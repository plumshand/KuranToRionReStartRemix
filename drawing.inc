; =====================================
; 背景描画ルーチン
; =====================================

	.import DrawBackgroundInit
	.import DrawBackgroundSetup

	.importzp draw_status

CMD_FINISH			= $00			; 描画終了コマンド
CMD_SET_ADDRESS		= $01			; アドレス指定コマンド
CMD_SET_COUNT		= $02			; 個数指定コマンド
CMD_WRITE_CHAR		= $03			; CHARインデックス指定&描画コマンド
CMD_WRITE_ARRAY		= $04			; 指定個数分指定データ書き込み
CMD_ADDR_AND_ARRAY	= $05			; アドレス指定＆データ書き込み
CMD_WAIT_FRAME		= $06			; 指定フレーム描画スキップ

STATUS_DRAWING_MASK	= $01			; 背景描画中マスク
