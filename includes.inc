
	.setcpu "6502"

; =====================================
; IMPORT ZEROPAGE VARILABLES
; =====================================
	.importzp SceneNo, SubStatus
	.importzp JumpAddrLow, JumpAddrHigh
	.importzp SubJumpAddrLow, SubJumpAddrHigh

; =====================================
; IMPORT BSS VARILABLES
; =====================================
	.import PpuControl1, PpuControl2

; =====================================
; IMPORT MAIN ROUTINE END (main.s)
; =====================================
	.import MainEnd

; =====================================
; IMPORT SUB ROUTINE (main.s)
; =====================================
	.import NextScene, NextSubStatus
	.import ShowSprites, HideSprites

; =====================================
; CHARACTER DEFINITIONS
; =====================================
	.import Kuran1, Kuran2, Kuran3, Kuran4
	.import Rion1, Rion2, Rion3, Rion4
.define __kuran1_ypos		Kuran1+Sprite::ypos
.define __kuran2_ypos		Kuran2+Sprite::ypos
.define __kuran3_ypos		Kuran3+Sprite::ypos
.define __kuran4_ypos		Kuran4+Sprite::ypos
.define __kuran1_xpos		Kuran1+Sprite::xpos
.define __kuran2_xpos		Kuran2+Sprite::xpos
.define __kuran3_xpos		Kuran3+Sprite::xpos
.define __kuran4_xpos		Kuran4+Sprite::xpos
.define __kuran1_attr		Kuran1+Sprite::attr
.define __kuran2_attr		Kuran2+Sprite::attr
.define __kuran3_attr		Kuran3+Sprite::attr
.define __kuran4_attr		Kuran4+Sprite::attr
.define __kuran1_char		Kuran1+Sprite::char
.define __kuran2_char		Kuran2+Sprite::char
.define __kuran3_char		Kuran3+Sprite::char
.define __kuran4_char		Kuran4+Sprite::char

.define __rion1_ypos		Rion1+Sprite::ypos
.define __rion2_ypos		Rion2+Sprite::ypos
.define __rion3_ypos		Rion3+Sprite::ypos
.define __rion4_ypos		Rion4+Sprite::ypos
.define __rion1_xpos		Rion1+Sprite::xpos
.define __rion2_xpos		Rion2+Sprite::xpos
.define __rion3_xpos		Rion3+Sprite::xpos
.define __rion4_xpos		Rion4+Sprite::xpos
.define __rion1_attr		Rion1+Sprite::attr
.define __rion2_attr		Rion2+Sprite::attr
.define __rion3_attr		Rion3+Sprite::attr
.define __rion4_attr		Rion4+Sprite::attr
.define __rion1_char		Rion1+Sprite::char
.define __rion2_char		Rion2+Sprite::char
.define __rion3_char		Rion3+Sprite::char
.define __rion4_char		Rion4+Sprite::char
