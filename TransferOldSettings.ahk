#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if not A_IsAdmin
    if A_IsCompiled
    Run *RunAs "%A_ScriptFullPath%" /restart
else
    Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"

Sleep, 200

IniRead, Sections, settings.ini

MsgBox, 3, Transfer Profiles, Would you like to transfer your profiles?

IfMsgBox, Cancel
ExitApp

IfMsgBox, Yes
{
    If InStr(Sections, "Profiles")
    {
        IniRead, ProfileStr, settings.ini, Profiles
        IniWrite, %ProfileStr%, profiles.ini, Profiles
        IniDelete, settings.ini, Profiles
    }
    Loop 10
    {
        If InStr(Sections, "Profile" . A_Index)
        {
            IniRead, ProfileStr, settings.ini, Profile%A_Index%
            IniWrite, %ProfileStr%, profiles.ini, Profile%A_Index%
            IniDelete, settings.ini, Profile%A_Index%
        }
    }
}

MsgBox, 3, Convert BGR to RGB, Would you like to convert old samples to RGB?

IfMsgBox, Cancel
ExitApp

IfMsgBox, Yes
{
    SectionList := [ "Failsafe Colors"
        , "Inventory Colors"
        , "Life Colors"
        , "ES Colors"
        , "Mana Colors"
        , "Loot Colors" ]
    For k, items in SectionList
    If InStr(Sections, items)
    {
        IniRead, ColorStr, settings.ini, %items%
        ColorStr := RegExReplace(ColorStr, "0x(\w{2})(\w{2})(\w{2})", "0x$3$2$1")
        IniWrite, %ColorStr%, settings.ini, %items%
    }
}

If InStr(Sections, "Loot Colors")
{
    MsgBox, 3, Loot Vacuum Colors, The colors for the script have been changed in sequence and number`nIt is recommended to delete the key so you can load new defaults`nClick Yes to delete the key to load defaults`nClick Cancel to quit
    IfMsgBox, Yes
    {
        IniDelete, settings.ini, "Loot Colors"
    }
}

ExitApp