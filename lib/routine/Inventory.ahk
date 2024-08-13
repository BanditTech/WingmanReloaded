; ItemSortCommand - Sort inventory and determine action
ItemSortCommand(){
	; Thread, NoTimers, True
	CheckRunning()
	SetActionTimings()
	MouseGetPos xx, yy
	IfWinActive, ahk_group POEGameGroup
	{
		CheckRunning("On")
		GuiStatus()
		If (!OnChar)
		{ ;Need to be on Character
			Notify("You do not appear to be in game.","Likely need to calibrate Character Active",1)
			CheckRunning("Off")
			Return
		}
		Else If (!OnInventory&&OnChar) ; Click Stash or open Inventory
		{
			; First Automation Entry
			If (FirstAutomationSetting == "Search Vendor" && YesEnableAutomation && (OnTown || OnHideout || OnMines))
			{
				; This automation use the following Else If (OnVendor && YesVendor) to entry on Vendor Routine
				If !SearchVendor()
				{
					SendHotkey(hotkeyInventory)
					CheckRunning("Off")
					Return
				}
			}
			; First Automation Entry
			Else If (FirstAutomationSetting == "Search Stash" && YesEnableAutomation && (OnTown || OnHideout || OnMines))
			{
				; This automation use the following Else If (OnStash && YesStash) to entry on Stash Routine
				If !SearchStash()
				{
					SendHotkey(hotkeyInventory)
					CheckRunning("Off")
					Return
				}
			}
			Else
			{
				SendHotkey(hotkeyInventory)
				CheckRunning("Off")
				Return
			}
		}
		Sleep, -1
		GuiStatus()
		If (OnDiv && YesDiv)
			DivRoutine()
		Else If (OnStash && YesStash)
			StashRoutine()
		Else If (OnVendor && YesVendor)
			VendorRoutine()
		Else If (OnInventory&&YesIdentify)
			IdentifyRoutine()
	}
	Sleep, 90*Latency
	MouseMove, xx, yy, 0
	CheckRunning("Off")
	UpdateGuiChaosCounts()
	Return
}

CheckRunning(ret:=false){
	Global RunningToggle
	If (RunningToggle && !ret) ; This means an underlying thread is already running the loop below.
	{
		RunningToggle := False ; Signal that thread's loop to stop.
		ResetMainTimer("On")
		Notify("Aborting Current Process","",2)
		exit ; End this thread so that the one underneath will resume and see the change made by the line above.
	} Else If (ret=="On") {
		RunningToggle := True
		ResetMainTimer("Off")
	} Else If (ret) {
		RunningToggle := False ; Reset in preparation for the next press of this hotkey.
		ResetMainTimer("On")
		Return
	}
}
; Search Stash Routine
SearchStash()
{
	If (FindStash:=FindText(GameX,GameY,GameW,GameH,0,0,StashStr))
	{
		LeftClick(FindStash.1.x,FindStash.1.y)
		Loop, 66
		{
			Sleep, 50
			GuiStatus()
			If OnStash
				Return True
			Else If ( !Mod(A_Index,20) && (FindStash:=FindText(GameX,GameY,GameW,GameH,0,0,StashStr)) )
				LeftClick(FindStash.1.x,FindStash.1.y)
		}
	}
	Return False
}
; ShooMouse - Move mouse out of the inventory area
ShooMouse()
{
	Random, RX, (A_ScreenWidth*0.45), (A_ScreenWidth*0.55)
	Random, RY, (A_ScreenHeight*0.45), (A_ScreenHeight*0.55)
	MouseMove, RX, RY, 0
	Sleep, 90*Latency
}
; ClearNotifications - Get rid of overlay messages if any are present
ClearNotifications()
{
	; Global InventoryGridY
	If (xBtn := FindText(GameW - 30,InventoryGridY[1] - 90,GameW,InventoryGridY[5] + 30,0.2,0.2,XButtonStr,0))
	{
		Log("Verbose","Clearing Notifications #" xBtn.Count(), GameW, InventoryGridY[1], InventoryGridY[5])
		For k, v in xBtn
			LeftClick(v.x,v.y)
		Sleep, 300*Latency
		GuiStatus()
	}
}
; Make a more uniform method of checking for identification
CheckToIdentify(){
	If (Item.Affix["Unidentified"] && YesIdentify)
	{
		If (Item.Prop.IsSynthesisItem && YesSynthesisId && Item.Prop.Rarity_Digit <= 3)
			Return True
		Else If (Item.Prop.IsInfluenceItem && YesInfluencedUnid && Item.Prop.RarityRare)
			Return False
		Else If (ChaosRecipeEnableFunction && ChaosRecipeEnableUnId && (Item.Prop.ChaosRecipe || Item.Prop.RegalRecipe)
			&& Item.Prop.ItemLevel < ChaosRecipeLimitUnId && Item.StashChaosRecipe(false))
			Return False
		Else If (Item.Prop.IsMap && !YesMapUnid)
			Return True
		Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) )
			Return True
		Else If ( Item.Prop.Jeweller && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
			Return True
		Else If (!Item.Prop.Chromatic && !Item.Prop.Jeweller && !Item.Prop.IsMap)
			Return True
	}
	Return False
}
; VendorRoutine - Does vendor functions
VendorRoutine()
{
	SetActionTimings()
	tQ := 0
	tGQ := 0
	SortFlask := []
	SortGem := []
	BlackList := Array_DeepClone(BlackList_Default)
	; Move mouse out of the way to grab screenshot
	ShooMouse()
	GuiStatus()
	ClearNotifications()
	If !OnVendor
	{
		Return
	}
	If StashTabYesPredictive
	{
		If !PPServerStatus()
			Notify("PoEPrice.info Offline","",2)
	}
	VendoredItems := False
	; Main loop through inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If (BlackList[C][R] || !WR.Restock[C][R].Normal)
				Continue
			Grid := RandClick(GridX, GridY)
			PointColor := FindText.GetColor(GridX,GridY)

			If indexOf(PointColor, varEmptyInvSlotColor) {
				;Seems to be an empty slot, no need to clip item info
				Continue
			}
			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			If (!Item.Prop.IsItem || Item.Prop.ItemName = "")
				ShooMouse(),GuiStatus(),Continue
			If CheckToIdentify()
			{
				WisdomScroll(Grid.X,Grid.Y)
				ClipItem(Grid.X,Grid.Y)
			}

			If (OnVendor&&YesVendor)
			{
				If Item.MatchLootFilter()
					Continue
				If (Item.Prop.RarityCurrency && !Item.Prop.Vendorable)
					Continue
				If ( Item.Prop.Flask && Item.Prop.Quality > 0 )
				{
					If !YesBatchVendorBauble
						Continue
					If (Item.Prop.Quality >= 20)
						Q := 40
					Else
						Q := Item.Prop.Quality
					tQ += Q
					SortFlask.Push({"C":C,"R":R,"Q":Q})
					Continue
				}
				If ( Item.Prop.RarityGem && Item.Prop.Quality > 0 )
				{
					If !YesBatchVendorGCP
						Continue
					If (Item.Prop.Quality >= 20)
						Continue
					Q := Item.Prop.Quality
					tGQ += Q
					SortGem.Push({"C":C,"R":R,"Q":Q})
					Continue
				}
				If ((Item.Prop.StashReturnVal && !Item.Prop.DumpTabItem)
					|| (Item.Prop.StashReturnVal && (!YesVendorDumpItems && Item.Prop.DumpTabItem)))
					&& !(Item.Prop.Vendorable)
					Continue
				If ( Item.Prop.SpecialType="" || Item.Prop.Vendorable )
				{
					CtrlClick(Grid.X,Grid.Y)
					If !(Item.Prop.Chromatic || Item.Prop.Jeweller)
						VendoredItems := True
					Continue
				}
			}
		}
	}
	; Sell any bulk Flasks or Gems
	If (OnVendor && RunningToggle && YesVendor && tQ >= 40)
	{
		Grouped := New SortByNum(SortFlask)
		For k, v in Grouped
		{
			If (!RunningToggle) ; The user signaled the loop to stop by pressing Hotkey again.
				exit
			For kk, vv in v
			{
				If (!RunningToggle) ; The user signaled the loop to stop by pressing Hotkey again.
					exit
				Grid := RandClick(InventoryGridX[vv.C], InventoryGridY[vv.R])
				CtrlClick(Grid.X,Grid.Y)
				RandomSleep(20,40)
				VendoredItems := True
			}
		}
	}
	If (OnVendor && RunningToggle && YesVendor && tGQ >= 40)
	{
		Grouped := New SortByNum(SortGem)
		For k, v in Grouped
		{
			If (!RunningToggle) ; The user signaled the loop to stop by pressing Hotkey again.
				exit
			For kk, vv in v
			{
				If (!RunningToggle) ; The user signaled the loop to stop by pressing Hotkey again.
					exit
				Grid := RandClick(InventoryGridX[vv.C], InventoryGridY[vv.R])
				CtrlClick(Grid.X,Grid.Y)
				RandomSleep(20,40)
				VendoredItems := True
			}
		}
	}
	; Auto Confirm Vendoring Option
	If (OnVendor && RunningToggle && YesEnableAutomation)
	{
		ContinueFlag := False
		If (YesEnableAutoSellConfirmation || (!VendoredItems && YesEnableAutoSellConfirmationSafe))
		{
			RandomSleep(20,40)
			LeftClick(WR.loc.pixel.VendorAccept.X,WR.loc.pixel.VendorAccept.Y)
			RandomSleep(20,40)
			ContinueFlag := True
		}
		Else If (FirstAutomationSetting=="Search Vendor")
		{
			CheckTime("Seconds",120,"VendorUI",A_Now)
			If YesEnableAutoSellConfirmationSafe
				MouseMove, WR.loc.pixel.VendorAccept.X, WR.loc.pixel.VendorAccept.Y
			While (!CheckTime("Seconds",120,"VendorUI"))
			{
				If (YesController)
					Controller()
				Sleep, 100
				GuiStatus()
				If !OnVendor && !OnInventory
				{
					ContinueFlag := True
					break
				}
			}
		}
		; Search Stash and StashRoutine
		If (YesEnableNextAutomation && FirstAutomationSetting=="Search Vendor" && ContinueFlag)
		{
			RandomSleep(20,40)
			SendHotkey(hotkeyCloseAllUI)
			RandomSleep(20,40)
			If OnHideout
				Town := "Hideout"
			Else If OnMines
				Town := "Mines"
			Else
				Town := CompareLocation("Town")

			If OnMines
			{
				LeftClick(GameX + GameW//1.5, GameY + GameH//1.1)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			Else If (Town = "Oriath Docks")
			{
				LeftClick(GameX + GameW//1.1, GameY + GameH//3)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			Else If (Town = "The Sarn Encampment")
			{
				LeftClick(GameX + GameW//1.1, GameY + GameH//3)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			GuiStatus()
			If SearchStash()
				StashRoutine()
		}
	}
	Return
}
; Build Empty Grid List
EmptyGrid(){
	ShooMouse()
	FindText.ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH)
	EmptySlots := {}
	For C, GridX in InventoryGridX {
		For R, GridY in InventoryGridY {
			If !WR.Restock[C][R].Normal
				Continue 1
			PointColor := FindText.GetColor(GridX,GridY)
			If indexOf(PointColor, varEmptyInvSlotColor) {
				EmptySlots.Push(RandClick(GridX, GridY))
			}
		}
	}
	If (YesSkipMaps_eval = "<=")
		EmptySlots := AHK.Reverse(AHK.SortBy(EmptySlots,"X"))
	Return EmptySlots
}
; Open Stacked Decks Automatically
StackedDeckOpen(number,x,y){
	SetActionTimings()
	EmptySlots := EmptyGrid()
	Loop %number% {
		If (EmptySlots.Count() >= 1){
			If !RunningToggle
				Break
			RightClick(x,y)
			Sleep, 75
			EmptySlot := EmptySlots.Pop()
			LeftClick(EmptySlot.X,EmptySlot.Y)
			Sleep, 75
		} Else {
			Break
		}
	}
}
ResetMainTimer(toggle:="On"){
	If (WR.func.Toggle.Quit || WR.func.Toggle.Flask || WR.func.Toggle.Utility || WR.func.Toggle.Move || WR.perChar.Setting.autominesEnable || WR.perChar.Setting.autolevelgemsEnable || LootVacuum)
		SetTimer, TGameTick, %toggle%
}
; StashRoutine - Does stash functions
StashRoutine()
{
	SetActionTimings()
	Global PPServerStatus
	If StashTabYesPredictive
	{
		If !PPServerStatus()
			Notify("PoEPrice.info Offline","",2)
	}
	CurrentTab:=0
	SortFirst := {}
	Loop 99
	{
		SortFirst[A_Index] := {}
	}
	BlackList := Array_DeepClone(BlackList_Default)
	; Move mouse away for Screenshot
	ShooMouse()
	FindText.ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH)
	ClearNotifications()
	; CraftingBasesRequest()
	; Main loop through inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If (BlackList[C][R] || !WR.Restock[C][R].Normal)
				Continue
			Grid := RandClick(GridX, GridY)
			PointColor := FindText.GetColor(GridX,GridY)
			If indexOf(PointColor, varEmptyInvSlotColor) {
				;Seems to be an empty slot, no need to clip item info
				Continue
			}

			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			If CheckToIdentify()
			{
				WisdomScroll(Grid.X,Grid.Y)
				ClipItem(Grid.X,Grid.Y)
			}
			If (YesOpenStackedDeck && Item.Prop.ItemName = "Stacked Deck")
			|| (YesOpenVeiledScarab && Item.Prop.ItemName = "Veiled Scarab") {
				StackedDeckOpen(Item.Prop.Stack_Size,Grid.X,Grid.Y)
				ShooMouse(),GuiStatus(),Continue
			}

			If (OnStash && YesStash)
			{
				If (Item.Prop.SpecialType = "Quest Item" || Item.Prop.ItemClass = "Quest Items")
					Continue
				Else If (sendstash:=Item.MatchLootFilter())
					Sleep, -1
				Else If ( Item.Prop.MapPrep && YesSkipMaps && YesSkipMaps_Prep && InMapArea(C) )
					Continue
				Else If ((Item.Prop.SpecialType = "Heist Contract" || Item.Prop.SpecialType = "Heist Blueprint") && YesSkipMaps && InMapArea(C)
					&& ( (Item.Prop.RarityNormal && YesSkipMaps_normal)
					|| (Item.Prop.RarityMagic && YesSkipMaps_magic)
					|| (Item.Prop.RarityRare && YesSkipMaps_rare)
					|| (Item.Prop.RarityUnique && YesSkipMaps_unique) ) )
					Continue
				Else If ( Item.Prop.IsMap && !Item.Prop.IsBrickedMap && YesSkipMaps && InMapArea(C)
					&& ( (Item.Prop.RarityNormal && YesSkipMaps_normal)
					|| (Item.Prop.RarityMagic && YesSkipMaps_magic)
					|| (Item.Prop.RarityRare && YesSkipMaps_rare)
					|| (Item.Prop.RarityUnique && YesSkipMaps_unique) )
					&& (Item.Prop.Map_Tier >= YesSkipMaps_tier) )
					Continue
				Else If (sendstash:=Item.MatchStashManagement(True)){
					;Skip
					If (sendstash == -1)
						Continue
					;Affinities
					Else If (sendstash == -2)
					{
						CtrlClick(Grid.X,Grid.Y)
						If (Item.Prop.RarityUnique && !Item.Prop.HasKey("IsOrgan")) && ((StashTabYesUniqueRing && Item.Prop.Ring) || StashTabYesUniqueDump)
						{
							Sleep, 250*Latency
							ShooMouse()
							GuiStatus()
							ClearNotifications()
							Pitem := FindText.GetColor(GridX,GridY)
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							SortFirst[StashTabYesUniqueRing && Item.Prop.Ring?StashTabUniqueRing:StashTabUniqueDump].Push({"C":C,"R":R,"Item":Item})
						} Else {
							Continue
						}
					}
				}
				Else
					++Unstashed
				If (sendstash == -2) {
					CtrlClick(Grid.X,Grid.Y)
				} Else If (sendstash > 0) {
					If YesSortFirst
						SortFirst[sendstash].Push({"C":C,"R":R,"Item":Item})
					Else
					{
						MoveStash(sendstash)
						RandomSleep(20,40)
						CtrlShiftClick(Grid.X,Grid.Y)
						; Check if we need to send to alternate stash for uniques
						If (sendstash = StashTabUnique || sendstash = StashTabUniqueRing )
							&& (Item.Prop.RarityUnique && !Item.Prop.HasKey("IsOrgan"))
						{
							If (StashTabYesUniqueRing && Item.Prop.Ring
								&& sendstash != StashTabUniqueRing)
							{
								Sleep, 200*Latency
								ShooMouse(), GuiStatus(), ClearNotifications(), Pitem := FindText.GetColor(GridX,GridY)
								if (indexOfHex(Pitem, varEmptyInvSlotColor))
									Continue
								MoveStash(StashTabUniqueRing)
								RandomSleep(20,40)
								CtrlShiftClick(Grid.X,Grid.Y)
							}
							If (StashTabYesUniqueDump)
							{
								Sleep, 200*Latency
								ShooMouse()
								GuiStatus()
								ClearNotifications()
								Pitem := FindText.GetColor(GridX,GridY)
								if (indexOfHex(Pitem, varEmptyInvSlotColor))
									Continue
								MoveStash(StashTabUniqueDump)
								RandomSleep(20,40)
								CtrlShiftClick(Grid.X,Grid.Y)
							}
						}
					}
				}
			}
		}
	}
	; Sorted items are sent together
	If (OnStash && RunningToggle && YesStash)
	{
		If (YesSortFirst)
		{
			For Tab, Tv in SortFirst
			{
				If !RunningToggle
					Break
				For Items, Iv in Tv
				{
					If !RunningToggle
						Break
					MoveStash(Tab)
					C := SortFirst[Tab][Items]["C"]
					R := SortFirst[Tab][Items]["R"]
					Item := SortFirst[Tab][Items]["Item"]
					GridX := InventoryGridX[C]
					GridY := InventoryGridY[R]
					Grid := RandClick(GridX, GridY)
					CtrlShiftClick(Grid.X,Grid.Y)
					; Check for unique items
					If (Tab = StashTabUnique || Tab = StashTabUniqueRing )
						&& (Item.Prop.RarityUnique && !Item.Prop.HasKey("IsOrgan"))
					{
						If (StashTabYesUniqueRing && Item.Prop.Ring
							&& Tab != StashTabUniqueRing)
						{
							Sleep, 200*Latency
							ShooMouse()
							GuiStatus()
							ClearNotifications()
							Pitem := FindText.GetColor(GridX,GridY)
							; Check if the item is gone, if it is we can move on
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueRing)
							CtrlShiftClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueDump)
						{
							Sleep, 200*Latency
							ShooMouse()
							GuiStatus()
							ClearNotifications()
							Pitem := FindText.GetColor(GridX,GridY)
							; Check if the item is gone, if it is we can move on
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueDump)
							CtrlShiftClick(Grid.X,Grid.Y)
						}
					}
				}
			}
		}
		If (RunningToggle && (EnableRestock))
		{
			RunRestock()
		}
		; Find Vendor if Automation Start with Search Stash and NextAutomation is enable
		If (FirstAutomationSetting == "Search Stash" && YesEnableAutomation && YesEnableNextAutomation && Unstashed && RunningToggle && (OnHideout || OnTown || OnMines))
		{
			SendHotkey(hotkeyCloseAllUI)
			RandomSleep(20,40)
			GuiStatus()
			If SearchVendor()
				VendorRoutine()
		} Else If (FirstAutomationSetting == "Search Vendor") {
			RandomSleep(20,40)
			SendHotkey(hotkeyCloseAllUI)
			RandomSleep(20,40)
			GuiStatus()
		}
	}
	Return
}

; Search Vendor Routine
SearchVendor()
{
	If OnHideout
		SearchStr := VendorStr
	Else If OnMines
	{
		SearchStr := VendorMineStr
		Town := "Mines"
	}
	Else
	{
		Town := CompareLocation("Town")
		If (Town = "Lioneye's Watch")
			SearchStr := VendorLioneyeStr
		Else If (Town = "The Forest Encampment")
			SearchStr := VendorForestStr
		Else If (Town = "The Sarn Encampment")
			SearchStr := VendorSarnStr
		Else If (Town = "Highgate")
			SearchStr := VendorHighgateStr
		Else If (Town = "Overseer's Tower")
			SearchStr := VendorOverseerStr
		Else If (Town = "The Bridge Encampment")
			SearchStr := VendorBridgeStr
		Else If (Town = "Oriath Docks")
			SearchStr := VendorDocksStr
		Else If (Town = "Oriath")
			SearchStr := VendorOriathStr
		Else If (Town = "The Rogue Harbour")
			SearchStr := VendorHarbourStr
		Else
			Return
	}
	Sleep, 45*Latency
	Sell:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SellItemsStr, 1, 0)
	If (Sell)	{
		Sleep, 30*Latency
		LeftClick(Sell.1.x,Sell.1.y)
		Sleep, 120*Latency
		Return True
	}
	Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SearchStr, 1, 0)
	If (FirstAutomationSetting == "Search Stash" && !Vendor)
	{
		If (Town = "The Sarn Encampment")
		{
			LeftClick(GameX + GameW//6, GameY + GameH//1.5)
			Sleep, 600
			; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
		}
		Else If (Town = "Oriath Docks")
		{
			LeftClick(GameX + 5, GameY + GameH//2)
			Sleep, 1200
			; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
		}
		Else If (Town = "Mines")
		{
			LeftClick(GameX + GameW//3, GameY + GameH//5)
			Sleep, 1300
			; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
		}
		Else If (Town = "The Rogue Harbour")
		{
			LeftClick(GameX + GameW//3, GameY + GameH//1.3)
			Sleep, 800
			; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
		}
	}
	If (!Vendor)
		Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SearchStr, 1, 0)
	if (Vendor)
	{
		LeftClick(Vendor.1.x, Vendor.1.y)
		Sleep, 60
		Loop, 66
		{
			If (Sell:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SellItemsStr, 1, 0))
			{
				Sleep, 30*Latency
				LeftClick(Sell.1.x,Sell.1.y)
				Sleep, 120*Latency
				Return True
			}
			Else If !Mod(A_Index, 20)
			{
				If (Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SearchStr, 1, 0))
					LeftClick(Vendor.1.x, Vendor.1.y)
			}
			Sleep, 50
		}
	}
	Return False
}

; DivRoutine - Does divination trading function
DivRoutine()
{
	SetActionTimings()
	BlackList := Array_DeepClone(BlackList_Default)
	ShooMouse()
	GuiStatus()
	ClearNotifications()
	; Main loop through inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If (BlackList[C][R] || !WR.Restock[C][R].Normal)
				Continue
			Grid := RandClick(GridX, GridY)
			PointColor := FindText.GetColor(GridX,GridY)

			If indexOf(PointColor, varEmptyInvSlotColor) {
				;Seems to be an empty slot, no need to clip item info
				Continue
			}

			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			; Trade full div stacks
			If (OnDiv && YesDiv)
			{
				If (Item.Prop.RarityDivination && (Item.Prop.Stack = Item.Prop.StackMax)){
					CtrlClick(Grid.X,Grid.Y)
					RandomSleep(150,200)
					LeftClick(WR.loc.pixel.OnDiv.X,WR.loc.pixel.DivTrade.Y)
					Sleep, 45+(ClickLatency*15)
					CtrlClick(WR.loc.pixel.OnDiv.X,WR.loc.pixel.DivItem.Y)
					Sleep, 45+(ClickLatency*15)
				}
				Continue
			}
		}
	}
	Return
}
; IdentifyRoutine - Does basic function when not at other windows
IdentifyRoutine()
{
	SetActionTimings()
	BlackList := Array_DeepClone(BlackList_Default)
	ShooMouse()
	GuiStatus()
	ClearNotifications()
	; Main loop through inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If (BlackList[C][R] || !WR.Restock[C][R].Normal)
				Continue
			Grid := RandClick(GridX, GridY)
			PointColor := FindText.GetColor(GridX,GridY)

			If indexOf(PointColor, varEmptyInvSlotColor) {
				;Seems to be an empty slot, no need to clip item info
				Continue
			}

			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			; id if necessary
			If CheckToIdentify()
			{
				WisdomScroll(Grid.X,Grid.Y)
				ClipItem(Grid.X,Grid.Y)
			}
		}
	}
	Return
}
; ItemInfo - Display information about item under cursor
ItemInfo(){
	ItemInfoCommand:
		ItemParseActive := True
		MouseGetPos, Mx, My
		ClipItem(Mx, My)
		Item.ItemInfo()
		ItemParseActive := False
	Return
}
; MoveStash - Input any digit and it will move to that Stash tab
MoveStash(Tab,CheckStatus:=0)
{
	If CheckStatus
	{
		If !GuiStatus("OnStash")
		{
			Notify("Was not able to verify OnStash","",2)
			Return
		}
		CurrentTab := 0
	}
	If (CurrentTab==Tab)
		return
	If (CurrentTab!=Tab)
	{
		Sleep, 90*Latency
		Dif:=(CurrentTab-Tab)
		If (CurrentTab = 0)
		{
			If (OnChat)
			{
				Send {Escape}
				Sleep, 15
			}
			send {Left 99}
			val := Tab - 1
			send {Right %val%}
			CurrentTab:=Tab
		}
		Else
		{
			val := Abs(Dif)
			If (Dif > 0)
				SendInput {Left %val%}
			Else
				SendInput {Right %val%}
			CurrentTab:=Tab
		}
		Sleep, 210*Latency
	}
	If (Tab == StashTabMap || Tab == StashTabUnique)
		Sleep, 300*Latency
	return
}
; RunRestock - Restock currency Items in inventory
RunRestock(){
	SetActionTimings()
	BlockInput, MouseMove
	For C, vv in WR.Restock {
		For R, v in vv {
			If (v.Normal || v.Ignored || v.RestockName = "")
				Continue
			If !(v.RestockName = "Custom") {
				If !WR.loc.pixel.HasKey(v.RestockName){
					Notify("Missing Location","There is no entry for " v.RestockName,5)
					Continue
				} Else If (WR.loc.pixel[v.RestockName].X = 0 && WR.loc.pixel[v.RestockName].Y = 0) {
					Notify("Unscaled Location","The entry for " v.RestockName " has not been scaled from 0",5)
					Continue
				}
			}
			X := InventoryGridX[C], Y := InventoryGridY[R]
			o := RandClick(X,Y)
			ClipItem(o.X, o.Y)
			If (Item.Prop.Stack_Size <= 0)
				Item.Prop.Stack_Size := 0
			; Store the item stack size
			InvCount := Item.Prop.Stack_Size
			If (InvCount = v.RestockTo && v.RestockTo = v.RestockMax) {
				Continue
			}
			If (InvCount < v.RestockMin || InvCount >= v.RestockMax) {
				If (v.RestockName = "Custom") {
					MoveStash(v.CustomTab)
					StockX := v.CustomX
					StockY := v.CustomY
				} Else {
					MoveStash(StashTabCurrency)
					LeftClick(WR.loc.pixel.CurrencyGeneral.X, WR.loc.pixel.CurrencyGeneral.Y)
					StockX := WR.loc.pixel[v.RestockName].X
					StockY := WR.loc.pixel[v.RestockName].Y
				}
				ClipItem(StockX, StockY)
				; Store the stash stack size
				StashCount := Item.Prop.Stack_Size
				; Determine if we need to add or subtract
				If (InvCount > v.RestockTo) {
					dif := InvCount - v.RestockTo
					ShiftClick(o.X, o.Y)
					Sleep, 90*Latency
					Send %dif%
					Sleep, 90*Latency
					Send {Enter}
					Sleep, 120*Latency
					LeftClick(StockX, StockY)
					Sleep, 120*Latency
				} Else {
					dif := v.RestockTo - InvCount
					If (StashCount < dif) {
						Notify("Out of Stock","Attempting to restock " v.RestockName " but not enough in stock",2)
						Continue
					} Else If (dif = 0) {
						Continue
					}
					ShiftClick(StockX, StockY)
					Sleep, 90*Latency
					Send %dif%
					Sleep, 90*Latency
					Send {Enter}
					Sleep, 120*Latency
					LeftClick(o.X, o.Y)
					Sleep, 120*Latency
				}
			}
		}
	}
	BlockInput, MouseMoveOff
	return
}
addToBlacklist(C, R){
	Loop % Item.Prop.Item_Height
	{
		addNum := A_Index - 1
		addR := R + addNum
		addC := C + 1
		If !IsObject(BlackList[C])
			BlackList[C] := []
		BlackList[C][addR] := True
		If Item.Prop.Item_Width = 2
		{
			If !IsObject(BlackList[addC])
				BlackList[addC] := []
			BlackList[addC][addR] := True
		}
	}
}
