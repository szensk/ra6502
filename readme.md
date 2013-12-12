Description
===========
ra6502 is a simple 6502 assembler made as a learning exercise in Ruby. It doesn't look like Ruby. I plan to include a dissassembler and simulator in the near future.

Usage
============

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
asm.assemble(test_program) #assemble program
asm.output('test.bin') #write to test.bin file
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

