; Rerun as admin if not already admin, required to disconnect client
if not A_IsAdmin
	if A_IsCompiled
		Run *RunAs "%A_ScriptFullPath%" /restart
	else
		Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
Sleep, -1