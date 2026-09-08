arch nes.cpu

org $000020FD
	incbin "asm/gfx/font.chr"

// Adjust starting tilemap for menu to accomodate expanded menu options
org $00001FF4
	db $C1,$AE,$A6,$D4,$A8,$A7,$C7
	
	db $AE,$A9,$A9
	
	db $C1,$AE,$AA,$D4,$A8,$AB,$C7