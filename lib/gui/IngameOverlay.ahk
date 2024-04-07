Gui 2:Color, 0X130F13
Gui 2:+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20
WinSet, TransColor, 0X130F13
Gui 2:Font, bold cFFFFFF S9, Trebuchet MS
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT1, Quit: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT2, Flask: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT3, Move: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT4, Util: OFF

IfWinExist, ahk_group POEGameGroup
{
  Rescale()
  Gui 2: Show,% "x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15 " NA"
  GuiUpdate()
  ToggleExist := True
}
