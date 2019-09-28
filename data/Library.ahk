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

/** * Functions to Monitor File Changes
 * Lib: PoEClick.ahk
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
 
/** * PoE Click v1.0.0 : PoE Click Lib for AutoHotkey.
 * Lib: PoEClick.ahk
 *     Path of Exile Click functions for AutoHotkey.
 *     Developed by Bandit
 * Version:
 *     v1.0.0 [updated 09/24/2019 (MM/DD/YYYY)]
 */

    ; SwiftClick - Left Click at Coord
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SwiftClick(x, y){
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

/** * Send message to other scripts: Pulled from AutoHotkey wiki
 * Lib: SendMSG.ahk
 *     Send up to two digits as a message
 *     Requires additional lines to function
 * Version:
 *     v1.0.0
 */

    ; Send one or two digits to a sub-script 
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SendMSG(wParam:=0, lParam:=0, script:=""){
        DetectHiddenWindows On
        if WinExist(script) 
            PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
        else 
            MsgBox %script% . " Not found"
        DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
        Return
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
 *     v1.0.0
 */

    ; Debug messages within script
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Ding(Timeout:=500,Message:="Ding", Message2:="", Message3:="", Message4:="", Message5:="", Message6:="", Message7:="" ){
        If (!DebugMessages)
            Return
        Else If (DebugMessages){
            debugStr:=Message
            If (Message2!=""){
                debugStr.="`n"
                debugStr.=Message2
                }
            If (Message3!=""){
                debugStr.="`n"
                debugStr.=Message3
                }
            If (Message4!=""){
                debugStr.="`n"
                debugStr.=Message4
                }
            If (Message5!=""){
                debugStr.="`n"
                debugStr.=Message5
                }
            If (Message6!=""){
                debugStr.="`n"
                debugStr.=Message6
                }
            If (Message7!=""){
                debugStr.="`n"
                debugStr.=Message7
                }
            Tooltip, %debugStr%
            }
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

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * Compare Hex color code within variation
 * Lib: Util.ahk
 *     ToRGB function
 *     CompareHex function
 */

    ; Converts a hex color into its R G B elements
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ToRGB(color) {
        return { "b": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "r": color & 0xFF }
        }

    ; Compares two converted HEX codes as R G B within the variance range
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
				WinGetPos, X, Y, W, H
				If (ResolutionScale="Standard") {
					; Item Inventory Grid
					Global InventoryGridX := [ Round(A_ScreenWidth/(1920/1274)), Round(A_ScreenWidth/(1920/1326)), Round(A_ScreenWidth/(1920/1379)), Round(A_ScreenWidth/(1920/1432)), Round(A_ScreenWidth/(1920/1484)), Round(A_ScreenWidth/(1920/1537)), Round(A_ScreenWidth/(1920/1590)), Round(A_ScreenWidth/(1920/1642)), Round(A_ScreenWidth/(1920/1695)), Round(A_ScreenWidth/(1920/1748)), Round(A_ScreenWidth/(1920/1800)), Round(A_ScreenWidth/(1920/1853)) ]
					Global InventoryGridY := [ Round(A_ScreenHeight/(1080/638)), Round(A_ScreenHeight/(1080/690)), Round(A_ScreenHeight/(1080/743)), Round(A_ScreenHeight/(1080/796)), Round(A_ScreenHeight/(1080/848)) ]  
					;Detonate Mines
					Global DetonateDelveX:=X + Round(A_ScreenWidth/(1920/1542))
					Global DetonateX:=X + Round(A_ScreenWidth/(1920/1658))
					Global DetonateY:=Y + Round(A_ScreenHeight/(1080/901))
					;Scrolls in currency tab
					Global WisdomStockX:=X + Round(A_ScreenWidth/(1920/125))
					Global PortalStockX:=X + Round(A_ScreenWidth/(1920/175))
					Global WPStockY:=Y + Round(A_ScreenHeight/(1080/262))
					;Status Check OnHideout
					global vX_OnHideout:=X + Round(A_ScreenWidth / (1920 / 1178))
					global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 930))
					global vY_OnHideoutMin:=Y + Round(A_ScreenHeight / (1080 / 1053))
					;Status Check OnMenu
					global vX_OnMenu:=X + Round(A_ScreenWidth / 2)
					global vY_OnMenu:=Y + Round(A_ScreenHeight / (1080 / 54))
					;Status Check OnChar
					global vX_OnChar:=X + Round(A_ScreenWidth / (1920 / 41))
					global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1080 / 915))
					;Status Check OnChat
					global vX_OnChat:=X + Round(A_ScreenWidth / (1920 / 0))
					global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1080 / 653))
					;Status Check OnInventory
					global vX_OnInventory:=X + Round(A_ScreenWidth / (1920 / 1583))
					global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
					;Status Check OnStash
					global vX_OnStash:=X + Round(A_ScreenWidth / (1920 / 336))
					global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
					;Status Check OnVendor
					global vX_OnVendor:=X + Round(A_ScreenWidth / (1920 / 618))
					global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1080 / 88))
					;Status Check OnDiv
					global vX_OnDiv:=X + Round(A_ScreenWidth / (1920 / 618))
					global vY_OnDiv:=Y + Round(A_ScreenHeight / ( 1080 / 135))
					;Life %'s
					global vX_Life:=X + Round(A_ScreenWidth / (1920 / 95))
					global vY_Life20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_Life30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_Life40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_Life50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_Life60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_Life70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_Life80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_Life90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;ES %'s
					global vX_ES:=X + Round(A_ScreenWidth / (1920 / 180))
					global vY_ES20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_ES30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_ES40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_ES50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_ES60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_ES70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_ES80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_ES90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;Mana
					global vX_Mana:=X + Round(A_ScreenWidth / (1920 / 1825))
					global vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
					;GUI overlay
					global GuiX:=X + Round(A_ScreenWidth / (1920 / -10))
					global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
					;Divination Y locations
					Global vY_DivTrade:=Y + Round(A_ScreenHeight / (1080 / 736))
					Global vY_DivItem:=Y + Round(A_ScreenHeight / (1080 / 605))
					;Stash tabs menu button
					global vX_StashTabMenu := X + Round(A_ScreenWidth / (1920 / 640))
					global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
					;Stash tabs menu list
					global vX_StashTabList := X + Round(A_ScreenWidth / (1920 / 706))
					global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1080 / 120))
					;calculate the height of each tab
					global vY_StashTabSize := Round(A_ScreenHeight / ( 1080 / 22))
				}
				Else If (ResolutionScale="UltraWide") {
					; Item Inventory Grid
					Global InventoryGridX := [ Round(A_ScreenWidth/(3840/3193)), Round(A_ScreenWidth/(3840/3246)), Round(A_ScreenWidth/(3840/3299)), Round(A_ScreenWidth/(3840/3352)), Round(A_ScreenWidth/(3840/3404)), Round(A_ScreenWidth/(3840/3457)), Round(A_ScreenWidth/(3840/3510)), Round(A_ScreenWidth/(3840/3562)), Round(A_ScreenWidth/(3840/3615)), Round(A_ScreenWidth/(3840/3668)), Round(A_ScreenWidth/(3840/3720)), Round(A_ScreenWidth/(3840/3773)) ]
					Global InventoryGridY := [ Round(A_ScreenHeight/(1080/638)), Round(A_ScreenHeight/(1080/690)), Round(A_ScreenHeight/(1080/743)), Round(A_ScreenHeight/(1080/796)), Round(A_ScreenHeight/(1080/848)) ]  
					;Detonate Mines
					Global DetonateDelveX:=X + Round(A_ScreenWidth/(3840/3462))
					Global DetonateX:=X + Round(A_ScreenWidth/(3840/3578))
					Global DetonateY:=Y + Round(A_ScreenHeight/(1080/901))
					;Scrolls in currency tab
					Global WisdomStockX:=X + Round(A_ScreenWidth/(3840/125))
					Global PortalStockX:=X + Round(A_ScreenWidth/(3840/175))
					Global WPStockY:=Y + Round(A_ScreenHeight/(1080/262))
					;Status Check OnHideout
					global vX_OnHideout:=X + Round(A_ScreenWidth / (3840 / 3098))
					global vY_OnHideout:=Y + Round(A_ScreenHeight / (1080 / 930))
					global vY_OnHideoutMin:=Y + Round(A_ScreenHeight / (1080 / 1053))
					;Status Check OnMenu
					global vX_OnMenu:=X + Round(A_ScreenWidth / 2)
					global vY_OnMenu:=Y + Round(A_ScreenHeight / (1080 / 54))
					;Status Check OnChar
					global vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
					global vY_OnChar:=Y + Round(A_ScreenHeight / ( 1080 / 915))
					;Status Check OnChat
					global vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
					global vY_OnChat:=Y + Round(A_ScreenHeight / ( 1080 / 653))
					;Status Check OnInventory
					global vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
					global vY_OnInventory:=Y + Round(A_ScreenHeight / ( 1080 / 36))
					;Status Check OnStash
					global vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
					global vY_OnStash:=Y + Round(A_ScreenHeight / ( 1080 / 32))
					;Status Check OnVendor
					global vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
					global vY_OnVendor:=Y + Round(A_ScreenHeight / ( 1080 / 88))
					;Status Check OnDiv
					global vX_OnDiv:=X + Round(A_ScreenWidth / (3840 / 1578))
					global vY_OnDiv:=Y + Round(A_ScreenHeight / ( 1080 / 135))
					;Life %'s
					global vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
					global vY_Life20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_Life30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_Life40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_Life50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_Life60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_Life70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_Life80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_Life90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;ES %'s
					global vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
					global vY_ES20:=Y + Round(A_ScreenHeight / ( 1080 / 1034))
					global vY_ES30:=Y + Round(A_ScreenHeight / ( 1080 / 1014))
					global vY_ES40:=Y + Round(A_ScreenHeight / ( 1080 / 994))
					global vY_ES50:=Y + Round(A_ScreenHeight / ( 1080 / 974))
					global vY_ES60:=Y + Round(A_ScreenHeight / ( 1080 / 954))
					global vY_ES70:=Y + Round(A_ScreenHeight / ( 1080 / 934))
					global vY_ES80:=Y + Round(A_ScreenHeight / ( 1080 / 914))
					global vY_ES90:=Y + Round(A_ScreenHeight / ( 1080 / 894))
					;Mana
					global vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
					global vY_Mana10:=Y + Round(A_ScreenHeight / (1080 / 1054))
					;GUI overlay
					global GuiX:=X + Round(A_ScreenWidth / (3840 / -10))
					global GuiY:=Y + Round(A_ScreenHeight / (1080 / 1027))
					;Divination Y locations
					Global vY_DivTrade:=Y + Round(A_ScreenHeight / (1080 / 736))
					Global vY_DivItem:=Y + Round(A_ScreenHeight / (1080 / 605))
					;Stash tabs menu button
					global vX_StashTabMenu := X + Round(A_ScreenWidth / (3840 / 640))
					global vY_StashTabMenu := Y + Round(A_ScreenHeight / ( 1080 / 146))
					;Stash tabs menu list
					global vX_StashTabList := X + Round(A_ScreenWidth / (3840 / 706))
					global vY_StashTabList := Y + Round(A_ScreenHeight / ( 1080 / 120))
					;calculate the height of each tab
					global vY_StashTabSize := Round(A_ScreenHeight / ( 1080 / 22))
				} 
                Global ScrCenter := { "X" : X + Round(A_ScreenWidth / 2) , "Y" : Y + Round(A_ScreenHeight / 2) }
				RescaleRan := True
			}
		return
		}


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

/** * tooltip management
 */
    ; Tooltip Management
    ; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	WM_MOUSEMOVE(){
			static CurrControl, PrevControl, _TT
			CurrControl := A_GuiControl
			If (CurrControl <> PrevControl and not InStr(CurrControl, " ")){
				SetTimer, DisplayToolTip, -300 	; shorter wait, shows the tooltip quicker
				PrevControl := CurrControl
			}
		return

		DisplayToolTip:
			try
			ToolTip % %CurrControl%_TT
			catch
			ToolTip
			SetTimer, RemoveToolTip, -10000
		return
		return
		}

	RemoveToolTip:
		SetTimer, RemoveToolTip, Off
		ToolTip
	return

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
				Ding( ,%RecipientName%)
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
		settimer,TDetonated,delete
	return


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
