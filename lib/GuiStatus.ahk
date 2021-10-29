; GuiStatus - Determine the gamestates by checking for specific pixel colors
GuiStatus(Fetch:="",SS:=1){
  Global YesXButtonFound, OnChar, OnChat, OnMenu, OnInventory, OnStash, OnVendor, OnDiv, OnLeft, OnDelveChart, OnMetamorph, OnLocker, OnDetonate
  If (SS)
    FindText.ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH)
  If (Fetch="OnDetonate")
  {
    POnDetonateDelve := FindText.GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y), POnDetonate := FindText.GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
    , OnDetonate := ((POnDetonateDelve=varOnDetonate || POnDetonate=varOnDetonate)?True:False)
    Return OnDetonate
  }
  Else If !(Fetch="")
  {
    P%Fetch% := FindText.GetColor(WR.loc.pixel[Fetch].X,WR.loc.pixel[Fetch].Y)
    temp := %Fetch% := (P%Fetch%=var%Fetch%?True:False)
    Return temp
  }
  If (YesXButtonFound||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker)
    CheckXButton(), xChecked := True
  POnChar := FindText.GetColor(WR.loc.pixel.OnChar.X,WR.loc.pixel.OnChar.Y), OnChar := (POnChar=varOnChar?True:False)
  POnChat := FindText.GetColor(WR.loc.pixel.OnChat.X,WR.loc.pixel.OnChat.Y), OnChat := (POnChat=varOnChat?True:False)
  POnMenu := FindText.GetColor(WR.loc.pixel.OnMenu.X,WR.loc.pixel.OnMenu.Y), OnMenu := (POnMenu=varOnMenu?True:False)
  POnInventory := FindText.GetColor(WR.loc.pixel.OnInventory.X,WR.loc.pixel.OnInventory.Y), OnInventory := (POnInventory=varOnInventory?True:False)
  POnStash := FindText.GetColor(WR.loc.pixel.OnStash.X,WR.loc.pixel.OnStash.Y), OnStash := (POnStash=varOnStash?True:False)
  POnDiv := FindText.GetColor(WR.loc.pixel.OnDiv.X,WR.loc.pixel.OnDiv.Y), OnDiv := (POnDiv=varOnDiv?True:False)
  POnLeft := FindText.GetColor(WR.loc.pixel.OnLeft.X,WR.loc.pixel.OnLeft.Y), OnLeft := (POnLeft=varOnLeft?True:False)
  POnDelveChart := FindText.GetColor(WR.loc.pixel.OnDelveChart.X,WR.loc.pixel.OnDelveChart.Y), OnDelveChart := (POnDelveChart=varOnDelveChart?True:False)
  POnMetamorph := FindText.GetColor(WR.loc.pixel.OnMetamorph.X,WR.loc.pixel.OnMetamorph.Y), OnMetamorph := (POnMetamorph=varOnMetamorph?True:False)
  POnLocker := FindText.GetColor(WR.loc.pixel.OnLocker.X,WR.loc.pixel.OnLocker.Y), OnLocker := (POnLocker=varOnLocker?True:False)
  If OnMines {
    POnDetonate := FindText.GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y)
    OnDetonate := (POnDetonate=varOnDetonateDelve?True:False)
  } Else {
    POnDetonate := FindText.GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
    OnDetonate := (POnDetonate=varOnDetonate?True:False)
  } 
  If (CurrentLocation = "The Rogue Harbour") {
    POnVendor := FindText.GetColor(WR.loc.pixel.OnVendorHeist.X,WR.loc.pixel.OnVendorHeist.Y)
    OnVendor := (POnVendor=varOnVendorHeist?True:False)
  } Else {
    POnVendor := FindText.GetColor(WR.loc.pixel.OnVendor.X,WR.loc.pixel.OnVendor.Y)
    OnVendor := (POnVendor=varOnVendor?True:False)
  } 
  

  If (!xChecked && (OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker))
    CheckXButton()
  Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker||YesXButtonFound))
}
; Use saved information instead of attempting another pixel evaluation
GuiCheck(){
  Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker))
}
; CheckOHB - Determine the position of the OHB
CheckOHB()
{
  Global YesOHBFound
  If GamePID
  {
    if (ok:=FindText(GameX + Round((GameW / 2)-(OHBStrW/2) - 2), GameY + Round(GameH / (1080 / 50)), GameX + Round((GameW / 2)+(OHBStrW/2) + 2), GameY + Round(GameH / (1080 / 430)) , 0.1, 0.1, HealthBarStr,0))
    {
      YesOHBFound := True
      Return {1:ok.1.1, 2:ok.1.2, 3:ok.1.3,4:ok.1.4,"Id":ok.1.Id}
    }
    Else
    {
      Ding(500,6,"OHB Not Found")
      YesOHBFound := False
      Return False
    }
  }
  Else 
    Return False
}
CheckXButton(retObj:=0)
{
  Global YesXButtonFound
  If GamePID
  {
    If (Butt := FindText( GameX, GameY, GameX + GameW, GameY + GameH * .3, .08, .15, XButtonStr, 0 ) )
    {
      YesXButtonFound := True
      Ding(500,7,"XButton Detected")
      If retObj
        Return Butt
      Else
        Return True
    }
    Else
    {
      YesXButtonFound := False
      Return False
    }
  }
  Else
    Return False
}
; ScanGlobe - Determine the percentage of Life, ES and Mana
ScanGlobe(SS:=0)
{
  Global Globe, Player, GlobeActive
  Static OldLife := 111, OldES := 111, OldMana := 111
  If (Life := FindText(Globe.Life.X1, Globe.Life.Y1, Globe.Life.X2, Globe.Life.Y2, 0,0,Globe.Life.Color.Str,SS,1))
    Player.Percent.Life := Round(((Globe.Life.Y2 - Life.1.2) / Globe.Life.Height) * 100)
  Else
    Player.Percent.Life := -1
  If (WR.perChar.Setting.typeEldritch)
  {
    If (EB := FindText(Globe.EB.X1, Globe.EB.Y1, Globe.EB.X2, Globe.EB.Y2, 0,0,Globe.EB.Color.Str,SS,1))
      Player.Percent.ES := Round(((Globe.EB.Y2 - EB.1.2) / Globe.EB.Height) * 100)
    Else
      Player.Percent.ES := -1
  }
  Else
  {
    If (ES := FindText(Globe.ES.X1, Globe.ES.Y1, Globe.ES.X2, Globe.ES.Y2, 0,0,Globe.ES.Color.Str,SS,0))
      Player.Percent.ES := Round(((Globe.ES.Y2 - ES.1.2) / Globe.ES.Height) * 100)
    Else
      Player.Percent.ES := -1
  }
  If (Mana := FindText(Globe.Mana.X1, Globe.Mana.Y1, Globe.Mana.X2, Globe.Mana.Y2, 0,0,Globe.Mana.Color.Str,SS,1))
    Player.Percent.Mana := Round(((Globe.Mana.Y2 - Mana.1.2) / Globe.Mana.Height) * 100)
  Else
    Player.Percent.Mana := -1
  If (Player.Percent.Life != OldLife) ||  (Player.Percent.ES != OldES) || (Player.Percent.Mana != OldMana)
  {
    If (Player.Percent.Life != OldLife)
    {
      OldLife := Player.Percent.Life
      If GlobeActive
      GuiControl,Globe:, Globe_Percent_Life, % "Life " Player.Percent.Life "`%"
    }
    If (Player.Percent.ES != OldES)
    {
      OldES := Player.Percent.ES
      If GlobeActive
      GuiControl,Globe: , Globe_Percent_ES, % "ES " Player.Percent.ES "`%"
    }
    If (Player.Percent.Mana != OldMana)
    {
      OldMana := Player.Percent.Mana
      If GlobeActive
      GuiControl,Globe: , Globe_Percent_Mana, % "Mana " Player.Percent.Mana "`%"
    }
    SB_SetText("Life " Player.Percent.Life "`% ES " Player.Percent.ES "`% Mana " Player.Percent.Mana "`%",3)
  }
  Return
}
