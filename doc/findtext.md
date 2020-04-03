# FindText Interface

## Introduction

The [FindText Library](https://www.autohotkey.com/boards/viewtopic.php?p=86796#p86796) is a crucial part of the script. This toolset allows us to do the rapid searches that would otherwise be too time consuming for the fast pace of Path of Exile gameplay. This library allows for screenshots to be captured in as little as 30ms, and searches on that screenshot are nearly instantaneous. Compared to the default search method used in AHK its leagues ahead in terms of speed. The way it searches so quickly, is that it abstracts the image based on the search pattern. Then it matches the two abstractions, The ones we generate to use in the script, and the screenshot itself. This makes the search much less time consuming than actual image bit comparison, and speed is the name of the game!

When using the Capture GUI, always keep in mind of this general rule:

> The smallest search pattern which still gives a unique result is always the better one

Aim to minimize capturing the GUI elements surrounding icons, and trim off excess pixels from the results. When you use a smaller search pattern it will reduce the amount of CPU load that it requires, and it makes sure it's as fast as possible.

Give them a name when you are capturing to remember what they are! If you forget, the label can be inserted into the <>

Search patterns will look like a combination of strange symbols, but there is a simple pattern to them. The first portion is the delimiter | , then the label section wrapped in <> , the type of search style and variance , Width of the search pattern , then the string abstraction after .

```
"|<demo>*111$5.Enw"
```

And here is the abstraction of the image:

```
_0___  
_00__  
00000  
```  

We can take this string, and combine it like so:

```
"|<demo>*111$5.Enw|<demo2>*94$5.8lY"
```

now it will match if either of the patterns is found

For anyone interested in seeing what the captures look like which I have done, copy the string from the script and paste it into the Capture GUI. You can then click on the line, and it will update the display to show what the capture looks like in abstraction.

## Making a new capture
> The process of capturing an image sample is fairly straightforward. What you do with the sample is very much up to your discretion. There are several types of color or black and white abstraction.

### Gray Capture type
> Using Gray2Two it will automatically select an appropriate level of Gray Threshold, which makes this the easiest and default option. When searching for text, this is often your best choice.

### GrayDiff Capture type
> Using GrayDiff2Two will generate a more strict search pattern, but generally highlights text well. 

### Color Capture type
> Using Color2Two will generate an abstraction based on a specific color. This is based on the Similarity slider, at 100 there is no variance, at 0 it matches everything. Rule of thumb when dealing with Color type, try to keep the Similarity as high as possible.

### ColorPos Capture type
> Using ColorPos2Two will also generate an abstraction based on a specific color, similar to the standard Color capture. I am not sure what the exact differences are between these.

### ColorDiff Capture type
> Using ColorDiff2Two will also generate an abstraction based on a specific color, similar to the standard Color capture. This option allows you to select the tolerance for each individual color channel. So you can allow for higher variance only with specific Red, Green, or Blue color channels.

## Trimming the sample
> Once you have the type of abstraction selected, you will use the buttons on the left to trim off the excess area of the search pattern you are creating. It helps to do a few test runs of the abstraction results before making your final trim. This will allow you to see what the results are, and then reset back to the standard image.

when looking at the results of an abstraction, keep in mind that the dark blocks are matching and the light blocks are non-matching.

Once you have a good abstraction of the icon, the easiest is using the Auto button to trim off all excess pixels which are non-matching.

If there are stray pixels, you may need to use the "Left Right Up Down" group of buttons to trim from different sides of the sample.

Lets use the Letter R for example:

-R will undo one pixel of trim from the right side  
R will trim one pixel from the right side  
R3 will trim three pixels from the right side  

> Once you have finished trimming your sample, make sure you have given it a Comment to remember by. To add a second sample during the same capture session, use AllAdd. Otherwise click OK to continue to the main FindText interface.

## Working with a capture
> Now that you have a string which contains your search pattern, you can see the abstraction of the image on the top panel. Keep in mind you will need to scroll the viewport for large captures.

> The bottom section will contain working code that can be copied and used on its own. We will not need the full code for the script. Click Test Script to confirm your sample works, if you do not get a confirmation you may need to attempt a new sample.

Once tested and confirmed, you can move forward with using the sample in the script. Press Copy String in the top right corner to put the Search Pattern into the Clipboard. Go back to the WingmanReloaded option you were creating the capture for, and paste the string into the edit box.

### Confirming samples from the script
> You can test any strings in the WingmanReloaded settings by copying the entire contents of the string to the clipboard, then open the FindText Interface and click Test Clipboard.

## Using the ScreenShot Key
> The FindText interface provides a method of capturing a screenshot during action to use later. Double Click the yellow box to open the binding interface. Hold down the combination of keys you want to bind, then click OK to confirm. You can now MINIMIZE the window and use the key binding to take a screenshot, and use Capture from ScreenShot to use saved screen.

When you are finished, close the window, the program will close and the binding will be freed.