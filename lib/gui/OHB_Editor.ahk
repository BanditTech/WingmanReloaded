OHB_Editor(){
	Static OHB_Width := 104, OHB_Height := 1, OHB_Variance := 1, OHB_LR_border:=1, OHB_Split := ToRGB(0x221415), Initialized := 0
	Static OHBGui := ""
	global OHB_Preview,OHB_r,OHB_g,OHB_b, OHB_Color := 0x221415, OHB_StringEdit
	If !Initialized
	{
		Initialized := 1
		OHBGui := Gui()
		OHBGui.Opt("+AlwaysOnTop")
		OHBGui.SetFont("cBlack s20")
		OHBGui.Add("Text", "xm", "Output String:")
		btnTest := OHBGui.Add("Button", "x+120 yp hp wp vOHB_Test", "Test String")
		btnTest.OnEvent("Click", OHBUpdate)
		OHBGui.SetFont()
		OHBGui.Add("Edit", "xm vOHB_StringEdit w480 h25", Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border))
		OHBGui["OHB_StringEdit"].OnEvent("Change", OHBUpdate)
		OHBGui.SetFont("cBlack s20")
		OHBGui.Add("Text", "xm y+35", "Width:")
		OHBGui.Add("Text", "x+0 yp w65", OHB_Width)
		ud1 := OHBGui.Add("UpDown", "vOHB_Width Range20-300", OHB_Width)
		ud1.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Text", "x+20", "Height:")
		OHBGui.Add("Text", "x+0 yp w40", OHB_Height)
		ud2 := OHBGui.Add("UpDown", "vOHB_Height Range1-5", OHB_Height)
		ud2.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Text", "x+20", "Variance:")
		OHBGui.Add("Text", "x+0 yp w40", OHB_Variance)
		ud3 := OHBGui.Add("UpDown", "vOHB_Variance", OHB_Variance)
		ud3.OnEvent("Change", OHBUpdate)

		eColor := OHBGui.Add("Edit", "xm y+35 w140 h35 vOHB_Color", OHB_Color)
		eColor.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Text", "x+20 yp", "R:")
		OHBGui.Add("Text", "x+0 yp w65", OHB_Split.r)
		udr := OHBGui.Add("UpDown", "vOHB_r range0-255", OHB_Split.r)
		udr.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Text", "x+20 yp", "G:")
		OHBGui.Add("Text", "x+0 yp w65", OHB_Split.g)
		udg := OHBGui.Add("UpDown", "vOHB_g range0-255", OHB_Split.g)
		udg.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Text", "x+20 yp", "B:")
		OHBGui.Add("Text", "x+0 yp w65", OHB_Split.b)
		udb := OHBGui.Add("UpDown", "vOHB_b range0-255", OHB_Split.b)
		udb.OnEvent("Change", OHBUpdate)
		OHBGui.Add("Progress", "xm y+5 w140 h40 vOHB_Preview c" OHB_Color " BackgroundBlack", 100)
		btnReset := OHBGui.Add("Button", "x+90 yp hp wp+40 vOHB_CReset", "Reset Color")
		btnReset.OnEvent("Click", OHBUpdate)
		OHBGui.OnEvent("Close", OHBGuiClose)
		OHBGui.OnEvent("Escape", OHBGuiClose)
	}
	OHBGui.Show("w535 h300", "OHB String Builder")
	Return

	OHBUpdate(ctrl, *)
	{
		ctrlName := ctrl.Name
		If (ctrlName = "OHB_Test")
		{
			If GamePID
			{
				saved := OHBGui.Submit(0)
				OHB_StringEdit := OHBGui["OHB_StringEdit"].Value
				WinActivate(GameStr)
				Sleep(145)
				WinGetPos(&GameX, &GameY, &GameW, &GameH)
			}
			Else
			{
				MsgBox("Make sure you have the game open", "Cannot find game", 262144)
				Return
			}
			If (Bar:=FindText(GameX + Round((GameW / 2)-(OHB_Width/2 + 1)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2 + 1)+(OHB_Width/2)), Round(GameH / (1080 / 370)) , 0, 0, OHB_StringEdit))
			{
				MsgBox("OHB string was found!`nMake sure the highlighted matched area is the entire width of the healthbar`nThe red and blue flashing boxes should go to the very inner edge`n`nIf you are done, copy the string into the String Tab", "String Found", 262144)
				MouseTip(Bar[1][1], Bar[1][2], (Bar[1][3]<2?2:Bar[1][3]), (Bar[1][4]<2?2:Bar[1][4]))
				OHB_Editor()
			}
			Else
			{
				MsgBox("OHB string was not found!`nMake sure the width is an even number`nTry reset the color if its adjusted", "Cannot find string", 262144)
				OHB_Editor()
			}
		}
		Else If (ctrlName = "OHB_EditorBtn")
		{
			StringsGui.Submit(0)
			OHB_Editor()
			return
		}
		Else
			OHBGui.Submit(0)
		If (ctrlName = "OHB_r" || ctrlName = "OHB_g" || ctrlName = "OHB_b")
		{
			OHB_r := OHBGui["OHB_r"].Value
			OHB_g := OHBGui["OHB_g"].Value
			OHB_b := OHBGui["OHB_b"].Value
			OHB_Split.r := OHB_r, OHB_Split.g := OHB_g, OHB_Split.b := OHB_b
			OHB_Color := ToHex(OHB_Split)
			OHBGui["OHB_Color"].Value := OHB_Color
			OHBGui["OHB_Preview"].Opt("+c" OHB_Color)
		}
		Else If (ctrlName = "OHB_Color" || ctrlName = "OHB_CReset")
		{
			If (ctrlName = "OHB_CReset")
			{
				OHB_Color := "0x221415"
				OHBGui["OHB_Color"].Value := OHB_Color
			}
			OHB_Split := ToRGB(OHB_Color)
			OHBGui["OHB_r"].Value := OHB_Split.r
			OHBGui["OHB_g"].Value := OHB_Split.g
			OHBGui["OHB_b"].Value := OHB_Split.b
			OHBGui["OHB_Preview"].Opt("+c" OHB_Color)
		}
		OHBGui["OHB_StringEdit"].Value := Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border)
	}

	OHBGuiClose(*)
	{
		OHBGui.Hide()
		StringsGui.Show()
	}
}
