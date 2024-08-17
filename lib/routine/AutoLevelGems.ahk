; autoLevelGems - Check for gems that are ready to level up, and click them.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
autoLevelGems()
{
	Static LastCheck:=0
	If (WR.perChar.Setting.autolevelgemsEnable && OnChar && (A_TickCount - LastCheck > 200))
	{
		IfWinActive, ahk_group POEGameGroup 
		{
			SetKeyDelay, %SetKeyDelayValue1%, %SetKeyDelayValue2%, Play
			SetMouseDelay, %SetMouseDelayValue%
			SetDefaultMouseSpeed, %SetDefaultMouseSpeedValue%
			If (WR.perChar.Setting.autolevelgemsWait && (GetKeyState("LButton","P") || GetKeyState("RButton","P")))
				Return
			LastCheck := A_TickCount
			if (ok:=FindText(GameX + Round(GameW * .93) , GameY + Round(GameH * .17), GameX + GameW , GameY + Round(GameH * .8), 0, 0, SkillUpStr,0))
			{
				X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, X+=W//2, Y+=H//2
				MouseGetPos, mX, mY
				LP := GetKeyState("LButton","P"), RP := GetKeyState("RButton","P")
				If (LP || RP)
				{
					If LP
						Click, up
					If RP
						Click, Right, up
					Sleep, 25
				}
				BlockInput, MouseMove
				MouseMove, X, Y, 0
				Sleep, 30*Latency
				Send {Click}
				Sleep, 45*Latency
				MouseMove, mX, mY, 0
				BlockInput, MouseMoveOff
				LP := GetKeyState("LButton","P"), RP := GetKeyState("RButton","P")
				If (LP || RP)
				{
					Sleep, 25
					If LP
						Click, down
					If RP
						Click, Right, down
				}
				ok:=""
			}
		}
	}
	Return
}
