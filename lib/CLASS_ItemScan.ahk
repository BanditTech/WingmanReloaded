; NOTE: CLASS_ItemScan.ahk - Converted to AHK v2
; GoSub labels in GraphNinjaPrices() have been converted to nested helper functions.
; GuiControl calls have been converted to Gui object syntax.
; Review all TODO comments before running.

class ItemScan
{
	__New(){
		This.Data := {}
		This.Data.ClipContents := RegExReplace(Clip_Contents, "<<.*?>>|<.*?>") ; Clipboard
		This.Data.Sections := StrSplit(This.Data.ClipContents, "`r`n--------`r`n")
		This.Data.Blocks := {Affix:"", Enchant:"", Implicit:"", Influence:"", TempleRooms:"", ObstructedRooms:"", FlavorText:"", NamePlate:"", Properties:"", ClusterImplicit:""}
		This.Pseudo := Map()
		This.Affix := Map()
		This.Prop := {}
		This.Modifier := Map()
		This.Percent := {}
		; Split our sections from the clipboard
		; NamePlate, Affix, FlavorText, Enchant, Implicit, Influence, Corrupted
		For SectionKey, SVal in This.Data.Sections
		{
			If ((SVal ~= ":" || SVal ~= "Currently has \d+ Charges") && !(SVal ~= "grant:") && !(SVal ~= "slot:"))
			{
				If (SectionKey == 1 && SVal ~= "Rarity:" || SVal ~= "Item Class:"){
					This.Data.Blocks.NamePlate := SVal, This.Prop.IsItem := true
				} Else If (SVal ~= "\(implicit\)$"){
					This.Prop.HasImplicit := True
					This.Data.Blocks.Implicit := SVal
				} Else If (SVal ~= "{ Prefix" || SVal ~= "{ Suffix" || SVal ~= "{ Unique" || SVal ~= "^Pack Size:" ) {
					This.Data.Blocks.Affix := SVal
				} Else If (SVal ~= " \(enchant\)$"){
					This.Prop.Enchanted := True
					This.Data.Blocks.Enchant := SVal
				} Else If (SVal ~= "Open Rooms:"){
					temp := StrSplit(SVal,"Obstructed Rooms:")
					This.Data.Blocks.TempleRooms := StrSplit(temp.1,"Open Rooms:").2
					This.Data.Blocks.ObstructedRooms := RegExReplace(temp.2, "$", " (Obstructed)")
				}	Else {
					This.Data.Blocks.Properties .= SVal "`r`n"
				}
			}
			Else
			{
				If (SVal ~= "\.$" || SVal ~= "\?$" || SVal ~= "`"$")
					This.Data.Blocks.FlavorText := SVal
				Else If (SVal ~= "\(implicit\)$"){
					This.Prop.HasImplicit := True
					This.Data.Blocks.Implicit := SVal
				}
				Else If (SVal ~= "Adds \d{1,} Passive Skills (enchant)")
					This.Data.Blocks.ClusterImplicit := SVal
				Else If (SVal ~= "\(enchant\)$"){
					This.Prop.HasEnchant := True
					This.Data.Blocks.Enchant := SVal
				}
				Else If (SVal ~= " Item$") && !(SVal ~= "\w{1,} \w{1,} \w{1,} Item$")
					This.Data.Blocks.Influence := SVal
				Else If (SVal ~= "^Corrupted$")
					This.Prop.Corrupted := True
				Else If (SVal ~= "^Abyss$")
					This.Prop.IsAbyss := True
				Else If (SVal ~= "^Unidentified$")
					This.Data.Blocks.Affix := SVal
				Else If (This.Data.Blocks.Affix != "" || SVal ~= "`".*`"$")
					This.Data.Blocks.FlavorText := SVal
				Else
					This.Data.Blocks.Affix := SVal
			}
		}
		This.Data.Sections := ""
		This.Data.DeleteProp("Sections")

		This.MatchAffixesWithoutDoubleMods(This.Data.Blocks.Affix)
		;This.MatchAffixes(This.Data.Blocks.Affix)
		This.MatchAffixes(This.Data.Blocks.Enchant)
		This.MatchAffixes(This.Data.Blocks.Implicit)
		This.MatchAffixes(This.Data.Blocks.Influence)
		This.MatchAffixes(This.Data.Blocks.TempleRooms)
		This.MatchAffixes(This.Data.Blocks.ObstructedRooms)
		This.MatchAffixes(This.Data.Blocks.ClusterImplicit)
		This.MatchProperties()
		If (This.Prop.Rarity_Digit == 4 && !This.Affix.Has("Unidentified"))
			This.ApproximatePerfection()
		This.MatchPseudoAffix()
		If (This.Prop.ClusterJewel) {
			This.Prop.ClusterSkills := 0
			This.Prop.ClusterSmall := 0
			For k, v in This.Affix {
				If InStr(k, "# Added Passive Skill is")
					This.Prop.ClusterSkills += 1
				If InStr(k, "Added Small Passive Skills also grant:")
					This.Prop.ClusterSmall += 1
				If (RegExMatch(k, "Added Small Passive Skills grant\: (.*) \(enchant\)", &match))
					This.Prop.ClusterKey := StrReplace(match[1],"#",This.Affix.Get(k, ""))
			}
			This.Prop.ClusterVariant := This.Affix.Get("Adds # Passive Skills (enchant)", "") " passives"
		}
		This.MatchExtenalDB()
		This.MatchCraftingBases()
		This.MatchBase2Slot()
		This.MatchChaosRegal()

		If (This.Prop.SlotType && ChaosRecipeEnableFunction)
			This.Prop.StashChaosItem := This.StashChaosRecipe(False)
		If (This.Prop.HasImplicit) {
			Static Tiers := {Lesser:1, Greater:2, Grand:3, Exceptional:4, Exquisite:5, Perfect:6}
			If (RegExMatch(This.Data.Blocks.Implicit, "`am)Searing Exarch Implicit Modifier \((.*?)\)", &RxMatch)) {
				This.Prop.TierImplicitSearing := Tiers[RxMatch.Value(1)] ? Tiers[RxMatch.Value(1)] : 5
				This.Prop.EldritchImplicit := True
				This.Prop.IsInfluenceItem := True
				This.Prop.Influence .= (This.Prop.Influence?" ":"") "Searing Exarch"
			}
			If (RegExMatch(This.Data.Blocks.Implicit, "`am)Eater of Worlds Implicit Modifier \((.*?)\)", &RxMatch)){
				This.Prop.TierImplicitEater := Tiers[RxMatch.Value(1)] ? Tiers[RxMatch.Value(1)] : 5
				This.Prop.EldritchImplicit := True
				This.Prop.IsInfluenceItem := True
				This.Prop.Influence .= (This.Prop.Influence?" ":"") "Eater of Worlds"
			}
		}
		; Disenchant value for Unique Items
		If (This.Prop.RarityUnique && (This.Prop.SlotType || This.Prop.IsWeapon || This.Prop.Quiver)) {
			multi := WR.Disenchant.Has(This.Prop.ItemName) ? WR.Disenchant[This.Prop.ItemName] : ""
			if multi {
				This.Prop.DustValue := This.DisenchantCalculation(multi,This.Prop.ItemLevel,This.Prop.Quality)
				totalSize := This.Prop.Item_Width * This.Prop.Item_Height
				This.Prop.DustPerSlot := Round(This.Prop.DustValue / totalSize,2)
			}
		}

		This.Prop.StashReturnVal := This.MatchStashManagement(false)
	}

	MatchProperties(){
		;Get total count of affixes
		This.Prop.AffixCount := 0
		This.Prop.PrefixCount := 0
		This.Prop.SuffixCount := 0
		This.Data.AffixNames := {Prefix:[],Suffix:[]}
		For k, v in StrSplit(This.Data.Blocks.Affix, "`n", "`r")
		{
			If (v == "")
				Continue
			; Flag curse on hit items
			If (v ~= "^Curse Enemies with .+ on Hit$")
				This.Prop.IsCurseOnHit := True
			If (v ~= "\{ Prefix Modifier"){
				If RegExMatch(v, "\{ Prefix Modifier `"(.+)`" \(Tier: (\d+)\) ?.? ?(.*) \}", &rxm ) {
					This.Data.AffixNames.Prefix.Push({Name:rxm[1],Tier:rxm[2],Tags:(rxm[3]?rxm[3]:"")})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				} Else If RegExMatch(v, "\{ Prefix Modifier `"(.+)`" . (.*) \}", &rxm ) {
					This.Data.AffixNames.Prefix.Push({Name:rxm[1],Tier:1,Tags:(rxm[2]?rxm[2]:"")})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				} Else If RegExMatch(v, "\{ Prefix Modifier `"(.+)`" \}", &rxm ) {
					This.Data.AffixNames.Prefix.Push({Name:rxm[1],Tier:1,Tags:""})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				}
				This.Prop.PrefixCount++, This.Prop.AffixCount++
			} Else If (v ~= "\{ Suffix Modifier") {
				If RegExMatch(v, "\{ Suffix Modifier `"(.+)`" \(Tier: (\d+)\) ?.? ?(.*) \}", &rxm ) {
					This.Data.AffixNames.Suffix.Push({Name:rxm[1],Tier:rxm[2],Tags:(rxm[3]?rxm[3]:"")})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				} Else If RegExMatch(v, "\{ Suffix Modifier `"(.+)`" . (.*) \}", &rxm ) {
					This.Data.AffixNames.Suffix.Push({Name:rxm[1],Tier:1,Tags:(rxm[2]?rxm[2]:"")})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				} Else If RegExMatch(v, "\{ Suffix Modifier `"(.+)`" \}", &rxm ) {
					This.Data.AffixNames.Suffix.Push({Name:rxm[1],Tier:1,Tags:""})
					This.Affix[rxm[1]] := This.Modifier[rxm[1]] := 1
				}
				This.Prop.SuffixCount++, This.Prop.AffixCount++
			}
		}
		This.Prop.OpenAffix := 6 - This.Prop.PrefixCount - This.Prop.SuffixCount

		If (RegExMatch(This.Data.Blocks.NamePlate, "`am)Item Class: (.+)", &RxMatch))
			This.Prop.ItemClass := RxMatch[1]
		If (RegExMatch(This.Data.Blocks.NamePlate, "`am)Rarity: (.+)", &RxMatch))
			This.Prop.Rarity := RxMatch[1]
		;Start NamePlate Parser
		If (This.Prop.Rarity || This.Prop.ItemClass)
		{
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
				This.Prop.SpecialType := This.Prop.Rarity ? This.Prop.Rarity : This.Prop.ItemClass
			}
			If (This.Prop.Rarity_Digit < 3)
				This.Prop.OpenAffix -= 4
			Else If (This.Prop.ItemClass ~= "Jewels" && This.Prop.Rarity_Digit == 3)
				This.Prop.OpenAffix -= 2
			; 4 Lines in NamePlate => Rarity / Item Name/ Item Base
			If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n.+`r`n(.+)`r`n(.+)", &RxMatch))
			{
				This.Prop.ItemName := RxMatch[1]
				This.Prop.ItemBase := RxMatch[2]
			}
			; 3 Lines in NamePlate => Rarity / Item Base
			Else If (RegExMatch(This.Data.Blocks.NamePlate, "`r`n.+`r`n(.+)", &RxMatch))
			{
				This.Prop.ItemName := RxMatch[1]
				This.Prop.ItemBase := RxMatch[1]
			}
			; 2 Lines in NamePlate => Item Name
			Else If (RegExMatch(This.Data.Blocks.NamePlate, "^.+`r`n(.+)$", &RxMatch))
			{
				This.Prop.ItemName := RxMatch[1]
				This.Prop.ItemBase := This.Prop.ItemClass
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

			; We match one of these against an item to identify its purpose
			If (This.Prop.ItemClass == "Atlas Upgrade Items")
			{
				This.Prop.AtlasStone := True
			}
			Else If (This.Prop.ItemClass == "Misc Map Items"
				|| This.Prop.ItemClass == "Memories"
				|| This.Prop.ItemClass == "Vault Key"
				|| (This.Prop.ItemClass == "Stackable Currency" && This.Prop.ItemBase ~= "Scouting Report"))
			{
				This.Prop.MiscMapItem := True
				This.Prop.SpecialType := "Misc Map Item"
				If (This.Prop.ItemClass == "Memories")
					This.Prop.IsMemory := True
			}
			Else If (This.Prop.ItemClass == "Stackable Currency" && RegExMatch(This.Prop.ItemBase, "^(.*) Rune$", &match))
			{
				This.Prop.IsRune := True
				This.Prop.KalguuranRune := match[1]
				This.Prop.SpecialType := "Kalguuran Rune"
			}
			Else If (This.Prop.ItemClass == "Stackable Currency" && RegExMatch(This.Prop.ItemBase, "^Omen of t?h?e? ?(.*)$", &match))
			{
				This.Prop.IsOmen := True
				This.Prop.OmenType := match[1]
				This.Prop.SpecialType := "Omen"
			}
			Else If (This.Prop.ItemClass == "Stackable Currency" && RegExMatch(This.Prop.ItemBase, "^Tattoo of the (.*)$", &match))
			{
				This.Prop.IsTattoo := True
				This.Prop.TattooType := match[1]
				This.Prop.SpecialType := "Tattoo"
			}
			Else If (This.Prop.ItemClass == "Atlas Region Upgrade Items" || This.Prop.ItemClass ~= "Atlas Upgrade Item" )
			{
				This.Prop.MiscMapItem := True
				This.Prop.SpecialType := "Atlas Voidstone"
			}
			Else If (This.Prop.ItemClass == "Maps")
			{
				This.Prop.IsMap := True
				; Deal with Blighted Map
				If (InStr(This.Prop.ItemBase, "Blighted"))
				{
					This.Prop.IsBlightedMap := True
					This.Prop.SpecialType := "Blighted Map"
				}
				Else If (InStr(This.Prop.ItemBase, "Blight-ravaged"))
				{
					This.Prop.IsBlightRavagedMap := True
					This.Prop.SpecialType := "Blight-ravaged Map"
				}
				Else
				{
					This.Prop.SpecialType := "Map"
				}
			}
			Else If (This.Prop.ItemBase ~= "Invitation:" && This.Data.Blocks.FlavorText ~= "Map Device")
			{
				This.Prop.SpecialType := "Invitation Map"
				This.Prop.IsInvitation := True
			}
			Else If (This.Prop.ItemBase ~= " Incubator$")
			{
				This.Prop.Incubator := True
				This.Prop.SpecialType := "Incubator"
			}
			Else If (This.Prop.ItemBase ~= "Crystallised Lifeforce$")
			{
				This.Prop.HarvestCurrency := True
				This.Prop.SpecialType := "Harvest Currency"
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
			Else If (InStr(This.Prop.ItemBase, "Splinter of") && This.Prop.ItemClass ~= "Stackable Currency")
			{
				This.Prop.BreachSplinter := True
				This.Prop.SpecialType := "Breach Splinter"
			}
			Else If (InStr(This.Prop.ItemBase, "Crest") && This.Prop.ItemClass ~= "Fragments")
			{
				This.Prop.ConquererFragment := True
				This.Prop.SpecialType := "Conquerer Fragment"
			}
			Else If (InStr(This.Prop.ItemBase, "Breachstone") && This.Prop.ItemClass ~= "Breachstones")
			{
				This.Prop.BreachSplinter := True
				This.Prop.SpecialType := "Breachstone"
			}
			Else If (InStr(This.Prop.ItemBase, "Sacrifice at") && This.Prop.ItemClass ~= "Fragments")
			{
				This.Prop.SacrificeFragment := True
				This.Prop.MapPrep := True
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
				This.Prop.MapPrep := True
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
			Else If (This.Prop.ItemClass == "Map Fragments")
			{
				This.Prop.SpecialType := "Map Fragments"
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
			Else If (This.Prop.ItemClass == "Abyss Jewel")
			{
				This.Prop.AbyssJewel := True
				This.Prop.Jewel := True
			}
			Else If (This.Prop.ItemClass == "Jewels")
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
			Else If (This.Prop.ItemClass == "Heist Targets")
			{
				This.Prop.Heist := True
				This.Prop.Vendorable := True
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
			Else If (This.Prop.ItemClass == "Quivers")
			{
				This.Prop.Quiver := True
				This.Prop.Item_Width := 2
				This.Prop.Item_Height := 3
			}
			Else if (indexOf(this.Prop.ItemBase, ["Exotic Coinage","Scrap Metal","Astragali","Burial Medallion"])) {
				This.Prop.Expedition := True
				This.Prop.ExpeditionCurrency := True
				This.Prop.SpecialType := "Expedition Currency"
			}
			Else If (InStr(This.Prop.ItemBase, "Expedition Logbook"))
			{
				This.Prop.Expedition := True
				This.Prop.SpecialType := "Expedition Logbook"
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
			Else If (This.Prop.ItemClass == "Contracts")
			{
				This.Prop.Heist := True
				This.Prop.MapLikeItem := True
				This.Prop.SpecialType := "Heist Contract"
			}
			Else If (This.Prop.ItemClass == "Blueprints")
			{
				This.Prop.Heist := True
				This.Prop.MapLikeItem := True
				This.Prop.SpecialType := "Heist Blueprint"
			}
			Else If (InStr(This.Prop.ItemBase, "Thief's Trinket"))
			{
				This.Prop.HeistGear := True
				This.Prop.SpecialType := "Heist Tricket"
			}
			Else If (InStr(This.Prop.ItemBase, "Rogue's Marker"))
			{
				This.Prop.Heist := True
				This.Prop.SpecialType := "Heist Marker"
			}
			Else If (indexOf(This.Prop.ItemBase, HeistGear))
			{
				This.Prop.HeistGear := True
				This.Prop.SpecialType := "Heist Gear"
				If InStr(This.Prop.ItemBase, "Brooch")
					This.Prop.Item_Width := This.Prop.Item_Height := 1
				Else
					This.Prop.Item_Width := This.Prop.Item_Height := 2
			}
			Else If (This.Prop.ItemClass == "Tinctures")
			{
				This.Prop.Item_Width := 1
				This.Prop.Item_Height := 2
			}
		}
		;End NamePlate Parser

		;Start Extra Blocks Parser
		;Parse Influence data block
		Loop Parse, This.Data.Blocks.Influence, "`n", "`r"
		{
			; Match for influence type
			If (RegExMatch(A_LoopField, "`am)(.+) Item", &RxMatch))
				This.Prop.Influence .= (This.Prop.Influence?" ":"") RxMatch[1]
		}
		If This.Prop.Influence {
			If (This.Prop.Influence ~= "Fractured" || This.Prop.Influence ~= "Synthesised")
				This.Prop.IsSynthesisItem := True
			Else
				This.Prop.IsInfluenceItem := True
		}
		; Get Beasts using Flavour Txt
		If (RegExMatch(This.Data.Blocks.FlavorText, "Right-click to add this to your bestiary", &RxMatch))
		{
			This.Prop.IsBeast := True
			This.Prop.SpecialType := "Beast"
		}
		;End Extra Blocks Parser

		;Start Prop Block Parser for General Items
		;Every Item has a Item Level
		If (This.Prop.Rarity)
		{
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Level: " rxNum, &RxMatch))
			{
				This.Prop.ItemLevel := RxMatch[1]
			}
			If (This.Data.Blocks.Has("Enchant"))
			{
				This.Prop.SpecialType := "Enchanted Item"
			}
			If (position := RegExMatch(This.Data.Blocks.Properties, "`am)^Level: " rxNum "( \(Max\))?", &RxMatch))
			{
				If (This.Prop.RarityGem) {
					This.Prop.Gem_Level := RxMatch[1]
					If (RxMatch[2] == " (Max)")
						This.Prop.Gem_MaxLevel := True
					If RegExMatch(This.Data.Blocks.Properties, "`am)^Level: " rxNum, &RxMatch, position+10)
						This.Prop.Required_Level := RxMatch[1]
					If RegExMatch(This.Data.Blocks.Properties, "`am)([, \w]+)\r", &RxMatch)
						This.Prop.Gem_Tags := RxMatch[1]
				} Else {
					This.Prop.Required_Level := RxMatch[1]
				}
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Str: " rxNum, &RxMatch))
			{
				This.Prop.Required_Str := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Dex: " rxNum, &RxMatch))
			{
				This.Prop.Required_Dex := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Int: " rxNum, &RxMatch))
			{
				This.Prop.Required_Int := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Sockets: ([\w- ]+)", &RxMatch))
			{
				This.Prop.Sockets_Raw := RxMatch[1]
				This.Prop.Sockets_Num := StrLen(RegExReplace(This.Prop.Sockets_Raw, "[- ]+" , ""))
				This.Prop.Sockets_Link := 0
				RegExReplace(RxMatch[1], "R",, n)
				This.Prop.Sockets_R := n
				RegExReplace(RxMatch[1], "G",, n)
				This.Prop.Sockets_G := n
				RegExReplace(RxMatch[1], "B",, n)
				This.Prop.Sockets_B := n
				RegExReplace(RxMatch[1], "W",, n)
				This.Prop.Sockets_W := n
				For k, v in StrSplit(RxMatch[1], " ")
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
					This.Prop.Jeweller := True
				}
			}
			;Generic Props
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: \+" rxNum, &RxMatch) && !This.Prop.IsMap)
			{
				This.Prop.Quality := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Armour: " rxNum, &RxMatch))
			{
				This.Prop.Rating_Armour := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Energy Shield: " rxNum, &RxMatch))
			{
				This.Prop.Rating_EnergyShield := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Evasion Rating: " rxNum, &RxMatch))
			{
				This.Prop.Rating_Evasion := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Chance to Block: " rxNum, &RxMatch))
			{
				This.Prop.Rating_Block := RxMatch[1]
			}

			;Weapon Specific Props
			;Every Weapon has APS
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Attacks per Second: " rxNum, &RxMatch))
			{
				This.Prop.IsWeapon := True
				This.Prop.Weapon_APS := RxMatch[1]
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Two Handed", &RxMatch)){
					This.Prop.IsTwoHanded := True
				}
				Else If (RegExMatch(This.Data.Blocks.Properties, "`am)^Staff", &RxMatch)){
					This.Prop.IsTwoHanded := True
				}
				Else If (RegExMatch(This.Data.Blocks.Properties, "`am)^Bow", &RxMatch)){
					This.Prop.IsTwoHanded := True
				}
				Else
				{
					This.Prop.IsOneHanded := True
				}
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Physical Damage: " rxNum "-" rxNum , &RxMatch))
				{
					This.Prop.Weapon_Avg_Physical_Dmg := Format("{1:0.3g}",(RxMatch[1] + RxMatch[2]) / 2)
					This.Prop.Weapon_Min_Physical_Dmg := RxMatch[1]
					This.Prop.Weapon_Max_Physical_Dmg := RxMatch[2]
				}
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Chaos Damage: " rxNum "-" rxNum , &RxMatch))
				{
					This.Prop.Weapon_Avg_Chaos_Dmg := Format("{1:0.3g}",(RxMatch[1] + RxMatch[2]) / 2)
					This.Prop.Weapon_Min_Chaos_Dmg := RxMatch[1]
					This.Prop.Weapon_Max_Chaos_Dmg := RxMatch[2]
				}
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Elemental Damage: .+", &RxMatch))
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
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Critical Strike Chance: " rxNum, &RxMatch))
				{
					This.Prop.Weapon_Critical_Strike := RxMatch[1]
				}
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Weapon Range: " rxNum, &RxMatch))
				{
					This.Prop.Weapon_Range := RxMatch[1]
				}
				This.Prop.Weapon_DPS_Total := 0
				This.Prop.Weapon_DPS_Total_Q20 := 0
				If (This.Prop.Has("Weapon_Avg_Physical_Dmg"))
					This.Prop.Weapon_DPS_Physical := Round(This.Prop.Weapon_Avg_Physical_Dmg * This.Prop.Weapon_APS,1)
				If (This.Prop.Has("Weapon_Avg_Elemental_Dmg"))
					This.Prop.Weapon_DPS_Elemental := Round(This.Prop.Weapon_Avg_Elemental_Dmg * This.Prop.Weapon_APS,1)
				If (This.Prop.Has("Weapon_Avg_Chaos_Dmg"))
					This.Prop.Weapon_DPS_Chaos := Round(This.Prop.Weapon_Avg_Chaos_Dmg * This.Prop.Weapon_APS,1)
				This.Prop.Weapon_DPS_Total := Round((This.Prop.Weapon_DPS_Physical?This.Prop.Weapon_DPS_Physical:0) + (This.Prop.Weapon_DPS_Elemental?This.Prop.Weapon_DPS_Elemental:0) + (This.Prop.Weapon_DPS_Chaos?This.Prop.Weapon_DPS_Chaos:0),1)
				If ((This.Prop.Quality?This.Prop.Quality:0) < 20 && This.Prop.Has("Weapon_Avg_Physical_Dmg"))
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
		If (RegExMatch(This.Data.Blocks.Properties, "`am)^Map Tier: " rxNum, &RxMatch))
		{
			This.Prop.Map_Tier := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Atlas Region: ([a-zA-Z0-9 ']+)", &RxMatch))
			{
				This.Prop.Map_AtlasRegion := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Quantity: \+" rxNum, &RxMatch))
			{
				This.Prop.Map_Quantity := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Rarity: \+" rxNum, &RxMatch))
			{
				This.Prop.Map_Rarity := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Monster Pack Size: \+" rxNum, &RxMatch))
			{
				This.Prop.Map_PackSize := RxMatch[1]
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Delirium Reward Type:", &RxMatch))
			{
				This.Prop.Map_Delirium := True
			}
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Quality: \+" rxNum, &RxMatch))
			{
				This.Prop.Map_Quality := RxMatch[1]
			}Else{
				;Set Quality to 0 if not in map prop (instead flagging as false)
				This.Prop.Map_Quality := 0
			}
		}
		;End Prop Block Parser for Maps

		; Start Prop Block Parser for Heist
		If indexOf(This.Prop.ItemClass, ["Contracts","Blueprints"]) {
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Heist Target: (.*)", &RxMatch))
				This.Prop.Heist_Target := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Client: (.*)", &RxMatch))
				This.Prop.Heist_Client := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Area Level: " rxNum, &RxMatch))
				This.Prop.Heist_AreaLevel := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Quantity: \+" rxNum, &RxMatch))
				This.Prop.Heist_ItemQuantity := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Item Rarity: \+" rxNum, &RxMatch))
				This.Prop.Heist_ItemRarity := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Alert Level Reduction: \+" rxNum, &RxMatch))
				This.Prop.Heist_AlertLevelReduction := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Time Before Lockdown: \+" rxNum, &RxMatch))
				This.Prop.Heist_TimeBeforeLockdown := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Maximum Alive Reinforcements: \+" rxNum, &RxMatch))
				This.Prop.Heist_MaximumAliveReinforcements := RxMatch[1]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Wings Revealed: " rxNum "/" rxNum, &RxMatch))
				This.Prop.Heist_WingsRevealed := RxMatch[1], This.Prop.Heist_WingsRevealedMax := RxMatch[2]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Escape Routes Revealed: " rxNum "/" rxNum, &RxMatch))
				This.Prop.Heist_EscapeRoutesRevealed := RxMatch[1], This.Prop.Heist_EscapeRoutesRevealedMax := RxMatch[2]
			If (RegExMatch(This.Data.Blocks.Properties, "`am)^Reward Rooms Revealed: " rxNum "/" rxNum, &RxMatch))
				This.Prop.Heist_RewardRoomsRevealed := RxMatch[1], This.Prop.Heist_RewardRoomsRevealedMax := RxMatch[2]
			For k, job in ["Brute Force","Agility","Perception","Demolition","Counter-Thaumaturgy","Trap Disarmament","Deception","Engineering","Lockpicking"] {
				If (RegExMatch(This.Data.Blocks.Properties, "`am)^Requires " job " \(Level " rxNum "( \(unmet\))?\)", &RxMatch)) {
					This.Prop.%"Heist_Requires_" job% := RxMatch[1]
					If (This.Prop.ItemClass == "Contracts"){
						This.Prop.Heist_Contract_Type := job
					}
				}

			}
		}
		; End Prop Block Parser for Heist
		;Start Prop Block Parser for Gems
		If (This.Prop.RarityGem)
		{
			If (This.Prop.Corrupted) {
				If (RegExMatch(This.Data.Blocks.Properties, "`am)Vaal", &RxMatch))
				{
					This.Prop.VaalGem := True
					This.Prop.ItemName := "Vaal " . This.Prop.ItemName
				}
			}
			If (RegExMatch(This.Prop.ItemBase, "(^Divergent|^Phantasmal|^Anomalous)", &RxMatch))
				This.Prop.Gem_AltQuality := RxMatch[1]
			If (This.Prop.ItemBase ~= "^Awakened")
				This.Prop.Gem_Awakened := True
			If (This.Prop.Gem_Tags ~= "Exceptional")
				This.Prop.Gem_Exceptional := True
		}
		;End Prop Block Parser for Vaal Gems

		If (This.Affix.Get("Veiled Prefix", 0) || This.Affix.Get("Veiled Suffix", 0))
		{
			This.Prop.Veiled := True
			This.Prop.SpecialType := "Veiled Item"
			For k, v in This.Modifier {
				If RegExMatch(k, "(.*) Veiled", &rxm) {
					This.Prop.VeiledType := rxm[1]
					Break
				}
			}
		}
		Else
		{
			This.Prop.Veiled := False
		}
		; Call MapCraft Logic
		This.MapCraftItemLogic()
		If (This.MatchCraftingItemMods()) {
			; Flags for Item Crafting
			This.Prop.ItemCraftingHit := True
		}
		;Stack size for anything with it
		If (RegExMatch(This.Data.Blocks.Properties, "`am)^Stack Size: (\d.*)\/(\d.*)" , &RxMatch))
		{
			This.Prop.Stack_Size := RegExReplace(RxMatch[1],"[^\d]","")
			This.Prop.Stack_Max := RegExReplace(RxMatch[2],"[^\d]","")
		}
		If (This.Data.Blocks.FlavorText ~= "[into] the Sacred Grove")
			This.Prop.SpecialType := "Harvest Item"
		If (This.Data.Blocks.FlavorText ~= "Ritual Altar" || This.Data.Blocks.FlavorText ~= "Ritual Vessel")
			This.Prop.SpecialType := "Ritual Item", This.Prop.Ritual := True
		;Actual Tier
		This.CreateAllActualTiers()

	}
	MapCraftItemLogic()
	{
		If(!This.Prop.IsMap){
			Return
		}
		This.Prop.MapSumWeightGoodMod := 0
		This.Prop.MapSumWeightBadMod := 0
		For k, v in WR.CustomMapMods.MapMods{
			if(This.Affix.Has(v["Map Affix"]))
			{
				if(v["Mod Type"] == "Impossible"){
					This.Prop.MapImpossibleMod := True
					;Set Flag to Reroll
					This.Prop.MapRerollFlag := True
				}else if(v["Mod Type"] == "Good"){
					This.Prop.MapSumWeightGoodMod += v["Weight"]
				}else if(v["Mod Type"] == "Bad"){
					This.Prop.MapSumWeightBadMod += v["Weight"]
				}
			}
		}
		This.Prop.MapSumMod := This.Prop.MapSumWeightGoodMod - This.Prop.MapSumWeightBadMod
		;Check if MapSum > Minimum Weight Settings
		ConsiderMMQ := (This.Prop.RarityMagic && EnableMQQForMagicMap) || This.Prop.RarityRare
		If (ConsiderMMQ) {
			MeetsMMQ := This.Prop.Map_Rarity >= MMapItemRarity && This.Prop.Map_PackSize >= MMapMonsterPackSize && This.Prop.Map_Quantity >= MMapItemQuantity
		} Else {
			MeetsMMQ := True
		}
		MeetsWeight := This.Prop.MapSumMod >= MMapWeight
		GoodEnough := (!MMQorWeight && MeetsWeight && MeetsMMQ) || (MMQorWeight && (MeetsWeight || MeetsMMQ))
		If (GoodEnough && !This.Prop.MapImpossibleMod) {
			This.Prop.MapKeepFlag := True
		} Else {
			This.Prop.MapRerollFlag := True
		}
		If (This.Prop.Corrupted && (YesMapUnid && !This.Affix.Has("Unidentified") || !YesMapUnid) && !This.Prop.RarityUnique && (!GoodEnough || This.Prop.MapImpossibleMod)){
			This.Prop.IsBrickedMap := True
		}
	}
	MatchCraftingItemMods() {
		local preMatch, sufMatch, SumRNP, SumRNS, LastID, SumCombination
		This.Prop.CraftingMatchedPrefix := 0
		This.Prop.CraftingMatchedSuffix := 0
		SumRNP := 0
		SumRNS := 0
		LastID :=0
		For k, v in WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector]
		{
			If(This.Affix.Get(v["ModWRFormat"], 0) >= v["ValueWRFormatLow"] && This.Affix.Get(v["ModWRFormat"], 0) <= v["ValueWRFormatHigh"] && This.Affix.Has(v["Affix"]))
			{
				If(v["ModGenerationType"] == "Prefix"){
					If(v["RNMod"] > 1){
						If(v["ID"] != LastID){
							SumRNP := 1
						}Else If(SumRNP == (v["RNMod"] - 1)){
							This.Prop.CraftingMatchedPrefix++
							SumRNP := 0
						}Else{
							SumRNP++
						}
					}Else{
						SumRNP := 0
						This.Prop.CraftingMatchedPrefix++
					}
				}
				Else If(v["ModGenerationType"] == "Suffix"){
					If(v["RNMod"] > 1){
						If(v["ID"] != LastID){
							SumRNS := 1
						}Else If(SumRNS == (v["RNMod"] - 1)){
							This.Prop.CraftingMatchedSuffix++
							SumRNS := 0
						}Else{
							SumRNS++
						}
					}Else{
						SumRNS := 0
						This.Prop.CraftingMatchedSuffix++
					}
				}
			}
			LastID := v["ID"]
		}
		SumCombination := This.Prop.CraftingMatchedPrefix + This.Prop.CraftingMatchedSuffix

		if (ItemCraftingNumberCombination > 0) {
			return SumCombination >= ItemCraftingNumberCombination
		} else if (ItemCraftingNumberPrefix > 0 || ItemCraftingNumberSuffix > 0) {
			if (ItemCraftingNumberPrefix > 0) {
				preMatch := This.Prop.CraftingMatchedPrefix >= ItemCraftingNumberPrefix
			} else {
				preMatch := true
			}
			if (ItemCraftingNumberSuffix > 0) {
				sufMatch := This.Prop.CraftingMatchedSuffix >= ItemCraftingNumberSuffix
			} else {
				sufMatch := true
			}
			return preMatch && sufMatch
		}
	}
	CreateAllActualTiers()
	{
		for a , b in WR.ActualTier.%This.Prop.ItemClass%
		{
			ILvLList := b["ILvL"]
			AffixList := b["AffixLine"]
			Name := b["ActualTierName"]
			AffixWRLine := StrSplit(b["AffixWRLine"], " | ")
			if(AffixWRLine.Length > 1){
				AffixWRLine[1] := "(Hybrid) " . AffixWRLine[1]
			}
			If(!This.Affix.Has(AffixWRLine[1]))
			{
				Continue
			}
			for k,v in ILvLList
			{
				if ((This.Prop.ItemLevel >= v && This.Prop.ItemLevel < ILvLList[k+1]) || k == ILvLList.Length())
				{
					for ki,vi in AffixList
					{
						If (This.HasAffix(vi)){
							value := k-ki+1
							This.Prop.%Name% := value
							if(AffixWRLine[1] == This.Prop.FracturedModKey){
								Name := "Fractured" . Name
								This.Prop.%Name% := value
								This.Prop.FracturedActualTier := value
							}
							break
						}
					}
					break
				}
			}
		}
	}
	HasModifierFromList(ModList){
		for k,v in ModList{
			if (This.Affix.Has(v)){
				return true
			}
		}
		return false
	}
	HasAffix(Name){
		local Type, Obj, k, v
		For Type, Obj in This.Data.AffixNames {
			For k, v in Obj {
				If (v.Name == Name)
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
		If (This.Prop.Rarity_Digit == 3 && This.Prop.SlotType != "" )
		{
			If (This.Prop.ItemLevel >= 60 && This.Prop.ItemLevel <= 74 && (ChaosRecipeTypePure || ChaosRecipeTypeHybrid))
				This.Prop.ChaosRecipe := 1
			Else If (This.Prop.ItemLevel >= 75 && This.Prop.ItemLevel <= 100 && (ChaosRecipeTypeRegal || ChaosRecipeTypeHybrid))
				This.Prop.RegalRecipe := 1
		}
	}
	StashChaosRecipe(deposit:=false){
		Global RecipeMap
		Static TypeList := [ "Amulet", "Ring", "Belt", "Boots", "Gloves", "Helmet", "Body" ]
		Static WeaponList := [ "One Hand", "Two Hand", "Shield" ]
		If ( This.Prop.Rarity_Digit != 3 )
			|| ( This.Prop.ItemLevel < 60 )
			|| !( This.Prop.SlotType )
			|| ( ChaosRecipeTypePure && This.Prop.ItemLevel > 74)
			|| ( ChaosRecipeTypeRegal && This.Prop.ItemLevel < 75 )
			|| ( ChaosRecipeSmallWeapons && (This.Prop.IsWeapon || This.Prop.ItemClass == "Shields")
			&& (( This.Prop.Item_Width > 1 && This.Prop.Item_Height > 2) || ( This.Prop.Item_Width == 1 && This.Prop.Item_Height > 3))
			&& !(This.Prop.IsTwoHanded && This.Prop.Item_Width == 2 && This.Prop.Item_Height == 3) )
			Return False
		If (ChaosRecipeSkipJC && (This.Prop.Jeweller || This.Prop.Chromatic))
			Return False
		If !IsObject(RecipeMap)
		{
			If !ChaosRecipe(1)
			{
				Notify("Error","Requesting stash information Failed`nCheck your POESESSID",3)
				Return False
			}
		}
		For k, v in TypeList
		{
			If (This.Prop.SlotType == v)
			{
				If This.Affix.Has("Unidentified") {
					CountValue := retCount(RecipeMap["uChaos"][v]) + retCount(RecipeMap["uRegal"][v])
					ChaosRecipeMaxHolding := ChaosRecipeMaxHoldingUNID
				} Else {
					CountValue := retCount(RecipeMap["Chaos"][v]) + retCount(RecipeMap["Regal"][v])
					ChaosRecipeMaxHolding := ChaosRecipeMaxHoldingID
				}
				If (v == "Ring")
					CountValue := CountValue / 2
				If (ChaosRecipeAllowDoubleJewellery && IndexOf(v,["Ring","Amulet"]))
					CountValue := CountValue / 2
				If (ChaosRecipeAllowDoubleBelt && IndexOf(v,["Belt"]))
					CountValue := CountValue / 2

				If (CountValue < ChaosRecipeMaxHolding)
				{
					If (OnStash && deposit)
					{
						If This.Affix.Has("Unidentified")
						{
							If This.Prop.ChaosRecipe
								RecipeMap["uChaos"][v].Push(This)
							Else If This.Prop.RegalRecipe
								RecipeMap["uRegal"][v].Push(This)
							Else
								Return False
						} Else {
							If This.Prop.ChaosRecipe
								RecipeMap["Chaos"][v].Push(This)
							Else If This.Prop.RegalRecipe
								RecipeMap["Regal"][v].Push(This)
							Else
								Return False
						}
					}
					Return True
				}
				Else
					Return False
			}
		}
		For k, v in WeaponList
		{
			If (This.Prop.SlotType == v)
			{
				If This.Affix.Has("Unidentified"){
					WeaponCount := retCount(RecipeMap["uRegal"]["Two Hand"]) + retCount(RecipeMap["uChaos"]["Two Hand"])
					WeaponCount += (retCount(RecipeMap["uRegal"]["One Hand"]) + retCount(RecipeMap["uChaos"]["One Hand"])) / 2
					WeaponCount += (retCount(RecipeMap["uRegal"]["Shield"]) + retCount(RecipeMap["uChaos"]["Shield"])) / 2
					ChaosRecipeMaxHolding := ChaosRecipeMaxHoldingUNID
				}Else{
					WeaponCount := retCount(RecipeMap["Regal"]["Two Hand"]) + retCount(RecipeMap["Chaos"]["Two Hand"])
					WeaponCount += (retCount(RecipeMap["Regal"]["One Hand"]) + retCount(RecipeMap["Chaos"]["One Hand"])) / 2
					WeaponCount += (retCount(RecipeMap["Regal"]["Shield"]) + retCount(RecipeMap["Chaos"]["Shield"])) / 2
					ChaosRecipeMaxHolding := ChaosRecipeMaxHoldingID
				}
				If (WeaponCount < ChaosRecipeMaxHolding)
				{
					If (OnStash && deposit)
					{
						If This.Affix.Has("Unidentified")
						{
							If This.Prop.ChaosRecipe
								RecipeMap["uChaos"][v].Push(This)
							Else If This.Prop.RegalRecipe
								RecipeMap["uRegal"][v].Push(This)
						} Else {
							If This.Prop.ChaosRecipe
								RecipeMap["Chaos"][v].Push(This)
							Else If This.Prop.RegalRecipe
								RecipeMap["Regal"][v].Push(This)
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
		; Remove the extra line created by "additional information bubbles"
		content := RegExReplace(content,"\n? ?\(\w+ \w+ [\w\d\.\% ,'\+\-]+\)( \(implicit\))?( \(enchant\))?", "")
		; Do Stuff with info
		LastLine := ""
		DoubleModCounter := 0
		Loop Parse, content, "`r`n" ; , `r
		{
			If (A_LoopField == "" || A_LoopField ~= "^\{ .* \}$")
			{
				DoubleModCounter := 0
				Continue
			}
			DoubleModCounter++
			if(DoubleModCounter == 2){
				If (vals := This.MatchLine(LastLine))
				{

					If (vals.Length == 1 && This.CheckIfActualHybridMod(key))
					{
						If This.Affix.Has(key)
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
			line := RegExReplace(A_LoopField, rxNum "\(" rxNum "-" rxNum "\)", "$1")
			line := RegExReplace(line, rxNum "\(-" rxNum "--" rxNum "\)", "$1")
			line := RegExReplace(line, " . Unscalable Value" , "")
			;Fix Extra Text from Spell Suppress Mods
			line := RegExReplace(line, "\(50% of Damage from Suppressed Hits and Ailments they inflict is prevented\)", "")
			key := This.Standardize(line)
			If (vals := This.MatchLine(line))
			{
				If (vals.Length >= 2)
				{
					If (line ~= rxNum " to " rxNum || line ~= rxNum "-" rxNum)
						This.Affix[key] := (Format("{1:0.3g}",(vals[1] + vals[2]) / 2))
					Else
						This.Affix[key] := vals[1]
					For k, v in vals
						This.Affix[ key "_value" k ] := v
				}
				Else If (vals.Length == 1)
				{
					If (This.Affix.Has(key) && DoubleModCounter != 2)
					{
						This.Affix[key] += vals[1]
					}Else If(DoubleModCounter != 2){
						This.Affix[key] := vals[1]
					}Else{
						This.AddHybridModAffix(key,vals[1])
					}
				}
			}
			Else{
				If(key == "")
					Continue
				Else
					This.Affix[key] := True
			}
			LastLine := line

			If (A_LoopField ~= rxNum "\(-*" rxNum "-*" rxNum "\)") {
				EndValue := 0
				Position := 1
				While RegExMatch(A_LoopField, "`am)" rxNum "\(-*" rxNum "-*" rxNum "\)", &RxMatch, Position) {
					Position := RxMatch.Len(0) + RxMatch.Pos(0)
					Value := RxMatch.Value(1)
					Range1 := RxMatch.Value(2)
					Range2 := RxMatch.Value(3)
					Perc := This.perc(Value,[Range1,Range2])
					EndEntries := A_Index
					EndValue += Perc
				}
				EndValue := EndValue / EndEntries
				If !This.Percent.Has(Key)
					This.Percent.%key% := EndValue
				Else {
					Loop {
						If !This.Percent.Has(Key A_Index + 1){
							This.Percent[Key A_Index + 1] := EndValue
							Break
						}
					}
				}
				This.Prop.HasRange := True
			}
		}
		If This.Percent.Length {
			This.Prop.PercentageAffix := 0
			For mod, val in This.Percent {
				This.Prop.PercentageAffix += val
			}
			This.Prop.PercentageAffix := Round(This.Prop.PercentageAffix / This.Percent.Length,2)
		} Else {
			This.Prop.PercentageAffix := 100
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
		If(!This.Affix.Has(HybridKey))
		{
			aux := Value
			If (aux != 0)
				This.Affix[HybridKey] := aux
		}Else
		{
			aux := This.GetValue("Affix", HybridKey) + Value
			If (aux != 0)
				This.Affix[HybridKey] := aux
		}
		return
	}
	MatchAffixes(content:=""){
		; Remove the extra line created by "additional information bubbles"
		content := RegExReplace(content,"\n? ?\(\w+ \w+ [\r\n\w\%\d,\: ]*\)( \(implicit\))?( \(enchant\))?", "")
		; Do Stuff with info
		Loop Parse, content, "`r`n" ; , `r
		{
			If (A_LoopField == "" || A_LoopField ~= "^\{ .* \}$")
				Continue
			line := RegExReplace(A_LoopField, rxNum "\(" rxNum "-" rxNum "\)", "$1")
			line := RegExReplace(line, rxNum "\(-" rxNum "--" rxNum "\)", "$1")
			line := RegExReplace(line, " . Unscalable Value" , "")
			key := This.Standardize(line)
			If (key ~= "^ \(.*\)$")
				Continue
			If (vals := This.MatchLine(line))
			{
				If (vals.Length >= 2)
				{
					If (line ~= rxNum " to " rxNum || line ~= rxNum "-" rxNum)
						This.Affix[key] := (Format("{1:0.3g}",(vals[1] + vals[2]) / 2))
					Else
						This.Affix[key] := vals[1]
					For k, v in vals
						This.Affix[ key "_value" k ] := v
				}
				Else If (vals.Length == 1)
				{
					If This.Affix.Has(key)
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
		If (RegExMatch(lineString, "`am)" rxNum "[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" rxNum "{0,}[ \-a-zA-Z+,\%]{0,}+" , &RxMatch))
		{
			ret := {}
			Loop RxMatch.Length
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
		str := RegExReplace(str, "\+?" rxNum , "#")
		; str := RegExReplace(str, "#\(#-#\)" , "#")
		str := RegExReplace(str, " (augmented)" , "")
		If (str ~= "\(fractured\)") {
			str := RegexReplace(str, " \(fractured\)", "")
			This.Prop.FracturedModKey := str
		}
		Return str
	}
	MatchPseudoAffix(){
		for k, v in This.Affix
		{
			; Standardize implicit and crafted for Pseudo sums
			; Implicits can be disable being merge into Pseudos checking YesCLFIgnoreImplicit
			If (RegExMatch(k, "`am) \((.*)\)$", &RxMatch) && YesCLFIgnoreImplicit)
			{
				If (RxMatch[1] != "crafted")
				{
					Continue
				}
			}
			trimKey := RegExReplace(k," \(.*\)$","")
			; Singular Resistances
			If (trimKey == "# to maximum Life")
			{
				This.AddPseudoAffix("(Pseudo) Total to Maximum Life",k)
			}
			If (trimKey == "#% to Cold Resistance")
			{
				This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
			}
			Else If (trimKey == "#% to Fire Resistance")
			{
				This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
			}
			Else If (trimKey == "#% to Lightning Resistance")
			{
				This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
			}
			Else If (trimKey == "#% to Chaos Resistance")
			{
				This.AddPseudoAffix("(Pseudo) Total to Chaos Resistance",k)
			}
			; Double Resistances
			Else If (trimKey == "#% to Cold and Lightning Resistances")
			{
				This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
				This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
			}
			Else If (trimKey == "#% to Fire and Cold Resistances")
			{
				This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
				This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
			}
			Else If (trimKey == "#% to Fire and Lightning Resistances")
			{
				This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
				This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
			}
			; All Resistances
			Else If (trimKey == "#% to all Elemental Resistances")
			{
				This.AddPseudoAffix("(Pseudo) Total to Fire Resistance",k)
				This.AddPseudoAffix("(Pseudo) Total to Lightning Resistance",k)
				This.AddPseudoAffix("(Pseudo) Total to Cold Resistance",k)
			}
			; Attributes Singular
			Else If (trimKey == "# to Intelligence")
			{
				This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
			}
			Else If (trimKey == "# to Dexterity")
			{
				This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
			}
			Else If (trimKey == "# to Strength")
			{
				This.AddPseudoAffix("(Pseudo) Total to Strength",k)
			}
			; Double Atributes
			Else If (trimKey == "# to Strength and Dexterity")
			{
				This.AddPseudoAffix("(Pseudo) Total to Strength",k)
				This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
			}
			Else If (trimKey == "# to Dexterity and Intelligence")
			{
				This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
				This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
			}
			Else If (trimKey == "# to Strength and Intelligence")
			{
				This.AddPseudoAffix("(Pseudo) Total to Strength",k)
				This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
			}
			; All Atribbutes
			Else If (trimKey == "# to all Attributes")
			{
				This.AddPseudoAffix("(Pseudo) Total to Strength",k)
				This.AddPseudoAffix("(Pseudo) Total to Intelligence",k)
				This.AddPseudoAffix("(Pseudo) Total to Dexterity",k)
			}
			; Singular Armour Affix
			Else If (trimKey == "#% increased Armour")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
			}
			Else If (trimKey == "#% increased Evasion Rating")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
			}
			Else If (trimKey == "#% increased Energy Shield")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
			}
			Else If (trimKey == "#% to maximum Energy Shield")
			{
				This.AddPseudoAffix("(Pseudo) Total to Maximum Energy Shield",k)
			}
			; Double Armour Affix
			Else If (trimKey == "#% increased Evasion and Energy Shield")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
				This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
			}
			Else If (trimKey == "#% increased Armour and Energy Shield")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
				This.AddPseudoAffix("(Pseudo) Total Increased Energy Shield",k)
			}
			Else If (trimKey == "#% increased Armour and Evasion")
			{
				This.AddPseudoAffix("(Pseudo) Total Increased Armour",k)
				This.AddPseudoAffix("(Pseudo) Total Increased Evasion",k)
			}
			; Damage Mods
			Else If (trimKey == "Adds # to # Physical Damage to Attacks")
			{
				This.AddPseudoAffix("(Pseudo) Add Physical Damage to Attacks",k)
			}
			Else If (trimKey == "Adds # to # Physical Damage to Spells")
			{
				This.AddPseudoAffix("(Pseudo) Add Physical Damage to Spells",k)
			}
			Else If (trimKey == "Adds # to # Cold Damage to Attacks")
			{
				This.AddPseudoAffix("(Pseudo) Add Cold Damage to Attacks",k)
			}
			Else If (trimKey == "Adds # to # Cold Damage to Spells")
			{
				This.AddPseudoAffix("(Pseudo) Add Cold Damage to Spells",k)
			}
			Else If (trimKey == "Adds # to # Fire Damage to Attacks")
			{
				This.AddPseudoAffix("(Pseudo) Add Fire Damage to Attacks",k)
			}
			Else If (trimKey == "Adds # to # Fire Damage to Spells")
			{
				This.AddPseudoAffix("(Pseudo) Add Fire Damage to Spells",k)
			}
			Else If (trimKey == "Adds # to # Lightning Damage to Attacks")
			{
				This.AddPseudoAffix("(Pseudo) Add Lightning Damage to Attacks",k)
			}
			Else If (trimKey == "Adds # to # Lightning Damage to Spells")
			{
				This.AddPseudoAffix("(Pseudo) Add Lightning Damage to Spells",k)
			}
			Else If (trimKey == "Adds # to # Chaos Damage to Attacks")
			{
				This.AddPseudoAffix("(Pseudo) Add Chaos Damage to Attacks",k)
			}
			Else If (trimKey == "Adds # to # Chaos Damage to Spells")
			{
				This.AddPseudoAffix("(Pseudo) Add Chaos Damage to Spells",k)
			}
			; Spell Pseudo
			Else If (trimKey == "#% increased Lightning Damage")
			{
				This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
			}
			Else If (trimKey == "#% increased Cold Damage")
			{
				This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
			}
			Else If (trimKey == "#% increased Fire Damage")
			{
				This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
			}
			Else If (trimKey == "#% increased Chaos Damage")
			{
				This.AddPseudoAffix("(Pseudo) Increased Chaos Damage",k)
			}
			Else If (trimKey == "#% increased Spell Damage")
			{
				This.AddPseudoAffix("(Pseudo) Increased Lightning Damage",k)
				This.AddPseudoAffix("(Pseudo) Increased Cold Damage",k)
				This.AddPseudoAffix("(Pseudo) Increased Fire Damage",k)
				This.AddPseudoAffix("(Pseudo) Increased Chaos Damage",k)
				This.AddPseudoAffix("(Pseudo) Increased Spell Damage",k)
			}
			Else If (trimKey == "#% increased Elemental Damage")
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
		If (aux != 0)
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
		This.DeleteProp("Pseudo")
	}
	FuckingSugoiFreeMate(){
		This.Data := ""
		This.DeleteProp("Data")
	}
	MatchExtenalDB(){
		For k, v in QuestItems
		{
			If (k == This.Prop.ItemName)
			{
				This.Prop.Item_Width := v["inventory_width"]
				This.Prop.Item_Height := v["inventory_height"]
				This.Prop.SpecialType := "Quest Item"
				Return
			}
		}
		If (!This.Prop.IsMap)
		{
			For k, v in BasesWR
			{
				for a, b in v{
					If (a == This.Prop.ItemBase)
					{
						This.Prop.Item_Width := b["inventory_width"]
						This.Prop.Item_Height := b["inventory_height"]
						This.Prop.ItemBase := a
						This.Prop.DropLevel := b["drop_level"]

						If (This.Prop.Rating_Armour || This.Prop.Rating_EnergyShield || This.Prop.Rating_Evasion){
							tally := total := 0
							If This.Prop.Rating_Armour {
								tally++
								val := This.Perc(This.Prop.Rating_Armour,[b.properties.armour.min,b.properties.armour.max])
								total += val
								This.Prop.Rating_Armour_Percent := round(val,2)
							}
							If This.Prop.Rating_EnergyShield {
								tally++
								val := This.Perc(This.Prop.Rating_EnergyShield,[b.properties.energy_shield.min,b.properties.energy_shield.max])
								total += val
								This.Prop.Rating_EnergyShield_Percent := round(val,2)
							}
							If This.Prop.Rating_Evasion {
								tally++
								val := This.Perc(This.Prop.Rating_Evasion,[b.properties.evasion.min,b.properties.evasion.max])
								total += val
								This.Prop.Rating_Evasion_Percent := round(val,2)
							}
							This.Prop.Rating_Percent := round(total/tally,2)
							tally := total := val := ""
						}

						If InStr(This.Prop.ItemClass, "Rings")
							This.Prop.Ring := True
						If InStr(This.Prop.ItemClass, "Amulets")
							This.Prop.Amulet := True
						If InStr(This.Prop.ItemClass, "Belts")
							This.Prop.Belt := True
						If (This.Prop.ItemClass == "Support Skill Gems")
							This.Prop.Support := True
						Break 2
					}
				}
			}
			If (!This.Prop.Item_Height || !This.Prop.Item_Width) {
				If (This.Prop.ItemClass ~= "Amulets|Rings") {
					This.Prop.Item_Width := 1
					This.Prop.Item_Height := 1
				} Else If (This.Prop.ItemClass ~= "Belts") {
					This.Prop.Item_Width := 2
					This.Prop.Item_Height := 1
				} Else If (This.Prop.ItemClass ~= "Thrusting") {
					This.Prop.Item_Width := 1
					This.Prop.Item_Height := 4
				} Else If (This.Prop.ItemClass ~= "Body Armours|Quivers|One Hand|Sceptres") {
					This.Prop.Item_Width := 2
					This.Prop.Item_Height := 3
				} Else If (This.Prop.ItemClass ~= "Boots|Gloves|Helmets|Claws") {
					This.Prop.Item_Width := 2
					This.Prop.Item_Height := 2
				} Else If (This.Prop.ItemClass ~= "Warstaffs|Staffs|Two Hand|Bows") {
					This.Prop.Item_Width := 2
					This.Prop.Item_Height := 4
				} Else If (This.Prop.ItemClass ~= "Daggers|Wands") {
					This.Prop.Item_Width := 1
					This.Prop.Item_Height := 3
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
			Else If (This.Prop.IsOmen)
			{
				If This.MatchNinjaDB("Omen")
					Return
			}
			Else If (This.Prop.IsTattoo)
			{
				If This.MatchNinjaDB("Tattoo")
					Return
			}
			Else If (This.Prop.IsInvitation)
			{
				If This.MatchNinjaDB("Invitation")
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
		If (This.Prop.TimelessSplinter || This.Prop.TimelessEmblem || This.Prop.BreachSplinter || This.Prop.Offering || This.Prop.Vessel || This.Prop.Scarab || This.Prop.SacrificeFragment || This.Prop.MortalFragment || This.Prop.GuardianFragment || This.Prop.ProphecyFragment || This.Prop.ConquererFragment || This.Prop.ItemName ~= "Simulacrum")
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
		If (This.Prop.ItemClass ~= "Helmets" && This.Data.Blocks.Has("Enchant"))
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
			keyToUse := This.Prop.IsBlightedMap ? "BlightedMap"
				: This.Prop.IsBlightRavagedMap ? "BlightRavagedMap"
				: "Map"
			If This.MatchNinjaDB(keyToUse,"ItemBase","name")
				Return
		}
		If (This.Prop.IsInvitation)
		{
			If This.MatchNinjaDB("Invitation")
				Return
		}
		If (This.Prop.IsMemory)
		{
			If This.MatchNinjaDB("Memory")
				Return
		}
		If (This.Prop.ClusterJewel)
		{
			For k, v in Ninja.ClusterJewel
			{
				If (This.Prop.ClusterKey == v["name"]
					&& This.Prop.ClusterVariant == v["variant"]
					&& This.Prop.ItemLevel >= v["levelRequired"])
				{
					This.Prop.ChaosValue := v["chaosValue"]
					This.Prop.ExaltValue := v["exaltedValue"]
					Break
				}
			}
			Return
		}
		If (This.Prop.IsRune)
		{
			If This.MatchNinjaDB("KalguuranRune")
				Return
		}
		If (This.Prop.ItemLevel >= 82 && This.Prop.Influence != "" && !This.Prop.RarityUnique)
		{
			For k, v in Ninja.BaseType
			{
				If (This.Prop.ItemBase == v["name"]
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
			If (This.Prop.%MatchKey% == v[NinjaKey])
			{
				If (ApiStr ~= "Map"
					&& This.Prop.Map_Tier < v["mapTier"])
					Continue
				If (v["links"]
					&& ApiStr ~= "Unique"
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
		Global ItemInfoGui
		propText:=statText:=affixText:=modifierText:=""
		For key, value in This.Prop.OwnProps()
		{
			If( RegExMatch(key, "^Required")
				|| RegExMatch(key, "^Rating")
				|| RegExMatch(key, "^Sockets")
				|| RegExMatch(key, "^Gem")
				|| RegExMatch(key, "^Quality")
				|| RegExMatch(key, "^Map")
				|| RegExMatch(key, "^Heist_")
				|| RegExMatch(key, "^Stack")
				|| RegExMatch(key, "^Weapon"))
			{
				If indexOf(key,this.MatchedCLF)
					statText .= "CLF⭐"
				statText .= key . ": " . value . "`n"
			}
			Else
			{
				If indexOf(key,this.MatchedCLF)
					propText .= "CLF⭐"
				propText .= key . ": " . value . "`n"
			}
		}

		ItemInfoGui["ItemInfoPropText"].Value := propText

		ItemInfoGui["ItemInfoStatText"].Value := statText

		For key, value in This.Affix
		{
			If(!This.Modifier[key]){
				If (value != 0 && value != "" && value != False){
					If indexOf(key,this.MatchedCLF){
						affixText .= "CLF⭐"
					}
					affixText .= key . ": " . value . "`n"
				}
			}Else{
				If indexOf(key,this.MatchedCLF){
					modifierText .= "CLF⭐"
				}
				modifierText .= key . ": " . value . "`n"
			}
		}
		ItemInfoGui["ItemInfoAffixText"].Value := affixText

		ItemInfoGui["ItemInfoModifierText"].Value := modifierText

	}
	GraphNinjaPrices(){
		Global ItemInfoGui
		If This.Data.Has("Ninja") || This.Data.Has("HelmNinja") || This.Data.Has("BaseNinja")
		{
			_GoSub_ShowGraph()
			ItemInfoGui.Title := This.Prop.ItemName " Sparkline"
			ItemInfoGui.Show("AutoSize")
		}
		Else
		{
			_GoSub_noDataGraph()  ; TODO: convert GoSub label to function call
			_GoSub_HideGraph()  ; TODO: convert GoSub label to function call
			ItemInfoGui.Title := This.Prop.ItemName " has no Graph Data" (This.Prop.IsMap?" for this Tier":"")
			ItemInfoGui.Show("AutoSize")
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
			If (basePayPoint == 0)
				FormatStr := "{1:0.0f}"
			Else If basePayPoint < 1
				FormatStr := "{1:0.3f}"
			Else If basePayPoint < 10
				FormatStr := "{1:0.2f}"
			Else If basePayPoint < 100
				FormatStr := "{1:0.1f}"
			Else If basePayPoint > 100
				FormatStr := "{1:0.0f}"

			ItemInfoGui["PercentText1G1"].Value := Format(FormatStr,(basePayPoint*1.0)) "`%"
			ItemInfoGui["PercentText1G2"].Value := Format(FormatStr,(basePayPoint*0.9)) "`%"
			ItemInfoGui["PercentText1G3"].Value := Format(FormatStr,(basePayPoint*0.8)) "`%"
			ItemInfoGui["PercentText1G4"].Value := Format(FormatStr,(basePayPoint*0.7)) "`%"
			ItemInfoGui["PercentText1G5"].Value := Format(FormatStr,(basePayPoint*0.6)) "`%"
			ItemInfoGui["PercentText1G6"].Value := Format(FormatStr,(basePayPoint*0.5)) "`%"
			ItemInfoGui["PercentText1G7"].Value := Format(FormatStr,(basePayPoint*0.4)) "`%"
			ItemInfoGui["PercentText1G8"].Value := Format(FormatStr,(basePayPoint*0.3)) "`%"
			ItemInfoGui["PercentText1G9"].Value := Format(FormatStr,(basePayPoint*0.2)) "`%"
			ItemInfoGui["PercentText1G10"].Value := Format(FormatStr,(basePayPoint*0.1)) "`%"
			ItemInfoGui["PercentText1G11"].Value := "0`%"
			ItemInfoGui["PercentText1G12"].Value := Format(FormatStr,-(basePayPoint*0.1)) "`%"
			ItemInfoGui["PercentText1G13"].Value := Format(FormatStr,-(basePayPoint*0.2)) "`%"
			ItemInfoGui["PercentText1G14"].Value := Format(FormatStr,-(basePayPoint*0.3)) "`%"
			ItemInfoGui["PercentText1G15"].Value := Format(FormatStr,-(basePayPoint*0.4)) "`%"
			ItemInfoGui["PercentText1G16"].Value := Format(FormatStr,-(basePayPoint*0.5)) "`%"
			ItemInfoGui["PercentText1G17"].Value := Format(FormatStr,-(basePayPoint*0.6)) "`%"
			ItemInfoGui["PercentText1G18"].Value := Format(FormatStr,-(basePayPoint*0.7)) "`%"
			ItemInfoGui["PercentText1G19"].Value := Format(FormatStr,-(basePayPoint*0.8)) "`%"
			ItemInfoGui["PercentText1G20"].Value := Format(FormatStr,-(basePayPoint*0.9)) "`%"
			ItemInfoGui["PercentText1G21"].Value := Format(FormatStr,-(basePayPoint*1.0)) "`%"

			baseRecPoint := 0
			For k, v in dataRecPoint
			{
				If Abs(v) > baseRecPoint
					baseRecPoint := Abs(v)
			}
			If (baseRecPoint == 0)
				FormatStr := "{1:0.0f}"
			Else If baseRecPoint < 1
				FormatStr := "{1:0.3f}"
			Else If baseRecPoint < 10
				FormatStr := "{1:0.2f}"
			Else If baseRecPoint < 100
				FormatStr := "{1:0.1f}"
			Else If baseRecPoint > 100
				FormatStr := "{1:0.0f}"

			ItemInfoGui["PercentText2G1"].Value := Format(FormatStr,(baseRecPoint*1.0)) "`%"
			ItemInfoGui["PercentText2G2"].Value := Format(FormatStr,(baseRecPoint*0.9)) "`%"
			ItemInfoGui["PercentText2G3"].Value := Format(FormatStr,(baseRecPoint*0.8)) "`%"
			ItemInfoGui["PercentText2G4"].Value := Format(FormatStr,(baseRecPoint*0.7)) "`%"
			ItemInfoGui["PercentText2G5"].Value := Format(FormatStr,(baseRecPoint*0.6)) "`%"
			ItemInfoGui["PercentText2G6"].Value := Format(FormatStr,(baseRecPoint*0.5)) "`%"
			ItemInfoGui["PercentText2G7"].Value := Format(FormatStr,(baseRecPoint*0.4)) "`%"
			ItemInfoGui["PercentText2G8"].Value := Format(FormatStr,(baseRecPoint*0.3)) "`%"
			ItemInfoGui["PercentText2G9"].Value := Format(FormatStr,(baseRecPoint*0.2)) "`%"
			ItemInfoGui["PercentText2G10"].Value := Format(FormatStr,(baseRecPoint*0.1)) "`%"
			ItemInfoGui["PercentText2G11"].Value := "0`%"
			ItemInfoGui["PercentText2G12"].Value := Format(FormatStr,-(baseRecPoint*0.1)) "`%"
			ItemInfoGui["PercentText2G13"].Value := Format(FormatStr,-(baseRecPoint*0.2)) "`%"
			ItemInfoGui["PercentText2G14"].Value := Format(FormatStr,-(baseRecPoint*0.3)) "`%"
			ItemInfoGui["PercentText2G15"].Value := Format(FormatStr,-(baseRecPoint*0.4)) "`%"
			ItemInfoGui["PercentText2G16"].Value := Format(FormatStr,-(baseRecPoint*0.5)) "`%"
			ItemInfoGui["PercentText2G17"].Value := Format(FormatStr,-(baseRecPoint*0.6)) "`%"
			ItemInfoGui["PercentText2G18"].Value := Format(FormatStr,-(baseRecPoint*0.7)) "`%"
			ItemInfoGui["PercentText2G19"].Value := Format(FormatStr,-(baseRecPoint*0.8)) "`%"
			ItemInfoGui["PercentText2G20"].Value := Format(FormatStr,-(baseRecPoint*0.9)) "`%"
			ItemInfoGui["PercentText2G21"].Value := Format(FormatStr,-(baseRecPoint*1.0)) "`%"

			AvgPay := Map()
			Loop 5
			{
				AvgPay[A_Index] := (dataPayPoint[A_Index+1] + dataPayPoint[A_Index+2]) / 2
			}
			paddedPayData := Map()
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
			AvgRec := Map()
			Loop 5
			{
				AvgRec[A_Index] := (dataRecPoint[A_Index+1] + dataRecPoint[A_Index+2]) / 2
			}
			paddedRecData := Map()
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

			ItemInfoGui["GroupBox1"].Value := "Sell " This.Prop.ItemName " to Chaos"
			ItemInfoGui["PComment1"].Text := "Sell Value"
			ItemInfoGui["PData1"].Value := sellval := (1 / This.Data.Ninja["pay"]["value"])
			ItemInfoGui["PComment2"].Text := "Sell Value `% Change"
			ItemInfoGui["PData2"].Value := This.Data.Ninja["paySparkLine"]["totalChange"]
			ItemInfoGui["PComment3"].Text := "Orb per Chaos"
			ItemInfoGui["PData3"].Value := This.Data.Ninja["pay"]["value"]
			ItemInfoGui["PComment4"].Text := "Day 6 Change"
			ItemInfoGui["PData4"].Value := dataPayPoint[2]
			ItemInfoGui["PComment5"].Text := "Day 5 Change"
			ItemInfoGui["PData5"].Value := dataPayPoint[3]
			ItemInfoGui["PComment6"].Text := "Day 4 Change"
			ItemInfoGui["PData6"].Value := dataPayPoint[4]
			ItemInfoGui["PComment7"].Text := "Day 3 Change"
			ItemInfoGui["PData7"].Value := dataPayPoint[5]
			ItemInfoGui["PComment8"].Text := "Day 2 Change"
			ItemInfoGui["PData8"].Value := dataPayPoint[6]
			ItemInfoGui["PComment9"].Text := "Day 1 Change"
			ItemInfoGui["PData9"].Value := dataPayPoint[7]
			ItemInfoGui["PComment10"].Value := Decimal2Fraction(sellval,"ID3")
			ItemInfoGui["PData10"].Text := "C / O"

			ItemInfoGui["GroupBox2"].Value := "Buy " This.Prop.ItemName " from Chaos"
			ItemInfoGui["SComment1"].Text := "Buy Value"
			ItemInfoGui["SData1"].Value := sellval := (This.Data.Ninja["receive"]["value"])
			ItemInfoGui["SComment2"].Text := "Buy Value `% Change"
			ItemInfoGui["SData2"].Value := This.Data.Ninja["receiveSparkLine"]["totalChange"]
			ItemInfoGui["SComment3"].Text := "Orb per Chaos"
			ItemInfoGui["SData3"].Value := 1 / This.Data.Ninja["receive"]["value"]
			ItemInfoGui["SComment4"].Text := "Day 6 Change"
			ItemInfoGui["SData4"].Value := dataRecPoint[2]
			ItemInfoGui["SComment5"].Text := "Day 5 Change"
			ItemInfoGui["SData5"].Value := dataRecPoint[3]
			ItemInfoGui["SComment6"].Text := "Day 4 Change"
			ItemInfoGui["SData6"].Value := dataRecPoint[4]
			ItemInfoGui["SComment7"].Text := "Day 3 Change"
			ItemInfoGui["SData7"].Value := dataRecPoint[5]
			ItemInfoGui["SComment8"].Text := "Day 2 Change"
			ItemInfoGui["SData8"].Value := dataRecPoint[6]
			ItemInfoGui["SComment9"].Text := "Day 1 Change"
			ItemInfoGui["SData9"].Value := dataRecPoint[7]
			ItemInfoGui["SComment10"].Value := Decimal2Fraction(sellval,"ID3")
			ItemInfoGui["SData10"].Text := "C / O"

		}
		Else If (This.Data.Ninja["sparkline"] || This.Data.HelmNinja["sparkline"] || This.Data.BaseNinja["sparkline"] )
		{
			LTGraph := HTGraph := True
			If (This.Data.Has("Ninja"))
			{
				HTGraph := "Name"
				dataPoint := This.Data.Ninja["sparkline"]["data"]
				totalChange := This.Data.Ninja["sparkline"]["totalChange"]
			}
			Else
				HTGraph := False

			If (This.Data.Has("HelmNinja") && This.Data.Has("BaseNinja"))
			{
				dataPoint := This.Data.BaseNinja["sparkline"]["data"]
				totalChange := This.Data.BaseNinja["sparkline"]["totalChange"]
				dataLTPoint := This.Data.HelmNinja["sparkline"]["data"]
				totalLTChange := This.Data.HelmNinja["sparkline"]["totalChange"]
				HTGraph := "Base"
				LTGraph := "Helm"
			}
			Else If (This.Data.Has("BaseNinja"))
			{
				dataLTPoint := This.Data.BaseNinja["sparkline"]["data"]
				totalLTChange := This.Data.BaseNinja["sparkline"]["totalChange"]
				LTGraph := "Base"
			}
			Else If (This.Data.Has("HelmNinja"))
			{
				dataLTPoint := This.Data.HelmNinja["sparkline"]["data"]
				totalLTChange := This.Data.HelmNinja["sparkline"]["totalChange"]
				LTGraph := "Helm"
			}
			Else
			{
				LTGraph := False
				_GoSub_noDataGraph2()  ; TODO: convert GoSub label to function call
				_GoSub_noDataGraph2()  ; TODO: convert GoSub label to function call
			}

			If (HTGraph)
			{
				basePoint := 0
				For k, v in dataPoint
				{
					If (Abs(v) > basePoint)
						basePoint := Abs(v)
				}
				If (basePoint == 0)
					FormatStr := "{1:0.0f}"
				Else If basePoint < 1
					FormatStr := "{1:0.3f}"
				Else If basePoint < 10
					FormatStr := "{1:0.2f}"
				Else If basePoint < 100
					FormatStr := "{1:0.1f}"
				Else If basePoint > 100
					FormatStr := "{1:0.0f}"

				ItemInfoGui["PercentText1G1"].Value := Format(FormatStr,(basePoint*1.0)) "`%"
				ItemInfoGui["PercentText1G2"].Value := Format(FormatStr,(basePoint*0.9)) "`%"
				ItemInfoGui["PercentText1G3"].Value := Format(FormatStr,(basePoint*0.8)) "`%"
				ItemInfoGui["PercentText1G4"].Value := Format(FormatStr,(basePoint*0.7)) "`%"
				ItemInfoGui["PercentText1G5"].Value := Format(FormatStr,(basePoint*0.6)) "`%"
				ItemInfoGui["PercentText1G6"].Value := Format(FormatStr,(basePoint*0.5)) "`%"
				ItemInfoGui["PercentText1G7"].Value := Format(FormatStr,(basePoint*0.4)) "`%"
				ItemInfoGui["PercentText1G8"].Value := Format(FormatStr,(basePoint*0.3)) "`%"
				ItemInfoGui["PercentText1G9"].Value := Format(FormatStr,(basePoint*0.2)) "`%"
				ItemInfoGui["PercentText1G10"].Value := Format(FormatStr,(basePoint*0.1)) "`%"
				ItemInfoGui["PercentText1G11"].Value := "0`%"
				ItemInfoGui["PercentText1G12"].Value := Format(FormatStr,-(basePoint*0.1)) "`%"
				ItemInfoGui["PercentText1G13"].Value := Format(FormatStr,-(basePoint*0.2)) "`%"
				ItemInfoGui["PercentText1G14"].Value := Format(FormatStr,-(basePoint*0.3)) "`%"
				ItemInfoGui["PercentText1G15"].Value := Format(FormatStr,-(basePoint*0.4)) "`%"
				ItemInfoGui["PercentText1G16"].Value := Format(FormatStr,-(basePoint*0.5)) "`%"
				ItemInfoGui["PercentText1G17"].Value := Format(FormatStr,-(basePoint*0.6)) "`%"
				ItemInfoGui["PercentText1G18"].Value := Format(FormatStr,-(basePoint*0.7)) "`%"
				ItemInfoGui["PercentText1G19"].Value := Format(FormatStr,-(basePoint*0.8)) "`%"
				ItemInfoGui["PercentText1G20"].Value := Format(FormatStr,-(basePoint*0.9)) "`%"
				ItemInfoGui["PercentText1G21"].Value := Format(FormatStr,-(basePoint*1.0)) "`%"

				Avg := Map()
				Loop 5
				{
					Avg[A_Index] := ((dataPoint[A_Index+1]?dataPoint[A_Index+1]:0) + (dataPoint[A_Index+2]?dataPoint[A_Index+2]:0)) / 2
				}
				paddedData := Map()
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

				ItemInfoGui["GroupBox1"].Value := (HTGraph == "Name"?"Value of " This.Prop.ItemName : (HTGraph == "Base" ? "Value of " This.Prop.ItemBase :"Value Title Undefined") )
				ItemInfoGui["PComment1"].Text := "Chaos Value"
				ItemInfoGui["PData1"].Value := (HTGraph == "Name"?This.Data.Ninja["chaosValue"]:(HTGraph == "Base"?This.Data.BaseNinja["chaosValue"]:""))
				ItemInfoGui["PComment2"].Text := "Exalted Value"
				ItemInfoGui["PData2"].Value := (HTGraph == "Name"?This.Data.Ninja["exaltedValue"]:(HTGraph == "Base"?This.Data.BaseNinja["exaltedValue"]:""))
				ItemInfoGui["PComment3"].Text := "Chaos Value `% Change"
				ItemInfoGui["PData3"].Value := (HTGraph == "Name"?This.Data.Ninja["sparkline"]["totalChange"]:(HTGraph == "Base"?This.Data.BaseNinja["sparkline"]["totalChange"]:""))
				ItemInfoGui["PComment4"].Text := "Day 6 Change"
				ItemInfoGui["PData4"].Value := dataPoint[2]
				ItemInfoGui["PComment5"].Text := "Day 5 Change"
				ItemInfoGui["PData5"].Value := dataPoint[3]
				ItemInfoGui["PComment6"].Text := "Day 4 Change"
				ItemInfoGui["PData6"].Value := dataPoint[4]
				ItemInfoGui["PComment7"].Text := "Day 3 Change"
				ItemInfoGui["PData7"].Value := dataPoint[5]
				ItemInfoGui["PComment8"].Text := "Day 2 Change"
				ItemInfoGui["PData8"].Value := dataPoint[6]
				ItemInfoGui["PComment9"].Text := "Day 1 Change"
				ItemInfoGui["PData9"].Value := dataPoint[7]
				ItemInfoGui["PComment10"].Value := ""
				ItemInfoGui["PData10"].Value := ""
			}
			Else
			{
				_GoSub_noDataGraph1()
				_GoSub_HideGraph1()
			}

			If (LTGraph)
			{
				baseLTPoint := 0
				For k, v in dataLTPoint
				{
					If Abs(v) > baseLTPoint
						baseLTPoint := Abs(v)
				}
				If (baseLTPoint == 0)
					FormatStr := "{1:0.0f}"
				If baseLTPoint < 1
					FormatStr := "{1:0.3f}"
				Else If baseLTPoint < 10
					FormatStr := "{1:0.2f}"
				Else If baseLTPoint < 100
					FormatStr := "{1:0.1f}"
				Else If baseLTPoint > 100
					FormatStr := "{1:0.0f}"

				ItemInfoGui["PercentText2G1"].Value := Format(FormatStr,(baseLTPoint*1.0)) "`%"
				ItemInfoGui["PercentText2G2"].Value := Format(FormatStr,(baseLTPoint*0.9)) "`%"
				ItemInfoGui["PercentText2G3"].Value := Format(FormatStr,(baseLTPoint*0.8)) "`%"
				ItemInfoGui["PercentText2G4"].Value := Format(FormatStr,(baseLTPoint*0.7)) "`%"
				ItemInfoGui["PercentText2G5"].Value := Format(FormatStr,(baseLTPoint*0.6)) "`%"
				ItemInfoGui["PercentText2G6"].Value := Format(FormatStr,(baseLTPoint*0.5)) "`%"
				ItemInfoGui["PercentText2G7"].Value := Format(FormatStr,(baseLTPoint*0.4)) "`%"
				ItemInfoGui["PercentText2G8"].Value := Format(FormatStr,(baseLTPoint*0.3)) "`%"
				ItemInfoGui["PercentText2G9"].Value := Format(FormatStr,(baseLTPoint*0.2)) "`%"
				ItemInfoGui["PercentText2G10"].Value := Format(FormatStr,(baseLTPoint*0.1)) "`%"
				ItemInfoGui["PercentText2G11"].Value := "0`%"
				ItemInfoGui["PercentText2G12"].Value := Format(FormatStr,-(baseLTPoint*0.1)) "`%"
				ItemInfoGui["PercentText2G13"].Value := Format(FormatStr,-(baseLTPoint*0.2)) "`%"
				ItemInfoGui["PercentText2G14"].Value := Format(FormatStr,-(baseLTPoint*0.3)) "`%"
				ItemInfoGui["PercentText2G15"].Value := Format(FormatStr,-(baseLTPoint*0.4)) "`%"
				ItemInfoGui["PercentText2G16"].Value := Format(FormatStr,-(baseLTPoint*0.5)) "`%"
				ItemInfoGui["PercentText2G17"].Value := Format(FormatStr,-(baseLTPoint*0.6)) "`%"
				ItemInfoGui["PercentText2G18"].Value := Format(FormatStr,-(baseLTPoint*0.7)) "`%"
				ItemInfoGui["PercentText2G19"].Value := Format(FormatStr,-(baseLTPoint*0.8)) "`%"
				ItemInfoGui["PercentText2G20"].Value := Format(FormatStr,-(baseLTPoint*0.9)) "`%"
				ItemInfoGui["PercentText2G21"].Value := Format(FormatStr,-(baseLTPoint*1.0)) "`%"

				LTAvg := Map()
				Loop 5
				{
					LTAvg[A_Index] := (dataLTPoint[A_Index+1] + dataLTPoint[A_Index+2]) / 2
				}
				paddedLTData := Map()
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

				ItemInfoGui["GroupBox2"].Value := (LTGraph == "Base"? ("Value of " This.Prop.ItemLevel " " This.Prop.Influence " " This.Prop.ItemBase ) : (LTGraph == "Helm" ? "Value of " This.Data.HelmNinja["name"] : "") )
				ItemInfoGui["SComment1"].Text := "Chaos Value"
				ItemInfoGui["SData1"].Value := (LTGraph == "Base"? This.Data.BaseNinja["chaosValue"] : (LTGraph == "Helm" ? This.Data.HelmNinja["chaosValue"] : "") )
				ItemInfoGui["SComment2"].Value := ""
				ItemInfoGui["SData2"].Value := ""
				ItemInfoGui["SComment3"].Text := "Chaos Value `% Change"
				ItemInfoGui["SData3"].Value := (LTGraph == "Base"? This.Data.BaseNinja["sparkline"]["totalChange"] : (LTGraph == "Helm" ? This.Data.HelmNinja["sparkline"]["totalChange"] : "") )
				ItemInfoGui["SComment4"].Text := "Day 6 Change"
				ItemInfoGui["SData4"].Value := dataLTPoint[2]
				ItemInfoGui["SComment5"].Text := "Day 5 Change"
				ItemInfoGui["SData5"].Value := dataLTPoint[3]
				ItemInfoGui["SComment6"].Text := "Day 4 Change"
				ItemInfoGui["SData6"].Value := dataLTPoint[4]
				ItemInfoGui["SComment7"].Text := "Day 3 Change"
				ItemInfoGui["SData7"].Value := dataLTPoint[5]
				ItemInfoGui["SComment8"].Text := "Day 2 Change"
				ItemInfoGui["SData8"].Value := dataLTPoint[6]
				ItemInfoGui["SComment9"].Text := "Day 1 Change"
				ItemInfoGui["SData9"].Value := dataLTPoint[7]
				ItemInfoGui["SComment10"].Value := ""
				ItemInfoGui["SData10"].Value := ""
			}
			Else
			{
				_GoSub_noDataGraph2()
				_GoSub_HideGraph2()
			}

		}
		Return

		_GoSub_ShowGraph(){
			Loop 2
			{
				aVal := A_Index
				Loop 21
				{
					ItemInfoGui["PercentText" aVal "G" A_Index].Visible := True
				}
				ItemInfoGui["pGraph" aVal].Visible := True
				ItemInfoGui["GroupBox" aVal].Visible := True
			}
			Loop 10
			{
				ItemInfoGui["PComment" A_Index].Visible := True
				ItemInfoGui["PData" A_Index].Visible := True
				ItemInfoGui["SComment" A_Index].Visible := True
				ItemInfoGui["SData" A_Index].Visible := True
			}
		}
		_GoSub_noDataGraph(){
			_GoSub_noDataGraph1()
			_GoSub_noDataGraph2()
		}
		_GoSub_noDataGraph1(){
			Loop 21
			{
				ItemInfoGui["PercentText1G" A_Index].Text := "0`%"
			}
			ItemInfoGui["GroupBox1"].Text := "No Data"
			Loop 13
			{
				XGraph_Plot( pGraph1, 100, "", True )
			}
			Loop 10
			{
				ItemInfoGui["PComment" A_Index].Text := ""
				ItemInfoGui["PData" A_Index].Text := ""
			}
		}
		_GoSub_noDataGraph2(){
			Loop 21
			{
				ItemInfoGui["PercentText2G" A_Index].Text := "0`%"
			}
			ItemInfoGui["GroupBox2"].Text := "No Data"
			Loop 13
			{
				XGraph_Plot( pGraph2, 100, "", True )
			}
			Loop 10
			{
				ItemInfoGui["SComment" A_Index].Text := ""
				ItemInfoGui["SData" A_Index].Text := ""
			}
		}
		_GoSub_HideGraph(){
			_GoSub_HideGraph1()
			_GoSub_HideGraph2()
		}
		_GoSub_HideGraph1(){
			Loop 21
			{
				ItemInfoGui["PercentText1G" A_Index].Visible := False
			}
			ItemInfoGui["pGraph1"].Visible := False
			ItemInfoGui["GroupBox1"].Visible := False
			Loop 10
			{
				ItemInfoGui["PComment" A_Index].Visible := False
				ItemInfoGui["PData" A_Index].Visible := False
			}
		}
		_GoSub_HideGraph2(){
			Loop 21
			{
				ItemInfoGui["PercentText2G" A_Index].Visible := False
			}
			ItemInfoGui["pGraph2"].Visible := False
			ItemInfoGui["GroupBox2"].Visible := False
			Loop 10
			{
				ItemInfoGui["SComment" A_Index].Visible := False
				ItemInfoGui["SData" A_Index].Visible := False
			}
		}
	}
	ItemInfo(){
		This.MatchLootFilter()
		This.DisplayPSA()
		This.GraphNinjaPrices()
	}
	MatchStashManagement(passthrough:=False){
		; Create associative array so HasKey function can be used
		UnsupportedAffinityCurrencies := Map("Prime Regrading Lens",0
			,"Secondary Regrading Lens",0
			,"Vial of Transcendence",0
			,"Vial of Sacrifice",0
			,"Vial of the Ghost",0
			,"Vial of Consequence",0
			,"Vial of Summoning",0
			,"Vial of Dominance",0
			,"Vial of Awakening",0
			,"Vial of the Ritual",0
			,"Vial of Fate",0
			,"Bestiary Orb",0)
		If (This.Prop.IsRune && StashTabYesRunes){
			sendstash := StashTabRunes
		} Else If (This.Prop.IsTattoo && StashTabYesTattoos){
			sendstash := StashTabTattoos
		} Else If ( StashTabYesCurrency
			&& This.Prop.RarityCurrency
			&& ( This.Prop.SpecialType == ""
			|| This.Prop.SpecialType == "Ritual Item"
			|| (This.Prop.IsRune && !StashTabYesRunes)
			|| (This.Prop.IsTattoo && !StashTabYesTattoos) ) )
		{
			If ( StashTabYesCurrency > 1
				&& !This.Prop.IsRune
				&& !This.Prop.IsTattoo
				&& !UnsupportedAffinityCurrencies.Has( This.Prop.ItemName ) )
				sendstash := -2
			Else
				sendstash := StashTabCurrency
		} Else If (This.Prop.IsRune && StashTabYesRunes){
			sendstash := StashTabRunes
		} Else If (This.Prop.IsTattoo && StashTabYesTattoos){
			sendstash := StashTabTattoos
		} Else If (StashTabYesNinjaPrice && This.Prop.ChaosValue >= StashTabYesNinjaPrice_Price && !This.Prop.IsMap) {
			sendstash := StashTabNinjaPrice
		} Else If (This.Prop.Expedition) {
			Return -2
		} Else If (This.Prop.HarvestCurrency) {
			Return -2
		} Else If (This.Prop.Heist) {
			Return -2
		} Else If (This.Prop.Incubator) {
			Return -1
			;Affinities
		} Else If ((This.Prop.IsBlightedMap || This.Prop.Oil) && StashTabYesBlight) {
			If (StashTabYesBlight > 1)
				sendstash := -2
			Else
				sendstash := StashTabBlight
		} Else If (This.Prop.IsBrickedMap && StashTabYesBrickedMaps) {
			sendstash := StashTabBrickedMaps
		} Else If (This.Prop.IsMap && StashTabYesMap) {
			If (StashTabYesMap > 1)
				sendstash := -2
			Else
				sendstash := StashTabMap
		} Else If (This.Prop.Catalyst && StashTabYesUltimatum) {
			If (StashTabYesUltimatum > 1)
				sendstash := -2
			Else
				sendstash := StashTabUltimatum
		} Else If (This.Prop.SpecialType="Delirium" && StashTabYesDelirium) {
			If (StashTabYesDelirium > 1)
				sendstash := -2
			Else
				sendstash := StashTabDelirium
		} Else If ((This.Prop.TimelessSplinter || This.Prop.TimelessEmblem || This.Prop.BreachSplinter || This.Prop.Offering || This.Prop.UberDuberOffering || This.Prop.Vessel || This.Prop.Scarab || This.Prop.SacrificeFragment || This.Prop.MortalFragment || This.Prop.GuardianFragment || This.Prop.ProphecyFragment || This.Prop.ConquererFragment ) && StashTabYesFragment) {
			If (StashTabYesFragment > 1)
				sendstash := -2
			Else
				sendstash := StashTabFragment
		} Else If (This.Prop.RarityDivination) && StashTabYesDivination {
			If (StashTabYesDivination > 1)
				sendstash := -2
			Else
				sendstash := StashTabDivination
		} Else If (This.Prop.Essence) && StashTabYesEssence {
			If (StashTabYesEssence > 1)
				sendstash := -2
			Else
				sendstash := StashTabEssence
		} Else If (This.Prop.Fossil || This.Prop.Resonator) && StashTabYesDelve {
			If (StashTabYesDelve > 1)
				sendstash := -2
			Else
				sendstash := StashTabDelve
		} Else If (This.Prop.Flask&&!This.Prop.RarityUnique) {
			If (StashTabYesFlask > 1)
				sendstash := -2
			Else
				sendstash := StashTabFlask
		} Else If (This.Prop.RarityGem && StashTabYesGem) {
			If (StashTabYesGem > 1)
				sendstash := -2
			Else
				sendstash := StashTabGem
		} Else If ((StashTabYesUnique||StashTabYesUniqueRing||StashTabYesUniqueDump) && This.Prop.RarityUnique
			&&( !StashTabYesUniquePercentage || (StashTabYesUniquePercentage && This.Prop.HasRange && This.Prop.PercentageAffix >= StashTabUniquePercentage) ) ) {
			If (StashTabYesUnique == 2)
				Return -2
			Else if (StashTabYesUnique)
				sendstash := StashTabUnique
			Else If (StashTabYesUniqueRing&&This.Prop.Ring)
				sendstash := StashTabUniqueRing
			Else If (StashTabYesUniqueDump)
				sendstash := StashTabUniqueDump
		} Else If ( ((StashTabYesUniqueRing && StashTabYesUniqueRingAll && This.Prop.Ring) || (StashTabYesUniqueDump&&StashTabYesUniqueDumpAll)) && This.Prop.RarityUnique
			&& (StashTabYesUniquePercentage && This.Prop.PercentageAffix < StashTabUniquePercentage) ) {
			If (StashTabYesUniqueRing && StashTabYesUniqueRingAll && This.Prop.Ring)
				sendstash := StashTabUniqueRing
			Else If (StashTabYesUniqueDump&&StashTabYesUniqueDumpAll)
				sendstash := StashTabUniqueDump
		} Else If (This.Prop.MiscMapItem&&StashTabYesMiscMapItems) {
			sendstash := StashTabMiscMapItems
		} Else If ((This.Prop.IsInfluenceItem||This.Prop.IsSynthesisItem&&YesIncludeFandSItem)&&StashTabYesInfluencedItem) {
			sendstash := StashTabInfluencedItem
		} Else If ((This.Prop.Sockets_Link >= 5)&&StashTabYesLinked) {
			sendstash := StashTabLinked
		} Else If (This.Prop.Veiled&&StashTabYesVeiled) {
			sendstash := StashTabVeiled
		} Else If (This.Prop.ClusterJewel&&StashTabYesClusterJewel) {
			sendstash := StashTabClusterJewel
		} Else If (This.Prop.HeistGear&&StashTabYesHeistGear) {
			sendstash := StashTabHeistGear
		} Else If (StashTabYesCrafting && This.Prop.WantedCraftingBase) {
			sendstash := StashTabCrafting
		} Else If (ChaosRecipeEnableFunction && This.StashChaosRecipe(passthrough)) {
			If (ChaosRecipeStashMethodDump)
				sendstash := StashTabDump
			Else If (ChaosRecipeStashMethodTab)
				sendstash := ChaosRecipeStashTab
			Else If (ChaosRecipeStashMethodSort) {
				If (This.Prop.SlotType == "Body")
					sendstash := ChaosRecipeStashTabArmour
				Else If (This.Prop.SlotType == "One Hand" || This.Prop.SlotType == "Two Hand" || This.Prop.SlotType == "Shield")
					sendstash := ChaosRecipeStashTabWeapon
				Else If (This.Prop.SlotType) {
					w := This.Prop.SlotType
					sendstash := %("ChaosRecipeStashTab" w)%
				}
			}
		} Else If (((StashDumpInTrial || StashTabYesDump) && CurrentLocation ~= "Aspirant's Trial")
			|| (StashTabYesDump && (!StashDumpSkipJC || (StashDumpSkipJC && !(This.Prop.Jeweller || This.Prop.Chromatic))))) {
			sendstash := StashTabDump, This.Prop.DumpTabItem := True
		} Else If (This.Prop.SpecialType && This.Prop.SpecialType != "Heist Goods") {
			Return -1
		}	Else {
			Return False
		}
		Return sendstash
	}
	MatchLootFilter(GroupOut:=0){
		For GKey, Groups in LootFilter
		{
			If (Groups.GroupType) {
				AuxStrictness := (Groups["Strictness"]?Groups["Strictness"]:-1)
				If (val := This.MatchGroup(Groups)){
					If(CLFStrictnessNumber <= AuxStrictness || AuxStrictness == -1){
						this.Prop.CLF_Tab := Groups["StashTab"]
						this.Prop.CLF_Group := (Groups["GroupName"]?Groups["GroupName"]:GKey)
						this.Prop.CLF_Strictness := AuxStrictness
						This.MatchedCLF := val
						Return this.Prop.CLF_Tab
					}
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
					If ( SKey == "Data" )
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
	MatchGroup(grp,returnWeight){
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
			If returnWeight {
				return CountSum
			} Else If (CountSum >= grp.TypeValue) {
				Return PotentialMatches
			} Else {
				Return False
			}
		}
	}
	Evaluate(eval,val,min){
		if (eval == ">") {
			Return (val > min)
		} Else if (eval == ">=") {
			Return (val >= min)
		} Else if (eval == "=") {
			Return (val == min)
		} Else if (eval == "<") {
			Return (val < min)
		} else if (eval == "<=") {
			Return (val <= min)
		} else if (eval == ">0<") {
			Return (val > 0 && val < min)
		} else if (eval == ">0<=") {
			Return (val > 0 && val <= min)
		} else if (eval == "!=") {
			Return (val != min)
		} else if (eval == "~=") {
			Return (val ~= min)
		} else if (eval == "~") {
			matchedOR := False
			for k, v in StrSplit(min, "|"," ") { ; Split OR first
				if InStr(v, "&") { 					 ; Check for any & sections
					mismatched := false
					for kk, vv in StrSplit(v, "&"," ") { ; Split the array again
						If !InStr(val, vv) ; Check AND sections for mismatch
							mismatched := true
					}
					if !mismatched { ; no mismatch means all sections found in the string
						matchedOR := true
						Break
					}
				}	Else if InStr(val, v)	{ ; If there was no & symbol this is an OR section
					matchedOR := True
					break
				}
			}
			Return matchedOR ; If any of the sections produced a match it will flag true
		}
	}
	inRange(key,obj,base){
		If (obj.ranges.Length == 1) {
			If !((base[key] >= obj.ranges[1][1] && base[key] <= obj.ranges[1][2])
				|| (base[key] <= obj.ranges[1][1] && base[key] >= obj.ranges[1][2]))
				Return False
		} Else If (obj.ranges.Length >= 2) {
			for k, v in obj.ranges
			{
				If !((base[key "_Value" k] >= v.1 && base[key "_Value" k] <= v.2)
					|| (base[key "_Value" k] <= v.1 && base[key "_Value" k] >= v.2))
					Return False
			}
		} Else If (obj.values.Length == 1) {
			If !(base[key] == obj.values.1 )
				Return False
		} Else If (obj.values.Length >= 2) {
			for k, v in obj.values
				If !(base[key "_Value" k] == v )
					Return False
		}
		Return True
	}
	MatchCraftingBases(Flag:=false){
		If (This.Prop.Rarity_Digit == 4 || This.Prop.Corrupted)
			Return False
		update := false
		For ki,vi in ["str_armour","dex_armour","int_armour","str_dex_armour","str_int_armour","dex_int_armour","amulet","ring","belt","weapon"]
		{
			For k,v in WR.CustomCraftingBases.%vi%
			{
				If (v.BaseName == This.Prop.ItemBase && ((YesStashBasesAboveIlvl && This.Prop.ItemLevel >= StashBasesAboveIlvl)|| !YesStashBasesAboveIlvl))
				{
					If (v.ILvL <= This.Prop.ItemLevel)
					{
						If (v.ILvL < This.Prop.ItemLevel)
						{
							v.ILvL := This.Prop.ItemLevel
							v.Quant := 1
							update := True
						}
						If ((YesCraftingBaseLimitBases && v.Quant < CraftingBaseLimitBasesNumber) || !YesCraftingBaseLimitBases)
						{
							This.Prop.WantedCraftingBase := True
						}
						If (Flag && !update)
						{
							v.Quant++
							update := true
						}

					}
					This.Prop.CraftingBaseHigherILvLFound := v.ILvL
					This.Prop.CraftingBaseQuantFound := v.Quant
					If(update){
						Settings("CustomCraftingBases","Save")
					}
					Return
				}
			}
		}
	}
	ApproximatePerfection(){
		For ku, unique in WR.data.Perfect
		{
			If ( This.Prop.ItemName == unique.name ) {
				If unique.pricePerfect
				{
					perccalc := This.percval(This.Prop.PercentageAffix,[unique.mean,unique.pricePerfect]) * (This.Prop.PercentageAffix/90)
					This.Prop.UniquePerfectValue := perccalc < unique.mean ? unique.mean
						: perccalc > unique.pricePerfect ? unique.pricePerfect
						: perccalc
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
		This.Prop.UniquePerfectValue := 0
		This.Prop.UniqueNormalMean := 0
		This.Prop.UniquePerfectMaxVal := 0
	}
	perc(value,range){
		Return abs(((value - range.1) * 100) / (range.2 - range.1))
	}
	percval(perc,range){
		Return ((perc * (range.2 - range.1) / 100) + range.1)
	}
	DisenchantCalculation(multi, ilvl, quality){
		quality := quality > 0 ? quality : 0
		qualityScaler := 1 + quality/100
		ilvl := ilvl > 84 ? 84 : ilvl < 65 ? 65 : ilvl
		levelScaler := 20 - ( 84 - ilvl )
		dustAmount := multi * 100 * levelScaler * qualityScaler
		return Round(dustAmount)
	}
}
