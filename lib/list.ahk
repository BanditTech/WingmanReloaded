; Third-party library includes
; Packages managed by Aris (https://github.com/Descolada/Aris) live under lib\Aris\
; All libs below have been ported to AHK v2

; --- Aris-managed packages ---
; Suppress LocalSameAsGlobal while loading third-party libs that may shadow globals.
#Warn LocalSameAsGlobal, Off
#Include %A_ScriptDir%\lib\Aris\packages.ahk
#Warn LocalSameAsGlobal, MsgBox

; --- Ported third-party libs (lib\ref) ---
#Include %A_ScriptDir%\lib\ref\XGraph.ahk
#Include %A_ScriptDir%\lib\ref\RadialMenu.ahk
#Include %A_ScriptDir%\lib\ref\Class_CtlColors.ahk
#Include %A_ScriptDir%\lib\ref\LutBotLite.ahk
#Include %A_ScriptDir%\lib\ref\LetUserSelectRect.ahk
#Include %A_ScriptDir%\lib\ref\ColorRange.ahk
