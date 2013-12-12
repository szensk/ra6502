Description
===========
ra6502 is a simple 6502 (dis)assembler made as a learning exercise in Ruby. It doesn't look like Ruby. I plan to include a simulator at a future date.

```ruby
test_program = 'LDX #$08
decrement:
  DEX
  STX $0200
  CPX #$03
  test: BNE decrement
  STX $0201
  BRK
  JMP test'
asm = Assembler.new(0x600) #program starts at 600
result = asm.assemble(test_program) #assemble program
#result = a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00 4c 02 06
asm.output('test.bin') #write to test.bin file
dasm = Disassembler.new
puts dasm.disassemble(result) #disassemble
#LDX #$08
#DEX
#STX $0200
#CPX #$03
#BNE $f8
#STX $0201
#BRK
#JMP $0602
```

Opcode File
==================

If you want to add a new type of derivative 6502 assembly, simply look at opcodes_6502.txt to look how to define more. The format:

```
$hh "WWW args"
$21 "AND (x,X)"
$58 "CLI"
```

where hh is a two hexadecimal digit number, WWW is capital opcode instruction (such as ADC), and args are optional. Lower-case x and y are stand-ins for hexadecimal values.

Stand-ins
---------
* '^': label (offset, 1 byte)

* '_': label (address, 2 byte)

* '?': two byte value

* 'x' or 'y': one byte value

