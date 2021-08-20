Class RefreshAffixes {
	Maps(){
		Static FileList := [ {"category":"Map", "subfield":"low_tier_map"}
			,{"category":"Map", "subfield":"mid_tier_map"}
			,{"category":"Map", "subfield":"top_tier_map"}]
		Download := {}
		This.ReturnList := []
		For k, v in FileList {
			Download[v.subfield] := This.Download(v.category,v.subfield)
		}
		For subfield, v in Download {
			Try {
				obj := Json.Load(v)
				; MsgBox % isObject(obj)
			} Catch e {
				Util.Err(e,"Issue loading JSON for " subfield)
			}
			For k, vv in obj.normal {
				This.SplitKeys(vv.str)
			}
		}
		Util.Save(Util.Dir.Data "\Affix_List_Map.json",This.ReturnList)
		This.ReturnList := ""
		Download := ""
	}
	SplitKeys(Str){
		Static ignored := ["#% increased Pack size"
		,"#% increased Rarity of Items found in this Area"
		,"#% increased Quantity of Items found in this Area"]
		line := RegexReplace(Str,"\d+","#")
		line := RegexReplace(line,"\(#-#\)","#")
		line := RegexReplace(line,"\(-#--#\)","-#")
		; MsgBox % line
		strLines := StrSplit(line, "<br>")
		For k, v in strLines {
			If (v = "" || indexOf(v,ignored) || indexOf(v,This.ReturnList))
				Continue
			This.ReturnList.Push(v)
		}
	}
	Download(category,subfield){
		Static replace := [["&ndash;","-"]
			,["(<br>)?<span class='mod_grey'>.*?</span>",""]
			,["<span class='mod-value'>",""]
			,["</span>",""]]
		Str := Util.HttpGet("https://poedb.tw/us/json.php/Mods/Gen?cn=" category "&an=&tags=" subfield)
		For k, v in replace {
			Str := RegexReplace(Str,v.1,v.2)
		}
		Return Str
	}
}

