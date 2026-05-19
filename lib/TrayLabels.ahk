; Tray Labels
WINSPY(*) {
  SplitPath(A_AhkPath, , &AHKDIR)
  Run(AHKDIR "\WindowSpy.ahk")
}
RELOAD(*) {
  Reload()
}
QuitNow(*) {
  ExitApp()
}
