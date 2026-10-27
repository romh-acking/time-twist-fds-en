arch nes.cpu

org $000020FD
	incbin "asm/gfx/font.chr"
	
org $00002320
	db "Translation by FCC and friends."

org $000009d2
	incbin "asm/gfx/title.chr"

// OAM: Relocate b/c expanded CHR tile count
org $00002375; base $C575; fill $100, $00
TitleSprite:
	incbin "asm/gfx/title.sprite.chr"

// CHR: Extend write region to support expanded tile usage
org $0000028F; base $A48F
	ldx #$FF

// CHR: remove 4 tile color writing
org $00000296; base $A496; fill $0B, $ea
	
// OAM: remove uneccessary writing title tileset
org $000002A1; base $A4A7; fill $0B, $ea

// OAM: remove uneccessary 4 tile color writing
org $000002AC; base $A4AC; fill $0B, $ea

org $000002C0; base $A4C0
	db TitleSprite&$FF,TitleSprite>>8&$FF

// Tilescreen tilemap
org $0000065E; base $A85E; fill $2EF, $FF
org $0000065E; base $A85E
	incbin "asm/gfx/title.compressed"

// Move clock hand sprites left
org $000003CA
	db $68
org $000003CE
	db $70
