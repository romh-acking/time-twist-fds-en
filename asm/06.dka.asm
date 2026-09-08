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
// Adjust (WAIT #1) spacing
///////////////////
//org $0000202D; base $802D
//	ldx #$18

//org $000023B9; base $83B9; fill $0D,$ea
//org $000023B9; base $83B9
//	inc $69
//	rts

///////////////////
// Expand menu
///////////////////
// Not enough space to store expanded tilemap
org $000028A3; base $88A3
	db $05,$25,$45,$65,$85,$A5,$C5,$E5

org $00002896; base $8896
	ldx #$16

// Bottom start index
org $0000281D; base $881d
	ldy #$2C
// Middle start index
org $00002822; base $8822
	ldy #$58
	
org $00002827; base $8827
	ldx #$2C

// Relocate tilemap
//org $00002829; base $8829
	//lda $89ae,y
	
org $000028AB; base $88AB
	db $A6,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A7
	db $AA,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$AB
	db $A9,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$A9
	db $AA,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$AB

// Relocate where sprite data starts
org $00002B53; base $8B53
	lda {SpriteSlot03Constant}&$FF //lo
org $00002B57; base $8B57
	lda {SpriteSlot03Constant}>>8 // hi

org $000030B8; base $90b8
	lda {SpriteSlot03Constant}&$FF //lo
org $000030Bc; base $90bc
	lda {SpriteSlot03Constant}>>8 // hi

org $00002B0C; base $8b0c
	sta {SpriteSlot01}
	sta {SpriteSlot02}

org $00001156; base $7156
	sbc {SpriteSlot02}
	sta {SpriteSlot01}

org $0000115E; base $715e
	sta {SpriteSlot02}
  
org $0000108B; base $708b
	stx {SpriteSlot01}
	stx {SpriteSlot02}
	
org $00002BA9; base $8ba9
	sta {SpriteSlot01}

org $000030B0; base $90B0
	lda {SpriteSlot01}

org $00002B4E; base $8b4e
	lda {SpriteSlot01}
	
org $00002B62; base $8b62
	lda {SpriteSlot01}
	
org $00001152; base $7152
	lda {SpriteSlot01}
	
//------------------
// Adjust text printing / sprites
//------------------

// Move left column left
org $000034AF; base $94AF
	lda #$47

// Move left column left
org $00003890; base $9890
	lda #$30

// Extend text limit
org $000034BC; base $94BC
	lda #$09

// Move right sprite of cursor
org $0000389F; base $989F; fill $0E, $ea
