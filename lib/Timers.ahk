; Check for window to be active
SetTimer, PoEWindowCheck, 1000
; Check once an hour to see if we should updated database
SetTimer, DBUpdateCheck, 360000
; Log file parser
If FileExist(ClientLog)
{
	Monitor_GameLogs(1)
	SetTimer, Monitor_GameLogs, 300
}
Else
{
	MsgBox, 262144, Client Log Error, Client.txt Log File not found!`nAssign the location in Configuration Tab`nClick ""Locate Logfile"" to find yours
	Log("Error","Client Log not Found",ClientLog)
	SB_SetText("Client.txt file not found", 2)
}
; Check for Flask presses
SetTimer, TimerPassthrough, %KeyscanRate%
; Main Game Timer
SetTimer, TGameTick, %Tick%
