DynaRun(script, name:="", args*) { ;// http://goo.gl/ECC6Qw
	if (name == "")
		name := "AHK_" . A_TickCount
	;// Create named pipe(s), first one is a dummy
	for each, pipe in ["__PIPE_GA_", "__PIPE_"]
		%pipe% := DllCall(
		(Join Q C
			"CreateNamedPipe",      ;// http://goo.gl/3aJQg7
			"Str", "\\.\pipe\" . name,  ;// lpName
			"UInt", 2,          ;// dwOpenMode = PIPE_ACCESS_OUTBOUND
			"UInt", 0,          ;// dwPipeMode = PIPE_TYPE_BYTE
			"UInt", 255,        ;// nMaxInstances
			"UInt", 0,          ;// nOutBufferSize
			"UInt", 0,          ;// nInBufferSize
			"Ptr", 0,           ;// nDefaultTimeOut
			"Ptr", 0          ;// lpSecurityAttributes
		))
	
	if (__PIPE_ == -1 || __PIPE_GA_ == -1)
		return false
	
	q := Chr(34) ;// for v1.1 and v2.0-a compatibility
	for each, arg in args
		args .= " " . q . arg . q
	Run "%A_AhkPath%" "\\.\pipe\%name%" %args%,, UseErrorLevel Hide, PID
	if ErrorLevel
		MsgBox, 262144, ERROR, Could not open file:`n%A_AhkPath%\\.\pipe\%name%
	
	DllCall("ConnectNamedPipe", "Ptr", __PIPE_GA_, "Ptr", 0) ;// http://goo.gl/pwTnxj
	DllCall("CloseHandle", "Ptr", __PIPE_GA_)
	DllCall("ConnectNamedPipe", "Ptr", __PIPE_, "Ptr", 0)
	
	script := (A_IsUnicode ? Chr(0xfeff) : (Chr(239) . Chr(187) . Chr(191))) . script
	if !DllCall(
	(Join Q C
		"WriteFile",                ;// http://goo.gl/fdyWm0
		"Ptr", __PIPE_,               ;// hFile
		"Str", script,                ;// lpBuffer
		"UInt", (StrLen(script)+1)*(A_IsUnicode+1), ;// nNumberOfBytesToWrite
		"UInt*", 0,                 ;// lpNumberOfBytesWritten
		"Ptr", 0                  ;// lpOverlapped
	))
		return A_LastError
	/* FileOpen() version
	if !(f := FileOpen(__PIPE_, "h", A_IsUnicode ? "UTF-8" : ""))
		return A_LastError
	f.Write(script), f.Close() ;// .Close() -> Redundant, no effect
	*/
	DllCall("CloseHandle", "Ptr", __PIPE_)
	
	return PID
}
