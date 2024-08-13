Class Craft {
	__New(Type,Method,Desired){
		; Type := "Chance","Color","Link","Socket"
		This.Type := Type

		If (Method = 1)
			Method := "cursor"
		Else If (Method = 2)
			Method := "stash"
		Else If (Method = 3)
			Method := "bulk"
		; Method := "cursor","stash","bulk"
		This.Method := Method

		; Desired := SettingObject
		This.Desired := Desired

		; Determine target object
		If (This.Method = "bulk") {
			; add for expansion of this feature later
			This.Target := "inventory"
		} Else {
			If (This.Method = "stash")
				This.Target := WR.Loc.Pixel["Currency Craft Slot"]
			Else If (This.Method = "cursor"){
				MouseGetPos, xx, yy
				This.Target := {X:xx,Y:yy}
			}
		}

		; Begin the specified crafting routine
		
		This.Initiate()

		Return This
	}
	GetAuto(){
		local lvl := Item.Prop.ItemLevel
		If This.Type = "Link"
			Return Item.Prop.Sockets_Num
		If (lvl < 2)
			Return 2
		Else If (lvl < 25)
			Return 3
		Else If (IndexOf(Item.Prop.SlotType,["One Hand","Shield"]))
			Return 3
		Else If (lvl < 35)
			Return 4
		Else If (!IndexOf(Item.Prop.SlotType,["Two Hand","Body"]))
			Return 4
		Else If (lvl < 50)
			Return 5
		Else If (lvl <= 100)
			Return 6
	}
	Validate(){
		If (Item.Prop.ItemName = "")
		|| (This.Desired.Links > Item.Prop.Sockets_Num && !This.Desired.Auto)
		|| ((!Item.Prop.SlotType || indexOf(Item.Prop.SlotType,["Belt","Ring","Amulet"])) && indexOf(This.Type,["Color","Link","Socket"]))
		|| (Item.Prop.ItemLevel < 2 && This.Desired.Sockets >= 3 && !This.Desired.Auto)
		|| (Item.Prop.ItemLevel < 25 && This.Desired.Sockets >= 4 && !This.Desired.Auto)
		|| (Item.Prop.ItemLevel < 35 && This.Desired.Sockets >= 5 && !This.Desired.Auto)
		|| (Item.Prop.ItemLevel < 50 && This.Desired.Sockets >= 6 && !This.Desired.Auto)
		|| (This.Desired.Sockets > 4 && !IndexOf(Item.Prop.SlotType,["Two Hand","Body"]) && !This.Desired.Auto)
		|| (This.Desired.Sockets > 3 && IndexOf(Item.Prop.SlotType,["One Hand","Shield"]) && !This.Desired.Auto)
		|| ((This.Desired.R + This.Desired.G + This.Desired.B) > Item.Prop.Sockets_Num)
		{
			Notify("Validation Failed","",2)
			Return False
		}
		Else
			Return True
	}
	Initiate(){
		WinActivate, % GameStr
		If (This.Method = "bulk") {
			
		} Else {
				This.Looping(This.Target.X,This.Target.Y)
		}
	}
	Logic(){
		If (This.Type = "Chance"){
			If Item.Prop.Rarity_Digit = 4
				Return True
			Else If (Item.Prop.Rarity_Digit > 1 && !This.Desired.Scour)
				Return True
			Else
				Return False
		} Else If (This.Type = "Color"){
			If This.Colormatch()
				Return True
			Else
				Return False
		} Else If (This.Type = "Link"){
			If (This.Desired.Auto && Item.Prop.Sockets_Link >= This.Desired.Auto)
			|| (!This.Desired.Auto && Item.Prop.Sockets_Link >= This.Desired.Links)
				Return True
			Else
				Return False
		} Else If (This.Type = "Socket"){
			If (This.Desired.Auto && Item.Prop.Sockets_Num >= This.Desired.Auto)
			|| (!This.Desired.Auto && Item.Prop.Sockets_Num >= This.Desired.Sockets)
				Return True
			Else
				Return False
		}
	}
	ColorMatch(){
		If This.Desired.R
			RDif := This.Desired.R - Item.Prop.Sockets_R
		If This.Desired.G
			GDif := This.Desired.G - Item.Prop.Sockets_G
		If This.Desired.B
			BDif := This.Desired.B - Item.Prop.Sockets_B
		TDif := (RDif<=0?0:RDif) + (GDif<=0?0:GDif) + (BDif<=0?0:BDif)
		If TDif {
			If (Item.Prop.Sockets_W >= TDif)
				Return True
			Else
				Return False
		} Else {
			Return True
		}
	}
	ApplyCurrency(cname, x, y){
		Global WR
		MoveStash(StashTabCurrency)
		RightClick(WR.loc.pixel[cname].X, WR.loc.pixel[cname].Y)
		Sleep, 45*Latency
		LeftClick(x,y)
		Sleep, 90*Latency
		ClipItem(x,y)
		Sleep, 45*Latency
		return
	}
	Looping(x,y){
		Global RunningToggle
		Static namearr := {Chance:"Chance",Color:"Chromatic",Link:"Fusing",Socket:"Jeweller"}
		ClipItem(x,y)
		If Item.Affix.Unidentified
			WisdomScroll(x,y), ClipItem(x,y)
		If This.Desired.Auto
			This.Desired.Auto := This.GetAuto()
		If This.Validate()
			While !This.Logic() && RunningToggle {
				If (This.Type = "Chance") {
					If (Item.Prop.Rarity_Digit != 1 && This.Desired.Scour)
						This.ApplyCurrency("Scouring",x,y)
				}
				This.ApplyCurrency(namearr[This.Type],x,y)
			}
		Notify("Loop Complete","",1)
	}
}
