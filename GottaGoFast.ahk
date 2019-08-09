#IfWinActive Path of Exile
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
#Warn  
#Persistent 
#InstallMouseHook
#MaxThreadsPerHotkey 2
#NoTrayIcon
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

Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
Global scriptPOEWingmanSecondary := "WingmanReloaded ahk_exe AutoHotkey.exe"
global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
for n, exe in POEGameArr {
	GroupAdd, POEGameGroup, ahk_exe %exe%
	}
Hotkey, IfWinActive, ahk_group POEGameGroup

SetTitleMatchMode 3 
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SetWorkingDir %A_ScriptDir%  
Thread, interrupt, 0

OnMessage(0x5555, "MsgMonitor")
OnMessage(0x5556, "MsgMonitor")

I_Icon = phase_run_skill_icon.ico
IfExist, %I_Icon%
  Menu, Tray, Icon, %I_Icon%
  
if not A_IsAdmin
{
	Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	ExitApp
}

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Global variables
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	;General
		; Dont change the speed & the tick unless you know what you are doing
		global Speed:=1
		global QTick:=250
		global PopFlaskRespectCD:=1
		global ResolutionScale:="Standard"
		Global ToggleExist := False
		Global RescaleRan := False
		Global FlaskList := []

	;Coordinates
		global GuiX:=-5
		global GuiY:=1005

	;Failsafe Colors
		global varOnHideout
		global varOnChar
		global varOnChat
		global varOnInventory
		global varOnStash
		global varOnVendor

	;Utility Buttons
		global YesPhaseRun := 1
		global YesVaalDiscipline:=1

	;Utility Cooldowns
		global CooldownUtility1:=5000
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
		global TriggerQuicksilverDelay:=0.8
		global TriggerQuicksilver:=00000
		global QuicksilverSlot1:=0
		global QuicksilverSlot2:=0
		global QuicksilverSlot3:=0
		global QuicksilverSlot4:=0
		global QuicksilverSlot5:=0
	
	;Gui Status
		global OnHideout:=False
		global OnChar:=False
		global OnChat:=False
		global OnInventory:=False
		global OnStash:=False
		global OnVendor:=False

	;Hotkeys
		global hotkeyAutoQuicksilver
	
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
		global KeyUtility1, YesUtility2, YesUtility3, YesUtility4, YesUtility5

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Standard ini read
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		;General
			IniRead, Speed, settings.ini, General, Speed, 1
			IniRead, QTick, settings.ini, General, QTick, 50
			IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
			IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
		;Coordinates
			IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
			IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027
		;Failsafe Colors
			IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0x161114
			IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar, 0x4F6980
			IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat, 0x3B6288
			IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor, 0x7BB1CC
			IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash, 0x9BD6E7
			IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory, 0x8CC6DD
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
			IniRead, YesUtility1EsPercent, settings.ini, Utility Buttons, YesUtility1EsPercent, Off
			IniRead, YesUtility2EsPercent, settings.ini, Utility Buttons, YesUtility2EsPercent, Off
			IniRead, YesUtility3EsPercent, settings.ini, Utility Buttons, YesUtility3EsPercent, Off
			IniRead, YesUtility4EsPercent, settings.ini, Utility Buttons, YesUtility4EsPercent, Off
			IniRead, YesUtility5EsPercent, settings.ini, Utility Buttons, YesUtility5EsPercent, Off

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

		;Flask Cooldowns
			IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1, 4800
			IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2, 4800
			IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3, 4800
			IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4, 4800
			IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5, 4800
		;Quicksilver
			IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, 0.5
			IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
			IniRead, QuicksilverSlot1, settings.ini, Quicksilver, QuicksilverSlot1, 0
			IniRead, QuicksilverSlot2, settings.ini, Quicksilver, QuicksilverSlot2, 0
			IniRead, QuicksilverSlot3, settings.ini, Quicksilver, QuicksilverSlot3, 0
			IniRead, QuicksilverSlot4, settings.ini, Quicksilver, QuicksilverSlot4, 0
			IniRead, QuicksilverSlot5, settings.ini, Quicksilver, QuicksilverSlot5, 0
		;hotkeys
			IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, %A_Space%
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Extra vars - Not in INI
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	global TriggerQ=00000
	global AutoQuick=0 
	global OnCooldown:=[0,0,0,0,0]
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Scale positions for status check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IfWinExist, ahk_group POEGameGroup
	{
	Rescale()
	WinActivate, ahk_group POEGameGroup
	} Else {
	global vX_OnHideout:=1241
	global vY_OnHideout:=951
	global vX_OnChar:=41
	global vY_OnChar:=915
	global vX_OnChat:=0
	global vY_OnChat:=653
	global vX_OnInventory:=1583
	global vY_OnInventory:=36
	global vX_OnStash:=336
	global vY_OnStash:=32
	global vX_OnVendor:=618
	global vY_OnVendor:=88
	}
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Ingame Overlay (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Gui, Color, 0X130F13
Gui +LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, 0X130F13
Gui -Caption
Gui, Font, bold cFFFFFF S10, Trebuchet MS
Gui, Add, Text, y+35 BackgroundTrans vT1, Quicksilver: OFF
IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		Gui, Show, x%GuiX% y%GuiY%, NoActivate 
		ToggleExist := True
		WinActivate, ahk_group POEGameGroup
	}

If hotkeyAutoQuicksilver
	hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On

; Check for window to open
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SetTimer, PoEWindowCheck, 5000

; Start timer for active Utility that is not triggered by Life, ES, or QS
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Loop, 5 {
		if ( (YesUtility%A_Index%) && !(YesUtility%A_Index%Quicksilver) && (YesUtility%A_Index%LifePercent="Off") && (YesUtility%A_Index%ESPercent="Off") ){
			SetTimer, TUtilityTick, 250
			Break
		}
		Else If (YesUtility%A_Index%) && ( (YesUtility%A_Index%Quicksilver) || (YesUtility%A_Index%ESPercent!="Off") || (YesUtility%A_Index%LifePercent!="Off") )
			SetTimer, TUtilityTick, Off
		Else
			SetTimer, TUtilityTick, Off
		}

;Pop all flasks
PopFlaskCooldowns(){
	If (PopFlaskRespectCD)
		TriggerFlaskCD(11111)
	Else {
		OnCooldown[1]:=1 
		settimer, TimmerFlask1, %CooldownFlask1%
		OnCooldown[4]:=1 
		settimer, TimmerFlask4, %CooldownFlask2%
		OnCooldown[3]:=1 
		settimer, TimmerFlask3, %CooldownFlask3%
		OnCooldown[2]:=1 
		settimer, TimmerFlask2, %CooldownFlask4%
		OnCooldown[5]:=1 
		settimer, TimmerFlask5, %CooldownFlask5%
		}
	return
	}

~#Escape::
	ExitApp

;Toggle Auto-Quick
AutoQuicksilverCommand:
    AutoQuick := !AutoQuick	
	if (!AutoQuick) {
        SetTimer TQuickTick, Off
    } else {
        SetTimer TQuickTick, %QTick%	
    }
	GuiUpdate()
	return
; Receive Messages from other scripts
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MsgMonitor(wParam, lParam, msg)
	{
	critical
    If (wParam=1){
		ReadFromFile()
		FlaskList:=[]
	}
	Else If (wParam=2)
		PopFlaskCooldowns()
	Else If (wParam=3) {
		If (lParam=1){
			OnCooldown[1]:=1 
			SendMSG(3, 1, scriptPOEWingman)
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
	Return
	}
; Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0, script:=""){
	DetectHiddenWindows On
	if WinExist(script) 
		PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
	else if WinExist(scriptPOEWingmanSecondary)
		PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
	else
		MsgBox, Either Script Window Not Found
	DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
	}
PoEWindowCheck(){
	IfWinExist, ahk_group POEGameGroup 
		{
		global GuiX, GuiY, RescaleRan, ToggleExist
		If (!RescaleRan)
			Rescale()
		If (!ToggleExist) {
			Gui 1: Show, x%GuiX% y%GuiY%, NoActivate 
			ToggleExist := True
			WinActivate, ahk_group POEGameGroup
			}
		} Else {
		If (ToggleExist){
			Gui 1: Show, Hide
			ToggleExist := False
			}
		}
	Return
	}

ReadFromFile(){
	Global
	;General
		IniRead, Speed, settings.ini, General, Speed, 1
		IniRead, QTick, settings.ini, General, QTick, 50
		IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
		IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
	;Coordinates
		IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
		IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027
	;Failsafe Colors
		IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0x161114
		IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar, 0x4F6980
		IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat, 0x3B6288
		IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor, 0x7BB1CC
		IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash, 0x9BD6E7
		IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory, 0x8CC6DD
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
		IniRead, YesUtility1EsPercent, settings.ini, Utility Buttons, YesUtility1EsPercent, Off
		IniRead, YesUtility2EsPercent, settings.ini, Utility Buttons, YesUtility2EsPercent, Off
		IniRead, YesUtility3EsPercent, settings.ini, Utility Buttons, YesUtility3EsPercent, Off
		IniRead, YesUtility4EsPercent, settings.ini, Utility Buttons, YesUtility4EsPercent, Off
		IniRead, YesUtility5EsPercent, settings.ini, Utility Buttons, YesUtility5EsPercent, Off

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

	;Flask Cooldowns
		IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1, 4800
		IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2, 4800
		IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3, 4800
		IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4, 4800
		IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5, 4800
	;Quicksilver
		IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, 0.5
		IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
		IniRead, QuicksilverSlot1, settings.ini, Quicksilver, QuicksilverSlot1, 0
		IniRead, QuicksilverSlot2, settings.ini, Quicksilver, QuicksilverSlot2, 0
		IniRead, QuicksilverSlot3, settings.ini, Quicksilver, QuicksilverSlot3, 0
		IniRead, QuicksilverSlot4, settings.ini, Quicksilver, QuicksilverSlot4, 0
		IniRead, QuicksilverSlot5, settings.ini, Quicksilver, QuicksilverSlot5, 0
	;hotkeys
		IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, %A_Space%
	IfWinExist, ahk_group POEGameGroup
		{
		Rescale()
		If (!ToggleExist){
			Gui, Show, x%GuiX% y%GuiY%, NoActivate 
			WinActivate, ahk_group POEGameGroup
			}
		}
	; Start timer for active Utility that is not triggered by Life, ES, or QS
	; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Loop, 5 {
			if ( (YesUtility%A_Index%) && !(YesUtility%A_Index%Quicksilver) && (YesUtility%A_Index%LifePercent="Off") && (YesUtility%A_Index%ESPercent="Off") ){
				SetTimer, TUtilityTick, 250
				Break
			}
			Else If (YesUtility%A_Index%) && ( (YesUtility%A_Index%Quicksilver) || (YesUtility%A_Index%ESPercent!="Off") || (YesUtility%A_Index%LifePercent!="Off") )
				SetTimer, TUtilityTick, Off
			Else
				SetTimer, TUtilityTick, Off
			}
	Return
	}
RandomSleep(min,max){
	Random, r, %min%, %max%
	r:=floor(r/Speed)
	Sleep %r%
	return
	}

GuiUpdate(){
	if (AutoQuick=1) {
	AutoQuickToggle:="ON" 
	} else AutoQuickToggle:="OFF" 
	GuiControl ,, T1, Quicksilver: %AutoQuickToggle%
	Return
	}

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
	Return
	}

TQuickTick(){
	IfWinActive, Path of Exile
		{
		;pixelgetcolor, OnHideout, vX_OnHideout, vY_OnHideout
		;pixelgetcolor, OnChar, vX_OnChar, vY_OnChar
		GuiStatus("OnHideout")
		GuiStatus("OnChar")
		GuiStatus("OnChat")
		GuiStatus("OnInventory")
	
		if (OnHideout || !OnChar || OnChat || OnInventory) { ;in Hideout, not on char, chat open, or open inventory
			GuiUpdate()
			Exit
			}

		if ((AutoQuick=1)&&((QuicksilverSlot1=1) || (QuicksilverSlot2=1) || (QuicksilverSlot3=1) || (QuicksilverSlot4=1) || (QuicksilverSlot5=1))) {
			TriggerFlask(TriggerQuicksilver)
			}
		}
	}

TUtilityTick(){
	IfWinActive, Path of Exile
		{
		GuiStatus("OnHideout")
		GuiStatus("OnChar")
		GuiStatus("OnChat")
		GuiStatus("OnInventory")
	
		if (OnHideout || !OnChar || OnChat || OnInventory) { ;in Hideout, not on char, chat open, or open inventory
			GuiUpdate()
			Exit
			}

		if ( ( (YesUtility1) && !(YesUtility1Quicksilver) && (YesUtility1LifePercent="Off") && (YesUtility1ESPercent="Off") ) || ( (YesUtility2) && !(YesUtility2Quicksilver) && (YesUtility2LifePercent="Off") && (YesUtility2ESPercent="Off") ) || ( (YesUtility3) && !(YesUtility3Quicksilver) && (YesUtility3LifePercent="Off") && (YesUtility3ESPercent="Off") ) || ( (YesUtility4) && !(YesUtility4Quicksilver) && (YesUtility4LifePercent="Off") && (YesUtility4ESPercent="Off") ) || ( (YesUtility5) && !(YesUtility5Quicksilver) && (YesUtility5LifePercent="Off") && (YesUtility5ESPercent="Off") ) ) {
			Loop, 5 {
				If (YesUtility%A_Index%) && !(YesUtility%A_Index%Quicksilver) && !(YesUtility%A_Index%LifePercent!="Off") && !(YesUtility%A_Index%ESPercent!="Off")
					TriggerUtility(A_Index)
				}
			}
		}
	}

TriggerFlask(Trigger){
	If ((!FlaskList.Count())&& !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) ) {
		QFL=1
		loop, 5 {
			QFLVal:=SubStr(Trigger,QFL,1)+0
			if (QFLVal > 0) {
				if (OnCooldown[QFL]=0)
					FlaskList.Push(QFL)
				}
			++QFL
			}
		} 
	Else If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ){
		Keywait, LButton, t%TriggerQuicksilverDelay% ;time to wait how long left mouse button has to be pressed
		if (ErrorLevel=1) {
			QFL:=FlaskList.RemoveAt(1)
			send %QFL%
			OnCooldown[QFL] := 1 
			Cooldown:=CooldownFlask%QFL%
			settimer, TimmerFlask%QFL%, %Cooldown%
			SendMSG(3, QFL, scriptPOEWingman)
			RandomSleep(23,59)
			Loop, 5 {
				If (YesUtility%A_Index%) && (YesUtility%A_Index%Quicksilver){
					TriggerUtility(A_Index)
					}
				}
			}
		}
	Return
	}

TriggerUtility(Utility){
	If (!OnCooldownUtility%Utility%)&&(YesUtility%Utility%){
		key:=KeyUtility%Utility%
		Send %key%
		SendMSG(4, Utility, scriptPOEWingman)
		OnCooldownUtility%Utility%:=1
		Cooldown:=CooldownUtility%Utility%
		SetTimer, TimerUtility%Utility%, %Cooldown%
		}
	Return
	} 

Rescale(){
	IfWinExist, ahk_group POEGameGroup 
		{
		WinGetPos, X, Y, W, H
		If (ResolutionScale="Standard") {
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
			;GUI overlay
			global GuiX:=X + Round(A_ScreenWidth / (1920 / -10))
			global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
			}
		Else If (ResolutionScale="UltraWide") {
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
			;GUI overlay
			global GuiX:=X + Round(A_ScreenWidth / (3840 / -10))
			global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
			}
		Else If (ResolutionScale="QHD") {
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
			;GUI overlay
			global GuiX:=X + Round(A_ScreenWidth / (2560 / -10))
			global GuiY:=Y + Round(A_ScreenHeight / (1440 / 1027))
			}
		Global RescaleRan := True
		}
	return
	}

TriggerFlaskCD(Trigger){
	QFL=1
	loop, 5 {
		QFLVal:=SubStr(Trigger,QFL,1)+0
		if (QFLVal > 0) {
			if (OnCooldown[QFL]=0) {
				if (ErrorLevel=1) {
					OnCooldown[QFL]:=1 
					Cooldown:=CooldownFlask%QFL%
					settimer, TimmerFlask%QFL%, %Cooldown%
					}					
				}
			}
		++QFL
		}
	Return
	}
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
