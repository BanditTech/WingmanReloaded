; Crafting Section - main routine and all subroutines and popup
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Crafting(selection:="Maps"){
	; Thread, NoTimers, True
	MouseGetPos xx, yy
	CheckRunning()
	If GameActive
	{
		CheckRunning("On")
		GuiStatus()
		If (!OnChar)
		{
			Notify("You do not appear to be in game.","Likely need to calibrate Character Active",1)
			CheckRunning("Off")
			Return
		}
		; Begin Crafting Script
		Else
		{
			If (!OnStash && YesEnableAutomation)
			{
				; If don't find stash, return
				If !SearchStash()
				{
					CheckRunning("Off")
					Return
				}
				Else
					RandomSleep(90,90)
			}
			; Open Inventory if is closed
			If (!OnInventory && OnStash)
			{
				SendHotkey(hotkeyInventory)
				RandomSleep(45,45)
				GuiStatus()
				RandomSleep(45,45)
			}
			If (OnInventory && OnStash)
			{
				RandomSleep(45,45)
				CurrentTab := 0
				MoveStash(StashTabCurrency)
				If indexOf(selection,["Maps","Socket","Color","Link","Chance","Item"])
					Crafting%selection%()
				Else
					Notify("Unknown Result is:",selection,2)
			}
			Else
			{
				; Exit Routine
				CheckRunning("Off")
				Return
			}
		}
	}
	MouseMove %xx%, %yy%
	CheckRunning("Off")
	Return
}
; CraftingChance - Use the settings to apply chance to item(s) until unique
CraftingChance(){
	Global
	local f
	; Notify("Chance Logic Coming Soon","",2)
	f := New Craft("Chance",BasicCraftChanceMethod,{Scour:BasicCraftChanceScour})
}
; CraftingColor - Use the settings to apply Chromatic Orb to item(s) until proper colors
CraftingColor(){
	Global
	local f
	f := New Craft("Color",BasicCraftColorMethod,{R:BasicCraftR,G:BasicCraftG,B:BasicCraftB})
}
; CraftingLink - Use the settings to apply Fusing to item(s) until minimum links
CraftingLink(){
	Global
	local f
	f := New Craft("Link",BasicCraftLinkMethod,{Links:BasicCraftDesiredLinks,Auto:BasicCraftLinkAuto})
}
; CraftingSocket - Use the settings to apply Jewellers to item(s) until minimum sockets
CraftingSocket(){
	Global
	local f
	f := New Craft("Socket",BasicCraftSocketMethod,{Sockets:BasicCraftDesiredSockets,Auto:BasicCraftSocketAuto})
}
CraftingItemCaller(){
	Crafting("Item")
}

ItemCraftingBaseComparator(base1,base2){
	base1 := RegExReplace(base1,"\(.+\)", "")
	base1 := RegExReplace(base1,"Cobalt Jewel|Viridian Jewel|Crimson Jewel", "Jewels")
	base1 := RegExReplace(base1,"Ghastly Eye|Hypnotic Eye|Searching Eye|Murderous Eye", "Abyss")
	base1 := RegExReplace(base1,"Staff", "Staves")
	base1 := RegExReplace(base1,"Warstaff", "Warstaves")
	base1 := RegExReplace(base1,"SCJ", "Small Cluster Jewel")
	base1 := RegExReplace(base1,"MCJ", "Medium Cluster Jewel")
	base1 := RegExReplace(base1,"LCJ", "Large Cluster Jewel")
	base1 := RegExReplace(base1,"Awakened|Elevated", "Atlas Upgrade Items")
	base1 := RegExReplace(base1,"([^s])$", "$1s")
	result := base1 ~= base2
	Log("Item Crafting Base Comparison ","Evaluating " base1 " and " base2 " returned " (result?"True":"False"))
	return result
}

CraftingItem(){
	Global RunningToggle
	MouseGetPos xx, yy
	If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
		Return
	; Move mouse away for Screenshot
	ShooMouse(), GuiStatus(), ClearNotifications()
	If (ItemCraftingBaseSelector ~= "Awakened|Elevated") {
		CurrencyList := []
		CurrencyList.Push(ItemCraftingBaseSelector)
	} Else {
		CurrencyList := []
		If (ItemCraftingMethod ~= "Alteration")
			CurrencyList.Push("Alteration")
		If (ItemCraftingMethod ~= "Aug")
			CurrencyList.Push("Augmentation")
		If (ItemCraftingMethod ~= "Regal")
			CurrencyList.Push("Regal")
		If (ItemCraftingMethod ~= "Scouring")
			CurrencyList.Push("Scouring")
		If (ItemCraftingMethod ~= "Alchemy")
			CurrencyList.Push("Alchemy")
		If (ItemCraftingMethod ~= "Chaos")
			CurrencyList.Push("Chaos")
	}
	WR.data.Counts := CountCurrency(CurrencyList)
	MouseMove %xx%, %yy%
	Sleep, 150
	ClipItem(xx,yy)
	Log("[Start] Item Crafting ","Initial Clip",JSON.Dump(Item))
	Sleep, 45*Latency

	If (!ItemCraftingBaseComparator(ItemCraftingBaseSelector,Item.Prop.ItemClass)) {
		Notify("Item Base Error","You Need Select or Use Same Base as Mod Selector",4)
		Log("[End]Item Crafting - Item Crafting Error","You Need Select or Use Same Base as Mod Selector")
		Return
	}
	If !(ItemCraftingBaseSelector ~= "Awakened|Elevated")
	&& (WR.ItemCrafting[ItemCraftingBaseSelector].Count() == 0) {
		Notify("Mod Selector Empty","You Need Select at Least 1 Affix on Mod Selector",4)
		Log("[End]Item Crafting - Item Crafting Error","You Need Select at Least 1 Affix on Mod Selector")
		Return
	} Else If (ItemCraftingBaseSelector ~= "Awakened|Elevated")
	&& (WR.CustomSextantMods.SextantMods.Count() <= 0) {
		Notify("Sextant Mod Selector Empty","You Need Select at Least 1 Affix on Sextant Mod Selector",4)
		Log("[End]Item Crafting - Sextant Crafting Error","You Need Select at Least 1 Affix on Sextant Mod Selector")
		Return
	}
	If !(ItemCraftingBaseSelector ~= "Awakened|Elevated")
	&& (ItemCraftingNumberPrefix == 0 && ItemCraftingNumberSuffix == 0 && ItemCraftingNumberCombination == 0) {
		Notify("Affix Matcher Error","You Need Select at least one Prefix or Suffix or Combination",4)
		Log("[End]Item Crafting - Item Crafting Error","You Need Select at least one Prefix or Suffix or Combination")
		Return
	}
	If !(ItemCraftingBaseSelector ~= "Awakened|Elevated")
	&& (!Item.Prop.RarityNormal && (Item.Prop.AffixCount == 0 && Item.Prop.PrefixCount == 0 && Item.Prop.SuffixCount == 0)) {
		Notify("Missing Advanced Tooltip","The default solution is unbind ALT Key from POE hotkeys as they prevent from using CTRL+ALT+C to get advanced clip information for parsin")
		Log("Missing Advanced Tooltip","Clip Item Function cannot detect item prefix/suffix","The default solution is unbind ALT Key from POE hotkeys as they prevent from using CTRL+ALT+C to get advanced clip information for parsing")
		Return
	}
	If (ItemCraftingBaseSelector ~= "Awakened|Elevated") && (GrabCompassX <= 0) or (GrabCompassY <=0) {
		Notify("Missing Surveyor's Compass Location","You must setup the co-ordinates in your currency tab before you can craft with sextants")
		Log("Missing Surveyor's Compass Location","You must setup the co-ordinates in your currency tab before you can craft with sextants")
		Return
	}
	If (ItemCraftingBaseSelector ~= "Awakened|Elevated") {
		SextantCraftingRoll(ItemCraftingBaseSelector,xx,yy)
	}Else If(ItemCraftingMethod == "Alteration Spam"){
		If(ItemCraftingNumberPrefix > 1 || ItemCraftingNumberSuffix > 1 || ItemCraftingNumberCombination > 2){
			Notify("Magic Item Mismatch","Magic Itens Roll can only have 1 Prefix and 1 Suffix",4)
			Log("[End]Item Crafting - Item Crafting Error","Magic Itens Roll can only have 1 Prefix and 1 Suffix")
			Return
		}
		ItemCraftingRoll("Alt", xx, yy)
	}Else If(ItemCraftingMethod == "Alteration and Aug Spam"){
		If(ItemCraftingNumberPrefix > 1 || ItemCraftingNumberSuffix > 1 || ItemCraftingNumberCombination > 2){
			Notify("Magic Item Mismatch","Magic Itens Roll can only have 1 Prefix and 1 Suffix",4)
			Log("[End]Item Crafting - Item Crafting Error","Magic Itens Roll can only have 1 Prefix and 1 Suffix")
			Return
		}
		ItemCraftingRoll("AltAug", xx, yy)
	}Else If(ItemCraftingMethod == "Alteration and Aug and Regal Spam"){
		If(((ItemCraftingNumberPrefix + ItemCraftingNumberSuffix) > 3) || ItemCraftingNumberCombination > 3){
			Notify("Magic Item Mismatch","Magic Itens with Regal Orb can only have 3 Mods",4)
			Log("[End]Item Crafting - Item Crafting Error","Magic Itens with Regal Orb can only have 3 Mods")
			Return
		}
		ItemCraftingRoll("AltAugRegal", xx, yy)
	}Else If(ItemCraftingMethod == "Scouring and Alchemy Spam"){
		ItemCraftingRoll("AlcSco", xx, yy)
	}Else If(ItemCraftingMethod == "Chaos Spam"){
		ItemCraftingRoll("Chaos", xx, yy)
	}
	Return
}
; CraftingMaps - Scan the Inventory for Maps and apply currency based on method select in Crafting Settings
CraftingMaps(){
	Global RunningToggle
	; Move mouse away for Screenshot
	ShooMouse(), GuiStatus(), ClearNotifications()
	; Ignore Slot
	BlackList := Array_DeepClone(BlackList_Default)
	WR.data.Counts := CountCurrency(["Alchemy","Binding","Transmutation","Scouring","Vaal","Chisel","Augmentation","Awakened","Elevated"])
	; MsgBoxVals(WR.data.Counts)
	MapList := {}
	; Start Scan on Inventory
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
			If indexOf(PointColor, varEmptyInvSlotColor)
			{
				;Seems to be an empty slot, no need to clip item info
				Continue
			}
			; Identify Items routines
			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			If (Item.Affix["Unidentified"]&&YesIdentify)
			{
				If ( (Item.Prop.IsMap || Item.Prop.IsBlightedMap) && (!YesMapUnid || ( Item.Prop.RarityMagic && ( getMapCraftingMethod() ~= "(Alchemy|Hybrid|Binding)" ))) && !Item.Prop.Corrupted)
				{
					WisdomScroll(Grid.X,Grid.Y)
					ClipItem(Grid.X,Grid.Y)
				}
				Else If CheckToIdentify()
				{
					WisdomScroll(Grid.X,Grid.Y)
					ClipItem(Grid.X,Grid.Y)
				}
			}
			;Crafting Map Script
			If ((Item.Prop.IsMap || Item.Prop.IsBlightedMap) && !Item.Prop.Corrupted && !Item.Prop.RarityUnique)
			{
				If (Item.Prop.Map_Quality < 20)
					If (ForceMaxChisel) {
						numberChisel := Ceil((20 - Item.Prop.Map_Quality)/5)
					} Else {
						numberChisel := (20 - Item.Prop.Map_Quality)//5
					}
				Else
					numberChisel := 0
				;Check all 3 ranges tier with same logic
				i = 0
				Loop, 3
				{
					i++
					If (EndMapTier%i% >= StartMapTier%i% && CraftingMapMethod%i% != "Disable" && Item.Prop.Map_Tier >= StartMapTier%i% && Item.Prop.Map_Tier <= EndMapTier%i%)
					{
						If (!Item.Prop.RarityNormal)
						{
							If ( (Item.Prop.RarityMagic && CraftingMapMethod%i% == "Transmutation+Augmentation") || (Item.Prop.RarityRare && (CraftingMapMethod%i% == "Transmutation+Augmentation" || CraftingMapMethod%i% ~= "(^Alchemy$|^Binding$|^Hybrid$)")) || (Item.Prop.RarityRare && Item.Prop.Quality >= 16 && CraftingMapMethod%i% ~= "(Alchemy|Binding|Hybrid)") )
							{
								MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
								If (CraftingMapMethod%i% ~= "Vaal$")
									ApplyCurrency("Vaal",Grid.X,Grid.Y)
								Continue
							}
							Else
							{
								If !ApplyCurrency("Scouring",Grid.X,Grid.Y)
									Return False
							}
						}
						If (Item.Prop.RarityNormal)
						{
							If (CraftingMapMethod%i% ~= "^Chisel")
								If !ApplyCurrency("Chisel",Grid.X,Grid.Y,numberChisel)
								Return False
							MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
							If (CraftingMapMethod%i% ~= "Vaal$")
								ApplyCurrency("Vaal",Grid.X,Grid.Y)
						}
					}
				}
			} Else If (indexOf(Item.Prop.ItemClass,["Blueprints","Contracts"]) && HeistAlcNGo) {
				If (Item.Prop.RarityMagic)
					ApplyCurrency("Scouring",Grid.X,Grid.Y)
				If (Item.Prop.RarityNormal)
					ApplyCurrency("Hybrid",Grid.X,Grid.Y)
			}
			If (MoveMapsToArea && (Item.Prop.IsMap || Item.Prop.IsBlightedMap || Item.Prop.MapPrep || Item.Prop.MapLikeItem) && !InMapArea(C))
				MapList[C " " R] := {X:Grid.X,Y:Grid.Y}
		}
	}
	If (MoveMapsToArea && RunningToggle){
		Slots := EmptyGrid()
		For k, obj in MapList {
			If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If Slots.Count() {
				split := StrSplit(k," ")
				C := split.1
				R := split.2
				gogo := Slots.Pop()
				LeftClick(obj.X,obj.Y)
				Sleep, 180 + (15 * ClickLatency)
				LeftClick(gogo.X,gogo.Y)
				Sleep, 120 + (15 * ClickLatency)
			}	Else
			Break
		}
	}
	Return
}
InMapArea(C:=0){
	If (C <= 0)
		Return False
	If (C >= YesSkipMaps && YesSkipMaps_eval = ">=")
		|| (C <= YesSkipMaps && YesSkipMaps_eval = "<=")
	Return True
	Return False
}
getMapCraftingMethod(){
	Loop, 3
	{
		If ( EndMapTier%A_Index% >= StartMapTier%A_Index%
				&& CraftingMapMethod%A_Index% != "Disable"
			&& Item.Prop.Map_Tier >= StartMapTier%A_Index%
		&& Item.Prop.Map_Tier <= EndMapTier%A_Index% )
		Return CraftingMapMethod%A_Index%
	}
	Return False
}
; Find the stack sizes of all relevant currency, returns count object
CountCurrency(NameList:=""){
	retCount := {}
	If (NameList = "")
		Return False
	If !IsObject(NameList)
		NameList := StrSplit(NameList,",")
	For key, currency in NameList {
		If !WR.loc.pixel.HasKey(currency)
			Return False
		If (WR.loc.pixel[currency].X = 0 && WR.loc.pixel[currency].Y = 0) {
			Notify("Position Error","Aspect ratio is missing adjustment for " currency " slot`nPlease submit the correct position on github for your aspect ratio",5)
			retCount[currency] := 0
		} Else {
			ClipItem(WR.loc.pixel[currency].X,WR.loc.pixel[currency].Y)
			retCount[currency] := Item.Prop.Stack_Size ? Item.Prop.Stack_Size : 0
		}
	}
	Return retCount.Count() ? retCount : False
}
; ApplyCurrency - Using cname = currency name string and x, y as apply position
ApplyCurrency(cname, x, y, Amount:=1){
	If (Amount < 1)
		Return True
	If (cname = "Hybrid") {
		If (WR.data.Counts.Binding >= WR.data.Counts.Alchemy)
			cname := "Binding"
		Else
			cname := "Alchemy"
	}
	If WR.data.Counts.HasKey(cname) {
		If (WR.data.Counts[cname] <= 0) {
			Log("Error","Not enough " cname " to continue crafting")
			Return False
		}
		WR.data.Counts[cname]--
	}
	Log("Currency","Applying " cname " onto item at " x "," y)
	RightClick(WR.loc.pixel[cname].X, WR.loc.pixel[cname].Y)
	Sleep, 45*Latency
	If (Amount > 1) {
		Send, {Shift down}
		RandomSleep(30,45)
	}
	Loop, %Amount% {
		LeftClick(x,y)
		RandomSleep(30,45)
	}
	If (Amount > 1) {
		Send, {Shift up}
		RandomSleep(30,45)
	}
	Sleep, 90*Latency
	ClipItem(x,y)
	Sleep, 45*Latency
	return True
}
; MapRoll - Apply currency/reroll on maps based on select undesireable mods
MapRoll(Method, x, y){
	If (Method == "Transmutation+Augmentation")
	{
		cname := "Transmutation"
		crname := "Alteration"
	}
	Else If (Method ~= "Alchemy")
	{
		cname := "Alchemy"
		crname := "Scouring"
	}
	Else If (Method ~= "Binding")
	{
		cname := "Binding"
		crname := "Scouring"
	}
	Else If (Method ~= "Hybrid")
	{
		If (WR.data.Counts.Binding >= WR.data.Counts.Alchemy)
			cname := "Binding"
		Else
			cname := "Alchemy"
		crname := "Scouring"
	}
	Else
	{
		return
	}
	If (Item.Affix["Unidentified"])
	{
		If (Item.Prop.Rarity_Digit > 1 && cname = "Transmutation" && YesMapUnid )
		{
			Return
		}
		Else If (Item.Prop.Rarity_Digit > 2 && cname = "Alchemy" && YesMapUnid )
		{
			Return
		}
		Else If (Item.Prop.Rarity_Digit > 2 && cname = "Binding" && YesMapUnid )
		{
			Return
		}
		Else
		{
			WisdomScroll(x,y)
			ClipItem(x,y)
			Sleep, 45*Latency
		}
	}
	; Apply Currency if Normal
	If (Item.Prop.RarityNormal)
	{
		If !ApplyCurrency(cname, x, y)
			Return False
	}
	If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic && cname = "Transmutation")
	{
		If !ApplyCurrency("Augmentation",x,y)
			Return False
	}
	BelowRarity := Item.Prop.Map_Rarity < MMapItemRarity
	BelowPackSize := Item.Prop.Map_PackSize < MMapMonsterPackSize
	BelowQuantity := Item.Prop.Map_Quantity < MMapItemQuantity
	; Corrupted White Maps can break the function without !Item.Prop.Corrupted in loop
	While (!Item.Affix["Unidentified"] && !Item.Prop.Corrupted && Item.Prop.MapRerollFlag)
	{
		If (!RunningToggle) {
			break
		}
		If(!Item.Prop.RarityNormal && (Item.Prop.AffixCount == 0 && Item.Prop.PrefixCount == 0 && Item.Prop.SuffixCount == 0)){
			Notify("Missing Advanced Tooltip","The default solution is unbind ALT Key from POE hotkeys as they prevent from using CTRL+ALT+C to get advanced clip information for parsin")
			Log("Missing Advanced Tooltip","Clip Item Function cannot detect item prefix/suffix","The default solution is unbind ALT Key from POE hotkeys as they prevent from using CTRL+ALT+C to get advanced clip information for parsing")
			Return
		}
		Log("Crafting","Map reroll initiated because:"
			. (Item.Prop.RarityNormal?" Normal Item":"")
			. (Item.Prop.MapImpossibleMod?" Has Impossible Mod":"")
			. (Item.Prop.MapSumMod < MMapWeight?  " " Item.Prop.MapSumMod " Sum Weight < " MMapWeight " Minimum Weight":"")
		, "Minimum Map Qualities: "(Item.Prop.Map_Rarity < MMapItemRarity?" Below " MMapItemRarity " Rarity: " Item.Prop.Map_Rarity ",": " Adequate Rarity,")
			. (Item.Prop.Map_PackSize < MMapMonsterPackSize?" Below " MMapMonsterPackSize " PackSize: " Item.Prop.Map_PackSize ",": " Adequate PackSize,")
			. (Item.Prop.Map_Quantity < MMapItemQuantity?" Below " MMapItemQuantity " Quantity: " Item.Prop.Map_Quantity : " Adequate Quantity")
		,JSON.Dump(Item) )
		; Scouring or Alteration
		If !ApplyCurrency(crname, x, y)
			Return False
		If (Item.Prop.RarityNormal) {
			If !ApplyCurrency(cname, x, y)
				Return False
		; Augmentation if not 2 mods on magic maps
		} Else If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic) {
			If !ApplyCurrency("Augmentation",x,y)
				Return False
		}
		BelowRarity := Item.Prop.Map_Rarity < MMapItemRarity
		BelowPackSize := Item.Prop.Map_PackSize < MMapMonsterPackSize
		BelowQuantity := Item.Prop.Map_Quantity < MMapItemQuantity
	}
	Log("Crafting","Map crafting resulted in a"
		. (Item.Prop.RarityNormal?" Normal Map":"")
		. (Item.Prop.RarityMagic?" Magic Map":"")
		. (Item.Prop.RarityRare?" Rare Map":"")
		. (Item.Prop.MapSumMod >= MMapWeight?" with sum Mod weight of " Item.Prop.MapSumMod :"")
		. (Item.Prop.IsBricked?" with Bricked Mods":"")
		, "Map is" (Item.Prop.Map_Rarity < MMapItemRarity?" Below " MMapItemRarity " Rarity: " Item.Prop.Map_Rarity ",":" Adequate Rarity,")
		. (Item.Prop.Map_PackSize < MMapMonsterPackSize?" Below " MMapMonsterPackSize " PackSize: " Item.Prop.Map_PackSize ",":" Adequate PackSize,")
		. (Item.Prop.Map_Quantity < MMapItemQuantity?" Below " MMapItemQuantity " Quantity: " Item.Prop.Map_Quantity :" Adequate Quantity")
	,JSON.Dump(Item) )
	Return 1
}
ItemCraftingRoll(Method, x, y){
	desirednumber := ItemCraftingNumberPrefix + ItemCraftingNumberSuffix + ItemCraftingNumberCombination
	If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
		Return
	If (Method == "Alt")
	{
		cname := "Transmutation"
		crname := "Alteration"
	}
	Else If (Method == "AltAug")
	{
		cname := "Transmutation"
		crname := "Alteration"
	}
	Else If (Method == "AltAugRegal")
	{
		cname := "Transmutation"
		crname := "Alteration"
		cr2name := "Scouring"
	}
	Else If (Method == "AlcSco")
	{
		cname := "Alchemy"
		crname := "Scouring"
	}
	Else If (Method == "Chaos")
	{
		cname := "Alchemy"
		crname := "Chaos"
	}
	Else
	{
		Return
	}
	If (Item.Affix["Unidentified"])
	{
		WisdomScroll(x,y)
		ClipItem(x,y)
		Sleep, 45*Latency
	}
	While (!Item.Prop.ItemCraftingHit){
		If not RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		If (Item.Prop.RarityNormal)
		{
			If !ApplyCurrency(cname, x, y)
				Return False
		}
		Else If (Item.Prop.RarityMagic) {
			If (Method ~= "AltAug" && Item.Prop.AffixCount < 2 && !(Item.Prop.CraftingMatchedPrefix > 0 || Item.Prop.CraftingMatchedSuffix > 0) && (desirednumber <= 1) ) {
				If !ApplyCurrency("Augmentation",x,y)
					Return False
			} Else If (Method ~= "AltAug" && Item.Prop.AffixCount < 2 && (Item.Prop.CraftingMatchedPrefix > 0 || Item.Prop.CraftingMatchedSuffix > 0)) {
				If !ApplyCurrency("Augmentation",x,y)
					Return False
			} Else If (Method ~= "Regal" && Item.Prop.CraftingMatchedPrefix == 1 && Item.Prop.CraftingMatchedSuffix == 1) {
				If !ApplyCurrency("Regal",x,y)
					Return False
			}	Else {
				If !ApplyCurrency(crname, x, y)
					Return False
			}
		}
		Else If (Item.Prop.RarityRare){
			If(Method ~= "Regal")
			{
				If !ApplyCurrency(cr2name, x, y)
						Return False
			}
			Else
			{
				If !ApplyCurrency(crname, x, y)
					Return False
			}
		}
		Log("Item Crafting Loop ","Item result has "
		. Item.Prop.CraftingMatchedPrefix " Matched Prefix and "
		. Item.Prop.CraftingMatchedSuffix " Matched Suffix"
		,JSON.Dump(Item) )

	}
	If (Item.Prop.ItemCraftingHit) {
		Notify("Item Crafting Notification","Sucess!! Please Report Bugs in GitHub or Discord",3)
		Log("[End]Item Crafting - Sucess ","End Routine")
	}

	Return
}
SextantCraftingRoll(Method, x, y){
	If (SextantCraftingMethod == 1) {
		While (WR.data.Counts[Method] > 0) {
			If !RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
			Break
			ClipItem(GrabCompassX,GrabCompassY)
			If (Item.Prop.Stack_Size < 1){
				Log("Sextant Crafting Loop ", "No compass available to seal the sextant")
				Break
			}
			EmptySlots := EmptyGrid()
			If (EmptySlots.Count() = 0) {
				Log("Sextant Crafting Loop ", "No inventory slot available for compass")
				Break
			}
			Log("Sextant Crafting Loop ", "Starting with:"
				, WR.data.Counts[Method] " Sextants available"
				, Item.Prop.Stack_Size " Compass available"
				, EmptySlots.Count() " Inventory slots available")

			While (!Item.Prop.SextantCraftingHit) {
				If !RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
					Break
				If !ApplyCurrency(Method,x,y) ; Ran out of sextants so end loop
					Break
				Log("Sextant Crafting Loop ", "Sextant result has " (Item.Prop.SextantFlag?Item.Prop.SextantFlag:"no Good or Bad") " Mod", Item)
			}
			If (Item.Prop.SextantCraftingHit) {
				Log("Sextant Crafting Loop ", "Hit a match, saving sextant with compass")
				If (OnInventory && OnStash) {
					EmptySlot := EmptySlots.Pop()
					RightClick(GrabCompassX, GrabCompassY)
					RandomSleep(75,75)
					LeftClick(x, y)
					RandomSleep(45,45)
					LeftClick(EmptySlot.X,EmptySlot.Y)
					RandomSleep(75,75)
				} Else {
					Log("[End]Sextant Crafting - Inventory or Stash closed ","End Routine")
					Break
				}
			} Else {
				Log("[End]Sextant Crafting Loop ", "No Sextant available for crafting", "End Routine")
				Break
			}
		}
	} Else If (SextantCraftingMethod == 2) {
		While (!Item.Prop.SextantCraftingHit) {
			If !RunningToggle ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If !ApplyCurrency(Method,x,y) { ; Ran out of sextants so end loop
				Log("[End]Sextant Crafting Loop ", "No Sextant available for crafting", "End Routine")
				Break
			}
			Log("Sextant Crafting Loop ", "Sextant result has " (Item.Prop.SextantFlag?Item.Prop.SextantFlag:"no Good or Bad") " Mod", Item)
		}
	}
	Log("[End]Sextant Crafting ","End Routine")
	Return
}