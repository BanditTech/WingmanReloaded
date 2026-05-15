; Trigger Status Overlay
OverlayGui := Gui("+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20")
OverlayGui.BackColor := "0X130F13"
WinSetTransColor("0X130F13", OverlayGui)
OverlayGui.SetFont("bold cFFFFFF S9", "Trebuchet MS")
  OverlayGui.Add("Text", "y+0.5 BackgroundTrans voverlayT1", "Quit: OFF")
  OverlayGui.Add("Text", "y+0.5 BackgroundTrans voverlayT2", "Flask: OFF")
  OverlayGui.Add("Text", "y+0.5 BackgroundTrans voverlayT3", "Move: OFF")
  OverlayGui.Add("Text", "y+0.5 BackgroundTrans voverlayT4", "Util: OFF")

; Chaos Recipe Overlay
ChaosGui := Gui("+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20")
ChaosGui.BackColor := "0X130F13"
WinSetTransColor("0X130F13", ChaosGui)
ChaosGui.SetFont("bold cFFFFFF S9", "Trebuchet MS")
  ChaosGui.Add("Text", "Right     BackgroundTrans       cRed      ", "Chest: ")
  ChaosGui.Add("Text", "Center w25 x+5  BackgroundTrans vGuiChaosCountChest ", GuiChaosCountChest)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cGreen      ", "Helmet: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountHelmet ", GuiChaosCountHelmet)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cBlue      ", "Boot: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountBoot   ", GuiChaosCountBoot)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cAqua      ", "Glove: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountGlove  ", GuiChaosCountGlove)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cOlive      ", "Belt: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountBelt   ", GuiChaosCountBelt)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cWhite      ", "Weapons: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountWeapons", GuiChaosCountWeapons)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cPurple      ", "Rings: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountRings  ", GuiChaosCountRings)

  ChaosGui.Add("Text", "Right x+8 BackgroundTrans       cFuchsia      ", "Amulet: ")
  ChaosGui.Add("Text", "Center w25 x+5 BackgroundTrans vGuiChaosCountAmulet ", GuiChaosCountAmulet)






if WinExist("ahk_group POEGameGroup")
{
  Rescale()
  OverlayGui.Show("x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15 " NA")
  ChaosGui.Show("x" (WR.loc.pixel.GuiChaos.X - 300) " y" WR.loc.pixel.GuiChaos.Y " NA")
  GuiUpdate()
  ToggleExist := True
}
