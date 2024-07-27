; Trigger Status Overlay
Gui 2:Color, 0X130F13
Gui 2:+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20
WinSet, TransColor, 0X130F13
Gui 2:Font, bold cFFFFFF S9, Trebuchet MS
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT1, Quit: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT2, Flask: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT3, Move: OFF
  Gui 2:Add, Text, y+0.5 BackgroundTrans voverlayT4, Util: OFF

; Chaos Recipe Overlay
Gui Chaos:Color, 0X130F13
Gui Chaos:+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x20
WinSet, TransColor, 0X130F13
Gui Chaos:Font, bold cFFFFFF S9, Trebuchet MS
  Gui Chaos:Add, Text, Right     BackgroundTrans       cRed      , Chest: 
  Gui Chaos:Add, Text, Center w25 x+5  BackgroundTrans vGuiChaosCountChest , %GuiChaosCountChest%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cGreen      , Helmet: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountHelmet , %GuiChaosCountHelmet%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cBlue      , Boot: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountBoot   , %GuiChaosCountBoot%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cAqua      , Glove: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountGlove  , %GuiChaosCountGlove%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cOlive      , Belt: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountBelt   , %GuiChaosCountBelt%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cWhite      , Weapons: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountWeapons, %GuiChaosCountWeapons%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cPurple      , Rings: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountRings  , %GuiChaosCountRings%

  Gui Chaos:Add, Text, Right x+8 BackgroundTrans       cFuchsia      , Amulet: 
  Gui Chaos:Add, Text, Center w25 x+5 BackgroundTrans vGuiChaosCountAmulet , %GuiChaosCountAmulet%

  









IfWinExist, ahk_group POEGameGroup
{
  Rescale()
  Gui 2: Show,% "x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15 " NA"
  Gui Chaos: Show,% "x" (WR.loc.pixel.GuiChaos.X - 300) " y" WR.loc.pixel.GuiChaos.Y " NA"
  GuiUpdate()
  ToggleExist := True
}
