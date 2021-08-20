; Add simple shared functions 
Class Util {
	Static Name := "WingmanReloaded"
	; List the files within a folder
	FileList(dir,pat:="*.*"){
		Local Files := []
		Loop %dir%\%pat% {
			Files.Push(A_LoopFileName)
		}
		If Files
			Return Files
		Else
			Return False
	}
	; Simple 1d array printing
	PrintArray(Obj,showkey:=True){
		local Msg := "", k, v
		For k, v in Obj {
			Msg .= (Msg?"`n":"") (showkey? k " : " : "" )  (IsObject(v)?"{OBJECT}":v)
		}
		Return Msg
	}
	; Retreive HWND of a process
	HwndOfPID(pid){
		local hWnd
		DetectHiddenWindows, On
		WinGet, hWnd, ID, % "ahk_pid " pid
		DetectHiddenWindows, Off
		return hWnd
	}
	; JSON wrapper for loading files
	Load(File){
		local t, f, fStr, _JSON
		Try {
			If File {
				If (File ~= "^\w:\\.+\.json$") { ; This File is a Full Path
					fStr := File
				} Else If !(File ~= "^\w:\\") && (File ~= ".+\.json$") { ; This File is a Filename
					If !FileExist(This.Dir.save "\" File)
						fStr := This.Dir.data "\" File
					Else
						fStr := This.Dir.save "\" File
				} Else If !(File ~= ".+\.json$") { ; This File is a File Label
					If !FileExist(This.Dir.save "\" File ".json")
						fStr := This.Dir.data "\" File ".json"
					Else
						fStr := This.Dir.save "\" File ".json"
				}
				If (FileExist(fStr)) {
					f := FileOpen(fStr,"r")
					This.Log.Msg("Verbose","Loading settings from " File, fStr )
				} Else
					This.Log.Msg("Error","Issue properly locating " File, fStr )
			}
			If f {
				_JSON := JSON.Load(f.Read())
				If IsObject(_JSON)
					Return _JSON
				Else
					Return "00" ; Loading File Failed
			} Else
				Return "0" ; No File Object
		} Catch e {
			This.Err(e, "Failed during JSON Load:", "fileParam: " File, "fStr: " fStr, "fLoaded: " (IsObject(f) ? "True" : "False" ))
		}
	}
	; JSON wrapper for saving files
	Save(File,Object){
		local t, f, fStr, _JSON
		Try {
			If !FileExist(This.Dir.save "\"){
				FileCreateDir, % This.Dir.save
			}
			If File {
				If (File ~= "^\w:\\.+\.json$") { ; This File is a Full Path
					fStr := File
				} Else If !(File ~= "^\w:\\") && (File ~= ".+\.json$") { ; This File is a Filename
					fStr := This.Dir.save "\" File
				} Else If !(File ~= ".+\.json$") { ; This File is a File Label
					fStr := This.Dir.save "\" File ".json"
				}
				f := FileOpen(fStr,"w")
			} Else
				Return "00" ; No File Reference
			If f {
				f.Write(JSON.Dump(Object,,2))
				f.close()
				Return True
			} Else
				Return "0" ; File object not loaded
		} Catch e {
			This.Err( e, "Failed during JSON Save:", "fileParam: " File, "fStr: " fStr, "fLoaded: " (IsObject(f) ? "True" : "False" ) )
		}
	}
	; Simple JSON string dump
	JString(Object){
		Try {
			Return JSON.Dump(Object,,2)
		} Catch e {
			This.Err( e )
		}
	}
	; Error report for standard error message
	Err(e,t*){
		local l, k, v
		For k, v in t
			If IsObject(v)
				l := t.RemoveAt(k)
		If !IsObject(l)
			l := []
		For k, v in t
			l.Push(v)
		l.Push("Error Report:")
		For k, v in ["what","file","line","message","extra"]
			l.Push(v ": " e[v])
		This.Log.Msg("Error ", l)
		If This.Debug.ErrorMsgBox
			MsgBox,% 4096+16, %A_ScriptName%,% This.PrintArray(l,False)
		Return l
	}
	HttpGet(url){
		Try {
			whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			whr.Open("GET", url, true)
			whr.Send()
			; Using 'true' above and the call below allows the script to remain responsive.
			whr.WaitForResponse()
			response := whr.ResponseText
			Return response
		} catch e {
			This.Err(e,"Download failed for " url)
		}
	}
	; Allow child process to terminate script
	Quit() {
		This.Log.Msg("Quit Was Called")
		If This.Debug.AllowQuit {
			DetectHiddenWindows On  ; WM_CLOSE=0x10
			PostMessage 0x10,,,, ahk_id %A_ScriptHwnd%
		} ; Now return, so the client's call to Quit() succeeds.
	}
	; Store our directories for simple calls to files
	Class Dir {
		Static lib := A_ScriptDir "\lib"
		Static data := A_ScriptDir "\data"
		Static save := A_ScriptDir "\save"
		Static media := A_ScriptDir "\media"
		Static temp := A_ScriptDir "\temp"
		Static logs := A_ScriptDir "\logs"
	}
	; Debugging settings
	Class Debug {
		Static Log := True
		Static Verbose := False
		Static UberVerbose := False
		Static LogNum := 0
		Static Timers := 1
		Static AllowQuit := 0
		Static Kill := 1
		Static SpecifyUser := "limited"
		Static ColorGlobes := 0
		Static ErrorMsgBox := 1
	}

	; Create a rotating log file
	Class Log extends Util {
		Static Limit := 10
		Static ActiveFile := ""
		Open(){
			local loglist, filename, TimeString
			If !FileExist(This.Dir.logs "\"){
				FileCreateDir, % This.Dir.logs
			}
			This.Log.ActiveFile := This.Dir.logs "\" This.Name " " A_Now ".log"
			This.Log.File := FileOpen(This.Log.ActiveFile,"w")
			This.Log.File.Close()
			loglist := This.FileList(This.Dir.logs, This.Name " ??????????????.log")
			If (loglist.Count() > This.Log.Limit && This.Log.Limit)
			{
				While (loglist.Count() > This.Log.Limit) {
					FileDelete,% This.Dir.logs "\" loglist.RemoveAt(1)
				}
			}
			FormatTime, TimeString, T12, Time
			FormatTime, TimeString, A_Now, yyyy/MM/d
			This.Log.Msg(This.Name " Log ", TimeString
			, "Script Version " VersionNumber
			, "AHK v" A_AhkVersion " " (A_IsUnicode ? "Unicode" : "ANSI") " " (A_PtrSize = 4 ? 32 : 64) "-b"
			, "AHK " A_AhkPath
			, "OS " (A_OSVersion ~= "^WIN_" ? A_OSVersion : A_OSVersion >= 10 ? "WIN_"A_OSVersion : "Unknown OS " A_OSVersion) (A_Is64bitOS?" 64-b":" 32-b")
			, "Screen W" A_ScreenWidth " H" A_ScreenHeight
			, "Screen DPI " Round(( A_ScreenDPI / 96 ) * 100) "% (" A_ScreenDPI " DPI)" ) 
		}
		Msg(t*){
			local flag := "", k, v, File, line := ""
			If (t.1 ~= "Verbose" && !This.Debug.Verbose)
				Return
			Else If (t.1 ~= "^\w+$" || t.1 ~= ".+ $")
				flag := Rtrim(t.RemoveAt(1))
			If !(flag ~= "[eE]rror") && !This.Debug.Log
				Return False
			If !This.Log.ActiveFile
				This.Log.Open()
			File := FileOpen(This.Log.ActiveFile,"a")
			If t.1.Count()
				t := t.1
			For k, v in t {
				line .= A_Hour ":" A_Min ":" A_Sec (k=1 ? (flag?" " flag ": " : " ") : "`t") v "`n"
			}
			File.WriteLine( line )
			; updateLogViewer( line )
			; File.WriteLine("")
			File.Close()
		}
		Close(t*){
			If t.Count()
				This.Log.Msg(t*)
			This.Log.Msg(This.Name " Log ","End of File")
			This.Log.ActiveFile := ""
		}
	}
}

; Log file function
Log(var*) 
{
	Util.Log.Msg(var*)
	return
}
