IgnoreClose:
IgnoreEscape:
	SaveIgnoreArray()
	Gui, Ignore: Destroy
	Gui, Inventory: Show
Return


BuildIgnoreMenu:
	Gui, Submit
	Gui, Ignore: +LabelIgnore -MinimizeBox +AlwaysOnTop
	Gui, Ignore: Font, Bold
	Gui, Ignore: Add, GroupBox, w660 h305 Section xm ym, Ignored Inventory Slots:
	Gui, Ignore: Add, Picture, w650 h-1 xs+5 ys+15, %A_ScriptDir%\data\InventorySlots.png
	Gui, Ignore: Font
	LoadIgnoreArray()

	Gui, Ignore: Add, Text, w1 h1 xs+25 ys+13, ""
	For C, GridX in InventoryGridX
	{
		If (C != 1)
			Gui, Ignore: Add, Text, w1 h1 x+18 ys+13, ""
		For R, GridY in InventoryGridY
		{
			++ind
			checkboxStr := "IgnoredSlot_" . C . "_" . R
			checkboxTik := IgnoredSlot[C][R]
			Gui, Ignore: Add, Checkbox, v%checkboxStr% gUpdateCheckbox y+25 h27 Checked%checkboxTik%,% (ind < 10 ? "0" . ind : ind)
		}
	}
	ind=0
	MainMenu()
	Gui, Ignore: Show
Return

UpdateCheckbox:
	Gui, Ignore: Submit, NoHide
	btnArr := StrSplit(A_GuiControl, "_")
	C := btnArr[2]
	R := btnArr[3]
	IgnoredSlot[C][R] := %A_GuiControl%
Return

LoadIgnoreArray()
{
	IgnoredSlot := JSON.Load(FileOpen(A_ScriptDir "\save\IgnoredSlot.json","r").Read())
	Return
}

SaveIgnoreArray()
{
	SaveIgnoreArray:
	Gui, Ignore: Submit, NoHide
	JSONtext := JSON.Dump(IgnoredSlot,,2)
	FileDelete, %A_ScriptDir%\save\IgnoredSlot.json
	FileAppend, %JSONtext%, %A_ScriptDir%\save\IgnoredSlot.json
	LoadIgnoreArray()
	Return
}

IgnoreSlotSetup(){
  ;Ignore Slot setup
  IfNotExist, %A_ScriptDir%\save\IgnoredSlot.json
  {
    For C, GridX in InventoryGridX
    {
      IgnoredSlot[C] := {}
      For R, GridY in InventoryGridY
      {
        IgnoredSlot[C][R] := False
      }
    }
    SaveIgnoreArray()
  } 
  Else
    LoadIgnoreArray()
}