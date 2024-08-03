
Gui, Add, StatusBar, vWR_Statusbar hwndWR_hStatusbar, %WR_Statusbar%
SB_SetParts(220,220)
SB_SetText("Logic Status", 1)
SB_SetText("Location Status", 2)
SB_SetText("Percentage not updated", 3)

Gui Add, Tab2, vMainGuiTabs xm y3 w655 h505 -wrap , Main|Configuration|Hotkeys|Debug
; #Main Tab
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
	GuiControl, ChooseString, ProfileMenuperChar,% ProfileMenuperChar
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
	GuiControl, ChooseString, ProfileMenuFlask,% ProfileMenuFlask
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
	GuiControl, ChooseString, ProfileMenuUtility,% ProfileMenuUtility
	Gui, Add, Button, gProfile vMainMenu_Utility_Save x+1 yp hp w40 , Save
	Gui, Add, Button, gProfile vMainMenu_Utility_Load x+1 yp hp w40 , Load
	Gui, Add, Button, gProfile vMainMenu_Utility_Remove x+1 yp hp w50 , Remove

	;Middle Vertical Lines
	Gui, Add, Text,                   xm+279   y23    w1  h483 0x7
	Gui, Add, Text,                   x+1   y23    w1  h483 0x7

	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, GroupBox,  Center   Section  w350 h210        x+15   ym+20 ,    Game Logic States
	Gui, Font,
	Gui, Add, Text, Section xs+20 ys+20 w150 Center h20 0x200 vMainMenuOnChar hwndMainMenuIDOnChar, % "Character Active"
	CtlColors.Attach(MainMenuIDOnChar, "52D165", "")
	Gui, Add, Text, xp yp wp hp gupdateOnChar BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnOHB hwndMainMenuIDOnOHB, % "Overhead Health Bar"
	CtlColors.Attach(MainMenuIDOnOHB, "52D165", "")
	; Gui, Add, Text, xp yp wp hp gupdateOnOHB BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnChat hwndMainMenuIDOnChat, % "Chat Open"
	CtlColors.Attach(MainMenuIDOnChat, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnChat BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnInventory hwndMainMenuIDOnInventory, % "Inventory Open"
	CtlColors.Attach(MainMenuIDOnInventory, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnInventory BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnDiv hwndMainMenuIDOnDiv, % "Div Trade Open"
	CtlColors.Attach(MainMenuIDOnDiv, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnDiv BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnStash hwndMainMenuIDOnStash, % "Stash Open"
	CtlColors.Attach(MainMenuIDOnStash, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnStash BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnMenu hwndMainMenuIDOnMenu, % "Talent Menu Open"
	CtlColors.Attach(MainMenuIDOnMenu, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnMenu BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnVendor hwndMainMenuIDOnVendor, % "Vendor Trade Open"
	CtlColors.Attach(MainMenuIDOnVendor, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnVendor BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnDelveChart hwndMainMenuIDOnDelveChart, % "Delve Chart Open"
	CtlColors.Attach(MainMenuIDOnDelveChart, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnDelveChart BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuOnLeft hwndMainMenuIDOnLeft, % "Left Panel Open"
	CtlColors.Attach(MainMenuIDOnLeft, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateOnStash BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuOnDetonate hwndMainMenuIDOnDetonate, % "Detonate Shown"
	CtlColors.Attach(MainMenuIDOnDetonate, "", "Green")
	Gui, Add, Text, xp yp wp hp gupdateDetonate BackgroundTrans

	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, GroupBox,      Center       section        xs-20   y+35 w350 h60 ,         Gamestate Calibration
	Gui, Font, s8
	Gui, Add, Button, ghelpCalibration   xp+250 ys-4    h20, %  "? help"
	Gui, Add, Button, gStartCalibrationWizard vStartCalibrationWizardBtn  xs+10  ys+20 w105 h25,   Run Wizard
	Gui, Add, Button, gWR_Update vWR_Btn_Globe         x+8 yp       wp,   Adjust Globes
	; Gui, Add, Button, gWR_Update vWR_Btn_Locations         xs+10  y+10      wp,   Adjust Locations
	Gui, Add, Button, gCheckPixelGrid x+8 yp wp , Inventory Grid
	Gui, Font

	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, GroupBox,      Center       section        xs   y+20 w350 h80 ,        Active Functions
	Gui, Font, s8
	Gui, Add, Text, Section xs+20 ys+20 w150 Center h20 0x200 vMainMenuAutoFlask hwndMainMenuIDAutoFlask, % "Flask Triggers"
	CtlColors.Attach(MainMenuIDAutoFlask, "52D165", "")
	Gui, Add, Text, xp yp wp hp gtoggleAutoFlask BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuAutoQuit hwndMainMenuIDAutoQuit, % "Quit Trigger"
	CtlColors.Attach(MainMenuIDAutoQuit, "52D165", "")
	Gui, Add, Text, xp yp wp hp gtoggleAutoQuit BackgroundTrans
	Gui, Add, Text, xs y+10 w150 Center h20 0x200 vMainMenuAutoMove hwndMainMenuIDAutoMove, % "Move Triggers"
	CtlColors.Attach(MainMenuIDAutoMove, "52D165", "")
	Gui, Add, Text, xp yp wp hp gtoggleAutoMove BackgroundTrans
	Gui, Add, Text, x+5 yp w150 Center h20 0x200 vMainMenuAutoUtility hwndMainMenuIDAutoUtility, % "Utility Triggers"
	CtlColors.Attach(MainMenuIDAutoUtility, "52D165", "")
	Gui, Add, Text, xp yp wp hp gtoggleAutoUtility BackgroundTrans


	;Save Setting
	Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
	Gui, Add, Button,      gLaunchSite     x+5           h23,   Website
	Gui, Add, Button,      gft_Start     x+5           h23,   Grab Icon

; #Configuration Tab
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
	Gui Add, CheckBox, gSaveGeneral vYesInGameOverlay Checked%YesInGameOverlay%             , Show In-Game Overlay?
	Gui Add, CheckBox, gSaveGeneral vYesChaosOverlay Checked%YesChaosOverlay%               , Show Chaos Overlay?
	Gui Add, Checkbox, gUpdateExtra  vYesGuiLastPosition Checked%YesGuiLastPosition%   xs   , Remember Last GUI Position?
	Gui Add, Checkbox, gUpdateExtra  vYesDX12 Checked%YesDX12%      xs                      , Use Direct X 12?

	Gui,Font, Bold s9 cBlack, Arial
	Gui,Add,GroupBox,Section x295 ym+20  w350 h130              ,Update Control
	Gui,Font,Norm

	Gui, Add, Text, xs+5 yp+20 , Wingman Reloaded  %VersionNumber% 
	Gui Add, DropDownList, gUpdateExtra  vBranchName     w90   xs+5 y+5           , master|Alpha
	GuiControl, ChooseString, BranchName                                                  , %BranchName%
	Gui, Add, Text,       x+8 yp+3                                                        , Update Branch
	Gui Add, DropDownList, gUpdateExtra  vScriptUpdateTimeType   xs+5 y+10  w90                  , Off|days|hours|minutes
	GuiControl, ChooseString, ScriptUpdateTimeType                                        , %ScriptUpdateTimeType%
	Gui Add, Edit, gUpdateExtra  vScriptUpdateTimeInterval  x+5   w40                     , %ScriptUpdateTimeInterval%
	Gui, Add, Text,       x+8 yp+3                                   , Auto-check Update
	Gui, Add, Button, hwndHWND xs+5 y+10, Force Update
	Gui Add, Checkbox, gUpdateExtra  vAutoUpdateOff Checked%AutoUpdateOff%     x+7 yp+4              , Turn off Auto-Update?


	f := Func("checkUpdate").Bind(True)
	GuiControl, +g,% HWND,% f
	f := ""

	Gui,Font, Bold s9 cBlack, Arial
	Gui,Add,GroupBox,Section xs y+20  w350 h170                                                     , Game Setup
	Gui, Add, Text,          xs+5 yp+20                                                             , Aspect Ratio:
	Gui,Font,Norm

	Gui Add, DropDownList, gUpdateResolutionScale  vResolutionScale     w160   x+8 yp-3             , Standard|Classic|Cinematic|Cinematic(43:18)|UltraWide|WXGA(16:10)
	GuiControl, ChooseString, ResolutionScale                                                       , %ResolutionScale%
	Gui, Add, Button, x+5 yp gCheckAspectRatio , Get ratio

	Gui,Font, Bold s9 cBlack, Arial
	Gui, Add, Text,          xs+5 y+10                                                             , POE LogFile:
	Gui,Font,Norm

	Gui, Add, Edit,       vClientLog         x+5 yp-3  w170  h23                                   ,   %ClientLog%
	Gui, add, Button, gSelectClientLog hp yp x+5                                                 , Locate

	IfNotExist, %A_ScriptDir%\data\leagues.json
	{
		UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
	}
	Try {
	LeagueIndex := JSON.Load(FileOpen(A_ScriptDir "\data\leagues.json","r").Read())
	} Catch e {
		MsgBox, 262144, Error loading leagues, % e
		LeagueIndex := [{"id":"Standard"}]
	}
	textList= 
	For K, V in LeagueIndex
		textList .= (!textList ? "" : "|") V["id"]
	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, Text, xs+5 y+10, League:
	Gui, Font,Norm
	Gui, Add, ComboBox, vselectedLeague x+5 yp-3 w150, %textList%
	GuiControl, ChooseString, selectedLeague, %selectedLeague%
	Gui, Add, Button, gUpdateLeagues vUpdateLeaguesBtn x+5 yp-1 , Refresh

	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, Text, xs+5 y+10 , PoE Cookie
	Gui, Font,Norm
	Gui, Add, Edit, password vPoECookie  x+5 yp-3 r1 -wrap  w240, %PoECookie%
	Gui, Font, Bold s9 cBlack, Arial
	Gui, Add, Text, xs+5 y+10 , PoE Account Name
	Gui, Font,Norm
	Gui, Add, Edit, password vAccountNameSTR  x+5 yp-3 r1 -wrap  w120, %AccountNameSTR%

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

; #Hotkey Tab
	Gui, Tab, Hotkeys
	Gui, Font, Bold s9 cBlack, Arial
	Gui Add, GroupBox,    center w170 h180               xm+5   ym+25,         Main Script Keybinds:
	Gui, Font
	Gui,Add,Edit, section xp+5 yp+20        w60 h19   vhotkeyOptions           ,%hotkeyOptions%
	Gui Add, Text,                     hp x+5   yp+3,         Open this GUI
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyAutoFlask         ,%hotkeyAutoFlask%
	Gui Add, Text,                     hp x+5   yp+3,         Toggle Auto-Flask
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyAutoQuit          ,%hotkeyAutoQuit%
	Gui Add, Text,                     hp x+5   yp+3,         Toggle Auto-Quit
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyAutoMove          ,%hotkeyAutoMove%
	Gui Add, Text,                     hp x+5   yp+3,         Toggle Auto-Move
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyAutoUtility       ,%hotkeyAutoUtility%
	Gui Add, Text,                     hp x+5   yp+3,         Toggle Auto-Utility
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyPauseMines       ,%hotkeyPauseMines%
	Gui Add, Text,                     hp x+5   yp+3,         Pause Detonate

	Gui, Font, Bold s9 cBlack, Arial
	Gui Add, GroupBox,    center w170 h100               xm+5   y+5,       Trigger Keybinds: 
	Gui, Font

	Gui Add, Edit, xp+5 yp+20   w60 h19   vhotkeyTriggerMovement   ,%hotkeyTriggerMovement%
	Gui Add, Text,                     hp x+5   yp+3,         Movement Trigger
	Gui Add, Edit, xs y+5   w60 h19   vhotkeyMainAttack        ,%hotkeyMainAttack%
	Gui Add, Text,                     hp x+5   yp+3,         Main Attack
	Gui Add, Edit, xs y+5   w60 h19   vhotkeySecondaryAttack   ,%hotkeySecondaryAttack%
	Gui Add, Text,                     hp x+5   yp+3,         Secondary Attack

	Gui, Font, Bold s9 cBlack, Arial
	Gui Add, GroupBox,    center w170 h180               xm+5   y+5,       Ingame Assigned Keys: 
	Gui, Font

	Gui,Add,Edit, xp+5 yp+20  w60 h19   vhotkeyCloseAllUI    ,%hotkeyCloseAllUI%
	Gui Add, Text, hp x+5   yp+3,         Close UI
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyInventory      ,%hotkeyInventory%
	Gui Add, Text, hp x+5   yp+3,         Inventory
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyWeaponSwapKey    ,%hotkeyWeaponSwapKey%
	Gui Add, Text, hp x+5   yp+3,         W-Swap
	Gui,Add,Edit, xs y+5    w60 h19   vhotkeyLootScan        ,%hotkeyLootScan%
	Gui Add, Text, hp x+5   yp+3,         Item Pickup
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyDetonateMines    ,%hotkeyDetonateMines%
	Gui Add, Text, hp x+5   yp+3,         Detonate Mines
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyOpenPortal    ,%hotkeyOpenPortal%
	Gui Add, Text, hp x+5   yp+3,         Open Portal

	Gui, Font, Bold s9 cBlack, Arial
	Gui Add, GroupBox,    center w170 h440               xs+175   ym+25,       Tool Keybinds: 
	Gui, Font

	Gui,Add,Edit, section xp+5 yp+20   w60 h19   vhotkeyLogout            ,%hotkeyLogout%
	Gui Add, Text,                     hp x+5   yp+3,         Logout
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyPopFlasks         ,%hotkeyPopFlasks%
	Gui Add, Text,                     hp x+5   yp+3,         Pop Flasks
	Gui Add, Checkbox, gUpdateExtra  vPopFlaskRespectCD Checked%PopFlaskRespectCD%                 xs y+1 , Pop Flasks Respect CD?
	Gui,Add,Edit, xs y+3   w60 h19   vhotkeyQuickPortal       ,%hotkeyQuickPortal%
	Gui Add, Text,                     hp x+5   yp+3,         Quick-Portal
	Gui,Add,Edit, xs y+3   w60 h19   vhotkeyGemSwap           ,%hotkeyGemSwap%
	Gui Add, Text,                     hp x+5   yp+3,         Gem-Swap
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyGrabCurrency      ,%hotkeyGrabCurrency%
	Gui Add, Text,                     hp x+5   yp+3,         Grab Currency
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyGetMouseCoords    ,%hotkeyGetMouseCoords%
	Gui Add, Text,                     hp x+5   yp+3,         Coord/Pixel
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyItemInfo          ,%hotkeyItemInfo%
	Gui Add, Text,                     hp x+5   yp+3,         Item Info
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyItemSort          ,%hotkeyItemSort%
	Gui Add, Text,                     hp x+5   yp+3,         Inventory Sort
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyStartCraft        ,%hotkeyStartCraft%
	Gui Add, Text,                     hp x+5   yp+3,         Bulk Craft Maps
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyChaosRecipe       ,%hotkeyChaosRecipe%
	Gui Add, Text,                     hp x+5   yp+3,         Chaos Recipe
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyCraftBasic        ,%hotkeyCraftBasic%
	Gui Add, Text,                     hp x+5   yp+3,         Basic Crafting
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyItemCrafting       ,%hotkeyItemCrafting%
	Gui Add, Text,                     hp x+5   yp+3,         Item Crafting
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyCtrlClicker        ,%hotkeyCtrlClicker%
	Gui Add, Text,                     hp x+5   yp+3,         Ctrl Clicker
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyCtrlShiftClicker   ,%hotkeyCtrlShiftClicker%
	Gui Add, Text,                     hp x+5   yp+3,         CtrlShift Clicker
	Gui,Add,Edit, xs y+5   w60 h19   vhotkeyShiftClicker   ,%hotkeyShiftClicker%
	Gui Add, Text,                     hp x+5   yp+3,         Shift Clicker

	Gui, Font
	Gui, Add, Checkbox, section xs+195 ys vYesController Checked%YesController%,     Enable Controller
	Gui, Font, Bold s9 cBlack, Arial
	Gui, add, button, gWR_Update vWR_Btn_Controller  xs y+10 w130, Set Controller Keys
	Gui, Font

	Gui, Add, Checkbox, gUpdateExtra  vEnableChatHotkeys Checked%EnableChatHotkeys%   xs y+20                   , Enable chat Hotkeys?
	Gui,Font, Bold s9 cBlack, Arial
	Gui, add, button, gWR_Update vWR_Btn_Chat   xp y+10     w130, Set Chat Hotkeys
	Gui,Font,

	Gui, Add, Checkbox, xs y+20  vYesStashKeys Checked%YesStashKeys%                    , Enable stash hotkeys?
	Gui,Font, Bold s9 cBlack, Arial
	Gui, add, button, gWR_Update vWR_Btn_hkStash   xp y+10     w130, Set Stash Hotkeys
	Gui,Font,

	;~ =========================================================================================== Subgroup: Hints
	Gui,Font, Bold s9 cBlack, Arial
	Gui,Add,GroupBox,Section xs  y+25  w130 h80              ,Hotkey Modifiers
	Gui, Add, Button,      gLaunchHelp vLaunchHelp     center wp,   Show Key Help
	Gui,Font,Norm
	Gui,Font,s8,Arial
	Gui,Add,Text,          xs+15 ys+17          ,!%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%ALT
	Gui,Add,Text,              y+5          ,^%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%CTRL
	Gui,Add,Text,              y+5          ,+%A_Tab%=%A_Space%%A_Space%%A_Space%%A_Space%SHIFT


	;Save Setting
	Gui, Add, Button, default gupdateEverything    x380 y470  w150 h23,   Save Configuration
	Gui, Add, Button,      gLaunchSite     x+5           h23,   Website

	Gui, +LastFound +AlwaysOnTop
; Debug Tab
	Gui, Tab, Debug
	Gui, Font, Bold s9 cBlack, Arial
	Gui Add, GroupBox,  section  center w200 h100               xm+5   ym+25,         Debug Tooltips:
	Gui, Font
	Gui Add, Checkbox,   vDebugMessages Checked%DebugMessages%  gUpdateDebug     xs+20 ys+20, Show Debug Tooltips
	Gui Add, Checkbox,   vYesTimeMS Checked%YesTimeMS%  gUpdateDebug     , Logic Tooltips
	Gui Add, Checkbox,   vYesLocation Checked%YesLocation%  gUpdateDebug , Location Tooltips
	
	Gui, Add, Button,      gActualTierCreator     xs ys+120          h23,   Update Actual Tiers
	Gui, Add, Button,      gDBUpdateNinja           h23,   Update Ninja Database
	Gui, Add, Button,      gRefreshChaosRecipe h23,   Reset Chaos Recipe Data
	; Gui, Add, Button,      gForceUpdatePOEDB           h23,   Update PoeDB Affixes
	