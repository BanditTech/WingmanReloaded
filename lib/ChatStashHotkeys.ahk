; Register and UnRegister Hotkeys - Register Chat and Stash Hotkeys
RegisterHotkeys() {
	global
	Gui Submit, NoHide

	fn1 := Func("1HotkeyShouldFire").Bind(1Prefix1,1Prefix2,EnableChatHotkeys)
	Hotkey If, % fn1
	Loop, 9 {
		If 1Suffix%A_Index%
		{
			1bind%A_Index% := Func("FireHotkey").Bind("Enter","1",A_Index)
			Hotkey,% "*" 1Suffix%A_Index%,% 1bind%A_Index%, On
		}
	}
	fn2 := Func("2HotkeyShouldFire").Bind(2Prefix1,2Prefix2,EnableChatHotkeys)
	Hotkey If, % fn2
	Loop, 9 {
		If 2Suffix%A_Index%
		{
			2bind%A_Index% := Func("FireHotkey").Bind("CtrlEnter","2",A_Index)
			Hotkey,% "*" 2Suffix%A_Index%,% 2bind%A_Index%, On
		}
	}
	fn3 := Func("stashHotkeyShouldFire").Bind(stashPrefix1,stashPrefix2,YesStashKeys)
	Hotkey If, % fn3
	Loop, 9 {
		If stashSuffix%A_Index%
		{
			stashbind%A_Index% := Func("FireHotkey").Bind("Stash","stash", "Tab" A_Index)
			Hotkey,% "~*" stashSuffix%A_Index%,% stashbind%A_Index%, On
		}
	}
	Return
}
UnRegisterHotkeys(){
	global
	Hotkey If, % fn1
		Loop, 9
	{
		If 1Suffix%A_Index%
		{
			1bind%A_Index% := Func("FireHotkey").Bind("Enter","1",A_Index)
			Hotkey,% "*" 1Suffix%A_Index%,% 1bind%A_Index%, off
		}
	}
	Hotkey If, % fn2
		Loop, 9
	{
		If 2Suffix%A_Index%
		{
			2bind%A_Index% := Func("FireHotkey").Bind("CtrlEnter","2",A_Index)
			Hotkey,% "*" 2Suffix%A_Index%,% 2bind%A_Index%, off
		}
	}
	Hotkey If, % fn3
		Loop, 9
	{
		If stashSuffix%A_Index%
		{
			stashbind%A_Index% := Func("FireHotkey").Bind("Stash","stash", "Tab" A_Index)
			Hotkey,% "*" stashSuffix%A_Index%,% stashbind%A_Index%, off
		}
	}
	Return
}
; HotkeyShouldFire - Functions to evaluate keystate
1HotkeyShouldFire(1Prefix1, 1Prefix2, EnableChatHotkeys, thisHotkey) {
	IfWinActive, ahk_group POEGameGroup
	{
		If (EnableChatHotkeys){
			If ( 1Prefix1 && 1Prefix2 ){
				If ( GetKeyState(1Prefix1) && GetKeyState(1Prefix2) )
					return True
				Else
					return False
			}
			Else If ( 1Prefix1 && !1Prefix2 ) {
				If ( GetKeyState(1Prefix1) ) 
					return True
				Else
					return False
			}
			Else If ( !1Prefix1 && 1Prefix2 ) {
				If ( GetKeyState(1Prefix2) ) 
					return True
				Else
					return False
			}
			Else If ( !1Prefix1 && !1Prefix2 ) {
				return True
			}
		} 
	}
	Else {
		Return False
	}
}
2HotkeyShouldFire(2Prefix1, 2Prefix2, EnableChatHotkeys, thisHotkey) {
	IfWinActive, ahk_group POEGameGroup
	{
		If (EnableChatHotkeys){
			If ( 2Prefix1 && 2Prefix2 ){
				If ( GetKeyState(2Prefix1) && GetKeyState(2Prefix2) )
					return True
				Else
					return False
			}
			Else If ( 2Prefix1 && !2Prefix2 ) {
				If ( GetKeyState(2Prefix1) ) 
					return True
				Else
					return False
			}
			Else If ( !2Prefix1 && 2Prefix2 ) {
				If ( GetKeyState(2Prefix2) ) 
					return True
				Else
					return False
			}
			Else If ( !2Prefix1 && !2Prefix2 ) {
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
	IfWinActive, ahk_group POEGameGroup
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
FireHotkey(func:="CtrlEnter",TypePrefix:="2",SuffixNum:="1"){
	; Enter func is Prefix 1, CtrlEnter func is Prefix 2
	; Stash func is Prefix stash with SuffixNum of Tab#
	IfWinActive, ahk_group POEGameGroup
	{
		If (func = "Enter")
		{
			tempStr := StrReplace(%TypePrefix%Suffix%SuffixNum%Text, "CharacterName", CharName, 0, -1)
			tempStr := StrReplace(tempStr, "RecipientName", RecipientName, 0, -1)
			tempStr := StrReplace(tempStr, "!", "{!}", 0, -1)
			Send, {Enter}%tempStr%{Enter}
			ResetChat()
		}
		Else If (func = "CtrlEnter")
		{
			GrabRecipientName()
			tempStr := StrReplace(%TypePrefix%Suffix%SuffixNum%Text, "CharacterName", CharName, 0, -1)
			tempStr := StrReplace(tempStr, "RecipientName", RecipientName, 0, -1)
			tempStr := StrReplace(tempStr, "!", "{!}", 0, -1)
			Send, ^{Enter}%tempStr%{Enter}
			ResetChat()

		}
		Else If (func = "Stash")
		{
			MoveStash(%TypePrefix%Suffix%SuffixNum%,1)
		}
	}
	Return
}

; Reset Chat
ResetChat(){
	Send {Enter}{Up}{Escape}
	return
}

; Grab Reply whisper recipient
GrabRecipientName(){
	CopyClip := Clipboard
	Clipboard := ""
	Send ^{Enter}^{A}^{C}{Escape}
	ClipWait, 0
	Content := Clipboard
	Clipboard := CopyClip
	If (Content ~= "^@"){
		RecipientName := StrSplit(Content, " ", "@").1
		Return RecipientName
	}
	Else
		Return False
}
