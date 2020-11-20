; Contains all the pre-setup for the script
  Global VersionNumber := .12.0304
  #IfWinActive Path of Exile 
  #NoEnv
  #MaxHotkeysPerInterval 99000000
  #HotkeyInterval 99000000
  #KeyHistory 0
  #SingleInstance force
  #Warn UseEnv 
  #Persistent 
  #InstallMouseHook
  #InstallKeybdHook
  #MaxThreadsPerHotkey 2
  #MaxMem 256
  ListLines Off
  ; Process, Priority, , A
  SetBatchLines, -1
  SetKeyDelay, -1, -1
  SetMouseDelay, -1
  SetDefaultMouseSpeed, 0
  SetWinDelay, -1
  SetControlDelay, -1
  CoordMode, Mouse, Screen
  CoordMode, Pixel, Screen
  CoordMode, Tooltip, Screen
  FileEncoding , UTF-8
  SendMode Input
  StringCaseSense, On ; Match strings with case.
  FormatTime, Date_now, A_Now, yyyyMMdd
  If A_AhkVersion < 1.1.28
  {
    Log("Load Error","Too Low version")
    msgbox 1, ,% "Version " A_AhkVersion " AutoHotkey has been found`nThe script requires minimum version 1.1.28+`nPress OK to go to download page"
    IfMsgBox, OK
    {
      Run, "https://www.autohotkey.com/download/"
      ExitApp
    }
    Else 
      ExitApp
  }

  OnMessage(0x5555, "MsgMonitor")
  ; OnMessage(0x5556, "MsgMonitor")
  OnMessage( 0xF, "WM_PAINT")
  OnMessage(0x200, Func("ShowToolTip"))  ; WM_MOUSEMOVE

  SetTitleMatchMode 2
  SetWorkingDir %A_ScriptDir%  
  Thread, interrupt, 0
  I_Icon = %A_ScriptDir%\data\WR.ico
  IfExist, %I_Icon%
  Menu, Tray, Icon, %I_Icon%

  ; Setup for LutBot logout method
  full_command_line := DllCall("GetCommandLine", "str")
  GetTable := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "GetExtendedTcpTable", "Ptr")
  SetEntry := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "SetTcpEntry", "Ptr")
  EnumProcesses := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Psapi.dll", "Ptr"), Astr, "EnumProcesses", "Ptr")
  preloadPsapi := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")
  OpenProcessToken := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "OpenProcessToken", "Ptr")
  LookupPrivilegeValue := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "LookupPrivilegeValue", "Ptr")
  AdjustTokenPrivileges := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "AdjustTokenPrivileges", "Ptr")
  
  ; CleanUp()
  ;REMEMBER TO ENABLE IF PUSHING TO ALPHA/MASTER!!!
  ; Rerun as admin if not already admin, required to disconnect client
  if not A_IsAdmin
    if A_IsCompiled
    Run *RunAs "%A_ScriptFullPath%" /restart
  else
    Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
  Sleep, -1
  
  IfNotExist, %A_ScriptDir%\data
    FileCreateDir, %A_ScriptDir%\data
  IfNotExist, %A_ScriptDir%\save
    FileCreateDir, %A_ScriptDir%\save
  IfNotExist, %A_ScriptDir%\save\profiles
    FileCreateDir, %A_ScriptDir%\save\profiles
  IfNotExist, %A_ScriptDir%\save\profiles\Flask
    FileCreateDir, %A_ScriptDir%\save\profiles\Flask
  IfNotExist, %A_ScriptDir%\save\profiles\perChar
    FileCreateDir, %A_ScriptDir%\save\profiles\perChar
  IfNotExist, %A_ScriptDir%\save\profiles\Utility
    FileCreateDir, %A_ScriptDir%\save\profiles\Utility
  IfNotExist, %A_ScriptDir%\temp
    FileCreateDir, %A_ScriptDir%\temp
  
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; Extra vars - Not in INI
    Global rxNum := "(?!\+1 )(?!1 (?!to \d))(?!\+1\%)(?!1\%)"
      . "(?!\d{1,} second)"
      . "(?!\d{1,} Poisons)"
      . "(?!\d{1,} Rampage)"
      . "(?!\d{1,} Dexterity)"
      . "(?!\d{1,} total Dexterity)"
      . "(?!\d{1,} Intelligence)"
      . "(?!\d{1,} total Intelligence)"
      . "(?!\d{1,} Strength)"
      . "(?!\d{1,} total Strength)"
      . "\+{0,1}"
      . "(\d{1,}\.{0,1}\,{0,1}\d{0,})"
      . "\%{0,1}"
    Global Controller := {"Btn":{}}
    Global Controller_Active := 0
    Global Item
    Global WR_Statusbar := "WingmanReloaded Status"
    Global WR_hStatusbar
    Global PPServerStatus := True
    Global Ninja := {}
    Global Enchantment  := []
    Global Corruption := []
    Global Bases
    Global num := "\+{0,1}(\d{1,}\.{0,1}\d{0,})\%{0,1}" 
    Global Date_now
    Global GameActive
    Global GamePID
    Global QuestItems
    Global DelayAction := {}
    Global ProfileMenuFlask,ProfileMenuUtility,ProfileMenuperChar
    Global Active_executable := "TempName"
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
    ; List crafting T1
    Global DefaultcraftingBasesT1 := ["Opal Ring"
      , "Steel Ring"
      , "Vermillion Ring"]
    ; List crafting T2
    Global DefaultcraftingBasesT2 := ["Blue Pearl Amulet"
      , "Bone Helmet"
      , "Cerulean Ring"
      , "Convoking Wand"
      , "Crystal Belt"
      , "Fingerless Silk Gloves"
      , "Gripped Gloves"
      , "Marble Amulet"
      , "Sacrificial Garb"
      , "Spiked Gloves"
      , "Stygian Vise"
      , "Two-Toned Boots"
      , "Vanguard Belt"]
    ; List crafting T3
    Global DefaultcraftingBasesT3 := ["Colossal Tower Shield"
      , "Eternal Burgonet"
      , "Hubris Circlet"
      , "Lion Pelt"
      , "Sorcerer Boots"
      , "Sorcerer Gloves"
      , "Titanium Spirit Shield"
      , "Vaal Regalia"
      , "Diamond Ring"
      , "Onyx Amulet"
      , "Two-Stone Ring"
      , "Glorious Plate"
      , "Zodiac Leather"]
    ; List crafting T4/Jewel
    Global DefaultcraftingBasesT4 := ["Cobalt Jewel"
      , "Viridian Jewel"
      , "Crimson Jewel"
      , "Searching Eye Jewel"
      , "Murderous Eye Jewel"
      , "Ghastly Eye Jewel"]
    Global craftingBasesT1 := []
    Global craftingBasesT2 := []
    Global craftingBasesT3 := []
    Global craftingBasesT4 := []
    Global scriptTradeMacro := "_TradeMacroMain.ahk ahk_exe AutoHotkey.exe"
    ; Create Executable group for gameHotkey, IfWinActive
    global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe", "PathOfExile_x64EGS.exe", "PathOfExile_EGS.exe"]
    for n, exe in POEGameArr
      GroupAdd, POEGameGroup, ahk_exe %exe%
    Global GameStr := "ahk_exe PathOfExile_x64.exe"
    ; Global GameStr := "ahk_group POEGameGroup"
    Hotkey, IfWinActive, ahk_group POEGameGroup

    global PauseTooltips:=0
    global Clip_Contents:=""
    global CheckGamestates:=False
    Process, Exist
    Global ScriptPID := ErrorLevel
    global AutoQuit:=0 
    global AutoFlask:=0
    global AutoQuick:=0 
    Global LootFilter := {}
    Global IgnoredSlot := {}
    Global BlackList := {}
    Global YesClickPortal := True
    Global RelogOnQuit := True
    Global MainAttackPressedActive,MainAttackLastRelease,SecondaryAttackPressedActive
    global ColorPicker_Group_Color, ColorPicker_Group_Color_Hex
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
      CalibrateOHBBtn = Calibrate the life color of the Overhead Health Bar`rMake sure the OHB is visible
      ShowSampleIndBtn = Open the Sample GUI which allows you to recalibrate one at a time
      StartCalibrationWizardBtn = Use the Wizard to grab multiple samples at once`rThis will prompt you with instructions for each step
      YesOHB = Pauses the script when it cannot find the Overhead Health Bar
      ShowOnStart = Enable this to have the GUI show on start`rThe script can run without saving each launch`rAs long as nothing changed since last color sample
      AutoUpdateOff = Enable this to not check for new updates when launching the script
      YesPersistantToggle = Enable this to have toggles remain after exiting and restarting the script
      ResolutionScale = Adjust the resolution the script scales its values from`rStandard is 16:9`rClassic is 4:3 aka 12:9`rCinematic is 21:9`rCinematic(43:18) is 43:18`rUltraWide is 32:9`rWXGA(16:10) is 16:10 aka 8:5
      Latency = Use this to multiply the sleep timers by this value`rOnly use in situations where you have extreme lag
      ClickLatency = Use this to modify delay to click actions`rAdd this many multiples of 15ms to each delay
      ClipLatency = Use this to modify delay to Item clip`rAdd this many multiples of 15ms to each delay
      PortalScrollX = Select the X location at the center of Portal scrolls in inventory`rPress Locate to grab positions
      PortalScrollY = Select the Y location at the center of Portal scrolls in inventory`rPress Locate to grab positions
      WisdomScrollX = Select the X location at the center of Wisdom scrolls in inventory`rPress Locate to grab positions
      WisdomScrollY = Select the Y location at the center of Wisdom scrolls in inventory`rPress Locate to grab positions
      GrabCurrencyPosX = Select the X location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
      GrabCurrencyPosY = Select the Y location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
      StockPortal = Enable this to restock Portal scrolls when more than 10 are missing`rThis requires an assigned currency tab to work
      StockWisdom = Enable this to restock Wisdom scrolls when more than 10 are missing`rThis requires an assigned currency tab to work    
      YesEnableAutomation = Enable Automation Routines
      FirstAutomationSetting = Start Automation selected option
      YesEnableNextAutomation = Enable next automation after the first selected
      YesEnableLockerAutomation = Enable Heist automation to find and deposit at Heist Locker
      YesEnableAutoSellConfirmation = Enable Automation Routine to Accept Vendor Sell Button!! Be Careful!!
      YesEnableAutoSellConfirmationSafe = Enable Automation Routine to Accept Vendor Sell Button only when:`n   The vendor is empty`n   The only items are Chromatic or Jeweler
      YesAutoSkillUp = Enable this to Automatically level up skill gems
      YesWaitAutoSkillUp = Enable this to wait for mouse to not be held down before leveling gems
      DebugMessages = Enable this to show debug tooltips`rAlso shows additional options for location and logic readout
      YesTimeMS = Enable to show a tooltip when game logic is running
      YesLocation = Enable to show tooltips with current location information`rWhen checked this will also log zone change information
      hotkeyOptions = Set your hotkey to open the options GUI
      hotkeyAutoFlask = Set your hotkey to turn on and off AutoFlask
      hotkeyTriggerMovement = Set your hotkey to trigger Quicksilver Flasks or Cast on Detonate
      hotkeyAutoQuit = Set your hotkey to turn on and off AutoQuit
      hotkeyLogout = Set your hotkey to Log out of the game
      hotkeyAutoQuicksilver = Set your hotkey to Turn on and off AutoQuicksilver
      hotkeyGetMouseCoords = Set your hotkey to grab mouse coordinates`rIf debug is enabled this function becomes the debug tool`rUse this to get gamestates or pixel grid info
      hotkeyQuickPortal = Set your hotkey to use a portal scroll from inventory
      hotkeyGemSwap = Set your hotkey to swap gems between the two locations set above`rEnable Weapon swap if your gem is on alternate weapon set
      hotkeyStartCraft = Set your hotkey to use Crafting Settings functions, as Map Crafting
      hotkeyCraftBasic = Set your hotkey to use Basic Crafting pop-up, these can be configured in the Crafting Settings.
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
      LootVacuumSettings = Assign your own loot colors and adjust the AreaScale and delay`rAlso contains options for openable containers
      PopFlaskRespectCD = Enable this option to limit flasks on CD when Popping all Flasks`rThis will always fire any extra keys that are present in the bindings`rThis over-rides the option below
      LaunchHelp = Opens the AutoHotkey List of Keys
      YesIdentify = This option is for the Identify logic`rEnable to Identify items when the inventory panel is open
      YesStash = This option is for the Stash logic`rEnable to stash items to assigned tabs when the stash panel is open
      YesHeistLocker = This option is for the Heist Locker logic`rEnable to stash Blueprints and contracts when the Heist Locker panel is open
      YesVendor = This option is for the Vendor logic`rEnable to sell items to vendors when the sell panel is open
      YesDiv = This option is for the Divination Trade logic`rEnable to sell stacks of divination cards at the trade panel
      YesMapUnid = This option is for the Identify logic`rEnable to avoid identifying maps
      YesCLFIgnoreImplicit = This option disable implicits being merged with Pseudos.`rEx: This will ignore implicits in base like two-stone boots (elemental resists)`ror two-stone rings (elemental resists) or wand (spell damage)
      YesSortFirst = This option is for the Stash logic`rEnable to send items to stash after all have been scanned
      YesStashT1 = Enable to stash Tier 1 crafting bases
      YesStashT2 = Enable to stash Tier 2 crafting bases
      YesStashT3 = Enable to stash Tier 3 crafting bases
      YesStashT4 = Enable to stash Abyss Jewel and Jewel as crafting bases
      YesStashCraftingNormal = Enable to stash Normal crafting bases
      YesStashCraftingMagic = Enable to stash Magic crafting bases
      YesStashCraftingRare = Enable to stash Rare crafting bases
      YesStashCraftingIlvl = Enable to only stash above selected ilvl
      YesStashCraftingIlvlMin = Set minimum ilvl
      YesSkipMaps = Select the inventory column which you will begin skipping rolled maps`rDisable by setting to 0
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
      )

    ft_ToolTip_Text_Part2=
      (LTrim
      ChaosRecipeEnableFunction = Enable/Disable the Chaos Recipe logic which includes all of its settings
      ChaosRecipeMaxHolding = Determine how many sets of Chaos Recipe to stash
      ChaosRecipeTypePure = Recipe will affect items which are between 60-74 which have not met other stash/CLF filters`ronly draw items within that range from stash for chaos recipe.
      ChaosRecipeTypeHybrid = Recipe will affect all rares 60+ which have not met other stash/CLF filters`rRequires at least one lvl 60-74 item to make a recipe set`rPriority is given to regal items.
      ChaosRecipeTypeRegal = Recipe will affect items which are 75+ which have not met other stash/CLF filters`ronly draw items for regal recipe from stash.
      ChaosRecipeAllowDoubleJewellery = Belts, Amulets and Rings will be given double allowance of Parts limit
      ChaosRecipeEnableUnId = Keep items which are within the limits of the recipe settings from being identified.
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
      StashTabCollection = Assign the Stash tab for Collection items`rThis is where Uniques will first be attempted to stash
      StashTabYesCollection = Enable to send Collection items to the assigned tab on the left`rThis is where Uniques will first be attempted to stash
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
      StashTabLinked = Assign the Stash tab for 6 or 5 Linked items
      StashTabYesLinked = Enable to send 6 or 5 Linked items to the assigned tab on the left
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
      stashReset = Assign the hotkey to reset the CurrentTab`rThis hotkey will only activate while the Modifier(s) are pressed`rThis hotkey is necessary after moving the tab manually
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
      )

      ft_ToolTip_Text := ft_ToolTip_Text_Part1 . ft_ToolTip_Text_Part2 . ft_ToolTip_Text_Part3
  ; Global Script object
    Global WR := {"loc":{},"Flask":{},"Utility":{},"cdExpires":{},"perChar":{}}
    WR.cdExpires.Group := {}, WR.cdExpires.Flask := {}, WR.cdExpires.Utility := {}
    WR.perChar.Setting := {"typeLife":"1", "typeHybrid":"0", "typeES":"0", "typeEldritch":"0"
      , "quitDC":"1", "quitPortal":"0", "quitExit":"0", "quitBelow":"20", "quitLogBackIn":"1"
      , "movementDelay":".5", "movementMainAttack":"0", "movementSecondaryAttack":"0"
      , "channelrepressEnable":"0" , "channelrepressKey":"RButton", "channelrepressOffsetX1":"0", "channelrepressOffsetY1":"0", "channelrepressOffsetX2":"0", "channelrepressOffsetY2":"0"
        , "channelrepressIcon":"|<Scourge Arrow>0xFDF100@0.60$40.108104040k60E0k30M303UQ1UA0C1kC0s0s70w7U3US3kC040k70k0E30M1011hzw4049zwQE0F3zVt01SLwDw0DsjUzk0zmS7zkDz9QTk1Xw3lk001sD60oQ3UwED1w23k1w7s0DUDkTk3B1z1zUBo5y7z26U0sTk0H00lw0A0017U2k000w0053w/c00kDwj3k01zMMzU0Dptrz01wFgzzU7U2rzzwQ0Tzzzllz7zzzzz03zzzzU003zz008"
        , "channelrepressStack":"|<5 stacks>*52$8.zsC3bsS3wz7nwsSTzs"
      , "autominesEnable":"0", "autominesBoomDelay":"500", "autominesPauseDoubleTapSpeed":"300", "autominesPauseKey":"d", "autominesSmokeDashEnable":"0", "autominesSmokeDashKey":"q"
      , "autolevelgemsEnable":"0", "autolevelgemsWait":"0" 
      , "swap1AltWeapon":"0", "swap1Item":"0", "swap1Xa":"0", "swap1Ya":"0", "swap1Xb":"0", "swap1Yb":"0"
      , "swap2AltWeapon":"0", "swap2Item":"0", "swap2Xa":"0", "swap2Ya":"0", "swap2Xb":"0", "swap2Yb":"0"}
    for k, v in ["Gui","VendorAccept","OnMenu","OnChar","OnChat","OnInventory","OnStash","OnVendor"
    ,"OnDiv","OnLeft","OnDelveChart","OnMetamorph","OnLocker","Detonate","DetonateDelve","DivTrade","DivItem"
    ,"Wisdom","Portal","Scouring","Chisel","Alchemy","Transmutation","Alteration","Augmentation","Vaal"]
      WR.loc[v] := {}
    for k, v in ["1","2","3","4","5"]
    {
      WR.Flask[v] := {"Key":v, "GroupCD":"5000", "Condition":"1", "CD":"5000", "MainAttack":"0", "SecondaryAttack":"0", "Move":"0", "PopAll":"1", "Life":0, "ES":0, "Mana":0, "Group":Chr(A_Index+96), "Slot":A_Index}
      WR.cdExpires.Flask[v] := A_TickCount
    }
    for k, v in ["1","2","3","4","5","6","7","8","9","10"]
    {
      WR.Utility[v] := {"Enable":"0", "OnCD":"0", "Condition":"1", "Key":v, "GroupCD":"5000", "CD":"5000", "MainAttack":"0", "SecondaryAttack":"0", "Move":"0", "PopAll":"0", "Icon":"", "IconShown":"0", "IconSearch":"1", "IconArea":{}, "Life":0, "ES":0, "Mana":0, "Group":"u"A_Index, "Slot":A_Index}
      WR.cdExpires.Utility[v] := A_TickCount
    }
    for k, v in ["a","b","c","d","e","u1","u2","u3","u4","u5","u6","u7","u8","u9","u10","Mana","Life","ES","QuickSilver","Defense"]
      WR.cdExpires.Group[v] := A_TickCount
    
  ; Login POESESSID
    Global PoESessionID := ""
    Global AccountNameSTR := ""
  ; Globals For client.txt file
    Global ClientLog := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"
    Global CurrentLocation := ""
    Global CLogFO
  ; ASCII converted strings of images
    Global 1080_HealthBarStr := "|<1080 Overhead Health Bar>0x221415@0.99$106.Tzzzzzzzzzzzzzzzzu"
      , 1440_HealthBarStr := "|<1440 Overhead Health Bar>0x190D11@0.99$138.TzzzzzzzzzzzzzzzzzzzzzyU"
      , 1440_HealthBarStr_Alt := "|<1440 OHB alt>*58$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1050_HealthBarStr := "|<1050 Overhead Health Bar>0x221415@0.99$104.Tzzzzzzzzzzzzzzzzc"
      , OHBStrW := StrSplit(StrSplit(1080_HealthBarStr, "$")[2], ".")[1]

      , 2160_SellItemsStr := "|<2160 Sell Items>0xE3D7A6@1.00$71.00000001k3U000000003U70003y000070C000AD0000C0Q000U60000Q0s003040000s1k006000001k3U00A000003U7000M000w070C000s007S0C0Q001s00MC0Q0s001s01UA0s1k001w020Q1k3U001w0A0M3U70001y0M0k70C0000y1rzUC0Q0000y3U00Q0s0000w7000s1k0000wC001k3U0000sQ003U700001ks0070C00003Uk00C0Q000071k00Q0s0000A3k20s1k0040k3k81k3U007z03zU3U70007s01y070C0000000000000000000000000000000000000000000000000000000000000000000000004"
      , 1440_SellItemsStr := "|<1440 Sell Items>*106$71.zzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy73zzzzzzzzzwC7zzzzzzzzzwSDzkzzzzzzzswTzVzzzzzzzlszz3tzzzzzzXlzy7nzzzzkT7XzwC0T1wM0SD7zsQ0w1kUMQSDzkw7lVk1sswTzVszbXVvllszz3lyD77k3Xlzy7Xw0CDU77XzwD7s0QTTyD7zsSDlzsyzwSDzkwTXzlxyswTzVsz7vXttlszz3lq7b7k3Xlzy7UC0CDUD7XzwDUS0wTlzzzzzzXz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1080_SellItemsStr := "|<1080 Sell Items>*100$80.zzzjTzzzzzzzzzzzlXzzzzzzzzy3zwMzlzzzzzzz0TzbDyTzzzzzznbztnzbbzzzzzwzsSQztkC74AT37w3bDyQ30k03UESQtnzbbbAAANa3b6Qztttlb76TsM1bDySS0NllVz6Ttnzb7byQQQ7sbyQztltzb77lyMxbDyQSDFlly360NnzbUU4QQPY3kCQztsA37761nzDzzzzDnzzzts"
      , 1050_SellItemsStr := "|<1050 Sell Items>*93$71.zzzzzzzzzzzzzzz6DzzzzzzzzzyATzzzzzzy3zwMzlzzzzztXzslznzzzzznjzlXzbbzzzzby3X7zC3Us133sX6DyQC8k033naATwswtXb73UAMztls37CD28slznXWCCQTaTlXzb7bwQszAxX7zCDDMtlAM36DyQ20lnW1sCATwwC3Xb7DxzzzzwzTzzzzzzzzzzzzzzzzzzzzzzzzzzU"
      , 768_SellItemsStr := "|<768 Sell Items>0xE0E0DB@0.52$56.00NU000007U6M600001A1a1a0000kCNUPtnvXr7qM6QyzxhvBa1aNgnQ7zNUNbvAnUw6M6NUnASDZa1aQgn3STNUNvvArn1000A800G"

      , 1080_HeistLockerStr := "|<1080 Locker>*90$59.7zzzzzzzzzDzzzzzzzzyTyTyTDTzzwzkDk4QE60tz6D6AlnANnwSASt7bslbtwNzkTDlXDnsnzVy3XCTblbz1w70QzDX7yFty1tyDCDwXnwFnaASCNXbslUA1y1nX0llzyTzDzzzzy"

      , 2160_StashStr := "|<2160 Stash>116$64.w0zzzzzzzzz00zzzzzzzzsS3zzzzzzzzXyDzzzzzzzwDszzzzzzzzlzrU00zsTzU3zw003z1zs0DzksADw7zXkTzDVyzUDwTUTzy7zyEzly0TzsTzl3z7w0zzVzz47wDs1zy7zssTkTk1zsTzXUzUTk3zVzyT3y0zUDy7zlwDw3zUTsTz7kTwDz1zVzs01zszy7y7zU07zvzsTsTyDsDzzzVzVzlzkzzzy7y7z7z3zwzkzsTszw7Tk03zVzXzsQTU0Ty7yDzUk307zsTlzz3UDVzzzzzzzzVU"
      , 1440_StashStr := "|<1440 Stash>*92$71.Dz0TzzzwzzXxzy5zzzzzzy7vzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUzzzzzzzzzzw0zzzzzzzzzzttzzzzzzzzzzXvU1zDwDXyTz7y01wDk77szy7wknsT7CDtzy7zVzUySQTnzw3z3z0wTszbzw3y7wlsTlzDzy3wDtXsDU0Tzy3szXXs700zzy7lz07sCDtzzyDXy0DwATnzzwT7tyDwMzbznsyDnwPslzDzU3wT7sE3XyTzUDsSTsUD7wzzlzzzzzlzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1080_StashStr := "|<1080 Stash>0xC8C8DC@0.78$57.00Q000000006s00000001V00000000A3zVUT6301k3UC48kM070A2kk6300S1UK70kM01sA4MQ7z0031UX1skM00MADs3630031V1UMkM08MA8AX6300y1X0rkkQ"
      , 1050_StashStr := "|<1050 Stash>*102$56.zzzzzzzzzzzUzzzzzzzzn7zzzzzzzwv0DbsQwTzDk1lw3D7zkzXwDBnlzy7syHnwwTzkyDYwD07zz7bv7Vk1zzttw1yAwTzySTCDnD7zn7bbnQnlzw3stwkQwTznzzzzTzzzzzzzzzzzU"
      , 768_StashStr := "|<768 Stash>#208@0.49$32.T00007k00033wsxXwACNMrX7b6AQlgxz3AT7MsnAsqBsn7xXU"

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

    Global 1080_ChestStr := "|<1080 Door>*100$47.zzzzzzzz0zzzzzzy0TzzzzzwwTnznzztsS1y1s3nstltllbblXnXnX7DXDXDX6CT6T6T6AwyAyAyA3twNwNwM7ntltltl7b7lXlXX70TkTkT77zzvzvzzzzzzzzzzs"
      , 1080_ChestStr .= "|<1080 Chest>*100$52.zzzzzzzzzsTzzzzzzy0TzzzzzzltrxzzbzyDjDb0w40MzwySPaKBbznttyTsyTzDbbszXszw0S3kyDXzk1sTVsyDzDbbz7XsTQySTyCDklnttytszUDDbUMDXzrzzzzvzzzzzzzzzzy"
      , 1080_ChestStr .= "|<1080 Trunk>*100$57.zzzzzzzzzw0DzzzzzzzU1zzzzzzzxlzzrvrxvvyD0QSAT6CDlsnXtlttnyD6ATC7DAzlslXtkNtDyD6STCFD3zls7ntn9sDyD0yTCMD9zlsXnvnVtbyD6CCSSDATlsss7nttlzzzznzzzzzzzzzzzzzzU"
      , 1080_ChestStr .= "|<1080 Rack>*100$41.zzzzzzz1zzzzzy0zzzzzwtzTwyytlwzUMsnXkyANnb7VsxnDCSFnzYy1wnbz3w3s7Dy3tXU6DwbnbDATtbb4yQQn7D1wQ3b7zzzyTzzzzzzzzs"
      , 1080_ChestStr .= "|<1080 Cocoon>*100$71.zzzzzzzzzzzzwDzzzzzzzzzzU7zzzzzzzzzyDDnznzDzDvysyy1y1s7s7Xslztlslb7b7XnbzXnXqDCDD3bDzDXDwyAyC3CDyT6TtwNwQWQTwyAznsnstYsztwMzblbln1kyltlz7b7bb3kllXln6D6DD7k7kTkD1z1yTDxzvztzjzjzzzzzzzzzzzzzzs"
      , 1080_ChestStr .= "|<1080 Bundle>*100$64.zzzzzzzzzzy3zzzzzzzzzs7zzzzzzzzzbDTjTrzzjzyQswMyA1wT0tnXtlttVtyPUSDb3bb7bty0syQ6SSCTbtlntm9tsty3b7DbAbbXbsSSQyQkSSSTbttnvnVtttyTbD7DD7bDbNy1y1wyS1y1UTzyTzzzzzzzzzzzzzzzzzy"
      , 1080_ChestStr .= "|<1080 Lever>*100$46.DzzzzzzwzzzzzzznzzjvzzzDkATA3UAzatwtiAnyTXnbslDtzCSTX4zUwtsCAny7ljVs7DtzYyTUQzby7ty8naTsTbsl0M7ly1XXzzzjzzzs"
      , 1080_ChestStr .= "|<1080 Crank>*100$54.wDzzzzzzzk3zzzzzzzXnzzrvyxx7r0TblwMs7z6T3swwtDz6D3sQwnDz6CFsAwb7z6SNt4wD7z0y1tYw77z0w0tUwb3v4QwtkwnVX69wtswlk771wNwwsyzzzzzzzzU"
      , 1080_ChestStr .= "|<1080 Hoard>*100$56.DlzzzzzzznwTzzzzzzwz7wzxzzzzDlw3yT0Q1nwSQT3lba4z77bkwMtl01nst76CS00QyCNlbbUz7DXUQ3tsDlnsk30ySHwQSQwl7bYz7X6TAMtnDlw7bl761zzzrzzzzzy"
      , 1080_ChestStr .= "|<1080 Sulphite>*100$36.lzzzzziTzzzzDTzzzzDwywz17wywzAXwywzSlwywzSswywzSyQywz1yQywzDzQywzDSQwwzDUy1w3DU"
      , 1080_ChestStr .= "|<1080 Hand>*47$48.7szzzzzzbszzzzzzbszjrxzTbsz7Xsk3bsy7lstVbsy7kttlU0wXkNtsU0wXk9tsbss3m1tsbss1n1tsbstlnVttbsnsnltXbsnsnts7U"
      , 1080_ChestStr .= "|<1080 LodeStone>*88$69.7zzzzzzzzzzwzzzzzzzzzzzbzbzzzznzztwzkD0D0M40Q3bwMwkwnAgP6Az7Xb7btzXlsbtwQwQz7wST4zDXbXUsDXnsbtwQwQ7kwST4zDXbbbz7XnsbswwwwzwQSDAtX7bDbvbXslUA1w3w30wT0TztzzzzyTzyTU"
      , 1080_ChestStr .= "|<1080 Blight>*98$57.0zzzzzzzzw1zzzzzzzzbDDnyTbnzwtlwT0MyM0bDDnlXbnMo3tyQSwyT7UDDnbzbnswstyQzw0T7b7DnbnU3swwtyQQQyT7b7DnXnbnswttqSCQyT7UT0ns3bnszzzzznzzzzU"

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
    , VendorOverseerStr, VendorBridgeStr, VendorDocksStr, VendorOriathStr
  ; StackRelease tool
    Global 1080_StackRelease_BuffIcon := "|<Blade Flurry Icon>0xD8FAD0@0.81$39.000008001k00US0y0071zzU00E0zs00303zk00A0znw00kTk0S06Tw00Tsvz0003fTk0003Tw0000Lz0000Dzk0001zy0000zrs000DznU003zoQ000zy1k007zUD001zw0s00Tz07U03zk0Q00zw4"
      , 1080_StackRelease_BuffCount := "|<6>0xFEFEFE@0.81$8.01kUM41gFYN6N3U0U"
      , StackRelease_BuffIcon , StackRelease_BuffCount
      , StackRelease_Keybind := "RButton"
      , StackRelease_X1Offset := 0
      , StackRelease_Y1Offset := 2
      , StackRelease_X2Offset := 0
      , StackRelease_Y2Offset := 15
      , StackRelease_Enable := False

  ; Automation Settings
    Global YesEnableAutomation, FirstAutomationSetting, YesEnableNextAutomation,YesEnableLockerAutomation,YesEnableAutoSellConfirmation,YesEnableAutoSellConfirmationSafe

  ; General
    Global BranchName := "master"
    Global selectedLeague, UpdateDatabaseInterval, LastDatabaseParseDate, YesNinjaDatabase
      , ScriptUpdateTimeInterval, ScriptUpdateTimeType
    Global Latency := 1
    Global PauseMinesDelay := 250
    Global ClickLatency := 0
    Global ClipLatency := 0
    Global ShowOnStart := 0
    Global PopFlaskRespectCD := 1
    Global ResolutionScale := "Standard"
    Global YesPersistantToggle := 1
    Global YesGuiLastPosition := 1
    Global YesSortFirst := 1
    Global FlaskList := []
    Global AreaScale := 0
    Global LVdelay := 0
    Global LootVacuum := 1
    Global YesVendor := 1
    Global YesStash := 1
    Global YesHeistLocker := 1
    Global YesIdentify := 1
    Global YesDiv := 1
    Global YesMapUnid := 1
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
    Global OHB, OHBLHealthHex, OHBLManaHex, OHBLESHex, OHBLEBHex, OHBCheckHex
    Global WinGuiX := 0
    Global WinGuiY := 0


    ; Chaos Recipe
    Global ChaosRecipeEnableFunction := False
    Global ChaosRecipeEnableUnId := True
    Global ChaosRecipeSkipJC := True
    Global ChaosRecipeLimitUnId := 82
    Global ChaosRecipeAllowDoubleJewellery := True
    Global ChaosRecipeMaxHolding := 10
    Global ChaosRecipeTypePure := 0
    Global ChaosRecipeTypeHybrid := 1
    Global ChaosRecipeTypeRegal := 0
    Global ChaosRecipeStashMethodDump := 1
    Global ChaosRecipeStashMethodTab := 0
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
    global Detonated := 0
    global CurrentTab := 0
    global DebugMessages := 0
    global YesTimeMS := 0
    global YesLocation := 0
    global ShowPixelGrid := 0
    global ShowItemInfo := 0
    global Latency := 1
    global RunningToggle := False
    Global AutoUpdateOff := 0
    Global EnableChatHotkeys := 0
    ; Dont change the speed & the tick unless you know what you are doing
    global Speed:=1
    global Tick:=150
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
  ; Inventory
    ;Affinities
    Global StashTabCurrency := 1
    Global StashTabMap := 1
    Global StashTabDivination := 1
    Global StashTabMetamorph := 1
    Global StashTabFragment := 1
    Global StashTabEssence := 1
    Global StashTabBlight := 1
    Global StashTabDelirium := 1
    Global StashTabDelve := 1
    Global StashTabUnique := 1

    ;Unique Special
    Global StashTabCollection := 1
    Global StashTabUniqueRing := 1
    Global StashTabUniqueDump := 1
    Global StashTabGem := 1
    Global StashTabGemVaal := 1
    Global StashTabGemQuality := 1
    Global StashTabFlaskQuality := 1
    Global StashTabLinked := 1
    Global StashTabInfluencedItem := 1
    Global StashTabCrafting := 1
    Global StashTabProphecy := 1
    Global StashTabVeiled := 1
    Global StashTabGemSupport := 1
    Global StashTabClusterJewel := 1
    Global StashTabDump := 1
    Global StashTabPredictive := 1
    Global StashTabNinjaPrice := 1
  ; Checkbox to activate each tab
    
        ;Affinities
    Global StashTabYesCurrency := 0
    Global StashTabYesMap := 0
    Global StashTabYesDivination := 0
    Global StashTabYesMetamorph := 0
    Global StashTabYesFragment := 0
    Global StashTabYesEssence := 0
    Global StashTabYesBlight := 0
    Global StashTabYesDelirium := 0
    Global StashTabYesDelve := 0
    Global StashTabYesUnique := 0
    ;Unique Special
    Global StashTabYesCollection := 1
    Global StashTabYesUniqueRing := 1
    Global StashTabYesUniqueDump := 1
    
    Global StashTabYesGem := 1
    Global StashTabYesGemVaal := 1
    Global StashTabYesGemQuality := 1
    Global StashTabYesFlaskQuality := 1
    Global StashTabYesLinked := 1
    Global StashTabYesInfluencedItem := 1
    Global StashTabYesCrafting := 1
    Global StashTabYesProphecy := 1
    Global StashTabYesVeiled := 1
    Global StashTabYesGemSupport := 1
    Global StashTabYesClusterJewel := 1
    Global StashTabYesDump := 1
    Global StashDumpInTrial := 1
    Global StashDumpSkipJC := 1
    Global StashTabYesPredictive := 0
    Global StashTabYesPredictive_Price := 5
    Global StashTabYesNinjaPrice := 0
    Global StashTabYesNinjaPrice_Price := 5
  ; Crafting bases to stash
    Global YesStashT1 := 1
    Global YesStashT2 := 1
    Global YesStashT3 := 1
    Global YesStashT4 := 1
    Global YesStashCraftingNormal := 1
    Global YesStashCraftingMagic := 1
    Global YesStashCraftingRare := 1
    Global YesStashCraftingIlvl := 0
    Global YesStashCraftingIlvlMin := 76
  ; Skip Maps after column #
    Global YesSkipMaps := 0
    Global YesSkipMaps_eval := ">="
    Global YesSkipMaps_normal := 0
    Global YesSkipMaps_magic := 1
    Global YesSkipMaps_rare := 1
    Global YesSkipMaps_unique := 1
    Global YesSkipMaps_tier := 2
  ; Controller
    Global YesController := 1
    global checkvar:=0
    Global YesMovementKeys := 0
    Global YesTriggerUtilityKey := 0
    Global TriggerUtilityKey := 1
    Global JoystickNumber := 0
    Global JoyThreshold := 6
    global JoyThresholdUpper := 50 + JoyThreshold
    global JoyThresholdLower := 50 - JoyThreshold
    global InvertYAxis := false
    global JoyMultiplier := 0.30
    global JoyMultiplier2 := 8
    global hotkeyControllerButtonA,hotkeyControllerButtonB,hotkeyControllerButtonX,hotkeyControllerButtonY,hotkeyControllerButtonLB,hotkeyControllerButtonRB,hotkeyControllerButtonBACK,hotkeyControllerButtonSTART,hotkeyControllerButtonL3,hotkeyControllerButtonR3,hotkeyControllerJoystickRight
    global YesTriggerUtilityJoystickKey := 1
    global YesTriggerJoystickRightKey := 1
  ; ~ Hotkeys
  ; Legend:    ! = Alt    ^ = Ctrl    + = Shift 
    global hotkeyOptions:="!F10"
    global hotkeyAutoFlask:="!F11"
    global hotkeyAutoQuit:="!F12"
    global hotkeyLogout:="F12"
    global hotkeyAutoQuicksilver:="!MButton"
    global hotkeyPopFlasks:="CapsLock"
    global hotkeyItemSort:="F6"
    global hotkeyItemInfo:="F5"
    global hotkeyChaosRecipe:="F8"
    global hotkeyLootScan:="f"
    global hotkeyDetonateMines:="d"
    global hotkeyPauseMines:="d"
    global hotkeyQuickPortal:="!q"
    global hotkeyGemSwap:="!e"
    global hotkeyStartCraft:="F7"
    global hotkeyCraftBasic:="F9"
    global hotkeyGrabCurrency:="!a"
    global hotkeyGetMouseCoords:="!o"
    global hotkeyCloseAllUI:="Space"
    global hotkeyInventory:="c"
    global hotkeyWeaponSwapKey:="x"
    global hotkeyMainAttack:="RButton"
    global hotkeySecondaryAttack:="w"
    global hotkeyDetonate:="d"
    global hotkeyUp := "W"
    global hotkeyDown := "S"
    global hotkeyLeft := "A"
    global hotkeyRight := "D"
    global hotkeyCastOnDetonate := "Q"
    Global hotkeyTriggerMovement := "LButton"

  ; Coordinates
    global PortalScrollX:=1825
    global PortalScrollY:=825
    global WisdomScrollX:=1875
    global WisdomScrollY:=825
    global StockPortal:=0
    global StockWisdom:=0

  ; Inventory Colors
    global varEmptyInvSlotColor := [0x000100, 0x020402, 0x000000, 0x020302, 0x010101, 0x010201, 0x060906, 0x050905] ;Default values from sauron-dev
  ; Failsafe Colors
    global varOnMenu:=0xD6B97B
    global varOnChar:=0x6B5543
    global varOnChat:=0x88623B
    global varOnInventory:=0xDCC289
    global varOnStash:=0xECDBA6
    global varOnVendor:=0xCEB178
    global varOnDiv:=0xF6E2C5
    global varOnLeft:=0xB58C4D
    global varOnDelveChart:=0xB58C4D
    global varOnMetamorph:=0xE06718
    global varOnLocker:=0xE97724
    Global varOnDetonate := 0x5D4661

  ; Grab Currency
    global GrabCurrencyPosX:=1877
    global GrabCurrencyPosY:=772

  ; First Gem/Item Swap
    global CurrentGemX:=1483
    global CurrentGemY:=372
    global AlternateGemX:=1379 
    global AlternateGemY:=171
    global AlternateGemOnSecondarySlot:=0
    global GemItemToogle:=0

  ; Second Gem/Item Swap
    global CurrentGem2X:=0
    global CurrentGem2Y:=0
    global AlternateGem2X:=0
    global AlternateGem2Y:=0
    global AlternateGem2OnSecondarySlot:=0
    global GemItemToogle2:=0
    
  ; Chat Hotkeys, and stash hotkeys
    Global CharName := "ReplaceWithCharName"
    Global RecipientName := "NothingYet"
    Global fn1, fn2, fn3
    Global 1Prefix1, 1Prefix2, 2Prefix1, 2Prefix2, stashPrefix1, stashPrefix2, stashReset
    Global 1Suffix1,1Suffix2,1Suffix3,1Suffix4,1Suffix5,1Suffix6,1Suffix7,1Suffix8,1Suffix9
    Global 1Suffix1Text,1Suffix2Text,1Suffix3Text,1Suffix4Text,1Suffix5Text,1Suffix6Text,1Suffix7Text,1Suffix8Text,1Suffix9Text
    Global 2Suffix1,2Suffix2,2Suffix3,2Suffix4,2Suffix5,2Suffix6,2Suffix7,2Suffix8,2Suffix9
    Global 2Suffix1Text,2Suffix2Text,2Suffix3Text,2Suffix4Text,2Suffix5Text,2Suffix6Text,2Suffix7Text,2Suffix8Text,2Suffix9Text
    Global stashSuffix1,stashSuffix2,stashSuffix3,stashSuffix4,stashSuffix5,stashSuffix6,stashSuffix7,stashSuffix8,stashSuffix9
    Global stashSuffixTab1,stashSuffixTab2,stashSuffixTab3,stashSuffixTab4,stashSuffixTab5,stashSuffixTab6,stashSuffixTab7,stashSuffixTab8,stashSuffixTab9
  
  ; Map Crafting Settings
    Global StartMapTier1,StartMapTier2,StartMapTier3,StartMapTier4,EndMapTier1,EndMapTier2,EndMapTier3
    , CraftingMapMethod1,CraftingMapMethod2,CraftingMapMethod3
    , ElementalReflect,PhysicalReflect,NoLeech,NoRegen,AvoidAilments,AvoidPBB,MinusMPR,LRRLES,MFAProjectiles,MDExtraPhysicalDamage,MICSC,MSCAT
    , MMapItemQuantity,MMapItemRarity,MMapMonsterPackSize,EnableMQQForMagicMap
    
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
    Global ItemInfoStatText := "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    global graphWidth := 219
    global graphHeight := 221
    Global ForceMatch6Link := False
    Global ForceMatchGem20 := False
  ; Ingame Overlay Transparency
    Global YesInGameOverlay := 0

; ReadFromFile()
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  readFromFile()
; Check for Update on Start
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript")
  checkUpdate()
; Ensure files are present
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IfNotExist, %A_ScriptDir%\data\WR.ico
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/WR.ico, %A_ScriptDir%\data\WR.ico
    if ErrorLevel{
       Log("data","uhoh", "WR.ico")
      MsgBox, Error ED02 : There was a problem downloading WR.ico
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "WR.ico")
      needReload := True
    }
  }
  IfNotExist, %A_ScriptDir%\data\InventorySlots.png
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/InventorySlots.png, %A_ScriptDir%\data\InventorySlots.png
    if ErrorLevel{
       Log("data","uhoh", "InventorySlots.png")
      MsgBox, Error ED02 : There was a problem downloading InventorySlots.png
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "InventorySlots.png")
    }
  }
  IfNotExist, %A_ScriptDir%\data\boot_enchantment_mods.txt
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/boot_enchantment_mods.txt, %A_ScriptDir%\data\boot_enchantment_mods.txt
    if ErrorLevel{
       Log("data","uhoh", "boot_enchantment_mods")
      MsgBox, Error ED02 : There was a problem downloading boot_enchantment_mods.txt
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "boot_enchantment_mods")
    }
  }
  Loop, Read, %A_ScriptDir%\data\boot_enchantment_mods.txt
  {
    If (StrLen(Trim(A_LoopReadLine)) > 0) {
      Enchantment.push(A_LoopReadLine)
    }
  }
  IfNotExist, %A_ScriptDir%\data\helmet_enchantment_mods.txt
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/helmet_enchantment_mods.txt, %A_ScriptDir%\data\helmet_enchantment_mods.txt
    if ErrorLevel {
       Log("data","uhoh", "helmet_enchantment_mods")
      MsgBox, Error ED02 : There was a problem downloading helmet_enchantment_mods.txt
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "helmet_enchantment_mods")
    }
  }
  Loop, Read, %A_ScriptDir%\data\helmet_enchantment_mods.txt
  {
    If (StrLen(Trim(A_LoopReadLine)) > 0) {
      Enchantment.push(A_LoopReadLine)
    }
  }
  IfNotExist, %A_ScriptDir%\data\glove_enchantment_mods.txt
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/glove_enchantment_mods.txt, %A_ScriptDir%\data\glove_enchantment_mods.txt
    if ErrorLevel {
       Log("data","uhoh", "glove_enchantment_mods")
      MsgBox, Error ED02 : There was a problem downloading glove_enchantment_mods.txt
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "glove_enchantment_mods")
    }
  }
  Loop, Read, %A_ScriptDir%\data\glove_enchantment_mods.txt
  {
    If (StrLen(Trim(A_LoopReadLine)) > 0) {
      Enchantment.push(A_LoopReadLine)
    }
  }
  IfNotExist, %A_ScriptDir%\data\item_corrupted_mods.txt
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/item_corrupted_mods.txt, %A_ScriptDir%\data\item_corrupted_mods.txt
    if ErrorLevel {
       Log("data","uhoh", "item_corrupted_mods")
      MsgBox, Error ED02 : There was a problem downloading item_corrupted_mods.txt
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "item_corrupted_mods")
    }
  }
  Loop, read, %A_ScriptDir%\data\item_corrupted_mods.txt
  {
    If (StrLen(Trim(A_LoopReadLine)) > 0) {
      Corruption.push(A_LoopReadLine)
    }
  }
  IfNotExist, %A_ScriptDir%\data\Controller.png
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Controller.png, %A_ScriptDir%\data\Controller.png
    if ErrorLevel {
       Log("data","uhoh", "Controller.png")
      MsgBox, Error ED02 : There was a problem downloading Controller.png
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "Controller.png")
    }
  }
  IfNotExist, %A_ScriptDir%\data\LootFilter.ahk
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/LootFilter.ahk, %A_ScriptDir%\data\LootFilter.ahk
    if ErrorLevel {
       Log("data","uhoh", "LootFilter.ahk")
      MsgBox, Error ED02 : There was a problem downloading LootFilter.ahk
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "LootFilter.ahk")
    }
  }
  IfNotExist, %A_ScriptDir%\data\WR_Prop.json
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/WR_Prop.json, %A_ScriptDir%\data\WR_Prop.json
    if ErrorLevel {
       Log("data","uhoh", "WR_Prop.json")
      MsgBox, Error ED02 : There was a problem downloading WR_Prop.json
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "WR_Prop.json")
    }
  }
  IfNotExist, %A_ScriptDir%\data\WR_Pseudo.json
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/WR_Pseudo.json, %A_ScriptDir%\data\WR_Pseudo.json
    if ErrorLevel {
       Log("data","uhoh", "WR_Pseudo.json")
      MsgBox, Error ED02 : There was a problem downloading WR_Pseudo.json
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "WR_Pseudo.json")
    }
  }
  IfNotExist, %A_ScriptDir%\data\WR_Affix.json
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/WR_Affix.json, %A_ScriptDir%\data\WR_Affix.json
    if ErrorLevel {
       Log("data","uhoh", "WR_Affix.json")
      MsgBox, Error ED02 : There was a problem downloading WR_Affix.json
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "WR_Affix.json")
    }
  }
  IfNotExist, %A_ScriptDir%\data\Bases.json
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/base_items.json, %A_ScriptDir%\data\Bases.json
    if ErrorLevel {
       Log("data","uhoh", "Bases.json")
      MsgBox, Error ED02 : There was a problem downloading Bases.json from RePoE
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "Bases.json")
      FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
      Holder := []
      Bases := JSON.Load(JSONtext)
      For k, v in Bases
      {
        temp := {"name":v["name"]
          ,"item_class":v["item_class"]
          ,"domain":v["domain"]
          ,"tags":v["tags"]
          ,"inventory_width":v["inventory_width"]
          ,"inventory_height":v["inventory_height"]
          ,"drop_level":v["drop_level"]}
        Holder.Push(temp)
      }
      Bases := Holder
      JSONtext := JSON.Dump(Bases,,2)
      FileDelete, %A_ScriptDir%\data\Bases.json
      FileAppend, %JSONtext%, %A_ScriptDir%\data\Bases.json
    }
  }
  Else
  {
    FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
    Bases := JSON.Load(JSONtext)
  }
  IfNotExist, %A_ScriptDir%\data\Quest.json
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Quest.json, %A_ScriptDir%\data\Quest.json
    if ErrorLevel {
       Log("data","uhoh", "Quest.json")
      MsgBox, Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub
    }
    Else if (ErrorLevel=0){
       Log("data","pass", "Quest.json")
      FileRead, JSONtext, %A_ScriptDir%\data\Quest.json
      QuestItems := JSON.Load(JSONtext)
    }
  }
  Else
  {
    FileRead, JSONtext, %A_ScriptDir%\data\Quest.json
    QuestItems := JSON.Load(JSONtext)
  }
  If needReload
    Reload

; MAIN Gui Section
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Critical
  Gui Add, Checkbox,   vDebugMessages Checked%DebugMessages%  gUpdateDebug     x610   y5     w13 h13
  Gui Add, Text,                     x515  y5,         Debug Messages:
  Gui Add, Checkbox,   vYesTimeMS Checked%YesTimeMS%  gUpdateDebug     x490   y5     w13 h13
  Gui Add, Text,         vYesTimeMS_t            x455  y5,         Logic:
  Gui Add, Checkbox,   vYesLocation Checked%YesLocation%  gUpdateDebug     x435   y5     w13 h13
  Gui Add, Text,         vYesLocation_t            x385  y5,         Location:

  Gui, Add, StatusBar, vWR_Statusbar hwndWR_hStatusbar, %WR_Statusbar%
  SB_SetParts(220,220)
  SB_SetText("Logic Status", 1)
  SB_SetText("Location Status", 2)
  SB_SetText("Percentage not updated", 3)

  Gui Add, Tab2, vMainGuiTabs xm y3 w655 h505 -wrap , Main|Configuration|Hotkeys
  ;#######################################################################################################Flasks and Utility Tab
  Gui, Tab, Main
    Gui, Font,
    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,         Section    w265 h77        xp+5   y+2,         Per Character Settings
    Gui, Font,
    Gui, Add, Button, gperCharMenu w255 xs+5 ys+20, Configure Character Options
    l := [], s := ""
    Loop, Files, %A_ScriptDir%\save\profiles\perChar\*.json
      l.Push(StrReplace(A_LoopFileName,".json",""))
    For k, v in l
      s .=(k=1?"":"|") v
    Gui, Add, ComboBox,  vProfileMenuperChar xs+6 y+5 w117, %s%
    Gui, Add, Button, gProfile vMainMenu_perChar_Save x+1 yp hp w40 , Save
    Gui, Add, Button, gProfile vMainMenu_perChar_Load x+1 yp hp w40 , Load
    Gui, Add, Button, gProfile vMainMenu_perChar_Remove x+1 yp hp w50 , Remove


    ; Flask
    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,        Section    w265 h77 xs y+14  , Flask Settings
    Gui, Font
    Loop 5
    Gui, Add, Button, % "gFlaskMenu W46 -wrap " ((A_Index==1||A_Index==6)?"xs+6 yp+20":"x+5 yp") , Flask %A_Index%
    l := [], s := ""
    Loop, Files, %A_ScriptDir%\save\profiles\Flask\*.json
      l.Push(StrReplace(A_LoopFileName,".json",""))
    For k, v in l
      s .=(k=1?"":"|") v
    Gui, Add, ComboBox,  vProfileMenuFlask xs+6 y+5 w117, %s%
    Gui, Add, Button, gProfile vMainMenu_Flask_Save x+1 yp hp w40 , Save
    Gui, Add, Button, gProfile vMainMenu_Flask_Load x+1 yp hp w40 , Load
    Gui, Add, Button, gProfile vMainMenu_Flask_Remove x+1 yp hp w50 , Remove

    ; Utility
    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,        Section    w265 h105 xs y+14  , Utility Settings
    Gui, Font
    Loop 10
    Gui, Add, Button, % "gUtilityMenu W46 -wrap " (A_Index==1?"xs+6 yp+20":A_Index==6?"xs+6 y+5":"x+5 yp") , Utility %A_Index%
    
    l := [], s := ""
    Loop, Files, %A_ScriptDir%\save\profiles\Utility\*.json
      l.Push(StrReplace(A_LoopFileName,".json",""))
    For k, v in l
      s .=(k=1?"":"|") v
    Gui, Add, ComboBox,  vProfileMenuUtility xs+6 y+5 w117, %s%
    Gui, Add, Button, gProfile vMainMenu_Utility_Save x+1 yp hp w40 , Save
    Gui, Add, Button, gProfile vMainMenu_Utility_Load x+1 yp hp w40 , Load
    Gui, Add, Button, gProfile vMainMenu_Utility_Remove x+1 yp hp w50 , Remove

    ;Middle Vertical Lines
    Gui, Add, Text,                   xm+279   y23    w1  h483 0x7
    Gui, Add, Text,                   x+1   y23    w1  h483 0x7

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,  Center   Section  w350 h230        x+15   ym+20 ,    Game Logic States
    Gui, Font,
    Gui, Add, Text, Section xs+20 ys+20 w150 Center h20 0x200 vMainMenuOnChar hwndMainMenuIDOnChar, % "Character Active"
    CtlColors.Attach(MainMenuIDOnChar, "Lime", "")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnOHB hwndMainMenuIDOnOHB, % "Overhead Health Bar"
    CtlColors.Attach(MainMenuIDOnOHB, "Lime", "")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnChat hwndMainMenuIDOnChat, % "Chat Open"
    CtlColors.Attach(MainMenuIDOnChat, "", "Green")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnInventory hwndMainMenuIDOnInventory, % "Inventory Open"
    CtlColors.Attach(MainMenuIDOnInventory, "", "Green")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnDiv hwndMainMenuIDOnDiv, % "Div Trade Open"
    CtlColors.Attach(MainMenuIDOnDiv, "", "Green")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnStash hwndMainMenuIDOnStash, % "Stash Open"
    CtlColors.Attach(MainMenuIDOnStash, "", "Green")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnMenu hwndMainMenuIDOnMenu, % "Talent Menu Open"
    CtlColors.Attach(MainMenuIDOnMenu, "", "Green")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnVendor hwndMainMenuIDOnVendor, % "Vendor Trade Open"
    CtlColors.Attach(MainMenuIDOnVendor, "", "Green")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnDelveChart hwndMainMenuIDOnDelveChart, % "Delve Chart Open"
    CtlColors.Attach(MainMenuIDOnDelveChart, "", "Green")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnLeft hwndMainMenuIDOnLeft, % "Left Panel Open"
    CtlColors.Attach(MainMenuIDOnLeft, "", "Green")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnMetamorph hwndMainMenuIDOnMetamorph, % "Map Metamorph Open"
    CtlColors.Attach(MainMenuIDOnMetamorph, "", "Green")
    Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnDetonate hwndMainMenuIDOnDetonate, % "Detonate Shown"
    CtlColors.Attach(MainMenuIDOnDetonate, "", "Green")
    Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnLocker hwndMainMenuIDOnLocker, % "League Stash Open"
    CtlColors.Attach(MainMenuIDOnLocker, "", "Green")

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,      Center       section        xs-20   y+20 w350 h90 ,         Gamestate Calibration:
    Gui, Font, s8
    Gui, Add, Button, ghelpCalibration   xp+250 ys-4    h20, %  "? help"
    Gui, Add, Button, gStartCalibrationWizard vStartCalibrationWizardBtn  xs+10  ys+20 w105 h25,   Run Wizard
    Gui, Add, Button, gShowSampleInd vShowSampleIndBtn    x+8 yp     wp,   Individual Sample
    Gui, Add, Button, gWR_Update vWR_Btn_Globe         x+8 yp       wp,   Adjust Globes
    Gui, Add, Button, gWR_Update vWR_Btn_Locations         xs+10  y+10      wp,   Adjust Locations
    Gui, Add, Button, gCheckPixelGrid x+8 yp wp , Inventory Grid
    Gui, Font

    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gLaunchSite     x+5           h23,   Website
    Gui, Add, Button,      gft_Start     x+5           h23,   Grab Icon

  ;#######################################################################################################Configuration Tab
  Gui, Tab, Configuration
    Gui, Add, Text,                   x279   y23    w1  h483 0x7
    Gui, Add, Text,                   x+1   y23    w1  h483 0x7

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,           Section          x22   y30,         Automation Settings:
    Gui, Add, Button, ghelpAutomationSetting   x+10 ys-4    h20, %  "? help"
    Gui, add, button, gWR_Update vWR_Btn_Strings     xs ys+18 w110, Sample Strings
    Gui, add, Button, gLootColorsMenu  vLootVacuumSettings x+8 yp w110, Loot Vacuum
    Gui, Font, 

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,           Section          xs   y+10,         Item and Inventory Settings:
    Gui, add, button, gLaunchLootFilter vWR_Btn_CLF  xs y+10 w110, Custom Loot Filter
    Gui, add, button, gWR_Update vWR_Btn_Inventory   x+10 yp w110, Inventory Sorting
    Gui, add, button, gWR_Update vWR_Btn_Crafting  xs y+10 w110, Crafting
    Gui, Font, 

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,           Section          xs   y+10,         Interface Options:
    Gui, Font, 

    Gui Add, Checkbox, gUpdateExtra  vYesOHB Checked%YesOHB%                                , Pause script when OHB missing?
    Gui Add, Checkbox, gUpdateExtra  vShowOnStart Checked%ShowOnStart%                      , Show GUI on startup?
    Gui Add, CheckBox, gSaveGeneral vYesInGameOverlay Checked%YesInGameOverlay%                    , Show In-Game Overlay?
    Gui Add, Checkbox, gUpdateExtra  vYesPersistantToggle Checked%YesPersistantToggle%      xs        , Persistant Auto-Toggles?
    Gui Add, Checkbox, gUpdateExtra  vYesGuiLastPosition Checked%YesGuiLastPosition%      xs        , Remember Last GUI Position?

    Gui,Font, Bold s9 cBlack, Arial
    Gui,Add,GroupBox,Section x295 ym+20  w350 h90              ,Update Control
    Gui,Font,Norm

    Gui Add, DropDownList, gUpdateExtra  vBranchName     w90   xs+5 yp+15           , master|Alpha
    GuiControl, ChooseString, BranchName                                                  , %BranchName%
    Gui, Add, Text,       x+8 yp+3                                                        , Update Branch
    Gui Add, DropDownList, gUpdateExtra  vScriptUpdateTimeType   xs+5 y+10  w90                  , Off|days|hours|minutes
    GuiControl, ChooseString, ScriptUpdateTimeType                                        , %ScriptUpdateTimeType%
    Gui Add, Edit, gUpdateExtra  vScriptUpdateTimeInterval  x+5   w40                     , %ScriptUpdateTimeInterval%
    Gui, Add, Text,       x+8 yp+3                                   , Auto-check Update
    Gui Add, Checkbox, gUpdateExtra  vAutoUpdateOff Checked%AutoUpdateOff%     xs+5 y+10              , Turn off Auto-Update?

    Gui,Font, Bold s9 cBlack, Arial
    Gui,Add,GroupBox,Section xs y+10  w350 h140                                                     , Game Setup
    Gui, Add, Text,          xs+5 yp+20                                                             , Aspect Ratio:
    Gui,Font,Norm

    Gui Add, DropDownList, gUpdateResolutionScale  vResolutionScale     w160   x+8 yp-3             , Standard|Classic|Cinematic|Cinematic(43:18)|UltraWide|WXGA(16:10)
    GuiControl, ChooseString, ResolutionScale                                                       , %ResolutionScale%

    Gui,Font, Bold s9 cBlack, Arial
    Gui, Add, Text,          xs+5 y+10                                                             , POE LogFile:
    Gui,Font,Norm

    Gui, Add, Edit,       vClientLog         x+5 yp-3  w170  h23                                   ,   %ClientLog%
    Gui, add, Button, gSelectClientLog hp yp x+5                                                 , Locate

    IfNotExist, %A_ScriptDir%\data\leagues.json
    {
      UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
    }
    FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
    LeagueIndex := JSON.Load(JSONtext)
    textList= 
    For K, V in LeagueIndex
      textList .= (!textList ? "" : "|") LeagueIndex[K]["id"]
    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, Text, xs+5 y+10, League:
    Gui, Font,Norm
    Gui, Add, DropDownList, vselectedLeague x+5 yp-3 w150, %textList%
    GuiControl, ChooseString, selectedLeague, %selectedLeague%
    Gui, Add, Button, gUpdateLeagues vUpdateLeaguesBtn x+5 yp-1 , Refresh

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, Text, xs+5 y+10 , PoESessionID
    Gui, Font,Norm
    Gui, Add, Edit, password vPoESessionID  x+5 yp-3  w240, %PoESessionID%

    Gui, Font, Bold s9 cBlack, Arial
    Gui,Add,GroupBox,Section xs y+10  w350 h55                                                     , Script Latency
    Gui, Font,Norm
    Gui, Add, DropDownList, gUpdateExtra vLatency w40 xs+5 yp+20                                       ,  1|1.1|1.2|1.3|1.4|1.5|1.6|1.7|1.8|1.9|2|2.5|3
    GuiControl, ChooseString, Latency, %Latency%
    Gui, Add, Text,                     x+5 yp+3 hp-3              , Global Adjust
    Gui, Add, DropDownList, gUpdateExtra vClickLatency w35 x+10 yp-3,  -2|-1|0|1|2|3|4
    GuiControl, ChooseString, ClickLatency, %ClickLatency%
    Gui, Add, Text,                     x+5 yp+3  hp-3            , Click Adjust
    Gui, Add, DropDownList, gUpdateExtra vClipLatency w35 x+10 yp-3,  -2|-1|0|1|2|3|4
    GuiControl, ChooseString, ClipLatency, %ClipLatency%
    Gui, Add, Text,                     x+5 yp+3  hp-3            , Clip Adjust

    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gLaunchSite     x+5           h23,   Website

  Gui, Tab, Hotkeys
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,   Section                  xm+5   ym+25,         Script Keybinds:
    Gui, Font
    Gui Add, Text,                     xs+65   y+8,         Open this GUI
    Gui Add, Text,                     xs+65   y+10,         Toggle Auto-Flask
    Gui Add, Text,                     xs+65   y+10,         Toggle Auto-Quit
    Gui Add, Text,                     xs+65   y+10,         Toggle Auto-QSilver
    Gui Add, Text,                     xs+65   y+10,         Movement Trigger
    Gui Add, Text,                     xs+65   y+10,         Main Attack
    Gui Add, Text,                     xs+65   y+10,         Secondary Attack
    Gui Add, Text,                     xs+65   y+10,         Logout
    Gui Add, Text,                     xs+65   y+10,         Pop Flasks
    Gui Add, Text,                     xs+65   y+10,         Quick-Portal
    Gui Add, Text,                     xs+65   y+10,         Gem-Swap
    Gui Add, Text,                     xs+65   y+10,         Grab Currency
    Gui Add, Text,                     xs+65   y+10,         Coord/Pixel
    Gui Add, Text,                     xs+65   y+10,         Item Info
    Gui Add, Text,                     xs+65   y+10,         Inventory Sort
    Gui Add, Text,                     xs+65   y+10,         Bulk Craft Maps
    Gui Add, Text,                     xs+65   y+10,         Chaos Recipe
    Gui Add, Text,                     xs+65   y+10,         Basic Crafting

    Gui,Add,Edit,  xs ys+20        w60 h19   vhotkeyOptions           ,%hotkeyOptions%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoFlask         ,%hotkeyAutoFlask%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoQuit          ,%hotkeyAutoQuit%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoQuicksilver   ,%hotkeyAutoQuicksilver%
    Gui Add, Edit,           y+4   w60 h19   vhotkeyTriggerMovement   ,%hotkeyTriggerMovement%
    Gui Add, Edit,           y+4   w60 h19   vhotkeyMainAttack        ,%hotkeyMainAttack%
    Gui Add, Edit,           y+4   w60 h19   vhotkeySecondaryAttack   ,%hotkeySecondaryAttack%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyLogout            ,%hotkeyLogout%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyPopFlasks         ,%hotkeyPopFlasks%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyQuickPortal       ,%hotkeyQuickPortal%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGemSwap           ,%hotkeyGemSwap%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGrabCurrency      ,%hotkeyGrabCurrency%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGetMouseCoords    ,%hotkeyGetMouseCoords%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyItemInfo          ,%hotkeyItemInfo%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyItemSort          ,%hotkeyItemSort%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyStartCraft        ,%hotkeyStartCraft%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyChaosRecipe       ,%hotkeyChaosRecipe%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyCraftBasic        ,%hotkeyCraftBasic%

    Gui, Font, Bold s9 cBlack, Arial
    Gui, add, button, gWR_Update vWR_Btn_Controller  xs y+15 w110, Controller Keys

    Gui Add, Text,                     xs+175   ys,         Ingame Assigned Keys:
    Gui, Font
    Gui Add, Text,                     xs+235   y+10,         Close UI
    Gui Add, Text,                          y+10,         Inventory
    Gui Add, Text,                          y+10,         W-Swap
    Gui Add, Text,                          y+10,         Item Pickup
    Gui Add, Text,                          y+10,         Detonate Mines

    Gui,Add,Edit,          xs+170 ys+20  w60 h19   vhotkeyCloseAllUI    ,%hotkeyCloseAllUI%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyInventory      ,%hotkeyInventory%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyWeaponSwapKey    ,%hotkeyWeaponSwapKey%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyLootScan        ,%hotkeyLootScan%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyDetonateMines    ,%hotkeyDetonateMines%

    Gui Add, Checkbox, gUpdateExtra  vPopFlaskRespectCD Checked%PopFlaskRespectCD%                 xp y+6 , Pop Flasks Respect CD?
    Gui Add, Checkbox, gUpdateExtra  vYesClickPortal Checked%YesClickPortal%                          y+8 , Click portal after opening?

    ;~ =========================================================================================== Subgroup: Hints
    Gui,Font, Bold s9 cBlack, Arial
    Gui,Add,GroupBox,Section xp  y+25  w120 h80              ,Hotkey Modifiers
    Gui, Add, Button,      gLaunchHelp vLaunchHelp     center wp,   Show Key List
    Gui,Font,Norm
    Gui,Font,s8,Arial
    Gui,Add,Text,          xs+15 ys+17          ,!%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%ALT
    Gui,Add,Text,              y+5          ,^%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%CTRL
    Gui,Add,Text,              y+5          ,+%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%SHIFT


    Gui, Add, Checkbox, gUpdateExtra  vEnableChatHotkeys Checked%EnableChatHotkeys%   xs+200 ym+25                    , Enable chat Hotkeys?
    Gui,Font, Bold s9 cBlack, Arial
    Gui, add, button, gWR_Update vWR_Btn_Chat        w160, Configure Chat Hotkeys
    Gui,Font,Norm

    Gui, Add, Checkbox, xs+200 y+15  vYesStashKeys Checked%YesStashKeys%                    , Enable stash hotkeys?

    Gui, Font,s9 cBlack Bold Underline, Arial
    Gui, Add,GroupBox,Section xp-5 yp+20 w100 h85                      ,Modifier
    Gui, Font,
    Gui, Font,s9,Arial
    Gui, Add, Edit, xs+4 ys+20 w90 h23 vstashPrefix1, %stashPrefix1%
    Gui, Add, Edit, y+8    w90 h23 vstashPrefix2, %stashPrefix2%

    Gui, Font,s9 cBlack Bold Underline, Arial
    Gui, Add,GroupBox, xp-5 y+20 w100 h55                      ,Reset Tab
    Gui, Font,
    Gui, Font,s9,Arial
    Gui, Add, Edit, xp+4 yp+20 w90 h23 vstashReset, %stashReset%

    Gui, Font,s9 cBlack Bold Underline, Arial
    Gui, Add,GroupBox,Section x+10 ys w100 h275                      ,Keys
    Gui, Font,
    Gui, Font,s9,Arial
    Gui, Add, Edit, ys+20 xs+4 w90 h23 vstashSuffix1, %stashSuffix1%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix2, %stashSuffix2%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix3, %stashSuffix3%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix4, %stashSuffix4%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix5, %stashSuffix5%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix6, %stashSuffix6%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix7, %stashSuffix7%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix8, %stashSuffix8%
    Gui, Add, Edit, y+5    w90 h23 vstashSuffix9, %stashSuffix9%

    Gui, Font,s9 cBlack Bold Underline, Arial
    Gui, Add,GroupBox,Section x+4 ys w50 h275                      ,Tab
    Gui, Font,
    Gui, Font,s9,Arial
    Gui, Add, Edit, Number xs+4 ys+20 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab1 , %stashSuffixTab1%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab2 , %stashSuffixTab2%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab3 , %stashSuffixTab3%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab4 , %stashSuffixTab4%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab5 , %stashSuffixTab5%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab6 , %stashSuffixTab6%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab7 , %stashSuffixTab7%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab8 , %stashSuffixTab8%
    Gui, Add, Edit, Number y+5 w40
    Gui, Add, UpDown, Range1-64  x+0 hp vstashSuffixTab9 , %stashSuffixTab9%
    



    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gLaunchSite     x+5           h23,   Website

    ForceUpdate := Func("checkUpdate").Bind(True)

    Gui, +LastFound +AlwaysOnTop
    Menu, Tray, Tip,         WingmanReloaded Dev Ver%VersionNumber%
    Menu, Tray, NoStandard
    Menu, Tray, Add,         WingmanReloaded, optionsCommand
    Menu, Tray, Default,       WingmanReloaded
    Menu, Tray, Add
    Menu, Tray, Add,         Project Site, LaunchSite
    Menu, Tray, Add
    Menu, Tray, Add,         Make a Donation, LaunchDonate
    Menu, Tray, Add
    Menu, Tray, Add,         Run Calibration Wizard, StartCalibrationWizard
    Menu, Tray, Add
    Menu, Tray, add,         Print Object, PromptForObject
    Menu, Tray, add
    Menu, Tray, Add,         Custom Loot Filter, LaunchLootFilter
    Menu, Tray, Add
    Menu, Tray, Add,         Open FindText interface, ft_Start
    Menu, Tray, Add
    Menu, Tray, add,         Window Spy, WINSPY
    Menu, Tray, Add
    Menu, Tray, add,         Force Update, %ForceUpdate%
    Menu, Tray, add
    Menu, Tray, add,         Reload This Script, RELOAD  
    Menu, Tray, add
    Menu, Tray, add,         Exit, QuitNow ; added exit script option

    Gui, ItemInfo: +AlwaysOnTop +LabelItemInfo -MinimizeBox
    Gui, ItemInfo: Margin, 10, 10
    Gui, ItemInfo: Font, Bold s8 c4D7186, Verdana
    Gui, ItemInfo: Add, GroupBox, vGroupBox1 xm+1 y+1  h251 w554 , %GroupBox1%
    Gui, ItemInfo: Add, Text, xp+3 yp+20 Section h1 w1 , ""
    Loop, % 21 + ( Y := 15 ) - 15 ; Loop 21 times 
    {
      addY := y + 10 
      Gui, ItemInfo: Add, Text, vPercentText1G%A_Index% xs+10 y%addY% w70 h10 0x200 Right, % Abs( 125 - ( Y += 10 ) ) "`%"
    }

    Gui, ItemInfo: Add, Text, % "x+5 ys w" (graphWidth + 2) " h" (graphHeight + 2) " 0x1000" ; SS_SUNKEN := 0x1000
    Gui, ItemInfo: Add, Text, % "xp+1 yp+1 w" graphWidth " h" graphHeight " hwndhGraph1", pGraph1
    Gui, ItemInfo: Add, Text, Section x+8 vPComment1, %PComment1%
    Gui, ItemInfo: Add, Text, x+8 vPData1, %PData1%
    Gui, ItemInfo: Add, Text, xs vPComment2, %PComment2%
    Gui, ItemInfo: Add, Text, x+8 vPData2, %PData2%
    Gui, ItemInfo: Add, Text, xs vPComment3, %PComment3%
    Gui, ItemInfo: Add, Text, x+8 vPData3, %PData3%
    Gui, ItemInfo: Add, Text, xs vPComment4, %PComment4%
    Gui, ItemInfo: Add, Text, x+8 vPData4, %PData4%
    Gui, ItemInfo: Add, Text, xs vPComment5, %PComment5%
    Gui, ItemInfo: Add, Text, x+8 vPData5, %PData5%
    Gui, ItemInfo: Add, Text, xs vPComment6, %PComment6%
    Gui, ItemInfo: Add, Text, x+8 vPData6, %PData6%
    Gui, ItemInfo: Add, Text, xs vPComment7, %PComment7%
    Gui, ItemInfo: Add, Text, x+8 vPData7, %PData7%
    Gui, ItemInfo: Add, Text, xs vPComment8, %PComment8%
    Gui, ItemInfo: Add, Text, x+8 vPData8, %PData8%
    Gui, ItemInfo: Add, Text, xs vPComment9, %PComment9%
    Gui, ItemInfo: Add, Text, x+8 vPData9, %PData9%
    Gui, ItemInfo: Add, Text, xs vPComment10, %PComment10%
    Gui, ItemInfo: Add, Text, x+8 vPData10, %PData10%

    Gui, ItemInfo: Add, GroupBox, vGroupBox2 x+15 ys-21  h251 w554 , %GroupBox2%
    Gui, ItemInfo: Add, Text, xp+3 ys Section h1 w1 , ""
    Loop, % 21 + ( Y := 15 ) - 15 ; Loop 21 times 
    {
      addY := y + 10 
      Gui, ItemInfo: Add, Text, vPercentText2G%A_Index% xs+10 y%addY% w70 h10 0x200 Right, % Abs( 125 - ( Y += 10 ) ) "`%"
    }
    Gui, ItemInfo: Add, Text, % "x+5 ys w" (graphWidth + 2) " h" (graphHeight + 2) " 0x1000" ; SS_SUNKEN := 0x1000
    Gui, ItemInfo: Add, Text, % "xp+1 yp+1 w" graphWidth " h" graphHeight " hwndhGraph2", pGraph2
    Gui, ItemInfo: Add, Text, Section x+8 vSComment1, %SComment1%
    Gui, ItemInfo: Add, Text, x+8 vSData1, %SData1%
    Gui, ItemInfo: Add, Text, xs vSComment2, %SComment2%
    Gui, ItemInfo: Add, Text, x+8 vSData2, %SData2%
    Gui, ItemInfo: Add, Text, xs vSComment3, %SComment3%
    Gui, ItemInfo: Add, Text, x+8 vSData3, %SData3%
    Gui, ItemInfo: Add, Text, xs vSComment4, %SComment4%
    Gui, ItemInfo: Add, Text, x+8 vSData4, %SData4%
    Gui, ItemInfo: Add, Text, xs vSComment5, %SComment5%
    Gui, ItemInfo: Add, Text, x+8 vSData5, %SData5%
    Gui, ItemInfo: Add, Text, xs vSComment6, %SComment6%
    Gui, ItemInfo: Add, Text, x+8 vSData6, %SData6%
    Gui, ItemInfo: Add, Text, xs vSComment7, %SComment7%
    Gui, ItemInfo: Add, Text, x+8 vSData7, %SData7%
    Gui, ItemInfo: Add, Text, xs vSComment8, %SComment8%
    Gui, ItemInfo: Add, Text, x+8 vSData8, %SData8%
    Gui, ItemInfo: Add, Text, xs vSComment9, %SComment9%
    Gui, ItemInfo: Add, Text, x+8 vSData9, %SData9%
    Gui, ItemInfo: Add, Text, xs vSComment10, %SComment10%
    Gui, ItemInfo: Add, Text, x+8 vSData10, %SData10%

    global hBM := CreateDIB( "E9F5F8|E9F5F8|AFAFAF|AFAFAF|E9F5F8|E9F5F8", 2, 3, graphWidth, graphHeight, 0)
    global pGraph1 := XGraph( hGraph1, hBM, 21, "1,10,0,10", 0xFF0000, 2 ) 
    global pGraph2 := XGraph( hGraph2, hBM, 21, "1,10,0,10", 0xFF0000, 2 ) 


    Gui, ItemInfo: Add, GroupBox, Section xm+1 y+30  h251 w364 , Item Properties
    Gui, ItemInfo: Add, Edit, VScroll HScroll vItemInfoPropText xp+2 ys+17 w358, %ItemInfoPropText%
    Gui, ItemInfo: Add, GroupBox, x+10 ys   h251 w364 , Item Statistics
    Gui, ItemInfo: Add, Edit, VScroll HScroll vItemInfoStatText xp+2 ys+17 w358, %ItemInfoStatText%
    Gui, ItemInfo: Add, GroupBox, x+9 ys  h251 w364 , Item Affixes
    Gui, ItemInfo: Add, Edit, VScroll HScroll vItemInfoAffixText xp+2 ys+17 w358, %ItemInfoAffixText%
    ;Gui, ItemInfo: Show, AutoSize, % Item.Prop.ItemName " Sparkline"
    ;Gui, ItemInfo: Hide
    If (DebugMessages)
    {
      GuiControl, Show, YesTimeMS
      GuiControl, Show, YesTimeMS_t
      GuiControl, Show, YesLocation
      GuiControl, Show, YesLocation_t
    }
    Else
    {
      GuiControl, Hide, YesTimeMS
      GuiControl, Hide, YesTimeMS_t
      GuiControl, Hide, YesLocation
      GuiControl, Hide, YesLocation_t
    }
  Gui,SampleInd: Font, Bold s9 cBlack, Arial
  Gui,SampleInd: Add, Text,         section            xm   ym+5,         Gamestate Calibration:
    Gui,SampleInd: Font

    Gui,SampleInd: Add, Button, gupdateOnChar vUpdateOnCharBtn         xs y+3      w110,   OnChar
    Gui,SampleInd: Add, Button, gupdateOnInventory vUpdateOnInventoryBtn  x+8  yp      w110,   OnInventory
    Gui,SampleInd: Add, Button, gupdateOnChat vUpdateOnChatBtn         xs y+3      w110,   OnChat
    Gui,SampleInd: Add, Button, gupdateOnStash vUpdateOnStashBtn       x+8  yp      w110,   OnStash/OnLeft
    Gui,SampleInd: Add, Button, gupdateOnDiv vUpdateOnDivBtn         xs y+3      w110,   OnDiv
    Gui,SampleInd: Add, Button, gupdateOnVendor vUpdateOnVendorBtn       x+8  yp      w110,   OnVendor
    Gui,SampleInd: Add, Button, gupdateOnMenu vUpdateOnMenuBtn         xs y+3      w110,   OnMenu
    Gui,SampleInd: Add, Button, gupdateOnDelveChart vUpdateOnDelveChartBtn  x+8  yp      w110,   OnDelveChart
    Gui,SampleInd: Add, Button, gupdateOnMetamorph vUpdateOnMetamorphBtn  xs y+3      w110,   OnMetamorph
    Gui,SampleInd: Add, Button, gupdateOnLocker vUpdateOnLockerBtn  x+8  yp      w110,   OnLocker


    Gui,SampleInd: Font, Bold s9 cBlack, Arial
    Gui,SampleInd: Add, Text,         section            xm   y+10,         Inventory Calibration:
    Gui,SampleInd: Font
    Gui,SampleInd: Add, Button, gupdateEmptyColor vUdateEmptyInvSlotColorBtn xs ys+20         w110,   Empty Inventory

    Gui,SampleInd: Font, Bold s9 cBlack, Arial
    Gui,SampleInd: Add, Text,         section            xm   y+10,         AutoDetonate Calibration:
    Gui,SampleInd: Font
    Gui,SampleInd: Add, Button, gupdateDetonate vUpdateDetonateBtn     xs ys+20          w110,   OnDetonate

    Gui,SampleInd: +AlwaysOnTop

;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  END of Wingman Gui Settings
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  Grab Ninja Database, Start Scaling resolution values, and setup ignore slots
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;Begin scaling resolution values
  IfWinExist, ahk_group POEGameGroup
    {
    Rescale()
    } else {
    Global InventoryGridX := [ 1274, 1326, 1379, 1432, 1484, 1537, 1590, 1642, 1695, 1748, 1800, 1853 ]
    Global InventoryGridY := [ 638, 690, 743, 796, 848 ]  
    WR.loc.DetonateDelve.X:=1542
    WR.loc.Detonate.X:=1658
    WR.loc.Detonate.Y:=901
    WR.loc.VendorAccept.X:=380
    WR.loc.VendorAccept.Y:=820
    ; Scrolls
    WR.loc.Wisdom.X:=115
    WR.loc.Portal.X:=175
    WR.loc.Wisdom.Y:=WR.loc.Portal.Y:=190
    ; Scouring
    WR.loc.Scouring.X:=175
    WR.loc.Scouring.Y:=445
    ; Chisel
    WR.loc.Chisel.X:=605
    WR.loc.Chisel.Y:=190
    ; Alchemy
    WR.loc.Alchemy.X:=490
    WR.loc.Alchemy.Y:=260
    ; Transmutation
    WR.loc.Transmutation.X:=60
    WR.loc.Transmutation.Y:=260
    ; Augmentation
    WR.loc.Augmentation.X:=230
    WR.loc.Augmentation.Y:=310
    ; Alteration
    WR.loc.Alteration.X:=120
    WR.loc.Alteration.Y:=260
    ; Vaal
    WR.loc.Vaal.X:=230
    WR.loc.Vaal.Y:=445

    WR.loc.OnMenu.X:=960
    WR.loc.OnMenu.Y:=54
    WR.loc.OnChar.X:=41
    WR.loc.OnChar.Y:=915
    WR.loc.OnChat.X:=41
    WR.loc.OnChat.Y:=915
    WR.loc.OnInventory.X:=1583
    WR.loc.OnInventory.Y:=36
    WR.loc.OnStash.X:=336
    WR.loc.OnStash.Y:=32
    WR.loc.OnVendor.X:=618
    WR.loc.OnVendor.Y:=88
    WR.loc.OnDiv.X:=618
    WR.loc.OnDiv.Y:=135
    WR.loc.OnLeft.X:=252
    WR.loc.OnLeft.Y:=57
    WR.loc.OnDelveChart.X:=466
    WR.loc.OnDelveChart.Y:=89
    WR.loc.OnMetamorph.X:=785
    WR.loc.OnMetamorph.Y:=204
    WR.loc.OnLocker.X:=638
    WR.loc.OnLocker.Y:=600
    WR.loc.DivTrade.Y:=736
    WR.loc.DivItem.Y:=605

    WR.loc.Gui.X:=-10
    WR.loc.Gui.Y:=1027

    Global ScrCenter := { X : 960 , Y : 540 }
    }

  ;Ignore Slot setup
          apiList.MaxIndex()
  IfNotExist, %A_ScriptDir%\save\IgnoredSlot.json
  {
    For C, GridX in InventoryGridX
    {
      IgnoredSlot[C] := {}
      For R, GridY in InventoryGridY
      {
        IgnoredSlot[C][R] := False
      }
    }
    SaveIgnoreArray()
  } 
  Else
    LoadIgnoreArray()

  ;Update ninja Database
  If YesNinjaDatabase
  {
    l := apiList.MaxIndex()
    IfNotExist, %A_ScriptDir%\data\Ninja.json
    {
      Load_BarControl(0,"Initializing",1)
      For k, apiKey in apiList
      {
        Load_BarControl(k/l*100,"Downloading " k " of " l " (" apiKey ")")
        Sleep, -1
        ScrapeNinjaData(apiKey)
      }
      Load_BarControl(100,"Database Updated",-1)
      JSONtext := JSON.Dump(Ninja,,2)
      FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
      IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
    }
    Else
    {
      If DaysSince()
      {
        Load_BarControl(0,"Initializing",1)
        For k, apiKey in apiList
        {
          Load_BarControl(k/l*100,"Downloading " k " of " l " (" apiKey ")")
          Sleep, -1
          ScrapeNinjaData(apiKey)
        }
        JSONtext := JSON.Dump(Ninja,,2)
        FileDelete, %A_ScriptDir%\data\Ninja.json
        FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
        IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
        LastDatabaseParseDate := Date_now
        Load_BarControl(100,"Database Updated",-1)
      }
      Else
      {
        FileRead, JSONtext, %A_ScriptDir%\data\Ninja.json
        Ninja := JSON.Load(JSONtext)
      }
    }
  }
  Critical, Off
; Ingame Overlay (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Tooltip,

  Gui 2:Color, 0X130F13
  Gui 2:+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20
  WinSet, TransColor, 0X130F13
  Gui 2:Font, bold cFFFFFF S9, Trebuchet MS
    Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT1, Quit: OFF
    Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT2, Flasks: OFF
    Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT3, Quicksilver: OFF

  IfWinExist, ahk_group POEGameGroup
  {
    Rescale()
    Gui 2: Show,% "x" WR.loc.Gui.X " y" WR.loc.Gui.Y " NA", StatusOverlay
    GuiUpdate()
    ToggleExist := True
    If (ShowOnStart)
      Hotkeys()
  }
  Else If (ShowOnStart)
    Hotkeys()

; Timers for : game window open, Flask presses, Detonate mines, Auto Skill Up
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; Check for window to be active
  SetTimer, PoEWindowCheck, 1000
  ; Check once an hour to see if we should updated database
  SetTimer, DBUpdateCheck, 360000
  ; Log file parser
  If FileExist(ClientLog)
  {
    Monitor_GameLogs(1)
    SetTimer, Monitor_GameLogs, 300
  }
  Else
  {
    MsgBox, 262144, Client Log Error, Client.txt Log File not found!`nAssign the location in Configuration Tab`nClick ""Locate Logfile"" to find yours
    Log("Client Log not Found",ClientLog)
    SB_SetText("Client.txt file not found", 2)
  }
  ; Check for Flask presses
  SetTimer, TimerPassthrough, 15
  ; Main Game Timer
  SetTimer, TGameTick, %Tick%

; Hotkeys to reload or exit script - Hardcoded Hotkeys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  #IfWinActive
  ; Return
  !+^L::Array_Gui(Item)

  ; Reload Script with Alt+Escape
  !Escape::
    Reload
    Return

  ; Exit Script with Win+Escape
  #Escape::
    ExitApp
    Return
  #IfWinActive, ahk_group POEGameGroup

; ------------------------------------------------End of AutoExecute Section-----------------------------------------------------------------------------------------------------------
Return
; --------------------------------------------Function Section-----------------------------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Inventory Management Functions - ItemSortCommand, ClipItem, ParseClip, ItemInfo, MatchLootFilter, MatchNinjaPrice, GraphNinjaPrices, MoveStash, StockScrolls, LootScan
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; ItemSortCommand - Sort inventory and determine action
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ItemSortCommand(){
    ; Thread, NoTimers, True
    If RunningToggle  ; This means an underlying thread is already running the loop below.
    {
      RunningToggle := False  ; Signal that thread's loop to stop.
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, On
      SendMSG(1,0,scriptTradeMacro)
      Notify("Aborting Current Process","",2)
      exit  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }
    MouseGetPos xx, yy
    IfWinActive, ahk_group POEGameGroup
    {
      RunningToggle := True
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, Off
      GuiStatus()
      If (!OnChar) 
      { ;Need to be on Character 
        MsgBox %  "You do not appear to be in game.`nLikely need to calibrate OnChar"
        RunningToggle := False
        If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
          SetTimer, TGameTick, On
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
            RunningToggle := False
            If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
              SetTimer, TGameTick, On
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
            RunningToggle := False
            If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
              SetTimer, TGameTick, On
            Return
          }
        }
        Else
        {
          SendHotkey(hotkeyInventory)
          RunningToggle := False
          If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
            SetTimer, TGameTick, On
          Return
        }
      }
      Sleep, -1
      GuiStatus()
      SendMSG(1,1,scriptTradeMacro)
      If (OnDiv && YesDiv)
        DivRoutine()
      Else If (OnStash && YesStash)
        StashRoutine()
      Else If (OnVendor && YesVendor)
        VendorRoutine()
      Else If (OnLocker && YesHeistLocker)
        LockerRoutine()
      Else If (OnInventory&&YesIdentify)
        IdentifyRoutine()
    }
    RunningToggle := False  ; Reset in preparation for the next press of this hotkey.
    SendMSG(1,0,scriptTradeMacro)
    Sleep, 90*Latency
    MouseMove, xx, yy, 0
    If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
      SetTimer, TGameTick, On
    Return
  }

  ; Search Heist Locker
    ;Client:	638, 600 (recommended)
    ;Color:	1F2732 (Red=1F Green=27 Blue=32)
  SearchLocker()
  {
    If (FindStock:=FindText(GameX,GameY,GameW,GameH,0,0,HeistLockerStr))
    {
      LeftClick(FindStock.1.1 + 5,FindStock.1.2 + 5)
      Loop, 66
      {
        Sleep, 50
        GuiStatus()
        If OnLocker
        {
          Return True
        }
          
      }
    }
    Return False
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ShooMouse()
  {
    MouseGetPos Checkx, Checky
    If (((Checkx<InventoryGridX[12])&&(Checkx>InventoryGridX[1]))&&((Checky<InventoryGridY[5])&&(Checky>InventoryGridY[1]))){
      Random, RX, (A_ScreenWidth*0.45), (A_ScreenWidth*0.55)
      Random, RY, (A_ScreenHeight*0.45), (A_ScreenHeight*0.55)
      MouseMove, RX, RY, 0
      Sleep, 105*Latency
    }
  }
  ; ClearNotifications - Get rid of overlay messages if any are present
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ClearNotifications()
  {
    If (xBtn := FindText(GameW - 21,InventoryGridY[1] - 60,GameW,InventoryGridY[5] + 10,0.2,0.2,XButtonStr,0))
    {
      For k, v in xBtn
        LeftClick(v.x,v.y)
      Sleep, 195*Latency
      GuiStatus()
      ClearNotifications()
      Return
    }
    Else
      Return
  }
  ; Make a more uniform method of checking for identification
  CheckToIdentify(){
    If (Item.Affix["Unidentified"]&&YesIdentify)
    {
      If ChaosRecipeEnableFunction && ((Item.Prop.ChaosRecipe && (ChaosRecipeTypePure || ChaosRecipeTypeHybrid) && ChaosRecipeEnableUnId) 
      || (Item.Prop.RegalRecipe && (ChaosRecipeTypeHybrid || ChaosRecipeTypeRegal) && ChaosRecipeEnableUnId && Item.Prop.ItemLevel < ChaosRecipeLimitUnId))
      {
        Return False
      }
      Else If (Item.Prop.IsMap&&!YesMapUnid&&!Item.Prop.Corrupted)
      {
        Return True
      }
      Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
      {
        Return True
      }
      Else If ( Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
      {
        Return True
      }
      Else If (!Item.Prop.Chromatic && !Item.Prop.Jeweler && !Item.Prop.IsMap)
      {
        Return True
      }
    } 
    Else
      Return False
  }
  ; VendorRoutine - Does vendor functions
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  VendorRoutine()
  {
    tQ := 0
    tGQ := 0
    SortFlask := {}
    SortGem := {}
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Move mouse out of the way to grab screenshot
    ShooMouse(), GuiStatus(), ClearNotifications()
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
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
        
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
          If (Item.Prop.RarityCurrency && Item.Prop.SpecialType != "Heist Goods")
            Continue
          If (Item.Prop.RarityUnique && (Item.Prop.Ring||Item.Prop.Amulet||Item.Prop.Jewel||Item.Prop.Flask))
            Continue
          If ( Item.Prop.Flask && Item.Prop.Quality > 0 )
          {
            If (Item.Prop.Quality >= 20)
              Q := 40 
            Else 
              Q := Item.Prop.Quality
            tQ += Q
            SortFlask.Push({"C":C,"R":R,"Q":Q})
            Continue
          }
          If ( Item.Prop.RarityGem && ( Item.Prop.Quality > 0 ))
          {
            If Item.Prop.Quality >= 20
              Continue 
            Else 
              Q := Item.Prop.Quality
            Q := Item.Prop.Quality
            tGQ += Q
            SortGem.Push({"C":C,"R":R,"Q":Q})
            Continue
          }
          ; Only need entry this condition if Search Vendor/Vendor is the first option
          If (YesEnableAutomation && FirstAutomationSetting=="Search Vendor")
          {
            If Item.MatchStashManagement()
            {
              If (Item.Prop.SpecialType != "Heist Goods")
                Continue
            }
          }
          If ( Item.Prop.SpecialType="" || Item.Prop.SpecialType = "Heist Goods" )
          {
            CtrlClick(Grid.X,Grid.Y)
            If !(Item.Prop.Chromatic || Item.Prop.Jeweler)
              VendoredItems := True
            Continue
          }
        }
      }
    }
    ; Sell any bulk Flasks or Gems
    If (OnVendor && RunningToggle && YesVendor && tQ >= 40)
    {
      Grouped := GroupByFourty(SortFlask)
      For k, v in Grouped
      {
        If (!RunningToggle)  ; The user signaled the loop to stop by pressing Hotkey again.
          exit
        For kk, vv in v
        {
          If (!RunningToggle)  ; The user signaled the loop to stop by pressing Hotkey again.
            exit
          Grid := RandClick(InventoryGridX[vv.C], InventoryGridY[vv.R])
          CtrlClick(Grid.X,Grid.Y)
          RandomSleep(60,90)
          VendoredItems := True
        }
      }
    }
    If (OnVendor && RunningToggle && YesVendor && tGQ >= 40)
    {
      Grouped := GroupByFourty(SortGem)
      For k, v in Grouped
      {
        If (!RunningToggle)  ; The user signaled the loop to stop by pressing Hotkey again.
          exit
        For kk, vv in v
        {
          If (!RunningToggle)  ; The user signaled the loop to stop by pressing Hotkey again.
            exit
          Grid := RandClick(InventoryGridX[vv.C], InventoryGridY[vv.R])
          CtrlClick(Grid.X,Grid.Y)
          RandomSleep(60,90)
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
        RandomSleep(60,90)
        LeftClick(WR.loc.VendorAccept.X,WR.loc.VendorAccept.Y)
        RandomSleep(60,90)
        ContinueFlag := True
      }
      Else If (FirstAutomationSetting=="Search Vendor")
      {
        CheckTime("Seconds",30,"VendorUI",A_Now)
        While (!CheckTime("Seconds",30,"VendorUI"))
        {
          If (YesController)
            Controller()
          Sleep, 100
          GuiStatus()
          If !OnVendor && !FindText( GameX + GameW * .5, GameY, GameX + GameW * .7, GameY + GameH * .3, 0, 0, XButtonStr )
          {
            ContinueFlag := True
            break
          }
        }
      }
      ; Search Stash and StashRoutine
      If (YesEnableNextAutomation && FirstAutomationSetting=="Search Vendor" && ContinueFlag)
      {
        SendHotkey(hotkeyCloseAllUI)
        RandomSleep(45,90)
        If OnHideout
          Town := "Hideout"
        Else If OnMines
          Town := "Mines"
        Else
          Town := CompareLocation("Town")

        If OnMines
        {
          LeftClick(GameX + GameW//1.1, GameY + GameH//1.1)
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
  ; VendorRoutineChaos - Does vendor functions for Chaos Recipe
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  VendorRoutineChaos()
  {
    tQ := 0
    tGQ := 0
    SortFlask := {}
    SortGem := {}
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Move mouse out of the way to grab screenshot
    ShooMouse(), GuiStatus(), ClearNotifications()
    If !OnVendor
    {
      Notify("Error", "Not at vendor", 2)
      Return
    }

    ; Main loop through inventory
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
        
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
          If (Item.Prop.RarityCurrency)
            Continue
          If (Item.Prop.RarityUnique && (Item.Prop.Ring||Item.Prop.Amulet||Item.Prop.Jewel||Item.Prop.Flask))
            Continue
          If ( Item.Prop.Flask && Item.Prop.Quality > 0 )
          {
            If (Item.Prop.Quality >= 20)
              Q := 40 
            Else 
              Q := Item.Prop.Quality
            tQ += Q
            SortFlask.Push({"C":C,"R":R,"Q":Q})
            Continue
          }
          If ( Item.Prop.RarityGem && ( Item.Prop.Quality > 0 ))
          {
            If Item.Prop.Quality >= 20
              Continue 
            Else 
              Q := Item.Prop.Quality
            Q := Item.Prop.Quality
            tGQ += Q
            SortGem.Push({"C":C,"R":R,"Q":Q})
            Continue
          }
          ; Only need entry this condition if Search Vendor/Vendor is the first option
          ; If (YesEnableAutomation && FirstAutomationSetting=="Search Vendor")
          ; {
          ;   If Item.MatchStashManagement()
          ;   {
          ;     Continue
          ;   }
          ; }
          If ( Item.Prop.SpecialType="" )
          {
            CtrlClick(Grid.X,Grid.Y)
            Continue
          }
        }
      }
    }
    ; Auto Confirm Vendoring Option
    If (OnVendor && RunningToggle && YesEnableAutomation)
    {
      ContinueFlag := False
      If (YesEnableAutoSellConfirmation)
      {
        RandomSleep(60,90)
        LeftClick(WR.loc.VendorAccept.X,WR.loc.VendorAccept.Y)
        RandomSleep(60,90)
        ContinueFlag := True
      }
      Else If (FirstAutomationSetting=="Search Vendor")
      {
        CheckTime("Seconds",30,"VendorUI",A_Now)
        While (!CheckTime("Seconds",30,"VendorUI"))
        {
          If (YesController)
            Controller()
          Sleep, 100
          GuiStatus()
          If !OnVendor
          {
            ContinueFlag := True
            break
          }
        }
      }
      ; Search Stash and StashRoutine
      If (YesEnableNextAutomation && FirstAutomationSetting=="Search Vendor" && ContinueFlag)
      {
        SendHotkey(hotkeyCloseAllUI)
        RandomSleep(45,90)
        If OnHideout
          Town := "Hideout"
        Else If OnMines
          Town := "Mines"
        Else
          Town := CompareLocation("Town")

        If OnMines
        {
          LeftClick(GameX + GameW//1.1, GameY + GameH//1.1)
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
        SearchStash()
        ; StashRoutine()
      }
    }
    Return
  }
  ; LockerRoutine - Deposit Contracts and Blueprints at the Heist Locker
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  LockerRoutine(){
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Move mouse out of the way to grab screenshot
    ShooMouse(), GuiStatus(), ClearNotifications()
    If !OnLocker
    {
      Return
    }
    ; Main loop through inventory
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
        If indexOf(PointColor, varEmptyInvSlotColor) {
          ;Seems to be an empty slot, no need to clip item info
          Continue
        }
        ClipItem(Grid.X,Grid.Y)
        addToBlacklist(C, R)
        If (!Item.Prop.IsItem || Item.Prop.ItemName = "")
          ShooMouse(),GuiStatus(),Continue
        If (Item.Prop.Heist)
        {
          CtrlClick(Grid.X,Grid.Y)
          Sleep, 45 + (15*ClickLatency)
        }
      }
    }
    Return
  }
  ; Takes a list of Recipe Sets to the vendor
  VendorChaosRecipe()
  {
    ; Ensure we only run one instance, second press of hotkey should stop function
    If RunningToggle  ; This means an underlying thread is already running the loop below.
    {
      RunningToggle := False  ; Signal that thread's loop to stop.
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, On
      SendMSG(1,0,scriptTradeMacro)
      exit  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }
    Global InvGrid, CurrentTab
    CurrentTab := 0
    Static Object := {}
    If !Object.Count()
      Object := ChaosRecipe()
    If !Object.Count()
    {
      PrintChaosRecipe("No Complete Rare Sets")
      Return
    }
    IfWinActive, ahk_group POEGameGroup
    {
      ; Refresh our screenshot
      GuiStatus()
      ; Check OnStash / Search for stash
      If (!OnStash)
      {
        If !SearchStash()
        {
          PrintChaosRecipe("There are " Object.Count() " sets of rare items in stash.`n", 3)
          Return
        }
      }
      RunningToggle := True
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, Off
    } Else
      Return

    For k, v in Object.1
    {
      ; Move to Tab
      MoveStash(v.Prop.StashTab)
      Sleep, 15
      ; Ctrl+Click to inventory
      CtrlClick(InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].X[v.Prop.StashX]
      , InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].Y[v.Prop.StashY])
      Sleep, 30
    }

    ; Remove set from Object array
    Object.RemoveAt(1)

    ; Close Stash panel
    SendHotkey(hotkeyCloseAllUI)
    GuiStatus()
    ; Search for Vendor
    If SearchVendor()
    {
      Sleep, 45
      ; Vendor set
      VendorRoutineChaos()
    }
    If !Object.Count()
    {
      PrintChaosRecipe("Finished Selling Rare Sets")
    }
    Else
      PrintChaosRecipe("There are " Object.Count() " sets of rare items left to vendor.`n", 3)

    ; Reset in preparation for the next press of this hotkey.
    RunningToggle := False  
    SendMSG(1,0,scriptTradeMacro)
    Sleep, 90*Latency
    MouseMove, xx, yy, 0
    If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
      SetTimer, TGameTick, On
    Return
  }
  PrintChaosRecipe(Message:="Current slot totals",Duration:="False")
  {
    Global RecipeArray
    ShowUNID := False
    Tally := {}
    uTally := {}
    For Slot, Items in RecipeArray.Chaos
    {
      For k, v in Items 
      {
        If !Tally[Slot]
          Tally[Slot] := 0
        Tally[Slot] += 1
      }
    }
    For Slot, Items in RecipeArray.Regal
    {
      For k, v in Items 
      {
        If !Tally[Slot]
          Tally[Slot] := 0
        Tally[Slot] += 1
      }
    }
    For Slot, Items in RecipeArray.uChaos
    {
      For k, v in Items 
      {
        If !uTally[Slot]
          uTally[Slot] := 0
        uTally[Slot] += 1
      }
    }
    For Slot, Items in RecipeArray.uRegal
    {
      For k, v in Items 
      {
        If !uTally[Slot]
          uTally[Slot] := 0
        uTally[Slot] += 1
      }
    }
    Notify("Chaos Recipe ID/UNID", Message . "`n"
    . "Amulet: " . (Tally.Amulet?Tally.Amulet:0) . "/" . (uTally.Amulet?uTally.Amulet:0) . "`t"
    . "Ring: " . (Tally.Ring?Tally.Ring:0) . "/" . (uTally.Ring?uTally.Ring:0) . "`n"
    . "Belt: " . (Tally.Belt?Tally.Belt:0) . "/" . (uTally.Belt?uTally.Belt:0) . "`t`t"
    . "Body: " . (Tally.Body?Tally.Body:0) . "/" . (uTally.Body?uTally.Body:0) . "`n"
    . "Boots: " . (Tally.Boots?Tally.Boots:0) . "/" . (uTally.Boots?uTally.Boots:0) . "`t"
    . "Gloves: " . (Tally.Gloves?Tally.Gloves:0) . "/" . (uTally.Gloves?uTally.Gloves:0) . "`n"
    . "Helmet: " . (Tally.Helmet?Tally.Helmet:0) . "/" . (uTally.Helmet?uTally.Helmet:0) . "`t"
    . "Shield: " . (Tally.Shield?Tally.Shield:0) . "/" . (uTally.Shield?uTally.Shield:0) . "`n"
    . "One Hand: " . (Tally["One Hand"]?Tally["One Hand"]:0) . "/" . (uTally["One Hand"]?uTally["One Hand"]:0) . "`t"
    . "Two Hand: " . (Tally["Two Hand"]?Tally["Two Hand"]:0) . "/" . (uTally["Two Hand"]?uTally["Two Hand"]:0) . "`n"
    , (Duration != "False" ? Duration : 20))
    Return
  }
  ; StashRoutine - Does stash functions
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  StashRoutine()
  {
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
    HeistC := {}
    HeistR := {}
    HeistCount := 0
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Move mouse away for Screenshot
    ShooMouse(), ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH) , ClearNotifications()
    ; Main loop through inventory
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
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
        If (OnStash && YesStash) 
        {
          If (Item.Prop.SpecialType = "Quest Item")
            Continue
          Else If (sendstash:=Item.MatchLootFilter())
            Sleep, -1
          ;Heist Modification Remove at End of League!  
          Else If ((Item.Prop.SpecialType = "Heist Contract" || Item.Prop.SpecialType = "Heist Blueprint") && YesSkipMaps && ( (C >= YesSkipMaps && YesSkipMaps_eval = ">=") || (C <= YesSkipMaps && YesSkipMaps_eval = "<=") ) && ((Item.Prop.RarityNormal && YesSkipMaps_normal) || (Item.Prop.RarityMagic && YesSkipMaps_magic) || (Item.Prop.RarityRare && YesSkipMaps_rare) || (Item.Prop.RarityUnique && YesSkipMaps_unique)))
            Continue
          ;Heist Modification Remove at End of League!  
          Else If (Item.Prop.SpecialType = "Heist Contract" || Item.Prop.SpecialType = "Heist Blueprint" || Item.Prop.SpecialType = "Heist Marker")
          {
            HeistC.Push(C)
            HeistR.Push(R)
            ++HeistCount
            Continue
          }
          Else If ( Item.Prop.IsMap && YesSkipMaps
          && ( (C >= YesSkipMaps && YesSkipMaps_eval = ">=") || (C <= YesSkipMaps && YesSkipMaps_eval = "<=") )
          && ((Item.Prop.RarityNormal && YesSkipMaps_normal) 
            || (Item.Prop.RarityMagic && YesSkipMaps_magic) 
            || (Item.Prop.RarityRare && YesSkipMaps_rare) 
            || (Item.Prop.RarityUnique && YesSkipMaps_unique)) 
          && (Item.Prop.Map_Tier >= YesSkipMaps_tier))
            Continue
          Else If (sendstash:=Item.MatchStashManagement()){
            ;Skip
            If (sendstash == -1)
              Continue
            ;Affinities
            Else If (sendstash == -2)
              CtrlClick(Grid.X,Grid.Y)
          }
          Else
            ++Unstashed
          If (sendstash > 0)
          {
            If YesSortFirst
              SortFirst[sendstash].Push({"C":C,"R":R,"Item":Item})
            Else
            {
              MoveStash(sendstash)
              RandomSleep(45,45)
              CtrlClick(Grid.X,Grid.Y)
              ; Check if we need to send to alternate stash for uniques
              If (sendstash = StashTabCollection || sendstash = StashTabUniqueRing )
              && (Item.Prop.RarityUnique && !Item.Prop.HasKey("IsOrgan"))
              {
                If (StashTabYesUniqueRing && Item.Prop.Ring 
                && sendstash != StashTabUniqueRing)
                {
                  Sleep, 200*Latency
                  ShooMouse(), GuiStatus(), ClearNotifications(), Pitem := ScreenShot_GetColor(GridX,GridY)
                  if (indexOfHex(Pitem, varEmptyInvSlotColor))
                    Continue
                  MoveStash(StashTabUniqueRing)
                  RandomSleep(45,45)
                  CtrlClick(Grid.X,Grid.Y)
                }
                If (StashTabYesUniqueDump)
                {
                  Sleep, 200*Latency
                  ShooMouse(), GuiStatus(), ClearNotifications(), Pitem := ScreenShot_GetColor(GridX,GridY)
                  if (indexOfHex(Pitem, varEmptyInvSlotColor))
                    Continue
                  MoveStash(StashTabUniqueDump)
                  RandomSleep(45,45)
                  CtrlClick(Grid.X,Grid.Y)
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
            Sleep, 15*Latency
            CtrlClick(Grid.X,Grid.Y)
            Sleep, 45*Latency
            ; Check for unique items
            If (Tab = StashTabCollection || Tab = StashTabUniqueRing )
            && (Item.Prop.RarityUnique && !Item.Prop.HasKey("IsOrgan"))
            {
              If (StashTabYesUniqueRing && Item.Prop.Ring 
              && Tab != StashTabUniqueRing)
              {
                Sleep, 200*Latency
                ShooMouse(), GuiStatus(), ClearNotifications(), Pitem := ScreenShot_GetColor(GridX,GridY)
                ; Check if the item is gone, if it is we can move on
                if (indexOfHex(Pitem, varEmptyInvSlotColor))
                  Continue
                MoveStash(StashTabUniqueRing)
                RandomSleep(45,45)
                CtrlClick(Grid.X,Grid.Y)
              }
              If (StashTabYesUniqueDump)
              {
                Sleep, 200*Latency
                ShooMouse(), GuiStatus(), ClearNotifications(), Pitem := ScreenShot_GetColor(GridX,GridY)
                ; Check if the item is gone, if it is we can move on
                if (indexOfHex(Pitem, varEmptyInvSlotColor))
                  Continue
                MoveStash(StashTabUniqueDump)
                RandomSleep(45,45)
                CtrlClick(Grid.X,Grid.Y)
              }
            }
          }
        }
      }
      If (RunningToggle && (StockPortal||StockWisdom))
      {
        StockScrolls()
      }
      If (YesEnableLockerAutomation&&HeistCount)
      {
        SendHotkey(hotkeyCloseAllUI)
        RandomSleep(45,90)
        GuiStatus()
        If (SearchLocker())
        {
          RandomSleep(45,90)
          For k, v in HeistC
          {
              GridX := InventoryGridX[v]
              GridY := InventoryGridY[ObjRawGet(HeistR, k)]
              Grid := RandClick(GridX, GridY)
              CtrlClick(Grid.X,Grid.Y)
              RandomSleep(45,45)
          }
        }
      }
      ; Find Vendor if Automation Start with Search Stash and NextAutomation is enable
      If (FirstAutomationSetting == "Search Stash" && YesEnableAutomation && YesEnableNextAutomation && Unstashed && RunningToggle && (OnHideout || OnTown || OnMines))
      {
        SendHotkey(hotkeyCloseAllUI)
        RandomSleep(45,90)
        GuiStatus()
        If SearchVendor()
          VendorRoutine()
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
      Else
        Return
    }
    Sleep, 45*Latency
    If (FirstAutomationSetting == "Search Stash")
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
        Sleep, 800
        ; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
      }
    }
    if (Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SearchStr, 1, 0))
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DivRoutine()
  {
    BlackList := Array_DeepClone(IgnoredSlot)
    ShooMouse(), GuiStatus(), ClearNotifications()
    ; Main loop through inventory
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
        
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
            LeftClick(WR.loc.OnDiv.X,WR.loc.DivTrade.Y)
            Sleep, Abs(ClickLatency*15)
            CtrlClick(WR.loc.OnDiv.X,WR.loc.DivItem.Y)
            Sleep, Abs(ClickLatency*15)
          }
          Continue
        }
      }
    }
    Return
  }
  ; IdentifyRoutine - Does basic function when not at other windows
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IdentifyRoutine()
  {
    BlackList := Array_DeepClone(IgnoredSlot)
    ShooMouse(), GuiStatus(), ClearNotifications()
    ; Main loop through inventory
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
        
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
  ; ClipItem - Capture Clip at Coord
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ClipItem(x, y){
      BlockInput, MouseMove
      Clipboard := ""
      Sleep, 45+(ClipLatency*15)
      MouseMove %x%, %y%
      Sleep, 45+(ClipLatency>0?ClipLatency*15:0)
      Send ^c
      ClipWait, 0.1
      If ErrorLevel
      {
        Sleep, 15
        Send ^c
        ClipWait, 0.1
      }
      Clip_Contents := Clipboard
      Item := new ItemScan
      BlockInput, MouseMoveOff
    Return
    }
  ; ItemInfo - Display information about item under cursor
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ItemInfo(){
    ItemInfoCommand:
    MouseGetPos, Mx, My
    ; SendMSG(1,1,scriptTradeMacro)
    ClipItem(Mx, My)
    ; SendMSG(1,0,scriptTradeMacro)
    ; MsgBox % Array_Print(Item.Data.Ninja)
    Item.ItemInfo()
    ; MatchNinjaPrice(True)
    Return
  }
  ; MoveStash - Input any digit and it will move to that Stash tab
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  MoveStash(Tab,CheckStatus:=0)
  {
    If CheckStatus
    GuiStatus("OnStash")
    If (!OnStash || CurrentTab=Tab)
      return
    If (CurrentTab!=Tab) 
    {
      Sleep, 60*Latency
      Dif:=(CurrentTab-Tab)
      If (CurrentTab = 0)
      {
        If (OnChat)
        {
          Send {Escape}
          Sleep, 15
        }
        Loop 99
          send {Left}
        Loop % Tab - 1
          send {Right}
        CurrentTab:=Tab
        Sleep, 210*Latency
      }
      Else
      {
        Loop % Abs(Dif)
        {
          If (Dif > 0)
            SendInput {Left}
          Else
            SendInput {Right}
        }
        CurrentTab:=Tab
        Sleep, 210*Latency
      }
    }
    If (Tab == StashTabMap)
    {
      Sleep, 500*Latency
    }
    Else If (Tab == StashTabCollection)
    {
      Sleep, 500*Latency
    }
    return
  }
  ; StockScrolls - Restock scrolls that have more than 10 missing
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  StockScrolls(){
      BlockInput, MouseMove
      If StockWisdom{
        ClipItem(WisdomScrollX, WisdomScrollY)
        dif := (40 - Item.Prop.Stack_Size)
        If(Item.Prop.ItemBase != "Scroll of Wisdom")
        {
          CtrlClick(WisdomScrollX, WisdomScrollY)
          Sleep, 45*Latency
          dif := 40
        }
        If (dif>10)
        {
          MoveStash(StashTabCurrency)
          ShiftClick(WR.loc.Wisdom.X, WR.loc.Wisdom.Y)
          Sleep, 45*Latency
          Send %dif%
          Sleep, 45*Latency
          Send {Enter}
          Sleep, 60*Latency
          LeftClick(WisdomScrollX, WisdomScrollY)
          Sleep, 60*Latency
        }
      }
      If StockPortal{
        ClipItem(PortalScrollX, PortalScrollY)
        dif := (40 - Item.Prop.Stack_Size)
        If(Item.Prop.ItemBase != "Portal Scroll")
        {
          CtrlClick(PortalScrollX, PortalScrollY)
          Sleep, 45*Latency
          dif := 40
        }
        If (dif>10)
        {
          MoveStash(StashTabCurrency)
          ShiftClick(WR.loc.Portal.X, WR.loc.Portal.Y)
          Sleep, 45*Latency
          Send %dif%
          Sleep, 45*Latency
          Send {Enter}
          Sleep, 60*Latency
          LeftClick(PortalScrollX, PortalScrollY)
          Sleep, 60*Latency
        }
      }
      BlockInput, MouseMoveOff
    return
    }

  ; LootScan - Finds matching colors under the cursor while key pressed
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  LootScan(Reset:=0){
      Static GreenHex := 0x32DE24, QuestHex := 0x47E635, LV_LastClick := 0
      Global LootVacuumActive
      If (!ComboHex || Reset)
      {
        ComboHex := Hex2FindText(LootColors,0,0,"",3,3)
        ; ComboHex .= Hex2FindText(QuestHex,2)
        ; ComboHex .= ChestStr
        ComboHex := """" . ComboHex . """"
        If Reset
          Return
      }
      If (A_TickCount - LV_LastClick <= LVdelay)
        Return
      If (LootVacuumActive&&LootVacuum)
      {
        If AreaScale
        {
          MouseGetPos mX, mY
          ClampGameScreen(x := mX - AreaScale, y := mY - AreaScale)
          ClampGameScreen(xx := mX + AreaScale, yy := mY + AreaScale)
          If (loot := FindText(x,y,xx,yy,0,0,ComboHex,0,0))
          {
            ScanPx := loot.1.x + 10, ScanPy := loot.1.y + 10, ScanId := loot.1.id
            If ( LootVacuumActive )
              GoSub LootScan_Click
            LV_LastClick := A_TickCount
            Return
          }
          If OnMines
          {
            MouseGetPos mX, mY
            ClampGameScreen(x := mX - (AreaScale + 80), y := mY - (AreaScale + 80))
            ClampGameScreen(xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80))
            If (loot := FindText(x,y,xx,yy,0,0,DelveStr,0,0))
            {
              ScanPx := loot.1.1, ScanPy := loot.1.y
              , ScanPy += 30
              If !(loot.Id ~= "cache" || loot.Id ~= "vein")
                ScanPx += loot.3
              GoSub LootScan_Click
              LV_LastClick := A_TickCount
              Return
            }
          }
          Else
          {
            MouseGetPos mX, mY
            ClampGameScreen(x := mX - (AreaScale + 80), y := mY - (AreaScale + 80))
            ClampGameScreen(xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80))
            If (loot := FindText(x,y,xx,yy,0,0,ChestStr,0,0))
            {
              ScanPx := loot.1.1, ScanPy := loot.1.y
              , ScanPy += 30
              GoSub LootScan_Click
              LV_LastClick := A_TickCount
              Return
            }
          }
        }
        Else
        {
          MouseGetPos mX, mY
          PixelGetColor, scolor, mX, mY, RGB
          If (indexOf(scolor,LootColors) || CompareHex(scolor,GreenHex,53,1))
            If ( LootVacuumActive )
            {
              click %mX%, %mY%
              LV_LastClick := A_TickCount
            }
        }
      }
      Else
        LootVacuumActive := False
    Return

    LootScanCommand:
      If !LootVacuumActive
      {
        LootVacuumActive:=True
      }
    Return
    LootScanCommandRelease:
      If LootVacuumActive
      {
        LootVacuumActive:=False
      }
    Return

    LootScan_Click:
      LP := GetKeyState("LButton","P"), RP := GetKeyState("RButton","P")
      If (LP || RP)
      {
        If LP
          Click, up
        If RP
          Click, Right, up
        Sleep, 25
      }
      ; MouseMove, ScanPx, ScanPy
      BlockInput, MouseMove
      Click %ScanPx%, %ScanPy%
      BlockInput, Mousemoveoff
      If (GetKeyState("RButton","P"))
        Click, Right, down
    Return
  }

  ; Build crafting popup menu
  CraftBasicPopUpBuild(){
    global hotkeyCraftBasic, CraftMenu
    CraftMenu := new Radial_Menu
    CraftMenu.SetSections("5")
    CraftMenu.Add("Chance","Images/Chance.png", "1")
    CraftMenu.Add("Socket","Images/Jeweller.png", "2")
    CraftMenu.Add("Color","Images/Chromatic.png", "3")
    CraftMenu.Add("Link","Images/Fusing.png", "4")
    CraftMenu.Add("Maps","Images/Maps.png", "5")
    ; CraftMenu.Add2("Jeweller","Images/Jeweller.png", "4")
  }
  CraftBasicPopUp(){
    static _init_ := CraftBasicPopUpBuild()
    Global CraftMenu, RunningToggle
    If RunningToggle  ; This means an underlying thread is already running the loop below.
    {
      RunningToggle := False  ; Signal that thread's loop to stop.
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, On
      SendMSG(1,0,scriptTradeMacro)
      Notify("Aborting Current Process","",2)
      exit  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }

    If !(CraftMenu.Active){
      MouseGetPos itemx, itemy
      CraftMenu.SetKey(hotkeyCraftBasic)
      ; CraftMenu.SetKeySpecial("Ctrl")
      selection := CraftMenu.Show()
      If selection
      {
        If DebugMessages
        {
          If (selection = "Maps")
            Notify("Begin Bulk Crafting Maps","",2)
          Else If (selection = "Socket")
            Notify("Socketing Selected Item","",2)
          Else If (selection = "Color")
            Notify("Coloring Selected Item","",2)
          Else If (selection = "Link")
            Notify("Linking Selected Item","",2)
          Else If (selection = "Chance")
            Notify("Chance Selected Item until Unique","Either Bulk mode or Scour",2)
          Else
            Notify("Result is:",selection,2)
        }
        WinActivate, % GameStr
        Crafting(selection)
      }
      Else WinActivate, % GameStr
    }
  }
; Main Script Logic Timers - TGameTick, TimerPassthrough
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; TGameTick - Flask Logic timer
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
      If (OnTown||OnHideout||!(AutoQuit||AutoFlask||DetonateMines||YesAutoSkillUp||LootVacuum))
      {
        Msg := (OnTown?"Script paused in town":(OnHideout?"Script paused in hideout":(!(AutoQuit||AutoFlask||DetonateMines||YesAutoSkillUp||LootVacuum)?"All options disabled, pausing":"Error")))
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
        Else If (YesOHB && !CheckOHB())
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
        Else If CheckTime("seconds",1,"StatusBar1")
          SB_SetText("WingmanReloaded Active", 1)
        If (!OnMetamorph && Metamorph_Filled && ((A_TickCount - OnScreenMM) >= 5000) && !FindText( GameX + GameW * .5, GameY, GameX + GameW * .7, GameY + GameH * .3, 0, 0, XButtonStr ))
          Metamorph_Filled := False
        If CheckGamestates
          mainmenuGameLogicState()
      }
      If (DetonateMines&&!Detonated)
      {
        If (OnDetonate)
        {
          SendHotkey(hotkeyDetonateMines)
          Detonated:=1
          Settimer, TDetonated, -%DetonateMinesDelay%
          a := A_TickCount - MainAttackLastRelease
          If CastOnDetonate&&GetKeyState(hotkeyTriggerMovement,"P")&&(a > 1000)
          {
            SendHotkey(hotkeyCastOnDetonate)
          }
        }
      }
      SendDelayAction()
      If (AutoFlask || AutoQuit)
      {
        ScanGlobe()
        if (!RadioCi) { ; Life
          if (AutoQuit && Player.Percent.Life < QuitBelow)
          {
            LogoutCommand()
            Exit
          }
        } Else { ; Energy Shield
          if ( AutoQuit && Player.Percent.ES < QuitBelow)
          {
            LogoutCommand()
            Exit
          }
        }
        If (AutoFlask)
        {
          Loop 5
          {
            If (WR.cdExpires.Flask[A_Index] < A_TickCount)
            {
              If(WR.Flask[A_Index].Life && WR.Flask[A_Index].Life > Player.Percent.Life)
              {
                Trigger(WR.Flask[A_Index],"Flask")
                Continue
              }
              If(WR.Flask[A_Index].ES && WR.Flask[A_Index].ES > Player.Percent.ES)
              {
                Trigger(WR.Flask[A_Index],"Flask")
                Continue
              }
              If(WR.Flask[A_Index].Mana && WR.Flask[A_Index].Mana > Player.Percent.Mana)
              {
                Trigger(WR.Flask[A_Index],"Flask")
                Continue
              }
            }
          }
        }

        If (MainAttackPressedActive && AutoFlask)
        {
          Loop 5
            If (WR.Flask[A_Index].MainAttack && WR.cdExpires.Flask[A_Index] < A_TickCount)
              Trigger(WR.Flask[A_Index],"Flask")
          Loop, 10
            If (WR.Utility[A_Index].Enable) && WR.cdExpires.Utility[A_Index] < A_TickCount && (WR.Utility[A_Index].MainAttack)
              Trigger(WR.Utility[A_Index],"Utility")
        }
        If (SecondaryAttackPressedActive && AutoFlask)
        {
          Loop 5
            If (WR.Flask[A_Index].SecondaryAttack && WR.cdExpires.Flask[A_Index] < A_TickCount)
              Trigger(WR.Flask[A_Index],"Flask")
          Loop, 10
          {
            If (WR.Utility[A_Index].Enable && WR.cdExpires.Utility[A_Index] < A_TickCount && WR.Utility[A_Index].SecondaryAttack)
              Trigger(WR.Utility[A_Index],"Utility")
          }
        }

        If (AutoFlask) ; Trigger Utilities
        {
          Loop, 10
          {
            If (WR.Utility[A_Index].Enable && WR.cdExpires.Utility[A_Index] < A_TickCount)
            {
              If ( WR.Utility[A_Index].OnCD )
                Trigger(WR.Utility[A_Index],"Utility")
              Else If ( WR.Utility[A_Index].ES && WR.Utility[A_Index].ES > Player.Percent.ES )
                Trigger(WR.Utility[A_Index],"Utility")
              Else If  (WR.Utility[A_Index].Life && WR.Utility[A_Index].Life > Player.Percent.Life )
                Trigger(WR.Utility[A_Index],"Utility")
              Else If (WR.Utility[A_Index].Mana && WR.Utility[A_Index].Mana > Player.Percent.Mana )
                Trigger(WR.Utility[A_Index],"Utility")
              Else If (WR.Utility[A_Index].Icon)
              {
                BuffIcon := FindText(GameX, GameY, GameX + GameW, GameY + Round(GameH / ( 1080 / 75 )), 0, 0, IconStringUtility%A_Index%,0)
                If (!WR.Utility[A_Index].IconShow && BuffIcon) || (WR.Utility[A_Index].IconShow && !BuffIcon)
                  WR.cdExpires.Utility[A_Index] := A_TickCount + (WR.Utility[A_Index].IconShow ? 150 : WR.Utility[A_Index].CD)
                Else If (WR.Utility[A_Index].IconShow && BuffIcon) || (!WR.Utility[A_Index].IconShow && !BuffIcon)
                  Trigger(WR.Utility[A_Index],"Utility")
              }
            }
          }
        }
      }
      If (AutoQuick)
      {
        If (MovementHotkeyActive || GetKeyState(hotkeyTriggerMovement, "P") || (MainAttackPressedActive && QSonMainAttack) || (SecondaryAttackPressedActive && QSonSecondaryAttack))
        {
          Loop 5
            If WR.Flask[A_Index].Move
              Trigger(WR.Flask[A_Index],"Flask")
          Loop 10
            If WR.Utility[A_Index].Move
              Trigger(WR.Utility[A_Index],"Utility")
        }
      }
      If (StackRelease_Enable)
        StackRelease()
      If LootVacuum
        LootScan()
      AutoSkillUp()
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
  
  ; TimerPassthrough - Uses the first key of each flask slot in order to put the slot on cooldown when manually used.
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TimerPassthrough:
    Loop 5
      If GetKeyState(StrSplit(WR.Flask[A_Index].Key," ")[1], "P")
        WR.cdExpires.Flask[A_Index]:=A_TickCount + WR.Flask[A_Index].CD
  Return
; Toggle Main Script Timers - AutoQuit, AutoFlask, GuiUpdate
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; AutoQuit - Toggle Auto-Quit
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoQuit(){
    AutoQuitCommand:
      AutoQuit := !AutoQuit
      IniWrite, %AutoQuit%, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuit
      GuiUpdate()
    return
    }

  ; AutoFlask - Toggle Auto-Pot
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoFlask(){
    AutoFlaskCommand:  
      AutoFlask := !AutoFlask
      IniWrite, %AutoFlask%, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoFlask
      GuiUpdate()  
    return
    }
  ; AutoQuicksilverCommand - Toggle Auto-Quick
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoQuicksilverCommand:
    AutoQuick := !AutoQuick  
    IniWrite, %AutoQuick%, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuick
    GuiUpdate()
  return
  ; Hotkey to pause the detonate mines
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PauseMines(){
    PauseMinesCommand:
      if !DetonateMines
      return
      static keyheld := 0
      keyheld++
      settimer, keyheldReset, 200
      if keyheld > 1
        return
      KeyWait, %hotkeyPauseMines%, T0.3 ; Wait .3 seconds until Detonate key is released.
      If ErrorLevel = 1 ; If not released, just exit out
        Exit
      keyheld := 0
      If PauseMinesDelay <= 50
      {
        pauseToggle := !pauseToggle
      }
      else if (A_PriorHotkey <> "$~" . hotkeyPauseMines || A_TimeSincePriorHotkey > PauseMinesDelay)
      {    ;This is a not a double tap
        pauseToggle := false
      }
      else if (A_TimeSincePriorHotkey > 50 && A_TimeSincePriorHotkey < PauseMinesDelay)
      {    ;This is a double tap that works if within range 25-set value
        pauseToggle := true
      }
      else if A_TimeSincePriorHotkey < 50
      {
        return
      }
      if (!pauseToggle)
      {
        Detonated := False
        PauseTooltips := 0
        Tooltip
      }
      else if (pauseToggle)
      {
        SetTimer, TDetonated, Delete
        Detonated := True
        PauseTooltips := 1
        Tooltip, Auto-Mines Paused, % A_ScreenWidth / 2 - 57, % A_ScreenHeight / 8
      }
    Return

    keyheldReset:
      keyheld := 0
    return
  }

  ; GuiUpdate - Update Overlay ON OFF states
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GuiUpdate(){
    GuiControl, 2:, overlayT1,% "Quit: " (AutoQuit?"ON":"OFF")
    GuiControl, 2:, overlayT2,% "Flasks: " (AutoFlask?"ON":"OFF")
    GuiControl, 2:, overlayT3,% "Quicksilver: " (AutoQuick?"ON":"OFF")
    ShowHideOverlay()
    Return
  }

; Trigger Abilities or Flasks - MainAttackCommand, SecondaryAttackCommand, Trigger
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; Trigger - Generic Trigger for flasks or utility
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Trigger(obj,type:="Flask"){
    Static ActionList := {}
    Static LastHeldLB, LastHeldMA, LastHeldSA
    Global MovementHotkeyActive
    If !IsObject(ActionList[obj.Group])
      ActionList[obj.Group] := {}
    If !ActionList[obj.Group].Count()
    {
      loop % (type="Flask"?5:10)
        if (WR[type][A_Index].Group = obj.Group 
        && WR.cdExpires[type][A_Index] < A_TickCount 
        && !indexOf(type . " " . A_Index,ActionList[obj.Group])) 
          ActionList[obj.Group].Push(type . " " . A_Index)
    } Else If (WR.cdExpires[type][obj.Slot] < A_TickCount 
    && !indexOf(A_Index,ActionList[obj.Group]))4
      ActionList[obj.Group].Push(type . " " . obj.Slot)
    For k, v in ActionList[obj.Group]
    {
      type := StrSplit(v, " ")[1], v := StrSplit(v, " ")[2]
      If (WR.cdExpires[type][v] < A_TickCount && WR.cdExpires.Group[obj.Group] < A_TickCount)
      {
        If (WR[type][v].Move)
        {
          If !GameActive
            Return
          MovementPressed := ( MovementHotkeyActive || GetKeyState(hotkeyTriggerMovement, "P") )
          If (TriggerQuicksilverDelay > 0)
          {
            delay := TriggerQuicksilverDelay * 1000
            If (!LastHeldLB && MovementPressed)
              LastHeldLB := A_TickCount
            Else If (LastHeldLB && !MovementPressed)
              LastHeldLB := False
            If (MovementPressed && A_TickCount - LastHeldLB < delay )
              Continue
            
            If QSonMainAttack
            {
              If (!LastHeldMA && MainAttackPressedActive)
                LastHeldMA := A_TickCount
              Else If (LastHeldMA && !MainAttackPressedActive)
                LastHeldMA := False
              If (MainAttackPressedActive && A_TickCount - LastHeldMA < delay )
                Continue
            }

            If QSonSecondaryAttack
            {
              If (!LastHeldSA && SecondaryAttackPressedActive)
                LastHeldSA := A_TickCount
              Else If (LastHeldSA && !SecondaryAttackPressedActive)
                LastHeldSA := False
              If (SecondaryAttackPressedActive && A_TickCount - LastHeldSA < delay )
                Continue
            }
          }
          if !(MovementPressed 
            || (MainAttackPressedActive && QSonMainAttack) 
            || (SecondaryAttackPressedActive && QSonSecondaryAttack) )
            Continue
        }
        SendHotkey(WR[type][v].Key)
        WR.cdExpires.Group[obj.Group] := A_TickCount + WR[type][v].GroupCD 
        WR.cdExpires[type][v] := A_TickCount + WR[type][v].CD 
        ActionList[obj.Group].RemoveAt(k)
        If (WR[type][v].Group = "QuickSilver")
          Loop, 10
            If (WR.Utility[A_Index].Enable && WR.Utility[A_Index].QS)
              Trigger(WR.Utility[A_Index],"Utility")
        Return
      }
    }
    Return
  }

  ; MainAttackCommand - Main attack Flasks
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    Return  
  }
  ; SecondaryAttackCommand - Secondary attack Flasks
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    Return  
  }
  
; mainmenuGameLogicState - Update information in main menu regarding game logic states
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  mainmenuGameLogicState(){
    Static OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1, OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnMetamorph:=-1, OldOnDetonate:=-1, OldOnLocker:=-1
    Local NewOHB
    If (OnChar != OldOnChar)
    {
      OldOnChar := OnChar
      If OnChar
        CtlColors.Change(MainMenuIDOnChar, "Lime", "")
      Else
        CtlColors.Change(MainMenuIDOnChar, "Red", "")
    }
    If ((NewOHB := (CheckOHB()?1:0)) != OldOHB)
    {
      OldOHB := NewOHB
      If NewOHB
        CtlColors.Change(MainMenuIDOnOHB, "Lime", "")
      Else
        CtlColors.Change(MainMenuIDOnOHB, "Red", "")
    }
    If (OnInventory != OldOnInventory)
    {
      OldOnInventory := OnInventory
      If (OnInventory)
        CtlColors.Change(MainMenuIDOnInventory, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnInventory, "", "Green")
    }
    If (OnChat != OldOnChat)
    {
      OldOnChat := OnChat
      If OnChat
        CtlColors.Change(MainMenuIDOnChat, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnChat, "", "Green")
    }
    If (OnStash != OldOnStash)
    {
      OldOnStash := OnStash
      If (OnStash)
        CtlColors.Change(MainMenuIDOnStash, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnStash, "", "Green")
    }
    If (OnDiv != OldOnDiv)
    {
      OldOnDiv := OnDiv
      If (OnDiv)
        CtlColors.Change(MainMenuIDOnDiv, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnDiv, "", "Green")
    }
    If (OnLeft != OldOnLeft)
    {
      OldOnLeft := OnLeft
      If (OnLeft)
        CtlColors.Change(MainMenuIDOnLeft, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnLeft, "", "Green")
    }
    If (OnDelveChart != OldOnDelveChart)
    {
      OldOnDelveChart := OnDelveChart
      If (OnDelveChart)
        CtlColors.Change(MainMenuIDOnDelveChart, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnDelveChart, "", "Green")
    }
    If (OnVendor != OldOnVendor)
    {
      OldOnVendor := OnVendor
      If (OnVendor)
        CtlColors.Change(MainMenuIDOnVendor, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnVendor, "", "Green")
    }
    If (OnDetonate != OldOnDetonate)
    {
      OldOnDetonate := OnDetonate
      If (OnDetonate)
        CtlColors.Change(MainMenuIDOnDetonate, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnDetonate, "", "Green")
    }
    If (OnMenu != OldOnMenu)
    {
      OldOnMenu := OnMenu
      If (OnMenu)
        CtlColors.Change(MainMenuIDOnMenu, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnMenu, "", "Green")
    }
    If (OnMetamorph != OldOnMetamorph)
    {
      OldOnMetamorph := OnMetamorph
      If (OnMetamorph)
        CtlColors.Change(MainMenuIDOnMetamorph, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnMetamorph, "", "Green")
    }
    If (OnLocker != OldOnLocker)
    {
      OldOnLocker := OnLocker
      If (OnLocker)
        CtlColors.Change(MainMenuIDOnLocker, "Red", "")
      Else
        CtlColors.Change(MainMenuIDOnLocker, "", "Green")
    }
    Return

    CheckPixelGrid:
      ;Check if inventory is open
      Gui, States: Hide
      if(!OnInventory){
        TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
      }else{
        TT := "Grid information:" . "`n"
        ScreenShot()
        For C, GridX in InventoryGridX  
        {
          For R, GridY in InventoryGridY
          {
            PointColor := ScreenShot_GetColor(GridX,GridY)
            if (indexOf(PointColor, varEmptyInvSlotColor)) {        
              TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Empty inventory slot. Color: " . PointColor  .  "`n"
            }else{
              TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Possibly occupied slot. Color: " . PointColor  .  "`n"
            }
          }
        }
      }
      MsgBox %TT%  
      Gui, States: Show
    Return
  }
; GrabCurrency - Get currency fast to use on a white/blue/rare strongbox
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GrabCurrency(){
    GrabCurrencyCommand:
      Critical
      Keywait, Alt
      BlockInput, MouseMove
      MouseGetPos xx, yy
      RandomSleep(45,45)
      If (GrabCurrencyPosX && GrabCurrencyPosY)
      {
        If !GuiStatus("OnInventory")
        {
          SendHotkey(hotkeyInventory)
          RandomSleep(45,45)
        }
        RandomSleep(45,45)
        RightClick(GrabCurrencyPosX, GrabCurrencyPosY)
        RandomSleep(45,45)
        SendHotkey(hotkeyInventory)
        MouseMove, xx, yy, 0
        BlockInput, MouseMoveOff
      }
  return
  }

; Crafting - Deal with Crafting requirement conditions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Crafting(selection:="Maps")
  {
      ; Thread, NoTimers, True
      MouseGetPos xx, yy
      If RunningToggle
      {
        RunningToggle := False
        If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        {
          SetTimer, TGameTick, On
        }
        SendMSG(1,0,scriptTradeMacro)
        Notify("Aborting Current Process","",2)
      exit
      }
      If GameActive
      {
        RunningToggle := True
        If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
          SetTimer, TGameTick, Off
        GuiStatus()
        If (!OnChar) 
        {
          MsgBox %  "You do not appear to be in game.`nLikely need to calibrate Character Active"
          RunningToggle := False
          If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
            SetTimer, TGameTick, On
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
              RunningToggle := False
              If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
              {
                SetTimer, TGameTick, On
              }
              SendMSG(1,0,scriptTradeMacro)
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
          If (selection = "Maps")
            CraftingMaps()
          Else If (selection = "Socket")
            Notify("Logic Coming Soon","",2)
          Else If (selection = "Color")
            Notify("Logic Coming Soon","",2)
          Else If (selection = "Link")
            Notify("Logic Coming Soon","",2)
          Else If (selection = "Chance")
            Notify("Logic Coming Soon","",2)
          Else
            Notify("Result is:",selection,2)

          }
          Else
          {
            ; Exit Routine
            RunningToggle := False
            If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
              SetTimer, TGameTick, On
            SendMSG(1,0,scriptTradeMacro)
            Return
          }
        }
      }
      MouseMove %xx%, %yy%
      RunningToggle := False
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, On
      SendMSG(1,0,scriptTradeMacro)
    Return
  }

; CraftingMaps - Scan the Inventory for Maps and apply currency based on method select in Crafting Settings
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CraftingMaps()
  {
    Global RunningToggle
    CurrentTab := 0
    MoveStash(StashTabCurrency)
    ; Move mouse away for Screenshot
    ShooMouse(), GuiStatus(), ClearNotifications()
    ; Ignore Slot
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Start Scan on Inventory
    SendMSG(1,1,scriptTradeMacro)
    For C, GridX in InventoryGridX
    {
      If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
        Break
      For R, GridY in InventoryGridY
      {
        If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
          Break
        If BlackList[C][R]
          Continue
        Grid := RandClick(GridX, GridY)
        If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
        {   
          Ding(500,11,"Hit Scroll")
          Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
        } 
        PointColor := ScreenShot_GetColor(GridX,GridY)
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
          If ( Item.Prop.IsMap
          && (!YesMapUnid || ( Item.Prop.RarityMagic && ( getMapCraftingMethod() ~= "Alchemy" )))
          &&!Item.Prop.Corrupted)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (!Item.Prop.Chromatic && !Item.Prop.Jeweler && !Item.Prop.IsMap)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
        }
        ;Crafting Map Script
        If (Item.Prop.IsMap && !Item.Prop.IsBlightedMap && !Item.Prop.Corrupted && !Item.Prop.RarityUnique) 
        {
          ;Check all 3 ranges tier with same logic
          i = 0
          Loop, 3
          {
            i++
            If (EndMapTier%i% >= StartMapTier%i% && CraftingMapMethod%i% != "Disable" && Item.Prop.Map_Tier >= StartMapTier%i% && Item.Prop.Map_Tier <= EndMapTier%i%)
            {
              If (!Item.Prop.RarityNormal)
              {
                If ((Item.Prop.RarityMagic && CraftingMapMethod%i% == "Transmutation+Augmentation") 
                || (Item.Prop.RarityRare && (CraftingMapMethod%i% == "Transmutation+Augmentation" || CraftingMapMethod%i% == "Alchemy")) 
                || (Item.Prop.RarityRare && Item.Prop.Quality >= 20 && (CraftingMapMethod%i% == "Transmutation+Augmentation" || CraftingMapMethod%i% == "Alchemy" || CraftingMapMethod%i% == "Chisel+Alchemy")))
                {
                  MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
                  Continue
                }
                Else
                {
                  ApplyCurrency("Scouring",Grid.X,Grid.Y)
                }
              }
              If (Item.Prop.RarityNormal)
              {
                If (Item.Prop.Map_Quality <= 20)
                {
                  numberChisel := (20 - Item.Prop.Map_Quality)//5
                }  
                Else
                {
                  numberChisel := 0
                }
                If (CraftingMapMethod%i% == "Transmutation+Augmentation")
                {
                  MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
                  Continue
                }
                Else if (CraftingMapMethod%i% == "Alchemy")
                {
                  MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
                  Continue
                }
                Else if (CraftingMapMethod%i% == "Chisel+Alchemy")
                {
                  Loop, %numberChisel%
                  {
                    ApplyCurrency("Chisel",Grid.X,Grid.Y)
                  }
                  MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
                  Continue
                }
                Else if (CraftingMapMethod%i% == "Chisel+Alchemy+Vaal")
                {
                  Loop, %numberChisel%
                  {
                    ApplyCurrency("Chisel",Grid.X,Grid.Y)
                  }
                  MapRoll("Alchemy",Grid.X,Grid.Y)
                  ApplyCurrency("Vaal",Grid.X,Grid.Y)
                  Continue
                }
              }
            }
          }
        }
      }
    }
    SendMSG(1,0,scriptTradeMacro)
    Return
  }

  getMapCraftingMethod()
  {
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
; ApplyCurrency - Using cname = currency name string and x, y as apply position
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ApplyCurrency(cname, x, y)
  {
    RightClick(WR.loc[cname].X, WR.loc[cname].Y)
    Sleep, 45*Latency
    LeftClick(x,y)
    Sleep, 90*Latency
    ClipItem(x,y)
    Sleep, 45*Latency
    return
  }

; MapRoll - Apply currency/reroll on maps based on select undesireable mods
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  MapRoll(Method, x, y)
  {
    MMQIgnore := False
    If (Method == "Transmutation+Augmentation")
    {
      cname := "Transmutation"
      crname := "Alteration"
      If (!EnableMQQForMagicMap)
      {
        MMQIgnore := True
      }
    }
    Else If (Method == "Alchemy")
    {
      cname := "Alchemy"
      crname := "Scouring"
    }
    Else If (Method == "Chisel+Alchemy")
    {
      cname := "Alchemy"
      crname := "Scouring"
    }
    Else If (Method == "Chisel+Alchemy+Vaal")
    {
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
      ApplyCurrency(cname, x, y)
    }
    If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic && cname = "Transmutation")
    {
      ApplyCurrency("Augmentation",x,y)
    }
    antr := Item.Prop.Map_Rarity
    antp := Item.Prop.Map_PackSize
    antq := Item.Prop.Map_Quantity
    ;MFAProjectiles,MDExtraPhysicalDamage,MICSC,MSCAT
    While ( (Item.Affix["Monsters have # chance to Avoid Elemental Ailments"] && AvoidAilments) 
    || (Item.Affix["Monsters have a # chance to avoid Poison, Blind, and Bleeding"] && AvoidPBB) 
    || (Item.Affix["Monsters reflect # of Elemental Damage"] && ElementalReflect) 
    || (Item.Affix["Monsters reflect # of Physical Damage"] && PhysicalReflect) 
    || (Item.Affix["Players cannot Regenerate Life, Mana or Energy Shield"] && NoRegen) 
    || (Item.Affix["Cannot Leech Life from Monsters"] && NoLeech)
    || (Item.Affix["-# maximum Player Resistances"] && MinusMPR)
    || (Item.Affix["Monsters fire # additional Projectiles"] && MFAProjectiles)
    || (Item.Affix["Monsters deal # extra Physical Damage as Fire"] && MDExtraPhysicalDamage)
    || (Item.Affix["Monsters deal # extra Physical Damage as Cold"] && MDExtraPhysicalDamage)
    || (Item.Affix["Monsters deal # extra Physical Damage as Lightning"] && MDExtraPhysicalDamage)
    || (Item.Affix["Monsters have # increased Critical Strike Chance"] && MICSC)
    || (Item.Affix["Monsters' skills Chain # additional times"] && MSCAT)
    || (Item.Affix["Players have # less Recovery Rate of Life and Energy Shield"] && LRRLES)
    || (Item.Prop.RarityNormal) 
    || (!MMQIgnore && (Item.Prop.Map_Rarity <= MMapItemRarity 
    || Item.Prop.Map_PackSize <= MMapMonsterPackSize 
    || Item.Prop.Map_Quantity <= MMapItemQuantity)) )
    && !Item.Affix["Unidentified"]
    {
      If (!RunningToggle)
      {
        break
      }
      antr := Item.Prop.Map_Rarity
      antp := Item.Prop.Map_PackSize
      antq := Item.Prop.Map_Quantity
      ; Scouring or Alteration
      ApplyCurrency(crname, x, y)
      If (Item.Prop.RarityNormal)
      {
        ApplyCurrency(cname, x, y)
      }
      ; Augmentation if not 2 mods on magic maps
      Else If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic)
      {
        ApplyCurrency("Augmentation",x,y)
      }
      If (DebugMessages)
      {
      Notify("MapCrafting: " Item.Prop.ItemBase "","Before Rolling`nItem Rarity: " antr "`nMonsterPackSize: " antp "`nItem Quantity: " antq "`nAfter Rolling`nItem Rarity: " Item.Prop.Map_Rarity "`nMonsterPackSize: " Item.Prop.Map_PackSize "`nItem Quantity: " Item.Prop.Map_Quantity "`nEnd",4)
      }
    }
    return
  }
  
; GemSwap - Swap gems between two locations
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GemSwap()
  {
    GemSwapCommand:
      Critical
      Keywait, Alt
      BlockInput, MouseMove
      MouseGetPos xx, yy
      RandomSleep(45,45)

      If !GuiStatus("OnInventory")
      {
        SendHotkey(hotkeyInventory)
        RandomSleep(45,45)
      }
      ;First Gem or Item Swap
      If (CurrentGemX && CurrentGemY && AlternateGemX && AlternateGemY) 
      {
        If (GemItemToogle)
        {
          LeftClick(CurrentGemX, CurrentGemY)
        }
        Else
        {
          RightClick(CurrentGemX, CurrentGemY)
        }
        RandomSleep(45,45)
        If (AlternateGemOnSecondarySlot && !GemItemToogle)
        {
          SendHotkey(hotkeyWeaponSwapKey)
          RandomSleep(45,45)
        }
        LeftClick(AlternateGemX, AlternateGemY)
        RandomSleep(90,120)
        If (AlternateGemOnSecondarySlot && !GemItemToogle)
        {
          SendHotkey(hotkeyWeaponSwapKey)
          RandomSleep(45,45)
        }
        LeftClick(CurrentGemX, CurrentGemY)
        RandomSleep(90,120)
      }
      ;Second Gem of Item Swap
      If (CurrentGem2X && CurrentGem2Y && AlternateGem2X && AlternateGem2Y) 
      {
        If (GemItemToogle2)
        {
          LeftClick(CurrentGem2X, CurrentGem2Y)
        }
        Else
        {
          RightClick(CurrentGem2X, CurrentGem2Y)
        }
        RandomSleep(45,45)
        If (AlternateGem2OnSecondarySlot && !GemItemToogle2)
        {
          SendHotkey(hotkeyWeaponSwapKey)
          RandomSleep(45,45)
        }
        LeftClick(AlternateGem2X, AlternateGem2Y)
        RandomSleep(90,120)
        If (AlternateGem2OnSecondarySlot && !GemItemToogle2)
        {
          SendHotkey(hotkeyWeaponSwapKey)
          RandomSleep(45,45)
        }
        LeftClick(CurrentGem2X, CurrentGem2Y)
        RandomSleep(90,120)
      }
      SendHotkey(hotkeyInventory)
      MouseMove, xx, yy, 0
      BlockInput, MouseMoveOff
    return
  }

; QuickPortal - Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  QuickPortal(ChickenFlag := False){
    QuickPortalCommand:
      If (OnTown || OnHideout || OnMines)
        Return
      Critical
      Keywait, Alt
      BlockInput On
      BlockInput MouseMove
      If (GetKeyState("LButton","P"))
        Click, up
      If (GetKeyState("RButton","P"))
        Click, Right, up
      MouseGetPos xx, yy
      RandomSleep(53,87)
      
      If !(OnInventory)
      {
        SendHotkey(hotkeyInventory)
        RandomSleep(56,68)
      }
      RightClick(PortalScrollX, PortalScrollY)

      SendHotkey(hotkeyInventory)
      If YesClickPortal || ChickenFlag
      {
        Sleep, 75*Latency
        SwiftClick(GameX + Round(GameW/2),GameY + Round(GameH/2.427))
      }
      Else
        MouseMove, xx, yy, 0
      BlockInput Off
      BlockInput MouseMoveOff
      RandomSleep(300,600)
      Thread, NoTimers, False    ;End Critical
    return
    }

; PopFlasks - Pop all flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PopFlasks(){
    PopFlasksCommand:
      Critical
      If PopFlaskRespectCD
      {
        Loop 5
        {
          If WR.Flask[A_Index].PopAll
            Trigger(WR.Flask[A_Index])
        }
      }
      Else
      {
        Loop 5
        {
          If WR.Flask[A_Index].PopAll
          {
            SendHotkey(WR.Flask[A_Index].Key)
            WR.cdExpires.Flask[A_Index]:=A_TickCount + WR.Flask[A_Index].CD
            WR.cdExpires.Group[WR.Flask[A_Index].Group] := A_TickCount + WR.Flask[A_Index].GroupCD
            RandomSleep(-99,99)
          }
        }
      }
      Thread, NoTimers, False    ;End Critical
    return
    }

; LogoutCommand - Logout Function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  LogoutCommand(){
    LogoutCommand:
      Critical
      Static LastLogout := 0
      if (RadioCritQuit || (RadioPortalQuit && (OnMines || OnTown || OnHideout))) {
        global POEGameArr
        dc := False
        succ := logout(Active_executable)
        if !(succ == 0)
        {
          dc := True
        }
        Else
        {
          tt=
          For k, executable in POEGameArr
          {
            tt.= (tt?",":"") executable
            succ := logout(executable)
            if !(succ == 0)
            {
              dc := True
              Break
            }
          }
        }
        If !dc
          Log("Logout Failed","Could not find game EXE",tt)
        If RelogOnQuit
        {
          RandomSleep(350,350)
          ControlSend,, {Enter}, %GameStr%
          RandomSleep(750,750)
          ControlSend,, {Enter}, %GameStr%
        }
      } 
      Else If RadioPortalQuit
      {
        If ((A_TickCount - LastLogout) > 10000)
        {
          If !GameActive
            WinActivate, %GameStr%
          QuickPortal(True)
          LastLogout := A_TickCount
        }
      }
      Else If RadioNormalQuit
      {
        Send, {Enter}/exit{Enter}
        If RelogOnQuit
        {
          RandomSleep(300,400)
          ControlSend,, {Enter}, %GameStr%
        }
      }
      If (!RadioCi)
        Log("Exit with " . Player.Percent.Life . "`% Life", CurrentLocation)
      Else
        Log("Exit with " . Player.Percent.ES . "`% ES", CurrentLocation)
      Thread, NoTimers, False    ;End Critical
    return
    }

; AutoSkillUp - Check for gems that are ready to level up, and click them.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoSkillUp()
  {
    Static LastCheck:=0
    If (YesAutoSkillUp && OnChar && (A_TickCount - LastCheck > 200))
    {
      IfWinActive, ahk_group POEGameGroup 
      {
        If (YesWaitAutoSkillUp && (GetKeyState("LButton","P") || GetKeyState("RButton","P")))
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
; PoEWindowCheck - Check for the game window. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PoEWindowCheck()
  {
    Global GamePID, NoGame, GameActive, YesInGameOverlay, WR
    If (GamePID := WinExist(GameStr))
    {
      GameActive := WinActive(GameStr)
      WinGetPos, , , nGameW, nGameH
      newDim := (nGameW != GameW || nGameH != GameH)
      global RescaleRan, ToggleExist
      If (!GameBound || newDim )
      {
        GameBound := True
        BindWindow(GamePID)
        WinGet, s, Style, ahk_class POEWindowClass
        If (s & +0x80000000)
          WinSet, Style, -0x80000000, ahk_class POEWindowClass
      }
      If (!RescaleRan || newDim)
        Rescale()
      If ((!ToggleExist || newDim) && GameActive) 
      {
        Gui 2: Show,% "x" WR.loc.Gui.X " y" WR.loc.Gui.Y " NA", StatusOverlay
        GuiUpdate()
        ToggleExist := True
        NoGame := False
      }
      Else If (ToggleExist && !GameActive)
      {
        ToggleExist := False
        Gui 2: Show, Hide, StatusOverlay
      }
    } 
    Else 
    {
      If CheckTime("seconds",5,"CheckActiveType")
        CheckActiveType()
      If GameActive
        GameActive := False
      If GameBound
      {
        GameBound := False
        BindWindow()
      }
      If (ToggleExist)
      {
        Gui 2: Show, Hide, StatusOverlay
        ToggleExist := False
        RescaleRan := False
        NoGame := True
      }
      If (!AutoUpdateOff && ScriptUpdateTimeType != "Off" && ScriptUpdateTimeInterval != 0 && CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript"))
      {
        checkUpdate()
      }
    }
    Return
  }
  ShowHideOverlay(){
    Global overlayT1, overlayT2, overlayT3
    GuiControl,2: Show%YesInGameOverlay%, overlayT1
    GuiControl,2: Show%YesInGameOverlay%, overlayT2
    GuiControl,2: Show%YesInGameOverlay%, overlayT3
    Return
  }
; DBUpdateCheck - Check if the database should be updated 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DBUpdateCheck()
  {
    Global Date_now, LastDatabaseParseDate
    IfWinExist, ahk_group POEGameGroup 
    {
      Return
    } 
    Else If (YesNinjaDatabase && DaysSince())
    {
      For k, apiKey in apiList
        ScrapeNinjaData(apiKey)
      JSONtext := JSON.Dump(Ninja,,2)
      FileDelete, %A_ScriptDir%\data\Ninja.json
      FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
      IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
      LastDatabaseParseDate := Date_now
    }
    Return
  }
; MsgMonitor - Receive Messages from other scripts
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  MsgMonitor(wParam, lParam, msg)
    {
    ;; Thread, NoTimers, True    ;Critical
    If (wParam=1)
      Return
    Else If (wParam=2)
      Return
    Else If (wParam=3) {
      If (lParam=1){
        OnCooldown[1]:=1 
        settimer, TimerFlask1, %CooldownFlask1%
        return
        }    
      If (lParam=2){
        OnCooldown[2]:=1 
        settimer, TimerFlask2, %CooldownFlask2%
        return
        }    
      If (lParam=3){
        OnCooldown[3]:=1 
        settimer, TimerFlask3, %CooldownFlask3%
        return
        }    
      If (lParam=4){
        OnCooldown[4]:=1 
        settimer, TimerFlask4, %CooldownFlask4%
        return
        }    
      If (lParam=5){
        OnCooldown[5]:=1 
        settimer, TimerFlask5, %CooldownFlask5%
        return
        }    
      }
    Else If (wParam=4) {
      If (lParam=1){
        OnCooldownUtility1:=1 
        settimer, TimerUtility1, %CooldownUtility1%
        return
        }    
      If (lParam=2){
        OnCooldownUtility2:=1 
        settimer, TimerUtility2, %CooldownUtility2%
        return
        }    
      If (lParam=3){
        OnCooldownUtility3:=1 
        settimer, TimerUtility3, %CooldownUtility3%
        return
        }    
      If (lParam=4){
        OnCooldownUtility4:=1 
        settimer, TimerUtility4, %CooldownUtility4%
        return
        }    
      If (lParam=5){
        OnCooldownUtility5:=1 
        settimer, TimerUtility5, %CooldownUtility5%
        return
        }    
      }
    Else If (wParam=6) {
      If (lParam=1){
        ; hotkeyLogout
        LogoutCommand()
        return
        }    
      If (lParam=2){
        ; hotkeyPopFlasks
        PopFlasks()
        return
        }    
      If (lParam=3){
        ; hotkeyQuickPortal
        QuickPortal()
        return
        }    
      If (lParam=4){
        ; hotkeyGemSwap
        GemSwap()
        return
        }    
      If (lParam=5){
        ; hotkeyItemSort
        ItemSortCommand()
        return
        }    
      }
    Else If (wParam=7) {
      ;MsgBox, Ding
      LoadArray()
      ;Hotkeys()
      Return
    }
    Return
    }
; SendMSG - Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  SendMSG(wParam:=0, lParam:=0, script:="BlankSubscript.ahk ahk_exe AutoHotkey.exe"){
    DetectHiddenWindows On
    if WinExist(script) 
      PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
    ; else 
    ;   Log("Recipient Script Not Found",script) ;Error  information sent to log file
    DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
    Return
    }
; Coord - : Pixel information on Mouse Cursor, provides pixel location and RGB color hex
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Coord(){
    Global Picker
    CoordCommand:
    Rect := LetUserSelectRect(1)
    If (Rect)
    {
      T1 := A_TickCount
      Ding(10000,-11,"Building an average of area colors`nThis may take some time, press escape to skip calculation.")
      AvgColor := AverageAreaColor(Rect)
      Ding(100,-11,"")
      Clipboard := "Average Color of Area:  " AvgColor "`n`n" "X1:" Rect.X1 "`tY1:" Rect.Y1 "`tX2:" Rect.X2 "`tY2:" Rect.Y2
      Notify(Clipboard, "`nThis information has been placed in the clipboard`nCalculation Took " (T1 := A_TickCount - T1) " MS for " (T_Area := ((Rect.X2 - Rect.X1) * (Rect.Y2 - Rect.Y1))) " Pixels`n" Round(T1 / T_Area,3) " MS per pixel",5)
      Picker.SetColor(AvgColor)
    }
    Else 
      Ding(3000,-11,Clipboard "`nColor and Location copied to Clipboard")
    Return
  }

; Controller functions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Controller(inputType:="Main")
  {
    Static __init__ := XInput_Init()
    Static JoyLHoldCount:=0, JoyRHoldCount:=0,  JoyMultiplier := 4, YAxisMultiplier := .6
    Static x_POVscale := 5, y_POVscale := 5, HeldCountPOV := 0
    Global MainAttackPressedActive, SecondaryAttackPressedActive, MovementHotkeyActive, LootVacuumActive
    Global Controller, Controller_Active, YesOHBFound
    If (inputType = "Main")
    {
      If !Controller("Refresh")
        Return False
      Controller("JoystickL")
      Controller("JoystickR")
      Controller("Buttons")
      Controller("DPad")
    }
    If (inputType = "Refresh")
    {
      if State := XInput_GetState(Controller_Active) 
      {
        ; LX,LY,RX,RY,LT,RT,A,B,X,Y,LB,RB,L3,R3,BACK,START,UP,DOWN,LEFT,RIGHT
        Controller.LX             := PercentAxis( State.sThumbLX )
        Controller.LY             := PercentAxis( State.sThumbLY )
        Controller.RX             := PercentAxis( State.sThumbRX )
        Controller.RY             := PercentAxis( State.sThumbRY )
        Controller.LT             := State.bLeftTrigger
        Controller.RT             := State.bRightTrigger
        Controller.UP             := XInputButtonIsDown( "PovUp", State.wButtons )
        Controller.DOWN           := XInputButtonIsDown( "PovDown", State.wButtons )
        Controller.LEFT           := XInputButtonIsDown( "PovLeft", State.wButtons )
        Controller.RIGHT          := XInputButtonIsDown( "PovRight", State.wButtons )
        Controller.Btn.A          := XInputButtonIsDown( "A", State.wButtons )
        Controller.Btn.B          := XInputButtonIsDown( "B", State.wButtons )
        Controller.Btn.X          := XInputButtonIsDown( "X", State.wButtons )
        Controller.Btn.Y          := XInputButtonIsDown( "Y", State.wButtons )
        Controller.Btn.LB         := XInputButtonIsDown( "LB", State.wButtons )
        Controller.Btn.RB         := XInputButtonIsDown( "RB", State.wButtons )
        Controller.Btn.L3         := XInputButtonIsDown( "LStick", State.wButtons )
        Controller.Btn.R3         := XInputButtonIsDown( "RStick", State.wButtons )
        Controller.Btn.BACK       := XInputButtonIsDown( "Back", State.wButtons )
        Controller.Btn.START      := XInputButtonIsDown( "Start", State.wButtons )
      }
      Else
      {
        If !DetectJoystick()
          Return False
      }
    }
    Else If (inputType = "JoystickL")
    {
      moveX := DeadZone(Controller.LX)
      moveY := DeadZone(Controller.LY)
      If (moveX || moveY)
      {
        If !GuiStatus("",0)
          MouseMove,% ScrCenter.X + Controller.LX * (ScrCenter.X/100), % ScrCenter.Yadjusted - Controller.LY * (ScrCenter.Y/100)
        Else
          MouseMove,% ScrCenter.X + Controller.LX * (ScrCenter.X/120), % ScrCenter.Yadjusted - Controller.LY * (ScrCenter.Y/120)
        ++JoyLHoldCount
        If (!MovementHotkeyActive
        && JoyLHoldCount > 1
        && GuiStatus("",0)
        && ((YesOHB && (YesOHBFound || OnTown)) || !YesOHB) )
        {
          Click, Down
          MovementHotkeyActive := True
        }
        If (YesTriggerUtilityKey && MovementHotkeyActive
        && (Abs(Controller.LX) >= 60 || Abs(Controller.LY) >= 70 )
        && JoyLHoldCount > 3
        && GuiStatus("",0)
        && ((YesOHB && YesOHBFound) || !YesOHB) )
        {
          Trigger(WR.Utility[TriggerUtilityKey],"Utility")
        }
      }
      Else
      {
        If MovementHotkeyActive
        {
          Click, Up
          MovementHotkeyActive := False
        }
        JoyLHoldCount := 0
        Return
      }
    }
    Else If (inputType = "JoystickR")
    {
      moveX := DeadZone(Controller.RX)
      moveY := DeadZone(Controller.RY)
      If (moveX || moveY)
      {
        If (GuiStatus("",0) && ((YesOHB && (YesOHBFound || OnTown)) || !YesOHB))
        && !(Controller.LT || Controller.RT)
          MouseMove,% ScrCenter.X + Controller.RX * (ScrCenter.X/100), % ScrCenter.Yadjusted - Controller.RY * (ScrCenter.Y/100)
        Else
          MouseMove, % Controller.RX, % -Controller.RY,0,R
        ++JoyRHoldCount
        If (!MainAttackPressedActive && JoyRHoldCount > 2 && YesTriggerJoystickRightKey)
        && (GuiStatus("",0) && ((YesOHB && YesOHBFound) || !YesOHB))
        && !(Controller.LT || Controller.RT)
        {
          SendHotkey(hotkeyControllerJoystickRight,"down")
          MainAttackPressedActive := True
        }
      }
      Else
      {
        If (MainAttackPressedActive && YesTriggerJoystickRightKey)
        {
          SendHotkey(hotkeyControllerJoystickRight,"up")
          MainAttackPressedActive := False
        }
        JoyRHoldCount := 0
        Return
      }
    }
    Else If (inputType = "Buttons")
    {
      Static StateA := 0, StateB := 0, StateX := 0, StateY := 0, StateLB := 0, StateRB := 0, StateL3 := 0, StateR3 := 0, StateBACK := 0, StateSTART := 0
      For Key, s in Controller.Btn
      {
        If (s != State%Key%)
        {
          If (s && State%Key% = 0)
          {
            If (hotkeyControllerButton%Key% = hotkeyLootScan && LootVacuum)
            {
              SendHotkey(hotkeyControllerButton%Key%,"down")
              LootVacuumActive := True
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = "Logout")
            {
              SetTimer, LogoutCommand, -1
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = "PopFlasks")
            {
              SetTimer, PopFlasks, -1
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = "QuickPortal")
            {
              SetTimer, QuickPortal, -1
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = "GemSwap")
            {
              SetTimer, GemSwap, -1
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = "ItemSort")
            {
              SetTimer, ItemSortCommand, -1
              State%Key% := 1
            }
            Else If (hotkeyControllerButton%Key% = hotkeyMainAttack)
            {
              SendHotkey(hotkeyControllerButton%Key%,"down")
              State%Key% := 1
              MainAttackPressedActive := True
            }
            Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
            {
              SendHotkey(hotkeyControllerButton%Key%,"down")
              State%Key% := 1
              SecondaryAttackPressedActive := True
            }
            Else
            {
              SendHotkey(hotkeyControllerButton%Key%,"down")
              State%Key% := 1
            }
          }
          Else If (!s && State%Key% = 1)
          {
            If (hotkeyControllerButton%Key% = hotkeyLootScan && LootVacuum)
            {
              SendHotkey(hotkeyControllerButton%Key%,"up")
              LootVacuumActive := False
              State%Key% := 0
            }
            Else If (hotkeyControllerButton%Key% = "Logout")
              State%Key% := 0
            Else If (hotkeyControllerButton%Key% = "PopFlasks")
              State%Key% := 0
            Else If (hotkeyControllerButton%Key% = "QuickPortal")
              State%Key% := 0
            Else If (hotkeyControllerButton%Key% = "GemSwap")
              State%Key% := 0
            Else If (hotkeyControllerButton%Key% = "ItemSort")
              State%Key% := 0
            Else If (hotkeyControllerButton%Key% = hotkeyMainAttack)
            {
              SendHotkey(hotkeyControllerButton%Key%,"up")
              State%Key% := 0
              MainAttackPressedActive := 0
            }
            Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
            {
              SendHotkey(hotkeyControllerButton%Key%,"up")
              State%Key% := 0
              SecondaryAttackPressedActive := 0
            }
            Else
            {
              SendHotkey(hotkeyControllerButton%Key%,"up")
              State%Key% := 0
            }
          }
        }
      }
    }
    Else If (inputType = "DPad")
    {
      if (Controller.Up || Controller.Down || Controller.Left || Controller.Right)
      {
        If (GuiStatus("",0) && !YesXButtonFound)
        {
          if (Controller.Up) ; Up
            y_finalPOV := -y_POVscale-HeldCountPOV*2
          else if (Controller.Down) ; Down
            y_finalPOV := +y_POVscale+HeldCountPOV*2
          else
            y_finalPOV := 0
          if (Controller.Left) ; Left
            x_finalPOV := -x_POVscale-HeldCountPOV*2
          else if (Controller.Right) ; Right
            x_finalPOV := +x_POVscale+HeldCountPOV*2
          else
            x_finalPOV := 0
          If (x_finalPOV || y_finalPOV)
          {
            MouseMove, %x_finalPOV%, %y_finalPOV%, 0, R
            HeldCountPOV+=1
          }
        }
        Else
        {
          If Controller.Up
            SnapToInventoryGrid("Up")
          If Controller.Down
            SnapToInventoryGrid("Down")
          If Controller.Left
            SnapToInventoryGrid("Left")
          If Controller.Right
            SnapToInventoryGrid("Right")
        }
      }
      Else If (HeldCountPOV > 1)
      {
        HeldCountPOV := 0
      }
    }
    Return
  }
  DetectJoystick()
  {
    If XInput_GetState(Controller_Active)
      Return Controller_Active
    Else
    {
      Loop, 4
      {
        If XInput_GetState(A_Index)
        {
          Return Controller_Active := A_Index
        }
      }
      Return False
    }
  }
  DeadZone(val, deadzone:=10){
    Return (Abs(val)<deadzone?False:True)
  }
  CapRange(var,min:=0,max:=65535){
    return (var > max ? max : (var < min ? min : var))
  }
  PercentAxis(axisPos){
    If (axisPos = 0)
      Return False
    Else If (axisPos > 0)
      Positive := True
    Else
      Positive := False
    Percentage := Round((axisPos / (Positive?32767:32768)) * 100 ,6)
    Return Percentage 
  }
  SnapToInventoryGrid(Direction:="Left"){
    Global InvGrid
    Outside := False
    m := UpdateMousePosition()
    If !(OnStash || OnInventory)
      Return False
    If InArea(m.X,m.Y,InvGrid.Corners.Stash.X1,InvGrid.Corners.Stash.Y1,InvGrid.Corners.Stash.X2,InvGrid.Corners.Stash.Y2) && OnStash
    {
      gridArea := "StashQuad"
    }
    Else If InArea(m.X,m.Y,InvGrid.Corners.VendorRec.X1,InvGrid.Corners.VendorRec.Y1,InvGrid.Corners.VendorRec.X2,InvGrid.Corners.VendorRec.Y2) && OnVendor
    {
      gridArea := "VendorRec"
    }
    Else If InArea(m.X,m.Y,InvGrid.Corners.VendorOff.X1,InvGrid.Corners.VendorOff.Y1,InvGrid.Corners.VendorOff.X2,InvGrid.Corners.VendorOff.Y2) && OnVendor
    {
      gridArea := "VendorOff"
    }
    Else If InArea(m.X,m.Y,InvGrid.Corners.Inventory.X1,InvGrid.Corners.Inventory.Y1,InvGrid.Corners.Inventory.X2,InvGrid.Corners.Inventory.Y2) && OnInventory
    {
      gridArea := "Inventory"
    }
    Else If InArea(m.X,m.Y,GameX,GameY,GameX+GameW/2,GameY+GameH) ; On Left
    {
      If OnStash
        gridArea := "StashQuad"
      Else If OnVendor
        gridArea := "VendorOff"
      Else If OnInventory
        gridArea := "Inventory"
      Outside := True
    }
    Else If InArea(m.X,m.Y,GameX+GameW/2,GameY,GameX+GameW,GameY+GameH) ; On Right
    {
      If OnInventory
        gridArea := "Inventory"
      Else If OnStash
        gridArea := "StashQuad"
      Else If OnVendor
        gridArea := "VendorOff"
      Outside := True
    }
    gPos := GridPosition(m.X,m.Y,gridArea)

    If Outside
    {
      MoveToGridPosition(gPos.C,gPos.R,gridArea)
    }
    Else
      MoveToGridPosition(gPos.C,gPos.R,gridArea,Direction)
    return
  }
  MoveToGridPosition(c,r,gridArea:="StashQuad",Direction:="None"){
    Global InvGrid
    If (gridArea = "VendorOff" && r = 1 && Direction = "Up")
      gridArea := "VendorRec", r := 6
    Else If ( (gridArea = "VendorOff" || gridArea = "VendorRec") && c = 12 && Direction = "Right")
      gridArea := "Inventory", c := 0
    Else If (gridArea = "VendorRec" && r = 5 && Direction = "Down")
      gridArea := "VendorOff", r := 0
    Else If (gridArea = "Inventory" && c = 1 && Direction = "Left")
    {
      If OnStash
        gridArea := "StashQuad", c := 25
      Else If OnVendor
        gridArea := "VendorOff", c := 13
    }
    Else If (gridArea = "StashQuad" && c = 24 && Direction = "Right")
      gridArea := "Inventory", c := 0, r := (r//5>0?r//5:1)

    If (Direction = "Left")
      c := (c-1>0?c-1:c)
    Else If (Direction = "Right")
      c := (c+1<=InvGrid[gridArea].X.Count()?c+1:c)
    Else If (Direction = "Up")
      r := (r-1>0?r-1:r)
    Else If (Direction = "Down")
      r := (r+1<=InvGrid[gridArea].Y.Count()?r+1:r)

    MouseMove,% InvGrid[gridArea].X[c],% InvGrid[gridArea].Y[r]
    Return
  }
  GridPosition(x,y,gridArea:="StashQuad"){
    Global InvGrid
    sR := InvGrid.SlotSpacing + InvGrid.SlotRadius
    sRQ := InvGrid.SlotSpacing + InvGrid.SlotRadius//2
    Partial := {}
    Best := {"Distance":-1,"C":1,"R":1}

    For C, xVal in InvGrid[gridArea].X
    {
      For R, yVal in InvGrid[gridArea].Y
      {
        If (gridArea = "StashQuad")
        {
          x1:=xVal - sRQ, x2:=xVal + sRQ
          y1:=yVal - sRQ, y2:=yVal + sRQ
        }
        Else
        {
          x1:=xVal - sR, x2:=xVal + sR
          y1:=yVal - sR, y2:=yVal + sR
        }
        If InArea(x,y,x1,y1,x2,y2)
        {
          ; Notify("Mouse Exact","Grid C" C " R" R )
          Return {"C":C,"R":R}
        }
        Else
        {
          tempObj := {}
          tempObj.Distance := DistanceTo(x,y,xVal,yVal)
          tempObj.C := C
          tempObj.R := R
          Partial.Push(tempObj)
        }
      }
    }
    For k, match in Partial
    {
      If (Best.Distance = -1 || match.Distance <= Best.Distance)
        Best := match
    }
    Partial := ""
    ; Notify("Mouse Closest",Best.Distance " distance is C" Best.C " R" Best.R)
    Return Best
  }
  InArea(x,y,x1,y1,x2,y2){
    If ( (x >= x1) && (x <= x2) ) && ( (y >= y1) && (y <= y2) )
      Return True
    Else
      Return False
  }
  DistanceTo(x,y,px,py){
    Return (Abs(x-px) + Abs(y-py))
  }
  UpdateMousePosition(){
    Global mouseX, mouseY, mouseWin, mouseControl
    MouseGetPos, mouseX, mouseY, mouseWin, mouseControl
    ; tooltip, % mouseX " , " mouseY " - " mouseWin " : " mouseControl
    return {"X":mouseX,"Y":mouseY,"hWin":mouseWin,"Ctrl":mouseControl}
  }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Configuration handling, ini updates, Hotkey handling, Profiles, Calibration, Ignore list, Loot Filter, Webpages (MISC BACKEND)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { ; Read, Save, Load - Includes basic hotkey setup
    readFromFile(){
      global
      Thread, NoTimers, True    ;Critical

      LoadArray()
      Settings("Flask","Load")
      Settings("Utility","Load")
      Settings("perChar","Load")

      ; Login Information
      IniRead, PoESessionID, %A_ScriptDir%\save\Account.ini, GGG, PoESessionID, %A_Space%

      ; GUI Position
      IniRead, WinGuiX, %A_ScriptDir%\save\Settings.ini, General, WinGuiX, 0
      IniRead, WinGuiY, %A_ScriptDir%\save\Settings.ini, General, WinGuiY, 0

      ;General settings
      IniRead, BranchName, %A_ScriptDir%\save\Settings.ini, General, BranchName, master
      IniRead, ScriptUpdateTimeInterval, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval, 1
      IniRead, ScriptUpdateTimeType, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType, Off
      IniRead, Speed, %A_ScriptDir%\save\Settings.ini, General, Speed, 1
      IniRead, Tick, %A_ScriptDir%\save\Settings.ini, General, Tick, 50
      IniRead, QTick, %A_ScriptDir%\save\Settings.ini, General, QTick, 250
      IniRead, DebugMessages, %A_ScriptDir%\save\Settings.ini, General, DebugMessages, 0
      IniRead, YesTimeMS, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS, 0
      IniRead, YesLocation, %A_ScriptDir%\save\Settings.ini, General, YesLocation, 0
      IniRead, ShowPixelGrid, %A_ScriptDir%\save\Settings.ini, General, ShowPixelGrid, 0
      IniRead, ShowItemInfo, %A_ScriptDir%\save\Settings.ini, General, ShowItemInfo, 0
      IniRead, LootVacuum, %A_ScriptDir%\save\Settings.ini, General, LootVacuum, 0
      IniRead, YesVendor, %A_ScriptDir%\save\Settings.ini, General, YesVendor, 1
      IniRead, YesStash, %A_ScriptDir%\save\Settings.ini, General, YesStash, 1
      IniRead, YesHeistLocker, %A_ScriptDir%\save\Settings.ini, General, YesHeistLocker, 1
      IniRead, YesIdentify, %A_ScriptDir%\save\Settings.ini, General, YesIdentify, 1
      IniRead, YesDiv, %A_ScriptDir%\save\Settings.ini, General, YesDiv, 1
      IniRead, YesMapUnid, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid, 1
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
      IniRead, YesPersistantToggle, %A_ScriptDir%\save\Settings.ini, General, YesPersistantToggle, 0
      IniRead, YesGuiLastPosition, %A_ScriptDir%\save\Settings.ini, General, YesGuiLastPosition, 0
      IniRead, YesStashT1, %A_ScriptDir%\save\Settings.ini, General, YesStashT1, 1
      IniRead, YesStashT2, %A_ScriptDir%\save\Settings.ini, General, YesStashT2, 1
      IniRead, YesStashT3, %A_ScriptDir%\save\Settings.ini, General, YesStashT3, 1
      IniRead, YesStashT4, %A_ScriptDir%\save\Settings.ini, General, YesStashT4, 1
      IniRead, YesStashCraftingNormal, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingNormal, 1
      IniRead, YesStashCraftingMagic, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingMagic, 1
      IniRead, YesStashCraftingRare, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingRare, 1
      IniRead, YesStashCraftingIlvl, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvl, 0
      IniRead, YesStashCraftingIlvlMin, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvlMin, 76
      IniRead, YesSkipMaps, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps, 11
      IniRead, YesSkipMaps_eval, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval, >=
      IniRead, YesSkipMaps_normal, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal, 0
      IniRead, YesSkipMaps_magic, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic, 1
      IniRead, YesSkipMaps_rare, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare, 1
      IniRead, YesSkipMaps_unique, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique, 1
      IniRead, YesSkipMaps_tier, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier, 2
      IniRead, YesClickPortal, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal, 0
      IniRead, AreaScale, %A_ScriptDir%\save\Settings.ini, General, AreaScale, 60
      IniRead, LVdelay, %A_ScriptDir%\save\Settings.ini, General, LVdelay, 30
      IniRead, YesLootChests, %A_ScriptDir%\save\Settings.ini, General, YesLootChests, 1
      IniRead, YesLootDelve, %A_ScriptDir%\save\Settings.ini, General, YesLootDelve, 1
      IniRead, YesStashChaosRecipe, %A_ScriptDir%\save\Settings.ini, General, YesStashChaosRecipe, 0
      IniRead, YesFillMetamorph, %A_ScriptDir%\save\Settings.ini, General, YesFillMetamorph, 0
      IniRead, YesPredictivePrice, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice, Off
      IniRead, YesPredictivePrice_Percent_Val, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice_Percent_Val, 100
      IniRead, YesInGameOverlay, %A_ScriptDir%\save\Settings.ini, General, YesInGameOverlay, 1

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
        ;MODS
      IniRead, ElementalReflect, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ElementalReflect, 0
      IniRead, PhysicalReflect, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, PhysicalReflect, 0
      IniRead, NoRegen, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoRegen, 0
      IniRead, NoLeech, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoLeech, 0
      IniRead, AvoidAilments, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidAilments, 0
      IniRead, AvoidPBB, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidPBB, 0
      IniRead, LRRLES, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, LRRLES, 0    
      IniRead, MFAProjectiles, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MFAProjectiles, 0
      IniRead, MDExtraPhysicalDamage, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MDExtraPhysicalDamage, 0
      IniRead, MICSC, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MICSC, 0
      IniRead, MSCAT, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MSCAT, 0
      
      IniRead, MMapItemQuantity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity, 1
      IniRead, MMapItemRarity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity, 1
      IniRead, MMapMonsterPackSize, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize, 1
      IniRead, EnableMQQForMagicMap, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap, 0

      ;Automation Settings
      IniRead, YesEnableAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation, 0
      IniRead, FirstAutomationSetting, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting, %A_Space%
      IniRead, YesEnableNextAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation, 0
      IniRead, YesEnableLockerAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableLockerAutomation, 0
      IniRead, YesEnableAutoSellConfirmation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation, 0
      IniRead, YesEnableAutoSellConfirmationSafe, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmationSafe, 0
      
      ;Stash Tab Management
      IniRead, StashTabCurrency, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCurrency, 1
      IniRead, StashTabMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMap, 1
      IniRead, StashTabDivination, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDivination, 1
      IniRead, StashTabGem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGem, 1
      IniRead, StashTabGemQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemQuality, 1
      IniRead, StashTabFlaskQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFlaskQuality, 1
      IniRead, StashTabLinked, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabLinked, 1
      IniRead, StashTabCollection, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCollection, 1
      IniRead, StashTabUniqueRing, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueRing, 1
      IniRead, StashTabUniqueDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueDump, 1
      IniRead, StashTabInfluencedItem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabInfluencedItem, 1 
      IniRead, StashTabFragment, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFragment, 1
      IniRead, StashTabEssence, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabEssence, 1
      IniRead, StashTabBlight, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlight, 1
      IniRead, StashTabDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium, 1
      IniRead, StashTabDelve, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelve, 1
      IniRead, StashTabCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting, 1
      IniRead, StashTabProphecy, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabProphecy, 1
      IniRead, StashTabVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled, 1
      IniRead, StashTabMetamorph, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMetamorph, 1
      IniRead, StashTabYesMetamorph, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMetamorph, 0
      IniRead, StashTabGemSupport, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemSupport, 1
      IniRead, StashTabClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel, 1
      IniRead, StashTabYesClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesClusterJewel, 1
      IniRead, StashTabDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump, 1
      IniRead, StashTabYesCurrency, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency, 0
      IniRead, StashTabYesMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap, 0
      IniRead, StashTabYesDivination, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination, 0
      IniRead, StashTabYesGem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem, 1
      IniRead, StashTabYesGemQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemQuality, 1
      IniRead, StashTabYesGemSupport, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemSupport, 1
      IniRead, StashTabYesFlaskQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlaskQuality, 1
      IniRead, StashTabYesLinked, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked, 1
      IniRead, StashTabYesCollection, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCollection, 1
      IniRead, StashTabYesUniqueRing, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing, 1
      IniRead, StashTabYesUniqueDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump, 1
      IniRead, StashTabYesInfluencedItem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem, 1
      IniRead, StashTabYesFragment, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment, 0
      IniRead, StashTabYesEssence, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence, 0
      IniRead, StashTabYesBlight, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlight, 0
      IniRead, StashTabYesDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium, 0
      IniRead, StashTabYesDelve, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelve, 0
      IniRead, StashTabYesCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting, 1
      IniRead, StashTabYesProphecy, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesProphecy, 1
      IniRead, StashTabYesVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled, 1
      IniRead, StashTabYesDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump, 0
      IniRead, StashDumpInTrial, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial, 0
      IniRead, StashTabPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive, 1
      IniRead, StashTabYesPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive, 0
      IniRead, StashTabYesPredictive_Price, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive_Price, 5
      IniRead, StashTabGemVaal, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemVaal, 1
      IniRead, StashTabYesGemVaal, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemVaal, 0
      IniRead, StashTabNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice, 1
      IniRead, StashTabYesNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice, 0
      IniRead, StashTabYesNinjaPrice_Price, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price, 5
      
      ; Chaos Recipe Settings
      IniRead, ChaosRecipeEnableFunction, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeEnableFunction, 0
      IniRead, ChaosRecipeSkipJC, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeSkipJC, 1
      IniRead, ChaosRecipeEnableUnId, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeEnableUnId, 1
      IniRead, ChaosRecipeLimitUnId, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeLimitUnId, 1
      IniRead, ChaosRecipeAllowDoubleJewellery, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeAllowDoubleJewellery, 1
      IniRead, ChaosRecipeMaxHolding, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeMaxHolding, 10
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


      ;Custom Crafting Bases
      ;loading default list
      sDefaultcraftingBasesT1 := ArrayToString(DefaultcraftingBasesT1)
      sDefaultcraftingBasesT2 := ArrayToString(DefaultcraftingBasesT2)
      sDefaultcraftingBasesT3 := ArrayToString(DefaultcraftingBasesT3)
      sDefaultcraftingBasesT4 := ArrayToString(DefaultcraftingBasesT4)
      IniRead, craftingBasesT1, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT1, %sDefaultcraftingBasesT1%
      IniRead, craftingBasesT2, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT2, %sDefaultcraftingBasesT2%
      IniRead, craftingBasesT3, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT3, %sDefaultcraftingBasesT3%
      IniRead, craftingBasesT4, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT4, %sDefaultcraftingBasesT4%
      ;converting string to array
      craftingBasesT1 := StringToArray(craftingBasesT1)
      craftingBasesT2 := StringToArray(craftingBasesT2)
      craftingBasesT3 := StringToArray(craftingBasesT3)
      craftingBasesT4 := StringToArray(craftingBasesT4)
      
      ;Settings for the Client Log file location
      IniRead, ClientLog, %A_ScriptDir%\save\Settings.ini, Log, ClientLog, %ClientLog%
      
      ;Settings for the Overhead Health Bar
      IniRead, YesOHB, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB, 1
      
      ;OHB Colors
      IniRead, OHBLHealthHex, %A_ScriptDir%\save\Settings.ini, OHB, OHBLHealthHex, 0x19A631

      ;Ascii strings
      IniRead, HealthBarStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, HealthBarStr, %1080_HealthBarStr%
      If HealthBarStr
      {
        HealthBarStr := """" . HealthBarStr . """"
        OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
      }
      IniRead, ChestStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, ChestStr, %1080_ChestStr%
      If ChestStr
        ChestStr := """" . ChestStr . """"
      IniRead, DelveStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, DelveStr, %1080_DelveStr%
      If DelveStr
        DelveStr := """" . DelveStr . """"
      IniRead, VendorStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorStr, %1080_MasterStr%
      If VendorStr
        VendorStr := """" . VendorStr . """"
      IniRead, SellItemsStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, SellItemsStr, %1080_SellItemsStr%
      If SellItemsStr
        SellItemsStr := """" . SellItemsStr . """"
      IniRead, StashStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, StashStr, %1080_StashStr%
      If StashStr
        StashStr := """" . StashStr . """"
      IniRead, HeistLockerStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, HeistLockerStr, %1080_HeistLockerStr%
      If HeistLockerStr
        HeistLockerStr := """" . HeistLockerStr . """"
      IniRead, SkillUpStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, SkillUpStr, %1080_SkillUpStr%
      If SkillUpStr
        SkillUpStr := """" . SkillUpStr . """"
      IniRead, XButtonStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, XButtonStr, %1080_XButtonStr%
      If XButtonStr
        XButtonStr := """" . XButtonStr . """"
      IniRead, VendorLioneyeStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorLioneyeStr, %1080_BestelStr%
      If VendorLioneyeStr
        VendorLioneyeStr := """" . VendorLioneyeStr . """"
      IniRead, VendorForestStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorForestStr, %1080_GreustStr%
      If VendorForestStr
        VendorForestStr := """" . VendorForestStr . """"
      IniRead, VendorSarnStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorSarnStr, %1080_ClarissaStr%
      If VendorSarnStr
        VendorSarnStr := """" . VendorSarnStr . """"
      IniRead, VendorHighgateStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorHighgateStr, %1080_PetarusStr%
      If VendorHighgateStr
        VendorHighgateStr := """" . VendorHighgateStr . """"
      IniRead, VendorOverseerStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorOverseerStr, %1080_LaniStr%
      If VendorOverseerStr
        VendorOverseerStr := """" . VendorOverseerStr . """"
      IniRead, VendorBridgeStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorBridgeStr, %1080_HelenaStr%
      If VendorBridgeStr
        VendorBridgeStr := """" . VendorBridgeStr . """"
      IniRead, VendorDocksStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorDocksStr, %1080_LaniStr%
      If VendorDocksStr
        VendorDocksStr := """" . VendorDocksStr . """"
      IniRead, VendorOriathStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorOriathStr, %1080_LaniStr%
      If VendorOriathStr
        VendorOriathStr := """" . VendorOriathStr . """"
      IniRead, VendorMineStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorMineStr, %1080_MasterStr%
      If VendorMineStr
        VendorMineStr := """" . VendorMineStr . """"

      ;Inventory Colors
      IniRead, varEmptyInvSlotColor, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor, 0x000100,0x020402,0x000000,0x020302,0x010101,0x010201,0x060906,0x050905,0x030303,0x020202
      ;Create an array out of the read string
      varEmptyInvSlotColor := StrSplit(varEmptyInvSlotColor, ",")

      ;Loot Vacuum Colors
      IniRead, LootColors, %A_ScriptDir%\save\Settings.ini, Loot Colors, LootColors, 0xF6FEC4,0xCCFE99,0xFEFE9E,0xFADF72,0xA36565,0x773838
      ;Create an array out of the read string
      LootColors := StrSplit(LootColors, ",")

      ;Failsafe Colors
      IniRead, varOnMenu, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu, 0xD6B97B
      IniRead, varOnChar, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar, 0x6B5543
      IniRead, varOnChat, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat, 0x88623B
      IniRead, varOnInventory, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory, 0xDCC289
      IniRead, varOnStash, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash, 0xECDBA6
      IniRead, varOnVendor, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor, 0xCEB178
      IniRead, varOnDiv, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv, 0xF6E2C5
      IniRead, varOnLeft, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft, 0xB58C4D
      IniRead, varOnDelveChart, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart, 0xE5B93F
      IniRead, varOnMetamorph, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMetamorph, 0xE06718
      IniRead, varOnLocker, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLocker, 0x1F2732
      IniRead, varOnDetonate, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate, 0x5D4661
            
      ;Grab Currency From Inventory
      IniRead, GrabCurrencyPosX, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosX, 1877
      IniRead, GrabCurrencyPosY, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosY, 772

      ;Coordinates
      IniRead, PortalScrollX, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollX, 1825
      IniRead, PortalScrollY, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollY, 825
      IniRead, WisdomScrollX, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollX, 1875
      IniRead, WisdomScrollY, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollY, 825
      IniRead, StockPortal, %A_ScriptDir%\save\Settings.ini, Coordinates, StockPortal, 0
      IniRead, StockWisdom, %A_ScriptDir%\save\Settings.ini, Coordinates, StockWisdom, 0
      
      ;~ hotkeys reset
      hotkey, IfWinActive, ahk_group POEGameGroup
      If hotkeyAutoQuit
        hotkey,% hotkeyAutoQuit, AutoQuitCommand, Off
      If hotkeyAutoFlask
        hotkey,% hotkeyAutoFlask, AutoFlaskCommand, Off
      If hotkeyAutoQuicksilver
        hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, Off
      If hotkeyQuickPortal
        hotkey,% hotkeyQuickPortal, QuickPortalCommand, Off
      If hotkeyGemSwap
        hotkey,% hotkeyGemSwap, GemSwapCommand, Off
      If hotkeyStartCraft
        hotkey,% hotkeyStartCraft, Crafting, Off
      If hotkeyCraftBasic
        hotkey,% hotkeyCraftBasic, CraftBasicPopUp, Off
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
        hotkey, $~%hotkeyLootScan% Up, LootScanCommandRelease, Off
      }
      If hotkeyPauseMines
        hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, Off
      If hotkeyMainAttack
      {
        hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
        hotkey, $~%hotkeyMainAttack% Up, MainAttackCommandRelease, Off
      }
      If hotkeySecondaryAttack
      {
        hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off
        hotkey, $~%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, Off
      }

      hotkey, IfWinActive
      If hotkeyOptions
        hotkey,% hotkeyOptions, optionsCommand, Off
      hotkey, IfWinActive, ahk_group POEGameGroup
        
      ;~ hotkeys iniread
      IniRead, hotkeyOptions, %A_ScriptDir%\save\Settings.ini, hotkeys, Options, !F10
      IniRead, hotkeyAutoQuit, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuit, !F12
      IniRead, hotkeyAutoFlask, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoFlask, !F11
      IniRead, hotkeyAutoQuicksilver, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuicksilver, !MButton
      IniRead, hotkeyQuickPortal, %A_ScriptDir%\save\Settings.ini, hotkeys, QuickPortal, !q
      IniRead, hotkeyStartCraft, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft, F7
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
      IniRead, hotkeyPauseMines, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyPauseMines, d
      IniRead, hotkeyMainAttack, %A_ScriptDir%\save\Settings.ini, hotkeys, MainAttack, RButton
      IniRead, hotkeySecondaryAttack, %A_ScriptDir%\save\Settings.ini, hotkeys, SecondaryAttack, w
      IniRead, hotkeyTriggerMovement, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyTriggerMovement, LButton
      
      hotkey, IfWinActive, ahk_group POEGameGroup
      If hotkeyAutoQuit
        hotkey,% hotkeyAutoQuit, AutoQuitCommand, On
      If hotkeyAutoFlask
        hotkey,% hotkeyAutoFlask, AutoFlaskCommand, On
      If hotkeyAutoQuicksilver
        hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On
      If hotkeyQuickPortal
        hotkey,% hotkeyQuickPortal, QuickPortalCommand, On
      If hotkeyGemSwap
        hotkey,% hotkeyGemSwap, GemSwapCommand, On
      If hotkeyStartCraft
        hotkey,% hotkeyStartCraft, Crafting, On
      If hotkeyCraftBasic
        hotkey,% hotkeyCraftBasic, CraftBasicPopUp, On
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
        hotkey, $~%hotkeyLootScan% Up, LootScanCommandRelease, On
      }
      If hotkeyMainAttack
      {
        hotkey, $~%hotkeyMainAttack%, MainAttackCommand, On
        hotkey, $~%hotkeyMainAttack% Up, MainAttackCommandRelease, On
      }
      If hotkeySecondaryAttack
      {
        hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, On
        hotkey, $~%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, On
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

      IniRead, stashReset, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashReset, NumpadDot
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
      IniRead, selectedLeague, %A_ScriptDir%\save\Settings.ini, Database, selectedLeague, Heist
      IniRead, UpdateDatabaseInterval, %A_ScriptDir%\save\Settings.ini, Database, UpdateDatabaseInterval, 2
      IniRead, YesNinjaDatabase, %A_ScriptDir%\save\Settings.ini, Database, YesNinjaDatabase, 1
      IniRead, ForceMatch6Link, %A_ScriptDir%\save\Settings.ini, Database, ForceMatch6Link, 0
      IniRead, ForceMatchGem20, %A_ScriptDir%\save\Settings.ini, Database, ForceMatchGem20, 0

      If (YesPersistantToggle)
      {
        IniRead, AutoQuit, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuit, 0
        IniRead, AutoFlask, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoFlask, 0
        IniRead, AutoQuick, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuick, 0
      }

      UnRegisterHotkeys()
      RegisterHotkeys()
      checkActiveType()
      Thread, NoTimers, False    ;End Critical
    Return
    }

    submit(){  
    updateEverything:
      global
      Thread, NoTimers, True    ;Critical

      IniWrite, %PoESessionID%, %A_ScriptDir%\save\Account.ini, GGG, PoESessionID
      Settings("Flask","Save")
      Settings("Utility","Save")

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
        hotkey,% hotkeyAutoQuit, AutoQuitCommand, Off
      If hotkeyAutoFlask
        hotkey,% hotkeyAutoFlask, AutoFlaskCommand, Off
      If hotkeyQuickPortal
        hotkey,% hotkeyQuickPortal, QuickPortalCommand, Off
      If hotkeyGemSwap
        hotkey,% hotkeyGemSwap, GemSwapCommand, Off
      If hotkeyStartCraft
        hotkey,% hotkeyStartCraft, Crafting, Off
      If hotkeyCraftBasic
        hotkey,% hotkeyCraftBasic, CraftBasicPopUp, Off
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
        hotkey, $~%hotkeyLootScan% Up, LootScanCommandRelease, Off
      }
      If hotkeyPauseMines
        hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, Off
      If hotkeyMainAttack
      {
        hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
        hotkey, $~%hotkeyMainAttack% Up, MainAttackCommandRelease, Off
      }
      If hotkeySecondaryAttack
      {
        hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off
        hotkey, $~%hotkeySecondaryAttack% Up, SecondaryAttackCommandRelease, Off
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
        Gui 2: Show,% "x" WR.loc.Gui.X " y" WR.loc.Gui.Y, StatusOverlay
        ToggleExist := True
        WinActivate, ahk_group POEGameGroup
      }

      Gui, Submit, NoHide

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
      IniWrite, %YesHeistLocker%, %A_ScriptDir%\save\Settings.ini, General, YesHeistLocker
      IniWrite, %YesIdentify%, %A_ScriptDir%\save\Settings.ini, General, YesIdentify
      IniWrite, %YesDiv%, %A_ScriptDir%\save\Settings.ini, General, YesDiv
      IniWrite, %YesMapUnid%, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid
      IniWrite, %YesCLFIgnoreImplicit%, %A_ScriptDir%\save\Settings.ini, General, YesCLFIgnoreImplicit
      IniWrite, %YesSortFirst%, %A_ScriptDir%\save\Settings.ini, General, YesSortFirst
      IniWrite, %Latency%, %A_ScriptDir%\save\Settings.ini, General, Latency
      IniWrite, %ClickLatency%, %A_ScriptDir%\save\Settings.ini, General, ClickLatency
      IniWrite, %ClipLatency%, %A_ScriptDir%\save\Settings.ini, General, ClipLatency
      IniWrite, %ShowOnStart%, %A_ScriptDir%\save\Settings.ini, General, ShowOnStart
      IniWrite, %PopFlaskRespectCD%, %A_ScriptDir%\save\Settings.ini, General, PopFlaskRespectCD
      IniWrite, %EnableChatHotkeys%, %A_ScriptDir%\save\Settings.ini, General, EnableChatHotkeys
      IniWrite, %YesStashKeys%, %A_ScriptDir%\save\Settings.ini, General, YesStashKeys
      IniWrite, %YesStashT1%, %A_ScriptDir%\save\Settings.ini, General, YesStashT1
      IniWrite, %YesStashT2%, %A_ScriptDir%\save\Settings.ini, General, YesStashT2
      IniWrite, %YesStashT3%, %A_ScriptDir%\save\Settings.ini, General, YesStashT3
      IniWrite, %YesStashT4%, %A_ScriptDir%\save\Settings.ini, General, YesStashT4
      IniWrite, %YesStashCraftingNormal%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingNormal
      IniWrite, %YesStashCraftingMagic%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingMagic
      IniWrite, %YesStashCraftingRare%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingRare
      IniWrite, %YesStashCraftingIlvl%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvl
      IniWrite, %YesStashCraftingIlvlMin%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvlMin
      IniWrite, %YesSkipMaps%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps
      IniWrite, %YesSkipMaps_eval%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval
      IniWrite, %YesSkipMaps_normal%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal
      IniWrite, %YesSkipMaps_magic%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic
      IniWrite, %YesSkipMaps_rare%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare
      IniWrite, %YesSkipMaps_unique%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique
      IniWrite, %YesSkipMaps_tier%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier
      IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
      IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
      IniWrite, %YesClickPortal%, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal

      ; Overhead Health Bar
      IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB

      ; ASCII Search Strings
      IniWrite, %HealthBarStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, HealthBarStr
      IniWrite, %VendorStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorStr
      IniWrite, %SellItemsStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SellItemsStr
      IniWrite, %StashStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, StashStr
      IniWrite, %HeistLockerStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, HeistLockerStr
      IniWrite, %SkillUpStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SkillUpStr

      ;~ Hotkeys 
      IniWrite, %hotkeyOptions%, %A_ScriptDir%\save\Settings.ini, hotkeys, Options
      IniWrite, %hotkeyAutoQuit%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuit
      IniWrite, %hotkeyAutoFlask%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoFlask
      IniWrite, %hotkeyAutoQuicksilver%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuicksilver
      IniWrite, %hotkeyQuickPortal%, %A_ScriptDir%\save\Settings.ini, hotkeys, QuickPortal
      IniWrite, %hotkeyGemSwap%, %A_ScriptDir%\save\Settings.ini, hotkeys, GemSwap
      IniWrite, %hotkeyStartCraft%, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft
      IniWrite, %hotkeyCraftBasic%, %A_ScriptDir%\save\Settings.ini, hotkeys, CraftBasic
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
      IniWrite, %hotkeyPauseMines%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyPauseMines
      IniWrite, %hotkeyMainAttack%, %A_ScriptDir%\save\Settings.ini, hotkeys, MainAttack
      IniWrite, %hotkeySecondaryAttack%, %A_ScriptDir%\save\Settings.ini, hotkeys, SecondaryAttack
      IniWrite, %hotkeyTriggerMovement%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyTriggerMovement
      
      ;Utility Keys
      IniWrite, %hotkeyUp%,     %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyUp
      IniWrite, %hotkeyDown%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyDown
      IniWrite, %hotkeyLeft%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyLeft
      IniWrite, %hotkeyRight%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyRight
      
      ;Grab Currency
      IniWrite, %GrabCurrencyPosX%, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosX
      IniWrite, %GrabCurrencyPosY%, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosY

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

        ;MODS
      IniWrite, %ElementalReflect%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ElementalReflect
      IniWrite, %PhysicalReflect%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, PhysicalReflect
      IniWrite, %NoRegen%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoRegen
      IniWrite, %NoLeech%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoLeech
      IniWrite, %AvoidAilments%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidAilments
      IniWrite, %AvoidPBB%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidPBB
      IniWrite, %MinusMPR%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MinusMPR
      IniWrite, %LRRLES%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, LRRLES
      IniWrite, %MFAProjectiles%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MFAProjectiles
      IniWrite, %MDExtraPhysicalDamage%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MDExtraPhysicalDamage
      IniWrite, %MICSC%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MICSC
      IniWrite, %MSCAT%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MSCAT

      IniWrite, %MMapItemQuantity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity
      IniWrite, %MMapItemRarity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity
      IniWrite, %MMapMonsterPackSize%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize
      IniWrite, %EnableMQQForMagicMap%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap
      
      ;~ Scroll locations
      IniWrite, %PortalScrollX%, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollX
      IniWrite, %PortalScrollY%, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollY
      IniWrite, %WisdomScrollX%, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollX
      IniWrite, %WisdomScrollY%, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollY
      IniWrite, %StockPortal%, %A_ScriptDir%\save\Settings.ini, Coordinates, StockPortal
      IniWrite, %StockWisdom%, %A_ScriptDir%\save\Settings.ini, Coordinates, StockWisdom
      
      ;Stash Tab Management
      IniWrite, %StashTabCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCurrency
      IniWrite, %StashTabMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMap
      IniWrite, %StashTabDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDivination
      IniWrite, %StashTabGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGem
      IniWrite, %StashTabGemQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemQuality
      IniWrite, %StashTabFlaskQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFlaskQuality
      IniWrite, %StashTabLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabLinked
      IniWrite, %StashTabCollection%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCollection
      IniWrite, %StashTabUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueRing
      IniWrite, %StashTabUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueDump
      IniWrite, %StashTabInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabInfluencedItem
      IniWrite, %StashTabFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFragment
      IniWrite, %StashTabEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabEssence
      IniWrite, %StashTabBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlight
      IniWrite, %StashTabDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium
      IniWrite, %StashTabYesMetamorph%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMetamorph
      IniWrite, %StashTabDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelve
      IniWrite, %StashTabCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting
      IniWrite, %StashTabProphecy%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabProphecy
      IniWrite, %StashTabVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled
      IniWrite, %StashTabClusterJewel%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel
      IniWrite, %StashTabDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump
      IniWrite, %StashTabYesCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency
      IniWrite, %StashTabYesMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap
      IniWrite, %StashTabYesDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination
      IniWrite, %StashTabYesGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem
      IniWrite, %StashTabYesGemQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemQuality
      IniWrite, %StashTabYesGemSupport%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemSupport
      IniWrite, %StashTabYesFlaskQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlaskQuality
      IniWrite, %StashTabYesLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked
      IniWrite, %StashTabYesCollection%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCollection
      IniWrite, %StashTabYesUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing
      IniWrite, %StashTabYesUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump
      IniWrite, %StashTabYesInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem
      IniWrite, %StashTabYesBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlight
      IniWrite, %StashTabYesDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium
      IniWrite, %StashTabYesFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment
      IniWrite, %StashTabYesEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence
      IniWrite, %StashTabYesDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelve
      IniWrite, %StashTabYesCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting
      IniWrite, %StashTabYesProphecy%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesProphecy
      IniWrite, %StashTabYesVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled
      IniWrite, %StashTabYesDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump
      IniWrite, %StashDumpInTrial%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial
      IniWrite, %StashTabPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive
      IniWrite, %StashTabYesPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive
      IniWrite, %StashTabYesPredictive_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive_Price
      IniWrite, %StashTabGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemVaal
      IniWrite, %StashTabYesGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemVaal
      IniWrite, %StashTabNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice
      IniWrite, %StashTabYesNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice
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

      IniWrite, %stashReset%, %A_ScriptDir%\save\Settings.ini, Stash Hotkeys, stashReset
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

      ;Custom Crafting Bases
      scraftingBasesT1 := ArrayToString(craftingBasesT1)
      scraftingBasesT2 := ArrayToString(craftingBasesT2)
      scraftingBasesT3 := ArrayToString(craftingBasesT3)
      scraftingBasesT4 := ArrayToString(craftingBasesT4)
      IniWrite, %scraftingBasesT1%, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT1
      IniWrite, %scraftingBasesT2%, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT2
      IniWrite, %scraftingBasesT3%, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT3
      IniWrite, %scraftingBasesT4%, %A_ScriptDir%\save\Settings.ini, Custom Crafting Bases, craftingBasesT4

      readFromFile()
      GuiUpdate()
      IfWinExist, ahk_group POEGameGroup
        {
        WinActivate, ahk_group POEGameGroup
        }
      ; SendMSG(1)
      Thread, NoTimers, False    ;End Critical
    return  
    }

    ; Settings Save/Load
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Settings(name:="perChar",Action:="Load"){
      If (Action = "Load"){
        IfNotExist, %A_ScriptDir%\save\%name%.json
          Return False
        FileRead, JSONtext, %A_ScriptDir%\save\%name%.json
        obj := JSON.Load(JSONtext)
        For k, v in WR[name]
          If (IsObject(obj[k]))
            For l, w in v
              If (obj[k].HasKey(l)) 
                WR[name][k][l] := obj[k][l]
        obj := JSONtext := ""
      } Else If (Action = "Save"){
        FileDelete, %A_ScriptDir%\save\%name%.json
        JSONtext := JSON.Dump(WR[name],,2)
        FileAppend, %JSONtext%, %A_ScriptDir%\save\%name%.json
        JSONtext := ""
      }
    }
    ; Profile Save/Load/Remove
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Profile(){
      Gui, submit, nohide
      split := StrSplit(A_GuiControl,"_")
      Type := split[2]
      Action := split[3]
      ControlGetText, name,% ProfileMenu%Type%
      If (name = "")
      {
        MsgBox, 262144, Whoah there clicky fingers, Profile name cannot be blank
        Return
      }
      If FileExist( A_ScriptDir "\save\profiles\" Type "\" name ".json")
      {
        ; If indexOf(Action,["Save","Remove"])
        MsgBox, 262148, Whoah there clicky fingers, Please confirm you want to %Action% the %name% Profile
        IfMsgBox No
          Return
      } Else If (Action != "Save") {
        MsgBox, 262144, Whoah there clicky fingers, Cannot %Action% the %name% Profile. The file does not exist.
        Return
      }

      If (Action = "Save")
      {
        FileDelete, %A_ScriptDir%\save\profiles\%Type%\%name%.json
        JSONtext := JSON.Dump(WR[Type],,2)
        FileAppend, %JSONtext%, %A_ScriptDir%\save\profiles\%Type%\%name%.json
      }
      Else If (Action = "Load")
      {
        FileRead, JSONtext, %A_ScriptDir%\save\profiles\%Type%\%name%.json
        obj := JSON.Load(JSONtext)
        For k, v in WR[Type]
          If (IsObject(obj[k]))
            For l, w in v
              If (obj[k].HasKey(l)) 
                WR[Type][k][l] := obj[k][l]
        Return
      }
      Else If (Action = "Remove")
      {
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

  }

  { ; Hotkeys with modifiers - RegisterHotkeys, 1HotkeyShouldFire, 2HotkeyShouldFire, stashHotkeyShouldFire

    
    ; Register and UnRegister Hotkeys - Register Chat and Stash Hotkeys
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RegisterHotkeys() {
      global
      Gui Submit, NoHide

      fn1 := Func("1HotkeyShouldFire").Bind(1Prefix1,1Prefix2,EnableChatHotkeys)
      Hotkey If, % fn1
      Loop, 9 {
        If 1Suffix%A_Index%
        {
          1bind%A_Index% := Func("FireHotkey").Bind("Enter","1",A_Index)
          Hotkey,% "*" 1Suffix%A_Index%,% 1bind%A_Index%, On
        }
      }
      fn2 := Func("2HotkeyShouldFire").Bind(2Prefix1,2Prefix2,EnableChatHotkeys)
      Hotkey If, % fn2
      Loop, 9 {
        If 2Suffix%A_Index%
        {
          2bind%A_Index% := Func("FireHotkey").Bind("CtrlEnter","2",A_Index)
          Hotkey,% "*" 2Suffix%A_Index%,% 2bind%A_Index%, On
        }
      }
      fn3 := Func("stashHotkeyShouldFire").Bind(stashPrefix1,stashPrefix2,YesStashKeys)
      Hotkey If, % fn3
      Loop, 9 {
        If stashSuffix%A_Index%
        {
          stashbind%A_Index% := Func("FireHotkey").Bind("Stash","stash", "Tab" A_Index)
          Hotkey,% "~*" stashSuffix%A_Index%,% stashbind%A_Index%, On
        }
      }
      If stashReset
        Hotkey,% "~*" stashReset, FireStashReset, On
      Return
    }
    UnRegisterHotkeys(){
      global
      Hotkey If, % fn1
        Loop, 9
        {
          If 1Suffix%A_Index%
          {
            1bind%A_Index% := Func("FireHotkey").Bind("Enter","1",A_Index)
            Hotkey,% "*" 1Suffix%A_Index%,% 1bind%A_Index%, off
          }
        }
      Hotkey If, % fn2
        Loop, 9
        {
          If 2Suffix%A_Index%
          {
            2bind%A_Index% := Func("FireHotkey").Bind("CtrlEnter","2",A_Index)
            Hotkey,% "*" 2Suffix%A_Index%,% 2bind%A_Index%, off
          }
        }
      Hotkey If, % fn3
        Loop, 9
        {
          If stashSuffix%A_Index%
          {
            stashbind%A_Index% := Func("FireHotkey").Bind("Stash","stash", "Tab" A_Index)
            Hotkey,% "*" stashSuffix%A_Index%,% stashbind%A_Index%, off
          }
        }
        If stashReset
          Hotkey, *%stashReset%, FireStashReset, off
      Return
    }
    ; HotkeyShouldFire - Functions to evaluate keystate
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    1HotkeyShouldFire(1Prefix1, 1Prefix2, EnableChatHotkeys, thisHotkey) {
      IfWinActive, ahk_group POEGameGroup
        {
        If (EnableChatHotkeys){
          If ( 1Prefix1 && 1Prefix2 ){
            If ( GetKeyState(1Prefix1) && GetKeyState(1Prefix2) )
              return True
            Else
              return False
            }
          Else If ( 1Prefix1 && !1Prefix2 ) {
            If ( GetKeyState(1Prefix1) ) 
              return True
            Else
              return False
            }
          Else If ( !1Prefix1 && 1Prefix2 ) {
            If ( GetKeyState(1Prefix2) ) 
              return True
            Else
              return False
            }
          Else If ( !1Prefix1 && !1Prefix2 ) {
            return True
            }
          } 
        }
        Else {
          Return False
        }
    }
    2HotkeyShouldFire(2Prefix1, 2Prefix2, EnableChatHotkeys, thisHotkey) {
      IfWinActive, ahk_group POEGameGroup
        {
        If (EnableChatHotkeys){
          If ( 2Prefix1 && 2Prefix2 ){
            If ( GetKeyState(2Prefix1) && GetKeyState(2Prefix2) )
              return True
            Else
              return False
            }
          Else If ( 2Prefix1 && !2Prefix2 ) {
            If ( GetKeyState(2Prefix1) ) 
              return True
            Else
              return False
            }
          Else If ( !2Prefix1 && 2Prefix2 ) {
            If ( GetKeyState(2Prefix2) ) 
              return True
            Else
              return False
            }
          Else If ( !2Prefix1 && !2Prefix2 ) {
            return True
            }
          }
        Else
          Return False 
        }
      Else {
          Return False
        }
    }
    stashHotkeyShouldFire(stashPrefix1, stashPrefix2, YesStashKeys, thisHotkey) {
      IfWinActive, ahk_group POEGameGroup
      {
        If (YesStashKeys){
          If ( stashPrefix1 && stashPrefix2 ){
            If ( GetKeyState(stashPrefix1) && GetKeyState(stashPrefix2) )
              return True
            Else
              return False
            }
          Else If ( stashPrefix1 && !stashPrefix2 ) {
            If ( GetKeyState(stashPrefix1) ) 
              return True
            Else
              return False
            }
          Else If ( !stashPrefix1 && stashPrefix2 ) {
            If ( GetKeyState(stashPrefix2) ) 
              return True
            Else
              return False
            }
          Else If ( !stashPrefix1 && !stashPrefix2 ) {
            return True
            }
        }
        Else
          Return False 
      }
      Else {
          Return False
      }
    }

    ; FireHotkey - Functions to Send each hotkey
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FireHotkey(func:="CtrlEnter",TypePrefix:="2",SuffixNum:="1"){
      ; Enter func is Prefix 1, CtrlEnter func is Prefix 2
      ; Stash func is Prefix stash with SuffixNum of Tab#
      IfWinActive, ahk_group POEGameGroup
      {
        If (func = "Enter")
        {
          tempStr := StrReplace(%TypePrefix%Suffix%SuffixNum%Text, "CharacterName", CharName, 0, -1)
          tempStr := StrReplace(tempStr, "RecipientName", RecipientName, 0, -1)
          tempStr := StrReplace(tempStr, "!", "{!}", 0, -1)
          Send, {Enter}%tempStr%{Enter}
          ResetChat()
        }
        Else If (func = "CtrlEnter")
        {
          GrabRecipientName()
          tempStr := StrReplace(%TypePrefix%Suffix%SuffixNum%Text, "CharacterName", CharName, 0, -1)
          tempStr := StrReplace(tempStr, "RecipientName", RecipientName, 0, -1)
          tempStr := StrReplace(tempStr, "!", "{!}", 0, -1)
          Send, ^{Enter}%tempStr%{Enter}
          ResetChat()

        }
        Else If (func = "Stash")
        {
          MoveStash(%TypePrefix%Suffix%SuffixNum%,1)
        }
      }
      Return
    }
    FireStashReset() {
      CurrentTab := 0
    return
    }  
  }

  { ; Submit Profiles
    submitProfile(Profile){  
      global
      Gui, Submit, NoHide

      ;Attack Keys
      IniWrite, %hotkeyMainAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttack
      IniWrite, %hotkeySecondaryAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttack
      
      ;QS on Attack Keys
      IniWrite, %QSonMainAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonMainAttack
      IniWrite, %QSonSecondaryAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonSecondaryAttack
      
      ;Quicksilver Flasks
      IniWrite, %TriggerQuicksilverDelay%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, TriggerQuicksilverDelay
      
      ;CharacterTypeCheck
      IniWrite, %RadioLife%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Life
      IniWrite, %RadioHybrid%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Hybrid  
      IniWrite, %RadioCi%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Ci  
      
      ;AutoMines
      IniWrite, %DetonateMines%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, DetonateMines
      IniWrite, %CastOnDetonate%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CastOnDetonate
      IniWrite, %hotkeyCastOnDetonate%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, hotkeyCastOnDetonate
      ; IniWrite, %DetonateMinesDelay%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, DetonateMinesDelay
      ; IniWrite, %PauseMinesDelay%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PauseMinesDelay
      ; IniWrite, %hotkeyPauseMines%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, hotkeyPauseMines

      ;EldritchBattery
      IniWrite, %YesEldritchBattery%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesEldritchBattery

      ;AutoQuit
      IniWrite, %QuitBelow%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuitBelow
      IniWrite, %RadioCritQuit%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CritQuit
      IniWrite, %RadioPortalQuit%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PortalQuit
      IniWrite, %RadioNormalQuit%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, NormalQuit
      
      ;Utility Buttons
      IniWrite, %YesUtility1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1
      IniWrite, %YesUtility2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2
      IniWrite, %YesUtility3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3
      IniWrite, %YesUtility4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4
      IniWrite, %YesUtility5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5
      IniWrite, %YesUtility6%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6
      IniWrite, %YesUtility7%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7
      IniWrite, %YesUtility8%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8
      IniWrite, %YesUtility9%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9
      IniWrite, %YesUtility10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10

      IniWrite, %YesUtility1Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1Quicksilver
      IniWrite, %YesUtility2Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2Quicksilver
      IniWrite, %YesUtility3Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3Quicksilver
      IniWrite, %YesUtility4Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4Quicksilver
      IniWrite, %YesUtility5Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5Quicksilver
      IniWrite, %YesUtility6Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6Quicksilver
      IniWrite, %YesUtility7Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7Quicksilver
      IniWrite, %YesUtility8Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8Quicksilver
      IniWrite, %YesUtility9Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9Quicksilver
      IniWrite, %YesUtility10Quicksilver%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10Quicksilver

      IniWrite, %YesUtility1InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1InverseBuff
      IniWrite, %YesUtility2InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2InverseBuff
      IniWrite, %YesUtility3InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3InverseBuff
      IniWrite, %YesUtility4InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4InverseBuff
      IniWrite, %YesUtility5InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5InverseBuff
      IniWrite, %YesUtility6InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6InverseBuff
      IniWrite, %YesUtility7InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7InverseBuff
      IniWrite, %YesUtility8InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8InverseBuff
      IniWrite, %YesUtility9InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9InverseBuff
      IniWrite, %YesUtility10InverseBuff%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10InverseBuff
      
      ;Utility Percents  
      IniWrite, %YesUtility1LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1LifePercent
      IniWrite, %YesUtility2LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2LifePercent
      IniWrite, %YesUtility3LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3LifePercent
      IniWrite, %YesUtility4LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4LifePercent
      IniWrite, %YesUtility5LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5LifePercent
      IniWrite, %YesUtility6LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6LifePercent
      IniWrite, %YesUtility7LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7LifePercent
      IniWrite, %YesUtility8LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8LifePercent
      IniWrite, %YesUtility9LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9LifePercent
      IniWrite, %YesUtility10LifePercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10LifePercent

      IniWrite, %YesUtility1EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1EsPercent
      IniWrite, %YesUtility2EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2EsPercent
      IniWrite, %YesUtility3EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3EsPercent
      IniWrite, %YesUtility4EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4EsPercent
      IniWrite, %YesUtility5EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5EsPercent
      IniWrite, %YesUtility6EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6EsPercent
      IniWrite, %YesUtility7EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7EsPercent
      IniWrite, %YesUtility8EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8EsPercent
      IniWrite, %YesUtility9EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9EsPercent
      IniWrite, %YesUtility10EsPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10EsPercent

      IniWrite, %YesUtility1ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1ManaPercent
      IniWrite, %YesUtility2ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2ManaPercent
      IniWrite, %YesUtility3ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3ManaPercent
      IniWrite, %YesUtility4ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4ManaPercent
      IniWrite, %YesUtility5ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5ManaPercent
      IniWrite, %YesUtility6ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6ManaPercent
      IniWrite, %YesUtility7ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7ManaPercent
      IniWrite, %YesUtility8ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8ManaPercent
      IniWrite, %YesUtility9ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9ManaPercent
      IniWrite, %YesUtility10ManaPercent%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10ManaPercent
      
      ;Utility Cooldowns
      IniWrite, %CooldownUtility1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility1
      IniWrite, %CooldownUtility2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility2
      IniWrite, %CooldownUtility3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility3
      IniWrite, %CooldownUtility4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility4
      IniWrite, %CooldownUtility5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility5
      IniWrite, %CooldownUtility6%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility6
      IniWrite, %CooldownUtility7%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility7
      IniWrite, %CooldownUtility8%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility8
      IniWrite, %CooldownUtility9%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility9
      IniWrite, %CooldownUtility10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility10
      
      ;Character Name
      IniWrite, %CharName%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CharName

      ;Utility Keys
      IniWrite, %KeyUtility1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility1
      IniWrite, %KeyUtility2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility2
      IniWrite, %KeyUtility3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility3
      IniWrite, %KeyUtility4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility4
      IniWrite, %KeyUtility5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility5
      IniWrite, %KeyUtility6%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility6
      IniWrite, %KeyUtility7%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility7
      IniWrite, %KeyUtility8%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility8
      IniWrite, %KeyUtility9%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility9
      IniWrite, %KeyUtility10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility10

      ;Utility Icon Strings
      IniWrite, %IconStringUtility1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility1
      IniWrite, %IconStringUtility2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility2
      IniWrite, %IconStringUtility3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility3
      IniWrite, %IconStringUtility4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility4
      IniWrite, %IconStringUtility5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility5
      IniWrite, %IconStringUtility6%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility6
      IniWrite, %IconStringUtility7%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility7
      IniWrite, %IconStringUtility8%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility8
      IniWrite, %IconStringUtility9%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility9
      IniWrite, %IconStringUtility10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility10
      
    return
    }

    submitProfile1:
      submitProfile(1)
    Return

    submitProfile2:
      submitProfile(2)
    Return

    submitProfile3:
      submitProfile(3)
    Return

    submitProfile4:
      submitProfile(4)
    Return

    submitProfile5:
      submitProfile(5)
    Return

    submitProfile6:
      submitProfile(6)
    Return

    submitProfile7:
      submitProfile(7)
    Return

    submitProfile8:
      submitProfile(8)
    Return

    submitProfile9:
      submitProfile(9)
    Return

    submitProfile10:
      submitProfile(10)
    Return
  }

  { ; Read Profiles
    readProfile(Profile){  
      global
      ;Attack Keys
      IniRead, hotkeyMainAttack, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttack, RButton
      GuiControl, , hotkeyMainAttack, %hotkeyMainAttack%
      IniRead, hotkeySecondaryAttack, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttack, w
      GuiControl, , hotkeySecondaryAttack, %hotkeySecondaryAttack%
      
      ;QS on Attack Keys
      IniRead, QSonMainAttack, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonMainAttack, 0
      GuiControl, , QSonMainAttack, %QSonMainAttack%
      IniRead, QSonSecondaryAttack, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonSecondaryAttack, 0
      GuiControl, , QSonSecondaryAttack, %QSonSecondaryAttack%

      ;CharacterTypeCheck
      IniRead, RadioLife, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Life, 1
      GuiControl, , RadioLife, %RadioLife%
      IniRead, RadioHybrid, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Hybrid, 0
      GuiControl, , RadioHybrid, %RadioHybrid%
      IniRead, RadioCi, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Ci, 0
      GuiControl, , RadioCi, %RadioCi%
      
      ;AutoMines
      IniRead, DetonateMines, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, DetonateMines, 0
      GuiControl, , DetonateMines, %DetonateMines%
      IniRead, CastOnDetonate, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CastOnDetonate, 0
      GuiControl, , CastOnDetonate, %CastOnDetonate%
      IniRead, hotkeyCastOnDetonate, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, hotkeyCastOnDetonate, q
      GuiControl, , hotkeyCastOnDetonate, %hotkeyCastOnDetonate%
      ; IniRead, DetonateMinesDelay, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, DetonateMinesDelay, 500
      ; GuiControl, , DetonateMinesDelay, %DetonateMinesDelay%
      ; IniRead, PauseMinesDelay, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PauseMinesDelay, 250
      ; GuiControl, , PauseMinesDelay, %PauseMinesDelay%
      ; IniRead, hotkeyPauseMines, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, hotkeyPauseMines, d
      ; GuiControl, , hotkeyPauseMines, %hotkeyPauseMines%

      ;EldritchBattery
      IniRead, YesEldritchBattery, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesEldritchBattery, 0
      GuiControl, , YesEldritchBattery, %YesEldritchBattery%

      ;AutoQuit
      IniRead, QuitBelow, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuitBelow, 20
      GuiControl, , QuitBelow, %QuitBelow%
      IniRead, RadioCritQuit, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CritQuit, 1
      GuiControl, , RadioCritQuit, %RadioCritQuit%
      IniRead, RadioPortalQuit, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PortalQuit, 0
      GuiControl, , RadioPortalQuit, %RadioPortalQuit%
      IniRead, RadioNormalQuit, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, NormalQuit, 0
      GuiControl, , RadioNormalQuit, %RadioNormalQuit%


      ;Utility Buttons
      IniRead, YesUtility1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1, 0
      GuiControl, , YesUtility1, %YesUtility1%
      IniRead, YesUtility2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2, 0
      GuiControl, , YesUtility2, %YesUtility2%
      IniRead, YesUtility3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3, 0
      GuiControl, , YesUtility3, %YesUtility3%
      IniRead, YesUtility4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4, 0
      GuiControl, , YesUtility4, %YesUtility4%
      IniRead, YesUtility5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5, 0
      GuiControl, , YesUtility5, %YesUtility5%
      IniRead, YesUtility6, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6, 0
      GuiControl, , YesUtility6, %YesUtility6%
      IniRead, YesUtility7, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7, 0
      GuiControl, , YesUtility7, %YesUtility7%
      IniRead, YesUtility8, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8, 0
      GuiControl, , YesUtility8, %YesUtility8%
      IniRead, YesUtility9, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9, 0
      GuiControl, , YesUtility9, %YesUtility9%
      IniRead, YesUtility10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10, 0
      GuiControl, , YesUtility10, %YesUtility10%
      IniRead, YesUtility1Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1Quicksilver, 0
      GuiControl, , YesUtility1Quicksilver, %YesUtility1Quicksilver%
      IniRead, YesUtility2Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2Quicksilver, 0
      GuiControl, , YesUtility2Quicksilver, %YesUtility2Quicksilver%
      IniRead, YesUtility3Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3Quicksilver, 0
      GuiControl, , YesUtility3Quicksilver, %YesUtility3Quicksilver%
      IniRead, YesUtility4Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4Quicksilver, 0
      GuiControl, , YesUtility4Quicksilver, %YesUtility4Quicksilver%
      IniRead, YesUtility5Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5Quicksilver, 0
      GuiControl, , YesUtility5Quicksilver, %YesUtility5Quicksilver%
      IniRead, YesUtility6Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6Quicksilver, 0
      GuiControl, , YesUtility6Quicksilver, %YesUtility6Quicksilver%
      IniRead, YesUtility7Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7Quicksilver, 0
      GuiControl, , YesUtility7Quicksilver, %YesUtility7Quicksilver%
      IniRead, YesUtility8Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8Quicksilver, 0
      GuiControl, , YesUtility8Quicksilver, %YesUtility8Quicksilver%
      IniRead, YesUtility9Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9Quicksilver, 0
      GuiControl, , YesUtility9Quicksilver, %YesUtility9Quicksilver%
      IniRead, YesUtility10Quicksilver, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10Quicksilver, 0
      GuiControl, , YesUtility10Quicksilver, %YesUtility10Quicksilver%
      IniRead, YesUtility1InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1InverseBuff, 0
      GuiControl, , YesUtility1InverseBuff, %YesUtility1InverseBuff%
      IniRead, YesUtility2InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2InverseBuff, 0
      GuiControl, , YesUtility2InverseBuff, %YesUtility2InverseBuff%
      IniRead, YesUtility3InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3InverseBuff, 0
      GuiControl, , YesUtility3InverseBuff, %YesUtility3InverseBuff%
      IniRead, YesUtility4InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4InverseBuff, 0
      GuiControl, , YesUtility4InverseBuff, %YesUtility4InverseBuff%
      IniRead, YesUtility5InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5InverseBuff, 0
      GuiControl, , YesUtility5InverseBuff, %YesUtility5InverseBuff%
      IniRead, YesUtility6InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6InverseBuff, 0
      GuiControl, , YesUtility6InverseBuff, %YesUtility6InverseBuff%
      IniRead, YesUtility7InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7InverseBuff, 0
      GuiControl, , YesUtility7InverseBuff, %YesUtility7InverseBuff%
      IniRead, YesUtility8InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8InverseBuff, 0
      GuiControl, , YesUtility8InverseBuff, %YesUtility8InverseBuff%
      IniRead, YesUtility9InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9InverseBuff, 0
      GuiControl, , YesUtility9InverseBuff, %YesUtility9InverseBuff%
      IniRead, YesUtility10InverseBuff, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10InverseBuff, 0
      GuiControl, , YesUtility10InverseBuff, %YesUtility10InverseBuff%
      
      ;Utility Percents  
      IniRead, YesUtility1LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1LifePercent, Off
      GuiControl, ChooseString, YesUtility1LifePercent, %YesUtility1LifePercent%
      IniRead, YesUtility2LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2LifePercent, Off
      GuiControl, ChooseString, YesUtility2LifePercent, %YesUtility2LifePercent%
      IniRead, YesUtility3LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3LifePercent, Off
      GuiControl, ChooseString, YesUtility3LifePercent, %YesUtility3LifePercent%
      IniRead, YesUtility4LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4LifePercent, Off
      GuiControl, ChooseString, YesUtility4LifePercent, %YesUtility4LifePercent%
      IniRead, YesUtility5LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5LifePercent, Off
      GuiControl, ChooseString, YesUtility5LifePercent, %YesUtility5LifePercent%
      IniRead, YesUtility6LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6LifePercent, Off
      GuiControl, ChooseString, YesUtility6LifePercent, %YesUtility6LifePercent%
      IniRead, YesUtility7LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7LifePercent, Off
      GuiControl, ChooseString, YesUtility7LifePercent, %YesUtility7LifePercent%
      IniRead, YesUtility8LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8LifePercent, Off
      GuiControl, ChooseString, YesUtility8LifePercent, %YesUtility8LifePercent%
      IniRead, YesUtility9LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9LifePercent, Off
      GuiControl, ChooseString, YesUtility9LifePercent, %YesUtility9LifePercent%
      IniRead, YesUtility10LifePercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10LifePercent, Off
      GuiControl, ChooseString, YesUtility10LifePercent, %YesUtility10LifePercent%
      IniRead, YesUtility1EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1EsPercent, Off
      GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
      IniRead, YesUtility2EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2EsPercent, Off
      GuiControl, ChooseString, YesUtility2EsPercent, %YesUtility2EsPercent%
      IniRead, YesUtility3EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3EsPercent, Off
      GuiControl, ChooseString, YesUtility3EsPercent, %YesUtility3EsPercent%
      IniRead, YesUtility4EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4EsPercent, Off
      GuiControl, ChooseString, YesUtility4EsPercent, %YesUtility4EsPercent%
      IniRead, YesUtility5EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5EsPercent, Off
      GuiControl, ChooseString, YesUtility5EsPercent, %YesUtility5EsPercent%
      IniRead, YesUtility6EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6EsPercent, Off
      GuiControl, ChooseString, YesUtility6EsPercent, %YesUtility6EsPercent%
      IniRead, YesUtility7EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7EsPercent, Off
      GuiControl, ChooseString, YesUtility7EsPercent, %YesUtility7EsPercent%
      IniRead, YesUtility8EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8EsPercent, Off
      GuiControl, ChooseString, YesUtility8EsPercent, %YesUtility8EsPercent%
      IniRead, YesUtility9EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9EsPercent, Off
      GuiControl, ChooseString, YesUtility9EsPercent, %YesUtility9EsPercent%
      IniRead, YesUtility10EsPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10EsPercent, Off
      GuiControl, ChooseString, YesUtility10EsPercent, %YesUtility10EsPercent%
      IniRead, YesUtility1ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility1ManaPercent, Off
      GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
      IniRead, YesUtility2ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility2ManaPercent, Off
      GuiControl, ChooseString, YesUtility2ManaPercent, %YesUtility2ManaPercent%
      IniRead, YesUtility3ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility3ManaPercent, Off
      GuiControl, ChooseString, YesUtility3ManaPercent, %YesUtility3ManaPercent%
      IniRead, YesUtility4ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility4ManaPercent, Off
      GuiControl, ChooseString, YesUtility4ManaPercent, %YesUtility4ManaPercent%
      IniRead, YesUtility5ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility5ManaPercent, Off
      GuiControl, ChooseString, YesUtility5ManaPercent, %YesUtility5ManaPercent%
      IniRead, YesUtility6ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility6ManaPercent, Off
      GuiControl, ChooseString, YesUtility6ManaPercent, %YesUtility6ManaPercent%
      IniRead, YesUtility7ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility7ManaPercent, Off
      GuiControl, ChooseString, YesUtility7ManaPercent, %YesUtility7ManaPercent%
      IniRead, YesUtility8ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility8ManaPercent, Off
      GuiControl, ChooseString, YesUtility8ManaPercent, %YesUtility8ManaPercent%
      IniRead, YesUtility9ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility9ManaPercent, Off
      GuiControl, ChooseString, YesUtility9ManaPercent, %YesUtility9ManaPercent%
      IniRead, YesUtility10ManaPercent, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, YesUtility10ManaPercent, Off
      GuiControl, ChooseString, YesUtility10ManaPercent, %YesUtility10ManaPercent%
      
      ;Utility Cooldowns
      IniRead, CooldownUtility1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility1, 5000
      GuiControl, , CooldownUtility1, %CooldownUtility1%
      IniRead, CooldownUtility2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility2, 5000
      GuiControl, , CooldownUtility2, %CooldownUtility2%
      IniRead, CooldownUtility3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility3, 5000
      GuiControl, , CooldownUtility3, %CooldownUtility3%
      IniRead, CooldownUtility4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility4, 5000
      GuiControl, , CooldownUtility4, %CooldownUtility4%
      IniRead, CooldownUtility5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility5, 5000
      GuiControl, , CooldownUtility5, %CooldownUtility5%
      IniRead, CooldownUtility6, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility6, 5000
      GuiControl, , CooldownUtility6, %CooldownUtility6%
      IniRead, CooldownUtility7, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility7, 5000
      GuiControl, , CooldownUtility7, %CooldownUtility7%
      IniRead, CooldownUtility8, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility8, 5000
      GuiControl, , CooldownUtility8, %CooldownUtility8%
      IniRead, CooldownUtility9, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility9, 5000
      GuiControl, , CooldownUtility9, %CooldownUtility9%
      IniRead, CooldownUtility10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownUtility10, 5000
      GuiControl, , CooldownUtility10, %CooldownUtility10%
      
      ;Character Name
      IniRead, CharName, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CharName, ReplaceWithCharName
      GuiControl, , CharName, %CharName%

      ;Utility Keys
      IniRead, KeyUtility1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility1, q
      GuiControl, , KeyUtility1, %KeyUtility1%
      IniRead, KeyUtility2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility2, w
      GuiControl, , KeyUtility2, %KeyUtility2%
      IniRead, KeyUtility3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility3, e
      GuiControl, , KeyUtility3, %KeyUtility3%
      IniRead, KeyUtility4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility4, r
      GuiControl, , KeyUtility4, %KeyUtility4%
      IniRead, KeyUtility5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility5, t
      GuiControl, , KeyUtility5, %KeyUtility5%
      IniRead, KeyUtility6, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility6, t
      GuiControl, , KeyUtility6, %KeyUtility6%
      IniRead, KeyUtility7, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility7, t
      GuiControl, , KeyUtility7, %KeyUtility7%
      IniRead, KeyUtility8, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility8, t
      GuiControl, , KeyUtility8, %KeyUtility8%
      IniRead, KeyUtility9, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility9, t
      GuiControl, , KeyUtility9, %KeyUtility9%
      IniRead, KeyUtility10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, KeyUtility10, t
      GuiControl, , KeyUtility10, %KeyUtility10%

      ;Utility Icon Strings
      IniRead, IconStringUtility1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility1, %A_Space%
      If IconStringUtility1
        IconStringUtility1 := """" . IconStringUtility1 . """"
      GuiControl, , IconStringUtility1, %IconStringUtility1%
      IniRead, IconStringUtility2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility2, %A_Space%
      If IconStringUtility2
        IconStringUtility2 := """" . IconStringUtility2 . """"
      GuiControl, , IconStringUtility2, %IconStringUtility2%
      IniRead, IconStringUtility3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility3, %A_Space%
      If IconStringUtility3
        IconStringUtility3 := """" . IconStringUtility3 . """"
      GuiControl, , IconStringUtility3, %IconStringUtility3%
      IniRead, IconStringUtility4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility4, %A_Space%
      If IconStringUtility4
        IconStringUtility4 := """" . IconStringUtility4 . """"
      GuiControl, , IconStringUtility4, %IconStringUtility4%
      IniRead, IconStringUtility5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility5, %A_Space%
      If IconStringUtility5
        IconStringUtility5 := """" . IconStringUtility5 . """"
      GuiControl, , IconStringUtility5, %IconStringUtility5%
      IniRead, IconStringUtility6, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility6, %A_Space%
      If IconStringUtility6
        IconStringUtility6 := """" . IconStringUtility6 . """"
      GuiControl, , IconStringUtility6, %IconStringUtility6%
      IniRead, IconStringUtility7, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility7, %A_Space%
      If IconStringUtility7
        IconStringUtility7 := """" . IconStringUtility7 . """"
      GuiControl, , IconStringUtility7, %IconStringUtility7%
      IniRead, IconStringUtility8, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility8, %A_Space%
      If IconStringUtility8
        IconStringUtility8 := """" . IconStringUtility8 . """"
      GuiControl, , IconStringUtility8, %IconStringUtility8%
      IniRead, IconStringUtility9, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility9, %A_Space%
      If IconStringUtility9
        IconStringUtility9 := """" . IconStringUtility9 . """"
      GuiControl, , IconStringUtility9, %IconStringUtility9%
      IniRead, IconStringUtility10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, IconStringUtility10, %A_Space%
      If IconStringUtility10
        IconStringUtility10 := """" . IconStringUtility10 . """"
      GuiControl, , IconStringUtility10, %IconStringUtility10%

    return  
    }

    readProfile1:
      readProfile(1)
    Return

    readProfile2:
      readProfile(2)
    Return

    readProfile3:
      readProfile(3)
    Return

    readProfile4:
      readProfile(4)
    Return

    readProfile5:
      readProfile(5)
    Return

    readProfile6:
      readProfile(6)
    Return

    readProfile7:
      readProfile(7)
    Return

    readProfile8:
      readProfile(8)
    Return

    readProfile9:
      readProfile(9)
    Return

    readProfile10:
      readProfile(10)
    Return
  }

  { ; Script Update Functions - checkUpdate, runUpdate, dontUpdate
    checkUpdate(force:=False)
    {
      Global BranchName
      If (!AutoUpdateOff || force) 
      {
        UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/version.html, %A_ScriptDir%\temp\version.html
        FileRead, newestVersion, %A_ScriptDir%\temp\version.html
        If InStr(newestVersion, ":")
        {
          Log("Error loading version number",newestVersion)
          Return
        }
        If RegExMatch(newestVersion, "[.0-9]+", matchVersion)
          newestVersion := matchVersion
        if ( VersionNumber < newestVersion || force) 
        {
          UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/changelog.txt, %A_ScriptDir%\temp\changelog.txt
          FileRead, changelog, %A_ScriptDir%\temp\changelog.txt
          Gui, Update: +AlwaysOnTop
          Gui, Update:Add, Button, x0 y0 h1 w1, a
          Gui, Update:Add, Text,, Update Available.`nYoure running version %VersionNumber%. The newest is version %newestVersion%`n
          Gui, Update:Add, Edit, w600 h200 +ReadOnly, %changelog% 
          Gui, Update:Add, Button, x70 section default grunUpdate, Update to the Newest Version!
          Gui, Update:Add, Button, x+35 ys gLaunchDonate, Support the Project
          Gui, Update:Add, Button, x+35 ys gdontUpdate, Turn off Auto-Update
          Gui, Update:Show,, WingmanReloaded Update
          IfWinExist WingmanReloaded Update ahk_exe AutoHotkey.exe
          {
            WinWaitClose
          }
        }
      }
      Return

      UpdateGuiClose:
      UpdateGuiEscape:
        Gui, Update: Destroy
      Return
    }

    runUpdate:
      Fail:=False
      UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/PoE-Wingman.ahk, PoE-Wingman.ahk
      if ErrorLevel {
        Fail:=true
      }
      UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/LootFilter.ahk, %A_ScriptDir%\data\LootFilter.ahk
      if ErrorLevel {
        Fail:=true
      }
      UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Quest.json, %A_ScriptDir%\data\Quest.json
      if ErrorLevel {
        Fail:=true
      }
      UrlDownloadToFile, https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/base_items.json, %A_ScriptDir%\data\Bases.json
      if ErrorLevel {
        Fail:=true
      } Else {
        FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
        Holder := []
        Global Bases := JSON.Load(JSONtext)
        For k, v in Bases
        {
          temp := {"name":v["name"]
            ,"item_class":v["item_class"]
            ,"domain":v["domain"]
            ,"tags":v["tags"]
            ,"inventory_width":v["inventory_width"]
            ,"inventory_height":v["inventory_height"]
            ,"drop_level":v["drop_level"]}
          Holder.Push(temp)
        }
        Bases := Holder
        JSONtext := JSON.Dump(Bases,,2)
        FileDelete, %A_ScriptDir%\data\Bases.json
        FileAppend, %JSONtext%, %A_ScriptDir%\data\Bases.json
      }

      UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Library.ahk, %A_ScriptDir%\data\Library.ahk
      if ErrorLevel {
        Fail:=true
      }
      if Fail {
        Log("update","fail")
      }
      else {
        Log("update","pass")
        Run "%A_ScriptFullPath%"
      }
      Sleep 5000 ;This shouldn't ever hit.
      Log("update","uhoh")
    Return

    dontUpdate:
      IniWrite, 1, %A_ScriptDir%\save\Settings.ini, General, AutoUpdateOff
      MsgBox, Auto-Updates have been disabled.`nCheck back on the forum for more information!`nTo resume updates, uncheck the box in config page.
      Gui, 4:Destroy
    return  
  }

  { ; Calibration color sample functions - updateOnChar, updateOnInventory, updateOnMenu, updateOnStash,
  ;   updateEmptyColor, updateOnChat, updateOnVendor, updateOnDiv, updateDetonate
    updateOnChar:
      Critical
      Gui, Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of Character Active didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnChar := ScreenShot_GetColor(WR.loc.OnChar.X,WR.loc.OnChar.Y)
        IniWrite, %varOnChar%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar
        readFromFile()
        MsgBox % "Character Active recalibrated!`nTook color hex: " . varOnChar . " `nAt coords x: " . WR.loc.OnChar.X . " and y: " . WR.loc.OnChar.Y
      } else
      MsgBox % "PoE Window is not active. `nRecalibrate of Character Active didn't work"
      
      hotkeys()
      
    return

    updateOnInventory:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnInventory didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnInventory := ScreenShot_GetColor(WR.loc.OnInventory.X,WR.loc.OnInventory.Y)
        IniWrite, %varOnInventory%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory
        readFromFile()
        MsgBox % "OnInventory recalibrated!`nTook color hex: " . varOnInventory . " `nAt coords x: " . WR.loc.OnInventory.X . " and y: " . WR.loc.OnInventory.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnInventory didn't work"
      
      hotkeys()
      
    return

    updateOnMenu:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnMenu didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnMenu := ScreenShot_GetColor(WR.loc.OnMenu.X,WR.loc.OnMenu.Y)
        IniWrite, %varOnMenu%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu
        readFromFile()
        MsgBox % "OnMenu recalibrated!`nTook color hex: " . varOnMenu . " `nAt coords x: " . WR.loc.OnMenu.X . " and y: " . WR.loc.OnMenu.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnMenu didn't work"
      
      hotkeys()
      
    return

    updateOnDelveChart:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnDelveChart didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnDelveChart := ScreenShot_GetColor(WR.loc.OnDelveChart.X,WR.loc.OnDelveChart.Y)
        IniWrite, %varOnDelveChart%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart
        readFromFile()
        MsgBox % "OnDelveChart recalibrated!`nTook color hex: " . varOnDelveChart . " `nAt coords x: " . WR.loc.OnDelveChart.X . " and y: " . WR.loc.OnDelveChart.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDelveChart didn't work"
      
      hotkeys()
      
    return

    updateOnMetamorph:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnMetamorph didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnMetamorph := ScreenShot_GetColor(WR.loc.OnMetamorph.X,WR.loc.OnMetamorph.Y)
        IniWrite, %varOnMetamorph%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMetamorph
        readFromFile()
        MsgBox % "OnMetamorph recalibrated!`nTook color hex: " . varOnMetamorph . " `nAt coords x: " . WR.loc.OnMetamorph.X . " and y: " . WR.loc.OnMetamorph.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnMetamorph didn't work"
      
      hotkeys()
      
    return

    updateOnLocker:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnLocker didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnLocker := ScreenShot_GetColor(WR.loc.OnLocker.X,WR.loc.OnLocker.Y)
        IniWrite, %varOnLocker%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLocker
        readFromFile()
        MsgBox % "OnLocker recalibrated!`nTook color hex: " . varOnLocker . " `nAt coords x: " . WR.loc.OnLocker.X . " and y: " . WR.loc.OnLocker.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnLocker didn't work"
      
      hotkeys()
      
    return

    updateOnStash:
      Critical
      Gui, Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnStash/OnLeft didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnLeft := ScreenShot_GetColor(WR.loc.OnLeft.X,WR.loc.OnLeft.Y)
        IniWrite, %varOnLeft%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft
        varOnStash := ScreenShot_GetColor(WR.loc.OnStash.X,WR.loc.OnStash.Y)
        IniWrite, %varOnStash%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash
        readFromFile()
        MsgBox % "OnStash recalibrated!`nTook color hex: " . varOnStash . " `nAt coords x: " . WR.loc.OnStash.X . " and y: " . WR.loc.OnStash.Y
          . "`n`nOnLeft recalibrated!`nTook color hex: " . varOnLeft . " `nAt coords x: " . WR.loc.OnLeft.X . " and y: " . WR.loc.OnLeft.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnStash/OnLeft didn't work"
      
      hotkeys()
      
    return

    updateEmptyColor:
      Critical
      Gui, Submit ; , NoHide

      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nEmpty Slot calibration didn't work"
        Return
      }

      if WinActive(ahk_group POEGameGroup){
        ;Now we need to get the user input for every grid element if its empty or not

        ;First inform the user about the procedure
        infoMsg := "Following we loop through the whole inventory, recording all colors and save it as Empty Slot colors.`r`n`r`n"
        infoMsg .= "  -> Clear all items from inventory`r`n"
        infoMsg .= "  -> Make sure your inventory is open`r`n`r`n"
        infoMsg .= "Do you meet the above state requirements? If not please cancel this function."

        MsgBox, 1,, %infoMsg%
        IfMsgBox, Cancel
        {
          MsgBox Canceled the Id / Empty Slot calibration
          return
        }

        varEmptyInvSlotColor := []
        WinActivate, ahk_group POEGameGroup

        ScreenShot()
        ;Loop through the whole grid, and add unknown colors to the lists
        For c, GridX in InventoryGridX  {
          For r, GridY in InventoryGridY
          {
            PointColor := ScreenShot_GetColor(GridX,GridY)

            if !(indexOf(PointColor, varEmptyInvSlotColor)){
              ;We dont have this Empty color already
              varEmptyInvSlotColor.Push(PointColor)
            }
          }
        }

        strToSave := hexArrToStr(varEmptyInvSlotColor)

        IniWrite, %strToSave%, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor
        readFromFile()


        infoMsg := "Empty Slot colors calibrated and saved with following color codes:`r`n`r`n"
        infoMsg .= strToSave

        MsgBox, %infoMsg%


      }else{
        MsgBox % "PoE Window is not active. `nRecalibrate Empty Slot Color didn't work"
      }

      hotkeys()
      Thread, NoTimers, False    ;End Critical
    return

    updateOnChat:
      Critical
      Gui, Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnChat didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnChat := ScreenShot_GetColor(WR.loc.OnChat.X,WR.loc.OnChat.Y)
        IniWrite, %varOnChat%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat
        readFromFile()
        MsgBox % "OnChat recalibrated!`nTook color hex: " . varOnChat . " `nAt coords x: " . WR.loc.OnChat.X . " and y: " . WR.loc.OnChat.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of onChat didn't work"
      
      hotkeys()
      
    return

    updateOnVendor:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnVendor didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnVendor := ScreenShot_GetColor(WR.loc.OnVendor.X,WR.loc.OnVendor.Y)
        IniWrite, %varOnVendor%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor
        readFromFile()
        MsgBox % "OnVendor recalibrated!`nTook color hex: " . varOnVendor . " `nAt coords x: " . WR.loc.OnVendor.X . " and y: " . WR.loc.OnVendor.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
      
      hotkeys()
      
    return

    updateOnDiv:
      Critical
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnDiv didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnDiv := ScreenShot_GetColor(WR.loc.OnDiv.X,WR.loc.OnDiv.Y)
        IniWrite, %varOnDiv%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv
        readFromFile()
        MsgBox % "OnDiv recalibrated!`nTook color hex: " . varOnDiv . " `nAt coords x: " . WR.loc.OnDiv.X . " and y: " . WR.loc.OnDiv.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDiv didn't work"
      
      hotkeys()
      
    return

    updateDetonate:
      Critical
      Gui, Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnDetonate didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        If OnMines
          varOnDetonate := ScreenShot_GetColor(WR.loc.DetonateDelve.X,WR.loc.Detonate.Y)
        Else
          varOnDetonate := ScreenShot_GetColor(WR.loc.Detonate.X,WR.loc.Detonate.Y)
        IniWrite, %varOnDetonate%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate
        readFromFile()
        MsgBox % "OnDetonate recalibrated!`nTook color hex: " . varOnDetonate . " `nAt coords x: " . (OnMines?WR.loc.DetonateDelve.X:WR.loc.Detonate.X) . " and y: " . WR.loc.Detonate.Y
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDetonate didn't work"
      
      hotkeys()
      
    return

    CalibrateOHB:
      Critical
      Gui,1: Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OHB didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        Sleep, 500
        If CheckOHB()
        {
          PixelGetColor, OHBLHealthHex, % OHB.X + 1, % OHB.hpY, RGB
          IniWrite, %OHBLHealthHex%, %A_ScriptDir%\save\Settings.ini, OHB, OHBLHealthHex
          ; If ((RadioHybrid || RadioCi) && !YesEldritchBattery)
          ; {
          ;   PixelGetColor, OHBLESHex, % OHB.X + 1, % OHB.esY, RGB
          ;   IniWrite, %OHBLESHex%, %A_ScriptDir%\save\Settings.ini, OHB, OHBLESHex
          ; }
          ; Else If ((RadioHybrid || RadioCi) && YesEldritchBattery)
          ; {
          ;   PixelGetColor, OHBLEBHex, % OHB.X + 1, % OHB.ebY, RGB
          ;   IniWrite, %OHBLEBHex%, %A_ScriptDir%\save\Settings.ini, OHB, OHBLEBHex
          ; }
          readFromFile()
          MsgBox % "OHB recalibrated!`nTook color hex: " . OHBLHealthHex . " `nAt coords x: " . OHB.X + 1 . " and y: " . OHB.hpY
          ; . "`n`nTook color hex: " . OHBLESHex . " `nAt coords x: " . OHB.X + 1 . " and y: " . OHB.esY
          ; . "`n`nTook color hex: " . OHBLEBHex . " `nAt coords x: " . OHB.X + 1 . " and y: " . OHB.ebY
        }
        Else
        {
          MsgBox % "OHB has not been found!`nMake sure you see the overhead health-bar"
        }
        
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OHB didn't work"
      
      hotkeys()
      
    return

    ShowSampleInd:
      Gui, Submit
      Gui,SampleInd: Show, Autosize Center
    return

    SampleIndGuiClose:
    SampleIndGuiEscape:
      Gui,SampleInd: Cancel
      Gui,1: Show
    Return
  }

  { ; Calibration Wizard
    CalibrationWizard()
    {
      Global
      StartCalibrationWizard:
        Critical
        Gui, Submit
        Gui, Wizard: New, +LabelWizard +AlwaysOnTop
        Gui, Wizard: Font, Bold
        Gui, Wizard: Add, GroupBox, x10 y9 w500 h270 , Select which calibrations to run
        Gui, Wizard: Font
        Gui, Wizard: Add, Text, x22 y29 w180 h200 , % "Enable the checkboxes to choose which calibration to perform"
          . "`n`nFollow the instructions in the tooltip that will appear in the screen center"
          . "`n`nFor best results, start the wizard in the hideout with your inventory emptied"
          . "`n`nPress the ""A"" button when your gamestate matches the instructions"
          . "`n`nTo cancel the Wizard, Hold Escape then press ""A"""

        Gui, Wizard: Add, CheckBox, Section Checked vCalibrationOnChar    x222 y39       w140 h20 , Character Active
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChat        xp   y+10      wp h20 , Chat Open
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnInventory     xp   y+10      wp h20 , Inventory Open
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnVendor      xp   y+10      wp h20 , Vendor Trade Open
        Gui, Wizard: Add, CheckBox, vCalibrationOnDiv             xp   y+10      wp h20 , Divination Trade Open
        Gui, Wizard: Add, CheckBox, vCalibrationOnMetamorph           xp   y+10      wp h20 , Map Metamorph Open

        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnMenu        xp+140 ys       wp h20 , Talent Menu Open
        Gui, Wizard: Add, CheckBox, Checked vCalibrationEmpty         xp   y+10      wp h20 , !EMPTY! Inventory Open
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnStash       xp   y+10      wp h20 , Stash Open
        Gui, Wizard: Add, CheckBox, vCalibrationOnDelveChart        xp   y+10      wp h20 , Delve Chart Open
        Gui, Wizard: Add, CheckBox, vCalibrationDetonate          xp   y+10      wp h20 , Detonate Shown

        Gui, Wizard: Add, Button, x100 y240 w160 h30 gRunWizard, Run Wizard
        Gui, Wizard: Add, Button, x+20 yp wp hp gWizardClose, Cancel Wizard

        Gui, Wizard: Show,% "x"ScrCenter.X - 240 "y"ScrCenter.Y - 150 " h300 w529", Calibration Wizard
      Return

      RunWizard:
        Critical
        PauseTooltips:=1
        Gui, Wizard: Submit
        IfWinExist, ahk_group POEGameGroup
        {
          WinActivate, ahk_group POEGameGroup
          Rescale()
        } else {
          MsgBox % "PoE Window does not exist. `nCalibration Wizard didn't run"
          Return
        }

        SampleTT=
        EmptySampleTT=
        If CalibrationOnChar
        {
          ToolTip,% "This will sample the Character Active Color"
            . "`nMake sure you are logged into a character with flasks and abilities clearly visible"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnChar := ScreenShot_GetColor(WR.loc.OnChar.X,WR.loc.OnChar.Y)
            SampleTT .= "Character Active took RGB color hex: " . varOnChar . "  At coords x: " . WR.loc.OnChar.X . " and y: " . WR.loc.OnChar.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Character Active didn't work"
        }
        If CalibrationOnChat
        {
          ToolTip,% "This will sample the Chat Open Color"
            . "`nMake sure you have chat panel open"
            . "`nNo other panels can be open on the left"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnChat := ScreenShot_GetColor(WR.loc.OnChat.X,WR.loc.OnChat.Y)
            SampleTT .= "Chat Open   took RGB color hex: " . varOnChat . "  At coords x: " . WR.loc.OnChat.X . " and y: " . WR.loc.OnChat.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Chat Open didn't work"
        }
        If CalibrationOnMenu
        {
          ToolTip,% "This will sample the Passive Menu Open Color"
            . "`nMake sure you have the Passive Skills menu open"
            . "`nCan also use Atlas menu to sample"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 135 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnMenu := ScreenShot_GetColor(WR.loc.OnMenu.X,WR.loc.OnMenu.Y)
            SampleTT .= "Passive Menu Open took RGB color hex: " . varOnMenu . "  At coords x: " . WR.loc.OnMenu.X . " and y: " . WR.loc.OnMenu.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Passive Menu Open didn't work"
        }
        If CalibrationOnInventory
        {
          ToolTip,% "This will sample the Inventory Open Color"
            . "`nMake sure you have the Inventory panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 130 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnInventory := ScreenShot_GetColor(WR.loc.OnInventory.X,WR.loc.OnInventory.Y)
            SampleTT .= "Inventory Open took RGB color hex: " . varOnInventory . "  At coords x: " . WR.loc.OnInventory.X . " and y: " . WR.loc.OnInventory.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Inventory Open didn't work"
        }
        If CalibrationEmpty
        {
          ToolTip,% "This will sample the Empty Inventory Colors"
            . "`nNo items can be in your inventory, ALL slots must be empty to calibrate"
            . "`nMake sure you have the Inventory panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 125 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            varEmptyInvSlotColor := []
            ScreenShot()
            For c, GridX in InventoryGridX  
            {
              For r, GridY in InventoryGridY
              {
                PointColor := ScreenShot_GetColor(GridX,GridY)
                if !(indexOf(PointColor, varEmptyInvSlotColor)){
                  varEmptyInvSlotColor.Push(PointColor)
                }
              }
            }
            strToSave := hexArrToStr(varEmptyInvSlotColor)
            NewString := StringReplaceN(strToSave,",",",`n",4)
            NewString := StringReplaceN(NewString,",",",`n",11)
            NewString := StringReplaceN(NewString,",",",`n",18)
            NewString := StringReplaceN(NewString,",",",`n",25)
            NewString := StringReplaceN(NewString,",",",`n",32)
            NewString := StringReplaceN(NewString,",",",`n",39)
            NewString := StringReplaceN(NewString,",",",`n",46)
            NewString := StringReplaceN(NewString,",",",`n",53)
            SampleTT .= " "
            EmptySampleTT := "`nEmpty Inventory took RGB color hexes: " . NewString
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Empty Inventory didn't work"
        }
        If CalibrationOnVendor
        {
          ToolTip,% "This will sample the Vendor Trade Open Color"
            . "`nMake sure you have the Vendor Sell panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 135 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnVendor := ScreenShot_GetColor(WR.loc.OnVendor.X,WR.loc.OnVendor.Y)
            SampleTT .= "Vendor Trade Open took RGB color hex: " . varOnVendor . "  At coords x: " . WR.loc.OnVendor.X . " and y: " . WR.loc.OnVendor.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Vendor Trade Open didn't work"
        }
        If CalibrationOnStash
        {
          ToolTip,% "This will sample the Stash Open and Left Panel Open Color"
            . "`nMake sure you have the Stash panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnStash := ScreenShot_GetColor(WR.loc.OnStash.X,WR.loc.OnStash.Y)
            , varOnLeft := ScreenShot_GetColor(WR.loc.OnLeft.X,WR.loc.OnLeft.Y)
            SampleTT .= "Stash Open took RGB color hex: " . varOnStash . "  At coords x: " . WR.loc.OnStash.X . " and y: " . WR.loc.OnStash.Y . "`n"
            SampleTT .= "Left Panel Open took RGB color hex: " . varOnLeft . "  At coords x: " . WR.loc.OnLeft.X . " and y: " . WR.loc.OnLeft.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Stash Open didn't work"
        }
        If CalibrationOnDiv
        {
          ToolTip,% "This will sample the Divination Trade Open Color"
            . "`nMake sure you have the Trade Divination panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 150 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnDiv := ScreenShot_GetColor(WR.loc.OnDiv.X,WR.loc.OnDiv.Y)
            SampleTT .= "Divination Trade Open took RGB color hex: " . varOnDiv . "  At coords x: " . WR.loc.OnDiv.X . " and y: " . WR.loc.OnDiv.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of Divination Trade Open didn't work"
        }
        If CalibrationDetonate
        {
          ToolTip,% "This will sample the Detonate Mines Color"
            . "`nPlace a mine, and the detonate mines icon should appear"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 165 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot()
            If OnMines
              varOnDetonate := ScreenShot_GetColor(WR.loc.DetonateDelve.X,WR.loc.Detonate.Y)
            Else
              varOnDetonate := ScreenShot_GetColor(WR.loc.Detonate.X,WR.loc.Detonate.Y)
            SampleTT .= "Detonate Mines took RGB color hex: " . varOnDetonate . "  At coords x: " . (OnMines?WR.loc.DetonateDelve.X:WR.loc.Detonate.X) . " and y: " . WR.loc.Detonate.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnDetonate didn't work"
        }
        If CalibrationOnDelveChart
        {
          ToolTip,% "This will sample the OnDelveChart Color"
            . "`nMake sure you have the Subterranean Chart open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 150 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnDelveChart := ScreenShot_GetColor(WR.loc.OnDelveChart.X,WR.loc.OnDelveChart.Y)
            SampleTT .= "OnDelveChart       took RGB color hex: " . varOnDelveChart . "  At coords x: " . WR.loc.OnDelveChart.X . " and y: " . WR.loc.OnDelveChart.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnDelveChart didn't work"
        }
        If CalibrationOnMetamorph
        {
          ToolTip,% "This will sample the OnMetamorph Color"
            . "`nMake sure you have the Metamorph Panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 150 , % ScrCenter.Y -30
          KeyWait, a, D L
          ToolTip
          KeyWait, a
          If GetKeyState("Escape", "P")
          {
            MsgBox % "Escape key was held`n"
            . "Canceling the Wizard!"
            Gui, Wizard: Show
            Exit
          }
          if WinActive(ahk_group POEGameGroup){
            ScreenShot(), varOnMetamorph := ScreenShot_GetColor(WR.loc.OnMetamorph.X,WR.loc.OnMetamorph.Y)
            SampleTT .= "OnMetamorph       took RGB color hex: " . varOnMetamorph . "  At coords x: " . WR.loc.OnMetamorph.X . " and y: " . WR.loc.OnMetamorph.Y . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnMetamorph didn't work"
        }
        PauseTooltips:=0
        If SampleTT =
        {
          MsgBox, No Sample Taken
          Gui, Wizard: Show
        }
        Else
          Goto, ShowWizardResults
      Return

      ShowWizardResults:
        Gui, Wizard: New, +LabelWizard
        Gui, Wizard: Add, Button,w1 h1
        Gui, Wizard: Add, Edit, , % SampleTT . EmptySampleTT
        Gui, Wizard: Add, Button, gSaveWizardResults, Save Samples
        Gui, Wizard: Add, Button, x+20 gWizardClose, Abort Samples

        Gui, Wizard: Show
      Return

      SaveWizardResults:
        If CalibrationOnChar
          IniWrite, %varOnChar%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar    
        If CalibrationOnChat
          IniWrite, %varOnChat%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat
        If CalibrationOnMenu
          IniWrite, %varOnMenu%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu
        If CalibrationOnInventory
          IniWrite, %varOnInventory%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory
        If CalibrationEmpty
          IniWrite, %strToSave%, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor
        If CalibrationOnVendor
          IniWrite, %varOnVendor%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor
        If CalibrationOnStash
        {
          IniWrite, %varOnStash%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash
          IniWrite, %varOnLeft%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft
        }
        If CalibrationOnDiv
          IniWrite, %varOnDiv%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv
        If CalibrationOnDelveChart
          IniWrite, %varOnDelveChart%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart
        If CalibrationOnMetamorph
          IniWrite, %varOnMetamorph%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMetamorph
        If CalibrationDetonate
          IniWrite, %varOnDetonate%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate
        Gui, Wizard: Submit
        Gui, 1: show
      Return

      WizardEscape:
      WizardClose:
        Gui, Wizard: Destroy
        Gui, 1: Show
      Return
    }
  }

  { ; Individual Menus - LootColorsMenu, OHB_Editor, FlaskMenu, UtilityMenu
    LootColorsMenu()
    {
      DrawLootColors:
        Static LG_Add, LG_Rem
        Global LootColors, LG_Vary
        Gui, Submit
        CheckGamestates := False
        gui,LootColors: new, LabelLootColors
        gui,LootColors: -MinimizeBox
        Gui LootColors: Add, Checkbox, section gUpdateExtra  vLootVacuum Checked%LootVacuum%   xm+5 ym+8 , Enable Loot Vacuum
        
        Gui,LootColors: Add, DropDownList, gUpdateExtra vAreaScale w45 xm+5 y+8,  0|30|40|50|60|70|80|90|100|200|300|400|500
        GuiControl,LootColors: ChooseString, AreaScale, %AreaScale%
        Gui,LootColors: Add, Text,                     x+3 yp+5              , Area around mouse
        Gui,LootColors: Add, DropDownList, gUpdateExtra vLVdelay w45 x+5 yp-5,  0|15|30|45|60|75|90|105|120|135|150|195|300
        GuiControl,LootColors: ChooseString, LVdelay, %LVdelay%
        Gui,LootColors: Add, Text,                     x+3 yp+5              , Delay after click
        gui,LootColors: add, CheckBox, gUpdateExtra vYesLootChests Checked%YesLootChests% Right xm h22, Open Containers?
        Gui,LootColors:  +Delimiter?
        Gui,LootColors: Add, ComboBox, x+5 w210 vChestStr gUpdateStringEdit , %ChestStr%??"%1080_ChestStr%"?"%1050_ChestStr%"
        Gui,LootColors:  +Delimiter|
        gui,LootColors: add, CheckBox, gUpdateExtra vYesLootDelve Checked%YesLootDelve% Right xm h22, Delve Containers?
        Gui,LootColors:  +Delimiter?
        Gui,LootColors: Add, ComboBox, x+5 w210 vDelveStr gUpdateStringEdit , %DelveStr%??"%1080_DelveStr%"
        Gui,LootColors:  +Delimiter|
        gui,LootColors: add, groupbox,% "section xm y+10 w330 h" 24 * (LootColors.Count() / 2) + 30 , Loot Colors:
        gui,LootColors: add, Button, gSaveLootColorArray yp-5 xp+70 h22 w80, Save to INI
        gui,LootColors: add, Button, gAdjustLootGroup vLG_Add yp x+5 h22 wp, Add Color Set
        gui,LootColors: add, Button, gAdjustLootGroup vLG_Rem yp x+5 h22 wp, Rem Color Set
        Item := 0
        For k, color in LootColors
        {
          ; color := val ; hexBGRToRGB(Format("0x{1:06X}",val))
          If !Mod(k,2) ;Check for a remainder when dividing by 2, this groups the colors
          {
            gui,LootColors: add, Progress, x+1 yp w50 h20 c%color% BackgroundBlack,100
            gui,LootColors: add, Button, gResampleLootColor yp x+5 h20,% "Resample " Item
            continue
          }
          Item++
          If A_Index = 1
          {
            gui,LootColors: add, text, yp+38 xs+10,% "Background " Item " Colors: "
            gui,LootColors: add, Progress, x+10 yp-5 w50 h20 c%color% BackgroundBlack,100
            continue
          }
          gui,LootColors: add, text, yp+29 xs+10,% "Background " Item " Colors: "
          gui,LootColors: add, Progress, x+10 yp-5 w50 h20 c%color% BackgroundBlack,100
        }
        Gui,LootColors: show,,Loot Vacuum settings
      return

      AdjustLootGroup:
        Global LootColors
        Gui, Submit
        ind := LootColors.MaxIndex()
        If (A_GuiControl = "LG_Add")
        {
          LootColors[ind + 1] := 0xFFFFFF
          LootColors[ind + 2] := 0xFFFFFF
        }
        Else If (A_GuiControl = "LG_Rem" && ind > 2)
        {
          LootColors.Pop(ind)
          LootColors.Pop(ind - 1)
        }
        Gui, LootColors: Destroy
        LootColorsMenu()
      Return

      ResampleLootColor:
        ; Thread, NoTimers, True ; Critical
        RemoveToolTip()
        PauseTooltips := 1
        groupNumber := StrSplit(A_GuiControl, A_Space)[2]
        MO_Index := (BG_Index := groupNumber * 2) - 1
        IfWinExist, ahk_group POEGameGroup
        {
          WinActivate, ahk_group POEGameGroup
        } else {
          MsgBox % "PoE Window does not exist. `nCannot sample the loot color."
          Return
        }
        ToolTip,% "Press ""A"" to sample loot background"
          . "`nHold Escape and press ""A"" to cancel"
          , % ScrCenter.X - 115 , % ScrCenter.Y - GameH // 3
        KeyWait, a, D L
        ToolTip
        KeyWait, a
        If GetKeyState("Escape", "P")
        {
          MsgBox % "Escape key was held`n"
          . "Canceling the sample!"
          Gui, LootColors: Show
          Exit
        }
        if WinActive(ahk_group POEGameGroup){
          BlockInput, MouseMove
          MouseGetPos, mX, mY
          ScreenShot(), BG_Color := ScreenShot_GetColor(mX,mY)
          LootColors[BG_Index] := Format("0x{1:06X}",BG_Color)
          Sleep, 100
          SendInput {%hotkeyLootScan% down}
          Sleep, 200
          ScreenShot(), MO_Color := ScreenShot_GetColor(mX,mY)
          LootColors[MO_Index] := Format("0x{1:06X}",MO_Color)
          SendInput {%hotkeyLootScan% up}
          BlockInput, MouseMoveOff
        } else {
          MsgBox % "PoE Window is not active. `nSampling the loot color didn't work"
          Gui, LootColors: Show
          Exit
        }
        Gui, LootColors: Destroy
        PauseTooltips := 0
        LootColorsMenu()
        Thread, NoTimers, False    ;End Critical
      Return

      SaveLootColorArray:
        LCstr := hexArrToStr(LootColors)
        IniWrite, %LCstr%, %A_ScriptDir%\save\Settings.ini, Loot Colors, LootColors
        LootScan(1)
        MsgBox % "LootColors saved with the following hex values:"
          . "`n" . LCstr
      Return

      LootColorsClose:
      LootColorsEscape:
        Gui, LootColors: Destroy
        hotkeys()
      Return
    }

    OHB_Editor()
    {
      Static OHB_Width := 104, OHB_Height := 1, OHB_Variance := 1, OHB_LR_border:=1, OHB_Split := ToRGB(0x221415), Initialized := 0, OHB_CReset, OHB_Test
      global OHB_Preview,OHB_r,OHB_g,OHB_b, OHB_Color = 0x221415,OHB_StringEdit
      If !Initialized
      {
        Gui, OHB: new
        Gui, OHB: +AlwaysOnTop
        Gui, OHB: Font, cBlack s20
        Gui, OHB: add, Text, xm , Output String:
        Gui, OHB: add, Button, x+120 yp hp wp vOHB_Test gOHBUpdate, Test String
        Gui, OHB: Font,
        Gui, OHB: add, edit, xm vOHB_StringEdit gOHBUpdate w480 h25, % """" Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border) """"
        Gui, OHB: Font, cBlack s20
        Gui, OHB: add, text, xm y+35, Width:
        Gui, OHB: add, text, x+0 yp w65, %OHB_Width%
        Gui, OHB: add, UpDown, vOHB_Width gOHBUpdate Range20-300 , %OHB_Width%
        Gui, OHB: add, text, x+20 , Height:
        Gui, OHB: add, text, x+0 yp w40, %OHB_Height%
        Gui, OHB: add, UpDown, vOHB_Height gOHBUpdate Range1-5 , %OHB_Height%
        Gui, OHB: add, text, x+20 , Variance:
        Gui, OHB: add, text, x+0 yp w40, %OHB_Variance%
        Gui, OHB: add, UpDown, vOHB_Variance gOHBUpdate , %OHB_Variance%

        Gui, OHB: add, Edit, xm y+35 w140 h35 vOHB_Color gOHBUpdate, %OHB_Color%
        Gui, OHB: add, text, x+20 yp, R:
        Gui, OHB: add, text, x+0 yp w65,% OHB_Split.r
        Gui, OHB: add, updown, vOHB_r gOHBUpdate range0-255, % OHB_Split.r
        Gui, OHB: add, text, x+20 yp, G:
        Gui, OHB: add, text, x+0 yp w65,% OHB_Split.g
        Gui, OHB: add, updown, vOHB_g gOHBUpdate range0-255, % OHB_Split.g
        Gui, OHB: add, text, x+20 yp, B:
        Gui, OHB: add, text, x+0 yp w65,% OHB_Split.b
        Gui, OHB: add, updown, vOHB_b gOHBUpdate range0-255, % OHB_Split.b
        Gui, OHB: add, Progress, xm y+5 w140 h40 vOHB_Preview c%OHB_Color% BackgroundBlack,100
        Gui, OHB: add, Button, x+90 yp hp wp+40 vOHB_CReset gOHBUpdate, Reset Color
      }
      Gui, OHB: show , w535 h300, OHB String Builder
      Return

      OHBUpdate:
        If (A_GuiControl = "OHB_Test")
        {
          If GamePID
          {
            Gui, OHB: Submit
            WinActivate, %GameStr%
            Sleep, 145
            WinGetPos, GameX, GameY, GameW, GameH
          }
          Else
          {
            MsgBox, 262144, Cannot find game, Make sure you have the game open
            Return
          }
          If (Bar:=FindText(GameX + Round((GameW / 2)-(OHB_Width/2 + 1)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2 + 1)+(OHB_Width/2)), Round(GameH / (1080 / 370)) , 0, 0, OHB_StringEdit))
          {
            MsgBox, 262144, String Found, OHB string was found!`nMake sure the highlighted matched area is the entire width of the healthbar`nThe red and blue flashing boxes should go to the very inner edge`n`nIf you are done, copy the string into the String Tab 
            MouseTip(Bar.1.1, Bar.1.2, (Bar.1.3<2?2:Bar.1.3), (Bar.1.4<2?2:Bar.1.4))
            OHB_Editor()
          }
          Else
          {
            MsgBox, 262144, Cannot find string, OHB string was not found!`nMake sure the width is an even number`nTry reset the color if its adjusted
            OHB_Editor()
          }
        }
        Else If (A_GuiControl = "OHB_EditorBtn")
        {
          Gui,Strings: submit
          OHB_Editor()
          return
        }
        Else
        Gui, OHB: Submit, NoHide
        If (A_GuiControl = "OHB_r" || A_GuiControl = "OHB_g" || A_GuiControl = "OHB_b")
        {
          OHB_Split.r := OHB_r, OHB_Split.g := OHB_g, OHB_Split.b := OHB_b, OHB_Color := ToHex(OHB_Split)
          GuiControl,OHB: , OHB_Color, %OHB_Color%
          GuiControl,OHB: +c%OHB_Color%, OHB_Preview
        }
        Else If (A_GuiControl = "OHB_Color" || A_GuiControl = "OHB_CReset")
        {
          If (A_GuiControl = "OHB_CReset")
          {
            OHB_Color = 0x221415
            GuiControl,OHB: , OHB_Color, %OHB_Color%
          }
          OHB_Split := ToRGB(OHB_Color)
          GuiControl,OHB: , OHB_r, % OHB_Split.r
          GuiControl,OHB: , OHB_g, % OHB_Split.g
          GuiControl,OHB: , OHB_b, % OHB_Split.b
          GuiControl,OHB: +c%OHB_Color%, OHB_Preview
        }
        GuiControl, , OHB_StringEdit, % """" Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border) """"
      Return

      OHBGuiClose:
      OHBGuiEscape:
        Gui, OHB: hide
        Gui, Strings: show
      return
    }

    ; Build Per Character settings Menu
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    perCharMenu(){
      Global
      static Built := False

      If !Built
      {
        Built := True
        Gui, perChar: new, AlwaysOnTop

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox, xm ym w565 h405, Per Character Settings
        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,         Section    w265 h40        xp+10   yp+20,         Character Type:
        Gui, perChar: Font,
        Gui, perChar: Font, cRed
        Gui, perChar: Add, Radio, %   "Group vtypeLife Checked" WR.perChar.Setting.typeLife     " xs+10 ys+20", Life
        Gui, perChar: Font, cPurple
        Gui, perChar: Add, Radio, %       "vtypeHybrid Checked" WR.perChar.Setting.typeHybrid   " x+10 yp",     Hybrid
        Gui, perChar: Font, cBlue
        Gui, perChar: Add, Radio, %           "vtypeES Checked" WR.perChar.Setting.typeES       " x+10 yp",     ES
        Gui, perChar: Add, Checkbox, %  "vtypeEldritch Checked" WR.perChar.Setting.typeEldritch " x+8 yp" ,     Eldritch Battery
        Gui, perChar: Font
        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h66        xs   y+10 ,         Auto-Quit Settings
        Gui, perChar: Font,
        Gui, perChar: Add, Text,                     xs+10   yp+22,         Quit via:
        Gui, perChar: Add, Radio, % "Group vquitDC        Checked" WR.perChar.Setting.quitDC     " x+8 y+-13",   Disconnect
        Gui, perChar: Add, Radio,     %   "vquitPortal    Checked" WR.perChar.Setting.quitPortal " x+8 yp"   ,   Portal
        Gui, perChar: Add, Radio,     %   "vquitExit      Checked" WR.perChar.Setting.quitExit   " x+8 yp"   ,   /exit
        Gui, perChar: Add, Slider, NoTicks vquitBelow Thick20 TickInterval10 ToolTip h21 w160 xs+5 y+3       , % WR.perChar.Setting.quitBelow
        Gui, perChar: Add, Checkbox,  %   "vquitLogBackIn Checked" WR.perChar.Setting.LogBackIn  " x+5 yp+7" ,   Log back in

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h85        xs   y+10 ,         Movement Settings
        Gui, perChar: Font,
        Gui, perChar: Add, Text,                     xs+10   ys+20,         Movement Trigger Delay (in seconds):
        Gui, perChar: Add, Edit,       vmovementDelay  x+10 Center  yp   w55 h17, % WR.perChar.Setting.movementDelay
        Gui, perChar: Font, s8 cBlack
        Gui, perChar: Add,GroupBox, xs+10 y+1 w245 h40    center                  , Movement Triggers with Attack Keys
        Gui, perChar: Font,
        Gui, perChar: Add, Checkbox, % "vmovementMainAttack +BackgroundTrans Checked" WR.perChar.Setting.movementMainAttack " xp+25 yp+20 ", Main Attack
        Gui, perChar: Add, Checkbox, % "vmovementSecondaryAttack +BackgroundTrans Checked" WR.perChar.Setting.movementSecondaryAttack " xp+98 yp", Secondary Attack

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h40        xs   y+15 ,         Auto Level Gems
        Gui, perChar: Font,
        Gui, perChar: Add, Checkbox, % "vautolevelgemsEnable Checked" WR.perChar.Setting.autolevelgemsEnable "   xs+35 yp+18"     , Enable
        Gui, perChar: Add, Checkbox, % "vautolevelgemsWait Checked" WR.perChar.Setting.autolevelgemsWait "    xp+98 yp "  , Wait for Mouse

        ; , "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
        ; , "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h65        xs   y+10 ,         First Swap Gem/Item
        Gui, perChar: Font,
        Gui, perChar: Add, Edit,  center     vswap1Xa         xs+5  yp+20     w34  h17, % WR.perChar.Setting.swap1Xa
        Gui, perChar: Add, Edit,  center     vswap1Ya           x+3                w34  h17, % WR.perChar.Setting.swap1Ya
        Gui, perChar: Add, Button,  gWR_Update vWR_Btn_Locate_CurrentGem  x+3   yp  hp , Locate A
        Gui, perChar: Add, Checkbox, % "vswap1Item Checked" WR.perChar.Setting.swap1Item " x+3  yp+2"               , Use as Item Swap?
        Gui, perChar: Add, Edit,   center    vswap1Xb         xs+5        y+5   w34  h17,   % WR.perChar.Setting.swap1Xb
        Gui, perChar: Add, Edit,   center    vswap1Yb         x+3                w34  h17,   % WR.perChar.Setting.swap1Yb
        Gui, perChar: Add, Button,      gWR_Update vWR_Btn_Locate_AlternateGem  x+3   yp    hp , Locate B
        Gui, perChar: Add, Checkbox, %  "vswap1AltWeapon Checked" WR.perChar.Setting.swap1AltWeapon "  x+3  yp+2"  , Swap Weapon for B?

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h65        xs   y+10 ,         Second Swap Gem/Item
        Gui, perChar: Font,
        Gui, perChar: Add, Edit,   center vswap2Xa xs+5 yp+20   w34  h17,   % WR.perChar.Setting.swap2Xa
        Gui, perChar: Add, Edit,   center vswap2Ya x+3 w34  hp,   % WR.perChar.Setting.swap2Ya
        Gui, perChar: Add, Button, gWR_Update vWR_Btn_Locate_CurrentGem2      x+3   yp    hp , Locate A
        Gui, perChar: Add, Checkbox, % "vswap2Item Checked" WR.perChar.Setting.swap2Item " x+3  yp+2" , Use as Item Swap?
        Gui, perChar: Add, Edit, center vswap2Xb xs+5 y+5   w34  h17,   % WR.perChar.Setting.swap2Xb
        Gui, perChar: Add, Edit, center vswap2Yb x+3 w34  hp,   % WR.perChar.Setting.swap2Yb
        Gui, perChar: Add, Button,      gWR_Update vWR_Btn_Locate_AlternateGem2      x+3   yp    hp , Locate B
        Gui, perChar: Add, Checkbox, %  "vswap2AltWeapon Checked" WR.perChar.Setting.swap2AltWeapon "  x+3  yp+2"  , Swap Weapon for B?


        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,  xs+280 ym+20 w265 h150 Section, Channeling Stack Re-Press
        Gui, perChar: Font,
        Gui, perChar: Add, CheckBox, % "vchannelrepressEnable Checked" WR.perChar.Setting.channelrepressEnable "  Right x+-65 ys+2 ", Enable
        Gui, perChar: Add, Edit,  vchannelrepressIcon xs+5 ys+19 w150 h21, % WR.perChar.Setting.channelrepressIcon
        Gui, perChar: Add, Text, x+4 yp+3, Icon to Find
        Gui, perChar: Add, Edit,  vchannelrepressStack xs+5 y+15 w150 h21, % WR.perChar.Setting.channelrepressStack
        Gui, perChar: Add, Text, x+4 yp+3, Stack Digit
        Gui, perChar: Add, Edit,  vchannelrepressKey xs+5 y+15 w150 h21, % WR.perChar.Setting.channelrepressKey
        Gui, perChar: Add, Text, x+4 yp+3, Key to Re-Press
        Gui, perChar: Add, Text, xs+15 y+12, Stack Search Offset - Bottom Edge of Buff Icon
        Gui, perChar: Font, Bold s9 cBlack
        Gui, perChar: Add, Text, xs+15 y+5, X1:
        Gui, perChar: Font,
        Gui, perChar: Add, Text, x+2 yp w29 hp,
        Gui, perChar: Add, UpDown,  vchannelrepressOffsetX1 hp center Range-150-150, % WR.perChar.Setting.channelrepressOffsetX1
        Gui, perChar: Font, Bold s9 cBlack
        Gui, perChar: Add, Text, x+10 yp, Y1:
        Gui, perChar: Font,
        Gui, perChar: Add, Text, x+2 yp w29 hp,
        Gui, perChar: Add, UpDown,  vchannelrepressOffsetY1 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetY1
        Gui, perChar: Font, Bold s9 cBlack
        Gui, perChar: Add, Text, x+10 yp, X2:
        Gui, perChar: Font,
        Gui, perChar: Add, Text, x+2 yp w29 hp,
        Gui, perChar: Add, UpDown,  vchannelrepressOffsetX2 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetX2
        Gui, perChar: Font, Bold s9 cBlack
        Gui, perChar: Add, Text, x+10 yp, Y2:
        Gui, perChar: Font,
        Gui, perChar: Add, Text, x+2 yp w29 hp,
        Gui, perChar: Add, UpDown,  vchannelrepressOffsetY2 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetY2

        Gui, perChar: Font, Bold s9 cBlack, Arial
        Gui, perChar: Add, GroupBox,     Section  w265 h128        xs   y+13 ,         Auto-Detonate Mines
        Gui, perChar: Font,
        Gui, perChar: Add, Checkbox, % "vautominesEnable Checked"  WR.perChar.Setting.autominesEnable  " xs+15  ys+23"       , Enable
        Gui, perChar: Add, Edit,        vautominesBoomDelay  h18  xs+90  yp-2  Number Limit w30        , % WR.perChar.Setting.autominesBoomDelay
        Gui, perChar: Add, Text, x+5 yp+2, Delay between Detonate
        Gui, perChar: Add, GroupBox, center xs+5 y+7 w255 h37, Double-Tap to Pause Mines
        Gui, perChar: Add, Edit,        vautominesPauseDoubleTapSpeed  h18  xp+10 yp+16  Number Limit w30        , % WR.perChar.Setting.autominesPauseDoubleTapSpeed 
        Gui, perChar: Add, Text, x+5  yp+2 , Double-Tap Speed
        Gui, perChar: Add, Text, xs+150 yp , Key
        Gui, perChar: Add, Edit,        vautominesPauseKey  h18  x+5  yp-2  w50        , % WR.perChar.Setting.autominesPauseKey
        Gui, perChar: Add, GroupBox, center xs+5 y+7 w255 h37, Dash on Detonate
        Gui, perChar: Add, CheckBox, %  "xp+15 yp+16 vautominesSmokeDashEnable Checked" WR.perChar.Setting.autominesSmokeDashEnable, Enable Smoke-Dash
        Gui, perChar: Add, Text, xs+150 yp , Key
        Gui, perChar: Add, Edit,        vautominesSmokeDashKey  h18  x+5  yp-2  w50        , % WR.perChar.Setting.autominesSmokeDashKey
        Gui, perChar: Font,
        Gui, perChar: show, w585 h420
      }
      Return

      perCharSaveValues:
        for k, kind in ["typeLife", "typeHybrid", "typeES", "typeEldritch"
        , "quitDC", "quitPortal", "quitExit", "quitBelow", "quitLogBackIn"
        , "movementDelay", "movementMainAttack", "movementSecondaryAttack"
        , "channelrepressEnable", "channelrepressIcon", "channelrepressStack", "channelrepressKey", "channelrepressOffsetX1", "channelrepressOffsetY1", "channelrepressOffsetX2", "channelrepressOffsetY2"
        , "autominesEnable", "autominesBoomDelay", "autominesPauseDoubleTapSpeed", "autominesPauseKey", "autominesSmokeDashEnable", "autominesSmokeDashKey"
        , "autolevelgemsEnable", "autolevelgemsWait"
        , "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
        , "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"]
          WR.perChar.Setting[kind] := %kind%
        Settings("perChar","Save")
        Return
      perCharGuiClose:
      perCharGuiEscape:
        Built := False
        Gui, Submit, NoHide
        Gosub, perCharSaveValues
        Gui, perChar: Destroy
        Return
    }
    ; Build Flask Menu
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FlaskMenu(){
      Global
      static Built := {}, which := 1
      RegExMatch(A_GuiControl, "\d+", slot)

      If !Built[slot]
      {
        Built[slot] := True
        Gui, Flask%slot%: new, AlwaysOnTop

        Gui, Flask%slot%: Add, GroupBox, section xm ym w500 h260, Flask Slot %slot%

        Gui, Flask%slot%: Add, GroupBox, center xs+10 yp+25 w100 h45, Cooldown
        Gui, Flask%slot%: Add, Edit,  center     vFlask%slot%CD  xs+20   yp+20  w80  h17, %  WR.Flask[slot].CD

        Gui, Flask%slot%: Add, GroupBox, center xs+10 y+15 w100 h45, Keys to Press
        Gui, Flask%slot%: Add, Edit,    center   vFlask%slot%Key       xs+20   yp+20   w80  h17, %   WR.Flask[slot].Key

        Gui, Flask%slot%: Add, GroupBox, center xs+10 y+15 w100 h55, CD Group
        Gui, Flask%slot%: Add, DropDownList, % "vFlask" slot "Group xs+20 yp+20 w80" , a|b|c|d|e|Mana|Life|ES|QuickSilver|Defense
        GuiControl,Flask%slot%: ChooseString, Flask%slot%Group,% WR.Flask[slot].Group

        Gui, Flask%slot%: Add, GroupBox, center xs+10 y+20 w100 h55, Group Cooldown
        Gui, Flask%slot%: Add, Edit,  center     vFlask%slot%GroupCD  xs+20   yp+20  w80  h17, %  WR.Flask[slot].GroupCD

        Gui, Flask%slot%: Add, GroupBox, Section center x+30 ys+25 w100 h45, Pop All Flasks
        Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "PopAll  xs+10   yp+20 Checked" WR.Flask[slot].PopAll, Include

        Gui, Flask%slot%: Add, GroupBox, center xs y+20 w100 h45, Trigger on Move
        Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Move xs+10   yp+20 Checked" WR.Flask[slot].Move , Enable

        Gui, Flask%slot%: Add, GroupBox, center xs y+20 w100 h65, Trigger with Attack
        Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "MainAttack xs+10 yp+20 Checked" WR.Flask[slot].MainAttack, Main
        Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "SecondaryAttack xs+10   y+10 Checked" WR.Flask[slot].SecondaryAttack, Secondary
        
        backColor := "E0E0E0"
        Gui, Flask%slot%: Add, GroupBox, Section center x+35 ys w240 h150, Resource Triggers
        setColor := "Red"
        Gui, Flask%slot%: Font, s16, Consolas
        Gui, Flask%slot%: Add, Text, xs+10 ys+18 c%setColor%, L`%
        Gui, Flask%slot%: Add, Text,% "vFlask" slot "Life hwndFlask" slot "LifeHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].Life
        ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%LifeHWND
        Flask%slot%Life_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].Life , backColor , setColor , 1 , "Flask" slot "Life" , 0 , 0 , 1)
        setColor := "51DEFF"
        Gui, Flask%slot%: Add, Text, xs+10 y+13 c%setColor%, E`%
        Gui, Flask%slot%: Add, Text,% "vFlask" slot "ES hwndFlask" slot "ESHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].ES
        ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%ESHWND
        Flask%slot%ES_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].ES , backColor , setColor , 1 , "Flask" slot "ES" , 0 , 0 , 1)
        setColor := "Blue"
        Gui, Flask%slot%: Add, Text, xs+10 y+13 c%setColor%, M`%
        Gui, Flask%slot%: Add, Text,% "vFlask" slot "Mana hwndFlask" slot "ManaHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].Mana
        Gui, Flask%slot%: Font,
        ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%ManaHWND
        Flask%slot%Mana_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].Mana , backColor , setColor , 1 , "Flask" slot "Mana" , 0 , 0 , 1)
        Gui, Flask%slot%: Add, Text, xs+10 y+13 , Resource Trigger Condition:
        Gui, Flask%slot%: Add, Radio, % "vFlask" slot "Condition  x+5   yp-5 h22 Checked" (WR.Flask[slot].Condition==1?1:0), Any
        Gui, Flask%slot%: Add, Radio, %                              " x+5 hp  yp Checked" (WR.Flask[slot].Condition==2?1:0), All

        Gui, Flask%slot%: show, w520 h280
      }
      Return

      FlaskSaveValues:
        for k, kind in ["CD", "GroupCD", "Key", "MainAttack", "SecondaryAttack", "PopAll", "Move", "Group", "Condition"]
          WR.Flask[which][kind] := Flask%which%%kind%
        for k, kind in ["Life", "ES", "Mana"]
          WR.Flask[which][kind] := Flask%which%%kind%_Slider.Slider_Value 
        FileDelete, %A_ScriptDir%\save\Flask.json
        JSONtext := JSON.Dump(WR.Flask,,2)
        FileAppend, %JSONtext%, %A_ScriptDir%\save\Flask.json
        Return
      Flask1GuiClose:
      Flask1GuiEscape:
        Built[1] := False
        Gui, Submit, NoHide
        which := 1
        Gosub, FlaskSaveValues
        Gui, Flask1: Destroy
        Return
      Flask2GuiClose:
      Flask2GuiEscape:
        Built[2] := False
        Gui, Submit, NoHide
        which := 2
        Gosub, FlaskSaveValues
        Gui, Flask2: Destroy
        Return
      Flask3GuiClose:
      Flask3GuiEscape:
        Built[3] := False
        Gui, Submit, NoHide
        which := 3
        Gosub, FlaskSaveValues
        Gui, Flask3: Destroy
        Return
      Flask4GuiClose:
      Flask4GuiEscape:
        Built[4] := False
        Gui, Submit, NoHide
        which := 4
        Gosub, FlaskSaveValues
        Gui, Flask4: Destroy
        Return
      Flask5GuiClose:
      Flask5GuiEscape:
        Built[5] := False
        Gui, Submit, NoHide
        which := 5
        Gosub, FlaskSaveValues
        Gui, Flask5: Destroy
        Return
    }
    ; Build Utility Menu
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    UtilityMenu(){
      Global
      static Built := {}, which := 1
      RegExMatch(A_GuiControl, "\d+", slot)

      If !Built[slot]
      {
        Built[slot] := True
        Gui, Utility%slot%: new, AlwaysOnTop

        Gui, Utility%slot%: Add, GroupBox, section xm ym w500 h325, Utility Slot %slot%

        Gui, Utility%slot%: Add, GroupBox, Section center xs+10 yp+20 w110 h65, Enable Utility
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Enable xs+10   yp+20 Checked" WR.Utility[slot].Enable , Enable
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "OnCD xs+10   y+8 Checked" WR.Utility[slot].OnCD , Cast on CD

        Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h45, Cooldown
        Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%CD  xs+10   yp+20  w80  h17, %  WR.Utility[slot].CD

        Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h45, Keys to Press
        Gui, Utility%slot%: Add, Edit,    center   vUtility%slot%Key       xs+10   yp+20   w80  h17, %   WR.Utility[slot].Key

        Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h55, CD Group
        Gui, Utility%slot%: Add, DropDownList, % "vUtility" slot "Group xs+10 yp+20 w80" , u1|u2|u3|u4|u5|u6|u7|u8|u9|u10|Mana|Life|ES|QuickSilver|Defense
        GuiControl,Utility%slot%: ChooseString, Utility%slot%Group,% WR.Utility[slot].Group

        Gui, Utility%slot%: Add, GroupBox, center xs y+20 w110 h55, Group Cooldown
        Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%GroupCD  xs+10   yp+20  w80  h17, %  WR.Utility[slot].GroupCD

        Gui, Utility%slot%: Add, GroupBox, Section center xs+120 ys w110 h45, Pop All Flasks
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "PopAll xs+10   yp+20 Checked" WR.Utility[slot].PopAll , Include

        Gui, Utility%slot%: Add, GroupBox, center xs y+20 w110 h45, Trigger on Move
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Move xs+10   yp+20 Checked" WR.Utility[slot].Move , Enable

        Gui, Utility%slot%: Add, GroupBox, center xs y+20 w110 h65, Trigger with Attack
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "MainAttack xs+10 yp+20 Checked" WR.Utility[slot].MainAttack, Main
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "SecondaryAttack xs+10   y+10 Checked" WR.Utility[slot].SecondaryAttack, Secondary

        backColor := "E0E0E0"
        Gui, Utility%slot%: Add, GroupBox, Section center x+35 ys w240 h150, Resource Triggers
        setColor := "Red"
        Gui, Utility%slot%: Font, s16, Consolas
        Gui, Utility%slot%: Add, Text, xs+10 ys+18 c%setColor%, L`%
        Gui, Utility%slot%: Add, Text,% "vUtility" slot "Life hwndUtility" slot "LifeHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].Life
        ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%LifeHWND
        Utility%slot%Life_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].Life , backColor , setColor , 1 , "Utility" slot "Life" , 0 , 0 , 1)
        setColor := "51DEFF"
        Gui, Utility%slot%: Add, Text, xs+10 y+13 c%setColor%, E`%
        Gui, Utility%slot%: Add, Text,% "vUtility" slot "ES hwndUtility" slot "ESHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].ES
        ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%ESHWND
        Utility%slot%ES_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].ES , backColor , setColor , 1 , "Utility" slot "ES" , 0 , 0 , 1)
        setColor := "Blue"
        Gui, Utility%slot%: Add, Text, xs+10 y+13 c%setColor%, M`%
        Gui, Utility%slot%: Add, Text,% "vUtility" slot "Mana hwndUtility" slot "ManaHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].Mana
        Gui, Utility%slot%: Font,
        ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%ManaHWND
        Utility%slot%Mana_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].Mana , backColor , setColor , 1 , "Utility" slot "Mana" , 0 , 0 , 1)
        Gui, Utility%slot%: Add, Text, xs+10 y+13 , Resource Trigger Condition:
        Gui, Utility%slot%: Add, Radio, % "vUtility" slot "Condition  x+5   yp-5 h22 Checked" (WR.Utility[slot].Condition==1?1:0), Any
        Gui, Utility%slot%: Add, Radio, %                              " x+5 hp  yp Checked" (WR.Utility[slot].Condition==2?1:0), All


        Gui, Utility%slot%: Add, GroupBox, Section center xs-120 y+55 w360 h100, Trigger when Sample String not found
        Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%Icon  xs+10   yp+20  w340  h17, %  WR.Utility[slot].Icon

        Gui, Utility%slot%: Add, Text, xs+10  y+8 , Search Area:
        Gui, Utility%slot%: Add, Radio, % "vUtility" slot "IconSearch  x+10   yp-4 h22 Checked" (WR.Utility[slot].IconSearch==1?1:0), Buff Area
        Gui, Utility%slot%: Add, Radio, %                              " x+9 hp  yp Checked" (WR.Utility[slot].IconSearch==2?1:0), DeBuff Area
        Gui, Utility%slot%: Add, Radio, %                              " x+9 hp  yp Checked" (WR.Utility[slot].IconSearch==3?1:0), Custom
        Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "IconShown xs+10   y+5 hp Checked" WR.Utility[slot].IconShown , Invert to Shown
        Gui, Utility%slot%: Add, Button, x+10 yp, Show Utility %slot% Area
        Gui, Utility%slot%: Add, Button, x+10 yp wp, Set Utility %slot% Area
        Utility%slot%IconArea := WR.Utility[slot].IconArea
        Gui, Utility%slot%: show, w520 h340
      }
      Return

      UtilitySaveValues:
        for k, kind in ["Enable", "OnCD", "CD", "GroupCD", "Key", "MainAttack", "SecondaryAttack", "PopAll", "Icon", "IconShown", "IconSearch", "IconArea", "Move", "Group", "Condition"]
          WR.Utility[which][kind] := Utility%which%%kind%
        for k, kind in ["Life", "ES", "Mana"]
          WR.Utility[which][kind] := Utility%which%%kind%_Slider.Slider_Value 
    
        FileDelete, %A_ScriptDir%\save\Utility.json
        JSONtext := JSON.Dump(WR.Utility,,2)
        FileAppend, %JSONtext%, %A_ScriptDir%\save\Utility.json
        Return
      Utility1GuiClose:
      Utility1GuiEscape:
        Built[1] := False
        Gui, Submit, NoHide
        which := 1
        Gosub, UtilitySaveValues
        Gui, Utility1: Destroy
        Return
      Utility2GuiClose:
      Utility2GuiEscape:
        Built[2] := False
        Gui, Submit, NoHide
        which := 2
        Gosub, UtilitySaveValues
        Gui, Utility2: Destroy
        Return
      Utility3GuiClose:
      Utility3GuiEscape:
        Built[3] := False
        Gui, Submit, NoHide
        which := 3
        Gosub, UtilitySaveValues
        Gui, Utility3: Destroy
        Return
      Utility4GuiClose:
      Utility4GuiEscape:
        Built[4] := False
        Gui, Submit, NoHide
        which := 4
        Gosub, UtilitySaveValues
        Gui, Utility4: Destroy
        Return
      Utility5GuiClose:
      Utility5GuiEscape:
        Built[5] := False
        Gui, Submit, NoHide
        which := 5
        Gosub, UtilitySaveValues
        Gui, Utility5: Destroy
        Return
      Utility6GuiClose:
      Utility6GuiEscape:
        Built[6] := False
        Gui, Submit, NoHide
        which := 6
        Gosub, UtilitySaveValues
        Gui, Utility6: Destroy
        Return
      Utility7GuiClose:
      Utility7GuiEscape:
        Built[7] := False
        Gui, Submit, NoHide
        which := 7
        Gosub, UtilitySaveValues
        Gui, Utility7: Destroy
        Return
      Utility8GuiClose:
      Utility8GuiEscape:
        Built[8] := False
        Gui, Submit, NoHide
        which := 8
        Gosub, UtilitySaveValues
        Gui, Utility8: Destroy
        Return
      Utility9GuiClose:
      Utility9GuiEscape:
        Built[9] := False
        Gui, Submit, NoHide
        which := 9
        Gosub, UtilitySaveValues
        Gui, Utility9: Destroy
        Return
      Utility10GuiClose:
      Utility10GuiEscape:
        Built[10] := False
        Gui, Submit, NoHide
        which := 10
        Gosub, UtilitySaveValues
        Gui, Utility10: Destroy
        Return
    }
  }

  { ; Ignore list functions - addToBlacklist, BuildIgnoreMenu, UpdateCheckbox, LoadIgnoreArray, SaveIgnoreArray
    IgnoreClose:
    IgnoreEscape:
      SaveIgnoreArray()
      Gui, Ignore: Destroy
      Gui, Inventory: Show
    Return

    addToBlacklist(C, R)
    {
      Loop % Item.Prop.Item_Height
      {
        addNum := A_Index - 1
        addR := R + addNum
        addC := C + 1
        BlackList[C][addR] := True
        If Item.Prop.Item_Width = 2
          BlackList[addC][addR] := True
      }
    }

    BuildIgnoreMenu:
      Gui, Submit
      Gui, Ignore: +LabelIgnore -MinimizeBox +AlwaysOnTop
      Gui, Ignore: Font, Bold
      Gui, Ignore: Add, GroupBox, w660 h305 Section xm ym, Ignored Inventory Slots:
      Gui, Ignore: Add, Picture, w650 h-1 xs+5 ys+15, %A_ScriptDir%\data\InventorySlots.png
      Gui, Ignore: Font
      LoadIgnoreArray()

      Gui, Ignore: Add, Text, w1 h1 xs+25 ys+13, ""
      For C, GridX in InventoryGridX
      {
        If (C != 1)
          Gui, Ignore: Add, Text, w1 h1 x+18 ys+13, ""
        For R, GridY in InventoryGridY
        {
          ++ind
          checkboxStr := "IgnoredSlot_" . C . "_" . R
          checkboxTik := IgnoredSlot[C][R]
          Gui, Ignore: Add, Checkbox, v%checkboxStr% gUpdateCheckbox y+25 h27 Checked%checkboxTik%,% (ind < 10 ? "0" . ind : ind)
        }
      }
      ind=0
      Hotkeys()
      Gui, Ignore: Show
    Return

    UpdateCheckbox:
      Gui, Ignore: Submit, NoHide
      btnArr := StrSplit(A_GuiControl, "_")
      C := btnArr[2]
      R := btnArr[3]
      IgnoredSlot[C][R] := %A_GuiControl%
    Return

    LoadIgnoreArray()
    {
      FileRead, JSONtext, %A_ScriptDir%\save\IgnoredSlot.json
      IgnoredSlot := JSON.Load(JSONtext)
      Return
    }

    SaveIgnoreArray()
    {
      SaveIgnoreArray:
      Gui, Ignore: Submit, NoHide
      JSONtext := JSON.Dump(IgnoredSlot,,2)
      FileDelete, %A_ScriptDir%\save\IgnoredSlot.json
      FileAppend, %JSONtext%, %A_ScriptDir%\save\IgnoredSlot.json
      LoadIgnoreArray()
      Return
    }
  }

  { ; Loot Filter Functions - LaunchLootFilter, LoadArray
    LaunchLootFilter:
      Run, %A_ScriptDir%\data\LootFilter.ahk ; Open the custom loot filter editor
    Return

    LoadArray:
      LoadArray()
    return

    LoadArray()
    {
      FileRead, JSONtext, %A_ScriptDir%\save\LootFilter.json
      LootFilter := JSON.Load(JSONtext)
      If !LootFilter
        LootFilter:={}
    Return
    }
  }

  { ; Gui Update functions - UpdateStash, UpdateExtra, UpdateResolutionScale, UpdateDebug, UpdateUtility
    SaveINI(type:="General") {
      Gui, Submit, NoHide
      If A_GuiControl ~= "UpDown"
      {
        control := StrReplace(A_GuiControl, "UpDown", "")
        IniWrite,% %control%, %A_ScriptDir%\save\Settings.ini,% type,% control
      }
      Else
      IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini,% type,% A_GuiControl
      Return
    }

    SaveGeneral:
      SaveINI("General")
    Return

    SaveChaos:
      SaveINI("Chaos Recipe")
    Return

    SaveChaosRadio:
      Gui, Submit, NoHide
      IniWrite, %ChaosRecipeTypePure%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypePure
      IniWrite, %ChaosRecipeTypeHybrid%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeHybrid
      IniWrite, %ChaosRecipeTypeRegal%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeRegal
      IniWrite, %ChaosRecipeStashMethodDump%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodDump
      IniWrite, %ChaosRecipeStashMethodTab%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodTab
      IniWrite, %ChaosRecipeStashMethodSort%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodSort
    Return

    UpdateStash:
      ; Gui, Submit, NoHide
      Gui, Inventory: Submit, NoHide
      ;Stash Tab Management
      IniWrite, %StashTabCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCurrency
      IniWrite, %StashTabMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMap
      IniWrite, %StashTabDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDivination
      IniWrite, %StashTabGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGem
      IniWrite, %StashTabGemSupport%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemSupport
      IniWrite, %StashTabGemQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemQuality
      IniWrite, %StashTabFlaskQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFlaskQuality
      IniWrite, %StashTabLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabLinked
      IniWrite, %StashTabCollection%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCollection
      IniWrite, %StashTabUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueRing
      IniWrite, %StashTabUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabUniqueDump
      IniWrite, %StashTabInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabInfluencedItem
      IniWrite, %StashTabFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFragment
      IniWrite, %StashTabEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabEssence
      IniWrite, %StashTabBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlight
      IniWrite, %StashTabDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium
      IniWrite, %StashTabMetamorph%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabMetamorph
      IniWrite, %StashTabDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelve
      IniWrite, %StashTabCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting
      IniWrite, %StashTabProphecy%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabProphecy
      IniWrite, %StashTabVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled
      IniWrite, %StashTabYesCurrency%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency
      IniWrite, %StashTabYesMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap
      IniWrite, %StashTabYesDivination%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination
      IniWrite, %StashTabYesGem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem
      IniWrite, %StashTabYesGemSupport%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemSupport
      IniWrite, %StashTabYesGemQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemQuality
      IniWrite, %StashTabYesFlaskQuality%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlaskQuality
      IniWrite, %StashTabYesLinked%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked
      IniWrite, %StashTabYesCollection%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCollection
      IniWrite, %StashTabYesUniqueRing%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing
      IniWrite, %StashTabYesUniqueDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump
      IniWrite, %StashTabYesInfluencedItem%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem
      IniWrite, %StashTabYesBlight%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlight
      IniWrite, %StashTabYesDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium
      IniWrite, %StashTabYesFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment
      IniWrite, %StashTabYesEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence
      IniWrite, %StashTabYesMetamorph%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMetamorph
      IniWrite, %StashTabYesDelve%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelve
      IniWrite, %StashTabYesCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting
      IniWrite, %StashTabYesProphecy%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesProphecy
      IniWrite, %StashTabYesVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled
      IniWrite, %StashTabClusterJewel%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel
      IniWrite, %StashTabYesClusterJewel%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesClusterJewel
      IniWrite, %StashTabDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump
      IniWrite, %StashTabYesDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump
      IniWrite, %StashDumpInTrial%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial
      IniWrite, %StashDumpSkipJC%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpSkipJC
      IniWrite, %StashTabPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive
      IniWrite, %StashTabYesPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive
      IniWrite, %StashTabYesPredictive_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive_Price
      IniWrite, %StashTabGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemVaal
      IniWrite, %StashTabYesGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemVaal
      IniWrite, %StashTabNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice
      IniWrite, %StashTabYesNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice
      IniWrite, %StashTabYesNinjaPrice_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price
    Return

    UpdateExtra:
      If hotkeyPauseMines
        hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, Off
      Gui, Submit, NoHide
      ; Gui, Inventory: Submit, NoHide
      IniWrite, %BranchName%, %A_ScriptDir%\save\Settings.ini, General, BranchName
      IniWrite, %ScriptUpdateTimeInterval%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval
      IniWrite, %ScriptUpdateTimeType%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType
      IniWrite, %DetonateMines%, %A_ScriptDir%\save\Settings.ini, General, DetonateMines
      IniWrite, %DetonateMinesDelay%, %A_ScriptDir%\save\Settings.ini, General, DetonateMinesDelay
      IniWrite, %PauseMinesDelay%, %A_ScriptDir%\save\Settings.ini, General, PauseMinesDelay
      IniWrite, %hotkeyPauseMines%, %A_ScriptDir%\save\Settings.ini, hotkeys, hotkeyPauseMines
      IniWrite, %LootVacuum%, %A_ScriptDir%\save\Settings.ini, General, LootVacuum
      IniWrite, %YesVendor%, %A_ScriptDir%\save\Settings.ini, General, YesVendor
      IniWrite, %YesStash%, %A_ScriptDir%\save\Settings.ini, General, YesStash
      IniWrite, %YesHeistLocker%, %A_ScriptDir%\save\Settings.ini, General, YesHeistLocker
      IniWrite, %YesStashT1%, %A_ScriptDir%\save\Settings.ini, General, YesStashT1
      IniWrite, %YesStashT2%, %A_ScriptDir%\save\Settings.ini, General, YesStashT2
      IniWrite, %YesStashT3%, %A_ScriptDir%\save\Settings.ini, General, YesStashT3
      IniWrite, %YesStashT4%, %A_ScriptDir%\save\Settings.ini, General, YesStashT4
      IniWrite, %YesStashCraftingNormal%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingNormal
      IniWrite, %YesStashCraftingMagic%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingMagic
      IniWrite, %YesStashCraftingRare%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingRare
      IniWrite, %YesStashCraftingIlvl%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvl
      IniWrite, %YesStashCraftingIlvlMin%, %A_ScriptDir%\save\Settings.ini, General, YesStashCraftingIlvlMin
      IniWrite, %YesPredictivePrice%, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice
      IniWrite, %YesSkipMaps%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps
      IniWrite, %YesSkipMaps_eval%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval
      IniWrite, %YesSkipMaps_normal%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal
      IniWrite, %YesSkipMaps_magic%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic
      IniWrite, %YesSkipMaps_rare%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare
      IniWrite, %YesSkipMaps_unique%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique
      IniWrite, %YesSkipMaps_tier%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier
      IniWrite, %YesIdentify%, %A_ScriptDir%\save\Settings.ini, General, YesIdentify
      IniWrite, %YesDiv%, %A_ScriptDir%\save\Settings.ini, General, YesDiv
      IniWrite, %YesMapUnid%, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid
      IniWrite, %YesSortFirst%, %A_ScriptDir%\save\Settings.ini, General, YesSortFirst
      IniWrite, %Latency%, %A_ScriptDir%\save\Settings.ini, General, Latency
      IniWrite, %ClickLatency%, %A_ScriptDir%\save\Settings.ini, General, ClickLatency
      IniWrite, %ClipLatency%, %A_ScriptDir%\save\Settings.ini, General, ClipLatency
      IniWrite, %PopFlaskRespectCD%, %A_ScriptDir%\save\Settings.ini, General, PopFlaskRespectCD
      IniWrite, %ShowOnStart%, %A_ScriptDir%\save\Settings.ini, General, ShowOnStart
      IniWrite, %AutoUpdateOff%, %A_ScriptDir%\save\Settings.ini, General, AutoUpdateOff
      IniWrite, %YesPersistantToggle%, %A_ScriptDir%\save\Settings.ini, General, YesPersistantToggle
      IniWrite, %YesGuiLastPosition%, %A_ScriptDir%\save\Settings.ini, General, YesGuiLastPosition
      IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
      IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
      IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB

      ;Automation Settings
      IniWrite, %YesEnableAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation
      IniWrite, %FirstAutomationSetting%, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting
      IniWrite, %YesEnableNextAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation
      IniWrite, %YesEnableLockerAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableLockerAutomation
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
      IniWrite, %YesEnableAutoSellConfirmationSafe%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmationSafe
      
      ;Automation Metamorph Settings
      IniWrite, %YesFillMetamorph%, %A_ScriptDir%\save\Settings.ini, General, YesFillMetamorph
      IniWrite, %YesClickPortal%, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal
      IniWrite, %RelogOnQuit%, %A_ScriptDir%\save\Settings.ini, General, RelogOnQuit
      IniWrite, %YesLootChests%, %A_ScriptDir%\save\Settings.ini, General, YesLootChests
      IniWrite, %YesLootDelve%, %A_ScriptDir%\save\Settings.ini, General, YesLootDelve
      IniWrite, %CastOnDetonate%, %A_ScriptDir%\save\Settings.ini, General, CastOnDetonate
      IniWrite, %hotkeyCastOnDetonate%, %A_ScriptDir%\save\Settings.ini, General, hotkeyCastOnDetonate
      #MaxThreadsPerHotkey, 1
      If hotkeyPauseMines
        hotkey, $~%hotkeyPauseMines%, PauseMinesCommand, On
      #MaxThreadsPerHotkey, 2
    Return

    UpdateEldritchBattery:
      Gui, Submit, NoHide
      IniWrite, %YesEldritchBattery%, %A_ScriptDir%\save\Settings.ini, General, YesEldritchBattery
      Rescale()
    Return

    UpdateStackRelease:
      Gui, Submit, NoHide
      IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini, StackRelease,% A_GuiControl
    Return

    UpdateStringEdit:
      Gui, Submit, NoHide
      IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini, FindText Strings,% A_GuiControl
      If A_GuiControl = HealthBarStr
        OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
    Return

    UpdateResolutionScale:
      Gui, Submit, NoHide
      IniWrite, %ResolutionScale%, %A_ScriptDir%\save\Settings.ini, General, ResolutionScale
      Rescale()
    Return

    UpdateDebug:
      Gui, Submit, NoHide
      If (DebugMessages)
      {
        GuiControl, Show, YesTimeMS
        GuiControl, Show, YesTimeMS_t
        GuiControl, Show, YesLocation
        GuiControl, Show, YesLocation_t
      }
      Else
      {
        GuiControl, Hide, YesTimeMS
        GuiControl, Hide, YesTimeMS_t
        GuiControl, Hide, YesLocation
        GuiControl, Hide, YesLocation_t
      }
      IniWrite, %DebugMessages%, %A_ScriptDir%\save\Settings.ini, General, DebugMessages
      IniWrite, %YesTimeMS%, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS
      IniWrite, %YesLocation%, %A_ScriptDir%\save\Settings.ini, General, YesLocation
    Return
  }

  { ; Launch Webpages from button
    LaunchHelp:
      Run, https://www.autohotkey.com/docs/KeyList.htm ; Open the AutoHotkey List of Keys
    Return

    LaunchSite:
      Run, https://bandittech.github.io/WingmanReloaded ; Open the Website page for the script
    Return

    LaunchDonate:
      Run, https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ESDL6W59QR63A&item_name=Open+Source+Script+Building&currency_code=USD&source=url ; Open the donation page for the script
    Return
  }

  { ; Basic GUI functions - Script Cleanup, UpdateProfileText, helpCalibration
    optionsCommand:
      hotkeys()
    return

    ft_Start:
    Gui, Submit
    CheckGamestates:= False
    Run, Library.ahk, %A_ScriptDir%\data\
    Return

    GuiEscape:
      Gui, Cancel
      CheckGamestates:= False
    return

    ItemInfoEscape:
    ItemInfoClose:
      Gui, ItemInfo: Hide
    Return

    helpCalibration:
      MsgBox, 262144, Calibration Tips, % "Use Game Logic States to observe what panels or game states are considered true or false. Open and close Panels within the game to see their respective status change from green to red. If all status are showing green, the script status should say Wingman Active.`n`n"
      . "If many are not responding to changes in the game, use the Wizard to calibrate them all at once. Just remember to follow the prompts closely in order to ensure proper calibration.`n`n"
      . "Sometimes it may be easier to calibrate one sample at a time, and this can be done with the Individual Sample menu.`n`n"
      . "If the issue is instead with the percentages of Health, ES, and/or Mana, then you will need to Adjust Globes. Use the menu to change the Scan options which the percentages will be shown in real time on the menu.`n`n"
      . "If the issue is with aspect ratio and you have already calculated your ratio manually, use Adjust Locations to enter custom positions."
    Return
    helpAutomationSetting:
      MsgBox, 262144, Automation Tips, % "Use Loot Vacuum to configure picking up loot, this function uses the Item Pickup hotkey bound in game. You must enable the In-Game option to only highlight loot when pressed, then you can calibrate colors within the script.`n`n"
      . "Sample Strings will allow you to change the image captures that have been saved for use with the script. Replace the default strings with your own, or use the ones available in the dropdown menus which match your resolution height."
    Return

    SelectClientLog:
      If (A_GuiControl = "ClientLog")
      {
        Gui, submit, NoHide
        If FileExist(ClientLog)
        {
          IniWrite, %ClientLog%, %A_ScriptDir%\save\Settings.ini, Log, ClientLog
          Monitor_GameLogs(1)
        }
      }
      Else
      {
        Gui, submit
        FileSelectFile, SelectClientLog, 1, 0, Select the location of your Client Log file, Client.txt
        If SelectClientLog !=
        {
          ClientLog := SelectClientLog
          GuiControl,, ClientLog, %SelectClientLog%
          IniWrite, %SelectClientLog%, %A_ScriptDir%\save\Settings.ini, Log, ClientLog
          Monitor_GameLogs(1)
        }
        Hotkeys()
      }
    Return
  }


  ; Comment out this line if your script crashes on launch
  #Include, %A_ScriptDir%\data\Library.ahk
