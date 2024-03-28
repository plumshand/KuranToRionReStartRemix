; =====================================
; ゲーミングパレット
; =====================================

	.include "structs.inc"
	.include "includes.inc"
	.include "nes.inc"

	.export SceneGamingPalette

.segment "GAMEZP": zeropage
logoPaletteIndex:	.byte $00
logoInterval:		.byte $00
KuranStatus:		.byte $00
RionStatus:			.byte $00

PALETTE_COUNT = $0b			; パレットの色数
RAINBOW_INTERVAL = $08		; 色替えインターバル

.code
SceneGamingPalette:
	ldy SubStatus
	lda GamingStatusTable_H, y
	sta SubJumpAddrHigh
	lda GamingStatusTable_L, y
	sta SubJumpAddrLow
	jmp (SubJumpAddrLow)
EndSceneGamingPalette:
	jmp MainEnd

; =====================================
; ゲーミング初期化
; =====================================
InitGamingPalette:
	lda #PALETTE_COUNT
	sta logoPaletteIndex
	lda #RAINBOW_INTERVAL
	sta logoInterval
	jsr NextSubStatus
	jmp EndSceneGamingPalette

; =====================================
; ゲーミング処理
; =====================================
GamingProcess:
	ldx logoInterval				; パレット色替えウェイトカウンタ取得
	beq @changePalette				; 0になったら色替え
	dex								; カウンタ減算して
	stx logoInterval				; またメモリへ保持
	jmp @endGameProcess				; アニメーションしない
; =====================================
; ロゴ用パレット変更
; =====================================
@changePalette:
	lda #$3f						; パレット変更用にVRAMアドレスを指定
	sta PPU_VRAM_ADDR2
	lda #$05
	sta PPU_VRAM_ADDR2
	ldx logoPaletteIndex			; パレットデータインデックスをロード
	lda GamingPaletteData, x		; パレットデータをロード
	sta PPU_VRAM_IO					; VRAMへ書き込み
	jsr @adjustX					; インデックスを減算＆調整
	lda GamingPaletteData, x
	sta PPU_VRAM_IO
	jsr @adjustX
	lda GamingPaletteData, x
	sta PPU_VRAM_IO
	jsr @adjustX
	lda #$21						; VRAMアドレスが背景色のアドレスになってるので、背景色を書き込んどく
	sta PPU_VRAM_IO
	lda GamingPaletteData, x
	sta PPU_VRAM_IO
	jsr @adjustX
	lda GamingPaletteData, x
	sta PPU_VRAM_IO
	jsr @adjustX
	lda GamingPaletteData, x
	sta PPU_VRAM_IO
	jsr @adjustX
	ldx logoPaletteIndex			; 再度パレットデータインデックスを読み込み
	jsr @adjustX					; 「1」だけ減算＆調整
	stx logoPaletteIndex			; メモリへ保持
	lda #RAINBOW_INTERVAL			; 色替えインターバル値取得
	sta logoInterval				; 再度ウェイト

; =====================================
; キャラアニメーション
; =====================================
@charaAnimation:
	; RION
	lda KuranStatus					; クラン状態取得
	beq @kuran1						; 0なら
	lda #$0a
	sta __kuran3_char
	lda #$0b
	sta __kuran4_char
	lda #$00
	jmp @kuranChSt
@kuran1:
	lda #$0c
	sta __kuran3_char
	lda #$0d
	sta __kuran4_char
	lda #$01
@kuranChSt:
	sta KuranStatus
	; RION
	lda RionStatus					; リオン状態取得
	beq @rion1
	lda #$22
	sta __rion3_char
	lda #$23
	sta __rion4_char
	lda #$00
	jmp @rionChSt
@rion1:
	lda #$24
	sta __rion3_char
	lda #$25
	sta __rion4_char
	lda #$01
@rionChSt:
	sta RionStatus
	lda #$07
	sta APU_SPR_DMA

@endGameProcess:
	jmp MainEnd

@adjustX:
	dex
	bne @adjustEnd
	ldx #PALETTE_COUNT
@adjustEnd:
	rts

; =====================================
; ジャンプテーブル(LOW)
; =====================================
GamingStatusTable_L:
	.byte <InitGamingPalette
	.byte <GamingProcess

; =====================================
; ジャンプテーブル(HIGH)
; =====================================
GamingStatusTable_H:
	.byte >InitGamingPalette
	.byte >GamingProcess

; =====================================
; パレットデータ
; =====================================
GamingPaletteData:
	.byte $00, $22, $2c, $2b, $2a, $29, $28, $27, $26, $25, $24, $23
