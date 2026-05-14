; Third-party library includes
; Packages managed by Aris (https://github.com/Descolada/Aris) live under lib\Aris\
; All libs below have been ported to AHK v2

; Suppress LocalSameAsGlobal for third-party libraries only.
; These libs may use variable names that shadow our globals; we can't modify them.
#Warn LocalSameAsGlobal, Off

; --- Aris-managed packages ---
#Include %A_ScriptDir%\lib\Aris\packages.ahk

; --- Ported third-party libs (lib\ref) ---
#Include %A_ScriptDir%\lib\ref\XGraph.ahk
#Include %A_ScriptDir%\lib\ref\RadialMenu.ahk
#Include %A_ScriptDir%\lib\ref\Class_CtlColors.ahk
#Include %A_ScriptDir%\lib\ref\LutBotLite.ahk
#Include %A_ScriptDir%\lib\ref\LetUserSelectRect.ahk
#Include %A_ScriptDir%\lib\ref\ColorRange.ahk

; Re-enable LocalSameAsGlobal for our own code included after this point.
#Warn LocalSameAsGlobal, On
