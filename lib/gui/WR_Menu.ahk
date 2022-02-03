; WR_Menu - New menu handling method
WR_Menu(Function:="",Var*){
  Global
  Static Built_Inventory, Built_Crafting, Built_Strings, Built_Chat, Built_Controller, Built_Hotkeys, Built_Globe, LeagueIndex, UpdateLeaguesBtn, OHB_EditorBtn, WR_Reset_Globe, DefaultWhisper, DefaultCommands, DefaultButtons, LocateType, oldx, oldy, TempC ,WR_Btn_Locate_PortalScroll, WR_Btn_Locate_WisdomScroll, WR_Btn_Locate_CurrentGem, WR_Btn_Locate_AlternateGem, WR_Btn_Locate_CurrentGem2, WR_Btn_Locate_AlternateGem2, WR_Btn_Locate_GrabCurrency, WR_Btn_FillMetamorph_Select, WR_Btn_FillMetamorph_Show, WR_Btn_FillMetamorph_Menu, WR_Btn_IgnoreSlot, WR_UpDown_Color_Life, WR_UpDown_Color_ES, WR_UpDown_Color_Mana, WR_UpDown_Color_EB, WR_Edit_Color_Life, WR_Edit_Color_ES, WR_Edit_Color_Mana, WR_Edit_Color_EB, WR_Save_JSON_Globe, WR_Load_JSON_Globe, Obj, WR_Save_JSON_FillMetamorph
  , ChaosRecipeMaxHoldingUpDown, ChaosRecipeLimitUnIdUpDown, ChaosRecipeStashTabUpDown, ChaosRecipeStashTabWeaponUpDown, ChaosRecipeStashTabHelmetUpDown, ChaosRecipeStashTabArmourUpDown, ChaosRecipeStashTabGlovesUpDown, ChaosRecipeStashTabBootsUpDown, ChaosRecipeStashTabBeltUpDown, ChaosRecipeStashTabAmuletUpDown, ChaosRecipeStashTabRingUpDown

  Log("Verbose","Load menu: " Function,Var*)

  If (Function = "Inventory")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Inventory
    {
      Built_Inventory := 1
      Gui, Inventory: New
      Gui, Inventory: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      Gui, Inventory: Add, Button, default gupdateEverything x295 y470 w150 h23, Save Configuration
      Gui, Inventory: Add, Button, gLaunchSite x+5 h23, Website

      Gui, Inventory: Add, Tab2, vInventoryGuiTabs x3 y3 w625 h505 -wrap , Options|Stash Tabs|Affinity|Chaos Recipe|Crafting Bases

      Gui, Inventory: Tab, Options
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w170 h315 xm ym+25, Inventory Sort/CLF Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesIdentify Checked%YesIdentify% xs+5 ys+18 , Identify Items?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesStash Checked%YesStash% y+8 , Deposit at Stash?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesVendor Checked%YesVendor% y+8 , Sell at Vendor?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesDiv Checked%YesDiv% y+8 , Trade Divination?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSortFirst Checked%YesSortFirst% y+8 , Group Items before stashing?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesMapUnid Checked%YesMapUnid% y+8 , Leave Map Un-ID?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesInfluencedUnid Checked%YesInfluencedUnid% y+8 , Leave Influenced Un-ID?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesCLFIgnoreImplicit Checked%YesCLFIgnoreImplicit% y+8 , Ignore Implicit in CLF?
      Gui, Inventory: Add, Checkbox, gSaveGeneral vYesBatchVendorBauble Checked%YesBatchVendorBauble% y+8 , Batch Vendor Quality Flasks?
      Gui, Inventory: Add, Checkbox, gSaveGeneral vYesBatchVendorGCP Checked%YesBatchVendorGCP% y+8 , Batch Vendor Quality Gems?
      Gui, Inventory: Add, Checkbox, gSaveGeneral vYesSpecial5Link Checked%YesSpecial5Link% y+8 , Give 5 link Special Type?
      Gui, Inventory: Add, Checkbox, gSaveGeneral vYesOpenStackedDeck Checked%YesOpenStackedDeck% y+8 , Open Stacked Decks?
      Gui, Inventory: Add, Checkbox, gSaveGeneral vYesVendorDumpItems Checked%YesVendorDumpItems% y+8 , Vendor Dump Tab Items?

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w370 h100 xm+180 ym+25, Scroll, Gem and Currency Locations
      Gui, Inventory: Font

      Gui, Inventory: Add, Text, xs+93 ys+15, X-Pos
      Gui, Inventory: Add, Text, x+12, Y-Pos

      Gui, Inventory: Add, Text, xs+9 y+6, Grab Currency:
      Gui, Inventory: Add, Edit, vGrabCurrencyX x+8 y+-15 w34 h17, %GrabCurrencyX%
      Gui, Inventory: Add, Edit, vGrabCurrencyY x+8 w34 h17, %GrabCurrencyY%
      Gui, Inventory: Add, Button, gWR_Update vWR_Btn_Locate_GrabCurrency xs+173 ys+31 h17 , Locate
      Gui, Inventory: Add, Button, gRestockMenu r2 x+16 ys+30, Inventory Slot`n`rManagement
      Gui, Inventory: Add, Checkbox, gSaveGeneral vEnableRestock Checked%EnableRestock% xp y+8 , Enable Restock?

      Gui, Inventory: Add, Text, xs+84 ys+25 h72 0x11
      Gui, Inventory: Add, Text, x+33 h72 0x11
      Gui, Inventory: Add, Text, x+33 h72 0x11
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w180 h160 xs y+5, Item Parse Settings
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, vYesNinjaDatabase xs+5 ys+20 Checked%YesNinjaDatabase%, Update PoE.Ninja DB?
      Gui, Inventory: Add, DropDownList, vUpdateDatabaseInterval x+1 yp-4 w30 Choose%UpdateDatabaseInterval%, 1|2|3|4|5|6|7
      Gui, Inventory: Add, Checkbox, vForceMatch6Link xs+5 y+8 Checked%ForceMatch6Link%, Match with the 6 Link price
      Gui, Inventory: Add, Checkbox, vForceMatchGem20 xs+5 y+8 Checked%ForceMatchGem20%, Match with gems below 20
      Gui, Inventory: Add, Text, xs+5 y+11 hwndPredictivePriceHWND, Price Rares?
      Gui, Inventory: Add, DropDownList, gUpdateExtra vYesPredictivePrice x+2 yp-3 w45 h13 r5, Off|Low|Avg|High
      GuiControl,Inventory: ChooseString, YesPredictivePrice, %YesPredictivePrice%

      Gui, Inventory: Font, s18
      Gui, Inventory: Add, Text, x+1 yp-3 cC39F22, `%
      Gui, Inventory: Add, Text, vYesPredictivePrice_Percent_Val x+0 yp w40 cC39F22 center, %YesPredictivePrice_Percent_Val%
      Gui, Inventory: Font,
      ControlGetPos, PPx, PPy, , , , ahk_id %PredictivePriceHWND%
      PPx:=Scale_PositionFromDPI(PPx), PPy:=Scale_PositionFromDPI(PPy)
      Slider_PredictivePrice := new Progress_Slider("Inventory", "YesPredictivePrice_Percent" , (PPx-6) , (PPy-3) , 175 , 15 , 50 , 200 , YesPredictivePrice_Percent_Val , "Black" , "F1C15D" , 1 , "YesPredictivePrice_Percent_Val" , 0 , 0 , 1, "General")

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h145 section xm+370 ys, Automation
      AutomationList := "Search Stash|Search Vendor"
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesEnableAutomation Checked%YesEnableAutomation% xs+5 ys+18 , Enable Automation ?
      Gui, Inventory: Add, Text, y+8, First Automation Action
      Gui, Inventory: Add, DropDownList, gUpdateExtra vFirstAutomationSetting y+3 w100 ,%AutomationList%
      GuiControl,Inventory: ChooseString, FirstAutomationSetting, %FirstAutomationSetting%
      Gui, Inventory: Add, Button, ghelpAutomation x+10 w20 h20, ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesEnableNextAutomation Checked%YesEnableNextAutomation% xs+5 y+8 , Enable Second Automation ?
      Gui, Inventory: Add, Checkbox, gWarningAutomation vYesEnableAutoSellConfirmation Checked%YesEnableAutoSellConfirmation% y+8 , Enable Auto Confirm Vendor ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesEnableAutoSellConfirmationSafe Checked%YesEnableAutoSellConfirmationSafe% y+8 , Enable Safe Auto Confirm?
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h70 section xm+370 y+15, Metamorph Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesFillMetamorph Checked%YesFillMetamorph% xs+5 ys+18 , Auto fill metamorph?
      Gui, Inventory: Add, Button, gWR_Update vWR_Btn_FillMetamorph_Menu y+8 w170 center , Adjust Metamorph Panel

      Gui, Inventory: Tab, Stash Tabs
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      ;You can test with Stash Tab management as a groupbox, but i dont like it
      ;Gui, Inventory: Add, GroupBox,       Section    w352 h437    xm   ym+25,Stash Tab Management
      Gui, Inventory: Add, Text, Section xm+5 ym+25,Stash Tab Management
      Gui, Inventory: Font,

      ; Veiled

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Veiled
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabVeiled x+0 yp hp , %StashTabVeiled%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesVeiled Checked%StashTabYesVeiled% x+5 yp+4, Enable

      ; Cluster

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Cluster Jewel
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabClusterJewel x+0 yp hp , %StashTabClusterJewel%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesClusterJewel Checked%StashTabYesClusterJewel% x+5 yp+4, Enable

      ; Heist Gear

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Heist Gear
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabHeistGear x+0 yp hp , %StashTabHeistGear%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesHeistGear Checked%StashTabYesHeistGear% x+5 yp+4, Enable

      ; Misc Map Items

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Misc Map Items
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabMiscMapItems x+0 yp hp , %StashTabMiscMapItems%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesMiscMapItems Checked%StashTabYesMiscMapItems% x+5 yp+4, Enable

      ; Second column Gui - GEMS

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys+18 , 5/6 linked
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabLinked , %StashTabLinked%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesLinked Checked%StashTabYesLinked% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Bricked Maps
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabBrickedMaps , %StashTabBrickedMaps%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesBrickedMaps Checked%StashTabYesBrickedMaps% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Influenced Item
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabInfluencedItem , %StashTabInfluencedItem%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesInfluencedItem Checked%StashTabYesInfluencedItem% x+5 yp+4, Enable

      ; Third column Gui - Rare itens

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w110 h50 x+15 ys , Crafting
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabCrafting , %StashTabCrafting%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesCrafting Checked%StashTabYesCrafting% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Dump
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabDump x+0 yp hp , %StashTabDump%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesDump Checked%StashTabYesDump% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Priced Rares
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabPredictive , %StashTabPredictive%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesPredictive Checked%StashTabYesPredictive% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w110 h50 xs yp+20 , Ninja Priced
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabNinjaPrice , %StashTabNinjaPrice%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesNinjaPrice Checked%StashTabYesNinjaPrice% x+5 yp+4, Enable

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w185 h60 section x+15 ys, Dump Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashDumpInTrial Checked%StashDumpInTrial% xs+5 ys+18, Enable Dump in Trial
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashDumpSkipJC Checked%StashDumpSkipJC% xs+5 y+5, Skip Jeweler/Chroma Items

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w185 h40 section xs y+10, Priced Rares Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
      Gui, Inventory: Add, Edit, x+5 yp-3 w40
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabYesPredictive_Price , %StashTabYesPredictive_Price%

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w185 h40 section xs y+10, Ninja Priced Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, center xs+5 ys+18, Minimum Value to Stash
      Gui, Inventory: Add, Edit, x+5 yp-3 w40
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabYesNinjaPrice_Price , %StashTabYesNinjaPrice_Price%

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w185 h135 section xs y+10, Map/Contract Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, DropDownList, w40 gUpdateExtra vYesSkipMaps_eval xs+5 yp+18 , % ">=|<=" 
      GuiControl,Inventory: ChooseString, YesSkipMaps_eval, %YesSkipMaps_eval%
      Gui, Inventory: Add, DropDownList, w40 gUpdateExtra vYesSkipMaps x+3 yp , 0|1|2|3|4|5|6|7|8|9|10|11|12
      GuiControl,Inventory: ChooseString, YesSkipMaps, %YesSkipMaps%
      Gui, Inventory: Add, Text, yp+3 x+5 , Column to Skip
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSkipMaps_normal Checked%YesSkipMaps_normal% xs+5 y+8 , Skip Normal?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSkipMaps_magic Checked%YesSkipMaps_magic% x+0 yp , Skip Magic?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSkipMaps_rare Checked%YesSkipMaps_rare% xs+5 y+8 , Skip Rare?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSkipMaps_unique Checked%YesSkipMaps_unique% x+0 yp , Skip Unique?
      Gui, Inventory: Add, Text, xs+5 y+8 , Skip Maps => Tier
      Gui, Inventory: Add, Edit, Number w40 x+5 yp-3 
      Gui, Inventory: Add, UpDown, center hp w40 range1-16 gUpdateExtra vYesSkipMaps_tier , %YesSkipMaps_tier%
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesSkipMaps_Prep Checked%YesSkipMaps_Prep% xs+5 y+8, Skip Enhance Items in Map Area

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w185 h50 section xs y+15, Influenced Item Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesIncludeFandSItem Checked%YesIncludeFandSItem% xs+5 ys+18, Fracture and Synthesised `nas Influenced Items

      ; Affinity
      Gui, Inventory: Tab, Affinity
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, Text, Section xm+5 ym+25, Affinities Management
      Gui, Inventory: Font,

      ; Blight
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs ys+18 , Blight
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vBlightEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabBlight, %StashTabBlight%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesBlight x+5 yp-5 w90 h20, %StashTabYesBlight%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vBlightEditText, Disable Type

      ; Delirium
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Delirium
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDeliriumEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabDelirium, %StashTabDelirium%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDelirium x+5 yp-5 w90 h20, %StashTabYesDelirium%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vDeliriumEditText, Disable Type

      ; Divination Card
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Divination Card
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDivinationEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabDivination x+0 yp hp , %StashTabDivination%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDivination x+5 yp-5 w90 h20, %StashTabYesDivination%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vDivinationEditText, Disable Type

      ; Fragments
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Fragment
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vFragmentEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabFragment x+0 yp hp , %StashTabFragment%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesFragment x+5 yp-5 w90 h20, %StashTabYesFragment%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vFragmentEditText, Disable Type

      ; Metamorph
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Metamorph
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vMetamorphEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabMetamorph x+0 yp hp , %StashTabMetamorph%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesMetamorph x+5 yp-5 w90 h20, %StashTabYesMetamorph%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vMetamorphEditText, Disable Type

      ; Gem
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Gem
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vGemEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabGem x+0 yp hp , %StashTabGem%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesGem x+5 yp-5 w90 h20, %StashTabYesGem%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vGemEditText, Disable Type

      ; Currency
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w145 h50 x+15 ys+18 , Currency
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 vCurrencyEdit xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabCurrency yp hp , %StashTabCurrency%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesCurrency x+5 yp-5 w90 h20, %StashTabYesCurrency%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vCurrencyEditText, Disable Type

      ; Delve
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Delve
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vDelveEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabDelve , %StashTabDelve%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesDelve x+5 yp-5 w90 h20, %StashTabYesDelve%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vDelveEditText, Disable Type

      ; Essence
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Essence
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vEssenceEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabEssence x+0 yp hp , %StashTabEssence%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesEssence x+5 yp-5 w90 h20, %StashTabYesEssence%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vEssenceEditText, Disable Type

      ; Map
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Map
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vMapEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabMap x+0 yp hp , %StashTabMap%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesMap x+5 yp-5 w90 h20, %StashTabYesMap%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vMapEditText, Disable Type

      ; Unique
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Unique
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vUniqueEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabUnique x+0 yp hp , %StashTabUnique%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesUnique x+5 yp-5 w90 h20, %StashTabYesUnique%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vUniqueEditText, Disable Type

      ; Flask
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w145 h50 xs yp+20 , Flask
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number vFlaskEdit w40 xp+6 yp+17
      Gui, Inventory: Add, UpDown,Range1-99 gSaveStashTabs vStashTabFlask x+0 yp hp , %StashTabFlask%
      Gui, Inventory: Add, Slider, range0-2 center noticks gSaveStashTabs vStashTabYesFlask x+5 yp-5 w90 h20, %StashTabYesFlask%
      Gui, Inventory: Add, Text, xp yp+22 w90 center vFlaskEditText, Disable Type

      ;Run GreyOut
      GreyOutAffinity()

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w200 h100 x+50 ys , Intructions:
      Gui, Inventory: Font,
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - You can enable Currency Affinity 
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, and set the stash for other functions
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - CLF will take priority over Affinity 
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - Use slider to choose logic type
      Gui, Inventory: Add, Text, xs+10 yp+15 +Wrap w180, - Enable overflow Unique tabs

      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, Section w200 h210 xs yp+30 , Unique Affinity Logic
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesUniquePercentage Checked%StashTabYesUniquePercentage% xs+15 yp+25, Only stash above `% Affixes
      Gui, Inventory: Add, Edit, Number w40 xp yp+17
      Gui, Inventory: Add, UpDown, Range1-100 x+0 yp hp gSaveStashTabs vStashTabUniquePercentage , %StashTabUniquePercentage%
      Gui, Inventory: Add, Text, x+3 yp+3 , Minimum Affix Percentage
      ; Unique Ring
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h65 xs+10 yp+25 , Unique Ring
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+25
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabUniqueRing , %StashTabUniqueRing%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesUniqueRing Checked%StashTabYesUniqueRing% x+5 yp-2, Stash Overflow
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesUniqueRingAll Checked%StashTabYesUniqueRingAll% xp y+4, Including Junk

      ; Unique Dump
      Gui, Inventory: Font, Bold s8 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w180 h65 xs+10 yp+25 , Unique Dump
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit, Number w40 xp+6 yp+25
      Gui, Inventory: Add, UpDown, Range1-99 x+0 yp hp gSaveStashTabs vStashTabUniqueDump , %StashTabUniqueDump%
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesUniqueDump Checked%StashTabYesUniqueDump% x+5 yp-2, Stash Overflow
      Gui, Inventory: Add, Checkbox, gSaveStashTabs vStashTabYesUniqueDumpAll Checked%StashTabYesUniqueDumpAll% xp y+4, Including Junk

      Gui, Inventory: Tab, Chaos Recipe
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w175 h245 xm+5 ym+25, Chaos Recipe Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeEnableFunction Checked%ChaosRecipeEnableFunction% xs+10 yp+20 Section, Enable Chaos Recipe Logic
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeUnloadAll Checked%ChaosRecipeUnloadAll% xs yp+20, Sell all sets back to back
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeSkipJC Checked%ChaosRecipeSkipJC% xs yp+20, Skip Jeweler/Chroma Items
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeAllowDoubleJewellery Checked%ChaosRecipeAllowDoubleJewellery% xs yp+20, Allow 2x Jewellery limit
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeAllowDoubleBelt Checked%ChaosRecipeAllowDoubleBelt% xs yp+20, Allow 2x Belt limit

      Gui, Inventory: Add, GroupBox, w150 h50 xs y+5, Max # of each part
      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeMaxHoldingIDUpDown xp+5 yp+20 w40 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range0-72 vChaosRecipeMaxHoldingID , %ChaosRecipeMaxHoldingID%
      Gui, Inventory: Add, Text, x+5 yp+3, ID
      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeMaxHoldingUNIDUpDown x+5 yp-3 w40 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range0-72 vChaosRecipeMaxHoldingUNID , %ChaosRecipeMaxHoldingUNID%
      Gui, Inventory: Add, Text, x+5 yp+3, UNID
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeSmallWeapons Checked%ChaosRecipeSmallWeapons% xs yp+32, Limit Weapons 1x3/2x2
      Gui, Inventory: Add, Checkbox,gSaveChaos vChaosRecipeEnableUnId Checked%ChaosRecipeEnableUnId% xs yp+22, Leave Recipe Rare Un-Id
      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeLimitUnIdUpDown xs yp+20 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range70-100 vChaosRecipeLimitUnId , %ChaosRecipeLimitUnId%
      Gui, Inventory: Add, Text, x+5 yp+3, Item lvl Resume Id
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w175 h80 xs-10 y+25, Chaos Recipe Type
      Gui, Inventory: Font,
      Gui, Inventory: Add, Radio,gSaveChaosRadio xp+15 yp+20 vChaosRecipeTypePure Checked%ChaosRecipeTypePure% , Pure Chaos 60-74 ilvl
      Gui, Inventory: Add, Radio,gSaveChaosRadio xp yp+20 vChaosRecipeTypeHybrid Checked%ChaosRecipeTypeHybrid% , Hybrid Chaos 60-100 ilvl
      Gui, Inventory: Add, Radio,gSaveChaosRadio xp yp+20 vChaosRecipeTypeRegal Checked%ChaosRecipeTypeRegal% , Pure Regal 75+ ilvl
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h90 xs+190 ym+25, Chaos Recipe Stashing
      Gui, Inventory: Font,
      Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodDump Checked%ChaosRecipeStashMethodDump%, Use Dump Tab
      Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodTab Checked%ChaosRecipeStashMethodTab%, Use Chaos Recipe Tab
      Gui, Inventory: Add, Radio,gSaveChaosRadio xs+15 yp+20 w250 center vChaosRecipeStashMethodSort Checked%ChaosRecipeStashMethodSort%, Use Seperate Tab for Each Part
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h50 xs y+25, Chaos Recipe Tab
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabUpDown xs+15 yp+20 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTab , %ChaosRecipeStashTab%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for ALL PARTS
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox,Section w285 h225 xs y+25, Chaos Recipe Part Tabs
      Gui, Inventory: Font,
      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabWeaponUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabWeapon , %ChaosRecipeStashTabWeapon%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Weapons

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabArmourUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabArmour , %ChaosRecipeStashTabArmour%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Armours

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabHelmetUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabHelmet , %ChaosRecipeStashTabHelmet%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Helmets

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabGlovesUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabGloves , %ChaosRecipeStashTabGloves%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Gloves

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabBootsUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabBoots , %ChaosRecipeStashTabBoots%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Boots

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabBeltUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabBelt , %ChaosRecipeStashTabBelt%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Belts

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabAmuletUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabAmulet , %ChaosRecipeStashTabAmulet%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Amulets

      Gui, Inventory: Add, Edit,gSaveChaos vChaosRecipeStashTabRingUpDown xs+15 yp+22 w50 center
      Gui, Inventory: Add, UpDown,gSaveChaos Range1-99 vChaosRecipeStashTabRing , %ChaosRecipeStashTabRing%
      Gui, Inventory: Add, Text, x+5 yp+3, Stash Tab for Rings

      ; Crafting Bases
      Gui, Inventory: Tab, Crafting Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xm+5 ym+25, Armour Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseSTRUI xs+10 ys+20 w120, Edit STR Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Armour Evasion Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseSTRDEXUI xs+10 ys+20 w120, Edit STR DEX Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Ring Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseRINGUI xs+10 ys+20 w120, Edit Ring Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs+160 ym+25, Evasion Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseDEXUI xs+10 ys+20 w120, Edit DEX Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Armour ES Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseSTRINTUI xs+10 ys+20 w120, Edit STR INT Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Belt Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseBELTUI xs+10 ys+20 w120, Edit Belt Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs+160 ym+25, ES Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseINTUI xs+10 ys+20 w120, Edit INT Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Evasion ES Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseDEXINTUI xs+10 ys+20 w120, Edit DEX INT Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Amulet Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseAMULETUI xs+10 ys+20 w120, Edit Amulet Bases

      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w150 h60 section xs y+25, Weapon Bases
      Gui, Inventory: Font,
      Gui, Inventory: Add, Button, gCraftingBaseWeaponUI xs+10 ys+20 w120, Edit Weapon Bases

      ; Options
      Gui, Inventory: Font, Bold s9 cBlack, Arial
      Gui, Inventory: Add, GroupBox, w240 h150 section xm+5 ym+250, Options
      Gui, Inventory: Font,
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesStashBasesAboveIlvl Checked%YesStashBasesAboveIlvl% xs+8 ys+20 , Above Ilvl:
      Gui, Inventory: Add, Edit, Number w40 x+2 yp-3 w40
      Gui, Inventory: Add, UpDown, Range1-100 hp gUpdateExtra vStashBasesAboveIlvl , %StashBasesAboveIlvl%
      ;Gui, Inventory: Add, Checkbox, gUpdateExtra vYesCraftingBaseAutoUpdateOnStart Checked%YesCraftingBaseAutoUpdateOnStart% xs+8 y+8 , Get Higher ILvL on Start ?
      Gui, Inventory: Add, Checkbox, gUpdateExtra vYesCraftingBaseAutoILvLUP Checked%YesCraftingBaseAutoILvLUP% xs+8 y+8 , Auto Increase IlvL Based on Last Item ?
      ;Gui, Inventory: Add, Checkbox, gUpdateExtra vYesCraftingBaseAutoUpdate Checked%YesCraftingBaseAutoUpdate% xs+8 y+8 , Auto Update Crafting Base API Stash ?
      ;Gui, Inventory: Add, Checkbox, gUpdateExtra vYesCraftingBaseAutoRemoveLower Checked%YesCraftingBaseAutoRemoveLower% xs+8 y+8 , Remove Lower ILvL Itens ?

    }
    Gui, Inventory: show , w600 h500, Inventory Settings
  }
  Else If (Function = "Crafting")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Crafting
    {
      Built_Crafting := 1
      Gui, Crafting: New
      Gui, Crafting: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      Gui, Crafting: Add, Button, default gupdateEverything x425 y510 w125 h23, Save Configuration
      Gui, Crafting: Add, Button, gLaunchSite x+5 h23, Website

      Gui, Crafting: Add, Tab2, vCraftingGuiTabs x3 y3 w675 h555 -wrap , Map Crafting|Basic Crafting|Item Craft Beta

      Gui, Crafting: Tab, Map Crafting

      MapMethodList := "Disable|Transmutation+Augmentation|Alchemy|Alchemy+Vaal|Chisel+Alchemy|Chisel+Alchemy+Vaal|Binding|Chisel+Binding|Chisel+Binding+Vaal|Hybrid|Hybrid+Vaal|Binding+Vaal|Chisel+Hybrid|Chisel+Hybrid+Vaal"
      MapTierList := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16"
      MapSetValue := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100"
      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add, Text, Section x12 ym+25, Map Crafting

      Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 1:
      Gui, Crafting: Font,
      Gui, Crafting: Font,s7
      Gui, Crafting: Add, Text, xs+5 ys+20 , Initial
      Gui, Crafting: Add, Text, xs+55 ys+20 , Ending
      Gui, Crafting: Add, Text, xs+105 ys+20 , Method
      Gui, Crafting: Font,s8
      Gui, Crafting: Add, DropDownList, xs+5 ys+35 w40 vStartMapTier1 Choose%StartMapTier1%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+55 ys+35 w40 vEndMapTier1 Choose%EndMapTier1%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+105 ys+35 w175 vCraftingMapMethod1 Choose%CraftingMapMethod1%, %MapMethodList%
      GuiControl,Crafting: ChooseString, CraftingMapMethod1, %CraftingMapMethod1%
      Gui, Crafting: Font, Bold s9 cBlack, Arial

      Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 2:
      Gui, Crafting: Font,
      Gui, Crafting: Font,s7
      Gui, Crafting: Add, Text, xs+5 ys+20 , Initial
      Gui, Crafting: Add, Text, xs+55 ys+20 , Ending
      Gui, Crafting: Add, Text, xs+105 ys+20 , Method
      Gui, Crafting: Font,s8
      Gui, Crafting: Add, DropDownList, xs+5 ys+35 w40 vStartMapTier2 Choose%StartMapTier2%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+55 ys+35 w40 vEndMapTier2 Choose%EndMapTier2%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+105 ys+35 w175 vCraftingMapMethod2 Choose%CraftingMapMethod2%, %MapMethodList%
      GuiControl,Crafting: ChooseString, CraftingMapMethod2, %CraftingMapMethod2%
      Gui, Crafting: Font,
      Gui, Crafting: Font, Bold s9 cBlack, Arial

      Gui, Crafting: Add,GroupBox,Section w285 h65 xs, Map Tier Range 3:
      Gui, Crafting: Font,
      Gui, Crafting: Font,s7
      Gui, Crafting: Add, Text, xs+5 ys+20 , Initial
      Gui, Crafting: Add, Text, xs+55 ys+20 , Ending
      Gui, Crafting: Add, Text, xs+105 ys+20 , Method
      Gui, Crafting: Font,s8
      Gui, Crafting: Add, DropDownList, xs+5 ys+35 w40 vStartMapTier3 Choose%StartMapTier3%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+55 ys+35 w40 vEndMapTier3 Choose%EndMapTier3%, %MapTierList%
      Gui, Crafting: Add, DropDownList, xs+105 ys+35 w175 vCraftingMapMethod3 Choose%CraftingMapMethod3%, %MapMethodList%
      GuiControl,Crafting: ChooseString, CraftingMapMethod3, %CraftingMapMethod3%
      Gui, Crafting: Font,
      Gui, Crafting: Font, Bold s9 cBlack, Arial

      Gui, Crafting: Add,GroupBox,Section w285 h55 xs, Map Mods:
      Gui, Crafting: Font,
      Gui, Crafting: Font,s7
      Gui, Crafting: Add, Button, xs+40 ys+20 w200 gCustomMapModsUI, Custom Map Mods
      Gui, Crafting: Font,
      Gui, Crafting: Font, Bold s9 cBlack, Arial

      Gui, Crafting: Add,GroupBox,Section w200 h130 x320 y50, Minimum Map Qualities:
      Gui, Crafting: Font, 
      Gui, Crafting: Font,s8

      Gui, Crafting: Add, Edit, number limit2 xs+15 yp+18 w40
      Gui, Crafting: Add, UpDown, Range1-99 x+0 yp hp vMMapItemQuantity , %MMapItemQuantity%
      Gui, Crafting: Add, Text, x+10 yp+3 , Item Quantity

      Gui, Crafting: Add, Edit, number limit2 xs+15 y+15 w40
      Gui, Crafting: Add, UpDown, Range1-54 x+0 yp hp vMMapItemRarity , %MMapItemRarity%
      Gui, Crafting: Add, Text, x+10 yp+3 , Item Rarity

      Gui, Crafting: Add, Edit, number limit2 xs+15 y+15 w40
      Gui, Crafting: Add, UpDown, Range1-45 x+0 yp hp vMMapMonsterPackSize , %MMapMonsterPackSize%
      Gui, Crafting: Add, Text, x+10 yp+3 , Monster Pack Size

      Gui, Crafting: Add, Checkbox, vEnableMQQForMagicMap xs+15 y+15 Checked%EnableMQQForMagicMap%, Enable on Magic Maps

      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add,GroupBox,Section w290 h60 x320 y190, Other Settings:
      Gui, Crafting: Font,
      Gui, Crafting: Font,s8
      Gui, Crafting: Add, Checkbox, vHeistAlcNGo xs+10 ys+20 Checked%HeistAlcNGo%, Alchemy Contract and Blueprint?
      Gui, Crafting: Add, Checkbox, vMoveMapsToArea xs+10 ys+40 Checked%MoveMapsToArea%, Move Crafted Maps and Enhance Items to Map Area?
      Gui, Crafting: Font

      Gui, Crafting: Tab, Basic Crafting
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, GroupBox,section Center xm+15 ym+25 w275 h100, Chance
      Gui, Crafting: Font
      Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftChanceMethod Checked" (BasicCraftChanceMethod=1?1:0), Cursor
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftChanceMethod=2?1:0), Currency Stash
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftChanceMethod=3?1:0), Bulk Inventory
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, Checkbox, % "gSaveBasicCraft vBasicCraftChanceScour xs+30 y+20 Checked" BasicCraftChanceScour, Scour and retry
      Gui, Crafting: Font
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, GroupBox,section Center xs ys+115 w275 h100, Color
      Gui, Crafting: Font
      Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftColorMethod Checked" (BasicCraftColorMethod=1?1:0), Cursor
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftColorMethod=2?1:0), Currency Stash
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftColorMethod=3?1:0), Bulk Inventory
      Gui, Crafting: Font, Bold s12 cRed, Arial
      Gui, Crafting: Add, Text,% "xs+25 y+20"
      Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftR, % BasicCraftR
      Gui, Crafting: Add, Text, x+5 yp, R 
      Gui, Crafting: Font, Bold s12 cGreen, Arial
      Gui, Crafting: Add, Text,% "x+25 yp"
      Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftG, % BasicCraftG
      Gui, Crafting: Add, Text, x+5 yp, G
      Gui, Crafting: Font, Bold s12 cBlue, Arial
      Gui, Crafting: Add, Text,% "x+25 yp"
      Gui, Crafting: Add, UpDown,gSaveBasicCraft Range0-6 vBasicCraftB, % BasicCraftB
      Gui, Crafting: Add, Text, x+5 yp, B
      Gui, Crafting: Font
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, GroupBox,section Center xm+295 ym+25 w275 h100, Link
      Gui, Crafting: Font
      Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftLinkMethod Checked" (BasicCraftLinkMethod=1?1:0), Cursor
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftLinkMethod=2?1:0), Currency Stash
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftLinkMethod=3?1:0), Bulk Inventory
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, Text,% "xs+25 y+20"
      Gui, Crafting: Add, UpDown, Range0-6 vBasicCraftDesiredLinks gSaveBasicCraft, % BasicCraftDesiredLinks
      Gui, Crafting: Add, Text, x+5 yp, Desired Links
      Gui, Crafting: Add, CheckBox, x+10 yp gSaveBasicCraft vBasicCraftLinkAuto Checked%BasicCraftLinkAuto%, Auto
      Gui, Crafting: Font
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, GroupBox,section Center xs ys+115 w275 h100, Socket
      Gui, Crafting: Font
      Gui, Crafting: Add, Radio,% "gBasicCraftRadio xs+10 ys+25 vBasicCraftSocketMethod Checked" (BasicCraftSocketMethod=1?1:0), Cursor
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftSocketMethod=2?1:0), Currency Stash
      Gui, Crafting: Add, Radio,% "disabled gBasicCraftRadio x+10 yp Checked" (BasicCraftSocketMethod=3?1:0), Bulk Inventory
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, Text,% "xs+25 y+20"
      Gui, Crafting: Add, UpDown, Range0-6 vBasicCraftDesiredSockets gSaveBasicCraft, % BasicCraftDesiredSockets
      Gui, Crafting: Add, Text, x+5 yp, Desired Sockets
      Gui, Crafting: Add, CheckBox, x+10 yp gSaveBasicCraft vBasicCraftSocketAuto Checked%BasicCraftSocketAuto%, Auto
      Gui, Crafting: Font

      ;Item Crafting Beta
      Gui, Crafting: Tab, Item Craft Beta
      ;Load DDL Content from API
      aux := ""
      for k, v in PoeDBAPI{
        If(v ~= "Map(.+)"){
          Continue
        }Else{
          aux .= v . "|"
        } 
      }
        
      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add, Text, Section xm+5 ym+25, Item Crafting BETA
      Gui, Crafting: Font,

      ; Mod Selector
      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add, GroupBox, w320 h80 xs yp+20 , Mod Selector
      Gui, Crafting: Font,
      Gui, Crafting: Add, DropDownList, vItemCraftingBaseSelector gItemCraftingSubmit Sort xp+10 yp+20 w300, %aux%
      ;;Select DDL Value Based on Last Value Saved
      GuiControl, ChooseString, ItemCraftingBaseSelector, %ItemCraftingBaseSelector%
      Gui, Crafting: Add, Button, gModsUI xp yp+25 w300, Open UI

      ; Affix Matcher
      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add, GroupBox, w320 h110 xs yp+35 , Affix Matcher
      Gui, Crafting: Font,
      Gui, Crafting: Add, Text, xs+10 yp+20, How Many Prefix From Mod List ?
      Gui, Crafting: Add, Edit, Number w40 x+10 yp
      Gui, Crafting: Add, UpDown,Range0-3 vItemCraftingNumberPrefix gItemCraftingSubmit x+0 yp hp , %ItemCraftingNumberPrefix%
      Gui, Crafting: Add, Text, xs+10 yp+30, How Many Suffix From Mod List ?
      Gui, Crafting: Add, Edit, Number w40 x+10 yp
      Gui, Crafting: Add, UpDown,Range0-3 vItemCraftingNumberSuffix gItemCraftingSubmit x+0 yp hp , %ItemCraftingNumberSuffix%
      Gui, Crafting: Add, Text, xs+10 yp+30, Any Combination From Mod List ? (Set 0 to Disable)
      Gui, Crafting: Add, Edit, Number w40 x+10 yp
      Gui, Crafting: Add, UpDown,Range0-3 vItemCraftingNumberCombination gItemCraftingSubmit x+0 yp hp , %ItemCraftingNumberCombination%

      ; Crafting Method
      Gui, Crafting: Font, Bold s9 cBlack, Arial
      Gui, Crafting: Add, GroupBox, w320 h45 xs yp+35 , Crafting Method
      Gui, Crafting: Font,
      Gui, Crafting: Add, DropDownList, vItemCraftingMethod gItemCraftingSubmit xp+10 yp+20 w300, Alteration Spam|Alteration and Aug Spam|Alteration and Aug and Regal Spam|Scouring and Alchemy Spam|Chaos Spam
      ;;Select DDL Value Based on Last Value Saved
      GuiControl, ChooseString, ItemCraftingMethod, %ItemCraftingMethod%

      ; Guide
      Gui, Crafting: Font, Bold s12 cBlack, Arial
      Gui, Crafting: Add, GroupBox, Section w250 h400 xs+330 ym+25 , Instructions
      Gui, Crafting: Font, 
      Gui, Crafting: Font, s11 cBlack, Arial
      Gui, Crafting: Add, Link, xs+10 yp+20 w220, This is a Experimental Feature!`nWe highly recommend using <a href="https://www.craftofexile.com/">CraftOfExile</a> to Calculate the Currency to Match the Desired Mods.`nSteps:`n1) Select Item Base in Mod Selector`n2) Open UI and Check Mods that You Want (Remember to Check Higher Mods too, This Feature is Tier Sensitive)`n3) Select How Many Prefix/Suffix from Mod Selector It Should Match to Stop`n4) Select the Crafting Method.`n5) Use the Bound Key (Default Key F11) with Your Cursor Over The Item and Stash Open to Start The Process`nP.S: You Can Break the Loop Pressing Bound Key Again
      Gui, Crafting: Font,

      Gui, Crafting: Show
    }
    Gui, Crafting: show , w650 h550, Crafting Settings
  }
  Else If (Function = "Strings")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Strings
    {
      Built_Strings := 1
      Gui, Strings: New
      Gui, Strings: +AlwaysOnTop -MinimizeBox
      ;Save Setting
      ; Gui, Add, Button, default gupdateEverything    x295 y470  w150 h23,   Save Configuration

      Gui, Strings: Add, Button, gLaunchSite x295 y470 h23, Website
      Gui, Strings: Add, Button, gft_Start x+5 h23, FindText Gui (capture)
      Gui, Strings: Font, Bold cBlack
      Gui, Strings: Add, GroupBox, Section w625 h10 x3 y3, String Samples from the FindText library - Match your resolution's height with the number in the string Label
      Gui, Strings: Add, Tab2, Section vStringsGuiTabs x20 y30 w600 h480 -wrap , General|Vendor|Debuff
      Gui, Strings: Font,

      Gui, Strings: Tab, General
      Gui, Strings: Add, Button, xs+1 ys+1 w1 h1, 
      Gui, Strings: +Delimiter?
      Gui, Strings: Add, Text, xs+10 ys+25 section, OHB 1 pixel bar - Only Adjust if not 1080 Height
      Gui, Strings: Add, ComboBox, xp y+8 w220 vHealthBarStr gUpdateStringEdit , %HealthBarStr%??"%1080_HealthBarStr%"?"%1440_HealthBarStr%"?"%1440_HealthBarStr_Alt%"?"%1050_HealthBarStr%"
      Gui, Strings: Add, Button, hp w50 x+10 yp vOHB_EditorBtn gOHBUpdate , Make
      Gui, Strings: Add, Text, x+10 x+10 ys , Capture of the Skill up icon
      Gui, Strings: Add, ComboBox, y+8 w280 vSkillUpStr gUpdateStringEdit , %SkillUpStr%??"%1080_SkillUpStr%"?"%1440_SkillUpStr%"?"%1050_SkillUpStr%"?"%768_SkillUpStr%"
      Gui, Strings: Add, Text, xs y+15 section , Capture of the words Sell Items
      Gui, Strings: Add, ComboBox, y+8 w280 vSellItemsStr gUpdateStringEdit , %SellItemsStr%??"%1080_SellItemsStr%"?"%2160_SellItemsStr%"?"%1440_SellItemsStr%"?"%1050_SellItemsStr%"?"%768_SellItemsStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Stash
      Gui, Strings: Add, ComboBox, y+8 w280 vStashStr gUpdateStringEdit , %StashStr%??"%1080_StashStr%"?"%2160_StashStr%"?"%1440_StashStr%"?"%1050_StashStr%"?"%768_StashStr%"
      Gui, Strings: Add, Text, xs y+15 section , Capture of the X button
      Gui, Strings: Add, ComboBox, y+8 w280 vXButtonStr gUpdateStringEdit , %XButtonStr%??"%1080_XButtonStr%"?"%1440_XButtonStr%"?"%1050_XButtonStr%"?"%768_XButtonStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Heist Locker
      Gui, Strings: Add, ComboBox, y+8 w280 vHeistLockerStr gUpdateStringEdit , %HeistLockerStr%??"%1080_HeistLockerStr%"?"%1440_HeistLockerStr%"
      Gui, Strings: +Delimiter|

      Gui, Strings: Tab, Vendor
      Gui, Strings: Add, Button, Section x20 y30 w1 h1, 
      Gui, Strings: +Delimiter?
      Gui, Strings: Add, Text, xs+10 ys+25 section, Capture of the Hideout vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorStr gUpdateStringEdit , %VendorStr%??"%1080_MasterStr%"?"%1080_NavaliStr%"?"%1080_HelenaStr%"?"%1080_ZanaStr%"?"%2160_NavaliStr%"?"%1440_ZanaStr%"?"%1440_NavaliStr%"?"%1050_MasterStr%"?"%1050_NavaliStr%"?"%1050_HelenaStr%"?"%1050_ZanaStr%"?"%768_NavaliStr%"?"%1440_JunStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Azurite Mines vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorMineStr gUpdateStringEdit , %VendorMineStr%??"%1080_MasterStr%"?"%1050_MasterStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Lioneye vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorLioneyeStr gUpdateStringEdit , %VendorLioneyeStr%??"%1080_BestelStr%"?"%1050_BestelStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Forest vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorForestStr gUpdateStringEdit , %VendorForestStr%??"%1080_GreustStr%"?"%1050_GreustStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Sarn vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorSarnStr gUpdateStringEdit , %VendorSarnStr%??"%1080_ClarissaStr%"?"%1050_ClarissaStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Highgate vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorHighgateStr gUpdateStringEdit , %VendorHighgateStr%??"%1080_PetarusStr%"?"%1050_PetarusStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Overseer vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorOverseerStr gUpdateStringEdit , %VendorOverseerStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Bridge vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorBridgeStr gUpdateStringEdit , %VendorBridgeStr%??"%1080_HelenaStr%"?"%1050_HelenaStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Docks vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorDocksStr gUpdateStringEdit , %VendorDocksStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, x+10 ys , Capture of the Oriath vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorOriathStr gUpdateStringEdit , %VendorOriathStr%??"%1080_LaniStr%"?"%1050_LaniStr%"
      Gui, Strings: Add, Text, xs y+15 section, Capture of the Harbour vendor nameplate
      Gui, Strings: Add, ComboBox, y+8 w280 vVendorHarbourStr gUpdateStringEdit , %VendorHarbourStr%??"%1080_FenceStr%"
      Gui, Strings: +Delimiter|
      Gui, Strings: Tab, Debuff
      Gui, Strings: Add, Button, Section x20 y30 w1 h1, 
      Gui, Strings: +Delimiter?

      Gui, Strings: Add, Text, xs+10 ys+25 section, Curse - Elemental Weakness
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseEleWeakStr gUpdateStringEdit , %debuffCurseEleWeakStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Vulnerability
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseVulnStr gUpdateStringEdit , %debuffCurseVulnStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Enfeeble
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseEnfeebleStr gUpdateStringEdit , %debuffCurseEnfeebleStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Temporal Chains
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseTempChainStr gUpdateStringEdit , %debuffCurseTempChainStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Condutivity
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseCondStr gUpdateStringEdit , %debuffCurseCondStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Flammability
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseFlamStr gUpdateStringEdit , %debuffCurseFlamStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Curse - Frostbite
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseFrostStr gUpdateStringEdit , %debuffCurseFrostStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Curse - Warlord's Mark
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffCurseWarMarkStr gUpdateStringEdit , %debuffCurseWarMarkStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Shock
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffShockStr gUpdateStringEdit , %debuffShockStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Bleed
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffBleedStr gUpdateStringEdit , %debuffBleedStr%??"%1080_CurseStr%"
      Gui, Strings: Add, Text, xs y+15 section, Freeze
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffFreezeStr gUpdateStringEdit , %debuffFreezeStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, x+10 ys , Ignite
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffIgniteStr gUpdateStringEdit , %debuffIgniteStr%??"%1080_CurseStr%"

      Gui, Strings: Add, Text, xs y+15 section, Poison
      Gui, Strings: Add, ComboBox, y+8 w280 vdebuffPoisonStr gUpdateStringEdit , %debuffPoisonStr%??"%1080_CurseStr%"

      Gui, Strings: +Delimiter|
    }
    Gui, Strings: show , w640 h525, FindText Strings
  }
  Else If (Function = "Chat")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Chat
    {
      Built_Chat := 1
      Gui, Chat: New
      Gui, Chat: +AlwaysOnTop -MinimizeBox

      ;Save Setting
      Gui, Chat: Add, Button, default gupdateEverything x295 y320 w150 h23, Save Configuration
      Gui, Chat: Add, Button, gLaunchSite x+5 h23, Website

      Gui, Chat: Add, Tab, w590 h350 xm+5 ym Section , Commands|Reply Whisper
      Gui, Chat: Tab, Commands
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section w60 h85 ,Modifier
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, xs+4 ys+20 w50 h23 v1Prefix1, %1Prefix1%
      Gui, Chat: Add, Edit, y+8 w50 h23 v1Prefix2, %1Prefix2%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w60 h275 ,Keys
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, ys+20 xs+4 w50 h23 v1Suffix1, %1Suffix1%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix2, %1Suffix2%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix3, %1Suffix3%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix4, %1Suffix4%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix5, %1Suffix5%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix6, %1Suffix6%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix7, %1Suffix7%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix8, %1Suffix8%
      Gui, Chat: Add, Edit, y+5 w50 h23 v1Suffix9, %1Suffix9%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w300 h275 ,Commands
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      DefaultCommands := [ "/Hideout","/Menagerie","/Delve","/cls","/ladder","/reset_xp","/invite RecipientName","/kick RecipientName","@RecipientName Thanks for the trade!","@RecipientName Still Interested?","/kick CharacterName"]
      textList=
      For k, v in DefaultCommands
        textList .= (!textList ? "" : "|") v
      Gui, Chat: Add, ComboBox, xs+4 ys+20 w290 v1Suffix1Text, %textList%
      GuiControl,Chat: Text, 1Suffix1Text, %1Suffix1Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix2Text, %textList%
      GuiControl,Chat: Text, 1Suffix2Text, %1Suffix2Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix3Text, %textList%
      GuiControl,Chat: Text, 1Suffix3Text, %1Suffix3Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix4Text, %textList%
      GuiControl,Chat: Text, 1Suffix4Text, %1Suffix4Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix5Text, %textList%
      GuiControl,Chat: Text, 1Suffix5Text, %1Suffix5Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix6Text, %textList%
      GuiControl,Chat: Text, 1Suffix6Text, %1Suffix6Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix7Text, %textList%
      GuiControl,Chat: Text, 1Suffix7Text, %1Suffix7Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix8Text, %textList%
      GuiControl,Chat: Text, 1Suffix8Text, %1Suffix8Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v1Suffix9Text, %textList%
      GuiControl,Chat: Text, 1Suffix9Text, %1Suffix9Text%
      Gui, Chat: Tab, Reply Whisper
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section w60 h85 ,Modifier
      Gui, Chat: Font,

      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, xs+4 ys+20 w50 h23 v2Prefix1, %2Prefix1%
      Gui, Chat: Add, Edit, y+8 w50 h23 v2Prefix2, %2Prefix2%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w60 h275 ,Keys
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      Gui, Chat: Add, Edit, ys+20 xs+4 w50 h23 v2Suffix1, %2Suffix1%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix2, %2Suffix2%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix3, %2Suffix3%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix4, %2Suffix4%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix5, %2Suffix5%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix6, %2Suffix6%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix7, %2Suffix7%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix8, %2Suffix8%
      Gui, Chat: Add, Edit, y+5 w50 h23 v2Suffix9, %2Suffix9%
      Gui, Chat: Font,s9 cBlack Bold Underline, Arial
      Gui, Chat: Add,GroupBox,Section x+10 ys w300 h275 ,Whisper Reply
      Gui, Chat: Font,
      Gui, Chat: Font,s9,Arial
      DefaultWhisper := [ "/invite RecipientName","Sure, will invite in a sec.","In a map, will get to you in a minute.","Sorry, going to be a while.","No thank you.","Sold","/afk Sold to RecipientName"]
      textList=
      For k, v in DefaultWhisper
        textList .= (!textList ? "" : "|") v
      Gui, Chat: Add, ComboBox, xs+4 ys+20 w290 v2Suffix1Text, %textList%
      GuiControl,Chat: Text, 2Suffix1Text, %2Suffix1Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix2Text, %textList%
      GuiControl,Chat: Text, 2Suffix2Text, %2Suffix2Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix3Text, %textList%
      GuiControl,Chat: Text, 2Suffix3Text, %2Suffix3Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix4Text, %textList%
      GuiControl,Chat: Text, 2Suffix4Text, %2Suffix4Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix5Text, %textList%
      GuiControl,Chat: Text, 2Suffix5Text, %2Suffix5Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix6Text, %textList%
      GuiControl,Chat: Text, 2Suffix6Text, %2Suffix6Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix7Text, %textList%
      GuiControl,Chat: Text, 2Suffix7Text, %2Suffix7Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix8Text, %textList%
      GuiControl,Chat: Text, 2Suffix8Text, %2Suffix8Text%
      Gui, Chat: Add, ComboBox, y+5 w290 v2Suffix9Text, %textList%
      GuiControl,Chat: Text, 2Suffix9Text, %2Suffix9Text%
    }
    Gui, Chat: show , w620 h370, Chat Hotkeys
  }
  Else If (Function = "Controller")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    If !Built_Controller
    {
      Built_Controller := 1
      Gui, Controller: New
      Gui, Controller: +AlwaysOnTop -MinimizeBox
      DefaultButtons := [ "ItemSort","QuickPortal","PopFlasks","GemSwap","Logout","LButton","RButton","MButton","q","w","e","r","t"]
      textList= 
      For k, v in DefaultButtons
        textList .= (!textList ? "" : "|") v

      Gui, Controller: Add, Picture, xm ym+20 w600 h400 +0x4000000, %A_ScriptDir%\data\Controller.png

      Gui, Controller: Add, Checkbox, section xp y+-10 vYesMovementKeys Checked%YesMovementKeys% , Use Move Keys?
      Gui, Controller: Add, Checkbox, vYesTriggerUtilityKey Checked%YesTriggerUtilityKey% , Use utility on Move?
      Gui, Controller: Add, DropDownList, x+5 yp-5 w40 vTriggerUtilityKey Choose%TriggerUtilityKey%, 1|2|3|4|5

      Gui, Controller: Add,GroupBox, section xm+80 ym+15 w80 h40 ,L Bumper
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonLB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonLB, %hotkeyControllerButtonLB%
      Gui, Controller: Add,GroupBox, xs+360 ys w80 h40 ,R Bumper
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonRB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonRB, %hotkeyControllerButtonRB%

      Gui, Controller: Add,GroupBox, section xm+65 ym+100 w90 h80 ,D-Pad
      Gui, Controller: add,text, xs+15 ys+30, Mouse`nMovement

      Gui, Controller: Add,GroupBox, section xm+165 ym+180 w80 h80 ,Left Joystick
      Gui, Controller: Add,Checkbox, xs+5 ys+30 Checked%YesTriggerUtilityJoystickKey% vYesTriggerUtilityJoystickKey, Use util from`nMove Keys?
      Gui, Controller: Add,GroupBox, xs ys+90 w80 h40 ,L3
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonL3, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonL3, %hotkeyControllerButtonL3%

      Gui, Controller: Add,GroupBox,section xs+190 ys w80 h80 ,Right Joystick
      Gui, Controller: Add,Checkbox, xp+5 y+-53 Checked%YesTriggerJoystickRightKey% vYesTriggerJoystickRightKey, Use key?
      Gui, Controller: Add, ComboBox, xp y+8 w70 vhotkeyControllerJoystickRight, LButton|RButton|q|w|e|r|t
      GuiControl,Controller: Text, hotkeyControllerJoystickRight, %hotkeyControllerJoystickRight%
      Gui, Controller: Add,GroupBox, xs ys+90 w80 h40 ,R3
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonR3, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonR3, %hotkeyControllerButtonR3%

      Gui, Controller: Add,GroupBox, section xm+140 ym+60 w80 h40 ,Select
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonBACK, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonBACK, %hotkeyControllerButtonBACK%
      Gui, Controller: Add,GroupBox, xs+245 ys w80 h40 ,Start
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w70 vhotkeyControllerButtonSTART, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonSTART, %hotkeyControllerButtonSTART%

      Gui, Controller: Add,GroupBox, section xm+65 ym+280 w40 h40 ,Up
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19 vhotkeyUp, %hotkeyUp%
      Gui, Controller: Add,GroupBox, xs ys+80 w40 h40 ,Down
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19 vhotkeyDown, %hotkeyDown%
      Gui, Controller: Add,GroupBox, xs-40 ys+40 w40 h40 ,Left
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19 vhotkeyLeft, %hotkeyLeft%
      Gui, Controller: Add,GroupBox, xs+40 ys+40 w40 h40 ,Right
      Gui, Controller: Add,Edit, xp+5 y+-23 w30 h19 vhotkeyRight, %hotkeyRight%

      Gui, Controller: Add,GroupBox,section xm+465 ym+80 w70 h40 ,Y
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60 vhotkeyControllerButtonY, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonY, %hotkeyControllerButtonY%
      Gui, Controller: Add,GroupBox, xs ys+80 w70 h40 ,A
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60 vhotkeyControllerButtonA, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonA, %hotkeyControllerButtonA%
      Gui, Controller: Add,GroupBox, xs-40 ys+40 w70 h40 ,X
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60 vhotkeyControllerButtonX, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonX, %hotkeyControllerButtonX%
      Gui, Controller: Add,GroupBox, xs+40 ys+40 w70 h40 ,B
      Gui, Controller: Add,ComboBox, xp+5 y+-23 w60 vhotkeyControllerButtonB, %textList%|%hotkeyLootScan%|%hotkeyCloseAllUI%
      GuiControl,Controller: Text, hotkeyControllerButtonB, %hotkeyControllerButtonB%

      ;Save Setting
      Gui, Controller: Add, Button, default gupdateEverything x295 y470 w150 h23, Save Configuration
      Gui, Controller: Add, Button, gLaunchSite x+5 h23, Website
    }
    Gui, Controller: show , w620 h500, Controller Settings
  }
  Else if (Function = "Globe")
  {
    Gui, 1: Submit
    CheckGamestates:= False
    Element := Var[1]
    If (!Built_Globe || Element = "Reset")
    {
      If (Element = "Reset")
      {
        Gui, Globe: Destroy
        Globe := Array_DeepClone(Base.Globe)
      }
      Built_Globe := 1
      Gui, Globe: New
      Gui, Globe: +AlwaysOnTop -MinimizeBox
      Picker := New ColorPicker("Globe","ColorPicker",460,30,80,200,120,0x000000)
      Gui, Globe: +AlwaysOnTop -MinimizeBox -MaximizeBox
      Gui, Globe: Add, Button, xm ym+8 w1 h1
      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xm ym w205 h100 Section, Life Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_Life_X1 xs+10 yp+20 , % "X1:" Globe.Life.X1
      Gui, Globe: Add, Text, vGlobe_Life_Y1 x+5 yp , % "Y1:" Globe.Life.Y1
      Gui, Globe: Add, Text, vGlobe_Life_X2 xs+10 y+8 , % "X2:" Globe.Life.X2
      Gui, Globe: Add, Text, vGlobe_Life_Y2 x+5 yp , % "Y2:" Globe.Life.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_Life x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.Life.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.Life.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_Life x+1 yp hp, % Globe.Life.Color.Variance
      TempC := Format("0x{1:06X}",Globe.Life.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_Life xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_Life xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_Life h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_Life wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xs+220 ys w205 h100 Section, Mana Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_Mana_X1 xs+10 yp+20 , % "X1:" Globe.Mana.X1
      Gui, Globe: Add, Text, vGlobe_Mana_Y1 x+5 yp , % "Y1:" Globe.Mana.Y1
      Gui, Globe: Add, Text, vGlobe_Mana_X2 xs+10 y+8 , % "X2:" Globe.Mana.X2
      Gui, Globe: Add, Text, vGlobe_Mana_Y2 x+5 yp , % "Y2:" Globe.Mana.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_Mana x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.Mana.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.Mana.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_Mana x+1 yp hp, % Globe.Mana.Color.Variance
      TempC := Format("0x{1:06X}",Globe.Mana.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_Mana xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_Mana xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_Mana h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_Mana wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xm y+60 w205 h100 Section, Energy Shield Scan Area
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, vGlobe_ES_X1 xs+10 yp+20 , % "X1:" Globe.ES.X1
      Gui, Globe: Add, Text, vGlobe_ES_Y1 x+5 yp , % "Y1:" Globe.ES.Y1
      Gui, Globe: Add, Text, vGlobe_ES_X2 xs+10 y+8 , % "X2:" Globe.ES.X2
      Gui, Globe: Add, Text, vGlobe_ES_Y2 x+5 yp , % "Y2:" Globe.ES.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_ES x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.ES.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.ES.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_ES x+1 yp hp, % Globe.ES.Color.Variance
      TempC := Format("0x{1:06X}",Globe.ES.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_ES xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_ES xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_ES h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_ES wp hp xp y+5, Show Area

      Gui, Globe: Font, Bold s9 c777777
      Gui, Globe: Add, GroupBox, xs+220 ys w205 h100 Section, Eldritch Battery Scan Area
      Gui, Globe: Font, Bold
      Gui, Globe: Add, Text, vGlobe_EB_X1 xs+10 yp+20 , % "X1:" Globe.EB.X1
      Gui, Globe: Add, Text, vGlobe_EB_Y1 x+5 yp , % "Y1:" Globe.EB.Y1
      Gui, Globe: Add, Text, vGlobe_EB_X2 xs+10 y+8 , % "X2:" Globe.EB.X2
      Gui, Globe: Add, Text, vGlobe_EB_Y2 x+5 yp , % "Y2:" Globe.EB.Y2
      Gui, Globe: Add, Text, xs+10 y+8, Color:
      Gui, Globe: Font
      Gui, Globe: Add, Edit, gWR_Update vWR_Edit_Color_EB x+2 yp-2 hp+4 w60, % Format("0x{1:06X}",Globe.EB.Color.Hex)
      Gui, Globe: Font, Bold c777777
      Gui, Globe: Add, Text, x+5 yp+2, Variance:
      Gui, Globe: Add, Text, x+2 yp w35, % Globe.EB.Color.Variance
      Gui, Globe: Add, UpDown, gWR_Update vWR_UpDown_Color_EB x+1 yp hp, % Globe.EB.Color.Variance
      TempC := Format("0x{1:06X}",Globe.EB.Color.Hex)
      Gui, Globe: Add, Text, gColorLabel_EB xs+10 y+6 hp w185,
      Gui, Globe: Add, Progress, vWR_Progress_Color_EB xs+10 yp hp wp c%TempC% BackgroundBlack, 100
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Area_EB h18 xs+115 ys+15, Choose Area
      Gui, Globe: Add, Button, gWR_Update vWR_Btn_Show_EB wp hp xp y+5, Show Area

      Gui, Globe: Add, Button, gWR_Update vWR_Save_JSON_Globe ys+110 xm+25, Save Values to JSON file
      Gui, Globe: Add, Button, gWR_Update vWR_Reset_Globe ys+110 xm+240 wp, Reset to Initial Values
      Gui, Globe: Font, s25 Bold c777777
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_Life xm y+15 c78211A, % "Life " Player.Percent.Life "`%"
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_ES x+0 yp c51DEFF, % "ES " Player.Percent.ES "`%"
      Gui, Globe: Add, Text, w220 Center vGlobe_Percent_Mana x+0 yp c1460A6, % "Mana " Player.Percent.Mana "`%"
    }
    GlobeActive := True
    Gui, Globe: show , Center AutoSize, Globe Settings
  }
  Else If (Function = "Locate")
  {
    LocateType := Var[2]
    Gui, Hide
    Loop
    {
      MouseGetPos, x, y
      If (x != oldx || y != oldy)
        ToolTip, % "-- Locate "LocateType " --`n@ " x "," y "`nPress Ctrl to set"
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    Tooltip
    %LocateType%X := x, %LocateType%Y := y
    GuiControl, Inventory: ,% LocateType "X", %x%
    GuiControl, Inventory: ,% LocateType "Y", %y%
    MsgBox % x "," y " was captured as the new location for "LocateType
    Gui, Show
  }
  Else If (Function = "Locate2")
  {
    MsgBoxVals(Var,2)
    ; LocateType := Var[2]
    ending := StrSplit(SubStr(Var[2],-1))
    slot := ending[1], position := ending[2]
    Gui, Hide
    Loop
    {
      MouseGetPos, x, y
      If (x != oldx || y != oldy)
        ToolTip, % "-- Locate Swap "slot " "position " --`n@ " x "," y "`nPress Ctrl to set"
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    Tooltip
    swap%slot%X%position% := x, swap%slot%Y%position% := y
    GuiControl, perChar: ,% "swap" slot "X" position, %x%
    GuiControl, perChar: ,% "swap" slot "Y" position, %y%
    MsgBox % x "," y " was captured as the new location for Swap "slot " "position
    Gui, Show
  }
  Else if (Function = "Area")
  {
    Gui, Submit
    Grab := LetUserSelectRect()
    AreaType := Var[2]
    Globe[AreaType].X1 := Grab.X1, Globe[AreaType].Y1 := Grab.Y1, Globe[AreaType].X2 := Grab.X2, Globe[AreaType].Y2 := Grab.Y2
    , Globe[AreaType].Width := Grab.X2 - Grab.X1, Globe[AreaType].Height := Grab.Y2 - Grab.Y1
    GuiControl, Globe:, Globe_%AreaType%_X1,% "X1:" Grab.X1
    GuiControl, Globe:, Globe_%AreaType%_Y1,% "Y1:" Grab.Y1
    GuiControl, Globe:, Globe_%AreaType%_X2,% "X2:" Grab.X2
    GuiControl, Globe:, Globe_%AreaType%_Y2,% "Y2:" Grab.Y2
    Gui, Show
  }
  Else if (Function = "Show")
  {
    Gui, Submit
    AreaType := Var[2]
    MouseTip(Globe[AreaType])
    Gui, Show
  }
  Else if (Function = "Color")
  {
    AreaType := Var[2]
    Element := Var[1]
    Split := {}
    Split.hex := Globe[AreaType].Color.Hex
    Gui, Submit, NoHide
    If (Element = "UpDown")
    {
      Globe[AreaType].Color.Variance := WR_UpDown_Color_%AreaType%
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
    }
    Else If (Element = "Edit")
    {
      CurPos := 1
      newhex := ""
      Loop, 3
      {
        RegExMatch(WR_Edit_Color_%AreaType%, "O)(x[0-9A-Fa-f]{6})", m,CurPos)
        CurPos := m.Pos(0) + m.Len(0) - 1
        If (m.1 != Split.hex && m.1 != "")
        {
          Split.new := m.1
          ; Break
        }
      }
      If (Split.new != "")
        m := "0" Split.new
      Else
        m := "0" Split.hex
      Globe[AreaType].Color.Hex := WR_Edit_Color_%AreaType% := Format("0x{1:06X}",m)
      GuiControl,Globe: , WR_Edit_Color_%AreaType%, % WR_Edit_Color_%AreaType%
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
      GuiControl,% "Globe: +c" Format("0x{1:06X}",WR_Edit_Color_%AreaType%), WR_Progress_Color_%AreaType%
    }
  }
  Else If (Function = "FillMetamorph")
  {
    Gui, Submit
    ValueType := Var[2]
    Element := Var[1]
    If (Element = "Btn")
    {
      If (ValueType = "Menu")
      {
        If (!FillMetamorphInitialized)
        {
          FillMetamorphInitialized := True
          Gui, FillMetamorph: New, -MinimizeBox -Resize
          Gui, FillMetamorph: Font, s12 c777777 bold
          Gui, FillMetamorph: Add, Text, xm+5 vWR_Btn_FillMetamorph_Area w170, % "X1: " FillMetamorph.X1 " Y1: " FillMetamorph.Y1 "`nX2: " FillMetamorph.X2 " Y2: " FillMetamorph.Y2
          Gui, FillMetamorph: Font,
          Gui, FillMetamorph: Add, Button, xm+5 gWR_Update vWR_Btn_FillMetamorph_Select w85, Select area
          Gui, FillMetamorph: Add, Button, x+5 yp gWR_Update vWR_Btn_FillMetamorph_Show wp, Show area
          Gui, FillMetamorph: Add, Button, xm+5 gWR_Update vWR_Save_JSON_FillMetamorph w170, Save to JSON
        }
      }
      Else If (ValueType = "Select")
      {
        If (Obj := LetUserSelectRect())
        {
          FillMetamorph := {"X1":Obj.X1
            ,"Y1":Obj.Y1
            ,"X2":Obj.X2
          ,"Y2":Obj.Y2}
          GuiControl,,WR_Btn_FillMetamorph_Area, % "X1: " FillMetamorph.X1 " Y1: " FillMetamorph.Y1 "`nX2: " FillMetamorph.X2 " Y2: " FillMetamorph.Y2
        }
      }
      Else If (ValueType = "Show")
      {
        MouseTip(FillMetamorph.X1,FillMetamorph.Y1,FillMetamorph.X2 - FillMetamorph.X1,FillMetamorph.Y2 - FillMetamorph.Y1)
      }
      Gui, FillMetamorph: Show
    }
  }
  Else If (Function = "hkStash")
  {
    Static hkStashBuilt := False
    If !(hkStashBuilt)
    {
      hkStashBuilt := True
      Gui, hkStash: New, +AlwaysOnTop -MinimizeBox -Resize
      ;Save Setting
      Gui, hkStash: Add, Button, default gupdateEverything x295 y320 w150 h23, Save Configuration
      Gui, hkStash: Add, Button, gLaunchSite x+5 h23, Website

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section xm+5 ym+50 w150 h80 center ,Binding Modifiers
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, xs+5 ys+20 w140 h23 vstashPrefix1, %stashPrefix1%
      Gui, hkStash: Add, Edit, y+5 w140 h23 vstashPrefix2, %stashPrefix2%

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section x+25 ym w100 h275 ,Keys
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, ys+20 xs+4 w90 h23 vstashSuffix1, %stashSuffix1%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix2, %stashSuffix2%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix3, %stashSuffix3%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix4, %stashSuffix4%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix5, %stashSuffix5%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix6, %stashSuffix6%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix7, %stashSuffix7%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix8, %stashSuffix8%
      Gui, hkStash: Add, Edit, y+5 w90 h23 vstashSuffix9, %stashSuffix9%

      Gui, hkStash: Font,s9 cBlack Bold Underline, Arial
      Gui, hkStash: Add,GroupBox,Section x+4 ys w50 h275 ,Tab
      Gui, hkStash: Font,
      Gui, hkStash: Font,s9,Arial
      Gui, hkStash: Add, Edit, Number xs+4 ys+20 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab1 , %stashSuffixTab1%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab2 , %stashSuffixTab2%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab3 , %stashSuffixTab3%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab4 , %stashSuffixTab4%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab5 , %stashSuffixTab5%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab6 , %stashSuffixTab6%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab7 , %stashSuffixTab7%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab8 , %stashSuffixTab8%
      Gui, hkStash: Add, Edit, Number y+5 w40
      Gui, hkStash: Add, UpDown, Range1-64 x+0 hp vstashSuffixTab9 , %stashSuffixTab9%
    }

    Gui, hkStash: Show

  }
  Else If (Function = "JSON")
  {
    ValueType := Var[2]
    Element := Var[1]
    If (Element = "Save")
    {
      Gui, Submit
      JSONtext := JSON.Dump(%ValueType%,,2)
      If FileExist(A_ScriptDir "\save\" ValueType ".json")
        FileDelete, %A_ScriptDir%\save\%ValueType%.json
      FileAppend, %JSONtext%, %A_ScriptDir%\save\%ValueType%.json
      Gui, Show
    }
    Else if (Element = "Load")
    {
      If FileExist(A_ScriptDir "\save\" ValueType ".json")
      {
        FileRead, JSONtext, %A_ScriptDir%\save\%ValueType%.json
        %ValueType% := JSON.Load(JSONtext)
      }
      Else
      {
        Notify("Error loading " ValueType " file","",3)
        Log("Error","issue with loading " ValueType " file")
      }
    }
  }
  Return

  WR_Update:
    If (A_GuiControl ~= "WR_\w{1,}_")
    {
      BtnStr := StrSplit(StrSplit(A_GuiControl, "WR_", " ")[2], "_", " ",3)
      ; Naming convention: WR_GuiElementType_FunctionName_ExtraStuff_AfterFunctionName
      ; Function = FunctionName, Var[1] = GuiElementType, Var[2] = ExtraStuff_AfterFunctionName
      WR_Menu(BtnStr[2],BtnStr[1],BtnStr[3])
    } 
  Return

  ColorLabel_Life:
    Picker.SetColor(Globe.Life.Color.hex)
  Return
  ColorLabel_Mana:
    Picker.SetColor(Globe.Mana.Color.hex)
  Return
  ColorLabel_ES:
    Picker.SetColor(Globe.ES.Color.hex)
  Return
  ColorLabel_EB:
    Picker.SetColor(Globe.EB.Color.hex)
  Return

  FillMetamorphGuiClose:
  FillMetamorphGuiEscape:
    Gui, Submit
    Gui, Inventory: Show
  Return

  hkStashGuiClose:
  hkStashGuiEscape:
  InventoryGuiClose:
  InventoryGuiEscape:
  CraftingGuiClose:
  CraftingGuiEscape:
  StringsGuiClose:
  StringsGuiEscape:
  ChatGuiClose:
  ChatGuiEscape:
  ControllerGuiClose:
  ControllerGuiEscape:
  HotkeysGuiClose:
  HotkeysGuiEscape:
    Gui, Submit
    Gui, 1: show
    CheckGamestates:= True
    mainmenuGameLogicState(True)
  return

  GlobeGuiClose:
  GlobeGuiEscape:
    GlobeActive := False
    Gui, Submit
    Gui, 1: show
    CheckGamestates:= True
    mainmenuGameLogicState(True)
  return
}
