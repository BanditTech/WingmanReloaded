/* Radial_Menu - Displays Menu encircling Mouse, which can contain icons.
; Created by ahk_user @ 2019
; Creates radial Mouse menu
; V1.00046
; Changes
; Add function accepts HBitmap or files
; Requires Gdip_GetPointsSection()
*/

Class Radial_Menu{
	static Sections, Sect_Name, Sect_Img
	__New(){
		This.Sections := "4"
		This.RM_Key := "F9"
		This.IconSize := 70
	}
	
	SetSections(Sections){
		This.Sections := Sections
	}
	SetKey(RM_Key){
		This.RM_Key := RM_Key
	}
	SetKeySpecial(RM_Key2){
		This.RM_Key2 := RM_Key2
	}
	
	Add(SectionName,SectionImg,ArcNr){
		if (This.Sections < ArcNr){
			This.Sections := ArcNr
		}
		This.Sect_Name[ArcNr] := SectionName
		This.Sect_Img[ArcNr] := SectionImg
	}
	Add2(SectionName2,SectionImg2,ArcNr){
		if (This.Sections < ArcNr){
			This.Sections := ArcNr
		}
		This.Sect_Name2[ArcNr] := SectionName2
		This.Sect_Img2[ArcNr] := SectionImg2
	}
	
	Show(){
		static
		This.Active := True
		SectName := ""
		CoordMode, Mouse, Window
		MouseGetPos, X_Center, Y_Center
		WinGetPos, X_Win, Y_Win,,, A
		R_1 := 100
		R_2 := R_1*0.2
		Offset := 2
		R_3 := R_1+Offset*2+10
		
		X_Gui := X_Center - R_3 + X_Win
		Y_Gui := Y_Center - R_3 + Y_Win
		Height_Gui := R_3*2
		Width_Gui := R_3*2
		
		Width := R_3*2
		height := R_3*2
		
		if WinExist("RM_Menu"){
			Gui, 69: Destroy
		}
		
		; Start gdi+
		If !pToken := Gdip_Startup(){
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}
		OnExit("ExitFunc")
		
		; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
		Gui, 69: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
		
		; Show the window
		Gui, 69: Show, NA x%X_Gui% y%Y_Gui% w%Width_Gui% h%Height_Gui%, RM_Menu
		
		; Get a handle to this window we have created in order to update it later
		hwnd1 := WinExist()
		
		MouseGetPos, X_Center, Y_Center
		ColorBackGround := "111111"
		ColorLineBackGround := "111111"
		ColorSelected := "222222"
		ColorLineSelected := "222222"
		
		Loop, % This.Sections { ;Setting Bitmap images of sections
			if FileExist(This.Sect_Img[A_Index]){
				pBitmap_%A_Index% := Gdip_CreateBitmapFromFile(This.Sect_Img[A_Index])
			}
			else if (This.Sect_Img[A_Index] !=""){
				pBitmap_%A_Index% := Gdip_CreateBitmapFromHBITMAP(This.Sect_Img[A_Index])
			}
			
			bWidth_%A_Index% := Gdip_GetImageWidth(pBitmap_%A_Index%)
			bHeight_%A_Index% := Gdip_GetImageHeight(pBitmap_%A_Index%)
			
			if FileExist(This.Sect_Img2[A_Index]){
				pBitmap2_%A_Index% := Gdip_CreateBitmapFromFile(This.Sect_Img2[A_Index])
			}
			else if (This.Sect_Img2[A_Index] !=""){
				pBitmap2_%A_Index% := Gdip_CreateBitmapFromHBITMAP(This.Sect_Img2[A_Index])
			}
			bWidth2_%A_Index% := Gdip_GetImageWidth(pBitmap2_%A_Index%)
			bHeight2_%A_Index% := Gdip_GetImageHeight(pBitmap2_%A_Index%)
		}
		
		Counter := 0
		loop, % This.Sections { ;Calculating Section Points
			SectionAngle := 2*3.141592653589793/This.Sections*(A_Index-1)
			
			X_Bitmap_%A_Index% := R_3+(R_1-30)*cos(SectionAngle)-8
			Y_Bitmap_%A_Index% := R_3+(R_1-30)*sin(SectionAngle)-8
			
			PointsA_%A_Index% := Gdip_GetPointsSection(R_3,R_3,R_1+Offset*2+10,R_1+Offset*2,This.Sections,Offset,A_Index)
			Points_%A_Index% := Gdip_GetPointsSection(R_3,R_3,R_1,R_2,This.Sections,Offset,A_Index)
		}
		
		; Setting brushes and Pens
		pBrush := Gdip_BrushCreateSolid("0xFF" ColorBackGround)
		pBrushA := Gdip_BrushCreateSolid("0xFF" ColorSelected)
		pBrushC := Gdip_BrushCreateSolid("0X01" ColorBackGround)
		pPen := Gdip_CreatePen("0xFF" ColorLineBackGround, 1)
		pPenA := Gdip_CreatePen("0xD2" ColorLineSelected, 1)
		
		Gdip_SetSmoothingMode(G, 4)
		
		RM_KeyState_D := 0
		Gdip_FillEllipse(G, pBrushC, R_3-R_1, R_3-R_1, 2*R_1, 2*R_1)
		
		loop, {
			RM_KeyState := GetKeyState(This.RM_Key,"P")
			RM_KeyState2 := GetKeyState(This.RM_Key2,"P")
			if !WinExist("RM_Menu"){
				Exit
			}
			if (RM_KeyState = 1){
				RM_KeyState_D := 1
			}
			if (RM_KeyState = 0 and RM_KeyState_D = 1){
				Section_Mouse := RM_GetSection(This.Sections, R_2,X_Center,Y_Center)
				if (Section_Mouse != 0){
					break
				}
				RM_KeyState_D := 0
			}
			if (GetKeyState("LButton")){
				Section_Mouse := RM_GetSection(This.Sections, R_2,X_Center,Y_Center)
				if (Section_Mouse != 0){
					break
				}
				if (Section_Mouse = 0){
					SectName := ""
					break
				}
			}
			if GetKeyState("Escape"){
				Section_Mouse := 0 
				SectName := ""
				break
			}
			
			MouseGetPos, X_Mouse, Y_Mouse
			X_Rel := X_Mouse - X_Center
			Y_Rel := Y_Mouse - Y_Center
			Center_Distance := Sqrt(X_Rel*X_Rel+Y_Rel*Y_Rel)
			
			Section_Mouse := RM_GetSection(This.Sections, R_2,X_Center,Y_Center)
			
			if (Center_Distance > R_1){
				break
			}
			if (Section_Mouse = 0){
				ToolTip
				SectName := ""
			}
			if (Section_Mouse > 0){
				Counter++
				SectName_N := This.Sect_Name[Section_Mouse]
				SectName2 := This.Sect_Name2[Section_Mouse]
				if (GetKeyState(This.RM_Key2,"P") and SectName2 !=""){
					SectName_N := This.Sect_Name2[Section_Mouse]
				}
				
				if ((X_Mouse_P != X_Mouse) or (Y_Mouse_P != Y_Mouse) or SectName_N != SectName or Counter > 500) {
					SectName := SectName_N
					CoordMode, Mouse, Window
					MouseGetPos, X_Mouse_P, Y_Mouse_P
					if (Counter > 500 or SectName_N != SectName){
						Tooltip %SectName%
						Counter := 0
					}
				}
			}
			if (Section_Mouse != Section_Mouse_Prev or A_Index = 1 or RM_KeyState2_Prev != RM_KeyState2){ ; Update GDIP   
				
				Gdip_GraphicsClear(G)
				hbm := CreateDIBSection(Width, Height) ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
				hdc := CreateCompatibleDC() ; Get a device context compatible with the screen
				obm := SelectObject(hdc, hbm) ; Select the bitmap into the device context
				G := Gdip_GraphicsFromHDC(hdc)	; Get a pointer to the graphics of the bitmap, for use with drawing functions
				
				; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
				Gdip_SetSmoothingMode(G, 4)
				Gdip_FillEllipse(G, pBrushC, R_3-R_1, R_3-R_1, 2*R_1, 2*R_1)
				
				loop, % This.Sections {
					SectionAngle := 2*3.141592653589793/This.Sections*(A_Index-1)
					if (This.Sect_Name[A_Index] = ""){
						continue
					}
					If (A_Index = Section_Mouse){
						Gdip_FillPolygon(G, pBrushA, Points_%A_Index%)
						Gdip_DrawLines(G, pPenA, Points_%A_Index%)
						Gdip_FillPolygon(G, pBrushA, PointsA_%A_Index%)
						Gdip_DrawLines(G, pPenA, PointsA_%A_Index%)
					} 
					else {
						Gdip_FillPolygon(G, pBrush, Points_%A_Index%)
						Gdip_DrawLines(G, pPen, Points_%A_Index%)
					}
					if (GetKeyState(This.RM_Key2,"P") and This.Sect_Name2[A_Index] !=""){
						Gdip_DrawImage(G, pBitmap2_%A_Index%, X_Bitmap_%A_Index%-This.IconSize//2.5, Y_Bitmap_%A_Index%-This.IconSize//2.5, This.IconSize, This.IconSize*bHeight2_%A_Index%/bWidth2_%A_Index%, 0, 0, bWidth2_%A_Index%, bHeight2_%A_Index%)
					}
					else {
						Gdip_DrawImage(G, pBitmap_%A_Index%, X_Bitmap_%A_Index%-This.IconSize//2.5, Y_Bitmap_%A_Index%-This.IconSize//2.5, This.IconSize, This.IconSize*bHeight_%A_Index%/bWidth_%A_Index%, 0, 0, bWidth_%A_Index%, bHeight_%A_Index%)
					}
					if(This.Sect_Img[A_Index]=""){
						Gdip_TextToGraphics(G, This.Sect_Name[A_Index], "vCenter x" X_Bitmap_%A_Index% -20+8 " y" Y_Bitmap_%A_Index% -20+8 , "", "40", "40")
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
		
		Tooltip
		
		SelectObject(hdc, obm) ; Select the object back into the hdc
		DeleteObject(hbm) ; Now the bitmap may be deleted
		DeleteDC(hdc) ; Also the device context related to the bitmap may be deleted
		Gdip_DeleteGraphics(G) ; The graphics may now be deleted
		
		loop, % This.Sections {
			Gdip_DisposeImage(pBitmap_%A_Index%)
			Gdip_DisposeImage(pBitmap2_%A_Index%)
		}
		
		Gdip_DeleteBrush(pBrushC)
		Gdip_DeleteBrush(pBrush)
		Gdip_DeleteBrush(pBrushA)
		Gdip_DeletePen(pPen)
		Gdip_DeletePen(pPenA)
		Gdip_Shutdown(pToken)
		Gui, 69: Destroy
		Section_Mouse := RM_GetSection(This.Sections, R_2,X_Center,Y_Center)
		if (Section_Mouse = 0){
			SectName := ""
		}
		This.Active := False
		Return % SectName
	}
}

RM_GetSection(Sections, R_2,X_Center,Y_Center){
	CoordMode, Mouse, Window
	MouseGetPos, X_Mouse, Y_Mouse
	X_Rel := X_Mouse - X_Center
	Y_Rel := Y_Mouse - Y_Center 
	Distance_Center := Sqrt(X_Rel*X_Rel+Y_Rel*Y_Rel)
	if (X_Rel = 0){ ; (correction to prevent X to be 0)
		X_Rel = 0.01
	}
	if (Y_Rel = 0){ ; (correction to prevent Y to be 0)
		Y_Rel = 0.01
	}
	if (Distance_Center < R_2){
		Section_Mouse := "0"
		return Section_Mouse
	}
	else if (Distance_Center > R_2){
		a := X_Rel = 0 ? (Y_Rel = 0 ? 0 : Y_Rel > 0 ? 90 : 270) : atan(Y_Rel/X_Rel)*57.2957795130823209 ; 180/pi
		Angle := X_Rel < 0 ? 180 + a : a < 0 ? 360 + a : a
		Section_Mouse := 1+round(Angle/360*Sections)
		if (Section_Mouse > Sections){
			Section_Mouse := 1
		}
	}
	return Section_Mouse
}

RM_BuildRM(RM_Name){
	global RM_File_Settings := A_ScriptDir "\RM_Settings.ini"
	IniRead, Sections,  %RM_File_Settings%,  %RM_Name%, Sections,  8
	loop, %Sections% {
		IniRead, RM_B%A_Index%_Name,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_Name, Name
		if (RM_B%A_Index%_Name = "Default"){
			continue
		}
		IniRead, RM_B%A_Index%_img,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_img, %A_Space%
		IniRead, RM_B%A_Index%_Script,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_Script, %A_Space%
		StringReplace, RM_B%A_Index%_Script,RM_B%A_Index%_Script,`<br`>,`n,all
		
		G.Add(RM_B%A_Index%_Name,RM_B%A_Index%_img,A_Index)
	}
	G.SetSections(Sections)
	Result := G.Show()
	loop, %Sections% {
		if (Result=RM_B%A_Index%_Name and RM_B%A_Index%_Script = != ""){
			Script := RM_B%A_Index%_Script
			Function := RegExMatch(Script,"([^\(]*)\((.*)\)","$1")
			Var := RegExMatch(Script,"([^\(]*)\((.*)\)","$1")
			%Function%(Var)
		}
	}
	return Result
}

RM_MenuSettings(RM_Name){
	RM_File_Settings :=  A_ScriptDir "\RM_Settings.ini"
	IniRead, Sections,  %RM_File_Settings%,  %RM_Name%, Sections,  8
	G := new Radial_Menu
	loop, %Sections% {
		IniRead, RM_B%A_Index%_Name,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_Name, Name
		if (RM_B%A_Index%_Name = "Default"){
			continue
		}
		IniRead, RM_B%A_Index%_img,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_img, %A_Space%
		IniRead, RM_B%A_Index%_Script,  %RM_File_Settings%,  %RM_Name%,  RM_B%A_Index%_Script, %A_Space%
		StringReplace, RM_B%A_Index%_Script,RM_B%A_Index%_Script,`<br`>,`n,all
		G.Add(RM_B%A_Index%_Name, RM_B%A_Index%_img , A_Index)
	}
	G.SetSections(Sections)
	Result := G.Show()
	loop, %Sections% {
		if (RM_B%A_Index%_Name and RM_B%A_Index%_Script){
			if (Result=RM_B%A_Index%_Name){
				return RM_B%A_Index%_Script 
				Exit
			}
		}
	}
	return Result
}

ExitFunc(){
	global
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	CraftMenu.Active := False
	return
}
