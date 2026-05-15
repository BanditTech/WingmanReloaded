; Zoom script found on AHK forum and modified to enclose in one function - Bandit

; Shared state for all DrawZoom functions — initialized once at script load
Global DZ_zoom := 6        ; initial magnification, 1..32
Global DZ_halfside := 192  ; circa halfside of the magnifier
Global DZ_part := DZ_halfside / DZ_zoom
Global DZ_L_edge := (A_ScreenWidth//2) - DZ_halfside
Global DZ_R_edge := (A_ScreenWidth//2) + DZ_halfside
Global DZ_Rz := Round(DZ_part)
Global DZ_R := DZ_Rz * DZ_zoom
Global DZ_LineMargin := 10
Global DZ_pos_old := 0
Global DZ_pos_new := ""

DrawZoom( Mode := "", M_C := 0 , R_C := 0, zoom_c := 0, dc := 0)
{
  If (Mode == "Toggle")
  {
    DrawZoom_ToggleZoom()
    DrawZoom_MoveAway()
    Return
  }
  If (Mode == "Repaint")
  {
    DrawZoom_Repaint()
    Return
  }
  If (Mode == "MoveAway")
  {
    DrawZoom_MoveAway()
    Return
  }
  If (Mode == "ClearGDI")
  {
    DrawZoom_ClearGDI()
    Return
  }

  ;specify the style, thickness and color of the cross lines
  h_pen := DllCall( "gdi32.dll\CreatePen", "int", 0, "int", 1, "uint", 0x0000FF)
  ;select the correct pen into DC
  DllCall( "gdi32.dll\SelectObject", "uint", dc, "uint", h_pen )
  ;update the current position to specified point - 1st horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", M_C, "int", R_C, "uint", 0)
  ;draw a line from the current position up to, but not including, the specified point.
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C)
  ; 2nd horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", M_C, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C+zoom_c)
  ; 3rd horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", 2*R_C+zoom_c-M_C, "int", R_C)
  ; 4th horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", 2*R_C+zoom_c-M_C, "int", R_C+zoom_c)
  ; 1st vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C, "int", M_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C)
  ; 2nd vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", M_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C+zoom_c, "int", R_C)
  ; 3rd vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", 2*R_C+zoom_c-M_C)
  ; 4th vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C+zoom_c, "int", 2*R_C+zoom_c-M_C)
  Return
}

DrawZoom_Repaint() {
  Global hdc_frame, hdd_frame, ZoomGui, DZ_zoom, DZ_Rz, DZ_R, DZ_LineMargin
  MouseGetPos(&x, &y)
  xz := x - DZ_Rz
  yz := y - DZ_Rz

  DllCall("gdi32.dll\StretchBlt", "UInt",hdc_frame, "Int",0, "Int",0, "Int",2*DZ_R+DZ_zoom, "Int",2*DZ_R+DZ_zoom
  , "UInt",hdd_frame, "UInt",xz, "UInt",yz, "Int",2*DZ_Rz+1, "Int",2*DZ_Rz+1, "UInt",0xCC0020) ; SRCCOPY

  DrawZoom( "", DZ_LineMargin, DZ_R, DZ_zoom, hdc_frame )
  ; DrawZoom_MoveAway()
}

DrawZoom_MoveAway() {
  Global ZoomGui, DZ_zoom, DZ_halfside, DZ_L_edge, DZ_R_edge, DZ_Rz, DZ_R, DZ_pos_old, DZ_pos_new
  ; keep the frame outside the magnifier and precalculate wanted position
  MouseGetPos(&x, &y)
  If (x < DZ_R_edge && x > DZ_L_edge) && (y < (2*DZ_R+DZ_zoom))
    DZ_pos_new := (2*DZ_R+DZ_zoom+8)
  Else
    DZ_pos_new := 0

  if ( DZ_pos_old != DZ_pos_new )      ; only move if the real position of window needs to change
    WinMove(,, DZ_pos_new,, "Magnifier")

  DZ_pos_old := DZ_pos_new   ; store value for next loop
}


DrawZoom_ClearGDI() {
  Global hdc_frame, hdd_frame, ZoomInitialize
  DllCall("gdi32.dll\DeleteDC", "UInt",hdc_frame )
  DllCall("gdi32.dll\DeleteDC", "UInt",hdd_frame )
  ZoomInitialize := 0
}

DrawZoom_ToggleZoom() {
  Global ZoomInitialize, hdc_frame, hdd_frame, GamePID, ZoomGui
  Global DZ_zoom, DZ_halfside, DZ_Rz, DZ_R
  If ZoomInitialize
  {
    DrawZoom_ClearGDI()
    SetTimer(DrawZoom_Repaint, 0)   ; flow through
    Hotkey("WheelUp", "ZoomAdjust", "Off")
    Hotkey("WheelDown", "ZoomAdjust", "Off")
    Hotkey("Up", "PushMouse", "Off")
    Hotkey("Down", "PushMouse", "Off")
    Hotkey("Left", "PushMouse", "Off")
    Hotkey("Right", "PushMouse", "Off")
    ZoomGui.Destroy()
  }
  Else
  {
    ZoomInitialize := 1
    ZoomGui := Gui("+AlwaysOnTop -Caption -Resize +ToolWindow +E0x80020")
    ZoomGui.Show("w" 2*DZ_R+DZ_zoom+0 " h" 2*DZ_R+DZ_zoom+0 " x" A_ScreenWidth//2 - DZ_halfside " y0 NA", "Magnifier")
    MagnifierID := WinGetID("Magnifier")
    WinSetTransparent(255, "Magnifier") ; makes the window invisible to magnification
    hdd_frame := DllCall("GetDC", "UInt", GamePID)
    hdc_frame := DllCall("GetDC", "UInt", MagnifierID)
    Hotkey("IfWinActive")
    Hotkey("Up", "PushMouse", "On")
    Hotkey("Down", "PushMouse", "On")
    Hotkey("Left", "PushMouse", "On")
    Hotkey("Right", "PushMouse", "On")
    Hotkey("WheelUp", "ZoomAdjust", "On")
    Hotkey("WheelDown", "ZoomAdjust", "On")
    SetTimer(DrawZoom_Repaint, 50)   ; flow through
  }
}

ZoomAdjust(*) {
  Global ZoomGui, DZ_zoom, DZ_halfside, DZ_part, DZ_Rz, DZ_R
  If (DZ_zoom < 31 && A_ThisHotKey == "WheelUp" )
    DZ_zoom *= 1.189207115     ; sqrt(sqrt(2))
  Else If (DZ_zoom >  1 && A_ThisHotKey == "WheelDown")
    DZ_zoom /= 1.189207115
  Else
    Return
  DZ_part := DZ_halfside / DZ_zoom       ;new calculation of the magnified image
  DZ_Rz := Round(DZ_part)
  DZ_R := DZ_Rz * DZ_zoom
  ZoomGui.Show("w" 2*DZ_R+DZ_zoom+0 " h" 2*DZ_R+DZ_zoom+0 " x" A_ScreenWidth//2 - DZ_halfside  " y0 NA", "Magnifier")
  DrawZoom_MoveAway()
}

PushMouse(*) {
  ;Mouse move one step with arrow keys
  If (A_ThisHotKey == "Up")
    MouseMove(0, -1, 0, "R")
  If (A_ThisHotKey == "Down")
    MouseMove(0, 1, 0, "R")
  If (A_ThisHotKey == "Left")
    MouseMove(-1, 0, 0, "R")
  If (A_ThisHotKey == "Right")
    MouseMove(1, 0, 0, "R")
  DrawZoom_MoveAway()
}
