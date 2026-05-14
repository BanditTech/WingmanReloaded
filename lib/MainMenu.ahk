; Hotkeys - Open main menu
MainMenu(){
  Global CheckGamestates
  if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    Return
  if(YesGuiLastPosition)
  {
    If (WinGuiX == "" || WinGuiY == "")
      WinGuiX := WinGuiY := 0
    MainGui.Show("Autosize x" WinGuiX " y" WinGuiY)
  }
  Else
  {
    MainGui.Show("Autosize Center")
  }
  mainmenuGameLogicState(True)
  GuiUpdate()
  CheckGamestates := True
  processWarningFound:=0
  return
}
