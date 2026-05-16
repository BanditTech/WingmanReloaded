SaveINI(ctrlName, type:="General") {
	Global MainGui
	If ctrlName ~= "UpDown"
	{
		control := StrReplace(ctrlName, "UpDown", "")
		IniWrite(MainGui[control].Value, A_ScriptDir "\save\Settings.ini", type, control)
	}
	Else
	IniWrite(MainGui[ctrlName].Value, A_ScriptDir "\save\Settings.ini", type, ctrlName)
	Return
}

SaveGeneral(GuiCtrl, *) {
	SaveINI(GuiCtrl.Name, "General")
}

SaveDelays(GuiCtrl, *) {
	SaveINI(GuiCtrl.Name, "Delays")
}

SaveChaos(GuiCtrl, *) {
	SaveINI(GuiCtrl.Name, "Chaos Recipe")
}

SaveBasicCraft(GuiCtrl, *) {
	SaveINI(GuiCtrl.Name, "Basic Craft")
}

BasicCraftRadio(ctrl, *) {
	Global BasicCraftChanceMethod, BasicCraftColorMethod, BasicCraftLinkMethod, BasicCraftSocketMethod
	saved := ctrl.Gui.Submit(0)
	For propName, val in saved.OwnProps()
		Try %propName% := val
	IniWrite(BasicCraftChanceMethod, A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftChanceMethod")
	IniWrite(BasicCraftColorMethod, A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftColorMethod")
	IniWrite(BasicCraftLinkMethod, A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftLinkMethod")
	IniWrite(BasicCraftSocketMethod, A_ScriptDir "\save\Settings.ini", "Basic Craft", "BasicCraftSocketMethod")
}

SaveStashTabs(GuiCtrl, *) {
	SaveINI(GuiCtrl.Name, "Stash Tab")
	GreyOutAffinity()
}

SaveChaosRadio(ctrl, *) {
	Global ChaosRecipeTypePure, ChaosRecipeTypeHybrid, ChaosRecipeTypeRegal
	Global ChaosRecipeStashMethodDump, ChaosRecipeStashMethodTab, ChaosRecipeStashMethodSort
	saved := ctrl.Gui.Submit(0)
	For propName, val in saved.OwnProps()
		Try %propName% := val
	IniWrite(ChaosRecipeTypePure, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypePure")
	IniWrite(ChaosRecipeTypeHybrid, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypeHybrid")
	IniWrite(ChaosRecipeTypeRegal, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeTypeRegal")
	IniWrite(ChaosRecipeStashMethodDump, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodDump")
	IniWrite(ChaosRecipeStashMethodTab, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodTab")
	IniWrite(ChaosRecipeStashMethodSort, A_ScriptDir "\save\Settings.ini", "Chaos Recipe", "ChaosRecipeStashMethodSort")
}

UpdateExtra(ctrl, *) {
	Global BranchName, ScriptUpdateTimeInterval, ScriptUpdateTimeType, LootVacuum, LootVacuumTapZ
	Global LootVacuumTapZEnd, LootVacuumTapZSec, YesVendor, YesStash, YesSkipMaps, YesSkipMaps_Prep
	Global YesSkipMaps_eval, YesSkipMaps_normal, YesSkipMaps_magic, YesSkipMaps_rare, YesSkipMaps_unique
	Global YesSkipMaps_tier, YesIdentify, YesDiv, YesMapUnid, YesInfluencedUnid, YesSynthesisId
	Global YesSortFirst, Latency, ClickLatency, ClipLatency, PopFlaskRespectCD, ShowOnStart
	Global AutoUpdateOff, YesGuiLastPosition, YesDX12, AreaScale, LVdelay, YesOHB
	Global YesEnableAutomation, FirstAutomationSetting, YesEnableNextAutomation
	Global YesEnableAutoSellConfirmation, YesEnableAutoSellConfirmationSafe, YesLootChests, YesLootDelve
	saved := ctrl.Gui.Submit(0)
	For propName, val in saved.OwnProps()
		Try %propName% := val
	; Gui, Inventory: Submit, NoHide
	IniWrite(BranchName, A_ScriptDir "\save\Settings.ini", "General", "BranchName")
	IniWrite(ScriptUpdateTimeInterval, A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeInterval")
	IniWrite(ScriptUpdateTimeType, A_ScriptDir "\save\Settings.ini", "General", "ScriptUpdateTimeType")
	IniWrite(LootVacuum, A_ScriptDir "\save\Settings.ini", "General", "LootVacuum")
	IniWrite(LootVacuumTapZ, A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZ")
	IniWrite(LootVacuumTapZEnd, A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZEnd")
	IniWrite(LootVacuumTapZSec, A_ScriptDir "\save\Settings.ini", "General", "LootVacuumTapZSec")
	IniWrite(YesVendor, A_ScriptDir "\save\Settings.ini", "General", "YesVendor")
	IniWrite(YesStash, A_ScriptDir "\save\Settings.ini", "General", "YesStash")
	IniWrite(YesSkipMaps, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps")
	IniWrite(YesSkipMaps_Prep, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_Prep")
	IniWrite(YesSkipMaps_eval, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_eval")
	IniWrite(YesSkipMaps_normal, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_normal")
	IniWrite(YesSkipMaps_magic, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_magic")
	IniWrite(YesSkipMaps_rare, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_rare")
	IniWrite(YesSkipMaps_unique, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_unique")
	IniWrite(YesSkipMaps_tier, A_ScriptDir "\save\Settings.ini", "General", "YesSkipMaps_tier")
	IniWrite(YesIdentify, A_ScriptDir "\save\Settings.ini", "General", "YesIdentify")
	IniWrite(YesDiv, A_ScriptDir "\save\Settings.ini", "General", "YesDiv")
	IniWrite(YesMapUnid, A_ScriptDir "\save\Settings.ini", "General", "YesMapUnid")
	IniWrite(YesInfluencedUnid, A_ScriptDir "\save\Settings.ini", "General", "YesInfluencedUnid")
	IniWrite(YesSynthesisId, A_ScriptDir "\save\Settings.ini", "General", "YesSynthesisId")
	IniWrite(YesSortFirst, A_ScriptDir "\save\Settings.ini", "General", "YesSortFirst")
	IniWrite(Latency, A_ScriptDir "\save\Settings.ini", "General", "Latency")
	IniWrite(ClickLatency, A_ScriptDir "\save\Settings.ini", "General", "ClickLatency")
	IniWrite(ClipLatency, A_ScriptDir "\save\Settings.ini", "General", "ClipLatency")
	IniWrite(PopFlaskRespectCD, A_ScriptDir "\save\Settings.ini", "General", "PopFlaskRespectCD")
	IniWrite(ShowOnStart, A_ScriptDir "\save\Settings.ini", "General", "ShowOnStart")
	IniWrite(AutoUpdateOff, A_ScriptDir "\save\Settings.ini", "General", "AutoUpdateOff")
	IniWrite(YesGuiLastPosition, A_ScriptDir "\save\Settings.ini", "General", "YesGuiLastPosition")
	IniWrite(YesDX12, A_ScriptDir "\save\Settings.ini", "General", "YesDX12")
	IniWrite(AreaScale, A_ScriptDir "\save\Settings.ini", "General", "AreaScale")
	IniWrite(LVdelay, A_ScriptDir "\save\Settings.ini", "General", "LVdelay")
	IniWrite(YesOHB, A_ScriptDir "\save\Settings.ini", "OHB", "YesOHB")

	;Automation Settings
	IniWrite(YesEnableAutomation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutomation")
	IniWrite(FirstAutomationSetting, A_ScriptDir "\save\Settings.ini", "Automation Settings", "FirstAutomationSetting")
	IniWrite(YesEnableNextAutomation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableNextAutomation")
	IniWrite(YesEnableAutoSellConfirmation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation")
	IniWrite(YesEnableAutoSellConfirmationSafe, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmationSafe")
	IniWrite(YesLootChests, A_ScriptDir "\save\Settings.ini", "General", "YesLootChests")
	IniWrite(YesLootDelve, A_ScriptDir "\save\Settings.ini", "General", "YesLootDelve")
}

UpdateStackRelease(GuiCtrl, *) {
	Global MainGui
	IniWrite(GuiCtrl.Value, A_ScriptDir "\save\Settings.ini", "StackRelease", GuiCtrl.Name)
}

UpdateStringEdit(GuiCtrl, *) {
	Global MainGui, HealthBarStr, OHBStrW, debuffCurseStr
	Global debuffCurseEleWeakStr, debuffCurseVulnStr, debuffCurseEnfeebleStr, debuffCurseTempChainStr
	Global debuffCurseCondStr, debuffCurseFlamStr, debuffCurseFrostStr, debuffCurseWarMarkStr
	IniWrite(GuiCtrl.Value, A_ScriptDir "\save\Settings.ini", "FindText Strings", GuiCtrl.Name)
	If GuiCtrl.Name == "HealthBarStr"
		OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
	If InStr(GuiCtrl.Name, "debuffCurse")
		debuffCurseStr := debuffCurseEleWeakStr . debuffCurseVulnStr . debuffCurseEnfeebleStr . debuffCurseTempChainStr . debuffCurseCondStr . debuffCurseFlamStr . debuffCurseFrostStr . debuffCurseWarMarkStr
}

UpdateResolutionScale(ctrl, *) {
	Global ResolutionScale
	saved := ctrl.Gui.Submit(0)
	For propName, val in saved.OwnProps()
		Try %propName% := val
	IniWrite(ResolutionScale, A_ScriptDir "\save\Settings.ini", "General", "ResolutionScale")
	Rescale()
}


UpdateDebug(ctrl, *) {
	Global DebugMessages, YesTimeMS, YesLocation
	saved := ctrl.Gui.Submit(0)
	For propName, val in saved.OwnProps()
		Try %propName% := val
	IniWrite(DebugMessages, A_ScriptDir "\save\Settings.ini", "General", "DebugMessages")
	IniWrite(YesTimeMS, A_ScriptDir "\save\Settings.ini", "General", "YesTimeMS")
	IniWrite(YesLocation, A_ScriptDir "\save\Settings.ini", "General", "YesLocation")
}

LoadArray(){
	Global LootFilter
	LootFilter := FileExist(A_ScriptDir "\save\LootFilter.json")
		? JSON.LoadFile(A_ScriptDir "\save\LootFilter.json")
		: Map()
	If !LootFilter
		LootFilter := Map()
	Return
}

optionsCommand(*) {
	MainMenu()
}

GuiEscape(GuiObj) {
	Global CheckGamestates
	GuiObj.Hide()
	CheckGamestates:= False
}

ItemInfoEscape(GuiObj) {
	Global ItemInfoGui
	ItemInfoGui.Hide()
}
ItemInfoClose(GuiObj) {
	Global ItemInfoGui
	ItemInfoGui.Hide()
}

LaunchLootFilter(*) {
	Run(A_ScriptDir "\data\LootFilter.ahk") ; Open the custom loot filter editor
}

LaunchHelp(*) {
	Run("https://www.autohotkey.com/docs/KeyList.htm") ; Open the AutoHotkey List of Keys
}

LaunchSite(*) {
	Run("https://bandittech.github.io/WingmanReloaded") ; Open the Website page for the script
}

LaunchDonate(*) {
	Run("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ESDL6W59QR63A&item_name=Open+Source+Script+Building&currency_code=USD&source=url") ; Open the donation page for the script
}

ft_Start(*) {
	Global MainGui, CheckGamestates
	MainGui.Submit()
	CheckGamestates:= False
	FindText().Gui("Show")
}

helpCalibration(*) {
	MsgBox("Use Game Logic States to observe what panels or game states are considered true or false. Open and close Panels within the game to see their respective status change from green to red. If all status are showing green, the script status should say Wingman Active.`n`n"
	. "If many are not responding to changes in the game, use the Wizard to calibrate them all at once. Just remember to follow the prompts closely in order to ensure proper calibration.`n`n"
	. "Sometimes it may be easier to calibrate one sample at a time, click on any of the labels to perform an individual calibration.`n`n"
	. "If the issue is instead with the percentages of Health, ES, and/or Mana, then you will need to Adjust Globes. Use the menu to change the Scan options which the percentages will be shown in real time on the menu.", "Calibration Tips", 262144)
}

helpAutomationSetting(*) {
	MsgBox("Use Loot Vacuum to configure picking up loot, this function uses the Item Pickup hotkey bound in game. You must enable the In-Game option to only highlight loot when pressed, then you can calibrate colors within the script.`n`n"
	. "Sample Strings will allow you to change the image captures that have been saved for use with the script. Replace the default strings with your own, or use the ones available in the dropdown menus which match your resolution height.", "Automation Tips", 262144)
}

SelectClientLog(GuiCtrl, *) {
	Global MainGui, ClientLog
	If (GuiCtrl.Name == "ClientLog") {
		MainGui.Submit(0)
		If FileExist(ClientLog) {
			IniWrite(ClientLog, A_ScriptDir "\save\Settings.ini", "Log", "ClientLog")
			Monitor_GameLogs(1)
		}
	} Else {
		MainGui.Submit()
		SelectClientLogVar := FileSelect(1, 0, "Select the location of your Client Log file", "Client.txt")
		If SelectClientLogVar != ""
		{
			ClientLog := SelectClientLogVar
			MainGui["ClientLog"].Value := SelectClientLogVar
			IniWrite(SelectClientLogVar, A_ScriptDir "\save\Settings.ini", "Log", "ClientLog")
			Monitor_GameLogs(1)
		}
		MainMenu()
	}
}

GreyOutAffinity() {
  Global MainGui
  for key, val in ["Blight","Delirium","Divination","Fragment","Ultimatum","Delve","Essence","Map","Currency","Unique","Gem","Flask"] {
    CheckBoxState := MainGui["StashTabYes" val].Value
    If (CheckBoxState == 0) {
      MainGui[val "Edit"].Enabled := false
      MainGui[val "EditText"].Value := "Disable Type"
    } Else If (CheckBoxState == 1) {
      MainGui[val "Edit"].Enabled := true
      MainGui[val "EditText"].Value := "Assign a Tab"
    } Else {
      if(val !="Currency" ) {
        MainGui[val "Edit"].Enabled := false
      }
      MainGui[val "EditText"].Value := "Enable Affinity"
    }
  }
  Return
}

; GuiUpdate - Update Overlay ON OFF states
GuiUpdate() {
  Global OverlayGui
  OverlayGui["overlayT1"].Value := "Quit: " (WR.func.Toggle.Quit?"ON":"OFF")
  OverlayGui["overlayT2"].Value := "Flask: " (WR.func.Toggle.Flask?"ON":"OFF")
  OverlayGui["overlayT3"].Value := "Move: " (WR.func.Toggle.Move?"ON":"OFF")
  OverlayGui["overlayT4"].Value := "Util: " (WR.func.Toggle.Utility?"ON":"OFF")
  ShowHideOverlay()
  CtlColors.Change(MainMenuIDAutoFlask, (WR.func.Toggle.Flask?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoQuit, (WR.func.Toggle.Quit?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoMove, (WR.func.Toggle.Move?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoUtility, (WR.func.Toggle.Utility?"52D165":"E0E0E0"), "")
  Return
}

ShowHideOverlay() {
  Global OverlayGui, ChaosGui, YesInGameOverlay, YesChaosOverlay
  OverlayGui["overlayT1"].Visible := YesInGameOverlay
  OverlayGui["overlayT2"].Visible := YesInGameOverlay
  OverlayGui["overlayT3"].Visible := YesInGameOverlay
  OverlayGui["overlayT4"].Visible := YesInGameOverlay

  If (YesChaosOverlay) {
    ChaosGui.Show("NA")
  } Else {
    ChaosGui.Show("Hide")
  }
  Return
}

mainmenuGameLogicState(refresh:=False) {
  Static OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1
  , OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnDetonate:=-1
  Local NewOHB
  If (OnChar != OldOnChar) || refresh {
    OldOnChar := OnChar
    If OnChar
      CtlColors.Change(MainMenuIDOnChar, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnChar, "RED", "")
  }
  If ((NewOHB := (CheckOHB()?1:0)) != OldOHB) || refresh {
    OldOHB := NewOHB
    If NewOHB
      CtlColors.Change(MainMenuIDOnOHB, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnOHB, "RED", "")
  }
  If (OnInventory != OldOnInventory) || refresh {
    OldOnInventory := OnInventory
    If (OnInventory)
      CtlColors.Change(MainMenuIDOnInventory, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnInventory, "", "GREEN")
  }
  If (OnChat != OldOnChat) || refresh {
    OldOnChat := OnChat
    If OnChat
      CtlColors.Change(MainMenuIDOnChat, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnChat, "", "GREEN")
  }
  If (OnStash != OldOnStash) || refresh {
    OldOnStash := OnStash
    If (OnStash)
      CtlColors.Change(MainMenuIDOnStash, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnStash, "", "GREEN")
  }
  If (OnDiv != OldOnDiv) || refresh {
    OldOnDiv := OnDiv
    If (OnDiv)
      CtlColors.Change(MainMenuIDOnDiv, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnDiv, "", "GREEN")
  }
  If (OnLeft != OldOnLeft) || refresh {
    OldOnLeft := OnLeft
    If (OnLeft)
      CtlColors.Change(MainMenuIDOnLeft, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnLeft, "", "GREEN")
  }
  If (OnDelveChart != OldOnDelveChart) || refresh {
    OldOnDelveChart := OnDelveChart
    If (OnDelveChart)
      CtlColors.Change(MainMenuIDOnDelveChart, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnDelveChart, "", "GREEN")
  }
  If (OnVendor != OldOnVendor) || refresh {
    OldOnVendor := OnVendor
    If (OnVendor)
      CtlColors.Change(MainMenuIDOnVendor, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnVendor, "", "GREEN")
  }
  If (OnDetonate != OldOnDetonate) || refresh {
    OldOnDetonate := OnDetonate
    If (OnDetonate)
      CtlColors.Change(MainMenuIDOnDetonate, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnDetonate, "", "GREEN")
  }
  If (OnMenu != OldOnMenu) || refresh {
    OldOnMenu := OnMenu
    If (OnMenu)
      CtlColors.Change(MainMenuIDOnMenu, "RED", "")
    Else
      CtlColors.Change(MainMenuIDOnMenu, "", "GREEN")
  }
  Return
}

CheckPixelGrid(*) {
  Global MainGui, OnInventory, InventoryGridX, InventoryGridY, varEmptyInvSlotColor
  ;Check if inventory is open
  MainGui.Hide()
  if (!OnInventory) {
    TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
  } else {
    TT := "Grid information:" . "`n"
    FindText().ScreenShot()
    For C, GridX in InventoryGridX {
      For R, GridY in InventoryGridY {
        PointColor := FindText().GetColor(GridX,GridY)
        if (indexOf(PointColor, varEmptyInvSlotColor)) {
          TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Empty inventory slot. Color: " . PointColor  .  "`n"
        } else {
          TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Possibly occupied slot. Color: " . PointColor  .  "`n"
        }
      }
    }
  }
  MsgBox(TT)
  MainMenu()
}


helpAutomation(*) {
  Global MainGui
  MainGui.Submit()
  MsgBox("Automation can start from two ways:`n`n"
    . "* Search for the Stash, and begin sorting items`n`n"
    . "* Search for the Vendor, and begin selling items`n`n"
    . "If you Enable Second Automation, both routines will occur`n"
    . "Whatever was not selected will be performed second`n`n"
    . "The following results can be arranged using these settings:`n`n"
    . "1) Search for Stash > Auto Stash Routine > END`n`n"
    . "2) Search for Stash > Auto Stash Routine > Search for Vendor >`n"
    . "Auto Sell Routine > END`n`n"
    . "3) Search for Stash > Auto Stash Routine > Search for Vendor >`n"
    . "Auto Sell Routine > Auto Confirm Sell > END`n`n"
    . "4) Search for Vendor > Auto Vendor Routine > END`n`n"
    . "5) Search for Vendor > Auto Vendor Routine > Wait at Vendor UI 30s >`n"
    . "Search Stash > Auto Stash Routine > END`n`n"
    . "6) Search for Vendor > Auto Vendor Routine > Auto Confirm Sell >`n"
    . "Search for Stash > Auto Stash Routine > END")
  MainMenu()
}

WarningAutomation(*) {
  Global MainGui, YesEnableAutoSellConfirmation, InventoryGui
  MainGui.Submit(0)
  If YesEnableAutoSellConfirmation {
    MainGui.Submit()
    result := MsgBox("Please Be Advised`n`n"
    . "Enabling this option will auto confirm vendoring items, only use this option if you have a well configured CLF to catch good items`n`n"
    . "We will not be responsible for anything lost using this option.`n`n"
    . "If you are unsure about this option, We strongly recomend doing more research before enabling.`n`n"
    . "Come to WingmanReloaded Discord to talk with us or look for more information.`n`n"
    . "You have been warned!!! This option can be dangerous if done incorrectly!!!`n"
    . "Press OK to accept", "WARNING!!!", 1)
    If (result == "OK")
    {
      IniWrite(YesEnableAutoSellConfirmation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation")
      MainMenu()
    } Else If result == "Cancel"
    {
      YesEnableAutoSellConfirmation := 0
      MainMenu()
      InventoryGui["YesEnableAutoSellConfirmation"].Value := 0
      IniWrite(YesEnableAutoSellConfirmation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation")
    } Else {
      YesEnableAutoSellConfirmation := 0
      MainMenu()
      InventoryGui["YesEnableAutoSellConfirmation"].Value := 0
      IniWrite(YesEnableAutoSellConfirmation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation")
    }
  } Else
    IniWrite(YesEnableAutoSellConfirmation, A_ScriptDir "\save\Settings.ini", "Automation Settings", "YesEnableAutoSellConfirmation")
}

MouseTip(x:="", y:="", w:=21, h:=21)
{
  if (x="") {
    pt := Buffer(16, 0), DllCall("GetCursorPos","ptr",pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  If IsObject(x) {
    w := Abs(x.X2-x.X1)
    h := Abs(x.Y2-x.Y1)
    y := (x.Y1<x.Y2?x.Y1:x.Y2)
    x := (x.X1<x.X2?x.X1:x.X2)
  }
  ; x:=Round(x-10), y:=Round(y-10)
  ;-------------------------
  MouseTipGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
  MouseTipGui.Show("Hide w" w " h" h)
  myid := MouseTipGui.Hwnd
  ;-------------------------
  dhw:=A_DetectHiddenWindows
  DetectHiddenWindows(true)
  d:=1, i:=w-d, j:=h-d
  s := "0-0 " w "-0 " w "-" h " 0-" h " 0-0"
  s := s "  " d "-" d " " i "-" d " " i "-" j " " d "-" j " " d "-" d
  WinSetRegion(s, "ahk_id " myid)
  DetectHiddenWindows(dhw)
  ;-------------------------
  MouseTipGui.Show("NA x" x " y" y)
  Loop 4 {
    MouseTipGui.BackColor := A_Index & 1 ? "Red" : "Blue"
    Sleep(500)
  }
  MouseTipGui.Destroy()
}
