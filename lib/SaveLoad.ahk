readFromFile(){
	Global ProfileMenuperChar, ProfileMenuFlask, ProfileMenuUtility
		, AccountNameSTR, PoECookie, WinGuiX, WinGuiY
		, BranchName, ScriptUpdateTimeInterval, ScriptUpdateTimeType
		, Speed, Tick, KeyscanRate, QTick
		, DebugMessages, YesTimeMS, YesLocation, ShowPixelGrid, ShowItemInfo
		, LootVacuum, LootVacuumTapZ, LootVacuumTapZEnd, LootVacuumTapZSec
		, YesVendor, YesStash, YesIdentify, YesDiv
		, YesMapUnid, YesInfluencedUnid, YesSynthesisId, YesCLFIgnoreImplicit, YesSortFirst
		, Latency, ClickLatency, ClipLatency, ShowOnStart, PopFlaskRespectCD
		, ResolutionScale, AutoUpdateOff, EnableChatHotkeys, CharName
		, YesStashKeys, YesGuiLastPosition, YesDX12
		, YesSkipMaps, YesSkipMaps_Prep, YesSkipMaps_eval
		, YesSkipMaps_normal, YesSkipMaps_magic, YesSkipMaps_rare, YesSkipMaps_unique, YesSkipMaps_tier
		, AreaScale, LVdelay, YesLootChests, YesLootDelve
		, YesStashChaosRecipe, YesInGameOverlay, YesChaosOverlay
		, YesBatchVendorBauble, YesBatchVendorGCP, BrickedWhenCorrupted
		, YesOpenStackedDeck, YesOpenVeiledScarab, YesSpecial5Link
		, YesVendorDumpItems, HeistAlcNGo, MoveMapsToArea, YesIncludeFandSItem, EnableRestock
		, CLFStrictnessNumber
		, BasicCraftChanceMethod, BasicCraftChanceScour, BasicCraftColorMethod
		, BasicCraftR, BasicCraftG, BasicCraftB
		, BasicCraftLinkMethod, BasicCraftDesiredLinks, BasicCraftLinkAuto
		, BasicCraftSocketMethod, BasicCraftDesiredSockets, BasicCraftSocketAuto
		, YesStashBasesAboveIlvl, StashBasesAboveIlvl
		, YesCraftingBaseAutoUpdateOnStart, YesCraftingBaseAutoUpdateOnZone
		, YesCraftingBaseLimitBases, CraftingBaseLimitBasesNumber
		, ItemCraftingSubCategorySelector, ItemCraftingCategorySelector
		, ItemCraftingNumberPrefix, ItemCraftingNumberSuffix, ItemCraftingNumberCombination, ItemCraftingMethod
		, StartMapTier1, StartMapTier2, StartMapTier3
		, EndMapTier1, EndMapTier2, EndMapTier3
		, CraftingMapMethod1, CraftingMapMethod2, CraftingMapMethod3
		, MMapItemQuantity, MMapItemRarity, MMapMonsterPackSize
		, EnableMQQForMagicMap, MMQorWeight, MMapWeight, ForceMaxChisel
		, YesEnableAutomation, FirstAutomationSetting, YesEnableNextAutomation
		, YesEnableAutoSellConfirmation, YesEnableAutoSellConfirmationSafe
		, StashTabCurrency, StashTabYesCurrency, StashTabMap, StashTabYesMap
		, StashTabDivination, StashTabYesDivination, StashTabGem, StashTabYesGem
		, StashTabFlask, StashTabYesFlask, StashTabFragment, StashTabYesFragment
		, StashTabEssence, StashTabYesEssence, StashTabBlight, StashTabYesBlight
		, StashTabDelirium, StashTabYesDelirium, StashTabDelve, StashTabYesDelve
		, StashTabUltimatum, StashTabYesUltimatum, StashTabUnique, StashTabYesUnique
		, StashTabUniqueRing, StashTabYesUniqueRing, StashTabUniqueDump, StashTabYesUniqueDump
		, StashTabYesUniquePercentage, StashTabUniquePercentage
		, StashTabYesUniqueRingAll, StashTabYesUniqueDumpAll
		, StashTabVeiled, StashTabYesVeiled, StashTabClusterJewel, StashTabYesClusterJewel
		, StashTabHeistGear, StashTabYesHeistGear, StashTabMiscMapItems, StashTabYesMiscMapItems
		, StashTabLinked, StashTabYesLinked, StashTabBrickedMaps, StashTabYesBrickedMaps
		, StashTabInfluencedItem, StashTabYesInfluencedItem
		, StashTabRunes, StashTabYesRunes, StashTabTattoos, StashTabYesTattoos
		, StashTabCrafting, StashTabYesCrafting, StashTabDump, StashTabYesDump
		, StashTabPredictive, StashTabYesPredictive, StashTabNinjaPrice, StashTabYesNinjaPrice
		, StashDumpInTrial, StashDumpSkipJC, StashTabYesNinjaPrice_Price
		, ChaosRecipeEnableFunction, ChaosRecipeUnloadAll, ChaosRecipeSkipJC
		, ChaosRecipeEnableUnId, ChaosRecipeSmallWeapons, ChaosRecipeLimitUnId
		, ChaosRecipeAllowDoubleJewellery, ChaosRecipeAllowDoubleBelt
		, ChaosRecipeMaxHoldingID, ChaosRecipeMaxHoldingUNID
		, ChaosRecipeTypePure, ChaosRecipeTypeHybrid, ChaosRecipeTypeRegal
		, ChaosRecipeStashMethodDump, ChaosRecipeStashMethodTab, ChaosRecipeStashMethodSort
		, ChaosRecipeStashTab, ChaosRecipeStashTabWeapon, ChaosRecipeStashTabHelmet
		, ChaosRecipeStashTabArmour, ChaosRecipeStashTabGloves, ChaosRecipeStashTabBoots
		, ChaosRecipeStashTabBelt, ChaosRecipeStashTabAmulet, ChaosRecipeStashTabRing
		, ClientLog, YesOHB, OHBLHealthHex, OHBStrW
		, HealthBarStr, ChestStr, DelveStr, VendorStr, SellItemsStr, StashStr, SkillUpStr, XButtonStr
		, VendorLioneyeStr, VendorForestStr, VendorSarnStr, VendorHighgateStr
		, VendorOverseerStr, VendorBridgeStr, VendorDocksStr, VendorOriathStr
		, VendorHarbourStr, VendorKingsmarchStr, VendorMineStr
		, debuffCurseEleWeakStr, debuffCurseVulnStr, debuffCurseEnfeebleStr
		, debuffCurseTempChainStr, debuffCurseCondStr, debuffCurseFlamStr
		, debuffCurseFrostStr, debuffCurseWarMarkStr, debuffShockStr
		, debuffBleedStr, debuffFreezeStr, debuffIgniteStr, debuffPoisonStr, debuffCurseStr
		, varEmptyInvSlotColor, LootColors
		, varOnMenu, varOnChar, varOnChat, varOnInventory, varOnStash, varOnVendor
		, varOnVendorHeist, varOnDiv, varOnLeft, varOnDelveChart, varOnDetonate, varOnDetonateDelve
		, GrabCurrencyX, GrabCurrencyY
		, hotkeyOptions, hotkeyAutoQuit, hotkeyAutoFlask, hotkeyAutoMove, hotkeyAutoUtility
		, hotkeyQuickPortal, hotkeyStartCraft, hotkeyItemCrafting, hotkeyCraftBasic
		, hotkeyGemSwap, hotkeyGrabCurrency, hotkeyGetMouseCoords
		, hotkeyPopFlasks, hotkeyLogout, hotkeyCloseAllUI, hotkeyInventory, hotkeyWeaponSwapKey
		, hotkeyItemSort, hotkeyItemInfo, hotkeyChaosRecipe, hotkeyLootScan
		, hotkeyDetonateMines, hotkeyOpenPortal, hotkeyPauseMines
		, hotkeyMainAttack, hotkeySecondaryAttack, hotkeyTriggerMovement
		, hotkeyCtrlClicker, hotkeyCtrlShiftClicker, hotkeyShiftClicker
		, c1Prefix1, c1Prefix2, c1Suffix1, c1Suffix2, c1Suffix3, c1Suffix4, c1Suffix5, c1Suffix6, c1Suffix7, c1Suffix8, c1Suffix9
		, c1Suffix1Text, c1Suffix2Text, c1Suffix3Text, c1Suffix4Text, c1Suffix5Text
		, c1Suffix6Text, c1Suffix7Text, c1Suffix8Text, c1Suffix9Text
		, c2Prefix1, c2Prefix2, c2Suffix1, c2Suffix2, c2Suffix3, c2Suffix4, c2Suffix5, c2Suffix6, c2Suffix7, c2Suffix8, c2Suffix9
		, c2Suffix1Text, c2Suffix2Text, c2Suffix3Text, c2Suffix4Text, c2Suffix5Text
		, c2Suffix6Text, c2Suffix7Text, c2Suffix8Text, c2Suffix9Text
		, stashPrefix1, stashPrefix2
		, stashSuffix1, stashSuffix2, stashSuffix3, stashSuffix4, stashSuffix5
		, stashSuffix6, stashSuffix7, stashSuffix8, stashSuffix9
		, stashSuffixTab1, stashSuffixTab2, stashSuffixTab3, stashSuffixTab4, stashSuffixTab5
		, stashSuffixTab6, stashSuffixTab7, stashSuffixTab8, stashSuffixTab9
		, hotkeyControllerButtonA, hotkeyControllerButtonB, hotkeyControllerButtonX, hotkeyControllerButtonY
		, hotkeyControllerButtonLB, hotkeyControllerButtonRB
		, hotkeyControllerButtonBACK, hotkeyControllerButtonSTART
		, hotkeyControllerButtonL3, hotkeyControllerButtonR3, hotkeyControllerJoystickRight
		, YesTriggerUtilityKey, YesTriggerUtilityJoystickKey, YesTriggerJoystickRightKey
		, TriggerUtilityKey, YesMovementKeys, YesController, JoystickNumber
		, LastDatabaseParseDate, selectedLeague, UpdateDatabaseInterval, YesNinjaDatabase
		, ForceMatch6Link, ForceMatchGem20
		, fn1, fn2, fn3
	Thread("NoTimers", true) ;Critical

	LoadArray()
	Settings("Flask","Load")
	Settings("Utility","Load")
	Settings("perChar","Load")
	Settings("func","Load")
	; Settings("String","Load")
	Settings("CustomCraftingBases","Load")
	Settings("CustomMapMods","Load")
	Settings("ItemCrafting","Load")
	Settings("ActualTier","Load")

	ProfileMenuperChar := IniRead(A_ScriptDir "\save\Settings.ini", "Chosen Profile", "perChar", A_Space)
	ProfileMenuFlask := IniRead(A_ScriptDir "\save\Settings.ini", "Chosen Profile", "Flask", A_Space)
	ProfileMenuUtility := IniRead(A_ScriptDir "\save\Settings.ini", "Chosen Profile", "Utility", A_Space)

	; Login Information
	; AccountNameSTR := IniRead(A_ScriptDir "\save\Account.ini", "GGG", "PoECookie", A_Space)
	AccountNameSTR := IniRead(A_ScriptDir "\save\Account.ini", "GGG", "AccountNameSTR", A_Space)
	PoECookie := FileExist(A_ScriptDir "\save\Cookie.json")
		? JSON.LoadFile(A_ScriptDir "\save\Cookie.json").Cookie
		: ""

	; GUI Position
	WinGuiX := IniRead(A_ScriptDir "\save\Settings.ini", "General", "WinGuiX", 0)
	WinGuiY := IniRead(A_ScriptDir "\save\Settings.ini", "General", "WinGuiY", 0)

	;General settings
	BranchName := IniRead(A_ScriptDir "\save\Settings.ini", "General", "BranchName", "master")
	ScriptUpdateTimeInterval := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeInterval", 1)
	ScriptUpdateTimeType := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeType", "Off")
	Speed := IniRead(A_ScriptDir "\save\Settings.ini", "General", "Speed", 1)
	Tick := IniRead(A_ScriptDir "\save\Settings.ini", "General", "Tick", 50)
	KeyscanRate := IniRead(A_ScriptDir "\save\Settings.ini", "General", "KeyscanRate", 15)
	QTick := IniRead(A_ScriptDir "\save\Settings.ini", "General", "QTick", 250)
	DebugMessages := IniRead(A_ScriptDir "\save\Settings.ini", "General", "DebugMessages", 0)
	YesTimeMS := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesTimeMS", 0)
	YesLocation := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesLocation", 0)
	ShowPixelGrid := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ShowPixelGrid", 0)
	ShowItemInfo := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ShowItemInfo", 0)
	LootVacuum := IniRead(A_ScriptDir "\save\Settings.ini", "General", "LootVacuum", 0)
	LootVacuumTapZ := IniRead(A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZ", 1)
	LootVacuumTapZEnd := IniRead(A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZEnd", 1)
	LootVacuumTapZSec := IniRead(A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZSec", 3)
	YesVendor := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesVendor", 1)
	YesStash := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesStash", 1)
	YesIdentify := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesIdentify", 1)
	YesDiv := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesDiv", 1)
	YesMapUnid := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesMapUnid", 0)
	YesInfluencedUnid := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesInfluencedUnid", 0)
	YesSynthesisId := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSynthesisId", 1)
	YesCLFIgnoreImplicit := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesCLFIgnoreImplicit", 0)
	YesSortFirst := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSortFirst", 1)
	Latency := IniRead(A_ScriptDir "\save\Settings.ini", "General", "Latency", 1)
	ClickLatency := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ClickLatency", 0)
	ClipLatency := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ClipLatency", 0)
	ShowOnStart := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ShowOnStart", 1)
	PopFlaskRespectCD := IniRead(A_ScriptDir "\save\Settings.ini", "General", "PopFlaskRespectCD", 0)
	ResolutionScale := IniRead(A_ScriptDir "\save\Settings.ini", "General", "ResolutionScale", "Standard")
	AutoUpdateOff := IniRead(A_ScriptDir "\save\Settings.ini", "General", "AutoUpdateOff", 0)
	EnableChatHotkeys := IniRead(A_ScriptDir "\save\Settings.ini", "General", "EnableChatHotkeys", 1)
	CharName := IniRead(A_ScriptDir "\save\Settings.ini", "General", "CharName", "ReplaceWithCharName")
	EnableChatHotkeys := IniRead(A_ScriptDir "\save\Settings.ini", "General", "EnableChatHotkeys", 1)
	YesStashKeys := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesStashKeys", 1)
	YesGuiLastPosition := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesGuiLastPosition", 0)
	YesDX12 := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesDX12", 0)
	YesSkipMaps := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps", 11)
	YesSkipMaps_Prep := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_Prep", 1)
	YesSkipMaps_eval := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_eval", ">=")
	YesSkipMaps_normal := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_normal", 0)
	YesSkipMaps_magic := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_magic", 1)
	YesSkipMaps_rare := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_rare", 1)
	YesSkipMaps_unique := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_unique", 1)
	YesSkipMaps_tier := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_tier", 2)
	AreaScale := IniRead(A_ScriptDir "\save\Settings.ini", "General", "AreaScale", 60)
	LVdelay := IniRead(A_ScriptDir "\save\Settings.ini", "General", "LVdelay", 30)
	YesLootChests := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesLootChests", 1)
	YesLootDelve := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesLootDelve", 1)
	YesStashChaosRecipe := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesStashChaosRecipe", 0)
	YesInGameOverlay := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesInGameOverlay", 1)
	YesChaosOverlay := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesChaosOverlay", 1)
	YesBatchVendorBauble := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesBatchVendorBauble", 1)
	YesBatchVendorGCP := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesBatchVendorGCP", 1)
	BrickedWhenCorrupted := IniRead(A_ScriptDir "\save\Settings.ini", "General", "BrickedWhenCorrupted", 1)
	YesOpenStackedDeck := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesOpenStackedDeck", 0)
	YesOpenVeiledScarab := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesOpenVeiledScarab", 0)
	YesSpecial5Link := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesSpecial5Link", 1)
	YesVendorDumpItems := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesVendorDumpItems", 0)
	HeistAlcNGo := IniRead(A_ScriptDir "\save\Settings.ini", "General", "HeistAlcNGo", 1)
	MoveMapsToArea := IniRead(A_ScriptDir "\save\Settings.ini", "General", "MoveMapsToArea", 1)
	YesIncludeFandSItem := IniRead(A_ScriptDir "\save\Settings.ini", "General", "YesIncludeFandSItem", 1)
	EnableRestock := IniRead(A_ScriptDir "\save\Settings.ini", "General", "EnableRestock", 1)

	; CLF Options
	CLFStrictnessNumber := IniRead(A_ScriptDir "\save\Settings.ini", "General", "CLFStrictnessNumber", 0)

	; Basic Crafting Settings
	BasicCraftChanceMethod := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftChanceMethod", 1)
	BasicCraftChanceScour := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftChanceScour", 1)
	BasicCraftColorMethod := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftColorMethod", 1)
	BasicCraftR := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftR", 0)
	BasicCraftG := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftG", 0)
	BasicCraftB := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftB", 0)
	BasicCraftLinkMethod := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftLinkMethod", 1)
	BasicCraftDesiredLinks := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftDesiredLinks", 0)
	BasicCraftLinkAuto := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftLinkAuto", 1)
	BasicCraftSocketMethod := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftSocketMethod", 1)
	BasicCraftDesiredSockets := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftDesiredSockets", 0)
	BasicCraftSocketAuto := IniRead(A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftSocketAuto", 1)

	;Crafting Bases Options

	YesStashBasesAboveIlvl := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesStashBasesAboveIlvl", 0)
	StashBasesAboveIlvl := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "StashBasesAboveIlvl", 68)
	YesCraftingBaseAutoUpdateOnStart := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseAutoUpdateOnStart", 0)
	YesCraftingBaseAutoUpdateOnZone := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseAutoUpdateOnZone", 0)
	YesCraftingBaseLimitBases := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseLimitBases", 0)
	CraftingBaseLimitBasesNumber := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "CraftingBaseLimitBasesNumber", 3)

	;Item Crafting Options

	ItemCraftingSubCategorySelector := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingSubCategorySelector", "Abyss Jewels")
	ItemCraftingCategorySelector := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingCategorySelector", "Ghastly Eye Jewel")
	ItemCraftingNumberPrefix := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberPrefix", 1)
	ItemCraftingNumberSuffix := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberSuffix", 1)
	ItemCraftingNumberCombination := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberCombination", 0)
	ItemCraftingMethod := IniRead(A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingMethod", "Alteration Spam")


	;Crafting Map Settings
	StartMapTier1 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier1", 1)
	StartMapTier2 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier2", 6)
	StartMapTier3 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier3", 13)
	EndMapTier1 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier1", 5)
	EndMapTier2 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier2", 12)
	EndMapTier3 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier3", 16)
	CraftingMapMethod1 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod1", "Disable")
	CraftingMapMethod2 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod2", "Disable")
	CraftingMapMethod3 := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod3", "Disable")
	MMapItemQuantity := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapItemQuantity", 1)
	MMapItemRarity := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapItemRarity", 1)
	MMapMonsterPackSize := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapMonsterPackSize", 1)
	EnableMQQForMagicMap := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EnableMQQForMagicMap", 0)
	MMQorWeight := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMQorWeight", 0)
	MMapWeight := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapWeight", 0)
	ForceMaxChisel := IniRead(A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "ForceMaxChisel", 0)

	;Automation Settings
	YesEnableAutomation := IniRead(A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutomation", 0)
	FirstAutomationSetting := IniRead(A_ScriptDir "\save\Settings.ini", "Automation Settings", "FirstAutomationSetting", A_Space)
	YesEnableNextAutomation := IniRead(A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableNextAutomation", 0)
	YesEnableAutoSellConfirmation := IniRead(A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation", 0)
	YesEnableAutoSellConfirmationSafe := IniRead(A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmationSafe", 0)

	;Affinities
	StashTabCurrency := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabCurrency", 1)
	StashTabYesCurrency := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesCurrency", 0)
	StashTabMap := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabMap", 1)
	StashTabYesMap := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesMap", 0)
	StashTabDivination := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDivination", 1)
	StashTabYesDivination := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDivination", 0)
	StashTabGem := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabGem", 1)
	StashTabYesGem := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesGem", 1)
	StashTabFlask := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabFlask", 1)
	StashTabYesFlask := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesFlask", 1)
	StashTabFragment := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabFragment", 1)
	StashTabYesFragment := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesFragment", 0)
	StashTabEssence := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabEssence", 1)
	StashTabYesEssence := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesEssence", 0)
	StashTabBlight := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabBlight", 1)
	StashTabYesBlight := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesBlight", 0)
	StashTabDelirium := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDelirium", 1)
	StashTabYesDelirium := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDelirium", 0)
	StashTabDelve := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDelve", 1)
	StashTabYesDelve := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDelve", 0)
	StashTabUltimatum := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUltimatum", 1)
	StashTabYesUltimatum := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUltimatum", 0)
	StashTabUnique := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUnique", 1)
	StashTabYesUnique := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUnique", 1)

	;Affinities Unique Options
	StashTabUniqueRing := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniqueRing", 1)
	StashTabYesUniqueRing := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueRing", 1)
	StashTabUniqueDump := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniqueDump", 1)
	StashTabYesUniqueDump := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueDump", 1)
	StashTabYesUniquePercentage := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniquePercentage", 0)
	StashTabUniquePercentage := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniquePercentage", 70)
	StashTabYesUniqueRingAll := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueRingAll", 0)
	StashTabYesUniqueDumpAll := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueDumpAll", 0)

	;Stash Tab Management
	StashTabVeiled := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabVeiled", 1)
	StashTabYesVeiled := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesVeiled", 1)
	StashTabClusterJewel := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabClusterJewel", 1)
	StashTabYesClusterJewel := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesClusterJewel", 1)
	StashTabHeistGear := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabHeistGear", 1)
	StashTabYesHeistGear := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesHeistGear", 1)
	StashTabMiscMapItems := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabMiscMapItems", 1)
	StashTabYesMiscMapItems := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesMiscMapItems", 1)
	StashTabLinked := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabLinked", 1)
	StashTabYesLinked := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesLinked", 1)
	StashTabBrickedMaps := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabBrickedMaps", 1)
	StashTabYesBrickedMaps := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesBrickedMaps", 1)
	StashTabInfluencedItem := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabInfluencedItem", 1)
	StashTabYesInfluencedItem := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesInfluencedItem", 1)
	StashTabRunes := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabRunes", 1)
	StashTabYesRunes := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesRunes", 1)
	StashTabTattoos := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabTattoos", 1)
	StashTabYesTattoos := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesTattoos", 1)
	StashTabCrafting := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabCrafting", 1)
	StashTabYesCrafting := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesCrafting", 1)
	StashTabDump := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDump", 1)
	StashTabYesDump := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDump", 0)
	StashTabPredictive := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabPredictive", 1)
	StashTabYesPredictive := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesPredictive", 0)
	StashTabNinjaPrice := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabNinjaPrice", 1)
	StashTabYesNinjaPrice := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesNinjaPrice", 0)

	;Dump Tab Options
	StashDumpInTrial := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashDumpInTrial", 0)
	StashDumpInTrial := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashDumpSkipJC", 0)

	;Priced Options
	StashTabYesNinjaPrice_Price := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesNinjaPrice_Price", 5)

	; Chaos Recipe Settings
	ChaosRecipeEnableFunction := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeEnableFunction", 0)
	ChaosRecipeUnloadAll := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeUnloadAll", 0)
	ChaosRecipeSkipJC := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeSkipJC", 1)
	ChaosRecipeEnableUnId := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeEnableUnId", 1)
	ChaosRecipeSmallWeapons := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeSmallWeapons", 1)
	ChaosRecipeLimitUnId := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeLimitUnId", 74)
	ChaosRecipeAllowDoubleJewellery := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeAllowDoubleJewellery", 1)
	ChaosRecipeAllowDoubleBelt := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeAllowDoubleBelt", 0)
	ChaosRecipeMaxHoldingID := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeMaxHoldingID", 12)
	ChaosRecipeMaxHoldingUNID := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeMaxHoldingUNID", 12)
	ChaosRecipeTypePure := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypePure", 0)
	ChaosRecipeTypeHybrid := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypeHybrid", 1)
	ChaosRecipeTypeRegal := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypeRegal", 0)
	ChaosRecipeStashMethodDump := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodDump", 1)
	ChaosRecipeStashMethodTab := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodTab", 0)
	ChaosRecipeStashMethodSort := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodSort", 0)
	ChaosRecipeStashTab := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTab", 1)
	ChaosRecipeStashTabWeapon := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabWeapon", 1)
	ChaosRecipeStashTabHelmet := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabHelmet", 1)
	ChaosRecipeStashTabArmour := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabArmour", 1)
	ChaosRecipeStashTabGloves := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabGloves", 1)
	ChaosRecipeStashTabBoots := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabBoots", 1)
	ChaosRecipeStashTabBelt := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabBelt", 1)
	ChaosRecipeStashTabAmulet := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabAmulet", 1)
	ChaosRecipeStashTabRing := IniRead(A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashTabRing", 1)

	;Settings for the Client Log file location
	ClientLog := IniRead(A_ScriptDir "\save\Settings.ini", "Log", "ClientLog", ClientLog)

	;Settings for the Overhead Health Bar
	YesOHB := IniRead(A_ScriptDir "\save\Settings.ini", "OHB", "YesOHB", 1)

	;OHB Colors
	OHBLHealthHex := IniRead(A_ScriptDir "\save\Settings.ini", "OHB", "OHBLHealthHex", 0x19A631)

	;Ascii strings
	HealthBarStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "HealthBarStr", Res1080_HealthBarStr)
	If HealthBarStr
		OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
	ChestStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "ChestStr", Res1080_ChestStr)
	DelveStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "DelveStr", Res1080_DelveStr)
	VendorStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorStr", Res1080_MasterStr)
	SellItemsStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "SellItemsStr", Res1080_SellItemsStr)
	StashStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "StashStr", Res1080_StashStr)
	SkillUpStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "SkillUpStr", Res1080_SkillUpStr)
	XButtonStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "XButtonStr", Res1080_XButtonStr)
	VendorLioneyeStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorLioneyeStr", Res1080_BestelStr)
	VendorForestStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorForestStr", Res1080_GreustStr)
	VendorSarnStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorSarnStr", Res1080_ClarissaStr)
	VendorHighgateStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorHighgateStr", Res1080_PetarusStr)
	VendorOverseerStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorOverseerStr", Res1080_LaniStr)
	VendorBridgeStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorBridgeStr", Res1080_HelenaStr)
	VendorDocksStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorDocksStr", Res1080_LaniStr)
	VendorOriathStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorOriathStr", Res1080_LaniStr)
	VendorHarbourStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorHarbourStr", Res1080_FenceStr)
	VendorKingsmarchStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorKingsmarchStr", Res1080_IslaStr)
	VendorMineStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorMineStr", Res1080_MasterStr)

	; Debuff Strings
	debuffCurseEleWeakStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseEleWeakStr", A_Space)
	debuffCurseVulnStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseVulnStr", A_Space)
	debuffCurseEnfeebleStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseEnfeebleStr", A_Space)
	debuffCurseTempChainStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseTempChainStr", A_Space)
	debuffCurseCondStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseCondStr", A_Space)
	debuffCurseFlamStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseFlamStr", A_Space)
	debuffCurseFrostStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseFrostStr", A_Space)
	debuffCurseWarMarkStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffCurseWarMarkStr", A_Space)
	debuffShockStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffShockStr", A_Space)
	debuffBleedStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffBleedStr", A_Space)
	debuffFreezeStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffFreezeStr", A_Space)
	debuffIgniteStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffIgniteStr", A_Space)
	debuffPoisonStr := IniRead(A_ScriptDir "\save\Settings.ini", "FindText Strings", "debuffPoisonStr", A_Space)

	debuffCurseStr := debuffCurseEleWeakStr . debuffCurseVulnStr . debuffCurseEnfeebleStr . debuffCurseTempChainStr . debuffCurseCondStr . debuffCurseFlamStr . debuffCurseFrostStr . debuffCurseWarMarkStr

	;Inventory Colors
	varEmptyInvSlotColor := IniRead(A_ScriptDir "\save\Settings.ini", "Inventory Colors", "EmptyInvSlotColor", "0x000100,0x020402,0x000000,0x020302,0x010101,0x010201,0x060906,0x050905,0x030303,0x020202")
	;Create an array out of the read string
	varEmptyInvSlotColor := StrSplit(varEmptyInvSlotColor, ",")

	;Loot Vacuum Colors
	LootColors := IniRead(A_ScriptDir "\save\Settings.ini", "Loot Colors", "LootColors", "0xF2F2F2,0xC8C8C8,0xFE844B,0xEF581C,0xDA8B4D,0xAF5F1C,0xFEC140,0xF8960D,0xFECA22,0xD59F00,0xFCDDB2,0xD2B286,0x49226D,0x160040,0x8D35A0,0x600075,0x404040,0x0D0D0D,0x80DA51,0x53AF22,0x227A45,0x004D16,0x22512E,0x002200,0x224022,0x000D00,0x602222,0x320000,0xA3A3A3,0x777777")
	;Create an array out of the read string
	LootColors := StrSplit(LootColors, ",")

	;Failsafe Colors
	varOnMenu := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnMenu", 0xD6B97B)
	varOnChar := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnChar", 0x6B5543)
	varOnChat := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnChat", 0x88623B)
	varOnInventory := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnInventory", 0xDCC289)
	varOnStash := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnStash", 0xECDBA6)
	varOnVendor := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnVendor", 0xCEB178)
	varOnVendorHeist := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnVendorHeist", 0xCEB178)
	varOnDiv := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnDiv", 0xF6E2C5)
	varOnLeft := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnLeft", 0xB58C4D)
	varOnDelveChart := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnDelveChart", 0xE5B93F)
	varOnDetonate := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnDetonate", 0x5D4661)
	varOnDetonateDelve := IniRead(A_ScriptDir "\save\Settings.ini", "Failsafe Colors", "OnDetonateDelve", 0x5D4661)

	;Grab Currency From Inventory
	GrabCurrencyX := IniRead(A_ScriptDir "\save\Settings.ini", "Grab Currency", "GrabCurrencyX", 1877)
	GrabCurrencyY := IniRead(A_ScriptDir "\save\Settings.ini", "Grab Currency", "GrabCurrencyY", 772)

	;~ hotkeys reset
	HotIf((*) => WinActive("ahk_group POEGameGroup"))
		If hotkeyAutoQuit
		Hotkey(hotkeyAutoQuit, toggleAutoQuit, "Off")
	If hotkeyAutoFlask
		Hotkey(hotkeyAutoFlask, toggleAutoFlask, "Off")
	If hotkeyAutoMove
		Hotkey(hotkeyAutoMove, toggleAutoMove, "Off")
	If hotkeyAutoUtility
		Hotkey(hotkeyAutoUtility, toggleAutoUtility, "Off")
	If hotkeyQuickPortal
		Hotkey(hotkeyQuickPortal, QuickPortalCommand, "Off")
	If hotkeyGemSwap
		Hotkey(hotkeyGemSwap, GemSwapCommand, "Off")
	If hotkeyStartCraft
		Hotkey(hotkeyStartCraft, StartCraftingCommand, "Off")
	If hotkeyItemCrafting
		Hotkey(hotkeyItemCrafting, CraftingItemCaller, "Off")
	If hotkeyCraftBasic
		Hotkey(hotkeyCraftBasic, CraftBasicPopUp, "Off")

	If hotkeyCtrlClicker
		Hotkey(hotkeyCtrlClicker, CtrlSpam, "Off")
	If hotkeyCtrlShiftClicker
		Hotkey(hotkeyCtrlShiftClicker, CtrlShiftSpam, "Off")
	If hotkeyShiftClicker
		Hotkey(hotkeyShiftClicker, ShiftSpam, "Off")
	HotIf()
		If hotkeyCtrlClicker
		Hotkey("*" hotkeyCtrlClicker " Up", CtrlSpamOff, "Off")
	If hotkeyCtrlShiftClicker
		Hotkey("*" hotkeyCtrlShiftClicker " Up", CtrlSpamOff, "Off")
	If hotkeyShiftClicker
		Hotkey("*" hotkeyShiftClicker " Up", CtrlSpamOff, "Off")
	HotIf((*) => WinActive("ahk_group POEGameGroup"))

	If hotkeyGrabCurrency
		Hotkey(hotkeyGrabCurrency, GrabCurrencyCommand, "Off")
	If hotkeyGetMouseCoords
		Hotkey(hotkeyGetMouseCoords, CoordCommand, "Off")
	If hotkeyPopFlasks
		Hotkey(hotkeyPopFlasks, PopFlasksCommand, "Off")
	If hotkeyLogout
		Hotkey(hotkeyLogout, LogoutCommand, "Off")
	If hotkeyItemSort
		Hotkey(hotkeyItemSort, ItemSortCommand, "Off")
	If hotkeyItemInfo
		Hotkey(hotkeyItemInfo, ItemInfoCommand, "Off")
	If hotkeyChaosRecipe
		Hotkey(hotkeyChaosRecipe, VendorChaosRecipe, "Off")
	If hotkeyLootScan
	{
		Hotkey("$~" hotkeyLootScan, LootScanCommand, "Off")
		Hotkey("$~*" hotkeyLootScan " Up", LootScanCommandRelease, "Off")
	}
	If hotkeyPauseMines
		Hotkey("$~" hotkeyPauseMines, PauseMinesCommand, "Off")
	If hotkeyMainAttack
	{
		Hotkey("$~" hotkeyMainAttack, MainAttackCommand, "Off")
		Hotkey("$~*" hotkeyMainAttack " Up", MainAttackCommandRelease, "Off")
	}
	If hotkeySecondaryAttack
	{
		Hotkey("$~" hotkeySecondaryAttack, SecondaryAttackCommand, "Off")
		Hotkey("$~*" hotkeySecondaryAttack " Up", SecondaryAttackCommandRelease, "Off")
	}

	HotIf()
		If hotkeyOptions
		Hotkey(hotkeyOptions, optionsCommand, "Off")
	HotIf((*) => WinActive("ahk_group POEGameGroup"))

	;~ hotkeys iniread
	hotkeyOptions := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "Options", "!F10")
	hotkeyAutoQuit := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoQuit", "!F12")
	hotkeyAutoFlask := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoFlask", "!F11")
	hotkeyAutoMove := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoMove", "!MButton")
	hotkeyAutoUtility := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoUtility", "!MButton")
	hotkeyQuickPortal := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "QuickPortal", "!q")
	hotkeyStartCraft := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "StartCraft", "F7")
	hotkeyItemCrafting := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "CraftingItemCaller", "F11")

	hotkeyCraftBasic := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "CraftBasic", "F9")
	hotkeyGemSwap := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "GemSwap", "!e")
	hotkeyGrabCurrency := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "GrabCurrency", "!a")
	hotkeyGetMouseCoords := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "GetMouseCoords", "!o")
	hotkeyPopFlasks := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "PopFlasks", "CapsLock")
	hotkeyLogout := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "Logout", "F12")
	hotkeyCloseAllUI := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "CloseAllUI", "Space")
	hotkeyInventory := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "Inventory", "i")
	hotkeyWeaponSwapKey := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "WeaponSwapKey", "x")
	hotkeyItemSort := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "ItemSort", "F6")
	hotkeyItemInfo := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "ItemInfo", "F5")
	hotkeyChaosRecipe := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "ChaosRecipe", "F8")
	hotkeyLootScan := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "LootScan", "f")
	hotkeyDetonateMines := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyDetonateMines", "d")
	hotkeyOpenPortal := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyOpenPortal", A_Space)
	hotkeyPauseMines := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyPauseMines", "d")
	hotkeyMainAttack := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "MainAttack", "RButton")
	hotkeySecondaryAttack := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "SecondaryAttack", "w")
	hotkeyTriggerMovement := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyTriggerMovement", "LButton")
	hotkeyCtrlClicker := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "CtrlClicker", A_Space)
	hotkeyCtrlShiftClicker := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "CtrlShiftClicker", A_Space)
	hotkeyShiftClicker := IniRead(A_ScriptDir "\save\Settings.ini", "hotkeys", "ShiftClicker", A_Space)

	HotIf((*) => WinActive("ahk_group POEGameGroup"))
		If hotkeyAutoQuit
		Hotkey(hotkeyAutoQuit, toggleAutoQuit, "On")
	If hotkeyAutoFlask
		Hotkey(hotkeyAutoFlask, toggleAutoFlask, "On")
	If hotkeyAutoMove
		Hotkey(hotkeyAutoMove, toggleAutoMove, "On")
	If hotkeyAutoUtility
		Hotkey(hotkeyAutoUtility, toggleAutoUtility, "On")
	If hotkeyQuickPortal
		Hotkey(hotkeyQuickPortal, QuickPortalCommand, "On")
	If hotkeyGemSwap
		Hotkey(hotkeyGemSwap, GemSwapCommand, "On")
	If hotkeyStartCraft
		Hotkey(hotkeyStartCraft, StartCraftingCommand, "On")
	If hotkeyItemCrafting
		Hotkey(hotkeyItemCrafting, CraftingItemCaller, "On")
	If hotkeyCraftBasic
		Hotkey(hotkeyCraftBasic, CraftBasicPopUp, "On")

	If hotkeyCtrlClicker
		Hotkey(hotkeyCtrlClicker, CtrlSpam, "On")
	If hotkeyCtrlShiftClicker
		Hotkey(hotkeyCtrlShiftClicker, CtrlShiftSpam, "On")
	If hotkeyShiftClicker
		Hotkey(hotkeyShiftClicker, ShiftSpam, "On")
	HotIf()
		If hotkeyCtrlClicker
		Hotkey("*" hotkeyCtrlClicker " Up", CtrlSpamOff, "On")
	If hotkeyCtrlShiftClicker
		Hotkey("*" hotkeyCtrlShiftClicker " Up", CtrlSpamOff, "On")
	If hotkeyShiftClicker
		Hotkey("*" hotkeyShiftClicker " Up", CtrlSpamOff, "On")
	HotIf((*) => WinActive("ahk_group POEGameGroup"))

	If hotkeyGrabCurrency
		Hotkey(hotkeyGrabCurrency, GrabCurrencyCommand, "On")
	If hotkeyGetMouseCoords
		Hotkey(hotkeyGetMouseCoords, CoordCommand, "On")
	If hotkeyPopFlasks
		Hotkey(hotkeyPopFlasks, PopFlasksCommand, "On")
	If hotkeyLogout
		Hotkey(hotkeyLogout, LogoutCommand, "On")
	If hotkeyItemSort
		Hotkey(hotkeyItemSort, ItemSortCommand, "On")
	If hotkeyItemInfo
		Hotkey(hotkeyItemInfo, ItemInfoCommand, "On")
	If hotkeyChaosRecipe
		Hotkey(hotkeyChaosRecipe, VendorChaosRecipe, "On")
	If hotkeyLootScan
	{
		Hotkey("$~" hotkeyLootScan, LootScanCommand, "On")
		Hotkey("$~*" hotkeyLootScan " Up", LootScanCommandRelease, "On")
	}
	If hotkeyMainAttack
	{
		Hotkey("$~" hotkeyMainAttack, MainAttackCommand, "On")
		Hotkey("$~*" hotkeyMainAttack " Up", MainAttackCommandRelease, "On")
	}
	If hotkeySecondaryAttack
	{
		Hotkey("$~" hotkeySecondaryAttack, SecondaryAttackCommand, "On")
		Hotkey("$~*" hotkeySecondaryAttack " Up", SecondaryAttackCommandRelease, "On")
	}

	A_MaxThreadsPerHotkey := 1
	If hotkeyPauseMines
		Hotkey("$~" hotkeyPauseMines, PauseMinesCommand, "On")
	A_MaxThreadsPerHotkey := 2
	HotIf()
	If hotkeyOptions {
		Hotkey(hotkeyOptions, optionsCommand, "On")
	} else {
		Hotkey("!F10", optionsCommand, "On")
		MsgBox("You dont have set the GUI hotkey!`nPlease hit Alt+F10 to open up the GUI and set your hotkey.")
	}

	c1Prefix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Prefix1", "a")
	c1Prefix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Prefix2", A_Space)
	c1Suffix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix1", 1)
	c1Suffix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix2", 2)
	c1Suffix3 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix3", 3)
	c1Suffix4 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix4", 4)
	c1Suffix5 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix5", 5)
	c1Suffix6 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix6", 6)
	c1Suffix7 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix7", 7)
	c1Suffix8 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix8", 8)
	c1Suffix9 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix9", 9)

	c1Suffix1Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix1Text", "/Hideout")
	c1Suffix2Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix2Text", "/Delve")
	c1Suffix3Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix3Text", "/cls")
	c1Suffix4Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix4Text", "/ladder")
	c1Suffix5Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix5Text", "/reset_xp")
	c1Suffix6Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix6Text", "/invite RecipientName")
	c1Suffix7Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix7Text", "/kick RecipientName")
	c1Suffix8Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix8Text", "/kick CharacterName")
	c1Suffix9Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix9Text", "@RecipientName Still Interested?")

	c2Prefix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Prefix1", "d")
	c2Prefix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Prefix2", A_Space)
	c2Suffix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix1", 1)
	c2Suffix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix2", 2)
	c2Suffix3 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix3", 3)
	c2Suffix4 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix4", 4)
	c2Suffix5 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix5", 5)
	c2Suffix6 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix6", 6)
	c2Suffix7 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix7", 7)
	c2Suffix8 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix8", 8)
	c2Suffix9 := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix9", 9)

	c2Suffix1Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix1Text", "Sure, will invite in a sec.")
	c2Suffix2Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix2Text", "In a map, will get to you in a minute.")
	c2Suffix3Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix3Text", "Still Interested?")
	c2Suffix4Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix4Text", "Sorry, going to be a while.")
	c2Suffix5Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix5Text", "No thank you.")
	c2Suffix6Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix6Text", "No thank you.")
	c2Suffix7Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix7Text", "No thank you.")
	c2Suffix8Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix8Text", "No thank you.")
	c2Suffix9Text := IniRead(A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix9Text", "No thank you.")

	stashPrefix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashPrefix1", "Numpad0")
	stashPrefix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashPrefix2", A_Space)
	stashSuffix1 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix1", "Numpad1")
	stashSuffix2 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix2", "Numpad2")
	stashSuffix3 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix3", "Numpad3")
	stashSuffix4 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix4", "Numpad4")
	stashSuffix5 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix5", "Numpad5")
	stashSuffix6 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix6", "Numpad6")
	stashSuffix7 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix7", "Numpad7")
	stashSuffix8 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix8", "Numpad8")
	stashSuffix9 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix9", "Numpad9")

	stashSuffixTab1 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab1", 1)
	stashSuffixTab2 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab2", 2)
	stashSuffixTab3 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab3", 3)
	stashSuffixTab4 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab4", 4)
	stashSuffixTab5 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab5", 5)
	stashSuffixTab6 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab6", 6)
	stashSuffixTab7 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab7", 7)
	stashSuffixTab8 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab8", 8)
	stashSuffixTab9 := IniRead(A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab9", 9)

	;Controller setup
	hotkeyControllerButtonA := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "A", "^LButton")
	hotkeyControllerButtonB := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "B", hotkeyLootScan)
	hotkeyControllerButtonX := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "X", "r")
	hotkeyControllerButtonY := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "Y", hotkeyCloseAllUI)
	hotkeyControllerButtonLB := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "LB", "e")
	hotkeyControllerButtonRB := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "RB", "RButton")
	hotkeyControllerButtonBACK := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "BACK", "ItemSort")
	hotkeyControllerButtonSTART := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "START", "Tab")
	hotkeyControllerButtonL3 := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "L3", "Logout")
	hotkeyControllerButtonR3 := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "R3", "QuickPortal")

	hotkeyControllerJoystickRight := IniRead(A_ScriptDir "\save\Settings.ini", "Controller Keys", "JoystickRight", "RButton")

	YesTriggerUtilityKey := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerUtilityKey", 1)
	YesTriggerUtilityJoystickKey := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerUtilityJoystickKey", 1)
	YesTriggerJoystickRightKey := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerJoystickRightKey", 1)
	TriggerUtilityKey := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "TriggerUtilityKey", 1)
	YesMovementKeys := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "YesMovementKeys", 0)
	YesController := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "YesController", 0)
	JoystickNumber := IniRead(A_ScriptDir "\save\Settings.ini", "Controller", "JoystickNumber", 0)

	;settings for the Ninja Database
	LastDatabaseParseDate := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "LastDatabaseParseDate", 20190913)
	selectedLeague := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "selectedLeague", "Standard")
	UpdateDatabaseInterval := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "UpdateDatabaseInterval", 2)
	YesNinjaDatabase := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "YesNinjaDatabase", 1)
	ForceMatch6Link := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "ForceMatch6Link", 0)
	ForceMatchGem20 := IniRead(A_ScriptDir "\save\Settings.ini", "Database", "ForceMatchGem20", 0)

	UnRegisterHotkeys()
	RegisterHotkeys()
	checkActiveType()
	Thread("NoTimers", false) ;End Critical
	Return
}

updateEverything(*){
		Global ToggleExist, WinGuiX, WinGuiY, AccountNameSTR, PoECookie
			, BranchName, ScriptUpdateTimeInterval, ScriptUpdateTimeType
			, DebugMessages, YesTimeMS, YesLocation, ShowPixelGrid, ShowItemInfo
			, LootVacuum, LootVacuumTapZ, LootVacuumTapZEnd, LootVacuumTapZSec
			, YesVendor, YesStash, YesIdentify, YesDiv
			, YesMapUnid, YesInfluencedUnid, YesSynthesisId, YesCLFIgnoreImplicit, YesSortFirst
			, Latency, ClickLatency, ClipLatency, ShowOnStart, PopFlaskRespectCD
			, ResolutionScale, AutoUpdateOff, EnableChatHotkeys, YesStashKeys
			, YesSkipMaps, YesSkipMaps_Prep, YesSkipMaps_eval
			, YesSkipMaps_normal, YesSkipMaps_magic, YesSkipMaps_rare, YesSkipMaps_unique, YesSkipMaps_tier
			, AreaScale, LVdelay, YesBatchVendorBauble, YesBatchVendorGCP
			, BrickedWhenCorrupted, YesOpenStackedDeck, YesOpenVeiledScarab, YesSpecial5Link
			, YesVendorDumpItems, HeistAlcNGo, MoveMapsToArea, YesIncludeFandSItem, EnableRestock
			, CLFStrictnessNumber, YesOHB
			, HealthBarStr, VendorStr, SellItemsStr, StashStr, SkillUpStr
			, hotkeyOptions, hotkeyAutoQuit, hotkeyAutoFlask, hotkeyAutoMove, hotkeyAutoUtility
			, hotkeyQuickPortal, hotkeyStartCraft, hotkeyItemCrafting, hotkeyCraftBasic
			, hotkeyGemSwap, hotkeyGrabCurrency, hotkeyGetMouseCoords
			, hotkeyPopFlasks, hotkeyLogout, hotkeyCloseAllUI, hotkeyInventory, hotkeyWeaponSwapKey
			, hotkeyItemSort, hotkeyItemInfo, hotkeyChaosRecipe, hotkeyLootScan
			, hotkeyDetonateMines, hotkeyOpenPortal, hotkeyPauseMines
			, hotkeyMainAttack, hotkeySecondaryAttack, hotkeyTriggerMovement
			, hotkeyCtrlClicker, hotkeyCtrlShiftClicker, hotkeyShiftClicker
			, hotkeyUp, hotkeyDown, hotkeyLeft, hotkeyRight
			, GrabCurrencyX, GrabCurrencyY
			, YesStashBasesAboveIlvl, StashBasesAboveIlvl
			, YesCraftingBaseAutoUpdateOnStart, YesCraftingBaseAutoUpdateOnZone
			, YesCraftingBaseLimitBases, CraftingBaseLimitBasesNumber
			, ItemCraftingSubCategorySelector, ItemCraftingCategorySelector
			, ItemCraftingNumberPrefix, ItemCraftingNumberSuffix, ItemCraftingNumberCombination, ItemCraftingMethod
			, StartMapTier1, StartMapTier2, StartMapTier3
			, EndMapTier1, EndMapTier2, EndMapTier3
			, CraftingMapMethod1, CraftingMapMethod2, CraftingMapMethod3
			, MMapItemQuantity, MMapItemRarity, MMapMonsterPackSize
			, EnableMQQForMagicMap, MMQorWeight, MMapWeight, ForceMaxChisel
			, StashTabCurrency, StashTabYesCurrency, StashTabMap, StashTabYesMap
			, StashTabDivination, StashTabYesDivination, StashTabGem, StashTabYesGem
			, StashTabFlask, StashTabYesFlask, StashTabFragment, StashTabYesFragment
			, StashTabEssence, StashTabYesEssence, StashTabBlight, StashTabYesBlight
			, StashTabDelirium, StashTabYesDelirium, StashTabDelve, StashTabYesDelve
			, StashTabUltimatum, StashTabYesUltimatum, StashTabUnique, StashTabYesUnique
			, StashTabUniqueRing, StashTabYesUniqueRing, StashTabUniqueDump, StashTabYesUniqueDump
			, StashTabYesUniquePercentage, StashTabUniquePercentage
			, StashTabYesUniqueRingAll, StashTabYesUniqueDumpAll
			, StashTabVeiled, StashTabYesVeiled, StashTabClusterJewel, StashTabYesClusterJewel
			, StashTabHeistGear, StashTabYesHeistGear, StashTabMiscMapItems, StashTabYesMiscMapItems
			, StashTabLinked, StashTabYesLinked, StashTabBrickedMaps, StashTabYesBrickedMaps
			, StashTabInfluencedItem, StashTabYesInfluencedItem
			, StashTabRunes, StashTabYesRunes, StashTabTattoos, StashTabYesTattoos
			, StashTabCrafting, StashTabYesCrafting, StashTabDump, StashTabYesDump
			, StashTabPredictive, StashTabYesPredictive, StashTabNinjaPrice, StashTabYesNinjaPrice
			, StashDumpInTrial, StashDumpSkipJC, StashTabYesNinjaPrice_Price
			, ChaosRecipeEnableFunction, ChaosRecipeUnloadAll, ChaosRecipeSkipJC
			, ChaosRecipeEnableUnId, ChaosRecipeSmallWeapons, ChaosRecipeLimitUnId
			, ChaosRecipeAllowDoubleJewellery, ChaosRecipeAllowDoubleBelt
			, ChaosRecipeMaxHoldingID, ChaosRecipeMaxHoldingUNID
			, ChaosRecipeTypePure, ChaosRecipeTypeHybrid, ChaosRecipeTypeRegal
			, ChaosRecipeStashMethodDump, ChaosRecipeStashMethodTab, ChaosRecipeStashMethodSort
			, ChaosRecipeStashTab, ChaosRecipeStashTabWeapon, ChaosRecipeStashTabHelmet
			, ChaosRecipeStashTabArmour, ChaosRecipeStashTabGloves, ChaosRecipeStashTabBoots
			, ChaosRecipeStashTabBelt, ChaosRecipeStashTabAmulet, ChaosRecipeStashTabRing
			, c1Prefix1, c1Prefix2, c1Suffix1, c1Suffix2, c1Suffix3, c1Suffix4, c1Suffix5, c1Suffix6, c1Suffix7, c1Suffix8, c1Suffix9
			, c1Suffix1Text, c1Suffix2Text, c1Suffix3Text, c1Suffix4Text, c1Suffix5Text
			, c1Suffix6Text, c1Suffix7Text, c1Suffix8Text, c1Suffix9Text
			, c2Prefix1, c2Prefix2, c2Suffix1, c2Suffix2, c2Suffix3, c2Suffix4, c2Suffix5, c2Suffix6, c2Suffix7, c2Suffix8, c2Suffix9
			, c2Suffix1Text, c2Suffix2Text, c2Suffix3Text, c2Suffix4Text, c2Suffix5Text
			, c2Suffix6Text, c2Suffix7Text, c2Suffix8Text, c2Suffix9Text
			, stashPrefix1, stashPrefix2
			, stashSuffix1, stashSuffix2, stashSuffix3, stashSuffix4, stashSuffix5
			, stashSuffix6, stashSuffix7, stashSuffix8, stashSuffix9
			, stashSuffixTab1, stashSuffixTab2, stashSuffixTab3, stashSuffixTab4, stashSuffixTab5
			, stashSuffixTab6, stashSuffixTab7, stashSuffixTab8, stashSuffixTab9
			, hotkeyControllerButtonA, hotkeyControllerButtonB, hotkeyControllerButtonX, hotkeyControllerButtonY
			, hotkeyControllerButtonLB, hotkeyControllerButtonRB
			, hotkeyControllerButtonBACK, hotkeyControllerButtonSTART
			, hotkeyControllerButtonL3, hotkeyControllerButtonR3, hotkeyControllerJoystickRight
			, YesTriggerUtilityKey, YesTriggerUtilityJoystickKey, YesTriggerJoystickRightKey
			, TriggerUtilityKey, YesMovementKeys, YesController, JoystickNumber
			, LastDatabaseParseDate, selectedLeague, UpdateDatabaseInterval, YesNinjaDatabase
			, ForceMatch6Link, ForceMatchGem20
			, CtrlSpam, CtrlShiftSpam, ShiftSpam, CtrlSpamOff
		Thread("NoTimers", true) ;Critical

		; IniWrite, %PoECookie%, %A_ScriptDir%\save\Account.ini, GGG, PoECookie
		Settings("Flask","Save")
		Settings("Utility","Save")
		Settings("perChar","Save")
		Settings("func","Save")
		; Settings("String","Save")
		Settings("CustomCraftingBases","Save")
		Settings("CustomMapMods","Save")
		Settings("ItemCrafting","Save")

		;GUI Position
		WinGetPos(&winguix, &winguiy, &winW, &winH, "WingmanReloaded")
		If !(WinGuiX == "" || WinGuiY == "")
		{
			IniWrite(winguix, A_ScriptDir "\save\Settings.ini", "General", "WinGuiX")
			IniWrite(winguiy, A_ScriptDir "\save\Settings.ini", "General", "WinGuiY")
		}

		;~ hotkeys reset
		HotIf((*) => WinActive("ahk_group POEGameGroup"))
			If hotkeyAutoQuit
			Hotkey(hotkeyAutoQuit, toggleAutoQuit, "Off")
		If hotkeyAutoFlask
			Hotkey(hotkeyAutoFlask, toggleAutoFlask, "Off")
		If hotkeyQuickPortal
			Hotkey(hotkeyQuickPortal, QuickPortalCommand, "Off")
		If hotkeyGemSwap
			Hotkey(hotkeyGemSwap, GemSwapCommand, "Off")
		If hotkeyStartCraft
			Hotkey(hotkeyStartCraft, StartCraftingCommand, "Off")
		If hotkeyItemCrafting
			Hotkey(hotkeyItemCrafting, CraftingItemCaller, "Off")
		If hotkeyCraftBasic
			Hotkey(hotkeyCraftBasic, CraftBasicPopUp, "Off")

		If hotkeyCtrlClicker
			Hotkey(hotkeyCtrlClicker, CtrlSpam, "Off")
		If hotkeyCtrlShiftClicker
			Hotkey(hotkeyCtrlShiftClicker, CtrlShiftSpam, "Off")
		If hotkeyShiftClicker
			Hotkey(hotkeyShiftClicker, ShiftSpam, "Off")
		HotIf()
			If hotkeyCtrlClicker
			Hotkey("*" hotkeyCtrlClicker " Up", CtrlSpamOff, "Off")
		If hotkeyCtrlShiftClicker
			Hotkey("*" hotkeyCtrlShiftClicker " Up", CtrlSpamOff, "Off")
		If hotkeyShiftClicker
			Hotkey("*" hotkeyShiftClicker " Up", CtrlSpamOff, "Off")
		HotIf((*) => WinActive("ahk_group POEGameGroup"))

		If hotkeyGrabCurrency
			Hotkey(hotkeyGrabCurrency, GrabCurrencyCommand, "Off")
		If hotkeyGetMouseCoords
			Hotkey(hotkeyGetMouseCoords, CoordCommand, "Off")
		If hotkeyPopFlasks
			Hotkey(hotkeyPopFlasks, PopFlasksCommand, "Off")
		If hotkeyLogout
			Hotkey(hotkeyLogout, LogoutCommand, "Off")
		If hotkeyItemSort
			Hotkey(hotkeyItemSort, ItemSortCommand, "Off")
		If hotkeyItemInfo
			Hotkey(hotkeyItemInfo, ItemInfoCommand, "Off")
		If hotkeyChaosRecipe
			Hotkey(hotkeyChaosRecipe, VendorChaosRecipe, "Off")
		If hotkeyLootScan
		{
			Hotkey("$~" hotkeyLootScan, LootScanCommand, "Off")
			Hotkey("$~*" hotkeyLootScan " Up", LootScanCommandRelease, "Off")
		}
		If hotkeyPauseMines
			Hotkey("$~" hotkeyPauseMines, PauseMinesCommand, "Off")
		If hotkeyMainAttack
		{
			Hotkey("$~" hotkeyMainAttack, MainAttackCommand, "Off")
			Hotkey("$~*" hotkeyMainAttack " Up", MainAttackCommandRelease, "Off")
		}
		If hotkeySecondaryAttack
		{
			Hotkey("$~" hotkeySecondaryAttack, SecondaryAttackCommand, "Off")
			Hotkey("$~*" hotkeySecondaryAttack " Up", SecondaryAttackCommandRelease, "Off")
		}

		UnRegisterHotkeys()

		HotIf()
			If hotkeyOptions
			Hotkey(hotkeyOptions, optionsCommand, "Off")
		HotIf((*) => WinActive("ahk_group POEGameGroup"))

		if WinExist("ahk_group POEGameGroup")
		{
			MainGui.Submit(1)
			Rescale()
			OverlayGui.Show("x" WR.loc.pixel.Gui.X " y" (WR.loc.pixel.Gui.Y - 15))
			ChaosGui.Show("x" (WR.loc.pixel.GuiChaos.X - 300) " y" WR.loc.pixel.GuiChaos.Y " NA")
			ToggleExist := True
			WinActivate("ahk_group POEGameGroup")
		}

		MainGui.Submit(0)

		IniWrite(AccountNameSTR, A_ScriptDir "\save\Account.ini", "GGG", "AccountNameSTR")
		temp := {Cookie: PoECookie}
		t := JSON.Dump(temp, 1)
		If FileExist(A_ScriptDir "\save\Cookie.json")
			FileDelete(A_ScriptDir "\save\Cookie.json")
		FileAppend(t, A_ScriptDir "\save\Cookie.json")
		t := temp := ""

		;Bandit Extra options
		IniWrite(BranchName, A_ScriptDir "\save\Settings.ini", "General", "BranchName")
		IniWrite(ScriptUpdateTimeInterval, A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeInterval")
		IniWrite(ScriptUpdateTimeType, A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeType")
		IniWrite(DebugMessages, A_ScriptDir "\save\Settings.ini", "General", "DebugMessages")
		IniWrite(YesTimeMS, A_ScriptDir "\save\Settings.ini", "General", "YesTimeMS")
		IniWrite(YesLocation, A_ScriptDir "\save\Settings.ini", "General", "YesLocation")
		IniWrite(ShowPixelGrid, A_ScriptDir "\save\Settings.ini", "General", "ShowPixelGrid")
		IniWrite(ShowItemInfo, A_ScriptDir "\save\Settings.ini", "General", "ShowItemInfo")
		IniWrite(LootVacuum, A_ScriptDir "\save\Settings.ini", "General", "LootVacuum")
		IniWrite(YesVendor, A_ScriptDir "\save\Settings.ini", "General", "YesVendor")
		IniWrite(YesStash, A_ScriptDir "\save\Settings.ini", "General", "YesStash")
		IniWrite(YesIdentify, A_ScriptDir "\save\Settings.ini", "General", "YesIdentify")
		IniWrite(YesDiv, A_ScriptDir "\save\Settings.ini", "General", "YesDiv")
		IniWrite(YesMapUnid, A_ScriptDir "\save\Settings.ini", "General", "YesMapUnid")
		IniWrite(YesInfluencedUnid, A_ScriptDir "\save\Settings.ini", "General", "YesInfluencedUnid")
		IniWrite(YesSynthesisId, A_ScriptDir "\save\Settings.ini", "General", "YesSynthesisId")
		IniWrite(YesCLFIgnoreImplicit, A_ScriptDir "\save\Settings.ini", "General", "YesCLFIgnoreImplicit")
		IniWrite(YesSortFirst, A_ScriptDir "\save\Settings.ini", "General", "YesSortFirst")
		IniWrite(Latency, A_ScriptDir "\save\Settings.ini", "General", "Latency")
		IniWrite(ClickLatency, A_ScriptDir "\save\Settings.ini", "General", "ClickLatency")
		IniWrite(ClipLatency, A_ScriptDir "\save\Settings.ini", "General", "ClipLatency")
		IniWrite(ShowOnStart, A_ScriptDir "\save\Settings.ini", "General", "ShowOnStart")
		IniWrite(PopFlaskRespectCD, A_ScriptDir "\save\Settings.ini", "General", "PopFlaskRespectCD")
		IniWrite(EnableChatHotkeys, A_ScriptDir "\save\Settings.ini", "General", "EnableChatHotkeys")
		IniWrite(YesStashKeys, A_ScriptDir "\save\Settings.ini", "General", "YesStashKeys")
		IniWrite(YesSkipMaps, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps")
		IniWrite(YesSkipMaps_Prep, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_Prep")
		IniWrite(YesSkipMaps_eval, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_eval")
		IniWrite(YesSkipMaps_normal, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_normal")
		IniWrite(YesSkipMaps_magic, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_magic")
		IniWrite(YesSkipMaps_rare, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_rare")
		IniWrite(YesSkipMaps_unique, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_unique")
		IniWrite(YesSkipMaps_tier, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_tier")
		IniWrite(AreaScale, A_ScriptDir "\save\Settings.ini", "General", "AreaScale")
		IniWrite(LVdelay, A_ScriptDir "\save\Settings.ini", "General", "LVdelay")
		IniWrite(YesBatchVendorBauble, A_ScriptDir "\save\Settings.ini", "General", "YesBatchVendorBauble")
		IniWrite(YesBatchVendorGCP, A_ScriptDir "\save\Settings.ini", "General", "YesBatchVendorGCP")
		IniWrite(BrickedWhenCorrupted, A_ScriptDir "\save\Settings.ini", "General", "BrickedWhenCorrupted")
		IniWrite(YesOpenStackedDeck, A_ScriptDir "\save\Settings.ini", "General", "YesOpenStackedDeck")
		IniWrite(YesOpenVeiledScarab, A_ScriptDir "\save\Settings.ini", "General", "YesOpenVeiledScarab")
		IniWrite(YesSpecial5Link, A_ScriptDir "\save\Settings.ini", "General", "YesSpecial5Link")
		IniWrite(YesVendorDumpItems, A_ScriptDir "\save\Settings.ini", "General", "YesVendorDumpItems")
		IniWrite(HeistAlcNGo, A_ScriptDir "\save\Settings.ini", "General", "HeistAlcNGo")
		IniWrite(MoveMapsToArea, A_ScriptDir "\save\Settings.ini", "General", "MoveMapsToArea")
		IniWrite(YesIncludeFandSItem, A_ScriptDir "\save\Settings.ini", "General", "YesIncludeFandSItem")
		IniWrite(EnableRestock, A_ScriptDir "\save\Settings.ini", "General", "EnableRestock")

		; CLF Options
		IniWrite(CLFStrictnessNumber, A_ScriptDir "\save\Settings.ini", "General", "CLFStrictnessNumber")

		; Overhead Health Bar
		IniWrite(YesOHB, A_ScriptDir "\save\Settings.ini", "OHB", "YesOHB")

		; ASCII Search Strings
		IniWrite(HealthBarStr, A_ScriptDir "\save\Settings.ini", "FindText Strings", "HealthBarStr")
		IniWrite(VendorStr, A_ScriptDir "\save\Settings.ini", "FindText Strings", "VendorStr")
		IniWrite(SellItemsStr, A_ScriptDir "\save\Settings.ini", "FindText Strings", "SellItemsStr")
		IniWrite(StashStr, A_ScriptDir "\save\Settings.ini", "FindText Strings", "StashStr")
		IniWrite(SkillUpStr, A_ScriptDir "\save\Settings.ini", "FindText Strings", "SkillUpStr")

		;~ Hotkeys
		IniWrite(hotkeyOptions, A_ScriptDir "\save\Settings.ini", "hotkeys", "Options")
		IniWrite(hotkeyAutoQuit, A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoQuit")
		IniWrite(hotkeyAutoFlask, A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoFlask")
		IniWrite(hotkeyAutoMove, A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoMove")
		IniWrite(hotkeyAutoUtility, A_ScriptDir "\save\Settings.ini", "hotkeys", "AutoUtility")
		IniWrite(hotkeyQuickPortal, A_ScriptDir "\save\Settings.ini", "hotkeys", "QuickPortal")
		IniWrite(hotkeyGemSwap, A_ScriptDir "\save\Settings.ini", "hotkeys", "GemSwap")
		IniWrite(hotkeyStartCraft, A_ScriptDir "\save\Settings.ini", "hotkeys", "StartCraft")
		IniWrite(hotkeyItemCrafting, A_ScriptDir "\save\Settings.ini", "hotkeys", "CraftingItemCaller")
		IniWrite(hotkeyCraftBasic, A_ScriptDir "\save\Settings.ini", "hotkeys", "CraftBasic")
		IniWrite(hotkeyCtrlClicker, A_ScriptDir "\save\Settings.ini", "hotkeys", "CtrlClicker")
		IniWrite(hotkeyCtrlShiftClicker, A_ScriptDir "\save\Settings.ini", "hotkeys", "CtrlShiftClicker")
		IniWrite(hotkeyShiftClicker, A_ScriptDir "\save\Settings.ini", "hotkeys", "ShiftClicker")
		IniWrite(hotkeyGrabCurrency, A_ScriptDir "\save\Settings.ini", "hotkeys", "GrabCurrency")
		IniWrite(hotkeyGetMouseCoords, A_ScriptDir "\save\Settings.ini", "hotkeys", "GetMouseCoords")
		IniWrite(hotkeyPopFlasks, A_ScriptDir "\save\Settings.ini", "hotkeys", "PopFlasks")
		IniWrite(hotkeyLogout, A_ScriptDir "\save\Settings.ini", "hotkeys", "Logout")
		IniWrite(hotkeyCloseAllUI, A_ScriptDir "\save\Settings.ini", "hotkeys", "CloseAllUI")
		IniWrite(hotkeyInventory, A_ScriptDir "\save\Settings.ini", "hotkeys", "Inventory")
		IniWrite(hotkeyWeaponSwapKey, A_ScriptDir "\save\Settings.ini", "hotkeys", "WeaponSwapKey")
		IniWrite(hotkeyItemSort, A_ScriptDir "\save\Settings.ini", "hotkeys", "ItemSort")
		IniWrite(hotkeyItemInfo, A_ScriptDir "\save\Settings.ini", "hotkeys", "ItemInfo")
		IniWrite(hotkeyChaosRecipe, A_ScriptDir "\save\Settings.ini", "hotkeys", "ChaosRecipe")
		IniWrite(hotkeyLootScan, A_ScriptDir "\save\Settings.ini", "hotkeys", "LootScan")
		IniWrite(hotkeyDetonateMines, A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyDetonateMines")
		IniWrite(hotkeyOpenPortal, A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyOpenPortal")
		IniWrite(hotkeyPauseMines, A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyPauseMines")
		IniWrite(hotkeyMainAttack, A_ScriptDir "\save\Settings.ini", "hotkeys", "MainAttack")
		IniWrite(hotkeySecondaryAttack, A_ScriptDir "\save\Settings.ini", "hotkeys", "SecondaryAttack")
		IniWrite(hotkeyTriggerMovement, A_ScriptDir "\save\Settings.ini", "hotkeys", "hotkeyTriggerMovement")

		;Utility Keys
		IniWrite(hotkeyUp, A_ScriptDir "\save\Settings.ini", "Controller Keys", "hotkeyUp")
		IniWrite(hotkeyDown, A_ScriptDir "\save\Settings.ini", "Controller Keys", "hotkeyDown")
		IniWrite(hotkeyLeft, A_ScriptDir "\save\Settings.ini", "Controller Keys", "hotkeyLeft")
		IniWrite(hotkeyRight, A_ScriptDir "\save\Settings.ini", "Controller Keys", "hotkeyRight")

		;Grab Currency
		IniWrite(GrabCurrencyX, A_ScriptDir "\save\Settings.ini", "Grab Currency", "GrabCurrencyX")
		IniWrite(GrabCurrencyY, A_ScriptDir "\save\Settings.ini", "Grab Currency", "GrabCurrencyY")

		;Crafting Bases Options

		IniWrite(YesStashBasesAboveIlvl, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesStashBasesAboveIlvl")
		IniWrite(StashBasesAboveIlvl, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "StashBasesAboveIlvl")
		IniWrite(YesCraftingBaseAutoUpdateOnStart, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseAutoUpdateOnStart")
		IniWrite(YesCraftingBaseAutoUpdateOnZone, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseAutoUpdateOnZone")
		IniWrite(YesCraftingBaseLimitBases, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "YesCraftingBaseLimitBases")
		IniWrite(CraftingBaseLimitBasesNumber, A_ScriptDir "\save\Settings.ini", "Crafting Bases Settings", "CraftingBaseLimitBasesNumber")

		;Item Crafting Options

		IniWrite(ItemCraftingSubCategorySelector, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingSubCategorySelector")
		IniWrite(ItemCraftingCategorySelector, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingCategorySelector")
		IniWrite(ItemCraftingNumberPrefix, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberPrefix")
		IniWrite(ItemCraftingNumberSuffix, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberSuffix")
		IniWrite(ItemCraftingNumberCombination, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingNumberCombination")
		IniWrite(ItemCraftingMethod, A_ScriptDir "\save\Settings.ini", "Item Crafting Settings", "ItemCraftingMethod")

		;Crafting Map Settings
		IniWrite(StartMapTier1, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier1")
		IniWrite(StartMapTier2, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier2")
		IniWrite(StartMapTier3, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "StartMapTier3")
		IniWrite(EndMapTier1, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier1")
		IniWrite(EndMapTier2, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier2")
		IniWrite(EndMapTier3, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EndMapTier3")
		IniWrite(CraftingMapMethod1, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod1")
		IniWrite(CraftingMapMethod2, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod2")
		IniWrite(CraftingMapMethod3, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "CraftingMapMethod3")
		IniWrite(MMapItemQuantity, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapItemQuantity")
		IniWrite(MMapItemRarity, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapItemRarity")
		IniWrite(MMapMonsterPackSize, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapMonsterPackSize")
		IniWrite(EnableMQQForMagicMap, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "EnableMQQForMagicMap")
		IniWrite(MMQorWeight, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMQorWeight")
		IniWrite(MMapWeight, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "MMapWeight")
		IniWrite(ForceMaxChisel, A_ScriptDir "\save\Settings.ini", "Crafting Map Settings", "ForceMaxChisel")

		;Affinities
		IniWrite(StashTabCurrency, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabCurrency")
		IniWrite(StashTabYesCurrency, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesCurrency")
		IniWrite(StashTabMap, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabMap")
		IniWrite(StashTabYesMap, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesMap")
		IniWrite(StashTabDivination, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDivination")
		IniWrite(StashTabYesDivination, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDivination")
		IniWrite(StashTabGem, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabGem")
		IniWrite(StashTabYesGem, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesGem")
		IniWrite(StashTabFlask, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabFlask")
		IniWrite(StashTabYesFlask, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesFlask")
		IniWrite(StashTabFragment, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabFragment")
		IniWrite(StashTabYesFragment, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesFragment")
		IniWrite(StashTabEssence, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabEssence")
		IniWrite(StashTabYesEssence, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesEssence")
		IniWrite(StashTabBlight, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabBlight")
		IniWrite(StashTabYesBlight, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesBlight")
		IniWrite(StashTabDelirium, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDelirium")
		IniWrite(StashTabYesDelirium, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDelirium")
		IniWrite(StashTabDelve, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDelve")
		IniWrite(StashTabYesDelve, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDelve")
		IniWrite(StashTabUltimatum, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUltimatum")
		IniWrite(StashTabYesUltimatum, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUltimatum")
		IniWrite(StashTabUnique, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUnique")
		IniWrite(StashTabYesUnique, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUnique")

		;Affinities Unique Options
		IniWrite(StashTabUniqueRing, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniqueRing")
		IniWrite(StashTabYesUniqueRing, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueRing")
		IniWrite(StashTabUniqueDump, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniqueDump")
		IniWrite(StashTabYesUniqueDump, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueDump")
		IniWrite(StashTabYesUniquePercentage, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniquePercentage")
		IniWrite(StashTabUniquePercentage, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabUniquePercentage")
		IniWrite(StashTabYesUniqueRingAll, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueRingAll")
		IniWrite(StashTabYesUniqueDumpAll, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesUniqueDumpAll")

		;Stash Tab Management
		IniWrite(StashTabVeiled, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabVeiled")
		IniWrite(StashTabYesVeiled, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesVeiled")
		IniWrite(StashTabClusterJewel, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabClusterJewel")
		IniWrite(StashTabYesClusterJewel, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesClusterJewel")
		IniWrite(StashTabHeistGear, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabHeistGear")
		IniWrite(StashTabYesHeistGear, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesHeistGear")
		IniWrite(StashTabMiscMapItems, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabMiscMapItems")
		IniWrite(StashTabYesMiscMapItems, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesMiscMapItems")
		IniWrite(StashTabLinked, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabLinked")
		IniWrite(StashTabYesLinked, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesLinked")
		IniWrite(StashTabBrickedMaps, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabBrickedMaps")
		IniWrite(StashTabYesBrickedMaps, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesBrickedMaps")
		IniWrite(StashTabInfluencedItem, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabInfluencedItem")
		IniWrite(StashTabYesInfluencedItem, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesInfluencedItem")
		IniWrite(StashTabRunes, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabRunes")
		IniWrite(StashTabYesRunes, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesRunes")
		IniWrite(StashTabTattoos, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabTattoos")
		IniWrite(StashTabYesTattoos, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesTattoos")
		IniWrite(StashTabCrafting, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabCrafting")
		IniWrite(StashTabYesCrafting, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesCrafting")
		IniWrite(StashTabDump, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabDump")
		IniWrite(StashTabYesDump, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesDump")
		IniWrite(StashTabPredictive, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabPredictive")
		IniWrite(StashTabYesPredictive, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesPredictive")
		IniWrite(StashTabNinjaPrice, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabNinjaPrice")
		IniWrite(StashTabYesNinjaPrice, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesNinjaPrice")

		;Dump Tab Options
		IniWrite(StashDumpInTrial, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashDumpInTrial")
		IniWrite(StashDumpInTrial, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashDumpSkipJC")

		;Priced Options
		IniWrite(StashTabYesNinjaPrice_Price, A_ScriptDir "\save\Settings.ini", "Stash Tab", "StashTabYesNinjaPrice_Price")

		;Chat Hotkeys
		IniWrite(c1Prefix1, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Prefix1")
		IniWrite(c1Prefix2, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Prefix2")
		IniWrite(c1Suffix1, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix1")
		IniWrite(c1Suffix2, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix2")
		IniWrite(c1Suffix3, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix3")
		IniWrite(c1Suffix4, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix4")
		IniWrite(c1Suffix5, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix5")
		IniWrite(c1Suffix6, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix6")
		IniWrite(c1Suffix7, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix7")
		IniWrite(c1Suffix8, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix8")
		IniWrite(c1Suffix9, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix9")

		IniWrite(c1Suffix1Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix1Text")
		IniWrite(c1Suffix2Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix2Text")
		IniWrite(c1Suffix3Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix3Text")
		IniWrite(c1Suffix4Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix4Text")
		IniWrite(c1Suffix5Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix5Text")
		IniWrite(c1Suffix6Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix6Text")
		IniWrite(c1Suffix7Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix7Text")
		IniWrite(c1Suffix8Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix8Text")
		IniWrite(c1Suffix9Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "1Suffix9Text")

		IniWrite(c2Prefix1, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Prefix1")
		IniWrite(c2Prefix2, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Prefix2")
		IniWrite(c2Suffix1, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix1")
		IniWrite(c2Suffix2, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix2")
		IniWrite(c2Suffix3, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix3")
		IniWrite(c2Suffix4, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix4")
		IniWrite(c2Suffix5, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix5")
		IniWrite(c2Suffix6, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix6")
		IniWrite(c2Suffix7, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix7")
		IniWrite(c2Suffix8, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix8")
		IniWrite(c2Suffix9, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix9")

		IniWrite(c2Suffix1Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix1Text")
		IniWrite(c2Suffix2Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix2Text")
		IniWrite(c2Suffix3Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix3Text")
		IniWrite(c2Suffix4Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix4Text")
		IniWrite(c2Suffix5Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix5Text")
		IniWrite(c2Suffix6Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix6Text")
		IniWrite(c2Suffix7Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix7Text")
		IniWrite(c2Suffix8Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix8Text")
		IniWrite(c2Suffix9Text, A_ScriptDir "\save\Settings.ini", "Chat Hotkeys", "2Suffix9Text")

		IniWrite(stashPrefix1, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashPrefix1")
		IniWrite(stashPrefix2, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashPrefix2")
		IniWrite(stashSuffix1, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix1")
		IniWrite(stashSuffix2, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix2")
		IniWrite(stashSuffix3, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix3")
		IniWrite(stashSuffix4, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix4")
		IniWrite(stashSuffix5, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix5")
		IniWrite(stashSuffix6, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix6")
		IniWrite(stashSuffix7, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix7")
		IniWrite(stashSuffix8, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix8")
		IniWrite(stashSuffix9, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffix9")

		IniWrite(stashSuffixTab1, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab1")
		IniWrite(stashSuffixTab2, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab2")
		IniWrite(stashSuffixTab3, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab3")
		IniWrite(stashSuffixTab4, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab4")
		IniWrite(stashSuffixTab5, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab5")
		IniWrite(stashSuffixTab6, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab6")
		IniWrite(stashSuffixTab7, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab7")
		IniWrite(stashSuffixTab8, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab8")
		IniWrite(stashSuffixTab9, A_ScriptDir "\save\Settings.ini", "Stash Hotkeys", "stashSuffixTab9")

		;Controller setup
		IniWrite(hotkeyControllerButtonA, A_ScriptDir "\save\Settings.ini", "Controller Keys", "A")
		IniWrite(hotkeyControllerButtonB, A_ScriptDir "\save\Settings.ini", "Controller Keys", "B")
		IniWrite(hotkeyControllerButtonX, A_ScriptDir "\save\Settings.ini", "Controller Keys", "X")
		IniWrite(hotkeyControllerButtonY, A_ScriptDir "\save\Settings.ini", "Controller Keys", "Y")
		IniWrite(hotkeyControllerButtonLB, A_ScriptDir "\save\Settings.ini", "Controller Keys", "LB")
		IniWrite(hotkeyControllerButtonRB, A_ScriptDir "\save\Settings.ini", "Controller Keys", "RB")
		IniWrite(hotkeyControllerButtonBACK, A_ScriptDir "\save\Settings.ini", "Controller Keys", "BACK")
		IniWrite(hotkeyControllerButtonSTART, A_ScriptDir "\save\Settings.ini", "Controller Keys", "START")
		IniWrite(hotkeyControllerButtonL3, A_ScriptDir "\save\Settings.ini", "Controller Keys", "L3")
		IniWrite(hotkeyControllerButtonR3, A_ScriptDir "\save\Settings.ini", "Controller Keys", "R3")

		IniWrite(hotkeyControllerJoystickRight, A_ScriptDir "\save\Settings.ini", "Controller Keys", "JoystickRight")

		IniWrite(YesTriggerUtilityKey, A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerUtilityKey")
		IniWrite(YesTriggerUtilityJoystickKey, A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerUtilityJoystickKey")
		IniWrite(YesTriggerJoystickRightKey, A_ScriptDir "\save\Settings.ini", "Controller", "YesTriggerJoystickRightKey")
		IniWrite(TriggerUtilityKey, A_ScriptDir "\save\Settings.ini", "Controller", "TriggerUtilityKey")
		IniWrite(YesMovementKeys, A_ScriptDir "\save\Settings.ini", "Controller", "YesMovementKeys")
		IniWrite(YesController, A_ScriptDir "\save\Settings.ini", "Controller", "YesController")
		IniWrite(JoystickNumber, A_ScriptDir "\save\Settings.ini", "Controller", "JoystickNumber")

		;Settings for Ninja parse
		IniWrite(LastDatabaseParseDate, A_ScriptDir "\save\Settings.ini", "Database", "LastDatabaseParseDate")
		IniWrite(selectedLeague, A_ScriptDir "\save\Settings.ini", "Database", "selectedLeague")
		IniWrite(UpdateDatabaseInterval, A_ScriptDir "\save\Settings.ini", "Database", "UpdateDatabaseInterval")
		IniWrite(YesNinjaDatabase, A_ScriptDir "\save\Settings.ini", "Database", "YesNinjaDatabase")
		IniWrite(ForceMatch6Link, A_ScriptDir "\save\Settings.ini", "Database", "ForceMatch6Link")
		IniWrite(ForceMatchGem20, A_ScriptDir "\save\Settings.ini", "Database", "ForceMatchGem20")

		readFromFile()
		GuiUpdate()
		if WinExist("ahk_group POEGameGroup")
		{
			WinActivate("ahk_group POEGameGroup")
		}
		Thread("NoTimers", false) ;End Critical
	return
}

; Settings Save/Load
Settings(name:="perChar",Action:="Load"){
	local f, JSONtext, obj
	If (Action == "Load"){
		Try {
			if !FileExist(A_ScriptDir "\save\" name ".json")
				Return False
			f := FileOpen(A_ScriptDir "\save\" name ".json","r")
			JSONtext := f.Read()
			obj := JSON.Load(JSONtext)
			; Merge fields into the existing per-slot plain Objects rather than
			; replacing them. obj[k] is a cJson Map; direct assignment would
			; clobber the plain-Object slot and break later dot-access like
			; WR.Flask.%slot%.CD ('Map has no property named CD').
			For k, v in WR.%name%.OwnProps() {
				If !obj.Has(k)
					Continue
				If (IsObject(v) && IsObject(obj[k]))
					For l, w in v.OwnProps()
						If (obj[k].Has(l))
							WR.%name%.%k%.%l% := obj[k][l]
				Else
					WR.%name%.%k% := obj[k]
			}
		} catch as e {
			Util.Err(e, "Setting Load failed for .\save\" name ".json")
		}
	}Else If (Action == "Save"){
		f := FileOpen(A_ScriptDir "\save\" name ".json", "w")
		JSONtext := JSON.Dump(WR.%name%, 2)
		f.Write(JSONtext)
		JSONtext := ""
	}
}
; Profile Save/Load/Remove
Profile(args*){
	MainGui.Submit(0)
	confirm := False
	If (IsObject(args[1])){  ; called as GUI click handler (GuiCtrl, Info)
		split := StrSplit(args[1].Name, "_")
		Type := split[2]
		Action := split[3]
		name := MainGui["ProfileMenu" Type].Text
		confirm := True
	} Else {
		Type := args[1]
		Action := args[2]
		name := args[3]
	}
	If (name == ""){
		MsgBox("Profile name cannot be blank", "Whoah there clicky fingers", 262144)
		Return
	}
	If FileExist( A_ScriptDir "\save\profiles\" Type "\" name ".json"){
		If confirm
		{
			if (MsgBox("Please confirm you want to " Action " the " name " Profile", "Whoah there clicky fingers", 262148) == "No")
			Return
		}
	} Else If (Action != "Save") {
		MsgBox("Cannot " Action " the " name " Profile. The file does not exist.", "Whoah there clicky fingers", 262144)
		Return
	}

	If (Action == "Save") {
		FileOpen(A_ScriptDir "\save\profiles\" Type "\" name ".json","w").Write(JSON.Dump(WR.%Type%, 2))
		IniWrite(name, A_ScriptDir "\save\Settings.ini", "Chosen Profile", Type)
	} Else If (Action == "Load") {
		obj := JSON.LoadFile(A_ScriptDir "\save\profiles\" Type "\" name ".json")
		For k, v in WR.%Type%.OwnProps()
			If (IsObject(obj[k]))
			For l, w in v.OwnProps()
			If (obj[k].Has(l))
			WR.%Type%.%k%.%l% := obj[k][l]
		If (Type == "perChar"){
			If WR.perChar.Setting.profilesYesFlask
				If WR.perChar.Setting.profilesFlask
				Profile("Flask","Load",WR.perChar.Setting.profilesFlask)
			If WR.perChar.Setting.profilesYesUtility
				If WR.perChar.Setting.profilesUtility
				Profile("Utility","Load",WR.perChar.Setting.profilesUtility)
		}
		MainGui["ProfileMenu" Type].Choose(name)
		IniWrite(name, A_ScriptDir "\save\Settings.ini", "Chosen Profile", Type)
		Return
	}	Else If (Action == "Remove"){
		FileDelete(A_ScriptDir "\save\profiles\" Type "\" name ".json")
	}

	l := [], s := ""
	Loop Files, A_ScriptDir "\save\profiles\" Type "\*.json"
		l.Push(StrReplace(A_LoopFileName,".json",""))
	For k, v in l
		s .=(k=1?"||":"|") v
	If (s == "")
		s := "||"
	MainGui["ProfileMenu" Type].Delete()
	For k, v in StrSplit(LTrim(s, "|"), "|")
		MainGui["ProfileMenu" Type].Add([v])
	If (Action != "Remove")
		MainGui["ProfileMenu" Type].Choose(name)
	Return
}

LoadDisenchanting(){
	f := FileOpen(A_ScriptDir "\data\Disenchant.json","r")
	JSONtext := f.Read()
	obj := JSON.Load(JSONtext)
	WR.Disenchant := obj
}