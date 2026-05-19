LootColorsMenu(*){
	Global LootColors, LG_Vary, LootColorsGui
	Static LG_Add, LG_Rem
	Global LootVacuum, LootVacuumTapZ, LootVacuumTapZEnd, LootVacuumTapZSec
	Global AreaScale, LVdelay, YesLootChests, ChestStr, YesLootDelve, DelveStr
	Global hotkeyLootScan, ScrCenter, GameH
	MainGui.Submit()
	CheckGamestates := False
	LootColorsGui := Gui()
	LootColorsGui.OnEvent("Close", LootColorsClose)
	LootColorsGui.OnEvent("Escape", LootColorsEscape)

	cb := LootColorsGui.Add("Checkbox", "section vLootVacuum Checked" LootVacuum "   xm+5 ym+8 ", "Enable Loot Vacuum")
	cb.OnEvent("Click", UpdateExtra)
	cb2 := LootColorsGui.Add("Checkbox",  "vLootVacuumTapZ Checked" LootVacuumTapZ "   x+5 yp ", "Double tap Z")
	cb2.OnEvent("Click", UpdateExtra)
	cb3 := LootColorsGui.Add("Checkbox",  "vLootVacuumTapZEnd Checked" LootVacuumTapZEnd "   x+5 yp ", "on release")
	cb3.OnEvent("Click", UpdateExtra)
	LootColorsGui.Add("Text",  "x+5 yp ", LootVacuumTapZSec)
	ud := LootColorsGui.Add("UpDown",  "vLootVacuumTapZSec range1-10", LootVacuumTapZSec)
	ud.OnEvent("Change", UpdateExtra)

	ddl := LootColorsGui.Add("DropDownList", "vAreaScale w45 xm+5 y+8",  [" ","0","30","40","50","60","70","80","90","100","200","300","400","500"])
	ddl.OnEvent("Change", UpdateExtra)
	LootColorsGui["AreaScale"].Choose(AreaScale)
	LootColorsGui.Add("Text",                     "x+3 yp+5"              , "Area around mouse")
	ddl2 := LootColorsGui.Add("DropDownList", "vLVdelay w45 x+5 yp-5",  [" ","0","15","30","45","60","75","90","105","120","135","150","195","300"])
	ddl2.OnEvent("Change", UpdateExtra)
	LootColorsGui["LVdelay"].Choose(LVdelay)
	LootColorsGui.Add("Text",                     "x+3 yp+5"              , "Delay after click")
	cb4 := LootColorsGui.Add("CheckBox", "vYesLootChests Checked" YesLootChests " Right xm h22", "Open Containers?")
	cb4.OnEvent("Click", UpdateExtra)
	cbox := LootColorsGui.Add("ComboBox", "x+5 w210 vChestStr " , [ChestStr, Chr(34) "1080_ChestStr" Chr(34), Chr(34) "1050_ChestStr" Chr(34)])
	cbox.OnEvent("Change", UpdateStringEdit)
	cb5 := LootColorsGui.Add("CheckBox", "vYesLootDelve Checked" YesLootDelve " Right xm h22", "Delve Containers?")
	cb5.OnEvent("Click", UpdateExtra)
	cbox2 := LootColorsGui.Add("ComboBox", "x+5 w210 vDelveStr " , [DelveStr, Chr(34) "1080_DelveStr" Chr(34)])
	cbox2.OnEvent("Change", UpdateStringEdit)
	LootColorsGui.Add("GroupBox", "section xm y+10 w330 h" 24 * (LootColors.Length / 2) + 30 , "Loot Colors:")
	savebtn := LootColorsGui.Add("Button", "yp-5 xp+70 h22 w80", "Save to INI")
	savebtn.OnEvent("Click", SaveLootColorArray)
	LG_Add := LootColorsGui.Add("Button", "vLG_Add yp x+5 h22 wp", "Add Color Set")
	LG_Add.OnEvent("Click", AdjustLootGroup)
	LG_Rem := LootColorsGui.Add("Button", "vLG_Rem yp x+5 h22 wp", "Rem Color Set")
	LG_Rem.OnEvent("Click", AdjustLootGroup)
	importBtn := LootColorsGui.Add("Button", "yp x+5 h22 wp", "Import Filter")
	importBtn.OnEvent("Click", ImportLootColorsFromFilter)
	colorIdx := 0
	For k, color in LootColors
	{
		; color := val ; hexBGRToRGB(Format("0x{1:06X}",val))
		If !Mod(k,2) ;Check for a remainder when dividing by 2, this groups the colors
		{
			LootColorsGui.Add("Progress", "x+1 yp w50 h20 c" color " BackgroundBlack",100)
			resBtn := LootColorsGui.Add("Button", "yp x+5 h20", "Resample " colorIdx)
			resBtn.OnEvent("Click", ResampleLootColor)
			continue
		}
		colorIdx++
		If (A_Index == 1)
		{
			LootColorsGui.Add("Text", "yp+38 xs+10", "Background " colorIdx " Colors: ")
			LootColorsGui.Add("Progress", "x+10 yp-5 w50 h20 c" color " BackgroundBlack",100)
			continue
		}
		LootColorsGui.Add("Text", "yp+29 xs+10", "Background " colorIdx " Colors: ")
		LootColorsGui.Add("Progress", "x+10 yp-5 w50 h20 c" color " BackgroundBlack",100)
	}
	LootColorsGui.Title := "Loot Vacuum settings"
	LootColorsGui.Show()

	AdjustLootGroup(ctrl, *) {
		Global LootColors, LootColorsGui
		LootColorsGui.Submit()
		ind := LootColors.Length
		If (ctrl.Name == "LG_Add")
		{
			LootColors.Push(0xFFFFFF)
			LootColors.Push(0xFFFFFF)
		}
		Else If (ctrl.Name == "LG_Rem" && ind > 2)
		{
			LootColors.Pop()
			LootColors.Pop()
		}
		LootColorsGui.Destroy()
		LootColorsMenu()
	}

	ResampleLootColor(ctrl, *) {
		Global LootColors, LootColorsGui, hotkeyLootScan, ScrCenter, GameH
		Global PauseTooltips
		; Thread, NoTimers, True ; Critical
		RemoveToolTip()
		PauseTooltips := 1
		groupNumber := StrSplit(ctrl.Text, A_Space)[2]
		MO_Index := (BG_Index := groupNumber * 2) - 1
		if WinExist("ahk_group POEGameGroup")
		{
			WinActivate("ahk_group POEGameGroup")
		} else {
			MsgBox("PoE Window does not exist. `nCannot sample the loot color.")
			Return
		}
		ToolTip("Press `"A`" to sample loot background"
			. "`nHold Escape and press `"A`" to cancel"
			, ScrCenter.X - 115 , ScrCenter.Y - GameH // 3)
		KeyWait("a", "D L")
		ToolTip()
		KeyWait("a")
		If GetKeyState("Escape", "P")
		{
			MsgBox("Escape key was held`n"
			. "Canceling the sample!")
			LootColorsGui.Show()
			Exit
		}
		if WinActive("ahk_group POEGameGroup"){
			BlockInput("MouseMove")
			MouseGetPos(&mX, &mY)
			FindText().ScreenShot(), BG_Color := FindText().GetColor(mX,mY)
			LootColors[BG_Index] := Format("0x{1:06X}",BG_Color)
			Sleep(100)
			SendInput("{" hotkeyLootScan " down}")
			Sleep(200)
			FindText().ScreenShot(), MO_Color := FindText().GetColor(mX,mY)
			LootColors[MO_Index] := Format("0x{1:06X}",MO_Color)
			SendInput("{" hotkeyLootScan " up}")
			BlockInput("MouseMoveOff")
		} else {
			MsgBox("PoE Window is not active. `nSampling the loot color didn't work")
			LootColorsGui.Show()
			Exit
		}
		LootColorsGui.Destroy()
		PauseTooltips := 0
		LootColorsMenu()
		Thread("NoTimers", false)    ;End Critical
	}

	SaveLootColorArray(*) {
		Global LootColors
		LCstr := hexArrToStr(LootColors)
		IniWrite(LCstr, A_ScriptDir "\save\Settings.ini", "Loot Colors", "LootColors")
		LootScan(1)
		MsgBox("LootColors saved with the following hex values:"
			. "`n" . LCstr)
	}

	; Pull SetBackgroundColor values out of a PoE .filter file and rebuild
	; LootColors from them. Only Show rules contribute (Hide / Disable rules
	; don't render on screen, so their colors are useless to the vacuum).
	; Each unique RGB becomes a pair where Mouseover is derived from Background
	; via HighlightColor; user can refine Mouseover per group with the in-game
	; Resample button if needed.
	;
	; Colors are ordered by NeverSink's value signals so the scanner prioritises
	; expensive items: primary key is max SetFontSize seen across the rules
	; using that color (NeverSink convention: 45=top-tier currency, 40=high,
	; 35=mid, 32=default, 25=low). Tiebreak by lowest PlayAlertSound number
	; (1 = mirror-tier), then by lowest section comment id (# [[NNNN]]).
	ImportLootColorsFromFilter(*) {
		Global LootColors, LootColorsGui
		Static BRIGHTNESS_MIN := 100   ; max(R,G,B) must exceed this to import
		initDir := A_MyDocuments "\My Games\Path of Exile"
		If !DirExist(initDir)
			initDir := ""
		filterPath := FileSelect(1, initDir ? initDir "\" : "", "Select Path of Exile loot filter", "Filter (*.filter)")
		If !filterPath
			Return
		If !FileExist(filterPath) {
			MsgBox("File not found:`n" filterPath)
			Return
		}
		; hex -> {fontSize, soundOrder, sectionId} preserving first-seen order.
		colorMeta := Map()
		skippedDim := 0
		inShow := False
		currentBg := ""
		currentFont := 32       ; NeverSink default for rules without SetFontSize
		currentSound := 9999    ; "no sound" rank - worse than any real sound
		currentSection := 9999  ; before any # [[NNNN]] has been seen
		Loop Read, filterPath
		{
			line := Trim(A_LoopReadLine)
			; Section marker like '# [[0200]] Gold' - update *outside* block
			; tracking so it applies to all subsequent rules.
			If RegExMatch(line, "#\s*\[\[(\d+)]]", &m) {
				currentSection := Integer(m[1])
				Continue
			}
			If !line || SubStr(line, 1, 1) == "#"
				Continue
			If (line ~= "i)^Show\b") {
				ImportCommitBlock(colorMeta, currentBg, currentFont, currentSound, currentSection)
				inShow := True
				currentBg := "", currentFont := 32, currentSound := 9999
				Continue
			}
			If (line ~= "i)^(Hide|Disable)\b") {
				ImportCommitBlock(colorMeta, currentBg, currentFont, currentSound, currentSection)
				inShow := False
				currentBg := ""
				Continue
			}
			If !inShow
				Continue
			If RegExMatch(line, "^SetBackgroundColor\s+(\d+)\s+(\d+)\s+(\d+)", &m) {
				r := Integer(m[1]), g := Integer(m[2]), b := Integer(m[3])
				; Skip dark filter backgrounds - max channel < 100 are typically
				; subtle NeverSink backgrounds (0x000014, 0x001414, etc.) that
				; overlap with random world/UI pixels and produce false positives.
				If (Max(r, g, b) < BRIGHTNESS_MIN) {
					skippedDim++
					currentBg := ""   ; mark as ineligible so we don't commit
					Continue
				}
				currentBg := Format("0x{1:06X}", (r << 16) | (g << 8) | b)
				Continue
			}
			If RegExMatch(line, "^SetFontSize\s+(\d+)", &m) {
				currentFont := Integer(m[1])
				Continue
			}
			If RegExMatch(line, "^PlayAlertSound\s+(\d+)", &m) {
				currentSound := Integer(m[1])
				Continue
			}
		}
		ImportCommitBlock(colorMeta, currentBg, currentFont, currentSound, currentSection)
		If !colorMeta.Count {
			MsgBox("No bright SetBackgroundColor entries (max channel >= "
				. BRIGHTNESS_MIN ") found in Show rules of:`n" filterPath)
			Return
		}
		; Build a sortable list, then insertion-sort by descending value:
		; primary -fontSize, secondary soundOrder asc, tertiary sectionId asc.
		sortable := []
		For hex, meta in colorMeta
			sortable.Push({hex: hex, fontSize: meta.fontSize, soundOrder: meta.soundOrder, sectionId: meta.sectionId})
		Loop sortable.Length - 1 {
			i := A_Index + 1
			key := sortable[i]
			j := i - 1
			While (j >= 1) {
				ex := sortable[j]
				better := (key.fontSize > ex.fontSize)
					|| (key.fontSize == ex.fontSize && key.soundOrder < ex.soundOrder)
					|| (key.fontSize == ex.fontSize && key.soundOrder == ex.soundOrder && key.sectionId < ex.sectionId)
				If !better
					Break
				sortable[j+1] := ex
				j--
			}
			sortable[j+1] := key
		}
		If (MsgBox("Found " sortable.Length " unique background colors in filter."
				. (skippedDim ? "`n(Skipped " skippedDim " dim entries with max channel < " BRIGHTNESS_MIN ".)" : "")
				. "`n`nReplace the current Loot Colors with these,"
				. " ordered highest-value first (by max FontSize, then alert-sound rank)?"
				. "`n`nThe Mouseover color of each pair will be derived from the Background"
				. " using PoE's approximate highlight formula. Use Resample per group"
				. " in-game if you need a tighter match."
				, "Import Loot Colors", "YesNo Icon?") != "Yes")
			Return
		newLC := []
		For item in sortable {
			newLC.Push(HighlightColor(item.hex))   ; Mouseover (odd index)
			newLC.Push(item.hex)                   ; Background (even index)
		}
		LootColors := newLC
		IniWrite(hexArrToStr(LootColors), A_ScriptDir "\save\Settings.ini", "Loot Colors", "LootColors")
		; Rebuild the LootScan ComboHex cache so the new colors take effect
		; immediately. Without this the running scanner keeps using the old
		; ComboHex from the previous LootColors until reload.
		LootScan(1)
		LootColorsGui.Destroy()
		LootColorsMenu()
	}

	; Helper for ImportLootColorsFromFilter: record (or update) the metadata for
	; the current Show block's background color. Maps are reference types in v2
	; so the mutation propagates back to the caller's colorMeta.
	ImportCommitBlock(metaMap, bg, font, sound, section) {
		If !bg
			Return
		If !metaMap.Has(bg) {
			metaMap[bg] := {fontSize: font, soundOrder: sound, sectionId: section}
			Return
		}
		m := metaMap[bg]
		If (font > m.fontSize)
			m.fontSize := font
		If (sound < m.soundOrder)
			m.soundOrder := sound
		If (section < m.sectionId)
			m.sectionId := section
	}

	LootColorsClose(GuiObj) {
		Global LootColorsGui
		LootColorsGui.Destroy()
		MainMenu()
	}
	LootColorsEscape(GuiObj) {
		Global LootColorsGui
		LootColorsGui.Destroy()
		MainMenu()
	}
}
