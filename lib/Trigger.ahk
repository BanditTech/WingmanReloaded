; Trigger - Generic Trigger for flasks or utility
Trigger(obj,force:=False){
	If !GuiCheck()
		Return
	Static ActionList := {}
	Static LastHeldLB, LastHeldMA, LastHeldSA
	Global MovementHotkeyActive
	If !IsObject(ActionList[obj.Group])
		ActionList[obj.Group] := {}
	If (force && WR.cdExpires[obj.Type][obj.Slot] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount)
		ActionList[obj.Group].Push(obj.Type . " " . obj.Slot . " Force")
	Else If ( !(indexOf(obj.Type . " " . obj.Slot . " Check",ActionList[obj.Group]) || indexOf(obj.Type . " " . obj.Slot . " Force",ActionList[obj.Group])) && ConfirmMatchingTriggers(obj))
		ActionList[obj.Group].Push(obj.Type . " " . obj.Slot . " Check")
	Else If !ActionList[obj.Group].Count()
	{
		loop % (obj.Type="Flask"?5:10)
			if (WR[obj.Type][A_Index].Group = obj.Group  && !(indexOf(obj.Type . " " . obj.Slot . " Check",ActionList[obj.Group]) || indexOf(obj.Type . " " . obj.Slot . " Force",ActionList[obj.Group])) ) 
				ActionList[obj.Group].Push(obj.Type . " " . A_Index . " Check")
	} 
	For k, v in ActionList[obj.Group]
	{
		type := StrSplit(v, " ")[1], recheck := (StrSplit(v, " ")[3] == "Check"?True:False), v := StrSplit(v, " ")[2]
		If (!recheck || (recheck && ConfirmMatchingTriggers(WR[type][v])))
		If (WR.cdExpires[type][v] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount)
		{
			If (WR[type][v].Move && !force)
			{
				If !GameActive
					Return
				MovementPressed := ( MovementHotkeyActive || GetKeyState(hotkeyTriggerMovement,"P")  
												|| (MainAttackPressedActive && WR.perChar.Setting.movementMainAttack)
												|| (SecondaryAttackPressedActive && WR.perChar.Setting.movementSecondaryAttack) )
				If (MovementPressed)
				{
					If (!WR.cdExpires.Binding.Move) ; If we have not had a source pressed before
						WR.cdExpires.Binding.Move := A_TickCount + ((WR.perChar.Setting.movementDelay+0)*1000)
				} Else { ; All binding sources were not active
					If (WR.cdExpires.Binding.Move)
						WR.cdExpires.Binding.Move := ""
				}
				if ( !MovementPressed || (WR.cdExpires.Binding.Move && A_TickCount < WR.cdExpires.Binding.Move) )
					Return
			}
			SendHotkey(WR[type][v].Key)
			WR.cdExpires.Group[obj.Group] := A_TickCount + WR[type][v].GroupCD 
			WR.cdExpires[type][v] := A_TickCount + WR[type][v].CD 
			ActionList[obj.Group].RemoveAt(k)
			If (WR[type][v].Group = "QuickSilver")
				Loop, 10
					If (WR.Utility[A_Index].Enable && WR.Utility[A_Index].QS)
						Trigger(WR.Utility[A_Index],true)
			Return
		}
	}
	Return
}
ConfirmMatchingTriggers(obj){
	If ((obj.Enable || obj.Type = "Flask") && WR.cdExpires[obj.Type][obj.Slot] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount )
	{
		If (WR.func.Toggle.PopAll && obj.PopAll) ; PopAll trigger
			Return True
		If (obj.OnCD)
			Return True
		If ( ( WR.func.Toggle[obj.Type] && obj.Condition == 1 ; Any/All Resource Triggers
			&& (obj.Life && obj.Life > Player.Percent.Life) || (obj.ES && obj.ES > Player.Percent.ES) || (obj.Mana && obj.Mana > Player.Percent.Mana) ) 
			|| ( WR.func.Toggle[obj.Type] && obj.Condition == 2 
			&& (!obj.Life || (obj.Life && obj.Life > Player.Percent.Life)) && (!obj.ES || (obj.ES && obj.ES > Player.Percent.ES)) && (!obj.Mana || (obj.Mana && obj.Mana > Player.Percent.Mana)) ) )
			Return True
		If (obj.Move && WR.func.Toggle.Move)
		{ ; Move Triggers
			If ( MovementHotkeyActive || GetKeyState(hotkeyTriggerMovement,"P")  
			|| (MainAttackPressedActive && WR.perChar.Setting.movementMainAttack)
			|| (SecondaryAttackPressedActive && WR.perChar.Setting.movementSecondaryAttack) )
			{
				If !WR.cdExpires.Binding.Move ; If we have not had a source pressed before
					WR.cdExpires.Binding.Move := A_TickCount + ((WR.perChar.Setting.movementDelay+0)*1000)
			} Else { ; All binding sources were not active
				If WR.cdExpires.Binding.Move
					WR.cdExpires.Binding.Move := ""
			}
			If (WR.cdExpires.Binding.Move && WR.cdExpires.Binding.Move <= A_TickCount)
			{
				Return True
			}
		}
		If (WR.func.Toggle[obj.Type] 
			&& ( (obj.MainAttack && MainAttackPressedActive) ;Attack Triggers
			|| (obj.SecondaryAttack && SecondaryAttackPressedActive) ) )
			Return True
	}
	Return False
}
; MainAttackCommand - Main attack Flasks
MainAttackCommand()
{
	MainAttackCommand:
	If (MainAttackPressedActive||OnTown||OnHideout)
		Return
	MainAttackPressedActive := True
	Return  
}
MainAttackCommandRelease()
{
	MainAttackCommandRelease:
	MainAttackPressedActive := False
	MainAttackLastRelease := A_TickCount
	If (OnTown||OnHideout)
		Return
	For k, types in ["Flask","Utility"]
		loop % (types="Flask"?5:10)
			If ((WR[types][A_Index].Enable || WR[types][A_Index].Type = "Flask") && WR[types][A_Index].MainAttackRelease && WR.cdExpires[obj.Type][obj.Slot] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount )
				Trigger(WR[types][A_Index],True)
	Return  
}
; SecondaryAttackCommand - Secondary attack Flasks
SecondaryAttackCommand()
{
	SecondaryAttackCommand:
	If (SecondaryAttackPressedActive||OnTown||OnHideout)
		Return
	SecondaryAttackPressedActive := True
	Return  
}
SecondaryAttackCommandRelease()
{
	SecondaryAttackCommandRelease:
	SecondaryAttackPressedActive := False
	If (OnTown||OnHideout)
		Return
	For k, types in ["Flask","Utility"]
		loop % (types="Flask"?5:10)
			If ((WR[types][A_Index].Enable || WR[types][A_Index].Type = "Flask") && WR[types][A_Index].SecondaryAttackRelease && WR.cdExpires[obj.Type][obj.Slot] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount )
				Trigger(WR[types][A_Index],True)
	Return  
}
; TimerPassthrough - Uses the first key of each flask slot in order to put the slot on cooldown when manually used.
TimerPassthrough:
	Loop 5
		try {
		If GetKeyState(StrSplit(WR.Flask[A_Index].Key," ")[1], "P")
			WR.cdExpires.Flask[A_Index]:=A_TickCount + WR.Flask[A_Index].CD
		} catch e {
			Log("Error","TimerPassthrough Error: " ErrorText(e))
		}
Return
