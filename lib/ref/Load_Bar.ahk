; Load_Bar - Cool Gradient progress bar class by joedf (using CreateDIB by SKAN)
; Ported to AHK v2

Scale_PositionFromDPI(val) {
	Return Round(val * A_ScreenDPI / 96)
}

Class LoaderBar {
	__New(GuiObj, x:=0, y:=0, w:=280, h:=28, ShowDesc:=0, FontColorDesc:="2B2B2B", FontColor:="EFEFEF", BG:="2B2B2B|2F2F2F|323232", FG:="66A3E2|4B79AF|385D87") {
		This.GuiObj := GuiObj
		This.BG := StrSplit(BG, "|")
		This.BG.W := w
		This.BG.H := h
		This.Width  := w
		This.Height := h
		This.FG := StrSplit(FG, "|")
		This.FG.W := This.BG.W - 2
		This.FG.H := (fg_h := (This.BG.H - 2))
		This.Percent := 0
		This.X := x
		This.Y := y
		fg_x := This.X + 1
		fg_y := This.Y + 1
		This.FontColor    := FontColor
		This.ShowDesc     := ShowDesc
		This.DescBGColor  := "Black"
		This.FontColorDesc := FontColorDesc

		GuiObj.SetFont("s8")

		hLoaderBarBG := GuiObj.Add("Text", "x" x " y" y " w" w " h" h " 0xE")
		This.ApplyGradient(This.hLoaderBarBG := hLoaderBarBG, This.BG[1], This.BG[2], This.BG[3], 1)

		hLoaderBarFG := GuiObj.Add("Text", "x" fg_x " y" fg_y " w0 h" fg_h " 0xE")
		This.ApplyGradient(This.hLoaderBarFG := hLoaderBarFG, This.FG[1], This.FG[2], This.FG[3], 1)

		hLoaderNumber := GuiObj.Add("Text", "x" x " y" y " w" w " h" h " 0x200 Border Center BackgroundTrans c" FontColor, "[ 0 % ]")
		This.hLoaderNumber := hLoaderNumber

		If (This.ShowDesc) {
			hLoaderDesc := GuiObj.Add("Text", "xp y+2 w" w " h16 0x200 Border BackgroundTrans c" FontColorDesc, "Loading...")
			This.hLoaderDesc := hLoaderDesc
			This.Height := h + 18
		}

		GuiObj.SetFont()
	}

	Set(p, w:="Loading...") {
		This.hLoaderBarBG.GetPos(, , &LoaderBarBGW)
		This.BG.W := LoaderBarBGW
		This.FG.W := LoaderBarBGW - 2
		This.Percent := (p >= 100) ? (p := 100) : p
		PercentNum := Round(This.Percent, 0)
		PercentBar := Floor((This.Percent / 100) * (This.FG.W))

		This.hLoaderBarFG.Move(, , PercentBar)
		This.hLoaderNumber.Text := "[ " PercentNum " % ]"

		If (This.ShowDesc)
			This.hLoaderDesc.Text := w
	}

	ApplyGradient(Ctrl, LT:="101010", MB:="0000AA", RB:="00FF00", Vertical:=1) {
		Static STM_SETIMAGE := 0x172
		Ctrl.GetPos(, , &W, &H)
		W := Scale_PositionFromDPI(W)
		H := Scale_PositionFromDPI(H)
		PixelData := Vertical
			? LT "|" LT "|" LT "|" MB "|" MB "|" MB "|" RB "|" RB "|" RB
			: LT "|" MB "|" RB "|" LT "|" MB "|" RB "|" LT "|" MB "|" RB
		hBitmap := This.CreateDIB(PixelData, 3, 3, W, H, True)
		oBitmap := DllCall("SendMessage", "Ptr", Ctrl.Hwnd, "UInt", STM_SETIMAGE, "Ptr", 0, "Ptr", hBitmap)
		DllCall("DeleteObject", "Ptr", oBitmap)
		Return hBitmap
	}

	CreateDIB(PixelData, W, H, ResizeW:=0, ResizeH:=0, Gradient:=1) {
		; http://ahkscript.org/boards/viewtopic.php?t=3203  SKAN, CD: 01-Apr-2014 MD: 05-May-2014
		Static LR_Flag1 := 0x2008  ; LR_CREATEDIBSECTION | LR_COPYDELETEORG
		     , LR_Flag2 := 0x200C  ; LR_CREATEDIBSECTION | LR_COPYDELETEORG | LR_COPYRETURNORG
		     , LR_Flag3 := 0x0008  ; LR_COPYDELETEORG
		WB := Ceil((W * 3) / 2) * 2
		BMBITS := Buffer(WB * H + 1, 0)
		P := BMBITS.Ptr
		Loop Parse, PixelData, "|" {
			P := NumPut("UInt", "0x" A_LoopField, P) - ((W & 1) && (Mod(A_Index * 3, W * 3) = 0) ? 0 : 1)
		}
		hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
		hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", LR_Flag1, "Ptr")
		DllCall("SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", BMBITS.Ptr)
		If !Gradient
			hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", LR_Flag3, "Ptr")
		Return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", LR_Flag2, "UPtr")
	}
}

; Function wrapper for the LoaderBar class
Load_BarControl(Percent:=0, uText:="Loading...", ShowGui:=0) {
	Static LoadBar_Initialized := 0
	Static load_BarGUI := ""
	Static load_Bar    := ""
	Static LB_wW := 0, LB_wH := 0

	If (!LoadBar_Initialized) {
		LoadBar_Initialized := 1
		load_BarGUI := Gui("-Border -Caption +ToolWindow +AlwaysOnTop", "Load Bar")
		load_BarGUI.BackColor := "4D4D4D"
		load_Bar := LoaderBar(load_BarGUI, 3, 3, 280, 28, 1, "EFEFEF")
		LB_wW := load_Bar.Width  + 2 * load_Bar.X
		LB_wH := load_Bar.Height + 2 * load_Bar.Y
	}
	If (ShowGui)
		load_BarGUI.Show("NA w" LB_wW " h" LB_wH " x10 y" Round(A_ScreenHeight * .5))

	load_Bar.Set(Percent, uText)

	If (ShowGui < 0)
		SetTimer(() => load_BarGUI.Hide(), -1000)
}
