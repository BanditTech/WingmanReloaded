; ======================================================================================================================
; Release date: 2023-05-28
; ======================================================================================================================
; Add tooltips to your Gui controls.
; Tooltips are managed per Gui, so you first have to create a new instance of the class for the Gui, e.g.:
;     MyGui := Gui()
;     MyGui.Tips := GuiCtrlTips(MyGui)
; Then you can create your controls and add tooltips, e.g.:
;     MyBtn := MyGui.AddButton(...)
;     MyGui.Tips.SetTip(MyBtn, "My Tooltip!")
; You can activate, deactivate, or change the delay times for all tooltips at any time by calling the corresponding
; methods.
; To remove a tooltip from a single control pass an empty text, e.g.:
;     MyGui.Tips.SetTip(MyBtn, "")
; Text and Picture controls require the SS_NOTIFY (+0x0100) style or a 'Click' event function.
; ----------------------------------------------------------------------------------------------------------------------
; Tooltip control: https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference
; ======================================================================================================================
Class GuiCtrlTips {
   Static TOOLINFO {
      Get {
         Static SizeOfTI := 24 + (A_PtrSize * 6)
         Local TI := Buffer(SizeOfTI, 0)
         NumPut("UInt", SizeOfTI, TI)
         Return TI
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Static ToolTipFont {
      Get {
         Static SizeOfLFW  := 92                      ; LOGFONTW structure
         Static SizeOfNCM := 44 + (SizeOfLFW * 5)      ; NONCLIENTMETRICSW structure
         Static OffStatusFont := 40 + (SizeOfLFW * 3)  ; lfStatusFont
         Static LOGFONTW := 0
         If !IsObject(LOGFONTW) { ; first call
            Local NCM := Buffer(SizeOfNCM, 0)
            NumPut("UInt", SizeOfNCM, NCM)
            DllCall("SystemParametersInfoW", "UInt", 0x0029, "UInt", 0, "Ptr", NCM.Ptr, "UInt", 0) ; SPI_GETNONCLIENTMETRICS
            LOGFONTW := Buffer(SizeOfLFW, 0)
            DllCall("RtlMoveMemory", "Ptr", LOGFONTW.Ptr, "Ptr", NCM.Ptr + OffStatusFont, "Ptr", SizeOfLFW)
         }
         Local LF := Buffer(SizeOfLFW, 0)
         DllCall("RtlMoveMemory", "Ptr", LF.Ptr, "Ptr", LOGFONTW.Ptr, "Ptr", SizeOfLFW)
         Return LF
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-addtool
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmaxtipwidth
   ; https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfow
   __New(GuiObj, UseAhkStyle := True, UseComboEdit := True) {
      Local Flags, HGUI, HTIP, TI
      If !(GuiObj Is Gui)
         Throw TypeError(A_ThisFunc . ": Expected a Gui object!", -1 "GuiObj")
      HGUI := GuiObj.Hwnd
      ; Create the TOOLINFO structure
      Flags := 0x11 ; TTF_SUBCLASS | TTF_IDISHWND
      TI := GuiCtrlTips.TOOLINFO
      NumPut("UInt", Flags, "UPtr", HGUI, "UPtr", HGUI, TI, 4) ; uFlags, hwnd, uID
      ; Create a tooltip control for this Gui
      If !(HTIP := DllCall("CreateWindowEx", "UInt", 0, "Str", "tooltips_class32", "Ptr", 0, "UInt", 0x80000003
                                           , "Int", 0x80000000, "Int", 0x80000000, "Int", 0x80000000, "Int", 0x80000000
                                           , "Ptr", HGUI, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UPtr"))
         Throw Error(A_ThisFunc . ": Could not create a tooltip control", -1)
      If (UseAhkStyle)
         DllCall("Uxtheme.dll\SetWindowTheme", "Ptr", HTIP, "Ptr", 0, "Str", " ")
      SendMessage(0x0418, 0, A_ScreenWidth, HTIP) ; TTM_SETMAXTIPWIDTH
      ; SendMessage(0x0432, 0, TI.Ptr, HTIP) ; TTM_ADDTOOLW <--- doesn't seem required any more
      This.DefineProp("HTIP", {Get: (*) => HTIP})
      This.DefineProp("HGUI", {Get: (*) => HGUI})
      This.DefineProp("UAS",  {Get: (*) => !!UseAhkStyle})
      This.DefineProp("UCE",  {Get: (*) => !!UseComboEdit})
      This.Ctrls := Map()
   }
   ; -------------------------------------------------------------------------------------------------------------------
   __Delete() {
      If This.HasProp("HTIP")
         DllCall("DestroyWindow", "Ptr", This.HTIP)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-activate
   Activate() {
      SendMessage(0x0401, True, 0, This.HTIP) ; TTM_ACTIVATE
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-activate
   Deactivate() {
      SendMessage(0x0401, False, 0, This.HTIP) ; TTM_ACTIVATE
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settipbkcolor
   SetBkColor(Color) {
      If IsInteger(Color) {
         Color := ((Color & 0x0000FF) << 16) | (Color & 0x00FF00) |  ((Color & 0xFF0000) >> 16)
         SendMessage(0x0413, Color, 0, This.HTIP)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setdelaytime
   ; Flag      - one of the string keys defined in Flags
   ; MilliSecs - time in millisecons, pass -1 to reset to the default
   SetDelayTime(Flag, MilliSecs) {
      Static Flags := {AUTOMATIC: 0, AUTOPOP: 2, INITIAL: 3, RESHOW: 1}
      If !Flags.HasProp(Flag) || !IsInteger(MilliSecs)
         Return False
      If  (MilliSecs < -1)
         MilliSecs := -1
      SendMessage(0x0403, Flags.%Flag%, MilliSecs, This.HTIP)
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Any value passed in Bold and Italic will set the related font option
   SetFont(FontSize?, FontName?, Bold?, Italic?) {
      Static LOGPIXELSY := 0, PrevFont := 0
      If (LOGPIXELSY = 0) { ; first call
         Local HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
         LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int") ; LOGPIXELSY
         DllCall("ReleaseDC", "Ptr", 0, "Ptr", HDC)
      }
      Local LOGFONT := GuiCtrlTips.ToolTipFont
      If IsSet(FontSize) && IsNumber(FontSize)
         NumPut("Int", -Round(FontSize * LOGPIXELSY / 72), LOGFONT)
      If IsSet(Bold)
         NumPut("Int", 700, LOGFONT, 16)
      If IsSet(Italic)
         NumPut("UChar", 1, LOGFONT, 20)
      If IsSet(FontName)
         StrPut(FontName, LOGFONT.Ptr + 28, 32)
      Local HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONT.Ptr, "UPtr")
      SendMessage(0x0030, HFONT, 1, This.HTIP)
      If PrevFont
         DllCall("DeleteObject", "Ptr", PrevFont)
      PrevFont := HFONT
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-setmargin
   SetMargins(L := 0, T := 0, R := 0, B := 0) {
      RC := Buffer(16, 0)
      NumPut("Int", L, "Int", T, "Int", R, "Int", B, RC)
      SendMessage(0x041A, 0, RC.Ptr, This.HTIP)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-addtool
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-deltool
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-updatetiptext
   SetTip(GuiCtrl, TipText, CenterTip := False) {
      Local Flags, HCTL, TI
      ; Check the passed GuiCtrl
      If !(GuiCtrl Is Gui.Control) || (GuiCtrl.Gui.Hwnd != This.HGUI)
         Return False
      If (GuiCtrl.Type = "ComboBox") && This.UCE ; use the Edit control of the Combobox
         HCTL := DllCall("FindWindowExW", "Ptr", GuiCtrl.Hwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UPtr")
      Else
         HCTL := GuiCtrl.Hwnd
      ; Create the TOOLINFO structure
      Flags := 0x11 | (CenterTip ? 0x02 : 0x00) ; TTF_SUBCLASS | TTF_IDISHWND [| TTF_CENTERTIP]
      TI := GuiCtrlTips.TOOLINFO
      NumPut("UInt", Flags, "UPtr", This.HGUI, "UPtr", HCTL, TI, 4) ; cbSize, uFlags, hwnd, uID
      If (TipText = "") {
         If This.Ctrls.Has(HCTL) {
            SendMessage(0x0433, 0, TI.Ptr, This.HTIP) ; TTM_DELTOOLW
            This.Ctrls.Delete(HCTL)
         }
         Return True
      }
      If !This.Ctrls.Has(HCTL) {
         SendMessage(0x0432, 0, TI.Ptr, This.HTIP) ; TTM_ADDTOOLW
         This.Ctrls[HCTL] := True
      }
      ; Set / Update the tool's text.
      NumPut("UPtr", StrPtr(TipText), TI, 24 + (A_PtrSize * 3))  ; lpszText
   	SendMessage(0x0439, 0, TI.Ptr, This.HTIP) ; TTM_UPDATETIPTEXTW
   	Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; https://learn.microsoft.com/en-us/windows/win32/controls/ttm-settiptextcolor
   SetTxColor(Color) {
      If IsInteger(Color) {
         Color := ((Color & 0x0000FF) << 16) | (Color & 0x00FF00) |  ((Color & 0xFF0000) >> 16)
         SendMessage(0x0414, Color, 0, This.HTIP)
      }
   }
}
; ======================================================================================================================