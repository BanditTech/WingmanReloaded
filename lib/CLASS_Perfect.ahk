Class Perfect {
	__New(mod){
		This.o := New OrderedAssociativeArray
		This.o.isvar := 0
		This.o.key:=This.Standardize(mod)
		This.SetVals(mod)
		This.o.text:=mod
	}
	Standardize(str){
		str := RegExReplace(str, "\+?"rxNum, "#")
		str := RegExReplace(str, "\(#-#\)", "#",replacecount)
		str := RegExReplace(str, "\+?#", "#")
		This.o.isvar := replacecount
		Return str
	}
	GetValues(lineString){
		values := []
		position := 1
		RxMatch:={"Len":[0]}
		While (position := RegExMatch(lineString, "O`am)"rxNum, RxMatch, position + RxMatch.Len[1]))
		{
			If (RxMatch[1] != "")
				values.push(RxMatch[1])
		}
		If values.Count()
			Return values
		Else
			Return False
	}
	SetVals(line){
		If (line = "")
			Return
		If (vals := This.GetValues(line))
		{
			If (vals.Count() >= 2)
			{
				If (line ~= "\d[ a-zA-Z%]*\(\d+-\d+\)")
					This.o.values := [vals[1]]
					, This.o.ranges := [[vals[2],vals[3]]]
					, vals.RemoveAt(1, 3)
				Else If (line ~= "\("rxNum "-"rxNum "\) to \(" rxNum "-"rxNum "\)")
					This.o.ranges := [[vals[1],vals[2]],[vals[3],vals[4]]]
					, vals.RemoveAt(1, 4)
				Else If (line ~= "\("rxNum "-"rxNum "\)")
					This.o.ranges := [[vals[1],vals[2]]]
					, vals.RemoveAt(1, 2)
				If vals.Count()
				{
					If !IsObject(This.values)
						This.o.values := []
					For k, v in vals
						This.o.values.Push(v)
				}
			}
			Else If (vals.Count() == 1)
			{
				This.o.values := [vals[1]]
			}
		}
		Else
			This.o.values := [""]
	}
}

RefreshPoeWatchPerfect(){
	Global selectedLeague
	RequestURL := "https://api.poe.watch/perfect?league=" selectedLeague
	UrlDownloadToFile, %RequestURL%, %A_ScriptDir%\temp\PoE.Watch_PerfectUnique_orig.json
	JSONtext := FileOpen(A_ScriptDir "\temp\PoE.Watch_PerfectUnique_orig.json","r").Read()
	Try {
		WR.Data.Perfect := JSON.Load(JSONtext,,1)
		For ku, itemDB in WR.Data.Perfect {
			pushto := {}
			For kt, type in ["implicits","explicits"] {
				pushto[type] := {}
				For ki, mod in itemDB[type] {
					mod := RegExReplace(mod, "1 to \(", "(1-1) to (")
					replace := new Perfect(mod)
					WR.Data.Perfect[ku][type][ki] := replace.o
				}
			}
		}
		FileOpen(A_ScriptDir "\data\PoE.Watch_PerfectUnique.json","w").Write(JSON_Beautify(WR.Data.Perfect," ",3))
	} Catch e {
		MsgBox % "There was an Error while Loading Perfect Price `n`n" ErrorText(e)
		WR.Data.Perfect := {}
	}
}