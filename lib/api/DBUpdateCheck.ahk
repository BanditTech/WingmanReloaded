; DBUpdateCheck - Check if the database should be updated 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DBUpdateCheck()
{
	Global LastDatabaseParseDate
	FormatTime, Date_now, A_Now, yyyyMMdd

	try {
		IfWinExist, ahk_group POEGameGroup 
		{
			Return
		} 
		Else If (YesNinjaDatabase && DaysSince())
		{
			For k, apiKey in apiList
				ScrapeNinjaData(apiKey)
			JSONtext := JSON.Dump(Ninja,,2)
			FileDelete, %A_ScriptDir%\data\Ninja.json
			FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
			IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
			LastDatabaseParseDate := Date_now
		}
	} catch e {
		Log("Error","DBUpdateCheck Error: " ErrorText(e))
	}
	Return
}
