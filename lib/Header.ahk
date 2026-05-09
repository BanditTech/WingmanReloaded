#HotIf WinActive("Path of Exile ")
A_MaxHotkeysPerInterval := 99000000
A_HotkeyInterval := 99000000
KeyHistory(0)
#SingleInstance force
#Warn
#MaxThreadsPerHotkey 2

ListLines(0)

; Load default delays values from INI
SetKeyDelayValue1 := IniRead(A_ScriptDir "\save\Settings.ini", "Delays", "SetKeyDelayValue1", 60)
SetKeyDelayValue2 := IniRead(A_ScriptDir "\save\Settings.ini", "Delays", "SetKeyDelayValue2", 90)
SetMouseDelayValue := IniRead(A_ScriptDir "\save\Settings.ini", "Delays", "SetMouseDelayValue", 90)
SetDefaultMouseSpeedValue := IniRead(A_ScriptDir "\save\Settings.ini", "Delays", "SetDefaultMouseSpeedValue", 5)

; Set default delays
SetKeyDelay(SetKeyDelayValue1, SetKeyDelayValue2, "Play")
SetMouseDelay(SetMouseDelayValue)
SetDefaultMouseSpeed(SetDefaultMouseSpeedValue)

CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
CoordMode("Tooltip", "Screen")
FileEncoding("UTF-8")
SendMode("Input")
StringCaseSense("On") ; Match strings with case.

SetTitleMatchMode(2)
SetWorkingDir(A_ScriptDir)
Thread("interrupt", 0)
I_Icon := A_ScriptDir "\data\WR.ico"
if FileExist(I_Icon)
  TraySetIcon(I_Icon)

OnMessage(0x5555, MsgMonitor)
OnMessage( 0xF, WM_PAINT)
OnMessage(0x200, ShowToolTip)  ; WM_MOUSEMOVE
