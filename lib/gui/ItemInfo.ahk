ItemInfoGui := Gui()
ItemInfoGui.Opt("+AlwaysOnTop -MinimizeBox")
ItemInfoGui.OnEvent("Close", ItemInfoGuiClose)
ItemInfoGui.OnEvent("Escape", ItemInfoGuiClose)
ItemInfoGui.MarginX := 10
ItemInfoGui.MarginY := 10
ItemInfoGui.SetFont("Bold s8 c4D7186", "Verdana")
ItemInfoGui.Add("GroupBox", "vGroupBox1 xm+1 y+1  h251 w554", GroupBox1)
ItemInfoGui.Add("Text", "xp+3 yp+20 Section h1 w1", "")
Loop 21 + ( Y := 15 ) - 15 ; Loop 21 times
{
  addY := y + 10
  ItemInfoGui.Add("Text", "vPercentText1G" A_Index " xs+10 y" addY " w70 h10 0x200 Right", Abs( 125 - ( Y += 10 ) ) "%")
}

ItemInfoGui.Add("Text", "x+5 ys w" (graphWidth + 2) " h" (graphHeight + 2) " 0x1000") ; SS_SUNKEN := 0x1000
graphCtrl1 := ItemInfoGui.Add("Text", "xp+1 yp+1 w" graphWidth " h" graphHeight)
hGraph1 := graphCtrl1.Hwnd
ItemInfoGui.Add("Text", "Section x+8 vPComment1", PComment1)
ItemInfoGui.Add("Text", "x+8 vPData1", PData1)
ItemInfoGui.Add("Text", "xs vPComment2", PComment2)
ItemInfoGui.Add("Text", "x+8 vPData2", PData2)
ItemInfoGui.Add("Text", "xs vPComment3", PComment3)
ItemInfoGui.Add("Text", "x+8 vPData3", PData3)
ItemInfoGui.Add("Text", "xs vPComment4", PComment4)
ItemInfoGui.Add("Text", "x+8 vPData4", PData4)
ItemInfoGui.Add("Text", "xs vPComment5", PComment5)
ItemInfoGui.Add("Text", "x+8 vPData5", PData5)
ItemInfoGui.Add("Text", "xs vPComment6", PComment6)
ItemInfoGui.Add("Text", "x+8 vPData6", PData6)
ItemInfoGui.Add("Text", "xs vPComment7", PComment7)
ItemInfoGui.Add("Text", "x+8 vPData7", PData7)
ItemInfoGui.Add("Text", "xs vPComment8", PComment8)
ItemInfoGui.Add("Text", "x+8 vPData8", PData8)
ItemInfoGui.Add("Text", "xs vPComment9", PComment9)
ItemInfoGui.Add("Text", "x+8 vPData9", PData9)
ItemInfoGui.Add("Text", "xs vPComment10", PComment10)
ItemInfoGui.Add("Text", "x+8 vPData10", PData10)

ItemInfoGui.Add("GroupBox", "vGroupBox2 x+15 ys-21  h251 w554", GroupBox2)
ItemInfoGui.Add("Text", "xp+3 ys Section h1 w1", "")
Loop 21 + ( Y := 15 ) - 15 ; Loop 21 times
{
  addY := y + 10
  ItemInfoGui.Add("Text", "vPercentText2G" A_Index " xs+10 y" addY " w70 h10 0x200 Right", Abs( 125 - ( Y += 10 ) ) "%")
}
ItemInfoGui.Add("Text", "x+5 ys w" (graphWidth + 2) " h" (graphHeight + 2) " 0x1000") ; SS_SUNKEN := 0x1000
graphCtrl2 := ItemInfoGui.Add("Text", "xp+1 yp+1 w" graphWidth " h" graphHeight)
hGraph2 := graphCtrl2.Hwnd
ItemInfoGui.Add("Text", "Section x+8 vSComment1", SComment1)
ItemInfoGui.Add("Text", "x+8 vSData1", SData1)
ItemInfoGui.Add("Text", "xs vSComment2", SComment2)
ItemInfoGui.Add("Text", "x+8 vSData2", SData2)
ItemInfoGui.Add("Text", "xs vSComment3", SComment3)
ItemInfoGui.Add("Text", "x+8 vSData3", SData3)
ItemInfoGui.Add("Text", "xs vSComment4", SComment4)
ItemInfoGui.Add("Text", "x+8 vSData4", SData4)
ItemInfoGui.Add("Text", "xs vSComment5", SComment5)
ItemInfoGui.Add("Text", "x+8 vSData5", SData5)
ItemInfoGui.Add("Text", "xs vSComment6", SComment6)
ItemInfoGui.Add("Text", "x+8 vSData6", SData6)
ItemInfoGui.Add("Text", "xs vSComment7", SComment7)
ItemInfoGui.Add("Text", "x+8 vSData7", SData7)
ItemInfoGui.Add("Text", "xs vSComment8", SComment8)
ItemInfoGui.Add("Text", "x+8 vSData8", SData8)
ItemInfoGui.Add("Text", "xs vSComment9", SComment9)
ItemInfoGui.Add("Text", "x+8 vSData9", SData9)
ItemInfoGui.Add("Text", "xs vSComment10", SComment10)
ItemInfoGui.Add("Text", "x+8 vSData10", SData10)

global hBM := CreateDIB( "E9F5F8|E9F5F8|AFAFAF|AFAFAF|E9F5F8|E9F5F8", 2, 3, graphWidth, graphHeight, 0)
global pGraph1 := XGraph( hGraph1, hBM, 21, "1,10,0,10", 0xFF0000, 2 )
global pGraph2 := XGraph( hGraph2, hBM, 21, "1,10,0,10", 0xFF0000, 2 )


ItemInfoGui.Add("GroupBox", "Section xm+1 y+30  h251 w364", "Item Properties")
ItemInfoGui.Add("Edit", "VScroll HScroll vItemInfoPropText xp+2 ys+17 w358", ItemInfoPropText)
ItemInfoGui.Add("GroupBox", "x+10 ys   h251 w364", "Item Statistics")
ItemInfoGui.Add("Edit", "VScroll HScroll vItemInfoStatText xp+2 ys+17 w358", ItemInfoStatText)
ItemInfoGui.Add("GroupBox", "x+9 ys  h251 w364", "Item Affixes")
ItemInfoGui.Add("Edit", "VScroll HScroll vItemInfoAffixText xp+2 ys+17 w358", ItemInfoAffixText)
ItemInfoGui.Add("GroupBox", "x+9 ys  h251 w364", "Item Modifiers")
ItemInfoGui.Add("Edit", "VScroll HScroll vItemInfoModifierText xp+2 ys+17 w358", ItemInfoModifierText)

ItemInfoGuiClose(*)
{
  ItemInfoGui.Hide()
}
