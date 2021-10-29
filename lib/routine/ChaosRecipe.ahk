; Find and retreive Chaos recipe items from a Stash Tab
ChaosRecipe(endAtRefresh := 0){
  If (AccountNameSTR = "")
    AccountNameSTR := POE_RequestAccount().accountName
  Global RecipeArray := {}

  If ChaosRecipeStashMethodDump
  {
    Object := POE_RequestStash(StashTabDump,0)
    ItemTypes := ChaosRecipeSort(Object)
  }
  Else If ChaosRecipeStashMethodTab
  {
    Object := POE_RequestStash(ChaosRecipeStashTab,0)
    ItemTypes := ChaosRecipeSort(Object)
  }
  Else If ChaosRecipeStashMethodSort
  {
    requestedTabs := []
    for k, part in ["Weapon", "Helmet", "Armour", "Gloves", "Boots", "Belt", "Amulet", "Ring"]
    {
      If !indexOf(ChaosRecipeStashTab%part%,requestedTabs)
      {
        requestedTabs.Push(ChaosRecipeStashTab%part%)
        Object := POE_RequestStash(ChaosRecipeStashTab%part%,0)
        ChaosRecipeSort(Object,True)
        Sleep, 300
      }
    }
    If RecipeArray.Count()
      ItemTypes := RecipeArray
    Else
      ItemTypes := False
  }
  
  If endAtRefresh
  {
    If (ItemTypes)
      Return True
    Else
      Return False
  }
  Return ChaosRecipeReturn(ItemTypes)
}
ChaosRecipeSort(Object,Merge:=False){
  Global RecipeArray
  Chaos := {}
  Regal := {}
  uChaos := {}
  uRegal := {}
  For i, content in Object.items
  {
    item := new ItemBuild(content,Object.quadLayout)
    ; Array_Gui(item)
    If (item.Prop.ChaosRecipe)
    {
      If !IsObject((item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType])
        (item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType] := {}
      (item.Affix.Unidentified?uChaos:Chaos)[item.Prop.SlotType].Push(item)
    }
    If (item.Prop.RegalRecipe)
    {
      If !IsObject((item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType])
        (item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType] := {}
      (item.Affix.Unidentified?uRegal:Regal)[item.Prop.SlotType].Push(item)
    }
  }
  If (!(i > 0) && !Merge)
  {
    Return False
  }
  If Merge
  {
    For k, type in ["Chaos","uChaos","Regal","uRegal"]
    {
      For slot, itemArr in %type%
      {
        If !IsObject(RecipeArray[type])
          RecipeArray[type] := {}
        For key, item in itemArr
        {
          If !IsObject(RecipeArray[type][slot])
            RecipeArray[type][slot] := {}
          RecipeArray[type][slot].Push(item)
        }
      }
    }
  }
  Else
    RecipeArray := { "Chaos" : Chaos, "uChaos" : uChaos, "Regal" : Regal, "uRegal" : uRegal}
  Return RecipeArray
}
confirmOneOfEach(Object,id:=True){
  ; Confirm we have at least one of each armour slot and 2 rings
  for k, kind in ["Amulet","Ring","Belt","Body","Boots","Gloves","Helmet"]
  {
    If ChaosRecipeTypeHybrid
    {
      result := getCount(Object[id?"Chaos":"uChaos"][kind]) + getCount(Object[id?"Regal":"uRegal"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
    Else If ChaosRecipeTypePure
    {
      result := getCount(Object[id?"Chaos":"uChaos"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
    Else If ChaosRecipeTypeRegal
    {
      result := getCount(Object[id?"Regal":"uRegal"][kind])
      If (!result || (kind = "Ring" && result < 2))
        Return False
    }
  }

  ; now lets confirm we have a valid combination of weapons
  If ChaosRecipeTypeHybrid
  {
    2hresult := getCount(Object[id?"Chaos":"uChaos"]["Two Hand"]) + getCount(Object[id?"Regal":"uRegal"]["Two Hand"])
    1hresult := getCount(Object[id?"Chaos":"uChaos"]["One Hand"]) + getCount(Object[id?"Regal":"uRegal"]["One Hand"])
    1hresult += getCount(Object[id?"Chaos":"uChaos"]["Shield"]) + getCount(Object[id?"Regal":"uRegal"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }
  Else If ChaosRecipeTypePure
  {
    2hresult := getCount(Object[id?"Chaos":"uChaos"]["Two Hand"])
    1hresult := getCount(Object[id?"Chaos":"uChaos"]["One Hand"])
    1hresult += getCount(Object[id?"Chaos":"uChaos"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }
  Else If ChaosRecipeTypeRegal
  {
    2hresult := getCount(Object[id?"Regal":"uRegal"]["Two Hand"])
    1hresult := getCount(Object[id?"Regal":"uRegal"]["One Hand"])
    1hresult += getCount(Object[id?"Regal":"uRegal"]["Shield"])
    If (!2hresult && 1hresult < 2)
      Return False
  }

  ; If we make it this far, all checks have passed
  Return True
}
ChaosRecipeReturn(Object){
  RecipeSets:={}
  types := ["Chaos","Regal","uChaos","uRegal"]
  If ChaosRecipeTypePure{
    Loop {
      ; Most basic check for one recipe, no logic to determine if Regal or Chaos set
      If confirmOneOfEach(Object,True)
      {
        Set := {}
        If (IsObject(Object.Chaos.Shield.1) && IsObject(Object.Chaos.Shield.2))
        {
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos.Shield.1) && IsObject(Object.Chaos["One Hand"].1))
        {
          Set.Push(Object.Chaos.Shield.RemoveAt(1))
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos["Two Hand"].1))
        {
          Set.Push(Object.Chaos["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Chaos["One Hand"].1) && IsObject(Object.Chaos["One Hand"].2))
        {
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
          Set.Push(Object.Chaos["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.Chaos.Amulet.RemoveAt(1))
        Set.Push(Object.Chaos.Ring.RemoveAt(1))
        Set.Push(Object.Chaos.Ring.RemoveAt(1))
        Set.Push(Object.Chaos.Belt.RemoveAt(1))
        Set.Push(Object.Chaos.Body.RemoveAt(1))
        Set.Push(Object.Chaos.Boots.RemoveAt(1))
        Set.Push(Object.Chaos.Gloves.RemoveAt(1))
        Set.Push(Object.Chaos.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else If confirmOneOfEach(Object,False)
      {
        Set := {}
        If (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uChaos.Shield.2))
        {
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uChaos["One Hand"].1))
        {
          Set.Push(Object.uChaos.Shield.RemoveAt(1))
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos["Two Hand"].1))
        {
          Set.Push(Object.uChaos["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uChaos["One Hand"].1) && IsObject(Object.uChaos["One Hand"].2))
        {
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
          Set.Push(Object.uChaos["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.uChaos.Amulet.RemoveAt(1))
        Set.Push(Object.uChaos.Ring.RemoveAt(1))
        Set.Push(Object.uChaos.Ring.RemoveAt(1))
        Set.Push(Object.uChaos.Belt.RemoveAt(1))
        Set.Push(Object.uChaos.Body.RemoveAt(1))
        Set.Push(Object.uChaos.Boots.RemoveAt(1))
        Set.Push(Object.uChaos.Gloves.RemoveAt(1))
        Set.Push(Object.uChaos.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  } Else If (ChaosRecipeTypeHybrid){
    Loop {
      ; Hybrid filter for determining at least one chaos item is present, then using up all regal items
      If ( confirmOneOfEach(Object,True) && getCount(Object.Chaos) )
      {
        Set := {}
        ChaosPresent := False
        If ( ( (IsObject(Object.Chaos.Shield.1) || IsObject(Object.Regal.Shield.1) ) && ( IsObject(Object.Chaos.Shield.2) || IsObject(Object.Regal.Shield.2) ) ) 
        || ( IsObject(Object.Chaos.Shield.1) && IsObject(Object.Regal.Shield.1) ) )
        {
          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal.Shield.1) )
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.Chaos.Shield.1) || IsObject(Object.Regal.Shield.1)) && (IsObject(Object.Chaos["One Hand"].1) || IsObject(Object.Regal["One Hand"].1)))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos.Shield.1)) && IsObject(Object.Regal.Shield.1)
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal.Shield.1) )
            Set.Push(Object.Regal.Shield.RemoveAt(1))
          Else If (IsObject(Object.Chaos.Shield.1))
            Set.Push(Object.Chaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If (IsObject(Object.Chaos["Two Hand"].1) || IsObject(Object.Regal["Two Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos["Two Hand"].1)) && IsObject(Object.Regal["Two Hand"].1)
            Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["Two Hand"].1) )
            Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["Two Hand"].1))
            Set.Push(Object.Chaos["Two Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.Chaos["One Hand"].1) || IsObject(Object.Regal["One Hand"].1)) && (IsObject(Object.Chaos["One Hand"].2) || IsObject(Object.Regal["One Hand"].2))) 
        || (IsObject(Object.Chaos["One Hand"].1) && IsObject(Object.Regal["One Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.Chaos["One Hand"].1)) && IsObject(Object.Regal["One Hand"].1)
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.Regal["One Hand"].1) )
            Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.Chaos["One Hand"].1))
            Set.Push(Object.Chaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else 
          Break

        If (!ChaosPresent && !IsObject(Object.Chaos.Body.1)) && IsObject(Object.Regal.Body.1)
          Set.Push(Object.Regal.Body.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Body.1) )
          Set.Push(Object.Regal.Body.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Body.1))
          Set.Push(Object.Chaos.Body.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Helmet.1)) && IsObject(Object.Regal.Helmet.1)
          Set.Push(Object.Regal.Helmet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Helmet.1) )
          Set.Push(Object.Regal.Helmet.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Helmet.1))
          Set.Push(Object.Chaos.Helmet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Gloves.1)) && IsObject(Object.Regal.Gloves.1)
          Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Gloves.1) )
          Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Gloves.1))
          Set.Push(Object.Chaos.Gloves.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Boots.1)) && IsObject(Object.Regal.Boots.1)
          Set.Push(Object.Regal.Boots.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Boots.1) )
          Set.Push(Object.Regal.Boots.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Boots.1))
          Set.Push(Object.Chaos.Boots.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Belt.1)) && IsObject(Object.Regal.Belt.1)
          Set.Push(Object.Regal.Belt.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Belt.1) )
          Set.Push(Object.Regal.Belt.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Belt.1))
          Set.Push(Object.Chaos.Belt.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Amulet.1)) && IsObject(Object.Regal.Amulet.1)
          Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Amulet.1) )
          Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Amulet.1))
          Set.Push(Object.Chaos.Amulet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Ring.1)) && IsObject(Object.Regal.Ring.1)
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Ring.1) )
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Ring.1))
          Set.Push(Object.Chaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.Chaos.Ring.1)) && IsObject(Object.Regal.Ring.1)
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.Regal.Ring.1) )
          Set.Push(Object.Regal.Ring.RemoveAt(1))
        Else If (IsObject(Object.Chaos.Ring.1))
          Set.Push(Object.Chaos.Ring.RemoveAt(1)), ChaosPresent := True

        RecipeSets.Push(Set)
      }
      Else If ( confirmOneOfEach(Object,False) && getCount(Object.uChaos) )
      {
        Set := {}
        ChaosPresent := False
        If ((IsObject(Object.uChaos.Shield.1) || IsObject(Object.uRegal.Shield.1)) && (IsObject(Object.uChaos.Shield.2) || IsObject(Object.uRegal.Shield.2))) 
        || (IsObject(Object.uChaos.Shield.1) && IsObject(Object.uRegal.Shield.1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal.Shield.1) )
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.uChaos.Shield.1) || IsObject(Object.uRegal.Shield.1)) && (IsObject(Object.uChaos["One Hand"].1) || IsObject(Object.uRegal["One Hand"].1)))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos.Shield.1)) && IsObject(Object.uRegal.Shield.1)
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal.Shield.1) )
            Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Else If (IsObject(Object.uChaos.Shield.1))
            Set.Push(Object.uChaos.Shield.RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If (IsObject(Object.uChaos["Two Hand"].1) || IsObject(Object.uRegal["Two Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos["Two Hand"].1)) && IsObject(Object.uRegal["Two Hand"].1)
            Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["Two Hand"].1) )
            Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["Two Hand"].1))
            Set.Push(Object.uChaos["Two Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else If ((IsObject(Object.uChaos["One Hand"].1) || IsObject(Object.uRegal["One Hand"].1)) && (IsObject(Object.uChaos["One Hand"].2) || IsObject(Object.uRegal["One Hand"].2))) 
        || (IsObject(Object.uChaos["One Hand"].1) && IsObject(Object.uRegal["One Hand"].1))
        {
          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True

          If (!ChaosPresent && !IsObject(Object.uChaos["One Hand"].1)) && IsObject(Object.uRegal["One Hand"].1)
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (ChaosPresent && IsObject(Object.uRegal["One Hand"].1) )
            Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Else If (IsObject(Object.uChaos["One Hand"].1))
            Set.Push(Object.uChaos["One Hand"].RemoveAt(1)), ChaosPresent := True
        }
        Else 
          Break

        If (!ChaosPresent && !IsObject(Object.uChaos.Amulet.1)) && IsObject(Object.uRegal.Amulet.1)
          Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Amulet.1) )
          Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Amulet.1))
          Set.Push(Object.uChaos.Amulet.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Ring.1)) && IsObject(Object.uRegal.Ring.1)
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Ring.1) )
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Ring.1))
          Set.Push(Object.uChaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Ring.1)) && IsObject(Object.uRegal.Ring.1)
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Ring.1) )
          Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Ring.1))
          Set.Push(Object.uChaos.Ring.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Belt.1)) && IsObject(Object.uRegal.Belt.1)
          Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Belt.1) )
          Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Belt.1))
          Set.Push(Object.uChaos.Belt.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Body.1)) && IsObject(Object.uRegal.Body.1)
          Set.Push(Object.uRegal.Body.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Body.1) )
          Set.Push(Object.uRegal.Body.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Body.1))
          Set.Push(Object.uChaos.Body.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Boots.1)) && IsObject(Object.uRegal.Boots.1)
          Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Boots.1) )
          Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Boots.1))
          Set.Push(Object.uChaos.Boots.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Gloves.1)) && IsObject(Object.uRegal.Gloves.1)
          Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Gloves.1) )
          Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Gloves.1))
          Set.Push(Object.uChaos.Gloves.RemoveAt(1)), ChaosPresent := True

        If (!ChaosPresent && !IsObject(Object.uChaos.Helmet.1)) && IsObject(Object.uRegal.Helmet.1)
          Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        Else If (ChaosPresent && IsObject(Object.uRegal.Helmet.1) )
          Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        Else If (IsObject(Object.uChaos.Helmet.1))
          Set.Push(Object.uChaos.Helmet.RemoveAt(1)), ChaosPresent := True

        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  } Else If (ChaosRecipeTypeRegal){
    Loop {
      ; Most basic check for one recipe, no logic to determine if Regal or Chaos set
      If confirmOneOfEach(Object,True)
      {
        Set := {}
        If (IsObject(Object.Regal.Shield.1) && IsObject(Object.Regal.Shield.2))
        {
          Set.Push(Object.Regal.Shield.RemoveAt(1))
          Set.Push(Object.Regal.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.Regal.Shield.1) && IsObject(Object.Regal["One Hand"].1))
        {
          Set.Push(Object.Regal.Shield.RemoveAt(1))
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Regal["Two Hand"].1))
        {
          Set.Push(Object.Regal["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.Regal["One Hand"].1) && IsObject(Object.Regal["One Hand"].2))
        {
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
          Set.Push(Object.Regal["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.Regal.Amulet.RemoveAt(1))
        Set.Push(Object.Regal.Ring.RemoveAt(1))
        Set.Push(Object.Regal.Ring.RemoveAt(1))
        Set.Push(Object.Regal.Belt.RemoveAt(1))
        Set.Push(Object.Regal.Body.RemoveAt(1))
        Set.Push(Object.Regal.Boots.RemoveAt(1))
        Set.Push(Object.Regal.Gloves.RemoveAt(1))
        Set.Push(Object.Regal.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else If confirmOneOfEach(Object,False)
      {
        Set := {}
        If (IsObject(Object.uRegal.Shield.1) && IsObject(Object.uRegal.Shield.2))
        {
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal.Shield.1) && IsObject(Object.uRegal["One Hand"].1))
        {
          Set.Push(Object.uRegal.Shield.RemoveAt(1))
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal["Two Hand"].1))
        {
          Set.Push(Object.uRegal["Two Hand"].RemoveAt(1))
        }
        Else If (IsObject(Object.uRegal["One Hand"].1) && IsObject(Object.uRegal["One Hand"].2))
        {
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
          Set.Push(Object.uRegal["One Hand"].RemoveAt(1))
        }
        Else 
          Break
        Set.Push(Object.uRegal.Amulet.RemoveAt(1))
        Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Set.Push(Object.uRegal.Ring.RemoveAt(1))
        Set.Push(Object.uRegal.Belt.RemoveAt(1))
        Set.Push(Object.uRegal.Body.RemoveAt(1))
        Set.Push(Object.uRegal.Boots.RemoveAt(1))
        Set.Push(Object.uRegal.Gloves.RemoveAt(1))
        Set.Push(Object.uRegal.Helmet.RemoveAt(1))
        RecipeSets.Push(Set)
      }
      Else
        Break
    }
  }
  Return RecipeSets
}
getCount(Object,full:=False){
  c := 0
  For slot, items in Object
  {
    If !full
      c++
    Else {
      for ik, itm in items
        c++
    }
  }
  Return c
}
retCount(obj){
  Return (obj.Count()>=0?obj.Count():0) 
}
; VendorRoutineChaos - Does vendor functions for Chaos Recipe
VendorRoutineChaos(){
	CRECIPE := {"Weapon":0,"Ring":0,"Amulet":0,"Belt":0,"Boots":0,"Gloves":0,"Body":0,"Helmet":0}
	BlackList := Array_DeepClone(BlackList_Default)
	; Move mouse out of the way to grab screenshot
	ShooMouse(), GuiStatus(), ClearNotifications()
	If !OnVendor
	{
		Notify("Error", "Not at vendor", 2)
		Return
	}

	; Main loop through inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If (BlackList[C][R] || !WR.Restock[C][R].Normal)
				Continue
			Grid := RandClick(GridX, GridY)
			PointColor := FindText.GetColor(GridX,GridY)
			
			If indexOf(PointColor, varEmptyInvSlotColor) {
				;Seems to be an empty slot, no need to clip item info
				Continue
			}
			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			If (!Item.Prop.IsItem || Item.Prop.ItemName = "")
				ShooMouse(),GuiStatus(),Continue
			If (OnVendor&&YesVendor)
			{
				If ( ( Item.Prop.SpecialType="" || (Item.Prop.SpecialType="Enchanted Item" && Item.Prop.ChaosValue < 1) ) && (Item.Prop.ChaosRecipe || Item.Prop.RegalRecipe) ) {
					If indexOf(Item.Prop.SlotType,["One Hand","Two Hand","Shield","Ring"]) {
						If (Item.Prop.SlotType = "Ring"){
							If (CRECIPE["Ring"] < 2){
								CtrlClick(Grid.X,Grid.Y)
								CRECIPE["Ring"] += 1
							}
						} Else  {
							If (CRECIPE["Weapon"] < 2){
								CtrlClick(Grid.X,Grid.Y)
								CRECIPE["Weapon"] += 1
								If (Item.Prop.SlotType = "Two Hand")
									CRECIPE["Weapon"] += 1
							}
						}
					} Else If CRECIPE.HasKey(Item.Prop.SlotType) {
						If (CRECIPE[Item.Prop.SlotType] < 1){
						CtrlClick(Grid.X,Grid.Y)
						CRECIPE[Item.Prop.SlotType] += 1
						}
					}
				}
			}
		}
	}
	; Auto Confirm Vendoring Option
	If (OnVendor && RunningToggle && YesEnableAutomation)
	{
		ContinueFlag := False
		If (CRECIPE["Weapon"] = 2 && CRECIPE["Ring"] = 2 && CRECIPE["Amulet"] = 1 && CRECIPE["Boots"] = 1 && CRECIPE["Gloves"] = 1 && CRECIPE["Helmet"] = 1 && CRECIPE["Body"] = 1 && CRECIPE["Belt"] = 1 )
			RecipeComplete := True
		If !RecipeComplete
			Return False
		If (YesEnableAutoSellConfirmation || RecipeComplete && YesEnableAutoSellConfirmationSafe)
		{
			RandomSleep(90,90)
			LeftClick(WR.loc.pixel.VendorAccept.X,WR.loc.pixel.VendorAccept.Y + (CurrentLocation = "The Rogue harbour"?Round(GameH/(1080/50)):0))
			RandomSleep(90,180)
			ContinueFlag := True
		}
		Else If (FirstAutomationSetting=="Search Vendor")
		{
			CheckTime("Seconds",120,"VendorUI",A_Now)
			MouseMove, WR.loc.pixel.VendorAccept.X, WR.loc.pixel.VendorAccept.Y + (CurrentLocation = "The Rogue harbour"?Round(GameH/(1080/50)):0)

			While (!CheckTime("Seconds",120,"VendorUI"))
			{
				If (YesController)
					Controller()
				Sleep, 100
				GuiStatus()
				If !OnVendor && !OnInventory
				{
					ContinueFlag := True
					break
				}
			}
		}
		; Search Stash and StashRoutine
		If (YesEnableNextAutomation && ContinueFlag)
		{
			RandomSleep(90,180)
			SendHotkey(hotkeyCloseAllUI)
			RandomSleep(90,180)
			If OnHideout
				Town := "Hideout"
			Else If OnMines
				Town := "Mines"
			Else
				Town := CompareLocation("Town")

			If OnMines
			{
				LeftClick(GameX + GameW//1.1, GameY + GameH//1.1)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			Else If (Town = "Oriath Docks")
			{
				LeftClick(GameX + GameW//1.1, GameY + GameH//3)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			Else If (Town = "The Sarn Encampment")
			{
				LeftClick(GameX + GameW//1.1, GameY + GameH//3)
				Sleep, 800
				; LeftClick(GameX + (GameW//2) - 10 , GameY + (GameH//2) - 30 )
			}
			GuiStatus()
			SearchStash()
			; StashRoutine()
		}
	}
	Return True
}
; Takes a list of Recipe Sets to the vendor
VendorChaosRecipe(){
	; Ensure we only run one instance, second press of hotkey should stop function
	CheckRunning()
	Global InvGrid, CurrentTab
	CurrentTab := 0
	Static Object := {}
	If !Object.Count()
		Object := ChaosRecipe()
	If !Object.Count()
	{
		PrintChaosRecipe("No Complete Rare Sets")
		Return
	}
	IfWinActive, ahk_group POEGameGroup
	{
		; Refresh our screenshot
		GuiStatus()
		; Check OnStash / Search for stash
		If (!OnStash)
		{
			If !SearchStash()
			{
				PrintChaosRecipe("There are " Object.Count() " sets of rare items in stash.`n", 3)
				Return
			}
		}
		CheckRunning("On")
	} Else
		Return

	For k, v in Object.1
	{
		; Move to Tab
		MoveStash(v.Prop.StashTab)
		Sleep, 30
		; Ctrl+Click to inventory
		CtrlClick(InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].X[v.Prop.StashX]
		, InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].Y[v.Prop.StashY])
		Sleep, 30
	}

	; Remove set from Object array
	Backup := Object.RemoveAt(1)

	; Close Stash panel
	SendHotkey(hotkeyCloseAllUI)
	GuiStatus()
	; Search for Vendor
	If SearchVendor()
	{
		Sleep, 45
		; Vendor set
		If !VendorRoutineChaos() {
				Notify("Recipe Set INCOMPLETE","Trying to fetch items Again",2)
				sleep, 180
				SendHotkey(hotkeyCloseAllUI)
				sleep, 180
				SendHotkey(hotkeyCloseAllUI)
				sleep, 200
				SearchStash()
				sleep, 200
				If OnStash {
					For k, v in Backup
					{
						; Move to Tab
						MoveStash(v.Prop.StashTab)
						Sleep, 45
						; Ctrl+Click to inventory
						CtrlClick(InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].X[v.Prop.StashX]
						, InvGrid[(v.Prop.StashQuad?"StashQuad":"Stash")].Y[v.Prop.StashY])
						Sleep, 45
					}
					; Close Stash panel
					SendHotkey(hotkeyCloseAllUI)
					GuiStatus()
					; Search for Vendor
					If SearchVendor()
					{
						Sleep, 45
						; Vendor set
						If !VendorRoutineChaos() {
							Notify("Recipe Set INCOMPLETE","Second Time failing",2)
							MouseMove, xx, yy, 0
							CheckRunning("Off")
							Return False
						}
					}
				} Else {
					Notify("Could Not reopen stash automatically","",2)
					MouseMove, xx, yy, 0
					CheckRunning("Off")
					Return False
				}
		}
	}
	If !Object.Count()
		PrintChaosRecipe("Finished Selling Rare Sets")
	Else {
		PrintChaosRecipe("There are " Object.Count() " sets of rare items left to vendor.`n", 3)
		If ChaosRecipeUnloadAll
			SetTimer VendorChaosRecipe, -500
	}
	; Reset in preparation for the next press of this hotkey.
	Sleep, 90*Latency
	CheckRunning("Off")
	Return True
}
PrintChaosRecipe(Message:="Current slot totals",Duration:="False"){
	Global RecipeArray
	ShowUNID := False
	Tally := {}
	uTally := {}
	For Slot, Items in RecipeArray.Chaos
	{
		For k, v in Items 
		{
			If !Tally[Slot]
				Tally[Slot] := 0
			Tally[Slot] += 1
		}
	}
	For Slot, Items in RecipeArray.Regal
	{
		For k, v in Items 
		{
			If !Tally[Slot]
				Tally[Slot] := 0
			Tally[Slot] += 1
		}
	}
	For Slot, Items in RecipeArray.uChaos
	{
		For k, v in Items 
		{
			If !uTally[Slot]
				uTally[Slot] := 0
			uTally[Slot] += 1
		}
	}
	For Slot, Items in RecipeArray.uRegal
	{
		For k, v in Items 
		{
			If !uTally[Slot]
				uTally[Slot] := 0
			uTally[Slot] += 1
		}
	}
	Notify("Chaos Recipe ID/UNID", Message . "`n"
	. "Amulet: " . (Tally.Amulet?Tally.Amulet:0) . "/" . (uTally.Amulet?uTally.Amulet:0) . "`t"
	. "Ring: " . (Tally.Ring?Tally.Ring:0) . "/" . (uTally.Ring?uTally.Ring:0) . "`n"
	. "Belt: " . (Tally.Belt?Tally.Belt:0) . "/" . (uTally.Belt?uTally.Belt:0) . "`t`t"
	. "Body: " . (Tally.Body?Tally.Body:0) . "/" . (uTally.Body?uTally.Body:0) . "`n"
	. "Boots: " . (Tally.Boots?Tally.Boots:0) . "/" . (uTally.Boots?uTally.Boots:0) . "`t"
	. "Gloves: " . (Tally.Gloves?Tally.Gloves:0) . "/" . (uTally.Gloves?uTally.Gloves:0) . "`n"
	. "Helmet: " . (Tally.Helmet?Tally.Helmet:0) . "/" . (uTally.Helmet?uTally.Helmet:0) . "`t"
	. "Shield: " . (Tally.Shield?Tally.Shield:0) . "/" . (uTally.Shield?uTally.Shield:0) . "`n"
	. "One Hand: " . (Tally["One Hand"]?Tally["One Hand"]:0) . "/" . (uTally["One Hand"]?uTally["One Hand"]:0) . "`t"
	. "Two Hand: " . (Tally["Two Hand"]?Tally["Two Hand"]:0) . "/" . (uTally["Two Hand"]?uTally["Two Hand"]:0) . "`n"
	, (Duration != "False" ? Duration : 20))
	Return
}
