Global VersionNumber := .15.32
#Include, %A_ScriptDir%\lib\Header.ahk
#Include, %A_ScriptDir%\lib\RunAdmin.ahk
#Include, %A_ScriptDir%\lib\FileCheck.ahk
#Include, %A_ScriptDir%\lib\TrayMenu.ahk
#Include, %A_ScriptDir%\lib\ScriptObject.ahk
#Include, %A_ScriptDir%\lib\GLOBALS.ahk
readFromFile()
CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript")
checkUpdate()
Critical
#Include, %A_ScriptDir%\lib\gui\MainMenu.ahk
#Include, %A_ScriptDir%\lib\gui\ItemInfo.ahk
FirstScale()
RestockMenu("Load")
If (YesNinjaDatabase && DaysSince()) {
  DBUpdateNinja()
} Else {
  Ninja := JSON.Load(FileOpen(A_ScriptDir "\data\Ninja.json","r").Read())
}
;CraftingBasesRequest(YesCraftingBaseAutoUpdateOnStart)
Critical, Off
Tooltip,

#Include, %A_ScriptDir%\lib\gui\IngameOverlay.ahk
If (ShowOnStart)
  MainMenu()
If (YesChaosOverlay){
  RefreshChaosRecipe()
}

#Include, %A_ScriptDir%\lib\Timers.ahk
#Include *i %A_ScriptDir%\save\MyCustomAutoRun.ahk
; Hotkeys to reload or exit script - Hardcoded Hotkeys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#IfWinActive
; Return
!+^L::Array_Gui(Item)
; Reload Script with Alt+Escape
!Escape::Reload
; Exit Script with Win+Escape
#Escape::ExitApp
#IfWinActive, ahk_group POEGameGroup
  ; ------------------------------------------------End of AutoExecute Section-----------------------------------------------------------------------------------------------------------
  Return

  #Include, %A_ScriptDir%\lib\Library.ahk
