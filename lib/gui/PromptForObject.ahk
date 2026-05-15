; horrible looking UI to print an object, needs work
PromptForObject(){
  ArrayPrintGui := Gui()
  ArrayPrintGui.Add("Edit", "xm+20 ym+20 w200 h23 vSubmitObjectName")
  btn := ArrayPrintGui.Add("Button", "wp hp", "Submit")
  btn.OnEvent("Click", PrintObj)
  ArrayPrintGui.Show()
  Return

  PrintObj(ctrl, *) {
    name := ArrayPrintGui["SubmitObjectName"].Value
    ArrayPrintGui.Destroy()
    ; Build a map of inspectable global objects by name
    Global WR, Item, LootFilter, Globe, RecipeArray
    objLookup := Map("WR", WR, "Item", Item, "LootFilter", LootFilter, "Globe", Globe, "RecipeArray", RecipeArray)
    If objLookup.Has(name)
      Array_Gui(objLookup[name])
    Else
      MsgBox(name)
  }
}
