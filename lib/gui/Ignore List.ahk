IgnoreClose(GuiObj) {
	SaveIgnoreArray()
	IgnoreGui.Destroy()
	InventoryGui.Show()
}
IgnoreEscape(GuiObj) {
	SaveIgnoreArray()
	IgnoreGui.Destroy()
	InventoryGui.Show()
}


BuildIgnoreMenu() {
	Global IgnoreGui, InventoryGui, InventoryGridX, InventoryGridY, IgnoredSlot
	MainGui.Submit(0)
	IgnoreGui := Gui("+LabelIgnore -MinimizeBox +AlwaysOnTop")
	IgnoreGui.SetFont("Bold")
	IgnoreGui.Add("GroupBox", "w660 h305 Section xm ym", "Ignored Inventory Slots:")
	IgnoreGui.Add("Picture", "w650 h-1 xs+5 ys+15", A_ScriptDir "\data\InventorySlots.png")
	IgnoreGui.SetFont()
	LoadIgnoreArray()

	IgnoreGui.Add("Text", "w1 h1 xs+25 ys+13", "")
	ind := 0
	For C, GridX in InventoryGridX
	{
		If (C != 1)
			IgnoreGui.Add("Text", "w1 h1 x+18 ys+13", "")
		For R, GridY in InventoryGridY
		{
			++ind
			checkboxStr := "IgnoredSlot_" . C . "_" . R
			checkboxTik := IgnoredSlot[C][R]
			cb := IgnoreGui.Add("Checkbox", "v" checkboxStr " y+25 h27 Checked" checkboxTik, (ind < 10 ? "0" . ind : ind))
			cb.OnEvent("Click", UpdateCheckbox)
		}
	}
	ind := 0
	MainMenu()
	IgnoreGui.Show()
}

UpdateCheckbox(ctrl, *) {
	Global IgnoreGui, IgnoredSlot
	IgnoreGui.Submit(0)
	btnArr := StrSplit(ctrl.Name, "_")
	C := btnArr[2]
	R := btnArr[3]
	IgnoredSlot[C][R] := IgnoreGui[ctrl.Name].Value
}

LoadIgnoreArray()
{
	Global IgnoredSlot
	IgnoredSlot := JSON.LoadFile(A_ScriptDir "\save\IgnoredSlot.json")
	Return
}

SaveIgnoreArray()
{
	Global IgnoreGui, IgnoredSlot
	IgnoreGui.Submit(0)
	JSONtext := JSON.Dump(IgnoredSlot,,2)
	FileDelete(A_ScriptDir "\save\IgnoredSlot.json")
	FileAppend(JSONtext, A_ScriptDir "\save\IgnoredSlot.json")
	LoadIgnoreArray()
	Return
}

IgnoreSlotSetup(){
  Global IgnoredSlot, InventoryGridX, InventoryGridY
  ;Ignore Slot setup
  if !FileExist(A_ScriptDir "\save\IgnoredSlot.json")
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
