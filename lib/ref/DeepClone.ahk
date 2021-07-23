/* DeepClone v1 : A library of functions to make unlinked array Clone
;
; Function:
; Array_Print
; Description:
; Quick and dirty text visualization of an array
; Syntax:
; Arrary_Print(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value:
; A text visualization of the input array
; Remarks:
; Supports sub-arrays
; Related:
; Array_Gui, Array_DeepClone, Array_IsCircle
; Example:
; MsgBox, % Array_Print({"A":["Aardvark", "Antelope"], "B":"Bananas"})
;
;
; Function:
; Array_Gui
; Description:
; Displays an array as a treeview in a GUI
; Syntax:
; Array_Gui(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value:
; Null
; Remarks:
; Resizeable
; Related:
; Array_Print, Array_DeepClone, Array_IsCircle
; Example:
; Array_Gui({"GeekDude":["Smart", "Charming", "Interesting"], "tidbit":"Weird"})
;
;
; Function:
; Array_DeepClone
; Description:
; Deep clone
; Syntax:
; Arrary_DeepClone(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value:
; A copy of the array, that is not linked to the original
; Remarks:
; Supports sub-arrays, and circular refrences
; Related:
; Array_Gui, Array_Print, Array_IsCircle
; Example:
; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
; Array2 := Array_DeepClone(Array1)
;
;
; Function:
; Array_IsCircle
; Description:
; Checks for circular refrences that could crash my other functions
; Syntax:
; Arrary_IsCircle(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value:
; Boolean value according to whether it has a circular refrence
; Remarks:
; Takes an average of 0.023 seconds
; Related:
; Array_Gui, Array_Print(), Array_DeepClone()
; Example:
; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
; Array2 := Array_Copy(Array1)
;
*/

Array_Print(Array) {
	if Array_IsCircle(Array)
		return "Error: Circular refrence"
	For Key, Value in Array
	{
		If Key is not Number
			Output .= """" . Key . """:"
		Else
			Output .= Key . ":"
		
		If (IsObject(Value))
			Output .= "[" . Array_Print(Value) . "]"
		Else If Value is not number
			Output .= """" . Value . """"
		Else
			Output .= Value
		
		Output .= ", "
	}
	StringTrimRight, OutPut, OutPut, 2
	Return OutPut
}

Array_Gui(Array, Parent="") {
	static
	global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
	if Array_IsCircle(Array)
	{
		MsgBox, 16, GuiArray, Error: Circular refrence
		return "Error: Circular refrence"
	}
	if !Parent
	{
		Gui, +HwndDefault
		Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
		Gui, Add, TreeView, vGuiArrayTree
		
		Parent := "P1"
		%Parent% := TV_Add("Array", 0, "+Expand")
		Array_Gui(Array, Parent)
		GuiControlGet, GuiArrayTree, Pos
		Gui, Show,, GuiArray
		Gui, %Default%:Default
		
		WinWaitActive, ahk_id%GuiArray%
		WinWaitClose, ahk_id%GuiArray%
		return
	}
	For Key, Value in Array
	{
		%Parent%C%A_Index% := TV_Add(Key, %Parent%)
		KeyParent := Parent "C" A_Index
		if (IsObject(Value))
			Array_Gui(Value, KeyParent)
		else
			%KeyParent%C1 := TV_Add(Value, %KeyParent%)
	}
	return
	
	GuiArrayClose:
	Gui, Destroy
	return
	
	GuiArraySize:
	if !(A_GuiWidth || A_GuiHeight) ; Minimized
		return
	GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX* 2) " h" A_GuiHeight - (GuiArrayTreeY* 2)
	return
}

Array_DeepClone(Array, Objs=0)
{
	if !Objs
		Objs := {}
	Obj := Array.Clone()
	Objs[&Array] := Obj ; Save this new array
	For Key, Val in Obj
		if (IsObject(Val)) ; If it is a subarray
			Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
			? Objs[&Val] ; Then point it to the new array
			: Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
	return Obj
}

Array_IsCircle(Obj, Objs=0)
{
	if !Objs
		Objs := {}
	For Key, Val in Obj
		if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
			return 1
	return 0
}

Array_IsLinear(arr, i=0) {
	For k, v in arr {
		If (++i != k)
			Return 0
	}
	Return 1
}

