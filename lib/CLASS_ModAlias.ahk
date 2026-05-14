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
		global JSON
		This.ModObject := JSON.LoadFile(A_ScriptDir "\Data\mods.min.json")
		This.TransObject := JSON.LoadFile(A_ScriptDir "\Data\stat_translations.min.json")
		This.Loaded := True
	}
	GetReference(StatKey){
		referenceid := This.ModObject[StatKey]["stats"][0]["id"]
		referencemax := This.ModObject[StatKey]["stats"][0]["max"]
		referencemin := This.ModObject[StatKey]["stats"][0]["min"]
		Return {id:referenceid, max:referencemax, min:referencemin}
	}
	Locate(StatID){
		Loop This.TransObject.length {
			k := A_Index - 1
			v := This.TransObject[k]["ids"]
			loop v.length {
				i := A_Index - 1
				strkey := v[i]
				If (strkey == StatID) {
					return This.TransObject[k]["English"]
				}
			}
		}
		Return False
	}
	ConvertJStoAHK(Obj){
		global JSON
		Return JSON.Load(JSON.Dump(Obj))
	}
}
