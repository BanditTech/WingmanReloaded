; PopFlasks - Pop all flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PopFlasks(){
	PopFlasksCommand:
		SetKeyDelay, %SetKeyDelayValue1%, %SetKeyDelayValue2%, Play
		SetMouseDelay, %SetMouseDelayValue%
		SetDefaultMouseSpeed, %SetDefaultMouseSpeedValue%
		Critical
		WR.func.Toggle.PopAll := True
		If PopFlaskRespectCD
		{
			Loop 5
				If WR.Flask[A_Index].PopAll
					Trigger(WR.Flask[A_Index])
			Loop 10
				If WR.Utility[A_Index].PopAll
					Trigger(WR.Utility[A_Index])
		}
		Else
		{
			Loop 5
				If WR.Flask[A_Index].PopAll
				{
					SendHotkey(WR.Flask[A_Index].Key)
					WR.cdExpires.Flask[A_Index]:=A_TickCount + WR.Flask[A_Index].CD
					WR.cdExpires.Group[WR.Flask[A_Index].Group] := A_TickCount + WR.Flask[A_Index].GroupCD
					RandomSleep(-99,99)
				}
			Loop 10
				If WR.Utility[A_Index].PopAll
				{
					SendHotkey(WR.Utility[A_Index].Key)
					WR.cdExpires.Utility[A_Index]:=A_TickCount + WR.Utility[A_Index].CD
					WR.cdExpires.Group[WR.Utility[A_Index].Group] := A_TickCount + WR.Utility[A_Index].GroupCD
					RandomSleep(-99,99)
				}
		}
		Critical, Off
		WR.func.Toggle.PopAll := False
	return
}

