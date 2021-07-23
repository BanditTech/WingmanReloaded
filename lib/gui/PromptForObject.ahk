; horrible looking UI to print an object, needs work
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
