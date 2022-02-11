LoadNSFile(path){
    FileRead, Contents, path
    if not ErrorLevel ; Successfully loaded.
    {
        Loop, Parse, Contents, `n, `r
        {
            ;Search for NS Index for Crafting Bases
            If(A_LoopField ~= "$type->normalcraft->rest $tier->t1"){
                FlagILvLAnyT1 := True
            }
            If(FlagILvLAnyT1 && A_LoopField ~= "ItemLevel >= (\d+)"){
                ;Replace with new ILvL
                NewStr := RegExReplace(A_LoopField, "ItemLevel >= (\d+)" , 80)
                ;Save Information in File
                Break
            }

        }

        Contents := "" ; Free the memory.
    }
}