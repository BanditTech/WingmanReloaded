; Function:       IPv4 ping with name resolution, based upon 'SimplePing' by Uberi ->
; ======================================================================================================================
;                 http://www.autohotkey.com/board/topic/87742-simpleping-successor-of-ping/
; Parameters:     Addr     -  IPv4 address or host / domain name.
;                 ----------  Optional:
;                 Result   -  Object to receive the result in three keys:
;                             -  InAddr - Original value passed in parameter Addr.
;                             -  IPAddr - The replying IPv4 address.
;                             -  RTTime - The round trip time, in milliseconds.
;                 Timeout  -  The time, in milliseconds, to wait for replies.
; Return values:  On success: The round trip time, in milliseconds.
;                 On failure: "", ErrorLevel contains additional informations.
; Tested with:    AHK 1.1.22.03
; Tested on:      Win 8.1 x64
; Authors:        Uberi / just me
; Change log:     1.0.01.00/2015-07-16/just me - fixed bug on Win 8
;                 1.0.00.00/2013-11-06/just me - initial release
; MSDN:           Winsock Functions   -> http://msdn.microsoft.com/en-us/library/ms741394(v=vs.85).aspx
;                 IP Helper Functions -> hhttp://msdn.microsoft.com/en-us/library/aa366071(v=vs.85).aspx
; ======================================================================================================================
Ping4(Addr, ByRef Result := "", Timeout := 1024) {
	; ICMP status codes -> http://msdn.microsoft.com/en-us/library/aa366053(v=vs.85).aspx
	; WSA error codes  -> http://msdn.microsoft.com/en-us/library/ms740668(v=vs.85).aspx
	Static WSADATAsize := (2 * 2) + 257 + 129 + (2 * 2) + (A_PtrSize - 2) + A_PtrSize
	OrgAddr := Addr
	Result := ""
	; Initiate the use of the Winsock 2 DLL
	VarSetCapacity(WSADATA, WSADATAsize, 0)
	If (Err := DllCall("Ws2_32.dll\WSAStartup", "UShort", 0x0202, "Ptr", &WSADATA, "Int")) {
		ErrorLevel := "WSAStartup failed with error " . Err
		Return ""
	}
	If !RegExMatch(Addr, "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") { ; Addr contains a name
		If !(HOSTENT := DllCall("Ws2_32.dll\gethostbyname", "AStr", Addr, "UPtr")) {
			DllCall("Ws2_32.dll\WSACleanup") ; Terminate the use of the Winsock 2 DLL
			ErrorLevel := "gethostbyname failed with error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
			Return ""
		}
		PAddrList := NumGet(HOSTENT + 0, (2 * A_PtrSize) + 4 + (A_PtrSize - 4), "UPtr")
		PIPAddr  := NumGet(PAddrList + 0, 0, "UPtr")
		Addr := StrGet(DllCall("Ws2_32.dll\inet_ntoa", "UInt", NumGet(PIPAddr + 0, 0, "UInt"), "UPtr"), "CP0")
	}
	INADDR := DllCall("Ws2_32.dll\inet_addr", "AStr", Addr, "UInt") ; convert address to 32-bit UInt
	If (INADDR = 0xFFFFFFFF) {
		ErrorLevel := "inet_addr failed for address " . Addr
		Return ""
	}
	; Terminate the use of the Winsock 2 DLL
	DllCall("Ws2_32.dll\WSACleanup")
	HMOD := DllCall("LoadLibrary", "Str", "Iphlpapi.dll", "UPtr")
	Err := ""
	If (HPORT := DllCall("Iphlpapi.dll\IcmpCreateFile", "UPtr")) { ; open a port
		REPLYsize := 32 + 8
		VarSetCapacity(REPLY, REPLYsize, 0)
		If DllCall("Iphlpapi.dll\IcmpSendEcho", "Ptr", HPORT, "UInt", INADDR, "Ptr", 0, "UShort", 0
															, "Ptr", 0, "Ptr", &REPLY, "UInt", REPLYsize, "UInt", Timeout, "UInt") {
			Result := {}
			Result.InAddr := OrgAddr
			Result.IPAddr := StrGet(DllCall("Ws2_32.dll\inet_ntoa", "UInt", NumGet(Reply, 0, "UInt"), "UPtr"), "CP0")
			Result.RTTime := NumGet(Reply, 8, "UInt")
		}
		Else
			Err := "IcmpSendEcho failed with error " . A_LastError
		DllCall("Iphlpapi.dll\IcmpCloseHandle", "Ptr", HPORT)
	}
	Else
		Err := "IcmpCreateFile failed to open a port!"
	DllCall("FreeLibrary", "Ptr", HMOD)
	If (Err) {
		ErrorLevel := Err
		Return ""
	}
	ErrorLevel := 0
	Return Result.RTTime
}
