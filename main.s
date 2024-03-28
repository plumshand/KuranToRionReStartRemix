; =======================
; VBlank割り込みメイン処理
; =======================

	.include "nes.inc"

	.importzp SceneNo, SubStatus
	.importzp JumpAddrLow, JumpAddrHigh

	.import _nsd_main
	.import SceneTitle
	.import SceneGamingPalette
	.import DrawBackgroundUpdate
	.import PpuControl1, PpuControl2
	.import NsdMainPlayed

	.export NMI_Main
	.export MainEnd
	.export NextScene, NextSubStatus
	.export ShowSprites, HideSprites

.code
NMI_Main:
	pha
	tya
	pha
	txa
	pha

@waitMainVBlank:
	lda PPU_STATUS
	bpl @waitMainVBlank

	sei							; 一旦割り込み停止

	; VBlank無効
	lda PpuControl1
	and #$7f
	sta PpuControl1
	sta PPU_CTRL1

	;jsr _nsd_main

	lda JumpAddrHigh			; ジャンプアドレス(HIGH)をロード
	beq MainEnd					; 0の場合は何もしない
	jmp (JumpAddrLow)			; 指定のアドレスへジャンプ

MainEnd:
	jsr DrawBackgroundUpdate	; 背景描画
	lda #$00					; スクロール位置座標(=0)
	sta PPU_VRAM_ADDR1			;  - X座標書き込み
	sta PPU_VRAM_ADDR1			;  - Y座標書き込み

	lda #$01
	sta NsdMainPlayed

	; VBlank有効
	lda PpuControl1
	ora #$80
	sta PpuControl1
	sta PPU_CTRL1

	cli

	pla
	tax
	pla
	tay
	pla

	rti

; =======================
; 次のシーンに更新
; =======================
NextScene:
	inc SceneNo
	ldy SceneNo
	lda JumpTable_H, y
	sta JumpAddrHigh
	lda JumpTable_L, y
	sta JumpAddrLow
	lda #$00
	sta SubStatus
	rts

; =======================
; 次のシーン無いサブステータスに更新
; =======================
NextSubStatus:
	inc SubStatus
	rts

; =======================
; BG・スプライト表示
; =======================
ShowSprites:
	lda PpuControl2
	ora #%00011000
	jmp writePpu2

; =======================
; BG・スプライト非表示
; =======================
HideSprites:
	lda PpuControl2
	and #%11100111
writePpu2:
	sta PpuControl2
	sta PPU_CTRL2
	rts

; =======================
; 各シーンジャンプテーブル
; =======================
JumpTable_L:
	.byte <SceneTitle
	.byte <SceneGamingPalette
	.byte $00
JumpTable_H:
	.byte >SceneTitle
	.byte >SceneGamingPalette
	.byte $00
