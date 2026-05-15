perCharMenu(*){
	static Built := False
	static perCharGui := 0

	If !Built
	{
		Built := True
		perCharGui := Gui("AlwaysOnTop")
		perCharGui.OnEvent("Close", perCharGuiClose)
		perCharGui.OnEvent("Escape", perCharGuiEscape)

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox", "xm ym w565 h405", "Per Character Settings")
		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",         "Section    w265 h40        xp+10   yp+20",         "Character Type:")
		perCharGui.SetFont()
		perCharGui.SetFont("cRed")
		perCharGui.Add("Radio", "Group vtypeLife Checked" WR.perChar.Setting.typeLife     " xs+10 ys+20", "Life")
		perCharGui.SetFont("cPurple")
		perCharGui.Add("Radio",       "vtypeHybrid Checked" WR.perChar.Setting.typeHybrid   " x+10 yp",     "Hybrid")
		perCharGui.SetFont("cBlue")
		perCharGui.Add("Radio",           "vtypeES Checked" WR.perChar.Setting.typeES       " x+10 yp",     "ES")
		perCharGui.Add("Checkbox", "vtypeEldritch Checked" WR.perChar.Setting.typeEldritch " x+8 yp" ,     "Eldritch Battery")
		perCharGui.SetFont()
		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h66        xs   y+10 ",         "Auto-Quit Settings")
		perCharGui.SetFont()
		perCharGui.Add("Text",                     "xs+10   yp+22",         "Quit via:")
		perCharGui.Add("Radio", "Group vquitDC        Checked" WR.perChar.Setting.quitDC     " x+8 y+-13",   "Disconnect")
		perCharGui.Add("Radio",     "vquitPortal    Checked" WR.perChar.Setting.quitPortal " x+8 yp"   ,   "Portal")
		perCharGui.Add("Radio",     "vquitExit      Checked" WR.perChar.Setting.quitExit   " x+8 yp"   ,   "/exit")
		perCharGui.Add("Slider", "NoTicks vquitBelow Thick20 TickInterval10 ToolTip h21 w160 xs+5 y+3"       , WR.perChar.Setting.quitBelow)
		perCharGui.Add("Checkbox",  "vquitLogBackIn Checked" WR.perChar.Setting.quitLogBackIn  " x+5 yp+7" ,   "Log back in")

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h85        xs   y+10 ",         "Movement Settings")
		perCharGui.SetFont()
		perCharGui.Add("Text",                     "xs+10   ys+20",         "Movement Trigger Delay (in seconds):")
		perCharGui.Add("Edit",       "vmovementDelay  x+10 Center  yp   w55 h17", WR.perChar.Setting.movementDelay)
		perCharGui.SetFont("s8 cBlack")
		perCharGui.Add("GroupBox", "xs+10 y+1 w245 h40    center"                  , "Movement Triggers with Attack Keys")
		perCharGui.SetFont()
		perCharGui.Add("Checkbox", "vmovementMainAttack Checked" WR.perChar.Setting.movementMainAttack " xp+25 yp+20 ", "Main Attack")
		perCharGui.Add("Checkbox", "vmovementSecondaryAttack Checked" WR.perChar.Setting.movementSecondaryAttack " xp+98 yp", "Secondary Attack")

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h40        xs   y+15 ",         "Auto Level Gems")
		perCharGui.SetFont()
		perCharGui.Add("Checkbox", "vautolevelgemsEnable Checked" WR.perChar.Setting.autolevelgemsEnable "   xs+35 yp+18"     , "Enable")
		perCharGui.Add("Checkbox", "vautolevelgemsWait Checked" WR.perChar.Setting.autolevelgemsWait "    xp+98 yp "  , "Wait for Mouse")

		; , "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
		; , "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h65        xs   y+10 ",         "First Swap Gem/Item")
		perCharGui.SetFont()
		perCharGui.Add("Edit",  "center     vswap1Xa         xs+5  yp+20     w34  h17", WR.perChar.Setting.swap1Xa)
		perCharGui.Add("Edit",  "center     vswap1Ya           x+3                w34  h17", WR.perChar.Setting.swap1Ya)
		btn := perCharGui.Add("Button",  "vWR_Btn_Locate2_swap1a  x+3   yp  hp ", "Locate A")
		btn.OnEvent("Click", WR_Update)
		perCharGui.Add("Checkbox", "vswap1Item Checked" WR.perChar.Setting.swap1Item " x+3  yp+2"               , "Use as Item Swap?")
		perCharGui.Add("Edit",   "center    vswap1Xb         xs+5        y+5   w34  h17",   WR.perChar.Setting.swap1Xb)
		perCharGui.Add("Edit",   "center    vswap1Yb         x+3                w34  h17",   WR.perChar.Setting.swap1Yb)
		btn := perCharGui.Add("Button",      "vWR_Btn_Locate2_swap1b  x+3   yp    hp ", "Locate B")
		btn.OnEvent("Click", WR_Update)
		perCharGui.Add("Checkbox",  "vswap1AltWeapon Checked" WR.perChar.Setting.swap1AltWeapon "  x+3  yp+2"  , "Swap Weapon for B?")

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h65        xs   y+10 ",         "Second Swap Gem/Item")
		perCharGui.SetFont()
		perCharGui.Add("Edit",   "center vswap2Xa xs+5 yp+20   w34  h17",   WR.perChar.Setting.swap2Xa)
		perCharGui.Add("Edit",   "center vswap2Ya x+3 w34  hp",   WR.perChar.Setting.swap2Ya)
		btn := perCharGui.Add("Button", "vWR_Btn_Locate2_swap2a      x+3   yp    hp ", "Locate A")
		btn.OnEvent("Click", WR_Update)
		perCharGui.Add("Checkbox", "vswap2Item Checked" WR.perChar.Setting.swap2Item " x+3  yp+2" , "Use as Item Swap?")
		perCharGui.Add("Edit", "center vswap2Xb xs+5 y+5   w34  h17",   WR.perChar.Setting.swap2Xb)
		perCharGui.Add("Edit", "center vswap2Yb x+3 w34  hp",   WR.perChar.Setting.swap2Yb)
		btn := perCharGui.Add("Button",      "vWR_Btn_Locate2_swap2b      x+3   yp    hp ", "Locate B")
		btn.OnEvent("Click", WR_Update)
		perCharGui.Add("Checkbox",  "vswap2AltWeapon Checked" WR.perChar.Setting.swap2AltWeapon "  x+3  yp+2"  , "Swap Weapon for B?")


		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",  "xs+280 ym+20 w265 h150 Section", "Channeling Stack Re-Press")
		perCharGui.SetFont()
		perCharGui.Add("CheckBox", "vchannelrepressEnable Checked" WR.perChar.Setting.channelrepressEnable "  Right x+-65 ys+2 ", "Enable")
		perCharGui.Add("Edit",  "vchannelrepressIcon xs+5 ys+19 w150 h21", WR.perChar.Setting.channelrepressIcon)
		perCharGui.Add("Text", "x+4 yp+3", "Icon to Find")
		perCharGui.Add("Edit",  "vchannelrepressStack xs+5 y+15 w150 h21", WR.perChar.Setting.channelrepressStack)
		perCharGui.Add("Text", "x+4 yp+3", "Stack Digit")
		perCharGui.Add("Edit",  "vchannelrepressKey xs+5 y+15 w150 h21", WR.perChar.Setting.channelrepressKey)
		perCharGui.Add("Text", "x+4 yp+3", "Key to Re-Press")
		perCharGui.Add("Text", "xs+15 y+12", "Stack Search Offset - Bottom Edge of Buff Icon")
		perCharGui.SetFont("Bold s9 cBlack")
		perCharGui.Add("Text", "xs+15 y+5", "X1:")
		perCharGui.SetFont()
		perCharGui.Add("Text", "x+2 yp w29 hp")
		perCharGui.Add("UpDown",  "vchannelrepressOffsetX1 hp center Range-150-150", WR.perChar.Setting.channelrepressOffsetX1)
		perCharGui.SetFont("Bold s9 cBlack")
		perCharGui.Add("Text", "x+10 yp", "Y1:")
		perCharGui.SetFont()
		perCharGui.Add("Text", "x+2 yp w29 hp")
		perCharGui.Add("UpDown",  "vchannelrepressOffsetY1 hp center Range-150-150", WR.perChar.Setting.channelrepressOffsetY1)
		perCharGui.SetFont("Bold s9 cBlack")
		perCharGui.Add("Text", "x+10 yp", "X2:")
		perCharGui.SetFont()
		perCharGui.Add("Text", "x+2 yp w29 hp")
		perCharGui.Add("UpDown",  "vchannelrepressOffsetX2 hp center Range-150-150", WR.perChar.Setting.channelrepressOffsetX2)
		perCharGui.SetFont("Bold s9 cBlack")
		perCharGui.Add("Text", "x+10 yp", "Y2:")
		perCharGui.SetFont()
		perCharGui.Add("Text", "x+2 yp w29 hp")
		perCharGui.Add("UpDown",  "vchannelrepressOffsetY2 hp center Range-150-150", WR.perChar.Setting.channelrepressOffsetY2)

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h132        xs   y+13 ",         "Auto-Detonate Mines")
		perCharGui.SetFont()
		perCharGui.Add("Checkbox", "vautominesEnable Checked"  WR.perChar.Setting.autominesEnable  " xs+15  ys+23"       , "Enable")
		perCharGui.Add("Edit",        "vautominesBoomDelay  h18  xs+90  yp-2  Number Limit w30"        , WR.perChar.Setting.autominesBoomDelay)
		perCharGui.Add("Text", "x+5 yp+2", "Delay between Detonate")
		perCharGui.SetFont("s8 cBlack")
		perCharGui.Add("GroupBox", "center  xs+5 y+7 w255 h40", "Pause Mines Hotkey")
		perCharGui.SetFont()
		perCharGui.Add("Radio",     "vautominesPauseSingleTap  h18  xp+10 yp+16  Checked" (WR.perChar.Setting.autominesPauseSingleTap == 1?"1":0)   , "Single-Tap")
		perCharGui.Add("Radio",     "h18  x+1 yp  Checked" (WR.perChar.Setting.autominesPauseSingleTap == 2?"1":0)   , "Double-Tap")
		perCharGui.Add("Text", "x+5  yp+2 " , "Speed")
		perCharGui.Add("Edit",        "vautominesPauseDoubleTapSpeed  h18  x+5 yp-2  Number Limit w30"        , WR.perChar.Setting.autominesPauseDoubleTapSpeed)
		perCharGui.SetFont("s8 cBlack")
		perCharGui.Add("GroupBox", "center xs+5 y+10 w255 h37", "Dash on Detonate")
		perCharGui.SetFont()
		perCharGui.Add("CheckBox",  "xp+15 yp+16 vautominesSmokeDashEnable Checked" WR.perChar.Setting.autominesSmokeDashEnable, "Enable Smoke-Dash")
		perCharGui.Add("Text", "xs+150 yp " , "Key")
		perCharGui.Add("Edit",        "vautominesSmokeDashKey  h18  x+5  yp-2  w50"        , WR.perChar.Setting.autominesSmokeDashKey)
		perCharGui.SetFont()

		perCharGui.SetFont("Bold s9 cBlack", "Arial")
		perCharGui.Add("GroupBox",     "Section  w265 h65        xs yp+35",         "Load Flask or Utility Profiles")
		perCharGui.SetFont()
		perCharGui.Add("CheckBox",  "xs+5 ys+20 vprofilesYesFlask Checked" WR.perChar.Setting.profilesYesFlask, "Load Flask Profile")
		l := [], s := ""
		Loop Files A_ScriptDir "\save\profiles\Flask\*.json"
			l.Push(StrReplace(A_LoopFileName,".json",""))
		For k, v in l
			s .=(k=1?"":"|") v
		perCharGui.Add("DropDownList", "vprofilesFlask xp y+5 w120", s)
		perCharGui["profilesFlask"].Choose(WR.perChar.Setting.profilesFlask)

		perCharGui.Add("CheckBox",  "xs+132 ys+20 vprofilesYesUtility Checked" WR.perChar.Setting.profilesYesUtility, "Load Utility Profile")
		l := [], s := ""
		Loop Files A_ScriptDir "\save\profiles\Utility\*.json"
			l.Push(StrReplace(A_LoopFileName,".json",""))
		For k, v in l
			s .=(k=1?"":"|") v
		perCharGui.Add("DropDownList", "vprofilesUtility xp y+5 w120", s)
		perCharGui["profilesUtility"].Choose(WR.perChar.Setting.profilesUtility)
		;  xm ym w565 h405
		perCharGui.Show("AutoSize")
	}
	Return

	perCharSaveValues() {
		for k, kind in ["typeLife", "typeHybrid", "typeES", "typeEldritch"
		, "quitDC", "quitPortal", "quitExit", "quitBelow", "quitLogBackIn"
		, "movementDelay", "movementMainAttack", "movementSecondaryAttack"
		, "channelrepressEnable", "channelrepressIcon", "channelrepressStack", "channelrepressKey", "channelrepressOffsetX1", "channelrepressOffsetY1", "channelrepressOffsetX2", "channelrepressOffsetY2"
		, "autominesEnable", "autominesBoomDelay", "autominesPauseDoubleTapSpeed", "autominesPauseSingleTap", "autominesSmokeDashEnable", "autominesSmokeDashKey"
		, "autolevelgemsEnable", "autolevelgemsWait"
		, "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
		, "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"
		, "profilesYesFlask", "profilesFlask", "profilesYesUtility", "profilesUtility"]
			WR.perChar.Setting.%kind% := perCharGui[kind].Value
		Settings("perChar","Save")
	}
	perCharGuiClose(GuiObj) {
		Built := False
		perCharGui.Submit(0)
		perCharSaveValues()
		perCharGui.Destroy()
	}
	perCharGuiEscape(GuiObj) {
		Built := False
		perCharGui.Submit(0)
		perCharSaveValues()
		perCharGui.Destroy()
	}
}
