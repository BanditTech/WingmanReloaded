Get_DpiFactor() {
  return A_ScreenDPI=96?1:A_ScreenDPI/96
}
Scale_PositionFromDPI(val){
  dpif := Get_DpiFactor()
  If (dpif != 1)
    val := val / dpif
  Return val
}
