Class 7za {
  Static ExeFile := A_ScriptDir "\data\7za.exe"
  Static AddArgs := "a -w""" A_ScriptDir """ -t7z -x!backup\ -x!.git\ -x!.github\ -x!github\ -x!.vscode\"
  Static SourceFile := ".\*"
  Static LogOutput := A_ScriptDir "\logs\Archive.log"
  Static Mtee := A_ScriptDir "\data\Mtee.exe"
  Static Source := A_ScriptDir "\data\source.zip"
  backup(){
    ToZip := A_ScriptDir "\backup\" A_Now ".7z"
    RunWait % comspec " /c "" """ This.ExeFile """ " This.AddArgs " """ ToZip """ """ This.SourceFile """ | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
  }
  restore(date){
    loc := A_ScriptDir "\backup\" date ".7z"
    If FileExist(loc){
      ExtArgs := "x """ loc """ -o""" A_ScriptDir """ -y"
      RunWait % comspec " /c "" """ This.ExeFile """ " ExtArgs " | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
    }
  }
  install(branch){
    Static Acc := "BanditTech"
    Static Proj := "WingmanReloaded"
    Link := "https://github.com/" Acc "/" Proj "/archive/refs/heads/" branch ".zip"
    This.backup()      
    UrlDownloadToFile,% Link,% This.Source
    ExtArgs := "x """ This.Source """ -o""" A_ScriptDir """ -y"
    subfolder := Proj "-" branch
    RunWait % comspec " /c "" """ This.ExeFile """ " ExtArgs " | """ This.Mtee """ /D/T/+ """ This.LogOutput """ """,, hide UseErrorLevel, ZipPID
    MoveArgs := "ROBOCOPY " subfolder " /S /IT """ A_ScriptDir """ /MOVE"
    RunWait % comspec " /c " MoveArgs,,hide
    RemoveArgs := "rmdir /s /q " subfolder
    RunWait % comspec " /c " RemoveArgs,,hide
  }
}
