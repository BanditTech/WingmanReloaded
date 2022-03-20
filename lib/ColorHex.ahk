; Compare two hex colors as their R G B elements, puts all the below together
CompareHex(color1, color2, vary:=1, BGR:=0){
  If BGR
  {
    c1 := ToRGBfromBGR(color1)
    c2 := ToRGBfromBGR(color2)
  }
  Else
  {
    c1 := ToRGB(color1)
    c2 := ToRGB(color2)
  }
  Return CompareRGB(c1,c2,vary)
}
; Convert a color to a pixel findtext string
Hex2FindText(Color,vary:=0,BGR:=0,Comment:="",Width:=2,Height:=2,LR_Border:=0){
  If (Width < 1)
    Width := 1
  If (Height < 1)
    Height := 1
  bitstr := ""
  Loop % LR_Border
    bitstr .= "0"
  Loop % Width
    bitstr .= "1"
  Loop % LR_Border
    bitstr .= "0"
  endstr := bitstr
  Loop % Height - 1
  endstr .= "`n" . bitstr
  bitstr := FindText.bit2base64(endstr)
  ; Width += 2*LR_Border
  If IsObject(Color)
  {
    build := ""
    For k, v in Color
    {
      If BGR
        v := hexBGRToRGB(v)
      build .= "|<" k ">" . v . "@" . Round((100-vary)/100,2) . "$" . Width + 2 * LR_Border . "." . bitstr
    }
    Return build
  }
  Else
  {
    If BGR
      Color := hexBGRToRGB(Color)
    Return "|<" Comment ">" . Color . "@" . Round((100-vary)/100,2) . "$" . Width + 2 * LR_Border . "." . bitstr
  }
}
; Converts a hex BGR color into its R G B elements
ToRGBfromBGR(color){
  return { "b": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "r": color & 0xFF }
}
; Converts a hex RGB color into its R G B elements
ToRGB(color){
  return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
}
; Converts R G B elements back to hex
ToHex(Color){
  If IsObject(Color)
  {
    C := (Color.r & 0xFF) << 16, C |= (Color.g & 0xFF) << 8, C |= (Color.b & 0xFF)
    Return Format("0x{1:06X}",C)
  }
  Else
    Return Format("0x{1:02X}",Color)
}
; Converts a hex BGR color into RGB format or vice versa
hexBGRToRGB(color){
    b := Format("{1:02X}",(color >> 16) & 0xFF)
    g := Format("{1:02X}",(color >> 8) & 0xFF)
    r := Format("{1:02X}",color & 0xFF)
  return "0x" . r . g . b
}
; Compares two converted HEX codes as R G B within the variance range (use ToRGB to convert first)
CompareRGB(c1, c2, vary:=1){
  rdiff := Abs( c1.r - c2.r )
  gdiff := Abs( c1.g - c2.g )
  bdiff := Abs( c1.b - c2.b )
  return rdiff <= vary && gdiff <= vary && bdiff <= vary
}
ColorPercent(percent){
	Local key
  Static ColorRange := ""
  Static ColorCount := ""
  If !IsObject(ColorRange)
		ColorRange := ColorRange("0xff0000","0x00ff00")
	If !ColorCount
		ColorCount := ColorRange.Length()
  percent := percent>100?100
    :percent<1?1
    :percent
	key := percent!=1 ? Round(ColorCount * ((Percent) / 100)) : 1
  Return ColorRange[key]
}
; Gather the pixel information of an area, then average the hex values
AverageAreaColor(AreaObj){
  Static
  X1:=AreaObj.X1
  Y1:=AreaObj.Y1
  X2:=AreaObj.X2
  Y2:=AreaObj.Y2
  W := X2 - X1 +1
  H := Y2 - Y1 +1
  M_Index := W * H
  Size := Round((W * H) / 300)
  ColorList := []
  FindText.ScreenShot()
  Load_BarControl(,,1)
  ColorCount:=R_Count:=G_Count:=B_Count:=LastDisplay_LB:=EscBreak:=0
  Loop, % W
  {
    W_Index := A_Index
    Cur_X := X1 + (A_Index - 1)
    Loop, % H
    {
      Cur_Y := Y1 + (A_Index - 1)
      Temp_Hex := FindText.GetColor(Cur_X,Cur_Y)
      if !(indexOf(Temp_Hex, ColorList))
      {
        ColorCount++
        ColorList.Push(Temp_Hex)
      }
      If (A_TickCount - LastDisplay_LB > Size)
      {
        T_Index := (W_Index-1)*H + A_Index
        Percent := Round((T_Index / M_Index) * 100)
        uText := ColorCount " variations - Escape to cancel"
        Load_BarControl(Percent,uText)
        LastDisplay_LB := A_TickCount
      }
    } Until EscBreak := GetKeyState("Escape", "P")
    If EscBreak
    {
      Notify("Canceled area calculation","",3,,110)
      Load_BarControl(100,"Canceled",-1)
      Return
    }
  }
  For k, color in ColorList
  {
    Split := ToRGB(color)
    R_Count += Split.r ** 2
    G_Count += Split.g ** 2
    B_Count += Split.b ** 2
  }
  Split := {"r":Round(Sqrt(R_Count) / ColorCount),"g":Round(Sqrt(G_Count) / ColorCount),"b":Round(Sqrt(B_Count) / ColorCount)}
  Load_BarControl(100,"Done.",-1)
  Return ToHex(Split)
}
; Check if a specific hex value is part of an array within a variance and return the index
indexOfHex(var, Arr, fromIndex:=1, vary:=2){
  for index, value in Arr {
    h1 := ToRGB(value) 
    h2 := ToRGB(var) 
    if (index < fromIndex){
      Continue
    }else if (CompareRGB(h1, h2, vary)){
      return index
    }
  }
}
