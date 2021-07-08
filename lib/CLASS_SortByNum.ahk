Class SortByNum {
	__New(sortlist,maxOver:=14,min:=40){
		; Initiate values, get the total number of potential groups
		This.Excess := AHK.reverse(AHK.sortBy(sortlist,"Q"))
		This.Min := min
		This.Max := This.Min + maxOver
		This.MaxOver := maxOver
		This.TotalQ := This.GetQ(This.Excess)
		This.TotalNum := This.Excess.Count()
		This.Mean := Round(AHK.meanBy(This.Excess,"Q"))
		; Find the optimum starting number of groups, then create them
		This.GetGroupNum()
		This.BuildSortGroups()
		; Unload some processing by First Fit
		This.FillBinsFirstFit()
		; This.FillBinsFirstFit()
		; Try to intelligently fill the remainder
		This.FillBinsMulti(3) ; 2 layers deep to avoid strain on larger list
		; Then try to reduce the overQ if any possible swap is available
		; This.SwapForBetter()
		This.BreakDownGroups()
		This.SwapForBetter()
		; Now we check for any remaining possible groups
		This.CheckForFilledGroups()
		This.BreakDownGroups()
		This.SwapForBetter()
		This.CheckForFilledGroups()
		; With all groups hopefully filled, we destroy any below min
		This.BreakDownGroups()
		This.ReSort()

		This.EndCounts := This.GetCounts()
		This.ExcessQ := This.GetQ(This.Excess)
		; This.FinalMessage()
		Return This.SortGroups
	}
	FinalMessage(){
		txt := ""
		For k, bin in This.SortGroups {
			txt .= "<" This.GetQ(bin) ">"
			for kk, vv in bin
				txt .= " " vv.Q
			txt .= "`n"
		}
		txt .= "Excess:" This.ExcessQ " Count:" This.Excess.Count() "`n"
		For k, v in This.Excess {
			txt .= v.Q " "
		}
		Tooltip % txt
	}
	SwapForBetter(){
		While (Results := This.MultiSwap() ) {
			binNum := Results.1.1
			binKey := Results.1.2
			binKey2 := Results.1.3
			key := Results.2.1
			fetch := This.SortGroups[binNum][binKey]
			fetch2 := This.SortGroups[binNum][binKey2]
			replace := This.Excess[key]
			This.SortGroups[binNum].RemoveAt(binKey2)
			This.SortGroups[binNum].RemoveAt(binKey)
			This.SortGroups[binNum].Push(replace)
			This.Excess.RemoveAt(key)
			This.Excess.Push(fetch)
			This.Excess.Push(fetch2)
			; This.ReSort()
		}
		While (Results := This.Swap() ) {
			binNum := Results.1.1
			binKey := Results.1.2
			key1 := Results.2.1
			key2 := Results.2.2
			fetch := This.SortGroups[binNum][binKey]
			replace := This.Excess[key1]
			If key2 {
				replace2 := This.Excess[key2]
				This.SortGroups[binNum].Push(replace2)
			}
			This.SortGroups[binNum].RemoveAt(binKey)
			This.SortGroups[binNum].Push(replace)
			If key2
				This.Excess.RemoveAt(key2)
			This.Excess.RemoveAt(key1)
			This.Excess.Push(fetch)
			; This.ReSort()
		}
	}
	Swap(){
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ <= This.Min)
				Continue
			overQ := groupQ - This.Min
			For binKey, binObj in bin {
				; Going through each bin, finding replacements to lower overQ
				For key1, obj1 in This.Excess {
					newQ := groupQ - binObj.Q + obj1.Q
					If (newQ >= This.Min && newQ - This.Min < overQ)
						Return [[binNum,binKey],[key1]]
					Else {
						For key2, obj2 in This.Excess {
							If (key1 = key2)
								Continue 1
							newQ := groupQ - binObj.Q + obj1.Q + obj2.Q
							If (newQ >= This.Min && newQ - This.Min < overQ)
								Return [[binNum,binKey],[key1,key2]]
						}
					}
				}
			}
		}
		Return False
	}
	MultiSwap(){
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ <= This.Min)
				Continue
			overQ := groupQ - This.Min
			For binKey, binObj in bin {
				; Going through each bin, finding replacements to lower overQ
				For binKey2, binObj2 in bin {
					If (binKey2 = binKey)
						Continue
					For key, obj in This.Excess {
						newQ := groupQ - binObj.Q - binObj2.Q + obj.Q
						If (newQ >= This.Min && newQ - This.Min < overQ){
							Return [[binNum,binKey,binKey2],[key]]
						}
					}
				}
			}
		}
		Return False
	}
	BreakDownGroups(){
		cleanup := []
		For binNum, bin in This.SortGroups {
			If (This.GetQ(bin) < This.Min)
				cleanup.Push(binNum)
		}
		For k, v in cleanup
			This.ReturnToExcess(v)
		This.StripOut()
	}
	StripOut(){
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ <= This.Min)
				Continue
			For key, obj in bin {
				If (groupQ - obj.Q >= This.Min){
					This.ReturnToExcess(binNum,key)
					; Return True
					This.StripOut()
				}
			}
		}
	}
	ReturnToExcess(binNum,tkey:=""){
		For key, obj in This.SortGroups[binNum] {
			If (tkey="" || tkey && key = tkey)
				This.Excess.Push(obj)
		}
		If (tkey="")
			This.SortGroups.Delete(binNum)
		Else
			This.SortGroups[binNum].RemoveAt(tkey)
	}
	GroupsAreFull(){
		For k, bin in This.SortGroups {
			If (This.GetQ(bin) < This.Min) 
				Return False
		}
		Return True
	}
	CheckForFilledGroups(){
		; Check if all groups have filled
		If !This.GroupsAreFull(){
			This.FillBinsFirstFit()
			This.FillBinsFirstFit()
			This.FillBinsMulti(4)
			This.StripOut()
		}
		This.BreakDownGroups()
		While (This.GetQ(This.Excess) >= This.Min) {
			This.ReSort(), This.AddGroup(), This.StripOut(), This.SwapForBetter()
		}
		This.AddGroup()
	}
	AddGroup(){
		This.SortGroups.Push([])
		This.FillBinsFirstFit()
		This.FillBinsFirstFit()
		This.FillBinsMulti(4)
	}
	FillBinsFirstFit(startingKey:=1) {
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ >= This.Min)
				Continue
			Results := This.FirstFit(bin,startingKey)
			If Results
				This.AddToBin(binNum,Results)
		}
	}
	FillBinsFirstFill() {
		This.Excess := AHK.sortBy(This.Excess,"Q")
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ >= This.Min)
				Continue
			Results := This.FirstFill(bin)
			If Results
				This.AddToBin(binNum,Results)
		}
	}
	FirstFit(bin,startingKey:=1){
		groupQ := This.GetQ(bin)
		If (groupQ >= This.Min)
			Return False
		For key, obj in This.Excess {
			If (key < startingKey)
				Continue
			If ((groupQ + obj.Q) <= This.Max) {
				Return [key]
			}
		}
	}
	FirstFill(bin){
		groupQ := This.GetQ(bin)
		tally := 0
		keys := []
		If (groupQ >= This.Min)
			Return False
		For key, obj in This.Excess {
			If (groupQ + tally + obj.Q <= This.Max) {
				keys.Push(key), tally += obj.Q
			}
		}
		; If groupQ + tally >= This.Min
		Return keys
		; Return False
	}
	FillBinsMulti(depth:=2) {
		For binNum, bin in This.SortGroups {
			groupQ := This.GetQ(bin)
			If (groupQ >= This.Min)
				Continue
			Results := This.MultiFit(bin,depth)
			If Results
				This.AddToBin(binNum,Results)
		}
	}
	MultiFit(bin,depth:=2){
		groupQ := This.GetQ(bin)
		If (groupQ >= This.Min)
			Return False
		For FirstKey, FirstObj in This.Excess {
			If ((groupQ + FirstObj.Q) >= This.Min && (groupQ + FirstObj.Q) <= This.Max) {
				Return [FirstKey]
			} Else If (depth >= 2) {
				For SecondKey, SecondObj in This.Excess {
					If (FirstKey = SecondKey)
						Continue 1
					If ((groupQ + FirstObj.Q + SecondObj.Q) >= This.Min && (groupQ + FirstObj.Q + SecondObj.Q) <= This.Max) {
						Return [FirstKey,SecondKey]
					}	Else If (depth >= 3) {
						For ThirdKey, ThirdObj in This.Excess {
							If (FirstKey = ThirdKey || SecondKey = ThirdKey)
								Continue 1
							If ((groupQ + FirstObj.Q + SecondObj.Q + ThirdObj.Q) >= This.Min && (groupQ + FirstObj.Q + SecondObj.Q + ThirdObj.Q) <= This.Max) {
								Return [FirstKey,SecondKey,ThirdKey]
							} Else If (depth >= 4) {
								For FourthKey, FourthObj in This.Excess {
									If (FirstKey = FourthKey || SecondKey = FourthKey || ThirdKey = FourthKey)
										Continue 1
									If ((groupQ + FirstObj.Q + SecondObj.Q + ThirdObj.Q + FourthObj.Q) >= This.Min && (groupQ + FirstObj.Q + SecondObj.Q + ThirdObj.Q + FourthObj.Q) <= This.Max) {
										Return [FirstKey,SecondKey,ThirdKey,FourthKey]
									}
								}
							}
						}
					}						
				}
			}
		}
	}
	GetQ(LST){
		Return AHK.sumBy(LST,"Q")
	}
	GetGroupNum(){
		val := 0
		While (val < This.Min) {
			val += This.Mean
		}
		This.GroupNum := (This.TotalQ // val)
	}
	BuildSortGroups(){
		This.SortGroups := []
		Loop, % This.GroupNum - 1 {
			This.SortGroups.Push([])
		}
	}
	ReSort(){
		For binNum, bin in This.SortGroups {
			This.SortGroups[binNum] := AHK.reverse(AHK.sortBy(bin,"Q"))
		}
		This.Excess := AHK.reverse(AHK.sortBy(This.Excess,"Q"))
	}
	AddToBin(binNum,Results){
		For k, key in Results {
			This.SortGroups[binNum].Push( This.Excess[key] )
		}
		For k, key in Results {
			This.Excess.Delete(key)
		}
	}
	GetCounts(){
		objCount := 0
		For k, bin in This.SortGroups {
			objCount += bin.Count()
		}
		objCount += This.Excess.Count()
		If (objCount != This.TotalNum)
			MsgBox % "There is a mismatching number of end objects"
			. "`nStarting Count:" This.TotalNum "`tEnd:" objCount
		Return objCount
	}
}
