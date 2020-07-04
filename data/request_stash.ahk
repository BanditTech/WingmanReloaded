#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
; SetWorkingDir %SaveDir%

Global PoESessionID := ""
, AccountNameSTR := ""
, selectedLeague := "Harvest"

IniRead, PoESessionID, %SaveDir%\Account.ini, GGG, PoESessionID, %A_Space%
; IniRead, AccountNameSTR, %SaveDir%\Account.ini, GGG, AccountNameSTR, %A_Space%

AccountNameSTR := POE_RequestAccount().accountName

curlReturn := ""
Object := POE_RequestStash(12,1)
Array_Gui(Object)
ExitApp

#Include %A_ScriptDir%/Library.ahk
