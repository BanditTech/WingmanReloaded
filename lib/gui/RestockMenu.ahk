RestockMenu(choice:=""){
	Global
	static Built := False
	static Active := [1,1]
	static LoadedValues := ""
	Static DefaultSettings := {"Normal":"1"
	                          ,"Ignored":"0"
	                          ,"Restock":"0"
	                          ,"RestockName":""
	                          ,"RestockMin":20
	                          ,"RestockMax":40
	                          ,"RestockTo":30
														,"CustomTab":0
														,"CustomX":0
														,"CustomY":0}
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
		Gui, Restock: Add, DropDownList, xs+5 y+5 w180 vRestockRestockName gRestockSetValue, ||Wisdom|Portal|Blacksmith|Armourer|Glassblower|Gemcutter|Chisel|Transmutation|Alteration|Annulment|Chance|Regal|Alchemy|Chaos|Veiled|Augmentation|Divine|Jeweller|Fusing|Chromatic|Harbinger|Horizon|Enkindling|Ancient|Binding|Engineer|Regret|Unmaking|Instilling|Scouring|Sacred|Blessed|Vaal|Custom
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, xs+5 y+10, Min stack:
		Gui, Restock: Font, s9
		Gui, Restock: Add, text, x+5 yp w35, 0
		Gui, Restock: Add, UpDown, range0-40 vRestockRestockMin gRestockSetValue, 0
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, x+5 yp, Max stack:
		Gui, Restock: Font, s9
		Gui, Restock: Add, text, x+5 yp w35, 0
		Gui, Restock: Add, UpDown, range0-40 vRestockRestockMax gRestockSetValue, 0
		Gui, Restock: Font, Bold s9
		Gui, Restock: Add, Text, xs+5 y+10, Restock back to:
		Gui, Restock: Font, s9
		Gui, Restock: Add, text, x+5 yp w35, 0
		Gui, Restock: Add, UpDown, range0-40 vRestockRestockTo gRestockSetValue, 0
		CustomSlotHWND := []
		Gui, Restock: Add, Text, HWNDhwnd			   xs+5 y+20, Custom Tab:
		CustomSlotHWND.Push(hwnd)
    Gui, Restock: Add, Edit, HWNDhwnd      vRestockCustomTab gRestockSetValue     x+8 yp-3               w34  ,   0
		CustomSlotHWND.Push(hwnd)
		Gui, Restock: Add, Text, HWNDhwnd			   xs+5 y+10, Position:
		CustomSlotHWND.Push(hwnd)
		Gui, Restock: Add, Edit, HWNDhwnd      vRestockCustomX  gRestockSetValue      x+8 yp-3         w34 ,   0
		CustomSlotHWND.Push(hwnd)
		Gui, Restock: Add, Edit, HWNDhwnd      vRestockCustomY  gRestockSetValue      x+8                w34 ,   0
		CustomSlotHWND.Push(hwnd)
		Gui, Restock: Add, Button, HWNDhwnd    gRestockGetPosition    x+8              ,   Locate
		CustomSlotHWND.Push(hwnd)
		Gosub, RestockRefreshOption
		Gui, ReStock: show, AutoSize
	} Else
		Gui, ReStock: show, AutoSize
	Return

	RestockGetPosition:
		Coord := LetUserSelectPixel()
		LoadedValues["CustomX"] := Coord.X
		LoadedValues["CustomY"] := Coord.Y
		Gosub RestockRefreshOption
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
		If (LoadedValues.RestockName = "")
			GuiControl, Choose, RestockRestockName, 0
		Else
			GuiControl, ChooseString, RestockRestockName,% LoadedValues.RestockName
		
		max := StackSizes[LoadedValues["RestockName"]]
		if (max <= 0)
			max := 40
		GuiControl, +Range0-%max%, RestockRestockMax
		GuiControl, +Range0-%max%, RestockRestockMin
		GuiControl, +Range0-%max%, RestockRestockTo
		If (LoadedValues["RestockMax"] > max || LoadedValues.RestockName = "")
			LoadedValues["RestockMax"] := max
		If (LoadedValues["RestockMin"] >= max - 2 || LoadedValues.RestockName = "")
			LoadedValues["RestockMin"] := max // 2
		If (LoadedValues["RestockTo"] > max || LoadedValues.RestockName = "")
			LoadedValues["RestockTo"] := Round(max * (3/4))
		If (LoadedValues["RestockMin"] >= LoadedValues["RestockMax"] - 1)
			LoadedValues["RestockMin"] := LoadedValues["RestockMax"] - 2
		If (LoadedValues["RestockTo"] > LoadedValues["RestockMax"])
			LoadedValues["RestockTo"] := LoadedValues["RestockMax"]
		If (LoadedValues["RestockTo"] <= LoadedValues["RestockMin"])
			LoadedValues["RestockTo"] := LoadedValues["RestockMin"] + 1
		for k,v in DefaultSettings {
			If !LoadedValues.HasKey(k)
				LoadedValues[k] := v
			If (k = "RestockName")
				Continue
			Else
				GuiControl, , Restock%k%, % LoadedValues[k]
		}

		For k, v in CustomSlotHWND {
			GuiControl,% "Show" (LoadedValues["RestockName"] = "Custom") , % v
		}

		GroupNumber := (Active.1 - 1) * 5 + Active.2
		GuiControl, Text, RestockGroupBox, Slot Configuration: %GroupNumber%
		Gui, Restock: Show
	Return

	LoadRestockArray:
		If FileExist( A_ScriptDir "\save\Restock.json") {
			WR.Restock := JSON.Load(FileOpen(A_ScriptDir "\save\Restock.json","r").Read())
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
		Gosub RestockRefreshOption
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

