; WR_Menu - New menu handling method
WR_Menu(Function:="",Var*){
  Global CheckGamestates, Globe, Picker, GlobeActive
    , InventoryGui, CraftingGui, StringsGui, ChatGui, ControllerGui, GlobeGui, hkStashGui
  Static Built_Inventory, Built_Crafting, Built_Strings, Built_Chat, Built_Controller, Built_Hotkeys, Built_Globe, LeagueIndex, UpdateLeaguesBtn, OHB_EditorBtn, WR_Reset_Globe, DefaultWhisper, DefaultCommands, DefaultButtons, LocateType, oldx, oldy, TempC ,WR_Btn_Locate_PortalScroll, WR_Btn_Locate_WisdomScroll, WR_Btn_Locate_CurrentGem, WR_Btn_Locate_AlternateGem, WR_Btn_Locate_CurrentGem2, WR_Btn_Locate_AlternateGem2, WR_Btn_Locate_GrabCurrency, WR_Btn_IgnoreSlot, WR_UpDown_Color_Life, WR_UpDown_Color_ES, WR_UpDown_Color_Mana, WR_UpDown_Color_EB, WR_Edit_Color_Life, WR_Edit_Color_ES, WR_Edit_Color_Mana, WR_Edit_Color_EB, WR_Save_JSON_Globe, WR_Load_JSON_Globe, Obj
    , ChaosRecipeMaxHoldingUpDown, ChaosRecipeLimitUnIdUpDown, ChaosRecipeStashTabUpDown, ChaosRecipeStashTabWeaponUpDown, ChaosRecipeStashTabHelmetUpDown, ChaosRecipeStashTabArmourUpDown, ChaosRecipeStashTabGlovesUpDown, ChaosRecipeStashTabBootsUpDown, ChaosRecipeStashTabBeltUpDown, ChaosRecipeStashTabAmuletUpDown, ChaosRecipeStashTabRingUpDown

  Log("Verbose","Load menu: " Function,Var*)

  If (Function == "Inventory") {
    MainGui.Submit(0)
    CheckGamestates:= False
    If !Built_Inventory
    {
      Built_Inventory := 1
      InventoryGui := Gui("+AlwaysOnTop -MinimizeBox")
      InventoryGui.OnEvent("Close", WR_SubGui_Close)
      InventoryGui.OnEvent("Escape", WR_SubGui_Close)
      ;Save Setting
      InventoryGui.Add("Button", "default x295 y470 w150 h23", "Save Configuration").OnEvent("Click", updateEverything)
      InventoryGui.Add("Button", "x+5 h23", "Website").OnEvent("Click", LaunchSite)

      ;InventoryGui.Add("Tab2", "vInventoryGuiTabs x3 y3 w625 h505 -wrap", ["Options","Stash Tabs","Affinity","Chaos Recipe","Crafting Bases"])
      local inventoryTab := InventoryGui.Add("Tab2", "vInventoryGuiTabs x3 y3 w625 h505 -wrap", ["Options","Stash Tabs","Affinity","Chaos Recipe"])

      inventoryTab.UseTab(1)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w170 h330 xm ym+25", "Inventory Sort/CLF Options")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vYesIdentify Checked" YesIdentify " xs+5 ys+18", "Identify Items?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesStash Checked" YesStash " y+8", "Deposit at Stash?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesVendor Checked" YesVendor " y+8", "Sell at Vendor?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesDiv Checked" YesDiv " y+8", "Trade Divination?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSortFirst Checked" YesSortFirst " y+8", "Group Items before stashing?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesMapUnid Checked" YesMapUnid " y+8", "Leave Map Un-ID?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesInfluencedUnid Checked" YesInfluencedUnid " y+8", "Leave Influenced Un-ID?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSynthesisId Checked" YesSynthesisId " y+8", "Always ID Frac/Syth rares?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesCLFIgnoreImplicit Checked" YesCLFIgnoreImplicit " y+8", "Ignore Implicit in CLF?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesBatchVendorBauble Checked" YesBatchVendorBauble " y+8", "Batch Vendor Quality Flasks?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Checkbox", "vYesBatchVendorGCP Checked" YesBatchVendorGCP " y+8", "Batch Vendor Quality Gems?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Checkbox", "vYesSpecial5Link Checked" YesSpecial5Link " y+8", "Give 5 link Special Type?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Checkbox", "vYesOpenStackedDeck Checked" YesOpenStackedDeck " y+8", "Open Stacked Decks?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Checkbox", "vYesOpenVeiledScarab Checked" YesOpenVeiledScarab " y+8", "Open Veiled Scarab?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Checkbox", "vYesVendorDumpItems Checked" YesVendorDumpItems " y+8", "Vendor Dump Tab Items?").OnEvent("Click", SaveGeneral)
      InventoryGui.Add("Edit", "Number w40 y+8")
      InventoryGui.Add("UpDown", "Range0-5 vCLFStrictnessNumber x+0 yp hp").OnEvent("Change", SaveGeneral)
      InventoryGui.Add("Text", "x+5 yp+4", "CLF Strictness Level")

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w370 h100 xm+180 ym+25", "Scroll, Gem and Currency Locations")
      InventoryGui.SetFont()

      InventoryGui.Add("Text", "xs+93 ys+15", "X-Pos")
      InventoryGui.Add("Text", "x+12", "Y-Pos")

      InventoryGui.Add("Text", "xs+9 y+6", "Grab Currency:")
      InventoryGui.Add("Edit", "vGrabCurrencyX x+8 y+-15 w34 h17", GrabCurrencyX)
      InventoryGui.Add("Edit", "vGrabCurrencyY x+8 w34 h17", GrabCurrencyY)
      InventoryGui.Add("Button", "vWR_Btn_Locate_GrabCurrency xs+173 ys+31 h17", "Locate").OnEvent("Click", WR_Update)
      InventoryGui.Add("Button", "r2 x+16 ys+30", "Inventory Slot`n`rManagement").OnEvent("Click", RestockMenu)
      InventoryGui.Add("Checkbox", "vEnableRestock Checked" EnableRestock " xp y+8", "Enable Restock?").OnEvent("Click", SaveGeneral)

      InventoryGui.Add("Text", "xs+84 ys+25 h72 0x11")
      InventoryGui.Add("Text", "x+33 h72 0x11")
      InventoryGui.Add("Text", "x+33 h72 0x11")
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w180 h160 xs y+5", "Item Parse Settings")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vYesNinjaDatabase xs+5 ys+20 Checked" YesNinjaDatabase, "Update PoE.Ninja DB?")
      InventoryGui.Add("DropDownList", "vUpdateDatabaseInterval x+1 yp-4 w30 Choose" UpdateDatabaseInterval, "1|2|3|4|5|6|7")
      InventoryGui.Add("Checkbox", "vForceMatch6Link xs+5 y+8 Checked" ForceMatch6Link, "Match with the 6 Link price")
      InventoryGui.Add("Checkbox", "vForceMatchGem20 xs+5 y+8 Checked" ForceMatchGem20, "Match with gems below 20")

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w180 h145 Section xm+370 ys", "Automation")
      AutomationList := "Search Stash|Search Vendor"
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vYesEnableAutomation Checked" YesEnableAutomation " xs+5 ys+18", "Enable Automation ?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Text", "y+8", "First Automation Action")
      InventoryGui.Add("DropDownList", "vFirstAutomationSetting y+3 w100", AutomationList).OnEvent("Change", UpdateExtra)
      InventoryGui["FirstAutomationSetting"].Choose(FirstAutomationSetting)
      InventoryGui.Add("Button", "x+10 w20 h20", "?").OnEvent("Click", helpAutomation)
      InventoryGui.Add("Checkbox", "vYesEnableNextAutomation Checked" YesEnableNextAutomation " xs+5 y+8", "Enable Second Automation ?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesEnableAutoSellConfirmation Checked" YesEnableAutoSellConfirmation " y+8", "Enable Auto Confirm Vendor ?").OnEvent("Click", WarningAutomation)
      InventoryGui.Add("Checkbox", "vYesEnableAutoSellConfirmationSafe Checked" YesEnableAutoSellConfirmationSafe " y+8", "Enable Safe Auto Confirm?").OnEvent("Click", UpdateExtra)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")

      inventoryTab.UseTab(2)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("Text", "Section xm+5 ym+25", "Stash Tab Management")
      InventoryGui.SetFont()

      ; Veiled

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Veiled")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabVeiled x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesVeiled Checked" StashTabYesVeiled " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      ; Cluster

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Cluster Jewel")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabClusterJewel x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesClusterJewel Checked" StashTabYesClusterJewel " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      ; Heist Gear

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Heist Gear")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabHeistGear x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesHeistGear Checked" StashTabYesHeistGear " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      ; Misc Map Items

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Misc Map Items")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabMiscMapItems x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesMiscMapItems Checked" StashTabYesMiscMapItems " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      ; Second column Gui - Links/Bricked Maps/Influenced/Runes/Tattoos

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w110 h50 x+15 ys+18", "5/6 linked")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabLinked x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesLinked Checked" StashTabYesLinked " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Bricked Maps")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabBrickedMaps x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesBrickedMaps Checked" StashTabYesBrickedMaps " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Influenced Item")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabInfluencedItem x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesInfluencedItem Checked" StashTabYesInfluencedItem " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Runes")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabRunes x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesRunes Checked" StashTabYesRunes " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Tattoos")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabTattoos x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesTattoos Checked" StashTabYesTattoos " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      ; Third column Gui - Rare itens

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w110 h50 x+15 ys", "Crafting")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabCrafting x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesCrafting Checked" StashTabYesCrafting " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Dump")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabDump x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesDump Checked" StashTabYesDump " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w110 h50 xs yp+20", "Ninja Priced")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabNinjaPrice x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesNinjaPrice Checked" StashTabYesNinjaPrice " x+5 yp+4", "Enable").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w185 h60 Section x+15 ys", "Dump Tab")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vStashDumpInTrial Checked" StashDumpInTrial " xs+5 ys+18", "Enable Dump in Trial").OnEvent("Click", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashDumpSkipJC Checked" StashDumpSkipJC " xs+5 y+5", "Skip Jeweller/Chroma Items").OnEvent("Click", SaveStashTabs)

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w185 h65 Section xs y+10", "Ninja Priced Tab")
      InventoryGui.SetFont()
      InventoryGui.Add("Text", "center xs+5 ys+18", "Minimum Value to Stash")
      InventoryGui.Add("Edit", "x+5 yp-3 w40")
      InventoryGui.Add("UpDown", "Range1-100 vStashTabYesNinjaPrice_Price x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Button", "xs+5 y+3 w175", "Included Item Types")

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w185 h135 Section xs y+10", "Map/Contract Options")
      InventoryGui.SetFont()
      InventoryGui.Add("DropDownList", "w40 vYesSkipMaps_eval xs+5 yp+18", ">=|<=").OnEvent("Change", UpdateExtra)
      InventoryGui["YesSkipMaps_eval"].Choose(YesSkipMaps_eval)
      InventoryGui.Add("DropDownList", "w40 vYesSkipMaps x+3 yp", "0|1|2|3|4|5|6|7|8|9|10|11|12").OnEvent("Change", UpdateExtra)
      InventoryGui["YesSkipMaps"].Choose(YesSkipMaps)
      InventoryGui.Add("Text", "yp+3 x+5", "Column to Skip")
      InventoryGui.Add("Checkbox", "vYesSkipMaps_normal Checked" YesSkipMaps_normal " xs+5 y+8", "Skip Normal?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSkipMaps_magic Checked" YesSkipMaps_magic " x+0 yp", "Skip Magic?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSkipMaps_rare Checked" YesSkipMaps_rare " xs+5 y+8", "Skip Rare?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSkipMaps_unique Checked" YesSkipMaps_unique " x+0 yp", "Skip Unique?").OnEvent("Click", UpdateExtra)
      InventoryGui.Add("Text", "xs+5 y+8", "Skip Maps => Tier")
      InventoryGui.Add("Edit", "Number w40 x+5 yp-3")
      InventoryGui.Add("UpDown", "center hp w40 Range1-16 vYesSkipMaps_tier").OnEvent("Change", UpdateExtra)
      InventoryGui.Add("Checkbox", "vYesSkipMaps_Prep Checked" YesSkipMaps_Prep " xs+5 y+8", "Skip Enhance Items in Map Area").OnEvent("Click", UpdateExtra)

      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w185 h50 Section xs y+15", "Influenced Item Options")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vYesIncludeFandSItem Checked" YesIncludeFandSItem " xs+5 ys+18", "Fracture and Synthesised `nas Influenced Items").OnEvent("Click", UpdateExtra)

      ; Affinity
      inventoryTab.UseTab(3)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("Text", "Section xm+5 ym+25", "Affinities Management")
      InventoryGui.SetFont()

      ; Blight
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs ys+18", "Blight")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vBlightEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabBlight x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesBlight x+5 yp-5 w90 h20", StashTabYesBlight).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vBlightEditText", "Disable Type")

      ; Delirium
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Delirium")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vDeliriumEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabDelirium x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesDelirium x+5 yp-5 w90 h20", StashTabYesDelirium).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vDeliriumEditText", "Disable Type")

      ; Divination Card
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Divination Card")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vDivinationEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabDivination x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesDivination x+5 yp-5 w90 h20", StashTabYesDivination).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vDivinationEditText", "Disable Type")

      ; Fragments
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Fragment")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vFragmentEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabFragment x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesFragment x+5 yp-5 w90 h20", StashTabYesFragment).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vFragmentEditText", "Disable Type")

      ; Ultimatum
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Ultimatum")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vUltimatumEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabUltimatum x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesUltimatum x+5 yp-5 w90 h20", StashTabYesUltimatum).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vUltimatumEditText", "Disable Type")

      ; Gem
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Gem")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vGemEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabGem x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesGem x+5 yp-5 w90 h20", StashTabYesGem).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vGemEditText", "Disable Type")

      ; Currency
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w145 h50 x+15 ys+18", "Currency")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 vCurrencyEdit xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabCurrency yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesCurrency x+5 yp-5 w90 h20", StashTabYesCurrency).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vCurrencyEditText", "Disable Type")

      ; Delve
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Delve")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vDelveEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabDelve x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesDelve x+5 yp-5 w90 h20", StashTabYesDelve).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vDelveEditText", "Disable Type")

      ; Essence
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Essence")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vEssenceEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabEssence x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesEssence x+5 yp-5 w90 h20", StashTabYesEssence).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vEssenceEditText", "Disable Type")

      ; Map
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Map")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vMapEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabMap x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesMap x+5 yp-5 w90 h20", StashTabYesMap).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vMapEditText", "Disable Type")

      ; Unique
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Unique")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vUniqueEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabUnique x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesUnique x+5 yp-5 w90 h20", StashTabYesUnique).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vUniqueEditText", "Disable Type")

      ; Flask
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w145 h50 xs yp+20", "Flask")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number vFlaskEdit w40 xp+6 yp+17")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabFlask x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Slider", "Range0-2 center noticks vStashTabYesFlask x+5 yp-5 w90 h20", StashTabYesFlask).OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "xp yp+22 w90 center vFlaskEditText", "Disable Type")

      ;Run GreyOut
      GreyOutAffinity()

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w200 h100 x+50 ys", "Intructions:")
      InventoryGui.SetFont()
      InventoryGui.Add("Text", "xs+10 yp+15 +Wrap w180", "- You can enable Currency Affinity")
      InventoryGui.Add("Text", "xs+10 yp+15 +Wrap w180", "and set the stash for other functions")
      InventoryGui.Add("Text", "xs+10 yp+15 +Wrap w180", "- CLF will take priority over Affinity")
      InventoryGui.Add("Text", "xs+10 yp+15 +Wrap w180", "- Use slider to choose logic type")
      InventoryGui.Add("Text", "xs+10 yp+15 +Wrap w180", "- Enable overflow Unique tabs")

      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w200 h210 xs yp+30", "Unique Affinity Logic")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vStashTabYesUniquePercentage Checked" StashTabYesUniquePercentage " xs+15 yp+25", "Only stash above % Affixes").OnEvent("Click", SaveStashTabs)
      InventoryGui.Add("Edit", "Number w40 xp yp+17")
      InventoryGui.Add("UpDown", "Range1-100 vStashTabUniquePercentage x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Text", "x+3 yp+3", "Minimum Affix Percentage")
      ; Unique Ring
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w180 h65 xs+10 yp+25", "Unique Ring")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+25")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabUniqueRing x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesUniqueRing Checked" StashTabYesUniqueRing " x+5 yp-2", "Stash Overflow").OnEvent("Click", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesUniqueRingAll Checked" StashTabYesUniqueRingAll " xp y+4", "Including Junk").OnEvent("Click", SaveStashTabs)

      ; Unique Dump
      InventoryGui.SetFont("Bold s8 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "w180 h65 xs+10 yp+25", "Unique Dump")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "Number w40 xp+6 yp+25")
      InventoryGui.Add("UpDown", "Range1-99 vStashTabUniqueDump x+0 yp hp").OnEvent("Change", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesUniqueDump Checked" StashTabYesUniqueDump " x+5 yp-2", "Stash Overflow").OnEvent("Click", SaveStashTabs)
      InventoryGui.Add("Checkbox", "vStashTabYesUniqueDumpAll Checked" StashTabYesUniqueDumpAll " xp y+4", "Including Junk").OnEvent("Click", SaveStashTabs)

      inventoryTab.UseTab(4)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w175 h245 xm+5 ym+25", "Chaos Recipe Options")
      InventoryGui.SetFont()
      InventoryGui.Add("Checkbox", "vChaosRecipeEnableFunction Checked" ChaosRecipeEnableFunction " xs+10 yp+20 Section", "Enable Chaos Recipe Logic").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Checkbox", "vChaosRecipeUnloadAll Checked" ChaosRecipeUnloadAll " xs yp+20", "Sell all sets back to back").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Checkbox", "vChaosRecipeSkipJC Checked" ChaosRecipeSkipJC " xs yp+20", "Skip Jeweller/Chroma Items").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Checkbox", "vChaosRecipeAllowDoubleJewellery Checked" ChaosRecipeAllowDoubleJewellery " xs yp+20", "Allow 2x Jewellery limit").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Checkbox", "vChaosRecipeAllowDoubleBelt Checked" ChaosRecipeAllowDoubleBelt " xs yp+20", "Allow 2x Belt limit").OnEvent("Click", SaveChaos)

      InventoryGui.Add("GroupBox", "w150 h50 xs y+5", "Max # of each part")
      InventoryGui.Add("Edit", "vChaosRecipeMaxHoldingIDUpDown xp+5 yp+20 w40 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range0-72 vChaosRecipeMaxHoldingID").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "ID")
      InventoryGui.Add("Edit", "vChaosRecipeMaxHoldingUNIDUpDown x+5 yp-3 w40 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range0-72 vChaosRecipeMaxHoldingUNID").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "UNID")
      InventoryGui.Add("Checkbox", "vChaosRecipeSmallWeapons Checked" ChaosRecipeSmallWeapons " xs yp+32", "Limit Weapons 1x3/2x2").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Checkbox", "vChaosRecipeEnableUnId Checked" ChaosRecipeEnableUnId " xs yp+22", "Leave Recipe Rare Un-Id").OnEvent("Click", SaveChaos)
      InventoryGui.Add("Edit", "vChaosRecipeLimitUnIdUpDown xs yp+20 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range70-100 vChaosRecipeLimitUnId").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Item lvl Resume Id")
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w175 h80 xs-10 y+25", "Chaos Recipe Type")
      InventoryGui.SetFont()
      InventoryGui.Add("Radio", "xp+15 yp+20 vChaosRecipeTypePure Checked" ChaosRecipeTypePure, "Pure Chaos 60-74 ilvl").OnEvent("Click", SaveChaosRadio)
      InventoryGui.Add("Radio", "xp yp+20 vChaosRecipeTypeHybrid Checked" ChaosRecipeTypeHybrid, "Hybrid Chaos 60-100 ilvl").OnEvent("Click", SaveChaosRadio)
      InventoryGui.Add("Radio", "xp yp+20 vChaosRecipeTypeRegal Checked" ChaosRecipeTypeRegal, "Pure Regal 75+ ilvl").OnEvent("Click", SaveChaosRadio)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w285 h90 xs+190 ym+25", "Chaos Recipe Stashing")
      InventoryGui.SetFont()
      InventoryGui.Add("Radio", "xs+15 yp+20 w250 center vChaosRecipeStashMethodDump Checked" ChaosRecipeStashMethodDump, "Use Dump Tab").OnEvent("Click", SaveChaosRadio)
      InventoryGui.Add("Radio", "xs+15 yp+20 w250 center vChaosRecipeStashMethodTab Checked" ChaosRecipeStashMethodTab, "Use Chaos Recipe Tab").OnEvent("Click", SaveChaosRadio)
      InventoryGui.Add("Radio", "xs+15 yp+20 w250 center vChaosRecipeStashMethodSort Checked" ChaosRecipeStashMethodSort, "Use Seperate Tab for Each Part").OnEvent("Click", SaveChaosRadio)
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w285 h50 xs y+25", "Chaos Recipe Tab")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "vChaosRecipeStashTabUpDown xs+15 yp+20 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTab").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for ALL PARTS")
      InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      InventoryGui.Add("GroupBox", "Section w285 h225 xs y+25", "Chaos Recipe Part Tabs")
      InventoryGui.SetFont()
      InventoryGui.Add("Edit", "vChaosRecipeStashTabWeaponUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabWeapon").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Weapons")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabArmourUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabArmour").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Armours")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabHelmetUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabHelmet").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Helmets")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabGlovesUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabGloves").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Gloves")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabBootsUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabBoots").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Boots")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabBeltUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabBelt").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Belts")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabAmuletUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabAmulet").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Amulets")

      InventoryGui.Add("Edit", "vChaosRecipeStashTabRingUpDown xs+15 yp+22 w50 center").OnEvent("Change", SaveChaos)
      InventoryGui.Add("UpDown", "Range1-99 vChaosRecipeStashTabRing").OnEvent("Change", SaveChaos)
      InventoryGui.Add("Text", "x+5 yp+3", "Stash Tab for Rings")

      /*
      ; Crafting Bases tab — re-enable by adding "Crafting Bases" back to the Tab2 list above
      ; and changing UseTab(5) to the correct index.

      ; inventoryTab.UseTab(5)
      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xm+5 ym+25", "Armour Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit STR Bases").OnEvent("Click", CraftingBaseSTRUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Armour Evasion Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit STR DEX Bases").OnEvent("Click", CraftingBaseSTRDEXUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Ring Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit Ring Bases").OnEvent("Click", CraftingBaseRINGUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs+160 ym+25", "Evasion Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit DEX Bases").OnEvent("Click", CraftingBaseDEXUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Armour ES Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit STR INT Bases").OnEvent("Click", CraftingBaseSTRINTUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Belt Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit Belt Bases").OnEvent("Click", CraftingBaseBELTUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs+160 ym+25", "ES Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit INT Bases").OnEvent("Click", CraftingBaseINTUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Evasion ES Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit DEX INT Bases").OnEvent("Click", CraftingBaseDEXINTUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Amulet Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit Amulet Bases").OnEvent("Click", CraftingBaseAMULETUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Weapon Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit Weapon Bases").OnEvent("Click", CraftingBaseWeaponUI)

      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w150 h60 section xs y+25", "Quiver Bases")
      ; InventoryGui.SetFont()
      ; InventoryGui.Add("Button", "xs+10 ys+20 w120", "Edit Quiver Bases").OnEvent("Click", CraftingBaseQuiverUI)

      ; Options
      ; InventoryGui.SetFont("Bold s9 cBlack", "Arial")
      ; InventoryGui.Add("GroupBox", "w310 h150 section xm+5 ym+250", "Options")
      ; InventoryGui.SetFont()
      ; Above ILvL
      ; InventoryGui.Add("Checkbox", "vYesStashBasesAboveIlvl Checked" YesStashBasesAboveIlvl " xs+8 ys+20", "Above Ilvl:").OnEvent("Click", UpdateExtra)
      ; InventoryGui.Add("Edit", "Number w40 x+2 yp-3 w40")
      ; InventoryGui.Add("UpDown", "Range1-100 hp vStashBasesAboveIlvl", StashBasesAboveIlvl).OnEvent("Change", UpdateExtra)
      ; Update from API
      ; InventoryGui.Add("Checkbox", "vYesCraftingBaseAutoUpdateOnStart Checked" YesCraftingBaseAutoUpdateOnStart " xs+8 y+8", "Update Bases ILvL/Quantity on start?").OnEvent("Click", UpdateExtra)
      ; InventoryGui.Add("Checkbox", "vYesCraftingBaseAutoUpdateOnZone Checked" YesCraftingBaseAutoUpdateOnZone " xs+8 y+8", "Update Bases ILvL/Quantity on zone change?").OnEvent("Click", UpdateExtra)
      ; Max Number
      ; InventoryGui.Add("Checkbox", "vYesCraftingBaseLimitBases Checked" YesCraftingBaseLimitBases " xs+8 y+8", "Max Number of Each Bases (At Max ILvL Found)").OnEvent("Click", UpdateExtra)
      ; InventoryGui.Add("Edit", "Number w40 x+2 yp-3 w40")
      ; InventoryGui.Add("UpDown", "Range1-10 hp vCraftingBaseLimitBasesNumber", CraftingBaseLimitBasesNumber).OnEvent("Change", UpdateExtra)
      */
    }
    InventoryGui.Title := "Inventory Settings"
    InventoryGui.Show("w600 h500")
  } Else If (Function == "Crafting") {
    MainGui.Submit(0)
    CheckGamestates:= False
    If !Built_Crafting
    {
      Built_Crafting := 1
      CraftingGui := Gui("+AlwaysOnTop -MinimizeBox")
      CraftingGui.OnEvent("Close", WR_SubGui_Close)
      CraftingGui.OnEvent("Escape", WR_SubGui_Close)
      ;Save Setting
      CraftingGui.Add("Button", "default x425 y510 w125 h23", "Save Configuration").OnEvent("Click", updateEverything)
      CraftingGui.Add("Button", "x+5 h23", "Website").OnEvent("Click", LaunchSite)

      local craftingTab := CraftingGui.Add("Tab2", "vCraftingGuiTabs x3 y3 w675 h555 -wrap", ["Map Crafting","Basic Crafting","Item Craft Beta"])

      craftingTab.UseTab(1)

      MapMethodList := "Disable|Transmutation+Augmentation|Alchemy|Alchemy+Vaal|Chisel+Alchemy|Chisel+Alchemy+Vaal|Binding|Chisel+Binding|Chisel+Binding+Vaal|Hybrid|Hybrid+Vaal|Binding+Vaal|Chisel+Hybrid|Chisel+Hybrid+Vaal|Chaos|Chisel+Chaos|Chisel+Chaos+Vaal"
      MapTierList := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16"
      MapSetValue := "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|100"
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("Text", "Section x12 ym+25", "Map Crafting")

      CraftingGui.Add("GroupBox", "Section w285 h65 xs", "Map Tier Range 1:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s7")
      CraftingGui.Add("Text", "xs+5 ys+20", "Initial")
      CraftingGui.Add("Text", "xs+55 ys+20", "Ending")
      CraftingGui.Add("Text", "xs+105 ys+20", "Method")
      CraftingGui.SetFont("s8")
      CraftingGui.Add("DropDownList", "xs+5 ys+35 w40 vStartMapTier1 Choose" StartMapTier1, MapTierList)
      CraftingGui.Add("DropDownList", "xs+55 ys+35 w40 vEndMapTier1 Choose" EndMapTier1, MapTierList)
      CraftingGui.Add("DropDownList", "xs+105 ys+35 w175 vCraftingMapMethod1 Choose" CraftingMapMethod1, MapMethodList)
      CraftingGui["CraftingMapMethod1"].Choose(CraftingMapMethod1)
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")

      CraftingGui.Add("GroupBox", "Section w285 h65 xs", "Map Tier Range 2:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s7")
      CraftingGui.Add("Text", "xs+5 ys+20", "Initial")
      CraftingGui.Add("Text", "xs+55 ys+20", "Ending")
      CraftingGui.Add("Text", "xs+105 ys+20", "Method")
      CraftingGui.SetFont("s8")
      CraftingGui.Add("DropDownList", "xs+5 ys+35 w40 vStartMapTier2 Choose" StartMapTier2, MapTierList)
      CraftingGui.Add("DropDownList", "xs+55 ys+35 w40 vEndMapTier2 Choose" EndMapTier2, MapTierList)
      CraftingGui.Add("DropDownList", "xs+105 ys+35 w175 vCraftingMapMethod2 Choose" CraftingMapMethod2, MapMethodList)
      CraftingGui["CraftingMapMethod2"].Choose(CraftingMapMethod2)
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")

      CraftingGui.Add("GroupBox", "Section w285 h65 xs", "Map Tier Range 3:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s7")
      CraftingGui.Add("Text", "xs+5 ys+20", "Initial")
      CraftingGui.Add("Text", "xs+55 ys+20", "Ending")
      CraftingGui.Add("Text", "xs+105 ys+20", "Method")
      CraftingGui.SetFont("s8")
      CraftingGui.Add("DropDownList", "xs+5 ys+35 w40 vStartMapTier3 Choose" StartMapTier3, MapTierList)
      CraftingGui.Add("DropDownList", "xs+55 ys+35 w40 vEndMapTier3 Choose" EndMapTier3, MapTierList)
      CraftingGui.Add("DropDownList", "xs+105 ys+35 w175 vCraftingMapMethod3 Choose" CraftingMapMethod3, MapMethodList)
      CraftingGui["CraftingMapMethod3"].Choose(CraftingMapMethod3)
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")

      ;MapMods GroupBox
      CraftingGui.Add("GroupBox", "Section w285 h85 xs", "Map Mods:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s7")
      CraftingGui.Add("Button", "xs+40 ys+20 w200", "Custom Map Mods").OnEvent("Click", CustomMapModsUI)
      CraftingGui.Add("Text", "xs+35 y+15 center w100", "Minimum Weight:")
      CraftingGui.Add("Edit", "x+5 yp-4 w50")
      CraftingGui.Add("UpDown", "Range-100-200 vMMapWeight")
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")

      /*
      ;HeistMods GroupBox
      ; CraftingGui.Add("GroupBox", "Section w285 h85 xs", "Heist Mods:")
      ; CraftingGui.SetFont()
      ; CraftingGui.SetFont("s7")
      ; CraftingGui.Add("Button", "xs+40 ys+20 w200", "Custom Heist Mods").OnEvent("Click", CustomHeistModsUI)
      ; CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      */
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section w200 h150 x320 y50", "Minimum Map Qualities:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s8")

      CraftingGui.Add("Edit", "number limit3 xs+15 yp+18 w50")
      CraftingGui.Add("UpDown", "Range1-130 vMMapItemQuantity x+0 yp hp")
      CraftingGui.Add("Text", "x+10 yp+3", "Item Quantity")

      CraftingGui.Add("Edit", "number limit2 xs+15 y+15 w50")
      CraftingGui.Add("UpDown", "Range1-54 vMMapItemRarity x+0 yp hp")
      CraftingGui.Add("Text", "x+10 yp+3", "Item Rarity")

      CraftingGui.Add("Edit", "number limit2 xs+15 y+15 w50")
      CraftingGui.Add("UpDown", "Range1-45 vMMapMonsterPackSize x+0 yp hp")
      CraftingGui.Add("Text", "x+10 yp+3", "Monster Pack Size")

      CraftingGui.Add("Checkbox", "vEnableMQQForMagicMap xs+15 y+15 Checked" EnableMQQForMagicMap, "Enable on Magic Maps")
      CraftingGui.Add("Checkbox", "vMMQorWeight xs+15 y+5 Checked" MMQorWeight, "Match MMQ or Weight")

      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section w290 h90 x320 y210", "Other Settings:")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s8")
      CraftingGui.Add("Checkbox", "vHeistAlcNGo xs+10 ys+20 Checked" HeistAlcNGo, "Alchemy Contract and Blueprint?")
      CraftingGui.Add("Checkbox", "vMoveMapsToArea xs+10 ys+40 Checked" MoveMapsToArea, "Move Crafted Maps and Enhance Items to Map Area?")
      CraftingGui.Add("Checkbox", "vForceMaxChisel xs+10 ys+60 Checked" ForceMaxChisel, "Force Maps to 20 Quality?")
      CraftingGui.SetFont()

      craftingTab.UseTab(2)
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section Center xm+15 ym+25 w275 h100", "Chance")
      CraftingGui.SetFont()
      CraftingGui.Add("Radio", "xs+10 ys+25 vBasicCraftChanceMethod Checked" (BasicCraftChanceMethod=1?1:0), "Cursor").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftChanceMethod=2?1:0), "Currency Stash").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftChanceMethod=3?1:0), "Bulk Inventory").OnEvent("Click", BasicCraftRadio)
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("Checkbox", "vBasicCraftChanceScour xs+30 y+20 Checked" BasicCraftChanceScour, "Scour and retry").OnEvent("Click", SaveBasicCraft)
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section Center xs ys+115 w275 h100", "Color")
      CraftingGui.SetFont()
      CraftingGui.Add("Radio", "xs+10 ys+25 vBasicCraftColorMethod Checked" (BasicCraftColorMethod=1?1:0), "Cursor").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftColorMethod=2?1:0), "Currency Stash").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftColorMethod=3?1:0), "Bulk Inventory").OnEvent("Click", BasicCraftRadio)
      CraftingGui.SetFont("Bold s12 cRed", "Arial")
      CraftingGui.Add("Text", "xs+25 y+20")
      CraftingGui.Add("UpDown", "Range0-6 vBasicCraftR").OnEvent("Change", SaveBasicCraft)
      CraftingGui.Add("Text", "x+5 yp", "R")
      CraftingGui.SetFont("Bold s12 cGreen", "Arial")
      CraftingGui.Add("Text", "x+25 yp")
      CraftingGui.Add("UpDown", "Range0-6 vBasicCraftG").OnEvent("Change", SaveBasicCraft)
      CraftingGui.Add("Text", "x+5 yp", "G")
      CraftingGui.SetFont("Bold s12 cBlue", "Arial")
      CraftingGui.Add("Text", "x+25 yp")
      CraftingGui.Add("UpDown", "Range0-6 vBasicCraftB").OnEvent("Change", SaveBasicCraft)
      CraftingGui.Add("Text", "x+5 yp", "B")
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section Center xm+295 ym+25 w275 h100", "Link")
      CraftingGui.SetFont()
      CraftingGui.Add("Radio", "xs+10 ys+25 vBasicCraftLinkMethod Checked" (BasicCraftLinkMethod=1?1:0), "Cursor").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftLinkMethod=2?1:0), "Currency Stash").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftLinkMethod=3?1:0), "Bulk Inventory").OnEvent("Click", BasicCraftRadio)
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("Text", "xs+25 y+20")
      CraftingGui.Add("UpDown", "Range0-6 vBasicCraftDesiredLinks").OnEvent("Change", SaveBasicCraft)
      CraftingGui.Add("Text", "x+5 yp", "Desired Links")
      CraftingGui.Add("CheckBox", "x+10 yp vBasicCraftLinkAuto Checked" BasicCraftLinkAuto, "Auto").OnEvent("Click", SaveBasicCraft)
      CraftingGui.SetFont()
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section Center xs ys+115 w275 h100", "Socket")
      CraftingGui.SetFont()
      CraftingGui.Add("Radio", "xs+10 ys+25 vBasicCraftSocketMethod Checked" (BasicCraftSocketMethod=1?1:0), "Cursor").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftSocketMethod=2?1:0), "Currency Stash").OnEvent("Click", BasicCraftRadio)
      CraftingGui.Add("Radio", "disabled x+10 yp Checked" (BasicCraftSocketMethod=3?1:0), "Bulk Inventory").OnEvent("Click", BasicCraftRadio)
      CraftingGui.SetFont("Bold s12 cBlack", "Arial")
      CraftingGui.Add("Text", "xs+25 y+20")
      CraftingGui.Add("UpDown", "Range0-6 vBasicCraftDesiredSockets").OnEvent("Change", SaveBasicCraft)
      CraftingGui.Add("Text", "x+5 yp", "Desired Sockets")
      CraftingGui.Add("CheckBox", "x+10 yp vBasicCraftSocketAuto Checked" BasicCraftSocketAuto, "Auto").OnEvent("Click", SaveBasicCraft)
      CraftingGui.SetFont()

      ;Item Crafting Beta
      craftingTab.UseTab(3)

      ; Item Type
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section w292 h80 xm ym+25", "Item Type")
      CraftingGui.SetFont()
      CraftingGui.Add("Text", "xs+5 yp+25 w60", "Category:")
      aux := ""
      ; Disable Sextants Craftings as they removed in Necropolis
      for a,b in POEData{
        if(a ~= "Maps|Contracts|Expedition Logbooks|Blueprints|Sextant"){
          Continue
        }
        aux .= a "|"
      }
      CraftingGui.Add("DropDownList", "vItemCraftingCategorySelector xs+70 yp-4 w210", aux).OnEvent("Change", ItemCraftingSubmit)
      CraftingGui["ItemCraftingCategorySelector"].Choose(ItemCraftingCategorySelector)
      CraftingGui.Add("Text", "xs+5 y+5 w60", "SubCategory:")
      CraftingGui.Add("DropDownList", "vItemCraftingSubCategorySelector Sort xs+70 yp-4 w210").OnEvent("Change", ItemCraftingSubmit)
      FillItemCraftingSubCategoryDropdown()
      CraftingGui["ItemCraftingSubCategorySelector"].Choose(ItemCraftingSubCategorySelector)

      ; Affix Rules
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "w292 h140 xs yp+40", "Affix Rules")
      CraftingGui.SetFont()
      CraftingGui.Add("Button", "xs+10 yp+25 w272", "Affix Selector").OnEvent("Click", ModsUI)
      CraftingGui.Add("Text", "xs+15 yp+30", "Match how many Prefix?")
      CraftingGui.Add("Edit", "Number w40 x+10 yp-4")
      CraftingGui.Add("UpDown", "Range0-3 vItemCraftingNumberPrefix x+0 yp hp").OnEvent("Change", ItemCraftingSubmit)
      CraftingGui.Add("Text", "xs+15 yp+30", "Match how many Suffix?")
      CraftingGui.Add("Edit", "Number w40 x+10 yp-4")
      CraftingGui.Add("UpDown", "Range0-3 vItemCraftingNumberSuffix x+0 yp hp").OnEvent("Change", ItemCraftingSubmit)
      CraftingGui.Add("Text", "xs+15 yp+30", "Match Combination of Affixes? (0 to Disable)")
      CraftingGui.Add("Edit", "Number w40 x+10 yp-4")
      CraftingGui.Add("UpDown", "Range0-3 vItemCraftingNumberCombination x+0 yp hp").OnEvent("Change", ItemCraftingSubmit)

      ; Crafting Method
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "w292 h60 xs yp+40", "Item Crafting Method")
      CraftingGui.SetFont()
      CraftingGui.Add("DropDownList", "vItemCraftingMethod xp+10 yp+25 w270", "Alteration Spam|Alteration and Aug Spam|Alteration and Aug and Regal Spam|Scouring and Alchemy Spam|Chaos Spam").OnEvent("Change", ItemCraftingSubmit)
      ; Select DDL Value Based on Last Value Saved
      CraftingGui["ItemCraftingMethod"].Choose(ItemCraftingMethod)

      ; Guide
      CraftingGui.SetFont("Bold s9 cBlack", "Arial")
      CraftingGui.Add("GroupBox", "Section w320 h400 xs+300 ym+25", "Instructions")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s9 cBlack", "Arial")
      CraftingGui.Add("Link", "xs+10 yp+20 w290", "This is an Experimental Feature!`nWe highly recommend using <a href=`"https://www.craftofexile.com/`">CraftOfExile</a> to Calculate the Currency to Match the Desired Mods.")
      CraftingGui.Add("Link", "xs+10 yp+55 w290", "Steps:`n1) Select the item 'Category' and 'SubCategory' you are going to craft.`n`n2) Press 'Affix Selector' and 'Tick' all the mods that you want to look for.")
      CraftingGui.SetFont("s10 cRed Bold", "Arial")
      CraftingGui.Add("Link", "xs+10 yp+95 w290", "This is Tier Sensitive so you must tick every tier you would be happy to keep`n")
      CraftingGui.SetFont()
      CraftingGui.SetFont("s9 cBlack", "Arial")
      CraftingGui.Add("Link", "xs+10 yp+50 w290", "3) Setup the 'Prefix / Suffix / Combination' rules it should match before stopping as a successful craft.`n`n4) Select the 'Crafting Method' that should be used.`n`n5) Use the Bound Key (Default is F11) with your cursor over the item and Stash open to start the process`n`nP.S.: You can Break the Loop by pressing Bound Key again when it's running.")
      CraftingGui.SetFont()
      CraftingGui.Show()
    }
    CraftingGui.Title := "Crafting Settings"
    CraftingGui.Show("w650 h550")
  } Else If (Function == "Strings") {
    MainGui.Submit(0)
    CheckGamestates:= False
    If !Built_Strings
    {
      Built_Strings := 1
      StringsGui := Gui("+AlwaysOnTop -MinimizeBox")
      StringsGui.OnEvent("Close", WR_SubGui_Close)
      StringsGui.OnEvent("Escape", WR_SubGui_Close)
      ;Save Setting
      ; StringsGui.Add("Button", "default x295 y470 w150 h23", "Save Configuration").OnEvent("Click", updateEverything)

      StringsGui.Add("Button", "x295 y470 h23", "Website").OnEvent("Click", LaunchSite)
      StringsGui.Add("Button", "x+5 h23", "FindText Gui (capture)").OnEvent("Click", ft_Start)
      StringsGui.SetFont("Bold cBlack")
      StringsGui.Add("GroupBox", "Section w625 h10 x3 y3", "String Samples from the FindText library - Match your resolution's height with the number in the string Label")
      local stringsTab := StringsGui.Add("Tab2", "Section vStringsGuiTabs x20 y30 w600 h480 -wrap", ["General","Vendor","Debuff"])
      StringsGui.SetFont()

      stringsTab.UseTab(1)
      StringsGui.Add("Button", "xs+1 ys+1 w1 h1")
      StringsGui.Opt("+Delimiter?")
      StringsGui.Add("Text", "xs+10 ys+25 Section", "OHB 1 pixel bar - Only Adjust if not 1080 Height")
      StringsGui.Add("ComboBox", "xp y+8 w220 vHealthBarStr", HealthBarStr '??"' Res1080_HealthBarStr '"?"' Res1440_HealthBarStr '"?"' Res1440_HealthBarStr_Alt '"?"' Res1050_HealthBarStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Button", "hp w50 x+10 yp vOHB_EditorBtn", "Make").OnEvent("Click", OHBUpdate)
      StringsGui.Add("Text", "x+10 x+10 ys", "Capture of the Skill up icon")
      StringsGui.Add("ComboBox", "y+8 w280 vSkillUpStr", SkillUpStr '??"' Res1080_SkillUpStr '"?"' Res1440_SkillUpStr '"?"' Res1050_SkillUpStr '"?"' Res768_SkillUpStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the words Sell Items")
      StringsGui.Add("ComboBox", "y+8 w280 vSellItemsStr", SellItemsStr '??"' Res1080_SellItemsStr '"?"' Res2160_SellItemsStr '"?"' Res1440_SellItemsStr '"?"' Res1050_SellItemsStr '"?"' Res768_SellItemsStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Stash")
      StringsGui.Add("ComboBox", "y+8 w280 vStashStr", StashStr '??"' Res1080_StashStr '"?"' Res2160_StashStr '"?"' Res1440_StashStr '"?"' Res1050_StashStr '"?"' Res768_StashStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the X button")
      StringsGui.Add("ComboBox", "y+8 w280 vXButtonStr", XButtonStr '??"' Res1080_XButtonStr '"?"' Res1440_XButtonStr '"?"' Res1050_XButtonStr '"?"' Res768_XButtonStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Opt("+Delimiter|")

      stringsTab.UseTab(2)
      StringsGui.Add("Button", "Section x20 y30 w1 h1")
      StringsGui.Opt("+Delimiter?")
      StringsGui.Add("Text", "xs+10 ys+25 Section", "Capture of the Hideout vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorStr", VendorStr '??"' Res1080_MasterStr '"?"' Res1080_NavaliStr '"?"' Res1080_HelenaStr '"?"' Res1080_ZanaStr '"?"' Res2160_NavaliStr '"?"' Res1440_ZanaStr '"?"' Res1440_NavaliStr '"?"' Res1050_MasterStr '"?"' Res1050_NavaliStr '"?"' Res1050_HelenaStr '"?"' Res1050_ZanaStr '"?"' Res768_NavaliStr '"?"' Res1440_JunStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Azurite Mines vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorMineStr", VendorMineStr '??"' Res1080_MasterStr '"?"' Res1050_MasterStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the Lioneye vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorLioneyeStr", VendorLioneyeStr '??"' Res1080_BestelStr '"?"' Res1050_BestelStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Forest vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorForestStr", VendorForestStr '??"' Res1080_GreustStr '"?"' Res1050_GreustStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the Sarn vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorSarnStr", VendorSarnStr '??"' Res1080_ClarissaStr '"?"' Res1050_ClarissaStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Highgate vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorHighgateStr", VendorHighgateStr '??"' Res1080_PetarusStr '"?"' Res1050_PetarusStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the Overseer vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorOverseerStr", VendorOverseerStr '??"' Res1080_LaniStr '"?"' Res1050_LaniStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Bridge vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorBridgeStr", VendorBridgeStr '??"' Res1080_HelenaStr '"?"' Res1050_HelenaStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the Docks vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorDocksStr", VendorDocksStr '??"' Res1080_LaniStr '"?"' Res1050_LaniStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Oriath vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorOriathStr", VendorOriathStr '??"' Res1080_LaniStr '"?"' Res1050_LaniStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Capture of the Harbour vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorHarbourStr", VendorHarbourStr '??"' Res1080_FenceStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "x+10 ys", "Capture of the Kingsmarch vendor nameplate")
      StringsGui.Add("ComboBox", "y+8 w280 vVendorKingsmarchStr", VendorKingsmarchStr '??"' Res1080_IslaStr '"').OnEvent("Change", UpdateStringEdit)
      StringsGui.Opt("+Delimiter|")

      stringsTab.UseTab(3)
      StringsGui.Add("Button", "Section x20 y30 w1 h1")
      StringsGui.Opt("+Delimiter?")

      StringsGui.Add("Text", "xs+10 ys+25 Section", "Curse - Elemental Weakness")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseEleWeakStr", debuffCurseEleWeakStr "??" WR.String.h1080.Debuff.EleW).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Curse - Vulnerability")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseVulnStr", debuffCurseVulnStr "??" WR.String.h1080.Debuff.Vuln).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "xs y+15 Section", "Curse - Enfeeble")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseEnfeebleStr", debuffCurseEnfeebleStr "??" WR.String.h1080.Debuff.Enfeeble).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Curse - Temporal Chains")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseTempChainStr", debuffCurseTempChainStr "??" WR.String.h1080.Debuff.TempChains).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "xs y+15 Section", "Curse - Condutivity")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseCondStr", debuffCurseCondStr "??" WR.String.h1080.Debuff.Conductivity).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Curse - Flammability")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseFlamStr", debuffCurseFlamStr "??" WR.String.h1080.Debuff.Flammability).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "xs y+15 Section", "Curse - Frostbite")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseFrostStr", debuffCurseFrostStr "??" WR.String.h1080.Debuff.Frostbite).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Curse - Warlord's Mark")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffCurseWarMarkStr", debuffCurseWarMarkStr "??" WR.String.h1080.Debuff.WMark).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "xs y+15 Section", "Shock")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffShockStr", debuffShockStr "??" WR.String.h1080.Debuff.Shock).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Bleed")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffBleedStr", debuffBleedStr "??" WR.String.h1080.Debuff.Bleed).OnEvent("Change", UpdateStringEdit)
      StringsGui.Add("Text", "xs y+15 Section", "Freeze")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffFreezeStr", debuffFreezeStr "??" WR.String.h1080.Debuff.Freeze).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "x+10 ys", "Ignite")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffIgniteStr", debuffIgniteStr "??" WR.String.h1080.Debuff.Ignite).OnEvent("Change", UpdateStringEdit)

      StringsGui.Add("Text", "xs y+15 Section", "Poison")
      StringsGui.Add("ComboBox", "y+8 w280 vdebuffPoisonStr", debuffPoisonStr "??" WR.String.h1080.Debuff.Poison).OnEvent("Change", UpdateStringEdit)

      StringsGui.Opt("+Delimiter|")
    }
    StringsGui.Title := "FindText Strings"
    StringsGui.Show("w640 h525")
  } Else If (Function == "Chat") {
    MainGui.Submit(0)
    CheckGamestates:= False
    If !Built_Chat
    {
      Built_Chat := 1
      ChatGui := Gui("+AlwaysOnTop -MinimizeBox")
      ChatGui.OnEvent("Close", WR_SubGui_Close)
      ChatGui.OnEvent("Escape", WR_SubGui_Close)

      ;Save Setting
      ChatGui.Add("Button", "default x295 y320 w150 h23", "Save Configuration").OnEvent("Click", updateEverything)
      ChatGui.Add("Button", "x+5 h23", "Website").OnEvent("Click", LaunchSite)

      local chatTab := ChatGui.Add("Tab", "w590 h350 xm+5 ym Section", ["Commands","Reply Whisper"])
      chatTab.UseTab(1)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section w60 h85", "Modifier")
      ChatGui.SetFont()
      ChatGui.SetFont("s9", "Arial")
      ChatGui.Add("Edit", "xs+4 ys+20 w50 h23 vc1Prefix1", c1Prefix1)
      ChatGui.Add("Edit", "y+8 w50 h23 vc1Prefix2", c1Prefix2)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section x+10 ys w60 h275", "Keys")
      ChatGui.SetFont()
      ChatGui.SetFont("s9", "Arial")
      ChatGui.Add("Edit", "ys+20 xs+4 w50 h23 vc1Suffix1", c1Suffix1)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix2", c1Suffix2)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix3", c1Suffix3)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix4", c1Suffix4)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix5", c1Suffix5)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix6", c1Suffix6)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix7", c1Suffix7)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix8", c1Suffix8)
      ChatGui.Add("Edit", "y+5 w50 h23 vc1Suffix9", c1Suffix9)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section x+10 ys w300 h275", "Commands")
      ChatGui.SetFont()
      ChatGui.SetFont("s9", "Arial")
      DefaultCommands := [ "/Hideout","/Menagerie","/Delve","/cls","/ladder","/reset_xp","/invite RecipientName","/kick RecipientName","@RecipientName Thanks for the trade!","@RecipientName Still Interested?","/kick CharacterName"]
      textList := ""
      For k, v in DefaultCommands
        textList .= (!textList ? "" : "|") v
      ChatGui.Add("ComboBox", "xs+4 ys+20 w290 vc1Suffix1Text", textList)
      ChatGui["c1Suffix1Text"].Text := c1Suffix1Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix2Text", textList)
      ChatGui["c1Suffix2Text"].Text := c1Suffix2Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix3Text", textList)
      ChatGui["c1Suffix3Text"].Text := c1Suffix3Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix4Text", textList)
      ChatGui["c1Suffix4Text"].Text := c1Suffix4Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix5Text", textList)
      ChatGui["c1Suffix5Text"].Text := c1Suffix5Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix6Text", textList)
      ChatGui["c1Suffix6Text"].Text := c1Suffix6Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix7Text", textList)
      ChatGui["c1Suffix7Text"].Text := c1Suffix7Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix8Text", textList)
      ChatGui["c1Suffix8Text"].Text := c1Suffix8Text
      ChatGui.Add("ComboBox", "y+5 w290 vc1Suffix9Text", textList)
      ChatGui["c1Suffix9Text"].Text := c1Suffix9Text

      chatTab.UseTab(2)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section w60 h85", "Modifier")
      ChatGui.SetFont()

      ChatGui.SetFont("s9", "Arial")
      ChatGui.Add("Edit", "xs+4 ys+20 w50 h23 vc2Prefix1", c2Prefix1)
      ChatGui.Add("Edit", "y+8 w50 h23 vc2Prefix2", c2Prefix2)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section x+10 ys w60 h275", "Keys")
      ChatGui.SetFont()
      ChatGui.SetFont("s9", "Arial")
      ChatGui.Add("Edit", "ys+20 xs+4 w50 h23 vc2Suffix1", c2Suffix1)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix2", c2Suffix2)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix3", c2Suffix3)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix4", c2Suffix4)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix5", c2Suffix5)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix6", c2Suffix6)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix7", c2Suffix7)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix8", c2Suffix8)
      ChatGui.Add("Edit", "y+5 w50 h23 vc2Suffix9", c2Suffix9)
      ChatGui.SetFont("s9 cBlack Bold Underline", "Arial")
      ChatGui.Add("GroupBox", "Section x+10 ys w300 h275", "Whisper Reply")
      ChatGui.SetFont()
      ChatGui.SetFont("s9", "Arial")
      DefaultWhisper := [ "/invite RecipientName","Sure, will invite in a sec.","In a map, will get to you in a minute.","Sorry, going to be a while.","No thank you.","Sold","/afk Sold to RecipientName"]
      textList := ""
      For k, v in DefaultWhisper
        textList .= (!textList ? "" : "|") v
      ChatGui.Add("ComboBox", "xs+4 ys+20 w290 vc2Suffix1Text", textList)
      ChatGui["c2Suffix1Text"].Text := c2Suffix1Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix2Text", textList)
      ChatGui["c2Suffix2Text"].Text := c2Suffix2Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix3Text", textList)
      ChatGui["c2Suffix3Text"].Text := c2Suffix3Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix4Text", textList)
      ChatGui["c2Suffix4Text"].Text := c2Suffix4Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix5Text", textList)
      ChatGui["c2Suffix5Text"].Text := c2Suffix5Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix6Text", textList)
      ChatGui["c2Suffix6Text"].Text := c2Suffix6Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix7Text", textList)
      ChatGui["c2Suffix7Text"].Text := c2Suffix7Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix8Text", textList)
      ChatGui["c2Suffix8Text"].Text := c2Suffix8Text
      ChatGui.Add("ComboBox", "y+5 w290 vc2Suffix9Text", textList)
      ChatGui["c2Suffix9Text"].Text := c2Suffix9Text
    }
    ChatGui.Title := "Chat Hotkeys"
    ChatGui.Show("w620 h370")
  } Else If (Function == "Controller") {
    MainGui.Submit(0)
    CheckGamestates:= False
    If !Built_Controller
    {
      Built_Controller := 1
      ControllerGui := Gui("+AlwaysOnTop -MinimizeBox")
      ControllerGui.OnEvent("Close", WR_SubGui_Close)
      ControllerGui.OnEvent("Escape", WR_SubGui_Close)
      DefaultButtons := [ "ItemSort","QuickPortal","PopFlasks","GemSwap","Logout","LButton","RButton","MButton","q","w","e","r","t"]
      textList := ""
      For k, v in DefaultButtons
        textList .= (!textList ? "" : "|") v

      ControllerGui.Add("Picture", "xm ym+20 w600 h400 +0x4000000", A_ScriptDir "\data\Controller.png")

      ControllerGui.Add("Checkbox", "Section xp y+-10 vYesMovementKeys Checked" YesMovementKeys, "Use Move Keys?")
      ControllerGui.Add("Checkbox", "vYesTriggerUtilityKey Checked" YesTriggerUtilityKey, "Use utility on Move?")
      ControllerGui.Add("DropDownList", "x+5 yp-5 w40 vTriggerUtilityKey Choose" TriggerUtilityKey, "1|2|3|4|5")

      ControllerGui.Add("GroupBox", "Section xm+80 ym+15 w80 h40", "L Bumper")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonLB", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonLB"].Text := hotkeyControllerButtonLB
      ControllerGui.Add("GroupBox", "xs+360 ys w80 h40", "R Bumper")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonRB", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonRB"].Text := hotkeyControllerButtonRB

      ControllerGui.Add("GroupBox", "Section xm+65 ym+100 w90 h80", "D-Pad")
      ControllerGui.Add("Text", "xs+15 ys+30", "Mouse`nMovement")

      ControllerGui.Add("GroupBox", "Section xm+165 ym+180 w80 h80", "Left Joystick")
      ControllerGui.Add("Checkbox", "xs+5 ys+30 Checked" YesTriggerUtilityJoystickKey " vYesTriggerUtilityJoystickKey", "Use util from`nMove Keys?")
      ControllerGui.Add("GroupBox", "xs ys+90 w80 h40", "L3")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonL3", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonL3"].Text := hotkeyControllerButtonL3

      ControllerGui.Add("GroupBox", "Section xs+190 ys w80 h80", "Right Joystick")
      ControllerGui.Add("Checkbox", "xp+5 y+-53 Checked" YesTriggerJoystickRightKey " vYesTriggerJoystickRightKey", "Use key?")
      ControllerGui.Add("ComboBox", "xp y+8 w70 vhotkeyControllerJoystickRight", "LButton|RButton|q|w|e|r|t")
      ControllerGui["hotkeyControllerJoystickRight"].Text := hotkeyControllerJoystickRight
      ControllerGui.Add("GroupBox", "xs ys+90 w80 h40", "R3")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonR3", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonR3"].Text := hotkeyControllerButtonR3

      ControllerGui.Add("GroupBox", "Section xm+140 ym+60 w80 h40", "Select")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonBACK", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonBACK"].Text := hotkeyControllerButtonBACK
      ControllerGui.Add("GroupBox", "xs+245 ys w80 h40", "Start")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w70 vhotkeyControllerButtonSTART", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonSTART"].Text := hotkeyControllerButtonSTART

      ControllerGui.Add("GroupBox", "Section xm+65 ym+280 w40 h40", "Up")
      ControllerGui.Add("Edit", "xp+5 y+-23 w30 h19 vhotkeyUp", hotkeyUp)
      ControllerGui.Add("GroupBox", "xs ys+80 w40 h40", "Down")
      ControllerGui.Add("Edit", "xp+5 y+-23 w30 h19 vhotkeyDown", hotkeyDown)
      ControllerGui.Add("GroupBox", "xs-40 ys+40 w40 h40", "Left")
      ControllerGui.Add("Edit", "xp+5 y+-23 w30 h19 vhotkeyLeft", hotkeyLeft)
      ControllerGui.Add("GroupBox", "xs+40 ys+40 w40 h40", "Right")
      ControllerGui.Add("Edit", "xp+5 y+-23 w30 h19 vhotkeyRight", hotkeyRight)

      ControllerGui.Add("GroupBox", "Section xm+465 ym+80 w70 h40", "Y")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w60 vhotkeyControllerButtonY", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonY"].Text := hotkeyControllerButtonY
      ControllerGui.Add("GroupBox", "xs ys+80 w70 h40", "A")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w60 vhotkeyControllerButtonA", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonA"].Text := hotkeyControllerButtonA
      ControllerGui.Add("GroupBox", "xs-40 ys+40 w70 h40", "X")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w60 vhotkeyControllerButtonX", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonX"].Text := hotkeyControllerButtonX
      ControllerGui.Add("GroupBox", "xs+40 ys+40 w70 h40", "B")
      ControllerGui.Add("ComboBox", "xp+5 y+-23 w60 vhotkeyControllerButtonB", textList "|" hotkeyLootScan "|" hotkeyCloseAllUI)
      ControllerGui["hotkeyControllerButtonB"].Text := hotkeyControllerButtonB

      ;Save Setting
      ControllerGui.Add("Button", "default x295 y470 w150 h23", "Save Configuration").OnEvent("Click", updateEverything)
      ControllerGui.Add("Button", "x+5 h23", "Website").OnEvent("Click", LaunchSite)
    }
    ControllerGui.Title := "Controller Settings"
    ControllerGui.Show("w620 h500")
  } Else if (Function == "Globe") {
    MainGui.Submit(1)
    CheckGamestates:= False
    Element := Var[1]
    If (!Built_Globe || Element == "Reset")
    {
      If (Element == "Reset")
      {
        GlobeGui.Destroy()
        Globe := adash.cloneDeep(Base.Globe)
      }
      Built_Globe := 1
      GlobeGui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox")
      Picker := ColorPicker("Globe","ColorPicker",460,30,80,200,120,0x000000)
      GlobeGui.Add("Button", "xm ym+8 w1 h1")
      GlobeGui.SetFont("Bold s9 c777777")
      GlobeGui.Add("GroupBox", "xm ym w205 h100 Section", "Life Scan Area")
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "vGlobe_Life_X1 xs+10 yp+20", "X1:" Globe.Life.X1)
      GlobeGui.Add("Text", "vGlobe_Life_Y1 x+5 yp", "Y1:" Globe.Life.Y1)
      GlobeGui.Add("Text", "vGlobe_Life_X2 xs+10 y+8", "X2:" Globe.Life.X2)
      GlobeGui.Add("Text", "vGlobe_Life_Y2 x+5 yp", "Y2:" Globe.Life.Y2)
      GlobeGui.Add("Text", "xs+10 y+8", "Color:")
      GlobeGui.SetFont()
      GlobeGui.Add("Edit", "vWR_Edit_Color_Life x+2 yp-2 hp+4 w60", Format("0x{1:06X}",Globe.Life.Color.Hex)).OnEvent("Change", WR_Update)
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "x+5 yp+2", "Variance:")
      GlobeGui.Add("Text", "x+2 yp w35", Globe.Life.Color.Variance)
      GlobeGui.Add("UpDown", "vWR_UpDown_Color_Life x+1 yp hp", Globe.Life.Color.Variance).OnEvent("Change", WR_Update)
      TempC := Format("0x{1:06X}",Globe.Life.Color.Hex)
      GlobeGui.Add("Text", "xs+10 y+6 hp w185").OnEvent("Click", ColorLabel_Life)
      GlobeGui.Add("Progress", "vWR_Progress_Color_Life xs+10 yp hp wp c" TempC " BackgroundBlack", 100)
      GlobeGui.Add("Button", "vWR_Btn_Area_Life h18 xs+115 ys+15", "Choose Area").OnEvent("Click", WR_Update)
      GlobeGui.Add("Button", "vWR_Btn_Show_Life wp hp xp y+5", "Show Area").OnEvent("Click", WR_Update)

      GlobeGui.SetFont("Bold s9 c777777")
      GlobeGui.Add("GroupBox", "xs+220 ys w205 h100 Section", "Mana Scan Area")
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "vGlobe_Mana_X1 xs+10 yp+20", "X1:" Globe.Mana.X1)
      GlobeGui.Add("Text", "vGlobe_Mana_Y1 x+5 yp", "Y1:" Globe.Mana.Y1)
      GlobeGui.Add("Text", "vGlobe_Mana_X2 xs+10 y+8", "X2:" Globe.Mana.X2)
      GlobeGui.Add("Text", "vGlobe_Mana_Y2 x+5 yp", "Y2:" Globe.Mana.Y2)
      GlobeGui.Add("Text", "xs+10 y+8", "Color:")
      GlobeGui.SetFont()
      GlobeGui.Add("Edit", "vWR_Edit_Color_Mana x+2 yp-2 hp+4 w60", Format("0x{1:06X}",Globe.Mana.Color.Hex)).OnEvent("Change", WR_Update)
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "x+5 yp+2", "Variance:")
      GlobeGui.Add("Text", "x+2 yp w35", Globe.Mana.Color.Variance)
      GlobeGui.Add("UpDown", "vWR_UpDown_Color_Mana x+1 yp hp", Globe.Mana.Color.Variance).OnEvent("Change", WR_Update)
      TempC := Format("0x{1:06X}",Globe.Mana.Color.Hex)
      GlobeGui.Add("Text", "xs+10 y+6 hp w185").OnEvent("Click", ColorLabel_Mana)
      GlobeGui.Add("Progress", "vWR_Progress_Color_Mana xs+10 yp hp wp c" TempC " BackgroundBlack", 100)
      GlobeGui.Add("Button", "vWR_Btn_Area_Mana h18 xs+115 ys+15", "Choose Area").OnEvent("Click", WR_Update)
      GlobeGui.Add("Button", "vWR_Btn_Show_Mana wp hp xp y+5", "Show Area").OnEvent("Click", WR_Update)

      GlobeGui.SetFont("Bold s9 c777777")
      GlobeGui.Add("GroupBox", "xm y+60 w205 h100 Section", "Energy Shield Scan Area")
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "vGlobe_ES_X1 xs+10 yp+20", "X1:" Globe.ES.X1)
      GlobeGui.Add("Text", "vGlobe_ES_Y1 x+5 yp", "Y1:" Globe.ES.Y1)
      GlobeGui.Add("Text", "vGlobe_ES_X2 xs+10 y+8", "X2:" Globe.ES.X2)
      GlobeGui.Add("Text", "vGlobe_ES_Y2 x+5 yp", "Y2:" Globe.ES.Y2)
      GlobeGui.Add("Text", "xs+10 y+8", "Color:")
      GlobeGui.SetFont()
      GlobeGui.Add("Edit", "vWR_Edit_Color_ES x+2 yp-2 hp+4 w60", Format("0x{1:06X}",Globe.ES.Color.Hex)).OnEvent("Change", WR_Update)
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "x+5 yp+2", "Variance:")
      GlobeGui.Add("Text", "x+2 yp w35", Globe.ES.Color.Variance)
      GlobeGui.Add("UpDown", "vWR_UpDown_Color_ES x+1 yp hp", Globe.ES.Color.Variance).OnEvent("Change", WR_Update)
      TempC := Format("0x{1:06X}",Globe.ES.Color.Hex)
      GlobeGui.Add("Text", "xs+10 y+6 hp w185").OnEvent("Click", ColorLabel_ES)
      GlobeGui.Add("Progress", "vWR_Progress_Color_ES xs+10 yp hp wp c" TempC " BackgroundBlack", 100)
      GlobeGui.Add("Button", "vWR_Btn_Area_ES h18 xs+115 ys+15", "Choose Area").OnEvent("Click", WR_Update)
      GlobeGui.Add("Button", "vWR_Btn_Show_ES wp hp xp y+5", "Show Area").OnEvent("Click", WR_Update)

      GlobeGui.SetFont("Bold s9 c777777")
      GlobeGui.Add("GroupBox", "xs+220 ys w205 h100 Section", "Eldritch Battery Scan Area")
      GlobeGui.SetFont("Bold")
      GlobeGui.Add("Text", "vGlobe_EB_X1 xs+10 yp+20", "X1:" Globe.EB.X1)
      GlobeGui.Add("Text", "vGlobe_EB_Y1 x+5 yp", "Y1:" Globe.EB.Y1)
      GlobeGui.Add("Text", "vGlobe_EB_X2 xs+10 y+8", "X2:" Globe.EB.X2)
      GlobeGui.Add("Text", "vGlobe_EB_Y2 x+5 yp", "Y2:" Globe.EB.Y2)
      GlobeGui.Add("Text", "xs+10 y+8", "Color:")
      GlobeGui.SetFont()
      GlobeGui.Add("Edit", "vWR_Edit_Color_EB x+2 yp-2 hp+4 w60", Format("0x{1:06X}",Globe.EB.Color.Hex)).OnEvent("Change", WR_Update)
      GlobeGui.SetFont("Bold c777777")
      GlobeGui.Add("Text", "x+5 yp+2", "Variance:")
      GlobeGui.Add("Text", "x+2 yp w35", Globe.EB.Color.Variance)
      GlobeGui.Add("UpDown", "vWR_UpDown_Color_EB x+1 yp hp", Globe.EB.Color.Variance).OnEvent("Change", WR_Update)
      TempC := Format("0x{1:06X}",Globe.EB.Color.Hex)
      GlobeGui.Add("Text", "xs+10 y+6 hp w185").OnEvent("Click", ColorLabel_EB)
      GlobeGui.Add("Progress", "vWR_Progress_Color_EB xs+10 yp hp wp c" TempC " BackgroundBlack", 100)
      GlobeGui.Add("Button", "vWR_Btn_Area_EB h18 xs+115 ys+15", "Choose Area").OnEvent("Click", WR_Update)
      GlobeGui.Add("Button", "vWR_Btn_Show_EB wp hp xp y+5", "Show Area").OnEvent("Click", WR_Update)

      GlobeGui.Add("Button", "vWR_Save_JSON_Globe ys+110 xm+25", "Save Values to JSON file").OnEvent("Click", WR_Update)
      GlobeGui.Add("Button", "vWR_Reset_Globe ys+110 xm+240 wp", "Reset to Initial Values").OnEvent("Click", WR_Update)
      GlobeGui.SetFont("s25 Bold c777777")
      GlobeGui.Add("Text", "w220 Center vGlobe_Percent_Life xm y+15 c78211A", "Life " Player.Percent.Life "%")
      GlobeGui.Add("Text", "w220 Center vGlobe_Percent_ES x+0 yp c51DEFF", "ES " Player.Percent.ES "%")
      GlobeGui.Add("Text", "w220 Center vGlobe_Percent_Mana x+0 yp c1460A6", "Mana " Player.Percent.Mana "%")
      GlobeGui.OnEvent("Close", WR_GlobeGui_Close)
      GlobeGui.OnEvent("Escape", WR_GlobeGui_Close)
    }
    GlobeActive := True
    GlobeGui.Title := "Globe Settings"
    GlobeGui.Show("Center AutoSize")
  } Else If (Function == "Locate") {
    LocateType := Var[2]
    InventoryGui.Hide()
    Loop
    {
      MouseGetPos(&x, &y)
      If (x != oldx || y != oldy)
        ToolTip("-- Locate " LocateType " --`n@ " x "," y "`nPress Ctrl to set")
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    ToolTip()
    ; TODO: dynamic var assign %LocateType%X/:Y not possible in v2 - use object property
    InventoryGui[LocateType "X"].Text := x
    InventoryGui[LocateType "Y"].Text := y
    MsgBox(x "," y " was captured as the new location for " LocateType)
    InventoryGui.Show()
  } Else If (Function == "Locate2") {
    MsgBoxVals(Var,2)
    ; LocateType := Var[2]
    ending := StrSplit(SubStr(Var[2],-1))
    slot := ending[1], position := ending[2]
    InventoryGui.Hide()
    Loop
    {
      MouseGetPos(&x, &y)
      If (x != oldx || y != oldy)
        ToolTip("-- Locate Swap " slot " " position " --`n@ " x "," y "`nPress Ctrl to set")
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    ToolTip()
    ; TODO: dynamic var assign swap%slot%X%position% not possible in v2 - needs Map refactor
    MainGui["swap" slot "X" position].Text := x
    MainGui["swap" slot "Y" position].Text := y
    MsgBox(x "," y " was captured as the new location for Swap " slot " " position)
    InventoryGui.Show()
  } Else If (Function == "Locate3") {
    LocateType := Var[2]
    CraftingGui.Hide()
    Loop
    {
      MouseGetPos(&x, &y)
      If (x != oldx || y != oldy)
        ToolTip("-- Locate " LocateType " --`n@ " x "," y "`nPress Ctrl to set")
      oldx := x, oldy := y
    } Until GetKeyState("Ctrl")
    ToolTip()
    ; TODO: dynamic var assign %LocateType%X/:Y not possible in v2 - use object property
    CraftingGui[LocateType "X"].Text := x
    CraftingGui[LocateType "Y"].Text := y
    MsgBox(x "," y " was captured as the new location for " LocateType)
    CraftingGui.Show()
  } Else if (Function == "Area") {
    GlobeGui.Submit(0)
    Grab := LetUserSelectRect()
    AreaType := Var[2]
    Globe[AreaType].X1 := Grab.X1, Globe[AreaType].Y1 := Grab.Y1, Globe[AreaType].X2 := Grab.X2, Globe[AreaType].Y2 := Grab.Y2
      , Globe[AreaType].Width := Grab.X2 - Grab.X1, Globe[AreaType].Height := Grab.Y2 - Grab.Y1
    GlobeGui["Globe_" AreaType "_X1"].Text := "X1:" Grab.X1
    GlobeGui["Globe_" AreaType "_Y1"].Text := "Y1:" Grab.Y1
    GlobeGui["Globe_" AreaType "_X2"].Text := "X2:" Grab.X2
    GlobeGui["Globe_" AreaType "_Y2"].Text := "Y2:" Grab.Y2
    GlobeGui.Show()
  } Else if (Function == "Show") {
    GlobeGui.Submit(0)
    AreaType := Var[2]
    MouseTip(Globe[AreaType])
    GlobeGui.Show()
  } Else if (Function == "Color") {
    AreaType := Var[2]
    Element := Var[1]
    Split := {}
    Split.hex := Globe[AreaType].Color.Hex
    GlobeGui.Submit(0)
    If (Element == "UpDown")
    {
      Globe[AreaType].Color.Variance := GlobeGui["WR_UpDown_Color_" AreaType].Value
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
    }
    Else If (Element == "Edit")
    {
      CurPos := 1
      newhex := ""
      editVal := GlobeGui["WR_Edit_Color_" AreaType].Text
      Loop 3
      {
        RegExMatch(editVal, "O)(x[0-9A-Fa-f]{6})", &m, CurPos)
        CurPos := m.Pos(0) + m.Len(0) - 1
        If (m[1] != Split.hex && m[1] != "")
        {
          Split.new := m[1]
          ; Break
        }
      }
      If (Split.new != "")
        m := "0" Split.new
      Else
        m := "0" Split.hex
      newHex := Format("0x{1:06X}", m)
      Globe[AreaType].Color.Hex := newHex
      GlobeGui["WR_Edit_Color_" AreaType].Text := newHex
      Globe[AreaType].Color.Str := Hex2FindText(Globe[AreaType].Color.hex,Globe[AreaType].Color.variance,0,AreaType,1,1)
      GlobeGui["WR_Progress_Color_" AreaType].Opt("+c" newHex)
    }
  } Else If (Function == "hkStash") {
    Static hkStashBuilt := False
    If !(hkStashBuilt)
    {
      hkStashBuilt := True
      hkStashGui := Gui("+AlwaysOnTop -MinimizeBox -Resize")
      hkStashGui.OnEvent("Close", WR_SubGui_Close)
      hkStashGui.OnEvent("Escape", WR_SubGui_Close)
      ;Save Setting
      hkStashGui.Add("Button", "default x295 y320 w150 h23", "Save Configuration").OnEvent("Click", updateEverything)
      hkStashGui.Add("Button", "x+5 h23", "Website").OnEvent("Click", LaunchSite)

      hkStashGui.SetFont("s9 cBlack Bold Underline", "Arial")
      hkStashGui.Add("GroupBox", "Section xm+5 ym+50 w150 h80 center", "Binding Modifiers")
      hkStashGui.SetFont()
      hkStashGui.SetFont("s9", "Arial")
      hkStashGui.Add("Edit", "xs+5 ys+20 w140 h23 vstashPrefix1", stashPrefix1)
      hkStashGui.Add("Edit", "y+5 w140 h23 vstashPrefix2", stashPrefix2)

      hkStashGui.SetFont("s9 cBlack Bold Underline", "Arial")
      hkStashGui.Add("GroupBox", "Section x+25 ym w100 h275", "Keys")
      hkStashGui.SetFont()
      hkStashGui.SetFont("s9", "Arial")
      hkStashGui.Add("Edit", "ys+20 xs+4 w90 h23 vstashSuffix1", stashSuffix1)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix2", stashSuffix2)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix3", stashSuffix3)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix4", stashSuffix4)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix5", stashSuffix5)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix6", stashSuffix6)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix7", stashSuffix7)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix8", stashSuffix8)
      hkStashGui.Add("Edit", "y+5 w90 h23 vstashSuffix9", stashSuffix9)

      hkStashGui.SetFont("s9 cBlack Bold Underline", "Arial")
      hkStashGui.Add("GroupBox", "Section x+4 ys w50 h275", "Tab")
      hkStashGui.SetFont()
      hkStashGui.SetFont("s9", "Arial")
      hkStashGui.Add("Edit", "Number xs+4 ys+20 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab1", stashSuffixTab1)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab2", stashSuffixTab2)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab3", stashSuffixTab3)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab4", stashSuffixTab4)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab5", stashSuffixTab5)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab6", stashSuffixTab6)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab7", stashSuffixTab7)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab8", stashSuffixTab8)
      hkStashGui.Add("Edit", "Number y+5 w40")
      hkStashGui.Add("UpDown", "Range1-64 x+0 hp vstashSuffixTab9", stashSuffixTab9)
    }

    hkStashGui.Show()

  } Else If (Function == "JSON") {
    ValueType := Var[2]
    Element := Var[1]
    If (Element == "Save") {
      MainGui.Submit(0)
      If (ValueType == "Globe")
        FileOpen(A_ScriptDir "\save\" ValueType ".json","w").Write(JSON.Dump(Globe,,2))
      Else
        Log("Error","JSON Save: unknown ValueType " ValueType)
      MainGui.Show()
    } Else if (Element == "Load") {
      If FileExist(A_ScriptDir "\save\" ValueType ".json") {
        If (ValueType == "Globe")
          Globe := JSON.LoadFile(A_ScriptDir "\save\" ValueType ".json")
        Else
          Log("Error","JSON Load: unknown ValueType " ValueType)
      } Else {
        Notify("Error loading " ValueType " file","",3)
        Log("Error","issue with loading " ValueType " file")
      }
    }
  }
  Return
}

; Naming convention: WR_GuiElementType_FunctionName_ExtraStuff_AfterFunctionName
; Function = FunctionName, Var[1] = GuiElementType, Var[2] = ExtraStuff_AfterFunctionName
WR_Update(GuiCtrl, *) {
  If (GuiCtrl.Name ~= "WR_\w{1,}_")
  {
    BtnStr := StrSplit(StrSplit(GuiCtrl.Name, "WR_", " ")[2], "_", " ", 3)
    WR_Menu(BtnStr[2], BtnStr[1], BtnStr[3])
  }
}

ColorLabel_Life(*) {
  Global Globe, Picker
  Picker.SetColor(Globe.Life.Color.hex)
}
ColorLabel_Mana(*) {
  Global Globe, Picker
  Picker.SetColor(Globe.Mana.Color.hex)
}
ColorLabel_ES(*) {
  Global Globe, Picker
  Picker.SetColor(Globe.ES.Color.hex)
}
ColorLabel_EB(*) {
  Global Globe, Picker
  Picker.SetColor(Globe.EB.Color.hex)
}

WR_SubGui_Close(GuiObj, *) {
  Global CheckGamestates, MainGui
  GuiObj.Submit(0)
  MainGui.Show()
  CheckGamestates := True
  mainmenuGameLogicState(True)
}

WR_GlobeGui_Close(GuiObj, *) {
  Global GlobeActive, CheckGamestates, MainGui
  GlobeActive := False
  GuiObj.Submit(0)
  MainGui.Show()
  CheckGamestates := True
  mainmenuGameLogicState(True)
}