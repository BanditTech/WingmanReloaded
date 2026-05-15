CheckAspectRatio(*){
	v := GameW/GameH
	If GamePID
		MsgBox(v=16/9?"Standard 16:9"
						:v=12/9?"Classic 12:9 (4:3)"
						:v=21/9?"Cinematic 21:9"
						:v=43/18?"Cinematic 21.5:9 (43:18)"
						:v=32/9?"UltraWide 32:9"
						:v=16/10?"WXGA 16:10"
						:"The script does not have a matching aspect ratio", "Game Aspect Ratio", 262144)
	Else
		MsgBox("Open the game to calculate its window ratio", "Game Aspect Ratio", 262144)
}
