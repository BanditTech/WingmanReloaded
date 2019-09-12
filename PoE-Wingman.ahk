#IfWinActive Path of Exile
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
    ListLines Off
    Process, Priority, , A
    SetBatchLines, -1
    SetKeyDelay, -1, -1
    SetMouseDelay, -1
    SetDefaultMouseSpeed, 0
    SetWinDelay, -1
    SetControlDelay, -1
    FileEncoding , UTF-8
    SendMode Input
    StringCaseSense, On ; Match strings with case.
    ; Create a container for the sub-script
    Global scriptGottaGoFast := "GottaGoFast.ahk ahk_exe AutoHotkey.exe"
    ; Create Executable group for gameHotkey, IfWinActive
    global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
    for n, exe in POEGameArr {
        GroupAdd, POEGameGroup, ahk_exe %exe%
    }
    Hotkey, IfWinActive, ahk_group POEGameGroup
        
    OnMessage(0x5555, "MsgMonitor")
    OnMessage(0x5556, "MsgMonitor")
    
    SetTitleMatchMode 3 
    CoordMode, Mouse, Screen
    CoordMode, Pixel, Screen
    SetWorkingDir %A_ScriptDir%  
    Thread, interrupt, 0
    I_Icon = shield_charge_skill_icon.ico
    IfExist, %I_Icon%
        Menu, Tray, Icon, %I_Icon%
    
    Global VersionNumber := .05.02

	Global Null := 0
    
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
    
    If FileExist("settings.ini")
        readFromFile()
	Global Enchantment  := []
	Global Corruption := []
	Global WeaponBases, ArmourBases
	
	IfNotExist, %A_ScriptDir%\data\boot_enchantment_mods.txt
	{
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/boot_enchantment_mods.txt, %A_ScriptDir%\data\boot_enchantment_mods.txt
		if ErrorLevel{
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "boot_enchantment_mods")
			MsgBox, Error ED02 : There was a problem downloading boot_enchantment_mods.txt
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "boot_enchantment_mods")
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
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/helmet_enchantment_mods.txt, %A_ScriptDir%\data\helmet_enchantment_mods.txt
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "helmet_enchantment_mods")
			MsgBox, Error ED02 : There was a problem downloading helmet_enchantment_mods.txt
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "helmet_enchantment_mods")
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
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/glove_enchantment_mods.txt, %A_ScriptDir%\data\glove_enchantment_mods.txt
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "glove_enchantment_mods")
			MsgBox, Error ED02 : There was a problem downloading glove_enchantment_mods.txt
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "glove_enchantment_mods")
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
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/item_corrupted_mods.txt, %A_ScriptDir%\data\item_corrupted_mods.txt
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "item_corrupted_mods")
			MsgBox, Error ED02 : There was a problem downloading item_corrupted_mods.txt
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "item_corrupted_mods")
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
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/Controller.png, %A_ScriptDir%\data\Controller.png
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "Controller.png")
			MsgBox, Error ED02 : There was a problem downloading Controller.png
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "Controller.png")
		}
	}
	IfNotExist, %A_ScriptDir%\data\JSON.ahk
	{
		FileCreateDir, %A_ScriptDir%\data
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/JSON.ahk, %A_ScriptDir%\data\JSON.ahk
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "JSON.ahk")
			MsgBox, Error ED02 : There was a problem downloading JSON.ahk
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "JSON.ahk")
			MsgBox % "JSON library installed, ready for next patch!"
		}
	}
	IfNotExist, %A_ScriptDir%\data\LootFilter.ahk
	{
		FileCreateDir, %A_ScriptDir%\data
    	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/LootFilter.ahk, %A_ScriptDir%\data\LootFilter.ahk
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "LootFilter.ahk")
			MsgBox, Error ED02 : There was a problem downloading LootFilter.ahk
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "LootFilter.ahk")
		}
	}
	IfNotExist, %A_ScriptDir%\data\ArmourBases.json
	{
		FileCreateDir, %A_ScriptDir%\data
    	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/ArmourBases.json, %A_ScriptDir%\data\ArmourBases.json
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "ArmourBases.json")
			MsgBox, Error ED02 : There was a problem downloading ArmourBases.json
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "ArmourBases.json")
			needReload:=true
		}
	}
	Else
	{
		FileRead, JSONtext, %A_ScriptDir%\data\ArmourBases.json
		ArmourBases := JSON.Load(JSONtext)
	}
	IfNotExist, %A_ScriptDir%\data\WeaponBases.json
	{
		FileCreateDir, %A_ScriptDir%\data
    	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/WeaponBases.json, %A_ScriptDir%\data\WeaponBases.json
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "WeaponBases.json")
			MsgBox, Error ED02 : There was a problem downloading WeaponBases.json
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "WeaponBases.json")
			needReload:=true
		}
	}
	Else
	{
		FileRead, JSONtext, %A_ScriptDir%\data\WeaponBases.json
		WeaponBases := JSON.Load(JSONtext)
	}
	IfNotExist, %A_ScriptDir%\data\BeltBases.json
	{
		FileCreateDir, %A_ScriptDir%\data
    	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/data/BeltBases.json, %A_ScriptDir%\data\BeltBases.json
		if ErrorLevel {
 			error("data","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion, "BeltBases.json")
			MsgBox, Error ED02 : There was a problem downloading BeltBases.json
		}
		Else if (ErrorLevel=0){
 			error("data","pass", A_ScriptFullPath, VersionNumber, A_AhkVersion, "BeltBases.json")
			needReload:=true
		}
	}
	Else
	{
		FileRead, JSONtext, %A_ScriptDir%\data\BeltBases.json
		BeltBases := JSON.Load(JSONtext)
	}
	If needReload
		Reload
	; Comment out this line if your script crashes on launch
	#Include, %A_ScriptDir%\data\JSON.ahk

; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	; Extra vars - Not in INI
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

    ;General
		Global Latency := 1
		Global ShowOnStart := 0
		Global PopFlaskRespectCD := 1
		Global ResolutionScale := "Standard"
		Global IdColor := 0x1C0101
		Global UnIdColor := 0x01012A
		Global MOColor := 0x011C01
		Global QSonMainAttack := 1
		Global QSonSecondaryAttack := 1
		Global YesPersistantToggle := 1

		Global FlaskList := []
		; Use this area scale value to change how the pixel search behaves, Increasing the AreaScale will add +-(AreaScale) 
		Global AreaScale := 4
		Global LootVacuum := 1
		Global YesVendor := 1
		Global YesStash := 1
		Global YesIdentify := 1
		Global YesDiv := 1
		Global YesMapUnid := 1
		Global YesStashKeys := 1
		Global OnHideout := False
		Global OnChar := False
		Global OnChat := False
		Global OnInventory := False
		Global OnStash := False
		Global OnVendor := False
		Global OnDiv := False
		Global RescaleRan := False
		Global ToggleExist := False
		; These colors are from filterblade.xyz filter creator
		; Choose one of the default background colors with no transparency
		; These are the mouseover Hex for each of the default colors
		Global ColorKey := { Red: 0xFE2222
			, Brown : 0xDA8B4D
			, Tan : 0xFCDDB2
			, Yellow : 0xEFDB27
			, Green : 0x22AB22
			, Baby Blue : 0x45F2F2
			, Blue : 0x2222FE
			, Lavender : 0x8F8FFE
			, White : 0xFFFFFF
			, Black : 0x222222}

		; Use the colorkey above to choose your background colors.
		; The example below uses two colors black and white
		Global LootColors := { 1 : 0x222222
			, 2 : 0xFFFFFF}

		; Use this as an example of adding more colors into the loot vacuum (This adds tan and red at postion 2,3)
		Global ExampleColors := { 1 : 0xFFFFFF
			, 2 : 0xFCDDB2
			, 3 : 0xFE2222
			, 4 : 0x222222}

		;Item Parse blank Arrays
		Global Prop := {}
		Global Stats := {}
		Global Affix := {}

		global Detonated := 0
		global CritQuit := 1
		global CurrentTab := 0
		global DebugMessages := 0
		global ShowPixelGrid := 0
		global ShowItemInfo := 0
		global DetonateMines := 0
		global Latency := 1
		global RunningToggle := False
		Global Steam := 1
		Global HighBits := 1
		Global AutoUpdateOff := 0
		Global EnableChatHotkeys := 0
		; Dont change the speed & the tick unless you know what you are doing
			global Speed:=1
			global Tick:=50
	;Inventory
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
		Global StashTabProphecy := 1
	;Checkbox to activate each tab
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
		Global StashTabYesProphecy := 1
		;Controller
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
	;~ Hotkeys
	; Legend:   ! = Alt      ^ = Ctrl     + = Shift 
		global hotkeyOptions:=!F10
		global hotkeyAutoFlask:=!F11
		global hotkeyAutoQuit:=!F12
		global hotkeyLogout:=F12
		global hotkeyAutoQuicksilver:=!MButton
		global hotkeyPopFlasks:=CapsLock
		global hotkeyItemSort:=F6
		global hotkeyLootScan:=f
		global hotkeyQuickPortal:=!q
		global hotkeyGemSwap:=!e
		global hotkeyGetMouseCoords:=!o
		global hotkeyCloseAllUI:=Space
		global hotkeyInventory:=c
		global hotkeyWeaponSwapKey:=x
		global hotkeyMainAttack:=RButton
		global hotkeySecondaryAttack:=w

	;Coordinates
		global PortalScrollX:=1825
		global PortalScrollY:=825
		global WisdomScrollX:=1875
		global WisdomScrollY:=825
		global StockPortal:=0
		global StockWisdom:=0
		global GuiX:=-5
		global GuiY:=1005

	;Inventory Colors
		global varEmptyInvSlotColor := [0x000100, 0x020402, 0x000000, 0x020302, 0x010201, 0x060906, 0x050905] ;Default values from sauron-dev
		global varMouseoverColor := [0x000100, 0x020402, 0x000000, 0x020302, 0x010201, 0x060906, 0x050905]

	;Failsafe Colors
		global varOnHideout:=0xB5EFFE
		global varOnHideoutMin:=0xCDF6FE
		global varOnChar:=0x4F6980
		global varOnChat:=0x3B6288
		global varOnInventory:=0x8CC6DD
		global varOnStash:=0x9BD6E7
		global varOnVendor:=0x7BB1CC
		global varOnDiv:=0xC5E2F6
		Global DetonateHex := 0x412037

	;Life Colors
		global varLife20
		global varLife30
		global varLife40
		global varLife50
		global varLife60
		global varLife70
		global varLife80
		global varLife90
		
	;ES Colors
		global varES20
		global varES30
		global varES40
		global varES50
		global varES60
		global varES70
		global varES80
		global varES90

	;Mana Colors
		global varMana10

	;Gem Swap
		global CurrentGemX:=1483
		global CurrentGemY:=372
		global AlternateGemX:=1379 
		global AlternateGemY:=171
		global AlternateGemOnSecondarySlot:=1

	;Attack Triggers
		global TriggerMainAttack:=00000
		global TriggerSecondaryAttack:=00000
		Global MainAttackbox1,MainAttackbox2,MainAttackbox3,MainAttackbox4,MainAttackbox5
		Global SecondaryAttackbox1,SecondaryAttackbox2,SecondaryAttackbox3,SecondaryAttackbox4,SecondaryAttackbox5

	;CharacterTypeCheck
		global Life:=1
		global Hybrid:=0
		global Ci:=0

	;Life Triggers
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
	;ES Triggers
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

	;Mana Triggers
		global TriggerMana10:=00000

	;AutoQuit
		global RadioQuit20, RadioQuit30, RadioQuit40, RadioCritQuit, RadioNormalQuit

	;Character Type
		global RadioCi, RadioHybrid, RadioLife
		
	;Utility Buttons
		global YesUtility1, YesUtility2, YesUtility3, YesUtility4, YesUtility5
		global YesUtility1Quicksilver, YesUtility2Quicksilver, YesUtility3Quicksilver, YesUtility4Quicksilver, YesUtility5Quicksilver
		global YesUtility1LifePercent, YesUtility2LifePercent, YesUtility3LifePercent, YesUtility4LifePercent, YesUtility5LifePercent
		global YesUtility1ESPercent, YesUtility2ESPercent, YesUtility3ESPercent, YesUtility4ESPercent, YesUtility5ESPercent

	;Utility Cooldowns
		global CooldownUtility1, CooldownUtility2, CooldownUtility3, CooldownUtility4, CooldownUtility5
		global OnCooldownUtility1 := 0
		global OnCooldownUtility2 := 0
		global OnCooldownUtility3 := 0
		global OnCooldownUtility4 := 0
		global OnCooldownUtility5 := 0

	;Utility Keys
		global KeyUtility1, KeyUtility2, KeyUtility3, KeyUtility4, KeyUtility5

	;Flask Cooldowns
		global CooldownFlask1:=5000
		global CooldownFlask2:=5000
		global CooldownFlask3:=5000
		global CooldownFlask4:=5000
		global CooldownFlask5:=5000
		global Cooldown:=5000

	;Quicksilver
		global TriggerQuicksilverDelay=0.8
		global TriggerQuicksilver=00000
	;Chat Functions
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
; ReadFromFile()
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	readFromFile()
; Wingman Gui Variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if RadioLife=1 
		{
		varTextAutoQuit20:="20 % Life"
		varTextAutoQuit30:="30 % Life"
		varTextAutoQuit40:="40 % Life"
		} 
	else if RadioHybrid=1 
		{
		varTextAutoQuit20:="20 % Life"
		varTextAutoQuit30:="30 % Life"
		varTextAutoQuit40:="40 % Life"
		}
	else if RadioCi=1 
		{
		varTextAutoQuit20:="20 % ES"
		varTextAutoQuit30:="30 % ES"
		varTextAutoQuit40:="40 % ES"
		}
	GuiControl,, RadioQuit20, %varTextAutoQuit20%
	GuiControl,, RadioQuit30, %varTextAutoQuit30%
	GuiControl,, RadioQuit40, %varTextAutoQuit40%

; MAIN Gui Section
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Gui Add, Tab2, vMainGuiTabs x1 y1 w620 h465 -wrap gSelectMainGuiTabs, Flasks and Utility|Configuration|Inventory|Chat|Controller
	;#######################################################################################################Flasks and Utility Tab
	Gui, Tab, Flasks and Utility
	Gui, Font,

	Gui, Font, Bold
	Gui Add, Text, 										x12 	y30, 				Flask Settings
	Gui, Font,

	Gui Add, Text, 										x12 	y+10, 				Character Type:
	Gui, Font, cRed
	Gui Add, Radio, Group 	vRadioLife Checked%RadioLife% 					x+8 gUpdateCharacterType, 	Life
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

	Gui Add, Text, 										x12 	y+5, 				Duration:
	Gui Add, Edit, 			vCooldownFlask1 			x63 	y+-15 	w34	h17, 	%CooldownFlask1%
	Gui Add, Edit, 			vCooldownFlask2 			x+8 			w34	h17, 	%CooldownFlask2%
	Gui Add, Edit, 			vCooldownFlask3 			x+7 			w34	h17, 	%CooldownFlask3%
	Gui Add, Edit, 			vCooldownFlask4 			x+8 			w34	h17, 	%CooldownFlask4%
	Gui Add, Edit, 			vCooldownFlask5 			x+7 			w34	h17, 	%CooldownFlask5%

	Gui, Font, cRed
	Gui Add, Text,										x62	 	y+5, 				Life
	Gui Add, Text,										x+25, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui Add, Text,										x+24, 						Life
	Gui, Font
	Gui Add, Text,										x80	 	y+-13,				|
	Gui Add, Text,										x+40, 						|
	Gui Add, Text,										x+39, 						|
	Gui Add, Text,										x+39, 						|
	Gui Add, Text,										x+39, 						|
	Gui, Font, cBlue
	Gui Add, Text,										x83	 	y+-13,				ES
	Gui Add, Text,										x+28, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui Add, Text,										x+27, 						ES
	Gui, Font

	Gui Add, Text, 										x23 	y+5, 				< 90`%:
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
		Gui Add, Radio, Group 	vRadiobox%A_Index%Life90 gFlaskCheck		x+12	y+-157 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life80 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life70 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life60 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life50 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life40 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life30 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadiobox%A_Index%Life20 gFlaskCheck				y+5 	w13 h13
		Gui Add, Radio, 		vRadioUncheck%A_Index%Life 					y+5 	w13 h13
		
		Gui Add, Radio, Group 	vRadiobox%A_Index%ES90 gFlaskCheck			x+3 	y+-157 	w13 h13
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

	Gui Add, Text, 													x16 	y+12, 				Quicks.:
	Gui Add, Text, 													x25 	y+10, 				Mana:
	Gui Add, Radio, Group 	vRadiobox1QS 		gUtilityCheck		x+20 	y+-36 	w13 h13
	Gui Add, Radio, 		vRadiobox1Mana10 	gUtilityCheck				y+10 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, Radio, Group 	vRadiobox%vFlask%QS		gUtilityCheck	x+28 	y+-36 	w13 h13
		Gui Add, Radio, 		vRadiobox%vFlask%Mana10 gUtilityCheck			y+10 	w13 h13
		vFlask:=vFlask+1
		}
	Loop, 5 {	
		valueMana10 := substr(TriggerMana10, (A_Index), 1)
		GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
		valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
		GuiControl, , Radiobox%A_Index%QS, %valueQuicksilver%
		}

	Gui Add, Edit, 			vhotkeyMainAttack 				x12 	y+10 	w45 h17, 	%hotkeyMainAttack%
	Gui Add, Checkbox, 		vMainAttackbox1 			x75 	y+-15 	w13 h13
	vFlask=2
	loop 4 {
		Gui Add, Checkbox, 		vMainAttackbox%vFlask% 		x+28 			w13 h13
		vFlask:=vFlask+1
		} 

	Gui Add, Edit, 			vhotkeySecondaryAttack 		x12 	y+5 	w45 h17, 	%hotkeySecondaryAttack%
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

	Gui Add, Text, 										x12 	y+10, 				Quicksilver Flask Movement Delay (in s):
	Gui Add, Edit, 			vTriggerQuicksilverDelay	x+31 	y+-15 	w22 h17, 	%TriggerQuicksilverDelay%

	Gui Add, Text, 										x12 	y+10, 				Auto-Quit:
	Gui Add, Radio, Group 	vRadioQuit20 Checked%RadioQuit20% 				x+5, 						%varTextAutoQuit20%
	Gui Add, Radio, 		vRadioQuit30 Checked%RadioQuit30% 				x+5, 						%varTextAutoQuit30%
	Gui Add, Radio, 		vRadioQuit40 Checked%RadioQuit40% 				x+5, 						%varTextAutoQuit40%
	Gui Add, Text, 										x20 	y+10, 				Quit via:
	Gui, Add, Radio, Group	vRadioCritQuit Checked%RadioCritQuit%					x+5		y+-13,				LutBot Method
	Gui, Add, Radio, 		vRadioNormalQuit Checked%RadioNormalQuit%			x+19	,				normal /exit

	;Vertical Grey Lines
	Gui, Add, Text, 									x59 	y77 		h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+34 				h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+34 				h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+5 	y23		w1	h441 0x7
	Gui, Add, Text, 									x+1 	y23		w1	h441 0x7

	Gui, Add, Text, 									x447 	y51 		h135 0x11


	Gui, Font, Bold
	Gui, Add, Text, 					Section					x292 	y30, 				Flask Profile Management:
	Gui, Font
	Gui, Add, Button, gsubmitProfile1 xs-2 ys+22 w50 h21, Save 1
	Gui, Add, Button, gsubmitProfile2 w50 h21, Save 2
	Gui, Add, Button, gsubmitProfile3 w50 h21, Save 3
	Gui, Add, Button, gsubmitProfile4 w50 h21, Save 4
	Gui, Add, Button, gsubmitProfile5 w50 h21, Save 5

	Gui, Add, Edit, gUpdateProfileText1 vProfileText1 x+1 ys+23 w50 h19, %ProfileText1%
	Gui, Add, Edit, gUpdateProfileText2 vProfileText2 y+8 w50 h19, %ProfileText2%
	Gui, Add, Edit, gUpdateProfileText3 vProfileText3 y+8 w50 h19, %ProfileText3%
	Gui, Add, Edit, gUpdateProfileText4 vProfileText4 y+8 w50 h19, %ProfileText4%
	Gui, Add, Edit, gUpdateProfileText5 vProfileText5 y+8 w50 h19, %ProfileText5%

	Gui, Add, Button, greadProfile1 x+1 ys+22 w50 h21, Load 1
	Gui, Add, Button, greadProfile2 w50 h21, Load 2
	Gui, Add, Button, greadProfile3 w50 h21, Load 3
	Gui, Add, Button, greadProfile4 w50 h21, Load 4
	Gui, Add, Button, greadProfile5 w50 h21, Load 5

	Gui, Add, Button, gsubmitProfile6 x+10 ys+22 w50 h21, Save 6
	Gui, Add, Button, gsubmitProfile7 w50 h21, Save 7
	Gui, Add, Button, gsubmitProfile8 w50 h21, Save 8
	Gui, Add, Button, gsubmitProfile9 w50 h21, Save 9
	Gui, Add, Button, gsubmitProfile10 w50 h21, Save 10

	Gui, Add, Edit, gUpdateProfileText6 vProfileText6 y+8 x+1 ys+23 w50 h19, %ProfileText6%
	Gui, Add, Edit, gUpdateProfileText7 vProfileText7 y+8 w50 h19, %ProfileText7%
	Gui, Add, Edit, gUpdateProfileText8 vProfileText8 y+8 w50 h19, %ProfileText8%
	Gui, Add, Edit, gUpdateProfileText9 vProfileText9 y+8 w50 h19, %ProfileText9%
	Gui, Add, Edit, gUpdateProfileText10 vProfileText10 y+8 w50 h19, %ProfileText10%

	Gui, Add, Button, greadProfile6 x+1 ys+22 w50 h21, Load 6
	Gui, Add, Button, greadProfile7 w50 h21, Load 7
	Gui, Add, Button, greadProfile8 w50 h21, Load 8
	Gui, Add, Button, greadProfile9 w50 h21, Load 9
	Gui, Add, Button, greadProfile10 w50 h21, Load 10

	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section xs+10 y+15 w160 h45											,Character Name:
	Gui,Font,
	Gui, Add, Edit, vCharName xs+5 ys+18 w150 h19, %CharName%

	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+20 ys w120 h60											,QS on attack:
	Gui,Font,
	Gui, Add, Checkbox, vQSonMainAttack +BackgroundTrans Checked%QSonMainAttack% xs+5 ys+20 , Primary Attack
	Gui, Add, Checkbox, vQSonSecondaryAttack +BackgroundTrans Checked%QSonSecondaryAttack%  , Secondary Attack

	Gui, Font, Bold
	Gui Add, Text, 								section		x292 	y250, 				Utility Management:
	Gui, Font,

	Gui Add, Checkbox, gUpdateUtility	vYesUtility1 +BackgroundTrans Checked%YesUtility1%		y+34	, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility2 +BackgroundTrans Checked%YesUtility2%		y+12	, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility3 +BackgroundTrans Checked%YesUtility3%		y+12	, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility4 +BackgroundTrans Checked%YesUtility4%		y+12	, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility5 +BackgroundTrans Checked%YesUtility5%		y+12	, %A_Space%

	Gui,Add,Edit,			gUpdateUtility  x+10 ys+44   w40 h19 	vCooldownUtility1				,%CooldownUtility1%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility2				,%CooldownUtility2%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility3				,%CooldownUtility3%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility4				,%CooldownUtility4%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownUtility5				,%CooldownUtility5%

	Gui,Add,Edit,	  	x+20	ys+44   w40 h19 gUpdateUtility	vKeyUtility1				,%KeyUtility1%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility2				,%KeyUtility2%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility3				,%KeyUtility3%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility4				,%KeyUtility4%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vKeyUtility5				,%KeyUtility5%

	Gui Add, Checkbox, gUpdateUtility	vYesUtility1Quicksilver +BackgroundTrans Checked%YesUtility1Quicksilver%	x+20 ys+47, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility2Quicksilver +BackgroundTrans Checked%YesUtility2Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility3Quicksilver +BackgroundTrans Checked%YesUtility3Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility4Quicksilver +BackgroundTrans Checked%YesUtility4Quicksilver%		y+12, %A_Space%
	Gui Add, Checkbox, gUpdateUtility	vYesUtility5Quicksilver +BackgroundTrans Checked%YesUtility5Quicksilver%		y+12, %A_Space%

	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility1LifePercent h16 w40 x+12 	ys+43,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility2LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility3LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility4LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility5LifePercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	GuiControl, ChooseString, YesUtility1LifePercent, %YesUtility1LifePercent%
	GuiControl, ChooseString, YesUtility2LifePercent, %YesUtility2LifePercent%
	GuiControl, ChooseString, YesUtility3LifePercent, %YesUtility3LifePercent%
	GuiControl, ChooseString, YesUtility4LifePercent, %YesUtility4LifePercent%
	GuiControl, ChooseString, YesUtility5LifePercent, %YesUtility5LifePercent%
		
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility1ESPercent h16 w40 x+25 	ys+43,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility2ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility3ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility4ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	Gui, Add, DropDownList, R5 gUpdateUtility vYesUtility5ESPercent h16 w40  		y+4,  Off|20|30|40|50|60|70|80|90
	GuiControl, ChooseString, YesUtility1ESPercent, %YesUtility1ESPercent%
	GuiControl, ChooseString, YesUtility2ESPercent, %YesUtility2ESPercent%
	GuiControl, ChooseString, YesUtility3ESPercent, %YesUtility3ESPercent%
	GuiControl, ChooseString, YesUtility4ESPercent, %YesUtility4ESPercent%
	GuiControl, ChooseString, YesUtility5ESPercent, %YesUtility5ESPercent%

	Gui Add, Text, 										x292 	ys+25, 	ON:
	Gui Add, Text, 										x+25 	, 	CD:
	Gui Add, Text, 										x+40 	, 	Key:
	Gui Add, Text, 										x+31 	, 	QS:
	Gui Add, Text, 										x+28 	, 	Life:
	Gui Add, Text, 										x+47 	, 	ES:

	Gui, Add, Text, 									x317 	ys+25 		h145 0x11
	Gui, Add, Text, 									x+52 	 		h145 0x11
	Gui, Add, Text, 									x+52 	 		h145 0x11
	Gui, Add, Text, 									x+27 	 		h145 0x11
	Gui, Add, Text, 									x+57 	 		h145 0x11

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y430	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	;#######################################################################################################Configuration Tab
	Gui, Tab, Configuration
	Gui, Add, Text, 									x279 	y23		w1	h441 0x7
	Gui, Add, Text, 									x+1 	y23		w1	h441 0x7

	Gui, Add, Text, 									x376 	y29 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11

	Gui, Font, Bold
	Gui, Add, Text, 						section				x22 	y30, 				Gamestate Calibration:
	Gui, Font
	Gui, Add, Button, ghelpCalibration 	x+15		w15 h15, 	?

	;Update calibration for pixel check
	Gui, Add, Button, gupdateOnHideout vUpdateOnHideoutBtn	xs	ys+20				w110, 	OnHideout Color
	Gui, Add, Button, gupdateOnChar vUpdateOnCharBtn	 							w110, 	OnChar Color
	Gui, Add, Button, gupdateOnChat vUpdateOnChatBtn	 							w110, 	OnChat Color
	Gui, Add, Button, gupdateOnDiv vUpdateOnDivBtn	 								w110, 	OnDiv Color

	Gui, Add, Button, gupdateOnHideoutMin vUpdateOnHideoutMinBtn	 x+8 ys+20		w110, 	OnHideoutMin Color
	Gui, Add, Button, gupdateOnInventory vUpdateOnInventoryBtn						w110, 	OnInventory Color
	Gui, Add, Button, gupdateOnStash vUpdateOnStashBtn	 							w110, 	OnStash Color
	Gui, Add, Button, gupdateOnVendor vUpdateOnVendorBtn	 						w110, 	OnVendor Color

	Gui, Font, Bold
	Gui, Add, Text, 						section				xs 	y+10, 				Inventory Calibration:
	Gui, Font
	Gui, Add, Button, gupdateEmptyInvSlotColor vUdateEmptyInvSlotColorBtn xs ys+20 	w100, 	Empty Color
	Gui, Add, Button, gupdateMouseoverColor vUdateMouseoverColorBtn	 	x+8 ys+20	w100, 	Mouseover Color
	Gui, Font, Bold
	Gui, Add, Text, 				section						xs 	y+10, 				AutoDetonate Calibration:
	Gui, Font
	Gui, Add, Button, gupdateDetonate vUpdateDetonateBtn xs ys+20					w100, 	Detonate Color
	Gui, Add, Button, gupdateDetonateDelve vUpdateDetonateDelveBtn	 x+8 ys+20		w100, 	Detonate in Delve

	Gui, Font, Bold
	Gui Add, Text, 										xs 	y+10, 				Additional Interface Options:
	Gui, Font, 

	Gui Add, Checkbox, gUpdateExtra	vShowOnStart Checked%ShowOnStart%                         	          	, Show GUI on startup?
	Gui Add, Checkbox, gUpdateExtra	vSteam Checked%Steam%                         	          				, Are you using Steam?
	Gui Add, Checkbox, gUpdateExtra	vHighBits Checked%HighBits%                         	          		, Are you running 64 bit?
	Gui Add, Checkbox, gUpdateExtra	vAutoUpdateOff Checked%AutoUpdateOff%                         	        , Turn off Auto-Update?
	Gui Add, Checkbox, gUpdateExtra	vYesPersistantToggle Checked%YesPersistantToggle%                       , Persistant Auto-Toggles?
	Gui Add, DropDownList, gUpdateResolutionScale	vResolutionScale       w80               	    		, Standard|UltraWide
	GuiControl, ChooseString, ResolutionScale, %ResolutionScale%
	Gui Add, Text, 			x+8 y+-18							 							, Aspect Ratio
	Gui, Add, DropDownList, R5 gUpdateExtra vLatency Choose%Latency% w30 x+-149 y+10,  1|2|3
	Gui Add, Text, 										x+10 y+-18							, Adjust Latency

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
	Gui Add, Edit, 			vAlternateGemY 				x+7			 	w34	h17, 	%AlternateGemX%
	Gui Add, Checkbox, 	    vStockPortal Checked%StockPortal%              	x465     	y53	 	            , Stock Portal?
	Gui Add, Checkbox, 	    vStockWisdom Checked%StockWisdom%              	         y+8                , Stock Wisdom?
	Gui Add, Checkbox, 	vAlternateGemOnSecondarySlot Checked%AlternateGemOnSecondarySlot%             y+8                , Weapon Swap?

	Gui Add, Checkbox, 	vDebugMessages Checked%DebugMessages%  gUpdateDebug   	x610 	y5 	    w13 h13	
	Gui Add, Text, 										x573	y5, 				Debug:
	Gui Add, Checkbox, 	vShowPixelGrid Checked%ShowPixelGrid%  gUpdateDebug   	x556 	y5 	w13 h13	
	Gui Add, Text, 							vPGrid	    x507	y5, 		    	Pixel Grid:
	Gui Add, Checkbox, 	vShowItemInfo Checked%ShowItemInfo%  gUpdateDebug  	x490 	y5 	w13 h13	
	Gui Add, Text, 							vParseI	    x435	y5, 		        Parse Item:

	If (DebugMessages=1) {
		varCoordUtilText := "Coord/Debug"
		GuiControl, Show, ShowPixelGrid
		GuiControl, Show, PGrid
		GuiControl, Show, ShowItemInfo
		GuiControl, Show, ParseI
		} 
	Else If (DebugMessages=0) {
		varCoordUtilText := "Coord/Pixel"
		GuiControl, Hide, ShowPixelGrid
		GuiControl, Hide, ShowItemInfo
		GuiControl, Hide, PGrid
		GuiControl, Hide, ParseI
		}

	Gui Add, Checkbox, gUpdateExtra	vDetonateMines Checked%DetonateMines%           x300  y145           	          , Detonate Mines?
	Gui, Font, Bold
	Gui Add, Text, 										x295 	y168, 				Keybinds:
	Gui, Font
	Gui Add, Text, 										x360 	y+10, 				Open this GUI
	Gui Add, Text, 										x360 	y+10, 				Auto-Flask
	Gui Add, Text, 										x360 	y+10, 				Auto-Quit
	Gui Add, Text, 										x360 	y+10, 				Logout
	Gui Add, Text, 										x360 	y+10, 				Auto-QSilver
	;CoordUtilText:="Mouse Coord"
	Gui Add, Text, 					  	vCoordUtilText	x360 	y+10,               "%varCoordUtilText%" 				
	GuiControl, , CoordUtilText, %varCoordUtilText%
	Gui Add, Text, 										x360 	y+10, 				Quick-Portal
	Gui Add, Text, 										x360 	y+10, 				Gem-Swap
	Gui Add, Text, 										x360 	y+10, 				Pop Flasks
	Gui Add, Text, 										x360 	y+10, 				ID/Vend/Stash

	Gui,Add,Edit,			 x295 y188 w60 h19 	    vhotkeyOptions			,%hotkeyOptions%
	hotkeyOptions_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyAutoFlask			,%hotkeyAutoFlask%
	hotkeyAutoFlask_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4  w60 h19 	vhotkeyAutoQuit			,%hotkeyAutoQuit%
	hotkeyAutoQuit_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyLogout	        ,%hotkeyLogout%
	hotkeyLogout_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyAutoQuicksilver	,%hotkeyAutoQuicksilver%
	hotkeyAutoQuicksilver_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyGetMouseCoords	,%hotkeyGetMouseCoords%
	hotkeyGetMouseCoords_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyQuickPortal		,%hotkeyQuickPortal%
	hotkeyQuickPortal_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyGemSwap			,%hotkeyGemSwap%
	hotkeyGemSwap_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyPopFlasks	        ,%hotkeyPopFlasks%
	hotkeyPopFlasks_TT:="Set your own hotkey here"
	Gui,Add,Edit,			 		y+4   w60 h19 	vhotkeyItemSort     ,%hotkeyItemSort%
	hotkeyItemSort_TT:="Set your own hotkey here"

	Gui, Font, Bold
	Gui Add, Text, 										x440 	y168, 				Ingame:
	Gui, Font
	Gui Add, Text, 										x500 	y+10, 				Close UI
	Gui Add, Text, 											 	y+10, 				Inventory
	Gui Add, Text, 											 	y+10, 				W-Swap
	Gui Add, Text, 											 	y+10, 				Item Pickup
	Gui,Add,Edit,			  	x435 y188  w60 h19 	vhotkeyCloseAllUI		,%hotkeyCloseAllUI%
	hotkeyCloseAllUI_TT:="Put your ingame assigned hotkey here"
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyInventory			,%hotkeyInventory%
	hotkeyInventory_TT:="Put your ingame assigned hotkey here"
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyWeaponSwapKey		,%hotkeyWeaponSwapKey%
	hotkeyWeaponSwapKey_TT:="Put your ingame assigned hotkey here"
	Gui,Add,Edit,			  		y+4   w60 h19 	vhotkeyLootScan		,%hotkeyLootScan%
	hotkeyLootScan_TT:="Put your ingame assigned hotkey here"
	Gui Add, Checkbox, gUpdateExtra	vLootVacuum Checked%LootVacuum%                         	         y+8 , Loot Vacuum?
	Gui Add, Checkbox, gUpdateExtra	vPopFlaskRespectCD Checked%PopFlaskRespectCD%                         	     y+8 , Pop Flasks Respect CD?

	;~ =========================================================================================== Subgroup: Hints
	Gui,Font,Bold
	Gui,Add,GroupBox,Section xs	x450 y330  w120 h89							,Hotkey Modifiers
	Gui, Add, Button,  		gLaunchHelp 		x558 y330 w18 h18 , 	?
	Gui,Font,Norm
	Gui,Font,s8,Arial
	Gui,Add,Text,	 		 	x465 y350					,!%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%ALT
	Gui,Add,Text,	 		   		y+9					,^%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%CTRL
	Gui,Add,Text,	 		   		y+9					,+%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%SHIFT

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y430	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	;#######################################################################################################Inventory Tab
	Gui, Tab, Inventory
	Gui, Font, Bold
	Gui Add, Text, 										x12 	y30, 				Stash Management
	Gui, Font,
	Gui, Add, DropDownList, gUpdateStash vStashTabCurrency Choose%StashTabCurrency% x10 y50 w40  ,   1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabOil Choose%StashTabOil% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabMap Choose%StashTabMap% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabFragment Choose%StashTabFragment% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabDivination Choose%StashTabDivination% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabCollection Choose%StashTabCollection% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabEssence Choose%StashTabEssence% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabProphecy Choose%StashTabProphecy% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCurrency Checked%StashTabYesCurrency%  x+5 y55, Currency Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesOil Checked%StashTabYesOil% y+14, Oil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesMap Checked%StashTabYesMap% y+14, Map Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFragment Checked%StashTabYesFragment% y+14, Fragment Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesDivination Checked%StashTabYesDivination% y+14, Divination Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCollection Checked%StashTabYesCollection% y+14, Collection Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesEssence Checked%StashTabYesEssence% y+14, Essence Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesProphecy Checked%StashTabYesProphecy% y+14, Prophecy Tab

	Gui, Add, DropDownList, gUpdateStash vStashTabGem Choose%StashTabGem% x150 y50 w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabGemQuality Choose%StashTabGemQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabFlaskQuality Choose%StashTabFlaskQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabLinked Choose%StashTabLinked% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabUniqueDump Choose%StashTabUniqueDump% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabUniqueRing Choose%StashTabUniqueRing% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabFossil Choose%StashTabFossil% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, gUpdateStash vStashTabResonator Choose%StashTabResonator% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGem Checked%StashTabYesGem% x195 y55, Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGemQuality Checked%StashTabYesGemQuality% y+14, Quality Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFlaskQuality Checked%StashTabYesFlaskQuality% y+14, Quality Flask Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesLinked Checked%StashTabYesLinked% y+14, Linked Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% y+14, Unique Dump Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% y+14, Unique Ring Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFossil Checked%StashTabYesFossil% y+14, Fossil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesResonator Checked%StashTabYesResonator% y+14, Resonator Tab


	Gui Add, Checkbox, x+95 ym+30	vYesStashKeys Checked%YesStashKeys%                         	         , Enable stash hotkeys?
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section xp-5 yp+20 w60 h85											,Modifier
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, Edit, xs+4 ys+20 w50 h23 vstashPrefix1, %stashPrefix1%
	Gui Add, Edit, y+8        w50 h23 vstashPrefix2, %stashPrefix2%
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
	Gui,Font,s9 cBlack Bold Underline
	Gui,Add,GroupBox,Section x+10 ys w50 h275											,Tab
	Gui,Font,
	Gui,Font,s9,Arial
	Gui Add, DropDownList, xs+4 ys+20 w40 vstashSuffixTab1 Choose%stashSuffixTab1%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab2 Choose%stashSuffixTab2%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab3 Choose%stashSuffixTab3%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab4 Choose%stashSuffixTab4%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab5 Choose%stashSuffixTab5%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab6 Choose%stashSuffixTab6%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab7 Choose%stashSuffixTab7%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab8 Choose%stashSuffixTab8%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui Add, DropDownList,  y+5       w40 vstashSuffixTab9 Choose%stashSuffixTab9%, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25


	Gui, Add, Button, gLaunchLootFilter xm y290, Custom Loot Filter
	Gui, Font, Bold
	Gui Add, Text, 										xm 	y330, 				ID/Vend/Stash Options:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesIdentify Checked%YesIdentify%                         	          , Identify Items?
	Gui Add, Checkbox, gUpdateExtra	vYesStash Checked%YesStash%                         	        	  , Deposit at stash?
	Gui Add, Checkbox, gUpdateExtra	vYesVendor Checked%YesVendor%                         	              , Sell at vendor?
	Gui Add, Checkbox, gUpdateExtra	vYesDiv Checked%YesDiv%                         	              	  , Trade Divination?
	Gui Add, Checkbox, gUpdateExtra	vYesMapUnid Checked%YesMapUnid%                         	          , Leave Map Un-ID?

	Gui, Font, Bold
	Gui Add, Text, 										xm+170 	y330, 				Inventory Instructions:
	Gui, Font,
	Gui Add, Text, 										 	y+5, 				Use the dropdown list to choose which stash tab the item type will be sent.
	Gui Add, Text, 										 	y+5, 				The checkbox is to enable or disable that type of item being stashed.
	Gui Add, Text, 										 	y+5, 				The options to the right affect which portion of the script is enabled.

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y430	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki
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
	Gui, Add, Button, default gupdateEverything 	 x295 y430	w180 h23, 	Save Configuration
	Gui, Add, Button,  		gloadSaved 		x+5			 		h23, 	Load
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	;#######################################################################################################Chat Tab
	Gui, Tab, Chat
	Gui Add, Checkbox, gUpdateExtra	vEnableChatHotkeys Checked%EnableChatHotkeys%     xm ym+20                    	          	, Enable chat Hotkeys?

	;Save Setting
	Gui, Add, Button, default gupdateEverything 	 x295 y430	w180 h23, 	Save Configuration
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
	DefaultCommands := [ "/Hideout","/menagerie","/cls","/ladder","/reset_xp","/invite RecipientName","/kick RecipientName","@RecipientName Thanks for the trade!","@RecipientName Still Interested?","/kick CharacterName"]
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

	Gui, +LastFound
	If (ShowOnStart)
		Gui, Show, NoActivate Autosize Center, 	WingmanReloaded
	Menu, Tray, Tip, 				WingmanReloaded Dev Ver%VersionNumber%
	Menu, Tray, NoStandard
	Menu, Tray, Add, 				WingmanReloaded, optionsCommand
	Menu, Tray, Default, 			WingmanReloaded
	Menu, Tray, Add, 				Project Wiki, LaunchWiki
	Menu, Tray, Add, 				Support the Project, LaunchDonate
	Menu, Tray, Add
	Menu, Tray, Standard
	;Gui, Hide
	OnMessage(0x200, "WM_MOUSEMOVE")
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

;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  END of Wingman Gui Settings
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
		
		global vX_OnHideout:=1178
		global vY_OnHideout:=930
		global vY_OnHideoutMin:=1053
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
		global vY_Life90:=1034
		global vY_Life80:=1014
		global vY_Life70:=994
		global vY_Life60:=974
		global vY_Life50:=954
		global vY_Life40:=934
		global vY_Life30:=914
		global vY_Life20:=894
			
		global vX_ES:=180
		global vY_ES90:=1034
		global vY_ES80:=1014
		global vY_ES70:=994
		global vY_ES60:=974
		global vY_ES50:=954
		global vY_ES40:=934
		global vY_ES30:=914
		global vY_ES20:=894
		
		global vX_Mana:=1825
		global vY_Mana10:=1054
	
		Global vY_DivTrade:=736
		Global vY_DivItem:=605

		global vX_StashTabMenu := 640
		global vY_StashTabMenu := 146
		global vX_StashTabList := 706
		global vY_StashTabList := 120
		global vY_StashTabSize := 22
		}

; Ingame Overlay (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

; Check for window to open
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SetTimer, PoEWindowCheck, 5000
; Check for Flask presses
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SetTimer, TimerPassthrough, 25
; Detonate mines timer check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	If (DetonateMines&&!Detonated)
		SetTimer, TMineTick, 100
	Else If (!DetonateMines)
		SetTimer, TMineTick, off


;Reload Script with Alt+Escape
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	!Escape::
		Reload
		Return

;Exit Script with Win+Escape
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	#Escape::
		ExitApp
		Return

; --------------------------------------------Function Section-----------------------------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Loot Scanner for items under cursor pressing Loot button
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LootScan(){
	LootScanCommand:
		Pressed := GetKeyState(hotkeyLootScan)
		While (Pressed&&LootVacuum)
		{
			For k, ColorHex in LootColors
			{
				Pressed := GetKeyState(hotkeyLootScan)
				Sleep, -1
				MouseGetPos CenterX, CenterY
				ScanX1:=(CenterX-AreaScale)
				ScanY1:=(CenterY-AreaScale)
				ScanX2:=(CenterX+AreaScale)
				ScanY2:=(CenterY+AreaScale)
				PixelSearch, ScanPx, ScanPy, ScanX1, ScanY1, ScanX2, ScanY2, ColorHex, 0, Fast RGB
				If (ErrorLevel = 0){
					Pressed := GetKeyState(hotkeyLootScan)
					If !(Pressed)
						Break
					Sleep, -1
					SwiftClick(ScanPx, ScanPy)
					}
				Else If (ErrorLevel = 1)
					Continue
			}
		}
	Return
	}

; Sort inventory and determine action
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ItemSort(){
	ItemSortCommand:
		Thread, NoTimers, true		;Critical
		CurrentTab:=0
		MouseGetPos xx, yy
		IfWinActive, ahk_group POEGameGroup
		{
			If (!OnChar) { ;Need to be on Character 
				MsgBox %  "You do not appear to be in game."
				Return
			}
			Else If (!OnInventory&&OnChar){ ;Need to be on Character and have Inventory Open
				Send {%hotkeyInventory%}
				Return
			}
			If RunningToggle  ; This means an underlying thread is already running the loop below.
			{
				RunningToggle := False  ; Signal that thread's loop to stop.
				return  ; End this thread so that the one underneath will resume and see the change made by the line above.
			}
			RunningToggle := True
			GuiStatus()
			

			For C, GridX in InventoryGridX
			{
				If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
					Break
				For R, GridY in InventoryGridY
				{
					If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
						Break
					Grid := RandClick(GridX, GridY)
					If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
					{   
						;Unmark the below lines to check if it is going into scroll area during run
						;MsgBox, Hit Scroll
						;Return
						Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
					} 
					pixelgetcolor, PointColor, GridX, GridY
					
					If (indexOf(PointColor, varEmptyInvSlotColor)) || (indexOf(PointColor, varMouseoverColor)) {
						;Seems to be an empty slot or item already moused over, do not need to clip item info
						Continue
					}
					
					ClipItem(Grid.X,Grid.Y)
					If (OnDiv && YesDiv) 
					{
						If (Prop.RarityDivination && (Stats.Stack = Stats.StackMax)){
							CtrlClick(Grid.X,Grid.Y)
							RandomSleep(150,200)
							SwiftClick(vX_OnDiv,vY_DivTrade)
							CtrlClick(vX_OnDiv,vY_DivItem)
						}
						Continue
					}
					If (!Prop.Identified&&YesIdentify)
					{
						If (Prop.IsMap&&!YesMapUnid)
						{
							WisdomScroll(Grid.X,Grid.Y)
						}
						Else If (Prop.Chromatic && (Prop.RarityRare || Prop.RarityUnique ) ) 
						{
							WisdomScroll(Grid.X,Grid.Y)
						}
						Else If ( Prop.Jeweler && ( Prop.5Link || Prop.6Link || Prop.RarityRare || Prop.RarityUnique) )
						{
							WisdomScroll(Grid.X,Grid.Y)
						}
						Else If (!Prop.Chromatic && !Prop.Jeweler&&!Prop.IsMap)
						{
							WisdomScroll(Grid.X,Grid.Y)
						}
					}
					If (OnStash&&YesStash) 
					{
						If (sendstash:=MatchLootFilter())
						{
							MoveStash(sendstash)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.RarityCurrency&&Prop.SpecialType=""&&StashTabYesCurrency)
						{
							MoveStash(StashTabCurrency)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.IsMap&&StashTabYesMap)
						{
							MoveStash(StashTabMap)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.BreachSplinter&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.SacrificeFragment&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.MortalFragment&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.GuardianFragment&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.ProphecyFragment&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Offering&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Vessel&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Scarab&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.TimelessSplinter&&StashTabYesFragment)
						{
							MoveStash(StashTabFragment)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.RarityDivination&&StashTabYesDivination)
						{
							MoveStash(StashTabDivination)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.RarityUnique&&Prop.Ring)
						{
							If (StashTabYesCollection)
							{
								MoveStash(StashTabCollection)
								RandomSleep(30,45)
								CtrlClick(Grid.X,Grid.Y)
								If (StashTabYesUniqueRing)
								{
									pixelgetcolor, Pitem, GridX, GridY
									if (Pitem!=MOColor)
										Continue
									Sleep, 60*Latency
								}
							}
							If (StashTabYesUniqueRing)
							{
								MoveStash(StashTabUniqueRing)
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
								If (StashTabYesUniqueDump)
								{
									Sleep, 15*Latency
									pixelgetcolor, Pitem, GridX, GridY
									if (Pitem!=MOColor) 
										Continue
									Sleep, 45*Latency
								}
							}
							If (StashTabYesUniqueDump)
							{
								MoveStash(StashTabUniqueDump)
								CtrlClick(Grid.X,Grid.Y)
							}
							Continue
						}
						If (Prop.Essence&&StashTabYesEssence)
						{
							MoveStash(StashTabEssence)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Fossil&&StashTabYesFossil)
						{
							MoveStash(StashTabFossil)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Resonator&&StashTabYesResonator)
						{
							MoveStash(StashTabResonator)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Flask&&(Stats.Quality>0)&&StashTabYesFlaskQuality)
						{
							MoveStash(StashTabFlaskQuality)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.RarityGem)
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
						If ((Prop.5Link||Prop.6Link)&&StashTabYesLinked)
						{
							MoveStash(StashTabLinked)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Prophecy&&StashTabYesProphecy)
						{
							MoveStash(StashTabProphecy)
							CtrlClick(Grid.X,Grid.Y)
							Continue
						}
						If (Prop.Oil&&StashTabYesOil)
						{
							MoveStash(StashTabOil)
							CtrlClick(Grid.X,Grid.Y)
							Continue
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
						If ( Prop.SpecialType="" )
						{
							Sleep, 30*Latency
							CtrlClick(Grid.X,Grid.Y)
							Sleep, 10*Latency
							Continue
						}
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
			If (OnStash && RunningToggle && YesStash && (StockPortal||StockWisdom))
			{
				StockScrolls()
			}
		}
		RunningToggle := False  ; Reset in preparation for the next press of this hotkey.
		CurrentTab:=0
		MouseMove, xx, yy, 0
	Return
	}

; Input any digit and it will move to that Stash tab, only tested up to 25 tabs
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MoveStash(Tab){
	GuiStatus("OnStash")
	If (!OnStash)
		Return
	If (CurrentTab=Tab)
		return
	If (CurrentTab!=Tab) {
		MouseGetPos MSx, MSy
		BlockInput, MouseMove
		Sleep, 45*Latency
		MouseMove, vX_StashTabMenu, vY_StashTabMenu, 0
		Sleep, 45*Latency
		Click, Down, Left, 1
		Sleep, 45*Latency
		Click, Up, Left, 1
		Sleep, 45*Latency
		MouseMove, vX_StashTabList, (vY_StashTabList + (Tab*vY_StashTabSize)), 0
		Sleep, 60*Latency
		send {Enter}
		Sleep, 145*Latency
		MouseMove, vX_StashTabMenu, vY_StashTabMenu, 0
		Sleep, 45*Latency
		Click, Down, Left, 1
		Sleep, 45*Latency
		Click, Up, Left, 1
		Sleep, 45*Latency
		CurrentTab:=Tab
		MouseMove, MSx, MSy, 0
		Sleep, 45*Latency
		BlockInput, MouseMoveOff
		}
	return
	}

; Swift Click at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SwiftClick(x, y){
		MouseMove, x, y	
		Sleep, 15*Latency
		Send {Click, Down x, y }
		Sleep, 45*Latency
		Send {Click, Up x, y }
		Sleep, 15*Latency
	return
	}

; Right Click at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RightClick(x, y){
		BlockInput, MouseMove
		MouseMove, x, y
		Sleep, 15*Latency
		Send {Click, Down x, y, Right}
		Sleep, 45*Latency
		Send {Click, Up x, y, Right}
		Sleep, 15*Latency
		BlockInput, MouseMoveOff
	return
	}

; Shift Click +Click at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ShiftClick(x, y){
		BlockInput, MouseMove
		MouseMove, x, y
		Sleep, 15*Latency
		Send {Shift Down}
			Sleep, 30*Latency
		Send {Click, Down, x, y}
		Sleep, 45*Latency
		Send {Click, Up, x, y}
		Sleep, 15*Latency
		Send {Shift Up}
			Sleep, 15*Latency
		BlockInput, MouseMoveOff
	return
	}

; Ctrl Click ^Click at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CtrlClick(x, y){
		BlockInput, MouseMove
		MouseMove, x, y
		Sleep, 15*Latency
		Send {Ctrl Down}
		Sleep, 30*Latency
		Send {Click, Down, x, y}
		Sleep, 45*Latency
		Send {Click, Up, x, y}
		;Send ^{Click, Up, x, y}
		Sleep, 15*Latency
		Send {Ctrl Up}
		Sleep, 15*Latency
		BlockInput, MouseMoveOff
	return
	}

; Identify Item at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WisdomScroll(x, y){
		BlockInput, MouseMove
		Sleep, 30*Latency
		MouseMove %WisdomScrollX%, %WisdomScrollY%
		Sleep, 30*Latency
		Click, Down, Right, 1
		Sleep, 45*Latency
		Click, Up, Right, 1
		Sleep, 15*Latency
		MouseMove %x%, %y%
		Sleep, 30*Latency
		Click, Down, Left, 1
		Sleep, 45*Latency
		Click, Up, Left, 1
		Sleep, 30*Latency
		BlockInput, MouseMoveOff
	return
	}

; Restock scrolls that have more than 10 missing
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
StockScrolls(){
		BlockInput, MouseMove
		If StockWisdom{
			MouseMove %WisdomScrollX%, %WisdomScrollY%
			ClipItem(WisdomScrollX, WisdomScrollY)
			Sleep, 20*Latency
			dif := (40 - Stats.Stack)
				If (dif>10)
			{
				MoveStash(1)
				MouseMove WisdomStockX, WPStockY
				Sleep, 15*Latency
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
			Sleep, 20*Latency
			dif := (40 - Stats.Stack)
				If (dif>10)
			{
				MoveStash(1)
				MouseMove PortalStockX, WPStockY
				Sleep, 15*Latency
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

; Randomize Click area around middle of cell using Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RandClick(x, y){
		Random, Rx, x+10, x+40
		Random, Ry, y-40, y-10
	return {"X": Rx, "Y": Ry}
	}

; Scales two resolution quardinates -- Currently not being used
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ScaleRes(x, y){
		Rx:=Round(A_ScreenWidth / (1920 / x))
		Ry:=Round(A_ScreenHeight / (1080 / y))
	return {"X": Rx, "Y": Ry}
	}

; Rescales values for specialty resolutions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Rescale(){
		IfWinExist, ahk_group POEGameGroup 
		{
			WinGetPos, X, Y, W, H
			If (ResolutionScale="Standard") {
				; Item Inventory Grid
				Global InventoryGridX := [ Round(A_ScreenWidth/(1920/1274)), Round(A_ScreenWidth/(1920/1326)), Round(A_ScreenWidth/(1920/1379)), Round(A_ScreenWidth/(1920/1432)), Round(A_ScreenWidth/(1920/1484)), Round(A_ScreenWidth/(1920/1537)), Round(A_ScreenWidth/(1920/1590)), Round(A_ScreenWidth/(1920/1642)), Round(A_ScreenWidth/(1920/1695)), Round(A_ScreenWidth/(1920/1748)), Round(A_ScreenWidth/(1920/1800)), Round(A_ScreenWidth/(1920/1853)) ]
				Global InventoryGridY := [ Round(A_ScreenHeight/(1080/638)), Round(A_ScreenHeight/(1080/690)), Round(A_ScreenHeight/(1080/743)), Round(A_ScreenHeight/(1080/796)), Round(A_ScreenHeight/(1080/848)) ]  
				;Detonate Mines
				Global DetonateDelveX:=X + Round(A_ScreenWidth/(1920/1542))
				Global DetonateX:=X + Round(A_ScreenWidth/(1920/1658))
				Global DetonateY:=Y + Round(A_ScreenHeight/(1080/901))
				;Scrolls in currency tab
				Global WisdomStockX:=X + Round(A_ScreenWidth/(1920/125))
				Global PortalStockX:=X + Round(A_ScreenWidth/(1920/175))
				Global WPStockY:=Y + Round(A_ScreenHeight/(1080/262))
				;Status Check OnHideout
				global vX_OnHideout:=X + Round(A_ScreenWidth / (1920 / 1178))
				global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 930))
				global vY_OnHideoutMin:=Y + Round(A_ScreenHeight / (1080 / 1053))
				;Status Check OnChar
				global vX_OnChar:=X + Round(A_ScreenWidth / (1920 / 41))
				global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1080 / 915))
				;Status Check OnChat
				global vX_OnChat:=X + Round(A_ScreenWidth / (1920 / 0))
				global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1080 / 653))
				;Status Check OnInventory
				global vX_OnInventory:=X + Round(A_ScreenWidth / (1920 / 1583))
				global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
				;Status Check OnStash
				global vX_OnStash:=X + Round(A_ScreenWidth / (1920 / 336))
				global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
				;Status Check OnVendor
				global vX_OnVendor:=X + Round(A_ScreenWidth / (1920 / 618))
				global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1080 / 88))
				;Status Check OnDiv
				global vX_OnDiv:=X + Round(A_ScreenWidth / (1920 / 618))
				global vY_OnDiv:=Y + Round(A_ScreenHeight / ( 1080 / 135))
				;Life %'s
				global vX_Life:=X + Round(A_ScreenWidth / (1920 / 95))
					global vY_Life20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_Life30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_Life40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_Life50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_Life60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_Life70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_Life80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_Life90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;ES %'s
				global vX_ES:=X + Round(A_ScreenWidth / (1920 / 180))
				global vY_ES20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
				global vY_ES30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
				global vY_ES40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
				global vY_ES50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
				global vY_ES60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
				global vY_ES70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
				global vY_ES80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
				global vY_ES90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
				;Mana
				global vX_Mana:=X + Round(A_ScreenWidth / (1920 / 1825))
				global vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
				;GUI overlay
				global GuiX:=X + Round(A_ScreenWidth / (1920 / -10))
				global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
				;Divination Y locations
				Global vY_DivTrade:=Y + Round(A_ScreenHeight / (1080 / 736))
				Global vY_DivItem:=Y + Round(A_ScreenHeight / (1080 / 605))
				;Stash tabs menu button
				global vX_StashTabMenu := X + Round(A_ScreenWidth / (1920 / 640))
				global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
				;Stash tabs menu list
				global vX_StashTabList := X + Round(A_ScreenWidth / (1920 / 706))
				global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1080 / 120))
				;calculate the height of each tab
				global vY_StashTabSize := Round(A_ScreenHeight / ( 1080 / 22))
			}
			Else If (ResolutionScale="UltraWide") {
				; Item Inventory Grid
				Global InventoryGridX := [ Round(A_ScreenWidth/(3840/3193)), Round(A_ScreenWidth/(3840/3246)), Round(A_ScreenWidth/(3840/3299)), Round(A_ScreenWidth/(3840/3352)), Round(A_ScreenWidth/(3840/3404)), Round(A_ScreenWidth/(3840/3457)), Round(A_ScreenWidth/(3840/3510)), Round(A_ScreenWidth/(3840/3562)), Round(A_ScreenWidth/(3840/3615)), Round(A_ScreenWidth/(3840/3668)), Round(A_ScreenWidth/(3840/3720)), Round(A_ScreenWidth/(3840/3773)) ]
				Global InventoryGridY := [ Round(A_ScreenHeight/(1080/638)), Round(A_ScreenHeight/(1080/690)), Round(A_ScreenHeight/(1080/743)), Round(A_ScreenHeight/(1080/796)), Round(A_ScreenHeight/(1080/848)) ]  
				;Detonate Mines
				Global DetonateDelveX:=X + Round(A_ScreenWidth/(3840/3462))
				Global DetonateX:=X + Round(A_ScreenWidth/(3840/3578))
				Global DetonateY:=Y + Round(A_ScreenHeight/(1080/901))
				;Scrolls in currency tab
				Global WisdomStockX:=X + Round(A_ScreenWidth/(3840/125))
				Global PortalStockX:=X + Round(A_ScreenWidth/(3840/175))
				Global WPStockY:=Y + Round(A_ScreenHeight/(1080/262))
				;Status Check OnHideout
				global vX_OnHideout:=X + Round(A_ScreenWidth / (3840 / 3098))
				global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 930))
				global vY_OnHideoutMin:=Y + Round(A_ScreenHeight / (1080 / 1053))
				;Status Check OnChar
				global vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
				global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1080 / 915))
				;Status Check OnChat
				global vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
				global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1080 / 653))
				;Status Check OnInventory
				global vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
				global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
				;Status Check OnStash
				global vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
				global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
				;Status Check OnVendor
				global vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
				global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1080 / 88))
				;Status Check OnDiv
				global vX_OnDiv:=X + Round(A_ScreenWidth / (3840 / 1578))
				global vY_OnDiv:=Y + Round(A_ScreenHeight / ( 1080 / 135))
				;Life %'s
				global vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
					global vY_Life20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_Life30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_Life40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_Life50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_Life60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_Life70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_Life80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_Life90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;ES %'s
				global vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
				global vY_ES20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
				global vY_ES30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
				global vY_ES40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
				global vY_ES50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
				global vY_ES60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
				global vY_ES70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
				global vY_ES80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
				global vY_ES90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
				;Mana
				global vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
				global vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
				;GUI overlay
				global GuiX:=X + Round(A_ScreenWidth / (3840 / -10))
				global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
				;Divination Y locations
				Global vY_DivTrade:=Y + Round(A_ScreenHeight / (1080 / 736))
				Global vY_DivItem:=Y + Round(A_ScreenHeight / (1080 / 605))
				;Stash tabs menu button
				global vX_StashTabMenu := X + Round(A_ScreenWidth / (3840 / 640))
				global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
				;Stash tabs menu list
				global vX_StashTabList := X + Round(A_ScreenWidth / (3840 / 706))
				global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1080 / 120))
				;calculate the height of each tab
				global vY_StashTabSize := Round(A_ScreenHeight / ( 1080 / 22))
			} 
			RescaleRan := True
		}
	return
	}

; Toggle Auto-Quit
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

; Toggle Auto-Pot
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

; Load Previous Toggle States
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

; Tooltip Management
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WM_MOUSEMOVE(){
		static CurrControl, PrevControl, _TT
		CurrControl := A_GuiControl
		If (CurrControl <> PrevControl and not InStr(CurrControl, " ")){
			SetTimer, DisplayToolTip, -300 	; shorter wait, shows the tooltip quicker
			PrevControl := CurrControl
		}
	return

	DisplayToolTip:
		try
		ToolTip % %CurrControl%_TT
		catch
		ToolTip
		SetTimer, RemoveToolTip, -2000
	return
	return
	}

; Provides a call for simpler random sleep timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RandomSleep(min,max){
		Random, r, min, max
		r:=floor(r/Speed)
		Sleep, r*Latency
	return
	}

;Gem Swap
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
		
		SwiftClick(AlternateGemX, AlternateGemY)
			RandomSleep(90,120)
		
		if (WeaponSwap==1) 
			Send {%hotkeyWeaponSwapKey%} 
		RandomSleep(90,120)
		
		SwiftClick(CurrentGemX, CurrentGemY)
			RandomSleep(90,120)
		
		Send {%hotkeyInventory%} 
		MouseMove, xx, yy, 0
		BlockInput, MouseMoveOff
	return
	}

;Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
QuickPortal(){
	QuickPortalCommand:
		Thread, NoTimers, true		;Critical
		Keywait, Alt
		BlockInput On
		MouseGetPos xx, yy
		RandomSleep(53,87)
		
		Send {%hotkeyCloseAllUI%} 
		RandomSleep(53,68)
		
		Send {%hotkeyInventory%}
		RandomSleep(56,68)
		
		MouseMove, PortalScrollX, PortalScrollY, 0
		RandomSleep(56,68)
		
		Click Right
		RandomSleep(56,68)
		
		Send {%hotkeyInventory%}
		MouseMove, xx, yy, 0
		BlockInput Off
	return
	}

;Pop all flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PopFlasks(){
	PopFlasksCommand:
		Thread, NoTimers, true		;Critical
		If PopFlaskRespectCD
			TriggerFlask(11111)
		Else {
			Send 1
			OnCooldown[1]:=1 
			SendMSG(3, 1, scriptGottaGoFast)
			Cooldown:=CooldownFlask1
			settimer, TimmerFlask1, %Cooldown%
			RandomSleep(-99,99)
			Send 4
			OnCooldown[4]:=1 
			Cooldown:=CooldownFlask4
			SendMSG(3, 4, scriptGottaGoFast)
			settimer, TimmerFlask4, %Cooldown%
			RandomSleep(-99,99)
			Send 3
			OnCooldown[3]:=1 
			SendMSG(3, 3, scriptGottaGoFast)
			Cooldown:=CooldownFlask3
			settimer, TimmerFlask3, %Cooldown%
			RandomSleep(-99,99)
			Send 2
			OnCooldown[2]:=1 
			SendMSG(3, 2, scriptGottaGoFast)
			Cooldown:=CooldownFlask2
			settimer, TimmerFlask2, %Cooldown%
			RandomSleep(-99,99)
			Send 5
			OnCooldown[5]:=1 
			SendMSG(3, 5, scriptGottaGoFast)
			Cooldown:=CooldownFlask5
			settimer, TimmerFlask5, %Cooldown%
		}
	return
	}

; Decide which logout method to use
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LogoutCommand(){
	LogoutCommand:
		Thread, NoTimers, true		;Critical
		if (CritQuit=1) {
			global executable, backupExe
			succ := logout(executable)
			if (succ == 0) && backupExe != "" {
				newSucc := logout(backupExe)
				error("ED12",executable,backupExe)
				if (newSucc == 0) {
					error("ED13")
				}
			}
		} 
		Else 
			Send {Enter} /exit {Enter}
	return
	}

; Main function of the LutBot logout method
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
logout(executable){
		global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi
		Thread, NoTimers, true		;Critical
		start := A_TickCount
		
		poePID := Object()
		s := 4096
		Process, Exist 
		h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
		
		DllCall(OpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", t)
		VarSetCapacity(ti, 16, 0)
		NumPut(1, ti, 0, "UInt")
		
		DllCall(LookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
		NumPut(luid, ti, 4, "Int64")
		NumPut(2, ti, 12, "UInt")
		
		r := DllCall(AdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
		DllCall("CloseHandle", "Ptr", t)
		DllCall("CloseHandle", "Ptr", h)
		
		try
		{
			s := VarSetCapacity(a, s)
			c := 0
			DllCall(EnumProcesses, "Ptr", &a, "UInt", s, "UIntP", r)
			Loop, % r // 4
			{
				id := NumGet(a, A_Index * 4, "UInt")
				
				h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
				
				if !h
					continue
				VarSetCapacity(n, s, 0)
				e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
				if !e 
					if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
					SplitPath n, n
				DllCall("CloseHandle", "Ptr", h)
				if (n && e)
				if (n == executable) {
					poePID.Insert(id)
				}
			}
			
			l := poePID.Length()
			if ( l = 0 ) {
				Process, wait, %executable%, 0.2
				if ( ErrorLevel > 0 ) {
					poePID.Insert(ErrorLevel)
				}
			}
			
			VarSetCapacity(dwSize, 4, 0) 
			result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
			VarSetCapacity(TcpTable, NumGet(dwSize), 0) 
			
			result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
			
			num := NumGet(&TcpTable,0,"UInt")
			
			IfEqual, num, 0
			{
				error("ED11",num,l,executable)
				return False
			}
			
			out := 0
			Loop %num%
			{
				cutby := a_index - 1
				cutby *= 24
				ownerPID := NumGet(&TcpTable,cutby+24,"UInt")
				for index, element in poePID {
					if ( ownerPID = element )
					{
						VarSetCapacity(newEntry, 20, 0) 
						NumPut(12,&newEntry,0,"UInt")
						NumPut(NumGet(&TcpTable,cutby+8,"UInt"),&newEntry,4,"UInt")
						NumPut(NumGet(&TcpTable,cutby+12,"UInt"),&newEntry,8,"UInt")
						NumPut(NumGet(&TcpTable,cutby+16,"UInt"),&newEntry,12,"UInt")
						NumPut(NumGet(&TcpTable,cutby+20,"UInt"),&newEntry,16,"UInt")
						result := DllCall(SetEntry, UInt, &newEntry)
						IfNotEqual, result, 0
						{
							error("TCP" . result,out,result,l,executable)
							return False
						}
						out++
					}
				}
			}
			if ( out = 0 ) {
				error("ED10",out,l,executable)
				return False
			} else {
				error(l . ":" . A_TickCount - start,out,l,executable)
			}
		} 
		catch e
		{
			error("ED14","catcherror",e)
			return False
		}
		
	return True
	}

; Check for backup executable
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
checkActiveType() {
		global executable, backupExe
		Process, Exist, %executable%
		if !ErrorLevel
		{
			WinGet, id, list,ahk_group POEGameGroup,, Program Manager
			Loop, %id%
			{
				this_id := id%A_Index%
				WinGet, this_name, ProcessName, ahk_id %this_id%
				backupExe := this_name
				found .= ", " . this_name
			}
		}
	return
	}

; Error capture from LutLogout to error.txt
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
error(var,var2:="",var3:="",var4:="",var5:="",var6:="",var7:="") {
	GuiControl,1:, guiErr, %var%
	print := A_Now . "," . var . "," . var2 . "," . var3 . "," . var4 . "," . var5 . "," . var6 . "," . var7 . "`n"
	FileAppend, %print%, error.txt, UTF-16
	return
	}

; Capture Clip at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ClipItem(x, y){
		BlockInput, MouseMove
		Clipboard := ""
		MouseMove %x%, %y%
		Sleep, 75*Latency
		Send ^c
		ClipWait, 0
		ParseClip()
		BlockInput, MouseMoveOff
	Return
	}

; Checks the contents of the clipboard and parses the information from the tooltip capture
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ParseClip(){
		;Reset Variables
		NameIsDone := False
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
			, DoubleCorrupted : False
			, Width : 0
			, Height : 0
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
			, PseudoColdResist : 0
			, PseudoFireResist : 0
			, PseudoLightningResist : 0
			, PseudoChaosResist : 0
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
			, Implicit : ""}

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
					NameIsDone := True
				}
				Else
				{
					Prop.ItemName := Prop.ItemName . A_LoopField . "`n" ; Add a line of name

					If ArmourBases.HasKey(A_LoopField){
						Prop.Width := ArmourBases[A_LoopField]["Width"]
						Prop.Height := ArmourBases[A_LoopField]["Height"]
						Stats.ItemClass := ArmourBases[A_LoopField]["Item Class"]
						Continue
					}
					If WeaponBases.HasKey(A_LoopField){
						Prop.Width := WeaponBases[A_LoopField]["Width"]
						Prop.Height := WeaponBases[A_LoopField]["Height"]
						Stats.ItemClass := WeaponBases[A_LoopField]["Item Class"]
						Continue
					}
					If BeltBases.HasKey(A_LoopField){
						Prop.Width := BeltBases[A_LoopField]["Width"]
						Prop.Height := BeltBases[A_LoopField]["Height"]
						Prop.Belt := True
						Stats.ItemClass := BeltBases[A_LoopField]["Item Class"]
						Continue
					}
					IfInString, A_LoopField, Ring
					{
						IfInString, A_LoopField, Ringmail
						{
							Sleep, -1
						}
						Else
						{
						Prop.Ring := True
						Stats.ItemClass := "Rings"
						Continue
						}
					}
					IfInString, A_LoopField, Amulet
					{
						Prop.Amulet := True
						Stats.ItemClass := "Amulets"
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
						If Prop.Amulet
						continue
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
				Stats.RatingEvasion := arr2
				Continue
			}
			IfInString, A_LoopField, Chance to Block:
			{
				StringSplit, arr, A_LoopField, %A_Space%
				Stats.RatingBlock := arr2
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
			;Capture Implicit and Affixes after the Item Level
			If (itemLevelIsDone > 0 && itemLevelIsDone < 4) {
				If A_LoopField = --------
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
						if (indexOf(imp, Enchantment)) {
							Affix.LabEnchant := A_LoopField
							itemLevelIsDone := 1
						Continue
						}
					}
					If (itemLevelIsDone=2 && !Affix.Talisman && captureLines < 1) {
						IfInString, A_LoopField, Talisman Tier:
						{	
							StringSplit, Arr, A_LoopField, %A_Space%
							Affix.TalismanTier := Arr3
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

		Return
	}

; Evaluate Loot Filter Match
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
							If InStr(arrval, min)
							matched := True
							Else
							nomatched := True
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
							If InStr(arrval, min)
							matched := True
							Else
							nomatched := True
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
								if InStr(arrval, v)
									matched := True
							if !matched
								nomatched := True
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
; Grab Reply whisper recipient
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GrabRecipientName(){
	Clipboard := ""
	Send ^{Enter}^{A}^{C}{Escape}
	ClipWait, 0
	Loop, Parse, Clipboard, `n, `r
		{
		; Clipboard must have "@" in the first line
		If A_Index = 1
			{
			IfNotInString, A_LoopField, @
				{
				Exit
				}
			RecipientNameArr := StrSplit(A_LoopField, " ", @)
			RecipientName1 := RecipientNameArr[1]
			RecipientName := StrReplace(RecipientName1, "@")
			}
			Ding( ,%RecipientName%)
		}
	Sleep, 60
	Return
	}

; Debugging information on Mouse Cursor
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CoordAndDebug(){
		CoordAndDebugCommand:
			
			MouseGetPos x, y
			PixelGetColor, xycolor , x, y
			TT := "  Mouse X: " . x . "  Mouse Y: " . y . "  XYColor= " . xycolor 
			
			If DebugMessages{
				TT := TT . "`n`n"
				GuiStatus()
				TT := TT . "In Hideout:  " . OnHideout . "  On Character:  " . OnChar . "  Chat Open:  " . OnChat . "`n"
				TT := TT . "Inventory open:  " . OnInventory . "  Stash Open:  " . OnStash . "  Vendor Open:  " . OnVendor . "`n"
				TT := TT . "  Divination Trade: " . OnDiv . "`n`n"
				ClipItem(x, y)
				If (Prop.IsItem) {
					TT := TT . "Item Properties:`n`n"
					If ShowItemInfo {	
						If (sendstash:=MatchLootFilter())
							TT := TT . "Matches loot filter  -  Send to " . sendstash . "`n`n"
						Else
							TT := TT . "Item does not match Loot Filter`n`n"
						For key, value in Prop
						{
							If (value != 0 && value != "" && value != False)
								TT := TT . key . ":  " . value . "`n"
						}
						MsgBox %TT%
						If (Prop.IsItem) {
							TT := "Item Stats:`n`n"
							If ShowItemInfo {
								For key, value in Stats
								{
									If (value != 0 && value != "" && value != False)
										TT := TT . key . ":  " . value . "`n"
								}
							}
						MsgBox %TT%
						}
						If (Prop.HasAffix) {
							TT := "Item Affix:`n`n"
							If ShowItemInfo {
								For key, value in Affix
								{
									If (value != 0 && value != "" && value != False)
										TT := TT . key . ":  " . value . "`n"
								}
							If !Prop.Identified
							TT .= "Unidentified"
							}
						MsgBox %TT%
						}
					}
				} Else {
					Tooltip, %TT%
					SetTimer, RemoveToolTip, 10000
				}

			} Else {
				Tooltip, %TT%
				SetTimer, RemoveToolTip, 10000
			}
			If (DebugMessages&&ShowPixelGrid){
				
				;Check if inventory is open
				if(!OnInventory){
					TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
				}else{
					
					TT := "Grid information:" . "`n"
					
					For c, GridX in InventoryGridX	{
						For r, GridY in InventoryGridY
						{
							pixelgetcolor, PointColor, GridX, GridY
							
							If (PointColor=UnIdColor){
								TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Un-Identified. Color: " . PointColor  .  "`n"
							}else if (PointColor=IdColor){
								TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Identified. Color: " . PointColor  .  "`n"
							}else if (indexOf(PointColor, varMouseoverColor) > 0){
								TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Selected item. Color: " . PointColor  .  "`n"
							}else if (indexOf(PointColor, varEmptyInvSlotColor) > 0){				
								TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Empty inventory slot. Color: " . PointColor  .  "`n"
							}else{
								TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Possibly occupied slot. Color: " . PointColor  .  "`n"
							}
						}
					}
				}
				MsgBox %TT%	
			}
		Return
	}

; Check if a specific value is part of an array and return the index
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
indexOf(var, Arr, fromIndex:=1) {
		for index, value in Arr {
			if (index < fromIndex){
				Continue
			}else if (value = var){
				return index
			}
		}
	}

; Transform an array to a comma separated string
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
arrToStr(array){
		Str := ""
		For Index, Value In array
			Str .= "," . Value
		Str := LTrim(Str, ",")
		return Str
	}
; Auto Detonate Mines
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DetonateMines(){
		GuiStatus("OnChat")
		If (OnChat)
			exit
		pixelgetcolor, DelveMine, DetonateDelveX, DetonateY
		pixelgetcolor, Mine, DetonateX, DetonateY
		If ((Mine = DetonateHex)||(DelveMine = DetonateHex)){
			Sendraw, d
			Detonated:=1
			Settimer, TDetonated, 500
			Return
		}
		Return	
	}

; Update Overlay ON OFF states
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

; Pixelcheck for different parts of the screen to see what your status is in game. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PoEWindowCheck(){
		IfWinExist, ahk_group POEGameGroup 
		{
			global GuiX, GuiY, RescaleRan, ToggleExist
			If (!RescaleRan)
				Rescale()
			If (!ToggleExist) {
				Gui 2: Show, x%GuiX% y%GuiY%, NoActivate 
				ToggleExist := True
				WinActivate, ahk_group POEGameGroup
				If (YesPersistantToggle)
					AutoReset()
			}
		} Else {
			If (ToggleExist){
				Gui 2: Show, Hide
				ToggleExist := False
			}
		}
		Return
	}
; Receive Messages from other scripts
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
			settimer, TimmerFlask1, %CooldownFlask1%
			return
			}		
		If (lParam=2){
			OnCooldown[2]:=1 
			settimer, TimmerFlask2, %CooldownFlask2%
			return
			}		
		If (lParam=3){
			OnCooldown[3]:=1 
			settimer, TimmerFlask3, %CooldownFlask3%
			return
			}		
		If (lParam=4){
			OnCooldown[4]:=1 
			settimer, TimmerFlask4, %CooldownFlask4%
			return
			}		
		If (lParam=5){
			OnCooldown[5]:=1 
			settimer, TimmerFlask5, %CooldownFlask5%
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
			ItemSort()
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
; Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0, script:=""){
	DetectHiddenWindows On
	if WinExist(script) 
		PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
	else 
		MsgBox %script% . " Not found"
	DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
	Return
	}
; Pixelcheck for different parts of the screen to see what your status is in game. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuiStatus(Fetch:=""){
	If (Fetch="OnHideout")
		{
		pixelgetcolor, POnHideout, vX_OnHideout, vY_OnHideout
		pixelgetcolor, POnHideoutMin, vX_OnHideout, vY_OnHideoutMin
		if ((POnHideout=varOnHideout) || (POnHideoutMin=varOnHideoutMin)) {
			OnHideout:=True
			} Else {
			OnHideout:=False
			}
		Return
		}
	If !(Fetch="")
		{
		pixelgetcolor, P%Fetch%, vX_%Fetch%, vY_%Fetch%
		If (P%Fetch%=var%Fetch%){
			%Fetch%:=True
			} Else {
			%Fetch%:=False
			}
		Return
		}
	pixelgetcolor, POnHideout, vX_OnHideout, vY_OnHideout
	pixelgetcolor, POnHideoutMin, vX_OnHideout, vY_OnHideoutMin
	if ((POnHideout=varOnHideout) || (POnHideoutMin=varOnHideoutMin)) {
		OnHideout:=True
		} Else {
		OnHideout:=False
		}
	pixelgetcolor, POnChar, vX_OnChar, vY_OnChar
	If (POnChar=varOnChar)  {
		OnChar:=True
		} Else {
		OnChar:=False
		}
	pixelgetcolor, POnChat, vX_OnChat, vY_OnChat
	If (POnChat=varOnChat) {
		OnChat:=True
		} Else {
		OnChat:=False
		}
	pixelgetcolor, POnInventory, vX_OnInventory, vY_OnInventory
	If (POnInventory=varOnInventory) {
		OnInventory:=True
		} Else {
		OnInventory:=False
		}
	pixelgetcolor, POnStash, vX_OnStash, vY_OnStash
	If (POnStash=varOnStash) {
		OnStash:=True
		} Else {
		OnStash:=False
		}
	pixelgetcolor, POnVendor, vX_OnVendor, vY_OnVendor
	If (POnVendor=varOnVendor) {
		OnVendor:=True
		} Else {
		OnVendor:=False
		}
	pixelgetcolor, POnDiv, vX_OnDiv, vY_OnDiv
	If (POnDiv=varOnDiv) {
		OnDiv:=True
		} Else {
		OnDiv:=False
		}
	Return
	}

; Main attack Flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MainAttackCommand(){
	MainAttackCommand:
	if (AutoFlask || AutoQuicksilver) {
		GuiStatus()
		If (OnChat||OnHideout||OnVendor||OnStash||!OnChar)
			return
		If AutoFlask {
			TriggerFlask(TriggerMainAttack)
			SetTimer, TimerMainAttack, 400
		}
		If (AutoQuicksilver && QSonMainAttack) {
			If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
				If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
					Return
				SendMSG(5,1,scriptGottaGoFast)
				SetTimer, TimerMainAttack, 400
			}
		}
	}
    Return	
	}
; Secondary attack Flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SecondaryAttackCommand(){
	SecondaryAttackCommand:
	if (AutoFlask || AutoQuicksilver) {
		GuiStatus()
		If (OnChat||OnHideout||OnVendor||OnStash||!OnChar)
			return
		If AutoFlask {
			TriggerFlask(TriggerSecondaryAttack)
			SetTimer, TimerSecondaryAttack, 400
		}
		If (AutoQuicksilver && QSonSecondaryAttack) {
			If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
				If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
					Return
				SendMSG(5,1,scriptGottaGoFast)
				SetTimer, TimerSecondaryAttack, 400
			}
		}
	}
    Return	
	}

; Detonate Mines
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TMineTick(){
    IfWinActive, ahk_group POEGameGroup
    {	
        If (DetonateMines&&!Detonated) 
            DetonateMines()
    }
    Return
	}

; Debug messages within script
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Ding(Timeout:=500,Message:="Ding", Message2:="", Message3:="", Message4:="", Message5:="", Message6:="", Message7:="" ){
	If (!DebugMessages)
		Return
	Else If (DebugMessages){
		debugStr:=Message
		If (Message2!=""){
			debugStr.="`n"
			debugStr.=Message2
			}
		If (Message3!=""){
			debugStr.="`n"
			debugStr.=Message3
			}
		If (Message4!=""){
			debugStr.="`n"
			debugStr.=Message4
			}
		If (Message5!=""){
			debugStr.="`n"
			debugStr.=Message5
			}
		If (Message6!=""){
			debugStr.="`n"
			debugStr.=Message6
			}
		If (Message7!=""){
			debugStr.="`n"
			debugStr.=Message7
			}
		Tooltip, %debugStr%
		}
	SetTimer, RemoveTooltip, %Timeout%
	Return
	}

; Flask Logic
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TGameTick(){
    IfWinActive, ahk_group POEGameGroup
    {
        ; Check what status is your character in the game
        GuiStatus()
        if (OnHideout||!OnChar||OnChat||OnInventory||OnStash||OnVendor) { 
            ;GuiUpdate()																									   
            Exit
        }
        
        if (RadioLife=1)	{
            If ((TriggerLife20!="00000")|| ( AutoQuit && RadioQuit20 ) || ( ((YesUtility1)&&(YesUtility1LifePercent="20")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="20")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="20")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="20")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="20")&&!(OnCooldownUtility5)) ) ) {
				pixelgetcolor, Life20, vX_Life, vY_Life20 
				if (Life20!=varLife20) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit20=1) {
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
            If ((TriggerLife30!="00000")||(AutoQuit&&RadioQuit30)|| ( ((YesUtility1)&&(YesUtility1LifePercent="30")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="30")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="30")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="30")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="30")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life30, vX_Life, vY_Life30 
                if (Life30!=varLife30) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit30=1) {
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
            If ((TriggerLife40!="00000")||(AutoQuit&&RadioQuit40)|| ( ((YesUtility1)&&(YesUtility1LifePercent="40")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="40")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="40")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="40")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="40")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life40, vX_Life, vY_Life40 
                if (Life40!=varLife40) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit40=1) {
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
            If ((TriggerLife50!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="50")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="50")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="50")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="50")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="50")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life50, vX_Life, vY_Life50
                if (Life50!=varLife50) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    Loop, 5 {
                        If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="50")
                            TriggerUtility(A_Index)
                    }
                    If (TriggerLife50!="00000")
                        TriggerFlask(TriggerLife50)
                    }
            }
            If ((TriggerLife60!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="60")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="60")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="60")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="60")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="60")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life60, vX_Life, vY_Life60
                if (Life60!=varLife60) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    Loop, 5 {
                        If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="60")
                            TriggerUtility(A_Index)
                    }
                    If (TriggerLife60!="00000")
                        TriggerFlask(TriggerLife60)
                    }
            }
            If ((TriggerLife70!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="70")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="70")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="70")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="70")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="70")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerLife80!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="80")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="80")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="80")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="80")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="80")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerLife90!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="90")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="90")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="90")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="90")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="90")&&!(OnCooldownUtility5)) ) ) {
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
        
        if (RadioHybrid=1) {
            If ((TriggerLife20!="00000")||(AutoQuit&&RadioQuit20)|| ( ((YesUtility1)&&(YesUtility1LifePercent="20")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="20")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="20")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="20")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="20")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life20, vX_Life, vY_Life20 
                if (Life20!=varLife20) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit20=1) {
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
            If ((TriggerLife30!="00000")||(AutoQuit&&RadioQuit30)|| ( ((YesUtility1)&&(YesUtility1LifePercent="30")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="30")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="30")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="30")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="30")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life30, vX_Life, vY_Life30 
                if (Life30!=varLife30) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit30=1) {
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
            If ((TriggerLife40!="00000")||(AutoQuit&&RadioQuit40)|| ( ((YesUtility1)&&(YesUtility1LifePercent="40")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="40")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="40")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="40")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="40")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life40, vX_Life, vY_Life40 
                if (Life40!=varLife40) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit40=1) {
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
            If ((TriggerLife50!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="50")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="50")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="50")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="50")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="50")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life50, vX_Life, vY_Life50
                if (Life50!=varLife50) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    Loop, 5 {
                        If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="50")
                            TriggerUtility(A_Index)
                    }
                    If (TriggerLife50!="00000")
                        TriggerFlask(TriggerLife50)
                    }
            }
            If ((TriggerLife60!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="60")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="60")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="60")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="60")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="60")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, Life60, vX_Life, vY_Life60
                if (Life60!=varLife60) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    Loop, 5 {
                        If (YesUtility%A_Index%) && (YesUtility%A_Index%LifePercent="60")
                            TriggerUtility(A_Index)
                    }
                    If (TriggerLife60!="00000")
                        TriggerFlask(TriggerLife60)
                    }
            }
            If ((TriggerLife70!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="70")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="70")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="70")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="70")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="70")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerLife80!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="80")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="80")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="80")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="80")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="80")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerLife90!="00000")|| ( ((YesUtility1)&&(YesUtility1LifePercent="90")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2LifePercent="90")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3LifePercent="90")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4LifePercent="90")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5LifePercent="90")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES20!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="20")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="20")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="20")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="20")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="20")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES30!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="30")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="30")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="30")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="30")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="30")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES40!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="40")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="40")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="40")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="40")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="40")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES50!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="50")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="50")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="50")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="50")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="50")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES60!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="60")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="60")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="60")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="60")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="60")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES70!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="70")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="70")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="70")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="70")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="70")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES80!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="80")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="80")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="80")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="80")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="80")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES90!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="90")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="90")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="90")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="90")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="90")&&!(OnCooldownUtility5)) ) ) {
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
        }
        
        if (RadioCi=1) {
            If ((TriggerES20!="00000")||(AutoQuit&&RadioQuit20)|| ( ((YesUtility1)&&(YesUtility1ESPercent="20")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="20")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="20")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="20")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="20")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, ES20, vX_ES, vY_ES20 
                if (ES20!=varES20) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit20=1) {
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
            If ((TriggerES30!="00000")||(AutoQuit&&RadioQuit30)|| ( ((YesUtility1)&&(YesUtility1ESPercent="30")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="30")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="30")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="30")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="30")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, ES30, vX_ES, vY_ES30 
                if (ES30!=varES30) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit30=1) {
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
            If ((TriggerES40!="00000")||(AutoQuit&&RadioQuit40)|| ( ((YesUtility1)&&(YesUtility1ESPercent="40")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="40")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="40")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="40")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="40")&&!(OnCooldownUtility5)) ) ) {
                pixelgetcolor, ES40, vX_ES, vY_ES40 
                if (ES40!=varES40) {
					GuiStatus("OnChar")
					if !(OnChar)
						Exit
                    if (AutoQuit=1) && (RadioQuit40=1) {
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
            If ((TriggerES50!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="50")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="50")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="50")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="50")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="50")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES60!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="60")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="60")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="60")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="60")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="60")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES70!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="70")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="70")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="70")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="70")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="70")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES80!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="80")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="80")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="80")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="80")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="80")&&!(OnCooldownUtility5)) ) ) {
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
            If ((TriggerES90!="00000")|| ( ((YesUtility1)&&(YesUtility1ESPercent="90")&&!(OnCooldownUtility1)) || ((YesUtility2)&&(YesUtility2ESPercent="90")&&!(OnCooldownUtility2)) || ((YesUtility3)&&(YesUtility3ESPercent="90")&&!(OnCooldownUtility3)) || ((YesUtility4)&&(YesUtility4ESPercent="90")&&!(OnCooldownUtility4)) || ((YesUtility5)&&(YesUtility5ESPercent="90")&&!(OnCooldownUtility5)) ) ) {
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
        }
        
        If (TriggerMana10!="00000") {
            pixelgetcolor, Mana10, vX_Mana, vY_Mana10
            if (Mana10!=varMana10) {
				GuiStatus("OnChar")
				if !(OnChar)
					Exit
                TriggerMana(TriggerMana10)
            }
        }
        
        GuiUpdate()
    }
    Return
	}
; Trigger named Utility
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TriggerUtility(Utility){
	GuiStatus("OnHideout")
	GuiStatus("OnChar")
	GuiStatus("OnChat")
	GuiStatus("OnInventory")
	
	if (OnHideout || !OnChar || OnChat || OnInventory) { ;in Hideout, not on char, chat open, or open inventory
		GuiUpdate()
		Exit
	}
    If (!OnCooldownUtility%Utility%)&&(YesUtility%Utility%){
        key:=KeyUtility%Utility%
        Send %key%
        SendMSG(4, Utility, scriptGottaGoFast)
        OnCooldownUtility%Utility%:=1
        Cooldown:=CooldownUtility%Utility%
        SetTimer, TimerUtility%Utility%, %Cooldown%
    }
    Return
	} 
; Flask Trigger check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TriggerFlask(Trigger){
    FL:=1
    loop 5 {
        FLVal:=SubStr(Trigger,FL,1)+0
        if (FLVal > 0) {
            if (OnCooldown[FL]=0) {
                send %FL%
                SendMSG(3, FL, scriptGottaGoFast)
                OnCooldown[FL]:=1 
                Cooldown:=CooldownFlask%FL%
                settimer, TimmerFlask%FL%, %Cooldown%
                RandomSleep(15,60)			
            }
        }
        ++FL
    }
    Return
	}
; Trigger Mana Flasks Sequentially
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
        send %FL%
        OnCooldown[FL] := 1 
        Cooldown:=CooldownFlask%FL%
        settimer, TimmerFlask%FL%, %Cooldown%
        SendMSG(3, FL, scriptGottaGoFast)
        RandomSleep(23,59)
    }
    Return
	}

; Auto-detect the joystick number if called for:
DetectJoystick(){
     if JoystickNumber <= 0
     {
          Loop 16  ; Query each joystick number to find out which ones exist.
          {
               GetKeyState, JoyName, %A_Index%JoyName
               if JoyName <>
               {
                    JoystickNumber = %A_Index%
                    Ding(3000,"Detected Joystick on the " . A_Index . " port.")
                    break
                    
               }
          }
          if JoystickNumber <= 0
          {
				Ding(3000,"The system does not appear to have any joysticks.")
          }
     }
     Else 
     {
		Ding(3000,"System already has a Joystick on Port " . JoystickNumber ,"Set Joystick Number to 0 for auto-detect.")
     }
     Return
}
; Clamp Value function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Clamp( Val, Min, Max) {
    If Val < Min
        Val := Min
    If Val > Max
        Val := Max
    Return
	}
; Register Chat Hokeys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterHotkeys() {
    global
    Hotkey If, % fn1
        If 1Suffix1
            Hotkey, *%1Suffix1%, 1FireWhisperHotkey1, off
        If 1Suffix2
            Hotkey, *%1Suffix2%, 1FireWhisperHotkey2, off
        If 1Suffix3
            Hotkey, *%1Suffix3%, 1FireWhisperHotkey3, off
        If 1Suffix4
            Hotkey, *%1Suffix4%, 1FireWhisperHotkey4, off
        If 1Suffix5
            Hotkey, *%1Suffix5%, 1FireWhisperHotkey5, off
        If 1Suffix6
            Hotkey, *%1Suffix6%, 1FireWhisperHotkey6, off
        If 1Suffix7
            Hotkey, *%1Suffix7%, 1FireWhisperHotkey7, off
        If 1Suffix8
            Hotkey, *%1Suffix8%, 1FireWhisperHotkey8, off
        If 1Suffix9
            Hotkey, *%1Suffix9%, 1FireWhisperHotkey9, off

    Hotkey If, % fn2
        If 2Suffix1
            Hotkey, *%2Suffix1%, 2FireWhisperHotkey1, off
        If 2Suffix2
            Hotkey, *%2Suffix2%, 2FireWhisperHotkey2, off
        If 2Suffix3
            Hotkey, *%2Suffix3%, 2FireWhisperHotkey3, off
        If 2Suffix4
            Hotkey, *%2Suffix4%, 2FireWhisperHotkey4, off
        If 2Suffix5
            Hotkey, *%2Suffix5%, 2FireWhisperHotkey5, off
        If 2Suffix6
            Hotkey, *%2Suffix6%, 2FireWhisperHotkey6, off
        If 2Suffix7
            Hotkey, *%2Suffix7%, 2FireWhisperHotkey7, off
        If 2Suffix8
            Hotkey, *%2Suffix8%, 2FireWhisperHotkey8, off
        If 2Suffix9
            Hotkey, *%2Suffix9%, 2FireWhisperHotkey9, off

    Hotkey If, % fn3
        If stashSuffix1
            Hotkey, *%stashSuffix1%, FireStashHotkey1, off
        If stashSuffix2
            Hotkey, *%stashSuffix2%, FireStashHotkey2, off
        If stashSuffix3
            Hotkey, *%stashSuffix3%, FireStashHotkey3, off
        If stashSuffix4
            Hotkey, *%stashSuffix4%, FireStashHotkey4, off
        If stashSuffix5
            Hotkey, *%stashSuffix5%, FireStashHotkey5, off
        If stashSuffix6
            Hotkey, *%stashSuffix6%, FireStashHotkey6, off
        If stashSuffix7
            Hotkey, *%stashSuffix7%, FireStashHotkey7, off
        If stashSuffix8
            Hotkey, *%stashSuffix8%, FireStashHotkey8, off
        If stashSuffix9
            Hotkey, *%stashSuffix9%, FireStashHotkey9, off

    Gui Submit, NoHide
    fn1 := Func("1HotkeyShouldFire").Bind(1Prefix1,1Prefix2,EnableChatHotkeys)
    Hotkey If, % fn1
    Loop, 9 {
        If (1Suffix%A_Index%)
            keyval := 1Suffix%A_Index%
            Hotkey, *%keyval%, 1FireWhisperHotkey%A_Index%, On
        }
    fn2 := Func("2HotkeyShouldFire").Bind(2Prefix1,2Prefix2,EnableChatHotkeys)
    Hotkey If, % fn2
    Loop, 9 {
        If (2Suffix%A_Index%)
            keyval := 2Suffix%A_Index%
            Hotkey, *%keyval%, 2FireWhisperHotkey%A_Index%, On
        }
    fn3 := Func("stashHotkeyShouldFire").Bind(stashPrefix1,stashPrefix2,YesStashKeys)
    Hotkey If, % fn3
    Loop, 9 {
        If (stashSuffix%A_Index%)
            keyval := stashSuffix%A_Index%
            Hotkey, ~*%keyval%, FireStashHotkey%A_Index%, On
        }
    Return
    }
; Functions to evaluate keystate
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
; Flask Timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimmerFlask1:
		OnCooldown[1]:=0
		settimer,TimmerFlask1,delete
	return

	TimmerFlask2:
		OnCooldown[2]:=0
		settimer,TimmerFlask2,delete
	return

	TimmerFlask3:
		OnCooldown[3]:=0
		settimer,TimmerFlask3,delete
	return

	TimmerFlask4:
		OnCooldown[4]:=0
		settimer,TimmerFlask4,delete
	return

	TimmerFlask5:
		OnCooldown[5]:=0
		settimer,TimmerFlask5,delete
	return

; Passthrough Timer
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TimerPassthrough:
	If ( GetKeyState(1, "P") ) {
		OnCooldown[1]:=1
		settimer, TimmerFlask1, %CooldownFlask1%
		SendMSG(3, 1, scriptGottaGoFast)
	}
	If ( GetKeyState(2, "P") ) {
		OnCooldown[2]:=1
		settimer, TimmerFlask2, %CooldownFlask2%
		SendMSG(3, 2, scriptGottaGoFast)
	}
	If ( GetKeyState(3, "P") ) {
		OnCooldown[3]:=1
		settimer, TimmerFlask3, %CooldownFlask3%
		SendMSG(3, 3, scriptGottaGoFast)
	}
	If ( GetKeyState(4, "P") ) {
		OnCooldown[4]:=1
		settimer, TimmerFlask4, %CooldownFlask4%
		SendMSG(3, 4, scriptGottaGoFast)
	}
	If ( GetKeyState(5, "P") ) {
		OnCooldown[5]:=1
		settimer, TimmerFlask5, %CooldownFlask5%
		SendMSG(3, 5, scriptGottaGoFast)
	}
Return

; Attack Key timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerMainAttack:
		MainAttackPressed:=GetKeyState(hotkeyMainAttack)
		If (MainAttackPressed && TriggerMainAttack > 0 )
			MainAttackCommand()
		If (MainAttackPressed && QSonMainAttack)
			SendMSG(5,1,scriptGottaGoFast)
		If (!MainAttackPressed)
			settimer,TimerMainAttack,delete
	Return
	TimerSecondaryAttack:
		SecondaryAttackPressed:=GetKeyState(hotkeySecondaryAttack)
		If (SecondaryAttackPressed && TriggerSecondaryAttack > 0 )
			SecondaryAttackCommand()
		If (SecondaryAttackPressed && QSonSecondaryAttack)
			SendMSG(5,1,scriptGottaGoFast)
		If (!SecondaryAttackPressed)
			settimer,TimerSecondaryAttack,delete
	Return

; Utility Timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerUtility1:
		OnCooldownUtility1 := 0
		settimer,TimerUtility1,delete
	Return
	TimerUtility2:
		OnCooldownUtility2 := 0
		settimer,TimerUtility2,delete
	Return
	TimerUtility3:
		OnCooldownUtility3 := 0
		settimer,TimerUtility3,delete
	Return
	TimerUtility4:
		OnCooldownUtility4 := 0
		settimer,TimerUtility4,delete
	Return
	TimerUtility5:
		OnCooldownUtility5 := 0
		settimer,TimerUtility5,delete
	Return
; Detonate Timer
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TDetonated:
		Detonated:=0
		settimer,TDetonated,delete
	return

; Configuration handling, ini updates, Hotkey handling, Utility Gfunctions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
readFromFile(){
    global
	Thread, NoTimers, true		;Critical

	LoadArray()
    ;General settings
    IniRead, Speed, settings.ini, General, Speed, 1
    IniRead, Tick, settings.ini, General, Tick, 50
    IniRead, QTick, settings.ini, General, QTick, 250
    IniRead, DebugMessages, settings.ini, General, DebugMessages, 0
    IniRead, ShowPixelGrid, settings.ini, General, ShowPixelGrid, 0
    IniRead, ShowItemInfo, settings.ini, General, ShowItemInfo, 0
    IniRead, DetonateMines, settings.ini, General, DetonateMines, 0
    IniRead, LootVacuum, settings.ini, General, LootVacuum, 0
    IniRead, YesVendor, settings.ini, General, YesVendor, 1
    IniRead, YesStash, settings.ini, General, YesStash, 1
    IniRead, YesIdentify, settings.ini, General, YesIdentify, 1
    IniRead, YesDiv, settings.ini, General, YesDiv, 1
	IniRead, YesMapUnid, settings.ini, General, YesMapUnid, 1
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
    IniRead, StashTabProphecy, settings.ini, Stash Tab, StashTabProphecy, 1
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
    IniRead, StashTabYesProphecy, settings.ini, Stash Tab, StashTabYesProphecy, 1
    
    ;Inventory Colors
    IniRead, varEmptyInvSlotColor, settings.ini, Inventory Colors, EmptyInvSlotColor, 0x000100, 0x020402, 0x000000, 0x020302, 0x010201, 0x060906, 0x050905
    IniRead, varMouseoverColor, settings.ini, Inventory Colors, MouseoverColor, 0x011C01, 0x011C01
    ;Create an array out of the read string
    varEmptyInvSlotColor := StrSplit(varEmptyInvSlotColor, ",")
    varMouseoverColor := StrSplit(varMouseoverColor, ",")
    
    ;Failsafe Colors
    IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0xB5EFFE
    IniRead, varOnHideoutMin, settings.ini, Failsafe Colors, OnHideoutMin, 0xCDF6FE
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
    
    ;CharacterTypeCheck
    IniRead, RadioLife, settings.ini, CharacterTypeCheck, Life, 1
	IniRead, RadioHybrid, settings.ini, CharacterTypeCheck, Hybrid, 0
    IniRead, RadioCi, settings.ini, CharacterTypeCheck, Ci, 0
    
    ;AutoQuit
    IniRead, RadioQuit20, settings.ini, AutoQuit, Quit20, 1
    IniRead, RadioQuit30, settings.ini, AutoQuit, Quit30, 0
    IniRead, RadioQuit40, settings.ini, AutoQuit, Quit40, 0
    IniRead, RadioCritQuit, settings.ini, AutoQuit, CritQuit, 1
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
        hotkey,% hotkeyGetMouseCoords, CoordAndDebugCommand, Off
    If hotkeyPopFlasks
        hotkey,% hotkeyPopFlasks, PopFlasksCommand, Off
    If hotkeyLogout
        hotkey,% hotkeyLogout, LogoutCommand, Off
    If hotkeyItemSort
        hotkey,% hotkeyItemSort, ItemSortCommand, Off
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
        hotkey,% hotkeyGetMouseCoords, CoordAndDebugCommand, On
    If hotkeyPopFlasks
        hotkey,% hotkeyPopFlasks, PopFlasksCommand, On
    If hotkeyLogout
        hotkey,% hotkeyLogout, LogoutCommand, On
    If hotkeyItemSort
        hotkey,% hotkeyItemSort, ItemSortCommand, On
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
    IniRead, 1Prefix2, settings.ini, Chat Hotkeys, 1Prefix2, ""
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
    IniRead, 1Suffix2Text, settings.ini, Chat Hotkeys, 1Suffix2Text, /menagerie
    IniRead, 1Suffix3Text, settings.ini, Chat Hotkeys, 1Suffix3Text, /cls
    IniRead, 1Suffix4Text, settings.ini, Chat Hotkeys, 1Suffix4Text, /ladder
    IniRead, 1Suffix5Text, settings.ini, Chat Hotkeys, 1Suffix5Text, /reset_xp
    IniRead, 1Suffix6Text, settings.ini, Chat Hotkeys, 1Suffix6Text, /invite RecipientName
    IniRead, 1Suffix7Text, settings.ini, Chat Hotkeys, 1Suffix7Text, /kick RecipientName
    IniRead, 1Suffix8Text, settings.ini, Chat Hotkeys, 1Suffix8Text, /kick CharacterName
    IniRead, 1Suffix9Text, settings.ini, Chat Hotkeys, 1Suffix9Text, @RecipientName Still Interested?

    IniRead, 2Prefix1, settings.ini, Chat Hotkeys, 2Prefix1, d
    IniRead, 2Prefix2, settings.ini, Chat Hotkeys, 2Prefix2, ""
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

    IniRead, stashPrefix1, settings.ini, Stash Hotkeys, stashPrefix1, ""
    IniRead, stashPrefix2, settings.ini, Stash Hotkeys, stashPrefix2, ""
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
        hotkey,% hotkeyGetMouseCoords, CoordAndDebugCommand, Off
    If hotkeyPopFlasks
        hotkey,% hotkeyPopFlasks, PopFlasksCommand, Off
    If hotkeyLogout
        hotkey,% hotkeyLogout, LogoutCommand, Off
    If hotkeyItemSort
        hotkey,% hotkeyItemSort, ItemSortCommand, Off
    If hotkeyLootScan
        hotkey, $~%hotkeyLootScan%, LootScanCommand, Off
    If hotkeyMainAttack
        hotkey, $~%hotkeyMainAttack%, MainAttackCommand, Off
    If hotkeySecondaryAttack
        hotkey, $~%hotkeySecondaryAttack%, SecondaryAttackCommand, Off

    Hotkey If, % fn1
	If 1Suffix1
		Hotkey, *%1Suffix1%, 1FireWhisperHotkey1, off
	If 1Suffix2
		Hotkey, *%1Suffix2%, 1FireWhisperHotkey2, off
	If 1Suffix3
		Hotkey, *%1Suffix3%, 1FireWhisperHotkey3, off
	If 1Suffix4
		Hotkey, *%1Suffix4%, 1FireWhisperHotkey4, off
	If 1Suffix5
		Hotkey, *%1Suffix5%, 1FireWhisperHotkey5, off
	If 1Suffix6
		Hotkey, *%1Suffix6%, 1FireWhisperHotkey6, off
	If 1Suffix7
		Hotkey, *%1Suffix7%, 1FireWhisperHotkey7, off
	If 1Suffix8
		Hotkey, *%1Suffix8%, 1FireWhisperHotkey8, off
	If 1Suffix9
		Hotkey, *%1Suffix9%, 1FireWhisperHotkey9, off

    Hotkey If, % fn2
	If 2Suffix1
		Hotkey, *%2Suffix1%, 2FireWhisperHotkey1, off
	If 2Suffix2
		Hotkey, *%2Suffix2%, 2FireWhisperHotkey2, off
	If 2Suffix3
		Hotkey, *%2Suffix3%, 2FireWhisperHotkey3, off
	If 2Suffix4
		Hotkey, *%2Suffix4%, 2FireWhisperHotkey4, off
	If 2Suffix5
		Hotkey, *%2Suffix5%, 2FireWhisperHotkey5, off
	If 2Suffix6
		Hotkey, *%2Suffix6%, 2FireWhisperHotkey6, off
	If 2Suffix7
		Hotkey, *%2Suffix7%, 2FireWhisperHotkey7, off
	If 2Suffix8
		Hotkey, *%2Suffix8%, 2FireWhisperHotkey8, off
	If 2Suffix9
		Hotkey, *%2Suffix9%, 2FireWhisperHotkey9, off

    Hotkey If, % fn3
	If stashSuffix1
		Hotkey, *%stashSuffix1%, FireStashHotkey1, off
	If stashSuffix2
		Hotkey, *%stashSuffix2%, FireStashHotkey2, off
	If stashSuffix3
		Hotkey, *%stashSuffix3%, FireStashHotkey3, off
	If stashSuffix4
		Hotkey, *%stashSuffix4%, FireStashHotkey4, off
	If stashSuffix5
		Hotkey, *%stashSuffix5%, FireStashHotkey5, off
	If stashSuffix6
		Hotkey, *%stashSuffix6%, FireStashHotkey6, off
	If stashSuffix7
		Hotkey, *%stashSuffix7%, FireStashHotkey7, off
	If stashSuffix8
		Hotkey, *%stashSuffix8%, FireStashHotkey8, off
	If stashSuffix9
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
        
        IniWrite, %varMana10%, settings.ini, Mana Colors, Mana10
        ;Messagebox	
        ToolTip % "Resampled the Life, ES, and Mana colors`nMake sure you were on your character!"
            SetTimer, RemoveToolTip, -5000
    } Else {
        MsgBox % "Game is not Open`nWill not Resample the Life, ES, or Mana colors!`nAll other settings will save."
        Gui, Submit, NoHide
    }
    
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
    IniWrite, %ShowPixelGrid%, settings.ini, General, ShowPixelGrid
    IniWrite, %ShowItemInfo%, settings.ini, General, ShowItemInfo
    IniWrite, %DetonateMines%, settings.ini, General, DetonateMines
    IniWrite, %LootVacuum%, settings.ini, General, LootVacuum
    IniWrite, %YesVendor%, settings.ini, General, YesVendor
    IniWrite, %YesStash%, settings.ini, General, YesStash
    IniWrite, %YesIdentify%, settings.ini, General, YesIdentify
    IniWrite, %YesDiv%, settings.ini, General, YesDiv
	IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
    IniWrite, %Latency%, settings.ini, General, Latency
    IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
    IniWrite, %Steam%, settings.ini, General, Steam
    IniWrite, %HighBits%, settings.ini, General, HighBits
    IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
    IniWrite, %CharName%, settings.ini, General, CharName
    IniWrite, %EnableChatHotkeys%, settings.ini, General, EnableChatHotkeys
    IniWrite, %YesStashKeys%, settings.ini, General, YesStashKeys
    IniWrite, %QSonMainAttack%, settings.ini, General, QSonMainAttack
    IniWrite, %QSonSecondaryAttack%, settings.ini, General, QSonSecondaryAttack

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
    
    ;Flask Cooldowns
    IniWrite, %CooldownFlask1%, settings.ini, Flask Cooldowns, CooldownFlask1
    IniWrite, %CooldownFlask2%, settings.ini, Flask Cooldowns, CooldownFlask2
    IniWrite, %CooldownFlask3%, settings.ini, Flask Cooldowns, CooldownFlask3
    IniWrite, %CooldownFlask4%, settings.ini, Flask Cooldowns, CooldownFlask4
    IniWrite, %CooldownFlask5%, settings.ini, Flask Cooldowns, CooldownFlask5	
    
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
    IniWrite, %StashTabProphecy%, settings.ini, Stash Tab, StashTabProphecy
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
    IniWrite, %StashTabYesProphecy%, settings.ini, Stash Tab, StashTabYesProphecy
    
    ;Attack Flasks
    IniWrite, %MainAttackbox1%%MainAttackbox2%%MainAttackbox3%%MainAttackbox4%%MainAttackbox5%, settings.ini, Attack Triggers, TriggerMainAttack
    IniWrite, %SecondaryAttackbox1%%SecondaryAttackbox2%%SecondaryAttackbox3%%SecondaryAttackbox4%%SecondaryAttackbox5%, settings.ini, Attack Triggers, TriggerSecondaryAttack
    
    ;Quicksilver Flasks
    IniWrite, %TriggerQuicksilverDelay%, settings.ini, Quicksilver, TriggerQuicksilverDelay
    IniWrite, %Radiobox1QS%%Radiobox2QS%%Radiobox3QS%%Radiobox4QS%%Radiobox5QS%, settings.ini, Quicksilver, TriggerQuicksilver
    
    ;CharacterTypeCheck
    IniWrite, %RadioLife%, settings.ini, CharacterTypeCheck, Life
	IniWrite, %RadioHybrid%, settings.ini, CharacterTypeCheck, Hybrid	
    IniWrite, %RadioCi%, settings.ini, CharacterTypeCheck, Ci	
    
    ;AutoQuit
    IniWrite, %RadioQuit20%, settings.ini, AutoQuit, Quit20
    IniWrite, %RadioQuit30%, settings.ini, AutoQuit, Quit30
    IniWrite, %RadioQuit40%, settings.ini, AutoQuit, Quit40
    IniWrite, %RadioCritQuit%, settings.ini, AutoQuit, CritQuit
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

    readFromFile()
	If (YesPersistantToggle)
		AutoReset()
    GuiUpdate()
    SetTitleMatchMode 2
    IfWinExist, ahk_group POEGameGroup
    	{
        WinActivate, ahk_group POEGameGroup
    	}
    SendMSG(1, , scriptGottaGoFast)
return  
}

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
    
    ;AutoQuit
    IniWrite, %RadioQuit20%, settings.ini, Profile%Profile%, Quit20
    IniWrite, %RadioQuit30%, settings.ini, Profile%Profile%, Quit30
    IniWrite, %RadioQuit40%, settings.ini, Profile%Profile%, Quit40
    IniWrite, %RadioCritQuit%, settings.ini, Profile%Profile%, CritQuit
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
    
    ;AutoQuit
    IniRead, RadioQuit20, settings.ini, Profile%Profile%, Quit20, 1
    GuiControl, , RadioQuit20, %RadioQuit20%
    IniRead, RadioQuit30, settings.ini, Profile%Profile%, Quit30, 0
    GuiControl, , RadioQuit30, %RadioQuit30%
    IniRead, RadioQuit40, settings.ini, Profile%Profile%, Quit40, 0
    GuiControl, , RadioQuit40, %RadioQuit40%
    IniRead, RadioCritQuit, settings.ini, Profile%Profile%, CritQuit, 1
    GuiControl, , RadioCritQuit, %RadioCritQuit%
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

    ;Update UI
    if(RadioLife==1) {
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % ES"
        varTextAutoQuit30:="30 % ES"
        varTextAutoQuit40:="40 % ES"
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
    GuiControl,, RadioQuit20, %varTextAutoQuit20%
    GuiControl,, RadioQuit30, %varTextAutoQuit30%
    GuiControl,, RadioQuit40, %varTextAutoQuit40%
    
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

optionsCommand:
    hotkeys()
return

loadSaved:
    readFromFile()
    ;Update UI
    if(RadioLife==1) {
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % ES"
        varTextAutoQuit30:="30 % ES"
        varTextAutoQuit40:="40 % ES"
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
    GuiControl,, RadioQuit20, %varTextAutoQuit20%
    GuiControl,, RadioQuit30, %varTextAutoQuit30%
    GuiControl,, RadioQuit40, %varTextAutoQuit40%
    GuiControl,, RadioQuit20, %RadioQuit20%
    GuiControl,, RadioQuit30, %RadioQuit30%
    GuiControl,, RadioQuit40, %RadioQuit40%
    GuiControl,, CooldownFlask1, %CooldownFlask1%
    GuiControl,, CooldownFlask2, %CooldownFlask2%
    GuiControl,, CooldownFlask3, %CooldownFlask3%
    GuiControl,, CooldownFlask4, %CooldownFlask4%
    GuiControl,, CooldownFlask5, %CooldownFlask5%
    GuiControl,, RadioNormalQuit, %RadioNormalQuit%
    GuiControl,, RadioCritQuit, %RadioCritQuit%
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
	
	SendMSG(1,1,scriptGottaGoFast)
return

hotkeys(){
    global
    Gui, Show, Autosize Center, 	WingmanReloaded
    processWarningFound:=0
    Gui,6:Hide
return
}

CleanUp(){
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    
    WinGet, PID, PID, %A_ScriptDir%\GottaGoFast.ahk
    Process, Close, %PID%
Return
}

updateOnHideout:
    Gui, Submit, NoHide
    IfWinExist, ahk_group POEGameGroup
    {
        Rescale()
        WinActivate, ahk_group POEGameGroup
    } else {
        MsgBox % "PoE Window does not exist `nRecalibrate of OnHideout didn't work"
        Return
    }
    
    if WinActive(ahk_group POEGameGroup){
        pixelgetcolor, varOnHideout, vX_OnHideout, vY_OnHideout	
        IniWrite, %varOnHideout%, settings.ini, Failsafe Colors, OnHideout
        readFromFile()
        MsgBox % "OnHideout recalibrated!`nTook color hex: " . varOnHideout . " `nAt coords x: " . vX_OnHideout . " and y: " . vY_OnHideout
    } else
    MsgBox % "PoE Window is not active. `nRecalibrate of OnHideout didn't work"
    
    
    hotkeys()
    
return

updateOnHideoutMin:
    Gui, Submit, NoHide
    IfWinExist, ahk_group POEGameGroup
    {
        Rescale()
        WinActivate, ahk_group POEGameGroup
    } else {
        MsgBox % "PoE Window does not exist `nRecalibrate of OnHideoutMin didn't work"
        Return
    }
    
    if WinActive(ahk_group POEGameGroup){
		Sleep, 1000
        pixelgetcolor, varOnHideoutMin, vX_OnHideout, vY_OnHideoutMin	
        IniWrite, %varOnHideoutMin%, settings.ini, Failsafe Colors, OnHideoutMin
        readFromFile()
        MsgBox % "OnHideoutMin recalibrated!`nTook color hex: " . varOnHideoutMin . " `nAt coords x: " . vX_OnHideout . " and y: " . vY_OnHideoutMin
    } else
    MsgBox % "PoE Window is not active. `nRecalibrate of OnHideoutMin didn't work"
    
    
    hotkeys()
    
return

updateOnChar:
    Gui, Submit, NoHide
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
    Gui, Submit, NoHide
    
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

updateOnStash:
    Gui, Submit, NoHide
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

updateEmptyInvSlotColor:
    Gui, Submit, NoHide

    IfWinExist, ahk_group POEGameGroup
    {
        Rescale()
        WinActivate, ahk_group POEGameGroup
    } else {
        MsgBox % "PoE Window does not exist. `nInventory calibration didn't work"
        Return
    }

    
    
    if WinActive(ahk_group POEGameGroup){
        ;Now we need to get the user input for every grid element if its empty or not

        ;First inform the user about the procedure
        infoMsg := "Following we loop through the whole inventory, recording all colors and save it as empty slot colors.`r`n`r`n"
        infoMsg .= "  -> Make sure your whole inventory is empty`r`n"
        infoMsg .= "  -> Make sure your inventory is open`r`n`r`n"
        infoMsg .= "Do you meet the above state requirements? If not please cancel this function."

        MsgBox, 1,, %infoMsg%
        IfMsgBox, Cancel
        {
            MsgBox Canceled the inventory calibration
            return
        }

        varEmptyInvSlotColor := []
        WinActivate, ahk_group POEGameGroup

        ;Loop through the whole grid, overlay the current grid item and display a box with two buttons "Empty" and "Occupied"
        ; I couldn't find a fast way to draw an overlay, doing at the moment with manual , might lead to problem if the user doesnt understand
        ; If the user clicks "Empty" save the pixelcolor and add it to the array of empty inv slot colors
        For c, GridX in InventoryGridX	{
            For r, GridY in InventoryGridY
            {
                pixelgetcolor, PointColor, GridX, GridY

                if(indexOf(PointColor, varEmptyInvSlotColor)){
                    ;We have this empty color already, skip this slot
                    continue
                }else{
                    ;Assume that the whole inventory is empty and we just add the color to the array
                    varEmptyInvSlotColor.Push(PointColor)
                }
            }
        }

        strToSave := arrToStr(varEmptyInvSlotColor)

        IniWrite, %strToSave%, settings.ini, Inventory Colors, EmptyInvSlotColor
        readFromFile()

        infoMsg := "Empty inventory slot colors calibrated and saved with following color codes:`r`n`r`n"
        infoMsg .= strToSave

        MsgBox, %infoMsg%


    }else{
        MsgBox % "PoE Window is not active. `nRecalibrate of Empty Color didn't work"
    }

    hotkeys()
return

updateMouseoverColor:
    Gui, Submit, NoHide

    IfWinExist, ahk_group POEGameGroup
    {
        Rescale()
        WinActivate, ahk_group POEGameGroup
    } else {
        MsgBox % "PoE Window does not exist. `nMouseover calibration didn't work"
        Return
    }

    
    
    if WinActive(ahk_group POEGameGroup){
        ;Now we need to get the user input for every grid element if its empty or not

        ;First inform the user about the procedure
        infoMsg := "Following we loop through the whole inventory, recording all colors and save it as Mouseover colors.`r`n`r`n"
        infoMsg .= "  -> Make sure your whole inventory is filled with currency`r`n"
        infoMsg .= "  -> Make sure your inventory is open`r`n`r`n"
        infoMsg .= "Do you meet the above state requirements? If not please cancel this function."

        MsgBox, 1,, %infoMsg%
        IfMsgBox, Cancel
        {
            MsgBox Canceled the Mouseover calibration
            return
        }

        varMouseoverColor := []
        WinActivate, ahk_group POEGameGroup

        ;Loop through the whole grid, overlay the current grid item and display a box with two buttons "Empty" and "Occupied"
        ; I couldn't find a fast way to draw an overlay, doing at the moment with manual , might lead to problem if the user doesnt understand
        ; If the user clicks "Empty" save the pixelcolor and add it to the array of empty inv slot colors
        For c, GridX in InventoryGridX	{
            For r, GridY in InventoryGridY
            {
				Grid := RandClick(GridX, GridY)
				MouseMove, Grid.X, Grid.Y
				Sleep, 60
                pixelgetcolor, PointColor, GridX, GridY

                if(indexOf(PointColor, varMouseoverColor)){
                    ;We have this empty color already, skip this slot
                    continue
                }else{
                    ;Assume that the whole inventory is empty and we just add the color to the array
                    varMouseoverColor.Push(PointColor)
                }
            }
        }

        strToSave := arrToStr(varMouseoverColor)

        IniWrite, %strToSave%, settings.ini, Inventory Colors, MouseoverColor
        readFromFile()

        infoMsg := "Mouseover colors calibrated and saved with following color codes:`r`n`r`n"
        infoMsg .= strToSave

        MsgBox, %infoMsg%


    }else{
        MsgBox % "PoE Window is not active. `nRecalibrate of Mouseover Color didn't work"
    }

    hotkeys()
return

updateOnChat:
    Gui, Submit, NoHide
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
    Gui, Submit, NoHide
    
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
    Gui, Submit, NoHide
    
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
    Gui, Submit, NoHide
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
    Gui, Submit, NoHide
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

updateCharacterType:
    Gui, Submit, NoHide
    if(RadioLife==1) {
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % Life"
        varTextAutoQuit30:="30 % Life"
        varTextAutoQuit40:="40 % Life"
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
        varTextAutoQuit20:="20 % ES"
        varTextAutoQuit30:="30 % ES"
        varTextAutoQuit40:="40 % ES"
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
    GuiControl,, RadioQuit20, %varTextAutoQuit20%
    GuiControl,, RadioQuit30, %varTextAutoQuit30%
    GuiControl,, RadioQuit40, %varTextAutoQuit40%
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
    IniWrite, %StashTabProphecy%, settings.ini, Stash Tab, StashTabProphecy
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
    IniWrite, %StashTabYesProphecy%, settings.ini, Stash Tab, StashTabYesProphecy
Return

UpdateExtra:
    Gui, Submit, NoHide
    IniWrite, %DetonateMines%, settings.ini, General, DetonateMines
    IniWrite, %LootVacuum%, settings.ini, General, LootVacuum
    IniWrite, %YesVendor%, settings.ini, General, YesVendor
    IniWrite, %YesStash%, settings.ini, General, YesStash
    IniWrite, %YesIdentify%, settings.ini, General, YesIdentify
    IniWrite, %YesDiv%, settings.ini, General, YesDiv
	IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
    IniWrite, %Latency%, settings.ini, General, Latency
    IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
    IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
    IniWrite, %Steam%, settings.ini, General, Steam
    IniWrite, %HighBits%, settings.ini, General, HighBits
    IniWrite, %AutoUpdateOff%, settings.ini, General, AutoUpdateOff
    IniWrite, %YesPersistantToggle%, settings.ini, General, YesPersistantToggle
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

UpdateResolutionScale:
    Gui, Submit, NoHide
    IniWrite, %ResolutionScale%, settings.ini, General, ResolutionScale
    Rescale()
Return

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

LaunchHelp:
    Run, https://www.autohotkey.com/docs/KeyList.htm ; Open the AutoHotkey List of Keys
Return

LaunchWiki:
    Run, https://github.com/BanditTech/WingmanReloaded/wiki ; Open the wiki page for the script
Return

LaunchDonate:
    Run, https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ESDL6W59QR63A&currency_code=USD&source=url ; Open the donation page for the script
Return

LaunchLootFilter:
    Run, %A_ScriptDir%\data\LootFilter.ahk ; Open the custom loot filter editor
Return

UpdateDebug:
    Gui, Submit, NoHide
    If (DebugMessages=1) {
        varCoordUtilText := "Coord/Debug"
        GuiControl, Show, ShowPixelGrid
        GuiControl, Show, PGrid
        GuiControl, Show, ShowItemInfo
        GuiControl, Show, ParseI
    } Else If (DebugMessages=0) {
        varCoordUtilText := "Coord/Pixel"
        GuiControl, Hide, ShowPixelGrid
        GuiControl, Hide, ShowItemInfo
        GuiControl, Hide, PGrid
        GuiControl, Hide, ParseI
    }
    GuiControl, , CoordUtilText, %varCoordUtilText%
    IniWrite, %DebugMessages%, settings.ini, General, DebugMessages
    IniWrite, %ShowPixelGrid%, settings.ini, General, ShowPixelGrid
    IniWrite, %ShowItemInfo%, settings.ini, General, ShowItemInfo
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
    
    SendMSG(1, 0, scriptGottaGoFast)
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
    
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

helpCalibration:
    MsgBox, Gamestate Calibration Instructions:`n`n  These buttons regrab the gamestate sample color.`n  Each button references a different game state.`n  Make sure the gamestate is true for that button!`n  Click the button once ready to calibrate.`n`nAuto-Detonate Mines Recalibration:`n`n  Sample the DetonateHex color in normal or delve.`n  Drop a mine then press the sample button that matches.
Return

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
    if Fail {
        error("update","fail",A_ScriptFullPath, VersionNumber, A_AhkVersion)
        error("ED07")
    }
    else {
        error("update","pass",A_ScriptFullPath, VersionNumber, A_AhkVersion)
        Run "%A_ScriptFullPath%"
    }
    Sleep 5000 ;This shouldn't ever hit.
    error("update","uhoh", A_ScriptFullPath, VersionNumber, A_AhkVersion)
Return

dontUpdate:
	IniWrite, 1, Settings.ini, General, AutoUpdateOff
	MsgBox, Auto-Updates have been disabled.`nCheck back on the forum for more information!`nTo resume updates, uncheck the box in config page.
    Gui, 4:Destroy
return	

ResetChat(){
    Send {Enter}{Up}{Escape}
return
}
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

SelectMainGuiTabs:
	GuiControlGet MainGuiTabs
	GuiControl % (MainGuiTabs = "Chat") ? "Show" : "Hide", InnerTab
	GuiControl MoveDraw, MainGuiTabs
return

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

return
