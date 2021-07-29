RestockMenu(choice:=""){
	Global
	static Built := False
	static Active := [1,1]
	static LoadedValues := ""
	Static DefaultSettings := {"Normal":"1"
	                          ,"Ignored":"0"
	                          ,"Restock":"0"
	                          ,"RestockName":""
	                          ,"RestockMin":0
	                          ,"RestockMax":0
	                          ,"RestockTo":0
	                          ,"MapSlot":0
	                          ,"MapPrep":0
	                          ,"MapSpecial":0}
	If (choice = "Load") {
		Gosub, LoadRestockArray
		Return
	}
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
		Gosub, LoadRestockArray

		Gui, Restock: Add, Text, w1 h1 xs+26 ys+13, ""

		For C, GridX in InventoryGridX
		{
			If (C != 1)
				Gui, Restock: Add, Text, w1 h1 x+19 ys+13, ""
			For R, GridY in InventoryGridY
			{
				++ind
				buttonStr := "InventorySlot_" . C . "_" . R
				Gui, Restock: Add, Button, v%buttonStr% gRestockSetActive y+25 h27 w33,% (ind < 10 ? "0" . ind : ind)
			}
		}
		ind=

		
		Gui, Restock: Font, Bold
		Gui, Restock: Add, GroupBox, vRestockGroupBox w220 h305 Section xs+670 ym, Slot Configuration:
		Gui, Restock: Font

		LoadedValues := WR.Restock[Active.1][Active.2]

		Gui, Restock: Add, Radio, xs+5 ys+22 vRestockNormal gRestockSetValue, Normal slot
		Gui, Restock: Add, Radio, xs+5 y+5 vRestockIgnored gRestockSetValue, Ignore this slot
		Gui, Restock: Add, Radio, xs+5 y+5 vRestockRestock gRestockSetValue, Restock this slot
		Gui, Restock: Add, DropDownList, xs+5 y+5 w180 vRestockRestockName gRestockSetValue, ||Wisdom|Portal|Alchemy|Alteration|Transmute|Augment|Vaal|Chaos|Binding|Scouring|Chisel|Horizon|Simple|Prime|Awakened|Engineer|Regal
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, xs+5 y+10, Min stack:
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp-3, 0
		Gui, Restock: Add, UpDown, vRestockRestockMin gRestockSetValue, 0
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, x+5 yp+3, Max stack:
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp-3, 0
		Gui, Restock: Add, UpDown, vRestockRestockMax gRestockSetValue, 0
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, xs+5 y+13, Restock back to:
		Gui, Restock: Font
		Gui, Restock: Add, Edit, x+5 yp-3, 0
		Gui, Restock: Add, UpDown, vRestockRestockTo gRestockSetValue, 0
		Gosub, RestockRefreshOption

		Gui, ReStock: show, AutoSize
	} Else
		Gui, ReStock: show, AutoSize
	Return

	RestockSetActive:
		Gui, Restock: Submit, NoHide
		btnArr := StrSplit(A_GuiControl, "_")
		GuiControlGet, ButtonNum, ,% A_GuiControl
		Tooltip % ButtonNum
		C := btnArr[2]
		R := btnArr[3]
		Active := [C,R]
		LoadedValues := WR.Restock[C][R]
		Gosub, RestockRefreshOption
	Return

	RestockRefreshOption:
		for k,v in DefaultSettings {
			If !LoadedValues.HasKey(k)
				LoadedValues[k] := v
			If (k = "RestockName") {
				If (LoadedValues[k] = "")
					GuiControl, Choose, RestockRestockName, 0
				Else
					GuiControl, ChooseString, RestockRestockName,% LoadedValues[k]
			}
			Else
				GuiControl, , Restock%k%, % LoadedValues[k]
		}
		GroupNumber := (Active.1 - 1) * 5 + Active.2
		GuiControl, Text, RestockGroupBox, Slot Configuration: %GroupNumber%
	Return

	LoadRestockArray:
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

	RestockSetValue:
		Gui, Restock: Submit, NoHide
		VarName := RegExReplace(A_GuiControl, "^Restock", "")
		LoadedValues[VarName] := %A_GuiControl%
		radios := ["Normal","Ignored","Restock"]
		If indexOf(VarName,radios) {
			For k,v in radios {
				if (v = VarName){
					radios.Delete(k)
					Break
				}
			}
			For k,v in radios {
				LoadedValues[v] := Restock%v%
			}
		}
	Return

	ReStockSaveValues:
		FileDelete, %A_ScriptDir%\save\Restock.json
		JSONtext := JSON.Dump(WR.ReStock,,2)
		FileAppend, %JSONtext%, %A_ScriptDir%\save\Restock.json
		JSONtext := ""
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

