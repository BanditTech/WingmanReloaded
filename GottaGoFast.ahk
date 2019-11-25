#IfWinActive Path of Exile ; All Script Setup
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
     SetTitleMatchMode 2
     CoordMode, Mouse, Screen
     CoordMode, Pixel, Screen
     SetWorkingDir %A_ScriptDir%  
     Thread, interrupt, 0
     OnMessage(0x5555, "MsgMonitor")
     OnMessage(0x5556, "MsgMonitor")
     Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
     global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
     for n, exe in POEGameArr {
          GroupAdd, POEGameGroup, ahk_exe %exe%
     }
     Hotkey, IfWinActive, ahk_group POEGameGroup

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

     ; General
     Global Latency := 1
     Global YesPersistantToggle := 1

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
     Global CurrentLocation := ""
     Global ClientTowns := [ "Lioneye's Watch"
               ,"The Forest Encampment"
               ,"The Sarn Encampment"
               ,"Highgate"
               ,"Overseer's Tower"
               ,"The Bridge Encampment"
               ,"Oriath Docks"
               ,"Oriath" ]
     Global ClientLog := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"

; Ensure is Admin
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
     global OnTown:=False
     global OnMines:=False
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
     ReadFromFile()

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Scale positions for status check
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     IfWinExist, ahk_group POEGameGroup
     {
          Rescale()
          WinActivate, ahk_group POEGameGroup
     } Else {
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
          Gui, Show, x%GuiX% y%GuiY% NoActivate 
          ToggleExist := True
          WinActivate, ahk_group POEGameGroup
          If (YesPersistantToggle)
               AutoReset()
     }

; Set timers section
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     SetTimer, PoEWindowCheck, 5000
     SetTimer, CheckLocation, 15

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

; PopFlaskCooldowns - Pop all flasks
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     PopFlaskCooldowns(){
          If (PopFlaskRespectCD)
               TriggerFlaskCD(11111)
          Else {
               OnCooldown[1]:=1 
               settimer, TimerFlask1, %CooldownFlask1%
               OnCooldown[4]:=1 
               settimer, TimerFlask4, %CooldownFlask2%
               OnCooldown[3]:=1 
               settimer, TimerFlask3, %CooldownFlask3%
               OnCooldown[2]:=1 
               settimer, TimerFlask2, %CooldownFlask4%
               OnCooldown[5]:=1 
               settimer, TimerFlask5, %CooldownFlask5%
          }
          return
     }


; Hotkey to Exit
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     ~#Escape::
     ExitApp

; AutoQuicksilverCommand - Toggle Auto-Quick
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
; AutoReset - Load Previous Toggle States
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

; MsgMonitor - Receive Messages from other scripts
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
; SendMSG - Send one or two digits to a sub-script 
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
; PoEWindowCheck - Check if game is active
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     PoEWindowCheck(){
          DetectHiddenWindows On
          IfWinExist, ahk_group POEGameGroup 
          {
               global GuiX, GuiY, RescaleRan, ToggleExist
               If (!RescaleRan)
               Rescale()
               If (!ToggleExist) {
                    Gui, Show, x%GuiX% y%GuiY% NoActivate 
                    ToggleExist := True
                    DetectJoystick()
                    WinActivate, ahk_group POEGameGroup
                    If (YesPersistantToggle)
                         AutoReset()
               }
          } Else {
               If (ToggleExist){
                    Gui, Show, Hide
                    ToggleExist := False
               }
          }
          DetectHiddenWindows Off
          Return
     }

; ReadFromFile - Read Settings from file
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     ReadFromFile(){
          Global
          ;General
          IniRead, Speed, settings.ini, General, Speed, 1
          IniRead, QTick, settings.ini, General, QTick, 50
          IniRead, PopFlaskRespectCD, settings.ini, General, PopFlaskRespectCD, 0
          IniRead, ResolutionScale, settings.ini, General, ResolutionScale, Standard
          IniRead, QSonMainAttack, settings.ini, General, QSonMainAttack, 0
          IniRead, QSonSecondaryAttack, settings.ini, General, QSonSecondaryAttack, 0
          IniRead, TriggerUtilityKey, settings.ini, General, TriggerUtilityKey, 1
          IniRead, YesMovementKeys, settings.ini, General, YesMovementKeys, 0
          IniRead, LootVacuum, settings.ini, General, LootVacuum, 0
          IniRead, AreaScale, settings.ini, General, AreaScale, 0
          IniRead, DebugMessages, settings.ini, General, DebugMessages, 0
          ;Settings for the Client Log file location
          IniRead, ClientLog, Settings.ini, Log, ClientLog, %ClientLog%
          ;Coordinates
          IniRead, GuiX, settings.ini, Coordinates, GuiX, -10
          IniRead, GuiY, settings.ini, Coordinates, GuiY, 1027
          ;Failsafe Colors
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
          IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan, f
          IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI, Space

          ;Quicksilver
          IniRead, TriggerQuicksilverDelay, settings.ini, Quicksilver, TriggerQuicksilverDelay, 0.5
          IniRead, TriggerQuicksilver, settings.ini, Quicksilver, TriggerQuicksilver, 00000
          Loop, 5 {	
               valueQuicksilver := substr(TriggerQuicksilver, (A_Index), 1)
               QuicksilverSlot%A_Index% := valueQuicksilver
          }

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
          
          ;hotkeys
          IniRead, hotkeyMainAttack, settings.ini, hotkeys, MainAttack, RButton
          IniRead, hotkeySecondaryAttack, settings.ini, hotkeys, SecondaryAttack, w
          IniRead, hotkeyLootScan, settings.ini, hotkeys, LootScan, f
          IniRead, hotkeyCloseAllUI, settings.ini, hotkeys, CloseAllUI, Space

          If hotkeyAutoQuicksilver
               hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, Off
          IniRead, hotkeyAutoQuicksilver, settings.ini, hotkeys, AutoQuicksilver, !MButton
          If hotkeyAutoQuicksilver
               hotkey,%hotkeyAutoQuicksilver%, AutoQuicksilverCommand, On
          IfWinExist, ahk_group POEGameGroup
               Rescale()
          
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

; GuiUpdate - Opdate Overlay
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     GuiUpdate(){
          if (AutoQuick=1) {
               AutoQuickToggle:="ON" 
          } else AutoQuickToggle:="OFF" 
          GuiControl ,, T1, Quicksilver: %AutoQuickToggle%
          Return
     }

; TQuickTick - Main Quicksilver Logic
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     TQuickTick(){
          IfWinActive, Path of Exile
          {
               if ( AutoQuick && ( QuicksilverSlot1 || QuicksilverSlot2 || QuicksilverSlot3 || QuicksilverSlot4 || QuicksilverSlot5 ) )
                    If !( (QuicksilverSlot1 && OnCooldown[1]) 
                    || (QuicksilverSlot2 && OnCooldown[2]) 
                    || (QuicksilverSlot3 && OnCooldown[3]) 
                    || (QuicksilverSlot4 && OnCooldown[4]) 
                    || (QuicksilverSlot5 && OnCooldown[5]) ) ; Check if all the flasks are off cooldown
                         TriggerFlask(TriggerQuicksilver)
          }
     }

     TriggerFlask(Trigger){
          If (OnTown || OnHideout)
               Return
          GuiStatus()
          if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
               Exit
          If !(FlaskListQS.Count())
               loop, 5 
                    if ((SubStr(Trigger,A_Index,1)+0) > 0) 
                         FlaskListQS.Push(A_Index)
          If !( (QuicksilverSlot1 && OnCooldown[1]) 
          || (QuicksilverSlot2 && OnCooldown[2]) 
          || (QuicksilverSlot3 && OnCooldown[3]) 
          || (QuicksilverSlot4 && OnCooldown[4]) 
          || (QuicksilverSlot5 && OnCooldown[5]) ) 
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
                    settimer, TimerFlask%QFL%, % CooldownFlask%QFL%
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
          If (OnTown || OnHideout)
               Return
          GuiStatus()
          if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
               Return
          If !(FlaskListQS.Count())
               loop, 5 
                    if ((SubStr(Trigger,A_Index,1)+0) > 0)
                         FlaskListQS.Push(A_Index)
          If !( (QuicksilverSlot1 && OnCooldown[1]) 
          || (QuicksilverSlot2 && OnCooldown[2]) 
          || (QuicksilverSlot3 && OnCooldown[3]) 
          || (QuicksilverSlot4 && OnCooldown[4]) 
          || (QuicksilverSlot5 && OnCooldown[5]) ) 
          { ; If all the flasks are off cooldown, then we are ready to fire one
               QFL:=FlaskListQS.RemoveAt(1)
               If (!QFL)
                    Return
               send % keyFlask%QFL%
               OnCooldown[QFL] := 1 
               settimer, TimerFlask%QFL%, % CooldownFlask%QFL%
               SendMSG(3, QFL)
               Loop, 5
                    If (YesUtility%A_Index% && YesUtility%A_Index%Quicksilver)
                         TriggerUtility(A_Index)
          }
          Return
     }

     TriggerFlaskCD(Trigger){
          loop, 5 {
               QFLValCD:=SubStr(Trigger,A_Index,1)+0
               if (QFLValCD > 0) {
                    if (OnCooldown[A_Index]=0) {
                         OnCooldown[A_Index]:=1 
                         settimer, TimerFlask%A_Index%, % CooldownFlask%A_Index%
                    }
               }
          }
          Return
     }

; TUtilityTick - Main Utility Logic
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     TUtilityTick(){
          IfWinActive, Path of Exile
          {
               If (OnTown || OnHideout)
                    Return
               GuiStatus()
               if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
                    Return
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

     TriggerUtility(Utility){
          If (OnTown || OnHideout)
               Return
          GuiStatus()
          if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
               Return
          If (!OnCooldownUtility%Utility%)
          {
               Send % KeyUtility%Utility%
               OnCooldownUtility%Utility%:=1
               SetTimer, TimerUtility%Utility%, % CooldownUtility%Utility%
               SendMSG(4, Utility)
          }
          Return
     }

; Main Controller Handlers
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

     ; Keyboard movement handler
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
                         If (OnTown || OnHideout)
                              Return
                         GuiStatus()
                         if (!OnChar || OnChat || OnInventory || OnMenu) ;in Hideout, not on char, chat open, or open inventory
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

     ; Check if string contains modifier
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

; ---------------------------------------------                          END OF FUNCTIONS                                  ----------------------------------------------------------
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Include, %A_ScriptDir%\data\Library.ahk
