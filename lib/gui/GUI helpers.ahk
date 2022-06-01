SaveINI(type:="General") {
	Gui, Submit, NoHide
	If A_GuiControl ~= "UpDown"
	{
		control := StrReplace(A_GuiControl, "UpDown", "")
		IniWrite,% %control%, %A_ScriptDir%\save\Settings.ini,% type,% control
	}
	Else
	IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini,% type,% A_GuiControl
	Return
}

SaveGeneral:
	SaveINI("General")
Return

SaveChaos:
	SaveINI("Chaos Recipe")
Return

SaveBasicCraft:
	SaveINI("Basic Craft")
Return

SaveSextantMethodRadio:
	Gui, Submit, NoHide
	IniWrite, %SextantCraftingMethod%, %A_ScriptDir%\save\Settings.ini, Item Crafting Settings, SextantCraftingMethod
Return

BasicCraftRadio:
	Gui, Submit, NoHide
	IniWrite, %BasicCraftChanceMethod%, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftChanceMethod
	IniWrite, %BasicCraftColorMethod%, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftColorMethod
	IniWrite, %BasicCraftLinkMethod%, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftLinkMethod
	IniWrite, %BasicCraftSocketMethod%, %A_ScriptDir%\save\Settings.ini, Basic Craft, BasicCraftSocketMethod
Return

SaveStashTabs:
	SaveINI("Stash Tab")
	GreyOutAffinity()
Return

SaveChaosRadio:
	Gui, Submit, NoHide
	IniWrite, %ChaosRecipeTypePure%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypePure
	IniWrite, %ChaosRecipeTypeHybrid%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeHybrid
	IniWrite, %ChaosRecipeTypeRegal%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeTypeRegal
	IniWrite, %ChaosRecipeStashMethodDump%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodDump
	IniWrite, %ChaosRecipeStashMethodTab%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodTab
	IniWrite, %ChaosRecipeStashMethodSort%, %A_ScriptDir%\save\Settings.ini, Chaos Recipe, ChaosRecipeStashMethodSort
Return

UpdateExtra:
	Gui, Submit, NoHide
	; Gui, Inventory: Submit, NoHide
	IniWrite, %BranchName%, %A_ScriptDir%\save\Settings.ini, General, BranchName
	IniWrite, %ScriptUpdateTimeInterval%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeInterval
	IniWrite, %ScriptUpdateTimeType%, %A_ScriptDir%\save\Settings.ini, General, ScriptUpdateTimeType
	IniWrite, %LootVacuum%, %A_ScriptDir%\save\Settings.ini, General, LootVacuum
	IniWrite, %LootVacuumTapZ%, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZ
	IniWrite, %LootVacuumTapZEnd%, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZEnd
	IniWrite, %LootVacuumTapZSec%, %A_ScriptDir%\save\Settings.ini, General, LootVacuumTapZSec
	IniWrite, %YesVendor%, %A_ScriptDir%\save\Settings.ini, General, YesVendor
	IniWrite, %YesStash%, %A_ScriptDir%\save\Settings.ini, General, YesStash
	IniWrite, %YesHeistLocker%, %A_ScriptDir%\save\Settings.ini, General, YesHeistLocker
	IniWrite, %YesPredictivePrice%, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice
	IniWrite, %YesSkipMaps%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps
	IniWrite, %YesSkipMaps_Prep%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_Prep
	IniWrite, %YesSkipMaps_eval%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_eval
	IniWrite, %YesSkipMaps_normal%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_normal
	IniWrite, %YesSkipMaps_magic%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_magic
	IniWrite, %YesSkipMaps_rare%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_rare
	IniWrite, %YesSkipMaps_unique%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_unique
	IniWrite, %YesSkipMaps_tier%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps_tier
	IniWrite, %YesIdentify%, %A_ScriptDir%\save\Settings.ini, General, YesIdentify
	IniWrite, %YesDiv%, %A_ScriptDir%\save\Settings.ini, General, YesDiv
	IniWrite, %YesMapUnid%, %A_ScriptDir%\save\Settings.ini, General, YesMapUnid
	IniWrite, %YesInfluencedUnid%, %A_ScriptDir%\save\Settings.ini, General, YesInfluencedUnid
	IniWrite, %YesSortFirst%, %A_ScriptDir%\save\Settings.ini, General, YesSortFirst
	IniWrite, %Latency%, %A_ScriptDir%\save\Settings.ini, General, Latency
	IniWrite, %ClickLatency%, %A_ScriptDir%\save\Settings.ini, General, ClickLatency
	IniWrite, %ClipLatency%, %A_ScriptDir%\save\Settings.ini, General, ClipLatency
	IniWrite, %PopFlaskRespectCD%, %A_ScriptDir%\save\Settings.ini, General, PopFlaskRespectCD
	IniWrite, %ShowOnStart%, %A_ScriptDir%\save\Settings.ini, General, ShowOnStart
	IniWrite, %AutoUpdateOff%, %A_ScriptDir%\save\Settings.ini, General, AutoUpdateOff
	IniWrite, %YesGuiLastPosition%, %A_ScriptDir%\save\Settings.ini, General, YesGuiLastPosition
	IniWrite, %AreaScale%, %A_ScriptDir%\save\Settings.ini, General, AreaScale
	IniWrite, %LVdelay%, %A_ScriptDir%\save\Settings.ini, General, LVdelay
	IniWrite, %YesOHB%, %A_ScriptDir%\save\Settings.ini, OHB, YesOHB

	;Automation Settings
	IniWrite, %YesEnableAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutomation
	IniWrite, %FirstAutomationSetting%, %A_ScriptDir%\save\Settings.ini, Automation Settings, FirstAutomationSetting
	IniWrite, %YesEnableNextAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableNextAutomation
	IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
	IniWrite, %YesEnableAutoSellConfirmationSafe%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmationSafe
	
	;Automation Metamorph Settings
	IniWrite, %YesFillMetamorph%, %A_ScriptDir%\save\Settings.ini, General, YesFillMetamorph
	IniWrite, %YesClickPortal%, %A_ScriptDir%\save\Settings.ini, General, YesClickPortal
	IniWrite, %YesLootChests%, %A_ScriptDir%\save\Settings.ini, General, YesLootChests
	IniWrite, %YesLootDelve%, %A_ScriptDir%\save\Settings.ini, General, YesLootDelve
Return

UpdateStackRelease:
	Gui, Submit, NoHide
	IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini, StackRelease,% A_GuiControl
Return

UpdateStringEdit:
	Gui, Submit, NoHide
	IniWrite,% %A_GuiControl%, %A_ScriptDir%\save\Settings.ini, FindText Strings,% A_GuiControl
	If A_GuiControl = HealthBarStr
		OHBStrW := StrSplit(StrSplit(HealthBarStr, "$")[2], ".")[1]
	If InStr(A_GuiControl, "debuffCurse")
		debuffCurseStr := debuffCurseEleWeakStr . debuffCurseVulnStr . debuffCurseEnfeebleStr . debuffCurseTempChainStr . debuffCurseCondStr . debuffCurseFlamStr . debuffCurseFrostStr . debuffCurseWarMarkStr
Return

UpdateResolutionScale:
	Gui, Submit, NoHide
	IniWrite, %ResolutionScale%, %A_ScriptDir%\save\Settings.ini, General, ResolutionScale
	Rescale()
Return


UpdateDebug:
	Gui, Submit, NoHide
	IniWrite, %DebugMessages%, %A_ScriptDir%\save\Settings.ini, General, DebugMessages
	IniWrite, %YesTimeMS%, %A_ScriptDir%\save\Settings.ini, General, YesTimeMS
	IniWrite, %YesLocation%, %A_ScriptDir%\save\Settings.ini, General, YesLocation
Return

LoadArray:
	LoadArray()
return

LoadArray(){
	FileRead, JSONtext, %A_ScriptDir%\save\LootFilter.json
	LootFilter := JSON.Load(JSONtext)
	If !LootFilter
		LootFilter:={}
	Return
}

optionsCommand:
	MainMenu()
return

GuiEscape:
	Gui, Cancel
	CheckGamestates:= False
return

ItemInfoEscape:
ItemInfoClose:
	Gui, ItemInfo: Hide
Return

LaunchLootFilter:
	Run, %A_ScriptDir%\data\LootFilter.ahk ; Open the custom loot filter editor
Return

LaunchHelp:
	Run, https://www.autohotkey.com/docs/KeyList.htm ; Open the AutoHotkey List of Keys
Return

LaunchSite:
	Run, https://bandittech.github.io/WingmanReloaded ; Open the Website page for the script
Return

LaunchDonate:
	Run, https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ESDL6W59QR63A&item_name=Open+Source+Script+Building&currency_code=USD&source=url ; Open the donation page for the script
Return

ft_Start:
	Gui, Submit
	CheckGamestates:= False
	Run, FindText.ahk, %A_ScriptDir%\lib\ref\
Return

helpCalibration:
	MsgBox, 262144, Calibration Tips, % "Use Game Logic States to observe what panels or game states are considered true or false. Open and close Panels within the game to see their respective status change from green to red. If all status are showing green, the script status should say Wingman Active.`n`n"
	. "If many are not responding to changes in the game, use the Wizard to calibrate them all at once. Just remember to follow the prompts closely in order to ensure proper calibration.`n`n"
	. "Sometimes it may be easier to calibrate one sample at a time, and this can be done with the Individual Sample menu.`n`n"
	. "If the issue is instead with the percentages of Health, ES, and/or Mana, then you will need to Adjust Globes. Use the menu to change the Scan options which the percentages will be shown in real time on the menu.`n`n"
	. "If the issue is with aspect ratio and you have already calculated your ratio manually, use Adjust Locations to enter custom positions."
Return

helpAutomationSetting:
	MsgBox, 262144, Automation Tips, % "Use Loot Vacuum to configure picking up loot, this function uses the Item Pickup hotkey bound in game. You must enable the In-Game option to only highlight loot when pressed, then you can calibrate colors within the script.`n`n"
	. "Sample Strings will allow you to change the image captures that have been saved for use with the script. Replace the default strings with your own, or use the ones available in the dropdown menus which match your resolution height."
Return

SelectClientLog:
	If (A_GuiControl = "ClientLog")
	{
		Gui, submit, NoHide
		If FileExist(ClientLog)
		{
			IniWrite, %ClientLog%, %A_ScriptDir%\save\Settings.ini, Log, ClientLog
			Monitor_GameLogs(1)
		}
	}
	Else
	{
		Gui, submit
		FileSelectFile, SelectClientLog, 1, 0, Select the location of your Client Log file, Client.txt
		If SelectClientLog !=
		{
			ClientLog := SelectClientLog
			GuiControl,, ClientLog, %SelectClientLog%
			IniWrite, %SelectClientLog%, %A_ScriptDir%\save\Settings.ini, Log, ClientLog
			Monitor_GameLogs(1)
		}
		MainMenu()
	}
Return

GreyOutAffinity(){
  for key, val in ["Blight","Delirium","Divination","Fragment","Metamorph","Delve","Essence","Map","Currency","Unique","Gem","Flask"]
  {
    GuiControlGet, CheckBoxState,, StashTabYes%val%
    If (CheckBoxState == 0)
    { 
      GuiControl, Disable, %val%Edit
      GuiControl, , %val%EditText, Disable Type
    } 
    Else If (CheckBoxState == 1)
    {
      GuiControl, Enable, %val%Edit
      GuiControl, , %val%EditText, Assign a Tab
    }
    Else 
    {
      if(val !="Currency" )
      {
        GuiControl, Disable, %val%Edit
      }
      GuiControl, , %val%EditText, Enable Affinity
    }
  }
  Return
}

; GuiUpdate - Update Overlay ON OFF states
GuiUpdate(){
  GuiControl, 2:, overlayT1,% "Quit: " (WR.func.Toggle.Quit?"ON":"OFF")
  GuiControl, 2:, overlayT2,% "Flask: " (WR.func.Toggle.Flask?"ON":"OFF")
  GuiControl, 2:, overlayT3,% "Move: " (WR.func.Toggle.Move?"ON":"OFF")
  GuiControl, 2:, overlayT4,% "Util: " (WR.func.Toggle.Utility?"ON":"OFF")
  ShowHideOverlay()
  CtlColors.Change(MainMenuIDAutoFlask, (WR.func.Toggle.Flask?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoQuit, (WR.func.Toggle.Quit?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoMove, (WR.func.Toggle.Move?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoUtility, (WR.func.Toggle.Utility?"52D165":"E0E0E0"), "")
  Return
}

ShowHideOverlay(){
  Global overlayT1, overlayT2, overlayT3, overlayT4
  GuiControl,2: Show%YesInGameOverlay%, overlayT1
  GuiControl,2: Show%YesInGameOverlay%, overlayT2
  GuiControl,2: Show%YesInGameOverlay%, overlayT3
  GuiControl,2: Show%YesInGameOverlay%, overlayT4
  Return
}

mainmenuGameLogicState(refresh:=False){
  Static OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1
  , OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnMetamorph:=-1, OldOnDetonate:=-1, OldOnLocker:=-1
  Local NewOHB
  If (OnChar != OldOnChar) || refresh
  {
    OldOnChar := OnChar
    If OnChar
      CtlColors.Change(MainMenuIDOnChar, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnChar, "Red", "")
  }
  If ((NewOHB := (CheckOHB()?1:0)) != OldOHB) || refresh
  {
    OldOHB := NewOHB
    If NewOHB
      CtlColors.Change(MainMenuIDOnOHB, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnOHB, "Red", "")
  }
  If (OnInventory != OldOnInventory) || refresh
  {
    OldOnInventory := OnInventory
    If (OnInventory)
      CtlColors.Change(MainMenuIDOnInventory, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnInventory, "", "Green")
  }
  If (OnChat != OldOnChat) || refresh
  {
    OldOnChat := OnChat
    If OnChat
      CtlColors.Change(MainMenuIDOnChat, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnChat, "", "Green")
  }
  If (OnStash != OldOnStash) || refresh
  {
    OldOnStash := OnStash
    If (OnStash)
      CtlColors.Change(MainMenuIDOnStash, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnStash, "", "Green")
  }
  If (OnDiv != OldOnDiv) || refresh
  {
    OldOnDiv := OnDiv
    If (OnDiv)
      CtlColors.Change(MainMenuIDOnDiv, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDiv, "", "Green")
  }
  If (OnLeft != OldOnLeft) || refresh
  {
    OldOnLeft := OnLeft
    If (OnLeft)
      CtlColors.Change(MainMenuIDOnLeft, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnLeft, "", "Green")
  }
  If (OnDelveChart != OldOnDelveChart) || refresh
  {
    OldOnDelveChart := OnDelveChart
    If (OnDelveChart)
      CtlColors.Change(MainMenuIDOnDelveChart, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDelveChart, "", "Green")
  }
  If (OnVendor != OldOnVendor) || refresh
  {
    OldOnVendor := OnVendor
    If (OnVendor)
      CtlColors.Change(MainMenuIDOnVendor, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnVendor, "", "Green")
  }
  If (OnDetonate != OldOnDetonate) || refresh
  {
    OldOnDetonate := OnDetonate
    If (OnDetonate)
      CtlColors.Change(MainMenuIDOnDetonate, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDetonate, "", "Green")
  }
  If (OnMenu != OldOnMenu) || refresh
  {
    OldOnMenu := OnMenu
    If (OnMenu)
      CtlColors.Change(MainMenuIDOnMenu, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnMenu, "", "Green")
  }
  If (OnMetamorph != OldOnMetamorph) || refresh
  {
    OldOnMetamorph := OnMetamorph
    If (OnMetamorph)
      CtlColors.Change(MainMenuIDOnMetamorph, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnMetamorph, "", "Green")
  }
  If (OnLocker != OldOnLocker) || refresh
  {
    OldOnLocker := OnLocker
    If (OnLocker)
      CtlColors.Change(MainMenuIDOnLocker, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnLocker, "", "Green")
  }
  Return

  CheckPixelGrid:
    ;Check if inventory is open
    Gui, 1: Hide
    if(!OnInventory){
      TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
    }else{
      TT := "Grid information:" . "`n"
      FindText.ScreenShot()
      For C, GridX in InventoryGridX  
      {
        For R, GridY in InventoryGridY
        {
          PointColor := FindText.GetColor(GridX,GridY)
          if (indexOf(PointColor, varEmptyInvSlotColor)) {        
            TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Empty inventory slot. Color: " . PointColor  .  "`n"
          }else{
            TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Possibly occupied slot. Color: " . PointColor  .  "`n"
          }
        }
      }
    }
    MsgBox %TT%  
    MainMenu()
  Return
}


helpAutomation:
  Gui, submit
  MsgBox,% "Automation can start from two ways:`n`n"
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
    . "Search for Stash > Auto Stash Routine > END"
  MainMenu()
Return

WarningAutomation:
  Gui, submit, nohide
  If YesEnableAutoSellConfirmation
  {
    Gui, submit
    MsgBox,1,% "WARNING!!!", % "Please Be Advised`n`n"
    . "Enabling this option will auto confirm vendoring items, only use this option if you have a well configured CLF to catch good items`n`n"
    . "We will not be responsible for anything lost using this option.`n`n"
    . "If you are unsure about this option, We strongly recomend doing more research before enabling.`n`n"
    . "Come to WingmanReloaded Discord to talk with us or look for more information.`n`n"
    . "You have been warned!!! This option can be dangerous if done incorrectly!!!`n"
    . "Press OK to accept"
    IfMsgBox, OK
    {
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
      MainMenu()
    }
    Else IfMsgBox, Cancel
    {
      YesEnableAutoSellConfirmation := 0
      MainMenu()
      GuiControl,Inventory:, YesEnableAutoSellConfirmation, 0
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
    }
    Else
    {
      YesEnableAutoSellConfirmation := 0
      MainMenu()
      GuiControl,Inventory:, YesEnableAutoSellConfirmation, 0
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
    }
  }
  Else 
    IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
Return

MouseTip(x:="", y:="", w:=21, h:=21)
{
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  If IsObject(x){
    w := Abs(x.X2-x.X1)
    h := Abs(x.Y2-x.Y1)
    y := (x.Y1<x.Y2?x.Y1:x.Y2)
    x := (x.X1<x.X2?x.X1:x.X2)
  }
  ; x:=Round(x-10), y:=Round(y-10)
  ;-------------------------
  Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
  Gui, _MouseTip_: Show, Hide w%w% h%h%
  ;-------------------------
  dhw:=A_DetectHiddenWindows
  DetectHiddenWindows, On
  d:=1, i:=w-d, j:=h-d
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
  s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%, ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  Gui, _MouseTip_: Show, NA x%x% y%y%
  Loop, 4
  {
    Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
    Sleep, 500
  }
  Gui, _MouseTip_: Destroy
}

