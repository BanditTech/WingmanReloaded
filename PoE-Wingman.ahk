#Requires AutoHotkey v2.0
Global VersionNumber := "3.0.0"
#Include %A_ScriptDir%\lib\Header.ahk
#Include %A_ScriptDir%\lib\RunAdmin.ahk
#Include %A_ScriptDir%\lib\FileCheck.ahk
#Include %A_ScriptDir%\lib\TrayMenu.ahk
#Include %A_ScriptDir%\lib\ScriptObject.ahk
#Include %A_ScriptDir%\lib\GLOBALS.ahk
readFromFile()
CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript")
checkUpdate()
Critical(1)
#Include %A_ScriptDir%\lib\gui\MainMenu.ahk
#Include %A_ScriptDir%\lib\gui\ItemInfo.ahk
FirstScale()
RestockMenu("Load")
If (YesNinjaDatabase && DaysSince()) {
  DBUpdateNinja()
} Else {
  Ninja := JSON.LoadFile(A_ScriptDir "\data\Ninja.json")
}
;CraftingBasesRequest(YesCraftingBaseAutoUpdateOnStart)
Critical(0)
ToolTip()

#Include %A_ScriptDir%\lib\gui\IngameOverlay.ahk
If (ShowOnStart)
  MainMenu()
If (YesChaosOverlay){
  RefreshChaosRecipe()
}

#Include %A_ScriptDir%\lib\Timers.ahk
#Include *i %A_ScriptDir%\save\MyCustomAutoRun.ahk
; Hotkeys to reload or exit script - Hardcoded Hotkeys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#HotIf
; Return
!+^L::MsgBoxVals(Item)
; Reload Script with Alt+Escape
!Escape:: {
  BlockInput("MouseMoveOff")
  Reload()
}
; Exit Script with Win+Escape
#Escape:: {
  BlockInput("MouseMoveOff")
  ExitApp()
}
#HotIf WinActive("ahk_group POEGameGroup")
  #Include %A_ScriptDir%\lib\Library.ahk
  ; ------------------------------------------------End of AutoExecute Section-----------------------------------------------------------------------------------------------------------
  Return
