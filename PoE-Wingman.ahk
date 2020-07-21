; Contains all the pre-setup for the script
  Global VersionNumber := .12.00
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
  ; Run "%A_ScriptDir%\GottaGoFast.ahk"
  ; OnExit("CleanUp")
  
  IfNotExist, %A_ScriptDir%\data
    FileCreateDir, %A_ScriptDir%\data
  IfNotExist, %A_ScriptDir%\save
    FileCreateDir, %A_ScriptDir%\save
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
    ; Create a container for the sub-script
    ; Global scriptGottaGoFast := "GottaGoFast.ahk ahk_exe AutoHotkey.exe"
    Global scriptTradeMacro := "_TradeMacroMain.ahk ahk_exe AutoHotkey.exe"
    ; Create Executable group for gameHotkey, IfWinActive
    global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
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
    global Trigger:=00000
    global AutoQuit:=0 
    global AutoFlask:=0
    global AutoQuick:=0 
    global OnCooldown:=[0,0,0,0,0]
    global Radiobox1QS
    global Radiobox2QS
    global Radiobox3QS
    global Radiobox4QS
    global Radiobox5QS
    global Radiobox1Mana10
    global Radiobox2Mana10
    global Radiobox3Mana10
    global Radiobox4Mana10
    global Radiobox5Mana10
    Global LootFilter := {}
    Global IgnoredSlot := {}
    Global BlackList := {}
    Global YesClickPortal := True
    Global RelogOnQuit := True
    Global MainAttackPressedActive,SecondaryAttackPressedActive
    global ColorPicker_Group_Color, ColorPicker_Group_Color_Hex
      , ColorPicker_Red, ColorPicker_Red_Edit, ColorPicker_Red_Edit_Hex
      , ColorPicker_Green , ColorPicker_Green_Edit, ColorPicker_Green_Edit_Hex
      , ColorPicker_Blue , ColorPicker_Blue_Edit, ColorPicker_Blue_Edit_Hex
    Global FillMetamorph := {}
    ft_ToolTip_Text_Part1=
      (LTrim
      QuitBelow = Set the health threshold to logout`rLife and Hybrid character types quit from LIFE`rES character type quit from ENERGY SHIELD
      ManaThreshold = This value scales the location of the mana sample`rA value of 0 is aproximately 10`% mana`rA value of 100 is approximately 95`% mana
      RadioLife = Samples only Life values
      RadioHybrid = Samples both Life and ES values
      RadioCi = Samples only ES values
      PopFlasks1 = Enable flask slot 1 when using Pop Flasks hotkey
      PopFlasks2 = Enable flask slot 2 when using Pop Flasks hotkey
      PopFlasks3 = Enable flask slot 3 when using Pop Flasks hotkey
      PopFlasks4 = Enable flask slot 4 when using Pop Flasks hotkey
      PopFlasks5 = Enable flask slot 5 when using Pop Flasks hotkey
      Radiobox1QS = Enable this flask slot as a QuickSilver`rThis will trigger with Left Mouse or Attack Keys if set.
      Radiobox2QS = Enable this flask slot as a QuickSilver`rThis will trigger with Left Mouse or Attack Keys if set.
      Radiobox3QS = Enable this flask slot as a QuickSilver`rThis will trigger with Left Mouse or Attack Keys if set.
      Radiobox4QS = Enable this flask slot as a QuickSilver`rThis will trigger with Left Mouse or Attack Keys if set.
      Radiobox5QS = Enable this flask slot as a QuickSilver`rThis will trigger with Left Mouse or Attack Keys if set.
      Radiobox1Mana10 = Enable this flask slot in the Mana Group`rMana flasks will share a group cooldown, and will fire sequentially
      Radiobox2Mana10 = Enable this flask slot in the Mana Group`rMana flasks will share a group cooldown, and will fire sequentially
      Radiobox3Mana10 = Enable this flask slot in the Mana Group`rMana flasks will share a group cooldown, and will fire sequentially
      Radiobox4Mana10 = Enable this flask slot in the Mana Group`rMana flasks will share a group cooldown, and will fire sequentially
      Radiobox5Mana10 = Enable this flask slot in the Mana Group`rMana flasks will share a group cooldown, and will fire sequentially
      MainAttackbox1 = Enable this flask slot to trigger with Primary Attack Key`rBind the key on the left
      MainAttackbox2 = Enable this flask slot to trigger with Primary Attack Key`rBind the key on the left
      MainAttackbox3 = Enable this flask slot to trigger with Primary Attack Key`rBind the key on the left
      MainAttackbox4 = Enable this flask slot to trigger with Primary Attack Key`rBind the key on the left
      MainAttackbox5 = Enable this flask slot to trigger with Primary Attack Key`rBind the key on the left
      SecondaryAttackbox1 = Enable this flask slot to trigger with Secondary Attack Key`rBind the key on the left
      SecondaryAttackbox2 = Enable this flask slot to trigger with Secondary Attack Key`rBind the key on the left
      SecondaryAttackbox3 = Enable this flask slot to trigger with Secondary Attack Key`rBind the key on the left
      SecondaryAttackbox4 = Enable this flask slot to trigger with Secondary Attack Key`rBind the key on the left
      SecondaryAttackbox5 = Enable this flask slot to trigger with Secondary Attack Key`rBind the key on the left
      DetonateMines = Enable this to automatically Detonate Mines when placed`rDouble tap the D key to pause until next manual detonate
      DetonateMinesDelay = Delay for this long after detonating
      YesEldritchBattery = Enable this to sample the energy shield on the mana globe instead
      UpdateOnCharBtn = Calibrate the OnChar Color`rThis color determines if you are on a character`rSample located on the figurine next to the health globe
      UpdateOnChatBtn = Calibrate the OnChat Color`rThis color determines if the chat panel is open`rSample located on the very left edge of the screen
      UpdateOnDivBtn = Calibrate the OnDiv Color`rThis color determines if the Trade Divination panel is open`rSample located at the top of the Trade panel
      UpdateOnDelveChartBtn = Calibrate the OnDelveChart Color`rThis color determines if the Delve Chart panel is open`rSample located at the left of the Delve Chart panel
      UpdateOnMetamorphBtn = Calibrate the OnMetamorph Color`rThis color determines if the Metamorph panel is open`rSample located at the i Button of the Metamorph panel
      UpdateOnStockPileBtn = Calibrate the OnStockPile Color`rThis color determines if the Seed StockPile panel is open`rSample located in the center of the Seed StockPile panel
      UdateEmptyInvSlotColorBtn = Calibrate the Empty Inventory Color`rThis color determines the Empy Inventory slots`rSample located at the bottom left of each cell
      UpdateOnInventoryBtn = Calibrate the OnInventory Color`rThis color determines if the Inventory panel is open`rSample is located at the top of the Inventory panel
      UpdateOnStashBtn = Calibrate the OnStash/OnLeft Colors`rThese colors determine if the Stash/Left panel is open`rSample is located at the top of the Stash panel
      UpdateOnVendorBtn = Calibrate the OnVendor Color`rThis color determines if the Vendor Sell panel is open`r Sample is located at the top of the Sell panel
      UpdateOnMenuBtn = Calibrate the OnMenu Color`rThis color determines if Atlas or Skills menus are open`rSample located at the top of the fullscreen Menu panel
      UpdateDetonateBtn = Calibrate the Detonate Mines Color`rThis color determines if the detonate mine button is visible`rWill determine if you are in mines and change sample location`rLocated above mana flask on the right
      CalibrateOHBBtn = Calibrate the life color of the Overhead Health Bar`rMake sure the OHB is visible
      ShowSampleIndBtn = Open the Sample GUI which allows you to recalibrate one at a time
      ShowDebugGamestatesBtn = Open the Gamestate panel which shows you what the script is able to detect`rRed means its not active, green is active
      StartCalibrationWizardBtn = Use the Wizard to grab multiple samples at once`rThis will prompt you with instructions for each step
      YesOHB = Pauses the script when it cannot find the Overhead Health Bar
      YesGlobeScan = Use the new Globe scanning method to determine Life, ES and Mana
      YesStashChaosRecipe = Enable the dump tab automatically for items that can fill missing Chaos Recipe slots
      ChaosRecipeMaxHolding = Determine how many sets of Chaos Recipe to stash
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
      CurrentGemX = Select the X location for the first Gem or Item Swap`rWriting 0 or nothing in this box will disable this feature!`rPress Locate to grab positions
      CurrentGemY = Select the Y location for the first Gem or Item Swap`rWriting 0 or nothing in this box will disable this feature!`rPress Locate to grab positions
      AlternateGemX = Select the X location of the first Gem or Item to swap with`rIf you want to use your Secondary Weapon Set, enable Weapon Swap Gem 1`rPress Locate to grab positions
      AlternateGemY = Select the Y location of the first Gem or Item to swap with`rIf you want to use your Secondary Weapon Set, enable Weapon Swap Gem 1`rPress Locate to grab positions
      AlternateGemOnSecondarySlot = Enable this to get your First Alternate Gem from Secondary Weapon Set (Swap Weapons)
      GemItemToogle = Enable this to use Gem Swap1 as Item Swap1
      CurrentGem2X = Select the X location for the second Gem or Item Swap`rWriting 0 or nothing in this box will disable this feature!`rPress Locate to grab positions
      CurrentGem2Y = Select the Y location for the second Gem or Item Swap`rWriting 0 or nothing in this box will disable this feature!`rPress Locate to grab positions
      AlternateGem2X = Select the X location of the second Gem or Item to swap with`rIf you want to use your Secondary Weapon Set, enable Weapon Swap Gem 2`rPress Locate to grab positions
      AlternateGem2Y = Select the Y location of the second Gem or Item to swap with`rIf you want to use your Secondary Weapon Set, enable Weapon Swap Gem 2`rPress Locate to grab positions
      AlternateGem2OnSecondarySlot = Enable this to get your Second Alternate Gem from Secondary Weapon Set (Swap Weapons)
      GemItemToogle2 = Enable this to use Gem Swap2 as Item Swap2
      GrabCurrencyPosX = Select the X location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
      GrabCurrencyPosY = Select the Y location in your inventory for a currency`rWriting 0 or nothing in this box will disable this feature!`rYou can use this feature to quick grab a currency and put on your mouse point`rYou can use ignore slots to avoid currency being moved to stash`rPress Locate to grab positions
      StockPortal = Enable this to restock Portal scrolls when more than 10 are missing`rThis requires an assigned currency tab to work
      StockWisdom = Enable this to restock Wisdom scrolls when more than 10 are missing`rThis requires an assigned currency tab to work    
      YesEnableAutomation = Enable Automation Routines
      FirstAutomationSetting = Start Automation selected option
      YesEnableNextAutomation = Enable next automation after the first selected
      YesEnableSeedAutomation = Enable seed automation to find and deposit at Seed StockPile
      YesEnableAutoSellConfirmation = Enable Automation Routine to Accept Vendor Sell Button!! Be Careful!!
      YesEnableAutoSellConfirmationSafe = Enable Automation Routine to Accept Vendor Sell Button only when:`n   The vendor is empty`n   The only items are Chromatic or Jeweler
      YesAutoSkillUp = Enable this to Automatically level up skill gems
      YesWaitAutoSkillUp = Enable this to wait for mouse to not be held down before leveling gems
      DebugMessages = Enable this to show debug tooltips`rAlso shows additional options for location and logic readout
      YesTimeMS = Enable to show a tooltip when game logic is running
      YesLocation = Enable to show tooltips with current location information`rWhen checked this will also log zone change information
      hotkeyOptions = Set your hotkey to open the options GUI
      hotkeyAutoFlask = Set your hotkey to turn on and off AutoFlask
      hotkeyAutoQuit = Set your hotkey to turn on and off AutoQuit
      hotkeyLogout = Set your hotkey to Log out of the game
      hotkeyAutoQuicksilver = Set your hotkey to Turn on and off AutoQuicksilver
      hotkeyGetMouseCoords = Set your hotkey to grab mouse coordinates`rIf debug is enabled this function becomes the debug tool`rUse this to get gamestates or pixel grid info
      hotkeyQuickPortal = Set your hotkey to use a portal scroll from inventory
      hotkeyGemSwap = Set your hotkey to swap gems between the two locations set above`rEnable Weapon swap if your gem is on alternate weapon set
      hotkeyStartCraft = Set your hotkey to use Crafting Settings functions, as Map Crafting
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
      YesPopAllExtraKeys = Enable this option to press any extra keys in each flasks bindings when Popping all Flasks`rIf disabled, it will only fire the primary key assigned to the flask slot.
      LaunchHelp = Opens the AutoHotkey List of Keys
      YesIdentify = This option is for the Identify logic`rEnable to Identify items when the inventory panel is open
      YesStash = This option is for the Stash logic`rEnable to stash items to assigned tabs when the stash panel is open
      YesSeedStockPile = This option is for the Seed StockPile logic`rEnable to stash Seeds and Equipment when the Seed StockPile panel is open
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
      AreaScale = Increases the Pixel box around the Mouse`rA setting of 0 will search under cursor`rCan behave strangely at very high range
      StashTabCurrency = Assign the Stash tab for Currency items
      StashTabYesCurrency = Enable to send Currency items to the assigned tab on the left
      StashTabOil = Assign the Stash tab for Oil items
      StashTabYesOil = Enable to send Oil items to the assigned tab on the left
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
      StashTabCatalyst = Assign the Stash tab for Catalyst items
      StashTabYesCatalyst = Enable to send Catalyst items to the assigned tab on the left
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
      StashTabOrgan = Assign the Stash tab for Organ Part items
      StashTabYesOrgan = Enable to send Organ Part items to the assigned tab on the left
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
      StashTabFossil = Assign the Stash tab for Fossil items
      StashTabYesFossil = Enable to send Fossil items to the assigned tab on the left
      StashTabResonator = Assign the Stash tab for Resonator items
      StashTabYesResonator = Enable to send Resonator items to the assigned tab on the left
      StashTabCrafting = Assign the Stash tab for Crafting items
      StashTabYesCrafting = Enable to send Crafting items to the assigned tab on the left
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
      YesUtility1InverseBuff = Fire instead only when buff icon is present
      YesUtility2InverseBuff = Fire instead only when buff icon is present
      YesUtility3InverseBuff = Fire instead only when buff icon is present
      YesUtility4InverseBuff = Fire instead only when buff icon is present
      YesUtility5InverseBuff = Fire instead only when buff icon is present
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
      hotkeyMainAttack = Bind the Primary Attack for this Character
      hotkeySecondaryAttack = Bind the Secondary Attack for this Character
      )

      ft_ToolTip_Text := ft_ToolTip_Text_Part1 . ft_ToolTip_Text_Part2
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

      , 1440_SellItemsStr := "|<1440 Sell Items>*106$71.zzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy73zzzzzzzzzwC7zzzzzzzzzwSDzkzzzzzzzswTzVzzzzzzzlszz3tzzzzzzXlzy7nzzzzkT7XzwC0T1wM0SD7zsQ0w1kUMQSDzkw7lVk1sswTzVszbXVvllszz3lyD77k3Xlzy7Xw0CDU77XzwD7s0QTTyD7zsSDlzsyzwSDzkwTXzlxyswTzVsz7vXttlszz3lq7b7k3Xlzy7UC0CDUD7XzwDUS0wTlzzzzzzXz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1080_SellItemsStr := "|<1080 Sell Items>*100$80.zzzjTzzzzzzzzzzzlXzzzzzzzzy3zwMzlzzzzzzz0TzbDyTzzzzzznbztnzbbzzzzzwzsSQztkC74AT37w3bDyQ30k03UESQtnzbbbAAANa3b6Qztttlb76TsM1bDySS0NllVz6Ttnzb7byQQQ7sbyQztltzb77lyMxbDyQSDFlly360NnzbUU4QQPY3kCQztsA37761nzDzzzzDnzzzts"
      , 1050_SellItemsStr := "|<1050 Sell Items>*93$71.zzzzzzzzzzzzzzz6DzzzzzzzzzyATzzzzzzy3zwMzlzzzzztXzslznzzzzznjzlXzbbzzzzby3X7zC3Us133sX6DyQC8k033naATwswtXb73UAMztls37CD28slznXWCCQTaTlXzb7bwQszAxX7zCDDMtlAM36DyQ20lnW1sCATwwC3Xb7DxzzzzwzTzzzzzzzzzzzzzzzzzzzzzzzzzzU"
      , 768_SellItemsStr := "|<768 Sell Items>0xE0E0DB@0.52$56.00NU000007U6M600001A1a1a0000kCNUPtnvXr7qM6QyzxhvBa1aNgnQ7zNUNbvAnUw6M6NUnASDZa1aQgn3STNUNvvArn1000A800G"

      , 1440_SeedStockPileStr := "|<1440 Seed Stockpile>*109$71.zUzzzzzzzzzzw0zzzzzzzzzzttzzzzzzzzzzXvU1z3zsTXsz7y01s1z0D7ly7wknXVwQCD7y7zVyDXlwwQTw3z3wT3Xzslzw3y7lz6Dzl7zy3wDXyATzUTzy3sz7wMzz0zzy7lyDslzy8zzyDXwTlVzwEzzwT7wTbXzslznsyDsyD3xllzU3wTsMz03XlzUDsTs3z0D7VzlzzzwzzXzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1080_SeedStockPileStr := "|<1080 SeedStockPile>*106$100.kzzzzzzwDzzzzzzzy1zzzzzzUTzzzzzzznbzzzzzwtzznznvvvDs70s3znw0Q3w3740TnSPn3z7qBb7X6QlUTDtzCDw7swSQStbaUwzbwwTsDXnsnzYyPVkS3nlzsSDDXDy7tj73sTD7zlswyAzsDUyAzbwwzzXXnslzYyDtnyTnnzySD7b7yNtn7DtzCTwlsyASCNX70w3UQ3zkDXw7w3b4TDzzzzzznzzxzwzzzs"
      , 1050_SeedStockPileStr :="|<1050 SeedStockPile>*54$50.zzzzzzzzzzzzzzzzz1zzzzzy3aDzzzzzANr0kA3zniTkA30DwzVwT7llz3wD7lwQTsTVkA37bz3wA30ltzsTX7lwSTz7wlwT77ztaAT7lXzAM70kA1zkDbzzzzzzDzzzzzzzzs"
      , 768_SeedStockPileStr := "|<768 Seed Stockpile>#374@0.55$66.D0000D000009U0009U0000MDDDUMTbVxaCAABkA6AnBgDAAAkD6Mu1s3jDAk3aMS1k1gAAk1aML1sFgAAk1aAn5gDDDDUD6DXxi400004020k0U"

      , 1440_StashStr := "|<1440 Stash>*92$71.Dz0TzzzwzzXxzy5zzzzzzy7vzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUzzzzzzzzzzw0zzzzzzzzzzttzzzzzzzzzzXvU1zDwDXyTz7y01wDk77szy7wknsT7CDtzy7zVzUySQTnzw3z3z0wTszbzw3y7wlsTlzDzy3wDtXsDU0Tzy3szXXs700zzy7lz07sCDtzzyDXy0DwATnzzwT7tyDwMzbznsyDnwPslzDzU3wT7sE3XyTzUDsSTsUD7wzzlzzzzzlzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
      , 1080_StashStr := "|<1080 Stash>0xC8C8DC@0.78$57.00Q000000006s00000001V00000000A3zVUT6301k3UC48kM070A2kk6300S1UK70kM01sA4MQ7z0031UX1skM00MADs3630031V1UMkM08MA8AX6300y1X0rkkQ"
      , 1050_StashStr := "|<1050 Stash>*102$56.zzzzzzzzzzzUzzzzzzzzn7zzzzzzzwv0DbsQwTzDk1lw3D7zkzXwDBnlzy7syHnwwTzkyDYwD07zz7bv7Vk1zzttw1yAwTzySTCDnD7zn7bbnQnlzw3stwkQwTznzzzzTzzzzzzzzzzzU"
      , 768_StashStr := "|<768 Stash>#208@0.49$32.T00007k00033wsxXwACNMrX7b6AQlgxz3AT7MsnAsqBsn7xXU"

      , 1080_SkillUpStr := "|<1080 Skill Up>0xAA6204@0.66$9.sz7ss0000sz7sw"
      , 1050_SkillUpStr := "|<1050 Skill Up>**50$12.HoOkGY2VyzU1yzmX2VGU6U7kU"
      , 768_SkillUpStr := "|<768 Skill Up>#52@0.77$15.3U0W0CQ1nEU340MiO3nUAM0z07s3zkDl4"

      , 1080_XButtonStr := "|<1080 X Button>*43$12.0307sDwSDwDs7k7sDwSSwTsDk7U"
      , 1050_XButtonStr := "|<1050 X Button>*56$30.Tzz7zzw0lzzky4zz3znTyDzsDwE7S7sU7r7tU3D/nU0zXn3VzprXlvlbXznnbUzbvbwz7vbwz7vbtzXvrvvvnrrVtlnzVsnvq+MXtuTX/wzzzLyTzwTzDztzzXzXzzs8Dzzz1zzzzzzzU"
      , 768_XButtonStr := "|<768 X Button>#197@0.82$19.0zU1kQ1zb1twlcTgoDKmjBtXCzsCCS7773nb0tn6BdbbaTzlDzksxsCHs1zs0Dk8"

      , 1080_MasterStr := "|<1080 Master>*100$46.wy1043UDVtZXNiAy7byDbslmCDsyTX78wDXsCAw3sSDVs7U7lsyTUSSTXXty8ntiSDbslDW3sy1XW"
      , 1050_MasterStr := "|<1050 Master>*91$45.zzzzzzzznw81UMDwT00430TVtj7XsntDDswT6T9sT7UMnv7Vsw30S0z7DXs7nXwtwT4QyPbDXsnbn1sw37Dzyzzzzzzzzzzzzw"

      , 1080_NavaliStr := "|<1080 Navali>*100$56.TtzzzzzzznyTzzzzzzwTbxxzTjrx3tyCDXnsy0ST3ntsTDk3bkwSS7nw8Nt77D8wz36SNtnmDDks7USBw3nwD1k3mS0Qz3sQwwDbbDkz6TD3ntngDtblswyA38"
      , 1050_NavaliStr := "|<1050 Navali>*102$57.zzzzzzzzzwTbzzzzzzznwzzzzzzzyDbtsySTblkwyD7nXwzC3bkwywDbtmAwbXb9wzCMbYyRtDbtnUxXnDMwzCQ70S9k7btnktlsSQQzCT6TD3bnbtnwntwwyQ7DzzzzzzzzzU"
      , 768_NavaliStr := "|<768 Navali>#254@0.73$39.kk00007600000sln6QMTaC8nX3yllYQMSyPAan3nnswyMSCn7An3koAt3TQ"

      , 1080_HelenaStr := "|<1080 Helena>*100$62.DlzzzzzzzznwTzzzzzzzwz7zxzzvyzjDlkCDUQT7nnwSPnwrXnsQz7bwzDsQy701tzDny3D8k0S3nw7YHnAz7Vwz3tYw3DltzDnyMC0HwSTnwzb3bYz7bwvDtsntDls70kCTAy8"
      , 1050_HelenaStr := "|<1050 Helena>*95$61.zzzzzzzzzzlwTzzzzzzzwyDzzzzzzzyT70lw3DnwzDXUQy1ntwTbllyT7swy7k0szDXwCSHs0Q3bkCXD9wyC1ns7MbgST77twTi3UDDXXwyDrVnXbllyN7vsntnss70URyNwzzzzzzzzzzs"

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
    Global StashStr, SeedStockPileStr, VendorStr, VendorMineStr, HealthBarStr, SellItemsStr, SkillUpStr, ChestStr, DelveStr
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
    Global YesEnableAutomation, FirstAutomationSetting, YesEnableNextAutomation,YesEnableSeedAutomation,YesEnableAutoSellConfirmation,YesEnableAutoSellConfirmationSafe

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
    Global QSonMainAttack := 1
    Global QSonSecondaryAttack := 1
    Global YesPersistantToggle := 1
    Global YesSortFirst := 1
    Global YesAutoSkillUp := 1
    Global YesWaitAutoSkillUp := 1
    Global FlaskList := []
    Global AreaScale := 0
    Global LVdelay := 0
    Global LootVacuum := 1
    Global YesVendor := 1
    Global YesStash := 1
    Global YesSeedStockPile := 1
    Global YesIdentify := 1
    Global YesDiv := 1
    Global YesMapUnid := 1
    Global YesCLFIgnoreImplicit := 0
    Global YesStashKeys := 1
    Global YesPopAllExtraKeys := 1
    Global OnHideout := False
    Global OnTown := False
    Global OnMines := False
    Global DetonateMines := False
    Global DetonateMinesDelay := 500
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
    Global OnStockPile := False
    Global RescaleRan := False
    Global ToggleExist := False
    Global YesOHB := True
    Global YesGlobeScan := True
    Global YesStashChaosRecipe := False
    Global ChaosRecipeMaxHolding := 10
    Global YesFillMetamorph := True
    Global YesPredictivePrice := "Off"
    Global YesPredictivePrice_Percent_Val := 100
    Global HPerc := 100
    Global GameX, GameY, GameW, GameH, mouseX, mouseY
    Global OHB, OHBLHealthHex, OHBLManaHex, OHBLESHex, OHBLEBHex, OHBCheckHex
    Global CastOnDetonate := 0

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
    Global StashTabCurrency := 1
    Global StashTabMap := 1
    Global StashTabDivination := 1
    Global StashTabGem := 1
    Global StashTabGemVaal := 1
    Global StashTabGemQuality := 1
    Global StashTabFlaskQuality := 1
    Global StashTabLinked := 1
    Global StashTabCollection := 1
    Global StashTabUniqueRing := 1
    Global StashTabUniqueDump := 1
    Global StashTabInfluencedItem := 1
    Global StashTabFragment := 1
    Global StashTabEssence := 1
    Global StashTabOil := 1
    Global StashTabBlightedMap := 1
    Global StashTabDelirium := 1
    Global StashTabFossil := 1
    Global StashTabResonator := 1
    Global StashTabCrafting := 1
    Global StashTabProphecy := 1
    Global StashTabVeiled := 1
    Global StashTabGemSupport := 1
    Global StashTabOrgan := 1
    Global StashTabClusterJewel := 1
    Global StashTabDump := 1
    Global StashTabCatalyst := 1
    Global StashTabPredictive := 1
    Global StashTabNinjaPrice := 1
  ; Checkbox to activate each tab
    Global StashTabYesCurrency := 1
    Global StashTabYesMap := 1
    Global StashTabYesDivination := 1
    Global StashTabYesGem := 1
    Global StashTabYesGemVaal := 1
    Global StashTabYesGemQuality := 1
    Global StashTabYesFlaskQuality := 1
    Global StashTabYesLinked := 1
    Global StashTabYesCollection := 1
    Global StashTabYesUniqueRing := 1
    Global StashTabYesUniqueDump := 1
    Global StashTabYesInfluencedItem := 1
    Global StashTabYesBlightedMap := 1
    Global StashTabYesDelirium := 1
    Global StashTabYesFragment := 1
    Global StashTabYesEssence := 1
    Global StashTabYesOil := 1
    Global StashTabYesFossil := 1
    Global StashTabYesResonator := 1
    Global StashTabYesCrafting := 1
    Global StashTabYesProphecy := 1
    Global StashTabYesVeiled := 1
    Global StashTabYesGemSupport := 1
    Global StashTabYesOrgan := 1
    Global StashTabYesClusterJewel := 1
    Global StashTabYesDump := 1
    Global StashDumpInTrial := 1
    Global StashDumpSkipJC := 1
    Global StashTabYesCatalyst := 0
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
    global hotkeyStartCraft:="F2"
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
  ; Coordinates
    global PortalScrollX:=1825
    global PortalScrollY:=825
    global WisdomScrollX:=1875
    global WisdomScrollY:=825
    global StockPortal:=0
    global StockWisdom:=0
    global GuiX:=-5
    global GuiY:=1005

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
    global varOnStockPile:=0x1F2732
    Global varOnDetonate := 0x5D4661

  ; Life, ES, Mana Colors
    global varLife20, varLife30, varLife40, varLife50, varLife60, varLife70, varLife80, varLife90
    global varES20, varES30, varES40, varES50, varES60, varES70, varES80, varES90
    global varMana10, varManaThreshold, ManaThreshold


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

  ; Attack Triggers
    global TriggerMainAttack:=00000
    global TriggerSecondaryAttack:=00000
    Global MainAttackbox1,MainAttackbox2,MainAttackbox3,MainAttackbox4,MainAttackbox5
    Global SecondaryAttackbox1,SecondaryAttackbox2,SecondaryAttackbox3,SecondaryAttackbox4,SecondaryAttackbox5

  ; CharacterTypeCheck
    global Life:=1
    global Hybrid:=0
    global Ci:=0

  ; Life Triggers
    global TriggerLife20:=00000
    global TriggerLife30:=00000
    global TriggerLife40:=00000
    global TriggerLife50:=00000
    global TriggerLife60:=00000
    global TriggerLife70:=00000
    global TriggerLife80:=00000
    global TriggerLife90:=00000
    global DisableLife:=11111
    global Radiobox1Life20, Radiobox2Life20, Radiobox3Life20, Radiobox4Life20, Radiobox5Life20
    global Radiobox1Life30, Radiobox2Life30, Radiobox3Life30, Radiobox4Life30, Radiobox5Life30
    global Radiobox1Life40, Radiobox2Life40, Radiobox3Life40, Radiobox4Life40, Radiobox5Life40
    global Radiobox1Life50, Radiobox2Life50, Radiobox3Life50, Radiobox4Life50, Radiobox5Life50
    global Radiobox1Life60, Radiobox2Life60, Radiobox3Life60, Radiobox4Life60, Radiobox5Life60
    global Radiobox1Life70, Radiobox2Life70, Radiobox3Life70, Radiobox4Life70, Radiobox5Life70
    global Radiobox1Life80, Radiobox2Life80, Radiobox3Life80, Radiobox4Life80, Radiobox5Life80
    global Radiobox1Life90, Radiobox2Life90, Radiobox3Life90, Radiobox4Life90, Radiobox5Life90
    global RadioUncheck1Life, RadioUncheck2Life, RadioUncheck3Life, RadioUncheck4Life, RadioUncheck5Life
  ; ES Triggers
    Global YesEldritchBattery := 1
    global TriggerES20:=00000
    global TriggerES30:=00000
    global TriggerES40:=00000
    global TriggerES50:=00000
    global TriggerES60:=00000
    global TriggerES70:=00000
    global TriggerES80:=00000
    global TriggerES90:=00000
    global DisableES:=11111
    global Radiobox1ES20, Radiobox2ES20, Radiobox3ES20, Radiobox4ES20, Radiobox5ES20
    global Radiobox1ES30, Radiobox2ES30, Radiobox3ES30, Radiobox4ES30, Radiobox5ES30
    global Radiobox1ES40, Radiobox2ES40, Radiobox3ES40, Radiobox4ES40, Radiobox5ES40
    global Radiobox1ES50, Radiobox2ES50, Radiobox3ES50, Radiobox4ES50, Radiobox5ES50
    global Radiobox1ES60, Radiobox2ES60, Radiobox3ES60, Radiobox4ES60, Radiobox5ES60
    global Radiobox1ES70, Radiobox2ES70, Radiobox3ES70, Radiobox4ES70, Radiobox5ES70
    global Radiobox1ES80, Radiobox2ES80, Radiobox3ES80, Radiobox4ES80, Radiobox5ES80
    global Radiobox1ES90, Radiobox2ES90, Radiobox3ES90, Radiobox4ES90, Radiobox5ES90
    global RadioUncheck1ES, RadioUncheck2ES, RadioUncheck3ES, RadioUncheck4ES, RadioUncheck5ES

  ; Mana Triggers
    global TriggerMana10:=00000

  ; AutoQuit
    global QuitBelow, RadioCritQuit, RadioNormalQuit, RadioPortalQuit

  ; Character Type
    global RadioCi, RadioHybrid, RadioLife
    
  ; Utility Buttons
    global YesUtility1, YesUtility2, YesUtility3, YesUtility4, YesUtility5
      , YesUtility6, YesUtility7, YesUtility8, YesUtility9, YesUtility10
    global YesUtility1Quicksilver, YesUtility2Quicksilver, YesUtility3Quicksilver, YesUtility4Quicksilver, YesUtility5Quicksilver
      , YesUtility6Quicksilver, YesUtility7Quicksilver, YesUtility8Quicksilver, YesUtility9Quicksilver, YesUtility10Quicksilver
    global YesUtility1InverseBuff, YesUtility2InverseBuff, YesUtility3InverseBuff, YesUtility4InverseBuff, YesUtility5InverseBuff
      , YesUtility6InverseBuff, YesUtility7InverseBuff, YesUtility8InverseBuff, YesUtility9InverseBuff, YesUtility10InverseBuff
    global YesUtility1LifePercent, YesUtility2LifePercent, YesUtility3LifePercent, YesUtility4LifePercent, YesUtility5LifePercent
      , YesUtility6LifePercent, YesUtility7LifePercent, YesUtility8LifePercent, YesUtility9LifePercent, YesUtility10LifePercent
    global YesUtility1ESPercent, YesUtility2ESPercent, YesUtility3ESPercent, YesUtility4ESPercent, YesUtility5ESPercent
      , YesUtility6ESPercent, YesUtility7ESPercent, YesUtility8ESPercent, YesUtility9ESPercent, YesUtility10ESPercent
    global YesUtility1ManaPercent, YesUtility2ManaPercent, YesUtility3ManaPercent, YesUtility4ManaPercent, YesUtility5ManaPercent
      , YesUtility6ManaPercent, YesUtility7ManaPercent, YesUtility8ManaPercent, YesUtility9ManaPercent, YesUtility10ManaPercent
    global YesUtility1MainAttack, YesUtility2MainAttack, YesUtility3MainAttack, YesUtility4MainAttack, YesUtility5MainAttack
      , YesUtility6MainAttack, YesUtility7MainAttack, YesUtility8MainAttack, YesUtility9MainAttack, YesUtility10MainAttack
    global YesUtility1SecondaryAttack, YesUtility2SecondaryAttack, YesUtility3SecondaryAttack, YesUtility4SecondaryAttack, YesUtility5SecondaryAttack
      , YesUtility6SecondaryAttack, YesUtility7SecondaryAttack, YesUtility8SecondaryAttack, YesUtility9SecondaryAttack, YesUtility10SecondaryAttack
  ; Utility Cooldowns
    global CooldownUtility1, CooldownUtility2, CooldownUtility3, CooldownUtility4, CooldownUtility5
      , CooldownUtility6, CooldownUtility7, CooldownUtility8, CooldownUtility9, CooldownUtility10
    global OnCooldownUtility1 := 0, OnCooldownUtility2 := 0, OnCooldownUtility3 := 0, OnCooldownUtility4 := 0, OnCooldownUtility5 := 0
      , OnCooldownUtility6 := 0, OnCooldownUtility7 := 0, OnCooldownUtility8 := 0, OnCooldownUtility9 := 0, OnCooldownUtility10 := 0
  ; Utility Keys
    global KeyUtility1, KeyUtility2, KeyUtility3, KeyUtility4, KeyUtility5
      , KeyUtility6, KeyUtility7, KeyUtility8, KeyUtility9, KeyUtility10
  ; Utility Icons
    global IconStringUtility1, IconStringUtility2, IconStringUtility3, IconStringUtility4, IconStringUtility5
      , IconStringUtility6, IconStringUtility7, IconStringUtility8, IconStringUtility9, IconStringUtility10
  ; Flask Cooldowns
    global CooldownFlask1:=5000
    global CooldownFlask2:=5000
    global CooldownFlask3:=5000
    global CooldownFlask4:=5000
    global CooldownFlask5:=5000
    global Cooldown:=5000
  ; Flask hotkeys
    global keyFlask1:=1
    global keyFlask2:=2
    global keyFlask3:=3
    global keyFlask4:=4
    global keyFlask5:=5
    Global KeyFlask1Proper,KeyFlask2Proper,KeyFlask3Proper,KeyFlask4Proper,KeyFlask5Proper

  ; Quicksilver
    global TriggerQuicksilverDelay=0.8
    global TriggerQuicksilver=00000
  ; PopFlasks
    global PopFlasks1=1
    global PopFlasks2=1
    global PopFlasks3=1
    global PopFlasks4=1
    global PopFlasks5=1
    global TriggerPopFlasks=11111
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
    Global StartMapTier1,StartMapTier2,StartMapTier3,StartMapTier4,EndMapTier1,EndMapTier2,EndMapTier3,CraftingMapMethod1,CraftingMapMethod2,CraftingMapMethod3,ElementalReflect,PhysicalReflect,NoLeech,NoRegen,AvoidAilments,AvoidPBB,MinusMPR,MMapItemQuantity,MMapItemRarity,MMapMonsterPackSize,EnableMQQForMagicMap
    
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
  ; Quicksilver globals
    Global FlaskListQS := []
    Global LButtonPressed := 0
    Global MainPressed := 0
    Global SecondaryPressed := 0


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
  IfNotExist, %A_ScriptDir%\data\Migrate OLD CLF.ahk
  {
    UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Migrate OLD CLF.ahk, %A_ScriptDir%\data\Migrate OLD CLF.ahk
    if ErrorLevel {
      Log("data","uhoh", "Migrate OLD CLF.ahk")
      MsgBox, Error ED02 : There was a problem downloading Migrate OLD CLF.ahk
    }
    Else if (ErrorLevel=0){
      Log("data","pass", "Migrate OLD CLF.ahk")
      IfExist, %A_ScriptDir%\save\LootFilter.json
      {
        MsgBox, 4, Migrate OLD CLF detected, % ""
        . "The script has detected you are updating from an older version`n"
        . "The script has downloaded a migration tool to the DATA folder`n"
        . "`n"
        . "Click YES to migrate common CLF keys to their new format`n"
        . "`n"
        . "Click NO to Continue`n"
        . "`n"
        . "You will not receive this prompt again."
        IfMsgBox Yes
        {
          Run, %A_ScriptDir%\data\Migrate OLD CLF.ahk
        }
      }
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

  Gui Add, Tab2, vMainGuiTabs x3 y3 w625 h505 -wrap , Flasks|Utility|Configuration
  ;#######################################################################################################Flasks and Utility Tab
  Gui, Tab, Flasks
    Gui, Font,
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, GroupBox,         Section    w260 h40        xp+5   y+2,         Character Type:
    Gui, Font,
    Gui, Font, cRed
    Gui Add, Radio, Group   vRadioLife Checked%RadioLife%           xs+8 ys+20 gUpdateCharacterType,   Life
    Gui, Font, cPurple
    Gui Add, Radio,     vRadioHybrid Checked%RadioHybrid%         x+8 gUpdateCharacterType,   Hybrid
    Gui, Font, cBlue
    Gui Add, Radio,     vRadioCi Checked%RadioCi%           x+8 gUpdateCharacterType,   ES
    Gui Add, Checkbox, gUpdateEldritchBattery  vYesEldritchBattery Checked%YesEldritchBattery%         x+8          , Eldritch Battery
    Gui, Font
    ; Flask GUI
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, GroupBox,        Section    w260 h410 xs y+8  , Flask Settings
    Gui, Font
    Gui Add, Text,                     xs+55   ys+15,       Flask 1
    Gui Add, Text,                     x+8,                 Flask 2
    Gui Add, Text,                     x+7,                 Flask 3
    Gui Add, Text,                     x+8,                 Flask 4
    Gui Add, Text,                     x+7,                 Flask 5

    Gui Add, Text,       Section            x12   y+5,         Duration:
    Gui Add, Edit,       vCooldownFlask1       x63   ys-2   w34  h17,   %CooldownFlask1%
    Gui Add, Edit,       vCooldownFlask2       x+8       w34  h17,   %CooldownFlask2%
    Gui Add, Edit,       vCooldownFlask3       x+7       w34  h17,   %CooldownFlask3%
    Gui Add, Edit,       vCooldownFlask4       x+8       w34  h17,   %CooldownFlask4%
    Gui Add, Edit,       vCooldownFlask5       x+7       w34  h17,   %CooldownFlask5%

    Gui Add, Text,       Section        x13   y+5, %          "  IG Key:"
    Gui Add, Edit,       vkeyFlask1       x63   ys-2   w34  h17,   %keyFlask1%
    Gui Add, Edit,       vkeyFlask2       x+8       w34  h17,   %keyFlask2%
    Gui Add, Edit,       vkeyFlask3       x+7       w34  h17,   %keyFlask3%
    Gui Add, Edit,       vkeyFlask4       x+8       w34  h17,   %keyFlask4%
    Gui Add, Edit,       vkeyFlask5       x+7       w34  h17,   %keyFlask5%

    Gui, Font, cRed
    Gui Add, Text,      Section              x62     y+5,         Life
    Gui Add, Text,                    x+25,             Life
    Gui Add, Text,                    x+24,             Life
    Gui Add, Text,                    x+24,             Life
    Gui Add, Text,                    x+24,             Life
    Gui, Font
    Gui Add, Text,                    x80     ys,       |
    Gui Add, Text,                    x+40,             |
    Gui Add, Text,                    x+39,             |
    Gui Add, Text,                    x+39,             |
    Gui Add, Text,                    x+39,             |
    Gui, Font, cBlue
    Gui Add, Text,                    x83     ys,        ES
    Gui Add, Text,                    x+28,             ES
    Gui Add, Text,                    x+27,             ES
    Gui Add, Text,                    x+27,             ES
    Gui Add, Text,                    x+27,             ES
    Gui, Font

    Gui Add, Text,       Section              x23   y+5,         < 90`%:
    Gui Add, Text,                         y+5,         < 80`%:
    Gui Add, Text,                         y+5,         < 70`%:
    Gui Add, Text,                         y+5,         < 60`%:
    Gui Add, Text,                         y+5,         < 50`%:
    Gui Add, Text,                         y+5,         < 40`%:
    Gui Add, Text,                         y+5,         < 30`%:
    Gui Add, Text,                         y+5,         < 20`%:
    Gui Add, Text,                     x17    y+5,         Disable:

    loop 5 
      {
      Gui Add, Radio, Group   vRadiobox%A_Index%Life90 gFlaskCheck    x+12  ys    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life80 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life70 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life60 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life50 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life40 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life30 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%Life20 gFlaskCheck        y+5   w13 h13
      Gui Add, Radio,     vRadioUncheck%A_Index%Life           y+5   w13 h13
      
      Gui Add, Radio, Group   vRadiobox%A_Index%ES90 gFlaskCheck      x+3   ys    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES80 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES70 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES60 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES50 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES40 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES30 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadiobox%A_Index%ES20 gFlaskCheck          y+5    w13 h13
      Gui Add, Radio,     vRadioUncheck%A_Index%ES           y+5   w13 h13
      }
    Loop, 5 {
      valueLife20 := substr(TriggerLife20, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life20, %valueLife20%
      valueLife30 := substr(TriggerLife30, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life30, %valueLife30%
      valueLife40 := substr(TriggerLife40, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life40, %valueLife40%
      valueLife50 := substr(TriggerLife50, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life50, %valueLife50%
      valueLife60 := substr(TriggerLife60, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life60, %valueLife60%
      valueLife70 := substr(TriggerLife70, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life70, %valueLife70%
      valueLife80 := substr(TriggerLife80, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life80, %valueLife80%
      valueLife90 := substr(TriggerLife90, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Life90, %valueLife90%
      valueDisableLife := substr(DisableLife, (A_Index), 1)
      GuiControl, , RadioUncheck%A_Index%Life, %valueDisableLife%
      valueES20 := substr(TriggerES20, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES20, %valueES20%
      valueES30 := substr(TriggerES30, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES30, %valueES30%
      valueES40 := substr(TriggerES40, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES40, %valueES40%
      valueES50 := substr(TriggerES50, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES50, %valueES50%
      valueES60 := substr(TriggerES60, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES60, %valueES60%
      valueES70 := substr(TriggerES70, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES70, %valueES70%
      valueES80 := substr(TriggerES80, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES80, %valueES80%
      valueES90 := substr(TriggerES90, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%ES90, %valueES90%
      valueDisableES := substr(DisableES, (A_Index), 1)
      GuiControl, , RadioUncheck%A_Index%ES, %valueDisableES%
      }  
    Gui,Font,cBlack
    Gui Add, GroupBox,           Section  w257 h28       x11   y+5,
    Gui Add, Text,     Center      xp+5   yp+0,         Quick`nSilvers:

    ;Gui Add, GroupBox,     w257 h26                xp-5   yp-9, 
    Gui,Font
    Gui Add, CheckBox, Group   vRadiobox1QS     gUtilityCheck    xs+64   ys+10   w13 h13
    vFlask=2
    loop 4 {
      Gui Add, CheckBox, Group   vRadiobox%vFlask%QS    gUtilityCheck  x+28     w13 h13
      vFlask:=vFlask+1
      }

    Gui,Font,cBlack
    Gui Add, GroupBox,   Section  w257 h40                 x11   y+6, Mana `%
    Gui,Font
    Gui, Add, Edit, number limit2 xs+5 ys+15 w35
    Gui, Add, UpDown, vManaThreshold Range0-100, %ManaThreshold%
    Gui Add, CheckBox,     vRadiobox1Mana10   gUtilityCheck    xs+64    ys+18   w13 h13
    vFlask=2
    loop 4 {
      Gui Add, CheckBox,     vRadiobox%vFlask%Mana10 gUtilityCheck    x+28   w13 h13
      vFlask:=vFlask+1
      }
    Loop, 5 {  
      valueMana10 := substr(TriggerMana10, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
      valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
      GuiControl, , Radiobox%A_Index%QS, %valueQuicksilver%
      }
    Gui,Font,cBlack
    Gui Add, GroupBox,   Section  w257 h30                 x11   y+8,
    Gui Add, Text,   center xp+5 yp+0, Pop All`nFlasks:
    Gui,Font
    Gui Add, CheckBox, Group   vPopFlasks1    xs+64   ys+12   w13 h13
    Pop=2
    loop 4 {
      Gui Add, CheckBox, Group   vPopFlasks%Pop%   x+28     w13 h13
      Pop:=Pop+1
      }

    Loop, 5 {  
      valuePopFlasks := substr(TriggerPopFlasks, (A_Index), 1)
      GuiControl, , PopFlasks%A_Index%, %valuePopFlasks%
      }


    Gui, Font, s8 cBlack
    Gui Add, GroupBox,       Section            x11   y+6   w257 h58, Attack

    Gui,Font
    Gui Add, Edit,       vhotkeyMainAttack         xs+3   ys+14   w43 h17,   %hotkeyMainAttack%
    Gui Add, Checkbox,     vMainAttackbox1       x75   y+-15   w13 h13
    vFlask=2
    loop 4 {
      Gui Add, Checkbox,     vMainAttackbox%vFlask%     x+28       w13 h13
      vFlask:=vFlask+1
      } 

    Gui Add, Edit,       vhotkeySecondaryAttack     xs+3   y+8   w43 h17,   %hotkeySecondaryAttack%
    Gui Add, Checkbox,     vSecondaryAttackbox1     x75   y+-15   w13 h13
    vFlask=2
    loop 4 {
      Gui Add, Checkbox,     vSecondaryAttackbox%vFlask% x+28       w13 h13
      vFlask:=vFlask+1
      }
    Loop, 5 {  
      valueMainAttack := substr(TriggerMainAttack, (A_Index), 1)
      GuiControl, , MainAttackbox%A_Index%, %valueMainAttack%
      valueSecondaryAttack := substr(TriggerSecondaryAttack, (A_Index), 1)
      GuiControl, , SecondaryAttackbox%A_Index%, %valueSecondaryAttack%
      }

    ;Vertical Grey Lines
    Gui, Add, Text,                   x59   y84    h396 0x11
    Gui, Add, Text,                   x+33         h396 0x11
    Gui, Add, Text,                   x+34         h396 0x11
    Gui, Add, Text,                   x+33         h396 0x11
    Gui, Add, Text,                   x+34         h396 0x11
    Gui, Add, Text,                   x+33         h396 0x11
    ;Middle Vertical Lines
    Gui, Add, Text,                   x+5   y23    w1  h483 0x7
    Gui, Add, Text,                   x+1   y23    w1  h483 0x7


    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,     Section  w227 h66        x292   y30 ,         Auto-Quit Settings
    Gui, Font,
    ;Gui Add, Text,                       x292   y30,         Auto-Quit:
    Gui Add, DropDownList, vQuitBelow          h19 w37 r10 xs+5 ys+20,             10|20|30|40|50|60|70|80|90
    GuiControl, ChooseString, QuitBelow, %QuitBelow%
    Gui Add, Text,                     x+5   yp+3,         Quit via:
    Gui, Add, Radio, Group  vRadioCritQuit  Checked%RadioCritQuit%          x+1    y+-13,      D/C
    Gui, Add, Radio,     vRadioPortalQuit Checked%RadioPortalQuit%      x+1  ,        Portal
    Gui, Add, Radio,     vRadioNormalQuit Checked%RadioNormalQuit%      x+1  ,        /exit
    Gui Add, Checkbox, gUpdateExtra  vRelogOnQuit Checked%RelogOnQuit%         xs+5  y+8        , Log back in afterwards?

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, GroupBox,     Section  w257 h66        xs   y+10 ,         Quicksilver Settings
    Gui,Font,
    Gui Add, Text,                     xs+10   ys+16,         Quicksilver Flask Delay (in s):
    Gui Add, Edit,       vTriggerQuicksilverDelay  x+10   yp   w22 h17,   %TriggerQuicksilverDelay%
    Gui, Font, s8 cBlack
    ;Improve UI later
    Gui,Add,GroupBox, xs+10 yp+16 w208 h26                      ,Quicksilver on Attack:
    Gui,Font,
    Gui, Add, Checkbox, vQSonMainAttack +BackgroundTrans Checked%QSonMainAttack% xp+5 yp+15 , Primary Attack
    Gui, Add, Checkbox, vQSonSecondaryAttack +BackgroundTrans Checked%QSonSecondaryAttack% x+0 , Secondary Attack

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,           Section    w324 h176      xs   y+10,         Profile Management:
    Gui, Font
    Gui, Add, Text,                   xs+161   ys+41     h135 0x11


    ;Gui,Font,s9 cBlack Bold Underline
    ;Gui,Add,GroupBox, xs+5 ys+10 w190 h35                      ,
    Gui,Add,text, xs+10 ys+18                       ,Character Name:
    ;Gui,Font,
    Gui, Add, Edit, vCharName x+5 yp-2 w150 h19, %CharName%

    Gui, Add, Button, gsubmitProfile1 xs+4 ys+42 w50 h21, Save 1
    Gui, Add, Button, gsubmitProfile2 w50 h21, Save 2
    Gui, Add, Button, gsubmitProfile3 w50 h21, Save 3
    Gui, Add, Button, gsubmitProfile4 w50 h21, Save 4
    Gui, Add, Button, gsubmitProfile5 w50 h21, Save 5

    Gui, Add, Edit, gUpdateProfileText1 vProfileText1 x+1 ys+43 w50 h19, %ProfileText1%
    Gui, Add, Edit, gUpdateProfileText2 vProfileText2 y+8 w50 h19, %ProfileText2%
    Gui, Add, Edit, gUpdateProfileText3 vProfileText3 y+8 w50 h19, %ProfileText3%
    Gui, Add, Edit, gUpdateProfileText4 vProfileText4 y+8 w50 h19, %ProfileText4%
    Gui, Add, Edit, gUpdateProfileText5 vProfileText5 y+8 w50 h19, %ProfileText5%

    Gui, Add, Button, greadProfile1 x+1 ys+42 w50 h21, Load 1
    Gui, Add, Button, greadProfile2 w50 h21, Load 2
    Gui, Add, Button, greadProfile3 w50 h21, Load 3
    Gui, Add, Button, greadProfile4 w50 h21, Load 4
    Gui, Add, Button, greadProfile5 w50 h21, Load 5

    Gui, Add, Button, gsubmitProfile6 x+10 ys+42 w50 h21, Save 6
    Gui, Add, Button, gsubmitProfile7 w50 h21, Save 7
    Gui, Add, Button, gsubmitProfile8 w50 h21, Save 8
    Gui, Add, Button, gsubmitProfile9 w50 h21, Save 9
    Gui, Add, Button, gsubmitProfile10 w50 h21, Save 10

    Gui, Add, Edit, gUpdateProfileText6 vProfileText6 y+8 x+1 ys+43 w50 h19, %ProfileText6%
    Gui, Add, Edit, gUpdateProfileText7 vProfileText7 y+8 w50 h19, %ProfileText7%
    Gui, Add, Edit, gUpdateProfileText8 vProfileText8 y+8 w50 h19, %ProfileText8%
    Gui, Add, Edit, gUpdateProfileText9 vProfileText9 y+8 w50 h19, %ProfileText9%
    Gui, Add, Edit, gUpdateProfileText10 vProfileText10 y+8 w50 h19, %ProfileText10%

    Gui, Add, Button, greadProfile6 x+1 ys+42 w50 h21, Load 6
    Gui, Add, Button, greadProfile7 w50 h21, Load 7
    Gui, Add, Button, greadProfile8 w50 h21, Load 8
    Gui, Add, Button, greadProfile9 w50 h21, Load 9
    Gui, Add, Button, greadProfile10 w50 h21, Load 10

    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gloadSaved     x+5           h23,   Load
    Gui, Add, Button,      gLaunchSite     x+5           h23,   Website
    Gui, Add, Button,      gft_Start     x+5           h23,   Grab Icon

  Gui, Tab, Utility
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, GroupBox,             w605 h311    section    xm+5   y+15,         Utility Management:
    Gui, Font,

    Gui Add, Checkbox, gUpdateUtility  vYesUtility1 +BackgroundTrans Checked%YesUtility1%  Right  ys+45 xs+7  , 1
    Gui Add, Checkbox, gUpdateUtility  vYesUtility2 +BackgroundTrans Checked%YesUtility2%  Right  y+12    , 2
    Gui Add, Checkbox, gUpdateUtility  vYesUtility3 +BackgroundTrans Checked%YesUtility3%  Right  y+12    , 3
    Gui Add, Checkbox, gUpdateUtility  vYesUtility4 +BackgroundTrans Checked%YesUtility4%  Right  y+12    , 4
    Gui Add, Checkbox, gUpdateUtility  vYesUtility5 +BackgroundTrans Checked%YesUtility5%  Right  y+12    , 5
    Gui Add, Checkbox, gUpdateUtility  vYesUtility6 +BackgroundTrans Checked%YesUtility6%  Right  y+12    , 6
    Gui Add, Checkbox, gUpdateUtility  vYesUtility7 +BackgroundTrans Checked%YesUtility7%  Right  y+12    , 7
    Gui Add, Checkbox, gUpdateUtility  vYesUtility8 +BackgroundTrans Checked%YesUtility8%  Right  y+12    , 8
    Gui Add, Checkbox, gUpdateUtility  vYesUtility9 +BackgroundTrans Checked%YesUtility9%  Right  y+12    , 9
    Gui Add, Checkbox, gUpdateUtility  vYesUtility10 +BackgroundTrans Checked%YesUtility10% Right  y+12 xp-6    , 10

    Gui,Add,Edit,      gUpdateUtility  x+10 ys+42   w40 h19   vCooldownUtility1        ,%CooldownUtility1%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility2        ,%CooldownUtility2%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility3        ,%CooldownUtility3%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility4        ,%CooldownUtility4%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility5        ,%CooldownUtility5%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility6        ,%CooldownUtility6%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility7        ,%CooldownUtility7%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility8        ,%CooldownUtility8%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility9        ,%CooldownUtility9%
    Gui,Add,Edit,      gUpdateUtility         w40 h19   vCooldownUtility10        ,%CooldownUtility10%

    Gui,Add,Edit,      x+12  ys+42   w40 h19 gUpdateUtility  vKeyUtility1        ,%KeyUtility1%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility2        ,%KeyUtility2%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility3        ,%KeyUtility3%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility4        ,%KeyUtility4%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility5        ,%KeyUtility5%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility6        ,%KeyUtility6%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility7        ,%KeyUtility7%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility8        ,%KeyUtility8%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility9        ,%KeyUtility9%
    Gui,Add,Edit,               w40 h19 gUpdateUtility  vKeyUtility10        ,%KeyUtility10%

    Gui,Add,Edit,      x+11  ys+42   w60 h19 gUpdateUtility  vIconStringUtility1        ,%IconStringUtility1%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility2        ,%IconStringUtility2%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility3        ,%IconStringUtility3%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility4        ,%IconStringUtility4%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility5        ,%IconStringUtility5%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility6        ,%IconStringUtility6%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility7        ,%IconStringUtility7%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility8        ,%IconStringUtility8%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility9        ,%IconStringUtility9%
    Gui,Add,Edit,               w60 h19 gUpdateUtility  vIconStringUtility10      ,%IconStringUtility10%

    Gui Add, Checkbox, gUpdateUtility  vYesUtility1InverseBuff +BackgroundTrans Checked%YesUtility1InverseBuff%  x+7 ys+45, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility2InverseBuff +BackgroundTrans Checked%YesUtility2InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility3InverseBuff +BackgroundTrans Checked%YesUtility3InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility4InverseBuff +BackgroundTrans Checked%YesUtility4InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility5InverseBuff +BackgroundTrans Checked%YesUtility5InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility6InverseBuff +BackgroundTrans Checked%YesUtility6InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility7InverseBuff +BackgroundTrans Checked%YesUtility7InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility8InverseBuff +BackgroundTrans Checked%YesUtility8InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility9InverseBuff +BackgroundTrans Checked%YesUtility9InverseBuff%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility10InverseBuff +BackgroundTrans Checked%YesUtility10InverseBuff%    y+12, %A_Space%

    Gui Add, Checkbox, gUpdateUtility  vYesUtility1Quicksilver +BackgroundTrans Checked%YesUtility1Quicksilver%  x+17 ys+45, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility2Quicksilver +BackgroundTrans Checked%YesUtility2Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility3Quicksilver +BackgroundTrans Checked%YesUtility3Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility4Quicksilver +BackgroundTrans Checked%YesUtility4Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility5Quicksilver +BackgroundTrans Checked%YesUtility5Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility6Quicksilver +BackgroundTrans Checked%YesUtility6Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility7Quicksilver +BackgroundTrans Checked%YesUtility7Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility8Quicksilver +BackgroundTrans Checked%YesUtility8Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility9Quicksilver +BackgroundTrans Checked%YesUtility9Quicksilver%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility10Quicksilver +BackgroundTrans Checked%YesUtility10Quicksilver%    y+12, %A_Space%

    Gui Add, Checkbox, gUpdateUtility  vYesUtility1MainAttack +BackgroundTrans Checked%YesUtility1MainAttack%  x+17 ys+45, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility2MainAttack +BackgroundTrans Checked%YesUtility2MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility3MainAttack +BackgroundTrans Checked%YesUtility3MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility4MainAttack +BackgroundTrans Checked%YesUtility4MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility5MainAttack +BackgroundTrans Checked%YesUtility5MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility6MainAttack +BackgroundTrans Checked%YesUtility6MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility7MainAttack +BackgroundTrans Checked%YesUtility7MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility8MainAttack +BackgroundTrans Checked%YesUtility8MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility9MainAttack +BackgroundTrans Checked%YesUtility9MainAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility10MainAttack +BackgroundTrans Checked%YesUtility10MainAttack%    y+12, %A_Space%

    Gui Add, Checkbox, gUpdateUtility  vYesUtility1SecondaryAttack +BackgroundTrans Checked%YesUtility1SecondaryAttack%  x+12 ys+45, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility2SecondaryAttack +BackgroundTrans Checked%YesUtility2SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility3SecondaryAttack +BackgroundTrans Checked%YesUtility3SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility4SecondaryAttack +BackgroundTrans Checked%YesUtility4SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility5SecondaryAttack +BackgroundTrans Checked%YesUtility5SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility6SecondaryAttack +BackgroundTrans Checked%YesUtility6SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility7SecondaryAttack +BackgroundTrans Checked%YesUtility7SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility8SecondaryAttack +BackgroundTrans Checked%YesUtility8SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility9SecondaryAttack +BackgroundTrans Checked%YesUtility9SecondaryAttack%    y+12, %A_Space%
    Gui Add, Checkbox, gUpdateUtility  vYesUtility10SecondaryAttack +BackgroundTrans Checked%YesUtility10SecondaryAttack%    y+12, %A_Space%

    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility1LifePercent h16 w40 x+17   ys+42,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility2LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility3LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility4LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility5LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility6LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility7LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility8LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility9LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility10LifePercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    GuiControl, ChooseString, YesUtility1LifePercent, %YesUtility1LifePercent%
    GuiControl, ChooseString, YesUtility2LifePercent, %YesUtility2LifePercent%
    GuiControl, ChooseString, YesUtility3LifePercent, %YesUtility3LifePercent%
    GuiControl, ChooseString, YesUtility4LifePercent, %YesUtility4LifePercent%
    GuiControl, ChooseString, YesUtility5LifePercent, %YesUtility5LifePercent%
    GuiControl, ChooseString, YesUtility6LifePercent, %YesUtility6LifePercent%
    GuiControl, ChooseString, YesUtility7LifePercent, %YesUtility7LifePercent%
    GuiControl, ChooseString, YesUtility8LifePercent, %YesUtility8LifePercent%
    GuiControl, ChooseString, YesUtility9LifePercent, %YesUtility9LifePercent%
    GuiControl, ChooseString, YesUtility10LifePercent, %YesUtility10LifePercent%
      
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility1ESPercent h16 w40 x+17   ys+42,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility2ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility3ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility4ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility5ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility6ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility7ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility8ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility9ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility10ESPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
    GuiControl, ChooseString, YesUtility2ESPercent, %YesUtility2ESPercent%
    GuiControl, ChooseString, YesUtility3ESPercent, %YesUtility3ESPercent%
    GuiControl, ChooseString, YesUtility4ESPercent, %YesUtility4ESPercent%
    GuiControl, ChooseString, YesUtility5ESPercent, %YesUtility5ESPercent%
    GuiControl, ChooseString, YesUtility6ESPercent, %YesUtility6ESPercent%
    GuiControl, ChooseString, YesUtility7ESPercent, %YesUtility7ESPercent%
    GuiControl, ChooseString, YesUtility8ESPercent, %YesUtility8ESPercent%
    GuiControl, ChooseString, YesUtility9ESPercent, %YesUtility9ESPercent%
    GuiControl, ChooseString, YesUtility10ESPercent, %YesUtility10ESPercent%
      
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility1ManaPercent h16 w40 x+17   ys+42,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility2ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility3ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility4ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility5ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility6ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility7ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility8ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility9ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    Gui, Add, DropDownList, R10 gUpdateUtility vYesUtility10ManaPercent h16 w40      y+4,  Off|10|20|30|40|50|60|70|80|90
    GuiControl, ChooseString, YesUtility1ManaPercent, %YesUtility1ManaPercent%
    GuiControl, ChooseString, YesUtility2ManaPercent, %YesUtility2ManaPercent%
    GuiControl, ChooseString, YesUtility3ManaPercent, %YesUtility3ManaPercent%
    GuiControl, ChooseString, YesUtility4ManaPercent, %YesUtility4ManaPercent%
    GuiControl, ChooseString, YesUtility5ManaPercent, %YesUtility5ManaPercent%
    GuiControl, ChooseString, YesUtility6ManaPercent, %YesUtility6ManaPercent%
    GuiControl, ChooseString, YesUtility7ManaPercent, %YesUtility7ManaPercent%
    GuiControl, ChooseString, YesUtility8ManaPercent, %YesUtility8ManaPercent%
    GuiControl, ChooseString, YesUtility9ManaPercent, %YesUtility9ManaPercent%
    GuiControl, ChooseString, YesUtility10ManaPercent, %YesUtility10ManaPercent%

    Gui Add, Text,                     xs+11   ys+25,   ON:
    Gui, Add, Text,                   x+9   ys+25     h270 0x11
    Gui Add, Text,                     x+12   ,   CD:
    Gui, Add, Text,                   x+13        h270 0x11
    Gui Add, Text,                     x+10   ,   Key:
    Gui, Add, Text,                   x+14        h270 0x11
    Gui Add, Text,                     x+14   ,   Icon:
    ; Gui, Add, Text,                   x+25        h270 0x11
    Gui Add, Text,                     x+15   ,   Show:
    Gui, Add, Text,                   x+7        h270 0x11
    Gui Add, Text,                     x+8   ,   QS:
    Gui, Add, Text,                   x+8        h270 0x11
    Gui Add, Text,                     x+9   ,   Pri:
    ; Gui, Add, Text,                   x+11        h270 0x11
    Gui Add, Text,                     x+17   ,   Sec:
    Gui, Add, Text,                   x+12        h270 0x11
    Gui Add, Text,                     x+13   ,   Life:
    Gui, Add, Text,                   x+21        h270 0x11
    Gui Add, Text,                     x+14   ,   ES:
    Gui, Add, Text,                   x+17        h270 0x11
    Gui Add, Text,                     x+9   ,   Mana:
    Gui, Add, Text,                   x+18        h270 0x11

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,  y+20 xs w240 h150 Section, Stack Release Tool
    Gui, Font,
    Gui, Add, CheckBox, gUpdateStackRelease vStackRelease_Enable Checked%StackRelease_Enable%  Right x+-65 ys+2 , Enable
    Gui, Add, Edit, gUpdateStringEdit vStackRelease_BuffIcon xs+5 ys+19 w150 h21, % StackRelease_BuffIcon
    Gui, Add, Text, x+4 yp+3, Icon to Find
    Gui, Add, Edit, gUpdateStringEdit vStackRelease_BuffCount xs+5 y+15 w150 h21, % StackRelease_BuffCount
    Gui, Add, Text, x+4 yp+3, Stack Capture
    Gui, Add, Edit, gUpdateStackRelease vStackRelease_Keybind xs+5 y+15 w150 h21, %StackRelease_Keybind%
    Gui, Add, Text, x+4 yp+3, Key to release
    Gui, Add, Text, xs+5 y+12, Stack Search Offset - Bottom Edge of Buff Icon
    Gui, Font, Bold s9 cBlack
    Gui, Add, Text, xs+5 y+5, X1:
    Gui, Font,
    Gui, Add, Text, x+2 yp w29 hp,
    Gui, Add, UpDown, gUpdateStackRelease vStackRelease_X1Offset hp center Range-150-150, %StackRelease_X1Offset%
    Gui, Font, Bold s9 cBlack
    Gui, Add, Text, x+10 yp, Y1:
    Gui, Font,
    Gui, Add, Text, x+2 yp w29 hp,
    Gui, Add, UpDown, gUpdateStackRelease vStackRelease_Y1Offset hp center Range-150-150, %StackRelease_Y1Offset%
    Gui, Font, Bold s9 cBlack
    Gui, Add, Text, x+10 yp, X2:
    Gui, Font,
    Gui, Add, Text, x+2 yp w29 hp,
    Gui, Add, UpDown, gUpdateStackRelease vStackRelease_X2Offset hp center Range-150-150, %StackRelease_X2Offset%
    Gui, Font, Bold s9 cBlack
    Gui, Add, Text, x+10 yp, Y2:
    Gui, Font,
    Gui, Add, Text, x+2 yp w29 hp,
    Gui, Add, UpDown, gUpdateStackRelease vStackRelease_Y2Offset hp center Range-150-150, %StackRelease_Y2Offset%

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, GroupBox,     Section  w190 h110        xs+240+7   ys ,         Auto-Detonate Mines
    Gui, Font,
    Gui Add, Checkbox, gUpdateExtra  vDetonateMines Checked%DetonateMines%     Right    xs+128  ys+2        , Enable
    Gui Add, Text, xs+5 y+4, Delay after Detonate
    Gui Add, Edit,     gUpdateExtra   vDetonateMinesDelay  h18  x+5  yp-2  Number Limit w30        , %DetonateMinesDelay% 
    Gui Add, GroupBox, xs+5 y+1 w160 h37, Pause Mines
    Gui Add, Text, xp+5 yp+16 , Delay
    Gui Add, Edit,     gUpdateExtra   vPauseMinesDelay  h18  x+5  yp-2  Number Limit w30        , %PauseMinesDelay% 
    Gui Add, Text, x+5 yp+2 , Key
    Gui Add, Edit,     gUpdateExtra   vhotkeyPauseMines  h18  x+5  yp-2  w50        , %hotkeyPauseMines% 
    Gui Add, GroupBox, xs+5 y+3 w160 h37, Cast on Detonate
    Gui Add, CheckBox, gUpdateExtra xp+9 yp+16 vCastOnDetonate Checked%CastOnDetonate%, Enable
    Gui Add, Text, x+9 yp , Key
    Gui Add, Edit,     gUpdateExtra   vhotkeyCastOnDetonate  h18  x+5  yp-2  w50        , %hotkeyCastOnDetonate% 
    Gui,Font,

    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gloadSaved     x+5           h23,   Load
    Gui, Add, Button,      gLaunchSite     x+5           h23,   Website
    Gui, Add, Button,      gft_Start     x+5           h23,   Grab Icon

    ;#######################################################################################################Configuration Tab
  Gui, Tab, Configuration
    Gui, Add, Text,                   x279   y23    w1  h483 0x7
    Gui, Add, Text,                   x+1   y23    w1  h483 0x7

    Gui, Font, Bold s9 cBlack, Arial
    Gui, Add, Text,             section        x22   y30,         Gamestate Calibration:
    Gui, Font, s8
    Gui, Add, Button, ghelpCalibration   x+10 ys-4    w20 h20,   ?
    Gui, Add, Button, gStartCalibrationWizard vStartCalibrationWizardBtn  xs  ys+20 Section  w110 h25,   Run Wizard
    Gui, Add, Button, gShowDebugGamestates vShowDebugGamestatesBtn  x+8  yp        w110 h25,   Show Gamestates
    ;Update calibration for pixel check
    Gui, Add, Button, gShowSampleInd vShowSampleIndBtn    xs  ys+35      w110,   Individual Sample
    Gui, Add, Button, gWR_Update vWR_Btn_Globe         x+8 ys+35       w110,   Adjust Globes
    Gui, Font


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
    Gui,SampleInd: Add, Button, gupdateOnStockPile vUpdateOnStockPileBtn  x+8  yp      w110,   OnStockPile


    Gui,SampleInd: Font, Bold s9 cBlack, Arial
    Gui,SampleInd: Add, Text,         section            xm   y+10,         Inventory Calibration:
    Gui,SampleInd: Font
    Gui,SampleInd: Add, Button, gupdateEmptyColor vUdateEmptyInvSlotColorBtn xs ys+20         w110,   Empty Inventory

    Gui,SampleInd: Font, Bold s9 cBlack, Arial
    Gui,SampleInd: Add, Text,         section            xm   y+10,         AutoDetonate Calibration:
    Gui,SampleInd: Font
    Gui,SampleInd: Add, Button, gupdateDetonate vUpdateDetonateBtn     xs ys+20          w110,   OnDetonate

    Gui,SampleInd: +AlwaysOnTop

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,           Section          xs   y+10,         Interface Options:
    Gui, Font, 

    Gui Add, Checkbox, gUpdateExtra  vYesOHB Checked%YesOHB%                           , Pause script when OHB missing?
    Gui Add, Checkbox, gUpdateExtra  vYesGlobeScan Checked%YesGlobeScan%                    , Use Globe Scanner?
    Gui Add, Checkbox, gUpdateExtra  vShowOnStart Checked%ShowOnStart%                       , Show GUI on startup?
    Gui Add, Checkbox, gUpdateExtra  vYesPersistantToggle Checked%YesPersistantToggle%             , Persistant Auto-Toggles?
    Gui Add, Checkbox, gUpdateExtra  vAutoUpdateOff Checked%AutoUpdateOff%                   , Turn off Auto-Update?
    Gui Add, DropDownList, gUpdateExtra  vBranchName     w90                         , master|Alpha
    GuiControl, ChooseString, BranchName, %BranchName%
    Gui, Add, Text,       x+8 yp+3                                   , Update Branch
    Gui Add, DropDownList, gUpdateExtra  vScriptUpdateTimeType   xs  w90                  , Off|days|hours|minutes
    GuiControl, ChooseString, ScriptUpdateTimeType, %ScriptUpdateTimeType%
    Gui Add, Edit, gUpdateExtra  vScriptUpdateTimeInterval  x+5   w40                     , %ScriptUpdateTimeInterval%
    Gui, Add, Text,       x+8 yp+3                                   , Auto-check Update
    Gui Add, DropDownList, gUpdateResolutionScale  vResolutionScale     w90   xs              , Standard|Classic|Cinematic|Cinematic(43:18)|UltraWide|WXGA(16:10)
    GuiControl, ChooseString, ResolutionScale, %ResolutionScale%
    Gui, Add, Text,       x+8 y+-18                                   , Aspect Ratio
    Gui, Add, DropDownList, gUpdateExtra vLatency w40 xs y+10,  1|1.1|1.2|1.3|1.4|1.5|1.6|1.7|1.8|1.9|2|2.5|3
    GuiControl, ChooseString, Latency, %Latency%
    Gui, Add, Text,                     x+5 yp+3 hp-3              , Latency
    Gui, Add, DropDownList, gUpdateExtra vClickLatency w35 x+10 yp-3,  -2|-1|0|1|2|3|4
    GuiControl, ChooseString, ClickLatency, %ClickLatency%
    Gui, Add, Text,                     x+5 yp+3  hp-3            , Clicks
    Gui, Add, DropDownList, gUpdateExtra vClipLatency w35 x+10 yp-3,  -2|-1|0|1|2|3|4
    GuiControl, ChooseString, ClipLatency, %ClipLatency%
    Gui, Add, Text,                     x+5 yp+3  hp-3            , Clip
    Gui, Add, Edit,       vClientLog         xs y+10  w144  h21,   %ClientLog%
    Gui, add, Button, gSelectClientLog x+5 , Locate Logfile
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,           Section          xs   y+15,         Additional Settings:
    Gui, Font, s8
    Gui, add, button, gWR_Update vWR_Btn_Inventory   xs y+10 w110, Inventory
    Gui, add, button, gWR_Update vWR_Btn_Strings   x+10 yp w110, Strings
    Gui, add, button, gWR_Update vWR_Btn_Chat     xs y+10 w110, Chat
    Gui, add, button, gWR_Update vWR_Btn_Controller x+10 yp w110, Controller
    Gui, add, button, gLaunchLootFilter vWR_Btn_CLF  xs y+10 w110, C.L.F.
    ;Gui, add, button, gBuildIgnoreMenu vWR_Btn_IgnoreSlot x+10 yp w110, Ignore Slots

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,   Section                  x295   ym+25,         Keybinds:
    Gui, Font
    Gui Add, Text,                     xs+65   y+10,         Open this GUI
    Gui Add, Text,                     xs+65   y+10,         Auto-Flask
    Gui Add, Text,                     xs+65   y+10,         Auto-Quit
    Gui Add, Text,                     xs+65   y+10,         Logout
    Gui Add, Text,                     xs+65   y+10,         Auto-QSilver
    Gui Add, Text,                     xs+65   y+10,         Coord/Pixel         
    Gui Add, Text,                     xs+65   y+10,         Quick-Portal
    Gui Add, Text,                     xs+65   y+10,         Gem-Swap
    Gui Add, Text,                     xs+65   y+10,         Start Crafting
    Gui Add, Text,                     xs+65   y+10,         Grab Currency
    Gui Add, Text,                     xs+65   y+10,         Pop Flasks
    Gui Add, Text,                     xs+65   y+10,         ID/Vend/Stash
    Gui Add, Text,                     xs+65   y+10,         Item Info
    Gui Add, Text,                     xs+65   y+10,         Chaos Recipe

    Gui,Add,Edit,  xs ys+20        w60 h19     vhotkeyOptions         ,%hotkeyOptions%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoFlask         ,%hotkeyAutoFlask%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoQuit          ,%hotkeyAutoQuit%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyLogout            ,%hotkeyLogout%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyAutoQuicksilver   ,%hotkeyAutoQuicksilver%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGetMouseCoords    ,%hotkeyGetMouseCoords%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyQuickPortal       ,%hotkeyQuickPortal%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGemSwap           ,%hotkeyGemSwap%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyStartCraft        ,%hotkeyStartCraft%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyGrabCurrency      ,%hotkeyGrabCurrency%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyPopFlasks         ,%hotkeyPopFlasks%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyItemSort          ,%hotkeyItemSort%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyItemInfo          ,%hotkeyItemInfo%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyChaosRecipe       ,%hotkeyChaosRecipe%

    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Text,                     xs+145   ys,         Ingame:
    Gui, Font
    Gui Add, Text,                     xs+205   y+10,         Close UI
    Gui Add, Text,                          y+10,         Inventory
    Gui Add, Text,                          y+10,         W-Swap
    Gui Add, Text,                          y+10,         Item Pickup
    Gui Add, Text,                          y+10,         Detonate Mines
    Gui,Add,Edit,          xs+140 ys+20  w60 h19   vhotkeyCloseAllUI    ,%hotkeyCloseAllUI%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyInventory      ,%hotkeyInventory%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyWeaponSwapKey    ,%hotkeyWeaponSwapKey%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyLootScan        ,%hotkeyLootScan%
    Gui,Add,Edit,            y+4   w60 h19   vhotkeyDetonateMines    ,%hotkeyDetonateMines%
    Gui Add, Checkbox, section gUpdateExtra  vLootVacuum Checked%LootVacuum%                    y+8 ; Loot Vacuum?
    Gui, Font, Bold s9 cBlack, Arial
    Gui Add, Button, gLootColorsMenu  vLootVacuumSettings                  h19  x+0 yp-3, Loot Vacuum Settings
    Gui, Font
    Gui Add, Checkbox, gUpdateExtra  vPopFlaskRespectCD Checked%PopFlaskRespectCD%                 xs y+6 , Pop Flasks Respect CD?
    Gui Add, Checkbox, gUpdateExtra  vYesPopAllExtraKeys Checked%YesPopAllExtraKeys%                  y+8 , Pop Flasks Uses any extra keys?
    Gui Add, Checkbox, gUpdateExtra  vYesClickPortal Checked%YesClickPortal%                  y+8 , Click portal after opening?
    Gui Add, Checkbox,   vYesAutoSkillUp Checked%YesAutoSkillUp%    y+8        , Auto Skill Up?
    Gui Add, Checkbox,   vYesWaitAutoSkillUp Checked%YesWaitAutoSkillUp%    x+5 yp      , Wait?

    ;~ =========================================================================================== Subgroup: Hints
    Gui,Font, Bold s9 cBlack, Arial
    Gui,Add,GroupBox,Section xs  x450 y+10  w120 h80              ,Hotkey Modifiers
    Gui, Add, Button,      gLaunchHelp vLaunchHelp    xs+108 ys w18 h18 ,   ?
    Gui,Font,Norm
    Gui,Font,s8,Arial
    Gui,Add,Text,          xs+15 ys+17          ,!%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%ALT
    Gui,Add,Text,              y+5          ,^%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%CTRL
    Gui,Add,Text,              y+5          ,+%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%SHIFT


    Gui, Add, Text, x295 y400 , PoESessionID
    Gui, Add, Edit, password vPoESessionID  xp y+5  w300 h23, %PoESessionID%


    ;Save Setting
    Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
    Gui, Add, Button,      gloadSaved     x+5           h23,   Load
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
    Menu, Tray, Add,         Show Gamestates, ShowDebugGamestates
    Menu, Tray, Add
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

    if(RadioLife==1) {
      loop 5 {
        GuiControl, Enable, Radiobox%A_Index%Life90
          GuiControl, Enable, Radiobox%A_Index%Life80
          GuiControl, Enable, Radiobox%A_Index%Life70
          GuiControl, Enable, Radiobox%A_Index%Life60
          GuiControl, Enable, Radiobox%A_Index%Life50
          GuiControl, Enable, Radiobox%A_Index%Life40
          GuiControl, Enable, Radiobox%A_Index%Life30
          GuiControl, Enable, Radiobox%A_Index%Life20
          GuiControl, Enable, RadioUncheck%A_Index%Life
          
        GuiControl, Disable, Radiobox%A_Index%ES90
        GuiControl, Disable, Radiobox%A_Index%ES80
        GuiControl, Disable, Radiobox%A_Index%ES70
        GuiControl, Disable, Radiobox%A_Index%ES60
        GuiControl, Disable, Radiobox%A_Index%ES50
        GuiControl, Disable, Radiobox%A_Index%ES40
        GuiControl, Disable, Radiobox%A_Index%ES30
        GuiControl, Disable, Radiobox%A_Index%ES20
        GuiControl, Disable, RadioUncheck%A_Index%ES
        }
      }
    else if(RadioHybrid==1) {
      loop 5 {
        GuiControl, Enable, Radiobox%A_Index%Life90
          GuiControl, Enable, Radiobox%A_Index%Life80
          GuiControl, Enable, Radiobox%A_Index%Life70
          GuiControl, Enable, Radiobox%A_Index%Life60
          GuiControl, Enable, Radiobox%A_Index%Life50
          GuiControl, Enable, Radiobox%A_Index%Life40
          GuiControl, Enable, Radiobox%A_Index%Life30
          GuiControl, Enable, Radiobox%A_Index%Life20
          GuiControl, Enable, RadioUncheck%A_Index%Life
          
        GuiControl, Enable, Radiobox%A_Index%ES90
        GuiControl, Enable, Radiobox%A_Index%ES80
        GuiControl, Enable, Radiobox%A_Index%ES70
        GuiControl, Enable, Radiobox%A_Index%ES60
        GuiControl, Enable, Radiobox%A_Index%ES50
        GuiControl, Enable, Radiobox%A_Index%ES40
        GuiControl, Enable, Radiobox%A_Index%ES30
        GuiControl, Enable, Radiobox%A_Index%ES20
        GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
    else if(RadioCi==1) {
      loop 5 {
        GuiControl, Disable, Radiobox%A_Index%Life90
          GuiControl, Disable, Radiobox%A_Index%Life80
          GuiControl, Disable, Radiobox%A_Index%Life70
          GuiControl, Disable, Radiobox%A_Index%Life60
          GuiControl, Disable, Radiobox%A_Index%Life50
          GuiControl, Disable, Radiobox%A_Index%Life40
          GuiControl, Disable, Radiobox%A_Index%Life30
          GuiControl, Disable, Radiobox%A_Index%Life20
          GuiControl, Disable, RadioUncheck%A_Index%Life
          
        GuiControl, Enable, Radiobox%A_Index%ES90
        GuiControl, Enable, Radiobox%A_Index%ES80
        GuiControl, Enable, Radiobox%A_Index%ES70
        GuiControl, Enable, Radiobox%A_Index%ES60
        GuiControl, Enable, Radiobox%A_Index%ES50
        GuiControl, Enable, Radiobox%A_Index%ES40
        GuiControl, Enable, Radiobox%A_Index%ES30
        GuiControl, Enable, Radiobox%A_Index%ES20
        GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }

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
    Global DetonateDelveX:=1542
    Global DetonateX:=1658
    Global DetonateY:=901
    Global VendorAcceptX:=380
    Global VendorAcceptY:=820
    Global WisdomStockX:=115
    Global PortalStockX:=175
    Global WPStockY:=220
    ;Scouring 175,475
    Global ScouringX:=175
    Global ScouringY:=475
    ;Chisel 605,220
    Global ChiselX:=605
    Global ChiselY:=220
    ;Alchemy 490,290
    Global AlchemyX:=490
    Global AlchemyY:=290
    ;Transmutation 60,290
    Global TransmutationX:=60
    Global TransmutationY:=290
    ;Augmentation 230,340
    Global AugmentationX:=230
    Global AugmentationY:=340
    ;Vaal 230,475
    Global VaalX:=230
    Global VaalY:=475
    global vX_OnMenu:=960
    global vY_OnMenu:=54
    global vX_OnChar:=41
    global vY_OnChar:=915
    global vX_OnChat:=41
    global vY_OnChat:=915
    global vX_OnInventory:=1583
    global vY_OnInventory:=36
    global vX_OnStash:=336
    global vY_OnStash:=32
    global vX_OnVendor:=618
    global vY_OnVendor:=88
    global vX_OnDiv:=618
    global vY_OnDiv:=135
    global vX_OnLeft:=252
    global vY_OnLeft:=57
    global vX_OnDelveChart:=466
    global vY_OnDelveChart:=89
    global vX_OnMetamorph:=785
    global vY_OnMetamorph:=204
    ;638, 600
    global vX_OnStockPile:=638
    global vY_OnStockPile:=600
    global vX_Life:=95
    global vY_Life20:=1034
    global vY_Life30:=1014
    global vY_Life40:=994
    global vY_Life50:=974
    global vY_Life60:=954
    global vY_Life70:=934
    global vY_Life80:=914
    global vY_Life90:=894
      
    global vX_ES:=180
    global vY_ES20:=1034
    global vY_ES30:=1014
    global vY_ES40:=994
    global vY_ES50:=974
    global vY_ES60:=954
    global vY_ES70:=934
    global vY_ES80:=914
    global vY_ES90:=894
    
    global vX_Mana:=1825
    global vY_Mana10:=1054
    global vY_Mana90:=876
    Global vH_ManaBar:= vY_Mana10 - vY_Mana90
    Global vY_ManaThreshold:=vY_Mana10 - round(vH_ManaBar * (ManaThreshold / 100))
  
    Global vY_DivTrade:=736
    Global vY_DivItem:=605

    global vX_StashTabMenu := 640
    global vY_StashTabMenu := 146
    global vX_StashTabList := 706
    global vY_StashTabList := 120
    global vY_StashTabSize := 22
    Global ScrCenter := { X : 960 , Y : 540 }
    global GuiX:=-10
    global GuiY:=1027
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
  Gui 2:Font, bold cFFFFFF S10, Trebuchet MS
  Gui 2:Add, Text, y+0.5 BackgroundTrans vT1, Quit: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans vT2, Flasks: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans vT3, Quicksilver: OFF

  IfWinExist, ahk_group POEGameGroup
  {
    Rescale()
    Gui 2: Show, x%GuiX% y%GuiY% NA, StatusOverlay
    ToggleExist := True
    If (YesPersistantToggle)
      AutoReset()
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
    Thread, NoTimers, True
    If RunningToggle  ; This means an underlying thread is already running the loop below.
    {
      RunningToggle := False  ; Signal that thread's loop to stop.
      If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        SetTimer, TGameTick, On
      SendMSG(1,0,scriptTradeMacro)
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
            Send {%hotkeyInventory%}
            RunningToggle := False
            If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
              SetTimer, TGameTick, On
            Return
          }
        }
        Else
        {
          Send {%hotkeyInventory%}
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
      Else If (OnStockPile && YesSeedStockPile)
        StockPileRoutine()
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

  ; Search Seed StockPile
    ;Client:	638, 600 (recommended)
    ;Color:	1F2732 (Red=1F Green=27 Blue=32)
  SearchStockPile()
  {
    If (FindStock:=FindText(GameX,GameY,GameW,GameH,0,0,SeedStockPileStr))
    {
      LeftClick(FindStock.1.1 + 5,FindStock.1.2 + 5)
      Loop, 66
      {
        Sleep, 50
        GuiStatus()
        If OnStockPile
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
      LeftClick(FindStash.1.1 + 5,FindStash.1.2 + 5)
      Loop, 66
      {
        Sleep, 50
        GuiStatus()
        If OnStash
          Return True
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
        If (Item.Affix["Unidentified"]&&YesIdentify)
        {
          If (Item.Prop.IsMap&&!YesMapUnid&&!Item.Prop.Corrupted)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If ( Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
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
          If (YesEnableAutomation && FirstAutomationSetting=="Search Vendor")
          {
            If Item.MatchStashManagement()
            {
              Continue
            }
          }
          If ( Item.Prop.SpecialType="" )
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
        LeftClick(VendorAcceptX,VendorAcceptY)
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
        Send {%hotkeyCloseAllUI%}
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
        If (Item.Affix["Unidentified"]&&YesIdentify)
        {
          If (Item.Prop.IsMap&&!YesMapUnid&&!Item.Prop.Corrupted)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If ( Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
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
        LeftClick(VendorAcceptX,VendorAcceptY)
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
        Send {%hotkeyCloseAllUI%}
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
  ; StockPileRoutine - Deposit seeds and equipment at the Seed StockPile
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  StockPileRoutine(){
    BlackList := Array_DeepClone(IgnoredSlot)
    ; Move mouse out of the way to grab screenshot
    ShooMouse(), GuiStatus(), ClearNotifications()
    If !OnStockPile
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
        If (Item.Prop.SpecialType = "Harvest Item")
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
    Global StashGrid, CurrentTab
    CurrentTab := 0
    Static Object := {}
    If !Object.Count()
      Object := ChaosRecipe(StashTabDump)
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
          Return
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
      CtrlClick(StashGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].X[v.Prop.StashX]
      , StashGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].Y[v.Prop.StashY])
      Sleep, 30
    }

    ; Remove set from Object array
    Object.RemoveAt(1)

    ; Close Stash panel
    Send % hotkeyCloseAllUI
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
  PrintChaosRecipe(Message:="Current slot totals",Duration:=0)
  {
    Global RecipeArray
    Notify("Chaos Recipe", Message . "`n"
    . "Amulet: " . (RecipeArray.Amulet.Count()?RecipeArray.Amulet.Count():0) . "`t"
    . "Ring: " . (RecipeArray.Ring.Count()?RecipeArray.Ring.Count():0) . "`n"
    . "Belt: " . (RecipeArray.Belt.Count()?RecipeArray.Belt.Count():0) . "`t`t"
    . "Body: " . (RecipeArray.Body.Count()?RecipeArray.Body.Count():0) . "`n"
    . "Boots: " . (RecipeArray.Boots.Count()?RecipeArray.Boots.Count():0) . "`t"
    . "Gloves: " . (RecipeArray.Gloves.Count()?RecipeArray.Gloves.Count():0) . "`n"
    . "Helmet: " . (RecipeArray.Helmet.Count()?RecipeArray.Helmet.Count():0) . "`t"
    . "Shield: " . (RecipeArray.Shield.Count()?RecipeArray.Shield.Count():0) . "`n"
    . "One Hand: " . (RecipeArray["One Hand"].Count()?RecipeArray["One Hand"].Count():0) . "`t"
    . "Two Hand: " . (RecipeArray["Two Hand"].Count()?RecipeArray["Two Hand"].Count():0) . "`n" (Duration?"," Duration : ""))
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
    Loop 32
    {
      SortFirst[A_Index] := {}
    }
    SeedC := {}
    SeedR := {}
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
        If (Item.Affix["Unidentified"]&&YesIdentify)
        {
          If (Item.Prop.IsMap&&!YesMapUnid&&!Item.Prop.Corrupted)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If ( Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
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
        If (OnStash && YesStash) 
        {
          If (Item.Prop.SpecialType = "Quest Item")
            Continue
          Else If (sendstash:=Item.MatchLootFilter())
            Sleep, -1
          Else If (Item.Prop.SpecialType= "Harvest Item")
            {
              SeedC.Push(C)
              SeedR.Push(R)
              ++HarvestCount
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
            If (sendstash = -1)
              Continue
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
      If (YesEnableSeedAutomation&&HarvestCount)
      {
      Send {%hotkeyCloseAllUI%}
      RandomSleep(45,90)
      GuiStatus()
      If (SearchStockPile()){
        RandomSleep(45,90)
        For k, v in SeedC
        {
            GridX := InventoryGridX[v]
            GridY := InventoryGridY[ObjRawGet(SeedR, k)]
            Grid := RandClick(GridX, GridY)
            CtrlClick(Grid.X,Grid.Y)
            RandomSleep(45,45)
        }
      }
      }
      ; Find Vendor if Automation Start with Search Stash and NextAutomation is enable
      If (FirstAutomationSetting == "Search Stash" && YesEnableAutomation && YesEnableNextAutomation && Unstashed && RunningToggle && (OnHideout || OnTown || OnMines))
      {
        Send {%hotkeyCloseAllUI%}
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
        If (Sell:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SellItemsStr))
        {
          Sleep, 30*Latency
          LeftClick(Sell.1.x,Sell.1.y)
          Sleep, 120*Latency
          Return True
        }
        Sleep, 100
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
            LeftClick(vX_OnDiv,vY_DivTrade)
            Sleep, Abs(ClickLatency*15)
            CtrlClick(vX_OnDiv,vY_DivItem)
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
        ; Trade full div stacks
        If (Item.Affix["Unidentified"]&&YesIdentify)
        {
          If (Item.Prop.IsMap&&!YesMapUnid&&!Item.Prop.Corrupted)
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If (Item.Prop.Chromatic && (Item.Prop.RarityRare || Item.Prop.RarityUnique ) ) 
          {
            WisdomScroll(Grid.X,Grid.Y)
            ClipItem(Grid.X,Grid.Y)
          }
          Else If ( Item.Prop.Jeweler && ( Item.Prop.Sockets_Link >= 5 || Item.Prop.RarityRare || Item.Prop.RarityUnique) )
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
        Loop, 64
        {
          send {Left}
        }
        Loop % Tab - 1
        {
          send {Right}
        }
        CurrentTab:=Tab
        Sleep, 210*Latency
      }
      Else
      {
        Loop % Abs(Dif)
        {
          If (Dif > 0)
          {
            SendInput {Left}
          }
          Else
          {
            SendInput {Right}
          }
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
          ShiftClick(WisdomStockX, WPStockY)
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
          ShiftClick(PortalStockX, WPStockY)
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

; Main Script Logic Timers - TGameTick, TimerPassthrough
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; TGameTick - Flask Logic timer
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TGameTick(GuiCheck:=True)
  {
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
          DebugGamestates("CheckGamestates")
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
          Msg := "Paused while " . (!OnChar?"Not on Character":(OnChat?"Chat is Open":(OnMenu?"Passive/Atlas Menu Open":(OnInventory?"Inventory is Open":(OnStash?"Stash is Open":(OnVendor?"Vendor is Open":(OnDiv?"Divination Trade is Open":(OnLeft?"Left Panel is Open":(OnDelveChart?"Delve Chart is Open":(OnMetamorph?"Metamorph is Open":"Error"))))))))))
          If CheckTime("seconds",1,"StatusBar1")
            SB_SetText(Msg, 1)
          If (YesFillMetamorph) 
          {
            If (OnMetamorph && Metamorph_Filled)
              OnScreenMM := A_TickCount
            Else If (OnMetamorph && !Metamorph_Filled)
            {
              Metamorph_Filled := True
              Metamorph_FillOrgans()
              OnScreenMM := A_TickCount
            }
          }
          If CheckGamestates
          {
            DebugGamestates("CheckGamestates")
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
          Exit
        }
        Else If CheckTime("seconds",1,"StatusBar1")
          SB_SetText("WingmanReloaded Active", 1)
        If (!OnMetamorph && Metamorph_Filled && ((A_TickCount - OnScreenMM) >= 5000))
          Metamorph_Filled := False
        If CheckGamestates
          DebugGamestates("CheckGamestates")
      }
      If (DetonateMines&&!Detonated)
      {
        If (OnDetonate)
        {
          If GameActive
            send, % "{" hotkeyDetonateMines "}"
          Else
            controlsend, , % "{" hotkeyDetonateMines "}", %GameStr%
          If CastOnDetonate
            Send, % "{" hotkeyCastOnDetonate "}"
          Detonated:=1
          Settimer, TDetonated, -%DetonateMinesDelay%
        }
      }
      If (AutoFlask || AutoQuit)
      {
        If YesGlobeScan
          ScanGlobe()
        if (!RadioCi) { ; Life
          If (YesGlobeScan)
          {
            If (AutoQuit)
            {
              if (QuitBelow = 10 && Player.Percent.Life < 10)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 20 && Player.Percent.Life < 20)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 30 && Player.Percent.Life < 30)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 40 && Player.Percent.Life < 40)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 50 && Player.Percent.Life < 50)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 60 && Player.Percent.Life < 60)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 70 && Player.Percent.Life < 70)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 80 && Player.Percent.Life < 80)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 90 && Player.Percent.Life < 90)
              {
                LogoutCommand()
                Exit
              }
            }

            If (AutoFlask && DisableLife != "11111" )
            {
              If ( TriggerLife20 != "00000" && Player.Percent.Life < 20) 
                TriggerFlask(TriggerLife20)
              If ( TriggerLife30 != "00000" && Player.Percent.Life < 30) 
                TriggerFlask(TriggerLife30)
              If ( TriggerLife40 != "00000" && Player.Percent.Life < 40) 
                TriggerFlask(TriggerLife40)
              If ( TriggerLife50 != "00000" && Player.Percent.Life < 50) 
                TriggerFlask(TriggerLife50)
              If ( TriggerLife60 != "00000" && Player.Percent.Life < 60) 
                TriggerFlask(TriggerLife60)
              If ( TriggerLife70 != "00000" && Player.Percent.Life < 70) 
                TriggerFlask(TriggerLife70)
              If ( TriggerLife80 != "00000" && Player.Percent.Life < 80) 
                TriggerFlask(TriggerLife80)
              If ( TriggerLife90 != "00000" && Player.Percent.Life < 90) 
                TriggerFlask(TriggerLife90)
            }
            Loop, 10
              If (YesUtility%A_Index%
              && YesUtility%A_Index%LifePercent != "Off" 
              && !OnCooldownUtility%A_Index%
              && YesUtility%A_Index%LifePercent +0 > Player.Percent.Life )
                TriggerUtility(A_Index)
          }
          Else
          {
            If ( (TriggerLife20!="00000") 
              || (AutoQuit&&QuitBelow = 20)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="20" || YesUtility1LifePercent="10")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="20" || YesUtility2LifePercent="10")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="20" || YesUtility3LifePercent="10")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="20" || YesUtility4LifePercent="10")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="20" || YesUtility5LifePercent="10")&&!(OnCooldownUtility5)) ) ) {
              Life20 := ScreenShot_GetColor(vX_Life,vY_Life20) 
              if (Life20!=varLife20) {
                if (AutoQuit && QuitBelow >= 20) {
                  Log("Exit with < 20`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="20")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife20!="00000")
                  TriggerFlask(TriggerLife20)
                }
            }
            If ( (TriggerLife30!="00000") 
              || (AutoQuit&&QuitBelow = 30)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="30")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="30")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="30")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="30")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="30")&&!(OnCooldownUtility5)) ) ) {
              Life30 := ScreenShot_GetColor(vX_Life,vY_Life30) 
              if (Life30!=varLife30) {
                if (AutoQuit && QuitBelow >= 30) {
                  Log("Exit with < 30`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="30")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife30!="00000")
                  TriggerFlask(TriggerLife30)
                }
            }
            If ( (TriggerLife40!="00000") 
              || (AutoQuit&&QuitBelow = 40)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="40")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="40")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="40")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="40")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="40")&&!(OnCooldownUtility5)) ) ) {
              Life40 := ScreenShot_GetColor(vX_Life,vY_Life40) 
              if (Life40!=varLife40) {
                if (AutoQuit && QuitBelow >= 40) {
                  Log("Exit with < 40`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="40")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife40!="00000")
                  TriggerFlask(TriggerLife40)
                }
            }
            If ( (TriggerLife50!="00000")
              || (AutoQuit&&QuitBelow = 50)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="50")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="50")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="50")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="50")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="50")&&!(OnCooldownUtility5)) ) ) {
              Life50 := ScreenShot_GetColor(vX_Life,vY_Life50)
              if (Life50!=varLife50) {
                if (AutoQuit && QuitBelow >= 50) {
                  Log("Exit with < 50`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="50")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife50!="00000")
                  TriggerFlask(TriggerLife50)
                }
            }
            If ( (TriggerLife60!="00000")
              || (AutoQuit&&QuitBelow = 60)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="60")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="60")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="60")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="60")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="60")&&!(OnCooldownUtility5)) ) ) {
              Life60 := ScreenShot_GetColor(vX_Life,vY_Life60)
              if (Life60!=varLife60) {
                if (AutoQuit && QuitBelow >= 60) {
                  Log("Exit with < 60`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="60")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife60!="00000")
                  TriggerFlask(TriggerLife60)
                }
            }
            If ( (TriggerLife70!="00000") 
              || (AutoQuit&&QuitBelow = 70)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="70")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="70")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="70")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="70")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="70")&&!(OnCooldownUtility5)) ) ) {
              Life70 := ScreenShot_GetColor(vX_Life,vY_Life70)
              if (Life70!=varLife70) {
                if (AutoQuit && QuitBelow >= 70) {
                  Log("Exit with < 70`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="70")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife70!="00000")
                  TriggerFlask(TriggerLife70)
                }
            }
            If ( (TriggerLife80!="00000") 
              || (AutoQuit&&QuitBelow = 80)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="80")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="80")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="80")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="80")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="80")&&!(OnCooldownUtility5)) ) ) {
              Life80 := ScreenShot_GetColor(vX_Life,vY_Life80)
              if (Life80!=varLife80) {
                if (AutoQuit && QuitBelow >= 80) {
                  Log("Exit with < 80`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="80")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife80!="00000")
                  TriggerFlask(TriggerLife80)
                }
            }
            If ( (TriggerLife90!="00000") 
              || (AutoQuit&&QuitBelow = 90)
              || ( ((YesUtility1)&&(YesUtility1LifePercent="90")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2LifePercent="90")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3LifePercent="90")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4LifePercent="90")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5LifePercent="90")&&!(OnCooldownUtility5)) ) ) {
              Life90 := ScreenShot_GetColor(vX_Life,vY_Life90)
              if (Life90!=varLife90) {
                if (AutoQuit && QuitBelow >= 90) {
                  Log("Exit with < 90`% Life", CurrentLocation)
                  LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="90")
                    TriggerUtility(A_Index)
                }
                If (TriggerLife90!="00000")
                  TriggerFlask(TriggerLife90)
                }
            }
          }
        }

        if (!RadioLife) { ; Energy Shield
          If (YesGlobeScan)
          {
            If (AutoQuit && RadioCi)
            {
              if (QuitBelow = 10 && Player.Percent.ES < 10)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 20 && Player.Percent.ES < 20)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 30 && Player.Percent.ES < 30)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 40 && Player.Percent.ES < 40)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 50 && Player.Percent.ES < 50)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 60 && Player.Percent.ES < 60)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 70 && Player.Percent.ES < 70)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 80 && Player.Percent.ES < 80)
              {
                LogoutCommand()
                Exit
              }
              Else if (QuitBelow = 90 && Player.Percent.ES < 90)
              {
                LogoutCommand()
                Exit
              }
            }

            If (AutoFlask && DisableES != "11111" )
            {
              If ( TriggerES20 != "00000" && Player.Percent.ES < 20) 
                TriggerFlask(TriggerES20)
              If ( TriggerES30 != "00000" && Player.Percent.ES < 30) 
                TriggerFlask(TriggerES30)
              If ( TriggerES40 != "00000" && Player.Percent.ES < 40) 
                TriggerFlask(TriggerES40)
              If ( TriggerES50 != "00000" && Player.Percent.ES < 50) 
                TriggerFlask(TriggerES50)
              If ( TriggerES60 != "00000" && Player.Percent.ES < 60) 
                TriggerFlask(TriggerES60)
              If ( TriggerES70 != "00000" && Player.Percent.ES < 70) 
                TriggerFlask(TriggerES70)
              If ( TriggerES80 != "00000" && Player.Percent.ES < 80) 
                TriggerFlask(TriggerES80)
              If ( TriggerES90 != "00000" && Player.Percent.ES < 90) 
                TriggerFlask(TriggerES90)
            }
            Loop, 10
              If (YesUtility%A_Index%
              && YesUtility%A_Index%ESPercent != "Off" 
              && !OnCooldownUtility%A_Index%
              && YesUtility%A_Index%ESPercent +0 > Player.Percent.ES )
                TriggerUtility(A_Index)
          }
          Else
          {
            If ( (TriggerES20!="00000") 
              || (AutoQuit&&RadioCi&&QuitBelow = 20)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="20" || YesUtility1ESPercent="10")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="20" || YesUtility2ESPercent="10")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="20" || YesUtility3ESPercent="10")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="20" || YesUtility4ESPercent="10")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="20" || YesUtility5ESPercent="10")&&!(OnCooldownUtility5)) ) ) {
              ES20 := ScreenShot_GetColor(vX_ES,vY_ES20) 
              if (ES20!=varES20) {
                if (AutoQuit && RadioCi && QuitBelow >= 20) {
                    Log("Exit with < 20`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="20")
                    TriggerUtility(A_Index)
                }
                If (TriggerES20!="00000")
                  TriggerFlask(TriggerES20)
              }
            }
            If ( (TriggerES30!="00000") 
              || (AutoQuit&&RadioCi&&QuitBelow = 30)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="30")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="30")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="30")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="30")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="30")&&!(OnCooldownUtility5)) ) ) {
              ES30 := ScreenShot_GetColor(vX_ES,vY_ES30) 
              if (ES30!=varES30) {
                if (AutoQuit && RadioCi && QuitBelow >= 30) {
                    Log("Exit with < 30`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="30")
                    TriggerUtility(A_Index)
                }
                If (TriggerES30!="00000")
                  TriggerFlask(TriggerES30)
              }
            }
            If ( (TriggerES40!="00000") 
              || (AutoQuit&&RadioCi&&QuitBelow = 40)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="40")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="40")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="40")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="40")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="40")&&!(OnCooldownUtility5)) ) ) {
              ES40 := ScreenShot_GetColor(vX_ES,vY_ES40) 
              if (ES40!=varES40) {
                if (AutoQuit && RadioCi && QuitBelow >= 40) {
                    Log("Exit with < 40`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="40")
                    TriggerUtility(A_Index)
                }
                If (TriggerES40!="00000")
                  TriggerFlask(TriggerES40)
              }
            }
            If ( (TriggerES50!="00000")
              || (AutoQuit&&RadioCi&&QuitBelow = 50)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="50")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="50")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="50")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="50")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="50")&&!(OnCooldownUtility5)) ) ) {
              ES50 := ScreenShot_GetColor(vX_ES,vY_ES50)
              if (ES50!=varES50) {
                if (AutoQuit && RadioCi && QuitBelow >= 50) {
                    Log("Exit with < 50`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="50")
                    TriggerUtility(A_Index)
                }
                If (TriggerES50!="00000")
                  TriggerFlask(TriggerES50)
              }
            }
            If ( (TriggerES60!="00000")
              || (AutoQuit&&RadioCi&&QuitBelow = 60)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="60")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="60")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="60")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="60")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="60")&&!(OnCooldownUtility5)) ) ) {
              ES60 := ScreenShot_GetColor(vX_ES,vY_ES60)
              if (ES60!=varES60) {
                if (AutoQuit && RadioCi && QuitBelow >= 60) {
                    Log("Exit with < 60`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="60")
                    TriggerUtility(A_Index)
                }
                If (TriggerES60!="00000")
                  TriggerFlask(TriggerES60)
              }
            }
            If ( (TriggerES70!="00000")
              || (AutoQuit&&RadioCi&&QuitBelow = 70)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="70")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="70")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="70")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="70")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="70")&&!(OnCooldownUtility5)) ) ) {
              ES70 := ScreenShot_GetColor(vX_ES,vY_ES70)
              if (ES70!=varES70) {
                if (AutoQuit && RadioCi && QuitBelow >= 70) {
                    Log("Exit with < 70`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="70")
                    TriggerUtility(A_Index)
                }
                If (TriggerES70!="00000")
                  TriggerFlask(TriggerES70)
              }
            }
            If ( (TriggerES80!="00000")
              || (AutoQuit&&RadioCi&&QuitBelow = 80)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="80")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="80")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="80")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="80")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="80")&&!(OnCooldownUtility5)) ) ) {
              ES80 := ScreenShot_GetColor(vX_ES,vY_ES80)
              if (ES80!=varES80) {
                if (AutoQuit && RadioCi && QuitBelow >= 80) {
                    Log("Exit with < 80`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="80")
                    TriggerUtility(A_Index)
                }
                If (TriggerES80!="00000")
                  TriggerFlask(TriggerES80)
          
              }
            }
            If ( (TriggerES90!="00000")
              || (AutoQuit&&RadioCi&&QuitBelow = 90)
              || ( ((YesUtility1)&&(YesUtility1ESPercent="90")&&!(OnCooldownUtility1)) 
              || ((YesUtility2)&&(YesUtility2ESPercent="90")&&!(OnCooldownUtility2)) 
              || ((YesUtility3)&&(YesUtility3ESPercent="90")&&!(OnCooldownUtility3)) 
              || ((YesUtility4)&&(YesUtility4ESPercent="90")&&!(OnCooldownUtility4)) 
              || ((YesUtility5)&&(YesUtility5ESPercent="90")&&!(OnCooldownUtility5)) ) ) {
              ES90 := ScreenShot_GetColor(vX_ES,vY_ES90)
              if (ES90!=varES90) {
                if (AutoQuit && RadioCi && QuitBelow >= 90) {
                    Log("Exit with < 90`% Energy Shield", CurrentLocation)
                    LogoutCommand()
                  Exit
                }
                Loop, 10 {
                  If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="90")
                    TriggerUtility(A_Index)
                }
                If (TriggerES90!="00000")
                  TriggerFlask(TriggerES90)
          
              }
            }
          }
        }
        
        If (TriggerMana10!="00000") { ; Mana
          If (YesGlobeScan)
          {
            If (Player.Percent.Mana < ManaThreshold)
              TriggerMana(TriggerMana10)
            Loop, 10
              If (YesUtility%A_Index%
              && YesUtility%A_Index%ManaPercent != "Off" 
              && !OnCooldownUtility%A_Index%
              && YesUtility%A_Index%ManaPercent +0 > Player.Percent.Mana )
                TriggerUtility(A_Index)
          }
          Else
          {
            ManaPerc := ScreenShot_GetColor(vX_Mana,vY_ManaThreshold)
            if (ManaPerc!=varManaThreshold) {
              TriggerMana(TriggerMana10)
            Loop, 10
              If (YesUtility%A_Index%
              && YesUtility%A_Index%ManaPercent != "Off" 
              && !OnCooldownUtility%A_Index%)
                TriggerUtility(A_Index)
            }
          }
        }

        If (MainAttackPressedActive && AutoFlask)
        {
          If (TriggerMainAttack > 0)
            TriggerFlask(TriggerMainAttack)
          Loop, 10
          {
            If (YesUtility%A_Index%) && !(OnCooldownUtility%A_Index%) && (YesUtility%A_Index%MainAttack)
            {
              TriggerUtility(A_Index)
            }
          }
        }
        If (SecondaryAttackPressedActive && AutoFlask)
        {
          If (TriggerSecondaryAttack > 0)
            TriggerFlask(TriggerSecondaryAttack)
          Loop, 10
          {
            If (YesUtility%A_Index%) && !(OnCooldownUtility%A_Index%) && (YesUtility%A_Index%SecondaryAttack)
            {
              TriggerUtility(A_Index)
            }
          }
        }

        If (AutoFlask)
        {
          Loop, 10
          {
            If (YesUtility%A_Index%) 
              && !(OnCooldownUtility%A_Index%) 
              && !(YesUtility%A_Index%Quicksilver) 
              && !(YesUtility%A_Index%MainAttack) 
              && !(YesUtility%A_Index%SecondaryAttack) 
              && (YesUtility%A_Index%LifePercent="Off") 
              && (YesUtility%A_Index%ESPercent="Off") 
              && (YesUtility%A_Index%ManaPercent="Off") 
            {
              If !(IconStringUtility%A_Index%)
                TriggerUtility(A_Index)
              Else If (IconStringUtility%A_Index%)
              {
                BuffIcon := FindText(GameX, GameY, GameX + GameW, GameY + Round(GameH / ( 1080 / 75 )), 0, 0, IconStringUtility%A_Index%,0)
                If (!YesUtility%A_Index%InverseBuff && BuffIcon) || (YesUtility%A_Index%InverseBuff && !BuffIcon)
                {
                  OnCooldownUtility%A_Index%:=1
                  SetTimer, TimerUtility%A_Index%, % (YesUtility%A_Index%InverseBuff ? 150 : CooldownUtility%A_Index%)
                }
                Else If (YesUtility%A_Index%InverseBuff && BuffIcon) || (!YesUtility%A_Index%InverseBuff && !BuffIcon)
                  TriggerUtility(A_Index)
              }
            }
          }
        }
      }
      If (AutoQuick)
      {
        If ( Radiobox1QS > 0 || Radiobox2QS > 0 || Radiobox3QS > 0 || Radiobox4QS > 0 || Radiobox5QS > 0 )
        {
          TriggerQuick(TriggerQuicksilver)
        }
      }
      If (StackRelease_Enable)
      {
        StackRelease()
      }
      If LootVacuum
        LootScan()
      AutoSkillUp()
      If (DebugMessages && YesTimeMS)
      {
        If ((t1-LastAverageTimer) > 100)
        {
          If (YesGlobeScan)
            Ding(3000,2,"Globes:`t" . Player.Percent.Life . "`%L  " . Player.Percent.ES . "`%E  " . Player.Percent.Mana . "`%M")
          Else
            Ding(3000,2,"Total Time: `t" . tallyMS . "MS")
          If (YesGlobeScan)
            Ding(3000,3,"CPU `%:`t" . Round(tallyCPU,2) . "`%  " . tallyMS . "MS")
          Else
            Ding(3000,3,"CPU Load:   `t" . Round(tallyCPU,2) . "`%")
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
  
  ; TimerPassthrough - Passthrough Timer
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TimerPassthrough:
    If ( GetKeyState(KeyFlask1Proper, "P") ) {
      OnCooldown[1]:=1
      settimer, TimerFlask1, %CooldownFlask1%
      ; SendMSG(3, 1)
    }
    If ( GetKeyState(KeyFlask2Proper, "P") ) {
      OnCooldown[2]:=1
      settimer, TimerFlask2, %CooldownFlask2%
      ; SendMSG(3, 2)
    }
    If ( GetKeyState(KeyFlask3Proper, "P") ) {
      OnCooldown[3]:=1
      settimer, TimerFlask3, %CooldownFlask3%
      ; SendMSG(3, 3)
    }
    If ( GetKeyState(KeyFlask4Proper, "P") ) {
      OnCooldown[4]:=1
      settimer, TimerFlask4, %CooldownFlask4%
      ; SendMSG(3, 4)
    }
    If ( GetKeyState(KeyFlask5Proper, "P") ) {
      OnCooldown[5]:=1
      settimer, TimerFlask5, %CooldownFlask5%
      ; SendMSG(3, 5)
    }
  Return
; Toggle Main Script Timers - AutoQuit, AutoFlask, AutoReset, GuiUpdate
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; AutoQuit - Toggle Auto-Quit
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoQuit(){
    AutoQuitCommand:
      AutoQuit := !AutoQuit
      IniWrite, %AutoQuit%, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuit
      ; if ((!AutoFlask) && (!AutoQuit)) {
      ;   SetTimer TGameTick, Off
      ; } else if ((AutoFlask) || (AutoQuit)){
      ;   SetTimer TGameTick, %Tick%
      ; } 
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
  ; AutoReset - Load Previous Toggle States
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AutoReset(){
    IniRead, AutoQuit, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuit, 0
    IniRead, AutoFlask, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoFlask, 0
    IniRead, AutoQuick, %A_ScriptDir%\save\Settings.ini, Previous Toggles, AutoQuick, 0
    GuiUpdate()  
    return
    }

  ; GuiUpdate - Update Overlay ON OFF states
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GuiUpdate(){
      if (AutoFlask) {
        AutoFlaskToggle:="ON" 
      } else AutoFlaskToggle:="OFF" 
      
      if (AutoQuit) {
        AutoQuitToggle:="ON" 
      }else AutoQuitToggle:="OFF" 

      if (AutoQuick) {
        AutoQuickToggle:="ON" 
      } else AutoQuickToggle:="OFF" 

      GuiControl, 2:, T1, Quit: %AutoQuitToggle%
      GuiControl, 2:, T2, Flasks: %AutoFlaskToggle%
      GuiControl, 2:, T3, Quicksilver: %AutoQuickToggle%
      Return
    }

; Trigger Abilities or Flasks - MainAttackCommand, SecondaryAttackCommand, TriggerFlask, TriggerMana, TriggerUtility
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

  ; TriggerFlask - Flask Trigger check
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TriggerFlask(Trigger){
    FL:=1
    loop 5 {
      FLVal:=SubStr(Trigger,FL,1)+0
      if (FLVal > 0) {
        if (OnCooldown[FL]=0) {
          key := keyFlask%FL%
          If GameActive
            send, %key%
          Else
            controlsend, , %key%, %GameStr%
          ; SendMSG(3, FL)
          OnCooldown[FL]:=1 
          Cooldown:=CooldownFlask%FL%
          settimer, TimerFlask%FL%, %Cooldown%
          RandomSleep(15,60)      
        }
      }
      ++FL
    }
    Return
  }
  ; TriggerMana - Trigger Mana Flasks Sequentially
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TriggerMana(Trigger){
    If (!FlaskList.Count()) 
      loop, 5 
        if (SubStr(Trigger,A_Index,1)+0 > 0) 
          FlaskList.Push(A_Index)
    If !( (Radiobox1Mana10 && OnCooldown[1])
      || (Radiobox2Mana10 && OnCooldown[2])
      || (Radiobox3Mana10 && OnCooldown[3])
      || (Radiobox4Mana10 && OnCooldown[4])
      || (Radiobox5Mana10 && OnCooldown[5]) )
    {
      FL:=FlaskList.RemoveAt(1)
      key := keyFlask%FL%
      If GameActive
        send, %key%
      Else
        controlsend, , %key%, %GameStr%
      OnCooldown[FL] := 1 
      Cooldown:=CooldownFlask%FL%
      settimer, TimerFlask%FL%, %Cooldown%
      ; SendMSG(3, FL)
      RandomSleep(23,59)
    }
    Return
  }

  TriggerQuick(Trigger){
    Static LastHeldLB, LastHeldMA, LastHeldSA
    Global MovementHotkeyActive
    If !(FlaskListQS.Count())
      loop, 5 
        if (SubStr(Trigger,A_Index,1)+0 > 0)
          FlaskListQS.Push(A_Index)
    If !( (Radiobox1QS && OnCooldown[1])
      || (Radiobox2QS && OnCooldown[2])
      || (Radiobox3QS && OnCooldown[3])
      || (Radiobox4QS && OnCooldown[4])
      || (Radiobox5QS && OnCooldown[5]) )
    { ; If all the flasks are off cooldown, then we are ready to fire one
      LButtonPressed := ( MovementHotkeyActive || GetKeyState("LButton", "P") )
      If QSonMainAttack
        MainPressed := MainAttackPressedActive
      If QSonSecondaryAttack
        SecondaryPressed := SecondaryAttackPressedActive
      If (TriggerQuicksilverDelay > 0)
      {
        delay := TriggerQuicksilverDelay * 1000
        If (!LastHeldLB && LButtonPressed)
          LastHeldLB := A_TickCount
        Else If (LastHeldLB && !LButtonPressed)
          LastHeldLB := False
        If (LButtonPressed && A_TickCount - LastHeldLB < delay )
          Return
        
        If QSonMainAttack
        {
          If (!LastHeldMA && MainAttackPressedActive)
            LastHeldMA := A_TickCount
          Else If (LastHeldMA && !MainAttackPressedActive)
            LastHeldMA := False
          If (MainAttackPressedActive && A_TickCount - LastHeldMA < delay )
            Return
        }

        If QSonSecondaryAttack
        {
          If (!LastHeldSA && SecondaryAttackPressedActive)
            LastHeldSA := A_TickCount
          Else If (LastHeldSA && !SecondaryAttackPressedActive)
            LastHeldSA := False
          If (SecondaryAttackPressedActive && A_TickCount - LastHeldSA < delay )
            Return
        }
      }
      if (LButtonPressed || (MainAttackPressedActive && QSonMainAttack) || (SecondaryAttackPressedActive && QSonSecondaryAttack) ) 
      {
        QFL := FlaskListQS.RemoveAt(1)
        If (!QFL)
          Return
        key := keyFlask%QFL%
        If GameActive
          send, %key%
        Else
          controlsend, , %key%, %GameStr%
        settimer, TimerFlask%QFL%, % CooldownFlask%QFL%
        OnCooldown[QFL] := 1
        ; LastHeldLB := LastHeldMA := LastHeldSA := 0
        ; SendMSG(3, QFL)
        Loop, 10
          If (YesUtility%A_Index% && YesUtility%A_Index%Quicksilver)
            TriggerUtility(A_Index)
      }
    }
    Return
  }

  ; TriggerUtility - Trigger named Utility
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TriggerUtility(Utility){
    If (OnTown||OnHideout)
      Return
    If (!OnCooldownUtility%Utility%)&&(YesUtility%Utility% || TriggerUtilityKey = Utility){
      key:=KeyUtility%Utility%
      If GameActive
        send, %key%
      Else
        controlsend, , %key%, %GameStr%
      ; SendMSG(4, Utility)
      OnCooldownUtility%Utility%:=1
      Cooldown:=CooldownUtility%Utility%
      SetTimer, TimerUtility%Utility%, %Cooldown%
    }
    Return
  } 

; DebugGamestates - Show a GUI which will update based on the state of the game
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DebugGamestates(Switch:=""){
    Global
    Static OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1, OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnMetamorph:=-1, OldOnDetonate:=-1, OldOnStockPile:=-1
    Local NewOHB
    If (Switch := "CheckGamestates")
    {
      GoSub CheckGamestates
      Return
    }
    ShowDebugGamestates:
      ; SetTimer, CheckGamestates, 50
      CheckGamestates := True
      OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1, OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnMetamorph:=-1, OldOnDetonate:=-1, OldOnStockPile:=-1
      Gui, Submit
      ; ----------------------------------------------------------------------------------------------------------------------
      Gui, States: New, +LabelStates +AlwaysOnTop -MinimizeBox
      Gui, States: Margin, 10, 10
      ; ----------------------------------------------------------------------------------------------------------------------
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnChar hwndCTIDOnChar, % "OnChar"
      CtlColors.Attach(CTIDOnChar, "Lime", "")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnOHB hwndCTIDOnOHB, % "Overhead Health Bar"
      CtlColors.Attach(CTIDOnOHB, "Lime", "")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnChat hwndCTIDOnChat, % "OnChat"
      CtlColors.Attach(CTIDOnChat, "", "Green")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnInventory hwndCTIDOnInventory, % "OnInventory"
      CtlColors.Attach(CTIDOnInventory, "", "Green")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnDiv hwndCTIDOnDiv, % "OnDiv"
      CtlColors.Attach(CTIDOnDiv, "", "Green")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnStash hwndCTIDOnStash, % "OnStash"
      CtlColors.Attach(CTIDOnStash, "", "Green")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnMenu hwndCTIDOnMenu, % "OnMenu"
      CtlColors.Attach(CTIDOnMenu, "", "Green")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnVendor hwndCTIDOnVendor, % "OnVendor"
      CtlColors.Attach(CTIDOnVendor, "", "Green")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnDelveChart hwndCTIDOnDelveChart, % "OnDelveChart"
      CtlColors.Attach(CTIDOnDelveChart, "", "Green")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnLeft hwndCTIDOnLeft, % "OnLeft"
      CtlColors.Attach(CTIDOnLeft, "", "Green")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnMetamorph hwndCTIDOnMetamorph, % "OnMetamorph"
      CtlColors.Attach(CTIDOnMetamorph, "", "Green")
      Gui, States: Add, Text, x+5 yp w110 Center h20 0x200 vCTOnDetonate hwndCTIDOnDetonate, % "OnDetonate"
      CtlColors.Attach(CTIDOnDetonate, "", "Green")
      Gui, States: Add, Text, xm+5 y+10 w110 Center h20 0x200 vCTOnStockPile hwndCTIDOnStockPile, % "OnStockPile"
      CtlColors.Attach(CTIDOnStockPile, "", "Green")
      Gui, States: Add, Button, gCheckPixelGrid xm+5 y+15 w190 , Check Inventory Grid
      ; ----------------------------------------------------------------------------------------------------------------------
      GoSub CheckGamestates
      Gui, States: Show ,  , Check Gamestates
    Return
    ; ----------------------------------------------------------------------------------------------------------------------
    StatesClose:
    StatesEscape:
      Gui, States: Destroy
      SetTimer, CheckGamestates, Delete
      CtlColors.Free()
      Gui, 1: Show
      CheckGamestates := False
    Return
    ; ----------------------------------------------------------------------------------------------------------------------
    StatesSize:
      If (A_EventInfo != 1) {
        Gui, %A_Gui%:+LastFound
        WinSet, ReDraw
      }
    Return
    ; ----------------------------------------------------------------------------------------------------------------------
    CheckGamestates:
      ; GuiStatus()
      If (OnChar != OldOnChar)
      {
        OldOnChar := OnChar
        If OnChar
          CtlColors.Change(CTIDOnChar, "Lime", "")
        Else
          CtlColors.Change(CTIDOnChar, "Red", "")
      }
      If ((NewOHB := (CheckOHB()?1:0)) != OldOHB)
      {
        OldOHB := NewOHB
        If NewOHB
          CtlColors.Change(CTIDOnOHB, "Lime", "")
        Else
          CtlColors.Change(CTIDOnOHB, "Red", "")
      }
      If (OnInventory != OldOnInventory)
      {
        OldOnInventory := OnInventory
        If (OnInventory)
          CtlColors.Change(CTIDOnInventory, "Red", "")
        Else
          CtlColors.Change(CTIDOnInventory, "", "Green")
      }
      If (OnChat != OldOnChat)
      {
        OldOnChat := OnChat
        If OnChat
          CtlColors.Change(CTIDOnChat, "Red", "")
        Else
          CtlColors.Change(CTIDOnChat, "", "Green")
      }
      If (OnStash != OldOnStash)
      {
        OldOnStash := OnStash
        If (OnStash)
          CtlColors.Change(CTIDOnStash, "Red", "")
        Else
          CtlColors.Change(CTIDOnStash, "", "Green")
      }
      If (OnDiv != OldOnDiv)
      {
        OldOnDiv := OnDiv
        If (OnDiv)
          CtlColors.Change(CTIDOnDiv, "Red", "")
        Else
          CtlColors.Change(CTIDOnDiv, "", "Green")
      }
      If (OnLeft != OldOnLeft)
      {
        OldOnLeft := OnLeft
        If (OnLeft)
          CtlColors.Change(CTIDOnLeft, "Red", "")
        Else
          CtlColors.Change(CTIDOnLeft, "", "Green")
      }
      If (OnDelveChart != OldOnDelveChart)
      {
        OldOnDelveChart := OnDelveChart
        If (OnDelveChart)
          CtlColors.Change(CTIDOnDelveChart, "Red", "")
        Else
          CtlColors.Change(CTIDOnDelveChart, "", "Green")
      }
      If (OnVendor != OldOnVendor)
      {
        OldOnVendor := OnVendor
        If (OnVendor)
          CtlColors.Change(CTIDOnVendor, "Red", "")
        Else
          CtlColors.Change(CTIDOnVendor, "", "Green")
      }
      If (OnDetonate != OldOnDetonate)
      {
        OldOnDetonate := OnDetonate
        If (OnDetonate)
          CtlColors.Change(CTIDOnDetonate, "Red", "")
        Else
          CtlColors.Change(CTIDOnDetonate, "", "Green")
      }
      If (OnMenu != OldOnMenu)
      {
        OldOnMenu := OnMenu
        If (OnMenu)
          CtlColors.Change(CTIDOnMenu, "Red", "")
        Else
          CtlColors.Change(CTIDOnMenu, "", "Green")
      }
      If (OnMetamorph != OldOnMetamorph)
      {
        OldOnMetamorph := OnMetamorph
        If (OnMetamorph)
          CtlColors.Change(CTIDOnMetamorph, "Red", "")
        Else
          CtlColors.Change(CTIDOnMetamorph, "", "Green")
      }
      If (OnStockPile != OldOnStockPile)
      {
        OldOnStockPile := OnStockPile
        If (OnStockPile)
          CtlColors.Change(CTIDOnStockPile, "Red", "")
        Else
          CtlColors.Change(CTIDOnStockPile, "", "Green")
      }
    Return
    ; ----------------------------------------------------------------------------------------------------------------------
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
    ; ----------------------------------------------------------------------------------------------------------------------
  }

;
; GrabCurrency - Get currency fast to use on a white/blue/rare strongbox
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GrabCurrency(){
    GrabCurrencyCommand:
      Thread, NoTimers, true    ;Critical
      Keywait, Alt
      BlockInput, MouseMove
      MouseGetPos xx, yy
      RandomSleep(45,45)
      If (GrabCurrencyPosX && GrabCurrencyPosY)
      {
        If !GuiStatus("OnInventory")
        {      
          Send {%hotkeyInventory%} 
          RandomSleep(45,45)
        }
        RandomSleep(45,45)
        RightClick(GrabCurrencyPosX, GrabCurrencyPosY)
        RandomSleep(45,45)
        Send {%hotkeyInventory%} 
        MouseMove, xx, yy, 0
        BlockInput, MouseMoveOff
      }
  return
  }

;
; Crafting - Deal with Crafting requirement conditions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Crafting()
  {
    StartCraftCommand:
      Thread, NoTimers, True
      MouseGetPos xx, yy
      If RunningToggle
      {
        RunningToggle := False
        If (AutoQuit || AutoFlask || DetonateMines || YesAutoSkillUp || LootVacuum)
        {
          SetTimer, TGameTick, On
        }
        SendMSG(1,0,scriptTradeMacro)
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
          MsgBox %  "You do not appear to be in game.`nLikely need to calibrate OnChar"
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
            Send {%hotkeyInventory%}
            RandomSleep(45,45)
            GuiStatus()
            RandomSleep(45,45)
          }
          If (OnInventory && OnStash)
          {
            RandomSleep(45,45)
            CraftingMaps()
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

;
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
;
; ApplyCurrency - Using cname = currency name string and x, y as apply position
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ApplyCurrency(cname, x, y)
  {
    RightClick(%cname%X, %cname%Y)
    Sleep, 45*Latency
    LeftClick(x,y)
    Sleep, 90*Latency
    ClipItem(x,y)
    Sleep, 45*Latency
    return
  }

;
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
    While ( (Item.Affix["Monsters have # chance to Avoid Elemental Ailments"] && AvoidAilments) 
    || (Item.Affix["Monsters have a # chance to avoid Poison, Blind, and Bleeding"] && AvoidPBB) 
    || (Item.Affix["Monsters reflect # of Elemental Damage"] && ElementalReflect) 
    || (Item.Affix["Monsters reflect # of Physical Damage"] && PhysicalReflect) 
    || (Item.Affix["Players cannot Regenerate Life, Mana or Energy Shield"] && NoRegen) 
    || (Item.Affix["Cannot Leech Life from Monsters"] && NoLeech)
    || (Item.Affix["-# maximum Player Resistances"] && MinusMPR)
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
  
; 
; GemSwap - Swap gems between two locations
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GemSwap()
  {
    GemSwapCommand:
      Thread, NoTimers, true    ;Critical
      Keywait, Alt
      BlockInput, MouseMove
      MouseGetPos xx, yy
      RandomSleep(45,45)

      If !GuiStatus("OnInventory")
      {      
        Send {%hotkeyInventory%} 
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
          Send {%hotkeyWeaponSwapKey%}
          RandomSleep(45,45)
        }
        LeftClick(AlternateGemX, AlternateGemY)
        RandomSleep(90,120)
        If (AlternateGemOnSecondarySlot && !GemItemToogle)
        {
          Send {%hotkeyWeaponSwapKey%}
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
          Send {%hotkeyWeaponSwapKey%}
          RandomSleep(45,45)
        }
        LeftClick(AlternateGem2X, AlternateGem2Y)
        RandomSleep(90,120)
        If (AlternateGem2OnSecondarySlot && !GemItemToogle2)
        {
          Send {%hotkeyWeaponSwapKey%}
          RandomSleep(45,45)
        }
        LeftClick(CurrentGem2X, CurrentGem2Y)
        RandomSleep(90,120)
      }
      Send {%hotkeyInventory%} 
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
      Thread, NoTimers, true    ;Critical
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
        Send {%hotkeyInventory%}
        RandomSleep(56,68)
      }
      RightClick(PortalScrollX, PortalScrollY)

      Send {%hotkeyInventory%}
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
      Thread, NoTimers, true    ;Critical
      If PopFlaskRespectCD
        TriggerFlask(TriggerPopFlasks)
      Else 
      {
        If PopFlasks1
        {
          If YesPopAllExtraKeys 
            Send %keyFlask1% 
          Else
            Send %KeyFlask1Proper%
          OnCooldown[1]:=1 
          ; SendMSG(3, 1)
          Cooldown:=CooldownFlask1
          settimer, TimerFlask1, %Cooldown%
          RandomSleep(-99,99)
        }
        If PopFlasks2
        {
          If YesPopAllExtraKeys 
            Send %keyFlask2% 
          Else
            Send %KeyFlask2Proper%
          OnCooldown[2]:=1 
          ; SendMSG(3, 2)
          Cooldown:=CooldownFlask2
          settimer, TimerFlask2, %Cooldown%
          RandomSleep(-99,99)
        }
        If PopFlasks3
        {
          If YesPopAllExtraKeys 
            Send %keyFlask3% 
          Else
            Send %KeyFlask3Proper%
          OnCooldown[3]:=1 
          ; SendMSG(3, 3)
          Cooldown:=CooldownFlask3
          settimer, TimerFlask3, %Cooldown%
          RandomSleep(-99,99)
        }
        If PopFlasks4
        {
          If YesPopAllExtraKeys 
            Send %keyFlask4% 
          Else
            Send %KeyFlask4Proper%
          OnCooldown[4]:=1 
          Cooldown:=CooldownFlask4
          ; SendMSG(3, 4)
          settimer, TimerFlask4, %Cooldown%
          RandomSleep(-99,99)
        }
        If PopFlasks5
        {
          If YesPopAllExtraKeys 
            Send %keyFlask5% 
          Else
            Send %KeyFlask5Proper%
          OnCooldown[5]:=1 
          ; SendMSG(3, 5)
          Cooldown:=CooldownFlask5
          settimer, TimerFlask5, %Cooldown%
        }
      }
      Thread, NoTimers, False    ;End Critical
    return
    }

; LogoutCommand - Logout Function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  LogoutCommand(){
    LogoutCommand:
      Thread, NoTimers, true    ;Critical
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
      If YesGlobeScan
      {
        If (!RadioCi)
          Log("Exit with " . Player.Percent.Life . "`% Life", CurrentLocation)
        Else
          Log("Exit with " . Player.Percent.ES . "`% ES", CurrentLocation)
      }
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
        if (ok:=FindText( Round(GameX + GameW * .93) , GameY + Round(GameH * .17), GameX + GameW , GameY + Round(GameH * .8), 0, 0, SkillUpStr,0))
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
    Global GamePID, NoGame, GameActive
    If (GamePID := WinExist(GameStr))
    {
      GameActive := WinActive(GameStr)
      WinGetPos, , , nGameW, nGameH
      newDim := (nGameW != GameW || nGameH != GameH)
      global GuiX, GuiY, RescaleRan, ToggleExist
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
        Gui 2: Show, x%GuiX% y%GuiY% NA, StatusOverlay
        ToggleExist := True
        NoGame := False
        If (YesPersistantToggle)
          AutoReset()
      }
      Else If (ToggleExist && !GameActive)
      {
        ToggleExist := False
        Gui 2: Show, Hide
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
        Gui 2: Show, Hide
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
    ;Thread, NoTimers, true    ;Critical
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
; Coord - : Pixel information on Mouse Cursor, provides pixel location and GRB color hex
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Coord(){
    Global Picker
    CoordCommand:
    Rect := LetUserSelectRect(1)
    If (Rect)
    {
      T1 := A_TickCount
      Ding(10000,-11,"Building an average of area colors`nThis may take some time")
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
    Global Controller, Controller_Active
    If (inputType = "Main")
    {
      Controller("Refresh")
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
        DetectJoystick()
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
        If (!MovementHotkeyActive && JoyLHoldCount > 1 && GuiStatus("",0))
        {
          Click, Down
          MovementHotkeyActive := True
        }
        If (YesTriggerUtilityKey && MovementHotkeyActive
        && (Abs(Controller.LX) >= 60 || Abs(Controller.LY) >= 70 )
        && JoyLHoldCount > 3 && GuiStatus("",0))
        {
          TriggerUtility(TriggerUtilityKey)
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
        MouseMove,% ScrCenter.X + Controller.RX * JoyMultiplier, % ScrCenter.Yadjusted - Controller.RY * JoyMultiplier
        ++JoyRHoldCount
        If (!MainAttackPressedActive && JoyRHoldCount > 2 && YesTriggerJoystickRightKey)
        {
          Obj := SplitModsFromKey(hotkeyControllerJoystickRight)
          Send, % Obj.Mods "{" Obj.Key " down}"
          MainAttackPressedActive := True
        }
      }
      Else
      {
        If (MainAttackPressedActive && YesTriggerJoystickRightKey)
        {
          Obj := SplitModsFromKey(hotkeyControllerJoystickRight)
          Send, % Obj.Mods "{" Obj.Key " up}"
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
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " down}"
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
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " down}"
              State%Key% := 1
              MainAttackPressedActive := True
            }
            Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
            {
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " down}"
              State%Key% := 1
              SecondaryAttackPressedActive := True
            }
            Else
            {
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " down}"
              State%Key% := 1
            }
          }
          Else If (!s && State%Key% = 1)
          {
            If (hotkeyControllerButton%Key% = hotkeyLootScan && LootVacuum)
            {
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " up}"
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
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " up}"
              State%Key% := 0
              MainAttackPressedActive := 0
            }
            Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
            {
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " up}"
              State%Key% := 0
              SecondaryAttackPressedActive := 0
            }
            Else
            {
              Obj := SplitModsFromKey(hotkeyControllerButton%Key%)
              Send, % Obj.Mods "{" Obj.Key " up}"
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
          Sleep, 100 - (HeldCountPOV * 15 <= 70?HeldCountPOV * 15:70)
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
    Percentage := Round((axisPos / (Positive?32767:32768)) * 100 ,2)
    Return Percentage 
  }
  IsModifier(Character) {
    static Modifiers := {"!": 1, "#": 1, "~": 1, "^": 1, "*": 1, "+": 1}
    return Modifiers.HasKey(Character)
  }
  SplitModsFromKey(key){
    Mods := String := ""
    for k, Letter in StrSplit(key) {
      if (IsModifier(Letter)) {
        Mods .= Letter
      }
      else {
        String .= Letter
      }
    }
    Return {"Mods":Mods, "Key":String }
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Configuration handling, ini updates, Hotkey handling, Profiles, Calibration, Ignore list, Loot Filter, Webpages (MISC BACKEND)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { ; Read, Save, Load - Includes basic hotkey setup
    readFromFile(){
      global
      Thread, NoTimers, true    ;Critical

      LoadArray()

      ; Login Information
      IniRead, PoESessionID, %A_ScriptDir%\save\Account.ini, GGG, PoESessionID, %A_Space%

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
      IniRead, DetonateMines, %A_ScriptDir%\save\Settings.ini, General, DetonateMines, 0
      IniRead, DetonateMinesDelay, %A_ScriptDir%\save\Settings.ini, General, DetonateMinesDelay, 500
      IniRead, PauseMinesDelay, %A_ScriptDir%\save\Settings.ini, General, PauseMinesDelay, 250
      IniRead, LootVacuum, %A_ScriptDir%\save\Settings.ini, General, LootVacuum, 0
      IniRead, YesVendor, %A_ScriptDir%\save\Settings.ini, General, YesVendor, 1
      IniRead, YesStash, %A_ScriptDir%\save\Settings.ini, General, YesStash, 1
      IniRead, YesSeedStockPile, %A_ScriptDir%\save\Settings.ini, General, YesSeedStockPile, 1
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
      IniRead, QSonMainAttack, %A_ScriptDir%\save\Settings.ini, General, QSonMainAttack, 0
      IniRead, QSonSecondaryAttack, %A_ScriptDir%\save\Settings.ini, General, QSonSecondaryAttack, 0
      IniRead, YesPersistantToggle, %A_ScriptDir%\save\Settings.ini, General, YesPersistantToggle, 0
      IniRead, YesPopAllExtraKeys, %A_ScriptDir%\save\Settings.ini, General, YesPopAllExtraKeys, 0
      IniRead, ManaThreshold, %A_ScriptDir%\save\Settings.ini, General, ManaThreshold, 10
      IniRead, YesEldritchBattery, %A_ScriptDir%\save\Settings.ini, General, YesEldritchBattery, 0
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
      IniRead, YesAutoSkillUp, %A_ScriptDir%\save\Settings.ini, General, YesAutoSkillUp, 0
      IniRead, YesWaitAutoSkillUp, %A_ScriptDir%\save\Settings.ini, General, YesWaitAutoSkillUp, 0
      IniRead, YesClickPortal, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal, 0
      IniRead, RelogOnQuit, %A_ScriptDir%\save\Settings.ini, General, RelogOnQuit, 0
      IniRead, AreaScale, %A_ScriptDir%\save\Settings.ini, General, AreaScale, 60
      IniRead, LVdelay, %A_ScriptDir%\save\Settings.ini, General, LVdelay, 30
      IniRead, YesLootChests, %A_ScriptDir%\save\Settings.ini, General, YesLootChests, 1
      IniRead, YesLootDelve, %A_ScriptDir%\save\Settings.ini, General, YesLootDelve, 1
      IniRead, YesGlobeScan, %A_ScriptDir%\save\Settings.ini, General, YesGlobeScan, 1
      IniRead, YesStashChaosRecipe, %A_ScriptDir%\save\Settings.ini, General, YesStashChaosRecipe, 0
      IniRead, ChaosRecipeMaxHolding, %A_ScriptDir%\save\Settings.ini, General, ChaosRecipeMaxHolding, 10
      IniRead, YesFillMetamorph, %A_ScriptDir%\save\Settings.ini, General, YesFillMetamorph, 0
      IniRead, YesPredictivePrice, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice, Off
      IniRead, YesPredictivePrice_Percent_Val, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice_Percent_Val, 100
      IniRead, CastOnDetonate, %A_ScriptDir%\save\Settings.ini, General, CastOnDetonate, 0
      IniRead, hotkeyCastOnDetonate, %A_ScriptDir%\save\Settings.ini, General, hotkeyCastOnDetonate, q

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
      IniRead, ElementalReflect, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ElementalReflect, 0
      IniRead, PhysicalReflect, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, PhysicalReflect, 0
      IniRead, NoRegen, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoRegen, 0
      IniRead, NoLeech, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoLeech, 0
      IniRead, AvoidAilments, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidAilments, 0
      IniRead, AvoidPBB, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidPBB, 0
      IniRead, MinusMPR, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MinusMPR, 0
      IniRead, MMapItemQuantity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity, 1
      IniRead, MMapItemRarity, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity, 1
      IniRead, MMapMonsterPackSize, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize, 1
      IniRead, EnableMQQForMagicMap, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap, 0

      ;Automation Settings
      IniRead, YesEnableAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation, 0
      IniRead, FirstAutomationSetting, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting, %A_Space%
      IniRead, YesEnableNextAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation, 0
      IniRead, YesEnableSeedAutomation, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableSeedAutomation, 0
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
      IniRead, StashTabOil, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabOil, 1
      IniRead, StashTabBlightedMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlightedMap, 1
      IniRead, StashTabDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium, 1
      IniRead, StashTabFossil, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFossil, 1
      IniRead, StashTabResonator, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabResonator, 1
      IniRead, StashTabCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCrafting, 1
      IniRead, StashTabProphecy, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabProphecy, 1
      IniRead, StashTabVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabVeiled, 1
      IniRead, StashTabOrgan, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabOrgan, 1
      IniRead, StashTabYesOrgan, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOrgan, 1
      IniRead, StashTabGemSupport, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemSupport, 1
      IniRead, StashTabClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabClusterJewel, 1
      IniRead, StashTabYesClusterJewel, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesClusterJewel, 1
      IniRead, StashTabDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDump, 1
      IniRead, StashTabYesCurrency, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCurrency, 1
      IniRead, StashTabYesMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesMap, 1
      IniRead, StashTabYesDivination, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDivination, 1
      IniRead, StashTabYesGem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGem, 1
      IniRead, StashTabYesGemQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemQuality, 1
      IniRead, StashTabYesGemSupport, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemSupport, 1
      IniRead, StashTabYesFlaskQuality, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFlaskQuality, 1
      IniRead, StashTabYesLinked, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesLinked, 1
      IniRead, StashTabYesCollection, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCollection, 1
      IniRead, StashTabYesUniqueRing, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueRing, 1
      IniRead, StashTabYesUniqueDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesUniqueDump, 1
      IniRead, StashTabYesInfluencedItem, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesInfluencedItem, 1
      IniRead, StashTabYesFragment, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment, 1
      IniRead, StashTabYesEssence, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence, 1
      IniRead, StashTabYesOil, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOil, 1
      IniRead, StashTabYesBlightedMap, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlightedMap, 1
      IniRead, StashTabYesDelirium, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium, 1
      IniRead, StashTabYesFossil, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFossil, 1
      IniRead, StashTabYesResonator, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesResonator, 1
      IniRead, StashTabYesCrafting, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting, 1
      IniRead, StashTabYesProphecy, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesProphecy, 1
      IniRead, StashTabYesVeiled, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled, 1
      IniRead, StashTabYesDump, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump, 0
      IniRead, StashDumpInTrial, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial, 0
      IniRead, StashTabPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive, 1
      IniRead, StashTabYesPredictive, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive, 0
      IniRead, StashTabYesPredictive_Price, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive_Price, 5
      IniRead, StashTabCatalyst, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCatalyst, 1
      IniRead, StashTabYesCatalyst, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCatalyst, 0
      IniRead, StashTabGemVaal, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemVaal, 1
      IniRead, StashTabYesGemVaal, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemVaal, 0
      IniRead, StashTabNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice, 1
      IniRead, StashTabYesNinjaPrice, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice, 0
      IniRead, StashTabYesNinjaPrice_Price, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price, 5
      
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
      IniRead, SeedStockPileStr, %A_ScriptDir%\save\Settings.ini, FindText Strings, SeedStockPileStr, %1080_SeedStockPileStr%
      If SeedStockPileStr
        SeedStockPileStr := """" . SeedStockPileStr . """"
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
      IniRead, StackRelease_BuffIcon, %A_ScriptDir%\save\Settings.ini, FindText Strings, StackRelease_BuffIcon, %1080_StackRelease_BuffIcon%
      If StackRelease_BuffIcon
        StackRelease_BuffIcon := """" . StackRelease_BuffIcon . """"
      IniRead, StackRelease_BuffCount, %A_ScriptDir%\save\Settings.ini, FindText Strings, StackRelease_BuffCount, %1080_StackRelease_BuffCount%
      If StackRelease_BuffCount
        StackRelease_BuffCount := """" . StackRelease_BuffCount . """"

      ; Stack Release settings
      IniRead, StackRelease_Keybind, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Keybind, RButton
      IniRead, StackRelease_X1Offset, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_X1Offset, 0
      IniRead, StackRelease_Y1Offset, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Y1Offset, 2
      IniRead, StackRelease_X2Offset, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_X2Offset, 0
      IniRead, StackRelease_Y2Offset, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Y2Offset, 15
      IniRead, StackRelease_Enable, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Enable, 0

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
      IniRead, varOnStockPile, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStockPile, 0x1F2732
      IniRead, varOnDetonate, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate, 0x5D4661

      ;Life Colors
      IniRead, varLife20, %A_ScriptDir%\save\Settings.ini, Life Colors, Life20, 0x4D0D11
      IniRead, varLife30, %A_ScriptDir%\save\Settings.ini, Life Colors, Life30, 0x640E13
      IniRead, varLife40, %A_ScriptDir%\save\Settings.ini, Life Colors, Life40, 0x7D0E14
      IniRead, varLife50, %A_ScriptDir%\save\Settings.ini, Life Colors, Life50, 0xA0161E
      IniRead, varLife60, %A_ScriptDir%\save\Settings.ini, Life Colors, Life60, 0xB51521
      IniRead, varLife70, %A_ScriptDir%\save\Settings.ini, Life Colors, Life70, 0xB31326
      IniRead, varLife80, %A_ScriptDir%\save\Settings.ini, Life Colors, Life80, 0x841F26
      IniRead, varLife90, %A_ScriptDir%\save\Settings.ini, Life Colors, Life90, 0x662027
        
      ;ES Colors
      IniRead, varES20, %A_ScriptDir%\save\Settings.ini, ES Colors, ES20, 0x46C6FF
      IniRead, varES30, %A_ScriptDir%\save\Settings.ini, ES Colors, ES30, 0x68D3FF
      IniRead, varES40, %A_ScriptDir%\save\Settings.ini, ES Colors, ES40, 0x83FFFF
      IniRead, varES50, %A_ScriptDir%\save\Settings.ini, ES Colors, ES50, 0x81FFFF
      IniRead, varES60, %A_ScriptDir%\save\Settings.ini, ES Colors, ES60, 0x97FFFF
      IniRead, varES70, %A_ScriptDir%\save\Settings.ini, ES Colors, ES70, 0x7DCFFF
      IniRead, varES80, %A_ScriptDir%\save\Settings.ini, ES Colors, ES80, 0x5C9DDC
      IniRead, varES90, %A_ScriptDir%\save\Settings.ini, ES Colors, ES90, 0x3C93D9
      
      ;Mana Colors
      IniRead, varMana10, %A_ScriptDir%\save\Settings.ini, Mana Colors, Mana10, 0x1B203D
      IniRead, varManaThreshold, %A_ScriptDir%\save\Settings.ini, Mana Colors, ManaThreshold, 0x1B203D
      
      ;Life Triggers
      IniRead, TriggerLife20, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife20, 00000
      IniRead, TriggerLife30, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife30, 00000
      IniRead, TriggerLife40, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife40, 00000
      IniRead, TriggerLife50, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife50, 00000
      IniRead, TriggerLife60, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife60, 00000
      IniRead, TriggerLife70, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife70, 00000
      IniRead, TriggerLife80, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife80, 00000
      IniRead, TriggerLife90, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife90, 00000
      IniRead, DisableLife, %A_ScriptDir%\save\Settings.ini, Life Triggers, DisableLife, 11111
      Loop, 5 {
        valueLife20 := substr(TriggerLife20, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life20, %valueLife20%
        valueLife30 := substr(TriggerLife30, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life30, %valueLife30%
        valueLife40 := substr(TriggerLife40, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life40, %valueLife40%
        valueLife50 := substr(TriggerLife50, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life50, %valueLife50%
        valueLife60 := substr(TriggerLife60, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life60, %valueLife60%
        valueLife70 := substr(TriggerLife70, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life70, %valueLife70%
        valueLife80 := substr(TriggerLife80, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life80, %valueLife80%
        valueLife90 := substr(TriggerLife90, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Life90, %valueLife90%
        valueDisableLife := substr(DisableLife, (A_Index), 1)
        GuiControl, , RadioUncheck%A_Index%Life, %valueDisableLife%
        }
      
      ;ES Triggers
      IniRead, TriggerES20, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES20, 00000
      IniRead, TriggerES30, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES30, 00000
      IniRead, TriggerES40, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES40, 00000
      IniRead, TriggerES50, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES50, 00000
      IniRead, TriggerES60, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES60, 00000
      IniRead, TriggerES70, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES70, 00000
      IniRead, TriggerES80, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES80, 00000
      IniRead, TriggerES90, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES90, 00000
      IniRead, DisableES, %A_ScriptDir%\save\Settings.ini, ES Triggers, DisableES, 11111
      Loop, 5 {
        valueES20 := substr(TriggerES20, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES20, %valueES20%
        valueES30 := substr(TriggerES30, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES30, %valueES30%
        valueES40 := substr(TriggerES40, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES40, %valueES40%
        valueES50 := substr(TriggerES50, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES50, %valueES50%
        valueES60 := substr(TriggerES60, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES60, %valueES60%
        valueES70 := substr(TriggerES70, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES70, %valueES70%
        valueES80 := substr(TriggerES80, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES80, %valueES80%
        valueES90 := substr(TriggerES90, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%ES90, %valueES90%
        valueDisableES := substr(DisableES, (A_Index), 1)
        GuiControl, , RadioUncheck%A_Index%ES, %valueDisableES%
      }  
      
      ;Mana Triggers
      IniRead, TriggerMana10, %A_ScriptDir%\save\Settings.ini, Mana Triggers, TriggerMana10, 00000
      Loop, 5 {  
        valueMana10 := substr(TriggerMana10, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
      }
      
      ;Utility Buttons
      IniRead, YesUtility1, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1, 0
      IniRead, YesUtility2, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2, 0
      IniRead, YesUtility3, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3, 0
      IniRead, YesUtility4, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4, 0
      IniRead, YesUtility5, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5, 0
      IniRead, YesUtility6, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6, 0
      IniRead, YesUtility7, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7, 0
      IniRead, YesUtility8, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8, 0
      IniRead, YesUtility9, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9, 0
      IniRead, YesUtility10, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10, 0
      IniRead, YesUtility1Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1Quicksilver, 0
      IniRead, YesUtility2Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2Quicksilver, 0
      IniRead, YesUtility3Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3Quicksilver, 0
      IniRead, YesUtility4Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4Quicksilver, 0
      IniRead, YesUtility5Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5Quicksilver, 0
      IniRead, YesUtility6Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6Quicksilver, 0
      IniRead, YesUtility7Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7Quicksilver, 0
      IniRead, YesUtility8Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8Quicksilver, 0
      IniRead, YesUtility9Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9Quicksilver, 0
      IniRead, YesUtility10Quicksilver, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10Quicksilver, 0
      IniRead, YesUtility1InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1InverseBuff, 0
      IniRead, YesUtility2InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2InverseBuff, 0
      IniRead, YesUtility3InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3InverseBuff, 0
      IniRead, YesUtility4InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4InverseBuff, 0
      IniRead, YesUtility5InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5InverseBuff, 0
      IniRead, YesUtility6InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6InverseBuff, 0
      IniRead, YesUtility7InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7InverseBuff, 0
      IniRead, YesUtility8InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8InverseBuff, 0
      IniRead, YesUtility9InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9InverseBuff, 0
      IniRead, YesUtility10InverseBuff, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10InverseBuff, 0
      IniRead, YesUtility1MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1MainAttack, 0
      IniRead, YesUtility2MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2MainAttack, 0
      IniRead, YesUtility3MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3MainAttack, 0
      IniRead, YesUtility4MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4MainAttack, 0
      IniRead, YesUtility5MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5MainAttack, 0
      IniRead, YesUtility6MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6MainAttack, 0
      IniRead, YesUtility7MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7MainAttack, 0
      IniRead, YesUtility8MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8MainAttack, 0
      IniRead, YesUtility9MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9MainAttack, 0
      IniRead, YesUtility10MainAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10MainAttack, 0
      IniRead, YesUtility1SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1SecondaryAttack, 0
      IniRead, YesUtility2SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2SecondaryAttack, 0
      IniRead, YesUtility3SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3SecondaryAttack, 0
      IniRead, YesUtility4SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4SecondaryAttack, 0
      IniRead, YesUtility5SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5SecondaryAttack, 0
      IniRead, YesUtility6SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6SecondaryAttack, 0
      IniRead, YesUtility7SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7SecondaryAttack, 0
      IniRead, YesUtility8SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8SecondaryAttack, 0
      IniRead, YesUtility9SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9SecondaryAttack, 0
      IniRead, YesUtility10SecondaryAttack, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10SecondaryAttack, 0
      
      ;Utility Percents  
      IniRead, YesUtility1LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1LifePercent, Off
      IniRead, YesUtility2LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2LifePercent, Off
      IniRead, YesUtility3LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3LifePercent, Off
      IniRead, YesUtility4LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4LifePercent, Off
      IniRead, YesUtility5LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5LifePercent, Off
      IniRead, YesUtility6LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6LifePercent, Off
      IniRead, YesUtility7LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7LifePercent, Off
      IniRead, YesUtility8LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8LifePercent, Off
      IniRead, YesUtility9LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9LifePercent, Off
      IniRead, YesUtility10LifePercent, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10LifePercent, Off
      IniRead, YesUtility1EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility1EsPercent, Off
      IniRead, YesUtility2EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility2EsPercent, Off
      IniRead, YesUtility3EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility3EsPercent, Off
      IniRead, YesUtility4EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility4EsPercent, Off
      IniRead, YesUtility5EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility5EsPercent, Off
      IniRead, YesUtility6EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility6EsPercent, Off
      IniRead, YesUtility7EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility7EsPercent, Off
      IniRead, YesUtility8EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility8EsPercent, Off
      IniRead, YesUtility9EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility9EsPercent, Off
      IniRead, YesUtility10EsPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility10EsPercent, Off
      IniRead, YesUtility1ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility1ManaPercent, Off
      IniRead, YesUtility2ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility2ManaPercent, Off
      IniRead, YesUtility3ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility3ManaPercent, Off
      IniRead, YesUtility4ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility4ManaPercent, Off
      IniRead, YesUtility5ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility5ManaPercent, Off
      IniRead, YesUtility6ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility6ManaPercent, Off
      IniRead, YesUtility7ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility7ManaPercent, Off
      IniRead, YesUtility8ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility8ManaPercent, Off
      IniRead, YesUtility9ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility9ManaPercent, Off
      IniRead, YesUtility10ManaPercent, %A_ScriptDir%\save\Settings.ini,   Utility Buttons, YesUtility10ManaPercent, Off
      
      ;Utility Cooldowns
      IniRead, CooldownUtility1, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility1, 5000
      IniRead, CooldownUtility2, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility2, 5000
      IniRead, CooldownUtility3, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility3, 5000
      IniRead, CooldownUtility4, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility4, 5000
      IniRead, CooldownUtility5, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility5, 5000
      IniRead, CooldownUtility6, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility6, 5000
      IniRead, CooldownUtility7, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility7, 5000
      IniRead, CooldownUtility8, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility8, 5000
      IniRead, CooldownUtility9, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility9, 5000
      IniRead, CooldownUtility10, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility10, 5000
      
      ;Utility Keys
      IniRead, KeyUtility1, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility1, q
      IniRead, KeyUtility2, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility2, w
      IniRead, KeyUtility3, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility3, e
      IniRead, KeyUtility4, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility4, r
      IniRead, KeyUtility5, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility5, t
      IniRead, KeyUtility6, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility6, t
      IniRead, KeyUtility7, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility7, t
      IniRead, KeyUtility8, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility8, t
      IniRead, KeyUtility9, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility9, t
      IniRead, KeyUtility10, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility10, t

      ;Utility Icon Strings
      IniRead, IconStringUtility1, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility1, %A_Space%
      If IconStringUtility1
        IconStringUtility1 := """" . IconStringUtility1 . """"
      IniRead, IconStringUtility2, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility2, %A_Space%
      If IconStringUtility2
        IconStringUtility2 := """" . IconStringUtility2 . """"
      IniRead, IconStringUtility3, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility3, %A_Space%
      If IconStringUtility3
        IconStringUtility3 := """" . IconStringUtility3 . """"
      IniRead, IconStringUtility4, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility4, %A_Space%
      If IconStringUtility4
        IconStringUtility4 := """" . IconStringUtility4 . """"
      IniRead, IconStringUtility5, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility5, %A_Space%
      If IconStringUtility5
        IconStringUtility5 := """" . IconStringUtility5 . """"
      IniRead, IconStringUtility6, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility6, %A_Space%
      If IconStringUtility6
        IconStringUtility6 := """" . IconStringUtility6 . """"
      IniRead, IconStringUtility7, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility7, %A_Space%
      If IconStringUtility7
        IconStringUtility7 := """" . IconStringUtility7 . """"
      IniRead, IconStringUtility8, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility8, %A_Space%
      If IconStringUtility8
        IconStringUtility8 := """" . IconStringUtility8 . """"
      IniRead, IconStringUtility9, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility9, %A_Space%
      If IconStringUtility9
        IconStringUtility9 := """" . IconStringUtility9 . """"
      IniRead, IconStringUtility10, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility10, %A_Space%
      If IconStringUtility10
        IconStringUtility10 := """" . IconStringUtility10 . """"

      ;Utility Keys
      IniRead, hotkeyUp,     %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyUp,   w
      IniRead, hotkeyDown,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyDown,  s
      IniRead, hotkeyLeft,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyLeft,  a
      IniRead, hotkeyRight,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyRight, d
      
      ;Flask Cooldowns
      IniRead, CooldownFlask1, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask1, 4800
      IniRead, CooldownFlask2, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask2, 4800
      IniRead, CooldownFlask3, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask3, 4800
      IniRead, CooldownFlask4, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask4, 4800
      IniRead, CooldownFlask5, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask5, 4800

      ;Flask Keys
      IniRead, keyFlask1, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask1, 1
      IniRead, keyFlask2, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask2, 2
      IniRead, keyFlask3, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask3, 3
      IniRead, keyFlask4, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask4, 4
      IniRead, keyFlask5, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask5, 5
      
      Loop 5
      {
        key := keyFlask%A_Index%
        str := StrSplit(key, " ", ,2)
        KeyFlask%A_Index%Proper := str[1]
      }

      ;Grab Currency From Inventory
      IniRead, GrabCurrencyPosX, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosX, 1877
      IniRead, GrabCurrencyPosY, %A_ScriptDir%\save\Settings.ini, Grab Currency, GrabCurrencyPosY, 772

      ;Gem Swap Gem 1
      IniRead, CurrentGemX, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGemX, 1353
      IniRead, CurrentGemY, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGemY, 224
      IniRead, AlternateGemX, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemX, 1407
      IniRead, AlternateGemY, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemY, 201
      IniRead, AlternateGemOnSecondarySlot, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemOnSecondarySlot, 0
      IniRead, GemItemToogle, %A_ScriptDir%\save\Settings.ini, Gem Swap, GemItemToogle, 0

      ;Gem Swap Gem 2
      IniRead, CurrentGem2X, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGem2X, 0
      IniRead, CurrentGem2Y, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGem2Y, 0
      IniRead, AlternateGem2X, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2X, 0
      IniRead, AlternateGem2Y, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2Y, 0
      IniRead, AlternateGem2OnSecondarySlot, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2OnSecondarySlot, 0
      IniRead, GemItemToogle2, %A_ScriptDir%\save\Settings.ini, Gem Swap, GemItemToogle2, 0
      
      ;Coordinates
      IniRead, GuiX, %A_ScriptDir%\save\Settings.ini, Coordinates, GuiX, -10
      IniRead, GuiY, %A_ScriptDir%\save\Settings.ini, Coordinates, GuiY, 1027
      IniRead, PortalScrollX, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollX, 1825
      IniRead, PortalScrollY, %A_ScriptDir%\save\Settings.ini, Coordinates, PortalScrollY, 825
      IniRead, WisdomScrollX, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollX, 1875
      IniRead, WisdomScrollY, %A_ScriptDir%\save\Settings.ini, Coordinates, WisdomScrollY, 825
      IniRead, StockPortal, %A_ScriptDir%\save\Settings.ini, Coordinates, StockPortal, 0
      IniRead, StockWisdom, %A_ScriptDir%\save\Settings.ini, Coordinates, StockWisdom, 0
      
      
      ;Attack Flasks
      IniRead, TriggerMainAttack, %A_ScriptDir%\save\Settings.ini, Attack Triggers, TriggerMainAttack, 00000
      IniRead, TriggerSecondaryAttack, %A_ScriptDir%\save\Settings.ini, Attack Triggers, TriggerSecondaryAttack, 00000
      Loop, 5{  
        valueMainAttack := substr(TriggerMainAttack, (A_Index), 1)
        GuiControl, , MainAttackbox%A_Index%, %valueMainAttack%
        valueSecondaryAttack := substr(TriggerSecondaryAttack, (A_Index), 1)
        GuiControl, , SecondaryAttackbox%A_Index%, %valueSecondaryAttack%
      }
      
      ;Quicksilver
      IniRead, TriggerQuicksilverDelay, %A_ScriptDir%\save\Settings.ini, Quicksilver, TriggerQuicksilverDelay, .5
      IniRead, TriggerQuicksilver, %A_ScriptDir%\save\Settings.ini, Quicksilver, TriggerQuicksilver, 00000
      Loop, 5 {  
        Radiobox%A_Index%QS := substr(TriggerQuicksilver, (A_Index), 1)
        GuiControl, , Radiobox%A_Index%QS, % Radiobox%A_Index%QS
      }
      
      ;Pop Flasks
      IniRead, TriggerPopFlasks, %A_ScriptDir%\save\Settings.ini, PopFlasks, TriggerPopFlasks, 11111
      Loop, 5 {  
        valuePopFlasks := substr(TriggerPopFlasks, (A_Index), 1)
        GuiControl, , PopFlasks%A_Index%, %valuePopFlasks%
      }
      
      ;CharacterTypeCheck
      IniRead, RadioLife, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Life, 1
      IniRead, RadioHybrid, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Hybrid, 0
      IniRead, RadioCi, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Ci, 0
      
      ;AutoQuit
      IniRead, QuitBelow, %A_ScriptDir%\save\Settings.ini, AutoQuit, QuitBelow, 20
      IniRead, RadioCritQuit, %A_ScriptDir%\save\Settings.ini, AutoQuit, CritQuit, 1
      IniRead, RadioPortalQuit, %A_ScriptDir%\save\Settings.ini, AutoQuit, PortalQuit, 0
      IniRead, RadioNormalQuit, %A_ScriptDir%\save\Settings.ini, AutoQuit, NormalQuit, 0
      
      ;Profile Editbox
      Iniread, ProfileText1, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText1, Profile 1
      Iniread, ProfileText2, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText2, Profile 2
      Iniread, ProfileText3, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText3, Profile 3
      Iniread, ProfileText4, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText4, Profile 4
      Iniread, ProfileText5, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText5, Profile 5
      Iniread, ProfileText6, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText6, Profile 6
      Iniread, ProfileText7, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText7, Profile 7
      Iniread, ProfileText8, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText8, Profile 8
      Iniread, ProfileText9, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText9, Profile 9
      Iniread, ProfileText10, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText10, Profile 10

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
        hotkey,% hotkeyStartCraft, StartCraftCommand, Off
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
      IniRead, hotkeyStartCraft, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft, F2
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
        hotkey,% hotkeyStartCraft, StartCraftCommand, On
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
      IniRead, selectedLeague, %A_ScriptDir%\save\Settings.ini, Database, selectedLeague, Harvest
      IniRead, UpdateDatabaseInterval, %A_ScriptDir%\save\Settings.ini, Database, UpdateDatabaseInterval, 2
      IniRead, YesNinjaDatabase, %A_ScriptDir%\save\Settings.ini, Database, YesNinjaDatabase, 1
      IniRead, ForceMatch6Link, %A_ScriptDir%\save\Settings.ini, Database, ForceMatch6Link, 0
      IniRead, ForceMatchGem20, %A_ScriptDir%\save\Settings.ini, Database, ForceMatchGem20, 0

      RegisterHotkeys()
      checkActiveType()
      Thread, NoTimers, False    ;End Critical
    Return
    }

    submit(){  
    updateEverything:
      global
      Thread, NoTimers, true    ;Critical

      IniWrite, %PoESessionID%, %A_ScriptDir%\save\Account.ini, GGG, PoESessionID

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
        hotkey,% hotkeyStartCraft, StartCraftCommand, Off
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

      Hotkey If, % fn1
      If 1Suffix1 != A_Space
        Hotkey, *%1Suffix1%, 1FireWhisperHotkey1, off
      If 1Suffix2 != A_Space
        Hotkey, *%1Suffix2%, 1FireWhisperHotkey2, off
      If 1Suffix3 != A_Space
        Hotkey, *%1Suffix3%, 1FireWhisperHotkey3, off
      If 1Suffix4 != A_Space
        Hotkey, *%1Suffix4%, 1FireWhisperHotkey4, off
      If 1Suffix5 != A_Space
        Hotkey, *%1Suffix5%, 1FireWhisperHotkey5, off
      If 1Suffix6 != A_Space
        Hotkey, *%1Suffix6%, 1FireWhisperHotkey6, off
      If 1Suffix7 != A_Space
        Hotkey, *%1Suffix7%, 1FireWhisperHotkey7, off
      If 1Suffix8 != A_Space
        Hotkey, *%1Suffix8%, 1FireWhisperHotkey8, off
      If 1Suffix9 != A_Space
        Hotkey, *%1Suffix9%, 1FireWhisperHotkey9, off

      Hotkey If, % fn2
      If 2Suffix1 != A_Space
        Hotkey, *%2Suffix1%, 2FireWhisperHotkey1, off
      If 2Suffix2 != A_Space
        Hotkey, *%2Suffix2%, 2FireWhisperHotkey2, off
      If 2Suffix3 != A_Space
        Hotkey, *%2Suffix3%, 2FireWhisperHotkey3, off
      If 2Suffix4 != A_Space
        Hotkey, *%2Suffix4%, 2FireWhisperHotkey4, off
      If 2Suffix5 != A_Space
        Hotkey, *%2Suffix5%, 2FireWhisperHotkey5, off
      If 2Suffix6 != A_Space
        Hotkey, *%2Suffix6%, 2FireWhisperHotkey6, off
      If 2Suffix7 != A_Space
        Hotkey, *%2Suffix7%, 2FireWhisperHotkey7, off
      If 2Suffix8 != A_Space
        Hotkey, *%2Suffix8%, 2FireWhisperHotkey8, off
      If 2Suffix9 != A_Space
        Hotkey, *%2Suffix9%, 2FireWhisperHotkey9, off

      Hotkey If, % fn3
      If stashSuffix1 != A_Space
        Hotkey, *%stashSuffix1%, FireStashHotkey1, off
      If stashSuffix2 != A_Space
        Hotkey, *%stashSuffix2%, FireStashHotkey2, off
      If stashSuffix3 != A_Space
        Hotkey, *%stashSuffix3%, FireStashHotkey3, off
      If stashSuffix4 != A_Space
        Hotkey, *%stashSuffix4%, FireStashHotkey4, off
      If stashSuffix5 != A_Space
        Hotkey, *%stashSuffix5%, FireStashHotkey5, off
      If stashSuffix6 != A_Space
        Hotkey, *%stashSuffix6%, FireStashHotkey6, off
      If stashSuffix7 != A_Space
        Hotkey, *%stashSuffix7%, FireStashHotkey7, off
      If stashSuffix8 != A_Space
        Hotkey, *%stashSuffix8%, FireStashHotkey8, off
      If stashSuffix9 != A_Space
        Hotkey, *%stashSuffix9%, FireStashHotkey9, off

      hotkey, IfWinActive
      If hotkeyOptions
        hotkey,% hotkeyOptions, optionsCommand, Off
      hotkey, IfWinActive, ahk_group POEGameGroup
        
      IfWinExist, ahk_group POEGameGroup 
      {
        Gui, Submit
        Rescale()
        Gui 2: Show, x%GuiX% y%GuiY%
        ToggleExist := True
        WinActivate, ahk_group POEGameGroup
        If (GuiStatus("OnChar") && !YesGlobeScan) {
          ;Life Resample
          varLife20 := ScreenShot_GetColor(vX_Life,vY_Life20)
          varLife30 := ScreenShot_GetColor(vX_Life,vY_Life30)
          varLife40 := ScreenShot_GetColor(vX_Life,vY_Life40)
          varLife50 := ScreenShot_GetColor(vX_Life,vY_Life50)
          varLife60 := ScreenShot_GetColor(vX_Life,vY_Life60)
          varLife70 := ScreenShot_GetColor(vX_Life,vY_Life70)
          varLife80 := ScreenShot_GetColor(vX_Life,vY_Life80)
          varLife90 := ScreenShot_GetColor(vX_Life,vY_Life90)
            
          IniWrite, %varLife20%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life20
          IniWrite, %varLife30%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life30
          IniWrite, %varLife40%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life40
          IniWrite, %varLife50%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life50
          IniWrite, %varLife60%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life60
          IniWrite, %varLife70%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life70
          IniWrite, %varLife80%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life80
          IniWrite, %varLife90%, %A_ScriptDir%\save\Settings.ini, Life Colors, Life90
          ;ES Resample
          varES20 := ScreenShot_GetColor(vX_ES,vY_ES20)
          varES30 := ScreenShot_GetColor(vX_ES,vY_ES30)
          varES40 := ScreenShot_GetColor(vX_ES,vY_ES40)
          varES50 := ScreenShot_GetColor(vX_ES,vY_ES50)
          varES60 := ScreenShot_GetColor(vX_ES,vY_ES60)
          varES70 := ScreenShot_GetColor(vX_ES,vY_ES70)
          varES80 := ScreenShot_GetColor(vX_ES,vY_ES80)
          varES90 := ScreenShot_GetColor(vX_ES,vY_ES90)
          
          IniWrite, %varES20%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES20
          IniWrite, %varES30%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES30
          IniWrite, %varES40%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES40
          IniWrite, %varES50%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES50
          IniWrite, %varES60%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES60
          IniWrite, %varES70%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES70
          IniWrite, %varES80%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES80
          IniWrite, %varES90%, %A_ScriptDir%\save\Settings.ini, ES Colors, ES90
          ;Mana Resample
          varMana10 := ScreenShot_GetColor(vX_Mana,vY_Mana10)
          varManaThreshold := ScreenShot_GetColor(vX_Mana,vY_ManaThreshold)
          IniWrite, %varMana10%, %A_ScriptDir%\save\Settings.ini, Mana Colors, Mana10
          IniWrite, %varManaThreshold%, %A_ScriptDir%\save\Settings.ini, Mana Colors, ManaThreshold
          ;Messagebox  
          ToolTip, % "Script detects you are on Character`rGrabbed new Samples for Life, ES, and Mana colors"
          SetTimer, RemoveTT1, -5000
        } Else If (!YesGlobeScan) {
          MsgBox, 262144, No resample, % "Script Could not detect you on a character`rMake sure you calibrate OnChar if you have not`rCannot sample Life, ES, or Mana colors`nAll other settings will save."
        }
      } Else If (!YesGlobeScan) {
        MsgBox, 262144, No resample, % "Game is not Open`nWill not sample the Life, ES, or Mana colors!`nAll other settings will save."
      }
      Gui, Submit, NoHide
      ;Life Flasks
      IniWrite, %Radiobox1Life20%%Radiobox2Life20%%Radiobox3Life20%%Radiobox4Life20%%Radiobox5Life20%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife20
      IniWrite, %Radiobox1Life30%%Radiobox2Life30%%Radiobox3Life30%%Radiobox4Life30%%Radiobox5Life30%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife30
      IniWrite, %Radiobox1Life40%%Radiobox2Life40%%Radiobox3Life40%%Radiobox4Life40%%Radiobox5Life40%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife40
      IniWrite, %Radiobox1Life50%%Radiobox2Life50%%Radiobox3Life50%%Radiobox4Life50%%Radiobox5Life50%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife50
      IniWrite, %Radiobox1Life60%%Radiobox2Life60%%Radiobox3Life60%%Radiobox4Life60%%Radiobox5Life60%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife60
      IniWrite, %Radiobox1Life70%%Radiobox2Life70%%Radiobox3Life70%%Radiobox4Life70%%Radiobox5Life70%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife70
      IniWrite, %Radiobox1Life80%%Radiobox2Life80%%Radiobox3Life80%%Radiobox4Life80%%Radiobox5Life80%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife80
      IniWrite, %Radiobox1Life90%%Radiobox2Life90%%Radiobox3Life90%%Radiobox4Life90%%Radiobox5Life90%, %A_ScriptDir%\save\Settings.ini, Life Triggers, TriggerLife90
      IniWrite, %RadioUncheck1Life%%RadioUncheck2Life%%RadioUncheck3Life%%RadioUncheck4Life%%RadioUncheck5Life%, %A_ScriptDir%\save\Settings.ini, Life Triggers, DisableLife
        
      
      ;ES Flasks
      IniWrite, %Radiobox1ES20%%Radiobox2ES20%%Radiobox3ES20%%Radiobox4ES20%%Radiobox5ES20%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES20
      IniWrite, %Radiobox1ES30%%Radiobox2ES30%%Radiobox3ES30%%Radiobox4ES30%%Radiobox5ES30%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES30
      IniWrite, %Radiobox1ES40%%Radiobox2ES40%%Radiobox3ES40%%Radiobox4ES40%%Radiobox5ES40%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES40
      IniWrite, %Radiobox1ES50%%Radiobox2ES50%%Radiobox3ES50%%Radiobox4ES50%%Radiobox5ES50%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES50
      IniWrite, %Radiobox1ES60%%Radiobox2ES60%%Radiobox3ES60%%Radiobox4ES60%%Radiobox5ES60%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES60
      IniWrite, %Radiobox1ES70%%Radiobox2ES70%%Radiobox3ES70%%Radiobox4ES70%%Radiobox5ES70%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES70
      IniWrite, %Radiobox1ES80%%Radiobox2ES80%%Radiobox3ES80%%Radiobox4ES80%%Radiobox5ES80%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES80
      IniWrite, %Radiobox1ES90%%Radiobox2ES90%%Radiobox3ES90%%Radiobox4ES90%%Radiobox5ES90%, %A_ScriptDir%\save\Settings.ini, ES Triggers, TriggerES90
      IniWrite, %RadioUncheck1ES%%RadioUncheck2ES%%RadioUncheck3ES%%RadioUncheck4ES%%RadioUncheck5ES%, %A_ScriptDir%\save\Settings.ini, ES Triggers, DisableES
      ;Mana Flasks
      IniWrite, %Radiobox1Mana10%%Radiobox2Mana10%%Radiobox3Mana10%%Radiobox4Mana10%%Radiobox5Mana10%, %A_ScriptDir%\save\Settings.ini, Mana Triggers, TriggerMana10
      

      ;Bandit Extra options
      IniWrite, %BranchName%, %A_ScriptDir%\save\Settings.ini, General, BranchName
      IniWrite, %ScriptUpdateTimeInterval%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval
      IniWrite, %ScriptUpdateTimeType%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType
      IniWrite, %DebugMessages%, %A_ScriptDir%\save\Settings.ini, General, DebugMessages
      IniWrite, %YesTimeMS%, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS
      IniWrite, %YesLocation%, %A_ScriptDir%\save\Settings.ini, General, YesLocation
      IniWrite, %ShowPixelGrid%, %A_ScriptDir%\save\Settings.ini, General, ShowPixelGrid
      IniWrite, %ShowItemInfo%, %A_ScriptDir%\save\Settings.ini, General, ShowItemInfo
      IniWrite, %DetonateMines%, %A_ScriptDir%\save\Settings.ini, General, DetonateMines
      IniWrite, %DetonateMinesDelay%, %A_ScriptDir%\save\Settings.ini, General, DetonateMinesDelay
      IniWrite, %PauseMinesDelay%, %A_ScriptDir%\save\Settings.ini, General, PauseMinesDelay
      IniWrite, %LootVacuum%, %A_ScriptDir%\save\Settings.ini, General, LootVacuum
      IniWrite, %YesVendor%, %A_ScriptDir%\save\Settings.ini, General, YesVendor
      IniWrite, %YesStash%, %A_ScriptDir%\save\Settings.ini, General, YesStash
      IniWrite, %YesSeedStockPile%, %A_ScriptDir%\save\Settings.ini, General, YesSeedStockPile
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
      IniWrite, %CharName%, %A_ScriptDir%\save\Settings.ini, General, CharName
      IniWrite, %EnableChatHotkeys%, %A_ScriptDir%\save\Settings.ini, General, EnableChatHotkeys
      IniWrite, %YesStashKeys%, %A_ScriptDir%\save\Settings.ini, General, YesStashKeys
      IniWrite, %YesPopAllExtraKeys%, %A_ScriptDir%\save\Settings.ini, General, YesPopAllExtraKeys
      IniWrite, %QSonMainAttack%, %A_ScriptDir%\save\Settings.ini, General, QSonMainAttack
      IniWrite, %QSonSecondaryAttack%, %A_ScriptDir%\save\Settings.ini, General, QSonSecondaryAttack
      IniWrite, %YesEldritchBattery%, %A_ScriptDir%\save\Settings.ini, General, YesEldritchBattery
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
      IniWrite, %YesAutoSkillUp%, %A_ScriptDir%\save\Settings.ini, General, YesAutoSkillUp
      IniWrite, %YesWaitAutoSkillUp%, %A_ScriptDir%\save\Settings.ini, General, YesWaitAutoSkillUp
      IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
      IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
      IniWrite, %YesClickPortal%, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal
      IniWrite, %RelogOnQuit%, %A_ScriptDir%\save\Settings.ini, General, RelogOnQuit
      IniWrite, %YesGlobeScan%, %A_ScriptDir%\save\Settings.ini, General, YesGlobeScan
      IniWrite, %YesStashChaosRecipe%, %A_ScriptDir%\save\Settings.ini, General, YesStashChaosRecipe
      IniWrite, %ChaosRecipeMaxHolding%, %A_ScriptDir%\save\Settings.ini, General, ChaosRecipeMaxHolding
      IniWrite, %ManaThreshold%, %A_ScriptDir%\save\Settings.ini, General, ManaThreshold

      ; Overhead Health Bar
      IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB

      ; ASCII Search Strings
      IniWrite, %HealthBarStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, HealthBarStr
      IniWrite, %VendorStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, VendorStr
      IniWrite, %SellItemsStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SellItemsStr
      IniWrite, %StashStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, StashStr
      IniWrite, %SeedStockPileStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SeedStockPileStr
      IniWrite, %SkillUpStr%, %A_ScriptDir%\save\Settings.ini, FindText Strings, SkillUpStr

      ;~ Hotkeys 
      IniWrite, %hotkeyOptions%, %A_ScriptDir%\save\Settings.ini, hotkeys, Options
      IniWrite, %hotkeyAutoQuit%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuit
      IniWrite, %hotkeyAutoFlask%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoFlask
      IniWrite, %hotkeyAutoQuicksilver%, %A_ScriptDir%\save\Settings.ini, hotkeys, AutoQuicksilver
      IniWrite, %hotkeyQuickPortal%, %A_ScriptDir%\save\Settings.ini, hotkeys, QuickPortal
      IniWrite, %hotkeyGemSwap%, %A_ScriptDir%\save\Settings.ini, hotkeys, GemSwap
      IniWrite, %hotkeyStartCraft%, %A_ScriptDir%\save\Settings.ini, hotkeys, StartCraft
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
      
      ;Utility Keys
      IniWrite, %hotkeyUp%,     %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyUp
      IniWrite, %hotkeyDown%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyDown
      IniWrite, %hotkeyLeft%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyLeft
      IniWrite, %hotkeyRight%,   %A_ScriptDir%\save\Settings.ini, Controller Keys, hotkeyRight
      
      ;Utility Buttons
      IniWrite, %YesUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1
      IniWrite, %YesUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2
      IniWrite, %YesUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3
      IniWrite, %YesUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4
      IniWrite, %YesUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5
      IniWrite, %YesUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6
      IniWrite, %YesUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7
      IniWrite, %YesUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8
      IniWrite, %YesUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9
      IniWrite, %YesUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10
      IniWrite, %YesUtility1Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1Quicksilver
      IniWrite, %YesUtility2Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2Quicksilver
      IniWrite, %YesUtility3Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3Quicksilver
      IniWrite, %YesUtility4Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4Quicksilver
      IniWrite, %YesUtility5Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5Quicksilver
      IniWrite, %YesUtility6Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6Quicksilver
      IniWrite, %YesUtility7Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7Quicksilver
      IniWrite, %YesUtility8Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8Quicksilver
      IniWrite, %YesUtility9Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9Quicksilver
      IniWrite, %YesUtility10Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10Quicksilver
      IniWrite, %YesUtility1InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1InverseBuff
      IniWrite, %YesUtility2InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2InverseBuff
      IniWrite, %YesUtility3InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3InverseBuff
      IniWrite, %YesUtility4InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4InverseBuff
      IniWrite, %YesUtility5InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5InverseBuff
      IniWrite, %YesUtility6InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6InverseBuff
      IniWrite, %YesUtility7InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7InverseBuff
      IniWrite, %YesUtility8InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8InverseBuff
      IniWrite, %YesUtility9InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9InverseBuff
      IniWrite, %YesUtility10InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10InverseBuff
      IniWrite, %YesUtility1MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1MainAttack
      IniWrite, %YesUtility2MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2MainAttack
      IniWrite, %YesUtility3MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3MainAttack
      IniWrite, %YesUtility4MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4MainAttack
      IniWrite, %YesUtility5MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5MainAttack
      IniWrite, %YesUtility6MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6MainAttack
      IniWrite, %YesUtility7MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7MainAttack
      IniWrite, %YesUtility8MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8MainAttack
      IniWrite, %YesUtility9MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9MainAttack
      IniWrite, %YesUtility10MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10MainAttack
      IniWrite, %YesUtility1SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1SecondaryAttack
      IniWrite, %YesUtility2SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2SecondaryAttack
      IniWrite, %YesUtility3SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3SecondaryAttack
      IniWrite, %YesUtility4SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4SecondaryAttack
      IniWrite, %YesUtility5SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5SecondaryAttack
      IniWrite, %YesUtility6SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6SecondaryAttack
      IniWrite, %YesUtility7SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7SecondaryAttack
      IniWrite, %YesUtility8SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8SecondaryAttack
      IniWrite, %YesUtility9SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9SecondaryAttack
      IniWrite, %YesUtility10SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10SecondaryAttack
      
      ;Utility Percents  
      IniWrite, %YesUtility1LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1LifePercent
      IniWrite, %YesUtility2LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2LifePercent
      IniWrite, %YesUtility3LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3LifePercent
      IniWrite, %YesUtility4LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4LifePercent
      IniWrite, %YesUtility5LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5LifePercent
      IniWrite, %YesUtility6LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6LifePercent
      IniWrite, %YesUtility7LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7LifePercent
      IniWrite, %YesUtility8LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8LifePercent
      IniWrite, %YesUtility9LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9LifePercent
      IniWrite, %YesUtility10LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10LifePercent
      IniWrite, %YesUtility1EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1EsPercent
      IniWrite, %YesUtility2EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2EsPercent
      IniWrite, %YesUtility3EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3EsPercent
      IniWrite, %YesUtility4EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4EsPercent
      IniWrite, %YesUtility5EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5EsPercent
      IniWrite, %YesUtility6EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6EsPercent
      IniWrite, %YesUtility7EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7EsPercent
      IniWrite, %YesUtility8EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8EsPercent
      IniWrite, %YesUtility9EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9EsPercent
      IniWrite, %YesUtility10EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10EsPercent
      IniWrite, %YesUtility1ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1ManaPercent
      IniWrite, %YesUtility2ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2ManaPercent
      IniWrite, %YesUtility3ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3ManaPercent
      IniWrite, %YesUtility4ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4ManaPercent
      IniWrite, %YesUtility5ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5ManaPercent
      IniWrite, %YesUtility6ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6ManaPercent
      IniWrite, %YesUtility7ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7ManaPercent
      IniWrite, %YesUtility8ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8ManaPercent
      IniWrite, %YesUtility9ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9ManaPercent
      IniWrite, %YesUtility10ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10ManaPercent
      
      ;Utility Cooldowns
      IniWrite, %CooldownUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility1
      IniWrite, %CooldownUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility2
      IniWrite, %CooldownUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility3
      IniWrite, %CooldownUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility4
      IniWrite, %CooldownUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility5
      IniWrite, %CooldownUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility6
      IniWrite, %CooldownUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility7
      IniWrite, %CooldownUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility8
      IniWrite, %CooldownUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility9
      IniWrite, %CooldownUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility10
      
      ;StackRelease
      IniWrite, %StackRelease_Keybind%, %A_ScriptDir%\save\Settings.ini,  StackRelease, StackRelease_Keybind
      IniWrite, %StackRelease_X1Offset%, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_X1Offset
      IniWrite, %StackRelease_Y1Offset%, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Y1Offset
      IniWrite, %StackRelease_X2Offset%, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_X2Offset
      IniWrite, %StackRelease_Y2Offset%, %A_ScriptDir%\save\Settings.ini, StackRelease, StackRelease_Y2Offset
      
      ;Utility Keys
      IniWrite, %KeyUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility1
      IniWrite, %KeyUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility2
      IniWrite, %KeyUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility3
      IniWrite, %KeyUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility4
      IniWrite, %KeyUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility5
      IniWrite, %KeyUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility6
      IniWrite, %KeyUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility7
      IniWrite, %KeyUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility8
      IniWrite, %KeyUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility9
      IniWrite, %KeyUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility10
      
      ;Utility Icon Strings
      IniWrite, %IconStringUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility1
      IniWrite, %IconStringUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility2
      IniWrite, %IconStringUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility3
      IniWrite, %IconStringUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility4
      IniWrite, %IconStringUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility5
      IniWrite, %IconStringUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility6
      IniWrite, %IconStringUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility7
      IniWrite, %IconStringUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility8
      IniWrite, %IconStringUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility9
      IniWrite, %IconStringUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility10
      
      ;Flask Cooldowns
      IniWrite, %CooldownFlask1%, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask1
      IniWrite, %CooldownFlask2%, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask2
      IniWrite, %CooldownFlask3%, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask3
      IniWrite, %CooldownFlask4%, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask4
      IniWrite, %CooldownFlask5%, %A_ScriptDir%\save\Settings.ini, Flask Cooldowns, CooldownFlask5  

      ;Flask Keys
      IniWrite, %keyFlask1%, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask1
      IniWrite, %keyFlask2%, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask2
      IniWrite, %keyFlask3%, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask3
      IniWrite, %keyFlask4%, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask4
      IniWrite, %keyFlask5%, %A_ScriptDir%\save\Settings.ini, Flask Keys, keyFlask5  
      
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
      IniWrite, %ElementalReflect%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, ElementalReflect
      IniWrite, %PhysicalReflect%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, PhysicalReflect
      IniWrite, %NoRegen%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoRegen
      IniWrite, %NoLeech%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, NoLeech
      IniWrite, %AvoidAilments%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidAilments
      IniWrite, %AvoidPBB%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, AvoidPBB
      IniWrite, %MinusMPR%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MinusMPR
      IniWrite, %MMapItemQuantity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemQuantity
      IniWrite, %MMapItemRarity%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapItemRarity
      IniWrite, %MMapMonsterPackSize%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, MMapMonsterPackSize
      IniWrite, %EnableMQQForMagicMap%, %A_ScriptDir%\save\Settings.ini, Crafting Map Settings, EnableMQQForMagicMap
      
      ;Gem Swap
      IniWrite, %CurrentGemX%, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGemX
      IniWrite, %CurrentGemY%, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGemY
      IniWrite, %AlternateGemX%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemX
      IniWrite, %AlternateGemY%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemY
      IniWrite, %AlternateGemOnSecondarySlot%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGemOnSecondarySlot
      IniWrite, %GemItemToogle%, %A_ScriptDir%\save\Settings.ini, Gem Swap, GemItemToogle

      IniWrite, %CurrentGem2X%, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGem2X
      IniWrite, %CurrentGem2Y%, %A_ScriptDir%\save\Settings.ini, Gem Swap, CurrentGem2Y
      IniWrite, %AlternateGem2X%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2X
      IniWrite, %AlternateGem2Y%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2Y
      IniWrite, %AlternateGem2OnSecondarySlot%, %A_ScriptDir%\save\Settings.ini, Gem Swap, AlternateGem2OnSecondarySlot
      IniWrite, %GemItemToogle2%, %A_ScriptDir%\save\Settings.ini, Gem Swap, GemItemToogle2
      
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
      IniWrite, %StashTabOil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabOil
      IniWrite, %StashTabBlightedMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlightedMap
      IniWrite, %StashTabDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium
      IniWrite, %StashTabYesOrgan%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOrgan
      IniWrite, %StashTabFossil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFossil
      IniWrite, %StashTabResonator%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabResonator
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
      IniWrite, %StashTabYesBlightedMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlightedMap
      IniWrite, %StashTabYesDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium
      IniWrite, %StashTabYesFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment
      IniWrite, %StashTabYesEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence
      IniWrite, %StashTabYesOil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOil
      IniWrite, %StashTabYesFossil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFossil
      IniWrite, %StashTabYesResonator%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesResonator
      IniWrite, %StashTabYesCrafting%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCrafting
      IniWrite, %StashTabYesProphecy%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesProphecy
      IniWrite, %StashTabYesVeiled%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesVeiled
      IniWrite, %StashTabYesDump%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDump
      IniWrite, %StashDumpInTrial%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashDumpInTrial
      IniWrite, %StashTabPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabPredictive
      IniWrite, %StashTabYesPredictive%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive
      IniWrite, %StashTabYesPredictive_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesPredictive_Price
      IniWrite, %StashTabCatalyst%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCatalyst
      IniWrite, %StashTabYesCatalyst%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCatalyst
      IniWrite, %StashTabGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabGemVaal
      IniWrite, %StashTabYesGemVaal%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesGemVaal
      IniWrite, %StashTabNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabNinjaPrice
      IniWrite, %StashTabYesNinjaPrice%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice
      IniWrite, %StashTabYesNinjaPrice_Price%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesNinjaPrice_Price

      ;Attack Flasks
      IniWrite, %MainAttackbox1%%MainAttackbox2%%MainAttackbox3%%MainAttackbox4%%MainAttackbox5%, %A_ScriptDir%\save\Settings.ini, Attack Triggers, TriggerMainAttack
      IniWrite, %SecondaryAttackbox1%%SecondaryAttackbox2%%SecondaryAttackbox3%%SecondaryAttackbox4%%SecondaryAttackbox5%, %A_ScriptDir%\save\Settings.ini, Attack Triggers, TriggerSecondaryAttack
      
      ;Quicksilver Flasks
      IniWrite, %TriggerQuicksilverDelay%, %A_ScriptDir%\save\Settings.ini, Quicksilver, TriggerQuicksilverDelay
      IniWrite, %Radiobox1QS%%Radiobox2QS%%Radiobox3QS%%Radiobox4QS%%Radiobox5QS%, %A_ScriptDir%\save\Settings.ini, Quicksilver, TriggerQuicksilver
      
      ;Pop Flasks
      IniWrite, %PopFlasks1%%PopFlasks2%%PopFlasks3%%PopFlasks4%%PopFlasks5%, %A_ScriptDir%\save\Settings.ini, PopFlasks, TriggerPopFlasks
      
      ;CharacterTypeCheck
      IniWrite, %RadioLife%, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Life
      IniWrite, %RadioHybrid%, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Hybrid  
      IniWrite, %RadioCi%, %A_ScriptDir%\save\Settings.ini, CharacterTypeCheck, Ci  
      
      ;AutoQuit
      IniWrite, %QuitBelow%, %A_ScriptDir%\save\Settings.ini, AutoQuit, QuitBelow
      IniWrite, %RadioCritQuit%, %A_ScriptDir%\save\Settings.ini, AutoQuit, CritQuit
      IniWrite, %RadioPortalQuit%, %A_ScriptDir%\save\Settings.ini, AutoQuit, PortalQuit
      IniWrite, %RadioNormalQuit%, %A_ScriptDir%\save\Settings.ini, AutoQuit, NormalQuit

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
      If (YesPersistantToggle)
        AutoReset()
      GuiUpdate()
      IfWinExist, ahk_group POEGameGroup
        {
        WinActivate, ahk_group POEGameGroup
        }
      ; SendMSG(1)
      Thread, NoTimers, False    ;End Critical
    return  
    }

    loadSaved:
      readFromFile()
      ;Update UI
      if(RadioLife==1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Disable, Radiobox%A_Index%ES90
          GuiControl, Disable, Radiobox%A_Index%ES80
          GuiControl, Disable, Radiobox%A_Index%ES70
          GuiControl, Disable, Radiobox%A_Index%ES60
          GuiControl, Disable, Radiobox%A_Index%ES50
          GuiControl, Disable, Radiobox%A_Index%ES40
          GuiControl, Disable, Radiobox%A_Index%ES30
          GuiControl, Disable, Radiobox%A_Index%ES20
          GuiControl, Disable, RadioUncheck%A_Index%ES
        }
      }
      else if(RadioHybrid==1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
      else if(RadioCi==1) {
        loop 5 {
          GuiControl, Disable, Radiobox%A_Index%Life90
            GuiControl, Disable, Radiobox%A_Index%Life80
            GuiControl, Disable, Radiobox%A_Index%Life70
            GuiControl, Disable, Radiobox%A_Index%Life60
            GuiControl, Disable, Radiobox%A_Index%Life50
            GuiControl, Disable, Radiobox%A_Index%Life40
            GuiControl, Disable, Radiobox%A_Index%Life30
            GuiControl, Disable, Radiobox%A_Index%Life20
            GuiControl, Disable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
      GuiControl,, QuitBelow, %QuitBelow%
      GuiControl,, CooldownFlask1, %CooldownFlask1%
      GuiControl,, CooldownFlask2, %CooldownFlask2%
      GuiControl,, CooldownFlask3, %CooldownFlask3%
      GuiControl,, CooldownFlask4, %CooldownFlask4%
      GuiControl,, CooldownFlask5, %CooldownFlask5%
      GuiControl,, keyFlask1, %keyFlask1%
      GuiControl,, keyFlask2, %keyFlask2%
      GuiControl,, keyFlask3, %keyFlask3%
      GuiControl,, keyFlask4, %keyFlask4%
      GuiControl,, keyFlask5, %keyFlask5%
      GuiControl,, RadioNormalQuit, %RadioNormalQuit%
      GuiControl,, RadioCritQuit, %RadioCritQuit%
      GuiControl,, RadioPortalQuit, %RadioPortalQuit%
      GuiControl,, RadioLife, %RadioLife%
      GuiControl,, RadioHybrid, %RadioHybrid%
      GuiControl,, RadioCi, %RadioCi%
      GuiControl,, hotkeyMainAttack, %hotkeyMainAttack%
      GuiControl,, hotkeySecondaryAttack, %hotkeySecondaryAttack%
      GuiControl,, TriggerQuicksilverDelay, %TriggerQuicksilverDelay%
      GuiControl,, hotkeyOptions, %hotkeyOptions%
      GuiControl,, hotkeyAutoFlask, %hotkeyAutoFlask%
      GuiControl,, hotkeyAutoQuit, %hotkeyAutoQuit%
      GuiControl,, hotkeyLogout, %hotkeyLogout%
      GuiControl,, hotkeyAutoQuicksilver, %hotkeyAutoQuicksilver%
      GuiControl,, hotkeyGetMouseCoords, %hotkeyGetMouseCoords%
      GuiControl,, hotkeyQuickPortal, %hotkeyQuickPortal%
      GuiControl,, hotkeyGemSwap, %hotkeyGemSwap%
      GuiControl,, hotkeyStartCraft, %hotkeyStartCraft%
      GuiControl,, hotkeyGrabCurrency, %hotkeyGrabCurrency%
      GuiControl,, hotkeyPopFlasks, %hotkeyPopFlasks%
      GuiControl,, hotkeyItemSort, %hotkeyItemSort%
      GuiControl,, hotkeyItemInfo, %hotkeyItemInfo%
      GuiControl,, hotkeyChaosRecipe, %hotkeyChaosRecipe%
      GuiControl,, hotkeyCloseAllUI, %hotkeyCloseAllUI%
      GuiControl,, hotkeyInventory, %hotkeyInventory%
      GuiControl,, hotkeyWeaponSwapKey, %hotkeyWeaponSwapKey%
      GuiControl,, hotkeyLootScan, %hotkeyLootScan%
      GuiControl,, hotkeyDetonateMines, %hotkeyDetonateMines%
      GuiControl,, hotkeyPauseMines, %hotkeyPauseMines%
      GuiControl,, PortalScrollX, %PortalScrollX%
      GuiControl,, PortalScrollY, %PortalScrollY%
      GuiControl,, WisdomScrollX, %WisdomScrollX%
      GuiControl,, WisdomScrollY, %WisdomScrollY%
      GuiControl,, GrabCurrencyPosX, %GrabCurrencyPosX%
      GuiControl,, GrabCurrencyPosY, %GrabCurrencyPosY%
      GuiControl,, CurrentGemX, %CurrentGemX%
      GuiControl,, CurrentGemY, %CurrentGemY%
      GuiControl,, AlternateGemX, %AlternateGemX%
      GuiControl,, AlternateGemY, %AlternateGemY%
      GuiControl,, CurrentGem2X, %CurrentGem2X%
      GuiControl,, CurrentGem2Y, %CurrentGem2Y%
      GuiControl,, AlternateGem2X, %AlternateGem2X%
      GuiControl,, AlternateGem2Y, %AlternateGem2Y%
      
      ; SendMSG(1,1)
    return
  }

  { ; Hotkeys with modifiers - RegisterHotkeys, 1HotkeyShouldFire, 2HotkeyShouldFire, stashHotkeyShouldFire

    ; RegisterHotkeys - Register Chat and Stash Hotkeys
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RegisterHotkeys() {
      global
      Hotkey If, % fn1
        If 1Suffix1 != A_Space
          Hotkey, *%1Suffix1%, 1FireWhisperHotkey1, off
        If 1Suffix2 != A_Space
          Hotkey, *%1Suffix2%, 1FireWhisperHotkey2, off
        If 1Suffix3 != A_Space
          Hotkey, *%1Suffix3%, 1FireWhisperHotkey3, off
        If 1Suffix4 != A_Space
          Hotkey, *%1Suffix4%, 1FireWhisperHotkey4, off
        If 1Suffix5 != A_Space
          Hotkey, *%1Suffix5%, 1FireWhisperHotkey5, off
        If 1Suffix6 != A_Space
          Hotkey, *%1Suffix6%, 1FireWhisperHotkey6, off
        If 1Suffix7 != A_Space
          Hotkey, *%1Suffix7%, 1FireWhisperHotkey7, off
        If 1Suffix8 != A_Space
          Hotkey, *%1Suffix8%, 1FireWhisperHotkey8, off
        If 1Suffix9 != A_Space
          Hotkey, *%1Suffix9%, 1FireWhisperHotkey9, off

      Hotkey If, % fn2
        If 2Suffix1 != A_Space
          Hotkey, *%2Suffix1%, 2FireWhisperHotkey1, off
        If 2Suffix2 != A_Space
          Hotkey, *%2Suffix2%, 2FireWhisperHotkey2, off
        If 2Suffix3 != A_Space
          Hotkey, *%2Suffix3%, 2FireWhisperHotkey3, off
        If 2Suffix4 != A_Space
          Hotkey, *%2Suffix4%, 2FireWhisperHotkey4, off
        If 2Suffix5 != A_Space
          Hotkey, *%2Suffix5%, 2FireWhisperHotkey5, off
        If 2Suffix6 != A_Space
          Hotkey, *%2Suffix6%, 2FireWhisperHotkey6, off
        If 2Suffix7 != A_Space
          Hotkey, *%2Suffix7%, 2FireWhisperHotkey7, off
        If 2Suffix8 != A_Space
          Hotkey, *%2Suffix8%, 2FireWhisperHotkey8, off
        If 2Suffix9 != A_Space
          Hotkey, *%2Suffix9%, 2FireWhisperHotkey9, off

      Hotkey If, % fn3
        If stashSuffix1 != A_Space
          Hotkey, *%stashSuffix1%, FireStashHotkey1, off
        If stashSuffix2 != A_Space
          Hotkey, *%stashSuffix2%, FireStashHotkey2, off
        If stashSuffix3 != A_Space
          Hotkey, *%stashSuffix3%, FireStashHotkey3, off
        If stashSuffix4 != A_Space
          Hotkey, *%stashSuffix4%, FireStashHotkey4, off
        If stashSuffix5 != A_Space
          Hotkey, *%stashSuffix5%, FireStashHotkey5, off
        If stashSuffix6 != A_Space
          Hotkey, *%stashSuffix6%, FireStashHotkey6, off
        If stashSuffix7 != A_Space
          Hotkey, *%stashSuffix7%, FireStashHotkey7, off
        If stashSuffix8 != A_Space
          Hotkey, *%stashSuffix8%, FireStashHotkey8, off
        If stashSuffix9 != A_Space
          Hotkey, *%stashSuffix9%, FireStashHotkey9, off
        If stashReset != A_Space
          Hotkey, *%stashReset%, FireStashReset, off

      Gui Submit, NoHide
      fn1 := Func("1HotkeyShouldFire").Bind(1Prefix1,1Prefix2,EnableChatHotkeys)
      Hotkey If, % fn1
      Loop, 9 {
        If (1Suffix%A_Index% != A_Space)
        {
          keyval := 1Suffix%A_Index%
          Hotkey, *%keyval%, 1FireWhisperHotkey%A_Index%, On
        }
      }
      fn2 := Func("2HotkeyShouldFire").Bind(2Prefix1,2Prefix2,EnableChatHotkeys)
      Hotkey If, % fn2
      Loop, 9 {
        If (2Suffix%A_Index% != A_Space)
        {
          keyval := 2Suffix%A_Index%
          Hotkey, *%keyval%, 2FireWhisperHotkey%A_Index%, On
        }
      }
      fn3 := Func("stashHotkeyShouldFire").Bind(stashPrefix1,stashPrefix2,YesStashKeys)
      Hotkey If, % fn3
      Loop, 9 {
        If (stashSuffix%A_Index% != A_Space)
        {
          keyval := stashSuffix%A_Index%
          Hotkey, ~*%keyval%, FireStashHotkey%A_Index%, On
        }
      }
      If (stashReset != A_Space)
        Hotkey, ~*%stashReset%, FireStashReset, On
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
    1FireWhisperHotkey1() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix1Text := StrReplace(1Suffix1Text, "CharacterName", CharName, 0, -1)
        str1Suffix1Text := StrReplace(str1Suffix1Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix1Text := StrReplace(str1Suffix1Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix1Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey2() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix2Text := StrReplace(1Suffix2Text, "CharacterName", CharName, 0, -1)
        str1Suffix2Text := StrReplace(str1Suffix2Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix2Text := StrReplace(str1Suffix2Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix2Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey3() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix3Text := StrReplace(1Suffix3Text, "CharacterName", CharName, 0, -1)
        str1Suffix3Text := StrReplace(str1Suffix3Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix3Text := StrReplace(str1Suffix3Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix3Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey4() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix4Text := StrReplace(1Suffix4Text, "CharacterName", CharName, 0, -1)
        str1Suffix4Text := StrReplace(str1Suffix4Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix4Text := StrReplace(str1Suffix4Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix4Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey5() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix5Text := StrReplace(1Suffix5Text, "CharacterName", CharName, 0, -1)
        str1Suffix5Text := StrReplace(str1Suffix5Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix5Text := StrReplace(str1Suffix5Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix5Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey6() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix6Text := StrReplace(1Suffix6Text, "CharacterName", CharName, 0, -1)
        str1Suffix6Text := StrReplace(str1Suffix6Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix6Text := StrReplace(str1Suffix6Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix6Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey7() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix7Text := StrReplace(1Suffix7Text, "CharacterName", CharName, 0, -1)
        str1Suffix7Text := StrReplace(str1Suffix7Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix7Text := StrReplace(str1Suffix7Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix7Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey8() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix8Text := StrReplace(1Suffix8Text, "CharacterName", CharName, 0, -1)
        str1Suffix8Text := StrReplace(str1Suffix8Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix8Text := StrReplace(str1Suffix8Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix8Text%{Enter}
        ResetChat()
      }
    return
    }
    1FireWhisperHotkey9() {
      IfWinActive, ahk_group POEGameGroup
      {  
        str1Suffix9Text := StrReplace(1Suffix9Text, "CharacterName", CharName, 0, -1)
        str1Suffix9Text := StrReplace(str1Suffix9Text, "RecipientName", RecipientName, 0, -1)
        str1Suffix9Text := StrReplace(str1Suffix9Text, "!", "{!}", 0, -1)
        Send, {Enter}%str1Suffix9Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey1() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix1Text := StrReplace(2Suffix1Text, "CharacterName", CharName, 0, -1)
        str2Suffix1Text := StrReplace(str2Suffix1Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix1Text := StrReplace(str2Suffix1Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix1Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey2() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix2Text := StrReplace(2Suffix2Text, "CharacterName", CharName, 0, -1)
        str2Suffix2Text := StrReplace(str2Suffix2Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix2Text := StrReplace(str2Suffix2Text, "!", "{!}", 0, -1)

        Send, ^{Enter}%str2Suffix2Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey3() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix3Text := StrReplace(2Suffix3Text, "CharacterName", CharName, 0, -1)
        str2Suffix3Text := StrReplace(str2Suffix3Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix3Text := StrReplace(str2Suffix3Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix3Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey4() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix4Text := StrReplace(2Suffix4Text, "CharacterName", CharName, 0, -1)
        str2Suffix4Text := StrReplace(str2Suffix4Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix4Text := StrReplace(str2Suffix4Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix4Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey5() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix5Text := StrReplace(2Suffix5Text, "CharacterName", CharName, 0, -1)
        str2Suffix5Text := StrReplace(str2Suffix5Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix5Text := StrReplace(str2Suffix5Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix5Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey6() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix6Text := StrReplace(2Suffix6Text, "CharacterName", CharName, 0, -1)
        str2Suffix6Text := StrReplace(str2Suffix6Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix6Text := StrReplace(str2Suffix6Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix6Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey7() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix7Text := StrReplace(2Suffix7Text, "CharacterName", CharName, 0, -1)
        str2Suffix7Text := StrReplace(str2Suffix7Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix7Text := StrReplace(str2Suffix7Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix7Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey8() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix8Text := StrReplace(2Suffix8Text, "CharacterName", CharName, 0, -1)
        str2Suffix8Text := StrReplace(str2Suffix8Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix8Text := StrReplace(str2Suffix8Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix8Text%{Enter}
        ResetChat()
      }
    return
    }
    2FireWhisperHotkey9() {
      IfWinActive, ahk_group POEGameGroup
      {  
        GrabRecipientName()
        str2Suffix9Text := StrReplace(2Suffix9Text, "CharacterName", CharName, 0, -1)
        str2Suffix9Text := StrReplace(str2Suffix9Text, "RecipientName", RecipientName, 0, -1)
        str2Suffix9Text := StrReplace(str2Suffix9Text, "!", "{!}", 0, -1)
        Send, ^{Enter}%str2Suffix9Text%{Enter}
        ResetChat()
      }
    return
    }
    FireStashHotkey1() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab1,1)
      }
    return
    }
    FireStashHotkey2() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab2,1)
      }
    return
    }
    FireStashHotkey3() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab3,1)
      }
    return
    }
    FireStashHotkey4() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab4,1)
      }
    return
    }
    FireStashHotkey5() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab5,1)
      }
    return
    }
    FireStashHotkey6() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab6,1)
      }
    return
    }
    FireStashHotkey7() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab7,1)
      }
    return
    }
    FireStashHotkey8() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab8,1)
      }
    return
    }
    FireStashHotkey9() {
      IfWinActive, ahk_group POEGameGroup
      {  
        MoveStash(stashSuffixTab9,1)
      }
    return
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
      
      ;Life Flasks
      
      IniWrite, %Radiobox1Life20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life20
      IniWrite, %Radiobox2Life20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life20
      IniWrite, %Radiobox3Life20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life20
      IniWrite, %Radiobox4Life20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life20
      IniWrite, %Radiobox5Life20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life20

      IniWrite, %Radiobox1Life30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life30
      IniWrite, %Radiobox2Life30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life30
      IniWrite, %Radiobox3Life30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life30
      IniWrite, %Radiobox4Life30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life30
      IniWrite, %Radiobox5Life30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life30

      IniWrite, %Radiobox1Life40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life40
      IniWrite, %Radiobox2Life40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life40
      IniWrite, %Radiobox3Life40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life40
      IniWrite, %Radiobox4Life40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life40
      IniWrite, %Radiobox5Life40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life40

      IniWrite, %Radiobox1Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life50
      IniWrite, %Radiobox2Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life50
      IniWrite, %Radiobox3Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life50
      IniWrite, %Radiobox4Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life50
      IniWrite, %Radiobox5Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life50

      IniWrite, %Radiobox1Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life50
      IniWrite, %Radiobox2Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life50
      IniWrite, %Radiobox3Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life50
      IniWrite, %Radiobox4Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life50
      IniWrite, %Radiobox5Life50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life50

      IniWrite, %Radiobox1Life60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life60
      IniWrite, %Radiobox2Life60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life60
      IniWrite, %Radiobox3Life60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life60
      IniWrite, %Radiobox4Life60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life60
      IniWrite, %Radiobox5Life60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life60

      IniWrite, %Radiobox1Life70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life70
      IniWrite, %Radiobox2Life70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life70
      IniWrite, %Radiobox3Life70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life70
      IniWrite, %Radiobox4Life70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life70
      IniWrite, %Radiobox5Life70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life70

      IniWrite, %Radiobox1Life80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life80
      IniWrite, %Radiobox2Life80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life80
      IniWrite, %Radiobox3Life80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life80
      IniWrite, %Radiobox4Life80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life80
      IniWrite, %Radiobox5Life80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life80

      IniWrite, %Radiobox1Life90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life90
      IniWrite, %Radiobox2Life90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life90
      IniWrite, %Radiobox3Life90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life90
      IniWrite, %Radiobox4Life90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life90
      IniWrite, %Radiobox5Life90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life90

      IniWrite, %RadioUncheck1Life%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck1Life
      IniWrite, %RadioUncheck2Life%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck2Life
      IniWrite, %RadioUncheck3Life%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck3Life
      IniWrite, %RadioUncheck4Life%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck4Life
      IniWrite, %RadioUncheck5Life%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck5Life
      
      ;ES Flasks
      IniWrite, %Radiobox1ES20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES20
      IniWrite, %Radiobox2ES20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES20
      IniWrite, %Radiobox3ES20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES20
      IniWrite, %Radiobox4ES20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES20
      IniWrite, %Radiobox5ES20%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES20
      
      IniWrite, %Radiobox1ES30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES30
      IniWrite, %Radiobox2ES30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES30
      IniWrite, %Radiobox3ES30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES30
      IniWrite, %Radiobox4ES30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES30
      IniWrite, %Radiobox5ES30%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES30
      
      IniWrite, %Radiobox1ES40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES40
      IniWrite, %Radiobox2ES40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES40
      IniWrite, %Radiobox3ES40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES40
      IniWrite, %Radiobox4ES40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES40
      IniWrite, %Radiobox5ES40%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES40
      
      IniWrite, %Radiobox1ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES50
      IniWrite, %Radiobox2ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES50
      IniWrite, %Radiobox3ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES50
      IniWrite, %Radiobox4ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES50
      IniWrite, %Radiobox5ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES50
      
      IniWrite, %Radiobox1ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES50
      IniWrite, %Radiobox2ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES50
      IniWrite, %Radiobox3ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES50
      IniWrite, %Radiobox4ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES50
      IniWrite, %Radiobox5ES50%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES50
      
      IniWrite, %Radiobox1ES60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES60
      IniWrite, %Radiobox2ES60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES60
      IniWrite, %Radiobox3ES60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES60
      IniWrite, %Radiobox4ES60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES60
      IniWrite, %Radiobox5ES60%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES60
      
      IniWrite, %Radiobox1ES70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES70
      IniWrite, %Radiobox2ES70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES70
      IniWrite, %Radiobox3ES70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES70
      IniWrite, %Radiobox4ES70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES70
      IniWrite, %Radiobox5ES70%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES70
      
      IniWrite, %Radiobox1ES80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES80
      IniWrite, %Radiobox2ES80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES80
      IniWrite, %Radiobox3ES80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES80
      IniWrite, %Radiobox4ES80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES80
      IniWrite, %Radiobox5ES80%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES80
      
      IniWrite, %Radiobox1ES90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES90
      IniWrite, %Radiobox2ES90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES90
      IniWrite, %Radiobox3ES90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES90
      IniWrite, %Radiobox4ES90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES90
      IniWrite, %Radiobox5ES90%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES90
      
      IniWrite, %RadioUncheck1ES%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck1ES
      IniWrite, %RadioUncheck2ES%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck2ES
      IniWrite, %RadioUncheck3ES%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck3ES
      IniWrite, %RadioUncheck4ES%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck4ES
      IniWrite, %RadioUncheck5ES%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck5ES
      
      ;Mana Flasks
      IniWrite, %Radiobox1Mana10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Mana10
      IniWrite, %Radiobox2Mana10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Mana10
      IniWrite, %Radiobox3Mana10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Mana10
      IniWrite, %Radiobox4Mana10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Mana10
      IniWrite, %Radiobox5Mana10%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Mana10
      
      ;Flask Cooldowns
      IniWrite, %CooldownFlask1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask1
      IniWrite, %CooldownFlask2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask2
      IniWrite, %CooldownFlask3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask3
      IniWrite, %CooldownFlask4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask4
      IniWrite, %CooldownFlask5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask5  
      
      ;Attack Flasks
      IniWrite, %MainAttackbox1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox1
      IniWrite, %MainAttackbox2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox2
      IniWrite, %MainAttackbox3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox3
      IniWrite, %MainAttackbox4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox4
      IniWrite, %MainAttackbox5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox5
      
      IniWrite, %SecondaryAttackbox1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox1
      IniWrite, %SecondaryAttackbox2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox2
      IniWrite, %SecondaryAttackbox3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox3
      IniWrite, %SecondaryAttackbox4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox4
      IniWrite, %SecondaryAttackbox5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox5
      
      ;Attack Keys
      IniWrite, %hotkeyMainAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttack
      IniWrite, %hotkeySecondaryAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttack
      
      ;QS on Attack Keys
      IniWrite, %QSonMainAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonMainAttack
      IniWrite, %QSonSecondaryAttack%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QSonSecondaryAttack
      
      ;Quicksilver Flasks
      IniWrite, %TriggerQuicksilverDelay%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, TriggerQuicksilverDelay
      IniWrite, %Radiobox1QS%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot1
      IniWrite, %Radiobox2QS%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot2
      IniWrite, %Radiobox3QS%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot3
      IniWrite, %Radiobox4QS%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot4
      IniWrite, %Radiobox5QS%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot5
      
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

      ;ManaThreshold
      IniWrite, %ManaThreshold%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, ManaThreshold

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

      ;Pop Flasks Keys
      IniWrite, %PopFlasks1%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks1
      IniWrite, %PopFlasks2%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks2
      IniWrite, %PopFlasks3%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks3
      IniWrite, %PopFlasks4%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks4
      IniWrite, %PopFlasks5%, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks5
      
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
      ;Life Flasks
      IniRead, Radiobox1Life20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life20, 0
      GuiControl, , Radiobox1Life20, %Radiobox1Life20%
      IniRead, Radiobox2Life20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life20, 0
      GuiControl, , Radiobox2Life20, %Radiobox2Life20%
      IniRead, Radiobox3Life20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life20, 0
      GuiControl, , Radiobox3Life20, %Radiobox3Life20%
      IniRead, Radiobox4Life20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life20, 0
      GuiControl, , Radiobox4Life20, %Radiobox4Life20%
      IniRead, Radiobox5Life20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life20, 0
      GuiControl, , Radiobox5Life20, %Radiobox5Life20%

      IniRead, Radiobox1Life30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life30, 0
      GuiControl, , Radiobox1Life30, %Radiobox1Life30%
      IniRead, Radiobox2Life30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life30, 0
      GuiControl, , Radiobox2Life30, %Radiobox2Life30%
      IniRead, Radiobox3Life30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life30, 0
      GuiControl, , Radiobox3Life30, %Radiobox3Life30%
      IniRead, Radiobox4Life30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life30, 0
      GuiControl, , Radiobox4Life30, %Radiobox4Life30%
      IniRead, Radiobox5Life30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life30, 0
      GuiControl, , Radiobox5Life30, %Radiobox5Life30%

      IniRead, Radiobox1Life40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life40, 0
      GuiControl, , Radiobox1Life40, %Radiobox1Life40%
      IniRead, Radiobox2Life40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life40, 0
      GuiControl, , Radiobox2Life40, %Radiobox2Life40%
      IniRead, Radiobox3Life40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life40, 0
      GuiControl, , Radiobox3Life40, %Radiobox3Life40%
      IniRead, Radiobox4Life40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life40, 0
      GuiControl, , Radiobox4Life40, %Radiobox4Life40%
      IniRead, Radiobox5Life40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life40, 0
      GuiControl, , Radiobox5Life40, %Radiobox5Life40%

      IniRead, Radiobox1Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life50, 0
      GuiControl, , Radiobox1Life50, %Radiobox1Life50%
      IniRead, Radiobox2Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life50, 0
      GuiControl, , Radiobox2Life50, %Radiobox2Life50%
      IniRead, Radiobox3Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life50, 0
      GuiControl, , Radiobox3Life50, %Radiobox3Life50%
      IniRead, Radiobox4Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life50, 0
      GuiControl, , Radiobox4Life50, %Radiobox4Life50%
      IniRead, Radiobox5Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life50, 0
      GuiControl, , Radiobox5Life50, %Radiobox5Life50%

      IniRead, Radiobox1Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life50, 0
      GuiControl, , Radiobox1Life50, %Radiobox1Life50%
      IniRead, Radiobox2Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life50, 0
      GuiControl, , Radiobox2Life50, %Radiobox2Life50%
      IniRead, Radiobox3Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life50, 0
      GuiControl, , Radiobox3Life50, %Radiobox3Life50%
      IniRead, Radiobox4Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life50, 0
      GuiControl, , Radiobox4Life50, %Radiobox4Life50%
      IniRead, Radiobox5Life50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life50, 0
      GuiControl, , Radiobox5Life50, %Radiobox5Life50%

      IniRead, Radiobox1Life60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life60, 0
      GuiControl, , Radiobox1Life60, %Radiobox1Life60%
      IniRead, Radiobox2Life60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life60, 0
      GuiControl, , Radiobox2Life60, %Radiobox2Life60%
      IniRead, Radiobox3Life60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life60, 0
      GuiControl, , Radiobox3Life60, %Radiobox3Life60%
      IniRead, Radiobox4Life60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life60, 0
      GuiControl, , Radiobox4Life60, %Radiobox4Life60%
      IniRead, Radiobox5Life60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life60, 0
      GuiControl, , Radiobox5Life60, %Radiobox5Life60%

      IniRead, Radiobox1Life70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life70, 0
      GuiControl, , Radiobox1Life70, %Radiobox1Life70%
      IniRead, Radiobox2Life70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life70, 0
      GuiControl, , Radiobox2Life70, %Radiobox2Life70%
      IniRead, Radiobox3Life70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life70, 0
      GuiControl, , Radiobox3Life70, %Radiobox3Life70%
      IniRead, Radiobox4Life70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life70, 0
      GuiControl, , Radiobox4Life70, %Radiobox4Life70%
      IniRead, Radiobox5Life70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life70, 0
      GuiControl, , Radiobox5Life70, %Radiobox5Life70%

      IniRead, Radiobox1Life80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life80, 0
      GuiControl, , Radiobox1Life80, %Radiobox1Life80%
      IniRead, Radiobox2Life80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life80, 0
      GuiControl, , Radiobox2Life80, %Radiobox2Life80%
      IniRead, Radiobox3Life80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life80, 0
      GuiControl, , Radiobox3Life80, %Radiobox3Life80%
      IniRead, Radiobox4Life80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life80, 0
      GuiControl, , Radiobox4Life80, %Radiobox4Life80%
      IniRead, Radiobox5Life80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life80, 0
      GuiControl, , Radiobox5Life80, %Radiobox5Life80%

      IniRead, Radiobox1Life90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Life90, 0
      GuiControl, , Radiobox1Life90, %Radiobox1Life90%
      IniRead, Radiobox2Life90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Life90, 0
      GuiControl, , Radiobox2Life90, %Radiobox2Life90%
      IniRead, Radiobox3Life90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Life90, 0
      GuiControl, , Radiobox3Life90, %Radiobox3Life90%
      IniRead, Radiobox4Life90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Life90, 0
      GuiControl, , Radiobox4Life90, %Radiobox4Life90%
      IniRead, Radiobox5Life90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Life90, 0
      GuiControl, , Radiobox5Life90, %Radiobox5Life90%

      IniRead, RadioUncheck1Life, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck1Life, 1
      GuiControl, , RadioUncheck1Life, %RadioUncheck1Life%
      IniRead, RadioUncheck2Life, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck2Life, 1
      GuiControl, , RadioUncheck2Life, %RadioUncheck2Life%
      IniRead, RadioUncheck3Life, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck3Life, 1
      GuiControl, , RadioUncheck3Life, %RadioUncheck3Life%
      IniRead, RadioUncheck4Life, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck4Life, 1
      GuiControl, , RadioUncheck4Life, %RadioUncheck4Life%
      IniRead, RadioUncheck5Life, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck5Life, 1
      GuiControl, , RadioUncheck5Life, %RadioUncheck5Life%
      
      ;ES Flasks
      IniRead, Radiobox1ES20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES20, 0
      GuiControl, , Radiobox1ES20, %Radiobox1ES20%
      IniRead, Radiobox2ES20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES20, 0
      GuiControl, , Radiobox2ES20, %Radiobox2ES20%
      IniRead, Radiobox3ES20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES20, 0
      GuiControl, , Radiobox3ES20, %Radiobox3ES20%
      IniRead, Radiobox4ES20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES20, 0
      GuiControl, , Radiobox4ES20, %Radiobox4ES20%
      IniRead, Radiobox5ES20, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES20, 0
      GuiControl, , Radiobox5ES20, %Radiobox5ES20%
      
      IniRead, Radiobox1ES30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES30, 0
      GuiControl, , Radiobox1ES30, %Radiobox1ES30%
      IniRead, Radiobox2ES30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES30, 0
      GuiControl, , Radiobox2ES30, %Radiobox2ES30%
      IniRead, Radiobox3ES30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES30, 0
      GuiControl, , Radiobox3ES30, %Radiobox3ES30%
      IniRead, Radiobox4ES30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES30, 0
      GuiControl, , Radiobox4ES30, %Radiobox4ES30%
      IniRead, Radiobox5ES30, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES30, 0
      GuiControl, , Radiobox5ES30, %Radiobox5ES30%
      
      IniRead, Radiobox1ES40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES40, 0
      GuiControl, , Radiobox1ES40, %Radiobox1ES40%
      IniRead, Radiobox2ES40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES40, 0
      GuiControl, , Radiobox2ES40, %Radiobox2ES40%
      IniRead, Radiobox3ES40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES40, 0
      GuiControl, , Radiobox3ES40, %Radiobox3ES40%
      IniRead, Radiobox4ES40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES40, 0
      GuiControl, , Radiobox4ES40, %Radiobox4ES40%
      IniRead, Radiobox5ES40, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES40, 0
      GuiControl, , Radiobox5ES40, %Radiobox5ES40%
      
      IniRead, Radiobox1ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES50, 0
      GuiControl, , Radiobox1ES50, %Radiobox1ES50%
      IniRead, Radiobox2ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES50, 0
      GuiControl, , Radiobox2ES50, %Radiobox2ES50%
      IniRead, Radiobox3ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES50, 0
      GuiControl, , Radiobox3ES50, %Radiobox3ES50%
      IniRead, Radiobox4ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES50, 0
      GuiControl, , Radiobox4ES50, %Radiobox4ES50%
      IniRead, Radiobox5ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES50, 0
      GuiControl, , Radiobox5ES50, %Radiobox5ES50%
      
      IniRead, Radiobox1ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES50, 0
      GuiControl, , Radiobox1ES50, %Radiobox1ES50%
      IniRead, Radiobox2ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES50, 0
      GuiControl, , Radiobox2ES50, %Radiobox2ES50%
      IniRead, Radiobox3ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES50, 0
      GuiControl, , Radiobox3ES50, %Radiobox3ES50%
      IniRead, Radiobox4ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES50, 0
      GuiControl, , Radiobox4ES50, %Radiobox4ES50%
      IniRead, Radiobox5ES50, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES50, 0
      GuiControl, , Radiobox5ES50, %Radiobox5ES50%
      
      IniRead, Radiobox1ES60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES60, 0
      GuiControl, , Radiobox1ES60, %Radiobox1ES60%
      IniRead, Radiobox2ES60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES60, 0
      GuiControl, , Radiobox2ES60, %Radiobox2ES60%
      IniRead, Radiobox3ES60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES60, 0
      GuiControl, , Radiobox3ES60, %Radiobox3ES60%
      IniRead, Radiobox4ES60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES60, 0
      GuiControl, , Radiobox4ES60, %Radiobox4ES60%
      IniRead, Radiobox5ES60, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES60, 0
      GuiControl, , Radiobox5ES60, %Radiobox5ES60%
      
      IniRead, Radiobox1ES70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES70, 0
      GuiControl, , Radiobox1ES70, %Radiobox1ES70%
      IniRead, Radiobox2ES70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES70, 0
      GuiControl, , Radiobox2ES70, %Radiobox2ES70%
      IniRead, Radiobox3ES70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES70, 0
      GuiControl, , Radiobox3ES70, %Radiobox3ES70%
      IniRead, Radiobox4ES70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES70, 0
      GuiControl, , Radiobox4ES70, %Radiobox4ES70%
      IniRead, Radiobox5ES70, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES70, 0
      GuiControl, , Radiobox5ES70, %Radiobox5ES70%
      
      IniRead, Radiobox1ES80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES80, 0
      GuiControl, , Radiobox1ES80, %Radiobox1ES80%
      IniRead, Radiobox2ES80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES80, 0
      GuiControl, , Radiobox2ES80, %Radiobox2ES80%
      IniRead, Radiobox3ES80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES80, 0
      GuiControl, , Radiobox3ES80, %Radiobox3ES80%
      IniRead, Radiobox4ES80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES80, 0
      GuiControl, , Radiobox4ES80, %Radiobox4ES80%
      IniRead, Radiobox5ES80, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES80, 0
      GuiControl, , Radiobox5ES80, %Radiobox5ES80%
      
      IniRead, Radiobox1ES90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1ES90, 0
      GuiControl, , Radiobox1ES90, %Radiobox1ES90%
      IniRead, Radiobox2ES90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2ES90, 0
      GuiControl, , Radiobox2ES90, %Radiobox2ES90%
      IniRead, Radiobox3ES90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3ES90, 0
      GuiControl, , Radiobox3ES90, %Radiobox3ES90%
      IniRead, Radiobox4ES90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4ES90, 0
      GuiControl, , Radiobox4ES90, %Radiobox4ES90%
      IniRead, Radiobox5ES90, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5ES90, 0
      GuiControl, , Radiobox5ES90, %Radiobox5ES90%
      
      IniRead, RadioUncheck1ES, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck1ES, 1
      GuiControl, , RadioUncheck1ES, %RadioUncheck1ES%
      IniRead, RadioUncheck2ES, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck2ES, 1
      GuiControl, , RadioUncheck2ES, %RadioUncheck2ES%
      IniRead, RadioUncheck3ES, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck3ES, 1
      GuiControl, , RadioUncheck3ES, %RadioUncheck3ES%
      IniRead, RadioUncheck4ES, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck4ES, 1
      GuiControl, , RadioUncheck4ES, %RadioUncheck4ES%
      IniRead, RadioUncheck5ES, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, RadioUncheck5ES, 1
      GuiControl, , RadioUncheck5ES, %RadioUncheck5ES%
      
      ;Mana Flasks
      IniRead, Radiobox1Mana10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox1Mana10, 0
      GuiControl, , Radiobox1Mana10, %Radiobox1Mana10%
      IniRead, Radiobox2Mana10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox2Mana10, 0
      GuiControl, , Radiobox2Mana10, %Radiobox2Mana10%
      IniRead, Radiobox3Mana10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox3Mana10, 0
      GuiControl, , Radiobox3Mana10, %Radiobox3Mana10%
      IniRead, Radiobox4Mana10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox4Mana10, 0
      GuiControl, , Radiobox4Mana10, %Radiobox4Mana10%
      IniRead, Radiobox5Mana10, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, Radiobox5Mana10, 0
      GuiControl, , Radiobox5Mana10, %Radiobox5Mana10%
      
      ;Flask Cooldowns
      IniRead, CooldownFlask1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask1, 4800
      GuiControl, , CooldownFlask1, %CooldownFlask1%
      IniRead, CooldownFlask2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask2, 4800
      GuiControl, , CooldownFlask2, %CooldownFlask2%
      IniRead, CooldownFlask3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask3, 4800
      GuiControl, , CooldownFlask3, %CooldownFlask3%
      IniRead, CooldownFlask4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask4, 4800
      GuiControl, , CooldownFlask4, %CooldownFlask4%
      IniRead, CooldownFlask5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, CooldownFlask5  , 4800
      GuiControl, , CooldownFlask5, %CooldownFlask5%
      
      ;Attack Flasks
      IniRead, MainAttackbox1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox1, 0
      GuiControl, , MainAttackbox1, %MainAttackbox1%
      IniRead, MainAttackbox2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox2, 0
      GuiControl, , MainAttackbox2, %MainAttackbox2%
      IniRead, MainAttackbox3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox3, 0
      GuiControl, , MainAttackbox3, %MainAttackbox3%
      IniRead, MainAttackbox4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox4, 0
      GuiControl, , MainAttackbox4, %MainAttackbox4%
      IniRead, MainAttackbox5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, MainAttackbox5, 0
      GuiControl, , MainAttackbox5, %MainAttackbox5%
      
      IniRead, SecondaryAttackbox1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox1, 0
      GuiControl, , SecondaryAttackbox1, %SecondaryAttackbox1%
      IniRead, SecondaryAttackbox2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox2, 0
      GuiControl, , SecondaryAttackbox2, %SecondaryAttackbox2%
      IniRead, SecondaryAttackbox3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox3, 0
      GuiControl, , SecondaryAttackbox3, %SecondaryAttackbox3%
      IniRead, SecondaryAttackbox4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox4, 0
      GuiControl, , SecondaryAttackbox4, %SecondaryAttackbox4%
      IniRead, SecondaryAttackbox5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, SecondaryAttackbox5, 0
      GuiControl, , SecondaryAttackbox5, %SecondaryAttackbox5%
      
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
      
      ;Quicksilver Flasks
      IniRead, TriggerQuicksilverDelay, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, TriggerQuicksilverDelay, .5
      GuiControl, , TriggerQuicksilverDelay, %TriggerQuicksilverDelay%
      IniRead, Radiobox1QS, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot1, 0
      GuiControl, , Radiobox1QS, %Radiobox1QS%
      IniRead, Radiobox2QS, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot2, 0
      GuiControl, , Radiobox2QS, %Radiobox2QS%
      IniRead, Radiobox3QS, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot3, 0
      GuiControl, , Radiobox3QS, %Radiobox3QS%
      IniRead, Radiobox4QS, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot4, 0
      GuiControl, , Radiobox4QS, %Radiobox4QS%
      IniRead, Radiobox5QS, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, QuicksilverSlot5, 0
      GuiControl, , Radiobox5QS, %Radiobox5QS%
      
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

      ;ManaThreshold
      IniRead, ManaThreshold, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, ManaThreshold, 0
      GuiControl, , ManaThreshold, %ManaThreshold%

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

      ;Pop Flasks Keys
      IniRead, PopFlasks1, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks1, 1
      GuiControl, , PopFlasks1, %PopFlasks1%
      IniRead, PopFlasks2, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks2, 1
      GuiControl, , PopFlasks2, %PopFlasks2%
      IniRead, PopFlasks3, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks3, 1
      GuiControl, , PopFlasks3, %PopFlasks3%
      IniRead, PopFlasks4, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks4, 1
      GuiControl, , PopFlasks4, %PopFlasks4%
      IniRead, PopFlasks5, %A_ScriptDir%\save\Profiles.ini, Profile%Profile%, PopFlasks5, 1
      GuiControl, , PopFlasks5, %PopFlasks5%

      ;Update UI
      if (RadioLife=1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Disable, Radiobox%A_Index%ES90
          GuiControl, Disable, Radiobox%A_Index%ES80
          GuiControl, Disable, Radiobox%A_Index%ES70
          GuiControl, Disable, Radiobox%A_Index%ES60
          GuiControl, Disable, Radiobox%A_Index%ES50
          GuiControl, Disable, Radiobox%A_Index%ES40
          GuiControl, Disable, Radiobox%A_Index%ES30
          GuiControl, Disable, Radiobox%A_Index%ES20
          GuiControl, Disable, RadioUncheck%A_Index%ES
        }
      }
      else if (RadioHybrid=1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
      else if (RadioCi=1) {
        loop 5 {
          GuiControl, Disable, Radiobox%A_Index%Life90
            GuiControl, Disable, Radiobox%A_Index%Life80
            GuiControl, Disable, Radiobox%A_Index%Life70
            GuiControl, Disable, Radiobox%A_Index%Life60
            GuiControl, Disable, Radiobox%A_Index%Life50
            GuiControl, Disable, Radiobox%A_Index%Life40
            GuiControl, Disable, Radiobox%A_Index%Life30
            GuiControl, Disable, Radiobox%A_Index%Life20
            GuiControl, Disable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
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
      Thread, NoTimers, True
      Gui, Submit ; , NoHide
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnChar didn't work"
        Return
      }
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnChar := ScreenShot_GetColor(vX_OnChar,vY_OnChar)
        IniWrite, %varOnChar%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar
        readFromFile()
        MsgBox % "OnChar recalibrated!`nTook color hex: " . varOnChar . " `nAt coords x: " . vX_OnChar . " and y: " . vY_OnChar
      } else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnChar didn't work"
      
      hotkeys()
      
    return

    updateOnInventory:
      Thread, NoTimers, True
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
        varOnInventory := ScreenShot_GetColor(vX_OnInventory,vY_OnInventory)
        IniWrite, %varOnInventory%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory
        readFromFile()
        MsgBox % "OnInventory recalibrated!`nTook color hex: " . varOnInventory . " `nAt coords x: " . vX_OnInventory . " and y: " . vY_OnInventory
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnInventory didn't work"
      
      hotkeys()
      
    return

    updateOnMenu:
      Thread, NoTimers, True
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
        varOnMenu := ScreenShot_GetColor(vX_OnMenu,vY_OnMenu)
        IniWrite, %varOnMenu%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu
        readFromFile()
        MsgBox % "OnMenu recalibrated!`nTook color hex: " . varOnMenu . " `nAt coords x: " . vX_OnMenu . " and y: " . vY_OnMenu
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnMenu didn't work"
      
      hotkeys()
      
    return

    updateOnDelveChart:
      Thread, NoTimers, True
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
        varOnDelveChart := ScreenShot_GetColor(vX_OnDelveChart,vY_OnDelveChart)
        IniWrite, %varOnDelveChart%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart
        readFromFile()
        MsgBox % "OnDelveChart recalibrated!`nTook color hex: " . varOnDelveChart . " `nAt coords x: " . vX_OnDelveChart . " and y: " . vY_OnDelveChart
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDelveChart didn't work"
      
      hotkeys()
      
    return

    updateOnMetamorph:
      Thread, NoTimers, True
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
        varOnMetamorph := ScreenShot_GetColor(vX_OnMetamorph,vY_OnMetamorph)
        IniWrite, %varOnMetamorph%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMetamorph
        readFromFile()
        MsgBox % "OnMetamorph recalibrated!`nTook color hex: " . varOnMetamorph . " `nAt coords x: " . vX_OnMetamorph . " and y: " . vY_OnMetamorph
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnMetamorph didn't work"
      
      hotkeys()
      
    return

    updateOnStockPile:
      Thread, NoTimers, True
      Gui, Submit ; , NoHide
      
      IfWinExist, ahk_group POEGameGroup
      {
        Rescale()
        WinActivate, ahk_group POEGameGroup
      } else {
        MsgBox % "PoE Window does not exist. `nRecalibrate of OnStockPile didn't work"
        Return
      }
      
      
      if WinActive(ahk_group POEGameGroup){
        ScreenShot()
        varOnStockPile := ScreenShot_GetColor(vX_OnStockPile,vY_OnStockPile)
        IniWrite, %varOnStockPile%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStockPile
        readFromFile()
        MsgBox % "OnStockPile recalibrated!`nTook color hex: " . varOnStockPile . " `nAt coords x: " . vX_OnStockPile . " and y: " . vY_OnStockPile
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnStockPile didn't work"
      
      hotkeys()
      
    return

    updateOnStash:
      Thread, NoTimers, True
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
        varOnLeft := ScreenShot_GetColor(vX_OnLeft,vY_OnLeft)
        IniWrite, %varOnLeft%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft
        varOnStash := ScreenShot_GetColor(vX_OnStash,vY_OnStash)
        IniWrite, %varOnStash%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash
        readFromFile()
        MsgBox % "OnStash recalibrated!`nTook color hex: " . varOnStash . " `nAt coords x: " . vX_OnStash . " and y: " . vY_OnStash
          . "`n`nOnLeft recalibrated!`nTook color hex: " . varOnLeft . " `nAt coords x: " . vX_OnLeft . " and y: " . vY_OnLeft
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnStash/OnLeft didn't work"
      
      hotkeys()
      
    return

    updateEmptyColor:
      Thread, NoTimers, true    ;Critical
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
      Thread, NoTimers, True
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
        varOnChat := ScreenShot_GetColor(vX_OnChat,vY_OnChat)
        IniWrite, %varOnChat%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat
        readFromFile()
        MsgBox % "OnChat recalibrated!`nTook color hex: " . varOnChat . " `nAt coords x: " . vX_OnChat . " and y: " . vY_OnChat
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of onChat didn't work"
      
      hotkeys()
      
    return

    updateOnVendor:
      Thread, NoTimers, True
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
        varOnVendor := ScreenShot_GetColor(vX_OnVendor,vY_OnVendor)
        IniWrite, %varOnVendor%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor
        readFromFile()
        MsgBox % "OnVendor recalibrated!`nTook color hex: " . varOnVendor . " `nAt coords x: " . vX_OnVendor . " and y: " . vY_OnVendor
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
      
      hotkeys()
      
    return

    updateOnDiv:
      Thread, NoTimers, True
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
        varOnDiv := ScreenShot_GetColor(vX_OnDiv,vY_OnDiv)
        IniWrite, %varOnDiv%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv
        readFromFile()
        MsgBox % "OnDiv recalibrated!`nTook color hex: " . varOnDiv . " `nAt coords x: " . vX_OnDiv . " and y: " . vY_OnDiv
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDiv didn't work"
      
      hotkeys()
      
    return

    updateDetonate:
      Thread, NoTimers, True
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
          varOnDetonate := ScreenShot_GetColor(DetonateDelveX,DetonateY)
        Else
          varOnDetonate := ScreenShot_GetColor(DetonateX,DetonateY)
        IniWrite, %varOnDetonate%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate
        readFromFile()
        MsgBox % "OnDetonate recalibrated!`nTook color hex: " . varOnDetonate . " `nAt coords x: " . (OnMines?DetonateDelveX:DetonateX) . " and y: " . DetonateY
      }else
      MsgBox % "PoE Window is not active. `nRecalibrate of OnDetonate didn't work"
      
      hotkeys()
      
    return

    CalibrateOHB:
      Thread, NoTimers, True
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
        Thread, NoTimers, true
        Gui, Submit
        Gui, Wizard: New, +LabelWizard +AlwaysOnTop
        Gui, Wizard: Font, Bold
        Gui, Wizard: Add, GroupBox, x10 y9 w460 h270 , Select which calibrations to run
        Gui, Wizard: Font
        Gui, Wizard: Add, Text, x22 y29 w170 h200 , % "Enable the checkboxes to choose which calibration to perform"
          . "`n`nFollow the instructions in the tooltip that will appear in the screen center"
          . "`n`nFor best results, start the wizard in the hideout with your inventory emptied"
          . "`n`nPress the ""A"" button when your gamestate matches the instructions"
          . "`n`nTo cancel the Wizard, Hold Escape then press ""A"""

        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChar    x222 y39       w100 h20 , OnChar
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChat        xp   y+10      w100 h20 , OnChat
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnInventory     xp   y+10      w100 h20 , OnInventory
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnVendor      xp   y+10      w100 h20 , OnVendor
        Gui, Wizard: Add, CheckBox, vCalibrationOnDiv             xp   y+10      w100 h20 , OnDiv
        Gui, Wizard: Add, CheckBox, vCalibrationOnMetamorph           xp   y+10      w100 h20 , OnMetamorph

        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnMenu        x342 y39       w100 h20 , OnMenu
        Gui, Wizard: Add, CheckBox, Checked vCalibrationEmpty         xp   y+10      w100 h20 , Empty Inventory
        Gui, Wizard: Add, CheckBox, Checked vCalibrationOnStash       xp   y+10      w100 h20 , OnStash/OnLeft
        Gui, Wizard: Add, CheckBox, vCalibrationOnDelveChart        xp   y+10      w100 h20 , OnDelveChart
        Gui, Wizard: Add, CheckBox, vCalibrationDetonate          xp   y+10      w100 h20 , OnDetonate

        Gui, Wizard: Add, Button, x122 y239 w100 h30 gRunWizard, Run Wizard
        Gui, Wizard: Add, Button, x252 y239 w100 h30 gWizardClose, Cancel Wizard

        Gui, Wizard: Show,% "x"ScrCenter.X - 240 "y"ScrCenter.Y - 150 " h300 w479", Calibration Wizard
      Return

      RunWizard:
        Thread, NoTimers, True
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
          ToolTip,% "This will sample the OnChar Color"
            . "`nMake sure you are logged into a character"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnChar := ScreenShot_GetColor(vX_OnChar,vY_OnChar)
            SampleTT .= "OnChar      took RGB color hex: " . varOnChar . "  At coords x: " . vX_OnChar . " and y: " . vY_OnChar . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnChar didn't work"
        }
        If CalibrationOnChat
        {
          ToolTip,% "This will sample the OnChat Color"
            . "`nMake sure you have chat panel open"
            . "`nNo other panels can be open on the left"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnChat := ScreenShot_GetColor(vX_OnChat,vY_OnChat)
            SampleTT .= "OnChat      took RGB color hex: " . varOnChat . "  At coords x: " . vX_OnChat . " and y: " . vY_OnChat . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnChat didn't work"
        }
        If CalibrationOnMenu
        {
          ToolTip,% "This will sample the OnMenu Color"
            . "`nMake sure you have the Passive Skills menu open"
            . "`nCan also use Atlas menu to sample"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 135 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnMenu := ScreenShot_GetColor(vX_OnMenu,vY_OnMenu)
            SampleTT .= "OnMenu      took RGB color hex: " . varOnMenu . "  At coords x: " . vX_OnMenu . " and y: " . vY_OnMenu . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnMenu didn't work"
        }
        If CalibrationOnInventory
        {
          ToolTip,% "This will sample the OnInventory Color"
            . "`nMake sure you have the Inventory panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 130 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnInventory := ScreenShot_GetColor(vX_OnInventory,vY_OnInventory)
            SampleTT .= "OnInventory   took RGB color hex: " . varOnInventory . "  At coords x: " . vX_OnInventory . " and y: " . vY_OnInventory . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnInventory didn't work"
        }
        If CalibrationEmpty
        {
          ToolTip,% "This will sample the Empty Inventory Colors"
            . "`nMake sure you Empty all items from inventory"
            . "`nMake sure you have the Inventory panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 125 , % ScrCenter.Y -30
          KeyWait, a, D
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
          ToolTip,% "This will sample the OnVendor Color"
            . "`nMake sure you have the Vendor Sell panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 135 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnVendor := ScreenShot_GetColor(vX_OnVendor,vY_OnVendor)
            SampleTT .= "OnVendor    took RGB color hex: " . varOnVendor . "  At coords x: " . vX_OnVendor . " and y: " . vY_OnVendor . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
        }
        If CalibrationOnStash
        {
          ToolTip,% "This will sample the OnStash/OnLeft Color"
            . "`nMake sure you have the Stash panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 115 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnStash := ScreenShot_GetColor(vX_OnStash,vY_OnStash)
            , varOnLeft := ScreenShot_GetColor(vX_OnLeft,vY_OnLeft)
            SampleTT .= "OnStash      took RGB color hex: " . varOnStash . "  At coords x: " . vX_OnStash . " and y: " . vY_OnStash . "`n"
            SampleTT .= "OnLeft      took RGB color hex: " . varOnLeft . "  At coords x: " . vX_OnLeft . " and y: " . vY_OnLeft . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnStash/OnLeft didn't work"
        }
        If CalibrationOnDiv
        {
          ToolTip,% "This will sample the OnDiv Color"
            . "`nMake sure you have the Trade Divination panel open"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 150 , % ScrCenter.Y -30
          KeyWait, a, D
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
            ScreenShot(), varOnDiv := ScreenShot_GetColor(vX_OnDiv,vY_OnDiv)
            SampleTT .= "OnDiv       took RGB color hex: " . varOnDiv . "  At coords x: " . vX_OnDiv . " and y: " . vY_OnDiv . "`n"
          } else
          MsgBox % "PoE Window is not active. `nRecalibrate of OnDiv didn't work"
        }
        If CalibrationDetonate
        {
          ToolTip,% "This will sample the Detonate Mines Color"
            . "`nMake sure you are somewhere other than Delve mines"
            . "`nPlace a mine, and the detonate mines icon should appear"
            . "`nPress ""A"" to sample"
            . "`nHold Escape and press ""A"" to cancel"
            , % ScrCenter.X - 165 , % ScrCenter.Y -30
          KeyWait, a, D
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
              varOnDetonate := ScreenShot_GetColor(DetonateDelveX,DetonateY)
            Else
              varOnDetonate := ScreenShot_GetColor(DetonateX,DetonateY)
            SampleTT .= "Detonate Mines took RGB color hex: " . varOnDetonate . "  At coords x: " . (OnMines?DetonateDelveX:DetonateX) . " and y: " . DetonateY . "`n"
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
          KeyWait, a, D
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
            ScreenShot(), varOnDelveChart := ScreenShot_GetColor(vX_OnDelveChart,vY_OnDelveChart)
            SampleTT .= "OnDelveChart       took RGB color hex: " . varOnDelveChart . "  At coords x: " . vX_OnDelveChart . " and y: " . vY_OnDelveChart . "`n"
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
          KeyWait, a, D
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
            ScreenShot(), varOnMetamorph := ScreenShot_GetColor(vX_OnMetamorph,vY_OnMetamorph)
            SampleTT .= "OnMetamorph       took RGB color hex: " . varOnMetamorph . "  At coords x: " . vX_OnMetamorph . " and y: " . vY_OnMetamorph . "`n"
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

  { ; Individual Menus - LootColorsMenu, OHB_Editor, WR_Menu
    LootColorsMenu()
    {
      DrawLootColors:
        Static LG_Add, LG_Rem
        Global LootColors, LG_Vary
        Gui, Submit
        gui,LootColors: new, LabelLootColors
        gui,LootColors: -MinimizeBox
        Gui,LootColors: Add, DropDownList, gUpdateExtra vAreaScale w45 xm+5 ym+5,  0|30|40|50|60|70|80|90|100|200|300|400|500
        GuiControl,LootColors: ChooseString, AreaScale, %AreaScale%
        Gui,LootColors: Add, Text,                     x+3 yp+5              , AreaScale of search
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
        Thread, NoTimers, True ; Critical
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
        KeyWait, a, D
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
        Gui, 1: show
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

  { ; Gui Update functions - updateCharacterType, UpdateStash, UpdateExtra, UpdateResolutionScale, UpdateDebug, UpdateUtility, FlaskCheck, UtilityCheck
    updateCharacterType:
      Gui, Submit, NoHide
      if(RadioLife==1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Disable, Radiobox%A_Index%ES90
          GuiControl, Disable, Radiobox%A_Index%ES80
          GuiControl, Disable, Radiobox%A_Index%ES70
          GuiControl, Disable, Radiobox%A_Index%ES60
          GuiControl, Disable, Radiobox%A_Index%ES50
          GuiControl, Disable, Radiobox%A_Index%ES40
          GuiControl, Disable, Radiobox%A_Index%ES30
          GuiControl, Disable, Radiobox%A_Index%ES20
          GuiControl, Disable, RadioUncheck%A_Index%ES
        }
      }
      else if(RadioHybrid==1) {
        loop 5 {
          GuiControl, Enable, Radiobox%A_Index%Life90
            GuiControl, Enable, Radiobox%A_Index%Life80
            GuiControl, Enable, Radiobox%A_Index%Life70
            GuiControl, Enable, Radiobox%A_Index%Life60
            GuiControl, Enable, Radiobox%A_Index%Life50
            GuiControl, Enable, Radiobox%A_Index%Life40
            GuiControl, Enable, Radiobox%A_Index%Life30
            GuiControl, Enable, Radiobox%A_Index%Life20
            GuiControl, Enable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
      else if(RadioCi==1) {
        loop 5 {
          GuiControl, Disable, Radiobox%A_Index%Life90
            GuiControl, Disable, Radiobox%A_Index%Life80
            GuiControl, Disable, Radiobox%A_Index%Life70
            GuiControl, Disable, Radiobox%A_Index%Life60
            GuiControl, Disable, Radiobox%A_Index%Life50
            GuiControl, Disable, Radiobox%A_Index%Life40
            GuiControl, Disable, Radiobox%A_Index%Life30
            GuiControl, Disable, Radiobox%A_Index%Life20
            GuiControl, Disable, RadioUncheck%A_Index%Life
            
          GuiControl, Enable, Radiobox%A_Index%ES90
          GuiControl, Enable, Radiobox%A_Index%ES80
          GuiControl, Enable, Radiobox%A_Index%ES70
          GuiControl, Enable, Radiobox%A_Index%ES60
          GuiControl, Enable, Radiobox%A_Index%ES50
          GuiControl, Enable, Radiobox%A_Index%ES40
          GuiControl, Enable, Radiobox%A_Index%ES30
          GuiControl, Enable, Radiobox%A_Index%ES20
          GuiControl, Enable, RadioUncheck%A_Index%ES
        }
      }
    return

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
      IniWrite, %StashTabOil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabOil
      IniWrite, %StashTabBlightedMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabBlightedMap
      IniWrite, %StashTabDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabDelirium
      IniWrite, %StashTabOrgan%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabOrgan
      IniWrite, %StashTabFossil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabFossil
      IniWrite, %StashTabResonator%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabResonator
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
      IniWrite, %StashTabYesBlightedMap%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesBlightedMap
      IniWrite, %StashTabYesDelirium%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesDelirium
      IniWrite, %StashTabYesFragment%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFragment
      IniWrite, %StashTabYesEssence%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesEssence
      IniWrite, %StashTabYesOil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOil
      IniWrite, %StashTabYesOrgan%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesOrgan
      IniWrite, %StashTabYesFossil%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesFossil
      IniWrite, %StashTabYesResonator%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesResonator
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
      IniWrite, %StashTabCatalyst%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabCatalyst
      IniWrite, %StashTabYesCatalyst%, %A_ScriptDir%\save\Settings.ini, Stash Tab, StashTabYesCatalyst
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
      IniWrite, %YesSeedStockPile%, %A_ScriptDir%\save\Settings.ini, General, YesSeedStockPile
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
      IniWrite, %YesPopAllExtraKeys%, %A_ScriptDir%\save\Settings.ini, General, YesPopAllExtraKeys
      IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
      IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
      IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB
      IniWrite, %YesGlobeScan%, %A_ScriptDir%\save\Settings.ini, General, YesGlobeScan
      IniWrite, %YesStashChaosRecipe%, %A_ScriptDir%\save\Settings.ini, General, YesStashChaosRecipe
      IniWrite, %ChaosRecipeMaxHolding%, %A_ScriptDir%\save\Settings.ini, General, ChaosRecipeMaxHolding

      ;Automation Settings
      IniWrite, %YesEnableAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation
      IniWrite, %FirstAutomationSetting%, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting
      IniWrite, %YesEnableNextAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation
      IniWrite, %YesEnableSeedAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableSeedAutomation
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
      If (YesPersistantToggle)
        AutoReset()
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

    UpdateUtility:
      Gui, Submit, NoHide
      ;Utility Buttons
      IniWrite, %YesUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1
      IniWrite, %YesUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2
      IniWrite, %YesUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3
      IniWrite, %YesUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4
      IniWrite, %YesUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5
      IniWrite, %YesUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6
      IniWrite, %YesUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7
      IniWrite, %YesUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8
      IniWrite, %YesUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9
      IniWrite, %YesUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10

      IniWrite, %YesUtility1Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1Quicksilver
      IniWrite, %YesUtility2Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2Quicksilver
      IniWrite, %YesUtility3Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3Quicksilver
      IniWrite, %YesUtility4Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4Quicksilver
      IniWrite, %YesUtility5Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5Quicksilver
      IniWrite, %YesUtility6Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6Quicksilver
      IniWrite, %YesUtility7Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7Quicksilver
      IniWrite, %YesUtility8Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8Quicksilver
      IniWrite, %YesUtility9Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9Quicksilver
      IniWrite, %YesUtility10Quicksilver%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10Quicksilver

      IniWrite, %YesUtility1InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1InverseBuff
      IniWrite, %YesUtility2InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2InverseBuff
      IniWrite, %YesUtility3InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3InverseBuff
      IniWrite, %YesUtility4InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4InverseBuff
      IniWrite, %YesUtility5InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5InverseBuff
      IniWrite, %YesUtility6InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6InverseBuff
      IniWrite, %YesUtility7InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7InverseBuff
      IniWrite, %YesUtility8InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8InverseBuff
      IniWrite, %YesUtility9InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9InverseBuff
      IniWrite, %YesUtility10InverseBuff%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10InverseBuff

      IniWrite, %YesUtility1MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1MainAttack
      IniWrite, %YesUtility2MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2MainAttack
      IniWrite, %YesUtility3MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3MainAttack
      IniWrite, %YesUtility4MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4MainAttack
      IniWrite, %YesUtility5MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5MainAttack
      IniWrite, %YesUtility6MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6MainAttack
      IniWrite, %YesUtility7MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7MainAttack
      IniWrite, %YesUtility8MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8MainAttack
      IniWrite, %YesUtility9MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9MainAttack
      IniWrite, %YesUtility10MainAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10MainAttack
      
      IniWrite, %YesUtility1SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1SecondaryAttack
      IniWrite, %YesUtility2SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2SecondaryAttack
      IniWrite, %YesUtility3SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3SecondaryAttack
      IniWrite, %YesUtility4SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4SecondaryAttack
      IniWrite, %YesUtility5SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5SecondaryAttack
      IniWrite, %YesUtility6SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6SecondaryAttack
      IniWrite, %YesUtility7SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7SecondaryAttack
      IniWrite, %YesUtility8SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8SecondaryAttack
      IniWrite, %YesUtility9SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9SecondaryAttack
      IniWrite, %YesUtility10SecondaryAttack%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10SecondaryAttack
      
      ;Utility Percents  
      IniWrite, %YesUtility1LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1LifePercent
      IniWrite, %YesUtility2LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2LifePercent
      IniWrite, %YesUtility3LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3LifePercent
      IniWrite, %YesUtility4LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4LifePercent
      IniWrite, %YesUtility5LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5LifePercent
      IniWrite, %YesUtility6LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6LifePercent
      IniWrite, %YesUtility7LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7LifePercent
      IniWrite, %YesUtility8LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8LifePercent
      IniWrite, %YesUtility9LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9LifePercent
      IniWrite, %YesUtility10LifePercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10LifePercent

      IniWrite, %YesUtility1EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1EsPercent
      IniWrite, %YesUtility2EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2EsPercent
      IniWrite, %YesUtility3EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3EsPercent
      IniWrite, %YesUtility4EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4EsPercent
      IniWrite, %YesUtility5EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5EsPercent
      IniWrite, %YesUtility6EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6EsPercent
      IniWrite, %YesUtility7EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7EsPercent
      IniWrite, %YesUtility8EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8EsPercent
      IniWrite, %YesUtility9EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9EsPercent
      IniWrite, %YesUtility10EsPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10EsPercent

      IniWrite, %YesUtility1ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility1ManaPercent
      IniWrite, %YesUtility2ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility2ManaPercent
      IniWrite, %YesUtility3ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility3ManaPercent
      IniWrite, %YesUtility4ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility4ManaPercent
      IniWrite, %YesUtility5ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility5ManaPercent
      IniWrite, %YesUtility6ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility6ManaPercent
      IniWrite, %YesUtility7ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility7ManaPercent
      IniWrite, %YesUtility8ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility8ManaPercent
      IniWrite, %YesUtility9ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility9ManaPercent
      IniWrite, %YesUtility10ManaPercent%, %A_ScriptDir%\save\Settings.ini, Utility Buttons, YesUtility10ManaPercent
      
      ;Utility Cooldowns
      IniWrite, %CooldownUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility1
      IniWrite, %CooldownUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility2
      IniWrite, %CooldownUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility3
      IniWrite, %CooldownUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility4
      IniWrite, %CooldownUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility5
      IniWrite, %CooldownUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility6
      IniWrite, %CooldownUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility7
      IniWrite, %CooldownUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility8
      IniWrite, %CooldownUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility9
      IniWrite, %CooldownUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Cooldowns, CooldownUtility10
      
      ;Utility Keys
      IniWrite, %KeyUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility1
      IniWrite, %KeyUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility2
      IniWrite, %KeyUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility3
      IniWrite, %KeyUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility4
      IniWrite, %KeyUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility5
      IniWrite, %KeyUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility6
      IniWrite, %KeyUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility7
      IniWrite, %KeyUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility8
      IniWrite, %KeyUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility9
      IniWrite, %KeyUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Keys, KeyUtility10
      
      ;Utility Keys
      IniWrite, %IconStringUtility1%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility1
      IniWrite, %IconStringUtility2%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility2
      IniWrite, %IconStringUtility3%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility3
      IniWrite, %IconStringUtility4%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility4
      IniWrite, %IconStringUtility5%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility5
      IniWrite, %IconStringUtility6%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility6
      IniWrite, %IconStringUtility7%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility7
      IniWrite, %IconStringUtility8%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility8
      IniWrite, %IconStringUtility9%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility9
      IniWrite, %IconStringUtility10%, %A_ScriptDir%\save\Settings.ini, Utility Icons, IconStringUtility10
      
      ; SendMSG(1, 0)
    Return

    FlaskCheck:
      Gui, Submit, NoHide
      loop 5 {
        if(Radiobox%A_Index%Life90==1) || (Radiobox%A_Index%ES90==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life80==1) || (Radiobox%A_Index%ES80==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life70==1) || (Radiobox%A_Index%ES70==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life60==1) || (Radiobox%A_Index%ES60==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life50==1) || (Radiobox%A_Index%ES50==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life40==1) || (Radiobox%A_Index%ES40==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life30==1) || (Radiobox%A_Index%ES30==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
        if(Radiobox%A_Index%Life20==1) || (Radiobox%A_Index%ES20==1) {
          GuiControl,, Radiobox%A_Index%QS, 0
          GuiControl,, Radiobox%A_Index%Mana10, 0
        }
      }
    return

    UtilityCheck:
      Gui, Submit, NoHide
      loop 5 {
        if(Radiobox%A_Index%QS==1) || (Radiobox%A_Index%Mana10==1) {
          GuiControl,, Radiobox%A_Index%Life90, 0
          GuiControl,, Radiobox%A_Index%Life80, 0
          GuiControl,, Radiobox%A_Index%Life70, 0
          GuiControl,, Radiobox%A_Index%Life60, 0
          GuiControl,, Radiobox%A_Index%Life50, 0
          GuiControl,, Radiobox%A_Index%Life40, 0
          GuiControl,, Radiobox%A_Index%Life30, 0
          GuiControl,, Radiobox%A_Index%Life20, 0
          GuiControl,, RadioUncheck%A_Index%Life, 1
          GuiControl,, Radiobox%A_Index%ES90, 0
          GuiControl,, Radiobox%A_Index%ES80, 0
          GuiControl,, Radiobox%A_Index%ES70, 0
          GuiControl,, Radiobox%A_Index%ES60, 0
          GuiControl,, Radiobox%A_Index%ES50, 0
          GuiControl,, Radiobox%A_Index%ES40, 0
          GuiControl,, Radiobox%A_Index%ES30, 0
          GuiControl,, Radiobox%A_Index%ES20, 0
          GuiControl,, RadioUncheck%A_Index%ES, 1
          }
        }
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
    Run, Library.ahk, %A_ScriptDir%\data\
    Return

    GuiEscape:
      Gui, Cancel
    return

    ItemInfoEscape:
    ItemInfoClose:
      Gui, ItemInfo: Hide
    Return

    ; CleanUp(){
    ;   DetectHiddenWindows, On
      
    ;   WinGet, PID, PID, %A_ScriptDir%\GottaGoFast.ahk
    ;   Process, Close, %PID%
    ; Return
    ; }

    UpdateProfileText1:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText1, , ProfileText1
      IniWrite, %ProfileText1%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText1
    Return

    UpdateProfileText2:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText2, , ProfileText2
      IniWrite, %ProfileText2%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText2
    Return

    UpdateProfileText3:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText3, , ProfileText3
      IniWrite, %ProfileText3%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText3
    Return

    UpdateProfileText4:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText4, , ProfileText4
      IniWrite, %ProfileText4%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText4
    Return

    UpdateProfileText5:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText5, , ProfileText5
      IniWrite, %ProfileText5%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText5
    Return

    UpdateProfileText6:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText6, , ProfileText6, 
      IniWrite, %ProfileText6%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText6
    Return

    UpdateProfileText7:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText7, , ProfileText7
      IniWrite, %ProfileText7%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText7
    Return

    UpdateProfileText8:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText8, , ProfileText8
      IniWrite, %ProfileText8%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText8
    Return

    UpdateProfileText9:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText9, , ProfileText9
      IniWrite, %ProfileText9%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText9
    Return

    UpdateProfileText10:
      ;Gui, Submit, NoHide
      GuiControlGet, ProfileText10, , ProfileText10
      IniWrite, %ProfileText10%, %A_ScriptDir%\save\Profiles.ini, Profiles, ProfileText10
    Return

    helpCalibration:
      Gui, submit
      MsgBox % "" "Gamestate Calibration Instructions:`n`nThese buttons regrab the gamestate sample color which the script uses to determine whats going on.`n`nEach button references a different pixel on the screen, so make sure the gamestate is true for that button!`n`nRead the tooltip on each button for specific information on that sample.`n`nUse Coord/Debug tool to check if they are working, enable debug mode to use it`n`nDifferent parts of the script have mandatory calibrations:`n`nOnChar -- ALL FUNCTIONS REQUIRE`nOnChat -- Not Mandatory - Pauses Auto-Functions`nOnMenu -- Not Mandatory - Pauses Auto-Functions`nOnInventory -- ID/Vend/Stash`nOnStash -- ID/Vend/Stash`nOnDiv -- ID/Vend/Stash`nOnVendor -- ID/Vend/Stash`nEmpty Inventory -- ID/Vend/Stash`nDetonate Color -- Auto-Mines`nDetonate in Delve -- Auto-Mines"
      Hotkeys()
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
