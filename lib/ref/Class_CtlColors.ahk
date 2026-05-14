/*** Class_CtlColors
* Lib: Class_CtlColors.ahk
*   Found on page: https://github.com/AHK-just-me/Class_CtlColors
* Version:
*   v1.0.03 [updated 10/31/2017 (MM/DD/YYYY)]
* Class_CtlColors
*  Choose your own background and/or text colors for some AHK GUI controls.
*
* How to use
*  To register a control for coloring call CtlColors.Attach() passing up to three parameters:
*
*    HWND  - HWND of the GUI control
*    BkColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
*    ------- Optional
*    TxColor - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
*
*    If both BkColor and TxColor are "" the control will not be added and the call returns False.
*
*  To change the colors for a registered control call CtlColors.Change() passing up to three parameters:
*
*    HWND  - see above
*    BkColor - see above
*    ------- Optional
*    TxColor - see above
*
*    Both BkColor and TxColor may be "" to reset them to default colors. If the control is not registered yet, CtlColors.Attach() is called internally.
*
*  To unregister a control from coloring call CtlColors.Detach() passing one parameter:
*
*    HWND  - see above
*
*  To stop all coloring and free the resources call CtlColors.Free(). It's a good idea to insert this call into the scripts exit-routine.
*
*  To check if a control is already registered call CtlColors.IsAttached() passing one parameter:
*
*    HWND  - see above
*
*  To get a control's HWND use either the option HwndOutputVar with Gui, Add or the command GuiControlGet with sub-command Hwnd.
*/
; ======================================================================================================================
; AHK 2.0+
; ======================================================================================================================
; Function:      Auxiliary object to color controls on WM_CTLCOLOR... notifications.
;          Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;          Checkboxes and Radios accept only background colors due to design.
; Namespace:     CtlColors
; Tested with:     1.1.25.02
; Tested on:     Win 10 (x64)
; Change log:    1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
;          1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
;          1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
;          1.0.01.00/2014-02-15/just me  -  changed class initialization.
;          1.0.00.00/2014-02-14/just me  -  initial release.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
	class CtlColors {
; ===================================================================================================================
; Class variables
; ===================================================================================================================
; Registered Controls
static Attached := Map()
; OnMessage Handlers
static HandledMessages := Map("Edit", 0, "ListBox", 0, "Static", 0)
; Message Handler Function
static MessageHandler := "CtlColors_OnMessage"
; Windows Messages
static WM_CTLCOLOR := Map("Edit", 0x0133, "ListBox", 0x134, "Static", 0x0138)
; HTML Colors (BGR)
static HTML := Map("AQUA", 0xFFFF00, "BLACK", 0x000000, "BLUE", 0xFF0000, "FUCHSIA", 0xFF00FF, "GRAY", 0x808080, "GREEN", 0x008000
				, "LIME", 0x00FF00, "MAROON", 0x000080, "NAVY", 0x800000, "OLIVE", 0x008080, "PURPLE", 0x800080, "RED", 0x0000FF
				, "SILVER", 0xC0C0C0, "TEAL", 0x808000, "WHITE", 0xFFFFFF, "YELLOW", 0x00FFFF)
; Transparent Brush
static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
; System Colors
static SYSCOLORS := Map("Edit", "", "ListBox", "", "Static", "")
; Error message in case of errors
static ErrorMsg := ""
; ===================================================================================================================
; Constructor / Destructor
; ===================================================================================================================
__Delete() {
	This.Free() ; free GDI resources
}
; ===================================================================================================================
; CheckBkColor  Internal check for parameter BkColor.
; ===================================================================================================================
CheckBkColor(&BkColor, CtrlClass) {
	This.ErrorMsg := ""
	If (BkColor != "") && !This.HTML.Has(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
		This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
		Return False
	}
	BkColor := BkColor = "" ? This.SYSCOLORS[CtrlClass]
			:  This.HTML.Has(BkColor) ? This.HTML[BkColor]
			:  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
	Return True
}
; ===================================================================================================================
; CheckTxColor  Internal check for parameter TxColor.
; ===================================================================================================================
CheckTxColor(&TxColor) {
	This.ErrorMsg := ""
	If (TxColor != "") && !This.HTML.Has(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
		This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
		Return False
	}
	TxColor := TxColor = "" ? ""
			:  This.HTML.Has(TxColor) ? This.HTML[TxColor]
			:  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
	Return True
}
; ===================================================================================================================
; Attach      Registers a control for coloring.
; Parameters:   HWND    - HWND of the GUI control
;         BkColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
;         ----------- Optional
;         TxColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
; Return values:  On success  - True
;         On failure  - False, CtlColors.ErrorMsg contains additional informations
; ===================================================================================================================
Attach(HWND, BkColor, TxColor := "") {
	; Names of supported classes
	static ClassNames := Map("Button", "", "ComboBox", "", "Edit", "", "ListBox", "", "Static", "")
	; Button styles
	static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
	; Editstyles
	static ES_READONLY := 0x800
	; Default class background colors
	static COLOR_3DFACE := 15, COLOR_WINDOW := 5
	; Initialize default background colors on first call -------------------------------------------------------------
	If (This.SYSCOLORS["Edit"] = "") {
		This.SYSCOLORS["Static"] := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
		This.SYSCOLORS["Edit"] := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
		This.SYSCOLORS["ListBox"] := This.SYSCOLORS["Edit"]
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
	If This.Attached.Has(HWND) {
		This.ErrorMsg := "Control " . HWND . " is already registered!"
		Return False
	}
	Hwnds := [CtrlHwnd]
	; Check control's class ------------------------------------------------------------------------------------------
	Classes := ""
	CtrlClass := WinGetClass("ahk_id " CtrlHwnd)
	This.ErrorMsg := "Unsupported control class: " . CtrlClass
	If !ClassNames.Has(CtrlClass)
		Return False
	CtrlStyle := WinGetStyle("ahk_id " CtrlHwnd)
	If (CtrlClass = "Edit")
		Classes := ["Edit", "Static"]
	Else If (CtrlClass = "Button") {
		IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
			Classes := ["Static"]
		Else
			Return False
	}
	Else If (CtrlClass = "ComboBox") {
		CBBI := Buffer(40 + (A_PtrSize * 3), 0)
		NumPut("UInt", 40 + (A_PtrSize * 3), CBBI, 0)
		DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", CBBI)
		Hwnds.Push(NumGet(CBBI, 40 + (A_PtrSize * 2), "UPtr") + 0)
		Hwnds.Push(NumGet(CBBI, 40 + A_PtrSize, "UPtr") + 0)
		Classes := ["Edit", "Static", "ListBox"]
	}
	If !(Classes is Array)
		Classes := [CtrlClass]
	; Check background color -----------------------------------------------------------------------------------------
	If (BkColor != "Trans")
		If !This.CheckBkColor(&BkColor, Classes[1])
			Return False
	; Check text color -----------------------------------------------------------------------------------------------
	If !This.CheckTxColor(&TxColor)
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
; Change      Change control colors.
; Parameters:   HWND    - HWND of the GUI control
;         BkColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
;         ----------- Optional
;         TxColor   - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
; Return values:  On success  - True
;         On failure  - False, CtlColors.ErrorMsg contains additional informations
; Remarks:    If the control isn't registered yet, Add() is called instead internally.
; ===================================================================================================================
Change(HWND, BkColor, TxColor := "") {
	; Check HWND -----------------------------------------------------------------------------------------------------
	This.ErrorMsg := ""
	HWND += 0
	If !This.Attached.Has(HWND)
		Return This.Attach(HWND, BkColor, TxColor)
	CTL := This.Attached[HWND]
	; Check BkColor --------------------------------------------------------------------------------------------------
	If (BkColor != "Trans")
		If !This.CheckBkColor(&BkColor, CTL.Classes[1])
			Return False
	; Check TxColor ------------------------------------------------------------------------------------------------
	If !This.CheckTxColor(&TxColor)
		Return False
	; Store Colors ---------------------------------------------------------------------------------------------------
	If (BkColor != CTL.BkColor) {
		If (CTL.Brush) {
			If (CTL.Brush != This.NullBrush)
			DllCall("Gdi32.dll\DeleteObject", "Ptr", CTL.Brush)
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
; Detach      Stop control coloring.
; Parameters:   HWND    - HWND of the GUI control
; Return values:  On success  - True
;         On failure  - False, CtlColors.ErrorMsg contains additional informations
; ===================================================================================================================
Detach(HWND) {
	This.ErrorMsg := ""
	HWND += 0
	If This.Attached.Has(HWND) {
		CTL := This.Attached[HWND].Clone()
		If (CTL.Brush) && (CTL.Brush != This.NullBrush)
			DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
		For I, V In CTL.Classes {
			If This.HandledMessages[V] > 0 {
			This.HandledMessages[V] -= 1
			If This.HandledMessages[V] = 0
				OnMessage(This.WM_CTLCOLOR[V], "")
		}  }
		For I, V In CTL.Hwnds
			This.Attached.Delete(V)
		DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
		CTL := ""
		Return True
	}
	This.ErrorMsg := "Control " . HWND . " is not registered!"
	Return False
}
; ===================================================================================================================
; Free      Stop coloring for all controls and free resources.
; Return values:  Always True.
; ===================================================================================================================
Free() {
	For K, V In This.Attached
		If (V.Brush) && (V.Brush != This.NullBrush)
			DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
	For K, V In This.HandledMessages
		If (V > 0) {
			OnMessage(This.WM_CTLCOLOR[K], "")
			This.HandledMessages[K] := 0
		}
	This.Attached := Map()
	Return True
}
; ===================================================================================================================
; IsAttached    Check if the control is registered for coloring.
; Parameters:   HWND    - HWND of the GUI control
; Return values:  On success  - True
;         On failure  - False
; ===================================================================================================================
IsAttached(HWND) {
	Return This.Attached.Has(HWND)
}
}
CtlColors := CtlColors()
; ======================================================================================================================
; CtlColors_OnMessage
; This function handles CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
CtlColors_OnMessage(wParam, lParam, msg, hwnd) {
	Critical()
	HDC := wParam
	HWND := lParam
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
