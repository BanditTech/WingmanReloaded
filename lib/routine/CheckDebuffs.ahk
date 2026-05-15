CheckDebuffs(){
	; Debuff area
	If !(searchList := determineDebuffTriggerActive())
		Return
	x1:=GameX, y1:=GameY+Round(GameH/(1080/81)), x2:=GameX+GameW, y2:=GameY+Round(GameH/(1080/162))
	debuffStrMap := Map("Curse", debuffCurseStr, "Shock", debuffShockStr, "Bleed", debuffBleedStr, "Freeze", debuffFreezeStr, "Ignite", debuffIgniteStr, "Poison", debuffPoisonStr)
	For k, debuff in searchList
	{
		If (debuffFound := FindText(x1, y1, x2, y2, 0, 0, debuffStrMap[debuff],0))
		{
			For k, type in ["Flask","Utility"]
				Loop (type="Flask"?5:10)
					If (WR.%type%.%A_Index%.%debuff% && WR.func.Toggle.%type% && WR.cdExpires.%type%[A_Index] <= A_TickCount)
						Trigger(WR.%type%.%A_Index%,True)
		}
	}
	Return
}
determineDebuffTriggerActive(){
	active:=[]
	For k, type in ["Flask","Utility"]
		Loop (type="Flask"?5:10)
		{
			slot := A_Index
			for k, debuff in ["Curse", "Shock", "Bleed", "Freeze", "Ignite", "Poison"]
				If (WR.%type%.%slot%.%debuff% && !indexOf(debuff,active))
					active.Push(debuff)
		}
	If active.Count()
		Return active
	Return False
}
