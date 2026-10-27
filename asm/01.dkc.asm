arch nes.cpu

// This file is to show an error screen if you try to boot from Kouhen

// ぜんぺんィスクから
// ロードしクダサイ下さい。

// Please load part 1 disk.
// Pleasodprt1ik.

///////////////////
// Remove loading Japanese tileset to PPU (which overwrites BIOS font)
///////////////////
org $000001C8; base $DEE5; fill $03, $ea

///////////////////
// Correct palette to suit BIOS font
///////////////////
org $000001A2; base $DEBF
db $0F,$0F,$30,$0F
db $0F,$0F,$30,$0F
db $0F,$0F,$30,$0F
db $0F,$0F,$30,$0F

///////////////////
// Change blanking tile
///////////////////
org $00000156; base $DE73
	lda #$24

///////////////////
// Text
///////////////////

// PPU Start
org $0000008D; base $DDAA
  lda #$21
  sta $2006
  lda #$AA

table "asm/tbl/CHR - New.tbl"
org $000001EC; base $DF09; fill $3B, $FF
org $000001EC; base $DF09
	db "PLEASE LOAD"
	db $F5," "
	db "PART 1 DISK",$FF

