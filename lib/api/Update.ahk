checkUpdate(force:=False){
	Global BranchName
	If (!AutoUpdateOff || force)
	{
		Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/version.html", A_ScriptDir "\temp\version.html")
		newestVersion := FileOpen(A_ScriptDir "\temp\version.html","r").Read()
		If InStr(newestVersion, ":")
		{
			Log("Error","There was an issue when attempting to download the version file",newestVersion)
			Return
		}
		If RegExMatch(newestVersion, "[.0-9]+", &matchVersion)
			newestVersion := matchVersion[]
		if ( VersionNumber < newestVersion || force)
		{
			Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/changelog.txt", A_ScriptDir "\temp\changelog.txt")
			changelog := FileOpen(A_ScriptDir "\temp\changelog.txt","r").Read()
			UpdateGui := Gui()
			UpdateGui.Opt("+AlwaysOnTop")
			UpdateGui.Add("Button", "x0 y0 h1 w1", "a")
			UpdateGui.Add("Text",, "Update Available.`nYoure running version " VersionNumber ". The newest is version " newestVersion "`n")
			UpdateGui.Add("Edit", "w600 h200 +ReadOnly", changelog)
			btnUpdate := UpdateGui.Add("Button", "x70 section default", "Update to the Newest Version!")
			btnUpdate.OnEvent("Click", runUpdate)
			btnDonate := UpdateGui.Add("Button", "x+35 ys", "Support the Project")
			btnDonate.OnEvent("Click", LaunchDonate)
			btnDontUpdate := UpdateGui.Add("Button", "x+35 ys", "Turn off Auto-Update")
			btnDontUpdate.OnEvent("Click", dontUpdate)
			UpdateGui.OnEvent("Close", UpdateGuiClose)
			UpdateGui.OnEvent("Escape", UpdateGuiClose)
			UpdateGui.Show(, "WingmanReloaded Update")
			if WinExist("WingmanReloaded Update ahk_exe AutoHotkey.exe")
			{
				WinWaitClose()
			}
		}
	}
	Return

	UpdateGuiClose(*) {
		UpdateGui.Destroy()
		Return
	}
	runUpdate(*) {
		Fail:=False
		Log("Update","Running")
		SevenZip.install(BranchName)
		Run("`"" A_ScriptFullPath "`"")
		Sleep(5000) ;This shouldn't ever hit.
		Log("Error","There was an issue with the update")
		Return
	}
	dontUpdate(*) {
		IniWrite(1, A_ScriptDir "\save\Settings.ini", "General", "AutoUpdateOff")
		MsgBox("Auto-Updates have been disabled.`nCheck back on the forum for more information!`nTo resume updates, uncheck the box in config page.")
		UpdateGui.Destroy()
		return
	}
}

; DaysSince - Check how many days has it been since the last update
DaysSince()
{
  Global LastDatabaseParseDate, UpdateDatabaseInterval
  Date_now := FormatTime(A_Now, "yyyyMMdd")
  If (Date_now == LastDatabaseParseDate) ;
    Return False
  daysCount := DateDiff(Date_now, LastDatabaseParseDate, "Days")
  If (daysCount == "")
  {
    ;the value is too large of a dif to calculate, this means we should update
    Return True
  }
  Else If (daysCount >= UpdateDatabaseInterval)
  {
    ;The Count between the two dates is at/above the threshold, this means we should update
    Return daysCount
  }
  Else
  {
    ;The Count between the two dates is below the threshold, this means we should not
    Return False
  }
}
