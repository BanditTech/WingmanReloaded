; GroupByFourty - Mathematic function to sort quality into groups of 40
GroupByFourty(ArrList) {
  GroupList := {}
  tQ := 0
  ; Get total of Value before
  For k, v in ArrList
    allQ += v.Q 
  ; Begin adding values to GroupList
  Loop, 20
    GroupTotal%ind% := 0
  Gosub, Group_Add
  Gosub, Group_Swap
  Gosub, Group_Move
  Gosub, Group_Cleanup
  Gosub, Group_Cleanup
  Gosub, Group_Add
  Gosub, Group_Swap
  Gosub, Group_Cleanup
  ; Gosub, Group_Move
  ; Gosub, Group_Cleanup
  ; Gosub, Group_Add
  ; Gosub, Group_Move
  ; Gosub, Group_Cleanup
  ; Gosub, RebaseTotals

  ; Final tallies
  For k, v in ArrList
    remainQ += v.Q 
  If !remainQ
    remainQ:=0
  tQ=
  For k, v in GroupList
    For kk, vv in v
      tQ += vv.Q 
  If !tQ
    tQ:= 0
  overQ := mod(tQ, 40)
  If !overQ
    overQ:= 0
  ; Catch for high quality gems in low quantities
  If (tQ = 0 && remainQ >= 40 && remainQ <= 57)
  {
    Loop, 20
    {
      ind := A_Index
      For k, v in ArrList
      {
        If (GroupTotal%ind% >= 40)
          Continue
        If (GroupTotal%ind% + v.Q <= 57)
        {
          If !IsObject(GroupList[ind])
            GroupList[ind]:={}
          GroupList[ind].Push(ArrList.Delete(k))
          GroupTotal%ind% += v.Q
        }
      }
    }
    remainQ=
    For k, v in ArrList
      remainQ += v.Q 
    If !remainQ
      remainQ:=0
    tQ=
    For k, v in GroupList
      For kk, vv in v
        tQ += vv.Q 
    If !tQ
      tQ:= 0
    overQ := mod(tQ, 40)
    If !overQ
      overQ:= 0
  }
  expectC := Round((tQ - overQ) / 40)
  ; Display Tooltips
  Notify("Vendor Result"
  , "Total Quality:`t" allQ "`%`n"
  . "Orb Value:`t" expectC " orbs`n"
  . "Vend Quality:`t" tQ "`%`n"
  . "Extra Vend Q:`t" overQ "`%`n"
  . "UnVend Q:`t" remainQ "`%", 10)
  Return GroupList

  RebaseTotals:
    tt=
    tt2=
    For k, v in GroupList
    {
      tt .= GroupTotal%k% . "`r"
      GroupTotal%k% := 0
      For kk, vv in v
      {
        GroupTotal%k% += vv.Q
      }
    }
    For k, v in GroupList
      tt2 .= GroupTotal%k% . "`r"
    If (tt != tt2)
      MsgBox,% "Mismatch Found!`r`rFirst Values`r" . tt . "`r`rSecond Values`r" . tt2
  Return

  Group_Batch:
    Gosub, Group_Trim
    Gosub, Group_Trade
    Gosub, Group_Add
    Gosub, Group_Swap
  Return

  Group_Cleanup:
    ; Remove groups that didnt make it to 40
    Loop, 3
    For k, v in GroupList
    {
      If (GroupTotal%k% < 40)
      {
        For kk, vv in v
        {
          ArrList.Push(v.Delete(kk))
          GroupTotal%k% -= vv.Q
        }
      }
    }
  Return

  Group_Swap:
    ; Swap values Between groups to move closer to 40
    For k, v in GroupList
    {
      If (GroupTotal%k% <= 40)
        Continue
      For kk, vv in v
      {
        If (GroupTotal%k% <= 40)
          Continue
        For kg, vg in GroupList
        {
          If (k = kg)
            Continue
          For kkg, vvg in vg
          {
            newk := GroupTotal%k% - vv.Q + vvg.Q
            newkg := GroupTotal%kg% + vv.Q - vvg.Q
            If (GroupTotal%kg% >= 40 && newkg < 40)
              Continue
            If (newk >= 40 && newk < GroupTotal%k%)
            {
              GroupList[kg].Push(GroupList[k].Delete(kk))
              GroupList[k].Push(GroupList[kg].Delete(kkg))
              GroupTotal%k% := newk, GroupTotal%kg% := newkg
              Break 2
            }
          }
        }
      }
    }
  Return

  Group_Trade:
    ; Swap values from group to arrList to move closer to 40
    For k, v in GroupList
    {
      If (GroupTotal%k% <= 40)
        Continue
      For kk, vv in v
      {
        If (GroupTotal%k% <= 40)
          Continue
        For kg, vg in ArrList
        {
          newk := GroupTotal%k% - vv.Q + vvg.Q
          If (newk >= 40 && newk < GroupTotal%k%)
          {
            ArrList.Push(GroupList[k].Delete(kk))
            GroupList[k].Push(ArrList.Delete(kg))
            GroupTotal%k% := newk
            Break
          }
        }
      }
    }
  Return

  Group_Move:
    ; Move values from incomplete groups to add as close to 40
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 40)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Cleanup
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 41)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 42)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 43)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 44)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 45)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 46)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 47)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 48)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 49)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 50)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 51)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 52)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 53)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 54)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
    Loop 20
    {
      ind := A_Index
      If ((GroupTotal%ind% >= 40) || !GroupTotal%ind%)
        Continue
      For k, v in GroupList
      {
        If (ind = k || (GroupTotal%k% >= 40))
          Continue
        For kk, vv in v
        {
          If (GroupTotal%ind% + vv.Q <= 55)
          {
            If !IsObject(GroupList[ind])
              GroupList[ind]:={}
            GroupList[ind].Push(GroupList[k].Delete(kk))
            GroupTotal%ind% += vv.Q
            GroupTotal%k% -= vv.Q
          }
        }
      }
    }
    Gosub, Group_Batch
  Return

  Group_Add:
    ; Find any values to add to incomplete groups
    Loop, 20
    {
      ind := A_Index
      For k, v in ArrList
      {
        If (GroupTotal%ind% >= 40)
          Continue
        If (GroupTotal%ind% + v.Q <= 40)
        {
          If !IsObject(GroupList[ind])
            GroupList[ind]:={}
          GroupList[ind].Push(ArrList.Delete(k))
          GroupTotal%ind% += v.Q
        }
      }
    }
  Return

  Group_Trim:
    ; Trim excess values if group above 40
    Loop 20
    {
      ind := A_Index
      If GroupTotal%ind% > 40
      {
        For k, v in GroupList[ind]
        {
          If (GroupTotal%ind% - v.Q >= 40)
          {
            ArrList.Push(GroupList[ind].Delete(k))
            GroupTotal%ind% -= v.Q
          }
        }
      }
    }
  Return
}
