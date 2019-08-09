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

	Global VersionNumber := .03.3

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
	Run GottaGoFast.ahk, "A_ScriptDir"
	if not A_IsAdmin
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	OnExit("CleanUp")

	If FileExist("settings.ini")
		readFromFile()
; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;General
		Global Latency := 1
		Global ShowOnStart := 0
		Global PopFlaskRespectCD := 1
		Global ResolutionScale := "Standard"
		Global IdColor := 0x1C0101
		Global UnIdColor := 0x01012A
		Global MOColor := 0x011C01
		Global FlaskList := []
		; Use this area scale value to change how the pixel search behaves, Increasing the AreaScale will add +-(AreaScale) 
		Global AreaScale := 1
		Global LootVacuum := 1
		Global YesVendor := 1
		Global YesStash := 1
		Global YesIdentify := 1
		Global YesMapUnid := 1
		Global YesStashKeys := 1
		Global OnHideout := False
		Global OnChar := False
		Global OnChat := False
		Global OnInventory := False
		Global OnStash := False
		Global OnVendor := False
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

		Global ItemProp := {ItemName: ""
				, Rarity : ""
				, SpecialType : ""
				, Stack : 0
				, StackMax : 0
				, RarityCurrency : False
				, RarityDivination : False
				, RarityGem : False
				, RarityNormal : False
				, RarityMagic : False
				, RarityRare : False
				, RarityUnique : False
				, Identified : True
				, Map : False
				, Ring : False
				, Amulet : False
				, Chromatic : False
				, Jewel : False
				, AbyssJewel : False
				, Essence : False
				, Incubator : False
				, Fossil : False
				, Resonator : False
				, Quality : 0
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
				, Prophecy : False}

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
		Global StashTabTimelessSplinter := 1
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
		Global StashTabYesTimelessSplinter := 1
		Global StashTabYesFossil := 1
		Global StashTabYesResonator := 1
		Global StashTabYesProphecy := 1
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
		global StockPortal:=1
		global StockWisdom:=1
		global GuiX:=-5
		global GuiY:=1005

	;Failsafe Colors
		global varOnHideout:=0x161114
		global varOnChar:=0x4F6980
		global varOnChat:=0x3B6288
		global varOnInventory:=0x8CC6DD
		global varOnStash:=0x9BD6E7
		global varOnVendor:=0x7BB1CC
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
		global YesPhaseRun:=1
		global YesVaalDiscipline:=1

	;Utility Cooldowns
		global CooldownPhaseRun:=5000
		global CooldownVaalDiscipline:=60000
		
	;Utility Keys
		global utilityPhaseRun
		global utilityVaalDiscipline

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


; Standard ini read
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	readFromFile()
				

				


; Wingman Gui Variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if Life=1 
	{
		varTextAutoQuit20:="20 % Life"
		varTextAutoQuit30:="30 % Life"
		varTextAutoQuit40:="40 % Life"
	} 
	else if Hybrid=1 
		{
			varTextAutoQuit20:="20 % Life"
			varTextAutoQuit30:="30 % Life"
			varTextAutoQuit40:="40 % Life"
		}
		else if Ci=1 
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
	Gui Add, Tab2, x1 y1 w620 h465 -wrap, Flasks and Utility|Configuration|Inventory
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
	loop 4 
	{
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
	loop 4
	{
	Gui Add, Checkbox, 		vMainAttackbox%vFlask% 		x+28 			w13 h13
	vFlask:=vFlask+1
	} 

	Gui Add, Edit, 			vhotkeySecondaryAttack 		x12 	y+5 	w45 h17, 	%hotkeySecondaryAttack%
	Gui Add, Checkbox, 		vSecondaryAttackbox1 		x75 	y+-15 	w13 h13
	vFlask=2
	loop 4
	{
	Gui Add, Checkbox, 		vSecondaryAttackbox%vFlask% x+28 			w13 h13
	vFlask:=vFlask+1
	}
	Loop, 5{	
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

	Gui, Add, Text, 									x447 	y53 		h140 0x11

	Gui, Font, Bold
	Gui, Add, Text, 										x292 	y30, 				Flask Profile Management:
		Gui, Font
	Gui, Add, Button, gsubmitProfile1 x290 y52 w50 h23, Save 1
	Gui, Add, Button, gsubmitProfile2 w50 h23, Save 2
	Gui, Add, Button, gsubmitProfile3 w50 h23, Save 3
	Gui, Add, Button, gsubmitProfile4 w50 h23, Save 4
	Gui, Add, Button, gsubmitProfile5 w50 h23, Save 5

	Gui, Add, Edit, gUpdateProfileText1 vProfileText1 x340 y53 w50 h21, %ProfileText1%
	Gui, Add, Edit, gUpdateProfileText2 vProfileText2 y+8 w50 h21, %ProfileText2%
	Gui, Add, Edit, gUpdateProfileText3 vProfileText3 y+8 w50 h21, %ProfileText3%
	Gui, Add, Edit, gUpdateProfileText4 vProfileText4 y+8 w50 h21, %ProfileText4%
	Gui, Add, Edit, gUpdateProfileText5 vProfileText5 y+8 w50 h21, %ProfileText5%

	Gui, Add, Button, greadProfile1 x390 y52 w50 h23, Load 1
	Gui, Add, Button, greadProfile2 w50 h23, Load 2
	Gui, Add, Button, greadProfile3 w50 h23, Load 3
	Gui, Add, Button, greadProfile4 w50 h23, Load 4
	Gui, Add, Button, greadProfile5 w50 h23, Load 5

	Gui, Add, Button, gsubmitProfile6 x455 y52 w50 h23, Save 6
	Gui, Add, Button, gsubmitProfile7 w50 h23, Save 7
	Gui, Add, Button, gsubmitProfile8 w50 h23, Save 8
	Gui, Add, Button, gsubmitProfile9 w50 h23, Save 9
	Gui, Add, Button, gsubmitProfile10 w50 h23, Save 10

	Gui, Add, Edit, gUpdateProfileText6 vProfileText6 y+8 x505 y53 w50 h21, %ProfileText6%
	Gui, Add, Edit, gUpdateProfileText7 vProfileText7 y+8 w50 h21, %ProfileText7%
	Gui, Add, Edit, gUpdateProfileText8 vProfileText8 y+8 w50 h21, %ProfileText8%
	Gui, Add, Edit, gUpdateProfileText9 vProfileText9 y+8 w50 h21, %ProfileText9%
	Gui, Add, Edit, gUpdateProfileText10 vProfileText10 y+8 w50 h21, %ProfileText10%

	Gui, Add, Button, greadProfile6 x555 y52 w50 h23, Load 6
	Gui, Add, Button, greadProfile7 w50 h23, Load 7
	Gui, Add, Button, greadProfile8 w50 h23, Load 8
	Gui, Add, Button, greadProfile9 w50 h23, Load 9
	Gui, Add, Button, greadProfile10 w50 h23, Load 10

	Gui, Font, Bold
	Gui Add, Text, 										x292 	y230, 				Utility Management
	Gui, Font,

	Gui,Add,Edit,			gUpdateUtility  		x319 y249  w40 h19 	vCooldownPhaseRun				,%CooldownPhaseRun%
	Gui,Add,Edit,			gUpdateUtility  		   w40 h19 	vCooldownVaalDiscipline				,%CooldownVaalDiscipline%

	Gui,Add,Edit,			  	x+22	y249   w40 h19 gUpdateUtility	vutilityPhaseRun				,%utilityPhaseRun%
	Gui,Add,Edit,			  		   w40 h19 gUpdateUtility	vutilityVaalDiscipline				,%utilityVaalDiscipline%

	Gui Add, Checkbox, gUpdateUtility	vYesPhaseRun Checked%YesPhaseRun%				x+5 y252	, Use Phase Run on Quicksilver?
	Gui Add, Checkbox, gUpdateUtility	vYesVaalDiscipline Checked%YesVaalDiscipline%		y+13	, Use Vaal Discipline on 50`% ES?

	Gui Add, Text, 										x300 	y250, 	CD:
	Gui Add, Text, 													, 	CD:

	Gui Add, Text, 										x360 	y250, 	Key:
	Gui Add, Text, 													, 	Key:

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
	Gui, Add, Text, 										x22 	y30, 				Gamestate Calibration:
	Gui, Font
	Gui, Add, Button, ghelpCalibration 	x+15		w15 h15, 	?

	;Update calibration for pixel check
	Gui, Add, Button, gupdateOnHideout vUpdateOnHideoutBtn	x22	y50	w100, 	OnHideout Color
	Gui, Add, Button, gupdateOnChar vUpdateOnCharBtn	 	w100, 	OnChar Color
	Gui, Add, Button, gupdateOnChat vUpdateOnChatBtn	 	w100, 	OnChat Color

	Gui, Font, Bold
	Gui, Add, Text, 										x22 	y+10, 				AutoDetonate Calibration:
	Gui, Font

	Gui, Add, Button, gupdateDetonate vUpdateDetonateBtn	 y+8	w100, 	Detonate Color
	Gui, Add, Button, gupdateDetonateDelve vUpdateDetonateDelveBtn	 x+8	w100, 	Detonate in Delve

	Gui, Add, Button, gupdateOnInventory vUpdateOnInventoryBtn	 x130 y50	w100, 	OnInventory Color
	Gui, Add, Button, gupdateOnStash vUpdateOnStashBtn	 	w100, 	OnStash Color
	Gui, Add, Button, gupdateOnVendor vUpdateOnVendorBtn	 	w100, 	OnVendor Color
	Gui, Font, Bold
	Gui Add, Text, 										x22 	y+90, 				Additional Interface Options:
	Gui, Font, 

	Gui Add, Checkbox, gUpdateExtra	vShowOnStart Checked%ShowOnStart%                         	          	, Show GUI on startup?
	Gui Add, Checkbox, gUpdateExtra	vSteam Checked%Steam%                         	          	, Are you using Steam?
	Gui Add, Checkbox, gUpdateExtra	vHighBits Checked%HighBits%                         	          	, Are you running 64 bit?
	Gui Add, DropDownList, gUpdateResolutionScale	vResolutionScale       w80               	    , Standard|UltraWide
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
	} Else If (DebugMessages=0) {
		varCoordUtilText := "Coord/Pixel"
		GuiControl, Hide, ShowPixelGrid
		GuiControl, Hide, ShowItemInfo
		GuiControl, Hide, PGrid
		GuiControl, Hide, ParseI
	}

	Gui Add, Checkbox, gUpdateExtra	vDetonateMines Checked%DetonateMines%           x300  y145           	          , Detonate Mines?
	Gui Add, Checkbox, gUpdateExtra	vYesStashKeys Checked%YesStashKeys%                         	         x+20 , Ctrl(1-10) stash tabs?
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
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabCurrency Choose%StashTabCurrency% x10 y50 w40  ,   1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabTimelessSplinter Choose%StashTabTimelessSplinter% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabMap Choose%StashTabMap% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabFragment Choose%StashTabFragment% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabDivination Choose%StashTabDivination% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabCollection Choose%StashTabCollection% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabEssence Choose%StashTabEssence% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabProphecy Choose%StashTabProphecy% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCurrency Checked%StashTabYesCurrency%  x+5 y55, Currency Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesTimelessSplinter Checked%StashTabYesTimelessSplinter% y+14, TSplinter Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesMap Checked%StashTabYesMap% y+14, Map Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFragment Checked%StashTabYesFragment% y+14, Fragment Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesDivination Checked%StashTabYesDivination% y+14, Divination Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCollection Checked%StashTabYesCollection% y+14, Collection Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesEssence Checked%StashTabYesEssence% y+14, Essence Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesProphecy Checked%StashTabYesProphecy% y+14, Prophecy Tab

	Gui, Add, DropDownList, R5 gUpdateStash vStashTabGem Choose%StashTabGem% x150 y50 w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabGemQuality Choose%StashTabGemQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabFlaskQuality Choose%StashTabFlaskQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabLinked Choose%StashTabLinked% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabUniqueDump Choose%StashTabUniqueDump% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabUniqueRing Choose%StashTabUniqueRing% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabFossil Choose%StashTabFossil% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabResonator Choose%StashTabResonator% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGem Checked%StashTabYesGem% x195 y55, Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGemQuality Checked%StashTabYesGemQuality% y+14, Quality Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFlaskQuality Checked%StashTabYesFlaskQuality% y+14, Quality Flask Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesLinked Checked%StashTabYesLinked% y+14, Linked Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% y+14, Unique Dump Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% y+14, Unique Ring Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFossil Checked%StashTabYesFossil% y+14, Fossil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesResonator Checked%StashTabYesResonator% y+14, Resonator Tab

	Gui, Font, Bold
	Gui Add, Text, 										x352 	y30, 				ID/Vend/Stash Options:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesIdentify Checked%YesIdentify%                         	          , Identify Items?
	Gui Add, Checkbox, gUpdateExtra	vYesStash Checked%YesStash%                         	        	  , Deposit at stash?
	Gui Add, Checkbox, gUpdateExtra	vYesVendor Checked%YesVendor%                         	              , Sell at vendor?
	Gui Add, Checkbox, gUpdateExtra	vYesMapUnid Checked%YesMapUnid%                         	          , Leave Map Un-ID?

	Gui, Font, Bold
	Gui Add, Text, 										x20 	y280, 				Inventory Instructions:
	Gui, Font,
	Gui Add, Text, 										x22 	y+5, 				Use the dropdown list to choose which stash tab the item type will be sent.
	Gui Add, Text, 										x22 	y+5, 				The checkbox is to enable or disable that type of item being stashed.
	Gui Add, Text, 										x22 	y+5, 				The options to the right affect which portion of the script is enabled.

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

; Extra vars - Not in INI
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	global Trigger=00000
	global AutoQuit=0 
	global AutoFlask=0
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

		global vX_OnHideout:=1241
		global vY_OnHideout:=951
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

		global vX_StashTabMenu := 640
		global vY_StashTabMenu := 146
		global vX_StashTabList := 760
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
		If (ShowOnStart)
			Hotkeys()
	}

; Check for window to open
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SetTimer, PoEWindowCheck, 5000
; Detonate mines timer check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	If (DetonateMines&&!Detonated)
		SetTimer, TMineTick, 100
		Else If (!DetonateMines)
		SetTimer, TMineTick, off
		
; Key Passthrough for 1-5 & Attack keys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Passthrough for manual activation
	; pass-thru and start timer for flask 1
	~1::
		OnCooldown[1]:=1 
		settimer, TimmerFlask1, %CooldownFlask1%
		SendMSG(3, 1, scriptGottaGoFast)
		return

	; pass-thru and start timer for flask 2
	~2::
		OnCooldown[2]:=1 
		settimer, TimmerFlask2, %CooldownFlask2%
		SendMSG(3, 2, scriptGottaGoFast)
		return

	; pass-thru and start timer for flask 3
	~3::
		OnCooldown[3]:=1 
		settimer, TimmerFlask3, %CooldownFlask3%
		SendMSG(3, 3, scriptGottaGoFast)
		return

	; pass-thru and start timer for flask 4
	~4::
		OnCooldown[4]:=1 
		settimer, TimmerFlask4, %CooldownFlask4%
		SendMSG(3, 4, scriptGottaGoFast)
		return

	; pass-thru and start timer for flask 5
	~5::
		OnCooldown[5]:=1 
		settimer, TimmerFlask5, %CooldownFlask5%
		SendMSG(3, 5, scriptGottaGoFast)
		return

; Move to # stash hotkeys
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	If (YesStashKeys){
		^1::
			;Keywait, Ctrl
			MoveStash(1)
			return
			
		^2::
			;Keywait, Ctrl
			MoveStash(2)
			return
			
		^3::
			;Keywait, Ctrl
			MoveStash(3)
			return
			
		^4::
			;Keywait, Ctrl
			MoveStash(4)
			return
			
		^5::
			;Keywait, Ctrl
			MoveStash(5)
			return
			
		^6::
			;Keywait, Ctrl
			MoveStash(6)
			return
			
		^7::
			;Keywait, Ctrl
			MoveStash(7)
			return
			
		^8::
			;Keywait, Ctrl
			MoveStash(8)
			return
			
		^9::
			;Keywait, Ctrl
			MoveStash(9)
			return
			
		^0::
			;Keywait, Ctrl
			MoveStash(10)
			return
		}

;Reload Script with Alt+Escape
!Escape::
	Reload
	Return

;Exit Script with Win+Escape
#Escape::
	ExitApp
	Return


; --------------------------------------------Function Section-----------------------------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Loot Scanner for items under cursor pressing Loot button
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LootScan(){
	LootScanCommand:
	Pressed := GetKeyState(hotkeyLootScan, "P")
	While (Pressed&&LootVacuum)
		{
		For k, ColorHex in LootColors
			{
			Pressed := GetKeyState(hotkeyLootScan, "P")
			Sleep, -1
			MouseGetPos CenterX, CenterY
			ScanX1:=(CenterX-AreaScale)
			ScanY1:=(CenterY-AreaScale)
			ScanX2:=(CenterX+AreaScale)
			ScanY2:=(CenterY+AreaScale)
			PixelSearch, ScanPx, ScanPy, CenterX, CenterY, CenterX, CenterY, ColorHex, 0, Fast RGB
			If (ErrorLevel = 0){
				Pressed := GetKeyState(hotkeyLootScan, "P")
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
	Critical
	CurrentTab:=0
	MouseGetPos xx, yy
	IfWinActive, Path of Exile
		{
		If RunningToggle  ; This means an underlying thread is already running the loop below.
			{
			RunningToggle := False  ; Signal that thread's loop to stop.
			return  ; End this thread so that the one underneath will resume and see the change made by the line above.
			}
		RunningToggle := True
		GuiStatus()
		If ((!OnInventory&&OnChar)||(!OnChar)) ;Need to be on Character and have Inventory Open
			Return
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
				If ((PointColor=UnIdColor) || (PointColor=IdColor))
					{
					ClipItem(Grid.X,Grid.Y)
					If (!ItemProp.Identified&&YesIdentify)
						{
						If (ItemProp.Map&&!YesMapUnid)
							{
							WisdomScroll(Grid.X,Grid.Y)
							}
						Else If (ItemProp.Chromatic && (ItemProp.RarityRare || ItemProp.RarityUnique ) ) 
							{
							WisdomScroll(Grid.X,Grid.Y)
							}
						Else If ( ItemProp.Jeweler && ( ItemProp.5Link || ItemProp.6Link || ItemProp.RarityRare || ItemProp.RarityUnique) )
							{
								WisdomScroll(Grid.X,Grid.Y)
							}
						Else If (!ItemProp.Chromatic && !ItemProp.Jeweler&&!ItemProp.Map)
							{
								WisdomScroll(Grid.X,Grid.Y)
							}
						}
					If (OnStash&&YesStash) 
						{
						If (ItemProp.RarityCurrency&&ItemProp.SpecialType=""&&StashTabYesCurrency)
							{
							MoveStash(StashTabCurrency)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Map&&StashTabYesMap)
							{
							MoveStash(StashTabMap)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.BreachSplinter&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.SacrificeFragment&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.MortalFragment&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.GuardianFragment&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.ProphecyFragment&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Offering&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Vessel&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Scarab&&StashTabYesFragment)
							{
							MoveStash(StashTabFragment)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.RarityDivination&&StashTabYesDivination)
							{
							MoveStash(StashTabDivination)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.RarityUnique&&ItemProp.Ring)
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
						Else If (ItemProp.RarityUnique)
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
						If (ItemProp.Essence&&StashTabYesEssence)
							{
							MoveStash(StashTabEssence)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Fossil&&StashTabYesFossil)
							{
							MoveStash(StashTabFossil)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Resonator&&StashTabYesResonator)
							{
							MoveStash(StashTabResonator)
							RandomSleep(30,45)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Flask&&(ItemProp.Quality>0)&&StashTabYesFlaskQuality)
							{
							MoveStash(StashTabFlaskQuality)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.RarityGem)
							{
							If ((ItemProp.Quality>0)&&StashTabYesGemQuality)
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
						If ((ItemProp.5Link||ItemProp.6Link)&&StashTabYesLinked)
							{
							MoveStash(StashTabLinked)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.TimelessSplinter&&StashTabYesTimelessSplinter)
							{
							MoveStash(StashTabTimelessSplinter)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						If (ItemProp.Prophecy&&StashTabYesProphecy)
							{
							MoveStash(StashTabProphecy)
							CtrlClick(Grid.X,Grid.Y)
							Continue
							}
						}
					If (OnVendor&&YesVendor)
						{
						If (ItemProp.RarityCurrency)
							Continue
						If (ItemProp.RarityUnique && (ItemProp.Ring||ItemProp.Amulet||ItemProp.Jewel||ItemProp.Flask))
							Continue
						If ( ItemProp.SpecialType="" )
							{
							Sleep, 30*Latency
							CtrlClick(Grid.X,Grid.Y)
							Sleep, 10*Latency
							Continue
							}
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
	If (CurrentTab=Tab)
		return
	If (CurrentTab!=Tab)
		{
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
		Sleep, 45*Latency
		send {Enter}
		Sleep, 45*Latency
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
		dif := (40 - ItemProp.Stack)
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
		dif := (40 - ItemProp.Stack)
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
	Random, Rx, x+5, x+45
	Random, Ry, y-45, y-5
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
			global vX_OnHideout:=X + Round(	A_ScreenWidth / (1920 / 1241))
			global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 951))
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
			;Stash tabs menu button
			global vX_StashTabMenu := X + Round(A_ScreenWidth / (1920 / 640))
			global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
			;Stash tabs menu list
			global vX_StashTabList := X + Round(A_ScreenWidth / (1920 / 760))
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
			global vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
			global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 951))
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
			;Stash tabs menu button
			global vX_StashTabMenu := X + Round(A_ScreenWidth / (3840 / 640))
			global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
			;Stash tabs menu list
			global vX_StashTabList := X + Round(A_ScreenWidth / (3840 / 760))
			global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1080 / 120))
			;calculate the height of each tab
			global vY_StashTabSize := Round(A_ScreenHeight / ( 1080 / 22))
			} 
		Else If (ResolutionScale="QHD") {
			; Item Inventory Grid
			Global InventoryGridX := [ Round(A_ScreenWidth/(2560/3193)), Round(A_ScreenWidth/(2560/3246)), Round(A_ScreenWidth/(2560/3299)), Round(A_ScreenWidth/(2560/3352)), Round(A_ScreenWidth/(2560/3404)), Round(A_ScreenWidth/(2560/3457)), Round(A_ScreenWidth/(2560/3510)), Round(A_ScreenWidth/(2560/3562)), Round(A_ScreenWidth/(2560/3615)), Round(A_ScreenWidth/(2560/3668)), Round(A_ScreenWidth/(2560/3720)), Round(A_ScreenWidth/(2560/3773)) ]
			Global InventoryGridY := [ Round(A_ScreenHeight/(1440/638)), Round(A_ScreenHeight/(1440/690)), Round(A_ScreenHeight/(1440/743)), Round(A_ScreenHeight/(1440/796)), Round(A_ScreenHeight/(1440/848)) ]  
			;Detonate Mines
			Global DetonateDelveX:=X + Round(A_ScreenWidth/(2560/3462))
			Global DetonateX:=X + Round(A_ScreenWidth/(2560/3578))
			Global DetonateY:=Y + Round(A_ScreenHeight/(1440/901))
			;Scrolls in currency tab
			Global WisdomStockX:=X + Round(A_ScreenWidth/(2560/125))
			Global PortalStockX:=X + Round(A_ScreenWidth/(2560/175))
			Global WPStockY:=Y + Round(A_ScreenHeight/(1440/262))
			;Status Check OnHideout
			global vX_OnHideout:=X + Round(	A_ScreenWidth / (2560 / 3161))
			global vY_OnHideout:=Y + Round(A_ScreenHeight / (1440 / 951))
			;Status Check OnChar
			global vX_OnChar:=X + Round(A_ScreenWidth / (2560 / 41))
			global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1440 / 915))
			;Status Check OnChat
			global vX_OnChat:=X + Round(A_ScreenWidth / (2560 / 0))
			global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1440 / 653))
			;Status Check OnInventory
			global vX_OnInventory:=X + Round(A_ScreenWidth / (2560 / 3503))
			global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1440 / 36))
			;Status Check OnStash
			global vX_OnStash:=X + Round(A_ScreenWidth / (2560 / 336))
			global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1440 / 32))
			;Status Check OnVendor
			global vX_OnVendor:=X + Round(A_ScreenWidth / (2560 / 1578))
			global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1440 / 88))
			;Life %'s
			global vX_Life:=X + Round(A_ScreenWidth / (2560 / 95))
			global vY_Life20:=Y + Round(A_ScreenHeight / ( 1440 / 1034))
			global vY_Life30:=Y + Round(A_ScreenHeight / ( 1440 / 1014))
			global vY_Life40:=Y + Round(A_ScreenHeight / ( 1440 / 994))
			global vY_Life50:=Y + Round(A_ScreenHeight / ( 1440 / 974))
			global vY_Life60:=Y + Round(A_ScreenHeight / ( 1440 / 954))
			global vY_Life70:=Y + Round(A_ScreenHeight / ( 1440 / 934))
			global vY_Life80:=Y + Round(A_ScreenHeight / ( 1440 / 914))
			global vY_Life90:=Y + Round(A_ScreenHeight / ( 1440 / 894))
			;ES %'s
			global vX_ES:=X + Round(A_ScreenWidth / (2560 / 180))
			global vY_ES20:=Y + Round(A_ScreenHeight / ( 1440 / 1034))
			global vY_ES30:=Y + Round(A_ScreenHeight / ( 1440 / 1014))
			global vY_ES40:=Y + Round(A_ScreenHeight / ( 1440 / 994))
			global vY_ES50:=Y + Round(A_ScreenHeight / ( 1440 / 974))
			global vY_ES60:=Y + Round(A_ScreenHeight / ( 1440 / 954))
			global vY_ES70:=Y + Round(A_ScreenHeight / ( 1440 / 934))
			global vY_ES80:=Y + Round(A_ScreenHeight / ( 1440 / 914))
			global vY_ES90:=Y + Round(A_ScreenHeight / ( 1440 / 894))
			;Mana
			global vX_Mana:=X + Round(A_ScreenWidth / (2560 / 3745))
			global vY_Mana10:=Y + Round(A_ScreenHeight / (1440 / 1054))
			;GUI overlay
			global GuiX:=X + Round(A_ScreenWidth / (2560 / -10))
			global GuiY:=Y + Round(A_ScreenHeight / (1440 / 1027))
			;Stash tabs menu button
			global vX_StashTabMenu := X + Round(A_ScreenWidth / (2560 / 640))
			global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1440 / 146))
			;Stash tabs menu list
			global vX_StashTabList := X + Round(A_ScreenWidth / (2560 / 760))
			global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1440 / 120))
			;calculate the height of each tab
			global vY_StashTabSize := Round(A_ScreenHeight / ( 1440 / 22))
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
	if ((!AutoFlask) && (!AutoQuit)) {
		SetTimer TGameTick, Off
	} else {
	}
	GuiUpdate()
	return
	}

; Toggle Auto-Pot
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AutoFlask(){
	AutoFlaskCommand:	
	AutoFlask := !AutoFlask
	if ((!AutoFlask) and (!AutoQuit)) {
		SetTimer TGameTick, Off
	} else {
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
	Critical
	Keywait, Alt
	BlockInput, MouseMove
	MouseGetPos xx, yy
	RandomSleep(45,60)

	Send {%hotkeyCloseAllUI%} 
	RandomSleep(45,60)
	
	Send {%hotkeyInventory%} 
	RandomSleep(45,60)

	RightClick(CurrentGemX, CurrentGemY)
	RandomSleep(45,60)
	
	if (WeaponSwap==1) 
		Send {%hotkeyWeaponSwapKey%} 
	RandomSleep(45,60)

	SwiftClick(AlternateGemX, AlternateGemY)
	RandomSleep(45,60)
	
	if (WeaponSwap==1) 
		Send {%hotkeyWeaponSwapKey%} 
	RandomSleep(45,60)

	SwiftClick(CurrentGemX, CurrentGemY)
	RandomSleep(45,60)
	
	Send {%hotkeyInventory%} 
	MouseMove, xx, yy, 0
	BlockInput, MouseMoveOff
	return
	}

;Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
QuickPortal(){
	QuickPortalCommand:
	Critical
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
	Critical
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
	Critical
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
	Critical
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

	ItemProp := {ItemName: ""
				, Rarity : ""
				, SpecialType : ""
				, Stack : 0
				, StackMax : 0
				, RarityCurrency : False
				, RarityDivination : False
				, RarityGem : False
				, RarityNormal : False
				, RarityMagic : False
				, RarityRare : False
				, RarityUnique : False
				, Identified : True
				, Map : False
				, Ring : False
				, Amulet : False
				, Chromatic : False
				, Jewel : False
				, AbyssJewel : False
				, Essence : False
				, Incubator : False
				, Fossil : False
				, Resonator : False
				, Quality : 0
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
				, Prophecy : False}
	
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
				IfInString, A_LoopField, Currency
				{
					ItemProp.RarityCurrency := True
					ItemProp.Rarity := "Currency"
				}
				IfInString, A_LoopField, Divination Card
				{
					ItemProp.RarityDivination := True
					ItemProp.Rarity := "Divination Card"
					ItemProp.SpecialType := "Divination Card"
				}
				IfInString, A_LoopField, Gem
				{
					ItemProp.RarityGem := True
					ItemProp.Rarity := "Gem"
					ItemProp.SpecialType := "Gem"
				}
				IfInString, A_LoopField, Normal
				{
					ItemProp.RarityNormal := True
					ItemProp.Rarity := "Normal"
				}
				IfInString, A_LoopField, Magic
				{
					ItemProp.RarityMagic := True
					ItemProp.Rarity := "Magic"
				}
				IfInString, A_LoopField, Rare
				{
					ItemProp.RarityRare := True
					ItemProp.Rarity := "Rare"
				}
				IfInString, A_LoopField, Unique
				{
					ItemProp.RarityUnique := True
					ItemProp.Rarity := "Unique"
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
				ItemProp.ItemName := ItemProp.ItemName . A_LoopField . "`n" ; Add a line of name
				IfInString, A_LoopField, Ring
				{
					ItemProp.Ring := True
					Continue
				}
				IfInString, A_LoopField, Amulet
				{
					ItemProp.Amulet := True
					Continue
				}
				IfInString, A_LoopField, Map
				{
					ItemProp.Map := True
					ItemProp.SpecialType := "Map"
					Continue
				}
				IfInString, A_LoopField, Incubator
				{
					ItemProp.Incubator := True
					ItemProp.SpecialType := "Incubator"
					Continue
				}
				IfInString, A_LoopField, Timeless Karui Splinter
				{
					ItemProp.TimelessSplinter := True
					ItemProp.SpecialType := "Timeless Splinter"
					Continue
				}
				IfInString, A_LoopField, Timeless Eternal Empire Splinter
				{
					ItemProp.TimelessSplinter := True
					ItemProp.SpecialType := "Timeless Splinter"
					Continue
				}
				IfInString, A_LoopField, Timeless Vaal Splinter
				{
					ItemProp.TimelessSplinter := True
					ItemProp.SpecialType := "Timeless Splinter"
					Continue
				}
				IfInString, A_LoopField, Timeless Templar Splinter
				{
					ItemProp.TimelessSplinter := True
					ItemProp.SpecialType := "Timeless Splinter"
					Continue
				}
				IfInString, A_LoopField, Timeless Maraketh Splinter
				{
					ItemProp.TimelessSplinter := True
					ItemProp.SpecialType := "Timeless Splinter"
					Continue
				}
				IfInString, A_LoopField, Splinter of
				{
					ItemProp.BreachSplinter := True
					ItemProp.SpecialType := "Breach Splinter"
					Continue
				}
				IfInString, A_LoopField, Sacrifice at
				{
					ItemProp.SacrificeFragment := True
					ItemProp.SpecialType := "Sacrifice Fragment"
					Continue
				}
				IfInString, A_LoopField, Mortal Grief
				{
					ItemProp.MortalFragment := True
					ItemProp.SpecialType := "Mortal Fragment"
					Continue
				}
				IfInString, A_LoopField, Mortal Hope
				{
					ItemProp.MortalFragment := True
					ItemProp.SpecialType := "Mortal Fragment"
					Continue
				}
				IfInString, A_LoopField, Mortal Ignorance
				{
					ItemProp.MortalFragment := True
					ItemProp.SpecialType := "Mortal Fragment"
					Continue
				}
				IfInString, A_LoopField, Mortal Rage
				{
					ItemProp.MortalFragment := True
					ItemProp.SpecialType := "Mortal Fragment"
					Continue
				}
				IfInString, A_LoopField, Fragment of the
				{
					ItemProp.GuardianFragment := True
					ItemProp.SpecialType := "Guardian Fragment"
					Continue
				}
				IfInString, A_LoopField, Volkuur's Key
				{
					ItemProp.ProphecyFragment := True
					ItemProp.SpecialType := "Prophecy Fragment"
					Continue
				}
				IfInString, A_LoopField, Eber's Key
				{
					ItemProp.ProphecyFragment := True
					ItemProp.SpecialType := "Prophecy Fragment"
					Continue
				}
				IfInString, A_LoopField, Yriel's Key
				{
					ItemProp.ProphecyFragment := True
					ItemProp.SpecialType := "Prophecy Fragment"
					Continue
				}
				IfInString, A_LoopField, Inya's Key
				{
					ItemProp.ProphecyFragment := True
					ItemProp.SpecialType := "Prophecy Fragment"
					Continue
				}
				IfInString, A_LoopField, Scarab
				{
					ItemProp.Scarab := True
					ItemProp.SpecialType := "Scarab"
					Continue
				}
				IfInString, A_LoopField, Offering to the Goddess
				{
					ItemProp.Offering := True
					ItemProp.SpecialType := "Offering"
					Continue
				}
				IfInString, A_LoopField, Essence of
				{
					ItemProp.Essence := True
					ItemProp.SpecialType := "Essence"
					Continue
				}
				IfInString, A_LoopField, Remnant of Corruption
				{
					ItemProp.Essence := True
					ItemProp.SpecialType := "Essence"
					Continue
				}
				IfInString, A_LoopField, Incubator
				{
					ItemProp.Incubator := True
					ItemProp.SpecialType := "Incubator"
					Continue
				}
				IfInString, A_LoopField, Fossil
				{
					IfNotInString, A_LoopField, Fossilised
						{
						ItemProp.Fossil := True
						ItemProp.SpecialType := "Fossil"
						Continue
						}
				}
				IfInString, A_LoopField, Resonator
				{
					ItemProp.Resonator := True
					ItemProp.SpecialType := "Resonator"
					Continue
				}
				IfInString, A_LoopField, Divine Vessel
				{
					ItemProp.Vessel := True
					ItemProp.SpecialType := "Divine Vessel"
					Continue
				}
				IfInString, A_LoopField, Eye Jewel
				{
					ItemProp.AbyssJewel := True
					ItemProp.Jewel := True
					Continue
				}
				IfInString, A_LoopField, Cobalt Jewel
				{
					ItemProp.Jewel := True
					Continue
				}
				IfInString, A_LoopField, Crimson Jewel
				{
					ItemProp.Jewel := True
					Continue
				}
				IfInString, A_LoopField, Viridian Jewel
				{
					ItemProp.Jewel := True
					Continue
				}
				IfInString, A_LoopField, Flask
				{
					ItemProp.Flask := True
					Continue
				}
				}
			Continue
		}

		; Get Socket Information
		IfInString, A_LoopField, Sockets:
		{
			StringSplit, RawSocketsArray, A_LoopField, %A_Space%
			ItemProp.RawSockets := RawSocketsArray2 . A_Space . RawSocketsArray3 . A_Space . RawSocketsArray4 . A_Space . RawSocketsArray5 . A_Space . RawSocketsArray6 . A_Space . RawSocketsArray7
			For k, v in StrSplit(ItemProp.RawSockets, " ") 
				{		
				if (v ~= "B") && (v ~= "G") && (v ~= "R")
					ItemProp.Chromatic := True
				Loop, Parse, v
					Counter++
				If (Counter=11)
					{
					ItemProp.6Link:=True
					ItemProp.SpecialType := "6Link"
					}
				Else If (Counter=9)
					{
					ItemProp.5Link:=True
					ItemProp.SpecialType := "5Link"
					}
				Else If (Counter=7)
					{
					ItemProp.4Link:=True
					}
				Else If (Counter=5)
					{
					ItemProp.3Link:=True
					}
				Else If (Counter=3)
					{
					ItemProp.2Link:=True
					}
				Counter:=0
				}
			Loop, parse, A_LoopField
				{
				if (A_LoopField ~= "[-]")
					ItemProp.LinkCount++
				}
			Loop, parse, A_LoopField
				{
				if (A_LoopField ~= "[BGR]")
					ItemProp.Sockets++
				}
			If (ItemProp.Sockets = 6)
				ItemProp.Jeweler:=True
			Continue
		}
		; Get quality
		IfInString, A_LoopField, Quality:
		{
			StringSplit, QualityArray, A_LoopField, %A_Space%, +`%
			ItemProp.Quality := QualityArray2
			Continue
		}
		;Stack size
		IfInString, A_LoopField, Stack Size:
		{
			StringSplit, StackArray, A_LoopField, %A_Space%
			StringSplit, StripStackArray, StackArray3, /
			ItemProp.Stack := StripStackArray1
			ItemProp.StackMax := StripStackArray2
			Continue
		}
		; Flag Unidentified
		IfInString, A_LoopField, Unidentified
		{
			ItemProp.Identified := False
			continue
		}
		; Flag Veiled
		IfInString, A_LoopField, Veiled%A_Space%
		{
			ItemProp.Veiled := True
			ItemProp.SpecialType := "Veiled"
			continue
		}
		; Flag Prophecy
		IfInString, A_LoopField, add this prophecy
		{
			ItemProp.Prophecy := True
			ItemProp.SpecialType := "Prophecy"
			continue
		}
	}
	Return
	}

; Debugging information on Mouse Cursor
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetMouseCoords(){
	GetMouseCoordsCommand:

	MouseGetPos x, y
	PixelGetColor, xycolor , x, y
	TT := "  Mouse X: " . x . "  Mouse Y: " . y . "  XYColor= " . xycolor 
	
	If DebugMessages
		{
		TT := TT . "`n" . "`n"
		GuiStatus()
		TT := TT . "In Hideout:  " . OnHideout . "  On Character:  " . OnChar . "  Chat Open:  " . OnChat . "`n"
		TT := TT . "Inventory open:  " . OnInventory . "  Stash Open:  " . OnStash . "  Vendor Open:  " . OnVendor . "`n" . "`n"
		If ShowItemInfo
			{
			ClipItem(x, y)
			For key, value in ItemProp
				TT := TT . key . ":  " . value . "`n"
			}
		}
	MsgBox %TT%
	If (DebugMessages&&ShowPixelGrid)
		{
		TT := ""

		For c, GridX in InventoryGridX
			{
			For r, GridY in InventoryGridY
				{
				pixelgetcolor, PointColor, GridX, GridY
				If (PointColor=UnIdColor)
					{
					TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Un-Identified" . "`n"
					}
				If (PointColor=IdColor)
					{
					TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Identified" . "`n"
					}
				If (PointColor=MOColor)
					{
					TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Selected Item" . "`n"
					}
				}
			}
		TT := TT . "`n"
		For c, GridX in InventoryGridX
			{
					TT := TT . "  Start of Column:  " . c . "`n"
			For r, GridY in InventoryGridY
				{
				pixelgetcolor, PointColor, GridX, GridY
					TT := TT . "  X-" . GridX . "  Y-" . GridY . "  Color: " . PointColor
				}
			TT := TT . "`n"
			}
		MsgBox %TT%
		}
	Return
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
	critical
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
	}
; Pixelcheck for different parts of the screen to see what your status is in game. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GuiStatus(Fetch:=""){
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
	if (POnHideout=varOnHideout) {
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
	Return
	}

; Main attack and secondary attack Flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AttackFlasks(){
	MainAttackCommand:
		if (AutoFlask=1) {
			GuiStatus()
			If (OnChat||OnHideout||OnVendor||OnStash||!OnChar)
				return
			TriggerFlask(TriggerMainAttack)
			}
		Return	
	SecondaryAttackCommand:
		if (AutoFlask=1) {
			GuiStatus()
			If (OnChat||OnHideout||OnVendor||OnStash||!OnChar)
				return
			TriggerFlask(TriggerSecondaryAttack)
			}
		Return	
	}

; Detonate Mines
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TMineTick(){
	IfWinActive, Path of Exile
		{	
		If (DetonateMines&&!Detonated) 
			DetonateMines()
		}
	Return
	}

; Flask Logic
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TGameTick(){
	IfWinActive, Path of Exile
		{
		; Check what status is your character in the game
		GuiStatus()
		if (OnHideout||!OnChar||OnChat||OnInventory||OnStash||OnVendor) { 
			;GuiUpdate()																									   
			Exit
			}
		
		if (Life=1)	{
			If ((TriggerLife20!="00000")||(AutoQuit&&Quit20)) {
				pixelgetcolor, Life20, vX_Life, vY_Life20 
				if (Life20!=varLife20) {
					if (AutoQuit=1) && (Quit20=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife20)
					}
				}
			If ((TriggerLife30!="00000")||(AutoQuit&&Quit30)) {
				pixelgetcolor, Life30, vX_Life, vY_Life30 
				if (Life30!=varLife30) {
					if (AutoQuit=1) && (Quit30=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife30)
					}
				}
			If ((TriggerLife40!="00000")||(AutoQuit&&Quit40)) {
				pixelgetcolor, Life40, vX_Life, vY_Life40 
				if (Life40!=varLife40) {
					if (AutoQuit=1) && (Quit40=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife40)
					}
				}
			If (TriggerLife50!="00000") {
				pixelgetcolor, Life50, vX_Life, vY_Life50
				if (Life50!=varLife50) {
					TriggerFlask(TriggerLife50)
					}
				}
			If (TriggerLife60!="00000") {
				pixelgetcolor, Life60, vX_Life, vY_Life60
				if (Life60!=varLife60) {
					TriggerFlask(TriggerLife60)
					}
				}
			If (TriggerLife70!="00000") {
				pixelgetcolor, Life70, vX_Life, vY_Life70
				if (Life70!=varLife70) {
					TriggerFlask(TriggerLife70)
					}
				}
			If (TriggerLife80!="00000") {
				pixelgetcolor, Life80, vX_Life, vY_Life80
				if (Life80!=varLife80) {
					TriggerFlask(TriggerLife80)
					}
				}
			If (TriggerLife90!="00000") {
				pixelgetcolor, Life90, vX_Life, vY_Life90
				if (Life90!=varLife90) {
					TriggerFlask(TriggerLife90)
					}
				}
			}
		
		if (Hybrid=1) {
			If ((TriggerLife20!="00000")||(AutoQuit&&Quit20)) {
				pixelgetcolor, Life20, vX_Life, vY_Life20 
				if (Life20!=varLife20) {
					if (AutoQuit=1) && (Quit20=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife20)
					}
				}
			If ((TriggerLife30!="00000")||(AutoQuit&&Quit30)) {
				pixelgetcolor, Life30, vX_Life, vY_Life30 
				if (Life30!=varLife30) {
					if (AutoQuit=1) && (Quit30=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife30)
					}
				}
			If ((TriggerLife40!="00000")||(AutoQuit&&Quit40)) {
				pixelgetcolor, Life40, vX_Life, vY_Life40 
				if (Life40!=varLife40) {
					if (AutoQuit=1) && (Quit40=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerLife40)
					}
				}
			If (TriggerLife50!="00000") {
				pixelgetcolor, Life50, vX_Life, vY_Life50
				if (Life50!=varLife50) {
					TriggerFlask(TriggerLife50)
					}
				}
			If (TriggerLife60!="00000") {
				pixelgetcolor, Life60, vX_Life, vY_Life60
				if (Life60!=varLife60) {
					TriggerFlask(TriggerLife60)
					}
				}
			If (TriggerLife70!="00000") {
				pixelgetcolor, Life70, vX_Life, vY_Life70
				if (Life70!=varLife70) {
					TriggerFlask(TriggerLife70)
					}
				}
			If (TriggerLife80!="00000") {
				pixelgetcolor, Life80, vX_Life, vY_Life80
				if (Life80!=varLife80) {
					TriggerFlask(TriggerLife80)
					}
				}
			If (TriggerLife90!="00000") {
				pixelgetcolor, Life90, vX_Life, vY_Life90
				if (Life90!=varLife90) {
					TriggerFlask(TriggerLife90)
					}
				}
			If (TriggerES20!="00000") {
				pixelgetcolor, ES20, vX_ES, vY_ES20 
				if (ES20!=varES20) {
					TriggerFlask(TriggerES20)
					}
				}
			If (TriggerES30!="00000") {
				pixelgetcolor, ES30, vX_ES, vY_ES30 
				if (ES30!=varES30) {
					TriggerFlask(TriggerES30)
					}
				}
			If (TriggerES40!="00000") {
				pixelgetcolor, ES40, vX_ES, vY_ES40 
				if (ES40!=varES40) {
					TriggerFlask(TriggerES40)
					}
				}
			If (TriggerES50!="00000") {
				pixelgetcolor, ES50, vX_ES, vY_ES50
				if (ES50!=varES50) {
					TriggerFlask(TriggerES50)
					}
				}
			If (TriggerES60!="00000") {
				pixelgetcolor, ES60, vX_ES, vY_ES60
				if (ES60!=varES60) {
					TriggerFlask(TriggerES60)
					}
				}
			If (TriggerES70!="00000") {
				pixelgetcolor, ES70, vX_ES, vY_ES70
				if (ES70!=varES70) {
					TriggerFlask(TriggerES70)
					}
				}
			If (TriggerES80!="00000") {
				pixelgetcolor, ES80, vX_ES, vY_ES80
				if (ES80!=varES80) {
					TriggerFlask(TriggerES80)
					}
				}
			If (TriggerES90!="00000") {
				pixelgetcolor, ES90, vX_ES, vY_ES90
				if (ES90!=varES90) {
					TriggerFlask(TriggerES90)
					}
				}
			}
		
		if (Ci=1) {
			If ((TriggerES20!="00000")||(AutoQuit&&Quit20)) {
				pixelgetcolor, ES20, vX_ES, vY_ES20 
				if (ES20!=varES20) {
					if (AutoQuit=1) && (Quit20=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerES20)
					}
				}
			If ((TriggerES30!="00000")||(AutoQuit&&Quit30)) {
				pixelgetcolor, ES30, vX_ES, vY_ES30 
				if (ES30!=varES30) {
					if (AutoQuit=1) && (Quit30=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerES30)
					}
				}
			If ((TriggerES40!="00000")||(AutoQuit&&Quit40)) {
				pixelgetcolor, ES40, vX_ES, vY_ES40 
				if (ES40!=varES40) {
					if (AutoQuit=1) && (Quit40=1) {
						GuiStatus("OnChar")
						if (OnChar)
							LogoutCommand()
						Exit
						}
					TriggerFlask(TriggerES40)
					}
				}
			If ((TriggerES50!="00000")||(YesVaalDiscipline)) {
				pixelgetcolor, ES50, vX_ES, vY_ES50
				if (ES50!=varES50) {
					If (YesVaalDiscipline)
						TriggerUtility("VaalDiscipline")
					If (TriggerES50!="00000")
						TriggerFlask(TriggerES50)
					}
				}
			If (TriggerES60!="00000") {
				pixelgetcolor, ES60, vX_ES, vY_ES60
				if (ES60!=varES60) {
					TriggerFlask(TriggerES60)
					}
				}
			If (TriggerES70!="00000") {
				pixelgetcolor, ES70, vX_ES, vY_ES70
				if (ES70!=varES70) {
					TriggerFlask(TriggerES70)
					}
				}
			If (TriggerES80!="00000") {
				pixelgetcolor, ES80, vX_ES, vY_ES80
				if (ES80!=varES80) {
					TriggerFlask(TriggerES80)
					}
				}
			If (TriggerES90!="00000") {
				pixelgetcolor, ES90, vX_ES, vY_ES90
				if (ES90!=varES90) {
					TriggerFlask(TriggerES90)
					}
				}
			}
			
		If (TriggerMana10!="00000") {
			pixelgetcolor, Mana10, vX_Mana, vY_Mana10
			if (Mana10!=varMana10) {
				TriggerMana(TriggerMana10)
				}
			}

		GuiUpdate()
		}
	Return
	}
; Trigger named Utility
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TriggerUtility(Utility:=""){
	If !(Utility="") {
		If (!OnCooldown%Utility%)&&(Yes%Utility%){
			key:=utility%Utility%
			Send %key%
			OnCooldown%Utility%:=1
			Cooldown:=Cooldown%Utility%
			SetTimer, Timer%Utility%, %Cooldown%
			}
		} Else
			MsgBox, No utility passed to function
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

;Clamp Value function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Clamp( Val, Min, Max) {
  If Val < Min
	Val := Min
  If Val > Max
	Val := Max
	Return
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

; Utility Timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerVaalDiscipline:
		OnCooldownVaalDiscipline := 0
		settimer,TimerVaalDiscipline,delete
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
			IniRead, YesMapUnid, settings.ini, General, YesMapUnid, 1
			IniRead, Latency, settings.ini, General, Latency, 1
			IniRead, ShowOnStart, settings.ini, General, ShowOnStart, 1
			IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
			IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
			IniRead, Steam, settings.ini, General, Steam, 1
			IniRead, HighBits, settings.ini, General, HighBits, 1

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
			IniRead, StashTabTimelessSplinter, settings.ini, Stash Tab, StashTabTimelessSplinter, 1
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
			IniRead, StashTabYesTimelessSplinter, settings.ini, Stash Tab, StashTabYesTimelessSplinter, 1
			IniRead, StashTabYesFossil, settings.ini, Stash Tab, StashTabYesFossil, 1
			IniRead, StashTabYesResonator, settings.ini, Stash Tab, StashTabYesResonator, 1
			IniRead, StashTabYesProphecy, settings.ini, Stash Tab, StashTabYesProphecy, 1
			
		;Failsafe Colors
			IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0x161114
			IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar, 0x4F6980
			IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat, 0x3B6288
			IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory, 0x8CC6DD
			IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash, 0x9BD6E7
			IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor, 0x7BB1CC
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
			IniRead, YesPhaseRun, settings.ini, Utility Buttons, YesPhaseRun, 1
			IniRead, YesVaalDiscipline, settings.ini, Utility Buttons, YesVaalDiscipline, 1

		;Utility Cooldowns
			IniRead, CooldownPhaseRun, settings.ini, Utility Cooldowns, CooldownPhaseRun, 5000
			IniRead, CooldownVaalDiscipline, settings.ini, Utility Cooldowns, CooldownVaalDiscipline, 60000
			
		;Utility Keys
			IniRead, utilityPhaseRun, settings.ini, Utility Keys, PhaseRun, e
			IniRead, utilityVaalDiscipline, settings.ini, Utility Keys, VaalDiscipline, r

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
			IniRead, StockPortal, settings.ini, Coordinates, StockPortal, 1
			IniRead, StockWisdom, settings.ini, Coordinates, StockWisdom, 1

		
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
				hotkey,% hotkeyGetMouseCoords, GetMouseCoordsCommand, Off
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
				hotkey,% hotkeyGetMouseCoords, GetMouseCoordsCommand, On
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
				;GuiControl,, guiSettings, Settings:%hotkeyOptions%
				} else {
				hotkey,!F10, optionsCommand, On
				msgbox You dont have set the GUI hotkey!`nPlease hit Alt+F10 to open up the GUI and set your hotkey.
				;GuiControl,, guiSettings, Settings:%hotkeyOptions%
				}
		checkActiveType()
		Return
		}

	submit(){  
		updateEverything:
		global
		critical
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
			IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
			IniWrite, %Latency%, settings.ini, General, Latency
			IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
			IniWrite, %Steam%, settings.ini, General, Steam
			IniWrite, %HighBits%, settings.ini, General, HighBits
			IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
		
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

		;Utility Buttons
			IniWrite, %YesPhaseRun%, Settings.ini, Utility Buttons, YesPhaseRun
			IniWrite, %YesVaalDiscipline%, Settings.ini, Utility Buttons, YesVaalDiscipline

		;Utility Keys
			IniWrite, %utilityPhaseRun%, settings.ini, Utility Keys, PhaseRun
			IniWrite, %utilityVaalDiscipline%, settings.ini, Utility Keys, VaalDiscipline
				
		;Utility Cooldowns
			IniWrite, %CooldownPhaseRun%, settings.ini, Utility Cooldowns, CooldownPhaseRun
			IniWrite, %CooldownVaalDiscipline%, settings.ini, Utility Cooldowns, CooldownVaalDiscipline

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
			IniWrite, %StashTabTimelessSplinter%, settings.ini, Stash Tab, StashTabTimelessSplinter
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
			IniWrite, %StashTabYesTimelessSplinter%, settings.ini, Stash Tab, StashTabYesTimelessSplinter
			IniWrite, %StashTabYesFossil%, settings.ini, Stash Tab, StashTabYesFossil
			IniWrite, %StashTabYesResonator%, settings.ini, Stash Tab, StashTabYesResonator
			IniWrite, %StashTabYesProphecy%, settings.ini, Stash Tab, StashTabYesProphecy
		
		;Attack Flasks
			IniWrite, %MainAttackbox1%%MainAttackbox2%%MainAttackbox3%%MainAttackbox4%%MainAttackbox5%, settings.ini, Attack Triggers, TriggerMainAttack
			IniWrite, %SecondaryAttackbox1%%SecondaryAttackbox2%%SecondaryAttackbox3%%SecondaryAttackbox4%%SecondaryAttackbox5%, settings.ini, Attack Triggers, TriggerSecondaryAttack
		
		;Quicksilver Flasks
			IniWrite, %TriggerQuicksilverDelay%, settings.ini, Quicksilver, TriggerQuicksilverDelay
			IniWrite, %Radiobox1QS%%Radiobox2QS%%Radiobox3QS%%Radiobox4QS%%Radiobox5QS%, settings.ini, Quicksilver, TriggerQuicksilver
			IniWrite, %Radiobox1QS%, settings.ini, Quicksilver, QuicksilverSlot1
			IniWrite, %Radiobox2QS%, settings.ini, Quicksilver, QuicksilverSlot2
			IniWrite, %Radiobox3QS%, settings.ini, Quicksilver, QuicksilverSlot3
			IniWrite, %Radiobox4QS%, settings.ini, Quicksilver, QuicksilverSlot4
			IniWrite, %Radiobox5QS%, settings.ini, Quicksilver, QuicksilverSlot5
		
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
		
		readFromFile()
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
			
			IniRead, Test, settings.ini, Profile%Profile%, Radiobox1Life20
			If (Test = "ERROR")
				Exit
		;Life Flasks
		
			IniRead, Radiobox1Life20, settings.ini, Profile%Profile%, Radiobox1Life20
				GuiControl, , Radiobox1Life20, %Radiobox1Life20%
			IniRead, Radiobox2Life20, settings.ini, Profile%Profile%, Radiobox2Life20
				GuiControl, , Radiobox2Life20, %Radiobox2Life20%
			IniRead, Radiobox3Life20, settings.ini, Profile%Profile%, Radiobox3Life20
				GuiControl, , Radiobox3Life20, %Radiobox3Life20%
			IniRead, Radiobox4Life20, settings.ini, Profile%Profile%, Radiobox4Life20
				GuiControl, , Radiobox4Life20, %Radiobox4Life20%
			IniRead, Radiobox5Life20, settings.ini, Profile%Profile%, Radiobox5Life20
				GuiControl, , Radiobox5Life20, %Radiobox5Life20%

			IniRead, Radiobox1Life30, settings.ini, Profile%Profile%, Radiobox1Life30
				GuiControl, , Radiobox1Life30, %Radiobox1Life30%
			IniRead, Radiobox2Life30, settings.ini, Profile%Profile%, Radiobox2Life30
				GuiControl, , Radiobox2Life30, %Radiobox2Life30%
			IniRead, Radiobox3Life30, settings.ini, Profile%Profile%, Radiobox3Life30
				GuiControl, , Radiobox3Life30, %Radiobox3Life30%
			IniRead, Radiobox4Life30, settings.ini, Profile%Profile%, Radiobox4Life30
				GuiControl, , Radiobox4Life30, %Radiobox4Life30%
			IniRead, Radiobox5Life30, settings.ini, Profile%Profile%, Radiobox5Life30
				GuiControl, , Radiobox5Life30, %Radiobox5Life30%

			IniRead, Radiobox1Life40, settings.ini, Profile%Profile%, Radiobox1Life40
				GuiControl, , Radiobox1Life40, %Radiobox1Life40%
			IniRead, Radiobox2Life40, settings.ini, Profile%Profile%, Radiobox2Life40
				GuiControl, , Radiobox2Life40, %Radiobox2Life40%
			IniRead, Radiobox3Life40, settings.ini, Profile%Profile%, Radiobox3Life40
				GuiControl, , Radiobox3Life40, %Radiobox3Life40%
			IniRead, Radiobox4Life40, settings.ini, Profile%Profile%, Radiobox4Life40
				GuiControl, , Radiobox4Life40, %Radiobox4Life40%
			IniRead, Radiobox5Life40, settings.ini, Profile%Profile%, Radiobox5Life40
				GuiControl, , Radiobox5Life40, %Radiobox5Life40%

			IniRead, Radiobox1Life50, settings.ini, Profile%Profile%, Radiobox1Life50
				GuiControl, , Radiobox1Life50, %Radiobox1Life50%
			IniRead, Radiobox2Life50, settings.ini, Profile%Profile%, Radiobox2Life50
				GuiControl, , Radiobox2Life50, %Radiobox2Life50%
			IniRead, Radiobox3Life50, settings.ini, Profile%Profile%, Radiobox3Life50
				GuiControl, , Radiobox3Life50, %Radiobox3Life50%
			IniRead, Radiobox4Life50, settings.ini, Profile%Profile%, Radiobox4Life50
				GuiControl, , Radiobox4Life50, %Radiobox4Life50%
			IniRead, Radiobox5Life50, settings.ini, Profile%Profile%, Radiobox5Life50
				GuiControl, , Radiobox5Life50, %Radiobox5Life50%

			IniRead, Radiobox1Life50, settings.ini, Profile%Profile%, Radiobox1Life50
				GuiControl, , Radiobox1Life50, %Radiobox1Life50%
			IniRead, Radiobox2Life50, settings.ini, Profile%Profile%, Radiobox2Life50
				GuiControl, , Radiobox2Life50, %Radiobox2Life50%
			IniRead, Radiobox3Life50, settings.ini, Profile%Profile%, Radiobox3Life50
				GuiControl, , Radiobox3Life50, %Radiobox3Life50%
			IniRead, Radiobox4Life50, settings.ini, Profile%Profile%, Radiobox4Life50
				GuiControl, , Radiobox4Life50, %Radiobox4Life50%
			IniRead, Radiobox5Life50, settings.ini, Profile%Profile%, Radiobox5Life50
				GuiControl, , Radiobox5Life50, %Radiobox5Life50%

			IniRead, Radiobox1Life60, settings.ini, Profile%Profile%, Radiobox1Life60
				GuiControl, , Radiobox1Life60, %Radiobox1Life60%
			IniRead, Radiobox2Life60, settings.ini, Profile%Profile%, Radiobox2Life60
				GuiControl, , Radiobox2Life60, %Radiobox2Life60%
			IniRead, Radiobox3Life60, settings.ini, Profile%Profile%, Radiobox3Life60
				GuiControl, , Radiobox3Life60, %Radiobox3Life60%
			IniRead, Radiobox4Life60, settings.ini, Profile%Profile%, Radiobox4Life60
				GuiControl, , Radiobox4Life60, %Radiobox4Life60%
			IniRead, Radiobox5Life60, settings.ini, Profile%Profile%, Radiobox5Life60
				GuiControl, , Radiobox5Life60, %Radiobox5Life60%

			IniRead, Radiobox1Life70, settings.ini, Profile%Profile%, Radiobox1Life70
				GuiControl, , Radiobox1Life70, %Radiobox1Life70%
			IniRead, Radiobox2Life70, settings.ini, Profile%Profile%, Radiobox2Life70
				GuiControl, , Radiobox2Life70, %Radiobox2Life70%
			IniRead, Radiobox3Life70, settings.ini, Profile%Profile%, Radiobox3Life70
				GuiControl, , Radiobox3Life70, %Radiobox3Life70%
			IniRead, Radiobox4Life70, settings.ini, Profile%Profile%, Radiobox4Life70
				GuiControl, , Radiobox4Life70, %Radiobox4Life70%
			IniRead, Radiobox5Life70, settings.ini, Profile%Profile%, Radiobox5Life70
				GuiControl, , Radiobox5Life70, %Radiobox5Life70%

			IniRead, Radiobox1Life80, settings.ini, Profile%Profile%, Radiobox1Life80
				GuiControl, , Radiobox1Life80, %Radiobox1Life80%
			IniRead, Radiobox2Life80, settings.ini, Profile%Profile%, Radiobox2Life80
				GuiControl, , Radiobox2Life80, %Radiobox2Life80%
			IniRead, Radiobox3Life80, settings.ini, Profile%Profile%, Radiobox3Life80
				GuiControl, , Radiobox3Life80, %Radiobox3Life80%
			IniRead, Radiobox4Life80, settings.ini, Profile%Profile%, Radiobox4Life80
				GuiControl, , Radiobox4Life80, %Radiobox4Life80%
			IniRead, Radiobox5Life80, settings.ini, Profile%Profile%, Radiobox5Life80
				GuiControl, , Radiobox5Life80, %Radiobox5Life80%

			IniRead, Radiobox1Life90, settings.ini, Profile%Profile%, Radiobox1Life90
				GuiControl, , Radiobox1Life90, %Radiobox1Life90%
			IniRead, Radiobox2Life90, settings.ini, Profile%Profile%, Radiobox2Life90
				GuiControl, , Radiobox2Life90, %Radiobox2Life90%
			IniRead, Radiobox3Life90, settings.ini, Profile%Profile%, Radiobox3Life90
				GuiControl, , Radiobox3Life90, %Radiobox3Life90%
			IniRead, Radiobox4Life90, settings.ini, Profile%Profile%, Radiobox4Life90
				GuiControl, , Radiobox4Life90, %Radiobox4Life90%
			IniRead, Radiobox5Life90, settings.ini, Profile%Profile%, Radiobox5Life90
				GuiControl, , Radiobox5Life90, %Radiobox5Life90%

			IniRead, RadioUncheck1Life, settings.ini, Profile%Profile%, RadioUncheck1Life
				GuiControl, , RadioUncheck1Life, %RadioUncheck1Life%
			IniRead, RadioUncheck2Life, settings.ini, Profile%Profile%, RadioUncheck2Life
				GuiControl, , RadioUncheck2Life, %RadioUncheck2Life%
			IniRead, RadioUncheck3Life, settings.ini, Profile%Profile%, RadioUncheck3Life
				GuiControl, , RadioUncheck3Life, %RadioUncheck3Life%
			IniRead, RadioUncheck4Life, settings.ini, Profile%Profile%, RadioUncheck4Life
				GuiControl, , RadioUncheck4Life, %RadioUncheck4Life%
			IniRead, RadioUncheck5Life, settings.ini, Profile%Profile%, RadioUncheck5Life
				GuiControl, , RadioUncheck5Life, %RadioUncheck5Life%

		;ES Flasks
			IniRead, Radiobox1ES20, settings.ini, Profile%Profile%, Radiobox1ES20
				GuiControl, , Radiobox1ES20, %Radiobox1ES20%
			IniRead, Radiobox2ES20, settings.ini, Profile%Profile%, Radiobox2ES20
				GuiControl, , Radiobox2ES20, %Radiobox2ES20%
			IniRead, Radiobox3ES20, settings.ini, Profile%Profile%, Radiobox3ES20
				GuiControl, , Radiobox3ES20, %Radiobox3ES20%
			IniRead, Radiobox4ES20, settings.ini, Profile%Profile%, Radiobox4ES20
				GuiControl, , Radiobox4ES20, %Radiobox4ES20%
			IniRead, Radiobox5ES20, settings.ini, Profile%Profile%, Radiobox5ES20
				GuiControl, , Radiobox5ES20, %Radiobox5ES20%

			IniRead, Radiobox1ES30, settings.ini, Profile%Profile%, Radiobox1ES30
				GuiControl, , Radiobox1ES30, %Radiobox1ES30%
			IniRead, Radiobox2ES30, settings.ini, Profile%Profile%, Radiobox2ES30
				GuiControl, , Radiobox2ES30, %Radiobox2ES30%
			IniRead, Radiobox3ES30, settings.ini, Profile%Profile%, Radiobox3ES30
				GuiControl, , Radiobox3ES30, %Radiobox3ES30%
			IniRead, Radiobox4ES30, settings.ini, Profile%Profile%, Radiobox4ES30
				GuiControl, , Radiobox4ES30, %Radiobox4ES30%
			IniRead, Radiobox5ES30, settings.ini, Profile%Profile%, Radiobox5ES30
				GuiControl, , Radiobox5ES30, %Radiobox5ES30%

			IniRead, Radiobox1ES40, settings.ini, Profile%Profile%, Radiobox1ES40
				GuiControl, , Radiobox1ES40, %Radiobox1ES40%
			IniRead, Radiobox2ES40, settings.ini, Profile%Profile%, Radiobox2ES40
				GuiControl, , Radiobox2ES40, %Radiobox2ES40%
			IniRead, Radiobox3ES40, settings.ini, Profile%Profile%, Radiobox3ES40
				GuiControl, , Radiobox3ES40, %Radiobox3ES40%
			IniRead, Radiobox4ES40, settings.ini, Profile%Profile%, Radiobox4ES40
				GuiControl, , Radiobox4ES40, %Radiobox4ES40%
			IniRead, Radiobox5ES40, settings.ini, Profile%Profile%, Radiobox5ES40
				GuiControl, , Radiobox5ES40, %Radiobox5ES40%

			IniRead, Radiobox1ES50, settings.ini, Profile%Profile%, Radiobox1ES50
				GuiControl, , Radiobox1ES50, %Radiobox1ES50%
			IniRead, Radiobox2ES50, settings.ini, Profile%Profile%, Radiobox2ES50
				GuiControl, , Radiobox2ES50, %Radiobox2ES50%
			IniRead, Radiobox3ES50, settings.ini, Profile%Profile%, Radiobox3ES50
				GuiControl, , Radiobox3ES50, %Radiobox3ES50%
			IniRead, Radiobox4ES50, settings.ini, Profile%Profile%, Radiobox4ES50
				GuiControl, , Radiobox4ES50, %Radiobox4ES50%
			IniRead, Radiobox5ES50, settings.ini, Profile%Profile%, Radiobox5ES50
				GuiControl, , Radiobox5ES50, %Radiobox5ES50%

			IniRead, Radiobox1ES50, settings.ini, Profile%Profile%, Radiobox1ES50
				GuiControl, , Radiobox1ES50, %Radiobox1ES50%
			IniRead, Radiobox2ES50, settings.ini, Profile%Profile%, Radiobox2ES50
				GuiControl, , Radiobox2ES50, %Radiobox2ES50%
			IniRead, Radiobox3ES50, settings.ini, Profile%Profile%, Radiobox3ES50
				GuiControl, , Radiobox3ES50, %Radiobox3ES50%
			IniRead, Radiobox4ES50, settings.ini, Profile%Profile%, Radiobox4ES50
				GuiControl, , Radiobox4ES50, %Radiobox4ES50%
			IniRead, Radiobox5ES50, settings.ini, Profile%Profile%, Radiobox5ES50
				GuiControl, , Radiobox5ES50, %Radiobox5ES50%

			IniRead, Radiobox1ES60, settings.ini, Profile%Profile%, Radiobox1ES60
				GuiControl, , Radiobox1ES60, %Radiobox1ES60%
			IniRead, Radiobox2ES60, settings.ini, Profile%Profile%, Radiobox2ES60
				GuiControl, , Radiobox2ES60, %Radiobox2ES60%
			IniRead, Radiobox3ES60, settings.ini, Profile%Profile%, Radiobox3ES60
				GuiControl, , Radiobox3ES60, %Radiobox3ES60%
			IniRead, Radiobox4ES60, settings.ini, Profile%Profile%, Radiobox4ES60
				GuiControl, , Radiobox4ES60, %Radiobox4ES60%
			IniRead, Radiobox5ES60, settings.ini, Profile%Profile%, Radiobox5ES60
				GuiControl, , Radiobox5ES60, %Radiobox5ES60%

			IniRead, Radiobox1ES70, settings.ini, Profile%Profile%, Radiobox1ES70
				GuiControl, , Radiobox1ES70, %Radiobox1ES70%
			IniRead, Radiobox2ES70, settings.ini, Profile%Profile%, Radiobox2ES70
				GuiControl, , Radiobox2ES70, %Radiobox2ES70%
			IniRead, Radiobox3ES70, settings.ini, Profile%Profile%, Radiobox3ES70
				GuiControl, , Radiobox3ES70, %Radiobox3ES70%
			IniRead, Radiobox4ES70, settings.ini, Profile%Profile%, Radiobox4ES70
				GuiControl, , Radiobox4ES70, %Radiobox4ES70%
			IniRead, Radiobox5ES70, settings.ini, Profile%Profile%, Radiobox5ES70
				GuiControl, , Radiobox5ES70, %Radiobox5ES70%

			IniRead, Radiobox1ES80, settings.ini, Profile%Profile%, Radiobox1ES80
				GuiControl, , Radiobox1ES80, %Radiobox1ES80%
			IniRead, Radiobox2ES80, settings.ini, Profile%Profile%, Radiobox2ES80
				GuiControl, , Radiobox2ES80, %Radiobox2ES80%
			IniRead, Radiobox3ES80, settings.ini, Profile%Profile%, Radiobox3ES80
				GuiControl, , Radiobox3ES80, %Radiobox3ES80%
			IniRead, Radiobox4ES80, settings.ini, Profile%Profile%, Radiobox4ES80
				GuiControl, , Radiobox4ES80, %Radiobox4ES80%
			IniRead, Radiobox5ES80, settings.ini, Profile%Profile%, Radiobox5ES80
				GuiControl, , Radiobox5ES80, %Radiobox5ES80%

			IniRead, Radiobox1ES90, settings.ini, Profile%Profile%, Radiobox1ES90
				GuiControl, , Radiobox1ES90, %Radiobox1ES90%
			IniRead, Radiobox2ES90, settings.ini, Profile%Profile%, Radiobox2ES90
				GuiControl, , Radiobox2ES90, %Radiobox2ES90%
			IniRead, Radiobox3ES90, settings.ini, Profile%Profile%, Radiobox3ES90
				GuiControl, , Radiobox3ES90, %Radiobox3ES90%
			IniRead, Radiobox4ES90, settings.ini, Profile%Profile%, Radiobox4ES90
				GuiControl, , Radiobox4ES90, %Radiobox4ES90%
			IniRead, Radiobox5ES90, settings.ini, Profile%Profile%, Radiobox5ES90
				GuiControl, , Radiobox5ES90, %Radiobox5ES90%

			IniRead, RadioUncheck1ES, settings.ini, Profile%Profile%, RadioUncheck1ES
				GuiControl, , RadioUncheck1ES, %RadioUncheck1ES%
			IniRead, RadioUncheck2ES, settings.ini, Profile%Profile%, RadioUncheck2ES
				GuiControl, , RadioUncheck2ES, %RadioUncheck2ES%
			IniRead, RadioUncheck3ES, settings.ini, Profile%Profile%, RadioUncheck3ES
				GuiControl, , RadioUncheck3ES, %RadioUncheck3ES%
			IniRead, RadioUncheck4ES, settings.ini, Profile%Profile%, RadioUncheck4ES
				GuiControl, , RadioUncheck4ES, %RadioUncheck4ES%
			IniRead, RadioUncheck5ES, settings.ini, Profile%Profile%, RadioUncheck5ES
				GuiControl, , RadioUncheck5ES, %RadioUncheck5ES%
			
		;Mana Flasks
			IniRead, Radiobox1Mana10, settings.ini, Profile%Profile%, Radiobox1Mana10
				GuiControl, , Radiobox1Mana10, %Radiobox1Mana10%
			IniRead, Radiobox2Mana10, settings.ini, Profile%Profile%, Radiobox2Mana10
				GuiControl, , Radiobox2Mana10, %Radiobox2Mana10%
			IniRead, Radiobox3Mana10, settings.ini, Profile%Profile%, Radiobox3Mana10
				GuiControl, , Radiobox3Mana10, %Radiobox3Mana10%
			IniRead, Radiobox4Mana10, settings.ini, Profile%Profile%, Radiobox4Mana10
				GuiControl, , Radiobox4Mana10, %Radiobox4Mana10%
			IniRead, Radiobox5Mana10, settings.ini, Profile%Profile%, Radiobox5Mana10
				GuiControl, , Radiobox5Mana10, %Radiobox5Mana10%

		;Flask Cooldowns
			IniRead, CooldownFlask1, settings.ini, Profile%Profile%, CooldownFlask1
				GuiControl, , CooldownFlask1, %CooldownFlask1%
			IniRead, CooldownFlask2, settings.ini, Profile%Profile%, CooldownFlask2
				GuiControl, , CooldownFlask2, %CooldownFlask2%
			IniRead, CooldownFlask3, settings.ini, Profile%Profile%, CooldownFlask3
				GuiControl, , CooldownFlask3, %CooldownFlask3%
			IniRead, CooldownFlask4, settings.ini, Profile%Profile%, CooldownFlask4
				GuiControl, , CooldownFlask4, %CooldownFlask4%
			IniRead, CooldownFlask5, settings.ini, Profile%Profile%, CooldownFlask5	
				GuiControl, , CooldownFlask5, %CooldownFlask5%
			
		;Attack Flasks
			IniRead, MainAttackbox1, settings.ini, Profile%Profile%, MainAttackbox1
				GuiControl, , MainAttackbox1, %MainAttackbox1%
			IniRead, MainAttackbox2, settings.ini, Profile%Profile%, MainAttackbox2
				GuiControl, , MainAttackbox2, %MainAttackbox2%
			IniRead, MainAttackbox3, settings.ini, Profile%Profile%, MainAttackbox3
				GuiControl, , MainAttackbox3, %MainAttackbox3%
			IniRead, MainAttackbox4, settings.ini, Profile%Profile%, MainAttackbox4
				GuiControl, , MainAttackbox4, %MainAttackbox4%
			IniRead, MainAttackbox5, settings.ini, Profile%Profile%, MainAttackbox5
				GuiControl, , MainAttackbox5, %MainAttackbox5%

			IniRead, SecondaryAttackbox1, settings.ini, Profile%Profile%, SecondaryAttackbox1
				GuiControl, , SecondaryAttackbox1, %SecondaryAttackbox1%
			IniRead, SecondaryAttackbox2, settings.ini, Profile%Profile%, SecondaryAttackbox2
				GuiControl, , SecondaryAttackbox2, %SecondaryAttackbox2%
			IniRead, SecondaryAttackbox3, settings.ini, Profile%Profile%, SecondaryAttackbox3
				GuiControl, , SecondaryAttackbox3, %SecondaryAttackbox3%
			IniRead, SecondaryAttackbox4, settings.ini, Profile%Profile%, SecondaryAttackbox4
				GuiControl, , SecondaryAttackbox4, %SecondaryAttackbox4%
			IniRead, SecondaryAttackbox5, settings.ini, Profile%Profile%, SecondaryAttackbox5
				GuiControl, , SecondaryAttackbox5, %SecondaryAttackbox5%
		
		;Attack Keys
			IniRead, hotkeyMainAttack, settings.ini, Profile%Profile%, MainAttack, RButton
				GuiControl, , hotkeyMainAttack, %hotkeyMainAttack%
			IniRead, hotkeySecondaryAttack, settings.ini, Profile%Profile%, SecondaryAttack, W
				GuiControl, , hotkeySecondaryAttack, %hotkeySecondaryAttack%
		
		;Quicksilver Flasks
			IniRead, TriggerQuicksilverDelay, settings.ini, Profile%Profile%, TriggerQuicksilverDelay
				GuiControl, , TriggerQuicksilverDelay, %TriggerQuicksilverDelay%
			IniRead, Radiobox1QS, settings.ini, Profile%Profile%, QuicksilverSlot1
				GuiControl, , Radiobox1QS, %Radiobox1QS%
			IniRead, Radiobox2QS, settings.ini, Profile%Profile%, QuicksilverSlot2
				GuiControl, , Radiobox2QS, %Radiobox2QS%
			IniRead, Radiobox3QS, settings.ini, Profile%Profile%, QuicksilverSlot3
				GuiControl, , Radiobox3QS, %Radiobox3QS%
			IniRead, Radiobox4QS, settings.ini, Profile%Profile%, QuicksilverSlot4
				GuiControl, , Radiobox4QS, %Radiobox4QS%
			IniRead, Radiobox5QS, settings.ini, Profile%Profile%, QuicksilverSlot5
				GuiControl, , Radiobox5QS, %Radiobox5QS%
			
		;CharacterTypeCheck
			IniRead, RadioLife, settings.ini, Profile%Profile%, Life
				GuiControl, , RadioLife, %RadioLife%
			IniRead, RadioHybrid, settings.ini, Profile%Profile%, Hybrid	
				GuiControl, , RadioHybrid, %RadioHybrid%
			IniRead, RadioCi, settings.ini, Profile%Profile%, Ci	
				GuiControl, , RadioCi, %RadioCi%
		
		;AutoQuit
			IniRead, RadioQuit20, settings.ini, Profile%Profile%, Quit20
				GuiControl, , RadioQuit20, %RadioQuit20%
			IniRead, RadioQuit30, settings.ini, Profile%Profile%, Quit30
				GuiControl, , RadioQuit30, %RadioQuit30%
			IniRead, RadioQuit40, settings.ini, Profile%Profile%, Quit40
				GuiControl, , RadioQuit40, %RadioQuit40%
			IniRead, RadioCritQuit, settings.ini, Profile%Profile%, CritQuit
				GuiControl, , RadioCritQuit, %RadioCritQuit%
			IniRead, RadioNormalQuit, settings.ini, Profile%Profile%, NormalQuit
				GuiControl, , RadioNormalQuit, %RadioNormalQuit%
		
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
			GuiControl,, otkeyGetMouseCoords, %otkeyGetMouseCoords%
			GuiControl,, hotkeyQuickPortal, %hotkeyQuickPortal%
			GuiControl,, hotkeyGemSwap, %hotkeyGemSwap%
			GuiControl,, vhotkeyPopFlasks, %vhotkeyPopFlasks%
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
		IniWrite, %StashTabTimelessSplinter%, settings.ini, Stash Tab, StashTabTimelessSplinter
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
		IniWrite, %StashTabYesTimelessSplinter%, settings.ini, Stash Tab, StashTabYesTimelessSplinter
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
		IniWrite, %YesMapUnid%, settings.ini, General, YesMapUnid
		IniWrite, %Latency%, settings.ini, General, Latency
		IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
		IniWrite, %YesStashKeys%, settings.ini, General, YesStashKeys
		IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
		IniWrite, %Steam%, settings.ini, General, Steam
		IniWrite, %HighBits%, settings.ini, General, HighBits

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
			IniWrite, %YesPhaseRun%, Settings.ini, Utility Buttons, YesPhaseRun
			IniWrite, %YesVaalDiscipline%, Settings.ini, Utility Buttons, YesVaalDiscipline

		;Utility Keys
			IniWrite, %utilityPhaseRun%, settings.ini, Utility Keys, PhaseRun
			IniWrite, %utilityVaalDiscipline%, settings.ini, Utility Keys, VaalDiscipline
				
		;Utility Cooldowns
			IniWrite, %CooldownPhaseRun%, settings.ini, Utility Cooldowns, CooldownPhaseRun
			IniWrite, %CooldownVaalDiscipline%, settings.ini, Utility Cooldowns, CooldownVaalDiscipline
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
		Return
		}

	RemoveToolTip:
		SetTimer, RemoveToolTip, Off
		ToolTip
		return
	
	helpCalibration:
		MsgBox, Gamestate Calibration Instructions:`n`n  These buttons regrab the gamestate sample color.`n  Each button references a different game state.`n  Make sure the gamestate is true for that button!`n  Click the button once ready to calibrate.`n`nAuto-Detonate Mines Recalibration:`n`n  Sample the DetonateHex color in normal or delve.`n  Drop a mine then press the sample button that matches.
		Return

	checkUpdate(){
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/version.html, version.html
		FileRead, newestVersion, version.html

		if ( VersionNumber < newestVersion ) {
			UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/changelog.txt, changelog.txt
					if ErrorLevel
							GuiControl,1:, guiErr, ED08
			FileRead, changelog, changelog.txt
			Gui, 4:Add, Text,, Update Available.`nYoure running version %VersionNumber%. The newest is version %newestVersion%`n
			Gui, 4:Add, Edit, w600 h200 +ReadOnly, %changelog% 
			Gui, 4:Add, Button, section default grunUpdate, Update to the Newest Version!
			Gui, 4:Add, Button, ys gLaunchDonate, Support the Project
			Gui, 4:Add, Button, ys gdontUpdate, Skip Update this time
			Gui, 4:Show,, WingmanReloaded Update
			IfWinExist WingmanReloaded Update ahk_exe AutoHotkey.exe
				{
				WinWaitClose
				}
			}
		WinGetPos, , , WinWidth, WinHeight
		Return
		}

	runUpdate:
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/GottaGoFast.ahk, GottaGoFast.ahk
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/master/PoE-Wingman.ahk, PoE-Wingman.ahk
			if ErrorLevel {
				error("update","fail",A_ScriptFullPath, macroVersion, A_AhkVersion)
				error("ED07")
			}
			else {
				error("update","pass",A_ScriptFullPath, macroVersion, A_AhkVersion)
				Run "%A_ScriptFullPath%"
			}
		Sleep 5000 ;This shouldn't ever hit.
		error("update","uhoh", A_ScriptFullPath, macroVersion, A_AhkVersion)
	dontUpdate:
		Gui, 4:Destroy
		return	

return
