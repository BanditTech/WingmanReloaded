/*** Wingman Functions
*  Contains all the assorted functions written for Wingman
*/
; PoE Click v1.0.1 : Developed by Bandit
  ; SwiftClick - Left Click at Coord with no wait between up and down
  SwiftClick(x, y){
    Log("SwiftClick: " x ", " y)
    MouseMove, x, y  
    Sleep, 30+(ClickLatency*15)
    Send {Click}
    Sleep, 30+(ClickLatency*15)
    return
  }
  ; LeftClick - Left Click at Coord
  LeftClick(x, y){
    Log("LeftClick: " x ", " y)
    BlockInput, MouseMove
    MouseMove, x, y
    Sleep, 60+(ClickLatency*15)
    Send {Click}
    Sleep, 60+(ClickLatency*15)
    BlockInput, MouseMoveOff
    Return
  }
  ; RightClick - Right Click at Coord
  RightClick(x, y){
    Log("RightClick: " x ", " y)
    BlockInput, MouseMove
    MouseMove, x, y
    Sleep, 60+(ClickLatency*15)
    Send {Click, Right}
    Sleep, 60+(ClickLatency*15)
    BlockInput, MouseMoveOff
    Return
  }
  ; ShiftClick - Shift Click +Click at Coord
  ShiftClick(x, y){
    Log("ShiftClick: " x ", " y)
    BlockInput, MouseMove
    MouseMove, x, y
    Sleep, 60+(ClickLatency*15)
    Send {Shift Down}
    Sleep, 30*Latency
    Send {Click, Down, x, y}
    Sleep, 60+(ClickLatency*15)
    Send {Click, Up, x, y}
    Sleep, 30*Latency
    Send {Shift Up}
    Sleep, 30*Latency
    BlockInput, MouseMoveOff
    return
  }
  ; CtrlClick - Ctrl Click ^Click at Coord
  CtrlClick(x, y){
    Log("CtrlClick: " x ", " y)
    BlockInput, MouseMove
    MouseMove, x, y
    Sleep, 30+(ClickLatency*15)
    Send {Ctrl Down}
    Sleep, 45
    Send {Click, Down, x, y}
    Sleep, 60+(ClickLatency*15)
    Send {Click, Up, x, y}
    Sleep, 30
    Send {Ctrl Up}
    Sleep, 30+(ClickLatency*15)
    BlockInput, MouseMoveOff
    return
  }
  ; CtrlShiftClick - Ctrl + Shift Click +^Click at Coord
  CtrlShiftClick(x, y){
    Log("CtrlShiftClick: " x ", " y)
    BlockInput, MouseMove
    MouseMove, x, y
    Sleep, 30+(ClickLatency*15)
    Send {Ctrl Down}{Shift Down}
    Sleep, 45
    Send {Click, Down, x, y}
    Sleep, 60+(ClickLatency*15)
    Send {Click, Up, x, y}
    Sleep, 30
    Send {Ctrl Up}{Shift Up}
    Sleep, 30+(ClickLatency*15)
    BlockInput, MouseMoveOff
    return
  }
  ; RandClick - Randomize Click area around middle of cell using Coord
  RandClick(x, y){
    Random, Rx, x+10, x+30
    Random, Ry, y-30, y-10
    If DebugMessages
      Log("Randomize: " x ", " y " position to " Rx ", " Ry )
    return {"X": Rx, "Y": Ry}
  }
  ; WisdomScroll - Identify Item at Coord
  WisdomScroll(x, y){
    Log("WisdomScroll: " x ", " y)
    BlockInput, MouseMove
    RightClick(WisdomScrollX,WisdomScrollY)
    Sleep, 30+Abs(ClickLatency*15)
    LeftClick(x,y)
    Sleep, 45+Abs(ClickLatency*15)
    BlockInput, MouseMoveOff
    return
  }
    ; WisdomScroll - Identify Item at Coord

; ItemScan - Parse data from Cliboard Text into Prop and Affix values
  class ItemScan
  {
    __New(){
      This.Data := {}
      This.Data.ClipContents := RegExReplace(Clip_Contents, "<<.*?>>|<.*?>") ; Clipboard
      This.Data.Sections := StrSplit(This.Data.ClipContents, "`r`n--------`r`n")
      This.Data.Blocks := {}
      This.Pseudo := OrderedArray()
      This.Affix := OrderedArray()
      This.Prop := OrderedArray()
      This.Modifier := OrderedArray()
      ; Split our sections from the clipboard
      ; NamePlate, Affix, FlavorText, Enchant, Implicit, Influence, Corrupted
      For SectionKey, SVal in This.Data.Sections
      {
        If ((SVal ~= ":" || SVal ~= "Currently has \d+ Charges") && !(SVal ~= "grant:") && !(SVal ~= "slot:"))
        {
          If (SectionKey = 1 && SVal ~= "Rarity:")
            This.Data.Blocks.NamePlate := SVal, This.Prop.IsItem := true
          Else If (SVal ~= "{ Prefix" || SVal ~= "{ Suffix")
            This.Data.Blocks.Affix := SVal
          Else If (SVal ~= " \(enchant\)$")
            This.Data.Blocks.Enchant := SVal
          Else If (SVal ~= "Open Rooms:"){
            temp := StrSplit(SVal,"Obstructed Rooms:")
            This.Data.Blocks.TempleRooms := StrSplit(temp.1,"Open Rooms:").2
            This.Data.Blocks.ObstructedRooms := RegExReplace(temp.2, "$", " (Obstructed)")
          }
          Else
            This.Data.Blocks.Properties .= SVal "`r`n"
        }
        Else 
        {
          If (SVal ~= "\.$" || SVal ~= "\?$" || SVal ~= """$")
            This.Data.Blocks.FlavorText := SVal
          Else If (SVal ~= "\(implicit\)$")
            This.Data.Blocks.Implicit := SVal
          Else If (SVal ~= "Adds \d{1,} Passive Skills (enchant)")
            This.Data.Blocks.ClusterImplicit := SVal
          Else If (SVal ~= "\(enchant\)$")
            This.Data.Blocks.Enchant := SVal
          Else If (SVal ~= " Item$") && !(SVal ~= "\w{1,} \w{1,} \w{1,} Item$")
            This.Data.Blocks.Influence := SVal
          Else If (SVal ~= "^Corrupted$")
            This.Prop.Corrupted := True
          Else If (SVal ~= "^Abyss$")
            This.Prop.IsAbyss := True
          Else If (SVal ~= "^Unidentified$")
            This.Data.Blocks.Affix := SVal
          Else If (This.Data.Blocks.HasKey("Affix") || SVal ~= """.*""$")
            This.Data.Blocks.FlavorText := SVal
          Else
            This.Data.Blocks.Affix := SVal
        }
      }
        This.Data.Sections := ""
        This.Data.Delete("Sections")

      This.MatchAffixesWithoutDoubleMods(This.Data.Blocks.Affix)
      ;This.MatchAffixes(This.Data.Blocks.Affix)
      This.MatchAffixes(This.Data.Blocks.Enchant)
      This.MatchAffixes(This.Data.Blocks.Implicit)
      This.MatchAffixes(This.Data.Blocks.Influence)
      This.MatchAffixes(This.Data.Blocks.TempleRooms)
      This.MatchAffixes(This.Data.Blocks.ObstructedRooms)
      This.MatchAffixes(This.Data.Blocks.ClusterImplicit)
      This.MatchProperties()
      If (This.Prop.Rarity_Digit == 4 && !This.Affix["Unidentified"])
        This.ApproximatePerfection()
      This.MatchPseudoAffix()
      This.MatchExtenalDB()
      This.MatchCraftingBases()
      This.MatchBase2Slot()
      This.MatchChaosRegal()
      This.Prop.StashChaosItem := This.StashChaosRecipe(False)
      If (This.Prop.Rarity_Digit = 3 && !This.Affix.Unidentified && (StashTabYesPredictive && YesPredictivePrice != "Off")  ){
        This.Prop.PredictPrice := This.PredictPrice()
      }
      This.Prop.StashReturnVal := This.MatchStashManagement(false)
      ; This.FuckingSugoiFreeMate()
    }
    ; PredictPrice - Evaluate results from TradeFunc_DoPoePricesRequest
    PredictPrice(Switch:="")
    {
      Static ItemList := []
      Static WarnedError := 0
      FoundMatch := False
      If (This.Prop.Rarity_Digit != 3 || This.Affix.Unidentified)
        Return 0
      If (This.Prop.Rarity_Digit = 3 && (!This.Prop.SpecialType || This.Prop.SpecialType = "6Link" || This.Prop.SpecialType = "5Link") && YesPredictivePrice != "Off" )
      {
        For k, obj in ItemList
        {
          If (obj.Clip_Contents = Clip_Contents)
          {
            FoundMatch := True
            PriceObj := obj
            Break
          }
        }
        If !FoundMatch
        {
          PriceObj := TradeFunc_DoPoePricesRequest(Clip_Contents, "")
          if (PriceObj.error)
          {
            If (A_TickCount - WarnedError > 30000 )
            {
              Notify(PriceObj.error_msg, "", 10)
              WarnedError := A_TickCount
            }
            return
          }
          PriceObj.Clip_Contents := Clip_Contents
          If (YesPredictivePrice = "Low")
            Price := SelectedPrice := PriceObj.min
          Else If (YesPredictivePrice = "Avg")
            Price := SelectedPrice := (PriceObj.min + PriceObj.max) / 2
          Else If (YesPredictivePrice = "High")
            Price := SelectedPrice := PriceObj.max

          Price := Price * (YesPredictivePrice_Percent_Val / 100)
          PriceObj.Avg := (PriceObj.min + PriceObj.max) / 2
          PriceObj.Price := Price

          tt := "Priced using Machine Learning`n" Format("{1:0.3g}", PriceObj.min) " <<  " Format("{1:0.3g}", PriceObj.Avg ) "  >> " Format("{1:0.3g}", PriceObj.max) " @ " PriceObj.currency
            . "`nSelected Price: " YesPredictivePrice " (" Format("{1:0.3g}", SelectedPrice) ") " " multiplied by " YesPredictivePrice_Percent_Val "`%`nAffixes Influencing Price:"
          For k, reason in PriceObj.pred_explanation
            tt .= "`n" Round(reason.2 * 100) "`% " reason.1
          tt.= "`nEnd Of Predicive Price Information"
          PriceObj.tt := tt
          ItemList.Push(PriceObj)
        }
      }
      Else
        Return "000"

      If !(PriceObj.max > 0)
        Return "0000"

      If (Switch = "Obj")
        Return PriceObj
      Else
        Return PriceObj.Price
    }
    MatchProperties(){
      ;Get total count of affixes
      This.Prop.AffixCount := 0
      This.Prop.PrefixCount := 0
      This.Prop.SuffixCount := 0
      This.Data.AffixNames := {Prefix:[],Suffix:[]}
      For k, v in StrSplit(This.Data.Blocks.Affix, "`n", "`r")
      {
        If (v = "")
        Continue
        ; Flag curse on hit items
        If (v ~= "^Curse Enemies with .+ on Hit$")
          This.Prop.IsCurseOnHit := True
        If (v ~= "\{ Prefix Modifier"){
          If RegExMatch(v, "\{ Prefix Modifier ""(.+)"" \(Tier: (\d+)\) ?.? ?(.*) \}", rxm ) {
            This.Data.AffixNames.Prefix.Push({Name:rxm1,Tier:rxm2,Tags:(rxm3?rxm3:"")})
            This.Affix[rxm1] := This.Modifier[rxm1] := 1
          } Else If RegExMatch(v, "\{ Prefix Modifier ""(.+)"" . (.*) \}", rxm ) {
            This.Data.AffixNames.Prefix.Push({Name:rxm1,Tier:1,Tags:(rxm2?rxm2:"")})
            This.Affix[rxm1] := This.Modifier[rxm1] := 1
          }
          This.Prop.PrefixCount++, This.Prop.AffixCount++
        } Else If (v ~= "\{ Suffix Modifier") {
          If RegExMatch(v, "\{ Suffix Modifier ""(.+)"" \(Tier: (\d+)\) ?.? ?(.*) \}", rxm ) {
            This.Data.AffixNames.Suffix.Push({Name:rxm1,Tier:rxm2,Tags:(rxm3?rxm3:"")})
            This.Affix[rxm1] := This.Modifier[rxm1] := 1
          } Else If RegExMatch(v, "\{ Suffix Modifier ""(.+)"" . (.*) \}", rxm ) {
            This.Data.AffixNames.Suffix.Push({Name:rxm1,Tier:1,Tags:(rxm2?rxm2:"")})
            This.Affix[rxm1] := This.Modifier[rxm1] := 1
          }
          This.Prop.SuffixCount++, This.Prop.AffixCount++
        }
      }
      This.Prop.OpenAffix := 6 - This.Prop.PrefixCount - This.Prop.SuffixCount

      ;Start NamePlate Parser
      If RegExMatch(This.Data.Blocks.NamePlate, "`am)Rarity: (.+)", RxMatch)
      {
        This.Prop.Rarity := RxMatch1
        If RegExMatch(This.Data.Blocks.NamePlate, "`am)Item Class: (.+)", RxMatch)
          This.Prop.ItemClass := RxMatch1
        ;Prop Rarity Comparator
        If (InStr(This.Prop.Rarity, "Currency"))
        {
          This.Prop.RarityCurrency := True
        }
        Else If (InStr(This.Prop.Rarity, "Divination Card"))
        {
          This.Prop.RarityDivination := True
          This.Prop.SpecialType := "Divination Card"
        }
        Else If (InStr(This.Prop.Rarity, "Gem"))
        {
          This.Prop.RarityGem := True
          This.Prop.SpecialType := "Gem"
        }
        Else If (InStr(This.Prop.Rarity, "Normal"))
        {
          This.Prop.RarityNormal := True
          This.Prop.Rarity_Digit := 1
        }
        Else If (InStr(This.Prop.Rarity, "Magic"))
        {
          This.Prop.RarityMagic := True
          This.Prop.Rarity_Digit := 2
        }
        Else If (InStr(This.Prop.Rarity, "Rare"))
        {
          This.Prop.RarityRare := True
          This.Prop.Rarity_Digit := 3
        }
        Else If (InStr(This.Prop.Rarity, "Unique"))
        {
          This.Prop.RarityUnique := True
          This.Prop.Rarity_Digit := 4
        }
        ; Fail Safe in case nothing match, to avoid auto-sell
        Else
        {
          This.Prop.SpecialType := This.Prop.Rarity
        }
        If (This.Prop.Rarity_Digit < 3)
          This.Prop.OpenAffix -= 4
        ; 4 Lines in NamePlate => Rarity / Item Name/ Item Base
        If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n.+`r`n(.+)`r`n(.+)",RxMatch))
        {
          This.Prop.ItemName := RxMatch1
          This.Prop.ItemBase := RxMatch2
        }
        ; 3 Lines in NamePlate => Rarity / Item Base
        Else If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n.+`r`n(.+)",RxMatch))
        {
          This.Prop.ItemName := RxMatch1
          This.Prop.ItemBase := RxMatch1
        }
        If (This.Prop.ItemName ~= "^Superior ")
          This.Prop.ItemName := RegExReplace(This.Prop.ItemName, "^Superior ", "")
        If (This.Prop.ItemBase ~= "^Superior ")
          This.Prop.ItemBase := RegExReplace(This.Prop.ItemBase, "^Superior ", "")
        If (This.Prop.ItemBase ~= "^Synthesised ")
          This.Prop.ItemBase := RegExReplace(This.Prop.ItemBase, "^Synthesised ", "")
        If (This.Prop.RarityMagic){
          If (This.Prop.ItemBase ~= " of .+")
              This.Prop.ItemBase := RegExReplace(This.Prop.ItemBase, " of .+", "")
          For k, v in This.Data.AffixNames.Prefix {
            If (This.Prop.ItemBase ~= "^" v.Name)
              This.Prop.ItemBase := RegExReplace(This.Prop.ItemBase, "^" v.Name " ", "")
          }
        }
        ;Start Parse
        
        
        If (This.Prop.ItemClass = "Misc Map Items")
        {
          This.Prop.MiscMapItem := True
          This.Prop.SpecialType := "Misc Map Item"
        }
        If (This.Prop.ItemClass = "Maps")
        {
          This.Prop.IsMap := True
          ; Deal with Blighted Map
          If (InStr(This.Prop.ItemBase, "Blighted"))
          {
            This.Prop.IsBlightedMap := True
            Prop.SpecialType := "Blighted Map"
          }
          Else
          {
            This.Prop.SpecialType := "Map"
          }
        }
        If (This.Prop.ItemBase ~= "Invitation:" && This.Data.Blocks.FlavorText ~= "Map Device")
        {
          This.Prop.SpecialType := "Invitation Map"
        }
        Else If (This.Prop.ItemBase ~= " Incubator$")
        {
          This.Prop.Incubator := True
          This.Prop.SpecialType := "Incubator"
        }
        Else If (InStr(This.Prop.ItemBase, "Timeless Karui Splinter") 
        || InStr(This.Prop.ItemBase, "Timeless Eternal Empire Splinter") 
        || InStr(This.Prop.ItemBase, "Timeless Vaal Splinter") 
        || InStr(This.Prop.ItemBase, "Timeless Templar Splinter") 
        || InStr(This.Prop.ItemBase, "Timeless Maraketh Splinter"))
        {
          This.Prop.TimelessSplinter := True
          This.Prop.SpecialType := "Timeless Splinter"
        }
        Else If (InStr(This.Prop.ItemBase, "Timeless Karui Emblem") 
        || InStr(This.Prop.ItemBase, "Timeless Eternal Emblem") 
        || InStr(This.Prop.ItemBase, "Timeless Vaal Emblem") 
        || InStr(This.Prop.ItemBase, "Timeless Templar Emblem") 
        || InStr(This.Prop.ItemBase, "Timeless Maraketh Emblem"))
        {
          This.Prop.TimelessEmblem := True
          This.Prop.SpecialType := "Timeless Emblem"
        }
        Else If (InStr(This.Prop.ItemBase, "Simulacrum"))
        {
          This.Prop.DeliriumSimulacrum := True
          This.Prop.SpecialType := "Delirium"
        }
        Else If (InStr(This.Prop.ItemBase, "Delirium Orb"))
        {
          This.Prop.DeliriumOrb := True
          This.Prop.SpecialType := "Delirium"
        }
        Else If (InStr(This.Prop.ItemBase, "Splinter of") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.BreachSplinter := True
          This.Prop.SpecialType := "Breach Splinter"
        }
        Else If (InStr(This.Prop.ItemBase, "Breachstone") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.BreachSplinter := True
          This.Prop.SpecialType := "Breachstone"
        }
        Else If (InStr(This.Prop.ItemBase, "Sacrifice at") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.SacrificeFragment := True
          This.Prop.SpecialType := "Sacrifice Fragment"
        }
        Else If (InStr(This.Prop.ItemBase, "Mortal Grief") 
        || InStr(This.Prop.ItemBase, "Mortal Hope") 
        || InStr(This.Prop.ItemBase, "Mortal Ignorance")
        || InStr(This.Prop.ItemBase, "Mortal Rage"))
        {
          This.Prop.MortalFragment := True
          This.Prop.SpecialType := "Mortal Fragment"
        }
        Else If (InStr(This.Prop.ItemBase, "Fragment of") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.GuardianFragment := True
          This.Prop.SpecialType := "Guardian Fragment"
        }
        Else If (InStr(This.Prop.ItemBase, "Volkuur's Key") 
        || InStr(This.Prop.ItemBase, "Eber's Key")
        || InStr(This.Prop.ItemBase, "Yriel's Key")
        || InStr(This.Prop.ItemBase, "Inya's Key"))
        {
          This.Prop.ProphecyFragment := True
          This.Prop.SpecialType := "Prophecy Fragment"
        }
        Else If (InStr(This.Prop.ItemBase, "Scarab") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.Scarab := True
          This.Prop.SpecialType := "Scarab"
        }
        Else If (InStr(This.Prop.ItemBase, "Offering to the Goddess") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.Offering := True
          This.Prop.SpecialType := "Offering"
        }
        Else If (InStr(This.Prop.ItemBase, "to the Goddess") && This.Prop.ItemClass ~= "Fragments")
        {
          This.Prop.UberDuberOffering := True
          This.Prop.SpecialType := "Uber Duber Offering"
        }
        Else If (InStr(This.Prop.ItemBase, "Essence of")
        || InStr(This.Prop.ItemBase, "Remnant of Corruption"))
        {
          This.Prop.Essence := True
          This.Prop.SpecialType := "Essence"
        }
        Else If (This.Prop.RarityCurrency 
        && (This.Prop.ItemBase ~= " Fossil$"))
        {
          This.Prop.Fossil := True
          This.Prop.SpecialType := "Fossil"
        }
        Else If (This.Prop.ItemClass ="Delve Stackable Socketable Currency")
        {
          This.Prop.Resonator := True
          This.Prop.SpecialType := "Resonator"
          If (InStr(This.Prop.ItemName, "Primitive") || InStr(This.Prop.ItemName, "Potent"))
            This.Prop.Item_Width := 1
          Else
            This.Prop.Item_Width := 2
          
          If (InStr(This.Prop.ItemName, "Primitive"))
            This.Prop.Item_Height := 1
          Else
            This.Prop.Item_Height := 2
        }
        Else If (InStr(This.Prop.ItemBase, "Divine Vessel"))
        {
          This.Prop.Vessel := True
          This.Prop.SpecialType := "Divine Vessel"
        }
        Else If (This.Prop.ItemClass = "Abyss Jewel")
        {
          This.Prop.AbyssJewel := True
          This.Prop.Jewel := True
        }
        Else If (This.Prop.ItemClass = "Jewel")
        {
          If (InStr(This.Prop.ItemBase, "Cluster Jewel"))
          {
            This.Prop.ClusterJewel := True
            This.Prop.SpecialType := "Cluster Jewel"
          }
          else
          {
            This.Prop.Jewel := True
          }
        }
        Else If (This.Prop.ItemClass = "Heist Target")
        {
          This.Prop.Heist := True
          This.Prop.SpecialType := "Heist Goods"
          This.Prop.Item_Width := This.Prop.Item_Height := 2
          If indexOf(This.Prop.ItemBase, HeistLootLarge)
            This.Prop.Item_Height := 4
        }
        Else If (InStr(This.Prop.ItemClass, "Flasks"))
        {
          This.Prop.Flask := True
          This.Prop.Item_Width := 1
          This.Prop.Item_Height := 2
        }
        Else If (This.Prop.ItemClass = "Quivers")
        {
          This.Prop.Quiver := True
          This.Prop.Item_Width := 2
          This.Prop.Item_Height := 3
        }
        Else If (This.Prop.ItemBase ~= " Oil$")
        {
          If (This.Prop.RarityCurrency)
          {
          This.Prop.Oil := True
          This.Prop.SpecialType := "Oil"
          }
        }
        Else If (InStr(This.Prop.ItemBase, "Catalyst"))
        {
          If (This.Prop.RarityCurrency)
          {
          This.Prop.Catalyst := True
          This.Prop.SpecialType := "Catalyst"
          }
        }
        Else If (This.Prop.ItemClass = "Metamorph Sample")
        {
          If (InStr(This.Prop.ItemBase, "'s Lung"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Lung"
              This.Prop.SpecialType := "Organ"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Heart"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Heart"
              This.Prop.SpecialType := "Organ"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Brain"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Brain"
              This.Prop.SpecialType := "Organ"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Liver"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Liver"
              This.Prop.SpecialType := "Organ"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Eye"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Eye"
              This.Prop.SpecialType := "Organ"
            }
          }
        }
        Else If (This.Prop.ItemClass = "Contract")
        {
          This.Prop.Heist := True
          This.Prop.SpecialType := "Heist Contract"
        }
        Else If (This.Prop.ItemClass = "Blueprint")
        {
          This.Prop.Heist := True
          This.Prop.SpecialType := "Heist Blueprint"
        }
        Else If (InStr(This.Prop.ItemBase, "Thief's Trinket"))
        {
          This.Prop.Heist := True
          This.Prop.SpecialType := "Heist Tricket"
        }
        Else If (InStr(This.Prop.ItemBase, "Rogue's Marker"))
        {
          This.Prop.Heist := True
          This.Prop.SpecialType := "Heist Marker"
        }
        Else If (indexOf(This.Prop.ItemBase, HeistGear))
        {
          This.Prop.Heist := True
          This.Prop.HeistGear := True
          This.Prop.SpecialType := "Heist Gear"
          If InStr(This.Prop.ItemBase, "Brooch")
            This.Prop.Item_Width := This.Prop.Item_Height := 1
          Else
            This.Prop.Item_Width := This.Prop.Item_Height := 2
        }
      }
      ;End NamePlate Parser

      ;Start Extra Blocks Parser
        ;Parse Influence data block
      Loop, Parse,% This.Data.Blocks.Influence, `n, `r
      {
        ; Match for influence type
        If (RegExMatch(A_LoopField, "`am)(.+) Item",RxMatch))
          This.Prop.Influence .= (This.Prop.Influence?" ":"") RxMatch1
      }
      If This.Prop.Influence {
        If (This.Prop.Influence ~= "Fractured" || This.Prop.Influence ~= "Synthesised")
          This.Prop.IsSynthesisItem := True
        Else 
          This.Prop.IsInfluenceItem := True
      }
      ; Get Prophecy/Beasts using Flavour Txt
      If (RegExMatch(This.Data.Blocks.FlavorText, "Right-click to add this prophecy to your character",RxMatch))
      {
        This.Prop.Prophecy := True
        This.Prop.SpecialType := "Prophecy"
      }
        Else If (RegExMatch(This.Data.Blocks.FlavorText, "Right-click to add this to your bestiary",RxMatch))
      {
          This.Prop.IsBeast := True
          This.Prop.SpecialType := "Beast"
      }
      ;End Extra Blocks Parser

      ;Start Prop Block Parser for General Items
        ;Every Item has a Item Level
      If (This.Prop.Rarity)
      {
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Level: "rxNum,RxMatch))
        {
          This.Prop.ItemLevel := RxMatch1
        }
        If (This.Data.Blocks.HasKey("Enchant"))
        {
          This.Prop.SpecialType := "Enchanted Item"
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Level: "rxNum,RxMatch))
        {
          This.Prop.Required_Level := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Str: "rxNum,RxMatch))
        {
          This.Prop.Required_Str := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Dex: "rxNum,RxMatch))
        {
          This.Prop.Required_Dex := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Int: "rxNum,RxMatch))
        {
          This.Prop.Required_Int := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Sockets: ([\w- ]+)",RxMatch))
        {
          This.Prop.Sockets_Raw := RxMatch1
          This.Prop.Sockets_Num := StrLen(RegExReplace(This.Prop.Sockets_Raw, "[- ]+" , ""))
          This.Prop.Sockets_Link := 0
          RegExReplace(RxMatch1, "R",, n)
          This.Prop.Sockets_R := n
          RegExReplace(RxMatch1, "G",, n)
          This.Prop.Sockets_G := n
          RegExReplace(RxMatch1, "B",, n)
          This.Prop.Sockets_B := n
          RegExReplace(RxMatch1, "W",, n)
          This.Prop.Sockets_W := n
          For k, v in StrSplit(RxMatch1, " ")
          {
            nlink := StrLen(RegExReplace(v, "\w" , "")) + 1
            if (This.Prop.Sockets_Link < nlink)
            {
              This.Prop.Sockets_Link := nlink
            }
            if (v ~= "R" && v ~= "G" && v ~= "B")
            {
              This.Prop.Chromatic := True
            }
          }
          If (This.Prop.Sockets_Link == 5 && YesSpecial5Link)
          {
            This.Prop.SpecialType := "5Link"
          }
          Else If (This.Prop.Sockets_Link == 6)
          {
            This.Prop.SpecialType := "6Link"
          }
          If (This.Prop.Sockets_Num == 6)
          {
            This.Prop.Jeweler := True
          }
        }
        ;Generic Props
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: \+"rxNum,RxMatch) && !IsMap)
        {
          This.Prop.Quality := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Armour: "rxNum,RxMatch))
        {
          This.Prop.Rating_Armour := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Energy Shield: "rxNum,RxMatch))
        {
          This.Prop.Rating_EnergyShield := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Evasion: "rxNum,RxMatch))
        {
          This.Prop.Rating_Evasion := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Chance to Block: "rxNum,RxMatch))
        {
          This.Prop.Rating_Block := RxMatch1
        }

        ;Weapon Specific Props
          ;Every Weapon has APS
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Attacks per Second: "rxNum,RxMatch))
        {
          This.Prop.IsWeapon := True
          This.Prop.Weapon_APS := RxMatch1
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Two Handed",RxMatch)){
            This.Prop.IsTwoHanded := True  
          }
          Else If (RegExMatch(This.Data.Blocks.Properties, "`am)^Staff",RxMatch)){
            This.Prop.IsTwoHanded := True  
          }
          Else If (RegExMatch(This.Data.Blocks.Properties, "`am)^Bow",RxMatch)){
            This.Prop.IsTwoHanded := True  
          }
          Else
          {
            This.Prop.IsOneHanded := True
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Physical Damage: " rxNum "-" rxNum ,RxMatch))
          {
            This.Prop.Weapon_Avg_Physical_Dmg := Format("{1:0.3g}",(RxMatch1 + RxMatch2) / 2)
            This.Prop.Weapon_Min_Physical_Dmg := RxMatch1
            This.Prop.Weapon_Max_Physical_Dmg := RxMatch2
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Chaos Damage: " rxNum "-" rxNum ,RxMatch))
          {
            This.Prop.Weapon_Avg_Chaos_Dmg := Format("{1:0.3g}",(RxMatch1 + RxMatch2) / 2)
            This.Prop.Weapon_Min_Chaos_Dmg := RxMatch1
            This.Prop.Weapon_Max_Chaos_Dmg := RxMatch2
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Elemental Damage: .+",RxMatch))
          {
            This.Prop.Weapon_Avg_Elemental_Dmg := 0
            This.Prop.Weapon_Min_Elemental_Dmg := 0
            This.Prop.Weapon_Max_Elemental_Dmg := 0
            For k, v in StrSplit(RxMatch,",")
            {
              values := This.MatchLine(v)
              This.Prop.Weapon_Avg_Elemental_Dmg := Format("{1:0.3g}",This.Prop.Weapon_Avg_Elemental_Dmg + (values.1 + values.2) / 2 ) 
              This.Prop.Weapon_Min_Elemental_Dmg += values.1
              This.Prop.Weapon_Max_Elemental_Dmg += values.2
            }
            values := ""
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Critical Strike Chance: "rxNum,RxMatch))
          {
            This.Prop.Weapon_Critical_Strike := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Weapon Range: "rxNum,RxMatch))
          {
            This.Prop.Weapon_Range := RxMatch1
          }
          This.Prop.Weapon_DPS_Total := 0
          This.Prop.Weapon_DPS_Total_Q20 := 0
          If (This.Prop.HasKey("Weapon_Avg_Physical_Dmg"))
            This.Prop.Weapon_DPS_Physical := Round(This.Prop.Weapon_Avg_Physical_Dmg * This.Prop.Weapon_APS,1)
          If (This.Prop.HasKey("Weapon_Avg_Elemental_Dmg"))
            This.Prop.Weapon_DPS_Elemental := Round(This.Prop.Weapon_Avg_Elemental_Dmg * This.Prop.Weapon_APS,1)
          If (This.Prop.HasKey("Weapon_Avg_Chaos_Dmg"))
            This.Prop.Weapon_DPS_Chaos := Round(This.Prop.Weapon_Avg_Chaos_Dmg * This.Prop.Weapon_APS,1)
          This.Prop.Weapon_DPS_Total := Round((This.Prop.Weapon_DPS_Physical?This.Prop.Weapon_DPS_Physical:0) + (This.Prop.Weapon_DPS_Elemental?This.Prop.Weapon_DPS_Elemental:0) + (This.Prop.Weapon_DPS_Chaos?This.Prop.Weapon_DPS_Chaos:0),1)
          If ((This.Prop.Quality?This.Prop.Quality:0) < 20 && This.Prop.HasKey("Weapon_Avg_Physical_Dmg"))
          {
            BasePhysDps := (This.Prop.Weapon_Avg_Physical_Dmg * This.Prop.Weapon_APS) / (((This.Prop.Quality?This.Prop.Quality:0) + 100) / 100)
            Q20DpsPhys := Round(BasePhysDps * (120 / 100),2)
            This.Prop.Weapon_DPS_Total_Q20 := Round(Q20DpsPhys + (This.Prop.Weapon_DPS_Elemental?This.Prop.Weapon_DPS_Elemental:0) + (This.Prop.Weapon_DPS_Chaos?This.Prop.Weapon_DPS_Chaos:0),1)
          }
          Else
            This.Prop.Weapon_DPS_Total_Q20 := This.Prop.Weapon_DPS_Total
        }
      }
      ;End Prop Block Parser for General Items

      ;Start Prop Block Parser for Maps
        ;Every map has a Map Tier!
      If (RegExMatch(This.Data.Blocks.Properties, "`am)^Map Tier: "rxNum,RxMatch))
      {
        This.Prop.Map_Tier := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Atlas Region: ([a-zA-Z0-9 ']+)",RxMatch))
        {
          This.Prop.Map_AtlasRegion := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Quantity: \+"rxNum,RxMatch))
        {
          This.Prop.Map_Quantity := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Rarity: \+"rxNum,RxMatch))
        {
          This.Prop.Map_Rarity := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Monster Pack Size: \+"rxNum,RxMatch))
        {
          This.Prop.Map_PackSize := RxMatch1
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Delirium Reward Type:",RxMatch))
        {
          This.Prop.Map_Delirium := True
        }
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: \+"rxNum,RxMatch))
        {
          This.Prop.Map_Quality := RxMatch1
        }Else{
          ;Set Quality to 0 if not in map prop (instead flagging as false)
          This.Prop.Map_Quality := 0
        }
      }
      ;End Prop Block Parser for Maps
      
      ; Start Prop Block Parser for Heist
      If indexOf(This.Prop.ItemClass, ["Contract","Blueprint"]) {
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Heist Target: (.*)",RxMatch))
          This.Prop.Heist_Target := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Client: (.*)",RxMatch))
          This.Prop.Heist_Client := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Area Level: " rxNum,RxMatch))
          This.Prop.Heist_AreaLevel := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Quantity: \+" rxNum,RxMatch))
          This.Prop.Heist_ItemQuantity := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Rarity: \+" rxNum,RxMatch))
          This.Prop.Heist_ItemRarity := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Alert Level Reduction: \+" rxNum,RxMatch))
          This.Prop.Heist_AlertLevelReduction := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Time Before Lockdown: \+" rxNum,RxMatch))
          This.Prop.Heist_TimeBeforeLockdown := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Maximum Alive Reinforcements: \+" rxNum,RxMatch))
          This.Prop.Heist_MaximumAliveReinforcements := RxMatch1
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Wings Revealed: " rxNum "/" rxNum,RxMatch))
          This.Prop.Heist_WingsRevealed := RxMatch1, This.Prop.Heist_WingsRevealedMax := RxMatch2
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Escape Routes Revealed: " rxNum "/" rxNum,RxMatch))
          This.Prop.Heist_EscapeRoutesRevealed := RxMatch1, This.Prop.Heist_EscapeRoutesRevealedMax := RxMatch2
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Reward Rooms Revealed: " rxNum "/" rxNum,RxMatch))
          This.Prop.Heist_RewardRoomsRevealed := RxMatch1, This.Prop.Heist_RewardRoomsRevealedMax := RxMatch2
        For k, job in ["Brute Force","Agility","Perception","Demolition","Counter-Thaumaturgy","Trap Disarmament","Deception","Engineering","Lockpicking"] {
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Requires " job " \(Level " rxNum "\)",RxMatch)) {
            This.Prop["Heist_Requires" job ] := RxMatch1
          }
        }
      }
      ; End Prop Block Parser for Heist
      ;Start Prop Block Parser for Vaal Gems
      If (This.Prop.RarityGem && This.Prop.Corrupted)
      {
        If (RegExMatch(This.Data.Blocks.Properties, "`am)Vaal",RxMatch))
        {
          This.Prop.VaalGem := True
          This.Prop.ItemName := "Vaal " . This.Prop.ItemName
        }
      }
      ;End Prop Block Parser for Vaal Gems

      If (This.Affix["Veiled Prefix"] || This.Affix["Veiled Suffix"])
      {
        This.Prop.Veiled := True
        This.Prop.SpecialType := "Veiled Item"
      }
      Else
      {
        This.Prop.Veiled := False
      }

      If (This.BrickedMap())
        This.Prop.IsBrickedMap := True
      Else
        This.Prop.IsBrickedMap := False

      ;Stack size for anything with it
      If (RegExMatch(This.Data.Blocks.Properties, "`am)^Stack Size: (\d+\.?\,?\d*)\/" rxNum ,RxMatch))
      {
        This.Prop.Stack_Size := RegExReplace(RxMatch1,",","") + 0
        This.Prop.Stack_Max := RxMatch2
      }
      If (RegExMatch(This.Data.Blocks.Properties, "`am)^Seed Tier: "rxNum,RxMatch))
      {
        This.Prop.Seed_Tier := RxMatch1
        This.Prop.IsSeed := True
      }
      If (This.Data.Blocks.FlavorText ~= "in the Sacred Grove")
        This.Prop.SpecialType := "Harvest Item"
      If (This.Data.Blocks.FlavorText ~= "Ritual Altar" || This.Data.Blocks.FlavorText ~= "Ritual Vessel")
        This.Prop.SpecialType := "Ritual Item", This.Prop.Ritual := True
      If This.TopTierLife()
        This.Prop.TopTierLife := 1
      If This.TopTierES()
        This.Prop.TopTierES := 1
      If This.TopTierMS()
        This.Prop.TopTierMS := 1
      If This.TopTierChaosResist()
        This.Prop.TopTierChaosResist := 1
      If This.TopTierLightningResist()
        This.Prop.TopTierLightningResist := 1
      If This.TopTierFireResist()
        This.Prop.TopTierFireResist := 1
      If This.TopTierColdResist()
        This.Prop.TopTierColdResist := 1
      If This.TopTierAllResist()
        This.Prop.TopTierAllResist := 1
      If This.TopTierRarityPre()
        This.Prop.TopTierRarityPre := 1
      If This.TopTierRaritySuf()
        This.Prop.TopTierRaritySuf := 1
      If This.TopTierAttackSpeed()
        This.Prop.TopTierAttackSpeed := 1
      If This.TopTierCastSpeed()
        This.Prop.TopTierCastSpeed := 1
      If This.TopTierCritChance()
        This.Prop.TopTierCritChance := 1
      If This.TopTierCritMulti()
        This.Prop.TopTierCritMulti := 1
      If (This.Prop.TopTierLightningResist || This.Prop.TopTierFireResist || This.Prop.TopTierColdResist || This.Prop.TopTierChaosResist || This.Prop.TopTierAllResist)
        This.Prop.TopTierResists := (This.Prop.TopTierLightningResist?1:0) + (This.Prop.TopTierFireResist?1:0) + (This.Prop.TopTierColdResist?1:0) + (This.Prop.TopTierChaosResist?1:0) + (This.Prop.TopTierAllResist?1:0)
      If (This.Prop.TopTierRarityPre || This.Prop.TopTierRaritySuf)
        This.Prop.TopTierRarity := (This.Prop.TopTierRarityPre?1:0) + (This.Prop.TopTierRaritySuf?1:0)
    }
    BrickedMap() {
      If (This.HasBrickedAffix()) {
        If (BrickedWhenCorrupted && This.Prop.Corrupted)
          Return True
        Else If (!BrickedWhenCorrupted)
          Return True
        Else
          Return False
      } Else
        Return False
    }
    HasBrickedAffix() {
      If ((This.Affix["Monsters have #% chance to Avoid Elemental Ailments"] && AvoidAilments) 
      || (This.Affix["Monsters have a #% chance to avoid Poison, Blind, and Bleeding"] && AvoidPBB) 
      || (This.Affix["Monsters reflect #% of Elemental Damage"] && ElementalReflect) 
      || (This.Affix["Monsters reflect #% of Physical Damage"] && PhysicalReflect) 
      || (This.Affix["Players cannot Regenerate Life, Mana or Energy Shield"] && NoRegen) 
      || (This.Affix["Cannot Leech Life from Monsters"] && NoLeech)
      || (This.Affix["-#% maximum Player Resistances"] && MinusMPR)
      || (This.Affix["Monsters fire # additional Projectiles"] && MFAProjectiles)
      || (This.Affix["Monsters deal #% extra Physical Damage as Fire"] && MDExtraPhysicalDamage)
      || (This.Affix["Monsters deal #% extra Physical Damage as Cold"] && MDExtraPhysicalDamage)
      || (This.Affix["Monsters deal #% extra Physical Damage as Lightning"] && MDExtraPhysicalDamage)
      || (This.Affix["Monsters have #% increased Critical Strike Chance"] && MICSC)
      || (This.Affix["Monsters' skills Chain # additional times"] && MSCAT)
      || (This.Affix["Players have #% less Recovery Rate of Life and Energy Shield"] && LRRLES)
      || (This.Affix["Player chance to Dodge is Unlucky"] && PCDodgeUnlucky)
      || (This.Affix["Monsters have #% increased Accuracy Rating"] && MHAccuracyRating)
      || (This.Affix["Players have #% reduced Chance to Block"] && PHReducedChanceToBlock)
      || (This.Affix["Players have #% less Armour"] && PHLessArmour)
      || (This.Affix["Players have #% less Area of Effect"] && PHLessAreaOfEffect))
      {
        Return True
      } 
      Else 
      {
        return False
      }
    }
    TopTierChaosResist(){
      If (This.Prop.ItemLevel < 30 && This.HasAffix("of the Lost"))
        Return True
      Else If (This.Prop.ItemLevel < 44 && This.HasAffix("of Banishment"))
        Return True
      Else If (This.Prop.ItemLevel < 56 && This.HasAffix("of Eviction"))
        Return True
      Else If (This.Prop.ItemLevel < 65 && This.HasAffix("of Expulsion"))
        Return True
      Else If (This.Prop.ItemLevel < 81 && This.HasAffix("of Exile"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Bameth"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Tacati") && This.Affix["#% to Chaos Resistance"] >= 31)
        Return True
      Else
        Return False
    }
    TopTierLightningResist(){
      If (This.Prop.ItemLevel < 13 && This.HasAffix("of the Cloud"))
        Return True
      Else If (This.Prop.ItemLevel < 25 && This.HasAffix("of the Squall"))
        Return True
      Else If (This.Prop.ItemLevel < 37 && This.HasAffix("of the Storm"))
        Return True
      Else If (This.Prop.ItemLevel < 49 && This.HasAffix("of the Thunderhead"))
        Return True
      Else If (This.Prop.ItemLevel < 60 && This.HasAffix("of the Tempest"))
        Return True
      Else If (This.Prop.ItemLevel < 72 && This.HasAffix("of the Maelstrom"))
        Return True
      Else If (This.Prop.ItemLevel < 84 && This.HasAffix("of the Lightning"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Ephij"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Puhuarte") && This.Affix["#% to Lightning Resistance"])
        Return True
      Else
        Return False
    }
    TopTierFireResist(){
      If (This.Prop.ItemLevel < 12 && This.HasAffix("of the Whelpling"))
        Return True
      Else If (This.Prop.ItemLevel < 24 && This.HasAffix("of the Salamander"))
        Return True
      Else If (This.Prop.ItemLevel < 36 && This.HasAffix("of the Drake"))
        Return True
      Else If (This.Prop.ItemLevel < 48 && This.HasAffix("of the Kiln"))
        Return True
      Else If (This.Prop.ItemLevel < 60 && This.HasAffix("of the Furnace"))
        Return True
      Else If (This.Prop.ItemLevel < 72 && This.HasAffix("of the Volcano"))
        Return True
      Else If (This.Prop.ItemLevel < 84 && This.HasAffix("of the Magma"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Tzteosh"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Puhuarte") && This.Affix["#% to Fire Resistance"])
        Return True
      Else
        Return False
    }
    TopTierColdResist(){
      If (This.Prop.ItemLevel < 14 && This.HasAffix("of the Inuit"))
        Return True
      Else If (This.Prop.ItemLevel < 26 && This.HasAffix("of the Seal"))
        Return True
      Else If (This.Prop.ItemLevel < 38 && This.HasAffix("of the Penguin"))
        Return True
      Else If (This.Prop.ItemLevel < 50 && This.HasAffix("of the Yeti"))
        Return True
      Else If (This.Prop.ItemLevel < 60 && This.HasAffix("of the Walrus"))
        Return True
      Else If (This.Prop.ItemLevel < 72 && This.HasAffix("of the Polar Bear"))
        Return True
      Else If (This.Prop.ItemLevel < 84 && This.HasAffix("of the Ice"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Haast"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Puhuarte") && This.Affix["#% to Cold Resistance"])
        Return True
      Else
        Return False
    }
    TopTierAllResist(){
      If (This.Prop.ItemLevel < 24 && This.HasAffix("of the Crystal"))
        Return True
      Else If (This.Prop.ItemLevel < 36 && This.HasAffix("of the Prism"))
        Return True
      Else If (This.Prop.ItemLevel < 48 && This.HasAffix("of the Kaleidoscope"))
        Return True
      Else If (This.Prop.ItemLevel < 60 && This.HasAffix("of Variegation"))
        Return True
      Else If ((This.Prop.ItemLevel < 85 || indexOf(This.Prop.ItemClass,["Rings"])) 
      && This.HasAffix("of the Rainbow"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of the Span"))
        Return True
      Else
        Return False
    }
    TopTierCastSpeed(){
      If ((This.Prop.ItemLevel < 15 || indexOf(This.Prop.ItemClass,["Rings"]))
      && This.HasAffix("of Talent"))
        Return True
      Else If (This.Prop.ItemLevel < 30 && This.HasAffix("of Nimbleness"))
        Return True
      Else If ((This.Prop.ItemLevel < 40 || indexOf(This.Prop.ItemClass,["Amulets"])) 
      && This.HasAffix("of Expertise"))
        Return True
      Else If ((This.Prop.ItemLevel < 55 || indexOf(This.Prop.ItemClass,["Gloves"])) 
      && This.HasAffix("of Legerdemain"))
        Return True
      Else If (This.Prop.ItemLevel < 72 && This.HasAffix("of Prestidigitation"))
        Return True
      Else If (This.Prop.ItemLevel < 83 && This.HasAffix("of Sortilege"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Finesse"))
        Return True
      Else
        Return False
    }
    TopTierAttackSpeed(){
      If ((This.Prop.ItemLevel < 11 || indexOf(This.Prop.ItemClass,["Rings"]))
      && This.HasAffix("of Skill"))
        Return True
      Else If (This.Prop.ItemLevel < 22 && This.HasAffix("of Ease"))
        Return True
      Else If ((This.Prop.ItemLevel < 30 || indexOf(This.Prop.ItemClass,["Shields"])) 
      && This.HasAffix("of Mastery"))
        Return True
      Else If ((This.Prop.ItemLevel < 37 || indexOf(This.Prop.ItemClass,["Gloves"])) 
      && This.HasAffix("of Renown"))
        Return True
      Else If (This.Prop.ItemLevel < 45 && This.HasAffix("of Acclaim"))
        Return True
      Else If (This.Prop.ItemLevel < 60 && This.HasAffix("of Fame"))
        Return True
      Else If (This.Prop.ItemLevel < 77 && This.HasAffix("of Infamy"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Celebration"))
        Return True
      Else
        Return False
    }
    TopTierRaritySuf(){
      If (This.Prop.ItemLevel < 30 && This.HasAffix("of Plunder"))
        Return True
      Else If ((This.Prop.ItemLevel < 53 || indexOf(This.Prop.ItemClass,["Gloves","Boots"]) ) && This.HasAffix("of Raiding"))
        Return True
      Else If (This.Prop.ItemLevel < 75 && This.HasAffix("of Archaeology"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("of Excavation"))
        Return True
      Else
        Return False
    }
    TopTierRarityPre(){
      If (This.Prop.ItemLevel < 39 && This.HasAffix("Magpie's"))
        Return True
      Else If ((This.Prop.ItemLevel < 62 || indexOf(This.Prop.ItemClass,["Gloves","Boots"]) ) && This.HasAffix("Pirate's"))
        Return True
      Else If ((This.Prop.ItemLevel < 84 || indexOf(This.Prop.ItemClass,["Helmet"]) ) && This.HasAffix("Dragon's"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("Perandus's"))
        Return True
      Else
        Return False
    }
    TopTierCritMulti(){
      If (This.Prop.ItemLevel < 21
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 8 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 8 ))
        Return True
      Else If (This.Prop.ItemLevel < 31
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 13 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 13 ))
        Return True
      Else If (This.Prop.ItemLevel < 45
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 20 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 20 ))
        Return True
      Else If (This.Prop.ItemLevel < 59
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 25 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 25 ))
        Return True
      Else If (This.Prop.ItemLevel < 75
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 30 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 30 ))
        Return True
      Else If (This.Prop.ItemLevel < 75 && (This.Prop.ItemClass = "Rings" || This.Prop.ItemClass = "Helmets")
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 8 ))
        Return True
      Else If (This.Prop.ItemLevel < 75
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 30 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 30 ))
        Return True
      Else If (This.Prop.ItemLevel < 80 && (This.Prop.ItemClass = "Rings" || This.Prop.ItemClass = "Helmets")
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 13 ))
        Return True
      Else If (This.Prop.ItemLevel <= 100
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 35 
        || This.Affix["#% to Critical Strike Multiplier with Bows"] >= 35 ))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && (This.Prop.ItemClass = "Rings" || This.Prop.ItemClass = "Helmets")
      && (This.Affix["#% to Global Critical Strike Multiplier"] >= 17 ))
        Return True
      Else
        Return False
    }
    TopTierCritChance(){
      If ((This.Prop.ItemLevel < 20 || This.Prop.ItemClass = "Rings")
      && (This.Affix["#% increased Critical Strike Chance"] >= 10 
        || This.Affix["#% increased Global Critical Strike Chance"] >= 10 
        || This.Affix["#% increased Critical Strike Chance with Bows"] >= 10 ))
        Return True
      Else If ((This.Prop.ItemLevel < 30 || !(This.Prop.IsWeapon || This.Prop.ItemClass = "Amulets" || This.Prop.ItemClass = "Quivers"))
      && (This.Affix["#% increased Critical Strike Chance"] >= 15 
        || This.Affix["#% increased Global Critical Strike Chance"] >= 15 
        || This.Affix["#% increased Critical Strike Chance with Bows"] >= 15 ))
        Return True
      Else If (This.Prop.ItemLevel < 44 
      && (This.Affix["#% increased Critical Strike Chance"] >= 20 
        || This.Affix["#% increased Global Critical Strike Chance"] >= 20 
        || This.Affix["#% increased Critical Strike Chance with Bows"] >= 20 ))
        Return True
      Else If (This.Prop.ItemLevel < 58 
      && (This.Affix["#% increased Global Critical Strike Chance"] >= 25 
        || This.Affix["#% increased Critical Strike Chance with Bows"] >= 25 ))
        Return True
      Else If (This.Prop.ItemLevel < 59 
      && (This.Affix["#% increased Critical Strike Chance"] >= 25 ))
        Return True
      Else If (This.Prop.ItemLevel <= 100 
      && (This.Affix["#% increased Critical Strike Chance"] >= 30 
        || This.Affix["#% increased Global Critical Strike Chance"] >= 30 
        || This.Affix["#% increased Critical Strike Chance with Bows"] >= 30 ))
        Return True
      Else
        Return False
    }
    TopTierMS(){
      If (This.Prop.ItemLevel < 15 && This.HasAffix("Runner's"))
        Return True
      Else If (This.Prop.ItemLevel < 30 && This.HasAffix("Sprinter's"))
        Return True
      Else If (This.Prop.ItemLevel < 40 && This.HasAffix("Stallion's"))
        Return True
      Else If (This.Prop.ItemLevel < 55 && This.HasAffix("Gazelle's"))
        Return True
      Else If (This.Prop.ItemLevel < 86 && This.HasAffix("Cheetah's"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && This.HasAffix("Hellion's"))
        Return True
      Else
        Return False
    }
    TopTierES(){
      If (This.Prop.ItemLevel < 11 && This.HasAffix("Shining"))
        Return True
      Else If (This.Prop.ItemLevel < 17 && This.HasAffix("Glimmering"))
        Return True
      Else If (This.Prop.ItemLevel < 23 && This.HasAffix("Glittering"))
        Return True
      Else If (This.Prop.ItemLevel < 29 && This.HasAffix("Glowing"))
        Return True
      Else If (This.Prop.ItemLevel < 35 && This.HasAffix("Radiating"))
        Return True
      Else If (This.Prop.ItemLevel < 43 && This.HasAffix("Pulsing"))
        Return True
      Else If ((This.Prop.ItemLevel < 51 || indexOf(This.Prop.ItemClass,["Gloves","Boots"])) && This.HasAffix("Seething"))
        Return True
      Else If ((This.Prop.ItemLevel < 60 || indexOf(This.Prop.ItemClass,["Helmets"])) && This.HasAffix("Blazing"))
        Return True
      Else If (This.Prop.ItemLevel < 69 && This.HasAffix("Scintillating"))
        Return True
      Else If ((This.Prop.ItemLevel < 75 || indexOf(This.Prop.ItemClass,["Shields"])) && This.HasAffix("Incandescent"))
        Return True
      Else If ((This.Prop.ItemLevel < 80 || indexOf(This.Prop.ItemClass,["Rings","Body Armours"])) && This.HasAffix("Resplendent"))
        Return True
      Else If ((This.Prop.ItemLevel <= 100 || indexOf(This.Prop.ItemClass,["Belts","Amulets"])) && This.HasAffix("Dazzling"))
        Return True
      Else
        Return False
    }
    TopTierLife(){
      If (This.Prop.ItemLevel < 5 && This.HasAffix("Hale"))
        Return True
      Else If (This.Prop.ItemLevel < 11 && This.HasAffix("Healthy"))
        Return True
      Else If (This.Prop.ItemLevel < 18 && This.HasAffix("Sanguine"))
        Return True
      Else If (This.Prop.ItemLevel < 24 && This.HasAffix("Stalwart"))
        Return True
      Else If (This.Prop.ItemLevel < 30 && This.HasAffix("Stout"))
        Return True
      Else If (This.Prop.ItemLevel < 36 && This.HasAffix("Robust"))
        Return True
      Else If (This.Prop.ItemLevel < 44 && This.HasAffix("Rotund"))
        Return True
      Else If ((This.Prop.ItemLevel < 54 || indexOf(This.Prop.ItemClass,["Rings"])) && This.HasAffix("Virile"))
        Return True
      Else If ((This.Prop.ItemLevel < 64 || indexOf(This.Prop.ItemClass,["Amulets","Gloves","Boots"])) && This.HasAffix("Athlete's"))
        Return True
      Else If ((This.Prop.ItemLevel < 73 || indexOf(This.Prop.ItemClass,["Helmets","Belts","Quivers"])) && This.HasAffix("Fecund"))
        Return True
      Else If ((This.Prop.ItemLevel < 81 || indexOf(This.Prop.ItemClass,["Shields"])) && This.HasAffix("Vigorous"))
        Return True
      Else If (This.Prop.ItemLevel <= 100 && (This.HasAffix("Rapturous") || This.HasAffix("Prime") || (This.HasAffix("Guatelitzi's") && This.Affix["#% increased maximum Life"])))
        Return True
      Else If ((This.Prop.ItemLevel <= 100 || indexOf(This.Prop.ItemClass,["Body Armours"])) && )
        Return True
      Else
        Return False
    }
    HasAffix(Name){
      local Type, Obj, k, v
      For Type, Obj in This.Data.AffixNames {
        For k, v in Obj {
          If (v.Name = Name)
            Return True
        }
      }
      Return False
    }
    MatchBase2Slot(){
      If (This.Prop.ItemClass ~= "Body Armour")
        This.Prop.SlotType := "Body"
      Else If (This.Prop.ItemClass ~= "Helmet")
        This.Prop.SlotType := "Helmet"
      Else If (This.Prop.ItemClass ~= "Glove")
        This.Prop.SlotType := "Gloves"
      Else If (This.Prop.ItemClass ~= "Boot")
        This.Prop.SlotType := "Boots"
      Else If (This.Prop.ItemClass ~= "Belt")
        This.Prop.SlotType := "Belt"
      Else If (This.Prop.ItemClass ~= "Amulet")
        This.Prop.SlotType := "Amulet"
      Else If (This.Prop.ItemClass ~= "Ring")
        This.Prop.SlotType := "Ring"
      Else If (This.Prop.ItemClass ~= "(One|Wand|Dagger|Sceptre|Claw)")
        This.Prop.SlotType := "One Hand"
      Else If (This.Prop.ItemClass ~= "(Two|Bow|stave|Staff)")
        This.Prop.SlotType := "Two Hand"
      Else If (This.Prop.ItemClass ~= "Shield")
        This.Prop.SlotType := "Shield"
    }
    MatchChaosRegal(){
      If (This.Prop.Rarity_Digit = 3 && This.Prop.SlotType != "" )
      {
        If (This.Prop.ItemLevel >= 60 && This.Prop.ItemLevel <= 74 && (ChaosRecipeTypePure || ChaosRecipeTypeHybrid))
          This.Prop.ChaosRecipe := 1
        Else If (This.Prop.ItemLevel >= 75 && This.Prop.ItemLevel <= 100 && (ChaosRecipeTypeRegal || ChaosRecipeTypeHybrid))
          This.Prop.RegalRecipe := 1
      }
    }
    StashChaosRecipe(deposit:=false){
      Global RecipeArray
      Static TypeList := [ "Amulet", "Ring", "Belt", "Boots", "Gloves", "Helmet", "Body" ]
      Static WeaponList := [ "One Hand", "Two Hand", "Shield" ]
      If ( This.Prop.Rarity_Digit != 3 )
      || ( This.Prop.ItemLevel < 60 )
      || ( ChaosRecipeTypePure && This.Prop.ItemLevel > 74)
      || ( ChaosRecipeTypeRegal && This.Prop.ItemLevel < 75 )
      || ( ChaosRecipeSmallWeapons && (This.Prop.IsWeapon || This.Prop.ItemClass = "Shields") 
        && (( This.Prop.Item_Width > 1 && This.Prop.Item_Height > 2) || ( This.Prop.Item_Width = 1 && This.Prop.Item_Height > 3)) )
      || ( !This.Affix.Unidentified && ChaosRecipeEnableUnId && ChaosRecipeOnlyUnId && This.Prop.ItemLevel < ChaosRecipeLimitUnId)
        Return False
      If (ChaosRecipeSkipJC && (This.Prop.Jeweler || This.Prop.Chromatic))
        Return False
      If !IsObject(RecipeArray)
      {
        If !ChaosRecipe(1)
        {
          Notify("Error","Requesting stash information Failed`nCheck your POESESSID",3)
          Return False
        }
      }
      For k, v in TypeList
      {
        If (This.Prop.SlotType = v)
        {
          If ChaosRecipeSeperateCount {
            If This.Affix.Unidentified
              CountValue := retCount(RecipeArray.uChaos[v]) + retCount(RecipeArray.uRegal[v])
            Else
              CountValue := retCount(RecipeArray.Chaos[v]) + retCount(RecipeArray.Regal[v])
          } Else {
            CountValue := retCount(RecipeArray.uChaos[v]) + retCount(RecipeArray.uRegal[v]) + retCount(RecipeArray.Chaos[v]) + retCount(RecipeArray.Regal[v])
          }
          If (v = "Ring")
            CountValue := CountValue / 2
          If (ChaosRecipeAllowDoubleJewellery && IndexOf(v,["Ring","Amulet"]))
            CountValue := CountValue / 2
          If (ChaosRecipeAllowDoubleBelt && IndexOf(v,["Belt"]))
            CountValue := CountValue / 2

          If (CountValue < ChaosRecipeMaxHolding)
          {
            If (OnStash && deposit)
            {
              If This.Affix.Unidentified
              {
                If This.Prop.ChaosRecipe
                  RecipeArray.uChaos[v].Push(This)
                Else If This.Prop.RegalRecipe
                  RecipeArray.uRegal[v].Push(This)
              } Else {
                If This.Prop.ChaosRecipe
                  RecipeArray.Chaos[v].Push(This)
                Else If This.Prop.RegalRecipe
                  RecipeArray.Regal[v].Push(This)
              }
            }
            Return True
          }
          Else
            Return "000"
        }
      }
      For k, v in WeaponList
      {
        If (This.Prop.SlotType = v)
        {
          If ChaosRecipeSeperateCount {
            If This.Affix.Unidentified{
              WeaponCount := retCount(RecipeArray.uRegal["Two Hand"]) + retCount(RecipeArray.uChaos["Two Hand"]) 
              WeaponCount += (retCount(RecipeArray.uRegal["One Hand"]) + retCount(RecipeArray.uChaos["One Hand"])) / 2
              WeaponCount += (retCount(RecipeArray.uRegal["Shield"]) + retCount(RecipeArray.uChaos["Shield"])) / 2
            }Else{
              WeaponCount := retCount(RecipeArray.Regal["Two Hand"]) + retCount(RecipeArray.Chaos["Two Hand"]) 
              WeaponCount += (retCount(RecipeArray.Regal["One Hand"]) + retCount(RecipeArray.Chaos["One Hand"])) / 2 
              WeaponCount += (retCount(RecipeArray.Regal["Shield"]) + retCount(RecipeArray.Chaos["Shield"])) / 2
            }

          } Else {
            WeaponCount := retCount(RecipeArray.uRegal["Two Hand"]) + retCount(RecipeArray.uChaos["Two Hand"]) + retCount(RecipeArray.Regal["Two Hand"]) + retCount(RecipeArray.Chaos["Two Hand"])
                        + (retCount(RecipeArray.uRegal["One Hand"]) + retCount(RecipeArray.uChaos["One Hand"]) + retCount(RecipeArray.Regal["One Hand"]) + retCount(RecipeArray.Chaos["One Hand"]) 
                          + retCount(RecipeArray.uRegal["Shield"]) + retCount(RecipeArray.uChaos["Shield"]) + retCount(RecipeArray.Regal["Shield"]) + retCount(RecipeArray.Chaos["Shield"])) / 2
          }

          If (WeaponCount < ChaosRecipeMaxHolding)
          {
            If (OnStash && deposit)
            {
              If This.Affix.Unidentified
              {
                If This.Prop.ChaosRecipe
                  RecipeArray.uChaos[v].Push(This)
                Else If This.Prop.RegalRecipe
                  RecipeArray.uRegal[v].Push(This)
              } Else {
                If This.Prop.ChaosRecipe
                  RecipeArray.Chaos[v].Push(This)
                Else If This.Prop.RegalRecipe
                  RecipeArray.Regal[v].Push(This)
              }
            }
            Return True
          }
          Else
            Return "000"
        }
      }
      Return False
    }
    MatchAffixesWithoutDoubleMods(content:=""){
      ; These lines remove the extra line created by "additional information bubbles"
      If (content ~= "\n\(")
        content := RegExReplace(content, "\n\(", "(")
      content := RegExReplace(content,"\(\w+ \w+ [\w\d\.% ,]+\)", "")
      ; Do Stuff with info
      LastLine := ""
      DoubleModCounter := 0
      Loop, Parse,% content, `r`n  ; , `r
      {
        If (A_LoopField = "" || A_LoopField ~= "^\{ .* \}$")
        {
          DoubleModCounter := 0
          Continue
        }
        DoubleModCounter++
        if(DoubleModCounter == 2){
          If (vals := This.MatchLine(LastLine))
          {

            If (vals.Count() == 1 && This.CheckIfActualHybridMod(key))
            {
              If This.Affix[key]
              {
                This.Affix[key] -= vals[1]
                This.AddHybridModAffix(key,vals[1])
              }
              Else{
                This.AddHybridModAffix(key,vals[1])
              }
            }Else
            {
              DoubleModCounter := 0
            }
          }
        }
        line :=  RegExReplace(A_LoopField, rxNum "\(" rxNum "-" rxNum "\)", "$1")
        line :=  RegExReplace(line, rxNum "\(-" rxNum "--" rxNum "\)", "$1")
        line :=  RegExReplace(line,  " . Unscalable Value" , "")
        key := This.Standardize(line)
        If (vals := This.MatchLine(line))
        {
          If (vals.Count() >= 2)
          {
            If (line ~= rxNum " to " rxNum || line ~= rxNum "-" rxNum)
              This.Affix[key] := (Format("{1:0.3g}",(vals[1] + vals[2]) / 2))
            Else
              This.Affix[key] := vals[1]
            For k, v in vals
              This.Affix[ key "_value"k ] := v
          }
          Else If (vals.Count() == 1)
          {
            If (This.Affix[key] && DoubleModCounter != 2)
            {
              This.Affix[key] += vals[1]
            }Else If(DoubleModCounter != 2){
              This.Affix[key] := vals[1]
            }Else{
              This.AddHybridModAffix(key,vals[1])
            }
          }
        }
        Else
          This.Affix[key] := True
        LastLine := line
      }
    }
    CheckIfActualHybridMod(value){
      for k, v in HybridModsFirstLine
      {
          if (v == value)
          {
            return true
          }
      }
      return false
    }
    AddHybridModAffix(Key,Value){
      HybridKey := "(Hybrid) " . Key
      If(!This.Affix[HybridKey])
      {
        aux := Value
        If  (aux != 0)
          This.Affix[HybridKey] := aux
      }Else
      {
        aux := This.GetValue("Affix", HybridKey) + Value
        If  (aux != 0)
          This.Affix[HybridKey] := aux
      }
      return
    }
    MatchAffixes(content:=""){
      ; These lines remove the extra line created by "additional information bubbles"
      If (content ~= "\n\(")
        content := RegExReplace(content, "\n\(", "(")
      content := RegExReplace(content,"\(\w+ \w+ [\w\d\.% ,]+\)", "")
      ; Do Stuff with info
      Loop, Parse,% content, `r`n  ; , `r
      {
        If (A_LoopField = "" || A_LoopField ~= "^\{ .* \}$")
          Continue
        line :=  RegExReplace(A_LoopField, rxNum "\(" rxNum "-" rxNum "\)", "$1")
        line :=  RegExReplace(line, rxNum "\(-" rxNum "--" rxNum "\)", "$1")
        line :=  RegExReplace(line,  " . Unscalable Value" , "")
        key := This.Standardize(line)
        If (key ~= "^ \(.*\)$")
          Continue
        If (vals := This.MatchLine(line))
        {
          If (vals.Count() >= 2)
          {
            If (line ~= rxNum " to " rxNum || line ~= rxNum "-" rxNum)
              This.Affix[key] := (Format("{1:0.3g}",(vals[1] + vals[2]) / 2))
            Else
              This.Affix[key] := vals[1]
            For k, v in vals
              This.Affix[ key "_value"k ] := v
          }
          Else If (vals.Count() == 1)
          {
            If This.Affix[key]
              This.Affix[key] += vals[1]
            Else
              This.Affix[key] := vals[1]
          }
        }
        Else
          This.Affix[key] := True
      }
    }
    MatchLine(lineString){
      If (RegExMatch(lineString, "O`am)" rxNum "[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" , RxMatch))
      {
        ret := {}
        Loop % RxMatch.Count()
        {
          If RxMatch[A_Index] != ""
            ret.push(RxMatch[A_Index])
        }
        Return ret
      }
      Else
        Return False
    }
    Standardize(str:=""){
      str := RegExReplace(str, "\+?"rxNum , "#")
      ; str := RegExReplace(str, "#\(#-#\)" , "#")
      str := RegExReplace(str, " (augmented)" , "")
      Return str
    }
    MatchPseudoAffix(){
      for k, v in This.Affix
      {
        ; Standardize implicit and crafted for Pseudo sums
        ; Implicits can be disable being merge into Pseudos checking YesCLFIgnoreImplicit
        If (RegExMatch(k, "`am) \((.*)\)$", RxMatch) && YesCLFIgnoreImplicit)	
        {
          If (RxMatch1 != "crafted")
          {
            Continue
          }
        }
        trimKey := RegExReplace(k," \(.*\)$","")
        ; Singular Resistances
        If (trimKey = "# to maximum Life")
        {
          This.AddPseudoAffix("(Pseudo) Total to Maximum Life",k)
        }
        If (trimKey = "#% to Cold Resistance")
        {
          This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
        }
        Else If (trimKey = "#% to Fire Resistance")
        {
          This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
        }
        Else If (trimKey = "#% to Lightning Resistance")
        {
          This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
        }
        Else If (trimKey = "#% to Chaos Resistance")
        {
          This.AddPseudoAffix("(Pseudo) Total to Chaos Resistance",k)
        }
        ; Double Resistances
        Else If (trimKey = "#% to Cold and Lightning Resistances")
        {
          This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
          This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
        }
        Else If (trimKey = "#% to Fire and Cold Resistances")
        {
          This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
          This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
        }
        Else If (trimKey = "#% to Fire and Lightning Resistances")
        {
          This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
          This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
        }
        ; All Resistances
        Else If (trimKey = "#% to all Elemental Resistances")
        {
          This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
          This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
          This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
        }
        ; Attributes Singular
        Else If (trimKey = "# to Intelligence")
        {
          This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
        }
        Else If (trimKey = "# to Dexterity")
        {
          This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
        }
        Else If (trimKey = "# to Strength")
        {
          This.AddPseudoAffix("(Pseudo) Total to Strength",k)
        }
        ; Double Atributes
        Else If (trimKey = "# to Strength and Dexterity")
        {
          This.AddPseudoAffix("(Pseudo) Total to Strength",k)
          This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
        }
        Else If (trimKey = "# to Dexterity and Intelligence")
        {
          This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
          This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
        }
        Else If (trimKey = "# to Strength and Intelligence")
        {
          This.AddPseudoAffix("(Pseudo) Total to Strength",k)
          This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
        }
        ; All Atribbutes
        Else If (trimKey = "# to all Attributes")
        {
          This.AddPseudoAffix("(Pseudo) Total to Strength",k)
          This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
          This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
        }
        ; Singular Armour Affix
        Else If (trimKey = "#% increased Armour")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
        }
        Else If (trimKey = "#% increased Evasion Rating")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
        }
        Else If (trimKey = "#% increased Energy Shield")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
        }
        Else If (trimKey = "#% to maximum Energy Shield")
        {
          This.AddPseudoAffix("(Pseudo) Total to Maximum Energy Shield",k)
        }
        ; Double Armour Affix
        Else If (trimKey = "#% increased Evasion and Energy Shield")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
          This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
        }
        Else If (trimKey = "#% increased Armour and Energy Shield")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
          This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k) 
        }
        Else If (trimKey = "#% increased Armour and Evasion")
        {
          This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
          This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
        }
        ; Damage Mods
        Else If (trimKey = "Adds # to # Physical Damage to Attacks")
        {
          This.AddPseudoAffix("(Pseudo) Add Physical Damage to Attacks",k)
        }
        Else If (trimKey = "Adds # to # Physical Damage to Spells")
        {
          This.AddPseudoAffix("(Pseudo) Add Physical Damage to Spells",k)
        }
        Else If (trimKey = "Adds # to # Cold Damage to Attacks")
        {
          This.AddPseudoAffix("(Pseudo) Add Cold Damage to Attacks",k)
        }
        Else If (trimKey = "Adds # to # Cold Damage to Spells")
        {
          This.AddPseudoAffix("(Pseudo) Add Cold Damage to Spells",k)
        }
        Else If (trimKey = "Adds # to # Fire Damage to Attacks")
        {
          This.AddPseudoAffix("(Pseudo) Add Fire Damage to Attacks",k)
        }
        Else If (trimKey = "Adds # to # Fire Damage to Spells")
        {
          This.AddPseudoAffix("(Pseudo) Add Fire Damage to Spells",k)
        }
        Else If (trimKey = "Adds # to # Lightning Damage to Attacks")
        {
          This.AddPseudoAffix("(Pseudo) Add Lightning Damage to Attacks",k)
        }
        Else If (trimKey = "Adds # to # Lightning Damage to Spells")
        {
          This.AddPseudoAffix("(Pseudo) Add Lightning Damage to Spells",k)
        }
        Else If (trimKey = "Adds # to # Chaos Damage to Attacks")
        {
          This.AddPseudoAffix("(Pseudo) Add Chaos Damage to Attacks",k)
        }
        Else If (trimKey = "Adds # to # Chaos Damage to Spells")
        {
          This.AddPseudoAffix("(Pseudo) Add Chaos Damage to Spells",k)
        }
        ; Spell Pseudo
        Else If (trimKey = "#% increased Lightning Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
        }
        Else If (trimKey = "#% increased Cold Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
        }
        Else If (trimKey = "#% increased Fire Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
        }
        Else If (trimKey = "#% increased Chaos Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Chaos Damage",k)
        }
        Else If (trimKey = "#% increased Spell Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Chaos Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Spell Damage",k)
        }
        Else If (trimKey = "#% increased Elemental Damage")
        {
          This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
          This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
        }
      }
      ; SUM Pseudo
      ; Total Elemental Resistance
      This.AddPseudoAffix("(Pseudo) Total to Elemental Resistance","(Pseudo) Total to Fire Resistance","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total to Elemental Resistance","(Pseudo) Total to Lightning Resistance","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total to Elemental Resistance","(Pseudo) Total to Cold Resistance","Pseudo")

      ; Total Resistance
      This.AddPseudoAffix("(Pseudo) Total to Resistance","(Pseudo) Total to Elemental Resistance","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total to Resistance","(Pseudo) Total to Chaos Resistance","Pseudo")
      aux := 0
      If (This.GetValue("Pseudo","(Pseudo) Total to Fire Resistance") > aux)
        aux := This.GetValue("Pseudo","(Pseudo) Total to Fire Resistance")
      If (This.GetValue("Pseudo","(Pseudo) Total to Cold Resistance") > aux)
        aux := This.GetValue("Pseudo","(Pseudo) Total to Cold Resistance")
      If (This.GetValue("Pseudo","(Pseudo) Total to Lightning Resistance") > aux)
        aux := This.GetValue("Pseudo","(Pseudo) Total to Lightning Resistance")
      If (This.GetValue("Pseudo","(Pseudo) Total to Chaos Resistance") > aux)
        aux := This.GetValue("Pseudo","(Pseudo) Total to Chaos Resistance")
      If(aux > 0)
      {
        This.Pseudo["(Pseudo) Total to Single Resistance"] := aux
      }

      ; Total Stats
      This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Strength","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Intelligence","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Dexterity","Pseudo")
      ; Maximum Life
      aux:= This.GetValue("Pseudo","(Pseudo) Total to Maximum Life")
      + (This.GetValue("Pseudo","(Pseudo) Total to Strength"))//2
      If(aux > 0)
      {
        This.Pseudo["(Pseudo) Total to Maximum Life"] := aux
      }
      aux:=""
      ; Total Flat Elemental Spell Damage
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Spells","(Pseudo) Add Cold Damage to Spells","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Spells","(Pseudo) Add Fire Damage to Spells","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Spells","(Pseudo) Add Lightning Damage to Spells","Pseudo")
      ; Total Flat Elemental Atack Dmg
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Attacks","(Pseudo) Add Cold Damage to Attacks","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Attacks","(Pseudo) Add Fire Damage to Attacks","Pseudo")
      This.AddPseudoAffix("(Pseudo) Total Elemental Damage to Attacks","(Pseudo) Add Lightning Damage to Attacks","Pseudo")
      ; Merge
      This.MergePseudoInAffixs()
    }
    GetValue(Type, Context){
      If !This[Type][Context]
      {
        return 0
      }
      Else
      {
        return This[Type][Context]
      }
    }
    AddPseudoAffix(PseudoKey,StandardKey,StandardType:="Affix"){
      HybridKey := "(Hybrid) " . StandardKey
      aux := This.GetValue("Pseudo", PseudoKey) + This.GetValue("Affix", HybridKey) + This.GetValue(StandardType, StandardKey)
      If  (aux != 0)
        This.Pseudo[PseudoKey] := aux
      return
    }
    MergePseudoInAffixs(){
      for k, v in This.Pseudo
      {
        This.Affix[k] := v
      }
      ; Free Object (Not needed)
      This.Pseudo := ""
      This.Delete("Pseudo")
    }
    FuckingSugoiFreeMate(){
      This.Data := ""
      This.Delete("Data")
    }
    MatchExtenalDB(){
      For k, v in QuestItems
      {
        If (v["Name"] = This.Prop.ItemName)
        {
          This.Prop.Item_Width := v["Width"]
          This.Prop.Item_Height := v["Height"]
          This.Prop.SpecialType := "Quest Item"
          Return
        }
      }
      If (!This.Prop.IsMap)
      {
        For k, v in Bases
        {
          If (v["name"] = This.Prop.ItemBase)
          {
            This.Prop.Item_Width := v["inventory_width"]
            This.Prop.Item_Height := v["inventory_height"]
            This.Prop.ItemBase := v["name"]
            This.Prop.DropLevel := v["drop_level"]

            If InStr(This.Prop.ItemClass, "Rings")
              This.Prop.Ring := True
            If InStr(This.Prop.ItemClass, "Amulets")
              This.Prop.Amulet := True
            If InStr(This.Prop.ItemClass, "Belts")
              This.Prop.Belt := True
            If (This.Prop.ItemClass = "Support Skill Gems")
              This.Prop.Support := True
            Break
          }
        }
      }
      ;Start Ninja DB Matching
      If (This.Prop.RarityCurrency)
      {
        If (This.Prop.ItemName ~= "Delirium Orb")
        {
          If This.MatchNinjaDB("DeliriumOrb")
            Return
        }
        If (This.Prop.ItemName ~= "Vial of")
        {
          If This.MatchNinjaDB("Vial")
            Return
        }
        Else If (This.Prop.ItemName ~= "Essence of")
        {
          If This.MatchNinjaDB("Essence")
            Return
        }
        Else If (This.Prop.Incubator )
        {
          If This.MatchNinjaDB("Incubator")
            Return
        }
        Else If (This.Prop.Oil )
        {
          If This.MatchNinjaDB("Oil")
            Return
        }
        Else If (This.Prop.ItemName ~= "Fossil" )
        {
          If This.MatchNinjaDB("Fossil")
            Return
        }
        Else If (This.Prop.ItemName ~= "Resonator" )
        {
          If This.MatchNinjaDB("Resonator")
            Return
        }
        If This.MatchNinjaDB("Currency")
          Return
      }
      If (This.Prop.RarityDivination)
      {
        If This.MatchNinjaDB("DivinationCard")
          Return
      }
      If (This.Prop.Prophecy)
      {
        If This.MatchNinjaDB("Prophecy")
          Return
      }
      If (This.Prop.TimelessSplinter || This.Prop.TimelessEmblem || This.Prop.BreachSplinter || This.Prop.Offering || This.Prop.Vessel || This.Prop.Scarab || This.Prop.SacrificeFragment || This.Prop.MortalFragment || This.Prop.GuardianFragment || This.Prop.ProphecyFragment|| This.Prop.ItemName ~= "Simulacrum")
      {
        If This.MatchNinjaDB("Fragment")
          Return
        If This.MatchNinjaDB("Scarab")
          Return
      }
      If (This.Prop.IsBeast)
      {
        If This.MatchNinjaDB("Beast", "ItemBase")
          Return
      }
      If (This.Prop.ItemClass ~= "Helmets" && This.Data.Blocks.HasKey("Enchant"))
      {
        For k, v in Ninja.HelmetEnchant
        {
          If (InStr(This.Data.Blocks.Enchant, v["name"]))
          {
            This.Prop.ChaosValue := This.GetValue("Prop","ChaosValue") + v["chaosValue"]
            This.Prop.ExaltValue := This.GetValue("Prop","ExaltValue") + v["exaltedValue"]
            This.Data.HelmNinja := v
            If (v["chaosValue"] >= 5)
              This.Prop.ValuableEnch := True
            Break
          }
        }
      }
      If (This.Prop.RarityUnique)
      {
        If (This.Prop.ItemClass ~= "(Belts|Amulets|Rings)")
        {
          If This.MatchNinjaDB("UniqueAccessory")
            Return
        }
        Else If (This.Prop.ItemClass ~= "(Body Armours|Gloves|Boots|Helmets|Shields|Quivers)")
        {
          If This.MatchNinjaDB("UniqueArmour")
            Return
        }
        Else If (This.Prop.ItemClass ~= "Flasks")
        {
          If This.MatchNinjaDB("UniqueFlask")
            Return
        }
        Else If (This.Prop.ItemClass ~= "Jewel")
        {
          If This.MatchNinjaDB("UniqueJewel")
            Return
        }
        Else If (This.Prop.IsWeapon)
        {
          If This.MatchNinjaDB("UniqueWeapon")
            Return
        }
        Else If (This.Prop.IsMap)
        {
          If This.MatchNinjaDB("UniqueMap","ItemBase","baseType")
            Return
        }
      }
      If (This.Prop.IsMap)
      {
        If This.MatchNinjaDB("Map","ItemBase","name")
          Return
      }
      If (This.Prop.ItemLevel >= 82 && This.Prop.Influence != "")
      {
        For k, v in Ninja.BaseType
        {
          If (This.Prop.ItemBase = v["name"] 
          && This.Prop.Influence ~= v["variant"] 
          && This.Prop.ItemLevel >= v["levelRequired"])
          {
            This.Prop.ChaosValue := v["chaosValue"]
            This.Prop.ExaltValue := v["exaltedValue"]
            This.Data.BaseNinja := v
            If (v["chaosValue"] >= 5)
              This.Prop.ValuableBase := True
            ; Return
            Break
          }
        }
      }
    }
    MatchNinjaDB(ApiStr,MatchKey:="ItemName",NinjaKey:="name"){
      For k, v in Ninja[ApiStr]
      {
        If (This.Prop[MatchKey] = v[NinjaKey])
        {
          If ((ApiStr = "Map" || ApiStr = "UniqueMap") 
          && This.Prop.Map_Tier < v["mapTier"])
            Continue
          If (v["links"] && ApiStr ~= "Unique"
          && This.Prop.Sockets_Link < v["links"])
            Continue
          This.Prop.ChaosValue := This.GetValue("Prop","ChaosValue") + v["chaosValue"]
          If v["exaltedValue"]
            This.Prop.ExaltValue := This.GetValue("Prop","ExaltValue") + v["exaltedValue"]
          This.Data.Ninja := v
          Return True
        }
      }
      Return False
    }
    DisplayPSA(){
      propText:=statText:=affixText:=modifierText:=""
      For key, value in This.Prop
      {
        If( RegExMatch(key, "^Required")
        || RegExMatch(key, "^Rating")
        || RegExMatch(key, "^Sockets")
        || RegExMatch(key, "^Quality")
        || RegExMatch(key, "^Map")
        || RegExMatch(key, "^Heist_")
        || RegExMatch(key, "^Stack")
        || RegExMatch(key, "^Weapon"))
        {
          If indexOf(key,this.MatchedCLF)
            statText .= "CLF⭐"
          statText .= key . ":  " . value . "`n"
        }
        Else
        {
          If indexOf(key,this.MatchedCLF)
            propText .= "CLF⭐"
          propText .= key . ":  " . value . "`n"
        }
      }

      GuiControl, ItemInfo:, ItemInfoPropText, %propText%

      GuiControl, ItemInfo:, ItemInfoStatText, %statText%

      For key, value in This.Affix
      {
        If(!This.Modifier[key]){
            If (value != 0 && value != "" && value != False){
            If indexOf(key,this.MatchedCLF){
              affixText .= "CLF⭐"
            }
            affixText .= key . ":  " . value . "`n"
            }
        }Else{
          If indexOf(key,this.MatchedCLF){
            modifierText .= "CLF⭐"
          }
          modifierText .= key . ":  " . value . "`n"
        }
      }
      GuiControl, ItemInfo:, ItemInfoAffixText, %affixText%

      GuiControl, ItemInfo:, ItemInfoModifierText, %modifierText%

    }
    GraphNinjaPrices(){
      If This.Data.HasKey("Ninja") || This.Data.HasKey("HelmNinja") || This.Data.HasKey("BaseNinja")
      {
        Gosub, ShowGraph
        Gui, ItemInfo: Show, AutoSize, % This.Prop.ItemName " Sparkline"
      }
      Else
      {
        GoSub, noDataGraph
        GoSub, HideGraph
        Gui, ItemInfo: Show, AutoSize, % This.Prop.ItemName " has no Graph Data" (This.Prop.IsMap?" for this Tier":"")
        Return
      }
        
      If (This.Data.Ninja["paySparkLine"])
      {
        dataPayPoint := This.Data.Ninja["paySparkLine"]["data"]
        dataRecPoint := This.Data.Ninja["receiveSparkLine"]["data"]
        totalPayChange := This.Data.Ninja["paySparkLine"]["totalChange"]
        totalRecChange := This.Data.Ninja["receiveSparkLine"]["totalChange"]

        basePayPoint := 0
        For k, v in dataPayPoint
        {
          If Abs(v) > basePayPoint
            basePayPoint := Abs(v)
        }
        If basePayPoint = 0
        FormatStr := "{1:0.0f}"
        Else If basePayPoint < 1
        FormatStr := "{1:0.3f}"
        Else If basePayPoint < 10
        FormatStr := "{1:0.2f}"
        Else If basePayPoint < 100
        FormatStr := "{1:0.1f}"
        Else If basePayPoint > 100
        FormatStr := "{1:0.0f}"

        GuiControl,ItemInfo: , PercentText1G1, % Format(FormatStr,(basePayPoint*1.0)) "`%"
        GuiControl,ItemInfo: , PercentText1G2, % Format(FormatStr,(basePayPoint*0.9)) "`%"
        GuiControl,ItemInfo: , PercentText1G3, % Format(FormatStr,(basePayPoint*0.8)) "`%"
        GuiControl,ItemInfo: , PercentText1G4, % Format(FormatStr,(basePayPoint*0.7)) "`%"
        GuiControl,ItemInfo: , PercentText1G5, % Format(FormatStr,(basePayPoint*0.6)) "`%"
        GuiControl,ItemInfo: , PercentText1G6, % Format(FormatStr,(basePayPoint*0.5)) "`%"
        GuiControl,ItemInfo: , PercentText1G7, % Format(FormatStr,(basePayPoint*0.4)) "`%"
        GuiControl,ItemInfo: , PercentText1G8, % Format(FormatStr,(basePayPoint*0.3)) "`%"
        GuiControl,ItemInfo: , PercentText1G9, % Format(FormatStr,(basePayPoint*0.2)) "`%"
        GuiControl,ItemInfo: , PercentText1G10, % Format(FormatStr,(basePayPoint*0.1)) "`%"
        GuiControl,ItemInfo: , PercentText1G11, % "0`%"
        GuiControl,ItemInfo: , PercentText1G12, % Format(FormatStr,-(basePayPoint*0.1)) "`%"
        GuiControl,ItemInfo: , PercentText1G13, % Format(FormatStr,-(basePayPoint*0.2)) "`%"
        GuiControl,ItemInfo: , PercentText1G14, % Format(FormatStr,-(basePayPoint*0.3)) "`%"
        GuiControl,ItemInfo: , PercentText1G15, % Format(FormatStr,-(basePayPoint*0.4)) "`%"
        GuiControl,ItemInfo: , PercentText1G16, % Format(FormatStr,-(basePayPoint*0.5)) "`%"
        GuiControl,ItemInfo: , PercentText1G17, % Format(FormatStr,-(basePayPoint*0.6)) "`%"
        GuiControl,ItemInfo: , PercentText1G18, % Format(FormatStr,-(basePayPoint*0.7)) "`%"
        GuiControl,ItemInfo: , PercentText1G19, % Format(FormatStr,-(basePayPoint*0.8)) "`%"
        GuiControl,ItemInfo: , PercentText1G20, % Format(FormatStr,-(basePayPoint*0.9)) "`%"
        GuiControl,ItemInfo: , PercentText1G21, % Format(FormatStr,-(basePayPoint*1.0)) "`%"


        baseRecPoint := 0
        For k, v in dataRecPoint
        {
          If Abs(v) > baseRecPoint
            baseRecPoint := Abs(v)
        }
        If baseRecPoint = 0
        FormatStr := "{1:0.0f}"
        Else If baseRecPoint < 1
        FormatStr := "{1:0.3f}"
        Else If baseRecPoint < 10
        FormatStr := "{1:0.2f}"
        Else If baseRecPoint < 100
        FormatStr := "{1:0.1f}"
        Else If baseRecPoint > 100
        FormatStr := "{1:0.0f}"

        GuiControl,ItemInfo: , PercentText2G1, % Format(FormatStr,(baseRecPoint*1.0)) "`%"
        GuiControl,ItemInfo: , PercentText2G2, % Format(FormatStr,(baseRecPoint*0.9)) "`%"
        GuiControl,ItemInfo: , PercentText2G3, % Format(FormatStr,(baseRecPoint*0.8)) "`%"
        GuiControl,ItemInfo: , PercentText2G4, % Format(FormatStr,(baseRecPoint*0.7)) "`%"
        GuiControl,ItemInfo: , PercentText2G5, % Format(FormatStr,(baseRecPoint*0.6)) "`%"
        GuiControl,ItemInfo: , PercentText2G6, % Format(FormatStr,(baseRecPoint*0.5)) "`%"
        GuiControl,ItemInfo: , PercentText2G7, % Format(FormatStr,(baseRecPoint*0.4)) "`%"
        GuiControl,ItemInfo: , PercentText2G8, % Format(FormatStr,(baseRecPoint*0.3)) "`%"
        GuiControl,ItemInfo: , PercentText2G9, % Format(FormatStr,(baseRecPoint*0.2)) "`%"
        GuiControl,ItemInfo: , PercentText2G10, % Format(FormatStr,(baseRecPoint*0.1)) "`%"
        GuiControl,ItemInfo: , PercentText2G11, % "0`%"
        GuiControl,ItemInfo: , PercentText2G12, % Format(FormatStr,-(baseRecPoint*0.1)) "`%"
        GuiControl,ItemInfo: , PercentText2G13, % Format(FormatStr,-(baseRecPoint*0.2)) "`%"
        GuiControl,ItemInfo: , PercentText2G14, % Format(FormatStr,-(baseRecPoint*0.3)) "`%"
        GuiControl,ItemInfo: , PercentText2G15, % Format(FormatStr,-(baseRecPoint*0.4)) "`%"
        GuiControl,ItemInfo: , PercentText2G16, % Format(FormatStr,-(baseRecPoint*0.5)) "`%"
        GuiControl,ItemInfo: , PercentText2G17, % Format(FormatStr,-(baseRecPoint*0.6)) "`%"
        GuiControl,ItemInfo: , PercentText2G18, % Format(FormatStr,-(baseRecPoint*0.7)) "`%"
        GuiControl,ItemInfo: , PercentText2G19, % Format(FormatStr,-(baseRecPoint*0.8)) "`%"
        GuiControl,ItemInfo: , PercentText2G20, % Format(FormatStr,-(baseRecPoint*0.9)) "`%"
        GuiControl,ItemInfo: , PercentText2G21, % Format(FormatStr,-(baseRecPoint*1.0)) "`%"


        AvgPay := {}
        Loop 5
        {
          AvgPay[A_Index] := (dataPayPoint[A_Index+1] + dataPayPoint[A_Index+2]) / 2
        }
        paddedPayData := {}
        paddedPayData[1] := dataPayPoint[1]
        paddedPayData[2] := dataPayPoint[1]
        paddedPayData[3] := dataPayPoint[2]
        paddedPayData[4] := AvgPay[1]
        paddedPayData[5] := dataPayPoint[3]
        paddedPayData[6] := AvgPay[2]
        paddedPayData[7] := dataPayPoint[4]
        paddedPayData[8] := AvgPay[3]
        paddedPayData[9] := dataPayPoint[5]
        paddedPayData[10] := AvgPay[4]
        paddedPayData[11] := dataPayPoint[6]
        paddedPayData[12] := AvgPay[5]
        paddedPayData[13] := dataPayPoint[7]
        For k, v in paddedPayData
        {
          div := v / basePayPoint * 100
          XGraph_Plot( pGraph1, 100 - div, "", True )
          ;MsgBox % "Key : " k "   Val : " v
        }
        AvgRec := {}
        Loop 5
        {
          AvgRec[A_Index] := (dataRecPoint[A_Index+1] + dataRecPoint[A_Index+2]) / 2
        }
        paddedRecData := {}
        paddedRecData[1] := dataRecPoint[1]
        paddedRecData[2] := dataRecPoint[1]
        paddedRecData[3] := dataRecPoint[2]
        paddedRecData[4] := AvgRec[1]
        paddedRecData[5] := dataRecPoint[3]
        paddedRecData[6] := AvgRec[2]
        paddedRecData[7] := dataRecPoint[4]
        paddedRecData[8] := AvgRec[3]
        paddedRecData[9] := dataRecPoint[5]
        paddedRecData[10] := AvgRec[4]
        paddedRecData[11] := dataRecPoint[6]
        paddedRecData[12] := AvgRec[5]
        paddedRecData[13] := dataRecPoint[7]
        For k, v in paddedRecData
        {
          div := v / baseRecPoint * 100
          XGraph_Plot( pGraph2, 100 - div, "", True )
          ;MsgBox % "Key : " k "   Val : " v
        }

        GuiControl,ItemInfo: , GroupBox1, % "Sell " This.Prop.ItemName " to Chaos"
        GuiControl,ItemInfo: , PComment1, Sell Value
        GuiControl,ItemInfo: , PData1, % sellval := (1 / This.Data.Ninja["pay"]["value"])
        GuiControl,ItemInfo: , PComment2, Sell Value `% Change
        GuiControl,ItemInfo: , PData2, % This.Data.Ninja["paySparkLine"]["totalChange"]
        GuiControl,ItemInfo: , PComment3, Orb per Chaos
        GuiControl,ItemInfo: , PData3, % This.Data.Ninja["pay"]["value"]
        GuiControl,ItemInfo: , PComment4, Day 6 Change
        GuiControl,ItemInfo: , PData4, % dataPayPoint[2]
        GuiControl,ItemInfo: , PComment5, Day 5 Change
        GuiControl,ItemInfo: , PData5, % dataPayPoint[3]
        GuiControl,ItemInfo: , PComment6, Day 4 Change
        GuiControl,ItemInfo: , PData6, % dataPayPoint[4]
        GuiControl,ItemInfo: , PComment7, Day 3 Change
        GuiControl,ItemInfo: , PData7, % dataPayPoint[5]
        GuiControl,ItemInfo: , PComment8, Day 2 Change
        GuiControl,ItemInfo: , PData8, % dataPayPoint[6]
        GuiControl,ItemInfo: , PComment9, Day 1 Change
        GuiControl,ItemInfo: , PData9, % dataPayPoint[7]
        GuiControl,ItemInfo: , PComment10, % Decimal2Fraction(sellval,"ID3")
        GuiControl,ItemInfo: , PData10, C / O

        GuiControl,ItemInfo: , GroupBox2, % "Buy " This.Prop.ItemName " from Chaos"
        GuiControl,ItemInfo: , SComment1, Buy Value
        GuiControl,ItemInfo: , SData1, % sellval := (This.Data.Ninja["receive"]["value"])
        GuiControl,ItemInfo: , SComment2, Buy Value `% Change
        GuiControl,ItemInfo: , SData2, % This.Data.Ninja["receiveSparkLine"]["totalChange"]
        GuiControl,ItemInfo: , SComment3, Orb per Chaos
        GuiControl,ItemInfo: , SData3, % 1 / This.Data.Ninja["receive"]["value"]
        GuiControl,ItemInfo: , SComment4, Day 6 Change
        GuiControl,ItemInfo: , SData4, % dataRecPoint[2]
        GuiControl,ItemInfo: , SComment5, Day 5 Change
        GuiControl,ItemInfo: , SData5, % dataRecPoint[3]
        GuiControl,ItemInfo: , SComment6, Day 4 Change
        GuiControl,ItemInfo: , SData6, % dataRecPoint[4]
        GuiControl,ItemInfo: , SComment7, Day 3 Change
        GuiControl,ItemInfo: , SData7, % dataRecPoint[5]
        GuiControl,ItemInfo: , SComment8, Day 2 Change
        GuiControl,ItemInfo: , SData8, % dataRecPoint[6]
        GuiControl,ItemInfo: , SComment9, Day 1 Change
        GuiControl,ItemInfo: , SData9, % dataRecPoint[7]
        GuiControl,ItemInfo: , SComment10, % Decimal2Fraction(sellval,"ID3")
        GuiControl,ItemInfo: , SData10, C / O

      }
      Else If (This.Data.Ninja["sparkline"] || This.Data.HelmNinja["sparkline"] || This.Data.BaseNinja["sparkline"] )
      {
        LTGraph := HTGraph := True
        If (This.Data.HasKey("Ninja"))
        {
          HTGraph := "Name"
          dataPoint := This.Data.Ninja["sparkline"]["data"]
          totalChange := This.Data.Ninja["sparkline"]["totalChange"]
        }
        Else
          HTGraph := False

        If (This.Data.HasKey("HelmNinja") && This.Data.HasKey("BaseNinja"))
        {
          dataPoint := This.Data.BaseNinja["sparkline"]["data"]
          totalChange := This.Data.BaseNinja["sparkline"]["totalChange"]
          dataLTPoint := This.Data.HelmNinja["sparkline"]["data"]
          totalLTChange := This.Data.HelmNinja["sparkline"]["totalChange"]
          HTGraph := "Base"
          LTGraph := "Helm"
        }
        Else If (This.Data.HasKey("BaseNinja"))
        {
          dataLTPoint := This.Data.BaseNinja["sparkline"]["data"]
          totalLTChange := This.Data.BaseNinja["sparkline"]["totalChange"]
          LTGraph := "Base"
        }
        Else If (This.Data.HasKey("HelmNinja"))
        {
          dataLTPoint := This.Data.HelmNinja["sparkline"]["data"]
          totalLTChange := This.Data.HelmNinja["sparkline"]["totalChange"]
          LTGraph := "Helm"
        }
        Else
        {
          LTGraph := False
          GoSub, noDataGraph2
          GoSub, noDataGraph2
        }

        If (HTGraph)
        {
          basePoint := 0
          For k, v in dataPoint
          {
            If (Abs(v) > basePoint)
              basePoint := Abs(v)
          }
          If basePoint = 0
          FormatStr := "{1:0.0f}"
          Else If basePoint < 1
          FormatStr := "{1:0.3f}"
          Else If basePoint < 10
          FormatStr := "{1:0.2f}"
          Else If basePoint < 100
          FormatStr := "{1:0.1f}"
          Else If basePoint > 100
          FormatStr := "{1:0.0f}"

          GuiControl,ItemInfo: , PercentText1G1, % Format(FormatStr,(basePoint*1.0)) "`%"
          GuiControl,ItemInfo: , PercentText1G2, % Format(FormatStr,(basePoint*0.9)) "`%"
          GuiControl,ItemInfo: , PercentText1G3, % Format(FormatStr,(basePoint*0.8)) "`%"
          GuiControl,ItemInfo: , PercentText1G4, % Format(FormatStr,(basePoint*0.7)) "`%"
          GuiControl,ItemInfo: , PercentText1G5, % Format(FormatStr,(basePoint*0.6)) "`%"
          GuiControl,ItemInfo: , PercentText1G6, % Format(FormatStr,(basePoint*0.5)) "`%"
          GuiControl,ItemInfo: , PercentText1G7, % Format(FormatStr,(basePoint*0.4)) "`%"
          GuiControl,ItemInfo: , PercentText1G8, % Format(FormatStr,(basePoint*0.3)) "`%"
          GuiControl,ItemInfo: , PercentText1G9, % Format(FormatStr,(basePoint*0.2)) "`%"
          GuiControl,ItemInfo: , PercentText1G10, % Format(FormatStr,(basePoint*0.1)) "`%"
          GuiControl,ItemInfo: , PercentText1G11, % "0`%"
          GuiControl,ItemInfo: , PercentText1G12, % Format(FormatStr,-(basePoint*0.1)) "`%"
          GuiControl,ItemInfo: , PercentText1G13, % Format(FormatStr,-(basePoint*0.2)) "`%"
          GuiControl,ItemInfo: , PercentText1G14, % Format(FormatStr,-(basePoint*0.3)) "`%"
          GuiControl,ItemInfo: , PercentText1G15, % Format(FormatStr,-(basePoint*0.4)) "`%"
          GuiControl,ItemInfo: , PercentText1G16, % Format(FormatStr,-(basePoint*0.5)) "`%"
          GuiControl,ItemInfo: , PercentText1G17, % Format(FormatStr,-(basePoint*0.6)) "`%"
          GuiControl,ItemInfo: , PercentText1G18, % Format(FormatStr,-(basePoint*0.7)) "`%"
          GuiControl,ItemInfo: , PercentText1G19, % Format(FormatStr,-(basePoint*0.8)) "`%"
          GuiControl,ItemInfo: , PercentText1G20, % Format(FormatStr,-(basePoint*0.9)) "`%"
          GuiControl,ItemInfo: , PercentText1G21, % Format(FormatStr,-(basePoint*1.0)) "`%"

          Avg := {}
          Loop 5
          {
            Avg[A_Index] := ((dataPoint[A_Index+1]?dataPoint[A_Index+1]:0) + (dataPoint[A_Index+2]?dataPoint[A_Index+2]:0)) / 2
          }
          paddedData := {}
          paddedData[1] := (dataPoint[1]?dataPoint[1]:0)
          paddedData[2] := (dataPoint[1]?dataPoint[1]:0)
          paddedData[3] := (dataPoint[2]?dataPoint[2]:0)
          paddedData[4] := (Avg[1]?Avg[1]:0)
          paddedData[5] := (dataPoint[3]?dataPoint[3]:0)
          paddedData[6] := (Avg[2]?Avg[2]:0)
          paddedData[7] := (dataPoint[4]?dataPoint[4]:0)
          paddedData[8] := (Avg[3]?Avg[3]:0)
          paddedData[9] := (dataPoint[5]?dataPoint[5]:0)
          paddedData[10] := (Avg[4]?Avg[4]:0)
          paddedData[11] := (dataPoint[6]?dataPoint[6]:0)
          paddedData[12] := (Avg[5]?Avg[5]:0)
          paddedData[13] := (dataPoint[7]?dataPoint[7]:0)
          For k, v in paddedData
          {
            div := v / basePoint * 100
            XGraph_Plot( pGraph1, 100 - div, "", True )
            ;MsgBox % "Key : " k "   Val : " v
          }

          GuiControl,ItemInfo: , GroupBox1, % (HTGraph = "Name"?"Value of " This.Prop.ItemName : (HTGraph = "Base" ? "Value of " This.Prop.ItemBase :"Value Title Undefined") )
          GuiControl,ItemInfo: , PComment1, Chaos Value
          GuiControl,ItemInfo: , PData1, % (HTGraph = "Name"?This.Data.Ninja["chaosValue"]:(HTGraph = "Base"?This.Data.BaseNinja["chaosValue"]:""))
          GuiControl,ItemInfo: , PComment2, Exalted Value
          GuiControl,ItemInfo: , PData2, % (HTGraph = "Name"?This.Data.Ninja["exaltedValue"]:(HTGraph = "Base"?This.Data.BaseNinja["exaltedValue"]:""))
          GuiControl,ItemInfo: , PComment3, Chaos Value `% Change
          GuiControl,ItemInfo: , PData3, % (HTGraph = "Name"?This.Data.Ninja["sparkline"]["totalChange"]:(HTGraph = "Base"?This.Data.BaseNinja["sparkline"]["totalChange"]:""))
          GuiControl,ItemInfo: , PComment4, Day 6 Change
          GuiControl,ItemInfo: , PData4, % dataPoint[2]
          GuiControl,ItemInfo: , PComment5, Day 5 Change
          GuiControl,ItemInfo: , PData5, % dataPoint[3]
          GuiControl,ItemInfo: , PComment6, Day 4 Change
          GuiControl,ItemInfo: , PData6, % dataPoint[4]
          GuiControl,ItemInfo: , PComment7, Day 3 Change
          GuiControl,ItemInfo: , PData7, % dataPoint[5]
          GuiControl,ItemInfo: , PComment8, Day 2 Change
          GuiControl,ItemInfo: , PData8, % dataPoint[6]
          GuiControl,ItemInfo: , PComment9, Day 1 Change
          GuiControl,ItemInfo: , PData9, % dataPoint[7]
          GuiControl,ItemInfo: , PComment10, 
          GuiControl,ItemInfo: , PData10,
        }
        Else
        {
          Gosub, noDataGraph1
          Gosub, HideGraph1
        }

        If (LTGraph)
        {
          baseLTPoint := 0
          For k, v in dataLTPoint
          {
            If Abs(v) > baseLTPoint
              baseLTPoint := Abs(v)
          }
          If baseLTPoint = 0
          FormatStr := "{1:0.0f}"
          If baseLTPoint < 1
          FormatStr := "{1:0.3f}"
          Else If baseLTPoint < 10
          FormatStr := "{1:0.2f}"
          Else If baseLTPoint < 100
          FormatStr := "{1:0.1f}"
          Else If baseLTPoint > 100
          FormatStr := "{1:0.0f}"

          GuiControl,ItemInfo: , PercentText2G1, % Format(FormatStr,(baseLTPoint*1.0)) "`%"
          GuiControl,ItemInfo: , PercentText2G2, % Format(FormatStr,(baseLTPoint*0.9)) "`%"
          GuiControl,ItemInfo: , PercentText2G3, % Format(FormatStr,(baseLTPoint*0.8)) "`%"
          GuiControl,ItemInfo: , PercentText2G4, % Format(FormatStr,(baseLTPoint*0.7)) "`%"
          GuiControl,ItemInfo: , PercentText2G5, % Format(FormatStr,(baseLTPoint*0.6)) "`%"
          GuiControl,ItemInfo: , PercentText2G6, % Format(FormatStr,(baseLTPoint*0.5)) "`%"
          GuiControl,ItemInfo: , PercentText2G7, % Format(FormatStr,(baseLTPoint*0.4)) "`%"
          GuiControl,ItemInfo: , PercentText2G8, % Format(FormatStr,(baseLTPoint*0.3)) "`%"
          GuiControl,ItemInfo: , PercentText2G9, % Format(FormatStr,(baseLTPoint*0.2)) "`%"
          GuiControl,ItemInfo: , PercentText2G10, % Format(FormatStr,(baseLTPoint*0.1)) "`%"
          GuiControl,ItemInfo: , PercentText2G11, % "0`%"
          GuiControl,ItemInfo: , PercentText2G12, % Format(FormatStr,-(baseLTPoint*0.1)) "`%"
          GuiControl,ItemInfo: , PercentText2G13, % Format(FormatStr,-(baseLTPoint*0.2)) "`%"
          GuiControl,ItemInfo: , PercentText2G14, % Format(FormatStr,-(baseLTPoint*0.3)) "`%"
          GuiControl,ItemInfo: , PercentText2G15, % Format(FormatStr,-(baseLTPoint*0.4)) "`%"
          GuiControl,ItemInfo: , PercentText2G16, % Format(FormatStr,-(baseLTPoint*0.5)) "`%"
          GuiControl,ItemInfo: , PercentText2G17, % Format(FormatStr,-(baseLTPoint*0.6)) "`%"
          GuiControl,ItemInfo: , PercentText2G18, % Format(FormatStr,-(baseLTPoint*0.7)) "`%"
          GuiControl,ItemInfo: , PercentText2G19, % Format(FormatStr,-(baseLTPoint*0.8)) "`%"
          GuiControl,ItemInfo: , PercentText2G20, % Format(FormatStr,-(baseLTPoint*0.9)) "`%"
          GuiControl,ItemInfo: , PercentText2G21, % Format(FormatStr,-(baseLTPoint*1.0)) "`%"

          LTAvg := {}
          Loop 5
          {
            LTAvg[A_Index] := (dataLTPoint[A_Index+1] + dataLTPoint[A_Index+2]) / 2
          }
          paddedLTData := {}
          paddedLTData[1] := (dataLTPoint[1]?dataLTPoint[1]:0)
          paddedLTData[2] := (dataLTPoint[1]?dataLTPoint[1]:0)
          paddedLTData[3] := (dataLTPoint[2]?dataLTPoint[2]:0)
          paddedLTData[4] := (LTAvg[1]?LTAvg[1]:0)
          paddedLTData[5] := (dataLTPoint[3]?dataLTPoint[3]:0)
          paddedLTData[6] := (LTAvg[2]?LTAvg[2]:0)
          paddedLTData[7] := (dataLTPoint[4]?dataLTPoint[4]:0)
          paddedLTData[8] := (LTAvg[3]?LTAvg[3]:0)
          paddedLTData[9] := (dataLTPoint[5]?dataLTPoint[5]:0)
          paddedLTData[10] := (LTAvg[4]?LTAvg[4]:0)
          paddedLTData[11] := (dataLTPoint[6]?dataLTPoint[6]:0)
          paddedLTData[12] := (LTAvg[5]?LTAvg[5]:0)
          paddedLTData[13] := (dataLTPoint[7]?dataLTPoint[7]:0)
          For k, v in paddedLTData
          {
            div := v / baseLTPoint * 100
            XGraph_Plot( pGraph2, 100 - div, "", True )
            ;MsgBox % "Key : " k "   Val : " v
          }

          GuiControl,ItemInfo: , GroupBox2, % (LTGraph = "Base"? ("Value of " This.Prop.ItemLevel " " This.Prop.Influence " " This.Prop.ItemBase ) : (LTGraph = "Helm" ? "Value of " This.Data.HelmNinja["name"] : "") )
          GuiControl,ItemInfo: , SComment1, Chaos Value
          GuiControl,ItemInfo: , SData1, % (LTGraph = "Base"? This.Data.BaseNinja["chaosValue"] : (LTGraph = "Helm" ? This.Data.HelmNinja["chaosValue"] : "") )
          GuiControl,ItemInfo: , SComment2, 
          GuiControl,ItemInfo: , SData2, 
          GuiControl,ItemInfo: , SComment3, Chaos Value `% Change
          GuiControl,ItemInfo: , SData3, % (LTGraph = "Base"? This.Data.BaseNinja["sparkline"]["totalChange"] : (LTGraph = "Helm" ? This.Data.HelmNinja["sparkline"]["totalChange"] : "") )
          GuiControl,ItemInfo: , SComment4, Day 6 Change
          GuiControl,ItemInfo: , SData4, % dataLTPoint[2]
          GuiControl,ItemInfo: , SComment5, Day 5 Change
          GuiControl,ItemInfo: , SData5, % dataLTPoint[3]
          GuiControl,ItemInfo: , SComment6, Day 4 Change
          GuiControl,ItemInfo: , SData6, % dataLTPoint[4]
          GuiControl,ItemInfo: , SComment7, Day 3 Change
          GuiControl,ItemInfo: , SData7, % dataLTPoint[5]
          GuiControl,ItemInfo: , SComment8, Day 2 Change
          GuiControl,ItemInfo: , SData8, % dataLTPoint[6]
          GuiControl,ItemInfo: , SComment9, Day 1 Change
          GuiControl,ItemInfo: , SData9, % dataLTPoint[7]
          GuiControl,ItemInfo: , SComment10,
          GuiControl,ItemInfo: , SData10,
        }
        Else
        {
          Gosub, noDataGraph2
          Gosub, HideGraph2
        }

      }
      Return

      noDataGraph:
        GoSub, noDataGraph1
        GoSub, noDataGraph2
      Return

      noDataGraph1:
        Loop 21
        {
          GuiControl,ItemInfo: , PercentText1G%A_Index%, 0`%
        }
        GuiControl,ItemInfo: , GroupBox1, No Data
        Loop 13
        {
          XGraph_Plot( pGraph1, 100, "", True )
        }
        Loop 10
        {
          GuiControl,ItemInfo: , PComment%A_Index%,
          GuiControl,ItemInfo: , PData%A_Index%,
        }
      Return

      noDataGraph2:
        Loop 21
        {
          GuiControl,ItemInfo: , PercentText2G%A_Index%, 0`%
        }
        GuiControl,ItemInfo: , GroupBox2, No Data
        Loop 13
        {
          XGraph_Plot( pGraph2, 100, "", True )
        }
        Loop 10
        {
          GuiControl,ItemInfo: , SComment%A_Index%,
          GuiControl,ItemInfo: , SData%A_Index%,
        }
      Return

      HideGraph:
        GoSub, HideGraph1
        GoSub, HideGraph2
      Return

      HideGraph1:
        Loop 21
        {
          GuiControl,ItemInfo: Hide, PercentText1G%A_Index%
        }
        GuiControl,ItemInfo: Hide, pGraph1
        GuiControl,ItemInfo: Hide, GroupBox1
        Loop 10
        {
          GuiControl,ItemInfo: Hide, PComment%A_Index%
          GuiControl,ItemInfo: Hide, PData%A_Index%
        }
      Return

      HideGraph2:
        Loop 21
        {
          GuiControl,ItemInfo: Hide, PercentText2G%A_Index%
        }
        GuiControl,ItemInfo: Hide, pGraph2
        GuiControl,ItemInfo: Hide, GroupBox2
        Loop 10
        {
          GuiControl,ItemInfo: Hide, SComment%A_Index%
          GuiControl,ItemInfo: Hide, SData%A_Index%
        }
      Return

      ShowGraph:
        Loop 2
        {
          aVal := A_Index
          Loop 21
          {
            GuiControl,ItemInfo: Show, PercentText%aVal%G%A_Index%
          }
          GuiControl,ItemInfo: Show, pGraph%aVal%
          GuiControl,ItemInfo: Show, GroupBox%aVal%
        }
        Loop 10
        {
          GuiControl,ItemInfo: Show, PComment%A_Index%
          GuiControl,ItemInfo: Show, PData%A_Index%
          GuiControl,ItemInfo: Show, SComment%A_Index%
          GuiControl,ItemInfo: Show, SData%A_Index%
        }
        aVal := ""
      Return
    }
    ItemInfo(){
      This.MatchLootFilter()
      This.DisplayPSA()
      This.GraphNinjaPrices()
    }
    MatchStashManagement(passthrough:=False){
      ; Create associative array so HasKey function can be used
      UnsupportedAffinityCurrencies := { "Stacked Deck":0
                                        , "Prime Regrading Lens":0
                                        , "Secondary Regrading Lens":0
                                        , "Veiled Chaos Orb":0
                                        , "Vial of Transcendence":0
                                        , "Vial of Sacrifice":0
                                        , "Vial of the Ghost":0
                                        , "Vial of Consequence":0
                                        , "Vial of Summoning":0
                                        , "Vial of Dominance":0
                                        , "Vial of Awakening":0
                                        , "Vial of the Ritual":0
                                        , "Vial of Fate":0
                                        , "Bestiary Orb":0
                                        , "Blessing of Chayula":0
                                        , "Blessing of Xoph":0
                                        , "Blessing of Uul-Netol":0
                                        , "Blessing of Tul":0
                                        , "Blessing of Esh":0 }
      If (StashTabYesCurrency && This.Prop.RarityCurrency && (This.Prop.SpecialType="" || This.Prop.SpecialType = "Ritual Item"))
      {
        If (StashTabYesCurrency > 1 && !UnsupportedAffinityCurrencies.HasKey(This.Prop.ItemName))
          sendstash := -2
        Else
          sendstash := StashTabCurrency
      }
      Else If (StashTabYesNinjaPrice && This.Prop.ChaosValue >= StashTabYesNinjaPrice_Price && !This.Prop.IsMap)
        sendstash := StashTabNinjaPrice
      Else If (This.Prop.Incubator)
        Return -1
      ;Affinities
      Else If (This.Prop.IsBlightedMap || This.Prop.Oil) && StashTabYesBlight
      {
        If StashTabYesBlight > 1
          sendstash := -2
        Else
          sendstash := StashTabBlight
      }
      Else If ((This.Prop.IsBrickedMap) && StashTabYesBrickedMaps)
          sendstash := StashTabBrickedMaps
      Else If (This.Prop.IsMap && StashTabYesMap)
      {
        If StashTabYesMap > 1
          sendstash := -2
        Else
          sendstash := StashTabMap
      }
      Else If (This.Prop.Catalyst || This.Prop.IsOrgan != "") && StashTabYesMetamorph
      {
        If StashTabYesMetamorph > 1
          sendstash := -2
        Else
          sendstash := StashTabMetamorph
      }
      Else If (This.Prop.SpecialType="Delirium" && StashTabYesDelirium)
      {
        If StashTabYesDelirium > 1
          sendstash := -2
        Else
          sendstash := StashTabDelirium
      }
      Else If (This.Prop.TimelessSplinter || This.Prop.TimelessEmblem || This.Prop.BreachSplinter || This.Prop.Offering || This.Prop.UberDuberOffering || This.Prop.Vessel || This.Prop.Scarab || This.Prop.SacrificeFragment || This.Prop.MortalFragment || This.Prop.GuardianFragment || This.Prop.ProphecyFragment )&&StashTabYesFragment
      {
        If StashTabYesFragment > 1 
          sendstash := -2
        Else
          sendstash := StashTabFragment 
      }
      Else If (This.Prop.RarityDivination) && StashTabYesDivination
      {
        If StashTabYesDivination > 1
          sendstash := -2
        Else
          sendstash := StashTabDivination
      }
      Else If (This.Prop.Essence) && StashTabYesEssence
      {
        If StashTabYesEssence > 1
          sendstash := -2
        Else
          sendstash := StashTabEssence
      }
      Else If (This.Prop.Fossil || This.Prop.Resonator) && StashTabYesDelve
      {
        If StashTabYesDelve > 1
          sendstash := -2
        Else
          sendstash := StashTabDelve
      }
      Else If ((StashTabYesUnique||StashTabYesUniqueRing||StashTabYesUniqueDump) && This.Prop.RarityUnique && This.Prop.IsOrgan="" 
      &&( !StashTabYesUniquePercentage || (StashTabYesUniquePercentage && This.Prop.UniquePercentage >= StashTabUniquePercentage) ) )
      {
        If (StashTabYesUnique = 2)
          Return -2
        Else if (StashTabYesUnique)
        sendstash := StashTabUnique
        Else If (StashTabYesUniqueRing&&This.Prop.Ring)
        sendstash := StashTabUniqueRing
        Else If (StashTabYesUniqueDump)
        sendstash := StashTabUniqueDump
      }
      Else If ( ((StashTabYesUniqueRing&&StashTabYesUniqueRingAll&&This.Prop.Ring) || (StashTabYesUniqueDump&&StashTabYesUniqueDumpAll)) && This.Prop.RarityUnique && This.Prop.IsOrgan="" 
      && (StashTabYesUniquePercentage && This.Prop.UniquePercentage < StashTabUniquePercentage)  )
      {
        If (StashTabYesUniqueRing&&StashTabYesUniqueRingAll&&This.Prop.Ring)
        sendstash := StashTabUniqueRing
        Else If (StashTabYesUniqueDump&&StashTabYesUniqueDumpAll)
        sendstash := StashTabUniqueDump
      }
      Else If (This.Prop.MiscMapItem&&StashTabYesMiscMapItems)
      {
        sendstash := StashTabMiscMapItems
      }
      Else If (This.Prop.Flask&&(This.Prop.Quality>0)&&StashTabYesFlaskQuality&&!This.Prop.RarityUnique)
        sendstash := StashTabFlaskQuality
      Else If (This.Prop.RarityGem)
      {
        If ((This.Prop.Quality>0)&&StashTabYesGemQuality)
          sendstash := StashTabGemQuality
        Else If (This.Prop.VaalGem && StashTabYesGemVaal)
          sendstash := StashTabGemVaal
        Else If (This.Prop.Support && StashTabYesGemSupport)
          sendstash := StashTabGemSupport
        Else If (StashTabYesGem)
          sendstash := StashTabGem
      }
      Else If (This.Prop.IsInfluenceItem&&StashTabYesInfluencedItem)
        sendstash := StashTabInfluencedItem
      Else If ((This.Prop.Sockets_Link >= 5)&&StashTabYesLinked)
        sendstash := StashTabLinked
      Else If (This.Prop.Prophecy&&StashTabYesProphecy)
        sendstash := StashTabProphecy
      Else If (This.Prop.Veiled&&StashTabYesVeiled)
        sendstash := StashTabVeiled
      Else If (This.Prop.ClusterJewel&&StashTabYesClusterJewel)
        sendstash := StashTabClusterJewel
      Else If (This.Prop.HeistGear&&StashTabYesHeistGear)
        sendstash := StashTabHeistGear
      Else If (StashTabYesCrafting 
        && ((YesStashATLAS && This.Prop.CraftingBase = "Atlas Base" && ((This.Prop.ItemLevel >= YesStashATLASCraftingIlvlMin && YesStashATLASCraftingIlvl) || !YesStashATLASCraftingIlvl)) 
          || (YesStashSTR && This.Prop.CraftingBase = "STR Base" && ((This.Prop.ItemLevel >= YesStashSTRCraftingIlvlMin && YesStashSTRCraftingIlvl) || !YesStashSTRCraftingIlvl)) 
          || (YesStashDEX && This.Prop.CraftingBase = "DEX Base" && ((This.Prop.ItemLevel >= YesStashDEXCraftingIlvlMin && YesStashDEXCraftingIlvl) || !YesStashDEXCraftingIlvl)) 
          || (YesStashINT && This.Prop.CraftingBase = "INT Base" && ((This.Prop.ItemLevel >= YesStashINTCraftingIlvlMin && YesStashINTCraftingIlvl) || !YesStashINTCraftingIlvl)) 
          || (YesStashHYBRID && This.Prop.CraftingBase = "Hybrid Base" && ((This.Prop.ItemLevel >= YesStashHYBRIDCraftingIlvlMin && YesStashHYBRIDCraftingIlvl) || !YesStashHYBRIDCraftingIlvl)) 
          || (YesStashJ && This.Prop.CraftingBase = "Jewel Base" && ((This.Prop.ItemLevel >= YesStashJCraftingIlvlMin && YesStashJCraftingIlvl) || !YesStashJCraftingIlvl)) 
          || (YesStashAJ && This.Prop.CraftingBase = "Abyss Jewel Base" && ((This.Prop.ItemLevel >= YesStashAJCraftingIlvlMin && YesStashAJCraftingIlvl) || !YesStashAJCraftingIlvl))
          || (YesStashJewellery && This.Prop.CraftingBase = "Jewellery Base" && ((This.Prop.ItemLevel >= YesStashJewelleryCraftingIlvlMin && YesStashJewelleryCraftingIlvl) || !YesStashJewelleryCraftingIlvl)) )
        && (!This.Prop.Corrupted))
        sendstash := StashTabCrafting
      Else If (StashTabYesPredictive && PPServerStatus && This.Prop.PredictPrice >= StashTabYesPredictive_Price ){
        sendstash := StashTabPredictive
      }
      Else If (ChaosRecipeEnableFunction && This.StashChaosRecipe(passthrough))
      {
        If (ChaosRecipeStashMethodDump)
          sendstash := StashTabDump
        Else If (ChaosRecipeStashMethodTab)
          sendstash := ChaosRecipeStashTab
        Else If (ChaosRecipeStashMethodSort)
        {
          If (This.Prop.SlotType = "Body")
            sendstash := ChaosRecipeStashTabArmour
          Else If (This.Prop.SlotType = "One Hand" || This.Prop.SlotType = "Two Hand" || This.Prop.SlotType = "Shield")
            sendstash := ChaosRecipeStashTabWeapon
          Else If This.Prop.SlotType
          {
            w := This.Prop.SlotType
            sendstash := ChaosRecipeStashTab%w%
          }
        }
      }
      Else If (((StashDumpInTrial || StashTabYesDump) && CurrentLocation ~= "Aspirant's Trial") 
        || (StashTabYesDump && (!StashDumpSkipJC || (StashDumpSkipJC && !(This.Prop.Jeweler || This.Prop.Chromatic)))))
        sendstash := StashTabDump, This.Prop.DumpTabItem := True
      Else If (This.Prop.SpecialType && This.Prop.SpecialType != "Heist Goods")
        Return -1
      Else
        Return False
      Return sendstash
    }
    MatchLootFilter(GroupOut:=0){
      For GKey, Groups in LootFilter
      {
        If (Groups.GroupType) {
          If (val := This.MatchGroup(Groups)){
            this.Prop.CLF_Tab := Groups["StashTab"]
            this.Prop.CLF_Group := GKey
            This.MatchedCLF := val
            Return this.Prop.CLF_Tab
          }
        } Else {
          this.MatchedCLF := []
          matched := False
          nomatched := False
          ormatched := 0
          ormismatch := False
          orcount := Groups["Data"]["OrCount"]
          For SKey, Selected in Groups
          {
            If ( SKey = "Data" )
              Continue
            For AKey, AVal in Selected {
              orflag := AVal["OrFlag"]
              If (AVal.GroupType){
                If keylist := This.MatchGroup(AVal) {
                  matched := True
                  If orflag
                    ormatched++
                  For _, __ in keylist
                    this.MatchedCLF.Push(__)
                } Else {
                  if !orflag
                    nomatched := True
                  ormismatch := True
                }
              } Else {
                arrval := Item[SKey][AVal["#Key"]]
                eval := AVal["Eval"]
                min := AVal["Min"]
                orflag := AVal["OrFlag"]

                If This.Evaluate(eval,arrval,min){
                  matched := True
                  If orflag
                    ormatched++
                  This.MatchedCLF.Push(AVal["#Key"])
                } Else {
                  if !orflag
                    nomatched := True
                  ormismatch := True
                }
              }
            }
          }
          If (ormismatch && ormatched < orcount)
            nomatched := True
          If (matched && !nomatched)
          {
            this.Prop.CLF_Tab := Groups["Data"]["StashTab"]
            this.Prop.CLF_Group := GKey
            Return this.Prop.CLF_Tab
          }
        }
      }
      This.MatchedCLF := False
      Return False
    }
    MatchGroup(grp){
      local
      CountSum := 0
      PotentialMatches := []
      For k, elem in grp["~ElementList"] {
        If elem.GroupType {
          matched := This.MatchGroup(elem)
        } Else {
          arrval := This[elem["Type"]][elem["#Key"]]
          matched := This.Evaluate(elem["Eval"],arrval,elem["Min"])
        }
        If matched {
          If (grp.GroupType ~= "[nN][oO][tT]")
            Return False
          If elem["#Key"]
            PotentialMatches.Push(elem["#Key"])
          Else If IsObject(matched) {
            for kk, vv in matched {
              PotentialMatches.Push(vv)
            }
          }
          If (grp.GroupType ~= "[cC]ount"){
            CountSum += (elem["Weight"] != "" ? elem["Weight"] : 1)
          } Else If (grp.GroupType ~= "[wW]eight"){
            CountSum += (elem["Weight"] != "" ? elem["Weight"] : 1) * (arrval != "" ? arrval : 1)
          }
        } Else {
          If (grp.GroupType ~= "[aA][nN][dD]")
            Return False
        }
      }
      If (grp.GroupType ~= "[aA][nN][dD]" || grp.GroupType ~= "[nN][oO][tT]"){
        Return PotentialMatches
      }
      Else If (grp.GroupType ~= "[cC]ount" || grp.GroupType ~= "[wW]eight") {
        If (CountSum >= grp.TypeValue) {
          Return PotentialMatches
        } Else {
          Return False
        }
      }
    }
    Evaluate(eval,val,min){
      local
      if (eval = ">") {
        Return (val > min)
      } Else if (eval = ">=") {
        Return (val >= min)
      } Else if (eval = "=") {
        Return (val = min)
      } Else if (eval = "<") {
        Return (val < min)
      } else if (eval = "<=") {
        Return (val <= min)
      } else if (eval = "!=") {
        Return (val != min)
      } else if (eval = "~=") {
        Return (val ~= min)
      } else if (eval = "~") {
        matchedOR := False
        for k, v in StrSplit(min, "|"," ") { ; Split OR first
          if InStr(v, "&") { 					       ; Check for any & sections
            mismatched := false
            for kk, vv in StrSplit(v, "&"," ") { ; Split the array again
              If !InStr(val, vv)              ; Check AND sections for mismatch
                mismatched := true
            }
            if !mismatched {    ; no mismatch means all sections found in the string
              matchedOR := true 
              Break
            }
          }	Else if InStr(val, v)	{          ; If there was no & symbol this is an OR section
            matchedOR := True
            break
          }
        }
        Return matchedOR ; If any of the sections produced a match it will flag true
      }
    }

    inRange(key,obj,base){
      If (obj.ranges.Count() = 1) {
        If !((base[key] >= obj.ranges.1.1 && base[key] <= obj.ranges.1.2)
        || (base[key] <= obj.ranges.1.1 && base[key] >= obj.ranges.1.2))
          Return False
      } Else If (obj.ranges.Count() >= 2) {
        for k, v in obj.ranges
        {
          If !((base[key "_Value" k] >= v.1 && base[key "_Value" k] <= v.2)
          || (base[key "_Value" k] <= v.1 && base[key "_Value" k] >= v.2))
            Return False
        }
      } Else If (obj.values.Count() = 1) {
        If !(base[key] == obj.values.1 )
          Return False
      } Else If (obj.values.Count() >= 2) {
        for k, v in obj.values
          If !(base[key "_Value" k] == v )
            Return False
      }
      Return True
    }
    MatchCraftingBases(){
      If (This.Prop.Rarity_Digit == 4)
        Return False
      If(HasVal(craftingBasesT1,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "Atlas Base"
      }
      Else If(HasVal(craftingBasesT2,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "STR Base"
      }
      Else If(HasVal(craftingBasesT3,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "DEX Base"
      }
      Else If(HasVal(craftingBasesT4,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "INT Base"
      }
      Else If(HasVal(craftingBasesT5,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "Hybrid Base"
      }
      Else If(HasVal(craftingBasesT6,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "Jewel Base"
      }
      Else If(HasVal(craftingBasesT7,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "Abyss Jewel Base"
      }
      Else If(HasVal(craftingBasesT8,This.Prop.ItemBase))
      {
        This.Prop.CraftingBase := "Jewellery Base"
      }
    }
    ApproximatePerfection(){
      For ku, unique in WR.data.Perfect
      {
        If (match := This.ValidateUniqueModKeys(unique,ku))
        {
          tally := 0
          For k, value in This.Data.Percentage
          {
            tally += value
          }
          This.Prop.UniquePercentage := This.Data.Percentage.Count()?(Round((tally / This.Data.Percentage.Count()),2)) : 100
          If (match = "mismatch") ; Item is a mismatch
            This.Prop.UniquePercentageError := "Stat/Range mismatch"
          else If (match = "nodata") ; Item has no explicit data
            This.Prop.UniquePercentageError := "Item DB has no explicits"
          If unique.pricePerfect
          {
            perccalc := This.percval(This.Prop.UniquePercentage,[unique.mean,unique.pricePerfect]) * (This.Prop.UniquePercentage/100) * (This.Prop.UniquePercentage/100) * (This.Prop.UniquePercentage/100)
            This.Prop.UniquePerfectValue := perccalc >= unique.mean ? perccalc : unique.mean
            This.Prop.UniqueNormalMean := unique.mean?unique.mean:0
            This.Prop.UniquePerfectMaxVal := unique.pricePerfect
          } Else {
            This.Prop.UniquePerfectValue := 0
            This.Prop.UniqueNormalMean := unique.mean?unique.mean:0
            This.Prop.UniquePerfectMaxVal := 0
          }
          Return
        }
      }
      If !match
      Log("Unique Mod Database Missing","`t"This.Prop.ItemName,"`t"This.Prop.ItemBase,"`nItem.Affix : "JSON_Beautify(This.Affix,,1))
      , This.Prop.UniquePercentageError := "Item not in DB"

    }
    ValidateUniqueModKeys(unique,key){
      If (This.Prop.ItemName = unique.name)
      {
        UniqueMatchingKey := True
        UniqueMisMatchMods := ""
        This.Data.Percentage := {}
        If IsObject(unique.explicits) 
        {
          for k, mod in unique.explicits
          {
            If !This.Affix[mod.key]
              UniqueMisMatchMods .= "`n  [ " mod.key " ]"
            Else If !mod.isvar
              continue
              ; This.Data.Percentage[mod.key] := ""
            Else If (mod.ranges.Count() == 1 && mod.text ~= "\d[ a-zA-Z%]*\(\d+-\d+\)")
            {
              If (This.Affix[mod.key "_Value2"] >= mod.ranges.1.1 && This.Affix[mod.key "_Value2"] <= mod.ranges.1.2)
              || (This.Affix[mod.key "_Value2"] <= mod.ranges.1.1 && This.Affix[mod.key "_Value2"] >= mod.ranges.1.2)
              {
                This.Data.Percentage[mod.key] := This.perc(This.Affix[mod.key "_Value2"],mod.ranges.1)
              }
              Else
                UniqueMisMatchMods .= "`n  [ " mod.key " ] Item is not within DB Mod Range1"
            }
            Else If (mod.ranges.Count() == 1)
            {
              If (This.Affix[mod.key] >= mod.ranges.1.1 && This.Affix[mod.key] <= mod.ranges.1.2)
              || (This.Affix[mod.key] <= mod.ranges.1.1 && This.Affix[mod.key] >= mod.ranges.1.2)
              {
                This.Data.Percentage[mod.key] := This.perc(This.Affix[mod.key], mod.ranges.1)
              }
              Else
                UniqueMisMatchMods .= "`n  [ " mod.key " ] Item is not within DB Mod Range2"
            }
            Else If (mod.ranges.Count() == 2)
            {
              If ((This.Affix[mod.key "_Value1"] >= mod.ranges.1.1 && This.Affix[mod.key "_Value1"] <= mod.ranges.1.2)
                && (This.Affix[mod.key "_Value2"] >= mod.ranges.2.1 && This.Affix[mod.key "_Value2"] <= mod.ranges.2.2))
              || ((This.Affix[mod.key "_Value1"] <= mod.ranges.1.1 && This.Affix[mod.key "_Value1"] >= mod.ranges.1.2)
                && (This.Affix[mod.key "_Value2"] <= mod.ranges.2.1 && This.Affix[mod.key "_Value2"] >= mod.ranges.2.2))
              || ((This.Affix[mod.key "_Value1"] <= mod.ranges.1.1 && This.Affix[mod.key "_Value1"] >= mod.ranges.1.2)
                && (This.Affix[mod.key "_Value2"] >= mod.ranges.2.1 && This.Affix[mod.key "_Value2"] <= mod.ranges.2.2))
              || ((This.Affix[mod.key "_Value1"] >= mod.ranges.1.1 && This.Affix[mod.key "_Value1"] <= mod.ranges.1.2)
                && (This.Affix[mod.key "_Value2"] <= mod.ranges.2.1 && This.Affix[mod.key "_Value2"] >= mod.ranges.2.2))
              {
                This.Data.Percentage[mod.key] := ( This.perc(This.Affix[mod.key "_Value1"], mod.ranges.1) + This.perc(This.Affix[mod.key "_Value2"], mod.ranges.2) ) / 2
              }
              Else
                UniqueMisMatchMods .= "`n  [ " mod.key " ] Item is not within DB Mod Range3"
            }
          }
        } Else
          Return "nodata"
        If !UniqueMisMatchMods
          Return key
        Else
          Log("Unique Mod Database Mismatch","`t"This.Prop.ItemName,"`t"This.Prop.ItemBase,"`nKeys which are mismatched:"UniqueMisMatchMods,"`nItem.Affix : "JSON_Beautify(This.Affix,,1),"`nWR.data.Uniques["key "] : "JSON_Beautify(unique,,2))
        Return "mismatch"
      } Else 
        Return False
    }
    perc(value,range){
      Return abs(((value - range.1) * 100) / (range.2 - range.1))
    }
    percval(perc,range){
      Return ((perc * (range.2 - range.1) / 100) + range.1)
    }
  }
; ItemBuild - Create Prop and Affix Values in WR format from GGG Stash API
  class ItemBuild extends ItemScan
  {
    __New(Object,quad){
      This.Data := {"Blocks":{"Affix":"","FlavorText":""}}
      This.Pseudo := OrderedArray()
      This.Affix := OrderedArray()
      This.Prop := OrderedArray()
      This.Prop.Rarity := (Object.frameType=0?"Normal"
        :(Object.frameType=1?"Magic"
        :(Object.frameType=2?"Rare"
        :(Object.frameType=3?"Unique"
        :(Object.frameType=4?"Gem"
        :(Object.frameType=5?"Currency"
        :(Object.frameType=6?"Divination Card"
        :(Object.frameType>=7?"Unknown":"ERROR"))))))))
      If (Object.frameType >= 0 && Object.frameType <= 3)
        This.Prop.Rarity_Digit := Object.frameType + 1

      For k, v in Object.explicitMods
      {
        If (v != "")
          This.Data.Blocks.Affix .= v . "`r`n"
      }
      For k, v in Object.enchantMods
      {
        If (v != "")
          This.Data.Blocks.Affix .= v . " (enchant)`r`n"
      }
      For k, v in Object.implicitMods
      {
        If (v != "")
          This.Data.Blocks.Affix .= v . " (implicit)`r`n"
      }
      If Object.descrText
        This.Data.Blocks.FlavorText := Object.descrText
      Else If Object.FlavorText
      {
        For k, v in Object.FlavorText
          This.Data.Blocks.FlavorText .= RegExReplace(RegExReplace(RegExReplace(v, "`n", ""), "[{}]", ""), "\<.+\>", "") . "`n"
      }

      This.Prop.ItemName := (Object.name!=""?Object.name:Object.typeLine)
      This.Prop.ItemBase := Object.baseType
      This.MatchBaseType()
      This.Prop.ItemLevel := Object.ilvl
      This.Prop.Item_Width := Object.w
      This.Prop.Item_Height := Object.h
      If !Object.identified
        This.Affix.Unidentified := 1
      This.Prop.StashX := Object.x +1
      This.Prop.StashY := Object.y +1
      This.Prop.StashTab := (RegExMatch(Object.inventoryId, "Stash(\d{1,3})",RxMatch)?RxMatch1:False)
      If quad
        This.Prop.StashQuad := True
      Else
        This.Prop.StashQuad := False
      If (Object.stackSize != "")
      This.Prop.Stack_Size := Object.stackSize
      If (Object.maxStackSize != "")
      This.Prop.Stack_Max := Object.maxStackSize

      This.MatchAffixes(This.Data.Blocks.Affix)
      This.MatchBase2Slot()
      This.MatchChaosRegal()
    }
    MatchBaseType(){
      For k, v in Bases
      {
        If (v["name"] = This.Prop.ItemBase)
        {
          This.Prop.DropLevel := v["drop_level"]
          This.Prop.ItemClass := v["item_class"]

          If InStr(This.Prop.ItemClass, "Ring")
            This.Prop.Ring := True
          If InStr(This.Prop.ItemClass, "Amulet")
            This.Prop.Amulet := True
          If InStr(This.Prop.ItemClass, "Belt")
            This.Prop.Belt := True
          If (This.Prop.ItemClass = "Support Skill Gem")
            This.Prop.Support := True
          Break
        }
      }
    }
  }
; ClipItem - Capture Clip at Coord
ClipItem(x, y){
  Global RunningToggle
    BlockInput, MouseMove
    Backup := Clipboard
    Clipboard := ""
    Item := ""
    Sleep, 45+(ClipLatency*15)
    MouseMove %x%, %y%
    Sleep, 45+(ClipLatency>0?ClipLatency*15:0)
    Send ^!c
    ClipWait, 0.1
    If ErrorLevel
    {
      Sleep, 15
      Send ^!c
      ClipWait, 0.1
      If ErrorLevel && !RunningToggle
        Clipboard := Backup
    }
    Clip_Contents := Clipboard
    Item := new ItemScan
    BlockInput, MouseMoveOff
  Return
  }
addToBlacklist(C, R){
  Loop % Item.Prop.Item_Height
  {
    addNum := A_Index - 1
    addR := R + addNum
    addC := C + 1
    If !IsObject(BlackList[C])
      BlackList[C] := []
    BlackList[C][addR] := True
    If Item.Prop.Item_Width = 2
    {
      If !IsObject(BlackList[addC])
        BlackList[addC] := []
      BlackList[addC][addR] := True
    }
  }
}
; WR_Menu - New menu handling method
WR_Menu(Function:="",Var*)
{
  Global
  Static Built_Inventory, Built_Crafting, Built_Strings, Built_Chat, Built_Controller, Built_Hotkeys, Built_Globe, LeagueIndex, UpdateLeaguesBtn, OHB_EditorBtn, WR_Reset_Globe, DefaultWhisper, DefaultCommands, DefaultButtons, LocateType, oldx, oldy, TempC ,WR_Btn_Locate_PortalScroll, WR_Btn_Locate_WisdomScroll, WR_Btn_Locate_CurrentGem, WR_Btn_Locate_AlternateGem, WR_Btn_Locate_CurrentGem2, WR_Btn_Locate_AlternateGem2, WR_Btn_Locate_GrabCurrency, WR_Btn_FillMetamorph_Select, WR_Btn_FillMetamorph_Show, WR_Btn_FillMetamorph_Menu, WR_Btn_IgnoreSlot, WR_UpDown_Color_Life, WR_UpDown_Color_ES, WR_UpDown_Color_Mana, WR_UpDown_Color_EB, WR_Edit_Color_Life, WR_Edit_Color_ES, WR_Edit_Color_Mana, WR_Edit_Color_EB, WR_Save_JSON_Globe, WR_Load_JSON_Globe, Obj, WR_Save_JSON_FillMetamorph
  , ChaosRecipeMaxHoldingUpDown, ChaosRecipeLimitUnIdUpDown, ChaosRecipeStashTabUpDown, ChaosRecipeStashTabWeaponUpDown, ChaosRecipeStashTabHelmetUpDown, ChaosRecipeStashTabArmourUpDown, ChaosRecipeStashTabGlovesUpDown, ChaosRecipeStashTabBootsUpDown, ChaosRecipeStashTabBeltUpDown, ChaosRecipeStashTabAmuletUpDown, ChaosRecipeStashTabRingUpDown

  Log("Load menu: " Function,Var*)

  If (Function = "Inventory")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Inventory
    {
      Built_Inventory := 1
      Gui, Inventory: New
      Gui, Inventory: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      Gui, Inventory: Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
      Gui, Inventory: Add, Button,      gLaunchSite     x+5           h23,   Website

      Gui, Inventory: Add, Tab2, vInventoryGuiTabs x3 y3 w625 h505 -wrap , Options|Stash Tabs|Affinity|Chaos Recipe|Crafting Bases

    Gui, Inventory: Tab, Options
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,       Section    w170 h345    xm   ym+25,         Inventory Sort/CLF Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesIdentify           Checked%YesIdentify%    xs+5   ys+18  , Identify Items?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesStash              Checked%YesStash%              y+8    , Deposit at Stash?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesHeistLocker        Checked%YesHeistLocker%        y+8    , Deposit C/B at Heist Locker?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesVendor             Checked%YesVendor%             y+8    , Sell at Vendor?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesDiv                Checked%YesDiv%                y+8    , Trade Divination?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesSortFirst          Checked%YesSortFirst%          y+8    , Group Items before stashing?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesMapUnid            Checked%YesMapUnid%            y+8    , Leave Map Un-ID?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesInfluencedUnid     Checked%YesInfluencedUnid%     y+8    , Leave Influenced Un-ID?
      Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesCLFIgnoreImplicit  Checked%YesCLFIgnoreImplicit%  y+8    , Ignore Implicit in CLF?
      Gui, Inventory: Add, Checkbox, gSaveGeneral   vYesBatchVendorBauble  Checked%YesBatchVendorBauble%  y+8    , Batch Vendor Quality Flasks?
      Gui, Inventory: Add, Checkbox, gSaveGeneral   vYesBatchVendorGCP     Checked%YesBatchVendorGCP%     y+8    , Batch Vendor Quality Gems?
      Gui, Inventory: Add, Checkbox, gSaveGeneral   vYesSpecial5Link       Checked%YesSpecial5Link%       y+8    , Give 5 link Special Type?
      Gui, Inventory: Add, Checkbox, gSaveGeneral   vYesOpenStackedDeck    Checked%YesOpenStackedDeck%    y+8    , Open Stacked Decks?
      Gui, Inventory: Add, Checkbox, gSaveGeneral   vYesVendorDumpItems    Checked%YesVendorDumpItems%    y+8    , Vendor Dump Tab Items?
      
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, Button,   gBuildIgnoreMenu vWR_Btn_IgnoreSlot y+8  w160 center, Ignore Slots

      Gui, Inventory: Add, GroupBox,         Section      w370 h180      xm+180   ym+25,         Scroll, Gem and Currency Locations
      Gui, Inventory: Font

      Gui, Inventory: Add, Text,                     xs+93   ys+15,        X-Pos
      Gui, Inventory: Add, Text,                     x+12,             Y-Pos

      Gui, Inventory: Add, Text,                     xs+21  y+5,         Portal Scroll:
      Gui, Inventory: Add, Edit,       vPortalScrollX         x+8        y+-15   w34  h17,   %PortalScrollX%
      Gui, Inventory: Add, Edit,       vPortalScrollY         x+8                w34  h17,   %PortalScrollY%  
      Gui, Inventory: Add, Text,                     xs+10  y+6,         Wisdom Scroll:
      Gui, Inventory: Add, Edit,       vWisdomScrollX         x+8        y+-15   w34  h17,   %WisdomScrollX%
      Gui, Inventory: Add, Edit,       vWisdomScrollY         x+8                w34  h17,   %WisdomScrollY%  
      Gui, Inventory: Add, Text,                     xs+9  y+6,         Grab Currency:
      Gui, Inventory: Add, Edit,       vGrabCurrencyX        x+8        y+-15   w34  h17,   %GrabCurrencyX%
      Gui, Inventory: Add, Edit,       vGrabCurrencyY        x+8                w34  h17,   %GrabCurrencyY%
      Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_PortalScroll                     xs+173       ys+31  h17            , Locate
      Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_WisdomScroll                                  y+4    h17            , Locate
      Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_GrabCurrency                                  y+4    h17            , Locate
      Gui, Inventory: Add, Checkbox,    vStockPortal                    Checked%StockPortal%                    x+13   ys+33          , Stock Portal?
      Gui, Inventory: Add, Checkbox,    vStockWisdom                    Checked%StockWisdom%                    y+8                   , Stock Wisdom?
      Gui, Inventory: Add, Text,                   xs+84   ys+25    h152 0x11
      Gui, Inventory: Add, Text,                   x+33             h152 0x11
      Gui, Inventory: Add, Text,                   x+33             h152 0x11


      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,       Section    w180 h160        xs   y+5,         Item Parse Settings
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, vYesNinjaDatabase xs+5 ys+20 Checked%YesNinjaDatabase%, Update PoE.Ninja DB?
      Gui, Inventory: Add, DropDownList, vUpdateDatabaseInterval x+1 yp-4 w30 Choose%UpdateDatabaseInterval%, 1|2|3|4|5|6|7
      Gui, Inventory: Add, Checkbox, vForceMatch6Link xs+5 y+8 Checked%ForceMatch6Link%, Match with the 6 Link price
      Gui, Inventory: Add, Checkbox, vForceMatchGem20 xs+5 y+8 Checked%ForceMatchGem20%, Match with gems below 20
      Gui, Inventory: Add, Text, xs+5 y+11 hwndPredictivePriceHWND, Price Rares?
      Gui, Inventory: Add, DropDownList, gUpdateExtra vYesPredictivePrice x+2 yp-3 w45 h13 r5, Off|Low|Avg|High
      GuiControl,Inventory: ChooseString, YesPredictivePrice, %YesPredictivePrice%
      
      Gui, Inventory: Font, s18
      Gui, Inventory: Add, Text, x+1 yp-3 cC39F22, `%
      Gui, Inventory: Add, Text, vYesPredictivePrice_Percent_Val x+0 yp w40 cC39F22 center, %YesPredictivePrice_Percent_Val%
      Gui, Inventory: Font,
      ControlGetPos, PPx, PPy, , , , ahk_id %PredictivePriceHWND%
      PPx:=Scale_PositionFromDPI(PPx), PPy:=Scale_PositionFromDPI(PPy)
      Slider_PredictivePrice := new Progress_Slider("Inventory", "YesPredictivePrice_Percent" , (PPx-6) , (PPy-3) , 175 , 15 , 50 , 200 , YesPredictivePrice_Percent_Val , "Black" , "F1C15D" , 1 , "YesPredictivePrice_Percent_Val" , 0 , 0 , 1, "General")

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h165    section    xm+370   ys,         Automation
      AutomationList := "Search Stash|Search Vendor"
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesEnableAutomation Checked%YesEnableAutomation%       xs+5 ys+18  , Enable Automation ?
      Gui, Inventory: Add, Text, y+8, First Automation Action
      Gui, Inventory: Add, DropDownList, gUpdateExtra vFirstAutomationSetting y+3 w100 ,%AutomationList%
      GuiControl,Inventory: ChooseString, FirstAutomationSetting, %FirstAutomationSetting%
      Gui, Inventory: Add, Button, ghelpAutomation   x+10    w20 h20,   ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesEnableNextAutomation Checked%YesEnableNextAutomation%   xs+5    y+8  , Enable Second Automation ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesEnableLockerAutomation Checked%YesEnableLockerAutomation%   xs+5    y+8  , Enable Heist Automation ?
      Gui, Inventory: Add, Checkbox, gWarningAutomation vYesEnableAutoSellConfirmation Checked%YesEnableAutoSellConfirmation%       y+8  , Enable Auto Confirm Vendor ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesEnableAutoSellConfirmationSafe Checked%YesEnableAutoSellConfirmationSafe%       y+8  , Enable Safe Auto Confirm?
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h70    section   xm+370   y+15,         Metamorph Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesFillMetamorph Checked%YesFillMetamorph%       xs+5 ys+18      , Auto fill metamorph?
      Gui, Inventory: Add, Button, gWR_Update  vWR_Btn_FillMetamorph_Menu y+8  w170 center    , Adjust Metamorph Panel

    Gui, Inventory: Tab, Stash Tabs
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      ;You can test with Stash Tab management as a groupbox, but i dont like it
      ;Gui, Inventory: Add, GroupBox,       Section    w352 h437    xm   ym+25,Stash Tab Management
      Gui, Inventory: Add, Text,       Section    xm+5   ym+25,Stash Tab Management
      Gui, Inventory: Font,

      ; Prophecy

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Prophecy
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabProphecy x+0 yp hp ,  %StashTabProphecy%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesProphecy Checked%StashTabYesProphecy% x+5 yp+4, Enable

      ; Veiled

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Veiled
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabVeiled x+0 yp hp ,  %StashTabVeiled%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesVeiled Checked%StashTabYesVeiled% x+5 yp+4, Enable

      ; Cluster

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Cluster Jewel
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabClusterJewel x+0 yp hp ,  %StashTabClusterJewel%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesClusterJewel Checked%StashTabYesClusterJewel% x+5 yp+4, Enable

      ; Heist Gear

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Heist Gear
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabHeistGear x+0 yp hp ,  %StashTabHeistGear%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesHeistGear  Checked%StashTabYesHeistGear% x+5 yp+4, Enable

      ; Misc Map Items

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Misc Map Items
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabMiscMapItems x+0 yp hp ,  %StashTabMiscMapItems%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesMiscMapItems  Checked%StashTabYesMiscMapItems% x+5 yp+4, Enable
      
      ; Second column Gui - GEMS

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys+18 , Quality Gem
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99  x+0 yp hp gSaveStashTabs vStashTabGemQuality , %StashTabGemQuality%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesGemQuality Checked%StashTabYesGemQuality% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Vaal Gem
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabGemVaal , %StashTabGemVaal%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesGemVaal Checked%StashTabYesGemVaal% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Support Gem
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabGemSupport , %StashTabGemSupport%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesGemSupport Checked%StashTabYesGemSupport% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Gem
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabGem , %StashTabGem%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesGem Checked%StashTabYesGem% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , 5/6 linked
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabLinked , %StashTabLinked%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesLinked Checked%StashTabYesLinked% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , 'Bricked' Maps
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabBrickedMaps , %StashTabBrickedMaps%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesBrickedMaps Checked%StashTabYesBrickedMaps% x+5 yp+4, Enable

      ; Third column Gui - Rare itens

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys , Crafting
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99  x+0 yp hp gSaveStashTabs vStashTabCrafting , %StashTabCrafting%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesCrafting Checked%StashTabYesCrafting% x+5 yp+4, Enable
      
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Dump
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabDump x+0 yp hp ,  %StashTabDump%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesDump Checked%StashTabYesDump% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Priced Rares
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabPredictive , %StashTabPredictive%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesPredictive Checked%StashTabYesPredictive% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Ninja Priced
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabNinjaPrice , %StashTabNinjaPrice%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesNinjaPrice Checked%StashTabYesNinjaPrice% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Influenced Item
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabInfluencedItem , %StashTabInfluencedItem%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesInfluencedItem Checked%StashTabYesInfluencedItem% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Quality Flask
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabFlaskQuality , %StashTabFlaskQuality%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesFlaskQuality Checked%StashTabYesFlaskQuality% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h60    section    x+15 ys,         Dump Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashDumpInTrial Checked%StashDumpInTrial% xs+5 ys+18, Enable Dump in Trial
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashDumpSkipJC Checked%StashDumpSkipJC% xs+5 y+5, Skip Jeweler/Chroma Items

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h40    section    xs   y+10,         Priced Rares Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
      Gui, Inventory: Add, Edit, x+5 yp-3 w40
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabYesPredictive_Price , %StashTabYesPredictive_Price%

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h40    section    xs   y+10,         Ninja Priced Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
      Gui, Inventory: Add, Edit, x+5 yp-3 w40
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabYesNinjaPrice_Price , %StashTabYesNinjaPrice_Price%

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w180 h140    section    xs   y+10,         Map/Contract Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, DropDownList, w40 gUpdateExtra  vYesSkipMaps_eval xs+5 yp+18 , % ">=|<=" 
      GuiControl,Inventory: ChooseString, YesSkipMaps_eval, %YesSkipMaps_eval%
      Gui, Inventory: Add, DropDownList, w40 gUpdateExtra  vYesSkipMaps x+3 yp , 0|1|2|3|4|5|6|7|8|9|10|11|12
      GuiControl,Inventory: ChooseString, YesSkipMaps, %YesSkipMaps%
      Gui, Inventory: Add, Text, yp+3 x+5 , Column to Skip
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesSkipMaps_normal Checked%YesSkipMaps_normal%     xs+5  y+8    , Skip Normal?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesSkipMaps_magic Checked%YesSkipMaps_magic%     x+0 yp   , Skip Magic?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesSkipMaps_rare Checked%YesSkipMaps_rare%   xs+5 y+8        , Skip Rare?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesSkipMaps_unique Checked%YesSkipMaps_unique%   x+0 yp       , Skip Unique?
      Gui, Inventory: Add, Text, xs+5 y+8 , Skip Maps => Tier
      Gui, Inventory: Add, Edit, Number w40 x+5 yp-3 
      Gui, Inventory: Add, UpDown, center hp w40 range1-16 gUpdateExtra vYesSkipMaps_tier , %YesSkipMaps_tier%

      Gui, Inventory: Add, Checkbox, gUpdateExtra  vBrickedWhenCorrupted Checked%BrickedWhenCorrupted% xs+5 y+8, Only consider a map to be`rbricked if it's corrupted


      ; Affinity
    Gui, Inventory: Tab, Affinity
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, Text,       Section    xm+5   ym+25, Affinities Management
      Gui, Inventory: Font,

      ; Blight
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs ys+18 , Blight
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vBlightEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs  vStashTabBlight, %StashTabBlight%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesBlight x+5 yp-5 w90 h20, %StashTabYesBlight%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vBlightEditText, Disable Type

      ; Delirium
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Delirium
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDeliriumEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs  vStashTabDelirium, %StashTabDelirium%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDelirium x+5 yp-5 w90 h20, %StashTabYesDelirium%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vDeliriumEditText, Disable Type

      ; Divination Card
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Divination Card
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDivinationEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabDivination x+0 yp hp ,  %StashTabDivination%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDivination x+5 yp-5 w90 h20, %StashTabYesDivination%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vDivinationEditText, Disable Type

      ; Fragments
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Fragment
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vFragmentEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabFragment x+0 yp hp ,  %StashTabFragment%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesFragment x+5 yp-5 w90 h20, %StashTabYesFragment%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vFragmentEditText, Disable Type

      ; Metamorph
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Metamorph
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vMetamorphEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabMetamorph x+0 yp hp , %StashTabMetamorph%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesMetamorph x+5 yp-5 w90 h20, %StashTabYesMetamorph%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vMetamorphEditText, Disable Type

      ; Currency
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w145 h50 x+15 ys+18 , Currency
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 vCurrencyEdit  xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabCurrency yp hp , %StashTabCurrency%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesCurrency x+5 yp-5 w90 h20, %StashTabYesCurrency%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vCurrencyEditText, Disable Type

      ; Delve
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Delve
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDelveEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs  vStashTabDelve , %StashTabDelve%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDelve x+5 yp-5 w90 h20, %StashTabYesDelve%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vDelveEditText, Disable Type

      ; Essence
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Essence
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vEssenceEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabEssence x+0 yp hp ,  %StashTabEssence%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesEssence x+5 yp-5 w90 h20, %StashTabYesEssence%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vEssenceEditText, Disable Type

      ; Map
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Map
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vMapEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabMap x+0 yp hp ,  %StashTabMap%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesMap x+5 yp-5 w90 h20, %StashTabYesMap%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vMapEditText, Disable Type
      
      ; Unique
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Unique
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vUniqueEdit  w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs  vStashTabUnique x+0 yp hp ,  %StashTabUnique%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesUnique x+5 yp-5 w90 h20, %StashTabYesUnique%
      Gui, Inventory: Add, Text,  xp yp+22 w90 center vUniqueEditText, Disable Type

      ;Run GreyOut
      GreyOutAffinity()

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w200 h100 x+50 ys , Intructions:
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - You can enable Currency Affinity 
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, and set the stash for other functions
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - CLF will take priority over Affinity 
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - Use slider to choose logic type
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - Enable overflow Unique tabs

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w200 h210 xs yp+30 , Unique Affinity Logic
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesUniquePercentage Checked%StashTabYesUniquePercentage% xs+15 yp+25, Only stash above `% Affixes
      Gui, Inventory: Add, Edit, Number w40 xp yp+17
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabUniquePercentage , %StashTabUniquePercentage%
      Gui, Inventory: Add, Text, x+3 yp+3 , Minimum Affix Percentage
      ; Unique Ring
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h65 xs+10 yp+25 , Unique Ring
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+25
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabUniqueRing , %StashTabUniqueRing%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% x+5 yp-2, Stash Overflow
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesUniqueRingAll Checked%StashTabYesUniqueRingAll% xp y+4, Including Junk

      ; Unique Dump
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h65 xs+10 yp+25 , Unique Dump
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+25
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabUniqueDump , %StashTabUniqueDump%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% x+5 yp-2, Stash Overflow
      Gui, Inventory: Add, Checkbox, gSaveStashTabs  vStashTabYesUniqueDumpAll Checked%StashTabYesUniqueDumpAll% xp y+4, Including Junk


    Gui, Inventory: Tab, Chaos Recipe
    Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w170 h255 xm+5 ym+25, Chaos Recipe Options
      Gui, Inventory: Font,
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeEnableFunction Checked%ChaosRecipeEnableFunction% xs+10 yp+20 Section, Enable Chaos Recipe Logic
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeUnloadAll Checked%ChaosRecipeUnloadAll% xs yp+20, Sell all sets back to back
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeSkipJC Checked%ChaosRecipeSkipJC% xs yp+20, Skip Jeweler/Chroma Items
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeAllowDoubleJewellery Checked%ChaosRecipeAllowDoubleJewellery% xs yp+20, Allow 2x Jewellery limit
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeAllowDoubleBelt Checked%ChaosRecipeAllowDoubleBelt% xs yp+20, Allow 2x Belt limit
        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeMaxHoldingUpDown xs yp+20 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-36 vChaosRecipeMaxHolding , %ChaosRecipeMaxHolding%
        Gui, Inventory: Add, Text, x+5 yp+3, Max # of each part
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeSmallWeapons Checked%ChaosRecipeSmallWeapons% xs yp+22, Only stash Small Weap/Shield
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeEnableUnId Checked%ChaosRecipeEnableUnId% xs yp+22, Leave Recipe Rare Un-Id
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeSeperateCount Checked%ChaosRecipeSeperateCount% xs yp+22, Seperate count for Un-Id
        Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeOnlyUnId Checked%ChaosRecipeOnlyUnId% xs yp+22, Only Stash UnId in Range
        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeLimitUnIdUpDown xs yp+20 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range70-100 vChaosRecipeLimitUnId , %ChaosRecipeLimitUnId%
        Gui, Inventory: Add, Text, x+5 yp+3, Item lvl Resume Id
        Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w170 h80 xs-5 y+25, Chaos Recipe Type
      Gui, Inventory: Font,
        Gui, Inventory: Add, Radio,gSaveChaosRadio xp+15 yp+20 vChaosRecipeTypePure Checked%ChaosRecipeTypePure% , Pure Chaos 60-74 ilvl
        Gui, Inventory: Add, Radio,gSaveChaosRadio xp yp+20 vChaosRecipeTypeHybrid Checked%ChaosRecipeTypeHybrid%  , Hybrid Chaos 60-100 ilvl
        Gui, Inventory: Add, Radio,gSaveChaosRadio xp yp+20 vChaosRecipeTypeRegal Checked%ChaosRecipeTypeRegal%  , Pure Regal 75+ ilvl
        Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h90 xs+190 ym+25, Chaos Recipe Stashing
      Gui, Inventory: Font,
        Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodDump Checked%ChaosRecipeStashMethodDump%, Use Dump Tab
        Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodTab Checked%ChaosRecipeStashMethodTab%, Use Chaos Recipe Tab
        Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodSort Checked%ChaosRecipeStashMethodSort%, Use Seperate Tab for Each Part
        Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h50 xs y+25, Chaos Recipe Tab
        Gui, Inventory: Font,
        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabUpDown xs+15 yp+20 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTab , %ChaosRecipeStashTab%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for ALL PARTS
        Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h225 xs y+25, Chaos Recipe Part Tabs
      Gui, Inventory: Font,
        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabWeaponUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabWeapon , %ChaosRecipeStashTabWeapon%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Weapons

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabArmourUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabArmour , %ChaosRecipeStashTabArmour%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Armours

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabHelmetUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabHelmet , %ChaosRecipeStashTabHelmet%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Helmets

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabGlovesUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabGloves , %ChaosRecipeStashTabGloves%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Gloves

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabBootsUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabBoots , %ChaosRecipeStashTabBoots%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Boots

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabBeltUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabBelt , %ChaosRecipeStashTabBelt%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Belts

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabAmuletUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabAmulet , %ChaosRecipeStashTabAmulet%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Amulets

        Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabRingUpDown xs+15 yp+22 w50 center
        Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabRing , %ChaosRecipeStashTabRing%
        Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Rings

    ; Crafting Bases
    Gui, Inventory: Tab, Crafting Bases
    Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xm+5 ym+25,  Atlas Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashATLAS Checked%YesStashATLAS%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashATLASCraftingIlvl Checked%YesStashATLASCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashATLASCraftingIlvlMin , %YesStashATLASCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         STR Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashSTR Checked%YesStashSTR%   xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashSTRCraftingIlvl Checked%YesStashSTRCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashSTRCraftingIlvlMin , %YesStashSTRCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         DEX Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashDEX Checked%YesStashDEX%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashDEXCraftingIlvl Checked%YesStashDEXCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashDEXCraftingIlvlMin , %YesStashDEXCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         INT Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashINT Checked%YesStashINT%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashINTCraftingIlvl Checked%YesStashINTCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashINTCraftingIlvlMin , %YesStashINTCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs+160 ym+25,         Hybrid Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashHYBRID Checked%YesStashHYBRID%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashHYBRIDCraftingIlvl Checked%YesStashHYBRIDCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashHYBRIDCraftingIlvlMin , %YesStashHYBRIDCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         Jewels Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashJ Checked%YesStashJ%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashJCraftingIlvl Checked%YesStashJCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashJCraftingIlvlMin , %YesStashJCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         Abyss Jewels Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashAJ Checked%YesStashAJ%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashAJCraftingIlvl Checked%YesStashAJCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashAJCraftingIlvlMin , %YesStashAJCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,             w150 h90    section    xs y+25,         Jewellery
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashJewellery Checked%YesStashJewellery%    xs+5  ys+18 , Enable ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashJewelleryCraftingIlvl Checked%YesStashJewelleryCraftingIlvl%     xs+5  y+8    , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
      Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashJewelleryCraftingIlvlMin , %YesStashJewelleryCraftingIlvlMin%
      Gui, Inventory: Add, Button, gCustomCrafting xs+10 y+5  w120,   Edit Crafting Bases

    }
    Gui, Inventory: show , w600 h500, Inventory Settings
  }
  Else If (Function = "Crafting")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Crafting
    {
      Built_Crafting := 1
      Gui, Crafting: New
      Gui, Crafting: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      Gui, Crafting: Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
      Gui, Crafting: Add, Button,      gLaunchSite     x+5           h23,   Website

      Gui, Crafting: Add, Tab2, vCraftingGuiTabs x3 y3 w625 h505 -wrap , Map Crafting|Basic Crafting

      Gui, Crafting: Tab, Map Crafting
        MapMethodList := "Disable|Transmutation+Augmentation|Alchemy|Chisel+Alchemy|Chisel+Alchemy+Vaal"
        MapTierList := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16"
        MapSetValue := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100"
        Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add, Text,       Section              x12   ym+25,         Map Crafting
        Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 1:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s7
          Gui, Crafting: Add, Text,         xs+5     ys+20       , Initial
          Gui, Crafting: Add, Text,         xs+55    ys+20       , Ending
          Gui, Crafting: Add, Text,         xs+105   ys+20       , Method
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier1  Choose%StartMapTier1%,  %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier1    Choose%EndMapTier1%,    %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod1    Choose%CraftingMapMethod1%,   %MapMethodList%
          GuiControl,Crafting: ChooseString, CraftingMapMethod1, %CraftingMapMethod1%
          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 2:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s7
          Gui, Crafting: Add, Text,         xs+5     ys+20       , Initial
          Gui, Crafting: Add, Text,         xs+55    ys+20       , Ending
          Gui, Crafting: Add, Text,         xs+105   ys+20       , Method
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier2  Choose%StartMapTier2%,  %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier2    Choose%EndMapTier2%,    %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod2    Choose%CraftingMapMethod2%,    %MapMethodList%
          GuiControl,Crafting: ChooseString, CraftingMapMethod2, %CraftingMapMethod2%
          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 3:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s7
          Gui, Crafting: Add, Text,         xs+5     ys+20       , Initial
          Gui, Crafting: Add, Text,         xs+55    ys+20       , Ending
          Gui, Crafting: Add, Text,         xs+105   ys+20       , Method
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier3  Choose%StartMapTier3%,  %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier3    Choose%EndMapTier3%,    %MapTierList%
          Gui, Crafting: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod3    Choose%CraftingMapMethod3%,    %MapMethodList%
          GuiControl,Crafting: ChooseString, CraftingMapMethod3, %CraftingMapMethod3%
          Gui, Crafting: Font,
          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w580 h200 xs, Undesirable Mods:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, Checkbox, vElementalReflect xs+5 ys+20 Checked%ElementalReflect%, Reflect # of Elemental Damage
          Gui, Crafting: Add, Checkbox, vPhysicalReflect xs+5 ys+40 Checked%PhysicalReflect%, Reflect # of Physical Damage
          Gui, Crafting: Add, Checkbox, vNoLeech xs+5 ys+60 Checked%NoLeech%, Cannot Leech Life/Mana from Monsters
          Gui, Crafting: Add, Checkbox, vNoRegen xs+5 ys+80 Checked%NoRegen%, Cannot Regenerate Life, Mana or Energy Shield
          Gui, Crafting: Add, Checkbox, vAvoidAilments xs+5 ys+100 Checked%AvoidAilments%, Chance to Avoid Elemental Ailments
          Gui, Crafting: Add, Checkbox, vAvoidPBB xs+5 ys+120 Checked%AvoidPBB%, Chance to Avoid Poison, Blind, and Bleeding
          Gui, Crafting: Add, Checkbox, vLRRLES xs+5 ys+140 Checked%LRRLES%, Players Have # Less Recovery Rate of Life and ES
          Gui, Crafting: Add, Checkbox, vPHReducedChanceToBlock xs+5 ys+160 Checked%PHReducedChanceToBlock%, Players Have # Reduced Chance to Block
          Gui, Crafting: Add, Checkbox, vPHLessAreaOfEffect xs+5 ys+180 Checked%PHLessAreaOfEffect%, Players Have # Less Area of Effect
          Gui, Crafting: Add, Checkbox, vMDExtraPhysicalDamage xs+290 ys+20 Checked%MDExtraPhysicalDamage%,  Monsters Deal # Extra Physical Damage as F/C/L
          Gui, Crafting: Add, Checkbox, vMICSC xs+290 ys+40 Checked%MICSC%,  Monsters Have # Increased Critical Strike Chance
          Gui, Crafting: Add, Checkbox, vMSCAT xs+290 ys+60 Checked%MSCAT%, Monsters' Skills Chain # Additional Times
          Gui, Crafting: Add, Checkbox, vMFAProjectiles xs+290 ys+80 Checked%MFAProjectiles%, Monsters Fire # Additional Projectiles
          Gui, Crafting: Add, Checkbox, vMinusMPR xs+290 ys+100 Checked%MinusMPR%, Reduced # Maximum Player Resistances 
          Gui, Crafting: Add, Checkbox, vPCDodgeUnlucky xs+290 ys+120 Checked%PCDodgeUnlucky%, Player Chance to Dodge is Unlucky  
          Gui, Crafting: Add, Checkbox, vMHAccuracyRating xs+290 ys+140 Checked%MHAccuracyRating%, Monsters Have # Increased Accuracy Rating
          Gui, Crafting: Add, Checkbox, vPHLessArmour xs+290 ys+160 Checked%PHLessArmour%, Players Have # Less Armour
          

          Gui, Crafting: Font, Bold
          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w170 h110 x320 y50, Minimum Map Qualities:
          Gui, Crafting: Font, 
          Gui, Crafting: Font,s8

          Gui, Crafting: Add, Edit, number limit2 xs+15 yp+18 w40
          Gui, Crafting: Add, UpDown, Range1-99 x+0 yp hp vMMapItemQuantity , %MMapItemQuantity%
          Gui, Crafting: Add, Text,         x+10 yp+3        , Item Quantity

          Gui, Crafting: Add, Edit, number limit2 xs+15 y+15 w40
          Gui, Crafting: Add, UpDown, Range1-54 x+0 yp hp vMMapItemRarity , %MMapItemRarity%
          Gui, Crafting: Add, Text,         x+10 yp+3        , Item Rarity

          Gui, Crafting: Add, Edit, number limit2 xs+15 y+15 w40
          Gui, Crafting: Add, UpDown, Range1-45 x+0 yp hp vMMapMonsterPackSize , %MMapMonsterPackSize%
          Gui, Crafting: Add, Text,         x+10 yp+3        , Monster Pack Size

          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w170 h40 x320 y170, Minimum Settings Options:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, Checkbox, vEnableMQQForMagicMap xs+10 ys+20 Checked%EnableMQQForMagicMap%, Enable on Magic Maps?
          Gui, Crafting: Font, Bold s9 cBlack, Arial
        Gui, Crafting: Add,GroupBox,Section w170 h40 xs ys+50, Alc'n'go Heist:
          Gui, Crafting: Font,
          Gui, Crafting: Font,s8
          Gui, Crafting: Add, Checkbox, vHeistAlcNGo xs+10 ys+20 Checked%HeistAlcNGo%, Alchemy Contract/Blueprint?
      Gui, Crafting: Tab, Basic Crafting
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, GroupBox,section Center xm+15 ym+25 w275 h100, Chance
        Gui, Crafting: Font
        Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftChanceMethod Checked" (BasicCraftChanceMethod=1?1:0), Cursor
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftChanceMethod=2?1:0), Currency Stash
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftChanceMethod=3?1:0), Bulk Inventory
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, Checkbox, % "gSaveBasicCraft vBasicCraftChanceScour xs+30 y+20 Checked" BasicCraftChanceScour, Scour and retry
        Gui, Crafting: Font
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, GroupBox,section Center xs ys+115 w275 h100, Color
        Gui, Crafting: Font
        Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftColorMethod Checked" (BasicCraftColorMethod=1?1:0), Cursor
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftColorMethod=2?1:0), Currency Stash
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftColorMethod=3?1:0), Bulk Inventory
        Gui, Crafting: Font, Bold s12 cRed, Arial
        Gui, Crafting: Add, Text,% "xs+25 y+20"
        Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftR, % BasicCraftR
        Gui, Crafting: Add, Text, x+5 yp, R 
        Gui, Crafting: Font, Bold s12 cGreen, Arial
        Gui, Crafting: Add, Text,% "x+25 yp"
        Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftG, % BasicCraftG
        Gui, Crafting: Add, Text, x+5 yp, G
        Gui, Crafting: Font, Bold s12 cBlue, Arial
        Gui, Crafting: Add, Text,% "x+25 yp"
        Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftB, % BasicCraftB
        Gui, Crafting: Add, Text, x+5 yp, B
        Gui, Crafting: Font
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, GroupBox,section Center xm+295 ym+25 w275 h100, Link
        Gui, Crafting: Font
        Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftLinkMethod Checked" (BasicCraftLinkMethod=1?1:0), Cursor
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftLinkMethod=2?1:0), Currency Stash
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftLinkMethod=3?1:0), Bulk Inventory
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, Text,% "xs+25 y+20"
        Gui, Crafting: Add, UpDown, Range0-6 vBasicCraftDesiredLinks gSaveBasicCraft, % BasicCraftDesiredLinks
        Gui, Crafting: Add, Text, x+5 yp, Desired Links
        Gui, Crafting: Add, CheckBox, x+10 yp gSaveBasicCraft vBasicCraftLinkAuto Checked%BasicCraftLinkAuto%, Auto
        Gui, Crafting: Font
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, GroupBox,section Center xs ys+115 w275 h100, Socket
        Gui, Crafting: Font
        Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftSocketMethod Checked" (BasicCraftSocketMethod=1?1:0), Cursor
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftSocketMethod=2?1:0), Currency Stash
        Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftSocketMethod=3?1:0), Bulk Inventory
        Gui, Crafting: Font, Bold s12 cBlack, Arial
        Gui, Crafting: Add, Text,% "xs+25 y+20"
        Gui, Crafting: Add, UpDown, Range0-6 vBasicCraftDesiredSockets gSaveBasicCraft, % BasicCraftDesiredSockets
        Gui, Crafting: Add, Text, x+5 yp, Desired Sockets
        Gui, Crafting: Add, CheckBox, x+10 yp gSaveBasicCraft vBasicCraftSocketAuto Checked%BasicCraftSocketAuto%, Auto
        Gui, Crafting: Font
        Gui, Crafting: Show
    }
    Gui, Crafting: show , w600 h500, Crafting Settings
  }
  Else If (Function = "Strings")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Strings
    {
      Built_Strings := 1
      Gui, Strings: New
      Gui, Strings: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      ; Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
      
      Gui, Strings: Add, Button,      gLaunchSite     x295 y470           h23,   Website
      Gui, Strings: Add, Button,      gft_Start     x+5           h23,   FindText Gui (capture)
      Gui, Strings: Font, Bold cBlack
      Gui, Strings: Add, GroupBox,     Section    w625 h10            x3   y3,         String Samples from the FindText library - Match your resolution's height with the number in the string Label
      Gui, Strings: Add, Tab2, Section vStringsGuiTabs x20 y30 w600 h480 -wrap , General|Vendor|Debuff
      Gui, Strings: Font,

    Gui, Strings: Tab, General
      Gui, Strings: Add, Button, xs+1 ys+1 w1 h1, 
      Gui, Strings: +Delimiter?
      Gui, Strings: Add, Text, xs+10 ys+25 section, OHB 1 pixel bar - Only Adjust if not 1080 Height
      Gui, Strings: Add, ComboBox, xp y+8 w220 vHealthBarStr gUpdateStringEdit , %HealthBarStr%??"%1080_HealthBarStr%"?"%1440_HealthBarStr%"?"%1440_HealthBarStr_Alt%"?"%1050_HealthBarStr%"
      Gui, Strings: Add, Button, hp w50 x+10 yp vOHB_EditorBtn gOHBUpdate , Make
      Gui, Strings: Add, Text, x+10 x+10 ys , Capture of the Skill up icon
      Gui, Strings: Add, ComboBox, y+8 w280 vSkillUpStr gUpdateStringEdit , %SkillUpStr%??"%1080_SkillUpStr%"?"%1440_SkillUpStr%"?"%1050_SkillUpStr%"?"%768_SkillUpStr%"
      Gui, Strings: Add, Text, xs y+15 section , Capture of the words Sell Items
      Gui, Strings: Add, ComboBox, y+8 w280 vSellItemsStr gUpdateStringEdit , %SellItemsStr%??"%1080_SellItemsStr%"?"%2160_SellItemsStr%"?"%1440_SellItemsStr%"?"%1050_SellItemsStr%"?"%768_SellItemsStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Stash
      Gui, Strings: Add, ComboBox, y+8 w280 vStashStr gUpdateStringEdit , %StashStr%??"%1080_StashStr%"?"%2160_StashStr%"?"%1440_StashStr%"?"%1050_StashStr%"?"%768_StashStr%"
      Gui, Strings: Add, Text, xs y+15 section , Capture of the X button
      Gui, Strings: Add, ComboBox, y+8 w280 vXButtonStr gUpdateStringEdit , %XButtonStr%??"%1080_XButtonStr%"?"%1440_XButtonStr%"?"%1050_XButtonStr%"?"%768_XButtonStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Heist Locker
      Gui, Strings: Add, ComboBox, y+8 w280 vHeistLockerStr gUpdateStringEdit , %HeistLockerStr%??"%1080_HeistLockerStr%"?"%1440_HeistLockerStr%"
      Gui, Strings: +Delimiter|

    Gui, Strings: Tab, Vendor
      Gui, Strings: Add, Button, Section x20 y30 w1 h1, 
      Gui, Strings: +Delimiter?
      Gui, Strings: Add, Text, xs+10 ys+25 section, Capture of the Hideout vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorStr gUpdateStringEdit , %VendorStr%??"%1080_MasterStr%"?"%1080_NavaliStr%"?"%1080_HelenaStr%"?"%1080_ZanaStr%"?"%2160_NavaliStr%"?"%1440_ZanaStr%"?"%1440_NavaliStr%"?"%1050_MasterStr%"?"%1050_NavaliStr%"?"%1050_HelenaStr%"?"%1050_ZanaStr%"?"%768_NavaliStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Azurite Mines vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorMineStr gUpdateStringEdit , %VendorMineStr%??"%1080_MasterStr%"?"%1050_MasterStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Lioneye vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorLioneyeStr gUpdateStringEdit , %VendorLioneyeStr%??"%1080_BestelStr%"?"%1050_BestelStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Forest vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorForestStr gUpdateStringEdit , %VendorForestStr%??"%1080_GreustStr%"?"%1050_GreustStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Sarn vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorSarnStr gUpdateStringEdit , %VendorSarnStr%??"%1080_ClarissaStr%"?"%1050_ClarissaStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Highgate vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorHighgateStr gUpdateStringEdit , %VendorHighgateStr%??"%1080_PetarusStr%"?"%1050_PetarusStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Overseer vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorOverseerStr gUpdateStringEdit , %VendorOverseerStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Bridge vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorBridgeStr gUpdateStringEdit , %VendorBridgeStr%??"%1080_HelenaStr%"?"%1050_HelenaStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Docks vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorDocksStr gUpdateStringEdit , %VendorDocksStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Oriath vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorOriathStr gUpdateStringEdit , %VendorOriathStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Harbour vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorHarbourStr gUpdateStringEdit , %VendorHarbourStr%??"%1080_FenceStr%"
      Gui, Strings: +Delimiter|
    Gui, Strings: Tab, Debuff
      Gui, Strings: Add, Button, Section x20 y30 w1 h1, 
      Gui, Strings: +Delimiter?

      Gui, Strings: Add, Text, xs+10 ys+25 section, Curse - Elemental Weakness
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseEleWeakStr gUpdateStringEdit , %debuffCurseEleWeakStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Vulnerability
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseVulnStr gUpdateStringEdit , %debuffCurseVulnStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Enfeeble
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseEnfeebleStr gUpdateStringEdit , %debuffCurseEnfeebleStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Temporal Chains
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseTempChainStr gUpdateStringEdit , %debuffCurseTempChainStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Condutivity
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseCondStr gUpdateStringEdit , %debuffCurseCondStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Flammability
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseFlamStr gUpdateStringEdit , %debuffCurseFlamStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Frostbite
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseFrostStr gUpdateStringEdit , %debuffCurseFrostStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Warlord's Mark
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseWarMarkStr gUpdateStringEdit , %debuffCurseWarMarkStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Shock
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffShockStr gUpdateStringEdit , %debuffShockStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Bleed
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffBleedStr gUpdateStringEdit , %debuffBleedStr%??"%1080_CurseStr%"
      Gui, Strings: Add, Text, xs y+15 section, Freeze
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffFreezeStr gUpdateStringEdit , %debuffFreezeStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Ignite
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffIgniteStr gUpdateStringEdit , %debuffIgniteStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Poison
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffPoisonStr gUpdateStringEdit , %debuffPoisonStr%??"%1080_CurseStr%"

      Gui, Strings: +Delimiter|
    }
    Gui, Strings: show , w640 h525, FindText Strings
  }
  Else If (Function = "Chat")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Chat
    {
      Built_Chat := 1
      Gui, Chat: New
      Gui, Chat: +AlwaysOnTop -MinimizeBox

      ;Save Setting
      Gui, Chat: Add, Button, default gupdateEverything    x295 y320  w150 h23,   Save Configuration
      Gui, Chat: Add, Button,      gLaunchSite     x+5           h23,   Website

      Gui, Chat: Add, Tab, w590 h350 xm+5 ym Section , Commands|Reply Whisper
    Gui, Chat: Tab, Commands
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section w60 h85                      ,Modifier
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, xs+4 ys+20 w50 h23 v1Prefix1, %1Prefix1%
      Gui, Chat: Add, Edit, y+8    w50 h23 v1Prefix2, %1Prefix2%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w60 h275                      ,Keys
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, ys+20 xs+4 w50 h23 v1Suffix1, %1Suffix1%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix2, %1Suffix2%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix3, %1Suffix3%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix4, %1Suffix4%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix5, %1Suffix5%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix6, %1Suffix6%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix7, %1Suffix7%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix8, %1Suffix8%
      Gui, Chat: Add, Edit, y+5    w50 h23 v1Suffix9, %1Suffix9%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w300 h275                      ,Commands
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      DefaultCommands := [ "/Hideout","/Menagerie","/Delve","/cls","/ladder","/reset_xp","/invite RecipientName","/kick RecipientName","@RecipientName Thanks for the trade!","@RecipientName Still Interested?","/kick CharacterName"]
      textList=
      For k, v in DefaultCommands
        textList .= (!textList ? "" : "|") v
      Gui, Chat: Add, ComboBox, xs+4 ys+20 w290 v1Suffix1Text, %textList%
      GuiControl,Chat: Text, 1Suffix1Text, %1Suffix1Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix2Text, %textList%
      GuiControl,Chat: Text, 1Suffix2Text, %1Suffix2Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix3Text, %textList%
      GuiControl,Chat: Text, 1Suffix3Text, %1Suffix3Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix4Text, %textList%
      GuiControl,Chat: Text, 1Suffix4Text, %1Suffix4Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix5Text, %textList%
      GuiControl,Chat: Text, 1Suffix5Text, %1Suffix5Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix6Text, %textList%
      GuiControl,Chat: Text, 1Suffix6Text, %1Suffix6Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix7Text, %textList%
      GuiControl,Chat: Text, 1Suffix7Text, %1Suffix7Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix8Text, %textList%
      GuiControl,Chat: Text, 1Suffix8Text, %1Suffix8Text%
      Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix9Text, %textList%
      GuiControl,Chat: Text, 1Suffix9Text, %1Suffix9Text%
    Gui, Chat: Tab, Reply Whisper
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section  w60 h85                      ,Modifier
      Gui, Chat: Font,

      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, xs+4 ys+20 w50 h23 v2Prefix1, %2Prefix1%
      Gui, Chat: Add, Edit, y+8    w50 h23 v2Prefix2, %2Prefix2%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w60 h275                      ,Keys
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, ys+20 xs+4 w50 h23 v2Suffix1, %2Suffix1%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix2, %2Suffix2%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix3, %2Suffix3%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix4, %2Suffix4%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix5, %2Suffix5%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix6, %2Suffix6%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix7, %2Suffix7%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix8, %2Suffix8%
      Gui, Chat: Add, Edit, y+5    w50 h23 v2Suffix9, %2Suffix9%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w300 h275                      ,Whisper Reply
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      DefaultWhisper := [ "/invite RecipientName","Sure, will invite in a sec.","In a map, will get to you in a minute.","Sorry, going to be a while.","No thank you.","Sold","/afk Sold to RecipientName"]
      textList=
      For k, v in DefaultWhisper
        textList .= (!textList ? "" : "|") v
      Gui, Chat: Add, ComboBox,   xs+4 ys+20   w290 v2Suffix1Text, %textList%
      GuiControl,Chat: Text, 2Suffix1Text, %2Suffix1Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix2Text, %textList%
      GuiControl,Chat: Text, 2Suffix2Text, %2Suffix2Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix3Text, %textList%
      GuiControl,Chat: Text, 2Suffix3Text, %2Suffix3Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix4Text, %textList%
      GuiControl,Chat: Text, 2Suffix4Text, %2Suffix4Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix5Text, %textList%
      GuiControl,Chat: Text, 2Suffix5Text, %2Suffix5Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix6Text, %textList%
      GuiControl,Chat: Text, 2Suffix6Text, %2Suffix6Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix7Text, %textList%
      GuiControl,Chat: Text, 2Suffix7Text, %2Suffix7Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix8Text, %textList%
      GuiControl,Chat: Text, 2Suffix8Text, %2Suffix8Text%
      Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix9Text, %textList%
      GuiControl,Chat: Text, 2Suffix9Text, %2Suffix9Text%
    }
    Gui, Chat: show , w620 h370, Chat Hotkeys
  }
  Else If (Function = "Controller")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Controller
    {
      Built_Controller := 1
      Gui, Controller: New
      Gui, Controller: +AlwaysOnTop -MinimizeBox
      DefaultButtons := [ "ItemSort","QuickPortal","PopFlasks","GemSwap","Logout","LButton","RButton","MButton","q","w","e","r","t"]
      textList= 
      For k, v in DefaultButtons
        textList .= (!textList ? "" : "|") v
      
      Gui, Controller: Add, Picture, xm ym+20 w600 h400 +0x4000000, %A_ScriptDir%\data\Controller.png

      Gui, Controller: Add, Checkbox,  section  xp y+-10          vYesMovementKeys Checked%YesMovementKeys%                     , Use Move Keys?
      Gui, Controller: Add, Checkbox,             vYesTriggerUtilityKey Checked%YesTriggerUtilityKey%                     , Use utility on Move?
      Gui, Controller: Add, DropDownList,   x+5 yp-5   w40   vTriggerUtilityKey Choose%TriggerUtilityKey%, 1|2|3|4|5

      Gui, Controller: Add,GroupBox, section xm+80 ym+15 w80 h40                        ,L Bumper
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonLB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonLB, %hotkeyControllerButtonLB%
      Gui, Controller: Add,GroupBox,  xs+360 ys w80 h40                        ,R Bumper
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonRB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonRB, %hotkeyControllerButtonRB%

      Gui, Controller: Add,GroupBox, section  xm+65 ym+100 w90 h80                        ,D-Pad
      Gui, Controller: add,text, xs+15 ys+30, Mouse`nMovement

      Gui, Controller: Add,GroupBox, section xm+165 ym+180 w80 h80                        ,Left Joystick
      Gui, Controller: Add,Checkbox, xs+5 ys+30     Checked%YesTriggerUtilityJoystickKey%      vYesTriggerUtilityJoystickKey, Use util from`nMove Keys?
      Gui, Controller: Add,GroupBox,  xs ys+90 w80 h40                        ,L3
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonL3, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonL3, %hotkeyControllerButtonL3%

      Gui, Controller: Add,GroupBox,section  xs+190 ys w80 h80                        ,Right Joystick
      Gui, Controller: Add,Checkbox, xp+5 y+-53     Checked%YesTriggerJoystickRightKey%      vYesTriggerJoystickRightKey, Use key?
      Gui, Controller: Add, ComboBox,        xp y+8    w70   vhotkeyControllerJoystickRight, LButton|RButton|q|w|e|r|t
      GuiControl,Controller: Text, hotkeyControllerJoystickRight, %hotkeyControllerJoystickRight%
      Gui, Controller: Add,GroupBox,  xs ys+90 w80 h40                        ,R3
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonR3, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonR3, %hotkeyControllerButtonR3%

      Gui, Controller: Add,GroupBox, section xm+140 ym+60 w80 h40                        ,Select
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonBACK, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonBACK, %hotkeyControllerButtonBACK%
      Gui, Controller: Add,GroupBox, xs+245 ys w80 h40                        ,Start
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButtonSTART, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonSTART, %hotkeyControllerButtonSTART%

      Gui, Controller: Add,GroupBox, section xm+65 ym+280 w40 h40                  ,Up
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyUp, %hotkeyUp%
      Gui, Controller: Add,GroupBox, xs ys+80 w40 h40                        ,Down
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyDown, %hotkeyDown%
      Gui, Controller: Add,GroupBox, xs-40 ys+40 w40 h40                      ,Left
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyLeft, %hotkeyLeft%
      Gui, Controller: Add,GroupBox, xs+40 ys+40 w40 h40                      ,Right
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyRight, %hotkeyRight%

      Gui, Controller: Add,GroupBox,section xm+465 ym+80 w70 h40                      ,Y
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButtonY, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonY, %hotkeyControllerButtonY%
      Gui, Controller: Add,GroupBox, xs ys+80 w70 h40                      ,A
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButtonA, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonA, %hotkeyControllerButtonA%
      Gui, Controller: Add,GroupBox, xs-40 ys+40 w70 h40                      ,X
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButtonX, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonX, %hotkeyControllerButtonX%
      Gui, Controller: Add,GroupBox, xs+40 ys+40 w70 h40                      ,B
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButtonB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonB, %hotkeyControllerButtonB%

      ;Save Setting
      Gui, Controller: Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
      Gui, Controller: Add, Button,      gLaunchSite     x+5           h23,   Website
    }
    Gui, Controller: show , w620 h500, Controller Settings
  }
  Else if (Function = "Globe")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    Element := Var[1]
    If (!Built_Globe || Element = "Reset")
    {
      If (Element = "Reset")
      {
        Gui, Globe: Destroy
        Globe := Array_DeepClone(Base.Globe)
      }
      Built_Globe := 1
      Gui, Globe: New
      Gui, Globe: +AlwaysOnTop -MinimizeBox
      Picker := New ColorPicker("Globe","ColorPicker",460,30,80,200,120,0x000000)
      Gui, Globe: +AlwaysOnTop -MinimizeBox -MaximizeBox
      Gui, Globe: Add, Button, xm ym+8 w1 h1
      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xm ym w205 h100 Section, Life Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_Life_X1 xs+10 yp+20 , % "X1:" Globe.Life.X1
      Gui, Globe: Add, Text, vGlobe_Life_Y1 x+5 yp , % "Y1:" Globe.Life.Y1
      Gui, Globe: Add, Text, vGlobe_Life_X2 xs+10 y+8 , % "X2:" Globe.Life.X2
      Gui, Globe: Add, Text, vGlobe_Life_Y2 x+5 yp , % "Y2:" Globe.Life.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_Life x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.Life.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.Life.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_Life x+1 yp hp, % Globe.Life.Color.Variance
      TempC := Format("0x{1:06X}",Globe.Life.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_Life xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_Life xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_Life h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_Life wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xs+220 ys w205 h100 Section, Mana Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_Mana_X1 xs+10 yp+20 , % "X1:" Globe.Mana.X1
      Gui, Globe: Add, Text, vGlobe_Mana_Y1 x+5 yp , % "Y1:" Globe.Mana.Y1
      Gui, Globe: Add, Text, vGlobe_Mana_X2 xs+10 y+8 , % "X2:" Globe.Mana.X2
      Gui, Globe: Add, Text, vGlobe_Mana_Y2 x+5 yp , % "Y2:" Globe.Mana.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_Mana x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.Mana.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.Mana.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_Mana x+1 yp hp, % Globe.Mana.Color.Variance
      TempC := Format("0x{1:06X}",Globe.Mana.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_Mana xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_Mana xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_Mana h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_Mana wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xm y+60 w205 h100 Section, Energy Shield Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_ES_X1 xs+10 yp+20 , % "X1:" Globe.ES.X1
      Gui, Globe: Add, Text, vGlobe_ES_Y1 x+5 yp , % "Y1:" Globe.ES.Y1
      Gui, Globe: Add, Text, vGlobe_ES_X2 xs+10 y+8 , % "X2:" Globe.ES.X2
      Gui, Globe: Add, Text, vGlobe_ES_Y2 x+5 yp , % "Y2:" Globe.ES.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_ES x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.ES.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.ES.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_ES x+1 yp hp, % Globe.ES.Color.Variance
      TempC := Format("0x{1:06X}",Globe.ES.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_ES xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_ES xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_ES h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_ES wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xs+220 ys w205 h100 Section, Eldritch Battery Scan Area
      Gui, Globe: Font, Bold
      Gui, Globe: Add, Text, vGlobe_EB_X1 xs+10 yp+20 , % "X1:" Globe.EB.X1
      Gui, Globe: Add, Text, vGlobe_EB_Y1 x+5 yp , % "Y1:" Globe.EB.Y1
      Gui, Globe: Add, Text, vGlobe_EB_X2 xs+10 y+8 , % "X2:" Globe.EB.X2
      Gui, Globe: Add, Text, vGlobe_EB_Y2 x+5 yp , % "Y2:" Globe.EB.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_EB x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.EB.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.EB.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_EB x+1 yp hp, % Globe.EB.Color.Variance
      TempC := Format("0x{1:06X}",Globe.EB.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_EB xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_EB xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_EB h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_EB wp hp xp y+5, Show Area


      Gui, Globe: Add, Button, gWR_Update vWR_Save_JSON_Globe ys+110 xm+25, Save Values to JSON file
      Gui, Globe: Add, Button, gWR_Update vWR_Reset_Globe ys+110 xm+240 wp, Reset to Initial Values
      Gui, Globe: Font, s25 Bold c777777
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_Life xm y+15 c78211A, % "Life " Player.Percent.Life "`%"
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_ES x+0 yp c51DEFF, % "ES " Player.Percent.ES "`%"
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_Mana x+0 yp c1460A6, % "Mana " Player.Percent.Mana "`%"
    }
    GlobeActive := True
    Gui, Globe: show , Center AutoSize, Globe Settings
  }
  Else If (Function = "Locate")
  {
    LocateType := Var[2]
    Gui, Hide
    Loop
    {
      MouseGetPos, x, y
      If (x != oldx || y != oldy)
        ToolTip, % "-- Locate "LocateType " --`n@ " x "," y "`nPress Ctrl to set"
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    Tooltip
    %LocateType%X := x, %LocateType%Y := y
    GuiControl, Inventory: ,% LocateType "X", %x%
    GuiControl, Inventory: ,% LocateType "Y", %y%
    MsgBox % x "," y " was captured as the new location for "LocateType
    Gui, Show
  }
  Else If (Function = "Locate2")
  {
    MsgBoxVals(Var,2)
    ; LocateType := Var[2]
    ending := StrSplit(SubStr(Var[2],-1))
    slot := ending[1], position := ending[2]
    Gui, Hide
    Loop
    {
      MouseGetPos, x, y
      If (x != oldx || y != oldy)
        ToolTip, % "-- Locate Swap "slot " "position " --`n@ " x "," y "`nPress Ctrl to set"
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    Tooltip
    swap%slot%X%position% := x, swap%slot%Y%position% := y
    GuiControl, perChar: ,% "swap" slot "X" position, %x%
    GuiControl, perChar: ,% "swap" slot "Y" position, %y%
    MsgBox % x "," y " was captured as the new location for Swap "slot " "position
    Gui, Show
  }
  Else if (Function = "Area")
  {
    Gui, Submit
    Grab := LetUserSelectRect()
    AreaType := Var[2]
    Globe[AreaType].X1 := Grab.X1, Globe[AreaType].Y1 := Grab.Y1, Globe[AreaType].X2 := Grab.X2, Globe[AreaType].Y2 := Grab.Y2
    , Globe[AreaType].Width := Grab.X2 - Grab.X1, Globe[AreaType].Height := Grab.Y2 - Grab.Y1
    GuiControl, Globe:, Globe_%AreaType%_X1,% "X1:" Grab.X1
    GuiControl, Globe:, Globe_%AreaType%_Y1,% "Y1:" Grab.Y1
    GuiControl, Globe:, Globe_%AreaType%_X2,% "X2:" Grab.X2
    GuiControl, Globe:, Globe_%AreaType%_Y2,% "Y2:" Grab.Y2
    Gui, Show
  }
  Else if (Function = "Show")
  {
    Gui, Submit
    AreaType := Var[2]
    MouseTip(Globe[AreaType])
    Gui, Show
  }
  Else if (Function = "Color")
  {
    AreaType := Var[2]
    Element := Var[1]
    Split := {}
    Split.hex := Globe[AreaType].Color.Hex
    Gui, Submit, NoHide
    If (Element = "UpDown")
    {
      Globe[AreaType].Color.Variance := WR_UpDown_Color_%AreaType%
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
    }
    Else If (Element = "Edit")
    {
      CurPos := 1
      newhex := ""
      Loop, 3
      {
        RegExMatch(WR_Edit_Color_%AreaType%, "O)(x[0-9A-Fa-f]{6})", m,CurPos)
        CurPos := m.Pos(0) + m.Len(0) - 1
        If (m.1 != Split.hex && m.1 != "")
        {
          Split.new := m.1
          ; Break
        }
      }
      If (Split.new != "")
        m := "0" Split.new
      Else
        m := "0" Split.hex
      Globe[AreaType].Color.Hex := WR_Edit_Color_%AreaType% := Format("0x{1:06X}",m)
      GuiControl,Globe: , WR_Edit_Color_%AreaType%, % WR_Edit_Color_%AreaType%
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
      GuiControl,% "Globe: +c" Format("0x{1:06X}",WR_Edit_Color_%AreaType%), WR_Progress_Color_%AreaType%
    }
  }
  Else If (Function = "FillMetamorph")
  {
    Gui, Submit
    ValueType := Var[2]
    Element := Var[1]
    If (Element = "Btn")
    {
      If (ValueType = "Menu")
      {
        If (!FillMetamorphInitialized)
        {
          FillMetamorphInitialized := True
          Gui, FillMetamorph: New, -MinimizeBox -Resize
          Gui, FillMetamorph: Font, s12 c777777 bold
          Gui, FillMetamorph: Add, Text, xm+5 vWR_Btn_FillMetamorph_Area w170, % "X1: " FillMetamorph.X1 "  Y1: " FillMetamorph.Y1 "`nX2: " FillMetamorph.X2 "  Y2: " FillMetamorph.Y2
          Gui, FillMetamorph: Font,
          Gui, FillMetamorph: Add, Button, xm+5 gWR_Update vWR_Btn_FillMetamorph_Select w85, Select area
          Gui, FillMetamorph: Add, Button, x+5 yp gWR_Update vWR_Btn_FillMetamorph_Show wp, Show area
          Gui, FillMetamorph: Add, Button, xm+5 gWR_Update vWR_Save_JSON_FillMetamorph w170, Save to JSON
        }
      }
      Else If (ValueType = "Select")
      {
        If (Obj := LetUserSelectRect())
        {
          FillMetamorph := {"X1":Obj.X1
            ,"Y1":Obj.Y1
            ,"X2":Obj.X2
            ,"Y2":Obj.Y2}
          GuiControl,,WR_Btn_FillMetamorph_Area, % "X1: " FillMetamorph.X1 "  Y1: " FillMetamorph.Y1 "`nX2: " FillMetamorph.X2 "  Y2: " FillMetamorph.Y2
        }
      }
      Else If (ValueType = "Show")
      {
        MouseTip(FillMetamorph.X1,FillMetamorph.Y1,FillMetamorph.X2 - FillMetamorph.X1,FillMetamorph.Y2 - FillMetamorph.Y1)
      }
      Gui, FillMetamorph: Show
    }
  }
  Else If (Function = "hkStash")
  {
    Static hkStashBuilt := False
    If !(hkStashBuilt)
    {
      hkStashBuilt := True
      Gui, hkStash: New, +AlwaysOnTop -MinimizeBox -Resize
      ;Save Setting
      Gui, hkStash: Add, Button, default gupdateEverything    x295 y320  w150 h23,   Save Configuration
      Gui, hkStash: Add, Button,      gLaunchSite     x+5           h23,   Website

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section xm+5 ym+50 w150 h80   center                   ,Binding Modifiers
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, xs+5 ys+20 w140 h23 vstashPrefix1, %stashPrefix1%
      Gui, hkStash: Add, Edit, y+5    w140 h23 vstashPrefix2, %stashPrefix2%

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section x+25 ym w100 h275                      ,Keys
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, ys+20 xs+4 w90 h23 vstashSuffix1, %stashSuffix1%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix2, %stashSuffix2%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix3, %stashSuffix3%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix4, %stashSuffix4%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix5, %stashSuffix5%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix6, %stashSuffix6%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix7, %stashSuffix7%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix8, %stashSuffix8%
      Gui, hkStash: Add, Edit, y+5    w90 h23 vstashSuffix9, %stashSuffix9%

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section x+4 ys w50 h275                      ,Tab
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, Number xs+4 ys+20 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab1 , %stashSuffixTab1%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab2 , %stashSuffixTab2%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab3 , %stashSuffixTab3%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab4 , %stashSuffixTab4%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab5 , %stashSuffixTab5%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab6 , %stashSuffixTab6%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab7 , %stashSuffixTab7%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab8 , %stashSuffixTab8%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab9 , %stashSuffixTab9%
    }
    
    Gui, hkStash: Show

  }
  Else If (Function = "JSON")
  {
    ValueType := Var[2]
    Element := Var[1]
    If (Element = "Save")
    {
      Gui, Submit
      JSONtext := JSON.Dump(%ValueType%,,2)
      If FileExist(A_ScriptDir "\save\" ValueType ".json")
        FileDelete, %A_ScriptDir%\save\%ValueType%.json
      FileAppend, %JSONtext%, %A_ScriptDir%\save\%ValueType%.json
      Gui, Show
    }
    Else if (Element = "Load")
    {
      If FileExist(A_ScriptDir "\save\" ValueType ".json")
      {
        FileRead, JSONtext, %A_ScriptDir%\save\%ValueType%.json
        %ValueType% := JSON.Load(JSONtext)
      }
      Else
      {
        Notify("Error loading " ValueType " file","",3)
        Log("Error loading " ValueType " file")
      }
    }
  }
  Return

  WR_Update:
  If (A_GuiControl ~= "WR_\w{1,}_")
  {
    BtnStr := StrSplit(StrSplit(A_GuiControl, "WR_", " ")[2], "_", " ",3)
    ; Naming convention: WR_GuiElementType_FunctionName_ExtraStuff_AfterFunctionName
    ; Function = FunctionName, Var[1] = GuiElementType, Var[2] = ExtraStuff_AfterFunctionName
    WR_Menu(BtnStr[2],BtnStr[1],BtnStr[3])
  }  
  Return


  ColorLabel_Life:
  Picker.SetColor(Globe.Life.Color.hex)
  Return
  ColorLabel_Mana:
  Picker.SetColor(Globe.Mana.Color.hex)
  Return
  ColorLabel_ES:
  Picker.SetColor(Globe.ES.Color.hex)
  Return
  ColorLabel_EB:
  Picker.SetColor(Globe.EB.Color.hex)
  Return

  FillMetamorphGuiClose:
  FillMetamorphGuiEscape:
    Gui, Submit
    Gui, Inventory: Show
  Return

  hkStashGuiClose:
  hkStashGuiEscape:
  InventoryGuiClose:
  InventoryGuiEscape:
  CraftingGuiClose:
  CraftingGuiEscape:
  StringsGuiClose:
  StringsGuiEscape:
  ChatGuiClose:
  ChatGuiEscape:
  ControllerGuiClose:
  ControllerGuiEscape:
  HotkeysGuiClose:
  HotkeysGuiEscape:
    Gui, Submit
    Gui, 1: show
    CheckGamestates:= True
    mainmenuGameLogicState(True)
  return
  
  GlobeGuiClose:
  GlobeGuiEscape:
    GlobeActive := False
    Gui, Submit
    Gui, 1: show
    CheckGamestates:= True
    mainmenuGameLogicState(True)
  return
}
; Make a MsgBox Printout of an array
MsgBoxVals(obj,indent:=0){
  txt := ""
  Loop % indent
    spacing .= " "
  If IsObject(obj)
  {
    For k, v in obj
    {
      txt .= (k==1&&!indent?"":"`n") spacing
      txt .= "Key:`t"k "`t"
          . "Val:`t" (IsObject(v)?"OBJECT":v)
      If IsObject(v)
      txt .= MsgBoxVals(v,indent+1)
    }
  } Else {
    txt := obj
  }
  If indent
    Return txt
  Else
    MsgBox % txt
}
Get_DpiFactor() {
  return A_ScreenDPI=96?1:A_ScreenDPI/96
}
Scale_PositionFromDPI(val){
  dpif := Get_DpiFactor()
  If (dpif != 1)
    val := val / dpif
  Return val
}
GreyOutAffinity(){
  Static Lista := ["Blight","Delirium","Divination","Fragment","Metamorph","Delve","Essence","Map","Currency","Unique"]
  for key, val in Lista
  {
    GuiControlGet, CheckBoxState,, StashTabYes%val%
    If (CheckBoxState == 0)
    { 
      GuiControl, Disable, %val%Edit
      GuiControl, , %val%EditText, Disable Type
    } 
    Else If (CheckBoxState == 1)
    {
      GuiControl, Enable, %val%Edit
      GuiControl, , %val%EditText, Assign a Tab
    }
    Else 
    {
      if(val !="Currency" )
      {
        GuiControl, Disable, %val%Edit
      }
      GuiControl, , %val%EditText, Enable Affinity
    }
  }
  Return
}
; Find and retreive Chaos recipe items from a Stash Tab
ChaosRecipe(endAtRefresh := 0){
  If (AccountNameSTR = "")
    AccountNameSTR := POE_RequestAccount().accountName
  Global RecipeArray := {}

  If ChaosRecipeStashMethodDump
  {
    Object := POE_RequestStash(StashTabDump,0)
    ItemTypes := ChaosRecipeSort(Object)
  }
  Else If ChaosRecipeStashMethodTab
  {
    Object := POE_RequestStash(ChaosRecipeStashTab,0)
    ItemTypes := ChaosRecipeSort(Object)
  }
  Else If ChaosRecipeStashMethodSort
  {
    requestedTabs := []
    for k, part in ["Weapon", "Helmet", "Armour", "Gloves", "Boots", "Belt", "Amulet", "Ring"]
    {
      If !indexOf(ChaosRecipeStashTab%part%,requestedTabs)
      {
        requestedTabs.Push(ChaosRecipeStashTab%part%)
        Object := POE_RequestStash(ChaosRecipeStashTab%part%,0)
        ChaosRecipeSort(Object,True)
        Sleep, 300
      }
    }
    If RecipeArray.Count()
      ItemTypes := RecipeArray
    Else
      ItemTypes := False
  }
  
  If endAtRefresh
  {
    If (ItemTypes)
      Return True
    Else
      Return False
  }
  Return ChaosRecipeReturn(ItemTypes)
}
ChaosRecipeSort(Object,Merge:=False){
  Global RecipeArray
  Chaos := {}
  Regal := {}
  uChaos := {}
  uRegal := {}
  For i, content in Object.items
  {
    item := new ItemBuild(content,Object.quadLayout)
    ; Array_Gui(item)
    If (item.Prop.ChaosRecipe)
    {
      If !IsObject((item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType])
        (item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType] := {}
      (item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType].Push(item)
    }
    If (item.Prop.RegalRecipe)
    {
      If !IsObject((item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType])
        (item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType] := {}
      (item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType].Push(item)
    }
  }
  If (!(i > 0) && !Merge)
  {
    Return False
  }
  If Merge
  {
    For k, type in ["Chaos","uChaos","Regal","uRegal"]
    {
      For slot, itemArr in %type%
      {
        If !IsObject(RecipeArray[type])
          RecipeArray[type] := {}
        For key, item in itemArr
        {
          If !IsObject(RecipeArray[type][slot])
            RecipeArray[type][slot] := {}
          RecipeArray[type][slot].Push(item)
        }
      }
    }
  }
  Else
    RecipeArray := { "Chaos" : Chaos, "uChaos" : uChaos, "Regal" : Regal, "uRegal" : uRegal}
  Return RecipeArray
}
confirmOneOfEach(Object,id:=True){
  ; Confirm we have at least one of each armour slot and 2 rings
  for k, kind in ["Amulet","Ring","Belt","Body","Boots","Gloves","Helmet"]
  {
    If ChaosRecipeTypeHybrid
    {
      result := getCount(Object[id?"Chaos":"uChaos"][kind]) + getCount(Object[id?"Regal":"uRegal"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
    Else If ChaosRecipeTypePure
    {
      result := getCount(Object[id?"Chaos":"uChaos"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
    Else If ChaosRecipeTypeRegal
    {
      result := getCount(Object[id?"Regal":"uRegal"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
  }

  ; now lets confirm we have a valid combination of weapons
  If ChaosRecipeTypeHybrid
  {
    2hresult := getCount(Object[id?"Chaos":"uChaos"]["Two Hand"]) + getCount(Object[id?"Regal":"uRegal"]["Two Hand"])
    1hresult := getCount(Object[id?"Chaos":"uChaos"]["One Hand"]) + getCount(Object[id?"Regal":"uRegal"]["One Hand"])
    1hresult += getCount(Object[id?"Chaos":"uChaos"]["Shield"]) + getCount(Object[id?"Regal":"uRegal"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }
  Else If ChaosRecipeTypePure
  {
    2hresult := getCount(Object[id?"Chaos":"uChaos"]["Two Hand"])
    1hresult := getCount(Object[id?"Chaos":"uChaos"]["One Hand"])
    1hresult += getCount(Object[id?"Chaos":"uChaos"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }
  Else If ChaosRecipeTypeRegal
  {
    2hresult := getCount(Object[id?"Regal":"uRegal"]["Two Hand"])
    1hresult := getCount(Object[id?"Regal":"uRegal"]["One Hand"])
    1hresult += getCount(Object[id?"Regal":"uRegal"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }

  ; If we make it this far, all checks have passed
  Return True
}
ChaosRecipeReturn(Object){
  RecipeSets:={}
  types := ["Chaos","Regal","uChaos","uRegal"]
  If ChaosRecipeTypePure{
    Loop {
      ; Most basic check for one recipe, no logic to determine if Regal or Chaos set
      If confirmOneOfEach(Object,True)
      {
        Set := {}
        If (IsObject(Object.Chaos.Shield.1) && IsObject(Object.Chaos.Shield.2))
        {
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos.Shield.1) && IsObject(Object.Chaos["One Hand"].1))
        {
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos["Two Hand"].1))
        {
          Set.Push(Object.Chaos["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos["One Hand"].1) && IsObject(Object.Chaos["One Hand"].2))
        {
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.Chaos.Amulet.RemoveAt(1))
        Set.Push(Object.Chaos.Ring.RemoveAt(1))
        Set.Push(Object.Chaos.Ring.RemoveAt(1))
        Set.Push(Object.Chaos.Belt.RemoveAt(1))
        Set.Push(Object.Chaos.Body.RemoveAt(1))
        Set.Push(Object.Chaos.Boots.RemoveAt(1))
        Set.Push(Object.Chaos.Gloves.RemoveAt(1))
        Set.Push(Object.Chaos.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else If confirmOneOfEach(Object,False)
      {
        Set := {}
        If (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uChaos.Shield.2))
        {
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uChaos["One Hand"].1))
        {
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos["Two Hand"].1))
        {
          Set.Push(Object.uChaos["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos["One Hand"].1) && IsObject(Object.uChaos["One Hand"].2))
        {
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.uChaos.Amulet.RemoveAt(1))
        Set.Push(Object.uChaos.Ring.RemoveAt(1))
        Set.Push(Object.uChaos.Ring.RemoveAt(1))
        Set.Push(Object.uChaos.Belt.RemoveAt(1))
        Set.Push(Object.uChaos.Body.RemoveAt(1))
        Set.Push(Object.uChaos.Boots.RemoveAt(1))
        Set.Push(Object.uChaos.Gloves.RemoveAt(1))
        Set.Push(Object.uChaos.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  } Else If (ChaosRecipeTypeHybrid){
    Loop {
      ; Hybrid filter for determining at least one chaos item is present, then using up all regal items
      If ( confirmOneOfEach(Object,True) && getCount(Object.Chaos) )
      {
        Set := {}
        ChaosPresent := False
        If ( ( (IsObject(Object.Chaos.Shield.1) || IsObject(Object.Regal.Shield.1) ) && ( IsObject(Object.Chaos.Shield.2) || IsObject(Object.Regal.Shield.2) ) ) 
        || ( IsObject(Object.Chaos.Shield.1) && IsObject(Object.Regal.Shield.1) ) )
        {
          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal.Shield.1) )
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.Chaos.Shield.1) || IsObject(Object.Regal.Shield.1)) && (IsObject(Object.Chaos["One Hand"].1) || IsObject(Object.Regal["One Hand"].1)))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal.Shield.1) )
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If (IsObject(Object.Chaos["Two Hand"].1) || IsObject(Object.Regal["Two Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos["Two Hand"].1)) && IsObject(Object.Regal["Two Hand"].1)
            Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["Two Hand"].1) )
            Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["Two Hand"].1))
            Set.Push(Object.Chaos["Two Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.Chaos["One Hand"].1) || IsObject(Object.Regal["One Hand"].1)) && (IsObject(Object.Chaos["One Hand"].2) || IsObject(Object.Regal["One Hand"].2))) 
        || (IsObject(Object.Chaos["One Hand"].1) && IsObject(Object.Regal["One Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else 
          Break

        If (!ChaosPresent && !IsObject(Object.Chaos.Body.1)) && IsObject(Object.Regal.Body.1)
          Set.Push(Object.Regal.Body.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Body.1) )
          Set.Push(Object.Regal.Body.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Body.1))
          Set.Push(Object.Chaos.Body.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Helmet.1)) && IsObject(Object.Regal.Helmet.1)
          Set.Push(Object.Regal.Helmet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Helmet.1) )
          Set.Push(Object.Regal.Helmet.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Helmet.1))
          Set.Push(Object.Chaos.Helmet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Gloves.1)) && IsObject(Object.Regal.Gloves.1)
          Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Gloves.1) )
          Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Gloves.1))
          Set.Push(Object.Chaos.Gloves.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Boots.1)) && IsObject(Object.Regal.Boots.1)
          Set.Push(Object.Regal.Boots.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Boots.1) )
          Set.Push(Object.Regal.Boots.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Boots.1))
          Set.Push(Object.Chaos.Boots.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Belt.1)) && IsObject(Object.Regal.Belt.1)
          Set.Push(Object.Regal.Belt.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Belt.1) )
          Set.Push(Object.Regal.Belt.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Belt.1))
          Set.Push(Object.Chaos.Belt.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Amulet.1)) && IsObject(Object.Regal.Amulet.1)
          Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Amulet.1) )
          Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Amulet.1))
          Set.Push(Object.Chaos.Amulet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Ring.1)) && IsObject(Object.Regal.Ring.1)
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Ring.1) )
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Ring.1))
          Set.Push(Object.Chaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Ring.1)) && IsObject(Object.Regal.Ring.1)
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Ring.1) )
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Ring.1))
          Set.Push(Object.Chaos.Ring.RemoveAt(1)), ChaosPresent := True

        RecipeSets.Push(Set)
      }
      Else If ( confirmOneOfEach(Object,False) && getCount(Object.uChaos) )
      {
        Set := {}
        ChaosPresent := False
        If ((IsObject(Object.uChaos.Shield.1) || IsObject(Object.uRegal.Shield.1)) && (IsObject(Object.uChaos.Shield.2) || IsObject(Object.uRegal.Shield.2))) 
        || (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uRegal.Shield.1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal.Shield.1) )
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.uChaos.Shield.1) || IsObject(Object.uRegal.Shield.1)) && (IsObject(Object.uChaos["One Hand"].1) || IsObject(Object.uRegal["One Hand"].1)))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal.Shield.1) )
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If (IsObject(Object.uChaos["Two Hand"].1) || IsObject(Object.uRegal["Two Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos["Two Hand"].1)) && IsObject(Object.uRegal["Two Hand"].1)
            Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["Two Hand"].1) )
            Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["Two Hand"].1))
            Set.Push(Object.uChaos["Two Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.uChaos["One Hand"].1) || IsObject(Object.uRegal["One Hand"].1)) && (IsObject(Object.uChaos["One Hand"].2) || IsObject(Object.uRegal["One Hand"].2))) 
        || (IsObject(Object.uChaos["One Hand"].1) && IsObject(Object.uRegal["One Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else 
          Break

        If (!ChaosPresent && !IsObject(Object.uChaos.Amulet.1)) && IsObject(Object.uRegal.Amulet.1)
          Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Amulet.1) )
          Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Amulet.1))
          Set.Push(Object.uChaos.Amulet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Ring.1)) && IsObject(Object.uRegal.Ring.1)
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Ring.1) )
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Ring.1))
          Set.Push(Object.uChaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Ring.1)) && IsObject(Object.uRegal.Ring.1)
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Ring.1) )
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Ring.1))
          Set.Push(Object.uChaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Belt.1)) && IsObject(Object.uRegal.Belt.1)
          Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Belt.1) )
          Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Belt.1))
          Set.Push(Object.uChaos.Belt.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Body.1)) && IsObject(Object.uRegal.Body.1)
          Set.Push(Object.uRegal.Body.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Body.1) )
          Set.Push(Object.uRegal.Body.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Body.1))
          Set.Push(Object.uChaos.Body.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Boots.1)) && IsObject(Object.uRegal.Boots.1)
          Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Boots.1) )
          Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Boots.1))
          Set.Push(Object.uChaos.Boots.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Gloves.1)) && IsObject(Object.uRegal.Gloves.1)
          Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Gloves.1) )
          Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Gloves.1))
          Set.Push(Object.uChaos.Gloves.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Helmet.1)) && IsObject(Object.uRegal.Helmet.1)
          Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Helmet.1) )
          Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Helmet.1))
          Set.Push(Object.uChaos.Helmet.RemoveAt(1)), ChaosPresent := True

        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  } Else If (ChaosRecipeTypeRegal){
    Loop {
      ; Most basic check for one recipe, no logic to determine if Regal or Chaos set
      If confirmOneOfEach(Object,True)
      {
        Set := {}
        If (IsObject(Object.Regal.Shield.1) && IsObject(Object.Regal.Shield.2))
        {
          Set.Push(Object.Regal.Shield.RemoveAt(1))
          Set.Push(Object.Regal.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.Regal.Shield.1) && IsObject(Object.Regal["One Hand"].1))
        {
          Set.Push(Object.Regal.Shield.RemoveAt(1))
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Regal["Two Hand"].1))
        {
          Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Regal["One Hand"].1) && IsObject(Object.Regal["One Hand"].2))
        {
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Set.Push(Object.Regal.Ring.RemoveAt(1))
        Set.Push(Object.Regal.Ring.RemoveAt(1))
        Set.Push(Object.Regal.Belt.RemoveAt(1))
        Set.Push(Object.Regal.Body.RemoveAt(1))
        Set.Push(Object.Regal.Boots.RemoveAt(1))
        Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Set.Push(Object.Regal.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else If confirmOneOfEach(Object,False)
      {
        Set := {}
        If (IsObject(Object.uRegal.Shield.1) && IsObject(Object.uRegal.Shield.2))
        {
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal.Shield.1) && IsObject(Object.uRegal["One Hand"].1))
        {
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal["Two Hand"].1))
        {
          Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal["One Hand"].1) && IsObject(Object.uRegal["One Hand"].2))
        {
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Set.Push(Object.uRegal.Body.RemoveAt(1))
        Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  }
  Return RecipeSets
}
getCount(Object,full:=False){
  c := 0
  For slot, items in Object
  {
    If !full
      c++
    Else {
      for ik, itm in items
        c++
    }
  }
  Return c
}
retCount(obj){
  Return (obj.Count()>=0?obj.Count():0) 
}
; ArrayToString - Make a string from array using | as delimiters
ArrayToString(Array)
{
  for index, element in Array
  {
    if(text == "")
    {
      text = %element% 
    }
    else
    {
      text = %text%|%element% 
    }
  }
  return text
}
; StringToArray - Make a array from a string using | as delimiters
StringToArray(text)
{
  Array := StrSplit(text,"|")
  return array
}
; Debug messages within script
Ding(Timeout:=500, MultiTooltip:=0 , Message*)
{
  If (!DebugMessages && MultiTooltip >= 0)
    Return
  Else
  {
    If MultiTooltip < 0
      MultiTooltip := Abs(MultiTooltip)
    debugStr := ""
    If Message.Count()
    {
      For mkey, mval in Message
      {
        If mval=
          Continue
        If A_Index = 1
        {
          If MultiTooltip
            ToolTip, %mval%, 20, % 40 + MultiTooltip* 23, %MultiTooltip% 
          Else
            debugStr .= Message.A_Index
        }
        Else if A_Index <= 20
        {
          If MultiTooltip
            ToolTip, %mval%, 20, % 40 + A_Index* 23, %A_Index% 
          Else
            debugStr .= "`n" . Message.A_Index
        }
      }
      If !MultiTooltip
        Tooltip, %debugStr%
    }
    Else
    {
      If MultiTooltip
        ToolTip, Ding, 20, % 40 + MultiTooltip* 23, %MultiTooltip% 
      Else
        Tooltip, Ding
    }
  }
  If Timeout
  {
    If MultiTooltip
      SetTimer, RemoveTT%MultiTooltip%, %Timeout%
    Else
      SetTimer, RemoveToolTip, %Timeout%
  }
  Return
}
; tooltip management
RemoveToolTip()
{
  SetTimer, , Off
  Loop, 20
  {
    SetTimer, RemoveTT%A_Index%, Off
    ToolTip,,,,%A_Index%
  }
  PauseTooltips := 0
  return

  RemoveTT1:
    SetTimer, , Off
    ToolTip,,,,1
  Return

  RemoveTT2:
    SetTimer, , Off
    ToolTip,,,,2
  Return

  RemoveTT3:
    SetTimer, , Off
    ToolTip,,,,3
  Return

  RemoveTT4:
    SetTimer, , Off
    ToolTip,,,,4
  Return

  RemoveTT5:
    SetTimer, , Off
    ToolTip,,,,5
  Return

  RemoveTT6:
    SetTimer, , Off
    ToolTip,,,,6
  Return

  RemoveTT7:
    SetTimer, , Off
    ToolTip,,,,7
  Return

  RemoveTT8:
    SetTimer, , Off
    ToolTip,,,,8
  Return

  RemoveTT9:
    SetTimer, , Off
    ToolTip,,,,9
  Return

  RemoveTT10:
    SetTimer, , Off
    ToolTip,,,,10
  Return

  RemoveTT11:
    SetTimer, , Off
    ToolTip,,,,11
  Return

  RemoveTT12:
    SetTimer, , Off
    ToolTip,,,,12
  Return

  RemoveTT13:
    SetTimer, , Off
    ToolTip,,,,13
  Return

  RemoveTT14:
    SetTimer, , Off
    ToolTip,,,,14
  Return

  RemoveTT15:
    SetTimer, , Off
    ToolTip,,,,15
  Return

  RemoveTT16:
    SetTimer, , Off
    ToolTip,,,,16
  Return

  RemoveTT17:
    SetTimer, , Off
    ToolTip,,,,17
  Return

  RemoveTT18:
    SetTimer, , Off
    ToolTip,,,,18
  Return

  RemoveTT19:
    SetTimer, , Off
    ToolTip,,,,19
  Return

  RemoveTT20:
    SetTimer, , Off
    ToolTip,,,,20
  Return
}
ShowToolTip()
{
  global ft_ToolTip_Text
  If (PauseTooltips || GameActive)
    Return
  ListLines, Off
  static CurrControl, PrevControl, _TT
  CurrControl := A_GuiControl
  if (CurrControl != PrevControl)
  {
  PrevControl := CurrControl
  ToolTip
  if (CurrControl != "")
    SetTimer, ft_DisplayToolTip, -500
  }
  return

  ft_DisplayToolTip:
  If PauseTooltips
    Return
  ListLines, Off
  MouseGetPos,,, _TT
  WinGetClass, _TT, ahk_id %_TT%
  if (_TT = "AutoHotkeyGUI")
  {
  ToolTip, % RegExMatch(ft_ToolTip_Text, "m`n)^"
    . StrReplace(CurrControl,"ft_") . "\K\s*=.*", _TT)
    ? StrReplace(Trim(_TT,"`t ="),"\n","`n") : ""
  SetTimer, ft_RemoveToolTip, -5000
  }
  return

  ft_RemoveToolTip:
  ToolTip
  return
}
; GuiStatus - Determine the gamestates by checking for specific pixel colors
GuiStatus(Fetch:="",SS:=1){
  Global YesXButtonFound, OnChar, OnChat, OnMenu, OnInventory, OnStash, OnVendor, OnDiv, OnLeft, OnDelveChart, OnMetamorph, OnLocker, OnDetonate
  If (SS)
    ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH)
  If (Fetch="OnDetonate")
  {
    POnDetonateDelve := ScreenShot_GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y), POnDetonate := ScreenShot_GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
    , OnDetonate := ((POnDetonateDelve=varOnDetonate || POnDetonate=varOnDetonate)?True:False)
    Return OnDetonate
  }
  Else If !(Fetch="")
  {
    P%Fetch% := ScreenShot_GetColor(WR.loc.pixel[Fetch].X,WR.loc.pixel[Fetch].Y)
    temp := %Fetch% := (P%Fetch%=var%Fetch%?True:False)
    Return temp
  }
  If (YesXButtonFound||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker)
    CheckXButton(), xChecked := True
  POnChar := ScreenShot_GetColor(WR.loc.pixel.OnChar.X,WR.loc.pixel.OnChar.Y), OnChar := (POnChar=varOnChar?True:False)
  POnChat := ScreenShot_GetColor(WR.loc.pixel.OnChat.X,WR.loc.pixel.OnChat.Y), OnChat := (POnChat=varOnChat?True:False)
  POnMenu := ScreenShot_GetColor(WR.loc.pixel.OnMenu.X,WR.loc.pixel.OnMenu.Y), OnMenu := (POnMenu=varOnMenu?True:False)
  POnInventory := ScreenShot_GetColor(WR.loc.pixel.OnInventory.X,WR.loc.pixel.OnInventory.Y), OnInventory := (POnInventory=varOnInventory?True:False)
  POnStash := ScreenShot_GetColor(WR.loc.pixel.OnStash.X,WR.loc.pixel.OnStash.Y), OnStash := (POnStash=varOnStash?True:False)
  POnVendor := ScreenShot_GetColor(WR.loc.pixel.OnVendor.X,WR.loc.pixel.OnVendor.Y), OnVendor := (POnVendor=varOnVendor?True:False)
  POnDiv := ScreenShot_GetColor(WR.loc.pixel.OnDiv.X,WR.loc.pixel.OnDiv.Y), OnDiv := (POnDiv=varOnDiv?True:False)
  POnLeft := ScreenShot_GetColor(WR.loc.pixel.OnLeft.X,WR.loc.pixel.OnLeft.Y), OnLeft := (POnLeft=varOnLeft?True:False)
  POnDelveChart := ScreenShot_GetColor(WR.loc.pixel.OnDelveChart.X,WR.loc.pixel.OnDelveChart.Y), OnDelveChart := (POnDelveChart=varOnDelveChart?True:False)
  POnMetamorph := ScreenShot_GetColor(WR.loc.pixel.OnMetamorph.X,WR.loc.pixel.OnMetamorph.Y), OnMetamorph := (POnMetamorph=varOnMetamorph?True:False)
  POnLocker := ScreenShot_GetColor(WR.loc.pixel.OnLocker.X,WR.loc.pixel.OnLocker.Y), OnLocker := (POnLocker=varOnLocker?True:False)
  If OnMines
  POnDetonate := ScreenShot_GetColor(WR.loc.pixel.DetonateDelve.X,WR.loc.pixel.Detonate.Y)
  Else POnDetonate := ScreenShot_GetColor(WR.loc.pixel.Detonate.X,WR.loc.pixel.Detonate.Y)
  OnDetonate := (POnDetonate=varOnDetonate?True:False)
  If (!xChecked && (OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker))
    CheckXButton()
  Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker||YesXButtonFound))
}
GuiCheck(){
  Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph||OnLocker))
}
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
; ColorPicker - Create a color Picker into any GUI window or stand alone
class ColorPicker {
  __New(pGroup_GUI_NAME:="ColorPicker", pGroup_ID:="ColorPicker" , pGroup_X:=10 , pGroup_Y:=30 , pGroup_W:=90 , pGroup_H:=280, pGroup_SideBar:=110, pGroup_Start_Color:="000000"){
    This.GUI_NAME := pGroup_GUI_NAME
    This.ID := pGroup_ID
    This.X := pGroup_X
    This.Y := pGroup_Y
    This.W := pGroup_W
    This.H := pGroup_H
    This.SideBar := pGroup_SideBar
    This.Spacing := This.W // 2.5
    This.W_Bar := This.W // 4
    This.Start_Color := pGroup_Start_Color
    This.Start_Red := (0xff0000 & pGroup_Start_Color) >> 16
    This.Start_Green := (0x00ff00 & pGroup_Start_Color) >> 8
    This.Start_Blue := 0x0000ff & pGroup_Start_Color

    ; Gui,% This.GUI_NAME ":Destroy"
    Gui,% This.GUI_NAME ":+AlwaysOnTop +ToolWindow"
    Gui,% This.GUI_NAME ":Color",000000
    Gui,% This.GUI_NAME ":Font",s10 w600

    Edit_Trigger := This.UpdateColor.BIND( THIS ) 

    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Red_Edit_Hex" ,% Format("{1:02X}",This.Start_Red)
    This.Slider_Red := New Progress_Slider(This.GUI_NAME,This.ID "_Red",This.X ,This.Y,This.W_Bar,This.H,0,255,This.Start_Red,"550000","BB0000",2,This.ID "_Red_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Red_Edit hwndRedTriggerhwnd",% This.Start_Red
    GUICONTROL +G , %RedTriggerhwnd% , % Edit_Trigger

    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 + This.Spacing " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Green_Edit_Hex" ,% Format("{1:02X}",This.Start_Green)
    This.Slider_Green := New Progress_Slider(This.GUI_NAME,This.ID "_Green",This.X + This.Spacing,This.Y,This.W_Bar,This.H,0,255,This.Start_Green,"005500","00BB00",2,This.ID "_Green_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 + This.Spacing " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Green_Edit hwndGreenTriggerhwnd" ,% This.Start_Green
    GUICONTROL +G , %GreenTriggerhwnd% , % Edit_Trigger


    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 + This.Spacing * 2 " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Blue_Edit_Hex" ,% Format("{1:02X}",This.Start_Blue)
    This.Slider_Blue := New Progress_Slider(This.GUI_NAME,This.ID "_Blue",This.X + This.Spacing*2,This.Y,This.W_Bar,This.H,0,255,This.Start_Blue,"000055","0000BB",2,This.ID "_Blue_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 + This.Spacing * 2 " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Blue_Edit hwndBlueTriggerhwnd" ,% This.Start_Blue
    GUICONTROL +G , %BlueTriggerhwnd% , % Edit_Trigger


    Gui,% This.GUI_NAME ":Font",s15 w600
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X + This.Spacing * 3 " y" This.Y - 22 " w" This.SideBar "h17 -E0x200 Center Disabled v" This.ID "_Group_Color_Hex" ,% Format("0x{1:06X}",This.Start_Color)
  
    Copy_Trigger := This.CopyColor.BIND( THIS )

    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y " w" This.SideBar " h" This.H // 2 + 40 " hwndCopyTriggerhwnd center",
    GUICONTROL +G , %CopyTriggerhwnd% , % Copy_Trigger
    
    Gui,% This.GUI_NAME ":Add",Progress,% "x" This.X + This.Spacing * 3 " y" This.Y " w" This.SideBar " h" This.H // 2 + 20 " Background000000 c" Format("{1:06X}",This.Start_Color) " v" This.ID "_Group_Color", 100

    Gui,% This.GUI_NAME ":Font",s25 w600 c77BB77
    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y + This.H // 2 + 30 " w" This.SideBar " h" (This.H // 2 - 40) // 2 + 10 " hwndCopyTriggerhwnd center", Copy
    GUICONTROL +G , %CopyTriggerhwnd% , % Copy_Trigger
    Gui,% This.GUI_NAME ":Font",s25 w600 cBB7777
    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y + This.H // 2 + 40 + 10 + (This.H // 2 - 40) // 2 " w" This.SideBar " h" (This.H // 2 - 40) // 2 + 10 " gCoordCommand center", Coord


    ; Gui,% This.GUI_NAME ":Show", AutoSize, Color Picker
  }
  UpdateColor(){
    GuiControl, % This.GUI_NAME ": +c" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value), % This.ID "_Group_Color",
    GuiControl, % This.GUI_NAME ":", % This.ID "_Group_Color_Hex", % "0x" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value)
  }
  SetColor(newColor){
      This.Start_Color := Format("0x{1:06X}",newColor)
      This.Start_Red := (0xff0000 & newColor) >> 16
      This.Start_Green := (0x00ff00 & newColor) >> 8
      This.Start_Blue := 0x0000ff & newColor
      This.Slider_Red.SET_pSlider(This.Start_Red)
      This.Slider_Green.SET_pSlider(This.Start_Green)
      This.Slider_Blue.SET_pSlider(This.Start_Blue)
  }
  CopyColor(){
    Clipboard := "0x" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value)
    ; MsgBox, 262144, Color Copied, The Hex color code has been copied to the Clipboard `n`n %Clipboard%
    Notify("Copied To Clipboard`n`n" Clipboard,"",3)
  }
}
; Progress_Slider - Class written by Hellbent on AHK forum, adjusted by Bandit
class Progress_Slider  {
  __New(pSlider_GUI_NAME , pSlider_Control_ID , pSlider_X , pSlider_Y , pSlider_W , pSlider_H , pSlider_Range_Start , pSlider_Range_End , pSlider_Value:=0 , pSlider_Background_Color := "Black" , pSlider_Top_Color := "Red" , pSlider_Pair_With_Edit := 0 , pSlider_Paired_Edit_ID := "" , pSlider_Use_Tooltip := 0 ,  pSlider_Vertical := 0 , pSlider_Smooth := 1, SaveINISection := ""){
    This.GUI_NAME:=pSlider_GUI_NAME
    This.Control_ID:=pSlider_Control_ID
    This.X := pSlider_X
    This.Y := pSlider_Y
    This.W := pSlider_W
    This.H := pSlider_H
    This.Start_Range := pSlider_Range_Start
    This.End_Range := pSlider_Range_End
    This.Slider_Value := pSlider_Value
    This.Background_Color := pSlider_Background_Color
    This.Top_Color := pSlider_Top_Color
    This.Vertical := pSlider_Vertical
    This.Smooth := pSlider_Smooth
    This.Pair_With_Edit := pSlider_Pair_With_Edit
      ; Options
      ; 0 := Do not pair with edit
      ; 1 := Pair with only Decimal Edit
      ; 2 := Pair with both Decimal and Hex Edit
      ; 3 := Pair with only Hex Edit
    This.Paired_Edit_ID := pSlider_Paired_Edit_ID
    This.Paired_Edit_ID_Hex := (pSlider_Paired_Edit_ID != "" ? pSlider_Paired_Edit_ID . "_Hex" : "")
    This.Use_Tooltip := pSlider_Use_Tooltip
    This.SaveINISection := SaveINISection
    This.Add_pSlider()
  }
  Add_pSlider(){
    global
    Gui, % This.GUI_NAME ":Add" , Text , % "x" This.X " y" This.Y " w" This.W " h" This.H " hwndpSliderTriggerhwnd"
    pSlider_Trigger := This.Adjust_pSlider.BIND( THIS ) 
    GUICONTROL +G , %pSliderTriggerhwnd% , % pSlider_Trigger
    if(This.Smooth=1&&This.Vertical=0)
      Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " Background" This.Background_Color " c" This.Top_Color " Range" This.Start_Range "-" This.End_Range  " v" This.Control_ID ,% This.Slider_Value
    else if(This.Smooth=0&&This.Vertical=0)
      Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " -Smooth Range" This.Start_Range "-" This.End_Range  " v" This.Control_ID ,% This.Slider_Value
    else if(This.Smooth=1&&This.Vertical=1)
      Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " Background" This.Background_Color " c" This.Top_Color " Range" This.Start_Range "-" This.End_Range  " Vertical v" This.Control_ID ,% This.Slider_Value
    else if(This.Smooth=0&&This.Vertical=1)
      Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " -Smooth Range" This.Start_Range "-" This.End_Range  " Vertical v" This.Control_ID ,% This.Slider_Value
  }
  Adjust_pSlider(){
    Static OldVal
    CoordMode,Mouse,Client
    while(GetKeyState("LButton")){
      Static LastTT := 0
      MouseGetPos,pSlider_Temp_X,pSlider_Temp_Y
      pSlider_Temp_X := Scale_PositionFromDPI(pSlider_Temp_X), pSlider_Temp_Y := Scale_PositionFromDPI(pSlider_Temp_Y)
      if(This.Vertical=0)
        This.Slider_Value := Round((pSlider_Temp_X - This.X ) / ( This.W / (This.End_Range - This.Start_Range) )) + This.Start_Range
      else
        This.Slider_Value := Round(((pSlider_Temp_Y - This.Y ) / ( This.H / (This.End_Range - This.Start_Range) )) + This.Start_Range )* -1 + This.End_Range
      if(This.Slider_Value > This.End_Range )
        This.Slider_Value:=This.End_Range
      else if(This.Slider_Value<This.Start_Range)
        This.Slider_Value:=This.Start_Range
      GuiControl,% This.GUI_NAME ":" ,% This.Control_ID , % This.Slider_Value 
      if(This.Pair_With_Edit>=1 && This.Slider_Value != OldVal)
      {
        OldVal := This.Slider_Value
        if(This.Pair_With_Edit<=2)
        {
          GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID , % This.Slider_Value
          If (This.SaveINISection)
            IniWrite, % This.Slider_Value, %A_ScriptDir%\save\Settings.ini, % This.SaveINISection, % This.Paired_Edit_ID
        }
        if(This.Pair_With_Edit>=2)
        GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID_Hex , % Format("{1:02X}",This.Slider_Value)
      }
      if(This.Add_Method!=0)
      {
        
        GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID_Hex , % Format("{1:02X}",This.Slider_Value)
      }
      if(This.Use_Tooltip=1 && A_TickCount - LastTT > 100 )
      {
        LastTT := A_TickCount
        ToolTip , % This.Slider_Value 
      }
    }
    if(This.Use_Tooltip=1)
      ToolTip,
  }
  SET_pSlider(NEW_pSlider_Value){
    This.Slider_Value := NEW_pSlider_Value
    GuiControl,% This.GUI_NAME ":" ,% This.Control_ID , % This.Slider_Value
    if(This.Pair_With_Edit>=1)
    {
      if(This.Pair_With_Edit<=2)
      GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID , % This.Slider_Value 
      if(This.Pair_With_Edit>=2)
      GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID_Hex , % Format("{1:02X}",This.Slider_Value)
    }
  }
}

; CheckOHB - Determine the position of the OHB
CheckOHB()
{
  Global YesOHBFound
  If GamePID
  {
    if (ok:=FindText(GameX + Round((GameW / 2)-(OHBStrW/2)), GameY + Round(GameH / (1080 / 50)), GameX + Round((GameW / 2)+(OHBStrW/2)), GameY + Round(GameH / (1080 / 430)) , 0, 0, HealthBarStr,0))
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
CheckDialogue()
{
  If GamePID
  {
    if (ok:=FindText(GameX + Round((GameW / 2)-100), GameY + Round(GameH / (1080 / 1)), GameX + Round((GameW / 2)+100), GameY + Round(GameH / (1080 / 10)) , 0, 0, "|<NPC Dialogue>0x3B454E@0.97$61.0M4UGdaEQ0zzw1zRIC6zs1RvoECDkk7yDywE7zbzy",0))
      Return True
    Else
      Return False
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
; Rescale - Rescales values of the script to the user's resolution
Rescale(){
  Global GameX, GameY, GameW, GameH, FillMetamorph, Base, Globe, InvGrid, WR
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
    If (FileExist(A_ScriptDir "\save\FillMetamorph.json") && VersionNumber != "")
    {
      WR_Menu("JSON","Load","FillMetamorph")
      FillMetamorphImported := True
    }
    Else If (VersionNumber = "")
      FillMetamorphImported := True
    Else
      FillMetamorphImported := False
    
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
      ; Fill Metamorph
      If (!FillMetamorphImported) 
      {
        Global FillMetamorph := {"X1": GameX + Round(GameW/(1920/329)) ; (1920/2)-631
                    , "Y1": GameY + Round(GameH/(1080/189))
                    , "X2": GameX + Round(GameW/(1920/745)) ; (1920/2)-215
                    , "Y2": GameY + Round(GameH/(1080/746))}
      }
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
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(1920/380))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/820))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1920/1542))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1920/1658))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;Currency
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1920/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1920/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1920/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))
      ;Scouring
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1920/175))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/445))
      ;Chisel
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1920/605))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/190))
      ;Alchemy
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1920/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/260))
      ;Transmutation
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1920/60))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/260))
      ;Alteration
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1920/120))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/260))
      ;Augmentation
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/310))
      ;Vaal
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/445))
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
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1920 / 618))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1920 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1920 / 466))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;Status Check OnMetamporph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / (1920 / 785))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1080 / 204))
      ;Status Check OnLocker
      WR.loc.pixel.OnLocker.X:=GameX + Round(GameW / (1920 / 458))
      WR.loc.pixel.OnLocker.Y:=GameY + Round(GameH / ( 1080 / 918))
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
      ; Fill Metamorph
      If !FillMetamorphImported
        Global FillMetamorph := {"X1": GameX + Round(GameW/(1440/89)) ; (1440/2)-631
                , "Y1": GameY + Round(GameH/(1080/189))
                , "X2": GameX + Round(GameW/(1440/505)) ; (1440/2)-215
                , "Y2": GameY + Round(GameH/(1080/746))}
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
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/820))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1440/1062))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1440/1178))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
              ;Currency
        ;Scouring 175,476
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1440/175))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/445))
        ;Chisel 605,220
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1440/605))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/190))
        ;Alchemy 490,290
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1440/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/260))
        ;Transmutation 60,290
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1440/60))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/260))
        ;Alteration 120,290
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1440/120))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/260))
        ;Augmentation 230,340
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1440/230))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/310))
        ;Vaal 230,475
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1440/230))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/445))
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1920/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1920/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1920/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))
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
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1440 / 378))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1440 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1440 / 226))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;Status Check OnMetamorph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / (1440 / 545))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1080 / 204))
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
      ; Fill Metamorph
      If !FillMetamorphImported
        Global FillMetamorph := {"X1": GameX + Round(GameW/(2560/649)) ; (2560/2)-631
                , "Y1": GameY + Round(GameH/(1080/189))
                , "X2": GameX + Round(GameW/(2560/1065)) ; (2560/2)-215
                , "Y2": GameY + Round(GameH/(1080/746))}
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
      ;380,820
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(2560/380))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/820))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(2560/2185))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(2560/2298))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;Currency
        ;Scouring 175,476
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(2560/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(2560/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(2560/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(2560/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))

      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(2560/175))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/445))
        ;Chisel 605,220
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(2560/605))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/190))
        ;Alchemy 490,290
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(2560/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/260))
        ;Transmutation 60,290
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(2560/60))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/260))
        ;Alteration 120,290
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(2560/120))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/260))
        ;Augmentation 230,340
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(2560/230))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/310))
        ;Vaal 230,475
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(2560/230))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/445))
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
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (2560 / 618))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (2560 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (2560 / 786))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;Status Check OnMetamorph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / (2560 / 1105))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1080 / 204))
      ;Status Check OnLocker
      WR.loc.pixel.OnLocker.X:=GameX + Round(GameW / (2560 / 490))
      WR.loc.pixel.OnLocker.Y:=GameY + Round(GameH / ( 1080 / 918))

      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (2560 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1080 / 1027))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1080 / 736))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1080 / 605))
    }
    Else If (ResolutionScale="Cinematic(43:18)") {
      ;Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(3440/2579)), Round(GameW/(3440/2649)), Round(GameW/(3440/2719)), Round(GameW/(3440/2789)), Round(GameW/(3440/2860)), Round(GameW/(3440/2930)), Round(GameW/(3440/3000)), Round(GameW/(3440/3070)), Round(GameW/(3440/3140)), Round(GameW/(3440/3211)), Round(GameW/(3440/3281)), Round(GameW/(3440/3351)) ]
      Global InventoryGridY := [ Round(GameH/(1440/851)), Round(GameH/(1440/921)), Round(GameH/(1440/992)), Round(GameH/(1440/1062)), Round(GameH/(1440/1132)) ]
      ; Fill Metamorph
      If !FillMetamorphImported
        Global FillMetamorph := {"X1": GameX + Round(GameW/(2560/649)) ; (2560/2)-631
                , "Y1": GameY + Round(GameH/(1080/189))
                , "X2": GameX + Round(GameW/(2560/1065)) ; (2560/2)-215
                , "Y2": GameY + Round(GameH/(1080/746))}
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
      WR.loc.pixel.VendorAccept.X:=GameX + Round(GameW/(3440/945))
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1440/1090))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(3440/2934))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(3440/3090))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1440/1202))
      ;Currency
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1920/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1920/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1920/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))

      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(3440/235))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1440/590))
        ;Chisel 810,290
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(3440/810))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1440/250))
        ;Alchemy 655,390
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(3440/655))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1440/350))
        ;Transmutation 80,390
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(3440/80))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1440/350))
        ;Alteration 155, 390
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(3440/155))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1440/350))
        ;Augmentation 310,465
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(3440/310))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1440/425))
        ;Vaal 310, 631
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(3440/310))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1440/590))

      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(3440/164))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(3440/228))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1440/299))
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
      WR.loc.pixel.OnVendor.X:=GameX + Round(GameW / (3440 / 1264))
      WR.loc.pixel.OnVendor.Y:=GameY + Round(GameH / ( 1440 / 146))
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (3440 / 822))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1440 / 181))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (3440 / 365))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1440 / 90))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (3440 / 1056))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1440 / 118))
      ;Status Check OnMetamporph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / ( 3440 / 1480))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1440 / 270))
      ;Status Check OnLocker ((3440/3)-2)
      WR.loc.pixel.OnLocker.X:=GameX + Round(GameW / (3440 / 600))
      WR.loc.pixel.OnLocker.Y:=GameY + Round(GameH / ( 1440 / 918))
      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (3440 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1440 / 1370))
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1440 / 983))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1440 / 805))
    }
    Else If (ResolutionScale="UltraWide") {
      ; Item Inventory Grid
      Global InventoryGridX := [ Round(GameW/(3840/3193)), Round(GameW/(3840/3246)), Round(GameW/(3840/3299)), Round(GameW/(3840/3352)), Round(GameW/(3840/3404)), Round(GameW/(3840/3457)), Round(GameW/(3840/3510)), Round(GameW/(3840/3562)), Round(GameW/(3840/3615)), Round(GameW/(3840/3668)), Round(GameW/(3840/3720)), Round(GameW/(3840/3773)) ]
      Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]  
      ; Fill Metamorph
      If !FillMetamorphImported
        Global FillMetamorph := {"X1": GameX + Round(GameW/(3840/1289)) ; (3840/2)-631
                , "Y1": GameY + Round(GameH/(1080/189))
                , "X2": GameX + Round(GameW/(3840/1705)) ; (3840/2)-215
                , "Y2": GameY + Round(GameH/(1080/746))}
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
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1080/820))
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(3840/3462))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(3840/3578))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1080/901))
      ;Currency
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(3840/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(3840/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(3840/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(3840/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))

      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(3840/175))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1080/445))
        ;Chisel 605,220
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(3840/605))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1080/190))
        ;Alchemy 490,290
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(3840/490))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1080/260))
        ;Transmutation 60,290
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(3840/60))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1080/260))
        ;Alteration 120,290
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(3840/120))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1080/260))
        ;Augmentation 230,340
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(3840/230))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1080/310))
        ;Vaal 230,475
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(3840/230))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1080/445))
      ;Scrolls in currency tab
      WR.loc.pixel.Wisdom.X:=GameX + Round(GameW/(3840/125))
      WR.loc.pixel.Portal.X:=GameX + Round(GameW/(3840/175))
      WR.loc.pixel.Wisdom.Y:=WR.loc.pixel.Portal.Y:=GameY + Round(GameH/(1080/190))
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
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (3840 / 1578))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1080 / 135))
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (3840 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1080 / 57))
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (3840 / 1426))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1080 / 89))
      ;Status Check OnMetamorph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / (3840 / 1745))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1080 / 204))
      ;Status Check OnLocker ((3840/3)-2)
      WR.loc.pixel.OnLocker.X:=GameX + Round(GameW / (3840 / 1415))
      WR.loc.pixel.OnLocker.Y:=GameY + Round(GameH / ( 1080 / 918)) 
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

      ; Fill Metamorph
      If (!FillMetamorphImported)
      {
        Global FillMetamorph := {"X1": GameX + Round(GameW/(1680/227)) ; (1680/2)-631
                    , "Y1": GameY + Round(GameH/(1050/188))
                    , "X2": GameX + Round(GameW/(1680/632)) ; (1680/2)-215
                    , "Y2": GameY + Round(GameH/(1050/725))}
      }

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
      WR.loc.pixel.VendorAccept.Y:=GameY + Round(GameH/(1050/800))
      
      ;Detonate Mines
      WR.loc.pixel.DetonateDelve.X:=GameX + Round(GameW/(1680/1310))
      WR.loc.pixel.Detonate.X:=GameX + Round(GameW/(1680/1425))
      WR.loc.pixel.Detonate.Y:=GameY + Round(GameH/(1050/880))
      
      ;Currency
      ;Chance
      WR.loc.pixel.Chance.X:=GameX + Round(GameW/(1920/230))
      WR.loc.pixel.Chance.Y:=GameY + Round(GameH/(1080/260))
      ;Fusing
      WR.loc.pixel.Fusing.X:=GameX + Round(GameW/(1920/170))
      WR.loc.pixel.Fusing.Y:=GameY + Round(GameH/(1080/380))
      ;Jeweller
      WR.loc.pixel.Jeweller.X:=GameX + Round(GameW/(1920/120))
      WR.loc.pixel.Jeweller.Y:=GameY + Round(GameH/(1080/380))
      ;Chromatic
      WR.loc.pixel.Chromatic.X:=GameX + Round(GameW/(1920/234))
      WR.loc.pixel.Chromatic.Y:=GameY + Round(GameH/(1080/380))

      ;Scouring 175,460
      WR.loc.pixel.Scouring.X:=GameX + Round(GameW/(1680/175))
      WR.loc.pixel.Scouring.Y:=GameY + Round(GameH/(1050/430))      
      
      ;Chisel 590,210
      WR.loc.pixel.Chisel.X:=GameX + Round(GameW/(1680/590))
      WR.loc.pixel.Chisel.Y:=GameY + Round(GameH/(1050/180))
      
      ;Alchemy 475,280
      WR.loc.pixel.Alchemy.X:=GameX + Round(GameW/(1680/475))
      WR.loc.pixel.Alchemy.Y:=GameY + Round(GameH/(1050/250))
      
      ;Transmutation 55,280
      WR.loc.pixel.Transmutation.X:=GameX + Round(GameW/(1680/55))
      WR.loc.pixel.Transmutation.Y:=GameY + Round(GameH/(1050/250))
      
      ;Alteration 115,285
      WR.loc.pixel.Alteration.X:=GameX + Round(GameW/(1680/115))
      WR.loc.pixel.Alteration.Y:=GameY + Round(GameH/(1050/255))
      
      ;Augmentation 225,335
      WR.loc.pixel.Augmentation.X:=GameX + Round(GameW/(1680/225))
      WR.loc.pixel.Augmentation.Y:=GameY + Round(GameH/(1050/305))
      
      ;Vaal 225,460
      WR.loc.pixel.Vaal.X:=GameX + Round(GameW/(1680/225))
      WR.loc.pixel.Vaal.Y:=GameY + Round(GameH/(1050/430))
      
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
      
      ;Status Check OnDiv
      WR.loc.pixel.OnDiv.X:=GameX + Round(GameW / (1680 / 519))
      WR.loc.pixel.OnDiv.Y:=GameY + Round(GameH / ( 1050 / 716))
      
      ;Status Check OnLeft
      WR.loc.pixel.OnLeft.X:=GameX + Round(GameW / (1680 / 252))
      WR.loc.pixel.OnLeft.Y:=GameY + Round(GameH / ( 1050 / 57))
      
      ;Status Check OnDelveChart
      WR.loc.pixel.OnDelveChart.X:=GameX + Round(GameW / (1680 / 362))
      WR.loc.pixel.OnDelveChart.Y:=GameY + Round(GameH / ( 1050 / 84))
      
      ;Status Check OnMetamporph
      WR.loc.pixel.OnMetamorph.X:=GameX + Round(GameW / (1680 / 850))
      WR.loc.pixel.OnMetamorph.Y:=GameY + Round(GameH / ( 1050 / 195))
      
      ;Status Check OnLocker ((1680/3)-2)
      WR.loc.pixel.OnLocker.X:=GameX + Round(GameW / (1680 / 450))
      WR.loc.pixel.OnLocker.Y:=GameY + Round(GameH / ( 1050 / 918))

      ;GUI overlay
      WR.loc.pixel.Gui.X:=GameX + Round(GameW / (1680 / -10))
      WR.loc.pixel.Gui.Y:=GameY + Round(GameH / (1050 / 1000))
      
      ;Divination Y locations
      WR.loc.pixel.DivTrade.Y:=GameY + Round(GameH / (1050 / 716))
      WR.loc.pixel.DivItem.Y:=GameY + Round(GameH / (1050 / 605))
    }
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
PromptForObject(){
  Global
  Gui, ArrayPrint: New
  Gui, ArrayPrint: Add, Edit, xm+20 ym+20 w200 h23 vSubmitObjectName
  Gui, ArrayPrint: Add, Button, wp hp gPrintObj, Submit
  Gui, ArrayPrint: Show
  Return

  PrintObj:
    Gui, Submit, NoHide
    Gui, ArrayPrint: Destroy
    If IsObject(SubmitObjectName) 
      Array_Gui(%SubmitObjectName%)
    Else
    MsgBox % %SubmitObjectName%
  Return
}
; Compare two hex colors as their R G B elements, puts all the below together
CompareHex(color1, color2, vary:=1, BGR:=0)
{
  If BGR
  {
    c1 := ToRGBfromBGR(color1)
    c2 := ToRGBfromBGR(color2)
  }
  Else
  {
    c1 := ToRGB(color1)
    c2 := ToRGB(color2)
  }
  Return CompareRGB(c1,c2,vary)
}
; Convert a color to a pixel findtext string
Hex2FindText(Color,vary:=0,BGR:=0,Comment:="",Width:=2,Height:=2,LR_Border:=0)
{
  If (Width < 1)
    Width := 1
  If (Height < 1)
    Height := 1
  bitstr := ""
  Loop % LR_Border
    bitstr .= "0"
  Loop % Width
    bitstr .= "1"
  Loop % LR_Border
    bitstr .= "0"
  endstr := bitstr
  Loop % Height - 1
  endstr .= "`n" . bitstr
  bitstr := bit2base64(endstr)
  ; Width += 2*LR_Border
  If IsObject(Color)
  {
    build := ""
    For k, v in Color
    {
      If BGR
        v := hexBGRToRGB(v)
      build .= "|<" k ">" . v . "@" . Round((100-vary)/100,2) . "$" . Width + 2 * LR_Border . "." . bitstr
    }
    Return build
  }
  Else
  {
    If BGR
      Color := hexBGRToRGB(Color)
    Return "|<" Comment ">" . Color . "@" . Round((100-vary)/100,2) . "$" . Width + 2 * LR_Border . "." . bitstr
  }
}
; Converts a hex BGR color into its R G B elements
ToRGBfromBGR(color) {
  return { "b": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "r": color & 0xFF }
}
; Converts a hex RGB color into its R G B elements
ToRGB(color) {
  return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
}
; Converts R G B elements back to hex
ToHex(Color) {
  If IsObject(Color)
  {
    C := (Color.r & 0xFF) << 16, C |= (Color.g & 0xFF) << 8, C |= (Color.b & 0xFF)
    Return Format("0x{1:06X}",C)
  }
  Else
    Return Format("0x{1:02X}",Color)
}
; Converts a hex BGR color into RGB format or vice versa
hexBGRToRGB(color) {
    b := Format("{1:02X}",(color >> 16) & 0xFF)
    g := Format("{1:02X}",(color >> 8) & 0xFF)
    r := Format("{1:02X}",color & 0xFF)
  return "0x" . r . g . b
}
; Compares two converted HEX codes as R G B within the variance range (use ToRGB to convert first)
CompareRGB(c1, c2, vary:=1) {
  rdiff := Abs( c1.r - c2.r )
  gdiff := Abs( c1.g - c2.g )
  bdiff := Abs( c1.b - c2.b )
  return rdiff <= vary && gdiff <= vary && bdiff <= vary
}
; Check if a specific hex value is part of an array within a variance and return the index
indexOfHex(var, Arr, fromIndex:=1, vary:=2) {
  for index, value in Arr {
    h1 := ToRGB(value) 
    h2 := ToRGB(var) 
    if (index < fromIndex){
      Continue
    }else if (CompareRGB(h1, h2, vary)){
      return index
    }
  }
}
; Check if a specific value is part of an array and return the index
indexOf(var, Arr, fromIndex:=1) {
  for index, value in Arr {
    if (index < fromIndex){
      Continue
    }else if (value = var){
      return index
    }
  }
}
; Check if a specific value is part of an array's array and return the parent index
indexOfArr(var, Arr, fromIndex:=1) 
{
  for index, a in Arr 
  {
    if (index < fromIndex)
      Continue
    for k, value in a
      if (value = var)
        return index
  }
  Return False
}
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
HasVal(haystack, needle) {
  for index, value in haystack
  {
    if (value = needle)
      return true
  }
  return false
}
; Transform an array to a comma separated string
arrToStr(array){
  Str := ""
  For Index, Value In array
    Str .= "," . Value
  Str := LTrim(Str, ",")
  return Str
}
; Transform an array to a comma separated string
hexArrToStr(array){
  Str := ""
  For Index, Value In array
    {
    value := Format("0x{1:06X}", value)
    Str .= "," . Value
    }
  Str := LTrim(Str, ",")
  return Str
}
; Function to Replace Nth instance of Needle in Haystack
StringReplaceN( Haystack, Needle, Replacement="", Instance=1 ) 
{ 
  If !( Instance := 0 | Instance )
  {
    StringReplace, Haystack, Haystack, %Needle%, %Replacement%, A
    Return Haystack
  }
  Else Instance := "L" Instance
  StringReplace, Instance, Instance, L-, R
  StringGetPos, Instance, Haystack, %Needle%, %Instance%
  If ( ErrorLevel )
    Return Haystack
  StringTrimLeft, Needle, HayStack, Instance+ StrLen( Needle )
  StringLeft, HayStack, HayStack, Instance
  Return HayStack Replacement Needle
} 
; Clamp Value function
Clamp( Val, Min, Max) {
  If Val < Min
    Val := Min
  If Val > Max
    Val := Max
  Return
}
; ClampGameScreen - Ensure points do not go outside Game Window
ClampGameScreen(ByRef ValX, ByRef ValY) 
{
  Global GameWindow
  If (ValY < GameWindow.BBarY)
    ValY := GameWindow.BBarY
  If (ValX < GameWindow.X)
    ValX := GameWindow.X
  If (ValY > GameWindow.Y + GameWindow.H)
    ValT := GameWindow.Y + GameWindow.H
  If (ValX > GameWindow.X + GameWindow.W)
    ValX := GameWindow.X + GameWindow.W
  Return
}
; GroupByFourty - Mathematic function to sort quality into groups of 40
GroupByFourty(ArrList) {
  GroupList := {}
  tQ := 0
  ; Get total of Value before
  For k, v in ArrList
    allQ += v.Q 
  ; Begin adding values to GroupList
  Loop, 20
    GroupTotal%ind% := 0
  Gosub, Group_Add
  Gosub, Group_Swap
  Gosub, Group_Move
  Gosub, Group_Cleanup
  Gosub, Group_Cleanup
  Gosub, Group_Add
  Gosub, Group_Swap
  Gosub, Group_Cleanup
  ; Gosub, Group_Move
  ; Gosub, Group_Cleanup
  ; Gosub, Group_Add
  ; Gosub, Group_Move
  ; Gosub, Group_Cleanup
  ; Gosub, RebaseTotals

  ; Final tallies
  For k, v in ArrList
    remainQ += v.Q 
  If !remainQ
    remainQ:=0
  tQ=
  For k, v in GroupList
    For kk, vv in v
      tQ += vv.Q 
  If !tQ
    tQ:= 0
  overQ := mod(tQ, 40)
  If !overQ
    overQ:= 0
  ; Catch for high quality gems in low quantities
  If (tQ = 0 && remainQ >= 40 && remainQ <= 57)
  {
    Loop, 20
    {
      ind := A_Index
      For k, v in ArrList
      {
        If (GroupTotal%ind% >= 40)
          Continue
        If (GroupTotal%ind% + v.Q <= 57)
        {
          If !IsObject(GroupList[ind])
            GroupList[ind]:={}
          GroupList[ind].Push(ArrList.Delete(k))
          GroupTotal%ind% += v.Q
        }
      }
    }
    remainQ=
    For k, v in ArrList
      remainQ += v.Q 
    If !remainQ
      remainQ:=0
    tQ=
    For k, v in GroupList
      For kk, vv in v
        tQ += vv.Q 
    If !tQ
      tQ:= 0
    overQ := mod(tQ, 40)
    If !overQ
      overQ:= 0
  }
  expectC := Round((tQ - overQ) / 40)
  ; Display Tooltips
  Notify("Vendor Result"
  , "Total Quality:`t" allQ "`%`n"
  . "Orb Value:`t" expectC " orbs`n"
  . "Vend Quality:`t" tQ "`%`n"
  . "Extra Vend Q:`t" overQ "`%`n"
  . "UnVend Q:`t" remainQ "`%", 10)
  Return GroupList

  RebaseTotals:
    tt=
    tt2=
    For k, v in GroupList
    {
      tt .= GroupTotal%k% . "`r"
      GroupTotal%k% := 0
      For kk, vv in v
      {
        GroupTotal%k% += vv.Q
      }
    }
    For k, v in GroupList
      tt2 .= GroupTotal%k% . "`r"
    If (tt != tt2)
      MsgBox,% "Mismatch Found!`r`rFirst Values`r" . tt . "`r`rSecond Values`r" . tt2
  Return

  Group_Batch:
    Gosub, Group_Trim
    Gosub, Group_Trade
    Gosub, Group_Add
    Gosub, Group_Swap
  Return

  Group_Cleanup:
    ; Remove groups that didnt make it to 40
    Loop, 3
    For k, v in GroupList
    {
      If (GroupTotal%k% < 40)
      {
        For kk, vv in v
        {
          ArrList.Push(v.Delete(kk))
          GroupTotal%k% -= vv.Q
        }
      }
    }
  Return

  Group_Swap:
    ; Swap values Between groups to move closer to 40
    For k, v in GroupList
    {
      If (GroupTotal%k% <= 40)
        Continue
      For kk, vv in v
      {
        If (GroupTotal%k% <= 40)
          Continue
        For kg, vg in GroupList
        {
          If (k = kg)
            Continue
          For kkg, vvg in vg
          {
            newk := GroupTotal%k% - vv.Q + vvg.Q
            newkg := GroupTotal%kg% + vv.Q - vvg.Q
            If (GroupTotal%kg% >= 40 && newkg < 40)
              Continue
            If (newk >= 40 && newk < GroupTotal%k%)
            {
              GroupList[kg].Push(GroupList[k].Delete(kk))
              GroupList[k].Push(GroupList[kg].Delete(kkg))
              GroupTotal%k% := newk, GroupTotal%kg% := newkg
              Break 2
            }
          }
        }
      }
    }
  Return

  Group_Trade:
    ; Swap values from group to arrList to move closer to 40
    For k, v in GroupList
    {
      If (GroupTotal%k% <= 40)
        Continue
      For kk, vv in v
      {
        If (GroupTotal%k% <= 40)
          Continue
        For kg, vg in ArrList
        {
          newk := GroupTotal%k% - vv.Q + vvg.Q
          If (newk >= 40 && newk < GroupTotal%k%)
          {
            ArrList.Push(GroupList[k].Delete(kk))
            GroupList[k].Push(ArrList.Delete(kg))
            GroupTotal%k% := newk
            Break
          }
        }
      }
    }
  Return

  Group_Move:
    ; Move values from incomplete groups to add as close to 40
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 40)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Cleanup
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 41)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 42)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 43)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 44)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 45)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 46)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 47)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 48)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 49)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 50)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 51)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 52)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 53)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 54)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 55)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
  Return

  Group_Add:
    ; Find any values to add to incomplete groups
    Loop, 20
    {
      ind := A_Index
      For k, v in ArrList
      {
        If (GroupTotal%ind% >= 40)
          Continue
        If (GroupTotal%ind% + v.Q <= 40)
        {
          If !IsObject(GroupList[ind])
            GroupList[ind]:={}
          GroupList[ind].Push(ArrList.Delete(k))
          GroupTotal%ind% += v.Q
        }
      }
    }
  Return

  Group_Trim:
    ; Trim excess values if group above 40
    Loop 20
    {
      ind := A_Index
      If GroupTotal%ind% > 40
      {
        For k, v in GroupList[ind]
        {
          If (GroupTotal%ind% - v.Q >= 40)
          {
            ArrList.Push(GroupList[ind].Delete(k))
            GroupTotal%ind% -= v.Q
          }
        }
      }
    }
  Return
}
; Captures the current Location and determines if in Town, Hideout or Azurite Mines
CompareLocation(cStr:="")
{
  Static Lang := ""
  ;                                                     English / Thai                French                 German                  Russian                     Spanish                   Portuguese               Chinese             Korean
  Static ClientTowns :=  { "Lioneye's Watch" :    [ "Lioneye's Watch"       , "Le Guet d'Œil de Lion"  , "Löwenauges Wacht"    , "Застава Львиного глаза", "La Vigilancia de Lioneye", "Vigília de Lioneye"      , "獅眼守望"       , "라이온아이 초소에" ]
                      , "The Forest Encampment" : [ "The Forest Encampment" ,"Le Campement de la forêt", "Das Waldlager"       , "Лесной лагерь"         , "El Campamento Forestal"  , "Acampamento da Floresta" , "森林營地"       , "숲 야영지에" ]
                      , "The Sarn Encampment" :   [ "The Sarn Encampment"   , "Le Campement de Sarn"   , "Das Lager von Sarn"  , "Лагерь Сарна"          , "El Campamento de Sarn"   , "Acampamento de Sarn"     , "薩恩營地"       , "사안 야영지에" ]
                      , "Highgate" :              [ "Highgate"              , "Hautevoie"              , "Hohenpforte"         , "Македы"                , "Atalaya"                                             , "統治者之殿"     , "하이게이트에" ]
                      , "Overseer's Tower" :      [ "Overseer's Tower"      , "La Tour du Superviseur","Der Turm des Aufsehers", "Башня надзирателя"     , "La Torre del Capataz"    , "Torre do Capataz"        , "堅守高塔"       , "감시탑에" ]
                      , "The Bridge Encampment" : [ "The Bridge Encampment" , "Le Campement du pont"   , "Das Brückenlager"    , "Лагерь на мосту"       , "El Campamento del Puente", "Acampamento da Ponte"    , "橋墩營地"       , "다리 야영지에" ]
                      , "Oriath Docks" :          [ "Oriath Docks"          , "Les Docks d'Oriath"     , "Die Docks von Oriath", "Доки Ориата"           , "Las Dársenas de Oriath"  , "Docas de Oriath"         , "奧瑞亞港口"     , "오리아스 부두에" ]
                      , "Oriath" :                [ "Oriath"                                                                   , "Ориат"                                                                         , "奧瑞亞"         , "오리아스에" ]
                      , "Karui Shores" :          [ "Karui Shores" ]
                      , "The Rogue Harbour" :     [ "The Rogue Harbour","ท่าเรือโจร","Le Port des Malfaiteurs", "Der Hafen der Abtrünnigen", "Разбойничья гавань", "El Puerto de los renegados","O Porto dos Renegados","도둑 항구에"] }
  Static LangString :=  { "English" : ": You have entered"  , "Spanish" : " : Has entrado a "   , "Chinese" : " : 你已進入："   , "Korean" : "진입했습니다"   , "German" : " : Ihr habt '"
              , "Russian" : " : Вы вошли в область "  , "French" : " : Vous êtes à présent dans : "   , "Portuguese" : " : Você entrou em: "  , "Thai" : " : คุณเข้าสู่ " }
  Static MineStrings := ["Azurite Mine"]
  If (cStr="Town")
    Return indexOfArr(CurrentLocation,ClientTowns)
  If (Lang = "")
  {
    For k, v in LangString
    {
      If InStr(cStr, v)
      {
        Lang := k
        If (VersionNumber > 0)
        Log("Client.txt language has been detected as: " Lang)
        Break
      }
    }
  }
  If (Lang = "English") ; This is the default setting
  {
    ; first we confirm if this line contains our zone change phrase
    If InStr(cStr, ": You have entered")
    {
      ; We split away the rest of the sentence for only location
      CurrentLocation := StrSplit(cStr, " : You have entered "," .`r`n" )[2]
      ; We should now have our location name and can begin comparing
      ; This compares the captured string to a list of town names
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      ; Now we check if it's a hideout, make sure to whitelist Syndicate
      If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
        OnHideout := True
      Else
        OnHideout := False
      ; Now we check if we match mines
      If indexOf(CurrentLocation,MineStrings)
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Spanish") 
  {
    If InStr(cStr, " : Has entrado a ")
    {
      CurrentLocation := StrSplit(cStr, " : Has entrado a "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Guarida") && !InStr(CurrentLocation, "Sindicato"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Mina de Azurita")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Chinese") 
  {
    If InStr(cStr, " : 你已進入：")
    {
      CurrentLocation := StrSplit(cStr, " : 你已進入："," .。`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "藏身處") && !InStr(CurrentLocation, "永生密教"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "碧藍礦坑")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Korean") 
  {
    If InStr(cStr, "진입했습니다")
    {
      CurrentLocation := StrSplit(StrSplit(cStr,"] : ")[2], "진입했습니다"," .`r`n")[1]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "은신처에") && !InStr(CurrentLocation, "신디케이트"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "남동석 광산에")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "German") 
  {
    If InStr(cStr, " : Ihr habt '")
    {
      CurrentLocation := StrSplit(StrSplit(cStr," : Ihr habt '")[2], "' betreten"," .`r`n")[1]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Versteckter") && !InStr(CurrentLocation, "Syndikat"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Azuritmine")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Russian") 
  {
    If InStr(cStr, " : Вы вошли в область ")
    {
      CurrentLocation := StrSplit(cStr," : Вы вошли в область "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "убежище") && !InStr(CurrentLocation, "синдикат"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Азуритовая шахта")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "French") 
  {
    If InStr(cStr, " : Vous êtes à présent dans : ")
    {
      CurrentLocation := StrSplit(cStr," : Vous êtes à présent dans : "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Repaire") && !InStr(CurrentLocation, "Syndicat"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "La Mine d'Azurite")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Portuguese") 
  {
    If InStr(cStr, " : Você entrou em: ")
    {
      CurrentLocation := StrSplit(cStr," : Você entrou em: "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Refúgio") && !InStr(CurrentLocation, "Sindicato"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Mina de Azurita")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Thai") 
  {
    If InStr(cStr, " : คุณเข้าสู่ ")
    {
      CurrentLocation := StrSplit(cStr," : คุณเข้าสู่ "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Azurite Mine")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Return False
}
; Monitor for changes in log since initialized
Monitor_GameLogs(Initialize:=0) 
{
  global ClientLog, CLogFO, CurrentLocation
  OldTown := OnTown, OldHideout := OnHideout, OldMines := OnMines, OldLocation := CurrentLocation
  if (Initialize)
  {
    Try
    {
      CLogFO := FileOpen(ClientLog, "r")
      FileGetSize, errchk, %ClientLog%, M
      If (errchk >= 64)
      {
        CurrentLocation := "Log too large"
        CLogFO.Seek(0, 2)
        If (VersionNumber != "")
        {
          Log("Client.txt Log File is too large (" . errchk . "MB)")
          Notify("Client.txt file is too large (" . errchk . "MB)`nDelete contents of the log file and reload`nYou Must change zones to update Location","",0,,110)
        }
        Return
      }
      T1 := A_TickCount
      If (VersionNumber != "")
        Ding(0,-10,"Parsing Client.txt Logfile")
      latestFileContent := CLogFo.Read()
      latestFileContent := TF_ReverseLines(latestFileContent)
      Loop, Parse,% latestFileContent,`n,`r
      {
        If InStr(A_LoopField, "] :")
          If CompareLocation(A_LoopField)
            Break
        If (A_Index > 1000)
        {
          CurrentLocation := "1k Line Break"
          Log("1k Line Break reached, ensure the file is encoded with UTF-8-BOM")
          Break
        }
      }
      If (CurrentLocation = "")
        CurrentLocation := "Nothing Found"
      If (VersionNumber != "")
        Ding(500,-10,"Parsed Client.txt logs in " . A_TickCount - T1 . "MS`nSize: " . errchk . "MB")
      StatusText := (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere")))
      SB_SetText("Status:" StatusText " `(" CurrentLocation "`)",2)
      If (DebugMessages && YesLocation && WinActive(GameStr))
      {
        Ding(6000,4,"Status:   `t" (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere"))))
        Ding(6000,5,CurrentLocation)
      }
      If (VersionNumber != "")
        Log("Log File initialized","OnTown " OnTown, "OnHideout " OnHideout, "OnMines " OnMines, "Located:" CurrentLocation)
    }
    Catch, loaderror
    {
      Ding(5000,-10,"Client.txt Critical Load Error`nSize: " . errchk . "MB")
      CurrentLocation := "Client File Load Error"
      Log("Error loading File, Submit information about your client.txt",loaderror)
    }
    Return
  } Else {
    latestFileContent := CLogFo.Read()

    if (latestFileContent) 
    {
      Loop, Parse,% latestFileContent,`n,`r 
      {
        If InStr(A_LoopField, "] :")
          CompareLocation(A_LoopField)
      }
    }
    If (DebugMessages && YesLocation && GameActive)
    {
      Ding(2000,4,"Status:   `t" (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere"))))
      Ding(2000,5,CurrentLocation)
    }
    If (CurrentLocation != OldLocation || OldTown != OnTown || OldMines != OnMines || OldHideout != OnHideout)
    {
      StatusText := (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere")))
      If YesLocation
        Log("Zone Change Detected", StatusText , "Located:" CurrentLocation)
      SB_SetText("Status:" StatusText " (" CurrentLocation ")",2)
    }
    Return
  }
}
; Tail Function for files
LastLine(SomeFileObject) {
  static SEEK_CUR := 1
  static SEEK_END := 2
  loop {
    SomeFileObject.Seek(-1, SEEK_CUR)
    
    if (SomeFileObject.Read(1) = "`n") {
      StartPosition := SomeFileObject.Tell()
      
      Line := SomeFileObject.ReadLine()
      SomeFileObject.Seek(StartPosition - 1)
      return Line
    }
    else {
      SomeFileObject.Seek(-1, SEEK_CUR)
    }
  } until (A_Index >= 1000000)
  Return ; this should never happen
}
; CoolTime - Return a more accurate MS value
CoolTime() {
  VarSetCapacity(PerformanceCount, 8, 0)
  VarSetCapacity(PerformanceFreq, 8, 0)
  DllCall("QueryPerformanceCounter", "Ptr", &PerformanceCount)
  DllCall("QueryPerformanceFrequency", "Ptr", &PerformanceFreq)
  return NumGet(PerformanceCount, 0, "Int64") / NumGet(PerformanceFreq, 0, "Int64")
}
; DaysSince - Check how many days has it been since the last update
DaysSince()
{
  Global Date_now, LastDatabaseParseDate, UpdateDatabaseInterval
  FormatTime, Date_now, A_Now, yyyyMMdd
  If Date_now = LastDatabaseParseDate ;
    Return False
  daysCount := Date_now
  daysCount -= LastDatabaseParseDate, days
  If daysCount=
  {
    ;the value is too large of a dif to calculate, this means we should update
    Return True
  }
  Else If (daysCount >= UpdateDatabaseInterval)
  {
    ;The Count between the two dates is at/above the threshold, this means we should update
    Return daysCount
  }
  Else
  {
    ;The Count between the two dates is below the threshold, this means we should not
    Return False
  }
}
; Provides a call for simpler random sleep timers
RandomSleep(min,max){
    Random, r, min, max
    r:=floor(r/Speed)
    Sleep, r*Latency
  return
}
; Reset Chat
ResetChat(){
  Send {Enter}{Up}{Escape}
  return
}
; Grab Reply whisper recipient
GrabRecipientName(){
  Clipboard := ""
  Send ^{Enter}^{A}^{C}{Escape}
  ClipWait, 0
  Loop, Parse, Clipboard, `n, `r
    {
    ; Clipboard must have "@" in the first line
    If A_Index = 1
      {
      IfNotInString, A_LoopField, @
        {
        Exit
        }
      RecipientNameArr := StrSplit(A_LoopField, " ", @)
      RecipientName1 := RecipientNameArr[1]
      RecipientName := StrReplace(RecipientName1, "@")
      }
      Ding(, 1,%RecipientName%)
    }
  Sleep, 60
  Return
}
; ScrapeNinjaData - Parse raw data from PoE-Ninja API and standardize Chaos Value || Chaos Equivalent
ScrapeNinjaData(apiString)
{
  If(RegExMatch(selectedLeague, "SSF",RxMatch))
  {
    selectedLeagueSC := RegExReplace(selectedLeague, "SSF ", "")
  }
  Else
  {
    selectedLeagueSC :=selectedLeague
  }

  If InStr(apiString, "Fragment")
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    If ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid or an API change
    }
    Else If (ErrorLevel=0){
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      { ; This will extract the information and standardize the chaos value to one variable.
        grabName := (indexArr["currencyTypeName"] ? indexArr["currencyTypeName"] : False)
        grabChaosVal := (indexArr["chaosEquivalent"] ? indexArr["chaosEquivalent"] : False)
        grabPayVal := (indexArr["pay"] ? indexArr["pay"] : False)
        grabRecVal := (indexArr["receive"] ? indexArr["receive"] : False)
        grabPaySparklineVal := (indexArr["paySparkLine"] ? indexArr["paySparkLine"] : False)
        grabRecSparklineVal := (indexArr["receiveSparkLine"] ? indexArr["receiveSparkLine"] : False)
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"pay":grabPayVal
          ,"receive":grabRecVal
          ,"paySparkLine":grabPaySparklineVal
          ,"receiveSparkLine":grabRecSparklineVal}
      }
      Ninja[apiString] := holder.lines
      FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
    }
    Return
  }
  Else If InStr(apiString, "Currency")
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    if ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid
    }
    Else if (ErrorLevel=0){
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      {
        grabName := (indexArr["currencyTypeName"] ? indexArr["currencyTypeName"] : False)
        grabChaosVal := (indexArr["chaosEquivalent"] ? indexArr["chaosEquivalent"] : False)
        grabPayVal := (indexArr["pay"] ? indexArr["pay"] : False)
        grabRecVal := (indexArr["receive"] ? indexArr["receive"] : False)
        grabPaySparklineVal := (indexArr["paySparkLine"] ? indexArr["paySparkLine"] : False)
        grabRecSparklineVal := (indexArr["receiveSparkLine"] ? indexArr["receiveSparkLine"] : False)
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"pay":grabPayVal
          ,"receive":grabRecVal
          ,"paySparkLine":grabPaySparklineVal
          ,"receiveSparkLine":grabRecSparklineVal}
      }
      Ninja[apiString] := holder.lines
      for index, indexArr in holder.currencyDetails
      {
        grabName := (indexArr["name"] ? indexArr["name"] : False)
        grabPoeTrdId := (indexArr["poeTradeId"] ? indexArr["poeTradeId"] : False)
        grabId := (indexArr["id"] ? indexArr["id"] : False)
        grabTradeId := (indexArr["tradeId"] ? indexArr["tradeId"] : False)
        holder.currencyDetails[index] := {"currencyName":grabName
          ,"poeTradeId":grabPoeTrdId
          ,"id":grabId
          ,"tradeId":grabTradeId}
      }
      Ninja["currencyDetails"] := holder.currencyDetails
      FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
    }
    Return
  }
  Else
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    if ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid
    }
    Else if (ErrorLevel=0){
      RetryDL := False
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      {
        grabSparklineVal := (indexArr["sparkline"] ? indexArr["sparkline"] : False)
        grabExaltVal := (indexArr["exaltedValue"] ? indexArr["exaltedValue"] : False)
        grabChaosVal := (indexArr["chaosValue"] ? indexArr["chaosValue"] : False)
        grabName := (indexArr["name"] ? indexArr["name"] : False)
        grabLinks := (indexArr["links"] ? indexArr["links"] : False)
        grabVariant := (indexArr["variant"] ? indexArr["variant"] : False)
        grabMapTier := (indexArr["mapTier"] ? indexArr["mapTier"] : False)
        grabLevelRequired := (indexArr["levelRequired"] ? indexArr["levelRequired"] : False)
        grabGemLevel := (indexArr["gemLevel"] ? indexArr["gemLevel"] : False)
        grabGemQuality := (indexArr["gemQuality"] ? indexArr["gemQuality"] : False)
        grabBaseType := (indexArr["baseType"] ? indexArr["baseType"] : False)
        
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"sparkline":grabSparklineVal}

        If grabExaltVal
          holder.lines[index]["exaltedValue"] := grabExaltVal
        If grabVariant
          holder.lines[index]["variant"] := grabVariant
        If grabLinks
          holder.lines[index]["links"] := grabLinks
        If grabMapTier
          holder.lines[index]["mapTier"] := grabMapTier
        If grabLevelRequired
          holder.lines[index]["levelRequired"] := grabLevelRequired
        If grabGemLevel
          holder.lines[index]["gemLevel"] := grabGemLevel
        If grabGemQuality
          holder.lines[index]["gemQuality"] := grabGemQuality
        If (grabBaseType && apiString = "UniqueMap")
          holder.lines[index]["baseType"] := grabBaseType
      }
      Ninja[apiString] := holder.lines
    }
    FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
  }
    ;MsgBox % "Download worked for Ninja Database  -  There are " Ninja.Count() " Entries in the array
  Return
}
; GetProcessTimes - Show CPU usage as precentage
GetProcessTimes(PID)  
{
  static aPIDs := []
  ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage 
  if aPIDs.HasKey(PID) && A_TickCount - aPIDs[PID, "tickPrior"] < 250
    return aPIDs[PID, "usagePrior"] 

  DllCall("GetSystemTimes", "Int64*", lpIdleTimeSystem, "Int64*", lpKernelTimeSystem, "Int64*", lpUserTimeSystem)
  if !hProc := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "Ptr", pid)
    return -2, aPIDs.HasKey(PID) ? aPIDs.Remove(PID, "") : "" ; Process doesn't exist anymore or don't have access to it.
  DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", lpCreationTime, "Int64*", lpExitTime, "Int64*", lpKernelTimeProcess, "Int64*", lpUserTimeProcess)
  DllCall("CloseHandle", "Ptr", hProc)
  
  if aPIDs.HasKey(PID) ; check if previously run
  {
    ; find the total system run time delta between the two calls
    systemKernelDelta := lpKernelTimeSystem - aPIDs[PID, "lpKernelTimeSystem"] ;lpKernelTimeSystemOld
    systemUserDelta := lpUserTimeSystem - aPIDs[PID, "lpUserTimeSystem"] ; lpUserTimeSystemOld
    ; get the total process run time delta between the two calls 
    procKernalDelta := lpKernelTimeProcess - aPIDs[PID, "lpKernelTimeProcess"] ; lpKernelTimeProcessOld
    procUserDelta := lpUserTimeProcess - aPIDs[PID, "lpUserTimeProcess"] ;lpUserTimeProcessOld
    ; sum the kernal + user time
    totalSystem :=  systemKernelDelta + systemUserDelta
    totalProcess := procKernalDelta + procUserDelta
    ; The result is simply the process delta run time as a percent of system delta run time
    result := 100 * totalProcess / totalSystem
  }
  else result := -1

  aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
  aPIDs[PID, "lpUserTimeSystem"] := lpUserTimeSystem
  aPIDs[PID, "lpKernelTimeProcess"] := lpKernelTimeProcess
  aPIDs[PID, "lpUserTimeProcess"] := lpUserTimeProcess
  aPIDs[PID, "tickPrior"] := A_TickCount
  return aPIDs[PID, "usagePrior"] := result 
}
; Hotkeys - Open main menu
hotkeys(){
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
IsModifier(Character) {
  static Modifiers := {"!": 1, "#": 1, "~": 1, "^": 1, "*": 1, "+": 1}
  return Modifiers.HasKey(Character)
}
SplitModsFromKey(key){
  Mods := String := ""
  for k, Letter in StrSplit(key) {
    if (IsModifier(Letter)) {
      Mods .= Letter
    }
    else {
      String .= Letter
    }
  }
  Return {"Mods":Mods, "Key":String }
}
SendHotkey(keyStr:="",hold:=0){
  For i, keys in StrSplit(keyStr," "){
    If RegExMatch(keys, "O)\[(\d+)\]\(([\d\w]+)\)", DelayKey)
    {
      DelayAction.Push({"TriggerAt":A_TickCount+DelayKey[1],"Key":DelayKey[2]})
      Continue
    }
    Obj := SplitModsFromKey(keys)
    If (GameActive := WinActive(GameStr))
      Send, % Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}"
    Else
      controlsend, , % Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}", %GameStr%
  }
}
SendDelayAction(){
  For k, keys in DelayAction
  {
    If (keys.TriggerAt <= A_TickCount)
    {
      SendHotkey(keys.Key)
      DelayAction.Delete(k)
    }
  }
}
mainmenuGameLogicState(refresh:=False){
  Static OldOnChar:=-1, OldOHB:=-1, OldOnChat:=-1, OldOnInventory:=-1, OldOnDiv:=-1, OldOnStash:=-1, OldOnMenu:=-1
  , OldOnVendor:=-1, OldOnDelveChart:=-1, OldOnLeft:=-1, OldOnMetamorph:=-1, OldOnDetonate:=-1, OldOnLocker:=-1
  Local NewOHB
  If (OnChar != OldOnChar) || refresh
  {
    OldOnChar := OnChar
    If OnChar
      CtlColors.Change(MainMenuIDOnChar, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnChar, "Red", "")
  }
  If ((NewOHB := (CheckOHB()?1:0)) != OldOHB) || refresh
  {
    OldOHB := NewOHB
    If NewOHB
      CtlColors.Change(MainMenuIDOnOHB, "52D165", "")
    Else
      CtlColors.Change(MainMenuIDOnOHB, "Red", "")
  }
  If (OnInventory != OldOnInventory) || refresh
  {
    OldOnInventory := OnInventory
    If (OnInventory)
      CtlColors.Change(MainMenuIDOnInventory, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnInventory, "", "Green")
  }
  If (OnChat != OldOnChat) || refresh
  {
    OldOnChat := OnChat
    If OnChat
      CtlColors.Change(MainMenuIDOnChat, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnChat, "", "Green")
  }
  If (OnStash != OldOnStash) || refresh
  {
    OldOnStash := OnStash
    If (OnStash)
      CtlColors.Change(MainMenuIDOnStash, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnStash, "", "Green")
  }
  If (OnDiv != OldOnDiv) || refresh
  {
    OldOnDiv := OnDiv
    If (OnDiv)
      CtlColors.Change(MainMenuIDOnDiv, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDiv, "", "Green")
  }
  If (OnLeft != OldOnLeft) || refresh
  {
    OldOnLeft := OnLeft
    If (OnLeft)
      CtlColors.Change(MainMenuIDOnLeft, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnLeft, "", "Green")
  }
  If (OnDelveChart != OldOnDelveChart) || refresh
  {
    OldOnDelveChart := OnDelveChart
    If (OnDelveChart)
      CtlColors.Change(MainMenuIDOnDelveChart, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDelveChart, "", "Green")
  }
  If (OnVendor != OldOnVendor) || refresh
  {
    OldOnVendor := OnVendor
    If (OnVendor)
      CtlColors.Change(MainMenuIDOnVendor, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnVendor, "", "Green")
  }
  If (OnDetonate != OldOnDetonate) || refresh
  {
    OldOnDetonate := OnDetonate
    If (OnDetonate)
      CtlColors.Change(MainMenuIDOnDetonate, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnDetonate, "", "Green")
  }
  If (OnMenu != OldOnMenu) || refresh
  {
    OldOnMenu := OnMenu
    If (OnMenu)
      CtlColors.Change(MainMenuIDOnMenu, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnMenu, "", "Green")
  }
  If (OnMetamorph != OldOnMetamorph) || refresh
  {
    OldOnMetamorph := OnMetamorph
    If (OnMetamorph)
      CtlColors.Change(MainMenuIDOnMetamorph, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnMetamorph, "", "Green")
  }
  If (OnLocker != OldOnLocker) || refresh
  {
    OldOnLocker := OnLocker
    If (OnLocker)
      CtlColors.Change(MainMenuIDOnLocker, "Red", "")
    Else
      CtlColors.Change(MainMenuIDOnLocker, "", "Green")
  }
  Return

  CheckPixelGrid:
    ;Check if inventory is open
    Gui, States: Hide
    if(!OnInventory){
      TT := "Grid information cannot be read because inventory is not open.`r`nYou might need to calibrate the onInventory state."
    }else{
      TT := "Grid information:" . "`n"
      ScreenShot()
      For C, GridX in InventoryGridX  
      {
        For R, GridY in InventoryGridY
        {
          PointColor := ScreenShot_GetColor(GridX,GridY)
          if (indexOf(PointColor, varEmptyInvSlotColor)) {        
            TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Empty inventory slot. Color: " . PointColor  .  "`n"
          }else{
            TT := TT . "  Column:  " . c . "  Row:  " . r . "  X: " . GridX . "  Y: " . GridY . "  Possibly occupied slot. Color: " . PointColor  .  "`n"
          }
        }
      }
    }
    MsgBox %TT%  
    Gui, States: Show
  Return
}
; GuiUpdate - Update Overlay ON OFF states
GuiUpdate(){
  GuiControl, 2:, overlayT1,% "Quit: " (WR.func.Toggle.Quit?"ON":"OFF")
  GuiControl, 2:, overlayT2,% "Flask: " (WR.func.Toggle.Flask?"ON":"OFF")
  GuiControl, 2:, overlayT3,% "Move: " (WR.func.Toggle.Move?"ON":"OFF")
  GuiControl, 2:, overlayT4,% "Util: " (WR.func.Toggle.Utility?"ON":"OFF")
  ShowHideOverlay()
  CtlColors.Change(MainMenuIDAutoFlask, (WR.func.Toggle.Flask?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoQuit, (WR.func.Toggle.Quit?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoMove, (WR.func.Toggle.Move?"52D165":"E0E0E0"), "")
  CtlColors.Change(MainMenuIDAutoUtility, (WR.func.Toggle.Utility?"52D165":"E0E0E0"), "")
  Return
}
ShowHideOverlay(){
  Global overlayT1, overlayT2, overlayT3, overlayT4
  GuiControl,2: Show%YesInGameOverlay%, overlayT1
  GuiControl,2: Show%YesInGameOverlay%, overlayT2
  GuiControl,2: Show%YesInGameOverlay%, overlayT3
  GuiControl,2: Show%YesInGameOverlay%, overlayT4
  Return
}

; UpdateLeagues - Grab the League info from GGG API
UpdateLeagues:
  UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
  FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
  LeagueIndex := JSON.Load(JSONtext)
  textList= 
  For K, V in LeagueIndex
    textList .= (!textList ? "" : "|") LeagueIndex[K]["id"]
  GuiControl, , selectedLeague, %textList%
  GuiControl, ChooseString, selectedLeague, %selectedLeague%
Return
; Zoom script found on AHK forum and modified to enclose in one function - Bandit
DrawZoom( Switch := "", M_C := 0 , R_C := 0, zoom_c := 0, dc := 0)
{
  Global
  Static zoom = 6        ; initial magnification, 1..32
  , halfside = 192      ; circa halfside of the magnifier
  , part := halfside/zoom
  , L_edge := (A_ScreenWidth//2) - halfside - 18
  , R_edge := (A_ScreenWidth//2) + halfside + 18
  , Rz := Round(part)
  , R := Rz*zoom
  , LineMargin := 10
  , pos_old := 0
  , pos_new

  If (Switch = "Toggle")
  {
    Gosub, ToggleZoom
    Return
  }
  If (Switch = "Repaint")
  {
    Gosub, Repaint
    Return
  }
  If (Switch = "MoveAway")
  {
    Gosub, MoveAway
    Return
  }
  If (Switch = "ClearGDI")
  {
    Gosub, ClearGDI
    Return
  }

  
  ;specify the style, thickness and color of the cross lines
  h_pen := DllCall( "gdi32.dll\CreatePen", "int", 0, "int", 1, "uint", 0x0000FF)
  ;select the correct pen into DC
  DllCall( "gdi32.dll\SelectObject", "uint", dc, "uint", h_pen )     
  ;update the current position to specified point - 1st horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", M_C, "int", R_C, "uint", 0)
  ;draw a line from the current position up to, but not including, the specified point.
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C)
  ; 2nd horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", M_C, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C+zoom_c)
  ; 3rd horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", 2*R_C+zoom_c-M_C, "int", R_C)
  ; 4th horizontal
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", 2*R_C+zoom_c-M_C, "int", R_C+zoom_c)     
  ; 1st vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C, "int", M_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", R_C)
  ; 2nd vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", M_C, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C+zoom_c, "int", R_C)
  ; 3rd vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C, "int", 2*R_C+zoom_c-M_C)
  ; 4th vertical
  DllCall( "gdi32.dll\MoveToEx", "uint", dc, "int", R_C+zoom_c, "int", R_C+zoom_c, "uint", 0)
  DllCall( "gdi32.dll\LineTo", "uint", dc, "int", R_C+zoom_c, "int", 2*R_C+zoom_c-M_C)
  Return

  Repaint:
    MouseGetPos x, y
    xz := x-Rz
    yz := y-Rz

    DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,0, Int,2*R+zoom, Int,2*R+zoom
    , UInt,hdd_frame, UInt,xz, UInt,yz, Int,2*Rz+1, Int,2*Rz+1, UInt,0xCC0020) ; SRCCOPY
    
    DrawZoom( "", LineMargin, R, zoom, hdc_frame )
    ; Gosub, MoveAway
  Return

  MoveAway:
    ; keep the frame outside the magnifier and precalculate wanted position
    If (x < R_edge && x > L_edge) && (y < (2*R+zoom+18))
      pos_new := (2*R+zoom+8)
    Else
      pos_new := 0

    if ( pos_old <> pos_new )      ; only move if the real position of window needs to change
      WinMove Magnifier,, ,pos_new
    
    pos_old := pos_new   ; store value for next loop
  Return


  ClearGDI:
    DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
    DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
    ZoomInitialize := 0
  Return

  ToggleZoom:
    If ZoomInitialize
    {
      Gosub, ClearGDI
      SetTimer Repaint, Off   ; flow through
      Hotkey, WheelUp, ZoomAdjust, Off
      Hotkey, WheelDown, ZoomAdjust, Off
      Hotkey, Up, PushMouse, Off
      Hotkey, Down, PushMouse, Off
      Hotkey, Left, PushMouse, Off
      Hotkey, Right, PushMouse, Off
      Gui, Zoom: destroy
    }
    Else
    {
      ZoomInitialize := 1
      Gui Zoom:+AlwaysOnTop -Caption -Resize +ToolWindow +E0x80020
      Gui Zoom:Show, % "w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside " y0 NA", Magnifier
      WinGet MagnifierID, id,  Magnifier
      WinSet Transparent, 255, Magnifier ; makes the window invisible to magnification
      ; WinGet PrintSourceID, ID
      hdd_frame := DllCall("GetDC", UInt, GamePID)
      hdc_frame := DllCall("GetDC", UInt, MagnifierID)
      Hotkey, IfWinActive
      Hotkey, Up, PushMouse, On
      Hotkey, Down, PushMouse, On
      Hotkey, Left, PushMouse, On
      Hotkey, Right, PushMouse, On
      Hotkey, WheelUp, ZoomAdjust, On
      Hotkey, WheelDown, ZoomAdjust, On
      SetTimer Repaint, 50   ; flow through
    }
  Return

  ZoomAdjust:
    If (zoom < 31 && A_ThisHotKey = "WheelUp" )
      zoom *= 1.189207115     ; sqrt(sqrt(2))
    Else If (zoom >  1 && A_ThisHotKey = "WheelDown")
      zoom /= 1.189207115
    Else
      Return
    part := halfside/zoom       ;new calculation of the magnified image
    Rz := Round(part)
    R := Rz*zoom
    Gui Zoom:Show, % "w" 2*R+zoom+0 " h" 2*R+zoom+0 " x" A_ScreenWidth//2 - halfside  " y0 NA", Magnifier
    Gosub, MoveAway
  Return

  PushMouse:
    ;Mouse move one step with arrow keys
    If (A_ThisHotKey = "Up")
      MouseMove, 0, -1, 0, R
    If (A_ThisHotKey = "Down")
      MouseMove, 0, 1, 0, R
    If (A_ThisHotKey = "Left")
      MouseMove, -1, 0, 0, R
    If (A_ThisHotKey = "Right")
      MouseMove, 1, 0, 0, R
    Gosub, MoveAway
  Return
}
; Gather the pixel information of an area, then average the hex values
AverageAreaColor(AreaObj)
{
  Static
  X1:=AreaObj.X1
  Y1:=AreaObj.Y1
  X2:=AreaObj.X2
  Y2:=AreaObj.Y2
  W := X2 - X1 +1
  H := Y2 - Y1 +1
  M_Index := W * H
  Size := Round((W * H) / 300)
  ColorList := []
  ScreenShot()
  Load_BarControl(,,1)
  ColorCount:=R_Count:=G_Count:=B_Count:=LastDisplay_LB:=EscBreak:=0
  Loop, % W
  {
    W_Index := A_Index
    Cur_X := X1 + (A_Index - 1)
    Loop, % H
    {
      Cur_Y := Y1 + (A_Index - 1)
      Temp_Hex := ScreenShot_GetColor(Cur_X,Cur_Y)
      if !(indexOf(Temp_Hex, ColorList))
      {
        ColorCount++
        ColorList.Push(Temp_Hex)
      }
      If (A_TickCount - LastDisplay_LB > Size)
      {
        T_Index := (W_Index-1)*H + A_Index
        Percent := Round((T_Index / M_Index) * 100)
        uText := ColorCount " variations - Escape to cancel"
        Load_BarControl(Percent,uText)
        LastDisplay_LB := A_TickCount
      }
    } Until EscBreak := GetKeyState("Escape", "P")
    If EscBreak
    {
      Notify("Canceled area calculation","",3,,110)
      Load_BarControl(100,"Canceled",-1)
      Return
    }
  }
  For k, color in ColorList
  {
    Split := ToRGB(color)
    R_Count += Split.r
    G_Count += Split.g
    B_Count += Split.b
  }
  Split := {"r":Round(R_Count / ColorCount),"g":Round(G_Count / ColorCount),"b":Round(B_Count / ColorCount)}
  Load_BarControl(100,"Done.",-1)
  Return ToHex(Split)
}
; Fill the metamorph panel when it first appears
Metamorph_FillOrgans()
{
  Global FillMetamorph
  H_Cell := (FillMetamorph.Y2 - FillMetamorph.Y1) // 5
  W_Cell := (FillMetamorph.X2 - FillMetamorph.X1) // 6
  yMarker := FillMetamorph.Y1 + ((H_Cell // 3) * 2)
  xMarker := FillMetamorph.X1 + (W_Cell // 2)
  Loop, 5
  {
    yMarker += (A_Index!=1?H_Cell:0)
    CtrlClick(xMarker,yMarker)
  }
  MouseMove % GameW//2,% yMarker + H_Cell // 4
  Return
}
; check time
CheckTime(Type:="hours",Interval:=2,key:="temp",Time:="")
{
  Static Keys := {}
  ; Available time types are: years, months, days, hours, minutes, seconds
  If (!Keys[key] || Time != "")
  {
    Keys[key] := (Time = "" ? A_Now : Time)
  }
  TimeVal := Keys[key]
  EnvSub, TimeVal, %A_now%, %Type%
  If (TimeVal <= 0)
  {
    TimeVal := Abs(TimeVal)
    If (TimeVal >= Interval)
    {
      Keys[key] := A_Now
      Return TimeVal
    }
    Else
      Return False
  }
  Else
    Return False
}
; StackRelease
StackRelease()
{
  if (buff:=FindText(GameX, GameY, GameX + (GameW//(6/5)),GameY + (GameH//(1080/75)), 0, 0, WR.perChar.Setting.channelrepressIcon,0))
  {
    If FindText(buff.1.1 + WR.perChar.Setting.channelrepressOffsetX1,buff.1.2 + buff.1.4 + WR.perChar.Setting.channelrepressOffsetY1,buff.1.1 + buff.1.3 + WR.perChar.Setting.channelrepressOffsetX2,buff.1.2 + buff.1.4 + WR.perChar.Setting.channelrepressOffsetY2, 0, 0, WR.perChar.Setting.channelrepressStack,0)
    {
      If GetKeyState(WR.perChar.Setting.channelrepressKey,"P")
      {
        SendHotkey(WR.perChar.Setting.channelrepressKey,"up")
        Sleep, 10
        SendHotkey(WR.perChar.Setting.channelrepressKey,"down")
      }
    }
  }
}
; PoePrices server status - PPServerStatus
PPServerStatus()
{
  Global PPServerStatus
  RTT := Ping4("www.poeprices.info", Result)
  If (ErrorLevel){
    Log("PoePrice Error: " ErrorLevel)
    PPServerStatus := False
  } Else {
    PPServerStatus := True
  }
  Return PPServerStatus
}

String2ASCII(String:="",One:="#",Zero:="."){
  local
  s := StrSplit(String, ".")
  w := StrSplit(s.1, "$").2
  s := StrSplit(StrReplace(StrReplace(base64tobit(s.2),"1",One),"0",Zero))
  v := ""
  For k, c in s
  {
    v .= c
    If !Mod(k,w)
      v .= "`n"
  }
  Return v
}

Class 7za {
  Static ExeFile := A_ScriptDir "\data\7za.exe"
  Static AddArgs := "a -w""" A_ScriptDir """ -t7z -x!backup\"
  Static SourceFile := ".\*"
  Static LogOutput := A_ScriptDir "\logs\Archive.log"
  Static Mtee := A_ScriptDir "\data\Mtee.exe"
  Static Source := A_ScriptDir "\data\source.zip"
  backup(){
    ToZip := A_ScriptDir "\backup\" A_Now ".7z"
    RunWait % comspec " /c "" """ This.ExeFile """ " This.AddArgs " """ ToZip """ """ This.SourceFile """ | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
  }
  restore(date){
    loc := A_ScriptDir "\backup\" date ".7z"
    If FileExist(loc){
      ExtArgs := "x """ loc """ -o""" A_ScriptDir """ -y"
      RunWait % comspec " /c "" """ This.ExeFile """ " ExtArgs " | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
    }
  }
  install(branch){
    Static Acc := "BanditTech"
    Static Proj := "WingmanReloaded"
    Link := "https://github.com/" Acc "/" Proj "/archive/refs/heads/" branch ".zip"
    This.backup()      
    UrlDownloadToFile,% Link,% This.Source
    ExtArgs := "x """ This.Source """ -o""" A_ScriptDir """ -y"
    subfolder := Proj "-" branch
    RunWait % comspec " /c "" """ This.ExeFile """ " ExtArgs " | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
    MoveArgs := "ROBOCOPY " subfolder " /S /IT """ A_ScriptDir """ /MOVE"
    RunWait % comspec " /c " MoveArgs,,hide
    RemoveArgs := "rmdir /s /q " subfolder
    RunWait % comspec " /c " RemoveArgs,,hide
  }
}

; Label Section
; TimerFlask - Flask CD Timers
TimerFlask1:
  OnCooldown[1]:=0
  settimer,TimerFlask1,delete
  return
TimerFlask2:
  OnCooldown[2]:=0
  settimer,TimerFlask2,delete
  return
TimerFlask3:
  OnCooldown[3]:=0
  settimer,TimerFlask3,delete
  return
TimerFlask4:
  OnCooldown[4]:=0
  settimer,TimerFlask4,delete
  return
TimerFlask5:
  OnCooldown[5]:=0
  settimer,TimerFlask5,delete
  return
; TimerUtility - Utility CD Timers
TimerUtility1:
  OnCooldownUtility1 := 0
  settimer,TimerUtility1,delete
  Return
TimerUtility2:
  OnCooldownUtility2 := 0
  settimer,TimerUtility2,delete
  Return
TimerUtility3:
  OnCooldownUtility3 := 0
  settimer,TimerUtility3,delete
  Return
TimerUtility4:
  OnCooldownUtility4 := 0
  settimer,TimerUtility4,delete
  Return
TimerUtility5:
  OnCooldownUtility5 := 0
  settimer,TimerUtility5,delete
  Return
TimerUtility6:
  OnCooldownUtility6 := 0
  settimer,TimerUtility6,delete
  Return
TimerUtility7:
  OnCooldownUtility7 := 0
  settimer,TimerUtility7,delete
  Return
TimerUtility8:
  OnCooldownUtility8 := 0
  settimer,TimerUtility8,delete
  Return
TimerUtility9:
  OnCooldownUtility9 := 0
  settimer,TimerUtility9,delete
  Return
TimerUtility10:
  OnCooldownUtility10 := 0
  settimer,TimerUtility10,delete
  Return
; TDetonated - Detonate CD Timer
TDetonated:
  Detonated:=0
  ;settimer,TDetonated,delete
  return
; Tray Labels
WINSPY:
  SplitPath, A_AhkPath, , AHKDIR
  Run, %AHKDIR%\WindowSpy.ahk
  Return
RELOAD:
  Reload
  Return
QuitNow:
  ExitApp
  Return
; Wingman GUI Labels
helpAutomation:
  Gui, submit
  MsgBox,% "Automation can start from two ways:`n`n"
    . "* Search for the Stash, and begin sorting items`n`n"
    . "* Search for the Vendor, and begin selling items`n`n"
    . "If you Enable Second Automation, both routines will occur`n"
    . "Whatever was not selected will be performed second`n`n"
    . "The following results can be arranged using these settings:`n`n"
    . "1) Search for Stash > Auto Stash Routine > END`n`n"
    . "2) Search for Stash > Auto Stash Routine > Search for Vendor >`n"
    . "Auto Sell Routine > END`n`n"
    . "3) Search for Stash > Auto Stash Routine > Search for Vendor >`n"
    . "Auto Sell Routine > Auto Confirm Sell > END`n`n"
    . "4) Search for Vendor > Auto Vendor Routine > END`n`n"
    . "5) Search for Vendor > Auto Vendor Routine > Wait at Vendor UI 30s >`n"
    . "Search Stash > Auto Stash Routine > END`n`n"
    . "6) Search for Vendor > Auto Vendor Routine > Auto Confirm Sell >`n"
    . "Search for Stash > Auto Stash Routine > END"
  Hotkeys()
  Return
WarningAutomation:
  Gui, submit, nohide
  If YesEnableAutoSellConfirmation
  {
    Gui, submit
    MsgBox,1,% "WARNING!!!", % "Please Be Advised`n`n"
    . "Enabling this option will auto confirm vendoring items, only use this option if you have a well configured CLF to catch good items`n`n"
    . "We will not be responsible for anything lost using this option.`n`n"
    . "If you are unsure about this option, We strongly recomend doing more research before enabling.`n`n"
    . "Come to WingmanReloaded Discord to talk with us or look for more information.`n`n"
    . "You have been warned!!! This option can be dangerous if done incorrectly!!!`n"
    . "Press OK to accept"
    IfMsgBox, OK
    {
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
      Hotkeys()
    }
    Else IfMsgBox, Cancel
    {
      YesEnableAutoSellConfirmation := 0
      Hotkeys()
      GuiControl,Inventory:, YesEnableAutoSellConfirmation, 0
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
    }
    Else
    {
      YesEnableAutoSellConfirmation := 0
      Hotkeys()
      GuiControl,Inventory:, YesEnableAutoSellConfirmation, 0
      IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
    }
  }
  Else 
    IniWrite, %YesEnableAutoSellConfirmation%, %A_ScriptDir%\save\Settings.ini, Automation Settings, YesEnableAutoSellConfirmation
  Return
; Wingman Crafting Labels - By DanMarzola
CustomCrafting:
  Global CustomCraftingBase
  textList1 := ""
  For k, v in craftingBasesT1
    textList1 .= (!textList1 ? "" : ", ") v
  baseList := ""
  textList2 := ""
  For k, v in craftingBasesT2
    textList2 .= (!textList2 ? "" : ", ") v
  baseList := ""
  textList3 := ""
  For k, v in craftingBasesT3
    textList3 .= (!textList3 ? "" : ", ") v
  baseList := ""
  textList4 := ""
  For k, v in craftingBasesT4
    textList4 .= (!textList4 ? "" : ", ") v
  baseList := ""
  textList5 := ""
  For k, v in craftingBasesT5
    textList5 .= (!textList5 ? "" : ", ") v
  baseList := ""
  textList6 := ""
  For k, v in craftingBasesT6
    textList6 .= (!textList6 ? "" : ", ") v
  baseList := ""
  textList7 := ""
  For k, v in craftingBasesT7
    textList7 .= (!textList7 ? "" : ", ") v
  baseList := ""
  textList8 := ""
  For k, v in craftingBasesT8
    textList8 .= (!textList8 ? "" : ", ") v
  baseList := ""
  For k, v in Bases
  {
    If ( !IndexOf("talisman",v["tags"]) 
    && ( IndexOf("amulet",v["tags"]) 
      || IndexOf("ring",v["tags"]) 
      || IndexOf("belt",v["tags"]) 
      || IndexOf("armour",v["tags"]) 
      || IndexOf("weapon",v["tags"])
      || IndexOf("jewel",v["tags"])
      || IndexOf("abyss_jewel",v["tags"]) ) )
    {
      baseList .= v["name"]"|"
    }
  }
  Gui, CustomCrafting: New
  Gui, CustomCrafting: +AlwaysOnTop -MinimizeBox
  Gui, CustomCrafting: Add, Button, default gupdateEverything    x225 y180  w150 h23,   Save Configuration
  Gui, CustomCrafting: Add, ComboBox, Sort vCustomCraftingBase xm+5 ym+28 w500, %baseList%
  Gui, CustomCrafting: Add, Tab2, vInventoryGuiTabs x3 y3 w600 h300 -wrap , Atlas Tier 1|STR Tier 2|DEX Tier 3|INT Tier 4|Hybrid Tier 5|Jewel Tier 6|Abyss Jewel Tier 7|Jewellery Tier 8
  Gui, CustomCrafting: Tab, Atlas Tier 1
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier1 ReadOnly y+38 w500 r8 , %textList1%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT1 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT1 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT1 Base
  Gui, CustomCrafting: Tab, STR Tier 2
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier2 ReadOnly y+38 w500 r8 , %textList2%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT2 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT2 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT2 Base
  Gui, CustomCrafting: Tab, DEX Tier 3
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier3 ReadOnly y+38 w500 r8 , %textList3%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT3 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT3 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT3 Base
  Gui, CustomCrafting: Tab, INT Tier 4
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier4 ReadOnly y+38 w500 r8 , %textList4%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT4 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT4 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT4 Base
  Gui, CustomCrafting: Tab, Hybrid Tier 5
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier5 ReadOnly y+38 w500 r8 , %textList5%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT5 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT5 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT5 Base
  Gui, CustomCrafting: Tab, Jewel Tier 6
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier6 ReadOnly y+38 w500 r8 , %textList6%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT6 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT6 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT6 Base
  Gui, CustomCrafting: Tab, Abyss Jewel Tier 7
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier7 ReadOnly y+38 w500 r8 , %textList7%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT7 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT7 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT7 Base
  Gui, CustomCrafting: Tab, Jewellery Tier 8
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier8 ReadOnly y+38 w500 r8 , %textList8%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT8 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT8 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT8 Base
  Gui, CustomCrafting: Show, , Edit Crafting Tiers
  Return
AddCustomCraftingBase:
  Gui, Submit, nohide
  RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
  If (CustomCraftingBase = "" || IndexOf(CustomCraftingBase,craftingBasesT%RxMatch1%))
    Return
  craftingBasesT%RxMatch1%.Push(CustomCraftingBase)
  textList := ""
  For k, v in craftingBasesT%RxMatch1%
        textList .= (!textList ? "" : ", ") v
  GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
  Return
RemoveCustomCraftingBase:
  Gui, Submit, nohide
  RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
  If (CustomCraftingBase = "" || !IndexOf(CustomCraftingBase,craftingBasesT%RxMatch1%))
    Return
  For k, v in craftingBasesT%RxMatch1%
    If (v = CustomCraftingBase)
      craftingBasesT%RxMatch1%.Delete(k)
  textList := ""
  For k, v in craftingBasesT%RxMatch1%
        textList .= (!textList ? "" : ", ") v
  GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
  Gui, Show
  Return
ResetCustomCraftingBase:
  RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
  craftingBasesT%RxMatch1% := DefaultcraftingBasesT%RxMatch1%.Clone()
  textList := ""
  For k, v in craftingBasesT%RxMatch1%
        textList .= (!textList ? "" : ", ") v
  GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
  Return



; Requests GGG stash API, requires SessionID and Account Name
POE_RequestStash(FetchTab,tabs:=0) {
  FetchTab:=FetchTab-1
  encodingError := ""

  postData   := "league=" . UriEncode(selectedLeague)
  . "&realm=pc"
  . "&accountName=" AccountNameSTR
  . "&tabs=" . tabs
  . "&tabIndex=" FetchTab
  payLength  := StrLen(postData)
  url     := "https://www.pathofexile.com/character-window/get-stash-items"
  
  reqTimeout := 25
  options  := "RequestType: GET"
  ;options  .= "`n" "ReturnHeaders: skip"
  options  .= "`n" "ReturnHeaders: append"
  options  .= "`n" "TimeOut: " reqTimeout
  reqHeaders := []

  reqHeaders.push("connection: keep-alive")
  reqHeaders.push("cache-Control: max-age=0")
  reqHeaders.push("accept: */*")
  reqHeaders.push("cookie: "PoECookie)
  
  ; ShowToolTip("Getting price prediction... ")
  retCurl := true
  response := Curl_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
  
  responseObj := {}
  responseHeader := ""
  
  RegExMatch(response, "is)(.*?({.*}))?.*?'(.*?)'.*", responseMatch)
  response := responseMatch1
  responseHeader := responseMatch3

  Try {
    responseObj := JSON.Load(response)
  } Catch e {
    responseObj.failed := "ERROR: Parsing response failed, invalid JSON! "
  }
  If (not isObject(responseObj)) {    
    responseObj := {}
  }

  If (true) { ; Debug messages for the content response
    debugout := RegExReplace("""" A_ScriptDir "\data\" retCurl, "curl", "curl.exe""")
    FileDelete, %A_ScriptDir%\temp\Stash_request.txt
    FileAppend, %debugout%, %A_ScriptDir%\temp\Stash_request.txt
    FileDelete, %A_ScriptDir%\temp\DebugStashOutput.html
    FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugStashOutput.html
    FileDelete, %A_ScriptDir%\temp\DebugStashJSON.json
    FileAppend, % JSON.Dump(responseObj,,2), %A_ScriptDir%\temp\DebugStashJSON.json
  }

  Return responseObj
}
; Requests GGG account API, requires SessionID
POE_RequestAccount() {
  encodingError := ""

  postData   := ""
  payLength  := StrLen(postData)
  url     := "https://www.pathofexile.com/character-window/get-account-name"
  
  reqTimeout := 25
  options  := "RequestType: GET"
  ;options  .= "`n" "ReturnHeaders: skip"
  options  .= "`n" "ReturnHeaders: append"
  options  .= "`n" "TimeOut: " reqTimeout
  reqHeaders := []

  ; reqHeaders.push("Connection: keep-alive")
  reqHeaders.push("cache-control: max-age=0")
  reqHeaders.push("accept: */*")
  reqHeaders.push("accept-encoding: gzip, deflate, br")
  reqHeaders.push("cookie: "PoECookie)
  
  ; ShowToolTip("Getting price prediction... ")
  retCurl := true
  response := Curl_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
  

  responseObj := {}
  responseHeader := ""
  
  RegExMatch(response, "is)(.*?({.*}))?.*?'(.*?)'.*", responseMatch)
  response := responseMatch1
  responseHeader := responseMatch3

  Try {
    responseObj := JSON.Load(response)
  } Catch e {
    responseObj.failed := "ERROR: Parsing response failed, invalid JSON! "
  }
  If (not isObject(responseObj)) {    
    responseObj := {}
  }

  If (true) { ; Debug messages for the content response
    debugout := RegExReplace("""" A_ScriptDir "\data\" retCurl, "curl", "curl.exe""")
    FileDelete, %A_ScriptDir%\temp\account_request.txt
    FileAppend, %debugout%, %A_ScriptDir%\temp\account_request.txt
    FileDelete, %A_ScriptDir%\temp\DebugAccountOutput.html
    FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugAccountOutput.html
    FileDelete, %A_ScriptDir%\temp\DebugAccountJSON.json
    FileAppend, % JSON.Dump(responseObj,,2), %A_ScriptDir%\temp\DebugAccountJSON.json
  }

  Return responseObj
}

ColorPercent(percent){
	Local key
  Static ColorRange := ""
  Static ColorCount := ""
  If !IsObject(ColorRange)
		ColorRange := ColorRange("0xff0000","0x00ff00")
	If !ColorCount
		ColorCount := ColorRange.Length()
  percent := percent>100?100
    :percent<1?1
    :percent
	key := percent!=1 ? Round(ColorCount * ((Percent) / 100)) : 1
  Return ColorRange[key]
}

max(Max, n*) { ; return the greatest of all values
  For each, Value in n
    If (Value > Max)
      Max := Value
  Return Max
}

ErrorText(e) {
  msg := ""
  For k, type in ["what","file","line","message","extra"] {
    value := e[type]
    msg .= (msg ? "`n" : "") type " : " e[type]
  }
  return msg
}
