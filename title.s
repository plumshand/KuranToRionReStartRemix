

	.include "structs.inc"
	.include "includes.inc"
	.include "drawing.inc"
	.include "nes.inc"

	.export SceneTitle

	.import _nsd_play_bgm
	.import _ReStart_BGM0

.segment "GAMEBSS"
LogoShowingWait:	.byte $00	; ロゴ表示からサウンド再生までの待ちフレーム

WAIT_LOGO_FRAMES = $10

.code
bgm00:	.addr	_ReStart_BGM0

SceneTitle:
	ldy SubStatus
	lda TitleJump_H, y
	sta SubJumpAddrHigh
	lda TitleJump_L, y
	sta SubJumpAddrLow
	jmp (SubJumpAddrLow)
EndSceneTitle:
	jmp MainEnd

; =====================================
; タイトル初期化処理
; =====================================
InitTitle:
	jsr HideSprites				; BG・スプライト非表示
	lda #<TitleBgData			; 描画用データアドレスをセット
	ldx #>TitleBgData
	jsr DrawBackgroundSetup
	lda #WAIT_LOGO_FRAMES
	sta LogoShowingWait			; ロゴ表示からサウンド再生までを若干待つように初期化
	jsr NextSubStatus			; 次のサブステータスへ
	jmp EndSceneTitle

; =====================================
; タイトル描画処理
; =====================================
DrawTitle:
	lda draw_status				; 描画ステータス取得
	and #STATUS_DRAWING_MASK	; 背景描画中かな？
	bne @endDrawTitle			; 描画中なので何もしない
	jsr ShowSprites				; 描画完了したので表示
	jsr NextSubStatus			; 次のステータス
@endDrawTitle:
	jmp EndSceneTitle

; =====================================
; キャラクタを描画
; =====================================
DrawChars:
	; KURAN
	lda #$50					; X座標
	sta __kuran1_xpos
	sta __kuran3_xpos
	lda #$58
	sta __kuran2_xpos
	sta __kuran4_xpos
	lda #$87					; Y座標
	sta __kuran1_ypos
	sta __kuran2_ypos
	sta __rion1_ypos
	sta __rion2_ypos
	lda #$8f
	sta __kuran3_ypos
	sta __kuran4_ypos
	sta __rion3_ypos
	sta __rion4_ypos
	lda #$08					; インデックス
	sta __kuran1_char
	lda #$09
	sta __kuran2_char
	lda #$0a
	sta __kuran3_char
	lda #$0b
	sta __kuran4_char
	lda #%00000001				; 属性
	sta __kuran1_attr
	sta __kuran2_attr
	sta __kuran3_attr
	sta __kuran4_attr
	; RION
	lda #$a0					; X座標
	sta __rion1_xpos
	sta __rion3_xpos
	lda #$a8
	sta __rion2_xpos
	sta __rion4_xpos
	lda #$20					; インデックス
	sta __rion1_char
	lda #$21
	sta __rion2_char
	lda #$22
	sta __rion3_char
	lda #$23
	sta __rion4_char
	lda #%00000000				; 属性
	sta __rion1_attr
	sta __rion2_attr
	sta __rion3_attr
	sta __rion4_attr

	; DMA転送
	lda #$07
	sta APU_SPR_DMA
	jsr NextSubStatus			; 次のステータス
	jmp EndSceneTitle

; =====================================
; タイトル表示だけしてちょっと待つ
; =====================================
WaitTitleBGM:
	ldx LogoShowingWait			; ウェイトフレームカウンタ取得
	dex							; デクリメント
	bne @endWaitTitleBGM		; まだウェイト用フレームカウンタが0になってないので継続
	jsr NextSubStatus			; 0になったので次のステータスへ
@endWaitTitleBGM:
	stx LogoShowingWait			; メモリへの保持
	jmp EndSceneTitle

; =====================================
; BGMスタート
; =====================================
StartTitleBGM:
	lda bgm00
	ldx bgm00 + 1
	jsr _nsd_play_bgm
	jsr NextSubStatus
	jmp EndSceneTitle

; =====================================
; タイトル描画完了
; =====================================
TitleComplete:
	jsr ShowSprites				; BG・スプライト表示
	jsr NextScene				; 次のシーンへ
	jmp EndSceneTitle

; =====================================
; タイトル用ジャンプテーブル(LOW)
; =====================================
TitleJump_L:
	.byte <InitTitle
	.byte <DrawTitle
	.byte <DrawChars
	.byte <WaitTitleBGM
	.byte <StartTitleBGM
	.byte <TitleComplete

; =====================================
; タイトル用ジャンプテーブル(HIGH)
; =====================================
TitleJump_H:
	.byte >InitTitle
	.byte >DrawTitle
	.byte >DrawChars
	.byte >WaitTitleBGM
	.byte >StartTitleBGM
	.byte >TitleComplete

; =====================================
; タイトル背景描画データ
; =====================================
TitleBgData:
	; ネームテーブル(ReStartロゴ)
	.byte CMD_WAIT_FRAME,     $20	; 32フレームだけ描画ウェイト
	.byte CMD_ADDR_AND_ARRAY		; アドレス指定＆データ書き込みコマンド
	.byte $20, $a6					; 書き込み先アドレス
	.byte $03						; データ個数
	.byte $01, $02, $03				; 実データ(CHRインデックス)
	.byte CMD_ADDR_AND_ARRAY, $20, $ac, $06, $04, $05, $02, $06, $07, $08
	.byte CMD_ADDR_AND_ARRAY, $20, $b8, $02, $07, $08
	.byte CMD_ADDR_AND_ARRAY, $20, $c6, $14, $09, $0a, $0b, $00, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $0d, $16, $17, $18, $12, $13
	.byte CMD_ADDR_AND_ARRAY, $20, $e6, $14, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $23, $24
	.byte CMD_WAIT_FRAME,     $01
	.byte CMD_ADDR_AND_ARRAY, $21, $06, $14, $01, $01, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $33, $38, $00, $33, $34
	.byte CMD_ADDR_AND_ARRAY, $21, $26, $14, $09, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $42, $47, $00, $42, $43
	.byte CMD_ADDR_AND_ARRAY, $21, $46, $14, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $00, $52, $53
	.byte CMD_WAIT_FRAME,     $01
	; KURANTORION
	.byte CMD_ADDR_AND_ARRAY, $21, $87, $12, $59, $5a, $34, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69
	.byte CMD_ADDR_AND_ARRAY, $21, $a7, $12, $6a, $6b, $6c, $6d, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b
	.byte CMD_WAIT_FRAME,     $01
	; 作詞・作曲
	.byte CMD_ADDR_AND_ARRAY, $22, $a8, $0f, $7c, $7d, $7e, $7c, $7f, $00, $00, $00, $80, $81, $82, $83, $84, $85, $82
	; リミックス
	.byte CMD_ADDR_AND_ARRAY, $22, $e8, $0d, $84, $86, $87, $80, $88, $00, $00, $00, $89, $8a, $8a, $8b, $8c
	; 2024 KURANTORION
	.byte CMD_ADDR_AND_ARRAY, $23, $48, $10, $8d, $8e, $8d, $8f, $00, $90, $91, $92, $93, $94, $95, $8e, $92, $96, $8e, $94
	.byte CMD_ADDR_AND_ARRAY, $22, $2a, $02, $97, $98
	.byte CMD_ADDR_AND_ARRAY, $22, $4a, $02, $99, $9a
	.byte CMD_WAIT_FRAME,     $01
	; ここから属性テーブル
	.byte CMD_ADDR_AND_ARRAY, $23, $c9, $06, $44, $55, $55, $55, $55, $11
	.byte CMD_ADDR_AND_ARRAY, $23, $d1, $06, $aa, $aa, $aa, $aa, $aa, $aa
	; 1フレームだけ描画ウェイト
	.byte CMD_WAIT_FRAME,     $01
	; 描画終了
	.byte CMD_FINISH
