#rd6502.rb
require 'pp'
class Disassembler
    @@operations = {"00"=>{:opcode=>"BRK", :hex=>"00", :bytes=>1, :args=>""},
    "01"=>{:opcode=>"ORA", :hex=>"01", :bytes=>2, :args=>"(x,X)"},
    "05"=>{:opcode=>"ORA", :hex=>"05", :bytes=>2, :args=>"x"},
    "06"=>{:opcode=>"ASL", :hex=>"06", :bytes=>2, :args=>"x"},
    "08"=>{:opcode=>"PHP", :hex=>"08", :bytes=>1, :args=>""},
    "09"=>{:opcode=>"ORA", :hex=>"09", :bytes=>2, :args=>"#x"},
    "0a"=>{:opcode=>"ASL", :hex=>"0a", :bytes=>1, :args=>"A"},
    "0d"=>{:opcode=>"ORA", :hex=>"0d", :bytes=>3, :args=>"?"},
    "0e"=>{:opcode=>"ASL", :hex=>"0e", :bytes=>3, :args=>"?"},
    "10"=>{:opcode=>"BPL", :hex=>"10", :bytes=>2, :args=>"^"},
    "11"=>{:opcode=>"ORA", :hex=>"11", :bytes=>2, :args=>"(x),Y"},
    "15"=>{:opcode=>"ORA", :hex=>"15", :bytes=>2, :args=>"x,X"},
    "16"=>{:opcode=>"ASL", :hex=>"16", :bytes=>2, :args=>"x,X"},
    "18"=>{:opcode=>"CLC", :hex=>"18", :bytes=>1, :args=>""},
    "19"=>{:opcode=>"ORA", :hex=>"19", :bytes=>3, :args=>"?,Y"},
    "1d"=>{:opcode=>"ORA", :hex=>"1d", :bytes=>3, :args=>"?,X"},
    "1e"=>{:opcode=>"ASL", :hex=>"1e", :bytes=>3, :args=>"?,X"},
    "20"=>{:opcode=>"JSR", :hex=>"20", :bytes=>3, :args=>"_"},
    "21"=>{:opcode=>"AND", :hex=>"21", :bytes=>2, :args=>"(x,X)"},
    "24"=>{:opcode=>"BIT", :hex=>"24", :bytes=>2, :args=>"x"},
    "25"=>{:opcode=>"AND", :hex=>"25", :bytes=>2, :args=>"x"},
    "26"=>{:opcode=>"ROL", :hex=>"26", :bytes=>2, :args=>"x"},
    "28"=>{:opcode=>"PLP", :hex=>"28", :bytes=>1, :args=>""},
    "29"=>{:opcode=>"AND", :hex=>"29", :bytes=>2, :args=>"#x"},
    "2a"=>{:opcode=>"ROL", :hex=>"2a", :bytes=>1, :args=>"A"},
    "2c"=>{:opcode=>"BIT", :hex=>"2c", :bytes=>3, :args=>"?"},
    "2d"=>{:opcode=>"AND", :hex=>"2d", :bytes=>3, :args=>"?"},
    "2e"=>{:opcode=>"ROL", :hex=>"2e", :bytes=>3, :args=>"?"},
    "30"=>{:opcode=>"BMI", :hex=>"30", :bytes=>2, :args=>"^"},
    "31"=>{:opcode=>"AND", :hex=>"31", :bytes=>2, :args=>"(x),Y"},
    "35"=>{:opcode=>"AND", :hex=>"35", :bytes=>2, :args=>"x,X"},
    "36"=>{:opcode=>"ROL", :hex=>"36", :bytes=>2, :args=>"x,X"},
    "38"=>{:opcode=>"SEC", :hex=>"38", :bytes=>1, :args=>""},
    "39"=>{:opcode=>"AND", :hex=>"39", :bytes=>3, :args=>"?,Y"},
    "3d"=>{:opcode=>"AND", :hex=>"3d", :bytes=>3, :args=>"?,X"},
    "3e"=>{:opcode=>"ROL", :hex=>"3e", :bytes=>3, :args=>"?,X"},
    "40"=>{:opcode=>"RTI", :hex=>"40", :bytes=>1, :args=>""},
    "41"=>{:opcode=>"EOR", :hex=>"41", :bytes=>2, :args=>"(x,X)"},
    "45"=>{:opcode=>"EOR", :hex=>"45", :bytes=>2, :args=>"x"},
    "46"=>{:opcode=>"LSR", :hex=>"46", :bytes=>2, :args=>"x"},
    "48"=>{:opcode=>"PHA", :hex=>"48", :bytes=>1, :args=>""},
    "49"=>{:opcode=>"EOR", :hex=>"49", :bytes=>2, :args=>"#x"},
    "4a"=>{:opcode=>"LSR", :hex=>"4a", :bytes=>1, :args=>"A"},
    "4c"=>{:opcode=>"JMP", :hex=>"4c", :bytes=>3, :args=>"_"},
    "4d"=>{:opcode=>"EOR", :hex=>"4d", :bytes=>3, :args=>"?"},
    "4e"=>{:opcode=>"LSR", :hex=>"4e", :bytes=>3, :args=>"?"},
    "50"=>{:opcode=>"BVC", :hex=>"50", :bytes=>2, :args=>"^"},
    "51"=>{:opcode=>"EOR", :hex=>"51", :bytes=>2, :args=>"(x),Y"},
    "55"=>{:opcode=>"EOR", :hex=>"55", :bytes=>2, :args=>"x,X"},
    "56"=>{:opcode=>"LSR", :hex=>"56", :bytes=>2, :args=>"x,X"},
    "58"=>{:opcode=>"CLI", :hex=>"58", :bytes=>1, :args=>""},
    "59"=>{:opcode=>"EOR", :hex=>"59", :bytes=>3, :args=>"?,Y"},
    "5d"=>{:opcode=>"EOR", :hex=>"5d", :bytes=>3, :args=>"?,X"},
    "5e"=>{:opcode=>"LSR", :hex=>"5e", :bytes=>3, :args=>"?,X"},
    "60"=>{:opcode=>"RTS", :hex=>"60", :bytes=>1, :args=>""},
    "61"=>{:opcode=>"ADC", :hex=>"61", :bytes=>2, :args=>"(x,X)"},
    "65"=>{:opcode=>"ADC", :hex=>"65", :bytes=>2, :args=>"x"},
    "66"=>{:opcode=>"ROR", :hex=>"66", :bytes=>2, :args=>"x"},
    "68"=>{:opcode=>"PLA", :hex=>"68", :bytes=>1, :args=>""},
    "69"=>{:opcode=>"ADC", :hex=>"69", :bytes=>2, :args=>"#x"},
    "6a"=>{:opcode=>"ROR", :hex=>"6a", :bytes=>1, :args=>"A"},
    "6c"=>{:opcode=>"JMP", :hex=>"6c", :bytes=>3, :args=>"(_)"},
    "6d"=>{:opcode=>"ADC", :hex=>"6d", :bytes=>3, :args=>"?"},
    "6e"=>{:opcode=>"ROR", :hex=>"6e", :bytes=>3, :args=>"?"},
    "70"=>{:opcode=>"BVS", :hex=>"70", :bytes=>2, :args=>"^"},
    "71"=>{:opcode=>"ADC", :hex=>"71", :bytes=>2, :args=>"(x),Y"},
    "75"=>{:opcode=>"ADC", :hex=>"75", :bytes=>2, :args=>"x,X"},
    "76"=>{:opcode=>"ROR", :hex=>"76", :bytes=>2, :args=>"x,X"},
    "78"=>{:opcode=>"SEI", :hex=>"78", :bytes=>1, :args=>""},
    "79"=>{:opcode=>"ADC", :hex=>"79", :bytes=>3, :args=>"?,Y"},
    "7d"=>{:opcode=>"ADC", :hex=>"7d", :bytes=>3, :args=>"?,X"},
    "7e"=>{:opcode=>"ROR", :hex=>"7e", :bytes=>3, :args=>"?,X"},
    "81"=>{:opcode=>"STA", :hex=>"81", :bytes=>2, :args=>"(x,X)"},
    "84"=>{:opcode=>"STY", :hex=>"84", :bytes=>2, :args=>"x"},
    "85"=>{:opcode=>"STA", :hex=>"85", :bytes=>2, :args=>"x"},
    "86"=>{:opcode=>"STX", :hex=>"86", :bytes=>2, :args=>"x"},
    "88"=>{:opcode=>"DEY", :hex=>"88", :bytes=>1, :args=>""},
    "8a"=>{:opcode=>"TXA", :hex=>"8a", :bytes=>1, :args=>""},
    "8c"=>{:opcode=>"STY", :hex=>"8c", :bytes=>3, :args=>"?"},
    "8d"=>{:opcode=>"STA", :hex=>"8d", :bytes=>3, :args=>"?"},
    "8e"=>{:opcode=>"STX", :hex=>"8e", :bytes=>3, :args=>"?"},
    "90"=>{:opcode=>"BCC", :hex=>"90", :bytes=>2, :args=>"^"},
    "91"=>{:opcode=>"STA", :hex=>"91", :bytes=>2, :args=>"(x),Y"},
    "94"=>{:opcode=>"STY", :hex=>"94", :bytes=>2, :args=>"x,X"},
    "95"=>{:opcode=>"STA", :hex=>"95", :bytes=>2, :args=>"x,X"},
    "96"=>{:opcode=>"STX", :hex=>"96", :bytes=>2, :args=>"x,Y"},
    "98"=>{:opcode=>"TYA", :hex=>"98", :bytes=>1, :args=>""},
    "99"=>{:opcode=>"STA", :hex=>"99", :bytes=>3, :args=>"?,Y"},
    "9a"=>{:opcode=>"TXS", :hex=>"9a", :bytes=>1, :args=>""},
    "9d"=>{:opcode=>"STA", :hex=>"9d", :bytes=>3, :args=>"?,X"},
    "a0"=>{:opcode=>"LDY", :hex=>"a0", :bytes=>2, :args=>"#x"},
    "a1"=>{:opcode=>"LDA", :hex=>"a1", :bytes=>2, :args=>"(x,X)"},
    "a2"=>{:opcode=>"LDX", :hex=>"a2", :bytes=>2, :args=>"#x"},
    "a4"=>{:opcode=>"LDY", :hex=>"a4", :bytes=>2, :args=>"x"},
    "a5"=>{:opcode=>"LDA", :hex=>"a5", :bytes=>2, :args=>"x"},
    "a6"=>{:opcode=>"LDX", :hex=>"a6", :bytes=>2, :args=>"x"},
    "a8"=>{:opcode=>"TAY", :hex=>"a8", :bytes=>1, :args=>""},
    "a9"=>{:opcode=>"LDA", :hex=>"a9", :bytes=>2, :args=>"#x"},
    "aa"=>{:opcode=>"TAX", :hex=>"aa", :bytes=>1, :args=>""},
    "ac"=>{:opcode=>"LDY", :hex=>"ac", :bytes=>3, :args=>"?"},
    "ad"=>{:opcode=>"LDA", :hex=>"ad", :bytes=>3, :args=>"?"},
    "ae"=>{:opcode=>"LDX", :hex=>"ae", :bytes=>3, :args=>"?"},
    "b0"=>{:opcode=>"BCS", :hex=>"b0", :bytes=>2, :args=>"^"},
    "b1"=>{:opcode=>"LDA", :hex=>"b1", :bytes=>2, :args=>"(x),Y"},
    "b4"=>{:opcode=>"LDY", :hex=>"b4", :bytes=>2, :args=>"x,X"},
    "b5"=>{:opcode=>"LDA", :hex=>"b5", :bytes=>2, :args=>"x,X"},
    "b6"=>{:opcode=>"LDX", :hex=>"b6", :bytes=>2, :args=>"x,Y"},
    "b8"=>{:opcode=>"CLV", :hex=>"b8", :bytes=>1, :args=>""},
    "b9"=>{:opcode=>"LDA", :hex=>"b9", :bytes=>3, :args=>"?,Y"},
    "ba"=>{:opcode=>"TSX", :hex=>"ba", :bytes=>1, :args=>""},
    "bc"=>{:opcode=>"LDY", :hex=>"bc", :bytes=>3, :args=>"?,X"},
    "bd"=>{:opcode=>"LDA", :hex=>"bd", :bytes=>3, :args=>"?,X"},
    "be"=>{:opcode=>"LDX", :hex=>"be", :bytes=>3, :args=>"?,Y"},
    "c0"=>{:opcode=>"CPY", :hex=>"c0", :bytes=>2, :args=>"#x"},
    "c1"=>{:opcode=>"CMP", :hex=>"c1", :bytes=>2, :args=>"(x,X)"},
    "c4"=>{:opcode=>"CPY", :hex=>"c4", :bytes=>2, :args=>"x"},
    "c5"=>{:opcode=>"CMP", :hex=>"c5", :bytes=>2, :args=>"x"},
    "c6"=>{:opcode=>"DEC", :hex=>"c6", :bytes=>2, :args=>"x"},
    "c8"=>{:opcode=>"INY", :hex=>"c8", :bytes=>1, :args=>""},
    "c9"=>{:opcode=>"CMP", :hex=>"c9", :bytes=>2, :args=>"#x"},
    "ca"=>{:opcode=>"DEX", :hex=>"ca", :bytes=>1, :args=>""},
    "cc"=>{:opcode=>"CPY", :hex=>"cc", :bytes=>3, :args=>"?"},
    "cd"=>{:opcode=>"CMP", :hex=>"cd", :bytes=>3, :args=>"?"},
    "ce"=>{:opcode=>"DEC", :hex=>"ce", :bytes=>3, :args=>"?"},
    "d0"=>{:opcode=>"BNE", :hex=>"d0", :bytes=>2, :args=>"^"},
    "d1"=>{:opcode=>"CMP", :hex=>"d1", :bytes=>2, :args=>"(x),Y"},
    "d5"=>{:opcode=>"CMP", :hex=>"d5", :bytes=>2, :args=>"x,X"},
    "d6"=>{:opcode=>"DEC", :hex=>"d6", :bytes=>2, :args=>"x,X"},
    "d8"=>{:opcode=>"CLD", :hex=>"d8", :bytes=>1, :args=>""},
    "d9"=>{:opcode=>"CMP", :hex=>"d9", :bytes=>3, :args=>"?,Y"},
    "dd"=>{:opcode=>"CMP", :hex=>"dd", :bytes=>3, :args=>"?,X"},
    "de"=>{:opcode=>"DEC", :hex=>"de", :bytes=>3, :args=>"?,X"},
    "e0"=>{:opcode=>"CPX", :hex=>"e0", :bytes=>2, :args=>"#x"},
    "e1"=>{:opcode=>"SBC", :hex=>"e1", :bytes=>2, :args=>"(x,X)"},
    "e4"=>{:opcode=>"CPX", :hex=>"e4", :bytes=>2, :args=>"x"},
    "e5"=>{:opcode=>"SBC", :hex=>"e5", :bytes=>2, :args=>"x"},
    "e6"=>{:opcode=>"INC", :hex=>"e6", :bytes=>2, :args=>"x"},
    "e8"=>{:opcode=>"INX", :hex=>"e8", :bytes=>1, :args=>""},
    "e9"=>{:opcode=>"SBC", :hex=>"e9", :bytes=>2, :args=>"#x"},
    "ea"=>{:opcode=>"NOP", :hex=>"ea", :bytes=>1, :args=>""},
    "ec"=>{:opcode=>"CPX", :hex=>"ec", :bytes=>3, :args=>"?"},
    "ed"=>{:opcode=>"SBC", :hex=>"ed", :bytes=>3, :args=>"?"},
    "ee"=>{:opcode=>"INC", :hex=>"ee", :bytes=>3, :args=>"?"},
    "f0"=>{:opcode=>"BEQ", :hex=>"f0", :bytes=>2, :args=>"^"},
    "f1"=>{:opcode=>"SBC", :hex=>"f1", :bytes=>2, :args=>"(x),Y"},
    "f5"=>{:opcode=>"SBC", :hex=>"f5", :bytes=>2, :args=>"x,X"},
    "f6"=>{:opcode=>"INC", :hex=>"f6", :bytes=>2, :args=>"x,X"},
    "f8"=>{:opcode=>"SED", :hex=>"f8", :bytes=>1, :args=>""},
    "f9"=>{:opcode=>"SBC", :hex=>"f9", :bytes=>3, :args=>"?,Y"},
    "fd"=>{:opcode=>"SBC", :hex=>"fd", :bytes=>3, :args=>"?,X"},
    "fe"=>{:opcode=>"INC", :hex=>"fe", :bytes=>3, :args=>"?,X"}}

    def initialize()
        @result = ""
    end

    def decode_op(i, byte_arr)
        op = byte_arr[i]
        opcode = @@operations[op]
        if opcode then
            @result << opcode[:opcode] + " "
            bytes = opcode[:bytes]
            j = 2
            value = ""
            while j <= bytes
                value << "%02x" % (byte_arr[i+j-1].hex)
                j+=1
            end
            literal = '#' if opcode[:args].include?('#')
            literal = '' unless opcode[:args].include?('#')
            @result << "#{literal}$#{value[2..3] + value[0..1]}\n" if bytes > 2
            @result << "#{literal}$#{value}\n" if bytes == 2
            @result << "\n" if bytes == 1
            bytes
        else
            1
        end
    end

    def disassemble(input)
        @input = input
        @result = ""
        bytes = input.split("\s")
        i = 0
        while i < bytes.size
            i += decode_op(i, bytes)
        end
        @result
    end
    #generate opcode hash from text file
    def generate_operations(path = 'opcodes_6502.txt')
        file = File.open(path, 'r').read
        @@operations = {}
        file.each_line do |line|
            out = /\$([0-9a-f]*) "(\w\w\w\d?)\s?(.*)"/.match(line)
            add_opcode(@@operations, out)
        end
        @@operations
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
        operations[out[1]] = {opcode: out[2], hex: out[1], bytes: bytes, args: out[3]}
    end
end
