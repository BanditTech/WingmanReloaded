/**
 * Assigns an icon to a GUI button.
 * @author Fanatic Guru
 * @date 2019-03-26
 * @param {number|Gui.Button} Handle - The HWND handle of the GUI button or the Gui button object.
 * @param {string} File - The file containing the icon image.
 * @param {number} [Index=1] - The index of the icon in the file.
 * @param {string} [Options=''] - Single-letter flags followed by a number, with multiple options delimited by a space:
 * - `W`: Width of the icon (default = 16)
 * - `H`: Height of the icon (default = 16)
 * - `S`: Size of the icon, makes both width and height equal to the size
 * - `L`: Left margin
 * - `T`: Top margin
 * - `R`: Right margin
 * - `B`: Bottom margin
 * - `A`: Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center, default = 4)
 * @returns {number} 1 if the icon was found, 0 if the icon was not found.
 * @example
 * MyGui := Gui()
 * MyButton := MyGui.Add("Button", "w70 h38", "Save")
 * GuiButtonIcon(MyButton, "shell32.dll", 259, "s32 a1 r2")
 * MyGui.Show
 */
GuiButtonIcon(Handle, File, Index := 1, Options := "")
{
	Type(Handle) = 'Gui.Button' && Handle := Handle.Hwnd
	RegExMatch(Options, "i)w\K\d+", &W) ? W := W.0 : W := 16
	RegExMatch(Options, "i)h\K\d+", &H) ? H := H.0 : H := 16
	RegExMatch(Options, "i)s\K\d+", &S) ? W := H := S.0 : ""
	RegExMatch(Options, "i)l\K\d+", &L) ? L := L.0 : L := 0
	RegExMatch(Options, "i)t\K\d+", &T) ? T := T.0 : T := 0
	RegExMatch(Options, "i)r\K\d+", &R) ? R := R.0 : R := 0
	RegExMatch(Options, "i)b\K\d+", &B) ? B := B.0 : B := 0
	RegExMatch(Options, "i)a\K\d+", &A) ? A := A.0 : A := 4
	W := W * (A_ScreenDPI / 96), H := H * (A_ScreenDPI / 96)
	Psz := (A_PtrSize = "" ? 4 : A_PtrSize), DW := "UInt", Ptr := (A_PtrSize = "" ? DW : "Ptr")
	button_il := Buffer(20 + Psz)
	normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1)
	NumPut(Ptr, normal_il, button_il, 0)	; Width & Height
	NumPut(DW, L, button_il, 0 + Psz)	; Left Margin
	NumPut(DW, T, button_il, 4 + Psz)	; Top Margin
	NumPut(DW, R, button_il, 8 + Psz)	; Right Margin
	NumPut(DW, B, button_il, 12 + Psz)	; Bottom Margin
	NumPut(DW, A, button_il, 16 + Psz)	; Alignment
	SendMessage(BCM_SETIMAGELIST := 5634, 0, button_il, , "AHK_ID " Handle)
	Return IL_Add(normal_il, File, Index)
}