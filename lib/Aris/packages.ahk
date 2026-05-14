; Avoid modifying this file manually
; Managed by Aris - https://github.com/Descolada/Aris

; Third-party libraries may shadow our globals — suppress for library code only.
#Warn LocalSameAsGlobal, Off

; --- Aris-indexed packages ---
#include .\G33kDude\cJson.ahk          ; G33kDude/cJson@2.1.0
#include .\buliasz\Gdip.ahk            ; buliasz/Gdip@9fa1817
#include .\Cebolla\DeepClone.ahk       ; Cebolla/DeepClone@6ec6ff5
#include .\feiyue\FindText.ahk         ; feiyue/FindText@3ffe6b6
#include .\Chunjee\adash.ahk           ; Chunjee/adash@v0.6.0

; --- Manually installed packages (not in Aris index) ---
#include .\lexikos\XInput.ahk          ; lexikos/XInput@3ffe6b6 (via ahkscript/ScriptHub)
#include .\XMCQCX\Notify.ahk           ; XMCQCX/Notify@a66df2f
#include .\FanaticGuru\Fractions.ahk   ; FanaticGuru/Fractions@2023-08-28
