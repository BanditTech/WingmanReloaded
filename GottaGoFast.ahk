#IfWinActive Path of Exile
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
;#Warn  
#Persistent 
#InstallMouseHook
#MaxThreads 10
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
; Extra vars - Not in INI
global TriggerQ:=00000
global AutoQuit:=0 
global AutoFlask:=0
global AutoQuick:=0 
global OnCooldown:=[0,0,0,0,0]

global newposition := false
global newpositionPOV := false
global JoystickNumber := 0
global JoystickActive := False
Global Latency := 1
Global YesPersistantToggle := 1

Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
for n, exe in POEGameArr {
     GroupAdd, POEGameGroup, ahk_exe %exe%
}
Hotkey, IfWinActive, ahk_group POEGameGroup

SetTitleMatchMode 2
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SetWorkingDir %A_ScriptDir%  
Thread, interrupt, 0
global pressed1 := False
global pressed2 := False
global pressed3 := False
global pressed4 := False
global pressed5 := False
global pressed6 := False
global pressed7 := False
global pressed8 := False
global pressed9 := False
global pressed10 := False
global pressed11 := False
global pressed12 := False
global pressed13 := False
global pressed14 := False
global pressed15 := False
global pressed16 := False
global pressed17 := False
global pressed18 := False
global pressed19 := False
global pressed20 := False
global pressedJoy2 := False
global pressedVacuum := 0
Global AreaScale := 2
Global LootColors := { 1 : 0x222222
     , 2 : 0xFFFFFF}

OnMessage(0x5555, "MsgMonitor")
OnMessage(0x5556, "MsgMonitor")

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
Global LootVacuum := 1
global PopFlaskRespectCD:=1
global ResolutionScale:="Standard"
Global ToggleExist := False
Global RescaleRan := False
Global FlaskListQS := []
Global DebugMessages
Global QSonMainAttack := 0
Global QSonSecondaryAttack := 0
Global LButtonPressed := 0
Global MainPressed := 0
Global SecondaryPressed := 0

;Controller
Global YesController := 1
global checkvar:=0
global checkvarJoystick:=0
global checkvarJoy2:=False
Global YesMovementKeys := 0
Global YesTriggerUtilityKey := 0
Global TriggerUtilityKey := 1
Global JoystickNumber := 0
Global JoyThreshold := 6
global JoyThresholdUpper := 50 + JoyThreshold
global JoyThresholdLower := 50 - JoyThreshold
Global Joy2Threshold := 10
global Joy2ThresholdUpper := 50 + Joy2Threshold
global Joy2ThresholdLower := 50 - Joy2Threshold
global InvertYAxis := false
global JoyMultiplier := 6
global JoyMultiplier2 := 8
global hotkeyControllerButton1,hotkeyControllerButton2,hotkeyControllerButton3,hotkeyControllerButton4,hotkeyControllerButton5,hotkeyControllerButton6,hotkeyControllerButton7,hotkeyControllerButton8,hotkeyControllerButton9,hotkeyControllerButton10,hotkeyControllerJoystick2
global YesTriggerUtilityJoystickKey := 1
global YesTriggerJoystick2Key := 1
global HeldCountJoystick := 0
global HeldCountJoystick2 := 0
global HeldCountPOV := 1	


if InvertYAxis
    global YAxisMultiplier = -1
else
    global YAxisMultiplier = 1
;Coordinates
global GuiX:=-5
global GuiY:=1005

;Failsafe Colors
global varOnHideout
global varOnHideoutMin
global varOnChar
global varOnChat
global varOnInventory
global varOnStash
global varOnVendor
global varOnMenu

;Flask Cooldowns
global CooldownFlask1:=5000
global CooldownFlask2:=5000
global CooldownFlask3:=5000
global CooldownFlask4:=5000
global CooldownFlask5:=5000
global Cooldown:=5000

;Flask hotkeys
global keyFlask1:=1
global keyFlask2:=2
global keyFlask3:=3
global keyFlask4:=4
global keyFlask5:=5

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
global OnMenu:=False

;Hotkeys
global hotkeyAutoQuicksilver
global hotkeyMainAttack
global hotkeySecondaryAttack
global hotkeyLootScan
global hotkeyUp := "W"
global hotkeyDown := "S"
global hotkeyLeft := "A"
global hotkeyRight := "D"

global utilityKeyToFire := 1
global y_offset := 150	
global x_POVscale := 5	
global y_POVscale := 5	


global x_center := 1920 / 2
global compensation := (1920 / 1080) == (16 / 10) ? 1.103829 : 1.103719
global y_center := 1080 / 2 / compensation
global offset_mod := y_offset / 1080
global x_offset := 1920 * (offset_mod / 1.5 )


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

;Utility Icons
global IconStringUtility1, IconStringUtility2, IconStringUtility3, IconStringUtility4, IconStringUtility5

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Standard ini read
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;General
IniRead, Speed, settings.ini, General, Speed, 1
IniRead, QTick, settings.ini, General, QTick, 150
IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
IniRead, DebugMessages, settings.ini, General, DebugMessages, 0
IniRead, QSonMainAttack, settings.ini, General, QSonMainAttack, 0
IniRead, QSonSecondaryAttack, settings.ini, General, QSonSecondaryAttack, 0
IniRead, LootVacuum, settings.ini, General, LootVacuum, 0
IniRead, AreaScale, settings.ini, General, AreaScale, 0

;Coordinates
IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027

;Failsafe Colors
IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0x161114
IniRead, varOnHideoutMin, settings.ini, Failsafe Colors, OnHideoutMin, 0xCDF6FE
IniRead, varOnMenu, settings.ini, Failsafe Colors, OnMenu, 0x7BB9D6
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

;Flask Keys
IniRead, keyFlask1, settings.ini, Flask Keys, keyFlask1, 1
IniRead, keyFlask2, settings.ini, Flask Keys, keyFlask2, 2
IniRead, keyFlask3, settings.ini, Flask Keys, keyFlask3, 3
IniRead, keyFlask4, settings.ini, Flask Keys, keyFlask4, 4
IniRead, keyFlask5, settings.ini, Flask Keys, keyFlask5, 5

;Flask Cooldowns
IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1, 4800
IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2, 4800
IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3, 4800
IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4, 4800
IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5, 4800

;Quicksilver
IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, 0.5
IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
Loop, 5 {	
     valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
     QuicksilverSlot%A_Index% := valueQuicksilver
}

;hotkeys
IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, !MButton
IniRead, hotkeyMainAttack, settings.ini, hotkeys, MainAttack, RButton
IniRead, hotkeySecondaryAttack, settings.ini, hotkeys, SecondaryAttack, w
If hotkeyAutoQuicksilver
hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On
IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan, f
IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI, Space

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

IniRead, Latency, settings.ini, General, Latency, 1

DetectJoystick()
IniRead, YesPersistantToggle, settings.ini, General, YesPersistantToggle, 0
;Set up timer if checkbox ticked
If (YesMovementKeys)
SetTimer, WASD_Handler, 15
Else
SetTimer, WASD_Handler, Delete
;Set up timer if checkbox ticked
If (YesController)
{
	SetTimer, JoyButtons_Handler, 15
	SetTimer, Joystick_Handler, 15
	SetTimer, Joystick2_Handler, 15
}
Else
{
	SetTimer, JoyButtons_Handler, Delete
	SetTimer, Joystick_Handler, Delete
	SetTimer, Joystick2_Handler, Delete
}

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Scale positions for status check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IfWinExist, ahk_group POEGameGroup
{
     Rescale()
     WinActivate, ahk_group POEGameGroup
} Else {
     global vX_OnHideout:=1178
     global vY_OnHideout:=930
     global vY_OnHideoutMin:=1053
     global vX_OnMenu:=960
     global vY_OnMenu:=32
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
     If (YesPersistantToggle)
          AutoReset()
}

; Set timers section
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
IniWrite, %AutoQuick%, settings.ini, Previous Toggles, AutoQuick
if (!AutoQuick) {
     SetTimer TQuickTick, Off
} else {
     SetTimer TQuickTick, %QTick%	
}
GuiUpdate()
return
; Load Previous Toggle States
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AutoReset(){
	IniRead, AutoQuick, settings.ini, Previous Toggles, AutoQuick, 0
     if (!AutoQuick) {
          SetTimer TQuickTick, Off
     } else {
          SetTimer TQuickTick, %QTick%	
     }
	GuiUpdate()	
return
}

; Receive Messages from other scripts
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MsgMonitor(wParam, lParam, msg)
{
     Thread, NoTimers, true   ;critical
     If (wParam=1){
          ReadFromFile()
          FlaskListQS:=[]
          DetectJoystick()
     }
     Else If (wParam=2)
     PopFlaskCooldowns()
     Else If (wParam=3) {
          If (lParam=1){
               OnCooldown[1]:=1 
               SendMSG(3, 1)
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
     Else If (wParam=5) {
          If (lParam=1){
               If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) || ((QuicksilverSlot2=1)&&(OnCooldown[2])) || ((QuicksilverSlot3=1)&&(OnCooldown[3])) || ((QuicksilverSlot4=1)&&(OnCooldown[4])) || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) {
                    If  ( (QuicksilverSlot1 && OnCooldown[1]) || (QuicksilverSlot2 && OnCooldown[2]) || (QuicksilverSlot3 && OnCooldown[3]) || (QuicksilverSlot4 && OnCooldown[4]) || (QuicksilverSlot5 && OnCooldown[5]) )
                    Return
                    TriggerFlask(TriggerQuicksilver)
               }
          }		
          return
     }
     Return
}
; Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0){
     DetectHiddenWindows On
     if WinExist(scriptPOEWingman)
     {
          ; Ding(1000,1,"Script Found`nSending CD to main script")
          PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
     }
     else
          Ding(1000,1,"Wingman Script Not Found`nUnable to share CD") ;Turn on debug messages to see error information from GGF sendMSG
     DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
     Return
}
PoEWindowCheck(){
     DetectHiddenWindows On
     IfWinExist, ahk_group POEGameGroup 
     {
          global GuiX, GuiY, RescaleRan, ToggleExist
          If (!RescaleRan)
          Rescale()
          If (!ToggleExist) {
               Gui 1: Show, x%GuiX% y%GuiY%, NoActivate 
               ToggleExist := True
               DetectJoystick()
               WinActivate, ahk_group POEGameGroup
               If (YesPersistantToggle)
                    AutoReset()
          }
     } Else {
          If (ToggleExist){
               Gui 1: Show, Hide
               ToggleExist := False
          }
     }
     DetectHiddenWindows Off
     Return
}

ReadFromFile(){
     Global
     ;General
     IniRead, Speed, settings.ini, General, Speed, 1
     IniRead, QTick, settings.ini, General, QTick, 50
     IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
     IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
     IniRead, QSonMainAttack, settings.ini, General, QSonMainAttack, 0
     IniRead, QSonSecondaryAttack, settings.ini, General, QSonSecondaryAttack, 0
     IniRead, YesTriggerUtilityKey, settings.ini, General, YesTriggerUtilityKey, 0
     IniRead, TriggerUtilityKey, settings.ini, General, TriggerUtilityKey, 1
     IniRead, YesMovementKeys, settings.ini, General, YesMovementKeys, 0
     IniRead, LootVacuum, settings.ini, General, LootVacuum, 0
     IniRead, AreaScale, settings.ini, General, AreaScale, 0
     ;Coordinates
     IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
     IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027
     ;Failsafe Colors
     IniRead, varOnHideout, settings.ini, Failsafe Colors, OnHideout, 0xB5EFFE
     IniRead, varOnHideoutMin, settings.ini, Failsafe Colors, OnHideoutMin, 0xCDF6FE
     IniRead, varOnMenu, settings.ini, Failsafe Colors, OnMenu, 0x7BB9D6
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

     ;Flask Keys
     IniRead, keyFlask1, settings.ini, Flask Keys, keyFlask1, 1
     IniRead, keyFlask2, settings.ini, Flask Keys, keyFlask2, 2
     IniRead, keyFlask3, settings.ini, Flask Keys, keyFlask3, 3
     IniRead, keyFlask4, settings.ini, Flask Keys, keyFlask4, 4
     IniRead, keyFlask5, settings.ini, Flask Keys, keyFlask5, 5
     
     ;Flask Cooldowns
     IniRead, CooldownFlask1, settings.ini, Flask Cooldowns, CooldownFlask1, 4800
     IniRead, CooldownFlask2, settings.ini, Flask Cooldowns, CooldownFlask2, 4800
     IniRead, CooldownFlask3, settings.ini, Flask Cooldowns, CooldownFlask3, 4800
     IniRead, CooldownFlask4, settings.ini, Flask Cooldowns, CooldownFlask4, 4800
     IniRead, CooldownFlask5, settings.ini, Flask Cooldowns, CooldownFlask5, 4800
     IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan, f
     IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI, Space

	;Controller setup
    IniRead, hotkeyControllerButton1, settings.ini, Controller Keys, ControllerButton1, LButton
    IniRead, hotkeyControllerButton2, settings.ini, Controller Keys, ControllerButton2, %hotkeyLootScan%
    IniRead, hotkeyControllerButton3, settings.ini, Controller Keys, ControllerButton3, q
    IniRead, hotkeyControllerButton4, settings.ini, Controller Keys, ControllerButton4, %hotkeyCloseAllUI%
    IniRead, hotkeyControllerButton5, settings.ini, Controller Keys, ControllerButton5, e
    IniRead, hotkeyControllerButton6, settings.ini, Controller Keys, ControllerButton6, RButton
    IniRead, hotkeyControllerButton7, settings.ini, Controller Keys, ControllerButton7, ItemSort
    IniRead, hotkeyControllerButton8, settings.ini, Controller Keys, ControllerButton8, Logout
    IniRead, hotkeyControllerButton9, settings.ini, Controller Keys, ControllerButton9, Tab
    IniRead, hotkeyControllerButton10, settings.ini, Controller Keys, ControllerButton10, QuickPortal
	
	IniRead, hotkeyControllerJoystick2, settings.ini, Controller Keys, hotkeyControllerJoystick2, RButton

	IniRead, YesTriggerUtilityKey, settings.ini, Controller, YesTriggerUtilityKey, 1
	IniRead, YesTriggerUtilityJoystickKey, settings.ini, Controller, YesTriggerUtilityJoystickKey, 1
	IniRead, YesTriggerJoystick2Key, settings.ini, Controller, YesTriggerJoystick2Key, 1
	IniRead, TriggerUtilityKey, settings.ini, Controller, TriggerUtilityKey, 1
	IniRead, YesMovementKeys, settings.ini, Controller, YesMovementKeys, 0
	IniRead, YesController, settings.ini, Controller, YesController, 0
	IniRead, JoystickNumber, settings.ini, Controller, JoystickNumber, 0

     IniRead, Latency, settings.ini, General, Latency, 1

	DetectJoystick()
     IniRead, YesPersistantToggle, settings.ini, General, YesPersistantToggle, 0
     If (YesPersistantToggle)
          AutoReset()
	;Quicksilver
	IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, 0.5
	IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
	Loop, 5 {	
		valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
		QuicksilverSlot%A_Index% := valueQuicksilver
	}
	;hotkeys
	IniRead, hotkeyMainAttack, settings.ini, hotkeys, MainAttack, RButton
	IniRead, hotkeySecondaryAttack, settings.ini, hotkeys, SecondaryAttack, w
	
	If hotkeyAutoQuicksilver
	hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, Off
	
	IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, !MButton
	
	If hotkeyAutoQuicksilver
	hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		If (!ToggleExist){
			Gui, Show, x%GuiX% y%GuiY%, NoActivate 
			WinActivate, ahk_group POEGameGroup
		}
	}
	;Set up timer if checkbox ticked
	If (YesController)
	{
		SetTimer, JoyButtons_Handler, 15
		SetTimer, Joystick_Handler, 15
		SetTimer, Joystick2_Handler, 15
	}
	Else
	{
		SetTimer, JoyButtons_Handler, Delete
		SetTimer, Joystick_Handler, Delete
		SetTimer, Joystick2_Handler, Delete
	}
     ;Set up timer if checkbox ticked
     If (YesMovementKeys)
     SetTimer, WASD_Handler, 15
     Else
     SetTimer, WASD_Handler, Delete
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
     pixelgetcolor, POnMenu, vX_OnMenu, vY_OnMenu
	If (POnMenu=varOnMenu) {
		OnMenu:=True
		} Else {
		OnMenu:=False
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
          if ( (AutoQuick=1) 
          && ( (QuicksilverSlot1=1) 
          || (QuicksilverSlot2=1) 
          || (QuicksilverSlot3=1) 
          || (QuicksilverSlot4=1) 
          || (QuicksilverSlot5=1) ) ) 
               If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) 
               || ((QuicksilverSlot2=1)&&(OnCooldown[2])) 
               || ((QuicksilverSlot3=1)&&(OnCooldown[3])) 
               || ((QuicksilverSlot4=1)&&(OnCooldown[4])) 
               || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) ; Check if all the flasks are off cooldown
                    TriggerFlask(TriggerQuicksilver)
     }
}

TUtilityTick(){
     IfWinActive, Path of Exile
     {
          GuiStatus()
          if (OnHideout || !OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
               Exit
          Loop, 5
          {
               If (YesUtility%A_Index%) && !(YesUtility%A_Index%Quicksilver) && (YesUtility%A_Index%LifePercent="Off") && (YesUtility%A_Index%ESPercent="Off") && !(IconStringUtility%A_Index%)
                    TriggerUtility(A_Index)
               Else If (YesUtility%A_Index%) && !(YesUtility%A_Index%Quicksilver) && (YesUtility%A_Index%LifePercent="Off") && (YesUtility%A_Index%ESPercent="Off") && (IconStringUtility%A_Index%)
               {
                    If !(OnCooldownUtility%A_Index%)
                    {
                         If FindText(0, 0, A_ScreenWidth, A_ScreenHeight / ( 1080 / 75 ), 0, 0, IconStringUtility%A_Index%)
                         {
                              OnCooldownUtility%A_Index%:=1
                              SetTimer, TimerUtility%A_Index%, % CooldownUtility%A_Index%
                         }
                         Else
                              TriggerUtility(A_Index)
                    }
               }
          }
     }
}

TriggerFlask(Trigger){
     GuiStatus()
     if (OnHideout || !OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
          Exit
     If !(FlaskListQS.Count())
          loop, 5 
               if ((SubStr(Trigger,A_Index,1)+0) > 0) 
                    FlaskListQS.Push(A_Index)
     If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) 
     || ((QuicksilverSlot2=1)&&(OnCooldown[2])) 
     || ((QuicksilverSlot3=1)&&(OnCooldown[3])) 
     || ((QuicksilverSlot4=1)&&(OnCooldown[4])) 
     || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) 
     { ; If all the flasks are off cooldown, then we are ready to fire one
          LButtonPressed := GetKeyState("LButton", "P")
          MainPressed := GetKeyState(hotkeyMainAttack, "P")
          SecondaryPressed := GetKeyState(hotkeySecondaryAttack, "P")
          if (LButtonPressed || (MainPressed && QSonMainAttack) || (SecondaryPressed && QSonSecondaryAttack) ) 
          {
               If (TriggerQuicksilverDelay > 0) 
               {
                    if (LButtonPressed) 
                    {
                         Keywait, LButton, t%TriggerQuicksilverDelay% ;Wait for the key to be released
                         if (ErrorLevel=0)
                              Return
                    }
                    Else If (MainPressed && QSonMainAttack) 
                    {
                         Keywait, %hotkeyMainAttack%, t%TriggerQuicksilverDelay% ;Wait for the key to be released
                         if (ErrorLevel=0) 
                              Return
                    }
                    Else If (SecondaryPressed && QSonSecondaryAttack) 
                    {
                         Keywait, %hotkeySecondaryAttack%, t%TriggerQuicksilverDelay% ;Wait for the key to be released
                         if (ErrorLevel=0) 
                              Return
                    }
               }
               QFL := FlaskListQS.RemoveAt(1)
               If (!QFL)
                    Return
               send % keyFlask%QFL%
               settimer, TimmerFlask%QFL%, % CooldownFlask%QFL%
               OnCooldown[QFL] := 1 
               SendMSG(3, QFL)
               Loop, 5
                    If (YesUtility%A_Index% && YesUtility%A_Index%Quicksilver)
                         TriggerUtility(A_Index)
          }
     }
     Return
}

TriggerFlaskForce(Trigger){
     GuiStatus()
     if (OnHideout || !OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
          Exit
     If !(FlaskListQS.Count())
          loop, 5 
               if ((SubStr(Trigger,A_Index,1)+0) > 0)
                    FlaskListQS.Push(A_Index)
     If !( ((QuicksilverSlot1=1)&&(OnCooldown[1])) 
     || ((QuicksilverSlot2=1)&&(OnCooldown[2])) 
     || ((QuicksilverSlot3=1)&&(OnCooldown[3])) 
     || ((QuicksilverSlot4=1)&&(OnCooldown[4])) 
     || ((QuicksilverSlot5=1)&&(OnCooldown[5])) ) 
     { ; If all the flasks are off cooldown, then we are ready to fire one
          QFL:=FlaskListQS.RemoveAt(1)
          If (!QFL)
               Return
          send % keyFlask%QFL%
          OnCooldown[QFL] := 1 
          settimer, TimmerFlask%QFL%, % CooldownFlask%QFL%
          SendMSG(3, QFL)
          Loop, 5
               If (YesUtility%A_Index% && YesUtility%A_Index%Quicksilver)
                    TriggerUtility(A_Index)
     }
     Return
}

; Debug messages within script
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Ding(Timeout:=500, MultiTooltip:=0 , Message*)
    {
        If (!DebugMessages)
            Return
        Else
        {
            debugStr := ""
            If Message.Count()
            {
                For mkey, mval in Message
                {
                    If mval=
                        Continue
                    If A_Index = 1
                    {
                        If MultiTooltip
                            ToolTip, %mval%, 100, % 50 + MultiTooltip * 23, %MultiTooltip% 
                        Else
                            debugStr .= Message.A_Index
                    }
                    Else if A_Index <= 20
                    {
                        If MultiTooltip
                            ToolTip, %mval%, 100, % 50 + A_Index * 23, %A_Index% 
                        Else
                            debugStr .= "`n" . Message.A_Index
                    }
                }
                If !MultiTooltip
                    Tooltip, %debugStr%
            }
            Else
            {
                If MultiTooltip
                    ToolTip, Ding, 100, % 50 + MultiTooltip * 23, %MultiTooltip% 
                Else
                    Tooltip, Ding
            }
        }
        If Timeout
            SetTimer, RemoveTooltip, %Timeout%
        Return
    }

TriggerUtility(Utility){
     GuiStatus()
     if (OnHideout || !OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
          Exit
     If (!OnCooldownUtility%Utility%)
     {
          Send % KeyUtility%Utility%
          OnCooldownUtility%Utility%:=1
          SetTimer, TimerUtility%Utility%, % CooldownUtility%Utility%
          SendMSG(4, Utility)
     }
     Return
}

Rescale(){
     IfWinExist, ahk_group POEGameGroup 
     {
          WinGetPos, X, Y, GameW, GameH
          If (ResolutionScale="Standard") {
               ;Status Check OnHideout
               global vX_OnHideout:=X + Round(GameW / (1920 / 1178))
               global vY_OnHideout:=Y + Round(GameH / (1080 / 930))
               global vY_OnHideoutMin:=Y + Round(GameH / (1080 / 1053))
               ;Status Check OnChar
               global vX_OnChar:=X + Round(GameW / (1920 / 41))
               global vY_OnChar:=Y + Round(GameH / ( 1080 / 915))
               ;Status Check OnChat
               global vX_OnChat:=X + Round(GameW / (1920 / 0))
               global vY_OnChat:=Y + Round(GameH / ( 1080 / 653))
               ;Status Check OnInventory
               global vX_OnInventory:=X + Round(GameW / (1920 / 1583))
               global vY_OnInventory:=Y + Round(GameH / ( 1080 / 36))
               ;Status Check OnStash
               global vX_OnStash:=X + Round(GameW / (1920 / 336))
               global vY_OnStash:=Y + Round(GameH / ( 1080 / 32))
               ;Status Check OnVendor
               global vX_OnVendor:=X + Round(GameW / (1920 / 618))
               global vY_OnVendor:=Y + Round(GameH / ( 1080 / 88))
               ;Status Check OnMenu
               global vX_OnMenu:=X + Round(GameW / 2)
               global vY_OnMenu:=Y + Round(GameH / (1080 / 54))
               ;GUI overlay
               global GuiX:=X + Round(GameW / (1920 / -10))
               global GuiY:=Y + Round(GameH / (1080 / 1027))
          }
          Else If (ResolutionScale="Classic") {
               ;Status Check OnHideout
               global vX_OnHideout:=X + Round(GameW / (1440 / 698))
               global vY_OnHideout:=Y + Round(GameH / (1080 / 930))
               global vY_OnHideoutMin:=Y + Round(GameH / (1080 / 1053))
               ;Status Check OnMenu
               global vX_OnMenu:=X + Round(GameW / 2)
               global vY_OnMenu:=Y + Round(GameH / (1080 / 54))
               ;Status Check OnChar
               global vX_OnChar:=X + Round(GameW / (1440 / 41))
               global vY_OnChar:=Y + Round(GameH / ( 1080 / 915))
               ;Status Check OnChat
               global vX_OnChat:=X + Round(GameW / (1440 / 0))
               global vY_OnChat:=Y + Round(GameH / ( 1080 / 653))
               ;Status Check OnInventory
               global vX_OnInventory:=X + Round(GameW / (1440 / 1103))
               global vY_OnInventory:=Y + Round(GameH / ( 1080 / 36))
               ;Status Check OnStash
               global vX_OnStash:=X + Round(GameW / (1440 / 336))
               global vY_OnStash:=Y + Round(GameH / ( 1080 / 32))
               ;Status Check OnVendor
               global vX_OnVendor:=X + Round(GameW / (1440 / 378))
               global vY_OnVendor:=Y + Round(GameH / ( 1080 / 88))
               ;GUI overlay
               global GuiX:=X + Round(GameW / (1440 / -10))
               global GuiY:=Y + Round(GameH / (1080 / 1027))
          }
          Else If (ResolutionScale="Cinematic") {
               ;Status Check OnHideout
               global vX_OnHideout:=X + Round(GameW / (2560 / 1887))
               global vY_OnHideout:=Y + Round(GameH / (1080 / 930))
               global vY_OnHideoutMin:=Y + Round(GameH / (1080 / 1053))
               ;Status Check OnChar
               global vX_OnChar:=X + Round(GameW / (2560 / 41))
               global vY_OnChar:=Y + Round(GameH / ( 1080 / 915))
               ;Status Check OnChat
               global vX_OnChat:=X + Round(GameW / (2560 / 0))
               global vY_OnChat:=Y + Round(GameH / ( 1080 / 653))
               ;Status Check OnInventory
               global vX_OnInventory:=X + Round(GameW / (2560 / 2223))
               global vY_OnInventory:=Y + Round(GameH / ( 1080 / 36))
               ;Status Check OnStash
               global vX_OnStash:=X + Round(GameW / (2560 / 336))
               global vY_OnStash:=Y + Round(GameH / ( 1080 / 32))
               ;Status Check OnVendor
               global vX_OnVendor:=X + Round(GameW / (2560 / 618))
               global vY_OnVendor:=Y + Round(GameH / ( 1080 / 88))
               ;Status Check OnMenu
               global vX_OnMenu:=X + Round(GameW / 2)
               global vY_OnMenu:=Y + Round(GameH / (1080 / 54))
               ;GUI overlay
               global GuiX:=X + Round(GameW / (2560 / -10))
               global GuiY:=Y + Round(GameH / (1080 / 1027))
          } 
          Else If (ResolutionScale="UltraWide") {
               ;Status Check OnHideout
               global vX_OnHideout:=X + Round(GameW / (3840 / 3098))
               global vY_OnHideout:=Y + Round(GameH / (1080 / 930))
               global vY_OnHideoutMin:=Y + Round(GameH / (1080 / 1053))
               ;Status Check OnChar
               global vX_OnChar:=X + Round(GameW / (3840 / 41))
               global vY_OnChar:=Y + Round(GameH / ( 1080 / 915))
               ;Status Check OnChat
               global vX_OnChat:=X + Round(GameW / (3840 / 0))
               global vY_OnChat:=Y + Round(GameH / ( 1080 / 653))
               ;Status Check OnInventory
               global vX_OnInventory:=X + Round(GameW / (3840 / 3503))
               global vY_OnInventory:=Y + Round(GameH / ( 1080 / 36))
               ;Status Check OnStash
               global vX_OnStash:=X + Round(GameW / (3840 / 336))
               global vY_OnStash:=Y + Round(GameH / ( 1080 / 32))
               ;Status Check OnVendor
               global vX_OnVendor:=X + Round(GameW / (3840 / 1578))
               global vY_OnVendor:=Y + Round(GameH / ( 1080 / 88))
               ;Status Check OnMenu
               global vX_OnMenu:=X + Round(GameW / 2)
               global vY_OnMenu:=Y + Round(GameH / (1080 / 54))
               ;GUI overlay
               global GuiX:=X + Round(GameW / (3840 / -10))
               global GuiY:=Y + Round(GameH / (1080 / 1027))
          }

          ; Controller support section, finds the center of the screen.
          WinGetPos, win_x, win_y, width, height, A
          x_center := win_x + width / 2
          compensation := (width / height) == (16 / 10) ? 1.103829 : 1.103719
          y_center := win_y + height / 2 / compensation
          offset_mod := y_offset / height
          x_offset := width * (offset_mod / 1.5 )
          Global RescaleRan := True
     }
     return
}

TriggerFlaskCD(Trigger){
     loop, 5 {
          QFLValCD:=SubStr(Trigger,A_Index,1)+0
          if (QFLValCD > 0) {
               if (OnCooldown[A_Index]=0) {
                    OnCooldown[A_Index]:=1 
                    settimer, TimmerFlask%A_Index%, % CooldownFlask%A_Index%
               }
          }
     }
     Return
}

Joystick_Handler:
     IfWinActive ahk_group POEGameGroup
     {
          If (!JoystickActive || !YesController)
          {
               SetTimer, Joystick_Handler, off
               Return
          }
          MouseNeedsToBeMoved := false  ; Set default.
          SetFormat, float, 03
          GetKeyState, JoyX, %JoystickNumber%JoyX
          GetKeyState, JoyY, %JoystickNumber%JoyY
          if (JoyX < JoyThresholdUpper) && (JoyX > JoyThresholdLower)
          {
               DeltaX = 0
          }
          Else if (JoyX > JoyThresholdUpper)
          {
               MouseNeedsToBeMoved := true
               DeltaX := JoyX - JoyThresholdUpper
          }
          else if (JoyX < JoyThresholdLower) && (JoyX != -1)
          {
               MouseNeedsToBeMoved := true
               DeltaX := JoyX - JoyThresholdLower
          }
          else
               DeltaX = 0
          if (JoyY < JoyThresholdUpper) && (JoyY > JoyThresholdLower)
          {
               DeltaY = 0
          }
          Else if (JoyY > JoyThresholdUpper)
          {
               MouseNeedsToBeMoved := true
               DeltaY := JoyY - JoyThresholdUpper
          }
          else if (JoyY < JoyThresholdLower) && (JoyY != -1)
          {
               MouseNeedsToBeMoved := true
               DeltaY := JoyY - JoyThresholdLower
          }
          else
               DeltaY = 0
          if (MouseNeedsToBeMoved)
          {
               MouseMove, x_center + DeltaX * JoyMultiplier, y_center + DeltaY * JoyMultiplier * YAxisMultiplier
               ++HeldCountJoystick
               ;Ding(500,1,"Count: " . HeldCountJoystick)
               if (!checkvarJoystick && HeldCountJoystick > 3)
               {
                    Click, down
                    checkvarJoystick := 1
               }
               if (YesTriggerUtilityJoystickKey && HeldCountJoystick > 20)
               {
                    TriggerUtility(utilityKeyToFire)
               }
               if (AutoQuick && HeldCountJoystick > 60)
               {
                    if ((QuicksilverSlot1=1) || (QuicksilverSlot2=1) || (QuicksilverSlot3=1) || (QuicksilverSlot4=1) || (QuicksilverSlot5=1))
                    {
                         TriggerFlaskForce(TriggerQuicksilver)
                    }
               }
          }
          Else if (checkvarJoystick) 
          {
               click, up
               checkvarJoystick := 0
               HeldCountJoystick := 1
          }
     }
return

Joystick2_Handler:
     IfWinActive ahk_group POEGameGroup
     {
          If (!JoystickActive || !YesController)
          {
               SetTimer, Joystick2_Handler, off
               Return
          }
          MouseNeedsToBeMoved := false  ; Set default.
          SetFormat, float, 03
          GetKeyState, JoyX, %JoystickNumber%JoyU
          GetKeyState, JoyY, %JoystickNumber%JoyR
          if (JoyX < Joy2ThresholdUpper) && (JoyX > Joy2ThresholdLower)
          {
               DeltaX = 0
          }
          else if (JoyX > Joy2ThresholdUpper)
          {
               MouseNeedsToBeMoved := true
               DeltaX := JoyX - Joy2ThresholdUpper
          }
          else if (JoyX < Joy2ThresholdLower) && (JoyX != -1)
          {
               MouseNeedsToBeMoved := true
               DeltaX := JoyX - JoyThresholdLower
          }
          else
               DeltaX = 0
          if (JoyY < Joy2ThresholdUpper) && (JoyY > Joy2ThresholdLower)
          {
               DeltaY = 0
          }
          else if (JoyY > Joy2ThresholdUpper)
          {
               MouseNeedsToBeMoved := true
               DeltaY := JoyY - Joy2ThresholdUpper
          }
          else if (JoyY < Joy2ThresholdLower) && (JoyY != -1)
          {
               MouseNeedsToBeMoved := true
               DeltaY := JoyY - JoyThresholdLower
          }
          else
               DeltaY = 0
          if MouseNeedsToBeMoved
          {
               MouseMove, x_center + DeltaX * JoyMultiplier2, y_center + DeltaY * JoyMultiplier2 * YAxisMultiplier
               ++HeldCountJoystick2
               ;Ding(500,1,"Count: " . HeldCountJoystick2)
               if (YesTriggerJoystick2Key && !checkvarJoy2 && HeldCountJoystick2 > 6)
               {
                    Send {%hotkeyControllerJoystick2% down}
                    checkvarJoy2 := True
               }
          }
          Else If (checkvarJoy2)
          {
               Send {%hotkeyControllerJoystick2% up}
               checkvarJoy2 := False
               HeldCountJoystick2 := 0
          }
     }
return

JoyButtons_Handler:
     IfWinActive ahk_group POEGameGroup
     {
          If (!JoystickActive || !YesController)
          {
               SetTimer, JoyButtons_Handler, off
               Return
          }
          GetKeyState, joy_buttons, %JoystickNumber%JoyButtons
          GetKeyState, POV, %JoystickNumber%JoyPOV
          Loop, %joy_buttons%
          {
               If (A_Index > 10)
                    Break
               buttonIndex := A_Index
               GetKeyState, joy%A_Index%, %JoystickNumber%joy%A_Index%
               if (joy%A_Index% = "D") && (pressed%A_Index%)  && (pressedVacuum = A_Index) 
               {
				If AreaScale
				{
					For k, ColorHex in LootColors
					{
						MouseGetPos mX, mY
						PixelSearch, ScanPx, ScanPy ,% mX - AreaScale ,% mY - AreaScale ,% mX + AreaScale ,% mY + AreaScale , ColorHex, 0, Fast
						If !(Pressed := GetKeyState(hotkeyLootScan))
							Break 2
						If (ErrorLevel = 0)
						{
							ScanPx += 15
							ScanPy += 15
							Click %ScanPx%, %ScanPy%
							Break
						}
					}
				}
				Else
				{
					MouseGetPos mX, mY
					PixelGetColor, scolor, mX, mY
					Pressed := GetKeyState(hotkeyLootScan)
					If indexOf(scolor,LootColors)
					{
						click %mX%, %mY%
					}
				}
               }
               if (joy%A_Index% = "D") && !(pressed%A_Index%) 
               {
                    ;Ding(500,0,A_Index,"Pressed",hotkeyControllerButton%A_Index%)
                    pressed%A_Index% := True 
                    Modifiers := ""
                    String := ""
                    for k, Letter in StrSplit(hotkeyControllerButton%A_Index%) {
                    if (IsModifier(Letter)) {
                         Modifiers .= Letter
                    }
                    else {
                         String .= Letter
                    }
                    }
                    Send, % Modifiers "{" String " down}"
                    ;Ding(500,0,%Modifiers%,%String%)
                    If (hotkeyLootScan = hotkeyControllerButton%A_Index%) && LootVacuum
                    {
                         pressedVacuum := A_Index
                    }
          		Else If (hotkeyControllerButton%A_Index% = "Logout")
                    {
                         SendMSG(6,1)
                    }
          		Else If (hotkeyControllerButton%A_Index% = "PopFlasks")
                    {
                         SendMSG(6,2)
                    }
          		Else If (hotkeyControllerButton%A_Index% = "QuickPortal")
                    {
                         SendMSG(6,3)
                    }
          		Else If (hotkeyControllerButton%A_Index% = "GemSwap")
                    {
                         SendMSG(6,4)
                    }
          		Else If (hotkeyControllerButton%A_Index% = "ItemSort")
                    {
                         SendMSG(6,5)
                    }
               }
               Else if (pressed%A_Index%) && !(joy%A_Index% = "D")
               {
                    ;Ding(500,0,A_Index,"Released",hotkeyControllerButton%A_Index%)
                    pressed%A_Index% := False 
                    Modifiers := ""
                    String := ""
                    for k, Letter in StrSplit(hotkeyControllerButton%A_Index%) {
                    if (IsModifier(Letter)) {
                         Modifiers .= Letter
                    }
                    else {
                         String .= Letter
                    }
                    }
                    Send, % Modifiers "{" String " up}"
               }
          }
          if !(POV = -1)
          {
               if ((POV >= 31500 && POV <= 36000) || (POV >= 0 && POV <= 4500))
               {
                    y_finalPOV := -y_POVscale-HeldCountPOV
                    newpositionPOV := true
               }
               else if (POV >= 13500 && POV <= 22500)
               {
                    y_finalPOV := +y_POVscale+HeldCountPOV
                    newpositionPOV := true
               }
               else
               {
                    y_finalPOV := 0
               }
               
               if (POV >= 22500 && POV <= 31500)
               {
                    x_finalPOV := -x_POVscale-HeldCountPOV
                    newpositionPOV := true
               }
               else if (POV >= 4500 && POV <= 13500)
               {
                    x_finalPOV := +x_POVscale+HeldCountPOV
                    newpositionPOV := true
               }
               else
               {
                    x_finalPOV := 0
               }
               
               If (newpositionPOV)
               {
                    HeldCountPOV+=3
                    Sleep, 45
                    MouseMove, %x_finalPOV%, %y_finalPOV%, 0, R
                    newpositionPOV := false
               }
          }
          Else If (HeldCountPOV > 1)
          {
               HeldCountPOV := 1
          }
     }
return

WASD_Handler:
IfWinActive ahk_group POEGameGroup
{
     If (!YesMovementKeys)
     Return
     if (GetKeyState(hotkeyUp, "P") || GetKeyState(hotkeyDown, "P") || GetKeyState(hotkeyLeft, "P") || GetKeyState(hotkeyRight, "P"))
     {
          if (GetKeyState(hotkeyUp, "P"))
          {
               y_final := y_center - y_offset
               newposition := true
          }
          else if (GetKeyState(hotkeyDown, "P") )
          {
               y_final := y_center + y_offset
               newposition := true
          }
          else
          {
               y_final := y_center
          }
          
          if (GetKeyState(hotkeyLeft, "P"))
          {
               x_final := x_center - x_offset
               newposition := true
          }
          else if (GetKeyState(hotkeyRight, "P"))
          {
               x_final := x_center + x_offset
               newposition := true
          }
          else
          {
               x_final := x_center
          }
          
          If (newposition)
          {
               GuiStatus()
               If (!OnChar || OnChat || OnInventory)
                    Return
               MouseMove, %x_final%, %y_final%			
               Sleep, 45
               If !(checkvar)
               {
                    Click, Down, %x_final%, %y_final%
                    checkvar := 1
               }
               newposition := false
               If (YesTriggerUtilityKey)
                    TriggerUtility(utilityKeyToFire)
               if (AutoQuick)
               {
                    if ((QuicksilverSlot1=1) || (QuicksilverSlot2=1) || (QuicksilverSlot3=1) || (QuicksilverSlot4=1) || (QuicksilverSlot5=1))
                    {
                         TriggerFlaskForce(TriggerQuicksilver)
                    }
               }
          }
     }
     if !(GetKeyState(hotkeyUp, "P") || GetKeyState(hotkeyDown, "P") || GetKeyState(hotkeyLeft, "P") || GetKeyState(hotkeyRight, "P")) && (checkvar) 
     {
          click, up
          checkvar := 0
     }
}

return

IsModifier(Character) {
    static Modifiers := {"!": 1, "#": 1, "~": 1, "^": 1, "*": 1, "+": 1}
return Modifiers.HasKey(Character)
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
                    JoystickNumber := A_Index
                    If YesController
                         Ding(3000,1,"Detected Joystick on the " . A_Index . " port.")
                    JoystickActive:=True
                    break
               }
          }
          if JoystickNumber <= 0
          {
               If YesController
     			Ding(3000,1,"The system does not appear to have any joysticks.")
               JoystickActive:=False
          }
     }
     Else 
     {
          If YesController
          {
		     Ding(3000,1,"System already has a Joystick on Port " . JoystickNumber ,"Set Joystick Number to 0 for auto-detect.")
               JoystickActive := True
          }
          Else
               JoystickActive:=False
          
     }
     ;Set up timer if checkbox ticked
     If (YesController&&JoystickActive)
     {
          SetTimer, JoyButtons_Handler, 15
          SetTimer, Joystick_Handler, 15
          SetTimer, Joystick2_Handler, 15
     }
     Else
     {
          SetTimer, JoyButtons_Handler, Delete
          SetTimer, Joystick_Handler, Delete
          SetTimer, Joystick2_Handler, Delete
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
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

    FindText( x, y, w, h, err1, err0, text, ScreenShot=1
    , FindAll=1, JoinText=0, offsetX=20, offsetY=10 )
    {
    xywh2xywh(x,y,w,h,x,y,w,h)
    if (w<1 or h<1)
        return, 0
    bch:=A_BatchLines
    SetBatchLines, -1
    ;-------------------------------
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,ScreenShot,zx,zy)
    ;-------------------------------
    sx:=x-zx, sy:=y-zy, sw:=w, sh:=h
    , arr:=[], info:=[], allv:=""
    Loop, Parse, text, |
    {
        v:=A_LoopField
        IfNotInString, v, $, Continue
        comment:="", e1:=err1, e0:=err0
        ; You Can Add Comment Text within The <>
        if RegExMatch(v,"<([^>]*)>",r)
        v:=StrReplace(v,r), comment:=Trim(r1)
        ; You can Add two fault-tolerant in the [], separated by commas
        if RegExMatch(v,"\[([^\]]*)]",r)
        {
        v:=StrReplace(v,r), r1.=","
        StringSplit, r, r1, `,
        e1:=r1, e0:=r2
        }
        StringSplit, r, v, $
        color:=r1, v:=r2
        StringSplit, r, v, .
        w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
        if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
        Continue
        mode:=InStr(color,"-") ? 4 : InStr(color,"#") ? 3
        : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
        if (mode=4)
        {
        color:=StrReplace(color,"0x")
        StringSplit, r, color, -
        color:="0x" . r1, n:="0x" . r2
        }
        else
        {
        color:=RegExReplace(color,"[*#]") . "@"
        StringSplit, r, color, @
        color:=mode=3 ? ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4 : r1
        n:=Round(r2,2)+(!r2), n:=Floor(9*255*255*(1-n)*(1-n))
        }
        StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
        e1:=Round(len1*e1), e0:=Round(len0*e0)
        info.Push( [StrLen(allv),w1,h1,len1,len0,e1,e0
        ,mode,color,n,comment] ), allv.=v
    }
    if (allv="")
    {
        SetBatchLines, %bch%
        return, 0
    }
    num:=info.MaxIndex(), VarSetCapacity(input, num*7*4)
    , VarSetCapacity(gs, sw*sh)
    , VarSetCapacity(ss, sw*sh), k:=StrLen(allv)*4
    , VarSetCapacity(s1, k), VarSetCapacity(s0, k)
    , allpos_max:=FindAll ? 1024 : 1
    , VarSetCapacity(allpos, allpos_max*4)
    ;-------------------------------------
    Loop, 2 {
    if (JoinText)
    {
        mode:=info.1.8, color:=info.1.9, n:=info.1.10
        , w1:=-1, h1:=info.1.3, comment:="", k:=0
        Loop, % num {
        i:=A_Index, w1+=info[i].2+1, comment.=info[i].11
        Loop, 7
            NumPut(info[i][A_Index], input, 4*(k++), "int")
        }
        ok:=PicFind( mode,color,n,offsetX,offsetY
        ,Scan0,Stride,sx,sy,sw,sh,gs,ss,allv,s1,s0
        ,input,num*7,allpos,allpos_max )
        Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
    else
    {
        For i,j in info
        {
        mode:=j.8, color:=j.9, n:=j.10, comment:=j.11
        , w1:=j.2, h1:=j.3, v:=SubStr(allv, j.1+1, w1*h1)
        Loop, 7
            NumPut(j[A_Index], input, 4*(A_Index-1), "int")
        NumPut(0, input, "int")
        ok:=PicFind( mode,color,n,offsetX,offsetY
            ,Scan0,Stride,sx,sy,sw,sh,gs,ss,v,s1,s0
            ,input,7,allpos,allpos_max )
        Loop, % ok
            pos:=NumGet(allpos, 4*(A_Index-1), "uint")
            , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
            , arr.Push( [rx,ry,w1,h1,comment] )
        }
    }
    if (err1=0 and err0=0 and !arr.MaxIndex())
    {
        err1:=err0:=0.1
        For i,j in info
        if (j.6=0 and j.7=0)
            j.6:=Round(j.4*err1), j.7:=Round(j.5*err0)
    }
    else Break
    }
    SetBatchLines, %bch%
    return, arr.MaxIndex() ? arr:0
    }

    PicFind(mode, color, n, offsetX, offsetY
    , Scan0, Stride, sx, sy, sw, sh
    , ByRef gs, ByRef ss, ByRef text, ByRef s1, ByRef s0
    , ByRef input, num, ByRef allpos, allpos_max)
    {
    static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
    if !MyFunc
    {
        x32:="5557565383EC788B8424CC0000008BBC24CC000000C7442"
        . "424000000008B40048B7F148944243C8B8424CC000000897C2"
        . "42C8BBC24CC0000008B40088B7F18894424348B8424CC00000"
        . "0897C24308B400C89C6894424288B8424CC0000008B401039C"
        . "6894424200F4DC68944241C8B8424D000000085C00F8E15010"
        . "0008BB424CC0000008B44242489F78B0C868B7486048B44870"
        . "88974241085C0894424180F8ED700000089CD894C2414C7442"
        . "40C00000000C744240800000000C744240400000000890C248"
        . "D76008DBC27000000008B5C24108B7424088B4C24148B54240"
        . "C89DF89F029F101F78BB424C000000001CE85DB7E5E8B0C248"
        . "9EB893C2489D7EB198BAC24C800000083C70483C00189548D0"
        . "083C101390424742C83BC248C0000000389FA0F45D0803C063"
        . "175D48BAC24C400000083C70483C00189549D0083C30139042"
        . "475D48B7424100174241489DD890C2483442404018BB424B00"
        . "000008B442404017424088BBC24A4000000017C240C3944241"
        . "80F8554FFFFFF83442424078B442424398424D00000000F8FE"
        . "BFEFFFF83BC248C000000030F84A00600008B8424A40000008"
        . "BB424A80000000FAF8424AC0000008BBC248C0000008D2CB08"
        . "B8424B00000008BB424A4000000F7D885FF8D0486894424100"
        . "F84F702000083BC248C000000010F845F08000083BC248C000"
        . "000020F84130900008B8424900000008B9C24940000000FB6B"
        . "C24940000000FB6B42490000000C744241800000000C744242"
        . "400000000C1E8100FB6DF0FB6D08B84249000000089D10FB6C"
        . "4894424088B842494000000C1E8100FB6C029C101D08904248"
        . "B442408894C24408B4C240801D829D9894424088D043E894C2"
        . "40489F129F9894424148BBC24B40000008B8424B0000000894"
        . "C240C89E98B6C2440C1E00285FF894424380F8EBA0000008BB"
        . "424B000000085F60F8E910000008B8424A00000008B5424240"
        . "39424BC00000001C8034C243889CF894C244003BC24A000000"
        . "0EB3D8D76008DBC2700000000391C247C3D394C24047F37394"
        . "C24087C3189F30FB6F33974240C0F9EC3397424140F9DC183C"
        . "00483C20121D9884AFF39F8741E0FB658020FB648010FB6303"
        . "9DD7EBE31C983C00483C201884AFF39F875E28BBC24B000000"
        . "0017C24248B4C24408344241801034C24108B442418398424B"
        . "40000000F8546FFFFFF8B8424B00000002B44243C8944240C8"
        . "B8424B40000002B442434894424600F884D0900008B4424288"
        . "BBC24C40000008B74243CC744241000000000C744243800000"
        . "000C7442434000000008D3C8789C583EE01897C246C8974247"
        . "48B44240C85C00F88E70000008B7C24388B8424AC000000BE0"
        . "0000000C704240000000001F8C1E0108944246889F82B84249"
        . "C0000000F49F08B84249C000000897424640FAFB424B000000"
        . "001F8894424708974245C8DB6000000008B04240344241089C"
        . "1894424088B442430394424200F84AA0100008B5C241C89C60"
        . "38C24BC00000031C08B54242C85DB0F8EC8010000897424048"
        . "B7C2420EB2D39C77E1C8BB424C80000008B1C8601CB803B007"
        . "40B836C240401782B8D74260083C0013944241C0F849101000"
        . "039C57ECF8BB424C40000008B1C8601CB803B0174BE83EA017"
        . "9B9830424018B04243944240C0F8D68FFFFFF83442438018BB"
        . "424B00000008B44243801742410394424600F8DEFFEFFFF8B4"
        . "C243483C47889C85B5E5F5DC250008B8424900000008BB424B"
        . "4000000C744240C00000000C744241400000000C1E8100FB6C"
        . "08904248B8424900000000FB6C4894424040FB684249000000"
        . "0894424088B8424B0000000C1E00285F68944242489E88BAC2"
        . "4940000000F8E24FEFFFF8B9C24B000000085DB7E758B9C24A"
        . "00000008B7424148BBC24A000000003B424BC00000001C3034"
        . "424248944241801C78D76008DBC27000000000FB643020FB64"
        . "B012B04242B4C24040FB6132B5424080FAFC00FAFC98D04400"
        . "FAFD28D04888D045039C50F930683C30483C60139DF75C98BB"
        . "C24B0000000017C24148B4424188344240C01034424108B742"
        . "40C39B424B40000000F8566FFFFFFE985FDFFFF85ED7E358B7"
        . "424088BBC24BC00000031C08B54242C8D1C378BB424C400000"
        . "08B0C8601D9803901740983EA010F8890FEFFFF83C00139C57"
        . "5E683BC24D0000000070F8EAA0100008B442474030424C7442"
        . "44007000000896C2444894424288B8424CC00000083C020894"
        . "4243C8B44243C8B9424B00000008B7C24288B0029C28944245"
        . "08B84249800000001F839C20F4EC289C68944244C39FE0F8C0"
        . "90100008B44243C8B700C8B78148B6808897424148B7010897"
        . "C245489C7897424248BB424B40000002B700489F08B7424703"
        . "9C60F4EC68BB424C4000000894424188B47FC89442404C1E00"
        . "201C6038424C8000000894424588B4424648B7C2428037C245"
        . "C3B442418894424040F8F8700000085ED7E268B8C24BC00000"
        . "08B54242431C08D1C398B0C8601D9803901740583EA01784A8"
        . "3C00139C575EA8B4424148B4C245439C8747E85C07E7A8B9C2"
        . "4BC000000896C244831C08B6C245801FBEB0983C0013944241"
        . "4745C8B54850001DA803A0074EC83E90179E78B6C244890834"
        . "424040103BC24B00000008B442404394424180F8D79FFFFFF8"
        . "3442428018B4424283944244C0F8D4CFFFFFF830424018B6C2"
        . "4448B04243944240C0F8D7EFCFFFFE911FDFFFF8B4424288B7"
        . "4245083442440078344243C1C8D4430FF894424288B4424403"
        . "98424D00000000F8F7FFEFFFF8B6C24448B7C24348B0424038"
        . "424A80000008BB424D40000000B4424688D4F01398C24D8000"
        . "0008904BE0F8ED8FCFFFF85ED7E278B7424088BBC24BC00000"
        . "08B8424C40000008D1C378B74246C8B1083C00401DA39F0C60"
        . "20075F283042401894C24348B04243944240C0F8DDEFBFFFFE"
        . "971FCFFFF89F68DBC27000000008B8424B0000000038424A80"
        . "000002B44243C894424248B8424AC000000038424B40000002"
        . "B442434398424AC000000894424380F8F520400008B8424A40"
        . "000008BB424A80000000FAF8424AC000000C74424180000000"
        . "08D04B0038424900000008BB424A0000000894424348B44242"
        . "4398424A80000000F8F2B0100008B8424AC000000C1E010894"
        . "4243C8B442434894424148B8424A8000000894424088B44241"
        . "40FB67C060289C52BAC2490000000893C240FB67C0601897C2"
        . "4040FB63C068B44241C85C00F8E140100008B4424308944241"
        . "08B44242C8944240C31C0EB5D394424207E4A8B9C24C800000"
        . "08B0C8301E90FB6540E020FB65C0E012B14242B5C24040FB60"
        . "C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A3994249"
        . "4000000720C836C2410017865908D74260083C0013944241C0"
        . "F84A3000000394424287E9D8B9C24C40000008B0C8301E90FB"
        . "6540E020FB65C0E012B14242B5C24040FB60C0E0FAFD20FAFD"
        . "B29F98D14520FAFC98D149A8D144A3B9424940000000F865BF"
        . "FFFFF836C240C010F8950FFFFFF834424080183442414048B4"
        . "42408394424240F8DF6FEFFFF838424AC000000018BBC24A40"
        . "000008B442438017C24343B8424AC0000000F8DA0FEFFFF8B4"
        . "C241883C4785B5E89C85F5DC250008D7426008B7C24188B442"
        . "43C0B4424088B9C24D40000008D4F013B8C24D80000008904B"
        . "B0F8D84FAFFFF894C2418EB848B8424900000008B8C24B4000"
        . "000C7042400000000C74424040000000083C001C1E00789C78"
        . "B8424B0000000C1E00285C98944240889E889FD0F8ECFF8FFF"
        . "F8B9424B000000085D27E5F8B8C24A00000008B5C2404039C2"
        . "4BC00000001C1034424088944240C038424A000000089C70FB"
        . "651020FB641010FB6316BC04B6BD22601C289F0C1E00429F00"
        . "1D039C50F970383C10483C30139F975D58BBC24B0000000017"
        . "C24048B44240C83042401034424108B342439B424B40000007"
        . "582E94CF8FFFF8B8424B0000000C7042400000000C74424040"
        . "0000000C1E002894424088B8424B400000085C00F8E9200000"
        . "08B8424B000000085C07E6F8B8C24A00000008B5C24048BB42"
        . "4B800000001E9036C240801DE039C24BC000000896C240C03A"
        . "C24A00000000FB651020FB6410183C1040FB679FC83C60183C"
        . "3016BC04B6BD22601C289F8C1E00429F801D0C1F8078846FFC"
        . "643FF0039CD75CC8BB424B0000000017424048B6C240C83042"
        . "401036C24108B0424398424B40000000F856EFFFFFF83BC24B"
        . "4000000020F8E80F7FFFF8B8424BC000000038424B00000008"
        . "BAC24B800000003AC24B0000000C7442404010000008944240"
        . "88B8424B400000083E8018944240C8B8424B000000083C0018"
        . "944241083BC24B0000000027E798B44241089E92B8C24B0000"
        . "0008B5C240889EA8D34288D45FE8904240FB642010FB63A038"
        . "4249000000039F87C360FB67A0239F87C2E0FB6790139F87C2"
        . "60FB63E39F87C1F0FB63939F87C180FB6790239F87C100FB67"
        . "EFF39F87C080FB67E0139F87D04C643010183C20183C30183C"
        . "10183C6013B0C2475A3834424040103AC24B00000008B44240"
        . "48BB424B0000000017424083944240C0F8558FFFFFFE98FF6F"
        . "FFF83C47831C95B89C85E5F5DC2500090909090909090"
        x64:="4157415641554154555756534881EC88000000488B84245"
        . "0010000488BB42450010000448B94245801000089542428448"
        . "944240844898C24E80000008B40048B76144C8BBC244001000"
        . "04C8BB42448010000C74424180000000089442430488B84245"
        . "00100008974241C488BB424500100008B40088B76188944243"
        . "C488B842450010000897424388B400C89C789442440488B842"
        . "4500100008B401039C7894424100F4DC74585D289442454488"
        . "B84245001000048894424200F8ECB000000488B442420448B0"
        . "8448B68048B400885C0894424040F8E940000004489CE44890"
        . "C244531E431FF31ED0F1F8400000000004585ED7E614863142"
        . "4418D5C3D0089F848039424380100004589E0EB1D0F1F0083C"
        . "0014D63D94183C0044183C1014883C20139C34789149E74288"
        . "3F9034589C2440F45D0803A3175D783C0014C63DE4183C0048"
        . "3C6014883C20139C34789149F75D844012C2483C50103BC241"
        . "80100004403A42400010000396C24047582834424180748834"
        . "424201C8B442418398424580100000F8F35FFFFFF83F9030F8"
        . "43D0600008B8424000100008BBC24080100000FAF842410010"
        . "0008BB424000100008D3CB88B842418010000F7D885C9448D2"
        . "C860F841101000083F9010F842008000083F9020F84BF08000"
        . "08B742428C744240400000000C74424180000000089F0440FB"
        . "6CEC1E8104589CC0FB6D84889F08B7424080FB6D44189DB89F"
        . "0440FB6C64889F1C1E8100FB6CD89D60FB6C08D2C0A8B94242"
        . "00100004129C301C3438D040129CE4529C48904248B8424180"
        . "10000C1E00285D2894424080F8E660100004C89BC244001000"
        . "0448BBC24180100004585FF0F8E91040000488B8C24F800000"
        . "04863C74C6354241831D24C03942430010000488D440102EB3"
        . "A0F1F80000000004439C37C4039CE7F3C39CD7C384539CC410"
        . "F9EC044390C240F9DC14421C141880C124883C2014883C0044"
        . "139D70F8E2D040000440FB6000FB648FF440FB648FE4539C37"
        . "EBB31C9EBD58B5C2428448B8C242001000031ED4531E44889D"
        . "84189DB0FB6DB0FB6F48B84241801000041C1EB10450FB6DBC"
        . "1E0024585C98904240F8EA10000004C89BC24400100004C89B"
        . "42448010000448B7C2408448BB424180100004585F67E60488"
        . "B8C24F80000004D63D44C039424300100004863C74531C94C8"
        . "D440102410FB600410FB648FF410FB650FE4429D829F10FAFC"
        . "029DA0FAFC98D04400FAFD28D04888D04504139C7430F93040"
        . "A4983C1014983C0044539CE7FC4033C244501F483C5014401E"
        . "F39AC2420010000758C4C8BBC24400100004C8BB4244801000"
        . "08B8424180100002B4424308904248B8424200100002B44243"
        . "C894424680F88540800008B7C24404D89F5488BAC243001000"
        . "0448B7424104C89FEC74424040000000048C74424280000000"
        . "0C74424200000000089F883E801498D4487044189FF4889442"
        . "4088B44243083E801894424788B042485C00F88D9000000488"
        . "B5C24288B8424100100004D89EC448B6C245401D8C1E010894"
        . "4247089D82B8424F000000089C7B8000000000F49C731FF894"
        . "4246C0FAF842418010000894424648B8424F000000001D8894"
        . "42474908B442404897C24188D1C388B4424384139C60F84AB0"
        . "000004189C131C04585ED448B44241C7F36E9C30000000F1F4"
        . "0004139CE7E1B418B148401DA4863D2807C150000740B4183E"
        . "901782E0F1F4400004883C0014139C50F8E920000004139C78"
        . "9C17ECC8B148601DA4863D2807C15000174BD4183E80179B74"
        . "883C701393C240F8D7AFFFFFF4D89E54883442428018B9C241"
        . "8010000488B442428015C2404394424680F8DFCFEFFFF8B4C2"
        . "42089C84881C4880000005B5E5F5D415C415D415E415FC3458"
        . "5FF7E278B4C241C4C8B4424084889F28B0201D84898807C050"
        . "001740583E90178934883C2044939D075E583BC24580100000"
        . "70F8EE60100008B442478488B8C24500100000344241844896"
        . "C2450448BAC241801000044897C24404883C1204889742410C"
        . "744243C07000000448974244448897C24484989CF895C247C8"
        . "9C64C89642430418B074489EA29C28944245C8B8424E800000"
        . "001F039C20F4EC239F0894424580F8CD0000000418B47148BB"
        . "C2420010000412B7F0449635FFC458B4F08458B670C8944246"
        . "08B442474458B771039C70F4FF8488B44241048C1E3024C8D1"
        . "41848035C24308B442464448D04068B44246C39F84189C37F7"
        . "2904585C97E234489F131D2418B04924401C04898807C05000"
        . "1740583E90178464883C2014139D17FE28B4424604139C40F8"
        . "4AA0000004585E40F8EA100000089C131D2EB0D4883C201413"
        . "9D40F8E8E0000008B04934401C04898807C05000074E483E90"
        . "179DF4183C3014501E84439DF7D8F83C601397424580F8D6EF"
        . "FFFFF488B7C2448448B7C2440448B742444448B6C2450488B7"
        . "424104C8B6424304883C701393C240F8D97FDFFFFE918FEFFF"
        . "F6690037C240844017C241883442404014401EF8B442404398"
        . "424200100000F854DFBFFFF4C8BBC2440010000E996FCFFFF8"
        . "B44245C8344243C074983C71C8D7406FF8B44243C398424580"
        . "100000F8F87FEFFFF448B7C2440448B742444448B6C2450488"
        . "B7C24488B5C247C488B7424104C8B64243048634424208B542"
        . "418039424080100004C8B9C24600100000B5424708D4801398"
        . "C2468010000418914830F8E9AFDFFFF4585FF7E1D4C8B44240"
        . "84889F08B104883C00401DA4C39C04863D2C64415000075EB4"
        . "883C701393C24894C24200F8DBAFCFFFFE93BFDFFFF0F1F440"
        . "0008B842418010000038424080100002B442430894424308B8"
        . "42410010000038424200100002B44243C39842410010000894"
        . "424440F8F230400008B8424000100008BBC24080100000FAF8"
        . "42410010000448B642440448B6C24544C8B8C24F8000000C74"
        . "42420000000008D04B8034424288944243C8B4424303984240"
        . "80100000F8F2F0100008B8424100100008B6C243CC1E010894"
        . "424408B8424080100008904248D450289EF2B7C24284585ED4"
        . "898450FB61C018D45014898410FB61C014863C5410FB634010"
        . "F8E140100008B442438894424188B44241C8944240431C0EB6"
        . "244395424107E4E418B0C8601F98D5102448D41014863C9410"
        . "FB60C094863D24D63C0410FB61411470FB6040129F10FAFC94"
        . "429DA4129D80FAFD2450FAFC08D1452428D14828D144A39542"
        . "4087207836C241801786B4883C0014139C50F8E9E000000413"
        . "9C44189C27E96418B0C8701F98D5102448D41014863C9410FB"
        . "60C094863D24D63C0410FB61411470FB6040129F10FAFC9442"
        . "9DA4129D80FAFD2450FAFC08D1452428D14828D144A3B54240"
        . "80F864BFFFFFF836C2404010F8940FFFFFF8304240183C5048"
        . "B0424394424300F8DEDFEFFFF83842410010000018BBC24000"
        . "100008B442444017C243C3B8424100100000F8D9CFEFFFFE97"
        . "CFBFFFF0F1F0048634424208B5424400B1424488BBC2460010"
        . "0008D48013B8C24680100008914870F8D56FBFFFF830424018"
        . "3C504894C24208B0424394424300F8D82FEFFFFEB93448B5C2"
        . "428448B84242001000031DB8B84241801000031F6448B94241"
        . "80100004183C30141C1E3074585C08D2C85000000000F8E8CF"
        . "9FFFF4585D27E57488B8C24F80000004C63CE4C038C2430010"
        . "0004863C74531C0488D4C01020FB6110FB641FF440FB661FE6"
        . "BC04B6BD22601C24489E0C1E0044429E001D04139C3430F970"
        . "4014983C0014883C1044539C27FCC01EF4401D683C3014401E"
        . "F399C24200100007595E91CF9FFFF8B8C24200100008B84241"
        . "801000031DB31F6448B8C241801000085C98D2C85000000007"
        . "E7D4585C97E694C63C6488B8C24F80000004863C74D89C24C0"
        . "38424300100004C0394242801000031D2488D4C0102440FB61"
        . "90FB641FF4883C104440FB661FA6BC04B456BDB264101C3448"
        . "9E0C1E0044429E04401D8C1F8074188041241C60410004883C"
        . "2014139D17FC401EF4401CE83C3014401EF399C24200100007"
        . "58383BC2420010000020F8E6CF8FFFF4863B424180100008B9"
        . "C24180100008BBC2420010000488D5601448D67FFBF0100000"
        . "04889D0480394243001000048038424280100004889D58D53F"
        . "D4C8D6A0183BC241801000002488D1C067E7E4989C04D8D5C0"
        . "5004989D94929F04889E90FB610440FB650FF035424284439D"
        . "27C44440FB650014439D27C3A450FB6104439D27C31450FB61"
        . "14439D27C28450FB650FF4439D27C1E450FB650014439D27C1"
        . "4450FB651FF4439D27C0A450FB651014439D27D03C60101488"
        . "3C0014983C1014883C1014983C0014C39D8759383C7014801F"
        . "54889D84139FC0F8562FFFFFFE989F7FFFF31C9E9FAF8FFFF9"
        . "0909090909090909090909090"
        MCode(MyFunc, A_PtrSize=8 ? x64:x32)
    }
    return, DllCall(&MyFunc, "int",mode, "uint",color
        , "uint",n, "int",offsetX, "int",offsetY, Ptr,Scan0
        , "int",Stride, "int",sx, "int",sy, "int",sw, "int",sh
        , Ptr,&gs, Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
        , Ptr,&input, "int",num, Ptr,&allpos, "int",allpos_max)
    }

    xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
    {
    SysGet, zx, 76
    SysGet, zy, 77
    SysGet, zw, 78
    SysGet, zh, 79
    left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
    left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
    up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
    x:=left, y:=up, w:=right-left+1, h:=down-up+1
    }

    GetBitsFromScreen(x, y, w, h, ByRef Scan0, ByRef Stride
    , ScreenShot=1, ByRef zx="", ByRef zy="", bpp=32)
    {
    static bits, oldx, oldy, oldw, oldh
    static Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr "*"
    if (ScreenShot or x<oldx or y<oldy
        or x+w>oldx+oldw or y+h>oldy+oldh)
    {
        oldx:=x, oldy:=y, oldw:=w, oldh:=h, ScreenShot:=1
        VarSetCapacity(bits, w*h*4)
    }
    Scan0:=&bits, Stride:=((oldw*bpp+31)//32)*4, zx:=oldx, zy:=oldy
    if (!ScreenShot or w<1 or h<1)
        return
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
    ;-------------------------
    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
    NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
    NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
    ;-------------------------
    if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
        , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
    {
        oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
        DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
        , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
        DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
        DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
        DllCall("DeleteObject", Ptr,hBM)
    }
    DllCall("DeleteDC", Ptr,mDC)
    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
    }

    MCode(ByRef code, hex)
    {
    bch:=A_BatchLines
    SetBatchLines, -1
    VarSetCapacity(code, len:=StrLen(hex)//2)
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, % len
        NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
    ListLines, %lls%
    Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
    DllCall("VirtualProtect",Ptr,&code, Ptr,len,"uint",0x40,PtrP,0)
    SetBatchLines, %bch%
    }

    base64tobit(s)
    {
    Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        . "abcdefghijklmnopqrstuvwxyz"
    SetFormat, IntegerFast, d
    StringCaseSense, On
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, Parse, Chars
    {
        i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
        . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
        s:=StrReplace(s,A_LoopField,v)
    }
    ListLines, %lls%
    StringCaseSense, Off
    s:=SubStr(s,1,InStr(s,"1",0,0)-1)
    s:=RegExReplace(s,"[^01]+")
    return, s
    }

    bit2base64(s)
    {
    s:=RegExReplace(s,"[^01]+")
    s.=SubStr("100000",1,6-Mod(StrLen(s),6))
    s:=RegExReplace(s,".{6}","|$0")
    Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        . "abcdefghijklmnopqrstuvwxyz"
    SetFormat, IntegerFast, d
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, Parse, Chars
    {
        i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
        . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
        s:=StrReplace(s,v,A_LoopField)
    }
    ListLines, %lls%
    return, s
    }

    ASCII(s)
    {
    if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
    {
        s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
        s:=StrReplace(StrReplace(s,"0","_"),"1","0")
    }
    else s=
    return, s
    }

    ; You can put the text library at the beginning of the script,
    ; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
    ; Use Pic("comment1|comment2|...") to get text images from Lib

    Pic(comments, add_to_Lib=0)
    {
    static Lib:=[]
    if (add_to_Lib)
    {
        re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
        Loop, Parse, comments, |
        if RegExMatch(A_LoopField,re,r)
            Lib[Trim(r1)]:=r
        Lib[""]:=""
    }
    else
    {
        Text:=""
        Loop, Parse, comments, |
        Text.="|" . Lib[Trim(A_LoopField)]
        return, Text
    }
    }

    PicN(Number)
    {
    return, Pic( RegExReplace(Number, ".", "|$0") )
    }

    ; Use PicX(Text) to automatically cut into multiple characters
    ; Can't be used in ColorPos mode, because it can cause position errors

    PicX(Text)
    {
    if !RegExMatch(Text,"\|([^$]+)\$(\d+)\.([\w+/]+)",r)
        return, Text
    w:=r2, v:=base64tobit(r3), Text:=""
    c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
    wz:=RegExReplace(v,".{" w "}","$0`n")
    SetFormat, IntegerFast, d
    While InStr(wz,c) {
        While !(wz~="m`n)^" c)
        wz:=RegExReplace(wz,"m`n)^.")
        i:=0
        While (wz~="m`n)^.{" i "}" c)
        i++
        v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
        wz:=RegExReplace(wz,"m`n)^.{" i "}")
        if v!=
        Text.="|" r1 "$" i "." bit2base64(v)
    }
    return, Text
    }

    ; Screenshot and retained as the last screenshot.

    ScreenShot()
    {
    n:=150000
    xywh2xywh(-n,-n,2*n+1,2*n+1,x,y,w,h)
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,1)
    }

    FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=20)
    {
    OCR:="", RightX:=nX+nW-1, ScreenShot()
    While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text, 0))
    {
        For k,v in ok
        {
        ; X is the X coordinates of the upper left corner
        ; and W is the width of the image have been found
        x:=v.1, y:=v.2, w:=v.3, h:=v.4, comment:=v.5
        ; We need the leftmost X coordinates
        if (A_Index=1 or x<LeftX)
            LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
        else if (x=LeftX)
        {
            Loop, 100
            {
            err:=A_Index/100
            if FindText(x, y, w, h, err, err, Text, 0)
            {
                LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
                Break
            }
            if FindText(LeftX, LeftY, LeftW, LeftH, err, err, Text, 0)
                Break
            }
        }
        }
        ; If the interval exceeds the set value, add "*" to the result
        OCR.=(A_Index>1 and LeftX-nX-1>Interval ? "*":"") . LeftOCR
        ; Update nX and nW for next search
        nX:=LeftX+LeftW-1, nW:=RightX-nX+1
    }
    return, OCR
    }

    ; Reordering the objects returned from left to right,
    ; from top to bottom, ignore slight height difference

    SortOK(ok, dy=10) {
    if !IsObject(ok)
        return, ok
    SetFormat, IntegerFast, d
    For k,v in ok
    {
        x:=v.1+v.3//2, y:=v.2+v.4//2
        y:=A_Index>1 and Abs(y-lasty)<dy ? lasty : y, lasty:=y
        n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
    }
    Sort, s, N D-
    ok2:=[]
    Loop, Parse, s, -
        ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
    return, ok2
    }

    ; Reordering according to the nearest distance

    SortOK2(ok, px, py) {
    if !IsObject(ok)
        return, ok
    SetFormat, IntegerFast, d
    For k,v in ok
    {
        x:=v.1+v.3//2, y:=v.2+v.4//2
        n:=((x-px)**2+(y-py)**2) "." k
        s:=A_Index=1 ? n : s "-" n
    }
    Sort, s, N D-
    ok2:=[]
    Loop, Parse, s, -
        ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
    return, ok2
    }

    ; Prompt mouse position in remote assistance

    MouseTip(x="", y="") {
    if (x="")
    {
        VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
        x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
    }
    x:=Round(x-10), y:=Round(y-10), w:=h:=2*10+1
    ;-------------------------
    Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
    Gui, _MouseTip_: Show, Hide w%w% h%h%
    ;-------------------------
    dhw:=A_DetectHiddenWindows
    DetectHiddenWindows, On
    d:=4, i:=w-d, j:=h-d
    s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
    s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
    WinSet, Region, %s%, ahk_id %myid%
    DetectHiddenWindows, %dhw%
    ;-------------------------
    Gui, _MouseTip_: Show, NA x%x% y%y%
    Loop, 4 {
        Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
        Sleep, 500
    }
    Gui, _MouseTip_: Destroy
    }