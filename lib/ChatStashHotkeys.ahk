; Register and UnRegister Hotkeys - Register Chat and Stash Hotkeys
RegisterHotkeys() {
	Global fn1, fn2, fn3

	fn1 := c1HotkeyShouldFire.Bind(c1Prefix1,c1Prefix2,EnableChatHotkeys)
	HotIf(fn1)
	local c1Suffixes := [c1Suffix1,c1Suffix2,c1Suffix3,c1Suffix4,c1Suffix5,c1Suffix6,c1Suffix7,c1Suffix8,c1Suffix9]
	For i, suf in c1Suffixes {
		If suf {
			local c1b := FireHotkey.Bind("Enter","c1",i)
			Hotkey("*" suf, c1b, "On")
		}
	}
	fn2 := c2HotkeyShouldFire.Bind(c2Prefix1,c2Prefix2,EnableChatHotkeys)
	HotIf(fn2)
	local c2Suffixes := [c2Suffix1,c2Suffix2,c2Suffix3,c2Suffix4,c2Suffix5,c2Suffix6,c2Suffix7,c2Suffix8,c2Suffix9]
	For i, suf in c2Suffixes {
		If suf {
			local c2b := FireHotkey.Bind("CtrlEnter","c2",i)
			Hotkey("*" suf, c2b, "On")
		}
	}
	fn3 := stashHotkeyShouldFire.Bind(stashPrefix1,stashPrefix2,YesStashKeys)
	HotIf(fn3)
	local stashSuffixes := [stashSuffix1,stashSuffix2,stashSuffix3,stashSuffix4,stashSuffix5,stashSuffix6,stashSuffix7,stashSuffix8,stashSuffix9]
	For i, suf in stashSuffixes {
		If suf {
			local sb := FireHotkey.Bind("Stash","stash",i)
			Hotkey("~*" suf, sb, "On")
		}
	}
	Return
}
UnRegisterHotkeys(){
	Global fn1, fn2, fn3
	HotIf(fn1)
	local c1Suffixes := [c1Suffix1,c1Suffix2,c1Suffix3,c1Suffix4,c1Suffix5,c1Suffix6,c1Suffix7,c1Suffix8,c1Suffix9]
	For i, suf in c1Suffixes {
		If suf {
			local c1b := FireHotkey.Bind("Enter","c1",i)
			Hotkey("*" suf, c1b, "Off")
		}
	}
	HotIf(fn2)
	local c2Suffixes := [c2Suffix1,c2Suffix2,c2Suffix3,c2Suffix4,c2Suffix5,c2Suffix6,c2Suffix7,c2Suffix8,c2Suffix9]
	For i, suf in c2Suffixes {
		If suf {
			local c2b := FireHotkey.Bind("CtrlEnter","c2",i)
			Hotkey("*" suf, c2b, "Off")
		}
	}
	HotIf(fn3)
	local stashSuffixes := [stashSuffix1,stashSuffix2,stashSuffix3,stashSuffix4,stashSuffix5,stashSuffix6,stashSuffix7,stashSuffix8,stashSuffix9]
	For i, suf in stashSuffixes {
		If suf {
			local sb := FireHotkey.Bind("Stash","stash",i)
			Hotkey("*" suf, sb, "Off")
		}
	}
	Return
}
; HotkeyShouldFire - Functions to evaluate keystate
c1HotkeyShouldFire(p1, p2, EnableChatHotkeys, thisHotkey) {
	if WinActive("ahk_group POEGameGroup")
	{
		If (EnableChatHotkeys){
			If ( p1 && p2 ){
				If ( GetKeyState(p1) && GetKeyState(p2) )
					return True
				Else
					return False
			}
			Else If ( p1 && !p2 ) {
				If ( GetKeyState(p1) )
					return True
				Else
					return False
			}
			Else If ( !p1 && p2 ) {
				If ( GetKeyState(p2) )
					return True
				Else
					return False
			}
			Else If ( !p1 && !p2 ) {
				return True
			}
		}
	}
	Else {
		Return False
	}
}
c2HotkeyShouldFire(p1, p2, EnableChatHotkeys, thisHotkey) {
	if WinActive("ahk_group POEGameGroup")
	{
		If (EnableChatHotkeys){
			If ( p1 && p2 ){
				If ( GetKeyState(p1) && GetKeyState(p2) )
					return True
				Else
					return False
			}
			Else If ( p1 && !p2 ) {
				If ( GetKeyState(p1) )
					return True
				Else
					return False
			}
			Else If ( !p1 && p2 ) {
				If ( GetKeyState(p2) )
					return True
				Else
					return False
			}
			Else If ( !p1 && !p2 ) {
				return True
			}
		}
		Else
			Return False
	}
	Else {
		Return False
	}
}
stashHotkeyShouldFire(stashPrefix1, stashPrefix2, YesStashKeys, thisHotkey) {
	if WinActive("ahk_group POEGameGroup")
	{
		If (YesStashKeys){
			If ( stashPrefix1 && stashPrefix2 ){
				If ( GetKeyState(stashPrefix1) && GetKeyState(stashPrefix2) )
					return True
				Else
					return False
			}
			Else If ( stashPrefix1 && !stashPrefix2 ) {
				If ( GetKeyState(stashPrefix1) )
					return True
				Else
					return False
			}
			Else If ( !stashPrefix1 && stashPrefix2 ) {
				If ( GetKeyState(stashPrefix2) )
					return True
				Else
					return False
			}
			Else If ( !stashPrefix1 && !stashPrefix2 ) {
				return True
			}
		}
		Else
			Return False
	}
	Else {
		Return False
	}
}

; FireHotkey - Functions to Send each hotkey
; Enter func uses chat group c1, CtrlEnter func uses chat group c2
; Stash func uses stash prefix with SuffixNum as the slot index (1-9)
FireHotkey(func:="CtrlEnter",TypePrefix:="c2",SuffixNum:=1){
	if WinActive("ahk_group POEGameGroup")
	{
		If (func = "Enter")
		{
			local c1Texts := [c1Suffix1Text,c1Suffix2Text,c1Suffix3Text,c1Suffix4Text,c1Suffix5Text,c1Suffix6Text,c1Suffix7Text,c1Suffix8Text,c1Suffix9Text]
			tempStr := StrReplace(c1Texts[SuffixNum], "CharacterName", CharName, , -1)
			tempStr := StrReplace(tempStr, "RecipientName", RecipientName, , -1)
			tempStr := StrReplace(tempStr, "!", "{!}", , -1)
			Send("{Enter}" tempStr "{Enter}")
			ResetChat()
		}
		Else If (func = "CtrlEnter")
		{
			GrabRecipientName()
			local c2Texts := [c2Suffix1Text,c2Suffix2Text,c2Suffix3Text,c2Suffix4Text,c2Suffix5Text,c2Suffix6Text,c2Suffix7Text,c2Suffix8Text,c2Suffix9Text]
			tempStr := StrReplace(c2Texts[SuffixNum], "CharacterName", CharName, , -1)
			tempStr := StrReplace(tempStr, "RecipientName", RecipientName, , -1)
			tempStr := StrReplace(tempStr, "!", "{!}", , -1)
			Send("^{Enter}" tempStr "{Enter}")
			ResetChat()
		}
		Else If (func = "Stash")
		{
			local stashTabs := [stashSuffixTab1,stashSuffixTab2,stashSuffixTab3,stashSuffixTab4,stashSuffixTab5,stashSuffixTab6,stashSuffixTab7,stashSuffixTab8,stashSuffixTab9]
			MoveStash(stashTabs[SuffixNum], 1)
		}
	}
	Return
}

; Reset Chat
ResetChat(){
	Send("{Enter}{Up}{Escape}")
	return
}

; Grab Reply whisper recipient
GrabRecipientName(){
	CopyClip := Clipboard
	Clipboard := ""
	Send("^{Enter}^{A}^{C}{Escape}")
	ClipWait(0)
	Content := Clipboard
	Clipboard := CopyClip
	If (Content ~= "^@"){
		RecipientName := StrSplit(Content, " ", "@").1
		Return RecipientName
	}
	Else
		Return False
}
