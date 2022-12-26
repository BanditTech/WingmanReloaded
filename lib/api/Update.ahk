checkUpdate(force:=False){
	Global BranchName
	If (!AutoUpdateOff || force) 
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/version.html, %A_ScriptDir%\temp\version.html
		newestVersion := FileOpen(A_ScriptDir "\temp\version.html","r").Read()
		If InStr(newestVersion, ":")
		{
			Log("Error","There was an issue when attempting to download the version file",newestVersion)
			Return
		}
		If RegExMatch(newestVersion, "[.0-9]+", matchVersion)
			newestVersion := matchVersion
		if ( VersionNumber < newestVersion || force) 
		{
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/changelog.txt, %A_ScriptDir%\temp\changelog.txt
			changelog := FileOpen(A_ScriptDir "\temp\changelog.txt","r").Read()
			Gui, Update: +AlwaysOnTop
			Gui, Update:Add, Button, x0 y0 h1 w1, a
			Gui, Update:Add, Text,, Update Available.`nYoure running version %VersionNumber%. The newest is version %newestVersion%`n
			Gui, Update:Add, Edit, w600 h200 +ReadOnly, %changelog% 
			Gui, Update:Add, Button, x70 section default grunUpdate, Update to the Newest Version!
			Gui, Update:Add, Button, x+35 ys gLaunchDonate, Support the Project
			Gui, Update:Add, Button, x+35 ys gdontUpdate, Turn off Auto-Update
			Gui, Update:Show,, WingmanReloaded Update
			IfWinExist WingmanReloaded Update ahk_exe AutoHotkey.exe
			{
				WinWaitClose
			}
		}
	}
	Return

	UpdateGuiClose:
	UpdateGuiEscape:
		Gui, Update: Destroy
		Return
	runUpdate:
		Fail:=False
		Log("Update","Running")
		7za.install(BranchName)
		Run "%A_ScriptFullPath%"
		Sleep 5000 ;This shouldn't ever hit.
		Log("Error","There was an issue with the update")
		Return
	dontUpdate:
		IniWrite, 1, %A_ScriptDir%\save\Settings.ini, General, AutoUpdateOff
		MsgBox, Auto-Updates have been disabled.`nCheck back on the forum for more information!`nTo resume updates, uncheck the box in config page.
		Gui, 4:Destroy
		return  
}

; DaysSince - Check how many days has it been since the last update
DaysSince()
{
  Global LastDatabaseParseDate, UpdateDatabaseInterval
  FormatTime, Date_now, A_Now, yyyyMMdd
  If Date_now = LastDatabaseParseDate ;
    Return False
  daysCount := Date_now
  daysCount -= LastDatabaseParseDate, days
  If daysCount=
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
