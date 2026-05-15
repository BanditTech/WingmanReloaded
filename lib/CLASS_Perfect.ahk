Class Perfect {
    __New(mod) {
        This.o        := {}
        This.o.isvar  := 0
        This.o.key    := This.Standardize(mod)
        This.SetVals(mod)
        This.o.text   := mod
    }

    Standardize(str) {
        str := RegExReplace(str, "\+?" rxNum, "#")
        str := RegExReplace(str, "\(#-#\)", "#", &replacecount)
        str := RegExReplace(str, "\+?#", "#")
        This.o.isvar := replacecount
        Return str
    }

    GetValues(lineString) {
        values   := []
        position := 1
        RxMatch  := {Len: [0]}
        While (position := RegExMatch(lineString, "`am)" rxNum, &RxMatch, position + RxMatch.Len[1])) {
            If (RxMatch[1] != "")
                values.Push(RxMatch[1])
        }
        If values.Length
            Return values
        Else
            Return False
    }

    SetVals(line) {
        If (line == "")
            Return
        If (vals := This.GetValues(line)) {
            If (vals.Length >= 2) {
                If (line ~= "\d[ a-zA-Z%]*\(\d+-\d+\)")
                    This.o.values := [vals[1]]
                    , This.o.ranges := [[vals[2], vals[3]]]
                    , vals.RemoveAt(1, 3)
                Else If (line ~= "\(" rxNum "-" rxNum "\) to \(" rxNum "-" rxNum "\)")
                    This.o.ranges := [[vals[1], vals[2]], [vals[3], vals[4]]]
                    , vals.RemoveAt(1, 4)
                Else If (line ~= "\(" rxNum "-" rxNum "\)")
                    This.o.ranges := [[vals[1], vals[2]]]
                    , vals.RemoveAt(1, 2)
                If vals.Length {
                    If !IsObject(This.o.values)
                        This.o.values := []
                    For k, v in vals
                        This.o.values.Push(v)
                }
            } Else If (vals.Length == 1) {
                This.o.values := [vals[1]]
            }
        } Else {
            This.o.values := [""]
        }
    }
}

RefreshPoeWatchPerfect() {
    RequestURL := "https://api.poe.watch/perfect?league=" selectedLeague
    Download(RequestURL, A_ScriptDir "\temp\PoE.Watch_PerfectUnique_orig.json")
    JSONtext := FileRead(A_ScriptDir "\temp\PoE.Watch_PerfectUnique_orig.json")
    Try {
        WR.Data.Perfect := JSON.Load(JSONtext)
        For ku, itemDB in WR.Data.Perfect {
            pushto := {}
            For kt, type in ["implicits", "explicits"] {
                pushto.%type% := {}
                ; PoE.Watch returns JSON null for items with no implicits/explicits
                ; (e.g. unique flasks). cJson maps null -> JSON.Null sentinel, which
                ; isn't an Array and isn't enumerable. Skip non-Array values.
                If !(itemDB[type] is Array)
                    Continue
                For ki, mod in itemDB[type] {
                    mod     := RegExReplace(mod, "1 to \(", "(1-1) to (")
                    replace := Perfect(mod)
                    WR.Data.Perfect[ku][type][ki] := replace.o
                }
            }
        }
        FileOpen(A_ScriptDir "\data\PoE.Watch_PerfectUnique.json", "w").Write(JSON.Dump(WR.Data.Perfect, 1))
    } catch as e {
        MsgBox("There was an Error while Loading Perfect Price `n`n" ErrorText(e))
        WR.Data.Perfect := {}
    }
}
