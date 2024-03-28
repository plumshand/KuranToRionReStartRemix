; =======================
; Variables
; =======================

	.include "structs.inc"

.segment "GAMEZP": zeropage
SceneNo:		.byte $00		; シーン番号
SubStatus:		.byte $00		; シーン内サブステータス番号
JumpAddrLow:	.byte $00		; メインシーンジャンプアドレス(LOW)
JumpAddrHigh:	.byte $00		; メインシーンジャンプアドレス(HIGH)
SubJumpAddrLow:	.byte $00		; サブステータスジャンプアドレス(LOW)
SubJumpAddrHigh:.byte $00		; サブステータスジャンプアドレス(HIGH)
	.exportzp SceneNo, SubStatus
	.exportzp JumpAddrLow, JumpAddrHigh
	.exportzp SubJumpAddrLow, SubJumpAddrHigh

.segment "GAMEBSS"
PpuControl1:	.byte $00		; PPU制御レジスタ1保持
PpuControl2:	.byte $00		; PPU制御レジスタ2保持
	.export PpuControl1, PpuControl2

.segment "CHARDMA"
Kuran1:			.tag Sprite		; クラン(左上)
Kuran2:			.tag Sprite		; クラン(右上)
Kuran3:			.tag Sprite		; クラン(左下)
Kuran4:			.tag Sprite		; クラン(右下)
Rion1:			.tag Sprite		; リオン(左上)
Rion2:			.tag Sprite		; リオン(右上)
Rion3:			.tag Sprite		; リオン(左下)
Rion4:			.tag Sprite		; リオン(右下)
	.export Kuran1, Kuran2, Kuran3, Kuran4
	.export Rion1, Rion2, Rion3, Rion4
