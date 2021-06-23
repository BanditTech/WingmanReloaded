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
	IniWrite, %YesVendor%, %A_ScriptDir%\save\Settings.ini, General, YesVendor
	IniWrite, %YesStash%, %A_ScriptDir%\save\Settings.ini, General, YesStash
	IniWrite, %YesHeistLocker%, %A_ScriptDir%\save\Settings.ini, General, YesHeistLocker
	IniWrite, %YesPredictivePrice%, %A_ScriptDir%\save\Settings.ini, General, YesPredictivePrice
	IniWrite, %YesSkipMaps%, %A_ScriptDir%\save\Settings.ini, General, YesSkipMaps
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
	IniWrite, %YesEnableLockerAutomation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableLockerAutomation
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
	If (DebugMessages)
	{
		GuiControl, Show, YesTimeMS
		GuiControl, Show, YesTimeMS_t
		GuiControl, Show, YesLocation
		GuiControl, Show, YesLocation_t
	}
	Else
	{
		GuiControl, Hide, YesTimeMS
		GuiControl, Hide, YesTimeMS_t
		GuiControl, Hide, YesLocation
		GuiControl, Hide, YesLocation_t
	}
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
	hotkeys()
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
		Hotkeys()
	}
Return
