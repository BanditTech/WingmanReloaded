; Zoom script found on AHK forum and modified to enclose in one function - Bandit
DrawZoom( Switch := "", M_C := 0 , R_C := 0, zoom_c := 0, dc := 0)
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

  If (Switch = "Toggle")
  {
    Gosub, ToggleZoom
    Gosub, MoveAway
    Return
  }
  If (Switch = "Repaint")
  {
    Gosub, Repaint
    Return
  }
  If (Switch = "MoveAway")
  {
    Gosub, MoveAway
    Return
  }
  If (Switch = "ClearGDI")
  {
    Gosub, ClearGDI
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

  Repaint:
    MouseGetPos x, y
    xz := x-Rz
    yz := y-Rz

    DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,0, Int,2*R+zoom, Int,2*R+zoom
    , UInt,hdd_frame, UInt,xz, UInt,yz, Int,2*Rz+1, Int,2*Rz+1, UInt,0xCC0020) ; SRCCOPY
    
    DrawZoom( "", LineMargin, R, zoom, hdc_frame )
    ; Gosub, MoveAway
  Return

  MoveAway:
    ; keep the frame outside the magnifier and precalculate wanted position
    If (x < R_edge && x > L_edge) && (y < (2*R+zoom))
      pos_new := (2*R+zoom+8)
    Else
      pos_new := 0

    if ( pos_old <> pos_new )      ; only move if the real position of window needs to change
      WinMove Magnifier,, ,pos_new
    
    pos_old := pos_new   ; store value for next loop
  Return


  ClearGDI:
    DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
    DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
    ZoomInitialize := 0
  Return

  ToggleZoom:
    If ZoomInitialize
    {
      Gosub, ClearGDI
      SetTimer Repaint, Off   ; flow through
      Hotkey, WheelUp, ZoomAdjust, Off
      Hotkey, WheelDown, ZoomAdjust, Off
      Hotkey, Up, PushMouse, Off
      Hotkey, Down, PushMouse, Off
      Hotkey, Left, PushMouse, Off
      Hotkey, Right, PushMouse, Off
      Gui, Zoom: destroy
    }
    Else
    {
      ZoomInitialize := 1
      Gui Zoom:+AlwaysOnTop -Caption -Resize +ToolWindow +E0x80020
      Gui Zoom:Show, % "w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside " y0 NA", Magnifier
      WinGet MagnifierID, id,  Magnifier
      WinSet Transparent, 255, Magnifier ; makes the window invisible to magnification
      ; WinGet PrintSourceID, ID
      hdd_frame := DllCall("GetDC", UInt, GamePID)
      hdc_frame := DllCall("GetDC", UInt, MagnifierID)
      Hotkey, IfWinActive
      Hotkey, Up, PushMouse, On
      Hotkey, Down, PushMouse, On
      Hotkey, Left, PushMouse, On
      Hotkey, Right, PushMouse, On
      Hotkey, WheelUp, ZoomAdjust, On
      Hotkey, WheelDown, ZoomAdjust, On
      SetTimer Repaint, 50   ; flow through
    }
  Return

  ZoomAdjust:
    If (zoom < 31 && A_ThisHotKey = "WheelUp" )
      zoom *= 1.189207115     ; sqrt(sqrt(2))
    Else If (zoom >  1 && A_ThisHotKey = "WheelDown")
      zoom /= 1.189207115
    Else
      Return
    part := halfside/zoom       ;new calculation of the magnified image
    Rz := Round(part)
    R := Rz*zoom
    Gui Zoom:Show, % "w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside  " y0 NA", Magnifier
    Gosub, MoveAway
  Return

  PushMouse:
    ;Mouse move one step with arrow keys
    If (A_ThisHotKey = "Up")
      MouseMove, 0, -1, 0, R
    If (A_ThisHotKey = "Down")
      MouseMove, 0, 1, 0, R
    If (A_ThisHotKey = "Left")
      MouseMove, -1, 0, 0, R
    If (A_ThisHotKey = "Right")
      MouseMove, 1, 0, 0, R
    Gosub, MoveAway
  Return
}
