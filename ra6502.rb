require 'ostruct'

# 6502 assembler by szensk
# a Ruby learning exercise
# public domain
class Assembler
  attr_accessor :start, :input, :program, :result

  def initialize(program_start = 0)
    @start = program_start
    @operations = generate_operations unless @operations
  end

  def get_opcode(line)
    op = /([a-zA-Z]{3})\s?([^\s]*)/.match(line)
    if op then
      op1 = op[1]
      raise "No operation" unless @operations[op1]
      found = false
      @operations[op1].each do |opcode|
        r = Regexp.new(opcode[:args])
        match = r.match(op[2])
        if match and match.to_s.size == op[2].size #full match only
          return {opcode: opcode, args: op[2]}
        end
      end
    end
  end

  def assemble(input)
    @input = input
    remove_comments
    @program = parse_labels
    @result = ""
    count = @start || 0
    @bytes = 0
    @input.each_line do |line|
      line = line.upcase
      opcode = get_opcode(line)
      if opcode
        args = opcode[:args]
        opcode = opcode[:opcode]
        @result << format_opcode(opcode, args) + " "
        @bytes += opcode[:bytes]
        count += 1
      end
    end
    puts "Successfully assembled." + " Bytes: " + @bytes.to_s
    return @result
  end

  def format_label(ops, bytes)
    if @program.labels[ops] then
      target = @program.labels[ops]
      if bytes == 3 then
        ops = "%04x" % (target)
      else
        target = @program.labels[ops] - (@start + @bytes) - 2 #-2 because the current opcode is already jumped
        target = 256 + target if target < 0
        ops = "%02x" % target
      end
    end
    ops
  end

  def format_opcode(opcode, ops)
    bytes = opcode[:bytes]
    ops = ops.delete '$#(),'
    res = "#{opcode[:hex]}"
    ops = format_label(ops, bytes)
    ops = ops.delete('XY').downcase #yeah this is stupid
    if bytes == 1 then
      res
    elsif bytes == 2
      res << " " + ops
    else
      res << " " + ops[2..3] + " " + ops[0..1]
    end
    res
  end

  def remove_comments
    res = ""
    @input.each_line do |line|
      i = line.index(';')
      if i then
        res << line[0,i] + "\n"
      else
        res << line
      end
    end
    @input = res
  end

  def parse_labels
    res = OpenStruct.new
    res.labels = {}
    res.lines = {}
    result = ""
    count = @start
    @input.each_line do |line|
      stripped = line.strip
      line = line.upcase
      match = /([a-zA-Z0-9_]*):(.*)/.match(line)
      opcode = get_opcode(line) unless match
      count += opcode[:opcode][:bytes] if opcode
      if match then
        res.labels[match[1]] = count
        if match[2] then
          result << match[2] + "\n"
        end
      elsif stripped != ""
        result << line
      end
    end
    @input = result
    @program = res
  end

  def output(path, mode = :binary)
    res = @result.split("\s")
    File.open(path, 'wb') do |file|
      if mode == :binary then
        file.write [res.join].pack("H*")
      else
        count = 0
        file << ("%04x: " % @start)
        res.each do |byte|
          count += 1
          file << byte + " "
          file << ("\n%04x: " % (@start + count)) if count % 16 == 0
        end
      end
    end
    puts "Successfully wrote to file: " + path
  end

  #generate opcode hash from text file
  def generate_operations(path = 'opcodes_6502.txt')
    file = File.open(path, 'r').read
    @operations = {}
    file.each_line do |line|
      out = /\$([0-9a-f]*) "(\w\w\w\d?)\s?(.*)"/.match(line)
      add_opcode(@operations, out)
    end
    @operations
  end

  private
  def get_bytes(args)
    bytes = 2
    bytes = 1 if args == "" || args == "A"
    bytes += 1 if args.include?("?")
    bytes += 1 if args.include?("_")
    bytes
  end

  def add_opcode(operations, out)
    bytes = get_bytes(out[3])
    arguments = regexp_args(out[3])
    operations[out[2]] = [] unless operations[out[2]]
    operations[out[2]] << {opcode: out[2], hex: out[1], args: arguments, bytes: bytes}
  end

  def regexp_args(args)
    args = args.gsub('#x', '#\$[0-9a-fA-F]{2}|#[0-9a-fA-F]{2}')
    args = args.gsub('#y', '#\$[0-9a-fA-F]{2}|#[0-9a-fA-F]{2}')
    args = args.gsub('x', '\$[0-9a-fA-F]{2}')
    args = args.gsub('y', '\$[0-9a-fA-F]{2}')
    args = args.gsub('?', '\$[0-9a-fA-F]{4}')
    args = args.gsub('^', '[a-zA-Z0-9_]*')
    args = args.gsub('(', '\(')
    args = args.gsub(')', '\)')
    args.gsub('_', '[a-zA-Z0-9_]*')
  end
end
