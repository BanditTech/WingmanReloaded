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
		This.MatchCraftingBases()
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
