# Main Methods

## .find
`oGraphicSearch.fisnd(x1, y1, x2, y2, err1, err2, text [, screenshot, findall, jointext, offsetx, offsety])`

OutputVarY, X1, Y1, X2, Y2, ColorID , Variation, Mode`

### Arguments
#### x1, y1                
> the search scope's upper left corner coordinates

#### x2, y2
> the search scope's lower right corner coordinates

#### err1, err0
> Fault tolerance percentage of text and background (0.1=10%)

#### text
> GraphicsSearch queries as strings. Can be multiple queries separated by `|`

#### screenshot
> if the value is 0, the last ScreenShot will be used

#### findall
> if the value is 0, Just find one result and return

#### jointext
> if the value is 1, Join all Text for combination lookup

#### offsetx, offsety
> Set the Max text offset for combination lookup


#### Return

(Array) The method returns an array of objects containing all lookup results, Any result is an associative array {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}, 
If no graphic is found, the method returns an empty array.
All coordinates are relative to Screen, colors are in RGB format, and combination lookup must use uniform color mode

#### Example

```autohotkey
oGraphicSearch.search(x1, y1, x2, y2, err1, err0, "|<tag>*165$22.03z", ScreenShot := 1, FindAll := 1, JoinText := 0, offsetX := 20, offsetY := 10)
```


## .search
functionally identicle to `.find` but uses an options object instead of many arguments

### Arguments
#### [string:=""] (string)
> The GraphicSearch string(s) to search. Must be concatinated with `|` if searching multiple graphics

#### [options:={}] (object)
> The options object

#### [options.x1:=0] (number), [options.y1:=0] (number)
> the search scope's upper left corner coordinates

#### [options.x2:=A_ScreenWidth] (number), [options.y2:=A_ScreenHeight] (number)
> the search scope's lower right corner coordinates

#### [options.err1:=1] (number), [options.err0:=0] (number)
> Fault tolerance of graphic and background (0.1=10%)

#### [options.screenshot:=1] (number)
> Wether or not to capture a new screenshot or not. If the value is 0, the last captured screenhhot will be used

#### [options.findall:=1] (number)
> Wether or not to find all instances or just one.

#### [options.joinstring:=1] (number)
> Join all Text for combination lookup.

#### [options.offsetx:=1] (number), [options.offsety:=0] (number)
> Set the Max text offset for combination lookup


#### Example
```autohotkey
optionsObj := {   "x1": 0
                , "y1": 0
                , "x2": A_ScreenWidth
                , "y2": A_ScreenHeight
                , "err1": 0
                , "err0": 0
                , "screenshot": 1
                , "findall": 1
                , "joinstring": 1
                , "offsetx": 1
                , "offsety": 1 }

oGraphicSearch.search("|<tag>*165$22.03z", optionsObj)
```

## .scan
