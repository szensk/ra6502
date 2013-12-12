require '../ra6502'

tests = [';test program
loop:
LDA #$ff ;test junk
TAX
INX
BRK
test:
INX
JMP loop',
'test:
LDA #$01
STA $0200
LDA #$05
STA $0201
LDA #$08
STA $0202
STA $4400,X
JMP test',
'LDX #$08
decrement:
  DEX
  STX $0200
  CPX #$03
  test: BNE decrement
  STX $0201
  BRK
  JMP decrement']

  operations = {"BRK"=>
  [{:opcode=>"BRK", :hex=>"00", :args=>"", :bytes=>1},
   {:opcode=>"BRK", :hex=>"00", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2}],
 "ORA"=>
  [{:opcode=>"ORA", :hex=>"01", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"ORA", :hex=>"05", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ORA", :hex=>"09", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ORA", :hex=>"0d", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"ORA", :hex=>"11", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"ORA", :hex=>"15", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"ORA", :hex=>"19", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"ORA", :hex=>"1d", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "ASL"=>
  [{:opcode=>"ASL", :hex=>"06", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ASL", :hex=>"0a", :args=>"", :bytes=>1},
   {:opcode=>"ASL", :hex=>"0a", :args=>"A", :bytes=>1},
   {:opcode=>"ASL", :hex=>"0e", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"ASL", :hex=>"16", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"ASL", :hex=>"1e", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "PHP"=>[{:opcode=>"PHP", :hex=>"08", :args=>"", :bytes=>1}],
 "BPL"=>
  [{:opcode=>"BPL", :hex=>"10", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BPL",
    :hex=>"10",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "CLC"=>[{:opcode=>"CLC", :hex=>"18", :args=>"", :bytes=>1}],
 "JSR"=>
  [{:opcode=>"JSR", :hex=>"20", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"JSR", :hex=>"20", :args=>"[a-zA-Z0-9_]*", :bytes=>3}],
 "AND"=>
  [{:opcode=>"AND", :hex=>"21", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"AND", :hex=>"25", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"AND", :hex=>"29", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"AND", :hex=>"2d", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"AND", :hex=>"31", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"AND", :hex=>"35", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"AND", :hex=>"39", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"AND", :hex=>"3d", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "BIT"=>
  [{:opcode=>"BIT", :hex=>"24", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BIT", :hex=>"2c", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3}],
 "ROL"=>
  [{:opcode=>"ROL", :hex=>"26", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ROL", :hex=>"2a", :args=>"", :bytes=>1},
   {:opcode=>"ROL", :hex=>"2a", :args=>"A", :bytes=>1},
   {:opcode=>"ROL", :hex=>"2e", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"ROL", :hex=>"36", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"ROL", :hex=>"3e", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "PLP"=>[{:opcode=>"PLP", :hex=>"28", :args=>"", :bytes=>1}],
 "BMI"=>
  [{:opcode=>"BMI", :hex=>"30", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BMI",
    :hex=>"30",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "SEC"=>[{:opcode=>"SEC", :hex=>"38", :args=>"", :bytes=>1}],
 "RTI"=>[{:opcode=>"RTI", :hex=>"40", :args=>"", :bytes=>1}],
 "EOR"=>
  [{:opcode=>"EOR", :hex=>"41", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"EOR", :hex=>"45", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"EOR", :hex=>"49", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"EOR", :hex=>"4d", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"EOR", :hex=>"51", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"EOR", :hex=>"55", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"EOR", :hex=>"59", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"EOR", :hex=>"5d", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "LSR"=>
  [{:opcode=>"LSR", :hex=>"46", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LSR", :hex=>"4a", :args=>"", :bytes=>1},
   {:opcode=>"LSR", :hex=>"4a", :args=>"A", :bytes=>1},
   {:opcode=>"LSR", :hex=>"4e", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"LSR", :hex=>"56", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"LSR", :hex=>"5e", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "PHA"=>[{:opcode=>"PHA", :hex=>"48", :args=>"", :bytes=>1}],
 "JMP"=>
  [{:opcode=>"JMP", :hex=>"4c", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"JMP", :hex=>"4c", :args=>"[a-zA-Z0-9_]*", :bytes=>3},
   {:opcode=>"JMP", :hex=>"6c", :args=>"(\\$[0-9a-fA-F]{4})", :bytes=>3},
   {:opcode=>"JMP", :hex=>"6c", :args=>"([a-zA-Z0-9_]*)", :bytes=>3}],
 "BVC"=>
  [{:opcode=>"BVC", :hex=>"50", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BVC",
    :hex=>"50",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "CLI"=>[{:opcode=>"CLI", :hex=>"58", :args=>"", :bytes=>1}],
 "RTS"=>[{:opcode=>"RTS", :hex=>"60", :args=>"", :bytes=>1}],
 "ADC"=>
  [{:opcode=>"ADC", :hex=>"61", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"ADC", :hex=>"65", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ADC", :hex=>"69", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ADC", :hex=>"6d", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"ADC", :hex=>"71", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"ADC", :hex=>"75", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"ADC", :hex=>"79", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"ADC", :hex=>"7d", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "ROR"=>
  [{:opcode=>"ROR", :hex=>"66", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"ROR", :hex=>"6a", :args=>"", :bytes=>1},
   {:opcode=>"ROR", :hex=>"6a", :args=>"A", :bytes=>1},
   {:opcode=>"ROR", :hex=>"6e", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"ROR", :hex=>"76", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"ROR", :hex=>"7e", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "PLA"=>[{:opcode=>"PLA", :hex=>"68", :args=>"", :bytes=>1}],
 "BVS"=>
  [{:opcode=>"BVS", :hex=>"70", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BVS",
    :hex=>"70",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "SEI"=>[{:opcode=>"SEI", :hex=>"78", :args=>"", :bytes=>1}],
 "STA"=>
  [{:opcode=>"STA", :hex=>"81", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"STA", :hex=>"85", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"STA", :hex=>"8d", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"STA", :hex=>"91", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"STA", :hex=>"95", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"STA", :hex=>"99", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"STA", :hex=>"9d", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "STY"=>
  [{:opcode=>"STY", :hex=>"84", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"STY", :hex=>"8c", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"STY", :hex=>"94", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2}],
 "STX"=>
  [{:opcode=>"STX", :hex=>"86", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"STX", :hex=>"8e", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"STX", :hex=>"96", :args=>"\\$[0-9a-fA-F]{2},Y", :bytes=>2}],
 "DEY"=>[{:opcode=>"DEY", :hex=>"88", :args=>"", :bytes=>1}],
 "TXA"=>[{:opcode=>"TXA", :hex=>"8a", :args=>"", :bytes=>1}],
 "BCC"=>
  [{:opcode=>"BCC", :hex=>"90", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BCC",
    :hex=>"90",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "TYA"=>[{:opcode=>"TYA", :hex=>"98", :args=>"", :bytes=>1}],
 "TXS"=>[{:opcode=>"TXS", :hex=>"9a", :args=>"", :bytes=>1}],
 "LDY"=>
  [{:opcode=>"LDY", :hex=>"a0", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDY", :hex=>"a4", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDY", :hex=>"ac", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"LDY", :hex=>"b4", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"LDY", :hex=>"bc", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "LDA"=>
  [{:opcode=>"LDA", :hex=>"a1", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"LDA", :hex=>"a5", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDA", :hex=>"a9", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDA", :hex=>"ad", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"LDA", :hex=>"b1", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"LDA", :hex=>"b5", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"LDA", :hex=>"b9", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"LDA", :hex=>"bd", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "LDX"=>
  [{:opcode=>"LDX", :hex=>"a2", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDX", :hex=>"a6", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"LDX", :hex=>"ae", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"LDX", :hex=>"b6", :args=>"\\$[0-9a-fA-F]{2},Y", :bytes=>2},
   {:opcode=>"LDX", :hex=>"be", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3}],
 "TAY"=>[{:opcode=>"TAY", :hex=>"a8", :args=>"", :bytes=>1}],
 "TAX"=>[{:opcode=>"TAX", :hex=>"aa", :args=>"", :bytes=>1}],
 "BCS"=>
  [{:opcode=>"BCS", :hex=>"b0", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BCS",
    :hex=>"b0",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "CLV"=>[{:opcode=>"CLV", :hex=>"b8", :args=>"", :bytes=>1}],
 "TSX"=>[{:opcode=>"TSX", :hex=>"ba", :args=>"", :bytes=>1}],
 "CPY"=>
  [{:opcode=>"CPY", :hex=>"c0", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CPY", :hex=>"c4", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CPY", :hex=>"cc", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3}],
 "CMP"=>
  [{:opcode=>"CMP", :hex=>"c1", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"CMP", :hex=>"c5", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CMP", :hex=>"c9", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CMP", :hex=>"cd", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"CMP", :hex=>"d1", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"CMP", :hex=>"d5", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"CMP", :hex=>"d9", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"CMP", :hex=>"dd", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "DEC"=>
  [{:opcode=>"DEC", :hex=>"c6", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"DEC", :hex=>"ce", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"DEC", :hex=>"d6", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"DEC", :hex=>"de", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "INY"=>[{:opcode=>"INY", :hex=>"c8", :args=>"", :bytes=>1}],
 "DEX"=>[{:opcode=>"DEX", :hex=>"ca", :args=>"", :bytes=>1}],
 "BNE"=>
  [{:opcode=>"BNE", :hex=>"d0", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BNE",
    :hex=>"d0",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "CLD"=>[{:opcode=>"CLD", :hex=>"d8", :args=>"", :bytes=>1}],
 "CPX"=>
  [{:opcode=>"CPX", :hex=>"e0", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CPX", :hex=>"e4", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"CPX", :hex=>"ec", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3}],
 "SBC"=>
  [{:opcode=>"SBC", :hex=>"e1", :args=>"(\\$[0-9a-fA-F]{2},X)", :bytes=>2},
   {:opcode=>"SBC", :hex=>"e5", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"SBC", :hex=>"e9", :args=>"#\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"SBC", :hex=>"ed", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"SBC", :hex=>"f1", :args=>"(\\$[0-9a-fA-F]{2}),Y", :bytes=>2},
   {:opcode=>"SBC", :hex=>"f5", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"SBC", :hex=>"f9", :args=>"\\$[0-9a-fA-F]{4},Y", :bytes=>3},
   {:opcode=>"SBC", :hex=>"fd", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "INC"=>
  [{:opcode=>"INC", :hex=>"e6", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"INC", :hex=>"ee", :args=>"\\$[0-9a-fA-F]{4}", :bytes=>3},
   {:opcode=>"INC", :hex=>"f6", :args=>"\\$[0-9a-fA-F]{2},X", :bytes=>2},
   {:opcode=>"INC", :hex=>"fe", :args=>"\\$[0-9a-fA-F]{4},X", :bytes=>3}],
 "INX"=>[{:opcode=>"INX", :hex=>"e8", :args=>"", :bytes=>1}],
 "NOP"=>[{:opcode=>"NOP", :hex=>"ea", :args=>"", :bytes=>1}],
 "BEQ"=>
  [{:opcode=>"BEQ", :hex=>"f0", :args=>"\\$[0-9a-fA-F]{2}", :bytes=>2},
   {:opcode=>"BEQ",
    :hex=>"f0",
    :args=>"[a-zA-Z0-9[a-zA-Z0-9_]*]*",
    :bytes=>2}],
 "SED"=>[{:opcode=>"SED", :hex=>"f8", :args=>"", :bytes=>1}]}

describe Assembler do
    before :each do
      @asm = Assembler.new(0x600)
    end
    describe '#generate_operations' do
        it "parses assembly listings into hash tables" do
            (@asm.generate_operations).should == (operations)
        end
    end
    describe '#assemble' do
        it "handles comments and 2 byte label jumps" do
            (@asm.assemble(tests[0])).should == ("a9 ff aa e8 00 e8 4c 00 06 ")
        end
        it "handles 4 byte offsets" do
            (@asm.assemble(tests[1])).should == ("a9 01 8d 00 02 a9 05 8d 01 02 a9 08 8d 02 02 9d 00 44 4c 00 06 ")
        end
        it "handles inline and branch labels" do
            (@asm.assemble(tests[2])).should == ("a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00 4c 02 06 ")
        end
    end
end
