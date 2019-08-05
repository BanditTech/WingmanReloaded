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

; Check for window to open
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SetTimer, PoEWindowCheck, 5000

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

	;Flask Cooldowns
		global CoolDownFlask1:=5000
		global CoolDownFlask2:=5000
		global CoolDownFlask3:=5000
		global CoolDownFlask4:=5000
		global CoolDownFlask5:=5000
		global CoolDown:=5000

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
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Standard ini read
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	If FileExist("settings.ini"){ 
		;General
		IniRead, Speed, settings.ini, General, Speed
		IniRead, QTick, settings.ini, General, QTick
		IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD
		IniRead, ResolutionScale, settings.ini, General, ResolutionScale
		;Coordinates
		IniRead, GuiX, settings.ini, Coordinates, GuiX
		IniRead, GuiY, settings.ini, Coordinates, GuiY
		;Failsafe Colors
		IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout
		IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar
		IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat
		IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor
		IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash
		IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory
		;Flask Cooldowns
		IniRead, CoolDownFlask1, settings.ini, Flask Cooldowns, CoolDownFlask1
		IniRead, CoolDownFlask2, settings.ini, Flask Cooldowns, CoolDownFlask2
		IniRead, CoolDownFlask3, settings.ini, Flask Cooldowns, CoolDownFlask3
		IniRead, CoolDownFlask4, settings.ini, Flask Cooldowns, CoolDownFlask4
		IniRead, CoolDownFlask5, settings.ini, Flask Cooldowns, CoolDownFlask5
		;Quicksilver
		IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay
		IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver
		IniRead, QuicksilverSlot1, settings.ini, Quicksilver, QuicksilverSlot1
		IniRead, QuicksilverSlot2, settings.ini, Quicksilver, QuicksilverSlot2
		IniRead, QuicksilverSlot3, settings.ini, Quicksilver, QuicksilverSlot3
		IniRead, QuicksilverSlot4, settings.ini, Quicksilver, QuicksilverSlot4
		IniRead, QuicksilverSlot5, settings.ini, Quicksilver, QuicksilverSlot5
		;Hotkeys
		IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver
		} 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Extra vars - Not in INI
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	global TriggerQ=00000
	global AutoQuick=0 
	global OnCoolDown:=[0,0,0,0,0]
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
		WinActivate, ahk_group POEGameGroup
	}

If hotkeyAutoQuicksilver
	hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On


;Pop all flasks
PopFlaskCooldowns(){
	If (PopFlaskRespectCD)
		TriggerFlaskCD(11111)
	Else {
		OnCoolDown[1]:=1 
		settimer, TimmerFlask1, %CoolDownFlask1%
		OnCoolDown[4]:=1 
		settimer, TimmerFlask4, %CoolDownFlask2%
		OnCoolDown[3]:=1 
		settimer, TimmerFlask3, %CoolDownFlask3%
		OnCoolDown[2]:=1 
		settimer, TimmerFlask2, %CoolDownFlask4%
		OnCoolDown[5]:=1 
		settimer, TimmerFlask5, %CoolDownFlask5%
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
			OnCoolDown[1]:=1 
			SendMSG(3, 1, scriptPOEWingman)
			settimer, TimmerFlask1, %CoolDownFlask1%
			return
			}		
		If (lParam=2){
			OnCoolDown[2]:=1 
			settimer, TimmerFlask2, %CoolDownFlask2%
			return
			}		
		If (lParam=3){
			OnCoolDown[3]:=1 
			settimer, TimmerFlask3, %CoolDownFlask3%
			return
			}		
		If (lParam=4){
			OnCoolDown[4]:=1 
			settimer, TimmerFlask4, %CoolDownFlask4%
			return
			}		
		If (lParam=5){
			OnCoolDown[5]:=1 
			settimer, TimmerFlask5, %CoolDownFlask5%
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
	IniRead, Speed, settings.ini, General, Speed
	IniRead, QTick, settings.ini, General, QTick
	IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD
	IniRead, ResolutionScale, settings.ini, General, ResolutionScale
	;Coordinates
	IniRead, GuiX, settings.ini, Coordinates, GuiX
	IniRead, GuiY, settings.ini, Coordinates, GuiY
	;Failsafe Colors
	IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout
	IniRead, varOnChar, settings.ini, Failsafe Colors, OnChar
	IniRead, varOnChat, settings.ini, Failsafe Colors, OnChat
	IniRead, varOnVendor, settings.ini, Failsafe Colors, OnVendor
	IniRead, varOnStash, settings.ini, Failsafe Colors, OnStash
	IniRead, varOnInventory, settings.ini, Failsafe Colors, OnInventory
	;Flask Cooldowns
	IniRead, CoolDownFlask1, settings.ini, Flask Cooldowns, CoolDownFlask1
	IniRead, CoolDownFlask2, settings.ini, Flask Cooldowns, CoolDownFlask2
	IniRead, CoolDownFlask3, settings.ini, Flask Cooldowns, CoolDownFlask3
	IniRead, CoolDownFlask4, settings.ini, Flask Cooldowns, CoolDownFlask4
	IniRead, CoolDownFlask5, settings.ini, Flask Cooldowns, CoolDownFlask5
	;Quicksilver
	IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay
	IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver
	IniRead, QuicksilverSlot1, settings.ini, Quicksilver, QuicksilverSlot1
	IniRead, QuicksilverSlot2, settings.ini, Quicksilver, QuicksilverSlot2
	IniRead, QuicksilverSlot3, settings.ini, Quicksilver, QuicksilverSlot3
	IniRead, QuicksilverSlot4, settings.ini, Quicksilver, QuicksilverSlot4
	IniRead, QuicksilverSlot5, settings.ini, Quicksilver, QuicksilverSlot5
	;Hotkeys
	IniRead, hotkeyPopFlasks, settings.ini, hotkeys, PopFlasks
	IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver
	IfWinExist, ahk_group POEGameGroup
		{
			Rescale()
			Gui, Show, x%GuiX% y%GuiY%, NoActivate 
			WinActivate, ahk_group POEGameGroup
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

		if ((AutoQuick=1)&&(QuicksilverSlot1=1) || (QuicksilverSlot2=1) || (QuicksilverSlot3=1) || (QuicksilverSlot4=1) || (QuicksilverSlot5=1)) {
			TriggerFlask(TriggerQuicksilver)
			}
		}
	}

TriggerFlask(Trigger){
	If ((!FlaskList.Count())&& !( (OnCoolDown[1]) || (OnCoolDown[2]) || (OnCoolDown[3]) || (OnCoolDown[4]) || (OnCoolDown[5]) ) ) {
		QFL=1
		loop, 5 {
			QFLVal:=SubStr(Trigger,QFL,1)+0
			if (QFLVal > 0) {
				if (OnCoolDown[QFL]=0)
					FlaskList.Push(QFL)
				}
			++QFL
			}
		} 
	Else If !( (OnCoolDown[1]) || (OnCoolDown[2]) || (OnCoolDown[3]) || (OnCoolDown[4]) || (OnCoolDown[5]) ){
		Keywait, LButton, t%TriggerQuicksilverDelay% ;time to wait how long left mouse button has to be pressed
		if (ErrorLevel=1) {
			QFL:=FlaskList.RemoveAt(1)
			send %QFL%
			OnCoolDown[QFL] := 1 
			CoolDown:=CoolDownFlask%QFL%
			settimer, TimmerFlask%QFL%, %CoolDown%
			SendMSG(3, QFL, scriptPOEWingman)
			RandomSleep(23,59)
			}
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
			if (OnCoolDown[QFL]=0) {
				if (ErrorLevel=1) {
					OnCoolDown[QFL]:=1 
					CoolDown:=CoolDownFlask%QFL%
					settimer, TimmerFlask%QFL%, %CoolDown%
					}					
				}
			}
		++QFL
		}
	Return
	}
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