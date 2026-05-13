; Zoom script found on AHK forum and modified to enclose in one function - Bandit
DrawZoom( Mode := "", M_C := 0 , R_C := 0, zoom_c := 0, dc := 0)
{
  Global
  Static zoom = 6        ; initial magnification, 1..32
  , halfside = 192      ; circa halfside of the magnifier
  , part := halfside/zoom
  , L_edge := (A_ScreenWidth//2) - halfside
  , R_edge := (A_ScreenWidth//2) + halfside
  , Rz := Round(part)
  , R := Rz*zoom
  , LineMargin := 10
  , pos_old := 0
  , pos_new

  If (Mode = "Toggle")
  {
    DrawZoom_ToggleZoom()
    DrawZoom_MoveAway()
    Return
  }
  If (Mode = "Repaint")
  {
    DrawZoom_Repaint()
    Return
  }
  If (Mode = "MoveAway")
  {
    DrawZoom_MoveAway()
    Return
  }
  If (Mode = "ClearGDI")
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
  Global hdc_frame, hdd_frame, ZoomGui
  Static zoom = 6
  , halfside = 192
  , part := halfside/zoom
  , Rz := Round(part)
  , R := Rz*zoom
  , LineMargin := 10
  MouseGetPos(&x, &y)
  xz := x-Rz
  yz := y-Rz

  DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,0, Int,2*R+zoom, Int,2*R+zoom
  , UInt,hdd_frame, UInt,xz, UInt,yz, Int,2*Rz+1, Int,2*Rz+1, UInt,0xCC0020) ; SRCCOPY

  DrawZoom( "", LineMargin, R, zoom, hdc_frame )
  ; DrawZoom_MoveAway()
}

DrawZoom_MoveAway() {
  Global ZoomGui
  Static zoom = 6
  , halfside = 192
  , part := halfside/zoom
  , L_edge := (A_ScreenWidth//2) - halfside
  , R_edge := (A_ScreenWidth//2) + halfside
  , Rz := Round(part)
  , R := Rz*zoom
  , pos_old := 0
  , pos_new
  ; keep the frame outside the magnifier and precalculate wanted position
  MouseGetPos(&x, &y)
  If (x < R_edge && x > L_edge) && (y < (2*R+zoom))
    pos_new := (2*R+zoom+8)
  Else
    pos_new := 0

  if ( pos_old <> pos_new )      ; only move if the real position of window needs to change
    WinMove(,, pos_new,, "Magnifier")

  pos_old := pos_new   ; store value for next loop
}


DrawZoom_ClearGDI() {
  Global hdc_frame, hdd_frame, ZoomInitialize
  DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
  DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
  ZoomInitialize := 0
}

DrawZoom_ToggleZoom() {
  Global ZoomInitialize, hdc_frame, hdd_frame, GamePID, ZoomGui
  Static zoom = 6
  , halfside = 192
  , part := halfside/zoom
  , Rz := Round(part)
  , R := Rz*zoom
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
    ZoomGui.Show("w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside " y0 NA", "Magnifier")
    MagnifierID := WinGetID("Magnifier")
    WinSetTransparent(255, "Magnifier") ; makes the window invisible to magnification
    ; WinGet PrintSourceID, ID
    hdd_frame := DllCall("GetDC", UInt, GamePID)
    hdc_frame := DllCall("GetDC", UInt, MagnifierID)
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
  Global ZoomGui
  Static zoom = 6
  , halfside = 192
  , part := halfside/zoom
  , Rz := Round(part)
  , R := Rz*zoom
  If (zoom < 31 && A_ThisHotKey = "WheelUp" )
    zoom *= 1.189207115     ; sqrt(sqrt(2))
  Else If (zoom >  1 && A_ThisHotKey = "WheelDown")
    zoom /= 1.189207115
  Else
    Return
  part := halfside/zoom       ;new calculation of the magnified image
  Rz := Round(part)
  R := Rz*zoom
  ZoomGui.Show("w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside  " y0 NA", "Magnifier")
  DrawZoom_MoveAway()
}

PushMouse(*) {
  ;Mouse move one step with arrow keys
  If (A_ThisHotKey = "Up")
    MouseMove(0, -1, 0, "R")
  If (A_ThisHotKey = "Down")
    MouseMove(0, 1, 0, "R")
  If (A_ThisHotKey = "Left")
    MouseMove(-1, 0, 0, "R")
  If (A_ThisHotKey = "Right")
    MouseMove(1, 0, 0, "R")
  DrawZoom_MoveAway()
}
