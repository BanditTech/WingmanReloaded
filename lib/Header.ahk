#IfWinActive Path of Exile 
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
#Warn UseEnv 
#Persistent 
#InstallMouseHook
#InstallKeybdHook
#MaxThreadsPerHotkey 2
#MaxMem 256

ListLines Off
SetBatchLines, -1

; Load default delays values from INI
IniRead, SetKeyDelayValue1, %A_ScriptDir%\save\Settings.ini, Delays, SetKeyDelayValue1, 15
IniRead, SetKeyDelayValue2, %A_ScriptDir%\save\Settings.ini, Delays, SetKeyDelayValue2, 0
IniRead, SetMouseDelayValue, %A_ScriptDir%\save\Settings.ini, Delays, SetMouseDelayValue, 15
IniRead, SetDefaultMouseSpeedValue, %A_ScriptDir%\save\Settings.ini, Delays, SetDefaultMouseSpeedValue, 1
IniRead, SetWinDelayValue, %A_ScriptDir%\save\Settings.ini, Delays, SetWinDelayValue, -1
IniRead, SetControlDelayValue, %A_ScriptDir%\save\Settings.ini, Delays, SetControlDelayValue, 15

; Set default delays
SetKeyDelay, %SetKeyDelayValue1%, %SetKeyDelayValue2%
SetMouseDelay, %SetMouseDelayValue%
SetDefaultMouseSpeed, %SetDefaultMouseSpeedValue%
SetWinDelay, %SetWinDelayValue%
SetControlDelay, %SetControlDelayValue%

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, Tooltip, Screen
FileEncoding , UTF-8
SendMode Input
StringCaseSense, On ; Match strings with case.
If A_AhkVersion < 1.1.28
{
	Log("Error","Too Low version")
	msgbox 1, ,% "Version " A_AhkVersion " AutoHotkey has been found`nThe script requires minimum version 1.1.28+`nPress OK to go to download page"
	IfMsgBox, OK
	{
		Run, "https://www.autohotkey.com/download/"
		ExitApp
	}
	Else 
		ExitApp
}

SetTitleMatchMode 2
SetWorkingDir %A_ScriptDir%  
Thread, interrupt, 0
I_Icon = %A_ScriptDir%\data\WR.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%

OnMessage(0x5555, "MsgMonitor")
OnMessage( 0xF, "WM_PAINT")
OnMessage(0x200, Func("ShowToolTip"))  ; WM_MOUSEMOVE
