; =====================================
; 背景描画ルーチン
; =====================================

	.export DrawBackgroundInit
	.export DrawBackgroundSetup
	.export DrawBackgroundUpdate
	.exportzp draw_status

	.include "nes.inc"

.segment "GAMEZP": zeropage
data_addr_L:		.byte $00		; 背景データアドレス(L)
data_addr_H:		.byte $00		; 背景データアドレス(H)
draw_count:			.byte $00		; 描画個数カウンタ
wait_frame_counter:	.byte $00		; 待機フレームカウンタ
draw_status:		.byte $00		; ステータス
command_addr:		.word $0000		; コマンドサブルーチンアドレス

.segment "DRAWBSS"
draw_background_enable:	.byte $00	; 描画するかどうか(0=しない、それ以外=する)

.code

; =====================================
; 背景描画ルーチン初期化処理
;   Reset割り込みあたりから1回だけ呼び出しておく
; =====================================
DrawBackgroundInit:
	lda #<DrawCommandTable_L
	sta command_addr
	lda #>DrawCommandTable_H
	sta command_addr+1
	rts

; =====================================
; 背景描画セットアップ
;   背景データのアドレスをA(L)、X(H)に入れておくこと
; =====================================
DrawBackgroundSetup:
	sta data_addr_L
	stx data_addr_H
	inc draw_background_enable
	rts

; =====================================
; 背景描画メイン処理
;   NMI割り込みからコールする
; =====================================
DrawBackgroundUpdate:
	lda draw_background_enable		; 描画ステータス取得
	bne @startDrawBackground		; 0じゃないので描画開始
	rts

@startDrawBackground:
	lda draw_status
	ora #%00000001					; ステータス描画中をオン
	sta draw_status

	ldy #$00

; =====================================
; 次のコマンドを取得
; =====================================
drawBgWaitCommand:
	lda wait_frame_counter			; ウェイトフレームカウンタ取得
	bne drawBgWaiting				; まだウェイト中なので何もしない
	lda (data_addr_L), y			; コマンドをロード
	tax
	lda DrawCommandTable_L, x		; コマンドに対応したルーチンのアドレスをロード
	sta command_addr
	lda DrawCommandTable_H, x
	sta command_addr+1
	jmp (command_addr)				; コマンド処理へジャンプ
drawBgWaiting:
	dec wait_frame_counter			; 描画待ちフレームカウンタ減算
	jmp endDrawBackground

; =====================================
; 描画先アドレス設定コマンド
; =====================================
_drawBgSetAddress:
	iny
	lda (data_addr_L), y
	sta PPU_VRAM_ADDR2
	iny
	lda (data_addr_L), y
	sta PPU_VRAM_ADDR2
	iny
	jmp drawBgWaitCommand

; =====================================
; 描画個数設定コマンド
; =====================================
_drawBgSetCount:
	iny
	lda (data_addr_L), y			; 個数取得
	sta draw_count					; メモリへ個数を保持
	iny
	jmp drawBgCalcAddress			; アドレス再計算

; =====================================
; 指定個数分、同一CHRを書き込み
;   個数はCMD_SET_COUNTコマンドで指定
;   続く1バイトが書き込むCHR
; =====================================
_drawBgWriteChar:
	iny
	lda (data_addr_L), y			; CHRインデックスを取得
	ldx draw_count					; 書き込む回数を取得
@drawLoop:
	sta PPU_VRAM_IO					; VRAMへ書き込み
	dex								; 個数デクリメント
	bne @drawLoop					; まだ0にならないのでループ
	iny
	jmp drawBgCalcAddress			; アドレス再計算

; =====================================
; 指定個数分、指定CHRを書き込み
; =====================================
_drawBgArray:
	iny
	lda (data_addr_L), y			; 書き込む個数を取得
	tax								; Xレジスタに保持
@drawBgArrayLoop:
	iny								; 読み込み位置更新
	lda (data_addr_L), y			; CHRインデックス取得
	sta PPU_VRAM_IO					; VRAMへ書き込み
	dex								; 個数デクリメント
	bne @drawBgArrayLoop			; まだ0にならないのでループ
	iny
	jmp drawBgCalcAddress			; アドレス再計算

; =====================================
; アドレス指定＆指定CHR書き込み
; SET_ADDRESSとWRITE_ARRAYの融合
; =====================================
_drawBgAddressAndArray:
	iny
	lda (data_addr_L), y			; 書き込み先VRAMアドレス(HIGH)取得
	sta PPU_VRAM_ADDR2				; VRAMへ通知
	iny
	lda (data_addr_L), y			; 書き込み先VRAMアドレス(LOW)取得
	sta PPU_VRAM_ADDR2				; VRAMへ通知
	jmp _drawBgArray				; データ書き込み処理へ

; =====================================
; 指定フレーム数描画スキップコマンド
; =====================================
_drawBgWaitFrame:
	iny
	lda (data_addr_L), y			; ウェイトフレーム数取得
	sta wait_frame_counter			; メモリへ保持
	iny
	jmp drawBgCalcAddress			; アドレス再計算

; =====================================
; 描画完了コマンド
; =====================================
_drawBgFinish:
	lda #$00
	sta draw_background_enable
	lda draw_status
	and #%11111110					; ステータス描画中をオフに
	sta draw_status

endDrawBackground:
	rts

; =====================================
; 次のコマンドへのアドレス再計算処理
; =====================================
drawBgCalcAddress:
	tya
	clc
	adc data_addr_L			; Y(実際はAだけどtyaしてるので) + carry(clc命令で0) + data_addr_Lを計算
	sta data_addr_L			; 算出したアドレス(LOW)を保持
	lda #$00
	adc data_addr_H			; 0 + carry(前回adcの結果) + data_addr_H
	sta data_addr_H			; 算出したアドレス(HIGH)を保持
	ldy #$00
	jmp drawBgWaitCommand	; またコマンド解析へ戻る

; =====================================
; 各描画コマンドルーチンアドレス(LOW)
; =====================================
DrawCommandTable_L:
	.byte <_drawBgFinish
	.byte <_drawBgSetAddress
	.byte <_drawBgSetCount
	.byte <_drawBgWriteChar
	.byte <_drawBgArray
	.byte <_drawBgAddressAndArray
	.byte <_drawBgWaitFrame

; =====================================
; 各描画コマンドルーチンアドレス(HIGH)
; =====================================
DrawCommandTable_H:
	.byte >_drawBgFinish
	.byte >_drawBgSetAddress
	.byte >_drawBgSetCount
	.byte >_drawBgWriteChar
	.byte >_drawBgArray
	.byte >_drawBgAddressAndArray
	.byte >_drawBgWaitFrame
