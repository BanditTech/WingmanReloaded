perCharMenu(){
	Global
	static Built := False

	If !Built
	{
		Built := True
		Gui, perChar: new, AlwaysOnTop

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox, xm ym w565 h405, Per Character Settings
		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,         Section    w265 h40        xp+10   yp+20,         Character Type:
		Gui, perChar: Font,
		Gui, perChar: Font, cRed
		Gui, perChar: Add, Radio, %   "Group vtypeLife Checked" WR.perChar.Setting.typeLife     " xs+10 ys+20", Life
		Gui, perChar: Font, cPurple
		Gui, perChar: Add, Radio, %       "vtypeHybrid Checked" WR.perChar.Setting.typeHybrid   " x+10 yp",     Hybrid
		Gui, perChar: Font, cBlue
		Gui, perChar: Add, Radio, %           "vtypeES Checked" WR.perChar.Setting.typeES       " x+10 yp",     ES
		Gui, perChar: Add, Checkbox, %  "vtypeEldritch Checked" WR.perChar.Setting.typeEldritch " x+8 yp" ,     Eldritch Battery
		Gui, perChar: Font
		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h66        xs   y+10 ,         Auto-Quit Settings
		Gui, perChar: Font,
		Gui, perChar: Add, Text,                     xs+10   yp+22,         Quit via:
		Gui, perChar: Add, Radio, % "Group vquitDC        Checked" WR.perChar.Setting.quitDC     " x+8 y+-13",   Disconnect
		Gui, perChar: Add, Radio,     %   "vquitPortal    Checked" WR.perChar.Setting.quitPortal " x+8 yp"   ,   Portal
		Gui, perChar: Add, Radio,     %   "vquitExit      Checked" WR.perChar.Setting.quitExit   " x+8 yp"   ,   /exit
		Gui, perChar: Add, Slider, NoTicks vquitBelow Thick20 TickInterval10 ToolTip h21 w160 xs+5 y+3       , % WR.perChar.Setting.quitBelow
		Gui, perChar: Add, Checkbox,  %   "vquitLogBackIn Checked" WR.perChar.Setting.quitLogBackIn  " x+5 yp+7" ,   Log back in

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h85        xs   y+10 ,         Movement Settings
		Gui, perChar: Font,
		Gui, perChar: Add, Text,                     xs+10   ys+20,         Movement Trigger Delay (in seconds):
		Gui, perChar: Add, Edit,       vmovementDelay  x+10 Center  yp   w55 h17, % WR.perChar.Setting.movementDelay
		Gui, perChar: Font, s8 cBlack
		Gui, perChar: Add,GroupBox, xs+10 y+1 w245 h40    center                  , Movement Triggers with Attack Keys
		Gui, perChar: Font,
		Gui, perChar: Add, Checkbox, % "vmovementMainAttack +BackgroundTrans Checked" WR.perChar.Setting.movementMainAttack " xp+25 yp+20 ", Main Attack
		Gui, perChar: Add, Checkbox, % "vmovementSecondaryAttack +BackgroundTrans Checked" WR.perChar.Setting.movementSecondaryAttack " xp+98 yp", Secondary Attack

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h40        xs   y+15 ,         Auto Level Gems
		Gui, perChar: Font,
		Gui, perChar: Add, Checkbox, % "vautolevelgemsEnable Checked" WR.perChar.Setting.autolevelgemsEnable "   xs+35 yp+18"     , Enable
		Gui, perChar: Add, Checkbox, % "vautolevelgemsWait Checked" WR.perChar.Setting.autolevelgemsWait "    xp+98 yp "  , Wait for Mouse

		; , "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
		; , "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h65        xs   y+10 ,         First Swap Gem/Item
		Gui, perChar: Font,
		Gui, perChar: Add, Edit,  center     vswap1Xa         xs+5  yp+20     w34  h17, % WR.perChar.Setting.swap1Xa
		Gui, perChar: Add, Edit,  center     vswap1Ya           x+3                w34  h17, % WR.perChar.Setting.swap1Ya
		Gui, perChar: Add, Button,  gWR_Update vWR_Btn_Locate2_swap1a  x+3   yp  hp , Locate A
		Gui, perChar: Add, Checkbox, % "vswap1Item Checked" WR.perChar.Setting.swap1Item " x+3  yp+2"               , Use as Item Swap?
		Gui, perChar: Add, Edit,   center    vswap1Xb         xs+5        y+5   w34  h17,   % WR.perChar.Setting.swap1Xb
		Gui, perChar: Add, Edit,   center    vswap1Yb         x+3                w34  h17,   % WR.perChar.Setting.swap1Yb
		Gui, perChar: Add, Button,      gWR_Update vWR_Btn_Locate2_swap1b  x+3   yp    hp , Locate B
		Gui, perChar: Add, Checkbox, %  "vswap1AltWeapon Checked" WR.perChar.Setting.swap1AltWeapon "  x+3  yp+2"  , Swap Weapon for B?

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h65        xs   y+10 ,         Second Swap Gem/Item
		Gui, perChar: Font,
		Gui, perChar: Add, Edit,   center vswap2Xa xs+5 yp+20   w34  h17,   % WR.perChar.Setting.swap2Xa
		Gui, perChar: Add, Edit,   center vswap2Ya x+3 w34  hp,   % WR.perChar.Setting.swap2Ya
		Gui, perChar: Add, Button, gWR_Update vWR_Btn_Locate2_swap2a      x+3   yp    hp , Locate A
		Gui, perChar: Add, Checkbox, % "vswap2Item Checked" WR.perChar.Setting.swap2Item " x+3  yp+2" , Use as Item Swap?
		Gui, perChar: Add, Edit, center vswap2Xb xs+5 y+5   w34  h17,   % WR.perChar.Setting.swap2Xb
		Gui, perChar: Add, Edit, center vswap2Yb x+3 w34  hp,   % WR.perChar.Setting.swap2Yb
		Gui, perChar: Add, Button,      gWR_Update vWR_Btn_Locate2_swap2b      x+3   yp    hp , Locate B
		Gui, perChar: Add, Checkbox, %  "vswap2AltWeapon Checked" WR.perChar.Setting.swap2AltWeapon "  x+3  yp+2"  , Swap Weapon for B?


		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,  xs+280 ym+20 w265 h150 Section, Channeling Stack Re-Press
		Gui, perChar: Font,
		Gui, perChar: Add, CheckBox, % "vchannelrepressEnable Checked" WR.perChar.Setting.channelrepressEnable "  Right x+-65 ys+2 ", Enable
		Gui, perChar: Add, Edit,  vchannelrepressIcon xs+5 ys+19 w150 h21, % WR.perChar.Setting.channelrepressIcon
		Gui, perChar: Add, Text, x+4 yp+3, Icon to Find
		Gui, perChar: Add, Edit,  vchannelrepressStack xs+5 y+15 w150 h21, % WR.perChar.Setting.channelrepressStack
		Gui, perChar: Add, Text, x+4 yp+3, Stack Digit
		Gui, perChar: Add, Edit,  vchannelrepressKey xs+5 y+15 w150 h21, % WR.perChar.Setting.channelrepressKey
		Gui, perChar: Add, Text, x+4 yp+3, Key to Re-Press
		Gui, perChar: Add, Text, xs+15 y+12, Stack Search Offset - Bottom Edge of Buff Icon
		Gui, perChar: Font, Bold s9 cBlack
		Gui, perChar: Add, Text, xs+15 y+5, X1:
		Gui, perChar: Font,
		Gui, perChar: Add, Text, x+2 yp w29 hp,
		Gui, perChar: Add, UpDown,  vchannelrepressOffsetX1 hp center Range-150-150, % WR.perChar.Setting.channelrepressOffsetX1
		Gui, perChar: Font, Bold s9 cBlack
		Gui, perChar: Add, Text, x+10 yp, Y1:
		Gui, perChar: Font,
		Gui, perChar: Add, Text, x+2 yp w29 hp,
		Gui, perChar: Add, UpDown,  vchannelrepressOffsetY1 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetY1
		Gui, perChar: Font, Bold s9 cBlack
		Gui, perChar: Add, Text, x+10 yp, X2:
		Gui, perChar: Font,
		Gui, perChar: Add, Text, x+2 yp w29 hp,
		Gui, perChar: Add, UpDown,  vchannelrepressOffsetX2 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetX2
		Gui, perChar: Font, Bold s9 cBlack
		Gui, perChar: Add, Text, x+10 yp, Y2:
		Gui, perChar: Font,
		Gui, perChar: Add, Text, x+2 yp w29 hp,
		Gui, perChar: Add, UpDown,  vchannelrepressOffsetY2 hp center Range-150-150, %  WR.perChar.Setting.channelrepressOffsetY2

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h132        xs   y+13 ,         Auto-Detonate Mines
		Gui, perChar: Font,
		Gui, perChar: Add, Checkbox, % "vautominesEnable Checked"  WR.perChar.Setting.autominesEnable  " xs+15  ys+23"       , Enable
		Gui, perChar: Add, Edit,        vautominesBoomDelay  h18  xs+90  yp-2  Number Limit w30        , % WR.perChar.Setting.autominesBoomDelay
		Gui, perChar: Add, Text, x+5 yp+2, Delay between Detonate
		Gui, perChar: Font, s8 cBlack
		Gui, perChar: Add, GroupBox, center  xs+5 y+7 w255 h40, Pause Mines Hotkey
		Gui, perChar: Font,
		Gui, perChar: Add, Radio,     %   "vautominesPauseSingleTap  h18  xp+10 yp+16  Checked" (WR.perChar.Setting.autominesPauseSingleTap == 1?"1":0)   , Single-Tap
		Gui, perChar: Add, Radio,     %   "h18  x+1 yp  Checked" (WR.perChar.Setting.autominesPauseSingleTap == 2?"1":0)   , Double-Tap
		Gui, perChar: Add, Text, x+5  yp+2 , Speed
		Gui, perChar: Add, Edit,        vautominesPauseDoubleTapSpeed  h18  x+5 yp-2  Number Limit w30        , % WR.perChar.Setting.autominesPauseDoubleTapSpeed 
		Gui, perChar: Font, s8 cBlack
		Gui, perChar: Add, GroupBox, center xs+5 y+10 w255 h37, Dash on Detonate
		Gui, perChar: Font,
		Gui, perChar: Add, CheckBox, %  "xp+15 yp+16 vautominesSmokeDashEnable Checked" WR.perChar.Setting.autominesSmokeDashEnable, Enable Smoke-Dash
		Gui, perChar: Add, Text, xs+150 yp , Key
		Gui, perChar: Add, Edit,        vautominesSmokeDashKey  h18  x+5  yp-2  w50        , % WR.perChar.Setting.autominesSmokeDashKey
		Gui, perChar: Font,

		Gui, perChar: Font, Bold s9 cBlack, Arial
		Gui, perChar: Add, GroupBox,     Section  w265 h65        xs yp+35,         Load Flask or Utility Profiles
		Gui, perChar: Font,
		Gui, perChar: Add, CheckBox, %  "xs+5 ys+20 vprofilesYesFlask Checked" WR.perChar.Setting.profilesYesFlask, Load Flask Profile
		l := [], s := ""
		Loop, Files, %A_ScriptDir%\save\profiles\Flask\*.json
			l.Push(StrReplace(A_LoopFileName,".json",""))
		For k, v in l
			s .=(k=1?"":"|") v
		Gui, perChar: Add, DropDownList, % "vprofilesFlask xp y+5 w120", %s%
		GuiControl, perChar: ChooseString, profilesFlask, % WR.perChar.Setting.profilesFlask

		Gui, perChar: Add, CheckBox, %  "xs+132 ys+20 vprofilesYesUtility Checked" WR.perChar.Setting.profilesYesUtility, Load Utility Profile
		l := [], s := ""
		Loop, Files, %A_ScriptDir%\save\profiles\Utility\*.json
			l.Push(StrReplace(A_LoopFileName,".json",""))
		For k, v in l
			s .=(k=1?"":"|") v
		Gui, perChar: Add, DropDownList, % "vprofilesUtility xp y+5 w120", %s%
		GuiControl, perChar: ChooseString, profilesUtility, % WR.perChar.Setting.profilesUtility
		;  xm ym w565 h405
		Gui, perChar: show, AutoSize
	}
	Return

	perCharSaveValues:
		for k, kind in ["typeLife", "typeHybrid", "typeES", "typeEldritch"
		, "quitDC", "quitPortal", "quitExit", "quitBelow", "quitLogBackIn"
		, "movementDelay", "movementMainAttack", "movementSecondaryAttack"
		, "channelrepressEnable", "channelrepressIcon", "channelrepressStack", "channelrepressKey", "channelrepressOffsetX1", "channelrepressOffsetY1", "channelrepressOffsetX2", "channelrepressOffsetY2"
		, "autominesEnable", "autominesBoomDelay", "autominesPauseDoubleTapSpeed", "autominesPauseSingleTap", "autominesSmokeDashEnable", "autominesSmokeDashKey"
		, "autolevelgemsEnable", "autolevelgemsWait"
		, "swap1AltWeapon", "swap1Item", "swap1Xa", "swap1Ya", "swap1Xb", "swap1Yb"
		, "swap2AltWeapon", "swap2Item", "swap2Xa", "swap2Ya", "swap2Xb", "swap2Yb"
		, "profilesYesFlask", "profilesFlask", "profilesYesUtility", "profilesUtility"]
			WR.perChar.Setting[kind] := %kind%
		Settings("perChar","Save")
		Return
	perCharGuiClose:
	perCharGuiEscape:
		Built := False
		Gui, Submit, NoHide
		Gosub, perCharSaveValues
		Gui, perChar: Destroy
		Return
}
