Class ModAlias {
	Translate(StatKey){
		If !(This.Loaded) {
			This.LoadDatabase()
		}
		Reference := This.GetReference(StatKey)
		possible := This.Locate(Reference.id)
		; Later we can convert to AHK for evaluating conditions
		; possible := This.ConvertJStoAHK(possible)
		; for now we just return the first entry
		string := possible[0]["string"]
		string := RegExReplace(string,"\{\d\}","#")
		string := RegExReplace(string,RxNum,"#")
		Return string
	}
	LoadDatabase(){
		This.ModObject := JSONcom.Parse(FileOpen(A_ScriptDir "\Data\mods.min.json","r").Read(),true)
		This.TransObject := JSONcom.Parse(FileOpen(A_ScriptDir "\Data\stat_translations.min.json","r").Read(),true)
		This.Loaded := True
	}
	GetReference(StatKey){
		referenceid := This.ModObject[StatKey]["stats"][0]["id"]
		referencemax := This.ModObject[StatKey]["stats"][0]["max"]
		referencemin := This.ModObject[StatKey]["stats"][0]["min"]
		Return {"id":referenceid,"max":referencemax,"min":referencemin}
	}
	Locate(StatID){
		Loop % This.TransObject.length {
			k := A_Index - 1
			v := This.TransObject[k]["ids"]
			loop % v.length {
				i := A_Index - 1
				strkey := v[i]
				If (strkey = StatID) {
					return This.TransObject[k]["English"]
				}
			}
		}
		Return False
	}
	ConvertJStoAHK(Obj){
		Return JSON.Load(JSONcom.Stringify(Obj,true))
	}
}