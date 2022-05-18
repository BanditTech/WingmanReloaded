; Extra vars - Not in INI
Global rxNum := "(\d+\.?\d*)"
Global Controller := {"Btn":{}}
Global Controller_Active := 0
Global Item
Global WR_Statusbar := "WingmanReloaded Status"
Global WR_hStatusbar
Global PPServerStatus := True
Global Ninja := {}
Global InventoryGridX := []
Global InventoryGridY := []
Global Bases
Global GameActive
Global GamePID
Global ItemParseActive
Global ClipParseError
Global QuestItems
Global DelayAction := {}
Global ProfileMenuFlask,ProfileMenuUtility,ProfileMenuperChar
Global PoeDBAPI := ["Life Flask"
,"Mana Flask"
,"Hybrid Flask"
,"Amulet"
,"Ring"
,"Claw"
,"Dagger"
,"Wand"
,"One Hand Sword"
,"Thrusting One Hand Sword"
,"One Hand Axe"
,"One Hand Mace"
,"Bow"
,"Two Hand Sword"
,"Two Hand Axe"
,"Two Hand Mace"
,"Quiver"
,"Belt"
,"Gloves(STR)"
,"Gloves(DEX)"
,"Gloves(INT)"
,"Gloves(STR-DEX)"
,"Gloves(DEX-INT)"
,"Gloves(STR-INT)"
,"Boots(STR)"
,"Boots(DEX)"
,"Boots(INT)"
,"Boots(STR-DEX)"
,"Boots(DEX-INT)"
,"Boots(STR-INT)"
,"Body Armour(STR)"
,"Body Armour(DEX)"
,"Body Armour(INT)"
,"Body Armour(STR-DEX)"
,"Body Armour(DEX-INT)"
,"Body Armour(STR-INT)"
,"Helmet(STR)"
,"Helmet(DEX)"
,"Helmet(INT)"
,"Helmet(STR-DEX)"
,"Helmet(DEX-INT)"
,"Helmet(STR-INT)"
,"Shield(STR)"
,"Shield(DEX)"
,"Shield(INT)"
,"Shield(STR-DEX)"
,"Shield(DEX-INT)"
,"Shield(STR-INT)"
,"Sceptre"
,"Utility Flask"
,"Cobalt Jewel"
,"Viridian Jewel"
,"Crimson Jewel"
,"Murderous Eye Jewel"
,"Searching Eye Jewel"
,"Hypnotic Eye Jewel"
,"Ghastly Eye Jewel"
,"Rune Dagger"
,"Warstaff"
,"Trinket"
,"Staff"
,"Map(LOW)"
,"Map(MID)"
,"Map(TOP)"
,"HeistContract"
,"HeistBlueprint"
,"Sextant"
,"LCJ(axe and sword damage)"
,"LCJ(mace and staff damage)"
,"LCJ(dagger and claw damage)"
,"LCJ(bow damage)"
,"LCJ(wand damage)"
,"LCJ(damage with two handed melee weapons)"
,"LCJ(attack damage while dual wielding)"
,"LCJ(atack damage while holding a shield)"
,"LCJ(attack damage)"
,"LCJ(spell damage)"
,"LCJ(elemental damage)"
,"LCJ(physical damage)"
,"LCJ(fire damage)"
,"LCJ(lightning damage)"
,"LCJ(cold damage)"
,"LCJ(chaos damage)"
,"LCJ(minion damage)"
,"MCJ(fire damage over time multiplier)"
,"MCJ(chaos damage over time multiplier)"
,"MCJ(physical damage over time multiplier)"
,"MCJ(cold damage over time multiplier)"
,"MCJ(damage over time multiplier)"
,"MCJ(effect of non-damaging ailments)"
,"MCJ(legacy aura effect)"
,"MCJ(legacy curse effect)"
,"MCJ(damage while you have a herald)"
,"MCJ(minion damage while you have a herald)"
,"MCJ(warcry buff effect)"
,"MCJ(critical chance)"
,"MCJ(minion life)"
,"MCJ(area damage)"
,"MCJ(projectile damage)"
,"MCJ(trap and mine damage)"
,"MCJ(totem damage)"
,"MCJ(brand damage)"
,"MCJ(channelling skill damage)"
,"MCJ(flask duration)"
,"MCJ(life and mana recovery from flasks)"
,"SCJ(maximum life)"
,"SCJ(maximum energy shield)"
,"SCJ(maximum mana)"
,"SCJ(armour)"
,"SCJ(evasion)"
,"SCJ(chance to block)"
,"SCJ(fire resistance)"
,"SCJ(cold resistance)"
,"SCJ(lightning resistance)"
,"SCJ(chaos resistance)"
,"SCJ(chance to dodge attacks)"
,"SCJ(reservation efficiency)"
,"SCJ(curse effect)"]
Global Active_executable := "TempName"
Global selectedLeague := "Standard"
; Hybrid Mods First Line
Global HybridModsFirstLine := ["# to maximum Energy Shield"
, "# to Armour"
, "# to Evasion Rating"
, "#% increased Energy Shield"
, "#% increased Armour"
, "#% increased Evasion Rating"
, "#% increased Armour and Evasion"
, "#% increased Evasion and Energy Shield"
, "#% increased Armour and Energy Shield"
, "#% increased Armour, Evasion and Energy Shield" ]
; List available database endpoints
Global apiList := ["Currency"
, "Fragment"
, "DeliriumOrb"
, "Oil"
, "Incubator"
, "Scarab"
, "Fossil"
, "Resonator"
, "Essence"
, "DivinationCard"
, "Prophecy"
, "SkillGem"
, "BaseType"
, "HelmetEnchant"
, "UniqueMap"
, "Map"
, "UniqueJewel"
, "UniqueFlask"
, "UniqueWeapon"
, "UniqueArmour"
, "UniqueAccessory"
, "Beast"
, "Vial"]
; Create Executable group for gameHotkey, IfWinActive
Global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe", "PathOfExile_x64EGS.exe", "PathOfExileEGS.exe"]
for n, exe in POEGameArr
	GroupAdd, POEGameGroup, ahk_exe %exe%
Global GameStr := "ahk_exe PathOfExile_x64.exe"
; Global GameStr := "ahk_group POEGameGroup"
Hotkey, IfWinActive, ahk_group POEGameGroup

; Binding Objects for Spam keys
Global CtrlSpam := Func("SpamClick").Bind("On","Ctrl")
Global CtrlShiftSpam := Func("SpamClick").Bind("On",["Ctrl","Shift"])
Global ShiftSpam := Func("SpamClick").Bind("On",["Shift"])
Global CtrlSpamOff := Func("SpamClick").Bind("Off")

Global PauseTooltips:=0
Global Clip_Contents:=""
Global CheckGamestates:=False
Process, Exist
Global ScriptPID := ErrorLevel
Global MainMenuIDAutoFlask, MainMenuIDAutoQuit, MainMenuIDAutoMove, MainMenuIDAutoUtility
Global LootFilter := {}
Global BlackList
Global BlackList_Default := [[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0]]
Global StackSizes := {"Wisdom":40,"Portal":40,"Scouring":30,"Perandus":5000
	,"Alteration":20,"Transmutation":40,"Augment":30,"Chance":20
	,"Alchemy":10,"Binding":20,"Vaal":10,"Chisel":20
	,"Harbinger":20,"Horizon":20,"Chaos":10,"Engineer":20,"Regal":10
,"Simple":10,"Prime":10,"Awakened":10,"Exalted":10,"Veiled":10}
Global YesClickPortal := True
Global MainAttackPressedActive,MainAttackLastRelease,SecondaryAttackPressedActive
Global ColorPicker_Group_Color, ColorPicker_Group_Color_Hex
, ColorPicker_Red, ColorPicker_Red_Edit, ColorPicker_Red_Edit_Hex
, ColorPicker_Green , ColorPicker_Green_Edit, ColorPicker_Green_Edit_Hex
, ColorPicker_Blue , ColorPicker_Blue_Edit, ColorPicker_Blue_Edit_Hex
Global FillMetamorph := {}
Global HeistGear := ["Torn Cloak","Tattered Cloak","Hooded Cloak","Whisper-woven Cloak"
,"Silver Brooch","Golden Brooch","Enamel Brooch","Foliate Brooch"
,"Simple Lockpick","Standard Lockpick","Fine Lockpick","Master Lockpick"
,"Leather Bracers","Studded Bracers","Runed Bracers","Steel Bracers"
,"Crude Sensing Charm","Fine Sensing Charm","Polished Sensing Charm","Thaumaturgical Sensing Charm"
,"Voltaxic Flashpowder","Trarthan Flashpowder","Azurite Flashpowder"
,"Crude Ward","Lustrous Ward","Shining Ward","Thaumaturgical Ward"
,"Essential Keyring","Versatile Keyring","Skeleton Keyring","Grandmaster Keyring"
,"Eelskin Sole","Foxhide Sole","Winged Sole","Silkweave Sole"
,"Basic Disguise Kit","Theatre Disguise Kit","Espionage Disguise Kit","Regicide Disguise Kit"
,"Steel Drill","Flanged Drill"
,"Sulphur Blowtorch","Thaumetic Blowtorch"
,"Rough Sharpening Stone","Standard Sharpening Stone","Fine Sharpening Stone","Obsidian Sharpening Stone"
,"Flanged Arrowhead","Fragmenting Arrowhead","Hollowpoint Arrowhead","Precise Arrowhead"
,"Focal Stone","Conduit Line","Aggregator Charm","Burst Band"]

Global HeistLootLarge := ["Essence Burner","Ancient Seal","Blood of Innocence","Dekhara's Resolve","Orbala's Fifth Adventure","Staff of the first Sin Eater","Sword of the Inverse Relic"]

; Tooltip Texts
ft_ToolTip_Text_Part1=
(LTrim
	UpdateOnCharBtn = Calibrate the OnChar Color`rThis color determines if you are on a character`rSample located on the figurine next to the health globe
	UpdateOnChatBtn = Calibrate the OnChat Color`rThis color determines if the chat panel is open`rSample located on the very left edge of the screen
	UpdateOnDivBtn = Calibrate the OnDiv Color`rThis color determines if the Trade Divination panel is open`rSample located at the top of the Trade panel
	UpdateOnDelveChartBtn = Calibrate the OnDelveChart Color`rThis color determines if the Delve Chart panel is open`rSample located at the left of the Delve Chart panel
	UpdateOnMetamorphBtn = Calibrate the OnMetamorph Color`rThis color determines if the Metamorph panel is open`rSample located at the i Button of the Metamorph panel
	UpdateOnLockerBtn = Calibrate the OnLocker Color`rThis color determines if the Heist Locker panel is open`rSample located in the bottom right of the Heist Locker panel
	UdateEmptyInvSlotColorBtn = Calibrate the Empty Inventory Color`rThis color determines the Empy Inventory slots`rSample located at the bottom left of each cell
	UpdateOnInventoryBtn = Calibrate the OnInventory Color`rThis color determines if the Inventory panel is open`rSample is located at the top of the Inventory panel
	UpdateOnStashBtn = Calibrate the OnStash/OnLeft Colors`rThese colors determine if the Stash/Left panel is open`rSample is located at the top of the Stash panel
	UpdateOnVendorBtn = Calibrate the OnVendor Color`rThis color determines if the Vendor Sell panel is open`r Sample is located at the top of the Sell panel
	UpdateOnMenuBtn = Calibrate the OnMenu Color`rThis color determines if Atlas or Skills menus are open`rSample located at the top of the fullscreen Menu panel
	UpdateDetonateBtn = Calibrate the Detonate Mines Color`rThis color determines if the detonate mine button is visible`rWill determine if you are in mines and change sample location`rLocated above mana flask on the right
	StartCalibrationWizardBtn = Use the Wizard to grab multiple samples at once`rThis will prompt you with instructions for each step
	YesOHB = Pauses the script when it cannot find the Overhead Health Bar
	ShowOnStart = Enable this to have the GUI show on start`rThe script can run without saving each launch`rAs long as nothing changed since last color sample
	AutoUpdateOff = Enable this to not check for new updates when launching the script
	ResolutionScale = Adjust the resolution the script scales its values from`rStandard is 16:9`rClassic is 4:3 aka 12:9`rCinematic is 21:9`rCinematic(43:18) is 43:18`rUltraWide is 32:9`rWXGA(16:10) is 16:10 aka 8:5
	Latency = Use this to multiply the sleep timers by this value`rOnly use in situations where you have extreme lag
	ClickLatency = Use this to modify delay to click actions`rAdd this many multiples of 15ms to each delay
	ClipLatency = Use this to modify delay to Item clip`rAdd this many multiples of 15ms to each delay
	GrabCurrencyX = Select the X location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
	GrabCurrencyY = Select the Y location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
	EnableRestock = Enable this to restock any inventory slots assigned a currency type
	YesEnableAutomation = Enable Automation Routines
	FirstAutomationSetting = Start Automation selected option
	YesEnableNextAutomation = Enable next automation after the first selected
	YesEnableAutoSellConfirmation = Enable Automation Routine to Accept Vendor Sell Button!! Be Careful!!
	YesEnableAutoSellConfirmationSafe = Enable Automation Routine to Accept Vendor Sell Button only when:`r The vendor is empty`r The only items are Chromatic or Jeweller`r During the chaos Recipe
	DebugMessages = Enable this to show debug tooltips`rAlso shows additional options for location and logic readout
	YesTimeMS = Enable to show a tooltip when game logic is running
	YesLocation = Enable to show tooltips with current location information`rWhen checked this will also log zone change information
	hotkeyOptions = Set your hotkey to open the options GUI
	hotkeyAutoFlask = Set your hotkey to turn on and off Auto-Flask
	hotkeyAutoQuit = Set your hotkey to turn on and off Auto-Quit
	hotkeyAutoMove = Set your hotkey to Turn on and off Auto-Move
	hotkeyAutoUtility = Set your hotkey to Turn on and off Auto-Utility
	hotkeyTriggerMovement = Set the key to trigger Movement or Smoke-Dash (cast on detonate)
	hotkeyLogout = Set your hotkey to Log out of the game
	hotkeyGetMouseCoords = Set your hotkey to grab mouse coordinates`rIf debug is enabled this function becomes the debug tool`rUse this to get gamestates or pixel grid info
	hotkeyQuickPortal = Set your hotkey to use a portal scroll from inventory
	hotkeyGemSwap = Set your hotkey to swap gems between the two locations set above`rEnable Weapon swap if your gem is on alternate weapon set
	hotkeyStartCraft = Set your hotkey to use Crafting Settings functions, as Map Crafting
	hotkeyCraftBasic = Set your hotkey to use Basic Crafting pop-up, these can be configured in the Crafting Settings.
	hotkeyCtrlClicker = Bind a key to use for fast Ctrl Clicks on your cursor.
	hotkeyCtrlShiftClicker = Bind a key to use for fast Ctrl + Shift Clicks on your cursor.
	hotkeyShiftClicker = Bind a key to use for fast Shift Clicks on your cursor.
	hotkeyGrabCurrency = Set your hotkey to quick open your inventory and get a currency from a seleted position and put on your mouse pointer`rUse this feature to quickly change white strongbox
	hotkeyPopFlasks = Set your hotkey to Pop all flasks`rEnable the option to respect cooldowns on the right
	hotkeyItemSort = Set your hotkey to Sort through inventory`rPerforms several functions:`rIdentifies Items`rVendors Items`rSend Items to Stash`rTrade Divination cards
	hotkeyItemInfo = Set your hotkey to display information about an item`rWill graph price info if there is any match
	hotkeyChaosRecipe = Set your hotkey to scan the dump tab for chaos recipe`rRequires POESESSID to function`rWill use automation to search for stash and vendor`rAdjust your strings if it cannot find them
	hotkeyCloseAllUI = Put your ingame assigned hotkey to Close All User Interface here
	hotkeyInventory = Put your ingame assigned hotkey to open inventory panel here
	hotkeyWeaponSwapKey = Put your ingame assigned hotkey to Weapon Swap here
	hotkeyLootScan = Put your ingame assigned hotkey for Item Pickup Key here
	LootVacuum = Enable the Loot Vacuum function`rUses the hotkey assigned to Item Pickup
	LootVacuumTapZ = When pressing the loot key, it will tap z two times to refresh the location of loot on the floor.
	LootVacuumTapZEnd = This will make the loot resort when releasing the key.
	LootVacuumTapZSec = How many seconds should elapse between resorting loot.
	LootVacuumSettings = Assign your own loot colors and adjust the AreaScale and delay`rAlso contains options for openable containers
	PopFlaskRespectCD = Enable this option to limit flasks on CD when Popping all Flasks`rThis will always fire any extra keys that are present in the bindings`rThis over-rides the option below
	LaunchHelp = Opens the AutoHotkey List of Keys
	YesIdentify = This option is for the Identify logic`rEnable to Identify items when the inventory panel is open
	YesStash = This option is for the Stash logic`rEnable to stash items to assigned tabs when the stash panel is open
	YesVendor = This option is for the Vendor logic`rEnable to sell items to vendors when the sell panel is open
	YesDiv = This option is for the Divination Trade logic`rEnable to sell stacks of divination cards at the trade panel
	YesMapUnid = This option is for the Identify logic`rEnable to avoid identifying maps
	YesInfluencedUnid = This option is for the Identify logic`rEnable to avoid identifying influenced rares
	YesCLFIgnoreImplicit = This option disable implicits being merged with Pseudos.`rEx: This will ignore implicits in base like two-stone boots (elemental resists)`ror two-stone rings (elemental resists) or wand (spell damage)
	YesSortFirst = This option is for the Stash logic`rEnable to send items to stash after all have been scanned
	YesSkipMaps = Select the inventory column which you will begin skipping rolled maps`rDisable by setting to 0
	YesSkipMaps_Prep = Skip items such as sacrifice fragments and scarabs inside the map prep zone
	YesSkipMaps_eval = Choose either Greater than or Less than the selected column`rYou can start skipping maps store on the right or left from the inventory column selected
	YesSkipMaps_normal = Skip normal quality maps within the column range
	YesSkipMaps_magic = Skip magic quality maps within the column range
	YesSkipMaps_rare = Skip rare quality maps within the column range
	YesSkipMaps_unique = Skip unique quality maps within the column range
	YesSkipMaps_tier = Skip maps at or above this Map Tier
	UpdateDatabaseInterval = How many days between database updates?
	selectedLeague = Which league are you playing on?
	UpdateLeaguesBtn = Use this button when there is a new league
	LVdelay = Change the time between each click command in ms`rThis is in case low delay causes disconnect`rIn those cases, use 45ms or more
	RestockCustomY = Y cord positions for custom slot restocking
	RestockCustomX = X cord positions for custom slot restocking
	RestockCustomTab = Stash tab number for custom slot restocking

)

ft_ToolTip_Text_Part2=
(LTrim
	ChaosRecipeEnableFunction = Enable/Disable the Chaos Recipe logic which includes all of its settings
	ChaosRecipeMaxHoldingID = Determine how many sets of identified Chaos Recipe to stash
	ChaosRecipeMaxHoldingUNID = Determine how many sets of unidentified Chaos Recipe to stash
	ChaosRecipeTypePure = Recipe will affect items which are between 60-74 which have not met other stash/CLF filters`ronly draw items within that range from stash for chaos recipe.
	ChaosRecipeTypeHybrid = Recipe will affect all rares 60+ which have not met other stash/CLF filters`rRequires at least one lvl 60-74 item to make a recipe set`rPriority is given to regal items.
	ChaosRecipeTypeRegal = Recipe will affect items which are 75+ which have not met other stash/CLF filters`ronly draw items for regal recipe from stash.
	ChaosRecipeAllowDoubleJewellery = Amulets and Rings will be given double allowance of Parts limit
	ChaosRecipeAllowDoubleBelt = Belts will be given double allowance of Parts limit
	ChaosRecipeEnableUnId = Keep items which are within the limits of the recipe settings from being identified.
	ChaosRecipeSmallWeapons = Stash 1x3 or 2x2 Weapons and Shields only, filtering bulky items from wasting space.`rWill also stash 2x3 two handers.
	ChaosRecipeStashTabWeapon = Assign the Stash Tab that Weapons will be sorted into.
	ChaosRecipeStashTabHelmet = Assign the Stash Tab that Helmets will be sorted into.
	ChaosRecipeStashTabArmour = Assign the Stash Tab that Armours will be sorted into.
	ChaosRecipeStashTabGloves = Assign the Stash Tab that Gloves will be sorted into.
	ChaosRecipeStashTabBoots = Assign the Stash Tab that Boots will be sorted into.
	ChaosRecipeStashTabBelt = Assign the Stash Tab that Belts will be sorted into.
	ChaosRecipeStashTabAmulet = Assign the Stash Tab that Amulets will be sorted into.
	ChaosRecipeStashTabRing = Assign the Stash Tab that Rings will be sorted into.
	ChaosRecipeStashMethodDump = Use the dump tab assigned in stash tab management
	ChaosRecipeStashMethodTab = Use the tab set below to seperate chaos recipe items
	ChaosRecipeStashMethodSort = Use seperate tabs for each part of the recipe list
	ChaosRecipeStashTab = Assign the Stash Tab that All Parts will be sorted into.
	ChaosRecipeLimitUnId = Items will remain unidentified until this Item Level
	AreaScale = Increases the Pixel box around the Mouse`rA setting of 0 will search under cursor`rCan behave strangely at very high range
	StashTabCurrency = Assign the Stash tab for Currency items
	StashTabYesCurrency = Enable to send Currency items to the assigned tab on the left
	StashTabMap = Assign the Stash tab for Map items
	StashTabYesMap = Enable to send Map items to the assigned tab on the left
	StashTabFragment = Assign the Stash tab for Fragment items
	StashTabYesFragment = Enable to send Fragment items to the assigned tab on the left
	StashTabDivination = Assign the Stash tab for Divination items
	StashTabYesDivination = Enable to send Divination items to the assigned tab on the left
	StashTabUnique = Assign the Stash tab for Collection items`rThis is where Uniques will first be attempted to stash
	StashTabYesUnique = Enable to send Collection items to the assigned tab on the left`rThis is where Uniques will first be attempted to stash
	StashTabEssence = Assign the Stash tab for Essence items
	StashTabYesEssence = Enable to send Essence items to the assigned tab on the left
	StashTabProphecy = Assign the Stash tab for Prophecy items
	StashTabYesProphecy = Enable to send Prophecy items to the assigned tab on the left
	StashTabVeiled = Assign the Stash tab for Veiled items
	StashTabYesVeiled = Enable to send Veiled items to the assigned tab on the left
	StashTabNinjaPrice = Assign the Stash tab for Ninja Priced items
	StashTabYesNinjaPrice = Enable to send Ninja Priced items to the assigned tab on the left`rChaos Value must be at or above threshold 
	StashTabYesNinjaPrice_Price = Assign the minimum value in chaos to send to Ninja Priced Tab
	StashTabPredictive = Assign the Stash tab for Rare items priced with Machine Learning
	StashTabYesPredictive = Enable to send Priced Rare items to the assigned tab on the left`rPredicted price value must be at or above threshold
	StashTabYesPredictive_Price = Set the minimum value to consider worth stashing
	StashTabClusterJewel = Assign the Stash tab for cluster jewels
	StashTabYesClusterJewel = Enable to send Cluster Jewels to the assigned tab on the left
	StashTabDump = Assign the Stash tab for Unsorted items left over during Stash routine
	StashTabYesDump = Enable to send Unsorted items to the assigned Dump tab on the left
	StashDumpInTrial = Enables dump tab for all unsorted items when in Aspirant's Trial
	StashDumpSkipJC = Do not stash Jewler or Chromatic items when dumping
	StashTabGemSupport = Assign the Stash tab for Support Gem items
	StashTabYesGemSupport = Enable to send Support Gem items to the assigned tab on the left 
	StashTabMetamorph = Assign the Stash tab for Metamorph items
	StashTabYesMetamorph = Enable to send Metamorph items to the assigned tab on the left
	StashTabGem = Assign the Stash tab for Normal Gem items
	StashTabYesGem = Enable to send Normal Gem items to the assigned tab on the left
	StashTabGemVaal = Assign the Stash tab for Vaal Gem items
	StashTabYesGemVaal = Enable to send Vaal Gem items to the assigned tab on the left`rIf Quality Gems are enabled, that will take priority
	StashTabGemQuality = Assign the Stash tab for Quality Gem items
	StashTabYesGemQuality = Enable to send Quality Gem items to the assigned tab on the left
	StashTabFlaskQuality = Assign the Stash tab for Quality Flask items
	StashTabYesFlaskQuality = Enable to send Quality Flask items to the assigned tab on the left
	StashTabFlaskAll = Assign the Stash tab for Quality Flask items
	StashTabYesFlaskAll = Enable to send unquality flasks to the assigned tab on the left
	StashTabLinked = Assign the Stash tab for 6 or 5 Linked items
	StashTabYesLinked = Enable to send 6 or 5 Linked items to the assigned tab on the left
	StashTabBrickedMaps = Assign the Stash tab for maps that have unwanted mods on them
	StashTabYesBrickedMaps = Enable to send maps that have unwanted mods on them to the assigned tab on the left
	StashTabUniqueDump = Assign the Stash tab for Unique items`rIf Collection is enabled, this will be where overflow goes
	StashTabYesUniqueDump = Enable to send Unique items to the assigned tab on the left`rIf Collection is enabled, this will be where overflow goes
	StashTabUniqueRing = Assign the Stash tab for Unique Ring items`rIf Collection is enabled, this will be where overflow rings go
	StashTabYesUniqueRing = Enable to send Unique Ring items to the assigned tab on the left`rIf Collection is enabled, this will be where overflow rings go
	StashTabYesInfluencedItem = Enable to send Influenced items to the assigned tab on the left
	StashTabInfluencedItem = Assign the Stash tab for Influenced items
	StashTabDelve = Assign the Stash tab for Delve items
	StashTabYesDelve = Enable to send Delve items to the assigned tab on the left
	StashTabCrafting = Assign the Stash tab for Crafting items
	StashTabYesCrafting = Enable to send Crafting items to the assigned tab on the left
	MMQorWeight = Keep maps which reach Minimum Map Qualities OR Minimum Weight

)

ft_ToolTip_Text_Part3=
(LTrim
	StartMapTier1 = Select Initial Map Tier Range 1
	StartMapTier2 = Select Initial Map Tier Range 2
	StartMapTier3 = Select Initial Map Tier Range 3
	EndMapTier1 = Select Ending Map Tier Range 1
	EndMapTier2 = Select Ending Map Tier Range 2
	EndMapTier3 = Select Ending Map Tier Range 3
	CraftingMapMethod1 = Select Crafting/ReCrafting Method for Range 1
	CraftingMapMethod2 = Select Crafting/ReCrafting Method for Range 2
	CraftingMapMethod3 = Select Crafting/ReCrafting Method for Range 3
	MoveMapsToArea = When finished map crafting, move all crafted maps to the map area`rThis will include MapPrep Items that were not in map area
	YesIncludeFandSItem = Fracture and Synthesised itens will be considered as influenced items
	ElementalReflect = Select this if your build can't run maps with this mod
	PhysicalReflect = Select this if your build can't run maps with this mod
	NoLeech = Select this if your build can't run maps with this mod
	NoRegen = Select this if your build can't run maps with this mod
	AvoidAilments = Select this if your build can't run maps with this mod
	AvoidPBB = Select this if your build can't run maps with this mod
	MinusMPR = Select this if your build can't run maps with this mod
	YesNinjaDatabase = Enable to Update Ninja Database and load at start
	WR_Btn_Inventory = Open the settings related to the inventory
	WR_Btn_Strings = Open the settings related to the FindText Strings
	WR_Btn_Chat = Open the settings related to the Chat Hotkeys
	WR_Btn_Controller = Bind actions to joystick input
	WR_Btn_CLF = Configure the Custom Loot Filter`rUse this to filter items by properties, affixes, or stats
	WR_Btn_IgnoreSlot = Assign the ignored slots in your inventory`rThe script will not touch items in these locations
	WR_Reset_Globe = Loads unmodified default values and reloads UI
	WR_Save_JSON_Globe = Save changes to disk`rThese changes will load on script launch
	stashPrefix1 = Assign one or more modifier key`rWhen all assigned keys are pressed, Stash Hotkeys become active`rLeave Blank to disable
	stashPrefix2 = Assign one or more modifier key`rWhen all assigned keys are pressed, Stash Hotkeys become active`rLeave Blank to disable
	stashSuffix1 = Hotkey for the 1st Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix2 = Hotkey for the 2nd Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix3 = Hotkey for the 3rd Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix4 = Hotkey for the 4th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix5 = Hotkey for the 5th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix6 = Hotkey for the 6th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix7 = Hotkey for the 7th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix8 = Hotkey for the 8th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffix9 = Hotkey for the 9th Stash Hotkey slot`rThis hotkey will only activate while the Modifier(s) are pressed`rLeave Blank to disable
	stashSuffixTab1 = Assign the Stash Tab for the 1st Stash Hotkey slot
	stashSuffixTab2 = Assign the Stash Tab for the 2nd Stash Hotkey slot
	stashSuffixTab3 = Assign the Stash Tab for the 3rd Stash Hotkey slot
	stashSuffixTab4 = Assign the Stash Tab for the 4th Stash Hotkey slot
	stashSuffixTab5 = Assign the Stash Tab for the 5th Stash Hotkey slot
	stashSuffixTab6 = Assign the Stash Tab for the 6th Stash Hotkey slot
	stashSuffixTab7 = Assign the Stash Tab for the 7th Stash Hotkey slot
	stashSuffixTab8 = Assign the Stash Tab for the 8th Stash Hotkey slot
	stashSuffixTab9 = Assign the Stash Tab for the 9th Stash Hotkey slot
	hotkeyMainAttack = Bind the Main Attack for this Character
	hotkeySecondaryAttack = Bind the Secondary Attack for this Character
	YesOpenStackedDeck = Open Stacked Decks while at the stash`rMoves to inventory respecting ignore slots
	YesSpecial5Link = Giving 5 links a special type will prevent them from being vendored, expecially relevant for Jeweller's recipe items with 5 links.

)

; Tooltips for the utility and flask menus
ft_ToolTip_Text_Part4=
(LTrim
	MainAttackOnly = Only trigger other settings when the main attack is being held
	MainAttack = Trigger this when the Main attack button is pressed
	MainAttackRelease = Trigger this when the Main attack button is released
	SecondaryAttack = Trigger this when the Secondary attack button is pressed
	SecondaryAttackRelease = Trigger this when the Secondary attack button is released
	Enable = Enable this to trigger
	OnCD = Fire this every time it comes off cooldown
	CD = Set the time between firing
	Key = Set the key to press`rThis can include multiple keys seperated with a space`rIt can also include a delay like so [100](k)
	Group = Which cooldown group will this belong to
	GroupCD = How long will the group remain on cooldown when this fires
	Curse = Trigger when a Curse is found`rRequires the strings configured in string settings to work
	Shock = Trigger when a Shock is found`rRequires the strings configured in string settings to work
	Bleed = Trigger when a Bleed is found`rRequires the strings configured in string settings to work
	Freeze = Trigger when a Freeze is found`rRequires the strings configured in string settings to work
	Ignite = Trigger when a Ignite is found`rRequires the strings configured in string settings to work
	Poison = Trigger when a Poison is found`rRequires the strings configured in string settings to work
	Icon = Trigger this when the sample cannot be found
	IconShown = Inverts the logic to trigger when the sample is found
	IconSearch = Which type of search area do you want configured
	IconArea_Show = Show the area which is configured for custom
	IconArea_Set = Set the custom area for searching for an icon
	IconVar1 = Change the allowed error value for 1's in the sample
	IconVar0 = Change the allowed error value for 0's in the sample
	PopAll = Include this in the Pop All hotkey
	Move = Trigger this when the Movement key is pressed
	Condition = Make the resource triggers fire when any are true, or when all are true

)

ft_ToolTip_Text := ft_ToolTip_Text_Part1 . ft_ToolTip_Text_Part2 . ft_ToolTip_Text_Part3 . ft_ToolTip_Text_Part4
; Current log file
Global logFile := A_Now

; Login POESESSID
Global PoECookie := ""
Global AccountNameSTR := ""
; Globals For client.txt file
Global ClientLog := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"
Global CurrentLocation := ""
Global CLogFO
; ASCII converted strings of images
Global 1080_HealthBarStr := "|<1080 Overhead Health Bar>0x201614@0.99$106.Tzzzzzzzzzzzzzzzzu"
, 1440_HealthBarStr := "|<1440 Overhead Health Bar>0x190D11@0.98$138.TzzzzzzzzzzzzzzzzzzzzzyU"
, 1440_HealthBarStr_Alt := "|<1440 OHB alt>*58$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
, 1050_HealthBarStr := "|<1050 Overhead Health Bar>0x221415@0.98$104.Tzzzzzzzzzzzzzzzzc"
, OHBStrW := StrSplit(StrSplit(1080_HealthBarStr, "$")[2], ".")[1]

, 2160_SellItemsStr := "|<2160 Sell Items>0xE3D7A6@1.00$71.00000001k3U000000003U70003y000070C000AD0000C0Q000U60000Q0s003040000s1k006000001k3U00A000003U7000M000w070C000s007S0C0Q001s00MC0Q0s001s01UA0s1k001w020Q1k3U001w0A0M3U70001y0M0k70C0000y1rzUC0Q0000y3U00Q0s0000w7000s1k0000wC001k3U0000sQ003U700001ks0070C00003Uk00C0Q000071k00Q0s0000A3k20s1k0040k3k81k3U007z03zU3U70007s01y070C0000000000000000000000000000000000000000000000000000000000000000000000004"
, 1440_SellItemsStr := "|<1440 Sell Items>*106$71.zzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy73zzzzzzzzzwC7zzzzzzzzzwSDzkzzzzzzzswTzVzzzzzzzlszz3tzzzzzzXlzy7nzzzzkT7XzwC0T1wM0SD7zsQ0w1kUMQSDzkw7lVk1sswTzVszbXVvllszz3lyD77k3Xlzy7Xw0CDU77XzwD7s0QTTyD7zsSDlzsyzwSDzkwTXzlxyswTzVsz7vXttlszz3lq7b7k3Xlzy7UC0CDUD7XzwDUS0wTlzzzzzzXz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
, 1080_SellItemsStr := "|<1080 Sell Items>*100$80.zzzjTzzzzzzzzzzzlXzzzzzzzzy3zwMzlzzzzzzz0TzbDyTzzzzzznbztnzbbzzzzzwzsSQztkC74AT37w3bDyQ30k03UESQtnzbbbAAANa3b6Qztttlb76TsM1bDySS0NllVz6Ttnzb7byQQQ7sbyQztltzb77lyMxbDyQSDFlly360NnzbUU4QQPY3kCQztsA37761nzDzzzzDnzzzts"
, 1050_SellItemsStr := "|<1050 Sell Items>*93$71.zzzzzzzzzzzzzzz6DzzzzzzzzzyATzzzzzzy3zwMzlzzzzztXzslznzzzzznjzlXzbbzzzzby3X7zC3Us133sX6DyQC8k033naATwswtXb73UAMztls37CD28slznXWCCQTaTlXzb7bwQszAxX7zCDDMtlAM36DyQ20lnW1sCATwwC3Xb7DxzzzzwzTzzzzzzzzzzzzzzzzzzzzzzzzzzU"
, 768_SellItemsStr := "|<768 Sell Items>0xE0E0DB@0.52$56.00NU000007U6M600001A1a1a0000kCNUPtnvXr7qM6QyzxhvBa1aNgnQ7zNUNbvAnUw6M6NUnASDZa1aQgn3STNUNvvArn1000A800G"

, 1080_HeistLockerStr := "|<1080 Locker>*90$59.7zzzzzzzzzDzzzzzzzzyTyTyTDTzzwzkDk4QE60tz6D6AlnANnwSASt7bslbtwNzkTDlXDnsnzVy3XCTblbz1w70QzDX7yFty1tyDCDwXnwFnaASCNXbslUA1y1nX0llzyTzDzzzzy"
, 1440_HeistLockerStr := "|<1440 Locker>**50$64.00000000000000000z0000000003A0000000008k001wDzzw0n03w7lzzzs3A0zwFA301UAk70tYrZty0n0llqGTzbs3A3DXN8z6M0AkNX5YlkNU0n1aAKH3la03A4EFN636M0AkF1ZYC6N00n166KEQNY03A6MFNCNaE0AnsnBYzaNU0nzXsqGQNa037D7aNA36M0A0y1lwzsTU0zzDy00y000000TU00000000002"

, 2160_StashStr := "|<2160 Stash>116$64.w0zzzzzzzzz00zzzzzzzzsS3zzzzzzzzXyDzzzzzzzwDszzzzzzzzlzrU00zsTzU3zw003z1zs0DzksADw7zXkTzDVyzUDwTUTzy7zyEzly0TzsTzl3z7w0zzVzz47wDs1zy7zssTkTk1zsTzXUzUTk3zVzyT3y0zUDy7zlwDw3zUTsTz7kTwDz1zVzs01zszy7y7zU07zvzsTsTyDsDzzzVzVzlzkzzzy7y7z7z3zwzkzsTszw7Tk03zVzXzsQTU0Ty7yDzUk307zsTlzz3UDVzzzzzzzzVU"
, 1440_StashStr := "|<1440 Stash>**50$62.U000000000800zk00000200QC000000U060U00000803DDzw7UTW00qPzzXgDyU0Ark0NX61c03C5tyMFj+00ktyTY6HSU0C71a3NYTc01kMNUq9XW00C36MNnMSU01sla6wn1c0074N104QC000l6EmFXXU0D6FYByTAs03zANaEXzC00n36NgAnXU0C1VaH361c01zkTbUTzm007k00007kU0000000008"
, 1080_StashStr := "|<1080 Stash>0xC8C8DC@0.78$57.00Q000000006s00000001V00000000A3zVUT6301k3UC48kM070A2kk6300S1UK70kM01sA4MQ7z0031UX1skM00MADs3630031V1UMkM08MA8AX6300y1X0rkkQ"
, 1050_StashStr := "|<1050 Stash>*102$56.zzzzzzzzzzzUzzzzzzzzn7zzzzzzzwv0DbsQwTzDk1lw3D7zkzXwDBnlzy7syHnwwTzkyDYwD07zz7bv7Vk1zzttw1yAwTzySTCDnD7zn7bbnQnlzw3stwkQwTznzzzzTzzzzzzzzzzzU"
, 768_StashStr := "|<768 Stash>#208@0.49$32.T00007k00033wsxXwACNMrX7b6AQlgxz3AT7MsnAsqBsn7xXU"

, 1440_SkillUpStr := "|<1440 Skill Up>0xF6CB08@0.48$11.wTsw0000000wTsy"
, 1080_SkillUpStr := "|<1080 Skill Up>0xAA6204@0.66$9.sz7ss0000sz7sw"
, 1050_SkillUpStr := "|<1050 Skill Up>**50$12.HoOkGY2VyzU1yzmX2VGU6U7kU"
, 768_SkillUpStr := "|<768 Skill Up>#52@0.77$15.3U0W0CQ1nEU340MiO3nUAM0z07s3zkDl4"

, 1440_XButtonStr := "|<1440 x button>*54$14.01y0zkTyDzrtzwDy1z0TkDy7znxyyDz3zWTk3s"
, 1080_XButtonStr := "|<1080 X Button>*43$12.0307sDwSDwDs7k7sDwSSwTsDk7U"
, 1050_XButtonStr := "|<1050 X Button>*56$30.Tzz7zzw0lzzky4zz3znTyDzsDwE7S7sU7r7tU3D/nU0zXn3VzprXlvlbXznnbUzbvbwz7vbwz7vbtzXvrvvvnrrVtlnzVsnvq+MXtuTX/wzzzLyTzwTzDztzzXzXzzs8Dzzz1zzzzzzzU"
, 768_XButtonStr := "|<768 X Button>#197@0.82$19.0zU1kQ1zb1twlcTgoDKmjBtXCzsCCS7773nb0tn6BdbbaTzlDzksxsCHs1zs0Dk8"

, 1080_MasterStr := "|<1080 Master>*100$46.wy1043UDVtZXNiAy7byDbslmCDsyTX78wDXsCAw3sSDVs7U7lsyTUSSTXXty8ntiSDbslDW3sy1XW"
, 1050_MasterStr := "|<1050 Master>*91$45.zzzzzzzznw81UMDwT00430TVtj7XsntDDswT6T9sT7UMnv7Vsw30S0z7DXs7nXwtwT4QyPbDXsnbn1sw37Dzyzzzzzzzzzzzzw"

, 2160_NavaliStr := "|<2160 Navali>121$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzwDzy7zzzzzzzwDzwDzzzzzzzsDzsTzzzzzzzkTzkzzzzzzzzUTzlzzzzzzzz0TzXzwDsDzky0Tz7zkTsDzVw0TyDzUzkTz3sUTwzy0zkzyDlUTtzwVzUzwTX0Tnzl3zVzkz70zbzW3z3zXyD0zDyC7y3z7wT0yTwQ7y7wTsz0wztwDw7szlz0tzXsTwDXzXz0nz7kTsT7z7z07w00zkQTyDy0Ds01zkszwTy0Tlz1zVnzszy0z7z3zV7ylzy1yDy7z2DxXzy3szw7y0zn7zy7lzwDy1zaDzyDXzsDw7zATzyCDzsTwDwTzzzzzzzzwzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
, 1440_NavaliStr := "|<1440 Navali>**50$59.0000000000000000000000000000000000000000D7ljVsDUT0vDlz7MT0y36NVaMkW1464lXAkVY388An6F1X86EqNW9an6EAVgF6nBWAUN6QnBgnaN0mBtaCNjAm1YE1aRW0BY39YXAnAYP86HTa8gPwqHggl6MNa8wztP3AkXMNtvma68n4klk7Zs7lyD0zzvs001s0000000000000008"
, 1080_NavaliStr := "|<1080 Navali>*100$56.TtzzzzzzznyTzzzzzzwTbxxzTjrx3tyCDXnsy0ST3ntsTDk3bkwSS7nw8Nt77D8wz36SNtnmDDks7USBw3nwD1k3mS0Qz3sQwwDbbDkz6TD3ntngDtblswyA38"
, 1050_NavaliStr := "|<1050 Navali>*102$57.zzzzzzzzzwTbzzzzzzznwzzzzzzzyDbtsySTblkwyD7nXwzC3bkwywDbtmAwbXb9wzCMbYyRtDbtnUxXnDMwzCQ70S9k7btnktlsSQQzCT6TD3bnbtnwntwwyQ7DzzzzzzzzzU"
, 768_NavaliStr := "|<768 Navali>#254@0.73$39.kk00007600000sln6QMTaC8nX3yllYQMSyPAan3nnswyMSCn7An3koAt3TQ"

, 1080_HelenaStr := "|<1080 Helena>*100$62.DlzzzzzzzznwTzzzzzzzwz7zxzzvyzjDlkCDUQT7nnwSPnwrXnsQz7bwzDsQy701tzDny3D8k0S3nw7YHnAz7Vwz3tYw3DltzDnyMC0HwSTnwzb3bYz7bwvDtsntDls70kCTAy8"
, 1050_HelenaStr := "|<1050 Helena>*95$61.zzzzzzzzzzlwTzzzzzzzwyDzzzzzzzyT70lw3DnwzDXUQy1ntwTbllyT7swy7k0szDXwCSHs0Q3bkCXD9wyC1ns7MbgST77twTi3UDDXXwyDrVnXbllyN7vsntnss70URyNwzzzzzzzzzzs"

, 1440_ZanaStr := "|<1440 zana>*101$62.k07zzzzzzzw03zzzzzzzzDkzzzzzzzzzwTtzDyTtzzyDwTlz7wTzz3z3wDtz3zzlzUz1yTUzzsTs7kDbs7zwDwlwVtwlzz7zAT4CTATzVzXXlVbXXzkzs0wQNs0zwTy0D7WS0Dy7zDllw7DlzXyHwQTVnwRk00z77sMz6800Tslz6TsXzzzzzzzzzszzzzzzzzzyTzzzzzzzzzDzzzzzzzzzrzzzzzzzzzzs"
, 1080_ZanaStr := "|<1080 Zana>*100$44.U3zzzzzs0zzzzzyyTrvyzjz7twT7nzXwDXnsTsz3sQy7wTYS3D8yDtbYHnDXy1tYw3lz0CMC0Mznnb3ba01wtsnt02T6TAy8"
, 1050_ZanaStr := "|<1050 Zana>*106$44.zzzzzzzw0Tzzzzy0DzzzzzzXtyzDnzlwTbnszwz3swy7yDYy7D9z7tDcnmTnylv4xXsz0SsC0wTnXj3b701wvsntU0TCzAyTzzzzzzy"

, 1080_BestelStr := "|<1080 Bestel>*100$54.zzzzzzzzzUzzzzzzzzUTzzzzzzzbDzwzzzyzbC1s80UQTbDBn/6nSTUTDnz7nyTUDDlz7nyTb71sT7kSTb73wD7kyTbbDyD7nyTbbDz77nyTbDDrD7nyRUT0kT7kC1zzzxzzzzzzzzzzzzzzU"
, 1050_BestelStr := "|<1050 Bestel>*94$51.zzzzzzzzw1zzzzzzzmDzzzzzzyMkC40kATnC1U021nyNlwrXlyTkCDbwSDnyMkADXkCTna1kwS1nyQlzXblyTnaDyQyDnyMlxnblyNkC1UwS1kDzzzTzzzzzzzzzzzzw"

, 1080_GreustStr := "|<1080 Greust>*100$61.zzzzzzzzzzz3zzzzzzzzy0TzzzzzzzyDDzzzTjbzyDi0s77XUU37z6SPXtaKBbzX7Dlwnz7nzlXbsyMzXsyMnkSTC7lwSA3sTDbVsyDa1wzbnswT3n4STnvyCDktX7DstrD7w0llUS1sDXznzzzznzTzzzzzzzzzzzy"
, 1050_GreustStr := "|<1050 Greust>*88$58.zzzzzzzzzzkDzzzzzzzwMzzzzzzzzXnUy1XnV0CDy0s6DA00NzsnXswnSDbzXCDXnDsyTyAs6DADXswM3UMwsSDXlUSDXnstyD68szDDnbwAMnXwsrCTs1Xa1k71sztzzzzlzTzzzzzzzzzzzU"

, 1080_ClarissaStr := "|<1080 Clarissa>*100$73.zzzzzzzzzzzzz3zzzzzzzzzzy0TzzzzzzzzzyDCzxzzvwzDxyDiDwy0sw71wz7zbwD6SQnAwDbzny7X7CTby7nztyFlXb7lyFszwzAsnnkwDAwTyTUQ3twD3USDzDU61wz7lU73vbnn4STlwHnklnXtX7CtiHtw1s1wFlb1kNwTrzzzzzzvyzzzzzzzzzzzzzzy"
, 1050_ClarissaStr := "|<1050 Clarissa>*64$69.zzzzzzzzzzzz0TzzzzzzzzzkVzzzzzzzzzwSMzns7XksTDXz7wT0QQ21lwzwzVsnn63C7bzbtD6SQSDYwzwz8snnVkwXXzbv70SS73gQTwy0s7nwS83XxbnX4STntCC6QkwMlnC73ls3U7n66Q62TDlzzzzzzlszzzzzzzzzzzzzw"

, 1080_PetarusStr := "|<1080 Petarus>*100$69.zzzzzzzzzzzw7zzzzzzzzzzUDzzzzzzzzzwtzzzzTzyzTDb61U3ns3XlkQsthXQD6QTAnb7DwTVslXtbwttzXt76ATATUT1wTAsnntkwDsTXs70yTD3bzDwS0M7ntwQztzXnn4STTlbzDwQyMllniQzs7Xbl770w7zzzzzzzzyTvzzzzzzzzzzzzU"
, 1050_PetarusStr := "|<1050 Petarus>*92$66.zzzzzzzzzzzUDzzzzzzzzzn7zzzzzzzzzna10DbkT7b3na1077k77a1naDsz3lb7aPnaDsyHlb7aTkC1syHlb7a7kS1sylk77b3nyDtw1kD7blnyDtwsl7bbtnyDttwlbb6tny1stwlnUC3zzzzzzzzszjzzzzzzzzzzzU"

, 1080_LaniStr := "|<1080 Lani>*100$36.zzzzzzbzzzzzbzzzzzbzjrxvbzDXslby7lttby7kttbwXkNtbwnm9tbw3n9tbs1n1tbttnVtb3tnltU3snttzzzzzzU"
, 1050_LaniStr := "|<1050 Lani>*73$37.zzzzzzlzzzzzwzzzzzyTwyTb7DwT7nXby7lttnyHsQwtz8x6SQzgSlDCTUDQ7bDnXj3nb3lrltk1wvswzzzzzzs"

, 1080_FenceStr := "|<1080 Fence>*40$48.0TzzzzzzUDzzzzzzbDzjvyDzbs37ls20bwnXllXAbwzVnXrDUQzUnbzDUw7UHbz1bw7Y3bz1bwza3XzDbwzb3XzDbwzbXlnDbw3bnk70zzzzzwTzU"

, 1440_JunStr := "|<1440 Jun>*89$45.zzzzzzzzzzzzzzzz3zzzzzzsTzzzzzz3zzzzzzsSDltzXz3lyD7wTsSDlsTnz3lyD1yTsSDls7nz3lyD0STsSDlsVnz3lyD66TsSDlssHz3lyD70TsSDlsw3z3kyT7kTsT03sz3z7w0z7wTszsTzzzz7zzzzzzlzzzzzzwTzzzzzzbzzzzzzU"
Global 1080_ChestStr := "|<Door>*86$33.XDXDX0swswsU|<Door>*86$33.XDXDX0swswsU"
, 1080_ChestStr .= "|<Chest>*85$26.bnnAtwwzCTDDlU3kQ80w7mTDDybnnzs"
, 1080_ChestStr .= "|<Excavated Chest>*75$28.bnkv6DD3wMtt7lnbYT74y1wSHk3lsTDD6"
, 1080_ChestStr .= "|<1080 Trunk>*100$30.6ATC76ATC36STCF0yTCNU"
, 1080_ChestStr .= "|<1080 Rack>*100$25.lsSDNt7Dlwnbsy1ny"
, 1080_ChestStr .= "|<Cocoon>*91$15.zzrzwzz1zl7y8znXyQTlXyAzlby1zsTzbzzU"
, 1080_ChestStr .= "|<Lever>*91$18.aTCyDCyCSDCSD4yzYyU"
, 1080_ChestStr .= "|<1080 Crank>*100$24.Xky7XYS3baSFDUSNU"
, 1080_ChestStr .= "|<1080 Hoard>*100$31.DXYQMblnCAnss70w"
, 1080_ChestStr .= "|<1080 Sulphite>*100$36.lzzzzziTzzzzDTzzzzDwywz17wywzAXwywzSlwywzSswywzSyQywz1yQywzDzQywzDSQwwzDUy1w3DU"
, 1080_ChestStr .= "|<1080 Hand>*47$28.mD0ba0wUSM1n1tU"
, 1080_ChestStr .= "|<1080 LodeStone>*88$32.wnAgPDDnz7VnwTltQ71wSL1wD7bnzXltU"
, 1080_ChestStr .= "|<1080 Blight>*98$21.bDz4twsb77A"

Global 1050_ChestStr := "|<1050 Door>*92$44.zzzzzzzs1zzzzzzADzzzzznVwDsS3wwQ1s3UDDWCAQMnnsbnDaAwy9wntXDDaTAyM3ntbnDa1wwMwltWDCC6QAsnk7kDUSCTzzDyTzzzzzzzzzU"
, 1050_ChestStr .= "|<1050 Chest>*84$48.zzzzzzzzw3zzzzzzlXzzzzzznn7X0sE3XzbX0k01bzbX7nSDbzbX7nyDbzU30kyDbzU30sSDXzbX7yCTXxbX7zCTknbX7rCTs3bX0kSDyTzzzxzzzzzzzzzzU"
, 1050_ChestStr .= "|<1050 Trunk>*97$55.zzzzzzzzzk0zzzzzzzs0TzzzzzzznsDXnDnXbtw1ltnttXwyAswswwXyT6QSQCSHzDXCDCXD3zbk77bMbVzns7Xni3kTtwFttrVt7wyAwsvswlyT7C0xySMzzzzlzzzzzzzzzzzzzw"
, 1050_ChestStr .= "|<1050 Rack>*91$41.zzzzzzz0TzzzzzATzzzzyQzDwCCQtwTUCMtnsSCQXnbYwztDUT9tzkz1ylnzVyFs3bz1wlnX7yFtlDb7QlnkTC0tXzzzzbzy"
, 1050_ChestStr .= "|<1050 Cocoon>*88$66.zzzzzzzzzzzw3zzzzzzzzzlXzzzzzzzzznnsTkz3y7btXzUD0Q1s3ntbz76CMsllltbzDaTtwntktbzDaTtwntoNbzDaTtwntq9XzDaTtwntr1Xx7aDswltrVkn3D7MNknrls3UT0Q3s7rtyTtztzDyTzzzzzzzzzzzzzU"
, 1050_ChestStr .= "|<1050 Lever>*90$45.zzzzzzzwTzzzzzznzzzzzzyTUFwUMDnw2DY30STXttXsnnwT7AT6STUQtUMnnw3aQ30STXwHXs7nwTkwT4SQXy7XsnkA3tw37Dzzzjzzzzzzzzzzw"
, 1050_ChestStr .= "|<1050 Crank>*85$54.zzzzzzzzzw3zzzzzzzlXzzzzzzznn1zbnwstXz0T7twwlbz6T3swwXbz6SHsQwbbz6SHuAwDbz0Slv4wDXz0w1vUw7Xx4QsvkwXkn6Nwvswls379wvwwlyTzzzzzzzzzzzzzzzzU"
, 1050_ChestStr .= "|<1050 Hoard>*99$55.zzzzzzzzznszzzzzzztyTzzzzzzwzDkzbsTUyTbWDXsXm7DnnXkyNtnU1ntuTAwsk0twtDaSSNyQyRnkTDAzCTA1sTbaTb7awwbnbDnnbTCNtnbtw7DbCQ7zzzzzzzzzs"
, 1050_ChestStr .= "|<1050 Sulphite>*63$37.zzzzzzsDzzzztXzzzzwvXnbkSTltns33swtwNkwSQyAwCDCT6TX7bDUTtXnbkTwttnszAQstwTUT0w6Dwzvzzzzzzzzzw"
, 1050_ChestStr .= "|<1050 LodeStone>*99$66.zzzzzzzzzzzXzzzzzzzzzznzzzzzzzzzznzVs7kC40y7ny0s1kA00M3nwQMtlwrXllnwyMslwzXntnwyMwkQDXntnwyMwkS7bntnwyMwlzXbntnwSMslznbltnaQsllxnbtnkC1s3kA7Xs7zzbzzzzTzyTzzzzzzzzzzzU"
, 1050_ChestStr .= "|<1050 Blight>*95$57.zzzzzzzzzw1zzzzzzzzmDzzzzzzzyMlwTVswE3nDDXk7bW0CNtyQQwwSDkDDnbzbXlyMtyQzw0SDnbDnbzU3lyQtyQwQwSTnbDnXXbXnyMtaSAQwSTkD0nk3bXlzzzzzXzzzzzzzzzzzzzw"

Global 1080_DelveStr := "|<1080 Hidden>*100$65.7szzzzzzzzzDlzzzzzzzzyTXnyzyzzyzgz770D0D0My9yDDADADAswHwSSQSQSTktU0wwwQwQzUn01ttstssD0aTXnnlnlkSEAz7bbXbXbwkNyDDDDDDDtknwSSMyMyTnlbsww3w3w3bn"
, 1080_DelveStr .= "|<1080 Lost>*100$37.7zzzzznzzzzztztzbTozkD0U2TlXaKBDlsnz7btwMzXnwyA7ltyT7Vswz7XswSTXnyCDCElrD7UA1s7XzzXyDzs"
, 1080_DelveStr .= "|<1080 Forgot>*100$61.0zzzzzzzzzUDzzzzzzzznbnzzz7yTTlzUS0y0w3U0zX76CAQMqATXlX6DQSD70nslXDyT7XUtwMnbzDXlnwyA1ntblstyD61sslswQz7b4QSMwyCTVXX77AAT7Ds3llk70TXzz7zzwTszzs"
, 1080_DelveStr .= "|<1080 Cache>*100$52.s7zzzzzzz0DzzzzzzsszTwSTDz7rsz0Fws0Tz3slbnn3zwD7iTDDDzYQztwwwTyFnzU3kFzk7Dy0D17z0ATtwwwDgslzbnns8blXaTDDk6T60tww3lzzyDzzzs"
, 1080_DelveStr .= "|<1080 Cache Yellow>*100$51.wDzzzzzzy0TzzzzzzXnzzzzzzwyzDs7DbUDzkySNwwlzybXzDbbDzowztwwtzwnbz07U7ziQztww8zs1bzDbbXzDATtwwwCPtlnDbbk6T70tww4"
, 1080_DelveStr .= "|<1080 Vein>*100$39.7szzzzsz7zzzzXszySzgTA1XXsntnCSDCCSTnktlnnyS3DAy3nk9sbkSSED4yTnn1wDnySQDVyTnnlyTkCSTDvzzzzzU"
, 1080_DelveStr .= "|<1080 Fossil>*100$50.0Tzzzzzzs3zzzzzzyQyTtyTDDby1s61XXtz6CNaQwyTXlbtzDDUNwMyDnnsCT63UwwyTblsS7DDbswT7lnntyDDsyAwyTVXiPbDCbw1s61nkDzlz7lzzy"
, 1080_DelveStr .= "|<1080 Resona>*100$62.0Tzzzzzzzzk3zzzzzzzzyQTznzDvyzjb60kD0wT7ltlnAnX7XlsSQQzDlssQy7bDDlwyC3D8s7kQ7DXUHmC1w7knst0s3aDDyASCMC0NVnzl7bb3b6QQzQkltsnsXX0kC0yTAyDzzyDszzzzy"
; FindText strings from INI
Global StashStr, HeistLockerStr, VendorStr, VendorMineStr, HealthBarStr, SellItemsStr, SkillUpStr, ChestStr, DelveStr
, XButtonStr
, VendorLioneyeStr, VendorForestStr, VendorSarnStr, VendorHighgateStr
, VendorOverseerStr, VendorBridgeStr, VendorDocksStr, VendorOriathStr, VendorHarbourStr

; Automation Settings
Global YesEnableAutomation, FirstAutomationSetting, YesEnableNextAutomation,YesEnableAutoSellConfirmation,YesEnableAutoSellConfirmationSafe

; General
Global BranchName := "master"
Global selectedLeague, UpdateDatabaseInterval, LastDatabaseParseDate, YesNinjaDatabase
, ScriptUpdateTimeInterval, ScriptUpdateTimeType
Global Latency := 1
Global ClickLatency := 0
Global ClipLatency := 0
Global ShowOnStart := 0
Global PopFlaskRespectCD := 1
Global ResolutionScale := "Standard"
Global YesGuiLastPosition := 1
Global YesSortFirst := 1
Global FlaskList := []
Global AreaScale := 0
Global LVdelay := 0
Global LootVacuum := 1
Global LootVacuumTapZ := 1
Global LootVacuumTapZEnd := 1
Global LootVacuumTapZSec := 3
Global YesVendor := 1
Global YesStash := 1
Global YesIdentify := 1
Global YesDiv := 1
Global YesMapUnid := 1
Global YesInfluencedUnid := 1
Global YesCLFIgnoreImplicit := 0
Global YesStashKeys := 1
Global OnHideout := False
Global OnTown := False
Global OnMines := False
Global OnDetonate := False
Global OnDetonateDelve := False
Global OnMenu := False
Global OnChar := False
Global OnChat := False
Global OnInventory := False
Global OnStash := False
Global OnVendor := False
Global OnDiv := False
Global OnLeft := False
Global OnDelveChart := False
Global OnMetamorph := False
Global OnLocker := False
Global RescaleRan := False
Global ToggleExist := False
Global YesOHB := True
Global YesFillMetamorph := True
Global YesPredictivePrice := "Off"
Global YesPredictivePrice_Percent_Val := 100
Global HPerc := 100
Global GameX, GameY, GameW, GameH, mouseX, mouseY
Global OHB
Global WinGuiX := 0
Global WinGuiY := 0
Global YesVendorDumpItems := 0
Global HeistAlcNGo := 1
Global YesBatchVendorBauble := 1
Global YesBatchVendorGCP := 1
Global YesOpenStackedDeck := True
Global YesSpecial5Link := True
Global EnableRestock:=True
Global MoveMapsToArea:=True
Global YesIncludeFandSItem := True

; Item Crafting

Global ItemCraftingcategorySelector
Global ItemCraftingBaseSelector
Global ItemCraftingMethod
Global ItemCraftingNumberPrefix
Global ItemCraftingNumberSuffix
Global ItemCraftingNumberCombination

; Chaos Recipe
Global ChaosRecipeEnableFunction := False
Global ChaosRecipeUnloadAll := True
Global ChaosRecipeEnableUnId := True
Global ChaosRecipeSmallWeapons := True
Global ChaosRecipeSkipJC := True
Global ChaosRecipeLimitUnId := 74
Global ChaosRecipeAllowDoubleJewellery := True
Global ChaosRecipeAllowDoubleBelt := True
Global ChaosRecipeMaxHoldingID := 12
Global ChaosRecipeMaxHoldingUNID := 12
Global ChaosRecipeTypePure := 0
Global ChaosRecipeTypeHybrid := 1
Global ChaosRecipeTypeRegal := 0
Global ChaosRecipeStashMethodDump := 0
Global ChaosRecipeStashMethodTab := 1
Global ChaosRecipeStashMethodSort := 0
Global ChaosRecipeStashTab := 1
Global ChaosRecipeStashTabWeapon := 1
Global ChaosRecipeStashTabHelmet := 1
Global ChaosRecipeStashTabArmour := 1
Global ChaosRecipeStashTabGloves := 1
Global ChaosRecipeStashTabBoots := 1
Global ChaosRecipeStashTabBelt := 1
Global ChaosRecipeStashTabAmulet := 1
Global ChaosRecipeStashTabRing := 1

; Loot colors for the vacuum
Global LootColors := { 1 : 0xF6FEC4
	, 2 : 0xCCFE99
	, 3 : 0xA36565
, 4 : 0x773838}
Global YesLootChests := 1
Global YesLootDelve := 1
Global Detonated := 0
Global CurrentTab := 0
Global DebugMessages := 0
Global YesTimeMS := 0
Global YesLocation := 0
Global ShowPixelGrid := 0
Global ShowItemInfo := 0
Global Latency := 1
Global RunningToggle := False
Global AutoUpdateOff := 0
Global EnableChatHotkeys := 0
; Dont change the speed & the tick unless you know what you are doing
Global Speed:=1
Global Tick:=50
Global KeyscanRate:=15
; Globe
Global Globe:= OrderedArray()
Globe.Life := OrderedArray("X1",106,"Y1",886,"X2",146,"Y2",1049)
Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
Globe.Life.Color := OrderedArray()
Globe.Life.Color.hex := Format("0x{1:06X}",0xAF1525)
Globe.Life.Color.variance := 22
Globe.Life.Color.Str := Hex2FindText(Globe.Life.Color.hex,Globe.Life.Color.variance,0,"Life",1,1)
Globe.ES := OrderedArray("X1",165,"Y1",886,"X2",210,"Y2",1064)
Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
Globe.ES.Color := OrderedArray()
Globe.ES.Color.hex := Format("0x{1:06X}",0x51DEFF)
Globe.ES.Color.variance := 8
Globe.ES.Color.Str := Hex2FindText(Globe.ES.Color.hex,Globe.ES.Color.variance,0,"ES",1,1)
Globe.EB := OrderedArray("X1",1720,"Y1",886,"X2",1800,"Y2",1064)
Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
Globe.EB.Color := OrderedArray()
Globe.EB.Color.hex := Format("0x{1:06X}",0x51DEFF)
Globe.EB.Color.variance := 8
Globe.EB.Color.Str := Hex2FindText(Globe.EB.Color.hex,Globe.EB.Color.variance,0,"EB",1,1)
Globe.Mana := OrderedArray("X1",1760,"Y1",878,"X2",1830,"Y2",1060)
Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
Globe.Mana.Color := OrderedArray()
Globe.Mana.Color.hex := Format("0x{1:06X}",0x1B2A5E)
Globe.Mana.Color.variance := 4
Globe.Mana.Color.Str := Hex2FindText(Globe.Mana.Color.hex,Globe.Mana.Color.variance,0,"Mana",1,1)
Global Base := OrderedArray()
Base.Globe := Array_DeepClone(Globe)
; Player
Global Player := OrderedArray()
Player.Percent := {"Life":100, "ES":100, "Mana":100}


;Stash Tabs Management
Global StashTabLinked := 1
Global StashTabYesLinked := 1
Global StashTabBrickedMaps := 1
Global StashTabYesBrickedMaps := 1
Global StashTabInfluencedItem := 1
Global StashTabYesInfluencedItem := 1
Global StashTabCrafting := 1
Global StashTabYesCrafting := 1
Global StashTabVeiled := 1
Global StashTabYesVeiled := 1
Global StashTabClusterJewel := 1
Global StashTabYesClusterJewel := 1
Global StashTabHeistGear := 1
Global StashTabYesHeistGear := 1
Global StashTabMiscMapItems := 1
Global StashTabYesMiscMapItems := 1
Global StashTabDump := 1
Global StashTabYesDump := 1

;Priced Tabs Options
Global StashTabPredictive := 1
Global StashTabYesPredictive := 0
Global StashTabYesPredictive_Price := 5
Global StashTabNinjaPrice := 1
Global StashTabYesNinjaPrice := 0
Global StashTabYesNinjaPrice_Price := 5

;Dump Tab Options
Global StashDumpInTrial := 1
Global StashDumpSkipJC := 1

;Affinities
Global StashTabCurrency := 1
Global StashTabYesCurrency := 0
Global StashTabMap := 1
Global StashTabYesMap := 0
Global StashTabDivination := 1
Global StashTabYesDivination := 0
Global StashTabMetamorph := 1
Global StashTabYesMetamorph := 0
Global StashTabFragment := 1
Global StashTabYesFragment := 0
Global StashTabEssence := 1
Global StashTabYesEssence := 0
Global StashTabBlight := 1
Global StashTabYesBlight := 0
Global StashTabDelirium := 1
Global StashTabYesDelirium := 0
Global StashTabDelve := 1
Global StashTabYesDelve := 0
Global StashTabUnique := 1
Global StashTabYesUnique := 0
Global StashTabGem := 1
Global StashTabYesGem := 0
Global StashTabFlask := 1
Global StashTabYesFlask := 0

;Unique Logic
Global StashTabYesUniquePercentage := 0
Global StashTabUniquePercentage := 70
Global StashTabYesUniqueRingAll := 0
Global StashTabYesUniqueDumpAll := 0
Global StashTabUniqueRing := 1
Global StashTabUniqueDump := 1

;Unique Options
Global StashTabYesUniqueRing := 1
Global StashTabYesUniqueDump := 1

; Crafting Bases Options
Global CraftingBaseTypeSelector
Global YesStashBasesAboveIlvl := False
Global StashBasesAboveIlvl := False
Global YesCraftingBaseAutoUpdateOnStart := False
Global YesCraftingBaseAutoUpdateOnZone := False
Global YesCraftingBaseLimitBases := False
Global CraftingBaseLimitBasesNumber := 3

; Skip Maps after column #
Global YesSkipMaps := 0
Global YesSkipMaps_Prep := 1
Global YesSkipMaps_eval := ">="
Global YesSkipMaps_normal := 0
Global YesSkipMaps_magic := 1
Global YesSkipMaps_rare := 1
Global YesSkipMaps_unique := 1
Global YesSkipMaps_tier := 2
; Controller
Global YesController := 1
Global checkvar:=0
Global YesMovementKeys := 0
Global YesTriggerUtilityKey := 0
Global TriggerUtilityKey := 1
Global JoystickNumber := 0
Global JoyThreshold := 6
Global JoyThresholdUpper := 50 + JoyThreshold
Global JoyThresholdLower := 50 - JoyThreshold
Global InvertYAxis := false
Global JoyMultiplier := 0.30
Global JoyMultiplier2 := 8
Global hotkeyControllerButtonA,hotkeyControllerButtonB,hotkeyControllerButtonX,hotkeyControllerButtonY,hotkeyControllerButtonLB,hotkeyControllerButtonRB,hotkeyControllerButtonBACK,hotkeyControllerButtonSTART,hotkeyControllerButtonL3,hotkeyControllerButtonR3,hotkeyControllerJoystickRight
Global YesTriggerUtilityJoystickKey := 1
Global YesTriggerJoystickRightKey := 1
; ~ Hotkeys
; Legend:    ! = Alt    ^ = Ctrl    + = Shift 
Global hotkeyOptions:="!F10"
Global hotkeyAutoFlask:="!F11"
Global hotkeyAutoQuit:="!F12"
Global hotkeyAutoMove:="!MButton"
Global hotkeyAutoUtility:="!Backspace"
Global hotkeyLogout:="F12"
Global hotkeyPopFlasks:="CapsLock"
Global hotkeyItemSort:="F6"
Global hotkeyItemInfo:="F5"
Global hotkeyChaosRecipe:="F8"
Global hotkeyLootScan:="f"
Global hotkeyDetonateMines:="d"
Global hotkeyPauseMines:="d"
Global hotkeyQuickPortal:="!q"
Global hotkeyGemSwap:="!e"
Global hotkeyStartCraft:="F7"
Global hotkeyCraftBasic:="F9"
Global hotkeyCtrlClicker:=""
Global hotkeyCtrlShiftClicker:=""
Global hotkeyShiftClicker:=""
Global hotkeyGrabCurrency:="!a"
Global hotkeyGetMouseCoords:="!o"
Global hotkeyCloseAllUI:="Space"
Global hotkeyInventory:="c"
Global hotkeyWeaponSwapKey:="x"
Global hotkeyMainAttack:="RButton"
Global hotkeySecondaryAttack:="w"
Global hotkeyDetonate:="d"
Global hotkeyUp := "W"
Global hotkeyDown := "S"
Global hotkeyLeft := "A"
Global hotkeyRight := "D"
Global hotkeyCastOnDetonate := "Q"
Global hotkeyTriggerMovement := "LButton"

; Inventory Colors
Global varEmptyInvSlotColor := [0x000100, 0x020402, 0x000000, 0x020302, 0x010101, 0x010201, 0x060906, 0x050905] ;Default values from sauron-dev
; Failsafe Colors
Global varOnMenu:=0xD6B97B
Global varOnChar:=0x6B5543
Global varOnChat:=0x88623B
Global varOnInventory:=0xDCC289
Global varOnStash:=0xECDBA6
Global varOnVendor:=0xCEB178
Global varOnVendorHeist:=0xCEB178
Global varOnDiv:=0xF6E2C5
Global varOnLeft:=0xB58C4D
Global varOnDelveChart:=0xB58C4D
Global varOnMetamorph:=0xE06718
Global varOnLocker:=0xE97724
Global varOnDetonate := 0x5D4661
Global varOnDetonateDelve := 0x5D4661

; Grab Currency
Global GrabCurrencyX:=1877
Global GrabCurrencyY:=772

; Chat Hotkeys, and stash hotkeys
Global CharName := "ReplaceWithCharName"
Global RecipientName := "NothingYet"
Global fn1, fn2, fn3
Global 1Prefix1, 1Prefix2, 2Prefix1, 2Prefix2, stashPrefix1, stashPrefix2
Global 1Suffix1,1Suffix2,1Suffix3,1Suffix4,1Suffix5,1Suffix6,1Suffix7,1Suffix8,1Suffix9
Global 1Suffix1Text,1Suffix2Text,1Suffix3Text,1Suffix4Text,1Suffix5Text,1Suffix6Text,1Suffix7Text,1Suffix8Text,1Suffix9Text
Global 2Suffix1,2Suffix2,2Suffix3,2Suffix4,2Suffix5,2Suffix6,2Suffix7,2Suffix8,2Suffix9
Global 2Suffix1Text,2Suffix2Text,2Suffix3Text,2Suffix4Text,2Suffix5Text,2Suffix6Text,2Suffix7Text,2Suffix8Text,2Suffix9Text
Global stashSuffix1,stashSuffix2,stashSuffix3,stashSuffix4,stashSuffix5,stashSuffix6,stashSuffix7,stashSuffix8,stashSuffix9
Global stashSuffixTab1,stashSuffixTab2,stashSuffixTab3,stashSuffixTab4,stashSuffixTab5,stashSuffixTab6,stashSuffixTab7,stashSuffixTab8,stashSuffixTab9

; Map Crafting Settings
Global StartMapTier1,StartMapTier2,StartMapTier3,StartMapTier4,EndMapTier1,EndMapTier2,EndMapTier3,CraftingMapMethod1,CraftingMapMethod2,CraftingMapMethod3,EnableMQQForMagicMap,MMQorWeight,MMapItemRarity,MMapMonsterPackSize,MMapItemQuantity,MMapWeight,ForceMaxChisel,SextantDDLSelector

; ItemInfo GUI
Global PercentText1G1, PercentText1G2, PercentText1G3, PercentText1G4, PercentText1G5, PercentText1G6, PercentText1G7, PercentText1G8, PercentText1G9, PercentText1G10, PercentText1G11, PercentText1G12, PercentText1G13, PercentText1G14, PercentText1G15, PercentText1G16, PercentText1G17, PercentText1G18, PercentText1G19, PercentText1G20, PercentText1G21, 
Global PercentText2G1, PercentText2G2, PercentText2G3, PercentText2G4, PercentText2G5, PercentText2G6, PercentText2G7, PercentText2G8, PercentText2G9, PercentText2G10, PercentText2G11, PercentText2G12, PercentText2G13, PercentText2G14, PercentText2G15, PercentText2G16, PercentText2G17, PercentText2G18, PercentText2G19, PercentText2G20, PercentText2G21, 
Global PComment1 := "LongDataTextNameSpace"
Global PData1 := "000.000"
Global PComment2 := "LongDataTextNameSpace"
Global PData2 := "000.000"
Global PComment3 := "LongDataTextNameSpace"
Global PData3 := "000.000"
Global PComment4 := "LongDataTextNameSpace"
Global PData4 := "000.000"
Global PComment5 := "LongDataTextNameSpace"
Global PData5 := "000.000"
Global PComment6 := "LongDataTextNameSpace"
Global PData6 := "000.000"
Global PComment7 := "LongDataTextNameSpace"
Global PData7 := "000.000"
Global PComment8 := "LongDataTextNameSpace"
Global PData8 := "000.000"
Global PComment9 := "LongDataTextNameSpace"
Global PData9 := "000.000"
Global PComment10 := "LongDataTextNameSpace"
Global PData10 := "000.000"
Global SComment1 := "LongDataTextNameSpace"
Global SData1 := "000.000"
Global SComment2 := "LongDataTextNameSpace"
Global SData2 := "000.000"
Global SComment3 := "LongDataTextNameSpace"
Global SData3 := "000.000"
Global SComment4 := "LongDataTextNameSpace"
Global SData4 := "000.000"
Global SComment5 := "LongDataTextNameSpace"
Global SData5 := "000.000"
Global SComment6 := "LongDataTextNameSpace"
Global SData6 := "000.000"
Global SComment7 := "LongDataTextNameSpace"
Global SData7 := "000.000"
Global SComment8 := "LongDataTextNameSpace"
Global SData8 := "000.000"
Global SComment9 := "LongDataTextNameSpace"
Global SData9 := "000.000"
Global SComment10 := "LongDataTextNameSpace"
Global SData10 := "000.000"
Global GroupBox1 := "LongDataTextNameSpaceLongDataTextNameSpaceLongDataTextNameSpace"
Global GroupBox2 := "LongDataTextNameSpaceLongDataTextNameSpaceLongDataTextNameSpace"
Global ItemInfoPropText := "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
Global ItemInfoAffixText := "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
Global ItemInfoModifierText := "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
Global ItemInfoStatText := "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
Global graphWidth := 219
Global graphHeight := 221
Global ForceMatch6Link := False
Global ForceMatchGem20 := False
; Ingame Overlay Transparency
Global YesInGameOverlay := 0

