/* XGraph v1.1.1.0 : Real time data plotting.
*  Script    :  XGraph v1.1.1.0 : Real time data plotting.
*         http://ahkscript.org/boards/viewtopic.php?t=3492
*         Created: 24-Apr-2014,  Last Modified: 09-May-2014
*
*  Description :  Easy to use, Light weight, fast, efficient GDI based function library for
*         graphically plotting real time data.
*
*  Author    :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
*  Demos     :  CPU Load Monitor > http://ahkscript.org/boards/viewtopic.php?t=3413
*  Ported to AHK v2 by Claude Code
- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
*/

XGraph( hCtrl, hBM := 0, ColumnW := 3, LTRB := "0,2,0,2", PenColor := 0x808080, PenSize := 1, SV := 0 ) {
	Static WM_SETREDRAW := 0xB, STM_SETIMAGE := 0x172, PS_SOLID := 0, cbSize := 136, SRCCOPY := 0x00CC0020
		, GPTR := 0x40, OBJ_BMP := 0x7, LR_CREATEDIBSECTION := 0x2000, LR_COPYDELETEORG := 0x8

	; Validate control
	Class   := WinGetClass("ahk_id " hCtrl)
	ControlSetStyle("+0x5000010E", hCtrl)
	Style   := WinGetStyle("ahk_id " hCtrl)
	ExStyle := WinGetExStyle("ahk_id " hCtrl)
	ControlGetPos(,, &CtrlW, &CtrlH, "", "ahk_id " hCtrl)
	CtrlW := Scale_PositionFromDPI(CtrlW), CtrlH := Scale_PositionFromDPI(CtrlH)

	If not ( Class == "Static" and Style = 0x5000010E and ExStyle = 0 and CtrlW > 0 and CtrlH > 0 )
		Return 0

	; Validate Bitmap
	If ( DllCall( "GetObjectType", "Ptr",hBM ) != OBJ_BMP )
		hTargetBM := DllCall( "CreateBitmap", "Int",2, "Int",2, "UInt",1, "UInt",16, "Ptr",0, "Ptr" )
		,  hTargetBM := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",CtrlW, "Int",CtrlH
							, "UInt",LR_CREATEDIBSECTION|LR_COPYDELETEORG, "Ptr" )
	else hTargetBM := hBM

	BITMAP := Buffer(32, 0)
	DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",BITMAP )
	If NumGet( BITMAP, 18, "UInt" ) < 16 ; Checking if BPP < 16
		Return 0
	Else BitmapW := NumGet( BITMAP,  4, "UInt" ),  BitmapH := NumGet( BITMAP, 8, "UInt" )
	If ( BitmapW != CtrlW or BitmapH != CtrlH )
		Return 0

	; Validate Margins and Column width
	M := StrSplit(LTRB, ",", " ") ; Left,Top,Right,Bottom
	MarginL := ( M[1]+0 < 0 ? 0 : M[1] ),  MarginT   := ( M[2]+0 < 0 ? 0 : M[2] )
	MarginR := ( M[3]+0 < 0 ? 0 : M[3] ),  MarginB   := ( M[4]+0 < 0 ? 0 : M[4] )
	ColumnW := ( ColumnW+0 < 0 ? 3 : ColumnW & 0xff ) ; 1 - 255

	; Derive Columns, BitBlt dimensions, Movement coords for Lineto() and MoveToEx()
	Columns := ( BitmapW - MarginL - MarginR ) // ColumnW
	BitBltW := Columns* ColumnW,        BitBltH := BitmapH - MarginT - MarginB
	MX1   := BitBltW - ColumnW,          MY1 := BitBltH - 1
	MX2   := MX1 + ColumnW - ( PenSize < 1 ) ;   MY2 := < user defined >

	; Initialize Memory Bitmap
	hSourceDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
	hSourceBM  := DllCall( "CopyImage", "Ptr",hTargetBM, "UInt",0, "Int",ColumnW* 2 + BitBltW
						, "Int",BitBltH, "UInt",LR_CREATEDIBSECTION, "Ptr" )
	DllCall( "SaveDC", "Ptr",hSourceDC )
	DllCall( "SelectObject", "Ptr",hSourceDC, "Ptr",hSourceBM )

	hTempDC  := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )
	DllCall( "SaveDC", "Ptr",hTempDC )
	DllCall( "SelectObject", "Ptr",hTempDC, "Ptr",hTargetBM )

	If ( hTargetBM != hBM )
		hBrush := DllCall( "CreateSolidBrush", "UInt",hBM & 0xFFFFFF, "Ptr" )
	, RECT := Buffer(16, 0)
	, NumPut( "UInt", BitmapW, RECT, 8 ),  NumPut( "UInt", BitmapH, RECT, 12 )
	, DllCall( "FillRect", "Ptr",hTempDC, "Ptr",RECT, "Ptr",hBrush )
	, DllCall( "DeleteObject", "Ptr",hBrush )

	DllCall( "BitBlt", "Ptr",hSourceDC, "Int",ColumnW* 2, "Int",0, "Int",BitBltW, "Int",BitBltH
					, "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )
	DllCall( "BitBlt", "Ptr",hSourceDC, "Int",0, "Int",0, "Int",BitBltW, "Int",BitBltH
					, "Ptr",hTempDC,   "Int",MarginL, "Int",MarginT, "UInt",SRCCOPY )

	; Validate Pen color / Size
	PenColor   := ( PenColor + 0 != "" ? PenColor & 0xffffff : 0x808080 ) ; Range: 000000 - ffffff
	PenSize  := ( PenSize  + 0 != "" ? PenSize & 0xf : 1 )        ; Range: 0 - 15
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
	NumPut( "UInt64", DataSz, pGraph + cbSize - 8 )
	NumPut("UInt64", cbSize,     pGraph,   0)
	NumPut("UInt64", hCtrl,      pGraph,   8)
	NumPut("UInt64", hTargetDC,  pGraph,  16)
	NumPut("UInt64", hSourceDC,  pGraph,  24)
	NumPut("UInt64", hSourceBM,  pGraph,  32)
	NumPut("UInt64", hSourcePen, pGraph,  40)
	NumPut("UInt64", ColumnW,    pGraph,  48)
	NumPut("UInt64", Columns,    pGraph,  56)
	NumPut("UInt64", MarginL,    pGraph,  64)
	NumPut("UInt64", MarginT,    pGraph,  72)
	NumPut("UInt64", MarginR,    pGraph,  80)
	NumPut("UInt64", MarginB,    pGraph,  88)
	NumPut("UInt64", MX1,        pGraph,  96)
	NumPut("UInt64", MX2,        pGraph, 104)
	NumPut("UInt64", BitBltW,    pGraph, 112)
	NumPut("UInt64", BitBltH,    pGraph, 120)

	Return pGraph
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_Info( pGraph, FormatFloat := "" ) {
	Static STM_GETIMAGE := 0x173
	if (pGraph = 0) { Return "" }
	T := "`t",  TT := "`t:`t",  LF := "`n", SP := "        "

	pData := pGraph + NumGet(pGraph, 0, "UInt64"),  DataSz := NumGet(pData - 8, 0, "UInt64")

	if (FormatFloat != "" and DataSz) {
		Values := ""
		Loop DataSz // 8
			Values .= SubStr( A_Index "   ", 1, 4 ) T NumGet( pData - 8, A_Index* 8, "Double" ) LF
		Values := SubStr(Values, 1, -1)
		Return Values
	}

	cbSize    := NumGet(pGraph,   0, "UInt64")
	hCtrl     := NumGet(pGraph,   8, "UInt64")
	hTargetDC := NumGet(pGraph,  16, "UInt64")
	hSourceDC := NumGet(pGraph,  24, "UInt64")
	hSourceBM := NumGet(pGraph,  32, "UInt64")
	hSourcePen:= NumGet(pGraph,  40, "UInt64")
	ColumnW   := NumGet(pGraph,  48, "UInt64")
	Columns   := NumGet(pGraph,  56, "UInt64")
	MarginL   := NumGet(pGraph,  64, "UInt64")
	MarginT   := NumGet(pGraph,  72, "UInt64")
	MarginR   := NumGet(pGraph,  80, "UInt64")
	MarginB   := NumGet(pGraph,  88, "UInt64")
	MX1       := NumGet(pGraph,  96, "UInt64")
	MX2       := NumGet(pGraph, 104, "UInt64")
	BitBltW   := NumGet(pGraph, 112, "UInt64")
	BitBltH   := NumGet(pGraph, 120, "UInt64")

	hTargetBM := DllCall( "SendMessage", "Ptr",hCtrl, "UInt",STM_GETIMAGE, "Ptr",0, "Ptr",0 )
	BITMAP := Buffer(32, 0)
	DllCall( "GetObject", "Ptr",hTargetBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",BITMAP )
	TBMW := NumGet( BITMAP,  4, "UInt" ),      TBMH := NumGet( BITMAP, 8, "UInt" )
	TBMB := NumGet( BITMAP, 12, "UInt" )* TBMH,   TBMZ := Round( TBMB/1024,2 )
	TBPP := NumGet( BITMAP, 18, "UShort" )
	Adj := ( Adj := TBMW - MarginL - BitBltW - MarginR ) ? " (-" Adj ")" : ""

	DllCall( "GetObject", "Ptr",hSourceBM, "Int",( A_PtrSize = 8 ? 32 : 24 ), "Ptr",BITMAP )
	SBMW := NumGet( BITMAP,  4, "UInt" ),      SBMH := NumGet( BITMAP, 8, "UInt" )
	SBMB := NumGet( BITMAP, 12, "UInt" )* SBMH,   SBMZ := Round( SBMB/1024,2 )
	SBPP := NumGet( BITMAP, 18, "UShort" )

	Return "GRAPH Properties" LF LF
	. "Screen BG Bitmap   " TT TBMW ( Adj ) "x" TBMH " " TBPP "bpp ( " TBMZ " KB )" LF
	. "Margins ( L,T,R,B )" TT MarginL "," MarginT "," MarginR "," MarginB LF
	. "Client Area    " TT MarginL "," MarginT "," MarginL+BitBltW-1 "," MarginT+BitBltH-1 LF LF
	. "Memory Bitmap    " TT SBMW     "x" SBMH " " SBPP "bpp ( " SBMZ " KB )" LF
	. "Graph Width    " TT BitBltW " px ( " Columns " cols x " ColumnW " px )" LF
	. "Graph Height (MY2) " TT BitBltH " px ( y0 to y" BitBltH - 1 " )" LF
	. "Graph Array    " TT ( DataSz=0 ? "NA" : Columns " cols x 8 bytes = " DataSz " bytes" ) LF LF
	. "Pen start position " TT MX1 "," BitBltH - 1 LF
	. "LineTo position  " TT MX2 "," "MY2" LF
	. "MoveTo position  " TT MX1 "," "MY2" LF LF
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_Plot( pGraph, MY2 := "", SetVal := "", Draw := 1 ) {
	Static SRCCOPY := 0x00CC0020

	if (pGraph = 0) { Return "" }
	pData   := pGraph + NumGet(pGraph, 0, "UInt64"),   DataSz   := NumGet(pData - 8, 0, "UInt64")

	hSourceDC := NumGet(pGraph,  24, "UInt64"),   BitBltW  := NumGet(pGraph, 112, "UInt64")
	hTargetDC := NumGet(pGraph,  16, "UInt64"),   BitBltH  := NumGet(pGraph, 120, "UInt64")
	ColumnW   := NumGet(pGraph,  48, "UInt64")

	MarginL   := NumGet(pGraph,  64, "UInt64"),   MX1 := NumGet(pGraph,  96, "UInt64")
	MarginT   := NumGet(pGraph,  72, "UInt64"),   MX2 := NumGet(pGraph, 104, "UInt64")

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
	,  NumPut( "Double", SetVal, pData + DataSz - 8, 0 )

	Return 1
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_SetVal( pGraph, Double := 0, Column := "" ) {

	if (pGraph = 0) { Return "" }
	pData := pGraph + NumGet(pGraph, 0, "UInt64"),  DataSz := NumGet(pData - 8, 0, "UInt64")
	if DataSz = 0 { Return 0 }

	If ( Column = "" )
		DllCall( "RtlMoveMemory", "Ptr",pData, "Ptr",pData + 8, "Ptr",DataSz - 8 )
		, pNumPut := pData + DataSz
	else Columns := NumGet( pGraph, 56, "UInt64" )
		, pNumPut := pData + ( Column < 0 or Column > Columns ? Columns* 8 : Column* 8 )

	Return NumPut( "Double", Double, pNumPut - 8, 0 ) - 8
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_GetVal( pGraph, Column := "" ) {
	Static RECT := Buffer(16, 0)

	if (pGraph = 0) { Return "" }
	pData   := pGraph + NumGet(pGraph, 0, "UInt64"),   DataSz  := NumGet(pData - 8, 0, "UInt64")
	Columns := NumGet( pGraph, 56, "UInt64" )
	If not ( Column = "" or DataSz = 0 or Column < 1 or Column > Columns )
		Return NumGet( pData - 8, Column* 8, "Double" )

	hCtrl   := NumGet(pGraph,   8, "UInt64"),   ColumnW := NumGet(pGraph,  48, "UInt64")
	BitBltW := NumGet(pGraph, 112, "UInt64"),   MarginL := NumGet(pGraph,  64, "UInt64")
	BitBltH := NumGet(pGraph, 120, "UInt64"),   MarginT := NumGet(pGraph,  72, "UInt64")

	NumPut( "Int", MarginL, RECT, 0 ),  NumPut( "Int", MarginT, RECT, 4 )
	DllCall( "ClientToScreen", "Ptr",hCtrl, "Ptr",RECT )
	DllCall( "GetCursorPos", "Ptr",RECT.Ptr + 8 )

	MX := NumGet( RECT, 8, "Int" ) - NumGet( RECT, 0, "Int" )
	MY := NumGet( RECT,12, "Int" ) - NumGet( RECT, 4, "Int" )

	Column := ( MX >= 0 and MY >= 0 and MX < BitBltW and MY < BitBltH ) ? MX // ColumnW + 1 : 0
	Return ( DataSz and Column ) ? NumGet( pData - 8, Column* 8, "Double" ) : ""
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_GetMean( pGraph, TailCols := "" ) {

	if (pGraph = 0) { Return "" }
	pData := pGraph + NumGet(pGraph, 0, "UInt64"),  DataSz := NumGet(pData - 8, 0, "UInt64")
	if DataSz = 0 { Return 0 }

	Columns := NumGet( pGraph, 56, "UInt64" )
	pDataEnd := pGraph + NumGet(pGraph, 0, "UInt64") + ( Columns* 8 )
	TailCols := ( TailCols = "" or TailCols < 1 or TailCols > Columns ) ? Columns : TailCols

	Value := 0
	Loop TailCols
		Value += NumGet( pDataEnd - ( A_Index* 8 ), 0, "Double" )

	Return Value / TailCols
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_Detach( pGraph ) {
	if (pGraph = 0) { Return 0 }

	hCtrl      := NumGet(pGraph,  8, "UInt64")
	hTargetDC  := NumGet(pGraph, 16, "UInt64")
	hSourceDC  := NumGet(pGraph, 24, "UInt64")
	hSourceBM  := NumGet(pGraph, 32, "UInt64")
	hSourcePen := NumGet(pGraph, 40, "UInt64")

	DllCall( "ReleaseDC",  "Ptr",hCtrl, "Ptr",hTargetDC )
	DllCall( "RestoreDC",  "Ptr",hSourceDC, "Int",-1  )
	DllCall( "DeleteDC",   "Ptr",hSourceDC  )
	DllCall( "DeleteObject", "Ptr",hSourceBM  )
	DllCall( "DeleteObject", "Ptr",hSourcePen )

	Return DllCall( "GlobalFree", "Ptr",pGraph, "Ptr"  )
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

XGraph_MakeGrid( CellW, CellH, Cols, Rows, GLClr, BGClr, &BMPW := "", &BMPH := "" ) {
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
	, RECT := Buffer(16, 0)
	, NumPut( "UInt", BMPW, RECT, 8 ),  NumPut( "UInt", BMPH, RECT, 12 )
	, DllCall( "FillRect", "Ptr",hTempDC, "Ptr",RECT, "Ptr",hBrush )
	, DllCall( "DeleteObject", "Ptr",hBrush )

	hPenDC := DllCall( "GetStockObject", "Int",DC_PEN, "Ptr" )
	DllCall( "SelectObject",  "Ptr",hTempDC, "Ptr",hPenDC )
	DllCall( "SetDCPenColor", "Ptr",hTempDC, "UInt",GLClr & 0xFFFFFF )

	Loop Rows + 1 + ( X := Y := 0 )
		DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X,  "Int",Y, "Ptr",0  )
	, DllCall( "LineTo",   "Ptr",hTempDC, "Int",BMPW, "Int",Y ),  Y := Y + CellH

	Loop Cols + 1 + ( X := Y := 0 )
		DllCall( "MoveToEx", "Ptr",hTempDC, "Int",X, "Int",Y, "Ptr",0 )
	, DllCall( "LineTo",   "Ptr",hTempDC, "Int",X, "Int",BMPH ),  X := X + CellW

	DllCall( "RestoreDC", "Ptr",hTempDC, "Int",-1 )
	DllCall( "DeleteDC",  "Ptr",hTempDC )

	Return hTBM
}

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

CreateDIB( PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1  ) {
	; http://ahkscript.org/boards/viewtopic.php?t=3203          SKAN, CD: 01-Apr-2014 MD: 05-May-2014
	Static LR_Flag1 := 0x2008 ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8
		,  LR_Flag2 := 0x200C ; LR_CREATEDIBSECTION := 0x2000 | LR_COPYDELETEORG := 8 | LR_COPYRETURNORG := 4
		,  LR_Flag3 := 0x0008 ; LR_COPYDELETEORG := 8

	WB := Ceil( ( W* 3 ) / 2 )* 2,  BMBITS := Buffer(WB * H + 1, 0),  P := BMBITS.Ptr
	Loop Parse, PixelData, "|"
		P := NumPut("UInt", Integer("0x" A_LoopField), P, 0) - ( W & 1 and Mod( A_Index* 3, W* 3 ) = 0 ? 0 : 1 )

	hBM := DllCall( "CreateBitmap", "Int",W, "Int",H, "UInt",1, "UInt",24, "Ptr",0, "Ptr" )
	hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag1, "Ptr" )
	DllCall( "SetBitmapBits", "Ptr",hBM, "UInt",WB* H, "Ptr",BMBITS )

	If not ( Gradient + 0 )
		hBM := DllCall( "CopyImage", "Ptr",hBM, "UInt",0, "Int",0, "Int",0, "UInt",LR_Flag3, "Ptr" )
	Return DllCall( "CopyImage", "Ptr",hBM, "Int",0, "Int",ResizeW, "Int",ResizeH, "Int",LR_Flag2, "UPtr" )
}
