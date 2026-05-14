; DBUpdateCheck - Check if the database should be updated
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DBUpdateCheck()
{
	Global LastDatabaseParseDate
	Date_now := FormatTime(A_Now, "yyyyMMdd")

	try {
		if WinExist("ahk_group POEGameGroup")
		{
			Return
		}
		Else If (YesNinjaDatabase && DaysSince())
		{
			For k, apiKey in apiList
				ScrapeNinjaData(apiKey)
			JSONtext := JSON.Dump(Ninja,,2)
			FileDelete(A_ScriptDir "\data\Ninja.json")
			FileAppend(JSONtext, A_ScriptDir "\data\Ninja.json")
			IniWrite(Date_now, A_ScriptDir "\save\Settings.ini", "Database", "LastDatabaseParseDate")
			LastDatabaseParseDate := Date_now
		}
	} catch as e {
		Log("Error","DBUpdateCheck Error: " ErrorText(e))
	}
	Return
}
