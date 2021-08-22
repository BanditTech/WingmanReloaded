; Function: Create Matching ComboBox GUI
;--------------------------------------------------------------------------------
;================================================================================
;#[3.3.2.1 CBMatchingGUI]
#IfWinActive, CBMatchingGUI
;================================================================================
Enter::
NumpadEnter::
Tab::setCBMatchingGUILBChoice(CBMatchingGUI) ; pass GUI object reference

Up::
Down::ControlSend,, % A_ThisHotkey = "Up" ? "{Up}" : "{Down}", % "ahk_id "CBMatchingGUI.hLB

#If WinActive("Add or Edit a Group")
Tab::
	Gui, submit, NoHide
	;...context specific stuff
	KeyWait, Tab
	GuiControlGet, OutputVarE, 2:Focus
	GuiControlGet, varname, 2:Focusv
	If (InStr(varname,"OrFlag") || InStr(varname,"Min") || InStr(varname,"Eval") || InStr(varname,"OrCount") || InStr(varname,"StashTab") || InStr(varname,"Export") || InStr(varname,"groupKey") || InStr(varname,"Click here to Finish and Return to CLF") || InStr(varname,"Remove") || InStr(varname,"Add new"))
		return
	OutputVar := StrReplace(OutputVarE, "Edit", "ComboBox")
	ControlGet, hCBe, hwnd,,%OutputVarE%
	ControlGet, hCB, hwnd,,%OutputVar%
	if (!WinExist("ahk_id "hCBMatchesGui) && hCB && hCBe) {
		CreateCBMatchingGUI(hCB, "Add or Edit a Group")
	}
return

#If WinActive("Edit Crafting Tiers")
Tab::
	Gui, submit, NoHide
	;...context specific stuff
	KeyWait, Tab
	GuiControlGet, OutputVarE, CustomCrafting:Focus
	GuiControlGet, varname, CustomCrafting:Focusv
	If ( InStr(OutputVarE,"SysTabControl") || InStr(OutputVarE,"Button") || !InStr(varname, "CustomCrafting") )
		Return
	OutputVar := StrReplace(OutputVarE, "Edit", "ComboBox")
	ControlGet, hCBe, hwnd,,%OutputVarE%
	ControlGet, hCB, hwnd,,%OutputVar%
	if (!WinExist("ahk_id "hCBMatchesGui) && hCB && hCBe) {
		CreateCBMatchingGUI(hCB, "Edit Crafting Tiers")
	}
return

#If WinActive("Edit Map Mod")
Tab::
	Gui, submit, NoHide
	;...context specific stuff
	KeyWait, Tab
	GuiControlGet, OutputVarE, CustomMapModsUI2:Focus
	GuiControlGet, varname, CustomMapModsUI2:Focusv
	Tooltip % OutputVarE " - " varname
	If ( !InStr(varname, "MapModField") )
		Return
	OutputVar := StrReplace(OutputVarE, "Edit", "ComboBox")
	ControlGet, hCBe, hwnd,,%OutputVarE%
	ControlGet, hCB, hwnd,,%OutputVar%
	if (!WinExist("ahk_id "hCBMatchesGui) && hCB && hCBe) {
		CreateCBMatchingGUI(hCB, "Edit Map Mod")
	}
return

CreateCBMatchingGUI(hCB, parentWindowTitle) {
;--------------------------------------------------------------------------------
	Global CBMatchingGUI := {}
	Gui CBMatchingGUI:New, -Caption -SysMenu -Resize +ToolWindow +AlwaysOnTop
	Gui, +HWNDhCBMatchesGui +Delimiter`n
	Gui, Margin, 0, 0
	Gui, Font, s14 q5
	
	; get Parent ComboBox info
	WinGetPos, cX, cY, cW, cH, % "ahk_id " hCB
	ControlGet, CBList, List,,, % "ahk_id " hCB
	; MsgBox % ErrorLevel
	ControlGet, CBChoice, Choice,,, % "ahk_id " hCB
	; MsgBox % CBList ? "True" : "False"
	; set Gui controls with Parent ComboBox info
	Gui, Add, Edit, % "+HWNDhEdit x0 y0 w"cW+400 " R1"
	GuiControl,, %hEdit%, %CBChoice%
	Gui, Add, ListBox, % "+HWNDhLB xp y+0 wp" " R20", % CBList
	GuiControl, ChooseString, %hLB%, %CBChoice%
	
	CBMatchingGUI.hwnd := hCBMatchesGui
	CBMatchingGUI.hEdit := hEdit
	CBMatchingGUI.hLB := hLB
	CBMatchingGUI.hParentCB := hCB
	CBMatchingGUI.parentCBList := CBList
	CBMatchingGUI.parentWindowTitle := parentWindowTitle
	
	gFunction := Func("CBMatching").Bind(CBMatchingGUI)
	tFunction := Func("FuncTimer").Bind(gFunction,400)
	GuiControl, +g, %hEdit%, %tFunction%
	
	Gui, Show, % "x"cX-50 " y"cY-5 " ", % "CBMatchingGUI"
	ControlFocus,, % "ahk_id "CBMatchingGUI.hEdit
	SetTimer, DestroyCBMatchingGUI, 80
}
FuncTimer(funcobj,duration){
	SetTimer % funcobj,% "-" duration
}
;--------------------------------------------------------------------------------
CBMatching(ByRef CBMatchingGUI) { ; ByRef object generated at the GUI creation
;--------------------------------------------------------------------------------
	GuiControlGet, userInput,, % CBMatchingGUI.hEdit
	userInputArr := StrSplit(RTrim(userInput), " ")
	; choicesList := CBMatchingGUI.parentCBList
	MatchCount := MatchList := MisMatchList := 0
	matchArr := {}
	;--Find in list
	for k, v in userInputArr
	{
		If (v = "")
			Continue
		If (InStr(CBMatchingGUI.parentCBList, v))
			MatchList := True
		else
			MisMatchList := True
	}
	if (MatchList && !MisMatchList) {
		; Loop, Parse, choicesList, "`n"
		For index, choice in StrSplit(CBMatchingGUI.parentCBList,"`n"," `r")
		{
			if choice = ""
				continue
			MatchString := MisMatchString := 0
			posArr := {}
			for k, v in userInputArr
			{
				If (FoundPos := InStr(choice, v))
				{
					MatchString := True
					posArr.Push(FoundPos)
				}
				else
					MisMatchString := True
			}
			If (MatchString && !MisMatchString)
			{
				For k, v in posArr
				{
					If (v = 1 && A_Index = 1)
						atStart := True
				}
				If !IndexOf(choice,matchArr)
				{
					If (atStart)
						MatchesAtStart .= "`n"choice
					else
						MatchesAnywhere .= "`n"choice
					MatchCount++
					matchArr.Push(choice)
				}
			}
		}
		Matches := MatchesAtStart . MatchesAnywhere ; Ordered Match list
		GuiControl,, % CBMatchingGUI.hLB, %Matches%
		if (MatchCount = 1) {
			UniqueMatch := Matches
			GuiControl, ChooseString, % CBMatchingGUI.hLB, %UniqueMatch%
		} 
		else
			GuiControl, Choose, % CBMatchingGUI.hLB, 1
	} 
	else
		GuiControl,, % CBMatchingGUI.hLB, % "`n<! No Match !>" (userInput?"":"`n" CBMatchingGUI.parentCBList)
}

;--------------------------------------------------------------------------------
DestroyCBMatchingGUI() {
;--------------------------------------------------------------------------------
	Global CBMatchingGUI ; global object created with the CBMatchingGUI
	
	if (!WinActive("Ahk_id " CBMatchingGUI.hwnd) and WinExist("ahk_id " CBMatchingGUI.hwnd)) {
		Gui, % CBMatchingGUI.hwnd ":Destroy"
		SetTimer, DestroyCBMatchingGUI, Delete
	}
}

;--------------------------------------------------------------------------------
setCBMatchingGUILBChoice(CBMatchingGUI) {
;--------------------------------------------------------------------------------
	; get ListBox choice
	GuiControlGet, LBMatchesSelectedChoice,, % CBMatchingGUI.hLB 
	; set choice in parent ComboBox
	Control, ChooseString, %LBMatchesSelectedChoice%,,% "ahk_id "CBMatchingGUI.hParentCB
	; set focus to Parent ComboBox, this will destroy matching GUI
	ControlFocus,, % "ahk_id "CBMatchingGUI.hParentCB
}
