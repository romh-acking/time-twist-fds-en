arch nes.cpu

define TextBufferStart						0x8747
define LineLength							0x18

define TextBuffer_Line1						{TextBufferStart}
define TextBuffer_Line2						{TextBuffer_Line1}+{LineLength}
define TextBuffer_Line3						{TextBuffer_Line2}+{LineLength}
define TextBuffer_Line4						{TextBuffer_Line3}+{LineLength}
define TextBuffer_Line5						{TextBuffer_Line4}+{LineLength}
define TextBuffer_Line6						{TextBuffer_Line5}+{LineLength}
define TextBuffer_Line7						{TextBuffer_Line6}+{LineLength}
define TextBuffer_Line8						{TextBuffer_Line7}+{LineLength}


define PpuLine_Line1						#$24
define PpuLine_Line2						#$44
define PpuLine_Line3						#$64
define PpuLine_Line4						#$84
define PpuLine_Line5						#$A4
define PpuLine_Line6						#$C4
define PpuLine_Line7						#$E4

define LineNumber							0x72

define SpriteSlot01							$0588+4
define SpriteSlot02							$0589+4
define SpriteSlot03							$058a+4

define SpriteSlot01Constant					#$0588+4
define SpriteSlot02Constant					#$0589+4
define SpriteSlot03Constant					#$058a+4

///////////////////
// Single line
///////////////////

// For auto-linebreak
org $00002436
 adc #$08

org $0000223E
  nop
  
///////////////////
// Remove diatrics: Text buffer (located @ 0x8747)
///////////////////
// Remove writing diatric to text buffer 
org $000023F0; base $83F0; fill $15, $ea

// Change iterator from 2 => 1
org $00002444; base $8444
	adc #$01
	
// Adjust new starting text after (SCROLL)
org $000024FF; base $84FF
	lda {TextBuffer_Line1},y
org $00002512; base $8512
	lda {TextBuffer_Line2},y
org $00002525; base $8525
	lda {TextBuffer_Line3},y
org $00002538; base $8538
	lda {TextBuffer_Line4},y
org $0000254B; base $854B
	lda {TextBuffer_Line5},y
org $0000255E; base $855E
	lda {TextBuffer_Line6},y
org $00002571; base $8571
	lda {TextBuffer_Line7},y
	
// Adjust new PPU start after (SCROLL)
// Skip writing to first line (vanilla does this for diatrics)
org $000024FA; base $84FA; fill $10, $ea
	//lda {PpuLine_Line1}
org $000024FA; base $84FA
	dec {LineNumber}
	
org $0000250D; base $850D
	lda {PpuLine_Line2}
org $00002520; base $8520
	lda {PpuLine_Line3}
org $00002533; base $8533
	lda {PpuLine_Line4}
org $00002546; base $8546
	lda {PpuLine_Line5}
org $00002559; base $8559
	lda {PpuLine_Line6}
org $0000256C; base $856C
	lda {PpuLine_Line7}
	
// Adjust new PPU start after (SCROLL) (AGAIN)
// Skip writing to first line (vanilla does this for diatrics)
org $00002594; base $8594; fill $05, $ea
org $00002594; base $8594
	jmp $85B7

// Change iterator from 2 => 1 for  (SCROLL)  
// And also halve the count required to exit the loop 
org $000025C1; base $85C1
	nop
    cpy #$18

// Move text up in text buffer for (SCROLL)
org $00002451; base $8451
  lda {TextBuffer_Line3},x
  sta {TextBuffer_Line1},x

///////////////////
// Remove diatrics: Text buffer (text options)
///////////////////
org $000034D8; base $94D8; fill $29, $ea
org $000034D3; base $94D3; fill $01, $ea

///////////////////
// Single line (LINE)
///////////////////

//org $0000228E; base $828E
//	ldx #$18
//org $000022A3; base $82A3
//	ldx #$30
//org $000022B8; base $82B8
//	ldx #$48
	
///////////////////
// Expand how many lines you can have on-screen
///////////////////
org $0000226F; base $826F; fill $4F, $ea
org $0000226F; base $826F
LineCalc:
  lda {LineNumber}
  bne NotLine1
  ldx #$18
  jmp LINE
NotLine1:
  cmp #$01
  bne NotLine2
  ldx #$30
  jmp LINE
NotLine2:
  cmp #$02
  bne NotLine3
  ldx #$48
  jmp LINE
NotLine3:
  cmp #$03
  bne NotLine4
  ldx #$60
  jmp LINE
NotLine4:
  cmp #$04
  bne NotLine5
  ldx #$78
  jmp LINE
NotLine5:
  cmp #$05
  bne NotLine6
  ldx #$90
  jmp LINE
NotLine6:
  cmp #$06
  bne NotLine7
  ldx #$A8
  jmp LINE
NotLine7:
  ldx #$C0
LINE:
	inc {LineNumber}
	iny
	jmp $815E

///////////////////
// Adjust where (SCROLL) starts in text buffer
///////////////////
org $00001FFB; base $7FFB
	// New line text buffer X
	ldx #$30

org $000023C6; base $83C6
	// New line text buffer location
	lda #$77		// lo
	sta $61
	ldx #$87		// hi
	
	// New line PPU location
	ldy #$84		// lo
	lda #$22		// hi

///////////////////
// Adjust WAIT spacing
///////////////////

// (WAIT #1)
org $00002027; base $8027; fill $0C, $ea
// (WAIT #2)
org $0000200E; base $800E; fill $0C, $ea
// (WAIT #3)
org $00002040; base $8040; fill $0C, $ea

org $00002027; base $8027
  jsr CalcLinePrint
  jmp LineCalc

///////////////////
// Menu: Double space => single space
///////////////////
//------------------
// Printing
//------------------
// Change text spacing
org $00003483; base $9483; fill $01, $ea

// Remove column shift (X)
org $00003499; base $9499; fill $16, $ea

// Remove column shift (Y)
org $00003481; base $9481; fill $03, $ea
	
//org $00002896; base $8896
	//ldx #$16

//------------------
// Sprite remove column change
//------------------
// Change text spacing
org $00003876; base $9876; fill $03, $ea

// Remove column shift (Y)
org $00003885; base $9885; fill $0B, $ea

//------------------
// Sprite: L/R D-pad
//------------------
// Right d-pad
org $00003946; base $9946
	adc #$00
	
// Left d-pad
org $00003979; base $9979
	sbc #$00

//------------------
// Sprite alignment
//------------------
org $00003890; base $9890
	lda #$38
	
// Remove right sprite of cursor
//org $0000389F; base $989F; fill $0E, $ea

// Move right sprite of cursor
org $000038A2; base $98A2
	adc #$88

//------------------
// ETC
//------------------
// Move text to left
org $000034AF
  lda #$48

// Extend text limit
org $000034BC; base $94BC
	lda #$0F

///////////////////
// Repurpose STRING_9 to be a dictionary
///////////////////
org $22BE; base $82BE; fill $7, $ea
org $22BE; base $82BE
	jmp BottomDictionary
	
org $21CC; base $81CC; fill $49, $ea
org $21CC; base $81CC
	// Mostly copied from 0x22BE (RAM: $82BE)
	// The original dictionary reading code.
	
TopDictionary:
	lda #$00
	sta $3a
	jsr $810a // Read 6 bits
	
	jmp $82C5
BottomDictionary:
	lda #$00
	sta $3a
	jsr $810d // Read 5 bits
	
	lda $3a
	clc
	adc #$40
	sta $3a
	
	jmp $82C5

// $6E is a byte that controls where to start writing in the PPU
// The wrong value will result in longer wait time with a text printing SFX playing
CalcLinePrint:
	lda {LineNumber}
	cmp #$03
	bcc CalcLinePrint_NotLine4
		lda #$ff
		bne CalcLinePrint_Exit
	CalcLinePrint_NotLine4:
		cmp #$01
		bcc CalcLinePrint_NotLine2
		lda #$80
		bne CalcLinePrint_Exit
	CalcLinePrint_NotLine2:
		lda #$70
	
	CalcLinePrint_Exit:
		sta $6e
		rts

///////////////////
// Disk changing text: Switch 2nd and last line
///////////////////
// The game writes to a buffer to write string ids to print.
// Change where "SIDE B" dialogue id is stored
org $00001A17; base $7a17
	sty $7ABB

// Set buffer default value
org $00001AB9; base $7AB9
	db $08
	
// The game writes to a buffer to write string ids to print.
// Change where "SIDE A" dialogue id is stored
org $00001AF4; base $7af4
	sta $7ABB
org $00000033; base $6033
	lda $7ABB

// There's a function used to check if the third line was changed.
// If the test fails, the game prints the LOADING text.
// We obviously need to change this.
org $00001AA2; base $7AA2
	db $BB,$7A

///////////////////
// Disk changing text
///////////////////

// Hardcoded pointer I'm not supporting in my tool lol
//  8059: lda #$d9
//  805B: sta $6a
//  805D: lda #$85
//  805F: sta $6b

org $000025D9; base $85D9; fill $152, $FA
org $000025D9; base $85D9
	// Original String
	// しばらく(LINE)  おまちください(STOP)えー らむせーぶ(LINE)びー ですくせーぶ(LINE)せる きゃんせる(STOP)でぃすくせーぶ(LINE)しとるからの(STOP)ぜんぺんの(STOP)こうへんの(STOP)(LINE)えーめんを(STOP)(LINE)びーめんを(STOP)(LINE)(LINE)せっとしてください(STOP)(STOP)しょうはじめ(STOP)(STOP)(STOP)でぃすく、とらぶる(STOP)おぼえる(STOP)せーぶ(STOP)おもいだす(STOP)さいしょから(STOP)ろーど(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)せーぶでーたが、いじょうです(STOP)(LINE)げんざいのじょうたいで(LINE)ふぁいるをさくせいします(STOP)(LINE)さいしょからはじめます。(STOP)でぃすくせっと(STOP)ばってりー(STOP)らいとぷろてくと(STOP)げーむ めいかー(STOP)げーむ ねーむ(STOP)げーむ ばーじょん(STOP)えーびーさいど(STOP)でぃすく なんばー(STOP)(LINE)     えらー(STOP)ちがった でぃすくが(STOP)(LINE)    せっとされています(STOP)いったいさん(STOP)なにかようかの？(STOP)(STOP)はい(STOP)いいえ(STOP)いったい「じゃあつづきを はなすとするかの」(STOP)
	
	// Translated
	// Now(LINE)  loading...(STOP)RAM Save(LINE)Disk save(LINE)Cancel(STOP)Disk save done(STOP)Part 1(STOP)Part 2(STOP)(LINE)(LINE)Side A(STOP)(LINE)(LINE)Side B(STOP)(LINE)Switch to(STOP)(STOP)From Start(STOP)(STOP)(STOP)Disk Error(STOP)Remember(STOP)Save(STOP)Recall(STOP)From Start(STOP)Load(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)(STOP)Save corrupt(STOP)(LINE)right now(LINE)Create file(STOP)(LINE)New game(STOP)Disk insertion(STOP)Battery(STOP)Write protected(STOP)Game maker(STOP)Game name(STOP)Game version(STOP)Side AB(STOP)Disk No(STOP)(LINE)  Error(STOP)Wrong disk(STOP)(LINE)  inserted(STOP)Ittai(STOP)What's up?(STOP)(STOP)Yes(STOP)No(STOP)Ittai: Continue?(STOP)

	db $34,$E5,$BC,$5B,$69,$67,$00,$19,$06,$8C,$D3,$4D,$7D,$44,$03,$2D,$48,$05,$44,$F0,$19,$09,$15,$6A,$40,$2A,$27,$80,$80,$34,$21,$0B,$FA,$0C,$84,$8A,$B5,$20,$15,$12,$D0,$CE,$34,$4F,$A0,$3C,$04,$53,$B6,$3F,$A0,$3C,$04,$53,$B6,$4F,$A0,$F1,$E1,$22,$03,$12,$D0,$3E,$80,$F1,$E1,$22,$03,$12,$D0,$7E,$80,$F0,$92,$C4,$26,$10,$F6,$A6,$77,$D0,$FA,$15,$13,$8C,$B5,$24,$C0,$45,$3F,$A0,$FA,$FA,$0C,$84,$8A,$B4,$44,$51,$39,$1F,$A0,$44,$43,$04,$30,$11,$11,$FA,$48,$05,$44,$FA,$44,$40,$80,$2C,$BF,$A0,$15,$13,$8C,$B5,$24,$C0,$45,$3F,$A0,$2C,$E0,$03,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$48,$05,$44,$B4,$23,$91,$45,$43,$D3,$FA,$F0,$89,$03,$0E,$9D,$A6,$9C,$B7,$80,$91,$10,$04,$C4,$B4,$52,$0B,$13,$E8,$F0,$68,$8B,$5A,$30,$06,$09,$F4,$0C,$84,$8A,$B4,$83,$52,$11,$14,$C8,$38,$DF,$A0,$04,$04,$D3,$11,$16,$3E,$80,$59,$12,$13,$12,$D3,$D1,$39,$31,$02,$4C,$40,$FE,$80,$18,$03,$04,$B4,$C0,$0A,$11,$1F,$A0,$18,$03,$04,$B4,$D0,$0C,$13,$E8,$18,$03,$04,$B5,$51,$11,$48,$83,$8D,$FA,$48,$80,$C4,$B4,$00,$7E,$80,$0C,$84,$8A,$B4,$D3,$BE,$80,$F1,$6D,$A2,$22,$89,$C8,$FD,$59,$13,$8D,$1A,$D0,$C8,$48,$AF,$A0,$F1,$6D,$A4,$1A,$90,$88,$A6,$20,$7F,$40,$21,$34,$C0,$23,$E8,$58,$70,$13,$75,$2B,$54,$3D,$FF,$A0,$FA,$60,$44,$BE,$80,$34,$EF,$A0,$21,$34,$C0,$21,$CB,$42,$38,$D4,$C8,$35,$41,$1F,$FA

///////////////////
// FDS filelist for disk loading
///////////////////

// TT4B file id
org $00001BC5
	db $47,$48,$57,$FF
