
	.setcpu "6502"

	.import _nsd_init
	.import _nsd_main

	.import NMI_Main
	.import DrawBackgroundSetup

	.include "includes.inc"
	.include "nes.inc"
	.include "drawing.inc"

	.export NsdMainPlayed

.segment "GAMEBSS"
NsdMainPlayed:	.byte $00		; VBlank完了後にnsd_mainを実行したか

; =======================
; 起動時処理
; =======================
.segment "STARTUP"
.proc Reset
	; 割り込み停止
	sei
	; Decimalモードクリア
	cld
	; スタックポインタ初期化
	ldx #$ff
	txs

	; RAM初期化
	jsr ClearMemory

	; PPU制御1レジスタ初期化
	lda #%00010000
	sta PpuControl1
	sta PPU_CTRL1

	; PPU制御2レジスタ初期化
	lda #%00000110
	sta PpuControl2
	sta PPU_CTRL2

	; サウンドドライバ初期化
	jsr _nsd_init

	; 背景描画ルーチン初期化
	jsr DrawBackgroundInit

	; VBlank待ち
@waitVBlank:
	lda PPU_STATUS
	bpl @waitVBlank

	; スプライトDMA初期化
	jsr InitSpriteDMA
	; DMA転送
	lda #$07
	sta APU_SPR_DMA

	; パレットデータロード
	jsr LoadPalette

	; 最初のシーン番号(0xffにしておいてNextScene内でincして0になる)
	lda #$ff
	sta SceneNo
	jsr NextScene

	;lda #$40
	;sta APU_PAD2

	; 初期完了したので割り込み許可
	lda PpuControl1
	ora #$80
	sta PpuControl1
	sta PPU_CTRL1
	cli

; =======================
; VBlank待ちメインループ
; =======================
@infinityLoop:
	lda NsdMainPlayed
	beq @infinityLoop		; 0なら実行済みなので、VBlank待ちループ
	jsr _nsd_main
	lda #$00
	sta NsdMainPlayed
	jmp @infinityLoop

.endproc

; =======================
; WRAM初期化
; =======================
ClearMemory:
	ldx #$00
	lda #$00
@clearMemoryLoop:
	sta <$00, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	inx
	bne @clearMemoryLoop
	rts

; =======================
; パレットデータ読み込み
; =======================
LoadPalette:
	; VRAMアドレスレジスタに、パレットロード先のアドレス$3F00を指定
	lda #$3f
	sta PPU_VRAM_ADDR2
	lda #$00
	sta PPU_VRAM_ADDR2
	ldx #$00
@loadPal:
	lda PaletteData, x
	sta PPU_VRAM_IO
	inx
	cpx #$20
	bne @loadPal
	rts

; =======================
; スプライト初期化
; =======================
InitSpriteDMA:
	ldx #$00
@initSpriteDMA:
	lda #$f8			; Y座標
	sta $0700, x
	inx
	lda #$ff			; スプライト番号
	sta $0700, x
	inx
	lda #$20			; 属性
	sta $0700, x
	inx
	lda #$00			; X座標
	sta $0700, x
	inx
	bne @initSpriteDMA
	rts

; =======================
; パレットデータ
; =======================
PaletteData:
	.include "palette.inc"

; =======================
; スプライトキャラクターデータ
; =======================
.segment "CHAR"
	.incbin "sprites.chr"

; =======================
; 背景キャラクターデータ
; =======================
.segment "BG"
	.incbin "bgchars.chr"

; =======================
; 各種ベクタ登録
; =======================
.segment "VECINFO"
	; VBlank割り込み
	.word NMI_Main
	; Reset割り込み
	.word Reset
	; IRQ(未使用)
	.word $0
