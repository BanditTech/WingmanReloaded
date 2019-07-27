#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , thisscriptname
#MaxThreadsPerHotkey, 1 ; no re-entrant hotkey handling
; DetectHiddenWindows, On
; SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag



; Removed from MoveStash


		If (YesUltraWide=1)
			MouseMove, (A_ScreenWidth/(3840/640)), (A_ScreenHeight/(1080/146)), 0
		Else


		If (YesUltraWide=1)
			MouseMove, (A_ScreenWidth/(3840/640)), (A_ScreenHeight/(1080/146)), 0
		Else


;removed from ScaleRes

	If (YesUltraWide=1)
		Rx:=Round(A_ScreenWidth / (3840 / x))
	Else


; removed from submit()

			If (YesUltraWide=1)
				vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
			Else

			If (YesUltraWide=1)
				vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
			Else
			If (YesUltraWide=1)
				vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
			Else


; Removed from updateOnHideout

			If (YesUltraWide=1)
				{
				vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
				}
			Else
				{

				}


; Removed from updateOnChar


			If (YesUltraWide=1)
			{
			vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
			}
			Else
			{

			}

; Removed from update OnInventory

			If (YesUltraWide=1)
				{
				vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
				}
			Else
				{

				}


; Removed from updatedOnStash

			If (YesUltraWide=1)
				{
				vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
				}
			Else
				{

				}


; Removed from updateOnChat
			If (YesUltraWide=1)
			{
			vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
			}
			Else
			{

			}

; Removed from updateOnVendor

			If (YesUltraWide=1)
			{
			vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
			}
			Else
			{

			}

; Removed from updateDetonate

			If (YesUltraWide=1)
			{
			DetonateX:=X + Round(A_ScreenWidth / (3840 / 3578))
			}
			Else
			{

			}

; Removed from updateDetonateDelve

			If (YesUltraWide=1)
			{
			DetonateDelveX:=X + Round(A_ScreenWidth / (3840 / 3578))
			}
			Else
			{

			}


; Removed from Scaling:

			If (YesUltraWide=1)
				{
				Global InventoryGridX := [ Round(A_ScreenWidth/(3840/3194)), Round(A_ScreenWidth/(3840/3246)), Round(A_ScreenWidth/(3840/3299)), Round(A_ScreenWidth/(3840/3352)), Round(A_ScreenWidth/(3840/3404)), Round(A_ScreenWidth/(3840/3457)), Round(A_ScreenWidth/(3840/3510)), Round(A_ScreenWidth/(3840/3562)), Round(A_ScreenWidth/(3840/3615)), Round(A_ScreenWidth/(3840/3668)), Round(A_ScreenWidth/(3840/3720)), Round(A_ScreenWidth/(3840/3773)) ]
				Global DetonateDelveX:=X + Round(A_ScreenWidth/(3840/3462))
				Global DetonateX:=X + Round(A_ScreenWidth/(3840/3578))
				Global WisdomStockX:=X + Round(A_ScreenWidth/(3840/125))
				Global PortalStockX:=X + Round(A_ScreenWidth/(3840/175))
				global vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
				global vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
				global vX_OnChat:=X + Round(A_ScreenWidth / (3840 / 0))
				global vX_OnInventory:=X + Round(A_ScreenWidth / (3840 / 3503))
				global vX_OnStash:=X + Round(A_ScreenWidth / (3840 / 336))
				global vX_OnVendor:=X + Round(A_ScreenWidth / (3840 / 1578))
				global vX_Life:=X + Round(A_ScreenWidth / (3840 / 95))
				global vX_ES:=X + Round(A_ScreenWidth / (3840 / 180))
				global vX_Mana:=X + Round(A_ScreenWidth / (3840 / 3745))
				}
			Else
				{

				}


; removed from gottagofast

	If (YesUltraWide)
		{
		global vX_OnHideout:=X + Round(	A_ScreenWidth / (3840 / 3161))
		global vX_OnChar:=X + Round(A_ScreenWidth / (3840 / 41))
		}
	Else
		{

		}
