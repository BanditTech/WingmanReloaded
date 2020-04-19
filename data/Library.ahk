if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
{
  ft_Gui("Show")
  Return
}

/*** Wingman Functions
*  Contains all the assorted functions written for Wingman
*/
  ; PoE Click v1.0.1 : Developed by Bandit
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; SwiftClick - Left Click at Coord with no wait between up and down
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SwiftClick(x, y){
      MouseMove, x, y  
      Sleep, 30+(ClickLatency*15)
      Send {Click}
      Sleep, 30+(ClickLatency*15)
      return
    }
    ; LeftClick - Left Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    LeftClick(x, y, Old:=0){
      If Old
      Goto OldStyleLeft
      Else
      {
        BlockInput, MouseMove
        MouseMove, x, y
        Sleep, 60+(ClickLatency*15)
        Send {Click}
        Sleep, 60+(ClickLatency*15)
        BlockInput, MouseMoveOff
      }
      Return
      
      OldStyleLeft:
        MouseMove, x, y  
        Sleep, 30*Latency
        Send {Click, Down x, y }
        Sleep, 60*Latency
        Send {Click, Up x, y }
        Sleep, 30*Latency
      return
    }
    ; RightClick - Right Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RightClick(x, y, Old:=0){
      If Old
      Goto OldStyleRight
      Else
      {
        BlockInput, MouseMove
        MouseMove, x, y
        Sleep, 60+(ClickLatency*15)
        Send {Click, Right}
        Sleep, 60+(ClickLatency*15)
        BlockInput, MouseMoveOff
      }
      Return

      OldStyleRight:
        BlockInput, MouseMove
        MouseMove, x, y
        Sleep, 30*Latency
        Send {Click, Down x, y, Right}
        Sleep, 60*Latency
        Send {Click, Up x, y, Right}
        Sleep, 30*Latency
        BlockInput, MouseMoveOff
      return
    }
    ; ShiftClick - Shift Click +Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ShiftClick(x, y){
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CtrlClick(x, y){
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
    ; RandClick - Randomize Click area around middle of cell using Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RandClick(x, y){
      Random, Rx, x+10, x+30
      Random, Ry, y-30, y-10
      return {"X": Rx, "Y": Ry}
    }
    ; WisdomScroll - Identify Item at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    WisdomScroll(x, y){
      BlockInput, MouseMove
      RightClick(WisdomScrollX,WisdomScrollY)
      Sleep, 30+Abs(ClickLatency*15)
      LeftClick(x,y)
      Sleep, 15+Abs(ClickLatency*15)
      BlockInput, MouseMoveOff
      return
    }
    ; ItemScan - Parse data from Cliboard to Prop and Affix
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    class ItemScan
    {
      __New()
      {
        This.Data := {}
        This.Data.ClipContents := Clip_Contents ; Clipboard
        This.Data.Sections := StrSplit(This.Data.ClipContents, "`r`n--------`r`n")
        This.Data.Blocks := {}
        This.Pseudo := OrderedArray()
        This.Affix := OrderedArray()
        This.Prop := OrderedArray()
        ; This.Stats := {}
        ; Split our sections from the clipboard
        ; NamePlate, Affix, FlavorText, Enchant, Implicit, Influence, Corrupted
        For SectionKey, SVal in This.Data.Sections
        {
          If (SVal ~= ":")
          {
            If (SectionKey = 1 && SVal ~= "Rarity:")
              This.Data.Blocks.NamePlate := SVal, This.Prop.IsItem := true
            Else
              This.Data.Blocks.Properties .= SVal "`n"
          }
          Else 
          {
            If (SVal ~= "\.$" || SVal ~= "\?$" || SVal ~= """$")
              This.Data.Blocks.FlavorText := SVal
            Else If (SVal ~= "\(implicit\)$")
              This.Data.Blocks.Implicit := SVal
            Else If (SVal ~= "\(enchant\)$")
              This.Data.Blocks.Enchant := SVal
            Else If (SVal ~= " Item$") && !(SVal ~= "\w{1,} \w{1,} \w{1,} Item$")
              This.Data.Blocks.Influence := SVal
            Else If (SVal ~= "^Corrupted$")
              This.Prop.Corrupted := True
            Else
              This.Data.Blocks.Affix := SVal
          }
        }
        This.MatchAffixes(This.Data.Blocks.Affix)
        This.MatchAffixes(This.Data.Blocks.Enchant)
        This.MatchAffixes(This.Data.Blocks.Implicit)
        This.MatchAffixes(This.Data.Blocks.Influence)
        This.MatchProperties()
        This.MatchPseudoAffix()
        This.MatchExtenalDB()
        ; This.FuckingSugoiFreeMate()
      }
      MatchProperties(){
        ;Start NamePlate Parser
        If RegExMatch(This.Data.Blocks.NamePlate, "`am)Rarity: (.+)", RxMatch)
        {
          This.Prop.Rarity := RxMatch1
          ;Prop Rarity Comparator
          If (InStr(This.Prop.Rarity, "Currency"))
          {
            This.Prop.RarityCurrency := True
            This.Prop.DefaultSendStash := "CurrencyTab"
          }
          Else If (InStr(This.Prop.Rarity, "Divination Card"))
          {
            This.Prop.RarityDivination := True
            This.Prop.SpecialType := "Divination Card"
            This.Prop.DefaultSendStash := "DivinationTab"
          }
          Else If (InStr(This.Prop.Rarity, "Gem"))
          {
            This.Prop.RarityGem := True
            This.Prop.SpecialType := "Gem"
            This.Prop.DefaultSendStash := "GemTab"
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
            This.Prop.DefaultSendStash := "CollectionTab"
          }
          ; Fail Safe in case nothing match, to avoid auto-sell
          Else
          {
            This.Prop.SpecialType := This.Prop.Rarity
          }
          ; 3 Lines in NamePlate => Rarity / Item Name/ Item Base
          If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n(.+)`r`n(.+)",RxMatch))
          {
            This.Prop.ItemName := RxMatch1
            This.Prop.ItemBase := RxMatch2
          }
          ; 2 Lines in NamePlate => Rarity / Item Base
          Else If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n(.+)",RxMatch))
          {
            This.Prop.ItemName := RxMatch1
            This.Prop.ItemBase := RxMatch1
          }
          ;Start Parse
          If (InStr(This.Prop.ItemBase, "Map"))
          {
            This.Prop.IsMap := True
            This.Prop.ItemClass := "Maps"
            ; Deal with Blighted Map
            If (InStr(This.Prop.ItemBase, "Blighted"))
            {
              This.Prop.IsBlightedMap := True
              Prop.SpecialType := "Blighted Map"
            }
            Else
            {
              This.Prop.SpecialType := "Map"
              This.Prop.DefaultSendStash := "MapTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "Incubator"))
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
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Splinter of"))
          {
            This.Prop.BreachSplinter := True
            This.Prop.SpecialType := "Breach Splinter"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Breachstone"))
          {
            This.Prop.BreachSplinter := True
            This.Prop.SpecialType := "Breachstone"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Sacrifice at"))
          {
            This.Prop.SacrificeFragment := True
            This.Prop.SpecialType := "Sacrifice Fragment"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Mortal Grief") 
          || InStr(This.Prop.ItemBase, "Mortal Hope") 
          || InStr(This.Prop.ItemBase, "Mortal Ignorance")
          || InStr(This.Prop.ItemBase, "Mortal Rage"))
          {
            This.Prop.MortalFragment := True
            This.Prop.SpecialType := "Mortal Fragment"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Fragment of"))
          {
            This.Prop.GuardianFragment := True
            This.Prop.SpecialType := "Guardian Fragment"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Volkuur's Key") 
          || InStr(This.Prop.ItemBase, "Eber's Key")
          || InStr(This.Prop.ItemBase, "Yriel's Key")
          || InStr(This.Prop.ItemBase, "Inya's Key"))
          {
            This.Prop.ProphecyFragment := True
            This.Prop.SpecialType := "Prophecy Fragment"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Scarab"))
          {
            This.Prop.Scarab := True
            This.Prop.SpecialType := "Scarab"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Offering to the Goddess"))
          {
            This.Prop.Offering := True
            This.Prop.SpecialType := "Offering"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Essence of")
          || InStr(This.Prop.ItemBase, "Remnant of Corruption"))
          {
            This.Prop.Essence := True
            This.Prop.SpecialType := "Essence"
            This.Prop.DefaultSendStash := "EssenceTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Fossil")
          || InStr(This.Prop.ItemBase, "Resonator"))
          {
            This.Prop.Resonator := True
            This.Prop.SpecialType := "Resonator"
            This.Prop.DefaultSendStash := "ResonatorTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Divine Vessel"))
          {
            This.Prop.Vessel := True
            This.Prop.SpecialType := "Divine Vessel"
            This.Prop.DefaultSendStash := "FragmentsTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Eye Jewel"))
          {
            This.Prop.AbyssJewel := True
            This.Prop.Jewel := True
          }
          Else If (InStr(This.Prop.ItemBase, "Cobalt Jewel")
          || InStr(This.Prop.ItemBase, "Crimson Jewel")
          || InStr(This.Prop.ItemBase, "Viridian Jewel"))
          {
            This.Prop.Jewel := True
          }
          Else If (InStr(This.Prop.ItemBase, "Cluster Jewel"))
          {
            This.Prop.ClusterJewel := True
            This.Prop.SpecialType := "Cluster Jewel"
            This.Prop.DefaultSendStash := "ClusterJewelTab"
          }
          Else If (InStr(This.Prop.ItemBase, "Flask"))
          {
            This.Prop.Flask := True
            This.Prop.ItemClass := "Flasks"
            This.Prop.DefaultSendStash := "QualityFlaskTab"
            This.Prop.Item_Width := 1
            This.Prop.Item_Height := 2
          }
          Else If (InStr(This.Prop.ItemBase, "Quiver"))
          {
            This.Prop.Quiver := True
            This.Prop.ItemClass := "Quivers"
            This.Prop.Item_Width := 2
            This.Prop.Item_Height := 3
          }
          Else If (InStr(This.Prop.ItemBase, "Oil"))
          {
            If (This.Prop.RarityCurrency)
            {
            This.Prop.Oil := True
            This.Prop.SpecialType := "Oil"
            This.Prop.DefaultSendStash := "OilTab"
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
          Else If (InStr(This.Prop.ItemBase, "'s Lung"))
          {	     
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Lung"
              This.Prop.SpecialType := "Organ"
              This.Prop.DefaultSendStash := "OrganTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Heart"))
          {			        
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Heart"
              This.Prop.SpecialType := "Organ"
              This.Prop.DefaultSendStash := "OrganTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Brain"))
          {			        
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Brain"
              This.Prop.SpecialType := "Organ"
              This.Prop.DefaultSendStash := "OrganTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Liver"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Liver"
              This.Prop.SpecialType := "Organ"
              This.Prop.DefaultSendStash := "OrganTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, "'s Eye"))
          {
            If (This.Prop.RarityUnique)
            {
              This.Prop.IsOrgan := "Eye"
              This.Prop.SpecialType := "Organ"
              This.Prop.DefaultSendStash := "OrganTab"
            }
          }
          Else If (InStr(This.Prop.ItemBase, " Beast"))
          {
            ;Only Rare and Unique Beasts
            If (This.Prop.Rarity_Digit >= 3)
            {
              This.Prop.IsBeast := True
              This.Prop.SpecialType := "Beast"
              This.Prop.ItemClass := "Beasts"
            }
          }
        }
        ;End NamePlate Parser

        ;Start Extra Blocks Parser
          ;Parse Influence data block
        Loop, Parse,% This.Data.Blocks.Influence, `n, `r
        {
          ; Match for influence type
          If (RegExMatch(A_LoopField, "`am)(.+) Item",RxMatch))
          {
            This.Prop.Influence .= (This.Prop.Influence?" ":"") RxMatch1
          }
        }
        ; Get Prophecy using Flavor Txt
        If (RegExMatch(This.Data.Blocks.FlavorText, "Right-click to add this prophecy to your character",RxMatch))
        {
          This.Prop.Prophecy := True
          This.Prop.SpecialType := "Prophecy"
        }
        ;End Extra Blocks Parser

        ;Start Prop Block Parser for General Items
          ;Every Item has a Item Level
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Level: (.+)",RxMatch))
        {
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Level: (.+)",RxMatch))
          {
            This.Prop.ItemLevel := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Level: (.+)",RxMatch))
          {
            This.Prop.Required_Level := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Str: (.+)",RxMatch))
          {
            This.Prop.Required_Str := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Dex: (.+)",RxMatch))
          {
            This.Prop.Required_Dex := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Int: (.+)",RxMatch))
          {
            This.Prop.Required_Int := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Sockets: (.+)",RxMatch))
          {
            This.Prop.Sockets_Raw := RxMatch1
            This.Prop.Sockets_Num := StrLen(RegExReplace(This.Prop.Sockets_Raw, "[- ]+" , ""))
            This.Prop.Sockets_Link := 0
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
            If (This.Prop.Sockets_Link == 5)
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
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: "rxNum,RxMatch))
          {
            This.Prop.Quality := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Armour: "rxNum,RxMatch))
          {
            This.Prop.RatingArmour := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Energy Shield: "rxNum,RxMatch))
          {
            This.Prop.RatingEnergyShield := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Evasion: "rxNum,RxMatch))
          {
            This.Prop.RatingEvasion := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Chance to Block: "rxNum,RxMatch))
          {
            This.Prop.RatingBlock := RxMatch1
          }

          ;Weapon Specific Props
            ;Every Weapon has APS
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Attacks per Second: "rxNum,RxMatch))
          {
            This.Prop.IsWeapon := True
            This.Prop.Weapon_APS := RxMatch1
            If (RegExMatch(This.Data.Blocks.Properties, "`am)^Physical Damage: " rxNum "-" rxNum ,RxMatch))
            {
              This.Prop.Weapon_Avg_Physical_Dmg := Format("{1:0.3g}",(RxMatch1 + RxMatch2) / 2)
              This.Prop.Weapon_Max_Physical_Dmg := RxMatch2
              This.Prop.Weapon_Min_Physical_Dmg := RxMatch1
            }
            If (RegExMatch(This.Data.Blocks.Properties, "`am)^Elemental Damage: .+",RxMatch))
            {
              This.Prop.Weapon_Avg_Elemental_Dmg := 0
              This.Prop.Weapon_Max_Elemental_Dmg := 0
              This.Prop.Weapon_Min_Elemental_Dmg := 0
              For k, v in StrSplit(RxMatch,",")
              {
                values := This.MatchLine(v)
                This.Prop.Weapon_Avg_Elemental_Dmg := Format("{1:0.3g}",This.Prop.Weapon_Avg_Elemental_Dmg + values.avg)
                This.Prop.Weapon_Max_Elemental_Dmg += values.max
                This.Prop.Weapon_Min_Elemental_Dmg += values.min
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
          }
        }
        ;End Prop Block Parser for General Items

        ;Start Prop Block Parser for Maps
          ;Every map has a Map Tier!
        If (RegExMatch(This.Data.Blocks.Properties, "`am)^Map Tier: "rxNum,RxMatch))
        {
          This.Prop.MapTier := RxMatch1
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Atlas Region: "rxNum,RxMatch))
          {
            This.Prop.MapAtlasRegion := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Quantity: "rxNum,RxMatch))
          {
            This.Prop.MapQuantity := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Rarity: "rxNum,RxMatch))
          {
            This.Prop.MapRarity := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Monster Pack Size: "rxNum,RxMatch))
          {
            This.Prop.MapMPS := RxMatch1
          }
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: "rxNum,RxMatch))
          {
            This.Prop.MapQuality := RxMatch1
          }
        }
        ;End Prop Block Parser for Maps

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

        ;Start Prop Block Parser for Divinations
        If (This.RarityDivination)
        {
          If (RegExMatch(This.Data.Blocks.Properties, "`am)^Stack Size: "rxNum "\/"rxNum ,RxMatch))
          {
            This.Prop.Stack_Size := RegExReplace(RxMatch1,",","") + 0
            This.Prop.Stack_Max := RxMatch2
          }
        }
        ;End Prop Block Parser for Divinations
      }
      MatchAffixes(content:=""){
        ; Do Stuff with info
        Loop, Parse,% content, `n, `r
        {
          If (A_LoopField = "")
            Continue
          key := This.Standardize(A_LoopField)
          If (vals := This.MatchLine(A_LoopField))
          {
            If (vals.HasKey("avg"))
            {
              This.Affix[key "_Avg"] := vals.avg
              This.Affix[key "_Max"] := vals.max
              This.Affix[key "_Min"] := vals.min
            }
            Else
            {
              For k, v in vals
                This.Affix[ key (k = 1 ? "" : "_value" k) ] := v
            }
          }
          Else
            This.Affix[key] := True
        }
      }
      MatchLine(lineString){
        If (RegExMatch(lineString, "O)" rxNum " to " rxNum , RxMatch) || RegExMatch(lineString, "O)" rxNum "-" rxNum , RxMatch))
          Return {"min":RxMatch[1],"max":RxMatch[2],"avg":(Format("{1:0.3g}",(RxMatch[1] + RxMatch[2]) / 2))}
        Else If (RegExMatch(lineString, "O)" rxNum " .* " rxNum , RxMatch))
          Return [ RxMatch[1], RxMatch[2] ]
        Else If (RegExMatch(lineString, "O)" rxNum , RxMatch))
          Return [ RxMatch[1] ]
        Else
          Return False
      }
      Standardize(str:=""){
        Return RegExReplace(str, rxNum , "#")
      }
      MatchPseudoAffix(){
        for k, v in This.Affix
        {
          trimKey := RegExReplace(k," \(.*\)","")
          ; Singular Resistances
          If (trimKey = "# to Cold Resistance")
          {
            This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
          }
          Else If (trimKey = "# to Fire Resistance")
          {
            This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
          }
          Else If (trimKey = "# to Lightning Resistance")
          {
            This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
          }
          Else If (trimKey = "# to Chaos Resistance")
          {
            This.AddPseudoAffix("(Pseudo) Total to Chaos Resistance",k)
          }
          ; Double Resistances
          Else If (trimKey = "# to Cold and Lightning Resistances")
          {
            This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
            This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
          }
          Else If (trimKey = "# to Fire and Cold Resistances")
          {
            This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
            This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
          }
          Else If (trimKey = "# to Fire and Lightning Resistances")
          {
            This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
            This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
          }
          ; All Resistances
          Else If (trimKey = "# to all Elemental Resistances")
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
          Else If (trimKey = "# increased Armour")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
          }
          Else If (trimKey = "# increased Evasion Rating")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
          }
          Else If (trimKey = "# increased Energy Shield")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
          }
          ; Double Armour Affix
          Else If (trimKey = "# increased Evasion and Energy Shield")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
            This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
          }
          Else If (trimKey = "# increased Armour and Energy Shield")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
            This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k) 
          }
          Else If (trimKey = "# increased Armour and Evasion")
          {
            This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
            This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
          }
          ; Damage Mods
          Else If (trimKey = "Adds # to # Physical Damage to Attacks_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Physical Damage to Attacks_Avg",k)
          }
          Else If (trimKey = "Adds # to # Physical Damage to Spells_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Physical Damage to Spells_Avg",k)
          }
          Else If (trimKey = "Adds # to # Cold Damage to Attacks_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Cold Damage to Attacks_Avg",k)
          }
          Else If (trimKey = "Adds # to # Cold Damage to Spells_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Cold Damage to Spells_Avg",k)
          }
          Else If (trimKey = "Adds # to # Fire Damage to Attacks_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Fire Damage to Attacks_Avg",k)
          }
          Else If (trimKey = "Adds # to # Fire Damage to Spells_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Fire Damage to Spells_Avg",k)
          }
          Else If (trimKey = "Adds # to # Lightning Damage to Attacks_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Lightning Damage to Attacks_Avg",k)
          }
          Else If (trimKey = "Adds # to # Lightning Damage to Spells_Avg")
          {
            This.AddPseudoAffix("(Pseudo) Lightning Damage to Spells_Avg",k)
          }
          ; Spell Pseudo
          Else If (trimKey = "# increased Lightning Damage")
          {
            This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
          }
          Else If (trimKey = "# increased Cold Damage")
          {
            This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
          }
          Else If (trimKey = "# increased Fire Damage")
          {
            This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
          }
          Else If (trimKey = "# increased Spell Damage")
          {
            This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
            This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
            This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
            This.AddPseudoAffix("(Pseudo) Increased Chaos Damage",k)
          }
          Else If (trimKey = "# increased Elemental Damage")
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
        ; Total Stats
        This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Strength","Pseudo")
        This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Intelligence","Pseudo")
        This.AddPseudoAffix("(Pseudo) Total to Stats","(Pseudo) Total to Dexterity","Pseudo")
        ; Maximum Life, yeah unfortunally we need do this way =/
        aux:= This.GetValue("Affix","# to maximum Life") 
        + This.GetValue("Affix","# to maximum Life (crafted)") 
        + This.GetValue("Affix","# to maximum Life (implicit)") 
        + (This.GetValue("Pseudo","(Pseudo) Total to Strength"))//2
        If(aux > 0)
        {
          This.Pseudo["(Pseudo) Total Maximum Life"] :=aux
        }

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
        aux := This.GetValue("Pseudo", PseudoKey) + This.GetValue(StandardType, StandardKey)
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
      MatchExtenalDB()
      {
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
        For k, v in Bases	
        {	
          If ((v["name"] = This.Prop.ItemBase) || (v["name"] = StandardBase) || ( Prop.Rarity_Digit = 2 && v["name"] = PrefixMagicBase ) )	
          {
            This.Prop.Item_Width := v["inventory_width"]	
            This.Prop.Item_Height := v["inventory_height"]	
            This.Prop.ItemClass := v["item_class"]	
            This.Prop.ItemBase := v["name"]	
            This.Prop.DropLevel := v["drop_level"]	

            If InStr(This.Prop.ItemClass, "Ring")	
              This.Prop.Ring := True
            If InStr(This.Prop.ItemClass, "Amulet")	
              This.Prop.Amulet := True
            If InStr(This.Prop.ItemClass, "Belt")	
              This.Prop.Belt := True	
            Break	
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
        If (This.Prop.DefaultSendStash = "FragmentsTab" || This.Prop.ItemName ~= "Simulacrum")
        {
          If This.MatchNinjaDB("Fragment")
            Return
          If This.MatchNinjaDB("Scarab")
            Return
        }
        If (This.Prop.IsBeast)	
        {	
          If This.MatchNinjaDB("Beast")
            Return
        }
        If (This.Prop.RarityUnique)
        {
          If (This.Prop.ItemClass ~= "(Belt|Amulet|Ring)")
          {
            If This.MatchNinjaDB("UniqueAccessory")
              Return
          }
          Else If (This.Prop.ItemClass ~= "(Body Armour|Gloves|Boots|Helmet|Shield)")
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
          If This.MatchNinjaDB("Map","ItemBase","baseType")
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
              This.Data.Ninja := v
              This.Prop.SpecialType := "Valuable Base"
              Return
            }
          }	
        }
      }
      MatchNinjaDB(ApiStr,MatchKey:="ItemName",NinjaKey:="name")
      {
        For k, v in Ninja[ApiStr]
        {
          If (This.Prop[MatchKey] = v[NinjaKey])
          {
            If ((ApiStr = "Map" || ApiStr = "UniqueMap") 
            && This.Prop.MapTier < v["mapTier"])
              Continue
            This.Prop.ChaosValue := v["chaosValue"]
            If v["exaltedValue"]
              This.Prop.ExaltValue := v["exaltedValue"]
            If This.Prop.IsBeast
              Prop.ItemBase := This.Prop.ItemName
            This.Data.Ninja := v
            Return True
          }
        }
        Return False
      }
      DisplayPSA()
      {
        propText:=statText:=affixText:=""
        For key, value in This.Prop
        {
          If( RegExMatch(key, "^Required")
          || RegExMatch(key, "^Rating")
          || RegExMatch(key, "^Sockets")
          || RegExMatch(key, "^Quality")
          || RegExMatch(key, "^Map")
          || RegExMatch(key, "^Weapon"))
          {
            statText .= key . ":  " . value . "`n"
          }
          Else
          {
            propText .= key . ":  " . value . "`n"
          }
        }

        GuiControl, ItemInfo:, ItemInfoPropText, %propText%

        GuiControl, ItemInfo:, ItemInfoStatText, %statText%

        For key, value in This.Affix
        {
          If (value != 0 && value != "" && value != False)
            affixText .= key . ":  " . value . "`n"
        }
        GuiControl, ItemInfo:, ItemInfoAffixText, %affixText%
      }
      GraphNinjaPrices()
      {
        If This.Data.HasKey("Ninja")
        {
          Gosub, ShowGraph
          Gui, ItemInfo: Show, AutoSize, % This.Prop.ItemName " Sparkline"
        }
        Else
        {
          GoSub, noDataGraph
          GoSub, HideGraph
          Gui, ItemInfo: Show, AutoSize, % This.Prop.ItemName " has no Graph Data" (Item)
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

          GuiControl,ItemInfo: , GroupBox1, % "Sell " Item.Prop.ItemName " to Chaos"
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

          GuiControl,ItemInfo: , GroupBox2, % "Buy " Item.Prop.ItemName " from Chaos"
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
        Else If (This.Data.Ninja["sparkline"])
        {
          dataPoint := This.Data.Ninja["sparkline"]["data"]
          dataLTPoint := This.Data.Ninja["lowConfidenceSparkline"]["data"]
          totalChange := This.Data.Ninja["sparkline"]["totalChange"]
          totalLTChange := This.Data.Ninja["lowConfidenceSparkline"]["totalChange"]

          basePoint := 0
          For k, v in dataPoint
          {
            If Abs(v) > basePoint
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

          Avg := {}
          Loop 5
          {
            Avg[A_Index] := (dataPoint[A_Index+1] + dataPoint[A_Index+2]) / 2
          }
          paddedData := {}
          paddedData[1] := dataPoint[1]
          paddedData[2] := dataPoint[1]
          paddedData[3] := dataPoint[2]
          paddedData[4] := Avg[1]
          paddedData[5] := dataPoint[3]
          paddedData[6] := Avg[2]
          paddedData[7] := dataPoint[4]
          paddedData[8] := Avg[3]
          paddedData[9] := dataPoint[5]
          paddedData[10] := Avg[4]
          paddedData[11] := dataPoint[6]
          paddedData[12] := Avg[5]
          paddedData[13] := dataPoint[7]
          For k, v in paddedData
          {
            div := v / basePoint * 100
            XGraph_Plot( pGraph1, 100 - div, "", True )
            ;MsgBox % "Key : " k "   Val : " v
          }
          LTAvg := {}
          Loop 5
          {
            LTAvg[A_Index] := (dataLTPoint[A_Index+1] + dataLTPoint[A_Index+2]) / 2
          }
          paddedLTData := {}
          paddedLTData[1] := dataLTPoint[1]
          paddedLTData[2] := dataLTPoint[1]
          paddedLTData[3] := dataLTPoint[2]
          paddedLTData[4] := LTAvg[1]
          paddedLTData[5] := dataLTPoint[3]
          paddedLTData[6] := LTAvg[2]
          paddedLTData[7] := dataLTPoint[4]
          paddedLTData[8] := LTAvg[3]
          paddedLTData[9] := dataLTPoint[5]
          paddedLTData[10] := LTAvg[4]
          paddedLTData[11] := dataLTPoint[6]
          paddedLTData[12] := LTAvg[5]
          paddedLTData[13] := dataLTPoint[7]
          For k, v in paddedLTData
          {
            div := v / baseLTPoint * 100
            XGraph_Plot( pGraph2, 100 - div, "", True )
            ;MsgBox % "Key : " k "   Val : " v
          }

          GuiControl,ItemInfo: , GroupBox1, % "Value of " Item.Prop.ItemName
          GuiControl,ItemInfo: , PComment1, Chaos Value
          GuiControl,ItemInfo: , PData1, % This.Data.Ninja["chaosValue"]
          GuiControl,ItemInfo: , PComment2, Chaos Value `% Change
          GuiControl,ItemInfo: , PData2, % This.Data.Ninja["sparkline"]["totalChange"]
          GuiControl,ItemInfo: , PComment3, Exalted Value
          GuiControl,ItemInfo: , PData3, % This.Data.Ninja["exaltedValue"]
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

          GuiControl,ItemInfo: , GroupBox2, % "Low Confidence Value of " Item.Prop.ItemName
          GuiControl,ItemInfo: , SComment1, Chaos Value
          GuiControl,ItemInfo: , SData1, % This.Data.Ninja["chaosValue"]
          GuiControl,ItemInfo: , SComment2, Chaos Value `% Change
          GuiControl,ItemInfo: , SData2, % This.Data.Ninja["lowConfidenceSparkline"]["totalChange"]
          GuiControl,ItemInfo: , SComment3, 
          GuiControl,ItemInfo: , SData3, 
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
        Return

        noDataGraph:
          Loop 2
          {
            aVal := A_Index
            Loop 21
            {
              GuiControl,ItemInfo: , PercentText%aVal%G%A_Index%, 0`%
            }
            GuiControl,ItemInfo: , GroupBox%aVal%, No Data
            Loop 13
            {
              XGraph_Plot( pGraph%aVal%, 100, "", True )
            }
          }
          Loop 10
          {
            GuiControl,ItemInfo: , PComment%A_Index%,
            GuiControl,ItemInfo: , PData%A_Index%,
            GuiControl,ItemInfo: , SComment%A_Index%,
            GuiControl,ItemInfo: , SData%A_Index%,
          }
          aVal := ""
        Return

        HideGraph:
          Loop 2
          {
            aVal := A_Index
            Loop 21
            {
              GuiControl,ItemInfo: Hide, PercentText%aVal%G%A_Index%
            }
            GuiControl,ItemInfo: Hide, pGraph%aVal%
            GuiControl,ItemInfo: Hide, GroupBox%aVal%
          }
          Loop 10
          {
            GuiControl,ItemInfo: Hide, PComment%A_Index%
            GuiControl,ItemInfo: Hide, PData%A_Index%
            GuiControl,ItemInfo: Hide, SComment%A_Index%
            GuiControl,ItemInfo: Hide, SData%A_Index%
          }
          aVal := ""
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
      ItemInfo()
      {
        This.DisplayPSA()
        This.GraphNinjaPrices()
      }
    }
    ; ArrayToString - Make a string from array using | as delimiters
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    StringToArray(text)
    {
      Array := StrSplit(text,"|")
      return array
    }
  /*** Wingman GUI Handlers

  */
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
      Gui, 1: Submit
      Gui, CustomCrafting: New
      Gui, CustomCrafting: +AlwaysOnTop -MinimizeBox
      Gui, CustomCrafting: Add, Button, default gupdateEverything    x225 y180  w150 h23,   Save Configuration
      Gui, CustomCrafting: Add, ComboBox, Sort vCustomCraftingBase xm+5 ym+28 w350, %baseList%
      Gui, CustomCrafting: Add, Tab2, vInventoryGuiTabs x3 y3 w400 h205 -wrap , Tier 1|Tier 2|Tier 3|Tier 4
      Gui, CustomCrafting: Tab, Tier 1
        Gui, CustomCrafting: Add, Edit, vActiveCraftTier1 ReadOnly y+38 w350 r6 , %textList1%
        Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT1 Base
        Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT1 Base
        Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT1 Base
      Gui, CustomCrafting: Tab, Tier 2
        Gui, CustomCrafting: Add, Edit, vActiveCraftTier2 ReadOnly y+38 w350 r6 , %textList2%
        Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT2 Base
        Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT2 Base
        Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT2 Base
      Gui, CustomCrafting: Tab, Tier 3
        Gui, CustomCrafting: Add, Edit, vActiveCraftTier3 ReadOnly y+38 w350 r6 , %textList3%
        Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT3 Base
        Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT3 Base
        Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT3 Base
      Gui, CustomCrafting: Tab, Tier 4
        Gui, CustomCrafting: Add, Edit, vActiveCraftTier4 ReadOnly y+38 w350 r6 , %textList4%
        Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT4 Base
        Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT4 Base
        Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT4 Base
      Gui, CustomCrafting: Show, , Edit Crafting Tiers
    Return
    AddCustomCraftingBase:
      Gui, Submit, nohide
      RegExMatch(A_GuiControl, "T" num " Base", RxMatch )
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
      RegExMatch(A_GuiControl, "T" num " Base", RxMatch )
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
      RegExMatch(A_GuiControl, "T" num " Base", RxMatch )
      craftingBasesT%RxMatch1% := DefaultcraftingBasesT%RxMatch1%.Clone()
      textList := ""
      For k, v in craftingBasesT%RxMatch1%
            textList .= (!textList ? "" : ", ") v
      GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
    Return
  ; WR_Menu - New menu handling method
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    WR_Menu(Function:="",Var*)
    {
      Static Built_Inventory, Built_Strings, Built_Chat, Built_Controller, Built_Hotkeys, Built_Globe, LeagueIndex, UpdateLeaguesBtn, OHB_EditorBtn, WR_Reset_Globe, DefaultWhisper, DefaultCommands, DefaultButtons, LocateType, oldx, oldy, TempC ,WR_Btn_Locate_PortalScroll, WR_Btn_Locate_WisdomScroll, WR_Btn_Locate_CurrentGem, WR_Btn_Locate_AlternateGem, WR_Btn_Locate_CurrentGem2, WR_Btn_Locate_AlternateGem2, WR_Btn_Locate_GrabCurrency, WR_Btn_FillMetamorph_Select, WR_Btn_FillMetamorph_Show, WR_Btn_FillMetamorph_Menu, WR_Btn_IgnoreSlot, WR_UpDown_Color_Life, WR_UpDown_Color_ES, WR_UpDown_Color_Mana, WR_UpDown_Color_EB, WR_Edit_Color_Life, WR_Edit_Color_ES, WR_Edit_Color_Mana, WR_Edit_Color_EB, WR_Save_JSON_Globe, WR_Load_JSON_Globe, Obj, WR_Save_JSON_FillMetamorph

      Global InventoryGuiTabs, StringsGuiTabs, Globe, Player, WR_Progress_Color_Life, WR_Progress_Color_ES, WR_Progress_Color_Mana, WR_Progress_Color_EB
        , Globe_Life_X1, Globe_Life_Y1, Globe_Life_X2, Globe_Life_Y2, Globe_Life_Color_Hex, Globe_Life_Color_Variance, WR_Btn_Area_Life, WR_Btn_Show_Life
        , Globe_ES_X1, Globe_ES_Y1, Globe_ES_X2, Globe_ES_Y2, Globe_ES_Color_Hex, Globe_ES_Color_Variance, WR_Btn_Area_ES, WR_Btn_Show_ES
        , Globe_EB_X1, Globe_EB_Y1, Globe_EB_X2, Globe_EB_Y2, Globe_EB_Color_Hex, Globe_EB_Color_Variance, WR_Btn_Area_EB, WR_Btn_Show_EB
        , Globe_Mana_X1, Globe_Mana_Y1, Globe_Mana_X2, Globe_Mana_Y2, Globe_Mana_Color_Hex, Globe_Mana_Color_Variance, WR_Btn_Area_Mana, WR_Btn_Show_Mana
        , WR_Btn_FillMetamorph_Area
        , Globe_Percent_Life, Globe_Percent_ES, Globe_Percent_Mana, GlobeActive, YesPredictivePrice, YesPredictivePrice_Percent, YesPredictivePrice_Percent_Val, StashTabYesPredictive_Price
      If (Function = "Inventory")
      {
        Gui, 1: Submit
        If !Built_Inventory
        {
          Built_Inventory := 1
          Gui, Inventory: New
          Gui, Inventory: +AlwaysOnTop -MinimizeBox
          ;Save Setting
          Gui, Inventory: Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
          ; Gui, Inventory: Add, Button,      gloadSaved     x+5           h23,   Load
          Gui, Inventory: Add, Button,      gLaunchSite     x+5           h23,   Website

          Gui, Inventory: Add, Tab2, vInventoryGuiTabs x3 y3 w625 h505 -wrap , Options|Stash Tabs|Stash Hotkeys|Map Crafting Settings

        Gui, Inventory: Tab, Options
          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,       Section    w170 h170    xm   ym+25,         ID/Vend/Stash Options
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesIdentify          Checked%YesIdentify%    xs+5  ys+18   , Identify Items?
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesStash             Checked%YesStash%         y+8    , Deposit at stash?
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesVendor            Checked%YesVendor%        y+8    , Sell at vendor?
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesDiv               Checked%YesDiv%            y+8   , Trade Divination?
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesSortFirst         Checked%YesSortFirst%     y+8    , Group Items before stashing?
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesMapUnid           Checked%YesMapUnid%          y+8 , Leave Map Un-ID?
          Gui, Inventory: Add, Button,   gBuildIgnoreMenu vWR_Btn_IgnoreSlot y+8  w160 center, Ignore Slots

          Gui, Inventory: Font, Bold s9 cBlack, Arial
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
          Gui, Inventory: Add, Text,                     xs+12  y+6,         Current Gem1:
          Gui, Inventory: Add, Edit,       vCurrentGemX           x+8        y+-15   w34  h17,   %CurrentGemX%
          Gui, Inventory: Add, Edit,       vCurrentGemY           x+8                w34  h17,   %CurrentGemY%
          Gui, Inventory: Add, Text,                     xs+4  y+6,         Alternate Gem1:
          Gui, Inventory: Add, Edit,       vAlternateGemX         x+8        y+-15   w34  h17,   %AlternateGemX%
          Gui, Inventory: Add, Edit,       vAlternateGemY         x+8                w34  h17,   %AlternateGemY%
          Gui, Inventory: Add, Text,                     xs+12  y+6,         Current Gem2:
          Gui, Inventory: Add, Edit,       vCurrentGem2X          x+8        y+-15   w34  h17,   %CurrentGem2X%
          Gui, Inventory: Add, Edit,       vCurrentGem2Y          x+8                w34  h17,   %CurrentGem2Y%
          Gui, Inventory: Add, Text,                     xs+4  y+6,         Alternate Gem2:
          Gui, Inventory: Add, Edit,       vAlternateGem2X        x+8        y+-15   w34  h17,   %AlternateGem2X%
          Gui, Inventory: Add, Edit,       vAlternateGem2Y        x+8                w34  h17,   %AlternateGem2Y%
          Gui, Inventory: Add, Text,                     xs+9  y+6,         Grab Currency:
          Gui, Inventory: Add, Edit,       vGrabCurrencyPosX        x+8        y+-15   w34  h17,   %GrabCurrencyPosX%
          Gui, Inventory: Add, Edit,       vGrabCurrencyPosY        x+8                w34  h17,   %GrabCurrencyPosY%
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_PortalScroll                     xs+173       ys+31  h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_WisdomScroll                                  y+4    h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_CurrentGem                                    y+4    h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_AlternateGem                                  y+4    h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_CurrentGem2                                   y+4    h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_AlternateGem2                                 y+4    h17            , Locate
          Gui, Inventory: Add, Button,      gWR_Update vWR_Btn_Locate_GrabCurrency                                  y+4    h17            , Locate
          Gui, Inventory: Add, Checkbox,    vStockPortal                    Checked%StockPortal%                    x+13   ys+33          , Stock Portal?
          Gui, Inventory: Add, Checkbox,    vStockWisdom                    Checked%StockWisdom%                    y+8                   , Stock Wisdom?
          Gui, Inventory: Add, Checkbox,    vAlternateGemOnSecondarySlot    Checked%AlternateGemOnSecondarySlot%    y+8                   , Weapon Swap Gem1?
          Gui, Inventory: Add, Checkbox,    vGemItemToogle                  Checked%GemItemToogle%                  y+8                   , Enable Swap Item1?
          Gui, Inventory: Add, Checkbox,    vAlternateGem2OnSecondarySlot   Checked%AlternateGem2OnSecondarySlot%   y+8                   , Weapon Swap Gem2?
          Gui, Inventory: Add, Checkbox,    vGemItemToogle2                 Checked%GemItemToogle2%                 y+8                   , Enable Swap Item2?
          Gui, Inventory: Add, Text,                   xs+84   ys+25    h152 0x11
          Gui, Inventory: Add, Text,                   x+33             h152 0x11
          Gui, Inventory: Add, Text,                   x+33             h152 0x11

          IfNotExist, %A_ScriptDir%\data\leagues.json
          {
            UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
          }
          FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
          LeagueIndex := JSON.Load(JSONtext)
          textList= 
          For K, V in LeagueIndex
            textList .= (!textList ? "" : "|") LeagueIndex[K]["id"]

          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,       Section    w180 h160        xs   y+5,         Item Parse Settings
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, vYesNinjaDatabase xs+5 ys+20 Checked%YesNinjaDatabase%, Update PoE.Ninja DB?
          Gui, Inventory: Add, DropDownList, vUpdateDatabaseInterval x+1 yp-4 w30 Choose%UpdateDatabaseInterval%, 1|2|3|4|5|6|7
          Gui, Inventory: Add, DropDownList, vselectedLeague xs+5 y+5 w102, %textList%
          GuiControl,Inventory: ChooseString, selectedLeague, %selectedLeague%
          Gui, Inventory: Add, Button, gUpdateLeagues vUpdateLeaguesBtn x+5 , Refresh
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
          Slider_PredictivePrice := new Progress_Slider("Inventory", "YesPredictivePrice_Percent" , (PPx-6) , (PPy-3) , 175 , 15 , 50 , 200 , YesPredictivePrice_Percent_Val , "Black" , "F1C15D" , 1 , "YesPredictivePrice_Percent_Val" , 0 , 0 , 1, "General")
          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h130    section    xm+370   ys,         Automation
          AutomationList := "Search Stash|Search Vendor"
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesEnableAutomation Checked%YesEnableAutomation%       xs+5 ys+18  , Enable Automation ?
          Gui, Inventory: Add, Text, y+8, First Automation Action
          Gui, Inventory: Add, DropDownList, gUpdateExtra vFirstAutomationSetting y+3 w100 ,%AutomationList%
          GuiControl,Inventory: ChooseString, FirstAutomationSetting, %FirstAutomationSetting%
          Gui, Inventory: Add, Button, ghelpAutomation   x+10    w20 h20,   ?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesEnableNextAutomation Checked%YesEnableNextAutomation%   xs+5    y+8  , Enable Second Automation ?
          Gui, Inventory: Add, Checkbox, gWarningAutomation vYesEnableAutoSellConfirmation Checked%YesEnableAutoSellConfirmation%       y+8  , Enable Auto Confirm Vendor ?
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

          ; Keeping Specific Tab first

          ; Currency
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs ys+18 , Currency
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabCurrency yp hp , %StashTabCurrency%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesCurrency Checked%StashTabYesCurrency%  x+5 yp+4, Enable
          ; Map
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Map
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabMap x+0 yp hp ,  %StashTabMap%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesMap Checked%StashTabYesMap% x+5 yp+4, Enable
          
          ; Divination
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Divination
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabDivination x+0 yp hp ,  %StashTabDivination%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesDivination Checked%StashTabYesDivination% x+5 yp+4, Enable

          ; Fragments
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Fragment
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabFragment x+0 yp hp ,  %StashTabFragment%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesFragment Checked%StashTabYesFragment% x+5 yp+4, Enable

          ; Essence
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Essence
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabEssence x+0 yp hp ,  %StashTabEssence%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesEssence Checked%StashTabYesEssence% x+5 yp+4, Enable
          
          ; Collection
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Collection
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabCollection x+0 yp hp ,  %StashTabCollection%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesCollection Checked%StashTabYesCollection% x+5 yp+4, Enable

          ; Fossil
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Fossil
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabFossil , %StashTabFossil%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesFossil Checked%StashTabYesFossil% x+5 yp+4, Enable

          ; Resonator
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Resonator
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabResonator , %StashTabResonator%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesResonator Checked%StashTabYesResonator% x+5 yp+4, Enable
          
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Prophecy
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabProphecy x+0 yp hp ,  %StashTabProphecy%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesProphecy Checked%StashTabYesProphecy% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Veiled
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabVeiled x+0 yp hp ,  %StashTabVeiled%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesVeiled Checked%StashTabYesVeiled% x+5 yp+4, Enable

          ; Second column Gui
          
          ; Organ
          
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys+18 , Organ
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabOrgan x+0 yp hp , %StashTabOrgan%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesOrgan Checked%StashTabYesOrgan%  x+5 yp+4, Enable

          ; Oil
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Oil
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabOil x+0 yp hp ,  %StashTabOil%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesOil Checked%StashTabYesOil% x+5 yp+4, Enable

          ;Catalyst
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Catalyst
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabCatalyst x+0 yp hp ,  %StashTabCatalyst%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesCatalyst Checked%StashTabYesCatalyst% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Quality Gem
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabGemQuality , %StashTabGemQuality%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesGemQuality Checked%StashTabYesGemQuality% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Vaal Gem
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabGemVaal , %StashTabGemVaal%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesGemVaal Checked%StashTabYesGemVaal% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Support Gem
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabGemSupport , %StashTabGemSupport%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesGemSupport Checked%StashTabYesGemSupport% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Gem
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabGem , %StashTabGem%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesGem Checked%StashTabYesGem% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Cluster Jewel
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabClusterJewel x+0 yp hp ,  %StashTabClusterJewel%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesClusterJewel Checked%StashTabYesClusterJewel% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Quality Flask
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabFlaskQuality , %StashTabFlaskQuality%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesFlaskQuality Checked%StashTabYesFlaskQuality% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Linked
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabLinked , %StashTabLinked%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesLinked Checked%StashTabYesLinked% x+5 yp+4, Enable

          ; Third Column
          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys , Dump
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown,Range1-64 gUpdateStash vStashTabDump x+0 yp hp ,  %StashTabDump%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesDump Checked%StashTabYesDump% x+5 yp+4, Enable


          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Priced Rares
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabPredictive , %StashTabPredictive%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesPredictive Checked%StashTabYesPredictive% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Ninja Priced
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabNinjaPrice , %StashTabNinjaPrice%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesNinjaPrice Checked%StashTabYesNinjaPrice% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Crafting
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabCrafting , %StashTabCrafting%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesCrafting Checked%StashTabYesCrafting% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Unique Ring
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabUniqueRing , %StashTabUniqueRing%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% x+5 yp+4, Enable

          Gui, Inventory: Font, Bold s8 cBlack, Arial
          Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Unique Dump
          Gui, Inventory: Font,
          Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
          Gui, Inventory: Add, UpDown, Range1-64 x+0 yp hp gUpdateStash vStashTabUniqueDump , %StashTabUniqueDump%
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% x+5 yp+4, Enable

          ; Crafting Bases
          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h110    section    x+15   ys,         Crafting Tab
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashT1 Checked%YesStashT1%   xs+5  ys+18 , T1?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashT2 Checked%YesStashT2%   x+3        , T2?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashT3 Checked%YesStashT3%   x+3        , T3?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashT4 Checked%YesStashT4%   x+3        , T4?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashCraftingNormal Checked%YesStashCraftingNormal%     xs+5  y+8    , Normal?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashCraftingMagic Checked%YesStashCraftingMagic%   x+0        , Magic?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashCraftingRare Checked%YesStashCraftingRare%   x+0        , Rare?
          Gui, Inventory: Add, Checkbox, gUpdateExtra  vYesStashCraftingIlvl Checked%YesStashCraftingIlvl%     xs+5  y+8    , Above Ilvl:
          Gui, Inventory: Add, Edit, Number w40  x+2 yp-3  w40
          Gui, Inventory: Add, UpDown, Range1-100  hp gUpdateExtra vYesStashCraftingIlvlMin , %YesStashCraftingIlvlMin%
          Gui, Inventory: Add, Button, gCustomCrafting xs+15 y+5  w150,   Custom Crafting List

          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h60    section    xs   y+10,         Dump Tab
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashDumpInTrial Checked%StashDumpInTrial% xs+5 ys+18, Enable Dump in Trial
          Gui, Inventory: Add, Checkbox, gUpdateStash  vStashDumpSkipJC Checked%StashDumpSkipJC% xs+5 y+8, Skip Jewlers and Chromatics

          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h40    section    xs   y+10,         Priced Rares Tab
          Gui, Inventory: Font,
          Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
          Gui, Inventory: Add, Edit, x+5 yp-3 w40
          Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gUpdateStash vStashTabYesPredictive_Price , %StashTabYesPredictive_Price%

          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h40    section    xs   y+10,         Ninja Priced Tab
          Gui, Inventory: Font,
          Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
          Gui, Inventory: Add, Edit, x+5 yp-3 w40
          Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gUpdateStash vStashTabYesNinjaPrice_Price , %StashTabYesNinjaPrice_Price%

          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, GroupBox,             w180 h125    section    xs   y+10,         Map Options
          Gui, Inventory: Font,
          Gui, Inventory: Add, Checkbox, gUpdateExtra   vYesStashBlightedMap  Checked%YesStashBlightedMap% xs+5 ys+18 , Stash BlightedMaps?
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

        Gui, Inventory: Tab, Stash Hotkeys

          Gui, Inventory: Add, Checkbox, xm+5 ym+25  vYesStashKeys Checked%YesStashKeys%                    , Enable stash hotkeys?

          Gui, Inventory: Font,s9 cBlack Bold Underline, Arial
          Gui, Inventory: Add,GroupBox,Section xp-5 yp+20 w100 h85                      ,Modifier
          Gui, Inventory: Font,
          Gui, Inventory: Font,s9,Arial
          Gui, Inventory: Add, Edit, xs+4 ys+20 w90 h23 vstashPrefix1, %stashPrefix1%
          Gui, Inventory: Add, Edit, y+8    w90 h23 vstashPrefix2, %stashPrefix2%

          Gui, Inventory: Font,s9 cBlack Bold Underline, Arial
          Gui, Inventory: Add,GroupBox, xp-5 y+20 w100 h55                      ,Reset Tab
          Gui, Inventory: Font,
          Gui, Inventory: Font,s9,Arial
          Gui, Inventory: Add, Edit, xp+4 yp+20 w90 h23 vstashReset, %stashReset%

          Gui, Inventory: Font,s9 cBlack Bold Underline, Arial
          Gui, Inventory: Add,GroupBox,Section x+10 ys w100 h275                      ,Keys
          Gui, Inventory: Font,
          Gui, Inventory: Font,s9,Arial
          Gui, Inventory: Add, Edit, ys+20 xs+4 w90 h23 vstashSuffix1, %stashSuffix1%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix2, %stashSuffix2%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix3, %stashSuffix3%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix4, %stashSuffix4%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix5, %stashSuffix5%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix6, %stashSuffix6%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix7, %stashSuffix7%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix8, %stashSuffix8%
          Gui, Inventory: Add, Edit, y+5    w90 h23 vstashSuffix9, %stashSuffix9%

          Gui, Inventory: Font,s9 cBlack Bold Underline, Arial
          Gui, Inventory: Add,GroupBox,Section x+4 ys w50 h275                      ,Tab
          Gui, Inventory: Font,
          Gui, Inventory: Font,s9,Arial
          Gui, Inventory: Add, Edit, Number xs+4 ys+20 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab1 , %stashSuffixTab1%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab2 , %stashSuffixTab2%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab3 , %stashSuffixTab3%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab4 , %stashSuffixTab4%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab5 , %stashSuffixTab5%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab6 , %stashSuffixTab6%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab7 , %stashSuffixTab7%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab8 , %stashSuffixTab8%
          Gui, Inventory: Add, Edit, Number y+5 w40
          Gui, Inventory: Add, UpDown, Range1-64  x+0 hp vstashSuffixTab9 , %stashSuffixTab9%
        Gui, Inventory: Tab, Map Crafting Settings
          MapMethodList := "Disable|Transmutation+Augmentation|Alchemy|Chisel+Alchemy|Chisel+Alchemy+Vaal"
          MapTierList := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16"
          MapSetValue := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100"
          Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add, Text,       Section              x12   ym+25,         Map Crafting
          Gui, Inventory: Add,GroupBox,Section w285 h65 xs, Map Tier Range 1:
          Gui, Inventory: Font,
          Gui, Inventory: Font,s7
            Gui, Inventory: Add, Text,         xs+5     ys+20       , Initial
            Gui, Inventory: Add, Text,         xs+55    ys+20       , Ending
            Gui, Inventory: Add, Text,         xs+105   ys+20       , Method
            Gui, Inventory: Font,s8
            Gui, Inventory: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier1  Choose%StartMapTier1%,  %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier1    Choose%EndMapTier1%,    %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod1    Choose%CraftingMapMethod1%,   %MapMethodList%
            GuiControl,Inventory: ChooseString, CraftingMapMethod1, %CraftingMapMethod1%
            Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add,GroupBox,Section w285 h65 xs, Map Tier Range 2:
            Gui, Inventory: Font,
            Gui, Inventory: Font,s7
            Gui, Inventory: Add, Text,         xs+5     ys+20       , Initial
            Gui, Inventory: Add, Text,         xs+55    ys+20       , Ending
            Gui, Inventory: Add, Text,         xs+105   ys+20       , Method
            Gui, Inventory: Font,s8
            Gui, Inventory: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier2  Choose%StartMapTier2%,  %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier2    Choose%EndMapTier2%,    %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod2    Choose%CraftingMapMethod2%,    %MapMethodList%
            GuiControl,Inventory: ChooseString, CraftingMapMethod2, %CraftingMapMethod2%
            Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add,GroupBox,Section w285 h65 xs, Map Tier Range 3:
            Gui, Inventory: Font,
            Gui, Inventory: Font,s7
            Gui, Inventory: Add, Text,         xs+5     ys+20       , Initial
            Gui, Inventory: Add, Text,         xs+55    ys+20       , Ending
            Gui, Inventory: Add, Text,         xs+105   ys+20       , Method
            Gui, Inventory: Font,s8
            Gui, Inventory: Add, DropDownList, xs+5   ys+35    w40    vStartMapTier3  Choose%StartMapTier3%,  %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+55  ys+35    w40    vEndMapTier3    Choose%EndMapTier3%,    %MapTierList%
            Gui, Inventory: Add, DropDownList, xs+105 ys+35    w175   vCraftingMapMethod3    Choose%CraftingMapMethod3%,    %MapMethodList%
            GuiControl,Inventory: ChooseString, CraftingMapMethod3, %CraftingMapMethod3%
            Gui, Inventory: Font,
            Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add,GroupBox,Section w285 h160 xs, Undesireble Mods:
            Gui, Inventory: Font,
            Gui, Inventory: Font,s8
            Gui, Inventory: Add, Checkbox, vElementalReflect xs+5 ys+20 Checked%ElementalReflect%, Reflect # of Elemental Damage
            Gui, Inventory: Add, Checkbox, vPhysicalReflect xs+5 ys+40 Checked%PhysicalReflect%, Reflect # of Physical Damage
            Gui, Inventory: Add, Checkbox, vNoLeech xs+5 ys+60 Checked%NoLeech%, Cannot Leech Life/Mana from Monsters
            Gui, Inventory: Add, Checkbox, vNoRegen xs+5 ys+80 Checked%NoRegen%, Cannot Regenerate Life, Mana or Energy Shield
            Gui, Inventory: Add, Checkbox, vAvoidAilments xs+5 ys+100 Checked%AvoidAilments%, Chance to Avoid Elemental Ailments
            Gui, Inventory: Add, Checkbox, vAvoidPBB xs+5 ys+120 Checked%AvoidPBB%, Chance to Avoid Poison, Blind, and Bleeding
            Gui, Inventory: Add, Checkbox, vMinusMPR xs+5 ys+140 Checked%MinusMPR%, Reduced # Maximum Player Resistances
            Gui, Inventory: Font, Bold
            Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add,GroupBox,Section w170 h110 x320 y50, Minimum Map Qualities:
            Gui, Inventory: Font, 
            Gui, Inventory: Font,s8

            Gui, Inventory: Add, Edit, number limit2 xs+15 yp+18 w40
            Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp vMMapItemQuantity , %MMapItemQuantity%
            Gui, Inventory: Add, Text,         x+10 yp+3        , Item Quantity

            Gui, Inventory: Add, Edit, number limit2 xs+15 y+15 w40
            Gui, Inventory: Add, UpDown, Range1-54 x+0 yp hp vMMapItemRarity , %MMapItemRarity%
            Gui, Inventory: Add, Text,         x+10 yp+3        , Item Rarity

            Gui, Inventory: Add, Edit, number limit2 xs+15 y+15 w40
            Gui, Inventory: Add, UpDown, Range1-45 x+0 yp hp vMMapMonsterPackSize , %MMapMonsterPackSize%
            Gui, Inventory: Add, Text,         x+10 yp+3        , Monster Pack Size

            Gui, Inventory: Font, Bold s9 cBlack, Arial
          Gui, Inventory: Add,GroupBox,Section w170 h40 x320 y170, Minimum Settings Options:
          Gui, Inventory: Font,
            Gui, Inventory: Font,s8
            Gui, Inventory: Add, Checkbox, vEnableMQQForMagicMap x335 y190 Checked%EnableMQQForMagicMap%, Enable to Magic Maps?
        }
        Gui, Inventory: show , w600 h500, Inventory Settings
      }
      Else If (Function = "Strings")
      {
        Gui, 1: Submit
        If !Built_Strings
        {
          Built_Strings := 1
          Gui, Strings: New
          Gui, Strings: +AlwaysOnTop -MinimizeBox
          ;Save Setting
          ; Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
          ; Gui, Add, Button,      gloadSaved     x+5           h23,   Load
          
          Gui, Strings: Add, Button,      gLaunchSite     x295 y470           h23,   Website
          Gui, Strings: Add, Button,      gft_Start     x+5           h23,   FindText Gui (capture)
          Gui, Strings: Font, Bold cBlack
          Gui, Strings: Add, GroupBox,     Section    w625 h10            x3   y3,         String Samples from the FindText library - Use the dropdown to select from 1080 defaults
          Gui, Strings: Add, Tab2, Section vStringsGuiTabs x20 y30 w600 h480 -wrap , General|Vendor
          Gui, Strings: Font,

        Gui, Strings: Tab, General
          Gui, Strings: Add, Button, xs+1 ys+1 w1 h1, 
          Gui, Strings: +Delimiter?
          Gui, Strings: Add, Text, xs+10 ys+25 section, OHB 2 pixel bar - Only Adjust if not 1080 Height
          Gui, Strings: Add, ComboBox, xp y+8 w220 vHealthBarStr gUpdateStringEdit , %HealthBarStr%??"%1080_HealthBarStr%"?"%1440_HealthBarStr%"
          Gui, Strings: Add, Button, hp w50 x+10 yp vOHB_EditorBtn gOHBUpdate , Make
          Gui, Strings: Add, Text, x+10 x+10 ys , Capture of the Skill up icon
          Gui, Strings: Add, ComboBox, y+8 w280 vSkillUpStr gUpdateStringEdit , %SkillUpStr%??"%1080_SkillUpStr%"
          Gui, Strings: Add, Text, xs y+15 section , Capture of the words Sell Items
          Gui, Strings: Add, ComboBox, y+8 w280 vSellItemsStr gUpdateStringEdit , %SellItemsStr%??"%1080_SellItemsStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Stash
          Gui, Strings: Add, ComboBox, y+8 w280 vStashStr gUpdateStringEdit , %StashStr%??"%1080_StashStr%"
          Gui, Strings: Add, Text, xs y+15 section , Capture of the X button
          Gui, Strings: Add, ComboBox, y+8 w280 vXButtonStr gUpdateStringEdit , %XButtonStr%??"%1080_XButtonStr%"
          Gui, Strings: +Delimiter|

        Gui, Strings: Tab, Vendor
          Gui, Strings: Add, Button, Section x20 y30 w1 h1, 
          Gui, Strings: +Delimiter?
          Gui, Strings: Add, Text, xs+10 ys+25 section, Capture of the Hideout vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorStr gUpdateStringEdit , %VendorStr%??"%1080_MasterStr%"?"%1080_NavaliStr%"?"%1080_HelenaStr%"?"%1080_ZanaStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Azurite Mines vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorMineStr gUpdateStringEdit , %VendorMineStr%??"%1080_MasterStr%"
          Gui, Strings: Add, Text, xs y+15 section, Capture of the Lioneye vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorLioneyeStr gUpdateStringEdit , %VendorLioneyeStr%??"%1080_BestelStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Forest vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorForestStr gUpdateStringEdit , %VendorForestStr%??"%1080_GreustStr%"
          Gui, Strings: Add, Text, xs y+15 section, Capture of the Sarn vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorSarnStr gUpdateStringEdit , %VendorSarnStr%??"%1080_ClarissaStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Highgate vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorHighgateStr gUpdateStringEdit , %VendorHighgateStr%??"%1080_PetarusStr%"
          Gui, Strings: Add, Text, xs y+15 section, Capture of the Overseer vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorOverseerStr gUpdateStringEdit , %VendorOverseerStr%??"%1080_LaniStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Bridge vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorBridgeStr gUpdateStringEdit , %VendorBridgeStr%??"%1080_HelenaStr%"
          Gui, Strings: Add, Text, xs y+15 section, Capture of the Docks vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorDocksStr gUpdateStringEdit , %VendorDocksStr%??"%1080_LaniStr%"
          Gui, Strings: Add, Text, x+10 ys , Capture of the Oriath vendor nameplate
          Gui, Strings: Add, ComboBox, y+8 w280 vVendorOriathStr gUpdateStringEdit , %VendorOriathStr%??"%1080_LaniStr%"
          Gui, Strings: +Delimiter|
        }
        Gui, Strings: show , w640 h525, FindText Strings
      }
      Else If (Function = "Chat")
      {
        Gui, 1: Submit
        If !Built_Chat
        {
          Built_Chat := 1
          Gui, Chat: New
          Gui, Chat: +AlwaysOnTop -MinimizeBox
          Gui, Chat: Add, Checkbox, gUpdateExtra  vEnableChatHotkeys Checked%EnableChatHotkeys%   xm+400 ym                    , Enable chat Hotkeys?

          ;Save Setting
          Gui, Chat: Add, Button, default gupdateEverything    x295 y320  w150 h23,   Save Configuration
          ; Gui, Add, Button,      gloadSaved     x+5           h23,   Load
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
          GuiControl,Chat: ChooseString, 1Suffix1Text, %1Suffix1Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix2Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix2Text, %1Suffix2Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix3Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix3Text, %1Suffix3Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix4Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix4Text, %1Suffix4Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix5Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix5Text, %1Suffix5Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix6Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix6Text, %1Suffix6Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix7Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix7Text, %1Suffix7Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix8Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix8Text, %1Suffix8Text%
          Gui, Chat: Add, ComboBox,  y+5     w290 v1Suffix9Text, %textList%
          GuiControl,Chat: ChooseString, 1Suffix9Text, %1Suffix9Text%
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
          GuiControl,Chat: ChooseString, 2Suffix1Text, %2Suffix1Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix2Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix2Text, %2Suffix2Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix3Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix3Text, %2Suffix3Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix4Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix4Text, %2Suffix4Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix5Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix5Text, %2Suffix5Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix6Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix6Text, %2Suffix6Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix7Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix7Text, %2Suffix7Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix8Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix8Text, %2Suffix8Text%
          Gui, Chat: Add, ComboBox,  y+5      w290 v2Suffix9Text, %textList%
          GuiControl,Chat: ChooseString, 2Suffix9Text, %2Suffix9Text%
        }
        Gui, Chat: show , w620 h370, Chat Hotkeys
      }
      Else If (Function = "Controller")
      {
        Gui, 1: Submit
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

          Gui, Controller: Add, Checkbox, section xm+255 ym+360 vYesController Checked%YesController%,Enable Controller
          
          Gui, Controller: Add,GroupBox, section xm+80 ym+15 w80 h40                        ,5
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton5, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton5, %hotkeyControllerButton5%
          Gui, Controller: Add,GroupBox,  xs+360 ys w80 h40                        ,6
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton6, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton6, %hotkeyControllerButton6%

          Gui, Controller: Add,GroupBox, section  xm+65 ym+100 w90 h80                        ,D-Pad
          Gui, Controller: add,text, xs+15 ys+30, Mouse`nMovement

          Gui, Controller: Add,GroupBox, section xm+165 ym+180 w80 h80                        ,Joystick1
          Gui, Controller: Add,Checkbox, xs+5 ys+30     Checked%YesTriggerUtilityJoystickKey%      vYesTriggerUtilityJoystickKey, Use util from`nMove Keys?
          Gui, Controller: Add,GroupBox,  xs ys+90 w80 h40                        ,9 / L3
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton9, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton9, %hotkeyControllerButton9%

          Gui, Controller: Add,GroupBox,section  xs+190 ys w80 h80                        ,Joystick2
          Gui, Controller: Add,Checkbox, xp+5 y+-53     Checked%YesTriggerJoystick2Key%      vYesTriggerJoystick2Key, Use key?
          Gui, Controller: Add, ComboBox,        xp y+8    w70   vhotkeyControllerJoystick2, LButton|RButton|q|w|e|r|t
          GuiControl,Controller: ChooseString, hotkeyControllerJoystick2, %hotkeyControllerJoystick2%
          Gui, Controller: Add,GroupBox,  xs ys+90 w80 h40                        ,10 / R3
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton10, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton10, %hotkeyControllerButton10%

          Gui, Controller: Add,GroupBox, section xm+140 ym+60 w80 h40                        ,7 / Select
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton7, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton7, %hotkeyControllerButton7%
          Gui, Controller: Add,GroupBox, xs+245 ys w80 h40                        ,8 / Start
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w70                       vhotkeyControllerButton8, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton8, %hotkeyControllerButton8%

          Gui, Controller: Add,GroupBox, section xm+65 ym+280 w40 h40                  ,Up
          Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyUp, %hotkeyUp%
          Gui, Controller: Add,GroupBox, xs ys+80 w40 h40                        ,Down
          Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyDown, %hotkeyDown%
          Gui, Controller: Add,GroupBox, xs-40 ys+40 w40 h40                      ,Left
          Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyLeft, %hotkeyLeft%
          Gui, Controller: Add,GroupBox, xs+40 ys+40 w40 h40                      ,Right
          Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19                      vhotkeyRight, %hotkeyRight%

          Gui, Controller: Add,GroupBox,section xm+465 ym+80 w70 h40                      ,4
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButton4, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton4, %hotkeyControllerButton4%
          Gui, Controller: Add,GroupBox, xs ys+80 w70 h40                      ,1
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButton1, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton1, %hotkeyControllerButton1%
          Gui, Controller: Add,GroupBox, xs-40 ys+40 w70 h40                      ,3
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButton3, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton3, %hotkeyControllerButton3%
          Gui, Controller: Add,GroupBox, xs+40 ys+40 w70 h40                      ,2
          Gui, Controller: Add,ComboBox, xp+5 y+-23 w60                       vhotkeyControllerButton2, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
          GuiControl,Controller: ChooseString, hotkeyControllerButton2, %hotkeyControllerButton2%

          ;Save Setting
          Gui, Controller: Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration
          ; Gui, Controller: Add, Button,      gloadSaved     x+5           h23,   Load
          Gui, Controller: Add, Button,      gLaunchSite     x+5           h23,   Website
        }
        Gui, Controller: show , w620 h500, Controller Settings
      }
      Else if (Function = "Globe")
      {
        Gui, 1: Submit
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
          Global Picker := New ColorPicker("Globe","ColorPicker",460,30,80,200,120,0x000000)
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
            ToolTip, % "-- Locate " LocateType " --`n@ " x "," y "`nPress Ctrl to set"
          oldx := x, oldy := y
        } Until GetKeyState("Ctrl")
        Tooltip
        %LocateType%X := x, %LocateType%Y := y
        GuiControl,Inventory: ,% LocateType "X", %x%
        GuiControl,Inventory: ,% LocateType "Y", %y%
        MsgBox % x "," y " was captured as the new location for " LocateType
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
        MouseTip(Globe[AreaType].X1,Globe[AreaType].Y1,Globe[AreaType].Width,Globe[AreaType].Height)
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
          Else If (ValueType = "Select" && Obj := LetUserSelectRect())
          {
            FillMetamorph := {"X1":Obj.X1
              ,"Y1":Obj.Y1
              ,"X2":Obj.X2
              ,"Y2":Obj.Y2}
            GuiControl,,WR_Btn_FillMetamorph_Area, % "X1: " FillMetamorph.X1 "  Y1: " FillMetamorph.Y1 "`nX2: " FillMetamorph.X2 "  Y2: " FillMetamorph.Y2
          }
          Else If (ValueType = "Show")
          {
            MouseTip(FillMetamorph.X1,FillMetamorph.Y1,FillMetamorph.X2 - FillMetamorph.X1,FillMetamorph.Y2 - FillMetamorph.Y1)
          }
          Gui, FillMetamorph: Show
        }
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

      InventoryGuiClose:
      InventoryGuiEscape:
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
      return
      
      GlobeGuiClose:
      GlobeGuiEscape:
        GlobeActive := False
        Gui, Submit
        Gui, 1: show
      return
    }
  ; Debug messages within script
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GuiStatus(Fetch:="",SS:=1){
    If (SS)
      ScreenShot(GameX,GameY,GameX+GameW,GameY+GameH)
    If (Fetch="OnDetonate")
    {
      POnDetonateDelve := ScreenShot_GetColor(DetonateDelveX,DetonateY), POnDetonate := ScreenShot_GetColor(DetonateX,DetonateY)
      , OnDetonate := ((POnDetonateDelve=varOnDetonate || POnDetonate=varOnDetonate)?True:False)
      Return OnDetonate
    }
    Else If !(Fetch="")
    {
      P%Fetch% := ScreenShot_GetColor(vX_%Fetch%,vY_%Fetch%)
      temp := %Fetch% := (P%Fetch%=var%Fetch%?True:False)
      Return temp
    }
    POnChar := ScreenShot_GetColor(vX_OnChar,vY_OnChar), OnChar := (POnChar=varOnChar?True:False)
    POnChat := ScreenShot_GetColor(vX_OnChat,vY_OnChat), OnChat := (POnChat=varOnChat?True:False)
    POnMenu := ScreenShot_GetColor(vX_OnMenu,vY_OnMenu), OnMenu := (POnMenu=varOnMenu?True:False)
    POnInventory := ScreenShot_GetColor(vX_OnInventory,vY_OnInventory), OnInventory := (POnInventory=varOnInventory?True:False)
    POnStash := ScreenShot_GetColor(vX_OnStash,vY_OnStash), OnStash := (POnStash=varOnStash?True:False)
    POnVendor := ScreenShot_GetColor(vX_OnVendor,vY_OnVendor), OnVendor := (POnVendor=varOnVendor?True:False)
    POnDiv := ScreenShot_GetColor(vX_OnDiv,vY_OnDiv), OnDiv := (POnDiv=varOnDiv?True:False)
    POnLeft := ScreenShot_GetColor(vX_OnLeft,vY_OnLeft), OnLeft := (POnLeft=varOnLeft?True:False)
    POnDelveChart := ScreenShot_GetColor(vX_OnDelveChart,vY_OnDelveChart), OnDelveChart := (POnDelveChart=varOnDelveChart?True:False)
    POnMetamorph := ScreenShot_GetColor(vX_OnMetamorph,vY_OnMetamorph), OnMetamorph := (POnMetamorph=varOnMetamorph?True:False)
    If OnMines
    POnDetonate := ScreenShot_GetColor(DetonateDelveX,DetonateY)
    Else POnDetonate := ScreenShot_GetColor(DetonateX,DetonateY)
    OnDetonate := (POnDetonate=varOnDetonate?True:False)
    Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph))
  }
  ; PanelManager - This class manages every gamestate within one place
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; PanelStatus - This class manages pixel sample and comparison
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; PredictPrice - Evaluate results from TradeFunc_DoPoePricesRequest
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PredictPrice(Switch:="")
  {
    Static ItemList := []
    Static WarnedError := 0
    FoundMatch := False
    If (Prop.Rarity_Digit = 3 && (Prop.SpecialType = "" || Prop.SpecialType = "6Link" || Prop.SpecialType = "5Link") && YesPredictivePrice != "Off")
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
            MsgBox % PriceObj.error_msg
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
      Return 0

    If !(PriceObj.max > 0)
      Return 0

    If (Switch = "Obj")
      Return PriceObj
    Else
      Return PriceObj.Price
  }
  ; CheckOHB - Determine the position of the OHB
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CheckOHB()
  {
    If GamePID
    {
      if (ok:=FindText(GameX + Round((GameW / 2)-(OHBStrW/2)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2)+(OHBStrW/2)), GameY + Round(GameH / (1080 / 370)) , 0, 0, HealthBarStr,0))
        Return {1:ok.1.1, 2:ok.1.2, 3:ok.1.3,4:ok.1.4,"Id":ok.1.Id}
      Else
      {
        Ding(500,6,"OHB Not Found")
        Return False
      }
    }
    Else 
      Return False
  }
  CheckOHBold()
  {
    Global GameStr, HealthBarStr, OHB, OHBLHealthHex, OHBLESHex, OHBLEBHex, OHBCheckHex
    If WinActive(GameStr)
    {
      if (ok:=FindText(GameX + Round((GameW / 2)-(OHBStrW/2)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2)+(OHBStrW/2)), GameY + Round(GameH / (1080 / 370)) , 0, 0, HealthBarStr,0))
      {
        ok.1.3 -= 1
        ok.1.4 += 8

        OHB := { "X" : ok.1.1
          , "Y" : ok.1.2
          , "rX" : ok.1.1 + ok.1.3
          , "W" : ok.1.3
          , "H" : ok.1.4
          , "hpY" : ok.1.2 - (ok.1.4 // 2)
          , "mY" : ok.1.2 + (ok.1.4 // 2)
          , "esY" : ok.1.2 - 2
          , "ebY" : ok.1.2 + 2 }
        OHB["pX"] := { 1 : Round(ok.1.1 + (ok.1.3* 0.10))
          , 2 : Round(ok.1.1 + (ok.1.3* 0.20))
          , 3 : Round(ok.1.1 + (ok.1.3* 0.30))
          , 4 : Round(ok.1.1 + (ok.1.3* 0.40))
          , 5 : Round(ok.1.1 + (ok.1.3* 0.50))
          , 6 : Round(ok.1.1 + (ok.1.3* 0.60))
          , 7 : Round(ok.1.1 + (ok.1.3* 0.70))
          , 8 : Round(ok.1.1 + (ok.1.3* 0.80))
          , 9 : Round(ok.1.1 + (ok.1.3* 0.90))
          , 10 : Round(ok.1.1 + ok.1.3) }
        Return OHB.X + OHB.Y
      }
      Else
      {
        Ding(500,6,"OHB Not Found")
        Return False
      }
    }
    Else 
      Return False
  }
  ; ScanGlobe - Determine the percentage of Life, ES and Mana
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ScanGlobe(SS:=0)
  {
    Global Globe, Player, GlobeActive
    Static OldLife := 111, OldES := 111, OldMana := 111
    If (Life := FindText(Globe.Life.X1, Globe.Life.Y1, Globe.Life.X2, Globe.Life.Y2, 0,0,Globe.Life.Color.Str,SS,1))
      Player.Percent.Life := Round(((Globe.Life.Y2 - Life.1.2) / Globe.Life.Height) * 100)
    Else
      Player.Percent.Life := -1
    If (YesEldritchBattery)
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
  ; GetPercent - Determine the percentage of health
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  GetPercent(CID, PosY, Variance)
  {
    Thread, NoTimers, true    ;Critical
    Global OHB, OHBLHealthHex
    If !CompareRGB(ToRGB(CID),ToRGB(ScreenShot_GetColor(OHB.X+1, PosY)),Variance)
    {
      Ding(500,7,"OHB Obscured, Moved, or Dead" )
      Return HPerc
    }
    Else
    Found := OHB.X + 1
    Loop 10
    {
      pX:= OHB.pX[A_Index]
      If CompareRGB(ToRGB(CID),ToRGB(ScreenShot_GetColor(pX, PosY)),Variance)
        Found := pX
    }
    Thread, NoTimers, False    ;End Critical
    Return Round(100* (1 - ( (OHB.rX - Found) / OHB.W ) ) )
  }
  ; Rescale - Rescales values of the script to the user's resolution
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rescale(){
    Global GameX, GameY, GameW, GameH, FillMetamorph, Base, Globe
    If checkActiveType()
    {
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
        ;Auto Vendor Settings
          ;380,820
        Global VendorAcceptX:=GameX + Round(GameW/(1920/380))
        Global VendorAcceptY:=GameY + Round(GameH/(1080/820))
        ;Detonate Mines
        Global DetonateDelveX:=GameX + Round(GameW/(1920/1542))
        Global DetonateX:=GameX + Round(GameW/(1920/1658))
        Global DetonateY:=GameY + Round(GameH/(1080/901))
        ;Currency
        ;Scouring 175,476
        Global ScouringX:=GameX + Round(GameW/(1920/175))
        Global ScouringY:=GameY + Round(GameH/(1080/475))
        ;Chisel 605,220
        Global ChiselX:=GameX + Round(GameW/(1920/605))
        Global ChiselY:=GameY + Round(GameH/(1080/220))
        ;Alchemy 490,290
        Global AlchemyX:=GameX + Round(GameW/(1920/490))
        Global AlchemyY:=GameY + Round(GameH/(1080/290))
        ;Transmutation 60,290
        Global TransmutationX:=GameX + Round(GameW/(1920/60))
        Global TransmutationY:=GameY + Round(GameH/(1080/290))
        ;Alteration 120,290
        Global AlterationX:=GameX + Round(GameW/(1920/120))
        Global AlterationY:=GameY + Round(GameH/(1080/290))
        ;Augmentation 230,340
        Global AugmentationX:=GameX + Round(GameW/(1920/230))
        Global AugmentationY:=GameY + Round(GameH/(1080/340))
        ;Vaal 230,475
        Global VaalX:=GameX + Round(GameW/(1920/230))
        Global VaalY:=GameY + Round(GameH/(1080/475))
        ;Scrolls in currency tab
        Global WisdomStockX:=GameX + Round(GameW/(1920/115))
        Global PortalStockX:=GameX + Round(GameW/(1920/175))
        Global WPStockY:=GameY + Round(GameH/(1080/220))
        ;Status Check OnMenu
        global vX_OnMenu:=GameX + Round(GameW / 2)
        global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
        ;Status Check OnChar
        global vX_OnChar:=GameX + Round(GameW / (1920 / 41))
        global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
        ;Status Check OnChat
        global vX_OnChat:=GameX + Round(GameW / (1920 / 0))
        global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
        ;Status Check OnInventory
        global vX_OnInventory:=GameX + Round(GameW / (1920 / 1583))
        global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
        ;Status Check OnStash
        global vX_OnStash:=GameX + Round(GameW / (1920 / 336))
        global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
        ;Status Check OnVendor
        global vX_OnVendor:=GameX + Round(GameW / (1920 / 618))
        global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
        ;Status Check OnDiv
        global vX_OnDiv:=GameX + Round(GameW / (1920 / 618))
        global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
        ;Status Check OnLeft
        global vX_OnLeft:=GameX + Round(GameW / (1920 / 252))
        global vY_OnLeft:=GameY + Round(GameH / ( 1080 / 57))
        ;Status Check OnDelveChart
        global vX_OnDelveChart:=GameX + Round(GameW / (1920 / 466))
        global vY_OnDelveChart:=GameY + Round(GameH / ( 1080 / 89))
        ;Status Check OnMetamporph
        global vX_OnMetamorph:=GameX + Round(GameW / (1920 / 785))
        global vY_OnMetamorph:=GameY + Round(GameH / ( 1080 / 204))
        ;Life %'s
        global vX_Life:=GameX + Round(GameW / (1920 / 95))
        global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
        ;ES %'s
        If YesEldritchBattery
          global vX_ES:=GameX + Round(GameW / (1920 / 1740))
        Else
          global vX_ES:=GameX + Round(GameW / (1920 / 180))
        global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
        ;Mana
        global vX_Mana:=GameX + Round(GameW / (1920 / 1825))
        global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
        global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
        Global vH_ManaBar:= vY_Mana10 - vY_Mana90
        Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
        ;GUI overlay
        global GuiX:=GameX + Round(GameW / (1920 / -10))
        global GuiY:=GameY + Round(GameH / (1080 / 1027))
        ;Divination Y locations
        Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
        Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
        ;Stash tabs menu button
        global vX_StashTabMenu := GameX + Round(GameW / (1920 / 640))
        global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
        ;Stash tabs menu list
        global vX_StashTabList := GameX + Round(GameW / (1920 / 706))
        global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
        ;calculate the height of each tab
        global vY_StashTabSize := Round(GameH / ( 1080 / 22))
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
        ;Auto Vendor Settings
          ;380,820
        Global VendorAcceptX:=GameX + Round(GameW/(1440/380))
        Global VendorAcceptY:=GameY + Round(GameH/(1080/820))
        ;Detonate Mines
        Global DetonateDelveX:=GameX + Round(GameW/(1440/1062))
        Global DetonateX:=GameX + Round(GameW/(1440/1178))
        Global DetonateY:=GameY + Round(GameH/(1080/901))
                ;Currency
          ;Scouring 175,476
        Global ScouringX:=GameX + Round(GameW/(1440/175))
        Global ScouringY:=GameY + Round(GameH/(1080/475))
          ;Chisel 605,220
        Global ChiselX:=GameX + Round(GameW/(1440/605))
        Global ChiselY:=GameY + Round(GameH/(1080/220))
          ;Alchemy 490,290
        Global AlchemyX:=GameX + Round(GameW/(1440/490))
        Global AlchemyY:=GameY + Round(GameH/(1080/290))
          ;Transmutation 60,290
        Global TransmutationX:=GameX + Round(GameW/(1440/60))
        Global TransmutationY:=GameY + Round(GameH/(1080/290))
          ;Alteration 120,290
        Global AlterationX:=GameX + Round(GameW/(1440/120))
        Global AlterationY:=GameY + Round(GameH/(1080/290))
          ;Augmentation 230,340
        Global AugmentationX:=GameX + Round(GameW/(1440/230))
        Global AugmentationY:=GameY + Round(GameH/(1080/340))
          ;Vaal 230,475
        Global VaalX:=GameX + Round(GameW/(1440/230))
        Global VaalY:=GameY + Round(GameH/(1080/475))
        ;Scrolls in currency tab
        Global WisdomStockX:=GameX + Round(GameW/(1440/125))
        Global PortalStockX:=GameX + Round(GameW/(1440/175))
        Global WPStockY:=GameY + Round(GameH/(1080/220))
        ;Status Check OnMenu
        global vX_OnMenu:=GameX + Round(GameW / 2)
        global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
        ;Status Check OnChar
        global vX_OnChar:=GameX + Round(GameW / (1440 / 41))
        global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
        ;Status Check OnChat
        global vX_OnChat:=GameX + Round(GameW / (1440 / 0))
        global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
        ;Status Check OnInventory
        global vX_OnInventory:=GameX + Round(GameW / (1440 / 1103))
        global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
        ;Status Check OnStash
        global vX_OnStash:=GameX + Round(GameW / (1440 / 336))
        global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
        ;Status Check OnVendor
        global vX_OnVendor:=GameX + Round(GameW / (1440 / 378))
        global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
        ;Status Check OnDiv
        global vX_OnDiv:=GameX + Round(GameW / (1440 / 378))
        global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
        ;Status Check OnLeft
        global vX_OnLeft:=GameX + Round(GameW / (1440 / 252))
        global vY_OnLeft:=GameY + Round(GameH / ( 1080 / 57))
        ;Status Check OnDelveChart
        global vX_OnDelveChart:=GameX + Round(GameW / (1440 / 226))
        global vY_OnDelveChart:=GameY + Round(GameH / ( 1080 / 89))
        ;Status Check OnMetamorph
        global vX_OnMetamorph:=GameX + Round(GameW / (1440 / 545))
        global vY_OnMetamorph:=GameY + Round(GameH / ( 1080 / 204))
        ;Life %'s
        global vX_Life:=GameX + Round(GameW / (1440 / 95))
        global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
        ;ES %'s
        If YesEldritchBattery
          global vX_ES:=GameX + Round(GameW / (1440 / 1260))
        Else
          global vX_ES:=GameX + Round(GameW / (1440 / 180))
        global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
        ;Mana
        global vX_Mana:=GameX + Round(GameW / (1440 / 1345))
        global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
        global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
        Global vH_ManaBar:= vY_Mana10 - vY_Mana90
        Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
        ;GUI overlay
        global GuiX:=GameX + Round(GameW / (1440 / -10))
        global GuiY:=GameY + Round(GameH / (1080 / 1027))
        ;Divination Y locations
        Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
        Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
        ;Stash tabs menu button
        global vX_StashTabMenu := GameX + Round(GameW / (1440 / 640))
        global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
        ;Stash tabs menu list
        global vX_StashTabList := GameX + Round(GameW / (1440 / 706))
        global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
        ;calculate the height of each tab
        global vY_StashTabSize := Round(GameH / ( 1080 / 22))
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
        ;Auto Vendor Settings
        ;380,820
        Global VendorAcceptX:=GameX + Round(GameW/(2560/380))
        Global VendorAcceptY:=GameY + Round(GameH/(1080/820))
        ;Detonate Mines
        Global DetonateDelveX:=GameX + Round(GameW/(2560/2185))
        Global DetonateX:=GameX + Round(GameW/(2560/2298))
        Global DetonateY:=GameY + Round(GameH/(1080/901))
        ;Currency
          ;Scouring 175,476
        Global ScouringX:=GameX + Round(GameW/(2560/175))
        Global ScouringY:=GameY + Round(GameH/(1080/475))
          ;Chisel 605,220
        Global ChiselX:=GameX + Round(GameW/(2560/605))
        Global ChiselY:=GameY + Round(GameH/(1080/220))
          ;Alchemy 490,290
        Global AlchemyX:=GameX + Round(GameW/(2560/490))
        Global AlchemyY:=GameY + Round(GameH/(1080/290))
          ;Transmutation 60,290
        Global TransmutationX:=GameX + Round(GameW/(2560/60))
        Global TransmutationY:=GameY + Round(GameH/(1080/290))
          ;Alteration 120,290
        Global AlterationX:=GameX + Round(GameW/(2560/120))
        Global AlterationY:=GameY + Round(GameH/(1080/290))
          ;Augmentation 230,340
        Global AugmentationX:=GameX + Round(GameW/(2560/230))
        Global AugmentationY:=GameY + Round(GameH/(1080/340))
          ;Vaal 230,475
        Global VaalX:=GameX + Round(GameW/(2560/230))
        Global VaalY:=GameY + Round(GameH/(1080/475))
        ;Scrolls in currency tab
        Global WisdomStockX:=GameX + Round(GameW/(2560/125))
        Global PortalStockX:=GameX + Round(GameW/(2560/175))
        Global WPStockY:=GameY + Round(GameH/(1080/220))
        ;Status Check OnMenu
        global vX_OnMenu:=GameX + Round(GameW / 2)
        global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
        ;Status Check OnChar
        global vX_OnChar:=GameX + Round(GameW / (2560 / 41))
        global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
        ;Status Check OnChat
        global vX_OnChat:=GameX + Round(GameW / (2560 / 0))
        global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
        ;Status Check OnInventory
        global vX_OnInventory:=GameX + Round(GameW / (2560 / 2223))
        global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
        ;Status Check OnStash
        global vX_OnStash:=GameX + Round(GameW / (2560 / 336))
        global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
        ;Status Check OnVendor
        global vX_OnVendor:=GameX + Round(GameW / (2560 / 618))
        global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
        ;Status Check OnDiv
        global vX_OnDiv:=GameX + Round(GameW / (2560 / 618))
        global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
        ;Status Check OnLeft
        global vX_OnLeft:=GameX + Round(GameW / (2560 / 252))
        global vY_OnLeft:=GameY + Round(GameH / ( 1080 / 57))
        ;Status Check OnDelveChart
        global vX_OnDelveChart:=GameX + Round(GameW / (2560 / 786))
        global vY_OnDelveChart:=GameY + Round(GameH / ( 1080 / 89))
        ;Status Check OnMetamorph
        global vX_OnMetamorph:=GameX + Round(GameW / (2560 / 1105))
        global vY_OnMetamorph:=GameY + Round(GameH / ( 1080 / 204))
        ;Life %'s
        global vX_Life:=GameX + Round(GameW / (2560 / 95))
        global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
        ;ES %'s
        If YesEldritchBattery
          global vX_ES:=GameX + Round(GameW / (2560 / 2380))
        Else
          global vX_ES:=GameX + Round(GameW / (2560 / 180))
        global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
        ;Mana
        global vX_Mana:=GameX + Round(GameW / (2560 / 2465))
        global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
        global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
        Global vH_ManaBar:= vY_Mana10 - vY_Mana90
        Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
        ;GUI overlay
        global GuiX:=GameX + Round(GameW / (2560 / -10))
        global GuiY:=GameY + Round(GameH / (1080 / 1027))
        ;Divination Y locations
        Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
        Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
        ;Stash tabs menu button
        global vX_StashTabMenu := GameX + Round(GameW / (2560 / 640))
        global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
        ;Stash tabs menu list
        global vX_StashTabList := GameX + Round(GameW / (2560 / 706))
        global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
        ;calculate the height of each tab
        global vY_StashTabSize := Round(GameH / ( 1080 / 22))
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
        ;Auto Vendor Settings
        Global VendorAcceptX:=GameX + Round(GameW/(3440/945))
        Global VendorAcceptY:=GameY + Round(GameH/(1440/1090))
        ;Detonate Mines
        Global DetonateDelveX:=GameX + Round(GameW/(3440/2934))
        Global DetonateX:=GameX + Round(GameW/(3440/3090))
        Global DetonateY:=GameY + Round(GameH/(1440/1202))
        ;Currency
          ;Scouring 235,631
        Global ScouringX:=GameX + Round(GameW/(3440/235))
        Global ScouringY:=GameY + Round(GameH/(1440/630))
          ;Chisel 810,290
        Global ChiselX:=GameX + Round(GameW/(3440/810))
        Global ChiselY:=GameY + Round(GameH/(1440/290))
          ;Alchemy 655,390
        Global AlchemyX:=GameX + Round(GameW/(3440/655))
        Global AlchemyY:=GameY + Round(GameH/(1440/390))
          ;Transmutation 80,390
        Global TransmutationX:=GameX + Round(GameW/(3440/80))
        Global TransmutationY:=GameY + Round(GameH/(1440/390))
          ;Alteration 155, 390
        Global AlterationX:=GameX + Round(GameW/(3440/155))
        Global AlterationY:=GameY + Round(GameH/(1440/390))
          ;Augmentation 310,465
        Global AugmentationX:=GameX + Round(GameW/(3440/310))
        Global AugmentationY:=GameY + Round(GameH/(1440/465))
          ;Vaal 310, 631
        Global VaalX:=GameX + Round(GameW/(3440/310))
        Global VaalY:=GameY + Round(GameH/(1440/630))
        ;Scrolls in currency tab
        Global WisdomStockX:=GameX + Round(GameW/(3440/164))
        Global PortalStockX:=GameX + Round(GameW/(3440/228))
        Global WPStockY:=GameY + Round(GameH/(1440/299))
        ;Status Check OnMenu
        global vX_OnMenu:=GameX + Round(GameW / 2)
        global vY_OnMenu:=GameY + Round(GameH / (1440 / 72))
        ;Status Check OnChar
        global vX_OnChar:=GameX + Round(GameW / (3440 / 54))
        global vY_OnChar:=GameY + Round(GameH / ( 1440 / 1217))
        ;Status Check OnChat
        global vX_OnChat:=GameX + Round(GameW / (3440 / 0))
        global vY_OnChat:=GameY + Round(GameH / ( 1440 / 850))
        ;Status Check OnInventory
        global vX_OnInventory:=GameX + Round(GameW / (3440 / 2991))
        global vY_OnInventory:=GameY + Round(GameH / ( 1440 / 47))
        ;Status Check OnStash
        global vX_OnStash:=GameX + Round(GameW / (3440 / 448))
        global vY_OnStash:=GameY + Round(GameH / ( 1440 / 42))
        ;Status Check OnVendor
        global vX_OnVendor:=GameX + Round(GameW / (3440 / 1264))
        global vY_OnVendor:=GameY + Round(GameH / ( 1440 / 146))
        ;Status Check OnDiv
        global vX_OnDiv:=GameX + Round(GameW / (3440 / 822))
        global vY_OnDiv:=GameY + Round(GameH / ( 1440 / 181))
        ;Status Check OnLeft
        global vX_OnLeft:=GameX + Round(GameW / (3440 / 365))
        global vY_OnLeft:=GameY + Round(GameH / ( 1440 / 90))
        ;Status Check OnMetamporph
        global vX_OnMetamorph:=GameX + Round(GameW / ( 3440 / 1480))
        global vY_OnMetamorph:=GameY + Round(GameH / ( 1440 / 270))
        ;Life %'s
        global vX_Life:=GameX + Round(GameW / (3440 / 128))
        global vY_Life20:=GameY + Round(GameH / ( 1440 / 1383))
        global vY_Life30:=GameY + Round(GameH / ( 1440 / 1356))
        global vY_Life40:=GameY + Round(GameH / ( 1440 / 1329))
        global vY_Life50:=GameY + Round(GameH / ( 1440 / 1302))
        global vY_Life60:=GameY + Round(GameH / ( 1440 / 1275))
        global vY_Life70:=GameY + Round(GameH / ( 1440 / 1248))
        global vY_Life80:=GameY + Round(GameH / ( 1440 / 1221))
        global vY_Life90:=GameY + Round(GameH / ( 1440 / 1194))
        ;ES %'s
        If YesEldritchBattery
          global vX_ES:=GameX + Round(GameW / (3440 / 3222))
        Else
          global vX_ES:=GameX + Round(GameW / (3440 / 225))
        global vY_ES20:=GameY + Round(GameH / ( 1440 / 1383))
        global vY_ES30:=GameY + Round(GameH / ( 1440 / 1356))
        global vY_ES40:=GameY + Round(GameH / ( 1440 / 1329))
        global vY_ES50:=GameY + Round(GameH / ( 1440 / 1302))
        global vY_ES60:=GameY + Round(GameH / ( 1440 / 1275))
        global vY_ES70:=GameY + Round(GameH / ( 1440 / 1248))
        global vY_ES80:=GameY + Round(GameH / ( 1440 / 1221))
        global vY_ES90:=GameY + Round(GameH / ( 1440 / 1194))
        ;Mana
        global vX_Mana:=GameX + Round(GameW / (3440 / 3314))
        global vY_Mana10:=GameY + Round(GameH / (1440 / 1409))
        global vY_Mana90:=GameY + Round(GameH / (1440 / 1165))
        Global vH_ManaBar:= vY_Mana10 - vY_Mana90
        Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
        ;GUI overlay
        global GuiX:=GameX + Round(GameW / (3440 / -10))
        global GuiY:=GameY + Round(GameH / (1440 / 1370))
        ;Divination Y locations
        Global vY_DivTrade:=GameY + Round(GameH / (1440 / 983))
        Global vY_DivItem:=GameY + Round(GameH / (1440 / 805))
        ;Stash tabs menu button
        global vX_StashTabMenu := GameX + Round(GameW / (3440 / 853))
        global vY_StashTabMenu := GameY + Round(GameH / ( 1440 / 195))
        ;Stash tabs menu list
        global vX_StashTabList := GameX + Round(GameW / (3440 / 1000))
        global vY_StashTabList := GameY + Round(GameH / ( 1440 / 160))
        ;calculate the height of each tab
        global vY_StashTabSize := Round(GameH / ( 1440 / 29))
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
        ;Auto Vendor Settings
        ;380,820
        Global VendorAcceptX:=GameX + Round(GameW/(3840/380))
        Global VendorAcceptY:=GameY + Round(GameH/(1080/820))
        ;Detonate Mines
        Global DetonateDelveX:=GameX + Round(GameW/(3840/3462))
        Global DetonateX:=GameX + Round(GameW/(3840/3578))
        Global DetonateY:=GameY + Round(GameH/(1080/901))
        ;Currency
          ;Scouring 175,476
        Global ScouringX:=GameX + Round(GameW/(3840/175))
        Global ScouringY:=GameY + Round(GameH/(1080/475))
          ;Chisel 605,220
        Global ChiselX:=GameX + Round(GameW/(3840/605))
        Global ChiselY:=GameY + Round(GameH/(1080/220))
          ;Alchemy 490,290
        Global AlchemyX:=GameX + Round(GameW/(3840/490))
        Global AlchemyY:=GameY + Round(GameH/(1080/290))
          ;Transmutation 60,290
        Global TransmutationX:=GameX + Round(GameW/(3840/60))
        Global TransmutationY:=GameY + Round(GameH/(1080/290))
          ;Alteration 120,290
        Global AlterationX:=GameX + Round(GameW/(3840/120))
        Global AlterationY:=GameY + Round(GameH/(1080/290))
          ;Augmentation 230,340
        Global AugmentationX:=GameX + Round(GameW/(3840/230))
        Global AugmentationY:=GameY + Round(GameH/(1080/340))
          ;Vaal 230,475
        Global VaalX:=GameX + Round(GameW/(3840/230))
        Global VaalY:=GameY + Round(GameH/(1080/475))
        ;Scrolls in currency tab
        Global WisdomStockX:=GameX + Round(GameW/(3840/125))
        Global PortalStockX:=GameX + Round(GameW/(3840/175))
        Global WPStockY:=GameY + Round(GameH/(1080/220))
        ;Status Check OnMenu
        global vX_OnMenu:=GameX + Round(GameW / 2)
        global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
        ;Status Check OnChar
        global vX_OnChar:=GameX + Round(GameW / (3840 / 41))
        global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
        ;Status Check OnChat
        global vX_OnChat:=GameX + Round(GameW / (3840 / 0))
        global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
        ;Status Check OnInventory
        global vX_OnInventory:=GameX + Round(GameW / (3840 / 3503))
        global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
        ;Status Check OnStash
        global vX_OnStash:=GameX + Round(GameW / (3840 / 336))
        global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
        ;Status Check OnVendor
        global vX_OnVendor:=GameX + Round(GameW / (3840 / 1578))
        global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
        ;Status Check OnDiv
        global vX_OnDiv:=GameX + Round(GameW / (3840 / 1578))
        global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
        ;Status Check OnLeft
        global vX_OnLeft:=GameX + Round(GameW / (3840 / 252))
        global vY_OnLeft:=GameY + Round(GameH / ( 1080 / 57))
        ;Status Check OnDelveChart
        global vX_OnDelveChart:=GameX + Round(GameW / (3840 / 1426))
        global vY_OnDelveChart:=GameY + Round(GameH / ( 1080 / 89))
        ;Status Check OnMetamorph
        global vX_OnMetamorph:=GameX + Round(GameW / (3840 / 1745))
        global vY_OnMetamorph:=GameY + Round(GameH / ( 1080 / 204))
        ;Life %'s
        global vX_Life:=GameX + Round(GameW / (3840 / 95))
        global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
        ;ES %'s
        If YesEldritchBattery
          global vX_ES:=GameX + Round(GameW / (3840 / 3660))
        Else
          global vX_ES:=GameX + Round(GameW / (3840 / 180))
        global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
        global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
        global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
        global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
        global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
        global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
        global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
        global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
        ;Mana
        global vX_Mana:=GameX + Round(GameW / (3840 / 3745))
        global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
        global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
        Global vH_ManaBar:= vY_Mana10 - vY_Mana90
        Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
        ;GUI overlay
        global GuiX:=GameX + Round(GameW / (3840 / -10))
        global GuiY:=GameY + Round(GameH / (1080 / 1027))
        ;Divination Y locations
        Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
        Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
        ;Stash tabs menu button
        global vX_StashTabMenu := GameX + Round(GameW / (3840 / 640))
        global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
        ;Stash tabs menu list
        global vX_StashTabList := GameX + Round(GameW / (3840 / 706))
        global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
        ;calculate the height of each tab
        global vY_StashTabSize := Round(GameH / ( 1080 / 22))
      } 
      x_center := GameX + GameW / 2
      compensation := (GameW / GameH) == (16 / 10) ? 1.103829 : 1.103719
      y_center := GameY + GameH / 2 / compensation
      offset_mod := y_offset / GameH
      x_offset := GameW * (offset_mod / 1.5 )
      Global ScrCenter := { "X" : GameX + Round(GameW / 2) , "Y" : GameY + Round(GameH / 2) }
      RescaleRan := True
      Global GameWindow := {"X" : GameX, "Y" : GameY, "W" : GameW, "H" : GameH, "BBarY" : (GameY + (GameH / (1080 / 75))) }
    }
    return
  }
  ; Compare two hex colors as their R G B elements, puts all the below together
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ToRGBfromBGR(color) {
    return { "b": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "r": color & 0xFF }
  }
  ; Converts a hex RGB color into its R G B elements
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ToRGB(color) {
    return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
  }
  ; Converts R G B elements back to hex
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  hexBGRToRGB(color) {
      b := Format("{1:02X}",(color >> 16) & 0xFF)
      g := Format("{1:02X}",(color >> 8) & 0xFF)
      r := Format("{1:02X}",color & 0xFF)
    return "0x" . r . g . b
  }
  ; Compares two converted HEX codes as R G B within the variance range (use ToRGB to convert first)
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CompareRGB(c1, c2, vary:=1) {
    rdiff := Abs( c1.r - c2.r )
    gdiff := Abs( c1.g - c2.g )
    bdiff := Abs( c1.b - c2.b )
    return rdiff <= vary && gdiff <= vary && bdiff <= vary
  }
  ; Check if a specific hex value is part of an array within a variance and return the index
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; Transform an array to a comma separated string
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  arrToStr(array){
    Str := ""
    For Index, Value In array
      Str .= "," . Value
    Str := LTrim(Str, ",")
    return Str
  }
  ; Transform an array to a comma separated string
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Clamp( Val, Min, Max) {
    If Val < Min
      Val := Min
    If Val > Max
      Val := Max
    Return
  }
  ; ClampGameScreen - Ensure points do not go outside Game Window
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    ToolTip,Total Quality:`t %allQ%`%,100,180,15
    ToolTip,Currency Value:`t %expectC% orbs,100,200,18
    ToolTip,Groups Quality:`t %tQ%`%,100,220,16
    ToolTip,Excess Groups Q:`t %overQ%`%,100,240,17
    ToolTip,Leftover Quality:`t %remainQ%`%,100,260,19
    SetTimer, RemoveToolTip, -20000
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CompareLocation(cStr:="")
  {
    Static Lang := ""
    ;                             English / Thai         French         German           Russian             Spanish        Portuguese        Chinese      Korean
    Static ClientTowns :=  { "Lioneye's Watch" :    [ "Lioneye's Watch"     , "Le Guet d'Œil de Lion"  , "Löwenauges Wacht"    , "Застава Львиного глаза", "La Vigilancia de Lioneye", "Vigília de Lioneye"    , "獅眼守望"  , "라이온아이 초소에" ]
                , "The Forest Encampment" : [ "The Forest Encampment" ,"Le Campement de la forêt", "Das Waldlager"     , "Лесной лагерь"     , "El Campamento Forestal"  , "Acampamento da Floresta" , "森林營地"  , "숲 야영지에" ]
                , "The Sarn Encampment" :   [ "The Sarn Encampment"   , "Le Campement de Sarn"   , "Das Lager von Sarn"  , "Лагерь Сарна"      , "El Campamento de Sarn"   , "Acampamento de Sarn"   , "薩恩營地"  , "사안 야영지에" ]
                , "Highgate" :        [ "Highgate"        , "Hautevoie"        , "Hohenpforte"       , "Македы"        , "Atalaya"                       , "統治者之殿"  , "하이게이트에" ]
                , "Overseer's Tower" :    [ "Overseer's Tower"    , "La Tour du Superviseur" , "Der Turm des Aufsehers", "Башня надзирателя"   , "La Torre del Capataz"  , "Torre do Capataz"    , "堅守高塔"  , "감시탑에" ]
                , "The Bridge Encampment" : [ "The Bridge Encampment" , "Le Campement du pont"   , "Das Brückenlager"    , "Лагерь на мосту"     , "El Campamento del Puente", "Acampamento da Ponte"  , "橋墩營地"  , "다리 야영지에" ]
                , "Oriath Docks" :      [ "Oriath Docks"      , "Les Docks d'Oriath"   , "Die Docks von Oriath"  , "Доки Ориата"       , "Las Dársenas de Oriath"  , "Docas de Oriath"     , "奧瑞亞港口"  , "오리아스 부두에" ]
                , "Oriath" :        [ "Oriath"                                   , "Ориат"                                     , "奧瑞亞"    , "오리아스에" ] }
    Static LangString :=  { "English" : ": You have entered"  , "Spanish" : " : Has entrado a "   , "Chinese" : " : 你已進入："   , "Korean" : "진입했습니다"   , "German" : " : Ihr habt '"
                , "Russian" : " : Вы вошли в область "  , "French" : " : Vous êtes à présent dans : "   , "Portuguese" : " : Você entrou em: "  , "Thai" : " : คุณเข้าสู่ " }
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
        If (CurrentLocation = "Azurite Mine")
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
        Ding(500,-10,"Critical Load Error`nSize: " . errchk . "MB")
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  CoolTime() {
    VarSetCapacity(PerformanceCount, 8, 0)
    VarSetCapacity(PerformanceFreq, 8, 0)
    DllCall("QueryPerformanceCounter", "Ptr", &PerformanceCount)
    DllCall("QueryPerformanceFrequency", "Ptr", &PerformanceFreq)
    return NumGet(PerformanceCount, 0, "Int64") / NumGet(PerformanceFreq, 0, "Int64")
  }
  ; DaysSince - Check how many days has it been since the last update
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  RandomSleep(min,max){
      Random, r, min, max
      r:=floor(r/Speed)
      Sleep, r*Latency
    return
  }
  ; Reset Chat
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ResetChat(){
    Send {Enter}{Up}{Escape}
    return
  }
  ; Grab Reply whisper recipient
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; ScrapeNinjaData - Parse raw data from PoE-Ninja API and standardize Chaos Value || Chaose Equivalent
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ScrapeNinjaData(apiString)
  {
    If InStr(apiString, "Fragment")
    {
      UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
      If ErrorLevel{
        MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid or an API change
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
          UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
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
          grabPayLowSparklineVal := (indexArr["lowConfidencePaySparkLine"] ? indexArr["lowConfidencePaySparkLine"] : False)
          grabRecLowSparklineVal := (indexArr["lowConfidenceReceiveSparkLine"] ? indexArr["lowConfidenceReceiveSparkLine"] : False)
          holder.lines[index] := {"name":grabName
            ,"chaosValue":grabChaosVal
            ,"pay":grabPayVal
            ,"receive":grabRecVal
            ,"paySparkLine":grabPaySparklineVal
            ,"receiveSparkLine":grabRecSparklineVal
            ,"lowConfidencePaySparkLine":grabPayLowSparklineVal
            ,"lowConfidenceReceiveSparkLine":grabRecLowSparklineVal}
        }
        Ninja[apiString] := holder.lines
        FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
      }
      Return
    }
    Else If InStr(apiString, "Currency")
    {
      UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
      if ErrorLevel{
        MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid
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
          UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
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
          grabPayLowSparklineVal := (indexArr["lowConfidencePaySparkLine"] ? indexArr["lowConfidencePaySparkLine"] : False)
          grabRecLowSparklineVal := (indexArr["lowConfidenceReceiveSparkLine"] ? indexArr["lowConfidenceReceiveSparkLine"] : False)
          holder.lines[index] := {"name":grabName
            ,"chaosValue":grabChaosVal
            ,"pay":grabPayVal
            ,"receive":grabRecVal
            ,"paySparkLine":grabPaySparklineVal
            ,"receiveSparkLine":grabRecSparklineVal
            ,"lowConfidencePaySparkLine":grabPayLowSparklineVal
            ,"lowConfidenceReceiveSparkLine":grabRecLowSparklineVal}
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
      UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
      if ErrorLevel{
        MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid
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
          UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\temp\data_%apiString%.txt
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
          grabLowSparklineVal := (indexArr["lowConfidenceSparkline"] ? indexArr["lowConfidenceSparkline"] : False)
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
            ,"sparkline":grabSparklineVal
            ,"lowConfidenceSparkline":grabLowSparklineVal}

            ; ,"lowConfidenceSparkline":grabLowSparklineVal}
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  hotkeys(){
    global
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
      Return
    Gui, Show, Autosize Center,   WingmanReloaded
    processWarningFound:=0
    Gui,6:Hide
    return
  }
  ; UpdateLeagues - Grab the League info from GGG API
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
        WinGet PrintSourceID, ID
        hdd_frame := DllCall("GetDC", UInt, PrintSourceID)
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
    W := X2 - X1
    H := Y2 - Y1
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
    if (buff:=FindText(GameX, GameY, GameX + (GameW//(6/5)),GameY + (GameH//(1080/75)), 0, 0, StackRelease_BuffIcon,0))
    {
      If FindText(buff.1.1 + StackRelease_X1Offset,buff.1.2 + buff.1.4 + StackRelease_Y1Offset,buff.1.1 + buff.1.3 + StackRelease_X2Offset,buff.1.2 + buff.1.4 + StackRelease_Y2Offset, 0, 0, StackRelease_BuffCount,0)
      {
        If GetKeyState(StackRelease_Keybind,"P")
        {
          Send {%StackRelease_Keybind% up}
          Sleep, 10
          Send {%StackRelease_Keybind% down}
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
  ; Cooldown Timers
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; TimerFlask - Flask CD Timers
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    TDetonated:
      Detonated:=0
      ;settimer,TDetonated,delete
    return
  ; Tray Labels
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -


/*** JSON v2.1.3 : JSON lib for AutoHotkey.
 * Lib: JSON.ahk
 *   JSON lib for AutoHotkey.
 * Version:
 *   v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *   WTFPL [http://wtfpl.net/]
 * Requirements:
 *   Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *   Use #Include JSON.ahk or copy into a function library folder and then
 *   use #Include <JSON>
 * Links:
 *   GitHub:   - https://github.com/cocobelgica/AutoHotkey-JSON
 *   Forum Topic - http://goo.gl/r0zI8t
 *   Email:    - cocobelgica <at> gmail <dot> com
 * Class: JSON
 *   The JSON object contains methods for parsing JSON and converting values
 *   to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *   Nestable(via #Include) - NO.
 * Methods:
 *   Load() - see relevant documentation before method definition header
 *   Dump() - see relevant documentation before method definition header
 */
  class JSON
  {
    /**
    * Method: Load
    *   Parses a JSON string into an AHK value
    * Syntax:
    *   value := JSON.Load( text [, reviver ] )
    * Parameter(s):
    *   value    [retval] - parsed value
    *   text  [in, ByRef] - JSON formatted string
    *   reviver   [in, opt] - function object, similar to JavaScript's
    *               JSON.parse() 'reviver' parameter
    */
    class Load extends JSON.Functor
    {
      Call(self, ByRef text, reviver:="")
      {
        this.rev := IsObject(reviver) ? reviver : false
      ; Object keys(and array indices) are temporarily stored in arrays so that
      ; we can enumerate them in the order they appear in the document/text instead
      ; of alphabetically. Skip if no reviver function is specified.
        this.keys := this.rev ? {} : false
        static quot := Chr(34), bashq := "\" . quot
          , json_value := quot . "{[01234567890-tfn"
          , json_value_or_array_closing := quot . "{[]01234567890-tfn"
          , object_key_or_object_closing := quot . "}"
        key := ""
        is_key := false
        root := {}
        stack := [root]
        next := json_value
        pos := 0
        while ((ch := SubStr(text, ++pos, 1)) != "") {
          if InStr(" `t`r`n", ch)
            continue
          if !InStr(next, ch, 1)
            this.ParseError(next, text, pos)
          holder := stack[1]
          is_array := holder.IsArray
          if InStr(",:", ch) {
            next := (is_key := !is_array && ch == ",") ? quot : json_value
          } else if InStr("}]", ch) {
            ObjRemoveAt(stack, 1)
            next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
          } else {
            if InStr("{[", ch) {
            ; Check if Array() is overridden and if its return value has
            ; the 'IsArray' property. If so, Array() will be called normally,
            ; otherwise, use a custom base object for arrays
              static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
            
            ; sacrifice readability for minor(actually negligible) performance gain
              (ch == "{")
                ? ( is_key := true
                , value := OrderedArray()
                , next := object_key_or_object_closing )
              ; ch == "["
                : ( value := json_array ? new json_array : []
                , next := json_value_or_array_closing )
              
              ObjInsertAt(stack, 1, value)
              if (this.keys)
                this.keys[value] := []
            
            } else {
              if (ch == quot) {
                i := pos
                while (i := InStr(text, quot,, i+1)) {
                  value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
                  static tail := A_AhkVersion<"2" ? 0 : -1
                  if (SubStr(value, tail) != "\")
                    break
                }
                if (!i)
                  this.ParseError("'", text, pos)
                value := StrReplace(value,  "\/",  "/")
                , value := StrReplace(value, bashq, quot)
                , value := StrReplace(value,  "\b", "`b")
                , value := StrReplace(value,  "\f", "`f")
                , value := StrReplace(value,  "\n", "`n")
                , value := StrReplace(value,  "\r", "`r")
                , value := StrReplace(value,  "\t", "`t")
                pos := i ; update pos
                
                i := 0
                while (i := InStr(value, "\",, i+1)) {
                  if !(SubStr(value, i+1, 1) == "u")
                    this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
                  uffff := Abs("0x" . SubStr(value, i+2, 4))
                  if (A_IsUnicode || uffff < 0x100)
                    value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
                }
                if (is_key) {
                  key := value, next := ":"
                  continue
                }
              
              } else {
                value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
                static number := "number", integer :="integer"
                if value is %number%
                {
                  if value is %integer%
                    value += 0
                }
                else if (value == "true" || value == "false")
                  value := %value% + 0
                else if (value == "null")
                  value := ""
                else
                ; we can do more here to pinpoint the actual culprit
                ; but that's just too much extra work.
                  this.ParseError(next, text, pos, i)
                pos += i-1
              }
              next := holder==root ? "" : is_array ? ",]" : ",}"
            } ; If InStr("{[", ch) { ... } else
            is_array? key := ObjPush(holder, value) : holder[key] := value
            if (this.keys && this.keys.HasKey(holder))
              this.keys[holder].Push(key)
          }
        
        } ; while ( ... )
        return this.rev ? this.Walk(root, "") : root[""]
      }
      ParseError(expect, ByRef text, pos, len:=1)
      {
        static quot := Chr(34), qurly := quot . "}"
        
        line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
        col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
        msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
        ,   (expect == "")   ? "Extra data"
          : (expect == "'")  ? "Unterminated string starting at"
          : (expect == "\")  ? "Invalid \escape"
          : (expect == ":")  ? "Expecting ':' delimiter"
          : (expect == quot)   ? "Expecting object key enclosed in double quotes"
          : (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
          : (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
          : (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
          : InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
          :            "Expecting JSON value(string, number, true, false, null, object or array)"
        , line, col, pos)
        static offset := A_AhkVersion<"2" ? -3 : -4
        throw Exception(msg, offset, SubStr(text, pos, len))
      }
      Walk(holder, key)
      {
        value := holder[key]
        if IsObject(value) {
          for i, k in this.keys[value] {
            ; check if ObjHasKey(value, k) ??
            v := this.Walk(value, k)
            if (v != JSON.Undefined)
              value[k] := v
            else
              ObjDelete(value, k)
          }
        }
        
        return this.rev.Call(holder, key, value)
      }
    }
    /**
    * Method: Dump
    *   Converts an AHK value into a JSON string
    * Syntax:
    *   str := JSON.Dump( value [, replacer, space ] )
    * Parameter(s):
    *   str    [retval] - JSON representation of an AHK value
    *   value      [in] - any value(object, string, number)
    *   replacer  [in, opt] - function object, similar to JavaScript's
    *               JSON.stringify() 'replacer' parameter
    *   space   [in, opt] - similar to JavaScript's JSON.stringify()
    *               'space' parameter
    */
    class Dump extends JSON.Functor
    {
      Call(self, value, replacer:="", space:="")
      {
        this.rep := IsObject(replacer) ? replacer : ""
        this.gap := ""
        if (space) {
          static integer := "integer"
          if space is %integer%
            Loop, % ((n := Abs(space))>10 ? 10 : n)
              this.gap .= " "
          else
            this.gap := SubStr(space, 1, 10)
          this.indent := "`n"
        }
        return this.Str({"": value}, "")
      }
      Str(holder, key)
      {
        value := holder[key]
        if (this.rep)
          value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)
        if IsObject(value) {
        ; Check object type, skip serialization for other object types such as
        ; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
          static type := A_AhkVersion<"2" ? "" : Func("Type")
          if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
            if (this.gap) {
              stepback := this.indent
              this.indent .= this.gap
            }
            is_array := value.IsArray
          ; Array() is not overridden, rollback to old method of
          ; identifying array-like objects. Due to the use of a for-loop
          ; sparse arrays such as '[1,,3]' are detected as objects({}). 
            if (!is_array) {
              for i in value
                is_array := i == A_Index
              until !is_array
            }
            str := ""
            if (is_array) {
              Loop, % value.Length() {
                if (this.gap)
                  str .= this.indent
                
                v := this.Str(value, A_Index)
                str .= (v != "") ? v . "," : "null,"
              }
            } else {
              colon := this.gap ? ": " : ":"
              for k in value {
                v := this.Str(value, k)
                if (v != "") {
                  if (this.gap)
                    str .= this.indent
                  str .= this.Quote(k) . colon . v . ","
                }
              }
            }
            if (str != "") {
              str := RTrim(str, ",")
              if (this.gap)
                str .= stepback
            }
            if (this.gap)
              this.indent := stepback
            return is_array ? "[" . str . "]" : "{" . str . "}"
          }
        
        } else ; is_number ? value : "value"
          return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
      }
      Quote(string)
      {
        static quot := Chr(34), bashq := "\" . quot
        if (string != "") {
          string := StrReplace(string,  "\",  "\\")
          ; , string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
          , string := StrReplace(string, quot, bashq)
          , string := StrReplace(string, "`b",  "\b")
          , string := StrReplace(string, "`f",  "\f")
          , string := StrReplace(string, "`n",  "\n")
          , string := StrReplace(string, "`r",  "\r")
          , string := StrReplace(string, "`t",  "\t")
          static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
          while RegExMatch(string, rx_escapable, m)
            string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
        }
        return quot . string . quot
      }
    }
    /**
    * Property: Undefined
    *   Proxy for 'undefined' type
    * Syntax:
    *   undefined := JSON.Undefined
    * Remarks:
    *   For use with reviver and replacer functions since AutoHotkey does not
    *   have an 'undefined' type. Returning blank("") or 0 won't work since these
    *   can't be distnguished from actual JSON values. This leaves us with objects.
    *   Replacer() - the caller may return a non-serializable AHK objects such as
    *   ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
    *   mimic the behavior of returning 'undefined' in JavaScript but for the sake
    *   of code readability and convenience, it's better to do 'return JSON.Undefined'.
    *   Internally, the property returns a ComObject with the variant type of VT_EMPTY.
    */
    Undefined[]
    {
      get {
        static empty := {}, vt_empty := ComObject(0, &empty, 1)
        return vt_empty
      }
    }
    class Functor
    {
      __Call(method, ByRef arg, args*)
      {
      ; When casting to Call(), use a new instance of the "function object"
      ; so as to avoid directly storing the properties(used across sub-methods)
      ; into the "function object" itself.
        if IsObject(method)
          return (new this).Call(method, arg, args*)
        else if (method == "")
          return (new this).Call(arg, args*)
      }
    }
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -


; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
  ; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
  ; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
  ;
  ; Updated 2/20/2014 - fixed Gdip_CreateRegion() and Gdip_GetClipRegion() on AHK Unicode x86
  ; Updated 5/13/2013 - fixed Gdip_SetBitmapToClipboard() on AHK Unicode x64
  ;
  ;#####################################################################################
  ;#####################################################################################
  ; STATUS ENUMERATION
  ; Return values for functions specified to have status enumerated return type
  ;#####################################################################################
  ;
  ; Ok =            = 0
  ; GenericError        = 1
  ; InvalidParameter      = 2
  ; OutOfMemory        = 3
  ; ObjectBusy        = 4
  ; InsufficientBuffer    = 5
  ; NotImplemented      = 6
  ; Win32Error        = 7
  ; WrongState        = 8
  ; Aborted          = 9
  ; FileNotFound        = 10
  ; ValueOverflow        = 11
  ; AccessDenied        = 12
  ; UnknownImageFormat    = 13
  ; FontFamilyNotFound    = 14
  ; FontStyleNotFound      = 15
  ; NotTrueTypeFont      = 16
  ; UnsupportedGdiplusVersion  = 17
  ; GdiplusNotInitialized    = 18
  ; PropertyNotFound      = 19
  ; PropertyNotSupported    = 20
  ; ProfileNotFound      = 21
  ;
  ;#####################################################################################
  ;#####################################################################################
  ; FUNCTIONS
  ;#####################################################################################
  ;
  ; UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
  ; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
  ; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster="")
  ; SetImage(hwnd, hBitmap)
  ; Gdip_BitmapFromScreen(Screen=0, Raster="")
  ; CreateRectF(ByRef RectF, x, y, w, h)
  ; CreateSizeF(ByRef SizeF, w, h)
  ; CreateDIBSection
  ;
  ;#####################################################################################

  ; Function:         UpdateLayeredWindow
  ; Description:        Updates a layered window with the handle to the DC of a gdi bitmap
  ; 
  ; hwnd            Handle of the layered window to update
  ; hdc             Handle to the DC of the GDI bitmap to update the window with
  ; Layeredx          x position to place the window
  ; Layeredy          y position to place the window
  ; Layeredw          Width of the window
  ; Layeredh          Height of the window
  ; Alpha           Default = 255 : The transparency (0-255) to set the window transparency
  ;
  ; return            If the function succeeds, the return value is nonzero
  ;
  ; notes            If x or y omitted, then layered window will use its current coordinates
  ;              If w or h omitted then current width and height will be used

  UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if ((x != "") && (y != ""))
      VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")

    if (w = "") ||(h = "")
      WinGetPos,,, w, h, ahk_id %hwnd%
  
    return DllCall("UpdateLayeredWindow"
            , Ptr, hwnd
            , Ptr, 0
            , Ptr, ((x = "") && (y = "")) ? 0 : &pt
            , "int64*", w|h<<32
            , Ptr, hdc
            , "int64*", 0
            , "uint", 0
            , "UInt*", Alpha<<16|1<<24
            , "uint", 2)
  }

  ;#####################################################################################

  ; Function        BitBlt
  ; Description      The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle 
  ;            of pixels from the specified source device context into a destination device context.
  ;
  ; dDC          handle to destination DC
  ; dx          x-coord of destination upper-left corner
  ; dy          y-coord of destination upper-left corner
  ; dw          width of the area to copy
  ; dh          height of the area to copy
  ; sDC          handle to source DC
  ; sx          x-coordinate of source upper-left corner
  ; sy          y-coordinate of source upper-left corner
  ; Raster        raster operation code
  ;
  ; return        If the function succeeds, the return value is nonzero
  ;
  ; notes          If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
  ;
  ; BLACKNESS        = 0x00000042
  ; NOTSRCERASE      = 0x001100A6
  ; NOTSRCCOPY      = 0x00330008
  ; SRCERASE        = 0x00440328
  ; DSTINVERT        = 0x00550009
  ; PATINVERT        = 0x005A0049
  ; SRCINVERT        = 0x00660046
  ; SRCAND        = 0x008800C6
  ; MERGEPAINT      = 0x00BB0226
  ; MERGECOPY        = 0x00C000CA
  ; SRCCOPY        = 0x00CC0020
  ; SRCPAINT        = 0x00EE0086
  ; PATCOPY        = 0x00F00021
  ; PATPAINT        = 0x00FB0A09
  ; WHITENESS        = 0x00FF0062
  ; CAPTUREBLT      = 0x40000000
  ; NOMIRRORBITMAP    = 0x80000000

  BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdi32\BitBlt"
            , Ptr, dDC
            , "int", dx
            , "int", dy
            , "int", dw
            , "int", dh
            , Ptr, sDC
            , "int", sx
            , "int", sy
            , "uint", Raster ? Raster : 0x00CC0020)
  }

  ;#####################################################################################

  ; Function        StretchBlt
  ; Description      The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle, 
  ;            stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
  ;            The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
  ;
  ; ddc          handle to destination DC
  ; dx          x-coord of destination upper-left corner
  ; dy          y-coord of destination upper-left corner
  ; dw          width of destination rectangle
  ; dh          height of destination rectangle
  ; sdc          handle to source DC
  ; sx          x-coordinate of source upper-left corner
  ; sy          y-coordinate of source upper-left corner
  ; sw          width of source rectangle
  ; sh          height of source rectangle
  ; Raster        raster operation code
  ;
  ; return        If the function succeeds, the return value is nonzero
  ;
  ; notes          If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt    

  StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdi32\StretchBlt"
            , Ptr, ddc
            , "int", dx
            , "int", dy
            , "int", dw
            , "int", dh
            , Ptr, sdc
            , "int", sx
            , "int", sy
            , "int", sw
            , "int", sh
            , "uint", Raster ? Raster : 0x00CC0020)
  }

  ;#####################################################################################

  ; Function        SetStretchBltMode
  ; Description      The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
  ;
  ; hdc          handle to the DC
  ; iStretchMode      The stretching mode, describing how the target will be stretched
  ;
  ; return        If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
  ;
  ; STRETCH_ANDSCANS     = 0x01
  ; STRETCH_ORSCANS     = 0x02
  ; STRETCH_DELETESCANS   = 0x03
  ; STRETCH_HALFTONE     = 0x04

  SetStretchBltMode(hdc, iStretchMode=4)
  {
    return DllCall("gdi32\SetStretchBltMode"
            , A_PtrSize ? "UPtr" : "UInt", hdc
            , "int", iStretchMode)
  }

  ;#####################################################################################

  ; Function        SetImage
  ; Description      Associates a new image with a static control
  ;
  ; hwnd          handle of the control to update
  ; hBitmap        a gdi bitmap to associate the static control with
  ;
  ; return        If the function succeeds, the return value is nonzero

  SetImage(hwnd, hBitmap)
  {
    SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
    E := ErrorLevel
    DeleteObject(E)
    return E
  }

  ;#####################################################################################

  ; Function        SetSysColorToControl
  ; Description      Sets a solid colour to a control
  ;
  ; hwnd          handle of the control to update
  ; SysColor        A system colour to set to the control
  ;
  ; return        If the function succeeds, the return value is zero
  ;
  ; notes          A control must have the 0xE style set to it so it is recognised as a bitmap
  ;            By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
  ;
  ; COLOR_3DDKSHADOW        = 21
  ; COLOR_3DFACE          = 15
  ; COLOR_3DHIGHLIGHT        = 20
  ; COLOR_3DHILIGHT        = 20
  ; COLOR_3DLIGHT          = 22
  ; COLOR_3DSHADOW        = 16
  ; COLOR_ACTIVEBORDER      = 10
  ; COLOR_ACTIVECAPTION      = 2
  ; COLOR_APPWORKSPACE      = 12
  ; COLOR_BACKGROUND        = 1
  ; COLOR_BTNFACE          = 15
  ; COLOR_BTNHIGHLIGHT      = 20
  ; COLOR_BTNHILIGHT        = 20
  ; COLOR_BTNSHADOW        = 16
  ; COLOR_BTNTEXT          = 18
  ; COLOR_CAPTIONTEXT        = 9
  ; COLOR_DESKTOP          = 1
  ; COLOR_GRADIENTACTIVECAPTION  = 27
  ; COLOR_GRADIENTINACTIVECAPTION  = 28
  ; COLOR_GRAYTEXT        = 17
  ; COLOR_HIGHLIGHT        = 13
  ; COLOR_HIGHLIGHTTEXT      = 14
  ; COLOR_HOTLIGHT        = 26
  ; COLOR_INACTIVEBORDER      = 11
  ; COLOR_INACTIVECAPTION      = 3
  ; COLOR_INACTIVECAPTIONTEXT    = 19
  ; COLOR_INFOBK          = 24
  ; COLOR_INFOTEXT        = 23
  ; COLOR_MENU          = 4
  ; COLOR_MENUHILIGHT        = 29
  ; COLOR_MENUBAR          = 30
  ; COLOR_MENUTEXT        = 7
  ; COLOR_SCROLLBAR        = 0
  ; COLOR_WINDOW          = 5
  ; COLOR_WINDOWFRAME        = 6
  ; COLOR_WINDOWTEXT        = 8

  SetSysColorToControl(hwnd, SysColor=15)
  {
  WinGetPos,,, w, h, ahk_id %hwnd%
  bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
  pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
  pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
  Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
  hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
  SetImage(hwnd, hBitmap)
  Gdip_DeleteBrush(pBrushClear)
  Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
  return 0
  }

  ;#####################################################################################

  ; Function        Gdip_BitmapFromScreen
  ; Description      Gets a gdi+ bitmap from the screen
  ;
  ; Screen        0 = All screens
  ;            Any numerical value = Just that screen
  ;            x|y|w|h = Take specific coordinates with a width and height
  ; Raster        raster operation code
  ;
  ; return          If the function succeeds, the return value is a pointer to a gdi+ bitmap
  ;            -1:    one or more of x,y,w,h not passed properly
  ;
  ; notes          If no raster operation is specified, then SRCCOPY is used to the returned bitmap

  Gdip_BitmapFromScreen(Screen=0, Raster="")
  {
    if (Screen = 0)
    {
      Sysget, x, 76
      Sysget, y, 77  
      Sysget, w, 78
      Sysget, h, 79
    }
    else if (SubStr(Screen, 1, 5) = "hwnd:")
    {
      Screen := SubStr(Screen, 6)
      if !WinExist( "ahk_id " Screen)
        return -2
      WinGetPos,,, w, h, ahk_id %Screen%
      x := y := 0
      hhdc := GetDCEx(Screen, 3)
    }
    else if (Screen&1 != "")
    {
      Sysget, M, Monitor, %Screen%
      x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
    }
    else
    {
      StringSplit, S, Screen, |
      x := S1, y := S2, w := S3, h := S4
    }

    if (x = "") || (y = "") || (w = "") || (h = "")
      return -1

    chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
    BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
    ReleaseDC(hhdc)
    
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
    return pBitmap
  }

  ;#####################################################################################

  ; Function        Gdip_BitmapFromHWND
  ; Description      Uses PrintWindow to get a handle to the specified window and return a bitmap from it
  ;
  ; hwnd          handle to the window to get a bitmap from
  ;
  ; return        If the function succeeds, the return value is a pointer to a gdi+ bitmap
  ;
  ; notes          Window must not be not minimised in order to get a handle to it's client area

  Gdip_BitmapFromHWND(hwnd)
  {
    WinGetPos,,, Width, Height, ahk_id %hwnd%
    hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
    PrintWindow(hwnd, hdc)
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
    return pBitmap
  }

  ;#####################################################################################

  ; Function        CreateRectF
  ; Description      Creates a RectF object, containing a the coordinates and dimensions of a rectangle
  ;
  ; RectF           Name to call the RectF object
  ; x            x-coordinate of the upper left corner of the rectangle
  ; y            y-coordinate of the upper left corner of the rectangle
  ; w            Width of the rectangle
  ; h            Height of the rectangle
  ;
  ; return          No return value

  CreateRectF(ByRef RectF, x, y, w, h)
  {
  VarSetCapacity(RectF, 16)
  NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
  }

  ;#####################################################################################

  ; Function        CreateRect
  ; Description      Creates a Rect object, containing a the coordinates and dimensions of a rectangle
  ;
  ; RectF           Name to call the RectF object
  ; x            x-coordinate of the upper left corner of the rectangle
  ; y            y-coordinate of the upper left corner of the rectangle
  ; w            Width of the rectangle
  ; h            Height of the rectangle
  ;
  ; return          No return value

  CreateRect(ByRef Rect, x, y, w, h)
  {
    VarSetCapacity(Rect, 16)
    NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
  }
  ;#####################################################################################

  ; Function        CreateSizeF
  ; Description      Creates a SizeF object, containing an 2 values
  ;
  ; SizeF         Name to call the SizeF object
  ; w            w-value for the SizeF object
  ; h            h-value for the SizeF object
  ;
  ; return          No Return value

  CreateSizeF(ByRef SizeF, w, h)
  {
  VarSetCapacity(SizeF, 8)
  NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")   
  }
  ;#####################################################################################

  ; Function        CreatePointF
  ; Description      Creates a SizeF object, containing an 2 values
  ;
  ; SizeF         Name to call the SizeF object
  ; w            w-value for the SizeF object
  ; h            h-value for the SizeF object
  ;
  ; return          No Return value

  CreatePointF(ByRef PointF, x, y)
  {
  VarSetCapacity(PointF, 8)
  NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float")   
  }
  ;#####################################################################################

  ; Function        CreateDIBSection
  ; Description      The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
  ;
  ; w            width of the bitmap to create
  ; h            height of the bitmap to create
  ; hdc          a handle to the device context to use the palette from
  ; bpp          bits per pixel (32 = ARGB)
  ; ppvBits        A pointer to a variable that receives a pointer to the location of the DIB bit values
  ;
  ; return        returns a DIB. A gdi bitmap
  ;
  ; notes          ppvBits will receive the location of the pixels in the DIB

  CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    hdc2 := hdc ? hdc : GetDC()
    VarSetCapacity(bi, 40, 0)
    
    NumPut(w, bi, 4, "uint")
    , NumPut(h, bi, 8, "uint")
    , NumPut(40, bi, 0, "uint")
    , NumPut(1, bi, 12, "ushort")
    , NumPut(0, bi, 16, "uInt")
    , NumPut(bpp, bi, 14, "ushort")
    
    hbm := DllCall("CreateDIBSection"
            , Ptr, hdc2
            , Ptr, &bi
            , "uint", 0
            , A_PtrSize ? "UPtr*" : "uint*", ppvBits
            , Ptr, 0
            , "uint", 0, Ptr)

    if !hdc
      ReleaseDC(hdc2)
    return hbm
  }

  ;#####################################################################################

  ; Function        PrintWindow
  ; Description      The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
  ;
  ; hwnd          A handle to the window that will be copied
  ; hdc          A handle to the device context
  ; Flags          Drawing options
  ;
  ; return        If the function succeeds, it returns a nonzero value
  ;
  ; PW_CLIENTONLY      = 1

  PrintWindow(hwnd, hdc, Flags=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("PrintWindow", Ptr, hwnd, Ptr, hdc, "uint", Flags)
  }

  ;#####################################################################################

  ; Function        DestroyIcon
  ; Description      Destroys an icon and frees any memory the icon occupied
  ;
  ; hIcon          Handle to the icon to be destroyed. The icon must not be in use
  ;
  ; return        If the function succeeds, the return value is nonzero

  DestroyIcon(hIcon)
  {
    return DllCall("DestroyIcon", A_PtrSize ? "UPtr" : "UInt", hIcon)
  }

  ;#####################################################################################

  PaintDesktop(hdc)
  {
    return DllCall("PaintDesktop", A_PtrSize ? "UPtr" : "UInt", hdc)
  }

  ;#####################################################################################

  CreateCompatibleBitmap(hdc, w, h)
  {
    return DllCall("gdi32\CreateCompatibleBitmap", A_PtrSize ? "UPtr" : "UInt", hdc, "int", w, "int", h)
  }

  ;#####################################################################################

  ; Function        CreateCompatibleDC
  ; Description      This function creates a memory device context (DC) compatible with the specified device
  ;
  ; hdc          Handle to an existing device context          
  ;
  ; return        returns the handle to a device context or 0 on failure
  ;
  ; notes          If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

  CreateCompatibleDC(hdc=0)
  {
  return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
  }

  ;#####################################################################################

  ; Function        SelectObject
  ; Description      The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
  ;
  ; hdc          Handle to a DC
  ; hgdiobj        A handle to the object to be selected into the DC
  ;
  ; return        If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
  ;
  ; notes          The specified object must have been created by using one of the following functions
  ;            Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
  ;            Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
  ;            Font - CreateFont, CreateFontIndirect
  ;            Pen - CreatePen, CreatePenIndirect
  ;            Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
  ;
  ; notes          If the selected object is a region and the function succeeds, the return value is one of the following value
  ;
  ; SIMPLEREGION      = 2 Region consists of a single rectangle
  ; COMPLEXREGION      = 3 Region consists of more than one rectangle
  ; NULLREGION      = 1 Region is empty

  SelectObject(hdc, hgdiobj)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
  }

  ;#####################################################################################

  ; Function        DeleteObject
  ; Description      This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
  ;            After the object is deleted, the specified handle is no longer valid
  ;
  ; hObject        Handle to a logical pen, brush, font, bitmap, region, or palette to delete
  ;
  ; return        Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

  DeleteObject(hObject)
  {
  return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
  }

  ;#####################################################################################

  ; Function        GetDC
  ; Description      This function retrieves a handle to a display device context (DC) for the client area of the specified window.
  ;            The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window. 
  ;
  ; hwnd          Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen          
  ;
  ; return        The handle the device context for the specified window's client area indicates success. NULL indicates failure

  GetDC(hwnd=0)
  {
    return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
  }

  ;#####################################################################################

  ; DCX_CACHE = 0x2
  ; DCX_CLIPCHILDREN = 0x8
  ; DCX_CLIPSIBLINGS = 0x10
  ; DCX_EXCLUDERGN = 0x40
  ; DCX_EXCLUDEUPDATE = 0x100
  ; DCX_INTERSECTRGN = 0x80
  ; DCX_INTERSECTUPDATE = 0x200
  ; DCX_LOCKWINDOWUPDATE = 0x400
  ; DCX_NORECOMPUTE = 0x100000
  ; DCX_NORESETATTRS = 0x4
  ; DCX_PARENTCLIP = 0x20
  ; DCX_VALIDATE = 0x200000
  ; DCX_WINDOW = 0x1

  GetDCEx(hwnd, flags=0, hrgnClip=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
  }

  ;#####################################################################################

  ; Function        ReleaseDC
  ; Description      This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
  ;
  ; hdc          Handle to the device context to be released
  ; hwnd          Handle to the window whose device context is to be released
  ;
  ; return        1 = released
  ;            0 = not released
  ;
  ; notes          The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
  ;            An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function. 

  ReleaseDC(hdc, hwnd=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
  }

  ;#####################################################################################

  ; Function        DeleteDC
  ; Description      The DeleteDC function deletes the specified device context (DC)
  ;
  ; hdc          A handle to the device context
  ;
  ; return        If the function succeeds, the return value is nonzero
  ;
  ; notes          An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

  DeleteDC(hdc)
  {
  return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
  }
  ;#####################################################################################

  ; Function        Gdip_LibraryVersion
  ; Description      Get the current library version
  ;
  ; return        the library version
  ;
  ; notes          This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

  Gdip_LibraryVersion()
  {
    return 1.45
  }

  ;#####################################################################################

  ; Function        Gdip_LibrarySubVersion
  ; Description      Get the current library sub version
  ;
  ; return        the library sub version
  ;
  ; notes          This is the sub-version currently maintained by Rseding91
  Gdip_LibrarySubVersion()
  {
    return 1.47
  }

  ;#####################################################################################

  ; Function:        Gdip_BitmapFromBRA
  ; Description:       Gets a pointer to a gdi+ bitmap from a BRA file
  ;
  ; BRAFromMemIn      The variable for a BRA file read to memory
  ; File          The name of the file, or its number that you would like (This depends on alternate parameter)
  ; Alternate        Changes whether the File parameter is the file name or its number
  ;
  ; return          If the function succeeds, the return value is a pointer to a gdi+ bitmap
  ;            -1 = The BRA variable is empty
  ;            -2 = The BRA has an incorrect header
  ;            -3 = The BRA has information missing
  ;            -4 = Could not find file inside the BRA

  Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
  {
    Static FName = "ObjRelease"
    
    if !BRAFromMemIn
      return -1
    Loop, Parse, BRAFromMemIn, `n
    {
      if (A_Index = 1)
      {
        StringSplit, Header, A_LoopField, |
        if (Header0 != 4 || Header2 != "BRA!")
          return -2
      }
      else if (A_Index = 2)
      {
        StringSplit, Info, A_LoopField, |
        if (Info0 != 3)
          return -3
      }
      else
        break
    }
    if !Alternate
      StringReplace, File, File, \, \\, All
    RegExMatch(BRAFromMemIn, "mi`n)^" (Alternate ? File "\|.+?\|(\d+)\|(\d+)" : "\d+\|" File "\|(\d+)\|(\d+)") "$", FileInfo)
    if !FileInfo
      return -4
    
    hData := DllCall("GlobalAlloc", "uint", 2, Ptr, FileInfo2, Ptr)
    pData := DllCall("GlobalLock", Ptr, hData, Ptr)
    DllCall("RtlMoveMemory", Ptr, pData, Ptr, &BRAFromMemIn+Info2+FileInfo1, Ptr, FileInfo2)
    DllCall("GlobalUnlock", Ptr, hData)
    DllCall("ole32\CreateStreamOnHGlobal", Ptr, hData, "int", 1, A_PtrSize ? "UPtr*" : "UInt*", pStream)
    DllCall("gdiplus\GdipCreateBitmapFromStream", Ptr, pStream, A_PtrSize ? "UPtr*" : "UInt*", pBitmap)
    If (A_PtrSize)
      %FName%(pStream)
    Else
      DllCall(NumGet(NumGet(1*pStream)+8), "uint", pStream)
    return pBitmap
  }

  ;#####################################################################################

  ; Function        Gdip_DrawRectangle
  ; Description      This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x            x-coordinate of the top left of the rectangle
  ; y            y-coordinate of the top left of the rectangle
  ; w            width of the rectanlge
  ; h            height of the rectangle
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawRoundedRectangle
  ; Description      This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x            x-coordinate of the top left of the rounded rectangle
  ; y            y-coordinate of the top left of the rounded rectangle
  ; w            width of the rectanlge
  ; h            height of the rectangle
  ; r            radius of the rounded corners
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
  {
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
    Gdip_ResetClip(pGraphics)
    Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
    Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
    Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
    Gdip_ResetClip(pGraphics)
    return E
  }

  ;#####################################################################################

  ; Function        Gdip_DrawEllipse
  ; Description      This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x            x-coordinate of the top left of the rectangle the ellipse will be drawn into
  ; y            y-coordinate of the top left of the rectangle the ellipse will be drawn into
  ; w            width of the ellipse
  ; h            height of the ellipse
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawBezier
  ; Description      This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x1          x-coordinate of the start of the bezier
  ; y1          y-coordinate of the start of the bezier
  ; x2          x-coordinate of the first arc of the bezier
  ; y2          y-coordinate of the first arc of the bezier
  ; x3          x-coordinate of the second arc of the bezier
  ; y3          y-coordinate of the second arc of the bezier
  ; x4          x-coordinate of the end of the bezier
  ; y4          y-coordinate of the end of the bezier
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawBezier"
            , Ptr, pgraphics
            , Ptr, pPen
            , "float", x1
            , "float", y1
            , "float", x2
            , "float", y2
            , "float", x3
            , "float", y3
            , "float", x4
            , "float", y4)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawArc
  ; Description      This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x            x-coordinate of the start of the arc
  ; y            y-coordinate of the start of the arc
  ; w            width of the arc
  ; h            height of the arc
  ; StartAngle      specifies the angle between the x-axis and the starting point of the arc
  ; SweepAngle      specifies the angle between the starting and ending points of the arc
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawArc"
            , Ptr, pGraphics
            , Ptr, pPen
            , "float", x
            , "float", y
            , "float", w
            , "float", h
            , "float", StartAngle
            , "float", SweepAngle)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawPie
  ; Description      This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x            x-coordinate of the start of the pie
  ; y            y-coordinate of the start of the pie
  ; w            width of the pie
  ; h            height of the pie
  ; StartAngle      specifies the angle between the x-axis and the starting point of the pie
  ; SweepAngle      specifies the angle between the starting and ending points of the pie
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

  Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawPie", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawLine
  ; Description      This function uses a pen to draw a line into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; x1          x-coordinate of the start of the line
  ; y1          y-coordinate of the start of the line
  ; x2          x-coordinate of the end of the line
  ; y2          y-coordinate of the end of the line
  ;
  ; return        status enumeration. 0 = success    

  Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipDrawLine"
            , Ptr, pGraphics
            , Ptr, pPen
            , "float", x1
            , "float", y1
            , "float", x2
            , "float", y2)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawLines
  ; Description      This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pPen          Pointer to a pen
  ; Points        the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
  ;
  ; return        status enumeration. 0 = success        

  Gdip_DrawLines(pGraphics, pPen, Points)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0)   
    Loop, %Points0%
    {
      StringSplit, Coord, Points%A_Index%, `,
      NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }
    return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointF, "int", Points0)
  }

  ;#####################################################################################

  ; Function        Gdip_FillRectangle
  ; Description      This function uses a brush to fill a rectangle in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; x            x-coordinate of the top left of the rectangle
  ; y            y-coordinate of the top left of the rectangle
  ; w            width of the rectanlge
  ; h            height of the rectangle
  ;
  ; return        status enumeration. 0 = success

  Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipFillRectangle"
            , Ptr, pGraphics
            , Ptr, pBrush
            , "float", x
            , "float", y
            , "float", w
            , "float", h)
  }

  ;#####################################################################################

  ; Function        Gdip_FillRoundedRectangle
  ; Description      This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; x            x-coordinate of the top left of the rounded rectangle
  ; y            y-coordinate of the top left of the rounded rectangle
  ; w            width of the rectanlge
  ; h            height of the rectangle
  ; r            radius of the rounded corners
  ;
  ; return        status enumeration. 0 = success

  Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
  {
    Region := Gdip_GetClipRegion(pGraphics)
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
    Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
    Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_DeleteRegion(Region)
    return E
  }

  ;#####################################################################################

  ; Function        Gdip_FillPolygon
  ; Description      This function uses a brush to fill a polygon in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; Points        the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
  ; Alternate       = 0
  ; Winding         = 1

  Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0)   
    Loop, %Points0%
    {
      StringSplit, Coord, Points%A_Index%, `,
      NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }   
    return DllCall("gdiplus\GdipFillPolygon", Ptr, pGraphics, Ptr, pBrush, Ptr, &PointF, "int", Points0, "int", FillMode)
  }

  ;#####################################################################################

  ; Function        Gdip_FillPie
  ; Description      This function uses a brush to fill a pie in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; x            x-coordinate of the top left of the pie
  ; y            y-coordinate of the top left of the pie
  ; w            width of the pie
  ; h            height of the pie
  ; StartAngle      specifies the angle between the x-axis and the starting point of the pie
  ; SweepAngle      specifies the angle between the starting and ending points of the pie
  ;
  ; return        status enumeration. 0 = success

  Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipFillPie"
            , Ptr, pGraphics
            , Ptr, pBrush
            , "float", x
            , "float", y
            , "float", w
            , "float", h
            , "float", StartAngle
            , "float", SweepAngle)
  }

  ;#####################################################################################

  ; Function        Gdip_FillEllipse
  ; Description      This function uses a brush to fill an ellipse in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; x            x-coordinate of the top left of the ellipse
  ; y            y-coordinate of the top left of the ellipse
  ; w            width of the ellipse
  ; h            height of the ellipse
  ;
  ; return        status enumeration. 0 = success

  Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
  }

  ;#####################################################################################

  ; Function        Gdip_FillRegion
  ; Description      This function uses a brush to fill a region in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; Region        Pointer to a Region
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          You can create a region Gdip_CreateRegion() and then add to this

  Gdip_FillRegion(pGraphics, pBrush, Region)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipFillRegion", Ptr, pGraphics, Ptr, pBrush, Ptr, Region)
  }

  ;#####################################################################################

  ; Function        Gdip_FillPath
  ; Description      This function uses a brush to fill a path in the Graphics of a bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBrush        Pointer to a brush
  ; Region        Pointer to a Path
  ;
  ; return        status enumeration. 0 = success

  Gdip_FillPath(pGraphics, pBrush, Path)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, Path)
  }

  ;#####################################################################################

  ; Function        Gdip_DrawImagePointsRect
  ; Description      This function draws a bitmap into the Graphics of another bitmap and skews it
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBitmap        Pointer to a bitmap to be drawn
  ; Points        Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
  ; sx          x-coordinate of source upper-left corner
  ; sy          y-coordinate of source upper-left corner
  ; sw          width of source rectangle
  ; sh          height of source rectangle
  ; Matrix        a matrix used to alter image attributes when drawing
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          if sx,sy,sw,sh are missed then the entire source bitmap will be used
  ;            Matrix can be omitted to just draw with no alteration to ARGB
  ;            Matrix may be passed as a digit from 0 - 1 to change just transparency
  ;            Matrix can be passed as a matrix with any delimiter

  Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0)   
    Loop, %Points0%
    {
      StringSplit, Coord, Points%A_Index%, `,
      NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }

    if (Matrix&1 = "")
      ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
    else if (Matrix != 1)
      ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
      
    if (sx = "" && sy = "" && sw = "" && sh = "")
    {
      sx := 0, sy := 0
      sw := Gdip_GetImageWidth(pBitmap)
      sh := Gdip_GetImageHeight(pBitmap)
    }

    E := DllCall("gdiplus\GdipDrawImagePointsRect"
          , Ptr, pGraphics
          , Ptr, pBitmap
          , Ptr, &PointF
          , "int", Points0
          , "float", sx
          , "float", sy
          , "float", sw
          , "float", sh
          , "int", 2
          , Ptr, ImageAttr
          , Ptr, 0
          , Ptr, 0)
    if ImageAttr
      Gdip_DisposeImageAttributes(ImageAttr)
    return E
  }

  ;#####################################################################################

  ; Function        Gdip_DrawImage
  ; Description      This function draws a bitmap into the Graphics of another bitmap
  ;
  ; pGraphics        Pointer to the Graphics of a bitmap
  ; pBitmap        Pointer to a bitmap to be drawn
  ; dx          x-coord of destination upper-left corner
  ; dy          y-coord of destination upper-left corner
  ; dw          width of destination image
  ; dh          height of destination image
  ; sx          x-coordinate of source upper-left corner
  ; sy          y-coordinate of source upper-left corner
  ; sw          width of source image
  ; sh          height of source image
  ; Matrix        a matrix used to alter image attributes when drawing
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          if sx,sy,sw,sh are missed then the entire source bitmap will be used
  ;            Gdip_DrawImage performs faster
  ;            Matrix can be omitted to just draw with no alteration to ARGB
  ;            Matrix may be passed as a digit from 0 - 1 to change just transparency
  ;            Matrix can be passed as a matrix with any delimiter. For example:
  ;            MatrixBright=
  ;            (
  ;            1.5    |0    |0    |0    |0
  ;            0    |1.5  |0    |0    |0
  ;            0    |0    |1.5  |0    |0
  ;            0    |0    |0    |1    |0
  ;            0.05  |0.05  |0.05  |0    |1
  ;            )
  ;
  ; notes          MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
  ;            MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
  ;            MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

  Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if (Matrix&1 = "")
      ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
    else if (Matrix != 1)
      ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

    if (sx = "" && sy = "" && sw = "" && sh = "")
    {
      if (dx = "" && dy = "" && dw = "" && dh = "")
      {
        sx := dx := 0, sy := dy := 0
        sw := dw := Gdip_GetImageWidth(pBitmap)
        sh := dh := Gdip_GetImageHeight(pBitmap)
      }
      else
      {
        sx := sy := 0
        sw := Gdip_GetImageWidth(pBitmap)
        sh := Gdip_GetImageHeight(pBitmap)
      }
    }

    E := DllCall("gdiplus\GdipDrawImageRectRect"
          , Ptr, pGraphics
          , Ptr, pBitmap
          , "float", dx
          , "float", dy
          , "float", dw
          , "float", dh
          , "float", sx
          , "float", sy
          , "float", sw
          , "float", sh
          , "int", 2
          , Ptr, ImageAttr
          , Ptr, 0
          , Ptr, 0)
    if ImageAttr
      Gdip_DisposeImageAttributes(ImageAttr)
    return E
  }

  ;#####################################################################################

  ; Function        Gdip_SetImageAttributesColorMatrix
  ; Description      This function creates an image matrix ready for drawing
  ;
  ; Matrix        a matrix used to alter image attributes when drawing
  ;            passed with any delimeter
  ;
  ; return        returns an image matrix on sucess or 0 if it fails
  ;
  ; notes          MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
  ;            MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
  ;            MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

  Gdip_SetImageAttributesColorMatrix(Matrix)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    VarSetCapacity(ColourMatrix, 100, 0)
    Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
    StringSplit, Matrix, Matrix, |
    Loop, 25
    {
      Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
      NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
    }
    DllCall("gdiplus\GdipCreateImageAttributes", A_PtrSize ? "UPtr*" : "uint*", ImageAttr)
    DllCall("gdiplus\GdipSetImageAttributesColorMatrix", Ptr, ImageAttr, "int", 1, "int", 1, Ptr, &ColourMatrix, Ptr, 0, "int", 0)
    return ImageAttr
  }

  ;#####################################################################################

  ; Function        Gdip_GraphicsFromImage
  ; Description      This function gets the graphics for a bitmap used for drawing functions
  ;
  ; pBitmap        Pointer to a bitmap to get the pointer to its graphics
  ;
  ; return        returns a pointer to the graphics of a bitmap
  ;
  ; notes          a bitmap can be drawn into the graphics of another bitmap

  Gdip_GraphicsFromImage(pBitmap)
  {
    DllCall("gdiplus\GdipGetImageGraphicsContext", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
    return pGraphics
  }

  ;#####################################################################################

  ; Function        Gdip_GraphicsFromHDC
  ; Description      This function gets the graphics from the handle to a device context
  ;
  ; hdc          This is the handle to the device context
  ;
  ; return        returns a pointer to the graphics of a bitmap
  ;
  ; notes          You can draw a bitmap into the graphics of another bitmap

  Gdip_GraphicsFromHDC(hdc)
  {
    DllCall("gdiplus\GdipCreateFromHDC", A_PtrSize ? "UPtr" : "UInt", hdc, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
    return pGraphics
  }

  ;#####################################################################################

  ; Function        Gdip_GetDC
  ; Description      This function gets the device context of the passed Graphics
  ;
  ; hdc          This is the handle to the device context
  ;
  ; return        returns the device context for the graphics of a bitmap

  Gdip_GetDC(pGraphics)
  {
    DllCall("gdiplus\GdipGetDC", A_PtrSize ? "UPtr" : "UInt", pGraphics, A_PtrSize ? "UPtr*" : "UInt*", hdc)
    return hdc
  }

  ;#####################################################################################

  ; Function        Gdip_ReleaseDC
  ; Description      This function releases a device context from use for further use
  ;
  ; pGraphics        Pointer to the graphics of a bitmap
  ; hdc          This is the handle to the device context
  ;
  ; return        status enumeration. 0 = success

  Gdip_ReleaseDC(pGraphics, hdc)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipReleaseDC", Ptr, pGraphics, Ptr, hdc)
  }

  ;#####################################################################################

  ; Function        Gdip_GraphicsClear
  ; Description      Clears the graphics of a bitmap ready for further drawing
  ;
  ; pGraphics        Pointer to the graphics of a bitmap
  ; ARGB          The colour to clear the graphics to
  ;
  ; return        status enumeration. 0 = success
  ;
  ; notes          By default this will make the background invisible
  ;            Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

  Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
  {
    return DllCall("gdiplus\GdipGraphicsClear", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", ARGB)
  }

  ;#####################################################################################

  ; Function        Gdip_BlurBitmap
  ; Description      Gives a pointer to a blurred bitmap from a pointer to a bitmap
  ;
  ; pBitmap        Pointer to a bitmap to be blurred
  ; Blur          The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
  ;
  ; return        If the function succeeds, the return value is a pointer to the new blurred bitmap
  ;            -1 = The blur parameter is outside the range 1-100
  ;
  ; notes          This function will not dispose of the original bitmap

  Gdip_BlurBitmap(pBitmap, Blur)
  {
    if (Blur > 100) || (Blur < 1)
      return -1  
    
    sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
    dWidth := sWidth//Blur, dHeight := sHeight//Blur

    pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
    G1 := Gdip_GraphicsFromImage(pBitmap1)
    Gdip_SetInterpolationMode(G1, 7)
    Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)

    Gdip_DeleteGraphics(G1)

    pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
    G2 := Gdip_GraphicsFromImage(pBitmap2)
    Gdip_SetInterpolationMode(G2, 7)
    Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)

    Gdip_DeleteGraphics(G2)
    Gdip_DisposeImage(pBitmap1)
    return pBitmap2
  }

  ;#####################################################################################

  ; Function:       Gdip_SaveBitmapToFile
  ; Description:      Saves a bitmap to a file in any supported format onto disk
  ;   
  ; pBitmap        Pointer to a bitmap
  ; sOutput          The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
  ; Quality          If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
  ;
  ; return          If the function succeeds, the return value is zero, otherwise:
  ;            -1 = Extension supplied is not a supported file format
  ;            -2 = Could not get a list of encoders on system
  ;            -3 = Could not find matching encoder for specified file format
  ;            -4 = Could not get WideChar name of output file
  ;            -5 = Could not save file to disk
  ;
  ; notes          This function will use the extension supplied from the sOutput parameter to determine the output format

  Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    SplitPath, sOutput,,, Extension
    if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
      return -1
    Extension := "." Extension

    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
    if !(nCount && nSize)
      return -2
    
    If (A_IsUnicode){
      StrGet_Name := "StrGet"
      Loop, %nCount%
      {
        sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
        if !InStr(sString, "*" Extension)
          continue
        
        pCodec := &ci+idx
        break
      }
    } else {
      Loop, %nCount%
      {
        Location := NumGet(ci, 76*(A_Index-1)+44)
        nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
        VarSetCapacity(sString, nSize)
        DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
        if !InStr(sString, "*" Extension)
          continue
        
        pCodec := &ci+76*(A_Index-1)
        break
      }
    }
    
    if !pCodec
      return -3

    if (Quality != 75)
    {
      Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
      if Extension in .JPG,.JPEG,.JPE,.JFIF
      {
        DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
        VarSetCapacity(EncoderParameters, nSize, 0)
        DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
        Loop, % NumGet(EncoderParameters, "UInt")    ;%
        {
          elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
          if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
          {
            p := elem+&EncoderParameters-pad-4
            NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
            break
          }
        }    
      }
    }

    if (!A_IsUnicode)
    {
      nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0)
      VarSetCapacity(wOutput, nSize*2)
      DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize)
      VarSetCapacity(wOutput, -1)
      if !VarSetCapacity(wOutput)
        return -4
      E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", p ? p : 0)
    }
    else
      E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", p ? p : 0)
    return E ? -5 : 0
  }

  ;#####################################################################################

  ; Function        Gdip_GetPixel
  ; Description      Gets the ARGB of a pixel in a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ; x            x-coordinate of the pixel
  ; y            y-coordinate of the pixel
  ;
  ; return        Returns the ARGB value of the pixel

  Gdip_GetPixel(pBitmap, x, y)
  {
    DllCall("gdiplus\GdipBitmapGetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "uint*", ARGB)
    return ARGB
  }

  ;#####################################################################################

  ; Function        Gdip_SetPixel
  ; Description      Sets the ARGB of a pixel in a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ; x            x-coordinate of the pixel
  ; y            y-coordinate of the pixel
  ;
  ; return        status enumeration. 0 = success

  Gdip_SetPixel(pBitmap, x, y, ARGB)
  {
  return DllCall("gdiplus\GdipBitmapSetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "int", ARGB)
  }

  ;#####################################################################################

  ; Function        Gdip_GetImageWidth
  ; Description      Gives the width of a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ;
  ; return        Returns the width in pixels of the supplied bitmap

  Gdip_GetImageWidth(pBitmap)
  {
  DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
  return Width
  }

  ;#####################################################################################

  ; Function        Gdip_GetImageHeight
  ; Description      Gives the height of a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ;
  ; return        Returns the height in pixels of the supplied bitmap

  Gdip_GetImageHeight(pBitmap)
  {
  DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
  return Height
  }

  ;#####################################################################################

  ; Function        Gdip_GetDimensions
  ; Description      Gives the width and height of a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ; Width          ByRef variable. This variable will be set to the width of the bitmap
  ; Height        ByRef variable. This variable will be set to the height of the bitmap
  ;
  ; return        No return value
  ;            Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

  Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    DllCall("gdiplus\GdipGetImageWidth", Ptr, pBitmap, "uint*", Width)
    DllCall("gdiplus\GdipGetImageHeight", Ptr, pBitmap, "uint*", Height)
  }

  ;#####################################################################################

  Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
  {
    Gdip_GetImageDimensions(pBitmap, Width, Height)
  }

  ;#####################################################################################

  Gdip_GetImagePixelFormat(pBitmap)
  {
    DllCall("gdiplus\GdipGetImagePixelFormat", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", Format)
    return Format
  }

  ;#####################################################################################

  ; Function        Gdip_GetDpiX
  ; Description      Gives the horizontal dots per inch of the graphics of a bitmap
  ;
  ; pBitmap        Pointer to a bitmap
  ; Width          ByRef variable. This variable will be set to the width of the bitmap
  ; Height        ByRef variable. This variable will be set to the height of the bitmap
  ;
  ; return        No return value
  ;            Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

  Gdip_GetDpiX(pGraphics)
  {
    DllCall("gdiplus\GdipGetDpiX", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpix)
    return Round(dpix)
  }

  ;#####################################################################################

  Gdip_GetDpiY(pGraphics)
  {
    DllCall("gdiplus\GdipGetDpiY", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpiy)
    return Round(dpiy)
  }

  ;#####################################################################################

  Gdip_GetImageHorizontalResolution(pBitmap)
  {
    DllCall("gdiplus\GdipGetImageHorizontalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpix)
    return Round(dpix)
  }

  ;#####################################################################################

  Gdip_GetImageVerticalResolution(pBitmap)
  {
    DllCall("gdiplus\GdipGetImageVerticalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpiy)
    return Round(dpiy)
  }

  ;#####################################################################################

  Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
  {
    return DllCall("gdiplus\GdipBitmapSetResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float", dpix, "float", dpiy)
  }

  ;#####################################################################################

  Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    , PtrA := A_PtrSize ? "UPtr*" : "UInt*"
    
    SplitPath, sFile,,, ext
    if ext in exe,dll
    {
      Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
      BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))
      
      VarSetCapacity(buf, BufSize, 0)
      Loop, Parse, Sizes, |
      {
        DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", A_LoopField, "int", A_LoopField, PtrA, hIcon, PtrA, 0, "uint", 1, "uint", 0)
        
        if !hIcon
          continue

        if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, &buf)
        {
          DestroyIcon(hIcon)
          continue
        }
        
        hbmMask  := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
        hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
        if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, &buf))
        {
          DestroyIcon(hIcon)
          continue
        }
        break
      }
      if !hIcon
        return -1

      Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
      hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
      if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
      {
        DestroyIcon(hIcon)
        return -2
      }
      
      VarSetCapacity(dib, 104)
      DllCall("GetObject", Ptr, hbm, "int", A_PtrSize = 8 ? 104 : 84, Ptr, &dib) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
      Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0)) ; padding
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, Ptr, Bits, PtrA, pBitmapOld)
      pBitmap := Gdip_CreateBitmap(Width, Height)
      G := Gdip_GraphicsFromImage(pBitmap)
      , Gdip_DrawImage(G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
      SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
      Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapOld)
      DestroyIcon(hIcon)
    }
    else
    {
      if (!A_IsUnicode)
      {
        VarSetCapacity(wFile, 1024)
        DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sFile, "int", -1, Ptr, &wFile, "int", 512)
        DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &wFile, PtrA, pBitmap)
      }
      else
        DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &sFile, PtrA, pBitmap)
    }
    
    return pBitmap
  }

  ;#####################################################################################

  Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    return pBitmap
  }

  ;#####################################################################################

  Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
  {
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hbm, "int", Background)
    return hbm
  }

  ;#####################################################################################

  Gdip_CreateBitmapFromHICON(hIcon)
  {
    DllCall("gdiplus\GdipCreateBitmapFromHICON", A_PtrSize ? "UPtr" : "UInt", hIcon, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    return pBitmap
  }

  ;#####################################################################################

  Gdip_CreateHICONFromBitmap(pBitmap)
  {
    DllCall("gdiplus\GdipCreateHICONFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hIcon)
    return hIcon
  }

  ;#####################################################################################

  Gdip_CreateBitmap(Width, Height, Format=0x26200A)
  {
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, A_PtrSize ? "UPtr" : "UInt", 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    Return pBitmap
  }

  ;#####################################################################################

  Gdip_CreateBitmapFromClipboard()
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if !DllCall("OpenClipboard", Ptr, 0)
      return -1
    if !DllCall("IsClipboardFormatAvailable", "uint", 8)
      return -2
    if !hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
      return -3
    if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
      return -4
    if !DllCall("CloseClipboard")
      return -5
    DeleteObject(hBitmap)
    return pBitmap
  }

  ;#####################################################################################

  Gdip_SetBitmapToClipboard(pBitmap)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
    hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
    pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
    DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
    DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), Ptr), Ptr, NumGet(oi, off1, "UInt"))
    DllCall("GlobalUnlock", Ptr, hdib)
    DllCall("DeleteObject", Ptr, hBitmap)
    DllCall("OpenClipboard", Ptr, 0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 8, Ptr, hdib)
    DllCall("CloseClipboard")
  }

  ;#####################################################################################

  Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
  {
    DllCall("gdiplus\GdipCloneBitmapArea"
            , "float", x
            , "float", y
            , "float", w
            , "float", h
            , "int", Format
            , A_PtrSize ? "UPtr" : "UInt", pBitmap
            , A_PtrSize ? "UPtr*" : "UInt*", pBitmapDest)
    return pBitmapDest
  }

  ;#####################################################################################
  ; Create resources
  ;#####################################################################################

  Gdip_CreatePen(ARGB, w)
  {
  DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
  return pPen
  }

  ;#####################################################################################

  Gdip_CreatePenFromBrush(pBrush, w)
  {
    DllCall("gdiplus\GdipCreatePen2", A_PtrSize ? "UPtr" : "UInt", pBrush, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
    return pPen
  }

  ;#####################################################################################

  Gdip_BrushCreateSolid(ARGB=0xff000000)
  {
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
    return pBrush
  }

  ;#####################################################################################

  ; HatchStyleHorizontal = 0
  ; HatchStyleVertical = 1
  ; HatchStyleForwardDiagonal = 2
  ; HatchStyleBackwardDiagonal = 3
  ; HatchStyleCross = 4
  ; HatchStyleDiagonalCross = 5
  ; HatchStyle05Percent = 6
  ; HatchStyle10Percent = 7
  ; HatchStyle20Percent = 8
  ; HatchStyle25Percent = 9
  ; HatchStyle30Percent = 10
  ; HatchStyle40Percent = 11
  ; HatchStyle50Percent = 12
  ; HatchStyle60Percent = 13
  ; HatchStyle70Percent = 14
  ; HatchStyle75Percent = 15
  ; HatchStyle80Percent = 16
  ; HatchStyle90Percent = 17
  ; HatchStyleLightDownwardDiagonal = 18
  ; HatchStyleLightUpwardDiagonal = 19
  ; HatchStyleDarkDownwardDiagonal = 20
  ; HatchStyleDarkUpwardDiagonal = 21
  ; HatchStyleWideDownwardDiagonal = 22
  ; HatchStyleWideUpwardDiagonal = 23
  ; HatchStyleLightVertical = 24
  ; HatchStyleLightHorizontal = 25
  ; HatchStyleNarrowVertical = 26
  ; HatchStyleNarrowHorizontal = 27
  ; HatchStyleDarkVertical = 28
  ; HatchStyleDarkHorizontal = 29
  ; HatchStyleDashedDownwardDiagonal = 30
  ; HatchStyleDashedUpwardDiagonal = 31
  ; HatchStyleDashedHorizontal = 32
  ; HatchStyleDashedVertical = 33
  ; HatchStyleSmallConfetti = 34
  ; HatchStyleLargeConfetti = 35
  ; HatchStyleZigZag = 36
  ; HatchStyleWave = 37
  ; HatchStyleDiagonalBrick = 38
  ; HatchStyleHorizontalBrick = 39
  ; HatchStyleWeave = 40
  ; HatchStylePlaid = 41
  ; HatchStyleDivot = 42
  ; HatchStyleDottedGrid = 43
  ; HatchStyleDottedDiamond = 44
  ; HatchStyleShingle = 45
  ; HatchStyleTrellis = 46
  ; HatchStyleSphere = 47
  ; HatchStyleSmallGrid = 48
  ; HatchStyleSmallCheckerBoard = 49
  ; HatchStyleLargeCheckerBoard = 50
  ; HatchStyleOutlinedDiamond = 51
  ; HatchStyleSolidDiamond = 52
  ; HatchStyleTotal = 53
  Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
  {
    DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
    return pBrush
  }

  ;#####################################################################################

  Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    , PtrA := A_PtrSize ? "UPtr*" : "UInt*"
    
    if !(w && h)
      DllCall("gdiplus\GdipCreateTexture", Ptr, pBitmap, "int", WrapMode, PtrA, pBrush)
    else
      DllCall("gdiplus\GdipCreateTexture2", Ptr, pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
    return pBrush
  }

  ;#####################################################################################

  ; WrapModeTile = 0
  ; WrapModeTileFlipX = 1
  ; WrapModeTileFlipY = 2
  ; WrapModeTileFlipXY = 3
  ; WrapModeClamp = 4
  Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
    DllCall("gdiplus\GdipCreateLineBrush", Ptr, &PointF1, Ptr, &PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
    return LGpBrush
  }

  ;#####################################################################################

  ; LinearGradientModeHorizontal = 0
  ; LinearGradientModeVertical = 1
  ; LinearGradientModeForwardDiagonal = 2
  ; LinearGradientModeBackwardDiagonal = 3
  Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
  {
    CreateRectF(RectF, x, y, w, h)
    DllCall("gdiplus\GdipCreateLineBrushFromRect", A_PtrSize ? "UPtr" : "UInt", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
    return LGpBrush
  }

  ;#####################################################################################

  Gdip_CloneBrush(pBrush)
  {
    DllCall("gdiplus\GdipCloneBrush", A_PtrSize ? "UPtr" : "UInt", pBrush, A_PtrSize ? "UPtr*" : "UInt*", pBrushClone)
    return pBrushClone
  }

  ;#####################################################################################
  ; Delete resources
  ;#####################################################################################

  Gdip_DeletePen(pPen)
  {
  return DllCall("gdiplus\GdipDeletePen", A_PtrSize ? "UPtr" : "UInt", pPen)
  }

  ;#####################################################################################

  Gdip_DeleteBrush(pBrush)
  {
  return DllCall("gdiplus\GdipDeleteBrush", A_PtrSize ? "UPtr" : "UInt", pBrush)
  }

  ;#####################################################################################

  Gdip_DisposeImage(pBitmap)
  {
  return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
  }

  ;#####################################################################################

  Gdip_DeleteGraphics(pGraphics)
  {
  return DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)
  }

  ;#####################################################################################

  Gdip_DisposeImageAttributes(ImageAttr)
  {
    return DllCall("gdiplus\GdipDisposeImageAttributes", A_PtrSize ? "UPtr" : "UInt", ImageAttr)
  }

  ;#####################################################################################

  Gdip_DeleteFont(hFont)
  {
  return DllCall("gdiplus\GdipDeleteFont", A_PtrSize ? "UPtr" : "UInt", hFont)
  }

  ;#####################################################################################

  Gdip_DeleteStringFormat(hFormat)
  {
  return DllCall("gdiplus\GdipDeleteStringFormat", A_PtrSize ? "UPtr" : "UInt", hFormat)
  }

  ;#####################################################################################

  Gdip_DeleteFontFamily(hFamily)
  {
  return DllCall("gdiplus\GdipDeleteFontFamily", A_PtrSize ? "UPtr" : "UInt", hFamily)
  }

  ;#####################################################################################

  Gdip_DeleteMatrix(Matrix)
  {
  return DllCall("gdiplus\GdipDeleteMatrix", A_PtrSize ? "UPtr" : "UInt", Matrix)
  }

  ;#####################################################################################
  ; Text functions
  ;#####################################################################################

  Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
  {
    IWidth := Width, IHeight:= Height
    
    RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
    RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
    RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
    RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
    RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
    RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
    RegExMatch(Options, "i)NoWrap", NoWrap)
    RegExMatch(Options, "i)R(\d)", Rendering)
    RegExMatch(Options, "i)S(\d+)(p*)", Size)

    if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
      PassBrush := 1, pBrush := Colour2
    
    if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
      return -1

    Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
    Loop, Parse, Styles, |
    {
      if RegExMatch(Options, "\b" A_loopField)
      Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
    }
  
    Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
    Loop, Parse, Alignments, |
    {
      if RegExMatch(Options, "\b" A_loopField)
        Align |= A_Index//2.1    ; 0|0|1|1|2|2
    }

    xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
    ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
    Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
    Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
    if !PassBrush
      Colour := "0x" (Colour2 ? Colour2 : "ff000000")
    Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
    Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12

    hFamily := Gdip_FontFamilyCreate(Font)
    hFont := Gdip_FontCreate(hFamily, Size, Style)
    FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
    hFormat := Gdip_StringFormatCreate(FormatStyle)
    pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
    if !(hFamily && hFont && hFormat && pBrush && pGraphics)
      return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
  
    CreateRectF(RC, xpos, ypos, Width, Height)
    Gdip_SetStringFormatAlign(hFormat, Align)
    Gdip_SetTextRenderingHint(pGraphics, Rendering)
    ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

    if vPos
    {
      StringSplit, ReturnRC, ReturnRC, |
      
      if (vPos = "vCentre") || (vPos = "vCenter")
        ypos += (Height-ReturnRC4)//2
      else if (vPos = "Top") || (vPos = "Up")
        ypos := 0
      else if (vPos = "Bottom") || (vPos = "Down")
        ypos := Height-ReturnRC4
      
      CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
      ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
    }

    if !Measure
      E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)

    if !PassBrush
      Gdip_DeleteBrush(pBrush)
    Gdip_DeleteStringFormat(hFormat)   
    Gdip_DeleteFont(hFont)
    Gdip_DeleteFontFamily(hFamily)
    return E ? E : ReturnRC
  }

  ;#####################################################################################

  Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if (!A_IsUnicode)
    {
      nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
      VarSetCapacity(wString, nSize*2)
      DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
    }
    
    return DllCall("gdiplus\GdipDrawString"
            , Ptr, pGraphics
            , Ptr, A_IsUnicode ? &sString : &wString
            , "int", -1
            , Ptr, hFont
            , Ptr, &RectF
            , Ptr, hFormat
            , Ptr, pBrush)
  }

  ;#####################################################################################

  Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    VarSetCapacity(RC, 16)
    if !A_IsUnicode
    {
      nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, "uint", 0, "int", 0)
      VarSetCapacity(wString, nSize*2)   
      DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
    }
    
    DllCall("gdiplus\GdipMeasureString"
            , Ptr, pGraphics
            , Ptr, A_IsUnicode ? &sString : &wString
            , "int", -1
            , Ptr, hFont
            , Ptr, &RectF
            , Ptr, hFormat
            , Ptr, &RC
            , "uint*", Chars
            , "uint*", Lines)
    
    return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
  }

  ; Near = 0
  ; Center = 1
  ; Far = 2
  Gdip_SetStringFormatAlign(hFormat, Align)
  {
  return DllCall("gdiplus\GdipSetStringFormatAlign", A_PtrSize ? "UPtr" : "UInt", hFormat, "int", Align)
  }

  ; StringFormatFlagsDirectionRightToLeft  = 0x00000001
  ; StringFormatFlagsDirectionVertical     = 0x00000002
  ; StringFormatFlagsNoFitBlackBox       = 0x00000004
  ; StringFormatFlagsDisplayFormatControl  = 0x00000020
  ; StringFormatFlagsNoFontFallback      = 0x00000400
  ; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
  ; StringFormatFlagsNoWrap          = 0x00001000
  ; StringFormatFlagsLineLimit         = 0x00002000
  ; StringFormatFlagsNoClip          = 0x00004000 
  Gdip_StringFormatCreate(Format=0, Lang=0)
  {
  DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
  return hFormat
  }

  ; Regular = 0
  ; Bold = 1
  ; Italic = 2
  ; BoldItalic = 3
  ; Underline = 4
  ; Strikeout = 8
  Gdip_FontCreate(hFamily, Size, Style=0)
  {
  DllCall("gdiplus\GdipCreateFont", A_PtrSize ? "UPtr" : "UInt", hFamily, "float", Size, "int", Style, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFont)
  return hFont
  }

  Gdip_FontFamilyCreate(Font)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if (!A_IsUnicode)
    {
      nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, "uint", 0, "int", 0)
      VarSetCapacity(wFont, nSize*2)
      DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, Ptr, &wFont, "int", nSize)
    }
    
    DllCall("gdiplus\GdipCreateFontFamilyFromName"
            , Ptr, A_IsUnicode ? &Font : &wFont
            , "uint", 0
            , A_PtrSize ? "UPtr*" : "UInt*", hFamily)
    
    return hFamily
  }

  ;#####################################################################################
  ; Matrix functions
  ;#####################################################################################

  Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
  {
  DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, A_PtrSize ? "UPtr*" : "UInt*", Matrix)
  return Matrix
  }

  Gdip_CreateMatrix()
  {
  DllCall("gdiplus\GdipCreateMatrix", A_PtrSize ? "UPtr*" : "UInt*", Matrix)
  return Matrix
  }

  ;#####################################################################################
  ; GraphicsPath functions
  ;#####################################################################################

  ; Alternate = 0
  ; Winding = 1
  Gdip_CreatePath(BrushMode=0)
  {
    DllCall("gdiplus\GdipCreatePath", "int", BrushMode, A_PtrSize ? "UPtr*" : "UInt*", Path)
    return Path
  }

  Gdip_AddPathEllipse(Path, x, y, w, h)
  {
    return DllCall("gdiplus\GdipAddPathEllipse", A_PtrSize ? "UPtr" : "UInt", Path, "float", x, "float", y, "float", w, "float", h)
  }

  Gdip_AddPathPolygon(Path, Points)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0)   
    Loop, %Points0%
    {
      StringSplit, Coord, Points%A_Index%, `,
      NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }   

    return DllCall("gdiplus\GdipAddPathPolygon", Ptr, Path, Ptr, &PointF, "int", Points0)
  }

  Gdip_DeletePath(Path)
  {
    return DllCall("gdiplus\GdipDeletePath", A_PtrSize ? "UPtr" : "UInt", Path)
  }

  ;#####################################################################################
  ; Quality functions
  ;#####################################################################################

  ; SystemDefault = 0
  ; SingleBitPerPixelGridFit = 1
  ; SingleBitPerPixel = 2
  ; AntiAliasGridFit = 3
  ; AntiAlias = 4
  Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
  {
    return DllCall("gdiplus\GdipSetTextRenderingHint", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", RenderingHint)
  }

  ; Default = 0
  ; LowQuality = 1
  ; HighQuality = 2
  ; Bilinear = 3
  ; Bicubic = 4
  ; NearestNeighbor = 5
  ; HighQualityBilinear = 6
  ; HighQualityBicubic = 7
  Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
  {
  return DllCall("gdiplus\GdipSetInterpolationMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", InterpolationMode)
  }

  ; Default = 0
  ; HighSpeed = 1
  ; HighQuality = 2
  ; None = 3
  ; AntiAlias = 4
  Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
  {
  return DllCall("gdiplus\GdipSetSmoothingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", SmoothingMode)
  }

  ; CompositingModeSourceOver = 0 (blended)
  ; CompositingModeSourceCopy = 1 (overwrite)
  Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
  {
  return DllCall("gdiplus\GdipSetCompositingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", CompositingMode)
  }

  ;#####################################################################################
  ; Extra functions
  ;#####################################################################################

  Gdip_Startup()
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
      DllCall("LoadLibrary", "str", "gdiplus")
    VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
    DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
    return pToken
  }

  Gdip_Shutdown(pToken)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
    if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
      DllCall("FreeLibrary", Ptr, hModule)
    return 0
  }

  ; Prepend = 0; The new operation is applied before the old operation.
  ; Append = 1; The new operation is applied after the old operation.
  Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
  {
    return DllCall("gdiplus\GdipRotateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", Angle, "int", MatrixOrder)
  }

  Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
  {
    return DllCall("gdiplus\GdipScaleWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
  }

  Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
  {
    return DllCall("gdiplus\GdipTranslateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
  }

  Gdip_ResetWorldTransform(pGraphics)
  {
    return DllCall("gdiplus\GdipResetWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics)
  }

  Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
  {
    pi := 3.14159, TAngle := Angle*(pi/180)  

    Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
    if ((Bound >= 0) && (Bound <= 90))
      xTranslation := Height*Sin(TAngle), yTranslation := 0
    else if ((Bound > 90) && (Bound <= 180))
      xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
    else if ((Bound > 180) && (Bound <= 270))
      xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
    else if ((Bound > 270) && (Bound <= 360))
      xTranslation := 0, yTranslation := -Width*Sin(TAngle)
  }

  Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
  {
    pi := 3.14159, TAngle := Angle*(pi/180)
    if !(Width && Height)
      return -1
    RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
    RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
  }

  ; RotateNoneFlipNone   = 0
  ; Rotate90FlipNone   = 1
  ; Rotate180FlipNone  = 2
  ; Rotate270FlipNone  = 3
  ; RotateNoneFlipX    = 4
  ; Rotate90FlipX    = 5
  ; Rotate180FlipX     = 6
  ; Rotate270FlipX     = 7
  ; RotateNoneFlipY    = Rotate180FlipX
  ; Rotate90FlipY    = Rotate270FlipX
  ; Rotate180FlipY     = RotateNoneFlipX
  ; Rotate270FlipY     = Rotate90FlipX
  ; RotateNoneFlipXY   = Rotate180FlipNone
  ; Rotate90FlipXY     = Rotate270FlipNone
  ; Rotate180FlipXY    = RotateNoneFlipNone
  ; Rotate270FlipXY    = Rotate90FlipNone 

  Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
  {
    return DllCall("gdiplus\GdipImageRotateFlip", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", RotateFlipType)
  }

  ; Replace = 0
  ; Intersect = 1
  ; Union = 2
  ; Xor = 3
  ; Exclude = 4
  ; Complement = 5
  Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
  {
  return DllCall("gdiplus\GdipSetClipRect",  A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
  }

  Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, Path, "int", CombineMode)
  }

  Gdip_ResetClip(pGraphics)
  {
  return DllCall("gdiplus\GdipResetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics)
  }

  Gdip_GetClipRegion(pGraphics)
  {
    Region := Gdip_CreateRegion()
    DllCall("gdiplus\GdipGetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics, "UInt*", Region)
    return Region
  }

  Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
  }

  Gdip_CreateRegion()
  {
    DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
    return Region
  }

  Gdip_DeleteRegion(Region)
  {
    return DllCall("gdiplus\GdipDeleteRegion", A_PtrSize ? "UPtr" : "UInt", Region)
  }

  ;#####################################################################################
  ; BitmapLockBits
  ;#####################################################################################

  Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    CreateRect(Rect, x, y, w, h)
    VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
    E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
    Stride := NumGet(BitmapData, 8, "Int")
    Scan0 := NumGet(BitmapData, 16, Ptr)
    return E
  }

  ;#####################################################################################

  Gdip_UnlockBits(pBitmap, ByRef BitmapData)
  {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
  }

  ;#####################################################################################

  Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
  {
    Numput(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")
  }

  ;#####################################################################################

  Gdip_GetLockBitPixel(Scan0, x, y, Stride)
  {
    return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
  }

  ;#####################################################################################

  Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
  {
    static PixelateBitmap
    
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    
    if (!PixelateBitmap)
    {
      if A_PtrSize != 8 ; x86 machine code
      MCode_PixelateBitmap =
      (LTrim Join
      558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
      397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
      8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
      4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
      C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
      8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
      148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
      B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
      F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
      038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
      1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
      FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
      D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
      45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
      89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
      0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
      75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
      8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
      B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
      451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
      75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
      8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
      )
      else ; x64 machine code
      MCode_PixelateBitmap =
      (LTrim Join
      4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
      448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
      4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
      C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
      24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
      004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
      0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
      DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
      024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
      99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
      8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
      4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
      000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
      ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
      4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
      99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
      8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
      2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
      FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
      83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
      F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
      0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
      413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
      )
      
      VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
      Loop % StrLen(MCode_PixelateBitmap)//2    ;%
        NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "UChar")
      DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, A_PtrSize ? "UPtr*" : "UInt*", 0)
    }

    Gdip_GetImageDimensions(pBitmap, Width, Height)
    
    if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
      return -1
    if (BlockSize > Width || BlockSize > Height)
      return -2

    E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
    E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
    if (E1 || E2)
      return -3

    E := DllCall(&PixelateBitmap, Ptr, Scan01, Ptr, Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
    
    Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
    return 0
  }

  ;#####################################################################################

  Gdip_ToARGB(A, R, G, B)
  {
    return (A << 24) | (R << 16) | (G << 8) | B
  }

  ;#####################################################################################

  Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
  {
    A := (0xff000000 & ARGB) >> 24
    R := (0x00ff0000 & ARGB) >> 16
    G := (0x0000ff00 & ARGB) >> 8
    B := 0x000000ff & ARGB
  }

  ;#####################################################################################

  Gdip_AFromARGB(ARGB)
  {
    return (0xff000000 & ARGB) >> 24
  }

  ;#####################################################################################

  Gdip_RFromARGB(ARGB)
  {
    return (0x00ff0000 & ARGB) >> 16
  }

  ;#####################################################################################

  Gdip_GFromARGB(ARGB)
  {
    return (0x0000ff00 & ARGB) >> 8
  }

  ;#####################################################################################

  Gdip_BFromARGB(ARGB)
  {
    return 0x000000ff & ARGB
  }

  ;#####################################################################################

  StrGetB(Address, Length=-1, Encoding=0)
  {
    ; Flexible parameter handling:
    if Length is not integer
    Encoding := Length,  Length := -1

    ; Check for obvious errors.
    if (Address+0 < 1024)
      return

    ; Ensure 'Encoding' contains a numeric identifier.
    if Encoding = UTF-16
      Encoding = 1200
    else if Encoding = UTF-8
      Encoding = 65001
    else if SubStr(Encoding,1,2)="CP"
      Encoding := SubStr(Encoding,3)

    if !Encoding ; "" or 0
    {
      ; No conversion necessary, but we might not want the whole string.
      if (Length == -1)
        Length := DllCall("lstrlen", "uint", Address)
      VarSetCapacity(String, Length)
      DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
    }
    else if Encoding = 1200 ; UTF-16
    {
      char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
      VarSetCapacity(String, char_count)
      DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
    }
    else if Encoding is integer
    {
      ; Convert from target encoding to UTF-16 then to the active code page.
      char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
      VarSetCapacity(String, char_count * 2)
      char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
      String := StrGetB(&String, char_count, 1200)
    }
    
    return String
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -


/* TF: Textfile & String Library for AutoHotkey
 Version     : 3.7
 Documentation : https://github.com/hi5/TF
 AHKScript.org : http://www.ahkscript.org/boards/viewtopic.php?f=6&t=576
 AutoHotkey.com: http://www.autohotkey.com/forum/topic46195.html (Also for examples)
 License     : see license.txt (GPL 2.0)
 Credits & History: See documentation at GH above.
 */

  TF_CountLines(Text)
    {
    TF_GetData(OW, Text, FileName)
    StringReplace, Text, Text, `n, `n, UseErrorLevel
    Return ErrorLevel + 1
    }

  TF_ReadLines(Text, StartLine = 1, EndLine = 0, Trailing = 0)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        OutPut .= A_LoopField "`n"
      Else if (A_Index => EndLine)
        Break
      }
    OW = 2 ; make sure we return variable not process file
    Return TF_ReturnOutPut(OW, OutPut, FileName, Trailing)
    }

  TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
    {
    TF_GetData(OW, Text, FileName)
    IfNotInString, Text, %SearchText%
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        StringReplace, LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
        OutPut .= LoopField "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_Replace(Text, SearchText, ReplaceText="")
    {
    TF_GetData(OW, Text, FileName)
    IfNotInString, Text, %SearchText%
      Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
    Loop
      {
      StringReplace, Text, Text, %SearchText%, %ReplaceText%, All
      if (ErrorLevel = 0) ; No more replacements needed.
        break
      }
    Return TF_ReturnOutPut(OW, Text, FileName, 0)
    }

  TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
    {
    options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
    If RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
    Else searchText := "m)" . searchText
    TF_GetData(OW, Text, FileName)
      If (RegExMatch(Text, SearchText) < 1)
        Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3

    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        LoopField := RegExReplace(A_LoopField, NeedleRegEx, Replacement)
        OutPut .= LoopField "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_RegExReplace(Text, NeedleRegEx = "", Replacement = "")
    {
    options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
    if RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
    else searchText := "m)" . searchText
    TF_GetData(OW, Text, FileName)
      If (RegExMatch(Text, SearchText) < 1)
        Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
    Text := RegExReplace(Text, NeedleRegEx, Replacement)
    Return TF_ReturnOutPut(OW, Text, FileName, 0)
    }

  TF_RemoveLines(Text, StartLine = 1, EndLine = 0)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        Continue
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_RemoveBlankLines(Text, StartLine = 1, EndLine = 0)
    {
    TF_GetData(OW, Text, FileName)
    If (RegExMatch(Text, "[\S]+?\r?\n?") < 1)
      Return Text ; No empty lines so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_RemoveDuplicateLines(Text, StartLine = 1, Endline = 0, Consecutive = 0, CaseSensitive = false)
    {
    TF_GetData(OW, Text, FileName)
    If (StartLine = "")
      StartLine = 1
    If (Endline = 0 OR Endline = "")
      EndLine := TF_Count(Text, "`n") + 1
    Loop, Parse, Text, `n, `r
      {
      If (A_Index < StartLine)
        Section1 .= A_LoopField "`n"
      If A_Index between %StartLine% and %Endline%
        {
        If (Consecutive = 1)
          {
          If (A_LoopField <> PreviousLine) ; method one for consecutive duplicate lines
            Section2 .= A_LoopField "`n"
          PreviousLine:=A_LoopField
          }
        Else
          {
          If !(InStr(SearchForSection2,"__bol__" . A_LoopField . "__eol__",CaseSensitive)) ; not found
            {
            SearchForSection2 .= "__bol__" A_LoopField "__eol__" ; this makes it unique otherwise it could be a partial match
            Section2 .= A_LoopField "`n"
            }
          }
        }
      If (A_Index > EndLine)
        Section3 .= A_LoopField "`n"
      }
    Output .= Section1 Section2 Section3
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_InsertLine(Text, StartLine = 1, Endline = 0, InsertText = "")
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        Output .= InsertText "`n" A_LoopField "`n"
      Else
        Output .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        Output .= ReplaceText "`n"
      Else
        Output .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_InsertPrefix(Text, StartLine = 1, EndLine = 0, InsertText = "")
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        OutPut .= InsertText A_LoopField "`n"
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_InsertSuffix(Text, StartLine = 1, EndLine = 0 , InsertText = "")
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        OutPut .= A_LoopField InsertText "`n"
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_TrimLeft(Text, StartLine = 1, EndLine = 0, Count = 1)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        StringTrimLeft, StrOutPut, A_LoopField, %Count%
        OutPut .= StrOutPut "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_TrimRight(Text, StartLine = 1, EndLine = 0, Count = 1)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        StringTrimRight, StrOutPut, A_LoopField, %Count%
        OutPut .= StrOutPut "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_AlignLeft(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
    {
    Trim:=A_AutoTrim ; store trim settings
    AutoTrim, On ; make sure AutoTrim is on
    TF_GetData(OW, Text, FileName)
    If (Endline = 0 OR Endline = "")
      EndLine := TF_Count(Text, "`n") + 1
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace. Trims leading and trailing spaces!
        SpaceNum := Columns-StrLen(LoopField)-1
        If (SpaceNum > 0) and (Padding = 1) ; requires padding + keep padding
          {
          Left:=TF_SetWidth(LoopField,Columns, 0) ; align left
          OutPut .= Left "`n"
          }
        Else
          OutPut .= LoopField "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    AutoTrim, %Trim%  ; restore original Trim
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_AlignCenter(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
    {
    Trim:=A_AutoTrim ; store trim settings
    AutoTrim, On ; make sure AutoTrim is on
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
        SpaceNum := (Columns-StrLen(LoopField)-1)/2
        If (Padding = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
          {
          OutPut .= "`n"
          Continue
          }
        If (StrLen(LoopField) >= Columns)
          {
          OutPut .= LoopField "`n" ; add as is
          Continue
          }
        Centered:=TF_SetWidth(LoopField,Columns, 1) ; align center using set width
        OutPut .= Centered "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    AutoTrim, %Trim%  ; restore original Trim
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_AlignRight(Text, StartLine = 1, EndLine = 0, Columns = 80, Skip = 0)
    {
    Trim:=A_AutoTrim ; store trim settings
    AutoTrim, On ; make sure AutoTrim is on
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
        If (Skip = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
          {
          OutPut .= "`n"
          Continue
          }
        If (StrLen(LoopField) >= Columns)
          {
          OutPut .= LoopField "`n" ; add as is
          Continue
          }
        Right:=TF_SetWidth(LoopField,Columns, 2) ; align right using set width
        OutPut .= Right "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    AutoTrim, %Trim%  ; restore original Trim
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ; Based on: CONCATenate text files, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
  TF_ConCat(FirstTextFile, SecondTextFile, OutputFile = "", Blanks = 0, FirstPadMargin = 0, SecondPadMargin = 0)
    {
    If (Blanks > 0)
      Loop, %Blanks%
        InsertBlanks .= A_Space
    If (FirstPadMargin > 0)
      Loop, %FirstPadMargin%
        PaddingFile1 .= A_Space
    If (SecondPadMargin > 0)
      Loop, %SecondPadMargin%
        PaddingFile2 .= A_Space
    Text:=FirstTextFile
    TF_GetData(OW, Text, FileName)
    StringSplit, Str1Lines, Text, `n, `r
    Text:=SecondTextFile
    TF_GetData(OW, Text, FileName)
    StringSplit, Str2Lines, Text, `n, `r
    Text= ; clear mem

    ; first we need to determine the file with the most lines for our loop
    If (Str1Lines0 > Str2Lines0)
      MaxLoop:=Str1Lines0
    Else
      MaxLoop:=Str2Lines0
    Loop, %MaxLoop%
      {
      Section1:=Str1Lines%A_Index%
      Section2:=Str2Lines%A_Index%
      OutPut .= Section1 PaddingFile1 InsertBlanks Section2 PaddingFile2 "`n"
      Section1= ; otherwise it will remember the last line from the shortest file or var
      Section2=
      }
    OW=1 ; it is probably 0 so in that case it would create _copy, so set it to 1
    If (OutPutFile = "") ; if OutPutFile is empty return as variable
      OW=2
    Return TF_ReturnOutPut(OW, OutPut, OutputFile, 1, 1)
    }

  TF_LineNumber(Text, Leading = 0, Restart = 0, Char = 0) ; HT ribbet.1
    {
    global t
    TF_GetData(OW, Text, FileName)
    Lines:=TF_Count(Text, "`n") + 1
    Padding:=StrLen(Lines)
    If (Leading = 0) and (Char = 0)
      Char := A_Space
    Loop, %Padding%
      PadLines .= Char
    Loop, Parse, Text, `n, `r
      {
      If Restart = 0
        MaxNo = %A_Index%
      Else
        {
        MaxNo++
        If MaxNo > %Restart%
          MaxNo = 1
        }
      LineNumber:= MaxNo
      If (Leading = 1)
        {
        LineNumber := Padlines LineNumber ; add padding
        StringRight, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
        }
      If (Leading = 0)
        {
        LineNumber := LineNumber Padlines ; add padding
        StringLeft, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
        }
      OutPut .= LineNumber A_Space A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ; skip = 1, skip shorter lines (e.g. lines shorter startcolumn position)
  ; modified in TF 3.4, fixed in 3.5
  TF_ColGet(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1, Skip = 0)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    If (StartColumn < 0)
      {
      StartColumn++
      Loop, Parse, Text, `n, `r ; parsing file/var
        {
        If A_Index in %TF_MatchList%
          {
          output .= SubStr(A_LoopField,StartColumn) "`n"
          }
        else
          output .= A_LoopField "`n"
        }
      Return TF_ReturnOutPut(OW, OutPut, FileName)
      }
    if RegExMatch(StartColumn, ",|\+|-")
      {
      StartColumn:=_MakeMatchList(Text, StartColumn, 1, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
        {
        If A_Index in %TF_MatchList%
          {
          loop, parse, A_LoopField ; parsing LINE char by char
            {
            If A_Index in %StartColumn% ; if col in index get char
              output .= A_LoopField
            }
          output .= "`n"
          }
        else
          output .= A_LoopField "`n"
        }
      output .= A_LoopField "`n"
      }
    else
      {
      EndColumn:=(EndColumn+1)-StartColumn
      Loop, Parse, Text, `n, `r
        {
        If A_Index in %TF_MatchList%
          {
          StringMid, Section, A_LoopField, StartColumn, EndColumn
          If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
            Continue
          OutPut .= Section "`n"
          }
        }
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ; Based on: COLPUT.EXE & CUT.EXE, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
  ; modified in TF 3.4
  TF_ColPut(Text, Startline = 1, EndLine = 0, StartColumn = 1, InsertText = "", Skip = 0)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    If RegExMatch(StartColumn, ",|\+")
      {
      StartColumn:=_MakeMatchList(Text, StartColumn, 0, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
        {
        If A_Index in %TF_MatchList%
          {
          loop, parse, A_LoopField ; parsing LINE char by char
            {
            If A_Index in %StartColumn% ; if col in index insert text
              output .= InsertText A_LoopField
            Else
              output .= A_LoopField
            }
          output .= "`n"
          }
        else
          output .= A_LoopField "`n"
        }
      output .= A_LoopField "`n"
      }
    else
      {
      StartColumn--
      Loop, Parse, Text, `n, `r
        {
        If A_Index in %TF_MatchList%
          {
          If (StartColumn > 0)
            {
            StringLeft, Section1, A_LoopField, StartColumn
            StringMid, Section2, A_LoopField, StartColumn+1
            If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
              OutPut .= Section1 Section2 "`n"
            }
          Else
            {
            Section1:=SubStr(A_LoopField, 1, StrLen(A_LoopField) + StartColumn + 1)
            Section2:=SubStr(A_LoopField, StrLen(A_LoopField) + StartColumn + 2)
            If (Skip = 1) and (A_LoopField = "")
              OutPut .= Section1 Section2 "`n"
            }
          OutPut .= Section1 InsertText Section2 "`n"
          }
        Else
          OutPut .= A_LoopField "`n"
        }
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ; modified TF 3.4
  TF_ColCut(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    If RegExMatch(StartColumn, ",|\+|-")
      {
      StartColumn:=_MakeMatchList(Text, StartColumn, EndColumn, 1)
      Loop, Parse, Text, `n, `r ; parsing file/var
        {
        If A_Index in %TF_MatchList%
          {
          loop, parse, A_LoopField ; parsing LINE char by char
            {
            If A_Index not in %StartColumn% ; if col not in index get char
              output .= A_LoopField
            }
          output .= "`n"
          }
        else
          output .= A_LoopField "`n"
        }
      output .= A_LoopField "`n"
      }
    else
      {
      StartColumn--
      EndColumn++
      Loop, Parse, Text, `n, `r
        {
        If A_Index in %TF_MatchList%
          {
          StringLeft, Section1, A_LoopField, StartColumn
          StringMid, Section2, A_LoopField, EndColumn
          OutPut .= Section1 Section2 "`n"
          }
        Else
          OutPut .= A_LoopField "`n"
        }
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_ReverseLines(Text, StartLine = 1, EndLine = 0)
    {
    TF_GetData(OW, Text, FileName)
    StringSplit, Line, Text, `n, `r ; line0 is number of lines
    If (EndLine = 0 OR EndLine = "")
      EndLine:=Line0
    If (EndLine > Line0)
      EndLine:=Line0
    CountDown:=EndLine+1
    Loop, Parse, Text, `n, `r
      {
      If (A_Index < StartLine)
        Output1 .= A_LoopField "`n" ; section1
      If A_Index between %StartLine% and %Endline%
        {
        CountDown--
        Output2 .= Line%CountDown% "`n" section2
        }
      If (A_Index > EndLine)
        Output3 .= A_LoopField "`n"
      }
    OutPut.= Output1 Output2 Output3
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ;TF_SplitFileByLines
  ;example:
  ;TF_SplitFileByLines("TestFile.txt", "4", "sfile_", "txt", "1") ; split file every 3 lines
  ; InFile = 0 skip line e.g. do not include the actual line in any of the output files
  ; InFile = 1 include line IN current file
  ; InFile = 2 include line IN next file
  TF_SplitFileByLines(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
    {
    LineCounter=1
    FileCounter=1
    Where:=SplitAt
    Method=1
    ; 1 = default, splitat every X lines,
    ; 2 = splitat: - rotating if applicable
    ; 3 = splitat: specific lines comma separated
    TF_GetData(OW, Text, FileName)

    IfInString, SplitAt, `- ; method 2
      {
      StringSplit, Split, SplitAt, `-
      Part=1
      Where:=Split%Part%
      Method=2
      }
    IfInString, SplitAt, `, ; method 3
      {
      StringSplit, Split, SplitAt, `,
      Part=1
      Where:=Split%Part%
      Method=3
      }
    Loop, Parse, Text, `n, `r
      {
      OutPut .= A_LoopField "`n"
      If (LineCounter = Where)
        {
        If (InFile = 0)
          {
          StringReplace, CheckOutput, PreviousOutput, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; skip empty files
            TF_SetGlobal(Prefix FileCounter,PreviousOutput)
          Output:=
          }
        If (InFile = 1)
          {
          StringReplace, CheckOutput, Output, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; skip empty files
            TF_SetGlobal(Prefix FileCounter,Output)
          Output:=
          }
        If (InFile = 2)
          {
          OutPut := PreviousOutput
          StringReplace, CheckOutput, Output, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; output to array
            TF_SetGlobal(Prefix FileCounter,Output)
          OutPut := A_LoopField "`n"
          }
        If (Method <> 3)
          LineCounter=0 ; reset
        FileCounter++ ; next file
        Part++
        If (Method = 2) ; 2 = splitat: - rotating if applicable
          {
        If (Part > Split0)
            {
            Part=1
            }
          Where:=Split%Part%
          }
        If (Method = 3) ; 3 = splitat: specific lines comma separated
          {
          If (Part > Split0)
            Where:=Split%Split0%
          Else
            Where:=Split%Part%
          }
        }
      LineCounter++
      PreviousOutput:=Output
      PreviousLine:=A_LoopField
      }
    StringReplace, CheckOutput, Output, `n, , All
    StringReplace, CheckOutput, CheckOutput, `r, , All
    If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
      TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
    If (CheckOutput <> "") and (OW = 2) ; output to array
      {
      TF_SetGlobal(Prefix FileCounter,Output)
      TF_SetGlobal(Prefix . "0" , FileCounter)
      }
    }

  ; TF_SplitFileByText("TestFile.txt", "button", "sfile_", "txt") ; split file at every line with button in it, can be regexp
  ; InFile = 0 skip line e.g. do not include the actual line in any of the output files
  ; InFile = 1 include line IN current file
  ; InFile = 2 include line IN next file
  TF_SplitFileByText(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
    {
    LineCounter=1
    FileCounter=1
    TF_GetData(OW, Text, FileName)
    SplitPath, TextFile,, Dir
    Loop, Parse, Text, `n, `r
      {
      OutPut .= A_LoopField "`n"
      FoundPos:=RegExMatch(A_LoopField, SplitAt)
      If (FoundPos > 0)
        {
        If (InFile = 0)
          {
          StringReplace, CheckOutput, PreviousOutput, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; output to array
            TF_SetGlobal(Prefix FileCounter,PreviousOutput)
          Output:=
          }
        If (InFile = 1)
          {
          StringReplace, CheckOutput, Output, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; output to array
            TF_SetGlobal(Prefix FileCounter,Output)
          Output:=
          }
        If (InFile = 2)
          {
          OutPut := PreviousOutput
          StringReplace, CheckOutput, Output, `n, , All
          StringReplace, CheckOutput, CheckOutput, `r, , All
          If (CheckOutput <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
          If (CheckOutput <> "") and (OW = 2) ; output to array
            TF_SetGlobal(Prefix FileCounter,Output)
          OutPut := A_LoopField "`n"
          }
        LineCounter=0 ; reset
        FileCounter++ ; next file
        }
      LineCounter++
      PreviousOutput:=Output
      PreviousLine:=A_LoopField
      }
    StringReplace, CheckOutput, Output, `n, , All
    StringReplace, CheckOutput, CheckOutput, `r, , All
    If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
      TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
    If (CheckOutput <> "") and (OW = 2) ; output to array
      {
      TF_SetGlobal(Prefix FileCounter,Output)
      TF_SetGlobal(Prefix . "0" , FileCounter)
      }
    }

  TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
    {
    options:="^[imsxADJUXPS]+\)"
    if RegExMatch(searchText,options,o)
      searchText:=RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0(*ANYCRLF)" : "$0"))
    else searchText:="m)(*ANYCRLF)" searchText
    options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze, see http://www.autohotkey.com/forum/viewtopic.php?t=60062
    if RegExMatch(searchText,options,o)
      searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
    else searchText := "m)" . searchText

    TF_GetData(OW, Text, FileName)
    If (RegExMatch(Text, SearchText) < 1)
      Return "0" ; SearchText not in file or error, so do nothing

    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        If (RegExMatch(A_LoopField, SearchText) > 0)
          {
          If (ReturnText = 0)
            Lines .= A_Index "," ; line number
          Else If (ReturnText = 1)
            Lines .= A_LoopField "`n" ; text of line
          Else If (ReturnText = 2)
            Lines .= A_Index ": " A_LoopField "`n" ; add line number
          If (ReturnFirst = 1) ; only return first occurrence
            Break
          }
        }
      }
    If (Lines <> "")
      StringTrimRight, Lines, Lines, 1 ; trim trailing , or `n
    Else
      Lines = 0 ; make sure we return 0
    Return Lines
    }

  TF_Prepend(File1, File2)
    {
  FileList=
  (
  %File1%
  %File2%
  )
  TF_Merge(FileList,"`n", "!" . File2)
  Return
    }

  TF_Append(File1, File2)
    {
  FileList=
  (
  %File2%
  %File1%
  )
  TF_Merge(FileList,"`n", "!" . File2)
  Return
    }

  ; For TF_Merge You will need to create a Filelist variable, one file per line,
  ; to pass on to the function:
  ; FileList=
  ; (
  ; c:\file1.txt
  ; c:\file2.txt
  ; )
  ; use Loop (files & folders) to create one quickly if you want to merge all TXT files for example
  ;
  ; Loop, c:\*.txt
  ;   FileList .= A_LoopFileFullPath "`n"
  ;
  ; By default, a new line is used as a separator between two text files
  ; !merged.txt deletes target file before starting to merge files
  TF_Merge(FileList, Separator = "`n", FileName = "merged.txt")
    {
    OW=0
    Loop, Parse, FileList, `n, `r
      {
      Append2File= ; Just make sure it is empty
      IfExist, %A_LoopField%
        {
        FileRead, Append2File, %A_LoopField%
        If not ErrorLevel ; Successfully loaded
          Output .= Append2File Separator
        }
      }

    If (SubStr(FileName,1,1)="!") ; check if we want to delete the target file before we start
      {
      FileName:=SubStr(FileName,2)
      OW=1
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName, 0, 1)
    }

  TF_Wrap(Text, Columns = 80, AllowBreak = 0, StartLine = 1, EndLine = 0)
    {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    If (AllowBreak = 1)
      Break=
    Else
      Break=[ \r?\n]
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        If (StrLen(A_LoopField) > Columns)
          {
          LoopField := A_LoopField " " ; just seems to work better by adding a space
          OutPut .= RegExReplace(LoopField, "(.{1," . Columns . "})" . Break , "$1`n")
          }
        Else
          OutPut .= A_LoopField "`n"
        }
      Else
        OutPut .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_WhiteSpace(Text, RemoveLeading = 1, RemoveTrailing = 1, StartLine = 1, EndLine = 0) {
    TF_GetData(OW, Text, FileName)
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
    Trim:=A_AutoTrim ; store trim settings
    AutoTrim, On ; make sure AutoTrim is on
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        If (RemoveLeading = 1) AND (RemoveTrailing = 1)
          {
          LoopField = %A_LoopField%
          Output .= LoopField "`n"
            Continue
          }
        If (RemoveLeading = 1) AND (RemoveTrailing = 0)
          {
          LoopField := A_LoopField . "."
          LoopField = %LoopField%
          StringTrimRight, LoopField, LoopField, 1
          Output .= LoopField "`n"
            Continue
          }
        If (RemoveLeading = 0) AND (RemoveTrailing = 1)
          {
          LoopField := "." A_LoopField
          LoopField = %LoopField%
          StringTrimLeft, LoopField, LoopField, 1
          Output .= LoopField "`n"
            Continue
          }
        If (RemoveLeading = 0) AND (RemoveTrailing = 0)
          {
          Output .= A_LoopField "`n"
            Continue
          }
        }
      Else
        Output .= A_LoopField "`n"
      }
    AutoTrim, %Trim%  ; restore original Trim
    Return TF_ReturnOutPut(OW, OutPut, FileName)
  }

  ; Delete lines from file1 in file2 (using StringReplace)
  ; Partialmatch = 2 added in 3.4
  TF_Substract(File1, File2, PartialMatch = 0) {
    Text:=File1
    TF_GetData(OW, Text, FileName)
    Str1:=Text
    Text:=File2
    TF_GetData(OW, Text, FileName)
      OutPut:=Text
    If (OW = 2)
      File1= ; free mem in case of var/text
    OutPut .= "`n" ; just to make sure the StringReplace will work

    If (PartialMatch = 2)
      {
      Loop, Parse, Str1, `n, `r
        {
        IfInString, Output, %A_LoopField%
          {
          Output:= RegExReplace(Output, "im)^.*" . A_LoopField . ".*\r?\n?", replace)
          }
        }
      }
    Else If (PartialMatch = 1) ; allow paRTIal match
      {
      Loop, Parse, Str1, `n, `r
        StringReplace, Output, Output, %A_LoopField%, , All ; remove lines from file1 in file2
      }
    Else If (PartialMatch = 0)
      {
      search:="m)^(.*)$"
      replace=__bol__$1__eol__
      Output:=RegExReplace(Output, search, replace)
      StringReplace, Output, Output, `n__eol__,__eol__ , All ; strange fix but seems to be needed.
      Loop, Parse, Str1, `n, `r
        StringReplace, Output, Output, __bol__%A_LoopField%__eol__, , All ; remove lines from file1 in file2
      }
    If (PartialMatch = 0)
      {
      StringReplace, Output, Output, __bol__, , All
      StringReplace, Output, Output, __eol__, , All
      }

    ; Remove all blank lines from the text in a variable:
    Loop
      {
      StringReplace, Output, Output, `r`n`r`n, `r`n, UseErrorLevel
      if (ErrorLevel = 0) or (ErrorLevel = 1) ; No more replacements needed.
        break
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName, 0)
  }

  ; Similar to "BK Replace EM" RangeReplace
  TF_RangeReplace(Text, SearchTextBegin, SearchTextEnd, ReplaceText = "", CaseSensitive = "False", KeepBegin = 0, KeepEnd = 0)
    {
    TF_GetData(OW, Text, FileName)
    IfNotInString, Text, %SearchText%
      Return Text ; SearchTextBegin not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
    Start = 0
    End = 0
    If (KeepBegin = 1)
      KeepBegin:=SearchTextBegin
    Else
      KeepBegin=
    If (KeepEnd = 1)
      KeepEnd:= SearchTextEnd
    Else
      KeepEnd=
    If (SearchTextBegin = "")
      Start=1
    If (SearchTextEnd = "")
      End=2

    Loop, Parse, Text, `n, `r
      {
      If (End = 1) ; end has been found already, replacement made simply continue to add all lines
        {
        Output .= A_LoopField "`n"
          Continue
        }
      If (Start = 0) ; start hasn't been found
        {
        If (InStr(A_LoopField,SearchTextBegin,CaseSensitive)) ; start has been found
          {
          Start = 1
          KeepSection := SubStr(A_LoopField, 1, InStr(A_LoopField, SearchTextBegin)-1)
          EndSection := SubStr(A_LoopField, InStr(A_LoopField, SearchTextBegin)-1)
          ; check if SearchEndText is in second part of line
          If (InStr(EndSection,SearchTextEnd,CaseSensitive)) ; end found
            {
            EndSection := ReplaceText KeepEnd SubStr(EndSection, InStr(EndSection, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
            If (End <> 2)
              End=1
            If (End = 2)
              EndSection=
            }
          Else
            EndSection=
          Output .= KeepSection KeepBegin EndSection
          Continue
          }
        Else
          Output .= A_LoopField "`n" ; if not found yet simply add
          }
      If (Start = 1) and (End <> 2) ; start has been found, now look for end if end isn't an empty string
        {
        If (InStr(A_LoopField,SearchTextEnd,CaseSensitive)) ; end found
          {
          End = 1
          Output .= ReplaceText KeepEnd SubStr(A_LoopField, InStr(A_LoopField, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
          }
        }
      }
    If (End = 2)
      Output .= ReplaceText
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ; Create file of X lines and Y columns, fill with space or other character(s)
  TF_MakeFile(Text, Lines = 1, Columns = 1, Fill = " ")
    {
    OW=1
    If (Text = "") ; if OutPutFile is empty return as variable
      OW=2
    Loop, % Columns
      Cols .= Fill
    Loop, % Lines
      Output .= Cols "`n"
    Return TF_ReturnOutPut(OW, OutPut, Text, 1, 1)
    }

  ; Convert tabs to spaces, shorthand for TF_ReplaceInLines
  TF_Tab2Spaces(Text, TabStop = 4, StartLine = 1, EndLine =0)
    {
    Loop, % TabStop
      Replace .= A_Space
    Return TF_ReplaceInLines(Text, StartLine, EndLine, A_Tab, Replace)
    }

  ; Convert spaces to tabs, shorthand for TF_ReplaceInLines
  TF_Spaces2Tab(Text, TabStop = 4, StartLine = 1, EndLine =0)
    {
    Loop, % TabStop
      Replace .= A_Space
    Return TF_ReplaceInLines(Text, StartLine, EndLine, Replace, A_Tab)
    }

  ; Sort (section of) a text file
  TF_Sort(Text, SortOptions = "", StartLine = 1, EndLine = 0) ; use the SORT options http://www.autohotkey.com/docs/commands/Sort.htm
    {
    TF_GetData(OW, Text, FileName)
    If StartLine contains -,+,`, ; no sections, incremental or multiple line input
      Return
    If (StartLine = 1) and (Endline = 0) ; process entire file
      {
      Output:=Text
      Sort, Output, %SortOptions%
      }
    Else
      {
      Output := TF_ReadLines(Text, 1, StartLine-1) ; get first section
      ToSort := TF_ReadLines(Text, StartLine, EndLine) ; get section to sort
      Sort, ToSort, %SortOptions%
      OutPut .= ToSort
      OutPut .= TF_ReadLines(Text, EndLine+1) ; append last section
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  TF_Tail(Text, Lines = 1, RemoveTrailing = 0, ReturnEmpty = 1)
    {
    TF_GetData(OW, Text, FileName)
    Neg = 0
    If (Lines < 0)
      {
      Neg=1
      Lines:= Lines * -1
      }
    If (ReturnEmpty = 0) ; remove blank lines first so we can't return any blank lines anyway
      {
      Loop, Parse, Text, `n, `r
        OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
      StringTrimRight, OutPut, OutPut, 1 ; remove trailing `n added by loop above
      Text:=OutPut
      OutPut=
    }
    If (Neg = 1) ; get only one line!
      {
      Lines++
      Output:=Text
      StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
      StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
      StringGetPos, Pos, Output, `n
      StringLeft, Output, Output, % Pos
      Output .= "`n"
      }
    Else
      {
      Output:=Text
      StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
      StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
      Output .= "`n"
      }
    OW = 2 ; make sure we return variable not process file
    Return TF_ReturnOutPut(OW, OutPut, FileName, RemoveTrailing)
    }

  TF_Count(String, Char)
    {
    StringReplace, String, String, %Char%,, UseErrorLevel
    Return ErrorLevel
    }

  TF_Save(Text, FileName, OverWrite = 1) { ; HugoV write file
    Return TF_ReturnOutPut(OverWrite, Text, FileName, 0, 1)
    }

  TF(TextFile, CreateGlobalVar = "T") { ; read contents of file in output and %output% as global var ...  http://www.autohotkey.com/forum/viewtopic.php?p=313120#313120
    global
    FileRead, %CreateGlobalVar%, %TextFile%
    Return, (%CreateGlobalVar%)
    }

  ; TF_Join
  ; SmartJoin: Detect if CHAR(s) is/are already present at the end of the line before joining the next, this to prevent unnecessary double spaces for example.
  ; Char: character(s) to use between new lines, defaults to a space. To use nothing use ""
  TF_Join(Text, StartLine = 1, EndLine = 0, SmartJoin = 0, Char = 0)
    {
    If ( (InStr(StartLine,",") > 0) AND (InStr(StartLine,"-") = 0) ) OR (InStr(StartLine,"+") > 0)
      Return Text ; can't do multiplelines, only multiple sections of lines e.g. "1,5" bad "1-5,15-10" good, "2+2" also bad
    TF_GetData(OW, Text, FileName)
    If (InStr(Text,"`n") = 0)
      Return Text ; there are no lines to join so just return Text
    If (InStr(StartLine,"-") > 0)  ; OK, we need some counter-intuitive string mashing to substract ONE from the "endline" parameter
      {
      Loop, Parse, StartLine, CSV
        {
        StringSplit, part, A_LoopField, -
        NewStartLine .= part1 "-" (part2-1) ","
        }
      StringTrimRight, StartLine, NewStartLine, 1
      }
    If (Endline > 0)
      Endline--
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc)
    If (Char = 0)
      Char:=A_Space
    Char_Org:=Char
    GetRightLen:=StrLen(Char)-1
    Loop, Parse, Text, `n, `r
      {
      If A_Index in %TF_MatchList%
        {
        If (SmartJoin = 1)
          {
          GetRightText:=SubStr(A_LoopField,0)
          If (GetRightText = Char)
            Char=
          }
        Output .= A_LoopField Char
        Char:=Char_Org
        }
      Else
        Output .= A_LoopField "`n"
      }
    Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

  ;----- Helper functions ----------------

  TF_SetGlobal(var, content = "") ; helper function for TF_Split* to return array and not files, credits Tuncay :-)
    {
    global
    %var% := content
    }

  ; Helper function to determine if VAR/TEXT or FILE is passed to TF
  ; Update 11 January 2010 (skip filecheck if `n in Text -> can't be file)
  TF_GetData(byref OW, byref Text, byref FileName)
    {
    If (text = 0 "") ; v3.6 -> v3.7 https://github.com/hi5/TF/issues/4 and https://autohotkey.com/boards/viewtopic.php?p=142166#p142166 in case user passes on zero/zeros ("0000") as text - will error out when passing on one 0 and there is no file with that name
      {
      IfNotExist, %Text% ; additional check to see if a file 0 exists
        {
        MsgBox, 48, TF Lib Error, % "Read Error - possible reasons (see documentation):`n- Perhaps you used !""file.txt"" vs ""!file.txt""`n- A single zero (0) was passed on to a TF function as text"
        ExitApp
        }
      }
    OW=0 ; default setting: asume it is a file and create file_copy
    IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
      {
      If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
        {
        Text:=SubStr(Text,2)
        OW=1 ; overwrite file (if it is a file)
        }
      IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
        {
        If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
          Text:= "!" . Text
        OW=2 ; no file, so it is a var or Text passed on directly to TF
        }
      }
    Else ; there is a newline character in Text so it has to be a variable
      {
      OW=2
      }
    If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
      {
      Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
      FileName=%Text% ; Store FileName
      FileRead, Text, %Text% ; Read file and return as var Text
      If (ErrorLevel > 0)
        {
        MsgBox, 48, TF Lib Error, % "Can not read " FileName
        ExitApp
        }
      }
    Return
    }

  ; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
  ; SetWidth() : SetWidth increases a String's length by adding spaces to it and aligns it Left/Center/Right. ( Requires Space() )
  TF_SetWidth(Text,Width,AlignText)
    {
    If (AlignText!=0 and AlignText!=1 and AlignText!=2)
      AlignText=0
    If AlignText=0
      {
      RetStr= % (Text)TF_Space(Width)
      StringLeft, RetText, RetText, %Width%
      }
    If AlignText=1
      {
      Spaces:=(Width-(StrLen(Text)))
      RetStr= % TF_Space(Round(Spaces/2))(Text)TF_Space(Spaces-(Round(Spaces/2)))
      }
    If AlignText=2
      {
      RetStr= % TF_Space(Width)(Text)
      StringRight, RetStr, RetStr, %Width%
      }
    Return RetStr
    }

  ; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
  TF_Space(Width)
    {
    Loop,%Width%
      Space=% Space Chr(32)
    Return Space
    }

  ; Write to file or return variable depending on input
  TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) {
    If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
      {
      IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
        {
        If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
          {
          OW = 1
          Goto CreateNewFile
          }
        Else
          Return
        }
      If (TrimTrailing = 1)
        StringTrimRight, Text, Text, 1 ; remove trailing `n
      SplitPath, FileName,, Dir, Ext, Name
      If (Dir = "") ; if Dir is empty Text & script are in same directory
        Dir := A_WorkingDir
      IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
        FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
      FileDelete, % Dir "\" Name "_copy." Ext
      FileAppend, %Text%, % Dir "\" Name "_copy." Ext
      Return Errorlevel ? False : True
      }
    CreateNewFile:
    If (OW = 1) ; input was file, will be overwritten by output
      {
      IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
        {
        If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
          Return
        }
      If (TrimTrailing = 1)
        StringTrimRight, Text, Text, 1 ; remove trailing `n
      SplitPath, FileName,, Dir, Ext, Name
      If (Dir = "") ; if Dir is empty Text & script are in same directory
        Dir := A_WorkingDir
      IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
        FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
      FileDelete, % Dir "\" Name "." Ext
      FileAppend, %Text%, % Dir "\" Name "." Ext
      Return Errorlevel ? False : True
      }
    If (OW = 2) ; input was var, return variable
      {
      If (TrimTrailing = 1)
        StringTrimRight, Text, Text, 1 ; remove trailing `n
      Return Text
      }
    }

  ; _MakeMatchList()
  ; Purpose:
  ; Make a MatchList which is used in various functions
  ; Using a MatchList gives greater flexibility so you can process multiple
  ; sections of lines in one go avoiding repetitive fileread/append actions
  ; For TF 3.4 added COL = 0/1 option (for TF_Col* functions) and CallFunc for
  ; all TF_* functions to facilitate bug tracking
  _MakeMatchList(Text, Start = 1, End = 0, Col = 0, CallFunc = "Not available")
    {
    ErrorList=
    (join|
  Error 01: Invalid StartLine parameter (non numerical character)`nFunction used: %CallFunc%
  Error 02: Invalid EndLine parameter (non numerical character)`nFunction used: %CallFunc%
  Error 03: Invalid StartLine parameter (only one + allowed)`nFunction used: %CallFunc%
    )
    StringSplit, ErrorMessage, ErrorList, |
    Error = 0

    If (Col = 1)
      {
      LongestLine:=TF_Stat(Text)
      If (End > LongestLine) or (End = 1) ; FIXITHERE BUG
        End:=LongestLine
      }

    TF_MatchList= ; just to be sure
    If (Start = 0 or Start = "")
      Start = 1

    ; some basic error checking

    ; error: only digits - and + allowed
    If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
      Error = 1

    If (RegExReplace(End, "[0-9 ]", "") <> "")
      Error = 2

    ; error: only one + allowed
    If (TF_Count(Start,"+") > 1)
      Error = 3

    If (Error > 0 )
      {
      MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
      ExitApp
      }

    ; Option #0 [ added 30-Oct-2010 ]
    ; Startline has negative value so process X last lines of file
    ; endline parameter ignored

    If (Start < 0) ; remove last X lines from file, endline parameter ignored
      {
      Start:=TF_CountLines(Text) + Start + 1
      End=0 ; now continue
      }

    ; Option #1
    ; StartLine has + character indicating startline + incremental processing.
    ; EndLine will be used
    ; Make TF_MatchList

    IfInString, Start, `+
      {
      If (End = 0 or End = "") ; determine number of lines
        End:= TF_Count(Text, "`n") + 1
      StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
      Loop, %Section0%
        {
        StringSplit, SectionLines, Section%A_Index%, `+
        LoopSection:=End + 1 - SectionLines1
        Counter=0
          TF_MatchList .= SectionLines1 ","
        Loop, %LoopSection%
          {
          If (A_Index >= End) ;
            Break
          If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
            {
            TF_MatchList .= (SectionLines1 + A_Index) ","
            Counter=0
            }
          Else
            Counter++
          }
        }
      StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
      Return TF_MatchList
      }

    ; Option #2
    ; StartLine has - character indicating from-to, COULD be multiple sections.
    ; EndLine will be ignored
    ; Make TF_MatchList

    IfInString, Start, `-
      {
      StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
      Loop, %Section0%
        {
        StringSplit, SectionLines, Section%A_Index%, `-
        LoopSection:=SectionLines2 + 1 - SectionLines1
        Loop, %LoopSection%
          {
          TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
          }
        }
      StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
      Return TF_MatchList
      }

    ; Option #3
    ; StartLine has comma indicating multiple lines.
    ; EndLine will be ignored

    IfInString, Start, `,
      {
      TF_MatchList:=Start
      Return TF_MatchList
      }

    ; Option #4
    ; parameters passed on as StartLine, EndLine.
    ; Make TF_MatchList from StartLine to EndLine

    If (End = 0 or End = "") ; determine number of lines
        End:= TF_Count(Text, "`n") + 1
    LoopTimes:=End-Start
    Loop, %LoopTimes%
      {
      TF_MatchList .= (Start - 1 + A_Index) ","
      }
    TF_MatchList .= End ","
    StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
    Return TF_MatchList
    }

  ; added for TF 3.4 col functions - currently only gets longest line may change in future
  TF_Stat(Text)
    {
    TF_GetData(OW, Text, FileName)
    Sort, Text, f _AscendingLinesL
    Pos:=InStr(Text,"`n")-1
    Return pos
    }

  _AscendingLinesL(a1, a2) ; used by TF_Stat
    {
    Return StrLen(a2) - StrLen(a1)
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/* XGraph v1.1.1.0 : Real time data plotting.
 *  Script    :  XGraph v1.1.1.0 : Real time data plotting.
 *         http://ahkscript.org/boards/viewtopic.php?t=3492
 *         Created: 24-Apr-2014,  Last Modified: 09-May-2014 
 *
 *  Description :  Easy to use, Light weight, fast, efficient GDI based function library for 
 *         graphically plotting real time data.
 *
 *  Author    :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
 *  Demos     :  CPU Load Monitor > http://ahkscript.org/boards/viewtopic.php?t=3413
 - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
 */

  XGraph( hCtrl, hBM := 0, ColumnW := 3, LTRB := "0,2,0,2", PenColor := 0x808080, PenSize := 1, SV := 0 ) {
  Static WM_SETREDRAW := 0xB, STM_SETIMAGE := 0x172, PS_SOLID := 0, cbSize := 136, SRCCOPY := 0x00CC0020 
    , GPTR := 0x40, OBJ_BMP := 0x7, LR_CREATEDIBSECTION := 0x2000, LR_COPYDELETEORG := 0x8

  ; Validate control  
  WinGetClass, Class,   ahk_id %hCtrl%  
  Control, Style, +0x5000010E,, ahk_id %hCtrl% 
  ControlGet, Style, Style,,, ahk_id %hCtrl%
  ControlGet, ExStyle, ExStyle,,, ahk_id %hCtrl%
  ControlGetPos,,, CtrlW, CtrlH,, ahk_id %hCtrl% 
  If not ( Class == "Static" and Style = 0x5000010E and ExStyle = 0 and CtrlW > 0 and CtrlH > 0 ) 
    Return 0, ErrorLevel := -1

  ; Validate Bitmap
  If ( DllCall( "GetObjectType", "Ptr",hBM ) <> OBJ_BMP )
    hTargetBM := DllCall( "CreateBitmap", "Int",2, "Int",2, "UInt",1, "UInt",16, "Ptr",0, "Ptr" )
    ,  hTargetBM := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",CtrlW, "Int",CtrlH
              , "UInt",LR_CREATEDIBSECTION|LR_COPYDELETEORG, "Ptr" )
  else hTargetBM := hBM  

  VarSetCapacity( BITMAP,32,0 )  
  DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
  If NumGet( BITMAP, 18, "UInt" ) < 16 ; Checking if BPP < 16  
    Return 0, ErrorLevel := -2
  Else BitmapW := NumGet( BITMAP,  4, "UInt" ),  BitmapH := NumGet( BITMAP, 8, "UInt" )   
  If ( BitmapW <> CtrlW or BitmapH <> CtrlH )         
    Return 0, ErrorLevel := -3

  ; Validate Margins and Column width   
  StringSplit, M, LTRB, `, , %A_Space% ; Left,Top,Right,Bottom
  MarginL := ( M1+0 < 0 ? 0 : M1 ),  MarginT   := ( M2+0 < 0 ? 0 : M2 )
  MarginR := ( M3+0 < 0 ? 0 : M3 ),  MarginB   := ( M4+0 < 0 ? 0 : M4 )  
  ColumnW := ( ColumnW+0 < 0 ? 3 : ColumnW & 0xff ) ; 1 - 255

  ; Derive Columns, BitBlt dimensions, Movement coords for Lineto() and MoveToEx()  
  Columns := ( BitmapW - MarginL - MarginR ) // ColumnW 
  BitBltW := Columns* ColumnW,        BitBltH := BitmapH - MarginT - MarginB
  MX1   := BitBltW - ColumnW,          MY1 := BitBltH - 1 
  MX2   := MX1 + ColumnW - ( PenSize < 1 ) ;   MY2 := < user defined >

  ; Initialize Memory Bitmap
  hSourceDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" ) 
  hSourceBM  := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",ColumnW* 2 + BitBltW
            , "Int",BitBltH, "UInt",LR_CREATEDIBSECTION, "Ptr" )   
  DllCall( "SaveDC", "Ptr",hSourceDC ) 
  DllCall( "SelectObject", "Ptr",hSourceDC, "Ptr",hSourceBM )

  hTempDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
  DllCall( "SaveDC", "Ptr",hTempDC )
  DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTargetBM )

  If ( hTargetBM <> hBM )
    hBrush := DllCall( "CreateSolidBrush", UInt,hBM & 0xFFFFFF, "Ptr" )
  , VarSetCapacity( RECT, 16, 0 )
  , NumPut( BitmapW, RECT, 8, "UInt" ),  NumPut( BitmapH, RECT,12, "UInt" )
  , DllCall( "FillRect", "Ptr",hTempDC, "Ptr",&RECT, "Ptr",hBrush )
  , DllCall( "DeleteObject", "Ptr",hBrush )
  
  DllCall( "BitBlt", "Ptr",hSourceDC, "Int",ColumnW* 2, "Int",0, "Int",BitBltW, "Int",BitBltH
          , "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )
  DllCall( "BitBlt", "Ptr",hSourceDC, "Int",0, "Int",0, "Int",BitBltW, "Int",BitBltH
          , "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )

  ; Validate Pen color / Size                                  
  PenColor   := ( PenColor + 0 <> "" ? PenColor & 0xffffff : 0x808080 ) ; Range: 000000 - ffffff
  PenSize  := ( PenSize  + 0 <> "" ? PenSize & 0xf : 1 )        ; Range: 0 - 15        
  hSourcePen := DllCall( "CreatePen", "Int",PS_SOLID, "Int",PenSize, "UInt",PenColor, "Ptr" )
  DllCall( "SelectObject", "Ptr",hSourceDC, "Ptr",hSourcePen )
  DllCall( "MoveToEx", "Ptr",hSourceDC, "Int",MX1, "Int",MY1, "Ptr",0 )

  hTargetDC := DllCall( "GetDC", "Ptr",hCtrl, "Ptr" ) 
  DllCall( "BitBlt", "Ptr",hTargetDC, "Int",0, "Int",0, "Int",BitmapW, "Int",BitmapH
          , "Ptr",hTempDC,   "Int",0, "Int",0, "UInt",SRCCOPY ) 

  DllCall( "RestoreDC", "Ptr",hTempDC, "Int",-1 )
  DllCall( "DeleteDC",  "Ptr",hTempDC )  

  DllCall( "SendMessage", "Ptr",hCtrl, "UInt",WM_SETREDRAW, "Ptr",False, "Ptr",0 ) 
  hOldBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_SETIMAGE, "Ptr",0, "Ptr",hTargetBM )  
  DllCall( "SendMessage", "Ptr",hCtrl, "UInt",WM_SETREDRAW, "Ptr",True,  "Ptr",0 )
  DllCall( "DeleteObject", "Ptr",hOldBM )

  ; Create / Update Graph structure
  DataSz := ( SV = 1 ? Columns* 8 : 0 )
  pGraph := DllCall( "GlobalAlloc", "UInt",GPTR, "Ptr",cbSize + DataSz, "UPtr" )
  NumPut( DataSz, pGraph + cbSize - 8   )   
  VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen / ColumnW / Columns / "
      . "MarginL / MarginT / MarginR / MarginB / MX1 / MX2 / BitBltW / BitBltH" 
  Loop, Parse, VarL, /, %A_Space%
    NumPut( %A_LoopField%, pGraph + 0, ( A_Index - 1 )* 8 )

  Return pGraph      
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_Info( pGraph, FormatFloat := "" ) {
  Static STM_GETIMAGE := 0x173
  IfEqual, pGraph, 0, Return "",  ErrorLevel := -1 
  T := "`t",  TT := "`t:`t",  LF := "`n", SP := "        "

  pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData-8 )
  If ( FormatFloat <> "" and DataSz )
    GoTo, XGraph_Info_Data  
  
  VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen / ColumnW / Columns / "
      . "MarginL / MarginT / MarginR / MarginB / MX1 / MX2 / BitBltW / BitBltH" 
  Loop, Parse, VarL, /, %A_Space%
    Offset := ( A_Index - 1 )* 8,     %A_LoopField% := NumGet( pGraph + 0, OffSet )
  , RAW  .= SubStr( Offset SP,1,3 ) T SubStr( A_LoopField SP,1,16 ) T %A_LoopField% LF
  
  hTargetBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_GETIMAGE, "Ptr",0, "Ptr",0 )
  VarSetCapacity( BITMAP,32,0 )
  DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
  TBMW := NumGet( BITMAP,  4, "UInt" ),      TBMH := NumGet( BITMAP, 8, "UInt" )
  TBMB := NumGet( BITMAP, 12, "UInt" )* TBMH,   TBMZ := Round( TBMB/1024,2 )
  TBPP := NumGet( BITMAP, 18, "UShort" )
  Adj := ( Adj := TBMW - MarginL - BitBltW - MarginR ) ? " (-" Adj ")" : ""

  DllCall( "GetObject", "Ptr",hSourceBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
  SBMW := NumGet( BITMAP,  4, "UInt" ),      SBMH := NumGet( BITMAP, 8, "UInt" )
  SBMB := NumGet( BITMAP, 12, "UInt" )* SBMH,   SBMZ := Round( SBMB/1024,2 )
  SBPP := NumGet( BITMAP, 18, "UShort" )
  
  Return "GRAPH Properties" LF LF
  . "Screen BG Bitmap   " TT TBMW ( Adj ) "x" TBMH " " TBPP "bpp ( " TBMZ " KB )" LF
  . "Margins ( L,T,R,B )" TT MarginL "," MarginT "," MarginR "," MarginB LF 
  . "Client Area    " TT MarginL "," MarginT "," MarginL+BitBltW-1 "," MarginT+BitBltH-1 LF LF
  . "Memory Bitmap    " TT SBMW     "x" SBMH " " SBPP "bpp ( " SBMZ " KB )" LF 
  . "Graph Width    " TT BitBltW " px ( " Columns " cols x " ColumnW " px )" LF
  . "Graph Height (MY2) " TT BitBltH " px ( y0 to y" BitBltH - 1 " )" LF  
  . "Graph Array    " TT ( DataSz=0 ? "NA" : Columns " cols x 8 bytes = " DataSz " bytes" ) LF LF 
  . "Pen start position " TT MX1 "," BitBltH - 1 LF
  . "LineTo position  " TT MX2 "," "MY2" LF
  . "MoveTo position  " TT MX1 "," "MY2" LF LF
  . "STRUCTURE ( Offset / Variable / Raw value )" LF LF RAW

  XGraph_Info_Data:

  AFF := A_FormatFloat 
  SetFormat, FloatFast, %FormatFloat%
  Loop % DataSz // 8  
    Values .= SubStr( A_Index "   ", 1, 4  ) T NumGet( pData - 8, A_Index* 8, "Double" ) LF
  SetFormat, FloatFast, %AFF%
  StringTrimRight, Values, Values, 1                                      

  Return Values    
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_Plot( pGraph, MY2 := "", SetVal := "", Draw := 1 ) {
  Static SRCCOPY := 0x00CC0020

  IfEqual, pGraph, 0, Return "",  ErrorLevel := -1 
  pData   := pGraph + NumGet( pGraph + 0 ),   DataSz   := Numget( pData - 8 )

  , hSourceDC := NumGet( pGraph + 24 ),       BitBltW  := NumGet( pGraph + 112 )   
  , hTargetDC := NumGet( pGraph + 16 ),       BitBltH  := NumGet( pGraph + 120 )
  , ColumnW   := NumGet( pGraph + 48 )       

  , MarginL   := NumGet( pGraph + 64 ),       MX1 := NumGet( pGraph + 096 )
  , MarginT   := NumGet( pGraph + 72 ),       MX2 := NumGet( pGraph + 104 ) 

  If not ( MY2 = "" )                 
    DllCall( "BitBlt", "Ptr",hSourceDC, "Int",0, "Int",0, "Int",BitBltW + ColumnW, "Int",BitBltH
            , "Ptr",hSourceDC, "Int",ColumnW, "Int",0, "UInt",SRCCOPY )
  ,  DllCall( "LineTo",   "Ptr",hSourceDC, "Int",MX2, "Int",MY2 )
  ,  DllCall( "MoveToEx", "Ptr",hSourceDC, "Int",MX1, "Int",MY2, "Ptr",0 )
            
  If ( Draw = 1 ) 
    DllCall( "BitBlt", "Ptr",hTargetDC, "Int",MarginL, "Int",MarginT, "Int",BitBltW, "Int",BitBltH
            , "Ptr",hSourceDC, "Int",0, "Int",0, "UInt",SRCCOPY )

  If not ( MY2 = "" or SetVal = "" or DataSz = 0 ) 
    DllCall( "RtlMoveMemory", "Ptr",pData, "Ptr",pData + 8, "Ptr",DataSz - 8 )
  ,  NumPut( SetVal, pData + DataSz - 8, 0, "Double" )

  Return 1
  } 

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_SetVal( pGraph, Double := 0, Column := "" ) {

  IfEqual, pGraph, 0, Return "",  ErrorLevel := -1 
  pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData - 8 )
  IfEqual, DataSz, 0, Return 0

  If ( Column = "" )
    DllCall( "RtlMoveMemory", "Ptr",pData, "Ptr",pData + 8, "Ptr",DataSz - 8 )
    , pNumPut := pData + DataSz 
  else Columns := NumGet( pGraph + 56 ) 
    , pNumPut := pData + ( Column < 0 or Column > Columns ? Columns* 8 : Column* 8 )

  Return NumPut( Double, pNumPut - 8, 0, "Double" ) - 8     
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_GetVal( pGraph, Column := "" ) {
  Static RECT
  If not VarSetCapacity( RECT )
      VarSetCapacity( RECT, 16, 0 )

  IfEqual, pGraph, 0, Return "",  ErrorLevel := -1
  pData   := pGraph + NumGet( pGraph + 0 ),   DataSz  := Numget( pData - 8 )
  Columns := NumGet( pGraph + 56 )
  If not ( Column = "" or DataSz = 0 or Column < 1 or Column > Columns )
    Return NumGet( pData - 8, Column* 8, "Double" ),  ErrorLevel := Column

  hCtrl   := NumGet( pGraph + 8   ),      ColumnW := NumGet( pGraph + 48 )            
  , BitBltW := NumGet( pGraph + 112 ),      MarginL := NumGet( pGraph + 64 )
  , BitBltH := NumGet( pGraph + 120 ),      MarginT := NumGet( pGraph + 72 )

  , Numput( MarginL, RECT, 0, "Int" ),      Numput( MarginT, RECT, 4, "Int" )
  , DllCall( "ClientToScreen", "Ptr",hCtrl, "Ptr",&RECT )
  , DllCall( "GetCursorPos", "Ptr",&RECT + 8 )

  , MX := NumGet( RECT, 8, "Int" ) - NumGet( RECT, 0, "Int" ) 
  , MY := NumGet( RECT,12, "Int" ) - NumGet( RECT, 4, "Int" )

  , Column := ( MX >= 0 and MY >= 0 and MX < BitBltW and MY < BitBltH ) ? MX // ColumnW + 1 : 0
  Return ( DataSz and Column ) ? NumGet( pData - 8, Column* 8, "Double" ) : "",  ErrorLevel := Column  
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_GetMean( pGraph, TailCols := "" ) {

  IfEqual, pGraph, 0, Return "",  ErrorLevel := -1 
  pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData - 8 )
  IfEqual, DataSz, 0, Return 0,   ErrorLevel := 0

  Columns := NumGet( pGraph + 56 )
  pDataEnd := pGraph + NumGet( pGraph + 0 ) + ( Columns* 8 )
  TailCols := ( TailCols = "" or TailCols < 1 or Tailcols > Columns ) ? Columns : TailCols

  Loop %TailCols%
    Value += NumGet( pDataEnd - ( A_Index* 8 ), 0, "Double"  )

  Return Value / TailCols,      ErrorLevel := TailCols
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_Detach( pGraph ) {
  IfEqual, pGraph, 0, Return 0
  
  VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen"
  Loop, Parse, VarL, /, %A_Space%
    %A_LoopField% := NumGet( pGraph + 0, ( A_Index - 1 )* 8 )

  DllCall( "ReleaseDC",  "Ptr",hCtrl, "Ptr",hTargetDC )
  DllCall( "RestoreDC",  "Ptr",hSourceDC, "Int",-1  )
  DllCall( "DeleteDC",   "Ptr",hSourceDC  )
  DllCall( "DeleteObject", "Ptr",hSourceBM  )         
  DllCall( "DeleteObject", "Ptr",hSourcePen )

  Return DllCall( "GlobalFree", "Ptr",pGraph, "Ptr"  )   
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  XGraph_MakeGrid(  CellW, CellH, Cols, Rows, GLClr, BGClr, ByRef BMPW := "", ByRef BMPH := "" ) {
  Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
    ,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4 
    ,  DC_PEN := 19

  BMPW := CellW* Cols + 1,  BMPH := CellH* Rows + 1
  hTempDC := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
  DllCall( "SaveDC", "Ptr",hTempDC )
  
  If ( DllCall( "GetObjectType", "Ptr",BGClr ) = 0x7 ) 
    hTBM := DllCall( "CopyImage", "Ptr",BGClr, "Int",0, "Int",BMPW, "Int",BMPH, "UInt",LR_Flag2, "UPtr" )
  , DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTBM )

  Else 
    hTBM := DllCall( "CreateBitmap", "Int",2, "Int",2, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )
  , hTBM := DllCall( "CopyImage", "Ptr",hTBM,  "Int",0, "Int",BMPW, "Int",BMPH, "UInt",LR_Flag1, "UPtr" )
  , DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTBM )
  , hBrush := DllCall( "CreateSolidBrush", "UInt",BGClr & 0xFFFFFF, "Ptr" )
  , VarSetCapacity( RECT, 16 )
  , NumPut( BMPW, RECT, 8, "UInt" ),  NumPut( BMPH, RECT, 12, "UInt" )
  , DllCall( "FillRect", "Ptr",hTempDC, "Ptr",&RECT, "Ptr",hBrush )
  , DllCall( "DeleteObject", "Ptr",hBrush )

  hPenDC := DllCall( "GetStockObject", "Int",DC_PEN, "Ptr" ) 
  DllCall( "SelectObject",  "Ptr",hTempDC, "Ptr",hPenDC )
  DllCall( "SetDCPenColor", "Ptr",hTempDC, "UInt",GLClr & 0xFFFFFF )

  Loop, % Rows + 1 + ( X := Y := 0 )  
    DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X,  "Int",Y, "Ptr",0  )
  , DllCall( "LineTo",   "Ptr",hTempDC, "Int",BMPW, "Int",Y ),  Y := Y + CellH
  
  Loop, % Cols + 1 + ( X := Y := 0 )
    DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X, "Int",Y, "Ptr",0 )
  , DllCall( "LineTo",   "Ptr",hTempDC, "Int",X, "Int",BMPH ),  X := X + CellW

  DllCall( "RestoreDC", "Ptr",hTempDC, "Int",-1 )
  DllCall( "DeleteDC",  "Ptr",hTempDC )  

  Return hTBM
  }

  ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

  CreateDIB( PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1  ) {    
    ; http://ahkscript.org/boards/viewtopic.php?t=3203          SKAN, CD: 01-Apr-2014 MD: 05-May-2014
    Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
      ,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4 
      ,  LR_Flag3 := 0x0008 ; LR_COPYDELETEORG := 8

    WB := Ceil( ( W* 3 ) / 2 )* 2,  VarSetCapacity( BMBITS, WB* H + 1, 0 ),  P := &BMBITS
    Loop, Parse, PixelData, |
      P := Numput( "0x" A_LoopField, P+0, 0, "UInt" ) - ( W & 1 and Mod( A_Index* 3, W* 3 ) = 0 ? 0 : 1 )

    hBM := DllCall( "CreateBitmap", "Int",W, "Int",H, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )  
    hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag1, "Ptr" ) 
    DllCall( "SetBitmapBits", "Ptr",hBM, "UInt",WB* H, "Ptr",&BMBITS )

    If not ( Gradient + 0 )
      hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag3, "Ptr" )  
  Return DllCall( "CopyImage", "Ptr",hBM, "Int",0, "Int",ResizeW, "Int",ResizeH, "Int",LR_Flag2, "UPtr" )
  }  

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/* DeepClone v1 : A library of functions to make unlinked array Clone
 ;
 ; Function:
 ; Array_Print
 ; Description:
 ; Quick and dirty text visualization of an array
 ; Syntax:
 ; Arrary_Print(Array)
 ; Parameters:
 ; Param1 - Array
 ; An array, associative array, or object.
 ; Return Value:
 ; A text visualization of the input array
 ; Remarks:
 ; Supports sub-arrays
 ; Related:
 ; Array_Gui, Array_DeepClone, Array_IsCircle
 ; Example:
 ; MsgBox, % Array_Print({"A":["Aardvark", "Antelope"], "B":"Bananas"})
 ;
 ;
 ; Function:
 ; Array_Gui
 ; Description:
 ; Displays an array as a treeview in a GUI
 ; Syntax:
 ; Array_Gui(Array)
 ; Parameters:
 ; Param1 - Array
 ; An array, associative array, or object.
 ; Return Value:
 ; Null
 ; Remarks:
 ; Resizeable
 ; Related:
 ; Array_Print, Array_DeepClone, Array_IsCircle
 ; Example:
 ; Array_Gui({"GeekDude":["Smart", "Charming", "Interesting"], "tidbit":"Weird"})
 ;
 ;
 ; Function:
 ; Array_DeepClone
 ; Description:
 ; Deep clone
 ; Syntax:
 ; Arrary_DeepClone(Array)
 ; Parameters:
 ; Param1 - Array
 ; An array, associative array, or object.
 ; Return Value:
 ; A copy of the array, that is not linked to the original
 ; Remarks:
 ; Supports sub-arrays, and circular refrences
 ; Related:
 ; Array_Gui, Array_Print, Array_IsCircle
 ; Example:
 ; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
 ; Array2 := Array_DeepClone(Array1)
 ;
 ;
 ; Function:
 ; Array_IsCircle
 ; Description:
 ; Checks for circular refrences that could crash my other functions
 ; Syntax:
 ; Arrary_IsCircle(Array)
 ; Parameters:
 ; Param1 - Array
 ; An array, associative array, or object.
 ; Return Value:
 ; Boolean value according to whether it has a circular refrence
 ; Remarks:
 ; Takes an average of 0.023 seconds
 ; Related:
 ; Array_Gui, Array_Print(), Array_DeepClone()
 ; Example:
 ; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
 ; Array2 := Array_Copy(Array1)
 ;
 */
 
  Array_Print(Array) {
  if Array_IsCircle(Array)
      return "Error: Circular refrence"
    For Key, Value in Array
    {
      If Key is not Number
        Output .= """" . Key . """:"
      Else
        Output .= Key . ":"
      
      If (IsObject(Value))
        Output .= "[" . Array_Print(Value) . "]"
      Else If Value is not number
        Output .= """" . Value . """"
      Else
        Output .= Value
      
      Output .= ", "
    }
    StringTrimRight, OutPut, OutPut, 2
    Return OutPut
  }

  Array_Gui(Array, Parent="") {
    static
    global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
    if Array_IsCircle(Array)
    {
      MsgBox, 16, GuiArray, Error: Circular refrence
      return "Error: Circular refrence"
    }
    if !Parent
    {
      Gui, +HwndDefault
      Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
      Gui, Add, TreeView, vGuiArrayTree
      
      Parent := "P1"
      %Parent% := TV_Add("Array", 0, "+Expand")
      Array_Gui(Array, Parent)
      GuiControlGet, GuiArrayTree, Pos
      Gui, Show,, GuiArray
      Gui, %Default%:Default
      
      WinWaitActive, ahk_id%GuiArray%
      WinWaitClose, ahk_id%GuiArray%
      return
    }
    For Key, Value in Array
    {
      %Parent%C%A_Index% := TV_Add(Key, %Parent%)
      KeyParent := Parent "C" A_Index
      if (IsObject(Value))
        Array_Gui(Value, KeyParent)
      else
        %KeyParent%C1 := TV_Add(Value, %KeyParent%)
    }
    return
    
    GuiArrayClose:
    Gui, Destroy
    return
    
    GuiArraySize:
    if !(A_GuiWidth || A_GuiHeight) ; Minimized
      return
    GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX* 2) " h" A_GuiHeight - (GuiArrayTreeY* 2)
    return
  }
 
  Array_DeepClone(Array, Objs=0)
  {
    if !Objs
      Objs := OrderedArray()
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key, Val in Obj
      if (IsObject(Val)) ; If it is a subarray
        Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
        ? Objs[&Val] ; Then point it to the new array
        : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
    return Obj
  }

  Array_IsCircle(Obj, Objs=0)
  {
    if !Objs
      Objs := {}
    For Key, Val in Obj
      if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
        return 1
    return 0
  }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



;{[Function] Decimal2Fraction and Fraction2Decimal
  ; Fanatic Guru
  ; 2013 12 21
  ; Version 1.9
  ;
  ; Function to Convert a Decimal Number to a Fraction String
  ;
  ;------------------------------------------------
  ;
  ; Method:
  ;   Decimal2Fraction(Decimal, Options)
  ;
  ;   Parameters:
  ;   1) {Decimal}         A decimal number to be converted to a fraction string
  ;   2) {Options ~= {Number}}    Round to this fractional Percision ie. 32 would round to the closest 1/32nd
  ;    {Options ~= {D}{Number}}  Round fractional to a {Number} limit of digits ie. D5 limits fraction to 5 digits
  ;    {Options ~= "I"}      Return Improper Fraction
  ;    {Options ~= "AA"}      Return in Architectural format with feet and inches
  ;    {Options ~= "A"}      Return in Architectural format with inches only
  ;       Optional
  ;
  ;
  ; Example:
  ;  MsgBox % Decimal2Fraction(1.2345)
  ;  MsgBox % Decimal2Fraction(1.2345,"I")
  ;  MsgBox % Decimal2Fraction(1.2345,"A")      ; Convert Decminal Inches to Inches Fraction/Inches"
  ;  MsgBox % Decimal2Fraction(1.2345,"AI")      ; Convert Decminal Inches to Fraction/Inches"
  ;  MsgBox % Decimal2Fraction(1.2345,"AA16")     ; Convert Decimal Feet to Feet'-Inches Fraction/16th Inches"
  ;  MsgBox % Decimal2Fraction(14.28571428571429,"D5")  ; Convert with round to a limit of 5 digit fraction
  ;  MsgBox % Decimal2Fraction(.28571428571429,"AAD5")  ; Convert Decimal Feet to Feet'-Inches Fraction/Inches" with round to a limit of 5 digit fraction

  Decimal2Fraction(Decimal, Options := "" )
  {
    FormatFloat := A_FormatFloat
    SetFormat, FloatFast, 0.15
    Whole := 0
    if (Options ~= "i)D")
      Digits := RegExReplace(Options,"\D*(\d*)\D*","$1"), (Digits > 15 ? Digits := 15 : )
    else
      Precision := RegExReplace(Options,"\D*(\d*)\D*","$1")
    if (Options ~= "i)AA")
      Feet := Floor(Decimal), Decimal -= Feet, Inches := Floor(Decimal* 12), Decimal := Decimal* 12 - Inches
    if !(Options ~= "i)I")
      Whole := Floor(Decimal), Decimal -= Whole
    RegExMatch(Decimal,"^(\d*)\.?(\d*?)0*$",Match), N := Match1 Match2
    D := 10** StrLen(Match2)
    if Precision
      N := Round(N / D* Precision), D := Precision
    Repeat_Digits:
    Original_N := N, Original_D := D 
    Repeat_Reduce:
    X := 0, Temp_D := D 
    while X != 1
      X := GCD(N,D), N := N / X, D := D / X
    if Digits
    {
      if (Temp_D = D and D > 1)
      {
        if Direction
          ((N/ D < Decimal) ? N+= 1 : D += 1)
        else
          ((N/ D > Decimal) ? N-= 1 : D -= 1)
        goto Repeat_Reduce
      }
      if !Direction
      {
        N_Minus := Floor(N), D_Minus := Floor(D), N := Original_N, D := Original_D, Direction := !Direction
        goto Repeat_Reduce
      }
      N_Plus := Floor(N), D_Plus := Floor(D)
      if (StrLen(D_Plus) <= Digits and StrLen(D_Minus) > Digits)
        N := N_Plus, D := D_Plus
      else if (StrLen(D_Minus) <= Digits and StrLen(D_Plus) > Digits)
        N := N_Minus, D := D_Minus
      else
        if (Abs(Decimal - (N_Plus / D_Plus)) < Abs(Decimal - (N_Minus / D_Minus)))
          N := N_Plus, D := D_Plus
        else
          N := N_Minus, D := D_Minus
      if (StrLen(D) > Digits)
      {
        Direction := 0
        goto Repeat_Digits
      }
    }
    if (D = 1 and !(Options ~= "i)Inches"))
    {
      if (Options ~= "i)AA")
      {
        Inches += N
        if (Inches = 12)
          Feet ++=, Inches := 0
      }
      else
        Whole += N
      N := 0
    }
    N := Floor(N)
    D := Floor(D)
    if (Options ~= "i)AA")
      Output := Feet "'-" Inches (N and D ? " " N "/" D:"")"""" 
    else
      Output := (Whole ? Whole " ":"") (N and D ? N "/" D:"")((Options ~= "i)A") ? """":"")
    SetFormat, FloatFast, %FormatFloat%
    return (Whole + N ? Trim(Output) : 0)
  }

  GCD(A, B) 
  {
    while B 
    B := Mod(A|0x0, A:=B)
    return A
  }
  ;{[Function] Fraction2Decimal
  ; Fanatic Guru
  ; 2013 12 18
  ; Version 1.6
  ;
  ; Function to Fraction String to a Decimal Number
  ;   Tries to account for any phrasing of feet and inches 
  ;------------------------------------------------
  ;
  ; Method:
  ;   Fraction2Decimal(Fraction, Unit)
  ;
  ;   Parameters:
  ;   1) {Fraction}     A string representing a fraction to be converted to a decimal number
  ;   2) {Unit} = true  Include feet or inch symbol in return
  ;    {Unit} = false   Do not include feet or inch symbol in return
  ;       Optional - Default to false
  ;
  ; Example:
  ;   MsgBox % Fraction2Decimal("7/8")
  ;   MsgBox % Fraction2Decimal("1 7/8")
  ;   MsgBox % Fraction2Decimal("1-7/8""") ; "" required to escape a literal " for testing
  ;   MsgBox % Fraction2Decimal("2'1-7/8""") ; "" required to escape a literal " for testing
  ;   MsgBox % Fraction2Decimal("2'-1 7/8""") ; "" required to escape a literal " for testing
  ;   MsgBox % Fraction2Decimal("2' 1"" 7/8") ; "" required to escape a literal " for testing
  ;

  Fraction2Decimal(Fraction, Unit := false)
  {
      FormatFloat := A_FormatFloat
    SetFormat, FloatFast, 0.15
      Num := {}
      N := 0
      D := 1
      if RegExMatch(Fraction, "^\s*-")
        Has_Neg := true
      if RegExMatch(Fraction, "i)feet|foot|ft|'")
        Has_Feet := true
      if RegExMatch(Fraction, "i)inch|in|""")
        Has_Inches := true
      if RegExMatch(Fraction, "i)/|of|div")
        Has_Fraction := true
      Output := Trim(Fraction,"""'")
      if Output is number
      {
        SetFormat, FloatFast, %FormatFloat%
        return Output (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
      }
      RegExMatch(Fraction,"^[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)",Match)
      Loop 4
        if !(Match%A_Index% = "")
          Num.Insert(Match%A_Index%)
      if Has_Fraction
      {
        N := Num[Num.MaxIndex()-1]
        D := Num[Num.MaxIndex()]
      }
      Output := (Num.MaxIndex() = 2 ? N / D : (Num[1]) + N / D)
      if (Has_Feet &  Has_Inches)
        if (Num.MaxIndex() = 2)
          Output := Num[1] + Num[2] /12
        else
          Output := Num[1] + ((Num.MaxIndex() = 3 ? 0:Num[2]) + N / D) / 12
      Output := (Has_Neg ? "-":"") (Output ~= "." ? RTrim(RTrim(Output,"0"),".") : Output) (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
      SetFormat, FloatFast, %FormatFloat%
      return Output
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*** Class_CtlColors
 * Lib: Class_CtlColors.ahk
 *   Found on page: https://github.com/AHK-just-me/Class_CtlColors
 * Version:
 *   v1.0.03 [updated 10/31/2017 (MM/DD/YYYY)]
 * Class_CtlColors
 *  Choose your own background and/or text colors for some AHK GUI controls.
 *
 * How to use
 *  To register a control for coloring call CtlColors.Attach() passing up to three parameters:
 *
 *    HWND  - HWND of the GUI control
 *    BkColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
 *    ------- Optional 
 *    TxColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
 *
 *    If both BkColor and TxColor are "" the control will not be added and the call returns False.
 *
 *  To change the colors for a registered control call CtlColors.Change() passing up to three parameters:
 *
 *    HWND  - see above
 *    BkColor - see above
 *    ------- Optional
 *    TxColor - see above
 *
 *    Both BkColor and TxColor may be "" to reset them to default colors. If the control is not registered yet, CtlColors.Attach() is called internally.
 *
 *  To unregister a control from coloring call CtlColors.Detach() passing one parameter:
 *
 *    HWND  - see above
 *
 *  To stop all coloring and free the resources call CtlColors.Free(). It's a good idea to insert this call into the scripts exit-routine.
 *
 *  To check if a control is already registered call CtlColors.IsAttached() passing one parameter:
 *
 *    HWND  - see above
 *
 *  To get a control's HWND use either the option HwndOutputVar with Gui, Add or the command GuiControlGet with sub-command Hwnd.
 */
 ; ======================================================================================================================
 ; AHK 1.1+
 ; ======================================================================================================================
 ; Function:      Auxiliary object to color controls on WM_CTLCOLOR... notifications.
 ;          Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
 ;          Checkboxes and Radios accept only background colors due to design.
 ; Namespace:     CtlColors
 ; Tested with:     1.1.25.02
 ; Tested on:     Win 10 (x64)
 ; Change log:    1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
 ;          1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
 ;          1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
 ;          1.0.01.00/2014-02-15/just me  -  changed class initialization.
 ;          1.0.00.00/2014-02-14/just me  -  initial release.
 ; ======================================================================================================================
 ; This software is provided 'as-is', without any express or implied warranty.
 ; In no event will the authors be held liable for any damages arising from the use of this software.
 ; ======================================================================================================================
   Class CtlColors {
  ; ===================================================================================================================
  ; Class variables
  ; ===================================================================================================================
  ; Registered Controls
  Static Attached := {}
  ; OnMessage Handlers
  Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
  ; Message Handler Function
  Static MessageHandler := "CtlColors_OnMessage"
  ; Windows Messages
  Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
  ; HTML Colors (BGR)
  Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
          , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
          , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
  ; Transparent Brush
  Static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
  ; System Colors
  Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
  ; Error message in case of errors
  Static ErrorMsg := ""
  ; Class initialization
  Static InitClass := CtlColors.ClassInit()
  ; ===================================================================================================================
  ; Constructor / Destructor
  ; ===================================================================================================================
  __New() { ; You must not instantiate this class!
    If (This.InitClass == "!DONE!") { ; external call after class initialization
      This["!Access_Denied!"] := True
      Return False
    }
  }
  ; ----------------------------------------------------------------------------------------------------------------
  __Delete() {
    If This["!Access_Denied!"]
      Return
    This.Free() ; free GDI resources
  }
  ; ===================================================================================================================
  ; ClassInit     Internal creation of a new instance to ensure that __Delete() will be called.
  ; ===================================================================================================================
  ClassInit() {
    CtlColors := New CtlColors
    Return "!DONE!"
  }
  ; ===================================================================================================================
  ; CheckBkColor  Internal check for parameter BkColor.
  ; ===================================================================================================================
  CheckBkColor(ByRef BkColor, Class) {
    This.ErrorMsg := ""
    If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
      This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
      Return False
    }
    BkColor := BkColor = "" ? This.SYSCOLORS[Class]
        :  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
        :  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
    Return True
  }
  ; ===================================================================================================================
  ; CheckTxColor  Internal check for parameter TxColor.
  ; ===================================================================================================================
  CheckTxColor(ByRef TxColor) {
    This.ErrorMsg := ""
    If (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
      This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
      Return False
    }
    TxColor := TxColor = "" ? ""
        :  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
        :  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
    Return True
  }
  ; ===================================================================================================================
  ; Attach      Registers a control for coloring.
  ; Parameters:   HWND    - HWND of the GUI control                   
  ;         BkColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
  ;         ----------- Optional 
  ;         TxColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
  ; Return values:  On success  - True
  ;         On failure  - False, CtlColors.ErrorMsg contains additional informations
  ; ===================================================================================================================
  Attach(HWND, BkColor, TxColor := "") {
    ; Names of supported classes
    Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
    ; Button styles
    Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
    ; Editstyles
    Static ES_READONLY := 0x800
    ; Default class background colors
    Static COLOR_3DFACE := 15, COLOR_WINDOW := 5
    ; Initialize default background colors on first call -------------------------------------------------------------
    If (This.SYSCOLORS.Edit = "") {
      This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
      This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
      This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
    }
    This.ErrorMsg := ""
    ; Check colors ---------------------------------------------------------------------------------------------------
    If (BkColor = "") && (TxColor = "") {
      This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
      Return False
    }
    ; Check HWND -----------------------------------------------------------------------------------------------------
    If !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "UInt") {
      This.ErrorMsg := "Invalid parameter HWND: " . HWND
      Return False
    }
    If This.Attached.HasKey(HWND) {
      This.ErrorMsg := "Control " . HWND . " is already registered!"
      Return False
    }
    Hwnds := [CtrlHwnd]
    ; Check control's class ------------------------------------------------------------------------------------------
    Classes := ""
    WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
    This.ErrorMsg := "Unsupported control class: " . CtrlClass
    If !ClassNames.HasKey(CtrlClass)
      Return False
    ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
    If (CtrlClass = "Edit")
      Classes := ["Edit", "Static"]
    Else If (CtrlClass = "Button") {
      IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
        Classes := ["Static"]
      Else
        Return False
    }
    Else If (CtrlClass = "ComboBox") {
      VarSetCapacity(CBBI, 40 + (A_PtrSize* 3), 0)
      NumPut(40 + (A_PtrSize* 3), CBBI, 0, "UInt")
      DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
      Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize* 2, "UPtr")) + 0)
      Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
      Classes := ["Edit", "Static", "ListBox"]
    }
    If !IsObject(Classes)
      Classes := [CtrlClass]
    ; Check background color -----------------------------------------------------------------------------------------
    If (BkColor <> "Trans")
      If !This.CheckBkColor(BkColor, Classes[1])
        Return False
    ; Check text color -----------------------------------------------------------------------------------------------
    If !This.CheckTxColor(TxColor)
      Return False
    ; Activate message handling on the first call for a class --------------------------------------------------------
    For I, V In Classes {
      If (This.HandledMessages[V] = 0)
        OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
      This.HandledMessages[V] += 1
    }
    ; Store values for HWND ------------------------------------------------------------------------------------------
    If (BkColor = "Trans")
      Brush := This.NullBrush
    Else
      Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
    For I, V In Hwnds
      This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
    ; Redraw control -------------------------------------------------------------------------------------------------
    DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
    This.ErrorMsg := ""
    Return True
  }
  ; ===================================================================================================================
  ; Change      Change control colors.
  ; Parameters:   HWND    - HWND of the GUI control
  ;         BkColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
  ;         ----------- Optional 
  ;         TxColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
  ; Return values:  On success  - True
  ;         On failure  - False, CtlColors.ErrorMsg contains additional informations
  ; Remarks:    If the control isn't registered yet, Add() is called instead internally.
  ; ===================================================================================================================
  Change(HWND, BkColor, TxColor := "") {
    ; Check HWND -----------------------------------------------------------------------------------------------------
    This.ErrorMsg := ""
    HWND += 0
    If !This.Attached.HasKey(HWND)
      Return This.Attach(HWND, BkColor, TxColor)
    CTL := This.Attached[HWND]
    ; Check BkColor --------------------------------------------------------------------------------------------------
    If (BkColor <> "Trans")
      If !This.CheckBkColor(BkColor, CTL.Classes[1])
        Return False
    ; Check TxColor ------------------------------------------------------------------------------------------------
    If !This.CheckTxColor(TxColor)
      Return False
    ; Store Colors ---------------------------------------------------------------------------------------------------
    If (BkColor <> CTL.BkColor) {
      If (CTL.Brush) {
        If (Ctl.Brush <> This.NullBrush)
        DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
        This.Attached[HWND].Brush := 0
      }
      If (BkColor = "Trans")
        Brush := This.NullBrush
      Else
        Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
      For I, V In CTL.Hwnds {
        This.Attached[V].Brush := Brush
        This.Attached[V].BkColor := BkColor
      }
    }
    For I, V In Ctl.Hwnds
      This.Attached[V].TxColor := TxColor
    This.ErrorMsg := ""
    DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
    Return True
  }
  ; ===================================================================================================================
  ; Detach      Stop control coloring.
  ; Parameters:   HWND    - HWND of the GUI control
  ; Return values:  On success  - True
  ;         On failure  - False, CtlColors.ErrorMsg contains additional informations
  ; ===================================================================================================================
  Detach(HWND) {
    This.ErrorMsg := ""
    HWND += 0
    If This.Attached.HasKey(HWND) {
      CTL := This.Attached[HWND].Clone()
      If (CTL.Brush) && (CTL.Brush <> This.NullBrush)
        DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
      For I, V In CTL.Classes {
        If This.HandledMessages[V] > 0 {
        This.HandledMessages[V] -= 1
        If This.HandledMessages[V] = 0
          OnMessage(This.WM_CTLCOLOR[V], "")
      }  }
      For I, V In CTL.Hwnds
        This.Attached.Remove(V, "")
      DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
      CTL := ""
      Return True
    }
    This.ErrorMsg := "Control " . HWND . " is not registered!"
    Return False
  }
  ; ===================================================================================================================
  ; Free      Stop coloring for all controls and free resources.
  ; Return values:  Always True.
  ; ===================================================================================================================
  Free() {
    For K, V In This.Attached
      If (V.Brush) && (V.Brush <> This.NullBrush)
        DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
    For K, V In This.HandledMessages
      If (V > 0) {
        OnMessage(This.WM_CTLCOLOR[K], "")
        This.HandledMessages[K] := 0
      }
    This.Attached := {}
    Return True
  }
  ; ===================================================================================================================
  ; IsAttached    Check if the control is registered for coloring.
  ; Parameters:   HWND    - HWND of the GUI control
  ; Return values:  On success  - True
  ;         On failure  - False
  ; ===================================================================================================================
  IsAttached(HWND) {
    Return This.Attached.HasKey(HWND)
  }
  }
  ; ======================================================================================================================
  ; CtlColors_OnMessage
  ; This function handles CTLCOLOR messages. There's no reason to call it manually!
  ; ======================================================================================================================
   CtlColors_OnMessage(HDC, HWND) {
  Critical
  If CtlColors.IsAttached(HWND) {
    CTL := CtlColors.Attached[HWND]
    If (CTL.TxColor != "")
      DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CTL.TxColor)
    If (CTL.BkColor = "Trans")
      DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "UInt", 1) ; TRANSPARENT = 1
    Else
      DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", CTL.BkColor)
    Return CTL.Brush
  }
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



;_______________________ Hotkey() _______________________
 ;____ Date: June 2006
 ;____ AHK version: 1.0.44.06
 ;____ Platform: WinXP
 ;____ Authors: Sam & Roland


  ;#################### Example Gui ########################
  /*
  #SingleInstance, force

  Gui, Margin, 5, 5
  Gui, Add, Text,, Hotkey(Options="",Prompt="",Title="",GuiNumber=77)
  Gui, Font, s10
  Gui, Add, Text, w500
  ,Options:`n-Keynames/-Symbols -LR -~ -* -UP -Joystick -Mouse -Mods -&& +Default1/2 +OwnerN -Owner -Modal +ReturnKeynames +Tooltips

  E1 = Hotkey()
  E2 = Hotkey("+Default1 -LR -UP","Please hold down the keys you want to turn into a hotkey:")
  E3 = Hotkey("+Default1 -Symbols +ReturnKeynames +Tooltips","","","Hotkey configuration")
  E4 = Hotkey("+Default2 -Mouse -Keynames -Modal -LR","Note that you're able to interact with the owner")
  E5 = Hotkey("-~ -* -Up -LR +Owner2","This window has no owner, since a non-existen owner (Gui2) was specified")

  Gui, Font, s8
  Loop, 5
    {
      Gui, Add, Text, w500, % E%a_index% ":"
      Gui, Add, ListView
      , v%a_index% r1 -Hdr -LV0x20 r1 w200 cGreen BackgroundFFFACD gLV_DblClick, 1|2
      LV_ModifyCol(1, 0)
      LV_ModifyCol(2, 195)
    }
  Gui, Font, s10
  Gui, Add, Text, w500, Note: Double-click on one on one of the ListViews to test the Hotkey dialogue.
  Gui, Show, x100 y100 Autosize, Hotkey()  
  Return

  GuiClose:
  ExitApp

  LV_DblClick:
  If a_guicontrolevent <> DoubleClick
    return
  Gui, ListView, %a_guicontrol%
  LV_Delete(1)
  If a_guicontrol = 1
      LV_Add("","",Hotkey())
  else if a_guicontrol = 2
      LV_Add("","",Hotkey("+Default1 -LR -UP","Please hold down the keys you want to turn into a hotkey:"))
  else if a_guicontrol = 3
      LV_Add("","",Hotkey("+Default1 -Symbols +ReturnKeynames +Tooltips","","","Hotkey configuration"))
  else if a_guicontrol = 4
      LV_Add("","",Hotkey("+Default2 -Mouse -Keynames -Modal -LR","Note that you're able to interact with the owner"))
  else if a_guicontrol = 5
      LV_Add("","",Hotkey("-~ -* -Up -LR +Owner2","This window has no owner, since a non-existen owner (Gui2) was specified"))
  return
  */

 /*
 #############################################################################
 ################################ Remarks ####################################
 #############################################################################
 **************************************************** Remarks: **************************************************
 * -It would have been to hard (and to messy) to compact everything into a single funtion, so we have a few globals.
 *   All the globals (and all the subroutines) start with "Hotkey_" though, so this shouldn't be a problem
 * -Both the keyboard and mouse hook will be installed 
 * -"Critical" has to be turned off for the thread that called the funtion, to allow the threads in the funtion to run.
 * This could cause problems obviously, although turning Critical back on after calling the funtion should work okay in most cases
 * -When the user clicks "Submit", the funtion will create the hotkey (If non-blank) and check ErrorLevel (and If ErrorLevel <> 0 
 *   display a Msgbox saying the hotkey is invalid and asking to notify the author). This way you shouldn't have to worry about 
 * invalid hotkeys yourself.
 * -You can easily change the default color and font by editing the default values right at the top of the funtion.
 *   Should be easy to spot.
 * -Also, You can easily change the default behavior by changing the Options param right at the top of the funtion
 *   (for instance: Options = %Options% +Default1 -Mouse). You can also edit the keyList of course.
 ########################## The main funtion ############################
  Note: The following funtions must all be present (they are included here, but I thought 
      I had better mention it):
      
  Hotkey(Options="",Prompt="",BottomInfo="",Title="",GuiNumber=77)
  AddPrefixSymbols(keys)
  KeysToSymbols(s)
  Keys()
  ToggleOperator(p)
  IsHotkeyValid(k)


  ######## Options ########
  Zero or more of the following strings may be present in Options. ; Spaces are optional, 
  i.e. "-~-*+Default2" is valid. -/+ are NOT optional, though. I.e. "Owner3" is invalid:

  -Keynames/-Symbols: Omits one of the ListViews
  -LR: Omit the "left/right modifiers" checkbox (forced for Win95/98/ME)
  -~, -*, -Up: Omit one or more of the corresponding checkboxes (forced for Win95/98/ME)
  -Joystick/-Mouse: No joystick and/or mouse hotkeys
  -Mods: No modifers
  -&: No ampersand hotkeys (forced for Win95/98/ME)
  +Default1, +Default2: Sets the default button (and omits the Enter key from the keyList)
  +Owner*: Sets the owner. Default is A_Gui, or 1 If A_Gui is blank (or none If Gui1 doesn't exist)
  -Owner: No owner
  -Modal: The dialogue will be owned, but not modal
  +ReturnKeynames: Return "Control+Alt+c" instead of "^!c" etc. These can later be converted by calling the KeysToSymbols(s) funtion
  +Tooltips: Gives a little info about "~", "*" and "UP" (basically copied from the docs)
  */
 

  ;this funtion will Return a (hopfully) valid key combination, either
  ;as symbols (^!+..) or as keynames (Control+Alt+Shift+Space...)
  Hotkey(Options="",Prompt="",BottomInfo="",Title="",GuiNumber=77)
  {
    global Hotkey_LeftRightMods,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_Hotkey1,Hotkey_Hotkey2
          ,Hotkey_ButtonSubmit,Hotkey_ButtonCancel,Hotkey_DefaultButton,Hotkey_keyList,Hotkey_modList_left_right
          ,Hotkey_modList_normal,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

    ;these are all cleared again before the funtion Returns, to be on the safe side
    HotKey_globals = Hotkey_LeftRightMods,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_Hotkey1,Hotkey_Hotkey2
          ,Hotkey_ButtonSubmit,Hotkey_ButtonCancel,Hotkey_DefaultButton,Hotkey_keyList,Hotkey_modList_left_right
          ,Hotkey_modList_normal,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

    batch_lines = %A_BatchLines%
    SetBatchLines -1    ;this speeds things up a bit (we reset it after the Gui is shown)

    ;change these to suit your needs:
    ;default colors, etc. 
    defBgColor = 
    defTxtColor = 000000
    defLVBgColor = FFFFFF
    defLVTxtColor1 = Green
    defLVTxtColor2 = 6495ED
    defFontName = Arial
    defFontSize = 8
    defTitle = Hotkey

    ;Note: To change the default behavior permenantly, just add:
    ;Options = %Options%***MyFavoriteOptions*** 

    ;we can't have the special prefix symbols or the & on Win95/98/ME
    ;so we just edit the Options param to exclude them
    If A_OSType = WIN32_WINDOWS    
      Options = %Options%-~-*-Up-&-lr

    ;this is a bit akward but we have to store the Gui # in a seperate variable
    ;because GuiNumber is a parameter and we can't declare it as global
    If GuiNumber <>
      Hotkey_numGui = %GuiNumber%
    Else
      Hotkey_numGui = 77

    ;because we use ListViews (who operate on the default Gui), we have
    ;to set the default in every thread that operates on the ListViews
    Gui, %Hotkey_numGui%: Default  

    ;it's global, so we have to empty it
    Hotkey_JoystickButtons =
    ;get a list of joystick buttons
    IfNotInString, Options, -Joystick
    {
    ;Query each joystick number to find out which ones exist.
    Loop 32
    {
      ;If the joystick has a name
      GetKeyState, joy_name, %A_Index%JoyName
      If joy_name <>
      {
      ;It's our joystick.
      joy_number = %A_Index%
      joy_exists = 1
      break
      }
    }
    ;If we don't have a joystick
    If joy_number <= 0
    {
      ;record it so.
      joy_exists = 0
    }
    ;If we do have a joystick
    Else
    {
      ;Determine the number of buttons.
      GetKeyState, num_buttons, %joy_number%JoyButtons
      ;Go through the buttons
      Loop, %num_buttons%
      {
      newButton = Joy%a_index%
      Hotkey_JoystickButtons = %Hotkey_JoystickButtons%,%newButton%
      }
      StringTrimLeft, Hotkey_JoystickButtons, Hotkey_JoystickButtons, 1
    }
    }

    ;the main key list. Add (or delete) keys to suit your needs
    Hotkey_keyList =
    ( Join
    #|.|,|-|<|+|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|ü|ä|ö|ß|1|2|3|4|5|6|7|8|9|0
    |Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9
    |NumpadClear|Right|Left|Up|Down|NumpadDot|Space|Tab|Escape|Backspace|Delete|Insert|Home
    |End|PgUp|PgDn|ScrollLock|CapsLock|NumLock|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub
    |F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|AppsKey|PrintScreen|CtrlBreak|Pause|Break
    |Browser_Back|Browser_Forward|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute
    |Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media
    |Launch_App1|Launch_App2|Sleep
    )

    ;If we have a default button, the Enter key can't be part of the key list
    IfNotInString, Options, +Default
      Hotkey_keyList = %Hotkey_keyList%|Enter

    ;add the mouse buttons to the list 
    MouseButtons = LButton|RButton|MButton|XButton1|XButton2
    IfNotInString, Options, -Mouse
      Hotkey_keyList = %Hotkey_keyList%|%MouseButtons%

    ;If -LR is present in Options, the two modifier key lists are the same
    ;Else we have two different lists. Which one is used depends on whether
    ;the "left/right modifiers" checkbox is checked or not
    IfNotInString, Options, -lr
      Hotkey_modList_left_right = LControl,RControl,LAlt,RAlt,LWin,RWin,LShift,RShift
    Else
      Hotkey_modList_left_right = Control,Alt,LWin,RWin,Shift
    Hotkey_modList_normal = Control,Alt,LWin,RWin,Shift

    ;these will be turned into hotkeys to override their native funtion
    ;(we don't want calculator to launch when the user presses Launch_App1 etc...)
    turnIntoHotkeyList =
    (Join
    PrintScreen|CtrlBreak|Pause|Break
    |Browser_Back|Browser_Forward|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute
    |Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media
    |Launch_App1|Launch_App2|Sleep|Control|Alt|LWin|RWin|Shift
    )

    ;destroy the Gui, just in case
    Gui, %Hotkey_numGui%: Destroy

    ;Owner/modal handling; by default, the Gui is owned, either by %a_gui% or
    ;by Gui1 If %a_gui% is blank. If the owner doesn't exist, well, it will not be owned!
    IfNotInString, Options, -Owner
      {
        IfInString, Options, +Owner
          {
            StringMid, owner, Options, InStr(Options, "+Owner") + 7, 2
            If owner not integer
              StringTrimRight, owner, owner, 1
            If owner = 
              StringTrimLeft, owner, Options, InStr(Options, "+Owner") + 5
          }
        Else
        {
            If a_gui <>
              owner = %a_gui%
            Else
              owner = 1
        }
      Gui, %owner%: +LastfoundExist
      IfWinExist
        {
        IfNotInString, Options, -Modal
          Gui, %owner%: +Disabled
        Gui, %Hotkey_numGui%: +Owner%owner%
        }
      Else
        owner =
      }

    ;the Gui has no Close button (this way we're flexible with the Gui #)
    Gui, %Hotkey_numGui%:+Lastfound +Toolwindow -SysMenu  
    GuiID := WinExist()    ;used for Hotkey, IfWinActive, ahk_id%GuiID%
      
    Gui, %Hotkey_numGui%:Font, s%defFontSize% bold c%defTxtColor%, %defFontName%
    Gui, %Hotkey_numGui%:Margin, 5, 5
    Gui, %Hotkey_numGui%:Color, %defBgColor%
    If prompt <>
      Gui, %Hotkey_numGui%:Add, Text, w220, %Prompt%
    ; If prompt <>
    ;   Gui, %Hotkey_numGui%:Add, Text, w220 cRed, (Assigning currently requires a script reload)
    IfNotInString, Options, -KeyNames
      Gui, %Hotkey_numGui%:Add, ListView
      , vHotkey_Hotkey1 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor1% Background%defLVBgColor%, 1|2
    Else
      Gui, %Hotkey_numGui%:Add, ListView
      , vHotkey_Hotkey1 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor1% Background%defLVBgColor% Hidden, 1|2
    LV_ModifyCol(1, 0)
    LV_ModifyCol(2, 195)
    IfInString, Options, -Symbols
      hidden = hidden
    If (InStr(Options, "-Symbols") <> 0 OR InStr(Options, "-KeyNames") <> 0)
      Gui, %Hotkey_numGui%:Add, ListView
      , vHotkey_Hotkey2 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor2% Background%defLVBgColor% %hidden% xp yp, 1|2
    Else
      Gui, %Hotkey_numGui%:Add, ListView
      , vHotkey_Hotkey2 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor2% Background%defLVBgColor%, 1|2
    LV_ModifyCol(1, 0)
    LV_ModifyCol(2, 195)

    ;this is a bit of a mess, because we optionally have to exclude some of these..
    If Options not contains -lr,-mods
      Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_LeftRightMods, left/right modifiers
      IfNotInString, Options, -~
        {
        Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_Tilde Section gHotkey_Tilde, ~
        ys = ys
        }
      IfNotInString, Options, -*
        {
        Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_Wildcard %ys% Section gHotkey_Wildcard, *
        ys = ys
        }        
      Else If ys =
        ys =
      IfNotInString, Options, -Up
        Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_UP %ys% gHotkey_UP, UP


    Gui, %Hotkey_numGui%:Font, norm
    Gui, %Hotkey_numGui%:Add, Button, vHotkey_ButtonSubmit x62.5 Section w50 h20 gHotkey_Submit, Submit
    Gui, %Hotkey_numGui%:Add, Button, vHotkey_ButtonCancel h20 ys w50 gHotkey_Cancel, Cancel
    Gui, %Hotkey_numGui%:Add, Text, x5 y+10 w220, % BottomInfo
    ;the Timer sets focus to this button all the time to avoid key combinations triggering a focused checkbox
    Gui, %Hotkey_numGui%:Add, Button, vHotkey_DefaultButton x0 y0 w0 h0

    ;set the default button If called for
    IfInString, Options, +Default
      {
        StringMid, defButton, Options, InStr(Options, "+Default") + 8, 1
        If defButton = 1
          GuiControl, %Hotkey_numGui%:+Default, Hotkey_ButtonSubmit
        Else If defButton = 2
          GuiControl, %Hotkey_numGui%:+Default, Hotkey_ButtonCancel
      }

    ;the default title
    If title =
      title = %defTitle%

    ;turn these keys into a hotkeys to try
    ;and override their native funtion 
    Hotkey, IfWinActive, ahk_id%GuiID%
    Loop, Parse, turnIntoHotkeyList, |
          Hotkey, %a_loopfield%, Return, UseErrorLevel

    IfNotInString, Options, -Mouse
      {
        Hotkey, *WheelUp, Wheel, UseErrorLevel 
        Hotkey, *WheelDown, Wheel, UseErrorLevel
      }

    ;If we have an owner, center the Gui on it
    If owner <> 
      {
        Gui, %Hotkey_numGui%:Show, Autosize Hide
        Gui, %owner%: +Lastfound
        WinGetPos, x, y, w, h
        Gui, %Hotkey_numGui%:+Lastfound
        WinGetPos,,,gw,gh
        gx := x + w/2 - gw/2
        gy := y + h/2 - gh/2
        Gui, %Hotkey_numGui%: Show, x%gx% y%gy%, %title%
      }
    Else
      Gui, %Hotkey_numGui%:Show, Autosize, %title%
      
    ;400 is about right, but feel free to experiment
    ;basically you have to keep the balance between registering new keys fast enough
    ;but not registering the release of keys TOO fast
    SetTimer, Hotkey_Hotkey, 400  

    ;we need Options to be global so that the other functions can use it
    ;so we store it in another variable
    Hotkey_OptionsGlobal = %Options%

    Gui, %Hotkey_numGui%:+Lastfound
    Critical Off    ;has to be turned off to allow the other threads to run
    SetBatchLines %batch_lines%    ;reset it

    WinWaitClose

    SetTimer, Hotkey_Hotkey, Off    ;turn off the timer
    Tooltip    ;in case we were displaying a tooltip
    Tooltip,,,,2

    ;free all the globals, to be on the safe side:
    Loop, Parse, HotKey_globals, `,
      %a_loopfield% =

    ;reset the default Gui
    If owner <>
      Gui, %owner%: Default
    Else If a_gui <> 
      Gui, %a_gui%: Default
    Else
      Gui, 1: Default
      
    ;re-enable and activate the owner
    If owner <>
      {
      Gui, %owner%: -Disabled
      Gui, %owner%: Show
      }
      
    Return ReturnValue  

    ;####################### Timer ####################

    Hotkey_Hotkey:
    IfWinNotActive, ahk_id%GuiID%
      Return
      
    Gui, %Hotkey_numGui%: Default  

    ;If the mouse isn't over a control, set focus to an (invisible) button
    MouseGetPos,,,win,ctrl
    If (win <> GuiID OR ctrl = "")
      {
        GuiControl, Focus, Hotkey_DefaultButton
        Tooltip,,,,2    ;we use tooltip1 to display a message Elsewhere, so use #2
      }
    Else IfInString, Hotkey_OptionsGlobal, +Tooltips    ;If we want tooltips
      {
        ControlGetText, t, %ctrl%, ahk_id%win%
        If t = ~
          tip = Tilde: When the hotkey fires, its key's`nnative function will not be blocked`n(hidden from the system). 
        Else If t = *
          tip = Wildcard: Fire the hotkey even If extra`nmodifiers are being held down. 
        Else If t = UP
          tip = Causes the hotkey to fire upon release of the key`nrather than when the key is pressed down.
        Else 
          tip =
        Tooltip %tip%,,,2
      }
      
    keys := Keys()      ;get the keys that are beeing held down

    ;If no keys are down, find out If we're looking at something 
    ;like "Control+Alt+" or a valid hotkey, and clear the ListView 
    ;in case #1
    If keys =
      {
        Gui, ListView, Hotkey_Hotkey1
        LV_GetText(k, 1, 2)
        ;If UP is checked we could have "Ctrl+Alt+ UP", so get rid of the UP
        StringReplace, k, k, %a_space%UP    
        ;If the right-most char is a "+" but we don't have "++" (e.g. "Ctrl+Alt++"), clean up
        If (InStr(k, "+","",0) = StrLen(k) AND InStr(k, "++") = 0)
          {
            LV_Delete(1)
            Gui, ListView, Hotkey_Hotkey2
            LV_Delete(1)
            ;clear keys_prev in this case
            keys_prev =
          }
        Return    ;nothing Else
      }

    ;this avoids flickering
    If keys = %keys_prev%
      Return
    keys_prev = %keys%

    ;this handles differing between, say, "Space & LButton" and "LButton & Space"
    ;by remembering which key was pressed first (otherwise the keys would always
    ;be in the order they appear in the keyList
    IfNotInString, keys, +    ;If we have only a single key, remember it
      firstKey = %keys%
    ;Else If we have more than one but no modifier(s)
    Else If keys not contains %Hotkey_modList_left_right%,%Hotkey_modList_normal%,Win  
      {
        If InStr(keys, firstKey) <> 1    ;If they're in the wrong order
          {
            StringLeft, k1, keys, InStr(keys, "+") - 1    ;swap them
            StringTrimLeft, k2, keys, InStr(keys, "+") 
            keys = %k2%+%k1%
          }
      }

    ;add the special prefix keys from the checkboxes
    keys := AddPrefixSymbols(keys)

    ;delete old keys and add new ones
    Gui, %Hotkey_numGui%: ListView, Hotkey_Hotkey1
    LV_Delete(1)
    LV_Add("","",keys)

    Gui, ListView, Hotkey_Hotkey2
    LV_Delete(1)
    LV_Add("","",KeysToSymbols(keys))
    Return

    ;############# checkbox labels ###########

    ;these all call the same function... easier that way
    Hotkey_Tilde:
    Hotkey_Wildcard:
    Hotkey_Up:
    ToggleOperator(a_guicontrol)
    Return

    ;########## Remove the tooltip and the pseudo label for the Hotkey #####

    Hotkey_RemoveTooltip:
    Tooltip
    Return

    Return:
    Return

    ;############### The Label for WheelUp&WheelDown ##################

    Wheel:
    StringTrimLeft, w, a_thishotkey, 1    ;remove the "*" from WheelUp/Down

    Gui, %Hotkey_numGui%: Default
    Gui, %Hotkey_numGui%: Submit, NoHide

    ;in this case only check for modifiers
    IfInString, Hotkey_OptionsGlobal, -&
      {
        mods =
        
        ;If -LR is not present in options AND the LR checkbox is checked,
        ;use the left/right mod list
        If (InStr(Hotkey_OptionsGlobal, "-LR") = 0 AND Hotkey_LeftRightMods <> 0)
          modList = %Hotkey_modList_left_right%
        Else
          modList = %Hotkey_modList_normal%
          
        Loop, Parse, modList, `,
          {
            If GetKeyState(a_loopfield,"P") <> 1
              continue
            mods = %mods%%a_loopfield%+
          }
        
        If Hotkey_LeftRightMods <> 1
          {
            StringReplace, mods, mods, LWin, Win
            StringReplace, mods, mods, RWin, Win
          }
        
        k = %mods%%w%  ;the keys are the modifiers plus WheelUp/down
        
        If k = %k_prev%
          Return
        k_prev = %k%
        
        ;add the prefix symbols
        k := AddPrefixSymbols(k)
        
        ;add them to the LV and Return
        Gui, ListView, Hotkey_Hotkey1
        LV_Delete(1)
        LV_Add("","",k)
        Gui, ListView, Hotkey_Hotkey2
        LV_Delete(1)
        LV_Add("","",KeysToSymbols(k))
      Return
      }

    ;If "-&" is not present in Options, get all the keys, like in the Hotkey_Hotkey timer:

    k := Keys()      

    ;just in case somebody tries mapping "Joy3 & WheelUp" or whatever :)
    If k in %Hotkey_JoystickButtons%
      {
        Tooltip, Note: Joystick buttons are not`nsupported as prefix keys.
        SetTimer, Hotkey_RemoveTooltip, 5000
        k =
      }

    If (InStr(k, "+","",0) <> StrLen(k))  ;If it's not something like "Control+Alt+"
      {
      IfInString, k, +    ;If we have more than one key, remove all but the first (can't have "a & b & WheelUp")
        StringLeft, k, k, InStr(k, "+","",0)
      Else
        k = %k%+    ;turn "Space" into "Space+" etc...
      }
      
    k = %k%%w%    ;add WheelUp/Down

    If k = %k_prev%
      Return
    k_prev = %k%

    ;add the prefix symbols
    k := AddPrefixSymbols(k)

    ;add the keys to the ListViews:
    Gui, ListView, Hotkey_Hotkey1
    LV_Delete(1)
    LV_Add("","",k)
    Gui, ListView, Hotkey_Hotkey2
    LV_Delete(1)
    LV_Add("","",KeysToSymbols(k))
    Return

    ;################### Submit & Cancel ##################### 

    Hotkey_Submit:
    Gui, %Hotkey_numGui%: Default
    Gui, ListView, Hotkey_Hotkey1
    LV_GetText(k, 1, 2)
    ;call IsHotkeyValid() to find out If this is a "real" hotkey
    ;If not, just destroy the Gui and Return
    If IsHotkeyValid(k) = -1
      {
        Gui, %Hotkey_numGui%:Destroy
        Return
      }
    IfNotInString, Options, +ReturnKeynames    ;If we should Return symbols, get those
      {
        Gui, ListView, Hotkey_Hotkey2
        LV_GetText(ReturnValue, 1, 2)
      }
    Else
      ReturnValue = %k%  ;we got keynames already
    Gui, %Hotkey_numGui%:Destroy
    
    ; make single word characters in hotkeys upper case
    ; simple version, only works if there are no multi word character strings 
    If (ReturnValue) {
      If (not RegExMatch(ReturnValue, "([\w]{2,})")) {
        StringUpper, ReturnValue, ReturnValue
      }
    }
    
    Return

    Hotkey_Cancel:
    Gui, %Hotkey_numGui%:Destroy
    Return
  }

  ;###################### Other funtions ######################

  ;this has to bee done in three different places, so it's a seperate funtion
  ;it checks which checkboxes are checked ... ugh ... and adds the symbols in the right places
  ;note that we can't have any of the symbols with Joystick buttons, and that " * " and "&"
  ;can't be present in the same hotkey
  AddPrefixSymbols(keys)
  {
    global Hotkey_JoystickButtons,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_numGui

    Gui, %Hotkey_numGui%:Submit, NoHide

    ;joystick buttons can't have prefix keys, therefore uncheck all the checkboxes
    If keys in %Hotkey_JoystickButtons%  
      {
        GuiControl,, Hotkey_Tilde, 0
        GuiControl,, Hotkey_Wildcard, 0
        GuiControl,, Hotkey_UP, 0
      }
    Else
      {
    If Hotkey_Tilde = 1
      keys = ~%keys%
    If Hotkey_Wildcard = 1
      {
        ;the wildcard can't be present together with the ampersand
        If (InStr(KeysToSymbols(keys), "&") = 0)
          keys = *%keys%
        Else
          {
          GuiControl,, Hotkey_Wildcard, 0
          Tooltip, The * prefix is not allowed in hotkeys`nthat use the ampersand (&).
          SetTimer, Hotkey_RemoveTooltip, 5000
          }
      }
    If Hotkey_UP = 1
      keys = %keys%%a_space%UP
    }
    Return keys
  }

  ;________________________________________________________

  ;this funtion turns, say, "Control+Alt+Win+Space" into "^!#Space" etc.
  ;this is handy since when you use the "+ReturnKeynames" option, you can 
  ;convert to hotkey symbols later using this funtion
  KeysToSymbols(s)
  {
    global Hotkey_modList_left_right,Hotkey_modList_normal,Hotkey_LeftRightMods,Hotkey_numGui

    Gui, %Hotkey_numGui%:Submit, NoHide
    ;grab the correct modList
    If Hotkey_LeftRightMods = 1
      modList = %Hotkey_modList_left_right%
    Else
      modList = %Hotkey_modList_normal%

    ;If the keys don't contain a modifier, it has to be something
    ;like "a+b", so turn it into "a & b" and Return
    If s not contains %modList%,Win
        {
              StringReplace, s, s, +, %a_space%&%a_space%
              Return s
        }
    ;Else, replace the keynames with the appropriate symbols
    StringReplace, s, s, LControl+, <^
    StringReplace, s, s, RControl+, >^
    StringReplace, s, s, Control+, ^
    StringReplace, s, s, LAlt+, <!
    StringReplace, s, s, RAlt+, >!
    StringReplace, s, s, Alt+, !
    StringReplace, s, s, LShift+, <+
    StringReplace, s, s, RShift+, >+
    StringReplace, s, s, Shift+, +
    StringReplace, s, s, LWin+, <#
    StringReplace, s, s, RWin+, >#
    StringReplace, s, s, Win+, #
    Return s
  }

  ;__________________________________________________

  ;this function checks which keys are beeing held down using the correct modList 
  Keys()
  {
    global Hotkey_keyList,Hotkey_modList_left_right,Hotkey_modList_normal,Hotkey_LeftRightMods
            ,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

    Gui, %Hotkey_numGui%:Submit, NoHide

    ;grab the correct modList
    If Hotkey_LeftRightMods = 1
      modList = %Hotkey_modList_left_right%
    Else
      modList = %Hotkey_modList_normal%

    ;If we don't want modifiers, just make it blank
    IfInString, Hotkey_OptionsGlobal, -mods
      modList =

    ;check joystick buttons first, since we can have only one
    ;and no modifiers. If we find one, just Return it, nothing Else
    Loop, Parse, Hotkey_JoystickButtons, `,
      {
        If GetKeyState(a_loopfield, "P") = 1
          Return a_loopfield
      }

    ;check for modifiers
    Loop, Parse, modList, `,
      {
        If GetKeyState(a_loopfield,"P") <> 1
          continue
        mods = %mods%%a_loopfield%+
      }

    ;GetKeyState("Win") doesn't work, which is why both modLists include 
    ;both variants. So replace L/RWin with Win here If needed
    If Hotkey_LeftRightMods <> 1
      {
        StringReplace, mods, mods, LWin, Win
        StringReplace, mods, mods, RWin, Win
      }

    ;check If other keys are beeing held down
    Loop, Parse, Hotkey_keyList, |
      {
        If GetKeyState(a_loopfield,"P") <> 1
          continue
        ;If ithe left mouse button is down, check If the user is clicking a control
        ;(and ignore it If that's the case)
        If a_loopfield = LButton
          {
            MouseGetPos,,,,ctrl
            If (ctrl <> "" AND InStr(ctrl, "SysListView") = 0)
              continue
          }
        ;If we don't want the ampersand (either because specified in options, or
        ;because we're on Win95/98/ME, just Return the first key we find (plus mods)
        IfInString, OptionsGlobal, -&
          {
          keys = %mods%%a_loopfield%
          Return keys
          }
        ;If this is the second time we get to this point in the loop...
        ;we must already have a key -> the user is holding down two keys
        ;in this case, ignore any modifiers and just Return our two keys
        If keys <>
          {
          keys = %keys%+%a_loopfield%
          Return keys
          }    
        ;Else If keys is still blank, take this key
        keys = %a_loopfield%
      }

    ;If we get to this point, the user is holding down only one key (from the keyList)
    ;so we can add the modifiers, If we found some
    If mods <>
      keys = %mods%%keys%
    Return %keys%
  }

  ;_______________________________________________________________

  ;this funtion gets called everytime the user clicks one of the checkboxes
  ToggleOperator(p)
  {
    global Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_JoystickButtons,Hotkey_numGui

    ;we need to turn on CaseSense because we could have, say, Up UP :)
    StringCaseSense On  
    AutoTrim Off    ;because of the space between the keys and the UP symbol

    Gui, %Hotkey_numGui%:Submit, NoHide

    ;this is kinda confusing, but I'm not changing it now...
    ctrl = %p%

    ;"p" is a_guicontrol btw...
    If p = Hotkey_Tilde
      p = ~
    Else If p = Hotkey_Wildcard
      p = *
    Else If p = Hotkey_UP
      p = %a_space%UP

    Loop 2
      {
        Gui, ListView, Hotkey_Hotkey%a_index%
        LV_GetText(k%a_index%,1,2)
      }

    ;If it's a joytick button, we can't have any special operators
    If Hotkey_JoystickButtons <>
      {
        If k1 in %Hotkey_JoystickButtons%
          {
            GuiControl,, %ctrl%, 0
            Tooltip, This operator is not supported`nfor joystick buttons.
            SetTimer, Hotkey_RemoveTooltip, 5000
            Return
          }
      }

    ;If a_guicontrol is not checked (i.e. is was unchecked), 
    ;remove the prefix, edit the Listviews and Return
    If %ctrl% <> 1
      {
        StringReplace, k1, k1, %p%
        StringReplace, k2, k2, %p%
        Loop 2
          {
            Gui, ListView, Hotkey_Hotkey%a_index%
            LV_Delete(1)
            LV_Add("","", k%a_index%)
          }
        Return
      }


    If p = ~
      {
        k1 = ~%k1%
        k2 = ~%k2%
      }
    Else If p = *
      {
        IfNotInString, k2, &      ;we can't have both " * " and "&" 
          {
            k1 = *%k1%
            k2 = *%k2%
          }
        Else
        {
          GuiControl,, Hotkey_Wildcard, 0
          Tooltip, The * prefix is not allowed in hotkeys`nthat use the ampersand (&).
          SetTimer, Hotkey_RemoveTooltip, 5000
        }
      }
    Else If p contains UP      
      {
        k1 = %k1%%p%
        k2 = %k2%%p%
      }    
    ;edit the ListViews
    Loop 2
      {
        Gui, ListView, Hotkey_Hotkey%a_index%
        LV_Delete(1)
        LV_Add("","", k%a_index%)
      }
  }

  ;_____________________________________________________

  ;this funtion checks If a) it's some kind of a sensible hotkey,
  ;i.e not Ctrl+Alt+, ~ UP, etc., and b) that it's a valid hotkey
  ;If it's not, the funtion Returns -1, Else it Returns 1
  IsHotkeyValid(k)
  {
    If k =
      Return -1
      
    ;If UP is checked we could have "Ctrl+Alt+ UP", so get rid of the UP
    StringReplace, k, k, %a_space%UP    
    ;If the right-most char is a "+" but we don't have "++" (e.g. "Ctrl+Alt++"),
    ;it's not a "real" hotkey - most likely the user clicked okay while 
    ;holding down some modifiers. We can't have that...
    If (InStr(k, "+","",0) = StrLen(k) AND InStr(k, "++") = 0)
      Return -1
      
    ;these are all valid hotkeys, but we don't really want these either
    If k in ,*,~, UP,*~,~*,* UP,~ UP,*~ UP
      Return -1

    ;turn it into a hotkey to check ErrorLevel. 
    ;convert to symbols before we do this

    k := KeysToSymbols(k)

    Hotkey, %k%, Return, UseErrorLevel
    If ErrorLevel <> 0
      {
        ;Joystick buttons cause an incorrect ErrorLevel on WinXP (see my post in Bug Reports)
        ;so ignore it
        If (A_OSType <> "WIN32_WINDOWS" AND ErrorLevel = 51 AND InStr(k, "Joy") <> 0)
          {
            Hotkey, %k%, Return, Off
            Return 1
          }
        Else    ;notify user
          {
            ErrorMessage =
              (LTrim
              Sorry, this hotkey (%k%) is invalid.
              To find out why, please look up Error #%ErrorLevel% under the "Hotkey" command in the AHK command list.
              Also, please report this Error to the author of this script so that the bug can be fixed.
              (Note: Press Ctrl+C to copy this message to the clipboard).
              )
            Gui, +OwnDialogs
            Msgbox, 8208, Invalid Hotkey, %ErrorMessage%
            Return -1
          }
      }
    Else    
      Return 1
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*** DynaRun - CreateScript - Run AHK in a pipe! 
 *   These functions allow for dynamically created scripts to be run
 *   Removes the need for creating temporary script files
 */
  CreateScript(script){
  static mScript
  StringReplace,script,script,`n,`r`n,A
  StringReplace,script,script,`r`r,`r,A
  If RegExMatch(script,"m)^[^:]+:[^:]+|[a-zA-Z0-9#_@]+\{}$"){
    If !(mScript){
    If (A_IsCompiled){
      lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
      If !(res := DllCall("FindResource", "ptr", lib, "str", ">AUTOHOTKEY SCRIPT<", "ptr", Type:=10, "ptr"))
      If !(res := DllCall("FindResource", "ptr", lib, "str", ">AHK WITH ICON<", "ptr", Type:=10, "ptr")){
        MsgBox Could not extract script!
        return
      }
      DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
      ,hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
      ,pData := DllCall("LockResource", "ptr", hresdata, "ptr")
      If (DataSize){
      mScript:=StrGet(pData,"UTF-8")
      StringReplace,mScript,mScript,`n,`r`n,A
      StringReplace,mScript,mScript,`r,`r`n,A
      StringReplace,mScript,mScript,`r`r,`r,A
      StringReplace,mScript,mScript,`n`n,`n,A
      mScript :="`r`n" mScript "`r`n"
      }
    } else {
      FileRead,mScript,%A_ScriptFullPath%
      StringReplace,mScript,mScript,`n,`r`n,A
      StringReplace,mScript,mScript,`r`r,`r,A
      mScript := "`r`n" mScript "`r`n"
      Loop,Parse,mScript,`n,`r
      {
      If A_Index=1
        mScript:=""
      If RegExMatch(A_LoopField,"i)^\s*#include"){
        temp:=RegExReplace(A_LoopField,"i)^\s*#include[\s+|,]")
        If InStr(temp,"%"){
        Loop,Parse,temp,`%
        {
          If (A_Index=1)
          temp:=A_LoopField
          else if !Mod(A_Index,2)
          _temp:=A_LoopField
          else {
          _temp:=%_temp%
          temp.=_temp A_LoopField
          _temp:=""
          }
        }
        }
        If InStr(FileExist(trim(temp,"<>")),"D"){
    SetWorkingDir % trim(temp,"<>")
    continue
  } else if InStr(FileExist(temp),"D"){
    SetWorkingDir % temp
    continue
  } else If (SubStr(temp,1,1) . SubStr(temp,0) = "<>"){
        If !FileExist(_temp:=A_ScriptDir "\lib\" trim(temp,"<>") ".ahk")
          If !FileExist(_temp:=A_MyDocuments "\AutoHotkey\lib\" trim(temp,"<>") ".ahk")
          If !FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib\" trim(temp,"<>") ".ahk")
            If FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib.lnk"){
            FileGetShortcut,_temp,_temp
            _temp:=_temp "\" trim(temp,"<>") ".ahk"
            }
    FileRead,_temp,%_temp%
      mScript.= _temp "`r`n"
        } else {
    FileRead,_temp,%temp%
    mScript.= _temp "`r`n"
  }
      } else mScript.=A_LoopField "`r`n"
      }
    }
    }
    Loop,Parse,script,`n,`r
    {
    If A_Index=1
      script=
    else If A_LoopField=
      Continue
    If (RegExMatch(A_LoopField,"^[^:\s]+:[^:\s=]+$")){
      StringSplit,label,A_LoopField,:
      If (label0=2 and IsLabel(label1) and IsLabel(label2)){
      script .=SubStr(mScript
        , h:=InStr(mScript,"`r`n" label1 ":`r`n")
        , InStr(mScript,"`r`n" label2 ":`r`n")-h) . "`r`n"
      }
    } else if RegExMatch(A_LoopField,"^[^\{}\s]+\{}$"){
      StringTrimRight,label,A_LoopField,2
      script .= SubStr(mScript
      , h:=RegExMatch(mScript,"i)\n" label "\([^\)\n]*\)\n?\s*\{")
      , RegExMatch(mScript "`r`n","\n\s*}\s*\K\n",1,h)-h) . "`r`n"
    } else
      script .= A_LoopField "`r`n"
    }
  }
  StringReplace,script,script,`r`n,`n,All
  Return Script
  }

  DynaRun(script, name:="", args*) { ;// http://goo.gl/ECC6Qw
    if (name == "")
      name := "AHK_" . A_TickCount
    ;// Create named pipe(s), first one is a dummy
    for each, pipe in ["__PIPE_GA_", "__PIPE_"]
      %pipe% := DllCall(
      (Join Q C
        "CreateNamedPipe",      ;// http://goo.gl/3aJQg7
        "Str", "\\.\pipe\" . name,  ;// lpName
        "UInt", 2,          ;// dwOpenMode = PIPE_ACCESS_OUTBOUND
        "UInt", 0,          ;// dwPipeMode = PIPE_TYPE_BYTE
        "UInt", 255,        ;// nMaxInstances
        "UInt", 0,          ;// nOutBufferSize
        "UInt", 0,          ;// nInBufferSize
        "Ptr", 0,           ;// nDefaultTimeOut
        "Ptr", 0          ;// lpSecurityAttributes
      ))
    
    if (__PIPE_ == -1 || __PIPE_GA_ == -1)
      return false
    
    q := Chr(34) ;// for v1.1 and v2.0-a compatibility
    for each, arg in args
      args .= " " . q . arg . q
    Run "%A_AhkPath%" "\\.\pipe\%name%" %args%,, UseErrorLevel Hide, PID
    if ErrorLevel
      MsgBox, 262144, ERROR, Could not open file:`n%A_AhkPath%\\.\pipe\%name%
    
    DllCall("ConnectNamedPipe", "Ptr", __PIPE_GA_, "Ptr", 0) ;// http://goo.gl/pwTnxj
    DllCall("CloseHandle", "Ptr", __PIPE_GA_)
    DllCall("ConnectNamedPipe", "Ptr", __PIPE_, "Ptr", 0)
    
    script := (A_IsUnicode ? Chr(0xfeff) : (Chr(239) . Chr(187) . Chr(191))) . script
    if !DllCall(
    (Join Q C
      "WriteFile",                ;// http://goo.gl/fdyWm0
      "Ptr", __PIPE_,               ;// hFile
      "Str", script,                ;// lpBuffer
      "UInt", (StrLen(script)+1)*(A_IsUnicode+1), ;// nNumberOfBytesToWrite
      "UInt*", 0,                 ;// lpNumberOfBytesWritten
      "Ptr", 0                  ;// lpOverlapped
    ))
      return A_LastError
    /* FileOpen() version
    if !(f := FileOpen(__PIPE_, "h", A_IsUnicode ? "UTF-8" : ""))
      return A_LastError
    f.Write(script), f.Close() ;// .Close() -> Redundant, no effect
    */
    DllCall("CloseHandle", "Ptr", __PIPE_)
    
    return PID
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*** Lib from LutBot : Extracted from lite version
 * Lib: LutBotLite.ahk
 *   Path of Exile Quick disconnect.
 */

  ; Main function of the LutBot logout method
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  logout(executable){
      global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi
      Thread, NoTimers, true    ;Critical
      start := A_TickCount
      
      poePID := Object()
      s := 4096
      Process, Exist 
      h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
      
      DllCall(OpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", t)
      VarSetCapacity(ti, 16, 0)
      NumPut(1, ti, 0, "UInt")
      
      DllCall(LookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
      NumPut(luid, ti, 4, "Int64")
      NumPut(2, ti, 12, "UInt")
      
      r := DllCall(AdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
      DllCall("CloseHandle", "Ptr", t)
      DllCall("CloseHandle", "Ptr", h)
      
      try
      {
        s := VarSetCapacity(a, s)
        c := 0
        DllCall(EnumProcesses, "Ptr", &a, "UInt", s, "UIntP", r)
        Loop, % r // 4
        {
          id := NumGet(a, A_Index* 4, "UInt")
          
          h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
          
          if !h
            continue
          VarSetCapacity(n, s, 0)
          e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
          if !e 
            if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
            SplitPath n, n
          DllCall("CloseHandle", "Ptr", h)
          if (n && e)
          if (n == executable) {
            poePID.Insert(id)
          }
        }
        
        l := poePID.Length()
        if ( l = 0 ) {
          Process, wait, %executable%, 0.2
          if ( ErrorLevel > 0 ) {
            poePID.Insert(ErrorLevel)
          }
        }
        
        VarSetCapacity(dwSize, 4, 0) 
        result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
        VarSetCapacity(TcpTable, NumGet(dwSize), 0) 
        
        result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
        
        num := NumGet(&TcpTable,0,"UInt")
        
        IfEqual, num, 0
        {
          Log("ED11",num,l,executable)
          return False
        }
        
        out := 0
        Loop %num%
        {
          cutby := a_index - 1
          cutby*= 24
          ownerPID := NumGet(&TcpTable,cutby+24,"UInt")
          for index, element in poePID {
            if ( ownerPID = element )
            {
              VarSetCapacity(newEntry, 20, 0) 
              NumPut(12,&newEntry,0,"UInt")
              NumPut(NumGet(&TcpTable,cutby+8,"UInt"),&newEntry,4,"UInt")
              NumPut(NumGet(&TcpTable,cutby+12,"UInt"),&newEntry,8,"UInt")
              NumPut(NumGet(&TcpTable,cutby+16,"UInt"),&newEntry,12,"UInt")
              NumPut(NumGet(&TcpTable,cutby+20,"UInt"),&newEntry,16,"UInt")
              result := DllCall(SetEntry, UInt, &newEntry)
              IfNotEqual, result, 0
              {
                Log("TCP" . result,out,result,l,executable)
                return False
              }
              out++
            }
          }
        }
        if ( out = 0 ) {
          Log("ED10",out,l,executable)
          return False
        } else {
          Log(l . ":" . A_TickCount - start,out,l,executable)
        }
      } 
      catch e
      {
        Log("ED14","catcherror",e)
        return False
      }
      
    return True
    }

  ; Log file function
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Log(var*) 
  {
    print := A_Now
    For k, v in var
      print .= "," . v
    print .= ", Script: " . A_ScriptFullPath . " , Script Version: " . VersionNumber . " , AHK version: " . A_AhkVersion . "`n"
    FileAppend, %print%, %A_ScriptDir%\temp\Log.txt, UTF-16
    return
  }

  ; checkActiveType - Check for active executable
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  checkActiveType() 
  {
    global Active_executable, GameStr
    Process, Exist, %Active_executable%
    if !ErrorLevel
    {
      WinGet, id, list,ahk_group POEGameGroup,, Program Manager
      Loop, %id%
      {
        this_id := id%A_Index%
        WinGet, this_name, ProcessName, ahk_id %this_id%
        Active_executable := this_name
        GameStr := "ahk_exe " Active_executable
        Return True
      }
      Return False
    }
    Else
      Return True
  }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/* OrderedArray code by Lexikos
 * Modifications and additional methods by rbrtryn
 * http://tinyurl.com/lhtvalv
 */
  OrderedArray(prm*)
  {
    ; Define prototype object for ordered arrays:
    static base := Object("__Set", "oaSet", "_NewEnum", "oaNewEnum"
              , "Remove", "oaRemove", "Insert", "oaInsert", "InsertBefore", "oaInsertBefore")
    ; Create and return new ordered array object:
    return Object("_keys", Object(), "base", base, prm*)
  }

  oaSet(obj, prm*)
  {
    ; If this function is called, the key must not already exist.
    ; Sub-class array if necessary then add this new key to the key list
    if prm.maxindex() > 2
      ObjInsert(obj, prm[1], OrderedArray())
    ObjInsert(obj._keys, prm[1])
    ; Since we don't return a value, the default behaviour takes effect.
    ; That is, a new key-value pair is created and stored in the object.
  }

  oaNewEnum(obj)
  {
    ; Define prototype object for custom enumerator:
    static base := Object("Next", "oaEnumNext")
    ; Return an enumerator wrapping our _keys array's enumerator:
    return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
  }

  oaEnumNext(e, ByRef k, ByRef v="")
  {
    ; If Enum.Next() returns a "true" value, it has stored a key and
    ; value in the provided variables. In this case, "i" receives the
    ; current index in the _keys array and "k" receives the value at
    ; that index, which is a key in the original object:
    if r := e.enum.Next(i,k)
      ; We want it to appear as though the user is simply enumerating
      ; the key-value pairs of the original object, so store the value
      ; associated with this key in the second output variable:
      v := e.obj[k]
    return r
  }

  oaRemove(obj, prm*)
  {
    r := ObjRemove(obj, prm*)     ; Remove keys from main object
    Removed := []           
    for k, v in obj._keys       ; Get each index key pair
      if not ObjHasKey(obj, v)    ; if key is not in main object
        Removed.Insert(k)     ; Store that keys index to be removed later
    for k, v in Removed         ; For each key to be removed
      ObjRemove(obj._keys, v, "")   ; remove that key from key list
    return r
  }

  oaInsert(obj, prm*)
  {
    r := ObjInsert(obj, prm*)      ; Insert keys into main object
    enum := ObjNewEnum(obj)        ; Can't use for-loop because it would invoke oaNewEnum
    while enum[k] {            ; For each key in main object
      if (k = "_keys")
        continue 
      for i, kv in obj._keys       ; Search for key in obj._keys
        if (k = kv)          ; If found...
          continue 2         ; Get next key in main object
      ObjInsert(obj._keys, k)      ; Else insert key into obj._keys
    }
    return r
  }

  oaInsertBefore(obj, key, prm*)
  {
    OldKeys := obj._keys         ; Save key list
    obj._keys := []            ; Clear key list
    for idx, k in OldKeys {        ; Put the keys before key
      if (k = key)           ; back into key list
        break
      obj._keys.Insert(k)
    }
    
    r := ObjInsert(obj, prm*)      ; Insert keys into main object
    enum := ObjNewEnum(obj)        ; Can't use for-loop because it would invoke oaNewEnum
    while enum[k] {            ; For each key in main object
      if (k = "_keys")
        continue 
      for i, kv in OldKeys       ; Search for key in OldKeys
        if (k = kv)          ; If found...
          continue 2         ; Get next key in main object
      ObjInsert(obj._keys, k)      ; Else insert key into obj._keys
    }
    
    for i, k in OldKeys {        ; Put the keys after key
      if (i < idx)           ; back into key list
        continue
      obj._keys.Insert(k)
    }
    return r
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



; Rectangular selection function written by Lexikos
  LetUserSelectRect(PixelToo:=0)
  {
    Global Picker
    Hotkey Ifwinactive
    static r := 1
    ; Create the "selection rectangle" GUIs (one for each edge).
    Loop 4 {
      Gui, Rect%A_Index%: -Caption +ToolWindow +AlwaysOnTop
      Gui, Rect%A_Index%: Color, Red
    }
    PauseTooltips := 1
    If GamePID
      WinActivate, %GameStr%
    If PixelToo
      Ding(0,-11,"Click and hold left mouse to draw box`nUse arrow keys to move mouse,and mousewheel to zoom`nPress Ctrl to Clipboard the color and X,Y")
    Else
      Ding(0,-11,"Click and hold left mouse to begin`nUse arrow keys to move mouse,and mousewheel to zoom")
    ; Wait for release of LButton
    KeyWait, LButton
    ; Wait for release of Ctrl
    If PixelToo
      KeyWait, Ctrl
    ; Disable LButton.
    Hotkey, *LButton, lusr_return, On
    DrawZoom("Toggle")
    Loop
    {
      ; Get initial coordinates.
      MouseGetPos, xorigin, yorigin
      PixelGetColor, col, %xorigin%, %yorigin%, RGB
      Picker.SetColor(col)
      ToolTip, % (PixelToo?"   " col " @ ":"   ") xorigin "," yorigin 
      DrawZoom("Repaint")
      DrawZoom("MoveAway")
      If (GetKeyState("Ctrl", "P") && PixelToo)
      {
        Hotkey, *LButton, Off
        Tooltip
        Ding(1,-11,"")
        PauseTooltips := 0
        Clipboard := col " @ " xorigin "," yorigin
        Notify(Clipboard,"Copied to the clipboard",5)
        DrawZoom("Toggle")
        Return False
      }
    } Until GetKeyState("LButton", "P")
    Tooltip
    Ding(0,-11,"Drag the mouse then release to select the area")
    ; Set timer for updating the selection rectangle.
    SetTimer, lusr_update, 10
    ; Wait for user to release LButton.
    KeyWait, LButton
    ; Re-enable LButton.
    Hotkey, *LButton, Off
    ; Disable timer.
    SetTimer, lusr_update, Off
    ; Destroy "selection rectangle" GUIs.
    Loop 4
      Gui, Rect%A_Index%: Destroy
    PauseTooltips := 0
    Ding(1,-11,"")
    DrawZoom("Toggle")
    return { "X1":X1,"Y1":Y1,"X2":X2,"Y2":Y2 }
  
    lusr_update:
      MouseGetPos, x, y
      if (x = xlast && y = ylast)
        ; Mouse hasn't moved so there's nothing to do.
        return
      if (x < xorigin)
        x1 := x, x2 := xorigin
      else x2 := x, x1 := xorigin
      if (y < yorigin)
        y1 := y, y2 := yorigin
      else y2 := y, y1 := yorigin
      ; Update the "selection rectangle".
      Gui, Rect1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" (r?r:1)
      Gui, Rect2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" (r?r:1)
      Gui, Rect3:Show, % "NA X" x1 " Y" y1 " W" (r?r:1) " H" y2-y1
      Gui, Rect4:Show, % "NA X" x2-r " Y" y1 " W" (r?r:1) " H" y2-y1
    lusr_return:
    return
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*  XInput by Lexikos
 *  This version of the script uses objects, so requires AutoHotkey_L.
 ; Example: Control the vibration motors using the analog triggers of each controller.
 XInput_Init()
 Loop 
 {
  Loop, 4 
  {
    if State := XInput_GetState(A_Index-1) 
    {
      LT := State.bLeftTrigger
      RT := State.bRightTrigger
      XInput_SetState(A_Index-1, LT*257, RT*257)
    }
  }
  Sleep, 100
 }
 */

  /*
    Function: XInput_Init
    
    Initializes XInput.ahk with the given XInput DLL.
    
    Parameters:
      dll   -   The path or name of the XInput DLL to load.
  */
  XInput_Init(dll="xinput1_3")
  {
    global
    if _XInput_hm
      return
    
    ;======== CONSTANTS DEFINED IN XINPUT.H ========
    
    ; NOTE: These are based on my outdated copy of the DirectX SDK.
    ;     Newer versions of XInput may require additional constants.
    
    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD      := 0x01

    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD     := 0x01

    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED   := 0x0004

    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP      := 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN    := 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT    := 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT     := 0x0008
    XINPUT_GAMEPAD_START      := 0x0010
    XINPUT_GAMEPAD_BACK       := 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB     := 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB    := 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER  := 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
    XINPUT_GAMEPAD_A        := 0x1000
    XINPUT_GAMEPAD_B        := 0x2000
    XINPUT_GAMEPAD_X        := 0x4000
    XINPUT_GAMEPAD_Y        := 0x8000

    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  := 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE := 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD  := 30

    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD       := 0x00000001
    
    ;=============== END CONSTANTS =================
    
    _XInput_hm := DllCall("LoadLibrary" ,"str",dll)
    
    if !_XInput_hm
    {
      MsgBox, Failed to initialize XInput: %dll%.dll not found.
      return
    }
    
    _XInput_GetState    := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetState")
    _XInput_SetState    := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputSetState")
    _XInput_GetCapabilities := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetCapabilities")
    
    if !(_XInput_GetState && _XInput_SetState && _XInput_GetCapabilities)
    {
      XInput_Term()
      MsgBox, Failed to initialize XInput: function not found.
      return
    }
  }

  /*
    Function: XInput_GetState
    
    Retrieves the current state of the specified controller.

    Parameters:
      UserIndex   -   [in] Index of the user's controller. Can be a value from 0 to 3.
      State     -   [out] Receives the current state of the controller.
    
    Returns:
      If the function succeeds, the return value is ERROR_SUCCESS (zero).
      If the controller is not connected, the return value is ERROR_DEVICE_NOT_CONNECTED (1167).
      If the function fails, the return value is an error code defined in Winerror.h.
        http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
      XInput.dll returns controller state as a binary structure:
        http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_state
        http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_gamepad
      XInput.ahk converts this structure to an AutoHotkey_L object.
  */
  XInput_GetState(UserIndex)
  {
    global _XInput_GetState
    
    VarSetCapacity(xiState,16)

    if ErrorLevel := DllCall(_XInput_GetState ,"uint",UserIndex ,"uint",&xiState)
      return 0
    
    return {
    (Join,
      dwPacketNumber: NumGet(xiState,  0, "UInt")
      wButtons:     NumGet(xiState,  4, "UShort")
      bLeftTrigger:   NumGet(xiState,  6, "UChar")
      bRightTrigger:  NumGet(xiState,  7, "UChar")
      sThumbLX:     NumGet(xiState,  8, "Short")
      sThumbLY:     NumGet(xiState, 10, "Short")
      sThumbRX:     NumGet(xiState, 12, "Short")
      sThumbRY:     NumGet(xiState, 14, "Short")
    )}
  }

  /*
    Function: XInput_SetState
    
    Sends data to a connected controller. This function is used to activate the vibration
    function of a controller.
    
    Parameters:
      UserIndex     -   [in] Index of the user's controller. Can be a value from 0 to 3.
      LeftMotorSpeed  -   [in] Speed of the left motor, between 0 and 65535.
      RightMotorSpeed -   [in] Speed of the right motor, between 0 and 65535.
    
    Returns:
      If the function succeeds, the return value is 0 (ERROR_SUCCESS).
      If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
      If the function fails, the return value is an error code defined in Winerror.h.
        http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    Remarks:
      The left motor is the low-frequency rumble motor. The right motor is the
      high-frequency rumble motor. The two motors are not the same, and they create
      different vibration effects.
  */
  XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
  {
    global _XInput_SetState
    return DllCall(_XInput_SetState ,"uint",UserIndex ,"uint*",LeftMotorSpeed|RightMotorSpeed<<16)
  }

  /*
    Function: XInput_GetCapabilities
    
    Retrieves the capabilities and features of a connected controller.
    
    Parameters:
      UserIndex   -   [in] Index of the user's controller. Can be a value in the range 0–3.
      Flags     -   [in] Input flags that identify the controller type.
                  0   - All controllers.
                  1   - XINPUT_FLAG_GAMEPAD: Xbox 360 Controllers only.
      Caps    -   [out] Receives the controller capabilities.
    
    Returns:
      If the function succeeds, the return value is 0 (ERROR_SUCCESS).
      If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
      If the function fails, the return value is an error code defined in Winerror.h.
        http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    Remarks:
      XInput.dll returns capabilities via a binary structure:
        http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_capabilities
      XInput.ahk converts this structure to an AutoHotkey_L object.
  */
  XInput_GetCapabilities(UserIndex, Flags)
  {
    global _XInput_GetCapabilities
    
    VarSetCapacity(xiCaps,20)
    
    if ErrorLevel := DllCall(_XInput_GetCapabilities ,"uint",UserIndex ,"uint",Flags ,"ptr",&xiCaps)
      return 0
    
    return,
    (Join
      {
        Type:           NumGet(xiCaps,  0, "UChar"),
        SubType:        NumGet(xiCaps,  1, "UChar"),
        Flags:          NumGet(xiCaps,  2, "UShort"),
        Gamepad:
        {
          wButtons:       NumGet(xiCaps,  4, "UShort"),
          bLeftTrigger:     NumGet(xiCaps,  6, "UChar"),
          bRightTrigger:    NumGet(xiCaps,  7, "UChar"),
          sThumbLX:       NumGet(xiCaps,  8, "Short"),
          sThumbLY:       NumGet(xiCaps, 10, "Short"),
          sThumbRX:       NumGet(xiCaps, 12, "Short"),
          sThumbRY:       NumGet(xiCaps, 14, "Short")
        },
        Vibration:
        {
          wLeftMotorSpeed:  NumGet(xiCaps, 16, "UShort"),
          wRightMotorSpeed:   NumGet(xiCaps, 18, "UShort")
        }
      }
    )
  }

  /*
    Function: XInput_Term
    Unloads the previously loaded XInput DLL.
  */
  XInput_Term() {
    global
    if _XInput_hm
      DllCall("FreeLibrary","uint",_XInput_hm), _XInput_hm :=_XInput_GetState :=_XInput_SetState :=_XInput_GetCapabilities :=0
  }

 ; TODO: XInputEnable, 'GetBatteryInformation and 'GetKeystroke.
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



;;;;;;;  Notify() 0.45        made by gwarble - sept 09
 ;;;    multiple tray area notifications
 ;      thanks to Rhys/engunneer/HugoV/Forum Posters
 ;
 ;   Notify([Title,Message,Duration,Options,Image])
 ;
 ;   Title    [!!!]      "" to omit title line
 ;   Message    []       "" to omit message line
 ;   Duration  [15]      seconds to show notification
 ;                 0  to flash until clicked
 ;                <0  to ExitApp on click/timeout
 ;                 "-0" for permanent and exitOnClick
 ;   Options           string of options... see function
 ;      [SI=999 GC=Blue...]  most options are remembered (static)
 ;                 "Reset" to restore default options
 ;                 if you want to show as well, use NO=Reset
 ;                 "Wait" to wait for a notification  ***
 ;   Image []          Image file name/library or
 ;                 number of icon in shell32.dll
 ; 110 220
 ; 132        These are different sys32 icon numbers
 ; 145
 ; 239 Reload
 ; 250 dll
 ; 297 Check 145 red
 ; 312 White cross out
 ;                 Gui Number to "Wait" for      ***
 ;
 ;   Return          Gui Number used           ***
 ;                 0 if failed (too many open)
 ;
 Notify(Title="!!!",Message="",Duration=30,Options="",Image="")
 {
  Static        ;Options string: "TS=12 GC=Blue..."
  static GF := 50     ;  Gui First Number  ;= override Gui: # used
  static GL := 74     ;  Gui Last Number   ;= between GF and GL
  static GC := "FFFFAA" ;  Gui Color     ;   ie: don't use GF<=Gui#<=GL
  static GR := 9    ;  Gui Radius    ;     elsewhere in your script
  static GT := "Off"  ;  Gui Transparency
  static TS := 9    ;  Title Font Size
  static TW := 625    ;  Title Font Weight
  static TC := "Black"  ;  Title Font Color
  static TF := "Arial"  ;  Title Font Face
  static MS := 8    ;Message Font Size
  static MW := 550    ;Message Font Weight
  static MC := "Black"  ;Message Font Color
  static MF := "Arial"  ;Message Font Face
  static BC := "000000"  ; Border Colors
  static BW := 2    ; Border Width/Thickness
  static BR := 13     ; Border Radius
  static BT := 105    ; Border Transpacency
  static BF := 150    ; Border Flash Speed
  static SI := 100    ;  Speed In (AnimateWindow)
  static SC := 100    ;  Speed Clicked (AnimateWindow)
  static ST := 100    ;  Speed TimeOut (AnimateWindow)
  static IW := 32     ;  Image Width
  static IH := 32     ;  Image Height
  static IN := 0    ;  Image Icon Number (from Image)
  static AX := 0    ; Action X Close Button (maybe add yes/no ok/cancel, etc...)
  local AC, AT      ;Actions Clicked/Timeout
  local _Notify_Action, ImageOptions, GY, OtherY

  _Notify_:
  local NO := 0     ;NO is Notify Option [NO=Reset]
  If (Options)
  {
  IfInString, Options, =
  {
  Loop,Parse,Options,%A_Space%
    If (Option:= SubStr(A_LoopField,1,2))
    %Option%:= SubStr(A_LoopField,4)
  If NO = Reset
  {
    Options := "GF=50 GL=74 GC=FFFFAA GR=9 GT=Off "
    . "TS=8 TW=625 TC=Black TF=Arial MS=8 MW=550 MC=Black MF=Arial "
    . "BC=Black BW=2 BR=9 BT=105 BF=150 SC=300 SI=250 ST=100 "
    . "IW=32 IH=32 IN=0"
    Goto, _Notify_
  }
  }
  Else If Options = Wait
  Goto, _Notify_Wait_
  }


  GN := GF
  Loop
  IfNotInString, NotifyList, % "|" GN
  Break
  Else
  If (++GN > GL)
    Return 0        ;=== too many notifications open!
  NotifyList .= "|" GN
  GN2 := GN + GL - GF + 1
  If AC <>
  ActionList .= "|" GN "=" AC

  Prev_DetectHiddenWindows := A_DetectHiddenWindows
  Prev_TitleMatchMode := A_TitleMatchMode
  DetectHiddenWindows On
  SetTitleMatchMode 1
  If (WinExist("NotifyGui"))  ;=== find all Notifications from ALL scripts, for placement
  WinGetPos, OtherX, OtherY  ;=== change this to a loop for all open notifications?
  DetectHiddenWindows %Prev_DetectHiddenWindows%
  SetTitleMatchMode %Prev_TitleMatchMode%

  Gui, %GN%:-Caption +ToolWindow +AlwaysOnTop -Border
  Gui, %GN%:Color, %GC%
  Gui, %GN%:Font, w%TW% s%TS% c%TC%, %TF%
  If (Image)
  {
  If FileExist(Image)
  Gui, %GN%:Add, Picture, w%IW% h%IH% Icon%IN%, % Image
  Else
  Gui, %GN%:Add, Picture, w%IW% h%IH% Icon%Image%, c:\windows\system32\shell32.dll
  ImageOptions = x+10
  }
  If Title <>
  Gui, %GN%:Add, Text, % ImageOptions, % Title
  Gui, %GN%:Font, w%MW% s%MS% c%MC%, %MF%
  If ((Title) && (Message))
  Gui, %GN%:Margin, , -5
  If Message <>
  Gui, %GN%:Add, Text,, % Message
  If ((Title) && (Message))
  Gui, %GN%:Margin, , 8
  Gui, %GN%:Show, Hide, NotifyGui
  Gui  %GN%:+LastFound
  WinGetPos, GX, GY, GW, GH

  If AX =
  {
  GW += 10
  Gui, %GN%:Font, w800 s6 c%MC%
  Gui, %GN%:Add, Text, % "x" GW-11 " y-1 Border Center w12 h12 g_Notify_Kill_" GN - GF + 1, X
  }

  Gui, %GN%:Add, Text, x0 y0 w%GW% h%GH% g_Notify_Action BackgroundTrans
  If (GR)
  WinSet, Region, % "0-0 w" GW " h" GH " R" GR "-" GR
  If (GT)
  WinSet, Transparent, % GT

  SysGet, Workspace, MonitorWorkArea
  NewX := WorkSpaceRight-GW-5
  If (OtherY)
  NewY := OtherY-GH-5
  Else
  NewY := WorkspaceBottom-GH-5
  If NewY < % WorkspaceTop
  NewY := WorkspaceBottom-GH-5

  Gui, %GN2%:-Caption +ToolWindow +AlwaysOnTop -Border +E0x20
  Gui, %GN2%:Color, %BC%
  Gui  %GN2%:+LastFound
  If (BR)
  WinSet, Region, % "0-0 w" GW+(BW*2) " h" GH+(BW*2) " R" BR "-" BR
  If (BT)
  WinSet, Transparent, % BT

  Gui, %GN2%:Show, % "Hide x" NewX-BW " y" NewY-BW " w" GW+(BW*2) " h" GH+(BW*2)
  Gui, %GN%:Show,  % "Hide x" NewX " y" NewY " w" GW, NotifyGui
  Gui  %GN%:+LastFound
  If SI
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SI,"UInt","0x00040008")
  Else
  Gui, %GN%:Show, NA, NotifyGui
  Gui, %GN2%:Show, NA
  WinSet, AlwaysOnTop, On

  If ((Duration < 0) OR (Duration = "-0"))
  Exit := GN
  If (Duration)
  SetTimer, % "_Notify_Kill_" GN - GF + 1, % - Abs(Duration) * 1000
  Else
  SetTimer, % "_Notify_Flash_" GN - GF + 1, % BF

  Return % GN

  ;==========================================================================
  ;========================================== when a notification is clicked:
  _Notify_Action:
  ;Critical
  SetTimer, % "_Notify_Kill_" A_Gui - GF + 1, Off
  Gui, % A_Gui + GL - GF + 1 ":Destroy"
  Gui  %A_Gui%:+LastFound
  If SC
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SC,"UInt", "0x00050001")
  Gui, %A_Gui%:Destroy
  If (ActionList)
  Loop,Parse,ActionList,|
  If ((Action := SubStr(A_LoopField,1,2)) = A_Gui)
  {
    Temp_Notify_Action:= SubStr(A_LoopField,4)
    StringReplace, ActionList, ActionList, % "|" A_Gui "=" Temp_Notify_Action, , All
    If IsLabel(_Notify_Action := Temp_Notify_Action)
    Gosub, %_Notify_Action%
    _Notify_Action =
    Break
  }
  StringReplace, NotifyList, NotifyList, % "|" GN, , All
  SetTimer, % "_Notify_Flash_" A_Gui - GF + 1, Off
  If (Exit = A_Gui)
  ExitApp
  Return

  ;==========================================================================
  ;=========================================== when a notification times out:
  _Notify_Kill_1:
  _Notify_Kill_2:
  _Notify_Kill_3:
  _Notify_Kill_4:
  _Notify_Kill_5:
  _Notify_Kill_6:
  _Notify_Kill_7:
  _Notify_Kill_8:
  _Notify_Kill_9:
  _Notify_Kill_10:
  _Notify_Kill_11:
  _Notify_Kill_12:
  _Notify_Kill_13:
  _Notify_Kill_14:
  _Notify_Kill_15:
  _Notify_Kill_16:
  _Notify_Kill_17:
  _Notify_Kill_18:
  _Notify_Kill_19:
  _Notify_Kill_20:
  _Notify_Kill_21:
  _Notify_Kill_22:
  _Notify_Kill_23:
  _Notify_Kill_24:
  _Notify_Kill_25:
  ;Critical
  StringReplace, GK, A_ThisLabel, _Notify_Kill_
  SetTimer, _Notify_Flash_%GK%, Off
  GK += GF - 1
  Gui, % GK + GL - GF + 1 ":Destroy"
  Gui  %GK%:+LastFound
  If ST
  DllCall("AnimateWindow","UInt",WinExist(),"Int",ST,"UInt", "0x00050001")
  Gui, %GK%:Destroy
  StringReplace, NotifyList, NotifyList, % "|" GK
  If (Exit = GK)
  ExitApp
  Return

  ;==========================================================================
  ;======================================== flashes a permanent notification:
  _Notify_Flash_1:
  _Notify_Flash_2:
  _Notify_Flash_3:
  _Notify_Flash_4:
  _Notify_Flash_5:
  _Notify_Flash_6:
  _Notify_Flash_7:
  _Notify_Flash_8:
  _Notify_Flash_9:
  _Notify_Flash_10:
  _Notify_Flash_11:
  _Notify_Flash_12:
  _Notify_Flash_13:
  _Notify_Flash_14:
  _Notify_Flash_15:
  _Notify_Flash_16:
  _Notify_Flash_17:
  _Notify_Flash_18:
  _Notify_Flash_19:
  _Notify_Flash_20:
  _Notify_Flash_21:
  _Notify_Flash_22:
  _Notify_Flash_23:
  _Notify_Flash_24:
  _Notify_Flash_25:
  StringReplace, FlashGN, A_ThisLabel, _Notify_Flash_
  FlashGN += GF - 1
  FlashGN2 := FlashGN + GL - GF + 1
  If Flashed%FlashGN2% := !Flashed%FlashGN2%
  Gui, %FlashGN2%:Color, Silver
  Else
  Gui, %FlashGN2%:Color, % BC
  Return

  ;==========================================================================
  ;============================= wait for (or force) a notification to close:
  _Notify_Wait_:
  ;Critical
  If (Image)
  {
  Gui %Image%:+LastFound
  If NotifyGuiID := WinExist()
  {
  WinWaitClose, , , % Abs(Duration)
  If (ErrorLevel && Duration < 1)
  {
    Gui, % Image + GL - GF + 1 ":Destroy"
    DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001")
    Gui, %Image%:Destroy
  }
  }
  }
  Else
  Loop, % GL-GF
  {
  Image := GL - (A_Index) ;+ GF - 1)
  Gui %Image%:+LastFound
  If NotifyGuiID := WinExist()
  {
  ;WinWaitClose, , , % Abs(Duration)
  ;If (ErrorLevel && Duration < 1)
  ;{
    Gui, % Image + GL - GF + 1 ":Destroy"
    DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001")
    Gui, %Image%:Destroy
  ;}
  }
  }
  Return
 }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



; Load_Bar - Cool Gradient progress bar class by joedf (using CreateDIB by SKAN)
  class LoaderBar {
    __New(GUI_ID:="Default",x:=0,y:=0,w:=280,h:=28,ShowDesc:=0,FontColorDesc:="2B2B2B",FontColor:="EFEFEF",BG:="2B2B2B|2F2F2F|323232",FG:="66A3E2|4B79AF|385D87") {
      SetWinDelay,0
      SetBatchLines,-1
      if (StrLen(A_Gui))
        _GUI_ID:=A_Gui
      else
        _GUI_ID:=1
      if ( (GUI_ID="Default") || !StrLen(GUI_ID) || GUI_ID==0 )
        GUI_ID:=_GUI_ID
      this.GUI_ID := GUI_ID
      Gui, %GUI_ID%:Default
      this.BG := StrSplit(BG,"|")
      this.BG.W := w
      this.BG.H := h
      this.Width:=w
      this.Height:=h
      this.FG := StrSplit(FG,"|")
      this.FG.W := this.BG.W - 2
      this.FG.H := (fg_h:=(this.BG.H - 2))
      this.Percent := 0
      this.X := x
      this.Y := y
      fg_x:= this.X + 1
      fg_y:= this.Y + 1
      this.FontColor := FontColor
      this.ShowDesc := ShowDesc
      
      ;DescBGColor:="4D4D4D"
      DescBGColor:="Black"
      this.DescBGColor := DescBGColor
      
      this.FontColorDesc := FontColorDesc
      
      Gui,Font,s8
      
      Gui, Add, Text, x%x% y%y% w%w% h%h% 0xE hwndhLoaderBarBG
        this.ApplyGradient(this.hLoaderBarBG := hLoaderBarBG,this.BG.1,this.BG.2,this.BG.3,1)
        
        Gui, Add, Text, x%fg_x% y%fg_y% w0 h%fg_h% 0xE hwndhLoaderBarFG
        this.ApplyGradient(this.hLoaderBarFG := hLoaderBarFG,this.FG.1,this.FG.2,this.FG.3,1)
        
      Gui, Add, Text, x%x% y%y% w%w% h%h% 0x200 border center BackgroundTrans hwndhLoaderNumber c%FontColor%, % "[ 0 % ]"
        this.hLoaderNumber := hLoaderNumber
      
      if (this.ShowDesc) {
        ;Gui, Add, Text, xp y+2 w%w% h16 0x200 border Background%DescBGColor% hwndhLoaderDesc, Loading...
        Gui, Add, Text, xp y+2 w%w% h16 0x200 border BackgroundTrans hwndhLoaderDesc c%FontColorDesc%, Loading...
        this.hLoaderDesc := hLoaderDesc
        this.Height:=h+18
      }
        
      Gui,Font
      
      Gui, %_GUI_ID%:Default
    }
    
    Set(p,w:="Loading...") {
      if (StrLen(A_Gui))
        _GUI_ID:=A_Gui
      else
        _GUI_ID:=1
      GUI_ID := this.GUI_ID
      Gui, %GUI_ID%:Default
      GuiControlGet, LoaderBarBG, Pos, % this.hLoaderBarBG
      this.BG.W := LoaderBarBGW
      this.FG.W := LoaderBarBGW - 2
      this.Percent:=(p>=100) ? p:=100 : p
      PercentNum:=Round(this.Percent,0)
      PercentBar:=floor((this.Percent/100)*(this.FG.W))
      
      hLoaderBarFG := this.hLoaderBarFG
      hLoaderNumber := this.hLoaderNumber
      
      GuiControl,Move,%hLoaderBarFG%,w%PercentBar%
      GuiControl,,%hLoaderNumber%,[ %PercentNum% `% ]
      
      if (this.ShowDesc) {
        hLoaderDesc := this.hLoaderDesc
        GuiControl,,%hLoaderDesc%, %w%
      }
      Gui, %_GUI_ID%:Default
    }
    
    ApplyGradient( Hwnd, LT := "101010", MB := "0000AA", RB := "00FF00", Vertical := 1 ) {
      Static STM_SETIMAGE := 0x172 
      ControlGetPos,,, W, H,, ahk_id %Hwnd%
      PixelData := Vertical ? LT "|" LT "|" LT "|" MB "|" MB "|" MB "|" RB "|" RB "|" RB : LT "|" MB "|" RB "|" LT "|" MB "|" RB "|" LT "|" MB "|" RB
      hBitmap := this.CreateDIB( PixelData, 3, 3, W, H, True )
      oBitmap := DllCall( "SendMessage", "Ptr",Hwnd, "UInt",STM_SETIMAGE, "Ptr",0, "Ptr",hBitmap )
      Return hBitmap, DllCall( "DeleteObject", "Ptr",oBitmap )
    }
    
    CreateDIB( PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1  ) {    
      ; http://ahkscript.org/boards/viewtopic.php?t=3203          SKAN, CD: 01-Apr-2014 MD: 05-May-2014
      Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
        ,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4 
        ,  LR_Flag3 := 0x0008 ; LR_COPYDELETEORG := 8
      WB := Ceil( ( W * 3 ) / 2 ) * 2,  VarSetCapacity( BMBITS, WB * H + 1, 0 ),  P := &BMBITS
      Loop, Parse, PixelData, |
      P := Numput( "0x" A_LoopField, P+0, 0, "UInt" ) - ( W & 1 and Mod( A_Index * 3, W * 3 ) = 0 ? 0 : 1 )
      hBM := DllCall( "CreateBitmap", "Int",W, "Int",H, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )  
      hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag1, "Ptr" ) 
      DllCall( "SetBitmapBits", "Ptr",hBM, "UInt",WB * H, "Ptr",&BMBITS )
      If not ( Gradient + 0 )
        hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag3, "Ptr" )  
      Return DllCall( "CopyImage", "Ptr",hBM, "Int",0, "Int",ResizeW, "Int",ResizeH, "Int",LR_Flag2, "UPtr" )
    }
  }
  ; Function wrapper for the Load_bar class by Bandit
  Load_BarControl(Percent:=0,uText:="Loading...",ShowGui:=0)
  {
    Global
    Static LoadBar_Initialized := 0
    If (!LoadBar_Initialized)
    {
      LoadBar_Initialized := 1
      LastDisplay_LB := 0
      Gui, load_BarGUI: New
      Gui, load_BarGUI:-Border -Caption +ToolWindow +AlwaysOnTop
      Gui, load_BarGUI:Color, 0x4D4D4D, 0xFFFFFF
      load_Bar := new LoaderBar("load_BarGUI",3,3,280,28,1,"EFEFEF")
      LB_wW:=load_Bar.Width + 2*load_Bar.X
      LB_wH:=load_Bar.Height + 2*load_Bar.Y
    }
    If (ShowGui)
    {
      Gui, load_BarGUI:Show, % "NA w" LB_wW " h" LB_wH " x10 y" Round(A_ScreenHeight * .5) ,Load Bar
    }

    load_Bar.Set(Percent,uText)
    If (ShowGui < 0)
      SetTimer, Load_BarControl_Hide, -1000
    Return

    Load_BarControl_Hide:
      Gui, load_BarGUI: Hide
    Return
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*** PoEPrices.info functions from PoE-TradeMacro v2.15.7
*  Contains all the assorted functions needed to launch TradeFunc_DoPoePricesRequest
*/
  TradeFunc_DoPoePricesRequest(RawItemData, ByRef retCurl) {
    RawItemData := RegExReplace(RawItemData, "<<.*?>>|<.*?>")
    encodingError := ""
    EncodedItemData := StringToBase64UriEncoded(RawItemData, true, encodingError)
    
    postData   := "l=" UriEncode(selectedLeague) "&i=" EncodedItemData
    ; postData   := "l=" UriEncode(TradeGlobals.Get("LeagueName")) "&i=" EncodedItemData
    payLength  := StrLen(postData)
    url     := "https://www.poeprices.info/api"
    
    reqTimeout := 25
    options  := "RequestType: GET"
    ;options  .= "`n" "ReturnHeaders: skip"
    options  .= "`n" "ReturnHeaders: append"
    options  .= "`n" "TimeOut: " reqTimeout
    reqHeaders := []

    reqHeaders.push("Connection: keep-alive")
    reqHeaders.push("Cache-Control: max-age=0")
    reqHeaders.push("Origin: https://poeprices.info")
    reqHeaders.push("Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8")
    
    ; ShowToolTip("Getting price prediction... ")
    retCurl := true
    response := PoEScripts_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
    
    ; debugout := RegExReplace("""" A_ScriptDir "\lib\" retCurl, "curl", "curl.exe""")
    ; FileDelete, %A_ScriptDir%\temp\poeprices_request.txt
    ; FileAppend, %debugout%, %A_ScriptDir%\temp\poeprices_request.txt
    
    
    ; If (TradeOpts.Debug) {
      ; FileDelete, %A_ScriptDir%\temp\DebugSearchOutput.html
      ; FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugSearchOutput.html
    ; }

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

    ; If (TradeOpts.Debug) {
    ;   arr := {}
    ;   arr.RawItemData := RawItemData
    ;   arr.EncodedItemata := EncodedItemData
    ;   arr.League := TradeGlobals.Get("LeagueName")
    ;   TradeFunc_LogPoePricesRequest(arr, request, "poe_prices_debug_log.txt")
    ; }

    ; responseObj.added := {}
    ; responseObj.added.encodedData := EncodedItemData
    ; responseObj.added.league := TradeGlobals.Get("LeagueName")
    ; responseObj.added.requestUrl := url "?" postData
    ; responseObj.added.browserUrl := url "?" postData "&w=1"
    ; responseObj.added.encodingError := encodingError
    ; responseObj.added.retHeader := responseHeader
    ; responseObj.added.timeoutParam := reqTimeout
    
    Return responseObj
  }

  StringToBase64UriEncoded(stringIn, noUriEncode = false, ByRef errorMessage = "") {
    FileDelete, %A_ScriptDir%\temp\itemText.txt
    FileDelete, %A_ScriptDir%\temp\base64Itemtext.txt
    FileDelete, %A_ScriptDir%\temp\encodeToBase64.txt
    
    encodeError1 := ""
    encodeError2 := ""
    stringBase64 := b64Encode(stringIn, encodeError1)
    
    If (not StrLen(stringBase64)) {
      FileAppend, %stringIn%, %A_ScriptDir%\temp\itemText.txt, utf-8
      command    := "certutil -encode -f ""%cd%\temp\itemText.txt"" ""%cd%\temp\base64ItemText.txt"" & type ""%cd%\temp\base64ItemText.txt"""
      stringBase64  := ReadConsoleOutputFromFile(command, "encodeToBase64.txt", encodeError2)
      stringBase64  := Trim(RegExReplace(stringBase64, "i)-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|77u/", ""))
    }

    If (not StrLen(stringBase64)) {
      errorMessage := ""
      If (StrLen(encodeError1)) {
        errorMessage .= encodeError1 " "
      }
      If (StrLen(encodeError2)) {
        errorMessage .= "Encoding via certutil returned: " encodeError2
      }
    }
    
    If (not noUriEncode) {
      stringBase64  := UriEncode(stringBase64)
      stringBase64  := RegExReplace(stringBase64, "i)^(%0D)?(%0A)?|((%0D)?(%0A)?)+$", "")
    } Else {
      stringBase64 := RegExReplace(stringBase64, "i)\r|\n", "")
    }
    
    Return stringBase64
  }

  /*  Base64 Encode / Decode a string (binary-to-text encoding)
    https://github.com/jNizM/AHK_Scripts/blob/master/src/encoding_decoding/base64.ahk
    
    Alternative: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Base64.ahk
    */
  b64Encode(string, ByRef error = "") {  
    VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1 
    If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size)) {
      ;throw Exception("CryptBinaryToString failed", -1)
      error := "Exception (1) while encoding string to base64."
    }  
    VarSetCapacity(buf, size << 1, 0)
    If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size)) {
      ;throw Exception("CryptBinaryToString failed", -1)
      error := "Exception (2) while encoding string to base64."
    }
    
    If (not StrLen(Error)) {
      Return StrGet(&buf)
    } Else {
      Return ""
    }
  }
  b64Decode(string) {
    If !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
      throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    If !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
      throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
  }

  UriEncode(Uri, Enc = "UTF-8")  {
    StrPutVar(Uri, Var, Enc)
    f := A_FormatInteger
    SetFormat, IntegerFast, H
    Loop
    {
      Code := NumGet(Var, A_Index - 1, "UChar")
      If (!Code)
        Break
      If (Code >= 0x30 && Code <= 0x39 ; 0-9
        || Code >= 0x41 && Code <= 0x5A ; A-Z
        || Code >= 0x61 && Code <= 0x7A) ; a-z
        Res .= Chr(Code)
      Else
        Res .= "%" . SubStr(Code + 0x100, -1)
    }
    SetFormat, IntegerFast, %f%
    Return, Res
  }

  StrPutVar(Str, ByRef Var, Enc = "") {
    Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
    VarSetCapacity(Var, Len, 0)
    Return, StrPut(Str, &Var, Enc)
  }

  RandomStr(l = 24, i = 48, x = 122) { ; length, lowest and highest Asc value
    Loop, %l% {
      Random, r, i, x
      s .= Chr(r)
    }
    s := RegExReplace(s, "\W", "i") ; only alphanum.
    
    Return, s
  }

  PoEScripts_Download(url, ioData, ByRef ioHdr, options, useFallback = true, critical = false, binaryDL = false, errorMsg = "", ByRef reqHeadersCurl = "", handleAccessForbidden = true, ByRef returnCurl = false) {
    /*
      url    = download url
      ioData  = uri encoded postData 
      ioHdr  = array of request headers
      options  = multiple options separated by newline (currently only "SaveAs:",  "Redirect:true/false")
      
      useFallback = Use UrlDownloadToFile if curl fails, not possible for POST requests or when cookies are required 
      critical  = exit macro if download fails
      binaryDL  = file download (zip for example)
      errorMsg  = optional error message, will be added to default message
      reqHeadersCurl = returns the returned headers from the curl request 
      handleAccessForbidden = "true" throws an error message if "403 Forbidden" is returned, "false" prevents it, returning "403 Forbidden" to enable custom error handling
    */

    ; https://curl.haxx.se/download.html -> https://bintray.com/vszakats/generic/curl/
    /*
      parse options, create the cURL request and execute it
    */
    reqLoops++
    curl    := """" A_ScriptDir "\data\curl.exe"" "  
    headers  := ""
    cookies  := ""
    uAgent  := ""

    For key, val in ioHdr {    
      val := Trim(RegExReplace(val, "i)(.*?)\s*:\s*(.*)", "$1:$2"))

      If (RegExMatch(val, "i)^Cookie:(.*)", cookie)) {
        cookies .= cookie1 " "    
      }
      If (RegExMatch(val, "i)^User-Agent:(.*)", ua)) {
        uAgent := ua1 " "    
      }
    }
    cookies := StrLen(cookies) ? "-b """ Trim(cookies) """ " : ""
    uAgent := StrLen(uAgent) ? "-A """ Trim(uAgent) """ " : ""
    
    redirect := "L"
    PreventErrorMsg := false
    validateResponse := 1
    If (StrLen(options)) {
      Loop, Parse, options, `n 
      {
        If (RegExMatch(A_LoopField, "i)SaveAs:[ \t]*\K[^\r\n]+", SavePath)) {
          commandData  .= " " A_LoopField " "
          commandHdr  .= ""  
        }
        If (RegExMatch(A_LoopField, "i)Redirect:\sFalse")) {
          redirect := ""
        }
        If (RegExMatch(A_LoopField, "i)parseJSON:\sTrue")) {
          ignoreRetCodeForJSON := true
        }
        If (RegExMatch(A_LoopField, "i)PreventErrorMsg")) {
          PreventErrorMsg := true
        }
        If (RegExMatch(A_LoopField, "i)RequestType:(.*)", match)) {
          requestType := Trim(match1)
        }
        If (RegExMatch(A_LoopField, "i)ReturnHeaders:(.*skip.*)")) {
          skipRetHeaders := true
        }
        If (RegExMatch(A_LoopField, "i)ReturnHeaders:(.*append.*)")) {
          appendRetHeaders := true
        }
        If (RegExMatch(A_LoopField, "i)TimeOut:(.*)", match)) {
          timeout := Trim(match1)
        }
        If (RegExMatch(A_LoopField, "i)ValidateResponse:(.*)", match)) {
          If (Trim(match1) = "false") {
            validateResponse := 0
          }        
        }  
      }      
    }
    If (not timeout or timeout < 5) {
      timeout := 25
    }
    
    e := {}
    Try {    
      commandData  := ""    ; console curl command to return data/content 
      commandHdr  := ""    ; console curl command to return headers
      If (binaryDL) {
        commandData .= " -" redirect "Jkv "    ; save as file
        If (SavePath) {
          commandData .= "-o """ SavePath """ "  ; set target destination and name
        }
      } Else {
        commandData .= " -" redirect "ks --compressed "
        If (requestType = "GET") {        
          ;commandHdr  .= " -s" redirect " -D - -o /dev/null " ; unix
          commandHdr  .= " -s" redirect " -D - -o nul " ; windows
        } Else {
          commandHdr  .= " -I" redirect "ks "
        }
        
        If (appendRetHeaders) {
          commandData  .= " -w '%{http_code}' "
          commandHdr  .= " -w '%{http_code}' "
        }
      }      

      If (not requestType = "GET") {
        commandData .= headers
        commandHdr  .= headers
      }      
      If (StrLen(cookies)) {
        commandData .= cookies
        commandHdr  .= cookies
      }
      If (StrLen(uAgent)) {
        commandData .= uAgent
        commandHdr  .= uAgent
      }

      If (StrLen(ioData) and not requestType = "GET") {
        If (requestType = "POST") {
          commandData .= "-X POST "
        }
        commandData .= "--data """ ioData """ "
      } Else If (StrLen(ioData)) {
        url := url "?" ioData
      }
      
      If (binaryDL) {
        commandData  .= "--connect-timeout " timeout " "
        commandData  .= "--connect-timeout " timeout " "
      } Else {
        commandData  .= "--connect-timeout " timeout " --max-time " timeout + 15 " "
        commandHdr  .= "--connect-timeout " timeout " --max-time " timeout + 15 " "
      }
      ; get data
      html  := StdOutStream(curl """" url """" commandData)
      
      ;html := ReadConsoleOutputFromFile(curl """" url """" commandData, "commandData") ; alternative function
      
      If (returnCurl) {
        returnCurl := "curl " """" url """" commandData
      }

      ; get return headers in seperate request
      If (not binaryDL and not skipRetHeaders) {
        If (StrLen(ioData) and not requestType = "GET") {
          commandHdr := curl """" url "?" ioData """" commandHdr    ; add payload to url since you can't use the -I argument with POST requests          
        } Else {
          commandHdr := curl """" url """" commandHdr
        }
        ioHdr := StdOutStream(commandHdr)
        ;ioHrd := ReadConsoleOutputFromFile(commandHdr, "commandHdr") ; alternative function
      } Else If (skipRetHeaders) {
        commandHdr := curl """" url """" commandHdr
        ioHdr := html
      } Else {
        ioHdr := html
      }
      ;msgbox % curl """" url """" commandData "`n`n" commandHdr
      reqHeadersCurl := commandHdr
    } Catch e {

    }
    
    Return html
  }

  ReadConsoleOutputFromFile(command, fileName, ByRef error = "") {
    file := "temp\" fileName
    RunWait %comspec% /c "chcp 1251 /f >nul 2>&1 & %command% > %file%", , Hide
    FileRead, io, %file%
    
    If (FileExist(file) and not StrLen(io)) {
      error := "Output file is empty."
    }
    Else If (not FileExist(file)) {
      error := "Output file does not exist."
    }
    
    Return io
  }

  StdOutStream(sCmd, Callback = "") {
    /*
      Runs commands in a hidden cmdlet window and returns the output.
    */
                ; Modified  :  Eruyome 18-June-2017
    Static StrGet := "StrGet"  ; Modified  :  SKAN 31-Aug-2013 http://goo.gl/j8XJXY
                ; Thanks to :  HotKeyIt     http://goo.gl/IsH1zs
                ; Original  :  Sean 20-Feb-2007 http://goo.gl/mxCdn
    64Bit := A_PtrSize=8

    DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
    DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

    If 64Bit {
      VarSetCapacity( STARTUPINFO, 104, 0 )    ; STARTUPINFO      ;  http://goo.gl/fZf24
      NumPut( 68,     STARTUPINFO,  0 )    ; cbSize
      NumPut( 0x100,    STARTUPINFO, 60 )    ; dwFlags  =>  STARTF_USESTDHANDLES = 0x100
      NumPut( hPipeWrite, STARTUPINFO, 88 )    ; hStdOutput
      NumPut( hPipeWrite, STARTUPINFO, 96 )    ; hStdError

      VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI
    } Else {
      VarSetCapacity( STARTUPINFO, 68,  0 )    ; STARTUPINFO      ;  http://goo.gl/fZf24
      NumPut( 68,     STARTUPINFO,  0 )    ; cbSize
      NumPut( 0x100,    STARTUPINFO, 44 )    ; dwFlags  =>  STARTF_USESTDHANDLES = 0x100
      NumPut( hPipeWrite, STARTUPINFO, 60 )    ; hStdOutput
      NumPut( hPipeWrite, STARTUPINFO, 64 )    ; hStdError

      VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI
    }

    If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0 ;  http://goo.gl/USC5a
          , UInt,1, UInt,0x08000000, UInt,0, UInt,0
          , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION )
    Return ""
    , DllCall( "CloseHandle", UInt,hPipeWrite )
    , DllCall( "CloseHandle", UInt,hPipeRead )
    , DllCall( "SetLastError", Int,-1 )

    hProcess := NumGet( PROCESS_INFORMATION, 0 )
    If 64Bit {
      hThread  := NumGet( PROCESS_INFORMATION, 8 )
    } Else {
      hThread  := NumGet( PROCESS_INFORMATION, 4 )
    }

    DllCall( "CloseHandle", UInt,hPipeWrite )

    AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )           ;  A_IsClassic
    VarSetCapacity( Buffer, 4096, 0 ), nSz := 0

    While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {
      tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) )
          ? Buffer : %StrGet%( &Buffer, nSz, "CP850" )

      Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput
    }

    DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
    DllCall( "CloseHandle",  UInt,hProcess  )
    DllCall( "CloseHandle",  UInt,hThread   )
    DllCall( "CloseHandle",  UInt,hPipeRead )
    DllCall( "SetLastError", UInt,ExitCode  )

    Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



; Function:       IPv4 ping with name resolution, based upon 'SimplePing' by Uberi ->
  ; ======================================================================================================================
  ;                 http://www.autohotkey.com/board/topic/87742-simpleping-successor-of-ping/
  ; Parameters:     Addr     -  IPv4 address or host / domain name.
  ;                 ----------  Optional:
  ;                 Result   -  Object to receive the result in three keys:
  ;                             -  InAddr - Original value passed in parameter Addr.
  ;                             -  IPAddr - The replying IPv4 address.
  ;                             -  RTTime - The round trip time, in milliseconds.
  ;                 Timeout  -  The time, in milliseconds, to wait for replies.
  ; Return values:  On success: The round trip time, in milliseconds.
  ;                 On failure: "", ErrorLevel contains additional informations.
  ; Tested with:    AHK 1.1.22.03
  ; Tested on:      Win 8.1 x64
  ; Authors:        Uberi / just me
  ; Change log:     1.0.01.00/2015-07-16/just me - fixed bug on Win 8
  ;                 1.0.00.00/2013-11-06/just me - initial release
  ; MSDN:           Winsock Functions   -> http://msdn.microsoft.com/en-us/library/ms741394(v=vs.85).aspx
  ;                 IP Helper Functions -> hhttp://msdn.microsoft.com/en-us/library/aa366071(v=vs.85).aspx
  ; ======================================================================================================================
  Ping4(Addr, ByRef Result := "", Timeout := 1024) {
    ; ICMP status codes -> http://msdn.microsoft.com/en-us/library/aa366053(v=vs.85).aspx
    ; WSA error codes  -> http://msdn.microsoft.com/en-us/library/ms740668(v=vs.85).aspx
    Static WSADATAsize := (2 * 2) + 257 + 129 + (2 * 2) + (A_PtrSize - 2) + A_PtrSize
    OrgAddr := Addr
    Result := ""
    ; -------------------------------------------------------------------------------------------------------------------
    ; Initiate the use of the Winsock 2 DLL
    VarSetCapacity(WSADATA, WSADATAsize, 0)
    If (Err := DllCall("Ws2_32.dll\WSAStartup", "UShort", 0x0202, "Ptr", &WSADATA, "Int")) {
      ErrorLevel := "WSAStartup failed with error " . Err
      Return ""
    }
    If !RegExMatch(Addr, "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") { ; Addr contains a name
      If !(HOSTENT := DllCall("Ws2_32.dll\gethostbyname", "AStr", Addr, "UPtr")) {
        DllCall("Ws2_32.dll\WSACleanup") ; Terminate the use of the Winsock 2 DLL
        ErrorLevel := "gethostbyname failed with error " . DllCall("Ws2_32.dll\WSAGetLastError", "Int")
        Return ""
      }
      PAddrList := NumGet(HOSTENT + 0, (2 * A_PtrSize) + 4 + (A_PtrSize - 4), "UPtr")
      PIPAddr  := NumGet(PAddrList + 0, 0, "UPtr")
      Addr := StrGet(DllCall("Ws2_32.dll\inet_ntoa", "UInt", NumGet(PIPAddr + 0, 0, "UInt"), "UPtr"), "CP0")
    }
    INADDR := DllCall("Ws2_32.dll\inet_addr", "AStr", Addr, "UInt") ; convert address to 32-bit UInt
    If (INADDR = 0xFFFFFFFF) {
      ErrorLevel := "inet_addr failed for address " . Addr
      Return ""
    }
    ; Terminate the use of the Winsock 2 DLL
    DllCall("Ws2_32.dll\WSACleanup")
    ; -------------------------------------------------------------------------------------------------------------------
    HMOD := DllCall("LoadLibrary", "Str", "Iphlpapi.dll", "UPtr")
    Err := ""
    If (HPORT := DllCall("Iphlpapi.dll\IcmpCreateFile", "UPtr")) { ; open a port
      REPLYsize := 32 + 8
      VarSetCapacity(REPLY, REPLYsize, 0)
      If DllCall("Iphlpapi.dll\IcmpSendEcho", "Ptr", HPORT, "UInt", INADDR, "Ptr", 0, "UShort", 0
                                , "Ptr", 0, "Ptr", &REPLY, "UInt", REPLYsize, "UInt", Timeout, "UInt") {
        Result := {}
        Result.InAddr := OrgAddr
        Result.IPAddr := StrGet(DllCall("Ws2_32.dll\inet_ntoa", "UInt", NumGet(Reply, 0, "UInt"), "UPtr"), "CP0")
        Result.RTTime := NumGet(Reply, 8, "UInt")
      }
      Else
        Err := "IcmpSendEcho failed with error " . A_LastError
      DllCall("Iphlpapi.dll\IcmpCloseHandle", "Ptr", HPORT)
    }
    Else
      Err := "IcmpCreateFile failed to open a port!"
    DllCall("FreeLibrary", "Ptr", HMOD)
    ; -------------------------------------------------------------------------------------------------------------------
    If (Err) {
      ErrorLevel := Err
      Return ""
    }
    ErrorLevel := 0
    Return Result.RTTime
  }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -


; Function: Create Matching ComboBox GUI
;--------------------------------------------------------------------------------
;================================================================================
  ;#[3.3.2.1 CBMatchingGUI]
  #IfWinActive, CBMatchingGUI
  ;================================================================================
  Enter::
  NumpadEnter::
  Tab::setCBMatchingGUILBChoice(CBMatchingGUI) ; pass GUI object reference

  Up::
  Down::ControlSend,, % A_ThisHotkey = "Up" ? "{Up}" : "{Down}", % "ahk_id "CBMatchingGUI.hLB

  #If WinActive("Add or Edit a Group")
  Tab::
    Gui, submit, NoHide
    ;...context specific stuff
    KeyWait, Tab
    GuiControlGet, OutputVarE, 2:Focus
    GuiControlGet, varname, 2:Focusv
    If (InStr(varname,"OrFlag") || InStr(varname,"Min") || InStr(varname,"Eval") || InStr(varname,"OrCount") || InStr(varname,"StashTab") || InStr(varname,"Export") || InStr(varname,"groupKey") || InStr(varname,"Click here to Finish and Return to CLF") || InStr(varname,"Remove") || InStr(varname,"Add new"))
      return
    OutputVar := StrReplace(OutputVarE, "Edit", "ComboBox")
    ControlGet, hCBe, hwnd,,%OutputVarE%
    ControlGet, hCB, hwnd,,%OutputVar%
    if (!WinExist("ahk_id "hCBMatchesGui) && hCB && hCBe) {
      CreateCBMatchingGUI(hCB, "Add or Edit a Group")
    }
  return

  #If WinActive("Edit Crafting Tiers")
  Tab::
    Gui, submit, NoHide
    ;...context specific stuff
    KeyWait, Tab
    GuiControlGet, OutputVarE, CustomCrafting:Focus
    GuiControlGet, varname, CustomCrafting:Focusv
    If ( InStr(OutputVarE,"SysTabControl") || InStr(OutputVarE,"Button") || !InStr(varname, "CustomCrafting") )
      Return
    OutputVar := StrReplace(OutputVarE, "Edit", "ComboBox")
    ControlGet, hCBe, hwnd,,%OutputVarE%
    ControlGet, hCB, hwnd,,%OutputVar%
    if (!WinExist("ahk_id "hCBMatchesGui) && hCB && hCBe) {
      CreateCBMatchingGUI(hCB, "Edit Crafting Tiers")
    }
  return

  CreateCBMatchingGUI(hCB, parentWindowTitle) {
  ;--------------------------------------------------------------------------------
    Global CBMatchingGUI := {}
    Gui CBMatchingGUI:New, -Caption -SysMenu -Resize +ToolWindow +AlwaysOnTop
    Gui, +HWNDhCBMatchesGui +Delimiter`n
    Gui, Margin, 0, 0
    Gui, Font, s14 q5
    
    ; get Parent ComboBox info
    WinGetPos, cX, cY, cW, cH, % "ahk_id " hCB
    ControlGet, CBList, List,,, % "ahk_id " hCB
    ; MsgBox % ErrorLevel
    ControlGet, CBChoice, Choice,,, % "ahk_id " hCB
    ; MsgBox % CBList ? "True" : "False"
    ; set Gui controls with Parent ComboBox info
    Gui, Add, Edit, % "+HWNDhEdit x0 y0 w"cW+200 " R1"
    GuiControl,, %hEdit%, %CBChoice%
    Gui, Add, ListBox, % "+HWNDhLB xp y+0 wp" " R20", % CBList
    GuiControl, ChooseString, %hLB%, %CBChoice%
    
    CBMatchingGUI.hwnd := hCBMatchesGui
    CBMatchingGUI.hEdit := hEdit
    CBMatchingGUI.hLB := hLB
    CBMatchingGUI.hParentCB := hCB
    CBMatchingGUI.parentCBList := CBList
    CBMatchingGUI.parentWindowTitle := parentWindowTitle
    
    gFunction := Func("CBMatching").Bind(CBMatchingGUI)
    GuiControl, +g, %hEdit%, %gFunction%
    
    Gui, Show, % "x"cX-5 " y"cY-5 " ", % "CBMatchingGUI"
    ControlFocus,, % "ahk_id "CBMatchingGUI.hEdit
    SetTimer, DestroyCBMatchingGUI, 80
  }

  ;--------------------------------------------------------------------------------
  CBMatching(ByRef CBMatchingGUI) { ; ByRef object generated at the GUI creation
  ;--------------------------------------------------------------------------------
    GuiControlGet, userInput,, % CBMatchingGUI.hEdit
    userInputArr := StrSplit(RTrim(userInput), " ")
    choicesList := CBMatchingGUI.parentCBList
    MatchCount := MatchList := MisMatchList := 0
    matchArr := {}
    ;--Find in list
    for k, v in userInputArr
    {
      If (InStr(choicesList, v))
        MatchList := True
      else
        MisMatchList := True
    }
    if (MatchList && !MisMatchList) {

      Loop, Parse, choicesList, "`n"
      {
        MatchString := MisMatchString := 0
        posArr := {}
        for k, v in userInputArr
        {
          If (FoundPos := InStr(A_LoopField, v))
          {
            MatchString := True
            posArr.Push(FoundPos)
          }
          else
            MisMatchString := True
        }
        If (MatchString && !MisMatchString)
        {
          For k, v in posArr
          {
            If (v = 1 && A_Index = 1)
              atStart := True
          }
          If !IndexOf(A_LoopField,matchArr)
          {
            If (atStart)
              MatchesAtStart .= "`n"A_LoopField
            else
              MatchesAnywhere .= "`n"A_LoopField
            MatchCount++
            matchArr.Push(A_LoopField)
          }
        }
        Else if (FoundPos := InStr(A_LoopField, userInput)) {
          if (FoundPos = 1)
            MatchesAtStart .= "`n"A_LoopField
          else
            MatchesAnywhere .= "`n"A_LoopField             
          MatchCount++
        } 
      }
      Matches := MatchesAtStart . MatchesAnywhere ; Ordered Match list
      GuiControl,, % CBMatchingGUI.hLB, %Matches%
      if (MatchCount = 1) {
        UniqueMatch := Matches
        GuiControl, ChooseString, % CBMatchingGUI.hLB, %UniqueMatch%
      } 
      else
        GuiControl, Choose, % CBMatchingGUI.hLB, 1
    } 
    else
      GuiControl,, % CBMatchingGUI.hLB, `n<! No Match !>
  }

  ;--------------------------------------------------------------------------------
  DestroyCBMatchingGUI() {
  ;--------------------------------------------------------------------------------
    Global CBMatchingGUI ; global object created with the CBMatchingGUI
    
    if (!WinActive("Ahk_id " CBMatchingGUI.hwnd) and WinExist("ahk_id " CBMatchingGUI.hwnd)) {
      Gui, % CBMatchingGUI.hwnd ":Destroy"
      SetTimer, DestroyCBMatchingGUI, Delete
    }
  }

  ;--------------------------------------------------------------------------------
  setCBMatchingGUILBChoice(CBMatchingGUI) {
  ;--------------------------------------------------------------------------------
    ; get ListBox choice
    GuiControlGet, LBMatchesSelectedChoice,, % CBMatchingGUI.hLB 
        
    ; set choice in parent ComboBox
    Control, ChooseString, %LBMatchesSelectedChoice%,,% "ahk_id "CBMatchingGUI.hParentCB
    ; set focus to Parent ComboBox, this will destroy matching GUI
    ControlFocus,, % "ahk_id "CBMatchingGUI.hParentCB

    ; execute next Tab_EnregFournisseursClients() step
    ; parentWinTitle := CBMatchingGUI.parentWindowTitle
    ; if (InStr(parentWinTitle, WinTitles.EnregFournisseurs)) {
    ;   ; Tab_EnregFournisseursClients("Fournisseurs")
    ; } 
    ; else if (InStr(parentWinTitle, WinTitles.EnregClients)) {
    ;   ; Tab_EnregFournisseursClients("Clients")
    ; }
  }
;--------------------------------------------------------------------------------





/* FindText - Capture screen image into text and then find it
 *  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834
 *
 *  Author  :  FeiYue
 *  Version :  7.3
 *  Date  :  2019-12-21
 *
 *  Usage:
 *  1. Capture the image to text string.
 *  2. Test find the text string on full Screen.
 *  3. When test is successful, you may copy the code
 *   and paste it into your own script.
 *   Note: Copy the "FindText()" function and the following
 *   functions and paste it into your own script Just once.
 *  4. The more recommended way is to save the script as
 *   "FindText.ahk" and copy it to the "Lib" subdirectory
 *   of AHK program, instead of copying the "FindText()"
 *   function and the following functions, add a line to
 *   the beginning of your script: #Include <FindText>
 *
 *  Note:
 *   After upgrading to v7.0, the search scope using
 *   the upper left  corner coordinates (X1, Y1)
 *   and lower right corner coordinates (X2, Y2), similar to ImageSearch.
 *   This makes it easier for novices to understand and use.
 *
 *===========================================
 *  Introduction of function parameters:
 *
 *  returnArray := FindText(
 *    X1 --> the search scope's upper left corner X coordinates
 *  , Y1 --> the search scope's upper left corner Y coordinates
 *  , X2 --> the search scope's lower right corner X coordinates
 *  , Y2 --> the search scope's lower right corner Y coordinates
 *  , err1 --> Fault tolerance percentage of text     (0.1=10%)
 *  , err0 --> Fault tolerance percentage of background (0.1=10%)
 *  , Text --> can be a lot of text parsed into images, separated by "|"
 *  , ScreenShot --> if the value is 0, the last screenshot will be used
 *  , FindAll --> if the value is 0, Just find one result and return
 *  , JoinText --> if the value is 1, Join all Text for combination lookup
 *  , offsetX --> Set the max text offset for combination lookup
 *  , offsetY --> Set the max text offset for combination lookup
 *  )
 *
 *  The function returns a second-order array containing
 *  all lookup results, Any result is an associative array
 *  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
 *  if no image is found, the function returns 0.
 *
 *  If the return variable is set to "ok", ok.1 is the first result found.
 *  Where ok.1.1 is the X coordinate of the upper left corner of the found image,
 *  and ok.1.2 is the Y coordinate of the upper left corner of the found image,
 *  ok.1.3 is the width of the found image, and ok.1.4 is the height of the found image,
 *  ok.1.x <==> ok.1.1+ok.1.3//2 ( is the Center X coordinate of the found image ),
 *  ok.1.y <==> ok.1.2+ok.1.4//2 ( is the Center Y coordinate of the found image ),
 *  ok.1.id is the comment text, which is included in the <> of its parameter.
 *  ok.1.x can also be written as ok[1].x, which supports variables. (eg: ok[A_Index].x)
 *
 *  All coordinates are relative to Screen, colors are in RGB format,
 *  and combination lookup must use uniform color mode
 *===========================================
 */


ft_Gui(cmd)
{
  static
  if (cmd="Show")
  {
  Gui, ft_Main:+LastFoundExist
  IfWinExist
  {
    Gui, ft_Main:Show, Center
    return
  }
  if (!ft_FuncBind1)
    ft_FuncBind1:=Func("ft_Gui").Bind("Show")
  #NoEnv
  if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
  {
    Menu, Tray, Tip, FindText GUI
    Menu, Tray, NoStandard
    Menu, Tray, Add, FindText, %ft_FuncBind1%
    Menu, Tray, Default, FindText
    Menu, Tray, Click, 1
    Menu, Tray, Icon, Shell32.dll, 23
    Menu, Tray, Add
    Menu, Tray, add, Window Spy, WINSPY
    Menu, Tray, Add
    Menu, Tray, add, Reload This Script, RELOAD  
    Menu, Tray, add
    Menu, Tray, add, Exit, QuitNow ; added exit script option
  }
  ft_BatchLines:=A_BatchLines
  ft_IsCritical:=A_IsCritical
  Critical
  ww:=35, hh:=16, WindowColor:="0xDDEEFF"
  ft_Gui("MakeCaptureWindow")
  ft_Gui("MakeSubPicWindow")
  ft_Gui("MakeMainWindow")
  OnMessage(0x100, Func("ft_EditEvents1"))  ; WM_KEYDOWN
  OnMessage(0x201, Func("ft_EditEvents2"))  ; WM_LBUTTONDOWN
  OnMessage(0x200, Func("ft_ShowToolTip"))  ; WM_MOUSEMOVE
  Gui, ft_Main:Show, Center
  GuiControl, Focus, capture
  Critical, %ft_IsCritical%
  SetBatchLines, %ft_BatchLines%
  return
  ;-------------------
  ft_Run:
  Critical
  ft_Gui(Trim(A_GuiControl))
  return
  }
  if (cmd="MakeCaptureWindow")
  {
  Gui, ft_Capture:New
  Gui, +AlwaysOnTop
  Gui, Margin, 15, 15
  Gui, Color, %WindowColor%
  Gui, Font, s12, Verdana
  Gui, Add, Text, xm w855 h315 +HwndhPic
  Gui, Add, Slider, ym h315 vMySlider2 gft_Run
    +Center Page20 Line20 NoTicks AltSubmit +Vertical
  Gui, Add, Slider, xm w855 vMySlider1 gft_Run
    +Center Page20 Line20 NoTicks AltSubmit
  GuiControlGet, Pic, Pos, %hPic%
  PicW:=Round(PicW), PicH:=Round(PicH), MySlider1:=MySlider2:=0
  Gui, Add, Button, xm+125 w50 vRepU  gft_Run, -U
  Gui, Add, Button, x+0  wp  vCutU  gft_Run, U
  Gui, Add, Button, x+0  wp  vCutU3 gft_Run, U3
  ;--------------
  Gui, Add, Text,   x+50 yp+3 Section, Gray
  Gui, Add, Edit,   x+3 yp-3 w60 vSelGray ReadOnly
  Gui, Add, Text,   x+15 ys, Color
  Gui, Add, Edit,   x+3 yp-3 w120 vSelColor ReadOnly
  Gui, Add, Text,   x+15 ys, R
  Gui, Add, Edit,   x+3 yp-3 w60 vSelR ReadOnly
  Gui, Add, Text,   x+5 ys, G
  Gui, Add, Edit,   x+3 yp-3 w60 vSelG ReadOnly
  Gui, Add, Text,   x+5 ys, B
  Gui, Add, Edit,   x+3 yp-3 w60 vSelB ReadOnly
  ;--------------
  Gui, Add, Button, xm   w50 vRepL  gft_Run, -L
  Gui, Add, Button, x+0  wp  vCutL  gft_Run, L
  Gui, Add, Button, x+0  wp  vCutL3 gft_Run, L3
  Gui, Add, Button, x+15   w70 vAuto  gft_Run, Auto
  Gui, Add, Button, x+15   w50 vRepR  gft_Run, -R
  Gui, Add, Button, x+0  wp  vCutR  gft_Run, R
  Gui, Add, Button, x+0  wp  vCutR3 gft_Run Section, R3
  Gui, Add, Button, xm+125 w50 vRepD  gft_Run, -D
  Gui, Add, Button, x+0  wp  vCutD  gft_Run, D
  Gui, Add, Button, x+0  wp  vCutD3 gft_Run, D3
  ;--------------
  Gui, Add, Tab3,   ys-8 -Wrap, Gray|GrayDiff|Color|ColorPos|ColorDiff
  Gui, Tab, 1
  Gui, Add, Text,   x+15 y+15, Gray Threshold
  Gui, Add, Edit,   x+15 w100 vThreshold
  Gui, Add, Button, x+15 yp-3 vGray2Two gft_Run, Gray2Two
  Gui, Tab, 2
  Gui, Add, Text,   x+15 y+15, Gray Difference
  Gui, Add, Edit,   x+15 w100 vGrayDiff, 50
  Gui, Add, Button, x+15 yp-3 vGrayDiff2Two gft_Run, GrayDiff2Two
  Gui, Tab, 3
  Gui, Add, Text,   x+15 y+15, Similarity 0
  Gui, Add, Slider, x+0 w100 vSimilar1 gft_Run
    +Center Page1 NoTicks ToolTip, 100
  Gui, Add, Text,   x+0, 100
  Gui, Add, Button, x+15 yp-3 vColor2Two gft_Run, Color2Two
  Gui, Tab, 4
  Gui, Add, Text,   x+15 y+15, Similarity 0
  Gui, Add, Slider, x+0 w100 vSimilar2 gft_Run
    +Center Page1 NoTicks ToolTip, 100
  Gui, Add, Text,   x+0, 100
  Gui, Add, Button, x+15 yp-3 vColorPos2Two gft_Run, ColorPos2Two
  Gui, Tab, 5
  Gui, Add, Text,   x+10 y+15, R
  Gui, Add, Edit,   x+2 w70 vDiffR Limit3
  Gui, Add, UpDown, vdR Range0-255
  Gui, Add, Text,   x+5, G
  Gui, Add, Edit,   x+2 w70 vDiffG Limit3
  Gui, Add, UpDown, vdG Range0-255
  Gui, Add, Text,   x+5, B
  Gui, Add, Edit,   x+2 w70 vDiffB Limit3
  Gui, Add, UpDown, vdB Range0-255
  Gui, Add, Button, x+5 yp-3 vColorDiff2Two gft_Run, ColorDiff2Two
  Gui, Tab
  ;--------------
  Gui, Add, Button, xm vReset gft_Run, Reset
  Gui, Add, Checkbox, x+15 yp+5 vModify gft_Run, Modify
  Gui, Add, Text,   x+30, Comment
  Gui, Add, Edit,   x+5 yp-2 w150 vComment
  ; Gui, Add, Button, x+30 yp-3 vSplitAdd gft_Run, SplitAdd
  Gui, Add, Button, x+30 yp-3 vAllAdd gft_Run, AllAdd
  Gui, Add, Button, x+10 w80 vButtonOK gft_Run, OK
  Gui, Add, Button, x+10 wp vClose gCancel, Close
  Gui, Add, Button, xm   vBind1 gft_Run, BindWindow
  Gui, Add, Button, x+15 vBind2 gft_Run, BindWindow+
  Gui, Show, Hide, Capture Image To Text
  return
  }
  if (cmd="MakeSubPicWindow")
  {
  Gui, ft_SubPic:New
  Gui, +AlwaysOnTop -Caption +ToolWindow +Parent%hPic%
  ; Gui, +AlwaysOnTop -Caption +ToolWindow -DPIScale +Parent%hPic%
  Gui, Margin, 0, 0
  Gui, Color, %WindowColor%
  Gui, -Theme
  nW:=2*ww+1, nH:=2*hh+1, C_:=[], w:=11
  Loop, % nW*(nH+1)
  {
    i:=A_Index, j:=i=1 ? "x0 y0" : Mod(i,nW)=1 ? "x0 y+1" : "x+1"
    j.=i>nW*nH ? " cRed BackgroundFFFFAA" : ""
    Gui, Add, Progress, w%w% h%w% %j% +Hwndid
    Control, ExStyle, -0x20000,, ahk_id %id%
    C_[i]:=id
  }
  Gui, +Theme
  GuiControlGet, SubPic, Pos, %id%
  SubPicW:=Round(SubPicX+SubPicW), SubPicH:=Round(SubPicY+SubPicH)
  Gui, Show, NA x0 y0 w%SubPicW% h%SubPicH%, SubPic
  i:=(SubPicW>PicW), j:=(SubPicH>PicH)
  Gui, ft_Capture:Default
  GuiControl, Enable%i%, MySlider1
  GuiControl, Enable%j%, MySlider2
  GuiControl,, MySlider1, % MySlider1:=0
  GuiControl,, MySlider2, % MySlider2:=0
  return
  }
  if (cmd="MakeMainWindow")
  {
  Gui, ft_Main:New
  Gui, +AlwaysOnTop
  ; Gui, +AlwaysOnTop -DPIScale
  Gui, Margin, 15, 15
  Gui, Color, %WindowColor%
  Gui, Font, s12 norm, Verdana
  Gui, Add, Checkbox, xm y+15 r1 -Wrap vAddFunc Checked
    , Add FindText() to Script
  Gui, Add, Button, x+20 yp-5 w240 vTestClip gft_Run, Test Clipboard
  Gui, Add, Button, x+0 w240 vCopyString gft_Run, Copy String



  Gui, Font, s6 bold, Verdana
  Gui, Add, Edit, xm w720 r25 vMyPic -Wrap
  Gui, Font, s12 norm, Verdana
  Gui, Add, Button, w240 vCapture gft_Run, Capture
  Gui, Add, Button, x+0 wp vCaptureS gft_Run, Capture from ScreenShot
  Gui, Add, Button, x+0 wp vTest gft_Run, Test Script

  Gui, Font, cBlack, Verdana
  Gui, Add, GroupBox, x+170 xm y+4 W240 h52 Section, Adjust Capture Box
  Gui, Font, s12 norm, Verdana
  Gui, Add, Text, xs+10 yp+22 h25, % "Width: "
  Gui, Add, Text, x+0 yp w47, %ww%
  Gui, Add, UpDown, vWidth Range1-110, %ww%
  Gui, Add, Text, x+5 yp h25, % "Height: "
  Gui, Add, Text, x+0 yp w40, %hh%
  Gui, Add, UpDown, vHeight Range1-40, %hh%

  Gui, Font, s12 cBlack, Verdana
  Gui, Add, GroupBox, x+10 ys W240 h52 Section, ScreenShot Key
  Gui, Font, s12 norm, Verdana
  Gui, Add, ListView
  , vlvar_SetHotkey1 r1 -Hdr -LV0x20 r1 w230 xs+5 ys+20  cGreen BackgroundFFFACD gft_LV_DblClick, 1|2
  LV_ModifyCol(1, 0)
  LV_ModifyCol(2, 225)
  Gui, Add, Button, x+5 yp-5 w240 vCopy gft_Run , Copy Script


  Gui, Font, s12 cBlue, Verdana
  Gui, Add, Edit, xm w720 h350 vscr Hwndhscr -Wrap HScroll
  Gui, Show, Hide, Capture Image To Text And Find Text Tool
  return
  }
  if (cmd="Update")
  {
  Gui, ft_Main:Default
  GuiControlGet, Width
  GuiControlGet, Height
  If (Width * Height > 2200)
  {
    MsgBox, 262144, Error Building Capture Menu, The area is too large, will crash the GUI creation`nMax Area is 110 x 20
    Exit
  }
  Gui, Hide
  If (Width != ww || Height != hh)
  {
    ToolTip, Building new Capture Box
    ww:=Width, hh:=Height, ft_Gui("MakeSubPicWindow")
    ToolTip
  }
  return
  }
  if (cmd="Capture") or (cmd="CaptureS")
  {
  ft_Gui("Update")
  Gui, ft_Main:Default
  Gui, +LastFound
  WinMinimize
  Gui, Hide
  ShowScreenShot:=(cmd="CaptureS")
  if (ShowScreenShot)
    ft_ShowScreenShot(1)
  ;----------------------
  Gui, ft_Mini:New
  Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x08000000
  ; Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
  Gui, Color, Red
  d:=2, w:=nW+2*d, h:=nH+2*d, i:=w-d, j:=h-d
  Gui, Show, Hide w%w% h%h%
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
  s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%
  ;------------------------------
  Hotkey, $*RButton, ft_RButton_Off, On
  lls:=A_ListLines=0 ? "Off" : "On"
  ListLines, Off
  CoordMode, Mouse
  KeyWait, RButton
  KeyWait, Ctrl
  oldx:=oldy:=""
  Loop
  {
    Sleep, 50
    MouseGetPos, x, y, Bind_ID
    if (oldx=x and oldy=y)
    Continue
    oldx:=x, oldy:=y
    ;---------------
    Gui, Show, % "NA x" (x-w//2) " y" (y-h//2)
    ToolTip, % "Mark the Position : " x "," y
    . "`nFirst: Press Ctrl, or RButton to mark area"
  }
  Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
  KeyWait, RButton
  KeyWait, Ctrl
  px:=x, py:=y, oldx:=oldy:=""
  Loop
  {
    Sleep, 50
    MouseGetPos, x, y
    if (oldx=x and oldy=y)
    Continue
    oldx:=x, oldy:=y
    ;---------------
    ToolTip, % "The Capture Position : " px "," py
    . "`nSecond: Press Ctrl, or RButton to capture"
  }
  Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P") 
  KeyWait, RButton
  KeyWait, Ctrl
  ToolTip
  ListLines, %lls%
  Gui, Destroy
  WinWaitClose,,, 10
  cors:=ft_getc(px,py,ww,hh,!ShowScreenShot)
  Hotkey, $*RButton, ft_RButton_Off, Off
  if (ShowScreenShot)
    ft_ShowScreenShot(0)
  ;--------------------------------
  Gui, ft_Capture:Default
  k:=nW*nH+1
  Loop, % nW
    GuiControl,, % C_[k++], 0
  Loop, 6
    GuiControl,, Edit%A_Index%
  GuiControl,, Modify, % Modify:=0
  GuiControl,, GrayDiff, 50
  GuiControl, Focus, Gray2Two
  GuiControl, +Default, Gray2Two
  ft_Gui("Reset")
  Gui, Show, Center
  Event:=Result:=""
  DetectHiddenWindows, Off
  Gui, +LastFound
  Critical, Off
  WinWaitClose, % "ahk_id " WinExist()
  Gui, ft_Main:Default
  ;--------------------------------
  if (cors.bind!="")
  {
    WinGetTitle, tt, ahk_id %Bind_ID%
    WinGetClass, tc, ahk_id %Bind_ID%
    tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
    tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
    Result:="`nSetTitleMatchMode, 2`nid:=WinExist(""" tt """)"
    . "`nBindWindow(id" (cors.bind ? ",1":"")
    . ")  `; Unbind Window using Bindwindow(0)`n`n" Result
  }
  if (Event="ButtonOK")
  {
    if (!A_IsCompiled)
    {
    FileRead, s, %A_LineFile%
    s:=SubStr(s, s~="i)\n[;=]+ Copy The")
    }
    else s:=""
    GuiControl,, scr, % Result "`n" s
    GuiControl,, MyPic, % Trim(ASCII(Result),"`n")
    Result:=s:=""
  }
  else if (Event="SplitAdd") or (Event="AllAdd")
  {
    GuiControlGet, s,, scr
    i:=j:=0, r:="\|<[^>\n]*>[^$\n]+\$\d+\.[\w+/]+"
    While j:=RegExMatch(s,r,"",j+1)
    i:=InStr(s,"`n",0,j)
    GuiControl,, scr, % SubStr(s,1,i-1) . "`n" . Result . SubStr(s,i+1)
    GuiControl,, MyPic, % Trim(ASCII(Result),"`n")
    Result:=s:=""
  }
  ;----------------------
  Gui, Show
  GuiControl, Focus, scr
  ft_RButton_Off:
  return
  }
  if (cmd="Bind1") or (cmd="Bind2")
  {
  BindWindow(Bind_ID, (cmd="Bind2"))
  Hotkey, $*RButton, ft_RButton_Off, On
  lls:=A_ListLines=0 ? "Off" : "On"
  ListLines, Off
  CoordMode, Mouse
  KeyWait, RButton
  KeyWait, Ctrl
  oldx:=oldy:=""
  Loop
  {
    Sleep, 50
    MouseGetPos, x, y
    if (oldx=x and oldy=y)
    Continue
    oldx:=x, oldy:=y
    ;---------------
    cors:=ft_getc(px:=x,py:=y,ww,hh)
    ft_Gui("Reset")
    ToolTip, % "The Capture Position : " x "," y
    . "`nPerspective binding window"
    . "`nRight click to finish capture"
  }
  Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
  KeyWait, RButton
  KeyWait, Ctrl
  ToolTip
  ListLines, %lls%
  Hotkey, $*RButton, ft_RButton_Off, Off
  BindWindow(0), cors.bind:=(cmd="Bind2")
  return
  }
  if (cmd="Test") or (cmd="TestClip")
  {
  Critical, Off
  Gui, ft_Main:Default
  Gui, +LastFound
  WinMinimize
  Gui, Hide
  DetectHiddenWindows, Off
  WinWaitClose, % "ahk_id " WinExist()
  Sleep, 100
  ;----------------------
  if (cmd="Test")
    GuiControlGet, s,, scr
  if (!A_IsCompiled) and InStr(s,"MCode(") and (cmd="Test")
  {
    s:="`n#NoEnv`nMenu, Tray, Click, 1`n"
    . "Gui, ft_ok_:Show, Hide, ft_ok_`n"
    . s "`nExitApp`n"
    ft_Exec(s)
    DetectHiddenWindows, On
    WinWait, ft_ok_ ahk_class AutoHotkeyGUI,, 3
    if (!ErrorLevel)
    WinWaitClose,,, 30
  }
  else
  {
    Gui, +OwnDialogs
    t:=CoolTime(), n:=150000
    if (cmd="TestClip")
    v := Clipboard
    Else
    RegExMatch(s,"\|<[^>\n]*>[^$\n]+\$\d+\.[\w+/]+",v)
    ok:=FindText(-n, -n, n, n, 0, 0, v)
    , X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    MsgBox, 4096,Test Results, % "Found :`t" Round(ok.MaxIndex()) "`n`n"
    . "Time  :`t" (A_TickCount-t) " ms`n`n"
    . "Pos   :`t"  X ", " Y "`n`n"
    . "Result:`t" (ok ? "Success ! " Comment : "Failed !"), 3
    for i,v in ok
    if (i<=5)
      MouseTip(ok[i].x, ok[i].y)
    ok:=""
  }
  ;----------------------
  Gui, Show
  GuiControl, Focus, scr
  return
  }
  if (cmd="Copy") or (cmd="CopyString")
  {
  Gui, ft_Main:Default
  ControlGet, s, Selected,,, ahk_id %hscr%
  if (s="")
  {
    GuiControlGet, s,, scr
    GuiControlGet, r,, AddFunc
    if (r != 1)
    s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
  }
  If (cmd="Copy")
    Clipboard:=RegExReplace(s,"\R","`r`n")
  Else if (cmd="CopyString")
    Clipboard:= """" copyString """"

  ;----------------------
  ; if !(!A_IsCompiled and A_LineFile=A_ScriptFullPath)
  ; {
  ;   Gui, Hide
  ;   Gui, 1: Default
  ;   Hotkeys()
  ; }
  return
  }
  if (cmd="MySlider1") or (cmd="MySlider2")
  {
  x:=SubPicW>PicW ? -(SubPicW-PicW)*MySlider1//100 : 0
  y:=SubPicH>PicH ? -(SubPicH-PicH)*MySlider2//100 : 0
  Gui, ft_SubPic:Show, NA x%x% y%y%
  return
  }
  if (cmd="Reset")
  {
  if !IsObject(ascii)
    ascii:=[], gray:=[], show:=[]
  CutLeft:=CutRight:=CutUp:=CutDown:=k:=0, bg:=""
  Loop, % nW*nH
  {
    show[++k]:=1, c:=cors[k]
    gray[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    ft_Gui("SetColor")
  }
  Loop, % cors.CutLeft
    ft_Gui("CutL")
  Loop, % cors.CutRight
    ft_Gui("CutR")
  Loop, % cors.CutUp
    ft_Gui("CutU")
  Loop, % cors.CutDown
    ft_Gui("CutD")
  return
  }
  if (cmd="SetColor")
  {
  c:=c="Black" ? 0x000000 : c="White" ? 0xFFFFFF
    : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
  SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
  return
  }
  if (cmd="RepColor")
  {
  show[k]:=1, c:=(bg="" ? cors[k] : ascii[k]
    ? "Black":"White"), ft_Gui("SetColor")
  return
  }
  if (cmd="CutColor")
  {
  show[k]:=0, c:=WindowColor, ft_Gui("SetColor")
  return
  }
  if (cmd="RepL")
  {
  if (CutLeft<=cors.CutLeft)
  or (bg!="" and InStr(color,"**")
  and CutLeft=cors.CutLeft+1)
    return
  k:=CutLeft-nW, CutLeft--
  Loop, %nH%
    k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
    ? ft_Gui("RepColor") : "")
  return
  }
  if (cmd="CutL")
  {
  if (CutLeft+CutRight>=nW)
    return
  CutLeft++, k:=CutLeft-nW
  Loop, %nH%
    k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
    ? ft_Gui("CutColor") : "")
  return
  }
  if (cmd="CutL3")
  {
  Loop, 3
    ft_Gui("CutL")
  return
  }
  if (cmd="RepR")
  {
  if (CutRight<=cors.CutRight)
  or (bg!="" and InStr(color,"**")
  and CutRight=cors.CutRight+1)
    return
  k:=1-CutRight, CutRight--
  Loop, %nH%
    k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
    ? ft_Gui("RepColor") : "")
  return
  }
  if (cmd="CutR")
  {
  if (CutLeft+CutRight>=nW)
    return
  CutRight++, k:=1-CutRight
  Loop, %nH%
    k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
    ? ft_Gui("CutColor") : "")
  return
  }
  if (cmd="CutR3")
  {
  Loop, 3
    ft_Gui("CutR")
  return
  }
  if (cmd="RepU")
  {
  if (CutUp<=cors.CutUp)
  or (bg!="" and InStr(color,"**")
  and CutUp=cors.CutUp+1)
    return
  k:=(CutUp-1)*nW, CutUp--
  Loop, %nW%
    k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
    ? ft_Gui("RepColor") : "")
  return
  }
  if (cmd="CutU")
  {
  if (CutUp+CutDown>=nH)
    return
  CutUp++, k:=(CutUp-1)*nW
  Loop, %nW%
    k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
    ? ft_Gui("CutColor") : "")
  return
  }
  if (cmd="CutU3")
  {
  Loop, 3
    ft_Gui("CutU")
  return
  }
  if (cmd="RepD")
  {
  if (CutDown<=cors.CutDown)
  or (bg!="" and InStr(color,"**")
  and CutDown=cors.CutDown+1)
    return
  k:=(nH-CutDown)*nW, CutDown--
  Loop, %nW%
    k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
    ? ft_Gui("RepColor") : "")
  return
  }
  if (cmd="CutD")
  {
  if (CutUp+CutDown>=nH)
    return
  CutDown++, k:=(nH-CutDown)*nW
  Loop, %nW%
    k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
    ? ft_Gui("CutColor") : "")
  return
  }
  if (cmd="CutD3")
  {
  Loop, 3
    ft_Gui("CutD")
  return
  }
  if (cmd="Gray2Two")
  {
  Gui, ft_Capture:Default
  GuiControl, Focus, Threshold
  GuiControlGet, Threshold
  if (Threshold="")
  {
    pp:=[]
    Loop, 256
    pp[A_Index-1]:=0
    Loop, % nW*nH
    if (show[A_Index])
      pp[gray[A_Index]]++
    IP:=IS:=0
    Loop, 256
    k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
    Threshold:=Floor(IP/IS)
    Loop, 20
    {
    LastThreshold:=Threshold
    IP1:=IS1:=0
    Loop, % LastThreshold+1
      k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
    IP2:=IP-IP1, IS2:=IS-IS1
    if (IS1!=0 and IS2!=0)
      Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
    if (Threshold=LastThreshold)
      Break
    }
    GuiControl,, Threshold, %Threshold%
  }
  Threshold:=Round(Threshold)
  color:="*" Threshold, k:=i:=0
  Loop, % nW*nH
  {
    ascii[++k]:=v:=(gray[k]<=Threshold)
    if (show[k])
    i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
  }
  bg:=i>0 ? "1":"0"
  return
  }
  if (cmd="GrayDiff2Two")
  {
  Gui, ft_Capture:Default
  GuiControlGet, GrayDiff
  if (GrayDiff="")
  {
    Gui, +OwnDialogs
    MsgBox, 4096, Tip, `n  Please Set Gray Difference First !  `n, 1
    return
  }
  if (CutLeft=cors.CutLeft)
    ft_Gui("CutL")
  if (CutRight=cors.CutRight)
    ft_Gui("CutR")
  if (CutUp=cors.CutUp)
    ft_Gui("CutU")
  if (CutDown=cors.CutDown)
    ft_Gui("CutD")
  GrayDiff:=Round(GrayDiff)
  color:="**" GrayDiff, k:=i:=0
  Loop, % nW*nH
  {
    j:=gray[++k]+GrayDiff
    , ascii[k]:=v:=( gray[k-1]>j or gray[k+1]>j
    or gray[k-nW]>j or gray[k+nW]>j
    or gray[k-nW-1]>j or gray[k-nW+1]>j
    or gray[k+nW-1]>j or gray[k+nW+1]>j )
    if (show[k])
    i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
  }
  bg:=i>0 ? "1":"0"
  return
  }
  if (cmd="Color2Two") or (cmd="ColorPos2Two")
  {
  Gui, ft_Capture:Default
  GuiControlGet, c,, SelColor
  if (c="")
  {
    Gui, +OwnDialogs
    MsgBox, 4096, Tip, `n  Please Select a Color First !  `n, 1
    return
  }
  UsePos:=(cmd="ColorPos2Two") ? 1:0
  GuiControlGet, n,, Similar1
  n:=Round(n/100,2), color:=c "@" n
  , n:=Floor(9*255*255*(1-n)*(1-n)), k:=i:=0
  , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
  Loop, % nW*nH
  {
    c:=cors[++k], r:=((c>>16)&0xFF)-rr
    , g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
    , ascii[k]:=v:=(3*r*r+4*g*g+2*b*b<=n)
    if (show[k])
    i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
  }
  bg:=i>0 ? "1":"0"
  return
  }
  if (cmd="ColorDiff2Two")
  {
  Gui, ft_Capture:Default
  GuiControlGet, c,, SelColor
  if (c="")
  {
    Gui, +OwnDialogs
    MsgBox, 4096, Tip, `n  Please Select a Color First !  `n, 1
    return
  }
  GuiControlGet, dR
  GuiControlGet, dG
  GuiControlGet, dB
  rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
  , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
  , color:=StrReplace(c "-" n,"0x"), k:=i:=0
  Loop, % nW*nH
  {
    c:=cors[++k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF
    , b:=c&0xFF, ascii[k]:=v:=(Abs(r-rr)<=dR
    and Abs(g-gg)<=dG and Abs(b-bb)<=dB)
    if (show[k])
    i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
  }
  bg:=i>0 ? "1":"0"
  return
  }
  if (cmd="Modify")
  {
  GuiControlGet, Modify, ft_Capture:, Modify
  return
  }
  if (cmd="Similar1")
  {
  GuiControl, ft_Capture:, Similar2, %Similar1%
  return
  }
  if (cmd="Similar2")
  {
  GuiControl, ft_Capture:, Similar1, %Similar2%
  return
  }
  if (cmd="getwz")
  {
  wz:=""
  if (bg="")
    return
  k:=0
  Loop, %nH%
  {
    v:=""
    Loop, %nW%
    v.=!show[++k] ? "" : ascii[k] ? "1":"0"
    wz.=v="" ? "" : v "`n"
  }
  return
  }
  if (cmd="Auto")
  {
  ft_Gui("getwz")
  if (wz="")
  {
    Gui, ft_Capture:+OwnDialogs
    MsgBox, 4096, Tip, `nPlease Click Color2Two or Gray2Two First !, 1
    return
  }
  While InStr(wz,bg)
  {
    if (wz~="^" bg "+\n")
    wz:=RegExReplace(wz,"^" bg "+\n"), ft_Gui("CutU")
    else if !(wz~="m`n)[^\n" bg "]$")
    wz:=RegExReplace(wz,"m`n)" bg "$"), ft_Gui("CutR")
    else if (wz~="\n" bg "+\n$")
    wz:=RegExReplace(wz,"\n\K" bg "+\n$"), ft_Gui("CutD")
    else if !(wz~="m`n)^[^\n" bg "]")
    wz:=RegExReplace(wz,"m`n)^" bg), ft_Gui("CutL")
    else Break
  }
  wz:=""
  return
  }
  if (cmd="ButtonOK") or (cmd="SplitAdd") or (cmd="AllAdd")
  {
  Gui, ft_Capture:Default
  Gui, +OwnDialogs
  ft_Gui("getwz")
  if (wz="")
  {
    MsgBox, 4096, Tip, `nPlease Click Color2Two or Gray2Two First !, 1
    return
  }
  if InStr(color,"@") and (UsePos)
  {
    StringSplit, r, color, @
    k:=i:=j:=0
    Loop, % nW*nH
    {
    if (!show[++k])
      Continue
    i++
    if (k=cors.SelPos)
    {
      j:=i
      Break
    }
    }
    if (j=0)
    {
    MsgBox, 4096, Tip, Please select the core color again !, 3
    return
    }
    color:="#" (j-1) "@" r2
  }
  GuiControlGet, Comment
  if (cmd="SplitAdd")
  {
    if InStr(color,"#")
    {
    MsgBox, 4096, Tip
      , % "Can't be used in ColorPos mode, "
      . "because it can cause position errors", 3
    return
    }
    SetFormat, IntegerFast, d
    bg:=StrLen(StrReplace(wz,"0"))
    > StrLen(StrReplace(wz,"1")) ? "1":"0"
    s:="", i:=0, k:=nW*nH+1+CutLeft
    Loop, % w:=nW-CutLeft-CutRight
    {
    i++
    GuiControlGet, j,, % C_[k++]
    if (j=0 and A_Index<w)
      Continue
    v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
    wz:=RegExReplace(wz,"m`n)^.{" i "}"), i:=0
    While InStr(v,bg)
    {
      if (v~="^" bg "+\n")
      v:=RegExReplace(v,"^" bg "+\n")
      else if !(v~="m`n)[^\n" bg "]$")
      v:=RegExReplace(v,"m`n)" bg "$")
      else if (v~="\n" bg "+\n$")
      v:=RegExReplace(v,"\n\K" bg "+\n$")
      else if !(v~="m`n)^[^\n" bg "]")
      v:=RegExReplace(v,"m`n)^" bg)
      else Break
    }
    if (v!="")
    {
      v:=Format("{:d}",InStr(v,"`n")-1) "." bit2base64(v)
      s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
      copyString.="|<" SubStr(Comment,1,1) ">" color "$" v
      Comment:=SubStr(Comment, 2)
    }
    }
    Event:=cmd, Result:=s
    Gui, Hide
    return
  }
  wz:=Format("{:d}",InStr(wz,"`n")-1) "." bit2base64(wz)
  s:="`nText.=""|<" Comment ">" color "$" wz """`n"
  if (cmd="AllAdd")
  {
    Event:=cmd, Result:=s
    copyString.="|<" Comment ">" color "$" wz
    Gui, Hide
    return
  }
  x:=(bx:=(px-ww+CutLeft))+(bw:=(nW-CutLeft-CutRight))//2
  y:=(by:=(py-hh+CutUp))+(bh:=(nH-CutUp-CutDown))//2
  bx2:=bx+bw, by2:=by+bh
  s:=StrReplace(s, "Text.=", "Text:=")
  If !MonN
  ft_Gui("Edges")
  ldif := Abs(EdgeL - bx), tdif := Abs(EdgeT - by)
  rdif := Abs(EdgeR - bx2), bdif := Abs(EdgeB - by2)
  s=
  (
t1:=A_TickCount
%s%
`;X1,Y1,X2,Y2 are adjusted to screen edges
if (ok:=FindText(%bx%-%ldif%, %by%-%tdif%, %bx2%+%rdif%, %by2%+%bdif%, 0, 0, Text))
{
  CoordMode, Mouse
  X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
  ; Click, `%X`%, `%Y`%
}

MsgBox, 4096,Test Results, `% "Found :``t" Round(ok.MaxIndex()) "``n``n"
  . "Time  :``t" (A_TickCount-t1) " ms``n``n"
  . "Pos   :``t" X ", " Y "``n``n"
  . "Result:``t" (ok ? "Success ! " Comment : "Failed !")

for i,v in ok
  if (i<=5)
  MouseTip(ok[i].x, ok[i].y)

)
  Event:=cmd, Result:=s, copyString:="|<" Comment ">" color "$" wz
  Gui, Hide
  return
  }
  if (cmd="ShowPic")
  {
  Critical
  ControlGet, i, CurrentLine,,, ahk_id %hscr%
  ControlGet, s, Line, %i%,, ahk_id %hscr%
  GuiControl, ft_Main:, MyPic, % Trim(ASCII(s),"`n")
  return
  }
  if (cmd="WM_LBUTTONDOWN")
  {
  Critical
  MouseGetPos,,,, j
  IfNotInString, j, progress
    return
  MouseGetPos,,,, j, 2
  Gui, ft_Capture:Default
  For k,v in C_
  {
    if (v!=j)
    Continue
    if (k>nW*nH)
    {
    GuiControlGet, i,, %v%
    GuiControl,, %v%, % i ? 0:100
    }
    else if (Modify and bg!="" and show[k])
    {
    ascii[k]:=!ascii[k]
    , c:=(ascii[k] ? "Black":"White")
    , ft_Gui("SetColor")
    }
    else
    {
    c:=cors[k], cors.SelPos:=k
    r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
    GuiControl,, SelGray, % gray[k]
    GuiControl,, SelColor, %c%
    GuiControl,, SelR, %r%
    GuiControl,, SelG, %g%
    GuiControl,, SelB, %b%
    }
    Break
  }
  return
  }
  if (cmd="Apply")
  {
  if (!ft_FuncBind2)
    ft_FuncBind2:=Func("ft_Gui").Bind("ScreenShot")
  Gui, ft_Main:Default
  GuiControlGet, NowHotkey
  Gui, ListView, lvar_SetHotkey1
  LV_GetText(SetHotkey1, 1, 2)
  Hotkey, IfWinActive
  if (NowHotkey!="")
    Hotkey, *%NowHotkey%,, Off UseErrorLevel
  GuiControl,, NowHotkey, %SetHotkey1%
  if (SetHotkey1!="")
    Hotkey, *%SetHotkey1%, %ft_FuncBind2%, On UseErrorLevel
  return

  ;Label for assigning hotkeys
  ft_LV_DblClick:
    If a_guicontrolevent != DoubleClick
      return
    Gui, ft_Main:Default
    ; varstr := StrSplit(Trim(A_GuiControl),"lvar_")[2]
    if (!ft_FuncBind2)
      ft_FuncBind2:=Func("ft_Gui").Bind("ScreenShot")
    Gui, ListView, %a_guicontrol%
    LV_GetText(old, 1, 2)
    Hotkey, IfWinActive
    if (old!="")
      Hotkey, %old%,, Off UseErrorLevel
    LV_Delete(1)
    LV_Add("","",newHK:=Hotkey("+Default1 -LR -Symbols +Tooltips","Hold down your key combination","      Submit to bind  Cancel to clear","Select Screenshot Hotkey"))
    ; %varstr% := newHK
    Hotkey, IfWinActive
    if (newHK!="")
      Hotkey, %newHK%, %ft_FuncBind2%, On UseErrorLevel
  return
  }
  if (cmd="ScreenShot")
  {
  Critical
  ScreenShot()
  Gui, ft_Tip:New
  ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
  Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption +E0x08000020
  ; Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000020
  Gui, Color, Yellow
  Gui, Font, cRed s48 bold
  Gui, Add, Text,, Success
  WinSet, Transparent, 200
  Gui, Show, NA y0, ScreenShot Tip
  Sleep, 1000
  Gui, Destroy
  return
  }
  If (cmd="Edges")
  {
  EdgeL:=EdgeT:=EdgeR:=EdgeB:=0
  SysGet, MonN, 80
  loop, %MonN%
  {
    SysGet, Mon%A_Index%, Monitor, %A_Index%
    EdgeL := (Mon%A_Index%Left < EdgeL ? Mon%A_Index%Left : EdgeL ), EdgeR := (Mon%A_Index%Right > EdgeR ? Mon%A_Index%Right : EdgeR )
    EdgeT := (Mon%A_Index%Top < EdgeT ? Mon%A_Index%Top : EdgeT ), EdgeB := (Mon%A_Index%Bottom > EdgeB ? Mon%A_Index%Bottom : EdgeB )
  }
  Return
  }

  ft_MainGuiClose:
  ft_MainGuiEscape:
  ExitApp
}

  ft_Load_ToolTip_Text()
  {
    s=
    (LTrim
    Update = Update the capture range by adjusting the numbers
    AddFunc = Additional FindText() in Copy
    lvar_SetHotkey1 = Currently assigned screenshot hotkey`rDouble click to assign new key
    Apply = Clear old screenshot hotkey and apply a new hotkey`rHotkey assigned by priority from First to Second
    TestClip = Test the Text data in the clipboard for searching images
    Capture = Initiate Image Capture Sequence`rWill rebuild capture box if adjusted
    CaptureS = Restore the last screenshot and then start capturing`rWill rebuild capture box if adjusted
    Test = Test Results of Code
    Copy = Copy Script Code to Clipboard`rUse this to make your own scripts
    CopyString = Copy String Code to Clipboard`rUse this for Wingman Strings
    Width = Change the width value to scale the capture box`rWidth ends up being 1 + Width * 2
    Height = Change the height value to scale the capture box`rHeight ends up being 1 + Height * 2
    --------------------
    Reset = Reset to Original Captured Image
    SplitAdd = Using Markup Segmentation to Generate Text Library
    AllAdd = Append Another FindText Search Text into Previously Generated Code
    ButtonOK = Create New FindText Code for Testing
    Close = Close the Window Don't Do Anything
    Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
    GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
    Color2Two = Converts Image Pixels from Color Similar to Black or White
    ColorPos2Two = Converts Image Pixels from Color Position to Black or White
    ColorDiff2Two = Converts Image Pixels from Color Difference to Black or White
    SelGray = Gray value of the selected color
    SelColor = The selected color
    SelR = Red component of the selected color
    SelG = Green component of the selected color
    SelB = Blue component of the selected color
    RepU = Undo Cut the Upper Edge by 1
    CutU = Cut the Upper Edge by 1
    CutU3 = Cut the Upper Edge by 3
    RepL = Undo Cut the Left Edge by 1
    CutL = Cut the Left Edge by 1
    CutL3 = Cut the Left Edge by 3
    Auto = Automatic Cutting Edge
    RepR = Undo Cut the Right Edge by 1
    CutR = Cut the Right Edge by 1
    CutR3 = Cut the Right Edge by 3
    RepD = Undo Cut the Lower Edge by 1
    CutD = Cut the Lower Edge by 1
    CutD3 = Cut the Lower Edge by 3
    Modify = Allows Modify the Black and White Image
    Comment = Optional Comment used to Label Code ( Within <> )
    Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
    GrayDiff = Gray Difference which Determines Black or White Pixel Conversion (0-255)
    Similar1 = Adjust color similarity as Equivalent to The Selected Color
    Similar2 = Adjust color similarity as Equivalent to The Selected Color
    DiffR = Red Difference which Determines Black or White Pixel Conversion (0-255)
    DiffG = Green Difference which Determines Black or White Pixel Conversion (0-255)
    DiffB = Blue Difference which Determines Black or White Pixel Conversion (0-255)
    Bind1 = Bind the window so that it can find images when obscured by other windows
    Bind2 = Modify the window to support transparency and then bind the window
    )
    return, s
  }

  ft_EditEvents1()
  {
    static ft_FuncBind3:=Func("ft_Gui").Bind("ShowPic")
    ListLines, Off
    if (A_Gui="ft_Main" && A_GuiControl="scr")
      SetTimer, %ft_FuncBind3%, -150
  }

  ft_EditEvents2()
  {
    ListLines, Off
    if (A_Gui="ft_SubPic")
      ft_Gui("WM_LBUTTONDOWN")
    else
      ft_EditEvents1()
  }

  ft_ShowToolTip(cmd:="")
  {
    static
    ListLines, Off
    if (!ToolTip_Text)
      ToolTip_Text:=ft_Load_ToolTip_Text()
    if (!ft_FuncBind4)
      ft_FuncBind4:=Func("ft_ShowToolTip").Bind("ToolTip")
    if (!ft_FuncBind5)
      ft_FuncBind5:=Func("ft_ShowToolTip").Bind("ToolTipOff")
    if (cmd="ToolTip")
    {
      MouseGetPos,,, _TT
      WinGetClass, _TT, ahk_id %_TT%
      if (_TT = "AutoHotkeyGUI")
      ToolTip, % RegExMatch(ToolTip_Text
      , "im`n)^" CurrControl "\K\s*=.*", _TT)
      ? StrReplace(Trim(_TT,"`t ="),"\n","`n") : ""
      return
    }
    if (cmd="ToolTipOff")
    {
      ToolTip
      return
    }
    CurrControl:=A_GuiControl
    if (CurrControl!=PrevControl)
    {
      PrevControl:=CurrControl, _TT:=(CurrControl!="")
      SetTimer, %ft_FuncBind4%, % _TT ? -500  : "Off"
      SetTimer, %ft_FuncBind5%, % _TT ? -5500 : "Off"
      ToolTip
    }
  }

  ft_getc(px, py, ww, hh, ScreenShot:=1)
  {
      xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
    if (w<1 or h<1)
      return
    bch:=A_BatchLines
    SetBatchLines, -1
    if (ScreenShot)
      ScreenShot()
    cors:=[], k:=0
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, % 2*hh+1
    {
      j:=py-hh+A_Index-1
      Loop, % 2*ww+1
        i:=px-ww+A_Index-1, cors[++k]:=ScreenShot_GetColor(i,j)
    }
    ListLines, %lls%
    cors.CutLeft:=Abs(px-ww-x)
    cors.CutRight:=Abs(px+ww-(x+w-1))
    cors.CutUp:=Abs(py-hh-y)
    cors.CutDown:=Abs(py+hh-(y+h-1))
    SetBatchLines, %bch%
    return, cors
  }

  ft_ShowScreenShot(Show:=1) {
    local  ; Unaffected by Super-global variables
    static hBM, Ptr:=A_PtrSize ? "UPtr" : "UInt"
    Gui, ft_ScreenShot:Destroy
    if (hBM)
      DllCall("DeleteObject",Ptr,hBM), hBM:=""
      bits:=GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
      if (!Show or !bits.1 or zw<1 or zh<1)
      return
    ;---------------------
    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
    NumPut(zw, bi, 4, "int"), NumPut(-zh, bi, 8, "int")
    NumPut(1, bi, 12, "short"), NumPut(bpp:=32, bi, 14, "short")
    if (hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
      , "int",0, Ptr "*",ppvBits, Ptr,0, "int",0, Ptr))
      DllCall("RtlMoveMemory",Ptr,ppvBits,Ptr,bits.1,Ptr,bits.2*zh)
    ;-------------------------
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    hBrush:=DllCall("CreateSolidBrush", "uint",0xFFFFFF, Ptr)
    oBrush:=DllCall("SelectObject", Ptr,mDC, Ptr,hBrush, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",zw, "int",zh
      , Ptr,mDC, "int",0, "int",0, "uint",0xC000CA)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBrush)
    DllCall("DeleteObject", Ptr,hBrush)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteDC", Ptr,mDC)
    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
    ;-------------------------
    Gui, ft_ScreenShot:+AlwaysOnTop -Caption +ToolWindow +E0x08000000
    ; Gui, ft_ScreenShot:+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
    Gui, ft_ScreenShot:Margin, 0, 0
    Gui, ft_ScreenShot:Add, Picture, x0 y0 w%zw% h%zh% +HwndhPic +0xE
    SendMessage, 0x172, 0, hBM,, ahk_id %hPic%
    Gui, ft_ScreenShot:Show, NA x%zx% y%zy% w%zw% h%zh%, Show ScreenShot
  }

  ft_Exec(s)
  {
    Ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
    s:=RegExReplace(s, "\R", "`r`n")
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec(Ahk " /f /ErrorStdOut *")
      oExec.StdIn.Write(s)
      oExec.StdIn.Close()
    }
    catch
    {
      f:=A_Temp "\~test1.tmp"
      s:="`r`n FileDelete, " f "`r`n" s
      FileDelete, %f%
      FileAppend, %s%, %f%
      Run, %Ahk% /f "%f%",, UseErrorLevel
    }
  }


;===== Copy The Following Functions To Your Own Code Just once =====
;=============== FindText Library Start ===================

  ;--------------------------------
  ; FindText - Capture screen image into text and then find it
  ;--------------------------------
  ; X1, Y1 --> the search scope's upper left corner coordinates
  ; X2, Y2 --> the search scope's lower right corner coordinates
  ; err1, err0 --> Fault tolerance percentage of text and background (0.1=10%)
  ; Text --> can be a lot of text parsed into images, separated by "|"
  ; ScreenShot --> if the value is 0, the last screenshot will be used
  ; FindAll --> if the value is 0, Just find one result and return
  ; JoinText --> if the value is 1, Join all Text for combination lookup
  ; offsetX, offsetY --> Set the Max text offset for combination lookup
  ; ruturn --> the function returns a second-order array
  ; containing all lookup results, Any result is an associative array
  ; {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment},
  ; if no image is found, the function returns 0.
  ; All coordinates are relative to Screen, colors are in RGB format,
  ; and combination lookup must use uniform color mode
  ;--------------------------------

  FindText( x1, y1, x2, y2, err1, err0, text, ScreenShot:=1
  , FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10 )
  {
    local  ; Unaffected by Super-global variables
    bch:=A_BatchLines
    SetBatchLines, -1
    x:=(x1<x2 ? x1:x2), y:=(y1<y2 ? y1:y2)
    , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
    , xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
    if (w<1 or h<1)
    {
      SetBatchLines, %bch%
      return, 0
    }
    bits:=GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
    sx:=x-zx, sy:=y-zy, sw:=w, sh:=h, arr:=[], info:=[]
    Loop, Parse, text, |
      if IsObject(j:=PicInfo(A_LoopField))
      info.Push(j)
    if (!(num:=info.MaxIndex()) or !bits.1)
    {
      SetBatchLines, %bch%
      return, 0
    }
    VarSetCapacity(input, num*7*4), k:=0
    Loop, % num
      k+=Round(info[A_Index].2 * info[A_Index].3)
    VarSetCapacity(s1, k*4), VarSetCapacity(s0, k*4)
    , VarSetCapacity(gs, sw*sh), VarSetCapacity(ss, sw*sh)
    , allpos_max:=(FindAll ? 1024 : 1)
    , VarSetCapacity(allpos, allpos_max*4)
    Loop, 2
    {
      if (err1=0 and err0=0) and (num>1 or A_Index>1)
      err1:=0.1, err0:=0.05
      if (JoinText)
      {
      j:=info[1], mode:=j.8, color:=j.9, n:=j.10
      , w1:=-1, h1:=j.3, comment:="", v:="", i:=0
      Loop, % num
      {
        j:=info[A_Index], w1+=j.2+1, comment.=j.11
        Loop, 7
        NumPut((A_Index=1 ? StrLen(v)
        : A_Index=6 and err1 and !j.12 ? Round(j.4*err1)
        : A_Index=7 and err0 and !j.12 ? Round(j.5*err0)
        : j[A_Index]), input, 4*(i++), "int")
        v.=j.1
      }
      ok:=PicFind( mode,color,n,offsetX,offsetY
      , bits,sx,sy,sw,sh,gs,ss,v,s1,s0
      , input,num*7,allpos,allpos_max )
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
        , arr.Push( {1:rx, 2:ry, 3:w1, 4:h1
        , x:rx+w1//2, y:ry+h1//2, id:comment} )
      }
      else
      {
      For i,j in info
      {
        mode:=j.8, color:=j.9, n:=j.10, comment:=j.11
        , w1:=j.2, h1:=j.3, v:=j.1
        Loop, 7
        NumPut((A_Index=1 ? 0
        : A_Index=6 and err1 and !j.12 ? Round(j.4*err1)
        : A_Index=7 and err0 and !j.12 ? Round(j.5*err0)
        : j[A_Index]), input, 4*(A_Index-1), "int")
        ok:=PicFind( mode,color,n,offsetX,offsetY
        , bits,sx,sy,sw,sh,gs,ss,v,s1,s0
        , input,7,allpos,allpos_max )
        Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
        , arr.Push( {1:rx, 2:ry, 3:w1, 4:h1
        , x:rx+w1//2, y:ry+h1//2, id:comment} )
        if (ok and !FindAll)
        Break
      }
      }
      if (err1=0 and err0=0 and num=1 and !arr.MaxIndex())
      {
      k:=0
      For i,j in info
        k+=(!j.12)
      IfEqual, k, 0, Break
      }
      else Break
    }
    SetBatchLines, %bch%
    return, arr.MaxIndex() ? arr:0
  }

  ; Bind the window so that it can find images when obscured
  ; by other windows, it's equivalent to always being
  ; at the front desk. Unbind Window using Bindwindow(0)
  
  BindWindow(window_id:=0, set_exstyle:=0, get:=0)
  {
    static id, old, Ptr:=A_PtrSize ? "UPtr" : "UInt"
    if (get)
    return, id
    if (window_id)
    {
    id:=window_id, old:=0
    if (set_exstyle)
    {
      WinGet, old, ExStyle, ahk_id %id%
      WinSet, Transparent, 255, ahk_id %id%
      Loop, 30
      {
      Sleep, 100
      WinGet, i, Transparent, ahk_id %id%
      }
      Until (i=255)
    }
    }
    else
    {
    if (old)
      WinSet, ExStyle, %old%, ahk_id %id%
    id:=old:=0
    }
  }

  xywh2xywh(x1,y1,w1,h1, ByRef x,ByRef y,ByRef w,ByRef h
    , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
  {
    SysGet, zx, 76
    SysGet, zy, 77
    SysGet, zw, 78
    SysGet, zh, 79
    left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
    left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
    up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
    x:=left, y:=up, w:=right-left+1, h:=down-up+1
  }

  GetBitsFromScreen(x, y, w, h, ScreenShot:=1
    , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
  {
    local  ; Unaffected by Super-global variables
      static hBM, oldzx, oldzy, oldzw, oldzh, bits:=[]
    static Ptr:=A_PtrSize ? "UPtr" : "UInt"
    static init:=!GetBitsFromScreen(0,0,0,0,1)
    if (!ScreenShot)
    {
    zx:=oldzx, zy:=oldzy, zw:=oldzw, zh:=oldzh
    return, bits
    }
    bch:=A_BatchLines, cri:=A_IsCritical
    Critical
    if (zw<1 or zh<1)
    {
    SysGet, zx, 76
    SysGet, zy, 77
    SysGet, zw, 78
    SysGet, zh, 79
    }
    if (zw>oldzw or zh>oldzh or !hBM)
    {
    DllCall("DeleteObject", Ptr,hBM), hBM:="", bpp:=32
    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
    NumPut(zw, bi, 4, "int"), NumPut(-zh, bi, 8, "int")
    NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
    hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
      , "int",0, Ptr "*",ppvBits, Ptr,0, "int",0, Ptr)
    Scan0:=(!hBM ? 0:ppvBits), Stride:=((zw*bpp+31)//32)*4
    bits.1:=Scan0, bits.2:=Stride
    oldzx:=zx, oldzy:=zy, oldzw:=zw, oldzh:=zh
    x:=zx, y:=zy, w:=zw, h:=zh
    }
    if (hBM) and !(w<1 or h<1)
    {
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020) ; |0x40000000)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
  if (id:=BindWindow(0,0,1))
    WinGet, id, ID, ahk_id %id%
  if (id)
  {
    WinGetPos, wx, wy, ww, wh, ahk_id %id%
    left:=x, right:=x+w-1, up:=y, down:=y+h-1
    left:=left<wx ? wx:left, right:=right>wx+ww-1 ? wx+ww-1:right
    up:=up<wy ? wy:up, down:=down>wy+wh-1 ? wy+wh-1:down
    x:=left, y:=up, w:=right-left+1, h:=down-up+1
  }
  if (id) and !(w<1 or h<1)
  {
    hDC2:=DllCall("GetDCEx", Ptr,id, Ptr,0, "int",3, Ptr)
    DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
    , Ptr,hDC2, "int",x-wx, "int",y-wy, "uint",0x00CC0020) ; |0x40000000)
    DllCall("ReleaseDC", Ptr,id, Ptr,hDC2)
  }
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteDC", Ptr,mDC)
    }
    Critical, %cri%
    SetBatchLines, %bch%
    return, bits
  }

  PicInfo(text)
  {
    static info:=[]
    IfNotInString, text, $, return
    if (info[text])
      return, info[text]
    v:=text, comment:="", e1:=e0:=0, set_e1_e0:=0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2, set_e1_e0:=1
    }
    StringSplit, r, v, $
    color:=r1, v:=r2 "."
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (w1<1 or h1<1 or StrLen(v)!=w1*h1)
      return
    mode:=InStr(color,"-") ? 4 : InStr(color,"#") ? 3
      : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
    if (mode=4)
    {
      color:=StrReplace(color,"0x")
      StringSplit, r, color, -
      color:="0x" . r1, n:="0x" . r2
    }
    else
    {
      color:=RegExReplace(color,"[*#]") . "@"
      StringSplit, r, color, @
      color:=r1, n:=Round(r2,2)+(!r2)
      , n:=Floor(9*255*255*(1-n)*(1-n))
    }
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    , e1:=Round(len1*e1), e0:=Round(len0*e0)
    return, info[text]:=[v,w1,h1,len1,len0,e1,e0
      , mode,color,n,comment,set_e1_e0]
  }

  PicFind(mode, color, n, offsetX, offsetY
  , bits, sx, sy, sw, sh
  , ByRef gs, ByRef ss, ByRef text, ByRef s1, ByRef s0
  , ByRef input, num, ByRef allpos, allpos_max)
  {
    static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
    if (!MyFunc)
    {
      x32:="5557565383EC788B8424CC0000008BBC24CC000000C7442"
      . "424000000008B40048B7F148944243C8B8424CC000000897C2"
      . "42C8BBC24CC0000008B40088B7F18894424388B8424CC00000"
      . "0897C24308B400C89C6894424288B8424CC0000008B401039C"
      . "6894424200F4DC68944241C8B8424D000000085C00F8E15010"
      . "0008BB424CC0000008B44242489F78B0C868B7486048B44870"
      . "88974241085C0894424180F8ED700000089CD894C2414C7442"
      . "40C00000000C744240800000000C744240400000000890C248"
      . "D76008DBC27000000008B5C24108B7424088B4C24148B54240"
      . "C89DF89F029F101F78BB424C000000001CE85DB7E5E8B0C248"
      . "9EB893C2489D7EB198BAC24C800000083C70483C00189548D0"
      . "083C101390424742C83BC248C0000000389FA0F45D0803C063"
      . "175D48BAC24C400000083C70483C00189549D0083C30139042"
      . "475D48B7424100174241489DD890C2483442404018BB424B00"
      . "000008B442404017424088BBC24A4000000017C240C3944241"
      . "80F8554FFFFFF83442424078B442424398424D00000000F8FE"
      . "BFEFFFF83BC248C000000030F84A00600008B8424A40000008"
      . "BB424A80000000FAF8424AC0000008BBC24A40000008D2CB08"
      . "B8424B0000000F7D88D04878BBC248C0000008944241085FF0"
      . "F84F702000083BC248C000000010F847F08000083BC248C000"
      . "000020F84330900008B8424900000008B9C24940000000FB6B"
      . "C24940000000FB6B42490000000C744241800000000C744242"
      . "400000000C1E8100FB6DF0FB6D08B84249000000089D10FB6C"
      . "4894424088B842494000000C1E8100FB6C029C101D08904248"
      . "B442408894C24408B4C240801D829D9894424088D043E894C2"
      . "40489F129F9894424148BBC24B40000008B8424B0000000894"
      . "C240C89E98B6C2440C1E00285FF894424340F8EBA0000008BB"
      . "424B000000085F60F8E910000008B8424A00000008B5424240"
      . "39424BC00000001C8034C243489CF894C244003BC24A000000"
      . "0EB3D8D76008DBC2700000000391C247C3D394C24047F37394"
      . "C24087C3189F30FB6F33974240C0F9EC3397424140F9DC183C"
      . "00483C20121D9884AFF39F8741E0FB658020FB648010FB6303"
      . "9DD7EBE31C983C00483C201884AFF39F875E28BB424B000000"
      . "0017424248B4C24408344241801034C24108B442418398424B"
      . "40000000F8546FFFFFF8B8424B00000002B44243C8944240C8"
      . "B8424B40000002B442438894424600F886D0900008B4424288"
      . "BBC24C40000008B74243CC744241000000000C744243800000"
      . "000C7442434000000008D3C8789C583EE01897C246C8974247"
      . "48B44240C85C00F88E70000008B7C24388B8424AC000000BE0"
      . "0000000C704240000000001F8C1E0108944246889F82B84249"
      . "C0000000F49F08B84249C000000897424640FAFB424B000000"
      . "001F8894424708974245C8DB6000000008B04240344241089C"
      . "1894424088B442430394424200F84AA0100008B5C241C89C60"
      . "38C24BC00000031C08B54242C85DB0F8EC8010000897424048"
      . "B7C2420EB2D39C77E1C8BB424C80000008B1C8601CB803B007"
      . "40B836C240401782B8D74260083C0013944241C0F849101000"
      . "039C57ECF8BB424C40000008B1C8601CB803B0174BE83EA017"
      . "9B9830424018B04243944240C0F8D68FFFFFF83442438018BB"
      . "424B00000008B44243801742410394424600F8DEFFEFFFF8B4"
      . "C243483C47889C85B5E5F5DC250008B8424900000008BB424B"
      . "4000000C744240C00000000C744241400000000C1E8100FB6C"
      . "08904248B8424900000000FB6C4894424040FB684249000000"
      . "0894424088B8424B0000000C1E00285F68944242489E88BAC2"
      . "4940000000F8E24FEFFFF8B9C24B000000085DB7E758B9C24A"
      . "00000008B7424148BBC24A000000003B424BC00000001C3034"
      . "424248944241801C78D76008DBC27000000000FB643020FB64"
      . "B012B04242B4C24040FB6132B5424080FAFC00FAFC98D04400"
      . "FAFD28D04888D045039C50F930683C30483C60139DF75C98BB"
      . "C24B0000000017C24148B4424188344240C01034424108B742"
      . "40C39B424B40000000F8566FFFFFFE985FDFFFF85ED7E358B7"
      . "424088BBC24BC00000031C08B54242C8D1C378BB424C400000"
      . "08B0C8601D9803901740983EA010F8890FEFFFF83C00139C57"
      . "5E683BC24D0000000070F8EAA0100008B442474030424C7442"
      . "44007000000896C2444894424288B8424CC00000083C020894"
      . "4243C8B44243C8B9424B00000008B7C24288B0029C28944245"
      . "08B84249800000001F839C20F4EC289C68944244C39FE0F8C0"
      . "90100008B44243C8B700C8B78108B6808897424148B7014897"
      . "C242489C7897424548BB424B40000002B700489F08B7424703"
      . "9C60F4EC68BB424C4000000894424188B47FC89442404C1E00"
      . "201C6038424C8000000894424588B4424648B7C2428037C245"
      . "C3B442418894424040F8F8700000085ED7E268B8C24BC00000"
      . "08B54242431C08D1C398B0C8601D9803901740583EA01784A8"
      . "3C00139C575EA8B4424148B4C245439C8747E85C07E7A8B9C2"
      . "4BC000000896C244831C08B6C245801FBEB0983C0013944241"
      . "4745C8B54850001DA803A0074EC83E90179E78B6C244890834"
      . "424040103BC24B00000008B442404394424180F8D79FFFFFF8"
      . "3442428018B4424283944244C0F8D4CFFFFFF830424018B6C2"
      . "4448B04243944240C0F8D7EFCFFFFE911FDFFFF8B4424288B7"
      . "C245083442440078344243C1C8D4438FF894424288B4424403"
      . "98424D00000000F8F7FFEFFFF8B6C24448B7C24348B0424038"
      . "424A80000008BB424D40000000B4424688D4F01398C24D8000"
      . "0008904BE0F8ED8FCFFFF85ED7E278B7424088BBC24BC00000"
      . "08B8424C40000008D1C378B74246C8B1083C00401DA39F0C60"
      . "20075F283042401894C24348B04243944240C0F8DDEFBFFFFE"
      . "971FCFFFF89F68DBC27000000008B74243C8B8424900000003"
      . "1D2F7F60FAF8424A40000008D0490894424188B8424B000000"
      . "0038424A800000029F0894424348B8424AC000000038424B40"
      . "000002B442438398424AC0000008944243C0F8F560400008B8"
      . "424A40000008BB424A80000000FAF8424AC000000C74424240"
      . "00000008D04B0034424188BB424A0000000894424388B44243"
      . "4398424A80000000F8F320100008B8424AC000000C1E010894"
      . "424408B442438894424148B8424A8000000894424088B44241"
      . "40FB67C060289C52B6C2418893C240FB67C0601897C24040FB"
      . "63C068B44241C85C00F8E1E0100008B442430894424108B442"
      . "42C8944240C31C0EB678D76008DBC2700000000394424207E4"
      . "A8B9C24C80000008B0C8301E90FB6540E020FB65C0E012B142"
      . "42B5C24040FB60C0E0FAFD20FAFDB29F98D14520FAFC98D149"
      . "A8D144A39942494000000720C836C2410017865908D7426008"
      . "3C0013944241C0F84A3000000394424287E9D8B9C24C400000"
      . "08B0C8301E90FB6540E020FB65C0E012B14242B5C24040FB60"
      . "C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A3B94249"
      . "40000000F865BFFFFFF836C240C010F8950FFFFFF834424080"
      . "183442414048B442408394424340F8DEFFEFFFF838424AC000"
      . "000018BBC24A40000008B44243C017C24383B8424AC0000000"
      . "F8D99FEFFFF8B4C242483C4785B5E89C85F5DC250008D74260"
      . "08B7C24248B4424400B4424088B9C24D40000008D4F013B8C2"
      . "4D80000008904BB0F8D64FAFFFF894C2424EB848B842490000"
      . "0008B8C24B4000000C7042400000000C74424040000000083C"
      . "001C1E00789C68B8424B0000000C1E00285C98944240889E88"
      . "9F50F8EAFF8FFFF8B9424B000000085D27E5F8B8C24A000000"
      . "08B5C2404039C24BC00000001C1034424088944240C038424A"
      . "000000089C70FB651020FB641010FB6316BC04B6BD22601C28"
      . "9F0C1E00429F001D039C50F970383C10483C30139F975D58BB"
      . "424B0000000017424048B44240C83042401034424108B34243"
      . "9B424B40000007582E92CF8FFFF8B8424B0000000C70424000"
      . "00000C744240400000000C1E002894424088B8424B40000008"
      . "5C00F8E920000008B8424B000000085C07E6F8B8C24A000000"
      . "08B5C24048BB424B800000001E9036C240801DE039C24BC000"
      . "000896C240C03AC24A00000000FB651020FB6410183C1040FB"
      . "679FC83C60183C3016BC04B6BD22601C289F8C1E00429F801D"
      . "0C1F8078846FFC643FF0039CD75CC8BBC24B0000000017C240"
      . "48B6C240C83042401036C24108B0424398424B40000000F856"
      . "EFFFFFF83BC24B4000000020F8E60F7FFFF8B8424BC0000000"
      . "38424B00000008BAC24B800000003AC24B0000000C74424040"
      . "1000000894424088B8424B400000083E8018944240C8B8424B"
      . "000000083C0018944241083BC24B0000000027E798B4424108"
      . "9E92B8C24B00000008B5C240889EA8D34288D45FE8904240FB"
      . "642010FB63A0384249000000039F87C360FB67A0239F87C2E0"
      . "FB6790139F87C260FB63E39F87C1F0FB63939F87C180FB6790"
      . "239F87C100FB67EFF39F87C080FB67E0139F87D04C64301018"
      . "3C20183C30183C10183C6013B0C2475A3834424040103AC24B"
      . "00000008B4424048BBC24B0000000017C24083944240C0F855"
      . "8FFFFFFE96FF6FFFF83C47831C95B89C85E5F5DC2500090909"
      . "090909090"
      x64:="4157415641554154555756534881EC88000000488B84245"
      . "0010000488BB42450010000448B94245801000089542428448"
      . "944240844898C24E80000008B40048B76144C8BBC244001000"
      . "04C8BB42448010000C74424180000000089442430488B84245"
      . "00100008974241C488BB424500100008B40088B76188944243"
      . "C488B842450010000897424388B400C89C789442440488B842"
      . "4500100008B401039C7894424100F4DC74585D289442454488"
      . "B84245001000048894424200F8ECB000000488B442420448B0"
      . "8448B68048B400885C0894424040F8E940000004489CE44890"
      . "C244531E431FF31ED0F1F8400000000004585ED7E614863142"
      . "4418D5C3D0089F848039424380100004589E0EB1D0F1F0083C"
      . "0014D63D94183C0044183C1014883C20139C34789149E74288"
      . "3F9034589C2440F45D0803A3175D783C0014C63DE4183C0048"
      . "3C6014883C20139C34789149F75D844012C2483C50103BC241"
      . "80100004403A42400010000396C24047582834424180748834"
      . "424201C8B442418398424580100000F8F35FFFFFF83F9030F8"
      . "43D0600008B8424000100008BBC24080100000FAF842410010"
      . "0008BB424000100008D3CB88B842418010000F7D885C9448D2"
      . "C860F841101000083F9010F844108000083F9020F84E008000"
      . "08B742428C744240400000000C74424180000000089F0440FB"
      . "6CEC1E8104589CC0FB6D84889F08B7424080FB6D44189DB89F"
      . "0440FB6C64889F1C1E8100FB6CD89D60FB6C08D2C0A8B94242"
      . "00100004129C301C3438D040129CE4529C48904248B8424180"
      . "10000C1E00285D2894424080F8E660100004C89BC244001000"
      . "0448BBC24180100004585FF0F8E91040000488B8C24F800000"
      . "04863C74C6354241831D24C03942430010000488D440102EB3"
      . "A0F1F80000000004439C37C4039CE7F3C39CD7C384539CC410"
      . "F9EC044390C240F9DC14421C141880C124883C2014883C0044"
      . "139D70F8E2D040000440FB6000FB648FF440FB648FE4539C37"
      . "EBB31C9EBD58B5C2428448B8C242001000031ED4531E44889D"
      . "84189DB0FB6DB0FB6F48B84241801000041C1EB10450FB6DBC"
      . "1E0024585C98904240F8EA10000004C89BC24400100004C89B"
      . "42448010000448B7C2408448BB424180100004585F67E60488"
      . "B8C24F80000004D63D44C039424300100004863C74531C94C8"
      . "D440102410FB600410FB648FF410FB650FE4429D829F10FAFC"
      . "029DA0FAFC98D04400FAFD28D04888D04504139C7430F93040"
      . "A4983C1014983C0044539CE7FC4033C244501F483C5014401E"
      . "F39AC2420010000758C4C8BBC24400100004C8BB4244801000"
      . "08B8424180100002B4424308904248B8424200100002B44243"
      . "C894424680F88750800008B7C24404D89F5488BAC243001000"
      . "0448B7424104C89FEC74424040000000048C74424280000000"
      . "0C74424200000000089F883E801498D4487044189FF4889442"
      . "4088B44243083E801894424788B042485C00F88D9000000488"
      . "B5C24288B8424100100004D89EC448B6C245401D8C1E010894"
      . "4247089D82B8424F000000089C7B8000000000F49C731FF894"
      . "4246C0FAF842418010000894424648B8424F000000001D8894"
      . "42474908B442404897C24188D1C388B4424384139C60F84AB0"
      . "000004189C131C04585ED448B44241C7F36E9C30000000F1F4"
      . "0004139CE7E1B418B148401DA4863D2807C150000740B4183E"
      . "901782E0F1F4400004883C0014139C50F8E920000004139C78"
      . "9C17ECC8B148601DA4863D2807C15000174BD4183E80179B74"
      . "883C701393C240F8D7AFFFFFF4D89E54883442428018B9C241"
      . "8010000488B442428015C2404394424680F8DFCFEFFFF8B4C2"
      . "42089C84881C4880000005B5E5F5D415C415D415E415FC3458"
      . "5FF7E278B4C241C4C8B4424084889F28B0201D84898807C050"
      . "001740583E90178934883C2044939D075E583BC24580100000"
      . "70F8EE60100008B442478488B8C24500100000344241844896"
      . "C2450448BAC241801000044897C24404883C1204889742410C"
      . "744243C07000000448974244448897C24484989CF895C247C8"
      . "9C64C89642430418B074489EA29C28944245C8B8424E800000"
      . "001F039C20F4EC239F0894424580F8CD0000000418B47148BB"
      . "C2420010000412B7F0449635FFC458B4F08458B670C8944246"
      . "08B442474458B771039C70F4FF8488B44241048C1E3024C8D1"
      . "41848035C24308B442464448D04068B44246C39F84189C37F7"
      . "2904585C97E234489F131D2418B04924401C04898807C05000"
      . "1740583E90178464883C2014139D17FE28B4424604139C40F8"
      . "4AA0000004585E40F8EA100000089C131D2EB0D4883C201413"
      . "9D40F8E8E0000008B04934401C04898807C05000074E483E90"
      . "179DF4183C3014501E84439DF7D8F83C601397424580F8D6EF"
      . "FFFFF488B7C2448448B7C2440448B742444448B6C2450488B7"
      . "424104C8B6424304883C701393C240F8D97FDFFFFE918FEFFF"
      . "F6690037C240844017C241883442404014401EF8B442404398"
      . "424200100000F854DFBFFFF4C8BBC2440010000E996FCFFFF8"
      . "B44245C8344243C074983C71C8D7406FF8B44243C398424580"
      . "100000F8F87FEFFFF448B7C2440448B742444448B6C2450488"
      . "B7C24488B5C247C488B7424104C8B64243048634424208B542"
      . "418039424080100004C8B9C24600100000B5424708D4801398"
      . "C2468010000418914830F8E9AFDFFFF4585FF7E1D4C8B44240"
      . "84889F08B104883C00401DA4C39C04863D2C64415000075EB4"
      . "883C701393C24894C24200F8DBAFCFFFFE93BFDFFFF0F1F440"
      . "0008B7C24308B44242831D2F7F70FAF8424000100008D04908"
      . "94424208B8424180100000384240801000029F8894424308B8"
      . "42410010000038424200100002B44243C39842410010000894"
      . "424440F8F2B0400008B8424000100008BBC24080100000FAF8"
      . "42410010000448B642440448B6C24544C8B8C24F8000000C74"
      . "42428000000008D04B8034424208944243C8B4424303984240"
      . "80100000F8F360100008B8424100100008B6C243CC1E010894"
      . "424408B8424080100008904248D450289EF2B7C24204585ED4"
      . "898450FB61C018D45014898410FB61C014863C5410FB634010"
      . "F8E1C0100008B442438894424188B44241C8944240431C0EB6"
      . "90F1F800000000044395424107E4E418B0C8601F98D5102448"
      . "D41014863C9410FB60C094863D24D63C0410FB61411470FB60"
      . "40129F10FAFC94429DA4129D80FAFD2450FAFC08D1452428D1"
      . "4828D144A395424087207836C241801786B4883C0014139C50"
      . "F8E9F0000004139C44189C27E96418B0C8701F98D5102448D4"
      . "1014863C9410FB60C094863D24D63C0410FB61411470FB6040"
      . "129F10FAFC94429DA4129D80FAFD2450FAFC08D1452428D148"
      . "28D144A3B5424080F864BFFFFFF836C2404010F8940FFFFFF8"
      . "304240183C5048B0424394424300F8DE6FEFFFF83842410010"
      . "000018BBC24000100008B442444017C243C3B8424100100000"
      . "F8D95FEFFFF8B4C2428E95CFBFFFF48634424288B5424400B1"
      . "424488BBC24600100008D48013B8C24680100008914870F8D3"
      . "5FBFFFF8304240183C504894C24288B0424394424300F8D7AF"
      . "EFFFFEB92448B5C2428448B84242001000031DB8B842418010"
      . "00031F6448B9424180100004183C30141C1E3074585C08D2C8"
      . "5000000000F8E6BF9FFFF4585D27E57488B8C24F80000004C6"
      . "3CE4C038C24300100004863C74531C0488D4C01020FB6110FB"
      . "641FF440FB661FE6BC04B6BD22601C24489E0C1E0044429E00"
      . "1D04139C3430F9704014983C0014883C1044539C27FCC01EF4"
      . "401D683C3014401EF399C24200100007595E9FBF8FFFF8B8C2"
      . "4200100008B84241801000031DB31F6448B8C241801000085C"
      . "98D2C85000000007E7D4585C97E694C63C6488B8C24F800000"
      . "04863C74D89C24C038424300100004C0394242801000031D24"
      . "88D4C0102440FB6190FB641FF4883C104440FB661FA6BC04B4"
      . "56BDB264101C34489E0C1E0044429E04401D8C1F8074188041"
      . "241C60410004883C2014139D17FC401EF4401CE83C3014401E"
      . "F399C2420010000758383BC2420010000020F8E4BF8FFFF486"
      . "3B424180100008B9C24180100008BBC2420010000488D56014"
      . "48D67FFBF010000004889D0480394243001000048038424280"
      . "100004889D58D53FD4C8D6A0183BC241801000002488D1C067"
      . "E7E4989C04D8D5C05004989D94929F04889E90FB610440FB65"
      . "0FF035424284439D27C44440FB650014439D27C3A450FB6104"
      . "439D27C31450FB6114439D27C28450FB650FF4439D27C1E450"
      . "FB650014439D27C14450FB651FF4439D27C0A450FB65101443"
      . "9D27D03C601014883C0014983C1014883C1014983C0014C39D"
      . "8759383C7014801F54889D84139FC0F8562FFFFFFE968F7FFF"
      . "F31C9E9D9F8FFFF909090909090909090909090"
      MCode(MyFunc, A_PtrSize=8 ? x64:x32)
    }
    return, !bits.1 ? 0:DllCall(&MyFunc, "int",mode, "uint",color
      , "uint",n, "int",offsetX, "int",offsetY, Ptr,bits.1
      , "int",bits.2, "int",sx, "int",sy, "int",sw, "int",sh
      , Ptr,&gs, Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
      , Ptr,&input, "int",num, Ptr,&allpos, "int",allpos_max)
  }


  MCode(ByRef code, hex)
  {
    bch:=A_BatchLines
    SetBatchLines, -1
    VarSetCapacity(code, len:=StrLen(hex)//2)
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, % len
      NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
    ListLines, %lls%
    Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr "*"
    DllCall("VirtualProtect",Ptr,&code, Ptr,len,"uint",0x40,PtrP,0)
    SetBatchLines, %bch%
  }

  base64tobit(s)
  {
    Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      . "abcdefghijklmnopqrstuvwxyz"
    SetFormat, IntegerFast, d
    StringCaseSense, On
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, Parse, Chars
    {
      i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
      s:=StrReplace(s,A_LoopField,v)
    }
    ListLines, %lls%
    StringCaseSense, Off
    s:=SubStr(s,1,InStr(s,"1",0,0)-1)
    s:=RegExReplace(s,"[^01]+")
    return, s
  }

  bit2base64(s)
  {
    s:=RegExReplace(s,"[^01]+")
    s.=SubStr("100000",1,6-Mod(StrLen(s),6))
    s:=RegExReplace(s,".{6}","|$0")
    Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      . "abcdefghijklmnopqrstuvwxyz"
    SetFormat, IntegerFast, d
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    Loop, Parse, Chars
    {
      i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
      s:=StrReplace(s,v,A_LoopField)
    }
    ListLines, %lls%
    return, s
  }

  ASCII(s)
  {
    if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
    {
      s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
      s:=StrReplace(StrReplace(s,"0","_"),"1","0")
    }
    else s=
    return, s
  }

  ; You can put the text library at the beginning of the script,
  ; and Use PicLib(Text,1) to add the text library to PicLib()'s Lib,
  ; Use PicLib("comment1|comment2|...") to get text images from Lib

  PicLib(comments, add_to_Lib:=0, index:=1)
  {
    static Lib:=[]
    SetFormat, IntegerFast, d
    if (add_to_Lib)
    {
      re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
      Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
      {
        s1:=Trim(r1), s2:=""
        Loop, Parse, s1
        s2.="_" . Ord(A_LoopField)
        Lib[index,s2]:=r
      }
      Lib[index,""]:=""
    }
    else
    {
      Text:=""
      Loop, Parse, comments, |
      {
      s1:=Trim(A_LoopField), s2:=""
      Loop, Parse, s1
        s2.="_" . Ord(A_LoopField)
      Text.="|" . Lib[index,s2]
      }
      return, Text
    }
  }

  PicN(Number, index:=1)
  {
    return, PicLib(RegExReplace(Number,".","|$0"), 0, index)
  }

  ; Use PicX(Text) to automatically cut into multiple characters
  ; Can't be used in ColorPos mode, because it can cause position errors

  PicX(Text)
  {
    if !RegExMatch(Text,"\|([^$]+)\$(\d+)\.([\w+/]+)",r)
      return, Text
    w:=r2, v:=base64tobit(r3), Text:=""
    c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
    wz:=RegExReplace(v,".{" w "}","$0`n")
    SetFormat, IntegerFast, d
    While InStr(wz,c)
    {
      While !(wz~="m`n)^" c)
      wz:=RegExReplace(wz,"m`n)^.")
      i:=0
      While (wz~="m`n)^.{" i "}" c)
      i++
      v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
      wz:=RegExReplace(wz,"m`n)^.{" i "}")
      if (v!="")
      Text.="|" r1 "$" i "." bit2base64(v)
    }
    return, Text
  }

  ; Screenshot and retained as the last screenshot.

  ScreenShot(x1:="", y1:="", x2:="", y2:="")
  {
    if (x1+y1+x2+y2="")
      n:=150000, x:=y:=-n, w:=h:=2*n
    else
      x:=(x1<x2 ? x1:x2), y:=(y1<y2 ? y1:y2)
      , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
    xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
    GetBitsFromScreen(x,y,w,h,1,zx,zy,zw,zh)
  }

  ; Get the RGB color of a point from the last screenshot.
  ; If the point to get the color is beyond the range of
  ; Screen, it will return White color (0xFFFFFF).

  ScreenShot_GetColor(x,y)
  {
      bits:=GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
    return, (x<zx or x>zx+zw-1 or y<zy or y>zy+zh-1 or !bits.1)
    ? "0xFFFFFF" : Format("0x{:06X}",NumGet(bits.1
    +(y-zy)*bits.2+(x-zx)*4,"uint")&0xFFFFFF)
  }

  ; Identify a line of text or verification code
  ; based on the result returned by FindText()
  ; Return Association array {ocr:Text, x:X, y:Y}

  OcrOK(ok, offsetX:=20, offsetY:=20)
  {
    ocr_Text:=ocr_X:=ocr_Y:=min_X:=""
    For k,v in ok
      x:=v.1
      , min_X:=(A_Index=1 or x<min_X ? x : min_X)
      , max_X:=(A_Index=1 or x>max_X ? x : max_X)
    While (min_X!="" and min_X<=max_X)
    {
      LeftX:=""
      For k,v in ok
      {
      x:=v.1, y:=v.2, w:=v.3, h:=v.4
      if (x<min_X) or Abs(y-ocr_Y)>offsetY
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" or x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=v.id
      else if (x=LeftX)
      {
        Loop, 100
        {
        err:=(A_Index-1)/100+0.000001
        if FindText(LeftX,LeftY,LeftX+LeftW-1,LeftY+LeftH-1,err,err,Text,0)
          Break
        if FindText(x, y, x+w-1, y+h-1, err, err, Text, 0)
        {
          LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=v.id
          Break
        }
        }
      }
      }
      if (ocr_X="")
      ocr_X:=LeftX, ocr_Y:=LeftY
      ; If the interval exceeds the set value, add "*" to the result
      ocr_Text.=(ocr_Text!="" and LeftX-min_X>offsetX ? "*":"") . LeftOCR
      ; Update min_X for next search
      min_X:=LeftX+LeftW
    }
    return, {ocr:ocr_Text, x:ocr_X, y:ocr_Y}
  }

  ; Sort the results returned by FindText() from left to right
  ; and top to bottom, ignore slight height difference

  SortOK(ok, dy:=10)
  {
    if !IsObject(ok)
      return, ok
    SetFormat, IntegerFast, d
    ypos:=[]
    For k,v in ok
    {
      x:=v.x, y:=v.y, add:=1
      For k2,v2 in ypos
      if Abs(y-v2)<=dy
      {
        y:=v2, add:=0
        Break
      }
      if (add)
      ypos.Push(y)
      n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
    }
    Sort, s, N D-
    ok2:=[]
    Loop, Parse, s, -
      ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
    return, ok2
  }

  ; Reordering according to the nearest distance

  SortOK2(ok, px, py)
  {
    if !IsObject(ok)
      return, ok
    SetFormat, IntegerFast, d
    For k,v in ok
    {
      x:=v.1+v.3//2, y:=v.2+v.4//2
      n:=((x-px)**2+(y-py)**2) "." k
      s:=A_Index=1 ? n : s "-" n
    }
    Sort, s, N D-
    ok2:=[]
    Loop, Parse, s, -
      ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
    return, ok2
  }

  ; Prompt mouse position in remote assistance

  MouseTip(x:="", y:="", w:=21, h:=21)
  {
    if (x="")
    {
      VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
      x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
    }
    ; x:=Round(x-10), y:=Round(y-10)
    ;-------------------------
    Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
    Gui, _MouseTip_: Show, Hide w%w% h%h%
    ;-------------------------
    dhw:=A_DetectHiddenWindows
    DetectHiddenWindows, On
    d:=1, i:=w-d, j:=h-d
    s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
    s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
    WinSet, Region, %s%, ahk_id %myid%
    DetectHiddenWindows, %dhw%
    ;-------------------------
    Gui, _MouseTip_: Show, NA x%x% y%y%
    Loop, 4
    {
      Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
      Sleep, 500
    }
    Gui, _MouseTip_: Destroy
  }

;===============  FindText Library End  ===================
