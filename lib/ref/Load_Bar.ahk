
; Load_Bar - Cool Gradient progress bar class by joedf (using CreateDIB by SKAN)
class LoaderBar {
	__New(GUI_ID:="Default",x:=0,y:=0,w:=280,h:=28,ShowDesc:=0,FontColorDesc:="2B2B2B",FontColor:="EFEFEF",BG:="2B2B2B|2F2F2F|323232",FG:="66A3E2|4B79AF|385D87") {
		SetWinDelay,0
		SetBatchLines,-1
		if (StrLen(A_Gui))
			_GUI_ID:=A_Gui
		else
			_GUI_ID:=1
		if ( (GUI_ID="Default") || !StrLen(GUI_ID) || GUI_ID==0 )
			GUI_ID:=_GUI_ID
		this.GUI_ID := GUI_ID
		Gui, %GUI_ID%:Default
		this.BG := StrSplit(BG,"|")
		this.BG.W := w
		this.BG.H := h
		this.Width:=w
		this.Height:=h
		this.FG := StrSplit(FG,"|")
		this.FG.W := this.BG.W - 2
		this.FG.H := (fg_h:=(this.BG.H - 2))
		this.Percent := 0
		this.X := x
		this.Y := y
		fg_x:= this.X + 1
		fg_y:= this.Y + 1
		this.FontColor := FontColor
		this.ShowDesc := ShowDesc
		
		;DescBGColor:="4D4D4D"
		DescBGColor:="Black"
		this.DescBGColor := DescBGColor
		
		this.FontColorDesc := FontColorDesc
		
		Gui,Font,s8
		
		Gui, Add, Text, x%x% y%y% w%w% h%h% 0xE hwndhLoaderBarBG
			this.ApplyGradient(this.hLoaderBarBG := hLoaderBarBG,this.BG.1,this.BG.2,this.BG.3,1)
			
			Gui, Add, Text, x%fg_x% y%fg_y% w0 h%fg_h% 0xE hwndhLoaderBarFG
			this.ApplyGradient(this.hLoaderBarFG := hLoaderBarFG,this.FG.1,this.FG.2,this.FG.3,1)
			
		Gui, Add, Text, x%x% y%y% w%w% h%h% 0x200 border center BackgroundTrans hwndhLoaderNumber c%FontColor%, % "[ 0 % ]"
			this.hLoaderNumber := hLoaderNumber
		
		if (this.ShowDesc) {
			;Gui, Add, Text, xp y+2 w%w% h16 0x200 border Background%DescBGColor% hwndhLoaderDesc, Loading...
			Gui, Add, Text, xp y+2 w%w% h16 0x200 border BackgroundTrans hwndhLoaderDesc c%FontColorDesc%, Loading...
			this.hLoaderDesc := hLoaderDesc
			this.Height:=h+18
		}
			
		Gui,Font
		
		Gui, %_GUI_ID%:Default
	}
	
	Set(p,w:="Loading...") {
		if (StrLen(A_Gui))
			_GUI_ID:=A_Gui
		else
			_GUI_ID:=1
		GUI_ID := this.GUI_ID
		Gui, %GUI_ID%:Default
		GuiControlGet, LoaderBarBG, Pos, % this.hLoaderBarBG
		this.BG.W := LoaderBarBGW
		this.FG.W := LoaderBarBGW - 2
		this.Percent:=(p>=100) ? p:=100 : p
		PercentNum:=Round(this.Percent,0)
		PercentBar:=floor((this.Percent/100)*(this.FG.W))
		
		hLoaderBarFG := this.hLoaderBarFG
		hLoaderNumber := this.hLoaderNumber
		
		GuiControl,Move,%hLoaderBarFG%,w%PercentBar%
		GuiControl,,%hLoaderNumber%,[ %PercentNum% `% ]
		
		if (this.ShowDesc) {
			hLoaderDesc := this.hLoaderDesc
			GuiControl,,%hLoaderDesc%, %w%
		}
		Gui, %_GUI_ID%:Default
	}
	
	ApplyGradient( Hwnd, LT := "101010", MB := "0000AA", RB := "00FF00", Vertical := 1 ) {
		Static STM_SETIMAGE := 0x172 
		ControlGetPos,,, W, H,, ahk_id %Hwnd%
		W:=Scale_PositionFromDPI(W), H:=Scale_PositionFromDPI(H)
		PixelData := Vertical ? LT "|" LT "|" LT "|" MB "|" MB "|" MB "|" RB "|" RB "|" RB : LT "|" MB "|" RB "|" LT "|" MB "|" RB "|" LT "|" MB "|" RB
		hBitmap := this.CreateDIB( PixelData, 3, 3, W, H, True )
		oBitmap := DllCall( "SendMessage", "Ptr",Hwnd, "UInt",STM_SETIMAGE, "Ptr",0, "Ptr",hBitmap )
		Return hBitmap, DllCall( "DeleteObject", "Ptr",oBitmap )
	}
	
	CreateDIB( PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1  ) {    
		; http://ahkscript.org/boards/viewtopic.php?t=3203          SKAN, CD: 01-Apr-2014 MD: 05-May-2014
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
}
; Function wrapper for the Load_bar class by Bandit
Load_BarControl(Percent:=0,uText:="Loading...",ShowGui:=0)
{
	Global
	Static LoadBar_Initialized := 0
	If (!LoadBar_Initialized)
	{
		LoadBar_Initialized := 1
		LastDisplay_LB := 0
		Gui, load_BarGUI: New
		Gui, load_BarGUI:-Border -Caption +ToolWindow +AlwaysOnTop
		Gui, load_BarGUI:Color, 0x4D4D4D, 0xFFFFFF
		load_Bar := new LoaderBar("load_BarGUI",3,3,280,28,1,"EFEFEF")
		LB_wW:=load_Bar.Width + 2*load_Bar.X
		LB_wH:=load_Bar.Height + 2*load_Bar.Y
	}
	If (ShowGui)
	{
		Gui, load_BarGUI:Show, % "NA w" LB_wW " h" LB_wH " x10 y" Round(A_ScreenHeight * .5) ,Load Bar
	}

	load_Bar.Set(Percent,uText)
	If (ShowGui < 0)
		SetTimer, Load_BarControl_Hide, -1000
	Return

	Load_BarControl_Hide:
		Gui, load_BarGUI: Hide
	Return
}
