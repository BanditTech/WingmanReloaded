SendMSG(wParam:=0, lParam:=0, script:="BlankSubscript.ahk ahk_exe AutoHotkey.exe"){
	DetectHiddenWindows(1)
	if WinExist(script)
		PostMessage(0x5555, wParam, lParam)
	DetectHiddenWindows(0)  ; Must not be turned off until after PostMessage.
	Return
}

MsgMonitor(wParam, lParam, msg, hwnd) {
	If (wParam==1)
		LoadArray()
	Return
}
