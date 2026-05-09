; ======================================================================================================================
; just me      ->  https://www.autohotkey.com/boards/viewtopic.php?f=83&t=125259
; LV_GridColor - Sets/resets the color used to draw the gridlines in a ListView
; Parameter:
;     LV          -  ListView control object
;     GridColor   -  RGB integer value in the range from 0x000000 to 0xFFFFFF or HTML color nameas  defined in the docs
; Remarks:
;     Drawing is implemented using Custom Draw -> https://learn.microsoft.com/en-us/windows/win32/controls/custom-draw
; ======================================================================================================================
LV_GridColor(LV, GridColor?) {
   Static Controls := Map()
   If Controls.Has(LV.Hwnd) {
      LV.OnNotify(-12, NM_CUSTOMDRAW, 0)
      If LV.HasProp("GridPen") {
         DllCall("DeleteObject", "Ptr", LV.GridPen)
         LV.DeleteProp("GridPen")
      }
      If (Controls[LV.Hwnd] = 1)
         LV.Opt("+LV0x00000001") ; LV_EX_GRIDLINES
      Controls.Delete(LV.Hwnd)
   }
   If IsSet(GridColor) {
      GridColor := BGR(GridColor)
      If (GridColor = "")
         Throw Error("Invald parameter GridColor!")
      LV.GridPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", GridColor, "UPtr")
      LV_EX_Styles := SendMessage(0x1037, 0, 0, LV.Hwnd) ; LVM_GETEXTENDEDLISTVIEWSTYLE
      If (LV_EX_Styles & 0x00000001) ; LV_EX_GRIDLINES
         LV.Opt("-LV0x00000001")
      Controls[LV.Hwnd] := LV_EX_Styles & 0x00000001
      LV.OnNotify(-12, NM_CUSTOMDRAW, 1)
   }
   Return True
   ; -------------------------------------------------------------------------------------------------------------------
   NM_CUSTOMDRAW(LV, LP) {
      Static Points := Buffer(24, 0)                     ; Polyline points
      Static SizeNMHDR := A_PtrSize * 3                  ; Size of NMHDR structure
      Static SizeNCD := SizeNMHDR + 16 + (A_PtrSize * 5) ; Size of NMCUSTOMDRAW structure
      Static OffDC := SizeNMHDR + A_PtrSize
      Static OffRC := OffDC + A_PtrSize
      Static OffItem := SizeNMHDR + 16 + (A_PtrSize * 2) ; Offset of dwItemSpec (NMCUSTOMDRAW)
      Static OffCT := SizeNCD                            ; Offset of clrText (NMLVCUSTOMDRAW)
      Static OffCB := OffCT + 4                          ; Offset of clrTextBk (NMLVCUSTOMDRAW)
      Static OffSubItem := OffCB + 4                     ; Offset of iSubItem (NMLVCUSTOMDRAW)
      Critical -1
      Local DrawStage := NumGet(LP + SizeNMHDR, "UInt")  ; drawing stage
      Switch DrawStage {
         Case 0x030002:       ; CDDS_SUBITEMPOSTPAINT
            Local SI := NumGet(LP + OffSubItem, "Int") ; subitem
            Local DC := NumGet(LP + OffDC, "UPtr")     ; device context
            Local RC := LP + OffRC                     ; drawing rectangle
            Local L := SI = 0 ? 0 : NumGet(RC, "Int")  ; left
            Local T := NumGet(RC + 4, "Int")           ; top
            Local R := NumGet(RC + 8, "Int")           ; right
            Local B := NumGet(RC + 12, "Int")          ; bottom
            Local PP := DllCall("SelectObject", "Ptr", DC, "Ptr", LV.GridPen, "UPtr") ; previous pen
            If (SI = 0)
               NumPut("Int", L, "Int", B - 1, "Int", R, "Int", B - 1, Points)
            Else
               NumPut("Int", L, "Int", T, "Int", L, "Int", B - 1, "Int", R, "Int", B - 1, Points)
            DllCall("Polyline", "Ptr", DC, "Ptr", Points, "Int", SI = 0 ? 2 : 3)
            NumPut("Int", L, "Int", B - 1, "Int", R, "Int", B - 1, "Int", R, "Int", T - 1, Points)
            DllCall("Polyline", "Ptr", DC, "Ptr", Points, "Int", 3)
            DllCall("SelectObject", "Ptr", DC, "Ptr", PP, "UPtr")
            Return 0x00       ; CDRF_DODEFAULT
         Case 0x030001:       ; CDDS_SUBITEMPREPAINT
            Return 0x10       ; CDRF_NOTIFYPOSTPAINT
         Case 0x010001:       ; CDDS_ITEMPREPAINT
            Return 0x20       ; CDRF_NOTIFYSUBITEMDRAW
         Case 0x000001:       ; CDDS_PREPAINT
            Return 0x20       ; CDRF_NOTIFYITEMDRAW
         Default:
            Return 0x00       ; CDRF_DODEFAULT
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   BGR(Color, Default := "") { ; converts colors to BGR
      ; HTML Colors (BGR)
      Static HTML := {AQUA:   0xFFFF00, BLACK: 0x000000, BLUE:   0xFF0000, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
                      GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x000080, NAVY:    0x800000, OLIVE: 0x008080,
                      PURPLE: 0x800080, RED:   0x0000FF, SILVER: 0xC0C0C0, TEAL:    0x808000, WHITE: 0xFFFFFF,
                      YELLOW: 0x00FFFF}
      If IsInteger(Color)
         Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
      Return (HTML.HasOwnProp(Color) ? HTML.%Color% : Default)
   }
}