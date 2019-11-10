/** * JSON v2.1.3 : JSON lib for AutoHotkey.
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
 */


/**
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

/* XGraph v1.1.1.0 : Real time data plotting.
     __    __  __          __ __       __    __                 _       __                   
    / /_  / /_/ /_____  _ / // /____ _/ /_  / /________________(_)___  / /_ ____  _______
   / __ \/ __/ __/ __ \(_) // // __ '/ __ \/ //_/ ___/ ___/ __/ / __ \/ __// __ \/ __/ _ \     
  / / / / /_/ /_/ /_/ / / // // /_/ / / / / ,< (__  ) /__/ / / / /_/ / /__/ /_/ / / / // / 
 /_/ /_/\__/\__/ .___(_) // / \__,_/_/ /_/_/|_/____/\___/_/ /_/ .___/\__(_)____/_/  \__ /  
              /_/     /_//_/                                 /_/                   (___/   
              
  Script      :  XGraph v1.1.1.0 : Real time data plotting.
                 http://ahkscript.org/boards/viewtopic.php?t=3492
                 Created: 24-Apr-2014,  Last Modified: 09-May-2014 

  Description :  Easy to use, Light weight, fast, efficient GDI based function library for 
                 graphically plotting real time data.

  Author      :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
  Demos       :  CPU Load Monitor > http://ahkscript.org/boards/viewtopic.php?t=3413
  
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
    BitBltW := Columns * ColumnW,                BitBltH := BitmapH - MarginT - MarginB
    MX1     := BitBltW - ColumnW,                    MY1 := BitBltH - 1 
    MX2     := MX1 + ColumnW - ( PenSize < 1 ) ;     MY2 := < user defined >

    ; Initialize Memory Bitmap
    hSourceDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" ) 
    hSourceBM  := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",ColumnW * 2 + BitBltW
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
    
    DllCall( "BitBlt", "Ptr",hSourceDC, "Int",ColumnW * 2, "Int",0, "Int",BitBltW, "Int",BitBltH
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
    DataSz := ( SV = 1 ? Columns * 8 : 0 )
    pGraph := DllCall( "GlobalAlloc", "UInt",GPTR, "Ptr",cbSize + DataSz, "UPtr" )
    NumPut( DataSz, pGraph + cbSize - 8   )     
    VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen / ColumnW / Columns / "
            . "MarginL / MarginT / MarginR / MarginB / MX1 / MX2 / BitBltW / BitBltH" 
    Loop, Parse, VarL, /, %A_Space%
        NumPut( %A_LoopField%, pGraph + 0, ( A_Index - 1 ) * 8 )

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
        Offset := ( A_Index - 1 ) * 8,         %A_LoopField% := NumGet( pGraph + 0, OffSet )
    , RAW    .= SubStr( Offset SP,1,3 ) T SubStr( A_LoopField SP,1,16 ) T %A_LoopField% LF
    
    hTargetBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_GETIMAGE, "Ptr",0, "Ptr",0 )
    VarSetCapacity( BITMAP,32,0 )
    DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
    TBMW := NumGet( BITMAP,  4, "UInt" ),            TBMH := NumGet( BITMAP, 8, "UInt" )
    TBMB := NumGet( BITMAP, 12, "UInt" ) * TBMH,     TBMZ := Round( TBMB/1024,2 )
    TBPP := NumGet( BITMAP, 18, "UShort" )
    Adj := ( Adj := TBMW - MarginL - BitBltW - MarginR ) ? " (-" Adj ")" : ""

    DllCall( "GetObject", "Ptr",hSourceBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",&BITMAP )
    SBMW := NumGet( BITMAP,  4, "UInt" ),            SBMH := NumGet( BITMAP, 8, "UInt" )
    SBMB := NumGet( BITMAP, 12, "UInt" ) * SBMH,     SBMZ := Round( SBMB/1024,2 )
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
        Values .= SubStr( A_Index "   ", 1, 4  ) T NumGet( pData - 8, A_Index * 8, "Double" ) LF
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
        , pNumPut := pData + ( Column < 0 or Column > Columns ? Columns * 8 : Column * 8 )

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
        Return NumGet( pData - 8, Column * 8, "Double" ),    ErrorLevel := Column

    hCtrl   := NumGet( pGraph + 8   ),          ColumnW := NumGet( pGraph + 48 )                      
    , BitBltW := NumGet( pGraph + 112 ),          MarginL := NumGet( pGraph + 64 )
    , BitBltH := NumGet( pGraph + 120 ),          MarginT := NumGet( pGraph + 72 )

    , Numput( MarginL, RECT, 0, "Int" ),          Numput( MarginT, RECT, 4, "Int" )
    , DllCall( "ClientToScreen", "Ptr",hCtrl, "Ptr",&RECT )
    , DllCall( "GetCursorPos", "Ptr",&RECT + 8 )

    , MX := NumGet( RECT, 8, "Int" ) - NumGet( RECT, 0, "Int" ) 
    , MY := NumGet( RECT,12, "Int" ) - NumGet( RECT, 4, "Int" )

    , Column := ( MX >= 0 and MY >= 0 and MX < BitBltW and MY < BitBltH ) ? MX // ColumnW + 1 : 0
    Return ( DataSz and Column ) ? NumGet( pData - 8, Column * 8, "Double" ) : "",    ErrorLevel := Column  
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_GetMean( pGraph, TailCols := "" ) {

    IfEqual, pGraph, 0, Return "",    ErrorLevel := -1 
    pData := pGraph + NumGet( pGraph + 0 ), DataSz := Numget( pData - 8 )
    IfEqual, DataSz, 0, Return 0,     ErrorLevel := 0

    Columns := NumGet( pGraph + 56 )
    pDataEnd := pGraph + NumGet( pGraph + 0 ) + ( Columns * 8 )
    TailCols := ( TailCols = "" or TailCols < 1 or Tailcols > Columns ) ? Columns : TailCols

    Loop %TailCols%
        Value += NumGet( pDataEnd - ( A_Index * 8 ), 0, "Double"  )

    Return Value / TailCols,            ErrorLevel := TailCols
    }

    ; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    XGraph_Detach( pGraph ) {
    IfEqual, pGraph, 0, Return 0
    
    VarL := "cbSize / hCtrl / hTargetDC / hSourceDC / hSourceBM / hSourcePen"
    Loop, Parse, VarL, /, %A_Space%
        %A_LoopField% := NumGet( pGraph + 0, ( A_Index - 1 ) * 8 )

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

    BMPW := CellW * Cols + 1,  BMPH := CellH * Rows + 1
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

        WB := Ceil( ( W * 3 ) / 2 ) * 2,  VarSetCapacity( BMBITS, WB * H + 1, 0 ),  P := &BMBITS
        Loop, Parse, PixelData, |
            P := Numput( "0x" A_LoopField, P+0, 0, "UInt" ) - ( W & 1 and Mod( A_Index * 3, W * 3 ) = 0 ? 0 : 1 )

        hBM := DllCall( "CreateBitmap", "Int",W, "Int",H, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )    
        hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag1, "Ptr" ) 
        DllCall( "SetBitmapBits", "Ptr",hBM, "UInt",WB * H, "Ptr",&BMBITS )

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
        GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX * 2) " h" A_GuiHeight - (GuiArrayTreeY * 2)
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

/* FindText - Capture screen image into text and then find it
    ;--------------------------------
    ; X, Y --> the search scope's upper left corner coordinates
    ; W, H --> the search scope's Width and Height
    ; err1, err0 --> character "0" or "_" fault-tolerant in percentage
    ; Text --> can be a lot of text parsed into images, separated by "|"
    ; ScreenShot --> if the value is 0, the last screenshot will be used
    ; FindAll --> if the value is 0, Just find one result and return
    ; JoinText --> if the value is 1, Join all Text for combination lookup
    ; offsetX, offsetY --> Set the Max text offset for combination lookup
    ; ruturn --> a second-order array contains the [X,Y,W,H,Comment] of Each Find
    ;--------------------------------
*/
    FindText( x, y, w, h, err1, err0, text, ScreenShot=1
    , FindAll=1, JoinText=0, offsetX=20, offsetY=10 )
    {
    xywh2xywh(x,y,w,h,x,y,w,h)
    if (w<1 or h<1)
        return, 0
    bch:=A_BatchLines
    SetBatchLines, -1
    ;-------------------------------
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,ScreenShot,zx,zy)
    ;-------------------------------
    sx:=x-zx, sy:=y-zy, sw:=w, sh:=h
    , arr:=[], info:=[], allv:=""
    Loop, Parse, text, |
    {
        v:=A_LoopField
        IfNotInString, v, $, Continue
        comment:="", e1:=err1, e0:=err0
        ; You Can Add Comment Text within The <>
        if RegExMatch(v,"<([^>]*)>",r)
        v:=StrReplace(v,r), comment:=Trim(r1)
        ; You can Add two fault-tolerant in the [], separated by commas
        if RegExMatch(v,"\[([^\]]*)]",r)
        {
        v:=StrReplace(v,r), r1.=","
        StringSplit, r, r1, `,
        e1:=r1, e0:=r2
        }
        StringSplit, r, v, $
        color:=r1, v:=r2
        StringSplit, r, v, .
        w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
        if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
        Continue
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
        color:=mode=3 ? ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4 : r1
        n:=Round(r2,2)+(!r2), n:=Floor(9*255*255*(1-n)*(1-n))
        }
        StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
        e1:=Round(len1*e1), e0:=Round(len0*e0)
        info.Push( [StrLen(allv),w1,h1,len1,len0,e1,e0
        ,mode,color,n,comment] ), allv.=v
    }
    if (allv="")
    {
        SetBatchLines, %bch%
        return, 0
    }
    num:=info.MaxIndex(), VarSetCapacity(input, num*7*4)
    , VarSetCapacity(gs, sw*sh)
    , VarSetCapacity(ss, sw*sh), k:=StrLen(allv)*4
    , VarSetCapacity(s1, k), VarSetCapacity(s0, k)
    , allpos_max:=FindAll ? 1024 : 1
    , VarSetCapacity(allpos, allpos_max*4)
    ;-------------------------------------
    Loop, 2 {
    if (JoinText)
    {
        mode:=info.1.8, color:=info.1.9, n:=info.1.10
        , w1:=-1, h1:=info.1.3, comment:="", k:=0
        Loop, % num {
        i:=A_Index, w1+=info[i].2+1, comment.=info[i].11
        Loop, 7
            NumPut(info[i][A_Index], input, 4*(k++), "int")
        }
        ok:=PicFind( mode,color,n,offsetX,offsetY
        ,Scan0,Stride,sx,sy,sw,sh,gs,ss,allv,s1,s0
        ,input,num*7,allpos,allpos_max )
        Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
    else
    {
        For i,j in info
        {
        mode:=j.8, color:=j.9, n:=j.10, comment:=j.11
        , w1:=j.2, h1:=j.3, v:=SubStr(allv, j.1+1, w1*h1)
        Loop, 7
            NumPut(j[A_Index], input, 4*(A_Index-1), "int")
        NumPut(0, input, "int")
        ok:=PicFind( mode,color,n,offsetX,offsetY
            ,Scan0,Stride,sx,sy,sw,sh,gs,ss,v,s1,s0
            ,input,7,allpos,allpos_max )
        Loop, % ok
            pos:=NumGet(allpos, 4*(A_Index-1), "uint")
            , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
            , arr.Push( [rx,ry,w1,h1,comment] )
        }
    }
    if (err1=0 and err0=0 and !arr.MaxIndex())
    {
        err1:=err0:=0.1
        For i,j in info
        if (j.6=0 and j.7=0)
            j.6:=Round(j.4*err1), j.7:=Round(j.5*err0)
    }
    else Break
    }
    SetBatchLines, %bch%
    return, arr.MaxIndex() ? arr:0
    }

    PicFind(mode, color, n, offsetX, offsetY
    , Scan0, Stride, sx, sy, sw, sh
    , ByRef gs, ByRef ss, ByRef text, ByRef s1, ByRef s0
    , ByRef input, num, ByRef allpos, allpos_max)
    {
    static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
    if !MyFunc
    {
        x32:="5557565383EC788B8424CC0000008BBC24CC000000C7442"
        . "424000000008B40048B7F148944243C8B8424CC000000897C2"
        . "42C8BBC24CC0000008B40088B7F18894424348B8424CC00000"
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
        . "BB424A80000000FAF8424AC0000008BBC248C0000008D2CB08"
        . "B8424B00000008BB424A4000000F7D885FF8D0486894424100"
        . "F84F702000083BC248C000000010F845F08000083BC248C000"
        . "000020F84130900008B8424900000008B9C24940000000FB6B"
        . "C24940000000FB6B42490000000C744241800000000C744242"
        . "400000000C1E8100FB6DF0FB6D08B84249000000089D10FB6C"
        . "4894424088B842494000000C1E8100FB6C029C101D08904248"
        . "B442408894C24408B4C240801D829D9894424088D043E894C2"
        . "40489F129F9894424148BBC24B40000008B8424B0000000894"
        . "C240C89E98B6C2440C1E00285FF894424380F8EBA0000008BB"
        . "424B000000085F60F8E910000008B8424A00000008B5424240"
        . "39424BC00000001C8034C243889CF894C244003BC24A000000"
        . "0EB3D8D76008DBC2700000000391C247C3D394C24047F37394"
        . "C24087C3189F30FB6F33974240C0F9EC3397424140F9DC183C"
        . "00483C20121D9884AFF39F8741E0FB658020FB648010FB6303"
        . "9DD7EBE31C983C00483C201884AFF39F875E28BBC24B000000"
        . "0017C24248B4C24408344241801034C24108B442418398424B"
        . "40000000F8546FFFFFF8B8424B00000002B44243C8944240C8"
        . "B8424B40000002B442434894424600F884D0900008B4424288"
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
        . "90100008B44243C8B700C8B78148B6808897424148B7010897"
        . "C245489C7897424248BB424B40000002B700489F08B7424703"
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
        . "4245083442440078344243C1C8D4430FF894424288B4424403"
        . "98424D00000000F8F7FFEFFFF8B6C24448B7C24348B0424038"
        . "424A80000008BB424D40000000B4424688D4F01398C24D8000"
        . "0008904BE0F8ED8FCFFFF85ED7E278B7424088BBC24BC00000"
        . "08B8424C40000008D1C378B74246C8B1083C00401DA39F0C60"
        . "20075F283042401894C24348B04243944240C0F8DDEFBFFFFE"
        . "971FCFFFF89F68DBC27000000008B8424B0000000038424A80"
        . "000002B44243C894424248B8424AC000000038424B40000002"
        . "B442434398424AC000000894424380F8F520400008B8424A40"
        . "000008BB424A80000000FAF8424AC000000C74424180000000"
        . "08D04B0038424900000008BB424A0000000894424348B44242"
        . "4398424A80000000F8F2B0100008B8424AC000000C1E010894"
        . "4243C8B442434894424148B8424A8000000894424088B44241"
        . "40FB67C060289C52BAC2490000000893C240FB67C0601897C2"
        . "4040FB63C068B44241C85C00F8E140100008B4424308944241"
        . "08B44242C8944240C31C0EB5D394424207E4A8B9C24C800000"
        . "08B0C8301E90FB6540E020FB65C0E012B14242B5C24040FB60"
        . "C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A3994249"
        . "4000000720C836C2410017865908D74260083C0013944241C0"
        . "F84A3000000394424287E9D8B9C24C40000008B0C8301E90FB"
        . "6540E020FB65C0E012B14242B5C24040FB60C0E0FAFD20FAFD"
        . "B29F98D14520FAFC98D149A8D144A3B9424940000000F865BF"
        . "FFFFF836C240C010F8950FFFFFF834424080183442414048B4"
        . "42408394424240F8DF6FEFFFF838424AC000000018BBC24A40"
        . "000008B442438017C24343B8424AC0000000F8DA0FEFFFF8B4"
        . "C241883C4785B5E89C85F5DC250008D7426008B7C24188B442"
        . "43C0B4424088B9C24D40000008D4F013B8C24D80000008904B"
        . "B0F8D84FAFFFF894C2418EB848B8424900000008B8C24B4000"
        . "000C7042400000000C74424040000000083C001C1E00789C78"
        . "B8424B0000000C1E00285C98944240889E889FD0F8ECFF8FFF"
        . "F8B9424B000000085D27E5F8B8C24A00000008B5C2404039C2"
        . "4BC00000001C1034424088944240C038424A000000089C70FB"
        . "651020FB641010FB6316BC04B6BD22601C289F0C1E00429F00"
        . "1D039C50F970383C10483C30139F975D58BBC24B0000000017"
        . "C24048B44240C83042401034424108B342439B424B40000007"
        . "582E94CF8FFFF8B8424B0000000C7042400000000C74424040"
        . "0000000C1E002894424088B8424B400000085C00F8E9200000"
        . "08B8424B000000085C07E6F8B8C24A00000008B5C24048BB42"
        . "4B800000001E9036C240801DE039C24BC000000896C240C03A"
        . "C24A00000000FB651020FB6410183C1040FB679FC83C60183C"
        . "3016BC04B6BD22601C289F8C1E00429F801D0C1F8078846FFC"
        . "643FF0039CD75CC8BB424B0000000017424048B6C240C83042"
        . "401036C24108B0424398424B40000000F856EFFFFFF83BC24B"
        . "4000000020F8E80F7FFFF8B8424BC000000038424B00000008"
        . "BAC24B800000003AC24B0000000C7442404010000008944240"
        . "88B8424B400000083E8018944240C8B8424B000000083C0018"
        . "944241083BC24B0000000027E798B44241089E92B8C24B0000"
        . "0008B5C240889EA8D34288D45FE8904240FB642010FB63A038"
        . "4249000000039F87C360FB67A0239F87C2E0FB6790139F87C2"
        . "60FB63E39F87C1F0FB63939F87C180FB6790239F87C100FB67"
        . "EFF39F87C080FB67E0139F87D04C643010183C20183C30183C"
        . "10183C6013B0C2475A3834424040103AC24B00000008B44240"
        . "48BB424B0000000017424083944240C0F8558FFFFFFE98FF6F"
        . "FFF83C47831C95B89C85E5F5DC2500090909090909090"
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
        . "C860F841101000083F9010F842008000083F9020F84BF08000"
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
        . "C894424680F88540800008B7C24404D89F5488BAC243001000"
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
        . "0008B842418010000038424080100002B442430894424308B8"
        . "42410010000038424200100002B44243C39842410010000894"
        . "424440F8F230400008B8424000100008BBC24080100000FAF8"
        . "42410010000448B642440448B6C24544C8B8C24F8000000C74"
        . "42420000000008D04B8034424288944243C8B4424303984240"
        . "80100000F8F2F0100008B8424100100008B6C243CC1E010894"
        . "424408B8424080100008904248D450289EF2B7C24284585ED4"
        . "898450FB61C018D45014898410FB61C014863C5410FB634010"
        . "F8E140100008B442438894424188B44241C8944240431C0EB6"
        . "244395424107E4E418B0C8601F98D5102448D41014863C9410"
        . "FB60C094863D24D63C0410FB61411470FB6040129F10FAFC94"
        . "429DA4129D80FAFD2450FAFC08D1452428D14828D144A39542"
        . "4087207836C241801786B4883C0014139C50F8E9E000000413"
        . "9C44189C27E96418B0C8701F98D5102448D41014863C9410FB"
        . "60C094863D24D63C0410FB61411470FB6040129F10FAFC9442"
        . "9DA4129D80FAFD2450FAFC08D1452428D14828D144A3B54240"
        . "80F864BFFFFFF836C2404010F8940FFFFFF8304240183C5048"
        . "B0424394424300F8DEDFEFFFF83842410010000018BBC24000"
        . "100008B442444017C243C3B8424100100000F8D9CFEFFFFE97"
        . "CFBFFFF0F1F0048634424208B5424400B1424488BBC2460010"
        . "0008D48013B8C24680100008914870F8D56FBFFFF830424018"
        . "3C504894C24208B0424394424300F8D82FEFFFFEB93448B5C2"
        . "428448B84242001000031DB8B84241801000031F6448B94241"
        . "80100004183C30141C1E3074585C08D2C85000000000F8E8CF"
        . "9FFFF4585D27E57488B8C24F80000004C63CE4C038C2430010"
        . "0004863C74531C0488D4C01020FB6110FB641FF440FB661FE6"
        . "BC04B6BD22601C24489E0C1E0044429E001D04139C3430F970"
        . "4014983C0014883C1044539C27FCC01EF4401D683C3014401E"
        . "F399C24200100007595E91CF9FFFF8B8C24200100008B84241"
        . "801000031DB31F6448B8C241801000085C98D2C85000000007"
        . "E7D4585C97E694C63C6488B8C24F80000004863C74D89C24C0"
        . "38424300100004C0394242801000031D2488D4C0102440FB61"
        . "90FB641FF4883C104440FB661FA6BC04B456BDB264101C3448"
        . "9E0C1E0044429E04401D8C1F8074188041241C60410004883C"
        . "2014139D17FC401EF4401CE83C3014401EF399C24200100007"
        . "58383BC2420010000020F8E6CF8FFFF4863B424180100008B9"
        . "C24180100008BBC2420010000488D5601448D67FFBF0100000"
        . "04889D0480394243001000048038424280100004889D58D53F"
        . "D4C8D6A0183BC241801000002488D1C067E7E4989C04D8D5C0"
        . "5004989D94929F04889E90FB610440FB650FF035424284439D"
        . "27C44440FB650014439D27C3A450FB6104439D27C31450FB61"
        . "14439D27C28450FB650FF4439D27C1E450FB650014439D27C1"
        . "4450FB651FF4439D27C0A450FB651014439D27D03C60101488"
        . "3C0014983C1014883C1014983C0014C39D8759383C7014801F"
        . "54889D84139FC0F8562FFFFFFE989F7FFFF31C9E9FAF8FFFF9"
        . "0909090909090909090909090"
        MCode(MyFunc, A_PtrSize=8 ? x64:x32)
    }
    return, DllCall(&MyFunc, "int",mode, "uint",color
        , "uint",n, "int",offsetX, "int",offsetY, Ptr,Scan0
        , "int",Stride, "int",sx, "int",sy, "int",sw, "int",sh
        , Ptr,&gs, Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
        , Ptr,&input, "int",num, Ptr,&allpos, "int",allpos_max)
    }

    xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
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

    GetBitsFromScreen(x, y, w, h, ByRef Scan0, ByRef Stride
    , ScreenShot=1, ByRef zx="", ByRef zy="", bpp=32)
    {
    static bits, oldx, oldy, oldw, oldh
    static Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr "*"
    if (ScreenShot or x<oldx or y<oldy
        or x+w>oldx+oldw or y+h>oldy+oldh)
    {
        oldx:=x, oldy:=y, oldw:=w, oldh:=h, ScreenShot:=1
        VarSetCapacity(bits, w*h*4)
    }
    Scan0:=&bits, Stride:=((oldw*bpp+31)//32)*4, zx:=oldx, zy:=oldy
    if (!ScreenShot or w<1 or h<1)
        return
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
    ;-------------------------
    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
    NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
    NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
    ;-------------------------
    if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
        , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
    {
        oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
        DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
        , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
        DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
        DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
        DllCall("DeleteObject", Ptr,hBM)
    }
    DllCall("DeleteDC", Ptr,mDC)
    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
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
    Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
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
    ; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
    ; Use Pic("comment1|comment2|...") to get text images from Lib

    Pic(comments, add_to_Lib=0)
    {
    static Lib:=[]
    if (add_to_Lib)
    {
        re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
        Loop, Parse, comments, |
        if RegExMatch(A_LoopField,re,r)
            Lib[Trim(r1)]:=r
        Lib[""]:=""
    }
    else
    {
        Text:=""
        Loop, Parse, comments, |
        Text.="|" . Lib[Trim(A_LoopField)]
        return, Text
    }
    }

    PicN(Number)
    {
    return, Pic( RegExReplace(Number, ".", "|$0") )
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
    While InStr(wz,c) {
        While !(wz~="m`n)^" c)
        wz:=RegExReplace(wz,"m`n)^.")
        i:=0
        While (wz~="m`n)^.{" i "}" c)
        i++
        v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
        wz:=RegExReplace(wz,"m`n)^.{" i "}")
        if v!=
        Text.="|" r1 "$" i "." bit2base64(v)
    }
    return, Text
    }

    ; Screenshot and retained as the last screenshot.

    ScreenShot()
    {
    n:=150000
    xywh2xywh(-n,-n,2*n+1,2*n+1,x,y,w,h)
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,1)
    }

    FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=20)
    {
    OCR:="", RightX:=nX+nW-1, ScreenShot()
    While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text, 0))
    {
        For k,v in ok
        {
        ; X is the X coordinates of the upper left corner
        ; and W is the width of the image have been found
        x:=v.1, y:=v.2, w:=v.3, h:=v.4, comment:=v.5
        ; We need the leftmost X coordinates
        if (A_Index=1 or x<LeftX)
            LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
        else if (x=LeftX)
        {
            Loop, 100
            {
            err:=A_Index/100
            if FindText(x, y, w, h, err, err, Text, 0)
            {
                LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
                Break
            }
            if FindText(LeftX, LeftY, LeftW, LeftH, err, err, Text, 0)
                Break
            }
        }
        }
        ; If the interval exceeds the set value, add "*" to the result
        OCR.=(A_Index>1 and LeftX-nX-1>Interval ? "*":"") . LeftOCR
        ; Update nX and nW for next search
        nX:=LeftX+LeftW-1, nW:=RightX-nX+1
    }
    return, OCR
    }

    ; Reordering the objects returned from left to right,
    ; from top to bottom, ignore slight height difference

    SortOK(ok, dy=10) {
    if !IsObject(ok)
        return, ok
    SetFormat, IntegerFast, d
    For k,v in ok
    {
        x:=v.1+v.3//2, y:=v.2+v.4//2
        y:=A_Index>1 and Abs(y-lasty)<dy ? lasty : y, lasty:=y
        n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
    }
    Sort, s, N D-
    ok2:=[]
    Loop, Parse, s, -
        ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
    return, ok2
    }

    ; Reordering according to the nearest distance

    SortOK2(ok, px, py) {
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

    MouseTip(x="", y="") {
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
    Loop, 4 {
        Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
        Sleep, 500
    }
    Gui, _MouseTip_: Destroy
    }
; Capture GUI for FindText


  ; if (A_IsCompiled or A_LineFile!=A_ScriptFullPath)
  ;   Goto, ft_End

  ft_Start:

  ;IfNotEqual, ft_ToolTip_Text,, Goto, ft_Main_Window
  If CaptureGUIFirstLoad
   Goto, ft_Main_Window
  ;   #NoEnv
  ;   #SingleInstance force
  ;   SetBatchLines, -1
  ;   Menu, Tray, Add
  ;   Menu, Tray, Add, FinText, ft_Main_Window
  ;   if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
  ;   {
  ;     Menu, Tray, Default, FinText
  ;     Menu, Tray, Click, 1
  ;     Menu, Tray, Icon, Shell32.dll, 23
  ;   }
  ; The capture range can be changed by adjusting the numbers
  ;----------------------------
    ft_ww:=15, ft_hh:=15
  ;----------------------------
  ft_nW:=2*ft_ww+1, ft_nH:=2*ft_hh+1
  Gosub, ft_MakeCaptureWindow
  Gosub, ft_MakeMainWindow
  Gosub, ft_Load_ToolTip_Text
  return

  ft_Load_ToolTip_Text:
    CaptureGUIFirstLoad := True
  return

  ft_Main_Window:
  Gui, ft_Main:Show, Center
  return

  ft_MakeMainWindow:
  Gui, ft_Main:Default
  Gui, +AlwaysOnTop
  Gui, Margin, 15, 15
  Gui, Color, DDEEFF
  Gui, Font, s6 bold, Verdana
  Gui, Add, Edit, xm w660 r25 vft_MyPic -Wrap -VScroll
  Gui, Font, s12 norm, Verdana
  Gui, Add, Button, w220 gft_MainRun, Capture
  Gui, Add, Button, x+0 wp gft_MainRun, Test
  Gui, Add, Button, x+0 wp gft_MainRun Section, Copy
  Gui, Font, s10
  	Gui, Add, text, xm+25 y+5 w35, Width: %A_Space%
  	Gui, Add, text, vft_ww_t x+0 yp w35, %ft_ww%
	Gui, Add, UpDown, vft_ww Range1-60, %ft_ww%
  	Gui, Add, text, x+5 yp w35, Height: %A_Space%
  	Gui, Add, text, vft_hh_t x+0 yp w35, %ft_hh%
	Gui, Add, UpDown, vft_hh Range1-30, %ft_hh%

  Gui, Add, Text, xm, Click Text String to See ASCII Search Text in the Above
  ;   Gui, Add, Checkbox, xs yp w220 r1 -Wrap -Checked vft_AddFunc, Additional FindText() in Copy
  Gui, Font, s12 cBlue, Verdana
  Gui, Add, Edit, xm w660 h350 vft_scr Hwndft_hscr -Wrap HScroll
  Gui, Show,, Capture Image To Text And Find Text Tool
  ;---------------------------------------
  OnMessage(0x100, Func("ft_EditEvents1"))  ; WM_KEYDOWN
  OnMessage(0x201, Func("ft_EditEvents2"))  ; WM_LBUTTONDOWN
  OnMessage(0x200, Func("ft_ShowToolTip"))  ; WM_MOUSEMOVE
  return

  UpdateWWHH:
    ft_old_ww := ft_ww, ft_old_hh := ft_hh
    Gui, Submit, NoHide
    If (ft_old_ww != ft_ww || ft_old_hh != ft_hh)
    {
        Tooltip, Building Menu for new capture area
        ft_nW:=2*ft_ww+1, ft_nH:=2*ft_hh+1
        Gui, ft_Capture: Destroy
        Gosub, ft_MakeCaptureWindow
        Tooltip
    }
  Return

  ft_EditEvents1()
  {
    ListLines, Off
    if (A_Gui="ft_Main" && A_GuiControl="ft_scr")
      SetTimer, ft_ShowPic, -100
  }

  ft_EditEvents2()
  {
    ListLines, Off
    if (A_Gui="ft_Capture")
      ft_WM_LBUTTONDOWN()
    else
      ft_EditEvents1()
  }

  ft_ShowPic:
    ListLines, Off
    Critical
    ControlGet, i, CurrentLine,,, ahk_id %ft_hscr%
    ControlGet, s, Line, %i%,, ahk_id %ft_hscr%
    GuiControl, ft_Main:, ft_MyPic, % Trim(ASCII(s),"`n")
  return

  ft_MainRun:
    k:="ft_" . A_GuiControl
    WinMinimize
    Gui, Hide
    DetectHiddenWindows, Off
    Gui, +LastFound
    WinWaitClose, % "ahk_id " WinExist()
    if IsLabel(k)
      Gosub, %k%
    Gui, ft_Main: Show
    GuiControl, ft_Main: Focus, ft_scr
  return

  ft_Copy:
    GuiControlGet, s,, ft_scr
    GuiControlGet, r,, ft_AddFunc
    if (r != 1)
      s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
    ExportString := StrReplace(ExportString,"Text:=","")
    ExportString:=Clipboard:=StrReplace(ExportString,"`n","")
    s=
    Gui, ft_Main: Hide
    Gui, ft_Capture: Hide
    Gui, ft_Mini: Hide
    Exit
  Return

  ft_Capture:
    GoSub, UpdateWWHH
    Thread, NoTimers, true ;Critical
    Gui, ft_Mini:Default
    Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x08000000
    Gui, Color, Red
    d:=2, w:=ft_nW+2*d, h:=ft_nH+2*d, i:=w-d, j:=h-d
    Gui, Show, Hide w%w% h%h%
    s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
    s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
    WinSet, Region, %s%
    ;------------------------------
    Hotkey, $*a, ft_Akey_Off, On
    ListLines, Off
    CoordMode, Mouse
    ft_oldx:=ft_oldy:=""
    Loop {
      Sleep, 50
      MouseGetPos, x, y
      if (ft_oldx=x and ft_oldy=y)
        Continue
      ft_oldx:=x, ft_oldy:=y
      ;---------------
      Gui, Show, % "NA x" (x-w//2) " y" (y-h//2)
      ToolTip, % "Mark the Position : " x "," y
        . "`nFirst: Press the A key to mark area"
    } Until GetKeyState("a", "P")
    KeyWait, a
    ft_px:=x, ft_py:=y, ft_oldx:=ft_oldy:=""
    Loop {
      Sleep, 50
      MouseGetPos, x, y
      if (ft_oldx=x and ft_oldy=y)
        Continue
      ft_oldx:=x, ft_oldy:=y
      ;---------------
      ToolTip, % "The Capture Position : " ft_px "," ft_py
        . "`nSecond: Press the A key to capture"
    } Until GetKeyState("a", "P")
    KeyWait, a
    ToolTip
    ListLines, On
    Gui, Destroy
    WinWaitClose
    ft_cors:=ft_getc(ft_px,ft_py,ft_ww,ft_hh)
    Hotkey, $*a, ft_Akey_Off, Off
    Goto, ft_ShowCaptureWindow
    ft_Akey_Off:
  return

  ft_ShowCaptureWindow:
    ft_cors.Event:="", ft_cors.Result:=""
    ;--------------------------------
    Gui, ft_Capture:Default
    k:=ft_nW*ft_nH+1
    Loop, % ft_nW
      GuiControl,, % ft_C_[k++], 0
    Loop, 6
      GuiControl,, Edit%A_Index%
    GuiControl,, ft_Modify, % ft_Modify:=0
    GuiControl,, ft_GrayDiff, 50
    GuiControl, Focus, ft_Threshold
    Gosub, ft_Reset
    Gui, Show, Center
    DetectHiddenWindows, Off
    Gui, +LastFound
    WinWaitClose, % "ahk_id " WinExist()
    ;--------------------------------
    if InStr(ft_cors.Event,"OK")
    {
      if !A_IsCompiled
      {
        FileRead, s, %A_LineFile%
        s:=SubStr(s, s~="i)\n[;=]+ Copy The")
      } else s:=""
      GuiControl, ft_Main:, ft_scr, % ft_cors.Result "`n" s
      ft_cors.Result:=s:=""
      return
    }
    if InStr(ft_cors.Event,"Add")
      ft_add(ft_cors.Result, 0), ft_cors.Result:=""
  return

  ft_WM_LBUTTONDOWN()
  {
    global
    ListLines, Off
    Critical
    MouseGetPos,,,, j
    IfNotInString, j, progress
      return
    Gui, ft_Capture:Default
    MouseGetPos,,,, j, 2
    For k,v in ft_C_
      if (v=j)
      {
        if (k>ft_nW*ft_nH)
        {
          GuiControlGet, i,, %v%
          GuiControl,, %v%, % i ? 0:100
        }
        else if (ft_Modify and ft_bg!="")
        {
          c:=ft_ascii[k], ft_ascii[k]:=c="0" ? "_" : c="_" ? "0" : c
          c:=c="0" ? "White" : c="_" ? "Black" : ft_WindowColor
          Gosub, ft_SetColor
        }
        else
        {
          c:=ft_cors[k], ft_cors.SelPos:=k
          r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
          GuiControl,, ft_SelGray, % (r*38+g*75+b*15)>>7
          GuiControl,, ft_SelColor, %c%
          GuiControl,, ft_SelR, %r%
          GuiControl,, ft_SelG, %g%
          GuiControl,, ft_SelB, %b%
        }
        return
      }
  }

  ft_getc(px, py, ww, hh)
  {
    xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
    if (w<1 or h<1)
      return, 0
    bch:=A_BatchLines
    SetBatchLines, -1
    ;--------------------------------------
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,1)
    ;--------------------------------------
    cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
    lls:=A_ListLines=0 ? "Off" : "On"
    ListLines, Off
    fmt:=A_FormatInteger
    SetFormat, IntegerFast, H
    Loop, %nH% {
      j:=py-hh+A_Index-1
      Loop, %nW% {
        i:=px-ww+A_Index-1, k++
        if (i>=x and i<=x+w-1 and j>=y and j<=y+h-1)
          c:=NumGet(Scan0+0,(j-y)*Stride+(i-x)*4,"uint")
            , cors[k]:="0x" . SubStr(0x1000000|c,-5)
        else
          cors[k]:="0xFFFFFF"
      }
    }
    SetFormat, IntegerFast, %fmt%
    ListLines, %lls%
    cors.LeftCut:=Abs(px-ww-x)
    cors.RightCut:=Abs(px+ww-(x+w-1))
    cors.UpCut:=Abs(py-hh-y)
    cors.DownCut:=Abs(py+hh-(y+h-1))
    SetBatchLines, %bch%
    return, cors
  }

  ft_Test:
    GuiControlGet, s, ft_Main:, ft_scr
    s:="`n#NoEnv`nMenu, Tray, Click, 1`n"
      . "Gui, _ok_:Show, Hide, _ok_`n"
      . s "`nExitApp`n#SingleInstance off`n"
    if (!A_IsCompiled) and InStr(s,"MCode(")
    {
      ft_Exec(s)
      DetectHiddenWindows, On
      WinWait, _ok_ ahk_class AutoHotkeyGUI,, 3
      if !ErrorLevel
        WinWaitClose, _ok_ ahk_class AutoHotkeyGUI
    }
    else
    {
      CoordMode, Mouse
      t:=A_TickCount, RegExMatch(s,"\[\d+,\s*\d+\]",r)
      RegExMatch(s,"=""\K[^$\n]+\$\d+\.[\w+/]+",v)
      k:=FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, v)
      X:=k.1.1, Y:=k.1.2, W:=k.1.3, H:=k.1.4, cX:=X + W//2, cY:=Y + H//2
      MsgBox, 4096,, % "Time:`t" (A_TickCount-t) " ms`n`n"
        . "Pos:`t" r "  " X ", " Y ", " W ", " H "`n`n"
        . "Result:`t" (k ? "Found " k.MaxIndex() :"Failed !") , 3
      for i,v in k
        if i<=4
          MouseTip(v.1+v.3//2, v.2+v.4//2)
      k:=""
    }
  return

  ft_Exec(s)
  {
    Ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
    s:=RegExReplace(s, "\R", "`r`n")
    Try {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec(Ahk " /f /ErrorStdOut *")
      oExec.StdIn.Write(s)
      oExec.StdIn.Close()
    }
    catch {
      f:=A_Temp "\~test1.tmp", s:="`r`n FileDelete, " f "`r`n" s
      FileDelete, %f%
      FileAppend, %s%, %f%
      Run, %Ahk% /f "%f%",, UseErrorLevel
    }
  }

  ft_MakeCaptureWindow:
    ft_WindowColor:="0xCCDDEE"
    Gui, ft_Capture:Default
    Gui, +LastFound +AlwaysOnTop +ToolWindow
    Gui, Margin, 15, 15
    Gui, Color, %ft_WindowColor%
    Gui, Font, s14, Verdana
    Gui, -Theme
    w:=800//ft_nW, h:=(A_ScreenHeight-300)//ft_nH, w:=h<w ? h-1:w-1
    Loop, % ft_nW*(ft_nH) {
      i:=A_Index, j:=i=1 ? "" : Mod(i,ft_nW)=1 ? "xm y+1" : "x+1"
      j.=i>ft_nW*ft_nH ? " cRed BackgroundFFFFAA":""
      Gui, Add, Progress, w%w% h%w% %j%
    }
    WinGet, s, ControlListHwnd
    ft_C_:=StrSplit(s,"`n"), s:=""
    Loop, % ft_nW*(ft_nH+1)
      Control, ExStyle, -0x20000,, % "ahk_id " ft_C_[A_Index]
    Gui, +Theme
    Gui, Add, Button, xm+95  w45 gft_Run, U
    Gui, Add, Button, x+0    wp gft_Run, U3
    ;--------------
    Gui, Add, Text,   x+42 yp+3 Section, Gray
    Gui, Add, Edit,   x+3 yp-3 w60 vft_SelGray ReadOnly
    Gui, Add, Text,   x+15 ys, Color
    Gui, Add, Edit,   x+3 yp-3 w120 vft_SelColor ReadOnly
    Gui, Add, Text,   x+15 ys, R
    Gui, Add, Edit,   x+3 yp-3 w60 vft_SelR ReadOnly
    Gui, Add, Text,   x+5 ys, G
    Gui, Add, Edit,   x+3 yp-3 w60 vft_SelG ReadOnly
    Gui, Add, Text,   x+5 ys, B
    Gui, Add, Edit,   x+3 yp-3 w60 vft_SelB ReadOnly
    ;--------------
    Gui, Add, Button, xm     w45 gft_Run, L
    Gui, Add, Button, x+0    wp gft_Run, L3
    Gui, Add, Button, x+15   w70 gft_Run, Auto
    Gui, Add, Button, x+15   w45 gft_Run, R
    Gui, Add, Button, x+0    wp gft_Run Section, R3
    Gui, Add, Button, xm+95  w45 gft_Run, D
    Gui, Add, Button, x+0    wp gft_Run, D3
    ;------------------
    Gui, Add, Tab3,   ys-8 -Wrap, Gray|GrayDiff|Color||ColorPos|ColorDiff
    Gui, Tab, 1
    Gui, Add, Text,   x+15 y+15, Gray Threshold
    Gui, Add, Edit,   x+15 w100 vft_Threshold
    Gui, Add, Button, x+15 yp-3 gft_Run Default, Gray2Two
    Gui, Tab, 2
    Gui, Add, Text,   x+15 y+15, Gray Difference
    Gui, Add, Edit,   x+15 w100 vft_GrayDiff, 50
    Gui, Add, Button, x+15 yp-3 gft_Run, GrayDiff2Two
    Gui, Tab, 3
    Gui, Add, Text,   x+15 y+15, Similarity 0
    Gui, Add, Slider
      , x+0 w100 vft_Similar gft_Run Page1 NoTicks ToolTip Center, 98
    Gui, Add, Text,   x+0, 100
    Gui, Add, Button, x+15 yp-3 gft_Run, Color2Two
    Gui, Tab, 4
    Gui, Add, Text,   x+15 y+15, Similarity 0
    Gui, Add, Slider
      , x+0 w100 vft_Similar2 gft_Run Page1 NoTicks ToolTip Center, 98
    Gui, Add, Text,   x+0, 100
    Gui, Add, Button, x+15 yp-3 gft_Run, ColorPos2Two
    Gui, Tab, 5
    Gui, Add, Text,   x+15 y+15, R
    Gui, Add, Edit,   x+3 w70 vft_DiffR Limit3
    Gui, Add, UpDown, vft_dR Range0-255
    Gui, Add, Text,   x+10, G
    Gui, Add, Edit,   x+3 w70 vft_DiffG Limit3
    Gui, Add, UpDown, vft_dG Range0-255
    Gui, Add, Text,   x+10, B
    Gui, Add, Edit,   x+3 w70 vft_DiffB Limit3
    Gui, Add, UpDown, vft_dB Range0-255
    Gui, Add, Button, x+12 yp-3 gft_Run, ColorDiff2Two
    Gui, Tab
    ;------------------
    Gui, Add, Checkbox, xm   gft_Run vft_Modify, Modify
    Gui, Add, Button, x+5    yp-3 gft_Run, Reset
    Gui, Add, Text,   x+15   yp+3, Comment
    Gui, Add, Edit,   x+5    w132 vft_Comment
    ; Gui, Add, Button, x+10   yp-3 gft_Run, SplitAdd
    ; Gui, Add, Button, x+10   gft_Run, AllAdd
    Gui, Add, Button, x+10   yp-3 w80 gft_Run, OK
    Gui, Add, Button, x+10   gft_Run, Close
    Gui, Show, Autosize Hide, Capture Image To Text
  return

  ft_Run:
    Critical
    k:=A_GuiControl
    k:= k="L" ? "LeftCut"  : k="L3" ? "LeftCut3"
      : k="R" ? "RightCut" : k="R3" ? "RightCut3"
      : k="U" ? "UpCut"    : k="U3" ? "UpCut3"
      : k="D" ? "DownCut"  : k="D3" ? "DownCut3" : k
    Gui, +OwnDialogs
    k:=InStr(k,"ft_") ? k : "ft_" k
    if IsLabel(k)
      Gosub, %k%
  return

  ft_Close:
    Gui, Cancel
    Exit
  return

  ft_Modify:
  GuiControlGet, ft_Modify
  return

  ft_Similar:
  ft_Similar2:
    ListLines, Off
    GuiControl,, % InStr(A_ThisLabel,"2")
      ? "ft_Similar":"ft_Similar2", % %A_ThisLabel%
  return

  ft_SetColor:
    c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
      : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
    SendMessage, 0x2001, 0, c,, % "ahk_id " . ft_C_[k]
  return

  ft_Reset:
    if !IsObject(ft_ascii)
      ft_ascii:=[], ft_gs:=[]
    ft_left:=ft_right:=ft_up:=ft_down:=k:=0, ft_bg:=""
    Loop, % ft_nW*ft_nH {
      ft_ascii[++k]:=1, c:=ft_cors[k]
      ft_gs[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
      Gosub, ft_SetColor
    }
    Loop, % ft_cors.LeftCut
      Gosub, ft_LeftCut
    Loop, % ft_cors.RightCut
      Gosub, ft_RightCut
    Loop, % ft_cors.UpCut
      Gosub, ft_UpCut
    Loop, % ft_cors.DownCut
      Gosub, ft_DownCut
  return

  ft_Gray2Two:
    GuiControl, Focus, ft_Threshold
    GuiControlGet, ft_Threshold
    if (ft_Threshold="")
    {
      ft_pp:=[]
      Loop, 256
        ft_pp[A_Index-1]:=0
      Loop, % ft_nW*ft_nH
        if (ft_ascii[A_Index]!="")
          ft_pp[ft_gs[A_Index]]++
      ft_Threshold:=ft_GetThreshold(ft_pp)
      GuiControl,, ft_Threshold, %ft_Threshold%
    }
    ft_Threshold:=Round(ft_Threshold)
    ft_color:="*" ft_Threshold, k:=i:=0
    Loop, % ft_nW*ft_nH {
      if (ft_ascii[++k]="")
        Continue
      if (ft_gs[k]<=ft_Threshold)
        ft_ascii[k]:="0", c:="Black", i++
      else
        ft_ascii[k]:="_", c:="White", i--
      Gosub, ft_SetColor
    }
    ft_bg:=i>0 ? "0":"_"
  return

  ft_GetThreshold(pp)
  {
    IP:=IS:=0
    Loop, 256
      k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
    NewThreshold:=Floor(IP/IS)
    Loop, 20 {
      Threshold:=NewThreshold
      IP1:=IS1:=0
      Loop, % Threshold+1
        k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
      IP2:=IP-IP1, IS2:=IS-IS1
      if (IS1!=0 and IS2!=0)
        NewThreshold:=Floor((IP1/IS1+IP2/IS2)/2)
      if (NewThreshold=Threshold)
        Break
    }
    return, NewThreshold
  }

  ft_GrayDiff2Two:
    GuiControlGet, ft_GrayDiff
    if (ft_GrayDiff="")
    {
      MsgBox, 4096, Tip
        , `n  Please Set Gray Difference First !  `n, 1
      Return
    }
    if (ft_left=ft_cors.LeftCut)
      Gosub, ft_LeftCut
    if (ft_right=ft_cors.RightCut)
      Gosub, ft_RightCut
    if (ft_up=ft_cors.UpCut)
      Gosub, ft_UpCut
    if (ft_down=ft_cors.DownCut)
      Gosub, ft_DownCut
    ft_GrayDiff:=Round(ft_GrayDiff)
    ft_color:="**" ft_GrayDiff, k:=i:=0, n:=ft_nW
    Loop, % ft_nW*ft_nH {
      if (ft_ascii[++k]="")
        Continue
      j:=ft_gs[k]+ft_GrayDiff
      if ( ft_gs[k-1]>j   or ft_gs[k+1]>j
        or ft_gs[k-n]>j   or ft_gs[k+n]>j
        or ft_gs[k-n-1]>j or ft_gs[k-n+1]>j
        or ft_gs[k+n-1]>j or ft_gs[k+n+1]>j )
          ft_ascii[k]:="0", c:="Black", i++
      else
        ft_ascii[k]:="_", c:="White", i--
      Gosub, ft_SetColor
    }
    ft_bg:=i>0 ? "0":"_"
  return

  ft_Color2Two:
  ft_ColorPos2Two:
    GuiControlGet, c,, ft_SelColor
    if (c="")
    {
      MsgBox, 4096, Tip
        , `n  Please Select a Color First !  `n, 1
      return
    }
    ft_UsePos:=InStr(A_ThisLabel,"ColorPos2Two") ? 1:0
    GuiControlGet, n,, ft_Similar
    n:=Round(n/100,2), ft_color:=c "@" n
    n:=Floor(9*255*255*(1-n)*(1-n)), k:=i:=0
    ft_rr:=(c>>16)&0xFF, ft_gg:=(c>>8)&0xFF, ft_bb:=c&0xFF
    Loop, % ft_nW*ft_nH {
      if (ft_ascii[++k]="")
        Continue
      c:=ft_cors[k], r:=((c>>16)&0xFF)-ft_rr
        , g:=((c>>8)&0xFF)-ft_gg, b:=(c&0xFF)-ft_bb
      if (3*r*r+4*g*g+2*b*b<=n)
        ft_ascii[k]:="0", c:="Black", i++
      else
        ft_ascii[k]:="_", c:="White", i--
      Gosub, ft_SetColor
    }
    ft_bg:=i>0 ? "0":"_"
  return

  ft_ColorDiff2Two:
    GuiControlGet, c,, ft_SelColor
    if (c="")
    {
      MsgBox, 4096, Tip
        , `n  Please Select a Color First !  `n, 1
      return
    }
    GuiControlGet, ft_dR
    GuiControlGet, ft_dG
    GuiControlGet, ft_dB
    ft_rr:=(c>>16)&0xFF, ft_gg:=(c>>8)&0xFF, ft_bb:=c&0xFF
    n:=Format("{:06X}",(ft_dR<<16)|(ft_dG<<8)|ft_dB)
    ft_color:=StrReplace(c "-" n,"0x"), k:=i:=0
    Loop, % ft_nW*ft_nH {
      if (ft_ascii[++k]="")
        Continue
      c:=ft_cors[k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
      if ( Abs(r-ft_rr)<=ft_dR
        and Abs(g-ft_gg)<=ft_dG
        and Abs(b-ft_bb)<=ft_dB )
          ft_ascii[k]:="0", c:="Black", i++
      else
        ft_ascii[k]:="_", c:="White", i--
      Gosub, ft_SetColor
    }
    ft_bg:=i>0 ? "0":"_"
  return

  ft_gui_del:
    ft_ascii[k]:="", c:=ft_WindowColor
    Gosub, ft_SetColor
  return

  ft_LeftCut3:
    Loop, 3
      Gosub, ft_LeftCut
  return

  ft_LeftCut:
    if (ft_left+ft_right>=ft_nW)
      return
    ft_left++, k:=ft_left
    Loop, %ft_nH% {
      Gosub, ft_gui_del
      k+=ft_nW
    }
  return

  ft_RightCut3:
    Loop, 3
      Gosub, ft_RightCut
  return

  ft_RightCut:
    if (ft_left+ft_right>=ft_nW)
      return
    ft_right++, k:=ft_nW+1-ft_right
    Loop, %ft_nH% {
      Gosub, ft_gui_del
      k+=ft_nW
    }
  return

  ft_UpCut3:
    Loop, 3
      Gosub, ft_UpCut
  return

  ft_UpCut:
    if (ft_up+ft_down>=ft_nH)
      return
    ft_up++, k:=(ft_up-1)*ft_nW
    Loop, %ft_nW% {
      k++
      Gosub, ft_gui_del
    }
  return

  ft_DownCut3:
    Loop, 3
      Gosub, ft_DownCut
  return

  ft_DownCut:
    if (ft_up+ft_down>=ft_nH)
      return
    ft_down++, k:=(ft_nH-ft_down)*ft_nW
    Loop, %ft_nW% {
      k++
      Gosub, ft_gui_del
    }
  return

  ft_getwz:
    ft_wz:=""
    if (ft_bg="")
      return
    k:=0
    Loop, %ft_nH% {
      v:=""
      Loop, %ft_nW%
        v.=ft_ascii[++k]
      ft_wz.=v="" ? "" : v "`n"
    }
  return

  ft_Auto:
    Gosub, ft_getwz
    if (ft_wz="")
    {
      MsgBox, 4096, Tip
        , `nPlease Click Color2Two or Gray2Two First !, 1
      return
    }
    While InStr(ft_wz, ft_bg) {
      if (ft_wz~="^" ft_bg "+\n")
      {
        ft_wz:=RegExReplace(ft_wz,"^" ft_bg "+\n")
        Gosub, ft_UpCut
      }
      else if !(ft_wz~="m`n)[^\n" ft_bg "]$")
      {
        ft_wz:=RegExReplace(ft_wz,"m`n)" ft_bg "$")
        Gosub, ft_RightCut
      }
      else if (ft_wz~="\n" ft_bg "+\n$")
      {
        ft_wz:=RegExReplace(ft_wz,"\n\K" ft_bg "+\n$")
        Gosub, ft_DownCut
      }
      else if !(ft_wz~="m`n)^[^\n" ft_bg "]")
      {
        ft_wz:=RegExReplace(ft_wz,"m`n)^" ft_bg)
        Gosub, ft_LeftCut
      }
      else Break
    }
    ft_wz:=""
  return

  ft_OK:
  ft_AllAdd:
  ft_SplitAdd:
    Gosub, ft_getwz
    if ft_wz=
    {
      MsgBox, 4096, Tip
        , `nPlease Click Color2Two or Gray2Two First !, 1
      return
    }
    if InStr(ft_color,"@") and (ft_UsePos)
    {
      StringSplit, r, ft_color, @
      k:=i:=j:=0
      Loop, % ft_nW*ft_nH {
        if (ft_ascii[++k]="")
          Continue
        i++
        if (k=ft_cors.SelPos)
        {
          j:=i
          Break
        }
      }
      if (j=0)
      {
        MsgBox, 4096, Tip
          , Please select the core color again !, 3
        return
      }
      ft_color:="#" . j . "@" . r2
    }
    GuiControlGet, ft_Comment
    ft_cors.Event:=A_ThisLabel
    if InStr(A_ThisLabel, "SplitAdd")
    {
      if InStr(ft_color,"#")
      {
        MsgBox, 4096, Tip
          , % "Can't be used in ColorPos mode, "
          . "because it can cause position errors", 3
        return
      }
      SetFormat, IntegerFast, d
      ft_bg:=StrLen(StrReplace(ft_wz,"_"))
        > StrLen(StrReplace(ft_wz,"0")) ? "0":"_"
      s:="", k:=ft_nW*ft_nH+1+ft_left
        , i:=0, w:=ft_nW-ft_left-ft_right
      Loop, % w {
        i++
        GuiControlGet, j,, % ft_C_[k++]
        if (j=0 and A_Index<w)
          Continue
        v:=RegExReplace(ft_wz,"m`n)^(.{" i "}).*","$1")
        ft_wz:=RegExReplace(ft_wz,"m`n)^.{" i "}"), i:=0
        While InStr(v, ft_bg) {
          if (v~="^" ft_bg "+\n")
            v:=RegExReplace(v,"^" ft_bg "+\n")
          else if !(v~="m`n)[^\n" ft_bg "]$")
            v:=RegExReplace(v,"m`n)" ft_bg "$")
          else if (v~="\n" ft_bg "+\n$")
            v:=RegExReplace(v,"\n\K" ft_bg "+\n$")
          else if !(v~="m`n)^[^\n" ft_bg "]")
            v:=RegExReplace(v,"m`n)^" ft_bg)
          else Break
        }
        if v!=
          s.=ft_towz(ft_color, v, SubStr(ft_Comment,1,1))
        ft_Comment:=SubStr(ft_Comment, 2)
      }
      ft_cors.Result:=s
      Gui, Hide
      return
    }
    s:=ft_towz(ft_color, ft_wz, ft_Comment)
    if InStr(A_ThisLabel, "AllAdd")
    {
      ft_cors.Result:=s
      Gui, Hide
      return
    }
    x:=ft_px-ft_ww+ft_left+(ft_nW-ft_left-ft_right)//2
    y:=ft_py-ft_hh+ft_up+(ft_nH-ft_up-ft_down)//2
    s:=StrReplace(s, "Text.=", "Text:=")
    Global ExportString := s
    s=
    (
    ;Sample Code
    t1:=A_TickCount

    %s%

    if (ok:=FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, Text))
    {
      CoordMode, Mouse
      X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
      ; Click, `%X`%, `%Y`%
    }
    MsgBox, 4096, `% ok.MaxIndex(), `% "Time:``t" (A_TickCount-t1) " ms``n``n"
      . "Pos:``t[%x%, %y%]  " X ", " Y "``n``n"
      . "Result:``t" (ok ? "Success ! " Comment : "Failed !")

    for i,v in ok
      if i<=2
        MouseTip(v.1+v.3//2, v.2+v.4//2)

    )
    ft_cors.Result:=s
    Gui, Hide
  return

  ft_towz(color,wz,comment="")
  {
    SetFormat, IntegerFast, d
    wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
    wz:=(InStr(wz,"`n")-1) "." bit2base64(wz)
    return, "Text.=""|<" comment ">" color "$" wz """"
  }

  ft_add(s, rn=1)
  {
    global ft_hscr
    if (rn=1)
      s:="`n" s "`n"
    ; s:=RegExReplace(s,"\N","")
    ; s:=RegExReplace(s,"\R","")
    s:=RegExReplace(s,"\R","`r`n")
    ControlGet, i, CurrentCol,,, ahk_id %ft_hscr%
    if i>1
      ControlSend,, {Home}{Down}, ahk_id %ft_hscr%
    Control, EditPaste, %s%,, ahk_id %ft_hscr%
  }

  ft_End:
  Trim("")

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
            Feet := Floor(Decimal), Decimal -= Feet, Inches := Floor(Decimal * 12), Decimal := Decimal * 12 - Inches
        if !(Options ~= "i)I")
            Whole := Floor(Decimal), Decimal -= Whole
        RegExMatch(Decimal,"^(\d*)\.?(\d*?)0*$",Match), N := Match1 Match2
        D := 10 ** StrLen(Match2)
        if Precision
            N := Round(N / D * Precision), D := Precision
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

/** * Class_CtlColors
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
            VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
            NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
            DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
            Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
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

/** * Functions to Monitor File Changes
 *     Found on page: https://autohotkey.com/board/topic/6416-tail-the-last-lines-of-a-text-file/
 * Version:
 *     v1.0.0 [updated 09/24/2019 (MM/DD/YYYY)]
 */
    ; str_getTailf - Return the last line from a file
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    str_getTailf(ByRef _Str) {
        Return SubStr(_Str,InStr(_Str,"`n",False,0)+1)
    }
    ; str_getTail - Return the last n lines from a file
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    str_getTail(_Str, _LineNum = 1)
    {
        StringGetPos, Pos, _Str, `n, R%_LineNum%
        StringTrimLeft, _Str, _Str, % ++Pos
        Return _Str
    }
    ; FileCheck - Checks for changes in file size
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FileCheck(file){
        Static Size0
        FileGetSize Size, file
        If Size0 >= %Size%
            Return False
        If Size0 =
        {
            Size0 = %Size%
            Return False
        }
        Size0 = %Size% ; File size increased!
    Return True
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * DaysSince - Function to determine the time in days between two dates
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

/** * Function to Replace Nth instance of Needle in Haystack
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
 
/** * PoE Click v1.0.1 : PoE Click Lib for AutoHotkey.
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
            Random, Rx, x+10, x+40
            Random, Ry, y-40, y-10
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

/** * Array functions v1.0.0 : Index matching.
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
                }else if (CompareHex(h1, h2, vary)){
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

/** * Lib from LutBot : Extracted from lite version
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
                    id := NumGet(a, A_Index * 4, "UInt")
                    
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
                    error("ED11",num,l,executable)
                    return False
                }
                
                out := 0
                Loop %num%
                {
                    cutby := a_index - 1
                    cutby *= 24
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
                                error("TCP" . result,out,result,l,executable)
                                return False
                            }
                            out++
                        }
                    }
                }
                if ( out = 0 ) {
                    error("ED10",out,l,executable)
                    return False
                } else {
                    error(l . ":" . A_TickCount - start,out,l,executable)
                }
            } 
            catch e
            {
                error("ED14","catcherror",e)
                return False
            }
            
        return True
        }

    ; Error capture from LutLogout to error.txt
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    error(var,var2:="",var3:="",var4:="",var5:="",var6:="",var7:="") {
        GuiControl,1:, guiErr, %var%
        print := A_Now . "," . var . "," . var2 . "," . var3 . "," . var4 . "," . var5 . "," . var6 . "," . var7 . "`n"
        FileAppend, %print%, error.txt, UTF-16
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

/** * RandomSleep Timers: 
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

/** * Ding Debug tooltip message : WingMan
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
                            ToolTip, %mval%, 100, % 50 + MultiTooltip * 23, %MultiTooltip% 
                        Else
                            debugStr .= Message.A_Index
                    }
                    Else if A_Index <= 20
                    {
                        If MultiTooltip
                            ToolTip, %mval%, 100, % 50 + A_Index * 23, %A_Index% 
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
                    ToolTip, Ding, 100, % 50 + MultiTooltip * 23, %MultiTooltip% 
                Else
                    Tooltip, Ding
            }
        }
        If Timeout
            SetTimer, RemoveTooltip, %Timeout%
        Return
    }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * Clamp value 
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

/** * hex color tools: extract R G B elements from BGR or RGB hex, convert RGB <> BGR, or compare extracted RGB values against another color. 
 * Lib: ColorTools.ahk
 *     ToRGBfromBGR function
 *     ToRGB function
 *     hexBGRToRGB function
 *     CompareHex function
 */

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
    CompareHex(c1, c2, vary:=1) {
        rdiff := Abs( c1.r - c2.r )
        gdiff := Abs( c1.g - c2.g )
        bdiff := Abs( c1.b - c2.b )

        return rdiff <= vary && gdiff <= vary && bdiff <= vary
        }

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * Rescale : Resolution scaling for pixel locations taken at a sample resolution.
    */
    ; Rescale - Rescales values of the script to the user's resolution
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Rescale(){
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
					;Status Check OnHideout
					global vX_OnHideout:=GameX + Round(GameW / (1920 / 1178))
					global vY_OnHideout:=GameY + Round(GameH / (1080 / 930))
					global vY_OnHideoutMin:=GameY + Round(GameH / (1080 / 1053))
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
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar * (ManaThreshold / 100))
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
					;Status Check OnHideout
					global vX_OnHideout:=GameX + Round(GameW / (1440 / 698))
					global vY_OnHideout:=GameY + Round(GameH / (1080 / 930))
					global vY_OnHideoutMin:=GameY + Round(GameH / (1080 / 1053))
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
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar * (ManaThreshold / 100))
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
                    ;Status Check OnHideout
                    global vX_OnHideout:=GameX + Round(GameW / (2560 / 1887))
                    global vY_OnHideout:=GameY + Round(GameH / (1080 / 930))
                    global vY_OnHideoutMin:=GameY + Round(GameH / (1080 / 1053))
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
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar * (ManaThreshold / 100))
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
					;Status Check OnHideout
					global vX_OnHideout:=GameX + Round(GameW / (3840 / 3098))
					global vY_OnHideout:=GameY + Round(GameH / (1080 / 930))
					global vY_OnHideoutMin:=GameY + Round(GameH / (1080 / 1053))
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
                    Global vY_ManaThreshold:=vY_Mana10 - Round(vH_ManaBar * (ManaThreshold / 100))
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
                Global ScrCenter := { "X" : GameX + Round(GameW / 2) , "Y" : GameY + Round(GameH / 2) }
				RescaleRan := True
                Global GameWindow := {"X" : GameX, "Y" : GameY, "W" : GameW, "H" : GameH, "BBarY" : (GameY + (GameH / (1080 / 75))) }
			}
		return
		}


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * tooltip management
 */
  ; OLD Tooltip Management
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ; WM_MOUSEMOVE(){
  ; 		static CurrControl, PrevControl, _TT
  ; 		CurrControl := A_GuiControl
  ; 		If (CurrControl <> PrevControl and not InStr(CurrControl, " ")){
  ; 			SetTimer, DisplayToolTip, -300 	; shorter wait, shows the tooltip quicker
  ; 			PrevControl := CurrControl
  ; 		}
  ; 	return
  
  ; 	DisplayToolTip:
  ; 		try
  ; 		ToolTip % %CurrControl%_TT
  ; 		catch
  ; 		ToolTip
  ; 		SetTimer, RemoveToolTip, -10000
  ; 	return
  ; 	return
  ; 	}
  
  RemoveToolTip:
  	SetTimer, RemoveToolTip, Off
      Loop, 20
  	    ToolTip,,,,%A_Index%
  return

  ft_ShowToolTip()
  {
    ListLines, Off
    global ft_ToolTip_Text
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

/** * Chat functions : ResetChat and GrabRecipientName
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

/** * API scraper for PoE.Ninja : Pulls all the information into one database file
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

/** * API scraper for Path of Exile Leagues
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

/** * Cooldown Timers
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

/** * Overhead Healthbar detection and a method to get health percent
 */
    CheckOHB()
    {
        Global GameStr, HealthBarStr, OHB, OHBLHealthHex, OHBLESHex, OHBLEBHex
        If WinActive(GameStr)
        {
            WinGetPos, GameX, GameY, GameW, GameH
            if (ok:=FindText(GameX, GameY, GameW, Round(GameH/2), 0, 0, HealthBarStr))
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
                OHB["pX"] := { 1 : Round(ok.1.1 + (ok.1.3 * 0.10))
                    , 2 : Round(ok.1.1 + (ok.1.3 * 0.20))
                    , 3 : Round(ok.1.1 + (ok.1.3 * 0.30))
                    , 4 : Round(ok.1.1 + (ok.1.3 * 0.40))
                    , 5 : Round(ok.1.1 + (ok.1.3 * 0.50))
                    , 6 : Round(ok.1.1 + (ok.1.3 * 0.60))
                    , 7 : Round(ok.1.1 + (ok.1.3 * 0.70))
                    , 8 : Round(ok.1.1 + (ok.1.3 * 0.80))
                    , 9 : Round(ok.1.1 + (ok.1.3 * 0.90))
                    , 10 : Round(ok.1.1 + ok.1.3) }
                If !OHBLHealthHex
                    PixelGetColor, OHBLHealthHex, % OHB.X + 1, % OHB.hpY, RGB
                If (!OHBLESHex && (RadioHybrid || RadioCi) && !YesEldritchBattery)
                    PixelGetColor, OHBLESHex, % OHB.X + 1, % OHB.esY, RGB
                Else If (!OHBLEBHex && (RadioHybrid || RadioCi) && YesEldritchBattery)
                    PixelGetColor, OHBLEBHex, % OHB.X + 1, % OHB.ebY, RGB
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
        Global OHB
        Found := OHB.X
        Loop 10
        {
            PixelSearch, pX, pY, % OHB.pX[A_Index], % PosY, % OHB.pX[A_Index], % PosY, %CID%, %Variance%, RGB Fast
            If ErrorLevel = 0
                Found := pX
            Else 
            {
                Break
            }
        }
        PixelGetColor, checkHex, % OHB.X + 1, % OHB.hpY, RGB
        If (CheckHex != OHBLHealthHex)
            Exit
        Else
            Return Round(100 * (1 - ( (OHB.rX - Found) / OHB.W ) ) )
    }
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
