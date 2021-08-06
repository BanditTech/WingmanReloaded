; TGameTick - Main Logic timer - Coordinates all other functions
TGameTick(GuiCheck:=True){
	Static LastAverageTimer:=0,LastPauseMessage:=0, tallyMS:=0, tallyCPU:=0, Metamorph_Filled := False, OnScreenMM := 0
	Global GlobeActive, CurrentMessage, NoGame, GamePID
	If (NoGame)
		Return
	If GamePID
	{
		If (YesController)
			Controller()
		If (DebugMessages && YesTimeMS)
			t1 := A_TickCount
		If ( OnTown || OnHideout || !( WR.func.Toggle.Quit || WR.func.Toggle.Flask || WR.func.Toggle.Utility || WR.func.Toggle.Move || WR.perChar.Setting.autominesEnable || WR.perChar.Setting.autolevelgemsEnable || LootVacuum ) )
		{
			Msg := (OnTown?"Script paused in town"
			:(OnHideout?"Script paused in hideout"
			:(!(WR.func.Toggle.Quit||WR.func.Toggle.Flask||WR.func.Toggle.Utility||WR.func.Toggle.Move||WR.perChar.Setting.autominesEnable||WR.perChar.Setting.autolevelgemsEnable||LootVacuum)?"All options disabled, pausing"
			:"Error")))
			If CheckTime("seconds",1,"StatusBar1")
				SB_SetText(Msg, 1)
			If (CheckGamestates || GlobeActive || YesController)
			{
				GuiStatus()
				If CheckGamestates
					mainmenuGameLogicState()
				Else
					CheckOHB()
				If (GlobeActive)
					ScanGlobe()
			}
			If (DebugMessages && YesTimeMS)
			{
				If ((t1-LastPauseMessage) > 100)
				{
					Ding(600,2,Msg)
					LastPauseMessage := A_TickCount
				}
			}
			Exit
		}

		; Check what status is your character in the game
		if (GuiCheck)
		{
			If !GuiStatus()
			{
				Msg := "Paused while " . (!OnChar?"Not on Character":(OnChat?"Chat is Open":(OnMenu?"Passive/Atlas Menu Open":(OnInventory?"Inventory is Open":(OnStash?"Stash is Open":(OnVendor?"Vendor is Open":(OnDiv?"Divination Trade is Open":(OnLeft?"Left Panel is Open":(OnDelveChart?"Delve Chart is Open":(OnMetamorph?"Metamorph is Open":(YesXButtonFound?"X Button is Detected":"Error")))))))))))
				If CheckTime("seconds",1,"StatusBar1")
					SB_SetText(Msg, 1)
				If (YesFillMetamorph) 
				{
					If (Metamorph_Filled && (OnMetamorph || FindText( GameX + GameW * .5, GameY, GameX + GameW * .7, GameY + GameH * .3, 0, 0, XButtonStr )))
						OnScreenMM := A_TickCount
					Else If (OnMetamorph && !Metamorph_Filled 
					&& FindText( GameX + GameW * .5, GameY, GameX + GameW * .7, GameY + GameH * .3, 0, 0, XButtonStr ) )
					{
						Metamorph_Filled := True
						Metamorph_FillOrgans()
						OnScreenMM := A_TickCount
					}
				}
				If CheckGamestates
				{
					mainmenuGameLogicState()
				}
				If (DebugMessages && YesTimeMS)
					If ((t1-LastPauseMessage) > 100)
					{
						Ding(600,2, Msg )
						LastPauseMessage := A_TickCount
					}
				Exit
			}
			Else If (YesOHB && !(WR.func.failsafe.OHB := CheckOHB()))
			{
				If CheckTime("seconds",1,"StatusBar1")
					SB_SetText("Script paused while no OHB", 1)
				If (DebugMessages && YesTimeMS)
					If ((t1-LastPauseMessage) > 100)
					{
						Ding(600,2,"Script paused while no OHB")
						LastPauseMessage := A_TickCount
					}
				If CheckGamestates
					mainmenuGameLogicState()
				Exit
			}
			; Else If (CheckDialogue()) ; kinda forgot what this was checking for :P
			; {
			;   If CheckTime("seconds",1,"StatusBar1")
			;     SB_SetText("Script paused while NPC Dialogue", 1)
			;   If (DebugMessages && YesTimeMS)
			;     If ((t1-LastPauseMessage) > 100)
			;     {
			;       Ding(600,2,"Script paused while NPC Dialogue")
			;       LastPauseMessage := A_TickCount
			;     }
			;   Exit
			; }
			Else If CheckTime("seconds",1,"StatusBar1")
				SB_SetText("WingmanReloaded Active", 1)
			If (!OnMetamorph && Metamorph_Filled && ((A_TickCount - OnScreenMM) >= 5000) && !FindText( GameX + GameW * .5, GameY, GameX + GameW * .7, GameY + GameH * .3, 0, 0, XButtonStr ))
				Metamorph_Filled := False
			If CheckGamestates
				mainmenuGameLogicState()
		}

		If (WR.perChar.Setting.autominesEnable&&!Detonated)
		{
			If (OnDetonate)
			{
				SendHotkey(hotkeyDetonateMines)
				Detonated:=1
				Settimer, TDetonated, % "-" WR.perChar.Setting.autominesBoomDelay
				a := A_TickCount - MainAttackLastRelease
				If WR.perChar.Setting.autominesSmokeDashEnable&&GetKeyState(hotkeyTriggerMovement,"P")&&(a > 1000)
				{
					SendHotkey(WR.perChar.Setting.autominesSmokeDashKey)
				}
			}
		}

		SendDelayAction()

		If (WR.func.Toggle.Flask || WR.func.Toggle.Quit || WR.func.Toggle.Utility)
		{
			ScanGlobe()
			if (WR.func.Toggle.Quit && Player.Percent[!WR.perChar.Setting.typeES?"Life":"ES"] < WR.perChar.Setting.quitBelow)
			{
				LogoutCommand()
				Exit
			}

			If (WR.func.Toggle.Flask || WR.func.Toggle.Utility) ; Debuff
				CheckDebuffs()

			If (WR.func.Toggle.Flask)
			{
				Loop 5
				{
					If (WR.cdExpires.Flask[A_Index] > A_TickCount) {
						If (WR.Flask[A_Index].ResetCooldownAtHealthPercentage && Player.Percent.Life >= WR.Flask[A_Index].ResetCooldownAtHealthPercentageInput)
						|| (WR.Flask[A_Index].ResetCooldownAtEnergyShieldPercentage && Player.Percent.ES >= WR.Flask[A_Index].ResetCooldownAtEnergyShieldPercentageInput) 
						|| (WR.Flask[A_Index].ResetCooldownAtManaPercentage && Player.Percent.Mana >= WR.Flask[A_Index].ResetCooldownAtManaPercentageInput) {
							WR.cdExpires.Flask[A_Index] := 0
							WR.cdExpires.Group[WR.Flask[A_Index].Group] := 0
						}
					} 
					If (WR.cdExpires.Flask[A_Index] < A_TickCount) {
						If ((WR.Flask[A_Index].Life && WR.Flask[A_Index].Life > Player.Percent.Life)
						|| (WR.Flask[A_Index].ES && WR.Flask[A_Index].ES > Player.Percent.ES)
						|| (WR.Flask[A_Index].Mana && WR.Flask[A_Index].Mana > Player.Percent.Mana))
						{
							Trigger(WR.Flask[A_Index])
							Continue
						}
					}
				}
			}

			If MainAttackPressedActive
			{
				If WR.func.Toggle.Flask
					Loop 5
						If (WR.Flask[A_Index].MainAttack && WR.cdExpires.Flask[A_Index] < A_TickCount)
							Trigger(WR.Flask[A_Index],true)
				If WR.func.Toggle.Utility
					Loop, 10
						If (WR.Utility[A_Index].Enable) && WR.cdExpires.Utility[A_Index] < A_TickCount && (WR.Utility[A_Index].MainAttack)
							Trigger(WR.Utility[A_Index],true)
			}
			If SecondaryAttackPressedActive
			{
				If WR.func.Toggle.Flask
					Loop 5
						If (WR.Flask[A_Index].SecondaryAttack && WR.cdExpires.Flask[A_Index] < A_TickCount)
							Trigger(WR.Flask[A_Index],true)
				If WR.func.Toggle.Utility
					Loop, 10
						If (WR.Utility[A_Index].Enable && WR.cdExpires.Utility[A_Index] < A_TickCount && WR.Utility[A_Index].SecondaryAttack)
							Trigger(WR.Utility[A_Index],true)
			}

			If (WR.func.Toggle.Utility) ; Trigger Utilities
			{
				Loop, 10
				{
					If (WR.Utility[A_Index].Enable && WR.cdExpires.Utility[A_Index] <= A_TickCount)
					{
						If (NOT WR.Utility[A_Index].MainAttackOnly || ( WR.Utility[A_Index].MainAttackOnly && MainAttackPressedActive ))
						{																									 
							If (( WR.Utility[A_Index].OnCD )
							|| ( WR.Utility[A_Index].ES && WR.Utility[A_Index].ES > Player.Percent.ES )
							|| ( WR.Utility[A_Index].Life && WR.Utility[A_Index].Life > Player.Percent.Life )
							|| ( WR.Utility[A_Index].Mana && WR.Utility[A_Index].Mana > Player.Percent.Mana ))
								Trigger(WR.Utility[A_Index])
							Else If (WR.Utility[A_Index].Icon)
							{
								If (WR.Utility[A_Index].IconSearch == 1) ; Search Buff Area
									x1:=GameX, y1:=GameY, x2:=GameX+GameW, y2:=GameY+Round(GameH/(1080/81))
								Else If (WR.Utility[A_Index].IconSearch == 2) ; Search Debuff Area
									x1:=GameX, y1:=GameY+Round(GameH/(1080/81)), x2:=GameX+GameW, y2:=GameY+Round(GameH/(1080/162))
								Else If (WR.Utility[A_Index].IconSearch == 3) ; Custom Icon Area
									x1:=WR.Utility[A_Index].IconArea.X1, y1:=WR.Utility[A_Index].IconArea.Y1, x2:=WR.Utility[A_Index].IconArea.X2, y2:=WR.Utility[A_Index].IconArea.Y2

								BuffIcon := FindText(x1, y1, x2, y2, WR.Utility[A_Index].IconVar1, WR.Utility[A_Index].IconVar0, WR.Utility[A_Index].Icon,0)
								
								If ((WR.Utility[A_Index].IconShown && BuffIcon) || (!WR.Utility[A_Index].IconShown && !BuffIcon))
									Trigger(WR.Utility[A_Index],True)
								Else
									WR.cdExpires.Utility[A_Index] := A_TickCount + (WR.Utility[A_Index].IconShow ? 150 : WR.Utility[A_Index].CD)
							}
						}
					}
				}
			}
		}

		If (WR.func.Toggle.Move && GuiCheck())
		{
			Loop 5
				If WR.Flask[A_Index].Move
					Trigger(WR.Flask[A_Index])
			Loop 10
				If WR.Utility[A_Index].Move
					Trigger(WR.Utility[A_Index])
		}

		If (WR.perChar.Setting.channelrepressEnable)
			StackRelease()
		If LootVacuum
			LootScan()
		If WR.perChar.Setting.autolevelgemsEnable
			autoLevelGems()
		#Include *i %A_ScriptDir%\save\MyCustomRoutine.ahk
		If (DebugMessages && YesTimeMS)
		{
			If ((t1-LastAverageTimer) > 100)
			{
				Ding(3000,2,"Globes:`t" . Player.Percent.Life . "`%L  " . Player.Percent.ES . "`%E  " . Player.Percent.Mana . "`%M")
				Ding(3000,3,"CPU `%:`t" . Round(tallyCPU,2) . "`%  " . tallyMS . "MS")
				tallyMS := 0
				tallyCPU := 0
				LastAverageTimer := A_TickCount
			}
			Else
			{
				t1 := A_TickCount - t1
				tallyMS := (t1>tallyMS?t1:tallyMS)
				load := GetProcessTimes(ScriptPID)
				tallyCPU :=(load>tallyCPU?load:tallyCPU)
			}
		}
	}
	Else
	{
		If CheckTime("seconds",5,"StatusBar1")
			SB_SetText("No game found", 1)
		If CheckTime("seconds",5,"StatusBar3")
			SB_SetText("No game found", 3)
	} 
	Return
}
; TDetonated - Detonate CD Timer
TDetonated:
  Detonated:=0
return
