; Check for window to be active
SetTimer(PoEWindowCheck, 1000)
; Check once an hour to see if we should updated database
SetTimer(DBUpdateCheck, 360000)
; Log file parser
If FileExist(ClientLog)
{
	Monitor_GameLogs(1)
	SetTimer(Monitor_GameLogs, 300)
}
Else
{
	MsgBox("Client.txt Log File not found!`nAssign the location in Configuration Tab`nClick ""Locate Logfile"" to find yours", "Client Log Error", 262144)
	Log("Error","Client Log not Found",ClientLog)
	WR_StatusBarCtrl.SetText("Client.txt file not found", 2)
}
; Check for Flask presses
SetTimer(TimerPassthrough, KeyscanRate)
; Main Game Timer
SetTimer(TGameTick, Tick)
