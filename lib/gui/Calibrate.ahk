updateOnChar:
	Critical
	Gui, Submit ; , NoHide
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of Character Active didn't work"
		Return
	}
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnChar := FindText.GetColor(WR.loc.pixel.OnChar.X,WR.loc.pixel.OnChar.Y)
		IniWrite, %varOnChar%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar
		readFromFile()
		MsgBox % "Character Active recalibrated!`nTook color hex: " . varOnChar . " `nAt coords x: " . WR.loc.pixel.OnChar.X . " and y: " . WR.loc.pixel.OnChar.Y
	} else
	MsgBox % "PoE Window is not active. `nRecalibrate of Character Active didn't work"
	
	MainMenu()
	
return

updateOnInventory:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnInventory didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnInventory := FindText.GetColor(WR.loc.pixel.OnInventory.X,WR.loc.pixel.OnInventory.Y)
		IniWrite, %varOnInventory%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory
		readFromFile()
		MsgBox % "OnInventory recalibrated!`nTook color hex: " . varOnInventory . " `nAt coords x: " . WR.loc.pixel.OnInventory.X . " and y: " . WR.loc.pixel.OnInventory.Y
		GoSub, updateEmptyColor
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnInventory didn't work"
	
	MainMenu()
	
return

updateOnMenu:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnMenu didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnMenu := FindText.GetColor(WR.loc.pixel.OnMenu.X,WR.loc.pixel.OnMenu.Y)
		IniWrite, %varOnMenu%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu
		readFromFile()
		MsgBox % "OnMenu recalibrated!`nTook color hex: " . varOnMenu . " `nAt coords x: " . WR.loc.pixel.OnMenu.X . " and y: " . WR.loc.pixel.OnMenu.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnMenu didn't work"
	
	MainMenu()
	
return

updateOnDelveChart:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnDelveChart didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnDelveChart := FindText.GetColor(WR.loc.pixel.OnDelveChart.X,WR.loc.pixel.OnDelveChart.Y)
		IniWrite, %varOnDelveChart%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart
		readFromFile()
		MsgBox % "OnDelveChart recalibrated!`nTook color hex: " . varOnDelveChart . " `nAt coords x: " . WR.loc.pixel.OnDelveChart.X . " and y: " . WR.loc.pixel.OnDelveChart.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnDelveChart didn't work"
	
	MainMenu()
	
return

updateOnMetamorph:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnMetamorph didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnMetamorph := FindText.GetColor(WR.loc.pixel.OnMetamorph.X,WR.loc.pixel.OnMetamorph.Y)
		IniWrite, %varOnMetamorph%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMetamorph
		readFromFile()
		MsgBox % "OnMetamorph recalibrated!`nTook color hex: " . varOnMetamorph . " `nAt coords x: " . WR.loc.pixel.OnMetamorph.X . " and y: " . WR.loc.pixel.OnMetamorph.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnMetamorph didn't work"
	
	MainMenu()
	
return

updateOnLocker:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnLocker didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnLocker := FindText.GetColor(WR.loc.pixel.OnLocker.X,WR.loc.pixel.OnLocker.Y)
		IniWrite, %varOnLocker%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLocker
		readFromFile()
		MsgBox % "OnLocker recalibrated!`nTook color hex: " . varOnLocker . " `nAt coords x: " . WR.loc.pixel.OnLocker.X . " and y: " . WR.loc.pixel.OnLocker.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnLocker didn't work"
	
	MainMenu()
	
return

updateOnStash:
	Critical
	Gui, Submit ; , NoHide
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnStash/OnLeft didn't work"
		Return
	}
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnLeft := FindText.GetColor(WR.loc.pixel.OnLeft.X,WR.loc.pixel.OnLeft.Y)
		IniWrite, %varOnLeft%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft
		varOnStash := FindText.GetColor(WR.loc.pixel.OnStash.X,WR.loc.pixel.OnStash.Y)
		IniWrite, %varOnStash%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash
		readFromFile()
		MsgBox % "OnStash recalibrated!`nTook color hex: " . varOnStash . " `nAt coords x: " . WR.loc.pixel.OnStash.X . " and y: " . WR.loc.pixel.OnStash.Y
			. "`n`nOnLeft recalibrated!`nTook color hex: " . varOnLeft . " `nAt coords x: " . WR.loc.pixel.OnLeft.X . " and y: " . WR.loc.pixel.OnLeft.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnStash/OnLeft didn't work"
	
	MainMenu()
	
return

updateEmptyColor:
	Critical
	Gui, Submit ; , NoHide

	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nEmpty Slot calibration didn't work"
		Return
	}

	if WinActive(ahk_group POEGameGroup){
		;Now we need to get the user input for every grid element if its empty or not

		;First inform the user about the procedure
		infoMsg := "Following we loop through the whole inventory, recording all colors and save it as Empty Slot colors.`r`n`r`n"
		infoMsg .= "  -> Clear all items from inventory`r`n"
		infoMsg .= "  -> Make sure your inventory is open`r`n`r`n"
		infoMsg .= "Do you meet the above state requirements? If not please cancel this function."

		MsgBox, 1,, %infoMsg%
		IfMsgBox, Cancel
		{
			MsgBox Canceled the Id / Empty Slot calibration
			return
		}

		varEmptyInvSlotColor := []
		WinActivate, ahk_group POEGameGroup

		FindText.ScreenShot()
		;Loop through the whole grid, and add unknown colors to the lists
		For c, GridX in InventoryGridX  {
			For r, GridY in InventoryGridY
			{
				PointColor := FindText.GetColor(GridX,GridY)

				if !(indexOf(PointColor, varEmptyInvSlotColor)){
					;We dont have this Empty color already
					varEmptyInvSlotColor.Push(PointColor)
				}
			}
		}

		strToSave := hexArrToStr(varEmptyInvSlotColor)

		IniWrite, %strToSave%, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor
		readFromFile()


		infoMsg := "Empty Slot colors calibrated and saved with following color codes:`r`n`r`n"
		infoMsg .= strToSave

		MsgBox, %infoMsg%


	}else{
		MsgBox % "PoE Window is not active. `nRecalibrate Empty Slot Color didn't work"
	}

	MainMenu()
	Thread, NoTimers, False    ;End Critical
return

updateOnChat:
	Critical
	Gui, Submit ; , NoHide
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnChat didn't work"
		Return
	}
	
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnChat := FindText.GetColor(WR.loc.pixel.OnChat.X,WR.loc.pixel.OnChat.Y)
		IniWrite, %varOnChat%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat
		readFromFile()
		MsgBox % "OnChat recalibrated!`nTook color hex: " . varOnChat . " `nAt coords x: " . WR.loc.pixel.OnChat.X . " and y: " . WR.loc.pixel.OnChat.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of onChat didn't work"
	
	MainMenu()
	
return

updateOnVendor:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnVendor didn't work"
		Return
	}
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		If (CurrentLocation = "The Rogue Harbour") {
			varOnVendorHeist := FindText.GetColor(WR.loc.pixel.OnVendorHeist.X,WR.loc.pixel.OnVendorHeist.Y)
			IniWrite, %varOnVendorHeist%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendorHeist
			readFromFile()
			MsgBox % "OnVendorHeist recalibrated!`nTook color hex: " . varOnVendorHeist . " `nAt coords x: " . WR.loc.pixel.OnVendorHeist.X . " and y: " . WR.loc.pixel.OnVendorHeist.Y
		} Else {
			varOnVendor := FindText.GetColor(WR.loc.pixel.OnVendorHeist.X,WR.loc.pixel.OnVendorHeist.Y)
			IniWrite, %varOnVendor%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor
			readFromFile()
			MsgBox % "OnVendor recalibrated!`nTook color hex: " . varOnVendor . " `nAt coords x: " . WR.loc.pixel.OnVendorHeist.X . " and y: " . WR.loc.pixel.OnVendorHeist.Y
		}
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnVendor didn't work"
	
	MainMenu()
	
return

updateOnDiv:
	Critical
	Gui, Submit ; , NoHide
	
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnDiv didn't work"
		Return
	}
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		varOnDiv := FindText.GetColor(WR.loc.pixel.OnDiv.X,WR.loc.pixel.OnDiv.Y)
		IniWrite, %varOnDiv%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv
		readFromFile()
		MsgBox % "OnDiv recalibrated!`nTook color hex: " . varOnDiv . " `nAt coords x: " . WR.loc.pixel.OnDiv.X . " and y: " . WR.loc.pixel.OnDiv.Y
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnDiv didn't work"
	
	MainMenu()
	
return

updateDetonate:
	Critical
	Gui, Submit ; , NoHide
	IfWinExist, ahk_group POEGameGroup
	{
		Rescale()
		WinActivate, ahk_group POEGameGroup
	} else {
		MsgBox % "PoE Window does not exist. `nRecalibrate of OnDetonate didn't work"
		Return
	}
	
	if WinActive(ahk_group POEGameGroup){
		FindText.ScreenShot()
		If OnMines {
			varOnDetonateDelve := FindText.GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y)
			IniWrite, %varOnDetonateDelve%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonateDelve
			readFromFile()
			MsgBox % "OnDetonateDelve recalibrated!`nTook color hex: " . varOnDetonateDelve . " `nAt coords x: " . WR.loc.pixel.DetonateDelve.X . " and y: " . WR.loc.pixel.Detonate.Y
		} Else {
			varOnDetonate := FindText.GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
			IniWrite, %varOnDetonate%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate
			readFromFile()
			MsgBox % "OnDetonate recalibrated!`nTook color hex: " . varOnDetonate . " `nAt coords x: " . WR.loc.pixel.Detonate.X . " and y: " . WR.loc.pixel.Detonate.Y
		}
	}else
	MsgBox % "PoE Window is not active. `nRecalibrate of OnDetonate didn't work"
	
	MainMenu()
	
return

CalibrationWizard(){
	Global
	StartCalibrationWizard:
		Critical
		Gui, Submit
		Gui, Wizard: New, +LabelWizard +AlwaysOnTop
		Gui, Wizard: Font, Bold
		Gui, Wizard: Add, GroupBox, x10 y9 w500 h270 , Select which calibrations to run
		Gui, Wizard: Font
		Gui, Wizard: Add, Text, x22 y29 w180 h200 , % "Enable the checkboxes to choose which calibration to perform"
			. "`n`nFollow the instructions in the tooltip that will appear in the screen center"
			. "`n`nFor best results, start the wizard in the hideout with your inventory emptied"
			. "`n`nPress the ""A"" button when your gamestate matches the instructions"
			. "`n`nTo cancel the Wizard, Hold Escape then press ""A"""

		Gui, Wizard: Add, CheckBox, Section Checked vCalibrationOnChar    x222 y39       w140 h20 , Character Active
		Gui, Wizard: Add, CheckBox, Checked vCalibrationOnChat        xp   y+10      wp h20 , Chat Open
		Gui, Wizard: Add, CheckBox, Checked vCalibrationOnInventory     xp   y+10      wp h20 , Inventory Open
		Gui, Wizard: Add, CheckBox, Checked vCalibrationOnVendor      xp   y+10      wp h20 , Vendor Trade Open
		Gui, Wizard: Add, CheckBox, vCalibrationOnDiv             xp   y+10      wp h20 , Divination Trade Open
		Gui, Wizard: Add, CheckBox, vCalibrationDetonate          xp   y+10      wp h20 , Detonate Shown

		Gui, Wizard: Add, CheckBox, Checked vCalibrationOnMenu        xp+140 ys       wp h20 , Talent Menu Open
		Gui, Wizard: Add, CheckBox, Checked vCalibrationEmpty         xp   y+10      wp h20 , !EMPTY! Inventory Open
		Gui, Wizard: Add, CheckBox, Checked vCalibrationOnStash       xp   y+10      wp h20 , Stash Open
		Gui, Wizard: Add, CheckBox, vCalibrationOnDelveChart        xp   y+10      wp h20 , Delve Chart Open

		Gui, Wizard: Add, Button, x100 y240 w160 h30 gRunWizard, Run Wizard
		Gui, Wizard: Add, Button, x+20 yp wp hp gWizardClose, Cancel Wizard

		Gui, Wizard: Show,% "x"ScrCenter.X - 240 "y"ScrCenter.Y - 150 " h300 w529", Calibration Wizard
	Return

	RunWizard:
		Critical
		PauseTooltips:=1
		Gui, Wizard: Submit
		IfWinExist, ahk_group POEGameGroup
		{
			WinActivate, ahk_group POEGameGroup
			Rescale()
		} else {
			MsgBox % "PoE Window does not exist. `nCalibration Wizard didn't run"
			Return
		}

		SampleTT=
		EmptySampleTT=
		If CalibrationOnChar
		{
			ToolTip,% "This will sample the Character Active Color"
				. "`nMake sure you are logged into a character with flasks and abilities clearly visible"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 115 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnChar := FindText.GetColor(WR.loc.pixel.OnChar.X,WR.loc.pixel.OnChar.Y)
				SampleTT .= "Character Active took RGB color hex: " . varOnChar . "  At coords x: " . WR.loc.pixel.OnChar.X . " and y: " . WR.loc.pixel.OnChar.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Character Active didn't work"
		}
		If CalibrationOnChat
		{
			ToolTip,% "This will sample the Chat Open Color"
				. "`nMake sure you have chat panel open"
				. "`nNo other panels can be open on the left"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 115 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnChat := FindText.GetColor(WR.loc.pixel.OnChat.X,WR.loc.pixel.OnChat.Y)
				SampleTT .= "Chat Open   took RGB color hex: " . varOnChat . "  At coords x: " . WR.loc.pixel.OnChat.X . " and y: " . WR.loc.pixel.OnChat.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Chat Open didn't work"
		}
		If CalibrationOnMenu
		{
			ToolTip,% "This will sample the Passive Menu Open Color"
				. "`nMake sure you have the Passive Skills menu open"
				. "`nCan also use Atlas menu to sample"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 135 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnMenu := FindText.GetColor(WR.loc.pixel.OnMenu.X,WR.loc.pixel.OnMenu.Y)
				SampleTT .= "Passive Menu Open took RGB color hex: " . varOnMenu . "  At coords x: " . WR.loc.pixel.OnMenu.X . " and y: " . WR.loc.pixel.OnMenu.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Passive Menu Open didn't work"
		}
		If CalibrationOnInventory
		{
			ToolTip,% "This will sample the Inventory Open Color"
				. "`nMake sure you have the Inventory panel open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 130 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnInventory := FindText.GetColor(WR.loc.pixel.OnInventory.X,WR.loc.pixel.OnInventory.Y)
				SampleTT .= "Inventory Open took RGB color hex: " . varOnInventory . "  At coords x: " . WR.loc.pixel.OnInventory.X . " and y: " . WR.loc.pixel.OnInventory.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Inventory Open didn't work"
		}
		If CalibrationEmpty
		{
			ToolTip,% "This will sample the Empty Inventory Colors"
				. "`nNo items can be in your inventory, ALL slots must be empty to calibrate"
				. "`nMake sure you have the Inventory panel open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 125 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				varEmptyInvSlotColor := []
				FindText.ScreenShot()
				For c, GridX in InventoryGridX  
				{
					For r, GridY in InventoryGridY
					{
						PointColor := FindText.GetColor(GridX,GridY)
						if !(indexOf(PointColor, varEmptyInvSlotColor)){
							varEmptyInvSlotColor.Push(PointColor)
						}
					}
				}
				strToSave := hexArrToStr(varEmptyInvSlotColor)
				NewString := StringReplaceN(strToSave,",",",`n",4)
				NewString := StringReplaceN(NewString,",",",`n",11)
				NewString := StringReplaceN(NewString,",",",`n",18)
				NewString := StringReplaceN(NewString,",",",`n",25)
				NewString := StringReplaceN(NewString,",",",`n",32)
				NewString := StringReplaceN(NewString,",",",`n",39)
				NewString := StringReplaceN(NewString,",",",`n",46)
				NewString := StringReplaceN(NewString,",",",`n",53)
				SampleTT .= " "
				EmptySampleTT := "`nEmpty Inventory took RGB color hexes: " . NewString
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Empty Inventory didn't work"
		}
		If CalibrationOnVendor
		{
			ToolTip,% "This will sample the Vendor Trade Open Color"
				. "`nMake sure you have the Vendor Sell panel open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 135 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnVendor := FindText.GetColor(WR.loc.pixel.OnVendor.X,WR.loc.pixel.OnVendor.Y)
				SampleTT .= "Vendor Trade Open took RGB color hex: " . varOnVendor . "  At coords x: " . WR.loc.pixel.OnVendor.X . " and y: " . WR.loc.pixel.OnVendor.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Vendor Trade Open didn't work"
		}
		If CalibrationOnStash
		{
			ToolTip,% "This will sample the Stash Open and Left Panel Open Color"
				. "`nMake sure you have the Stash panel open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 115 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnStash := FindText.GetColor(WR.loc.pixel.OnStash.X,WR.loc.pixel.OnStash.Y)
				, varOnLeft := FindText.GetColor(WR.loc.pixel.OnLeft.X,WR.loc.pixel.OnLeft.Y)
				SampleTT .= "Stash Open took RGB color hex: " . varOnStash . "  At coords x: " . WR.loc.pixel.OnStash.X . " and y: " . WR.loc.pixel.OnStash.Y . "`n"
				SampleTT .= "Left Panel Open took RGB color hex: " . varOnLeft . "  At coords x: " . WR.loc.pixel.OnLeft.X . " and y: " . WR.loc.pixel.OnLeft.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Stash Open didn't work"
		}
		If CalibrationOnDiv
		{
			ToolTip,% "This will sample the Divination Trade Open Color"
				. "`nMake sure you have the Trade Divination panel open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 150 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnDiv := FindText.GetColor(WR.loc.pixel.OnDiv.X,WR.loc.pixel.OnDiv.Y)
				SampleTT .= "Divination Trade Open took RGB color hex: " . varOnDiv . "  At coords x: " . WR.loc.pixel.OnDiv.X . " and y: " . WR.loc.pixel.OnDiv.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of Divination Trade Open didn't work"
		}
		If CalibrationDetonate
		{
			ToolTip,% "This will sample the Detonate Mines Color"
				. "`nPlace a mine, and the detonate mines icon should appear"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 165 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot()
				If OnMines
					varOnDetonate := FindText.GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y)
				Else
					varOnDetonate := FindText.GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
				SampleTT .= "Detonate Mines took RGB color hex: " . varOnDetonate . "  At coords x: " . (OnMines?WR.loc.pixel.DetonateDelve.X:WR.loc.pixel.Detonate.X) . " and y: " . WR.loc.pixel.Detonate.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of OnDetonate didn't work"
		}
		If CalibrationOnDelveChart
		{
			ToolTip,% "This will sample the OnDelveChart Color"
				. "`nMake sure you have the Subterranean Chart open"
				. "`nPress ""A"" to sample"
				. "`nHold Escape and press ""A"" to cancel"
				, % ScrCenter.X - 150 , % ScrCenter.Y -30
			KeyWait, a, D L
			ToolTip
			KeyWait, a
			If GetKeyState("Escape", "P")
			{
				MsgBox % "Escape key was held`n"
				. "Canceling the Wizard!"
				Gui, Wizard: Show
				Exit
			}
			if WinActive(ahk_group POEGameGroup){
				FindText.ScreenShot(), varOnDelveChart := FindText.GetColor(WR.loc.pixel.OnDelveChart.X,WR.loc.pixel.OnDelveChart.Y)
				SampleTT .= "OnDelveChart       took RGB color hex: " . varOnDelveChart . "  At coords x: " . WR.loc.pixel.OnDelveChart.X . " and y: " . WR.loc.pixel.OnDelveChart.Y . "`n"
			} else
			MsgBox % "PoE Window is not active. `nRecalibrate of OnDelveChart didn't work"
		}
		PauseTooltips:=0
		If SampleTT =
		{
			MsgBox, No Sample Taken
			Gui, Wizard: Show
		}
		Else
			Goto, ShowWizardResults
	Return

	ShowWizardResults:
		Gui, Wizard: New, +LabelWizard
		Gui, Wizard: Add, Button,w1 h1
		Gui, Wizard: Add, Edit, , % SampleTT . EmptySampleTT
		Gui, Wizard: Add, Button, gSaveWizardResults, Save Samples
		Gui, Wizard: Add, Button, x+20 gWizardClose, Abort Samples

		Gui, Wizard: Show
	Return

	SaveWizardResults:
		If CalibrationOnChar
			IniWrite, %varOnChar%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChar    
		If CalibrationOnChat
			IniWrite, %varOnChat%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnChat
		If CalibrationOnMenu
			IniWrite, %varOnMenu%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnMenu
		If CalibrationOnInventory
			IniWrite, %varOnInventory%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnInventory
		If CalibrationEmpty
			IniWrite, %strToSave%, %A_ScriptDir%\save\Settings.ini, Inventory Colors, EmptyInvSlotColor
		If CalibrationOnVendor
			IniWrite, %varOnVendor%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnVendor
		If CalibrationOnStash
		{
			IniWrite, %varOnStash%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnStash
			IniWrite, %varOnLeft%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnLeft
		}
		If CalibrationOnDiv
			IniWrite, %varOnDiv%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDiv
		If CalibrationOnDelveChart
			IniWrite, %varOnDelveChart%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDelveChart
		If CalibrationDetonate
			IniWrite, %varOnDetonate%, %A_ScriptDir%\save\Settings.ini, Failsafe Colors, OnDetonate
		Gui, Wizard: Submit
		Gui, 1: show
	Return

	WizardEscape:
	WizardClose:
		Gui, Wizard: Destroy
		Gui, 1: Show
	Return
}
