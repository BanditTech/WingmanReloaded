SETLOCAL
ECHO OFF
SET run_as=C:\Windows\System32\runas.exe

REM Name of the local user account you are having launch the EXE
SET local_user=ReplaceWithUserName

REM Possible EXE names: PathOfExile.exe, PathOfExile_x64.exe, PathOfExileSteam.exe, PathOfExile_x64Steam.exe, PathOfExile_KG.exe, PathOfExile_x64_KG.exe
SET exe_name=PathOfExile_x64.exe

REM You can launch the game with additional Parameters
SET exe_params=--nologo --waitforpreload

REM Keep in mind because of strange reasons this one must have / instead of \
SET exe_path=C:/Program Files (x86)/Grinding Gear Games/Path of Exile/

REM Make sure to change this drive letter if not on C: drive
CD C:

REM Now we run the code you provided
TASKLIST /fi "IMAGENAME eq %exe_name%" 2>NUL | FIND /I /N "%exe_name%">NUL
IF NOT "%ERRORLEVEL%"=="0" START %run_as% /user:%local_user% /savecred "cmd /C cd /D \"%exe_path%\" && Start /high %exe_name% %exe_params%"



REM ---------------
REM Scripts Section
REM ---------------

REM Place all scripts in subfolders one directory
SET scripts_path=C:\Path\To\The\Path of Exile\Scripts


REM Name of the script to run
SET script_1_name=PoE-Wingman.ahk
REM Which subdirectory of the scripts folder
SET script_1_subpath=WingmanReloaded
REM What to look for as an active process in AHK
SET script_1_searchString=PoE-Wingman.ahk ahk_exe AutoHotkey.exe
REM Build the Path from supplied values
SET script_1_path=%scripts_path%\%script_1_subpath%\%script_1_name%


REM Script 2
SET script_2_name=Awakened PoE Trade.exe
SET script_2_searchString=ahk_exe %script_2_name%
REM Build the Path
SET script_2_path=C:\Program Files\Awakened PoE Trade\%script_2_name%


REM Script 3
SET script_3_name=POE Trades Companion.ahk
SET script_3_subpath=POE-Trades Companion
SET script_3_searchString=%script_3_name% ahk_exe AutoHotkey.exe
REM Build the Path
SET script_3_path=%scripts_path%\%script_3_subpath%\%script_3_name%


REM Send script to AutoHotkey to evaluate for hidden window titles
(
ECHO #NoTrayIcon
ECHO SetTitleMatchMode, 2
ECHO DetectHiddenWindows On
ECHO If !WinExist^("%script_1_searchString%"^^^)
ECHO Run %script_1_path%
ECHO If !WinExist^("%script_2_searchString%"^^^)
ECHO Run %script_2_path%
ECHO If !WinExist^("%script_3_searchString%"^^^)
ECHO Run %script_3_path%
ECHO ExitApp

)| "C:\Program Files\AutoHotkey\AutoHotkey.exe" *