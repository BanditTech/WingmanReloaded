#IfWinActive Path of Exile ;Contains all the pre-setup for the script
    #NoEnv
    #MaxHotkeysPerInterval 99000000
    #HotkeyInterval 99000000
    #KeyHistory 0
    #SingleInstance force
	;#Warn UseEnv 
    #Persistent 
    #InstallMouseHook
    #InstallKeybdHook
    #MaxThreadsPerHotkey 2
	#MaxMem 256
    ListLines Off
    Process, Priority, , A
    SetBatchLines, -1
    SetKeyDelay, -1, -1
    SetMouseDelay, -1
    SetDefaultMouseSpeed, 0
    SetWinDelay, -1
    SetControlDelay, -1
    CoordMode, Mouse, Screen
    CoordMode, Pixel, Screen
    FileEncoding , UTF-8
    SendMode Input
    StringCaseSense, On ; Match strings with case.
	FormatTime, Date_now, A_Now, yyyyMMdd
    Global VersionNumber := .08.09
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
	Global selectedLeague, UpdateDatabaseInterval, LastDatabaseParseDate, YesNinjaDatabase
	IniRead, LastDatabaseParseDate, Settings.ini, Database, LastDatabaseParseDate, 20190913
	IniRead, selectedLeague, Settings.ini, Database, selectedLeague, Blight
	IniRead, UpdateDatabaseInterval, Settings.ini, Database, UpdateDatabaseInterval, 2
	IniRead, YesNinjaDatabase, Settings.ini, Database, YesNinjaDatabase, 1
	Global Ninja := {}
	Global apiList := ["Currency"
		, "Fragment"
		, "Prophecy"
		, "DivinationCard"
		, "Map"
		, "Essence"
		, "UniqueArmour"
		, "UniqueFlask"
		, "UniqueWeapon"
		, "UniqueAccessory"
		, "UniqueJewel"
		, "UniqueMap"
		, "SkillGem"
		, "Scarab"
		, "Oil"
		, "Incubator"
		, "Resonator"
		, "Fossil"
		, "Beast"]

	Global craftingBasesT1 := ["Opal Ring"
		, "Steel Ring"
		, "Vermillion Ring"]

	Global craftingBasesT2 := ["Blue Pearl Amulet"
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

	Global craftingBasesT3 := ["Colossal Tower Shield"
		, "Eternal Burgonet"
		, "Hubris Circlet"
		, "Lion Pelt"
		, "Sorcerer Boots"
		, "Sorcerer Gloves"
		, "Titanium Spirit Shield"
		, "Vaal Regalia"
		, "Diamond Ring"
		, "Onyx Amulet"
		, "Two-Stone Ring"]

    ; Create a container for the sub-script
    Global scriptGottaGoFast := "GottaGoFast.ahk ahk_exe AutoHotkey.exe"
    ; Create Executable group for gameHotkey, IfWinActive
    global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
    for n, exe in POEGameArr
        GroupAdd, POEGameGroup, ahk_exe %exe%
	Global GameStr := "ahk_group POEGameGroup"
    Hotkey, IfWinActive, ahk_group POEGameGroup
        
    OnMessage(0x5555, "MsgMonitor")
    OnMessage(0x5556, "MsgMonitor")
	OnMessage( 0xF, "WM_PAINT")
	OnMessage(0x200, Func("ShowToolTip"))  ; WM_MOUSEMOVE
    
    SetTitleMatchMode 2
    SetWorkingDir %A_ScriptDir%  
    Thread, interrupt, 0
    I_Icon = shield_charge_skill_icon.ico
    IfExist, %I_Icon%
        Menu, Tray, Icon, %I_Icon%
    

    checkUpdate()
    
    full_command_line := DllCall("GetCommandLine", "str")
    
    GetTable := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "GetExtendedTcpTable", "Ptr")
    SetEntry := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "SetTcpEntry", "Ptr")
    EnumProcesses := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Psapi.dll", "Ptr"), Astr, "EnumProcesses", "Ptr")
    preloadPsapi := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")
    OpenProcessToken := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "OpenProcessToken", "Ptr")
    LookupPrivilegeValue := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "LookupPrivilegeValue", "Ptr")
    AdjustTokenPrivileges := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "AdjustTokenPrivileges", "Ptr")
    
    CleanUp()
    if not A_IsAdmin
        if A_IsCompiled
        Run *RunAs "%A_ScriptFullPath%" /restart
    else
        Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	Sleep, -1
    Run "%A_ScriptDir%\GottaGoFast.ahk"
    OnExit("CleanUp")
    
	Global Enchantment  := []
	Global Corruption := []
	Global Bases
	IfNotExist, %A_ScriptDir%\data
		FileCreateDir, %A_ScriptDir%\data
	
	IfNotExist, %A_ScriptDir%\data\InventorySlots.png
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/InventorySlots.png, %A_ScriptDir%\data\InventorySlots.png
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
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/boot_enchantment_mods.txt, %A_ScriptDir%\data\boot_enchantment_mods.txt
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
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/helmet_enchantment_mods.txt, %A_ScriptDir%\data\helmet_enchantment_mods.txt
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
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/glove_enchantment_mods.txt, %A_ScriptDir%\data\glove_enchantment_mods.txt
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
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/item_corrupted_mods.txt, %A_ScriptDir%\data\item_corrupted_mods.txt
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
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/Controller.png, %A_ScriptDir%\data\Controller.png
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
    	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/LootFilter.ahk, %A_ScriptDir%\data\LootFilter.ahk
		if ErrorLevel {
 			Log("data","uhoh", "LootFilter.ahk")
			MsgBox, Error ED02 : There was a problem downloading LootFilter.ahk
		}
		Else if (ErrorLevel=0){
 			Log("data","pass", "LootFilter.ahk")
		}
	}
	IfNotExist, %A_ScriptDir%\data\Bases.json
	{
    	UrlDownloadToFile, https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/base_items.min.json, %A_ScriptDir%\data\Bases.json
		if ErrorLevel {
 			Log("data","uhoh", "Bases.json")
			MsgBox, Error ED02 : There was a problem downloading Bases.json from RePoE
		}
		Else if (ErrorLevel=0){
 			Log("data","pass", "Bases.json")
			FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
			Bases := JSON.Load(JSONtext)
		}
	}
	Else
	{
		FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
		Bases := JSON.Load(JSONtext)
	}
	If needReload
		Reload

; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; Extra vars - Not in INI
		global OutsideTimer:=0
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
		Global LootFilterTabs := {}
		Global IgnoredSlot := {}
		Global BlackList := {}
		Global OHBxy := 0
		Global YesClickPortal := True
		Global RelogOnQuit := True

		ft_ToolTip_Text=
			(LTrim
			ManaThreshold = This value scales the location of the mana sample`rA value of 0 is aproximately 10`% mana`rA value of 100 is approximately 95`% mana
			PopFlasks1 = Enable flask slot 1 when using Pop Flasks hotkey
			PopFlasks2 = Enable flask slot 2 when using Pop Flasks hotkey
			PopFlasks3 = Enable flask slot 3 when using Pop Flasks hotkey
			PopFlasks4 = Enable flask slot 4 when using Pop Flasks hotkey
			PopFlasks5 = Enable flask slot 5 when using Pop Flasks hotkey
			DetonateMines = Enable this to automatically Detonate Mines when placed`rDouble tap the D key to pause until next manual detonate
			YesEldritchBattery = Enable this to sample the energy shield on the mana globe instead
			UpdateOnCharBtn = Calibrate the OnChar Color`rThis color determines if you are on a character`rSample located on the figurine next to the health globe
			UpdateOnChatBtn = Calibrate the OnChat Color`rThis color determines if the chat panel is open`rSample located on the very left edge of the screen
			UpdateOnDivBtn = Calibrate the OnDiv Color`rThis color determines if the Trade Divination panel is open`rSample located at the top of the Trade panel
			UdateEmptyInvSlotColorBtn = Calibrate the Empty Inventory Color`rThis color determines the Empy Inventory slots`rSample located at the bottom left of each cell
			UpdateOnInventoryBtn = Calibrate the OnInventory Color`rThis color determines if the Inventory panel is open`rSample is located at the top of the Inventory panel
			UpdateOnStashBtn = Calibrate the OnStash Color`rThis color determines if the Stash panel is open`rSample is located at the top of the Stash panel
			UpdateOnVendorBtn = Calibrate the OnVendor Color`rThis color determines if the Vendor Sell panel is open`r Sample is located at the top of the Sell panel
			UpdateOnMenuBtn = Calibrate the OnMenu Color`rThis color determines if Atlas or Skills menus are open`rSample located at the top of the fullscreen Menu panel
			UpdateDetonateBtn = Calibrate the Detonate Mines Color`rThis color determines if the detonate mine button is visible`rLocated above mana flask on the right
			UpdateDetonateDelveBtn = Calibrate the Detonate Mines Color while in Delve`rThis color determines if the detonate mine button is visible`rLocated above mana flask on the left
			CalibrateOHBBtn = Calibrate the life color of the Overhead Health Bar`rMake sure the OHB is visible
			ShowSampleIndBtn = Open the Sample GUI which allows you to recalibrate one at a time
			ShowDebugGamestatesBtn = Open the Gamestate panel which shows you what the script is able to detect`rRed means its not active, green is active
			StartCalibrationWizardBtn = Use the Wizard to grab multiple samples at once`rThis will prompt you with instructions for each step
			YesOHB = Uses the new Overhead Health Bar detection in delve`rRequires a working Client.txt logfile location`rOnly affects Health Detection
			ShowOnStart = Enable this to have the GUI show on start`rThe script can run without saving each launch`rAs long as nothing changed since last color sample
			Steam = These settings are for the LutBot Quit method`rEnable this to set the EXE as Steam version
			HighBits = These settings are for the LutBot Quit method`rEnable this to set the EXE as 64bit version
			AutoUpdateOff = Enable this to not check for new updates when launching the script
			YesPersistantToggle = Enable this to have toggles remain after exiting and restarting the script
			ResolutionScale = Adjust the resolution the script scales its values from`rStandard is 16:9`rClassic is 4:3 aka 12:9`rCinematic is 21:9`rUltraWide is 32:9
			Latency = Use this to multiply the sleep timers by this value`rOnly use in situations where you have extreme lag
			PortalScrollX = Select the X location at the center of Portal scrolls in inventory`rUse the Coord tool to find the X and Y
			PortalScrollY = Select the Y location at the center of Portal scrolls in inventory`rUse the Coord tool to find the X and Y
			WisdomScrollX = Select the X location at the center of Wisdom scrolls in inventory`rUse the Coord tool to find the X and Y
			WisdomScrollY = Select the Y location at the center of Wisdom scrolls in inventory`rUse the Coord tool to find the X and Y
			CurrentGemX = Select the X location of the Gem to swap from`rUse the Coord tool to find the X and Y
			CurrentGemY = Select the Y location of the Gem to swap from`rUse the Coord tool to find the X and Y
			AlternateGemX = Select the X location of the Gem to swap with`rThis can be in secondary weapon, enable weapon swap`rUse the Coord tool to find the X and Y
			AlternateGemY = Select the Y location of the Gem to swap with`rThis can be in secondary weapon, enable weapon swap`rUse the Coord tool to find the X and Y
			StockPortal = Enable this to restock Portal scrolls when more than 10 are missing
			StockWisdom = Enable this to restock Wisdom scrolls when more than 10 are missing
			AlternateGemOnSecondarySlot = Enable this to Swap Weapons for your Alternate Gem Swap location
			YesAutoSkillUp = Enable this to Automatically level up skill gems
			DebugMessages = Enable this to show debug messages, previous functions have been moved to gamestates
			hotkeyOptions = Set your hotkey to open the options GUI
			hotkeyAutoFlask = Set your hotkey to turn on and off AutoFlask
			hotkeyAutoQuit = Set your hotkey to turn on and off AutoQuit
			hotkeyLogout = Set your hotkey to Log out of the game
			hotkeyAutoQuicksilver = Set your hotkey to Turn on and off AutoQuicksilver
			hotkeyGetMouseCoords = Set your hotkey to grab mouse coordinates`rIf debug is enabled this function becomes the debug tool`rUse this to get gamestates or pixel grid info
			hotkeyQuickPortal = Set your hotkey to use a portal scroll from inventory
			hotkeyGemSwap = Set your hotkey to swap gems between the two locations set above`rEnable Weapon swap if your gem is on alternate weapon set
			hotkeyPopFlasks = Set your hotkey to Pop all flasks`rEnable the option to respect cooldowns on the right
			hotkeyItemSort = Set your hotkey to Sort through inventory`rPerforms several functions:`rIdentifies Items`rVendors Items`rSend Items to Stash`rTrade Divination cards
			hotkeyItemInfo = Set your hotkey to display information about an item`rWill graph price info if there is any match
			hotkeyCloseAllUI = Put your ingame assigned hotkey to Close All User Interface here
			hotkeyInventory = Put your ingame assigned hotkey to open inventory panel here
			hotkeyWeaponSwapKey = Put your ingame assigned hotkey to Weapon Swap here
			hotkeyLootScan = Put your ingame assigned hotkey for Item Pickup Key here
			LootVacuum = Enable the Loot Vacuum function`rUses the hotkey assigned to Item Pickup
			LootVacuumSettings = Assign your own loot colors and adjust the AreaScale`rEdit the INI directly for more than 2 groups or less`rThe menu is built to support any number of color groups`rEach group must contain Normal and Hovered colors
			PopFlaskRespectCD = Enable this option to limit flasks on CD when Popping all Flasks`rThis will always fire any extra keys that are present in the bindings`rThis over-rides the option below
			YesPopAllExtraKeys = Enable this option to press any extra keys in each flasks bindings when Popping all Flasks`rIf disabled, it will only fire the primary key assigned to the flask slot.
			LaunchHelp = Opens the AutoHotkey List of Keys
			YesIdentify = This option is for the Identify logic`rEnable to Identify items when the inventory panel is open
			YesStash = This option is for the Stash logic`rEnable to stash items to assigned tabs when the stash panel is open
			YesVendor = This option is for the Vendor logic`rEnable to sell items to vendors when the sell panel is open
			YesDiv = This option is for the Divination Trade logic`rEnable to sell stacks of divination cards at the trade panel
			YesMapUnid = This option is for the Identify logic`rEnable to avoid identifying maps
			YesSortFirst = This option is for the Stash logic`rEnable to send items to stash after all have been scanned
			YesStashT1 = This option is for the Crafting stash tab`rEnable to stash T1 crafting bases
			YesStashT2 = This option is for the Crafting stash tab`rEnable to stash T2 crafting bases
			YesStashT3 = This option is for the Crafting stash tab`rEnable to stash T3 crafting bases
			YesStashCraftingNormal = This option is for the Crafting stash tab`rEnable to stash Normal crafting bases
			YesStashCraftingMagic = This option is for the Crafting stash tab`rEnable to stash Magic crafting bases
			YesStashCraftingRare = This option is for the Crafting stash tab`rEnable to stash Rare crafting bases
			UpdateDatabaseInterval = How many days between database updates?
			selectedLeague = Which league are you playing on?
			UpdateLeaguesBtn = Use this button when there is a new league
			LVdelay = Change the time between each click command in ms`rThis is in case low delay causes disconnect`rIn those cases, use 45ms or more
			AreaScale = Increases the Pixel box around the Mouse`rA setting of 0 will search under cursor`rCan behave strangely at very high range
			YesTimeMS = Enable to show the time in MS for each portion of the health scan
			YesLocation = Enable to show the results of the Client Log parser
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
			StashTabGem = Assign the Stash tab for Normal Gem items
			StashTabYesGem = Enable to send Normal Gem items to the assigned tab on the left
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
			StashTabFossil = Assign the Stash tab for Fossil items
			StashTabYesFossil = Enable to send Fossil items to the assigned tab on the left
			StashTabResonator = Assign the Stash tab for Resonator items
			StashTabYesResonator = Enable to send Resonator items to the assigned tab on the left
			StashTabCrafting = Assign the Stash tab for Crafting items
			StashTabYesCrafting = Enable to send Crafting items to the assigned tab on the left
			YesNinjaDatabase = Enable to Update Ninja Database and load at start
			)
	; Globals For client.txt file
		Global ClientLog := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"
		Global CurrentLocation := ""
		Global CLogFO
	; ASCII converted strings of images
		Global 1080_HealthBarStr := "|<1080 Middle Bar>0x221415@0.97$104.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
			, 1080_MasterStr := "|<1080 Master>*100$46.wy1043UDVtZXNiAy7byDbslmCDsyTX78wDXsCAw3sSDVs7U7lsyTUSSTXXty8ntiSDbslDW3sy1XW"
			, 1080_NavaliStr := "|<1080 Navali>*100$56.TtzzzzzzznyTzzzzzzwTbxxzTjrx3tyCDXnsy0ST3ntsTDk3bkwSS7nw8Nt77D8wz36SNtnmDDks7USBw3nwD1k3mS0Qz3sQwwDbbDkz6TD3ntngDtblswyA38"
			, 1080_HelenaStr := "|<1080 Helena>*100$62.DlzzzzzzzznwTzzzzzzzwz7zxzzvyzjDlkCDUQT7nnwSPnwrXnsQz7bwzDsQy701tzDny3D8k0S3nw7YHnAz7Vwz3tYw3DltzDnyMC0HwSTnwzb3bYz7bwvDtsntDls70kCTAy8"
			, 1080_ZanaStr := "|<1080 Zana>*100$44.U3zzzzzs0zzzzzyyTrvyzjz7twT7nzXwDXnsTsz3sQy7wTYS3D8yDtbYHnDXy1tYw3lz0CMC0Mznnb3ba01wtsnt02T6TAy8"
			, 1080_GreustStr := "|<1080 Greust>*100$61.zzzzzzzzzzz3zzzzzzzzy0TzzzzzzzyDDzzzTjbzyDi0s77XUU37z6SPXtaKBbzX7Dlwnz7nzlXbsyMzXsyMnkSTC7lwSA3sTDbVsyDa1wzbnswT3n4STnvyCDktX7DstrD7w0llUS1sDXznzzzznzTzzzzzzzzzzzy"
			, 1080_SellItemsStr := "|<1080 Sell Items>*100$80.zzzjTzzzzzzzzzzzlXzzzzzzzzy3zwMzlzzzzzzz0TzbDyTzzzzzznbztnzbbzzzzzwzsSQztkC74AT37w3bDyQ30k03UESQtnzbbbAAANa3b6Qztttlb76TsM1bDySS0NllVz6Ttnzb7byQQQ7sbyQztltzb77lyMxbDyQSDFlly360NnzbUU4QQPY3kCQztsA37761nzDzzzzDnzzzts"
			, 1080_StashStr := "|<1080 Stash>0xC8C8DC@0.78$57.00Q000000006s00000001V00000000A3zVUT6301k3UC48kM070A2kk6300S1UK70kM01sA4MQ7z0031UX1skM00MADs3630031V1UMkM08MA8AX6300y1X0rkkQ"
			, 1080_SkillUpStr := "|<1080 Skill Up>0xAA6204@0.66$9.sz7ss0000sz7sw"
			, OHBStrW := StrSplit(StrSplit(1080_HealthBarStr, "$")[2], ".")[1]
	; FindText strings from INI
		Global StashStr, VendorStr, VendorMineStr, HealthBarStr, SellItemsStr, SkillUpStr
		, VendorLioneyeStr, VendorForestStr, VendorSarnStr, VendorHighgateStr
		, VendorOverseerStr, VendorBridgeStr, VendorDocksStr, VendorOriathStr
	; Click Vendor after stash
		Global YesVendorAfterStash
    ; General
		Global Latency := 1
		Global ShowOnStart := 0
		Global PopFlaskRespectCD := 1
		Global ResolutionScale := "Standard"
		Global QSonMainAttack := 1
		Global QSonSecondaryAttack := 1
		Global YesPersistantToggle := 1
		Global YesSortFirst := 1
		Global YesAutoSkillUp := 1
		Global FlaskList := []
		Global AreaScale := 0
		Global LVdelay := 0
		Global LootVacuum := 1
		Global YesVendor := 1
		Global YesStash := 1
		Global YesIdentify := 1
		Global YesDiv := 1
		Global YesMapUnid := 1
		Global YesStashKeys := 1
		Global YesPopAllExtraKeys := 1
		Global OnHideout := False
		Global OnTown := False
		Global OnMines := False
		Global DetonateMines := False
		Global DetonateDelve := False
		Global OnMenu := False
		Global OnChar := False
		Global OnChat := False
		Global OnInventory := False
		Global OnStash := False
		Global OnVendor := False
		Global OnDiv := False
		Global RescaleRan := False
		Global ToggleExist := False
		Global YesOHB := True
		Global HPerc := 100
		Global GameX, GameY, GameW, GameH, mouseX, mouseY
		Global OHB, OHBLHealthHex, OHBLManaHex, OHBLESHex, OHBLEBHex, OHBCheckHex

		; Loot colors for the vacuum
		Global LootColors := { 1 : 0xC4FEF6
			, 2 : 0x99FECC
			, 3 : 0x6565A3
			, 4 : 0x383877}

		;Item Parse blank Arrays
		Global Prop := {}
		Global Stats := {}
		Global Affix := {}

		global Detonated := 0
		global CurrentTab := 0
		global DebugMessages := 0
		global YesTimeMS := 0
		global YesLocation := 0
		global ShowPixelGrid := 0
		global ShowItemInfo := 0
		global Latency := 1
		global RunningToggle := False
		Global Steam := 1
		Global HighBits := 1
		Global AutoUpdateOff := 0
		Global EnableChatHotkeys := 0
		; Dont change the speed & the tick unless you know what you are doing
			global Speed:=1
			global Tick:=150
	; Inventory
		Global StashTabCurrency := 1
		Global StashTabMap := 1
		Global StashTabDivination := 1
		Global StashTabGem := 1
		Global StashTabGemQuality := 1
		Global StashTabFlaskQuality := 1
		Global StashTabLinked := 1
		Global StashTabCollection := 1
		Global StashTabUniqueRing := 1
		Global StashTabUniqueDump := 1
		Global StashTabFragment := 1
		Global StashTabEssence := 1
		Global StashTabOil := 1
		Global StashTabFossil := 1
		Global StashTabResonator := 1
		Global StashTabCrafting := 1
		Global StashTabProphecy := 1
		Global StashTabVeiled := 1
	; Checkbox to activate each tab
		Global StashTabYesCurrency := 1
		Global StashTabYesMap := 1
		Global StashTabYesDivination := 1
		Global StashTabYesGem := 1
		Global StashTabYesGemQuality := 1
		Global StashTabYesFlaskQuality := 1
		Global StashTabYesLinked := 1
		Global StashTabYesCollection := 1
		Global StashTabYesUniqueRing := 1
		Global StashTabYesUniqueDump := 1
		Global StashTabYesFragment := 1
		Global StashTabYesEssence := 1
		Global StashTabYesOil := 1
		Global StashTabYesFossil := 1
		Global StashTabYesResonator := 1
		Global StashTabYesCrafting := 1
		Global StashTabYesProphecy := 1
		Global StashTabYesVeiled := 1
	; Crafting bases to stash
		Global YesStashT1 := 1
		Global YesStashT2 := 1
		Global YesStashT3 := 1
		Global YesStashCraftingNormal := 1
		Global YesStashCraftingMagic := 1
		Global YesStashCraftingRare := 1
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
		global hotkeyControllerButton1,hotkeyControllerButton2,hotkeyControllerButton3,hotkeyControllerButton4,hotkeyControllerButton5,hotkeyControllerButton6,hotkeyControllerButton7,hotkeyControllerButton8,hotkeyControllerButton9,hotkeyControllerButton10,hotkeyControllerJoystick2
		global YesTriggerUtilityJoystickKey := 1
		global YesTriggerJoystick2Key := 1
	; ~ Hotkeys
	; Legend:   ! = Alt      ^ = Ctrl     + = Shift 
		global hotkeyOptions:="!F10"
		global hotkeyAutoFlask:="!F11"
		global hotkeyAutoQuit:="!F12"
		global hotkeyLogout:="F12"
		global hotkeyAutoQuicksilver:="!MButton"
		global hotkeyPopFlasks:="CapsLock"
		global hotkeyItemSort:="F6"
		global hotkeyItemInfo:="F5"
		global hotkeyLootScan:="f"
		global hotkeyQuickPortal:="!q"
		global hotkeyGemSwap:="!e"
		global hotkeyGetMouseCoords:="!o"
		global hotkeyCloseAllUI:="Space"
		global hotkeyInventory:="c"
		global hotkeyWeaponSwapKey:="x"
		global hotkeyMainAttack:="RButton"
		global hotkeySecondaryAttack:="w"
		global hotkeyDetonate:="d"
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
		global varOnMenu:=0x7BB9D6
		global varOnChar:=0x4F6980
		global varOnChat:=0x3B6288
		global varOnInventory:=0x8CC6DD
		global varOnStash:=0x9BD6E7
		global varOnVendor:=0x7BB1CC
		global varOnDiv:=0xC5E2F6
		Global DetonateHex := 0x412037

	; Life Colors
		global varLife20
		global varLife30
		global varLife40
		global varLife50
		global varLife60
		global varLife70
		global varLife80
		global varLife90
		
	; ES Colors
		global varES20
		global varES30
		global varES40
		global varES50
		global varES60
		global varES70
		global varES80
		global varES90

	; Mana Colors
		global varMana10
		global varManaThreshold
		Global ManaThreshold

	; Gem Swap
		global CurrentGemX:=1483
		global CurrentGemY:=372
		global AlternateGemX:=1379 
		global AlternateGemY:=171
		global AlternateGemOnSecondarySlot:=1

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
		global RadioQuit20, RadioQuit30, RadioQuit40, RadioQuit50, RadioQuit60, RadioCritQuit, RadioNormalQuit, RadioPortalQuit

	; Character Type
		global RadioCi, RadioHybrid, RadioLife
		
	; Utility Buttons
		global YesUtility1, YesUtility2, YesUtility3, YesUtility4, YesUtility5
		global YesUtility1Quicksilver, YesUtility2Quicksilver, YesUtility3Quicksilver, YesUtility4Quicksilver, YesUtility5Quicksilver
		global YesUtility1LifePercent, YesUtility2LifePercent, YesUtility3LifePercent, YesUtility4LifePercent, YesUtility5LifePercent
		global YesUtility1ESPercent, YesUtility2ESPercent, YesUtility3ESPercent, YesUtility4ESPercent, YesUtility5ESPercent

	; Utility Cooldowns
		global CooldownUtility1, CooldownUtility2, CooldownUtility3, CooldownUtility4, CooldownUtility5
		global OnCooldownUtility1 := 0
		global OnCooldownUtility2 := 0
		global OnCooldownUtility3 := 0
		global OnCooldownUtility4 := 0
		global OnCooldownUtility5 := 0

	; Utility Keys
		global KeyUtility1, KeyUtility2, KeyUtility3, KeyUtility4, KeyUtility5
	; Utility Icons
		global IconStringUtility1, IconStringUtility2, IconStringUtility3, IconStringUtility4, IconStringUtility5

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
	; Chat Functions
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


; ReadFromFile()
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	readFromFile()
; MAIN Gui Section
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Thread, NoTimers, true		;Critical
	Tooltip, Loading GUI 00`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	Gui Add, Checkbox, 	vDebugMessages Checked%DebugMessages%  gUpdateDebug   	x610 	y5 	    w13 h13
	Gui Add, Text, 										x515	y5, 				Debug Messages:
	Gui Add, Checkbox, 	vYesTimeMS Checked%YesTimeMS%  gUpdateDebug   	x490 	y5 	    w13 h13
	Gui Add, Text, 				vYesTimeMS_t						x437	y5, 				Flask MS:
	Gui Add, Checkbox, 	vYesLocation Checked%YesLocation%  gUpdateDebug   	x420 	y5 	    w13 h13
	Gui Add, Text, 				vYesLocation_t						x387	y5, 				C log:

	Gui Add, Tab2, vMainGuiTabs x3 y3 w625 h505 -wrap gSelectMainGuiTabs, Flasks and Utility|Configuration|Strings|Inventory|Chat|Controller
	;#######################################################################################################Strings Tab
	Gui, Tab, Strings
	Gui, Add, Button, x1 y1 w1 h1, 
	Gui, Font,
	Gui, Font, Bold cBlack
	Gui Add, GroupBox, 		Section		w605 h435						x12 	y30, 				String Samples from the FindText library - Use the dropdown to select from 1080 defaults
	Gui, Font,

	Gui +Delimiter?
	Gui, Add, Text, xs+10 ys+25 section, OHB 2 pixel bar - Only Adjust if not 1080 Height
	Gui, Add, ComboBox, xp y+8 w280 vHealthBarStr gUpdateStringEdit , %HealthBarStr%??"%1080_HealthBarStr%"
	Gui, Add, Text, x+10 x+10 ys , Capture of the Skill up icon
	Gui, Add, ComboBox, y+8 w280 vSkillUpStr gUpdateStringEdit , %SkillUpStr%??"%1080_SkillUpStr%"
	Gui, Add, Text, xs y+15 section , Capture of the words Sell Items
	Gui, Add, ComboBox, y+8 w280 vSellItemsStr gUpdateStringEdit , %SellItemsStr%??"%1080_SellItemsStr%"
	Gui, Add, Text, x+10 ys , Capture of the Stash
	Gui, Add, ComboBox, y+8 w280 vStashStr gUpdateStringEdit , %StashStr%??"%1080_StashStr%"
	Gui, Add, Text, xs y+15 section, Capture of the Hideout vendor nameplate
	Gui, Add, ComboBox, y+8 w280 vVendorStr gUpdateStringEdit , %VendorStr%??"%1080_MasterStr%"?"%1080_NavaliStr%"?"%1080_HelenaStr%"?"%1080_ZanaStr%"
	Gui +Delimiter|
	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki
	Gui, Add, Button,  		gft_Start 		x+5			 		h23, 	Grab Icon

	Tooltip, Loading GUI 10`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	;#######################################################################################################Flasks and Utility Tab
	Gui, Tab, Flasks and Utility
	Gui, Font,
	Gui, Font, Bold
	Gui Add, Text, 										x12 	y30, 				Flask Settings
	Gui, Font,

	Gui Add, GroupBox, 				Section		w160 h35				x+12 	yp-7, 				Character Type:
	Gui, Font, cRed
	Gui Add, Radio, Group 	vRadioLife Checked%RadioLife% 					xs+8 ys+14 gUpdateCharacterType, 	Life
	Gui, Font, cPurple
	Gui Add, Radio, 		vRadioHybrid Checked%RadioHybrid% 				x+8 gUpdateCharacterType, 	Hybrid
	Gui, Font, cBlue
	Gui Add, Radio, 		vRadioCi Checked%RadioCi% 					x+8 gUpdateCharacterType, 	CI
	Gui, Font

	Gui Add, Text, 										x63 	y+10, 				Flask 1
	Gui Add, Text, 										x+8, 						Flask 2
	Gui Add, Text, 										x+7, 						Flask 3
	Gui Add, Text, 										x+8, 						Flask 4
	Gui Add, Text, 										x+7, 						Flask 5

	Gui Add, Text, 			Section						x12 	y+5, 				Duration:
	Gui Add, Edit, 			vCooldownFlask1 			x63 	ys-2 	w34	h17, 	%CooldownFlask1%
	Gui Add, Edit, 			vCooldownFlask2 			x+8 			w34	h17, 	%CooldownFlask2%
	Gui Add, Edit, 			vCooldownFlask3 			x+7 			w34	h17, 	%CooldownFlask3%
	Gui Add, Edit, 			vCooldownFlask4 			x+8 			w34	h17, 	%CooldownFlask4%
	Gui Add, Edit, 			vCooldownFlask5 			x+7 			w34	h17, 	%CooldownFlask5%

	Gui Add, Text, 			Section				x13 	y+5, % 			   "  IG Key:"
	Gui Add, Edit, 			vkeyFlask1 			x63 	ys-2 	w34	h17, 	%keyFlask1%
	Gui Add, Edit, 			vkeyFlask2 			x+8 			w34	h17, 	%keyFlask2%
	Gui Add, Edit, 			vkeyFlask3 			x+7 			w34	h17, 	%keyFlask3%
	Gui Add, Edit, 			vkeyFlask4 			x+8 			w34	h17, 	%keyFlask4%
	Gui Add, Edit, 			vkeyFlask5 			x+7 			w34	h17, 	%keyFlask5%

	Gui, Font, cRed
	Gui Add, Text,			Section							x62	 	y+5, 				Life
	Gui Add, Text,										x+25, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui, Font
	Gui Add, Text,										x80	 	ys,				|
	Gui Add, Text,										x+40, 						|
	Gui Add, Text,										x+39, 						|
	Gui Add, Text,										x+39, 						|
	Gui Add, Text,										x+39, 						|
	Gui, Font, cBlue
	Gui Add, Text,										x83	 	ys,				ES
	Gui Add, Text,										x+28, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui, Font

	Gui Add, Text, 			Section							x23 	y+5, 				< 90`%:
	Gui Add, Text, 												y+5, 				< 80`%:
	Gui Add, Text, 												y+5, 				< 70`%:
	Gui Add, Text, 												y+5, 				< 60`%:
	Gui Add, Text, 												y+5, 				< 50`%:
	Gui Add, Text, 												y+5, 				< 40`%:
	Gui Add, Text, 												y+5, 				< 30`%:
	Gui Add, Text, 												y+5, 				< 20`%:
	Gui Add, Text, 										x17		y+5, 				Disable:

	loop 5 
		{
		Gui Add, Radio, Group 	vRadiobox%A_Index%Life90 gFlaskCheck		x+12	ys  	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life80 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life70 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life60 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life50 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life40 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life30 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life20 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadioUncheck%A_Index%Life 					y+5 	w13 h13
		
		Gui Add, Radio, Group 	vRadiobox%A_Index%ES90 gFlaskCheck			x+3 	ys  	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES80 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES70 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES60 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES50 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES40 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES30 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%ES20 gFlaskCheck					y+5		w13 h13
		Gui Add, Radio, 		vRadioUncheck%A_Index%ES 					y+5 	w13 h13
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

	Gui Add, Text, 					Section								x16 	y+8, 				Quicks.:
	;Gui,Font,cBlack
	Gui,Font,cBlack
	Gui Add, GroupBox, 		w257 h26								xp-5 	yp-9, 
	Gui,Font
	Gui Add, CheckBox, Group 	vRadiobox1QS 		gUtilityCheck		xs+60 	ys 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, CheckBox, Group 	vRadiobox%vFlask%QS		gUtilityCheck	x+28 	ys 	w13 h13
		vFlask:=vFlask+1
		}

	Gui,Font,cBlack
	Gui Add, GroupBox, 	Section	w257 h30								x11 	y+3, Mana `%
	Gui,Font
	Gui, Add, text, section x20 ys+13 w35, %ManaThreshold%
	Gui, Add, UpDown, vManaThreshold Range0-100, %ManaThreshold%
	Gui Add, CheckBox, 		vRadiobox1Mana10 	gUtilityCheck		x+20		ys-2 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, CheckBox, 		vRadiobox%vFlask%Mana10 gUtilityCheck		x+28	ys-2 	w13 h13
		vFlask:=vFlask+1
		}
	Loop, 5 {	
		valueMana10 := substr(TriggerMana10, (A_Index), 1)
		GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
		valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
		GuiControl, , Radiobox%A_Index%QS, %valueQuicksilver%
		}
	Gui,Font,cBlack
	Gui Add, GroupBox, 	Section	w257 h30								x11 	y+2
	Gui,Font
	Gui Add, Text, 					Section								x13 	yp+12, 				Pop Flsk:
	Gui Add, Checkbox, 		vPopFlasks1 			x75 	ys 	w13 h13
	Gui Add, Checkbox, 		vPopFlasks2 		x+28 			w13 h13
	Gui Add, Checkbox, 		vPopFlasks3 		x+28 			w13 h13
	Gui Add, Checkbox, 		vPopFlasks4 		x+28 			w13 h13
	Gui Add, Checkbox, 		vPopFlasks5 		x+28 			w13 h13

	Loop, 5 {	
		valuePopFlasks := substr(TriggerPopFlasks, (A_Index), 1)
		GuiControl, , PopFlasks%A_Index%, %valuePopFlasks%
		}


	Gui,Font,cBlack
	Gui Add, GroupBox, 			Section						x11 	y+13 	w257 h58,  	Attack:
	Gui Add, text, vFlaskColumn1									xp+53 	ys-8 	, Flask 1
	Gui Add, text, vFlaskColumn2									xp+42 	ys-8 	, Flask 2
	Gui Add, text, vFlaskColumn3									xp+41 	ys-8 	, Flask 3
	Gui Add, text, vFlaskColumn4									xp+41 	ys-8 	, Flask 4
	Gui Add, text, vFlaskColumn5									xp+41 	ys-8 	, Flask 5
	Gui,Font
	Gui Add, Edit, 			vhotkeyMainAttack 				xs+1 	ys+14 	w48 h17, 	%hotkeyMainAttack%
	Gui Add, Checkbox, 		vMainAttackbox1 			x75 	y+-15 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, Checkbox, 		vMainAttackbox%vFlask% 		x+28 			w13 h13
		vFlask:=vFlask+1
		} 

	Gui Add, Edit, 			vhotkeySecondaryAttack 		x12 	y+8 	w48 h17, 	%hotkeySecondaryAttack%
	Gui Add, Checkbox, 		vSecondaryAttackbox1 		x75 	y+-15 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, Checkbox, 		vSecondaryAttackbox%vFlask% x+28 			w13 h13
		vFlask:=vFlask+1
		}
	Loop, 5 {	
		valueMainAttack := substr(TriggerMainAttack, (A_Index), 1)
		GuiControl, , MainAttackbox%A_Index%, %valueMainAttack%
		valueSecondaryAttack := substr(TriggerSecondaryAttack, (A_Index), 1)
		GuiControl, , SecondaryAttackbox%A_Index%, %valueSecondaryAttack%
		}


	Gui,Font,s9 cBlack 
	Gui Add, GroupBox, 		Section	w257 h66				x12 	y+5 , 				Quicksilver settings
	Gui,Font,
	Gui Add, Text, 										xs+10 	ys+16, 				Quicksilver Flask Delay (in s):
	Gui Add, Edit, 			vTriggerQuicksilverDelay	x+10 	yp 	w22 h17, 	%TriggerQuicksilverDelay%
	Gui,Add,GroupBox,Section xs+10 yp+16 w208 h26											,Quicksilver on attack:
	Gui, Add, Checkbox, vQSonMainAttack +BackgroundTrans Checked%QSonMainAttack% xs+5 ys+15 , Primary Attack
	Gui, Add, Checkbox, vQSonSecondaryAttack +BackgroundTrans Checked%QSonSecondaryAttack% x+0 , Secondary Attack

	;Vertical Grey Lines
	Gui, Add, Text, 									x59 	y62 		h381 0x11
	Gui, Add, Text, 									x+33 				h381 0x11
	Gui, Add, Text, 									x+34 				h381 0x11
	Gui, Add, Text, 									x+33 				h381 0x11
	Gui, Add, Text, 									x+34 				h381 0x11
	Gui, Add, Text, 									x+33 				h381 0x11
	Gui, Add, Text, 									x+5 	y23		w1	h483 0x7
	Gui, Add, Text, 									x+1 	y23		w1	h483 0x7


	Gui,Font,s9 cBlack 
	Gui Add, GroupBox, 		Section	w227 h66				x292 	y30 , 				Auto-Quit settings
	Gui,Font,
	;Gui Add, Text, 											x292 	y30, 				Auto-Quit:
	Gui Add, Radio, Group 	vRadioQuit20 Checked%RadioQuit20% 				xs+5 ys+16, 						20`%
	Gui Add, Radio, 		vRadioQuit30 Checked%RadioQuit30% 				x+1, 								30`%
	Gui Add, Radio, 		vRadioQuit40 Checked%RadioQuit40% 				x+1, 								40`%
	Gui Add, Radio, 		vRadioQuit50 Checked%RadioQuit50% 				x+1, 								50`%
	Gui Add, Radio, 		vRadioQuit60 Checked%RadioQuit60% 				x+1, 								60`%
	Gui Add, Text, 										xs+5 	y+4, 				Quit via:
	Gui, Add, Radio, Group	vRadioCritQuit  Checked%RadioCritQuit%					x+5		y+-13,			D/C
	Gui, Add, Radio, 		vRadioPortalQuit Checked%RadioPortalQuit%			x+3	,				Portal
	Gui, Add, Radio, 		vRadioNormalQuit Checked%RadioNormalQuit%			x+3	,				/exit
	Gui Add, Checkbox, gUpdateExtra	vRelogOnQuit Checked%RelogOnQuit%           	xs+5	y+4				, Log back in afterwards?

	Gui,Font,s9 cBlack 
	Gui Add, GroupBox, 		Section	w90 h32				xs+230 	ys , 				Auto-Mine
	Gui Add, Checkbox, gUpdateExtra	vDetonateMines Checked%DetonateMines%           	xs+15	ys+15				, Enable
	Gui Add, GroupBox, 		Section	w90 h32	vEldritchBatteryGroupbox			xs 	y+6 , 				Eldritch Battery
	Gui Add, Checkbox, gUpdateEldritchBattery	vYesEldritchBattery Checked%YesEldritchBattery%           	xs+15	ys+15				, Enable
	Gui,Font,

	Gui, Font, Bold s9 cBlack
	Gui, Add, GroupBox, 					Section		w324 h176			x292 	y+7, 				Profile Management:
	Gui, Font
	Gui, Add, Text, 									xs+161 	ys+41 		h135 0x11

	Tooltip, Loading GUI 20`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	;Gui,Font,s9 cBlack Bold Underline
	;Gui,Add,GroupBox, xs+5 ys+10 w190 h35											,
	Gui,Add,text, xs+10 ys+18 											,Character Name:
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

	Gui, Font, Bold s9 cBlack
	Gui Add, GroupBox, 						w324 h176		section		x292 	y+15, 				Utility Management:
	Gui, Font,

	Gui Add, Checkbox, gUpdateUtility	vYesUtility1 +BackgroundTrans Checked%YesUtility1%	Right	ys+45 xs+2	, 1
	Gui Add, Checkbox, gUpdateUtility	vYesUtility2 +BackgroundTrans Checked%YesUtility2%	Right	y+12		, 2
	Gui Add, Checkbox, gUpdateUtility	vYesUtility3 +BackgroundTrans Checked%YesUtility3%	Right	y+12		, 3
	Gui Add, Checkbox, gUpdateUtility	vYesUtility4 +BackgroundTrans Checked%YesUtility4%	Right	y+12		, 4
	Gui Add, Checkbox, gUpdateUtility	vYesUtility5 +BackgroundTrans Checked%YesUtility5%	Right	y+12		, 5

	Gui,Add,Edit,			gUpdateUtility  x+10 ys+42   w40 h19 	vCooldownUtility1				,%CooldownUtility1%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility2				,%CooldownUtility2%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility3				,%CooldownUtility3%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility4				,%CooldownUtility4%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility5				,%CooldownUtility5%

	Gui,Add,Edit,	  	x+12	ys+42   w40 h19 gUpdateUtility	vKeyUtility1				,%KeyUtility1%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility2				,%KeyUtility2%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility3				,%KeyUtility3%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility4				,%KeyUtility4%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility5				,%KeyUtility5%

	Gui,Add,Edit,	  	x+11	ys+42   w40 h19 gUpdateUtility	vIconStringUtility1				,%IconStringUtility1%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vIconStringUtility2				,%IconStringUtility2%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vIconStringUtility3				,%IconStringUtility3%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vIconStringUtility4				,%IconStringUtility4%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vIconStringUtility5				,%IconStringUtility5%

	Gui Add, Checkbox, gUpdateUtility	vYesUtility1Quicksilver +BackgroundTrans Checked%YesUtility1Quicksilver%	x+12 ys+45, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility2Quicksilver +BackgroundTrans Checked%YesUtility2Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility3Quicksilver +BackgroundTrans Checked%YesUtility3Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility4Quicksilver +BackgroundTrans Checked%YesUtility4Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility5Quicksilver +BackgroundTrans Checked%YesUtility5Quicksilver%		y+12, %A_Space%

	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility1LifePercent h16 w40 x+7 	ys+42,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility2LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility3LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility4LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility5LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	GuiControl, ChooseString, YesUtility1LifePercent, %YesUtility1LifePercent%
	GuiControl, ChooseString, YesUtility2LifePercent, %YesUtility2LifePercent%
	GuiControl, ChooseString, YesUtility3LifePercent, %YesUtility3LifePercent%
	GuiControl, ChooseString, YesUtility4LifePercent, %YesUtility4LifePercent%
	GuiControl, ChooseString, YesUtility5LifePercent, %YesUtility5LifePercent%
		
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility1ESPercent h16 w40 x+12 	ys+42,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility2ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility3ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility4ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility5ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
	GuiControl, ChooseString, YesUtility2ESPercent, %YesUtility2ESPercent%
	GuiControl, ChooseString, YesUtility3ESPercent, %YesUtility3ESPercent%
	GuiControl, ChooseString, YesUtility4ESPercent, %YesUtility4ESPercent%
	GuiControl, ChooseString, YesUtility5ESPercent, %YesUtility5ESPercent%

	Gui Add, Text, 										xs+6 	ys+25, 	ON:
	Gui, Add, Text, 									x+9 	ys+25 		h145 0x11
	Gui Add, Text, 										x+12 	, 	CD:
	Gui, Add, Text, 									x+13 	 		h145 0x11
	Gui Add, Text, 										x+10 	, 	Key:
	Gui, Add, Text, 									x+14 	 		h145 0x11
	Gui Add, Text, 										x+6 	, 	Icon:
	Gui, Add, Text, 									x+12 	 		h145 0x11
	Gui Add, Text, 										x+-1 	, 	QS:
	Gui, Add, Text, 									x+7 	 		h145 0x11
	Gui Add, Text, 										x+8 	, 	Life:
	Gui, Add, Text, 									x+17 	 		h145 0x11
	Gui Add, Text, 										x+9 	, 	ES:

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki
	Gui, Add, Button,  		gft_Start 		x+5			 		h23, 	Grab Icon

	Tooltip, Loading GUI 30`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	;#######################################################################################################Configuration Tab
	Gui, Tab, Configuration
	Gui, Add, Text, 									x279 	y23		w1	h441 0x7
	Gui, Add, Text, 									x+1 	y23		w1	h441 0x7

	Gui, Add, Text, 									x376 	y29 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11

	Gui, Font, Bold
	Gui, Add, Text, 						section				x22 	y30, 				Gamestate Calibration:
	Gui, Add, Button, ghelpCalibration 	x+10 ys-4		w20 h20, 	?
	Gui, Add, Button, gStartCalibrationWizard vStartCalibrationWizardBtn	xs	ys+20 Section	w110 h25, 	Run Wizard
	Gui, Add, Button, gShowDebugGamestates vShowDebugGamestatesBtn	x+8	yp				w110 h25, 	Show Gamestates
	;Update calibration for pixel check
	Gui, Add, Button, gShowSampleInd vShowSampleIndBtn		xs	ys+35			w110, 	Individual Sample
	Gui, Add, Button, gCalibrateOHB vCalibrateOHBBtn 		x+8 ys+35		 	w110, 	Sample OHB
	Gui, Font


	Gui,SampleInd: Font, Bold
	Gui,SampleInd: Add, Text, 				section						xm 	ym+5, 				Gamestate Calibration:
	Gui,SampleInd: Font

	Gui,SampleInd: Add, Button, gupdateOnChar vUpdateOnCharBtn	 			xs y+3			w110, 	OnChar Color
	Gui,SampleInd: Add, Button, gupdateOnInventory vUpdateOnInventoryBtn	x+8	yp			w110, 	OnInventory Color
	Gui,SampleInd: Add, Button, gupdateOnChat vUpdateOnChatBtn	 			xs y+3			w110, 	OnChat Color
	Gui,SampleInd: Add, Button, gupdateOnStash vUpdateOnStashBtn	 		x+8	yp			w110, 	OnStash Color
	Gui,SampleInd: Add, Button, gupdateOnDiv vUpdateOnDivBtn	 			xs y+3			w110, 	OnDiv Color
	Gui,SampleInd: Add, Button, gupdateOnVendor vUpdateOnVendorBtn	 		x+8	yp			w110, 	OnVendor Color
	Gui,SampleInd: Add, Button, gupdateOnMenu vUpdateOnMenuBtn	 			xs y+3			w110, 	OnMenu Color


	Gui,SampleInd: Font, Bold
	Gui,SampleInd: Add, Text, 				section						xm 	y+10, 				Inventory Calibration:
	Gui,SampleInd: Font
	Gui,SampleInd: Add, Button, gupdateEmptyColor vUdateEmptyInvSlotColorBtn xs ys+20			 	w110, 	Empty Inventory

	Gui,SampleInd: Font, Bold
	Gui,SampleInd: Add, Text, 				section						xm 	y+10, 				AutoDetonate Calibration:
	Gui,SampleInd: Font
	Gui,SampleInd: Add, Button, gupdateDetonate vUpdateDetonateBtn 		xs ys+20					w110, 	Detonate Color
	Gui,SampleInd: Add, Button, gupdateDetonateDelve vUpdateDetonateDelveBtn	 x+8 yp		w110, 	Detonate in Delve

	Gui,SampleInd: +AlwaysOnTop

	Gui, Font, Bold
	Gui Add, Text, 					Section					xs 	y+10, 				Additional Interface Options:
	Gui, Font, 

	Gui Add, Checkbox, gUpdateExtra	vYesOHB Checked%YesOHB%                         	          			, Switch to OHB for Delve?
	Gui Add, Checkbox, gUpdateExtra	vShowOnStart Checked%ShowOnStart%                         	          	, Show GUI on startup?
	Gui Add, Checkbox, gUpdateExtra	vSteam Checked%Steam%                         	          				, Are you using Steam?
	Gui Add, Checkbox, gUpdateExtra	vHighBits Checked%HighBits%                         	          		, Are you running 64 bit?
	Gui Add, Checkbox, gUpdateExtra	vAutoUpdateOff Checked%AutoUpdateOff%                         	        , Turn off Auto-Update?
	Gui Add, Checkbox, gUpdateExtra	vYesPersistantToggle Checked%YesPersistantToggle%                       , Persistant Auto-Toggles?
	Gui Add, DropDownList, gUpdateResolutionScale	vResolutionScale       w80               	    		, Standard|Classic|Cinematic|UltraWide
	GuiControl, ChooseString, ResolutionScale, %ResolutionScale%
	Gui Add, Text, 			x+8 y+-18							 							, Aspect Ratio
	Gui, Add, DropDownList, gUpdateExtra vLatency w30 xs y+10,  %Latency%||1|2|3
	Gui Add, Text, 										x+10 y+-18							, Adjust Latency
	Gui Add, Edit, 			vClientLog 				xs y+10	w144	h21, 	%ClientLog%
	Gui add, Button, gSelectClientLog x+5 , Locate Logfile
	IfNotExist, %A_ScriptDir%\data\leagues.json
	{
		UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
	}
	FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
	LeagueIndex := JSON.Load(JSONtext)
	textList= 
	For K, V in LeagueIndex
		textList .= (!textList ? "" : "|") LeagueIndex[K]["id"]

	Gui, Font, Bold
	Gui Add, GroupBox, 			Section		w210 h95				xm+5 	y+15, 				Item Parse Settings
	Gui, Font,
	Gui, Add, Checkbox, vYesNinjaDatabase xs+5 ys+20 Checked%YesNinjaDatabase%, Update PoE.Ninja Database?
	Gui, Add, DropDownList, vUpdateDatabaseInterval x+1 yp-4 w30 Choose%UpdateDatabaseInterval%, 1|2|3|4|5|6|7
	Gui, Add, DropDownList, vselectedLeague xs+5 y+5 w102, %selectedLeague%||%textList%
	Gui, Add, Button, gUpdateLeagues vUpdateLeaguesBtn x+5 , Update leagues
	Gui, Add, Checkbox, vForceMatch6Link xs+5 y+8 Checked%ForceMatch6Link%, Force a match with the 6 Link price


	Gui, Font, Bold
	Gui Add, Text, 										x292 	y30, 				QoL Settings
	Gui, Font

	Gui Add, Text, 										x+16 	y35,				X-Pos
	Gui Add, Text, 										x+12, 						Y-Pos

	Gui Add, Text, 										x314	y+5, 				Portal Scroll:
	Gui Add, Edit, 			vPortalScrollX 				x+7		y+-15 	w34	h17, 	%PortalScrollX%
	Gui Add, Edit, 			vPortalScrollY 				x+7			 	w34	h17, 	%PortalScrollY%	
	Gui Add, Text, 										x306	y+6, 				Wisdm. Scroll:
	Gui Add, Edit, 			vWisdomScrollX 				x+7		y+-15 	w34	h17, 	%WisdomScrollX%
	Gui Add, Edit, 			vWisdomScrollY 				x+7			 	w34	h17, 	%WisdomScrollY%	
	Gui Add, Text, 										x311	y+6, 				Current Gem:
	Gui Add, Edit, 			vCurrentGemX 				x+7		y+-15 	w34	h17, 	%CurrentGemX%
	Gui Add, Edit, 			vCurrentGemY 				x+7			 	w34	h17, 	%CurrentGemY%

	Gui Add, Text, 										x303	y+6, 				Alternate Gem:
	Gui Add, Edit, 			vAlternateGemX 				x+7		y+-15 	w34	h17, 	%AlternateGemX%
	Gui Add, Edit, 			vAlternateGemY 				x+7			 	w34	h17, 	%AlternateGemY%
	Gui Add, Checkbox, 	    vStockPortal Checked%StockPortal%              	x465     		y53				, Stock Portal?
	Gui Add, Checkbox, 	    vStockWisdom Checked%StockWisdom%              	         		y+8				, Stock Wisdom?
	Gui Add, Checkbox, 	vAlternateGemOnSecondarySlot Checked%AlternateGemOnSecondarySlot%  	y+8				, Weapon Swap?
	Gui Add, Checkbox, 	vYesAutoSkillUp Checked%YesAutoSkillUp%  	y+8				, Auto Skill Up?


	Gui, Font, Bold
	Gui Add, Text, 										x295 	y148, 				Keybinds:
	Gui, Font
	Gui Add, Text, 										x360 	y+10, 				Open this GUI
	Gui Add, Text, 										x360 	y+10, 				Auto-Flask
	Gui Add, Text, 										x360 	y+10, 				Auto-Quit
	Gui Add, Text, 										x360 	y+10, 				Logout
	Gui Add, Text, 										x360 	y+10, 				Auto-QSilver
	Gui Add, Text, 					  					x360 	y+10,               Coord/Pixel 				
	Gui Add, Text, 										x360 	y+10, 				Quick-Portal
	Gui Add, Text, 										x360 	y+10, 				Gem-Swap
	Gui Add, Text, 										x360 	y+10, 				Pop Flasks
	Gui Add, Text, 										x360 	y+10, 				ID/Vend/Stash
	Gui Add, Text, 										x360 	y+10, 				Item Info

	Gui,Add,Edit,			 x295 y168 w60 h19 	    vhotkeyOptions			,%hotkeyOptions%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyAutoFlask			,%hotkeyAutoFlask%
	Gui,Add,Edit,			 		y+4  w60 h19 	vhotkeyAutoQuit			,%hotkeyAutoQuit%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyLogout	        ,%hotkeyLogout%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyAutoQuicksilver	,%hotkeyAutoQuicksilver%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyGetMouseCoords	,%hotkeyGetMouseCoords%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyQuickPortal		,%hotkeyQuickPortal%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyGemSwap			,%hotkeyGemSwap%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyPopFlasks	        ,%hotkeyPopFlasks%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyItemSort     ,%hotkeyItemSort%
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyItemInfo     ,%hotkeyItemInfo%

	Gui, Font, Bold
	Gui Add, Text, 										x440 	y148, 				Ingame:
	Gui, Font
	Gui Add, Text, 										x500 	y+10, 				Close UI
	Gui Add, Text, 											 	y+10, 				Inventory
	Gui Add, Text, 											 	y+10, 				W-Swap
	Gui Add, Text, 											 	y+10, 				Item Pickup
	Gui,Add,Edit,			  	x435 y168  w60 h19 	vhotkeyCloseAllUI		,%hotkeyCloseAllUI%
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyInventory			,%hotkeyInventory%
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyWeaponSwapKey		,%hotkeyWeaponSwapKey%
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyLootScan		,%hotkeyLootScan%
	Gui Add, Checkbox, section gUpdateExtra	vLootVacuum Checked%LootVacuum%                         	         y+8 ; Loot Vacuum?
	Gui Add, Button, gLootColorsMenu    vLootVacuumSettings                      	      h19  x+0 yp-3, Loot Vacuum Settings
	Gui Add, Checkbox, gUpdateExtra	vPopFlaskRespectCD Checked%PopFlaskRespectCD%                         	    xs y+6 , Pop Flasks Respect CD?
	Gui Add, Checkbox, gUpdateExtra	vYesPopAllExtraKeys Checked%YesPopAllExtraKeys%                         	     y+8 , Pop Flasks Uses any extra keys?
	Gui Add, Checkbox, gUpdateExtra	vYesClickPortal Checked%YesClickPortal%                         	     y+8 , Click portal after opening?

	;~ =========================================================================================== Subgroup: Hints
	Gui,Font,Bold
	Gui,Add,GroupBox,Section xs	x450 y+10  w120 h80							,Hotkey Modifiers
	Gui, Add, Button,  		gLaunchHelp vLaunchHelp		xs+108 ys w18 h18 , 	?
	Gui,Font,Norm
	Gui,Font,s8,Arial
	Gui,Add,Text,	 		 	xs+15 ys+17					,!%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%ALT
	Gui,Add,Text,	 		   		y+5					,^%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%CTRL
	Gui,Add,Text,	 		   		y+5					,+%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%SHIFT

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	Tooltip, Loading GUI 40`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	;#######################################################################################################Inventory Tab
	Gui, Tab, Inventory
	Gui, Font, Bold
	Gui Add, Text, 										x12 	y30, 				Stash Management
	Gui, Font,

	tablistArr := [ "1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
	textList=
	For k, v in tablistArr
		textList .= (!textList ? "" : "|") v

	Gui, Add, DropDownList, gUpdateStash vStashTabCurrency Choose%StashTabCurrency% x10 y50 w40  , %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabOil Choose%StashTabOil% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabMap Choose%StashTabMap% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabFragment Choose%StashTabFragment% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabDivination Choose%StashTabDivination% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabCollection Choose%StashTabCollection% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabEssence Choose%StashTabEssence% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabProphecy Choose%StashTabProphecy% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabVeiled Choose%StashTabVeiled% w40 ,  %textList%

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCurrency Checked%StashTabYesCurrency%  x+5 y55, Currency Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesOil Checked%StashTabYesOil% y+14, Oil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesMap Checked%StashTabYesMap% y+14, Map Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFragment Checked%StashTabYesFragment% y+14, Fragment Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesDivination Checked%StashTabYesDivination% y+14, Divination Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCollection Checked%StashTabYesCollection% y+14, Collection Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesEssence Checked%StashTabYesEssence% y+14, Essence Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesProphecy Checked%StashTabYesProphecy% y+14, Prophecy Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesVeiled Checked%StashTabYesVeiled% y+14, Veiled Tab

	Tooltip, Loading GUI 45`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui, Add, DropDownList, gUpdateStash vStashTabGem Choose%StashTabGem% x150 y50 w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabGemQuality Choose%StashTabGemQuality% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabFlaskQuality Choose%StashTabFlaskQuality% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabLinked Choose%StashTabLinked% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabUniqueDump Choose%StashTabUniqueDump% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabUniqueRing Choose%StashTabUniqueRing% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabFossil Choose%StashTabFossil% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabResonator Choose%StashTabResonator% w40 ,  %textList%
	Gui, Add, DropDownList, gUpdateStash vStashTabCrafting Choose%StashTabCrafting% w40 ,  %textList%

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGem Checked%StashTabYesGem% x195 y55, Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGemQuality Checked%StashTabYesGemQuality% y+14, Quality Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFlaskQuality Checked%StashTabYesFlaskQuality% y+14, Quality Flask Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesLinked Checked%StashTabYesLinked% y+14, Linked Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% y+14, Unique Dump Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% y+14, Unique Ring Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFossil Checked%StashTabYesFossil% y+14, Fossil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesResonator Checked%StashTabYesResonator% y+14, Resonator Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCrafting Checked%StashTabYesCrafting% y+14, Crafting Tab

	Tooltip, Loading GUI 50`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui Add, Checkbox, x+65 ym+30	vYesStashKeys Checked%YesStashKeys%                         	         , Enable stash hotkeys?


	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section xp-5 yp+20 w100 h85											,Modifier
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, xs+4 ys+20 w90 h23 vstashPrefix1, %stashPrefix1%
	Gui Add, Edit, y+8        w90 h23 vstashPrefix2, %stashPrefix2%

	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox, xp-5 y+20 w100 h55											,Reset Tab
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, xp+4 yp+20 w90 h23 vstashReset, %stashReset%

	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w100 h275											,Keys
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, ys+20 xs+4 w90 h23 vstashSuffix1, %stashSuffix1%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix2, %stashSuffix2%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix3, %stashSuffix3%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix4, %stashSuffix4%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix5, %stashSuffix5%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix6, %stashSuffix6%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix7, %stashSuffix7%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix8, %stashSuffix8%
	Gui Add, Edit, y+5        w90 h23 vstashSuffix9, %stashSuffix9%

	Tooltip, Loading GUI 55`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w50 h275											,Tab
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, DropDownList, xs+4 ys+20 w40 vstashSuffixTab1 Choose%stashSuffixTab1%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab2 Choose%stashSuffixTab2%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab3 Choose%stashSuffixTab3%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab4 Choose%stashSuffixTab4%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab5 Choose%stashSuffixTab5%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab6 Choose%stashSuffixTab6%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab7 Choose%stashSuffixTab7%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab8 Choose%stashSuffixTab8%, %textList%
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab9 Choose%stashSuffixTab9%, %textList%

	Tooltip, Loading GUI 60`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui, Font, Bold
	Gui, Add, Button, gLaunchLootFilter xm y300, Custom Loot Filter
	Gui, Add, Button, gBuildIgnoreMenu x+10, Assign Ignored Slots
	Gui Add, Text, 		Section								xm 	y330, 				ID/Vend/Stash Options:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesIdentify Checked%YesIdentify%   				, Identify Items?
	Gui Add, Checkbox, gUpdateExtra	vYesStash Checked%YesStash%         				, Deposit at stash?
	Gui Add, Checkbox, gUpdateExtra	vYesVendor Checked%YesVendor%       				, Sell at vendor?
	Gui Add, Checkbox, gUpdateExtra	vYesDiv Checked%YesDiv%             				, Trade Divination?
	Gui Add, Checkbox, gUpdateExtra	vYesMapUnid Checked%YesMapUnid%     				, Leave Map Un-ID?
	Gui Add, Checkbox, gUpdateExtra	vYesSortFirst Checked%YesSortFirst% 				, Group Items before stashing?

	Gui, Font, Bold s9 cBlack
	Gui Add, GroupBox, 						w180 h60		section		xm+180 	ys+5, 				Crafting Tab:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesStashT1 Checked%YesStashT1%     xs+5	ys+18			, T1?
	Gui Add, Checkbox, gUpdateExtra	vYesStashT2 Checked%YesStashT2%     x+21				, T2?
	Gui Add, Checkbox, gUpdateExtra	vYesStashT3 Checked%YesStashT3%     x+16				, T3?
	Gui Add, Checkbox, gUpdateExtra	vYesStashCraftingNormal Checked%YesStashCraftingNormal%     	xs+5	y+8		, Normal?
	Gui Add, Checkbox, gUpdateExtra	vYesStashCraftingMagic Checked%YesStashCraftingMagic%     x+0				, Magic?
	Gui Add, Checkbox, gUpdateExtra	vYesStashCraftingRare Checked%YesStashCraftingRare%     x+0				, Rare?

	Gui, Font, Bold s9 cBlack
	Gui Add, GroupBox, 						w180 h60		section		xm+370 	ys, 				Automation:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesSearchForStash Checked%YesSearchForStash%     xs+5	ys+18			, Search for stash?
	Gui Add, Checkbox, gUpdateExtra	vYesVendorAfterStash Checked%YesVendorAfterStash%     y+8			, Move to vendor after stash?

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	Tooltip, Loading GUI 70`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	;#######################################################################################################Controller Tab

	Gui, Tab, Controller
	DefaultButtons := [ "ItemSort","QuickPortal","PopFlasks","GemSwap","Logout","LButton","RButton","MButton","q","w","e","r","t"]
	textList= 
	For k, v in DefaultButtons
		textList .= (!textList ? "" : "|") v
	
	Gui, Add, Picture, xm ym+20 w600 h400 +0x4000000, %A_ScriptDir%\data\Controller.png

	Gui Add, Checkbox,  section	xp y+-10					vYesMovementKeys Checked%YesMovementKeys%                         	          , Use Move Keys?
	Gui Add, Checkbox, 						vYesTriggerUtilityKey Checked%YesTriggerUtilityKey%                         	          , Use utility on Move?
	Gui Add, DropDownList,   x+5 yp-5     w40 	vTriggerUtilityKey Choose%TriggerUtilityKey%, 1|2|3|4|5

	Gui, Add, Checkbox, section xm+255 ym+360 vYesController Checked%YesController%,Enable Controller
	
	Gui,Add,GroupBox, section xm+80 ym+15 w80 h40												,5
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton5, %hotkeyControllerButton5%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
	Gui,Add,GroupBox,  xs+360 ys w80 h40												,6
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton6, %hotkeyControllerButton6%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%

	Gui,Add,GroupBox, section  xm+65 ym+100 w90 h80												,D-Pad
	gui,add,text, xs+15 ys+30, Mouse`nMovement

	Gui,Add,GroupBox, section xm+165 ym+180 w80 h80												,Joystick1
	Gui,Add,Checkbox, xs+5 ys+30 		Checked%YesTriggerUtilityJoystickKey%			vYesTriggerUtilityJoystickKey, Use util from`nMove Keys?
	Gui,Add,GroupBox,  xs ys+90 w80 h40												,9 / L3
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton9, %hotkeyControllerButton9%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%

	Tooltip, Loading GUI 75`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui,Add,GroupBox,section  xs+190 ys w80 h80												,Joystick2
	Gui,Add,Checkbox, xp+5 y+-53 		Checked%YesTriggerJoystick2Key%			vYesTriggerJoystick2Key, Use key?
	Gui Add, ComboBox,  			xp y+8      w70 	vhotkeyControllerJoystick2, %hotkeyControllerJoystick2%||LButton|RButton|q|w|e|r|t
	Gui,Add,GroupBox,  xs ys+90 w80 h40												,10 / R3
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton10, %hotkeyControllerButton10%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%

	Gui,Add,GroupBox, section xm+140 ym+60 w80 h40												,7 / Select
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton7, %hotkeyControllerButton7%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
	Gui,Add,GroupBox, xs+245 ys w80 h40												,8 / Start
	Gui,Add,ComboBox, xp+5 y+-23 w70 											vhotkeyControllerButton8, %hotkeyControllerButton8%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%

	Gui,Add,GroupBox, section xm+65 ym+280 w40 h40									,Up
	Gui,Add,Edit, xp+5 y+-23 w30 h19											vhotkeyUp, %hotkeyUp%
	Gui,Add,GroupBox, xs ys+80 w40 h40												,Down
	Gui,Add,Edit, xp+5 y+-23 w30 h19											vhotkeyDown, %hotkeyDown%
	Gui,Add,GroupBox, xs-40 ys+40 w40 h40											,Left
	Gui,Add,Edit, xp+5 y+-23 w30 h19											vhotkeyLeft, %hotkeyLeft%
	Gui,Add,GroupBox, xs+40 ys+40 w40 h40											,Right
	Gui,Add,Edit, xp+5 y+-23 w30 h19											vhotkeyRight, %hotkeyRight%

	Gui,Add,GroupBox,section xm+465 ym+80 w70 h40											,4
	Gui,Add,ComboBox, xp+5 y+-23 w60 											vhotkeyControllerButton4, %hotkeyControllerButton4%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
	Gui,Add,GroupBox, xs ys+80 w70 h40											,1
	Gui,Add,ComboBox, xp+5 y+-23 w60 											vhotkeyControllerButton1, %hotkeyControllerButton1%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
	Gui,Add,GroupBox, xs-40 ys+40 w70 h40											,3
	Gui,Add,ComboBox, xp+5 y+-23 w60 											vhotkeyControllerButton3, %hotkeyControllerButton3%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
	Gui,Add,GroupBox, xs+40 ys+40 w70 h40											,2
	Gui,Add,ComboBox, xp+5 y+-23 w60 											vhotkeyControllerButton2, %hotkeyControllerButton2%||%textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	Tooltip, Loading GUI 80`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	;#######################################################################################################Chat Tab
	Gui, Tab, Chat
	Gui Add, Checkbox, gUpdateExtra	vEnableChatHotkeys Checked%EnableChatHotkeys%     xm ym+20                    	          	, Enable chat Hotkeys?

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y470	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki


	Gui Add, Tab, vInnerTab w590 h370 xm+10 ym+40 Section hwndInnerTab, Commands|Reply Whisper
	Gui, Tab, Commands
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section w60 h85											,Modifier
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, xs+4 ys+20 w50 h23 v1Prefix1, %1Prefix1%
	Gui Add, Edit, y+8        w50 h23 v1Prefix2, %1Prefix2%
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w60 h275											,Keys
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, ys+20 xs+4 w50 h23 v1Suffix1, %1Suffix1%
	Gui Add, Edit, y+5        w50 h23 v1Suffix2, %1Suffix2%
	Gui Add, Edit, y+5        w50 h23 v1Suffix3, %1Suffix3%
	Gui Add, Edit, y+5        w50 h23 v1Suffix4, %1Suffix4%
	Gui Add, Edit, y+5        w50 h23 v1Suffix5, %1Suffix5%
	Gui Add, Edit, y+5        w50 h23 v1Suffix6, %1Suffix6%
	Gui Add, Edit, y+5        w50 h23 v1Suffix7, %1Suffix7%
	Gui Add, Edit, y+5        w50 h23 v1Suffix8, %1Suffix8%
	Gui Add, Edit, y+5        w50 h23 v1Suffix9, %1Suffix9%
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w300 h275											,Commands
	Gui,Font,
	Gui,Font,s9,Arial
	DefaultCommands := [ "/Hideout","/Menagerie","/Delve","/cls","/ladder","/reset_xp","/invite RecipientName","/kick RecipientName","@RecipientName Thanks for the trade!","@RecipientName Still Interested?","/kick CharacterName"]
	textList=
	For k, v in DefaultCommands
		textList .= (!textList ? "" : "|") v
	Gui Add, ComboBox, xs+4 ys+20 w290 v1Suffix1Text, %1Suffix1Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix2Text, %1Suffix2Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix3Text, %1Suffix3Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix4Text, %1Suffix4Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix5Text, %1Suffix5Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix6Text, %1Suffix6Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix7Text, %1Suffix7Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix8Text, %1Suffix8Text%||%textList%
	Gui Add, ComboBox,  y+5       w290 v1Suffix9Text, %1Suffix9Text%||%textList%
	Gui, Tab, Reply Whisper
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section  w60 h85											,Modifier
	Gui,Font,

	Tooltip, Loading GUI 85`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 

	Gui,Font,s9,Arial
	Gui Add, Edit, xs+4 ys+20 w50 h23 v2Prefix1, %2Prefix1%
	Gui Add, Edit, y+8        w50 h23 v2Prefix2, %2Prefix2%
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w60 h275											,Keys
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, ys+20 xs+4 w50 h23 v2Suffix1, %2Suffix1%
	Gui Add, Edit, y+5        w50 h23 v2Suffix2, %2Suffix2%
	Gui Add, Edit, y+5        w50 h23 v2Suffix3, %2Suffix3%
	Gui Add, Edit, y+5        w50 h23 v2Suffix4, %2Suffix4%
	Gui Add, Edit, y+5        w50 h23 v2Suffix5, %2Suffix5%
	Gui Add, Edit, y+5        w50 h23 v2Suffix6, %2Suffix6%
	Gui Add, Edit, y+5        w50 h23 v2Suffix7, %2Suffix7%
	Gui Add, Edit, y+5        w50 h23 v2Suffix8, %2Suffix8%
	Gui Add, Edit, y+5        w50 h23 v2Suffix9, %2Suffix9%
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w300 h275											,Whisper Reply
	Gui,Font,
	Gui,Font,s9,Arial
	DefaultWhisper := [ "/invite RecipientName","Sure, will invite in a sec.","In a map, will get to you in a minute.","Sorry, going to be a while.","No thank you.","Sold","/afk Sold to RecipientName"]
	textList=
	For k, v in DefaultWhisper
		textList .= (!textList ? "" : "|") v
	Gui Add, ComboBox, xs+4 ys+20 	w290 v2Suffix1Text, %2Suffix1Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix2Text, %2Suffix2Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix3Text, %2Suffix3Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix4Text, %2Suffix4Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix5Text, %2Suffix5Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix6Text, %2Suffix6Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix7Text, %2Suffix7Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix8Text, %2Suffix8Text%||%textList%
	Gui Add, ComboBox,  y+5			w290 v2Suffix9Text, %2Suffix9Text%||%textList%
	GuiControlGet MainGuiTabs
	GuiControl % (MainGuiTabs = "Chat") ? "Show" : "Hide", InnerTab
	WinSet Top,, ahk_id %InnerTab%

	Tooltip, Loading GUI 90`%,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
	Gui, +LastFound
	Gui, +AlwaysOnTop
	Menu, Tray, Tip, 				WingmanReloaded Dev Ver%VersionNumber%
	Menu, Tray, NoStandard
	Menu, Tray, Add, 				WingmanReloaded, optionsCommand
	Menu, Tray, Default, 			WingmanReloaded
	Menu, Tray, Add
	Menu, Tray, Add, 				Project Wiki, LaunchWiki
	Menu, Tray, Add
	Menu, Tray, Add, 				Make a Donation, LaunchDonate
	Menu, Tray, Add
	Menu, Tray, Add, 				Run Calibration Wizard, StartCalibrationWizard
	Menu, Tray, Add
	Menu, Tray, Add, 				Show Gamestates, ShowDebugGamestates
	Menu, Tray, Add
	Menu, Tray, Add, 				Open FindText interface, ft_Start
	Menu, Tray, Add
	Menu, Tray, add, 				Window Spy, WINSPY
	Menu, Tray, Add
	Menu, Tray, add, 				Reload This Script, RELOAD	
	Menu, Tray, add
	Menu, Tray, add, 				Exit, QuitNow ; added exit script option
	; Menu, Tray, NoStandard
	; Menu, Tray, Standard
	;Gui, Hide
	if ( Steam ) {
		if ( HighBits ) {
			executable := "PathOfExile_x64Steam.exe"
			} else {
			executable := "PathOfExileSteam.exe"
			}
		} else {
		if ( HighBits ) {
			executable := "PathOfExile_x64.exe"
			} else {
			executable := "PathOfExile.exe"
			}
		}

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
	Gui, ItemInfo: Add, Edit, vItemInfoPropText xp+2 ys+17 w358, %ItemInfoPropText%
	Gui, ItemInfo: Add, GroupBox, x+10 ys   h251 w364 , Item Statistics
	Gui, ItemInfo: Add, Edit, vItemInfoStatText xp+2 ys+17 w358, %ItemInfoStatText%
	Gui, ItemInfo: Add, GroupBox, x+9 ys  h251 w364 , Item Affixes
	Gui, ItemInfo: Add, Edit, vItemInfoAffixText xp+2 ys+17 w358, %ItemInfoAffixText%
	;Gui, ItemInfo: Show, AutoSize, % Prop.ItemName " Sparkline"
	;Gui, ItemInfo: Hide
	Tooltip, Loading GUI 100`%, %GuiX%, %GuiY%, 1 
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
	Thread, NoTimers, False		;Critical
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  END of Wingman Gui Settings
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  Grab Ninja Database, Start Scaling resolution values, and setup ignore slots
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; Rescale()
	Tooltip, Loading Ninja Database,% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
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
		Global WisdomStockX:=125
		Global PortalStockX:=175
		Global WPStockY:=262
		
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
	IfNotExist, %A_ScriptDir%\data\IgnoredSlot.json
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
		IfNotExist, %A_ScriptDir%\data\Ninja.json
		{
			For k, apiKey in apiList
				ScrapeNinjaData(apiKey)
			JSONtext := JSON.Dump(Ninja)
			FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
			IniWrite, %Date_now%, Settings.ini, Database, LastDatabaseParseDate
		}
		Else
		{
			If DaysSince()
			{
				For k, apiKey in apiList
				{
					ScrapeNinjaData(apiKey)
					Round((A_Index / apiList.MaxIndex()) * 100)
					Tooltip,% "Updating Ninja Database " Round((A_Index / apiList.MaxIndex()) * 100)"`%",% A_ScreenWidth - A_ScreenWidth,% A_ScreenHeight - 70, 1 
				}
					ScrapeNinjaData(apiKey)
				JSONtext := JSON.Dump(Ninja)
				FileDelete, %A_ScriptDir%\data\Ninja.json
				FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
				IniWrite, %Date_now%, Settings.ini, Database, LastDatabaseParseDate
				LastDatabaseParseDate := Date_now
			}
			Else
			{
				FileRead, JSONtext, %A_ScriptDir%\data\Ninja.json
				Ninja := JSON.Load(JSONtext)
			}
		}
	}
; Ingame Overlay (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Tooltip,

	Gui 2:Color, 0X130F13
	Gui 2:+LastFound +AlwaysOnTop +ToolWindow
	WinSet, TransColor, 0X130F13
	Gui 2: -Caption
	Gui 2:Font, bold cFFFFFF S10, Trebuchet MS
	Gui 2:Add, Text, y+0.5 BackgroundTrans vT1, Quit: OFF
	Gui 2:Add, Text, y+0.5 BackgroundTrans vT2, Flasks: OFF

	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		Gui 2: Show, x%GuiX% y%GuiY%, NoActivate 
		ToggleExist := True
		WinActivate, ahk_group POEGameGroup
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
	; Check for Flask presses
	SetTimer, TimerPassthrough, 15
	; Check for gems to level
	SetTimer, AutoSkillUp, 200
	; Detonate mines timer check
	If (DetonateMines&&!Detonated)
		SetTimer, TMineTick, 100
	Else If (!DetonateMines)
		SetTimer, TMineTick, off

; Hotkeys to reload or exit script
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	#IfWinActive
	; Reload Script with Alt+Escape
	!Escape::
		Reload
		Return

	; Exit Script with Win+Escape
	#Escape::
		ExitApp
		Return
    #IfWinActive, ahk_group POEGameGroup
	; Hotkey to pause the detonate mines
	#MaxThreadsPerHotkey, 1
	~d::
		KeyWait, d, T0.3 ; Wait .3 seconds until Detonate key is released.
		If ErrorLevel = 1 ; If not released, just exit out
			Exit
		KeyWait, d, D T0.2 ; ErrorLevel = 1 if Detonate Key not down within 0.2 seconds.
		if ((ErrorLevel = 0) && ( A_PriorHotKey = "~d" ) ) ; Is a double tap on Detonate key?
		{
			SetTimer, TDetonated, Delete
			Detonated := True
			Tooltip, Auto-Mines Paused, % A_ScreenWidth / 2 - 57, % A_ScreenHeight / 8
		}
		Else If (ErrorLevel = 1)
		{
			Detonated := False
			Tooltip
		}
	Return
	#MaxThreadsPerHotkey, 2
Return
; --------------------------------------------Function Section-----------------------------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Inventory Management Functions - ItemSortCommand, ClipItem, ParseClip, ItemInfo, MatchLootFilter, MatchNinjaPrice, GraphNinjaPrices, MoveStash, StockScrolls, LootScan
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; ItemSortCommand - Sort inventory and determine action
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ItemSortCommand:
		If RunningToggle  ; This means an underlying thread is already running the loop below.
		{
			RunningToggle := False  ; Signal that thread's loop to stop.
			exit  ; End this thread so that the one underneath will resume and see the change made by the line above.
		}
		Thread, NoTimers, true		;Critical
		MouseGetPos xx, yy
		IfWinActive, ahk_group POEGameGroup
		{
			RunningToggle := True
			GuiStatus("OnChar")
			GuiStatus("OnInventory")
			If (!OnChar) 
			{ ;Need to be on Character 
				MsgBox %  "You do not appear to be in game.`nLikely need to calibrate OnChar"
				RunningToggle := False
				Return
			} 
			Else If (!OnInventory&&OnChar) ; Click Stash or open Inventory
			{ 
				If (YesSearchForStash && (OnTown || OnHideout || OnMines))
				{
					If (FindStash:=FindText(GameX,GameY,GameW,GameH,0,0,StashStr))
					{
						LeftClick(FindStash.1.1 + 5,FindStash.1.2 + 5)
						Loop, 666
						{
							GuiStatus("OnStash")
							If OnStash
							Break
						}
					}
					Else
					{
						Send {%hotkeyInventory%}
						RunningToggle := False
						Return
					}
				}
				Else
				{
					Send {%hotkeyInventory%}
					RunningToggle := False
					Return
				}
			}
			GuiStatus("OnDiv")
			GuiStatus("OnStash")
			GuiStatus("OnVendor")
			If (OnDiv && YesDiv)
				DivRoutine()
			Else If (OnStash && YesStash)
				StashRoutine()
			Else If (OnVendor && YesVendor)
				VendorRoutine()
			Else If (OnInventory&&YesIdentify)
				IdentifyRoutine()
		}
		RunningToggle := False  ; Reset in preparation for the next press of this hotkey.
		RandomSleep(60,90)
		MouseMove, xx, yy, 0
	Return
	; VendorRoutine - Does vendor functions
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	VendorRoutine()
	{
		Thread, NoTimers, true		;Critical
		tQ := 0
		tGQ := 0
		SortFlask := {}
		SortGem := {}
		BlackList := Array_DeepClone(IgnoredSlot)
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
					Ding(500,1,"Hit Scroll")
					Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
				} 
				pixelgetcolor, PointColor, GridX, GridY
				
				If indexOf(PointColor, varEmptyInvSlotColor) {
					;Seems to be an empty slot, no need to clip item info
					Continue
				}
				
				ClipItem(Grid.X,Grid.Y)
				addToBlacklist(C, R)
				If (!Prop.Identified&&YesIdentify)
				{
					If (Prop.IsMap&&!YesMapUnid)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (Prop.Chromatic && (Prop.RarityRare || Prop.RarityUnique ) ) 
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If ( Prop.Jeweler && ( Prop.5Link || Prop.6Link || Prop.RarityRare || Prop.RarityUnique) )
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (!Prop.Chromatic && !Prop.Jeweler && !Prop.IsMap)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
				}
				If (OnVendor&&YesVendor)
				{
					If MatchLootFilter()
						Continue
					If (Prop.RarityCurrency)
						Continue
					If (Prop.RarityUnique && (Prop.Ring||Prop.Amulet||Prop.Jewel||Prop.Flask))
						Continue
					If ( Prop.Flask && ( Stats.Quality > 0 ))
					{
						If Stats.Quality >= 20
							Q := 40 
						Else 
							Q := Stats.Quality
						tQ += Q
						SortFlask.Push({"C":C,"R":R,"Q":Q})
						Continue
					}
					If ( Prop.RarityGem && ( Stats.Quality > 0 ))
					{
						If Stats.Quality >= 20
							Continue 
						Else 
							Q := Stats.Quality
						Q := Stats.Quality
						tGQ += Q
						SortGem.Push({"C":C,"R":R,"Q":Q})
						Continue
					}
					If ( Prop.SpecialType="" )
					{
						Sleep, 30*Latency
						CtrlClick(Grid.X,Grid.Y)
						Sleep, 10*Latency
						Continue
					}
				}
			}
			; Move mouse out of the way after a column
			MouseGetPos Checkx, Checky
			If (((Checkx<InventoryGridX[12])&&(Checkx>InventoryGridX[1]))&&((Checky<InventoryGridY[5])&&(Checky>InventoryGridY[1]))){
				Random, RX, (A_ScreenWidth*0.2), (A_ScreenWidth*0.6)
				Random, RY, (A_ScreenHeight*0.1), (A_ScreenHeight*0.8)
				MouseMove, RX, RY, 0
				Sleep, 45*Latency
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
					RandomSleep(45,90)
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
					RandomSleep(45,90)
				}
			}
		}
		Return
	}
	; StashRoutine - Does stash functions
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	StashRoutine()
	{
		Thread, NoTimers, true		;Critical
		CurrentTab:=0
		SortFirst := {}
		Loop 32
		{
			SortFirst[A_Index] := {}
		}
		BlackList := Array_DeepClone(IgnoredSlot)
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
					Ding(500,1,"Hit Scroll")
					Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
				} 
				pixelgetcolor, PointColor, GridX, GridY
				
				If indexOf(PointColor, varEmptyInvSlotColor) {
					;Seems to be an empty slot, no need to clip item info
					Continue
				}
				
				ClipItem(Grid.X,Grid.Y)
				addToBlacklist(C, R)
				If (!Prop.Identified&&YesIdentify)
				{
					If (Prop.IsMap&&!YesMapUnid)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (Prop.Chromatic && (Prop.RarityRare || Prop.RarityUnique ) ) 
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If ( Prop.Jeweler && ( Prop.5Link || Prop.6Link || Prop.RarityRare || Prop.RarityUnique) )
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (!Prop.Chromatic && !Prop.Jeweler && !Prop.IsMap)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
				}
				If (OnStash && YesStash && !YesSortFirst) 
				{
					If (sendstash:=MatchLootFilter())
					{
						MoveStash(sendstash)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.RarityCurrency&&Prop.SpecialType=""&&StashTabYesCurrency)
					{
						MoveStash(StashTabCurrency)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.IsMap&&StashTabYesMap)
					{
						MoveStash(StashTabMap)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.BreachSplinter&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.SacrificeFragment&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.MortalFragment&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.GuardianFragment&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.ProphecyFragment&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Offering&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Vessel&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Scarab&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.TimelessSplinter&&StashTabYesFragment)
					{
						MoveStash(StashTabFragment)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.RarityDivination&&StashTabYesDivination)
					{
						MoveStash(StashTabDivination)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.RarityUnique&&Prop.Ring)
					{
						If (StashTabYesCollection)
						{
							MoveStash(StashTabCollection)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueRing)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueRing)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueDump)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueDump)
							CtrlClick(Grid.X,Grid.Y)
						}
						Continue
					}
					Else If (Prop.RarityUnique)
					{
						If (StashTabYesCollection)
						{
							MoveStash(StashTabCollection)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueDump)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueDump)
							CtrlClick(Grid.X,Grid.Y)
						}
						Continue
					}
					Else If (Prop.Essence&&StashTabYesEssence)
					{
						MoveStash(StashTabEssence)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Fossil&&StashTabYesFossil)
					{
						MoveStash(StashTabFossil)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Resonator&&StashTabYesResonator)
					{
						MoveStash(StashTabResonator)
						RandomSleep(30,45)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Flask&&(Stats.Quality>0)&&StashTabYesFlaskQuality)
					{
						MoveStash(StashTabFlaskQuality)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.RarityGem)
					{
						If ((Stats.Quality>0)&&StashTabYesGemQuality)
						{
							MoveStash(StashTabGemQuality)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						Else If (StashTabYesGem)
						{
							MoveStash(StashTabGem)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
					}
					Else If ((Prop.5Link||Prop.6Link)&&StashTabYesLinked)
					{
						MoveStash(StashTabLinked)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Prophecy&&StashTabYesProphecy)
					{
						MoveStash(StashTabProphecy)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Oil&&StashTabYesOil)
					{
						MoveStash(StashTabOil)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If (Prop.Veiled&&StashTabYesVeiled)
					{
						MoveStash(StashTabVeiled)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else If StashTabYesCrafting 
						&& ((YesStashT1 && Prop.CraftingBase = "T1") 
							|| (YesStashT2 && Prop.CraftingBase = "T2") 
							|| (YesStashT3 && Prop.CraftingBase = "T3"))
						&& ((YesStashCraftingNormal && Prop.RarityNormal)
							|| (YesStashCraftingMagic && Prop.RarityMagic)
							|| (YesStashCraftingRare && Prop.RarityRare))
					{
						MoveStash(StashTabCrafting)
						CtrlClick(Grid.X,Grid.Y)
						Continue
					}
					Else
						++Unstashed
				}
				If (OnStash && YesStash && YesSortFirst) 
				{
					If (sendstash:=MatchLootFilter())
					{
						SortFirst[sendstash].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.RarityCurrency&&Prop.SpecialType=""&&StashTabYesCurrency)
					{
						SortFirst[StashTabCurrency].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.IsMap&&StashTabYesMap)
					{
						SortFirst[StashTabMap].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.BreachSplinter&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.SacrificeFragment&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					If (Prop.MortalFragment&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.GuardianFragment&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.ProphecyFragment&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Offering&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Vessel&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Scarab&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.TimelessSplinter&&StashTabYesFragment)
					{
						SortFirst[StashTabFragment].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.RarityDivination&&StashTabYesDivination)
					{
						SortFirst[StashTabDivination].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.RarityUnique&&Prop.Ring)
					{
						If (StashTabYesCollection)
						{
							MoveStash(StashTabCollection)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueRing)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueRing)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueDump)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueDump)
							CtrlClick(Grid.X,Grid.Y)
						}
						Continue
					}
					Else If (Prop.RarityUnique)
					{
						If (StashTabYesCollection)
						{
							MoveStash(StashTabCollection)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
						}
						If (StashTabYesUniqueDump)
						{
							Sleep, 200*Latency
							pixelgetcolor, Pitem, GridX, GridY
							if (indexOfHex(Pitem, varEmptyInvSlotColor))
								Continue
							MoveStash(StashTabUniqueDump)
							CtrlClick(Grid.X,Grid.Y)
						}
						Continue
					}
					Else If (Prop.Essence&&StashTabYesEssence)
					{
						SortFirst[StashTabEssence].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Fossil&&StashTabYesFossil)
					{
						SortFirst[StashTabFossil].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Resonator&&StashTabYesResonator)
					{
						SortFirst[StashTabResonator].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Flask&&(Stats.Quality>0)&&StashTabYesFlaskQuality)
					{
						SortFirst[StashTabFlaskQuality].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.RarityGem)
					{
						If ((Stats.Quality>0)&&StashTabYesGemQuality)
						{
							SortFirst[StashTabGemQuality].Push({"C":C,"R":R})
							Continue
						}
						Else If (StashTabYesGem)
						{
							SortFirst[StashTabGem].Push({"C":C,"R":R})
							Continue
						}
					}
					Else If ((Prop.5Link||Prop.6Link)&&StashTabYesLinked)
					{
						SortFirst[StashTabLinked].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Prophecy&&StashTabYesProphecy)
					{
						SortFirst[StashTabProphecy].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Oil&&StashTabYesOil)
					{
						SortFirst[StashTabOil].Push({"C":C,"R":R})
						Continue
					}
					Else If (Prop.Veiled&&StashTabYesVeiled)
					{
						SortFirst[StashTabVeiled].Push({"C":C,"R":R})
						Continue
					}
					Else If StashTabYesCrafting 
						&& ((YesStashT1 && Prop.CraftingBase = "T1") 
							|| (YesStashT2 && Prop.CraftingBase = "T2") 
							|| (YesStashT3 && Prop.CraftingBase = "T3"))
						&& ((YesStashCraftingNormal && Prop.RarityNormal)
							|| (YesStashCraftingMagic && Prop.RarityMagic)
							|| (YesStashCraftingRare && Prop.RarityRare))
					{
						SortFirst[StashTabCrafting].Push({"C":C,"R":R})
						Continue
					}
					Else
						++Unstashed
				}
			}
			MouseGetPos Checkx, Checky
			If (((Checkx<InventoryGridX[12])&&(Checkx>InventoryGridX[1]))&&((Checky<InventoryGridY[5])&&(Checky>InventoryGridY[1]))){
				Random, RX, (A_ScreenWidth*0.2), (A_ScreenWidth*0.6)
				Random, RY, (A_ScreenHeight*0.1), (A_ScreenHeight*0.8)
				MouseMove, RX, RY, 0
				Sleep, 45*Latency
			}
		}
		; Sorted items are sent together
		If (OnStash && RunningToggle && YesStash && !YesSortFirst)
		{
			If (YesVendorAfterStash && Unstashed && OnHideout)
			{
				If (OnStash && RunningToggle && YesStash && (StockPortal||StockWisdom))
					StockScrolls()
				SendInput, {%hotkeyCloseAllUI%}
				Sleep, 45*Latency
				if (Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, VendorStr))
				{
					LeftClick(Vendor.1.1, Vendor.1.2)
				}
				If Vendor
				{
					Loop, 666
					{
						If (Sell:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SellItemsStr))
						{
							LeftClick(Sell.1.1 + 5,Sell.1.2 + 5)
							Sleep, 60*Latency
							Break
						}
					}
					GuiStatus("OnStash")
					GuiStatus("OnVendor")
					VendorRoutine()
					Return
				}
			}
		}
		If (OnStash && RunningToggle && YesStash && YesSortFirst)
		{
			For Tab, Tv in SortFirst
			{
				For Item, Iv in Tv
				{
					MoveStash(Tab)
					C := SortFirst[Tab][Item]["C"]
					R := SortFirst[Tab][Item]["R"]
					GridX := InventoryGridX[C]
					GridY := InventoryGridY[R]
					Grid := RandClick(GridX, GridY)
					CtrlClick(Grid.X,Grid.Y)
					Sleep, 45*Latency
				}
			}
			If (YesVendorAfterStash && Unstashed && OnHideout)
			{
				If (OnStash && RunningToggle && YesStash && (StockPortal||StockWisdom))
					StockScrolls()
				SendInput, {%hotkeyCloseAllUI%}
				Sleep, 45*Latency
				if (Vendor:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, VendorStr))
				{
					LeftClick(Vendor.1.1, Vendor.1.2)
				}
				If Vendor
				{
					Loop, 666
					{
						If (Sell:=FindText( GameX, GameY, GameX + GameW, GameY + GameH, 0, 0, SellItemsStr))
						{
							LeftClick(Sell.1.1 + 5,Sell.1.2 + 5)
							Sleep, 60*Latency
							Break
						}
					}
					GuiStatus("OnStash")
					GuiStatus("OnVendor")
					VendorRoutine()
					Return
				}
			}
		}
		If (OnStash && RunningToggle && YesStash && (StockPortal||StockWisdom))
			StockScrolls()
		Return
	}
	; DivRoutine - Does divination trading function
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DivRoutine()
	{
		Thread, NoTimers, true		;Critical
		BlackList := Array_DeepClone(IgnoredSlot)
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
					Ding(500,1,"Hit Scroll")
					Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
				} 
				pixelgetcolor, PointColor, GridX, GridY
				
				If indexOf(PointColor, varEmptyInvSlotColor) {
					;Seems to be an empty slot, no need to clip item info
					Continue
				}
				
				ClipItem(Grid.X,Grid.Y)
				addToBlacklist(C, R)
				; Trade full div stacks
				If (OnDiv && YesDiv) 
				{
					If (Prop.RarityDivination && (Stats.Stack = Stats.StackMax)){
						CtrlClick(Grid.X,Grid.Y)
						RandomSleep(150,200)
						LeftClick(vX_OnDiv,vY_DivTrade)
						CtrlClick(vX_OnDiv,vY_DivItem)
					}
					Continue
				}
			}
			; Move mouse out of the way after a column
			MouseGetPos Checkx, Checky
			If (((Checkx<InventoryGridX[12])&&(Checkx>InventoryGridX[1]))&&((Checky<InventoryGridY[5])&&(Checky>InventoryGridY[1]))){
				Random, RX, (A_ScreenWidth*0.2), (A_ScreenWidth*0.6)
				Random, RY, (A_ScreenHeight*0.1), (A_ScreenHeight*0.8)
				MouseMove, RX, RY, 0
				Sleep, 45*Latency
			}
		}
		Return
	}
	; IdentifyRoutine - Does basic function when not at other windows
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IdentifyRoutine()
	{
		Thread, NoTimers, true		;Critical
		BlackList := Array_DeepClone(IgnoredSlot)
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
					Ding(500,1,"Hit Scroll")
					Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
				} 
				pixelgetcolor, PointColor, GridX, GridY
				
				If indexOf(PointColor, varEmptyInvSlotColor) {
					;Seems to be an empty slot, no need to clip item info
					Continue
				}
				
				ClipItem(Grid.X,Grid.Y)
				addToBlacklist(C, R)
				; Trade full div stacks
				If (!Prop.Identified&&YesIdentify)
				{
					If (Prop.IsMap&&!YesMapUnid)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (Prop.Chromatic && (Prop.RarityRare || Prop.RarityUnique ) ) 
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If ( Prop.Jeweler && ( Prop.5Link || Prop.6Link || Prop.RarityRare || Prop.RarityUnique) )
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
					Else If (!Prop.Chromatic && !Prop.Jeweler && !Prop.IsMap)
					{
						WisdomScroll(Grid.X,Grid.Y)
						ClipItem(Grid.X,Grid.Y)
					}
				}
			}
			; Move mouse out of the way after a column
			MouseGetPos Checkx, Checky
			If (((Checkx<InventoryGridX[12])&&(Checkx>InventoryGridX[1]))&&((Checky<InventoryGridY[5])&&(Checky>InventoryGridY[1]))){
				Random, RX, (A_ScreenWidth*0.2), (A_ScreenWidth*0.6)
				Random, RY, (A_ScreenHeight*0.1), (A_ScreenHeight*0.8)
				MouseMove, RX, RY, 0
				Sleep, 45*Latency
			}
		}
		Return
	}
	; ClipItem - Capture Clip at Coord
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ClipItem(x, y){
			BlockInput, MouseMove
			Clipboard := ""
			MouseMove %x%, %y%
			Sleep, 90*Latency
			Send ^c
			ClipWait, 0
			ParseClip()
			BlockInput, MouseMoveOff
		Return
		}
	; ParseClip - Checks the contents of the clipboard and parses the information from the tooltip capture
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ParseClip(){
		;Reset Variables
		NameIsDone := False
		IgnoreDash := False
		itemLevelIsDone := 0
		captureLines := 0
		countCorruption := 0
		doneCorruption := False
		Prop := {ItemName: ""
			, IsItem : False
			, IsWeapon : False
			, IsMap : False
			, ShowAffix : False
			, Rarity : ""
			, SpecialType : ""
			, RarityCurrency : False
			, RarityDivination : False
			, RarityGem : False
			, RarityNormal : False
			, RarityMagic : False
			, RarityRare : False
			, RarityUnique : False
			, Identified : True
			, Ring : False
			, Amulet : False
			, Belt : False
			, Chromatic : False
			, Jewel : False
			, AbyssJewel : False
			, Essence : False
			, Incubator : False
			, Fossil : False
			, Resonator : False
			, Sockets : 0
			, RawSockets : ""
			, LinkCount : 0
			, 2Link : False
			, 3Link : False
			, 4Link : False
			, 5Link : False
			, 6Link : False
			, Jeweler : False
			, TimelessSplinter : False
			, BreachSplinter : False
			, SacrificeFragment : False
			, MortalFragment : False
			, GuardianFragment : False
			, ProphecyFragment : False
			, Scarab : False
			, Offering : False
			, Vessel : False
			, Incubator : False
			, Flask : False
			, Veiled : False
			, Prophecy : False
			, Oil : False
			, Corrupted : False
			, DoubleCorrupted : False
			, Width : 1
			, Height : 1
			, Variant : 0
			, CraftingBase : 0
			, DropLevel : 0
			, ItemLevel : 0}

		Stats := { PhysLo : False
			, PhysHi : False
			, AttackSpeed : False
			, PhysMult : False
			, PhysDps : False
			, EleDps : False
			, TotalDps : False
			, ChaosLo : False
			, ChaosHi : False
			, EleLo : False
			, EleHi : False
			, TotalPhysMult : False
			, BasePhysDps : False
			, Q20Dps : False
			, ItemClass : ""
			, Quality : 0
			, GemLevel : 0
			, Stack : 0
			, StackMax : 0
			, RequiredLevel : 0
			, RequiredStr : 0
			, RequiredInt : 0
			, RequiredDex : 0
			, RatingArmour : 0
			, RatingEnergyShield : 0
			, RatingEvasion : 0
			, RatingBlock : 0
			, MapTier : 0
			, MapItemQuantity : 0
			, MapItemRarity : 0
			, MapMonsterPackSize : 0 }

		Affix := { SupportGem : ""
			, SupportGemLevel : 0
			, CountSupportGem : 0
			, AllElementalResistances : 0
			, ColdLightningResistance : 0
			, FireColdResistance : 0
			, FireLightningResistance : 0
			, ColdResistance : 0
			, FireResistance : 0
			, LightningResistance : 0
			, ChaosResistance : 0
			, MaximumLife : 0
			, IncreasedMaximumLife : 0
			, MaximumEnergyShield : 0
			, IncreasedEnergyShield : 0
			, MaximumMana : 0
			, IncreasedMaximumMana : 0
			, IncreasedAttackSpeed : 0
			, IncreasedColdDamage : 0
			, IncreasedFireDamage : 0
			, IncreasedLightningDamage : 0
			, IncreasedPhysicalDamage : 0
			, IncreasedSpellDamage : 0
			, IncreasedChaosDamage : 0
			, PseudoColdResist : 0
			, PseudoFireResist : 0
			, PseudoLightningResist : 0
			, PseudoChaosResist : 0
			, PseudoTotalEleResist : 0
			, PseudoTotalResist : 0
			, PseudoTotalEleResist : 0
			, LifeRegeneration : 0
			, ChanceDoubleDamage : 0
			, IncreasedRarity : 0
			, IncreasedEvasion : 0
			, IncreasedArmour : 0
			, IncreasedAttackSpeed : 0
			, IncreasedAttackCastSpeed : 0
			, IncreasedMovementSpeed : 0
			, ReducedEnemyStunThreshold : 0
			, IncreasedStunBlockRecovery : 0
			, LifeGainOnAttack : 0
			, WeaponRange : 0
			, AddedIntelligence : 0
			, AddedStrength : 0
			, AddedDexterity : 0
			, AddedStrengthDexterity : 0
			, AddedStrengthIntelligence : 0
			, AddedDexterityIntelligence : 0
			, AddedArmour : 0
			, AddedEvasion : 0
			, AddedAccuracy : 0
			, AddedAllStats : 0
			, PseudoAddedStrength : 0
			, PseudoAddedDexterity : 0
			, PseudoAddedIntelligence : 0
			, IncreasedArmourEnergyShield : 0
			, IncreasedArmourEvasion : 0
			, IncreasedEvasionEnergyShield : 0
			, PseudoIncreasedArmour : 0
			, PseudoIncreasedEvasion : 0
			, PseudoIncreasedEnergyShield : 0
			, ChanceDodgeAttack : 0
			, ChanceDodgeSpell : 0
			, ChanceBlockSpell : 0
			, BlockManaGain : 0
			, PhysicalDamageReduction : 0
			, ReducedAttributeRequirement : 0
			, ReflectPhysical : 0
			, EnergyShieldRegen : 0
			, PhysicalLeechLife : 0
			, PhysicalLeechMana : 0
			, OnKillLife : 0
			, OnKillMana : 0
			, IncreasedElementalAttack : 0
			, IncreasedFlaskLifeRecovery : 0
			, IncreasedFlaskManaRecovery : 0
			, IncreasedStunDuration : 0
			, IncreasedFlaskDuration : 0
			, IncreasedFlaskChargesGained : 0
			, ReducedFlaskChargesUsed : 0
			, GlobalCriticalChance : 0
			, GlobalCriticalMultiplier : 0
			, IncreasedProjectileSpeed : 0
			, AddedLevelGems : 0
			, AddedLevelMinionGems : 0
			, AddedLevelMeleeGems : 0
			, AddedLevelBowGems : 0
			, AddedLevelFireGems : 0
			, AddedLevelColdGems : 0
			, AddedLevelLightningGems : 0
			, AddedLevelChaosGems : 0
			, ChaosDOTMult : 0
			, ColdDOTMult : 0
			, ChanceFreeze : 0
			, ChanceShock : 0
			, ChanceIgnite : 0
			, ChanceAvoidElementalAilment : 0
			, ChanceIgnite : 0
			, ChanceIgnite : 0
			, ChanceIgnite : 0
			, IncreasedBurningDamage : 0
			, IncreasedSpellCritChance : 0
			, IncreasedCritChance : 0
			, IncreasedManaRegeneration : 0
			, IncreasedCastSpeed : 0
			, IncreasedPoisonDuration : 0
			, ChancePoison : 0
			, IncreasedPoisonDamage : 0
			, IncreasedBleedDuration : 0
			, ChanceBleed : 0
			, IncreasedBleedDamage : 0
			, IncreasedLightRadius : 0
			, IncreasedGlobalAccuracy : 0
			, ChanceBlock : 0
			, GainFireToExtraChaos : 0
			, GainColdToExtraChaos : 0
			, GainLightningToExtraChaos : 0
			, GainPhysicalToExtraChaos : 0
			, Implicit : ""
			, PseudoTotalAddedAvg : 0
			, PseudoTotalAddedEleAvg : 0}

		
		;Begin parsing information	
		Loop, Parse, Clipboard, `n, `r
		{
			; Clipboard must have "Rarity:" in the first line
			If A_Index = 1
			{
				IfNotInString, A_LoopField, Rarity:
				{
					Exit
				}
				Else
				{
					Prop.IsItem := True
					IfInString, A_LoopField, Currency
					{
						Prop.RarityCurrency := True
						Prop.Rarity := "Currency"
					}
					IfInString, A_LoopField, Divination Card
					{
						Prop.RarityDivination := True
						Prop.Rarity := "Divination Card"
						Prop.SpecialType := "Divination Card"
					}
					IfInString, A_LoopField, Gem
					{
						Prop.RarityGem := True
						Prop.Rarity := "Gem"
						Prop.SpecialType := "Gem"
					}
					IfInString, A_LoopField, Normal
					{
						Prop.RarityNormal := True
						Prop.Rarity := "Normal"
					}
					IfInString, A_LoopField, Magic
					{
						Prop.RarityMagic := True
						Prop.Rarity := "Magic"
					}
					IfInString, A_LoopField, Rare
					{
						Prop.RarityRare := True
						Prop.Rarity := "Rare"
					}
					IfInString, A_LoopField, Unique
					{
						Prop.RarityUnique := True
						Prop.Rarity := "Unique"
					}
					Continue
				}
			}
				
			; Get name
			If Not NameIsDone
			{
				If A_LoopField = --------
				{
					If !IgnoreDash
						NameIsDone := True
					Else
					{
						IgnoreDash := False
						Continue
					}
				}
				Else if A_LoopField = You cannot use this item. Its stats will be ignored
				{
					IgnoreDash := True
					Continue
				}
				Else
				{
					Prop.ItemName := Prop.ItemName . A_LoopField . "`n" ; Add a line of name
					Prop.ItemName := StrReplace(Prop.ItemName, "<<set:MS>><<set:M>><<set:S>>", "")
					StandardBase := StrReplace(A_LoopField, "Superior ", "")
					StandardBase := StrReplace(StandardBase, "<<set:MS>><<set:M>><<set:S>>", "")
					PossibleBase := StrSplit(StandardBase, " of ")
					StandardBase := PossibleBase[1]
					PossibleBase := StrSplit(PossibleBase[1], " ",,2)
					PrefixMagicBase := PossibleBase[2]

					For k, v in Bases
					{
						If (Bases[k]["name"] = StandardBase) || (Bases[k]["name"] = PrefixMagicBase)
						{
							Prop.Width := Bases[k]["inventory_width"]
							Prop.Height := Bases[k]["inventory_height"]
							Stats.ItemClass := Bases[k]["item_class"]
							Prop.ItemBase := Bases[k]["name"]
							Prop.DropLevel := Bases[k]["drop_level"]
							Break
						}
					}
					IfInString, A_LoopField, Ring
					{
						IfNotInString, A_LoopField, Ringmail
						{
							Prop.Ring := True
							Stats.ItemClass := "Rings"
							Continue
						}
					}
					IfInString, A_LoopField, Amulet
					{
						Prop.Amulet := True
						Continue
					}
					IfInString, A_LoopField, Map
					{
						Prop.IsMap := True
						Prop.SpecialType := "Map"
						Stats.ItemClass := "Maps"
						Continue
					}
					IfInString, A_LoopField, Incubator
					{
						Prop.Incubator := True
						Prop.SpecialType := "Incubator"
						Continue
					}
					IfInString, A_LoopField, Timeless Karui Splinter
					{
						Prop.TimelessSplinter := True
						Prop.SpecialType := "Timeless Splinter"
						Continue
					}
					IfInString, A_LoopField, Timeless Eternal Empire Splinter
					{
						Prop.TimelessSplinter := True
						Prop.SpecialType := "Timeless Splinter"
						Continue
					}
					IfInString, A_LoopField, Timeless Vaal Splinter
					{
						Prop.TimelessSplinter := True
						Prop.SpecialType := "Timeless Splinter"
						Continue
					}
					IfInString, A_LoopField, Timeless Templar Splinter
					{
						Prop.TimelessSplinter := True
						Prop.SpecialType := "Timeless Splinter"
						Continue
					}
					IfInString, A_LoopField, Timeless Maraketh Splinter
					{
						Prop.TimelessSplinter := True
						Prop.SpecialType := "Timeless Splinter"
						Continue
					}
					IfInString, A_LoopField, Splinter of
					{
						Prop.BreachSplinter := True
						Prop.SpecialType := "Breach Splinter"
						Continue
					}
					IfInString, A_LoopField, Breachstone
					{
						Prop.BreachSplinter := True
						Prop.SpecialType := "Breachstone"
						Continue
					}
					IfInString, A_LoopField, Sacrifice at
					{
						Prop.SacrificeFragment := True
						Prop.SpecialType := "Sacrifice Fragment"
						Continue
					}
					IfInString, A_LoopField, Mortal Grief
					{
						Prop.MortalFragment := True
						Prop.SpecialType := "Mortal Fragment"
						Continue
					}
					IfInString, A_LoopField, Mortal Hope
					{
						Prop.MortalFragment := True
						Prop.SpecialType := "Mortal Fragment"
						Continue
					}
					IfInString, A_LoopField, Mortal Ignorance
					{
						Prop.MortalFragment := True
						Prop.SpecialType := "Mortal Fragment"
						Continue
					}
					IfInString, A_LoopField, Mortal Rage
					{
						Prop.MortalFragment := True
						Prop.SpecialType := "Mortal Fragment"
						Continue
					}
					IfInString, A_LoopField, Fragment of the
					{
						Prop.GuardianFragment := True
						Prop.SpecialType := "Guardian Fragment"
						Continue
					}
					IfInString, A_LoopField, Volkuur's Key
					{
						Prop.ProphecyFragment := True
						Prop.SpecialType := "Prophecy Fragment"
						Continue
					}
					IfInString, A_LoopField, Eber's Key
					{
						Prop.ProphecyFragment := True
						Prop.SpecialType := "Prophecy Fragment"
						Continue
					}
					IfInString, A_LoopField, Yriel's Key
					{
						Prop.ProphecyFragment := True
						Prop.SpecialType := "Prophecy Fragment"
						Continue
					}
					IfInString, A_LoopField, Inya's Key
					{
						Prop.ProphecyFragment := True
						Prop.SpecialType := "Prophecy Fragment"
						Continue
					}
					IfInString, A_LoopField, Scarab
					{
						Prop.Scarab := True
						Prop.SpecialType := "Scarab"
						Continue
					}
					IfInString, A_LoopField, Offering to the Goddess
					{
						Prop.Offering := True
						Prop.SpecialType := "Offering"
						Continue
					}
					IfInString, A_LoopField, Essence of
					{
						Prop.Essence := True
						Prop.SpecialType := "Essence"
						Continue
					}
					IfInString, A_LoopField, Remnant of Corruption
					{
						Prop.Essence := True
						Prop.SpecialType := "Essence"
						Continue
					}
					IfInString, A_LoopField, Incubator
					{
						Prop.Incubator := True
						Prop.SpecialType := "Incubator"
						Continue
					}
					IfInString, A_LoopField, Fossil
					{
						IfNotInString, A_LoopField, Fossilised
						{
							Prop.Fossil := True
							Prop.SpecialType := "Fossil"
							Continue
						}
					}
					IfInString, A_LoopField, Resonator
					{
						Prop.Resonator := True
						Prop.SpecialType := "Resonator"
						Continue
					}
					IfInString, A_LoopField, Divine Vessel
					{
						Prop.Vessel := True
						Prop.SpecialType := "Divine Vessel"
						Continue
					}
					IfInString, A_LoopField, Eye Jewel
					{
						Prop.AbyssJewel := True
						Prop.Jewel := True
						Continue
					}
					IfInString, A_LoopField, Cobalt Jewel
					{
						Prop.Jewel := True
						Continue
					}
					IfInString, A_LoopField, Crimson Jewel
					{
						Prop.Jewel := True
						Continue
					}
					IfInString, A_LoopField, Viridian Jewel
					{
						Prop.Jewel := True
						Continue
					}
					IfInString, A_LoopField, Flask
					{
						Prop.Flask := True
						Stats.ItemClass := "Flasks"
						Prop.Width := 1
						Prop.Height := 2
						Continue
					}
					IfInString, A_LoopField, Quiver
					{
						Prop.Quiver := True
						Stats.ItemClass := "Quivers"
						Prop.Width := 2
						Prop.Height := 3
						Continue
					}
					IfInString, A_LoopField, Oil
					{
						If Prop.RarityCurrency
						{
							Prop.Oil := True
							Prop.SpecialType := "Oil"
							Continue
						}
					}
				}
				Continue
			}

			; Get Requirements

			IfInString, A_LoopField, Requirements:
			{
				ReqSect := True
				Continue
			}
			If ReqSect
			{
				IfInString, A_LoopField, Level:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredLevel := arr2
					Continue
				}
				IfInString, A_LoopField, Str:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredStr := arr2
					Continue
				}
				IfInString, A_LoopField, Strength:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredStr := arr2
					Continue
				}
				IfInString, A_LoopField, Int:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredInt := arr2
					Continue
				}
				IfInString, A_LoopField, Intelligence:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredInt := arr2
					Continue
				}
				IfInString, A_LoopField, Dex:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredDex := arr2
					Continue
				}
				IfInString, A_LoopField, Dexterity:
				{
					StringSplit, arr, A_LoopField, %A_Space%
					Stats.RequiredDex := arr2
					Continue
				}
				If A_LoopField = --------
					ReqSect := False
			}
			; Get Total Rating of the item
			IfInString, A_LoopField, Armour:
			{
				StringSplit, arr, A_LoopField, %A_Space%
				Stats.RatingArmour := arr2
				Continue
			}
			IfInString, A_LoopField, Energy Shield:
			{
				StringSplit, arr, A_LoopField, %A_Space%
				Stats.RatingEnergyShield := arr3
				Continue
			}
			IfInString, A_LoopField, Evasion Rating:
			{
				StringSplit, arr, A_LoopField, %A_Space%
				Stats.RatingEvasion := arr3
				Continue
			}
			IfInString, A_LoopField, Chance to Block:
			{
				StringSplit, arr, A_LoopField, %A_Space%, `%
				Stats.RatingBlock := arr4
				Continue
			}
			; Get quality
			IfInString, A_LoopField, Quality:
			{
				StringSplit, QualityArray, A_LoopField, %A_Space%, +`%
				Stats.Quality := QualityArray2
				Continue
			}
			; Get Socket Information
			IfInString, A_LoopField, Sockets:
			{
				StringSplit, RawSocketsArray, A_LoopField, %A_Space%
				Prop.RawSockets := RawSocketsArray2 . A_Space . RawSocketsArray3 . A_Space . RawSocketsArray4 . A_Space . RawSocketsArray5 . A_Space . RawSocketsArray6 . A_Space . RawSocketsArray7
				For k, v in StrSplit(Prop.RawSockets, " ") 
				{		
					if (v ~= "B") && (v ~= "G") && (v ~= "R")
						Prop.Chromatic := True
					Loop, Parse, v
						Counter++
					If (Counter=11)
					{
						Prop.6Link:=True
						Prop.SpecialType := "6Link"
					}
					Else If (Counter=9)
					{
						Prop.5Link:=True
						Prop.SpecialType := "5Link"
					}
					Else If (Counter=7)
					{
						Prop.4Link:=True
					}
					Else If (Counter=5)
					{
						Prop.3Link:=True
					}
					Else If (Counter=3)
					{
						Prop.2Link:=True
					}
					Counter:=0
				}
				Loop, parse, A_LoopField
				{
					if (A_LoopField ~= "[-]")
						Prop.LinkCount++
				}
				Loop, parse, A_LoopField
				{
					if (A_LoopField ~= "[BGR]")
						Prop.Sockets++
				}
				If (Prop.Sockets = 6)
					Prop.Jeweler:=True
				Continue
			}
			; Get item level
			IfInString, A_LoopField, Item Level:
			{
				StringSplit, ItemLevelArray, A_LoopField, %A_Space%
				Prop.ItemLevel := ItemLevelArray3
				itemLevelIsDone := 1
				Continue
			}
			; Get Gem Level
			If Prop.RarityGem && !Stats.GemLevel
			{
				IfInString, A_LoopField, Level:
				{
					StringSplit, GemLevelArray, A_LoopField, %A_Space%
					Stats.GemLevel := GemLevelArray2
					Continue
				}
			}
			;Capture Implicit and Affixes after the Item Level
			If (itemLevelIsDone > 0 && itemLevelIsDone < 4) {
				If InStr(A_LoopField, "----")
				{
					++itemLevelIsDone
					If (itemLevelIsDone = 3 && captureLines = 1){
						Prop.HasAffix := True
						Affix.Implicit := possibleImplicit
					}
					Else If (itemLevelIsDone = 2 && countCorruption > 0 && !doneCorruption && captureLines < 3){
						doneCorruption := True
						captureLines := 1
					}
					Else If (!Affix.Implicit && itemLevelIsDone = 3 && captureLines > 0){
						Prop.HasAffix := True
					}
					Else If (Affix.Implicit && itemLevelIsDone = 4 && captureLines > 0){
						Prop.HasAffix := True
					}
				}
				Else
				{
					If (itemLevelIsDone=2 && !Affix.LabEnchant && captureLines < 1) {
						imp := RegExReplace(A_LoopField, "i)([-.0-9]+)", "#")
						if (indexOf(imp, Enchantment)) 
						{
							Affix.LabEnchant := A_LoopField
							itemLevelIsDone := 1
							Continue
						}
					}
					If (itemLevelIsDone=2 && !Affix.TalismanTier && captureLines < 1) {
						IfInString, A_LoopField, Talisman Tier:
						{	
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.TalismanTier := Arr3
							itemLevelIsDone := 1
						Continue
						}
					}
					If (itemLevelIsDone=2 && !Affix.Annointment && captureLines < 1) {
						IfInString, A_LoopField, Allocates
						{	
							Arr := StrSplit(A_LoopField, "Allocates ")
							Affix.Annointment := Arr[2]
							itemLevelIsDone := 1
						Continue
						}
						IfInString, A_LoopField, Your
						{	
							Arr := StrSplit(A_LoopField, "Your ")
							Affix.Annointment := Arr[2]
							itemLevelIsDone := 1
						Continue
						}
					}
					++captureLines
					If (itemLevelIsDone >= 1 && !doneCorruption && captureLines < 3) {
						imp := RegExReplace(A_LoopField, "i)([-.0-9]+)", "#")
						if (indexOf(imp, Corruption)) {
							If (countCorruption < 1){
							possibleCorruption := A_LoopField
							++countCorruption
							}Else If (countCorruption = 1){
							possibleCorruption2 := A_LoopField
							++countCorruption
							}
							itemLevelIsDone := 1
						}
					}
					If (captureLines < 2)
						possibleImplicit:=A_LoopField
					If (InStr(possibleImplicit, "Life gained for each Enemy hit by Attacks") && InStr(A_LoopField, "Mana gained for each Enemy hit by Attacks"))
					{
						possibleImplicit := possibleImplicit . "`n" . A_LoopField
						captureLines -= 1
					}
					IfInString, A_LoopField, Socketed Gems are
					{
						++Affix.CountSupportGem
						If (Affix.CountSupportGem = 1) {
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.SupportGemLevel := Arr7
							StringSplit, Arrname, A_LoopField, %Arr7%, 3
							If (Arrname2!=""){
								StringTrimLeft, Arrname2, Arrname2 , 1
								Affix.SupportGem := Arrname2
							}
							Else if (Arrname3!=""){
								StringTrimLeft, Arrname3, Arrname3, 1
								Affix.SupportGem := Arrname3
							}
						} Else If (Affix.CountSupportGem = 2) {
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.SupportGem2Level := Arr7
							StringSplit, Arrname, A_LoopField, %Arr7%
							If (Arrname2!=""){
								StringTrimLeft, Arrname2, Arrname2 , 1
								Affix.SupportGem2 := Arrname2
							}
							Else if (Arrname3!=""){
								StringTrimLeft, Arrname3, Arrname3, 1
								Affix.SupportGem2 := Arrname3
							}
						} Else If (Affix.CountSupportGem = 3) {
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.SupportGem3Level := Arr7
							StringSplit, Arrname, A_LoopField, %Arr7%
							If (Arrname2!=""){
								StringTrimLeft, Arrname2, Arrname2 , 1
								Affix.SupportGem3 := Arrname2
							}
							Else if (Arrname3!=""){
								StringTrimLeft, Arrname3, Arrname3, 1
								Affix.SupportGem3 := Arrname3
							}
						} Else If (Affix.CountSupportGem = 4) {
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.SupportGem4Level := Arr7
							StringSplit, Arrname, A_LoopField, %Arr7%
							If (Arrname2!=""){
								StringTrimLeft, Arrname2, Arrname2 , 1
								Affix.SupportGem4 := Arrname2
							}
							Else if (Arrname3!=""){
								StringTrimLeft, Arrname3, Arrname3, 1
								Affix.SupportGem4 := Arrname3
							}
						}
					Continue
					}
					IfInString, A_LoopField, to Level of Socketed Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelGems := Affix.AddedLevelGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Minion Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelMinionGems := Affix.AddedLevelMinionGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Bow Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelBowGems := Affix.AddedLevelBowGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Fire Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelFireGems := Affix.AddedLevelFireGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Cold Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelColdGems := Affix.AddedLevelColdGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Lightning Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelLightningGems := Affix.AddedLevelLightningGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Level of Socketed Chaos Gems
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedLevelChaosGems := Affix.AddedLevelChaosGems + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Intelligence
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedIntelligence := Affix.AddedIntelligence + Arr1
						Affix.PseudoAddedIntelligence := Affix.PseudoAddedIntelligence + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Strength
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedStrength := Affix.AddedStrength + Arr1
						Affix.PseudoAddedStrength := Affix.PseudoAddedStrength + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Dexterity
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedDexterity := Affix.AddedDexterity + Arr1
						Affix.PseudoAddedDexterity := Affix.PseudoAddedDexterity + Arr1
					Continue	
					}
					IfInString, A_LoopField, to all Attributes
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedAllStats := Affix.AddedAllStats + Arr1
						Affix.PseudoAddedIntelligence := Affix.PseudoAddedIntelligence + Arr1
						Affix.PseudoAddedStrength := Affix.PseudoAddedStrength + Arr1
						Affix.PseudoAddedDexterity := Affix.PseudoAddedDexterity + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Strength and Dexterity
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedStrengthDexterity := Affix.AddedStrengthDexterity + Arr1
						Affix.PseudoAddedStrength := Affix.PseudoAddedStrength + Arr1
						Affix.PseudoAddedDexterity := Affix.PseudoAddedDexterity + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Dexterity and Intelligence
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedDexterityIntelligence := Affix.AddedDexterityIntelligence + Arr1
						Affix.PseudoAddedDexterity := Affix.PseudoAddedDexterity + Arr1
						Affix.PseudoAddedIntelligence := Affix.PseudoAddedIntelligence + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Strength and Intelligence
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedStrengthIntelligence := Affix.AddedStrengthIntelligence + Arr1
						Affix.PseudoAddedStrength := Affix.PseudoAddedStrength + Arr1
						Affix.PseudoAddedIntelligence := Affix.PseudoAddedIntelligence + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Armour
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedArmour := Affix.AddedArmour + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Armour and Energy Shield
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedArmourEnergyShield := Affix.IncreasedArmourEnergyShield + Arr1
						Affix.PseudoIncreasedArmour := Affix.PseudoIncreasedArmour + Arr1
						Affix.PseudoIncreasedEnergyShield := Affix.PseudoIncreasedEnergyShield + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Armour and Evasion
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedArmourEvasion := Affix.IncreasedArmourEvasion + Arr1
						Affix.PseudoIncreasedArmour := Affix.PseudoIncreasedArmour + Arr1
						Affix.PseudoIncreasedEvasion := Affix.PseudoIncreasedEvasion + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Armour
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedArmour := Affix.IncreasedArmour + Arr1
						Affix.PseudoIncreasedArmour := Affix.PseudoIncreasedArmour + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Evasion Rating
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedEvasion := Affix.AddedEvasion + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Evasion Rating
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedEvasion := Affix.IncreasedEvasion + Arr1
						Affix.PseudoIncreasedEvasion := Affix.PseudoIncreasedEvasion + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Evasion and Energy Shield
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedEvasionEnergyShield := Affix.IncreasedEvasionEnergyShield + Arr1
						Affix.PseudoIncreasedEvasion := Affix.PseudoIncreasedEvasion + Arr1
						Affix.PseudoIncreasedEnergyShield := Affix.PseudoIncreasedEnergyShield + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Accuracy Rating
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.AddedAccuracy := Affix.AddedAccuracy + Arr1
					Continue	
					}
					IfInString, A_LoopField, to maximum Life
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.MaximumLife := Affix.MaximumLife + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased maximum Life
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedMaximumLife := Affix.IncreasedMaximumLife + Arr1
					Continue	
					}
					IfInString, A_LoopField, to maximum Mana
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.MaximumMana := Affix.MaximumMana + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased maximum Mana
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedMaximumMana := Affix.IncreasedMaximumMana + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Mana Regeneration Rate
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedManaRegeneration := Affix.IncreasedManaRegeneration + Arr1
					Continue	
					}
					IfInString, A_LoopField, to maximum Energy Shield
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.MaximumEnergyShield := Affix.MaximumEnergyShield + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Energy Shield
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedEnergyShield := Affix.IncreasedEnergyShield + Arr1
						Affix.PseudoIncreasedEnergyShield := Affix.PseudoIncreasedEnergyShield + Arr1
					Continue	
					}
					IfInString, A_LoopField, of Physical Attack Damage Leeched as Life
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.PhysicalLeechLife := Affix.PhysicalLeechLife + Arr1
					Continue	
					}
					IfInString, A_LoopField, of Physical Attack Damage Leeched as Mana
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.PhysicalLeechMana := Affix.PhysicalLeechMana + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Global Critical Strike Chance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.GlobalCriticalChance := Affix.GlobalCriticalChance + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Global Critical Strike Multiplier
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.GlobalCriticalMultiplier := Affix.GlobalCriticalMultiplier + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Projectile Speed
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedProjectileSpeed := Affix.IncreasedProjectileSpeed + Arr1
					Continue	
					}
					IfInString, A_LoopField, to all Elemental Resistances
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.AllElementalResistances := Affix.AllElementalResistances + Arr1
						Affix.PseudoColdResist := Affix.PseudoColdResist + Arr1
						Affix.PseudoLightningResist := Affix.PseudoLightningResist + Arr1
						Affix.PseudoFireResist := Affix.PseudoFireResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Fire and Lightning Resistances
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.FireLightningResistance := Affix.FireLightningResistance + Arr1
						Affix.PseudoLightningResist := Affix.PseudoLightningResist + Arr1
						Affix.PseudoFireResist := Affix.PseudoFireResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Fire and Cold Resistances
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.FireColdResistance := Affix.FireColdResistance + Arr1
						Affix.PseudoFireResist := Affix.PseudoFireResist + Arr1
						Affix.PseudoColdResist := Affix.PseudoColdResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Cold and Lightning Resistances
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.ColdLightningResistance := Affix.ColdLightningResistance + Arr1
						Affix.PseudoColdResist := Affix.PseudoColdResist + Arr1
						Affix.PseudoLightningResist := Affix.PseudoLightningResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Cold Resistance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.ColdResistance := Affix.ColdResistance + Arr1
						Affix.PseudoColdResist := Affix.PseudoColdResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Fire Resistance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.FireResistance := Affix.FireResistance + Arr1
						Affix.PseudoFireResist := Affix.PseudoFireResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Lightning Resistance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.LightningResistance := Affix.LightningResistance + Arr1
						Affix.PseudoLightningResist := Affix.PseudoLightningResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Chaos Resistance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.ChaosResistance := Affix.ChaosResistance + Arr1
						Affix.PseudoChaosResist := Affix.PseudoChaosResist + Arr1
					Continue	
					}
					IfInString, A_LoopField, Life Regenerated per second
					{
						StringSplit, Arr, A_LoopField, %A_Space%
						Affix.LifeRegeneration := Affix.LifeRegeneration + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to deal Double Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceDoubleDamage := Affix.ChanceDoubleDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Avoid Elemental Ailments
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceAvoidElementalAilment := Affix.ChanceAvoidElementalAilment + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Dodge Attack Hits
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceDoubleDamage := Affix.ChanceDoubleDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to deal Double Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceDoubleDamage := Affix.ChanceDoubleDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Rarity of Items found
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedRarity := Affix.IncreasedRarity + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Attack and Cast Speed
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedAttackCastSpeed := Affix.IncreasedAttackCastSpeed + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Attack Speed
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedAttackSpeed := Affix.IncreasedAttackSpeed + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Movement Speed
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedMovementSpeed := Affix.IncreasedMovementSpeed + Arr1
					Continue	
					}
					IfInString, A_LoopField, Chance to Block
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceBlock := Affix.ChanceBlock + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Elemental Damage with Attack Skills
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedElementalAttack := Affix.IncreasedElementalAttack + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Physical Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedPhysicalDamage := Affix.IncreasedPhysicalDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Poison Duration
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedPoisonDuration := Affix.IncreasedPoisonDuration + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Poison on Hit
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChancePoison := Affix.ChancePoison + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Damage with Poison
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedPoisonDamage := Affix.IncreasedPoisonDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Bleeding Duration
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedBleedDuration := Affix.IncreasedBleedDuration + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to cause Bleeding on Hit
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceBleed := Affix.ChanceBleed + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Damage with Bleeding
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedBleedDamage := Affix.IncreasedBleedDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Critical Strike Chance for Spells
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedSpellCritChance := Affix.IncreasedSpellCritChance + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Critical Strike Chance
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedCritChance := Affix.IncreasedCritChance + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Cast Speed
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedCastSpeed := Affix.IncreasedCastSpeed + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Spell Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedSpellDamage := Affix.IncreasedSpellDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Chaos Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedChaosDamage := Affix.IncreasedChaosDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Cold Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedColdDamage := Affix.IncreasedColdDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Fire Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedFireDamage := Affix.IncreasedFireDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Burning Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedBurningDamage := Affix.IncreasedBurningDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Lightning Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedLightningDamage := Affix.IncreasedLightningDamage + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Ignite
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceIgnite := Affix.ChanceIgnite + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Freeze
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceFreeze := Affix.ChanceFreeze + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Shock
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceShock := Affix.ChanceShock + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Light Radius
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedLightRadius := Affix.IncreasedLightRadius + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Flask Life Recovery rate
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedFlaskLifeRecovery := Affix.IncreasedFlaskLifeRecovery + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Flask Mana Recovery rate
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedFlaskManaRecovery := Affix.IncreasedFlaskManaRecovery + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Flask Charges gained
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedFlaskChargesGained := Affix.IncreasedFlaskChargesGained + Arr1
					Continue	
					}
					IfInString, A_LoopField, reduced Flask Charges used
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ReducedFlaskChargesUsed := Affix.ReducedFlaskChargesUsed + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Flask Effect Duration
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedFlaskDuration := Affix.IncreasedFlaskDuration + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Global Accuracy Rating
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedGlobalAccuracy := Affix.IncreasedGlobalAccuracy + Arr1
					Continue	
					}
					IfInString, A_LoopField, reduced Enemy Stun Threshold
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ReducedEnemyStunThreshold := Affix.ReducedEnemyStunThreshold + Arr1
					Continue	
					}
					IfInString, A_LoopField, increased Stun Duration on Enemies
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedStunDuration := Affix.IncreasedStunDuration + Arr1
					Continue	
					}
					IfInString, A_LoopField, of Energy Shield Regenerated per second
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.EnergyShieldRegen := Affix.EnergyShieldRegen + Arr1
					Continue	
					}
					IfInString, A_LoopField, reduced Attribute Requirements
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ReducedAttributeRequirement := Affix.ReducedAttributeRequirement + Arr1
					Continue	
					}
					IfInString, A_LoopField, additional Physical Damage Reduction
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.PhysicalDamageReduction := Affix.PhysicalDamageReduction + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Dodge Attack Hits
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceDodgeAttack := Affix.ChanceDodgeAttack + Arr1
					Continue	
					}
					IfInString, A_LoopField, chance to Dodge Spell Hits
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceDodgeSpell := Affix.ChanceDodgeSpell + Arr1
					Continue	
					}
					IfInString, A_LoopField, Chance to Block Spell Damage
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.ChanceBlockSpell := Affix.ChanceBlockSpell + Arr1
					Continue	
					}
					IfInString, A_LoopField, Mana gained when you Block
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.BlockManaGain := Affix.BlockManaGain + Arr1
					Continue	
					}
					IfInString, A_LoopField, Physical Damage to Melee Attackers
					{
						StringSplit, Arr, A_LoopField, %A_Space%
						Affix.ReflectPhysical := Affix.ReflectPhysical + Arr2
					Continue	
					}
					IfInString, A_LoopField, increased Stun and Block Recovery
					{
						StringSplit, Arr, A_LoopField, %A_Space%, `%
						Affix.IncreasedStunBlockRecovery := Affix.IncreasedStunBlockRecovery + Arr1
					Continue	
					}
					IfInString, A_LoopField, Life gained on Kill
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.OnKillLife := Affix.OnKillLife + Arr1
					Continue	
					}
					IfInString, A_LoopField, Mana gained on Kill
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.OnKillMana := Affix.OnKillMana + Arr1
					Continue	
					}
					IfInString, A_LoopField, Life gained for each Enemy hit by Attacks
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.LifeGainOnAttack := Affix.LifeGainOnAttack + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Weapon range
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +
						Affix.WeaponRange := Affix.WeaponRange + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Chaos Damage over Time Multiplier
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.ChaosDOTMult := Affix.ChaosDOTMult + Arr1
					Continue	
					}
					IfInString, A_LoopField, to Cold Damage over Time Multiplier
					{
						StringSplit, Arr, A_LoopField, %A_Space%, +`%
						Affix.ColdDOTMult := Affix.ColdDOTMult + Arr1
					Continue	
					}
					IfInString, A_LoopField, Adds
					{
						IfInString, A_LoopField, Physical Damage to Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.PhysicalDamageAttackLo := Arr2
							Affix.PhysicalDamageAttackHi := Arr4
							Affix.PhysicalDamageAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Physical Damage to Bow Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.PhysicalDamageBowAttackLo := Arr2
							Affix.PhysicalDamageBowAttackHi := Arr4
							Affix.PhysicalDamageBowAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Fire Damage to Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.FireDamageAttackLo := Arr2
							Affix.FireDamageAttackHi := Arr4
							Affix.FireDamageAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Fire Damage to Spells
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.FireDamageSpellLo := Arr2
							Affix.FireDamageSpellHi := Arr4
							Affix.FireDamageSpellAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Cold Damage to Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.ColdDamageAttackLo := Arr2
							Affix.ColdDamageAttackHi := Arr4
							Affix.ColdDamageAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Cold Damage to Spells
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.ColdDamageSpellLo := Arr2
							Affix.ColdDamageSpellHi := Arr4
							Affix.ColdDamageSpellAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Lightning Damage to Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.LightningDamageAttackLo := Arr2
							Affix.LightningDamageAttackHi := Arr4
							Affix.LightningDamageAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Lightning Damage to Spells
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.LightningDamageSpellLo := Arr2
							Affix.LightningDamageSpellHi := Arr4
							Affix.LightningDamageSpellAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Chaos Damage to Attacks
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.ChaosDamageAttackLo := Arr2
							Affix.ChaosDamageAttackHi := Arr4
							Affix.ChaosDamageAttackAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Chaos Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.ChaosDamageLo := Arr2
							Affix.ChaosDamageHi := Arr4
							Affix.ChaosDamageAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Cold Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.ColdDamageLo := Arr2
							Affix.ColdDamageHi := Arr4
							Affix.ColdDamageAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Fire Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.FireDamageLo := Arr2
							Affix.FireDamageHi := Arr4
							Affix.FireDamageAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Lightning Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.LightningDamageLo := Arr2
							Affix.LightningDamageHi := Arr4
							Affix.LightningDamageAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}
						IfInString, A_LoopField, Physical Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.PhysicalDamageLo := Arr2
							Affix.PhysicalDamageHi := Arr4
							Affix.PhysicalDamageAvg := round(((Arr2 + Arr4) / 2),1)
						Continue
						}

					}
					IfInString, A_LoopField, Gain
					{
						IfInString, A_LoopField, of Fire Damage as Extra Chaos Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%, `%
							Affix.GainFireToExtraChaos := Affix.GainFireToExtraChaos + Arr2
						Continue
						}
						IfInString, A_LoopField, of Cold Damage as Extra Chaos Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%, `%
							Affix.GainColdToExtraChaos := Affix.GainColdToExtraChaos + Arr2
						Continue
						}
						IfInString, A_LoopField, of Lightning Damage as Extra Chaos Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%, `%
							Affix.GainLightningToExtraChaos := Affix.GainLightningToExtraChaos + Arr2
						Continue
						}
						IfInString, A_LoopField, of Physical Damage as Extra Chaos Damage
						{
							StringSplit, Arr, A_LoopField, %A_Space%, `%
							Affix.GainPhysicalToExtraChaos := Affix.GainPhysicalToExtraChaos + Arr2
						Continue
						}
					}
				}
			}
			; Corrupted
			IfInString, A_LoopField, Corrupted
			{
					If possibleCorruption{
						Affix.Corruption := possibleCorruption
						Prop.Corrupted := True
					}
					If possibleCorruption2 {
						Affix.Corruption2 := possibleCorruption2
						Prop.DoubleCorrupted := True
					}
				Continue
			}
			; Stack size
			IfInString, A_LoopField, Stack Size:
			{
				StringSplit, StackArray, A_LoopField, %A_Space%
				StringSplit, StripStackArray, StackArray3, /
				Stats.Stack := StripStackArray1
				Stats.StackMax := StripStackArray2
				Continue
			}
			; Flag Unidentified
			IfInString, A_LoopField, Unidentified
			{
				Prop.Identified := False
				continue
			}
			; Flag Prophecy
			IfInString, A_LoopField, add this prophecy
			{
				Prop.Prophecy := True
				Prop.SpecialType := "Prophecy"
				continue
			}
			; Flag Veiled
			IfInString, A_LoopField, Veiled%A_Space%
			{
				Prop.Veiled := True
				Prop.SpecialType := "Veiled"
				continue
			}
			; Get total physical damage
			IfInString, A_LoopField, Physical Damage:
			{
				Prop.IsWeapon := True
				StringSplit, Arr, A_LoopField, %A_Space%
				StringSplit, Arr, Arr3, -
				Stats.PhysLo := Arr1
				Stats.PhysHi := Arr2
				Continue
			}
			; Get total Elemental damage
			IfInString, A_LoopField, Elemental Damage:
			{
				Prop.IsWeapon := True
				StringSplit, Arr, A_LoopField, %A_Space%
				StringSplit, Arr, Arr3, -
				Stats.EleLo := Arr1
				Stats.EleHi := Arr2
				Continue
			}
			; Get total Chaos damage
			IfInString, A_LoopField, Chaos Damage:
			{
				Prop.IsWeapon := True
				StringSplit, Arr, A_LoopField, %A_Space%
				StringSplit, Arr, Arr3, -
				Stats.ChaosLo := Arr1
				Stats.ChaosHi := Arr2
				Continue
			}
			; These only make sense for weapons
			If Prop.IsWeapon 
			{
				; Get attack speed
				IfInString, A_LoopField, Attacks per Second:
				{
					StringSplit, Arr, A_LoopField, %A_Space%
					Stats.AttackSpeed := Arr4
					Continue
				}

				; Get percentage physical damage increase
				IfInString, A_LoopField, increased Physical Damage
				{
					StringSplit, Arr, A_LoopField, %A_Space%, `%
					Stats.PhysMult := Arr1
					Continue
				}
			}
		}
		;Determine if affixes complete on certain items
		If (itemLevelIsDone = 2 && captureLines >= 1)
		{
			Prop.HasAffix := True
		}
		; DPS calculations
		If (Prop.IsWeapon) {

			Stats.PhysDps := ((Stats.PhysLo + Stats.PhysHi) / 2) * Stats.AttackSpeed
			Stats.EleDps := ((Stats.EleLo + Stats.EleHi) / 2) * Stats.AttackSpeed
			Stats.ChaosDps := ((Stats.ChaosLo + Stats.ChaosHi) / 2) * Stats.AttackSpeed

			Stats.TotalDps := Stats.PhysDps + Stats.EleDps + Stats.ChaosDps
			; Only show Q20 values if item is not Q20
			If (Stats.Quality < 20)
			{
				Stats.TotalPhysMult := (Stats.PhysMult + Stats.Quality + 100) / 100
				Stats.BasePhysDps := Stats.PhysDps / Stats.TotalPhysMult
				Stats.Q20Dps := Stats.BasePhysDps * ((Stats.PhysMult + 120) / 100) + Stats.EleDps + Stats.ChaosDps
			}
		}

		Affix.PseudoTotalEleResist := Affix.PseudoColdResist + Affix.PseudoFireResist + Affix.PseudoLightningResist
		Affix.PseudoTotalResist := Affix.PseudoTotalEleResist + Affix.PseudoChaosResist
		
		Affix.PseudoTotalAddedEleAvg := (Affix.FireDamageAttackAvg?Affix.FireDamageAttackAvg:0) + ( (Affix.ColdDamageAttackAvg) ? (Affix.ColdDamageAttackAvg) : 0 ) + ( (Affix.LightningDamageAttackAvg) ? (Affix.LightningDamageAttackAvg) : 0 ) + ( (Affix.LightningDamageAttackAvg) ? (Affix.LightningDamageAttackAvg) : 0 )
		Affix.PseudoTotalAddedAvg := (Affix.PseudoTotalAddedEleAvg?Affix.PseudoTotalAddedEleAvg:0) + (Affix.PhysicalDamageAttackAvg?Affix.PhysicalDamageAttackAvg:0) + (Affix.PhysicalDamageBowAttackAvg?Affix.PhysicalDamageBowAttackAvg:0)

		nameArr := StrSplit(Prop.ItemName, "`n")
		Prop.ItemName := nameArr[1]

		If Prop.ItemBase =
		Prop.ItemBase := nameArr[2]

		If (possibleCorruption = possibleImplicit && !Prop.Corrupted)
			Affix.Implicit := possibleImplicit

		If indexOf(Prop.ItemBase, craftingBasesT1) 
			Prop.CraftingBase := "T1"
		Else if indexOf(Prop.ItemBase, craftingBasesT2)
			Prop.CraftingBase := "T2"
		Else if indexOf(Prop.ItemBase, craftingBasesT3) 
			Prop.CraftingBase := "T3"
		
		If Prop.RarityGem
		{
			If Stats.GemLevel >= 20
			{
				variantStr := Stats.GemLevel
				If Stats.Quality >= 20 && Stats.Quality < 23
					variantStr .= "/20"
				Else If Stats.Quality = 23
					variantStr .= "/23"
				If Prop.Corrupted 
					variantStr .= "c"
				Prop.Variant := variantStr
			}
			Else If Stats.GemLevel < 20 && Stats.Quality >= 15
			{
				variantStr := "1/20"
				Prop.Variant := variantStr
			}
			Else If Stats.GemLevel < 20 && Stats.Quality < 15
			{
				variantStr := "20"
				Prop.Variant := variantStr
			}
		}
		If Prop.Resonator
		{
			If (InStr(Prop.ItemName, "Primitive") || InStr(Prop.ItemName, "Potent"))
				Prop.Width := 1
			Else
				Prop.Width := 2
			
			If (InStr(Prop.ItemName, "Primitive"))
				Prop.Height := 1
			Else
				Prop.Height := 2
		}
		MatchNinjaPrice()
		If InStr(Prop.ItemName, "Chaos Orb")
			Prop.ChaosValue := 1

		If (Stats.ItemClass = "Amulet")
		{
			If Prop.Scarab
			{
				Prop.Scarab := False
				Prop.SpecialType := ""
			}
		}
		Return
	}
	; ItemInfo - Display information about item under cursor
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ItemInfo(){
		ItemInfoCommand:
		MouseGetPos, Mx, My
		ClipItem(Mx, My)
		MatchNinjaPrice(True)
		Return
	}
	; MatchLootFilter - Evaluate Loot Filter Match
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	MatchLootFilter()
	{
		For GKey, Groups in LootFilter
		{
			matched := False
			nomatched := False
			For SKey, Selected in Groups
			{
				For AKey, AVal in Selected
				{
					If (InStr(AKey, "Eval") || InStr(AKey, "Min"))
						Continue
					;MsgBox % "Key: " SKey "  Val: " Selected
					if InStr(SKey, "Affix")
					{
						if Affix.haskey(AVal)
						{
							arrval := Affix[AVal]
							eval := LootFilter[GKey][SKey][AKey . "Eval"]
							min := LootFilter[GKey][SKey][AKey . "Min"]
							if eval = >
								If (arrval > min)
								matched := True
								Else
								nomatched := True
							else if eval = =
								if (arrval = min)
								matched := True
								Else
								nomatched := True
							else if eval = <
								if (arrval < min)
								matched := True
								Else
								nomatched := True
							else if eval = !=
								if (arrval != min)
								matched := True
								Else
								nomatched := True
							else if eval = ~
							{
								minarr := StrSplit(min, "|"," ")
								for k, v in minarr
								{
									if InStr(arrval, v)
									{
										matched := True
										break
									}
									Else
									{
										matched := False
									}
								}
								if !matched
								{
									nomatched := True
								}
							}
						}
					}
					if InStr(SKey, "Prop")
					{
						if Prop.haskey(AVal)
						{
							arrval := Prop[AVal]
							eval := LootFilter[GKey][SKey][AKey . "Eval"]
							min := LootFilter[GKey][SKey][AKey . "Min"]
							if eval = >
								If (arrval > min)
								matched := True
								Else
								nomatched := True
							else if eval = =
								if (arrval = min)
								matched := True
								Else
								nomatched := True
							else if eval = <
								if (arrval < min)
								matched := True
								Else
								nomatched := True
							else if eval = !=
								if (arrval != min)
								matched := True
								Else
								nomatched := True
							else if eval = ~
							{
								minarr := StrSplit(min, "|"," ")
								for k, v in minarr
								{
									if InStr(arrval, v)
									{
										matched := True
										break
									}
									Else
									{
										matched := False
									}
								}
								if !matched
								{
									nomatched := True
								}
							}
						}
					}
					if InStr(SKey, "Stats")
					{
						if Stats.haskey(AVal)
						{
							arrval := Stats[AVal]
							eval := LootFilter[GKey][SKey][AKey . "Eval"]
							min := LootFilter[GKey][SKey][AKey . "Min"]
							if eval = >
								If (arrval > min)
								matched := True
								Else
								nomatched := True
							else if eval = =
								if (arrval = min)
								matched := True
								Else
								nomatched := True
							else if eval = <
								if (arrval < min)
								matched := True
								Else
								nomatched := True
							else if eval = !=
								if (arrval != min)
								matched := True
								Else
								nomatched := True
							else if eval = ~
							{
								minarr := StrSplit(min, "|"," ")
								for k, v in minarr
								{
									if InStr(arrval, v)
									{
										matched := True
										break
									}
									Else
									{
										matched := False
									}
								}
								if !matched
								{
									nomatched := True
								}
							}
						}
					}
				}
			}
			If matched && !nomatched
				Return LootFilterTabs[GKey]
		}
	Return False
	}
	; MatchNinjaPrice - Flag item with chaos value from PoE-Ninja
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	MatchNinjaPrice(graph := False)
	{
		For TKey, typeArr in Ninja
		{
			If TKey != "currencyDetails"
			{
				For index, indVal in typeArr
				{
					If Prop.RarityGem
					{
						If (Prop.ItemName = Ninja[TKey][index]["name"] && Prop.Variant = Ninja[TKey][index]["variant"])
						{
							Prop.ChaosValue := (Ninja[TKey][index]["chaosValue"] ? Ninja[TKey][index]["chaosValue"] : False)
							Prop.ExaltValue := (Ninja[TKey][index]["exaltedValue"] ? Ninja[TKey][index]["exaltedValue"] : False)
							If graph
							{
								GraphNinjaPrices(TKey,index)
								DisplayPSA()
							}
							Return True
						}
					}
					Else If (Prop.IsMap)
					{
						If InStr(Prop.ItemName, Ninja[TKey][index]["name"])
						{
							Prop.ChaosValue := (Ninja[TKey][index]["chaosValue"] ? Ninja[TKey][index]["chaosValue"] : False)
							Prop.ExaltValue := (Ninja[TKey][index]["exaltedValue"] ? Ninja[TKey][index]["exaltedValue"] : False)
							If graph
							{
								GraphNinjaPrices(TKey,index)
								DisplayPSA()
							}
							Return True
						}
					}
					Else If (Prop.ItemName = Ninja[TKey][index]["name"] && !Ninja[TKey][index].HasKey("links") )
					{
						Prop.ChaosValue := (Ninja[TKey][index]["chaosValue"] ? Ninja[TKey][index]["chaosValue"] : False)
						Prop.ExaltValue := (Ninja[TKey][index]["exaltedValue"] ? Ninja[TKey][index]["exaltedValue"] : False)
						If graph
						{
							GraphNinjaPrices(TKey,index)
							DisplayPSA()
						}
						Return True
					}
					Else If (Prop.ItemName = Ninja[TKey][index]["name"] && ((ForceMatch6Link && Ninja[TKey][index]["links"] = "6") || (Prop.6Link && Ninja[TKey][index]["links"] = "6") || (Prop.5Link && Ninja[TKey][index]["links"] = "5") || (Prop.LinkCount < 4 && Ninja[TKey][index]["links"] = "0")))
					{
						Prop.ChaosValue := (Ninja[TKey][index]["chaosValue"] ? Ninja[TKey][index]["chaosValue"] : False)
						Prop.ExaltValue := (Ninja[TKey][index]["exaltedValue"] ? Ninja[TKey][index]["exaltedValue"] : False)
						If graph
						{
							GraphNinjaPrices(TKey,index)
							DisplayPSA()
						}
						Return True
					}
				}
			}
		}
		If graph
		{
			GraphNinjaPrices()
			DisplayPSA()
		}
	Return False
	}
	; GraphNinjaPrices - Send sparkline data to the graphs
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	GraphNinjaPrices(TKey:=False,index:=False)
	{
		If !(TKey = False || index = False)
			Gui, ItemInfo: Show, AutoSize, % Prop.ItemName " Sparkline"
		Else
		{
			Gui, ItemInfo: Show, AutoSize, % Prop.ItemName " has no Graph Data"
			Goto, noDataGraph
		}
			
		If (Ninja[TKey][index]["paySparkLine"])
		{
			dataPayPoint := Ninja[TKey][index]["paySparkLine"]["data"]
			dataRecPoint := Ninja[TKey][index]["receiveSparkLine"]["data"]
			totalPayChange := Ninja[TKey][index]["paySparkLine"]["totalChange"]
			totalRecChange := Ninja[TKey][index]["receiveSparkLine"]["totalChange"]

			basePayPoint := 0
			For k, v in dataPayPoint
			{
				If Abs(v) > basePayPoint
					basePayPoint := Abs(v)
			}
			If basePayPoint = 0
			FormatStr := "{1:0.0f}"
			Else If basePayPoint < 1
			FormatStr := "{1:0.3f}"
			Else If basePayPoint < 10
			FormatStr := "{1:0.2f}"
			Else If basePayPoint < 100
			FormatStr := "{1:0.1f}"
			Else If basePayPoint > 100
			FormatStr := "{1:0.0f}"

			GuiControl,ItemInfo: , PercentText1G1, % Format(FormatStr,(basePayPoint*1.0)) "`%"
			GuiControl,ItemInfo: , PercentText1G2, % Format(FormatStr,(basePayPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText1G3, % Format(FormatStr,(basePayPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText1G4, % Format(FormatStr,(basePayPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText1G5, % Format(FormatStr,(basePayPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText1G6, % Format(FormatStr,(basePayPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText1G7, % Format(FormatStr,(basePayPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText1G8, % Format(FormatStr,(basePayPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText1G9, % Format(FormatStr,(basePayPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText1G10, % Format(FormatStr,(basePayPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText1G11, % "0`%"
			GuiControl,ItemInfo: , PercentText1G12, % Format(FormatStr,-(basePayPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText1G13, % Format(FormatStr,-(basePayPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText1G14, % Format(FormatStr,-(basePayPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText1G15, % Format(FormatStr,-(basePayPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText1G16, % Format(FormatStr,-(basePayPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText1G17, % Format(FormatStr,-(basePayPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText1G18, % Format(FormatStr,-(basePayPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText1G19, % Format(FormatStr,-(basePayPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText1G20, % Format(FormatStr,-(basePayPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText1G21, % Format(FormatStr,-(basePayPoint*1.0)) "`%"


			baseRecPoint := 0
			For k, v in dataRecPoint
			{
				If Abs(v) > baseRecPoint
					baseRecPoint := Abs(v)
			}
			If baseRecPoint = 0
			FormatStr := "{1:0.0f}"
			Else If baseRecPoint < 1
			FormatStr := "{1:0.3f}"
			Else If baseRecPoint < 10
			FormatStr := "{1:0.2f}"
			Else If baseRecPoint < 100
			FormatStr := "{1:0.1f}"
			Else If baseRecPoint > 100
			FormatStr := "{1:0.0f}"

			GuiControl,ItemInfo: , PercentText2G1, % Format(FormatStr,(baseRecPoint*1.0)) "`%"
			GuiControl,ItemInfo: , PercentText2G2, % Format(FormatStr,(baseRecPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText2G3, % Format(FormatStr,(baseRecPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText2G4, % Format(FormatStr,(baseRecPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText2G5, % Format(FormatStr,(baseRecPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText2G6, % Format(FormatStr,(baseRecPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText2G7, % Format(FormatStr,(baseRecPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText2G8, % Format(FormatStr,(baseRecPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText2G9, % Format(FormatStr,(baseRecPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText2G10, % Format(FormatStr,(baseRecPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText2G11, % "0`%"
			GuiControl,ItemInfo: , PercentText2G12, % Format(FormatStr,-(baseRecPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText2G13, % Format(FormatStr,-(baseRecPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText2G14, % Format(FormatStr,-(baseRecPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText2G15, % Format(FormatStr,-(baseRecPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText2G16, % Format(FormatStr,-(baseRecPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText2G17, % Format(FormatStr,-(baseRecPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText2G18, % Format(FormatStr,-(baseRecPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText2G19, % Format(FormatStr,-(baseRecPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText2G20, % Format(FormatStr,-(baseRecPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText2G21, % Format(FormatStr,-(baseRecPoint*1.0)) "`%"


			AvgPay := {}
			Loop 5
			{
				AvgPay[A_Index] := (dataPayPoint[A_Index+1] + dataPayPoint[A_Index+2]) / 2
			}
			paddedPayData := {}
			paddedPayData[1] := dataPayPoint[1]
			paddedPayData[2] := dataPayPoint[1]
			paddedPayData[3] := dataPayPoint[2]
			paddedPayData[4] := AvgPay[1]
			paddedPayData[5] := dataPayPoint[3]
			paddedPayData[6] := AvgPay[2]
			paddedPayData[7] := dataPayPoint[4]
			paddedPayData[8] := AvgPay[3]
			paddedPayData[9] := dataPayPoint[5]
			paddedPayData[10] := AvgPay[4]
			paddedPayData[11] := dataPayPoint[6]
			paddedPayData[12] := AvgPay[5]
			paddedPayData[13] := dataPayPoint[7]
			For k, v in paddedPayData
			{
				div := v / basePayPoint * 100
				XGraph_Plot( pGraph1, 100 - div, "", True )
				;MsgBox % "Key : " k "   Val : " v
			}
			AvgRec := {}
			Loop 5
			{
				AvgRec[A_Index] := (dataRecPoint[A_Index+1] + dataRecPoint[A_Index+2]) / 2
			}
			paddedRecData := {}
			paddedRecData[1] := dataRecPoint[1]
			paddedRecData[2] := dataRecPoint[1]
			paddedRecData[3] := dataRecPoint[2]
			paddedRecData[4] := AvgRec[1]
			paddedRecData[5] := dataRecPoint[3]
			paddedRecData[6] := AvgRec[2]
			paddedRecData[7] := dataRecPoint[4]
			paddedRecData[8] := AvgRec[3]
			paddedRecData[9] := dataRecPoint[5]
			paddedRecData[10] := AvgRec[4]
			paddedRecData[11] := dataRecPoint[6]
			paddedRecData[12] := AvgRec[5]
			paddedRecData[13] := dataRecPoint[7]
			For k, v in paddedRecData
			{
				div := v / baseRecPoint * 100
				XGraph_Plot( pGraph2, 100 - div, "", True )
				;MsgBox % "Key : " k "   Val : " v
			}

			GuiControl,ItemInfo: , GroupBox1, % "Sell " Prop.ItemName " to Chaos"
			GuiControl,ItemInfo: , PComment1, Sell Value
			GuiControl,ItemInfo: , PData1, % sellval := (1 / Ninja[TKey][index]["pay"]["value"])
			GuiControl,ItemInfo: , PComment2, Sell Value `% Change
			GuiControl,ItemInfo: , PData2, % Ninja[TKey][index]["paySparkLine"]["totalChange"]
			GuiControl,ItemInfo: , PComment3, Orb per Chaos
			GuiControl,ItemInfo: , PData3, % Ninja[TKey][index]["pay"]["value"]
			GuiControl,ItemInfo: , PComment4, Day 6 Change
			GuiControl,ItemInfo: , PData4, % dataPayPoint[2]
			GuiControl,ItemInfo: , PComment5, Day 5 Change
			GuiControl,ItemInfo: , PData5, % dataPayPoint[3]
			GuiControl,ItemInfo: , PComment6, Day 4 Change
			GuiControl,ItemInfo: , PData6, % dataPayPoint[4]
			GuiControl,ItemInfo: , PComment7, Day 3 Change
			GuiControl,ItemInfo: , PData7, % dataPayPoint[5]
			GuiControl,ItemInfo: , PComment8, Day 2 Change
			GuiControl,ItemInfo: , PData8, % dataPayPoint[6]
			GuiControl,ItemInfo: , PComment9, Day 1 Change
			GuiControl,ItemInfo: , PData9, % dataPayPoint[7]
			GuiControl,ItemInfo: , PComment10, % Decimal2Fraction(sellval,"ID3")
			GuiControl,ItemInfo: , PData10, C / O

			GuiControl,ItemInfo: , GroupBox2, % "Buy " Prop.ItemName " from Chaos"
			GuiControl,ItemInfo: , SComment1, Buy Value
			GuiControl,ItemInfo: , SData1, % sellval := (Ninja[TKey][index]["receive"]["value"])
			GuiControl,ItemInfo: , SComment2, Buy Value `% Change
			GuiControl,ItemInfo: , SData2, % Ninja[TKey][index]["receiveSparkLine"]["totalChange"]
			GuiControl,ItemInfo: , SComment3, Orb per Chaos
			GuiControl,ItemInfo: , SData3, % 1 / Ninja[TKey][index]["receive"]["value"]
			GuiControl,ItemInfo: , SComment4, Day 6 Change
			GuiControl,ItemInfo: , SData4, % dataRecPoint[2]
			GuiControl,ItemInfo: , SComment5, Day 5 Change
			GuiControl,ItemInfo: , SData5, % dataRecPoint[3]
			GuiControl,ItemInfo: , SComment6, Day 4 Change
			GuiControl,ItemInfo: , SData6, % dataRecPoint[4]
			GuiControl,ItemInfo: , SComment7, Day 3 Change
			GuiControl,ItemInfo: , SData7, % dataRecPoint[5]
			GuiControl,ItemInfo: , SComment8, Day 2 Change
			GuiControl,ItemInfo: , SData8, % dataRecPoint[6]
			GuiControl,ItemInfo: , SComment9, Day 1 Change
			GuiControl,ItemInfo: , SData9, % dataRecPoint[7]
			GuiControl,ItemInfo: , SComment10, % Decimal2Fraction(sellval,"ID3")
			GuiControl,ItemInfo: , SData10, C / O

		}
		Else If (Ninja[TKey][index]["sparkline"])
		{
			dataPoint := Ninja[TKey][index]["sparkline"]["data"]
			dataLTPoint := Ninja[TKey][index]["lowConfidenceSparkline"]["data"]
			totalChange := Ninja[TKey][index]["sparkline"]["totalChange"]
			totalLTChange := Ninja[TKey][index]["lowConfidenceSparkline"]["totalChange"]

			basePoint := 0
			For k, v in dataPoint
			{
				If Abs(v) > basePoint
					basePoint := Abs(v)
			}
			If basePoint = 0
			FormatStr := "{1:0.0f}"
			Else If basePoint < 1
			FormatStr := "{1:0.3f}"
			Else If basePoint < 10
			FormatStr := "{1:0.2f}"
			Else If basePoint < 100
			FormatStr := "{1:0.1f}"
			Else If basePoint > 100
			FormatStr := "{1:0.0f}"

			GuiControl,ItemInfo: , PercentText1G1, % Format(FormatStr,(basePoint*1.0)) "`%"
			GuiControl,ItemInfo: , PercentText1G2, % Format(FormatStr,(basePoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText1G3, % Format(FormatStr,(basePoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText1G4, % Format(FormatStr,(basePoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText1G5, % Format(FormatStr,(basePoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText1G6, % Format(FormatStr,(basePoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText1G7, % Format(FormatStr,(basePoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText1G8, % Format(FormatStr,(basePoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText1G9, % Format(FormatStr,(basePoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText1G10, % Format(FormatStr,(basePoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText1G11, % "0`%"
			GuiControl,ItemInfo: , PercentText1G12, % Format(FormatStr,-(basePoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText1G13, % Format(FormatStr,-(basePoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText1G14, % Format(FormatStr,-(basePoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText1G15, % Format(FormatStr,-(basePoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText1G16, % Format(FormatStr,-(basePoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText1G17, % Format(FormatStr,-(basePoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText1G18, % Format(FormatStr,-(basePoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText1G19, % Format(FormatStr,-(basePoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText1G20, % Format(FormatStr,-(basePoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText1G21, % Format(FormatStr,-(basePoint*1.0)) "`%"

			baseLTPoint := 0
			For k, v in dataLTPoint
			{
				If Abs(v) > baseLTPoint
					baseLTPoint := Abs(v)
			}
			If baseLTPoint = 0
			FormatStr := "{1:0.0f}"
			If baseLTPoint < 1
			FormatStr := "{1:0.3f}"
			Else If baseLTPoint < 10
			FormatStr := "{1:0.2f}"
			Else If baseLTPoint < 100
			FormatStr := "{1:0.1f}"
			Else If baseLTPoint > 100
			FormatStr := "{1:0.0f}"

			GuiControl,ItemInfo: , PercentText2G1, % Format(FormatStr,(baseLTPoint*1.0)) "`%"
			GuiControl,ItemInfo: , PercentText2G2, % Format(FormatStr,(baseLTPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText2G3, % Format(FormatStr,(baseLTPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText2G4, % Format(FormatStr,(baseLTPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText2G5, % Format(FormatStr,(baseLTPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText2G6, % Format(FormatStr,(baseLTPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText2G7, % Format(FormatStr,(baseLTPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText2G8, % Format(FormatStr,(baseLTPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText2G9, % Format(FormatStr,(baseLTPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText2G10, % Format(FormatStr,(baseLTPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText2G11, % "0`%"
			GuiControl,ItemInfo: , PercentText2G12, % Format(FormatStr,-(baseLTPoint*0.1)) "`%"
			GuiControl,ItemInfo: , PercentText2G13, % Format(FormatStr,-(baseLTPoint*0.2)) "`%"
			GuiControl,ItemInfo: , PercentText2G14, % Format(FormatStr,-(baseLTPoint*0.3)) "`%"
			GuiControl,ItemInfo: , PercentText2G15, % Format(FormatStr,-(baseLTPoint*0.4)) "`%"
			GuiControl,ItemInfo: , PercentText2G16, % Format(FormatStr,-(baseLTPoint*0.5)) "`%"
			GuiControl,ItemInfo: , PercentText2G17, % Format(FormatStr,-(baseLTPoint*0.6)) "`%"
			GuiControl,ItemInfo: , PercentText2G18, % Format(FormatStr,-(baseLTPoint*0.7)) "`%"
			GuiControl,ItemInfo: , PercentText2G19, % Format(FormatStr,-(baseLTPoint*0.8)) "`%"
			GuiControl,ItemInfo: , PercentText2G20, % Format(FormatStr,-(baseLTPoint*0.9)) "`%"
			GuiControl,ItemInfo: , PercentText2G21, % Format(FormatStr,-(baseLTPoint*1.0)) "`%"

			Avg := {}
			Loop 5
			{
				Avg[A_Index] := (dataPoint[A_Index+1] + dataPoint[A_Index+2]) / 2
			}
			paddedData := {}
			paddedData[1] := dataPoint[1]
			paddedData[2] := dataPoint[1]
			paddedData[3] := dataPoint[2]
			paddedData[4] := Avg[1]
			paddedData[5] := dataPoint[3]
			paddedData[6] := Avg[2]
			paddedData[7] := dataPoint[4]
			paddedData[8] := Avg[3]
			paddedData[9] := dataPoint[5]
			paddedData[10] := Avg[4]
			paddedData[11] := dataPoint[6]
			paddedData[12] := Avg[5]
			paddedData[13] := dataPoint[7]
			For k, v in paddedData
			{
				div := v / basePoint * 100
				XGraph_Plot( pGraph1, 100 - div, "", True )
				;MsgBox % "Key : " k "   Val : " v
			}
			LTAvg := {}
			Loop 5
			{
				LTAvg[A_Index] := (dataLTPoint[A_Index+1] + dataLTPoint[A_Index+2]) / 2
			}
			paddedLTData := {}
			paddedLTData[1] := dataLTPoint[1]
			paddedLTData[2] := dataLTPoint[1]
			paddedLTData[3] := dataLTPoint[2]
			paddedLTData[4] := LTAvg[1]
			paddedLTData[5] := dataLTPoint[3]
			paddedLTData[6] := LTAvg[2]
			paddedLTData[7] := dataLTPoint[4]
			paddedLTData[8] := LTAvg[3]
			paddedLTData[9] := dataLTPoint[5]
			paddedLTData[10] := LTAvg[4]
			paddedLTData[11] := dataLTPoint[6]
			paddedLTData[12] := LTAvg[5]
			paddedLTData[13] := dataLTPoint[7]
			For k, v in paddedLTData
			{
				div := v / baseLTPoint * 100
				XGraph_Plot( pGraph2, 100 - div, "", True )
				;MsgBox % "Key : " k "   Val : " v
			}

			GuiControl,ItemInfo: , GroupBox1, % "Value of " Prop.ItemName
			GuiControl,ItemInfo: , PComment1, Chaos Value
			GuiControl,ItemInfo: , PData1, % Ninja[TKey][index]["chaosValue"]
			GuiControl,ItemInfo: , PComment2, Chaos Value `% Change
			GuiControl,ItemInfo: , PData2, % Ninja[TKey][index]["sparkline"]["totalChange"]
			GuiControl,ItemInfo: , PComment3, Exalted Value
			GuiControl,ItemInfo: , PData3, % Ninja[TKey][index]["exaltedValue"]
			GuiControl,ItemInfo: , PComment4, Day 6 Change
			GuiControl,ItemInfo: , PData4, % dataPoint[2]
			GuiControl,ItemInfo: , PComment5, Day 5 Change
			GuiControl,ItemInfo: , PData5, % dataPoint[3]
			GuiControl,ItemInfo: , PComment6, Day 4 Change
			GuiControl,ItemInfo: , PData6, % dataPoint[4]
			GuiControl,ItemInfo: , PComment7, Day 3 Change
			GuiControl,ItemInfo: , PData7, % dataPoint[5]
			GuiControl,ItemInfo: , PComment8, Day 2 Change
			GuiControl,ItemInfo: , PData8, % dataPoint[6]
			GuiControl,ItemInfo: , PComment9, Day 1 Change
			GuiControl,ItemInfo: , PData9, % dataPoint[7]
			GuiControl,ItemInfo: , PComment10, 
			GuiControl,ItemInfo: , PData10,

			GuiControl,ItemInfo: , GroupBox2, % "Low Confidence Value of " Prop.ItemName
			GuiControl,ItemInfo: , SComment1, Chaos Value `% Change
			GuiControl,ItemInfo: , SData1, % Ninja[TKey][index]["lowConfidenceSparkline"]["totalChange"]
			GuiControl,ItemInfo: , SComment2,
			GuiControl,ItemInfo: , SData2, 
			GuiControl,ItemInfo: , SComment3, 
			GuiControl,ItemInfo: , SData3, 
			GuiControl,ItemInfo: , SComment4, Day 6 Change
			GuiControl,ItemInfo: , SData4, % dataLTPoint[2]
			GuiControl,ItemInfo: , SComment5, Day 5 Change
			GuiControl,ItemInfo: , SData5, % dataLTPoint[3]
			GuiControl,ItemInfo: , SComment6, Day 4 Change
			GuiControl,ItemInfo: , SData6, % dataLTPoint[4]
			GuiControl,ItemInfo: , SComment7, Day 3 Change
			GuiControl,ItemInfo: , SData7, % dataLTPoint[5]
			GuiControl,ItemInfo: , SComment8, Day 2 Change
			GuiControl,ItemInfo: , SData8, % dataLTPoint[6]
			GuiControl,ItemInfo: , SComment9, Day 1 Change
			GuiControl,ItemInfo: , SData9, % dataLTPoint[7]
			GuiControl,ItemInfo: , SComment10,
			GuiControl,ItemInfo: , SData10,
		}
		Return

		noDataGraph:
				GuiControl,ItemInfo: , PercentText1G1, 0`%
				GuiControl,ItemInfo: , PercentText1G2, 0`%
				GuiControl,ItemInfo: , PercentText1G3, 0`%
				GuiControl,ItemInfo: , PercentText1G4, 0`%
				GuiControl,ItemInfo: , PercentText1G5, 0`%
				GuiControl,ItemInfo: , PercentText1G6, 0`%
				GuiControl,ItemInfo: , PercentText1G7, 0`%
				GuiControl,ItemInfo: , PercentText1G8, 0`%
				GuiControl,ItemInfo: , PercentText1G9, 0`%
				GuiControl,ItemInfo: , PercentText1G10, 0`%
				GuiControl,ItemInfo: , PercentText1G11, 0`%
				GuiControl,ItemInfo: , PercentText1G12, 0`%
				GuiControl,ItemInfo: , PercentText1G13, 0`%
				GuiControl,ItemInfo: , PercentText1G14, 0`%
				GuiControl,ItemInfo: , PercentText1G15, 0`%
				GuiControl,ItemInfo: , PercentText1G16, 0`%
				GuiControl,ItemInfo: , PercentText1G17, 0`%
				GuiControl,ItemInfo: , PercentText1G18, 0`%
				GuiControl,ItemInfo: , PercentText1G19, 0`%
				GuiControl,ItemInfo: , PercentText1G20, 0`%
				GuiControl,ItemInfo: , PercentText1G21, 0`%
				GuiControl,ItemInfo: , PercentText2G1, 0`%
				GuiControl,ItemInfo: , PercentText2G2, 0`%
				GuiControl,ItemInfo: , PercentText2G3, 0`%
				GuiControl,ItemInfo: , PercentText2G4, 0`%
				GuiControl,ItemInfo: , PercentText2G5, 0`%
				GuiControl,ItemInfo: , PercentText2G6, 0`%
				GuiControl,ItemInfo: , PercentText2G7, 0`%
				GuiControl,ItemInfo: , PercentText2G8, 0`%
				GuiControl,ItemInfo: , PercentText2G9, 0`%
				GuiControl,ItemInfo: , PercentText2G10, 0`%
				GuiControl,ItemInfo: , PercentText2G11, 0`%
				GuiControl,ItemInfo: , PercentText2G12, 0`%
				GuiControl,ItemInfo: , PercentText2G13, 0`%
				GuiControl,ItemInfo: , PercentText2G14, 0`%
				GuiControl,ItemInfo: , PercentText2G15, 0`%
				GuiControl,ItemInfo: , PercentText2G16, 0`%
				GuiControl,ItemInfo: , PercentText2G17, 0`%
				GuiControl,ItemInfo: , PercentText2G18, 0`%
				GuiControl,ItemInfo: , PercentText2G19, 0`%
				GuiControl,ItemInfo: , PercentText2G20, 0`%
				GuiControl,ItemInfo: , PercentText2G21, 0`%

				Loop 13
				{
					XGraph_Plot( pGraph1, 100, "", True )
				}
				Loop 13
				{
					XGraph_Plot( pGraph2, 100, "", True )
				}

				GuiControl,ItemInfo: , GroupBox1, No Data
				GuiControl,ItemInfo: , PComment1,
				GuiControl,ItemInfo: , PData1, 
				GuiControl,ItemInfo: , PComment2,
				GuiControl,ItemInfo: , PData2, 
				GuiControl,ItemInfo: , PComment3,
				GuiControl,ItemInfo: , PData3, 
				GuiControl,ItemInfo: , PComment4,
				GuiControl,ItemInfo: , PData4, 
				GuiControl,ItemInfo: , PComment5,
				GuiControl,ItemInfo: , PData5, 
				GuiControl,ItemInfo: , PComment6,
				GuiControl,ItemInfo: , PData6, 
				GuiControl,ItemInfo: , PComment7,
				GuiControl,ItemInfo: , PData7, 
				GuiControl,ItemInfo: , PComment8,
				GuiControl,ItemInfo: , PData8, 
				GuiControl,ItemInfo: , PComment9,
				GuiControl,ItemInfo: , PData9, 
				GuiControl,ItemInfo: , PComment10, 
				GuiControl,ItemInfo: , PData10, 

				GuiControl,ItemInfo: , GroupBox2, No Data
				GuiControl,ItemInfo: , SComment1,
				GuiControl,ItemInfo: , SData1,
				GuiControl,ItemInfo: , SComment2,
				GuiControl,ItemInfo: , SData2,
				GuiControl,ItemInfo: , SComment3,
				GuiControl,ItemInfo: , SData3,
				GuiControl,ItemInfo: , SComment4,
				GuiControl,ItemInfo: , SData4,
				GuiControl,ItemInfo: , SComment5,
				GuiControl,ItemInfo: , SData5,
				GuiControl,ItemInfo: , SComment6,
				GuiControl,ItemInfo: , SData6,
				GuiControl,ItemInfo: , SComment7,
				GuiControl,ItemInfo: , SData7,
				GuiControl,ItemInfo: , SComment8,
				GuiControl,ItemInfo: , SData8,
				GuiControl,ItemInfo: , SComment9,
				GuiControl,ItemInfo: , SData9,
				GuiControl,ItemInfo: , SComment10,
				GuiControl,ItemInfo: , SData10
		Return
	}
	; DisplayPSA - Send Item info arrays Prop, Stats, and Affix to ItemInfo gui
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DisplayPSA()
	{
		propText=
		For key, value in Prop
		{
			If (value != 0 && value != "" && value != False)
				propText .= key . ":  " . value . "`n"
		}
		GuiControl, ItemInfo:, ItemInfoPropText, %propText%

		statText=
		For key, value in Stats
		{
			If (value != 0 && value != "" && value != False)
				statText .= key . ":  " . value . "`n"
		}
		GuiControl, ItemInfo:, ItemInfoStatText, %statText%

		affixText=
		For key, value in Affix
		{
			If (value != 0 && value != "" && value != False)
				affixText .= key . ":  " . value . "`n"
		}
		GuiControl, ItemInfo:, ItemInfoAffixText, %affixText%
	}
	; MoveStash - Input any digit and it will move to that Stash tab, only tested up to 25 tabs
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	MoveStash(Tab){
		GuiStatus("OnStash")
		If (!OnStash)
			Return
		If (CurrentTab=Tab)
			return
		If (CurrentTab!=Tab) 
		{
			Sleep, 60*Latency
			Dif:=(CurrentTab-Tab)
			If (CurrentTab = 0 || (Abs(Dif) > 20))
			{
				MouseGetPos MSx, MSy
				BlockInput, MouseMove
				Sleep, 90*Latency
				LeftClick(vX_StashTabMenu, vY_StashTabMenu)
				MouseMove, vX_StashTabList, (vY_StashTabList + (Tab*vY_StashTabSize)), 0
				Sleep, 195*Latency
				send {WheelUp 20}
				send {Enter}
				Sleep, 90*Latency
				LeftClick(vX_StashTabMenu, vY_StashTabMenu)
				CurrentTab:=Tab
				MouseMove, MSx, MSy, 0
				Sleep, 195*Latency
				BlockInput, MouseMoveOff
			}
			Else
			{
				Loop % Abs(Dif)
				{
					If (Dif > 0)
					{
						SendInput {Left}
						Sleep 15*Latency
					}
					Else
					{
						SendInput {Right}
						Sleep 15*Latency
					}
				}
				CurrentTab:=Tab
				Sleep, 170*Latency
			}
		}
		return
		}

	; StockScrolls - Restock scrolls that have more than 10 missing
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	StockScrolls(){
			BlockInput, MouseMove
			If StockWisdom{
				MouseMove %WisdomScrollX%, %WisdomScrollY%
				ClipItem(WisdomScrollX, WisdomScrollY)
				Sleep, 30*Latency
				dif := (40 - Stats.Stack)
					If (dif>10)
				{
					MoveStash(1)
					MouseMove WisdomStockX, WPStockY
					Sleep, 30*Latency
					ShiftClick(WisdomStockX, WPStockY)
						Sleep, 30*Latency
					Send %dif%
						Sleep, 45*Latency
					Send {Enter}
					Sleep, 60*Latency
					Send {Click, Down, %WisdomScrollX%, %WisdomScrollY%}
					Sleep, 30*Latency
					Send {Click, Up, %WisdomScrollX%, %WisdomScrollY%}
					Sleep, 45*Latency
				}
				Sleep, 20*Latency
			}
			If StockPortal{
				MouseMove %PortalScrollX%, %PortalScrollY%
				ClipItem(PortalScrollX, PortalScrollY)
				Sleep, 30*Latency
				dif := (40 - Stats.Stack)
					If (dif>10)
				{
					MoveStash(1)
					MouseMove PortalStockX, WPStockY
					Sleep, 30*Latency
					ShiftClick(PortalStockX, WPStockY)
						Sleep, 30*Latency
					Send %dif%
						Sleep, 45*Latency
					Send {Enter}
					Sleep, 60*Latency
					Send {Click, Down, %PortalScrollX%, %PortalScrollY%}
					Sleep, 30*Latency
					Send {Click, Up, %PortalScrollX%, %PortalScrollY%}
					Sleep, 45*Latency
				}
			}
			BlockInput, MouseMoveOff
		return
		}

	; LootScan - Finds matching colors under the cursor while key pressed
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LootScan(Reset:=0){
		LootScanCommand:
			Static NewStyle := 1, GreenHex := 0x24DE32
			If (!ComboHex || Reset)
			{
				ComboHex := Hex2FindText(GreenHex,12,1,0,0)
				ComboHex .= Hex2FindText(LootColors,0,1,1,1)
				ComboHex := """" . ComboHex . """"
				If Reset
					Return
			}
			Pressed := GetKeyState(hotkeyLootScan)
			If (Pressed&&LootVacuum)
			Loop
			{
				If AreaScale
				{
					MouseGetPos mX, mY
					ClampGameScreen(x := mX - AreaScale, y := mY - AreaScale)
					ClampGameScreen(xx := mX + AreaScale, yy := mY + AreaScale)
					Pressed := GetKeyState(hotkeyLootScan)
					If (loot := FindText(x,y,xx,yy,0,0,ComboHex,1,0))
					{
						ScanPx := loot.1.x, ScanPy := loot.1.y
						If (loot.1.id = "FIVE")
							ScanPx += 15, ScanPy += 15
						If (Pressed := GetKeyState(hotkeyLootScan))
							Click %ScanPx%, %ScanPy%
						If (LVdelay >= 60)
							Sleep, %LVdelay%
						else
							Sleep, 60
					}
				}
				Else
				{
					MouseGetPos mX, mY
					PixelGetColor, scolor, mX, mY
					If (indexOf(scolor,LootColors) || CompareHex(scolor,GreenHex,53,1))
					{
						click %mX%, %mY%
					}
				}
			} Until !Pressed
		Return
		}

; Main Script Logic Timers - TGameTick, TMineTick, TimerPassthrough
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; TGameTick - Flask Logic timer
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TGameTick(GuiCheck:=True)
	{
		If WinActive(GameStr)
		{
			If (OnTown||OnHideout)
				Exit
			OutsideTimer := A_TickCount - OutsideTimer
			t1 := A_TickCount
			; Check what status is your character in the game
			if (GuiCheck)
			{
				GuiStatus()
				if (!OnChar||OnChat||OnInventory||OnMenu)
					Exit
				t5 := A_TickCount - t1
			}
			
			if (RadioLife) {
				t2 := A_TickCount
				If (YesOHB && OnMines)
				{
					If (OHBxy := CheckOHB())
					{
						Global OHBLHealthHex, OHB
						HPerc := GetPercent(OHBLHealthHex, OHB.hpY, 70)
						If (AutoQuit&&(RadioQuit20||RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60))
						{
							GuiStatus("OnChar")
							if !(OnChar)
								Exit ; Ensure we do not exit during screen transition
							if (RadioQuit20 && HPerc < 20)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit30 && HPerc < 30)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit40 && HPerc < 40)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit50 && HPerc < 50)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit60 && HPerc < 60)
							{
								LogoutCommand()
								Exit
							}
						}

						If (AutoFlask && DisableLife != "11111" )
						{
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							If ( TriggerLife20 != "00000" && HPerc < 20) 
								TriggerFlask(TriggerLife20)
							If ( TriggerLife30 != "00000" && HPerc < 30) 
								TriggerFlask(TriggerLife30)
							If ( TriggerLife40 != "00000" && HPerc < 40) 
								TriggerFlask(TriggerLife40)
							If ( TriggerLife50 != "00000" && HPerc < 50) 
								TriggerFlask(TriggerLife50)
							If ( TriggerLife60 != "00000" && HPerc < 60) 
								TriggerFlask(TriggerLife60)
							If ( TriggerLife70 != "00000" && HPerc < 70) 
								TriggerFlask(TriggerLife70)
							If ( TriggerLife80 != "00000" && HPerc < 80) 
								TriggerFlask(TriggerLife80)
							If ( TriggerLife90 != "00000" && HPerc < 90) 
								TriggerFlask(TriggerLife90)
						}

						If ( (YesUtility1 && !OnCooldownUtility1) 
							|| (YesUtility2 && !OnCooldownUtility2) 
							|| (YesUtility3 && !OnCooldownUtility3) 
							|| (YesUtility4 && !OnCooldownUtility4) 
							|| (YesUtility5 && !OnCooldownUtility5) ) { 
							GuiStatus("OnChar")
							if !(OnChar)
								Exit

							If (HPerc < 20)
							{
								Loop, 5
									If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="20"&& !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 30)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="30" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 40)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="40" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 50)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="50" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 60)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="60" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 70)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="70" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 80)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="80" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 90)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="90" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
						}
					}
					Else
						HPerc := 100
				}
				Else
				{
					If ( (TriggerLife20!="00000") 
						|| (AutoQuit&&RadioQuit20)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="20")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="20")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="20")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="20")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="20")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life20, vX_Life, vY_Life20 
						if (Life20!=varLife20) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit20||RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 20`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="20")
									TriggerUtility(A_Index)
							}
							If (TriggerLife20!="00000")
								TriggerFlask(TriggerLife20)
							}
					}
					If ( (TriggerLife30!="00000") 
						|| (AutoQuit&&RadioQuit30)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="30")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="30")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="30")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="30")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="30")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life30, vX_Life, vY_Life30 
						if (Life30!=varLife30) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 30`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="30")
									TriggerUtility(A_Index)
							}
							If (TriggerLife30!="00000")
								TriggerFlask(TriggerLife30)
							}
					}
					If ( (TriggerLife40!="00000") 
						|| (AutoQuit&&RadioQuit40)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="40")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="40")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="40")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="40")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="40")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life40, vX_Life, vY_Life40 
						if (Life40!=varLife40) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 40`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="40")
									TriggerUtility(A_Index)
							}
							If (TriggerLife40!="00000")
								TriggerFlask(TriggerLife40)
							}
					}
					If ( (TriggerLife50!="00000")
						|| (AutoQuit&&RadioQuit50)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="50")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="50")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="50")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="50")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="50")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life50, vX_Life, vY_Life50
						if (Life50!=varLife50) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit50||RadioQuit60)) {
								Log("Exit with < 50`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="50")
									TriggerUtility(A_Index)
							}
							If (TriggerLife50!="00000")
								TriggerFlask(TriggerLife50)
							}
					}
					If ( (TriggerLife60!="00000")
						|| (AutoQuit&&RadioQuit60)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="60")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="60")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="60")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="60")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="60")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life60, vX_Life, vY_Life60
						if (Life60!=varLife60) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && RadioQuit60) {
								Log("Exit with < 60`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="60")
									TriggerUtility(A_Index)
							}
							If (TriggerLife60!="00000")
								TriggerFlask(TriggerLife60)
							}
					}
					If ( (TriggerLife70!="00000") 
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="70")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="70")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="70")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="70")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="70")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life70, vX_Life, vY_Life70
						if (Life70!=varLife70) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="70")
									TriggerUtility(A_Index)
							}
							If (TriggerLife70!="00000")
								TriggerFlask(TriggerLife70)
							}
					}
					If ( (TriggerLife80!="00000") 
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="80")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="80")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="80")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="80")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="80")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life80, vX_Life, vY_Life80
						if (Life80!=varLife80) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="80")
									TriggerUtility(A_Index)
							}
							If (TriggerLife80!="00000")
								TriggerFlask(TriggerLife80)
							}
					}
					If ( (TriggerLife90!="00000") 
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="90")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="90")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="90")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="90")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="90")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life90, vX_Life, vY_Life90
						if (Life90!=varLife90) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="90")
									TriggerUtility(A_Index)
							}
							If (TriggerLife90!="00000")
								TriggerFlask(TriggerLife90)
							}
					}
				}
				t2 := A_TickCount - t2
			}
			Else if (RadioHybrid) {
				t2 := A_TickCount
				If (YesOHB && OnMines)
				{
					If (OHBxy := CheckOHB())
					{
						Global OHBLHealthHex, OHB
						HPerc := GetPercent(OHBLHealthHex, OHB.hpY, 70)
						If (AutoQuit&&(RadioQuit20||RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60))
						{
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (RadioQuit20 && HPerc < 20)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit30 && HPerc < 30)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit40 && HPerc < 40)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit50 && HPerc < 50)
							{
								LogoutCommand()
								Exit
							}
							Else if (RadioQuit60 && HPerc < 60)
							{
								LogoutCommand()
								Exit
							}
						}
						If (AutoFlask && DisableLife != "11111" )
						{
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							If ( TriggerLife20 != "00000" && HPerc < 20) 
								TriggerFlask(TriggerLife20)
							If ( TriggerLife30 != "00000" && HPerc < 30) 
								TriggerFlask(TriggerLife30)
							If ( TriggerLife40 != "00000" && HPerc < 40) 
								TriggerFlask(TriggerLife40)
							If ( TriggerLife50 != "00000" && HPerc < 50) 
								TriggerFlask(TriggerLife50)
							If ( TriggerLife60 != "00000" && HPerc < 60) 
								TriggerFlask(TriggerLife60)
							If ( TriggerLife70 != "00000" && HPerc < 70) 
								TriggerFlask(TriggerLife70)
							If ( TriggerLife80 != "00000" && HPerc < 80) 
								TriggerFlask(TriggerLife80)
							If ( TriggerLife90 != "00000" && HPerc < 90) 
								TriggerFlask(TriggerLife90)
						}
						If ( (YesUtility1 && !OnCooldownUtility1) 
							|| (YesUtility2 && !OnCooldownUtility2) 
							|| (YesUtility3 && !OnCooldownUtility3) 
							|| (YesUtility4 && !OnCooldownUtility4) 
							|| (YesUtility5 && !OnCooldownUtility5) ) { 

							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							If (HPerc < 20)
							{
								Loop, 5
									If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="20"&& !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 30)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="30" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 40)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="40" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 50)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="50" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 60)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="60" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 70)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="70" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 80)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="80" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
							If (HPerc < 90)
							{
								Loop, 5 
									If (YesUtility%A_Index% && YesUtility%A_Index%LifePercent="90" && !OnCooldownUtility%A_Index%)
										TriggerUtility(A_Index)
							}
						}
					}
					Else
						HPerc := 100
				}
				Else
				{
					If ( (TriggerLife20!="00000") 
						|| (AutoQuit&&RadioQuit20)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="20")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="20")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="20")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="20")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="20")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life20, vX_Life, vY_Life20 
						if (Life20!=varLife20) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit20||RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 20`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="20")
									TriggerUtility(A_Index)
							}
							If (TriggerLife20!="00000")
								TriggerFlask(TriggerLife20)
							}
					}
					If ( (TriggerLife30!="00000") 
						|| (AutoQuit&&RadioQuit30)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="30")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="30")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="30")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="30")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="30")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life30, vX_Life, vY_Life30 
						if (Life30!=varLife30) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit30||RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 30`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="30")
									TriggerUtility(A_Index)
							}
							If (TriggerLife30!="00000")
								TriggerFlask(TriggerLife30)
							}
					}
					If ( (TriggerLife40!="00000") 
						|| (AutoQuit&&RadioQuit40)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="40")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="40")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="40")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="40")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="40")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life40, vX_Life, vY_Life40 
						if (Life40!=varLife40) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit40||RadioQuit50||RadioQuit60)) {
								Log("Exit with < 40`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="40")
									TriggerUtility(A_Index)
							}
							If (TriggerLife40!="00000")
								TriggerFlask(TriggerLife40)
							}
					}
					If ( (TriggerLife50!="00000")
						|| (AutoQuit&&RadioQuit50)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="50")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="50")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="50")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="50")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="50")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life50, vX_Life, vY_Life50
						if (Life50!=varLife50) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && (RadioQuit50||RadioQuit60)) {
								Log("Exit with < 50`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="50")
									TriggerUtility(A_Index)
							}
							If (TriggerLife50!="00000")
								TriggerFlask(TriggerLife50)
							}
					}
					If ( (TriggerLife60!="00000")
						|| (AutoQuit&&RadioQuit60)
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="60")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="60")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="60")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="60")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="60")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life60, vX_Life, vY_Life60
						if (Life60!=varLife60) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							if (AutoQuit && RadioQuit60) {
								Log("Exit with < 60`% Life", CurrentLocation)
								LogoutCommand()
								Exit
							}
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="60")
									TriggerUtility(A_Index)
							}
							If (TriggerLife60!="00000")
								TriggerFlask(TriggerLife60)
							}
					}
					If ( (TriggerLife70!="00000")
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="70")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="70")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="70")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="70")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="70")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life70, vX_Life, vY_Life70
						if (Life70!=varLife70) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="70")
									TriggerUtility(A_Index)
							}
							If (TriggerLife70!="00000")
								TriggerFlask(TriggerLife70)
							}
					}
					If ( (TriggerLife80!="00000")
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="80")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="80")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="80")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="80")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="80")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life80, vX_Life, vY_Life80
						if (Life80!=varLife80) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="80")
									TriggerUtility(A_Index)
							}
							If (TriggerLife80!="00000")
								TriggerFlask(TriggerLife80)
							}
					}
					If ( (TriggerLife90!="00000")
						|| ( ((YesUtility1)&&(YesUtility1LifePercent="90")&&!(OnCooldownUtility1)) 
						|| ((YesUtility2)&&(YesUtility2LifePercent="90")&&!(OnCooldownUtility2)) 
						|| ((YesUtility3)&&(YesUtility3LifePercent="90")&&!(OnCooldownUtility3)) 
						|| ((YesUtility4)&&(YesUtility4LifePercent="90")&&!(OnCooldownUtility4)) 
						|| ((YesUtility5)&&(YesUtility5LifePercent="90")&&!(OnCooldownUtility5)) ) ) {
						pixelgetcolor, Life90, vX_Life, vY_Life90
						if (Life90!=varLife90) {
							GuiStatus("OnChar")
							if !(OnChar)
								Exit
							Loop, 5 {
								If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="90")
									TriggerUtility(A_Index)
							}
							If (TriggerLife90!="00000")
								TriggerFlask(TriggerLife90)
							}
					}
				}
				t2 := A_TickCount - t2
				t3 := A_TickCount
				If ( (TriggerES20!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="20")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="20")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="20")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="20")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="20")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES20, vX_ES, vY_ES20 
					if (ES20!=varES20) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="20")
								TriggerUtility(A_Index)
						}
						If (TriggerES20!="00000")
							TriggerFlask(TriggerES20)
					}
				}
				If ( (TriggerES30!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="30")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="30")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="30")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="30")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="30")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES30, vX_ES, vY_ES30 
					if (ES30!=varES30) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="30")
								TriggerUtility(A_Index)
						}
						If (TriggerES30!="00000")
							TriggerFlask(TriggerES30)
					}
				}
				If ( (TriggerES40!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="40")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="40")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="40")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="40")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="40")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES40, vX_ES, vY_ES40 
					if (ES40!=varES40) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="40")
								TriggerUtility(A_Index)
						}
						If (TriggerES40!="00000")
							TriggerFlask(TriggerES40)
					}
				}
				If ( (TriggerES50!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="50")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="50")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="50")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="50")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="50")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES50, vX_ES, vY_ES50
					if (ES50!=varES50) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="50")
								TriggerUtility(A_Index)
						}
						If (TriggerES50!="00000")
							TriggerFlask(TriggerES50)
					}
				}
				If ( (TriggerES60!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="60")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="60")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="60")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="60")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="60")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES60, vX_ES, vY_ES60
					if (ES60!=varES60) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="60")
								TriggerUtility(A_Index)
						}
						If (TriggerES60!="00000")
							TriggerFlask(TriggerES60)
					}
				}
				If ( (TriggerES70!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="70")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="70")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="70")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="70")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="70")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES70, vX_ES, vY_ES70
					if (ES70!=varES70) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="70")
								TriggerUtility(A_Index)
						}
						If (TriggerES70!="00000")
							TriggerFlask(TriggerES70)
					}
				}
				If ( (TriggerES80!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="80")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="80")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="80")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="80")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="80")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES80, vX_ES, vY_ES80
					if (ES80!=varES80) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="80")
								TriggerUtility(A_Index)
						}
						If (TriggerES80!="00000")
							TriggerFlask(TriggerES80)
			
					}
				}
				If ( (TriggerES90!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="90")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="90")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="90")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="90")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="90")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES90, vX_ES, vY_ES90
					if (ES90!=varES90) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="90")
								TriggerUtility(A_Index)
						}
						If (TriggerES90!="00000")
							TriggerFlask(TriggerES90)
			
					}
				}
				t3 := A_TickCount - t3
			}
			Else if (RadioCi) {
				t3 := A_TickCount
				If ( (TriggerES20!="00000") 
					|| (AutoQuit&&RadioQuit20)
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="20")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="20")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="20")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="20")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="20")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES20, vX_ES, vY_ES20 
					if (ES20!=varES20) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						if (AutoQuit && (RadioQuit20 || RadioQuit30 || RadioQuit40 || RadioQuit50 || RadioQuit60)) {
								Log("Exit with < 20`% Energy Shield", CurrentLocation)
								LogoutCommand()
							Exit
						}
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="20")
								TriggerUtility(A_Index)
						}
						If (TriggerES20!="00000")
							TriggerFlask(TriggerES20)
					}
				}
				If ( (TriggerES30!="00000") 
					|| (AutoQuit&&RadioQuit30)
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="30")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="30")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="30")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="30")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="30")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES30, vX_ES, vY_ES30 
					if (ES30!=varES30) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						if (AutoQuit && (RadioQuit30 || RadioQuit40 || RadioQuit50 || RadioQuit60)) {
								Log("Exit with < 30`% Energy Shield", CurrentLocation)
								LogoutCommand()
							Exit
						}
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="30")
								TriggerUtility(A_Index)
						}
						If (TriggerES30!="00000")
							TriggerFlask(TriggerES30)
					}
				}
				If ( (TriggerES40!="00000") 
					|| (AutoQuit&&RadioQuit40)
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="40")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="40")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="40")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="40")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="40")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES40, vX_ES, vY_ES40 
					if (ES40!=varES40) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						if (AutoQuit && (RadioQuit40 || RadioQuit50 || RadioQuit60)) {
								Log("Exit with < 40`% Energy Shield", CurrentLocation)
								LogoutCommand()
							Exit
						}
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="40")
								TriggerUtility(A_Index)
						}
						If (TriggerES40!="00000")
							TriggerFlask(TriggerES40)
					}
				}
				If ( (TriggerES50!="00000")
					|| (AutoQuit&&RadioQuit50)
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="50")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="50")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="50")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="50")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="50")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES50, vX_ES, vY_ES50
					if (ES50!=varES50) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						if (AutoQuit && (RadioQuit50 || RadioQuit60)) {
								Log("Exit with < 50`% Energy Shield", CurrentLocation)
								LogoutCommand()
							Exit
						}
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="50")
								TriggerUtility(A_Index)
						}
						If (TriggerES50!="00000")
							TriggerFlask(TriggerES50)
					}
				}
				If ( (TriggerES60!="00000")
					|| (AutoQuit&&RadioQuit60)
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="60")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="60")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="60")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="60")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="60")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES60, vX_ES, vY_ES60
					if (ES60!=varES60) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						if (AutoQuit && RadioQuit60) {
								Log("Exit with < 60`% Energy Shield", CurrentLocation)
								LogoutCommand()
							Exit
						}
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="60")
								TriggerUtility(A_Index)
						}
						If (TriggerES60!="00000")
							TriggerFlask(TriggerES60)
					}
				}
				If ( (TriggerES70!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="70")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="70")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="70")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="70")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="70")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES70, vX_ES, vY_ES70
					if (ES70!=varES70) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="70")
								TriggerUtility(A_Index)
						}
						If (TriggerES70!="00000")
							TriggerFlask(TriggerES70)
					}
				}
				If ( (TriggerES80!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="80")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="80")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="80")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="80")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="80")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES80, vX_ES, vY_ES80
					if (ES80!=varES80) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="80")
								TriggerUtility(A_Index)
						}
						If (TriggerES80!="00000")
							TriggerFlask(TriggerES80)
			
					}
				}
				If ( (TriggerES90!="00000")
					|| ( ((YesUtility1)&&(YesUtility1ESPercent="90")&&!(OnCooldownUtility1)) 
					|| ((YesUtility2)&&(YesUtility2ESPercent="90")&&!(OnCooldownUtility2)) 
					|| ((YesUtility3)&&(YesUtility3ESPercent="90")&&!(OnCooldownUtility3)) 
					|| ((YesUtility4)&&(YesUtility4ESPercent="90")&&!(OnCooldownUtility4)) 
					|| ((YesUtility5)&&(YesUtility5ESPercent="90")&&!(OnCooldownUtility5)) ) ) {
					pixelgetcolor, ES90, vX_ES, vY_ES90
					if (ES90!=varES90) {
						GuiStatus("OnChar")
						if !(OnChar)
							Exit
						Loop, 5 {
							If (YesUtility%A_Index%) && (YesUtility%A_Index%ESPercent="90")
								TriggerUtility(A_Index)
						}
						If (TriggerES90!="00000")
							TriggerFlask(TriggerES90)
			
					}
				}
				t3 := A_TickCount - t3
			}
			
			If (TriggerMana10!="00000") {
				t4 := A_TickCount
				pixelgetcolor, ManaPerc, vX_Mana, vY_ManaThreshold
				if (ManaPerc!=varManaThreshold) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
					TriggerMana(TriggerMana10)
				}
				t4 := A_TickCount - t4
			}

			If (YesTimeMS)
			{
				If WinActive(GameStr)
				{
					Ding(3000,6,"Total Time:`t" . A_TickCount - t1 . "MS")
					Ding(3000,7,"Health Time:`t" . t2 . "MS")
					Ding(3000,8,"E. S. Time:`t" . t3 . "MS")
					Ding(3000,9,"Mana Time:`t" . t4 . "MS")
					Ding(3000,10,"Status Time:`t" . t5 . "MS")
					If (OutsideTimer < 999999)
						Ding(3000,11,"Out loop:`t" . OutsideTimer . "MS")
				}
			}
			OutsideTimer := A_TickCount
		}
		Return
	}
	; TMineTick - Detonate Mines timer
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TMineTick(){
		IfWinActive, ahk_group POEGameGroup
		{	
			If (OnTown||OnHideout)
				Exit
			If (DetonateMines&&!Detonated) 
				DetonateMines()
		}
		Return
		}
	
	; TimerPassthrough - Passthrough Timer
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerPassthrough:
		If ( GetKeyState(KeyFlask1Proper, "P") ) {
			OnCooldown[1]:=1
			settimer, TimerFlask1, %CooldownFlask1%
			SendMSG(3, 1)
		}
		If ( GetKeyState(KeyFlask2Proper, "P") ) {
			OnCooldown[2]:=1
			settimer, TimerFlask2, %CooldownFlask2%
			SendMSG(3, 2)
		}
		If ( GetKeyState(KeyFlask3Proper, "P") ) {
			OnCooldown[3]:=1
			settimer, TimerFlask3, %CooldownFlask3%
			SendMSG(3, 3)
		}
		If ( GetKeyState(KeyFlask4Proper, "P") ) {
			OnCooldown[4]:=1
			settimer, TimerFlask4, %CooldownFlask4%
			SendMSG(3, 4)
		}
		If ( GetKeyState(KeyFlask5Proper, "P") ) {
			OnCooldown[5]:=1
			settimer, TimerFlask5, %CooldownFlask5%
			SendMSG(3, 5)
		}
	Return
; Toggle Main Script Timers - AutoQuit, AutoFlask, AutoReset, GuiUpdate
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; AutoQuit - Toggle Auto-Quit
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	AutoQuit(){
		AutoQuitCommand:
			AutoQuit := !AutoQuit
			IniWrite, %AutoQuit%, settings.ini, Previous Toggles, AutoQuit
			if ((!AutoFlask) && (!AutoQuit)) {
				SetTimer TGameTick, Off
			} else if ((AutoFlask) || (AutoQuit)){
				SetTimer TGameTick, %Tick%
			} 
			GuiUpdate()
		return
		}

	; AutoFlask - Toggle Auto-Pot
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	AutoFlask(){
		AutoFlaskCommand:	
			AutoFlask := !AutoFlask
			IniWrite, %AutoFlask%, settings.ini, Previous Toggles, AutoFlask
			if ((!AutoFlask) and (!AutoQuit)) {
				SetTimer TGameTick, Off
			} else if ((AutoFlask) || (AutoQuit)) {
				SetTimer TGameTick, %Tick%
			}
			GuiUpdate()	
		return
		}

	; AutoReset - Load Previous Toggle States
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	AutoReset(){
		IniRead, AutoQuit, settings.ini, Previous Toggles, AutoQuit, 0
		IniRead, AutoFlask, settings.ini, Previous Toggles, AutoFlask, 0
		if ((!AutoFlask) and (!AutoQuit)) {
			SetTimer TGameTick, Off
		} else if ((AutoFlask) || (AutoQuit)) {
			SetTimer TGameTick, %Tick%
		}
		GuiUpdate()	
		return
		}

	; GuiUpdate - Update Overlay ON OFF states
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	GuiUpdate(){
			if (AutoFlask=1) {
				AutoFlaskToggle:="ON" 
			} else AutoFlaskToggle:="OFF" 
			
			if (AutoQuit=1) {
				AutoQuitToggle:="ON" 
			}else AutoQuitToggle:="OFF" 
			
			GuiControl, 2:, T1, Quit: %AutoQuitToggle%
			GuiControl, 2:, T2, Flasks: %AutoFlaskToggle%
			Return
		}

; Trigger Abilities or Flasks - MainAttackCommand, SecondaryAttackCommand, TriggerFlask, TriggerMana, TriggerUtility, DetonateMines
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; MainAttackCommand - Main attack Flasks
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	MainAttackCommand(){
		MainAttackCommand:
		If MainAttackPressedActive
			Return
		If (OnTown||OnHideout)
			Return
		if (AutoFlask || AutoQuicksilver) {
			GuiStatus()
			If (!OnChar||OnChat||OnInventory||OnMenu)
				Exit
			If AutoFlask {
				TriggerFlask(TriggerMainAttack)
				SetTimer, TimerMainAttack, %Tick%
				MainAttackPressedActive := True
			}
			If (AutoQuicksilver && QSonMainAttack) {
				If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
					If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
						Return
					SendMSG(5,1)
					SetTimer, TimerMainAttack, %Tick%
					MainAttackPressedActive := True
				}
			}
		}
		Return	

		TimerMainAttack:
			MainAttackPressed:=GetKeyState(hotkeyMainAttack)
			If (MainAttackPressed && TriggerMainAttack > 0 )
			{
				GuiStatus()
				If (!OnChar||OnChat||OnInventory||OnMenu)
					Exit
				If (AutoFlask) {
					TriggerFlask(TriggerMainAttack)
					TGameTick(False)
				}
				If (MainAttackPressed && QSonMainAttack) {
					If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
						If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
							Return
						SendMSG(5,1)
					}
				}
			}
			Else If (!MainAttackPressed){
				MainAttackPressedActive := False
				settimer,TimerMainAttack,delete
			}
		Return
		}
	; SecondaryAttackCommand - Secondary attack Flasks
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SecondaryAttackCommand(){
		SecondaryAttackCommand:
		If SecondaryAttackPressedActive
			Return
		If (OnTown||OnHideout)
			Return
		if (AutoFlask || AutoQuicksilver) {
			GuiStatus()
			If (!OnChar||OnChat||OnInventory||OnMenu)
				Exit
			If (AutoFlask) {
				TriggerFlask(TriggerSecondaryAttack)
				SetTimer, TimerSecondaryAttack, %Tick%
				SecondaryAttackPressedActive := True
			}
			If (AutoQuicksilver && QSonSecondaryAttack) {
				If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
					If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
						Return
					SendMSG(5,1)
					SetTimer, TimerSecondaryAttack, %Tick%
					SecondaryAttackPressedActive := True
				}
			}
		}
		Return	

		TimerSecondaryAttack:
			SecondaryAttackPressed:=GetKeyState(hotkeySecondaryAttack)
			If (SecondaryAttackPressed && TriggerSecondaryAttack > 0 )
			{
				GuiStatus()
				If (!OnChar||OnChat||OnInventory||OnMenu||OnTown||OnHideout)
					Exit
				If (AutoFlask) {
					TriggerFlask(TriggerSecondaryAttack)
					TGameTick(False)
				}
				If (SecondaryAttackPressed && QSonSecondaryAttack) {
					If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
						If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
							Return
						SendMSG(5,1)
					}
				}
			}
			Else If (!SecondaryAttackPressed){
				SecondaryAttackPressedActive := False
				settimer,TimerSecondaryAttack,delete
			}
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
					send %key%
					SendMSG(3, FL)
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
		If ((!FlaskList.Count())&& !( ((Radiobox1Mana10=1)&&(OnCooldown[1])) || ((Radiobox2Mana10=1)&&(OnCooldown[2])) || ((Radiobox3Mana10=1)&&(OnCooldown[3])) || ((Radiobox4Mana10=1)&&(OnCooldown[4])) || ((Radiobox5Mana10=1)&&(OnCooldown[5])) ) ) {
			FL=1
			loop, 5 {
				FLVal:=SubStr(Trigger,FL,1)+0
				if (FLVal > 0) {
					if (OnCooldown[FL]=0)
						FlaskList.Push(FL)
				}
				++FL
			}
		}
		Else If !( ((Radiobox1Mana10=1)&&(OnCooldown[1])) || ((Radiobox2Mana10=1)&&(OnCooldown[2])) || ((Radiobox3Mana10=1)&&(OnCooldown[3])) || ((Radiobox4Mana10=1)&&(OnCooldown[4])) || ((Radiobox5Mana10=1)&&(OnCooldown[5])) ) {
			FL:=FlaskList.RemoveAt(1)
			key := keyFlask%FL%
			send %key%
			OnCooldown[FL] := 1 
			Cooldown:=CooldownFlask%FL%
			settimer, TimerFlask%FL%, %Cooldown%
			SendMSG(3, FL)
			RandomSleep(23,59)
		}
		Return
	}

	; TriggerUtility - Trigger named Utility
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TriggerUtility(Utility){
		If (OnTown||OnHideout)
			Return
		If (!OnCooldownUtility%Utility%)&&(YesUtility%Utility%){
			GuiStatus()
			if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, menu open, chat open, or open inventory
				Return
			key:=KeyUtility%Utility%
			Send %key%
			SendMSG(4, Utility)
			OnCooldownUtility%Utility%:=1
			Cooldown:=CooldownUtility%Utility%
			SetTimer, TimerUtility%Utility%, %Cooldown%
		}
		Return
	} 
	; DetonateMines - Auto Detonate Mines
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DetonateMines(){
			If (OnTown||OnHideout)
				Return
			GuiStatus()
			If (!OnChar||OnChat||OnInventory||OnMenu)
				Exit
			pixelgetcolor, DelveMine, DetonateDelveX, DetonateY
			pixelgetcolor, Mine, DetonateX, DetonateY
			If ((Mine = DetonateHex)||(DelveMine = DetonateHex)){
				Sendraw, d
				Detonated:=1
				Settimer, TDetonated, -500
				Return
			}
			Return	
		}

; DebugGamestates - Show a GUI which will update based on the state of the game
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DebugGamestates(){
		Global
		ShowDebugGamestates:
			SetTimer, CheckGamestates, 50
			Gui, Submit
			; ----------------------------------------------------------------------------------------------------------------------
			Gui, States: New, +LabelStates +AlwaysOnTop -MinimizeBox
			Gui, States: Margin, 10, 10
			; ----------------------------------------------------------------------------------------------------------------------
			Gui, States: Add, Text, xm+5 y+10 w90 h20 0x200 vCTOnChar hwndCTIDOnChar, % "          OnChar "
			CtlColors.Attach(CTIDOnChar, "", "Red")
			Gui, States: Add, Text, x+5 yp w90 h20 0x200 vCTOnInventory hwndCTIDOnInventory, % "      OnInventory "
			CtlColors.Attach(CTIDOnInventory, "", "Red")
			Gui, States: Add, Text, xm+5 y+10 w90 h20 0x200 vCTOnChat hwndCTIDOnChat, % "          OnChat "
			CtlColors.Attach(CTIDOnChat, "", "Red")
			Gui, States: Add, Text, x+5 yp w90 h20 0x200 vCTOnStash hwndCTIDOnStash, % "         OnStash "
			CtlColors.Attach(CTIDOnStash, "", "Red")
			Gui, States: Add, Text, xm+5 y+10 w90 h20 0x200 vCTOnDiv hwndCTIDOnDiv, % "          OnDiv "
			CtlColors.Attach(CTIDOnDiv, "", "Red")
			Gui, States: Add, Text, x+5 yp w90 h20 0x200 vCTOnVendor hwndCTIDOnVendor, % "         OnVendor "
			CtlColors.Attach(CTIDOnVendor, "", "Red")
			Gui, States: Add, Text, xm+5 y+10 w90 h20 0x200 vCTOnMenu hwndCTIDOnMenu, % "         OnMenu "
			CtlColors.Attach(CTIDOnMenu, "", "Red")
			Gui, States: Add, Text, xm+5 y+10 w90 h20 0x200 vCTDetonateMines hwndCTIDDetonateMines, % "   DetonateMines "
			CtlColors.Attach(CTIDDetonateMines, "", "Red")
			Gui, States: Add, Text, x+5 yp w90 h20 0x200 vCTDetonateDelve hwndCTIDDetonateDelve, % "   DetonateDelve "
			CtlColors.Attach(CTIDDetonateDelve, "", "Red")
			Gui, States: Add, Button, gCheckPixelGrid xm+5 y+15 w190 , Check Inventory Grid
			; ----------------------------------------------------------------------------------------------------------------------
			Gui, States: Show ,  , Check Gamestates
		Return
		; ----------------------------------------------------------------------------------------------------------------------
		StatesClose:
		StatesEscape:
			Gui, States: Destroy
			SetTimer, CheckGamestates, Delete
			CtlColors.Free()
			Gui, 1: Show
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
			GuiStatus()
			GuiStatus("DetonateMines")
			GuiStatus("OnStash")
			GuiStatus("OnVendor")
			GuiStatus("OnDiv")
			If (OnChar)
				CtlColors.Change(CTIDOnChar, "Lime", "")
			Else
				CtlColors.Change(CTIDOnChar, "", "Red")
			If (OnInventory)
				CtlColors.Change(CTIDOnInventory, "Lime", "")
			Else
				CtlColors.Change(CTIDOnInventory, "", "Red")
			If (OnChat)
				CtlColors.Change(CTIDOnChat, "Lime", "")
			Else
				CtlColors.Change(CTIDOnChat, "", "Red")
			If (OnStash)
				CtlColors.Change(CTIDOnStash, "Lime", "")
			Else
				CtlColors.Change(CTIDOnStash, "", "Red")
			If (OnDiv)
				CtlColors.Change(CTIDOnDiv, "Lime", "")
			Else
				CtlColors.Change(CTIDOnDiv, "", "Red")
			If (OnVendor)
				CtlColors.Change(CTIDOnVendor, "Lime", "")
			Else
				CtlColors.Change(CTIDOnVendor, "", "Red")
			If (DetonateMines)
				CtlColors.Change(CTIDDetonateMines, "Lime", "")
			Else
				CtlColors.Change(CTIDDetonateMines, "", "Red")
			If (DetonateDelve)
				CtlColors.Change(CTIDDetonateDelve, "Lime", "")
			Else
				CtlColors.Change(CTIDDetonateDelve, "", "Red")
			If (OnMenu)
				CtlColors.Change(CTIDOnMenu, "Lime", "")
			Else
				CtlColors.Change(CTIDOnMenu, "", "Red")
		Return
		; ----------------------------------------------------------------------------------------------------------------------
		CheckPixelGrid:
			;Check if inventory is open
			Gui, States: Hide
			if(!OnInventory){
				TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
			}else{
				TT := "Grid information:" . "`n"
				For C, GridX in InventoryGridX	
				{
					For R, GridY in InventoryGridY
					{
						pixelgetcolor, PointColor, GridX, GridY
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

; GemSwap - Swap gems between two locations
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	GemSwap(){
		GemSwapCommand:
			Thread, NoTimers, true		;Critical
			Keywait, Alt
			BlockInput, MouseMove
			MouseGetPos xx, yy
			RandomSleep(90,120)
			
			Send {%hotkeyCloseAllUI%} 
			RandomSleep(90,120)
			
			Send {%hotkeyInventory%} 
			RandomSleep(90,120)
			
			RightClick(CurrentGemX, CurrentGemY)
			RandomSleep(90,120)
			
			if (WeaponSwap==1) 
				Send {%hotkeyWeaponSwapKey%} 
			RandomSleep(90,120)
			
			LeftClick(AlternateGemX, AlternateGemY)
				RandomSleep(90,120)
			
			if (WeaponSwap==1) 
				Send {%hotkeyWeaponSwapKey%} 
			RandomSleep(90,120)
			
			LeftClick(CurrentGemX, CurrentGemY)
				RandomSleep(90,120)
			
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
			Thread, NoTimers, true		;Critical
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
				Sleep, 90*Latency
				LeftClick(GameX + Round(GameW/2),GameY + Round(GameH/2.427))
			}
			Else
				MouseMove, xx, yy, 0
			BlockInput Off
			BlockInput MouseMoveOff
			RandomSleep(300,600)
		return
		}

; PopFlasks - Pop all flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PopFlasks(){
		PopFlasksCommand:
			Thread, NoTimers, true		;Critical
			If PopFlaskRespectCD
				TriggerFlask(TriggerPopFlasks)
			Else {
				If PopFlasks1
				{
					If YesPopAllExtraKeys 
						Send %keyFlask1% 
					Else
						Send %KeyFlask1Proper%
					OnCooldown[1]:=1 
					SendMSG(3, 1)
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
					SendMSG(3, 2)
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
					SendMSG(3, 3)
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
					SendMSG(3, 4)
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
					SendMSG(3, 5)
					Cooldown:=CooldownFlask5
					settimer, TimerFlask5, %Cooldown%
				}
			}
		return
		}

; LogoutCommand - Logout Function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LogoutCommand(){
		LogoutCommand:
			Thread, NoTimers, true		;Critical
			Static LastLogout := 0
			if (RadioCritQuit || (RadioPortalQuit && (OnMines || OnTown || OnHideout))) {
				global executable, backupExe
				succ := logout(executable)
				if (succ == 0) && backupExe != "" {
					newSucc := logout(backupExe)
					Log("ED12",executable,backupExe)
					if (newSucc == 0) {
						Log("ED13")
					}
				}
				If RelogOnQuit
				{
					RandomSleep(300,300)
					Send {Enter}
					RandomSleep(650,650)
					Send {Enter}
				}
			} 
			Else If RadioPortalQuit
			{
				If ((A_TickCount - LastLogout) > 10000)
				{
					QuickPortal(True)
					LastLogout := A_TickCount
				}
			}
			Else If RadioNormalQuit
			{
				Send {Enter} /exit {Enter}
				If RelogOnQuit
				{
					RandomSleep(300,400)
					Send {Enter}
				}
			}
			If YesOHB && OnMines
				Log("Exit with " . HPerc . "`% Life", CurrentLocation)
		return
		}

; AutoSkillUp - Check for gems that are ready to level up, and click them.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	AutoSkillUp()
	{
		If (YesAutoSkillUp && OnChar)
		{
			IfWinActive, ahk_group POEGameGroup 
			{
				if (ok:=FindText( Round(GameX + GameW * .93) , GameY + Round(GameH * .17), GameX + GameW , GameY + Round(GameH * .8), 0, 0, SkillUpStr))
				{
					If !GuiStatus("OnChar")
						Return
					X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, X+=W//2, Y+=H//2
					If (GetKeyState("LButton","P"))
						Click, up
					If (GetKeyState("RButton","P"))
						Click, Right, up
					MouseGetPos, mX, mY
					BlockInput, MouseMove
					SwiftClick(X,Y)
					MouseMove, mX, mY, 0
					Sleep, 60
					If (GetKeyState("LButton","P"))
						Click, down
					If (GetKeyState("RButton","P"))
						Click, Right, down
					BlockInput, MouseMoveOff
					ok:=""
				}
			}
		}
		Return
	}
; PoEWindowCheck - Check for the game window. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PoEWindowCheck(){
			IfWinActive, ahk_group POEGameGroup 
			{
				global GuiX, GuiY, RescaleRan, ToggleExist
				If (!RescaleRan)
					Rescale()
				If (!ToggleExist) 
				{
					Gui 2: Show, x%GuiX% y%GuiY%, NoActivate 
					ToggleExist := True
					WinActivate, ahk_group POEGameGroup
					If (YesPersistantToggle)
						AutoReset()
				}
			} 
			Else 
			{
				If (ToggleExist)
				{
					Gui 2: Show, Hide
					ToggleExist := False
					RescaleRan := False
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
			JSONtext := JSON.Dump(Ninja)
			FileDelete, %A_ScriptDir%\data\Ninja.json
			FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
			IniWrite, %Date_now%, Settings.ini, Database, LastDatabaseParseDate
			LastDatabaseParseDate := Date_now
		}
		Return
	}
; MsgMonitor - Receive Messages from other scripts
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	MsgMonitor(wParam, lParam, msg)
		{
		;Thread, NoTimers, true		;Critical
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
				GoSub, ItemSortCommand
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
    SendMSG(wParam:=0, lParam:=0, script:="GottaGoFast.ahk ahk_exe AutoHotkey.exe"){
        DetectHiddenWindows On
        if WinExist(script) 
            PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
        else 
			Ding(1000,0,"GGF Script Not Found") ;Turn on debug messages to see error information from GGF sendMSG
        DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
        Return
        }
; Coord - : Pixel information on Mouse Cursor, provides pixel location and GRB color hex
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Coord(){
		CoordCommand:
			MouseGetPos x, y
			PixelGetColor, xycolor , x, y
			TT := "  Mouse X: " . x . "  Mouse Y: " . y . "  XYColor= " . xycolor 
			Tooltip, %TT%
			SetTimer, RemoveToolTip, 10000
		Return
	}

; Configuration handling, ini updates, Hotkey handling, Profiles, Calibration, Ignore list, Loot Filter, Webpages
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	{ ; Read, Save, Load - Includes basic hotkey setup
		readFromFile(){
			global
			Thread, NoTimers, true		;Critical

			LoadArray()
			;General settings
			IniRead, Speed, settings.ini, General, Speed, 1
			IniRead, Tick, settings.ini, General, Tick, 50
			IniRead, QTick, settings.ini, General, QTick, 250
			IniRead, DebugMessages, settings.ini, General, DebugMessages, 0
			IniRead, YesTimeMS, settings.ini, General, YesTimeMS, 0
			IniRead, YesLocation, settings.ini, General, YesLocation, 0
			IniRead, ShowPixelGrid, settings.ini, General, ShowPixelGrid, 0
			IniRead, ShowItemInfo, settings.ini, General, ShowItemInfo, 0
			IniRead, DetonateMines, settings.ini, General, DetonateMines, 0
			IniRead, LootVacuum, settings.ini, General, LootVacuum, 0
			IniRead, YesVendor, settings.ini, General, YesVendor, 1
			IniRead, YesStash, settings.ini, General, YesStash, 1
			IniRead, YesIdentify, settings.ini, General, YesIdentify, 1
			IniRead, YesDiv, settings.ini, General, YesDiv, 1
			IniRead, YesMapUnid, settings.ini, General, YesMapUnid, 1
			IniRead, YesSortFirst, settings.ini, General, YesSortFirst, 1
			IniRead, Latency, settings.ini, General, Latency, 1
			IniRead, ShowOnStart, settings.ini, General, ShowOnStart, 1
			IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
			IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
			IniRead, Steam, settings.ini, General, Steam, 1
			IniRead, HighBits, settings.ini, General, HighBits, 1
			IniRead, AutoUpdateOff, settings.ini, General, AutoUpdateOff, 0
			IniRead, EnableChatHotkeys, settings.ini, General, EnableChatHotkeys, 1
			IniRead, CharName, settings.ini, General, CharName, ReplaceWithCharName
			IniRead, EnableChatHotkeys, settings.ini, General, EnableChatHotkeys, 1
			IniRead, YesStashKeys, settings.ini, General, YesStashKeys, 1
			IniRead, QSonMainAttack, settings.ini, General, QSonMainAttack, 0
			IniRead, QSonSecondaryAttack, settings.ini, General, QSonSecondaryAttack, 0
			IniRead, YesPersistantToggle, settings.ini, General, YesPersistantToggle, 0
			IniRead, YesPopAllExtraKeys, settings.ini, General, YesPopAllExtraKeys, 0
			IniRead, ManaThreshold, settings.ini, General, ManaThreshold, 0
			IniRead, YesEldritchBattery, settings.ini, General, YesEldritchBattery, 0
			IniRead, YesStashT1, settings.ini, General, YesStashT1, 1
			IniRead, YesStashT2, settings.ini, General, YesStashT2, 1
			IniRead, YesStashT3, settings.ini, General, YesStashT3, 1
			IniRead, YesStashCraftingNormal, settings.ini, General, YesStashCraftingNormal, 1
			IniRead, YesStashCraftingMagic, settings.ini, General, YesStashCraftingMagic, 1
			IniRead, YesStashCraftingRare, settings.ini, General, YesStashCraftingRare, 1
			IniRead, YesAutoSkillUp, settings.ini, General, YesAutoSkillUp, 0
			IniRead, YesClickPortal, settings.ini, General, YesClickPortal, 0
			IniRead, RelogOnQuit, settings.ini, General, RelogOnQuit, 0
			IniRead, AreaScale, settings.ini, General, AreaScale, 60
			IniRead, LVdelay, settings.ini, General, LVdelay, 15

			;Settings for Auto-Vendor
			IniRead, YesSearchForStash, settings.ini, General, YesSearchForStash, 0
			IniRead, YesVendorAfterStash, settings.ini, General, YesVendorAfterStash, 0
			
			;Stash Tab Management
			IniRead, StashTabCurrency, settings.ini, Stash Tab, StashTabCurrency, 1
			IniRead, StashTabMap, settings.ini, Stash Tab, StashTabMap, 1
			IniRead, StashTabDivination, settings.ini, Stash Tab, StashTabDivination, 1
			IniRead, StashTabGem, settings.ini, Stash Tab, StashTabGem, 1
			IniRead, StashTabGemQuality, settings.ini, Stash Tab, StashTabGemQuality, 1
			IniRead, StashTabFlaskQuality, settings.ini, Stash Tab, StashTabFlaskQuality, 1
			IniRead, StashTabLinked, settings.ini, Stash Tab, StashTabLinked, 1
			IniRead, StashTabCollection, settings.ini, Stash Tab, StashTabCollection, 1
			IniRead, StashTabUniqueRing, settings.ini, Stash Tab, StashTabUniqueRing, 1
			IniRead, StashTabUniqueDump, settings.ini, Stash Tab, StashTabUniqueDump, 1
			IniRead, StashTabFragment, settings.ini, Stash Tab, StashTabFragment, 1
			IniRead, StashTabEssence, settings.ini, Stash Tab, StashTabEssence, 1
			IniRead, StashTabOil, settings.ini, Stash Tab, StashTabOil, 1
			IniRead, StashTabFossil, settings.ini, Stash Tab, StashTabFossil, 1
			IniRead, StashTabResonator, settings.ini, Stash Tab, StashTabResonator, 1
			IniRead, StashTabCrafting, settings.ini, Stash Tab, StashTabCrafting, 1
			IniRead, StashTabProphecy, settings.ini, Stash Tab, StashTabProphecy, 1
			IniRead, StashTabVeiled, settings.ini, Stash Tab, StashTabVeiled, 1
			IniRead, StashTabYesCurrency, settings.ini, Stash Tab, StashTabYesCurrency, 1
			IniRead, StashTabYesMap, settings.ini, Stash Tab, StashTabYesMap, 1
			IniRead, StashTabYesDivination, settings.ini, Stash Tab, StashTabYesDivination, 1
			IniRead, StashTabYesGem, settings.ini, Stash Tab, StashTabYesGem, 1
			IniRead, StashTabYesGemQuality, settings.ini, Stash Tab, StashTabYesGemQuality, 1
			IniRead, StashTabYesFlaskQuality, settings.ini, Stash Tab, StashTabYesFlaskQuality, 1
			IniRead, StashTabYesLinked, settings.ini, Stash Tab, StashTabYesLinked, 1
			IniRead, StashTabYesCollection, settings.ini, Stash Tab, StashTabYesCollection, 1
			IniRead, StashTabYesUniqueRing, settings.ini, Stash Tab, StashTabYesUniqueRing, 1
			IniRead, StashTabYesUniqueDump, settings.ini, Stash Tab, StashTabYesUniqueDump, 1
			IniRead, StashTabYesFragment, settings.ini, Stash Tab, StashTabYesFragment, 1
			IniRead, StashTabYesEssence, settings.ini, Stash Tab, StashTabYesEssence, 1
			IniRead, StashTabYesOil, settings.ini, Stash Tab, StashTabYesOil, 1
			IniRead, StashTabYesFossil, settings.ini, Stash Tab, StashTabYesFossil, 1
			IniRead, StashTabYesResonator, settings.ini, Stash Tab, StashTabYesResonator, 1
			IniRead, StashTabYesCrafting, settings.ini, Stash Tab, StashTabYesCrafting, 1
			IniRead, StashTabYesProphecy, settings.ini, Stash Tab, StashTabYesProphecy, 1
			IniRead, StashTabYesVeiled, settings.ini, Stash Tab, StashTabYesVeiled, 1
			
			;Settings for the Client Log file location
			IniRead, ClientLog, Settings.ini, Log, ClientLog, %ClientLog%

			If FileExist(ClientLog)
				Monitor_GameLogs(1)
			Else
			{
                MsgBox, 262144, Client Log Error, Client.txt Log File not found!`nAssign the location in Configuration Tab`nClick ""Locate Logfile"" to find yours
				Log("Client Log not Found",ClientLog)
			}
			
			;Settings for the Overhead Health Bar
			IniRead, YesOHB, settings.ini, OHB, YesOHB, 1
			
			;OHB Colors
			IniRead, OHBLHealthHex, settings.ini, OHB, OHBLHealthHex, 0x19A631

			;Ascii strings
			IniRead, HealthBarStr, settings.ini, FindText Strings, HealthBarStr, %1080_HealthBarStr%
			If HealthBarStr
			{
				HealthBarStr := """" . HealthBarStr . """"
				OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
			}
			IniRead, VendorStr, settings.ini, FindText Strings, VendorStr, %1080_MasterStr%
			If VendorStr
				VendorStr := """" . VendorStr . """"
			IniRead, SellItemsStr, settings.ini, FindText Strings, SellItemsStr, %1080_SellItemsStr%
			If SellItemsStr
				SellItemsStr := """" . SellItemsStr . """"
			IniRead, StashStr, settings.ini, FindText Strings, StashStr, %1080_StashStr%
			If StashStr
				StashStr := """" . StashStr . """"
			IniRead, SkillUpStr, settings.ini, FindText Strings, SkillUpStr, %1080_SkillUpStr%
			If SkillUpStr
				SkillUpStr := """" . SkillUpStr . """"

			;Inventory Colors
			IniRead, varEmptyInvSlotColor, settings.ini, Inventory Colors, EmptyInvSlotColor, 0x000100, 0x020402, 0x000000, 0x020302, 0x010101, 0x010201, 0x060906, 0x050905
			;Create an array out of the read string
			varEmptyInvSlotColor := StrSplit(varEmptyInvSlotColor, ",")

			;Loot Vacuum Colors
			IniRead, LootColors, settings.ini, Loot Colors, LootColors, 0xC4FEF6, 0x99FECC, 0x6565A3, 0x383877
			;Create an array out of the read string
			LootColors := StrSplit(LootColors, ",")

			;Failsafe Colors
			IniRead, varOnMenu, settings.ini, Failsafe Colors, OnMenu, 0x7BB9D6
			IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar, 0x4F6980
			IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat, 0x3B6288
			IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory, 0x8CC6DD
			IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash, 0x9BD6E7
			IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor, 0x7BB1CC
			IniRead, varOnDiv, settings.ini, Failsafe Colors, OnDiv, 0xC5E2F6
			IniRead, DetonateHex, settings.ini, Failsafe Colors, DetonateHex, 0x412037

			;Life Colors
			IniRead, varLife20, settings.ini, Life Colors, Life20, 0x181145
			IniRead, varLife30, settings.ini, Life Colors, Life30, 0x181264
			IniRead, varLife40, settings.ini, Life Colors, Life40, 0x190F7D
			IniRead, varLife50, settings.ini, Life Colors, Life50, 0x2318A5
			IniRead, varLife60, settings.ini, Life Colors, Life60, 0x2215B4
			IniRead, varLife70, settings.ini, Life Colors, Life70, 0x2413B3
			IniRead, varLife80, settings.ini, Life Colors, Life80, 0x2B2385
			IniRead, varLife90, settings.ini, Life Colors, Life90, 0x664564
				
			;ES Colors
			IniRead, varES20, settings.ini, ES Colors, ES20, 0xFFC445
			IniRead, varES30, settings.ini, ES Colors, ES30, 0xFFCE66
			IniRead, varES40, settings.ini, ES Colors, ES40, 0xFFFF85
			IniRead, varES50, settings.ini, ES Colors, ES50, 0xFFFF82
			IniRead, varES60, settings.ini, ES Colors, ES60, 0xFFFF95
			IniRead, varES70, settings.ini, ES Colors, ES70, 0xFFD07F
			IniRead, varES80, settings.ini, ES Colors, ES80, 0xE89C5E
			IniRead, varES90, settings.ini, ES Colors, ES90, 0xE79435
			
			;Mana Colors
			IniRead, varMana10, settings.ini, Mana Colors, Mana10, 0x3C201D
			IniRead, varManaThreshold, settings.ini, Mana Colors, ManaThreshold, 0x3C201D
			
			;Life Triggers
			IniRead, TriggerLife20, settings.ini, Life Triggers, TriggerLife20, 00000
			IniRead, TriggerLife30, settings.ini, Life Triggers, TriggerLife30, 00000
			IniRead, TriggerLife40, settings.ini, Life Triggers, TriggerLife40, 00000
			IniRead, TriggerLife50, settings.ini, Life Triggers, TriggerLife50, 00000
			IniRead, TriggerLife60, settings.ini, Life Triggers, TriggerLife60, 00000
			IniRead, TriggerLife70, settings.ini, Life Triggers, TriggerLife70, 00000
			IniRead, TriggerLife80, settings.ini, Life Triggers, TriggerLife80, 00000
			IniRead, TriggerLife90, settings.ini, Life Triggers, TriggerLife90, 00000
			IniRead, DisableLife, settings.ini, Life Triggers, DisableLife, 11111
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
			IniRead, TriggerES20, settings.ini, ES Triggers, TriggerES20, 00000
			IniRead, TriggerES30, settings.ini, ES Triggers, TriggerES30, 00000
			IniRead, TriggerES40, settings.ini, ES Triggers, TriggerES40, 00000
			IniRead, TriggerES50, settings.ini, ES Triggers, TriggerES50, 00000
			IniRead, TriggerES60, settings.ini, ES Triggers, TriggerES60, 00000
			IniRead, TriggerES70, settings.ini, ES Triggers, TriggerES70, 00000
			IniRead, TriggerES80, settings.ini, ES Triggers, TriggerES80, 00000
			IniRead, TriggerES90, settings.ini, ES Triggers, TriggerES90, 00000
			IniRead, DisableES, settings.ini, ES Triggers, DisableES, 11111
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
			IniRead, TriggerMana10, settings.ini, Mana Triggers, TriggerMana10, 00000
			Loop, 5 {	
				valueMana10 := substr(TriggerMana10, (A_Index), 1)
				GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
			}
			
			;Utility Buttons
			IniRead, YesUtility1, settings.ini, Utility Buttons, YesUtility1, 0
			IniRead, YesUtility2, settings.ini, Utility Buttons, YesUtility2, 0
			IniRead, YesUtility3, settings.ini, Utility Buttons, YesUtility3, 0
			IniRead, YesUtility4, settings.ini, Utility Buttons, YesUtility4, 0
			IniRead, YesUtility5, settings.ini, Utility Buttons, YesUtility5, 0
			IniRead, YesUtility1Quicksilver, settings.ini, Utility Buttons, YesUtility1Quicksilver, 0
			IniRead, YesUtility2Quicksilver, settings.ini, Utility Buttons, YesUtility2Quicksilver, 0
			IniRead, YesUtility3Quicksilver, settings.ini, Utility Buttons, YesUtility3Quicksilver, 0
			IniRead, YesUtility4Quicksilver, settings.ini, Utility Buttons, YesUtility4Quicksilver, 0
			IniRead, YesUtility5Quicksilver, settings.ini, Utility Buttons, YesUtility5Quicksilver, 0
			
			;Utility Percents	
			IniRead, YesUtility1LifePercent, settings.ini, Utility Buttons, YesUtility1LifePercent, Off
			IniRead, YesUtility2LifePercent, settings.ini, Utility Buttons, YesUtility2LifePercent, Off
			IniRead, YesUtility3LifePercent, settings.ini, Utility Buttons, YesUtility3LifePercent, Off
			IniRead, YesUtility4LifePercent, settings.ini, Utility Buttons, YesUtility4LifePercent, Off
			IniRead, YesUtility5LifePercent, settings.ini, Utility Buttons, YesUtility5LifePercent, Off
			IniRead, YesUtility1EsPercent, settings.ini, 	Utility Buttons, YesUtility1EsPercent, Off
			IniRead, YesUtility2EsPercent, settings.ini, 	Utility Buttons, YesUtility2EsPercent, Off
			IniRead, YesUtility3EsPercent, settings.ini, 	Utility Buttons, YesUtility3EsPercent, Off
			IniRead, YesUtility4EsPercent, settings.ini, 	Utility Buttons, YesUtility4EsPercent, Off
			IniRead, YesUtility5EsPercent, settings.ini, 	Utility Buttons, YesUtility5EsPercent, Off
			
			;Utility Cooldowns
			IniRead, CooldownUtility1, settings.ini, Utility Cooldowns, CooldownUtility1, 5000
			IniRead, CooldownUtility2, settings.ini, Utility Cooldowns, CooldownUtility2, 5000
			IniRead, CooldownUtility3, settings.ini, Utility Cooldowns, CooldownUtility3, 5000
			IniRead, CooldownUtility4, settings.ini, Utility Cooldowns, CooldownUtility4, 5000
			IniRead, CooldownUtility5, settings.ini, Utility Cooldowns, CooldownUtility5, 5000
			
			;Utility Keys
			IniRead, KeyUtility1, settings.ini, Utility Keys, KeyUtility1, q
			IniRead, KeyUtility2, settings.ini, Utility Keys, KeyUtility2, w
			IniRead, KeyUtility3, settings.ini, Utility Keys, KeyUtility3, e
			IniRead, KeyUtility4, settings.ini, Utility Keys, KeyUtility4, r
			IniRead, KeyUtility5, settings.ini, Utility Keys, KeyUtility5, t

			;Utility Icon Strings
			IniRead, IconStringUtility1, settings.ini, Utility Icons, IconStringUtility1, %A_Space%
			If IconStringUtility1
				IconStringUtility1 := """" . IconStringUtility1 . """"
			IniRead, IconStringUtility2, settings.ini, Utility Icons, IconStringUtility2, %A_Space%
			If IconStringUtility2
				IconStringUtility2 := """" . IconStringUtility2 . """"
			IniRead, IconStringUtility3, settings.ini, Utility Icons, IconStringUtility3, %A_Space%
			If IconStringUtility3
				IconStringUtility3 := """" . IconStringUtility3 . """"
			IniRead, IconStringUtility4, settings.ini, Utility Icons, IconStringUtility4, %A_Space%
			If IconStringUtility4
				IconStringUtility4 := """" . IconStringUtility4 . """"
			IniRead, IconStringUtility5, settings.ini, Utility Icons, IconStringUtility5, %A_Space%
			If IconStringUtility5
				IconStringUtility5 := """" . IconStringUtility5 . """"

			;Utility Keys
			IniRead, hotkeyUp, 		settings.ini, Controller Keys, hotkeyUp, 	w
			IniRead, hotkeyDown, 	settings.ini, Controller Keys, hotkeyDown,  s
			IniRead, hotkeyLeft, 	settings.ini, Controller Keys, hotkeyLeft,  a
			IniRead, hotkeyRight, 	settings.ini, Controller Keys, hotkeyRight, d
			
			;Flask Cooldowns
			IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1, 4800
			IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2, 4800
			IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3, 4800
			IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4, 4800
			IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5, 4800

			;Flask Keys
			IniRead, keyFlask1, settings.ini, Flask Keys, keyFlask1, 1
			IniRead, keyFlask2, settings.ini, Flask Keys, keyFlask2, 2
			IniRead, keyFlask3, settings.ini, Flask Keys, keyFlask3, 3
			IniRead, keyFlask4, settings.ini, Flask Keys, keyFlask4, 4
			IniRead, keyFlask5, settings.ini, Flask Keys, keyFlask5, 5
			
			Loop 5
			{
				key := keyFlask%A_Index%
				str := StrSplit(key, " ", ,2)
				KeyFlask%A_Index%Proper := str[1]
			}
			
			;Gem Swap
			IniRead, CurrentGemX, settings.ini, Gem Swap, CurrentGemX, 1353
			IniRead, CurrentGemY, settings.ini, Gem Swap, CurrentGemY, 224
			IniRead, AlternateGemX, settings.ini, Gem Swap, AlternateGemX, 1407
			IniRead, AlternateGemY, settings.ini, Gem Swap, AlternateGemY, 201
			IniRead, AlternateGemOnSecondarySlot, settings.ini, Gem Swap, AlternateGemOnSecondarySlot, 0
			
			;Coordinates
			IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
			IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027
			IniRead, PortalScrollX, settings.ini, Coordinates, PortalScrollX, 1825
			IniRead, PortalScrollY, settings.ini, Coordinates, PortalScrollY, 825
			IniRead, WisdomScrollX, settings.ini, Coordinates, WisdomScrollX, 1875
			IniRead, WisdomScrollY, settings.ini, Coordinates, WisdomScrollY, 825
			IniRead, StockPortal, settings.ini, Coordinates, StockPortal, 0
			IniRead, StockWisdom, settings.ini, Coordinates, StockWisdom, 0
			
			
			;Attack Flasks
			IniRead, TriggerMainAttack, settings.ini, Attack Triggers, TriggerMainAttack, 00000
			IniRead, TriggerSecondaryAttack, settings.ini, Attack Triggers, TriggerSecondaryAttack, 00000
			Loop, 5{	
				valueMainAttack := substr(TriggerMainAttack, (A_Index), 1)
				GuiControl, , MainAttackbox%A_Index%, %valueMainAttack%
				valueSecondaryAttack := substr(TriggerSecondaryAttack, (A_Index), 1)
				GuiControl, , SecondaryAttackbox%A_Index%, %valueSecondaryAttack%
			}
			
			;Quicksilver
			IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, .5
			IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
			Loop, 5 {	
				valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
				GuiControl, , Radiobox%A_Index%QS, %valueQuicksilver%
			}
			
			;Pop Flasks
			IniRead, TriggerPopFlasks, settings.ini, PopFlasks, TriggerPopFlasks, 11111
			Loop, 5 {	
				valuePopFlasks := substr(TriggerPopFlasks, (A_Index), 1)
				GuiControl, , PopFlasks%A_Index%, %valuePopFlasks%
			}
			
			;CharacterTypeCheck
			IniRead, RadioLife, settings.ini, CharacterTypeCheck, Life, 1
			IniRead, RadioHybrid, settings.ini, CharacterTypeCheck, Hybrid, 0
			IniRead, RadioCi, settings.ini, CharacterTypeCheck, Ci, 0
			
			;AutoQuit
			IniRead, RadioQuit20, settings.ini, AutoQuit, Quit20, 1
			IniRead, RadioQuit30, settings.ini, AutoQuit, Quit30, 0
			IniRead, RadioQuit40, settings.ini, AutoQuit, Quit40, 0
			IniRead, RadioQuit50, settings.ini, AutoQuit, Quit50, 0
			IniRead, RadioQuit60, settings.ini, AutoQuit, Quit60, 0
			IniRead, RadioCritQuit, settings.ini, AutoQuit, CritQuit, 1
			IniRead, RadioPortalQuit, settings.ini, AutoQuit, PortalQuit, 0
			IniRead, RadioNormalQuit, settings.ini, AutoQuit, NormalQuit, 0
			
			;Profile Editbox
			Iniread, ProfileText1, settings.ini, Profiles, ProfileText1, Profile 1
			Iniread, ProfileText2, settings.ini, Profiles, ProfileText2, Profile 2
			Iniread, ProfileText3, settings.ini, Profiles, ProfileText3, Profile 3
			Iniread, ProfileText4, settings.ini, Profiles, ProfileText4, Profile 4
			Iniread, ProfileText5, settings.ini, Profiles, ProfileText5, Profile 5
			Iniread, ProfileText6, settings.ini, Profiles, ProfileText6, Profile 6
			Iniread, ProfileText7, settings.ini, Profiles, ProfileText7, Profile 7
			Iniread, ProfileText8, settings.ini, Profiles, ProfileText8, Profile 8
			Iniread, ProfileText9, settings.ini, Profiles, ProfileText9, Profile 9
			Iniread, ProfileText10, settings.ini, Profiles, ProfileText10, Profile 10

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
			If hotkeyLootScan
				hotkey, $~%hotkeyLootScan%, LootScanCommand, Off
			If hotkeyMainAttack
				hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
			If hotkeySecondaryAttack
				hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off

			hotkey, IfWinActive
			If hotkeyOptions
				hotkey,% hotkeyOptions, optionsCommand, Off
			hotkey, IfWinActive, ahk_group POEGameGroup
				
			;~ hotkeys iniread
			IniRead, hotkeyOptions, settings.ini, hotkeys, Options, !F10
			IniRead, hotkeyAutoQuit, settings.ini, hotkeys, AutoQuit, !F12
			IniRead, hotkeyAutoFlask, settings.ini, hotkeys, AutoFlask, !F11
			IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, !MButton
			IniRead, hotkeyQuickPortal, settings.ini, hotkeys, QuickPortal, !q
			IniRead, hotkeyGemSwap, settings.ini, hotkeys, GemSwap, !e
			IniRead, hotkeyGetMouseCoords, settings.ini, hotkeys, GetMouseCoords, !o
			IniRead, hotkeyPopFlasks, settings.ini, hotkeys, PopFlasks, CapsLock
			IniRead, hotkeyLogout, settings.ini, hotkeys, Logout, F12
			IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI, Space
			IniRead, hotkeyInventory, settings.ini, hotkeys, Inventory, c
			IniRead, hotkeyWeaponSwapKey, settings.ini, hotkeys, WeaponSwapKey, x
			IniRead, hotkeyItemSort, settings.ini, hotkeys, ItemSort, F6
			IniRead, hotkeyItemInfo, settings.ini, hotkeys, ItemInfo, F5
			IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan, f
			IniRead, hotkeyMainAttack, settings.ini, hotkeys, MainAttack, RButton
			IniRead, hotkeySecondaryAttack, settings.ini, hotkeys, SecondaryAttack, w
			
			hotkey, IfWinActive, ahk_group POEGameGroup
			If hotkeyAutoQuit
				hotkey,% hotkeyAutoQuit, AutoQuitCommand, On
			If hotkeyAutoFlask
				hotkey,% hotkeyAutoFlask, AutoFlaskCommand, On
			If hotkeyQuickPortal
				hotkey,% hotkeyQuickPortal, QuickPortalCommand, On
			If hotkeyGemSwap
				hotkey,% hotkeyGemSwap, GemSwapCommand, On
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
			If hotkeyLootScan
				hotkey, $~%hotkeyLootScan%, LootScanCommand, On
			If hotkeyMainAttack
				hotkey, $~%hotkeyMainAttack%, MainAttackCommand, On
			If hotkeySecondaryAttack
				hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, On
			
			hotkey, IfWinActive
			If hotkeyOptions {
				hotkey,% hotkeyOptions, optionsCommand, On
				} else {
				hotkey,!F10, optionsCommand, On
				msgbox You dont have set the GUI hotkey!`nPlease hit Alt+F10 to open up the GUI and set your hotkey.
				}
			
			IniRead, 1Prefix1, settings.ini, Chat Hotkeys, 1Prefix1, a
			IniRead, 1Prefix2, settings.ini, Chat Hotkeys, 1Prefix2, %A_Space%
			IniRead, 1Suffix1, settings.ini, Chat Hotkeys, 1Suffix1, 1
			IniRead, 1Suffix2, settings.ini, Chat Hotkeys, 1Suffix2, 2
			IniRead, 1Suffix3, settings.ini, Chat Hotkeys, 1Suffix3, 3
			IniRead, 1Suffix4, settings.ini, Chat Hotkeys, 1Suffix4, 4
			IniRead, 1Suffix5, settings.ini, Chat Hotkeys, 1Suffix5, 5
			IniRead, 1Suffix6, settings.ini, Chat Hotkeys, 1Suffix6, 6
			IniRead, 1Suffix7, settings.ini, Chat Hotkeys, 1Suffix7, 7
			IniRead, 1Suffix8, settings.ini, Chat Hotkeys, 1Suffix8, 8
			IniRead, 1Suffix9, settings.ini, Chat Hotkeys, 1Suffix9, 9

			IniRead, 1Suffix1Text, settings.ini, Chat Hotkeys, 1Suffix1Text, /Hideout
			IniRead, 1Suffix2Text, settings.ini, Chat Hotkeys, 1Suffix2Text, /Delve
			IniRead, 1Suffix3Text, settings.ini, Chat Hotkeys, 1Suffix3Text, /cls
			IniRead, 1Suffix4Text, settings.ini, Chat Hotkeys, 1Suffix4Text, /ladder
			IniRead, 1Suffix5Text, settings.ini, Chat Hotkeys, 1Suffix5Text, /reset_xp
			IniRead, 1Suffix6Text, settings.ini, Chat Hotkeys, 1Suffix6Text, /invite RecipientName
			IniRead, 1Suffix7Text, settings.ini, Chat Hotkeys, 1Suffix7Text, /kick RecipientName
			IniRead, 1Suffix8Text, settings.ini, Chat Hotkeys, 1Suffix8Text, /kick CharacterName
			IniRead, 1Suffix9Text, settings.ini, Chat Hotkeys, 1Suffix9Text, @RecipientName Still Interested?

			IniRead, 2Prefix1, settings.ini, Chat Hotkeys, 2Prefix1, d
			IniRead, 2Prefix2, settings.ini, Chat Hotkeys, 2Prefix2, %A_Space%
			IniRead, 2Suffix1, settings.ini, Chat Hotkeys, 2Suffix1, 1
			IniRead, 2Suffix2, settings.ini, Chat Hotkeys, 2Suffix2, 2
			IniRead, 2Suffix3, settings.ini, Chat Hotkeys, 2Suffix3, 3
			IniRead, 2Suffix4, settings.ini, Chat Hotkeys, 2Suffix4, 4
			IniRead, 2Suffix5, settings.ini, Chat Hotkeys, 2Suffix5, 5
			IniRead, 2Suffix6, settings.ini, Chat Hotkeys, 2Suffix6, 6
			IniRead, 2Suffix7, settings.ini, Chat Hotkeys, 2Suffix7, 7
			IniRead, 2Suffix8, settings.ini, Chat Hotkeys, 2Suffix8, 8
			IniRead, 2Suffix9, settings.ini, Chat Hotkeys, 2Suffix9, 9
			
			IniRead, 2Suffix1Text, settings.ini, Chat Hotkeys, 2Suffix1Text, Sure, will invite in a sec.
			IniRead, 2Suffix2Text, settings.ini, Chat Hotkeys, 2Suffix2Text, In a map, will get to you in a minute.
			IniRead, 2Suffix3Text, settings.ini, Chat Hotkeys, 2Suffix3Text, Still Interested?
			IniRead, 2Suffix4Text, settings.ini, Chat Hotkeys, 2Suffix4Text, Sorry, going to be a while.
			IniRead, 2Suffix5Text, settings.ini, Chat Hotkeys, 2Suffix5Text, No thank you.
			IniRead, 2Suffix6Text, settings.ini, Chat Hotkeys, 2Suffix6Text, No thank you.
			IniRead, 2Suffix7Text, settings.ini, Chat Hotkeys, 2Suffix7Text, No thank you.
			IniRead, 2Suffix8Text, settings.ini, Chat Hotkeys, 2Suffix8Text, No thank you.
			IniRead, 2Suffix9Text, settings.ini, Chat Hotkeys, 2Suffix9Text, No thank you.

			IniRead, stashReset, settings.ini, Stash Hotkeys, stashReset, NumpadDot
			IniRead, stashPrefix1, settings.ini, Stash Hotkeys, stashPrefix1, Numpad0
			IniRead, stashPrefix2, settings.ini, Stash Hotkeys, stashPrefix2, %A_Space%
			IniRead, stashSuffix1, settings.ini, Stash Hotkeys, stashSuffix1, Numpad1
			IniRead, stashSuffix2, settings.ini, Stash Hotkeys, stashSuffix2, Numpad2
			IniRead, stashSuffix3, settings.ini, Stash Hotkeys, stashSuffix3, Numpad3
			IniRead, stashSuffix4, settings.ini, Stash Hotkeys, stashSuffix4, Numpad4
			IniRead, stashSuffix5, settings.ini, Stash Hotkeys, stashSuffix5, Numpad5
			IniRead, stashSuffix6, settings.ini, Stash Hotkeys, stashSuffix6, Numpad6
			IniRead, stashSuffix7, settings.ini, Stash Hotkeys, stashSuffix7, Numpad7
			IniRead, stashSuffix8, settings.ini, Stash Hotkeys, stashSuffix8, Numpad8
			IniRead, stashSuffix9, settings.ini, Stash Hotkeys, stashSuffix9, Numpad9
			
			IniRead, stashSuffixTab1, settings.ini, Stash Hotkeys, stashSuffixTab1, 1
			IniRead, stashSuffixTab2, settings.ini, Stash Hotkeys, stashSuffixTab2, 2
			IniRead, stashSuffixTab3, settings.ini, Stash Hotkeys, stashSuffixTab3, 3
			IniRead, stashSuffixTab4, settings.ini, Stash Hotkeys, stashSuffixTab4, 4
			IniRead, stashSuffixTab5, settings.ini, Stash Hotkeys, stashSuffixTab5, 5
			IniRead, stashSuffixTab6, settings.ini, Stash Hotkeys, stashSuffixTab6, 6
			IniRead, stashSuffixTab7, settings.ini, Stash Hotkeys, stashSuffixTab7, 7
			IniRead, stashSuffixTab8, settings.ini, Stash Hotkeys, stashSuffixTab8, 8
			IniRead, stashSuffixTab9, settings.ini, Stash Hotkeys, stashSuffixTab9, 9


			;Controller setup
			IniRead, hotkeyControllerButton1, settings.ini, Controller Keys, ControllerButton1, ^LButton
			IniRead, hotkeyControllerButton2, settings.ini, Controller Keys, ControllerButton2, %hotkeyLootScan%
			IniRead, hotkeyControllerButton3, settings.ini, Controller Keys, ControllerButton3, r
			IniRead, hotkeyControllerButton4, settings.ini, Controller Keys, ControllerButton4, %hotkeyCloseAllUI%
			IniRead, hotkeyControllerButton5, settings.ini, Controller Keys, ControllerButton5, e
			IniRead, hotkeyControllerButton6, settings.ini, Controller Keys, ControllerButton6, RButton
			IniRead, hotkeyControllerButton7, settings.ini, Controller Keys, ControllerButton7, ItemSort
			IniRead, hotkeyControllerButton8, settings.ini, Controller Keys, ControllerButton8, Tab
			IniRead, hotkeyControllerButton9, settings.ini, Controller Keys, ControllerButton9, Logout
			IniRead, hotkeyControllerButton10, settings.ini, Controller Keys, ControllerButton10, QuickPortal
			
			IniRead, hotkeyControllerJoystick2, settings.ini, Controller Keys, hotkeyControllerJoystick2, RButton

			IniRead, YesTriggerUtilityKey, settings.ini, Controller, YesTriggerUtilityKey, 1
			IniRead, YesTriggerUtilityJoystickKey, settings.ini, Controller, YesTriggerUtilityJoystickKey, 1
			IniRead, YesTriggerJoystick2Key, settings.ini, Controller, YesTriggerJoystick2Key, 1
			IniRead, TriggerUtilityKey, settings.ini, Controller, TriggerUtilityKey, 1
			IniRead, YesMovementKeys, settings.ini, Controller, YesMovementKeys, 0
			IniRead, YesController, settings.ini, Controller, YesController, 0
			IniRead, JoystickNumber, settings.ini, Controller, JoystickNumber, 0

			;settings for the Ninja Database
			IniRead, LastDatabaseParseDate, Settings.ini, Database, LastDatabaseParseDate, 20190913
			IniRead, selectedLeague, Settings.ini, Database, selectedLeague, Blight
			IniRead, UpdateDatabaseInterval, Settings.ini, Database, UpdateDatabaseInterval, 2
			IniRead, YesNinjaDatabase, Settings.ini, Database, YesNinjaDatabase, 1
			IniRead, ForceMatch6Link, Settings.ini, Database, ForceMatch6Link, 0

			RegisterHotkeys()
			checkActiveType()
		Return
		}

		submit(){  
		updateEverything:
			global
			Thread, NoTimers, true		;Critical

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
			If hotkeyLootScan
				hotkey, $~%hotkeyLootScan%, LootScanCommand, Off
			If hotkeyMainAttack
				hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
			If hotkeySecondaryAttack
				hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off

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
				Gui 2: Show, x%GuiX% y%GuiY%, NoActivate 
				ToggleExist := True
				WinActivate, ahk_group POEGameGroup
				GuiStatus("OnChar")
				If (OnChar) {
					;Life Resample
					pixelgetcolor, varLife20, vX_Life, vY_Life20
					pixelgetcolor, varLife30, vX_Life, vY_Life30
					pixelgetcolor, varLife40, vX_Life, vY_Life40
					pixelgetcolor, varLife50, vX_Life, vY_Life50
					pixelgetcolor, varLife60, vX_Life, vY_Life60
					pixelgetcolor, varLife70, vX_Life, vY_Life70
					pixelgetcolor, varLife80, vX_Life, vY_Life80
					pixelgetcolor, varLife90, vX_Life, vY_Life90
						
					IniWrite, %varLife20%, settings.ini, Life Colors, Life20
					IniWrite, %varLife30%, settings.ini, Life Colors, Life30
					IniWrite, %varLife40%, settings.ini, Life Colors, Life40
					IniWrite, %varLife50%, settings.ini, Life Colors, Life50
					IniWrite, %varLife60%, settings.ini, Life Colors, Life60
					IniWrite, %varLife70%, settings.ini, Life Colors, Life70
					IniWrite, %varLife80%, settings.ini, Life Colors, Life80
					IniWrite, %varLife90%, settings.ini, Life Colors, Life90
					;ES Resample
					pixelgetcolor, varES20, vX_ES, vY_ES20
					pixelgetcolor, varES30, vX_ES, vY_ES30
					pixelgetcolor, varES40, vX_ES, vY_ES40
					pixelgetcolor, varES50, vX_ES, vY_ES50
					pixelgetcolor, varES60, vX_ES, vY_ES60
					pixelgetcolor, varES70, vX_ES, vY_ES70
					pixelgetcolor, varES80, vX_ES, vY_ES80
					pixelgetcolor, varES90, vX_ES, vY_ES90
					
					IniWrite, %varES20%, settings.ini, ES Colors, ES20
					IniWrite, %varES30%, settings.ini, ES Colors, ES30
					IniWrite, %varES40%, settings.ini, ES Colors, ES40
					IniWrite, %varES50%, settings.ini, ES Colors, ES50
					IniWrite, %varES60%, settings.ini, ES Colors, ES60
					IniWrite, %varES70%, settings.ini, ES Colors, ES70
					IniWrite, %varES80%, settings.ini, ES Colors, ES80
					IniWrite, %varES90%, settings.ini, ES Colors, ES90
					;Mana Resample
					pixelgetcolor, varMana10, vX_Mana, vY_Mana10
					pixelgetcolor, varManaThreshold, vX_Mana, vY_ManaThreshold
					IniWrite, %varMana10%, settings.ini, Mana Colors, Mana10
					IniWrite, %varManaThreshold%, settings.ini, Mana Colors, ManaThreshold
					;Messagebox	
					ToolTip, % "Script detects you are on Character`rGrabbed new Samples for Life, ES, and Mana colors"
					SetTimer, RemoveTT1, -5000
				} Else {
					MsgBox, 262144, No resample, % "Script Could not detect you on a character`rMake sure you calibrate OnChar if you have not`rCannot sample Life, ES, or Mana colors`nAll other settings will save."
				}
			} Else {
				MsgBox, 262144, No resample, % "Game is not Open`nWill not sample the Life, ES, or Mana colors!`nAll other settings will save."
			}
			Gui, Submit, NoHide
			;Life Flasks
			IniWrite, %Radiobox1Life20%%Radiobox2Life20%%Radiobox3Life20%%Radiobox4Life20%%Radiobox5Life20%, settings.ini, Life Triggers, TriggerLife20
			IniWrite, %Radiobox1Life30%%Radiobox2Life30%%Radiobox3Life30%%Radiobox4Life30%%Radiobox5Life30%, settings.ini, Life Triggers, TriggerLife30
			IniWrite, %Radiobox1Life40%%Radiobox2Life40%%Radiobox3Life40%%Radiobox4Life40%%Radiobox5Life40%, settings.ini, Life Triggers, TriggerLife40
			IniWrite, %Radiobox1Life50%%Radiobox2Life50%%Radiobox3Life50%%Radiobox4Life50%%Radiobox5Life50%, settings.ini, Life Triggers, TriggerLife50
			IniWrite, %Radiobox1Life60%%Radiobox2Life60%%Radiobox3Life60%%Radiobox4Life60%%Radiobox5Life60%, settings.ini, Life Triggers, TriggerLife60
			IniWrite, %Radiobox1Life70%%Radiobox2Life70%%Radiobox3Life70%%Radiobox4Life70%%Radiobox5Life70%, settings.ini, Life Triggers, TriggerLife70
			IniWrite, %Radiobox1Life80%%Radiobox2Life80%%Radiobox3Life80%%Radiobox4Life80%%Radiobox5Life80%, settings.ini, Life Triggers, TriggerLife80
			IniWrite, %Radiobox1Life90%%Radiobox2Life90%%Radiobox3Life90%%Radiobox4Life90%%Radiobox5Life90%, settings.ini, Life Triggers, TriggerLife90
			IniWrite, %RadioUncheck1Life%%RadioUncheck2Life%%RadioUncheck3Life%%RadioUncheck4Life%%RadioUncheck5Life%, settings.ini, Life Triggers, DisableLife
				
			
			;ES Flasks
			IniWrite, %Radiobox1ES20%%Radiobox2ES20%%Radiobox3ES20%%Radiobox4ES20%%Radiobox5ES20%, settings.ini, ES Triggers, TriggerES20
			IniWrite, %Radiobox1ES30%%Radiobox2ES30%%Radiobox3ES30%%Radiobox4ES30%%Radiobox5ES30%, settings.ini, ES Triggers, TriggerES30
			IniWrite, %Radiobox1ES40%%Radiobox2ES40%%Radiobox3ES40%%Radiobox4ES40%%Radiobox5ES40%, settings.ini, ES Triggers, TriggerES40
			IniWrite, %Radiobox1ES50%%Radiobox2ES50%%Radiobox3ES50%%Radiobox4ES50%%Radiobox5ES50%, settings.ini, ES Triggers, TriggerES50
			IniWrite, %Radiobox1ES60%%Radiobox2ES60%%Radiobox3ES60%%Radiobox4ES60%%Radiobox5ES60%, settings.ini, ES Triggers, TriggerES60
			IniWrite, %Radiobox1ES70%%Radiobox2ES70%%Radiobox3ES70%%Radiobox4ES70%%Radiobox5ES70%, settings.ini, ES Triggers, TriggerES70
			IniWrite, %Radiobox1ES80%%Radiobox2ES80%%Radiobox3ES80%%Radiobox4ES80%%Radiobox5ES80%, settings.ini, ES Triggers, TriggerES80
			IniWrite, %Radiobox1ES90%%Radiobox2ES90%%Radiobox3ES90%%Radiobox4ES90%%Radiobox5ES90%, settings.ini, ES Triggers, TriggerES90
			IniWrite, %RadioUncheck1ES%%RadioUncheck2ES%%RadioUncheck3ES%%RadioUncheck4ES%%RadioUncheck5ES%, settings.ini, ES Triggers, DisableES
			;Mana Flasks
			IniWrite, %Radiobox1Mana10%%Radiobox2Mana10%%Radiobox3Mana10%%Radiobox4Mana10%%Radiobox5Mana10%, settings.ini, Mana Triggers, TriggerMana10
			
			;Bandit Extra options
			IniWrite, %DebugMessages%, settings.ini, General, DebugMessages
			IniWrite, %YesTimeMS%, settings.ini, General, YesTimeMS
			IniWrite, %YesLocation%, settings.ini, General, YesLocation
			IniWrite, %ShowPixelGrid%, settings.ini, General, ShowPixelGrid
			IniWrite, %ShowItemInfo%, settings.ini, General, ShowItemInfo
			IniWrite, %DetonateMines%, settings.ini, General, DetonateMines
			IniWrite, %LootVacuum%, settings.ini, General, LootVacuum
			IniWrite, %YesVendor%, settings.ini, General, YesVendor
			IniWrite, %YesStash%, settings.ini, General, YesStash
			IniWrite, %YesIdentify%, settings.ini, General, YesIdentify
			IniWrite, %YesDiv%, settings.ini, General, YesDiv
			IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
			IniWrite, %YesSortFirst%, settings.ini, General, YesSortFirst
			IniWrite, %Latency%, settings.ini, General, Latency
			IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
			IniWrite, %Steam%, settings.ini, General, Steam
			IniWrite, %HighBits%, settings.ini, General, HighBits
			IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
			IniWrite, %CharName%, settings.ini, General, CharName
			IniWrite, %EnableChatHotkeys%, settings.ini, General, EnableChatHotkeys
			IniWrite, %YesStashKeys%, settings.ini, General, YesStashKeys
			IniWrite, %YesPopAllExtraKeys%, settings.ini, General, YesPopAllExtraKeys
			IniWrite, %QSonMainAttack%, settings.ini, General, QSonMainAttack
			IniWrite, %QSonSecondaryAttack%, settings.ini, General, QSonSecondaryAttack
			IniWrite, %YesEldritchBattery%, settings.ini, General, YesEldritchBattery
			IniWrite, %YesStashT1%, settings.ini, General, YesStashT1
			IniWrite, %YesStashT2%, settings.ini, General, YesStashT2
			IniWrite, %YesStashT3%, settings.ini, General, YesStashT3
			IniWrite, %YesStashCraftingNormal%, settings.ini, General, YesStashCraftingNormal
			IniWrite, %YesStashCraftingMagic%, settings.ini, General, YesStashCraftingMagic
			IniWrite, %YesStashCraftingRare%, settings.ini, General, YesStashCraftingRare
			IniWrite, %YesAutoSkillUp%, settings.ini, General, YesAutoSkillUp
			IniWrite, %AreaScale%, settings.ini, General, AreaScale
			IniWrite, %LVdelay%, settings.ini, General, LVdelay
			IniWrite, %YesClickPortal%, settings.ini, General, YesClickPortal
			IniWrite, %RelogOnQuit%, settings.ini, General, RelogOnQuit

			; Overhead Health Bar
			IniWrite, %YesOHB%, settings.ini, OHB, YesOHB

			; ASCII Search Strings
			IniWrite, %HealthBarStr%, Settings.ini, FindText Strings, HealthBarStr
			IniWrite, %VendorStr%, Settings.ini, FindText Strings, VendorStr
			IniWrite, %SellItemsStr%, Settings.ini, FindText Strings, SellItemsStr
			IniWrite, %StashStr%, Settings.ini, FindText Strings, StashStr
			IniWrite, %SkillUpStr%, Settings.ini, FindText Strings, SkillUpStr

			;~ Hotkeys 
			IniWrite, %hotkeyOptions%, settings.ini, hotkeys, Options
			IniWrite, %hotkeyAutoQuit%, settings.ini, hotkeys, AutoQuit
			IniWrite, %hotkeyAutoFlask%, settings.ini, hotkeys, AutoFlask
			IniWrite, %hotkeyAutoQuicksilver%, settings.ini, hotkeys, AutoQuicksilver
			IniWrite, %hotkeyQuickPortal%, settings.ini, hotkeys, QuickPortal
			IniWrite, %hotkeyGemSwap%, settings.ini, hotkeys, GemSwap
			IniWrite, %hotkeyGetMouseCoords%, settings.ini, hotkeys, GetMouseCoords
			IniWrite, %hotkeyPopFlasks%, settings.ini, hotkeys, PopFlasks
			IniWrite, %hotkeyLogout%, settings.ini, hotkeys, Logout
			IniWrite, %hotkeyCloseAllUI%, settings.ini, hotkeys, CloseAllUI
			IniWrite, %hotkeyInventory%, settings.ini, hotkeys, Inventory
			IniWrite, %hotkeyWeaponSwapKey%, settings.ini, hotkeys, WeaponSwapKey
			IniWrite, %hotkeyItemSort%, settings.ini, hotkeys, ItemSort
			IniWrite, %hotkeyItemInfo%, settings.ini, hotkeys, ItemInfo
			IniWrite, %hotkeyLootScan%, settings.ini, hotkeys, LootScan
			IniWrite, %hotkeyMainAttack%, settings.ini, hotkeys, MainAttack
			IniWrite, %hotkeySecondaryAttack%, settings.ini, hotkeys, SecondaryAttack
			
			;Utility Keys
			IniWrite, %hotkeyUp%, 		settings.ini, Controller Keys, hotkeyUp
			IniWrite, %hotkeyDown%, 	settings.ini, Controller Keys, hotkeyDown
			IniWrite, %hotkeyLeft%, 	settings.ini, Controller Keys, hotkeyLeft
			IniWrite, %hotkeyRight%, 	settings.ini, Controller Keys, hotkeyRight
			
			;Utility Buttons
			IniWrite, %YesUtility1%, settings.ini, Utility Buttons, YesUtility1
			IniWrite, %YesUtility2%, settings.ini, Utility Buttons, YesUtility2
			IniWrite, %YesUtility3%, settings.ini, Utility Buttons, YesUtility3
			IniWrite, %YesUtility4%, settings.ini, Utility Buttons, YesUtility4
			IniWrite, %YesUtility5%, settings.ini, Utility Buttons, YesUtility5
			IniWrite, %YesUtility1Quicksilver%, settings.ini, Utility Buttons, YesUtility1Quicksilver
			IniWrite, %YesUtility2Quicksilver%, settings.ini, Utility Buttons, YesUtility2Quicksilver
			IniWrite, %YesUtility3Quicksilver%, settings.ini, Utility Buttons, YesUtility3Quicksilver
			IniWrite, %YesUtility4Quicksilver%, settings.ini, Utility Buttons, YesUtility4Quicksilver
			IniWrite, %YesUtility5Quicksilver%, settings.ini, Utility Buttons, YesUtility5Quicksilver
			
			;Utility Percents	
			IniWrite, %YesUtility1LifePercent%, settings.ini, Utility Buttons, YesUtility1LifePercent
			IniWrite, %YesUtility2LifePercent%, settings.ini, Utility Buttons, YesUtility2LifePercent
			IniWrite, %YesUtility3LifePercent%, settings.ini, Utility Buttons, YesUtility3LifePercent
			IniWrite, %YesUtility4LifePercent%, settings.ini, Utility Buttons, YesUtility4LifePercent
			IniWrite, %YesUtility5LifePercent%, settings.ini, Utility Buttons, YesUtility5LifePercent
			IniWrite, %YesUtility1EsPercent%, settings.ini, Utility Buttons, YesUtility1EsPercent
			IniWrite, %YesUtility2EsPercent%, settings.ini, Utility Buttons, YesUtility2EsPercent
			IniWrite, %YesUtility3EsPercent%, settings.ini, Utility Buttons, YesUtility3EsPercent
			IniWrite, %YesUtility4EsPercent%, settings.ini, Utility Buttons, YesUtility4EsPercent
			IniWrite, %YesUtility5EsPercent%, settings.ini, Utility Buttons, YesUtility5EsPercent
			
			;Utility Cooldowns
			IniWrite, %CooldownUtility1%, settings.ini, Utility Cooldowns, CooldownUtility1
			IniWrite, %CooldownUtility2%, settings.ini, Utility Cooldowns, CooldownUtility2
			IniWrite, %CooldownUtility3%, settings.ini, Utility Cooldowns, CooldownUtility3
			IniWrite, %CooldownUtility4%, settings.ini, Utility Cooldowns, CooldownUtility4
			IniWrite, %CooldownUtility5%, settings.ini, Utility Cooldowns, CooldownUtility5
			
			;Utility Keys
			IniWrite, %KeyUtility1%, settings.ini, Utility Keys, KeyUtility1
			IniWrite, %KeyUtility2%, settings.ini, Utility Keys, KeyUtility2
			IniWrite, %KeyUtility3%, settings.ini, Utility Keys, KeyUtility3
			IniWrite, %KeyUtility4%, settings.ini, Utility Keys, KeyUtility4
			IniWrite, %KeyUtility5%, settings.ini, Utility Keys, KeyUtility5
			
			;Utility Icon Strings
			IniWrite, %IconStringUtility1%, settings.ini, Utility Icons, IconStringUtility1
			IniWrite, %IconStringUtility2%, settings.ini, Utility Icons, IconStringUtility2
			IniWrite, %IconStringUtility3%, settings.ini, Utility Icons, IconStringUtility3
			IniWrite, %IconStringUtility4%, settings.ini, Utility Icons, IconStringUtility4
			IniWrite, %IconStringUtility5%, settings.ini, Utility Icons, IconStringUtility5
			
			;Flask Cooldowns
			IniWrite, %CooldownFlask1%, settings.ini, Flask Cooldowns, CooldownFlask1
			IniWrite, %CooldownFlask2%, settings.ini, Flask Cooldowns, CooldownFlask2
			IniWrite, %CooldownFlask3%, settings.ini, Flask Cooldowns, CooldownFlask3
			IniWrite, %CooldownFlask4%, settings.ini, Flask Cooldowns, CooldownFlask4
			IniWrite, %CooldownFlask5%, settings.ini, Flask Cooldowns, CooldownFlask5	

			;Flask Keys
			IniWrite, %keyFlask1%, settings.ini, Flask Keys, keyFlask1
			IniWrite, %keyFlask2%, settings.ini, Flask Keys, keyFlask2
			IniWrite, %keyFlask3%, settings.ini, Flask Keys, keyFlask3
			IniWrite, %keyFlask4%, settings.ini, Flask Keys, keyFlask4
			IniWrite, %keyFlask5%, settings.ini, Flask Keys, keyFlask5	
			
			;Gem Swap
			IniWrite, %CurrentGemX%, settings.ini, Gem Swap, CurrentGemX
			IniWrite, %CurrentGemY%, settings.ini, Gem Swap, CurrentGemY
			IniWrite, %AlternateGemX%, settings.ini, Gem Swap, AlternateGemX
			IniWrite, %AlternateGemY%, settings.ini, Gem Swap, AlternateGemY
			IniWrite, %AlternateGemOnSecondarySlot%, settings.ini, Gem Swap, AlternateGemOnSecondarySlot
			
			;~ Scroll locations
			IniWrite, %PortalScrollX%, settings.ini, Coordinates, PortalScrollX
			IniWrite, %PortalScrollY%, settings.ini, Coordinates, PortalScrollY
			IniWrite, %WisdomScrollX%, settings.ini, Coordinates, WisdomScrollX
			IniWrite, %WisdomScrollY%, settings.ini, Coordinates, WisdomScrollY
			IniWrite, %StockPortal%, settings.ini, Coordinates, StockPortal
			IniWrite, %StockWisdom%, settings.ini, Coordinates, StockWisdom
			
			;Stash Tab Management
			IniWrite, %StashTabCurrency%, settings.ini, Stash Tab, StashTabCurrency
			IniWrite, %StashTabMap%, settings.ini, Stash Tab, StashTabMap
			IniWrite, %StashTabDivination%, settings.ini, Stash Tab, StashTabDivination
			IniWrite, %StashTabGem%, settings.ini, Stash Tab, StashTabGem
			IniWrite, %StashTabGemQuality%, settings.ini, Stash Tab, StashTabGemQuality
			IniWrite, %StashTabFlaskQuality%, settings.ini, Stash Tab, StashTabFlaskQuality
			IniWrite, %StashTabLinked%, settings.ini, Stash Tab, StashTabLinked
			IniWrite, %StashTabCollection%, settings.ini, Stash Tab, StashTabCollection
			IniWrite, %StashTabUniqueRing%, settings.ini, Stash Tab, StashTabUniqueRing
			IniWrite, %StashTabUniqueDump%, settings.ini, Stash Tab, StashTabUniqueDump
			IniWrite, %StashTabFragment%, settings.ini, Stash Tab, StashTabFragment
			IniWrite, %StashTabEssence%, settings.ini, Stash Tab, StashTabEssence
			IniWrite, %StashTabOil%, settings.ini, Stash Tab, StashTabOil
			IniWrite, %StashTabFossil%, settings.ini, Stash Tab, StashTabFossil
			IniWrite, %StashTabResonator%, settings.ini, Stash Tab, StashTabResonator
			IniWrite, %StashTabCrafting%, settings.ini, Stash Tab, StashTabCrafting
			IniWrite, %StashTabProphecy%, settings.ini, Stash Tab, StashTabProphecy
			IniWrite, %StashTabVeiled%, settings.ini, Stash Tab, StashTabVeiled
			IniWrite, %StashTabYesCurrency%, settings.ini, Stash Tab, StashTabYesCurrency
			IniWrite, %StashTabYesMap%, settings.ini, Stash Tab, StashTabYesMap
			IniWrite, %StashTabYesDivination%, settings.ini, Stash Tab, StashTabYesDivination
			IniWrite, %StashTabYesGem%, settings.ini, Stash Tab, StashTabYesGem
			IniWrite, %StashTabYesGemQuality%, settings.ini, Stash Tab, StashTabYesGemQuality
			IniWrite, %StashTabYesFlaskQuality%, settings.ini, Stash Tab, StashTabYesFlaskQuality
			IniWrite, %StashTabYesLinked%, settings.ini, Stash Tab, StashTabYesLinked
			IniWrite, %StashTabYesCollection%, settings.ini, Stash Tab, StashTabYesCollection
			IniWrite, %StashTabYesUniqueRing%, settings.ini, Stash Tab, StashTabYesUniqueRing
			IniWrite, %StashTabYesUniqueDump%, settings.ini, Stash Tab, StashTabYesUniqueDump
			IniWrite, %StashTabYesFragment%, settings.ini, Stash Tab, StashTabYesFragment
			IniWrite, %StashTabYesEssence%, settings.ini, Stash Tab, StashTabYesEssence
			IniWrite, %StashTabYesOil%, settings.ini, Stash Tab, StashTabYesOil
			IniWrite, %StashTabYesFossil%, settings.ini, Stash Tab, StashTabYesFossil
			IniWrite, %StashTabYesResonator%, settings.ini, Stash Tab, StashTabYesResonator
			IniWrite, %StashTabYesCrafting%, settings.ini, Stash Tab, StashTabYesCrafting
			IniWrite, %StashTabYesProphecy%, settings.ini, Stash Tab, StashTabYesProphecy
			IniWrite, %StashTabYesVeiled%, settings.ini, Stash Tab, StashTabYesVeiled
			
			;Attack Flasks
			IniWrite, %MainAttackbox1%%MainAttackbox2%%MainAttackbox3%%MainAttackbox4%%MainAttackbox5%, settings.ini, Attack Triggers, TriggerMainAttack
			IniWrite, %SecondaryAttackbox1%%SecondaryAttackbox2%%SecondaryAttackbox3%%SecondaryAttackbox4%%SecondaryAttackbox5%, settings.ini, Attack Triggers, TriggerSecondaryAttack
			
			;Quicksilver Flasks
			IniWrite, %TriggerQuicksilverDelay%, settings.ini, Quicksilver, TriggerQuicksilverDelay
			IniWrite, %Radiobox1QS%%Radiobox2QS%%Radiobox3QS%%Radiobox4QS%%Radiobox5QS%, settings.ini, Quicksilver, TriggerQuicksilver
			
			;Pop Flasks
			IniWrite, %PopFlasks1%%PopFlasks2%%PopFlasks3%%PopFlasks4%%PopFlasks5%, settings.ini, PopFlasks, TriggerPopFlasks
			
			;CharacterTypeCheck
			IniWrite, %RadioLife%, settings.ini, CharacterTypeCheck, Life
			IniWrite, %RadioHybrid%, settings.ini, CharacterTypeCheck, Hybrid	
			IniWrite, %RadioCi%, settings.ini, CharacterTypeCheck, Ci	
			
			;AutoQuit
			IniWrite, %RadioQuit20%, settings.ini, AutoQuit, Quit20
			IniWrite, %RadioQuit30%, settings.ini, AutoQuit, Quit30
			IniWrite, %RadioQuit40%, settings.ini, AutoQuit, Quit40
			IniWrite, %RadioQuit50%, settings.ini, AutoQuit, Quit50
			IniWrite, %RadioQuit60%, settings.ini, AutoQuit, Quit60
			IniWrite, %RadioCritQuit%, settings.ini, AutoQuit, CritQuit
			IniWrite, %RadioPortalQuit%, settings.ini, AutoQuit, PortalQuit
			IniWrite, %RadioNormalQuit%, settings.ini, AutoQuit, NormalQuit

			;Chat Hotkeys
			IniWrite, %1Prefix1%, settings.ini, Chat Hotkeys, 1Prefix1
			IniWrite, %1Prefix2%, settings.ini, Chat Hotkeys, 1Prefix2
			IniWrite, %1Suffix1%, settings.ini, Chat Hotkeys, 1Suffix1
			IniWrite, %1Suffix2%, settings.ini, Chat Hotkeys, 1Suffix2
			IniWrite, %1Suffix3%, settings.ini, Chat Hotkeys, 1Suffix3
			IniWrite, %1Suffix4%, settings.ini, Chat Hotkeys, 1Suffix4
			IniWrite, %1Suffix5%, settings.ini, Chat Hotkeys, 1Suffix5
			IniWrite, %1Suffix6%, settings.ini, Chat Hotkeys, 1Suffix6
			IniWrite, %1Suffix7%, settings.ini, Chat Hotkeys, 1Suffix7
			IniWrite, %1Suffix8%, settings.ini, Chat Hotkeys, 1Suffix8
			IniWrite, %1Suffix9%, settings.ini, Chat Hotkeys, 1Suffix9

			IniWrite, %1Suffix1Text%, settings.ini, Chat Hotkeys, 1Suffix1Text
			IniWrite, %1Suffix2Text%, settings.ini, Chat Hotkeys, 1Suffix2Text
			IniWrite, %1Suffix3Text%, settings.ini, Chat Hotkeys, 1Suffix3Text
			IniWrite, %1Suffix4Text%, settings.ini, Chat Hotkeys, 1Suffix4Text
			IniWrite, %1Suffix5Text%, settings.ini, Chat Hotkeys, 1Suffix5Text
			IniWrite, %1Suffix6Text%, settings.ini, Chat Hotkeys, 1Suffix6Text
			IniWrite, %1Suffix7Text%, settings.ini, Chat Hotkeys, 1Suffix7Text
			IniWrite, %1Suffix8Text%, settings.ini, Chat Hotkeys, 1Suffix8Text
			IniWrite, %1Suffix9Text%, settings.ini, Chat Hotkeys, 1Suffix9Text

			IniWrite, %2Prefix1%, settings.ini, Chat Hotkeys, 2Prefix1
			IniWrite, %2Prefix2%, settings.ini, Chat Hotkeys, 2Prefix2
			IniWrite, %2Suffix1%, settings.ini, Chat Hotkeys, 2Suffix1
			IniWrite, %2Suffix2%, settings.ini, Chat Hotkeys, 2Suffix2
			IniWrite, %2Suffix3%, settings.ini, Chat Hotkeys, 2Suffix3
			IniWrite, %2Suffix4%, settings.ini, Chat Hotkeys, 2Suffix4
			IniWrite, %2Suffix5%, settings.ini, Chat Hotkeys, 2Suffix5
			IniWrite, %2Suffix6%, settings.ini, Chat Hotkeys, 2Suffix6
			IniWrite, %2Suffix7%, settings.ini, Chat Hotkeys, 2Suffix7
			IniWrite, %2Suffix8%, settings.ini, Chat Hotkeys, 2Suffix8
			IniWrite, %2Suffix9%, settings.ini, Chat Hotkeys, 2Suffix9
			
			IniWrite, %2Suffix1Text%, settings.ini, Chat Hotkeys, 2Suffix1Text
			IniWrite, %2Suffix2Text%, settings.ini, Chat Hotkeys, 2Suffix2Text
			IniWrite, %2Suffix3Text%, settings.ini, Chat Hotkeys, 2Suffix3Text
			IniWrite, %2Suffix4Text%, settings.ini, Chat Hotkeys, 2Suffix4Text
			IniWrite, %2Suffix5Text%, settings.ini, Chat Hotkeys, 2Suffix5Text
			IniWrite, %2Suffix6Text%, settings.ini, Chat Hotkeys, 2Suffix6Text
			IniWrite, %2Suffix7Text%, settings.ini, Chat Hotkeys, 2Suffix7Text
			IniWrite, %2Suffix8Text%, settings.ini, Chat Hotkeys, 2Suffix8Text
			IniWrite, %2Suffix9Text%, settings.ini, Chat Hotkeys, 2Suffix9Text

			IniWrite, %stashReset%, settings.ini, Stash Hotkeys, stashReset
			IniWrite, %stashPrefix1%, settings.ini, Stash Hotkeys, stashPrefix1
			IniWrite, %stashPrefix2%, settings.ini, Stash Hotkeys, stashPrefix2
			IniWrite, %stashSuffix1%, settings.ini, Stash Hotkeys, stashSuffix1
			IniWrite, %stashSuffix2%, settings.ini, Stash Hotkeys, stashSuffix2
			IniWrite, %stashSuffix3%, settings.ini, Stash Hotkeys, stashSuffix3
			IniWrite, %stashSuffix4%, settings.ini, Stash Hotkeys, stashSuffix4
			IniWrite, %stashSuffix5%, settings.ini, Stash Hotkeys, stashSuffix5
			IniWrite, %stashSuffix6%, settings.ini, Stash Hotkeys, stashSuffix6
			IniWrite, %stashSuffix7%, settings.ini, Stash Hotkeys, stashSuffix7
			IniWrite, %stashSuffix8%, settings.ini, Stash Hotkeys, stashSuffix8
			IniWrite, %stashSuffix9%, settings.ini, Stash Hotkeys, stashSuffix9
			
			IniWrite, %stashSuffixTab1%, settings.ini, Stash Hotkeys, stashSuffixTab1
			IniWrite, %stashSuffixTab2%, settings.ini, Stash Hotkeys, stashSuffixTab2
			IniWrite, %stashSuffixTab3%, settings.ini, Stash Hotkeys, stashSuffixTab3
			IniWrite, %stashSuffixTab4%, settings.ini, Stash Hotkeys, stashSuffixTab4
			IniWrite, %stashSuffixTab5%, settings.ini, Stash Hotkeys, stashSuffixTab5
			IniWrite, %stashSuffixTab6%, settings.ini, Stash Hotkeys, stashSuffixTab6
			IniWrite, %stashSuffixTab7%, settings.ini, Stash Hotkeys, stashSuffixTab7
			IniWrite, %stashSuffixTab8%, settings.ini, Stash Hotkeys, stashSuffixTab8
			IniWrite, %stashSuffixTab9%, settings.ini, Stash Hotkeys, stashSuffixTab9

			;Controller setup
			IniWrite, %hotkeyControllerButton1%, settings.ini, Controller Keys, ControllerButton1
			IniWrite, %hotkeyControllerButton2%, settings.ini, Controller Keys, ControllerButton2
			IniWrite, %hotkeyControllerButton3%, settings.ini, Controller Keys, ControllerButton3
			IniWrite, %hotkeyControllerButton4%, settings.ini, Controller Keys, ControllerButton4
			IniWrite, %hotkeyControllerButton5%, settings.ini, Controller Keys, ControllerButton5
			IniWrite, %hotkeyControllerButton6%, settings.ini, Controller Keys, ControllerButton6
			IniWrite, %hotkeyControllerButton7%, settings.ini, Controller Keys, ControllerButton7
			IniWrite, %hotkeyControllerButton8%, settings.ini, Controller Keys, ControllerButton8
			IniWrite, %hotkeyControllerButton9%, settings.ini, Controller Keys, ControllerButton9
			IniWrite, %hotkeyControllerButton10%, settings.ini, Controller Keys, ControllerButton10
			
			IniWrite, %hotkeyControllerJoystick2%, settings.ini, Controller Keys, hotkeyControllerJoystick2

			IniWrite, %YesTriggerUtilityKey%, settings.ini, Controller, YesTriggerUtilityKey
			IniWrite, %YesTriggerUtilityJoystickKey%, settings.ini, Controller, YesTriggerUtilityJoystickKey
			IniWrite, %YesTriggerJoystick2Key%, settings.ini, Controller, YesTriggerJoystick2Key
			IniWrite, %TriggerUtilityKey%, settings.ini, Controller, TriggerUtilityKey
			IniWrite, %YesMovementKeys%, settings.ini, Controller, YesMovementKeys
			IniWrite, %YesController%, settings.ini, Controller, YesController
			IniWrite, %JoystickNumber%, settings.ini, Controller, JoystickNumber

			;Settings for Ninja parse
			IniWrite, %LastDatabaseParseDate%, Settings.ini, Database, LastDatabaseParseDate
			IniWrite, %selectedLeague%, Settings.ini, Database, selectedLeague
			IniWrite, %UpdateDatabaseInterval%, Settings.ini, Database, UpdateDatabaseInterval
			IniWrite, %YesNinjaDatabase%, Settings.ini, Database, YesNinjaDatabase
			IniWrite, %ForceMatch6Link%, Settings.ini, Database, ForceMatch6Link

			readFromFile()
			If (YesPersistantToggle)
				AutoReset()
			GuiUpdate()
			IfWinExist, ahk_group POEGameGroup
				{
				WinActivate, ahk_group POEGameGroup
				}
			SendMSG(1)
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
			GuiControl,, RadioQuit20, %RadioQuit20%
			GuiControl,, RadioQuit30, %RadioQuit30%
			GuiControl,, RadioQuit40, %RadioQuit40%
			GuiControl,, RadioQuit50, %RadioQuit50%
			GuiControl,, RadioQuit60, %RadioQuit60%
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
			GuiControl,, hotkeyPopFlasks, %hotkeyPopFlasks%
			GuiControl,, hotkeyItemSort, %hotkeyItemSort%
			GuiControl,, hotkeyItemInfo, %hotkeyItemInfo%
			GuiControl,, hotkeyCloseAllUI, %hotkeyCloseAllUI%
			GuiControl,, hotkeyInventory, %hotkeyInventory%
			GuiControl,, hotkeyWeaponSwapKey, %hotkeyWeaponSwapKey%
			GuiControl,, hotkeyLootScan, %hotkeyLootScan%
			GuiControl,, PortalScrollX, %PortalScrollX%
			GuiControl,, PortalScrollY, %PortalScrollY%
			GuiControl,, WisdomScrollX, %WisdomScrollX%
			GuiControl,, WisdomScrollY, %WisdomScrollY%
			GuiControl,, CurrentGemX, %CurrentGemX%
			GuiControl,, CurrentGemY, %CurrentGemY%
			GuiControl,, AlternateGemX, %AlternateGemX%
			GuiControl,, AlternateGemY, %AlternateGemY%
			
			SendMSG(1,1)
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
				MoveStash(stashSuffixTab1)
			}
		return
		}
		FireStashHotkey2() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab2)
			}
		return
		}
		FireStashHotkey3() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab3)
			}
		return
		}
		FireStashHotkey4() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab4)
			}
		return
		}
		FireStashHotkey5() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab5)
			}
		return
		}
		FireStashHotkey6() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab6)
			}
		return
		}
		FireStashHotkey7() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab7)
			}
		return
		}
		FireStashHotkey8() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab8)
			}
		return
		}
		FireStashHotkey9() {
			IfWinActive, ahk_group POEGameGroup
			{	
				MoveStash(stashSuffixTab9)
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
			
			IniWrite, %Radiobox1Life20%, settings.ini, Profile%Profile%, Radiobox1Life20
			IniWrite, %Radiobox2Life20%, settings.ini, Profile%Profile%, Radiobox2Life20
			IniWrite, %Radiobox3Life20%, settings.ini, Profile%Profile%, Radiobox3Life20
			IniWrite, %Radiobox4Life20%, settings.ini, Profile%Profile%, Radiobox4Life20
			IniWrite, %Radiobox5Life20%, settings.ini, Profile%Profile%, Radiobox5Life20

			IniWrite, %Radiobox1Life30%, settings.ini, Profile%Profile%, Radiobox1Life30
			IniWrite, %Radiobox2Life30%, settings.ini, Profile%Profile%, Radiobox2Life30
			IniWrite, %Radiobox3Life30%, settings.ini, Profile%Profile%, Radiobox3Life30
			IniWrite, %Radiobox4Life30%, settings.ini, Profile%Profile%, Radiobox4Life30
			IniWrite, %Radiobox5Life30%, settings.ini, Profile%Profile%, Radiobox5Life30

			IniWrite, %Radiobox1Life40%, settings.ini, Profile%Profile%, Radiobox1Life40
			IniWrite, %Radiobox2Life40%, settings.ini, Profile%Profile%, Radiobox2Life40
			IniWrite, %Radiobox3Life40%, settings.ini, Profile%Profile%, Radiobox3Life40
			IniWrite, %Radiobox4Life40%, settings.ini, Profile%Profile%, Radiobox4Life40
			IniWrite, %Radiobox5Life40%, settings.ini, Profile%Profile%, Radiobox5Life40

			IniWrite, %Radiobox1Life50%, settings.ini, Profile%Profile%, Radiobox1Life50
			IniWrite, %Radiobox2Life50%, settings.ini, Profile%Profile%, Radiobox2Life50
			IniWrite, %Radiobox3Life50%, settings.ini, Profile%Profile%, Radiobox3Life50
			IniWrite, %Radiobox4Life50%, settings.ini, Profile%Profile%, Radiobox4Life50
			IniWrite, %Radiobox5Life50%, settings.ini, Profile%Profile%, Radiobox5Life50

			IniWrite, %Radiobox1Life50%, settings.ini, Profile%Profile%, Radiobox1Life50
			IniWrite, %Radiobox2Life50%, settings.ini, Profile%Profile%, Radiobox2Life50
			IniWrite, %Radiobox3Life50%, settings.ini, Profile%Profile%, Radiobox3Life50
			IniWrite, %Radiobox4Life50%, settings.ini, Profile%Profile%, Radiobox4Life50
			IniWrite, %Radiobox5Life50%, settings.ini, Profile%Profile%, Radiobox5Life50

			IniWrite, %Radiobox1Life60%, settings.ini, Profile%Profile%, Radiobox1Life60
			IniWrite, %Radiobox2Life60%, settings.ini, Profile%Profile%, Radiobox2Life60
			IniWrite, %Radiobox3Life60%, settings.ini, Profile%Profile%, Radiobox3Life60
			IniWrite, %Radiobox4Life60%, settings.ini, Profile%Profile%, Radiobox4Life60
			IniWrite, %Radiobox5Life60%, settings.ini, Profile%Profile%, Radiobox5Life60

			IniWrite, %Radiobox1Life70%, settings.ini, Profile%Profile%, Radiobox1Life70
			IniWrite, %Radiobox2Life70%, settings.ini, Profile%Profile%, Radiobox2Life70
			IniWrite, %Radiobox3Life70%, settings.ini, Profile%Profile%, Radiobox3Life70
			IniWrite, %Radiobox4Life70%, settings.ini, Profile%Profile%, Radiobox4Life70
			IniWrite, %Radiobox5Life70%, settings.ini, Profile%Profile%, Radiobox5Life70

			IniWrite, %Radiobox1Life80%, settings.ini, Profile%Profile%, Radiobox1Life80
			IniWrite, %Radiobox2Life80%, settings.ini, Profile%Profile%, Radiobox2Life80
			IniWrite, %Radiobox3Life80%, settings.ini, Profile%Profile%, Radiobox3Life80
			IniWrite, %Radiobox4Life80%, settings.ini, Profile%Profile%, Radiobox4Life80
			IniWrite, %Radiobox5Life80%, settings.ini, Profile%Profile%, Radiobox5Life80

			IniWrite, %Radiobox1Life90%, settings.ini, Profile%Profile%, Radiobox1Life90
			IniWrite, %Radiobox2Life90%, settings.ini, Profile%Profile%, Radiobox2Life90
			IniWrite, %Radiobox3Life90%, settings.ini, Profile%Profile%, Radiobox3Life90
			IniWrite, %Radiobox4Life90%, settings.ini, Profile%Profile%, Radiobox4Life90
			IniWrite, %Radiobox5Life90%, settings.ini, Profile%Profile%, Radiobox5Life90

			IniWrite, %RadioUncheck1Life%, settings.ini, Profile%Profile%, RadioUncheck1Life
			IniWrite, %RadioUncheck2Life%, settings.ini, Profile%Profile%, RadioUncheck2Life
			IniWrite, %RadioUncheck3Life%, settings.ini, Profile%Profile%, RadioUncheck3Life
			IniWrite, %RadioUncheck4Life%, settings.ini, Profile%Profile%, RadioUncheck4Life
			IniWrite, %RadioUncheck5Life%, settings.ini, Profile%Profile%, RadioUncheck5Life
			
			;ES Flasks
			IniWrite, %Radiobox1ES20%, settings.ini, Profile%Profile%, Radiobox1ES20
			IniWrite, %Radiobox2ES20%, settings.ini, Profile%Profile%, Radiobox2ES20
			IniWrite, %Radiobox3ES20%, settings.ini, Profile%Profile%, Radiobox3ES20
			IniWrite, %Radiobox4ES20%, settings.ini, Profile%Profile%, Radiobox4ES20
			IniWrite, %Radiobox5ES20%, settings.ini, Profile%Profile%, Radiobox5ES20
			
			IniWrite, %Radiobox1ES30%, settings.ini, Profile%Profile%, Radiobox1ES30
			IniWrite, %Radiobox2ES30%, settings.ini, Profile%Profile%, Radiobox2ES30
			IniWrite, %Radiobox3ES30%, settings.ini, Profile%Profile%, Radiobox3ES30
			IniWrite, %Radiobox4ES30%, settings.ini, Profile%Profile%, Radiobox4ES30
			IniWrite, %Radiobox5ES30%, settings.ini, Profile%Profile%, Radiobox5ES30
			
			IniWrite, %Radiobox1ES40%, settings.ini, Profile%Profile%, Radiobox1ES40
			IniWrite, %Radiobox2ES40%, settings.ini, Profile%Profile%, Radiobox2ES40
			IniWrite, %Radiobox3ES40%, settings.ini, Profile%Profile%, Radiobox3ES40
			IniWrite, %Radiobox4ES40%, settings.ini, Profile%Profile%, Radiobox4ES40
			IniWrite, %Radiobox5ES40%, settings.ini, Profile%Profile%, Radiobox5ES40
			
			IniWrite, %Radiobox1ES50%, settings.ini, Profile%Profile%, Radiobox1ES50
			IniWrite, %Radiobox2ES50%, settings.ini, Profile%Profile%, Radiobox2ES50
			IniWrite, %Radiobox3ES50%, settings.ini, Profile%Profile%, Radiobox3ES50
			IniWrite, %Radiobox4ES50%, settings.ini, Profile%Profile%, Radiobox4ES50
			IniWrite, %Radiobox5ES50%, settings.ini, Profile%Profile%, Radiobox5ES50
			
			IniWrite, %Radiobox1ES50%, settings.ini, Profile%Profile%, Radiobox1ES50
			IniWrite, %Radiobox2ES50%, settings.ini, Profile%Profile%, Radiobox2ES50
			IniWrite, %Radiobox3ES50%, settings.ini, Profile%Profile%, Radiobox3ES50
			IniWrite, %Radiobox4ES50%, settings.ini, Profile%Profile%, Radiobox4ES50
			IniWrite, %Radiobox5ES50%, settings.ini, Profile%Profile%, Radiobox5ES50
			
			IniWrite, %Radiobox1ES60%, settings.ini, Profile%Profile%, Radiobox1ES60
			IniWrite, %Radiobox2ES60%, settings.ini, Profile%Profile%, Radiobox2ES60
			IniWrite, %Radiobox3ES60%, settings.ini, Profile%Profile%, Radiobox3ES60
			IniWrite, %Radiobox4ES60%, settings.ini, Profile%Profile%, Radiobox4ES60
			IniWrite, %Radiobox5ES60%, settings.ini, Profile%Profile%, Radiobox5ES60
			
			IniWrite, %Radiobox1ES70%, settings.ini, Profile%Profile%, Radiobox1ES70
			IniWrite, %Radiobox2ES70%, settings.ini, Profile%Profile%, Radiobox2ES70
			IniWrite, %Radiobox3ES70%, settings.ini, Profile%Profile%, Radiobox3ES70
			IniWrite, %Radiobox4ES70%, settings.ini, Profile%Profile%, Radiobox4ES70
			IniWrite, %Radiobox5ES70%, settings.ini, Profile%Profile%, Radiobox5ES70
			
			IniWrite, %Radiobox1ES80%, settings.ini, Profile%Profile%, Radiobox1ES80
			IniWrite, %Radiobox2ES80%, settings.ini, Profile%Profile%, Radiobox2ES80
			IniWrite, %Radiobox3ES80%, settings.ini, Profile%Profile%, Radiobox3ES80
			IniWrite, %Radiobox4ES80%, settings.ini, Profile%Profile%, Radiobox4ES80
			IniWrite, %Radiobox5ES80%, settings.ini, Profile%Profile%, Radiobox5ES80
			
			IniWrite, %Radiobox1ES90%, settings.ini, Profile%Profile%, Radiobox1ES90
			IniWrite, %Radiobox2ES90%, settings.ini, Profile%Profile%, Radiobox2ES90
			IniWrite, %Radiobox3ES90%, settings.ini, Profile%Profile%, Radiobox3ES90
			IniWrite, %Radiobox4ES90%, settings.ini, Profile%Profile%, Radiobox4ES90
			IniWrite, %Radiobox5ES90%, settings.ini, Profile%Profile%, Radiobox5ES90
			
			IniWrite, %RadioUncheck1ES%, settings.ini, Profile%Profile%, RadioUncheck1ES
			IniWrite, %RadioUncheck2ES%, settings.ini, Profile%Profile%, RadioUncheck2ES
			IniWrite, %RadioUncheck3ES%, settings.ini, Profile%Profile%, RadioUncheck3ES
			IniWrite, %RadioUncheck4ES%, settings.ini, Profile%Profile%, RadioUncheck4ES
			IniWrite, %RadioUncheck5ES%, settings.ini, Profile%Profile%, RadioUncheck5ES
			
			;Mana Flasks
			IniWrite, %Radiobox1Mana10%, settings.ini, Profile%Profile%, Radiobox1Mana10
			IniWrite, %Radiobox2Mana10%, settings.ini, Profile%Profile%, Radiobox2Mana10
			IniWrite, %Radiobox3Mana10%, settings.ini, Profile%Profile%, Radiobox3Mana10
			IniWrite, %Radiobox4Mana10%, settings.ini, Profile%Profile%, Radiobox4Mana10
			IniWrite, %Radiobox5Mana10%, settings.ini, Profile%Profile%, Radiobox5Mana10
			
			;Flask Cooldowns
			IniWrite, %CooldownFlask1%, settings.ini, Profile%Profile%, CooldownFlask1
			IniWrite, %CooldownFlask2%, settings.ini, Profile%Profile%, CooldownFlask2
			IniWrite, %CooldownFlask3%, settings.ini, Profile%Profile%, CooldownFlask3
			IniWrite, %CooldownFlask4%, settings.ini, Profile%Profile%, CooldownFlask4
			IniWrite, %CooldownFlask5%, settings.ini, Profile%Profile%, CooldownFlask5	
			
			;Attack Flasks
			IniWrite, %MainAttackbox1%, settings.ini, Profile%Profile%, MainAttackbox1
			IniWrite, %MainAttackbox2%, settings.ini, Profile%Profile%, MainAttackbox2
			IniWrite, %MainAttackbox3%, settings.ini, Profile%Profile%, MainAttackbox3
			IniWrite, %MainAttackbox4%, settings.ini, Profile%Profile%, MainAttackbox4
			IniWrite, %MainAttackbox5%, settings.ini, Profile%Profile%, MainAttackbox5
			
			IniWrite, %SecondaryAttackbox1%, settings.ini, Profile%Profile%, SecondaryAttackbox1
			IniWrite, %SecondaryAttackbox2%, settings.ini, Profile%Profile%, SecondaryAttackbox2
			IniWrite, %SecondaryAttackbox3%, settings.ini, Profile%Profile%, SecondaryAttackbox3
			IniWrite, %SecondaryAttackbox4%, settings.ini, Profile%Profile%, SecondaryAttackbox4
			IniWrite, %SecondaryAttackbox5%, settings.ini, Profile%Profile%, SecondaryAttackbox5
			
			;Attack Keys
			IniWrite, %hotkeyMainAttack%, settings.ini, Profile%Profile%, MainAttack
			IniWrite, %hotkeySecondaryAttack%, settings.ini, Profile%Profile%, SecondaryAttack
			
			;QS on Attack Keys
			IniWrite, %QSonMainAttack%, settings.ini, Profile%Profile%, QSonMainAttack
			IniWrite, %QSonSecondaryAttack%, settings.ini, Profile%Profile%, QSonSecondaryAttack
			
			;Quicksilver Flasks
			IniWrite, %TriggerQuicksilverDelay%, settings.ini, Profile%Profile%, TriggerQuicksilverDelay
			IniWrite, %Radiobox1QS%, settings.ini, Profile%Profile%, QuicksilverSlot1
			IniWrite, %Radiobox2QS%, settings.ini, Profile%Profile%, QuicksilverSlot2
			IniWrite, %Radiobox3QS%, settings.ini, Profile%Profile%, QuicksilverSlot3
			IniWrite, %Radiobox4QS%, settings.ini, Profile%Profile%, QuicksilverSlot4
			IniWrite, %Radiobox5QS%, settings.ini, Profile%Profile%, QuicksilverSlot5
			
			;CharacterTypeCheck
			IniWrite, %RadioLife%, settings.ini, Profile%Profile%, Life
			IniWrite, %RadioHybrid%, settings.ini, Profile%Profile%, Hybrid	
			IniWrite, %RadioCi%, settings.ini, Profile%Profile%, Ci	
			
			;AutoMines
			IniWrite, %DetonateMines%, settings.ini, Profile%Profile%, DetonateMines

			;EldritchBattery
			IniWrite, %YesEldritchBattery%, settings.ini, Profile%Profile%, YesEldritchBattery

			;ManaThreshold
			IniWrite, %ManaThreshold%, settings.ini, Profile%Profile%, ManaThreshold

			;AutoQuit
			IniWrite, %RadioQuit20%, settings.ini, Profile%Profile%, Quit20
			IniWrite, %RadioQuit30%, settings.ini, Profile%Profile%, Quit30
			IniWrite, %RadioQuit40%, settings.ini, Profile%Profile%, Quit40
			IniWrite, %RadioQuit50%, settings.ini, Profile%Profile%, Quit50
			IniWrite, %RadioQuit60%, settings.ini, Profile%Profile%, Quit60
			IniWrite, %RadioCritQuit%, settings.ini, Profile%Profile%, CritQuit
			IniWrite, %RadioPortalQuit%, settings.ini, Profile%Profile%, PortalQuit
			IniWrite, %RadioNormalQuit%, settings.ini, Profile%Profile%, NormalQuit
			
			;Utility Buttons
			IniWrite, %YesUtility1%, settings.ini, Profile%Profile%, YesUtility1
			IniWrite, %YesUtility2%, settings.ini, Profile%Profile%, YesUtility2
			IniWrite, %YesUtility3%, settings.ini, Profile%Profile%, YesUtility3
			IniWrite, %YesUtility4%, settings.ini, Profile%Profile%, YesUtility4
			IniWrite, %YesUtility5%, settings.ini, Profile%Profile%, YesUtility5
			IniWrite, %YesUtility1Quicksilver%, settings.ini, Profile%Profile%, YesUtility1Quicksilver
			IniWrite, %YesUtility2Quicksilver%, settings.ini, Profile%Profile%, YesUtility2Quicksilver
			IniWrite, %YesUtility3Quicksilver%, settings.ini, Profile%Profile%, YesUtility3Quicksilver
			IniWrite, %YesUtility4Quicksilver%, settings.ini, Profile%Profile%, YesUtility4Quicksilver
			IniWrite, %YesUtility5Quicksilver%, settings.ini, Profile%Profile%, YesUtility5Quicksilver
			
			;Utility Percents	
			IniWrite, %YesUtility1LifePercent%, settings.ini, Profile%Profile%, YesUtility1LifePercent
			IniWrite, %YesUtility2LifePercent%, settings.ini, Profile%Profile%, YesUtility2LifePercent
			IniWrite, %YesUtility3LifePercent%, settings.ini, Profile%Profile%, YesUtility3LifePercent
			IniWrite, %YesUtility4LifePercent%, settings.ini, Profile%Profile%, YesUtility4LifePercent
			IniWrite, %YesUtility5LifePercent%, settings.ini, Profile%Profile%, YesUtility5LifePercent
			IniWrite, %YesUtility1EsPercent%, settings.ini, Profile%Profile%, YesUtility1EsPercent
			IniWrite, %YesUtility2EsPercent%, settings.ini, Profile%Profile%, YesUtility2EsPercent
			IniWrite, %YesUtility3EsPercent%, settings.ini, Profile%Profile%, YesUtility3EsPercent
			IniWrite, %YesUtility4EsPercent%, settings.ini, Profile%Profile%, YesUtility4EsPercent
			IniWrite, %YesUtility5EsPercent%, settings.ini, Profile%Profile%, YesUtility5EsPercent
			
			;Utility Cooldowns
			IniWrite, %CooldownUtility1%, settings.ini, Profile%Profile%, CooldownUtility1
			IniWrite, %CooldownUtility2%, settings.ini, Profile%Profile%, CooldownUtility2
			IniWrite, %CooldownUtility3%, settings.ini, Profile%Profile%, CooldownUtility3
			IniWrite, %CooldownUtility4%, settings.ini, Profile%Profile%, CooldownUtility4
			IniWrite, %CooldownUtility5%, settings.ini, Profile%Profile%, CooldownUtility5
			
			;Character Name
			IniWrite, %CharName%, settings.ini, Profile%Profile%, CharName

			;Utility Keys
			IniWrite, %KeyUtility1%, settings.ini, Profile%Profile%, KeyUtility1
			IniWrite, %KeyUtility2%, settings.ini, Profile%Profile%, KeyUtility2
			IniWrite, %KeyUtility3%, settings.ini, Profile%Profile%, KeyUtility3
			IniWrite, %KeyUtility4%, settings.ini, Profile%Profile%, KeyUtility4
			IniWrite, %KeyUtility5%, settings.ini, Profile%Profile%, KeyUtility5

			;Utility Icon Strings
			IniWrite, %IconStringUtility1%, settings.ini, Profile%Profile%, IconStringUtility1
			IniWrite, %IconStringUtility2%, settings.ini, Profile%Profile%, IconStringUtility2
			IniWrite, %IconStringUtility3%, settings.ini, Profile%Profile%, IconStringUtility3
			IniWrite, %IconStringUtility4%, settings.ini, Profile%Profile%, IconStringUtility4
			IniWrite, %IconStringUtility5%, settings.ini, Profile%Profile%, IconStringUtility5

			;Pop Flasks Keys
			IniWrite, %PopFlasks1%, settings.ini, Profile%Profile%, PopFlasks1
			IniWrite, %PopFlasks2%, settings.ini, Profile%Profile%, PopFlasks2
			IniWrite, %PopFlasks3%, settings.ini, Profile%Profile%, PopFlasks3
			IniWrite, %PopFlasks4%, settings.ini, Profile%Profile%, PopFlasks4
			IniWrite, %PopFlasks5%, settings.ini, Profile%Profile%, PopFlasks5
			
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
			IniRead, Radiobox1Life20, settings.ini, Profile%Profile%, Radiobox1Life20, 0
			GuiControl, , Radiobox1Life20, %Radiobox1Life20%
			IniRead, Radiobox2Life20, settings.ini, Profile%Profile%, Radiobox2Life20, 0
			GuiControl, , Radiobox2Life20, %Radiobox2Life20%
			IniRead, Radiobox3Life20, settings.ini, Profile%Profile%, Radiobox3Life20, 0
			GuiControl, , Radiobox3Life20, %Radiobox3Life20%
			IniRead, Radiobox4Life20, settings.ini, Profile%Profile%, Radiobox4Life20, 0
			GuiControl, , Radiobox4Life20, %Radiobox4Life20%
			IniRead, Radiobox5Life20, settings.ini, Profile%Profile%, Radiobox5Life20, 0
			GuiControl, , Radiobox5Life20, %Radiobox5Life20%

			IniRead, Radiobox1Life30, settings.ini, Profile%Profile%, Radiobox1Life30, 0
			GuiControl, , Radiobox1Life30, %Radiobox1Life30%
			IniRead, Radiobox2Life30, settings.ini, Profile%Profile%, Radiobox2Life30, 0
			GuiControl, , Radiobox2Life30, %Radiobox2Life30%
			IniRead, Radiobox3Life30, settings.ini, Profile%Profile%, Radiobox3Life30, 0
			GuiControl, , Radiobox3Life30, %Radiobox3Life30%
			IniRead, Radiobox4Life30, settings.ini, Profile%Profile%, Radiobox4Life30, 0
			GuiControl, , Radiobox4Life30, %Radiobox4Life30%
			IniRead, Radiobox5Life30, settings.ini, Profile%Profile%, Radiobox5Life30, 0
			GuiControl, , Radiobox5Life30, %Radiobox5Life30%

			IniRead, Radiobox1Life40, settings.ini, Profile%Profile%, Radiobox1Life40, 0
			GuiControl, , Radiobox1Life40, %Radiobox1Life40%
			IniRead, Radiobox2Life40, settings.ini, Profile%Profile%, Radiobox2Life40, 0
			GuiControl, , Radiobox2Life40, %Radiobox2Life40%
			IniRead, Radiobox3Life40, settings.ini, Profile%Profile%, Radiobox3Life40, 0
			GuiControl, , Radiobox3Life40, %Radiobox3Life40%
			IniRead, Radiobox4Life40, settings.ini, Profile%Profile%, Radiobox4Life40, 0
			GuiControl, , Radiobox4Life40, %Radiobox4Life40%
			IniRead, Radiobox5Life40, settings.ini, Profile%Profile%, Radiobox5Life40, 0
			GuiControl, , Radiobox5Life40, %Radiobox5Life40%

			IniRead, Radiobox1Life50, settings.ini, Profile%Profile%, Radiobox1Life50, 0
			GuiControl, , Radiobox1Life50, %Radiobox1Life50%
			IniRead, Radiobox2Life50, settings.ini, Profile%Profile%, Radiobox2Life50, 0
			GuiControl, , Radiobox2Life50, %Radiobox2Life50%
			IniRead, Radiobox3Life50, settings.ini, Profile%Profile%, Radiobox3Life50, 0
			GuiControl, , Radiobox3Life50, %Radiobox3Life50%
			IniRead, Radiobox4Life50, settings.ini, Profile%Profile%, Radiobox4Life50, 0
			GuiControl, , Radiobox4Life50, %Radiobox4Life50%
			IniRead, Radiobox5Life50, settings.ini, Profile%Profile%, Radiobox5Life50, 0
			GuiControl, , Radiobox5Life50, %Radiobox5Life50%

			IniRead, Radiobox1Life50, settings.ini, Profile%Profile%, Radiobox1Life50, 0
			GuiControl, , Radiobox1Life50, %Radiobox1Life50%
			IniRead, Radiobox2Life50, settings.ini, Profile%Profile%, Radiobox2Life50, 0
			GuiControl, , Radiobox2Life50, %Radiobox2Life50%
			IniRead, Radiobox3Life50, settings.ini, Profile%Profile%, Radiobox3Life50, 0
			GuiControl, , Radiobox3Life50, %Radiobox3Life50%
			IniRead, Radiobox4Life50, settings.ini, Profile%Profile%, Radiobox4Life50, 0
			GuiControl, , Radiobox4Life50, %Radiobox4Life50%
			IniRead, Radiobox5Life50, settings.ini, Profile%Profile%, Radiobox5Life50, 0
			GuiControl, , Radiobox5Life50, %Radiobox5Life50%

			IniRead, Radiobox1Life60, settings.ini, Profile%Profile%, Radiobox1Life60, 0
			GuiControl, , Radiobox1Life60, %Radiobox1Life60%
			IniRead, Radiobox2Life60, settings.ini, Profile%Profile%, Radiobox2Life60, 0
			GuiControl, , Radiobox2Life60, %Radiobox2Life60%
			IniRead, Radiobox3Life60, settings.ini, Profile%Profile%, Radiobox3Life60, 0
			GuiControl, , Radiobox3Life60, %Radiobox3Life60%
			IniRead, Radiobox4Life60, settings.ini, Profile%Profile%, Radiobox4Life60, 0
			GuiControl, , Radiobox4Life60, %Radiobox4Life60%
			IniRead, Radiobox5Life60, settings.ini, Profile%Profile%, Radiobox5Life60, 0
			GuiControl, , Radiobox5Life60, %Radiobox5Life60%

			IniRead, Radiobox1Life70, settings.ini, Profile%Profile%, Radiobox1Life70, 0
			GuiControl, , Radiobox1Life70, %Radiobox1Life70%
			IniRead, Radiobox2Life70, settings.ini, Profile%Profile%, Radiobox2Life70, 0
			GuiControl, , Radiobox2Life70, %Radiobox2Life70%
			IniRead, Radiobox3Life70, settings.ini, Profile%Profile%, Radiobox3Life70, 0
			GuiControl, , Radiobox3Life70, %Radiobox3Life70%
			IniRead, Radiobox4Life70, settings.ini, Profile%Profile%, Radiobox4Life70, 0
			GuiControl, , Radiobox4Life70, %Radiobox4Life70%
			IniRead, Radiobox5Life70, settings.ini, Profile%Profile%, Radiobox5Life70, 0
			GuiControl, , Radiobox5Life70, %Radiobox5Life70%

			IniRead, Radiobox1Life80, settings.ini, Profile%Profile%, Radiobox1Life80, 0
			GuiControl, , Radiobox1Life80, %Radiobox1Life80%
			IniRead, Radiobox2Life80, settings.ini, Profile%Profile%, Radiobox2Life80, 0
			GuiControl, , Radiobox2Life80, %Radiobox2Life80%
			IniRead, Radiobox3Life80, settings.ini, Profile%Profile%, Radiobox3Life80, 0
			GuiControl, , Radiobox3Life80, %Radiobox3Life80%
			IniRead, Radiobox4Life80, settings.ini, Profile%Profile%, Radiobox4Life80, 0
			GuiControl, , Radiobox4Life80, %Radiobox4Life80%
			IniRead, Radiobox5Life80, settings.ini, Profile%Profile%, Radiobox5Life80, 0
			GuiControl, , Radiobox5Life80, %Radiobox5Life80%

			IniRead, Radiobox1Life90, settings.ini, Profile%Profile%, Radiobox1Life90, 0
			GuiControl, , Radiobox1Life90, %Radiobox1Life90%
			IniRead, Radiobox2Life90, settings.ini, Profile%Profile%, Radiobox2Life90, 0
			GuiControl, , Radiobox2Life90, %Radiobox2Life90%
			IniRead, Radiobox3Life90, settings.ini, Profile%Profile%, Radiobox3Life90, 0
			GuiControl, , Radiobox3Life90, %Radiobox3Life90%
			IniRead, Radiobox4Life90, settings.ini, Profile%Profile%, Radiobox4Life90, 0
			GuiControl, , Radiobox4Life90, %Radiobox4Life90%
			IniRead, Radiobox5Life90, settings.ini, Profile%Profile%, Radiobox5Life90, 0
			GuiControl, , Radiobox5Life90, %Radiobox5Life90%

			IniRead, RadioUncheck1Life, settings.ini, Profile%Profile%, RadioUncheck1Life, 1
			GuiControl, , RadioUncheck1Life, %RadioUncheck1Life%
			IniRead, RadioUncheck2Life, settings.ini, Profile%Profile%, RadioUncheck2Life, 1
			GuiControl, , RadioUncheck2Life, %RadioUncheck2Life%
			IniRead, RadioUncheck3Life, settings.ini, Profile%Profile%, RadioUncheck3Life, 1
			GuiControl, , RadioUncheck3Life, %RadioUncheck3Life%
			IniRead, RadioUncheck4Life, settings.ini, Profile%Profile%, RadioUncheck4Life, 1
			GuiControl, , RadioUncheck4Life, %RadioUncheck4Life%
			IniRead, RadioUncheck5Life, settings.ini, Profile%Profile%, RadioUncheck5Life, 1
			GuiControl, , RadioUncheck5Life, %RadioUncheck5Life%
			
			;ES Flasks
			IniRead, Radiobox1ES20, settings.ini, Profile%Profile%, Radiobox1ES20, 0
			GuiControl, , Radiobox1ES20, %Radiobox1ES20%
			IniRead, Radiobox2ES20, settings.ini, Profile%Profile%, Radiobox2ES20, 0
			GuiControl, , Radiobox2ES20, %Radiobox2ES20%
			IniRead, Radiobox3ES20, settings.ini, Profile%Profile%, Radiobox3ES20, 0
			GuiControl, , Radiobox3ES20, %Radiobox3ES20%
			IniRead, Radiobox4ES20, settings.ini, Profile%Profile%, Radiobox4ES20, 0
			GuiControl, , Radiobox4ES20, %Radiobox4ES20%
			IniRead, Radiobox5ES20, settings.ini, Profile%Profile%, Radiobox5ES20, 0
			GuiControl, , Radiobox5ES20, %Radiobox5ES20%
			
			IniRead, Radiobox1ES30, settings.ini, Profile%Profile%, Radiobox1ES30, 0
			GuiControl, , Radiobox1ES30, %Radiobox1ES30%
			IniRead, Radiobox2ES30, settings.ini, Profile%Profile%, Radiobox2ES30, 0
			GuiControl, , Radiobox2ES30, %Radiobox2ES30%
			IniRead, Radiobox3ES30, settings.ini, Profile%Profile%, Radiobox3ES30, 0
			GuiControl, , Radiobox3ES30, %Radiobox3ES30%
			IniRead, Radiobox4ES30, settings.ini, Profile%Profile%, Radiobox4ES30, 0
			GuiControl, , Radiobox4ES30, %Radiobox4ES30%
			IniRead, Radiobox5ES30, settings.ini, Profile%Profile%, Radiobox5ES30, 0
			GuiControl, , Radiobox5ES30, %Radiobox5ES30%
			
			IniRead, Radiobox1ES40, settings.ini, Profile%Profile%, Radiobox1ES40, 0
			GuiControl, , Radiobox1ES40, %Radiobox1ES40%
			IniRead, Radiobox2ES40, settings.ini, Profile%Profile%, Radiobox2ES40, 0
			GuiControl, , Radiobox2ES40, %Radiobox2ES40%
			IniRead, Radiobox3ES40, settings.ini, Profile%Profile%, Radiobox3ES40, 0
			GuiControl, , Radiobox3ES40, %Radiobox3ES40%
			IniRead, Radiobox4ES40, settings.ini, Profile%Profile%, Radiobox4ES40, 0
			GuiControl, , Radiobox4ES40, %Radiobox4ES40%
			IniRead, Radiobox5ES40, settings.ini, Profile%Profile%, Radiobox5ES40, 0
			GuiControl, , Radiobox5ES40, %Radiobox5ES40%
			
			IniRead, Radiobox1ES50, settings.ini, Profile%Profile%, Radiobox1ES50, 0
			GuiControl, , Radiobox1ES50, %Radiobox1ES50%
			IniRead, Radiobox2ES50, settings.ini, Profile%Profile%, Radiobox2ES50, 0
			GuiControl, , Radiobox2ES50, %Radiobox2ES50%
			IniRead, Radiobox3ES50, settings.ini, Profile%Profile%, Radiobox3ES50, 0
			GuiControl, , Radiobox3ES50, %Radiobox3ES50%
			IniRead, Radiobox4ES50, settings.ini, Profile%Profile%, Radiobox4ES50, 0
			GuiControl, , Radiobox4ES50, %Radiobox4ES50%
			IniRead, Radiobox5ES50, settings.ini, Profile%Profile%, Radiobox5ES50, 0
			GuiControl, , Radiobox5ES50, %Radiobox5ES50%
			
			IniRead, Radiobox1ES50, settings.ini, Profile%Profile%, Radiobox1ES50, 0
			GuiControl, , Radiobox1ES50, %Radiobox1ES50%
			IniRead, Radiobox2ES50, settings.ini, Profile%Profile%, Radiobox2ES50, 0
			GuiControl, , Radiobox2ES50, %Radiobox2ES50%
			IniRead, Radiobox3ES50, settings.ini, Profile%Profile%, Radiobox3ES50, 0
			GuiControl, , Radiobox3ES50, %Radiobox3ES50%
			IniRead, Radiobox4ES50, settings.ini, Profile%Profile%, Radiobox4ES50, 0
			GuiControl, , Radiobox4ES50, %Radiobox4ES50%
			IniRead, Radiobox5ES50, settings.ini, Profile%Profile%, Radiobox5ES50, 0
			GuiControl, , Radiobox5ES50, %Radiobox5ES50%
			
			IniRead, Radiobox1ES60, settings.ini, Profile%Profile%, Radiobox1ES60, 0
			GuiControl, , Radiobox1ES60, %Radiobox1ES60%
			IniRead, Radiobox2ES60, settings.ini, Profile%Profile%, Radiobox2ES60, 0
			GuiControl, , Radiobox2ES60, %Radiobox2ES60%
			IniRead, Radiobox3ES60, settings.ini, Profile%Profile%, Radiobox3ES60, 0
			GuiControl, , Radiobox3ES60, %Radiobox3ES60%
			IniRead, Radiobox4ES60, settings.ini, Profile%Profile%, Radiobox4ES60, 0
			GuiControl, , Radiobox4ES60, %Radiobox4ES60%
			IniRead, Radiobox5ES60, settings.ini, Profile%Profile%, Radiobox5ES60, 0
			GuiControl, , Radiobox5ES60, %Radiobox5ES60%
			
			IniRead, Radiobox1ES70, settings.ini, Profile%Profile%, Radiobox1ES70, 0
			GuiControl, , Radiobox1ES70, %Radiobox1ES70%
			IniRead, Radiobox2ES70, settings.ini, Profile%Profile%, Radiobox2ES70, 0
			GuiControl, , Radiobox2ES70, %Radiobox2ES70%
			IniRead, Radiobox3ES70, settings.ini, Profile%Profile%, Radiobox3ES70, 0
			GuiControl, , Radiobox3ES70, %Radiobox3ES70%
			IniRead, Radiobox4ES70, settings.ini, Profile%Profile%, Radiobox4ES70, 0
			GuiControl, , Radiobox4ES70, %Radiobox4ES70%
			IniRead, Radiobox5ES70, settings.ini, Profile%Profile%, Radiobox5ES70, 0
			GuiControl, , Radiobox5ES70, %Radiobox5ES70%
			
			IniRead, Radiobox1ES80, settings.ini, Profile%Profile%, Radiobox1ES80, 0
			GuiControl, , Radiobox1ES80, %Radiobox1ES80%
			IniRead, Radiobox2ES80, settings.ini, Profile%Profile%, Radiobox2ES80, 0
			GuiControl, , Radiobox2ES80, %Radiobox2ES80%
			IniRead, Radiobox3ES80, settings.ini, Profile%Profile%, Radiobox3ES80, 0
			GuiControl, , Radiobox3ES80, %Radiobox3ES80%
			IniRead, Radiobox4ES80, settings.ini, Profile%Profile%, Radiobox4ES80, 0
			GuiControl, , Radiobox4ES80, %Radiobox4ES80%
			IniRead, Radiobox5ES80, settings.ini, Profile%Profile%, Radiobox5ES80, 0
			GuiControl, , Radiobox5ES80, %Radiobox5ES80%
			
			IniRead, Radiobox1ES90, settings.ini, Profile%Profile%, Radiobox1ES90, 0
			GuiControl, , Radiobox1ES90, %Radiobox1ES90%
			IniRead, Radiobox2ES90, settings.ini, Profile%Profile%, Radiobox2ES90, 0
			GuiControl, , Radiobox2ES90, %Radiobox2ES90%
			IniRead, Radiobox3ES90, settings.ini, Profile%Profile%, Radiobox3ES90, 0
			GuiControl, , Radiobox3ES90, %Radiobox3ES90%
			IniRead, Radiobox4ES90, settings.ini, Profile%Profile%, Radiobox4ES90, 0
			GuiControl, , Radiobox4ES90, %Radiobox4ES90%
			IniRead, Radiobox5ES90, settings.ini, Profile%Profile%, Radiobox5ES90, 0
			GuiControl, , Radiobox5ES90, %Radiobox5ES90%
			
			IniRead, RadioUncheck1ES, settings.ini, Profile%Profile%, RadioUncheck1ES, 1
			GuiControl, , RadioUncheck1ES, %RadioUncheck1ES%
			IniRead, RadioUncheck2ES, settings.ini, Profile%Profile%, RadioUncheck2ES, 1
			GuiControl, , RadioUncheck2ES, %RadioUncheck2ES%
			IniRead, RadioUncheck3ES, settings.ini, Profile%Profile%, RadioUncheck3ES, 1
			GuiControl, , RadioUncheck3ES, %RadioUncheck3ES%
			IniRead, RadioUncheck4ES, settings.ini, Profile%Profile%, RadioUncheck4ES, 1
			GuiControl, , RadioUncheck4ES, %RadioUncheck4ES%
			IniRead, RadioUncheck5ES, settings.ini, Profile%Profile%, RadioUncheck5ES, 1
			GuiControl, , RadioUncheck5ES, %RadioUncheck5ES%
			
			;Mana Flasks
			IniRead, Radiobox1Mana10, settings.ini, Profile%Profile%, Radiobox1Mana10, 0
			GuiControl, , Radiobox1Mana10, %Radiobox1Mana10%
			IniRead, Radiobox2Mana10, settings.ini, Profile%Profile%, Radiobox2Mana10, 0
			GuiControl, , Radiobox2Mana10, %Radiobox2Mana10%
			IniRead, Radiobox3Mana10, settings.ini, Profile%Profile%, Radiobox3Mana10, 0
			GuiControl, , Radiobox3Mana10, %Radiobox3Mana10%
			IniRead, Radiobox4Mana10, settings.ini, Profile%Profile%, Radiobox4Mana10, 0
			GuiControl, , Radiobox4Mana10, %Radiobox4Mana10%
			IniRead, Radiobox5Mana10, settings.ini, Profile%Profile%, Radiobox5Mana10, 0
			GuiControl, , Radiobox5Mana10, %Radiobox5Mana10%
			
			;Flask Cooldowns
			IniRead, CooldownFlask1, settings.ini, Profile%Profile%, CooldownFlask1, 4800
			GuiControl, , CooldownFlask1, %CooldownFlask1%
			IniRead, CooldownFlask2, settings.ini, Profile%Profile%, CooldownFlask2, 4800
			GuiControl, , CooldownFlask2, %CooldownFlask2%
			IniRead, CooldownFlask3, settings.ini, Profile%Profile%, CooldownFlask3, 4800
			GuiControl, , CooldownFlask3, %CooldownFlask3%
			IniRead, CooldownFlask4, settings.ini, Profile%Profile%, CooldownFlask4, 4800
			GuiControl, , CooldownFlask4, %CooldownFlask4%
			IniRead, CooldownFlask5, settings.ini, Profile%Profile%, CooldownFlask5	, 4800
			GuiControl, , CooldownFlask5, %CooldownFlask5%
			
			;Attack Flasks
			IniRead, MainAttackbox1, settings.ini, Profile%Profile%, MainAttackbox1, 0
			GuiControl, , MainAttackbox1, %MainAttackbox1%
			IniRead, MainAttackbox2, settings.ini, Profile%Profile%, MainAttackbox2, 0
			GuiControl, , MainAttackbox2, %MainAttackbox2%
			IniRead, MainAttackbox3, settings.ini, Profile%Profile%, MainAttackbox3, 0
			GuiControl, , MainAttackbox3, %MainAttackbox3%
			IniRead, MainAttackbox4, settings.ini, Profile%Profile%, MainAttackbox4, 0
			GuiControl, , MainAttackbox4, %MainAttackbox4%
			IniRead, MainAttackbox5, settings.ini, Profile%Profile%, MainAttackbox5, 0
			GuiControl, , MainAttackbox5, %MainAttackbox5%
			
			IniRead, SecondaryAttackbox1, settings.ini, Profile%Profile%, SecondaryAttackbox1, 0
			GuiControl, , SecondaryAttackbox1, %SecondaryAttackbox1%
			IniRead, SecondaryAttackbox2, settings.ini, Profile%Profile%, SecondaryAttackbox2, 0
			GuiControl, , SecondaryAttackbox2, %SecondaryAttackbox2%
			IniRead, SecondaryAttackbox3, settings.ini, Profile%Profile%, SecondaryAttackbox3, 0
			GuiControl, , SecondaryAttackbox3, %SecondaryAttackbox3%
			IniRead, SecondaryAttackbox4, settings.ini, Profile%Profile%, SecondaryAttackbox4, 0
			GuiControl, , SecondaryAttackbox4, %SecondaryAttackbox4%
			IniRead, SecondaryAttackbox5, settings.ini, Profile%Profile%, SecondaryAttackbox5, 0
			GuiControl, , SecondaryAttackbox5, %SecondaryAttackbox5%
			
			;Attack Keys
			IniRead, hotkeyMainAttack, settings.ini, Profile%Profile%, MainAttack, RButton
			GuiControl, , hotkeyMainAttack, %hotkeyMainAttack%
			IniRead, hotkeySecondaryAttack, settings.ini, Profile%Profile%, SecondaryAttack, w
			GuiControl, , hotkeySecondaryAttack, %hotkeySecondaryAttack%
			
			;QS on Attack Keys
			IniRead, QSonMainAttack, settings.ini, Profile%Profile%, QSonMainAttack, 0
			GuiControl, , QSonMainAttack, %QSonMainAttack%
			IniRead, QSonSecondaryAttack, settings.ini, Profile%Profile%, QSonSecondaryAttack, 0
			GuiControl, , QSonSecondaryAttack, %QSonSecondaryAttack%
			
			;Quicksilver Flasks
			IniRead, TriggerQuicksilverDelay, settings.ini, Profile%Profile%, TriggerQuicksilverDelay, .5
			GuiControl, , TriggerQuicksilverDelay, %TriggerQuicksilverDelay%
			IniRead, Radiobox1QS, settings.ini, Profile%Profile%, QuicksilverSlot1, 0
			GuiControl, , Radiobox1QS, %Radiobox1QS%
			IniRead, Radiobox2QS, settings.ini, Profile%Profile%, QuicksilverSlot2, 0
			GuiControl, , Radiobox2QS, %Radiobox2QS%
			IniRead, Radiobox3QS, settings.ini, Profile%Profile%, QuicksilverSlot3, 0
			GuiControl, , Radiobox3QS, %Radiobox3QS%
			IniRead, Radiobox4QS, settings.ini, Profile%Profile%, QuicksilverSlot4, 0
			GuiControl, , Radiobox4QS, %Radiobox4QS%
			IniRead, Radiobox5QS, settings.ini, Profile%Profile%, QuicksilverSlot5, 0
			GuiControl, , Radiobox5QS, %Radiobox5QS%
			
			;CharacterTypeCheck
			IniRead, RadioLife, settings.ini, Profile%Profile%, Life, 1
			GuiControl, , RadioLife, %RadioLife%
			IniRead, RadioHybrid, settings.ini, Profile%Profile%, Hybrid, 0
			GuiControl, , RadioHybrid, %RadioHybrid%
			IniRead, RadioCi, settings.ini, Profile%Profile%, Ci, 0
			GuiControl, , RadioCi, %RadioCi%
			
			;AutoMines
			IniRead, DetonateMines, settings.ini, Profile%Profile%, DetonateMines, 0
			GuiControl, , DetonateMines, %DetonateMines%

			;EldritchBattery
			IniRead, YesEldritchBattery, settings.ini, Profile%Profile%, YesEldritchBattery, 0
			GuiControl, , YesEldritchBattery, %YesEldritchBattery%

			;ManaThreshold
			IniRead, ManaThreshold, settings.ini, Profile%Profile%, ManaThreshold, 0
			GuiControl, , ManaThreshold, %ManaThreshold%

			;AutoQuit
			IniRead, RadioQuit20, settings.ini, Profile%Profile%, Quit20, 1
			GuiControl, , RadioQuit20, %RadioQuit20%
			IniRead, RadioQuit30, settings.ini, Profile%Profile%, Quit30, 0
			GuiControl, , RadioQuit30, %RadioQuit30%
			IniRead, RadioQuit40, settings.ini, Profile%Profile%, Quit40, 0
			GuiControl, , RadioQuit40, %RadioQuit40%
			IniRead, RadioQuit50, settings.ini, Profile%Profile%, Quit50, 0
			GuiControl, , RadioQuit50, %RadioQuit50%
			IniRead, RadioQuit60, settings.ini, Profile%Profile%, Quit60, 0
			GuiControl, , RadioQuit60, %RadioQuit60%
			IniRead, RadioCritQuit, settings.ini, Profile%Profile%, CritQuit, 1
			GuiControl, , RadioCritQuit, %RadioCritQuit%
			IniRead, RadioPortalQuit, settings.ini, Profile%Profile%, PortalQuit, 0
			GuiControl, , RadioPortalQuit, %RadioPortalQuit%
			IniRead, RadioNormalQuit, settings.ini, Profile%Profile%, NormalQuit, 0
			GuiControl, , RadioNormalQuit, %RadioNormalQuit%


			;Utility Buttons
			IniRead, YesUtility1, settings.ini, Profile%Profile%, YesUtility1, 0
			GuiControl, , YesUtility1, %YesUtility1%
			IniRead, YesUtility2, settings.ini, Profile%Profile%, YesUtility2, 0
			GuiControl, , YesUtility2, %YesUtility2%
			IniRead, YesUtility3, settings.ini, Profile%Profile%, YesUtility3, 0
			GuiControl, , YesUtility3, %YesUtility3%
			IniRead, YesUtility4, settings.ini, Profile%Profile%, YesUtility4, 0
			GuiControl, , YesUtility4, %YesUtility4%
			IniRead, YesUtility5, settings.ini, Profile%Profile%, YesUtility5, 0
			GuiControl, , YesUtility5, %YesUtility5%
			IniRead, YesUtility1Quicksilver, settings.ini, Profile%Profile%, YesUtility1Quicksilver, 0
			GuiControl, , YesUtility1Quicksilver, %YesUtility1Quicksilver%
			IniRead, YesUtility2Quicksilver, settings.ini, Profile%Profile%, YesUtility2Quicksilver, 0
			GuiControl, , YesUtility2Quicksilver, %YesUtility2Quicksilver%
			IniRead, YesUtility3Quicksilver, settings.ini, Profile%Profile%, YesUtility3Quicksilver, 0
			GuiControl, , YesUtility3Quicksilver, %YesUtility3Quicksilver%
			IniRead, YesUtility4Quicksilver, settings.ini, Profile%Profile%, YesUtility4Quicksilver, 0
			GuiControl, , YesUtility4Quicksilver, %YesUtility4Quicksilver%
			IniRead, YesUtility5Quicksilver, settings.ini, Profile%Profile%, YesUtility5Quicksilver, 0
			GuiControl, , YesUtility5Quicksilver, %YesUtility5Quicksilver%
			
			;Utility Percents	
			IniRead, YesUtility1LifePercent, settings.ini, Profile%Profile%, YesUtility1LifePercent, Off
			GuiControl, ChooseString, YesUtility1LifePercent, %YesUtility1LifePercent%
			IniRead, YesUtility2LifePercent, settings.ini, Profile%Profile%, YesUtility2LifePercent, Off
			GuiControl, ChooseString, YesUtility2LifePercent, %YesUtility2LifePercent%
			IniRead, YesUtility3LifePercent, settings.ini, Profile%Profile%, YesUtility3LifePercent, Off
			GuiControl, ChooseString, YesUtility3LifePercent, %YesUtility3LifePercent%
			IniRead, YesUtility4LifePercent, settings.ini, Profile%Profile%, YesUtility4LifePercent, Off
			GuiControl, ChooseString, YesUtility4LifePercent, %YesUtility4LifePercent%
			IniRead, YesUtility5LifePercent, settings.ini, Profile%Profile%, YesUtility5LifePercent, Off
			GuiControl, ChooseString, YesUtility5LifePercent, %YesUtility5LifePercent%
			IniRead, YesUtility1EsPercent, settings.ini, Profile%Profile%, YesUtility1EsPercent, Off
			GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
			IniRead, YesUtility2EsPercent, settings.ini, Profile%Profile%, YesUtility2EsPercent, Off
			GuiControl, ChooseString, YesUtility2EsPercent, %YesUtility2EsPercent%
			IniRead, YesUtility3EsPercent, settings.ini, Profile%Profile%, YesUtility3EsPercent, Off
			GuiControl, ChooseString, YesUtility3EsPercent, %YesUtility3EsPercent%
			IniRead, YesUtility4EsPercent, settings.ini, Profile%Profile%, YesUtility4EsPercent, Off
			GuiControl, ChooseString, YesUtility4EsPercent, %YesUtility4EsPercent%
			IniRead, YesUtility5EsPercent, settings.ini, Profile%Profile%, YesUtility5EsPercent, Off
			GuiControl, ChooseString, YesUtility5EsPercent, %YesUtility5EsPercent%
			
			;Utility Cooldowns
			IniRead, CooldownUtility1, settings.ini, Profile%Profile%, CooldownUtility1, 5000
			GuiControl, , CooldownUtility1, %CooldownUtility1%
			IniRead, CooldownUtility2, settings.ini, Profile%Profile%, CooldownUtility2, 5000
			GuiControl, , CooldownUtility2, %CooldownUtility2%
			IniRead, CooldownUtility3, settings.ini, Profile%Profile%, CooldownUtility3, 5000
			GuiControl, , CooldownUtility3, %CooldownUtility3%
			IniRead, CooldownUtility4, settings.ini, Profile%Profile%, CooldownUtility4, 5000
			GuiControl, , CooldownUtility4, %CooldownUtility4%
			IniRead, CooldownUtility5, settings.ini, Profile%Profile%, CooldownUtility5, 5000
			GuiControl, , CooldownUtility5, %CooldownUtility5%
			
			;Character Name
			IniRead, CharName, settings.ini, Profile%Profile%, CharName, ReplaceWithCharName
			GuiControl, , CharName, %CharName%

			;Utility Keys
			IniRead, KeyUtility1, settings.ini, Profile%Profile%, KeyUtility1, q
			GuiControl, , KeyUtility1, %KeyUtility1%
			IniRead, KeyUtility2, settings.ini, Profile%Profile%, KeyUtility2, w
			GuiControl, , KeyUtility2, %KeyUtility2%
			IniRead, KeyUtility3, settings.ini, Profile%Profile%, KeyUtility3, e
			GuiControl, , KeyUtility3, %KeyUtility3%
			IniRead, KeyUtility4, settings.ini, Profile%Profile%, KeyUtility4, r
			GuiControl, , KeyUtility4, %KeyUtility4%
			IniRead, KeyUtility5, settings.ini, Profile%Profile%, KeyUtility5, t
			GuiControl, , KeyUtility5, %KeyUtility5%

			;Utility Icon Strings
			IniRead, IconStringUtility1, settings.ini, Profile%Profile%, IconStringUtility1, %A_Space%
			If IconStringUtility1
				IconStringUtility1 := """" . IconStringUtility1 . """"
			GuiControl, , IconStringUtility1, %IconStringUtility1%
			IniRead, IconStringUtility2, settings.ini, Profile%Profile%, IconStringUtility2, %A_Space%
			If IconStringUtility2
				IconStringUtility2 := """" . IconStringUtility2 . """"
			GuiControl, , IconStringUtility2, %IconStringUtility2%
			IniRead, IconStringUtility3, settings.ini, Profile%Profile%, IconStringUtility3, %A_Space%
			If IconStringUtility3
				IconStringUtility3 := """" . IconStringUtility3 . """"
			GuiControl, , IconStringUtility3, %IconStringUtility3%
			IniRead, IconStringUtility4, settings.ini, Profile%Profile%, IconStringUtility4, %A_Space%
			If IconStringUtility4
				IconStringUtility4 := """" . IconStringUtility4 . """"
			GuiControl, , IconStringUtility4, %IconStringUtility4%
			IniRead, IconStringUtility5, settings.ini, Profile%Profile%, IconStringUtility5, %A_Space%
			If IconStringUtility5
				IconStringUtility5 := """" . IconStringUtility5 . """"
			GuiControl, , IconStringUtility5, %IconStringUtility5%

			;Pop Flasks Keys
			IniRead, PopFlasks1, settings.ini, Profile%Profile%, PopFlasks1, 1
			GuiControl, , PopFlasks1, %PopFlasks1%
			IniRead, PopFlasks2, settings.ini, Profile%Profile%, PopFlasks2, 1
			GuiControl, , PopFlasks2, %PopFlasks2%
			IniRead, PopFlasks3, settings.ini, Profile%Profile%, PopFlasks3, 1
			GuiControl, , PopFlasks3, %PopFlasks3%
			IniRead, PopFlasks4, settings.ini, Profile%Profile%, PopFlasks4, 1
			GuiControl, , PopFlasks4, %PopFlasks4%
			IniRead, PopFlasks5, settings.ini, Profile%Profile%, PopFlasks5, 1
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
		checkUpdate(){
			IniRead, AutoUpdateOff, settings.ini, General, AutoUpdateOff, 0
			If (!AutoUpdateOff) {
				UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/version.html, version.html
				FileRead, newestVersion, version.html
				
				if ( VersionNumber < newestVersion ) {
					UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/changelog.txt, changelog.txt
					if ErrorLevel
						GuiControl,1:, guiErr, ED08
					FileRead, changelog, changelog.txt
					Gui, 4:Add, Button, x0 y0 h1 w1, a
					Gui, 4:Add, Text,, Update Available.`nYoure running version %VersionNumber%. The newest is version %newestVersion%`n
					Gui, 4:Add, Edit, w600 h200 +ReadOnly, %changelog% 
					Gui, 4:Add, Button, x70 section default grunUpdate, Update to the Newest Version!
					Gui, 4:Add, Button, x+35 ys gLaunchDonate, Support the Project
					Gui, 4:Add, Button, x+35 ys gdontUpdate, Turn off Auto-Update
					Gui, 4:Show,, WingmanReloaded Update
					IfWinExist WingmanReloaded Update ahk_exe AutoHotkey.exe
						{
						WinWaitClose
						}
					}
				WinGetPos, , , WinWidth, WinHeight
				}
		Return
		}

		runUpdate:

			Fail:=False
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/GottaGoFast.ahk, GottaGoFast.ahk
			if ErrorLevel {
				Fail:=true
			}
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/PoE-Wingman.ahk, PoE-Wingman.ahk
			if ErrorLevel {
				Fail:=true
			}
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/LootFilter.ahk, %A_ScriptDir%\data\LootFilter.ahk
			if ErrorLevel {
				Fail:=true
			}
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/Library.ahk, %A_ScriptDir%\data\Library.ahk
			if ErrorLevel {
				Fail:=true
			}
			if Fail {
				Log("update","fail",A_ScriptFullPath, VersionNumber, A_AhkVersion)
				Log("ED07")
			}
			else {
				Log("update","pass",A_ScriptFullPath, VersionNumber, A_AhkVersion)
				Run "%A_ScriptFullPath%"
			}
			Sleep 5000 ;This shouldn't ever hit.
			Log("update","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion)
		Return

		dontUpdate:
			IniWrite, 1, Settings.ini, General, AutoUpdateOff
			MsgBox, Auto-Updates have been disabled.`nCheck back on the forum for more information!`nTo resume updates, uncheck the box in config page.
			Gui, 4:Destroy
		return	
	}

	{ ; Calibration color sample functions - updateOnChar, updateOnInventory, updateOnMenu, updateOnStash,
	;   updateEmptyColor, updateOnChat, updateOnVendor, updateOnDiv, updateDetonate, updateDetonateDelve
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
				pixelgetcolor, varOnChar, vX_OnChar, vY_OnChar
				IniWrite, %varOnChar%, settings.ini, Failsafe Colors, OnChar
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
				pixelgetcolor, varOnInventory, vX_OnInventory, vY_OnInventory
				IniWrite, %varOnInventory%, settings.ini, Failsafe Colors, OnInventory
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
				pixelgetcolor, varOnMenu, vX_OnMenu, vY_OnMenu
				IniWrite, %varOnMenu%, settings.ini, Failsafe Colors, OnMenu
				readFromFile()
				MsgBox % "OnMenu recalibrated!`nTook color hex: " . varOnMenu . " `nAt coords x: " . vX_OnMenu . " and y: " . vY_OnMenu
			}else
			MsgBox % "PoE Window is not active. `nRecalibrate of OnMenu didn't work"
			
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
				MsgBox % "PoE Window does not exist. `nRecalibrate of OnStash didn't work"
				Return
			}
			
			if WinActive(ahk_group POEGameGroup){
				pixelgetcolor, varOnStash, vX_OnStash, vY_OnStash
				IniWrite, %varOnStash%, settings.ini, Failsafe Colors, OnStash
				readFromFile()
				MsgBox % "OnStash recalibrated!`nTook color hex: " . varOnStash . " `nAt coords x: " . vX_OnStash . " and y: " . vY_OnStash
			}else
			MsgBox % "PoE Window is not active. `nRecalibrate of OnStash didn't work"
			
			hotkeys()
			
		return

		updateEmptyColor:
			Thread, NoTimers, true		;Critical
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

				varIdColor := []
				varEmptyInvSlotColor := []
				WinActivate, ahk_group POEGameGroup

				;Loop through the whole grid, and add unknown colors to the lists
				For c, GridX in InventoryGridX	{
					For r, GridY in InventoryGridY
					{
						pixelgetcolor, PointColor, GridX, GridY

						if !(indexOf(PointColor, varEmptyInvSlotColor)){
							;We dont have this Empty color already
							varEmptyInvSlotColor.Push(PointColor)
						}
					}
				}

				strToSave := hexArrToStr(varEmptyInvSlotColor)

				IniWrite, %strToSave%, settings.ini, Inventory Colors, EmptyInvSlotColor
				readFromFile()


				infoMsg := "Empty Slot colors calibrated and saved with following color codes:`r`n`r`n"
				infoMsg .= strToSave

				MsgBox, %infoMsg%


			}else{
				MsgBox % "PoE Window is not active. `nRecalibrate Empty Slot Color didn't work"
			}

			hotkeys()
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
				pixelgetcolor, varOnChat, vX_OnChat, vY_OnChat
				IniWrite, %varOnChat%, settings.ini, Failsafe Colors, OnChat
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
				pixelgetcolor, varOnVendor, vX_OnVendor, vY_OnVendor
				IniWrite, %varOnVendor%, settings.ini, Failsafe Colors, OnVendor
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
				pixelgetcolor, varOnDiv, vX_OnDiv, vY_OnDiv
				IniWrite, %varOnDiv%, settings.ini, Failsafe Colors, OnDiv
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
				MsgBox % "PoE Window does not exist. `nRecalibrate of DetonateHex didn't work"
				Return
			}
			
			if WinActive(ahk_group POEGameGroup){
				pixelgetcolor, DetonateHex, DetonateX, DetonateY
				IniWrite, %DetonateHex%, settings.ini, Failsafe Colors, DetonateHex
				readFromFile()
				MsgBox % "DetonateHex recalibrated!`nTook color hex: " . DetonateHex . " `nAt coords x: " . DetonateX . " and y: " . DetonateY
			}else
			MsgBox % "PoE Window is not active. `nRecalibrate of DetonateHex didn't work"
			
			hotkeys()
			
		return

		updateDetonateDelve:
			Thread, NoTimers, True
			Gui, Submit ; , NoHide
			IfWinExist, ahk_group POEGameGroup
			{
				Rescale()
				WinActivate, ahk_group POEGameGroup
			} else {
				MsgBox % "PoE Window does not exist. `nRecalibrate of DetonateHex didn't work"
				Return
			}
			
			if WinActive(ahk_group POEGameGroup){
				pixelgetcolor, DetonateHex, DetonateDelveX, DetonateY
				IniWrite, %DetonateHex%, settings.ini, Failsafe Colors, DetonateHex
				readFromFile()
				MsgBox % "DetonateHex recalibrated!`nTook color hex: " . DetonateHex . " `nAt coords x: " . DetonateDelveX . " and y: " . DetonateY
			}else
			MsgBox % "PoE Window is not active. `nRecalibrate of DetonateHex didn't work"
			
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
					IniWrite, %OHBLHealthHex%, settings.ini, OHB, OHBLHealthHex
					; If ((RadioHybrid || RadioCi) && !YesEldritchBattery)
					; {
					;     PixelGetColor, OHBLESHex, % OHB.X + 1, % OHB.esY, RGB
					; 	IniWrite, %OHBLESHex%, settings.ini, OHB, OHBLESHex
					; }
					; Else If ((RadioHybrid || RadioCi) && YesEldritchBattery)
					; {
					;     PixelGetColor, OHBLEBHex, % OHB.X + 1, % OHB.ebY, RGB
					; 	IniWrite, %OHBLEBHex%, settings.ini, OHB, OHBLEBHex
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

				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChar      x222 y39             w100 h20 , OnChar
				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChat              xp   y+10            w100 h20 , OnChat
				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnInventory         xp   y+10            w100 h20 , OnInventory
				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnVendor            xp   y+10            w100 h20 , OnVendor
				Gui, Wizard: Add, CheckBox, vCalibrationOnDiv               xp   y+10            w100 h20 , OnDiv

				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnMenu              x342 y39             w100 h20 , OnMenu
				Gui, Wizard: Add, CheckBox, Checked vCalibrationEmpty               xp   y+10            w100 h20 , Empty Inventory
				Gui, Wizard: Add, CheckBox, Checked vCalibrationOnStash             xp   y+10            w100 h20 , OnStash
				Gui, Wizard: Add, CheckBox, vCalibrationDetonate            xp   y+10            w100 h20 , Detonate Mines

				Gui, Wizard: Add, Button, x122 y239 w100 h30 gRunWizard, Run Wizard
				Gui, Wizard: Add, Button, x252 y239 w100 h30 gWizardClose, Cancel Wizard

				Gui, Wizard: Show,% "x"ScrCenter.X - 240 "y"ScrCenter.Y - 150 " h300 w479", Calibration Wizard
			Return

			RunWizard:
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
						pixelgetcolor, varOnChar, vX_OnChar, vY_OnChar
						SampleTT .= "OnChar            took BGR color hex: " . varOnChar . "    At coords x: " . vX_OnChar . " and y: " . vY_OnChar . "`n"
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
						pixelgetcolor, varOnChat, vX_OnChat, vY_OnChat
						SampleTT .= "OnChat            took BGR color hex: " . varOnChat . "    At coords x: " . vX_OnChat . " and y: " . vY_OnChat . "`n"
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
						pixelgetcolor, varOnMenu, vX_OnMenu, vY_OnMenu
						SampleTT .= "OnMenu          took BGR color hex: " . varOnMenu . "    At coords x: " . vX_OnMenu . " and y: " . vY_OnMenu . "`n"
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
						pixelgetcolor, varOnInventory, vX_OnInventory, vY_OnInventory
						SampleTT .= "OnInventory     took BGR color hex: " . varOnInventory . "    At coords x: " . vX_OnInventory . " and y: " . vY_OnInventory . "`n"
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
						For c, GridX in InventoryGridX	
						{
							For r, GridY in InventoryGridY
							{
								pixelgetcolor, PointColor, GridX, GridY
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
						EmptySampleTT := "`nEmpty Inventory took BGR color hexes: " . NewString
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
						pixelgetcolor, varOnVendor, vX_OnVendor, vY_OnVendor
						SampleTT .= "OnVendor        took BGR color hex: " . varOnVendor . "    At coords x: " . vX_OnVendor . " and y: " . vY_OnVendor . "`n"
					} else
					MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
				}
				If CalibrationOnStash
				{
					ToolTip,% "This will sample the OnStash Color"
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
						pixelgetcolor, varOnStash, vX_OnStash, vY_OnStash
						SampleTT .= "OnStash          took BGR color hex: " . varOnStash . "    At coords x: " . vX_OnStash . " and y: " . vY_OnStash . "`n"
					} else
					MsgBox % "PoE Window is not active. `nRecalibrate of OnStash didn't work"
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
						pixelgetcolor, varOnDiv, vX_OnDiv, vY_OnDiv
						SampleTT .= "OnDiv             took BGR color hex: " . varOnDiv . "    At coords x: " . vX_OnDiv . " and y: " . vY_OnDiv . "`n"
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
						pixelgetcolor, DetonateHex, DetonateX, DetonateY
						SampleTT .= "Detonate Mines took BGR color hex: " . DetonateHex . "    At coords x: " . DetonateX . " and y: " . DetonateY . "`n"
					} else
					MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
				}

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
					IniWrite, %varOnChar%, settings.ini, Failsafe Colors, OnChar        
				If CalibrationOnChat
					IniWrite, %varOnChat%, settings.ini, Failsafe Colors, OnChat
				If CalibrationOnMenu
					IniWrite, %varOnMenu%, settings.ini, Failsafe Colors, OnMenu
				If CalibrationOnInventory
					IniWrite, %varOnInventory%, settings.ini, Failsafe Colors, OnInventory
				If CalibrationEmpty
					IniWrite, %strToSave%, settings.ini, Inventory Colors, EmptyInvSlotColor
				If CalibrationOnVendor
					IniWrite, %varOnVendor%, settings.ini, Failsafe Colors, OnVendor
				If CalibrationOnStash
					IniWrite, %varOnStash%, settings.ini, Failsafe Colors, OnStash
				If CalibrationOnDiv
					IniWrite, %varOnDiv%, settings.ini, Failsafe Colors, OnDiv
				If CalibrationDetonate
					IniWrite, %DetonateHex%, settings.ini, Failsafe Colors, DetonateHex
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

	{ ; Loot Colors Menu
		LootColorsMenu()
		{
			DrawLootColors:
				Static LG_Add, LG_Rem
				Global LootColors, LG_Vary
				Gui, Submit
				gui,LootColors: new, LabelLootColors
				gui,LootColors: -MinimizeBox
				gui,LootColors: add, groupbox,% "section w320 h" 24 * (LootColors.Count() / 2) + 25 + 40 , Loot Colors:
				gui,LootColors: add, Button, gSaveLootColorArray yp-5 xp+70 h22, Save to INI
				Gui,LootColors: Add, DropDownList, gUpdateExtra vAreaScale w45 x+10 yp+1,  %AreaScale%||0|30|40|50|60|70|80|90|100|200|300|400|500
				Gui,LootColors: Add, Text, 										x+3 yp+5							, AreaScale
				Gui,LootColors: Add, DropDownList, gUpdateExtra vLVdelay w45 x+5 yp-6,  %LVdelay%||0|15|30|45|60|75|90|105|120|135|150|195|300
				Gui,LootColors: Add, Text, 										x+3 yp+5							, Delay
				gui,LootColors: add, Button, gAdjustLootGroup vLG_Add y+10 xm+50 h22 w100, Add Color Set
				gui,LootColors: add, Button, gAdjustLootGroup vLG_Rem yp x+20 h22 w100, Rem Color Set

				For k, val in LootColors
				{
					color := hexBGRToRGB(Format("0x{1:06X}",val))
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
				groupNumber := StrSplit(A_GuiControl, A_Space)[2]
				MO_Index := (BG_Index := groupNumber * 2) - 1
				IfWinExist, ahk_group POEGameGroup
				{
					WinActivate, ahk_group POEGameGroup
				} else {
					MsgBox % "PoE Window does not exist. `nCannot sample the loot color."
					Return
				}
				RemoveToolTip()
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
					pixelgetcolor, BG_Color, mX, mY
					LootColors[BG_Index] := Format("0x{1:06X}",BG_Color)
					Sleep, 100
					SendInput {%hotkeyLootScan% down}
					Sleep, 200
					pixelgetcolor, MO_Color, mX, mY
					LootColors[MO_Index] := Format("0x{1:06X}",MO_Color)
					SendInput {%hotkeyLootScan% up}
					BlockInput, MouseMoveOff
				} else {
					MsgBox % "PoE Window is not active. `nSampling the loot color didn't work"
					Gui, LootColors: Show
					Exit
				}
				Critical, Off
				Gui, LootColors: Destroy
				LootColorsMenu()
			Return

			SaveLootColorArray:
				LCstr := hexArrToStr(LootColors)
				IniWrite, %LCstr%, settings.ini, Loot Colors, LootColors
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
	}

	{ ; Ignore list functions - addToBlacklist, BuildIgnoreMenu, UpdateCheckbox, LoadIgnoreArray, SaveIgnoreArray
		IgnoreClose:
		IgnoreEscape:
			SaveIgnoreArray()
			Gui, Ignore: Destroy
			Gui, 1: Show
		Return

		addToBlacklist(C, R)
		{
			Loop % Prop.Height
			{
				addNum := A_Index - 1
				addR := R + addNum
				addC := C + 1
				BlackList[C][addR] := True
				If Prop.Width = 2
					BlackList[addC][addR] := True
			}
		}

		BuildIgnoreMenu:
			Gui, Submit
			Gui, Ignore: +LabelIgnore -MinimizeBox
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
			FileRead, JSONtext, %A_ScriptDir%\data\IgnoredSlot.json
			IgnoredSlot := JSON.Load(JSONtext)
			Return
		}

		SaveIgnoreArray()
		{
			SaveIgnoreArray:
			Gui, Ignore: Submit, NoHide
			JSONtext := JSON.Dump(IgnoredSlot)
			FileDelete, %A_ScriptDir%\data\IgnoredSlot.json
			FileAppend, %JSONtext%, %A_ScriptDir%\data\IgnoredSlot.json
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
			FileRead, JSONtext, %A_ScriptDir%\data\LootFilter.json
			LootFilter := JSON.Load(JSONtext)
			If !LootFilter
				LootFilter:={}
			FileRead, JSONtexttabs, %A_ScriptDir%\data\LootFilterTabs.json
			LootFilterTabs := JSON.Load(JSONtexttabs)
			If !LootFilterTabs
				LootFilterTabs:={}
		Return
		}
	}

	{ ; Gui Update functions - updateCharacterType, UpdateStash, UpdateExtra, UpdateResolutionScale, UpdateDebug, UpdateUtility, SelectMainGuiTabs, FlaskCheck, UtilityCheck
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
			Gui, Submit, NoHide
			;Stash Tab Management
			IniWrite, %StashTabCurrency%, settings.ini, Stash Tab, StashTabCurrency
			IniWrite, %StashTabMap%, settings.ini, Stash Tab, StashTabMap
			IniWrite, %StashTabDivination%, settings.ini, Stash Tab, StashTabDivination
			IniWrite, %StashTabGem%, settings.ini, Stash Tab, StashTabGem
			IniWrite, %StashTabGemQuality%, settings.ini, Stash Tab, StashTabGemQuality
			IniWrite, %StashTabFlaskQuality%, settings.ini, Stash Tab, StashTabFlaskQuality
			IniWrite, %StashTabLinked%, settings.ini, Stash Tab, StashTabLinked
			IniWrite, %StashTabCollection%, settings.ini, Stash Tab, StashTabCollection
			IniWrite, %StashTabUniqueRing%, settings.ini, Stash Tab, StashTabUniqueRing
			IniWrite, %StashTabUniqueDump%, settings.ini, Stash Tab, StashTabUniqueDump
			IniWrite, %StashTabFragment%, settings.ini, Stash Tab, StashTabFragment
			IniWrite, %StashTabEssence%, settings.ini, Stash Tab, StashTabEssence
			IniWrite, %StashTabOil%, settings.ini, Stash Tab, StashTabOil
			IniWrite, %StashTabFossil%, settings.ini, Stash Tab, StashTabFossil
			IniWrite, %StashTabResonator%, settings.ini, Stash Tab, StashTabResonator
			IniWrite, %StashTabCrafting%, settings.ini, Stash Tab, StashTabCrafting
			IniWrite, %StashTabProphecy%, settings.ini, Stash Tab, StashTabProphecy
			IniWrite, %StashTabVeiled%, settings.ini, Stash Tab, StashTabVeiled
			IniWrite, %StashTabYesCurrency%, settings.ini, Stash Tab, StashTabYesCurrency
			IniWrite, %StashTabYesMap%, settings.ini, Stash Tab, StashTabYesMap
			IniWrite, %StashTabYesDivination%, settings.ini, Stash Tab, StashTabYesDivination
			IniWrite, %StashTabYesGem%, settings.ini, Stash Tab, StashTabYesGem
			IniWrite, %StashTabYesGemQuality%, settings.ini, Stash Tab, StashTabYesGemQuality
			IniWrite, %StashTabYesFlaskQuality%, settings.ini, Stash Tab, StashTabYesFlaskQuality
			IniWrite, %StashTabYesLinked%, settings.ini, Stash Tab, StashTabYesLinked
			IniWrite, %StashTabYesCollection%, settings.ini, Stash Tab, StashTabYesCollection
			IniWrite, %StashTabYesUniqueRing%, settings.ini, Stash Tab, StashTabYesUniqueRing
			IniWrite, %StashTabYesUniqueDump%, settings.ini, Stash Tab, StashTabYesUniqueDump
			IniWrite, %StashTabYesFragment%, settings.ini, Stash Tab, StashTabYesFragment
			IniWrite, %StashTabYesEssence%, settings.ini, Stash Tab, StashTabYesEssence
			IniWrite, %StashTabYesOil%, settings.ini, Stash Tab, StashTabYesOil
			IniWrite, %StashTabYesFossil%, settings.ini, Stash Tab, StashTabYesFossil
			IniWrite, %StashTabYesResonator%, settings.ini, Stash Tab, StashTabYesResonator
			IniWrite, %StashTabYesCrafting%, settings.ini, Stash Tab, StashTabYesCrafting
			IniWrite, %StashTabYesProphecy%, settings.ini, Stash Tab, StashTabYesProphecy
			IniWrite, %StashTabYesVeiled%, settings.ini, Stash Tab, StashTabYesVeiled
		Return

		UpdateExtra:
			Gui, Submit, NoHide
			IniWrite, %DetonateMines%, settings.ini, General, DetonateMines
			IniWrite, %LootVacuum%, settings.ini, General, LootVacuum
			IniWrite, %YesVendor%, settings.ini, General, YesVendor
			IniWrite, %YesStash%, settings.ini, General, YesStash
			IniWrite, %YesStashT1%, settings.ini, General, YesStashT1
			IniWrite, %YesStashT2%, settings.ini, General, YesStashT2
			IniWrite, %YesStashT3%, settings.ini, General, YesStashT3
			IniWrite, %YesStashCraftingNormal%, settings.ini, General, YesStashCraftingNormal
			IniWrite, %YesStashCraftingMagic%, settings.ini, General, YesStashCraftingMagic
			IniWrite, %YesStashCraftingRare%, settings.ini, General, YesStashCraftingRare
			IniWrite, %YesIdentify%, settings.ini, General, YesIdentify
			IniWrite, %YesDiv%, settings.ini, General, YesDiv
			IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
			IniWrite, %YesSortFirst%, settings.ini, General, YesSortFirst
			IniWrite, %Latency%, settings.ini, General, Latency
			IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
			IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
			IniWrite, %Steam%, settings.ini, General, Steam
			IniWrite, %HighBits%, settings.ini, General, HighBits
			IniWrite, %AutoUpdateOff%, settings.ini, General, AutoUpdateOff
			IniWrite, %YesPersistantToggle%, settings.ini, General, YesPersistantToggle
			IniWrite, %YesPopAllExtraKeys%, settings.ini, General, YesPopAllExtraKeys
			IniWrite, %AreaScale%, settings.ini, General, AreaScale
			IniWrite, %LVdelay%, settings.ini, General, LVdelay
			IniWrite, %YesOHB%, settings.ini, OHB, YesOHB
			IniWrite, %YesSearchForStash%, settings.ini, General, YesSearchForStash
			IniWrite, %YesVendorAfterStash%, settings.ini, General, YesVendorAfterStash
			IniWrite, %YesClickPortal%, settings.ini, General, YesClickPortal
			IniWrite, %RelogOnQuit%, settings.ini, General, RelogOnQuit
			If (YesPersistantToggle)
				AutoReset()
			If (DetonateMines&&!Detonated)
				SetTimer, TMineTick, 100
			Else If (!DetonateMines)
				SetTimer, TMineTick, off
			if ( Steam ) {
				if ( HighBits ) {
					executable := "PathOfExile_x64Steam.exe"
				} else {
					executable := "PathOfExileSteam.exe"
				}
			} else {
				if ( HighBits ) {
					executable := "PathOfExile_x64.exe"
				} else {
					executable := "PathOfExile.exe"
				}
			}
			
		Return

		UpdateEldritchBattery:
			Gui, Submit, NoHide
			IniWrite, %YesEldritchBattery%, settings.ini, General, YesEldritchBattery
			Rescale()
		Return

		UpdateStringEdit:
			Gui, Submit, NoHide
			IniWrite,% %A_GuiControl%, Settings.ini, FindText Strings,% A_GuiControl
			If A_GuiControl = HealthBarStr
				OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
		Return

		UpdateResolutionScale:
			Gui, Submit, NoHide
			IniWrite, %ResolutionScale%, settings.ini, General, ResolutionScale
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
			IniWrite, %DebugMessages%, settings.ini, General, DebugMessages
			IniWrite, %YesTimeMS%, settings.ini, General, YesTimeMS
			IniWrite, %YesLocation%, settings.ini, General, YesLocation
		Return

		UpdateUtility:
			Gui, Submit, NoHide
			;Utility Buttons
			IniWrite, %YesUtility1%, settings.ini, Utility Buttons, YesUtility1
			IniWrite, %YesUtility2%, settings.ini, Utility Buttons, YesUtility2
			IniWrite, %YesUtility3%, settings.ini, Utility Buttons, YesUtility3
			IniWrite, %YesUtility4%, settings.ini, Utility Buttons, YesUtility4
			IniWrite, %YesUtility5%, settings.ini, Utility Buttons, YesUtility5
			IniWrite, %YesUtility1Quicksilver%, settings.ini, Utility Buttons, YesUtility1Quicksilver
			IniWrite, %YesUtility2Quicksilver%, settings.ini, Utility Buttons, YesUtility2Quicksilver
			IniWrite, %YesUtility3Quicksilver%, settings.ini, Utility Buttons, YesUtility3Quicksilver
			IniWrite, %YesUtility4Quicksilver%, settings.ini, Utility Buttons, YesUtility4Quicksilver
			IniWrite, %YesUtility5Quicksilver%, settings.ini, Utility Buttons, YesUtility5Quicksilver
			
			;Utility Percents	
			IniWrite, %YesUtility1LifePercent%, settings.ini, Utility Buttons, YesUtility1LifePercent
			IniWrite, %YesUtility2LifePercent%, settings.ini, Utility Buttons, YesUtility2LifePercent
			IniWrite, %YesUtility3LifePercent%, settings.ini, Utility Buttons, YesUtility3LifePercent
			IniWrite, %YesUtility4LifePercent%, settings.ini, Utility Buttons, YesUtility4LifePercent
			IniWrite, %YesUtility5LifePercent%, settings.ini, Utility Buttons, YesUtility5LifePercent
			IniWrite, %YesUtility1EsPercent%, settings.ini, Utility Buttons, YesUtility1EsPercent
			IniWrite, %YesUtility2EsPercent%, settings.ini, Utility Buttons, YesUtility2EsPercent
			IniWrite, %YesUtility3EsPercent%, settings.ini, Utility Buttons, YesUtility3EsPercent
			IniWrite, %YesUtility4EsPercent%, settings.ini, Utility Buttons, YesUtility4EsPercent
			IniWrite, %YesUtility5EsPercent%, settings.ini, Utility Buttons, YesUtility5EsPercent
			
			;Utility Cooldowns
			IniWrite, %CooldownUtility1%, settings.ini, Utility Cooldowns, CooldownUtility1
			IniWrite, %CooldownUtility2%, settings.ini, Utility Cooldowns, CooldownUtility2
			IniWrite, %CooldownUtility3%, settings.ini, Utility Cooldowns, CooldownUtility3
			IniWrite, %CooldownUtility4%, settings.ini, Utility Cooldowns, CooldownUtility4
			IniWrite, %CooldownUtility5%, settings.ini, Utility Cooldowns, CooldownUtility5
			
			;Utility Keys
			IniWrite, %KeyUtility1%, settings.ini, Utility Keys, KeyUtility1
			IniWrite, %KeyUtility2%, settings.ini, Utility Keys, KeyUtility2
			IniWrite, %KeyUtility3%, settings.ini, Utility Keys, KeyUtility3
			IniWrite, %KeyUtility4%, settings.ini, Utility Keys, KeyUtility4
			IniWrite, %KeyUtility5%, settings.ini, Utility Keys, KeyUtility5
			
			;Utility Keys
			IniWrite, %IconStringUtility1%, settings.ini, Utility Icons, IconStringUtility1
			IniWrite, %IconStringUtility2%, settings.ini, Utility Icons, IconStringUtility2
			IniWrite, %IconStringUtility3%, settings.ini, Utility Icons, IconStringUtility3
			IniWrite, %IconStringUtility4%, settings.ini, Utility Icons, IconStringUtility4
			IniWrite, %IconStringUtility5%, settings.ini, Utility Icons, IconStringUtility5
			
			SendMSG(1, 0)
		Return

		SelectMainGuiTabs:
			GuiControlGet MainGuiTabs
			GuiControl % (MainGuiTabs = "Chat") ? "Show" : "Hide", InnerTab
			GuiControl MoveDraw, MainGuiTabs
		return

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

		LaunchWiki:
			Run, https://github.com/BanditTech/WingmanReloaded/wiki ; Open the wiki page for the script
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

		CleanUp(){
			DetectHiddenWindows, On
			
			WinGet, PID, PID, %A_ScriptDir%\GottaGoFast.ahk
			Process, Close, %PID%
		Return
		}

		UpdateProfileText1:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText1, , ProfileText1
			IniWrite, %ProfileText1%, settings.ini, Profiles, ProfileText1
		Return

		UpdateProfileText2:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText2, , ProfileText2
			IniWrite, %ProfileText2%, settings.ini, Profiles, ProfileText2
		Return

		UpdateProfileText3:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText3, , ProfileText3
			IniWrite, %ProfileText3%, settings.ini, Profiles, ProfileText3
		Return

		UpdateProfileText4:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText4, , ProfileText4
			IniWrite, %ProfileText4%, settings.ini, Profiles, ProfileText4
		Return

		UpdateProfileText5:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText5, , ProfileText5
			IniWrite, %ProfileText5%, settings.ini, Profiles, ProfileText5
		Return

		UpdateProfileText6:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText6, , ProfileText6, 
			IniWrite, %ProfileText6%, settings.ini, Profiles, ProfileText6
		Return

		UpdateProfileText7:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText7, , ProfileText7
			IniWrite, %ProfileText7%, settings.ini, Profiles, ProfileText7
		Return

		UpdateProfileText8:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText8, , ProfileText8
			IniWrite, %ProfileText8%, settings.ini, Profiles, ProfileText8
		Return

		UpdateProfileText9:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText9, , ProfileText9
			IniWrite, %ProfileText9%, settings.ini, Profiles, ProfileText9
		Return

		UpdateProfileText10:
			;Gui, Submit, NoHide
			GuiControlGet, ProfileText10, , ProfileText10
			IniWrite, %ProfileText10%, settings.ini, Profiles, ProfileText10
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
					IniWrite, %ClientLog%, Settings.ini, Log, ClientLog
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
					IniWrite, %SelectClientLog%, Settings.ini, Log, ClientLog
					Monitor_GameLogs(1)
				}
				Hotkeys()
			}
		Return
	}

	; Comment out this line if your script crashes on launch
	#Include, %A_ScriptDir%\data\Library.ahk
