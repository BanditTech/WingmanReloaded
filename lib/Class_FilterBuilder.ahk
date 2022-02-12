Class FilterBuilder {
	Static FBheader := "# FilterBlade: Conditional Entry"
	__New(Settings){
		This.String := []
		This.Settings := Settings
		This.Add(FBheader)
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
			This.BorderColor()
		}
		If This.Settings.HasKey("FontSize") {
			This.FontSize()
		}
		If This.Settings.HasKey("BackgroundColor") {
			This.BackgroundColor()
		}
		If This.Settings.HasKey("TextColor") {
			This.TextColor()
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
	BorderColor(){
		colors := ToRGB(This.Settings.BorderColor)
		This.Add("SetBorderColor " colors.r " " colors.g " " colors.b)
	}
	BackgroundColor(){
		colors := ToRGB(This.Settings.BackgroundColor)
		This.Add("SetBackgroundColor " colors.r " " colors.g " " colors.b)
	}
	TextColor(){
		colors := ToRGB(This.Settings.TextColor)
		This.Add("SetTextColor " colors.r " " colors.g " " colors.b)
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