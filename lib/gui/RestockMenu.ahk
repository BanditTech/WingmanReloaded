RestockMenu(choice:=""){
	static Built := False
	static Active := [1,1]
	static LoadedValues := ""
	Static DefaultSettings := {Normal:"1"
	                          , Ignored:"0"
	                          , Restock:"0"
	                          , RestockName:""
	                          , RestockMin:20
	                          , RestockMax:40
	                          , RestockTo:30
	                          , CustomTab:0
	                          , CustomX:0
	                          , CustomY:0}
	static RestockGui := ""
	static CustomSlotHWND := []

	If (choice == "Load") {
		LoadRestockArray()
		Return
	}
	If !Built
	{
		Built := True
		RestockGui := Gui("AlwaysOnTop")
		RestockGui.SetFont("Bold")
		RestockGui.Add("GroupBox", "w660 h305 Section xm ym", "Inventory Slot Management:")
		RestockGui.Add("Picture", "w650 h-1 xs+5 ys+15", A_ScriptDir "\data\InventorySlots.png")
		RestockGui.SetFont()
		RestockGui.Opt("-MinimizeBox +AlwaysOnTop")
		LoadRestockArray()

		RestockGui.Add("Text", "w1 h1 xs+26 ys+13", "")

		For C, GridX in InventoryGridX
		{
			If (C != 1)
				RestockGui.Add("Text", "w1 h1 x+19 ys+13", "")
			For R, GridY in InventoryGridY
			{
				++ind
				buttonStr := "InventorySlot_" . C . "_" . R
				btn := RestockGui.Add("Button", "v" buttonStr " y+25 h27 w33", (ind < 10 ? "0" . ind : ind))
				btn.OnEvent("Click", RestockSetActive)
			}
		}
		ind := 0

		RestockGui.SetFont("Bold")
		RestockGui.Add("GroupBox", "vRestockGroupBox w220 h305 Section xs+670 ym", "Slot Configuration:")
		RestockGui.SetFont()

		LoadedValues := WR.Restock[Active[1]][Active[2]]

		r1 := RestockGui.Add("Radio", "xs+5 ys+22 vRestockNormal", "Normal slot")
		r1.OnEvent("Click", RestockSetValue)
		r2 := RestockGui.Add("Radio", "xs+5 y+5 vRestockIgnored", "Ignore this slot")
		r2.OnEvent("Click", RestockSetValue)
		r3 := RestockGui.Add("Radio", "xs+5 y+5 vRestockRestock", "Restock this slot")
		r3.OnEvent("Click", RestockSetValue)
		ddl := RestockGui.Add("DropDownList", "xs+5 y+5 w180 vRestockRestockName", ["","Wisdom","Portal","Blacksmith","Armourer","Glassblower","Gemcutter","Chisel","Transmutation","Alteration","Annulment","Chance","Regal","Alchemy","Chaos","Veiled","Augmentation","Divine","Jeweller","Fusing","Chromatic","Harbinger","Horizon","Enkindling","Ancient","Binding","Engineer","Regret","Unmaking","Instilling","Scouring","Sacred","Blessed","Vaal","Custom"])
		ddl.OnEvent("Change", RestockSetValue)
		RestockGui.SetFont("Bold s9")
		RestockGui.Add("Text", "xs+5 y+10", "Min stack:")
		RestockGui.SetFont("s9")
		RestockGui.Add("Text", "x+5 yp w35", "0")
		ud1 := RestockGui.Add("UpDown", "range0-40 vRestockRestockMin", 0)
		ud1.OnEvent("Change", RestockSetValue)
		RestockGui.SetFont("Bold s9")
		RestockGui.Add("Text", "x+5 yp", "Max stack:")
		RestockGui.SetFont("s9")
		RestockGui.Add("Text", "x+5 yp w35", "0")
		ud2 := RestockGui.Add("UpDown", "range0-40 vRestockRestockMax", 0)
		ud2.OnEvent("Change", RestockSetValue)
		RestockGui.SetFont("Bold s9")
		RestockGui.Add("Text", "xs+5 y+10", "Restock back to:")
		RestockGui.SetFont("s9")
		RestockGui.Add("Text", "x+5 yp w35", "0")
		ud3 := RestockGui.Add("UpDown", "range0-40 vRestockRestockTo", 0)
		ud3.OnEvent("Change", RestockSetValue)
		CustomSlotHWND := []
		txt1 := RestockGui.Add("Text", "xs+5 y+20", "Custom Tab:")
		CustomSlotHWND.Push(txt1.Hwnd)
		edt1 := RestockGui.Add("Edit", "vRestockCustomTab x+8 yp-3 w34", "0")
		edt1.OnEvent("Change", RestockSetValue)
		CustomSlotHWND.Push(edt1.Hwnd)
		txt2 := RestockGui.Add("Text", "xs+5 y+10", "Position:")
		CustomSlotHWND.Push(txt2.Hwnd)
		edt2 := RestockGui.Add("Edit", "vRestockCustomX x+8 yp-3 w34", "0")
		edt2.OnEvent("Change", RestockSetValue)
		CustomSlotHWND.Push(edt2.Hwnd)
		edt3 := RestockGui.Add("Edit", "vRestockCustomY x+8 w34", "0")
		edt3.OnEvent("Change", RestockSetValue)
		CustomSlotHWND.Push(edt3.Hwnd)
		btnLoc := RestockGui.Add("Button", "x+8", "Locate")
		btnLoc.OnEvent("Click", RestockGetPosition)
		CustomSlotHWND.Push(btnLoc.Hwnd)
		RestockGui.OnEvent("Close", RestockClose)
		RestockGui.OnEvent("Escape", RestockClose)
		RestockRefreshOption()
		RestockGui.Show("AutoSize")
	} Else
		RestockGui.Show("AutoSize")
	Return

	RestockGetPosition(*)
	{
		Coord := LetUserSelectPixel()
		LoadedValues["CustomX"] := Coord.X
		LoadedValues["CustomY"] := Coord.Y
		RestockRefreshOption()
	}

	RestockSetActive(ctrl, *)
	{
		btnArr := StrSplit(ctrl.Name, "_")
		ButtonNum := ctrl.Text
		ToolTip(ButtonNum)
		C := btnArr[2]
		R := btnArr[3]
		Active := [C,R]
		LoadedValues := WR.Restock[C][R]
		RestockRefreshOption()
	}

	RestockRefreshOption()
	{
		if (LoadedValues.RestockName == "")
			RestockGui["RestockRestockName"].Choose(0)
		Else
			RestockGui["RestockRestockName"].Choose(LoadedValues.RestockName)

		max := StackSizes[LoadedValues["RestockName"]]
		if (max <= 0)
			max := 40
		RestockGui["RestockRestockMax"].Opt("+Range0-" max)
		RestockGui["RestockRestockMin"].Opt("+Range0-" max)
		RestockGui["RestockRestockTo"].Opt("+Range0-" max)
		If (LoadedValues["RestockMax"] > max || LoadedValues.RestockName == "")
			LoadedValues["RestockMax"] := max
		If (LoadedValues["RestockMin"] >= max - 2 || LoadedValues.RestockName == "")
			LoadedValues["RestockMin"] := max // 2
		If (LoadedValues["RestockTo"] > max || LoadedValues.RestockName == "")
			LoadedValues["RestockTo"] := Round(max * (3/4))
		If (LoadedValues["RestockMin"] >= LoadedValues["RestockMax"] - 1)
			LoadedValues["RestockMin"] := LoadedValues["RestockMax"] - 2
		If (LoadedValues["RestockTo"] > LoadedValues["RestockMax"])
			LoadedValues["RestockTo"] := LoadedValues["RestockMax"]
		If (LoadedValues["RestockTo"] <= LoadedValues["RestockMin"])
			LoadedValues["RestockTo"] := LoadedValues["RestockMin"] + 1
		for k,v in DefaultSettings {
			If !LoadedValues.HasOwnProp(k)
				LoadedValues[k] := v
			If (k == "RestockName")
				Continue
			Else
				RestockGui["Restock" k].Value := LoadedValues[k]
		}

		For k, v in CustomSlotHWND {
			GuiCtrlFromHwnd(v).Visible := (LoadedValues["RestockName"] == "Custom")
		}

		GroupNumber := (Active[1] - 1) * 5 + Active[2]
		RestockGui["RestockGroupBox"].Text := "Slot Configuration: " GroupNumber
		RestockGui.Show()
	}

	LoadRestockArray()
	{
		If FileExist(A_ScriptDir "\save\Restock.json") {
			WR.Restock := JSON.LoadFile(A_ScriptDir "\save\Restock.json")
		} Else {
			WR.Restock := Map()
			For C, GridX in InventoryGridX{
				If !WR.Restock.Has(C)
					WR.Restock[C] := Map()
				For R, GridY in InventoryGridY{
					If !WR.Restock[C].Has(R)
						WR.Restock[C][R] := adash.cloneDeep(DefaultSettings)
				}
			}
		}
	}

	RestockSetValue(ctrl, *)
	{
		saved := RestockGui.Submit(0)
		VarName := RegExReplace(ctrl.Name, "^Restock", "")
		LoadedValues[VarName] := RestockGui[ctrl.Name].Value
		radios := ["Normal","Ignored","Restock"]
		If indexOf(VarName,radios) {
			For k,v in radios {
				if (v == VarName){
					radios.Delete(k)
					Break
				}
			}
			For k,v in radios {
				LoadedValues[v] := RestockGui["Restock" v].Value
			}
		}
		RestockRefreshOption()
	}

	ReStockSaveValues()
	{
		If FileExist(A_ScriptDir "\save\Restock.json")
			FileDelete(A_ScriptDir "\save\Restock.json")
		JSONtext := JSON.Dump(WR.ReStock, 2)
		FileAppend(JSONtext, A_ScriptDir "\save\Restock.json")
		JSONtext := ""
	}

	RestockClose(*)
	{
		Built := False
		RestockGui.Submit(0)
		ReStockSaveValues()
		RestockGui.Destroy()
		InventoryGui.Show()
	}
}
