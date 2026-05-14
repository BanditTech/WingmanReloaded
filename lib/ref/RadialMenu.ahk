/* Radial_Menu - Displays Menu encircling Mouse, which can contain icons.
; Created by ahk_user @ 2019
; Creates radial Mouse menu
; V1.00046
; Changes
; Add function accepts HBitmap or files
; Requires Gdip_GetPointsSection()
*/

class Radial_Menu {
	__New() {
		this.Sections := 4
		this.RM_Key := "F9"
		this.IconSize := 70
		this.Sect_Name := Map()
		this.Sect_Img := Map()
		this.Sect_Name2 := Map()
		this.Sect_Img2 := Map()
	}

	SetSections(Sections) {
		this.Sections := Sections
	}
	SetKey(RM_Key) {
		this.RM_Key := RM_Key
	}
	SetKeySpecial(RM_Key2) {
		this.RM_Key2 := RM_Key2
	}

	Add(SectionName, SectionImg, ArcNr) {
		if (this.Sections < ArcNr) {
			this.Sections := ArcNr
		}
		this.Sect_Name[ArcNr] := SectionName
		this.Sect_Img[ArcNr] := SectionImg
	}
	Add2(SectionName2, SectionImg2, ArcNr) {
		if (this.Sections < ArcNr) {
			this.Sections := ArcNr
		}
		this.Sect_Name2[ArcNr] := SectionName2
		this.Sect_Img2[ArcNr] := SectionImg2
	}

	Show() {
		global pToken
		this.Active := True
		SectName := ""
		CoordMode("Mouse", "Window")
		MouseGetPos(&X_Center, &Y_Center)
		WinGetPos(&X_Win, &Y_Win,,, "A")
		R_1 := 100
		R_2 := R_1 * 0.2
		Offset := 2
		R_3 := R_1 + Offset * 2 + 10

		X_Gui := X_Center - R_3 + X_Win
		Y_Gui := Y_Center - R_3 + Y_Win
		Height_Gui := R_3 * 2
		Width_Gui := R_3 * 2

		Width := R_3 * 2
		height := R_3 * 2

		if WinExist("RM_Menu") {
			if IsObject(this.rmGui)
				this.rmGui.Destroy()
		}

		; Start gdi+
		If !pToken := Gdip_Startup() {
			MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system", "gdiplus error!", 48)
			ExitApp
		}
		OnExit(ExitFunc)

		; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
		rmGui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", "RM_Menu")
		this.rmGui := rmGui

		; Show the window
		rmGui.Show("NA x" X_Gui " y" Y_Gui " w" Width_Gui " h" Height_Gui)

		; Get a handle to this window we have created in order to update it later
		hwnd1 := rmGui.Hwnd

		MouseGetPos(&X_Center, &Y_Center)
		ColorBackGround := "111111"
		ColorLineBackGround := "111111"
		ColorSelected := "222222"
		ColorLineSelected := "222222"

		; Declare Maps for bitmap storage
		pBitmap := Map(), bWidth := Map(), bHeight := Map()
		pBitmap2 := Map(), bWidth2 := Map(), bHeight2 := Map()
		PointsA := Map(), Points := Map()
		X_Bitmap := Map(), Y_Bitmap := Map()

		Loop this.Sections { ; Setting Bitmap images of sections
			if FileExist(this.Sect_Img[A_Index]) {
				pBitmap[A_Index] := Gdip_CreateBitmapFromFile(this.Sect_Img[A_Index])
			} else if (this.Sect_Img[A_Index] != "") {
				pBitmap[A_Index] := Gdip_CreateBitmapFromHBITMAP(this.Sect_Img[A_Index])
			}

			bWidth[A_Index] := Gdip_GetImageWidth(pBitmap[A_Index])
			bHeight[A_Index] := Gdip_GetImageHeight(pBitmap[A_Index])

			if FileExist(this.Sect_Img2[A_Index]) {
				pBitmap2[A_Index] := Gdip_CreateBitmapFromFile(this.Sect_Img2[A_Index])
			} else if (this.Sect_Img2[A_Index] != "") {
				pBitmap2[A_Index] := Gdip_CreateBitmapFromHBITMAP(this.Sect_Img2[A_Index])
			}
			bWidth2[A_Index] := Gdip_GetImageWidth(pBitmap2[A_Index])
			bHeight2[A_Index] := Gdip_GetImageHeight(pBitmap2[A_Index])
		}

		Counter := 0
		Loop this.Sections { ; Calculating Section Points
			SectionAngle := 2 * 3.141592653589793 / this.Sections * (A_Index - 1)

			X_Bitmap[A_Index] := R_3 + (R_1 - 30) * Cos(SectionAngle) - 8
			Y_Bitmap[A_Index] := R_3 + (R_1 - 30) * Sin(SectionAngle) - 8

			PointsA[A_Index] := Gdip_GetPointsSection(R_3, R_3, R_1 + Offset * 2 + 10, R_1 + Offset * 2, this.Sections, Offset, A_Index)
			Points[A_Index] := Gdip_GetPointsSection(R_3, R_3, R_1, R_2, this.Sections, Offset, A_Index)
		}

		; Setting brushes and Pens
		pBrush := Gdip_BrushCreateSolid("0xFF" ColorBackGround)
		pBrushA := Gdip_BrushCreateSolid("0xFF" ColorSelected)
		pBrushC := Gdip_BrushCreateSolid("0X01" ColorBackGround)
		pPen := Gdip_CreatePen("0xFF" ColorLineBackGround, 1)
		pPenA := Gdip_CreatePen("0xD2" ColorLineSelected, 1)

		RM_KeyState_D := 0

		Loop {
			RM_KeyState := GetKeyState(this.RM_Key, "P")
			RM_KeyState2 := GetKeyState(this.RM_Key2, "P")
			if !WinExist("RM_Menu") {
				Break
			}
			if (RM_KeyState = 1) {
				RM_KeyState_D := 1
			}
			if (RM_KeyState = 0 and RM_KeyState_D = 1) {
				Section_Mouse := RM_GetSection(this.Sections, R_2, X_Center, Y_Center)
				if (Section_Mouse != 0) {
					break
				}
				RM_KeyState_D := 0
			}
			if (GetKeyState("LButton")) {
				Section_Mouse := RM_GetSection(this.Sections, R_2, X_Center, Y_Center)
				if (Section_Mouse != 0) {
					break
				}
				if (Section_Mouse = 0) {
					SectName := ""
					break
				}
			}
			if GetKeyState("Escape") {
				Section_Mouse := 0
				SectName := ""
				break
			}

			MouseGetPos(&X_Mouse, &Y_Mouse)
			X_Rel := X_Mouse - X_Center
			Y_Rel := Y_Mouse - Y_Center
			Center_Distance := Sqrt(X_Rel * X_Rel + Y_Rel * Y_Rel)

			Section_Mouse := RM_GetSection(this.Sections, R_2, X_Center, Y_Center)

			if (Center_Distance > R_1) {
				break
			}
			if (Section_Mouse = 0) {
				ToolTip
				SectName := ""
			}
			if (Section_Mouse > 0) {
				Counter++
				SectName_N := this.Sect_Name[Section_Mouse]
				SectName2 := this.Sect_Name2[Section_Mouse]
				if (GetKeyState(this.RM_Key2, "P") and SectName2 != "") {
					SectName_N := this.Sect_Name2[Section_Mouse]
				}

				if ((X_Mouse_P != X_Mouse) or (Y_Mouse_P != Y_Mouse) or SectName_N != SectName or Counter > 500) {
					SectName := SectName_N
					CoordMode("Mouse", "Window")
					MouseGetPos(&X_Mouse_P, &Y_Mouse_P)
					if (Counter > 500 or SectName_N != SectName) {
						ToolTip SectName
						Counter := 0
					}
				}
			}
			if (Section_Mouse != Section_Mouse_Prev or A_Index = 1 or RM_KeyState2_Prev != RM_KeyState2) { ; Update GDIP

				Gdip_GraphicsClear(G)
				hbm := CreateDIBSection(Width, Height) ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
				hdc := CreateCompatibleDC() ; Get a device context compatible with the screen
				obm := SelectObject(hdc, hbm) ; Select the bitmap into the device context
				G := Gdip_GraphicsFromHDC(hdc) ; Get a pointer to the graphics of the bitmap, for use with drawing functions

				; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
				Gdip_SetSmoothingMode(G, 4)
				Gdip_FillEllipse(G, pBrushC, R_3 - R_1, R_3 - R_1, 2 * R_1, 2 * R_1)

				Loop this.Sections {
					SectionAngle := 2 * 3.141592653589793 / this.Sections * (A_Index - 1)
					if (this.Sect_Name[A_Index] = "") {
						continue
					}
					If (A_Index = Section_Mouse) {
						Gdip_FillPolygon(G, pBrushA, Points[A_Index])
						Gdip_DrawLines(G, pPenA, Points[A_Index])
						Gdip_FillPolygon(G, pBrushA, PointsA[A_Index])
						Gdip_DrawLines(G, pPenA, PointsA[A_Index])
					} else {
						Gdip_FillPolygon(G, pBrush, Points[A_Index])
						Gdip_DrawLines(G, pPen, Points[A_Index])
					}
					if (GetKeyState(this.RM_Key2, "P") and this.Sect_Name2[A_Index] != "") {
						Gdip_DrawImage(G, pBitmap2[A_Index], X_Bitmap[A_Index] - this.IconSize // 2.5, Y_Bitmap[A_Index] - this.IconSize // 2.5, this.IconSize, this.IconSize * bHeight2[A_Index] / bWidth2[A_Index], 0, 0, bWidth2[A_Index], bHeight2[A_Index])
					} else {
						Gdip_DrawImage(G, pBitmap[A_Index], X_Bitmap[A_Index] - this.IconSize // 2.5, Y_Bitmap[A_Index] - this.IconSize // 2.5, this.IconSize, this.IconSize * bHeight[A_Index] / bWidth[A_Index], 0, 0, bWidth[A_Index], bHeight[A_Index])
					}
					if (this.Sect_Img[A_Index] = "") {
						Gdip_TextToGraphics(G, this.Sect_Name[A_Index], "vCenter x" X_Bitmap[A_Index] - 20 + 8 " y" Y_Bitmap[A_Index] - 20 + 8, "", "40", "40")
					}
				}

				; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
				; So this will position our gui at (0,0) with the Width and Height specified earlier
				UpdateLayeredWindow(hwnd1, hdc, X_Gui, Y_Gui, Width, Height)
				SelectObject(hdc, obm) ; Select the object back into the hdc
				DeleteObject(hbm) ; Now the bitmap may be deleted
				DeleteDC(hdc) ; Also the device context related to the bitmap may be deleted
				Gdip_DeleteGraphics(G) ; The graphics may now be deleted
			}
			RM_KeyState2_Prev := RM_KeyState2
			Section_Mouse_Prev := Section_Mouse
		}

		ToolTip

		SelectObject(hdc, obm) ; Select the object back into the hdc
		DeleteObject(hbm) ; Now the bitmap may be deleted
		DeleteDC(hdc) ; Also the device context related to the bitmap may be deleted
		Gdip_DeleteGraphics(G) ; The graphics may now be deleted

		Loop this.Sections {
			Gdip_DisposeImage(pBitmap[A_Index])
			Gdip_DisposeImage(pBitmap2[A_Index])
		}

		Gdip_DeleteBrush(pBrushC)
		Gdip_DeleteBrush(pBrush)
		Gdip_DeleteBrush(pBrushA)
		Gdip_DeletePen(pPen)
		Gdip_DeletePen(pPenA)
		Gdip_Shutdown(pToken)
		rmGui.Destroy()
		Section_Mouse := RM_GetSection(this.Sections, R_2, X_Center, Y_Center)
		if (Section_Mouse = 0) {
			SectName := ""
		}
		this.Active := False
		Return SectName
	}
}

RM_GetSection(Sections, R_2, X_Center, Y_Center) {
	CoordMode("Mouse", "Window")
	MouseGetPos(&X_Mouse, &Y_Mouse)
	X_Rel := X_Mouse - X_Center
	Y_Rel := Y_Mouse - Y_Center
	Distance_Center := Sqrt(X_Rel * X_Rel + Y_Rel * Y_Rel)
	if (X_Rel = 0) { ; (correction to prevent X to be 0)
		X_Rel := 0.01
	}
	if (Y_Rel = 0) { ; (correction to prevent Y to be 0)
		Y_Rel := 0.01
	}
	if (Distance_Center < R_2) {
		Section_Mouse := "0"
		return Section_Mouse
	} else if (Distance_Center > R_2) {
		a := X_Rel = 0 ? (Y_Rel = 0 ? 0 : Y_Rel > 0 ? 90 : 270) : ATan(Y_Rel / X_Rel) * 57.2957795130823209 ; 180/pi
		Angle := X_Rel < 0 ? 180 + a : a < 0 ? 360 + a : a
		Section_Mouse := 1 + Round(Angle / 360 * Sections)
		if (Section_Mouse > Sections) {
			Section_Mouse := 1
		}
	}
	return Section_Mouse
}

RM_BuildRM(RM_Name) {
	global RM_File_Settings := A_ScriptDir "\RM_Settings.ini"
	Sections := IniRead(RM_File_Settings, RM_Name, "Sections", 8)
	G := Radial_Menu()
	RM_Names := [], RM_Imgs := [], RM_Scripts := []
	Loop Sections {
		RM_Names.Push(IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_Name", "Name"))
		if (RM_Names[A_Index] = "Default") {
			RM_Names[A_Index] := ""
			RM_Imgs.Push("")
			RM_Scripts.Push("")
			continue
		}
		RM_Imgs.Push(IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_img", " "))
		script := IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_Script", " ")
		script := StrReplace(script, "<br>", "`n")
		RM_Scripts.Push(script)

		G.Add(RM_Names[A_Index], RM_Imgs[A_Index], A_Index)
	}
	G.SetSections(Sections)
	Result := G.Show()
	Loop Sections {
		if (Result = RM_Names[A_Index] and RM_Scripts[A_Index] != "") {
			Script := RM_Scripts[A_Index]
			Function := RegExMatch(Script, "([^\(]*)\((.*)\)", &m) ? m[1] : ""
			Var := RegExMatch(Script, "([^\(]*)\((.*)\)", &m) ? m[2] : ""
			; TODO: dynamic call — %Function%(Var) not supported in v2
		}
	}
	return Result
}

RM_MenuSettings(RM_Name) {
	RM_File_Settings := A_ScriptDir "\RM_Settings.ini"
	Sections := IniRead(RM_File_Settings, RM_Name, "Sections", 8)
	G := Radial_Menu()
	RM_Names := [], RM_Imgs := [], RM_Scripts := []
	Loop Sections {
		RM_Names.Push(IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_Name", "Name"))
		if (RM_Names[A_Index] = "Default") {
			RM_Names[A_Index] := ""
			RM_Imgs.Push("")
			RM_Scripts.Push("")
			continue
		}
		RM_Imgs.Push(IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_img", " "))
		script := IniRead(RM_File_Settings, RM_Name, "RM_B" A_Index "_Script", " ")
		script := StrReplace(script, "<br>", "`n")
		RM_Scripts.Push(script)
		G.Add(RM_Names[A_Index], RM_Imgs[A_Index], A_Index)
	}
	G.SetSections(Sections)
	Result := G.Show()
	Loop Sections {
		if (RM_Names[A_Index] and RM_Scripts[A_Index]) {
			if (Result = RM_Names[A_Index]) {
				return RM_Scripts[A_Index]
			}
		}
	}
	return Result
}

ExitFunc(ExitReason, ExitCode) {
	global pToken
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	CraftMenu.Active := False
	return
}

Gdip_GetPointsSection(cx, cy, R_outer, R_inner, sections, offset, section_nr) {
	; Returns polygon points string for a radial menu section (pie slice shape)
	; Format: "x1,y1|x2,y2|..."
	tau := 2 * 3.141592653589793
	step := tau / sections
	startAngle := step * (section_nr - 1) + offset * 0.01
	endAngle   := step * section_nr       - offset * 0.01
	pts := ""
	; Outer arc (forward)
	steps := 8
	Loop steps + 1 {
		a := startAngle + (endAngle - startAngle) * (A_Index - 1) / steps
		pts .= (pts = "" ? "" : "|") Round(cx + R_outer * Cos(a), 2) "," Round(cy + R_outer * Sin(a), 2)
	}
	; Inner arc (backward)
	Loop steps + 1 {
		a := endAngle - (endAngle - startAngle) * (A_Index - 1) / steps
		pts .= "|" Round(cx + R_inner * Cos(a), 2) "," Round(cy + R_inner * Sin(a), 2)
	}
	Return pts
}
