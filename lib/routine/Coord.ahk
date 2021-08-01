; Coord - : Pixel information on Mouse Cursor, provides pixel location and RGB color hex
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Coord(){
	Global Picker
	CoordCommand:
	Rect := LetUserSelectRect(1)
	If (Rect)
	{
		If (Rect.X1 > Rect.X2) {
			swap := Rect.X1
			Rect.X1 := Rect.X2
			Rect.X2 := swap
		}
		If (Rect.Y1 > Rect.Y2) {
			swap := Rect.Y1
			Rect.Y1 := Rect.Y2
			Rect.Y2 := swap
		}
		T1 := A_TickCount
		Ding(10000,-11,"Building an average of area colors`nThis may take some time, press escape to skip calculation.")
		AvgColor := AverageAreaColor(Rect)
		Ding(100,-11,"")
		Clipboard := "Average Color of Area:  " AvgColor "`n`n" "X1:" Rect.X1 "`tY1:" Rect.Y1 "`tX2:" Rect.X2 "`tY2:" Rect.Y2 "`nWidth: " Rect.X2-Rect.X1+1 "`tHeight: " Rect.Y2-Rect.Y1+1
		Notify(Clipboard, "`nThis information has been placed in the clipboard`nCalculation Took " (T1 := A_TickCount - T1) " MS for " (T_Area := ((Rect.X2 - Rect.X1 + 1) * (Rect.Y2 - Rect.Y1 + 1))) " Pixels`n" Round(T1 / T_Area,3) " MS per pixel",5)
		Picker.SetColor(AvgColor)
	}
	Else 
		Ding(3000,-11,Clipboard "`nColor and Location copied to Clipboard")
	Return
}
