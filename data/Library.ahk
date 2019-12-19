if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
{
  ft_Gui("Show")
  Return
}

hotkeys(){
    global
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    Return
    Gui, Show, Autosize Center, 	WingmanReloaded
    processWarningFound:=0
    Gui,6:Hide
return
}


/*** JSON v2.1.3 : JSON lib for AutoHotkey.
* Lib: JSON.ahk
*     JSON lib for AutoHotkey.
* Version:
*     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     Load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
*/
    class JSON
    {
        /**
        * Method: Load
        *     Parses a JSON string into an AHK value
        * Syntax:
        *     value := JSON.Load( text [, reviver ] )
        * Parameter(s):
        *     value      [retval] - parsed value
        *     text    [in, ByRef] - JSON formatted string
        *     reviver   [in, opt] - function object, similar to JavaScript's
        *                           JSON.parse() 'reviver' parameter
        */
        class Load extends JSON.Functor
        {
            Call(self, ByRef text, reviver:="")
            {
                this.rev := IsObject(reviver) ? reviver : false
            ; Object keys(and array indices) are temporarily stored in arrays so that
            ; we can enumerate them in the order they appear in the document/text instead
            ; of alphabetically. Skip if no reviver function is specified.
                this.keys := this.rev ? {} : false
                static quot := Chr(34), bashq := "\" . quot
                    , json_value := quot . "{[01234567890-tfn"
                    , json_value_or_array_closing := quot . "{[]01234567890-tfn"
                    , object_key_or_object_closing := quot . "}"
                key := ""
                is_key := false
                root := {}
                stack := [root]
                next := json_value
                pos := 0
                while ((ch := SubStr(text, ++pos, 1)) != "") {
                    if InStr(" `t`r`n", ch)
                        continue
                    if !InStr(next, ch, 1)
                        this.ParseError(next, text, pos)
                    holder := stack[1]
                    is_array := holder.IsArray
                    if InStr(",:", ch) {
                        next := (is_key := !is_array && ch == ",") ? quot : json_value
                    } else if InStr("}]", ch) {
                        ObjRemoveAt(stack, 1)
                        next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
                    } else {
                        if InStr("{[", ch) {
                        ; Check if Array() is overridden and if its return value has
                        ; the 'IsArray' property. If so, Array() will be called normally,
                        ; otherwise, use a custom base object for arrays
                            static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
                        
                        ; sacrifice readability for minor(actually negligible) performance gain
                            (ch == "{")
                                ? ( is_key := true
                                , value := {}
                                , next := object_key_or_object_closing )
                            ; ch == "["
                                : ( value := json_array ? new json_array : []
                                , next := json_value_or_array_closing )
                            
                            ObjInsertAt(stack, 1, value)
                            if (this.keys)
                                this.keys[value] := []
                        
                        } else {
                            if (ch == quot) {
                                i := pos
                                while (i := InStr(text, quot,, i+1)) {
                                    value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
                                    static tail := A_AhkVersion<"2" ? 0 : -1
                                    if (SubStr(value, tail) != "\")
                                        break
                                }
                                if (!i)
                                    this.ParseError("'", text, pos)
                                value := StrReplace(value,  "\/",  "/")
                                , value := StrReplace(value, bashq, quot)
                                , value := StrReplace(value,  "\b", "`b")
                                , value := StrReplace(value,  "\f", "`f")
                                , value := StrReplace(value,  "\n", "`n")
                                , value := StrReplace(value,  "\r", "`r")
                                , value := StrReplace(value,  "\t", "`t")
                                pos := i ; update pos
                                
                                i := 0
                                while (i := InStr(value, "\",, i+1)) {
                                    if !(SubStr(value, i+1, 1) == "u")
                                        this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
                                    uffff := Abs("0x" . SubStr(value, i+2, 4))
                                    if (A_IsUnicode || uffff < 0x100)
                                        value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
                                }
                                if (is_key) {
                                    key := value, next := ":"
                                    continue
                                }
                            
                            } else {
                                value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
                                static number := "number", integer :="integer"
                                if value is %number%
                                {
                                    if value is %integer%
                                        value += 0
                                }
                                else if (value == "true" || value == "false")
                                    value := %value% + 0
                                else if (value == "null")
                                    value := ""
                                else
                                ; we can do more here to pinpoint the actual culprit
                                ; but that's just too much extra work.
                                    this.ParseError(next, text, pos, i)
                                pos += i-1
                            }
                            next := holder==root ? "" : is_array ? ",]" : ",}"
                        } ; If InStr("{[", ch) { ... } else
                        is_array? key := ObjPush(holder, value) : holder[key] := value
                        if (this.keys && this.keys.HasKey(holder))
                            this.keys[holder].Push(key)
                    }
                
                } ; while ( ... )
                return this.rev ? this.Walk(root, "") : root[""]
            }
            ParseError(expect, ByRef text, pos, len:=1)
            {
                static quot := Chr(34), qurly := quot . "}"
                
                line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
                col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
                msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
                ,     (expect == "")     ? "Extra data"
                    : (expect == "'")    ? "Unterminated string starting at"
                    : (expect == "\")    ? "Invalid \escape"
                    : (expect == ":")    ? "Expecting ':' delimiter"
                    : (expect == quot)   ? "Expecting object key enclosed in double quotes"
                    : (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
                    : (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
                    : (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
                    : InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
                    :                      "Expecting JSON value(string, number, true, false, null, object or array)"
                , line, col, pos)
                static offset := A_AhkVersion<"2" ? -3 : -4
                throw Exception(msg, offset, SubStr(text, pos, len))
            }
            Walk(holder, key)
            {
                value := holder[key]
                if IsObject(value) {
                    for i, k in this.keys[value] {
                        ; check if ObjHasKey(value, k) ??
                        v := this.Walk(value, k)
                        if (v != JSON.Undefined)
                            value[k] := v
                        else
                            ObjDelete(value, k)
                    }
                }
                
                return this.rev.Call(holder, key, value)
            }
        }
        /**
        * Method: Dump
        *     Converts an AHK value into a JSON string
        * Syntax:
        *     str := JSON.Dump( value [, replacer, space ] )
        * Parameter(s):
        *     str        [retval] - JSON representation of an AHK value
        *     value          [in] - any value(object, string, number)
        *     replacer  [in, opt] - function object, similar to JavaScript's
        *                           JSON.stringify() 'replacer' parameter
        *     space     [in, opt] - similar to JavaScript's JSON.stringify()
        *                           'space' parameter
        */
        class Dump extends JSON.Functor
        {
            Call(self, value, replacer:="", space:="")
            {
                this.rep := IsObject(replacer) ? replacer : ""
                this.gap := ""
                if (space) {
                    static integer := "integer"
                    if space is %integer%
                        Loop, % ((n := Abs(space))>10 ? 10 : n)
                            this.gap .= " "
                    else
                        this.gap := SubStr(space, 1, 10)
                    this.indent := "`n"
                }
                return this.Str({"": value}, "")
            }
            Str(holder, key)
            {
                value := holder[key]
                if (this.rep)
                    value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)
                if IsObject(value) {
                ; Check object type, skip serialization for other object types such as
                ; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
                    static type := A_AhkVersion<"2" ? "" : Func("Type")
                    if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
                        if (this.gap) {
                            stepback := this.indent
                            this.indent .= this.gap
                        }
                        is_array := value.IsArray
                    ; Array() is not overridden, rollback to old method of
                    ; identifying array-like objects. Due to the use of a for-loop
                    ; sparse arrays such as '[1,,3]' are detected as objects({}). 
                        if (!is_array) {
                            for i in value
                                is_array := i == A_Index
                            until !is_array
                        }
                        str := ""
                        if (is_array) {
                            Loop, % value.Length() {
                                if (this.gap)
                                    str .= this.indent
                                
                                v := this.Str(value, A_Index)
                                str .= (v != "") ? v . "," : "null,"
                            }
                        } else {
                            colon := this.gap ? ": " : ":"
                            for k in value {
                                v := this.Str(value, k)
                                if (v != "") {
                                    if (this.gap)
                                        str .= this.indent
                                    str .= this.Quote(k) . colon . v . ","
                                }
                            }
                        }
                        if (str != "") {
                            str := RTrim(str, ",")
                            if (this.gap)
                                str .= stepback
                        }
                        if (this.gap)
                            this.indent := stepback
                        return is_array ? "[" . str . "]" : "{" . str . "}"
                    }
                
                } else ; is_number ? value : "value"
                    return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
            }
            Quote(string)
            {
                static quot := Chr(34), bashq := "\" . quot
                if (string != "") {
                    string := StrReplace(string,  "\",  "\\")
                    ; , string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
                    , string := StrReplace(string, quot, bashq)
                    , string := StrReplace(string, "`b",  "\b")
                    , string := StrReplace(string, "`f",  "\f")
                    , string := StrReplace(string, "`n",  "\n")
                    , string := StrReplace(string, "`r",  "\r")
                    , string := StrReplace(string, "`t",  "\t")
                    static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
                    while RegExMatch(string, rx_escapable, m)
                        string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
                }
                return quot . string . quot
            }
        }
        /**
        * Property: Undefined
        *     Proxy for 'undefined' type
        * Syntax:
        *     undefined := JSON.Undefined
        * Remarks:
        *     For use with reviver and replacer functions since AutoHotkey does not
        *     have an 'undefined' type. Returning blank("") or 0 won't work since these
        *     can't be distnguished from actual JSON values. This leaves us with objects.
        *     Replacer() - the caller may return a non-serializable AHK objects such as
        *     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
        *     mimic the behavior of returning 'undefined' in JavaScript but for the sake
        *     of code readability and convenience, it's better to do 'return JSON.Undefined'.
        *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
        */
        Undefined[]
        {
            get {
                static empty := {}, vt_empty := ComObject(0, &empty, 1)
                return vt_empty
            }
        }
        class Functor
        {
            __Call(method, ByRef arg, args*)
            {
            ; When casting to Call(), use a new instance of the "function object"
            ; so as to avoid directly storing the properties(used across sub-methods)
            ; into the "function object" itself.
                if IsObject(method)
                    return (new this).Call(method, arg, args*)
                else if (method == "")
                    return (new this).Call(arg, args*)
            }
        }
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*Name          : TF: Textfile & String Library for AutoHotkey
Version       : 3.7
Documentation : https://github.com/hi5/TF
AHKScript.org : http://www.ahkscript.org/boards/viewtopic.php?f=6&t=576
AutoHotkey.com: http://www.autohotkey.com/forum/topic46195.html (Also for examples)
License       : see license.txt (GPL 2.0)
Credits & History: See documentation at GH above.
Structure of most functions:
  TF_...(Text, other parameters)
  {
    ; get the basic data we need for further processing and returning the output:
    TF_GetData(OW, Text, FileName)
    ; OW = 0 Copy inputfile
    ; OW = 1 Overwrite inputfile
    ; OW = 2 Return variable
    ; Text : either contents of file or the var that was passed on
    ; FileName : Used in case OW is 0 or 1 (=file), not used for OW=2 (variable)
    ; Creates a matchlist for use in Loop below
    TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; A_ThisFunc useful for debugging your scripts
    Loop, Parse, Text, `n, `r
    {
        If A_Index in %TF_MatchList%
        {
        ...
        }
        Else
        {
        ...
        }
    }
    ; either copy or overwrite file or return variable
    Return TF_ReturnOutPut(OW, OutPut, FileName, TrimTrailing, CreateNewFile)
    ; OW 0 or 1 = file
    ; Output = new content of file to save or variable to return
    ; FileName
    ; TrimTrailing: because of the loops used most functions will add trailing newline, this will remove it by default
    ; CreateNewFile: To create a file that doesn't exist this parameter is needed, only used in few functions
  }
*/

    TF_CountLines(Text)
        {
        TF_GetData(OW, Text, FileName)
        StringReplace, Text, Text, `n, `n, UseErrorLevel
        Return ErrorLevel + 1
        }

    TF_ReadLines(Text, StartLine = 1, EndLine = 0, Trailing = 0)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                OutPut .= A_LoopField "`n"
            Else if (A_Index => EndLine)
                Break
            }
        OW = 2 ; make sure we return variable not process file
        Return TF_ReturnOutPut(OW, OutPut, FileName, Trailing)
        }

    TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
        {
        TF_GetData(OW, Text, FileName)
        IfNotInString, Text, %SearchText%
            Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                StringReplace, LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
                OutPut .= LoopField "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_Replace(Text, SearchText, ReplaceText="")
        {
        TF_GetData(OW, Text, FileName)
        IfNotInString, Text, %SearchText%
            Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
        Loop
            {
            StringReplace, Text, Text, %SearchText%, %ReplaceText%, All
            if (ErrorLevel = 0) ; No more replacements needed.
                break
            }
        Return TF_ReturnOutPut(OW, Text, FileName, 0)
        }

    TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
        {
        options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
        If RegExMatch(searchText,options,o)
            searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
        Else searchText := "m)" . searchText
        TF_GetData(OW, Text, FileName)
            If (RegExMatch(Text, SearchText) < 1)
                Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3

        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                LoopField := RegExReplace(A_LoopField, NeedleRegEx, Replacement)
                OutPut .= LoopField "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_RegExReplace(Text, NeedleRegEx = "", Replacement = "")
        {
        options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze http://www.autohotkey.com/forum/viewtopic.php?t=60062
        if RegExMatch(searchText,options,o)
            searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
        else searchText := "m)" . searchText
        TF_GetData(OW, Text, FileName)
            If (RegExMatch(Text, SearchText) < 1)
                Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
        Text := RegExReplace(Text, NeedleRegEx, Replacement)
        Return TF_ReturnOutPut(OW, Text, FileName, 0)
        }

    TF_RemoveLines(Text, StartLine = 1, EndLine = 0)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                Continue
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_RemoveBlankLines(Text, StartLine = 1, EndLine = 0)
        {
        TF_GetData(OW, Text, FileName)
        If (RegExMatch(Text, "[\S]+?\r?\n?") < 1)
            Return Text ; No empty lines so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_RemoveDuplicateLines(Text, StartLine = 1, Endline = 0, Consecutive = 0, CaseSensitive = false)
        {
        TF_GetData(OW, Text, FileName)
        If (StartLine = "")
            StartLine = 1
        If (Endline = 0 OR Endline = "")
            EndLine := TF_Count(Text, "`n") + 1
        Loop, Parse, Text, `n, `r
            {
            If (A_Index < StartLine)
                Section1 .= A_LoopField "`n"
            If A_Index between %StartLine% and %Endline%
                {
                If (Consecutive = 1)
                    {
                    If (A_LoopField <> PreviousLine) ; method one for consecutive duplicate lines
                        Section2 .= A_LoopField "`n"
                    PreviousLine:=A_LoopField
                    }
                Else
                    {
                    If !(InStr(SearchForSection2,"__bol__" . A_LoopField . "__eol__",CaseSensitive)) ; not found
                        {
                        SearchForSection2 .= "__bol__" A_LoopField "__eol__" ; this makes it unique otherwise it could be a partial match
                        Section2 .= A_LoopField "`n"
                        }
                    }
                }
            If (A_Index > EndLine)
                Section3 .= A_LoopField "`n"
            }
        Output .= Section1 Section2 Section3
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_InsertLine(Text, StartLine = 1, Endline = 0, InsertText = "")
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                Output .= InsertText "`n" A_LoopField "`n"
            Else
                Output .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                Output .= ReplaceText "`n"
            Else
                Output .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_InsertPrefix(Text, StartLine = 1, EndLine = 0, InsertText = "")
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                OutPut .= InsertText A_LoopField "`n"
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_InsertSuffix(Text, StartLine = 1, EndLine = 0 , InsertText = "")
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                OutPut .= A_LoopField InsertText "`n"
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_TrimLeft(Text, StartLine = 1, EndLine = 0, Count = 1)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                StringTrimLeft, StrOutPut, A_LoopField, %Count%
                OutPut .= StrOutPut "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_TrimRight(Text, StartLine = 1, EndLine = 0, Count = 1)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                StringTrimRight, StrOutPut, A_LoopField, %Count%
                OutPut .= StrOutPut "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_AlignLeft(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
        {
        Trim:=A_AutoTrim ; store trim settings
        AutoTrim, On ; make sure AutoTrim is on
        TF_GetData(OW, Text, FileName)
        If (Endline = 0 OR Endline = "")
            EndLine := TF_Count(Text, "`n") + 1
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace. Trims leading and trailing spaces!
                SpaceNum := Columns-StrLen(LoopField)-1
                If (SpaceNum > 0) and (Padding = 1) ; requires padding + keep padding
                    {
                    Left:=TF_SetWidth(LoopField,Columns, 0) ; align left
                    OutPut .= Left "`n"
                    }
                Else
                    OutPut .= LoopField "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        AutoTrim, %Trim%	; restore original Trim
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_AlignCenter(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
        {
        Trim:=A_AutoTrim ; store trim settings
        AutoTrim, On ; make sure AutoTrim is on
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
                SpaceNum := (Columns-StrLen(LoopField)-1)/2
                If (Padding = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
                    {
                    OutPut .= "`n"
                    Continue
                    }
                If (StrLen(LoopField) >= Columns)
                    {
                    OutPut .= LoopField "`n" ; add as is
                    Continue
                    }
                Centered:=TF_SetWidth(LoopField,Columns, 1) ; align center using set width
                OutPut .= Centered "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        AutoTrim, %Trim%	; restore original Trim
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_AlignRight(Text, StartLine = 1, EndLine = 0, Columns = 80, Skip = 0)
        {
        Trim:=A_AutoTrim ; store trim settings
        AutoTrim, On ; make sure AutoTrim is on
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
                If (Skip = 1) and (LoopField = "") ; skip empty lines, do not fill with spaces
                    {
                    OutPut .= "`n"
                    Continue
                    }
                If (StrLen(LoopField) >= Columns)
                    {
                    OutPut .= LoopField "`n" ; add as is
                    Continue
                    }
                Right:=TF_SetWidth(LoopField,Columns, 2) ; align right using set width
                OutPut .= Right "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        AutoTrim, %Trim%	; restore original Trim
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ; Based on: CONCATenate text files, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
    TF_ConCat(FirstTextFile, SecondTextFile, OutputFile = "", Blanks = 0, FirstPadMargin = 0, SecondPadMargin = 0)
        {
        If (Blanks > 0)
            Loop, %Blanks%
                InsertBlanks .= A_Space
        If (FirstPadMargin > 0)
            Loop, %FirstPadMargin%
                PaddingFile1 .= A_Space
        If (SecondPadMargin > 0)
            Loop, %SecondPadMargin%
                PaddingFile2 .= A_Space
        Text:=FirstTextFile
        TF_GetData(OW, Text, FileName)
        StringSplit, Str1Lines, Text, `n, `r
        Text:=SecondTextFile
        TF_GetData(OW, Text, FileName)
        StringSplit, Str2Lines, Text, `n, `r
        Text= ; clear mem

        ; first we need to determine the file with the most lines for our loop
        If (Str1Lines0 > Str2Lines0)
            MaxLoop:=Str1Lines0
        Else
            MaxLoop:=Str2Lines0
        Loop, %MaxLoop%
            {
            Section1:=Str1Lines%A_Index%
            Section2:=Str2Lines%A_Index%
            OutPut .= Section1 PaddingFile1 InsertBlanks Section2 PaddingFile2 "`n"
            Section1= ; otherwise it will remember the last line from the shortest file or var
            Section2=
            }
        OW=1 ; it is probably 0 so in that case it would create _copy, so set it to 1
        If (OutPutFile = "") ; if OutPutFile is empty return as variable
            OW=2
        Return TF_ReturnOutPut(OW, OutPut, OutputFile, 1, 1)
        }

    TF_LineNumber(Text, Leading = 0, Restart = 0, Char = 0) ; HT ribbet.1
        {
        global t
        TF_GetData(OW, Text, FileName)
        Lines:=TF_Count(Text, "`n") + 1
        Padding:=StrLen(Lines)
        If (Leading = 0) and (Char = 0)
            Char := A_Space
        Loop, %Padding%
            PadLines .= Char
        Loop, Parse, Text, `n, `r
            {
            If Restart = 0
                MaxNo = %A_Index%
            Else
                {
                MaxNo++
                If MaxNo > %Restart%
                    MaxNo = 1
                }
            LineNumber:= MaxNo
            If (Leading = 1)
                {
                LineNumber := Padlines LineNumber ; add padding
                StringRight, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
                }
            If (Leading = 0)
                {
                LineNumber := LineNumber Padlines ; add padding
                StringLeft, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
                }
            OutPut .= LineNumber A_Space A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ; skip = 1, skip shorter lines (e.g. lines shorter startcolumn position)
    ; modified in TF 3.4, fixed in 3.5
    TF_ColGet(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1, Skip = 0)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        If (StartColumn < 0)
            {
            StartColumn++
            Loop, Parse, Text, `n, `r ; parsing file/var
                {
                If A_Index in %TF_MatchList%
                    {
                    output .= SubStr(A_LoopField,StartColumn) "`n"
                    }
                else
                    output .= A_LoopField "`n"
                }
            Return TF_ReturnOutPut(OW, OutPut, FileName)
            }
        if RegExMatch(StartColumn, ",|\+|-")
            {
            StartColumn:=_MakeMatchList(Text, StartColumn, 1, 1)
            Loop, Parse, Text, `n, `r ; parsing file/var
                {
                If A_Index in %TF_MatchList%
                    {
                    loop, parse, A_LoopField ; parsing LINE char by char
                        {
                        If A_Index in %StartColumn% ; if col in index get char
                            output .= A_LoopField
                        }
                    output .= "`n"
                    }
                else
                    output .= A_LoopField "`n"
                }
            output .= A_LoopField "`n"
            }
        else
            {
            EndColumn:=(EndColumn+1)-StartColumn
            Loop, Parse, Text, `n, `r
                {
                If A_Index in %TF_MatchList%
                    {
                    StringMid, Section, A_LoopField, StartColumn, EndColumn
                    If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
                        Continue
                    OutPut .= Section "`n"
                    }
                }
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ; Based on: COLPUT.EXE & CUT.EXE, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
    ; modified in TF 3.4
    TF_ColPut(Text, Startline = 1, EndLine = 0, StartColumn = 1, InsertText = "", Skip = 0)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        If RegExMatch(StartColumn, ",|\+")
            {
            StartColumn:=_MakeMatchList(Text, StartColumn, 0, 1)
            Loop, Parse, Text, `n, `r ; parsing file/var
                {
                If A_Index in %TF_MatchList%
                    {
                    loop, parse, A_LoopField ; parsing LINE char by char
                        {
                        If A_Index in %StartColumn% ; if col in index insert text
                            output .= InsertText A_LoopField
                        Else
                            output .= A_LoopField
                        }
                    output .= "`n"
                    }
                else
                    output .= A_LoopField "`n"
                }
            output .= A_LoopField "`n"
            }
        else
            {
            StartColumn--
            Loop, Parse, Text, `n, `r
                {
                If A_Index in %TF_MatchList%
                    {
                    If (StartColumn > 0)
                        {
                        StringLeft, Section1, A_LoopField, StartColumn
                        StringMid, Section2, A_LoopField, StartColumn+1
                        If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
                            OutPut .= Section1 Section2 "`n"
                        }
                    Else
                        {
                        Section1:=SubStr(A_LoopField, 1, StrLen(A_LoopField) + StartColumn + 1)
                        Section2:=SubStr(A_LoopField, StrLen(A_LoopField) + StartColumn + 2)
                        If (Skip = 1) and (A_LoopField = "")
                            OutPut .= Section1 Section2 "`n"
                        }
                    OutPut .= Section1 InsertText Section2 "`n"
                    }
                Else
                    OutPut .= A_LoopField "`n"
                }
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ; modified TF 3.4
    TF_ColCut(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        If RegExMatch(StartColumn, ",|\+|-")
            {
            StartColumn:=_MakeMatchList(Text, StartColumn, EndColumn, 1)
            Loop, Parse, Text, `n, `r ; parsing file/var
                {
                If A_Index in %TF_MatchList%
                    {
                    loop, parse, A_LoopField ; parsing LINE char by char
                        {
                        If A_Index not in %StartColumn% ; if col not in index get char
                            output .= A_LoopField
                        }
                    output .= "`n"
                    }
                else
                    output .= A_LoopField "`n"
                }
            output .= A_LoopField "`n"
            }
        else
            {
            StartColumn--
            EndColumn++
            Loop, Parse, Text, `n, `r
                {
                If A_Index in %TF_MatchList%
                    {
                    StringLeft, Section1, A_LoopField, StartColumn
                    StringMid, Section2, A_LoopField, EndColumn
                    OutPut .= Section1 Section2 "`n"
                    }
                Else
                    OutPut .= A_LoopField "`n"
                }
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_ReverseLines(Text, StartLine = 1, EndLine = 0)
        {
        TF_GetData(OW, Text, FileName)
        StringSplit, Line, Text, `n, `r ; line0 is number of lines
        If (EndLine = 0 OR EndLine = "")
            EndLine:=Line0
        If (EndLine > Line0)
            EndLine:=Line0
        CountDown:=EndLine+1
        Loop, Parse, Text, `n, `r
            {
            If (A_Index < StartLine)
                Output1 .= A_LoopField "`n" ; section1
            If A_Index between %StartLine% and %Endline%
                {
                CountDown--
                Output2 .= Line%CountDown% "`n" section2
                }
            If (A_Index > EndLine)
                Output3 .= A_LoopField "`n"
            }
        OutPut.= Output1 Output2 Output3
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ;TF_SplitFileByLines
    ;example:
    ;TF_SplitFileByLines("TestFile.txt", "4", "sfile_", "txt", "1") ; split file every 3 lines
    ; InFile = 0 skip line e.g. do not include the actual line in any of the output files
    ; InFile = 1 include line IN current file
    ; InFile = 2 include line IN next file
    TF_SplitFileByLines(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
        {
        LineCounter=1
        FileCounter=1
        Where:=SplitAt
        Method=1
        ; 1 = default, splitat every X lines,
        ; 2 = splitat: - rotating if applicable
        ; 3 = splitat: specific lines comma separated
        TF_GetData(OW, Text, FileName)

        IfInString, SplitAt, `- ; method 2
            {
            StringSplit, Split, SplitAt, `-
            Part=1
            Where:=Split%Part%
            Method=2
            }
        IfInString, SplitAt, `, ; method 3
            {
            StringSplit, Split, SplitAt, `,
            Part=1
            Where:=Split%Part%
            Method=3
            }
        Loop, Parse, Text, `n, `r
            {
            OutPut .= A_LoopField "`n"
            If (LineCounter = Where)
                {
                If (InFile = 0)
                    {
                    StringReplace, CheckOutput, PreviousOutput, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; skip empty files
                        TF_SetGlobal(Prefix FileCounter,PreviousOutput)
                    Output:=
                    }
                If (InFile = 1)
                    {
                    StringReplace, CheckOutput, Output, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; skip empty files
                        TF_SetGlobal(Prefix FileCounter,Output)
                    Output:=
                    }
                If (InFile = 2)
                    {
                    OutPut := PreviousOutput
                    StringReplace, CheckOutput, Output, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; output to array
                        TF_SetGlobal(Prefix FileCounter,Output)
                    OutPut := A_LoopField "`n"
                    }
                If (Method <> 3)
                    LineCounter=0 ; reset
                FileCounter++ ; next file
                Part++
                If (Method = 2) ; 2 = splitat: - rotating if applicable
                    {
                If (Part > Split0)
                        {
                        Part=1
                        }
                    Where:=Split%Part%
                    }
                If (Method = 3) ; 3 = splitat: specific lines comma separated
                    {
                    If (Part > Split0)
                        Where:=Split%Split0%
                    Else
                        Where:=Split%Part%
                    }
                }
            LineCounter++
            PreviousOutput:=Output
            PreviousLine:=A_LoopField
            }
        StringReplace, CheckOutput, Output, `n, , All
        StringReplace, CheckOutput, CheckOutput, `r, , All
        If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
        If (CheckOutput <> "") and (OW = 2) ; output to array
            {
            TF_SetGlobal(Prefix FileCounter,Output)
            TF_SetGlobal(Prefix . "0" , FileCounter)
            }
        }

    ; TF_SplitFileByText("TestFile.txt", "button", "sfile_", "txt") ; split file at every line with button in it, can be regexp
    ; InFile = 0 skip line e.g. do not include the actual line in any of the output files
    ; InFile = 1 include line IN current file
    ; InFile = 2 include line IN next file
    TF_SplitFileByText(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
        {
        LineCounter=1
        FileCounter=1
        TF_GetData(OW, Text, FileName)
        SplitPath, TextFile,, Dir
        Loop, Parse, Text, `n, `r
            {
            OutPut .= A_LoopField "`n"
            FoundPos:=RegExMatch(A_LoopField, SplitAt)
            If (FoundPos > 0)
                {
                If (InFile = 0)
                    {
                    StringReplace, CheckOutput, PreviousOutput, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; output to array
                        TF_SetGlobal(Prefix FileCounter,PreviousOutput)
                    Output:=
                    }
                If (InFile = 1)
                    {
                    StringReplace, CheckOutput, Output, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; output to array
                        TF_SetGlobal(Prefix FileCounter,Output)
                    Output:=
                    }
                If (InFile = 2)
                    {
                    OutPut := PreviousOutput
                    StringReplace, CheckOutput, Output, `n, , All
                    StringReplace, CheckOutput, CheckOutput, `r, , All
                    If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                        TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
                    If (CheckOutput <> "") and (OW = 2) ; output to array
                        TF_SetGlobal(Prefix FileCounter,Output)
                    OutPut := A_LoopField "`n"
                    }
                LineCounter=0 ; reset
                FileCounter++ ; next file
                }
            LineCounter++
            PreviousOutput:=Output
            PreviousLine:=A_LoopField
            }
        StringReplace, CheckOutput, Output, `n, , All
        StringReplace, CheckOutput, CheckOutput, `r, , All
        If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
            TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1)
        If (CheckOutput <> "") and (OW = 2) ; output to array
            {
            TF_SetGlobal(Prefix FileCounter,Output)
            TF_SetGlobal(Prefix . "0" , FileCounter)
            }
        }

    TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
        {
        options:="^[imsxADJUXPS]+\)"
        if RegExMatch(searchText,options,o)
            searchText:=RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0(*ANYCRLF)" : "$0"))
        else searchText:="m)(*ANYCRLF)" searchText
        options:="^[imsxADJUXPS]+\)" ; Hat tip to sinkfaze, see http://www.autohotkey.com/forum/viewtopic.php?t=60062
        if RegExMatch(searchText,options,o)
            searchText := RegExReplace(searchText,options,(!InStr(o,"m") ? "m$0" : "$0"))
        else searchText := "m)" . searchText

        TF_GetData(OW, Text, FileName)
        If (RegExMatch(Text, SearchText) < 1)
            Return "0" ; SearchText not in file or error, so do nothing

        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                If (RegExMatch(A_LoopField, SearchText) > 0)
                    {
                    If (ReturnText = 0)
                        Lines .= A_Index "," ; line number
                    Else If (ReturnText = 1)
                        Lines .= A_LoopField "`n" ; text of line
                    Else If (ReturnText = 2)
                        Lines .= A_Index ": " A_LoopField "`n" ; add line number
                    If (ReturnFirst = 1) ; only return first occurrence
                        Break
                    }
                }
            }
        If (Lines <> "")
            StringTrimRight, Lines, Lines, 1 ; trim trailing , or `n
        Else
            Lines = 0 ; make sure we return 0
        Return Lines
        }

    TF_Prepend(File1, File2)
        {
    FileList=
    (
    %File1%
    %File2%
    )
    TF_Merge(FileList,"`n", "!" . File2)
    Return
        }

    TF_Append(File1, File2)
        {
    FileList=
    (
    %File2%
    %File1%
    )
    TF_Merge(FileList,"`n", "!" . File2)
    Return
        }

    ; For TF_Merge You will need to create a Filelist variable, one file per line,
    ; to pass on to the function:
    ; FileList=
    ; (
    ; c:\file1.txt
    ; c:\file2.txt
    ; )
    ; use Loop (files & folders) to create one quickly if you want to merge all TXT files for example
    ;
    ; Loop, c:\*.txt
    ;   FileList .= A_LoopFileFullPath "`n"
    ;
    ; By default, a new line is used as a separator between two text files
    ; !merged.txt deletes target file before starting to merge files
    TF_Merge(FileList, Separator = "`n", FileName = "merged.txt")
        {
        OW=0
        Loop, Parse, FileList, `n, `r
            {
            Append2File= ; Just make sure it is empty
            IfExist, %A_LoopField%
                {
                FileRead, Append2File, %A_LoopField%
                If not ErrorLevel ; Successfully loaded
                    Output .= Append2File Separator
                }
            }

        If (SubStr(FileName,1,1)="!") ; check if we want to delete the target file before we start
            {
            FileName:=SubStr(FileName,2)
            OW=1
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName, 0, 1)
        }

    TF_Wrap(Text, Columns = 80, AllowBreak = 0, StartLine = 1, EndLine = 0)
        {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        If (AllowBreak = 1)
            Break=
        Else
            Break=[ \r?\n]
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                If (StrLen(A_LoopField) > Columns)
                    {
                    LoopField := A_LoopField " " ; just seems to work better by adding a space
                    OutPut .= RegExReplace(LoopField, "(.{1," . Columns . "})" . Break , "$1`n")
                    }
                Else
                    OutPut .= A_LoopField "`n"
                }
            Else
                OutPut .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_WhiteSpace(Text, RemoveLeading = 1, RemoveTrailing = 1, StartLine = 1, EndLine = 0) {
        TF_GetData(OW, Text, FileName)
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
        Trim:=A_AutoTrim ; store trim settings
        AutoTrim, On ; make sure AutoTrim is on
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                If (RemoveLeading = 1) AND (RemoveTrailing = 1)
                    {
                    LoopField = %A_LoopField%
                    Output .= LoopField "`n"
                        Continue
                    }
                If (RemoveLeading = 1) AND (RemoveTrailing = 0)
                    {
                    LoopField := A_LoopField . "."
                    LoopField = %LoopField%
                    StringTrimRight, LoopField, LoopField, 1
                    Output .= LoopField "`n"
                        Continue
                    }
                If (RemoveLeading = 0) AND (RemoveTrailing = 1)
                    {
                    LoopField := "." A_LoopField
                    LoopField = %LoopField%
                    StringTrimLeft, LoopField, LoopField, 1
                    Output .= LoopField "`n"
                        Continue
                    }
                If (RemoveLeading = 0) AND (RemoveTrailing = 0)
                    {
                    Output .= A_LoopField "`n"
                        Continue
                    }
                }
            Else
                Output .= A_LoopField "`n"
            }
        AutoTrim, %Trim%	; restore original Trim
        Return TF_ReturnOutPut(OW, OutPut, FileName)
    }

    ; Delete lines from file1 in file2 (using StringReplace)
    ; Partialmatch = 2 added in 3.4
    TF_Substract(File1, File2, PartialMatch = 0) {
        Text:=File1
        TF_GetData(OW, Text, FileName)
        Str1:=Text
        Text:=File2
        TF_GetData(OW, Text, FileName)
            OutPut:=Text
        If (OW = 2)
            File1= ; free mem in case of var/text
        OutPut .= "`n" ; just to make sure the StringReplace will work

        If (PartialMatch = 2)
            {
            Loop, Parse, Str1, `n, `r
                {
                IfInString, Output, %A_LoopField%
                    {
                    Output:= RegExReplace(Output, "im)^.*" . A_LoopField . ".*\r?\n?", replace)
                    }
                }
            }
        Else If (PartialMatch = 1) ; allow paRTIal match
            {
            Loop, Parse, Str1, `n, `r
                StringReplace, Output, Output, %A_LoopField%, , All ; remove lines from file1 in file2
            }
        Else If (PartialMatch = 0)
            {
            search:="m)^(.*)$"
            replace=__bol__$1__eol__
            Output:=RegExReplace(Output, search, replace)
            StringReplace, Output, Output, `n__eol__,__eol__ , All ; strange fix but seems to be needed.
            Loop, Parse, Str1, `n, `r
                StringReplace, Output, Output, __bol__%A_LoopField%__eol__, , All ; remove lines from file1 in file2
            }
        If (PartialMatch = 0)
            {
            StringReplace, Output, Output, __bol__, , All
            StringReplace, Output, Output, __eol__, , All
            }

        ; Remove all blank lines from the text in a variable:
        Loop
            {
            StringReplace, Output, Output, `r`n`r`n, `r`n, UseErrorLevel
            if (ErrorLevel = 0) or (ErrorLevel = 1) ; No more replacements needed.
                break
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName, 0)
    }

    ; Similar to "BK Replace EM" RangeReplace
    TF_RangeReplace(Text, SearchTextBegin, SearchTextEnd, ReplaceText = "", CaseSensitive = "False", KeepBegin = 0, KeepEnd = 0)
        {
        TF_GetData(OW, Text, FileName)
        IfNotInString, Text, %SearchText%
            Return Text ; SearchTextBegin not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
        Start = 0
        End = 0
        If (KeepBegin = 1)
            KeepBegin:=SearchTextBegin
        Else
            KeepBegin=
        If (KeepEnd = 1)
            KeepEnd:= SearchTextEnd
        Else
            KeepEnd=
        If (SearchTextBegin = "")
            Start=1
        If (SearchTextEnd = "")
            End=2

        Loop, Parse, Text, `n, `r
            {
            If (End = 1) ; end has been found already, replacement made simply continue to add all lines
                {
                Output .= A_LoopField "`n"
                    Continue
                }
            If (Start = 0) ; start hasn't been found
                {
                If (InStr(A_LoopField,SearchTextBegin,CaseSensitive)) ; start has been found
                    {
                    Start = 1
                    KeepSection := SubStr(A_LoopField, 1, InStr(A_LoopField, SearchTextBegin)-1)
                    EndSection := SubStr(A_LoopField, InStr(A_LoopField, SearchTextBegin)-1)
                    ; check if SearchEndText is in second part of line
                    If (InStr(EndSection,SearchTextEnd,CaseSensitive)) ; end found
                        {
                        EndSection := ReplaceText KeepEnd SubStr(EndSection, InStr(EndSection, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
                        If (End <> 2)
                            End=1
                        If (End = 2)
                            EndSection=
                        }
                    Else
                        EndSection=
                    Output .= KeepSection KeepBegin EndSection
                    Continue
                    }
                Else
                    Output .= A_LoopField "`n" ; if not found yet simply add
                    }
            If (Start = 1) and (End <> 2) ; start has been found, now look for end if end isn't an empty string
                {
                If (InStr(A_LoopField,SearchTextEnd,CaseSensitive)) ; end found
                    {
                    End = 1
                    Output .= ReplaceText KeepEnd SubStr(A_LoopField, InStr(A_LoopField, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
                    }
                }
            }
        If (End = 2)
            Output .= ReplaceText
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ; Create file of X lines and Y columns, fill with space or other character(s)
    TF_MakeFile(Text, Lines = 1, Columns = 1, Fill = " ")
        {
        OW=1
        If (Text = "") ; if OutPutFile is empty return as variable
            OW=2
        Loop, % Columns
            Cols .= Fill
        Loop, % Lines
            Output .= Cols "`n"
        Return TF_ReturnOutPut(OW, OutPut, Text, 1, 1)
        }

    ; Convert tabs to spaces, shorthand for TF_ReplaceInLines
    TF_Tab2Spaces(Text, TabStop = 4, StartLine = 1, EndLine =0)
        {
        Loop, % TabStop
            Replace .= A_Space
        Return TF_ReplaceInLines(Text, StartLine, EndLine, A_Tab, Replace)
        }

    ; Convert spaces to tabs, shorthand for TF_ReplaceInLines
    TF_Spaces2Tab(Text, TabStop = 4, StartLine = 1, EndLine =0)
        {
        Loop, % TabStop
            Replace .= A_Space
        Return TF_ReplaceInLines(Text, StartLine, EndLine, Replace, A_Tab)
        }

    ; Sort (section of) a text file
    TF_Sort(Text, SortOptions = "", StartLine = 1, EndLine = 0) ; use the SORT options http://www.autohotkey.com/docs/commands/Sort.htm
        {
        TF_GetData(OW, Text, FileName)
        If StartLine contains -,+,`, ; no sections, incremental or multiple line input
            Return
        If (StartLine = 1) and (Endline = 0) ; process entire file
            {
            Output:=Text
            Sort, Output, %SortOptions%
            }
        Else
            {
            Output := TF_ReadLines(Text, 1, StartLine-1) ; get first section
            ToSort := TF_ReadLines(Text, StartLine, EndLine) ; get section to sort
            Sort, ToSort, %SortOptions%
            OutPut .= ToSort
            OutPut .= TF_ReadLines(Text, EndLine+1) ; append last section
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    TF_Tail(Text, Lines = 1, RemoveTrailing = 0, ReturnEmpty = 1)
        {
        TF_GetData(OW, Text, FileName)
        Neg = 0
        If (Lines < 0)
            {
            Neg=1
            Lines:= Lines * -1
            }
        If (ReturnEmpty = 0) ; remove blank lines first so we can't return any blank lines anyway
            {
            Loop, Parse, Text, `n, `r
                OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
            StringTrimRight, OutPut, OutPut, 1 ; remove trailing `n added by loop above
            Text:=OutPut
            OutPut=
        }
        If (Neg = 1) ; get only one line!
            {
            Lines++
            Output:=Text
            StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
            StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
            StringGetPos, Pos, Output, `n
            StringLeft, Output, Output, % Pos
            Output .= "`n"
            }
        Else
            {
            Output:=Text
            StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
            StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
            Output .= "`n"
            }
        OW = 2 ; make sure we return variable not process file
        Return TF_ReturnOutPut(OW, OutPut, FileName, RemoveTrailing)
        }

    TF_Count(String, Char)
        {
        StringReplace, String, String, %Char%,, UseErrorLevel
        Return ErrorLevel
        }

    TF_Save(Text, FileName, OverWrite = 1) { ; HugoV write file
        Return TF_ReturnOutPut(OverWrite, Text, FileName, 0, 1)
        }

    TF(TextFile, CreateGlobalVar = "T") { ; read contents of file in output and %output% as global var ...  http://www.autohotkey.com/forum/viewtopic.php?p=313120#313120
        global
        FileRead, %CreateGlobalVar%, %TextFile%
        Return, (%CreateGlobalVar%)
        }

    ; TF_Join
    ; SmartJoin: Detect if CHAR(s) is/are already present at the end of the line before joining the next, this to prevent unnecessary double spaces for example.
    ; Char: character(s) to use between new lines, defaults to a space. To use nothing use ""
    TF_Join(Text, StartLine = 1, EndLine = 0, SmartJoin = 0, Char = 0)
        {
        If ( (InStr(StartLine,",") > 0) AND (InStr(StartLine,"-") = 0) ) OR (InStr(StartLine,"+") > 0)
            Return Text ; can't do multiplelines, only multiple sections of lines e.g. "1,5" bad "1-5,15-10" good, "2+2" also bad
        TF_GetData(OW, Text, FileName)
        If (InStr(Text,"`n") = 0)
            Return Text ; there are no lines to join so just return Text
        If (InStr(StartLine,"-") > 0)	; OK, we need some counter-intuitive string mashing to substract ONE from the "endline" parameter
            {
            Loop, Parse, StartLine, CSV
                {
                StringSplit, part, A_LoopField, -
                NewStartLine .= part1 "-" (part2-1) ","
                }
            StringTrimRight, StartLine, NewStartLine, 1
            }
        If (Endline > 0)
            Endline--
        TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc)
        If (Char = 0)
            Char:=A_Space
        Char_Org:=Char
        GetRightLen:=StrLen(Char)-1
        Loop, Parse, Text, `n, `r
            {
            If A_Index in %TF_MatchList%
                {
                If (SmartJoin = 1)
                    {
                    GetRightText:=SubStr(A_LoopField,0)
                    If (GetRightText = Char)
                        Char=
                    }
                Output .= A_LoopField Char
                Char:=Char_Org
                }
            Else
                Output .= A_LoopField "`n"
            }
        Return TF_ReturnOutPut(OW, OutPut, FileName)
        }

    ;----- Helper functions ----------------

    TF_SetGlobal(var, content = "") ; helper function for TF_Split* to return array and not files, credits Tuncay :-)
        {
        global
        %var% := content
        }

    ; Helper function to determine if VAR/TEXT or FILE is passed to TF
    ; Update 11 January 2010 (skip filecheck if `n in Text -> can't be file)
    TF_GetData(byref OW, byref Text, byref FileName)
        {
        If (text = 0 "") ; v3.6 -> v3.7 https://github.com/hi5/TF/issues/4 and https://autohotkey.com/boards/viewtopic.php?p=142166#p142166 in case user passes on zero/zeros ("0000") as text - will error out when passing on one 0 and there is no file with that name
            {
            IfNotExist, %Text% ; additional check to see if a file 0 exists
                {
                MsgBox, 48, TF Lib Error, % "Read Error - possible reasons (see documentation):`n- Perhaps you used !""file.txt"" vs ""!file.txt""`n- A single zero (0) was passed on to a TF function as text"
                ExitApp
                }
            }
        OW=0 ; default setting: asume it is a file and create file_copy
        IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
            {
            If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
                {
                Text:=SubStr(Text,2)
                OW=1 ; overwrite file (if it is a file)
                }
            IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
                {
                If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
                    Text:= "!" . Text
                OW=2 ; no file, so it is a var or Text passed on directly to TF
                }
            }
        Else ; there is a newline character in Text so it has to be a variable
            {
            OW=2
            }
        If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
            {
            Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
            FileName=%Text% ; Store FileName
            FileRead, Text, %Text% ; Read file and return as var Text
            If (ErrorLevel > 0)
                {
                MsgBox, 48, TF Lib Error, % "Can not read " FileName
                ExitApp
                }
            }
        Return
        }

    ; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
    ; SetWidth() : SetWidth increases a String's length by adding spaces to it and aligns it Left/Center/Right. ( Requires Space() )
    TF_SetWidth(Text,Width,AlignText)
        {
        If (AlignText!=0 and AlignText!=1 and AlignText!=2)
            AlignText=0
        If AlignText=0
            {
            RetStr= % (Text)TF_Space(Width)
            StringLeft, RetText, RetText, %Width%
            }
        If AlignText=1
            {
            Spaces:=(Width-(StrLen(Text)))
            RetStr= % TF_Space(Round(Spaces/2))(Text)TF_Space(Spaces-(Round(Spaces/2)))
            }
        If AlignText=2
            {
            RetStr= % TF_Space(Width)(Text)
            StringRight, RetStr, RetStr, %Width%
            }
        Return RetStr
        }

    ; Skan - http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
    TF_Space(Width)
        {
        Loop,%Width%
            Space=% Space Chr(32)
        Return Space
        }

    ; Write to file or return variable depending on input
    TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) {
        If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
            {
            IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
                {
                If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
                    {
                    OW = 1
                    Goto CreateNewFile
                    }
                Else
                    Return
                }
            If (TrimTrailing = 1)
                StringTrimRight, Text, Text, 1 ; remove trailing `n
            SplitPath, FileName,, Dir, Ext, Name
            If (Dir = "") ; if Dir is empty Text & script are in same directory
                Dir := A_WorkingDir
            IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
                FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
            FileDelete, % Dir "\" Name "_copy." Ext
            FileAppend, %Text%, % Dir "\" Name "_copy." Ext
            Return Errorlevel ? False : True
            }
        CreateNewFile:
        If (OW = 1) ; input was file, will be overwritten by output
            {
            IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
                {
                If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
                    Return
                }
            If (TrimTrailing = 1)
                StringTrimRight, Text, Text, 1 ; remove trailing `n
            SplitPath, FileName,, Dir, Ext, Name
            If (Dir = "") ; if Dir is empty Text & script are in same directory
                Dir := A_WorkingDir
            IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
                FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
            FileDelete, % Dir "\" Name "." Ext
            FileAppend, %Text%, % Dir "\" Name "." Ext
            Return Errorlevel ? False : True
            }
        If (OW = 2) ; input was var, return variable
            {
            If (TrimTrailing = 1)
                StringTrimRight, Text, Text, 1 ; remove trailing `n
            Return Text
            }
        }

    ; _MakeMatchList()
    ; Purpose:
    ; Make a MatchList which is used in various functions
    ; Using a MatchList gives greater flexibility so you can process multiple
    ; sections of lines in one go avoiding repetitive fileread/append actions
    ; For TF 3.4 added COL = 0/1 option (for TF_Col* functions) and CallFunc for
    ; all TF_* functions to facilitate bug tracking
    _MakeMatchList(Text, Start = 1, End = 0, Col = 0, CallFunc = "Not available")
        {
        ErrorList=
        (join|
    Error 01: Invalid StartLine parameter (non numerical character)`nFunction used: %CallFunc%
    Error 02: Invalid EndLine parameter (non numerical character)`nFunction used: %CallFunc%
    Error 03: Invalid StartLine parameter (only one + allowed)`nFunction used: %CallFunc%
        )
        StringSplit, ErrorMessage, ErrorList, |
        Error = 0

        If (Col = 1)
            {
            LongestLine:=TF_Stat(Text)
            If (End > LongestLine) or (End = 1) ; FIXITHERE BUG
                End:=LongestLine
            }

        TF_MatchList= ; just to be sure
        If (Start = 0 or Start = "")
            Start = 1

        ; some basic error checking

        ; error: only digits - and + allowed
        If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
            Error = 1

        If (RegExReplace(End, "[0-9 ]", "") <> "")
            Error = 2

        ; error: only one + allowed
        If (TF_Count(Start,"+") > 1)
            Error = 3

        If (Error > 0 )
            {
            MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
            ExitApp
            }

        ; Option #0 [ added 30-Oct-2010 ]
        ; Startline has negative value so process X last lines of file
        ; endline parameter ignored

        If (Start < 0) ; remove last X lines from file, endline parameter ignored
            {
            Start:=TF_CountLines(Text) + Start + 1
            End=0 ; now continue
            }

        ; Option #1
        ; StartLine has + character indicating startline + incremental processing.
        ; EndLine will be used
        ; Make TF_MatchList

        IfInString, Start, `+
            {
            If (End = 0 or End = "") ; determine number of lines
                End:= TF_Count(Text, "`n") + 1
            StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
            Loop, %Section0%
                {
                StringSplit, SectionLines, Section%A_Index%, `+
                LoopSection:=End + 1 - SectionLines1
                Counter=0
                    TF_MatchList .= SectionLines1 ","
                Loop, %LoopSection%
                    {
                    If (A_Index >= End) ;
                        Break
                    If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
                        {
                        TF_MatchList .= (SectionLines1 + A_Index) ","
                        Counter=0
                        }
                    Else
                        Counter++
                    }
                }
            StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
            Return TF_MatchList
            }

        ; Option #2
        ; StartLine has - character indicating from-to, COULD be multiple sections.
        ; EndLine will be ignored
        ; Make TF_MatchList

        IfInString, Start, `-
            {
            StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
            Loop, %Section0%
                {
                StringSplit, SectionLines, Section%A_Index%, `-
                LoopSection:=SectionLines2 + 1 - SectionLines1
                Loop, %LoopSection%
                    {
                    TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
                    }
                }
            StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
            Return TF_MatchList
            }

        ; Option #3
        ; StartLine has comma indicating multiple lines.
        ; EndLine will be ignored

        IfInString, Start, `,
            {
            TF_MatchList:=Start
            Return TF_MatchList
            }

        ; Option #4
        ; parameters passed on as StartLine, EndLine.
        ; Make TF_MatchList from StartLine to EndLine

        If (End = 0 or End = "") ; determine number of lines
                End:= TF_Count(Text, "`n") + 1
        LoopTimes:=End-Start
        Loop, %LoopTimes%
            {
            TF_MatchList .= (Start - 1 + A_Index) ","
            }
        TF_MatchList .= End ","
        StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
        Return TF_MatchList
        }

    ; added for TF 3.4 col functions - currently only gets longest line may change in future
    TF_Stat(Text)
        {
        TF_GetData(OW, Text, FileName)
        Sort, Text, f _AscendingLinesL
        Pos:=InStr(Text,"`n")-1
        Return pos
        }

    _AscendingLinesL(a1, a2) ; used by TF_Stat
        {
        Return StrLen(a2) - StrLen(a1)
        }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/* XGraph v1.1.1.0 : Real time data plotting.
*  Script      :  XGraph v1.1.1.0 : Real time data plotting.
*                 http://ahkscript.org/boards/viewtopic.php?t=3492
*                 Created: 24-Apr-2014,  Last Modified: 09-May-2014 
*
*  Description :  Easy to use, Light weight, fast, efficient GDI based function library for 
*                 graphically plotting real time data.
*
*  Author      :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
*  Demos       :  CPU Load Monitor > http://ahkscript.org/boards/viewtopic.php?t=3413
- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
*/

    XGraph( hCtrl, hBM := 0, ColumnW := 3, LTRB := "0,2,0,2", PenColor := 0x808080, PenSize := 1, SV := 0 ) {
    Static WM_SETREDRAW := 0xB, STM_SETIMAGE := 0x172, PS_SOLID := 0, cbSize := 136, SRCCOPY := 0x00CC0020 
        , GPTR := 0x40, OBJ_BMP := 0x7, LR_CREATEDIBSECTION := 0x2000, LR_COPYDELETEORG := 0x8

    ; Validate control  
    WinGetClass, Class,   ahk_id %hCtrl%  
    Control, Style, +0x5000010E,, ahk_id %hCtrl% 
    ControlGet, Style, Style,,, ahk_id %hCtrl%
    ControlGet, ExStyle, ExStyle,,, ahk_id %hCtrl%
    ControlGetPos,,, CtrlW, CtrlH,, ahk_id %hCtrl% 
    If not ( Class == "Static" and Style = 0x5000010E and ExStyle = 0 and CtrlW > 0 and CtrlH > 0 ) 
        Return 0, ErrorLevel := -1

    ; Validate Bitmap
    If ( DllCall( "GetObjectType", "Ptr",hBM ) <> OBJ_BMP )
        hTargetBM := DllCall( "CreateBitmap", "Int",2, "Int",2, "UInt",1, "UInt",16, "Ptr",0, "Ptr" )
        ,  hTargetBM := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",CtrlW, "Int",CtrlH
                            , "UInt",LR_CREATEDIBSECTION|LR_COPYDELETEORG, "Ptr" )
    else hTargetBM := hBM  

    VarSetCapacity( BITMAP,32,0 )    
    DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
    If NumGet( BITMAP, 18, "UInt" ) < 16 ; Checking if BPP < 16  
        Return 0, ErrorLevel := -2
    Else BitmapW := NumGet( BITMAP,  4, "UInt" ),  BitmapH := NumGet( BITMAP, 8, "UInt" )     
    If ( BitmapW <> CtrlW or BitmapH <> CtrlH )               
        Return 0, ErrorLevel := -3

    ; Validate Margins and Column width   
    StringSplit, M, LTRB, `, , %A_Space% ; Left,Top,Right,Bottom
    MarginL := ( M1+0 < 0 ? 0 : M1 ),    MarginT     := ( M2+0 < 0 ? 0 : M2 )
    MarginR := ( M3+0 < 0 ? 0 : M3 ),    MarginB     := ( M4+0 < 0 ? 0 : M4 )  
    ColumnW := ( ColumnW+0 < 0 ? 3 : ColumnW & 0xff ) ; 1 - 255

    ; Derive Columns, BitBlt dimensions, Movement coords for Lineto() and MoveToEx()  
    Columns := ( BitmapW - MarginL - MarginR ) // ColumnW 
    BitBltW := Columns* ColumnW,                BitBltH := BitmapH - MarginT - MarginB
    MX1     := BitBltW - ColumnW,                    MY1 := BitBltH - 1 
    MX2     := MX1 + ColumnW - ( PenSize < 1 ) ;     MY2 := < user defined >

    ; Initialize Memory Bitmap
    hSourceDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" ) 
    hSourceBM  := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",ColumnW* 2 + BitBltW
                        , "Int",BitBltH, "UInt",LR_CREATEDIBSECTION, "Ptr" )   
    DllCall( "SaveDC", "Ptr",hSourceDC ) 
    DllCall( "SelectObject", "Ptr",hSourceDC, "Ptr",hSourceBM )

    hTempDC    := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
    DllCall( "SaveDC", "Ptr",hTempDC )
    DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTargetBM )

    If ( hTargetBM <> hBM )
        hBrush := DllCall( "CreateSolidBrush", UInt,hBM & 0xFFFFFF, "Ptr" )
    , VarSetCapacity( RECT, 16, 0 )
    , NumPut( BitmapW, RECT, 8, "UInt" ),  NumPut( BitmapH, RECT,12, "UInt" )
    , DllCall( "FillRect", "Ptr",hTempDC, "Ptr",&RECT, "Ptr",hBrush )
    , DllCall( "DeleteObject", "Ptr",hBrush )
    
    DllCall( "BitBlt", "Ptr",hSourceDC, "Int",ColumnW* 2, "Int",0, "Int",BitBltW, "Int",BitBltH
                    , "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )
    DllCall( "BitBlt", "Ptr",hSourceDC, "Int",0, "Int",0, "Int",BitBltW, "Int",BitBltH
                    , "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )

    ; Validate Pen color / Size                                                                    
    PenColor   := ( PenColor + 0 <> "" ? PenColor & 0xffffff : 0x808080 ) ; Range: 000000 - ffffff
    PenSize    := ( PenSize  + 0 <> "" ? PenSize & 0xf : 1 )              ; Range: 0 - 15                
    hSourcePen := DllCall( "CreatePen", "Int",PS_SOLID, "Int",PenSize, "UInt",PenColor, "Ptr" )
    DllCall( "SelectObject", "Ptr",hSourceDC, "Ptr",hSourcePen )
    DllCall( "MoveToEx", "Ptr",hSourceDC, "Int",MX1, "Int",MY1, "Ptr",0 )

    hTargetDC := DllCall( "GetDC", "Ptr",hCtrl, "Ptr" ) 
    DllCall( "BitBlt", "Ptr",hTargetDC, "Int",0, "Int",0, "Int",BitmapW, "Int",BitmapH
                    , "Ptr",hTempDC,   "Int",0, "Int",0, "UInt",SRCCOPY ) 

    DllCall( "RestoreDC", "Ptr",hTempDC, "Int",-1 )
    DllCall( "DeleteDC",  "Ptr",hTempDC )    

    DllCall( "SendMessage", "Ptr",hCtrl, "UInt",WM_SETREDRAW, "Ptr",False, "Ptr",0 ) 
    hOldBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_SETIMAGE, "Ptr",0, "Ptr",hTargetBM )    
    DllCall( "SendMessage", "Ptr",hCtrl, "UInt",WM_SETREDRAW, "Ptr",True,  "Ptr",0 )
    DllCall( "DeleteObject", "Ptr",hOldBM )

    ; Create / Update Graph structure
    DataSz := ( SV = 1 ? Columns* 8 : 0 )
    pGraph := DllCall( "GlobalAlloc", "UInt",GPTR, "Ptr",cbSize + DataSz, "UPtr" )
    NumPut( DataSz, pGraph + cbSize - 8   )     
    VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen / ColumnW / Columns / "
            . "MarginL / MarginT / MarginR / MarginB / MX1 / MX2 / BitBltW / BitBltH" 
    Loop, Parse, VarL, /, %A_Space%
        NumPut( %A_LoopField%, pGraph + 0, ( A_Index - 1 )* 8 )

    Return pGraph          
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_Info( pGraph, FormatFloat := "" ) {
    Static STM_GETIMAGE := 0x173
    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1 
    T := "`t",  TT := "`t:`t",  LF := "`n", SP := "                "

    pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData-8 )
    If ( FormatFloat <> "" and DataSz )
        GoTo, XGraph_Info_Data  
    
    VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen / ColumnW / Columns / "
            . "MarginL / MarginT / MarginR / MarginB / MX1 / MX2 / BitBltW / BitBltH" 
    Loop, Parse, VarL, /, %A_Space%
        Offset := ( A_Index - 1 )* 8,         %A_LoopField% := NumGet( pGraph + 0, OffSet )
    , RAW    .= SubStr( Offset SP,1,3 ) T SubStr( A_LoopField SP,1,16 ) T %A_LoopField% LF
    
    hTargetBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_GETIMAGE, "Ptr",0, "Ptr",0 )
    VarSetCapacity( BITMAP,32,0 )
    DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
    TBMW := NumGet( BITMAP,  4, "UInt" ),            TBMH := NumGet( BITMAP, 8, "UInt" )
    TBMB := NumGet( BITMAP, 12, "UInt" )* TBMH,     TBMZ := Round( TBMB/1024,2 )
    TBPP := NumGet( BITMAP, 18, "UShort" )
    Adj := ( Adj := TBMW - MarginL - BitBltW - MarginR ) ? " (-" Adj ")" : ""

    DllCall( "GetObject", "Ptr",hSourceBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
    SBMW := NumGet( BITMAP,  4, "UInt" ),            SBMH := NumGet( BITMAP, 8, "UInt" )
    SBMB := NumGet( BITMAP, 12, "UInt" )* SBMH,     SBMZ := Round( SBMB/1024,2 )
    SBPP := NumGet( BITMAP, 18, "UShort" )
    
    Return "GRAPH Properties" LF LF
    . "Screen BG Bitmap   " TT TBMW ( Adj ) "x" TBMH " " TBPP "bpp ( " TBMZ " KB )" LF
    . "Margins ( L,T,R,B )" TT MarginL "," MarginT "," MarginR "," MarginB LF 
    . "Client Area        " TT MarginL "," MarginT "," MarginL+BitBltW-1 "," MarginT+BitBltH-1 LF LF
    . "Memory Bitmap      " TT SBMW         "x" SBMH " " SBPP "bpp ( " SBMZ " KB )" LF 
    . "Graph Width        " TT BitBltW " px ( " Columns " cols x " ColumnW " px )" LF
    . "Graph Height (MY2) " TT BitBltH " px ( y0 to y" BitBltH - 1 " )" LF  
    . "Graph Array        " TT ( DataSz=0 ? "NA" : Columns " cols x 8 bytes = " DataSz " bytes" ) LF LF 
    . "Pen start position " TT MX1 "," BitBltH - 1 LF
    . "LineTo position    " TT MX2 "," "MY2" LF
    . "MoveTo position    " TT MX1 "," "MY2" LF LF
    . "STRUCTURE ( Offset / Variable / Raw value )" LF LF RAW

    XGraph_Info_Data:

    AFF := A_FormatFloat 
    SetFormat, FloatFast, %FormatFloat%
    Loop % DataSz // 8  
        Values .= SubStr( A_Index "   ", 1, 4  ) T NumGet( pData - 8, A_Index* 8, "Double" ) LF
    SetFormat, FloatFast, %AFF%
    StringTrimRight, Values, Values, 1                                                                          

    Return Values      
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_Plot( pGraph, MY2 := "", SetVal := "", Draw := 1 ) {
    Static SRCCOPY := 0x00CC0020

    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1 
    pData     := pGraph + NumGet( pGraph + 0 ),     DataSz     := Numget( pData - 8 )

    , hSourceDC := NumGet( pGraph + 24 ),             BitBltW    := NumGet( pGraph + 112 )     
    , hTargetDC := NumGet( pGraph + 16 ),             BitBltH    := NumGet( pGraph + 120 )
    , ColumnW   := NumGet( pGraph + 48 )           

    , MarginL   := NumGet( pGraph + 64 ),             MX1 := NumGet( pGraph + 096 )
    , MarginT   := NumGet( pGraph + 72 ),             MX2 := NumGet( pGraph + 104 ) 

    If not ( MY2 = "" )                                 
        DllCall( "BitBlt", "Ptr",hSourceDC, "Int",0, "Int",0, "Int",BitBltW + ColumnW, "Int",BitBltH
                        , "Ptr",hSourceDC, "Int",ColumnW, "Int",0, "UInt",SRCCOPY )
    ,  DllCall( "LineTo",   "Ptr",hSourceDC, "Int",MX2, "Int",MY2 )
    ,  DllCall( "MoveToEx", "Ptr",hSourceDC, "Int",MX1, "Int",MY2, "Ptr",0 )
                        
    If ( Draw = 1 ) 
        DllCall( "BitBlt", "Ptr",hTargetDC, "Int",MarginL, "Int",MarginT, "Int",BitBltW, "Int",BitBltH
                        , "Ptr",hSourceDC, "Int",0, "Int",0, "UInt",SRCCOPY )

    If not ( MY2 = "" or SetVal = "" or DataSz = 0 ) 
        DllCall( "RtlMoveMemory", "Ptr",pData, "Ptr",pData + 8, "Ptr",DataSz - 8 )
    ,  NumPut( SetVal, pData + DataSz - 8, 0, "Double" )

    Return 1
    } 

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_SetVal( pGraph, Double := 0, Column := "" ) {

    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1 
    pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData - 8 )
    IfEqual, DataSz, 0, Return 0

    If ( Column = "" )
        DllCall( "RtlMoveMemory", "Ptr",pData, "Ptr",pData + 8, "Ptr",DataSz - 8 )
        , pNumPut := pData + DataSz 
    else Columns := NumGet( pGraph + 56 ) 
        , pNumPut := pData + ( Column < 0 or Column > Columns ? Columns* 8 : Column* 8 )

    Return NumPut( Double, pNumPut - 8, 0, "Double" ) - 8       
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_GetVal( pGraph, Column := "" ) {
    Static RECT
    If not VarSetCapacity( RECT )
            VarSetCapacity( RECT, 16, 0 )

    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1
    pData   := pGraph + NumGet( pGraph + 0 ),   DataSz  := Numget( pData - 8 )
    Columns := NumGet( pGraph + 56 )
    If not ( Column = "" or DataSz = 0 or Column < 1 or Column > Columns )
        Return NumGet( pData - 8, Column* 8, "Double" ),    ErrorLevel := Column

    hCtrl   := NumGet( pGraph + 8   ),          ColumnW := NumGet( pGraph + 48 )                      
    , BitBltW := NumGet( pGraph + 112 ),          MarginL := NumGet( pGraph + 64 )
    , BitBltH := NumGet( pGraph + 120 ),          MarginT := NumGet( pGraph + 72 )

    , Numput( MarginL, RECT, 0, "Int" ),          Numput( MarginT, RECT, 4, "Int" )
    , DllCall( "ClientToScreen", "Ptr",hCtrl, "Ptr",&RECT )
    , DllCall( "GetCursorPos", "Ptr",&RECT + 8 )

    , MX := NumGet( RECT, 8, "Int" ) - NumGet( RECT, 0, "Int" ) 
    , MY := NumGet( RECT,12, "Int" ) - NumGet( RECT, 4, "Int" )

    , Column := ( MX >= 0 and MY >= 0 and MX < BitBltW and MY < BitBltH ) ? MX // ColumnW + 1 : 0
    Return ( DataSz and Column ) ? NumGet( pData - 8, Column* 8, "Double" ) : "",    ErrorLevel := Column  
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_GetMean( pGraph, TailCols := "" ) {

    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1 
    pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData - 8 )
    IfEqual, DataSz, 0, Return 0,     ErrorLevel := 0

    Columns := NumGet( pGraph + 56 )
    pDataEnd := pGraph + NumGet( pGraph + 0 ) + ( Columns* 8 )
    TailCols := ( TailCols = "" or TailCols < 1 or Tailcols > Columns ) ? Columns : TailCols

    Loop %TailCols%
        Value += NumGet( pDataEnd - ( A_Index* 8 ), 0, "Double"  )

    Return Value / TailCols,            ErrorLevel := TailCols
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_Detach( pGraph ) {
    IfEqual, pGraph, 0, Return 0
    
    VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen"
    Loop, Parse, VarL, /, %A_Space%
        %A_LoopField% := NumGet( pGraph + 0, ( A_Index - 1 )* 8 )

    DllCall( "ReleaseDC",    "Ptr",hCtrl, "Ptr",hTargetDC )
    DllCall( "RestoreDC",    "Ptr",hSourceDC, "Int",-1  )
    DllCall( "DeleteDC",     "Ptr",hSourceDC  )
    DllCall( "DeleteObject", "Ptr",hSourceBM  )               
    DllCall( "DeleteObject", "Ptr",hSourcePen )

    Return DllCall( "GlobalFree", "Ptr",pGraph, "Ptr"  )   
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_MakeGrid(  CellW, CellH, Cols, Rows, GLClr, BGClr, ByRef BMPW := "", ByRef BMPH := "" ) {
    Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
        ,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4 
        ,  DC_PEN := 19

    BMPW := CellW* Cols + 1,  BMPH := CellH* Rows + 1
    hTempDC := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
    DllCall( "SaveDC", "Ptr",hTempDC )
    
    If ( DllCall( "GetObjectType", "Ptr",BGClr ) = 0x7 ) 
        hTBM := DllCall( "CopyImage", "Ptr",BGClr, "Int",0, "Int",BMPW, "Int",BMPH, "UInt",LR_Flag2, "UPtr" )
    , DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTBM )

    Else 
        hTBM := DllCall( "CreateBitmap", "Int",2, "Int",2, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )
    , hTBM := DllCall( "CopyImage", "Ptr",hTBM,  "Int",0, "Int",BMPW, "Int",BMPH, "UInt",LR_Flag1, "UPtr" )
    , DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTBM )
    , hBrush := DllCall( "CreateSolidBrush", "UInt",BGClr & 0xFFFFFF, "Ptr" )
    , VarSetCapacity( RECT, 16 )
    , NumPut( BMPW, RECT, 8, "UInt" ),  NumPut( BMPH, RECT, 12, "UInt" )
    , DllCall( "FillRect", "Ptr",hTempDC, "Ptr",&RECT, "Ptr",hBrush )
    , DllCall( "DeleteObject", "Ptr",hBrush )

    hPenDC := DllCall( "GetStockObject", "Int",DC_PEN, "Ptr" ) 
    DllCall( "SelectObject",  "Ptr",hTempDC, "Ptr",hPenDC )
    DllCall( "SetDCPenColor", "Ptr",hTempDC, "UInt",GLClr & 0xFFFFFF )

    Loop, % Rows + 1 + ( X := Y := 0 )  
        DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X,    "Int",Y, "Ptr",0  )
    , DllCall( "LineTo",   "Ptr",hTempDC, "Int",BMPW, "Int",Y ),  Y := Y + CellH
    
    Loop, % Cols + 1 + ( X := Y := 0 )
        DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X, "Int",Y, "Ptr",0 )
    , DllCall( "LineTo",   "Ptr",hTempDC, "Int",X, "Int",BMPH ),  X := X + CellW

    DllCall( "RestoreDC", "Ptr",hTempDC, "Int",-1 )
    DllCall( "DeleteDC",  "Ptr",hTempDC )    

    Return hTBM
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    CreateDIB( PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1  ) {      
        ; http://ahkscript.org/boards/viewtopic.php?t=3203                  SKAN, CD: 01-Apr-2014 MD: 05-May-2014
        Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
            ,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4 
            ,  LR_Flag3 := 0x0008 ; LR_COPYDELETEORG := 8

        WB := Ceil( ( W* 3 ) / 2 )* 2,  VarSetCapacity( BMBITS, WB* H + 1, 0 ),  P := &BMBITS
        Loop, Parse, PixelData, |
            P := Numput( "0x" A_LoopField, P+0, 0, "UInt" ) - ( W & 1 and Mod( A_Index* 3, W* 3 ) = 0 ? 0 : 1 )

        hBM := DllCall( "CreateBitmap", "Int",W, "Int",H, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )    
        hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag1, "Ptr" ) 
        DllCall( "SetBitmapBits", "Ptr",hBM, "UInt",WB* H, "Ptr",&BMBITS )

        If not ( Gradient + 0 )
            hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag3, "Ptr" )  
    Return DllCall( "CopyImage", "Ptr",hBM, "Int",0, "Int",ResizeW, "Int",ResizeH, "Int",LR_Flag2, "UPtr" )
    }    

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/* DeepClone v1 : A library of functions to make unlinked array Clone
    ;
    ; Function:
    ; Array_Print
    ; Description:
    ; Quick and dirty text visualization of an array
    ; Syntax:
    ; Arrary_Print(Array)
    ; Parameters:
    ; Param1 - Array
    ; An array, associative array, or object.
    ; Return Value:
    ; A text visualization of the input array
    ; Remarks:
    ; Supports sub-arrays
    ; Related:
    ; Array_Gui, Array_DeepClone, Array_IsCircle
    ; Example:
    ; MsgBox, % Array_Print({"A":["Aardvark", "Antelope"], "B":"Bananas"})
    ;

    ;
    ; Function:
    ; Array_Gui
    ; Description:
    ; Displays an array as a treeview in a GUI
    ; Syntax:
    ; Array_Gui(Array)
    ; Parameters:
    ; Param1 - Array
    ; An array, associative array, or object.
    ; Return Value:
    ; Null
    ; Remarks:
    ; Resizeable
    ; Related:
    ; Array_Print, Array_DeepClone, Array_IsCircle
    ; Example:
    ; Array_Gui({"GeekDude":["Smart", "Charming", "Interesting"], "tidbit":"Weird"})
    ;

    ;
    ; Function:
    ; Array_DeepClone
    ; Description:
    ; Deep clone
    ; Syntax:
    ; Arrary_DeepClone(Array)
    ; Parameters:
    ; Param1 - Array
    ; An array, associative array, or object.
    ; Return Value:
    ; A copy of the array, that is not linked to the original
    ; Remarks:
    ; Supports sub-arrays, and circular refrences
    ; Related:
    ; Array_Gui, Array_Print, Array_IsCircle
    ; Example:
    ; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
    ; Array2 := Array_DeepClone(Array1)
    ;

    ;
    ; Function:
    ; Array_IsCircle
    ; Description:
    ; Checks for circular refrences that could crash my other functions
    ; Syntax:
    ; Arrary_IsCircle(Array)
    ; Parameters:
    ; Param1 - Array
    ; An array, associative array, or object.
    ; Return Value:
    ; Boolean value according to whether it has a circular refrence
    ; Remarks:
    ; Takes an average of 0.023 seconds
    ; Related:
    ; Array_Gui, Array_Print(), Array_DeepClone()
    ; Example:
    ; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
    ; Array2 := Array_Copy(Array1)
    ;

*/
 
    Array_Print(Array) {
    if Array_IsCircle(Array)
            return "Error: Circular refrence"
        For Key, Value in Array
        {
            If Key is not Number
                Output .= """" . Key . """:"
            Else
                Output .= Key . ":"
            
            If (IsObject(Value))
                Output .= "[" . Array_Print(Value) . "]"
            Else If Value is not number
                Output .= """" . Value . """"
            Else
                Output .= Value
            
            Output .= ", "
        }
        StringTrimRight, OutPut, OutPut, 2
        Return OutPut
    }

    Array_Gui(Array, Parent="") {
        static
        global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
        if Array_IsCircle(Array)
        {
            MsgBox, 16, GuiArray, Error: Circular refrence
            return "Error: Circular refrence"
        }
        if !Parent
        {
            Gui, +HwndDefault
            Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
            Gui, Add, TreeView, vGuiArrayTree
            
            Parent := "P1"
            %Parent% := TV_Add("Array", 0, "+Expand")
            Array_Gui(Array, Parent)
            GuiControlGet, GuiArrayTree, Pos
            Gui, Show,, GuiArray
            Gui, %Default%:Default
            
            WinWaitActive, ahk_id%GuiArray%
            WinWaitClose, ahk_id%GuiArray%
            return
        }
        For Key, Value in Array
        {
            %Parent%C%A_Index% := TV_Add(Key, %Parent%)
            KeyParent := Parent "C" A_Index
            if (IsObject(Value))
                Array_Gui(Value, KeyParent)
            else
                %KeyParent%C1 := TV_Add(Value, %KeyParent%)
        }
        return
        
        GuiArrayClose:
        Gui, Destroy
        return
        
        GuiArraySize:
        if !(A_GuiWidth || A_GuiHeight) ; Minimized
            return
        GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX* 2) " h" A_GuiHeight - (GuiArrayTreeY* 2)
        return
    }
 
    Array_DeepClone(Array, Objs=0)
    {
        if !Objs
            Objs := {}
        Obj := Array.Clone()
        Objs[&Array] := Obj ; Save this new array
        For Key, Val in Obj
            if (IsObject(Val)) ; If it is a subarray
                Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
                ? Objs[&Val] ; Then point it to the new array
                : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
        return Obj
    }

    Array_IsCircle(Obj, Objs=0)
    {
        if !Objs
            Objs := {}
        For Key, Val in Obj
            if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
                return 1
        return 0
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




;{[Function] Decimal2Fraction
    ; Fanatic Guru
    ; 2013 12 21
    ; Version 1.9
    ;
    ; Function to Convert a Decimal Number to a Fraction String
    ;
    ;------------------------------------------------
    ;
    ; Method:
    ;   Decimal2Fraction(Decimal, Options)
    ;
    ;   Parameters:
    ;   1) {Decimal} 				A decimal number to be converted to a fraction string
    ;   2) {Options ~= {Number}}		Round to this fractional Percision ie. 32 would round to the closest 1/32nd
    ;      {Options ~= {D}{Number}}	Round fractional to a {Number} limit of digits ie. D5 limits fraction to 5 digits
    ;      {Options ~= "I"}			Return Improper Fraction
    ;      {Options ~= "AA"}			Return in Architectural format with feet and inches
    ;      {Options ~= "A"}			Return in Architectural format with inches only
    ;   		Optional
    ;
    ;
    ; Example:
    ;	MsgBox % Decimal2Fraction(1.2345)
    ;	MsgBox % Decimal2Fraction(1.2345,"I")
    ;	MsgBox % Decimal2Fraction(1.2345,"A")			; Convert Decminal Inches to Inches Fraction/Inches"
    ;	MsgBox % Decimal2Fraction(1.2345,"AI")			; Convert Decminal Inches to Fraction/Inches"
    ;	MsgBox % Decimal2Fraction(1.2345,"AA16") 		; Convert Decimal Feet to Feet'-Inches Fraction/16th Inches"
    ;	MsgBox % Decimal2Fraction(14.28571428571429,"D5")	; Convert with round to a limit of 5 digit fraction
    ;	MsgBox % Decimal2Fraction(.28571428571429,"AAD5")	; Convert Decimal Feet to Feet'-Inches Fraction/Inches" with round to a limit of 5 digit fraction

    Decimal2Fraction(Decimal, Options := "" )
    {
        FormatFloat := A_FormatFloat
        SetFormat, FloatFast, 0.15
        Whole := 0
        if (Options ~= "i)D")
            Digits := RegExReplace(Options,"\D*(\d*)\D*","$1"), (Digits > 15 ? Digits := 15 : )
        else
            Precision := RegExReplace(Options,"\D*(\d*)\D*","$1")
        if (Options ~= "i)AA")
            Feet := Floor(Decimal), Decimal -= Feet, Inches := Floor(Decimal* 12), Decimal := Decimal* 12 - Inches
        if !(Options ~= "i)I")
            Whole := Floor(Decimal), Decimal -= Whole
        RegExMatch(Decimal,"^(\d*)\.?(\d*?)0*$",Match), N := Match1 Match2
        D := 10** StrLen(Match2)
        if Precision
            N := Round(N / D* Precision), D := Precision
        Repeat_Digits:
        Original_N := N, Original_D := D 
        Repeat_Reduce:
        X := 0, Temp_D := D 
        while X != 1
            X := GCD(N,D), N := N / X, D := D / X
        if Digits
        {
            if (Temp_D = D and D > 1)
            {
                if Direction
                    ((N/ D < Decimal) ? N+= 1 : D += 1)
                else
                    ((N/ D > Decimal) ? N-= 1 : D -= 1)
                goto Repeat_Reduce
            }
            if !Direction
            {
                N_Minus := Floor(N), D_Minus := Floor(D), N := Original_N, D := Original_D, Direction := !Direction
                goto Repeat_Reduce
            }
            N_Plus := Floor(N), D_Plus := Floor(D)
            if (StrLen(D_Plus) <= Digits and StrLen(D_Minus) > Digits)
                N := N_Plus, D := D_Plus
            else if (StrLen(D_Minus) <= Digits and StrLen(D_Plus) > Digits)
                N := N_Minus, D := D_Minus
            else
                if (Abs(Decimal - (N_Plus / D_Plus)) < Abs(Decimal - (N_Minus / D_Minus)))
                    N := N_Plus, D := D_Plus
                else
                    N := N_Minus, D := D_Minus
            if (StrLen(D) > Digits)
            {
                Direction := 0
                goto Repeat_Digits
            }
        }
        if (D = 1 and !(Options ~= "i)Inches"))
        {
            if (Options ~= "i)AA")
            {
                Inches += N
                if (Inches = 12)
                    Feet ++=, Inches := 0
            }
            else
                Whole += N
            N := 0
        }
        N := Floor(N)
        D := Floor(D)
        if (Options ~= "i)AA")
            Output := Feet "'-" Inches (N and D ? " " N "/" D:"")"""" 
        else
            Output := (Whole ? Whole " ":"") (N and D ? N "/" D:"")((Options ~= "i)A") ? """":"")
        SetFormat, FloatFast, %FormatFloat%
        return (Whole + N ? Trim(Output) : 0)
    }

    GCD(A, B) 
    {
        while B 
        B := Mod(A|0x0, A:=B)
        return A
    }
;}




;{[Function] Fraction2Decimal
    ; Fanatic Guru
    ; 2013 12 18
    ; Version 1.6
    ;
    ; Function to Fraction String to a Decimal Number
    ;   Tries to account for any phrasing of feet and inches 
    ;------------------------------------------------
    ;
    ; Method:
    ;   Fraction2Decimal(Fraction, Unit)
    ;
    ;   Parameters:
    ;   1) {Fraction} 		A string representing a fraction to be converted to a decimal number
    ;   2) {Unit} = true    Include feet or inch symbol in return
    ;      {Unit} = false   Do not include feet or inch symbol in return
    ;           Optional - Default to false
    ;
    ; Example:
    ; 	MsgBox % Fraction2Decimal("7/8")
    ; 	MsgBox % Fraction2Decimal("1 7/8")
    ; 	MsgBox % Fraction2Decimal("1-7/8""") ; "" required to escape a literal " for testing
    ; 	MsgBox % Fraction2Decimal("2'1-7/8""") ; "" required to escape a literal " for testing
    ; 	MsgBox % Fraction2Decimal("2'-1 7/8""") ; "" required to escape a literal " for testing
    ; 	MsgBox % Fraction2Decimal("2' 1"" 7/8") ; "" required to escape a literal " for testing
    ;

    Fraction2Decimal(Fraction, Unit := false)
    {
            FormatFloat := A_FormatFloat
        SetFormat, FloatFast, 0.15
            Num := {}
            N := 0
            D := 1
            if RegExMatch(Fraction, "^\s*-")
                Has_Neg := true
            if RegExMatch(Fraction, "i)feet|foot|ft|'")
                Has_Feet := true
            if RegExMatch(Fraction, "i)inch|in|""")
                Has_Inches := true
            if RegExMatch(Fraction, "i)/|of|div")
                Has_Fraction := true
            Output := Trim(Fraction,"""'")
            if Output is number
            {
                SetFormat, FloatFast, %FormatFloat%
                return Output (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
            }
            RegExMatch(Fraction,"^[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)",Match)
            Loop 4
                if !(Match%A_Index% = "")
                    Num.Insert(Match%A_Index%)
            if Has_Fraction
            {
                N := Num[Num.MaxIndex()-1]
                D := Num[Num.MaxIndex()]
            }
            Output := (Num.MaxIndex() = 2 ? N / D : (Num[1]) + N / D)
            if (Has_Feet &  Has_Inches)
                if (Num.MaxIndex() = 2)
                    Output := Num[1] + Num[2] /12
                else
                    Output := Num[1] + ((Num.MaxIndex() = 3 ? 0:Num[2]) + N / D) / 12
            Output := (Has_Neg ? "-":"") (Output ~= "." ? RTrim(RTrim(Output,"0"),".") : Output) (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
            SetFormat, FloatFast, %FormatFloat%
            return Output
    }
;}





/*** Class_CtlColors
 * Lib: Class_CtlColors.ahk
 *     Found on page: https://github.com/AHK-just-me/Class_CtlColors
 * Version:
 *     v1.0.03 [updated 10/31/2017 (MM/DD/YYYY)]
 * Class_CtlColors
 *    Choose your own background and/or text colors for some AHK GUI controls.
 *
 * How to use
 *    To register a control for coloring call CtlColors.Attach() passing up to three parameters:
 *
 *        HWND    - HWND of the GUI control
 *        BkColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
 *        ------- Optional 
 *        TxColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
 *
 *        If both BkColor and TxColor are "" the control will not be added and the call returns False.
 *
 *    To change the colors for a registered control call CtlColors.Change() passing up to three parameters:
 *
 *        HWND    - see above
 *        BkColor - see above
 *        ------- Optional
 *        TxColor - see above
 *
 *        Both BkColor and TxColor may be "" to reset them to default colors. If the control is not registered yet, CtlColors.Attach() is called internally.
 *
 *    To unregister a control from coloring call CtlColors.Detach() passing one parameter:
 *
 *        HWND    - see above
 *
 *    To stop all coloring and free the resources call CtlColors.Free(). It's a good idea to insert this call into the scripts exit-routine.
 *
 *    To check if a control is already registered call CtlColors.IsAttached() passing one parameter:
 *
 *        HWND    - see above
 *
 *    To get a control's HWND use either the option HwndOutputVar with Gui, Add or the command GuiControlGet with sub-command Hwnd.
 */
 ; ======================================================================================================================
 ; AHK 1.1+
 ; ======================================================================================================================
 ; Function:          Auxiliary object to color controls on WM_CTLCOLOR... notifications.
 ;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
 ;                    Checkboxes and Radios accept only background colors due to design.
 ; Namespace:         CtlColors
 ; Tested with:       1.1.25.02
 ; Tested on:         Win 10 (x64)
 ; Change log:        1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
 ;                    1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
 ;                    1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
 ;                    1.0.01.00/2014-02-15/just me  -  changed class initialization.
 ;                    1.0.00.00/2014-02-14/just me  -  initial release.
 ; ======================================================================================================================
 ; This software is provided 'as-is', without any express or implied warranty.
 ; In no event will the authors be held liable for any damages arising from the use of this software.
 ; ======================================================================================================================
   Class CtlColors {
    ; ===================================================================================================================
    ; Class variables
    ; ===================================================================================================================
    ; Registered Controls
    Static Attached := {}
    ; OnMessage Handlers
    Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
    ; Message Handler Function
    Static MessageHandler := "CtlColors_OnMessage"
    ; Windows Messages
    Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
    ; HTML Colors (BGR)
    Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                    , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                    , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
    ; Transparent Brush
    Static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
    ; System Colors
    Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
    ; Error message in case of errors
    Static ErrorMsg := ""
    ; Class initialization
    Static InitClass := CtlColors.ClassInit()
    ; ===================================================================================================================
    ; Constructor / Destructor
    ; ===================================================================================================================
    __New() { ; You must not instantiate this class!
        If (This.InitClass == "!DONE!") { ; external call after class initialization
            This["!Access_Denied!"] := True
            Return False
        }
    }
    ; ----------------------------------------------------------------------------------------------------------------
    __Delete() {
        If This["!Access_Denied!"]
            Return
        This.Free() ; free GDI resources
    }
    ; ===================================================================================================================
    ; ClassInit       Internal creation of a new instance to ensure that __Delete() will be called.
    ; ===================================================================================================================
    ClassInit() {
        CtlColors := New CtlColors
        Return "!DONE!"
    }
    ; ===================================================================================================================
    ; CheckBkColor    Internal check for parameter BkColor.
    ; ===================================================================================================================
    CheckBkColor(ByRef BkColor, Class) {
        This.ErrorMsg := ""
        If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
            This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
            Return False
        }
        BkColor := BkColor = "" ? This.SYSCOLORS[Class]
                :  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
                :  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
        Return True
    }
    ; ===================================================================================================================
    ; CheckTxColor    Internal check for parameter TxColor.
    ; ===================================================================================================================
    CheckTxColor(ByRef TxColor) {
        This.ErrorMsg := ""
        If (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
            This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
            Return False
        }
        TxColor := TxColor = "" ? ""
                :  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
                :  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
        Return True
    }
    ; ===================================================================================================================
    ; Attach          Registers a control for coloring.
    ; Parameters:     HWND        - HWND of the GUI control                                   
    ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
    ;                 ----------- Optional 
    ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
    ; Return values:  On success  - True
    ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
    ; ===================================================================================================================
    Attach(HWND, BkColor, TxColor := "") {
        ; Names of supported classes
        Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
        ; Button styles
        Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
        ; Editstyles
        Static ES_READONLY := 0x800
        ; Default class background colors
        Static COLOR_3DFACE := 15, COLOR_WINDOW := 5
        ; Initialize default background colors on first call -------------------------------------------------------------
        If (This.SYSCOLORS.Edit = "") {
            This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
            This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
            This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
        }
        This.ErrorMsg := ""
        ; Check colors ---------------------------------------------------------------------------------------------------
        If (BkColor = "") && (TxColor = "") {
            This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
            Return False
        }
        ; Check HWND -----------------------------------------------------------------------------------------------------
        If !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "UInt") {
            This.ErrorMsg := "Invalid parameter HWND: " . HWND
            Return False
        }
        If This.Attached.HasKey(HWND) {
            This.ErrorMsg := "Control " . HWND . " is already registered!"
            Return False
        }
        Hwnds := [CtrlHwnd]
        ; Check control's class ------------------------------------------------------------------------------------------
        Classes := ""
        WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
        This.ErrorMsg := "Unsupported control class: " . CtrlClass
        If !ClassNames.HasKey(CtrlClass)
            Return False
        ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
        If (CtrlClass = "Edit")
            Classes := ["Edit", "Static"]
        Else If (CtrlClass = "Button") {
            IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
                Classes := ["Static"]
            Else
                Return False
        }
        Else If (CtrlClass = "ComboBox") {
            VarSetCapacity(CBBI, 40 + (A_PtrSize* 3), 0)
            NumPut(40 + (A_PtrSize* 3), CBBI, 0, "UInt")
            DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
            Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize* 2, "UPtr")) + 0)
            Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
            Classes := ["Edit", "Static", "ListBox"]
        }
        If !IsObject(Classes)
            Classes := [CtrlClass]
        ; Check background color -----------------------------------------------------------------------------------------
        If (BkColor <> "Trans")
            If !This.CheckBkColor(BkColor, Classes[1])
                Return False
        ; Check text color -----------------------------------------------------------------------------------------------
        If !This.CheckTxColor(TxColor)
            Return False
        ; Activate message handling on the first call for a class --------------------------------------------------------
        For I, V In Classes {
            If (This.HandledMessages[V] = 0)
                OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
            This.HandledMessages[V] += 1
        }
        ; Store values for HWND ------------------------------------------------------------------------------------------
        If (BkColor = "Trans")
            Brush := This.NullBrush
        Else
            Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
        For I, V In Hwnds
            This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
        ; Redraw control -------------------------------------------------------------------------------------------------
        DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
        This.ErrorMsg := ""
        Return True
    }
    ; ===================================================================================================================
    ; Change          Change control colors.
    ; Parameters:     HWND        - HWND of the GUI control
    ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
    ;                 ----------- Optional 
    ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
    ; Return values:  On success  - True
    ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
    ; Remarks:        If the control isn't registered yet, Add() is called instead internally.
    ; ===================================================================================================================
    Change(HWND, BkColor, TxColor := "") {
        ; Check HWND -----------------------------------------------------------------------------------------------------
        This.ErrorMsg := ""
        HWND += 0
        If !This.Attached.HasKey(HWND)
            Return This.Attach(HWND, BkColor, TxColor)
        CTL := This.Attached[HWND]
        ; Check BkColor --------------------------------------------------------------------------------------------------
        If (BkColor <> "Trans")
            If !This.CheckBkColor(BkColor, CTL.Classes[1])
                Return False
        ; Check TxColor ------------------------------------------------------------------------------------------------
        If !This.CheckTxColor(TxColor)
            Return False
        ; Store Colors ---------------------------------------------------------------------------------------------------
        If (BkColor <> CTL.BkColor) {
            If (CTL.Brush) {
                If (Ctl.Brush <> This.NullBrush)
                DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
                This.Attached[HWND].Brush := 0
            }
            If (BkColor = "Trans")
                Brush := This.NullBrush
            Else
                Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
            For I, V In CTL.Hwnds {
                This.Attached[V].Brush := Brush
                This.Attached[V].BkColor := BkColor
            }
        }
        For I, V In Ctl.Hwnds
            This.Attached[V].TxColor := TxColor
        This.ErrorMsg := ""
        DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
        Return True
    }
    ; ===================================================================================================================
    ; Detach          Stop control coloring.
    ; Parameters:     HWND        - HWND of the GUI control
    ; Return values:  On success  - True
    ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
    ; ===================================================================================================================
    Detach(HWND) {
        This.ErrorMsg := ""
        HWND += 0
        If This.Attached.HasKey(HWND) {
            CTL := This.Attached[HWND].Clone()
            If (CTL.Brush) && (CTL.Brush <> This.NullBrush)
                DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
            For I, V In CTL.Classes {
                If This.HandledMessages[V] > 0 {
                This.HandledMessages[V] -= 1
                If This.HandledMessages[V] = 0
                    OnMessage(This.WM_CTLCOLOR[V], "")
            }  }
            For I, V In CTL.Hwnds
                This.Attached.Remove(V, "")
            DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
            CTL := ""
            Return True
        }
        This.ErrorMsg := "Control " . HWND . " is not registered!"
        Return False
    }
    ; ===================================================================================================================
    ; Free            Stop coloring for all controls and free resources.
    ; Return values:  Always True.
    ; ===================================================================================================================
    Free() {
        For K, V In This.Attached
            If (V.Brush) && (V.Brush <> This.NullBrush)
                DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
        For K, V In This.HandledMessages
            If (V > 0) {
                OnMessage(This.WM_CTLCOLOR[K], "")
                This.HandledMessages[K] := 0
            }
        This.Attached := {}
        Return True
    }
    ; ===================================================================================================================
    ; IsAttached      Check if the control is registered for coloring.
    ; Parameters:     HWND        - HWND of the GUI control
    ; Return values:  On success  - True
    ;                 On failure  - False
    ; ===================================================================================================================
    IsAttached(HWND) {
        Return This.Attached.HasKey(HWND)
    }
    }
    ; ======================================================================================================================
    ; CtlColors_OnMessage
    ; This function handles CTLCOLOR messages. There's no reason to call it manually!
    ; ======================================================================================================================
   CtlColors_OnMessage(HDC, HWND) {
    Critical
    If CtlColors.IsAttached(HWND) {
        CTL := CtlColors.Attached[HWND]
        If (CTL.TxColor != "")
            DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CTL.TxColor)
        If (CTL.BkColor = "Trans")
            DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "UInt", 1) ; TRANSPARENT = 1
        Else
            DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", CTL.BkColor)
        Return CTL.Brush
    }
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -





/*** GuiStatus - Pixelcheck for different parts of the screen to see what your status is in game. 
* Version:
*     v1.0.1 [updated 12/17/2019 (MM/DD/YYYY)]
*/
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	GuiStatus(Fetch:=""){
        ScreenShot()
		If (Fetch="DetonateMines")
        {
            DelveMine := ScreenShot_GetColor(DetonateDelveX,DetonateY)
            Mine := ScreenShot_GetColor(DetonateX,DetonateY)
            DetonateMines := (Mine=DetonateHex?True:False)
            DetonateDelve := (DelveMine=DetonateHex?True:False)
            Return
        }
		If !(Fetch="")
        {
            P%Fetch% := ScreenShot_GetColor(vX_%Fetch%,vY_%Fetch%)
            temp := %Fetch% := (P%Fetch%=var%Fetch%?True:False)

            Return temp
        }
		POnChar := ScreenShot_GetColor(vX_OnChar,vY_OnChar), OnChar := (POnChar=varOnChar?True:False)
		POnChat := ScreenShot_GetColor(vX_OnChat,vY_OnChat), OnChat := (POnChat=varOnChat?True:False)
		POnMenu := ScreenShot_GetColor(vX_OnMenu,vY_OnMenu), OnMenu := (POnMenu=varOnMenu?True:False)
		POnInventory := ScreenShot_GetColor(vX_OnInventory,vY_OnInventory), OnInventory := (POnInventory=varOnInventory?True:False)
		POnStash := ScreenShot_GetColor(vX_OnStash,vY_OnStash), OnStash := (POnStash=varOnStash?True:False)
        POnVendor := ScreenShot_GetColor(vX_OnVendor,vY_OnVendor), OnVendor := (POnVendor=varOnVendor?True:False)
        POnDiv := ScreenShot_GetColor(vX_OnDiv,vY_OnDiv), OnDiv := (POnDiv=varOnDiv?True:False)
		Return
	}
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Cooltime - Accurate MS readout.
* From AHK discord
* Version:
*     v1.0.0 [updated 11/26/2019 (MM/DD/YYYY)]
*/
    ; CoolTime - Return a more accurate MS value
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CoolTime() {
        VarSetCapacity(PerformanceCount, 8, 0)
        VarSetCapacity(PerformanceFreq, 8, 0)
        DllCall("QueryPerformanceCounter", "Ptr", &PerformanceCount)
        DllCall("QueryPerformanceFrequency", "Ptr", &PerformanceFreq)
        return NumGet(PerformanceCount, 0, "Int64") / NumGet(PerformanceFreq, 0, "Int64")
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** DaysSince - Function to determine the time in days between two dates
*     Basic function found on page: https://autohotkey.com/board/topic/82024-calculate-the-number-of-days-between-two-dates/#entry521362
* Version:
*     v1.0.1 [updated 10/12/2019 (MM/DD/YYYY)]
*/
    ; DaysSince - Check how many days has it been since the last update
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DaysSince()
    {
        Global Date_now, LastDatabaseParseDate, UpdateDatabaseInterval
		FormatTime, Date_now, A_Now, yyyyMMdd
        If Date_now = LastDatabaseParseDate ;
            Return False
        daysCount := Date_now
        daysCount -= LastDatabaseParseDate, days
        If daysCount=
        {
            ;the value is too large of a dif to calculate, this means we should update
            Return True
        }
        Else If (daysCount >= UpdateDatabaseInterval)
        {
            ;The Count between the two dates is at/above the threshold, this means we should update
            Return daysCount
        }
        Else
        {
            ;The Count between the two dates is below the threshold, this means we should not
            Return False
        }
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Function to Replace Nth instance of Needle in Haystack
* Replaces the 'Instance'th instance of 'Needle' in 'Haystack' with 'Replacement'. If 'Instance' is
* negative, it counts instances from the right end of 'Haystack'. If 'Instance' is zero, it
* replaces all instances.
*/
    StringReplaceN( Haystack, Needle, Replacement="", Instance=1 ) 
    { 
        If !( Instance := 0 | Instance )
        {
            StringReplace, Haystack, Haystack, %Needle%, %Replacement%, A
            Return Haystack
        }
        Else Instance := "L" Instance
        StringReplace, Instance, Instance, L-, R
        StringGetPos, Instance, Haystack, %Needle%, %Instance%
        If ( ErrorLevel )
            Return Haystack
        StringTrimLeft, Needle, HayStack, Instance+ StrLen( Needle )
        StringLeft, HayStack, HayStack, Instance
        Return HayStack Replacement Needle
    } 
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** PoE Click v1.0.1 : PoE Click Lib for AutoHotkey.
* Lib: PoEClick.ahk
*     Path of Exile Click functions for AutoHotkey.
*     Developed by Bandit
* Version:
*     v1.0.1 [updated 10/02/2019 (MM/DD/YYYY)]
*/

    ; SwiftClick - Left Click at Coord with no wait between up and down
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SwiftClick(x, y){
            MouseMove, x, y	
            Sleep, 30*Latency
            Send {Click, x, y }
            Sleep, 30*Latency
        return
        }

    ; SwiftClick - Left Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    LeftClick(x, y){
            MouseMove, x, y	
            Sleep, 30*Latency
            Send {Click, Down x, y }
            Sleep, 60*Latency
            Send {Click, Up x, y }
            Sleep, 30*Latency
        return
        }

    ; RightClick - Right Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RightClick(x, y){
            BlockInput, MouseMove
            MouseMove, x, y
            Sleep, 30*Latency
            Send {Click, Down x, y, Right}
            Sleep, 60*Latency
            Send {Click, Up x, y, Right}
            Sleep, 30*Latency
            BlockInput, MouseMoveOff
        return
        }

    ; ShiftClick - Shift Click +Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ShiftClick(x, y){
            BlockInput, MouseMove
            MouseMove, x, y
            Sleep, 30*Latency
            Send {Shift Down}
            Sleep, 30*Latency
            Send {Click, Down, x, y}
            Sleep, 60*Latency
            Send {Click, Up, x, y}
            Sleep, 30*Latency
            Send {Shift Up}
            Sleep, 30*Latency
            BlockInput, MouseMoveOff
        return
        }

    ; CtrlClick - Ctrl Click ^Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CtrlClick(x, y){
            BlockInput, MouseMove
            MouseMove, x, y
            Sleep, 30*Latency
            Send {Ctrl Down}
            Sleep, 45*Latency
            Send {Click, Down, x, y}
            Sleep, 60*Latency
            Send {Click, Up, x, y}
            Sleep, 30*Latency
            Send {Ctrl Up}
            Sleep, 30*Latency
            BlockInput, MouseMoveOff
        return
        }

    ; RandClick - Randomize Click area around middle of cell using Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RandClick(x, y){
            Random, Rx, x+10, x+30
            Random, Ry, y-30, y-10
        return {"X": Rx, "Y": Ry}
        }

    ; WisdomScroll - Identify Item at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	WisdomScroll(x, y){
			BlockInput, MouseMove
			;Sleep, 15*Latency
			MouseMove %WisdomScrollX%, %WisdomScrollY%
			Sleep, 30*Latency
			Click, Down, Right, 1
			Sleep, 60*Latency
			Click, Up, Right, 1
			Sleep, 30*Latency
			MouseMove %x%, %y%
			Sleep, 30*Latency
			Click, Down, Left, 1
			Sleep, 60*Latency
			Click, Up, Left, 1
			Sleep, 30*Latency
			BlockInput, MouseMoveOff
		return
		}


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Array functions v1.0.0 : Index matching.
* Lib: ArrayCheck.ahk
*     Returns the index of a value within an array.
*     Also can color match within variance from an array
*     Developed by SauronDev and Bandit
* Version:
*     v1.0.0 [updated 09/24/2019 (MM/DD/YYYY)]
*/

    ; Check if a specific hex value is part of an array within a variance and return the index
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    indexOfHex(var, Arr, fromIndex:=1, vary:=2) {
            for index, value in Arr {
                h1 := ToRGB(value) 
                h2 := ToRGB(var) 
                if (index < fromIndex){
                    Continue
                }else if (CompareRGB(h1, h2, vary)){
                    return index
                }
            }
        }

    ; Check if a specific value is part of an array and return the index
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    indexOf(var, Arr, fromIndex:=1) {
            for index, value in Arr {
                if (index < fromIndex){
                    Continue
                }else if (value = var){
                    return index
                }
            }
        }

    ; Check if a specific value is part of an array's array and return the parent index
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    indexOfArr(var, Arr, fromIndex:=1) 
    {
        for index, a in Arr 
        {
            if (index < fromIndex)
                Continue
            for k, value in a
                if (value = var)
                    return index
        }
        Return False
    }

    ; Transform an array to a comma separated string
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    arrToStr(array){
            Str := ""
            For Index, Value In array
                Str .= "," . Value
            Str := LTrim(Str, ",")
            return Str
        }
    ; Transform an array to a comma separated string
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    hexArrToStr(array){
            Str := ""
            For Index, Value In array
                {
                value := Format("0x{1:06X}", value)
                Str .= "," . Value
                }
            Str := LTrim(Str, ",")
            return Str
        }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Lib from LutBot : Extracted from lite version
* Lib: LutBotLite.ahk
*     Path of Exile Quick disconnect.
* Version:
*     v?
*/

    ; Main function of the LutBot logout method
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    logout(executable){
            global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi
            Thread, NoTimers, true		;Critical
            start := A_TickCount
            
            poePID := Object()
            s := 4096
            Process, Exist 
            h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
            
            DllCall(OpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", t)
            VarSetCapacity(ti, 16, 0)
            NumPut(1, ti, 0, "UInt")
            
            DllCall(LookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
            NumPut(luid, ti, 4, "Int64")
            NumPut(2, ti, 12, "UInt")
            
            r := DllCall(AdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
            DllCall("CloseHandle", "Ptr", t)
            DllCall("CloseHandle", "Ptr", h)
            
            try
            {
                s := VarSetCapacity(a, s)
                c := 0
                DllCall(EnumProcesses, "Ptr", &a, "UInt", s, "UIntP", r)
                Loop, % r // 4
                {
                    id := NumGet(a, A_Index* 4, "UInt")
                    
                    h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
                    
                    if !h
                        continue
                    VarSetCapacity(n, s, 0)
                    e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
                    if !e 
                        if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
                        SplitPath n, n
                    DllCall("CloseHandle", "Ptr", h)
                    if (n && e)
                    if (n == executable) {
                        poePID.Insert(id)
                    }
                }
                
                l := poePID.Length()
                if ( l = 0 ) {
                    Process, wait, %executable%, 0.2
                    if ( ErrorLevel > 0 ) {
                        poePID.Insert(ErrorLevel)
                    }
                }
                
                VarSetCapacity(dwSize, 4, 0) 
                result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
                VarSetCapacity(TcpTable, NumGet(dwSize), 0) 
                
                result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
                
                num := NumGet(&TcpTable,0,"UInt")
                
                IfEqual, num, 0
                {
                    Log("ED11",num,l,executable)
                    return False
                }
                
                out := 0
                Loop %num%
                {
                    cutby := a_index - 1
                    cutby*= 24
                    ownerPID := NumGet(&TcpTable,cutby+24,"UInt")
                    for index, element in poePID {
                        if ( ownerPID = element )
                        {
                            VarSetCapacity(newEntry, 20, 0) 
                            NumPut(12,&newEntry,0,"UInt")
                            NumPut(NumGet(&TcpTable,cutby+8,"UInt"),&newEntry,4,"UInt")
                            NumPut(NumGet(&TcpTable,cutby+12,"UInt"),&newEntry,8,"UInt")
                            NumPut(NumGet(&TcpTable,cutby+16,"UInt"),&newEntry,12,"UInt")
                            NumPut(NumGet(&TcpTable,cutby+20,"UInt"),&newEntry,16,"UInt")
                            result := DllCall(SetEntry, UInt, &newEntry)
                            IfNotEqual, result, 0
                            {
                                Log("TCP" . result,out,result,l,executable)
                                return False
                            }
                            out++
                        }
                    }
                }
                if ( out = 0 ) {
                    Log("ED10",out,l,executable)
                    return False
                } else {
                    Log(l . ":" . A_TickCount - start,out,l,executable)
                }
            } 
            catch e
            {
                Log("ED14","catcherror",e)
                return False
            }
            
        return True
        }

    ; Log file function
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Log(var*) 
    {
        print := A_Now
        For k, v in var
            print .= "," . v
        print .= ", Script: " . A_ScriptFullPath . " , Script Version: " . VersionNumber . " , AHK version: " . A_AhkVersion . "`n"
        FileAppend, %print%, Log.txt, UTF-16
        return
    }

    ; checkActiveType - Check for backup executable
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	checkActiveType() {
			global executable, backupExe
			Process, Exist, %executable%
			if !ErrorLevel
			{
				WinGet, id, list,ahk_group POEGameGroup,, Program Manager
				Loop, %id%
				{
					this_id := id%A_Index%
					WinGet, this_name, ProcessName, ahk_id %this_id%
					backupExe := this_name
					found .= ", " . this_name
				}
			}
		return
		}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** RandomSleep Timers: 
*/

    ; Provides a call for simpler random sleep timers
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    RandomSleep(min,max){
            Random, r, min, max
            r:=floor(r/Speed)
            Sleep, r*Latency
        return
        }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Ding Debug tooltip message : WingMan
* Lib: Ding.ahk
*     Display tooltip which can be disabled later at once
*     Additional messages are given new lines
* Version:
*     v1.0.1
*/

    ; Debug messages within script
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Ding(Timeout:=500, MultiTooltip:=0 , Message*)
    {
        If (!DebugMessages)
            Return
        Else
        {
            debugStr := ""
            If Message.Count()
            {
                For mkey, mval in Message
                {
                    If mval=
                        Continue
                    If A_Index = 1
                    {
                        If MultiTooltip
                            ToolTip, %mval%, 100, % 50 + MultiTooltip* 23, %MultiTooltip% 
                        Else
                            debugStr .= Message.A_Index
                    }
                    Else if A_Index <= 20
                    {
                        If MultiTooltip
                            ToolTip, %mval%, 100, % 50 + A_Index* 23, %A_Index% 
                        Else
                            debugStr .= "`n" . Message.A_Index
                    }
                }
                If !MultiTooltip
                    Tooltip, %debugStr%
            }
            Else
            {
                If MultiTooltip
                    ToolTip, Ding, 100, % 50 + MultiTooltip* 23, %MultiTooltip% 
                Else
                    Tooltip, Ding
            }
        }
        If Timeout
        {
            If MultiTooltip
                SetTimer, RemoveTT%MultiTooltip%, %Timeout%
            Else
                SetTimer, RemoveToolTip, %Timeout%
        }
        Return
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Clamp value 
* Lib: Clamp.ahk
*     Clamp function
*/

    ; Clamp Value function
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Clamp( Val, Min, Max) {
        If Val < Min
            Val := Min
        If Val > Max
            Val := Max
        Return
        }
    ; Clamp Value function
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ClampGameScreen(ByRef ValX, ByRef ValY) 
    {
        Global GameWindow
        If (ValY < GameWindow.BBarY)
            ValY := GameWindow.BBarY
        If (ValX < GameWindow.X)
            ValX := GameWindow.X
        If (ValY > GameWindow.Y + GameWindow.H)
            ValT := GameWindow.Y + GameWindow.H
        If (ValX > GameWindow.X + GameWindow.W)
            ValX := GameWindow.X + GameWindow.W
        Return
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** hex color tools: extract R G B elements from BGR or RGB hex, convert RGB <> BGR, or compare extracted RGB values against another color. 
* Lib: ColorTools.ahk
*     ColorCompare function
*     ToRGBfromBGR function
*     ToRGB function
*     hexBGRToRGB function
*     CompareRGB function
*/

    ; Compare two hex colors as their R G B elements, puts all the below together
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CompareHex(color1, color2, vary:=1, BGR:=0)
    {
        If BGR
        {
            c1 := ToRGBfromBGR(color1)
            c2 := ToRGBfromBGR(color2)
        }
        Else
        {
            c1 := ToRGB(color1)
            c2 := ToRGB(color2)
        }
        Return CompareRGB(c1,c2,vary)
    }
    ; Convert a color to a two/five pixel square findtext string
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Hex2FindText(Color,vary:=0,BGR:=0,Arr:=0,Five:=0)
    {
        If Arr
        {
            build := ""
            For k, v in Color
            {
                If BGR
                    v := hexBGRToRGB(v)
                build .= "|<FIVE>" . v . "@" . Round((100-vary)/100,2) . (Five ? "$5.zzzzk" : "$2.y")
            }
            Return build
        }
        Else
        {
            Return "|<TWO>" . Color . "@" . Round((100-vary)/100,2) . (Five ? "$5.zzzzk" : "$2.y")
        }
    }

    ; Converts a hex BGR color into its R G B elements
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ToRGBfromBGR(color) {
        return { "b": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "r": color & 0xFF }
        }

    ; Converts a hex RGB color into its R G B elements
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ToRGB(color) {
        return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
        }

    ; Converts a hex BGR color into RGB format or vice versa
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    hexBGRToRGB(color) {
            b := Format("{1:02X}",(color >> 16) & 0xFF)
            g := Format("{1:02X}",(color >> 8) & 0xFF)
            r := Format("{1:02X}",color & 0xFF)
        return "0x" . r . g . b
        }

    ; Compares two converted HEX codes as R G B within the variance range (use ToRGB to convert first)
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CompareRGB(c1, c2, vary:=1) {
        rdiff := Abs( c1.r - c2.r )
        gdiff := Abs( c1.g - c2.g )
        bdiff := Abs( c1.b - c2.b )

        return rdiff <= vary && gdiff <= vary && bdiff <= vary
        }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Rescale : Resolution scaling for pixel locations taken at a sample resolution.
  */
    ; Rescale - Rescales values of the script to the user's resolution
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Rescale(){
            Global GameX, GameY, GameW, GameH
			IfWinExist, ahk_group POEGameGroup 
			{
				WinGetPos, GameX, GameY, GameW, GameH
				If (ResolutionScale="Standard") {
					; Item Inventory Grid
					Global InventoryGridX := [ GameX + Round(GameW/(1920/1274)), GameX + Round(GameW/(1920/1326)), GameX + Round(GameW/(1920/1379)), GameX + Round(GameW/(1920/1432)), GameX + Round(GameW/(1920/1484)), GameX + Round(GameW/(1920/1537)), GameX + Round(GameW/(1920/1590)), GameX + Round(GameW/(1920/1642)), GameX + Round(GameW/(1920/1695)), GameX + Round(GameW/(1920/1748)), GameX + Round(GameW/(1920/1800)), GameX + Round(GameW/(1920/1853)) ]
					Global InventoryGridY := [ GameY + Round(GameH/(1080/638)), GameY + Round(GameH/(1080/690)), GameY + Round(GameH/(1080/743)), GameY + Round(GameH/(1080/796)), GameY + Round(GameH/(1080/848)) ]  
					;Detonate Mines
					Global DetonateDelveX:=GameX + Round(GameW/(1920/1542))
					Global DetonateX:=GameX + Round(GameW/(1920/1658))
					Global DetonateY:=GameY + Round(GameH/(1080/901))
					;Scrolls in currency tab
					Global WisdomStockX:=GameX + Round(GameW/(1920/125))
					Global PortalStockX:=GameX + Round(GameW/(1920/175))
					Global WPStockY:=GameY + Round(GameH/(1080/262))
					;Status Check OnMenu
					global vX_OnMenu:=GameX + Round(GameW / 2)
					global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
					;Status Check OnChar
					global vX_OnChar:=GameX + Round(GameW / (1920 / 41))
					global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
					;Status Check OnChat
					global vX_OnChat:=GameX + Round(GameW / (1920 / 0))
					global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
					;Status Check OnInventory
					global vX_OnInventory:=GameX + Round(GameW / (1920 / 1583))
					global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
					;Status Check OnStash
					global vX_OnStash:=GameX + Round(GameW / (1920 / 336))
					global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
					;Status Check OnVendor
					global vX_OnVendor:=GameX + Round(GameW / (1920 / 618))
					global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
					;Status Check OnDiv
					global vX_OnDiv:=GameX + Round(GameW / (1920 / 618))
					global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
					;Life %'s
					global vX_Life:=GameX + Round(GameW / (1920 / 95))
					global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
					;ES %'s
                    If YesEldritchBattery
					    global vX_ES:=GameX + Round(GameW / (1920 / 1740))
					Else
                        global vX_ES:=GameX + Round(GameW / (1920 / 180))
					global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
					;Mana
					global vX_Mana:=GameX + Round(GameW / (1920 / 1825))
					global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
					global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
                    Global vH_ManaBar:= vY_Mana10 - vY_Mana90
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
					;GUI overlay
					global GuiX:=GameX + Round(GameW / (1920 / -10))
					global GuiY:=GameY + Round(GameH / (1080 / 1027))
					;Divination Y locations
					Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
					Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
					;Stash tabs menu button
					global vX_StashTabMenu := GameX + Round(GameW / (1920 / 640))
					global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
					;Stash tabs menu list
					global vX_StashTabList := GameX + Round(GameW / (1920 / 706))
					global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
					;calculate the height of each tab
					global vY_StashTabSize := Round(GameH / ( 1080 / 22))
				}
				Else If (ResolutionScale="Classic") {
					; Item Inventory Grid
					Global InventoryGridX := [ Round(GameW/(1440/794)) , Round(GameW/(1440/846)) , Round(GameW/(1440/899)) , Round(GameW/(1440/952)) , Round(GameW/(1440/1004)) , Round(GameW/(1440/1057)) , Round(GameW/(1440/1110)) , Round(GameW/(1440/1162)) , Round(GameW/(1440/1215)) , Round(GameW/(1440/1268)) , Round(GameW/(1440/1320)) , Round(GameW/(1440/1373)) ]
					Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]  
					;Detonate Mines
					Global DetonateDelveX:=GameX + Round(GameW/(1440/1062))
					Global DetonateX:=GameX + Round(GameW/(1440/1178))
					Global DetonateY:=GameY + Round(GameH/(1080/901))
					;Scrolls in currency tab
					Global WisdomStockX:=GameX + Round(GameW/(1440/125))
					Global PortalStockX:=GameX + Round(GameW/(1440/175))
					Global WPStockY:=GameY + Round(GameH/(1080/262))
					;Status Check OnMenu
					global vX_OnMenu:=GameX + Round(GameW / 2)
					global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
					;Status Check OnChar
					global vX_OnChar:=GameX + Round(GameW / (1440 / 41))
					global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
					;Status Check OnChat
					global vX_OnChat:=GameX + Round(GameW / (1440 / 0))
					global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
					;Status Check OnInventory
					global vX_OnInventory:=GameX + Round(GameW / (1440 / 1103))
					global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
					;Status Check OnStash
					global vX_OnStash:=GameX + Round(GameW / (1440 / 336))
					global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
					;Status Check OnVendor
					global vX_OnVendor:=GameX + Round(GameW / (1440 / 378))
					global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
					;Status Check OnDiv
					global vX_OnDiv:=GameX + Round(GameW / (1440 / 378))
					global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
					;Life %'s
					global vX_Life:=GameX + Round(GameW / (1440 / 95))
					global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
					;ES %'s
                    If YesEldritchBattery
					    global vX_ES:=GameX + Round(GameW / (1440 / 1260))
					Else
                        global vX_ES:=GameX + Round(GameW / (1440 / 180))
					global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
					;Mana
					global vX_Mana:=GameX + Round(GameW / (1440 / 1345))
					global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
					global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
                    Global vH_ManaBar:= vY_Mana10 - vY_Mana90
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
					;GUI overlay
					global GuiX:=GameX + Round(GameW / (1440 / -10))
					global GuiY:=GameY + Round(GameH / (1080 / 1027))
					;Divination Y locations
					Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
					Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
					;Stash tabs menu button
					global vX_StashTabMenu := GameX + Round(GameW / (1440 / 640))
					global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
					;Stash tabs menu list
					global vX_StashTabList := GameX + Round(GameW / (1440 / 706))
					global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
					;calculate the height of each tab
					global vY_StashTabSize := Round(GameH / ( 1080 / 22))
				}
				Else If (ResolutionScale="Cinematic") {
                    ; Item Inventory Grid
                    Global InventoryGridX := [ Round(GameW/(2560/1914)), Round(GameW/(2560/1967)), Round(GameW/(2560/2018)), Round(GameW/(2560/2072)), Round(GameW/(2560/2125)), Round(GameW/(2560/2178)), Round(GameW/(2560/2230)), Round(GameW/(2560/2281)), Round(GameW/(2560/2336)), Round(GameW/(2560/2388)), Round(GameW/(2560/2440)), Round(GameW/(2560/2493)) ]
                    Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]
                    ;Detonate Mines
                    Global DetonateDelveX:=GameX + Round(GameW/(2560/2185))
                    Global DetonateX:=GameX + Round(GameW/(2560/2298))
                    Global DetonateY:=GameY + Round(GameH/(1080/901))
                    ;Scrolls in currency tab
                    Global WisdomStockX:=GameX + Round(GameW/(2560/125))
                    Global PortalStockX:=GameX + Round(GameW/(2560/175))
                    Global WPStockY:=GameY + Round(GameH/(1080/262))
                    ;Status Check OnMenu
                    global vX_OnMenu:=GameX + Round(GameW / 2)
                    global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
                    ;Status Check OnChar
                    global vX_OnChar:=GameX + Round(GameW / (2560 / 41))
                    global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
                    ;Status Check OnChat
                    global vX_OnChat:=GameX + Round(GameW / (2560 / 0))
                    global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
                    ;Status Check OnInventory
                    global vX_OnInventory:=GameX + Round(GameW / (2560 / 2223))
                    global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
                    ;Status Check OnStash
                    global vX_OnStash:=GameX + Round(GameW / (2560 / 336))
                    global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
                    ;Status Check OnVendor
                    global vX_OnVendor:=GameX + Round(GameW / (2560 / 618))
                    global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
                    ;Status Check OnDiv
                    global vX_OnDiv:=GameX + Round(GameW / (2560 / 618))
                    global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
                    ;Life %'s
                    global vX_Life:=GameX + Round(GameW / (2560 / 95))
                    global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
                    global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
                    global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
                    global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
                    global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
                    global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
                    global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
                    global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
                    ;ES %'s
                    If YesEldritchBattery
					    global vX_ES:=GameX + Round(GameW / (2560 / 2380))
                    Else
                        global vX_ES:=GameX + Round(GameW / (2560 / 180))
                    global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
                    global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
                    global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
                    global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
                    global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
                    global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
                    global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
                    global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
                    ;Mana
                    global vX_Mana:=GameX + Round(GameW / (2560 / 2465))
                    global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
                    global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
                    Global vH_ManaBar:= vY_Mana10 - vY_Mana90
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
                    ;GUI overlay
                    global GuiX:=GameX + Round(GameW / (2560 / -10))
                    global GuiY:=GameY + Round(GameH / (1080 / 1027))
                    ;Divination Y locations
                    Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
                    Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
                    ;Stash tabs menu button
                    global vX_StashTabMenu := GameX + Round(GameW / (2560 / 640))
                    global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
                    ;Stash tabs menu list
                    global vX_StashTabList := GameX + Round(GameW / (2560 / 706))
                    global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
                    ;calculate the height of each tab
                    global vY_StashTabSize := Round(GameH / ( 1080 / 22))
				} 
				Else If (ResolutionScale="UltraWide") {
					; Item Inventory Grid
					Global InventoryGridX := [ Round(GameW/(3840/3193)), Round(GameW/(3840/3246)), Round(GameW/(3840/3299)), Round(GameW/(3840/3352)), Round(GameW/(3840/3404)), Round(GameW/(3840/3457)), Round(GameW/(3840/3510)), Round(GameW/(3840/3562)), Round(GameW/(3840/3615)), Round(GameW/(3840/3668)), Round(GameW/(3840/3720)), Round(GameW/(3840/3773)) ]
					Global InventoryGridY := [ Round(GameH/(1080/638)), Round(GameH/(1080/690)), Round(GameH/(1080/743)), Round(GameH/(1080/796)), Round(GameH/(1080/848)) ]  
					;Detonate Mines
					Global DetonateDelveX:=GameX + Round(GameW/(3840/3462))
					Global DetonateX:=GameX + Round(GameW/(3840/3578))
					Global DetonateY:=GameY + Round(GameH/(1080/901))
					;Scrolls in currency tab
					Global WisdomStockX:=GameX + Round(GameW/(3840/125))
					Global PortalStockX:=GameX + Round(GameW/(3840/175))
					Global WPStockY:=GameY + Round(GameH/(1080/262))
					;Status Check OnMenu
					global vX_OnMenu:=GameX + Round(GameW / 2)
					global vY_OnMenu:=GameY + Round(GameH / (1080 / 54))
					;Status Check OnChar
					global vX_OnChar:=GameX + Round(GameW / (3840 / 41))
					global vY_OnChar:=GameY + Round(GameH / ( 1080 / 915))
					;Status Check OnChat
					global vX_OnChat:=GameX + Round(GameW / (3840 / 0))
					global vY_OnChat:=GameY + Round(GameH / ( 1080 / 653))
					;Status Check OnInventory
					global vX_OnInventory:=GameX + Round(GameW / (3840 / 3503))
					global vY_OnInventory:=GameY + Round(GameH / ( 1080 / 36))
					;Status Check OnStash
					global vX_OnStash:=GameX + Round(GameW / (3840 / 336))
					global vY_OnStash:=GameY + Round(GameH / ( 1080 / 32))
					;Status Check OnVendor
					global vX_OnVendor:=GameX + Round(GameW / (3840 / 1578))
					global vY_OnVendor:=GameY + Round(GameH / ( 1080 / 88))
					;Status Check OnDiv
					global vX_OnDiv:=GameX + Round(GameW / (3840 / 1578))
					global vY_OnDiv:=GameY + Round(GameH / ( 1080 / 135))
					;Life %'s
					global vX_Life:=GameX + Round(GameW / (3840 / 95))
					global vY_Life20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_Life30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_Life40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_Life50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_Life60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_Life70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_Life80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_Life90:=GameY + Round(GameH / ( 1080 / 894))
					;ES %'s
                    If YesEldritchBattery
					    global vX_ES:=GameX + Round(GameW / (3840 / 3660))
                    Else
					    global vX_ES:=GameX + Round(GameW / (3840 / 180))
					global vY_ES20:=GameY + Round(GameH / ( 1080 / 1034))
					global vY_ES30:=GameY + Round(GameH / ( 1080 / 1014))
					global vY_ES40:=GameY + Round(GameH / ( 1080 / 994))
					global vY_ES50:=GameY + Round(GameH / ( 1080 / 974))
					global vY_ES60:=GameY + Round(GameH / ( 1080 / 954))
					global vY_ES70:=GameY + Round(GameH / ( 1080 / 934))
					global vY_ES80:=GameY + Round(GameH / ( 1080 / 914))
					global vY_ES90:=GameY + Round(GameH / ( 1080 / 894))
					;Mana
					global vX_Mana:=GameX + Round(GameW / (3840 / 3745))
					global vY_Mana10:=GameY + Round(GameH / (1080 / 1054))
					global vY_Mana90:=GameY + Round(GameH / (1080 / 876))
                    Global vH_ManaBar:= vY_Mana10 - vY_Mana90
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar* (ManaThreshold / 100))
					;GUI overlay
					global GuiX:=GameX + Round(GameW / (3840 / -10))
					global GuiY:=GameY + Round(GameH / (1080 / 1027))
					;Divination Y locations
					Global vY_DivTrade:=GameY + Round(GameH / (1080 / 736))
					Global vY_DivItem:=GameY + Round(GameH / (1080 / 605))
					;Stash tabs menu button
					global vX_StashTabMenu := GameX + Round(GameW / (3840 / 640))
					global vY_StashTabMenu := GameY + Round(GameH / ( 1080 / 146))
					;Stash tabs menu list
					global vX_StashTabList := GameX + Round(GameW / (3840 / 706))
					global vY_StashTabList := GameY + Round(GameH / ( 1080 / 120))
					;calculate the height of each tab
					global vY_StashTabSize := Round(GameH / ( 1080 / 22))
				} 
                x_center := GameX + GameW / 2
                compensation := (GameW / GameH) == (16 / 10) ? 1.103829 : 1.103719
                y_center := GameY + GameH / 2 / compensation
                offset_mod := y_offset / GameH
                x_offset := GameW * (offset_mod / 1.5 )
                Global ScrCenter := { "X" : GameX + Round(GameW / 2) , "Y" : GameY + Round(GameH / 2) }
				RescaleRan := True
                Global GameWindow := {"X" : GameX, "Y" : GameY, "W" : GameW, "H" : GameH, "BBarY" : (GameY + (GameH / (1080 / 75))) }
			}
		return
		}


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** tooltip management
*/
  
    RemoveToolTip()
    {
        SetTimer, , Off
        Loop, 20
        {
            SetTimer, RemoveTT%A_Index%, Off
            ToolTip,,,,%A_Index%
        }
        PauseTooltips := 0
        return

        RemoveTT1:
            SetTimer, , Off
            ToolTip,,,,1
        Return

        RemoveTT2:
            SetTimer, , Off
            ToolTip,,,,2
        Return

        RemoveTT3:
            SetTimer, , Off
            ToolTip,,,,3
        Return

        RemoveTT4:
            SetTimer, , Off
            ToolTip,,,,4
        Return

        RemoveTT5:
            SetTimer, , Off
            ToolTip,,,,5
        Return

        RemoveTT6:
            SetTimer, , Off
            ToolTip,,,,6
        Return

        RemoveTT7:
            SetTimer, , Off
            ToolTip,,,,7
        Return

        RemoveTT8:
            SetTimer, , Off
            ToolTip,,,,8
        Return

        RemoveTT9:
            SetTimer, , Off
            ToolTip,,,,9
        Return

        RemoveTT10:
            SetTimer, , Off
            ToolTip,,,,10
        Return

        RemoveTT11:
            SetTimer, , Off
            ToolTip,,,,11
        Return

        RemoveTT12:
            SetTimer, , Off
            ToolTip,,,,12
        Return

        RemoveTT13:
            SetTimer, , Off
            ToolTip,,,,13
        Return

        RemoveTT14:
            SetTimer, , Off
            ToolTip,,,,14
        Return

        RemoveTT15:
            SetTimer, , Off
            ToolTip,,,,15
        Return

        RemoveTT16:
            SetTimer, , Off
            ToolTip,,,,16
        Return

        RemoveTT17:
            SetTimer, , Off
            ToolTip,,,,17
        Return

        RemoveTT18:
            SetTimer, , Off
            ToolTip,,,,18
        Return

        RemoveTT19:
            SetTimer, , Off
            ToolTip,,,,19
        Return

        RemoveTT20:
            SetTimer, , Off
            ToolTip,,,,20
        Return
    }

    ShowToolTip()
    {
        global ft_ToolTip_Text
        If PauseTooltips
            Return
        ListLines, Off
        static CurrControl, PrevControl, _TT
        CurrControl := A_GuiControl
        if (CurrControl != PrevControl)
        {
        PrevControl := CurrControl
        ToolTip
        if (CurrControl != "")
            SetTimer, ft_DisplayToolTip, -500
        }
        return

        ft_DisplayToolTip:
        If PauseTooltips
            Return
        ListLines, Off
        MouseGetPos,,, _TT
        WinGetClass, _TT, ahk_id %_TT%
        if (_TT = "AutoHotkeyGUI")
        {
        ToolTip, % RegExMatch(ft_ToolTip_Text, "m`n)^"
            . StrReplace(CurrControl,"ft_") . "\K\s*=.*", _TT)
            ? StrReplace(Trim(_TT,"`t ="),"\n","`n") : ""
        SetTimer, ft_RemoveToolTip, -5000
        }
        return

        ft_RemoveToolTip:
        ToolTip
        return
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Chat functions : ResetChat and GrabRecipientName
*/
    ; Reset Chat
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ResetChat(){
		Send {Enter}{Up}{Escape}
	    return
	    }
    ; Grab Reply whisper recipient
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	GrabRecipientName(){
		Clipboard := ""
		Send ^{Enter}^{A}^{C}{Escape}
		ClipWait, 0
		Loop, Parse, Clipboard, `n, `r
			{
			; Clipboard must have "@" in the first line
			If A_Index = 1
				{
				IfNotInString, A_LoopField, @
					{
					Exit
					}
				RecipientNameArr := StrSplit(A_LoopField, " ", @)
				RecipientName1 := RecipientNameArr[1]
				RecipientName := StrReplace(RecipientName1, "@")
				}
				Ding(, 1,%RecipientName%)
			}
		Sleep, 60
		Return
		}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** API scraper for PoE.Ninja : Pulls all the information into one database file
*/
    ; ScrapeNinjaData - Parse raw data from PoE-Ninja API and standardize Chaos Value || Chaose Equivalent
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ScrapeNinjaData(apiString)
	{
		If InStr(apiString, "Fragment")
		{
			UrlDownloadToFile, https://poe.ninja/api/Data/Get%apiString%Overview?league=%selectedLeague%, %A_ScriptDir%\data\data_%apiString%.txt
			If ErrorLevel{
				MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid
			}
			Else If (ErrorLevel=0){
				FileRead, JSONtext, %A_ScriptDir%\data\data_%apiString%.txt
				holder := JSON.Load(JSONtext)
				For obj, objlist in holder
				{
					If (obj != "currencyDetails") 
					{
						for index, indexArr in objlist
						{ ; This will extract the information and standardize the chaos value to one variable.
							grabName := (holder[obj][index]["currencyTypeName"] ? holder[obj][index]["currencyTypeName"] : False)
							grabChaosVal := (holder[obj][index]["chaosEquivalent"] ? holder[obj][index]["chaosEquivalent"] : False)
							grabPayVal := (holder[obj][index]["pay"] ? holder[obj][index]["pay"] : False)
							grabRecVal := (holder[obj][index]["receive"] ? holder[obj][index]["receive"] : False)
							grabPaySparklineVal := (holder[obj][index]["paySparkLine"] ? holder[obj][index]["paySparkLine"] : False)
							grabRecSparklineVal := (holder[obj][index]["receiveSparkLine"] ? holder[obj][index]["receiveSparkLine"] : False)
							grabPayLowSparklineVal := (holder[obj][index]["lowConfidencePaySparkLine"] ? holder[obj][index]["lowConfidencePaySparkLine"] : False)
							grabRecLowSparklineVal := (holder[obj][index]["lowConfidenceReceiveSparkLine"] ? holder[obj][index]["lowConfidenceReceiveSparkLine"] : False)
							holder[obj][index] := {"name":grabName
								,"chaosValue":grabChaosVal
								,"pay":grabPayVal
								,"receive":grabRecVal
								,"paySparkLine":grabPaySparklineVal
								,"receiveSparkLine":grabRecSparklineVal
								,"lowConfidencePaySparkLine":grabPayLowSparklineVal
								,"lowConfidenceReceiveSparkLine":grabRecLowSparklineVal}
							Ninja[apiString] := holder[obj]
						}
					}
				}
				FileDelete, %A_ScriptDir%\data\data_%apiString%.txt
			}
			Return
		}
		Else If InStr(apiString, "Currency")
		{
			UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\data\data_%apiString%.txt
			if ErrorLevel{
				MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid
			}
			Else if (ErrorLevel=0){
				FileRead, JSONtext, %A_ScriptDir%\data\data_%apiString%.txt
				holder := JSON.Load(JSONtext)
				For obj, objlist in holder
				{
					If (obj != "currencyDetails") 
					{
						for index, indexArr in objlist
						{
							grabName := (holder[obj][index]["currencyTypeName"] ? holder[obj][index]["currencyTypeName"] : False)
							grabChaosVal := (holder[obj][index]["chaosEquivalent"] ? holder[obj][index]["chaosEquivalent"] : False)
							grabPayVal := (holder[obj][index]["pay"] ? holder[obj][index]["pay"] : False)
							grabRecVal := (holder[obj][index]["receive"] ? holder[obj][index]["receive"] : False)
							grabPaySparklineVal := (holder[obj][index]["paySparkLine"] ? holder[obj][index]["paySparkLine"] : False)
							grabRecSparklineVal := (holder[obj][index]["receiveSparkLine"] ? holder[obj][index]["receiveSparkLine"] : False)
							grabPayLowSparklineVal := (holder[obj][index]["lowConfidencePaySparkLine"] ? holder[obj][index]["lowConfidencePaySparkLine"] : False)
							grabRecLowSparklineVal := (holder[obj][index]["lowConfidenceReceiveSparkLine"] ? holder[obj][index]["lowConfidenceReceiveSparkLine"] : False)
							holder[obj][index] := {"name":grabName
								,"chaosValue":grabChaosVal
								,"pay":grabPayVal
								,"receive":grabRecVal
								,"paySparkLine":grabPaySparklineVal
								,"receiveSparkLine":grabRecSparklineVal
								,"lowConfidencePaySparkLine":grabPayLowSparklineVal
								,"lowConfidenceReceiveSparkLine":grabRecLowSparklineVal}
							Ninja[apiString] := holder[obj]
						}
					}
					Else 
					{
						for index, indexArr in objlist
						{
							grabName := (holder[obj][index]["currencyTypeName"] ? holder[obj][index]["currencyTypeName"] : False)
							grabPoeTrdId := (holder[obj][index]["poeTradeId"] ? holder[obj][index]["poeTradeId"] : False)
							grabId := (holder[obj][index]["id"] ? holder[obj][index]["id"] : False)

							holder[obj][index] := {"name":grabName
								,"poeTradeId":grabPoeTrdId
								,"id":grabId}

							Ninja["currencyDetails"] := holder[obj]
						}
					}
				}
				FileDelete, %A_ScriptDir%\data\data_%apiString%.txt
			}
			Return
		}
		Else
		{
			UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeague%, %A_ScriptDir%\data\data_%apiString%.txt
			if ErrorLevel{
				MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeague% not being valid
			}
			Else if (ErrorLevel=0){
				FileRead, JSONtext, %A_ScriptDir%\data\data_%apiString%.txt
				holder := JSON.Load(JSONtext)
				For obj, objlist in holder
				{
					If (obj != "currencyDetails")
					{
						for index, indexArr in objlist
						{
							grabSparklineVal := (holder[obj][index]["sparkline"] ? holder[obj][index]["sparkline"] : False)
							grabLowSparklineVal := (holder[obj][index]["lowConfidenceSparkline"] ? holder[obj][index]["lowConfidenceSparkline"] : False)
							grabExaltVal := (holder[obj][index]["exaltedValue"] ? holder[obj][index]["exaltedValue"] : False)
							grabChaosVal := (holder[obj][index]["chaosValue"] ? holder[obj][index]["chaosValue"] : False)
							grabName := (holder[obj][index]["name"] ? holder[obj][index]["name"] : False)
							grabLinks := (holder[obj][index]["links"] ? holder[obj][index]["links"] : False)
							grabVariant := (holder[obj][index]["variant"] ? holder[obj][index]["variant"] : False)
							
							holder[obj][index] := {"name":grabName
								,"chaosValue":grabChaosVal
								,"exaltedValue":grabExaltVal
								,"sparkline":grabSparklineVal
								,"lowConfidenceSparkline":grabLowSparklineVal
								,"links":grabLinks
								,"variant":grabVariant}
						}
					}
				}
				Ninja[apiString] := holder[obj]
			}
			FileDelete, %A_ScriptDir%\data\data_%apiString%.txt
		}
			;MsgBox % "Download worked for Ninja Database  -  There are " Ninja.Count() " Entries in the array
		Return
	}
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** API scraper for Path of Exile Leagues
*/
    UpdateLeagues:
        UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
        FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
        LeagueIndex := JSON.Load(JSONtext)
        textList= 
        For K, V in LeagueIndex
            textList .= (!textList ? "" : "|") LeagueIndex[K]["id"]
        GuiControl, , selectedLeague, |%selectedLeague%||%textList%
    Return
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** Cooldown Timers
*/
    ; TimerFlask - Flask CD Timers
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerFlask1:
		OnCooldown[1]:=0
		settimer,TimerFlask1,delete
	return

	TimerFlask2:
		OnCooldown[2]:=0
		settimer,TimerFlask2,delete
	return

	TimerFlask3:
		OnCooldown[3]:=0
		settimer,TimerFlask3,delete
	return

	TimerFlask4:
		OnCooldown[4]:=0
		settimer,TimerFlask4,delete
	return

	TimerFlask5:
		OnCooldown[5]:=0
		settimer,TimerFlask5,delete
	return

    ; TimerUtility - Utility CD Timers
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TimerUtility1:
		OnCooldownUtility1 := 0
		settimer,TimerUtility1,delete
	Return
	TimerUtility2:
		OnCooldownUtility2 := 0
		settimer,TimerUtility2,delete
	Return
	TimerUtility3:
		OnCooldownUtility3 := 0
		settimer,TimerUtility3,delete
	Return
	TimerUtility4:
		OnCooldownUtility4 := 0
		settimer,TimerUtility4,delete
	Return
	TimerUtility5:
		OnCooldownUtility5 := 0
		settimer,TimerUtility5,delete
	Return
    ; TDetonated - Detonate CD Timer
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TDetonated:
		Detonated:=0
		;settimer,TDetonated,delete
	return


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** CheckOHB - GetPercent - Overhead Healthbar detection and a method to get health percent
*/ ; 
    CheckOHB()
    {
        Global GameStr, HealthBarStr, OHB, OHBLHealthHex, OHBLESHex, OHBLEBHex, OHBCheckHex
        If WinActive(GameStr)
        {
            WinGetPos, GameX, GameY, GameW, GameH
            ; if (ok:=FindText(GameX + Round(GameW / (1920 / 907)), GameY + Round(GameH / (1080 / 177)), 106, Round(GameH / (1080 / 370)) - Round(GameH / (1080 / 177)), 0, 0, HealthBarStr,0))
            if (ok:=FindText(GameX + Round((GameW / 2)-(OHBStrW/2)), GameY + Round(GameH / (1080 / 177)), GameX + Round((GameW / 2)+(OHBStrW/2)), Round(GameH / (1080 / 370)) , 0, 0, HealthBarStr,0))
            {
                ok.1.3 -= 1
                ok.1.4 += 8

                OHB := { "X" : ok.1.1
                    , "Y" : ok.1.2
                    , "rX" : ok.1.1 + ok.1.3
                    , "W" : ok.1.3
                    , "H" : ok.1.4
                    , "hpY" : ok.1.2 - (ok.1.4 // 2)
                    , "mY" : ok.1.2 + (ok.1.4 // 2)
                    , "esY" : ok.1.2 - 2
                    , "ebY" : ok.1.2 + 2 }
                OHB["pX"] := { 1 : Round(ok.1.1 + (ok.1.3* 0.10))
                    , 2 : Round(ok.1.1 + (ok.1.3* 0.20))
                    , 3 : Round(ok.1.1 + (ok.1.3* 0.30))
                    , 4 : Round(ok.1.1 + (ok.1.3* 0.40))
                    , 5 : Round(ok.1.1 + (ok.1.3* 0.50))
                    , 6 : Round(ok.1.1 + (ok.1.3* 0.60))
                    , 7 : Round(ok.1.1 + (ok.1.3* 0.70))
                    , 8 : Round(ok.1.1 + (ok.1.3* 0.80))
                    , 9 : Round(ok.1.1 + (ok.1.3* 0.90))
                    , 10 : Round(ok.1.1 + ok.1.3) }
                Return OHB.X + OHB.Y
            }
            Else
            {
                Ding(500,5,"OHB Not Found")
                Return False
            }
        }
        Else 
            Return False
    }

    GetPercent(CID, PosY, Variance)
    {
        Thread, NoTimers, true		;Critical
        Global OHB, OHBLHealthHex
        Found := OHB.X
        ScreenShot(GameX, GameY, GameX + GameW, GameY + GameH)
        temp1 := ToRGB(CID), temp2 := ToRGB(ScreenShot_GetColor(OHB.X+1, PosY))
        If !CompareRGB(temp1,temp2,Variance)
        {
            Ding(500,4,"OHB Obscured, Moved, or Dead" )
            Return HPerc
        }
        Loop 10
        {
            pX:= OHB.pX[A_Index]
            temp1 := ToRGB(CID), temp2 := ToRGB(ScreenShot_GetColor(pX, PosY))
            If CompareRGB(temp1,temp2,Variance)
                Found := pX
            Else 
            {
                If (OHBxy != NewOHBxy := CheckOHB())
                {
                    Ding(500,4,"OHB Moved" )
                    Return HPerc
                }
                Else If (!OHBxy || !NewOHBxy)
                {
                    Ding(500,3,"OHB Error" )
                    Return HPerc
                }
                Else
                    Break
            }
        }
        Return Round(100* (1 - ( (OHB.rX - Found) / OHB.W ) ) )
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -




/*** GroupByFourty - Mathematic function to sort quality into groups of 40
*     Path of Exile Mathematic grouping function for AutoHotkey.
*     Developed by Bandit
* Version:
*     v1.0.0 [updated 11/19/2019 (MM/DD/YYYY)]
*/
    GroupByFourty(ArrList) {
        GroupList := {}
        tQ := 0
        ; Get total of Value before
        For k, v in ArrList
            allQ += v.Q 
        ; Begin adding values to GroupList
        Loop, 20
            GroupTotal%ind% := 0
        Gosub, Group_Add
        Gosub, Group_Swap
        Gosub, Group_Move
        Gosub, Group_Cleanup
        Gosub, Group_Cleanup
        Gosub, Group_Add
        Gosub, Group_Swap
        Gosub, Group_Cleanup
        ; Gosub, Group_Move
        ; Gosub, Group_Cleanup
        ; Gosub, Group_Add
        ; Gosub, Group_Move
        ; Gosub, Group_Cleanup
        ; Gosub, RebaseTotals

        ; Final tallies
        For k, v in ArrList
            remainQ += v.Q 
        If !remainQ
            remainQ:=0
        tQ=
        For k, v in GroupList
            For kk, vv in v
                tQ += vv.Q 
        If !tQ
            tQ:= 0
        overQ := mod(tQ, 40)
        If !overQ
            overQ:= 0
        ; Catch for high quality gems in low quantities
        If (tQ = 0 && remainQ >= 40 && remainQ <= 57)
        {
            Loop, 20
            {
                ind := A_Index
                For k, v in ArrList
                {
                    If (GroupTotal%ind% >= 40)
                        Continue
                    If (GroupTotal%ind% + v.Q <= 57)
                    {
                        If !IsObject(GroupList[ind])
                            GroupList[ind]:={}
                        GroupList[ind].Push(ArrList.Delete(k))
                        GroupTotal%ind% += v.Q
                    }
                }
            }
            remainQ=
            For k, v in ArrList
                remainQ += v.Q 
            If !remainQ
                remainQ:=0
            tQ=
            For k, v in GroupList
                For kk, vv in v
                    tQ += vv.Q 
            If !tQ
                tQ:= 0
            overQ := mod(tQ, 40)
            If !overQ
                overQ:= 0
        }
        expectC := Round((tQ - overQ) / 40)
        ; Display Tooltips
        ToolTip,Total Quality:`t %allQ%`%,100,180,15
        ToolTip,Currency Value:`t %expectC% orbs,100,200,18
        ToolTip,Groups Quality:`t %tQ%`%,100,220,16
        ToolTip,Excess Groups Q:`t %overQ%`%,100,240,17
        ToolTip,Leftover Quality:`t %remainQ%`%,100,260,19
        SetTimer, RemoveToolTip, -20000
        Return GroupList

        RebaseTotals:
            tt=
            tt2=
            For k, v in GroupList
            {
                tt .= GroupTotal%k% . "`r"
                GroupTotal%k% := 0
                For kk, vv in v
                {
                    GroupTotal%k% += vv.Q
                }
            }
            For k, v in GroupList
                tt2 .= GroupTotal%k% . "`r"
            If (tt != tt2)
                MsgBox,% "Mismatch Found!`r`rFirst Values`r" . tt . "`r`rSecond Values`r" . tt2
        Return

        Group_Batch:
            Gosub, Group_Trim
            Gosub, Group_Trade
            Gosub, Group_Add
            Gosub, Group_Swap
        Return

        Group_Cleanup:
            ; Remove groups that didnt make it to 40
            Loop, 3
            For k, v in GroupList
            {
                If (GroupTotal%k% < 40)
                {
                    For kk, vv in v
                    {
                        ArrList.Push(v.Delete(kk))
                        GroupTotal%k% -= vv.Q
                    }
                }
            }
        Return

        Group_Swap:
            ; Swap values Between groups to move closer to 40
            For k, v in GroupList
            {
                If (GroupTotal%k% <= 40)
                    Continue
                For kk, vv in v
                {
                    If (GroupTotal%k% <= 40)
                        Continue
                    For kg, vg in GroupList
                    {
                        If (k = kg)
                            Continue
                        For kkg, vvg in vg
                        {
                            newk := GroupTotal%k% - vv.Q + vvg.Q
                            newkg := GroupTotal%kg% + vv.Q - vvg.Q
                            If (GroupTotal%kg% >= 40 && newkg < 40)
                                Continue
                            If (newk >= 40 && newk < GroupTotal%k%)
                            {
                                GroupList[kg].Push(GroupList[k].Delete(kk))
                                GroupList[k].Push(GroupList[kg].Delete(kkg))
                                GroupTotal%k% := newk, GroupTotal%kg% := newkg
                                Break 2
                            }
                        }
                    }
                }
            }
        Return

        Group_Trade:
            ; Swap values from group to arrList to move closer to 40
            For k, v in GroupList
            {
                If (GroupTotal%k% <= 40)
                    Continue
                For kk, vv in v
                {
                    If (GroupTotal%k% <= 40)
                        Continue
                    For kg, vg in ArrList
                    {
                        newk := GroupTotal%k% - vv.Q + vvg.Q
                        If (newk >= 40 && newk < GroupTotal%k%)
                        {
                            ArrList.Push(GroupList[k].Delete(kk))
                            GroupList[k].Push(ArrList.Delete(kg))
                            GroupTotal%k% := newk
                            Break
                        }
                    }
                }
            }
        Return

        Group_Move:
            ; Move values from incomplete groups to add as close to 40
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 40)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Cleanup
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 41)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 42)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 43)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 44)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 45)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 46)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 47)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 48)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 49)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 50)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 51)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 52)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 53)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 54)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
            Loop 20
            {
                ind := A_Index
                If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
                    Continue
                For k, v in GroupList
                {
                    If (ind = k || (GroupTotal%k% >= 40))
                        Continue
                    For kk, vv in v
                    {
                        If (GroupTotal%ind% + vv.Q <= 55)
                        {
                            If !IsObject(GroupList[ind])
                                GroupList[ind]:={}
                            GroupList[ind].Push(GroupList[k].Delete(kk))
                            GroupTotal%ind% += vv.Q
                            GroupTotal%k% -= vv.Q
                        }
                    }
                }
            }
            Gosub, Group_Batch
        Return

        Group_Add:
            ; Find any values to add to incomplete groups
            Loop, 20
            {
                ind := A_Index
                For k, v in ArrList
                {
                    If (GroupTotal%ind% >= 40)
                        Continue
                    If (GroupTotal%ind% + v.Q <= 40)
                    {
                        If !IsObject(GroupList[ind])
                            GroupList[ind]:={}
                        GroupList[ind].Push(ArrList.Delete(k))
                        GroupTotal%ind% += v.Q
                    }
                }
            }
        Return

        Group_Trim:
            ; Trim excess values if group above 40
            Loop 20
            {
                ind := A_Index
                If GroupTotal%ind% > 40
                {
                    For k, v in GroupList[ind]
                    {
                        If (GroupTotal%ind% - v.Q >= 40)
                        {
                            ArrList.Push(GroupList[ind].Delete(k))
                            GroupTotal%ind% -= v.Q
                        }
                    }
                }
            }
        Return
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -






;_______________________ Hotkey() _______________________
;____ Date: June 2006
;____ AHK version: 1.0.44.06
;____ Platform: WinXP
;____ Authors: Sam & Roland


    ;#################### Example Gui ########################
    /*
    #SingleInstance, force

    Gui, Margin, 5, 5
    Gui, Add, Text,, Hotkey(Options="",Prompt="",Title="",GuiNumber=77)
    Gui, Font, s10
    Gui, Add, Text, w500
    ,Options:`n-Keynames/-Symbols -LR -~ -* -UP -Joystick -Mouse -Mods -&& +Default1/2 +OwnerN -Owner -Modal +ReturnKeynames +Tooltips

    E1 = Hotkey()
    E2 = Hotkey("+Default1 -LR -UP","Please hold down the keys you want to turn into a hotkey:")
    E3 = Hotkey("+Default1 -Symbols +ReturnKeynames +Tooltips","","","Hotkey configuration")
    E4 = Hotkey("+Default2 -Mouse -Keynames -Modal -LR","Note that you're able to interact with the owner")
    E5 = Hotkey("-~ -* -Up -LR +Owner2","This window has no owner, since a non-existen owner (Gui2) was specified")

    Gui, Font, s8
    Loop, 5
        {
            Gui, Add, Text, w500, % E%a_index% ":"
            Gui, Add, ListView
            , v%a_index% r1 -Hdr -LV0x20 r1 w200 cGreen BackgroundFFFACD gLV_DblClick, 1|2
            LV_ModifyCol(1, 0)
            LV_ModifyCol(2, 195)
        }
    Gui, Font, s10
    Gui, Add, Text, w500, Note: Double-click on one on one of the ListViews to test the Hotkey dialogue.
    Gui, Show, x100 y100 Autosize, Hotkey()	
    Return

    GuiClose:
    ExitApp

    LV_DblClick:
    If a_guicontrolevent <> DoubleClick
        return
    Gui, ListView, %a_guicontrol%
    LV_Delete(1)
    If a_guicontrol = 1
            LV_Add("","",Hotkey())
    else if a_guicontrol = 2
            LV_Add("","",Hotkey("+Default1 -LR -UP","Please hold down the keys you want to turn into a hotkey:"))
    else if a_guicontrol = 3
            LV_Add("","",Hotkey("+Default1 -Symbols +ReturnKeynames +Tooltips","","","Hotkey configuration"))
    else if a_guicontrol = 4
            LV_Add("","",Hotkey("+Default2 -Mouse -Keynames -Modal -LR","Note that you're able to interact with the owner"))
    else if a_guicontrol = 5
            LV_Add("","",Hotkey("-~ -* -Up -LR +Owner2","This window has no owner, since a non-existen owner (Gui2) was specified"))
    return
    */

/*
#############################################################################
################################ Remarks ####################################
#############################################################################


  **************************************************** Remarks: **************************************************
  * -It would have been to hard (and to messy) to compact everything into a single funtion, so we have a few globals.
  *     All the globals (and all the subroutines) start with "Hotkey_" though, so this shouldn't be a problem
  * -Both the keyboard and mouse hook will be installed 
  * -"Critical" has to be turned off for the thread that called the funtion, to allow the threads in the funtion to run.
  * This could cause problems obviously, although turning Critical back on after calling the funtion should work okay in most cases
  * -When the user clicks "Submit", the funtion will create the hotkey (If non-blank) and check ErrorLevel (and If ErrorLevel <> 0 
  *     display a Msgbox saying the hotkey is invalid and asking to notify the author). This way you shouldn't have to worry about 
  * invalid hotkeys yourself.
  * -You can easily change the default color and font by editing the default values right at the top of the funtion.
  *     Should be easy to spot.
  * -Also, You can easily change the default behavior by changing the Options param right at the top of the funtion
  *     (for instance: Options = %Options% +Default1 -Mouse). You can also edit the keyList of course.


########################## The main funtion ############################

    Note: The following funtions must all be present (they are included here, but I thought 
            I had better mention it):
            
    Hotkey(Options="",Prompt="",BottomInfo="",Title="",GuiNumber=77)
    AddPrefixSymbols(keys)
    KeysToSymbols(s)
    Keys()
    ToggleOperator(p)
    IsHotkeyValid(k)


    ######## Options ########
    Zero or more of the following strings may be present in Options. ; Spaces are optional, 
    i.e. "-~-*+Default2" is valid. -/+ are NOT optional, though. I.e. "Owner3" is invalid:

    -Keynames/-Symbols: Omits one of the ListViews
    -LR: Omit the "left/right modifiers" checkbox (forced for Win95/98/ME)
    -~, -*, -Up: Omit one or more of the corresponding checkboxes (forced for Win95/98/ME)
    -Joystick/-Mouse: No joystick and/or mouse hotkeys
    -Mods: No modifers
    -&: No ampersand hotkeys (forced for Win95/98/ME)
    +Default1, +Default2: Sets the default button (and omits the Enter key from the keyList)
    +Owner*: Sets the owner. Default is A_Gui, or 1 If A_Gui is blank (or none If Gui1 doesn't exist)
    -Owner: No owner
    -Modal: The dialogue will be owned, but not modal
    +ReturnKeynames: Return "Control+Alt+c" instead of "^!c" etc. These can later be converted by calling the KeysToSymbols(s) funtion
    +Tooltips: Gives a little info about "~", "*" and "UP" (basically copied from the docs)
    */
 

    ;this funtion will Return a (hopfully) valid key combination, either
    ;as symbols (^!+..) or as keynames (Control+Alt+Shift+Space...)
    Hotkey(Options="",Prompt="",BottomInfo="",Title="",GuiNumber=77)
    {
        global Hotkey_LeftRightMods,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_Hotkey1,Hotkey_Hotkey2
                    ,Hotkey_ButtonSubmit,Hotkey_ButtonCancel,Hotkey_DefaultButton,Hotkey_keyList,Hotkey_modList_left_right
                    ,Hotkey_modList_normal,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

        ;these are all cleared again before the funtion Returns, to be on the safe side
        HotKey_globals = Hotkey_LeftRightMods,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_Hotkey1,Hotkey_Hotkey2
                    ,Hotkey_ButtonSubmit,Hotkey_ButtonCancel,Hotkey_DefaultButton,Hotkey_keyList,Hotkey_modList_left_right
                    ,Hotkey_modList_normal,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

        batch_lines = %A_BatchLines%
        SetBatchLines -1		;this speeds things up a bit (we reset it after the Gui is shown)

        ;change these to suit your needs:
        ;default colors, etc. 
        defBgColor = 
        defTxtColor = 000000
        defLVBgColor = FFFFFF
        defLVTxtColor1 = Green
        defLVTxtColor2 = 6495ED
        defFontName = Arial
        defFontSize = 8
        defTitle = Hotkey

        ;Note: To change the default behavior permenantly, just add:
        ;Options = %Options%***MyFavoriteOptions*** 

        ;we can't have the special prefix symbols or the & on Win95/98/ME
        ;so we just edit the Options param to exclude them
        If A_OSType = WIN32_WINDOWS		
            Options = %Options%-~-*-Up-&-lr

        ;this is a bit akward but we have to store the Gui # in a seperate variable
        ;because GuiNumber is a parameter and we can't declare it as global
        If GuiNumber <>
            Hotkey_numGui = %GuiNumber%
        Else
            Hotkey_numGui = 77

        ;because we use ListViews (who operate on the default Gui), we have
        ;to set the default in every thread that operates on the ListViews
        Gui, %Hotkey_numGui%: Default	

        ;it's global, so we have to empty it
        Hotkey_JoystickButtons =
        ;get a list of joystick buttons
        IfNotInString, Options, -Joystick
        {
        ;Query each joystick number to find out which ones exist.
        Loop 32
        {
            ;If the joystick has a name
            GetKeyState, joy_name, %A_Index%JoyName
            If joy_name <>
            {
            ;It's our joystick.
            joy_number = %A_Index%
            joy_exists = 1
            break
            }
        }
        ;If we don't have a joystick
        If joy_number <= 0
        {
            ;record it so.
            joy_exists = 0
        }
        ;If we do have a joystick
        Else
        {
            ;Determine the number of buttons.
            GetKeyState, num_buttons, %joy_number%JoyButtons
            ;Go through the buttons
            Loop, %num_buttons%
            {
            newButton = Joy%a_index%
            Hotkey_JoystickButtons = %Hotkey_JoystickButtons%,%newButton%
            }
            StringTrimLeft, Hotkey_JoystickButtons, Hotkey_JoystickButtons, 1
        }
        }

        ;the main key list. Add (or delete) keys to suit your needs
        Hotkey_keyList =
        ( Join
        #|.|,|-|<|+|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|ü|ä|ö|ß|1|2|3|4|5|6|7|8|9|0
        |Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9
        |NumpadClear|Right|Left|Up|Down|NumpadDot|Space|Tab|Escape|Backspace|Delete|Insert|Home
        |End|PgUp|PgDn|ScrollLock|CapsLock|NumLock|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub
        |F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|AppsKey|PrintScreen|CtrlBreak|Pause|Break
        |Browser_Back|Browser_Forward|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute
        |Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media
        |Launch_App1|Launch_App2|Sleep
        )

        ;If we have a default button, the Enter key can't be part of the key list
        IfNotInString, Options, +Default
            Hotkey_keyList = %Hotkey_keyList%|Enter

        ;add the mouse buttons to the list 
        MouseButtons = LButton|RButton|MButton|XButton1|XButton2
        IfNotInString, Options, -Mouse
            Hotkey_keyList = %Hotkey_keyList%|%MouseButtons%

        ;If -LR is present in Options, the two modifier key lists are the same
        ;Else we have two different lists. Which one is used depends on whether
        ;the "left/right modifiers" checkbox is checked or not
        IfNotInString, Options, -lr
            Hotkey_modList_left_right = LControl,RControl,LAlt,RAlt,LWin,RWin,LShift,RShift
        Else
            Hotkey_modList_left_right = Control,Alt,LWin,RWin,Shift
        Hotkey_modList_normal = Control,Alt,LWin,RWin,Shift

        ;these will be turned into hotkeys to override their native funtion
        ;(we don't want calculator to launch when the user presses Launch_App1 etc...)
        turnIntoHotkeyList =
        (Join
        PrintScreen|CtrlBreak|Pause|Break
        |Browser_Back|Browser_Forward|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute
        |Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media
        |Launch_App1|Launch_App2|Sleep|Control|Alt|LWin|RWin|Shift
        )

        ;destroy the Gui, just in case
        Gui, %Hotkey_numGui%: Destroy

        ;Owner/modal handling; by default, the Gui is owned, either by %a_gui% or
        ;by Gui1 If %a_gui% is blank. If the owner doesn't exist, well, it will not be owned!
        IfNotInString, Options, -Owner
            {
                IfInString, Options, +Owner
                    {
                        StringMid, owner, Options, InStr(Options, "+Owner") + 7, 2
                        If owner not integer
                            StringTrimRight, owner, owner, 1
                        If owner = 
                            StringTrimLeft, owner, Options, InStr(Options, "+Owner") + 5
                    }
                Else
                {
                        If a_gui <>
                            owner = %a_gui%
                        Else
                            owner = 1
                }
            Gui, %owner%: +LastfoundExist
            IfWinExist
                {
                IfNotInString, Options, -Modal
                    Gui, %owner%: +Disabled
                Gui, %Hotkey_numGui%: +Owner%owner%
                }
            Else
                owner =
            }

        ;the Gui has no Close button (this way we're flexible with the Gui #)
        Gui, %Hotkey_numGui%:+Lastfound +Toolwindow -SysMenu	
        GuiID := WinExist()		;used for Hotkey, IfWinActive, ahk_id%GuiID%
            
        Gui, %Hotkey_numGui%:Font, s%defFontSize% bold c%defTxtColor%, %defFontName%
        Gui, %Hotkey_numGui%:Margin, 5, 5
        Gui, %Hotkey_numGui%:Color, %defBgColor%
        If prompt <>
            Gui, %Hotkey_numGui%:Add, Text, w220, %Prompt%
        ; If prompt <>
        ; 	Gui, %Hotkey_numGui%:Add, Text, w220 cRed, (Assigning currently requires a script reload)
        IfNotInString, Options, -KeyNames
            Gui, %Hotkey_numGui%:Add, ListView
            , vHotkey_Hotkey1 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor1% Background%defLVBgColor%, 1|2
        Else
            Gui, %Hotkey_numGui%:Add, ListView
            , vHotkey_Hotkey1 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor1% Background%defLVBgColor% Hidden, 1|2
        LV_ModifyCol(1, 0)
        LV_ModifyCol(2, 195)
        IfInString, Options, -Symbols
            hidden = hidden
        If (InStr(Options, "-Symbols") <> 0 OR InStr(Options, "-KeyNames") <> 0)
            Gui, %Hotkey_numGui%:Add, ListView
            , vHotkey_Hotkey2 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor2% Background%defLVBgColor% %hidden% xp yp, 1|2
        Else
            Gui, %Hotkey_numGui%:Add, ListView
            , vHotkey_Hotkey2 r1 -Hdr -LV0x20 r1 w220 c%defLVTxtColor2% Background%defLVBgColor%, 1|2
        LV_ModifyCol(1, 0)
        LV_ModifyCol(2, 195)

        ;this is a bit of a mess, because we optionally have to exclude some of these..
        If Options not contains -lr,-mods
            Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_LeftRightMods, left/right modifiers
            IfNotInString, Options, -~
                {
                Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_Tilde Section gHotkey_Tilde, ~
                ys = ys
                }
            IfNotInString, Options, -*
                {
                Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_Wildcard %ys% Section gHotkey_Wildcard, *
                ys = ys
                }				
            Else If ys =
                ys =
            IfNotInString, Options, -Up
                Gui, %Hotkey_numGui%:Add, Checkbox, vHotkey_UP %ys% gHotkey_UP, UP


        Gui, %Hotkey_numGui%:Font, norm
        Gui, %Hotkey_numGui%:Add, Button, vHotkey_ButtonSubmit x62.5 Section w50 h20 gHotkey_Submit, Submit
        Gui, %Hotkey_numGui%:Add, Button, vHotkey_ButtonCancel h20 ys w50 gHotkey_Cancel, Cancel
        Gui, %Hotkey_numGui%:Add, Text, x5 y+10 w220, % BottomInfo
        ;the Timer sets focus to this button all the time to avoid key combinations triggering a focused checkbox
        Gui, %Hotkey_numGui%:Add, Button, vHotkey_DefaultButton x0 y0 w0 h0

        ;set the default button If called for
        IfInString, Options, +Default
            {
                StringMid, defButton, Options, InStr(Options, "+Default") + 8, 1
                If defButton = 1
                    GuiControl, %Hotkey_numGui%:+Default, Hotkey_ButtonSubmit
                Else If defButton = 2
                    GuiControl, %Hotkey_numGui%:+Default, Hotkey_ButtonCancel
            }

        ;the default title
        If title =
            title = %defTitle%

        ;turn these keys into a hotkeys to try
        ;and override their native funtion 
        Hotkey, IfWinActive, ahk_id%GuiID%
        Loop, Parse, turnIntoHotkeyList, |
                    Hotkey, %a_loopfield%, Return, UseErrorLevel

        IfNotInString, Options, -Mouse
            {
                Hotkey, *WheelUp, Wheel, UseErrorLevel 
                Hotkey, *WheelDown, Wheel, UseErrorLevel
            }

        ;If we have an owner, center the Gui on it
        If owner <> 
            {
                Gui, %Hotkey_numGui%:Show, Autosize Hide
                Gui, %owner%: +Lastfound
                WinGetPos, x, y, w, h
                Gui, %Hotkey_numGui%:+Lastfound
                WinGetPos,,,gw,gh
                gx := x + w/2 - gw/2
                gy := y + h/2 - gh/2
                Gui, %Hotkey_numGui%: Show, x%gx% y%gy%, %title%
            }
        Else
            Gui, %Hotkey_numGui%:Show, Autosize, %title%
            
        ;400 is about right, but feel free to experiment
        ;basically you have to keep the balance between registering new keys fast enough
        ;but not registering the release of keys TOO fast
        SetTimer, Hotkey_Hotkey, 400	

        ;we need Options to be global so that the other functions can use it
        ;so we store it in another variable
        Hotkey_OptionsGlobal = %Options%

        Gui, %Hotkey_numGui%:+Lastfound
        Critical Off		;has to be turned off to allow the other threads to run
        SetBatchLines %batch_lines%		;reset it

        WinWaitClose

        SetTimer, Hotkey_Hotkey, Off		;turn off the timer
        Tooltip		;in case we were displaying a tooltip
        Tooltip,,,,2

        ;free all the globals, to be on the safe side:
        Loop, Parse, HotKey_globals, `,
            %a_loopfield% =

        ;reset the default Gui
        If owner <>
            Gui, %owner%: Default
        Else If a_gui <> 
            Gui, %a_gui%: Default
        Else
            Gui, 1: Default
            
        ;re-enable and activate the owner
        If owner <>
            {
            Gui, %owner%: -Disabled
            Gui, %owner%: Show
            }
            
        Return ReturnValue	

        ;####################### Timer ####################

        Hotkey_Hotkey:
        IfWinNotActive, ahk_id%GuiID%
            Return
            
        Gui, %Hotkey_numGui%: Default	

        ;If the mouse isn't over a control, set focus to an (invisible) button
        MouseGetPos,,,win,ctrl
        If (win <> GuiID OR ctrl = "")
            {
                GuiControl, Focus, Hotkey_DefaultButton
                Tooltip,,,,2		;we use tooltip1 to display a message Elsewhere, so use #2
            }
        Else IfInString, Hotkey_OptionsGlobal, +Tooltips		;If we want tooltips
            {
                ControlGetText, t, %ctrl%, ahk_id%win%
                If t = ~
                    tip = Tilde: When the hotkey fires, its key's`nnative function will not be blocked`n(hidden from the system). 
                Else If t = *
                    tip = Wildcard: Fire the hotkey even If extra`nmodifiers are being held down. 
                Else If t = UP
                    tip = Causes the hotkey to fire upon release of the key`nrather than when the key is pressed down.
                Else 
                    tip =
                Tooltip %tip%,,,2
            }
            
        keys := Keys()			;get the keys that are beeing held down

        ;If no keys are down, find out If we're looking at something 
        ;like "Control+Alt+" or a valid hotkey, and clear the ListView 
        ;in case #1
        If keys =
            {
                Gui, ListView, Hotkey_Hotkey1
                LV_GetText(k, 1, 2)
                ;If UP is checked we could have "Ctrl+Alt+ UP", so get rid of the UP
                StringReplace, k, k, %a_space%UP		
                ;If the right-most char is a "+" but we don't have "++" (e.g. "Ctrl+Alt++"), clean up
                If (InStr(k, "+","",0) = StrLen(k) AND InStr(k, "++") = 0)
                    {
                        LV_Delete(1)
                        Gui, ListView, Hotkey_Hotkey2
                        LV_Delete(1)
                        ;clear keys_prev in this case
                        keys_prev =
                    }
                Return		;nothing Else
            }

        ;this avoids flickering
        If keys = %keys_prev%
            Return
        keys_prev = %keys%

        ;this handles differing between, say, "Space & LButton" and "LButton & Space"
        ;by remembering which key was pressed first (otherwise the keys would always
        ;be in the order they appear in the keyList
        IfNotInString, keys, +		;If we have only a single key, remember it
            firstKey = %keys%
        ;Else If we have more than one but no modifier(s)
        Else If keys not contains %Hotkey_modList_left_right%,%Hotkey_modList_normal%,Win	
            {
                If InStr(keys, firstKey) <> 1		;If they're in the wrong order
                    {
                        StringLeft, k1, keys, InStr(keys, "+") - 1		;swap them
                        StringTrimLeft, k2, keys, InStr(keys, "+") 
                        keys = %k2%+%k1%
                    }
            }

        ;add the special prefix keys from the checkboxes
        keys := AddPrefixSymbols(keys)

        ;delete old keys and add new ones
        Gui, %Hotkey_numGui%: ListView, Hotkey_Hotkey1
        LV_Delete(1)
        LV_Add("","",keys)

        Gui, ListView, Hotkey_Hotkey2
        LV_Delete(1)
        LV_Add("","",KeysToSymbols(keys))
        Return

        ;############# checkbox labels ###########

        ;these all call the same function... easier that way
        Hotkey_Tilde:
        Hotkey_Wildcard:
        Hotkey_Up:
        ToggleOperator(a_guicontrol)
        Return

        ;########## Remove the tooltip and the pseudo label for the Hotkey #####

        Hotkey_RemoveTooltip:
        Tooltip
        Return

        Return:
        Return

        ;############### The Label for WheelUp&WheelDown ##################

        Wheel:
        StringTrimLeft, w, a_thishotkey, 1		;remove the "*" from WheelUp/Down

        Gui, %Hotkey_numGui%: Default
        Gui, %Hotkey_numGui%: Submit, NoHide

        ;in this case only check for modifiers
        IfInString, Hotkey_OptionsGlobal, -&
            {
                mods =
                
                ;If -LR is not present in options AND the LR checkbox is checked,
                ;use the left/right mod list
                If (InStr(Hotkey_OptionsGlobal, "-LR") = 0 AND Hotkey_LeftRightMods <> 0)
                    modList = %Hotkey_modList_left_right%
                Else
                    modList = %Hotkey_modList_normal%
                    
                Loop, Parse, modList, `,
                    {
                        If GetKeyState(a_loopfield,"P") <> 1
                            continue
                        mods = %mods%%a_loopfield%+
                    }
                
                If Hotkey_LeftRightMods <> 1
                    {
                        StringReplace, mods, mods, LWin, Win
                        StringReplace, mods, mods, RWin, Win
                    }
                
                k = %mods%%w%	;the keys are the modifiers plus WheelUp/down
                
                If k = %k_prev%
                    Return
                k_prev = %k%
                
                ;add the prefix symbols
                k := AddPrefixSymbols(k)
                
                ;add them to the LV and Return
                Gui, ListView, Hotkey_Hotkey1
                LV_Delete(1)
                LV_Add("","",k)
                Gui, ListView, Hotkey_Hotkey2
                LV_Delete(1)
                LV_Add("","",KeysToSymbols(k))
            Return
            }

        ;If "-&" is not present in Options, get all the keys, like in the Hotkey_Hotkey timer:

        k := Keys()			

        ;just in case somebody tries mapping "Joy3 & WheelUp" or whatever :)
        If k in %Hotkey_JoystickButtons%
            {
                Tooltip, Note: Joystick buttons are not`nsupported as prefix keys.
                SetTimer, Hotkey_RemoveTooltip, 5000
                k =
            }

        If (InStr(k, "+","",0) <> StrLen(k))	;If it's not something like "Control+Alt+"
            {
            IfInString, k, +		;If we have more than one key, remove all but the first (can't have "a & b & WheelUp")
                StringLeft, k, k, InStr(k, "+","",0)
            Else
                k = %k%+		;turn "Space" into "Space+" etc...
            }
            
        k = %k%%w%		;add WheelUp/Down

        If k = %k_prev%
            Return
        k_prev = %k%

        ;add the prefix symbols
        k := AddPrefixSymbols(k)

        ;add the keys to the ListViews:
        Gui, ListView, Hotkey_Hotkey1
        LV_Delete(1)
        LV_Add("","",k)
        Gui, ListView, Hotkey_Hotkey2
        LV_Delete(1)
        LV_Add("","",KeysToSymbols(k))
        Return

        ;################### Submit & Cancel ##################### 

        Hotkey_Submit:
        Gui, %Hotkey_numGui%: Default
        Gui, ListView, Hotkey_Hotkey1
        LV_GetText(k, 1, 2)
        ;call IsHotkeyValid() to find out If this is a "real" hotkey
        ;If not, just destroy the Gui and Return
        If IsHotkeyValid(k) = -1
            {
                Gui, %Hotkey_numGui%:Destroy
                Return
            }
        IfNotInString, Options, +ReturnKeynames		;If we should Return symbols, get those
            {
                Gui, ListView, Hotkey_Hotkey2
                LV_GetText(ReturnValue, 1, 2)
            }
        Else
            ReturnValue = %k%	;we got keynames already
        Gui, %Hotkey_numGui%:Destroy
        
        ; make single word characters in hotkeys upper case
        ; simple version, only works if there are no multi word character strings 
        If (ReturnValue) {
            If (not RegExMatch(ReturnValue, "([\w]{2,})")) {
                StringUpper, ReturnValue, ReturnValue
            }
        }
        
        Return

        Hotkey_Cancel:
        Gui, %Hotkey_numGui%:Destroy
        Return
    }

    ;###################### Other funtions ######################

    ;this has to bee done in three different places, so it's a seperate funtion
    ;it checks which checkboxes are checked ... ugh ... and adds the symbols in the right places
    ;note that we can't have any of the symbols with Joystick buttons, and that " * " and "&"
    ;can't be present in the same hotkey
    AddPrefixSymbols(keys)
    {
        global Hotkey_JoystickButtons,Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_numGui

        Gui, %Hotkey_numGui%:Submit, NoHide

        ;joystick buttons can't have prefix keys, therefore uncheck all the checkboxes
        If keys in %Hotkey_JoystickButtons%	
            {
                GuiControl,, Hotkey_Tilde, 0
                GuiControl,, Hotkey_Wildcard, 0
                GuiControl,, Hotkey_UP, 0
            }
        Else
            {
        If Hotkey_Tilde = 1
            keys = ~%keys%
        If Hotkey_Wildcard = 1
            {
                ;the wildcard can't be present together with the ampersand
                If (InStr(KeysToSymbols(keys), "&") = 0)
                    keys = *%keys%
                Else
                    {
                    GuiControl,, Hotkey_Wildcard, 0
                    Tooltip, The * prefix is not allowed in hotkeys`nthat use the ampersand (&).
                    SetTimer, Hotkey_RemoveTooltip, 5000
                    }
            }
        If Hotkey_UP = 1
            keys = %keys%%a_space%UP
        }
        Return keys
    }

    ;________________________________________________________

    ;this funtion turns, say, "Control+Alt+Win+Space" into "^!#Space" etc.
    ;this is handy since when you use the "+ReturnKeynames" option, you can 
    ;convert to hotkey symbols later using this funtion
    KeysToSymbols(s)
    {
        global Hotkey_modList_left_right,Hotkey_modList_normal,Hotkey_LeftRightMods,Hotkey_numGui

        Gui, %Hotkey_numGui%:Submit, NoHide
        ;grab the correct modList
        If Hotkey_LeftRightMods = 1
            modList = %Hotkey_modList_left_right%
        Else
            modList = %Hotkey_modList_normal%

        ;If the keys don't contain a modifier, it has to be something
        ;like "a+b", so turn it into "a & b" and Return
        If s not contains %modList%,Win
                {
                            StringReplace, s, s, +, %a_space%&%a_space%
                            Return s
                }
        ;Else, replace the keynames with the appropriate symbols
        StringReplace, s, s, LControl+, <^
        StringReplace, s, s, RControl+, >^
        StringReplace, s, s, Control+, ^
        StringReplace, s, s, LAlt+, <!
        StringReplace, s, s, RAlt+, >!
        StringReplace, s, s, Alt+, !
        StringReplace, s, s, LShift+, <+
        StringReplace, s, s, RShift+, >+
        StringReplace, s, s, Shift+, +
        StringReplace, s, s, LWin+, <#
        StringReplace, s, s, RWin+, >#
        StringReplace, s, s, Win+, #
        Return s
    }

    ;__________________________________________________

    ;this function checks which keys are beeing held down using the correct modList 
    Keys()
    {
        global Hotkey_keyList,Hotkey_modList_left_right,Hotkey_modList_normal,Hotkey_LeftRightMods
                        ,Hotkey_JoystickButtons,Hotkey_OptionsGlobal,Hotkey_numGui

        Gui, %Hotkey_numGui%:Submit, NoHide

        ;grab the correct modList
        If Hotkey_LeftRightMods = 1
            modList = %Hotkey_modList_left_right%
        Else
            modList = %Hotkey_modList_normal%

        ;If we don't want modifiers, just make it blank
        IfInString, Hotkey_OptionsGlobal, -mods
            modList =

        ;check joystick buttons first, since we can have only one
        ;and no modifiers. If we find one, just Return it, nothing Else
        Loop, Parse, Hotkey_JoystickButtons, `,
            {
                If GetKeyState(a_loopfield, "P") = 1
                    Return a_loopfield
            }

        ;check for modifiers
        Loop, Parse, modList, `,
            {
                If GetKeyState(a_loopfield,"P") <> 1
                    continue
                mods = %mods%%a_loopfield%+
            }

        ;GetKeyState("Win") doesn't work, which is why both modLists include 
        ;both variants. So replace L/RWin with Win here If needed
        If Hotkey_LeftRightMods <> 1
            {
                StringReplace, mods, mods, LWin, Win
                StringReplace, mods, mods, RWin, Win
            }

        ;check If other keys are beeing held down
        Loop, Parse, Hotkey_keyList, |
            {
                If GetKeyState(a_loopfield,"P") <> 1
                    continue
                ;If ithe left mouse button is down, check If the user is clicking a control
                ;(and ignore it If that's the case)
                If a_loopfield = LButton
                    {
                        MouseGetPos,,,,ctrl
                        If (ctrl <> "" AND InStr(ctrl, "SysListView") = 0)
                            continue
                    }
                ;If we don't want the ampersand (either because specified in options, or
                ;because we're on Win95/98/ME, just Return the first key we find (plus mods)
                IfInString, OptionsGlobal, -&
                    {
                    keys = %mods%%a_loopfield%
                    Return keys
                    }
                ;If this is the second time we get to this point in the loop...
                ;we must already have a key -> the user is holding down two keys
                ;in this case, ignore any modifiers and just Return our two keys
                If keys <>
                    {
                    keys = %keys%+%a_loopfield%
                    Return keys
                    }		
                ;Else If keys is still blank, take this key
                keys = %a_loopfield%
            }

        ;If we get to this point, the user is holding down only one key (from the keyList)
        ;so we can add the modifiers, If we found some
        If mods <>
            keys = %mods%%keys%
        Return %keys%
    }

    ;_______________________________________________________________

    ;this funtion gets called everytime the user clicks one of the checkboxes
    ToggleOperator(p)
    {
        global Hotkey_Tilde,Hotkey_Wildcard,Hotkey_UP,Hotkey_JoystickButtons,Hotkey_numGui

        ;we need to turn on CaseSense because we could have, say, Up UP :)
        StringCaseSense On	
        AutoTrim Off		;because of the space between the keys and the UP symbol

        Gui, %Hotkey_numGui%:Submit, NoHide

        ;this is kinda confusing, but I'm not changing it now...
        ctrl = %p%

        ;"p" is a_guicontrol btw...
        If p = Hotkey_Tilde
            p = ~
        Else If p = Hotkey_Wildcard
            p = *
        Else If p = Hotkey_UP
            p = %a_space%UP

        Loop 2
            {
                Gui, ListView, Hotkey_Hotkey%a_index%
                LV_GetText(k%a_index%,1,2)
            }

        ;If it's a joytick button, we can't have any special operators
        If Hotkey_JoystickButtons <>
            {
                If k1 in %Hotkey_JoystickButtons%
                    {
                        GuiControl,, %ctrl%, 0
                        Tooltip, This operator is not supported`nfor joystick buttons.
                        SetTimer, Hotkey_RemoveTooltip, 5000
                        Return
                    }
            }

        ;If a_guicontrol is not checked (i.e. is was unchecked), 
        ;remove the prefix, edit the Listviews and Return
        If %ctrl% <> 1
            {
                StringReplace, k1, k1, %p%
                StringReplace, k2, k2, %p%
                Loop 2
                    {
                        Gui, ListView, Hotkey_Hotkey%a_index%
                        LV_Delete(1)
                        LV_Add("","", k%a_index%)
                    }
                Return
            }


        If p = ~
            {
                k1 = ~%k1%
                k2 = ~%k2%
            }
        Else If p = *
            {
                IfNotInString, k2, &			;we can't have both " * " and "&" 
                    {
                        k1 = *%k1%
                        k2 = *%k2%
                    }
                Else
                {
                    GuiControl,, Hotkey_Wildcard, 0
                    Tooltip, The * prefix is not allowed in hotkeys`nthat use the ampersand (&).
                    SetTimer, Hotkey_RemoveTooltip, 5000
                }
            }
        Else If p contains UP			
            {
                k1 = %k1%%p%
                k2 = %k2%%p%
            }		
        ;edit the ListViews
        Loop 2
            {
                Gui, ListView, Hotkey_Hotkey%a_index%
                LV_Delete(1)
                LV_Add("","", k%a_index%)
            }
    }

    ;_____________________________________________________

    ;this funtion checks If a) it's some kind of a sensible hotkey,
    ;i.e not Ctrl+Alt+, ~ UP, etc., and b) that it's a valid hotkey
    ;If it's not, the funtion Returns -1, Else it Returns 1
    IsHotkeyValid(k)
    {
        If k =
            Return -1
            
        ;If UP is checked we could have "Ctrl+Alt+ UP", so get rid of the UP
        StringReplace, k, k, %a_space%UP		
        ;If the right-most char is a "+" but we don't have "++" (e.g. "Ctrl+Alt++"),
        ;it's not a "real" hotkey - most likely the user clicked okay while 
        ;holding down some modifiers. We can't have that...
        If (InStr(k, "+","",0) = StrLen(k) AND InStr(k, "++") = 0)
            Return -1
            
        ;these are all valid hotkeys, but we don't really want these either
        If k in ,*,~, UP,*~,~*,* UP,~ UP,*~ UP
            Return -1

        ;turn it into a hotkey to check ErrorLevel. 
        ;convert to symbols before we do this

        k := KeysToSymbols(k)

        Hotkey, %k%, Return, UseErrorLevel
        If ErrorLevel <> 0
            {
                ;Joystick buttons cause an incorrect ErrorLevel on WinXP (see my post in Bug Reports)
                ;so ignore it
                If (A_OSType <> "WIN32_WINDOWS" AND ErrorLevel = 51 AND InStr(k, "Joy") <> 0)
                    {
                        Hotkey, %k%, Return, Off
                        Return 1
                    }
                Else		;notify user
                    {
                        ErrorMessage =
                            (LTrim
                            Sorry, this hotkey (%k%) is invalid.
                            To find out why, please look up Error #%ErrorLevel% under the "Hotkey" command in the AHK command list.
                            Also, please report this Error to the author of this script so that the bug can be fixed.
                            (Note: Press Ctrl+C to copy this message to the clipboard).
                            )
                        Gui, +OwnDialogs
                        Msgbox, 8208, Invalid Hotkey, %ErrorMessage%
                        Return -1
                    }
            }
        Else		
            Return 1
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -







/*** DynaRun - CreateScript - Run AHK in a pipe! 
*     These functions allow for dynamically created scripts to be run
*     Removes the need for creating temporary script files
*/
    CreateScript(script){
    static mScript
    StringReplace,script,script,`n,`r`n,A
    StringReplace,script,script,`r`r,`r,A
    If RegExMatch(script,"m)^[^:]+:[^:]+|[a-zA-Z0-9#_@]+\{}$"){
        If !(mScript){
        If (A_IsCompiled){
            lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
            If !(res := DllCall("FindResource", "ptr", lib, "str", ">AUTOHOTKEY SCRIPT<", "ptr", Type:=10, "ptr"))
            If !(res := DllCall("FindResource", "ptr", lib, "str", ">AHK WITH ICON<", "ptr", Type:=10, "ptr")){
                MsgBox Could not extract script!
                return
            }
            DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
            ,hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
            ,pData := DllCall("LockResource", "ptr", hresdata, "ptr")
            If (DataSize){
            mScript:=StrGet(pData,"UTF-8")
            StringReplace,mScript,mScript,`n,`r`n,A
            StringReplace,mScript,mScript,`r,`r`n,A
            StringReplace,mScript,mScript,`r`r,`r,A
            StringReplace,mScript,mScript,`n`n,`n,A
            mScript :="`r`n" mScript "`r`n"
            }
        } else {
            FileRead,mScript,%A_ScriptFullPath%
            StringReplace,mScript,mScript,`n,`r`n,A
            StringReplace,mScript,mScript,`r`r,`r,A
            mScript := "`r`n" mScript "`r`n"
            Loop,Parse,mScript,`n,`r
            {
            If A_Index=1
                mScript:=""
            If RegExMatch(A_LoopField,"i)^\s*#include"){
                temp:=RegExReplace(A_LoopField,"i)^\s*#include[\s+|,]")
                If InStr(temp,"%"){
                Loop,Parse,temp,`%
                {
                    If (A_Index=1)
                    temp:=A_LoopField
                    else if !Mod(A_Index,2)
                    _temp:=A_LoopField
                    else {
                    _temp:=%_temp%
                    temp.=_temp A_LoopField
                    _temp:=""
                    }
                }
                }
                If InStr(FileExist(trim(temp,"<>")),"D"){
        SetWorkingDir % trim(temp,"<>")
        continue
    } else if InStr(FileExist(temp),"D"){
        SetWorkingDir % temp
        continue
    } else If (SubStr(temp,1,1) . SubStr(temp,0) = "<>"){
                If !FileExist(_temp:=A_ScriptDir "\lib\" trim(temp,"<>") ".ahk")
                    If !FileExist(_temp:=A_MyDocuments "\AutoHotkey\lib\" trim(temp,"<>") ".ahk")
                    If !FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib\" trim(temp,"<>") ".ahk")
                        If FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib.lnk"){
                        FileGetShortcut,_temp,_temp
                        _temp:=_temp "\" trim(temp,"<>") ".ahk"
                        }
        FileRead,_temp,%_temp%
            mScript.= _temp "`r`n"
                } else {
        FileRead,_temp,%temp%
        mScript.= _temp "`r`n"
    }
            } else mScript.=A_LoopField "`r`n"
            }
        }
        }
        Loop,Parse,script,`n,`r
        {
        If A_Index=1
            script=
        else If A_LoopField=
            Continue
        If (RegExMatch(A_LoopField,"^[^:\s]+:[^:\s=]+$")){
            StringSplit,label,A_LoopField,:
            If (label0=2 and IsLabel(label1) and IsLabel(label2)){
            script .=SubStr(mScript
                , h:=InStr(mScript,"`r`n" label1 ":`r`n")
                , InStr(mScript,"`r`n" label2 ":`r`n")-h) . "`r`n"
            }
        } else if RegExMatch(A_LoopField,"^[^\{}\s]+\{}$"){
            StringTrimRight,label,A_LoopField,2
            script .= SubStr(mScript
            , h:=RegExMatch(mScript,"i)\n" label "\([^\)\n]*\)\n?\s*\{")
            , RegExMatch(mScript "`r`n","\n\s*}\s*\K\n",1,h)-h) . "`r`n"
        } else
            script .= A_LoopField "`r`n"
        }
    }
    StringReplace,script,script,`r`n,`n,All
    Return Script
    }

    DynaRun(script, name:="", args*) { ;// http://goo.gl/ECC6Qw
        if (name == "")
            name := "AHK_" . A_TickCount
        ;// Create named pipe(s), first one is a dummy
        for each, pipe in ["__PIPE_GA_", "__PIPE_"]
            %pipe% := DllCall(
            (Join Q C
                "CreateNamedPipe",          ;// http://goo.gl/3aJQg7
                "Str", "\\.\pipe\" . name,  ;// lpName
                "UInt", 2,                  ;// dwOpenMode = PIPE_ACCESS_OUTBOUND
                "UInt", 0,                  ;// dwPipeMode = PIPE_TYPE_BYTE
                "UInt", 255,                ;// nMaxInstances
                "UInt", 0,                  ;// nOutBufferSize
                "UInt", 0,                  ;// nInBufferSize
                "Ptr", 0,                   ;// nDefaultTimeOut
                "Ptr", 0                    ;// lpSecurityAttributes
            ))
        
        if (__PIPE_ == -1 || __PIPE_GA_ == -1)
            return false
        
        q := Chr(34) ;// for v1.1 and v2.0-a compatibility
        for each, arg in args
            args .= " " . q . arg . q
        Run "%A_AhkPath%" "\\.\pipe\%name%" %args%,, UseErrorLevel Hide, PID
        if ErrorLevel
            MsgBox, 262144, ERROR, Could not open file:`n%A_AhkPath%\\.\pipe\%name%
        
        DllCall("ConnectNamedPipe", "Ptr", __PIPE_GA_, "Ptr", 0) ;// http://goo.gl/pwTnxj
        DllCall("CloseHandle", "Ptr", __PIPE_GA_)
        DllCall("ConnectNamedPipe", "Ptr", __PIPE_, "Ptr", 0)
        
        script := (A_IsUnicode ? Chr(0xfeff) : (Chr(239) . Chr(187) . Chr(191))) . script
        if !DllCall(
        (Join Q C
            "WriteFile",                                ;// http://goo.gl/fdyWm0
            "Ptr", __PIPE_,                             ;// hFile
            "Str", script,                              ;// lpBuffer
            "UInt", (StrLen(script)+1)*(A_IsUnicode+1), ;// nNumberOfBytesToWrite
            "UInt*", 0,                                 ;// lpNumberOfBytesWritten
            "Ptr", 0                                    ;// lpOverlapped
        ))
            return A_LastError
        /* FileOpen() version
        if !(f := FileOpen(__PIPE_, "h", A_IsUnicode ? "UTF-8" : ""))
            return A_LastError
        f.Write(script), f.Close() ;// .Close() -> Redundant, no effect
        */
        DllCall("CloseHandle", "Ptr", __PIPE_)
        
        return PID
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -









; Tray Labels

    WINSPY:
        SplitPath, A_AhkPath, , AHKDIR
        Run, %AHKDIR%\WindowSpy.ahk
    Return

    RELOAD:
        Reload
    Return

    QuitNow:
        ExitApp
    Return
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -



/*** Monitor_GameLogs - CompareLocation - Use the Client Log file to determine where you are!
* Version:
*     v1.0.3 [updated 12/11/2019 (MM/DD/YYYY)]
*/
    ; Captures the current Location and determines if in Town, Hideout or Azurite Mines
    ; Use this for creating translations
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CompareLocation(cStr:="")
    {
        Static Lang := ""
        ;                                                       English / Thai                 French                 German                     Russian                       Spanish                Portuguese              Chinese          Korean
        Static ClientTowns :=  { "Lioneye's Watch" :        [ "Lioneye's Watch"       , "Le Guet d'Œil de Lion"  , "Löwenauges Wacht"      , "Застава Львиного глаза", "La Vigilancia de Lioneye", "Vigília de Lioneye"      , "獅眼守望"    , "라이온아이 초소에" ]
                                , "The Forest Encampment" : [ "The Forest Encampment" ,"Le Campement de la forêt", "Das Waldlager"         , "Лесной лагерь"         , "El Campamento Forestal"  , "Acampamento da Floresta" , "森林營地"    , "숲 야영지에" ]
                                , "The Sarn Encampment" :   [ "The Sarn Encampment"   , "Le Campement de Sarn"   , "Das Lager von Sarn"    , "Лагерь Сарна"          , "El Campamento de Sarn"   , "Acampamento de Sarn"     , "薩恩營地"    , "사안 야영지에" ]
                                , "Highgate" :              [ "Highgate"              , "Hautevoie"              , "Hohenpforte"           , "Македы"                , "Atalaya"                                             , "統治者之殿"  , "하이게이트에" ]
                                , "Overseer's Tower" :      [ "Overseer's Tower"      , "La Tour du Superviseur" , "Der Turm des Aufsehers", "Башня надзирателя"     , "La Torre del Capataz"    , "Torre do Capataz"        , "堅守高塔"    , "감시탑에" ]
                                , "The Bridge Encampment" : [ "The Bridge Encampment" , "Le Campement du pont"   , "Das Brückenlager"      , "Лагерь на мосту"       , "El Campamento del Puente", "Acampamento da Ponte"    , "橋墩營地"    , "다리 야영지에" ]
                                , "Oriath Docks" :          [ "Oriath Docks"          , "Les Docks d'Oriath"     , "Die Docks von Oriath"  , "Доки Ориата"           , "Las Dársenas de Oriath"  , "Docas de Oriath"         , "奧瑞亞港口"  , "오리아스 부두에" ]
                                , "Oriath" :                [ "Oriath"                                                                     , "Ориат"                                                                         , "奧瑞亞"      , "오리아스에" ] }
        Static LangString :=    { "English" : ": You have entered"  , "Spanish" : " : Has entrado a "   , "Chinese" : " : 你已進入："   , "Korean" : "진입했습니다"     , "German" : " : Ihr habt '"
                                , "Russian" : " : Вы вошли в область "  , "French" : " : Vous êtes à présent dans : "   , "Portuguese" : " : Você entrou em: "  , "Thai" : " : คุณเข้าสู่ " }
        If (cStr="Town")
            Return indexOfArr(CurrentLocation,ClientTowns)
        If (Lang = "")
        {
            For k, v in LangString
            {
                If InStr(cStr, v)
                {
                    Lang := k
                    If (VersionNumber > 0)
                    Log("Client.txt language has been detected as: " Lang)
                    Break
                }
            }
        }
        If (Lang = "English") ; This is the default setting
        {
            ; first we confirm if this line contains our zone change phrase
            If InStr(cStr, ": You have entered")
            {
                ; We split away the rest of the sentence for only location
                CurrentLocation := StrSplit(cStr, " : You have entered "," .`r`n" )[2]
                ; We should now have our location name and can begin comparing
                ; This compares the captured string to a list of town names
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                ; Now we check if it's a hideout, make sure to whitelist Syndicate
                If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
                    OnHideout := True
                Else
                    OnHideout := False
                ; Now we check if we match mines
                If (CurrentLocation = "Azurite Mine")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Spanish") 
        {
            If InStr(cStr, " : Has entrado a ")
            {
                CurrentLocation := StrSplit(cStr, " : Has entrado a "," .`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "Guarida") && !InStr(CurrentLocation, "Sindicato"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "Mina de Azurita")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Chinese") 
        {
            If InStr(cStr, " : 你已進入：")
            {
                CurrentLocation := StrSplit(cStr, " : 你已進入："," .。`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "藏身處") && !InStr(CurrentLocation, "永生密教"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "碧藍礦坑")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Korean") 
        {
            If InStr(cStr, "진입했습니다")
            {
                CurrentLocation := StrSplit(StrSplit(cStr,"] : ")[2], "진입했습니다"," .`r`n")[1]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "은신처에") && !InStr(CurrentLocation, "신디케이트"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "남동석 광산에")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "German") 
        {
            If InStr(cStr, " : Ihr habt '")
            {
                CurrentLocation := StrSplit(StrSplit(cStr," : Ihr habt '")[2], "' betreten"," .`r`n")[1]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "Versteckter") && !InStr(CurrentLocation, "Syndikat"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "Azuritmine")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Russian") 
        {
            If InStr(cStr, " : Вы вошли в область ")
            {
                CurrentLocation := StrSplit(cStr," : Вы вошли в область "," .`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "убежище") && !InStr(CurrentLocation, "синдикат"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "Азуритовая шахта")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "French") 
        {
            If InStr(cStr, " : Vous êtes à présent dans : ")
            {
                CurrentLocation := StrSplit(cStr," : Vous êtes à présent dans : "," .`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "Repaire") && !InStr(CurrentLocation, "Syndicat"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "La Mine d'Azurite")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Portuguese") 
        {
            If InStr(cStr, " : Você entrou em: ")
            {
                CurrentLocation := StrSplit(cStr," : Você entrou em: "," .`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "Refúgio") && !InStr(CurrentLocation, "Sindicato"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "Mina de Azurita")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Else If (Lang = "Thai") 
        {
            If InStr(cStr, " : คุณเข้าสู่ ")
            {
                CurrentLocation := StrSplit(cStr," : คุณเข้าสู่ "," .`r`n")[2]
                If indexOfArr(CurrentLocation,ClientTowns)
                    OnTown := True
                Else
                    OnTown := False
                If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
                    OnHideout := True
                Else
                    OnHideout := False
                If (CurrentLocation = "Azurite Mine")
                    OnMines := True
                Else
                    OnMines := False
                Return True
            }
        }
        Return False
    }

    ; Monitor for changes in log since initialized
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Monitor_GameLogs(Initialize:=0) 
    {
        global ClientLog, CLogFO, CurrentLocation
        OldTown := OnTown, OldHideout := OnHideout, OldMines := OnMines, OldLocation := CurrentLocation
        SetTimer,% A_ThisFunc, 500 ; auto set timer
        timeMon := CoolTime()
        if (Initialize)
        {
            Try
            {
                CLogFO := FileOpen(ClientLog, "r")
                FileGetSize, errchk, %ClientLog%, M
                If (errchk >= 128)
                {
                    CurrentLocation := "Log too large"
                    CLogFO.Seek(0, 2)
                }
                Else
                {
                    latestFileContent := CLogFo.Read()
                    latestFileContent := TF_ReverseLines(latestFileContent)
                    Loop, Parse,% latestFileContent,`n,`r
                    {
                        If CompareLocation(A_LoopField)
                            Break
                        If (A_Index > 1000)
                        {
                            CurrentLocation := "1k Line Break"
                            Log("1k Line Break reached, ensure the file is encoded with UTF-8-BOM")
                            Break
                        }
                    }
                    If CurrentLocation = ""
                        CurrentLocation := "Nothing Found"
                }
                timeMon := Round((CoolTime() - timeMon) * 1000,1)
                If (DebugMessages && YesLocation && WinActive(GameStr))
                {
                    Ding(6000,14,"OnTown   `t" OnTown)
                    Ding(6000,15,"OnHideout`t" OnHideout)
                    Ding(6000,16,"OnMines  `t" OnMines)
                    Ding(6000,17,CurrentLocation)
                    Ding(6000,19,"First Load`t" timeMon " MilliSeconds")
                }
                If (VersionNumber != "")
                Log("Log File initialized","OnTown " OnTown, "OnHideout " OnHideout, "OnMines " OnMines, "Located:" CurrentLocation)
            }
            Catch, loaderror
            {
                CurrentLocation := "Client File Load Error"
                Log("Error loading File, Submit information about your client.txt",loaderror)
            }
            Return
        } Else {
            latestFileContent := CLogFo.Read()

            if (latestFileContent) 
            {
                Loop, Parse,% latestFileContent,`n,`r 
                {
                    ClientLogText := A_LoopField
                    ; MsgBox, line %A_LoopField%
                    CompareLocation(ClientLogText)
                }
            }
            timeMon := Round((CoolTime() - timeMon) * 1000000,1)
            If (DebugMessages && YesLocation && WinActive(GameStr))
            {
                Ding(2000,14,"OnTown   `t" OnTown)
                Ding(2000,15,"OnHideout`t" OnHideout)
                Ding(2000,16,"OnMines  `t" OnMines)
                Ding(2000,17,CurrentLocation)
                Ding(2000,18,"MicroSeconds  " timeMon)
            }
            If YesLocation && (CurrentLocation != OldLocation || OldTown != OnTown || OldMines != OnMines || OldHideout != OnHideout)
                Log("Zone Change Detected","OnTown " OnTown, "OnHideout " OnHideout, "OnMines " OnMines, "Located:" CurrentLocation)
            Return
        }
    }

    ; AHK version of the Tail function
    LastLine(SomeFileObject) {
        static SEEK_CUR := 1
        static SEEK_END := 2
        loop {
            SomeFileObject.Seek(-1, SEEK_CUR)
            
            if (SomeFileObject.Read(1) = "`n") {
                StartPosition := SomeFileObject.Tell()
                
                Line := SomeFileObject.ReadLine()
                SomeFileObject.Seek(StartPosition - 1)
                return Line
            }
            else {
                SomeFileObject.Seek(-1, SEEK_CUR)
            }
        } until (A_Index >= 1000000)
        Return ; this should never happen
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -





;/*
;===========================================
;  FindText - Capture screen image into text and then find it
;  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  Author  :  FeiYue
;  Version :  7.2
;  Date    :  2019-12-16
 ;
 ;  Usage:
 ;  1. Capture the image to text string.
 ;  2. Test find the text string on full Screen.
 ;  3. When test is successful, you may copy the code
 ;     and paste it into your own script.
 ;     Note: Copy the "FindText()" function and the following
 ;     functions and paste it into your own script Just once.
 ;  4. The more recommended way is to save the script as
 ;     "FindText.ahk" and copy it to the "Lib" subdirectory
 ;     of AHK program, instead of copying the "FindText()"
 ;     function and the following functions, add a line to
 ;     the beginning of your script: #Include <FindText>
 ;
 ;  Note:
 ;     After upgrading to v7.0, the search scope using
 ;     the upper left  corner coordinates (X1, Y1)
 ;     and lower right corner coordinates (X2, Y2), similar to ImageSearch.
 ;     This makes it easier for novices to understand and use.
 ;
 ;===========================================
 ;  Introduction of function parameters:
 ;
 ;  returnArray := FindText(
 ;      X1 --> the search scope's upper left corner X coordinates
 ;    , Y1 --> the search scope's upper left corner Y coordinates
 ;    , X2 --> the search scope's lower right corner X coordinates
 ;    , Y2 --> the search scope's lower right corner Y coordinates
 ;    , err1 --> Fault tolerance percentage of text       (0.1=10%)
 ;    , err0 --> Fault tolerance percentage of background (0.1=10%)
 ;    , Text --> can be a lot of text parsed into images, separated by "|"
 ;    , ScreenShot --> if the value is 0, the last screenshot will be used
 ;    , FindAll --> if the value is 0, Just find one result and return
 ;    , JoinText --> if the value is 1, Join all Text for combination lookup
 ;    , offsetX --> Set the max text offset for combination lookup
 ;    , offsetY --> Set the max text offset for combination lookup
 ;  )
 ;
 ;  The function returns a second-order array containing
 ;  all lookup results, Any result is an associative array
 ;  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
 ;  if no image is found, the function returns 0.
 ;
 ;  If the return variable is set to "ok", ok.1 is the first result found.
 ;  Where ok.1.1 is the X coordinate of the upper left corner of the found image,
 ;  and ok.1.2 is the Y coordinate of the upper left corner of the found image,
 ;  ok.1.3 is the width of the found image, and ok.1.4 is the height of the found image,
 ;  ok.1.x <==> ok.1.1+ok.1.3//2 ( is the Center X coordinate of the found image ),
 ;  ok.1.y <==> ok.1.2+ok.1.4//2 ( is the Center Y coordinate of the found image ),
 ;  ok.1.id is the comment text, which is included in the <> of its parameter.
 ;  ok.1.x can also be written as ok[1].x, which supports variables. (eg: ok[A_Index].x)
 ;
 ;  All coordinates are relative to Screen, colors are in RGB format,
 ;  and combination lookup must use uniform color mode
 ;===========================================
 ;*/


ft_Gui(cmd)
{
  static
  if (cmd="Show")
  {
    Gui, ft_Main:+LastFoundExist
    IfWinExist
    {
      Gui, ft_Main:Show, Center
      return
    }
    if (!ft_FuncBind1)
      ft_FuncBind1:=Func("ft_Gui").Bind("Show")
    #NoEnv
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    {
        Menu, Tray, Tip, FindText GUI
    	Menu, Tray, NoStandard
        Menu, Tray, Add, FindText, %ft_FuncBind1%
        Menu, Tray, Default, FindText
        Menu, Tray, Click, 1
        Menu, Tray, Icon, Shell32.dll, 23
        Menu, Tray, Add
        Menu, Tray, add, Window Spy, WINSPY
        Menu, Tray, Add
        Menu, Tray, add, Reload This Script, RELOAD	
        Menu, Tray, add
        Menu, Tray, add, Exit, QuitNow ; added exit script option
    }
    ft_BatchLines:=A_BatchLines
    ft_IsCritical:=A_IsCritical
    Critical
    ww:=35, hh:=16, WindowColor:="0xDDEEFF"
    ft_Gui("MakeCaptureWindow")
    ft_Gui("MakeSubPicWindow")
    ft_Gui("MakeMainWindow")
    OnMessage(0x100, Func("ft_EditEvents1"))  ; WM_KEYDOWN
    OnMessage(0x201, Func("ft_EditEvents2"))  ; WM_LBUTTONDOWN
    OnMessage(0x200, Func("ft_ShowToolTip"))  ; WM_MOUSEMOVE
    Gui, ft_Main:Show, Center
    GuiControl, Focus, capture
    Critical, %ft_IsCritical%
    SetBatchLines, %ft_BatchLines%
    return
    ;-------------------
    ft_Run:
    Critical
    ft_Gui(Trim(A_GuiControl))
    return
  }
  if (cmd="MakeCaptureWindow")
  {
    Gui, ft_Capture:New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12, Verdana
    Gui, Add, Text, xm w855 h315 +HwndhPic
    Gui, Add, Slider, ym h315 vMySlider2 gft_Run
      +Center Page20 Line20 NoTicks AltSubmit +Vertical
    Gui, Add, Slider, xm w855 vMySlider1 gft_Run
      +Center Page20 Line20 NoTicks AltSubmit
    GuiControlGet, Pic, Pos, %hPic%
    PicW:=Round(PicW), PicH:=Round(PicH), MySlider1:=MySlider2:=0
    Gui, Add, Button, xm+125 w50 vRepU  gft_Run, -U
    Gui, Add, Button, x+0    wp  vCutU  gft_Run, U
    Gui, Add, Button, x+0    wp  vCutU3 gft_Run, U3
    ;--------------
    Gui, Add, Text,   x+50 yp+3 Section, Gray
    Gui, Add, Edit,   x+3 yp-3 w60 vSelGray ReadOnly
    Gui, Add, Text,   x+15 ys, Color
    Gui, Add, Edit,   x+3 yp-3 w120 vSelColor ReadOnly
    Gui, Add, Text,   x+15 ys, R
    Gui, Add, Edit,   x+3 yp-3 w60 vSelR ReadOnly
    Gui, Add, Text,   x+5 ys, G
    Gui, Add, Edit,   x+3 yp-3 w60 vSelG ReadOnly
    Gui, Add, Text,   x+5 ys, B
    Gui, Add, Edit,   x+3 yp-3 w60 vSelB ReadOnly
    ;--------------
    Gui, Add, Button, xm     w50 vRepL  gft_Run, -L
    Gui, Add, Button, x+0    wp  vCutL  gft_Run, L
    Gui, Add, Button, x+0    wp  vCutL3 gft_Run, L3
    Gui, Add, Button, x+15   w70 vAuto  gft_Run, Auto
    Gui, Add, Button, x+15   w50 vRepR  gft_Run, -R
    Gui, Add, Button, x+0    wp  vCutR  gft_Run, R
    Gui, Add, Button, x+0    wp  vCutR3 gft_Run Section, R3
    Gui, Add, Button, xm+125 w50 vRepD  gft_Run, -D
    Gui, Add, Button, x+0    wp  vCutD  gft_Run, D
    Gui, Add, Button, x+0    wp  vCutD3 gft_Run, D3
    ;--------------
    Gui, Add, Tab3,   ys-8 -Wrap, Gray|GrayDiff|Color|ColorPos|ColorDiff
    Gui, Tab, 1
    Gui, Add, Text,   x+15 y+15, Gray Threshold
    Gui, Add, Edit,   x+15 w100 vThreshold
    Gui, Add, Button, x+15 yp-3 vGray2Two gft_Run, Gray2Two
    Gui, Tab, 2
    Gui, Add, Text,   x+15 y+15, Gray Difference
    Gui, Add, Edit,   x+15 w100 vGrayDiff, 50
    Gui, Add, Button, x+15 yp-3 vGrayDiff2Two gft_Run, GrayDiff2Two
    Gui, Tab, 3
    Gui, Add, Text,   x+15 y+15, Similarity 0
    Gui, Add, Slider, x+0 w100 vSimilar1 gft_Run
      +Center Page1 NoTicks ToolTip, 100
    Gui, Add, Text,   x+0, 100
    Gui, Add, Button, x+15 yp-3 vColor2Two gft_Run, Color2Two
    Gui, Tab, 4
    Gui, Add, Text,   x+15 y+15, Similarity 0
    Gui, Add, Slider, x+0 w100 vSimilar2 gft_Run
      +Center Page1 NoTicks ToolTip, 100
    Gui, Add, Text,   x+0, 100
    Gui, Add, Button, x+15 yp-3 vColorPos2Two gft_Run, ColorPos2Two
    Gui, Tab, 5
    Gui, Add, Text,   x+10 y+15, R
    Gui, Add, Edit,   x+2 w70 vDiffR Limit3
    Gui, Add, UpDown, vdR Range0-255
    Gui, Add, Text,   x+5, G
    Gui, Add, Edit,   x+2 w70 vDiffG Limit3
    Gui, Add, UpDown, vdG Range0-255
    Gui, Add, Text,   x+5, B
    Gui, Add, Edit,   x+2 w70 vDiffB Limit3
    Gui, Add, UpDown, vdB Range0-255
    Gui, Add, Button, x+5 yp-3 vColorDiff2Two gft_Run, ColorDiff2Two
    Gui, Tab
    ;--------------
    Gui, Add, Button, xm vReset gft_Run, Reset
    Gui, Add, Checkbox, x+15 yp+5 vModify gft_Run, Modify
    Gui, Add, Text,   x+30, Comment
    Gui, Add, Edit,   x+5 yp-2 w150 vComment
    ; Gui, Add, Button, x+30 yp-3 vSplitAdd gft_Run, SplitAdd
    Gui, Add, Button, x+30 yp-3 vAllAdd gft_Run, AllAdd
    Gui, Add, Button, x+10 w80 vButtonOK gft_Run, OK
    Gui, Add, Button, x+10 wp vClose gCancel, Close
    Gui, Show, Hide, Capture Image To Text
    return
  }
  if (cmd="MakeSubPicWindow")
  {
    Gui, ft_SubPic:New
    Gui, +AlwaysOnTop -Caption +ToolWindow -DPIScale +Parent%hPic%
    Gui, Margin, 0, 0
    Gui, Color, %WindowColor%
    Gui, -Theme
    nW:=2*ww+1, nH:=2*hh+1, C_:=[], w:=11
    Loop, % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "x0 y0" : Mod(i,nW)=1 ? "x0 y+1" : "x+1"
      j.=i>nW*nH ? " cRed BackgroundFFFFAA" : ""
      Gui, Add, Progress, w%w% h%w% %j% +Hwndid -E0x20000
      C_[i]:=id
    }
    Gui, +Theme
    GuiControlGet, SubPic, Pos, %id%
    SubPicW:=Round(SubPicX+SubPicW), SubPicH:=Round(SubPicY+SubPicH)
    Gui, Show, NA x0 y0 w%SubPicW% h%SubPicH%, SubPic
    i:=(SubPicW>PicW), j:=(SubPicH>PicH)
    Gui, ft_Capture:Default
    GuiControl, Enable%i%, MySlider1
    GuiControl, Enable%j%, MySlider2
    GuiControl,, MySlider1, % MySlider1:=0
    GuiControl,, MySlider2, % MySlider2:=0
    return
  }
  if (cmd="MakeMainWindow")
  {
    Gui, ft_Main:New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12 norm, Verdana
    Gui, Add, Checkbox, xm y+15 r1 -Wrap vAddFunc Checked
      , Add FindText() to Script
    Gui, Add, Button, x+20 yp-5 w240 vTestClip gft_Run, Test Clipboard
    Gui, Add, Button, x+0 w240 vCopyString gft_Run, Copy String



    Gui, Font, s6 bold, Verdana
    Gui, Add, Edit, xm w720 r25 vMyPic -Wrap
    Gui, Font, s12 norm, Verdana
    Gui, Add, Button, w240 vCapture gft_Run, Capture
    Gui, Add, Button, x+0 wp vCaptureS gft_Run, Capture from ScreenShot
    Gui, Add, Button, x+0 wp vTest gft_Run, Test Script

    Gui, Font, cBlack, Verdana
    Gui, Add, GroupBox, x+170 xm y+4 W240 h52 Section, Adjust Capture Box
    Gui, Font, s12 norm, Verdana
    Gui, Add, Text, xs+10 yp+22 h25, % "Width: "
    Gui, Add, Text, x+0 yp w47, %ww%
    Gui, Add, UpDown, vWidth Range1-110, %ww%
    Gui, Add, Text, x+5 yp h25, % "Height: "
    Gui, Add, Text, x+0 yp w40, %hh%
    Gui, Add, UpDown, vHeight Range1-40, %hh%

    Gui, Font, s12 cBlack, Verdana
    Gui, Add, GroupBox, x+10 ys W240 h52 Section, ScreenShot Key
    Gui, Font, s12 norm, Verdana
    Gui, Add, ListView
    , vlvar_SetHotkey1 r1 -Hdr -LV0x20 r1 w230 xs+5 ys+20  cGreen BackgroundFFFACD gft_LV_DblClick, 1|2
    LV_ModifyCol(1, 0)
    LV_ModifyCol(2, 225)
    Gui, Add, Button, x+5 yp-5 w240 vCopy gft_Run , Copy Script


    Gui, Font, s12 cBlue, Verdana
    Gui, Add, Edit, xm w720 h350 vscr Hwndhscr -Wrap HScroll
    Gui, Show, Hide, Capture Image To Text And Find Text Tool
    return
  }
  if (cmd="Update")
  {
    Gui, ft_Main:Default
    GuiControlGet, Width
    GuiControlGet, Height
    If (Width * Height > 2200)
    {
        MsgBox, 262144, Error Building Capture Menu, The area is too large, will crash the GUI creation`nMax Area is 110 x 20
        Exit
    }
    Gui, Hide
    If (Width != ww || Height != hh)
    {
        ToolTip, Building new Capture Box
        ww:=Width, hh:=Height, ft_Gui("MakeSubPicWindow")
        ToolTip
    }
    return
  }
  if (cmd="Capture") or (cmd="CaptureS")
  {
    ft_Gui("Update")
    Gui, ft_Main:Default
    Gui, +LastFound
    WinMinimize
    Gui, Hide
    ShowScreenShot:=(cmd="CaptureS")
    if (ShowScreenShot)
      ft_ShowScreenShot(1)
    ;----------------------
    Gui, ft_Mini:New
    Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
    Gui, Color, Red
    d:=2, w:=nW+2*d, h:=nH+2*d, i:=w-d, j:=h-d
    Gui, Show, Hide w%w% h%h%
    s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
    s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
    WinSet, Region, %s%
    ;------------------------------
    Hotkey, $*RButton, ft_RButton_Off, On
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    CoordMode, Mouse
    KeyWait, RButton
    KeyWait, Ctrl
    oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ;---------------
      Gui, Show, % "NA x" (x-w//2) " y" (y-h//2)
      ToolTip, % "Mark the Position : " x "," y
        . "`nFirst: Press Ctrl, or RButton to mark area"
    }
    Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
    KeyWait, RButton
    KeyWait, Ctrl
    px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ;---------------
      ToolTip, % "The Capture Position : " px "," py
        . "`nSecond: Press Ctrl, or RButton to capture"
    }
    Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P") 
    KeyWait, RButton
    KeyWait, Ctrl
    ToolTip
    ListLines, %lls%
    Gui, Destroy
    WinWaitClose,,, 10
    cors:=ft_getc(px,py,ww,hh,!ShowScreenShot)
    Hotkey, $*RButton, ft_RButton_Off, Off
    if (ShowScreenShot)
      ft_ShowScreenShot(0)
    ;--------------------------------
    Gui, ft_Capture:Default
    k:=nW*nH+1
    Loop, % nW
      GuiControl,, % C_[k++], 0
    Loop, 6
      GuiControl,, Edit%A_Index%
    GuiControl,, Modify, % Modify:=0
    GuiControl,, GrayDiff, 50
    GuiControl, Focus, Gray2Two
    GuiControl, +Default, Gray2Two
    ft_Gui("Reset")
    Gui, Show, Center
    Event:=Result:=""
    DetectHiddenWindows, Off
    Gui, +LastFound
    Critical, Off
    WinWaitClose, % "ahk_id " WinExist()
    Gui, ft_Main:Default
    ;--------------------------------
    if (Event="ButtonOK")
    {
      if (!A_IsCompiled)
      {
        FileRead, s, %A_LineFile%
        s:=SubStr(s, s~="i)\n[;=]+ Copy The")
      }
      else s:=""
      GuiControl,, scr, % Result "`n" s
      GuiControl,, MyPic, % Trim(ASCII(Result),"`n")
      Result:=s:=""
    }
    else if (Event="SplitAdd") or (Event="AllAdd")
    {
      GuiControlGet, s,, scr
      i:=j:=0, r:="\|<[^>\n]*>[^$\n]+\$\d+\.[\w+/]+"
      While j:=RegExMatch(s,r,"",j+1)
        i:=InStr(s,"`n",0,j)
      GuiControl,, scr, % SubStr(s,1,i-1) . "`n" . Result . SubStr(s,i+1)
      GuiControl,, MyPic, % Trim(ASCII(Result),"`n")
      Result:=s:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    ft_RButton_Off:
    return
  }
  if (cmd="Test") or (cmd="TestClip")
  {
    Critical, Off
    Gui, ft_Main:Default
    Gui, +LastFound
    WinMinimize
    Gui, Hide
    DetectHiddenWindows, Off
    WinWaitClose, % "ahk_id " WinExist()
    Sleep, 100
    ;----------------------
    if (cmd="Test")
      GuiControlGet, s,, scr
    if (!A_IsCompiled) and InStr(s,"MCode(") and (cmd="Test")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n"
        . "Gui, ft_ok_:Show, Hide, ft_ok_`n"
        . s "`nExitApp`n"
      ft_Exec(s)
      DetectHiddenWindows, On
      WinWait, ft_ok_ ahk_class AutoHotkeyGUI,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
    }
    else
    {
      Gui, +OwnDialogs
      t:=CoolTime(), n:=150000
      if (cmd="TestClip")
        v := Clipboard
      Else
        RegExMatch(s,"\|<[^>\n]*>[^$\n]+\$\d+\.[\w+/]+",v)
      ok:=FindText(-n, -n, n, n, 0, 0, v)
      , X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
      MsgBox, 4096,Test Results, % "Found :`t" Round(ok.MaxIndex()) "`n`n"
        . "Time  :`t" Round((CoolTime()-t)*1000) " ms`n`n"
        . "Pos   :`t"  X ", " Y "`n`n"
        . "Result:`t" (ok ? "Success ! " Comment : "Failed !"), 3
      for i,v in ok
        if (i<=5)
          MouseTip(ok[i].x, ok[i].y)
      ok:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  }
  if (cmd="Copy") or (cmd="CopyString")
  {
    Gui, ft_Main:Default
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      GuiControlGet, s,, scr
      GuiControlGet, r,, AddFunc
      if (r != 1)
        s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
    }
    If (cmd="Copy")
        Clipboard:=RegExReplace(s,"\R","`r`n")
    Else if (cmd="CopyString")
        Clipboard:= """" copyString """"

    ;----------------------
    ; if !(!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    ; {
    ;     Gui, Hide
    ;     Gui, 1: Default
    ;     Hotkeys()
    ; }
    return
  }
  if (cmd="MySlider1") or (cmd="MySlider2")
  {
    x:=SubPicW>PicW ? -(SubPicW-PicW)*MySlider1//100 : 0
    y:=SubPicH>PicH ? -(SubPicH-PicH)*MySlider2//100 : 0
    Gui, ft_SubPic:Show, NA x%x% y%y%
    return
  }
  if (cmd="Reset")
  {
    if !IsObject(ascii)
      ascii:=[], gray:=[], show:=[]
    CutLeft:=CutRight:=CutUp:=CutDown:=k:=0, bg:=""
    Loop, % nW*nH
    {
      show[++k]:=1, c:=cors[k]
      gray[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
      ft_Gui("SetColor")
    }
    Loop, % cors.CutLeft
      ft_Gui("CutL")
    Loop, % cors.CutRight
      ft_Gui("CutR")
    Loop, % cors.CutUp
      ft_Gui("CutU")
    Loop, % cors.CutDown
      ft_Gui("CutD")
    return
  }
  if (cmd="SetColor")
  {
    c:=c="Black" ? 0x000000 : c="White" ? 0xFFFFFF
      : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
    SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
    return
  }
  if (cmd="RepColor")
  {
    show[k]:=1, c:=(bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), ft_Gui("SetColor")
    return
  }
  if (cmd="CutColor")
  {
    show[k]:=0, c:=WindowColor, ft_Gui("SetColor")
    return
  }
  if (cmd="RepL")
  {
    if (CutLeft<=cors.CutLeft)
    or (bg!="" and InStr(color,"**")
    and CutLeft=cors.CutLeft+1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? ft_Gui("RepColor") : "")
    return
  }
  if (cmd="CutL")
  {
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? ft_Gui("CutColor") : "")
    return
  }
  if (cmd="CutL3")
  {
    Loop, 3
      ft_Gui("CutL")
    return
  }
  if (cmd="RepR")
  {
    if (CutRight<=cors.CutRight)
    or (bg!="" and InStr(color,"**")
    and CutRight=cors.CutRight+1)
      return
    k:=1-CutRight, CutRight--
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? ft_Gui("RepColor") : "")
    return
  }
  if (cmd="CutR")
  {
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? ft_Gui("CutColor") : "")
    return
  }
  if (cmd="CutR3")
  {
    Loop, 3
      ft_Gui("CutR")
    return
  }
  if (cmd="RepU")
  {
    if (CutUp<=cors.CutUp)
    or (bg!="" and InStr(color,"**")
    and CutUp=cors.CutUp+1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? ft_Gui("RepColor") : "")
    return
  }
  if (cmd="CutU")
  {
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? ft_Gui("CutColor") : "")
    return
  }
  if (cmd="CutU3")
  {
    Loop, 3
      ft_Gui("CutU")
    return
  }
  if (cmd="RepD")
  {
    if (CutDown<=cors.CutDown)
    or (bg!="" and InStr(color,"**")
    and CutDown=cors.CutDown+1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? ft_Gui("RepColor") : "")
    return
  }
  if (cmd="CutD")
  {
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? ft_Gui("CutColor") : "")
    return
  }
  if (cmd="CutD3")
  {
    Loop, 3
      ft_Gui("CutD")
    return
  }
  if (cmd="Gray2Two")
  {
    Gui, ft_Capture:Default
    GuiControl, Focus, Threshold
    GuiControlGet, Threshold
    if (Threshold="")
    {
      pp:=[]
      Loop, 256
        pp[A_Index-1]:=0
      Loop, % nW*nH
        if (show[A_Index])
          pp[gray[A_Index]]++
      IP:=IS:=0
      Loop, 256
        k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
      Threshold:=Floor(IP/IS)
      Loop, 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop, % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP-IP1, IS2:=IS-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      GuiControl,, Threshold, %Threshold%
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop, % nW*nH
    {
      ascii[++k]:=v:=(gray[k]<=Threshold)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  }
  if (cmd="GrayDiff2Two")
  {
    Gui, ft_Capture:Default
    GuiControlGet, GrayDiff
    if (GrayDiff="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, `n  Please Set Gray Difference First !  `n, 1
      return
    }
    if (CutLeft=cors.CutLeft)
      ft_Gui("CutL")
    if (CutRight=cors.CutRight)
      ft_Gui("CutR")
    if (CutUp=cors.CutUp)
      ft_Gui("CutU")
    if (CutDown=cors.CutDown)
      ft_Gui("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop, % nW*nH
    {
      j:=gray[++k]+GrayDiff
      , ascii[k]:=v:=( gray[k-1]>j or gray[k+1]>j
      or gray[k-nW]>j or gray[k+nW]>j
      or gray[k-nW-1]>j or gray[k-nW+1]>j
      or gray[k+nW-1]>j or gray[k+nW+1]>j )
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  }
  if (cmd="Color2Two") or (cmd="ColorPos2Two")
  {
    Gui, ft_Capture:Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, `n  Please Select a Color First !  `n, 1
      return
    }
    UsePos:=(cmd="ColorPos2Two") ? 1:0
    GuiControlGet, n,, Similar1
    n:=Round(n/100,2), color:=c "@" n
    , n:=Floor(9*255*255*(1-n)*(1-n)), k:=i:=0
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    Loop, % nW*nH
    {
      c:=cors[++k], r:=((c>>16)&0xFF)-rr
      , g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
      , ascii[k]:=v:=(3*r*r+4*g*g+2*b*b<=n)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  }
  if (cmd="ColorDiff2Two")
  {
    Gui, ft_Capture:Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, `n  Please Select a Color First !  `n, 1
      return
    }
    GuiControlGet, dR
    GuiControlGet, dG
    GuiControlGet, dB
    rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
    , color:=StrReplace(c "-" n,"0x"), k:=i:=0
    Loop, % nW*nH
    {
      c:=cors[++k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF
      , b:=c&0xFF, ascii[k]:=v:=(Abs(r-rr)<=dR
      and Abs(g-gg)<=dG and Abs(b-bb)<=dB)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), ft_Gui("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  }
  if (cmd="Modify")
  {
    GuiControlGet, Modify, ft_Capture:, Modify
    return
  }
  if (cmd="Similar1")
  {
    GuiControl, ft_Capture:, Similar2, %Similar1%
    return
  }
  if (cmd="Similar2")
  {
    GuiControl, ft_Capture:, Similar1, %Similar2%
    return
  }
  if (cmd="getwz")
  {
    wz:=""
    if (bg="")
      return
    k:=0
    Loop, %nH%
    {
      v:=""
      Loop, %nW%
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      wz.=v="" ? "" : v "`n"
    }
    return
  }
  if (cmd="Auto")
  {
    ft_Gui("getwz")
    if (wz="")
    {
      Gui, ft_Capture:+OwnDialogs
      MsgBox, 4096, Tip, `nPlease Click Color2Two or Gray2Two First !, 1
      return
    }
    While InStr(wz,bg)
    {
      if (wz~="^" bg "+\n")
        wz:=RegExReplace(wz,"^" bg "+\n"), ft_Gui("CutU")
      else if !(wz~="m`n)[^\n" bg "]$")
        wz:=RegExReplace(wz,"m`n)" bg "$"), ft_Gui("CutR")
      else if (wz~="\n" bg "+\n$")
        wz:=RegExReplace(wz,"\n\K" bg "+\n$"), ft_Gui("CutD")
      else if !(wz~="m`n)^[^\n" bg "]")
        wz:=RegExReplace(wz,"m`n)^" bg), ft_Gui("CutL")
      else Break
    }
    wz:=""
    return
  }
  if (cmd="ButtonOK") or (cmd="SplitAdd") or (cmd="AllAdd")
  {
    Gui, ft_Capture:Default
    Gui, +OwnDialogs
    ft_Gui("getwz")
    if (wz="")
    {
      MsgBox, 4096, Tip, `nPlease Click Color2Two or Gray2Two First !, 1
      return
    }
    if InStr(color,"@") and (UsePos)
    {
      StringSplit, r, color, @
      k:=i:=j:=0
      Loop, % nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=cors.SelPos)
        {
          j:=i
          Break
        }
      }
      if (j=0)
      {
        MsgBox, 4096, Tip, Please select the core color again !, 3
        return
      }
      color:="#" (j-1) "@" r2
    }
    GuiControlGet, Comment
    if (cmd="SplitAdd")
    {
      if InStr(color,"#")
      {
        MsgBox, 4096, Tip
          , % "Can't be used in ColorPos mode, "
          . "because it can cause position errors", 3
        return
      }
      SetFormat, IntegerFast, d
      bg:=StrLen(StrReplace(wz,"0"))
        > StrLen(StrReplace(wz,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop, % w:=nW-CutLeft-CutRight
      {
        i++
        GuiControlGet, j,, % C_[k++]
        if (j=0 and A_Index<w)
          Continue
        v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
        wz:=RegExReplace(wz,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}",InStr(v,"`n")-1) "." bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          copyString.="|<" SubStr(Comment,1,1) ">" color "$" v
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    wz:=Format("{:d}",InStr(wz,"`n")-1) "." bit2base64(wz)
    s:="`nText.=""|<" Comment ">" color "$" wz """`n"
    if (cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      copyString.="|<" Comment ">" color "$" wz
      Gui, Hide
      return
    }
    x:=(bx:=(px-ww+CutLeft))+(bw:=(nW-CutLeft-CutRight))//2
    y:=(by:=(py-hh+CutUp))+(bh:=(nH-CutUp-CutDown))//2
    bx2:=bx+bw, by2:=by+bh
    s:=StrReplace(s, "Text.=", "Text:=")
    If !MonN
    ft_Gui("Edges")
    ldif := Abs(EdgeL - bx), tdif := Abs(EdgeT - by)
    rdif := Abs(EdgeR - bx2), bdif := Abs(EdgeB - by2)
    s=
    (
t1:=A_TickCount
%s%
`;X1,Y1,X2,Y2 are adjusted to screen edges
if (ok:=FindText(%bx%-%ldif%, %by%-%tdif%, %bx2%+%rdif%, %by2%+%bdif%, 0, 0, Text))
{
  CoordMode, Mouse
  X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
  ; Click, `%X`%, `%Y`%
}

MsgBox, 4096,Test Results, `% "Found :``t" Round(ok.MaxIndex()) "``n``n"
  . "Time  :``t" (A_TickCount-t1) " ms``n``n"
  . "Pos   :``t" X ", " Y "``n``n"
  . "Result:``t" (ok ? "Success ! " Comment : "Failed !")

for i,v in ok
  if (i<=5)
    MouseTip(ok[i].x, ok[i].y)

)
    Event:=cmd, Result:=s, copyString:="|<" Comment ">" color "$" wz
    Gui, Hide
    return
  }
  if (cmd="ShowPic")
  {
    Critical
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    GuiControl, ft_Main:, MyPic, % Trim(ASCII(s),"`n")
    return
  }
  if (cmd="WM_LBUTTONDOWN")
  {
    Critical
    MouseGetPos,,,, j
    IfNotInString, j, progress
      return
    MouseGetPos,,,, j, 2
    Gui, ft_Capture:Default
    For k,v in C_
    {
      if (v!=j)
        Continue
      if (k>nW*nH)
      {
        GuiControlGet, i,, %v%
        GuiControl,, %v%, % i ? 0:100
      }
      else if (Modify and bg!="" and show[k])
      {
        ascii[k]:=!ascii[k]
        , c:=(ascii[k] ? "Black":"White")
        , ft_Gui("SetColor")
      }
      else
      {
        c:=cors[k], cors.SelPos:=k
        r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
        GuiControl,, SelGray, % gray[k]
        GuiControl,, SelColor, %c%
        GuiControl,, SelR, %r%
        GuiControl,, SelG, %g%
        GuiControl,, SelB, %b%
      }
      Break
    }
    return
  }
  if (cmd="Apply")
  {
    if (!ft_FuncBind2)
      ft_FuncBind2:=Func("ft_Gui").Bind("ScreenShot")
    Gui, ft_Main:Default
    GuiControlGet, NowHotkey
    Gui, ListView, lvar_SetHotkey1
    LV_GetText(SetHotkey1, 1, 2)
    Hotkey, IfWinActive
    if (NowHotkey!="")
      Hotkey, *%NowHotkey%,, Off UseErrorLevel
    GuiControl,, NowHotkey, %SetHotkey1%
    if (SetHotkey1!="")
      Hotkey, *%SetHotkey1%, %ft_FuncBind2%, On UseErrorLevel
    return

    ;Label for assigning hotkeys
    ft_LV_DblClick:
        If a_guicontrolevent != DoubleClick
            return
        Gui, ft_Main:Default
        ; varstr := StrSplit(Trim(A_GuiControl),"lvar_")[2]
        if (!ft_FuncBind2)
            ft_FuncBind2:=Func("ft_Gui").Bind("ScreenShot")
        Gui, ListView, %a_guicontrol%
        LV_GetText(old, 1, 2)
        Hotkey, IfWinActive
        if (old!="")
            Hotkey, %old%,, Off UseErrorLevel
        LV_Delete(1)
        LV_Add("","",newHK:=Hotkey("+Default1 -LR -Symbols +Tooltips","Hold down your key combination","            Submit to bind    Cancel to clear","Select Screenshot Hotkey"))
        ; %varstr% := newHK
        Hotkey, IfWinActive
        if (newHK!="")
            Hotkey, %newHK%, %ft_FuncBind2%, On UseErrorLevel
    return
  }
  if (cmd="ScreenShot")
  {
    Critical
    ScreenShot()
    Gui, ft_Tip:New
    ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
    Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000020
    Gui, Color, Yellow
    Gui, Font, cRed s48 bold
    Gui, Add, Text,, Success
    WinSet, Transparent, 200
    Gui, Show, NA y0, ScreenShot Tip
    Sleep, 1000
    Gui, Destroy
    return
  }
  If (cmd="Edges")
  {
    EdgeL:=EdgeT:=EdgeR:=EdgeB:=0
    SysGet, MonN, 80
    loop, %MonN%
    {
      SysGet, Mon%A_Index%, Monitor, %A_Index%
      EdgeL := (Mon%A_Index%Left < EdgeL ? Mon%A_Index%Left : EdgeL ), EdgeR := (Mon%A_Index%Right > EdgeR ? Mon%A_Index%Right : EdgeR )
      EdgeT := (Mon%A_Index%Top < EdgeT ? Mon%A_Index%Top : EdgeT ), EdgeB := (Mon%A_Index%Bottom > EdgeB ? Mon%A_Index%Bottom : EdgeB )
    }
    Return
  }

  ft_MainGuiClose:
  ft_MainGuiEscape:
  ExitApp
}

    ft_Load_ToolTip_Text()
    {
        s=
        (LTrim
        Update = Update the capture range by adjusting the numbers
        AddFunc = Additional FindText() in Copy
        lvar_SetHotkey1 = Currently assigned screenshot hotkey`rDouble click to assign new key
        Apply = Clear old screenshot hotkey and apply a new hotkey`rHotkey assigned by priority from First to Second
        TestClip = Test the Text data in the clipboard for searching images
        Capture = Initiate Image Capture Sequence`rWill rebuild capture box if adjusted
        CaptureS = Restore the last screenshot and then start capturing`rWill rebuild capture box if adjusted
        Test = Test Results of Code
        Copy = Copy Script Code to Clipboard`rUse this to make your own scripts
        CopyString = Copy String Code to Clipboard`rUse this for Wingman Strings
        Width = Change the width value to scale the capture box`rWidth ends up being 1 + Width * 2
        Height = Change the height value to scale the capture box`rHeight ends up being 1 + Height * 2
        --------------------
        Reset = Reset to Original Captured Image
        SplitAdd = Using Markup Segmentation to Generate Text Library
        AllAdd = Append Another FindText Search Text into Previously Generated Code
        ButtonOK = Create New FindText Code for Testing
        Close = Close the Window Don't Do Anything
        Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
        GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
        Color2Two = Converts Image Pixels from Color Similar to Black or White
        ColorPos2Two = Converts Image Pixels from Color Position to Black or White
        ColorDiff2Two = Converts Image Pixels from Color Difference to Black or White
        SelGray = Gray value of the selected color
        SelColor = The selected color
        SelR = Red component of the selected color
        SelG = Green component of the selected color
        SelB = Blue component of the selected color
        RepU = Undo Cut the Upper Edge by 1
        CutU = Cut the Upper Edge by 1
        CutU3 = Cut the Upper Edge by 3
        RepL = Undo Cut the Left Edge by 1
        CutL = Cut the Left Edge by 1
        CutL3 = Cut the Left Edge by 3
        Auto = Automatic Cutting Edge
        RepR = Undo Cut the Right Edge by 1
        CutR = Cut the Right Edge by 1
        CutR3 = Cut the Right Edge by 3
        RepD = Undo Cut the Lower Edge by 1
        CutD = Cut the Lower Edge by 1
        CutD3 = Cut the Lower Edge by 3
        Modify = Allows Modify the Black and White Image
        Comment = Optional Comment used to Label Code ( Within <> )
        Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
        GrayDiff = Gray Difference which Determines Black or White Pixel Conversion (0-255)
        Similar1 = Adjust color similarity as Equivalent to The Selected Color
        Similar2 = Adjust color similarity as Equivalent to The Selected Color
        DiffR = Red Difference which Determines Black or White Pixel Conversion (0-255)
        DiffG = Green Difference which Determines Black or White Pixel Conversion (0-255)
        DiffB = Blue Difference which Determines Black or White Pixel Conversion (0-255)
        )
        return, s
    }

    ft_EditEvents1()
    {
        static ft_FuncBind3:=Func("ft_Gui").Bind("ShowPic")
        ListLines, Off
        if (A_Gui="ft_Main" && A_GuiControl="scr")
            SetTimer, %ft_FuncBind3%, -150
    }

    ft_EditEvents2()
    {
        ListLines, Off
        if (A_Gui="ft_SubPic")
            ft_Gui("WM_LBUTTONDOWN")
        else
            ft_EditEvents1()
    }

    ft_ShowToolTip(cmd:="")
    {
        static
        ListLines, Off
        if (!ToolTip_Text)
            ToolTip_Text:=ft_Load_ToolTip_Text()
        if (!ft_FuncBind4)
            ft_FuncBind4:=Func("ft_ShowToolTip").Bind("ToolTip")
        if (!ft_FuncBind5)
            ft_FuncBind5:=Func("ft_ShowToolTip").Bind("ToolTipOff")
        if (cmd="ToolTip")
        {
            MouseGetPos,,, _TT
            WinGetClass, _TT, ahk_id %_TT%
            if (_TT = "AutoHotkeyGUI")
            ToolTip, % RegExMatch(ToolTip_Text
            , "im`n)^" CurrControl "\K\s*=.*", _TT)
            ? StrReplace(Trim(_TT,"`t ="),"\n","`n") : ""
            return
        }
        if (cmd="ToolTipOff")
        {
            ToolTip
            return
        }
        CurrControl:=A_GuiControl
        if (CurrControl!=PrevControl)
        {
            PrevControl:=CurrControl, _TT:=(CurrControl!="")
            SetTimer, %ft_FuncBind4%, % _TT ? -500  : "Off"
            SetTimer, %ft_FuncBind5%, % _TT ? -5500 : "Off"
            ToolTip
        }
    }

    ft_getc(px, py, ww, hh, ScreenShot:=1)
    {
  		xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
        if (w<1 or h<1)
            return
        bch:=A_BatchLines
        SetBatchLines, -1
        if (ScreenShot)
            ScreenShot()
        cors:=[], k:=0
        lls:=A_ListLines=0 ? "Off" : "On"
        ListLines, Off
        Loop, % 2*hh+1
        {
    		j:=py-hh+A_Index-1
            Loop, % 2*ww+1
      		i:=px-ww+A_Index-1, cors[++k]:=ScreenShot_GetColor(i,j)
        }
        ListLines, %lls%
        cors.CutLeft:=Abs(px-ww-x)
        cors.CutRight:=Abs(px+ww-(x+w-1))
        cors.CutUp:=Abs(py-hh-y)
        cors.CutDown:=Abs(py+hh-(y+h-1))
        SetBatchLines, %bch%
        return, cors
    }

    ft_ShowScreenShot(Show:=1) {
        local  ; Unaffected by Super-global variables
        static hBM, Ptr:=A_PtrSize ? "UPtr" : "UInt"
        Gui, ft_ScreenShot:Destroy
        if (hBM)
            DllCall("DeleteObject",Ptr,hBM), hBM:=""
  		bits:=GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
  		if (!Show or !bits.1 or zw<1 or zh<1)
            return
        ;---------------------
        VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
        NumPut(zw, bi, 4, "int"), NumPut(-zh, bi, 8, "int")
        NumPut(1, bi, 12, "short"), NumPut(bpp:=32, bi, 14, "short")
        if (hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
  		, "int",0, Ptr "*",ppvBits, Ptr,0, "int",0, Ptr))
            DllCall("RtlMoveMemory",Ptr,ppvBits,Ptr,bits.1,Ptr,bits.2*zh)
        ;-------------------------
        win:=DllCall("GetDesktopWindow", Ptr)
        hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
        mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
        oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
        hBrush:=DllCall("CreateSolidBrush", "uint",0xFFFFFF, Ptr)
        oBrush:=DllCall("SelectObject", Ptr,mDC, Ptr,hBrush, Ptr)
        DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",zw, "int",zh
            , Ptr,mDC, "int",0, "int",0, "uint",0xC000CA)
        DllCall("SelectObject", Ptr,mDC, Ptr,oBrush)
        DllCall("DeleteObject", Ptr,hBrush)
        DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
        DllCall("DeleteDC", Ptr,mDC)
        DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
        ;-------------------------
        Gui, ft_ScreenShot:+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
        Gui, ft_ScreenShot:Margin, 0, 0
        Gui, ft_ScreenShot:Add, Picture, x0 y0 w%zw% h%zh% +HwndhPic +0xE
        SendMessage, 0x172, 0, hBM,, ahk_id %hPic%
        Gui, ft_ScreenShot:Show, NA x%zx% y%zy% w%zw% h%zh%, Show ScreenShot
    }

    ft_Exec(s)
    {
        Ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
        s:=RegExReplace(s, "\R", "`r`n")
        Try
        {
            shell:=ComObjCreate("WScript.Shell")
            oExec:=shell.Exec(Ahk " /f /ErrorStdOut *")
            oExec.StdIn.Write(s)
            oExec.StdIn.Close()
        }
        catch
        {
            f:=A_Temp "\~test1.tmp"
            s:="`r`n FileDelete, " f "`r`n" s
            FileDelete, %f%
            FileAppend, %s%, %f%
            Run, %Ahk% /f "%f%",, UseErrorLevel
        }
    }


;===== Copy The Following Functions To Your Own Code Just once =====
;=============== FindText Library Start ===================

    ;--------------------------------
    ; FindText - Capture screen image into text and then find it
    ;--------------------------------
    ; X1, Y1 --> the search scope's upper left corner coordinates
    ; X2, Y2 --> the search scope's lower right corner coordinates
    ; err1, err0 --> Fault tolerance percentage of text and background (0.1=10%)
    ; Text --> can be a lot of text parsed into images, separated by "|"
    ; ScreenShot --> if the value is 0, the last screenshot will be used
    ; FindAll --> if the value is 0, Just find one result and return
    ; JoinText --> if the value is 1, Join all Text for combination lookup
    ; offsetX, offsetY --> Set the Max text offset for combination lookup
    ; ruturn --> the function returns a second-order array
    ; containing all lookup results, Any result is an associative array
    ; {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment},
    ; if no image is found, the function returns 0.
	; All coordinates are relative to Screen, colors are in RGB format,
	; and combination lookup must use uniform color mode
	;--------------------------------

    FindText( x1, y1, x2, y2, err1, err0, text, ScreenShot:=1
    , FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10 )
    {
        local  ; Unaffected by Super-global variables
        bch:=A_BatchLines
        SetBatchLines, -1
        x:=(x1<x2 ? x1:x2), y:=(y1<y2 ? y1:y2)
        , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
        , xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
        if (w<1 or h<1)
        {
            SetBatchLines, %bch%
            return, 0
        }
        bits:=GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
        sx:=x-zx, sy:=y-zy, sw:=w, sh:=h, arr:=[], info:=[]
        Loop, Parse, text, |
          if IsObject(j:=PicInfo(A_LoopField))
            info.Push(j)
        if (!(num:=info.MaxIndex()) or !bits.1)
        {
            SetBatchLines, %bch%
            return, 0
        }
        VarSetCapacity(input, num*7*4), k:=0
        Loop, % num
            k+=Round(info[A_Index].2 * info[A_Index].3)
        VarSetCapacity(s1, k*4), VarSetCapacity(s0, k*4)
        , VarSetCapacity(gs, sw*sh), VarSetCapacity(ss, sw*sh)
        , allpos_max:=(FindAll ? 1024 : 1)
        , VarSetCapacity(allpos, allpos_max*4)
        Loop, 2
        {
            if (err1=0 and err0=0) and (num>1 or A_Index>1)
            err1:=0.1, err0:=0.05
            if (JoinText)
            {
            j:=info[1], mode:=j.8, color:=j.9, n:=j.10
            , w1:=-1, h1:=j.3, comment:="", v:="", i:=0
            Loop, % num
            {
                j:=info[A_Index], w1+=j.2+1, comment.=j.11
                Loop, 7
                NumPut((A_Index=1 ? StrLen(v)
                : A_Index=6 and err1 and !j.12 ? Round(j.4*err1)
                : A_Index=7 and err0 and !j.12 ? Round(j.5*err0)
                : j[A_Index]), input, 4*(i++), "int")
                v.=j.1
            }
            ok:=PicFind( mode,color,n,offsetX,offsetY
            , bits,sx,sy,sw,sh,gs,ss,v,s1,s0
            , input,num*7,allpos,allpos_max )
            Loop, % ok
                pos:=NumGet(allpos, 4*(A_Index-1), "uint")
                , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
                , arr.Push( {1:rx, 2:ry, 3:w1, 4:h1
                , x:rx+w1//2, y:ry+h1//2, id:comment} )
            }
            else
            {
            For i,j in info
            {
                mode:=j.8, color:=j.9, n:=j.10, comment:=j.11
                , w1:=j.2, h1:=j.3, v:=j.1
                Loop, 7
                NumPut((A_Index=1 ? 0
                : A_Index=6 and err1 and !j.12 ? Round(j.4*err1)
                : A_Index=7 and err0 and !j.12 ? Round(j.5*err0)
                : j[A_Index]), input, 4*(A_Index-1), "int")
                ok:=PicFind( mode,color,n,offsetX,offsetY
                , bits,sx,sy,sw,sh,gs,ss,v,s1,s0
                , input,7,allpos,allpos_max )
                Loop, % ok
                pos:=NumGet(allpos, 4*(A_Index-1), "uint")
                , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
                , arr.Push( {1:rx, 2:ry, 3:w1, 4:h1
                , x:rx+w1//2, y:ry+h1//2, id:comment} )
                if (ok and !FindAll)
                Break
            }
            }
            if (err1=0 and err0=0 and num=1 and !arr.MaxIndex())
            {
            k:=0
            For i,j in info
                k+=(!j.12)
            IfEqual, k, 0, Break
            }
            else Break
        }
        SetBatchLines, %bch%
        return, arr.MaxIndex() ? arr:0
    }

	xywh2xywh(x1,y1,w1,h1, ByRef x,ByRef y,ByRef w,ByRef h
	  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
	{
	  SysGet, zx, 76
	  SysGet, zy, 77
	  SysGet, zw, 78
	  SysGet, zh, 79
	  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
	  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
	  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
	  x:=left, y:=up, w:=right-left+1, h:=down-up+1
	}

	GetBitsFromScreen(x, y, w, h, ScreenShot:=1
	  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
	{
	  local  ; Unaffected by Super-global variables
  	  static hBM, oldzx, oldzy, oldzw, oldzh, bits:=[]
	  static Ptr:=A_PtrSize ? "UPtr" : "UInt"
	  static init:=!GetBitsFromScreen(0,0,0,0,1)
	  if (!ScreenShot)
	  {
	    zx:=oldzx, zy:=oldzy, zw:=oldzw, zh:=oldzh
	    return, bits
	  }
	  bch:=A_BatchLines, cri:=A_IsCritical
	  Critical
	  if (zw<1 or zh<1)
	  {
	    SysGet, zx, 76
	    SysGet, zy, 77
	    SysGet, zw, 78
	    SysGet, zh, 79
	  }
	  if (zw>oldzw or zh>oldzh or !hBM)
	  {
	    DllCall("DeleteObject", Ptr,hBM), hBM:="", bpp:=32
	    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
	    NumPut(zw, bi, 4, "int"), NumPut(-zh, bi, 8, "int")
	    NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
	    hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
	      , "int",0, Ptr "*",ppvBits, Ptr,0, "int",0, Ptr)
	    Scan0:=(!hBM ? 0:ppvBits), Stride:=((zw*bpp+31)//32)*4
	    bits.1:=Scan0, bits.2:=Stride
	    oldzx:=zx, oldzy:=zy, oldzw:=zw, oldzh:=zh
	    x:=zx, y:=zy, w:=zw, h:=zh
	  }
	  if (hBM) and !(w<1 or h<1)
	  {
	    win:=DllCall("GetDesktopWindow", Ptr)
	    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
	    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
	    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
	    DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      	  , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020) ; |0x40000000)
	    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
	    DllCall("DeleteDC", Ptr,mDC)
	    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
	  }
	  Critical, %cri%
	  SetBatchLines, %bch%
	  return, bits
	}

    PicInfo(text)
    {
        static info:=[]
        IfNotInString, text, $, return
        if (info[text])
            return, info[text]
        v:=text, comment:="", e1:=e0:=0, set_e1_e0:=0
        ; You Can Add Comment Text within The <>
        if RegExMatch(v,"<([^>]*)>",r)
            v:=StrReplace(v,r), comment:=Trim(r1)
        ; You can Add two fault-tolerant in the [], separated by commas
        if RegExMatch(v,"\[([^\]]*)]",r)
        {
            v:=StrReplace(v,r), r1.=","
            StringSplit, r, r1, `,
            e1:=r1, e0:=r2, set_e1_e0:=1
        }
        StringSplit, r, v, $
        color:=r1, v:=r2 "."
        StringSplit, r, v, .
        w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
        if (w1<1 or h1<1 or StrLen(v)!=w1*h1)
            return
        mode:=InStr(color,"-") ? 4 : InStr(color,"#") ? 3
            : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
        if (mode=4)
        {
            color:=StrReplace(color,"0x")
            StringSplit, r, color, -
            color:="0x" . r1, n:="0x" . r2
        }
        else
        {
            color:=RegExReplace(color,"[*#]") . "@"
            StringSplit, r, color, @
            color:=r1, n:=Round(r2,2)+(!r2)
            , n:=Floor(9*255*255*(1-n)*(1-n))
        }
        StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
        , e1:=Round(len1*e1), e0:=Round(len0*e0)
        return, info[text]:=[v,w1,h1,len1,len0,e1,e0
            , mode,color,n,comment,set_e1_e0]
    }

    PicFind(mode, color, n, offsetX, offsetY
    , bits, sx, sy, sw, sh
    , ByRef gs, ByRef ss, ByRef text, ByRef s1, ByRef s0
    , ByRef input, num, ByRef allpos, allpos_max)
    {
        static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
        if (!MyFunc)
        {
            x32:="5557565383EC788B8424CC0000008BBC24CC000000C7442"
            . "424000000008B40048B7F148944243C8B8424CC000000897C2"
            . "42C8BBC24CC0000008B40088B7F18894424388B8424CC00000"
            . "0897C24308B400C89C6894424288B8424CC0000008B401039C"
            . "6894424200F4DC68944241C8B8424D000000085C00F8E15010"
            . "0008BB424CC0000008B44242489F78B0C868B7486048B44870"
            . "88974241085C0894424180F8ED700000089CD894C2414C7442"
            . "40C00000000C744240800000000C744240400000000890C248"
            . "D76008DBC27000000008B5C24108B7424088B4C24148B54240"
            . "C89DF89F029F101F78BB424C000000001CE85DB7E5E8B0C248"
            . "9EB893C2489D7EB198BAC24C800000083C70483C00189548D0"
            . "083C101390424742C83BC248C0000000389FA0F45D0803C063"
            . "175D48BAC24C400000083C70483C00189549D0083C30139042"
            . "475D48B7424100174241489DD890C2483442404018BB424B00"
            . "000008B442404017424088BBC24A4000000017C240C3944241"
            . "80F8554FFFFFF83442424078B442424398424D00000000F8FE"
            . "BFEFFFF83BC248C000000030F84A00600008B8424A40000008"
            . "BB424A80000000FAF8424AC0000008BBC24A40000008D2CB08"
            . "B8424B0000000F7D88D04878BBC248C0000008944241085FF0"
            . "F84F702000083BC248C000000010F847F08000083BC248C000"
            . "000020F84330900008B8424900000008B9C24940000000FB6B"
            . "C24940000000FB6B42490000000C744241800000000C744242"
            . "400000000C1E8100FB6DF0FB6D08B84249000000089D10FB6C"
            . "4894424088B842494000000C1E8100FB6C029C101D08904248"
            . "B442408894C24408B4C240801D829D9894424088D043E894C2"
            . "40489F129F9894424148BBC24B40000008B8424B0000000894"
            . "C240C89E98B6C2440C1E00285FF894424340F8EBA0000008BB"
            . "424B000000085F60F8E910000008B8424A00000008B5424240"
            . "39424BC00000001C8034C243489CF894C244003BC24A000000"
            . "0EB3D8D76008DBC2700000000391C247C3D394C24047F37394"
            . "C24087C3189F30FB6F33974240C0F9EC3397424140F9DC183C"
            . "00483C20121D9884AFF39F8741E0FB658020FB648010FB6303"
            . "9DD7EBE31C983C00483C201884AFF39F875E28BB424B000000"
            . "0017424248B4C24408344241801034C24108B442418398424B"
            . "40000000F8546FFFFFF8B8424B00000002B44243C8944240C8"
            . "B8424B40000002B442438894424600F886D0900008B4424288"
            . "BBC24C40000008B74243CC744241000000000C744243800000"
            . "000C7442434000000008D3C8789C583EE01897C246C8974247"
            . "48B44240C85C00F88E70000008B7C24388B8424AC000000BE0"
            . "0000000C704240000000001F8C1E0108944246889F82B84249"
            . "C0000000F49F08B84249C000000897424640FAFB424B000000"
            . "001F8894424708974245C8DB6000000008B04240344241089C"
            . "1894424088B442430394424200F84AA0100008B5C241C89C60"
            . "38C24BC00000031C08B54242C85DB0F8EC8010000897424048"
            . "B7C2420EB2D39C77E1C8BB424C80000008B1C8601CB803B007"
            . "40B836C240401782B8D74260083C0013944241C0F849101000"
            . "039C57ECF8BB424C40000008B1C8601CB803B0174BE83EA017"
            . "9B9830424018B04243944240C0F8D68FFFFFF83442438018BB"
            . "424B00000008B44243801742410394424600F8DEFFEFFFF8B4"
            . "C243483C47889C85B5E5F5DC250008B8424900000008BB424B"
            . "4000000C744240C00000000C744241400000000C1E8100FB6C"
            . "08904248B8424900000000FB6C4894424040FB684249000000"
            . "0894424088B8424B0000000C1E00285F68944242489E88BAC2"
            . "4940000000F8E24FEFFFF8B9C24B000000085DB7E758B9C24A"
            . "00000008B7424148BBC24A000000003B424BC00000001C3034"
            . "424248944241801C78D76008DBC27000000000FB643020FB64"
            . "B012B04242B4C24040FB6132B5424080FAFC00FAFC98D04400"
            . "FAFD28D04888D045039C50F930683C30483C60139DF75C98BB"
            . "C24B0000000017C24148B4424188344240C01034424108B742"
            . "40C39B424B40000000F8566FFFFFFE985FDFFFF85ED7E358B7"
            . "424088BBC24BC00000031C08B54242C8D1C378BB424C400000"
            . "08B0C8601D9803901740983EA010F8890FEFFFF83C00139C57"
            . "5E683BC24D0000000070F8EAA0100008B442474030424C7442"
            . "44007000000896C2444894424288B8424CC00000083C020894"
            . "4243C8B44243C8B9424B00000008B7C24288B0029C28944245"
            . "08B84249800000001F839C20F4EC289C68944244C39FE0F8C0"
            . "90100008B44243C8B700C8B78108B6808897424148B7014897"
            . "C242489C7897424548BB424B40000002B700489F08B7424703"
            . "9C60F4EC68BB424C4000000894424188B47FC89442404C1E00"
            . "201C6038424C8000000894424588B4424648B7C2428037C245"
            . "C3B442418894424040F8F8700000085ED7E268B8C24BC00000"
            . "08B54242431C08D1C398B0C8601D9803901740583EA01784A8"
            . "3C00139C575EA8B4424148B4C245439C8747E85C07E7A8B9C2"
            . "4BC000000896C244831C08B6C245801FBEB0983C0013944241"
            . "4745C8B54850001DA803A0074EC83E90179E78B6C244890834"
            . "424040103BC24B00000008B442404394424180F8D79FFFFFF8"
            . "3442428018B4424283944244C0F8D4CFFFFFF830424018B6C2"
            . "4448B04243944240C0F8D7EFCFFFFE911FDFFFF8B4424288B7"
            . "C245083442440078344243C1C8D4438FF894424288B4424403"
            . "98424D00000000F8F7FFEFFFF8B6C24448B7C24348B0424038"
            . "424A80000008BB424D40000000B4424688D4F01398C24D8000"
            . "0008904BE0F8ED8FCFFFF85ED7E278B7424088BBC24BC00000"
            . "08B8424C40000008D1C378B74246C8B1083C00401DA39F0C60"
            . "20075F283042401894C24348B04243944240C0F8DDEFBFFFFE"
            . "971FCFFFF89F68DBC27000000008B74243C8B8424900000003"
            . "1D2F7F60FAF8424A40000008D0490894424188B8424B000000"
            . "0038424A800000029F0894424348B8424AC000000038424B40"
            . "000002B442438398424AC0000008944243C0F8F560400008B8"
            . "424A40000008BB424A80000000FAF8424AC000000C74424240"
            . "00000008D04B0034424188BB424A0000000894424388B44243"
            . "4398424A80000000F8F320100008B8424AC000000C1E010894"
            . "424408B442438894424148B8424A8000000894424088B44241"
            . "40FB67C060289C52B6C2418893C240FB67C0601897C24040FB"
            . "63C068B44241C85C00F8E1E0100008B442430894424108B442"
            . "42C8944240C31C0EB678D76008DBC2700000000394424207E4"
            . "A8B9C24C80000008B0C8301E90FB6540E020FB65C0E012B142"
            . "42B5C24040FB60C0E0FAFD20FAFDB29F98D14520FAFC98D149"
            . "A8D144A39942494000000720C836C2410017865908D7426008"
            . "3C0013944241C0F84A3000000394424287E9D8B9C24C400000"
            . "08B0C8301E90FB6540E020FB65C0E012B14242B5C24040FB60"
            . "C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A3B94249"
            . "40000000F865BFFFFFF836C240C010F8950FFFFFF834424080"
            . "183442414048B442408394424340F8DEFFEFFFF838424AC000"
            . "000018BBC24A40000008B44243C017C24383B8424AC0000000"
            . "F8D99FEFFFF8B4C242483C4785B5E89C85F5DC250008D74260"
            . "08B7C24248B4424400B4424088B9C24D40000008D4F013B8C2"
            . "4D80000008904BB0F8D64FAFFFF894C2424EB848B842490000"
            . "0008B8C24B4000000C7042400000000C74424040000000083C"
            . "001C1E00789C68B8424B0000000C1E00285C98944240889E88"
            . "9F50F8EAFF8FFFF8B9424B000000085D27E5F8B8C24A000000"
            . "08B5C2404039C24BC00000001C1034424088944240C038424A"
            . "000000089C70FB651020FB641010FB6316BC04B6BD22601C28"
            . "9F0C1E00429F001D039C50F970383C10483C30139F975D58BB"
            . "424B0000000017424048B44240C83042401034424108B34243"
            . "9B424B40000007582E92CF8FFFF8B8424B0000000C70424000"
            . "00000C744240400000000C1E002894424088B8424B40000008"
            . "5C00F8E920000008B8424B000000085C07E6F8B8C24A000000"
            . "08B5C24048BB424B800000001E9036C240801DE039C24BC000"
            . "000896C240C03AC24A00000000FB651020FB6410183C1040FB"
            . "679FC83C60183C3016BC04B6BD22601C289F8C1E00429F801D"
            . "0C1F8078846FFC643FF0039CD75CC8BBC24B0000000017C240"
            . "48B6C240C83042401036C24108B0424398424B40000000F856"
            . "EFFFFFF83BC24B4000000020F8E60F7FFFF8B8424BC0000000"
            . "38424B00000008BAC24B800000003AC24B0000000C74424040"
            . "1000000894424088B8424B400000083E8018944240C8B8424B"
            . "000000083C0018944241083BC24B0000000027E798B4424108"
            . "9E92B8C24B00000008B5C240889EA8D34288D45FE8904240FB"
            . "642010FB63A0384249000000039F87C360FB67A0239F87C2E0"
            . "FB6790139F87C260FB63E39F87C1F0FB63939F87C180FB6790"
            . "239F87C100FB67EFF39F87C080FB67E0139F87D04C64301018"
            . "3C20183C30183C10183C6013B0C2475A3834424040103AC24B"
            . "00000008B4424048BBC24B0000000017C24083944240C0F855"
            . "8FFFFFFE96FF6FFFF83C47831C95B89C85E5F5DC2500090909"
            . "090909090"
            x64:="4157415641554154555756534881EC88000000488B84245"
            . "0010000488BB42450010000448B94245801000089542428448"
            . "944240844898C24E80000008B40048B76144C8BBC244001000"
            . "04C8BB42448010000C74424180000000089442430488B84245"
            . "00100008974241C488BB424500100008B40088B76188944243"
            . "C488B842450010000897424388B400C89C789442440488B842"
            . "4500100008B401039C7894424100F4DC74585D289442454488"
            . "B84245001000048894424200F8ECB000000488B442420448B0"
            . "8448B68048B400885C0894424040F8E940000004489CE44890"
            . "C244531E431FF31ED0F1F8400000000004585ED7E614863142"
            . "4418D5C3D0089F848039424380100004589E0EB1D0F1F0083C"
            . "0014D63D94183C0044183C1014883C20139C34789149E74288"
            . "3F9034589C2440F45D0803A3175D783C0014C63DE4183C0048"
            . "3C6014883C20139C34789149F75D844012C2483C50103BC241"
            . "80100004403A42400010000396C24047582834424180748834"
            . "424201C8B442418398424580100000F8F35FFFFFF83F9030F8"
            . "43D0600008B8424000100008BBC24080100000FAF842410010"
            . "0008BB424000100008D3CB88B842418010000F7D885C9448D2"
            . "C860F841101000083F9010F844108000083F9020F84E008000"
            . "08B742428C744240400000000C74424180000000089F0440FB"
            . "6CEC1E8104589CC0FB6D84889F08B7424080FB6D44189DB89F"
            . "0440FB6C64889F1C1E8100FB6CD89D60FB6C08D2C0A8B94242"
            . "00100004129C301C3438D040129CE4529C48904248B8424180"
            . "10000C1E00285D2894424080F8E660100004C89BC244001000"
            . "0448BBC24180100004585FF0F8E91040000488B8C24F800000"
            . "04863C74C6354241831D24C03942430010000488D440102EB3"
            . "A0F1F80000000004439C37C4039CE7F3C39CD7C384539CC410"
            . "F9EC044390C240F9DC14421C141880C124883C2014883C0044"
            . "139D70F8E2D040000440FB6000FB648FF440FB648FE4539C37"
            . "EBB31C9EBD58B5C2428448B8C242001000031ED4531E44889D"
            . "84189DB0FB6DB0FB6F48B84241801000041C1EB10450FB6DBC"
            . "1E0024585C98904240F8EA10000004C89BC24400100004C89B"
            . "42448010000448B7C2408448BB424180100004585F67E60488"
            . "B8C24F80000004D63D44C039424300100004863C74531C94C8"
            . "D440102410FB600410FB648FF410FB650FE4429D829F10FAFC"
            . "029DA0FAFC98D04400FAFD28D04888D04504139C7430F93040"
            . "A4983C1014983C0044539CE7FC4033C244501F483C5014401E"
            . "F39AC2420010000758C4C8BBC24400100004C8BB4244801000"
            . "08B8424180100002B4424308904248B8424200100002B44243"
            . "C894424680F88750800008B7C24404D89F5488BAC243001000"
            . "0448B7424104C89FEC74424040000000048C74424280000000"
            . "0C74424200000000089F883E801498D4487044189FF4889442"
            . "4088B44243083E801894424788B042485C00F88D9000000488"
            . "B5C24288B8424100100004D89EC448B6C245401D8C1E010894"
            . "4247089D82B8424F000000089C7B8000000000F49C731FF894"
            . "4246C0FAF842418010000894424648B8424F000000001D8894"
            . "42474908B442404897C24188D1C388B4424384139C60F84AB0"
            . "000004189C131C04585ED448B44241C7F36E9C30000000F1F4"
            . "0004139CE7E1B418B148401DA4863D2807C150000740B4183E"
            . "901782E0F1F4400004883C0014139C50F8E920000004139C78"
            . "9C17ECC8B148601DA4863D2807C15000174BD4183E80179B74"
            . "883C701393C240F8D7AFFFFFF4D89E54883442428018B9C241"
            . "8010000488B442428015C2404394424680F8DFCFEFFFF8B4C2"
            . "42089C84881C4880000005B5E5F5D415C415D415E415FC3458"
            . "5FF7E278B4C241C4C8B4424084889F28B0201D84898807C050"
            . "001740583E90178934883C2044939D075E583BC24580100000"
            . "70F8EE60100008B442478488B8C24500100000344241844896"
            . "C2450448BAC241801000044897C24404883C1204889742410C"
            . "744243C07000000448974244448897C24484989CF895C247C8"
            . "9C64C89642430418B074489EA29C28944245C8B8424E800000"
            . "001F039C20F4EC239F0894424580F8CD0000000418B47148BB"
            . "C2420010000412B7F0449635FFC458B4F08458B670C8944246"
            . "08B442474458B771039C70F4FF8488B44241048C1E3024C8D1"
            . "41848035C24308B442464448D04068B44246C39F84189C37F7"
            . "2904585C97E234489F131D2418B04924401C04898807C05000"
            . "1740583E90178464883C2014139D17FE28B4424604139C40F8"
            . "4AA0000004585E40F8EA100000089C131D2EB0D4883C201413"
            . "9D40F8E8E0000008B04934401C04898807C05000074E483E90"
            . "179DF4183C3014501E84439DF7D8F83C601397424580F8D6EF"
            . "FFFFF488B7C2448448B7C2440448B742444448B6C2450488B7"
            . "424104C8B6424304883C701393C240F8D97FDFFFFE918FEFFF"
            . "F6690037C240844017C241883442404014401EF8B442404398"
            . "424200100000F854DFBFFFF4C8BBC2440010000E996FCFFFF8"
            . "B44245C8344243C074983C71C8D7406FF8B44243C398424580"
            . "100000F8F87FEFFFF448B7C2440448B742444448B6C2450488"
            . "B7C24488B5C247C488B7424104C8B64243048634424208B542"
            . "418039424080100004C8B9C24600100000B5424708D4801398"
            . "C2468010000418914830F8E9AFDFFFF4585FF7E1D4C8B44240"
            . "84889F08B104883C00401DA4C39C04863D2C64415000075EB4"
            . "883C701393C24894C24200F8DBAFCFFFFE93BFDFFFF0F1F440"
            . "0008B7C24308B44242831D2F7F70FAF8424000100008D04908"
            . "94424208B8424180100000384240801000029F8894424308B8"
            . "42410010000038424200100002B44243C39842410010000894"
            . "424440F8F2B0400008B8424000100008BBC24080100000FAF8"
            . "42410010000448B642440448B6C24544C8B8C24F8000000C74"
            . "42428000000008D04B8034424208944243C8B4424303984240"
            . "80100000F8F360100008B8424100100008B6C243CC1E010894"
            . "424408B8424080100008904248D450289EF2B7C24204585ED4"
            . "898450FB61C018D45014898410FB61C014863C5410FB634010"
            . "F8E1C0100008B442438894424188B44241C8944240431C0EB6"
            . "90F1F800000000044395424107E4E418B0C8601F98D5102448"
            . "D41014863C9410FB60C094863D24D63C0410FB61411470FB60"
            . "40129F10FAFC94429DA4129D80FAFD2450FAFC08D1452428D1"
            . "4828D144A395424087207836C241801786B4883C0014139C50"
            . "F8E9F0000004139C44189C27E96418B0C8701F98D5102448D4"
            . "1014863C9410FB60C094863D24D63C0410FB61411470FB6040"
            . "129F10FAFC94429DA4129D80FAFD2450FAFC08D1452428D148"
            . "28D144A3B5424080F864BFFFFFF836C2404010F8940FFFFFF8"
            . "304240183C5048B0424394424300F8DE6FEFFFF83842410010"
            . "000018BBC24000100008B442444017C243C3B8424100100000"
            . "F8D95FEFFFF8B4C2428E95CFBFFFF48634424288B5424400B1"
            . "424488BBC24600100008D48013B8C24680100008914870F8D3"
            . "5FBFFFF8304240183C504894C24288B0424394424300F8D7AF"
            . "EFFFFEB92448B5C2428448B84242001000031DB8B842418010"
            . "00031F6448B9424180100004183C30141C1E3074585C08D2C8"
            . "5000000000F8E6BF9FFFF4585D27E57488B8C24F80000004C6"
            . "3CE4C038C24300100004863C74531C0488D4C01020FB6110FB"
            . "641FF440FB661FE6BC04B6BD22601C24489E0C1E0044429E00"
            . "1D04139C3430F9704014983C0014883C1044539C27FCC01EF4"
            . "401D683C3014401EF399C24200100007595E9FBF8FFFF8B8C2"
            . "4200100008B84241801000031DB31F6448B8C241801000085C"
            . "98D2C85000000007E7D4585C97E694C63C6488B8C24F800000"
            . "04863C74D89C24C038424300100004C0394242801000031D24"
            . "88D4C0102440FB6190FB641FF4883C104440FB661FA6BC04B4"
            . "56BDB264101C34489E0C1E0044429E04401D8C1F8074188041"
            . "241C60410004883C2014139D17FC401EF4401CE83C3014401E"
            . "F399C2420010000758383BC2420010000020F8E4BF8FFFF486"
            . "3B424180100008B9C24180100008BBC2420010000488D56014"
            . "48D67FFBF010000004889D0480394243001000048038424280"
            . "100004889D58D53FD4C8D6A0183BC241801000002488D1C067"
            . "E7E4989C04D8D5C05004989D94929F04889E90FB610440FB65"
            . "0FF035424284439D27C44440FB650014439D27C3A450FB6104"
            . "439D27C31450FB6114439D27C28450FB650FF4439D27C1E450"
            . "FB650014439D27C14450FB651FF4439D27C0A450FB65101443"
            . "9D27D03C601014883C0014983C1014883C1014983C0014C39D"
            . "8759383C7014801F54889D84139FC0F8562FFFFFFE968F7FFF"
            . "F31C9E9D9F8FFFF909090909090909090909090"
            MCode(MyFunc, A_PtrSize=8 ? x64:x32)
        }
        return, !bits.1 ? 0:DllCall(&MyFunc, "int",mode, "uint",color
            , "uint",n, "int",offsetX, "int",offsetY, Ptr,bits.1
            , "int",bits.2, "int",sx, "int",sy, "int",sw, "int",sh
            , Ptr,&gs, Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
            , Ptr,&input, "int",num, Ptr,&allpos, "int",allpos_max)
    }


    MCode(ByRef code, hex)
    {
        bch:=A_BatchLines
        SetBatchLines, -1
        VarSetCapacity(code, len:=StrLen(hex)//2)
        lls:=A_ListLines=0 ? "Off" : "On"
        ListLines, Off
        Loop, % len
            NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
        ListLines, %lls%
        Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr "*"
        DllCall("VirtualProtect",Ptr,&code, Ptr,len,"uint",0x40,PtrP,0)
        SetBatchLines, %bch%
    }

    base64tobit(s)
    {
        Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            . "abcdefghijklmnopqrstuvwxyz"
        SetFormat, IntegerFast, d
        StringCaseSense, On
        lls:=A_ListLines=0 ? "Off" : "On"
        ListLines, Off
        Loop, Parse, Chars
        {
            i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
            . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
            s:=StrReplace(s,A_LoopField,v)
        }
        ListLines, %lls%
        StringCaseSense, Off
        s:=SubStr(s,1,InStr(s,"1",0,0)-1)
        s:=RegExReplace(s,"[^01]+")
        return, s
    }

    bit2base64(s)
    {
        s:=RegExReplace(s,"[^01]+")
        s.=SubStr("100000",1,6-Mod(StrLen(s),6))
        s:=RegExReplace(s,".{6}","|$0")
        Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            . "abcdefghijklmnopqrstuvwxyz"
        SetFormat, IntegerFast, d
        lls:=A_ListLines=0 ? "Off" : "On"
        ListLines, Off
        Loop, Parse, Chars
        {
            i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
            . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
            s:=StrReplace(s,v,A_LoopField)
        }
        ListLines, %lls%
        return, s
    }

    ASCII(s)
    {
        if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
        {
            s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
            s:=StrReplace(StrReplace(s,"0","_"),"1","0")
        }
        else s=
        return, s
    }

    ; You can put the text library at the beginning of the script,
    ; and Use PicLib(Text,1) to add the text library to PicLib()'s Lib,
    ; Use PicLib("comment1|comment2|...") to get text images from Lib

    PicLib(comments, add_to_Lib:=0, index:=1)
    {
        static Lib:=[]
        SetFormat, IntegerFast, d
        if (add_to_Lib)
        {
            re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
            Loop, Parse, comments, |
            if RegExMatch(A_LoopField,re,r)
            {
                s1:=Trim(r1), s2:=""
                Loop, Parse, s1
                s2.="_" . Ord(A_LoopField)
                Lib[index,s2]:=r
            }
            Lib[index,""]:=""
        }
        else
        {
            Text:=""
            Loop, Parse, comments, |
            {
            s1:=Trim(A_LoopField), s2:=""
            Loop, Parse, s1
                s2.="_" . Ord(A_LoopField)
            Text.="|" . Lib[index,s2]
            }
            return, Text
        }
    }

    PicN(Number, index:=1)
    {
        return, PicLib(RegExReplace(Number,".","|$0"), 0, index)
    }

    ; Use PicX(Text) to automatically cut into multiple characters
    ; Can't be used in ColorPos mode, because it can cause position errors

    PicX(Text)
    {
        if !RegExMatch(Text,"\|([^$]+)\$(\d+)\.([\w+/]+)",r)
            return, Text
        w:=r2, v:=base64tobit(r3), Text:=""
        c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
        wz:=RegExReplace(v,".{" w "}","$0`n")
        SetFormat, IntegerFast, d
        While InStr(wz,c)
        {
            While !(wz~="m`n)^" c)
            wz:=RegExReplace(wz,"m`n)^.")
            i:=0
            While (wz~="m`n)^.{" i "}" c)
            i++
            v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
            wz:=RegExReplace(wz,"m`n)^.{" i "}")
            if (v!="")
            Text.="|" r1 "$" i "." bit2base64(v)
        }
        return, Text
    }

    ; Screenshot and retained as the last screenshot.

    ScreenShot(x1:="", y1:="", x2:="", y2:="")
    {
        if (x1+y1+x2+y2="")
            n:=150000, x:=y:=-n, w:=h:=2*n
        else
            x:=(x1<x2 ? x1:x2), y:=(y1<y2 ? y1:y2)
            , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
        xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
        GetBitsFromScreen(x,y,w,h,1,zx,zy,zw,zh)
    }

    ; Get the RGB color of a point from the last screenshot.
    ; If the point to get the color is beyond the range of
    ; Screen, it will return White color (0xFFFFFF).

	ScreenShot_GetColor(x,y)
	{
  	  bits:=GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
	  return, (x<zx or x>zx+zw-1 or y<zy or y>zy+zh-1 or !bits.1)
	    ? "0xFFFFFF" : Format("0x{:06X}",NumGet(bits.1
	    +(y-zy)*bits.2+(x-zx)*4,"uint")&0xFFFFFF)
	}

    ; Identify a line of text or verification code
    ; based on the result returned by FindText()
    ; Return Association array {ocr:Text, x:X, y:Y}

    OcrOK(ok, offsetX:=20, offsetY:=20)
    {
        ocr_Text:=ocr_X:=ocr_Y:=min_X:=""
        For k,v in ok
            x:=v.1
            , min_X:=(A_Index=1 or x<min_X ? x : min_X)
            , max_X:=(A_Index=1 or x>max_X ? x : max_X)
        While (min_X!="" and min_X<=max_X)
        {
            LeftX:=""
            For k,v in ok
            {
            x:=v.1, y:=v.2, w:=v.3, h:=v.4
            if (x<min_X) or Abs(y-ocr_Y)>offsetY
                Continue
            ; Get the leftmost X coordinates
            if (LeftX="" or x<LeftX)
                LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=v.id
            else if (x=LeftX)
            {
                Loop, 100
                {
                err:=(A_Index-1)/100+0.000001
                if FindText(LeftX,LeftY,LeftX+LeftW-1,LeftY+LeftH-1,err,err,Text,0)
                    Break
                if FindText(x, y, x+w-1, y+h-1, err, err, Text, 0)
                {
                    LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=v.id
                    Break
                }
                }
            }
            }
            if (ocr_X="")
            ocr_X:=LeftX, ocr_Y:=LeftY
            ; If the interval exceeds the set value, add "*" to the result
            ocr_Text.=(ocr_Text!="" and LeftX-min_X>offsetX ? "*":"") . LeftOCR
            ; Update min_X for next search
            min_X:=LeftX+LeftW
        }
        return, {ocr:ocr_Text, x:ocr_X, y:ocr_Y}
    }

    ; Sort the results returned by FindText() from left to right
    ; and top to bottom, ignore slight height difference

    SortOK(ok, dy:=10)
    {
        if !IsObject(ok)
            return, ok
        SetFormat, IntegerFast, d
        ypos:=[]
        For k,v in ok
        {
            x:=v.x, y:=v.y, add:=1
            For k2,v2 in ypos
            if Abs(y-v2)<=dy
            {
                y:=v2, add:=0
                Break
            }
            if (add)
            ypos.Push(y)
            n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
        }
        Sort, s, N D-
        ok2:=[]
        Loop, Parse, s, -
            ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
        return, ok2
    }

    ; Reordering according to the nearest distance

    SortOK2(ok, px, py)
    {
        if !IsObject(ok)
            return, ok
        SetFormat, IntegerFast, d
        For k,v in ok
        {
            x:=v.1+v.3//2, y:=v.2+v.4//2
            n:=((x-px)**2+(y-py)**2) "." k
            s:=A_Index=1 ? n : s "-" n
        }
        Sort, s, N D-
        ok2:=[]
        Loop, Parse, s, -
            ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
        return, ok2
    }

    ; Prompt mouse position in remote assistance

    MouseTip(x:="", y:="")
    {
        if (x="")
        {
            VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
            x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
        }
        x:=Round(x-10), y:=Round(y-10), w:=h:=2*10+1
        ;-------------------------
        Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
        Gui, _MouseTip_: Show, Hide w%w% h%h%
        ;-------------------------
        dhw:=A_DetectHiddenWindows
        DetectHiddenWindows, On
        d:=4, i:=w-d, j:=h-d
        s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
        s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
        WinSet, Region, %s%, ahk_id %myid%
        DetectHiddenWindows, %dhw%
        ;-------------------------
        Gui, _MouseTip_: Show, NA x%x% y%y%
        Loop, 4
        {
            Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
            Sleep, 500
        }
        Gui, _MouseTip_: Destroy
    }

;===============  FindText Library End  ===================