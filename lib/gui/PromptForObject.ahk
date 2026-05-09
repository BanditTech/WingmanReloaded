; horrible looking UI to print an object, needs work
PromptForObject(){
  Global
  ArrayPrintGui := Gui()
  ArrayPrintGui.Add("Edit", "xm+20 ym+20 w200 h23 vSubmitObjectName")
  btn := ArrayPrintGui.Add("Button", "wp hp", "Submit")
  btn.OnEvent("Click", PrintObj)
  ArrayPrintGui.Show()
  Return

  PrintObj(ctrl, *) {
    ArrayPrintGui.Submit(0)
    ArrayPrintGui.Destroy()
    If IsObject(SubmitObjectName)
      Array_Gui(%SubmitObjectName%)
    Else
    MsgBox(%SubmitObjectName%)
  }
}
