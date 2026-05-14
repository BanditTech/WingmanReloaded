
global MainGui := Gui()
global WR_StatusBarCtrl

WR_StatusBarCtrl := MainGui.Add("StatusBar",, WR_Statusbar)
WR_hStatusbar := WR_StatusBarCtrl.Hwnd
WR_StatusBarCtrl.SetParts(220,220)
WR_StatusBarCtrl.SetText("Logic Status", 1)
WR_StatusBarCtrl.SetText("Location Status", 2)
WR_StatusBarCtrl.SetText("Percentage not updated", 3)

MainGuiTabCtrl := MainGui.Add("Tab2", "vMainGuiTabs xm y3 w655 h505 -wrap", "Main|Configuration|Hotkeys|Debug")
; #Main Tab
	MainGuiTabCtrl.UseTab(1)
	MainGui.SetFont()
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",         "Section    w265 h77        xp+5   y+2",         "Per Character Settings")
	MainGui.SetFont()
	MainGui.Add("Button", "w255 xs+5 ys+20", "Configure Character Options").OnEvent("Click", perCharMenu)
	profileList := [], profileStr := ""
	Loop Files A_ScriptDir "\save\profiles\perChar\*.json"
		profileList.Push(StrReplace(A_LoopFileName,".json",""))
	For _k, _v in profileList
		profileStr .=(_k=1?"":"|") _v
	MainGui.Add("ComboBox",  "vProfileMenuperChar xs+6 y+5 w117", profileStr)
	MainGui["ProfileMenuperChar"].Choose(ProfileMenuperChar)
	MainGui.Add("Button", "vMainMenu_perChar_Save x+1 yp hp w40", "Save").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_perChar_Load x+1 yp hp w40", "Load").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_perChar_Remove x+1 yp hp w50", "Remove").OnEvent("Click", Profile)


	; Flask
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",        "Section    w265 h77 xs y+14  ", "Flask Settings")
	MainGui.SetFont()
	Loop 5
		MainGui.Add("Button", "W46 -wrap " ((A_Index==1||A_Index==6)?"xs+6 yp+20":"x+5 yp"), "Flask " A_Index).OnEvent("Click", FlaskMenu)
	profileList := [], profileStr := ""
	Loop Files A_ScriptDir "\save\profiles\Flask\*.json"
		profileList.Push(StrReplace(A_LoopFileName,".json",""))
	For _k, _v in profileList
		profileStr .=(_k=1?"":"|") _v
	MainGui.Add("ComboBox",  "vProfileMenuFlask xs+6 y+5 w117", profileStr)
	MainGui["ProfileMenuFlask"].Choose(ProfileMenuFlask)
	MainGui.Add("Button", "vMainMenu_Flask_Save x+1 yp hp w40", "Save").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_Flask_Load x+1 yp hp w40", "Load").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_Flask_Remove x+1 yp hp w50", "Remove").OnEvent("Click", Profile)

	; Utility
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",        "Section    w265 h105 xs y+14  ", "Utility Settings")
	MainGui.SetFont()
	Loop 10
		MainGui.Add("Button", "W46 -wrap " (A_Index==1?"xs+6 yp+20":A_Index==6?"xs+6 y+5":"x+5 yp"), "Utility " A_Index).OnEvent("Click", UtilityMenu)

	profileList := [], profileStr := ""
	Loop Files A_ScriptDir "\save\profiles\Utility\*.json"
		profileList.Push(StrReplace(A_LoopFileName,".json",""))
	For _k, _v in profileList
		profileStr .=(_k=1?"":"|") _v
	MainGui.Add("ComboBox",  "vProfileMenuUtility xs+6 y+5 w117", profileStr)
	MainGui["ProfileMenuUtility"].Choose(ProfileMenuUtility)
	MainGui.Add("Button", "vMainMenu_Utility_Save x+1 yp hp w40", "Save").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_Utility_Load x+1 yp hp w40", "Load").OnEvent("Click", Profile)
	MainGui.Add("Button", "vMainMenu_Utility_Remove x+1 yp hp w50", "Remove").OnEvent("Click", Profile)

	;Middle Vertical Lines
	MainGui.Add("Text",                   "xm+279   y23    w1  h483 0x7")
	MainGui.Add("Text",                   "x+1   y23    w1  h483 0x7")

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",  "Center   Section  w350 h210        x+15   ym+20",    "Game Logic States")
	MainGui.SetFont()
	ctrl := MainGui.Add("Text", "Section xs+20 ys+20 w150 Center h20 0x200 vMainMenuOnChar", "Character Active")
	MainMenuIDOnChar := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnChar, "52D165", "")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnChar)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuOnOHB", "Overhead Health Bar")
	MainMenuIDOnOHB := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnOHB, "52D165", "")
	; MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnOHB)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuOnChat", "Chat Open")
	MainMenuIDOnChat := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnChat, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnChat)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuOnInventory", "Inventory Open")
	MainMenuIDOnInventory := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnInventory, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnInventory)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuOnDiv", "Div Trade Open")
	MainMenuIDOnDiv := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnDiv, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnDiv)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuOnStash", "Stash Open")
	MainMenuIDOnStash := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnStash, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnStash)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuOnMenu", "Talent Menu Open")
	MainMenuIDOnMenu := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnMenu, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnMenu)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuOnVendor", "Vendor Trade Open")
	MainMenuIDOnVendor := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnVendor, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnVendor)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuOnDelveChart", "Delve Chart Open")
	MainMenuIDOnDelveChart := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnDelveChart, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnDelveChart)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuOnLeft", "Left Panel Open")
	MainMenuIDOnLeft := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnLeft, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateOnLeft)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuOnDetonate", "Detonate Shown")
	MainMenuIDOnDetonate := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDOnDetonate, "", "Green")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", updateDetonate)

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",      "Center       section        xs-20   y+35 w350 h60",         "Gamestate Calibration")
	MainGui.SetFont("s8")
	MainGui.Add("Button", "xp+250 ys-4    h20",  "? help").OnEvent("Click", helpCalibration)
	MainGui.Add("Button", "vStartCalibrationWizardBtn  xs+10  ys+20 w105 h25",   "Run Wizard").OnEvent("Click", StartCalibrationWizard)
	MainGui.Add("Button", "vWR_Btn_Globe         x+8 yp       wp",   "Adjust Globes").OnEvent("Click", WR_Update)
	; MainGui.Add("Button", "vWR_Btn_Locations         xs+10  y+10      wp",   "Adjust Locations").OnEvent("Click", WR_Update)
	MainGui.Add("Button", "x+8 yp wp", "Inventory Grid").OnEvent("Click", CheckPixelGrid)
	MainGui.SetFont()

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",      "Center       section        xs   y+20 w350 h80",        "Active Functions")
	MainGui.SetFont("s8")
	ctrl := MainGui.Add("Text", "Section xs+20 ys+20 w150 Center h20 0x200 vMainMenuAutoFlask", "Flask Triggers")
	MainMenuIDAutoFlask := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDAutoFlask, "52D165", "")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", toggleAutoFlask)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuAutoQuit", "Quit Trigger")
	MainMenuIDAutoQuit := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDAutoQuit, "52D165", "")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", toggleAutoQuit)
	ctrl := MainGui.Add("Text", "xs y+10 w150 Center h20 0x200 vMainMenuAutoMove", "Move Triggers")
	MainMenuIDAutoMove := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDAutoMove, "52D165", "")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", toggleAutoMove)
	ctrl := MainGui.Add("Text", "x+5 yp w150 Center h20 0x200 vMainMenuAutoUtility", "Utility Triggers")
	MainMenuIDAutoUtility := ctrl.Hwnd
	CtlColors.Attach(MainMenuIDAutoUtility, "52D165", "")
	MainGui.Add("Text", "xp yp wp hp BackgroundTrans").OnEvent("Click", toggleAutoUtility)


	;Save Setting
	MainGui.Add("Button", "default x295 y470  w150 h23",   "Save Configuration").OnEvent("Click", updateEverything)
	MainGui.Add("Button",      "x+5           h23",   "Website").OnEvent("Click", LaunchSite)
	MainGui.Add("Button",      "x+5           h23",   "Grab Icon").OnEvent("Click", ft_Start)

; #Configuration Tab
	MainGuiTabCtrl.UseTab(2)
	MainGui.Add("Text",                   "x279   y23    w1  h483 0x7")
	MainGui.Add("Text",                   "x+1   y23    w1  h483 0x7")

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text",           "Section          x22   y30",         "Automation Settings:")
	MainGui.Add("Button", "x+10 ys-4    h20",  "? help").OnEvent("Click", helpAutomationSetting)
	MainGui.Add("Button", "vWR_Btn_Strings     xs ys+18 w110", "Sample Strings").OnEvent("Click", WR_Update)
	MainGui.Add("Button", "vLootVacuumSettings x+8 yp w110", "Loot Vacuum").OnEvent("Click", LootColorsMenu)
	MainGui.SetFont()

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text",           "Section          xs   y+10",         "Item and Inventory Settings:")
	MainGui.Add("Button", "vWR_Btn_CLF  xs y+10 w110", "Custom Loot Filter").OnEvent("Click", LaunchLootFilter)
	MainGui.Add("Button", "vWR_Btn_Inventory   x+10 yp w110", "Inventory Sorting").OnEvent("Click", WR_Update)
	MainGui.Add("Button", "vWR_Btn_Crafting  xs y+10 w110", "Crafting").OnEvent("Click", WR_Update)
	MainGui.SetFont()

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text",           "Section          xs   y+10",         "Interface Options:")
	MainGui.SetFont()

	ctrl := MainGui.Add("CheckBox", "vYesOHB", "Pause script when OHB missing?")
	ctrl.Value := YesOHB
	ctrl.OnEvent("Click", UpdateExtra)
	ctrl := MainGui.Add("CheckBox", "vShowOnStart", "Show GUI on startup?")
	ctrl.Value := ShowOnStart
	ctrl.OnEvent("Click", UpdateExtra)
	ctrl := MainGui.Add("CheckBox", "vYesInGameOverlay", "Show In-Game Overlay?")
	ctrl.Value := YesInGameOverlay
	ctrl.OnEvent("Click", SaveGeneral)
	ctrl := MainGui.Add("CheckBox", "vYesChaosOverlay", "Show Chaos Overlay?")
	ctrl.Value := YesChaosOverlay
	ctrl.OnEvent("Click", SaveGeneral)
	ctrl := MainGui.Add("CheckBox", "vYesGuiLastPosition xs", "Remember Last GUI Position?")
	ctrl.Value := YesGuiLastPosition
	ctrl.OnEvent("Click", UpdateExtra)
	ctrl := MainGui.Add("CheckBox", "vYesDX12 xs", "Use Direct X 12?")
	ctrl.Value := YesDX12
	ctrl.OnEvent("Click", UpdateExtra)

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox","Section x295 ym+20  w350 h130",              "Update Control")
	MainGui.SetFont("Norm")

	MainGui.Add("Text", "xs+5 yp+20", "Wingman Reloaded  " VersionNumber)
	ctrl := MainGui.Add("DropDownList", "vBranchName     w90   xs+5 y+5", ["master","Alpha"])
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui["BranchName"].Choose(BranchName)
	MainGui.Add("Text",       "x+8 yp+3",                                                         "Update Branch")
	ctrl := MainGui.Add("DropDownList", "vScriptUpdateTimeType   xs+5 y+10  w90", ["Off","days","hours","minutes"])
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui["ScriptUpdateTimeType"].Choose(ScriptUpdateTimeType)
	ctrl := MainGui.Add("Edit", "vScriptUpdateTimeInterval  x+5   w40",  ScriptUpdateTimeInterval)
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui.Add("Text",       "x+8 yp+3",                                    "Auto-check Update")
	forceUpdateBtn := MainGui.Add("Button", "xs+5 y+10", "Force Update")
	MainMenuIDForceUpdate := forceUpdateBtn.Hwnd
	ctrl := MainGui.Add("CheckBox", "vAutoUpdateOff     x+7 yp+4", "Turn off Auto-Update?")
	ctrl.Value := AutoUpdateOff
	ctrl.OnEvent("Click", UpdateExtra)


	f := checkUpdate.Bind(True)
	forceUpdateBtn.OnEvent("Click", f)
	f := ""

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox","Section xs y+20  w350 h170",                                                      "Game Setup")
	MainGui.Add("Text",          "xs+5 yp+20",                                                              "Aspect Ratio:")
	MainGui.SetFont("Norm")

	ctrl := MainGui.Add("DropDownList", "vResolutionScale     w160   x+8 yp-3", ["Standard","Classic","Cinematic","Cinematic(43:18)","UltraWide","WXGA(16:10)"])
	ctrl.OnEvent("Change", UpdateResolutionScale)
	MainGui["ResolutionScale"].Choose(ResolutionScale)
	MainGui.Add("Button", "x+5 yp", "Get ratio").OnEvent("Click", CheckAspectRatio)

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text",          "xs+5 y+10",                                                              "POE LogFile:")
	MainGui.SetFont("Norm")

	MainGui.Add("Edit",       "vClientLog         x+5 yp-3  w170  h23",                                    ClientLog)
	MainGui.Add("Button", "hp yp x+5",                                                  "Locate").OnEvent("Click", SelectClientLog)

	if !FileExist(A_ScriptDir "\data\leagues.json")
	{
		Download("http://api.pathofexile.com/leagues", A_ScriptDir "\data\leagues.json")
	}
	Try {
		LeagueIndex := JSON.LoadFile(A_ScriptDir "\data\leagues.json")
	} catch as e {
		MsgBox(e, "Error loading leagues", 262144)
		LeagueIndex := [{id:"Standard"}]
	}
	textList := ""
	For K, V in LeagueIndex
		textList .= (!textList ? "" : "|") V["id"]
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text", "xs+5 y+10", "League:")
	MainGui.SetFont("Norm")
	MainGui.Add("ComboBox", "vselectedLeague x+5 yp-3 w150", textList)
	MainGui["selectedLeague"].Choose(selectedLeague)
	MainGui.Add("Button", "vUpdateLeaguesBtn x+5 yp-1", "Refresh").OnEvent("Click", UpdateLeagues)

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text", "xs+5 y+10", "PoE Cookie")
	MainGui.SetFont("Norm")
	MainGui.Add("Edit", "password vPoECookie  x+5 yp-3 r1 -wrap  w240", PoECookie)
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Text", "xs+5 y+10", "PoE Account Name")
	MainGui.SetFont("Norm")
	MainGui.Add("Edit", "password vAccountNameSTR  x+5 yp-3 r1 -wrap  w120", AccountNameSTR)

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox","Section xs y+10  w350 h55",                                                      "Script Latency")
	MainGui.SetFont("Norm")
	ctrl := MainGui.Add("DropDownList", "vLatency w40 xs+5 yp+20", [" 1","1.1","1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9","2","2.5","3"])
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui["Latency"].Choose(Latency)
	MainGui.Add("Text",                     "x+5 yp+3 hp-3",               "Global Adjust")
	ctrl := MainGui.Add("DropDownList", "vClickLatency w35 x+10 yp-3", [" -2","-1","0","1","2","3","4"])
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui["ClickLatency"].Choose(ClickLatency)
	MainGui.Add("Text",                     "x+5 yp+3  hp-3",             "Click Adjust")
	ctrl := MainGui.Add("DropDownList", "vClipLatency w35 x+10 yp-3", [" -2","-1","0","1","2","3","4"])
	ctrl.OnEvent("Change", UpdateExtra)
	MainGui["ClipLatency"].Choose(ClipLatency)
	MainGui.Add("Text",                     "x+5 yp+3  hp-3",             "Clip Adjust")

	;Save Setting
	MainGui.Add("Button", "default x295 y470  w150 h23",   "Save Configuration").OnEvent("Click", updateEverything)
	MainGui.Add("Button",      "x+5           h23",   "Website").OnEvent("Click", LaunchSite)

; #Hotkey Tab
	MainGuiTabCtrl.UseTab(3)
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",    "center w170 h180               xm+5   ym+25",         "Main Script Keybinds:")
	MainGui.SetFont()
	MainGui.Add("Edit", "section xp+5 yp+20        w60 h19   vhotkeyOptions",            hotkeyOptions)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Open this GUI")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyAutoFlask",          hotkeyAutoFlask)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Toggle Auto-Flask")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyAutoQuit",           hotkeyAutoQuit)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Toggle Auto-Quit")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyAutoMove",           hotkeyAutoMove)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Toggle Auto-Move")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyAutoUtility",        hotkeyAutoUtility)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Toggle Auto-Utility")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyPauseMines",        hotkeyPauseMines)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Pause Detonate")

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",    "center w170 h100               xm+5   y+5",       "Trigger Keybinds:")
	MainGui.SetFont()

	MainGui.Add("Edit", "xp+5 yp+20   w60 h19   vhotkeyTriggerMovement",    hotkeyTriggerMovement)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Movement Trigger")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyMainAttack",         hotkeyMainAttack)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Main Attack")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeySecondaryAttack",    hotkeySecondaryAttack)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Secondary Attack")

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",    "center w170 h180               xm+5   y+5",       "Ingame Assigned Keys:")
	MainGui.SetFont()

	MainGui.Add("Edit", "xp+5 yp+20  w60 h19   vhotkeyCloseAllUI",     hotkeyCloseAllUI)
	MainGui.Add("Text", "hp x+5   yp+3",         "Close UI")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyInventory",       hotkeyInventory)
	MainGui.Add("Text", "hp x+5   yp+3",         "Inventory")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyWeaponSwapKey",     hotkeyWeaponSwapKey)
	MainGui.Add("Text", "hp x+5   yp+3",         "W-Swap")
	MainGui.Add("Edit", "xs y+5    w60 h19   vhotkeyLootScan",         hotkeyLootScan)
	MainGui.Add("Text", "hp x+5   yp+3",         "Item Pickup")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyDetonateMines",     hotkeyDetonateMines)
	MainGui.Add("Text", "hp x+5   yp+3",         "Detonate Mines")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyOpenPortal",     hotkeyOpenPortal)
	MainGui.Add("Text", "hp x+5   yp+3",         "Open Portal")

	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",    "center w170 h440               xs+175   ym+25",       "Tool Keybinds:")
	MainGui.SetFont()

	MainGui.Add("Edit", "section xp+5 yp+20   w60 h19   vhotkeyLogout",             hotkeyLogout)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Logout")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyPopFlasks",          hotkeyPopFlasks)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Pop Flasks")
	ctrl := MainGui.Add("CheckBox", "vPopFlaskRespectCD                 xs y+1", "Pop Flasks Respect CD?")
	ctrl.Value := PopFlaskRespectCD
	ctrl.OnEvent("Click", UpdateExtra)
	MainGui.Add("Edit", "xs y+3   w60 h19   vhotkeyQuickPortal",        hotkeyQuickPortal)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Quick-Portal")
	MainGui.Add("Edit", "xs y+3   w60 h19   vhotkeyGemSwap",            hotkeyGemSwap)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Gem-Swap")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyGrabCurrency",       hotkeyGrabCurrency)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Grab Currency")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyGetMouseCoords",     hotkeyGetMouseCoords)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Coord/Pixel")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyItemInfo",           hotkeyItemInfo)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Item Info")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyItemSort",           hotkeyItemSort)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Inventory Sort")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyStartCraft",         hotkeyStartCraft)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Bulk Craft Maps")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyChaosRecipe",        hotkeyChaosRecipe)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Chaos Recipe")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyCraftBasic",         hotkeyCraftBasic)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Basic Crafting")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyItemCrafting",        hotkeyItemCrafting)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Item Crafting")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyCtrlClicker",         hotkeyCtrlClicker)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Ctrl Clicker")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyCtrlShiftClicker",    hotkeyCtrlShiftClicker)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "CtrlShift Clicker")
	MainGui.Add("Edit", "xs y+5   w60 h19   vhotkeyShiftClicker",    hotkeyShiftClicker)
	MainGui.Add("Text",                     "hp x+5   yp+3",         "Shift Clicker")

	MainGui.SetFont()
	ctrl := MainGui.Add("CheckBox", "section xs+195 ys vYesController", "    Enable Controller")
	ctrl.Value := YesController
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Button", "vWR_Btn_Controller  xs y+10 w130", "Set Controller Keys").OnEvent("Click", WR_Update)
	MainGui.SetFont()

	ctrl := MainGui.Add("CheckBox", "vEnableChatHotkeys   xs y+20", "Enable chat Hotkeys?")
	ctrl.Value := EnableChatHotkeys
	ctrl.OnEvent("Click", UpdateExtra)
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Button", "vWR_Btn_Chat   xp y+10     w130", "Set Chat Hotkeys").OnEvent("Click", WR_Update)
	MainGui.SetFont()

	ctrl := MainGui.Add("CheckBox", "xs y+20  vYesStashKeys", "Enable stash hotkeys?")
	ctrl.Value := YesStashKeys
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("Button", "vWR_Btn_hkStash   xp y+10     w130", "Set Stash Hotkeys").OnEvent("Click", WR_Update)
	MainGui.SetFont()

	;~ =========================================================================================== Subgroup: Hints
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox","Section xs  y+25  w130 h80",              "Hotkey Modifiers")
	MainGui.Add("Button",      "vLaunchHelp     center wp",   "Show Key Help").OnEvent("Click", LaunchHelp)
	MainGui.SetFont("Norm")
	MainGui.SetFont("s8","Arial")
	MainGui.Add("Text",          "xs+15 ys+17",          "!" A_Tab "=" A_Space A_Space A_Space A_Space "ALT")
	MainGui.Add("Text",              "y+5",          "^" A_Tab "=" A_Space A_Space A_Space A_Space "CTRL")
	MainGui.Add("Text",              "y+5",          "+" A_Tab "=" A_Space A_Space A_Space A_Space "SHIFT")


	;Save Setting
	MainGui.Add("Button", "default x380 y470  w150 h23",   "Save Configuration").OnEvent("Click", updateEverything)
	MainGui.Add("Button",      "x+5           h23",   "Website").OnEvent("Click", LaunchSite)

	MainGui.Opt("+LastFound +AlwaysOnTop")
; Debug Tab
	MainGuiTabCtrl.UseTab(4)
	MainGui.SetFont("Bold s9 cBlack", "Arial")
	MainGui.Add("GroupBox",  "section  center w200 h100               xm+5   ym+25",         "Debug Tooltips:")
	MainGui.SetFont()
	ctrl := MainGui.Add("CheckBox",   "vDebugMessages     xs+20 ys+20", "Show Debug Tooltips")
	ctrl.Value := DebugMessages
	ctrl.OnEvent("Click", UpdateDebug)
	ctrl := MainGui.Add("CheckBox",   "vYesTimeMS", "Logic Tooltips")
	ctrl.Value := YesTimeMS
	ctrl.OnEvent("Click", UpdateDebug)
	ctrl := MainGui.Add("CheckBox",   "vYesLocation", "Location Tooltips")
	ctrl.Value := YesLocation
	ctrl.OnEvent("Click", UpdateDebug)

	MainGui.Add("Button",      "xs ys+120          h23",   "Update Actual Tiers").OnEvent("Click", ActualTierCreator)
	MainGui.Add("Button",      "h23",   "Update Ninja Database").OnEvent("Click", DBUpdateNinja)
	MainGui.Add("Button",      "h23",   "Reset Chaos Recipe Data").OnEvent("Click", RefreshChaosRecipe)
	; MainGui.Add("Button",      "h23",   "Update PoeDB Affixes").OnEvent("Click", ForceUpdatePOEDB)

	; AHK Delay Adjustments
	MainGui.Add("GroupBox",  "section  center w200 h130               xm+5 y+15",         "AHK Action Adjustment:")

	MainGui.Add("Edit", "xs+20 ys+20 w40 h20 vSetKeyDelayValue1", SetKeyDelayValue1).OnEvent("Change", SaveDelays)
	MainGui.Add("Text", "x+5", "Keypress Duration (ms)")

	MainGui.Add("Edit", "xs+20 y+10 w40 h20 vSetKeyDelayValue2", SetKeyDelayValue2).OnEvent("Change", SaveDelays)
	MainGui.Add("Text", "x+5", "Keypress Delay (ms)")

	MainGui.Add("Edit", "xs+20 y+10 w40 h20 vSetMouseDelayValue", SetMouseDelayValue).OnEvent("Change", SaveDelays)
	MainGui.Add("Text", "x+5", "Mouse Delay (ms)")

	MainGui.Add("Edit", "xs+20 y+10 w40 h20 vSetDefaultMouseSpeedValue", SetDefaultMouseSpeedValue).OnEvent("Change", SaveDelays)
	MainGui.Add("Text", "x+5", "Mouse Speed (0-100)")

	MainGuiTabCtrl.UseTab()
