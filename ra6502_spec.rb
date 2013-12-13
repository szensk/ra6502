require './ra6502'

#examples
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
  JMP decrement',
'jsr init
jsr loop

init:
  jsr initSnake
  jsr generateApplePosition
  rts


initSnake:
  lda #02  ;start direction
  sta $02
  lda #04  ;start length
  sta $03
  lda #$11
  sta $10
  lda #$10
  sta $12
  lda #$0f
  sta $14
  lda #$04
  sta $11
  sta $13
  sta $15
  rts


generateApplePosition:
  ;load a new random byte into $00
  lda $fe
  sta $00

  ;load a new random number from 2 to 5 into $01
  lda $fe
  and #$03 ;mask out lowest 2 bits
  clc
  adc #02
  sta $01

  rts


loop:
  jsr readKeys
  jsr checkCollision
  jsr updateSnake
  jsr drawApple
  jsr drawSnake
  jsr spinWheels
  jmp loop


readKeys:
  lda $ff
  cmp #$77
  beq upKey
  cmp #$64
  beq rightKey
  cmp #$73
  beq downKey
  cmp #$61
  beq leftKey
  rts
upKey:
  lda #04
  bit $02
  bne illegalMove

  lda #01
  sta $02
  rts
rightKey:
  lda #08
  bit $02
  bne illegalMove

  lda #02
  sta $02
  rts
downKey:
  lda #01
  bit $02
  bne illegalMove

  lda #04
  sta $02
  rts
leftKey:
  lda #02
  bit $02
  bne illegalMove

  lda #08
  sta $02
  rts
illegalMove:
  rts


checkCollision:
  jsr checkAppleCollision
  jsr checkSnakeCollision
  rts


checkAppleCollision:
  lda $00
  cmp $10
  bne doneCheckingAppleCollision
  lda $01
  cmp $11
  bne doneCheckingAppleCollision

  ;eat apple
  inc $03
  inc $03 ;increase length
  jsr generateApplePosition
doneCheckingAppleCollision:
  rts


checkSnakeCollision:
  ldx #02 ;start with second segment
snakeCollisionLoop:
  lda $10,x
  cmp $10
  bne continueCollisionLoop

maybeCollided:
  lda $11,x
  cmp $11
  beq didCollide

continueCollisionLoop:
  inx
  inx
  cpx $03          ;got to last section with no collision
  beq didntCollide
  jmp snakeCollisionLoop

didCollide:
  jmp gameOver
didntCollide:
  rts


updateSnake:
  ldx $03 ;location of length
  dex
  txa
updateloop:
  lda $10,x
  sta $12,x
  dex
  bpl updateloop

  lda $02
  lsr
  bcs up
  lsr
  bcs right
  lsr
  bcs down
  lsr
  bcs left
up:
  lda $10
  sec
  sbc #$20
  sta $10
  bcc upup
  rts
upup:
  dec $11
  lda #$01
  cmp $11
  beq collision
  rts
right:
  inc $10
  lda #$1f
  bit $10
  beq collision
  rts
down:
  lda $10
  clc
  adc #$20
  sta $10
  bcs downdown
  rts
downdown:
  inc $11
  lda #$06
  cmp $11
  beq collision
  rts
left:
  dec $10
  lda $10
  and #$1f
  cmp #$1f
  beq collision
  rts
collision:
  jmp gameOver


drawApple:
  ldy #00
  lda $fe
  sta ($00),y
  rts


drawSnake:
  ldx #00
  lda #01
  sta ($10,x)
  ldx $03
  lda #00
  sta ($10,x)
  rts


spinWheels:
  ldx #00
spinloop:
  nop
  nop
  dex
  bne spinloop
  rts


gameOver:']

describe Assembler do
  before :each do
    @asm = Assembler.new(0x600)
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
    it "can assemble snake" do
      (@asm.assemble(tests[3])).should == ("20 06 06 20 38 06 20 0d 06 20 2a 06 60 a9 02 85 02 a9 04 85 03 a9 11 85 10 a9 10 85 12 a9 0f 85 14 a9 04 85 11 85 13 85 15 60 a5 fe 85 00 a5 fe 29 03 18 69 02 85 01 60 20 4d 06 20 8d 06 20 c3 06 20 19 07 20 20 07 20 2d 07 4c 38 06 a5 ff c9 77 f0 0d c9 64 f0 14 c9 73 f0 1b c9 61 f0 22 60 a9 04 24 02 d0 26 a9 01 85 02 60 a9 08 24 02 d0 1b a9 02 85 02 60 a9 01 24 02 d0 10 a9 04 85 02 60 a9 02 24 02 d0 05 a9 08 85 02 60 60 20 94 06 20 a8 06 60 a5 00 c5 10 d0 0d a5 01 c5 11 d0 07 e6 03 e6 03 20 2a 06 60 a2 02 b5 10 c5 10 d0 06 b5 11 c5 11 f0 09 e8 e8 e4 03 f0 06 4c aa 06 4c 35 07 60 a6 03 ca 8a b5 10 95 12 ca 10 f9 a5 02 4a b0 09 4a b0 19 4a b0 1f 4a b0 2f a5 10 38 e9 20 85 10 90 01 60 c6 11 a9 01 c5 11 f0 28 60 e6 10 a9 1f 24 10 f0 1f 60 a5 10 18 69 20 85 10 b0 01 60 e6 11 a9 06 c5 11 f0 0c 60 c6 10 a5 10 29 1f c9 1f f0 01 60 4c 35 07 a0 00 a5 fe 91 00 60 a2 00 a9 01 81 10 a6 03 a9 00 81 10 60 a2 00 ea ea ca d0 fb 60 ")
    end
  end
end
