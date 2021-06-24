; PanelManager - This class manages every gamestate within one place
Class PanelManager
{
  __New(){
    This.List := {}
  }
  AddPanel(Pixel){
    This.List[Pixel.Name] := Pixel
  }
  AddFailsafe(Pixel){
    This.Failsafe := Pixel
  }
  Status(ScreenShot := 1){
    Active := ""
    If ScreenShot
      ScreenShot(GameX,GameY,GameX + GameW,GameY + GameH)
    If IsObject(This.Failsafe)
    {
      If !This.Failsafe.On()
        Active .= This.Failsafe.Name
    }
    For k, Panel in This.List
    {
      If Panel.On()
        Active .= (Active != "" ? " " : "") Panel.Name
    }
    Return This.Active := (Active != "" ? Active : False)
  }
}

; PixelStatus - This class manages pixel sample and comparison
Class PixelStatus
{
  __New(Name,X,Y,Hex){
    This.Name := Name
    This.X := X
    This.Y := Y
    This.Hex := Hex
    This.Status := False
  }
  On(){
    pSample := Screenshot_GetColor(This.X,This.Y)
    Return (This.Status := (pSample = This.Hex ? True : False))
  }
}
