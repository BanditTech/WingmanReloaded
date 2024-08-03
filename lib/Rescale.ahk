; Rescale - Rescales values of the script to the user's resolution
Rescale(){
  Global GameX, GameY, GameW, GameH, Base, Globe, InvGrid, WR
  If checkActiveType()
  {
    ; Build array framework
    InvGrid:={"Corners":{"Stash":{},"Inventory":{},"VendorRec":{},"VendorOff":{},"Ritual":{}}
            ,"SlotSpacing": 2
            ,"SlotRadius": 25
            ,"Ritual":{"X":{},"Y":{}}
            ,"Stash":{"X":{},"Y":{}}
            ,"StashQuad":{"X":{},"Y":{}}
            ,"Inventory":{"X":{},"Y":{}}
            ,"VendorRec":{"X":{},"Y":{}}
            ,"VendorOff":{"X":{},"Y":{}}}
    If (FileExist(A_ScriptDir "\save\Globe.json") && VersionNumber != "")
    {
      WR_Menu("JSON","Load","Globe")
      GlobeImported := True
      Base.Globe := Array_DeepClone(Globe)
    }
    Else If (VersionNumber = "")
      GlobeImported := True
    Else
      GlobeImported := False

    WinGetPos, GameX, GameY, GameW, GameH
    If (ResolutionScale="Standard") {
      ; Item Inventory Grid
      Global InventoryGridX := [ GameX + Round(GameW/(1920/1274)), GameX + Round(GameW/(1920/1326)), GameX + Round(GameW/(1920/1379)), GameX + Round(GameW/(1920/1432)), GameX + Round(GameW/(1920/1484)), GameX + Round(GameW/(1920/1537)), GameX + Round(GameW/(1920/1590)), GameX + Round(GameW/(1920/1642)), GameX + Round(GameW/(1920/1695)), GameX + Round(GameW/(1920/1748)), GameX + Round(GameW/(1920/1800)), GameX + Round(GameW/(1920/1853)) ]
      Global InventoryGridY := [ GameY + Round(GameH/(1080/638)), GameY + Round(GameH/(1080/690)), GameY + Round(GameH/(1080/743)), GameY + Round(GameH/(1080/796)), GameY + Round(GameH/(1080/848)) ]  
      ; Globe areas
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(1920/106)) 
        Globe.Life.Y1 := GameY + Round(GameH/(1080/886))
        Globe.Life.X2 := GameX + Round(GameW/(1920/146)) 
        Globe.Life.Y2 := GameY + Round(GameH/(1080/1049))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(1920/165)) 
        Globe.ES.Y1 := GameY + Round(GameH/(1080/886))
        Globe.ES.X2 := GameX + Round(GameW/(1920/210)) 
        Globe.ES.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(1920/1720)) 
        Globe.EB.Y1 := GameY + Round(GameH/(1080/886))
        Globe.EB.X2 := GameX + Round(GameW/(1920/1800)) 
        Globe.EB.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(1920/1760)) 
        Globe.Mana.Y1 := GameY + Round(GameH/(1080/878))
        Globe.Mana.X2 := GameX + Round(GameW/(1920/1830)) 
        Globe.Mana.Y2 := GameY + Round(GameH/(1080/1060))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }
      ; Stash grid area
      ; ---Needs to be done with all aspect ratio---
      If (!StashImported)
      {

        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(1920/16))
        InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1080/127))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(1920/649))
        InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1080/759))
        ; Do the same for Inventory
        InvGrid.Corners.Inventory.X1:=GameX + Round(GameW/(1920/1270))
        InvGrid.Corners.Inventory.Y1:=GameY + Round(GameH/(1080/587))
        InvGrid.Corners.Inventory.X2:=GameX + Round(GameW/(1920/1904))
        InvGrid.Corners.Inventory.Y2:=GameY + Round(GameH/(1080/851))
        ; Area for Recieving Items
        InvGrid.Corners.VendorRec.X1:=GameX + Round(GameW/(1920/310))
        InvGrid.Corners.VendorRec.Y1:=GameY + Round(GameH/(1080/187))
        InvGrid.Corners.VendorRec.X2:=GameX + Round(GameW/(1920/943))
        InvGrid.Corners.VendorRec.Y2:=GameY + Round(GameH/(1080/451))
        ; Area for Offering Items
        InvGrid.Corners.VendorOff.X1:=GameX + Round(GameW/(1920/310))
        InvGrid.Corners.VendorOff.Y1:=GameY + Round(GameH/(1080/518))
        InvGrid.Corners.VendorOff.X2:=GameX + Round(GameW/(1920/943))
        InvGrid.Corners.VendorOff.Y2:=GameY + Round(GameH/(1080/783))
        ; Area for Ritual Items
        InvGrid.Corners.Ritual.X1:=GameX + Round(GameW/(1920/308))
        InvGrid.Corners.Ritual.Y1:=GameY + Round(GameH/(1080/268))
        InvGrid.Corners.Ritual.X2:=GameX + Round(GameW/(1920/938))
        InvGrid.Corners.Ritual.Y2:=GameY + Round(GameH/(1080/792))

        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1080/2))
      }
      ;Auto Vendor Settings
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(1920/410))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/860))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1920/1542))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1920/1658))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;Currency
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(1920/250))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1080/148))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(1920/420))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1080/148))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1920/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1920/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(1920/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(1920/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(1920/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(1920/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1920/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1920/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1920/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(1920/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1920/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(1920/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1920/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(1920/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(1920/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1920/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(1920/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1920/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1920/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1920/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(1920/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(1920/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(1920/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(1920/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(1920/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(1920/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(1920/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(1920/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(1920/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1920/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(1920/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(1920/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1920/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))

      ;Wisdom/Portal Scrolls
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1920/115))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1920/175))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1080 / 54))
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (1920 / 41))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1080 / 915))
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (1920 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1080 / 653))
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (1920 / 1583))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1080 / 36))
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (1920 / 248))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1080 / 896))
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (1920 / 670))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1080 / 125))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1920 / 618))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1920 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1920 / 466))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1080 / 736))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1080 / 605))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (1920 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1080 / 1027))
    }
    Else If (ResolutionScale="Classic") {
      ; Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(1440/794)) , Round(GameW/(1440/846)) , Round(GameW/(1440/899)) , Round(GameW/(1440/952)) , Round(GameW/(1440/1004)) , Round(GameW/(1440/1057)) , Round(GameW/(1440/1110)) , Round(GameW/(1440/1162)) , Round(GameW/(1440/1215)) , Round(GameW/(1440/1268)) , Round(GameW/(1440/1320)) , Round(GameW/(1440/1373)) ]
      Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]  
      ; Globe areas
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(1440/106)) ; left side does not require repositioning
        Globe.Life.Y1 := GameY + Round(GameH/(1080/886))
        Globe.Life.X2 := GameX + Round(GameW/(1440/146)) 
        Globe.Life.Y2 := GameY + Round(GameH/(1080/1049))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(1440/165)) 
        Globe.ES.Y1 := GameY + Round(GameH/(1080/886))
        Globe.ES.X2 := GameX + Round(GameW/(1440/210)) 
        Globe.ES.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(1440/1240)) ; Width - 200
        Globe.EB.Y1 := GameY + Round(GameH/(1080/886))
        Globe.EB.X2 := GameX + Round(GameW/(1440/1320)) ; Width - 120
        Globe.EB.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(1440/1280)) ; Width - 160
        Globe.Mana.Y1 := GameY + Round(GameH/(1080/878))
        Globe.Mana.X2 := GameX + Round(GameW/(1440/1350)) ; Width - 90
        Globe.Mana.Y2 := GameY + Round(GameH/(1080/1060))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }
      ; Stash grid area
      If (!StashImported)
      {
        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(1440/16))
        InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1080/127))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(1440/649))
        InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1080/759))

        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1080/2))
      }
      ;Auto Vendor Settings
        ;380,820
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(1440/380))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/860))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1440/1062))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1440/1178))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(1440/250))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1080/148))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(1440/420))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1080/148))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1440/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1440/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(1440/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(1440/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(1440/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(1440/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1440/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1440/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1440/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(1440/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1440/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(1440/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1440/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(1440/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(1440/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1440/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(1440/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1440/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1440/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1440/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(1440/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(1440/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(1440/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(1440/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(1440/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(1440/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(1440/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(1440/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(1440/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1440/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(1440/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(1440/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1440/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))
      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1440/125))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1440/175))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1080 / 54))
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (1440 / 41))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1080 / 915))
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (1440 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1080 / 653))
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (1440 / 1103))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1080 / 36))
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (1440 / 336))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1080 / 32))
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (1440 / 378))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1080 / 88))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1440 / 378))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1440 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1440 / 226))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (1440 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1080 / 1027))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1080 / 736))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1080 / 605))
    }
    Else If (ResolutionScale="Cinematic") {
      ; Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(2560/1914)), Round(GameW/(2560/1967)), Round(GameW/(2560/2018)), Round(GameW/(2560/2072)), Round(GameW/(2560/2125)), Round(GameW/(2560/2178)), Round(GameW/(2560/2230)), Round(GameW/(2560/2281)), Round(GameW/(2560/2336)), Round(GameW/(2560/2388)), Round(GameW/(2560/2440)), Round(GameW/(2560/2493)) ]
      Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]
      ; Globe areas
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(2560/106)) ; left side does not require repositioning
        Globe.Life.Y1 := GameY + Round(GameH/(1080/886))
        Globe.Life.X2 := GameX + Round(GameW/(2560/146)) 
        Globe.Life.Y2 := GameY + Round(GameH/(1080/1049))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(2560/165)) 
        Globe.ES.Y1 := GameY + Round(GameH/(1080/886))
        Globe.ES.X2 := GameX + Round(GameW/(2560/210)) 
        Globe.ES.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(2560/2360)) ; Width - 200
        Globe.EB.Y1 := GameY + Round(GameH/(1080/886))
        Globe.EB.X2 := GameX + Round(GameW/(2560/2440)) ; Width - 120
        Globe.EB.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(2560/2400)) ; Width - 160
        Globe.Mana.Y1 := GameY + Round(GameH/(1080/878))
        Globe.Mana.X2 := GameX + Round(GameW/(2560/2470)) ; Width - 90
        Globe.Mana.Y2 := GameY + Round(GameH/(1080/1060))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }
      ; Stash grid area
      If (!StashImported)
      {
        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(2560/16))
        InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1080/127))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(2560/649))
        InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1080/759))
        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1080/2))
      }
      ;Auto Vendor Settings
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(3440/980))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1440/1150))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(2560/2185))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(2560/2298))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(2560/250))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1080/148))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(2560/420))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1080/148))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(2560/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(2560/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(2560/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(2560/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(2560/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(2560/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(2560/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(2560/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(2560/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(2560/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(2560/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(2560/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(2560/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(2560/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(2560/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(2560/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(2560/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(2560/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(2560/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(2560/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(2560/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(2560/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(2560/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(2560/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(2560/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(2560/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(2560/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(2560/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(2560/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(2560/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(2560/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(2560/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(2560/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))
      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(2560/125))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(2560/175))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1080 / 54))
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (2560 / 41))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1080 / 915))
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (2560 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1080 / 653))
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (2560 / 2223))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1080 / 36))
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (2560 / 336))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1080 / 32))
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (2560 / 618))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1080 / 88))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (2560 / 618))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (2560 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (2560 / 786))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (2560 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1080 / 1027))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1080 / 736))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1080 / 605))
    }
    Else If (ResolutionScale="Cinematic(43:18)") {
      ; 1080 version of this aspect is 2580x1080
      ;Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(3440/2579)), Round(GameW/(3440/2649)), Round(GameW/(3440/2719)), Round(GameW/(3440/2789)), Round(GameW/(3440/2860)), Round(GameW/(3440/2930)), Round(GameW/(3440/3000)), Round(GameW/(3440/3070)), Round(GameW/(3440/3140)), Round(GameW/(3440/3211)), Round(GameW/(3440/3281)), Round(GameW/(3440/3351)) ]
      Global InventoryGridY := [ Round(GameH/(1440/851)), Round(GameH/(1440/921)), Round(GameH/(1440/992)), Round(GameH/(1440/1062)), Round(GameH/(1440/1132)) ]
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(2560/106)) ; left side does not require repositioning
        Globe.Life.Y1 := GameY + Round(GameH/(1080/886))
        Globe.Life.X2 := GameX + Round(GameW/(2560/146)) 
        Globe.Life.Y2 := GameY + Round(GameH/(1080/1049))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(2560/165)) 
        Globe.ES.Y1 := GameY + Round(GameH/(1080/886))
        Globe.ES.X2 := GameX + Round(GameW/(2560/210)) 
        Globe.ES.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(2560/2360)) ; Width - 200
        Globe.EB.Y1 := GameY + Round(GameH/(1080/886))
        Globe.EB.X2 := GameX + Round(GameW/(2560/2440)) ; Width - 120
        Globe.EB.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(2560/2400)) ; Width - 160
        Globe.Mana.Y1 := GameY + Round(GameH/(1080/878))
        Globe.Mana.X2 := GameX + Round(GameW/(2560/2470)) ; Width - 90
        Globe.Mana.Y2 := GameY + Round(GameH/(1080/1060))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }
      ; Stash grid area
      If (!StashImported)
      {
        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(3440/22))
        , InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1440/171))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(3440/864))
        , InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1440/1013))
        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1440/2))
        ; Area for Ritual Items
        InvGrid.Corners.Ritual.X1:=GameX + Round(GameW/(3440/848))
        InvGrid.Corners.Ritual.Y1:=GameY + Round(GameH/(1440/355))
        InvGrid.Corners.Ritual.X2:=GameX + Round(GameW/(3440/1692))
        InvGrid.Corners.Ritual.Y2:=GameY + Round(GameH/(1440/1058))
      }
      ;Auto Vendor Settings
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(3440/982))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1440/1157))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(3440/2934))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(3440/3090))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1440/1202))
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(3440/320))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1440/190))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(3440/560))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1440/190))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(2580/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(2580/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(2580/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(2580/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(2580/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(2580/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(2580/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(2580/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(2580/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(2580/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(2580/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(2580/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(2580/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(2580/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(2580/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(2580/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(2580/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(2580/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(2580/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(2580/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(2580/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(2580/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(2580/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(2580/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(2580/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(2580/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(2580/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(2580/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(2580/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(2580/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(2580/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(2580/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(2580/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))
      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(3440/150))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(3440/235))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1440/250))
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1440 / 72))
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (3440 / 54))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1440 / 1217))
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (3440 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1440 / 850))
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (3440 / 2991))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1440 / 47))
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (3440 / 448))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1440 / 42))
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (3440 / 1282))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1440 / 263))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (3440 / 1275))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1440 / 200))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (3440 / 365))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1440 / 90))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (3440 / 1056))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1440 / 118))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (3440 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1440 / 1370))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1440 / 980))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1440 / 750))
    }
    Else If (ResolutionScale="UltraWide") {
      ; Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(3840/3193)), Round(GameW/(3840/3246)), Round(GameW/(3840/3299)), Round(GameW/(3840/3352)), Round(GameW/(3840/3404)), Round(GameW/(3840/3457)), Round(GameW/(3840/3510)), Round(GameW/(3840/3562)), Round(GameW/(3840/3615)), Round(GameW/(3840/3668)), Round(GameW/(3840/3720)), Round(GameW/(3840/3773)) ]
      Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]  
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(3840/106)) ; left side does not require repositioning
        Globe.Life.Y1 := GameY + Round(GameH/(1080/886))
        Globe.Life.X2 := GameX + Round(GameW/(3840/146)) 
        Globe.Life.Y2 := GameY + Round(GameH/(1080/1049))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1
        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(3840/165)) 
        Globe.ES.Y1 := GameY + Round(GameH/(1080/886))
        Globe.ES.X2 := GameX + Round(GameW/(3840/210)) 
        Globe.ES.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1
        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(3840/3640)) ; Width - 200
        Globe.EB.Y1 := GameY + Round(GameH/(1080/886))
        Globe.EB.X2 := GameX + Round(GameW/(3840/3720)) ; Width - 120
        Globe.EB.Y2 := GameY + Round(GameH/(1080/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1
        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(3840/3680)) ; Width - 160
        Globe.Mana.Y1 := GameY + Round(GameH/(1080/878))
        Globe.Mana.X2 := GameX + Round(GameW/(3840/3750)) ; Width - 90
        Globe.Mana.Y2 := GameY + Round(GameH/(1080/1060))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1
        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }
      ; Stash grid area
      If (!StashImported)
      {
        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(3840/16))
        InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1080/127))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(3840/649))
        InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1080/759))
        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1080/2))
      }
      ;Auto Vendor Settings
      ;380,820
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(3840/1340))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/860))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(3840/3462))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(3840/3578))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;Currency
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(3840/250))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1080/148))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(3840/420))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1080/148))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(3840/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(3840/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(3840/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(3840/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(3840/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(3840/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(3840/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(3840/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(3840/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(3840/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(3840/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(3840/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(3840/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(3840/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(3840/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(3840/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(3840/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(3840/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(3840/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(3840/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(3840/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(3840/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(3840/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(3840/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(3840/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(3840/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(3840/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(3840/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(3840/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(3840/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(3840/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(3840/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(3840/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1080 / 54))
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (3840 / 41))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1080 / 915))
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (3840 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1080 / 653))
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (3840 / 3503))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1080 / 36))
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (3840 / 336))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1080 / 32))
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (3840 / 1578))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1080 / 88))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (3840 / 1578))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (3840 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (3840 / 1426))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (3840 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1080 / 1027))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1080 / 736))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1080 / 605))
    }
    Else If (ResolutionScale="WXGA(16:10)") {
      ; Item Inventory Grid
      Global InventoryGridX := [ GameX + Round(GameW/(1680/1051)), GameX + Round(GameW/(1680/1103)), GameX + Round(GameW/(1680/1154)), GameX + Round(GameW/(1680/1205)), GameX + Round(GameW/(1680/1256)), GameX + Round(GameW/(1680/1306)), GameX + Round(GameW/(1680/1358)), GameX + Round(GameW/(1680/1410)), GameX + Round(GameW/(1680/1461)), GameX + Round(GameW/(1680/1512)), GameX + Round(GameW/(1680/1563)), GameX + Round(GameW/(1680/1614)) ]
      Global InventoryGridY := [ GameY + Round(GameH/(1050/620)), GameY + Round(GameH/(1050/671)), GameY + Round(GameH/(1050/722)), GameY + Round(GameH/(1050/773)), GameY + Round(GameH/(1050/824)) ]  

      ; Globe areas
      If (!GlobeImported)
      {
        ; Life scan area
        Globe.Life.X1 := GameX + Round(GameW/(1680/96))
        Globe.Life.Y1 := GameY + Round(GameH/(1050/854))
        Globe.Life.X2 := GameX + Round(GameW/(1680/135))
        Globe.Life.Y2 := GameY + Round(GameH/(1050/1043))
        Globe.Life.Width := Globe.Life.X2 - Globe.Life.X1
        Globe.Life.Height := Globe.Life.Y2 - Globe.Life.Y1

        ; ES scan area
        Globe.ES.X1 := GameX + Round(GameW/(1680/116))
        Globe.ES.Y1 := GameY + Round(GameH/(1050/847))
        Globe.ES.X2 := GameX + Round(GameW/(1680/212))
        Globe.ES.Y2 := GameY + Round(GameH/(1050/1049))
        Globe.ES.Width := Globe.ES.X2 - Globe.ES.X1
        Globe.ES.Height := Globe.ES.Y2 - Globe.ES.Y1

        ; ES for Eldridtch Batterry scan area
        Globe.EB.X1 := GameX + Round(GameW/(1680/1720))
        Globe.EB.Y1 := GameY + Round(GameH/(1050/886))
        Globe.EB.X2 := GameX + Round(GameW/(1680/1800))
        Globe.EB.Y2 := GameY + Round(GameH/(1050/1064))
        Globe.EB.Width := Globe.EB.X2 - Globe.EB.X1
        Globe.EB.Height := Globe.EB.Y2 - Globe.EB.Y1

        ; Mana scan area
        Globe.Mana.X1 := GameX + Round(GameW/(1680/1541))
        Globe.Mana.Y1 := GameY + Round(GameH/(1050/848))
        Globe.Mana.X2 := GameX + Round(GameW/(1680/1594))
        Globe.Mana.Y2 := GameY + Round(GameH/(1050/1049))
        Globe.Mana.Width := Globe.Mana.X2 - Globe.Mana.X1
        Globe.Mana.Height := Globe.Mana.Y2 - Globe.Mana.Y1

        ; Set the base values for restoring default
        Base.Globe := Array_DeepClone(Globe)
      }

      ; Stash grid area
      If (!StashImported)
      {
        ; Scale the stash area automatically based on aspect ratio
        InvGrid.Corners.Stash.X1:=GameX + Round(GameW/(1680/16)), InvGrid.Corners.Stash.Y1:=GameY + Round(GameH/(1050/128))
        InvGrid.Corners.Stash.X2:=GameX + Round(GameW/(1680/650)), InvGrid.Corners.Stash.Y2:=GameY + Round(GameH/(1050/762))
        ; Give pixels for lines between slots
        InvGrid.SlotSpacing:=Round(GameH/(1050/2))
      }

      ;Auto Vendor Settings
      ;270,800
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(1680/270))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1050/855))
      
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1680/1310))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1680/1425))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1050/880))
      
      ;Currency
      ;General Button
      WR.loc.pixel.CurrencyGeneral.X:=GameX + Round(GameW/(1728/250))
      WR.loc.pixel.CurrencyGeneral.Y:=GameY + Round(GameH/(1080/148))
      ;Influence Button
      WR.loc.pixel.CurrencyInfluence.X:=GameX + Round(GameW/(1728/420))
      WR.loc.pixel.CurrencyInfluence.Y:=GameY + Round(GameH/(1080/148))
      ;Wisdom
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1728/125))
      WR.loc.pixel.Wisdom.Y:=GameY + Round(GameH/(1080/190))
      ;Portal
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1728/175))
      WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
      ; Blacksmith
      WR.loc.pixel.Blacksmith.X:=GameX + Round(GameW/(1728/380))
      WR.loc.pixel.Blacksmith.Y:=GameY + Round(GameH/(1080/202))
      ; Armourer
      WR.loc.pixel.Armourer.X:=GameX + Round(GameW/(1728/432))
      WR.loc.pixel.Armourer.Y:=GameY + Round(GameH/(1080/199))
      ; Glassblower
      WR.loc.pixel.Glassblower.X:=GameX + Round(GameW/(1728/490))
      WR.loc.pixel.Glassblower.Y:=GameY + Round(GameH/(1080/200))
      ; Gemcutter
      WR.loc.pixel.Gemcutter.X:=GameX + Round(GameW/(1728/550))
      WR.loc.pixel.Gemcutter.Y:=GameY + Round(GameH/(1080/201))
      ; Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1728/606))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/200))
      ; Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1728/53))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/272))	
      ; Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1728/113))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/272))
      ; Annulment
      WR.loc.pixel.Annulment.X:=GameX + Round(GameW/(1728/166))
      WR.loc.pixel.Annulment.Y:=GameY + Round(GameH/(1080/272))
      ; Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1728/226))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/272))
      ; Regal
      WR.loc.pixel.Regal.X:=GameX + Round(GameW/(1728/434))
      WR.loc.pixel.Regal.Y:=GameY + Round(GameH/(1080/272))
      ; Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1728/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/272))
      ; Chaos
      WR.loc.pixel.Chaos.X:=GameX + Round(GameW/(1728/548))
      WR.loc.pixel.Chaos.Y:=GameY + Round(GameH/(1080/272))
      ; Veiled
      WR.loc.pixel.Veiled.X:=GameX + Round(GameW/(1728/605))
      WR.loc.pixel.Veiled.Y:=GameY + Round(GameH/(1080/272))

      ; Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1728/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/327))
      ; Divine
      WR.loc.pixel.Divine.X:=GameX + Round(GameW/(1728/607))
      WR.loc.pixel.Divine.Y:=GameY + Round(GameH/(1080/327))

      ; Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1728/112))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/396))
      ; Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1728/167))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/396))
      ; Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1728/226))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/396))
      ; Harbinger
      WR.loc.pixel.Harbinger.X:=GameX + Round(GameW/(1728/548))
      WR.loc.pixel.Harbinger.Y:=GameY + Round(GameH/(1080/396))
      ; Horizon
      WR.loc.pixel.Horizon.X:=GameX + Round(GameW/(1728/605))
      WR.loc.pixel.Horizon.Y:=GameY + Round(GameH/(1080/396))

      ; Enkindling
      WR.loc.pixel.Enkindling.X:=GameX + Round(GameW/(1728/54))
      WR.loc.pixel.Enkindling.Y:=GameY + Round(GameH/(1080/453))
      ; Ancient
      WR.loc.pixel.Ancient.X:=GameX + Round(GameW/(1728/113))
      WR.loc.pixel.Ancient.Y:=GameY + Round(GameH/(1080/454))
      ; Binding
      WR.loc.pixel.Binding.X:=GameX + Round(GameW/(1728/168))
      WR.loc.pixel.Binding.Y:=GameY + Round(GameH/(1080/451))
      ; Engineer
      WR.loc.pixel.Engineer.X:=GameX + Round(GameW/(1728/225))
      WR.loc.pixel.Engineer.Y:=GameY + Round(GameH/(1080/451))
      ; Regret
      WR.loc.pixel.Regret.X:=GameX + Round(GameW/(1728/436))
      WR.loc.pixel.Regret.Y:=GameY + Round(GameH/(1080/451))
      ; Unmaking
      WR.loc.pixel.Unmaking.X:=GameX + Round(GameW/(1728/494))
      WR.loc.pixel.Unmaking.Y:=GameY + Round(GameH/(1080/451))

      ; Instilling
      WR.loc.pixel.Instilling.X:=GameX + Round(GameW/(1728/57))
      WR.loc.pixel.Instilling.Y:=GameY + Round(GameH/(1080/509))
      ; Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1728/435))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/508))
      ; Sacred
      WR.loc.pixel.Sacred.X:=GameX + Round(GameW/(1728/494))
      WR.loc.pixel.Sacred.Y:=GameY + Round(GameH/(1080/509))
      ; Blessed
      WR.loc.pixel.Blessed.X:=GameX + Round(GameW/(1728/550))
      WR.loc.pixel.Blessed.Y:=GameY + Round(GameH/(1080/508))
      ; Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1728/608))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/510))
      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(1680/115))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(1680/170))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1050/185))
      
      ;Status Check OnMenu
      WR.loc.pixel.OnMenu.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnMenu.Y:=GameY + Round(GameH / (1050 / 54))
      
      ;Status Check OnChar
      WR.loc.pixel.OnChar.X:=GameX + Round(GameW / (1680 / 36))
      WR.loc.pixel.OnChar.Y:=GameY + Round(GameH / ( 1050 / 920))
      
      ;Status Check OnChat
      WR.loc.pixel.OnChat.X:=GameX + Round(GameW / (1680 / 0))
      WR.loc.pixel.OnChat.Y:=GameY + Round(GameH / ( 1050 / 653))
      
      ;Status Check OnInventory
      WR.loc.pixel.OnInventory.X:=GameX + Round(GameW / (1680 / 1583))
      WR.loc.pixel.OnInventory.Y:=GameY + Round(GameH / ( 1050 / 36))
      
      ;Status Check OnStash
      WR.loc.pixel.OnStash.X:=GameX + Round(GameW / (1680 / 336))
      WR.loc.pixel.OnStash.Y:=GameY + Round(GameH / ( 1050 / 32))
      
      ;Status Check OnVendor
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (1680 / 525))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1050 / 120))
      ;Status Check OnVendorHeist
      WR.loc.pixel.OnVendorHeist.X:=GameX + Round(GameW / 2)
      WR.loc.pixel.OnVendorHeist.Y:=GameY + Round(GameH / ( 1080 / 183))
      
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1680 / 519))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1050 / 716))
      
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1680 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1050 / 57))
      
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1680 / 362))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1050 / 84))
      
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (1680 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1050 / 1000))
      
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1050 / 716))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1050 / 605))
    }

    WR.loc.pixel.GuiChaos.X:=GameX + Round(GameW/2)
    WR.loc.pixel.GuiChaos.Y:=GameY


    x_center := GameX + GameW / 2
    compensation := (GameW / GameH) == (16 / 10) ? 1.103829 : 1.103719
    Global ScrCenter := { "X" : GameX + Round(GameW / 2) , "Y" : GameY + Round(GameH / 2) ,"Yadjusted" : GameY + GameH / 2 / compensation}
    RescaleRan := True
    Global GameWindow := {"X" : GameX, "Y" : GameY, "W" : GameW, "H" : GameH, "BBarY" : (GameY + (GameH / (1080 / 75))) }
    BuildGridsFromCorners()
  }
  return
}
BuildGridsFromCorners(){
  Global InvGrid
  ; Calculate space for the Stash grid
  totalX:=InvGrid.Corners.Stash.X2 - InvGrid.Corners.Stash.X1
  , totalY:=InvGrid.Corners.Stash.Y2 - InvGrid.Corners.Stash.Y1
  ; Fill in array with grid locations for 12x12 stash
  Cnum:=Rnum:=12
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  InvGrid.SlotRadius := (Cwidth//2 + Rwidth//2) // 2
  InvGrid.SlotSize := (Cwidth + Rwidth) // 2
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.Stash.X1+Cwidth//2, PointY:=InvGrid.Corners.Stash.Y1+Rwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing, PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.Stash.X.Push(Round(PointX))
    InvGrid.Stash.Y.Push(Round(PointY))
  }
  ; Fill in array with grid locations for 24x24 stash
  Cnum:=Rnum:=24
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.Stash.X1+Cwidth//2, PointY:=InvGrid.Corners.Stash.Y1+Rwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing, PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.StashQuad.X.Push(Round(PointX))
    InvGrid.StashQuad.Y.Push(Round(PointY))
  }
  ; Calculate space for the Inventory grid
  totalX:=InvGrid.Corners.Inventory.X2 - InvGrid.Corners.Inventory.X1
  , totalY:=InvGrid.Corners.Inventory.Y2 - InvGrid.Corners.Inventory.Y1
  ; Fill in array with grid locations for 12x5 Inventory
  Cnum:=12
  Rnum:=5
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.Inventory.X1+Cwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing
    InvGrid.Inventory.X.Push(Round(PointX))
  }
  Loop, %Rnum%
  {
    If (A_Index = 1) 
      PointY:=InvGrid.Corners.Inventory.Y1+Rwidth//2
    Else
      PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.Inventory.Y.Push(Round(PointY))
  }
  ; Calculate space for the Vendor Receive grid
  totalX:=InvGrid.Corners.VendorRec.X2 - InvGrid.Corners.VendorRec.X1
  , totalY:=InvGrid.Corners.VendorRec.Y2 - InvGrid.Corners.VendorRec.Y1
  ; Fill in array with grid locations for 12x5 Receive Area
  Cnum:=12
  Rnum:=5
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.VendorRec.X1+Cwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing
    InvGrid.VendorRec.X.Push(Round(PointX))
  }
  Loop, %Rnum%
  {
    If (A_Index = 1) 
      PointY:=InvGrid.Corners.VendorRec.Y1+Rwidth//2
    Else
      PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.VendorRec.Y.Push(Round(PointY))
  }
  ; Calculate space for the Vendor Offer grid
  totalX:=InvGrid.Corners.VendorOff.X2 - InvGrid.Corners.VendorOff.X1
  , totalY:=InvGrid.Corners.VendorOff.Y2 - InvGrid.Corners.VendorOff.Y1
  ; Fill in array with grid locations for 12x5 Offer Area
  Cnum:=12
  Rnum:=5
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.VendorOff.X1+Cwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing
    InvGrid.VendorOff.X.Push(Round(PointX))
  }
  Loop, %Rnum%
  {
    If (A_Index = 1) 
      PointY:=InvGrid.Corners.VendorOff.Y1+Rwidth//2
    Else
      PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.VendorOff.Y.Push(Round(PointY))
  }
  ; Calculate space for the Vendor Offer grid
  totalX:=InvGrid.Corners.Ritual.X2 - InvGrid.Corners.Ritual.X1
  , totalY:=InvGrid.Corners.Ritual.Y2 - InvGrid.Corners.Ritual.Y1
  ; Fill in array with grid locations for 12x10 Offer Area
  Cnum:=12
  Rnum:=10
  Cwidth:=((totalX-((Cnum-1)*InvGrid.SlotSpacing))/Cnum)
  , Rwidth:=((totalY-((Rnum-1)*InvGrid.SlotSpacing))/Rnum)
  Loop, %Cnum%
  {
    If (A_Index = 1) 
      PointX:=InvGrid.Corners.Ritual.X1+Cwidth//2
    Else
      PointX+=Cwidth+InvGrid.SlotSpacing
    InvGrid.Ritual.X.Push(Round(PointX))
  }
  Loop, %Rnum%
  {
    If (A_Index = 1) 
      PointY:=InvGrid.Corners.Ritual.Y1+Rwidth//2
    Else
      PointY+=Rwidth+InvGrid.SlotSpacing
    InvGrid.Ritual.Y.Push(Round(PointY))
  }
}

FirstScale(){
  ;Begin scaling resolution values
  IfWinExist, ahk_group POEGameGroup
  {
    Rescale()
  } else {
    Global InventoryGridX := [ 1274, 1326, 1379, 1432, 1484, 1537, 1590, 1642, 1695, 1748, 1800, 1853 ]
    Global InventoryGridY := [ 638, 690, 743, 796, 848 ]

    WR.loc.pixel.DetonateDelve.X:=1542
    WR.loc.pixel.Detonate.X:=1658
    WR.loc.pixel.Detonate.Y:=901
    WR.loc.pixel.VendorAccept.X:=380
    WR.loc.pixel.VendorAccept.Y:=820
    ; Scrolls
    WR.loc.pixel.Wisdom.X:=115
    WR.loc.pixel.Portal.X:=175
    WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=190
    ; Scouring
    WR.loc.pixel.Scouring.X:=58
    WR.loc.pixel.Scouring.Y:=445
    ; Chisel
    WR.loc.pixel.Chisel.X:=605
    WR.loc.pixel.Chisel.Y:=190
    ; Alchemy
    WR.loc.pixel.Alchemy.X:=490
    WR.loc.pixel.Alchemy.Y:=260
    ; Transmutation
    WR.loc.pixel.Transmutation.X:=60
    WR.loc.pixel.Transmutation.Y:=260
    ; Augmentation
    WR.loc.pixel.Augmentation.X:=230
    WR.loc.pixel.Augmentation.Y:=310
    ; Alteration
    WR.loc.pixel.Alteration.X:=120
    WR.loc.pixel.Alteration.Y:=260
    ; Vaal
    WR.loc.pixel.Vaal.X:=230
    WR.loc.pixel.Vaal.Y:=445

    WR.loc.pixel.OnMenu.X:=960
    WR.loc.pixel.OnMenu.Y:=54
    WR.loc.pixel.OnChar.X:=41
    WR.loc.pixel.OnChar.Y:=915
    WR.loc.pixel.OnChat.X:=41
    WR.loc.pixel.OnChat.Y:=915
    WR.loc.pixel.OnInventory.X:=1583
    WR.loc.pixel.OnInventory.Y:=36
    WR.loc.pixel.OnStash.X:=336
    WR.loc.pixel.OnStash.Y:=32
    WR.loc.pixel.OnVendor.X:=618
    WR.loc.pixel.OnVendor.Y:=88
    WR.loc.pixel.OnDiv.X:=618
    WR.loc.pixel.OnDiv.Y:=135
    WR.loc.pixel.OnLeft.X:=252
    WR.loc.pixel.OnLeft.Y:=57
    WR.loc.pixel.OnDelveChart.X:=466
    WR.loc.pixel.OnDelveChart.Y:=89
    WR.loc.pixel.DivTrade.Y:=736
    WR.loc.pixel.DivItem.Y:=605
    WR.loc.pixel.DivItem.X:= WR.loc.pixel.DivTrade.X:=WR.loc.pixel.OnDiv.X

    WR.loc.pixel.Gui.X:=-10
    WR.loc.pixel.Gui.Y:=1027

    Global ScrCenter := { X : 960 , Y : 540 }
  }

}
