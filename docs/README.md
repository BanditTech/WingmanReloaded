## GraphicSearch

A fast, super powerful, and flexible alternative to AutoHotkey's ImageSearch


## What is it?

> Can be thought of as an alternative to native [AHK Imagesearch](https://autohotkey.com/docs/commands/ImageSearch.htm) function. The native function requires saved graphic files, identical image matching, is hard to troubleshoot, and performs in a relatively slow manner. GraphicSearch approaches searching differently. Think of ASCII art. GraphicSearch abstracts the screen's image into representative 0's and _'s. Because this is an abstraction, not and bit for bit comparison, it allows for faster matching and easier adjustments of fault tolerance. It can also check for several different graphics without recapturing the screen's image every time. In addition, it finds **all** instances of the graphic unlike AHK ImageSearch which only returns the first match. 


## Installation

In a terminal or command line:

```bash
npm install graphicsearch.ahk
```

In your code:

```autohotkey
#Include %A_ScriptDir%\node_modules
#Include graphicsearch.ahk\export.ahk

oGraphicSearch := new graphicsearch()
result := oGraphicSearch.search("|<HumanReadableTag>*165$22.03z")
; => [{1: 1215, 2: 407, 3: 22, 4: 10, "id": "HumanReadableTag", "x" :1226, "y" :412}, {1: 1457, 2: 815, 3: 22, 4: 10, "id": "HumanReadableTag", "x" :1468, "y" :820}]
```


## Documentation

See [**Documentation**](/documentation) for methods.

See [**Generating Queries**](/generating-queries) for turning images into GraphicSearch queries.


## Examples

In the following example, we search for an image and click on it.

```autohotkey
oGraphicSearch := new graphicsearch()

resultObj := oGraphicSearch.search("|<Pizza>*165$22.03z")
; check if any graphic was found
if (resultObj.Count()) {
    ; click on the first graphic in the object
    Click, % resultObj[1].x, resultObj[1].y
}
```

In the next example, we search for an image; if more than 4 are found, sort them by the closest to the bottom of the screen and mouseover all of them.

```autohotkey
oGraphicSearch := new graphicsearch()

resultObj := oGraphicSearch.search("|<Pizza>*165$22.03z")
; check if more than one graphic was found
if (resultObj.Count() >= 4) {
    ; sort by the closest to the bottom of the screen
    resultObj2 := oGraphicSearch.SortResult(resultObj)
    ; Mouseover each of the graphics found
    for _, object in resultObj2 {
        MouseMove, % object.x, object.y, 50
        sleep, 1000
    }
}
```

For the last example, search for two images. If found, sort them by the closest to the center of the monitor and click the 3rd one.

```autohotkey
oGraphicSearch := new graphicsearch()

resultObj := oGraphicSearch.search("|<Pizza>*165$22.03z||<spaghetti>*125$26.z")
; check if more than one graphic was found
if (resultObj.Count() >= 4) {
    ; sort by the closest to x,y point
    resultObj2 := oGraphicSearch.SortResultDistance(resultObj)
    ; Mouseover each of the graphics found
    Click, % resultObj2[3].x, resultObj2[3].y
}
```