ForceUpdate := Func("checkUpdate").Bind(True)

Menu, Tray, Tip,         WingmanReloaded Dev Ver%VersionNumber%
Menu, Tray, NoStandard
Menu, Tray, Add,         WingmanReloaded, optionsCommand
Menu, Tray, Default,       WingmanReloaded
Menu, Tray, Add
Menu, Tray, Add,         Project Site, LaunchSite
Menu, Tray, Add
Menu, Tray, Add,         Make a Donation, LaunchDonate
Menu, Tray, Add
Menu, Tray, Add,         Run Calibration Wizard, StartCalibrationWizard
Menu, Tray, Add
Menu, Tray, add,         Print Object, PromptForObject
Menu, Tray, add
Menu, Tray, Add,         Custom Loot Filter, LaunchLootFilter
Menu, Tray, Add
Menu, Tray, Add,         Refresh Chaos Data, RefreshChaosRecipe
Menu, Tray, Add
Menu, Tray, Add,         Open FindText interface, ft_Start
Menu, Tray, Add
Menu, Tray, add,         Window Spy, WINSPY
Menu, Tray, Add
Menu, Tray, add,         Force Update, %ForceUpdate%
Menu, Tray, add
Menu, Tray, add,         Reload This Script, RELOAD  
Menu, Tray, add
Menu, Tray, add,         Exit, QuitNow ; added exit script option
