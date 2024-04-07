readFromFile(){
	global
	Thread, NoTimers, True ;Critical

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

	For k, name in ["perChar","Flask","Utility"]
		IniRead, ProfileMenu%name%, %A_ScriptDir%\save\Settings.ini, Chosen Profile, %name%, % A_Space

	; Login Information
	; IniRead, PoECookie, %A_ScriptDir%\save\Account.ini, GGG, PoECookie, %A_Space%
	IniRead, AccountNameSTR, %A_ScriptDir%\save\Account.ini, GGG, AccountNameSTR, %A_Space%
	PoECookie := JSON.Load(FileOpen(A_ScriptDir "\save\Cookie.json","r").Read()).Cookie

	; GUI Position
	IniRead, WinGuiX, %A_ScriptDir%\save\Settings.ini, General, WinGuiX, 0
	IniRead, WinGuiY, %A_ScriptDir%\save\Settings.ini, General, WinGuiY, 0

	;General settings
	IniRead, BranchName, %A_ScriptDir%\save\Settings.ini, General, BranchName, master
	IniRead, ScriptUpdateTimeInterval, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval, 1
	IniRead, ScriptUpdateTimeType, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType, Off
	IniRead, Speed, %A_ScriptDir%\save\Settings.ini, General, Speed, 1
	IniRead, Tick, %A_ScriptDir%\save\Settings.ini, General, Tick, 50
	IniRead, KeyscanRate, %A_ScriptDir%\save\Settings.ini, General, KeyscanRate, 15
	IniRead, QTick, %A_ScriptDir%\save\Settings.ini, General, QTick, 250
	IniRead, DebugMessages, %A_ScriptDir%\save\Settings.ini, General, DebugMessages, 0
	IniRead, YesTimeMS, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS, 0
	IniRead, YesLocation, %A_ScriptDir%\save\Settings.ini, General, YesLocation, 0
	IniRead, ShowPixelGrid, %A_ScriptDir%\save\Settings.ini, General, ShowPixelGrid, 0
	IniRead, ShowItemInfo, %A_ScriptDir%\save\Settings.ini, General, ShowItemInfo, 0
	IniRead, LootVacuum, %A_ScriptDir%\save\Settings.ini, General, LootVacuum, 0
	IniRead, LootVacuumTapZ, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZ, 1
	IniRead, LootVacuumTapZEnd, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZEnd, 1
	IniRead, LootVacuumTapZSec, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZSec, 3
	IniRead, YesVendor, %A_ScriptDir%\save\Settings.ini, General, YesVendor, 1
	IniRead, YesStash, %A_ScriptDir%\save\Settings.ini, General, YesStash, 1
	IniRead, YesIdentify, %A_ScriptDir%\save\Settings.ini, General, YesIdentify, 1
	IniRead, YesDiv, %A_ScriptDir%\save\Settings.ini, General, YesDiv, 1
	IniRead, YesMapUnid, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid, 0
	IniRead, YesInfluencedUnid, %A_ScriptDir%\save\Settings.ini, General, YesInfluencedUnid, 0
	IniRead, YesCLFIgnoreImplicit, %A_ScriptDir%\save\Settings.ini, General, YesCLFIgnoreImplicit, 0
	IniRead, YesSortFirst, %A_ScriptDir%\save\Settings.ini, General, YesSortFirst, 1
	IniRead, Latency, %A_ScriptDir%\save\Settings.ini, General, Latency, 1
	IniRead, ClickLatency, %A_ScriptDir%\save\Settings.ini, General, ClickLatency, 0
	IniRead, ClipLatency, %A_ScriptDir%\save\Settings.ini, General, ClipLatency, 0
	IniRead, ShowOnStart, %A_ScriptDir%\save\Settings.ini, General, ShowOnStart, 1
	IniRead, PopFlaskRespectCD, %A_ScriptDir%\save\Settings.ini, General, PopFlaskRespectCD, 0
	IniRead, ResolutionScale, %A_ScriptDir%\save\Settings.ini, General, ResolutionScale, Standard
	IniRead, AutoUpdateOff, %A_ScriptDir%\save\Settings.ini, General, AutoUpdateOff, 0
	IniRead, EnableChatHotkeys, %A_ScriptDir%\save\Settings.ini, General, EnableChatHotkeys, 1
	IniRead, CharName, %A_ScriptDir%\save\Settings.ini, General, CharName, ReplaceWithCharName
	IniRead, EnableChatHotkeys, %A_ScriptDir%\save\Settings.ini, General, EnableChatHotkeys, 1
	IniRead, YesStashKeys, %A_ScriptDir%\save\Settings.ini, General, YesStashKeys, 1
	IniRead, YesGuiLastPosition, %A_ScriptDir%\save\Settings.ini, General, YesGuiLastPosition, 0
	IniRead, YesDX12, %A_ScriptDir%\save\Settings.ini, General, YesDX12, 0
	IniRead, YesSkipMaps, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps, 11
	IniRead, YesSkipMaps_Prep, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_Prep, 1
	IniRead, YesSkipMaps_eval, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval, >=
	IniRead, YesSkipMaps_normal, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal, 0
	IniRead, YesSkipMaps_magic, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic, 1
	IniRead, YesSkipMaps_rare, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare, 1
	IniRead, YesSkipMaps_unique, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique, 1
	IniRead, YesSkipMaps_tier, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier, 2
	IniRead, AreaScale, %A_ScriptDir%\save\Settings.ini, General, AreaScale, 60
	IniRead, LVdelay, %A_ScriptDir%\save\Settings.ini, General, LVdelay, 30
	IniRead, YesLootChests, %A_ScriptDir%\save\Settings.ini, General, YesLootChests, 1
	IniRead, YesLootDelve, %A_ScriptDir%\save\Settings.ini, General, YesLootDelve, 1
	IniRead, YesStashChaosRecipe, %A_ScriptDir%\save\Settings.ini, General, YesStashChaosRecipe, 0
	IniRead, YesInGameOverlay, %A_ScriptDir%\save\Settings.ini, General, YesInGameOverlay, 1
	IniRead, YesBatchVendorBauble, %A_ScriptDir%\save\Settings.ini, General, YesBatchVendorBauble, 1
	IniRead, YesBatchVendorGCP, %A_ScriptDir%\save\Settings.ini, General, YesBatchVendorGCP, 1
	IniRead, BrickedWhenCorrupted, %A_ScriptDir%\save\Settings.ini, General, BrickedWhenCorrupted, 1
	IniRead, YesOpenStackedDeck, %A_ScriptDir%\save\Settings.ini, General, YesOpenStackedDeck, 0
	IniRead, YesOpenVeiledScarab, %A_ScriptDir%\save\Settings.ini, General, YesOpenVeiledScarab, 0
	IniRead, YesSpecial5Link, %A_ScriptDir%\save\Settings.ini, General, YesSpecial5Link, 1
	IniRead, YesVendorDumpItems, %A_ScriptDir%\save\Settings.ini, General, YesVendorDumpItems, 0
	IniRead, HeistAlcNGo, %A_ScriptDir%\save\Settings.ini, General, HeistAlcNGo, 1
	IniRead, MoveMapsToArea, %A_ScriptDir%\save\Settings.ini, General, MoveMapsToArea, 1
	IniRead, YesIncludeFandSItem, %A_ScriptDir%\save\Settings.ini, General, YesIncludeFandSItem, 1
	IniRead, EnableRestock, %A_ScriptDir%\save\Settings.ini, General, EnableRestock, 1

	; CLF Options
	IniRead, CLFStrictnessNumber, %A_ScriptDir%\save\Settings.ini, General, CLFStrictnessNumber, 0

	; Basic Crafting Settings
	IniRead, BasicCraftChanceMethod, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftChanceMethod, 1
	IniRead, BasicCraftChanceScour, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftChanceScour, 1
	IniRead, BasicCraftColorMethod, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftColorMethod, 1
	IniRead, BasicCraftR, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftR, 0
	IniRead, BasicCraftG, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftG, 0
	IniRead, BasicCraftB, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftB, 0
	IniRead, BasicCraftLinkMethod, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftLinkMethod, 1
	IniRead, BasicCraftDesiredLinks, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftDesiredLinks, 0
	IniRead, BasicCraftLinkAuto, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftLinkAuto, 1
	IniRead, BasicCraftSocketMethod, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftSocketMethod, 1
	IniRead, BasicCraftDesiredSockets, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftDesiredSockets, 0
	IniRead, BasicCraftSocketAuto, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftSocketAuto, 1

	;Crafting Bases Options

	IniRead, YesStashBasesAboveIlvl, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesStashBasesAboveIlvl, 0
	IniRead, StashBasesAboveIlvl, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, StashBasesAboveIlvl, 68
	IniRead, YesCraftingBaseAutoUpdateOnStart, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseAutoUpdateOnStart, 0
	IniRead, YesCraftingBaseAutoUpdateOnZone, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseAutoUpdateOnZone, 0
	IniRead, YesCraftingBaseLimitBases, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseLimitBases, 0
	IniRead, CraftingBaseLimitBasesNumber, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, CraftingBaseLimitBasesNumber, 3

	;Item Crafting Options

	IniRead, ItemCraftingSubCategorySelector, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingSubCategorySelector, Abyss Jewels
	IniRead, ItemCraftingCategorySelector, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingCategorySelector, Ghastly Eye Jewel
	IniRead, ItemCraftingNumberPrefix, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberPrefix, 1
	IniRead, ItemCraftingNumberSuffix, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberSuffix, 1
	IniRead, ItemCraftingNumberCombination, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberCombination, 0
	IniRead, ItemCraftingMethod, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingMethod, Alteration Spam


	;Crafting Map Settings
	IniRead, StartMapTier1, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier1, 1
	IniRead, StartMapTier2, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier2, 6
	IniRead, StartMapTier3, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier3, 13
	IniRead, EndMapTier1, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier1, 5
	IniRead, EndMapTier2, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier2, 12
	IniRead, EndMapTier3, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier3, 16
	IniRead, CraftingMapMethod1, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod1, Disable
	IniRead, CraftingMapMethod2, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod2, Disable
	IniRead, CraftingMapMethod3, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod3, Disable
	IniRead, MMapItemQuantity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity, 1
	IniRead, MMapItemRarity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity, 1
	IniRead, MMapMonsterPackSize, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize, 1
	IniRead, EnableMQQForMagicMap, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap, 0
	IniRead, MMQorWeight, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMQorWeight, 0
	IniRead, MMapWeight, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapWeight, 0
	IniRead, ForceMaxChisel, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ForceMaxChisel, 0

	;Automation Settings
	IniRead, YesEnableAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation, 0
	IniRead, FirstAutomationSetting, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting, %A_Space%
	IniRead, YesEnableNextAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation, 0
	IniRead, YesEnableAutoSellConfirmation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation, 0
	IniRead, YesEnableAutoSellConfirmationSafe, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmationSafe, 0

	;Affinities
	IniRead, StashTabCurrency, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCurrency, 1
	IniRead, StashTabYesCurrency, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency, 0
	IniRead, StashTabMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMap, 1
	IniRead, StashTabYesMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap, 0
	IniRead, StashTabDivination, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDivination, 1
	IniRead, StashTabYesDivination, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination, 0
	IniRead, StashTabGem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGem, 1
	IniRead, StashTabYesGem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem, 1
	IniRead, StashTabFlask, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFlask, 1
	IniRead, StashTabYesFlask, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlask, 1
	IniRead, StashTabFragment, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFragment, 1
	IniRead, StashTabYesFragment, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment, 0
	IniRead, StashTabEssence, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabEssence, 1
	IniRead, StashTabYesEssence, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence, 0
	IniRead, StashTabBlight, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlight, 1
	IniRead, StashTabYesBlight, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlight, 0
	IniRead, StashTabDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium, 1
	IniRead, StashTabYesDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium, 0
	IniRead, StashTabDelve, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelve, 1
	IniRead, StashTabYesDelve, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelve, 0
	IniRead, StashTabUltimatum, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUltimatum, 1
	IniRead, StashTabYesUltimatum, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUltimatum, 0
	IniRead, StashTabUnique, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUnique, 1
	IniRead, StashTabYesUnique, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUnique, 1

	;Affinities Unique Options
	IniRead, StashTabUniqueRing, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueRing, 1
	IniRead, StashTabYesUniqueRing, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing, 1
	IniRead, StashTabUniqueDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueDump, 1
	IniRead, StashTabYesUniqueDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump, 1
	IniRead, StashTabYesUniquePercentage, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniquePercentage, 0
	IniRead, StashTabUniquePercentage, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniquePercentage, 70
	IniRead, StashTabYesUniqueRingAll, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRingAll, 0
	IniRead, StashTabYesUniqueDumpAll, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDumpAll, 0

	;Stash Tab Management
	IniRead, StashTabVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled, 1
	IniRead, StashTabYesVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled, 1
	IniRead, StashTabClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel, 1
	IniRead, StashTabYesClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesClusterJewel, 1
	IniRead, StashTabHeistGear, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabHeistGear, 1
	IniRead, StashTabYesHeistGear, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesHeistGear, 1
	IniRead, StashTabMiscMapItems, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMiscMapItems, 1
	IniRead, StashTabYesMiscMapItems, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMiscMapItems, 1
	IniRead, StashTabLinked, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabLinked, 1
	IniRead, StashTabYesLinked, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked, 1
	IniRead, StashTabBrickedMaps, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBrickedMaps, 1
	IniRead, StashTabYesBrickedMaps, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBrickedMaps, 1
	IniRead, StashTabInfluencedItem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabInfluencedItem, 1
	IniRead, StashTabYesInfluencedItem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem, 1
	IniRead, StashTabCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting, 1
	IniRead, StashTabYesCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting, 1
	IniRead, StashTabDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump, 1
	IniRead, StashTabYesDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump, 0
	IniRead, StashTabPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive, 1
	IniRead, StashTabYesPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive, 0
	IniRead, StashTabNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice, 1
	IniRead, StashTabYesNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice, 0

	;Dump Tab Options
	IniRead, StashDumpInTrial, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial, 0
	IniRead, StashDumpInTrial, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpSkipJC, 0

	;Priced Options
	IniRead, StashTabYesNinjaPrice_Price, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price, 5

	; Chaos Recipe Settings
	IniRead, ChaosRecipeEnableFunction, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeEnableFunction, 0
	IniRead, ChaosRecipeUnloadAll, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeUnloadAll, 0
	IniRead, ChaosRecipeSkipJC, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeSkipJC, 1
	IniRead, ChaosRecipeEnableUnId, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeEnableUnId, 1
	IniRead, ChaosRecipeSmallWeapons, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeSmallWeapons, 1
	IniRead, ChaosRecipeLimitUnId, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeLimitUnId, 74
	IniRead, ChaosRecipeAllowDoubleJewellery, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeAllowDoubleJewellery, 1
	IniRead, ChaosRecipeAllowDoubleBelt, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeAllowDoubleBelt, 0
	IniRead, ChaosRecipeMaxHoldingID, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeMaxHoldingID, 12
	IniRead, ChaosRecipeMaxHoldingUNID, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeMaxHoldingUNID, 12
	IniRead, ChaosRecipeTypePure, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypePure, 0
	IniRead, ChaosRecipeTypeHybrid, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeHybrid, 1
	IniRead, ChaosRecipeTypeRegal, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeRegal, 0
	IniRead, ChaosRecipeStashMethodDump, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodDump, 1
	IniRead, ChaosRecipeStashMethodTab, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodTab, 0
	IniRead, ChaosRecipeStashMethodSort, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodSort, 0
	IniRead, ChaosRecipeStashTab, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTab, 1
	IniRead, ChaosRecipeStashTabWeapon, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabWeapon, 1
	IniRead, ChaosRecipeStashTabHelmet, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabHelmet, 1
	IniRead, ChaosRecipeStashTabArmour, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabArmour, 1
	IniRead, ChaosRecipeStashTabGloves, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabGloves, 1
	IniRead, ChaosRecipeStashTabBoots, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabBoots, 1
	IniRead, ChaosRecipeStashTabBelt, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabBelt, 1
	IniRead, ChaosRecipeStashTabAmulet, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabAmulet, 1
	IniRead, ChaosRecipeStashTabRing, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashTabRing, 1

	;Settings for the Client Log file location
	IniRead, ClientLog, %A_ScriptDir%\save\Settings.ini, Log, ClientLog, %ClientLog%

	;Settings for the Overhead Health Bar
	IniRead, YesOHB, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB, 1

	;OHB Colors
	IniRead, OHBLHealthHex, %A_ScriptDir%\save\Settings.ini, OHB, OHBLHealthHex, 0x19A631

	;Ascii strings
	IniRead, HealthBarStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, HealthBarStr, %1080_HealthBarStr%
	If HealthBarStr
		OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
	IniRead, ChestStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, ChestStr, %1080_ChestStr%
	IniRead, DelveStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, DelveStr, %1080_DelveStr%
	IniRead, VendorStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorStr, %1080_MasterStr%
	IniRead, SellItemsStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, SellItemsStr, %1080_SellItemsStr%
	IniRead, StashStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, StashStr, %1080_StashStr%
	IniRead, SkillUpStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, SkillUpStr, %1080_SkillUpStr%
	IniRead, XButtonStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, XButtonStr, %1080_XButtonStr%
	IniRead, VendorLioneyeStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorLioneyeStr, %1080_BestelStr%
	IniRead, VendorForestStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorForestStr, %1080_GreustStr%
	IniRead, VendorSarnStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorSarnStr, %1080_ClarissaStr%
	IniRead, VendorHighgateStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorHighgateStr, %1080_PetarusStr%
	IniRead, VendorOverseerStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorOverseerStr, %1080_LaniStr%
	IniRead, VendorBridgeStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorBridgeStr, %1080_HelenaStr%
	IniRead, VendorDocksStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorDocksStr, %1080_LaniStr%
	IniRead, VendorOriathStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorOriathStr, %1080_LaniStr%
	IniRead, VendorHarbourStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorHarbourStr, %1080_FenceStr%
	IniRead, VendorMineStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorMineStr, %1080_MasterStr%

	; Debuff Strings
	IniRead, debuffCurseEleWeakStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseEleWeakStr,% A_Space
	IniRead, debuffCurseVulnStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseVulnStr,% A_Space
	IniRead, debuffCurseEnfeebleStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseEnfeebleStr,% A_Space
	IniRead, debuffCurseTempChainStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseTempChainStr,% A_Space
	IniRead, debuffCurseCondStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseCondStr,% A_Space
	IniRead, debuffCurseFlamStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseFlamStr,% A_Space
	IniRead, debuffCurseFrostStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseFrostStr,% A_Space
	IniRead, debuffCurseWarMarkStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffCurseWarMarkStr,% A_Space
	IniRead, debuffShockStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffShockStr,% A_Space
	IniRead, debuffBleedStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffBleedStr,% A_Space
	IniRead, debuffFreezeStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffFreezeStr,% A_Space
	IniRead, debuffIgniteStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffIgniteStr,% A_Space
	IniRead, debuffPoisonStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, debuffPoisonStr,% A_Space

	debuffCurseStr := debuffCurseEleWeakStr . debuffCurseVulnStr . debuffCurseEnfeebleStr . debuffCurseTempChainStr . debuffCurseCondStr . debuffCurseFlamStr . debuffCurseFrostStr . debuffCurseWarMarkStr

	;Inventory Colors
	IniRead, varEmptyInvSlotColor, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor, 0x000100,0x020402,0x000000,0x020302,0x010101,0x010201,0x060906,0x050905,0x030303,0x020202
	;Create an array out of the read string
	varEmptyInvSlotColor := StrSplit(varEmptyInvSlotColor, ",")

	;Loot Vacuum Colors
	IniRead, LootColors, %A_ScriptDir%\save\Settings.ini, Loot Colors, LootColors, 0xF2F2F2,0xC8C8C8,0xFE844B,0xEF581C,0xDA8B4D,0xAF5F1C,0xFEC140,0xF8960D,0xFECA22,0xD59F00,0xFCDDB2,0xD2B286,0x49226D,0x160040,0x8D35A0,0x600075,0x404040,0x0D0D0D,0x80DA51,0x53AF22,0x227A45,0x004D16,0x22512E,0x002200,0x224022,0x000D00,0x602222,0x320000,0xA3A3A3,0x777777
	;Create an array out of the read string
	LootColors := StrSplit(LootColors, ",")

	;Failsafe Colors
	IniRead, varOnMenu, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu, 0xD6B97B
	IniRead, varOnChar, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar, 0x6B5543
	IniRead, varOnChat, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat, 0x88623B
	IniRead, varOnInventory, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory, 0xDCC289
	IniRead, varOnStash, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash, 0xECDBA6
	IniRead, varOnVendor, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor, 0xCEB178
	IniRead, varOnVendorHeist, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendorHeist, 0xCEB178
	IniRead, varOnDiv, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv, 0xF6E2C5
	IniRead, varOnLeft, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft, 0xB58C4D
	IniRead, varOnDelveChart, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart, 0xE5B93F
	IniRead, varOnDetonate, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate, 0x5D4661
	IniRead, varOnDetonateDelve, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonateDelve, 0x5D4661

	;Grab Currency From Inventory
	IniRead, GrabCurrencyX, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyX, 1877
	IniRead, GrabCurrencyY, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyY, 772

	;~ hotkeys reset
	hotkey, IfWinActive, ahk_group POEGameGroup
		If hotkeyAutoQuit
		hotkey,% hotkeyAutoQuit, toggleAutoQuit, Off
	If hotkeyAutoFlask
		hotkey,% hotkeyAutoFlask, toggleAutoFlask, Off
	If hotkeyAutoMove
		hotkey,%hotkeyAutoMove%, toggleAutoMove, Off
	If hotkeyAutoUtility
		hotkey,%hotkeyAutoUtility%, toggleAutoUtility, Off
	If hotkeyQuickPortal
		hotkey,% hotkeyQuickPortal, QuickPortalCommand, Off
	If hotkeyGemSwap
		hotkey,% hotkeyGemSwap, GemSwapCommand, Off
	If hotkeyStartCraft
		hotkey,% hotkeyStartCraft, Crafting, Off
	If hotkeyItemCrafting
		hotkey,% hotkeyItemCrafting, CraftingItemCaller, Off
	If hotkeyCraftBasic
		hotkey,% hotkeyCraftBasic, CraftBasicPopUp, Off

	If hotkeyCtrlClicker
		hotkey % hotkeyCtrlClicker,% CtrlSpam, Off
	If hotkeyCtrlShiftClicker
		hotkey % hotkeyCtrlShiftClicker,% CtrlShiftSpam, Off
	If hotkeyShiftClicker
		hotkey % hotkeyShiftClicker,% ShiftSpam, Off
	Hotkey, If
		If hotkeyCtrlClicker
		hotkey % "*" hotkeyCtrlClicker " Up",% CtrlSpamOff, Off
	If hotkeyCtrlShiftClicker
		hotkey % "*" hotkeyCtrlShiftClicker " Up",% CtrlSpamOff, Off
	If hotkeyShiftClicker
		hotkey % "*" hotkeyShiftClicker " Up",% CtrlSpamOff, Off
	hotkey, IfWinActive, ahk_group POEGameGroup

	If hotkeyGrabCurrency
		hotkey,% hotkeyGrabCurrency, GrabCurrencyCommand, Off
	If hotkeyGetCoords
		hotkey,% hotkeyGetMouseCoords, CoordCommand, Off
	If hotkeyPopFlasks
		hotkey,% hotkeyPopFlasks, PopFlasksCommand, Off
	If hotkeyLogout
		hotkey,% hotkeyLogout, LogoutCommand, Off
	If hotkeyItemSort
		hotkey,% hotkeyItemSort, ItemSortCommand, Off
	If hotkeyItemInfo
		hotkey,% hotkeyItemInfo, ItemInfoCommand, Off
	If hotkeyChaosRecipe
		hotkey,% hotkeyChaosRecipe, VendorChaosRecipe, Off
	If hotkeyLootScan
	{
		hotkey, $~%hotkeyLootScan%, LootScanCommand, Off
		hotkey, $~*%hotkeyLootScan% Up, LootScanCommandRelease, Off
	}
	If hotkeyPauseMines
		hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, Off
	If hotkeyMainAttack
	{
		hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
		hotkey, $~*%hotkeyMainAttack% Up, MainAttackCommandRelease, Off
	}
	If hotkeySecondaryAttack
	{
		hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off
		hotkey, $~*%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, Off
	}

	hotkey, IfWinActive
		If hotkeyOptions
		hotkey,% hotkeyOptions, optionsCommand, Off
	hotkey, IfWinActive, ahk_group POEGameGroup

	;~ hotkeys iniread
	IniRead, hotkeyOptions, %A_ScriptDir%\save\Settings.ini, hotkeys, Options, !F10
	IniRead, hotkeyAutoQuit, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuit, !F12
	IniRead, hotkeyAutoFlask, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoFlask, !F11
	IniRead, hotkeyAutoMove, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoMove, !MButton
	IniRead, hotkeyAutoUtility, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoUtility, !MButton
	IniRead, hotkeyQuickPortal, %A_ScriptDir%\save\Settings.ini, hotkeys, QuickPortal, !q
	IniRead, hotkeyStartCraft, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft, F7
	IniRead, hotkeyItemCrafting, %A_ScriptDir%\save\Settings.ini, hotkeys, CraftingItemCaller, F11

	IniRead, hotkeyCraftBasic, %A_ScriptDir%\save\Settings.ini, hotkeys, CraftBasic, F9
	IniRead, hotkeyGemSwap, %A_ScriptDir%\save\Settings.ini, hotkeys, GemSwap, !e
	IniRead, hotkeyGrabCurrency, %A_ScriptDir%\save\Settings.ini, hotkeys, GrabCurrency, !a
	IniRead, hotkeyGetMouseCoords, %A_ScriptDir%\save\Settings.ini, hotkeys, GetMouseCoords, !o
	IniRead, hotkeyPopFlasks, %A_ScriptDir%\save\Settings.ini, hotkeys, PopFlasks, CapsLock
	IniRead, hotkeyLogout, %A_ScriptDir%\save\Settings.ini, hotkeys, Logout, F12
	IniRead, hotkeyCloseAllUI, %A_ScriptDir%\save\Settings.ini, hotkeys, CloseAllUI, Space
	IniRead, hotkeyInventory, %A_ScriptDir%\save\Settings.ini, hotkeys, Inventory, i
	IniRead, hotkeyWeaponSwapKey, %A_ScriptDir%\save\Settings.ini, hotkeys, WeaponSwapKey, x
	IniRead, hotkeyItemSort, %A_ScriptDir%\save\Settings.ini, hotkeys, ItemSort, F6
	IniRead, hotkeyItemInfo, %A_ScriptDir%\save\Settings.ini, hotkeys, ItemInfo, F5
	IniRead, hotkeyChaosRecipe, %A_ScriptDir%\save\Settings.ini, hotkeys, ChaosRecipe, F8
	IniRead, hotkeyLootScan, %A_ScriptDir%\save\Settings.ini, hotkeys, LootScan, f
	IniRead, hotkeyDetonateMines, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyDetonateMines, d
	IniRead, hotkeyOpenPortal, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyOpenPortal, % A_Space
	IniRead, hotkeyPauseMines, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyPauseMines, d
	IniRead, hotkeyMainAttack, %A_ScriptDir%\save\Settings.ini, hotkeys, MainAttack, RButton
	IniRead, hotkeySecondaryAttack, %A_ScriptDir%\save\Settings.ini, hotkeys, SecondaryAttack, w
	IniRead, hotkeyTriggerMovement, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyTriggerMovement, LButton
	IniRead, hotkeyCtrlClicker, %A_ScriptDir%\save\Settings.ini, hotkeys, CtrlClicker, % A_Space
	IniRead, hotkeyCtrlShiftClicker, %A_ScriptDir%\save\Settings.ini, hotkeys, CtrlShiftClicker, % A_Space
	IniRead, hotkeyShiftClicker, %A_ScriptDir%\save\Settings.ini, hotkeys, ShiftClicker, % A_Space

	hotkey, IfWinActive, ahk_group POEGameGroup
		If hotkeyAutoQuit
		hotkey,% hotkeyAutoQuit, toggleAutoQuit, On
	If hotkeyAutoFlask
		hotkey,% hotkeyAutoFlask, toggleAutoFlask, On
	If hotkeyAutoMove
		hotkey,%hotkeyAutoMove%, toggleAutoMove, On
	If hotkeyAutoUtility
		hotkey,%hotkeyAutoUtility%, toggleAutoUtility, On
	If hotkeyQuickPortal
		hotkey,% hotkeyQuickPortal, QuickPortalCommand, On
	If hotkeyGemSwap
		hotkey,% hotkeyGemSwap, GemSwapCommand, On
	If hotkeyStartCraft
		hotkey,% hotkeyStartCraft, Crafting, On
	If hotkeyItemCrafting
		hotkey,% hotkeyItemCrafting, CraftingItemCaller, On
	If hotkeyCraftBasic
		hotkey,% hotkeyCraftBasic, CraftBasicPopUp, On

	If hotkeyCtrlClicker
		hotkey % hotkeyCtrlClicker,% CtrlSpam, On
	If hotkeyCtrlShiftClicker
		hotkey % hotkeyCtrlShiftClicker,% CtrlShiftSpam, On
	If hotkeyShiftClicker
		hotkey % hotkeyShiftClicker,% ShiftSpam, On
	hotkey, If
		If hotkeyCtrlClicker
		hotkey % "*" hotkeyCtrlClicker " Up",% CtrlSpamOff, On
	If hotkeyCtrlShiftClicker
		hotkey % "*" hotkeyCtrlShiftClicker " Up",% CtrlSpamOff, On
	If hotkeyShiftClicker
		hotkey % "*" hotkeyShiftClicker " Up",% CtrlSpamOff, On
	hotkey, IfWinActive, ahk_group POEGameGroup

	If hotkeyGrabCurrency
		hotkey,% hotkeyGrabCurrency, GrabCurrencyCommand, On
	If hotkeyGetMouseCoords
		hotkey,% hotkeyGetMouseCoords, CoordCommand, On
	If hotkeyPopFlasks
		hotkey,% hotkeyPopFlasks, PopFlasksCommand, On
	If hotkeyLogout
		hotkey,% hotkeyLogout, LogoutCommand, On
	If hotkeyItemSort
		hotkey,% hotkeyItemSort, ItemSortCommand, On
	If hotkeyItemInfo
		hotkey,% hotkeyItemInfo, ItemInfoCommand, On
	If hotkeyChaosRecipe
		hotkey,% hotkeyChaosRecipe, VendorChaosRecipe, On
	If hotkeyLootScan
	{
		hotkey, $~%hotkeyLootScan%, LootScanCommand, On
		hotkey, $~*%hotkeyLootScan% Up, LootScanCommandRelease, On
	}
	If hotkeyMainAttack
	{
		hotkey, $~%hotkeyMainAttack%, MainAttackCommand, On
		hotkey, $~*%hotkeyMainAttack% Up, MainAttackCommandRelease, On
	}
	If hotkeySecondaryAttack
	{
		hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, On
		hotkey, $~*%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, On
	}

	#MaxThreadsPerHotkey, 1
	If hotkeyPauseMines
		hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, On
	#MaxThreadsPerHotkey, 2
	hotkey, IfWinActive
	If hotkeyOptions {
		hotkey,% hotkeyOptions, optionsCommand, On
	} else {
		hotkey,!F10, optionsCommand, On
		msgbox You dont have set the GUI hotkey!`nPlease hit Alt+F10 to open up the GUI and set your hotkey.
	}

	IniRead, 1Prefix1, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Prefix1, a
	IniRead, 1Prefix2, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Prefix2, %A_Space%
	IniRead, 1Suffix1, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix1, 1
	IniRead, 1Suffix2, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix2, 2
	IniRead, 1Suffix3, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix3, 3
	IniRead, 1Suffix4, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix4, 4
	IniRead, 1Suffix5, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix5, 5
	IniRead, 1Suffix6, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix6, 6
	IniRead, 1Suffix7, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix7, 7
	IniRead, 1Suffix8, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix8, 8
	IniRead, 1Suffix9, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix9, 9

	IniRead, 1Suffix1Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix1Text, /Hideout
	IniRead, 1Suffix2Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix2Text, /Delve
	IniRead, 1Suffix3Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix3Text, /cls
	IniRead, 1Suffix4Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix4Text, /ladder
	IniRead, 1Suffix5Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix5Text, /reset_xp
	IniRead, 1Suffix6Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix6Text, /invite RecipientName
	IniRead, 1Suffix7Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix7Text, /kick RecipientName
	IniRead, 1Suffix8Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix8Text, /kick CharacterName
	IniRead, 1Suffix9Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix9Text, @RecipientName Still Interested?

	IniRead, 2Prefix1, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Prefix1, d
	IniRead, 2Prefix2, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Prefix2, %A_Space%
	IniRead, 2Suffix1, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix1, 1
	IniRead, 2Suffix2, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix2, 2
	IniRead, 2Suffix3, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix3, 3
	IniRead, 2Suffix4, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix4, 4
	IniRead, 2Suffix5, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix5, 5
	IniRead, 2Suffix6, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix6, 6
	IniRead, 2Suffix7, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix7, 7
	IniRead, 2Suffix8, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix8, 8
	IniRead, 2Suffix9, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix9, 9

	IniRead, 2Suffix1Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix1Text, Sure, will invite in a sec.
	IniRead, 2Suffix2Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix2Text, In a map, will get to you in a minute.
	IniRead, 2Suffix3Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix3Text, Still Interested?
	IniRead, 2Suffix4Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix4Text, Sorry, going to be a while.
		IniRead, 2Suffix5Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix5Text, No thank you.
	IniRead, 2Suffix6Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix6Text, No thank you.
	IniRead, 2Suffix7Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix7Text, No thank you.
	IniRead, 2Suffix8Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix8Text, No thank you.
	IniRead, 2Suffix9Text, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix9Text, No thank you.

	IniRead, stashPrefix1, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashPrefix1, Numpad0
	IniRead, stashPrefix2, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashPrefix2, %A_Space%
	IniRead, stashSuffix1, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix1, Numpad1
	IniRead, stashSuffix2, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix2, Numpad2
	IniRead, stashSuffix3, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix3, Numpad3
	IniRead, stashSuffix4, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix4, Numpad4
	IniRead, stashSuffix5, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix5, Numpad5
	IniRead, stashSuffix6, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix6, Numpad6
	IniRead, stashSuffix7, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix7, Numpad7
	IniRead, stashSuffix8, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix8, Numpad8
	IniRead, stashSuffix9, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix9, Numpad9

	IniRead, stashSuffixTab1, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab1, 1
	IniRead, stashSuffixTab2, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab2, 2
	IniRead, stashSuffixTab3, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab3, 3
	IniRead, stashSuffixTab4, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab4, 4
	IniRead, stashSuffixTab5, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab5, 5
	IniRead, stashSuffixTab6, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab6, 6
	IniRead, stashSuffixTab7, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab7, 7
	IniRead, stashSuffixTab8, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab8, 8
	IniRead, stashSuffixTab9, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab9, 9

	;Controller setup
	IniRead, hotkeyControllerButtonA, %A_ScriptDir%\save\Settings.ini, Controller Keys, A, ^LButton
	IniRead, hotkeyControllerButtonB, %A_ScriptDir%\save\Settings.ini, Controller Keys, B, %hotkeyLootScan%
	IniRead, hotkeyControllerButtonX, %A_ScriptDir%\save\Settings.ini, Controller Keys, X, r
	IniRead, hotkeyControllerButtonY, %A_ScriptDir%\save\Settings.ini, Controller Keys, Y, %hotkeyCloseAllUI%
	IniRead, hotkeyControllerButtonLB, %A_ScriptDir%\save\Settings.ini, Controller Keys, LB, e
	IniRead, hotkeyControllerButtonRB, %A_ScriptDir%\save\Settings.ini, Controller Keys, RB, RButton
	IniRead, hotkeyControllerButtonBACK, %A_ScriptDir%\save\Settings.ini, Controller Keys, BACK, ItemSort
	IniRead, hotkeyControllerButtonSTART, %A_ScriptDir%\save\Settings.ini, Controller Keys, START, Tab
	IniRead, hotkeyControllerButtonL3, %A_ScriptDir%\save\Settings.ini, Controller Keys, L3, Logout
	IniRead, hotkeyControllerButtonR3, %A_ScriptDir%\save\Settings.ini, Controller Keys, R3, QuickPortal

	IniRead, hotkeyControllerJoystickRight, %A_ScriptDir%\save\Settings.ini, Controller Keys, JoystickRight, RButton

	IniRead, YesTriggerUtilityKey, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerUtilityKey, 1
	IniRead, YesTriggerUtilityJoystickKey, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerUtilityJoystickKey, 1
	IniRead, YesTriggerJoystickRightKey, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerJoystickRightKey, 1
	IniRead, TriggerUtilityKey, %A_ScriptDir%\save\Settings.ini, Controller, TriggerUtilityKey, 1
	IniRead, YesMovementKeys, %A_ScriptDir%\save\Settings.ini, Controller, YesMovementKeys, 0
	IniRead, YesController, %A_ScriptDir%\save\Settings.ini, Controller, YesController, 0
	IniRead, JoystickNumber, %A_ScriptDir%\save\Settings.ini, Controller, JoystickNumber, 0

	;settings for the Ninja Database
	IniRead, LastDatabaseParseDate, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate, 20190913
	IniRead, selectedLeague, %A_ScriptDir%\save\Settings.ini, Database, selectedLeague, Standard
	IniRead, UpdateDatabaseInterval, %A_ScriptDir%\save\Settings.ini, Database, UpdateDatabaseInterval, 2
	IniRead, YesNinjaDatabase, %A_ScriptDir%\save\Settings.ini, Database, YesNinjaDatabase, 1
	IniRead, ForceMatch6Link, %A_ScriptDir%\save\Settings.ini, Database, ForceMatch6Link, 0
	IniRead, ForceMatchGem20, %A_ScriptDir%\save\Settings.ini, Database, ForceMatchGem20, 0

	UnRegisterHotkeys()
	RegisterHotkeys()
	checkActiveType()
	Thread, NoTimers, False ;End Critical
	Return
}

submit(){
	updateEverything:
		global
		Thread, NoTimers, True ;Critical

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
		WinGetPos, winguix, winguiy, winW, winH, WingmanReloaded
		If !(WinGuiX = "" || WinGuiY = "")
		{
			IniWrite, %winguix%, %A_ScriptDir%\save\Settings.ini, General, WinGuiX
			IniWrite, %winguiy%, %A_ScriptDir%\save\Settings.ini, General, WinGuiY
		}

		;~ hotkeys reset
		hotkey, IfWinActive, ahk_group POEGameGroup
			If hotkeyAutoQuit
			hotkey,% hotkeyAutoQuit, toggleAutoQuit, Off
		If hotkeyAutoFlask
			hotkey,% hotkeyAutoFlask, toggleAutoFlask, Off
		If hotkeyQuickPortal
			hotkey,% hotkeyQuickPortal, QuickPortalCommand, Off
		If hotkeyGemSwap
			hotkey,% hotkeyGemSwap, GemSwapCommand, Off
		If hotkeyStartCraft
			hotkey,% hotkeyStartCraft, Crafting, Off
		If hotkeyItemCrafting
			hotkey,% hotkeyItemCrafting, CraftingItemCaller, Off
		If hotkeyCraftBasic
			hotkey,% hotkeyCraftBasic, CraftBasicPopUp, Off

		If hotkeyCtrlClicker
			hotkey % hotkeyCtrlClicker,% CtrlSpam, Off
		If hotkeyCtrlShiftClicker
			hotkey % hotkeyCtrlShiftClicker,% CtrlShiftSpam, Off
		If hotkeyShiftClicker
			hotkey % hotkeyShiftClicker,% ShiftSpam, Off
		hotkey, If
			If hotkeyCtrlClicker
			hotkey % "*" hotkeyCtrlClicker " Up",% CtrlSpamOff, Off
		If hotkeyCtrlShiftClicker
			hotkey % "*" hotkeyCtrlShiftClicker " Up",% CtrlSpamOff, Off
		If hotkeyShiftClicker
			hotkey % "*" hotkeyShiftClicker " Up",% CtrlSpamOff, Off
		hotkey, IfWinActive, ahk_group POEGameGroup

		If hotkeyGrabCurrency
			hotkey,% hotkeyGrabCurrency, GrabCurrencyCommand, Off
		If hotkeyGetCoords
			hotkey,% hotkeyGetMouseCoords, CoordCommand, Off
		If hotkeyPopFlasks
			hotkey,% hotkeyPopFlasks, PopFlasksCommand, Off
		If hotkeyLogout
			hotkey,% hotkeyLogout, LogoutCommand, Off
		If hotkeyItemSort
			hotkey,% hotkeyItemSort, ItemSortCommand, Off
		If hotkeyItemInfo
			hotkey,% hotkeyItemInfo, ItemInfoCommand, Off
		If hotkeyChaosRecipe
			hotkey,% hotkeyChaosRecipe, VendorChaosRecipe, Off
		If hotkeyLootScan
		{
			hotkey, $~%hotkeyLootScan%, LootScanCommand, Off
			hotkey, $~*%hotkeyLootScan% Up, LootScanCommandRelease, Off
		}
		If hotkeyPauseMines
			hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, Off
		If hotkeyMainAttack
		{
			hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
			hotkey, $~*%hotkeyMainAttack% Up, MainAttackCommandRelease, Off
		}
		If hotkeySecondaryAttack
		{
			hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off
			hotkey, $~*%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, Off
		}

		UnRegisterHotkeys()

		hotkey, IfWinActive
			If hotkeyOptions
			hotkey,% hotkeyOptions, optionsCommand, Off
		hotkey, IfWinActive, ahk_group POEGameGroup

		IfWinExist, ahk_group POEGameGroup
		{
			Gui, Submit
			Rescale()
			Gui 2: Show,% "x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15
			ToggleExist := True
			WinActivate, ahk_group POEGameGroup
		}

		Gui, Submit, NoHide

		IniWrite, %AccountNameSTR%, %A_ScriptDir%\save\Account.ini, GGG, AccountNameSTR
		temp := {"Cookie":PoECookie}
		t := JSON_Beautify(temp)
		FileDelete, %A_ScriptDir%\save\Cookie.json
		FileAppend, % t, %A_ScriptDir%\save\Cookie.json
		t := temp := ""

		;Bandit Extra options
		IniWrite, %BranchName%, %A_ScriptDir%\save\Settings.ini, General, BranchName
		IniWrite, %ScriptUpdateTimeInterval%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval
		IniWrite, %ScriptUpdateTimeType%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType
		IniWrite, %DebugMessages%, %A_ScriptDir%\save\Settings.ini, General, DebugMessages
		IniWrite, %YesTimeMS%, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS
		IniWrite, %YesLocation%, %A_ScriptDir%\save\Settings.ini, General, YesLocation
		IniWrite, %ShowPixelGrid%, %A_ScriptDir%\save\Settings.ini, General, ShowPixelGrid
		IniWrite, %ShowItemInfo%, %A_ScriptDir%\save\Settings.ini, General, ShowItemInfo
		IniWrite, %LootVacuum%, %A_ScriptDir%\save\Settings.ini, General, LootVacuum
		IniWrite, %YesVendor%, %A_ScriptDir%\save\Settings.ini, General, YesVendor
		IniWrite, %YesStash%, %A_ScriptDir%\save\Settings.ini, General, YesStash
		IniWrite, %YesIdentify%, %A_ScriptDir%\save\Settings.ini, General, YesIdentify
		IniWrite, %YesDiv%, %A_ScriptDir%\save\Settings.ini, General, YesDiv
		IniWrite, %YesMapUnid%, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid
		IniWrite, %YesInfluencedUnid%, %A_ScriptDir%\save\Settings.ini, General, YesInfluencedUnid
		IniWrite, %YesCLFIgnoreImplicit%, %A_ScriptDir%\save\Settings.ini, General, YesCLFIgnoreImplicit
		IniWrite, %YesSortFirst%, %A_ScriptDir%\save\Settings.ini, General, YesSortFirst
		IniWrite, %Latency%, %A_ScriptDir%\save\Settings.ini, General, Latency
		IniWrite, %ClickLatency%, %A_ScriptDir%\save\Settings.ini, General, ClickLatency
		IniWrite, %ClipLatency%, %A_ScriptDir%\save\Settings.ini, General, ClipLatency
		IniWrite, %ShowOnStart%, %A_ScriptDir%\save\Settings.ini, General, ShowOnStart
		IniWrite, %PopFlaskRespectCD%, %A_ScriptDir%\save\Settings.ini, General, PopFlaskRespectCD
		IniWrite, %EnableChatHotkeys%, %A_ScriptDir%\save\Settings.ini, General, EnableChatHotkeys
		IniWrite, %YesStashKeys%, %A_ScriptDir%\save\Settings.ini, General, YesStashKeys
		IniWrite, %YesSkipMaps%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps
		IniWrite, %YesSkipMaps_Prep%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_Prep
		IniWrite, %YesSkipMaps_eval%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval
		IniWrite, %YesSkipMaps_normal%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal
		IniWrite, %YesSkipMaps_magic%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic
		IniWrite, %YesSkipMaps_rare%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare
		IniWrite, %YesSkipMaps_unique%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique
		IniWrite, %YesSkipMaps_tier%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier
		IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
		IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
		IniWrite, %YesBatchVendorBauble%, %A_ScriptDir%\save\Settings.ini, General, YesBatchVendorBauble
		IniWrite, %YesBatchVendorGCP%, %A_ScriptDir%\save\Settings.ini, General, YesBatchVendorGCP
		IniWrite, %BrickedWhenCorrupted%, %A_ScriptDir%\save\Settings.ini, General, BrickedWhenCorrupted
		IniWrite, %YesOpenStackedDeck%, %A_ScriptDir%\save\Settings.ini, General, YesOpenStackedDeck
		IniWrite, %YesOpenVeiledScarab%, %A_ScriptDir%\save\Settings.ini, General, YesOpenVeiledScarab
		IniWrite, %YesSpecial5Link%, %A_ScriptDir%\save\Settings.ini, General, YesSpecial5Link
		IniWrite, %YesVendorDumpItems%, %A_ScriptDir%\save\Settings.ini, General, YesVendorDumpItems
		IniWrite, %HeistAlcNGo%, %A_ScriptDir%\save\Settings.ini, General, HeistAlcNGo
		IniWrite, %MoveMapsToArea%, %A_ScriptDir%\save\Settings.ini, General, MoveMapsToArea
		IniWrite, %YesIncludeFandSItem%, %A_ScriptDir%\save\Settings.ini, General, YesIncludeFandSItem
		IniWrite, %EnableRestock%, %A_ScriptDir%\save\Settings.ini, General, EnableRestock

		; CLF Options
		IniWrite, %CLFStrictnessNumber%, %A_ScriptDir%\save\Settings.ini, General, CLFStrictnessNumber

		; Overhead Health Bar
		IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB

		; ASCII Search Strings
		IniWrite, %HealthBarStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, HealthBarStr
		IniWrite, %VendorStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorStr
		IniWrite, %SellItemsStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SellItemsStr
		IniWrite, %StashStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, StashStr
		IniWrite, %SkillUpStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SkillUpStr

		;~ Hotkeys
		IniWrite, %hotkeyOptions%, %A_ScriptDir%\save\Settings.ini, hotkeys, Options
		IniWrite, %hotkeyAutoQuit%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuit
		IniWrite, %hotkeyAutoFlask%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoFlask
		IniWrite, %hotkeyAutoMove%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoMove
		IniWrite, %hotkeyAutoUtility%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoUtility
		IniWrite, %hotkeyQuickPortal%, %A_ScriptDir%\save\Settings.ini, hotkeys, QuickPortal
		IniWrite, %hotkeyGemSwap%, %A_ScriptDir%\save\Settings.ini, hotkeys, GemSwap
		IniWrite, %hotkeyStartCraft%, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft
		IniWrite, %hotkeyItemCrafting%, %A_ScriptDir%\save\Settings.ini, hotkeys, CraftingItemCaller
		IniWrite, %hotkeyCraftBasic%, %A_ScriptDir%\save\Settings.ini, hotkeys, CraftBasic
		IniWrite, %hotkeyCtrlClicker%, %A_ScriptDir%\save\Settings.ini, hotkeys, CtrlClicker
		IniWrite, %hotkeyCtrlShiftClicker%, %A_ScriptDir%\save\Settings.ini, hotkeys, CtrlShiftClicker
		IniWrite, %hotkeyShiftClicker%, %A_ScriptDir%\save\Settings.ini, hotkeys, ShiftClicker
		IniWrite, %hotkeyGrabCurrency%, %A_ScriptDir%\save\Settings.ini, hotkeys, GrabCurrency
		IniWrite, %hotkeyGetMouseCoords%, %A_ScriptDir%\save\Settings.ini, hotkeys, GetMouseCoords
		IniWrite, %hotkeyPopFlasks%, %A_ScriptDir%\save\Settings.ini, hotkeys, PopFlasks
		IniWrite, %hotkeyLogout%, %A_ScriptDir%\save\Settings.ini, hotkeys, Logout
		IniWrite, %hotkeyCloseAllUI%, %A_ScriptDir%\save\Settings.ini, hotkeys, CloseAllUI
		IniWrite, %hotkeyInventory%, %A_ScriptDir%\save\Settings.ini, hotkeys, Inventory
		IniWrite, %hotkeyWeaponSwapKey%, %A_ScriptDir%\save\Settings.ini, hotkeys, WeaponSwapKey
		IniWrite, %hotkeyItemSort%, %A_ScriptDir%\save\Settings.ini, hotkeys, ItemSort
		IniWrite, %hotkeyItemInfo%, %A_ScriptDir%\save\Settings.ini, hotkeys, ItemInfo
		IniWrite, %hotkeyChaosRecipe%, %A_ScriptDir%\save\Settings.ini, hotkeys, ChaosRecipe
		IniWrite, %hotkeyLootScan%, %A_ScriptDir%\save\Settings.ini, hotkeys, LootScan
		IniWrite, %hotkeyDetonateMines%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyDetonateMines
		IniWrite, %hotkeyOpenPortal%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyOpenPortal
		IniWrite, %hotkeyPauseMines%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyPauseMines
		IniWrite, %hotkeyMainAttack%, %A_ScriptDir%\save\Settings.ini, hotkeys, MainAttack
		IniWrite, %hotkeySecondaryAttack%, %A_ScriptDir%\save\Settings.ini, hotkeys, SecondaryAttack
		IniWrite, %hotkeyTriggerMovement%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyTriggerMovement

		;Utility Keys
		IniWrite, %hotkeyUp%, %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyUp
		IniWrite, %hotkeyDown%, %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyDown
		IniWrite, %hotkeyLeft%, %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyLeft
		IniWrite, %hotkeyRight%, %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyRight

		;Grab Currency
		IniWrite, %GrabCurrencyX%, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyX
		IniWrite, %GrabCurrencyY%, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyY

		;Crafting Bases Options

		IniWrite, %YesStashBasesAboveIlvl%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesStashBasesAboveIlvl
		IniWrite, %StashBasesAboveIlvl%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, StashBasesAboveIlvl
		IniWrite, %YesCraftingBaseAutoUpdateOnStart%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseAutoUpdateOnStart
		IniWrite, %YesCraftingBaseAutoUpdateOnZone%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseAutoUpdateOnZone
		IniWrite, %YesCraftingBaseLimitBases%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, YesCraftingBaseLimitBases
		IniWrite, %CraftingBaseLimitBasesNumber%, %A_ScriptDir%\save\Settings.ini, Crafting Bases Settings, CraftingBaseLimitBasesNumber

		;Item Crafting Options

		IniWrite, %ItemCraftingSubCategorySelector%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingSubCategorySelector
		IniWrite, %ItemCraftingCategorySelector%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingCategorySelector
		IniWrite, %ItemCraftingNumberPrefix%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberPrefix
		IniWrite, %ItemCraftingNumberSuffix%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberSuffix
		IniWrite, %ItemCraftingNumberCombination%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingNumberCombination
		IniWrite, %ItemCraftingMethod%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, ItemCraftingMethod

		;Crafting Map Settings
		IniWrite, %StartMapTier1%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier1
		IniWrite, %StartMapTier2%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier2
		IniWrite, %StartMapTier3%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, StartMapTier3
		IniWrite, %EndMapTier1%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier1
		IniWrite, %EndMapTier2%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier2
		IniWrite, %EndMapTier3%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EndMapTier3
		IniWrite, %CraftingMapMethod1%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod1
		IniWrite, %CraftingMapMethod2%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod2
		IniWrite, %CraftingMapMethod3%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, CraftingMapMethod3
		IniWrite, %MMapItemQuantity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity
		IniWrite, %MMapItemRarity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity
		IniWrite, %MMapMonsterPackSize%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize
		IniWrite, %EnableMQQForMagicMap%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap
		IniWrite, %MMQorWeight%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMQorWeight
		IniWrite, %MMapWeight%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapWeight
		IniWrite, %ForceMaxChisel%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ForceMaxChisel

		;Affinities
		IniWrite, %StashTabCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCurrency
		IniWrite, %StashTabYesCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency
		IniWrite, %StashTabMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMap
		IniWrite, %StashTabYesMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap
		IniWrite, %StashTabDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDivination
		IniWrite, %StashTabYesDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination
		IniWrite, %StashTabGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGem
		IniWrite, %StashTabYesGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem
		IniWrite, %StashTabFlask%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFlask
		IniWrite, %StashTabYesFlask%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlask
		IniWrite, %StashTabFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFragment
		IniWrite, %StashTabYesFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment
		IniWrite, %StashTabEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabEssence
		IniWrite, %StashTabYesEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence
		IniWrite, %StashTabBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlight
		IniWrite, %StashTabYesBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlight
		IniWrite, %StashTabDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium
		IniWrite, %StashTabYesDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium
		IniWrite, %StashTabDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelve
		IniWrite, %StashTabYesDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelve
		IniWrite, %StashTabUltimatum%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUltimatum
		IniWrite, %StashTabYesUltimatum%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUltimatum
		IniWrite, %StashTabUnique%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUnique
		IniWrite, %StashTabYesUnique%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUnique

		;Affinities Unique Options
		IniWrite, %StashTabUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueRing
		IniWrite, %StashTabYesUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing
		IniWrite, %StashTabUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueDump
		IniWrite, %StashTabYesUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump
		IniWrite, %StashTabYesUniquePercentage%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniquePercentage
		IniWrite, %StashTabUniquePercentage%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniquePercentage
		IniWrite, %StashTabYesUniqueRingAll%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRingAll
		IniWrite, %StashTabYesUniqueDumpAll%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDumpAll

		;Stash Tab Management
		IniWrite, %StashTabVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled
		IniWrite, %StashTabYesVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled
		IniWrite, %StashTabClusterJewel%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel
		IniWrite, %StashTabYesClusterJewel%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesClusterJewel
		IniWrite, %StashTabHeistGear%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabHeistGear
		IniWrite, %StashTabYesHeistGear%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesHeistGear
		IniWrite, %StashTabMiscMapItems%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMiscMapItems
		IniWrite, %StashTabYesMiscMapItems%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMiscMapItems
		IniWrite, %StashTabLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabLinked
		IniWrite, %StashTabYesLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked
		IniWrite, %StashTabBrickedMaps%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBrickedMaps
		IniWrite, %StashTabYesBrickedMaps%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBrickedMaps
		IniWrite, %StashTabInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabInfluencedItem
		IniWrite, %StashTabYesInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem
		IniWrite, %StashTabCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting
		IniWrite, %StashTabYesCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting
		IniWrite, %StashTabDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump
		IniWrite, %StashTabYesDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump
		IniWrite, %StashTabPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive
		IniWrite, %StashTabYesPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive
		IniWrite, %StashTabNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice
		IniWrite, %StashTabYesNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice

		;Dump Tab Options
		IniWrite, %StashDumpInTrial%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial
		IniWrite, %StashDumpInTrial%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpSkipJC

		;Priced Options
		IniWrite, %StashTabYesNinjaPrice_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price

		;Chat Hotkeys
		IniWrite, %1Prefix1%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Prefix1
		IniWrite, %1Prefix2%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Prefix2
		IniWrite, %1Suffix1%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix1
		IniWrite, %1Suffix2%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix2
		IniWrite, %1Suffix3%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix3
		IniWrite, %1Suffix4%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix4
		IniWrite, %1Suffix5%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix5
		IniWrite, %1Suffix6%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix6
		IniWrite, %1Suffix7%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix7
		IniWrite, %1Suffix8%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix8
		IniWrite, %1Suffix9%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix9

		IniWrite, %1Suffix1Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix1Text
		IniWrite, %1Suffix2Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix2Text
		IniWrite, %1Suffix3Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix3Text
		IniWrite, %1Suffix4Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix4Text
		IniWrite, %1Suffix5Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix5Text
		IniWrite, %1Suffix6Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix6Text
		IniWrite, %1Suffix7Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix7Text
		IniWrite, %1Suffix8Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix8Text
		IniWrite, %1Suffix9Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 1Suffix9Text

		IniWrite, %2Prefix1%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Prefix1
		IniWrite, %2Prefix2%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Prefix2
		IniWrite, %2Suffix1%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix1
		IniWrite, %2Suffix2%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix2
		IniWrite, %2Suffix3%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix3
		IniWrite, %2Suffix4%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix4
		IniWrite, %2Suffix5%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix5
		IniWrite, %2Suffix6%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix6
		IniWrite, %2Suffix7%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix7
		IniWrite, %2Suffix8%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix8
		IniWrite, %2Suffix9%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix9

		IniWrite, %2Suffix1Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix1Text
		IniWrite, %2Suffix2Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix2Text
		IniWrite, %2Suffix3Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix3Text
		IniWrite, %2Suffix4Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix4Text
		IniWrite, %2Suffix5Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix5Text
		IniWrite, %2Suffix6Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix6Text
		IniWrite, %2Suffix7Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix7Text
		IniWrite, %2Suffix8Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix8Text
		IniWrite, %2Suffix9Text%, %A_ScriptDir%\save\Settings.ini, Chat Hotkeys, 2Suffix9Text

		IniWrite, %stashPrefix1%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashPrefix1
		IniWrite, %stashPrefix2%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashPrefix2
		IniWrite, %stashSuffix1%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix1
		IniWrite, %stashSuffix2%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix2
		IniWrite, %stashSuffix3%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix3
		IniWrite, %stashSuffix4%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix4
		IniWrite, %stashSuffix5%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix5
		IniWrite, %stashSuffix6%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix6
		IniWrite, %stashSuffix7%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix7
		IniWrite, %stashSuffix8%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix8
		IniWrite, %stashSuffix9%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffix9

		IniWrite, %stashSuffixTab1%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab1
		IniWrite, %stashSuffixTab2%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab2
		IniWrite, %stashSuffixTab3%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab3
		IniWrite, %stashSuffixTab4%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab4
		IniWrite, %stashSuffixTab5%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab5
		IniWrite, %stashSuffixTab6%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab6
		IniWrite, %stashSuffixTab7%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab7
		IniWrite, %stashSuffixTab8%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab8
		IniWrite, %stashSuffixTab9%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashSuffixTab9

		;Controller setup
		IniWrite, %hotkeyControllerButtonA%, %A_ScriptDir%\save\Settings.ini, Controller Keys, A
		IniWrite, %hotkeyControllerButtonB%, %A_ScriptDir%\save\Settings.ini, Controller Keys, B
		IniWrite, %hotkeyControllerButtonX%, %A_ScriptDir%\save\Settings.ini, Controller Keys, X
		IniWrite, %hotkeyControllerButtonY%, %A_ScriptDir%\save\Settings.ini, Controller Keys, Y
		IniWrite, %hotkeyControllerButtonLB%, %A_ScriptDir%\save\Settings.ini, Controller Keys, LB
		IniWrite, %hotkeyControllerButtonRB%, %A_ScriptDir%\save\Settings.ini, Controller Keys, RB
		IniWrite, %hotkeyControllerButtonBACK%, %A_ScriptDir%\save\Settings.ini, Controller Keys, BACK
		IniWrite, %hotkeyControllerButtonSTART%, %A_ScriptDir%\save\Settings.ini, Controller Keys, START
		IniWrite, %hotkeyControllerButtonL3%, %A_ScriptDir%\save\Settings.ini, Controller Keys, L3
		IniWrite, %hotkeyControllerButtonR3%, %A_ScriptDir%\save\Settings.ini, Controller Keys, R3

		IniWrite, %hotkeyControllerJoystickRight%, %A_ScriptDir%\save\Settings.ini, Controller Keys, JoystickRight

		IniWrite, %YesTriggerUtilityKey%, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerUtilityKey
		IniWrite, %YesTriggerUtilityJoystickKey%, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerUtilityJoystickKey
		IniWrite, %YesTriggerJoystickRightKey%, %A_ScriptDir%\save\Settings.ini, Controller, YesTriggerJoystickRightKey
		IniWrite, %TriggerUtilityKey%, %A_ScriptDir%\save\Settings.ini, Controller, TriggerUtilityKey
		IniWrite, %YesMovementKeys%, %A_ScriptDir%\save\Settings.ini, Controller, YesMovementKeys
		IniWrite, %YesController%, %A_ScriptDir%\save\Settings.ini, Controller, YesController
		IniWrite, %JoystickNumber%, %A_ScriptDir%\save\Settings.ini, Controller, JoystickNumber

		;Settings for Ninja parse
		IniWrite, %LastDatabaseParseDate%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
		IniWrite, %selectedLeague%, %A_ScriptDir%\save\Settings.ini, Database, selectedLeague
		IniWrite, %UpdateDatabaseInterval%, %A_ScriptDir%\save\Settings.ini, Database, UpdateDatabaseInterval
		IniWrite, %YesNinjaDatabase%, %A_ScriptDir%\save\Settings.ini, Database, YesNinjaDatabase
		IniWrite, %ForceMatch6Link%, %A_ScriptDir%\save\Settings.ini, Database, ForceMatch6Link
		IniWrite, %ForceMatchGem20%, %A_ScriptDir%\save\Settings.ini, Database, ForceMatchGem20

		readFromFile()
		GuiUpdate()
		IfWinExist, ahk_group POEGameGroup
		{
			WinActivate, ahk_group POEGameGroup
		}
		Thread, NoTimers, False ;End Critical
	return
}

; Settings Save/Load
Settings(name:="perChar",Action:="Load"){
	local f, JSONtext, obj
	If (Action = "Load"){
		Try {
			IfNotExist, %A_ScriptDir%\save\%name%.json
				Return False
			f := FileOpen(A_ScriptDir "\save\" name ".json","r")
			JSONtext := f.Read()
			obj := JSON.Load(JSONtext)
			For k, v in WR[name] {
				If (obj.HasKey(k)) {
					WR[name][k] := obj[k]
				}
			}
		} Catch e {
			Util.Err(e, "Setting Load failed for .\save\" name ".json")
		}
	}Else If (Action = "Save"){
		f := FileOpen(A_ScriptDir "\save\" name ".json", "w")
		JSONtext := JSON.Dump(WR[name],,2)
		f.Write(JSONtext)
		JSONtext := ""
	}
}
; Profile Save/Load/Remove
Profile(args*){
	Gui, submit, nohide
	confirm := False
	If (!(args) || args[2] = "Normal"){
		split := StrSplit(A_GuiControl,"_")
		Type := split[2]
		Action := split[3]
		ControlGetText, name,% ProfileMenu%Type%
		confirm := True
	} Else {
		Type := args[1]
		Action := args[2]
		name := args[3]
	}
	If (name = ""){
		MsgBox, 262144, Whoah there clicky fingers, Profile name cannot be blank
		Return
	}
	If FileExist( A_ScriptDir "\save\profiles\" Type "\" name ".json"){
		If confirm
		{
			MsgBox, 262148, Whoah there clicky fingers, Please confirm you want to %Action% the %name% Profile
			IfMsgBox No
			Return
		}
	} Else If (Action != "Save") {
		MsgBox, 262144, Whoah there clicky fingers, Cannot %Action% the %name% Profile. The file does not exist.
		Return
	}

	If (Action = "Save") {
		FileOpen(A_ScriptDir "\save\profiles\" Type "\" name ".json","w").Write(JSON.Dump(WR[Type],,2))
		IniWrite, % ProfileMenu%Type%, %A_ScriptDir%\save\Settings.ini, Chosen Profile, %Type%
	} Else If (Action = "Load") {
		obj := JSON.Load(FileOpen(A_ScriptDir "\save\profiles\" Type "\" name ".json","r").Read())
		For k, v in WR[Type]
			If (IsObject(obj[k]))
			For l, w in v
			If (obj[k].HasKey(l))
			WR[Type][k][l] := obj[k][l]
		If (Type = "perChar"){
			If WR.perChar.Setting.profilesYesFlask
				If WR.perChar.Setting.profilesFlask
				Profile("Flask","Load",WR.perChar.Setting.profilesFlask)
			If WR.perChar.Setting.profilesYesUtility
				If WR.perChar.Setting.profilesUtility
				Profile("Utility","Load",WR.perChar.Setting.profilesUtility)
		}
		GuiControl, ChooseString, ProfileMenu%Type%, % name
		IniWrite, % name, %A_ScriptDir%\save\Settings.ini, Chosen Profile, %Type%
		Return
	}	Else If (Action = "Remove"){
		FileDelete, %A_ScriptDir%\save\profiles\%Type%\%name%.json
	}

	l := [], s := ""
	Loop, Files, %A_ScriptDir%\save\profiles\%Type%\*.json
		l.Push(StrReplace(A_LoopFileName,".json",""))
	For k, v in l
		s .=(k=1?"||":"|") v
	If (s = "")
		s := "||"
	GuiControl, , ProfileMenu%Type% , %s%
	If (Action != "Remove")
		GuiControl, ChooseString, ProfileMenu%Type% , %name%
	Return
}