/********************************************************************************************
 * Notify - Simplifies the creation and display of notification GUIs.
 * @author Martin Chartier (XMCQCX)
 * @date 2025/04/26
 * @version 1.10.1
 * @see {@link https://github.com/XMCQCX/NotifyClass-NotifyCreator GitHub}
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 AHK Forum}
 * @license MIT license
 * @credits
 * - JSON by thqby, HotKeyIt. {@link https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk GitHub}
 * - FrameShadow by Klark92. {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117 AHK Forum}
 * - DrawBorder by ericreeves. {@link https://gist.github.com/ericreeves/fd426cc0457a5a47058e1ad1a29d9bd6 GitHub}
 * - CalculatePopupWindowPosition by lexikos. {@link https://www.autohotkey.com/boards/viewtopic.php?t=103459 AHK Forum}
 * - PlayWavConcurrent by Faddix. {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=130425 AHK Forum}
 * - CreatePixel by TheDewd. {@link https://www.autohotkey.com/boards/viewtopic.php?t=7312 AHK Forum}
 * - Notify by gwarble. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991 AHK Forum}
 * - Notify by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2 the-automator.com}
 * - WiseGui by SKAN. {@link https://www.autohotkey.com/boards/viewtopic.php?t=94044 AHK Forum}
 * @features
 * - Customize various parameters such as text, font, color, image, sound, animation, and more.
 * - Choose from built-in themes or create your own custom themes with Notify Creator.
 * - Rounded or edged corners.
 * - Position at different locations on the screen.
 * - Call a function when clicking on it.
 * - GUI stacking and repositioning.
 * - Multi-Monitor support.
 * - Multi-Script support.
 * @methods
 * - Show(title, msg, image, sound, callback, options) - Builds and displays a notification GUI.
 * - Destroy(param, force) - Destroys GUIs.
 *   - param
 *     - Window handle (hwnd) - Destroys the GUI with the specified window handle.
 *     - tag - Destroys every GUI containing this tag across all scripts.
 *     - 'oldest' or no param - Destroys the oldest GUI.
 *     - 'latest' - Destroys the most recent GUI.
 *   - force - When true, overrides Destroy GUI block (DGB) setting and forces GUI destruction.
 * - DestroyAllOnMonitorAtPosition(monitorNumber, position, force) - Destroys all GUIs on a specific monitor at a given position.
 * - DestroyAllOnAllMonitorAtPosition(position, force) - Destroys all GUIs on all monitors at a specific position.
 * - DestroyAllOnMonitor(monitorNumber, force) - Destroys all GUIs on a specific monitor.
 * - DestroyAll(force) - Destroys all GUIs.
 * - Exist(tag) - Checks if a GUI with the specified tag exists and returns the unique ID (HWND) of the first matching GUI.
 * - SetDefaultTheme(theme) - Set a different theme as the default.
 * - Sound(sound) - Plays a sound.
 ********************************************************************************************/
Class Notify {

/********************************************************************************************
 * @method Show(title, msg, image, sound, callback, options)
 * @description Builds and displays a notification GUI.
 * @param title Title
 * @param msg Message
 * @param image
 * - File path of an image. Supported file types: `.ico, .dll, .exe, .cpl, .png, .jpeg, .jpg, .gif, .bmp, .tif`
 * - String: `'icon!'`, `'icon?'`, `'iconx'`, `'iconi'`
 * - Icon from dll. For example: `'C:\Windows\System32\imageres.dll|icon19'`
 * - Image Handle. For example: `'HICON:' hwnd`
 * - Filename of an image located in "Pictures\Notify".
 * @param sound
 * - File path of a WAV file.
 * - String: `'soundx'`, `'soundi'`
 * - Filename of a WAV file located in "C:\Windows\Media" or "Music\Sounds". For example: `'Ding'`, `'tada'`, `'Windows Error'` etc.
 * - Use Notify Creator to view and play all available notification sounds.
 * @param callback The function(s) to execute when clicking on the GUI, image, or background image.
 * - Accepts a single function or an array of functions.
 * - If a single function is provided, it will be used as the callback when clicking on the GUI.
 * - If an array is provided:
 *   - First item: Executed when clicking on the GUI.
 *   - Second item: Executed when clicking on the image.
 *   - Third item: Executed when clicking on the background image.
 * @param options For example: `'POS=TL DUR=6 IW=70 TF=Impact TS=42 TC=GREEN MC=blue BC=Silver STYLE=edge SHOW=Fade Hide=Fade@250'`
 * - The string is case-insensitive.
 * - The asterisk (*) indicates the default option.
 * - `THEME` - Built-in themes and user-created themes.
 *   - Use Notify Creator to view all themes and their visual appearance.
 * - `STYLE` - Notification Appearance
 *   - `Round` - Rounded corners*
 *   - `Edge` - Edged corners
 * - `POS` - Position
 *   - `TL` - Top left
 *   - `TC` - Top center
 *   - `TR` - Top right
 *   - `CTL` - Center left
 *   - `CT` - Center
 *   - `CTR` - Center right
 *   - `BL` - Bottom left
 *   - `BC` - Bottom center
 *   - `BR` - Bottom right*
 *   - `Mouse` - Near the cursor.
 * - `DUR` - Display duration (in seconds). Set to 0 to keep it on the screen until left-clicking on the GUI or programmatically destroying it. `*8`
 * - `MON` - Monitor to display the GUI. AutoHotkey monitor numbers may differ from those in Windows Display settings or NVIDIA Control Panel.
 *   - `Number` - A specific monitor number.
 *   - `Active` - The monitor on which the active window is displayed.
 *   - `Mouse` - The monitor on which the mouse is currently positioned.
 *   - `Primary`* - The primary monitor.
 * - `IW` - Image width - `*32`
 * - `IH` - Image height `*-1`
 *   - Image Dimensions (width and height)
 *     - To resize the image while preserving its aspect ratio, specify -1 for one dimension and a positive number for the other.
 *     - Specify 0 to retain the image's original width or height (DPI scaling does not apply).
 * - `BGIMG` - Background image. A valid image format. See the documentation for the image parameter.
 * - `BGIMGPOS` - Background image Position. Parameters for positioning and sizing the background image. For example: `ct Scale1.5`, `ctl w20 hStretch`, `tr w20 h-1 ofstx-10 ofsty10`
 *   - Positions
 *     - `TL` - Top left
 *     - `TC` - Top center
 *     - `TR` - Top right
 *     - `CTL` - Center left
 *     - `CT` - Center
 *     - `CTR` - Center right
 *     - `BL` - Bottom left
 *     - `BC` - Bottom center
 *     - `BR` - Bottom right
 *     - `X` - Custom horizontal position.
 *     - `Y` - Custom vertical position.
 *     - `OFSTX` - Horizontal pixel offset.
 *     - `OFSTY` - Vertical pixel offset.
 *   - Display Modes
 *     - `STRETCH`* - Stretches both the width and height of the image to fill the entire GUI.
 *     - `SCALE` - Resizes the image proportionally.
 *   - Image Dimensions (width and height)
 *     - `STRETCH` - Adjusts either the width or height of the image to match the GUI dimension.
 *     - To resize the image while preserving its aspect ratio, specify -1 for one dimension and a positive number for the other.
 *     - Specify 0 to retain the image's original width or height (DPI scaling does not apply).
 *     - Omit the W or H options to retain the image's original width or height (DPI scaling applies).
 * - `SHOW` and `HIDE` - Animation when showing and destroying the GUI. The duration, which is optional, can range from 1 to 2500 milliseconds. For example: `STYLE=EDGE SHOW=SlideNorth HIDE=SlideSouth@250`
 *   - The round style is not compatible with most animations. To use all available animations, choose the edge style. If animations aren’t specified, the default animations for the style and position will be set.
 *   - `None`
 *   - `Fade`
 *   - `Expand`
 *   - `SlideEast`
 *   - `SlideWest`
 *   - `SlideNorth`
 *   - `SlideSouth`
 *   - `SlideNorthEast`
 *   - `SlideNorthWest`
 *   - `SlideSouthEast`
 *   - `SlideSouthWest`
 *   - `RollEast`
 *   - `RollWest`
 *   - `RollNorth`
 *   - `RollSouth`
 *   - `RollNorthEast`
 *   - `RollNorthWest`
 *   - `RollSouthEast`
 *   - `RollSouthWest`
 * - `TF` - Title font `*Segoe UI`
 * - `TFO` - Title font options. `*Bold` For example: `tfo=underline italic strike`
 * - `TS` - Title size `*15`
 * - `TC` - Title color `*White`
 * - `TALI` - Title alignment
 *   - `Left`*
 *   - `Right`
 *   - `Center`
 * - `MF` - Message font `*Segoe UI`
 * - `MFO` - Message font options. For example: `mfo=underline italic strike`
 * - `MS` - Message size `*12`
 * - `MC` - Message color `*0xEAEAEA`
 * - `MALI` - Message alignment
 *   - `Left`*
 *   - `Right`
 *   - `Center`
 * - `BC` - Background color `*0x1F1F1F`
 * - `BDR` - Border. For example: `bdr=Aqua`,`bdr=Red,4`
 *   - The round style's maximum border width is limited to 1 pixel, while the edge style allows up to 10 pixels.
 *   - If the theme includes a border and the style is set to edge, you can specify only the border width like this: `bdr=,3`
 *   - `0` - No border
 *   - `1` - Border
 *   - `Default`
 *   - `Color`
 *   - `Color,border width` - Specify color and width, separated by a comma.
 * - `WSTC` - WinSetTransColor. Not compatible with the round style, fade animation. For example: `style=edge bdr=0 bc=black wstc=black` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransColor.htm WinSetTransColor}
 * - `WSTP` - WinSetTransparent. Not compatible with the round style, fade animation. For example: `style=edge wstp=120` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransparent.htm WinSetTransparent}
 * - `PAD` - Padding, margins, and spacing. Accepts comma-separated values or explicit key-value pairs. For examples: `pad=0,0,16,16,16,16,8,10`, `pad=,10`, `padx=10 pady=10`
 *   - `PadX` and `PadY` can range from 0 to 25. The others can range from 0 to 999.
 *   - `PadX` - Padding between the GUI's left or right edge and the screen's edge.
 *   - `PadY` - Padding between the GUI's top or bottom edge and the screen's edge or taskbar.
 *   - `gmT` - Top margin of the GUI.
 *   - `gmB` - Bottom margin of the GUI.
 *   - `gmL` - Left margin of the GUI.
 *   - `gmR` - Right margin of the GUI.
 *   - `SpX` - Horizontal spacing between the right side of the image and other controls.
 *   - `SpY` - Vertical spacing between the title, message, and progress bar.
 * - `MAXW` - Maximum width of the GUI (excluding image width and margins).
 * - `WIDTH` - Fixed width of the GUI (excluding the image width and margins).
 * - `MINH` - Minimum height of the GUI.
 * - `PROG` - Progress bar. For example: `prog=1`, `prog=h40 cGreen`, `prog=w400` {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Progress Progress Options}
 * - `TAG` - Marker to identify a GUI. The Destroy method accepts a handle or a tag, it destroys every GUI containing this tag across all scripts.
 * - `DGC` - Destroy GUI click. Allow or prevent the GUI from being destroyed when clicked.
 *   - `0` - Clicking on the GUI does not destroy it.
 *   - `1` - Clicking on the GUI destroys it.*
 * - `DG` - Destroy GUIs before showing the new GUI.
 *   - `0` - Do not destroy GUIs.*
 *   - `1` - Destroy all GUIs on the monitor option at the position option.
 *   - `2` - Destroy all GUIs on all monitors at the position option.
 *   - `3` - Destroy all GUIs on the monitor option.
 *   - `4` - Destroy all GUIs.
 *   - `5` - Destroy all GUIs containing the tag. For example: `dg=5 tag=myTAG`
 * - `DGB` - Destroy GUI block. Prevents the GUI from being destroyed unless the force parameter of the destroy methods is set to true.
 *           It does not prevent GUI destruction after the duration expires or when the GUI is clicked. In most cases, you’ll likely want to set
 *           both the Duration (DUR) and Destroy GUI Click (DGC) to 0. For example: `dgb=1 dur=0 dgc=0`
 *   - `0` - The GUI can be destroyed without setting the force parameter to true.
 *   - `1` - The GUI cannot be destroyed unless the force parameter is set to true.
 * - `DGA` - Destroy GUI animation. Enables or disables the hide animation when destroying the GUI using the destroy methods.
 *   - `0` - No animation.
 *   - `1` - Animation enabled.
 * - `OPT` - Sets various options and styles for the appearance and behavior of the window. `*+Owner -Caption +AlwaysOnTop +E0x08000000` {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt GUI Opt}
 * @returns Map object
********************************************************************************************/
    static Show(title:='', msg:='', image:='', sound:='', callback:='', options:='') => this._Show(title, msg, image, sound, callback, options)

    static __New()
    {
        this.mDefaults := this.MapCI().Set(
            'theme', 'Default',
            'mon', 'Primary',
            'pos', 'BR',
            'dur', 8,
            'style', 'Round',
            'ts', 15,
            'tc', 'White',
            'tf', 'Segoe UI',
            'tfo', 'norm Bold',
            'tali', 'Left',
            'ms', 12,
            'mc', '0xEAEAEA',
            'mf', 'Segoe UI',
            'mfo', 'norm',
            'mali', 'Left',
            'bc', '0x1F1F1F',
            'bdr', 'Default',
            'sound', 'None',
            'image', 'None',
            'iw', 32,
            'ih', -1,
            'bgImg', 'None',
            'bgImgPos', 'Stretch',
            'pad', ',,16,16,16,16,8,10',
            'width', '',
            'minH', '',
            'maxW', '',
            'prog', '',
            'tag', '',
            'dgc', 1,
            'dg', 0,
            'dgb', 0,
            'dga', 0,
            'wstc', '',
            'wstp', '',
            'opt', '+Owner -Caption +AlwaysOnTop +E0x08000000',
        )

        this.mThemesStrings := this.MapCI().Set(
            'Light', 'tc=Black mc=Black bc=White',
            'Dark', 'tc=White mc=0xEAEAEA bc=0x1F1F1F',
            'Matrix', 'tc=Lime mc=0x00FF7F bc=Black bdr=0x00FF7F tf=Consolas mf=Lucida Console',
            'Cyberpunk', 'tc=0xFF005F mc=Aqua bc=0x0D0D0D bdr=Aqua tf=Consolas mf=Lucida Console',
            'Cybernetic', 'tc=Aqua mc=0xFF005F bc=0x1A1A1A bdr=0xFF005F tf=Lucida Console mf=Consolas',
            'Synthwave', 'tc=Fuchsia mc=Aqua bc=0x1A0E2F bdr=Aqua tf=Consolas mf=Arial',
            'Dracula', 'tc=0xFF79C6 mc=0x8BE9FD bc=0x282A36 bdr=0x8BE9FD tf=Consolas mf=Arial',
            'Monokai', 'tc=0xF8F8F2 mc=0xA6E22E bc=0x272822 bdr=0xE8F7C8 tf=Lucida Console mf=Tahoma',
            'Solarized Dark', 'tc=0xD9A300 mc=0x9FADAE bc=0x002B36 bdr=0x9FADAE tf=Consolas mf=Calibri',
            'Atomic', 'tc=0xE49013 mc=0xDFCA9B bc=0x1F1F1F bdr=0xDFCA9B tf=Consolas mf=Lucida Console',
            'PCB', 'tc=0xCCAA00 mc=0x00CC00 bc=0x002200 bdr=0x00CC00 tf=Consolas mf=Arial',
            'Deep Sea', 'tc=0x00CED1 mc=0x5F9EA0 bc=0x002B36 bdr=0x4682B4 tf=Arial mf=Verdana',
            'Firewatch', 'tc=0xFF4500 mc=0xFF8C00 bc=0x2C1B18 bdr=0xFFA500 tf=Verdana mf=Georgia',
            'Nord', 'tc=0xD8DEE9 mc=0xECEFF4 bc=0x2E3440 bdr=0x88C0D0 tf=Calibri mf=Lucida Console',
            'Ivory', 'tc=0x333333 mc=0x666666 bc=0xFFFFF0 bdr=0xCCCCCC tf=Georgia mf=Tahoma',
            'Neon', 'tc=Yellow mc=Fuchsia bc=Black bdr=Fuchsia tf=Consolas mf=Lucida Console',
            'Frost', 'tc=Aqua mc=0xE0FFFF bc=0x002233 bdr=Aqua tf=Calibri mf=Arial',
            'Charcoal', 'tc=0xD3D3D3 mc=0xA9A9A9 bc=0x2F2F2F bdr=0xA9A9A9 tf=Tahoma mf=Consolas',
            'Zenburn', 'tc=0xDECEA3 mc=0xD3D3C4 bc=0x3F3F3F bdr=0x839496 tf=Consolas mf=Calibri',
            'Matcha', 'tc=0xD5D1B5 mc=0x87A9A2 bc=0x273136 bdr=0xD5D1B5',
            'Monaspace', 'tc=0x79C1FD mc=0xD1A7FE bc=0x0D1116 bdr=0xD1A7FE',
            'Milky Way', 'tc=0x9370DB mc=0xC0CAD7 bc=0x0D1B2A bdr=0x9370DB tf=Trebuchet MS mf=Calibri',
            'Reptilian', 'tc=Yellow mc=0xF0FFF0 bc=0x004D00 bdr=Yellow',
            'Aurora', 'tc=0x47F0AC mc=0xEAEAEA bc=0x0C1631 bdr=0x47F0AC',
            'Venom', 'tc=0xF9EA2C mc=0xFAF2A4 bc=0x317140 tf=Segoe UI mf=Segoe UI bdr=0x86EE99',
            'Forum', 'tc=0x3F5770 mc=0x272727 bc=0xDFDFDF bdr=0x686868',
            'Cappuccino', 'tc=0x6F4E37 mc=0x886434 bc=0xFFF8DC bdr=0x886434 tf=Trebuchet MS mf=Times New Roman',
            'Earthy', 'tc=0xF5FFFA mc=0x4DCA22 bc=0x3E2723 bdr=0x41A91D tf=Lucida Console mf=Arial',
            'Rust', 'tc=0xFFC107 mc=0xF5DEB3 bc=0x8F3209 bdr=0xF5DEB3 tf=Georgia mf=Arial',
            'Galactic', 'tc=0xFFD700 mc=White bc=Black bdr=White tf=Verdana mf=Arial',
            'Steampunk', 'tc=0xFFD700 mc=0xB87333 bc=0x3E2723 bdr=0xFFD700 tf=Trebuchet MS mf=Times New Roman',
            'Pastel', 'tc=0xFF69B4 mc=0x0072E3 bc=0xFFF0F5 bdr=0x0072E3 tf=Calibri',
            'Nature', 'tc=0x2E8B57 mc=0x4A5E4A bc=0xE8F3E8 bdr=0x4A5E4A tf=Trebuchet MS',
            'Pink Light', 'tc=0xFF1493 mc=0xFF69B4 bc=0xFFE4E1 bdr=0xFF69B4 tf=Comic Sans MS mf=Verdana',
            'Pink Dark', 'tc=0xFF1493 mc=0xFF69B4 bc=0x1F1F1F bdr=0xFF69B4 tf=Comic Sans MS mf=Verdana',
            'Sticky', 'tc=Black mc=0x333333 bc=0xF9E15B bdr=0x5F5103 tf=Arial mf=Verdana',
            'Chestnut', 'tc=0xF8F8E8 mc=0xC5735F bc=0x282828 bdr=0xF8F8E8',
            'Amber', 'tc=0xFFF8DC mc=0xFFBF00 bc=0x292929 bdr=0xFFF8DC',
            'Volcanic', 'tc=0xFE5F55 mc=0xFFC857 bc=0x1D1D1D bdr=0xFE5F55 tf=Lucida Console mf=Tahoma',
            'Amethyst', 'tc=0xD6ADFF mc=0xA56FFF bc=0x2A1B3D bdr=0xA56FFF tf=Trebuchet MS mf=Consolas',
            'Cosmos', 'tc=0x87CEEB mc=0xE6E6FA bc=0x0C0032 bdr=0x87CEEB tf=Consolas mf=Lucida Console',
            'OK', 'tc=Black mc=Black bc=0x49C149 bdr=0x336F50',
            'OKLight', 'tc=0x52CB43 mc=Black bc=0xF1F8F4 bdr=0x52CB43',
            'OKDark', 'tc=0x52CB43 mc=0xEAEAEA bc=0x1F1F1F bdr=0x52CB43 ',
            'x', 'tc=White mc=0xEAEAEA bc=0xC61111 bdr=0xEAEAEA image=iconx',
            'i', 'tc=White mc=0xEAEAEA bc=0x4682B4 bdr=0xEAEAEA image=iconi',
            '!', 'tc=Black mc=Black bc=0xFFD953 bdr=0x6F5600 image=icon!',
            '?', 'tc=White mc=0xEAEAEA bc=0x4682B4 bdr=0xEAEAEA image=icon?',
            'xLight', 'tc=0xC61111 mc=Black bc=0xFBEFEB bdr=0xC61111 image=iconx',
            '!Light', 'tc=0xE1AA04 mc=Black bc=0xFEF8EB bdr=0xE1AA04 image=icon!',
            'iLight', 'tc=0x2543AC mc=Black bc=0xE7EFFA bdr=0x2543AC image=iconi',
            '?Light', 'tc=0x2543AC mc=Black bc=0xE7EFFA bdr=0x2543AC image=icon?',
            'xDark', 'tc=0xC61111 mc=0xEAEAEA bc=0x1F1F1F bdr=0xC61111 image=iconx',
            '!Dark', 'tc=0xDEA309 mc=0xEAEAEA bc=0x1F1F1F bdr=0xDEA309 image=icon!',
            'iDark', 'tc=0x41A5EE mc=0xEAEAEA bc=0x1F1F1F bdr=0x41A5EE image=iconi',
            '?Dark', 'tc=0x41A5EE mc=0xEAEAEA bc=0x1F1F1F bdr=0x41A5EE image=icon?',
        )

        this.mAHKcolors := this.MapCI().Set(
            'Black',  '0x000000', 'Silver', '0xC0C0C0',
            'Gray',   '0x808080', 'White',  '0xFFFFFF',
            'Maroon', '0x800000', 'Red',    '0xFF0000',
            'Purple', '0x800080', 'Fuchsia','0xFF00FF',
            'Green',  '0x008000', 'Lime',   '0x00FF00',
            'Olive',  '0x808000', 'Yellow', '0xFFFF00',
            'Navy',   '0x000080', 'Blue',   '0x0000FF',
            'Teal',   '0x008080', 'Aqua',   '0x00FFFF'
        )

        this.mAW := this.MapCI().Set(
            'none', '',
            'fade', '0x80000',           ; AW_BLEND
            'expand', '0x00010',         ; AW_CENTER
            'slideEast', '0x40001',      ; AW_SLIDE | AW_HOR_POSITIVE
            'slideWest', '0x40002',      ; AW_SLIDE | AW_HOR_NEGATIVE
            'slideNorth', '0x40008',     ; AW_SLIDE | AW_VER_NEGATIVE
            'slideSouth', '0x40004',     ; AW_SLIDE | AW_VER_POSITIVE
            'slideNorthEast', '0x40009', ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_POSITIVE
            'slideNorthWest', '0x4000A', ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_NEGATIVE
            'slideSouthEast', '0x40005', ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_POSITIVE
            'slideSouthWest', '0x40006', ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_NEGATIVE
            'rollEast', '0x00001',       ; AW_HOR_POSITIVE
            'rollWest', '0x00002',       ; AW_HOR_NEGATIVE
            'rollNorth', '0x00008',      ; AW_VER_NEGATIVE
            'rollSouth', '0x00004',      ; AW_VER_POSITIVE
            'rollNorthEast', '0x00009',  ; ROLL_DIAG_BL_TO_TR
            'rollNorthWest', '0x0000a',  ; ROLL_DIAG_BR_TO_TL
            'rollSouthEast', '0x00005',  ; ROLL_DIAG_TL_TO_BR
            'rollSouthWest', '0x00006'   ; ROLL_DIAG_TR_TO_BL
        )

        this.mNotifyGUIs := this.MapCI()
        this.padG := 10 ; Pad between GUIs
        this.arrAnimDurRange := [1,2500]
        this.bdrWdefaultEdge := 2
        this.padXYdefaultEdge := 0
        this.padXYdefaultRound := 10
        this.arrBdrWrange := [1,10]
        this.arrPadXYrange := [0,25]
        this.arrPadRange := [0,999]
        this.arrFonts := Array()
        this.isTooManyFonts := false

        ;==============================================

        this.pathImagesFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Pictures') '\Notify'
        this.arrImageExt := ['ico', 'dll', 'exe', 'cpl', 'png', 'jpeg', 'jpg', 'gif', 'bmp', 'tif']
        this.strImageExt := this.ArrayToString(this.arrImageExt, '|')
        this.mImages := this.MapCI().Set('icon!', 2, 'icon?', 3, 'iconx', 4, 'iconi', 5)

        Loop Files this.pathImagesFolder '\*.*'
            if RegExMatch(A_LoopFileExt, 'i)^(' this.strImageExt ')$')
                SplitPath(A_LoopFilePath,,,, &fileName), this.mImages[fileName] := A_LoopFilePath

        ;==============================================

        this.pathSoundsFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Music') '\Sounds'
        this.mSounds := this.MapCI().Set('soundx', '*16', 'soundi', '*64')

        for path in [A_WinDir '\Media', this.pathSoundsFolder]
            Loop Files path '\*.wav'
                SplitPath(A_LoopFilePath,,,, &fileName), this.mSounds[fileName] := A_LoopFilePath

        ;==============================================

        this.mThemes := this.MapCI()
        this.mThemes['Default'] := this.MapCI()

        for theme, str in this.mThemesStrings
            this.OptionsStringToMap(this.mThemes[theme] := this.MapCI(), str)

        ;==============================================

        this.mOrig_mDefaults := this.MapCI()

        for key, value in this.mDefaults
            this.mOrig_mDefaults[key] := value

        ;==============================================

        this.mOrig_mThemes := this.MapCI()

        for theme, mTheme in this.mThemes {
            this.mOrig_mThemes[theme] := this.MapCI()

            for key, value in mTheme
                this.mOrig_mThemes[theme][key] := value
        }

        ;==============================================

        sourceFile := A_IsCompiled ? A_ScriptFullPath : A_LineFile
        SplitPath(sourceFile,, &pathDir)

        if (FileExist(pathDir '\Preferences.json')) {
            objFile := FileOpen(pathDir '\Preferences.json', 'r', 'UTF-8')
            mJSON := _JSON_thqby.parse(objFile.Read(), false, true)
            objFile.Close()

            if mJSON.Has('mDefaults')
                for key, value in mJSON['mDefaults']
                    this.mDefaults[key] := value

            if (mJSON.Has('mThemes')) {
                for key, value in mJSON['mThemes'] {
                    this.mThemes[key] := this.MapCI()

                    for k, v in value
                        this.mThemes[key][k] := v
                }
            }
        }

        ;==============================================

        if !this.mThemes.Has(this.mDefaults['theme'])
            this.mDefaults['theme'] := 'Default'

        ;==============================================

        for value in ['mThemes', 'mOrig_mThemes'] {
            for theme, mTheme in this.%value% {
                if (theme != 'default') {
                    arrKeyDefined := Array()

                    for key, v in mTheme
                        arrKeyDefined.Push(key)

                    mTheme['arrKeyDefined'] := arrKeyDefined
                }
            }
        }

        ;==============================================

        for theme, mTheme in this.mThemes
            this.ParseBorderOption(mTheme)
    }

    ;============================================================================================

    static _Show(title:='', msg:='', image:='', sound:='', callback:='', options:='')
    {
        static gIndex := 0
        this.OptionsStringToMap(m := this.MapCI(), options)

        if !m.Has('theme') || !this.mThemes.Has(m['theme'])
            m['theme'] := this.mDefaults['theme']

        if image
            m['image'] := image

        if sound
            m['sound'] := sound

        this.SetThemeSettings(m, this.mThemes[m['theme']])
        this.SetDefault_MiscValues(m)
        this.ParseAnimationOption(m)
        this.SetAnimationDefault(m)
        this.ParsePadOption(m)
        this.SetPadDefault(m)
        this.ParseBorderOption(m)
        this.SetBorderOption(m)

        if !title && !msg && m['image'] = 'none'
            return

        ;==============================================

        switch {
            case (m['mon'] = 'mouse' || m['pos'] = 'mouse'):
                m['mon'] := this.MonitorGetMouseIsIn()
            case m['mon'] = 'active':
                m['mon'] := this.MonitorGetWindowIsIn('A')
            case (m['mon'] = 'primary' || m['mon'] < 1 || m['mon'] > MonitorGetCount()):
                m['mon'] := MonitorGetPrimary()
        }

        switch m['dg'] {
            case 1: this.DestroyAllOnMonitorAtPosition(m['mon'], m['pos'])
            case 2: this.DestroyAllOnAllMonitorAtPosition(m['pos'])
            case 3: this.DestroyAllOnMonitor(m['mon'])
            case 4: this.DestroyAll()
            case 5: m['tag'] && this.Destroy(m['tag'])
        }

        ;==============================================

        g := Gui(m['opt'], 'NotifyGUI_' m['dgb'] '_' m['mon'] '_' m['pos'] '_' m['style'] '_' m['bdrC'] '_' m['bdrW'] '_'  m['padY'] '_' A_Now A_MSec (m['tag'] && '_' m['tag']))
        g.BackColor := m['bc']
        g.MarginX := m['gmL'] + m['bdrW']
        g.MarginY := m['gmT'] + m['bdrW']
        g.gIndex := ++gIndex
        m['hwnd'] := g.handle := g.hwnd

        for value in ['pos', 'mon', 'hideHex', 'hideDur', 'tag', 'dga']
            g.%value% := m[value]

        ;==============================================

        MonitorGetWorkArea(m['mon'], &monWALeft, &monWATop, &monWARight, &monWABottom)
        monWAwidth := Abs(monWARight - monWALeft)
        monWAheight := Abs(monWABottom - monWATop)
        visibleScreenWidth := this.DpiScale(monWAwidth)
        marginsWidth := (g.MarginX + m['gmR'] + m['bdrW'])

        if (mPicDimensions := this.GetImageDimensions(m['image'], 'x' monWALeft ' y' monWATop, ' w' m['iw'] ' h' m['ih']))
            pic_spX_mgn_Width := mPicDimensions['ctrlW'] + m['spX'] + marginswidth

        if title
            titleCtrlW := this.GetTextWidth(title, m['tf'], m['ts'], m['tfo'], monWALeft, monWATop)

        if msg
            msgCtrlW := this.GetTextWidth(msg, m['mf'], m['ms'], m['mfo'], monWALeft, monWATop)

        if title && (titleCtrlW + (pic_spX_mgn_Width ?? marginsWidth)) > visibleScreenWidth
            titleWidth := visibleScreenWidth - m['padX']*2 - (pic_spX_mgn_Width ?? marginsWidth)

        if msg && (msgCtrlW + (pic_spX_mgn_Width ?? marginsWidth)) > visibleScreenWidth
            msgWidth := visibleScreenWidth - m['padX']*2 - (pic_spX_mgn_Width ?? marginsWidth)

        if m['prog'] && RegExMatch(m['prog'], 'i)\bw(\d+)\b', &match_width)
            progUserW := match_width[1]

        if (m['prog'] && IsSet(progUserW)) && ((progUserW + (pic_spX_mgn_Width ?? marginsWidth)) > (visibleScreenWidth))
            progWidth := visibleScreenWidth - m['padX']*2 - (pic_spX_mgn_Width ?? marginsWidth)

        bodyWidth := Max(
            (title ? (titleWidth ?? titleCtrlW ?? 0) : 0),
            (msg ? (msgWidth ?? msgCtrlW ?? 0) : 0),
            (m['prog'] ? (progWidth ?? progUserW ?? 0) : 0)
        )

        switch {
            case m['width']: bodyWidth := m['width']
            case (m['maxW'] && m['maxW'] < bodyWidth): bodyWidth := m['maxW']
        }

        if (m['bgImg'] != 'none')
            if mPicDim := this.GetImageDimensions(m['bgImg'], 'x' monWALeft ' y' monWATop,, false)
                m['bgPic'] := g.Add('Picture', 'x0 y0')

        ;==============================================
        if (m['image'] != 'none') {
            switch {
                case this.isInternalString(m['image']):
                    try m['pic'] := g.Add('Picture', 'xm ym w' m['iw'] ' h' m['ih'] ' Icon' this.mImages[m['image']] ' BackgroundTrans', A_WinDir '\system32\user32.dll')

                case this.isInternalImage(m['image']):
                    try m['pic'] := g.Add('Picture', 'xm ym w' m['iw'] ' h' m['ih'] ' BackgroundTrans', this.mImages[m['image']])

                case arrRegExMatch := this.isIconResourceFile(m['image']):
                    try m['pic'] := g.Add('Picture', 'xm ym w' m['iw'] ' h' m['ih'] ' Icon' arrRegExMatch[2] ' BackgroundTrans', arrRegExMatch[1])

                case this.isImagePathOrHandle(m['image']):
                    try m['pic'] := g.Add('Picture', 'xm ym w' m['iw'] ' h' m['ih'] ' BackgroundTrans', m['image'])
            }
        }

        if (title) {
            this.SetFont(g, m['ts'], m['tc'], m['tfo'], m['tf'])

            switch {
                case m.Has('bgPic') && !m.Has('pic'): titlePosX := 'xm ym'
                case m.Has('pic'): titlePosX := 'x+' m['spX']
            }

            m['title'] := g.Add('Text', m['tali'] ' ' (titlePosX ?? '') ' w' bodyWidth ' BackgroundTrans', title)
        }

        if (m['prog']) {
            switch {
                case !IsSet(progUserW): m['prog'] := m['prog'] ' w' bodyWidth
                case IsSet(progUserW): m['prog'] := progUserW > bodyWidth ? RegExReplace(m['prog'], 'w\d+', 'w' bodyWidth) : m['prog']
            }

            g.MarginY := title ? m['spY'] : m['gmT'] + m['bdrW']

            switch {
                case m.Has('bgPic') && !title && !m.Has('pic'): progPosXY := 'xm ym'
                case !title && m.Has('pic'): progPosXY := 'x+' m['spX']
            }

            m['prog'] := g.Add('Progress', (progPosXY ?? '')  ' ' m['prog'])
        }

        if (msg) {
            g.MarginY := title || m['prog'] ? m['spY'] : m['gmT'] + m['bdrW']
            this.SetFont(g, m['ms'], m['mc'], m['mfo'], m['mf'])

            switch {
                case m.Has('bgPic') && !title && !m['prog'] && !m.Has('pic'): msgPosXY := 'xm ym'
                case !title && !m['prog'] && m.Has('pic'): msgPosXY := 'x+' m['spX'] ' ym'
            }

            m['msg'] := g.Add('Text', m['mali']  ' ' (msgPosXY ?? '') ' w' bodyWidth ' BackgroundTrans', msg)
        }

        g.MarginX := m['gmR'] + m['bdrW']
        g.MarginY := m['gmB'] + m['bdrW']

        g.Show('hide')
        WinGetPos(&gX, &gY, &gW, &gH, g)

        if (m['minH'] && (gH < m['minH']))
            g.Show('hide h' m['minH']), WinGetPos(&gX, &gY, &gW, &gH, g)

        m['gW'] := gW
        m['gH'] := gH

        ;==============================================

        if (m.Has('bgPic')) {
            try {
                for value in ['w', 'h'] {
                    switch {
                        case RegExMatch(m['bgImgPos'], 'i)\b' value '0\b'):
                            continue

                        case RegExMatch(m['bgImgPos'], 'i)\b' value 'stretch\b') || m['bgImgPos'] = 'stretch':
                            mPicDim['ctrl' value] := m['g' value]

                        case RegExMatch(m['bgImgPos'], 'i)\b' value '-1\b'):
                            mPicDim['ctrl' value] := -1

                        case RegExMatch(m['bgImgPos'], 'i)\b' value '\K\d+\b', &matchWH):
                            mPicDim['ctrl' value] := matchWH[0] * (A_ScreenDPI / 96)

                        default: mPicDim['ctrl' value] *= (A_ScreenDPI / 96)
                    }
                }

                switch {
                    case mPicDim['ctrlW'] = -1: mPicDim['ctrlW'] := Round(mPicDim['ctrlH'] * mPicDim['aspectRatio'])
                    case mPicDim['ctrlH'] = -1: mPicDim['ctrlH'] := Round(mPicDim['ctrlW'] / mPicDim['aspectRatio'])
                }

                if RegExMatch(m['bgImgPos'], 'i)\bscale\K([\d\.]+)\b', &matchScale)
                    for value in ['w', 'h']
                        mPicDim['ctrl' value] *= matchScale[0]

                switch {
                    case m['bgImgPos'] ~= 'i)\btl\b' : m['bgImgPosX'] := 0, m['bgImgPosY'] := 0
                    case m['bgImgPos'] ~= 'i)\btc\b' : m['bgImgPosX'] := this.DpiScale(m['gW']/2 - mPicDim['ctrlW']/2)
                    case m['bgImgPos'] ~= 'i)\btr\b' : m['bgImgPosX'] := this.DpiScale(m['gW'] - mPicDim['ctrlW'])
                    case m['bgImgPos'] ~= 'i)\bctl\b' : m['bgImgPosY'] := this.DpiScale(m['gH']/2 - mPicDim['ctrlH']/2)
                    case m['bgImgPos'] ~= 'i)\bct\b' : m['bgImgPosX'] := this.DpiScale(m['gW']/2 - mPicDim['ctrlW']/2), m['bgImgPosY'] := this.DpiScale(m['gH']/2 - mPicDim['ctrlH']/2)
                    case m['bgImgPos'] ~= 'i)\bctr\b' : m['bgImgPosY'] := this.DpiScale(m['gH']/2 - mPicDim['ctrlH']/2), m['bgImgPosX'] := this.DpiScale(m['gW'] - mPicDim['ctrlW'])
                    case m['bgImgPos'] ~= 'i)\bbl\b' : m['bgImgPosY'] := this.DpiScale(m['gH'] - mPicDim['ctrlH'])
                    case m['bgImgPos'] ~= 'i)\bbc\b' : m['bgImgPosX'] := this.DpiScale(m['gW']/2 - mPicDim['ctrlW']/2), m['bgImgPosY'] := this.DpiScale(m['gH'] - mPicDim['ctrlH'])
                    case m['bgImgPos'] ~= 'i)\bbr\b' : m['bgImgPosX'] := this.DpiScale(m['gW'] - mPicDim['ctrlW']), m['bgImgPosY'] := this.DpiScale(m['gH'] - mPicDim['ctrlH'])
                }

                for value in ['x', 'y'] {
                    m['bgImgPos' value] := m.Get('bgImgPos' value, 0)

                    switch {
                        case RegExMatch(m['bgImgPos'], 'i)\b' value '\K-?\d+\b', &matchPos):
                            m['bgImgPos' value] := matchPos[0]

                        case RegExMatch(m['bgImgPos'], 'i)\bofst' value '\K-?\d+\b', &matchOfst):
                            m['bgImgPos' value] += matchOfst[0]
                    }
                }

                switch {
                    case this.isInternalString(m['bgImg']):
                        m['bgPic'].Value := '*w' mPicDim['ctrlW'] ' *h' mPicDim['ctrlH'] ' *Icon' this.mImages[m['bgImg']] ' ' A_WinDir '\system32\user32.dll'

                    case this.isInternalImage(m['bgImg']):
                        m['bgPic'].Value := '*w' mPicDim['ctrlW'] ' *h' mPicDim['ctrlH'] ' ' this.mImages[m['bgImg']]

                    case arrRegExMatch := this.isIconResourceFile(m['bgImg']):
                        m['bgPic'].Value := '*w' mPicDim['ctrlW'] ' *h' mPicDim['ctrlH'] ' *Icon' arrRegExMatch[2] ' ' arrRegExMatch[1]

                    case this.isImagePathOrHandle(m['bgImg']):
                        m['bgPic'].Value := '*w' mPicDim['ctrlW'] ' *h' mPicDim['ctrlH'] ' ' m['bgImg']

                    case this.isValidColor(m['bgImg']):
                        m['bgPic'].Value := '*w' mPicDim['ctrlW'] ' *h' mPicDim['ctrlH'] ' hBitmap: ' this.CreatePixel(m['bgImg'])
                }

                m['bgPic'].Move(m['bgImgPosX'], m['bgImgPosY'])
            }
        }

        ;==============================================

        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')

        switch Type(callback) {
            case 'Func', 'BoundFunc': clickArea.OnEvent('Click', callback)
            case 'Array':
            {
                if callback.Has(1) && callback[1] != ''
                    clickArea.OnEvent('Click', callback[1])

                for value in ['pic', 'bgPic']
                    if m.Has(value) && callback.Has(A_Index+1) && callback[A_Index+1] != ''
                        m[value].OnEvent('Click', callback[A_Index+1])
            }
        }

        if m['dgc']
            clickArea.OnEvent('Click', this.gDestroy.Bind(this, g, 'clickArea'))

        g.OnEvent('Close', this.gDestroy.Bind(this, g, 'close'))
        g.boundFuncTimer := this.gDestroy.Bind(this, g, 'timer')

        if m['sound'] != 'none'
            this.Sound(m['sound'])

        ;==============================================

        switch m['pos'], false {
            case 'bl', 'bc', 'br': minMaxPosY := monWABottom
            case 'tl', 'tc', 'tr', 'ctl', 'ct', 'ctr': minMaxPosY := monWATop
        }

        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_[0-1]_' m['mon'] '_' m['pos'] '_ ahk_class AutoHotkeyGUI') {
            try {
                WinGetPos(, &guiY,, &guiH, 'ahk_id ' id)
                switch m['pos'], false {
                    case 'bl', 'bc', 'br': minMaxPosY := Min(minMaxPosY, guiY)
                    case 'tl', 'tc', 'tr', 'ctl', 'ct', 'ctr': minMaxPosY := Max(minMaxPosY, guiY + guiH)
                }
            } catch
                break
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])

        switch m['pos'], false {
            case 'tl':  gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'tc':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'tr':  gPos := 'x' monWARight - m['padX'] - gW      ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'ctl': gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'ct':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'ctr': gPos := 'x' monWARight - m['padX'] - gW      ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'bl':  gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'bc':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'br':  gPos := 'x' monWARight - gW - m['padX']      ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'mouse': gPos := this.CalculatePopupWindowPosition(g.hwnd)
        }

        switch g.pos, false {
            case 'bl', 'bc', 'br': outOfWorkArea := (minMaxPosY < (monWATop + gH + this.padG))
            case 'tl', 'tc', 'tr', 'ctl', 'ct', 'ctr': outOfWorkArea := (minMaxPosY > (monWABottom - gH - this.padG))
            case 'mouse': outOfWorkArea := false
        }

        ;==============================================

        this.mNotifyGUIs[gIndex] := g

        switch m['style'], false {
            case 'round': this.FrameShadow(g.hwnd), !RegExMatch(m['bdrC'], 'i)^(default|1|0)$') && this.DrawBorderRound(g.hwnd, m['bdrC'])
            case 'edge': RegExMatch(m['bdrC'], 'i)^(default|1)$') && g.Opt('+Border')
        }

        if m['wstp'] || m['wstp'] = 0
            WinSetTransparent(m['wstp'], g)

        if m['wstc']
            WinSetTransColor(m['wstc'], g)

        g.Show(gPos ' NoActivate Hide')

        if (m['showHex']) {
            try DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', m['showDur'], 'Int', m['showHex'])
            catch
                g.Show(gPos ' NoActivate')
        } else
            g.Show(gPos ' NoActivate')

        if m['style'] = 'edge' && !RegExMatch(m['bdrC'], 'i)^(default|1|0)$')
            try this.DrawBorderEdge(g.Hwnd, m['bdrC'], m['bdrW'])

        if m['dur']
            SetTimer(g.boundFuncTimer, - ((m['dur'] + (outOfWorkArea ? 8 : 0)) * 1000))

        return m
    }

    ;============================================================================================

    static gDestroy(g, fromMethod:='', *)
    {
        SetTimer(g.boundFuncTimer, 0)

        if g.hideHex && (fromMethod != 'close' || g.dga)
            try DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', g.hideDur, 'Int', Format('{:#X}', g.hideHex + 0x10000))

        g.Destroy()

        if this.mNotifyGUIs.Has(g.gIndex)
            this.mNotifyGUIs.Delete(g.gIndex)

        ;==============================================

        Sleep(25)
        arrGUIs := Array()
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_[0-1]_' g.mon '_' g.pos '_ ahk_class AutoHotkeyGUI') {
            try {
                WinGetPos(, &gY,, &gH, 'ahk_id ' id)
                RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_[0-1]_\d+_([a-z]+)_([a-z]+)_(\w+)_(\d+)_(\d+)_\d{17}', &match)

                if match[1] = 'mouse'
                    continue

                arrGUIs.Push(this.MapCI().Set('gY', gY, 'gH', gH, 'id', id, 'style', match[2], 'bdrC', match[3], 'bdrW', match[4], 'padY', match[5]))
            } catch {
                arrGUIs := Array()
                break
            }
        }

        if (arrGUIs.Length) {
            try MonitorGetWorkArea(g.mon,, &monWATop,, &monWABottom)
            catch {
                this.RedrawAllBorderEdge()
                this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
                return
            }

            monWAheight := Abs(monWABottom - monWATop)
            SetWinDelay(0)

            switch g.pos, false {
                case 'bl', 'bc', 'br': arrGUIs := this.SortArrayGUIPosY(arrGUIs, true),  posY := monWABottom - arrGUIs[1]['padY']
                case 'tl', 'tc', 'tr', 'ctl', 'ct', 'ctr': arrGUIs := this.SortArrayGUIPosY(arrGUIs),  posY := monWATop + arrGUIs[1]['padY']
            }

            for value in arrGUIs {
                switch g.pos, false {
                    case 'bl', 'bc', 'br': posY -= value['gH']
                    case 'ctl', 'ct', 'ctr': (A_Index = 1 && posY := monWATop + monWAheight/2 - value['gH']/2)
                }

                if (Abs(posY - value['gY']) > 10) {
                    try {
                        WinMove(, posY,,, 'ahk_id ' value['id'])
                        this.ReDrawBorderEdge(value['id'], value['style'], value['bdrC'], value['bdrW'])
                    } catch
                        break
                }

                switch g.pos, false {
                    case 'bl', 'bc', 'br': posY -= this.padG
                    case 'tl', 'tc', 'tr', 'ctl', 'ct', 'ctr': posY += value['gH'] + this.padG
                }
            }
        }

        this.RedrawAllBorderEdge()
        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    /********************************************************************************************
     * Destroys GUIs.
     * @param {integer|string} param
     * - Window handle (hwnd) - Destroys the GUI with the specified window handle.
     * - Tag - Destroys every GUI containing this tag across all scripts.
     * - 'oldest' or no param - Destroys the oldest GUI.
     * - 'latest' - Destroys the most recent GUI.
     * @param {boolean} force - When true, overrides Destroy GUI block (DGB) setting and forces GUI destruction.
     */
    static Destroy(param:='', force:=false)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')
        bin := (force ? '[0-1]' : 0)
        SetWinDelay(25)

        switch {
            case (param = 'oldest' || param = 'latest' || param = ''):
            {
                m := Map()
                for id in WinGetList('i)^NotifyGUI_' bin '_ ahk_class AutoHotkeyGUI') {
                    try {
                        RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_' bin '_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_(\d{17})', &match)
                        m[match[1]] := id
                    }
                }

                if (param = 'latest') {
                    for timestamp, id in m
                        destroyId := id
                } else {
                    for timestamp, id in m {
                        destroyId := id
                        break
                    }
                }

                if IsSet(destroyId)
                    try WinClose('ahk_id ' destroyId)
            }

            ;==============================================

            case (WinExist('ahk_id ' param)):
            {
                for id in WinGetList('i)^NotifyGUI_' bin '_ ahk_class AutoHotkeyGUI') {
                    if (param = id) {
                        try WinClose('ahk_id ' id)
                        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
                        return
                    }
                }
            }

            ;==============================================

            default:
                for id in WinGetList('i)^NotifyGUI_' bin '_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_\d{17}_\Q' param '\E$ ahk_class AutoHotkeyGUI')
                    try WinClose('ahk_id ' id)
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    ;============================================================================================

    static DestroyAllOnMonitorAtPosition(monNum, position, force:=false)=> this.WinGetList_WinClose('i)^NotifyGUI_' (force ? '[0-1]' : '0') '_' monNum '_' position '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')

    static DestroyAllOnAllMonitorAtPosition(position, force:=false)=> this.WinGetList_WinClose('i)^NotifyGUI_' (force ? '[0-1]' : '0') '_\d+_' position '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')

    static DestroyAllOnMonitor(monNum, force:=false)=> this.WinGetList_WinClose('i)NotifyGUI_' (force ? '[0-1]' : '0') '_' monNum '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')

    static DestroyAll(force:=false)=> this.WinGetList_WinClose('i)^NotifyGUI_' (force ? '[0-1]' : '0') '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')

    ;============================================================================================

    static WinGetList_WinClose(winTitle, dhWindows, tmMode)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(dhWindows, tmMode)
        SetWinDelay(25)

        for id in WinGetList(winTitle)
            try WinClose('ahk_id ' id)

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    /********************************************************************************************
     * Checks if a GUI with the specified tag exists.
     * @param {string} tag - The tag to search.
     * @returns {integer|false} - The unique ID (HWND) of the first matching GUI if found, otherwise false.
     */
    static Exist(tag)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_[0-1]_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_\d{17}_\Q' tag '\E$ ahk_class AutoHotkeyGUI') {
            idFound := id
            break
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
        return idFound ?? false
    }

    ;============================================================================================

    static SetDefaultTheme(theme:='')
    {
        switch {
            case this.mThemes.Has(theme): this.mDefaults['theme'] := theme
            case !theme: this.mDefaults['theme'] := 'default'
        }
    }

    ;============================================================================================

    static SetDefault_MiscValues(m)
    {
        for key, value in this.mDefaults
            m[key] := m.Get(key, value)

        if !RegExMatch(m['style'], 'i)^(round|edge)$')
            m['style'] := this.mDefaults['style']

        if !RegExMatch(m['dgb'], '^(0|1)$')
            m['dgb'] := this.mDefaults['dgb']

        for value in ['tfo', 'mfo'] {
            m['arr' value] := Array()

            for v in ['bold', 'italic', 'strike', 'underline']
                if InStr(m[value], v)
                    m['arr' value].Push(v)

            if !InStr(m[value], 'norm')
                m[value] := Trim('norm ' m[value])
        }
    }

    ;============================================================================================

    static ParsePadOption(m)
    {
        if (m.has('pad')) {
            arrPad := StrSplit(m['pad'], ',', A_Space)

            for key in ['padX', 'padY', 'gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
                if !m.Has(key) && arrPad.Has(A_Index) && arrPad[A_Index] != ''
                    m[key] := arrPad[A_Index]

            this.SetValidPadRange(m)
        }
    }

    ;============================================================================================

    static SetPadDefault(m)
    {
        padXYdefault := (m['style'] = 'edge' ? this.padXYdefaultEdge : this.padXYdefaultRound)

        for key in ['padX', 'padY']
            m[key] := m.Get(key, padXYdefault)

        if this.mThemes[m['theme']].Has('pad')
            arrPad := StrSplit(this.mThemes[m['theme']]['pad'], ',', A_Space)
        else
            arrPad := StrSplit(this.mDefaults['pad'], ',', A_Space)

        for key in ['gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
            if !m.Has(key) && arrPad.Has(A_Index+2) && arrPad[A_Index+2] != ''
                m[key] := arrPad[A_Index+2]

        this.SetValidPadRange(m)
    }

    ;============================================================================================

    static SetValidPadRange(m)
    {
        for key in ['padX', 'padY', 'gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY'] {
            strPad := RegExMatch(key, '^(padX|padY)$') ? 'arrPadXYrange' : 'arrPadRange'
            m.Has(key) ? m[key] := Min(this.%strPad%[2], Max(this.%strPad%[1], Integer(m[key]))) : ''
        }
    }

    ;============================================================================================

    static ParseAnimationOption(m)
    {
        for value in ['show', 'hide'] {
            if (m.has(value)) {
                arrAnim := StrSplit(m[value], '@', A_Space)
                m[value 'Hex'] := this.mAW[arrAnim[1] = 0 ? 'none' : arrAnim[1]]
                arrAnim.Has(2) && (m[value 'Dur'] := Min(this.arrAnimDurRange[2], Max(this.arrAnimDurRange[1], integer(arrAnim[2]))))
            }
        }
    }

    ;============================================================================================

    static SetAnimationDefault(m)
    {
        switch m['style'], false {
            case 'edge':
            {
                if !m.Has('showHex') {
                    switch m['pos'], false {
                        case 'br', 'tr', 'ctr': m['showHex'] := this.mAW['slideWest']
                        case 'bl', 'tl', 'ctl': m['showHex'] := this.mAW['slideEast']
                        case 'bc': m['showHex'] := this.mAW['slideNorth']
                        case 'tc': m['showHex'] := this.mAW['slideSouth']
                        case 'ct': m['showHex'] := this.mAW['expand']
                        case 'mouse': m['showHex'] := this.mAW['none']
                    }
                }

                if !m.Has('hideHex') {
                    switch m['pos'], false {
                        case 'br', 'tr', 'ctr': m['hideHex'] := this.mAW['slideEast']
                        case 'bl', 'tl', 'ctl': m['hideHex'] := this.mAW['slideWest']
                        case 'bc': m['hideHex'] := this.mAW['slideSouth']
                        case 'tc': m['hideHex'] := this.mAW['slideNorth']
                        case 'ct': m['hideHex'] := this.mAW['expand']
                        case 'mouse': m['hideHex'] := this.mAW['none']
                    }
                }
                m['showDur'] := m.Get('showDur', 75)
                m['hideDur'] := m.Get('hideDur', 100)
            }

            case 'round':
            {
                m['showHex'] := m.Get('showHex', this.mAW['fade'])
                m['hideHex'] := m.Get('hideHex', this.mAW['none'])
                m['showDur'] := m.Get('showDur', 1)
                m['hideDur'] := m.Get('hideDur', 1)
            }
        }
    }

    ;============================================================================================

    static ParseBorderOption(m)
    {
        if (m.Has('bdr')) {
            arrBdr := StrSplit(m['bdr'], ',', A_Space)
            m['bdr'] := this.NormAHKColor(m['bdr'])
            m['bdrC'] := this.NormAHKColor(arrBdr[1])
            arrBdr.Has(2) && (m['bdrW'] := this.SetValidBorderWidth(arrBdr[2]))
        }
    }

    ;============================================================================================

    static SetBorderOption(m)
    {
        mTheme := this.mThemes.Has(m['theme']) ? this.mThemes[m['theme']] : this.MapCI()

        switch {
            case m['bdr'] = 0: m['bdrC'] := 0
            case m.Has('bdrC') && m['bdrC']: m['bdrC'] := m['bdrC']
            case (!m.Has('bdrC') || !m['bdrC']) && mTheme.Has('bdrC'): m['bdrC'] := mTheme['bdrC']
            case (!m.Has('bdrC') || !m['bdrC']) && !mTheme.Has('bdrC'): m['bdrC'] := 'default'
        }

        switch {
            case RegExMatch(m['bdrC'], 'i)^(default|1|0)$'): m['bdrW'] := 0
            case !m.Has('bdrW'): m['bdrW'] := (m['style'] = 'edge' ? this.bdrWdefaultEdge : 0)
            case m.Has('bdrW'):
                switch m['style'], false {
                    case 'edge': m['bdrW'] := this.SetValidBorderWidth(m['bdrW'])
                    case 'round': m['bdrW'] := 0
                }
        }
    }

    ;============================================================================================

    static SetValidBorderWidth(width) => Min(this.arrBdrWrange[2], Max(this.arrBdrWrange[1], Integer(width)))

    ;============================================================================================

    static SetFont(g, size, color, fontOption, fontName)
    {
        g.SetFont('s' size ' c' color ' ' fontOption, fontName)
        strFont := size ' ' this.NormalizeFontOptions(fontOption) . fontName

        if !this.HasVal(strFont, this.arrFonts)
            this.arrFonts.Push(strFont)

        if (this.arrFonts.Length >= 190) {
            this.isTooManyFonts := true
            return false
        }

        return true
    }

    ;============================================================================================

    static NormalizeFontOptions(str)
    {
        strFontopt := ''

        for option in ['bold', 'italic', 'strike', 'underline']
            if InStr(str, option)
                strFontopt .= option ' '

        return strFontopt
    }

    ;============================================================================================

    static Set_DHWindows_TMMode(dhw, tmm)
    {
        dhwPrev := A_DetectHiddenWindows
        tmmPrev := A_TitleMatchMode
        DetectHiddenWindows(dhw)
        SetTitleMatchMode(tmm)
        return Map('dhwPrev', dhwPrev, 'tmmPrev', tmmPrev)
    }

    /********************************************************************************************
     * Plays a sound.
     * @param {string|integer} sound - A valid sound format. See the documentation for the sound parameter.
     */
    static Sound(sound)
    {
        if this.mSounds.Has(sound)
            sound := this.mSounds[sound]

        switch {
            case FileExist(sound): try this.PlayWavConcurrent(sound)
            case RegExMatch(sound,'^\*\-?\d+'): try Soundplay(sound)
        }
    }

    /********************************************************************************************
     * @credits Faddix, XMCQCX (minor modifications)
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=130425 AHK Forum}
     */
    static PlayWavConcurrent(fPath)
    {
        static obj := initialize()
        SplitPath(fPath,,, &ext)

        initialize() {
            if !hModule := DllCall("LoadLibrary", "Str", "XAudio2_9.dll", "Ptr")
                return false

            DllCall("XAudio2_9\XAudio2Create", "Ptr*", IXAudio2 := ComValue(13, 0), "Uint", 0, "Uint", 1)
            ComCall(7, IXAudio2, "Ptr*", &IXAudio2MasteringVoice := 0, "Uint", 0, "Uint", 0, "Uint", 0, "Ptr", 0, "Ptr", 0, "Int", 6) ; CreateMasteringVoice
            return { IXAudio2: IXAudio2, someMap: Map() }
        }

        if !obj || !RegExMatch(ext, 'i)^wav$')
            return

        ; freeing is unnecessary, but..
        XAUDIO2_VOICE_STATE := Buffer(A_PtrSize * 2 + 0x8)
        keys_to_delete := []
        for IXAudio2SourceVoice in obj.someMap {
            ComCall(25, IXAudio2SourceVoice, "Ptr", XAUDIO2_VOICE_STATE, "Uint", 0, "Int") ;GetState
            if (!NumGet(XAUDIO2_VOICE_STATE, A_PtrSize, "Uint")) { ; BuffersQueued (includes the one that is being processed)
                keys_to_delete.Push(IXAudio2SourceVoice)
            }
        }
        for IXAudio2SourceVoice in keys_to_delete {
            ComCall(20, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ;Stop
            ComCall(18, IXAudio2SourceVoice, "Int") ; void DestroyVoice
            obj.someMap.Delete(IXAudio2SourceVoice)
        }

        waveFile := FileRead(fPath, "RAW")

        if !root_tag_to_offset := get_tag_to_offset_map(0, waveFile.Size)
            return

        if !idk_tag_to_offset := get_tag_to_offset_map(root_tag_to_offset["RIFF"].ofs + 0xc, waveFile.Size)
            return

        WAVEFORMAT_ofs := idk_tag_to_offset["fmt "].ofs + 0x8
        data_ofs := idk_tag_to_offset["data"].ofs + 0x8
        data_size := idk_tag_to_offset["data"].size

        get_tag_to_offset_map(i, end) {
            tag_to_offset := Map()
            while (i + 8 <= end) { ; Ensure there's enough data for a chunk header
                tag := StrGet(waveFile.Ptr + i, 4, "UTF-8") ; RIFFChunk::tag
                size := NumGet(waveFile, i + 0x4, "Uint") ; RIFFChunk::size

                ; Stop execution and return false if chunk size exceeds file bounds
                if (i + 8 + size > end)
                    return false

                tag_to_offset[tag] := { ofs: i, size: size }
                ; Align to next 2-byte or 4-byte boundary
                i += size + 8
                if (i & 1) ; 2-byte alignment
                    i += 1
            }
            return tag_to_offset
        }

        ComCall(5, obj.IXAudio2, "Ptr*", &IXAudio2SourceVoice := 0, "Ptr", waveFile.Ptr + WAVEFORMAT_ofs, "int", 0, "float", 2.0, "Ptr", 0, "Ptr", 0, "Ptr", 0) ; CreateSourceVoice
        XAUDIO2_BUFFER := Buffer(A_PtrSize * 2 + 0x1c, 0)
        NumPut("Uint", 0x0040, XAUDIO2_BUFFER, 0x0) ; Flags=XAUDIO2_END_OF_STREAM
        NumPut("Uint", data_size, XAUDIO2_BUFFER, 0x4) ; AudioBytes
        NumPut("Ptr", waveFile.Ptr + data_ofs, XAUDIO2_BUFFER, 0x8) ; pAudioData
        ComCall(21, IXAudio2SourceVoice, "Ptr", XAUDIO2_BUFFER, "Ptr", 0) ; SubmitSourceBuffer
        ComCall(19, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ; Start
        obj.someMap[IXAudio2SourceVoice] := waveFile
    }

    ;============================================================================================

    static OptionsStringToMap(m, haystack)
    {
        pos := 1
        while (pos := RegExMatch(haystack, 'i)(\w+)\s*=\s*(.*?)\s*(?=\s*\w+\s*=|$)', &match, pos))
            m[match[1]] := match[2], pos += StrLen(match[0])
    }

    ;============================================================================================

    static SetThemeSettings(m, mTheme)
    {
        if (m['theme'] != 'default')
            for key in mTheme['arrKeyDefined']
                m[key] := m.Get(key, mTheme[key])
    }

    ;============================================================================================

    static GetTextWidth(str:='', font:='', fontSize:='', fontOption:='', monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.SetFont('s' fontSize ' ' fontOption, font)
        g.txt := g.Add('Text',, str)
        g.Show('x' monWALeft ' y' monWATop ' Hide')
        g.txt.GetPos(,, &ctrlW)
        g.Destroy()
        return ctrlW
    }

    ;============================================================================================

    static GetImageDimensions(image, posXY?, dimWH:='', dpiScale:=true)
    {
        g := Gui(dpiScale ? '' : '-DPIScale')
        posXY := (posXY ?? 'x0 y0')

        switch {
            case this.isInternalString(image):
                try g.pic := g.Add('Picture', dimWH ' Icon' this.mImages[image] ' BackgroundTrans', A_WinDir '\system32\user32.dll')

            case this.isInternalImage(image):
                try g.pic := g.Add('Picture', dimWH ' BackgroundTrans', this.mImages[image])

            case arrRegExMatch := this.isIconResourceFile(image):
                try g.pic := g.Add('Picture', dimWH ' Icon' arrRegExMatch[2] ' BackgroundTrans', arrRegExMatch[1])

            case this.isImagePathOrHandle(image):
                try g.pic := g.Add('Picture', dimWH ' BackgroundTrans', image)

            case this.isValidColor(image):
                try g.pic := g.Add('Picture',, 'hBitmap: ' this.CreatePixel(image))
        }

        if (g.HasOwnProp('pic')) {
            g.Show(posXY ' hide')
            g.pic.GetPos(,, &ctrlW, &ctrlH)
            mDim := this.MapCI().Set('ctrlW', ctrlW, 'ctrlH', ctrlH, 'aspectRatio', Round(ctrlW / ctrlH, 2))
        }

        g.Destroy()
        return mDim ?? false
    }

    ;============================================================================================

    static SortArrayGUIPosY(arr, sortReverse := false)
    {
        for value in arr
            listValueY .= value['gY'] ','

        listSortValueY := Sort(RTrim(listValueY, ','), (sortReverse ? 'RN' : 'N') ' D,')
        sortArray := Array()

        for value in StrSplit(listSortValueY, ',')
            for v in arr
                if v['gY'] = value
                    sortArray.Push(v)

        return sortArray
    }

    ;=============================================================================================

    static HasVal(needle, haystack, caseSensitive := false)
    {
        for index, value in haystack
            if (caseSensitive && value == needle) || (!caseSensitive && value = needle)
                return index

        return false
    }

    ;============================================================================================

    static ArrayToString(arr, delim)
    {
        for value in arr
            str .= value delim

        return RTrim(str, delim)
    }

    ;============================================================================================

    static NormAllColors(m)
    {
        for key in ['tc', 'mc', 'bc']
            if m.Has(key)
                m[key] := NormColor(m[key])

        for key in ['bdr', 'bdrC']
            if m.Has(key) && !RegExMatch(m[key], 'i)^(1|0|default)$')
                m[key] := NormColor(m[key])

        NormColor(key) => this.NormAHKColor(this.NormHexClrCode(key))
    }

    ;============================================================================================

    static NormAHKColor(color)
    {
        if RegExMatch(color, '^(0|1)$')
            return color

        for colorName, colorValue in this.mAHKcolors {
            if (colorValue = color) {
                color := colorName
                break
            }
        }

        return color
    }

    ;============================================================================================

    static NormHexClrCode(color)
    {
        if this.mAHKcolors.Has(color)
            color := this.mAHKcolors[color]

        if RegExMatch(Color, '^[0-9A-Fa-f]{1,6}$') && SubStr(color, 1, 2) != '0x'
            color := '0x' color

        if (RegExMatch(color, '^0x[0-9A-Fa-f]{1,6}$')) {
            hexPart := SubStr(color, 3)
            while StrLen(hexPart) < 6
                hexPart := '0' hexPart
            color := '0x' hexPart
        }
        else color := '0xFFFFFF'

        return color
    }

    /********************************************************************************************
     * @credits TheDewd, XMCQCX (v2 conversion, minor modifications)
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=7312 AHK Forum}
     */
    static CreatePixel(color)
    {
        color := this.NormHexClrCode(color)
        hBitmap := DllCall("CreateBitmap", "Int", 1, "Int", 1, "UInt", 1, "UInt", 32, "Ptr", 0, "Ptr")
        hBM := DllCall("CopyImage", "Ptr", hBitmap, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
        BMBITS := Buffer(4, 0)
        NumPut("UInt", color, BMBITS, 0)
        DllCall("SetBitmapBits", "Ptr", hBM, "UInt", 4, "Ptr", BMBITS)
        DllCall("DeleteObject", "Ptr", hBitmap)
        return hBM
    }

    /********************************************************************************************
     * @credits Klark92, XMCQCX (v2 conversion)
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117 AHK Forum}
     */
    static FrameShadow(hwnd)
    {
        DllCall("dwmapi.dll\DwmIsCompositionEnabled", "int*", &dwmEnabled:=0)

        if !dwmEnabled {
            DllCall("user32.dll\SetClassLongPtr", "ptr", hwnd, "int", -26, "ptr", DllCall("user32.dll\GetClassLongPtr", "ptr", hwnd, "int", -26) | 0x20000)
        }
        else {
            margins := Buffer(16, 0)
            NumPut("int", 1, "int", 1, "int", 1, "int", 1, margins)
            DllCall("dwmapi.dll\DwmSetWindowAttribute", "ptr", hwnd, "Int", 2, "Int*", 2, "Int", 4)
            DllCall("dwmapi.dll\DwmExtendFrameIntoClientArea", "ptr", hwnd, "ptr", margins)
        }
    }

    /********************************************************************************************
     * @credits ericreeves
     * @see {@link https://gist.github.com/ericreeves/fd426cc0457a5a47058e1ad1a29d9bd6 GitHub Gist}
     */
    static DrawBorderRound(hwnd, color)
    {
        color := this.RGB_BGR(this.NormHexClrCode(color))
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR := 34, "int*", color, "int", 4)
    }

    ;============================================================================================

    static DrawBorderEdge(hwnd, color, width)
    {
        color := this.RGB_BGR(this.NormHexClrCode(color))
        rect := Buffer(16)
        DllCall("GetClientRect", "ptr", hwnd, "ptr", rect)
        left := NumGet(rect, 0, "int")
        top := NumGet(rect, 4, "int")
        right := NumGet(rect, 8, "int")
        bottom := NumGet(rect, 12, "int")
        hdc := DllCall("GetDC", "ptr", hwnd)
        hBrush := DllCall("gdi32\CreateSolidBrush", "uint", color, "ptr")
        hOldBrush := DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", hBrush, "ptr")
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", top, "int", right - left, "int", width, "uint", 0x00F00021) ; Top border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", bottom - width, "int", right - left, "int", width, "uint", 0x00F00021) ; Bottom border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", top, "int", width, "int", bottom - top, "uint", 0x00F00021) ; Left border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", right - width, "int", top, "int", width, "int", bottom - top, "uint", 0x00F00021) ; Right border
        DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", hOldBrush)
        DllCall("gdi32\DeleteObject", "ptr", hBrush)
        DllCall("ReleaseDC", "ptr", hwnd, "ptr", hdc)
    }

    ;============================================================================================

    static ReDrawBorderEdge(hwnd, style, color, width)
    {
        if style = 'edge' && !RegExMatch(color, 'i)^(default|1|0)$')
            this.DrawBorderEdge(hwnd, color, width)
    }

    ;============================================================================================

    static RedrawAllBorderEdge()
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_[0-1]_\d+_[a-z]+_edge_\w+_\d+_\d+_\d{17} ahk_class AutoHotkeyGUI') {
            try {
                RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_[0-1]_\d+_[a-z]+_edge_(\w+)_(\d+)_\d+_\d{17}', &match)
                this.ReDrawBorderEdge(id, 'edge', match[1], match[2])
            }
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    ;============================================================================================

    static MonitorGetMouseIsIn()
    {
        cmmPrev := A_CoordModeMouse
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&posX, &posY)
        CoordMode('Mouse', cmmPrev)

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (posX >= monLeft) && (posX < monRight) && (posY >= monTop) && (posY < monBottom)
                return A_Index
        }

        return MonitorGetPrimary()
    }

    ;============================================================================================

    static MonitorGetWindowIsIn(winTitle)
    {
        try WinGetPos(&posX, &posY, &winW, &winH, winTitle)
        catch
            return MonitorGetPrimary()

        centerWinX := posX + winW/2
        centerWinY := posY + winH/2

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (centerWinX >= monLeft) && (centerWinX < monRight) && (centerWinY >= monTop) && (centerWinY < monBottom)
                return A_Index
        }

        return MonitorGetPrimary()
    }

    /********************************************************************************************
     * @credits lexikos
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=103459 AHK Forum}
     */
    static CalculatePopupWindowPosition(hwnd)
    {
        cmmPrev := A_CoordModeMouse
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&x, &y)
        CoordMode('Mouse', cmmPrev)
        anchorPt := Buffer(8)
        windowRect := Buffer(16), windowSize := windowRect.ptr + 8
        excludeRect := Buffer(16)
        outRect := Buffer(16)
        DllCall("GetClientRect", "ptr", hwnd, "ptr", windowRect)

        /*
            Windows 7 permits overlap with the taskbar, whereas Windows 10 requires the
            tooltip to be within the work area (WinMove can subvert that, so this is just
            for consistency with the normal behaviour).
        */
        flags := VerCompare(A_OSVersion, "6.2") < 0 ? 0 : 0x10000 ; TPM_WORKAREA

        NumPut("int", x+16, "int", y+16, anchorPt) ; ToolTip normally shows at an offset of 16,16 from the cursor.
        NumPut("int", x-3, "int", y-3, "int", x+3, "int", y+3, excludeRect) ; Avoid the area around the mouse pointer.
        DllCall("CalculatePopupWindowPosition", "ptr", anchorPt, "ptr", windowSize, "uint", flags, "ptr", excludeRect, "ptr", outRect)
        return 'x' NumGet(outRect, 0, 'int') ' y' NumGet(outRect, 4, 'int')
    }

    ;============================================================================================

    static isInternalString(image) => RegExMatch(image, 'i)^(icon!|icon\?|iconx|iconi)$')

    static isInternalImage(image) => this.mImages.Has(image) && FileExist(this.mImages[image])

    static isIconResourceFile(image) => RegExMatch(image, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &match) && FileExist(match[1]) ? [match[1], match[2]] : ''

    static isImagePathOrHandle(image) => FileExist(image) || RegExMatch(image, 'i)^h(icon|bitmap).*\d+')

    static isValidColor(color) => this.mAHKcolors.Has(color) || color ~= 'i)^(?:0x)?[0-9A-F]{1,6}$'

    static RGB_BGR(c) => ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)

    static DpiScale(value) => (value / (A_ScreenDPI / 96))

    static MapCI() => (m := Map(), m.CaseSense := false, m)
}

/****************************************************************************************************************************************
 * @description: JSON格式字符串序列化和反序列化, 修改自[HotKeyIt/Yaml](https://github.com/HotKeyIt/Yaml)
 * 增加了对true/false/null类型的支持, 保留了数值的类型
 * @author thqby, HotKeyIt
 * @date 2024/02/24
 * @version 1.0.7
 ************************************************************************************************/
class _JSON_thqby {
	static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)

	/**
	 * Converts a AutoHotkey Object Notation JSON string into an object.
	 * @param text A valid JSON string.
	 * @param keepbooltype convert true/false/null to JSON.true / JSON.false / JSON.null where it's true, otherwise 1 / 0 / ''
	 * @param as_map object literals are converted to map, otherwise to object
	 */
	static parse(text, keepbooltype := false, as_map := true) {
		keepbooltype ? (_true := this.true, _false := this.false, _null := this.null) : (_true := true, _false := false, _null := "")
		as_map ? (map_set := (maptype := Map).Prototype.Set) : (map_set := (obj, key, val) => obj.%key% := val, maptype := Object)
		NQ := "", LF := "", LP := 0, P := "", R := ""
		D := [C := (A := InStr(text := LTrim(text, " `t`r`n"), "[") = 1) ? [] : maptype()], text := LTrim(SubStr(text, 2), " `t`r`n"), L := 1, N := 0, V := K := "", J := C, !(Q := InStr(text, '"') != 1) ? text := LTrim(text, '"') : ""
		Loop Parse text, '"' {
			Q := NQ ? 1 : !Q
			NQ := Q && RegExMatch(A_LoopField, '(^|[^\\])(\\\\)*\\$')
			if !Q {
				if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
					continue
				else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || A && RegExMatch(t, "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]")) {
					Loop Parse t {
						if N && N--
							continue
						if InStr("`n`r `t", A_LoopField)
							continue
						else if InStr("{[", A_LoopField) {
							if !A && !V
								throw Error("Malformed JSON - missing key.", 0, t)
							C := A_LoopField = "[" ? [] : maptype(), A ? D[L].Push(C) : map_set(D[L], K, C), D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
							continue
						} else if InStr("]}", A_LoopField) {
							if !A && V
								throw Error("Malformed JSON - missing value.", 0, t)
							else if L = 0
								throw Error("Malformed JSON - to many closing brackets.", 0, t)
							else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
						} else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
							if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
								if A
									C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
								else if V
									map_set(C, K, R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R), K := V := ""
								else throw Error("Malformed JSON - missing key.", 0, t)
							} else {
								; Added support for comments without '"'
								if A_LoopField == '/' {
									nt := SubStr(t, A_Index + 1, 1), N := 0
									if nt == '/' {
										if nt := InStr(t, '`n', , A_Index + 2)
											N := nt - A_Index - 1
									} else if nt == '*' {
										if nt := InStr(t, '*/', , A_Index + 2)
											N := nt + 1 - A_Index
									} else nt := 0
									if N
										continue
								}
								throw Error("Malformed JSON - unrecognized character.", 0, A_LoopField " in " t)
							}
						}
					}
				} else if A || InStr(t, ':') > 1
					throw Error("Malformed JSON - unrecognized character.", 0, SubStr(t, 1, 1) " in " t)
			} else if NQ && (P .= A_LoopField '"', 1)
				continue
			else if A
				LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
			else if V
				LF := P A_LoopField, map_set(C, K, InStr(LF, "\") ? UC(LF) : LF), K := V := P := ""
			else
				LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
		}
		return J
		UC(S, e := 1) {
			static m := Map('"', '"', "a", "`a", "b", "`b", "t", "`t", "n", "`n", "v", "`v", "f", "`f", "r", "`r")
			local v := ""
			Loop Parse S, "\"
				if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
					v .= (t := m.Get(SubStr(A_LoopField, 1, 1), 0)) ? t SubStr(A_LoopField, 2) :
						(t := RegExMatch(A_LoopField, "i)^(u[\da-f]{4}|x[\da-f]{2})\K")) ?
							Chr("0x" SubStr(A_LoopField, 2, t - 2)) SubStr(A_LoopField, t) : "\" A_LoopField,
							e := A_LoopField = "" ? e : !e
			return v
		}
	}

	/**
	 * Converts a AutoHotkey Array/Map/Object to a Object Notation JSON string.
	 * @param obj A AutoHotkey value, usually an object or array or map, to be converted.
	 * @param expandlevel The level of JSON string need to expand, by default expand all.
	 * @param space Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
	 */
	static stringify(obj, expandlevel := unset, space := "  ") {
		expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
		return Trim(CO(obj, expandlevel))
		CO(O, J := 0, R := 0, Q := 0) {
			static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ":"
			if (OT := Type(O)) = "Array" {
				D := !R ? S1 : ""
				for key, value in O {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
				}
			} else {
				D := !R ? M1 : ""
				for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
					if J = 0 && !R
						D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
				}
			}
			if J > R
				D .= "`n" CL(R + 1)
			if R = 0
				D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
			return D
		}
		ES(S) {
			switch Type(S) {
				case "Float":
					if (v := '', d := InStr(S, 'e'))
						v := SubStr(S, d), S := SubStr(S, 1, d - 1)
					if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
						S := Round(S, Max(1, d - InStr(S, ".") - 1))
					return S v
				case "Integer":
					return S
				case "String":
					S := StrReplace(S, "\", "\\")
					S := StrReplace(S, "`t", "\t")
					S := StrReplace(S, "`r", "\r")
					S := StrReplace(S, "`n", "\n")
					S := StrReplace(S, "`b", "\b")
					S := StrReplace(S, "`f", "\f")
					S := StrReplace(S, "`v", "\v")
					S := StrReplace(S, '"', '\"')
					return '"' S '"'
				default:
					return S == this.true ? "true" : S == this.false ? "false" : "null"
			}
		}
		CL(i) {
			Loop (s := "", space ? i - 1 : 0)
				s .= space
			return s
		}
	}
}
