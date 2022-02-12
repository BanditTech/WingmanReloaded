Class FilterBuilder {
	Static FBheader := "# FilterBlade: Conditional Entry"
	__New(Settings){
		This.String := []
		This.Settings := Settings
		This.Add(This.FBheader)
		This.Add("Show")
		If This.Settings.HasKey("ItemLevel") {
			This.ItemLevel()
		}
		This.Add("Rarity Rare")
		This.Add("Identified False")
		If This.Settings.HasKey("Classes") {
			This.Classes()
		}
		If This.Settings.HasKey("BorderColor") {
			This.SetColor("Border")
		}
		If This.Settings.HasKey("FontSize") {
			This.FontSize()
		}
		If This.Settings.HasKey("BackgroundColor") {
			This.SetColor("Background")
		}
		If This.Settings.HasKey("TextColor") {
			This.SetColor("Text")
		}
		If This.Settings.HasKey("Dimensions") {
			This.Dimensions()
		}
		This.Add("")
		Return This.ReturnString()
	}
	ReturnString(){
		str := ""
		For k, v in This.String {
			str .= (str?"`r`n":"") v
		}
		Return str
	}
	Add(String){
		This.String.Push(String)
	}
	Classes(){
		str := "Class =="
		For k, v in This.Settings.Classes {
			str .= " """ v """"
		}
		This.Add(str)
	}
	SetColor(kind){
		c := This.Settings[kind "Color"]
		If (c is xdigit) {
			colors := ToRGB(c)
			This.Add("Set" kind "Color " colors.r " " colors.g " " colors.b)
		} Else If (c ~= "^\d+ \d+ \d+") {
			This.Add("Set" kind "Color " c)
		}
	}
	FontSize(){
		This.Add("SetFontSize " This.Settings.FontSize)
	}
	ItemLevel(){
		This.Add("ItemLevel >= " This.Settings.ItemLevel.Min)
		This.Add("ItemLevel <= " This.Settings.ItemLevel.Max)
	}
	Dimensions(){
		If This.Settings.Dimensions.HasKey("Height") {
			This.Add("Height = " This.Settings.Dimensions.Height)
		}
		If This.Settings.Dimensions.HasKey("Width") {
			This.Add("Width = " This.Settings.Dimensions.Width)
		}
	}
}