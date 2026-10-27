arch nes.cpu

// The game stores the sprites as 1BPP and switches between planes with different palettes
// Adjust one of the planes' palettes because we're using a slightly different 1BPP format.
org $000008BE
	db $B0,$0F,$30

// Fade in
org $000008C4
	db $80,$0F,$00
org $000008CA
	db $90,$0F,$10
org $000008D0
	db $A0,$0F,$20

// $4B8 and $4C8: sprite ids to show in credits

org $000004E4; base $A6E4; fill $2B4,$FF
org $000004E4; base $A6E4
	// ZZ XY (ZZ = Pointer; X = length; Y = height)
	// ZZ XX (ZZ = sprite id; XX = palette id)

// Scenario
Label1:
	db Label2-Label1,$61
	db $00,$02,$00,$03,$01,$02,$01,$03,$02,$02,$02,$03
// Design
Label2:
	db Label3-Label2,$51
	db $06,$03,$07,$02,$07,$03,$08,$02,$08,$03
// Program
Label3:
	db Label4-Label3,$61
	db $18,$02,$18,$03,$19,$02,$19,$03,$1A,$02,$1A,$03
// Music
Label4:
	db Label5-Label4,$41
	db $11,$03,$25,$03,$26,$02,$26,$03
// PRODUCER
Label5:
	db Label6-Label5,$61
	db $18,$02,$18,$03,$2B,$02,$2B,$03,$2C,$02,$2C,$03
// DIRECTOR
Label6:
	db Label7-Label6,$61
	db $2F,$03,$14,$03,$30,$02,$30,$03,$31,$02,$31,$03
// PRODUCTION AND COPYRIGHT
Label7:
	db Label8-Label7,$73
	db $18,$02,$18,$03,$2B,$02,$2B,$03,$32,$02,$32,$03,$33,$02
	db $33,$03,$34,$02,$34,$03,$FF,$FF,$FF,$FF
	db $35,$02,$35,$03,$36,$02,$36,$03,$37,$02,$37,$03,$38,$02
// NINTENDO
Label8:
	db Label9-Label8,$61
	db $38,$03,$39,$02,$39,$03,$01,$02,$3A,$02,$02,$03
// Hajime Hirasawa
Label9:
	db Label10-Label9,$62
	db $1D,$03,$27,$02,$27,$03,$28,$02,$28,$03,$FF
	db $29,$02,$29,$03,$0C,$03,$2A,$02,$2A,$03,$25,$02
// Tomoshige Hashishita
Label10:
	db Label11-Label10,$72
	db $04,$03,$1B,$02,$1B,$03,$1C,$02,$14,$02,$1C,$03,$1D,$02
	db $1D,$03,$0C,$03,$0D,$02,$1E,$02,$1E,$03,$1F,$02,$1F,$03
// Tatsuya Hishida
Label11:
	db Label12-Label11,$62
	db $0A,$03,$0E,$03,$0F,$02,$2D,$02,$2D,$03,$08,$03
	db $29,$02,$2E,$02,$2E,$03,$2F,$02,$13,$03,$FF
// Keiji Terui
Label12:
	db Label13-Label12,$42
	db $03,$02,$03,$03,$04,$02,$FF
	db $04,$03,$05,$02,$05,$03,$06,$02
// Taisuke Araki
Label13:
	db Label14-Label13,$52
	db $0A,$03,$20,$02,$20,$03,$21,$02,$21,$03
	db $22,$02,$22,$03,$23,$02,$06,$02,$FF
// Motoo Yasuma
Label14:
	db Label15-Label14,$52
	db $11,$03,$23,$03,$10,$02,$11,$02,$FF
	db $24,$02,$0C,$03,$24,$03,$10,$03,$25,$02
// Eiko Takahashi
Label15:
	db Label16-Label15,$72
	db $09,$02,$09,$03,$0A,$02,$FF,$FF,$FF,$FF
	db $0A,$03,$0B,$02,$0B,$03,$0C,$02,$0C,$03,$0D,$02,$0D,$03
// Katsutomo Maeiwa
Label16:
	db Label17-Label16,$72
	db $0E,$02,$0E,$03,$0F,$02,$0F,$03,$10,$02,$10,$03,$11,$02
	db $11,$03,$12,$02,$12,$03,$13,$02,$13,$03,$FF,$FF
// Takahiro Umehara
Label17:
	db Label18-Label17,$62
	db $0A,$03,$0B,$02,$0B,$03,$14,$02,$14,$03,$02,$03
	db $15,$02,$15,$03,$16,$02,$16,$03,$17,$02,$17,$03
// Dummied out
Label18:
	db Label19-Label18,$11
	db $05,$02
// XX 本茂 (???moto Shegeru)
Label19:
	db Label20-Label19,$11
	db $06,$02
Label20:
	db $22,$82
	db $AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20
	db $AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20,$AE,$20
