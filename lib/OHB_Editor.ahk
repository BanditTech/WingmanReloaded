OHB_Editor(){
	Static OHB_Width := 104, OHB_Height := 1, OHB_Variance := 1, OHB_LR_border:=1, OHB_Split := ToRGB(0x221415), Initialized := 0, OHB_CReset, OHB_Test
	global OHB_Preview,OHB_r,OHB_g,OHB_b, OHB_Color = 0x221415,OHB_StringEdit
	If !Initialized
	{
		Gui, OHB: new
		Gui, OHB: +AlwaysOnTop
		Gui, OHB: Font, cBlack s20
		Gui, OHB: add, Text, xm , Output String:
		Gui, OHB: add, Button, x+120 yp hp wp vOHB_Test gOHBUpdate, Test String
		Gui, OHB: Font,
		Gui, OHB: add, edit, xm vOHB_StringEdit gOHBUpdate w480 h25, % Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border)
		Gui, OHB: Font, cBlack s20
		Gui, OHB: add, text, xm y+35, Width:
		Gui, OHB: add, text, x+0 yp w65, %OHB_Width%
		Gui, OHB: add, UpDown, vOHB_Width gOHBUpdate Range20-300 , %OHB_Width%
		Gui, OHB: add, text, x+20 , Height:
		Gui, OHB: add, text, x+0 yp w40, %OHB_Height%
		Gui, OHB: add, UpDown, vOHB_Height gOHBUpdate Range1-5 , %OHB_Height%
		Gui, OHB: add, text, x+20 , Variance:
		Gui, OHB: add, text, x+0 yp w40, %OHB_Variance%
		Gui, OHB: add, UpDown, vOHB_Variance gOHBUpdate , %OHB_Variance%

		Gui, OHB: add, Edit, xm y+35 w140 h35 vOHB_Color gOHBUpdate, %OHB_Color%
		Gui, OHB: add, text, x+20 yp, R:
		Gui, OHB: add, text, x+0 yp w65,% OHB_Split.r
		Gui, OHB: add, updown, vOHB_r gOHBUpdate range0-255, % OHB_Split.r
		Gui, OHB: add, text, x+20 yp, G:
		Gui, OHB: add, text, x+0 yp w65,% OHB_Split.g
		Gui, OHB: add, updown, vOHB_g gOHBUpdate range0-255, % OHB_Split.g
		Gui, OHB: add, text, x+20 yp, B:
		Gui, OHB: add, text, x+0 yp w65,% OHB_Split.b
		Gui, OHB: add, updown, vOHB_b gOHBUpdate range0-255, % OHB_Split.b
		Gui, OHB: add, Progress, xm y+5 w140 h40 vOHB_Preview c%OHB_Color% BackgroundBlack,100
		Gui, OHB: add, Button, x+90 yp hp wp+40 vOHB_CReset gOHBUpdate, Reset Color
	}
	Gui, OHB: show , w535 h300, OHB String Builder
	Return

	OHBUpdate:
		If (A_GuiControl = "OHB_Test")
		{
			If GamePID
			{
				Gui, OHB: Submit
				WinActivate, %GameStr%
				Sleep, 145
				WinGetPos, GameX, GameY, GameW, GameH
			}
			Else
			{
				MsgBox, 262144, Cannot find game, Make sure you have the game open
				Return
			}
			If (Bar:=FindText(GameX + Round((GameW / 2)-(OHB_Width/2 + 1)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2 + 1)+(OHB_Width/2)), Round(GameH / (1080 / 370)) , 0, 0, OHB_StringEdit))
			{
				MsgBox, 262144, String Found, OHB string was found!`nMake sure the highlighted matched area is the entire width of the healthbar`nThe red and blue flashing boxes should go to the very inner edge`n`nIf you are done, copy the string into the String Tab 
				MouseTip(Bar.1.1, Bar.1.2, (Bar.1.3<2?2:Bar.1.3), (Bar.1.4<2?2:Bar.1.4))
				OHB_Editor()
			}
			Else
			{
				MsgBox, 262144, Cannot find string, OHB string was not found!`nMake sure the width is an even number`nTry reset the color if its adjusted
				OHB_Editor()
			}
		}
		Else If (A_GuiControl = "OHB_EditorBtn")
		{
			Gui,Strings: submit
			OHB_Editor()
			return
		}
		Else
		Gui, OHB: Submit, NoHide
		If (A_GuiControl = "OHB_r" || A_GuiControl = "OHB_g" || A_GuiControl = "OHB_b")
		{
			OHB_Split.r := OHB_r, OHB_Split.g := OHB_g, OHB_Split.b := OHB_b, OHB_Color := ToHex(OHB_Split)
			GuiControl,OHB: , OHB_Color, %OHB_Color%
			GuiControl,OHB: +c%OHB_Color%, OHB_Preview
		}
		Else If (A_GuiControl = "OHB_Color" || A_GuiControl = "OHB_CReset")
		{
			If (A_GuiControl = "OHB_CReset")
			{
				OHB_Color = 0x221415
				GuiControl,OHB: , OHB_Color, %OHB_Color%
			}
			OHB_Split := ToRGB(OHB_Color)
			GuiControl,OHB: , OHB_r, % OHB_Split.r
			GuiControl,OHB: , OHB_g, % OHB_Split.g
			GuiControl,OHB: , OHB_b, % OHB_Split.b
			GuiControl,OHB: +c%OHB_Color%, OHB_Preview
		}
		GuiControl, , OHB_StringEdit, % Hex2FindText(OHB_Color,OHB_Variance,0,"OHB_Bar",OHB_Width,OHB_Height,OHB_LR_border)
	Return

	OHBGuiClose:
	OHBGuiEscape:
		Gui, OHB: hide
		Gui, Strings: show
	return
}
