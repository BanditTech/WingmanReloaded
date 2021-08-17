/*** Lib from LutBot : Extracted from lite version
* Lib: LutBotLite.ahk
*   Path of Exile Quick disconnect.
*/

; Main function of the LutBot logout method
logout(executable){
	; global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi

	; Setup for LutBot logout method
	; Static full_command_line := DllCall("GetCommandLine", "str")
	Static GetTable := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "GetExtendedTcpTable", "Ptr")
	Static SetEntry := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "SetTcpEntry", "Ptr")
	Static EnumProcesses := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Psapi.dll", "Ptr"), Astr, "EnumProcesses", "Ptr")
	; Static preloadPsapi := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")
	Static OpenProcessToken := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "OpenProcessToken", "Ptr")
	Static LookupPrivilegeValue := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "LookupPrivilegeValue", "Ptr")
	Static AdjustTokenPrivileges := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "AdjustTokenPrivileges", "Ptr")

	Thread, NoTimers, true    ;Critical
	start := A_TickCount
	
	poePID := Object()
	s := 4096
	Process, Exist 
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
	
	DllCall(OpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)
	NumPut(1, ti, 0, "UInt")
	
	DllCall(LookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")
	
	r := DllCall(AdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)
	DllCall("CloseHandle", "Ptr", h)
	
	try	{
		s := VarSetCapacity(a, s)
		c := 0
		DllCall(EnumProcesses, "Ptr", &a, "UInt", s, "UIntP", r)
		Loop, % r // 4
		{
			id := NumGet(a, A_Index* 4, "UInt")
			
			h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
			
			if !h
				continue
			VarSetCapacity(n, s, 0)
			e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
			if !e 
				if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
				SplitPath n, n
			DllCall("CloseHandle", "Ptr", h)
			if (n && e)
			if (n == executable) {
				poePID.Insert(id)
			}
		}
		
		l := poePID.Length()
		if ( l = 0 ) {
			Process, wait, %executable%, 0.2
			if ( ErrorLevel > 0 ) {
				poePID.Insert(ErrorLevel)
			}
		}
		
		VarSetCapacity(dwSize, 4, 0) 
		result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
		VarSetCapacity(TcpTable, NumGet(dwSize), 0) 
		
		result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
		
		tcpNum := NumGet(&TcpTable,0,"UInt")
		
		IfEqual, tcpNum, 0
		{
			Log("Logout","ED11",tcpNum,l,executable)
			return False
		}
		
		out := 0
		Loop %tcpNum%
		{
			cutby := a_index - 1
			cutby*= 24
			ownerPID := NumGet(&TcpTable,cutby+24,"UInt")
			for index, element in poePID {
				if ( ownerPID = element )
				{
					VarSetCapacity(newEntry, 20, 0) 
					NumPut(12,&newEntry,0,"UInt")
					NumPut(NumGet(&TcpTable,cutby+8,"UInt"),&newEntry,4,"UInt")
					NumPut(NumGet(&TcpTable,cutby+12,"UInt"),&newEntry,8,"UInt")
					NumPut(NumGet(&TcpTable,cutby+16,"UInt"),&newEntry,12,"UInt")
					NumPut(NumGet(&TcpTable,cutby+20,"UInt"),&newEntry,16,"UInt")
					result := DllCall(SetEntry, UInt, &newEntry)
					IfNotEqual, result, 0
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
	} catch e	{
		Log("Logout","ED14","catcherror",ErrorText(e))
		return False
	}
	
	return True
}


; checkActiveType - Check for active executable
checkActiveType() 
{
	global Active_executable, GameStr
	Process, Exist, %Active_executable%
	if !ErrorLevel
	{
		WinGet, id, list,ahk_group POEGameGroup,, Program Manager
		Loop, %id%
		{
			this_id := id%A_Index%
			WinGet, this_name, ProcessName, ahk_id %this_id%
			Active_executable := this_name
			GameStr := "ahk_exe " Active_executable
			Return True
		}
		Return False
	}
	Else
		Return True
}
