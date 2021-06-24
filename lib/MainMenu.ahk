; Hotkeys - Open main menu
MainMenu(){
  global
  if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    Return
  if(YesGuiLastPosition)
  {
    If (WinGuiX = "" || WinGuiY = "")
      WinGuiX := WinGuiY := 0
    Gui, 1: Show, Autosize x%WinGuiX% y%WinGuiY%,   WingmanReloaded
  }
  Else
  {
    Gui, 1: Show, Autosize Center,   WingmanReloaded
  }
  mainmenuGameLogicState(True)
  GuiUpdate()
  CheckGamestates := True
  processWarningFound:=0
  return
}
