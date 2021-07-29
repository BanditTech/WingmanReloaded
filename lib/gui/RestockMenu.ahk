RestockMenu(){
	Global
	static Built := False
	static Active := [1,1]
	static LoadedValues := ""
	If !Built
	{
		Built := True
		Gui, Submit
		Gui, ReStock: new, AlwaysOnTop
		Gui, Restock: Font, Bold
		Gui, Restock: Add, GroupBox, w660 h305 Section xm ym, Inventory Slot Management:
		Gui, Restock: Add, Picture, w650 h-1 xs+5 ys+15, %A_ScriptDir%\data\InventorySlots.png
		Gui, Restock: Font
		Gui, Restock: +LabelRestock -MinimizeBox +AlwaysOnTop
		LoadRestockArray()

		Gui, Restock: Add, Text, w1 h1 xs+26 ys+13, ""

		For C, GridX in InventoryGridX
		{
			If (C != 1)
				Gui, Restock: Add, Text, w1 h1 x+19 ys+13, ""
			For R, GridY in InventoryGridY
			{
				++ind
				checkboxStr := "IgnoredSlot_" . C . "_" . R
				checkboxTik := IgnoredSlot[C][R]
				Gui, Restock: Add, Button, v%checkboxStr% gUpdateActiveRestock y+25 h27 w33 Checked%checkboxTik%,% (ind < 10 ? "0" . ind : ind)
			}
		}
		ind=0

		
		Gui, Restock: Font, Bold
		Gui, Restock: Add, GroupBox, w220 h305 Section xs+670 ym, Slot Configuration:
		Gui, Restock: Font

		LoadedValues := WR.Restock[Active.1][Active.2]

		Gui, Restock: Add, Checkbox, xs+5 ys+22 vRestockIgnored gUpdateRestockOption, Ignore this slot
		Gui, Restock: Add, Checkbox, xs+5 y+5 vRestockRestock gUpdateRestockOption, Restock this slot
		Gui, Restock: Add, DropDownList, xs+5 y+5 w180 vRestockRestockName gUpdateRestockOption, Wisdom||Portal|Alchemy|Alteration|Transmute|Augment|Vaal|Chaos|Binding|Scouring|Chisel|Horizon|Simple|Prime|Awakened|Engineer|Regal
		Gui, Restock: Font, Bold s10
		Gui, Restock: Add, Text, xs+5 y+5, Min
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp vRestockRestockMin gUpdateRestockOption, 0
		Gui, Restock: Font, Bold s10
		Gui, Restock: Add, Text, x+5 yp, Max
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp , 0
		Gui, Restock: Add, UpDown, vRestockRestockMax gUpdateRestockOption, 0
		Gui, Restock: Font, Bold s10
		Gui, Restock: Add, Text, x+5 yp, Target
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp vRestockRestockTo gUpdateRestockOption, 0
		Gui, Restock: Add, Checkbox, xs+5 y+5 vRestockMapSlot gUpdateRestockOption, Map slot
		Gui, Restock: Add, Checkbox, xs+5 y+5 vRestockMapPrep gUpdateRestockOption, Map prep slot
		Gui, Restock: Add, Checkbox, xs+5 y+5 vRestockMapSpecial gUpdateRestockOption, Map Special slot

		Gui, ReStock: show, AutoSize
	} Else
		Gui, ReStock: show, AutoSize
	Return

	UpdateActiveRestock:
		Gui, Restock: Submit, NoHide
		btnArr := StrSplit(A_GuiControl, "_")
		C := btnArr[2]
		R := btnArr[3]
		Tooltip Pressed Button %C% %R%
		Active := [C,R]
		LoadedValues := WR.Restock[C][R]
	Return

	UpdateRestockOption:
		Gui, Restock: Submit, NoHide
		VarName := RegExReplace(A_GuiControl, "^Restock", "")
		Tooltip % VarName " has " %A_GuiControl% Value
	Return


	ReStockSaveValues:
		FileDelete, %A_ScriptDir%\save\Restock.json
		JSONtext := JSON.Dump(WR.ReStock,,2)
		FileAppend, %JSONtext%, %A_ScriptDir%\save\Restock.json
	Return
	RestockClose:
	RestockEscape:
		Built := False
		Gui, Restock: Submit, Nohide
		Gosub, ReStockSaveValues
		Gui, Restock: Destroy
		Gui, Inventory: Show
	Return
}

LoadRestockArray()
{
	Static DefaultSettings := {"Ignored":0,"Restock":0,"RestockName":"","RestockMin":0,"RestockMax":0,"RestockTo":0,"MapSlot":0,"MapPrep":0,"MapSpecial":0}
	If FileExist( A_ScriptDir "\save\Restock.json") {
		FileRead, JSONtext, %A_ScriptDir%\save\Restock.json
		WR.Restock := JSON.Load(JSONtext)
	} Else {
		WR.Restock := {}
		For C, GridX in InventoryGridX{
			If !WR.Restock.HasKey(C)
				WR.Restock[C] := {}
			For R, GridY in InventoryGridY{
				If !WR.Restock[C].HasKey(R)
					WR.Restock[C][R] := Array_DeepClone(DefaultSettings)
			}
		}
	}
	Return
}
