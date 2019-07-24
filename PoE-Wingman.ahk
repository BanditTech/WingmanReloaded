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
	Hotkey, IfWinActive, ahk_class POEWindowClass

	SetTitleMatchMode 3 
	CoordMode, Mouse, Screen
	CoordMode, Pixel, Screen
	SetWorkingDir %A_ScriptDir%  
	Thread, interrupt, 0
	I_Icon = shield_charge_skill_icon.ico
	IfExist, %I_Icon%
	Menu, Tray, Icon, %I_Icon%

	CleanUp()
	if not A_IsAdmin
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart, , Hide
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%", , Hide
	Run GottaGoFast.ahk, "A_ScriptDir", Hide
	OnExit("CleanUp")

	If FileExist("settings.ini")
		readFromFile()
; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;General
		Global VersionNumber := .01.5
		Global Latency := 1
		Global ShowOnStart := 0
		Global PopFlaskRespectCD := 1
		If (YesUltraWide){
			Global InventoryGridX := [ (A_ScreenWidth/(3840/3194)), (A_ScreenWidth/(3840/3246)), (A_ScreenWidth/(3840/3299)), (A_ScreenWidth/(3840/3352)), (A_ScreenWidth/(3840/3404)), (A_ScreenWidth/(3840/3457)), (A_ScreenWidth/(3840/3510)), (A_ScreenWidth/(3840/3562)), (A_ScreenWidth/(3840/3615)), (A_ScreenWidth/(3840/3668)), (A_ScreenWidth/(3840/3720)), (A_ScreenWidth/(3840/3773)) ]
			Global DetonateDelveX:=(A_ScreenWidth/(3840/3462))
			Global DetonateX:=(A_ScreenWidth/(3840/3578))
			Global WisdomStockX:=(A_ScreenWidth/(3840/125))
			Global PortalStockX:=(A_ScreenWidth/(3840/175))
			} Else {
			Global InventoryGridX := [ (A_ScreenWidth/(1920/1274)), (A_ScreenWidth/(1920/1326)), (A_ScreenWidth/(1920/1379)), (A_ScreenWidth/(1920/1432)), (A_ScreenWidth/(1920/1484)), (A_ScreenWidth/(1920/1537)), (A_ScreenWidth/(1920/1590)), (A_ScreenWidth/(1920/1642)), (A_ScreenWidth/(1920/1695)), (A_ScreenWidth/(1920/1748)), (A_ScreenWidth/(1920/1800)), (A_ScreenWidth/(1920/1853)) ]
			Global DetonateDelveX:=(A_ScreenWidth/(1920/1542))
			Global DetonateX:=(A_ScreenWidth/(1920/1658))
			Global WisdomStockX:=(A_ScreenWidth/(1920/125))
			Global PortalStockX:=(A_ScreenWidth/(1920/175))
			}
		Global WPStockY:=(A_ScreenHeight/(1080/262))
		Global DetonateY:=(A_ScreenHeight/(1080/901))
		Global InventoryGridY := [ (A_ScreenHeight/(1080/637)), (A_ScreenHeight/(1080/690)), (A_ScreenHeight/(1080/743)), (A_ScreenHeight/(1080/796)), (A_ScreenHeight/(1080/848)) ]  
		Global IdColor := 0x1C0101
		Global UnIdColor := 0x01012A
		Global MOColor := 0x011C01
		; Use this area scale value to change how the pixel search behaves, Increasing the AreaScale will add +-(AreaScale*AreaScale) 
		; 0 = 1 pixel search area, 1 = 9 pixel square , 2 = 81 pixel, 3 = 361 pixel, 4 = 1089 pixel 
		Global AreaScale := 1
		Global LootVacuum := 1
		Global YesVendor := 1
		Global YesStash := 1
		Global YesIdentify := 1
		Global YesMapUnid := 1
		Global YesUltraWide := 0
		Global YesStashKeys := 1
		Global OnHideout := False
		Global OnChar := False
		Global OnChat := False
		Global OnInventory := False
		Global OnStash := False
		Global OnVendor := False

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
				, Flask : False}
		
		global Detonated := 0
		global CritQuit := 1
		global CurrentTab := 0
		global DebugMessages := 0
		global ShowPixelGrid := 0
		global ShowItemInfo := 0
		global DetonateMines := 0
		global Latency := 1
		; Dont change the speed & the tick unless you know what you are doing
			global Speed:=1
			global Tick:=50
			global RunningToggle := False
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

	;Attack Buttons
		global MainAttackKey:="Q"
		global SecondaryAttackKey:="W"

	;Attack Triggers
		global TriggerMainAttack:=00000
		global TriggerSecondaryAttack:=00000

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

	;Mana Triggers
		global TriggerMana10:=00000

	;AutoQuit
		global Quit20
		global Quit30
		global Quit40

	;Flask Cooldowns
		global CoolDownFlask1:=5000
		global CoolDownFlask2:=5000
		global CoolDownFlask3:=5000
		global CoolDownFlask4:=5000
		global CoolDownFlask5:=5000
		global CoolDown:=5000

	;Quicksilver
		global TriggerQuicksilverDelay=0.8
		global TriggerQuicksilver=00000

;readFromFile()

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Extra vars - Not in INI
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	global Trigger=00000
	global AutoQuit=0 
	global AutoFlask=0
	global OnCoolDown:=[0,0,0,0,0]
	global Radiobox1QS
	global Radiobox2QS
	global Radiobox3QS
	global Radiobox4QS
	global Radiobox5QS


	IfWinExist, ahk_class POEWindowClass
	{
		WinGetPos, X, Y, W, H
		If (YesUltraWide)
			{
			global vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
			global vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
			global vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
			global vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
			global vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
			global vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
			global vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
			global vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
			global vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
			}
		Else
			{
			global vX_OnHideout:=X + Round(	A_ScreenWidth / (1920 / 1241))
			global vX_OnChar:=X + Round(A_ScreenWidth / (1920 / 41))
			global vX_OnChat:=X + Round(A_ScreenWidth / (1920 / 0))
			global vX_OnInventory:=X + Round(A_ScreenWidth / (1920 / 1583))
			global vX_OnStash:=X + Round(A_ScreenWidth / (1920 / 336))
			global vX_OnVendor:=X + Round(A_ScreenWidth / (1920 / 618))
			global vX_Life:=X + Round(A_ScreenWidth / (1920 / 95))
			global vX_ES:=X + Round(A_ScreenWidth / (1920 / 180))
			global vX_Mana:=X + Round(A_ScreenWidth / (1920 / 1825))
			}
		global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 951))
		global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1080 / 915))
		global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1080 / 653))
		global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
		global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
		global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1080 / 88))
		
		global vY_Life20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
		global vY_Life30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
		global vY_Life40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
		global vY_Life50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
		global vY_Life60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
		global vY_Life70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
		global vY_Life80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
		global vY_Life90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
		
		global vY_ES20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
		global vY_ES30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
		global vY_ES40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
		global vY_ES50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
		global vY_ES60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
		global vY_ES70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
		global vY_ES80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
		global vY_ES90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
		
		global vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
	}
	else
	{
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
	}

; Standard ini read
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	If FileExist("settings.ini"){ 

		;General
		IniRead, Speed, settings.ini, General, Speed
		IniRead, Tick, settings.ini, General, Tick
		IniRead, QTick, settings.ini, General, QTick
		;Coordinates
		IniRead, GuiX, settings.ini, Coordinates, GuiX
		IniRead, GuiY, settings.ini, Coordinates, GuiY
		readFromFile()
		
		} else {
		
		;General
		IniWrite, 1, settings.ini, General, Speed
		IniWrite, 50, settings.ini, General, Tick
		IniWrite, 250, settings.ini, General, QTick
		IniWrite, 1, settings.ini, General, PopFlaskRespectCD
		IniWrite, 0, settings.ini, General, YesUltraWide
		IniWrite, 1, settings.ini, General, YesStashKeys
		IniWrite, 0, settings.ini, General, DebugMessages
		IniWrite, 0, settings.ini, General, ShowPixelGrid
		IniWrite, 0, settings.ini, General, ShowItemInfo
		IniWrite, 0, settings.ini, General, DetonateMines
		IniWrite, 1, settings.ini, General, LootVacuum
		IniWrite, 1, settings.ini, General, YesVendor
		IniWrite, 1, settings.ini, General, YesStash
		IniWrite, 1, settings.ini, General, YesIdentify
		IniWrite, 1, settings.ini, General, YesMapUnid
		IniWrite, 1, settings.ini, General, Latency
		IniWrite, 0, settings.ini, General, ShowOnStart

		;Stash Tab
		IniWrite, 1, settings.ini, Stash Tab, StashTabCurrency
		IniWrite, 1, settings.ini, Stash Tab, StashTabMap
		IniWrite, 1, settings.ini, Stash Tab, StashTabDivination
		IniWrite, 1, settings.ini, Stash Tab, StashTabGem
		IniWrite, 1, settings.ini, Stash Tab, StashTabGemQuality
		IniWrite, 1, settings.ini, Stash Tab, StashTabFlaskQuality
		IniWrite, 1, settings.ini, Stash Tab, StashTabLinked
		IniWrite, 1, settings.ini, Stash Tab, StashTabCollection
		IniWrite, 1, settings.ini, Stash Tab, StashTabUniqueRing
		IniWrite, 1, settings.ini, Stash Tab, StashTabUniqueDump
		IniWrite, 1, settings.ini, Stash Tab, StashTabFragment
		IniWrite, 1, settings.ini, Stash Tab, StashTabEssence
		IniWrite, 1, settings.ini, Stash Tab, StashTabTimelessSplinter
		IniWrite, 1, settings.ini, Stash Tab, StashTabFossil
		IniWrite, 1, settings.ini, Stash Tab, StashTabResonator
		
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesCurrency
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesMap
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesDivination
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesGem
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesGemQuality
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesFlaskQuality
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesLinked
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesCollection
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesUniqueRing
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesUniqueDump
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesFragment
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesEssence
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesTimelessSplinter
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesFossil
		IniWrite, 1, settings.ini, Stash Tab, StashTabYesResonator
		
		;Coordinates
		IniWrite, -10, settings.ini, Coordinates, GuiX
		IniWrite, 1027, settings.ini, Coordinates, GuiY
		IniWrite, 1825, settings.ini, Coordinates, PortalScrollX
		IniWrite, 825, settings.ini, Coordinates, PortalScrollY
		IniWrite, 1875, settings.ini, Coordinates, WisdomScrollX
		IniWrite, 825, settings.ini, Coordinates, WisdomScrollY
		IniWrite, 1, settings.ini, Coordinates, StockPortal
		IniWrite, 1, settings.ini, Coordinates, StockWisdom
		
		;Hotkeys
		IniWrite, !F10, settings.ini, hotkeys, Options
		IniWrite, !F12, settings.ini, hotkeys, AutoQuit
		IniWrite, !F11, settings.ini, hotkeys, AutoFlask
		IniWrite, !MButton, settings.ini, hotkeys, AutoQuicksilver
		IniWrite, !q, settings.ini, hotkeys, QuickPortal
		IniWrite, !e, settings.ini, hotkeys, GemSwap
		IniWrite, !o, settings.ini, hotkeys, GetMouseCoords
		IniWrite, CapsLock, settings.ini, hotkeys, PopFlasks
		IniWrite, F12, settings.ini, hotkeys, Logout
		IniWrite, Space, settings.ini, hotkeys, CloseAllUI
		IniWrite, c, settings.ini, hotkeys, Inventory
		IniWrite, x, settings.ini, hotkeys, WeaponSwapKey
		IniWrite, F6, settings.ini, hotkeys, ItemSort
		IniWrite, f, settings.ini, hotkeys, LootScan
		IniWrite, LButton, settings.ini, hotkeys, Move
		
		;Failsafe Colors
		IniWrite, 0x161114, settings.ini, Failsafe Colors, OnHideout
		IniWrite, 0x4F6980, settings.ini, Failsafe Colors, OnChar
		IniWrite, 0x3B6288, settings.ini, Failsafe Colors, OnChat
		IniWrite, 0x8CC6DD, settings.ini, Failsafe Colors, OnInventory
		IniWrite, 0x9BD6E7, settings.ini, Failsafe Colors, OnStash
		IniWrite, 0x7BB1CC, settings.ini, Failsafe Colors, OnVendor
		IniWrite, 0x412037, settings.ini, Failsafe Colors, DetonateHex
		

		;Life Colors
		IniWrite, 0x181145, settings.ini, Life Colors, Life20
		IniWrite, 0x181264, settings.ini, Life Colors, Life30
		IniWrite, 0x190F7D, settings.ini, Life Colors, Life40
		IniWrite, 0x2318A5, settings.ini, Life Colors, Life50
		IniWrite, 0x2215B4, settings.ini, Life Colors, Life60
		IniWrite, 0x2413B3, settings.ini, Life Colors, Life70
		IniWrite, 0x2B2385, settings.ini, Life Colors, Life80
		IniWrite, 0x664564, settings.ini, Life Colors, Life90
		
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife20
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife30
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife40
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife50
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife60
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife70
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife80
		IniWrite, 00000, settings.ini, Life Triggers, TriggerLife90
		IniWrite, 11111, settings.ini, Life Triggers, DisableLife
		
		;ES Colors
		IniWrite, 0xFFC445, settings.ini, ES Colors, ES20
		IniWrite, 0xFFCE66, settings.ini, ES Colors, ES30
		IniWrite, 0xFFFF85, settings.ini, ES Colors, ES40
		IniWrite, 0xFFFF82, settings.ini, ES Colors, ES50
		IniWrite, 0xFFFF95, settings.ini, ES Colors, ES60
		IniWrite, 0xFFD07F, settings.ini, ES Colors, ES70
		IniWrite, 0xE89C5E, settings.ini, ES Colors, ES80
		IniWrite, 0xE79435, settings.ini, ES Colors, ES90
		
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES20
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES30
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES40
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES50
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES60
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES70
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES80
		IniWrite, 00000, settings.ini, ES Triggers, TriggerES90
		IniWrite, 11111, settings.ini, ES Triggers, DisableES
		
		;Mana Colors
		IniWrite, 0x3C201D, settings.ini, Mana Colors, Mana10
		
		IniWrite, 00000, settings.ini, Mana Triggers, TriggerMana10
		
		;Flask Cooldowns
		IniWrite, 4800, settings.ini, Flask Cooldowns, CooldownFlask1
		IniWrite, 4800, settings.ini, Flask Cooldowns, CooldownFlask2
		IniWrite, 4800, settings.ini, Flask Cooldowns, CooldownFlask3
		IniWrite, 4800, settings.ini, Flask Cooldowns, CooldownFlask4
		IniWrite, 4800, settings.ini, Flask Cooldowns, CooldownFlask5	
		
		;Gem Swap
		IniWrite, 1353, settings.ini, Gem Swap, CurrentGemX
		IniWrite, 224, settings.ini, Gem Swap, CurrentGemY
		IniWrite, 1407, settings.ini, Gem Swap, AlternateGemX
		IniWrite, 201, settings.ini, Gem Swap, AlternateGemY
		IniWrite, 0, settings.ini, Gem Swap, AlternateGemOnSecondarySlot

		;Attack Flasks
		IniWrite, 00000, settings.ini, Attack Triggers, TriggerMainAttack
		IniWrite, 00000, settings.ini, Attack Triggers, TriggerSecondaryAttack
		
		;Attack Keys
		IniWrite, RButton, settings.ini, Attack Buttons, MainAttackKey
		IniWrite, W, settings.ini, Attack Buttons, SecondaryAttackKey
		
		;Quicksilver Flasks
		IniWrite, .5, settings.ini, Quicksilver, TriggerQuicksilverDelay
		IniWrite, 00000, settings.ini, Quicksilver, TriggerQuicksilver	
		IniWrite, 0, settings.ini, Quicksilver, QuicksilverSlot1
		IniWrite, 0, settings.ini, Quicksilver, QuicksilverSlot2
		IniWrite, 0, settings.ini, Quicksilver, QuicksilverSlot3
		IniWrite, 0, settings.ini, Quicksilver, QuicksilverSlot4
		IniWrite, 0, settings.ini, Quicksilver, QuicksilverSlot5
		
		;CharacterTypeCheck
		IniWrite, 1, settings.ini, CharacterTypeCheck, Life
		IniWrite, 0, settings.ini, CharacterTypeCheck, Hybrid	
		IniWrite, 0, settings.ini, CharacterTypeCheck, Ci	
		
		;AutoQuit
		IniWrite, 1, settings.ini, AutoQuit, Quit20
		IniWrite, 0, settings.ini, AutoQuit, Quit30
		IniWrite, 0, settings.ini, AutoQuit, Quit40
		IniWrite, 1, settings.ini, AutoQuit, CritQuit
		IniWrite, 0, settings.ini, AutoQuit, NormalQuit

		Reload
		}

; Wingman Gui Variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IfWinExist, ahk_class POEWindowClass 
	{
		varTextSave:="Save"
		varTextOnHideout:="OnHideout Color"
		varTextOnChar:="OnChar Color"
		varTextOnInventory:="OnInventory Color"
		varTextOnStash:="OnStash Color"
		varTextOnChat:="OnChat Color"
		varTextOnVendor:="OnVendor Color"
		varTextDetonate:="Detonate Color"
		varTextDetonateDelve:="Detonate in Delve"
	}
	else
	{
		varTextSave:="Save (POE not open)"
		varTextOnHideout:="(POE not open)"
		varTextOnChar:="(POE not open)"
		varTextOnInventory:="(POE not open)"
		varTextOnStash:="(POE not open)"
		varTextOnChat:="(POE not open)"
		varTextOnVendor:="(POE not open)"
		varTextDetonate:="(POE not open)"
		varTextDetonateDelve:="(POE not open)"
	}
	GuiControl,, SaveBtn, %varTextSave%
	GuiControl,, UpdateOnHideoutBtn, %varTextOnHideout%
	GuiControl,, UpdateOnCharBtn, %varTextOnChar%
	GuiControl,, UpdateOnInventoryBtn, %varTextOnInventory%
	GuiControl,, UpdateOnStashBtn, %varTextOnStash%
	GuiControl,, UpdateOnChatBtn, %varTextOnChat%
	GuiControl,, UpdateOnVendorBtn, %varTextOnVendor%
	GuiControl,, UpdateDetonateBtn, %varTextDetonate%
	GuiControl,, UpdateDetonateDelveBtn, %varTextDetonateDelve%

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

; Check presence of cports
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	IfNotExist, cports.exe
	{
	UrlDownloadToFile, http://lutbot.com/ahk/cports.exe, cports.exe
			if ErrorLevel
					MsgBox, Error ED02 : There was a problem downloading cports.exe
	}
	
	IfNotExist, cports.chm
	{
	UrlDownloadToFile, http://lutbot.com/ahk/cports.chm, cports.chm
			if ErrorLevel
					MsgBox, Error ED03 : There was a problem downloading cports.chm 
	}
	IfNotExist, cports.txt
	{
	UrlDownloadToFile, http://lutbot.com/ahk/readme.txt, cports.txt
			if ErrorLevel
					MsgBox, Error ED04 : There was a problem downloading readme.txt
	}

; MAIN Gui Section
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Gui Add, Tab2, x1 y1 w580 h465 -wrap, Configuration|Calibration|Inventory
	;#######################################################################################################Configuration Tab
	Gui, Tab, Configuration
	Gui, Font, Bold
	Gui Add, Text, 										x12 	y30, 				Flask Settings
	Gui, Font,

	Gui Add, Text, 										x12 	y+10, 				Character Type:
	Gui, Font, cRed
	Gui Add, Radio, Group 	vRadioLife 					x+8 gUpdateCharacterType, 	Life
	Gui, Font
	Gui Add, Radio, 		vRadioHybrid 				x+8 gUpdateCharacterType, 	Hybrid
	Gui, Font, cBlue
	Gui Add, Radio, 		vRadioCi 					x+8 gUpdateCharacterType, 	CI
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

	Gui Add, Edit, 			vMainAttackKey 				x12 	y+10 	w45 h17, 	%MainAttackKey%
	Gui Add, Checkbox, 		vMainAttackbox1 			x75 	y+-15 	w13 h13
	vFlask=2
	loop 4
	{
	Gui Add, Checkbox, 		vMainAttackbox%vFlask% 		x+28 			w13 h13
	vFlask:=vFlask+1
	} 

	Gui Add, Edit, 			vSecondaryAttackKey 		x12 	y+5 	w45 h17, 	%SecondaryAttackKey%
	Gui Add, Checkbox, 		vSecondaryAttackbox1 		x75 	y+-15 	w13 h13
	vFlask=2
	loop 4
	{
	Gui Add, Checkbox, 		vSecondaryAttackbox%vFlask% x+28 			w13 h13
	vFlask:=vFlask+1
	}

	Gui Add, Text, 										x12 	y+10, 				Quicksilver Flask Movement Delay (in s):
	Gui Add, Edit, 			vTriggerQuicksilverDelay	x+31 	y+-15 	w22 h17, 	%TriggerQuicksilverDelay%

	Gui Add, Text, 										x12 	y+10, 				Auto-Quit:
	Gui Add, Radio, Group 	vRadioQuit20 				x+5, 						%varTextAutoQuit20%
	Gui Add, Radio, 		vRadioQuit30 				x+5, 						%varTextAutoQuit30%
	Gui Add, Radio, 		vRadioQuit40 				x+5, 						%varTextAutoQuit40%
	Gui Add, Text, 										x20 	y+10, 				Quit via:
	Gui, Add, Radio, Group	vRadioCritQuit					x+5		y+-13,				cports
	Gui, Add, Radio, 		vRadioNormalQuit			x+19	,				normal /exit

	;Vertical Grey Lines
	Gui, Add, Text, 									x59 	y77 		h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+34 				h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+34 				h310 0x11
	Gui, Add, Text, 									x+33 				h310 0x11
	Gui, Add, Text, 									x+5 	y23		w1	h411 0x7
	Gui, Add, Text, 									x+1 	y23		w1	h411 0x7

	Gui, Add, Text, 									x376 	y29 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11
	Gui, Add, Text, 									x+33 		 		h107 0x11

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
	Gui Add, Checkbox, 	    vStockPortal              	x465     	y53	 	            , Stock Portal?
	Gui Add, Checkbox, 	    vStockWisdom              	         y+8                , Stock Wisdom?
	Gui Add, Checkbox, 	vAlternateGemOnSecondarySlot             y+8                , Weapon Swap?

	Gui Add, Checkbox, 	vDebugMessages  gUpdateDebug   	x560 	y5 	    w13 h13	
	Gui Add, Text, 										x523	y5, 				Debug:
	Gui Add, Checkbox, 	vShowPixelGrid  gUpdateDebug   	x506 	y5 	w13 h13	
	Gui Add, Text, 							vPGrid	    x457	y5, 		    	Pixel Grid:
	Gui Add, Checkbox, 	vShowItemInfo  gUpdateDebug  	x440 	y5 	w13 h13	
	Gui Add, Text, 							vParseI	    x385	y5, 		        Parse Item:

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

	Gui Add, Checkbox, gUpdateExtra	vDetonateMines           x300  y145           	          , Detonate Mines?
	Gui Add, Checkbox, gUpdateExtra	vYesStashKeys                         	         x+20 , Ctrl(1-10) stash tabs?
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
	Gui Add, Checkbox, gUpdateExtra	vLootVacuum                         	         y+8 , Loot Vacuum?
	Gui Add, Checkbox, gUpdateExtra	vPopFlaskRespectCD                         	     y+8 , Pop Flasks Respect CD?

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
	Gui, Add, Button, default gupdateEverything vSaveBtn	 x295 y430	w180 h23, 	%varTextSave%
	Gui, Add, Button,  		gRefreshGUI vRefreshBtn		x+5			 		h23, 	Check
	Gui, Add, Button,  		gLaunchWiki 		x+5			 		h23, 	Wiki

	;#######################################################################################################Calibration Tab
	Gui, Tab, Calibration
	Gui, Font, Bold
	Gui, Add, Text, 										x242 	y35, 				Gamestate Calibration Instructions:
	Gui, Font,
	Gui Add, Text, 										x252 	y+5, 				These buttons regrab the gamestate sample color.
	Gui Add, Text, 										x252 	y+5, 				Each button references a different game state.
	Gui Add, Text, 										x252 	y+5, 				Make sure the gamestate is true for that button!
	Gui Add, Text, 										x252 	y+5, 				Click the button once ready to calibrate.
	Gui, Font, Bold
	Gui Add, Text, 										x242 	y+10, 				Auto-Detonate Mines Recalibration:
	Gui, Font,
	Gui Add, Text, 										x252 	y+3, 				Sample the DetonateHex color in normal or delve.
	Gui Add, Text, 										x252 	y+3, 				Drop a mine then press the sample button that matches.

	;Update calibration for pixel check
	Gui, Add, Button, gupdateOnHideout vUpdateOnHideoutBtn	x22	y35	w100, 	%varTextOnHideout%
	Gui, Add, Button, gupdateOnChar vUpdateOnCharBtn	 	w100, 	%varTextOnChar%
	Gui, Add, Button, gupdateOnChat vUpdateOnChatBtn	 	w100, 	%varTextOnChat%


	Gui, Add, Button, gupdateDetonate vUpdateDetonateBtn	 y+22	w100, 	%varTextDetonate%
	Gui, Add, Button, gupdateDetonateDelve vUpdateDetonateDelveBtn	 x+8	w100, 	%varTextDetonateDelve%

	Gui, Add, Button, gupdateOnInventory vUpdateOnInventoryBtn	 x130 y35	w100, 	%varTextOnInventory%
	Gui, Add, Button, gupdateOnStash vUpdateOnStashBtn	 	w100, 	%varTextOnStash%
	Gui, Add, Button, gupdateOnVendor vUpdateOnVendorBtn	 	w100, 	%varTextOnVendor%
	Gui, Font, Bold
	Gui Add, Text, 										x22 	y+90, 				Additional Interface Options:
	Gui, Font, 

	Gui Add, Checkbox, gUpdateExtra	vYesUltraWide                          	    , UltraWide Scaling?
	Gui Add, Checkbox, gUpdateExtra	vShowOnStart                         	          	, Show GUI on startup?
	Gui, Add, DropDownList, R5 gUpdateExtra vLatency Choose%Latency% w30 ,  1|2|3
	Gui Add, Text, 										x+12 							, Adjust Latency
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

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCurrency  x+5 y55, Currency Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesTimelessSplinter y+14, TSplinter Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesMap y+14, Map Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFragment y+14, Fragment Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesDivination y+14, Divination Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesCollection y+14, Collection Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesEssence y+14, Essence Tab

	Gui, Add, DropDownList, R5 gUpdateStash vStashTabGem Choose%StashTabGem% x150 y50 w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabGemQuality Choose%StashTabGemQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabFlaskQuality Choose%StashTabFlaskQuality% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabLinked Choose%StashTabLinked% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabUniqueDump Choose%StashTabUniqueDump% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabUniqueRing Choose%StashTabUniqueRing% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabFossil Choose%StashTabFossil% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25
	Gui, Add, DropDownList, R5 gUpdateStash vStashTabResonator Choose%StashTabResonator% w40 ,  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGem x195 y55, Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesGemQuality y+14, Quality Gem Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFlaskQuality y+14, Quality Flask Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesLinked y+14, Linked Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueDump y+14, Unique Dump Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesUniqueRing y+14, Unique Ring Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesFossil y+14, Fossil Tab
	Gui, Add, Checkbox, gUpdateStash  vStashTabYesResonator y+14, Resonator Tab

	Gui, Font, Bold
	Gui Add, Text, 										x352 	y30, 				ID/Vend/Stash Options:
	Gui, Font,
	Gui Add, Checkbox, gUpdateExtra	vYesIdentify                         	          , Identify Items?
	Gui Add, Checkbox, gUpdateExtra	vYesStash                         	        	  , Deposit at stash?
	Gui Add, Checkbox, gUpdateExtra	vYesVendor                         	              , Sell at vendor?
	Gui Add, Checkbox, gUpdateExtra	vYesMapUnid                         	          , Leave Map Un-ID?

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
	Menu, Tray, Add
	Menu, Tray, Standard
	;Gui, Hide
	OnMessage(0x200, "WM_MOUSEMOVE")
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;~  END of Wingman Gui Settings
;~  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; GUI ini read / setup
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IfExist, settings.ini 
		{
		Loop, 5 {
			Iniread, CooldownFlask%A_Index%, settings.ini, Flask Cooldowns, CoolDownFlask%A_index%
			valueFlask := CooldownFlask%A_Index%
			GuiControl, , CoolDownFlask%A_Index%, %valueFlask%
			
			Iniread, TriggerLife20, settings.ini, Life Triggers, TriggerLife20
			valueLife20 := substr(TriggerLife20, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life20, %valueLife20%
			
			Iniread, TriggerLife30, settings.ini, Life Triggers, TriggerLife30
			valueLife30 := substr(TriggerLife30, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life30, %valueLife30%
			
			Iniread, TriggerLife40, settings.ini, Life Triggers, TriggerLife40
			valueLife40 := substr(TriggerLife40, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life40, %valueLife40%
			
			Iniread, TriggerLife50, settings.ini, Life Triggers, TriggerLife50
			valueLife50 := substr(TriggerLife50, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life50, %valueLife50%
			
			Iniread, TriggerLife60, settings.ini, Life Triggers, TriggerLife60
			valueLife60 := substr(TriggerLife60, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life60, %valueLife60%
			
			Iniread, TriggerLife70, settings.ini, Life Triggers, TriggerLife70
			valueLife70 := substr(TriggerLife70, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life70, %valueLife70%
			
			Iniread, TriggerLife80, settings.ini, Life Triggers, TriggerLife80
			valueLife80 := substr(TriggerLife80, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life80, %valueLife80%
			
			Iniread, TriggerLife90, settings.ini, Life Triggers, TriggerLife90
			valueLife90 := substr(TriggerLife90, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Life90, %valueLife90%
			
			Iniread, DisableLife, settings.ini, Life Triggers, DisableLife
			valueDisableLife := substr(DisableLife, (A_Index), 1)
			GuiControl, , RadioUncheck%A_Index%Life, %valueDisableLife%
			
			Iniread, TriggerES20, settings.ini, ES Triggers, TriggerES20
			valueES20 := substr(TriggerES20, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES20, %valueES20%
			
			Iniread, TriggerES30, settings.ini, ES Triggers, TriggerES30
			valueES30 := substr(TriggerES30, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES30, %valueES30%
			
			Iniread, TriggerES40, settings.ini, ES Triggers, TriggerES40
			valueES40 := substr(TriggerES40, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES40, %valueES40%
			
			Iniread, TriggerES50, settings.ini, ES Triggers, TriggerES50
			valueES50 := substr(TriggerES50, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES50, %valueES50%
			
			Iniread, TriggerES60, settings.ini, ES Triggers, TriggerES60
			valueES60 := substr(TriggerES60, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES60, %valueES60%
			
			Iniread, TriggerES70, settings.ini, ES Triggers, TriggerES70
			valueES70 := substr(TriggerES70, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES70, %valueES70%
			
			Iniread, TriggerES80, settings.ini, ES Triggers, TriggerES80
			valueES80 := substr(TriggerES80, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES80, %valueES80%
			
			Iniread, TriggerES90, settings.ini, ES Triggers, TriggerES90
			valueES90 := substr(TriggerES90, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%ES90, %valueES90%
			
			Iniread, DisableES, settings.ini, ES Triggers, DisableES
			valueDisableES := substr(DisableES, (A_Index), 1)
			GuiControl, , RadioUncheck%A_Index%ES, %valueDisableES%
			
			Iniread, TriggerMana10, settings.ini, Mana Triggers, TriggerMana10
			valueMana10 := substr(TriggerMana10, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%Mana10, %valueMana10%
			
			Iniread, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver
			valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
			GuiControl, , Radiobox%A_Index%QS, %valueQuicksilver%
			
			Iniread, TriggerMainAttack, settings.ini, Attack Triggers, TriggerMainAttack
			valueMainAttack := substr(TriggerMainAttack, (A_Index), 1)
			GuiControl, , MainAttackbox%A_Index%, %valueMainAttack%
			
			Iniread, TriggerSecondaryAttack, settings.ini, Attack Triggers, TriggerSecondaryAttack
			valueSecondaryAttack := substr(TriggerSecondaryAttack, (A_Index), 1)
			GuiControl, , SecondaryAttackbox%A_Index%, %valueSecondaryAttack%
		}

		Iniread, YesUltraWide, settings.ini, General, YesUltraWide
		valueYesUltraWide := YesUltraWide
		GuiControl, , YesUltraWide, %valueYesUltraWide%

		Iniread, YesStashKeys, settings.ini, General, YesStashKeys
		valueYesStashKeys := YesStashKeys
		GuiControl, , YesStashKeys, %valueYesStashKeys%

		Iniread, WisdomScrollX, settings.ini, Coordinates, WisdomScrollX
		valueWisdomScrollX := WisdomScrollX
		GuiControl, , WisdomScrollX, %valueWisdomScrollX%

		Iniread, WisdomScrollY, settings.ini, Coordinates, WisdomScrollY
		valueWisdomScrollY := WisdomScrollY
		GuiControl, , WisdomScrollY, %valueWisdomScrollY%

		Iniread, PortalScrollX, settings.ini, Coordinates, PortalScrollX
		valuePortalScrollX := PortalScrollX
		GuiControl, , PortalScrollX, %valuePortalScrollX%

		Iniread, PortalScrollY, settings.ini, Coordinates, PortalScrollY
		valuePortalScrollY := PortalScrollY
		GuiControl, , PortalScrollY, %valuePortalScrollY%

		Iniread, StockPortal, settings.ini, Coordinates, StockPortal
		valueStockPortal := StockPortal
		GuiControl, , StockPortal, %valueStockPortal%

		Iniread, StockWisdom, settings.ini, Coordinates, StockWisdom
		valueStockWisdom := StockWisdom
		GuiControl, , StockWisdom, %valueStockWisdom%

		Iniread, DebugMessages, settings.ini, General, DebugMessages
		valueDebugMessages := DebugMessages
		GuiControl, , DebugMessages, %valueDebugMessages%

		Iniread, ShowPixelGrid, settings.ini, General, ShowPixelGrid
		valueShowPixelGrid := ShowPixelGrid
		GuiControl, , ShowPixelGrid, %valueShowPixelGrid%
		
		Iniread, ShowItemInfo, settings.ini, General, ShowItemInfo
		valueShowItemInfo := ShowItemInfo
		GuiControl, , ShowItemInfo, %valueShowItemInfo%
		
		Iniread, DetonateMines, settings.ini, General, DetonateMines
		valueDetonateMines := DetonateMines
		GuiControl, , DetonateMines, %valueDetonateMines%
		
		Iniread, LootVacuum, settings.ini, General, LootVacuum
		valueLootVacuum := LootVacuum
		GuiControl, , LootVacuum, %valueLootVacuum%
		
		Iniread, YesVendor, settings.ini, General, YesVendor
		valueYesVendor := YesVendor
		GuiControl, , YesVendor, %valueYesVendor%
		
		Iniread, YesStash, settings.ini, General, YesStash
		valueYesStash := YesStash
		GuiControl, , YesStash, %valueYesStash%
		
		Iniread, YesIdentify, settings.ini, General, YesIdentify
		valueYesIdentify := YesIdentify
		GuiControl, , YesIdentify, %valueYesIdentify%
		
		Iniread, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD
		valuePopFlaskRespectCD := PopFlaskRespectCD
		GuiControl, , PopFlaskRespectCD, %valuePopFlaskRespectCD%
		
		Iniread, YesMapUnid, settings.ini, General, YesMapUnid
		valueYesMapUnid := YesMapUnid
		GuiControl, , YesMapUnid, %valueYesMapUnid%
		
		Iniread, Latency, settings.ini, General, Latency
		valueLatency := Latency
		GuiControl, Choose, Latency, %valueLatency%
		
		Iniread, ShowOnStart, settings.ini, General, ShowOnStart
		valueShowOnStart := ShowOnStart
		GuiControl, , ShowOnStart, %valueShowOnStart%
		
		Iniread, CurrentGemX, settings.ini, Gem Swap, CurrentGemX
		valueCurrentGemX := CurrentGemX
		GuiControl, , CurrentGemX, %valueCurrentGemX%
		
		Iniread, CurrentGemY, settings.ini, Gem Swap, CurrentGemY
		valueCurrentGemY := CurrentGemY
		GuiControl, , CurrentGemY, %valueCurrentGemY%
		
		Iniread, AlternateGemX, settings.ini, Gem Swap, AlternateGemX
		valueAlternateGemX := AlternateGemX
		GuiControl, , AlternateGemX, %valueAlternateGemX%
		
		Iniread, AlternateGemY, settings.ini, Gem Swap, AlternateGemY
		valueAlternateGemY := AlternateGemY
		GuiControl, , AlternateGemY, %valueAlternateGemY%
		
		Iniread, AlternateGemOnSecondarySlot, settings.ini, Gem Swap, AlternateGemOnSecondarySlot
		valueAlternateGemOnSecondarySlot := AlternateGemOnSecondarySlot
		GuiControl, , AlternateGemOnSecondarySlot, %valueAlternateGemOnSecondarySlot%

		Iniread, MainAttackKey, settings.ini, Attack Buttons, MainAttackKey
		valueMain := MainAttackKey
		GuiControl, , MainAttackKey, %valueMain%
		
		Iniread, SecondaryAttackKey, settings.ini, Attack Buttons, SecondaryAttackKey
		valueSec := SecondaryAttackKey
		GuiControl, , SecondaryAttackKey, %valueSec%
		
		Iniread, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay
		valueQSDelay := TriggerQuicksilverDelay
		GuiControl, , TriggerQuicksilverDelay, %valueQSDelay%
		
		Iniread, Life, settings.ini, CharacterTypeCheck, Life
		valueLife := Life
		GuiControl, , RadioLife, %valueLife%
		
		Iniread, Hybrid, settings.ini, CharacterTypeCheck, Hybrid
		valueHybrid := Hybrid
		GuiControl, , RadioHybrid, %valueHybrid%
		
		Iniread, Ci, settings.ini, CharacterTypeCheck, Ci
		valueCi := Ci
		GuiControl, , RadioCi, %valueCi%
		
		Iniread, Quit20, settings.ini, AutoQuit, Quit20
		valueQuit20 := Quit20
		GuiControl, , RadioQuit20, %valueQuit20%
		
		Iniread, Quit30, settings.ini, AutoQuit, Quit30
		valueQuit30 := Quit30
		GuiControl, , RadioQuit30, %valueQuit30%
		
		Iniread, Quit40, settings.ini, AutoQuit, Quit40
		valueQuit40 := Quit40
		GuiControl, , RadioQuit40, %valueQuit40%
		
		Iniread, CritQuit, settings.ini, AutoQuit, CritQuit
		valueCritQuit := CritQuit
		GuiControl, , RadioCritQuit, %valueCritQuit%
		
		Iniread, NormalQuit, settings.ini, AutoQuit, NormalQuit
		valueNormalQuit := NormalQuit
		GuiControl, , RadioNormalQuit, %valueNormalQuit%

		Iniread, StashTabYesCurrency, settings.ini, Stash Tab, StashTabYesCurrency
		valueStashTabYesCurrency := StashTabYesCurrency
		GuiControl, , StashTabYesCurrency, %valueStashTabYesCurrency%

		Iniread, StashTabYesMap, settings.ini, Stash Tab, StashTabYesMap
		valueStashTabYesMap := StashTabYesMap
		GuiControl, , StashTabYesMap, %valueStashTabYesMap%

		Iniread, StashTabYesFragment, settings.ini, Stash Tab, StashTabYesFragment
		valueStashTabYesFragment := StashTabYesFragment
		GuiControl, , StashTabYesFragment, %valueStashTabYesFragment%

		Iniread, StashTabYesDivination, settings.ini, Stash Tab, StashTabYesDivination
		valueStashTabYesDivination := StashTabYesDivination
		GuiControl, , StashTabYesDivination, %valueStashTabYesDivination%

		Iniread, StashTabYesCollection, settings.ini, Stash Tab, StashTabYesCollection
		valueStashTabYesCollection := StashTabYesCollection
		GuiControl, , StashTabYesCollection, %valueStashTabYesCollection%

		Iniread, StashTabYesEssence, settings.ini, Stash Tab, StashTabYesEssence
		valueStashTabYesEssence := StashTabYesEssence
		GuiControl, , StashTabYesEssence, %valueStashTabYesEssence%

		Iniread, StashTabYesGem, settings.ini, Stash Tab, StashTabYesGem
		valueStashTabYesGem := StashTabYesGem
		GuiControl, , StashTabYesGem, %valueStashTabYesGem%

		Iniread, StashTabYesGemQuality, settings.ini, Stash Tab, StashTabYesGemQuality
		valueStashTabYesGemQuality := StashTabYesGemQuality
		GuiControl, , StashTabYesGemQuality, %valueStashTabYesGemQuality%

		Iniread, StashTabYesFlaskQuality, settings.ini, Stash Tab, StashTabYesFlaskQuality
		valueStashTabYesFlaskQuality := StashTabYesFlaskQuality
		GuiControl, , StashTabYesFlaskQuality, %valueStashTabYesFlaskQuality%

		Iniread, StashTabYesLinked, settings.ini, Stash Tab, StashTabYesLinked
		valueStashTabYesLinked := StashTabYesLinked
		GuiControl, , StashTabYesLinked, %valueStashTabYesLinked%

		Iniread, StashTabYesUniqueDump, settings.ini, Stash Tab, StashTabYesUniqueDump
		valueStashTabYesUniqueDump := StashTabYesUniqueDump
		GuiControl, , StashTabYesUniqueDump, %valueStashTabYesUniqueDump%

		Iniread, StashTabYesUniqueRing, settings.ini, Stash Tab, StashTabYesUniqueRing
		valueStashTabYesUniqueRing := StashTabYesUniqueRing
		GuiControl, , StashTabYesUniqueRing, %valueStashTabYesUniqueRing%

		Iniread, StashTabYesTimelessSplinter, settings.ini, Stash Tab, StashTabYesTimelessSplinter
		valueStashTabYesTimelessSplinter := StashTabYesTimelessSplinter
		GuiControl, , StashTabYesTimelessSplinter, %valueStashTabYesTimelessSplinter%

		Iniread, StashTabYesFossil, settings.ini, Stash Tab, StashTabYesFossil
		valueStashTabYesFossil := StashTabYesFossil
		GuiControl, , StashTabYesFossil, %valueStashTabYesFossil%

		Iniread, StashTabYesResonator, settings.ini, Stash Tab, StashTabYesResonator
		valueStashTabYesResonator := StashTabYesResonator
		GuiControl, , StashTabYesResonator, %valueStashTabYesResonator%

		Iniread, hotkeyOptions, settings.ini, hotkeys, Options
		valuehotkeyOptions := hotkeyOptions
		GuiControl, , vhotkeyOptions, %valuehotkeyOptions%

		Iniread, hotkeyAutoFlask, settings.ini, hotkeys, AutoFlask
		valuehotkeyAutoFlask := hotkeyAutoFlask
		GuiControl, , vhotkeyAutoFlask, %valuehotkeyAutoFlask%

		Iniread, hotkeyAutoQuit, settings.ini, hotkeys, AutoQuit
		valuehotkeyAutoQuit := hotkeyAutoQuit
		GuiControl, , vhotkeyAutoQuit, %valuehotkeyAutoQuit%

		Iniread, hotkeyLogout, settings.ini, hotkeys, Logout
		valuehotkeyLogout := hotkeyLogout
		GuiControl, , vhotkeyLogout, %valuehotkeyLogout%

		Iniread, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver
		valuehotkeyAutoQuicksilver := hotkeyAutoQuicksilver
		GuiControl, , vhotkeyAutoQuicksilver, %valuehotkeyAutoQuicksilver%

		Iniread, hotkeyGetMouseCoords, settings.ini, hotkeys, GetMouseCoords
		valuehotkeyGetMouseCoords := hotkeyGetMouseCoords
		GuiControl, , vhotkeyGetMouseCoords, %valuehotkeyGetMouseCoords%

		Iniread, hotkeyGetMouseCoords, settings.ini, hotkeys, GetMouseCoords
		valuehotkeyGetMouseCoords := hotkeyGetMouseCoords
		GuiControl, , vhotkeyGetMouseCoords, %valuehotkeyGetMouseCoords%

		Iniread, hotkeyQuickPortal, settings.ini, hotkeys, QuickPortal
		valuehotkeyQuickPortal := hotkeyQuickPortal
		GuiControl, , vhotkeyQuickPortal, %valuehotkeyQuickPortal%

		Iniread, hotkeyGemSwap, settings.ini, hotkeys, GemSwap
		valuehotkeyGemSwap := hotkeyGemSwap
		GuiControl, , vhotkeyGemSwap, %valuehotkeyGemSwap%

		Iniread, hotkeyPopFlasks, settings.ini, hotkeys, PopFlasks
		valuehotkeyPopFlasks := hotkeyPopFlasks
		GuiControl, , vhotkeyPopFlasks, %valuehotkeyPopFlasks%

		Iniread, hotkeyItemSort, settings.ini, hotkeys, ItemSort
		valuehotkeyItemSort := hotkeyItemSort
		GuiControl, , vhotkeyItemSort, %valuehotkeyItemSort%

		Iniread, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI
		valuehotkeyCloseAllUI := hotkeyCloseAllUI
		GuiControl, , vhotkeyCloseAllUI, %valuehotkeyCloseAllUI%

		Iniread, hotkeyInventory, settings.ini, hotkeys, Inventory
		valuehotkeyInventory := hotkeyInventory
		GuiControl, , vhotkeyInventory, %valuehotkeyInventory%

		Iniread, hotkeyWeaponSwapKey, settings.ini, hotkeys, WeaponSwapKey
		valuehotkeyWeaponSwapKey := hotkeyWeaponSwapKey
		GuiControl, , vhotkeyWeaponSwapKey, %valuehotkeyWeaponSwapKey%

		Iniread, hotkeyLootScan, settings.ini, hotkeys, LootScan
		valuehotkeyLootScan := hotkeyLootScan
		GuiControl, , vhotkeyLootScan, %valuehotkeyLootScan%
		}
		
		IfWinExist, ahk_class POEWindowClass 
			{
				GuiControl, Enable, SaveBtn
				GuiControl, Enable, UpdateOnHideoutBtn
				GuiControl, Enable, UpdateOnCharBtn
				GuiControl, Enable, UpdateOnInventoryBtn
				GuiControl, Enable, UpdateOnStashBtn
				GuiControl, Enable, UpdateOnChatBtn
				GuiControl, Enable, UpdateOnVendorBtn
				GuiControl, Enable, UpdateDetonateBtn
				GuiControl, Enable, UpdateDetonateDelveBtn
				GuiControl, Hide, RefreshBtn
			}
			else
			{
				GuiControl, Disable, SaveBtn
				GuiControl, Disable, UpdateOnHideoutBtn
				GuiControl, Disable, UpdateOnCharBtn
				GuiControl, Disable, UpdateOnInventoryBtn
				GuiControl, Disable, UpdateOnStashBtn
				GuiControl, Disable, UpdateOnChatBtn
				GuiControl, Disable, UpdateOnVendorBtn
				GuiControl, Disable, UpdateDetonateBtn
				GuiControl, Disable, UpdateDetonateDelveBtn
			}
			
		if(valueLife==1) {
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
		else if(valueHybrid==1) {
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
		else if(valueCi==1) {
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
		
; Ingame Overlay (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Gui 2:Color, 0X130F13
	Gui 2:+LastFound +AlwaysOnTop +ToolWindow
	WinSet, TransColor, 0X130F13
	Gui 2: -Caption
	Gui 2:Font, bold cFFFFFF S10, Trebuchet MS
	Gui 2:Add, Text, y+0.5 BackgroundTrans vT1, Quit: OFF
	Gui 2:Add, Text, y+0.5 BackgroundTrans vT2, Flasks: OFF

	IfWinExist, ahk_class POEWindowClass
	{
		WinGetPos, X, Y, Width, Hight
		varX:=X + Round(A_ScreenWidth / (1920 / -10))
		varY:=Y + Round(A_ScreenHeight / (1080 / 1027))
		Gui 2: Show, x%varX% y%varY%, NoActivate 
	}

; Detonate mines timer check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	If (DetonateMines&&!Detonated)
		SetTimer, TMineTick, 100
		Else If (!DetonateMines)
		SetTimer, TMineTick, off
; Key Passthrough for 1-5
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Passthrough for manual activation
	; pass-thru and start timer for flask 1
	~1::
		OnCoolDown[1]:=1 
		settimer, TimmerFlask1, %CoolDownFlask1%
		return

	; pass-thru and start timer for flask 2
	~2::
		OnCoolDown[2]:=1 
		settimer, TimmerFlask2, %CoolDownFlask2%
		return

	; pass-thru and start timer for flask 3
	~3::
		OnCoolDown[3]:=1 
		settimer, TimmerFlask3, %CoolDownFlask3%
		return

	; pass-thru and start timer for flask 4
	~4::
		OnCoolDown[4]:=1 
		settimer, TimmerFlask4, %CoolDownFlask4%
		return

	; pass-thru and start timer for flask 5
	~5::
		OnCoolDown[5]:=1 
		settimer, TimmerFlask5, %CoolDownFlask5%
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

;Exit Script with Win+Escape
#Escape::
	ExitApp


; --------------------------------------------Function Section-----------------------------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Loot Scanner for items under cursor pressing Loot button
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LootScan(){
	LootScanCommand:
	Pressed := GetKeyState(hotkeyLootScan, "P")
	AreaScale:=0
	While (Pressed&&LootVacuum)
		{
		For k, ColorHex in LootColors
			{
			Pressed := GetKeyState(hotkeyLootScan, "P")
			MouseGetPos CenterX, CenterY
			ScanX1:=(CenterX-(AreaScale*AreaScale))
			ScanY1:=(CenterY-(AreaScale*AreaScale))
			ScanX2:=(CenterX+(AreaScale*AreaScale))
			ScanY2:=(CenterY+(AreaScale*AreaScale))
			PixelSearch, ScanPx, ScanPy, CenterX, CenterY, CenterX, CenterY, ColorHex, 0, Fast RGB
			If (ErrorLevel = 0){
				Pressed := GetKeyState(hotkeyLootScan, "P")
				If !(Pressed)
					Break
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
		If (YesUltraWide)
			MouseMove, (A_ScreenWidth/(3840/640)), (A_ScreenHeight/(1080/146)), 0
		Else
			MouseMove, (A_ScreenWidth/(1920/640)), (A_ScreenHeight/(1080/146)), 0
		Sleep, 45*Latency
		Click, Down, Left, 1
		Sleep, 45*Latency
		Click, Up, Left, 1
		Sleep, 45*Latency
		MouseMove, 760, ((A_ScreenHeight/(1080/120)) + (Tab*(A_ScreenHeight/(1080/22)))), 0
		Sleep, 45*Latency
		send {Enter}
		Sleep, 45*Latency
		If (YesUltraWide)
			MouseMove, (A_ScreenWidth/(3840/640)), (A_ScreenHeight/(1080/146)), 0
		Else
			MouseMove, (A_ScreenWidth/(1920/640)), (A_ScreenHeight/(1080/146)), 0
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

; Capture Clip at Coord
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ClipItem(x, y){
	BlockInput, MouseMove
	Clipboard := ""
	MouseMove %x%, %y%
	Sleep, 80*Latency
	Send ^c
	ClipWait, 0
	ParseClip()
	BlockInput, MouseMoveOff
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
	If (YesUltraWide)
		Rx:=Round(A_ScreenWidth / (3840 / x))
	Else
		Rx:=Round(A_ScreenWidth / (1920 / x))
	Ry:=Round(A_ScreenHeight / (1080 / y))
	return {"X": Rx, "Y": Ry}
	}

;Toggle Auto-Quit
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

;Toggle Auto-Pot
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
	If PopFlaskRespectCD
		TriggerFlask(11111)
	Else {
		Send 1
		OnCoolDown[1]:=1 
		CoolDown:=CoolDownFlask1
		settimer, TimmerFlask1, %CoolDown%
		RandomSleep(-99,99)
		Send 4
		OnCoolDown[4]:=1 
		CoolDown:=CoolDownFlask4
		settimer, TimmerFlask4, %CoolDown%
		RandomSleep(-99,99)
		Send 3
		OnCoolDown[3]:=1 
		CoolDown:=CoolDownFlask3
		settimer, TimmerFlask3, %CoolDown%
		RandomSleep(-99,99)
		Send 2
		OnCoolDown[2]:=1 
		CoolDown:=CoolDownFlask2
		settimer, TimmerFlask2, %CoolDown%
		RandomSleep(-99,99)
		Send 5
		OnCoolDown[5]:=1 
		CoolDown:=CoolDownFlask5
		settimer, TimmerFlask5, %CoolDown%
	}
	return
	}

;logout to character selection
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Logout(){
	LogoutCommand:
	Critical
	BlockInput On
	if (CritQuit=1) {
		Run, cports.exe /close * * * * PathOfExile_x64Steam.exe
		Run, cports.exe /close * * * * PathOfExileSteam.exe
		Run, cports.exe /close * * * * PathOfExile_x64Ci.exe
		Run, cports.exe /close * * * * PathOfExileCi.exe
		Run, cports.exe /close * * * * PathOfExile_x64.exe	
		Run, cports.exe /close * * * * PathOfExile.exe
		Send {Enter} /exit {Enter}
	} else {
		Send {Enter} /exit {Enter}		
	}
	RandomSleep(23,45)
	BlockInput Off
	return
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
				, Flask : False}
	
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
					ItemProp.Fossil := True
					ItemProp.SpecialType := "Fossil"
					Continue
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
	pixelgetcolor, DelveMine, DetonateDelveX, DetonateY
	pixelgetcolor, Mine, DetonateX, DetonateY
	If ((Mine = DetonateHex)||(DelveMine = DetonateHex)){
		Sendraw, d
		Detonated:=1
		Settimer, TDetonated, 500
		Return
		}
	;Uncheck the below line to confirm if you should be getting a trigger, move into either two to test
	;MsgBox boom
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



; Detonate Mines
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TMineTick(){
	IfWinActive, Path of Exile
		{	
		If (DetonateMines&&!Detonated) {
			DetonateMines()
			}
		}
	}

; Flask Logic
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TGameTick(){
	IfWinActive, Path of Exile
		{	
		; Check what status is your character in the game
		GuiStatus()
		if (OnHideout||!OnChar||OnChat||OnInventory||OnStash||OnVendor) { 
			GuiUpdate()																									   
			Exit
		}

		if (AutoFlask=1) {
			Trigger:=00000
			GetKeyState, %MainAttackKey%state, %MainAttackKey%, P
			if %MainAttackKey%state = D	
				TriggerFlask(TriggerMainAttack)
				;Trigger:=Trigger+TriggerMainAttack
			GetKeyState, %SecondaryAttackKey%state, %SecondaryAttackKey%
			if %SecondaryAttackKey%state = D
				TriggerFlask(TriggerSecondaryAttack)
				;Trigger:=Trigger+TriggerSecondaryAttack
			}	
		
		if (Life=1)
			{
			pixelgetcolor, Life20, vX_Life, vY_Life20 
			if (Life20!=varLife20) {
				Trigger:=Trigger+TriggerLife20			
				if (AutoQuit=1) && (Quit20=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life30, vX_Life, vY_Life30
			if (Life30!=varLife30) {
				Trigger:=Trigger+TriggerLife30				
				if (AutoQuit=1) && (Quit30=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life40, vX_Life, vY_Life40
			if (Life40!=varLife40) {
				Trigger:=Trigger+TriggerLife40
				if (AutoQuit=1) && (Quit40=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life50, vX_Life, vY_Life50
			if (Life50!=varLife50) {
				Trigger:=Trigger+TriggerLife50					
			}
			pixelgetcolor, Life60, vX_Life, vY_Life60
			if (Life60!=varLife60) {
				Trigger:=Trigger+TriggerLife60					
			}
			pixelgetcolor, Life70, vX_Life, vY_Life70
			if (Life70!=varLife70) {
				Trigger:=Trigger+TriggerLife70					
			}
			pixelgetcolor, Life80, vX_Life, vY_Life80
			if (Life80!=varLife80) {
				Trigger:=Trigger+TriggerLife80					
			}
			pixelgetcolor, Life90, vX_Life, vY_Life90
			if (Life90!=varLife90) {
				Trigger:=Trigger+TriggerLife90	
			}
			}
		
		if (Hybrid=1)
			{
			pixelgetcolor, Life20, vX_Life, vY_Life20 
			if (Life20!=varLife20) {
				Trigger:=Trigger+TriggerLife20			
				if (AutoQuit=1) && (Quit20=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life30, vX_Life, vY_Life30
			if (Life30!=varLife30) {
				Trigger:=Trigger+TriggerLife30				
				if (AutoQuit=1) && (Quit30=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life40, vX_Life, vY_Life40
			if (Life40!=varLife40) {
				Trigger:=Trigger+TriggerLife40
				if (AutoQuit=1) && (Quit40=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, Life50, vX_Life, vY_Life50
			if (Life50!=varLife50) {
				Trigger:=Trigger+TriggerLife50					
			}
			pixelgetcolor, Life60, vX_Life, vY_Life60
			if (Life60!=varLife60) {
				Trigger:=Trigger+TriggerLife60					
			}
			pixelgetcolor, Life70, vX_Life, vY_Life70
			if (Life70!=varLife70) {
				Trigger:=Trigger+TriggerLife70					
			}
			pixelgetcolor, Life80, vX_Life, vY_Life80
			if (Life80!=varLife80) {
				Trigger:=Trigger+TriggerLife80					
			}
			pixelgetcolor, Life90, vX_Life, vY_Life90
			if (Life90!=varLife90) {
				Trigger:=Trigger+TriggerLife90	
			}								
			pixelgetcolor, ES20, vX_ES, vY_ES20 
			if (ES20!=varES20) {
				Trigger:=Trigger+TriggerES20			
			}
			pixelgetcolor, ES30, vX_ES, vY_ES30
			if (ES30!=varES30) {
				Trigger:=Trigger+TriggerES30
			}
			pixelgetcolor, ES40, vX_ES, vY_ES40
			if (ES40!=varES40) {
				Trigger:=Trigger+TriggerES40
			}
			pixelgetcolor, ES50, vX_ES, vY_ES50
			if (ES50!=varES50) {
				Trigger:=Trigger+TriggerES50					
			}
			pixelgetcolor, ES60, vX_ES, vY_ES60
			if (ES60!=varES60) {
				Trigger:=Trigger+TriggerES60					
			}
			pixelgetcolor, ES70, vX_ES, vY_ES70
			if (ES70!=varES70) {
				Trigger:=Trigger+TriggerES70					
			}
			pixelgetcolor, ES80, vX_ES, vY_ES80
			if (ES80!=varES80) {
				Trigger:=Trigger+TriggerES80					
			}
			pixelgetcolor, ES90, vX_ES, vY_ES90
			if (ES90!=varES90) {
				Trigger:=Trigger+TriggerES90	
			}
			}
		
		if (Ci=1)
			{
			pixelgetcolor, ES20, vX_ES, vY_ES20 
			if (ES20!=varES20) {
				Trigger:=Trigger+TriggerES20			
				if (AutoQuit=1) && (Quit20=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, ES30, vX_ES, vY_ES30
			if (ES30!=varES30) {
				Trigger:=Trigger+TriggerES30				
				if (AutoQuit=1) && (Quit30=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, ES40, vX_ES, vY_ES40
			if (ES40!=varES40) {
				Trigger:=Trigger+TriggerES40
				if (AutoQuit=1) && (Quit40=1) {
					pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
					if (OnChar=varOnChar)
					Logout()
					Exit
				}
			}
			pixelgetcolor, ES50, vX_ES, vY_ES50
			if (ES50!=varES50) {
				Trigger:=Trigger+TriggerES50					
			}
			pixelgetcolor, ES60, vX_ES, vY_ES60
			if (ES60!=varES60) {
				Trigger:=Trigger+TriggerES60					
			}
			pixelgetcolor, ES70, vX_ES, vY_ES70
			if (ES70!=varES70) {
				Trigger:=Trigger+TriggerES70					
			}
			pixelgetcolor, ES80, vX_ES, vY_ES80
			if (ES80!=varES80) {
				Trigger:=Trigger+TriggerES80					
			}
			pixelgetcolor, ES90, vX_ES, vY_ES90
			if (ES90!=varES90) {
				Trigger:=Trigger+TriggerES90	
			}
			}
			
		pixelgetcolor, Mana10, vX_Mana, vY_Mana10
		if (Mana10!=varMana10) {
			Trigger:=Trigger+TriggerMana10
			}

		{
		GuiUpdate()
		}

		; Trigger the flasks
		if (AutoFlask=1) {
			STrigger:= SubStr("00000" Trigger,-4)
			FL=1
	   
			loop 5 {
				FLVal:=SubStr(STrigger,FL,1)+0
				if (FLVal > 0) {
					cd:=OnCoolDown[FL]
					if (cd=0) {
						send %FL%
						OnCoolDown[FL]:=1 
						CoolDown:=CoolDownFlask%FL%
						settimer, TimmerFlask%FL%, %CoolDown%
						sleep=rand(23,59)			
					}
				}
				FL:=FL+1
			}
			}
		}
	}
; Flask Trigger check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TriggerFlask(Trigger){
	FL:=1
	loop 5 {
		FLVal:=SubStr(Trigger,FL,1)+0
		if (FLVal > 0) {
			if (OnCoolDown[FL]=0) {
				send %FL%
				OnCoolDown[FL]:=1 
				CoolDown:=CoolDownFlask%FL%
				settimer, TimmerFlask%FL%, %CoolDown%
				RandomSleep(15,60)			
				}
			}
		++FL
		}
	}
;Clamp Value function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Clamp( Val, Min, Max) {
  If Val < Min
	Val := Min
  If Val > Max
	Val := Max
	}

; Flask Timers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimmerFlask1:
		OnCoolDown[1]:=0
		settimer,TimmerFlask1,delete
		return

	TimmerFlask2:
		OnCoolDown[2]:=0
		settimer,TimmerFlask2,delete
		return

	TimmerFlask3:
		OnCoolDown[3]:=0
		settimer,TimmerFlask3,delete
		return

	TimmerFlask4:
		OnCoolDown[4]:=0
		settimer,TimmerFlask4,delete
		return

	TimmerFlask5:
		OnCoolDown[5]:=0
		settimer,TimmerFlask5,delete
		return

; Detonate Timer
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TDetonated:
		Detonated:=0
		settimer,TDetonated,delete
		DetonateMines()
		return

; Configuration handling, ini updates, Hotkey handling, Utility Gfunctions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	readFromFile(){
		global
		;Hotkey,!F10, optionsCommand, Off
		IniRead, DebugMessages, settings.ini, General, DebugMessages
		IniRead, ShowPixelGrid, settings.ini, General, ShowPixelGrid
		IniRead, ShowItemInfo, settings.ini, General, ShowItemInfo
		IniRead, DetonateMines, settings.ini, General, DetonateMines
		IniRead, LootVacuum, settings.ini, General, LootVacuum
		IniRead, YesVendor, settings.ini, General, YesVendor
		IniRead, YesStash, settings.ini, General, YesStash
		IniRead, YesIdentify, settings.ini, General, YesIdentify
		IniRead, YesMapUnid, settings.ini, General, YesMapUnid
		IniRead, Latency, settings.ini, General, Latency
		IniRead, ShowOnStart, settings.ini, General, ShowOnStart
		IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD

		;Stash Tab Management
		IniRead, StashTabCurrency, settings.ini, Stash Tab, StashTabCurrency
		IniRead, StashTabMap, settings.ini, Stash Tab, StashTabMap
		IniRead, StashTabDivination, settings.ini, Stash Tab, StashTabDivination
		IniRead, StashTabGem, settings.ini, Stash Tab, StashTabGem
		IniRead, StashTabGemQuality, settings.ini, Stash Tab, StashTabGemQuality
		IniRead, StashTabFlaskQuality, settings.ini, Stash Tab, StashTabFlaskQuality
		IniRead, StashTabLinked, settings.ini, Stash Tab, StashTabLinked
		IniRead, StashTabCollection, settings.ini, Stash Tab, StashTabCollection
		IniRead, StashTabUniqueRing, settings.ini, Stash Tab, StashTabUniqueRing
		IniRead, StashTabUniqueDump, settings.ini, Stash Tab, StashTabUniqueDump
		IniRead, StashTabFragment, settings.ini, Stash Tab, StashTabFragment
		IniRead, StashTabEssence, settings.ini, Stash Tab, StashTabEssence
		IniRead, StashTabTimelessSplinter, settings.ini, Stash Tab, StashTabTimelessSplinter
		IniRead, StashTabFossil, settings.ini, Stash Tab, StashTabFossil
		IniRead, StashTabResonator, settings.ini, Stash Tab, StashTabResonator
		IniRead, StashTabYesCurrency, settings.ini, Stash Tab, StashTabYesCurrency
		IniRead, StashTabYesMap, settings.ini, Stash Tab, StashTabYesMap
		IniRead, StashTabYesDivination, settings.ini, Stash Tab, StashTabYesDivination
		IniRead, StashTabYesGem, settings.ini, Stash Tab, StashTabYesGem
		IniRead, StashTabYesGemQuality, settings.ini, Stash Tab, StashTabYesGemQuality
		IniRead, StashTabYesFlaskQuality, settings.ini, Stash Tab, StashTabYesFlaskQuality
		IniRead, StashTabYesLinked, settings.ini, Stash Tab, StashTabYesLinked
		IniRead, StashTabYesCollection, settings.ini, Stash Tab, StashTabYesCollection
		IniRead, StashTabYesUniqueRing, settings.ini, Stash Tab, StashTabYesUniqueRing
		IniRead, StashTabYesUniqueDump, settings.ini, Stash Tab, StashTabYesUniqueDump
		IniRead, StashTabYesFragment, settings.ini, Stash Tab, StashTabYesFragment
		IniRead, StashTabYesEssence, settings.ini, Stash Tab, StashTabYesEssence
		IniRead, StashTabYesTimelessSplinter, settings.ini, Stash Tab, StashTabYesTimelessSplinter
		IniRead, StashTabYesFossil, settings.ini, Stash Tab, StashTabYesFossil
		IniRead, StashTabYesResonator, settings.ini, Stash Tab, StashTabYesResonator
		
		;Failsafe Colors
		IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout
		IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar
		IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat
		IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory
		IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash
		IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor
		IniRead, DetonateHex, settings.ini, Failsafe Colors, DetonateHex
		
		;Life Flasks
		IniRead, varLife20, settings.ini, Life Colors, Life20
		IniRead, varLife30, settings.ini, Life Colors, Life30
		IniRead, varLife40, settings.ini, Life Colors, Life40
		IniRead, varLife50, settings.ini, Life Colors, Life50
		IniRead, varLife60, settings.ini, Life Colors, Life60
		IniRead, varLife70, settings.ini, Life Colors, Life70
		IniRead, varLife80, settings.ini, Life Colors, Life80
		IniRead, varLife90, settings.ini, Life Colors, Life90
		
		IniRead, TriggerLife20, settings.ini, Life Triggers, TriggerLife20
		IniRead, TriggerLife30, settings.ini, Life Triggers, TriggerLife30
		IniRead, TriggerLife40, settings.ini, Life Triggers, TriggerLife40
		IniRead, TriggerLife50, settings.ini, Life Triggers, TriggerLife50
		IniRead, TriggerLife60, settings.ini, Life Triggers, TriggerLife60
		IniRead, TriggerLife70, settings.ini, Life Triggers, TriggerLife70
		IniRead, TriggerLife80, settings.ini, Life Triggers, TriggerLife80
		IniRead, TriggerLife90, settings.ini, Life Triggers, TriggerLife90
		IniRead, DisableLife, settings.ini, Life Triggers, DisableLife

		;ES Flasks
		IniRead, varES20, settings.ini, ES Colors, ES20
		IniRead, varES30, settings.ini, ES Colors, ES30
		IniRead, varES40, settings.ini, ES Colors, ES40
		IniRead, varES50, settings.ini, ES Colors, ES50
		IniRead, varES60, settings.ini, ES Colors, ES60
		IniRead, varES70, settings.ini, ES Colors, ES70
		IniRead, varES80, settings.ini, ES Colors, ES80
		IniRead, varES90, settings.ini, ES Colors, ES90
		
		IniRead, TriggerES20, settings.ini, ES Triggers, TriggerES20
		IniRead, TriggerES30, settings.ini, ES Triggers, TriggerES30
		IniRead, TriggerES40, settings.ini, ES Triggers, TriggerES40
		IniRead, TriggerES50, settings.ini, ES Triggers, TriggerES50
		IniRead, TriggerES60, settings.ini, ES Triggers, TriggerES60
		IniRead, TriggerES70, settings.ini, ES Triggers, TriggerES70
		IniRead, TriggerES80, settings.ini, ES Triggers, TriggerES80
		IniRead, TriggerES90, settings.ini, ES Triggers, TriggerES90
		IniRead, DisableES, settings.ini, ES Triggers, DisableES
		
		;Mana Flasks
		IniRead, varMana10, settings.ini, Mana Colors, Mana10
		
		IniRead, TriggerMana10, settings.ini, Mana Triggers, TriggerMana10
		
		;Flask Cooldowns
		IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1
		IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2
		IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3
		IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4
		IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5
		
		;Gem Swap
		IniRead, CurrentGemX, settings.ini, Gem Swap, CurrentGemX
		IniRead, CurrentGemY, settings.ini, Gem Swap, CurrentGemY
		IniRead, AlternateGemX, settings.ini, Gem Swap, AlternateGemX
		IniRead, AlternateGemY, settings.ini, Gem Swap, AlternateGemY
		IniRead, AlternateGemOnSecondarySlot, settings.ini, Gem Swap, AlternateGemOnSecondarySlot

		;~ Scroll locations
		IniRead, PortalScrollX, settings.ini, Coordinates, PortalScrollX
		IniRead, PortalScrollY, settings.ini, Coordinates, PortalScrollY
		IniRead, WisdomScrollX, settings.ini, Coordinates, WisdomScrollX
		IniRead, WisdomScrollY, settings.ini, Coordinates, WisdomScrollY
		IniRead, StockPortal, settings.ini, Coordinates, StockPortal
		IniRead, StockWisdom, settings.ini, Coordinates, StockWisdom
		
		;Attack Flasks
		IniRead, TriggerMainAttack, settings.ini, Attack Triggers, TriggerMainAttack
		IniRead, TriggerSecondaryAttack, settings.ini, Attack Triggers, TriggerSecondaryAttack
		
		;Attack Keys
		IniRead, MainAttackKey, settings.ini, Attack Buttons, MainAttackKey
		IniRead, SecondaryAttackKey, settings.ini, Attack Buttons, SecondaryAttackKey
		
		;Quicksilver
		IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay
		IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver
		
		;CharacterTypeCheck
		IniRead, Life, settings.ini, CharacterTypeCheck, Life
		IniRead, Hybrid, settings.ini, CharacterTypeCheck, Hybrid
		IniRead, Ci, settings.ini, CharacterTypeCheck, Ci
		
		;AutoQuit
		IniRead, Quit20, settings.ini, AutoQuit, Quit20
		IniRead, Quit30, settings.ini, AutoQuit, Quit30
		IniRead, Quit40, settings.ini, AutoQuit, Quit40
		IniRead, CritQuit, settings.ini, AutoQuit, CritQuit

		;~ hotkeys reset
		hotkey, IfWinActive, ahk_class POEWindowClass
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
		
		hotkey, IfWinActive
		If hotkeyOptions
			hotkey,% hotkeyOptions, optionsCommand, Off
		hotkey, IfWinActive, ahk_class POEWindowClass

		;~ hotkeys iniread
		IniRead, hotkeyOptions, settings.ini, hotkeys, Options
		IniRead, hotkeyAutoQuit, settings.ini, hotkeys, AutoQuit
		IniRead, hotkeyAutoFlask, settings.ini, hotkeys, AutoFlask
		IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver
		IniRead, hotkeyQuickPortal, settings.ini, hotkeys, QuickPortal
		IniRead, hotkeyGemSwap, settings.ini, hotkeys, GemSwap
		IniRead, hotkeyGetMouseCoords, settings.ini, hotkeys, GetMouseCoords
		IniRead, hotkeyPopFlasks, settings.ini, hotkeys, PopFlasks
		IniRead, hotkeyLogout, settings.ini, hotkeys, Logout
		IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI
		IniRead, hotkeyInventory, settings.ini, hotkeys, Inventory
		IniRead, hotkeyWeaponSwapKey, settings.ini, hotkeys, WeaponSwapKey
		IniRead, hotkeyItemSort, settings.ini, hotkeys, ItemSort
		IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan

		hotkey, IfWinActive, ahk_class POEWindowClass
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
		
		hotkey, IfWinActive
		If hotkeyOptions {
			hotkey,% hotkeyOptions, optionsCommand, On
			;GuiControl,, guiSettings, Settings:%hotkeyOptions%
		}
		else {
			hotkey,!F10, optionsCommand, On
			msgbox You dont have set the GUI hotkey!`nPlease hit Alt+F10 to open up the GUI and set your hotkey.
			;GuiControl,, guiSettings, Settings:%hotkeyOptions%
		}
		Return
		}

	submit(){  
		updateEverything:
		global
		Gui, Submit
		
		IfWinExist, ahk_class POEWindowClass 
		{
			WinGetPos, X, Y, Width, Height  ; Uses the window found above.
			If (YesUltraWide)
				vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
			Else
				vX_Life:=X + Round(A_ScreenWidth / (1920 / 95))

			vY_Life20:=Y + Round(A_ScreenHeight / (1080 / 1034))
			vY_Life30:=Y + Round(A_ScreenHeight / (1080 / 1014))
			vY_Life40:=Y + Round(A_ScreenHeight / (1080 / 994))
			vY_Life50:=Y + Round(A_ScreenHeight / (1080 / 974))
			vY_Life60:=Y + Round(A_ScreenHeight / (1080 / 954))
			vY_Life70:=Y + Round(A_ScreenHeight / (1080 / 934))
			vY_Life80:=Y + Round(A_ScreenHeight / (1080 / 914))
			vY_Life90:=Y + Round(A_ScreenHeight / (1080 / 894))
			
			If (YesUltraWide)
				vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
			Else
				vX_ES:=X + Round(A_ScreenWidth / (1920 / 180))
				
			vY_ES20:=Y + Round(A_ScreenHeight / (1080 / 1034))
			vY_ES30:=Y + Round(A_ScreenHeight / (1080 / 1014))
			vY_ES40:=Y + Round(A_ScreenHeight / (1080 / 994))
			vY_ES50:=Y + Round(A_ScreenHeight / (1080 / 974))
			vY_ES60:=Y + Round(A_ScreenHeight / (1080 / 954))
			vY_ES70:=Y + Round(A_ScreenHeight / (1080 / 934))
			vY_ES80:=Y + Round(A_ScreenHeight / (1080 / 914))
			vY_ES90:=Y + Round(A_ScreenHeight / (1080 / 894))
			
			If (YesUltraWide)
				vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
			Else
				vX_Mana:=X + Round(A_ScreenWidth / (1920 / 1825))
			vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
		}

		
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		
		;Life Flasks
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
		pixelgetcolor, varMana10, vX_Mana, vY_Mana10
		
		IniWrite, %varMana10%, settings.ini, Mana Colors, Mana10

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
		IniWrite, %PopFlaskRespectCD%, settings.ini, General, PopFlaskRespectCD
		
		IniWrite, %Radiobox1Mana10%%Radiobox2Mana10%%Radiobox3Mana10%%Radiobox4Mana10%%Radiobox5Mana10%, settings.ini, Mana Triggers, TriggerMana10

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
		
		;Attack Flasks
		IniWrite, %MainAttackbox1%%MainAttackbox2%%MainAttackbox3%%MainAttackbox4%%MainAttackbox5%, settings.ini, Attack Triggers, TriggerMainAttack
		IniWrite, %SecondaryAttackbox1%%SecondaryAttackbox2%%SecondaryAttackbox3%%SecondaryAttackbox4%%SecondaryAttackbox5%, settings.ini, Attack Triggers, TriggerSecondaryAttack
		
		;Attack Keys
		IniWrite, %MainAttackKey%, settings.ini, Attack Buttons, MainAttackKey
		IniWrite, %SecondaryAttackKey%, settings.ini, Attack Buttons, SecondaryAttackKey
		
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
		Run GottaGoFast.ahk
		
		return  
		}

	optionsCommand:
		hotkeys()
		return

	hotkeys(){
		global ;processWarningFound, macroVersion
		;getLeagueListing()
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

	RefreshGUI:
		IfWinExist, ahk_class POEWindowClass 
		{
			GuiControl, Enable, SaveBtn
			GuiControl, Enable, UpdateOnHideoutBtn
			GuiControl, Enable, UpdateOnCharBtn
			GuiControl, Enable, UpdateOnInventoryBtn
			GuiControl, Enable, UpdateOnStashBtn
			GuiControl, Enable, UpdateOnChatBtn
			GuiControl, Enable, UpdateOnVendorBtn
			GuiControl, Enable, UpdateDetonateBtn
			GuiControl, Enable, UpdateDetonateDelveBtn
			GuiControl, Hide, RefreshBtn
			Reload
			varTextSave:="Save"
			varTextOnHideout:="OnHideout Color"
			varTextOnChar:="OnChar Color"
			varTextOnInventory:="OnInventory Color"
			varTextOnStash:="OnStash Color"
			varTextOnChat:="OnChat Color"
			varTextOnVendor:="OnVendor Color"
			varTextDetonate:="Detonate Color"
			varTextDetonateDelve:="Detonate in Delve"
		}
		else
		{
			GuiControl, Disable, SaveBtn
			GuiControl, Disable, UpdateOnHideoutBtn
			GuiControl, Disable, UpdateOnCharBtn
			GuiControl, Disable, UpdateOnInventoryBtn
			GuiControl, Disable, UpdateOnStashBtn
			GuiControl, Disable, UpdateOnChatBtn
			GuiControl, Disable, UpdateOnVendorBtn
			GuiControl, Disable, UpdateDetonateBtn
			GuiControl, Disable, UpdateDetonateDelveBtn
			GuiControl, Enable, ResfreshBtn
			varTextSave:="Save (POE not open)"
			varTextOnHideout:="(POE not open)"
			varTextOnChar:="(POE not open)"
			varTextOnInventory:="(POE not open)"
			varTextOnStash:="(POE not open)"
			varTextOnChat:="(POE not open)"
			varTextOnVendor:="(POE not open)"
			varTextDetonate:="(POE not open)"
			varTextDetonateDelve:="(POE not open)"
		}
		GuiControl,, SaveBtn, %varTextSave%
		GuiControl,, UpdateOnHideoutBtn, %varTextOnHideout%
		GuiControl,, UpdateOnCharBtn, %varTextOnChar%
		GuiControl,, UpdateOnInventoryBtn, %varTextOnInventory%
		GuiControl,, UpdateOnStashBtn, %varTextOnStash%
		GuiControl,, UpdateOnChatBtn, %varTextOnChat%
		GuiControl,, UpdateOnVendorBtn, %varTextOnVendor%
		GuiControl,, UpdateDetonateBtn, %varTextDetonate%
		GuiControl,, UpdateDetonateDelveBtn, %varTextDetonateDelve%
		return

	updateOnHideout:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			WinGetPos, X, Y, Width, Height  ; Uses the window found above.
			If (YesUltraWide)
				{
				vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
				}
			Else
				{
				vX_OnHideout:=X + Round(A_ScreenWidth / (1920 / 1241))
				}
			vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 951))
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnHideout, vX_OnHideout, vY_OnHideout	
		IniWrite, %varOnHideout%, settings.ini, Failsafe Colors, OnHideout
		readFromFile()
		MsgBox, OnHideout Recalibrated!
		return

	updateOnChar:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			If (YesUltraWide)
			{
			vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
			}
			Else
			{
			vX_OnChar:=X + Round(A_ScreenWidth / (1920 / 41))
			}
			WinGetPos,,, Width, Height  ; Uses the window found above.
			vY_OnChar:=Y + Round(A_ScreenHeight / (1080 / 915))
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnChar, vX_OnChar, vY_OnChar
		IniWrite, %varOnChar%, settings.ini, Failsafe Colors, OnChar
		readFromFile()
		MsgBox, OnChar Recalibrated!
		return

	updateOnInventory:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			WinGetPos, X, Y, Width, Height  ; Uses the window found above.
			If (YesUltraWide)
				{
				vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
				}
			Else
				{
				vX_OnInventory:=X + Round(A_ScreenWidth / (1920 / 1583))
				}
			vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnInventory, vX_OnInventory, vY_OnInventory
		IniWrite, %varOnInventory%, settings.ini, Failsafe Colors, OnInventory
		readFromFile()
		MsgBox, OnInventory Recalibrated!
		return

	updateOnStash:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			WinGetPos, X, Y, Width, Height  ; Uses the window found above.
			If (YesUltraWide)
				{
				vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
				}
			Else
				{
				vX_OnStash:=X + Round(A_ScreenWidth / (1920 / 336))
				}
			vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnStash, vX_OnStash, vY_OnStash
		IniWrite, %varOnStash%, settings.ini, Failsafe Colors, OnStash
		readFromFile()
		MsgBox, OnStash Recalibrated!
		return
		
	updateOnChat:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			If (YesUltraWide)
			{
			vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
			}
			Else
			{
			vX_OnChat:=X + Round(A_ScreenWidth / (1920 / 0))
			}
			WinGetPos,,, Width, Height  ; Uses the window found above.
			vY_OnChar:=Y + Round(A_ScreenHeight / (1080 / 915))
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnChat, vX_OnChat, vY_OnChat
		IniWrite, %varOnChat%, settings.ini, Failsafe Colors, OnChat
		readFromFile()
		MsgBox, OnChat Recalibrated!
		return

	updateOnVendor:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			If (YesUltraWide)
			{
			vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
			}
			Else
			{
			vX_OnVendor:=X + Round(A_ScreenWidth / (1920 / 618))
			}
			WinGetPos,,, Width, Height  ; Uses the window found above.
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, varOnVendor, vX_OnVendor, vY_OnVendor
		IniWrite, %varOnVendor%, settings.ini, Failsafe Colors, OnVendor
		readFromFile()
		MsgBox, OnVendor Recalibrated!
		return

	updateDetonate:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			If (YesUltraWide)
			{
			DetonateX:=X + Round(A_ScreenWidth / (3840 / 3578))
			}
			Else
			{
			DetonateX:=X + Round(A_ScreenWidth / (1920 / 1658))
			}
			WinGetPos,,, Width, Height  ; Uses the window found above.
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, DetonateHex, DetonateX, DetonateY
		IniWrite, %DetonateHex%, settings.ini, Failsafe Colors, DetonateHex
		readFromFile()
		MsgBox, Detonate Recalibrated!
		return

	updateDetonateDelve:
		Gui, Submit, NoHide
		IfWinExist, ahk_class POEWindowClass 
		{
			If (YesUltraWide)
			{
			DetonateDelveX:=X + Round(A_ScreenWidth / (3840 / 3578))
			}
			Else
			{
			DetonateDelveX:=X + Round(A_ScreenWidth / (1920 / 1658))
			}
			WinGetPos,,, Width, Height  ; Uses the window found above.
		}
		IfWinActive, ahk_class POEWindowClass 
		{
			WinActivate, ahk_class POEWindowClass
		}
		pixelgetcolor, DetonateHex, DetonateDelveX, DetonateDelveY
		IniWrite, %DetonateHex%, settings.ini, Failsafe Colors, DetonateHex
		readFromFile()
		MsgBox, DetonateDelve Recalibrated!
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
		IniWrite, %YesUltraWide%, settings.ini, General, YesUltraWide
		IniWrite, %YesStashKeys%, settings.ini, General, YesStashKeys
		IniWrite, %ShowOnStart%, settings.ini, General, ShowOnStart
		If (DetonateMines&&!Detonated)
			SetTimer, TMineTick, 100
			Else If (!DetonateMines)
			SetTimer, TMineTick, off
		Return

	LaunchHelp:
	Run, https://www.autohotkey.com/docs/KeyList.htm ; Open the AutoHotkey List of Keys
	Return

	LaunchWiki:
	Run, https://github.com/BanditTech/WingmanReloaded/wiki ; Open the wiki page for the script
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
	RemoveToolTip:
		SetTimer, RemoveToolTip, Off
		ToolTip
		return



return
