/*** Lib from LutBot : Extracted from lite version
* Lib: LutBotLite.ahk
*   Path of Exile Quick disconnect.
*/

; Main function of the LutBot logout method
logout(executable){
	; global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi

	; Setup for LutBot logout method
	; Static full_command_line := DllCall("GetCommandLine", "str")
	Static pfnGetTable := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Iphlpapi.dll", "Ptr"), "AStr", "GetExtendedTcpTable", "Ptr")
	Static pfnSetEntry := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Iphlpapi.dll", "Ptr"), "AStr", "SetTcpEntry", "Ptr")
	Static pfnEnumProcesses := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr"), "AStr", "EnumProcesses", "Ptr")
	; Static preloadPsapi := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")
	Static pfnOpenProcessToken := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Advapi32.dll", "Ptr"), "AStr", "OpenProcessToken", "Ptr")
	Static pfnLookupPrivilegeValue := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Advapi32.dll", "Ptr"), "AStr", "LookupPrivilegeValue", "Ptr")
	Static pfnAdjustTokenPrivileges := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Advapi32.dll", "Ptr"), "AStr", "AdjustTokenPrivileges", "Ptr")

	Thread("NoTimers", true)    ;Critical
	start := A_TickCount

	poePID := []
	s := 4096
	selfPID := DllCall("GetCurrentProcessId", "UInt")
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", selfPID, "Ptr")

	t := 0
	DllCall(pfnOpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", &t)
	ti := Buffer(16, 0)
	NumPut("UInt", 1, ti, 0)

	luid := 0
	DllCall(pfnLookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", &luid)
	NumPut("Int64", luid, ti, 4)
	NumPut("UInt", 2, ti, 12)

	r := DllCall(pfnAdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)
	DllCall("CloseHandle", "Ptr", h)

	try	{
		a := Buffer(s, 0)
		c := 0
		DllCall(pfnEnumProcesses, "Ptr", a, "UInt", s, "UIntP", &r)
		Loop r // 4
		{
			id := NumGet(a, A_Index * 4, "UInt")

			h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")

			if !h
				continue
			n := Buffer(s, 0)
			e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Ptr", n, "UInt", s // 2)
			nStr := ""
			if !e {
				if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Ptr", n, "UInt", s // 2)
					SplitPath(StrGet(n), &nStr)
			} else {
				nStr := StrGet(n)
			}
			DllCall("CloseHandle", "Ptr", h)
			if (nStr && e)
			if (nStr == executable) {
				poePID.Push(id)
			}
		}

		l := poePID.Length
		if ( l = 0 ) {
			pid := ProcessWait(executable, 0.2)
			if pid > 0 {
				poePID.Push(pid)
			}
		}

		dwSize := Buffer(4, 0)
		result := DllCall(pfnGetTable, "UInt", 0, "UInt", dwSize, "UInt", 0, "UInt", 2, "UInt", 5, "UInt", 0)
		TcpTable := Buffer(NumGet(dwSize, 0, "UInt"), 0)

		result := DllCall(pfnGetTable, "Ptr", TcpTable, "Ptr", dwSize, "UInt", 0, "UInt", 2, "UInt", 5, "UInt", 0)

		tcpNum := NumGet(TcpTable, 0, "UInt")

		if tcpNum = 0
		{
			Log("Logout","ED11",tcpNum,l,executable)
			return False
		}

		out := 0
		Loop tcpNum
		{
			cutby := A_Index - 1
			cutby *= 24
			ownerPID := NumGet(TcpTable, cutby+24, "UInt")
			for index, element in poePID {
				if ( ownerPID = element )
				{
					newEntry := Buffer(20, 0)
					NumPut("UInt", 12, newEntry, 0)
					NumPut("UInt", NumGet(TcpTable, cutby+8, "UInt"), newEntry, 4)
					NumPut("UInt", NumGet(TcpTable, cutby+12, "UInt"), newEntry, 8)
					NumPut("UInt", NumGet(TcpTable, cutby+16, "UInt"), newEntry, 12)
					NumPut("UInt", NumGet(TcpTable, cutby+20, "UInt"), newEntry, 16)
					result := DllCall(pfnSetEntry, "Ptr", newEntry)
					if result != 0
					{
						Log("Logout","TCP" . result,out,result,l,executable)
						return False
					}
					out++
				}
			}
		}
		if ( out = 0 ) {
			Log("Logout","ED10",out,l,executable)
			return False
		} else {
			Log("Logout",l . ":" . A_TickCount - start,out,l,executable)
		}
	} catch Error as e	{
		Log("Logout","ED14","catcherror",ErrorText(e))
		return False
	}

	return True
}


; checkActiveType - Check for active executable
checkActiveType()
{
	global Active_executable, GameStr
	if !ProcessExist(Active_executable)
	{
		id := WinGetList("ahk_group POEGameGroup",, "Program Manager")
		for hwnd in id
		{
			this_id := hwnd
			this_name := WinGetProcessName("ahk_id " this_id)
			Active_executable := this_name
			GameStr := "ahk_exe " Active_executable
			Return True
		}
		Return False
	}
	Else
		Return True
}
