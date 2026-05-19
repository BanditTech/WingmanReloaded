; Source: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
; Author: feiyue

;/*
;===========================================
;  FindText - Capture screen image into text and then find it
;  https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
;
;  Author  : FeiYue
;  Version : 10.0
;  Date    : 2024-10-06
;
;  Usage:  (required AHK v2.0.2+)
;  1. Capture the image to text string.
;  2. Test find the text string on full Screen.
;  3. When test is successful, you may copy the code
;     and paste it into your own script.
;     Note: Copy the "FindText()" function and the following
;     functions and paste it into your own script Just once.
;  4. The more recommended way is to save the script as
;     "FindText.ahk" and copy it to the "Lib" subdirectory
;     of AHK program, instead of copying the "FindText()"
;     function and the following functions, add a line to
;     the beginning of your script: #Include <FindText>
;  5. If you want to call a method in the "FindTextClass" class,
;     use the parameterless FindText() to get the default object
;
;===========================================
;*/


if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
  FindText().Gui("Show")


;===== Copy The Following Functions To Your Own Code Just once =====


FindText(args*)
{
  static obj:=FindTextClass()
  return !args.Length ? obj : obj.FindText(args*)
}

Class FindTextClass
{  ;// Class Begin

Floor(i) => IsNumber(i) ? i+0 : 0

__New()
{
  this.bits:={ Scan0: 0, hBM: 0, oldzw: 0, oldzh: 0 }
  this.bind:={ id: 0, mode: 0, oldStyle: 0 }
  this.Lib:=Map()
  this.Cursor:=0
}

__Delete()
{
  if (this.bits.hBM)
    Try DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

New()
{
  return FindTextClass()
}

help()
{
return "
(
;--------------------------------
;  FindText - Capture screen image into text and then find it
;  Version : 10.0  (2024-10-06)
;--------------------------------
;  returnArray:=FindText(
;      &OutputX --> The name of the variable used to store the returned X coordinate
;    , &OutputY --> The name of the variable used to store the returned Y coordinate
;    , X1 --> the search scope's upper left corner X coordinates
;    , Y1 --> the search scope's upper left corner Y coordinates
;    , X2 --> the search scope's lower right corner X coordinates
;    , Y2 --> the search scope's lower right corner Y coordinates
;    , err1 --> Fault tolerance percentage of text       (0.1=10%)
;    , err0 --> Fault tolerance percentage of background (0.1=10%)
;      Setting err1<0 or err0<0 can enable the left and right dilation algorithm
;      to ignore slight misalignment of text lines, the fault tolerance must be very small
;      In FindPic mode, err0 can set the number of rows and columns to be skipped
;    , Text --> can be a lot of text parsed into images, separated by '|'
;    , ScreenShot --> if the value is 0, the last screenshot will be used
;    , FindAll --> if the value is 0, Just find one result and return
;    , JoinText --> if you want to combine find, it can be 1, or an array of words to find
;    , offsetX --> Set the max text offset (X) for combination lookup
;    , offsetY --> Set the max text offset (Y) for combination lookup
;    , dir --> Nine directions for searching: up, down, left, right and center
;      Default dir=0, the returned result will be sorted by the smallest error,
;      Even if set a large fault tolerance, the first result still has the smallest error
;    , zoomW --> Zoom percentage of image width  (1.0=100%)
;    , zoomH --> Zoom percentage of image height (1.0=100%)
;  )
;
;  The function returns an Array containing all lookup results,
;  any result is a object with the following values:
;  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
;  If no image is found, the function returns 0.
;  All coordinates are relative to Screen, colors are in RGB format
;  All 'RRGGBB' can use 'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow'
;  All 'DRDGDB' can use similarity '1.0'(100%), it's floating-point number
;
;  If the return variable is set to 'ok', ok[1] is the first result found.
;  ok[1].1, ok[1].2 is the X, Y coordinate of the upper left corner of the found image,
;  ok[1].3, ok[1].4 is the width, height of the found image,
;  ok[1].x <==> ok[1].1+ok[1].3//2 ( is the Center X coordinate of the found image ),
;  ok[1].y <==> ok[1].2+ok[1].4//2 ( is the Center Y coordinate of the found image ),
;  ok[1].id is the comment text, which is included in the <> of its parameter.
;
;  If OutputX is equal to 'wait' or 'wait1'(appear), or 'wait0'(disappear)
;  it means using a loop to wait for the image to appear or disappear.
;  the OutputY is the wait time in seconds, time less than 0 means infinite waiting
;  Timeout means failure, return 0, and return other values means success
;  If you want to appear and the image is found, return the found array object
;  If you want to disappear and the image cannot be found, return 1
;  Example 1: FindText(&X:='wait', &Y:=3, 0,0,0,0,0,0,Text)   ; Wait 3 seconds for appear
;  Example 2: FindText(&X:='wait0', &Y:=-1, 0,0,0,0,0,0,Text) ; Wait indefinitely for disappear
;
;  <FindMultiColor> or <FindColor> : FindColor is FindMultiColor with only one point
;  Text:='|<>##DRDGDB $ 0/0/RRGGBB1-DRDGDB1/RRGGBB2, xn/yn/-RRGGBB3/RRGGBB4, ...'
;  Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
;  Initial point (0,0) match 0xRRGGBB1(+/-0xDRDGDB1) or 0xRRGGBB2(+/-0xDRDGDB),
;  point (xn,yn) match not 0xRRGGBB3(+/-0xDRDGDB) and not 0xRRGGBB4(+/-0xDRDGDB)
;  Starting with '-' after a point coordinate means excluding all subsequent colors
;  Each point can take up to 10 sets of colors (xn/yn/RRGGBB1/.../RRGGBB10)
;
;  <FindShape> : Similar to FindMultiColor, just replacing the color with
;  whether the point is similar in color to the first point
;  Text:='|<>##DRDGDB $ 0/0/1, x1/y1/0, x2/y2/1, xn/yn/0, ...'
;
;  <FindPic> : Text parameter require manual input
;  Text:='|<>##DRDGDB/RRGGBB1-DRDGDB1/RRGGBB2... $ d:\a.bmp'
;  Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
;  the 0xRRGGBB1(+/-0xDRDGDB1) and 0xRRGGBB2(+/-0xDRDGDB) both transparent colors
;
;--------------------------------
)"
}

FindText(&OutputX:="", &OutputY:=""
  , x1:=0, y1:=0, x2:=0, y2:=0, err1:=0, err0:=0, text:=""
  , ScreenShot:=1, FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10
  , dir:=0, zoomW:=1, zoomH:=1)
{
  if IsSet(OutputX) && (OutputX ~= "i)^\s*wait[10]?\s*$")
  {
    found:=!InStr(OutputX, "0"), time:=this.Floor(OutputY ?? 0)
    , timeout:=A_TickCount+Round(time*1000), OutputX:=""
    Loop
    {
      ok:=this.FindText(,, x1, y1, x2, y2, err1, err0, text, ScreenShot
        , FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH)
      if (found && ok)
      {
        OutputX:=ok[1].x, OutputY:=ok[1].y
        return ok
      }
      if (!found && !ok)
        return 1
      if (time>=0 && A_TickCount>=timeout)
        Break
      Sleep 50
    }
    return 0
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  , this.ok:=0, info:=[]
  Loop Parse, text, "|"
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 || h<1 || !(num:=info.Length) || !bits.Scan0)
  {
    return 0
  }
  arr:=[], info2:=Map(), k:=0, s:=""
  , mode:=(IsObject(JoinText) ? 2 : JoinText ? 1 : 0)
  For i,j in info
  {
    k:=Max(k, (j[7]=5 && j[8]!=2 ? j[9] : j[2]*j[3]))
    if (mode)
      v:=(mode=1 ? i : j[10]) . "", s.="|" v
      , (v!="") && ((!info2.Has(v) && info2[v]:=[]), info2[v].Push(j))
  }
  sx:=x, sy:=y, sw:=w, sh:=h, (mode=1 && JoinText:=[s])
  , allpos_max:=(FindAll || JoinText ? 10000:1)
  , s1:=Buffer(k*4), s0:=Buffer(k*4)
  , ss:=Buffer(sw*(sh+3)), allpos:=Buffer(allpos_max*8)
  , ini:={ sx:sx, sy:sy, sw:sw, sh:sh, zx:zx, zy:zy
  , mode:mode, bits:bits, ss:ss.Ptr, s1:s1.Ptr, s0:s0.Ptr
  , allpos:allpos.Ptr, allpos_max:allpos_max
  , err1:err1, err0:err0, zoomW:zoomW, zoomH:zoomH }
  Loop 2
  {
    if (err1=0 && err0=0) && (num>1 || A_Index>1)
      ini.err1:=err1:=0.05, ini.err0:=err0:=0.05
    if (!JoinText)
    {
      For i,j in info
      Loop this.PicFind(ini, j, dir, sx, sy, sw, sh)
      {
        v:=NumGet(allpos,4*A_Index-4,"uint"), x:=(v&0xFFFF)+zx, y:=(v>>16)+zy
        , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
        , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:j[10]})
        if (!FindAll)
          Break 3
      }
    }
    else
    For k,v in JoinText
    {
      v:=StrSplit(Trim(RegExReplace(v, "\s*\|[|\s]*", "|"), "|")
      , (InStr(v,"|")?"|":""), " `t")
      , this.JoinText(arr, ini, info2, v, 1, offsetX, offsetY
      , FindAll, dir, 0, 0, 0, sx, sy, sw, sh)
      if (!FindAll && arr.Length)
        Break 2
    }
    if (err1!=0 || err0!=0 || arr.Length || info[1][4] || info[1][7]=5)
      Break
  }
  if (arr.Length)
  {
    OutputX:=arr[1].x, OutputY:=arr[1].y, this.ok:=arr
    return arr
  }
  return 0
}

; the join text object use [ "abc", "xyz", "a1|a2|a3" ]

JoinText(arr, ini, info2, text, index, offsetX, offsetY
  , FindAll, dir, minX, minY, maxY, sx, sy, sw, sh)
{
  if !(Len:=text.Length) || !info2.Has(key:=text[index])
    return 0
  zoomW:=ini.zoomW, zoomH:=ini.zoomH, mode:=ini.mode
  For i,j in info2[key]
  if (mode!=2 || key==j[10])
  Loop ok:=this.PicFind(ini, j, dir, sx, sy, (index=1 ? sw
  : Min(sx+offsetX+Floor(j[2]*zoomW),ini.sx+ini.sw)-sx), sh)
  {
    if (A_Index=1)
    {
      pos:=[], p:=ini.allpos-4
      Loop ok
        pos.Push(NumGet(p+=4,"uint"))
    }
    v:=pos[A_Index], x:=v&0xFFFF, y:=v>>16
    , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
    , (index=1 && (minX:=x, minY:=y, maxY:=y+h))
    , minY1:=Min(y, minY), maxY1:=Max(y+h, maxY), sx1:=x+w
    if (index<Len)
    {
      sy1:=Max(minY1-offsetY, ini.sy)
      , sh1:=Min(maxY1+offsetY, ini.sy+ini.sh)-sy1
      if this.JoinText(arr, ini, info2, text, index+1, offsetX, offsetY
      , FindAll, 5, minX, minY1, maxY1, sx1, sy1, 0, sh1)
      && (index>1 || !FindAll)
        return 1
    }
    else
    {
      comment:=""
      For k,v in text
        comment.=(mode=2 ? v : info2[v][1][10])
      x:=minX+ini.zx, y:=minY1+ini.zy, w:=sx1-minX, h:=maxY1-minY1
      , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
      if (index>1 || !FindAll)
        return 1
    }
  }
  return 0
}

PicFind(ini, j, dir, sx, sy, sw, sh)
{
  static MyFunc:=""
  if (!MyFunc)
  {
    x32:="VVdWU4HsmAAAAIuEJNQAAAADhCTMAAAAi5wk@AAAAIO8JKwAAAAFiUQkIIuEJPgA"
    . "AACNBJiJRCQ0D4RKBgAAi4Qk6AAAAIXAD45ADwAAiXwkEIu8JOQAAAAx7ccEJAAA"
    . "AADHRCQIAAAAAMdEJBQAAAAAx0QkDAAAAACNtgAAAACLhCTgAAAAi0wkDDH2MdsB"
    . "yIX@iUQkBH896ZAAAABmkA+vhCTMAAAAicGJ8Jn3@wHBi0QkBIA8GDF0TIuEJNwA"
    . "AACDwwEDtCQAAQAAiQyog8UBOd90VIsEJJn3vCToAAAAg7wkrAAAAAR1tQ+vhCTA"
    . "AAAAicGJ8Jn3@40MgYtEJASAPBgxdbSLRCQUi5Qk2AAAAIPDAQO0JAABAACJDIKD"
    . "wAE534lEJBR1rAF8JAyDRCQIAYu0JAQBAACLRCQIATQkOYQk6AAAAA+FMv@@@4tE"
    . "JBSLfCQQD6+EJOwAAACJbCQwwfgKiUQkKIuEJPAAAAAPr8XB+AqJRCRAg7wkrAAA"
    . "AAQPhCIGAACLhCTAAAAAi5wkxAAAAA+vhCTIAAAAjSyYi4QkzAAAAIucJMAAAAD3"
    . "2IO8JKwAAAABjQSDiUQkLA+ELwYAAIO8JKwAAAACD4Q4CAAAg7wkrAAAAAMPhLkL"
    . "AACLjCTQAAAAhckPjicBAACLhCTMAAAAi6wkzAAAAMdEJAwAAAAAx0QkEAAAAACJ"
    . "fCQYg+gBiUQkCI22AAAAAIt8JBCLtCTUAAAAMcCLXCQgAfsB94Xtif6J738X6bwA"
    . "AADGBAYEg8ABg8MBOccPhKQAAACDvCSsAAAAA3@khcAPtgsPhLoPAAAPtlP@iVQk"
    . "BDlEJAgPhMIPAAAPtlMBiRQki5Qk9AAAAIXSD4SfAQAAD7bpugYAAACD7QGD@QF2"
    . "G4N8JAQBD5TCgzwkAYnVD5TCCeoPttIB0oPKBIHh@QAAAL0BAAAAdByLTCQEiywk"
    . "hckPlEQkBIXtD5TBic0PtkwkBAnNCeqDwwGIFAaDwAE5xw+FXP@@@wF8JBCJ@YNE"
    . "JAwBi0QkDDmEJNAAAAAPjwz@@@+LfCQYg7wkrAAAAAN@FouEJPQAAACFwA+VwDwB"
    . "g5wkxAAAAP+LXCQUi3QkKDHAOfOLdCRAD07YiVwkFItcJDA58w9Pw4lEJDCLhCTM"
    . "AAAAK4QkAAEAAIlEJASLhCTQAAAAK4QkBAEAAIO8JLgAAAAJiUQkCA+ExgAAAIuE"
    . "JLgAAACD6AGD+AcPh7wCAACD+AOJRCQkD463AgAAi0QkBMdEJEQAAAAAx0QkDAAA"
    . "AACJBCSLRCQIiUQkHItcJEQ5HCTHRCRMAAAAAA+MCwEAAItcJEw5XCQcD4zCDQAA"
    . "i3QkRItcJCSLBCQp8PbDAg9Exot0JEyJwotEJBwp8PbDAQ9ExoP7A4nWD0@wD0@C"
    . "iXQkGIlEJBDp3gsAAI12AA+20YPqAYP6AhnSg+ICg8IEgeH9AAAAD5TBCcqIFAbp"
    . "8v3@@4tcJASLdCQIx0QkZAAAAADHRCRgAQAAAMdEJFQAAAAAx0QkWAAAAACJ2I1W"
    . "AYk0JMHoH4lcJBzHRCQMAAAAAAHY0fiJRCQQifDB6B8B8NH4iUQkGInYg8ABicEP"
    . "r8o50A9MwoPACIlMJHyJwQ+vyImMJIAAAACLXCR8OVwkZH0Zi5wkgAAAADlcJFjH"
    . "RCRcAAAAAA+M9QQAAIuMJLgAAACFyQ+FnQIAAIuUJPgAAACF0g+EjgIAAIuEJAQB"
    . "AAAPr4QkAAEAAIP4AQ+EdgIAAIN8JAwBD46lCgAAi0QkNIucJPgAAAAx7cdEJAQA"
    . "AAAAiSwkjXgEi0QkDIPoAYlEJBCLRCQEiwwkizeLRAMEhcmJRCQIich4NotP@DnO"
    . "D4N1BQAAifqNa@zrDY12AIPqBItK@DnOcxeJCotMhQSJTIMEg+gBg@j@deS4@@@@"
    . "@4tMJDSDwAGDBCQBg8cEg0QkBASJNIGLdCQIiTSDiwQkO0QkEHWNi4QkBAEAAIus"
    . "JAABAAAPr8APr+2JRCQEi7Qk+AAAAMdEJAgAAAAAMduLRCQIiwSGiUQkEA+3+MHo"
    . "EIXbiQQkdC0xyY22AAAAAIsUjg+3win4D6@AOeh9D8HqECsUJA+v0jtUJAR8EYPB"
    . "ATnZdduLRCQQiQSeg8MBg0QkCAGLRCQIOUQkDHWiidiBxJgAAABbXl9dwlwAx0Qk"
    . "JAAAAACLRCQIx0QkRAAAAADHRCQMAAAAAIkEJItEJASJRCQc6UT9@@8xwIO8JLAA"
    . "AAACD5TAiYQkhAAAAA+EUAQAADHAg7wksAAAAAGLrCS0AAAAD5TAhe2JRCR4D4SG"
    . "CwAAi7Qk2AAAAIuUJLQAAAAx7YucJOAAAACLjCTcAAAAiXwkCI0ElolEJASNdCYA"
    . "izuDxgSDw1iDwQSJ+MHoEA+vhCQEAQAAmfe8JOgAAAAPr4QkwAAAAIkEJA+3xw+v"
    . "hCQAAQAAmfe8JOQAAACLFCSNBIKJRvyLQ6yNREUAg8UWiUH8O3QkBHWmi4QktAAA"
    . "AIm8JLAAAACLfCQIiUQkFIuEJOwAAAAPr4QktAAAAMH4ColEJCiLhCTgAAAAx0Qk"
    . "QAAAAADHRCQwAAAAAIPACIlEJFDpSfr@@4tEJAyBxJgAAABbXl9dwlwAi4QksAAA"
    . "AMHoEA+vhCQEAQAAmfe8JOgAAAAPr4QkwAAAAInBD7eEJLAAAAAPr4QkAAEAAJn3"
    . "vCTkAAAAjQSBiYQksAAAAOnt+f@@i4Qk6AAAAIu0JNAAAAAPr4Qk5AAAANGkJLQA"
    . "AAADhCTgAAAAhfaJRCRQD47z+v@@i4QkzAAAAInqi2wkUMdEJCQAAAAAx0QkOAAA"
    . "AADB4AKJRCRIMcCLnCTMAAAAhdsPjisBAACLnCS8AAAAAdMDVCRIiVwkEItcJCAD"
    . "XCQ4iVQkPAOUJLwAAACJXCQYiVQkHI12AI28JwAAAACLdCQQMds5nCS0AAAAD7ZO"
    . "AolMJAQPtk4BD7Y2iUwkCIl0JAx2W412AI28JwAAAACLRJ0Ag8MCi3yd@InCD7bM"
    . "D7bAK0QkDMHqECtMJAgPttIrVCQEgf@@@@8AiQQkdyUPr9IPr8mNFFIPr8CNFIqN"
    . "BEI5x3NGMcA5nCS0AAAAd6+JwutBif7B7hCJ8A+28A+v0g+v9jnyd92J+A+21A+v"
    . "yQ+v0jnRd86LNCSJ+A+20A+v0onwD6@GOdB3uroBAAAAuAEAAACLXCQYg0QkEASL"
    . "TCQQiBODwwE7TCQciVwkGA+FGv@@@4u0JMwAAAABdCQ4i1QkPINEJCQBA1QkLItc"
    . "JCQ5nCTQAAAAD4Ws@v@@6U34@@+LRCQQhcB4G4tcJBw52H8Ti0QkGIXAeAuLHCQ5"
    . "2A+ONwYAAItsJFSF7Q+F4AUAAINsJBgBg0QkXAGDRCRYAYt0JGA5dCRcfLiLXCRU"
    . "idiD4AEBxonYg8ABiXQkYIPgA4lEJFTpvvr@@4uEJLAAAACLjCTQAAAAxwQkAAAA"
    . "AMdEJAQAAAAAg8ABweAHiYQksAAAAIuEJMwAAADB4AKFyYlEJAwPjsz4@@+J6Ius"
    . "JLAAAACJfCQQi5QkzAAAAIXSfmaLjCS8AAAAi1wkIIu8JLwAAAADXCQEAcEDRCQM"
    . "iUQkCAHHjXYAjbwnAAAAAA+2UQIPtkEBD7Yxa8BLa9ImAcKJ8MHgBCnwAdA5xQ+X"
    . "A4PBBIPDATn5ddWLnCTMAAAAAVwkBItEJAiDBCQBA0QkLIs8JDm8JNAAAAAPhXf@"
    . "@@+LfCQQ6Qb3@@+LBCTprvr@@4uEJOgAAACLvCTgAAAAD6+EJOQAAADRpCS0AAAA"
    . "jQSHiUQkUIuEJPAAAADB+AqDwAGJRCQki4Qk6AAAAIXAD45ECgAAi3wkJIuEJAQB"
    . "AACLdCRQx0QkMAAAAADHRCQUAAAAAA+vx4lEJECLhCTkAAAAD6@HweACiUQkSIuE"
    . "JOAAAACDwAKJRCQ4ifiNPL0AAAAAiXwkLInHD6+EJAABAACJfCQ8iUQkKIuEJOQA"
    . "AACFwA+OaQEAAItEJDjHRCQcAAAAAIlEJBCLRCQkiUQkGItEJBC7AgAAAA+2OIk8"
    . "JA+2eP8PtkD+iXwkBIlEJAg5nCS0AAAAD4bCAAAAiwSeg8MCi3ye@InCD7bMD7bA"
    . "K0QkCMHqECtMJAQPttIrFCSB@@@@@wCJRCQMd0YPr9IPr8mNFFIPr8CNFIqNBEI5"
    . "x3Kui3wkGItEJCSLTCQsAUwkEItMJCgBTCQcAfg5vCTkAAAAD465AAAAiUQkGOlf"
    . "@@@@if3B7RCJ6A+26A+v0g+v7TnqD4dm@@@@ifgPttQPr8kPr9I50Q+HU@@@@4tM"
    . "JAyJ+A+2+A+v@4nID6@BOfh2kDmcJLQAAAAPhz7@@@+LRCQwi3wkFJmNHL0AAAAA"
    . "97wk6AAAAA+vhCTAAAAAicGLRCQcmfe8JOQAAACLFCTB4hCNBIGLjCTYAAAAiQS5"
    . "i0QkBIPHAYl8JBSLvCTcAAAAweAICdALRCQIiQQf6SD@@@+LfCQ8i0QkJItMJEAB"
    . "TCQwi0wkSAFMJDgB+Dm8JOgAAAB+CYlEJDzpXP7@@4tEJBQPr4Qk7AAAAMH4ColE"
    . "JCiLRCRQx0QkQAAAAADHRCQwAAAAAIt4BIn4ifvB6BAPtteJ+w+2wA+2y4nDD6@Y"
    . "idAPr8KJXCRwiUQkdInID6@BiUQkbOlH9P@@i4Qk0AAAAIXAD45u9f@@i5wkzAAA"
    . "AItEJCDHBCQAAAAAx0QkBAAAAACJfCQMjQRYiUQkGInYweACiUQkCIu0JMwAAACF"
    . "9n5Xi4wkvAAAAItcJBiLvCS8AAAAA1wkBAHpA2wkCAHvD7ZRAoPBBIPDAWvyJg+2"
    . "Uf1rwkuNFAYPtnH8ifDB4AQp8AHQwfgHiEP@Ofl10ou8JMwAAAABfCQEgwQkAQNs"
    . "JCyLBCQ5hCTQAAAAdYqLhCTMAAAAi3wkDDHti5QktAAAADH2g+gBiXwkJIlEJAyL"
    . "hCTQAAAAg+gBiUQkEIucJMwAAACF2w+O4gAAAIu8JMwAAACLRCQYAfeNDDCJ+4l8"
    . "JByJxwHfifMrnCTMAAAAiXwkBIt8JCABwwH3McCJfCQIiRwkhcAPhGQDAAA5RCQM"
    . "D4RaAwAAhe0PhFIDAAA5bCQQD4RIAwAAD7YRD7Z5@74BAAAAA5QksAAAADn6ckYP"
    . "tnkBOfpyPos8JA+2Pzn6cjSLXCQED7Y7OfpyKYs8JA+2f@85+nIeizwkD7Z@ATn6"
    . "chMPtnv@OfpyCw+2cwE58g+Sw4nei3wkCInziBwHg8ABg8EBg0QkBAGDBCQBOYQk"
    . "zAAAAA+FWv@@@4t0JByDxQE5rCTQAAAAD4X@@v@@i3wkJImUJLQAAADpY@L@@8dE"
    . "JEAAAAAAx0QkKAAAAADHRCQwAAAAAMdEJBQAAAAA6cfx@@+DfCRUAQ+E6gEAAIN8"
    . "JFQCD4SVAgAAg2wkEAHpBfr@@4uEJAQBAACLrCQAAQAAD6@AD6@tiUQkBItEJAyF"
    . "wA+P6PX@@zHA6VL2@@+DRCRkAcdEJCQJAAAAi0QkGIucJNQAAAAPr4QkzAAAAANE"
    . "JBCAPAMDD4ZnAQAAi3QkFItcJDA53g9N3oO8JKwAAAADiVwkIA+OdQEAAItEJBgD"
    . "hCTIAAAAD6+EJMAAAACLVCQQA5QkxAAAAIO8JKwAAAAFD4RsAgAAjTSQi4QksAAA"
    . "AIucJLwAAAAB8A+2XAMCiVwkOIucJLwAAAAPtlwDAYlcJDyLnCS8AAAAD7YEA4lE"
    . "JEiLRCQghcAPhKoBAACLRCRAiXwkLDHbi2wkKIu8JLwAAACJRCRo62KNtCYAAAAA"
    . "OVwkMH5Ii4Qk3AAAAIsUmAHyD7ZEFwIPtkwXAStEJDgrTCQ8D7YUFytUJEgPr8AP"
    . "r8mNBEAPr9KNBIiNBFA5hCS0AAAAcgeDbCRoAXhhg8MBOVwkIA+EogEAADlcJBR+"
    . "n4uEJNgAAACLFJgB8g+2RBcCD7ZMFwErRCQ4K0wkPA+2FBcrVCRID6@AD6@JjQRA"
    . "D6@SjQSIjQRQOYQktAAAAA+DWv@@@4PtAQ+JUf@@@4t8JCyDfCQkCQ+EKfj@@4NE"
    . "JEwB6Try@@+DRCQQAekm+P@@g0QkRAHpEfL@@410JgCF2w+EoAAAAAOEJNQAAACL"
    . "XCRAMdKLbCQoicHrJTlUJDB+Fou0JNwAAACLBJYByPYAAXUFg+sBeJqDwgE5VCQg"
    . "dGo5VCQUftWLtCTYAAAAiwSWAcj2AAJ1xIPtAXm@6XD@@@@HRCQEAwAAAOlB8P@@"
    . "i3wkCMYEBwLpEf3@@8cEJAMAAADpOfD@@8dEJCgAAAAAx0QkFAAAAADpGPX@@4NE"
    . "JBgB6XD3@@+LbCQoi4Qk+AAAAINEJAwBhcAPhMoDAACLVCQYA5QkyAAAAItcJAyL"
    . "RCQQA4QkxAAAAIu0JPgAAADB4hCNi@@@@z8J0IkEjou0JLgAAACF9g+F0gIAAItE"
    . "JCiLdCQ0Keg5nCT8AAAAiQSOD44z8v@@6bb+@@+LfCQs64mLtCSEAAAAjQSQiUQk"
    . "PIX2D4WuAQAAi1wkIItEJFAx9otsJCiF24lEJGgPhFn@@@+LhCTYAAAAi1wkaItU"
    . "JDwDFLCJXCRIa8YWgTv@@@8AiUQkOA+XwA+2wIlEJCyLhCTcAAAAiwSwiYQktAAA"
    . "AIuEJLwAAAAPtkQQAomEJIwAAADB4BCJwYuEJLwAAAAPtkQQAYmEJJAAAADB4AgJ"
    . "yIuMJLwAAAAPtgwRCciJjCSUAAAAiYQkiAAAAOsfD6@SD6@JjRRSD6@AjRSKjQRC"
    . "OccPg70AAACDRCRICItEJDg7hCS0AAAAD4PPAAAAi1QkeIt8JEiDRCQ4AoXSiweL"
    . "fwR0JoX2i5wkiAAAAA9FnCSwAAAAhcAPlMAPtsCJRCQsiZwksAAAAInYicIPtswP"
    . "tsDB6hArjCSQAAAAK4QklAAAAA+20iuUJIwAAACB@@@@@wAPhmX@@@+J+8HrEA+2"
    . "2w+v0g+v2znaD4dp@@@@ifsPttcPr8kPr9I50Q+HVv@@@4n7D7bTD6@AD6@SOdAP"
    . "h0P@@@+LRCQshcB0CYPtAQ+IDf3@@4PGAYNEJGhYOXQkIA+Fe@7@@+nP@f@@i0Qk"
    . "LIXAdeHr1otMJCCLbCQohckPhLX9@@8x9usuOUQkcHwSD6@JOUwkdHwJD6@SOVQk"
    . "bH0Jg+0BD4i3@P@@g8YBOXQkIA+Eg@3@@4uEJNgAAACLVCQ8i5wkvAAAAAMUsIuE"
    . "JNwAAACLBLCJhCSwAAAAi4QkvAAAAIuMJLAAAAAPtkQQAsHpEA+2ySnID7ZMEwGL"
    . "nCSwAAAAD6@AD7bfKdmLnCS8AAAAD7YUEw+2nCSwAAAAKdqB@@@@@wAPh1z@@@8P"
    . "r8mNBEAPr9KNBIiNBFA5xw+CXf@@@+lh@@@@x0QkKAAAAADHRCQUAAAAAOnC9@@@"
    . "i1wkDDmcJPwAAACJ2A+OrfD@@4tcJBgxyYnOidgrhCQEAQAAg8ABD0jBicKJ2Iuc"
    . "JAQBAACNRBj@i1wkCDnDD07Di1wkEInFidgrhCQAAQAAg8ABD0nwidiLnCQAAQAA"
    . "jUQY@4tcJAQ5ww9OwznVicMPjIz7@@+LhCTMAAAAg8UBD6@CA4Qk1AAAAInBjUMB"
    . "iUQkIDnefw+J8IAkAQODwAE7RCQgdfODwgEDjCTMAAAAOep13+lJ+@@@i6wkuAAA"
    . "AIXtD4VK@@@@6TX7@@+QkA=="
    x64:="QVdBVkFVQVRVV1ZTSIHsyAAAAEhjhCRQAQAASIu8JKgBAACJjCQQAQAAiVQkMESJ"
    . "jCQoAQAAi7QkgAEAAIusJIgBAABJicRIiUQkWEgDhCRgAQAAg@kFSIlEJChIY4Qk"
    . "sAEAAEiNBIdIiUQkYA+E3AUAAIXtD44BDAAARTH2iVwkEIu8JLgBAABEiXQkCIuc"
    . "JBABAABFMe1Mi7QkcAEAAEUx20Ux@0SJbCQYRImEJCABAABMY1QkCEUxyUUxwEwD"
    . "lCR4AQAAhfZ@Mut3Dx9AAEEPr8SJwUSJyJn3@gHBQ4A8AjF0PEmDwAFJY8dBAflB"
    . "g8cBRDnGQYkMhn5DRInYmff9g@sEdckPr4QkOAEAAInBRInImff+Q4A8AjGNDIF1"
    . "xEiLlCRoAQAASYPAAUljxUEB+UGDxQFEOcaJDIJ@vQF0JAiDRCQYAUQDnCTAAQAA"
    . "i0QkGDnFD4VX@@@@RInoi1wkEESLhCQgAQAAD6+EJJABAABEiWwkGMH4ColEJByL"
    . "hCSYAQAAQQ+vx8H4ColEJECDvCQQAQAABA+EtwUAAIuEJDgBAACLvCRAAQAAD6+E"
    . "JEgBAACNBLiLvCQ4AQAAiUQkCESJ4PfYg7wkEAEAAAGNBIeJRCQgD4SxBQAAg7wk"
    . "EAEAAAIPhIQHAACDvCQQAQAAAw+EowoAAIuEJFgBAACFwA+OHwEAAESJfCQQRIuc"
    . "JBABAABBjWwk@0yLfCQoi7wkoAEAAEUx9kUx7YlcJAhEiYQkIAEAAA8fhAAAAAAA"
    . "RYXkD467AAAASWPFMclJicFNjUQHAUwDjCRgAQAA6xhBxgEEg8EBSYPBAUmDwAFB"
    . "OcwPhIkAAABBg@sDf+KFyUEPtlD@D4S1DgAAQQ+2WP45zQ+Euw4AAEUPthCF@w+E"
    . "fAEAAA+28rgGAAAAg+4Bg@4BdhiD+wFAD5TGQYP6AQ+UwAnwD7bAAcCDyASB4v0A"
    . "AAC+AQAAAHQOhdtAD5TGRYXSD5TCCdYJ8IPBAUmDwQFBiEH@SYPAAUE5zA+Fd@@@"
    . "@0UB5UGDxgFEObQkWAEAAA+PKv@@@4tcJAhEi3wkEESLhCQgAQAAg7wkEAEAAAN@"
    . "FouEJKABAACFwA+VwDwBg5wkQAEAAP+LfCQYi3QkHDHARInlRIucJFgBAAA59w9O"
    . "+EQ7fCRAiXwkGEQPTvgrrCS4AQAARCucJMABAACDvCQoAQAACQ+EuQAAAIuEJCgB"
    . "AACD6AGD+AcPh5ACAACD+AOJRCRID46LAgAAiWwkCESJXCQQRTH2x0QkTAAAAACL"
    . "fCRMOXwkCMdEJGgAAAAAD4wNAQAAi3wkaDl8JBAPjNIMAACLfCRIi3QkTItEJAgp"
    . "8ED2xwIPRMaLdCRoicKLRCQQKfBA9scBD0TGg@8DidcPT@gPT8JBicXptgoAAGaQ"
    . "D7bCg+gBg@gCGcCD4AKDwASB4v0AAAAPlMIJ0EGIAekg@v@@iehBjVMBRIlcJAjB"
    . "6B+JbCQQx4QkiAAAAAAAAAAB6MeEJIQAAAABAAAAx0QkbAAAAADR+MdEJHwAAAAA"
    . "QYnFRInYwegfRAHY0fiJx41FAYnGD6@yOdAPTMJFMfaDwAiJtCSkAAAAicYPr@CJ"
    . "tCSoAAAAi7QkpAAAADm0JIgAAAB9HIu0JKgAAAA5dCR8x4QkgAAAAAAAAAAPjEYE"
    . "AACLhCQoAQAAhcAPhV0CAABIg7wkqAEAAAAPhE4CAACLhCTAAQAAD6+EJLgBAACD"
    . "+AEPhDYCAABBg@4BD45dCQAAQY1G@kyLRCRgTIucJKgBAABFMclFMdJIjRyFBAAA"
    . "AEOLdAgEQ4sUCESJ0UOLfAsETInQOdZyE+kJBAAAZpBIg+gBQYsUgDnWcx1BiVSA"
    . "BEGLFIOD6QGD+f9BiVSDBHXeSMfA@@@@@0mDwQRIg8ABSYPCAUk52UGJNIBBiTyD"
    . "dZ9Ei5QkuAEAAIucJMABAABFD6@SD6@bTIuMJKgBAAAx9jHAQYsssYnvRA+33cHv"
    . "EIXAdDJFMcAPH4QAAAAAAEOLDIEPt9FEKdoPr9JEOdJ9DMHpECn5D6@JOdl8E0mD"
    . "wAFEOcB@2Uhj0IPAAUGJLJFIg8YBQTn2f6pIgcTIAAAAW15fXUFcQV1BXkFfw8dE"
    . "JEgAAAAARIlcJAiJbCQQRTH2x0QkTAAAAADpcP3@@4tEJDAx@4P4AkAPlMeJvCSs"
    . "AAAAD4SpAwAAMcCDfCQwAQ+UwEWFwImEJKAAAAAPhNsKAABEiaQkUAEAAEyLlCR4"
    . "AQAARTHJi7wkOAEAAEyLpCRoAQAARTHbTIusJHABAABEi7QkuAEAAESLvCTAAQAA"
    . "iVwkGEGLGkmDwliJ2MHoEEEPr8eZ9@0Pr8eJwQ+3w0EPr8aZ9@6NBIFDiQSMQYtC"
    . "rEGNBENBg8MWQ4lEjQBJg8EBRTnId72LhCSQAQAARIukJFABAACJXCQwi1wkGESJ"
    . "RCQYQQ+vwMH4ColEJBxIi4QkeAEAAMdEJEAAAAAARTH@SIPACEiJBCTpq@r@@0SJ"
    . "8OnE@v@@i3wkMIn4wegQD6+EJMABAACZ9@0Pr4QkOAEAAInBD7fHD6+EJLgBAACZ"
    . "9@6NBIGJRCQw6Wv6@@+J6ESLjCRYAQAARQHAD6@GSJhIA4QkeAEAAEWFyUiJBCQP"
    . "jnL7@@9CjTylAAAAAMdEJBAAAAAAMcDHRCRIAAAAAESJfCR4iXwkUEWF5A+O6QAA"
    . "AEhjVCQISIu8JDABAABFMe1MY3QkSEwDdCQoSI1sFwJMiwwkRTHSD7Z9AA+2df9E"
    . "D7Zd@usmZi4PH4QAAAAAAA+vyQ+v0o0MSQ+vwI0UkY0EQjnDc2hJg8EIMcBFOcIP"
    . "gxsBAABBiwFBi1kEQYPCAonBD7bUD7bAwekQKfJEKdgPtskp+YH7@@@@AHazQYnf"
    . "QcHvEEUPtv8Pr8lFD6@@RDn5d7IPts8Pr9IPr8k5ynelD7bTD6@AD6@SOdB3mLoB"
    . "AAAAuAEAAABDiBQuSYPFAUiDxQRFOewPj0P@@@+LdCRQRAFkJEgBdCQIg0QkEAGL"
    . "VCQgi3wkEAFUJAg5vCRYAQAAD4Xw@v@@RIt8JHjpFvn@@0WF7XgVRDtsJBB@DoX@"
    . "eAo7fCQID464BQAAi0QkbIXAD4WNBQAAg+8Bg4QkgAAAAAGDRCR8AYuUJIQAAAA5"
    . "lCSAAAAAfLqLdCRsifCD4AEBwonwg8ABiZQkhAAAAIPgA4lEJGzpW@v@@w8fRAAA"
    . "icLpQf@@@0yJ0Oka@P@@i0QkMIuMJFgBAAAx9jH@Qo0spQAAAACDwAHB4AeFyYlE"
    . "JDAPjo@5@@9Ei3QkCESLbCQwRYXkflVIi5QkMAEAAExj30wDXCQoSWPGRTHJSI1M"
    . "AgIPthEPtkH@RA+2Uf5rwEtr0iYBwkSJ0MHgBEQp0AHQQTnFQw+XBAtJg8EBSIPB"
    . "BEU5zH@MQQHuRAHng8YBRAN0JCA5tCRYAQAAdZXp9vf@@4noRQHAD6@GweACSJhI"
    . "A4QkeAEAAEiJBCSLhCSYAQAAwfgKg8ABhe2JRCQID46VCgAAi3wkCIuEJMABAADH"
    . "RCRIAAAAAMdEJBgAAAAARImkJFABAACJrCSIAQAAD6@HiXwkUIlEJHiJ+A+vxsHg"
    . "AkiYSIlEJHBIi4QkeAEAAEiJRCRAifjB4AJImEiJRCQQi4QkuAEAAA+vx4lEJBxI"
    . "iwQkSIPACEiJRCQghfYPjiYBAABIi3wkQESLZCQIMe0Ptl8CTItMJCBBvgIAAABE"
    . "D7ZXAUQPth9Bid3rHQ8fAA+v2w+v0o0cWw+vwI0Uk40EQjnBc2pJg8EIRTnwD4Z9"
    . "AAAAQYsBQYtJBEGDxgKJww+21A+2wMHrEEQp0kQp2A+220Qp64H5@@@@AHazQYnP"
    . "QcHvEEUPtv8Pr9tFD6@@RDn7d7IPtt0Pr9IPr9s52nelD7bJD6@AD6@JOch3mGaQ"
    . "i0QkCEgDfCQQA2wkHEQB4EQ55n5lQYnE6UP@@@8PHwCLRCRIRIt0JBhEievB4xBB"
    . "weIIQQnamU1jzkUJ2ve8JIgBAAAPr4QkOAEAAInBieiZ9@5Ii5QkaAEAAI0EgUKJ"
    . "BIpEifCDwAGJRCQYSIuEJHABAABGiRSI64aLfCRQi0QkCItUJHgBVCRISItUJHBI"
    . "AVQkQAH4ObwkiAEAAH4JiUQkUOmk@v@@i0QkGESLpCRQAQAAD6+EJJABAADB+AqJ"
    . "RCQcSIsEJMdEJEAAAAAARTH@i1gEidgPts8PttPB6BAPtsCJxw+v+InID6@Bibwk"
    . "mAAAAImEJJwAAACJ0A+vwomEJJQAAADpffX@@8dEJEAAAAAAx0QkHAAAAABFMf@H"
    . "RCQYAAAAAOn19P@@i5QkWAEAAIXSD4589v@@Q40EZESLdCQIQo0spQAAAAAx9jH@"
    . "SJhIA4QkYAEAAEmJxUWF5H5aSIuUJDABAABJY8ZMY99FMclNAetIjUwCAg8fRAAA"
    . "D7YRSIPBBERr0iYPtlH7a8JLQY0UAkQPtlH6RInQweAERCnQAdDB+AdDiAQLSYPB"
    . "AUU5zH@KQQHuRAHng8YBRAN0JCA5tCRYAQAAdZBIi3wkWDHSQY1sJP9EiXwkSEUx"
    . "0olcJCBBiddIifhIg8ABSIlEJAi4AQAAAEiJxouEJFgBAABIKf6LfCQwSIl0JBBE"
    . "jXD@RYXkD47TAAAASItEJAhNY99Ii3QkKEuNVB0BTo0MGEiLRCQQTAHeTQHpSo0M"
    . "GDHATAHpZi4PH4QAAAAAAEiFwA+EgQMAADnFD4R5AwAARYXSD4RwAwAARTnWD4Rn"
    . "AwAARA+2Qv9ED7Za@rsBAAAAQQH4RTnYckZED7YaRTnYcj1ED7ZZ@0U52HIzRQ+2"
    . "Wf9FOdhyKUQPtln+RTnYch9ED7YZRTnYchZFD7ZZ@kU52HIMRQ+2GUU52A+Sw2aQ"
    . "iBwGSIPAAUiDwgFJg8EBSIPBAUE5xA+PZP@@@0UB50GDwgFEOZQkWAEAAA+FEv@@"
    . "@4tcJCBEi3wkSOmJ8@@@RIuUJLgBAACLnCTAAQAAMcBFD6@SD6@bRYX2D4569@@@"
    . "6RP3@@+DfCRsAQ+E@AEAAIN8JGwCD4S4AgAAQYPtAelX+v@@g4QkiAAAAAHHRCRI"
    . "CQAAAIn4SIu0JGABAABBD6@ERo0MKEljwYA8BgMPhqQBAACLRCQYRDn4QQ9Mx4O8"
    . "JBABAAADiUQkIA+OsAEAAIuEJEgBAACLlCRAAQAAAfhEAeoPr4QkOAEAAIO8JBAB"
    . "AAAFD4TAAgAARI0MkItEJDBIi7QkMAEAAESLVCQgRAHIjVACRYXSSGPSD7Y0Fo1Q"
    . "AUiYSGPSiXQkUEiLtCQwAQAAD7Y0Fol0JHhIi7QkMAEAAA+2BAaJRCRwD4TrAQAA"
    . "i0QkQESJXCQoRTHSi3QkHEyLnCQwAQAAiYQkjAAAAOtyRDu8JJAAAAB+WUiLhCRw"
    . "AQAAQosUkEQByo1CAo1KAUhj0kEPthQTSJhIY8krVCRwQQ+2BANBD7YMCytEJFAr"
    . "TCR4D6@SD6@AD6@JjQRAjQSIjQRQQTnAcgqDrCSMAAAAAXh+SYPCAUQ5VCQgD47P"
    . "AQAARDlUJBhEiZQkkAAAAA+Oe@@@@0iLhCRoAQAAQosUkEQByo1CAo1KAUhj0kEP"
    . "thQTSJhIY8krVCRwQQ+2BANBD7YMCytEJFArTCR4D6@SD6@AD6@JjQRAjQSIjQRQ"
    . "QTnAD4Mo@@@@g+4BD4kf@@@@RItcJCiDfCRICQ+Eavj@@4NEJGgB6Snz@@9Bg8UB"
    . "6Wb4@@+DRCRMAekA8@@@kIXAD4SzAAAARItUJECLdCQcMcnrM0Q7fCQofiJIi5Qk"
    . "cAEAAESJyAMEikiLlCRgAQAA9gQCAXUGQYPqAXiZSIPBATlMJCB+dzlMJBiJTCQo"
    . "fsNIi4QkaAEAAESJygMUiEiLhCRgAQAA9gQQAnWng+4BeaLpX@@@@w8fhAAAAAAA"
    . "uwMAAADpRvH@@8YEBgLp8Pz@@0G6AwAAAOk+8f@@x0QkHAAAAADHRCQYAAAAAOm7"
    . "9f@@g8cB6aD3@@+LdCQcQYPGAUiDvCSoAQAAAA+EHQQAAEljxouUJEgBAABIjQyF"
    . "AAAAAIuEJEABAAAB+sHiEEQB6AnQSIuUJKgBAACJRAr8i5QkKAEAAIXSD4UeAwAA"
    . "i0QkHCnwRDm0JLABAABIi3QkYIlEDvwPjhPz@@@ppf7@@0SLXCQo64aNBJCJRCQo"
    . "i4QkrAAAAIXAD4XjAQAAi0QkIIXAD4Rg@@@@SIsEJIt0JBxFMcnHRCR4AAAAAESJ"
    . "dCRwRIm8JIwAAABEiZwkkAAAAEiJRCRQSIuEJGgBAACLTCQoTIu8JDABAABMi1Qk"
    . "UEyLhCRwAQAARItcJHhCAwyIQYE6@@@@AEeLBIiNUQKNQQFIY8lBD5fGSGPSSJhF"
    . "D7b2QQ+2FBdBD7YEB4mUJLQAAACJhCS4AAAAweIQweAICdBBD7YUDwnQiZQkvAAA"
    . "AImEJLAAAADrHg+v0g+vyY0UUg+vwI0Uio0EQjnDD4OvAAAASYPCCEU5ww+D4AAA"
    . "AESLvCSgAAAAQYPDAkGLAkGLWgRFhf90Hk2FyYtUJDAPRJQksAAAAEUx9oXAQQ+U"
    . "xolUJDCJ0InCD7bMD7bAweoQK4wkuAAAACuEJLwAAAAPttIrlCS0AAAAgfv@@@8A"
    . "D4Z0@@@@QYnfQcHvEEUPtv8Pr9JFD6@@RDn6D4dz@@@@D7bXD6@JD6@SOdEPh2L@"
    . "@@8PttMPr8APr9I50A+HUf@@@0WF9nQFg+4BeDtJg8EBSINEJFBYg0QkeBZEOUwk"
    . "IA+Pkf7@@0SLdCRwRIu8JIwAAABEi5wkkAAAAOmu@f@@RYX2dcfrwESLdCRwRIu8"
    . "JIwAAABEi5wkkAAAAOml@P@@i0QkIIt0JByFwA+Eff3@@0Ux0us5OYQkmAAAAHwY"
    . "D6@JOYwknAAAAHwMD6@SOZQklAAAAH0Jg+4BD4hm@P@@SYPCAUQ5VCQgD44@@f@@"
    . "SIuEJGgBAACLVCQoTIuMJDABAABCAxSQSIuEJHABAABCiwSQicGNQgKJTCQwwekQ"
    . "SJgPtslBD7YEASnIjUoBSGPSD6@ASGPJRQ+2DAlIi0wkMA+2zUEpyUSJyUyLjCQw"
    . "AQAAQQ+2FBFED7ZMJDBEKcqB+@@@@wAPh0r@@@8Pr8mNBEAPr9KNBIiNBFA5ww+C"
    . "VP@@@+lY@@@@x0QkHAAAAADHRCQYAAAAAOlF9@@@RDm0JLABAABEifAPjhvx@@+J"
    . "+CuEJMABAABFMdKDwAFBD0jCicGLhCTAAQAAjUQH@0E5w0EPTsOJxkSJ6CuEJLgB"
    . "AACDwAFED0nQi4QkuAEAAEGNRAX@OcUPTsU5zolEJCAPjEH7@@9EieJJY8IPr9FI"
    . "Y9JIAdBIA4QkYAEAAEmJwY1GAYlEJCiLRCQgRCnQSI1wAUQ7VCQgfxNKjRQOTInI"
    . "gCADSIPAAUg50HX0g8EBTANMJFg7TCQoddjp6Pr@@4uMJCgBAACFyQ+FQf@@@+nU"
    . "+v@@kJCQkJCQkJCQkJCQkA=="
    MyFunc:=this.MCode(StrReplace((A_PtrSize=8?x64:x32),"@","/"))
  }
  text:=j[1], w:=j[2], h:=j[3]
  , err1:=this.Floor(j[4] ? j[5] : ini.err1)
  , err0:=this.Floor(j[4] ? j[6] : ini.err0)
  , mode:=j[7], color:=j[8], n:=j[9]
  ok:=(!ini.bits.Scan0 || mode<1 || mode>5) ? 0
    : DllCall(MyFunc.Ptr, "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",ini.bits.Scan0, "int",ini.bits.Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",ini.ss, "Ptr",ini.s1, "Ptr",ini.s0
    , "Ptr",text, "int",w, "int",h
    , "int",Floor(Abs(err1)*1024), "int",Floor(Abs(err0)*1024)
    , "int",(err1<0||err0<0), "Ptr",ini.allpos, "int",ini.allpos_max
    , "int",Floor(w*ini.zoomW), "int",Floor(h*ini.zoomH))
  return ok
}

code()
{
return "
(

//***** C source code of machine code *****
// gcc.exe -m32/-m64 -O2

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , unsigned char * ss, unsigned int * s1, unsigned int * s0
  , unsigned char * text, int w, int h
  , int err1, int err0, int more_err
  , unsigned int * allpos, int allpos_max
  , int new_w, int new_h )
{
  int ok, o, i, j, k, v, e1, e0, len1, len0, max, pic, shape, sort;
  int x, y, x1, y1, x2, y2, x3, y3, r, g, b, rr, gg, bb, dR, dG, dB;
  int ii, jj, RunDir, DirCount, RunCount, AllCount1, AllCount2;
  unsigned int c1, c2, *cors, *arr;
  unsigned char *ts, *gs;
  ok=0; o=0; v=0; len1=0; len0=0; ts=ss+sw; gs=ss+sw*3;
  arr=allpos+allpos_max; sort=(dir==0);
  //----------------------
  if (mode==5)
  {
    if (pic=(c==2))  // FindPic
    {
      cors=(unsigned int *)(text+w*h*4); j=(err0>>10)+1; n*=2;
      for (y=0; y<h; y+=j)
      {
        for (x=0; x<w; x+=j)
        {
          o=(y*w+x)*4; rr=text[2+o]; gg=text[1+o]; bb=text[o];
          for (i=2; i<n;)
          {
            c1=cors[i++]; c2=cors[i++];
            r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
            v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
            : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
            && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
            if (v) goto NoMatch1;
          }
          s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
          s0[len1++]=rr<<16|gg<<8|bb;
          NoMatch1:;
        }
      }
      c2=cors[1]; r=(c2>>16)&0xFF; g=(c2>>8)&0xFF; b=c2&0xFF; dR=r*r; dG=g*g; dB=b*b;
    }
    else  // FindMultiColor or FindColor
    {
      shape=(c==1);  // FindShape
      cors=(unsigned int *)text;
      for (i=0; i<n; i++, o+=22)
      {
        c=cors[o]; y=c>>16; x=c&0xFFFF;
        s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[len1++]=o+cors[o+1]*2;
      }
      cors+=2;
    }
    goto StartLookUp;
  }
  //----------------------
  // Generate Lookup Table
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      i=(mode==4) ? (y*new_h/h)*Stride+(x*new_w/w)*4 : (y*new_h/h)*sw+(x*new_w/w);
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  //----------------------
  // Color Position Mode
  // only used to recognize multicolored Verification Code
  if (mode==4)
  {
    y=c>>16; x=c&0xFFFF;
    c=(y*new_h/h)*Stride+(x*new_w/w)*4;
    goto StartLookUp;
  }
  //----------------------
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==1)  // Color Mode
  {
    cors=(unsigned int *)(text+w*h); n*=2;
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
      {
        rr=Bmp[2+o]; gg=Bmp[1+o]; bb=Bmp[o];
        for (k=0; k<n;)
        {
          c1=cors[k++]; c2=cors[k++];
          r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
          v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
          : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
          && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
          if (v) break;
        }
        ts[i]=(v) ? 1:0;
      }
    }
  }
  else if (mode==2)  // Gray Threshold Mode
  {
    c=(c+1)<<7;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ts[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 1:0;
  }
  else if (mode==3)  // Gray Difference Mode
  {
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    for (i=0, y=0; y<sh; y++)
    for (x=0; x<sw; x++, i++)
    if (x==0 || x==sw-1 || y==0 || y==sh-1)
      ts[i]=2;
    else
    {
      n=gs[i]+c;
      ts[i]=(gs[i-1]>n || gs[i+1]>n
      || gs[i-sw]>n   || gs[i+sw]>n
      || gs[i-sw-1]>n || gs[i-sw+1]>n
      || gs[i+sw-1]>n || gs[i+sw+1]>n) ? 1:0;
    }
  }
  //----------------------
  StartLookUp:
  for (i=0, y=0; y<sh; y++)
  {
    for (x=0; x<sw; x++, i++)
    {
      if (mode>=4) { ss[i]=4; continue; }
      r=ts[i]; g=(x==0 ? 3 : ts[i-1]); b=(x==sw-1 ? 3 : ts[i+1]);
      if (more_err)
        ss[i]=4|(r==2||r==1||g==1||b==1)<<1|(r==2||r==0||g==0||b==0);
      else
        ss[i]=4|(r==2||r==1)<<1|(r==2||r==0);
    }
  }
  if (mode<4 && more_err) sx++;
  err1=(len1*err1)>>10;
  err0=(len0*err0)>>10;
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=(len1>len0) ? len1 : len0;
  w=new_w; h=new_h; x1=0; y1=0; x2=sw-w; y2=sh-h;
  // 1 ==> ( Left to Right ) Top to Bottom
  // 2 ==> ( Right to Left ) Top to Bottom
  // 3 ==> ( Left to Right ) Bottom to Top
  // 4 ==> ( Right to Left ) Bottom to Top
  // 5 ==> ( Top to Bottom ) Left to Right
  // 6 ==> ( Bottom to Top ) Left to Right
  // 7 ==> ( Top to Bottom ) Right to Left
  // 8 ==> ( Bottom to Top ) Right to Left
  // 9 ==> Center to Four Sides
  if (dir==9)
  {
    x=(x1+x2)/2; y=(y1+y2)/2; i=x2-x1+1; j=y2-y1+1;
    AllCount1=i*j; i=(i>j?i:j)+8;
    AllCount2=i*i; RunCount=0; DirCount=1; RunDir=0;
    for (ii=0; RunCount<AllCount1 && ii<AllCount2;)
    {
      for(jj=0; jj<DirCount; jj++, ii++)
      {
        if(x>=x1 && x<=x2 && y>=y1 && y<=y2)
        {
          RunCount++;
          goto FindPos;
          FindPos_GoBak:;
        }
        if (RunDir==0) y--;
        else if (RunDir==1) x++;
        else if (RunDir==2) y++;
        else x--;
      }
      if (RunDir & 1) DirCount++;
      RunDir = (++RunDir) & 3;
    }
    goto Return1;
  }
  if (dir<1 || dir>8) dir=1;
  if (--dir>3) { r=y1; y1=x1; x1=r; r=y2; y2=x2; x2=r; }
  for (y3=y1; y3<=y2; y3++)
  {
    for (x3=x1; x3<=x2; x3++)
    {
      y=(dir & 2) ? y1+y2-y3 : y3;
      x=(dir & 1) ? x1+x2-x3 : x3;
      if (dir>3) { r=y; y=x; x=r; }
      //----------------------
      FindPos:
      e1=err1; e0=err0; o=y*sw+x;
      if (ss[o]<4) goto NoMatch;
      if (mode<4)
      {
        for (i=0; i<max; i++)
        {
          if (i<len1 && (ss[o+s1[i]]&2)==0 && (--e1)<0) goto NoMatch;
          if (i<len0 && (ss[o+s0[i]]&1)==0 && (--e0)<0) goto NoMatch;
        }
      }
      else if (mode==5)
      {
        o=(sy+y)*Stride+(sx+x)*4;
        if (pic)
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; c=s0[i]; r=Bmp[2+j]-((c>>16)&0xFF);
            g=Bmp[1+j]-((c>>8)&0xFF); b=Bmp[j]-(c&0xFF);
            v=(c2<0x1000000)?(3*r*r+4*g*g+2*b*b>c2):(r*r>dR||g*g>dG||b*b>dB);
            if (v && (--e1)<0) goto NoMatch;
          }
        }
        else
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
            for (j=i*22, k=cors[j]>0xFFFFFF, n=s0[i]; j<n;)
            {
              c1=cors[j++]; c2=cors[j++];
              if (shape) { if (i==0) c=rr<<16|gg<<8|bb; k=!c1; c1=c; }
              r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
              v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
              : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
              && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
              if (v) { if (k) goto NoMatch2; goto MatchOK; }
            }
            if (k) goto MatchOK;
            NoMatch2:
            if ((--e1)<0) goto NoMatch;
            MatchOK:;
          }
        }
      }
      else  // mode==4
      {
        o=(sy+y)*Stride+(sx+x)*4; j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b>n && (--e1)<0) goto NoMatch;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b<=n && (--e0)<0) goto NoMatch;
          }
        }
      }
      ok++;
      if (allpos)
      {
        allpos[ok-1]=(sy+y)<<16|(sx+x); if (sort) arr[ok-1]=err1-e1;
        if (ok>=allpos_max) goto Return1;
      }
      // Skip areas that may overlap
      if (!sort)
      {
        r=y-h+1; if (r<0) r=0; rr=y+h-1; if (rr>sh-h) rr=sh-h;
        g=x-w+1; if (g<0) g=0; gg=x+w-1; if (gg>sw-w) gg=sw-w;
        for (i=r; i<=rr; i++)
          for (j=g; j<=gg; j++)
            ss[i*sw+j] &= 3;
      }
      NoMatch:
      if (dir==9) goto FindPos_GoBak;
    }
  }
  //----------------------
  Return1:
  if (!sort || !allpos || w*h==1)
    return ok;
  // Sort by smallest error
  for (i=1; i<ok; i++)
  {
    k=arr[i]; v=allpos[i];
    for (j=i-1; j>=0 && arr[j]>k; j--)
    {
      arr[j+1]=arr[j]; allpos[j+1]=allpos[j];
    }
    arr[j+1]=k; allpos[j+1]=v;
  }
  // Clean up overlapping results
  w*=w; h*=h; k=ok; ok=0;
  for (i=0; i<k; i++)
  {
    c1=allpos[i]; x1=c1&0xFFFF; y1=c1>>16;
    for (j=0; j<ok; j++)
    {
      c2=allpos[j]; x=(c2&0xFFFF)-x1; y=(c2>>16)-y1;
      if (x*x<w && y*y<h) goto NoMatch3;
    }
    allpos[ok++]=c1;
    NoMatch3:;
  }
  return ok;
}

)"
}

PicInfo(text)
{
  if !InStr(text, "$")
    return
  static info:=Map(), bmp:=[]
  key:=(r:=StrLen(v:=Trim(text,"|")))<10000 ? v
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , "Ptr",StrPtr(v), "uint",r*2, "uint")
  if info.Has(key)
    return info[key]
  comment:="", seterr:=err1:=err0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v, "<([^>\n]*)>", &r)
    v:=StrReplace(v,r[0]), comment:=Trim(r[1])
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v, "\[([^\]\n]*)]", &r)
  {
    v:=StrReplace(v,r[0]), r:=StrSplit(r[1] ",", ",")
    , seterr:=1, err1:=r[1], err0:=r[2]
  }
  color:=SubStr(v,1,InStr(v,"$")-1), v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5 : InStr(color,"#") ? 4
    : InStr(color,"**") ? 3 : InStr(color,"*") ? 2 : 1
  color:=RegExReplace(StrReplace(color,"@","-"), "[*#\s]")
  (mode=1 || mode=5) && color:=StrReplace(color,"0x")
  if (mode=5)
  {
    if !(v~="^[\s\-\w.]+/[\s\-\w.]+/[\s\-\w./,]+$")  ; <FindPic>
    {
      if !(hBM:=LoadPicture(v))
      {
        MsgBox "Can't Load Picture ! " v, "Tip", 4096
        return
      }
      this.GetBitmapWH(hBM, &w, &h)
      if (w<1 || h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, &Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", "Ptr",hBM)
      if (!Scan0)
        return
      arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length
      bmp.Push(buf:=Buffer(w*h*4 + n*2*4)), v:=buf.Ptr, p:=v+w*h*4-4
      DllCall("RtlMoveMemory", "Ptr",v, "Ptr",Scan0, "Ptr",w*h*4)
      DllCall("DeleteObject", "Ptr",hBM2), color:=Trim(arr[1],"-")
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-" color, "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
        , NumPut("uint", this.ToRGB(c[1]), p+=4)
        , NumPut("uint", (InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), p+=4)
      color:=2
    }
    else  ; <FindMultiColor> or <FindColor> or <FindShape>
    {
      color:=Trim(StrSplit(color "/", "/")[1], "-")
      arr:=StrSplit(Trim(RegExReplace(v, "i)\s|0x"), ","), ",")
      if !(n:=arr.Length)
        return
      bmp.Push(buf:=Buffer(n*22*4)), v:=buf.Ptr
      shape:=(n>1 && StrLen(StrSplit(arr[1] "//","/")[3])=1 ? 1:0)
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1]), y:=this.Floor(r[2])
        , (A_Index=1) ? (x1:=x2:=x, y1:=y2:=y)
        : (x1:=Min(x1,x), x2:=Max(x2,x), y1:=Min(y1,y), y2:=Max(y2,y))
      }
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1])-x1, y:=this.Floor(r[2])-y1
        , NumPut("uint", y<<16|x, p:=v+(A_Index-1)*22*4)
        , NumPut("uint", n1:=Min(Max(r.Length-3,0),(shape?1:10)), p+=4)
        Loop n1
          c:=StrSplit(Trim(v1:=r[2+A_Index],"-") "-" color, "-")
          , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
          , NumPut("uint", this.ToRGB(c[1])&0xFFFFFF|(!shape&&InStr(v1,"-")=1?0x1000000:0), p+=4)
          , NumPut("uint", (InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), p+=4)
      }
      color:=shape, w:=x2-x1+1, h:=y2-y1+1
    }
  }
  else
  {
    r:=StrSplit(v ".", "."), w:=this.Floor(r[1])
    , v:=this.base64tobit(r[2]), h:=StrLen(v)//w
    if (w<1 || h<1 || StrLen(v)!=w*h)
      return
    arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length
    , bmp.Push(buf:=Buffer(StrPut(v, "CP0") + n*2*4))
    , StrPut(v, buf.Ptr, "CP0"), v:=buf.Ptr, p:=v+w*h-4
    , color:=this.Floor(color)
    if (mode=1)
    {
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-", "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
        , NumPut("uint", this.ToRGB(c[1]), p+=4)
        , NumPut("uint", (InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), p+=4)
    }
    else if (mode=4)
    {
      r:=StrSplit(Trim(arr[1],"-") "-", "-")
      , n:=this.Floor(r[2]), n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
      , c:=this.Floor(r[1]), color:=(c<1||c>w*h?0:((c-1)//w)<<16|Mod(c-1,w))
    }
  }
  return info[key]:=[v, w, h, seterr, err1, err0, mode, color, n, comment]
}

ToRGB(color)  ; color can use: RRGGBB, Red, Yellow, Black, White
{
  static tab:=""
  if (!tab)
    tab:=Map(), tab.CaseSense:="Off"
    , tab.Set("Black", "000000", "White", "FFFFFF"
    , "Red", "FF0000", "Green", "008000", "Blue", "0000FF"
    , "Yellow", "FFFF00", "Silver", "C0C0C0", "Gray", "808080"
    , "Teal", "008080", "Navy", "000080", "Aqua", "00FFFF"
    , "Olive", "808000", "Lime", "00FF00", "Fuchsia", "FF00FF"
    , "Purple", "800080", "Maroon", "800000")
  return this.Floor("0x" (tab.Has(color)?tab[color]:color))
}

GetBitsFromScreen(&x:=0, &y:=0, &w:=0, &h:=0
  , ScreenShot:=1, &zx:=0, &zy:=0, &zw:=0, &zh:=0)
{
  static CAPTUREBLT:=""
  if (CAPTUREBLT="")  ; thanks Descolada
  {
    DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", &i:=0)
    CAPTUREBLT:=i ? 0 : 0x40000000
  }
  if InStr(A_OSVersion, ".")  ; thanks QQ:349029755
    Try DllCall("SetThreadDpiAwarenessContext", "Ptr",-3, "Ptr")
  (!IsObject(this.bits) && this.bits:={Scan0:0, hBM:0, oldzw:0, oldzh:0})
  , bits:=this.bits
  if (!ScreenShot && bits.Scan0)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
    , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
    return bits
  }
  cri:=A_IsCritical
  Critical
  bits.BindWindow:=id:=this.BindWindow(0,0,1)
  if (id)
  {
    Try
      WinGetPos &zx, &zy, &zw, &zh, id
    Catch
      id:=0
  }
  if (!id)
  {
    zx:=SysGet(76)
    , zy:=SysGet(77)
    , zw:=SysGet(78)
    , zh:=SysGet(79)
  }
  this.UpdateBits(bits, zx, zy, zw, zh)
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (!ScreenShot || w<1 || h<1 || !bits.hBM)
  {
    Critical cri
    return bits
  }
  if IsSet(GetBitsFromScreen2) && (GetBitsFromScreen2 is Func)
    && GetBitsFromScreen2(bits, x-zx, y-zy, w, h)
  {
    ; Get the bind window use bits.BindWindow
    ; Each small range of data obtained from DXGI must be
    ; copied to the screenshot cache using FindText().CopyBits()
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    Critical cri
    return bits
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",bits.hBM, "Ptr")
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC:=DllCall("GetDCEx", "Ptr",id, "Ptr",0, "int",3, "Ptr")
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",hDC, "int",x-zx, "int",y-zy, "uint",0xCC0020|CAPTUREBLT)
      DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
      oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
      DllCall("UpdateWindow", "Ptr",id)
      ; RDW_INVALIDATE=0x1|RDW_ERASE=0x4|RDW_ALLCHILDREN=0x80|RDW_FRAME=0x400
      ; DllCall("RedrawWindow", "Ptr",id, "Ptr",0, "Ptr",0, "uint", 0x485)
      DllCall("PrintWindow", "Ptr",id, "Ptr",mDC2, "uint",(mode>3)*3)
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",mDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020)
      DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
      DllCall("DeleteDC", "Ptr",mDC2)
      DllCall("DeleteObject", "Ptr",hBM2)
    }
  }
  else
  {
    hDC:=DllCall("GetWindowDC","Ptr",id:=DllCall("GetDesktopWindow","Ptr"),"Ptr")
    DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , "Ptr",hDC, "int",x, "int",y, "uint",0xCC0020|CAPTUREBLT)
    DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  Critical cri
  return bits
}

UpdateBits(bits, zx, zy, zw, zh)
{
  if (zw>bits.oldzw || zh>bits.oldzh || !bits.hBM)
  {
    Try DllCall("DeleteObject", "Ptr",bits.hBM)
    bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, &ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
  }
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
}

CreateDIBSection(w, h, bpp:=32, &ppvBits:=0)
{
  NumPut("int",40, "int",w, "int",-h, "short",1, "short",bpp, bi:=Buffer(40,0))
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",bi
    , "int",0, "Ptr*",&ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

GetBitmapWH(hBM, &w, &h)
{
  bm:=Buffer(size:=(A_PtrSize=8 ? 32:24), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",size, "Ptr",bm)
  , w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w, h, Clear:=0)
{
  if (w<1 || h<1 || !hBM1 || !hBM2)
    return
  mDC1:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM1:=DllCall("SelectObject", "Ptr",mDC1, "Ptr",hBM1, "Ptr")
  mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
  DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
  , "Ptr",mDC2, "int",x2, "int",y2, "uint",0xCC0020)
  if (Clear)
    DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC1, "int",x1, "int",y1, "uint",MERGECOPY:=0xC000CA)
  DllCall("SelectObject", "Ptr",mDC1, "Ptr",oBM1)
  DllCall("DeleteDC", "Ptr",mDC1)
  DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
  DllCall("DeleteDC", "Ptr",mDC2)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w,h,Reverse:=0)
{
  if (w<1 || h<1 || !Scan01 || !Scan02)
    return
  static init:=0, MFCopyImage
  if (!init && init:=1)
  {
    MFCopyImage:=DllCall("GetProcAddress", "Ptr"
    , DllCall("LoadLibrary", "Str","Mfplat.dll", "Ptr")
    , "AStr","MFCopyImage", "Ptr")
  }
  if (MFCopyImage && !Reverse)  ; thanks QQ:121507989
  {
    return DllCall(MFCopyImage
      , "Ptr",Scan01+y1*Stride1+x1*4, "int",Stride1
      , "Ptr",Scan02+y2*Stride2+x2*4, "int",Stride2
      , "uint",w*4, "uint",h)
  }
  ListLines (lls:=A_ListLines)?0:0
  p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w*=4
  , (Reverse) && (p2+=(h+1)*Stride2, Stride2:=-Stride2)
  Loop h
    DllCall("RtlMoveMemory","Ptr",p1+=Stride1,"Ptr",p2+=Stride2,"Ptr",w)
  ListLines lls
}

DrawHBM(hBM, lines)
{
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  oldc:="", brush:=0, rect:=Buffer(16)
  For k,v in lines  ; [ [x, y, w, h, color] ]
  if IsObject(v)
  {
    if (oldc!=v[5])
    {
      oldc:=v[5], BGR:=(oldc&0xFF)<<16|oldc&0xFF00|(oldc>>16)&0xFF
      DllCall("DeleteObject", "Ptr",brush)
      brush:=DllCall("CreateSolidBrush", "uint",BGR, "Ptr")
    }
    DllCall("SetRect", "Ptr",rect, "int",v[1], "int",v[2]
      , "int",v[1]+v[3], "int",v[2]+v[4])
    DllCall("FillRect", "Ptr",mDC, "Ptr",rect, "Ptr",brush)
  }
  DllCall("DeleteObject", "Ptr",brush)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteObject", "Ptr",mDC)
}

; Bind the window so that it can find images when obscured
; by other windows, it's equivalent to always being
; at the front desk. Unbind Window using FindText().BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  (!IsObject(this.bind) && this.bind:={id:0, mode:0, oldStyle:0})
  , bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id:=this.Floor(bind_id)
    , bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      i:=WinGetExStyle(bind_id)
      bind.oldStyle:=i
      WinSetTransparent(255, bind_id)
      Loop 30
      {
        Sleep 100
        i:=WinGetTransparent(bind_id)
      }
      Until (i=255)
    }
  }
  else
  {
    bind_id:=bind.id
    if (bind.mode & 1)
      WinSetExStyle(bind.oldStyle, bind_id)
    bind.id:=0, bind.mode:=0, bind.oldStyle:=0
  }
}

; Use FindText().CaptureCursor(1) to Capture Cursor
; Use FindText().CaptureCursor(0) to Cancel Capture Cursor

CaptureCursor(hDC:=0, zx:=0, zy:=0, zw:=0, zh:=0, get_cursor:=0)
{
  if (get_cursor)
    return this.Cursor
  if (hDC=1 || hDC=0) && (zw=0)
  {
    this.Cursor:=hDC
    return
  }
  mi:=Buffer(40, 0), NumPut("int", 16+A_PtrSize, mi)
  DllCall("GetCursorInfo", "Ptr",mi)
  bShow:=NumGet(mi, 4, "int")
  hCursor:=NumGet(mi, 8, "Ptr")
  x:=NumGet(mi, 8+A_PtrSize, "int")
  y:=NumGet(mi, 12+A_PtrSize, "int")
  if (!bShow) || (x<zx || y<zy || x>=zx+zw || y>=zy+zh)
    return
  ni:=Buffer(40, 0)
  DllCall("GetIconInfo", "Ptr",hCursor, "Ptr",ni)
  xCenter:=NumGet(ni, 4, "int")
  yCenter:=NumGet(ni, 8, "int")
  hBMMask:=NumGet(ni, (A_PtrSize=8?16:12), "Ptr")
  hBMColor:=NumGet(ni, (A_PtrSize=8?24:16), "Ptr")
  DllCall("DrawIconEx", "Ptr",hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, "Ptr",hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", "Ptr",hBMMask)
  DllCall("DeleteObject", "Ptr",hBMColor)
}

MCode(hex)
{
  flag:=((hex~="[^A-Fa-f\d\s]") ? 1:4), len:=0
  Loop 2
    if !DllCall("crypt32\CryptStringToBinary", "Str",hex, "uint",0, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=Buffer(len)).Ptr), "uint*",&len, "Ptr",0, "Ptr",0)
      return
  if DllCall("VirtualProtect", "Ptr",p.Ptr, "Ptr",len, "uint",0x40, "uint*",0)
    return p
}

bin2hex(addr, size, base64:=0)
{
  flag:=(base64 ? 1:4)|0x40000000, len:=0
  Loop 2
    DllCall("crypt32\CryptBinaryToString", "Ptr",addr, "uint",size, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=Buffer(len*2)).Ptr), "uint*",&len)
  return RegExReplace(StrGet(p.Ptr, len), "\s+")
}

base64tobit(s)
{
  ListLines (lls:=A_ListLines)?0:0
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  Loop Parse, Chars
    if InStr(s, A_LoopField, 1)
      s:=RegExReplace(s, "[" A_LoopField "]", ((i:=A_Index-1)>>5&1)
      . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1))
  s:=RegExReplace(RegExReplace(s,"[^01]+"),"10*$")
  ListLines lls
  return s
}

bit2base64(s)
{
  ListLines (lls:=A_ListLines)?0:0
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  Loop Parse, Chars
    s:=StrReplace(s, "|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), A_LoopField)
  ListLines lls
  return s
}

ASCII(s)
{
  if RegExMatch(s, "\$(\d+)\.([\w+/]+)", &r)
  {
    s:=RegExReplace(this.base64tobit(r[2]),".{" r[1] "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s:=""
  return s
}

; You can put the text library at the beginning of the script,
; and Use FindText().PicLib(Text,1) to add the text library to PicLib()'s Lib,
; Use FindText().PicLib("comment1|comment2|...") to get text images from Lib

PicLib(comments, add_to_Lib:=0, index:=1)
{
  (!IsObject(this.Lib) && this.Lib:=Map()), Lib:=this.Lib
  , (!Lib.Has(index) && Lib[index]:=Map()), Lib:=Lib[index]
  if (add_to_Lib)
  {
    re:="<([^>\n]*)>[^$\n]+\$[^`"'\r\n]+"
    Loop Parse, comments, "|"
      if RegExMatch(A_LoopField, re, &r)
      {
        s1:=Trim(r[1]), s2:=""
        Loop Parse, s1
          s2.=Format("_{:d}", Ord(A_LoopField))
        (s2!="") && Lib[s2]:=r[0]
      }
  }
  else
  {
    Text:=""
    Loop Parse, comments, "|"
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop Parse, s1
        s2.=Format("_{:d}", Ord(A_LoopField))
      (Lib.Has(s2)) && Text.="|" Lib[s2]
    }
    return Text
  }
}

; Decompose a string into individual characters and get their data

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; Use FindText().PicX(Text) to automatically cut into multiple characters
; Can't be used in ColorPos mode, because it can cause position errors

PicX(Text)
{
  if !RegExMatch(Text, "(<[^$\n]+)\$(\d+)\.([\w+/]+)", &r)
    return Text
  v:=this.base64tobit(r[3]), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r[2] "}","$0`n")
  While InStr(txt,c)
  {
    While !(txt~="m`n)^" c)
      txt:=RegExReplace(txt,"m`n)^.")
    i:=0
    While (txt~="m`n)^.{" i "}" c)
      i:=Format("{:d}",i+1)
    v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
    txt:=RegExReplace(txt,"m`n)^.{" i "}")
    if (v!="")
      Text.="|" r[1] "$" i "." this.bit2base64(v)
  }
  return Text
}

; Screenshot and retained as the last screenshot.

ScreenShot(x1:=0, y1:=0, x2:=0, y2:=0)
{
  this.FindText(,, x1, y1, x2, y2)
}

; Get the RGB color of a point from the last screenshot.
; If the point to get the color is beyond the range of
; Screen, it will return White color (0xFFFFFF).

GetColor(x, y, fmt:=1)
{
  bits:=this.GetBitsFromScreen(,,,,0,&zx,&zy,&zw,&zh), x-=zx, y-=zy
  , c:=(x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
  ? NumGet(bits.Scan0+y*bits.Stride+x*4,"uint") : 0xFFFFFF
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; Set the RGB color of a point in the last screenshot

SetColor(x, y, color:=0x000000)
{
  bits:=this.GetBitsFromScreen(,,,,0,&zx,&zy,&zw,&zh), x-=zx, y-=zy
  if (x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
    NumPut("uint", color, bits.Scan0+y*bits.Stride+x*4)
}

; Identify a line of text or verification code
; based on the result returned by FindText().
; offsetX is the maximum interval between two texts,
; if it exceeds, a "*" sign will be inserted.
; offsetY is the maximum height difference between two texts.
; overlapW is used to set the width of the overlap.
; Return Association array {text:Text, x:X, y:Y, w:W, h:H}

Ocr(ok, offsetX:=20, offsetY:=20, overlapW:=0)
{
  ocr_Text:=ocr_X:=ocr_Y:=min_X:=dx:=""
  For k,v in ok
    x:=v.1
    , min_X:=(A_Index=1 || x<min_X ? x : min_X)
    , max_X:=(A_Index=1 || x>max_X ? x : max_X)
  While (min_X!="" && min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) || (ocr_Y!="" && Abs(y-ocr_Y)>offsetY)
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" || x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" && LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  (ocr_X="") && ocr_X:=min_Y:=min_X:=max_Y:=0
  return {text:ocr_Text, x:ocr_X, y:min_Y, w:min_X-ocr_X, h:max_Y-min_Y}
}

; Sort the results of FindText() from left to right
; and top to bottom, ignore slight height difference

Sort(ok, dy:=10)
{
  if !IsObject(ok)
    return ok
  s:="", n:=150000, ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k1,v1 in ypos
    if Abs(y-v1)<=dy
    {
      y:=v1, add:=0
      Break
    }
    if (add)
      ypos.Push(y)
    s.=(y*n+x) "." k "|"
  }
  s:=Trim(s,"|")
  s:=Sort(s, "N D|")
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Sort the results of FindText() according to the nearest distance

Sort2(ok, px, py)
{
  if !IsObject(ok)
    return ok
  s:=""
  For k,v in ok
    s.=((v.x-px)**2+(v.y-py)**2) "." k "|"
  s:=Trim(s,"|")
  s:=Sort(s, "N D|")
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Sort the results of FindText() according to the search direction

Sort3(ok, dir:=1)
{
  if !IsObject(ok)
    return ok
  s:="", n:=150000
  For k,v in ok
    x:=v.1, y:=v.2
    , s.=(dir=1 ? y*n+x
    : dir=2 ? y*n-x
    : dir=3 ? -y*n+x
    : dir=4 ? -y*n-x
    : dir=5 ? x*n+y
    : dir=6 ? x*n-y
    : dir=7 ? -x*n+y
    : dir=8 ? -x*n-y : y*n+x) "." k "|"
  s:=Trim(s,"|")
  s:=Sort(s, "N D|")
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Prompt mouse position in remote assistance

MouseTip(x:="", y:="", w:=10, h:=10, d:=3)
{
  if (x="")
  {
    pt:=Buffer(16,0), DllCall("GetCursorPos", "Ptr",pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  Loop 4
  {
    this.RangeTip(x-w, y-h, 2*w+1, 2*h+1, (A_Index & 1 ? "Red":"Blue"), d)
    Sleep 500
  }
  this.RangeTip()
}

; Shows a range of the borders, similar to the ToolTip

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=3, num:=1)
{
  ListLines (lls:=A_ListLines)?0:0
  static tab:=Map()
  (!tab.Has(num) && tab[num]:=[0,0,0,0]), Range:=tab[num]
  if (x="")
  {
    if (Range[1])
    Loop 4
      Range[A_Index].Destroy(), Range[A_Index]:=""
    ListLines lls
    return
  }
  if !(Range[1])
  {
    Loop 4
      Range[A_Index]:=Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  }
  x:=this.Floor(x), y:=this.Floor(y), w:=this.Floor(w), h:=this.Floor(h), d:=this.Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 || i=3 ? w+2*d : d)
    , h1:=(i=2 || i=4 ? h+2*d : d)
    Range[i].BackColor:=color
    Range[i].Show("NA x" x1 " y" y1 " w" w1 " h" h1)
  }
  ListLines lls
}

State(key)
{
  return GetKeyState(key,"P") || GetKeyState(key)
}

; Use RButton to select the screen range

GetRange(ww:=25, hh:=8, key:="RButton")
{
  static KeyOff:="", hk
  if (!KeyOff)
    KeyOff:=this.GetRange.Bind(this, "Off")
  if (ww=="Off")
    return hk:=Trim(A_ThisHotkey, "*")
  ;---------------------
  GetRange_HotkeyIf:=_Gui:=Gui()
  _Gui.Opt("-Caption +ToolWindow +E0x80000")
  _Gui.Title:="GetRange_HotkeyIf"
  _Gui.Show("NA x0 y0 w0 h0")
  ;---------------------
  if GetKeyState("Ctrl")
    Send "{Ctrl Up}"
  HotIfWinExist "GetRange_HotkeyIf"
  keys:=key "|Up|Down|Left|Right"
  For k,v in StrSplit(keys, "|")
  {
    if GetKeyState(v)
      Send "{" v " Up}"
    Try Hotkey "*" v, KeyOff, "On"
  }
  HotIfWinExist
  ;---------------------
  Critical (cri:=A_IsCritical)?"Off":"Off"
  CoordMode "Mouse"
  tip:=this.Lang("s5")
  hk:="", oldx:=oldy:="", keydown:=0
  Loop
  {
    Sleep 50
    MouseGetPos &x2, &y2
    if (hk=key) || this.State(key) || this.State("Ctrl")
    {
      keydown++
      if (keydown=1)
        MouseGetPos &x1, &y1, &Bind_ID
      timeout:=A_TickCount+3000
      While (A_TickCount<timeout) && (this.State(key) || this.State("Ctrl"))
        Sleep 50
      hk:=""
      if (keydown>=2)
        Break
    }
    else if (hk="Up") || this.State("Up")
      (hh>1 && hh--), hk:=""
    else if (hk="Down") || this.State("Down")
      hh++, hk:=""
    else if (hk="Left") || this.State("Left")
      (ww>1 && ww--), hk:=""
    else if (hk="Right") || this.State("Right")
      ww++, hk:=""
    x:=(keydown?x1:x2), y:=(keydown?y1:y2)
    this.RangeTip(x-ww, y-hh, 2*ww+1, 2*hh+1, (A_MSec<500?"Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip "x: " x " y: " y "`n" tip
  }
  ToolTip
  this.RangeTip()
  HotIfWinExist "GetRange_HotkeyIf"
  For k,v in StrSplit(keys, "|")
    Try Hotkey "*" v, KeyOff, "Off"
  HotIfWinExist
  GetRange_HotkeyIf.Destroy()
  Critical cri
  return [x-ww, y-hh, x+ww, y+hh, Bind_ID]
}

GetRange2(key:="LButton")
{
  FindText_GetRange:=_Gui:=Gui()
  _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  _Gui.BackColor:="White"
  WinSetTransparent(10)
  this.GetBitsFromScreen(,,,,0,&x,&y,&w,&h)
  _Gui.Title:="FindText_GetRange"
  _Gui.Show("NA x" x " y" y " w" w " h" h)
  CoordMode "Mouse"
  tip:=this.Lang("s7"), oldx:=oldy:=""
  Loop
  {
    Sleep 50
    MouseGetPos &x1, &y1
    if (oldx=x1 && oldy=y1)
      Continue
    oldx:=x1, oldy:=y1
    ToolTip "x: " x1 " y: " y1 " w: 0 h: 0`n" tip
  }
  Until this.State(key) || this.State("Ctrl")
  Loop
  {
    Sleep 50
    MouseGetPos &x2, &y2
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
    this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip "x: " x " y: " y " w: " w " h: " h "`n" tip
  }
  Until !(this.State(key) || this.State("Ctrl"))
  ToolTip
  this.RangeTip()
  FindText_GetRange.Destroy()
  A_Clipboard:=x "," y "," (x+w-1) "," (y+h-1)
  return [x, y, x+w-1, y+h-1]
}

BitmapFromScreen(&x:=0, &y:=0, &w:=0, &h:=0
  , ScreenShot:=1, &zx:=0, &zy:=0, &zw:=0, &zh:=0)
{
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy,&zw,&zh)
  if (w<1 || h<1 || !bits.hBM)
    return
  hBM:=this.CreateDIBSection(w, h)
  this.CopyHBM(hBM, 0, 0, bits.hBM, x-zx, y-zy, w, h, 1)
  return hBM
}

; Quickly save screen image to BMP file for debugging
; if file = 0 or "", save to Clipboard

SavePic(file:=0, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  hBM:=this.BitmapFromScreen(&x, &y, &w, &h, ScreenShot)
  this.SaveBitmapToFile(file, hBM)
  DllCall("DeleteObject", "Ptr",hBM)
}

; Save Bitmap To File, if file = 0 or "", save to Clipboard
; hBM_or_file can be a bitmap handle or file path, eg: "c:\1.bmp"

SaveBitmapToFile(file, hBM_or_file, x:=0, y:=0, w:=0, h:=0)
{
  if IsNumber(hBM_or_file)
    hBM_or_file:="HBITMAP:*" hBM_or_file
  if !hBM:=DllCall("CopyImage", "Ptr",LoadPicture(hBM_or_file)
  , "int",0, "int",0, "int",0, "uint",0x2008)
    return
  if (file) || (w!=0 && h!=0)
  {
    (w=0 || h=0) && this.GetBitmapWH(hBM, &w, &h)
    hBM2:=this.CreateDIBSection(w, -h, bpp:=(file ? 24 : 32))
    this.CopyHBM(hBM2, 0, 0, hBM, x, y, w, h)
    DllCall("DeleteObject", "Ptr",hBM), hBM:=hBM2
  }
  dib:=Buffer(dib_size:=(A_PtrSize=8 ? 104:84), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",dib_size, "Ptr",dib)
  , pbi:=dib.Ptr+(bitmap_size:=A_PtrSize=8 ? 32:24)
  , size:=NumGet(pbi+20, "uint"), pBits:=NumGet(pbi-A_PtrSize, "Ptr")
  if (!file)
  {
    hdib:=DllCall("GlobalAlloc", "uint",2, "Ptr",40+size, "Ptr")
    pdib:=DllCall("GlobalLock", "Ptr",hdib, "Ptr")
    DllCall("RtlMoveMemory", "Ptr",pdib, "Ptr",pbi, "Ptr",40)
    DllCall("RtlMoveMemory", "Ptr",pdib+40, "Ptr",pBits, "Ptr",size)
    DllCall("GlobalUnlock", "Ptr",hdib)
    DllCall("OpenClipboard", "Ptr",0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint",8, "Ptr",hdib)
    DllCall("CloseClipboard")
  }
  else
  {
    if InStr(file,"\") && !FileExist(dir:=RegExReplace(file,"[^\\]*$"))
      Try DirCreate(dir)
    bf:=Buffer(14, 0), NumPut("short", 0x4D42, bf)
    NumPut("uint", 54+size, bf, 2), NumPut("uint", 54, bf, 10)
    f:=FileOpen(file, "w"), f.RawWrite(bf, 14)
    , f.RawWrite(pbi+0, 40), f.RawWrite(pBits+0, size), f.Close()
  }
  DllCall("DeleteObject", "Ptr",hBM)
}

; Show the saved Picture file

ShowPic(file:="", show:=1, &x:="", &y:="", &w:="", &h:="")
{
  if (file="")
  {
    this.ShowScreenShot()
    return
  }
  if !(hBM:=LoadPicture(file))
    return
  this.GetBitmapWH(hBM, &w, &h)
  bits:=this.GetBitsFromScreen(,,,,0,&x,&y,&zw,&zh)
  this.UpdateBits(bits, x, y, Max(w,zw), Max(h,zh))
  this.CopyHBM(bits.hBM, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
  if (show)
    this.ShowScreenShot(x, y, x+w-1, y+h-1, 0)
  return 1
}

; Show the memory Screenshot for debugging

ShowScreenShot(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  static hPic, oldx, oldy, oldw, oldh, FindText_Screen:=""
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
  {
    if (FindText_Screen)
      FindText_Screen.Destroy(), FindText_Screen:=""
    return
  }
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  if !hBM:=this.BitmapFromScreen(&x,&y,&w,&h,ScreenShot)
    return
  ;---------------
  if (!FindText_Screen)
  {
    FindText_Screen:=_Gui:=Gui()  ; WS_EX_NOACTIVATE:=0x08000000
    _Gui.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    _Gui.MarginX:=0, _Gui.MarginY:=0
    id:=_Gui.Add("Pic", "w" w " h" h), hPic:=id.Hwnd
    _Gui.Title:="Show Pic"
    _Gui.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  else if (oldx!=x || oldy!=y || oldw!=w || oldh!=h)
  {
    if (oldw!=w || oldh!=h)
      FindText_Screen[hPic].Move(,, w, h)
    FindText_Screen.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  this.BitmapToWindow(hPic, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
}

BitmapToWindow(hwnd, x1, y1, hBM, x2, y2, w, h)
{
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  hDC:=DllCall("GetDC", "Ptr",hwnd, "Ptr")
  DllCall("BitBlt", "Ptr",hDC, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC, "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("ReleaseDC", "Ptr",hwnd, "Ptr",hDC)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
}

; Quickly get the search data of screen image

GetTextFromScreen(x1:=0, y1:=0, x2:=0, y2:=0, Threshold:=""
  , ScreenShot:=1, &rx:="", &ry:="", cut:=1)
{
  if (x1=0 && y1=0 && x2=0 && y2=0)
    return this.Gui("CaptureS", ScreenShot)
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy)
  if (w<1 || h<1 || !bits.Scan0)
  {
    return
  }
  ListLines (lls:=A_ListLines)?0:0
  gs:=Map(), gs.Default:=0
  j:=bits.Stride-w*4, p:=bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4-j-4
  Loop h + 0*(k:=0)
  Loop w + 0*(p+=j)
    c:=NumGet(p+=4,"uint")
    , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  if InStr(Threshold,"**")
  {
    Threshold:=Trim(Threshold,"* "), (Threshold="" && Threshold:=50)
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop h + 0*(y1:=0)
    Loop w + 0*(y1++)
      i:=y1*sw+A_Index+1, j:=gs[i]+Threshold
      , s.=( gs[i-1]>j || gs[i+1]>j
      || gs[i-sw]>j || gs[i+sw]>j
      || gs[i-sw-1]>j || gs[i-sw+1]>j
      || gs[i+sw-1]>j || gs[i+sw+1]>j ) ? "1":"0"
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=Trim(Threshold,"* ")
    if (Threshold="")
    {
      pp:=Map(), pp.Default:=0
      Loop 256
        pp[A_Index-1]:=0
      Loop w*h
        pp[gs[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop w*h
      s.=gs[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ListLines lls
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  if (cut=1)
  {
    re1:="(^0{" w "}|^1{" w "})"
    re2:="(0{" w "}$|1{" w "}$)"
    While (s~=re1)
      s:=RegExReplace(s,re1), CutUp++
    While (s~=re2)
      s:=RegExReplace(s,re2), CutDown++
  }
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  return s
}

; Wait for the screen image to change within a few seconds
; Take a Screenshot before using it: FindText().ScreenShot()

WaitChange(time:=-1, x1:=0, y1:=0, x2:=0, y2:=0)
{
  hash:=this.GetPicHash(x1, y1, x2, y2, 0)
  time:=this.Floor(time), timeout:=A_TickCount+Round(time*1000)
  Loop
  {
    if (hash!=this.GetPicHash(x1, y1, x2, y2, 1))
      return 1
    if (time>=0 && A_TickCount>=timeout)
      Break
    Sleep 10
  }
  return 0
}

; Wait for the screen image to stabilize

WaitNotChange(time:=1, timeout:=30, x1:=0, y1:=0, x2:=0, y2:=0)
{
  oldhash:="", time:=this.Floor(time)
  , timeout:=A_TickCount+Round(this.Floor(timeout)*1000)
  Loop
  {
    hash:=this.GetPicHash(x1, y1, x2, y2, 1), t:=A_TickCount
    if (hash!=oldhash)
      oldhash:=hash, timeout2:=t+Round(time*1000)
    if (t>=timeout2)
      return 1
    if (t>=timeout)
      return 0
    Sleep 100
  }
}

GetPicHash(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  static init:=DllCall("LoadLibrary", "Str","ntdll", "Ptr")
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  if (w<1 || h<1 || !bits.Scan0)
    return 0
  hash:=0, Stride:=bits.Stride, p:=bits.Scan0+(y-1)*Stride+x*4, w*=4
  ListLines (lls:=A_ListLines)?0:0
  Loop h
    hash:=(hash*31+DllCall("ntdll\RtlComputeCrc32", "uint",0
      , "Ptr",p+=Stride, "uint",w, "uint"))&0xFFFFFFFF
  ListLines lls
  return hash
}

WindowToScreen(&x, &y, x1, y1, id:="")
{
  if (!id)
    id:=WinGetID("A")
  rect:=Buffer(16, 0)
  , DllCall("GetWindowRect", "Ptr",id, "Ptr",rect)
  , x:=x1+NumGet(rect,"int"), y:=y1+NumGet(rect,4,"int")
}

ScreenToWindow(&x, &y, x1, y1, id:="")
{
  this.WindowToScreen(&dx, &dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

ClientToScreen(&x, &y, x1, y1, id:="")
{
  if (!id)
    id:=WinGetID("A")
  pt:=Buffer(8, 0), NumPut("int64", 0, pt)
  , DllCall("ClientToScreen", "Ptr",id, "Ptr",pt)
  , x:=x1+NumGet(pt,"int"), y:=y1+NumGet(pt,4,"int")
}

ScreenToClient(&x, &y, x1, y1, id:="")
{
  this.ClientToScreen(&dx, &dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command PixelGetColor using CoordMode Settings

PixelGetColor(x, y, ScreenShot:=1, id:="")
{
  if (A_CoordModePixel="Window")
    this.WindowToScreen(&x, &y, x, y, id)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(&x, &y, x, y, id)
  if (ScreenShot)
    this.ScreenShot(x, y, x, y)
  return this.GetColor(x, y)
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command ImageSearch using CoordMode Settings
; ImageFile can use "*n *TransBlack/White/RRGGBB-DRDGDB... d:\a.bmp"

ImageSearch(&rx:="", &ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ImageFile:="", ScreenShot:=1, FindAll:=0, dir:=1)
{
  dx:=dy:=0
  if (A_CoordModePixel="Window")
    this.WindowToScreen(&dx, &dy, 0, 0)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(&dx, &dy, 0, 0)
  text:=""
  Loop Parse, ImageFile, "|"
  if (v:=Trim(A_LoopField))!=""
  {
    text.=InStr(v,"$") ? "|" v : "|##"
    . (RegExMatch(v, "(^|\s)\*(\d+)\s", &r)
    ? Format("{:06X}", r[2]<<16|r[2]<<8|r[2]) : "000000")
    . (RegExMatch(v, "i)(^|\s)\*Trans(\S+)\s", &r) ? "/" Trim(r[2],"/"):"")
    . "$" Trim(RegExReplace(v,"(^|\s)\*\S+"))
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x1:=y1:=-n, x2:=y2:=n
  if (ok:=this.FindText(,, x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll,,,, dir))
  {
    For k,v in ok  ; you can use ok:=FindText().ok
      v.1-=dx, v.2-=dy, v.x-=dx, v.y-=dy
    rx:=ok[1].1, ry:=ok[1].2
    return ok
  }
  else
  {
    rx:=ry:=""
    return 0
  }
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command PixelSearch using CoordMode Settings
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelSearch(&rx:="", &ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ColorID:="", Variation:=0, ScreenShot:=1, FindAll:=0, dir:=1)
{
  n:=this.Floor(Variation), text:=Format("##{:06X}$0/0/", n<<16|n<<8|n)
  . Trim(StrReplace(ColorID, "|", "/"), "- /")
  return this.ImageSearch(&rx, &ry, x1, y1, x2, y2, text, ScreenShot, FindAll, dir)
}

; Pixel count of certain colors within the range indicated by Screen Coordinates
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelCount(x1:=0, y1:=0, x2:=0, y2:=0, ColorID:="", Variation:=0, ScreenShot:=1)
{
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  sum:=0, s1:=Buffer(4), s0:=Buffer(4), ss:=Buffer(w*(h+3))
  ini:={ bits:bits, ss:ss.Ptr, s1:s1.Ptr, s0:s0.Ptr, allpos:0, allpos_max:0
    , err1:0, err0:0, zoomW:1, zoomH:1 }
  n:=this.Floor(Variation), text:=Format("##{:06X}$0/0/", n<<16|n<<8|n)
  . Trim(StrReplace(ColorID, "|", "/"), "- /")
  if IsObject(j:=this.PicInfo(text))
    sum:=this.PicFind(ini, j, 1, x, y, w, h)
  return sum
}

; Create color blocks containing a specified number of specified colors
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", "*128", "**50"
; Count1, Count0 is the minimum number of black and white dots after binarization of this color block

ColorBlock(ColorID, w, h, Count1:=0, Count0:=0)
{
  (Count0>0 && Count1:=0)
  Text:="|<>[" (1-Count1/(w*h)) "," (1-Count0/(w*h)) "]"
  . Trim(StrReplace(ColorID,"|","/"),"- /") . Format("${:d}.",w)
  . this.bit2base64(StrReplace(Format(Format("{{}:0{:d}d{}}",w*h),0),"0"
  , (Count0>0 ? "0":"1")))
  return Text
}

Click(x:="", y:="", other1:="", other2:="", GoBack:=0)
{
  CoordMode "Mouse", (bak:=A_CoordModeMouse)?"Screen":"Screen"
  if GoBack
    MouseGetPos &oldx, &oldy
  MouseMove x, y, 0
  Sleep 30
  Click x "," y "," other1 "," other2
  if GoBack
    MouseMove oldx, oldy, 0
  CoordMode "Mouse", bak
  return 1
}

; Running AHK code dynamically with new threads

Class Thread
{
  __New(args*)
  {
    this.pid:=this.Exec(args*)
  }
  __Delete()
  {
    ProcessClose this.pid
  }
  Exec(s, Ahk:="", args:="")    ; required AHK v1.1.34+ and Ahk2Exe Use .exe
  {
    Ahk:=Ahk ? Ahk : A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    s:="`nDllCall(`"SetWindowText`",`"Ptr`",A_ScriptHwnd,`"Str`",`"<AHK>`")`n"
      . "`n`n" . s, s:=RegExReplace(s, "\R", "`r`n")
    Try
    {
      shell:=ComObject("WScript.Shell")
      oExec:=shell.Exec("`"" Ahk "`" /script /force /CP0 * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`r`nTry FileDelete `"" f "`"`r`n" s
      Try FileDelete f
      FileAppend s, f
      r:=this.Clear.Bind(this)
      SetTimer r, -3000
      Run "`"" Ahk "`" /script /force /CP0 `"" f "`" " args,,, &pid
    }
    return pid
  }
  Clear()
  {
    Try FileDelete A_Temp "\~ahk.tmp"
    SetTimer(,0)
  }
}

; FindText().QPC() Use the same as A_TickCount

QPC()
{
  static f:=0, c:=DllCall("QueryPerformanceFrequency", "Int64*",&f)+(f/=1000)
  return (!DllCall("QueryPerformanceCounter", "Int64*",&c))*0+(c/f)
}

; FindText().ToolTip() Use the same as ToolTip

ToolTip(s:="", x:="", y:="", num:=1, arg:="")
{
  static ini:=Map(), tip:=Map(), timer:=Map()
  f:="ToolTip_" . this.Floor(num)
  if (s="")
  {
    Try tip[f].Destroy()
    ini[f]:="", tip[f]:=""
    return
  }
  ;-----------------
  r1:=A_CoordModeToolTip
  r2:=A_CoordModeMouse
  CoordMode "Mouse", "Screen"
  MouseGetPos &x1, &y1
  CoordMode "Mouse", r1
  MouseGetPos &x2, &y2
  CoordMode "Mouse", r2
  (x!="" && x:="x" (this.Floor(x)+x1-x2))
  , (y!="" && y:="y" (this.Floor(y)+y1-y2))
  , (x="" && y="" && x:="x" (x1+16) " y" (y1+16))
  ;-----------------
  (!IsObject(arg) && arg:={})
  bgcolor:=arg.HasOwnProp("bgcolor") ? arg.bgcolor : "FAFBFC"
  color:=arg.HasOwnProp("color") ? arg.color : "Black"
  font:=arg.HasOwnProp("font") ? arg.font : "Consolas"
  size:=arg.HasOwnProp("size") ? arg.size : "10"
  bold:=arg.HasOwnProp("bold") ? arg.bold : ""
  trans:=arg.HasOwnProp("trans") ? arg.trans & 255 : 255
  timeout:=arg.HasOwnProp("timeout") ? arg.timeout : ""
  ;-----------------
  r:=bgcolor "|" color "|" font "|" size "|" bold "|" trans "|" s
  if (!ini.Has(f) || ini[f]!=r)
  {
    ini[f]:=r
    Try tip[f].Destroy()
    tip[f]:=_Gui:=Gui()  ; WS_EX_LAYERED:=0x80000, WS_EX_TRANSPARENT:=0x20
    _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x80020")
    _Gui.MarginX:=2, _Gui.MarginY:=2
    _Gui.BackColor:=bgcolor
    _Gui.SetFont("c" color " s" size " " bold, font)
    _Gui.Add("Text",, s)
    _Gui.Title:=f
    _Gui.Show("Hide")
    WinSetTransparent(trans)
  }
  tip[f].Opt("+AlwaysOnTop")
  tip[f].Show("NA " x " " y)
  if (timeout)
  {
    (!timer.Has(f) && timer[f]:=this.ToolTip.Bind(this,"","","",num))
    SetTimer timer[f], -Round(Abs(this.Floor(timeout)*1000))-1
  }
}

; FindText().ObjView()  view object values for Debug

ObjView(obj, keyname:="")
{
  if IsObject(obj)
  {
    s:=""
    For k,v in (HasMethod(obj,"__Enum") ? obj : obj.OwnProps())
      s.=this.ObjView(v, keyname "[" ((k is Integer) ? k : "`"" k "`"") "]")
  }
  else
    s:=keyname ": " ((obj is Number) ? obj : "`"" obj "`"") "`n"
  if (keyname!="")
    return s
  ;------------------
  _Gui:=Gui("+AlwaysOnTop")
  _Gui.Add("Button", "y270 w350 Default", "OK").OnEvent("Click",(*)=>WinHide())
  _Gui.Add("Edit", "xp y10 w350 h250 -Wrap -WantReturn")
  _Gui["Edit1"].Value:=s
  _Gui.Title:="Debug view object values"
  _Gui.Show()
  DetectHiddenWindows 0
  WinWaitClose "ahk_id " _Gui.Hwnd
  _Gui.Destroy()
}

EditScroll(hEdit, regex:="", line:=0, pos:=0)
{
  s:=ControlGetText(hEdit)
  pos:=(regex!="") ? InStr(SubStr(s,1,s~=regex) " ","`n",0,-1)
    : (line>1) ? InStr(s,"`n",0,1,line-1) : pos
  SendMessage 0xB1, pos, pos, hEdit
  SendMessage 0xB7,,, hEdit
}

LastCtrl()
{
  For Ctrl in GuiFromHwnd(WinExist())
    last:=Ctrl
  return last
}

Hide(args*)
{
  WinMinimize
  WinHide
  ToolTip
  DetectHiddenWindows 0
  WinWaitClose "ahk_id " WinExist()
}

SC(RGB, hwnd)
{
  SendMessage 0x2001,0,(RGB&0xFF)<<16|RGB&0xFF00|(RGB>>16)&0xFF,hwnd
}


;==== Optional GUI interface ====


Gui(cmd, arg1:="", args*)
{
  static
  local cri, lls, _Gui
  ListLines InStr("MouseMove|ToolTipOff",cmd)?0:A_ListLines
  static init:=0
  if (!init && init:=1)
  {
    SavePicDir:=A_Temp "\Ahk_ScreenShot\"
    G_ := this.Gui.Bind(this)
    G_G := this.Gui.Bind(this, "G")
    G_Run := this.Gui.Bind(this, "Run")
    G_Show := this.Gui.Bind(this, "Show")
    G_KeyDown := this.Gui.Bind(this, "KeyDown")
    G_LButtonDown := this.Gui.Bind(this, "LButtonDown")
    G_RButtonDown := this.Gui.Bind(this, "RButtonDown")
    G_MouseMove := this.Gui.Bind(this, "MouseMove")
    G_ScreenShot := this.Gui.Bind(this, "ScreenShot")
    G_ShowPic := this.Gui.Bind(this, "ShowPic")
    G_Slider := this.Gui.Bind(this, "Slider")
    G_ToolTip := this.Gui.Bind(this, "ToolTip")
    G_ToolTipOff := this.Gui.Bind(this, "ToolTipOff")
    G_SaveScr := this.Gui.Bind(this, "SaveScr")
    G_PicShowOK := this.Gui.Bind(this, "PicShowOK")
    G_Drag := this.Gui.Bind(this, "Drag")
    FindText_Capture:=FindText_Main:=""
    PrevControl:=x:=y:=oldx:=oldy:=""
    Pics:=Map(), hBM_old:=dx:=dy:=0
    cri:=A_IsCritical
    Critical
    Lang:=this.Lang(,1), Tip_Text:=this.Lang(,2)
    G_.Call("MakeCaptureWindow")
    G_.Call("MakeMainWindow")
    OnMessage(0x100, G_KeyDown)
    OnMessage(0x201, G_LButtonDown)
    OnMessage(0x204, G_RButtonDown)
    OnMessage(0x200, G_MouseMove)
    MenuTray:=A_TrayMenu
    MenuTray.Add
    MenuTray.Add Lang["s1"], G_Show
    if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
    {
      MenuTray.Default:=Lang["s1"]
      MenuTray.ClickCount:=1
      TraySetIcon "Shell32.dll", 23
    }
    Critical cri
    Gui("+LastFound").Destroy()
  }
  Switch cmd, 1
  {
  Case "G":
    id:=this.LastCtrl()
    Try id.OnEvent("Click", G_Run)
    Catch
      Try id.OnEvent("Change", G_Run)
    return
  Case "Run":
    Critical
    G_.Call(arg1.Name)
    return
  Case "Show":
    FindText_Main.Show(arg1 ? "Center" : "")
    ControlFocus hscr
    return
  Case "Cancel", "Cancel2":
    WinHide
    return
  Case "MakeCaptureWindow":
    WindowColor:="0xDDEEFF"
    Try FindText_Capture.Destroy()
    FindText_Capture:=_Gui:=Gui()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    Tab:=_Gui.Add("Tab3", "vMyTab1 -Wrap", StrSplit(Lang["s18"],"|"))
    Tab.UseTab(1)
    C_:=Map(), Cid_:=Map()
    , nW:=71, nH:=25, w:=h:=12, pW:=nW*(w+1)-1, pH:=(nH+1)*(h+1)-1
    id:=_Gui.Add("Text", "w" pW " h" pH), Cid_[id.Hwnd]:=-1
    _Gui.Opt("-Theme")
    ListLines (lls:=A_ListLines)?0:0
    Loop nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "xp yp Section" : Mod(i,nW)=1 ? "xs y+1":"x+1"
      id:=_Gui.Add("Progress", j " w" w " h" h " -E0x20000 Smooth")
      C_[i]:=id.Hwnd, Cid_[id.Hwnd]:=i
    }
    ListLines lls
    _Gui.Opt("+Theme")
    _Gui.Add("Slider", "xs w" pW " vMySlider1 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider2 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    Tab.UseTab(2)
    id:=_Gui.Add("Pic", "w" (pW-135) " h" pH " +Border -Background Section"), hPic:=id.Hwnd
    Pic_hBM:=this.CreateDIBSection(Pic_w:=(pW-135), Pic_h:=pH)
    _Gui.Add("Slider", "xs wp vMySlider3 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider4 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    _Gui.Add("ListBox", "ys w120 h200 vSelectBox AltSubmit 0x100")
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vClearAll", Lang["ClearAll"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vOpenDir", Lang["OpenDir"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vLoadPic", Lang["LoadPic"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vSavePic", Lang["SavePic"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Text", "xm Section", Lang["SelGray"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelGray ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelColor"])
    _Gui.Add("Edit", "x+5 yp-3 w150 vSelColor ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelR"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelR ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelG"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelG ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelB"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelB ReadOnly")
    ;--------------
    id:=_Gui.Add("Button", "xm Hidden Section", Lang["Auto"])
    id.GetPos(&pX, &pY, &pW, &pH)
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    _Gui.Add("Button", "xm+" i " yp w" w " hp -Wrap vRepU", Lang["RepU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU", Lang["CutU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU3", Lang["CutU3"])
    G_G.Call()
    _Gui.Add("Button", "xm wp hp -Wrap vRepL", Lang["RepL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL", Lang["CutL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL3", Lang["CutL3"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" pW " hp -Wrap vAuto", Lang["Auto"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" w " hp -Wrap vRepR", Lang["RepR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR", Lang["CutR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR3", Lang["CutR3"])
    G_G.Call()
    _Gui.Add("Button", "xm+" i " wp hp -Wrap vRepD", Lang["RepD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD", Lang["CutD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD3", Lang["CutD3"])
    G_G.Call()
    ;--------------
    Tab:=_Gui.Add("Tab3", "ys -Wrap", StrSplit(Lang["s2"],"|"))
    Tab.UseTab(1)
    _Gui.Add("Text", "x+30 y+35", Lang["Threshold"])
    _Gui.Add("Edit", "x+15 w100 vThreshold")
    _Gui.Add("Button", "x+15 yp-3 vGray2Two", Lang["Gray2Two"])
    G_G.Call()
    Tab.UseTab(2)
    _Gui.Add("Text", "x+30 y+35", Lang["GrayDiff"])
    _Gui.Add("Edit", "x+15 w100 vGrayDiff", "50")
    _Gui.Add("Button", "x+15 yp-3 vGrayDiff2Two", Lang["GrayDiff2Two"])
    G_G.Call()
    Tab.UseTab(3)
    _Gui.Add("Text", "x+10 y+15 Section", Lang["Similar1"] " 0")
    _Gui.Add("Slider", "x+0 w100 vSimilar1 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+10 ys-2 vAddColorSim", Lang["AddColorSim"])
    G_G.Call()
    _Gui.Add("Text", "x+25 ys+4", Lang["DiffRGB2"])
    _Gui.Add("Edit", "x+5 ys w80 vDiffRGB2 Limit3")
    _Gui.Add("UpDown", "vdRGB2 Range0-255 Wrap", 50)
    _Gui.Add("Button", "x+10 ys-2 vAddColorDiff", Lang["AddColorDiff"])
    G_G.Call()
    _Gui.Add("Button", "xs vUndo2", Lang["Undo2"])
    G_G.Call()
    _Gui.Add("Edit", "x+10 yp+2 w340 vColorList")
    _Gui.Add("Button", "x+10 yp-2 vColor2Two", Lang["Color2Two"])
    G_G.Call()
    Tab.UseTab(4)
    _Gui.Add("Text", "x+30 y+35", Lang["Similar2"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar2 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 yp-3 vColorPos2Two", Lang["ColorPos2Two"])
    G_G.Call()
    Tab.UseTab(5)
    _Gui.Add("Text", "x+30 y+15 Section", Lang["Similar3"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar3 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 ys-2 vUndo", Lang["Undo"])
    G_G.Call()
    _Gui.Add("Checkbox", "xs vMultiColor", Lang["MultiColor"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+50 vFindShape", Lang["FindShape"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Button", "xm vReset", Lang["Reset"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+15 yp+5 vModify", Lang["Modify"])
    G_G.Call()
    _Gui.Add("Text", "x+30", Lang["Comment"])
    _Gui.Add("Edit", "x+5 yp-2 w250 vComment")
    _Gui.Add("Button", "x+10 yp-3 vSplitAdd", Lang["SplitAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vAllAdd", Lang["AllAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+30 wp vOK", Lang["OK"])
    G_G.Call()
    _Gui.Add("Button", "x+15 wp vCancel", Lang["Cancel"])
    G_G.Call()
    _Gui.Add("Button", "xm vBind0", Lang["Bind0"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind1", Lang["Bind1"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind2", Lang["Bind2"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind3", Lang["Bind3"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind4", Lang["Bind4"])
    G_G.Call()
    _Gui.Add("Button", "x+30 vSavePic2", Lang["SavePic2"])
    G_G.Call()
    _Gui.Title:=Lang["s3"]
    _Gui.Show("Hide")
    _Gui.OnEvent("DropFiles", G_Drag)
    return
  Case "Drag":
    Try G_.Call("LoadPic", args[2][1])
    return
  Case "MakeMainWindow":
    Try FindText_Main.Destroy()
    FindText_Main:=_Gui:=Gui()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    _Gui.Add("Text", "xm", Lang["NowHotkey"])
    _Gui.Add("Edit", "x+5 w160 vNowHotkey ReadOnly")
    _Gui.Add("Hotkey", "x+5 w160 vSetHotkey1")
    s:="F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|LWin|Ctrl|Shift|Space|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    _Gui.Add("DDL", "x+5 w160 vSetHotkey2", StrSplit(s,"|"))
    _Gui.Add("Button", "x+15 vApply", Lang["Apply"])
    G_G.Call()
    _Gui.Add("GroupBox", "xm y+0 w280 h55 vMyGroup cBlack")
    _Gui.Add("Text", "xp+15 yp+20 Section", Lang["Myww"] ": ")
    _Gui.Add("Text", "x+0 w80", nW//2)
    _Gui.Add("UpDown", "vMyww Range1-100", nW//2)
    _Gui.Add("Text", "x+15 ys", Lang["Myhh"] ": ")
    _Gui.Add("Text", "x+0 w80", nH//2)
    id:=_Gui.Add("UpDown", "vMyhh Range1-100", nH//2)
    id.GetPos(&pX, &pY, &pW, &pH)
    _Gui["MyGroup"].Move(,, pX+pW, pH+30)
    id:=_Gui.Add("Checkbox", "x+100 ys vAddFunc", Lang["AddFunc"] " FindText()")
    id.GetPos(&pX, &pY, &pW, &pH)
    pW:=pX+pW-15, pW:=(pW<720?720:pW), w:=pW//5
    _Gui.Add("Button", "xm y+18 w" w " vCutL2", Lang["CutL2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutR2", Lang["CutR2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutU2", Lang["CutU2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutD2", Lang["CutD2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vUpdate", Lang["Update"])
    G_G.Call()
    _Gui.SetFont("s6 bold", "Verdana")
    _Gui.Add("Edit", "xm y+10 w" pW " h260 vMyPic -Wrap HScroll")
    _Gui.SetFont("s12 norm", "Verdana")
    w:=pW//3
    _Gui.Add("Button", "xm w" w " vCapture", Lang["Capture"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vTest", Lang["Test"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCopy", Lang["Copy"])
    G_G.Call()
    _Gui.Add("Button", "xm y+0 wp vCaptureS", Lang["CaptureS"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetRange", Lang["GetRange"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetOffset", Lang["GetOffset"])
    G_G.Call()
    _Gui.Add("Edit", "xm y+10 w130 hp vClipText")
    _Gui.Add("Button", "x+0 vPaste", Lang["Paste"])
    G_G.Call()
    _Gui.Add("Button", "x+0 vTestClip", Lang["TestClip"])
    G_G.Call()
    id:=_Gui.Add("Button", "x+0 vGetClipOffset", Lang["GetClipOffset"])
    G_G.Call()
    id.GetPos(&x,, &w)
    w:=((pW+15)-(x+w))//2
    _Gui.Add("Edit", "x+0 w" w " hp vOffset")
    _Gui.Add("Button", "x+0 wp vCopyOffset", Lang["CopyOffset"])
    G_G.Call()
    _Gui.SetFont("cBlue")
    id:=_Gui.Add("Edit", "xm w" pW " h250 vscr -Wrap HScroll"), hscr:=id.Hwnd
    _Gui.Title:=Lang["s4"]
    _Gui.Show("Hide")
    G_.Call("LoadScr")
    OnExit(G_SaveScr)
    return
  Case "LoadScr":
    f:=A_Temp "\~scr2.tmp"
    Try s:="", s:=FileRead(f)
    FindText_Main["scr"].Value:=s
    return
  Case "SaveScr":
    f:=A_Temp "\~scr2.tmp"
    s:=FindText_Main["scr"].Value
    Try FileDelete f
    FileAppend s, f
    return
  Case "Capture", "CaptureS":
    _Gui:=FindText_Main
    if show_gui:=WinExist("ahk_id " _Gui.Hwnd)
      this.Hide()
    if (cmd="Capture")
    {
      w:=_Gui["Myww"].Value
      h:=_Gui["Myhh"].Value
      p:=this.GetRange(w, h)
      sx:=p[1], sy:=p[2], sw:=p[3]-p[1]+1, sh:=p[4]-p[2]+1
      , Bind_ID:=p[5], bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(1)
    }
    else
    {
      sx:=0, sy:=0, sw:=1, sh:=1, Bind_ID:=WinExist("A"), bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(2)
    }
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(&x,&y,&w,&h,(arg1=0?0:1))
    Pics:=Map(), Pics[hBM]:=1, hBM_x:=hBM_y:=0
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    Names:=["HBITMAP:*" hBM], s:="<New>"
    Loop Files, SavePicDir "*.bmp"
      Names.Push(v:=A_LoopFileFullPath), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    _Gui["SelectBox"].Delete()
    _Gui["SelectBox"].Add(StrSplit(Trim(s,"|"),"|"))
    ;------------------------
    s:="SelGray|SelColor|SelR|SelG|SelB|Threshold|Comment|ColorList"
    Loop Parse, s, "|"
      _Gui[A_LoopField].Value:=""
    For k,v in ["Similar1","Similar2","Similar3"]
      _Gui[v].Value:=90
    _Gui["Modify"].Value:=Modify:=0
    _Gui["MultiColor"].Value:=MultiColor:=0
    _Gui["FindShape"].Value:=FindShape:=0
    _Gui["GrayDiff"].Value:=50
    _Gui["Gray2Two"].Focus()
    _Gui["Gray2Two"].Opt("+Default")
    _Gui.Show("Center")
    Event:=Result:=""
    DetectHiddenWindows 0
    Critical "Off"
    WinWaitClose "ahk_id " _Gui.Hwnd
    Critical
    ToolTip
    Pics[hBM]:=1, hBM_old:=0
    For k,v in Pics
      Try DllCall("DeleteObject", "Ptr",k)
    Text:=RegExMatch(Result,"\|<[^>\n]*>[^$\n]+\$[^`"'\r\n]+",&r)?r[0]:""
    ;------------------------
    _Gui:=FindText_Main
    if (bind_mode!="")
    {
      tt:=WinGetTitle(Bind_ID)
      tc:=WinGetClass(Bind_ID)
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt, "[;``]", "``$0"), "`"","```"")
      Result:="`nSetTitleMatchMode 2`nid:=WinExist(`"" tt "`")"
        . "`nFindText().BindWindow(id" (bind_mode=0 ? "":"," bind_mode)
        . ")  `; " Lang["s6"] " FindText().BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      s:=""
      if (!A_IsCompiled)
        Try s:=FileRead(A_LineFile)
      re:="i)\n\s*FindText[^\n]+args\*[\s\S]*?Script_End[(){}\s]+}"
      s:=RegExMatch(s, re, &r) ? "`n;==========`n" r[0] "`n" : ""
      _Gui["scr"].Value:=Result "`n" s
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    else if (Event="SplitAdd" || Event="AllAdd")
    {
      s:=_Gui["scr"].Value
      r:=SubStr(s, 1, InStr(s,"=FindText("))
      i:=j:=0, re:="<[^>\n]*>[^$\n]+\$[^`"'\r\n]+"
      While j:=RegExMatch(r, re,, j+1)
        i:=InStr(r, "`n", 0, j)
      _Gui["scr"].Value:=SubStr(s,1,i) . Result . SubStr(s,i+1)
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    if (Event) && RegExMatch(Result, "\$\d+\.[\w+/]{1,100}", &r)
      this.EditScroll(hscr, "\Q" r[0] "\E")
    Event:=Result:=s:=""
    ;----------------------
    if (show_gui && arg1="")
      G_Show.Call()
    else A_Clipboard:=Text
    return Text
  Case "CaptureUpdate":
    nX:=sx, nY:=sy, nW:=sw, nH:=sh
    bits:=this.GetBitsFromScreen(&nX,&nY,&nW,&nH,0,&zx,&zy)
    cors:=Map(), cors.Default:=0
    , show:=Map(), show.Default:=0
    , ascii:=Map(), ascii.Default:=0
    , SelPos:=bg:=color:=Result:=""
    , dx:=dy:=CutLeft:=CutRight:=CutUp:=CutDown:=0
    ListLines (lls:=A_ListLines)?0:0
    if (nW>0 && nH>0 && bits.Scan0)
    {
      j:=bits.Stride-nW*4, p:=bits.Scan0+(nY-zy)*bits.Stride+(nX-zx)*4-j-4
      Loop nH + 0*(k:=0)
      Loop nW + 0*(p+=j)
        show[++k]:=1, cors[k]:=NumGet(p+=4,"uint")
    }
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)<nW && ty<nH ? cors[ty*nW+tx+1]:WindowColor), C_[++k])
    Loop 71 + 0*(k:=71*25)
      this.SC(0xFFFFAA, C_[++k])
    ListLines lls
    _Gui:=FindText_Capture
    _Gui["MySlider1"].Enabled:=nW>71
    _Gui["MySlider2"].Enabled:=nH>25
    _Gui["MySlider1"].Value:=0
    _Gui["MySlider2"].Value:=0
    return
  Case "PicUpdate":
    Try i:=0, i:=Pics.Has(hBM_old)
    Try (!i) && DllCall("DeleteObject", "Ptr",hBM_old)
    this.GetBitmapWH(hBM, &hBM_w, &hBM_h), hBM_old:=hBM
    G_.Call("PicShow", 1)
    return
  Case "MySlider3", "MySlider4":
    hBM_x:=Round(FindText_Capture["MySlider3"].Value*(hBM_w-Pic_w)/100)
    hBM_y:=Round(FindText_Capture["MySlider4"].Value*(hBM_h-Pic_h)/100)
    G_.Call("PicShow")
    return
  Case "PicShow":
    w:=hBM_w-Pic_w, h:=hBM_h-Pic_h
    , hBM_x:=Max(Min(hBM_x,w),0), hBM_y:=Max(Min(hBM_y,h),0)
    if (w<0 || h<0)
      this.DrawHBM(Pic_hBM, [[0, 0, Pic_w, Pic_h, WindowColor]])
    this.CopyHBM(Pic_hBM,0,0,hBM,hBM_x,hBM_y,Min(Pic_w,hBM_w),Min(Pic_h,hBM_h))
    if (arg1)
      G_PicShowOK.Call()
    else
    {
      this.BitmapToWindow(hPic,0,0,Pic_hBM,0,0,Pic_w,Pic_h)
      SetTimer G_PicShowOK, -1000
    }
    FindText_Capture["MySlider3"].Value:=w>0?Round(hBM_x/w*100):0
    FindText_Capture["MySlider4"].Value:=h>0?Round(hBM_y/h*100):0
    return
  Case "PicShowOK":
    FindText_Capture[hPic].Value:="*w0 *h0 HBITMAP:*" Pic_hBM
    return
  Case "Reset":
    G_.Call("CaptureUpdate")
    return
  Case "LoadPic":
    FindText_Capture.Opt("+OwnDialogs")
    f:=arg1
    if (f="")
    {
      if !FileExist(SavePicDir)
        DirCreate SavePicDir
      f:=SavePicDir "*.bmp"
      Loop Files, f
        f:=A_LoopFileFullPath
      f:=FileSelect(, f, "Select Picture")
    }
    if !InStr(f,"HBITMAP:") && !FileExist(f)
    {
      MsgBox Lang["s17"], "Tip", "4096 T1"
      return
    }
    if !this.ShowPic(f, 0, &sx, &sy, &sw, &sh)
      return
    hBM:=this.BitmapFromScreen(&sx, &sy, &sw, &sh, 0)
    sw:=Min(sw,71), sh:=Min(sh,25)
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    return
  Case "SavePic":
    FindText_Capture.Hide()
    this.ScreenShot(), this.ShowPic("HBITMAP:*" hBM)
    Try GuiFromHwnd(WinExist("Show Pic")).Opt("+OwnDialogs")
    Loop
    {
      p:=this.GetRange2()
      r:=MsgBox(Lang["s15"], "Tip", "4099")
      if (r!="No")
        Break
    }
    if (r="Yes")
      G_.Call("ScreenShot", p[1] "|" p[2] "|" p[3] "|" p[4] "|0")
    this.ShowPic()
    return
  Case "SelectBox":
    SelectBox:=FindText_Capture["SelectBox"].Value
    Try f:="", f:=Names[SelectBox]
    if (f!="")
      G_.Call("LoadPic", f)
    return
  Case "ClearAll":
    FindText_Capture.Opt("+OwnDialogs")
    if MsgBox(Lang["s19"], "Tip", "4100")="Yes"
    {
      FindText_Capture.Hide()
      Try FileDelete SavePicDir "*.bmp"
    }
    return
  Case "OpenDir":
    if !FileExist(SavePicDir)
      DirCreate SavePicDir
    Run SavePicDir
    return
  Case "GetRange":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    p:=this.GetRange2(), v:=p[1] ", " p[2] ", " p[3] ", " p[4]
    s:=_Gui["scr"].Value
    re:="i)(=FindText\([^\n]*?)([^(,\n]*,){4}([^,\n]*,[^,\n]*,[^,\n]*Text)"
    if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
    {
      s:=RegExReplace(s, re, "$1 " v ",$3",, 1)
      _Gui["scr"].Value:=s
    }
    _Gui["Offset"].Value:=v
    G_Show.Call()
    return
  Case "Test", "TestClip":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    ;----------------------
    if (cmd="Test")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if (cmd="Test") && InStr(s, "MCode(")
    {
      s:="`nA_TrayMenu.ClickCount:=1`n" s "`nExitApp`n"
      Thread1:=FindTextClass.Thread(s)
      DetectHiddenWindows 1
      if WinWait("ahk_class AutoHotkey ahk_pid " Thread1.pid,, 3)
        WinWaitClose(,, 30)
      ; Thread1:=""  ; kill the Thread
    }
    else
    {
      t:=A_TickCount, v:=X:=Y:=""
      if RegExMatch(s, "<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
        v:=this.FindText(&X, &Y, 0,0,0,0, 0,0, r[0])
      r:=StrSplit(Lang["s8"] "||||", "|")
      MsgBox r[1] ":`t" (IsObject(v)?v.Length:v) "`n`n"
        . r[2] ":`t" (A_TickCount-t) " " r[3] "`n`n"
        . r[4] ":`t" X ", " Y "`n`n"
        . r[5] ":`t<" (IsObject(v)?v[1].id:"") ">", "Tip", "4096 T3"
      Try For i,j in v
        if (i<=2)
          this.MouseTip(j.x, j.y)
      v:="", A_Clipboard:=X "," Y
    }
    ;----------------------
    G_Show.Call()
    return
  Case "GetOffset", "GetClipOffset":
    FindText_Main.Hide()
    p:=this.GetRange()
    _Gui:=FindText_Main
    if (cmd="GetOffset")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if RegExMatch(s, "<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
    && this.FindText(&X, &Y, 0,0,0,0, 0,0, r[0])
    {
      r:=StrReplace("X+" ((p[1]+p[3])//2-X)
        . ", Y+" ((p[2]+p[4])//2-Y), "+-", "-")
      if (cmd="GetOffset")
      {
        re:="i)(\(\)\.\w*Click\w*\()[^,\n]*,[^,)\n]*"
        if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
          s:=RegExReplace(s, re, "$1" r,, 1)
        _Gui["scr"].Value:=s
      }
      _Gui["Offset"].Value:=r
    }
    s:="", G_Show.Call()
    return
  Case "Paste":
    if RegExMatch(A_Clipboard, "\|?<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
    {
      FindText_Main["ClipText"].Value:=r[0]
      FindText_Main["MyPic"].Value:=Trim(this.ASCII(r[0]),"`n")
    }
    return
  Case "CopyOffset":
    A_Clipboard:=FindText_Main["Offset"].Value
    return
  Case "Copy":
    s:=EditGetSelectedText(hscr)
    if (s="")
    {
      s:=FindText_Main["scr"].Value
      r:=FindText_Main["AddFunc"].Value
      if (r != 1)
        s:=RegExReplace(s, "i)\n\s*FindText[^\n]+args\*[\s\S]*")
        , s:=RegExReplace(s, "i)\n; ok:=FindText[\s\S]*")
        , s:=SubStr(s, (s~="i)\n[ \t]*Text"))
    }
    A_Clipboard:=RegExReplace(s, "\R", "`r`n")
    ControlFocus hscr
    return
  Case "Apply":
    _Gui:=FindText_Main
    NowHotkey:=_Gui["NowHotkey"].Value
    SetHotkey1:=_Gui["SetHotkey1"].Value
    SetHotkey2:=_Gui["SetHotkey2"].Text
    if (NowHotkey!="")
      Try Hotkey "*" NowHotkey,, "Off"
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Try Hotkey "*" k, G_ScreenShot, "On"
    _Gui["NowHotkey"].Value:=k
    _Gui["SetHotkey1"].Value:=""
    _Gui["SetHotkey2"].Choose(0)
    return
  Case "ScreenShot":
    Critical
    if !FileExist(SavePicDir)
      DirCreate SavePicDir
    Loop
      f:=SavePicDir . Format("{:03d}.bmp",A_Index)
    Until !FileExist(f)
    this.SavePic(f, StrSplit(arg1,"|")*)
    CoordMode "ToolTip"
    this.ToolTip(Lang["s9"],, 0,, { bgcolor:"Yellow", color:"Red"
      , size:48, bold:"bold", trans:200, timeout:0.2 })
    return
  Case "Bind0", "Bind1", "Bind2", "Bind3", "Bind4":
    this.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,5))
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(&x,&y,&w,&h,1)
    G_.Call("PicUpdate")
    FindText_Capture["MyTab1"].Choose(2)
    this.BindWindow(0)
    return
  Case "MySlider1", "MySlider2":
    SetTimer G_Slider, -10
    return
  Case "Slider":
    Critical
    dx:=nW>71 ? Round(FindText_Capture["MySlider1"].Value*(nW-71)/100):0
    dy:=nH>25 ? Round(FindText_Capture["MySlider2"].Value*(nH-25)/100):0
    if (oldx=dx && oldy=dy)
      return
    ListLines (lls:=A_ListLines)?0:0
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)>=nW || ty>=nH || !show[i:=ty*nW+tx+1]
      ? WindowColor : bg="" ? cors[i] : ascii[i] ? 0:0xFFFFFF), C_[++k])
    Loop 71*(oldx!=dx) + 0*(i:=nW*nH+dx)*(k:=71*25)
      this.SC((show[++i]?0xFF0000:0xFFFFAA), C_[++k])
    ListLines lls
    oldx:=dx, oldy:=dy
    return
  Case "RepColor", "CutColor":
    if (cmd="RepColor")
      show[k]:=1, c:=(bg="" ? cors[k] : ascii[k] ? 0:0xFFFFFF)
    else
      show[k]:=0, c:=WindowColor
    if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
      this.SC(c, C_[ty*71+tx+1])
    return
  Case "RepL":
    if (CutLeft<=0) || (bg!="" && InStr(color,"**") && CutLeft=1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutL3":
    Loop 3
      G_.Call("CutL")
    return
  Case "RepR":
    if (CutRight<=0) || (bg!="" && InStr(color,"**") && CutRight=1)
      return
    k:=1-CutRight, CutRight--
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutR3":
    Loop 3
      G_.Call("CutR")
    return
  Case "RepU":
    if (CutUp<=0) || (bg!="" && InStr(color,"**") && CutUp=1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutU3":
    Loop 3
      G_.Call("CutU")
    return
  Case "RepD":
    if (CutDown<=0) || (bg!="" && InStr(color,"**") && CutDown=1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutD3":
    Loop 3
      G_.Call("CutD")
    return
  Case "Gray2Two":
    ListLines (lls:=A_ListLines)?0:0
    gs:=Map(), gs.Default:=0, k:=0
    Loop nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    _Gui:=FindText_Capture
    _Gui["Threshold"].Focus()
    Threshold:=_Gui["Threshold"].Value
    if (Threshold="")
    {
      pp:=Map(), pp.Default:=0
      Loop 256
        pp[A_Index-1]:=0
      Loop nW*nH
        if (show[A_Index])
          pp[gs[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      _Gui["Threshold"].Value:=Threshold
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop nW*nH
      ascii[++k]:=v:=(gs[k]<=Threshold)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines lls
    return
  Case "GrayDiff2Two":
    _Gui:=FindText_Capture
    GrayDiff:=_Gui["GrayDiff"].Value
    if (GrayDiff="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox Lang["s11"], "Tip", "4096 T1"
      return
    }
    ListLines (lls:=A_ListLines)?0:0
    gs:=Map(), gs.Default:=0, k:=0
    Loop nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    if (CutLeft=0)
      G_.Call("CutL")
    if (CutRight=0)
      G_.Call("CutR")
    if (CutUp=0)
      G_.Call("CutU")
    if (CutDown=0)
      G_.Call("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop nW*nH
      j:=gs[++k]+GrayDiff
      , ascii[k]:=v:=( gs[k-1]>j || gs[k+1]>j
      || gs[k-nW]>j || gs[k+nW]>j
      || gs[k-nW-1]>j || gs[k-nW+1]>j
      || gs[k+nW-1]>j || gs[k+nW+1]>j )
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines lls
    return
  Case "AddColorSim", "AddColorDiff":
    _Gui:=FindText_Capture
    c:=StrReplace(_Gui["SelColor"].Value, "0x")
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox Lang["s12"], "Tip", "4096 T1"
      return
    }
    s:=_Gui["ColorList"].Value
    if InStr(cmd, "Sim")
      v:=_Gui["Similar1"].Value, v:=c "-" Round(v/100,2)
    else
      v:=_Gui["dRGB2"].Value, v:=c "-" Format("{:06X}",v<<16|v<<8|v)
    s:=RegExReplace("/" s, "/" c "-[^/]*") . "/" v
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend "{End}", _Gui["ColorList"].Hwnd
    G_.Call("Color2Two")
    return
  Case "Undo2":
    _Gui:=FindText_Capture
    s:=_Gui["ColorList"].Value
    s:=RegExReplace("/" s, "/[^/]+$")
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend "{End}", _Gui["ColorList"].Hwnd
    return
  Case "Color2Two":
    _Gui:=FindText_Capture
    color:=RegExReplace(_Gui["ColorList"].Value, "i)\s|0x")
    if (color="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox Lang["s16"], "Tip", "4096 T1"
      return
    }
    ListLines (lls:=A_ListLines)?0:0
    k:=i:=v:=0, arr:=StrSplit(Trim(StrReplace(color,"@","-"), "/"), "/")
    Loop nW*nH
    {
      c:=cors[++k], rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
      For k1,v1 in arr
      {
        r:=StrSplit(Trim(v1,"-") "-", "-"), c:=this.ToRGB(r[1]), n:=r[2]
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        if InStr(n, ".")
        {
          n:=this.Floor(n), n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
          if v:=(3*r*r+4*g*g+2*b*b<=n)
            Break
        }
        else
        {
          c:=this.Floor("0x" n), dR:=(c>>16)&0xFF, dG:=(c>>8)&0xFF, dB:=c&0xFF
          if v:=(Abs(r)<=dR && Abs(g)<=dG && Abs(b)<=dB)
            Break
        }
      }
      ascii[k]:=v, (show[k] && i:=(v?i+1:i-1))
    }
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines lls
    return
  Case "ColorPos2Two":
    _Gui:=FindText_Capture
    c:=_Gui["SelColor"].Value
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox Lang["s12"], "Tip", "4096 T1"
      return
    }
    n:=_Gui["Similar2"].Value, n:=Round(n/100,2), color:="#" c "-" n
    , n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF, k:=i:=0
    ListLines (lls:=A_ListLines)?0:0
    Loop nW*nH
      c:=cors[++k], r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
      , ascii[k]:=v:=3*r*r+4*g*g+2*b*b<=n, (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines lls
    return
  Case "BlackWhite":
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
    if (k++)*0 + (++tx)<nW && ty<nH && show[i:=ty*nW+tx+1]
      this.SC((ascii[i]?0:0xFFFFFF), C_[k])
    return
  Case "Modify":
    Modify:=FindText_Capture["Modify"].Value
    return
  Case "MultiColor":
    MultiColor:=FindText_Capture["MultiColor"].Value
    Result:=""
    ToolTip
    return
  Case "FindShape":
    FindShape:=FindText_Capture["FindShape"].Value
    (FindShape && !MultiColor) && FindText_Capture["MultiColor"].Value:=MultiColor:=1
    return
  Case "Undo":
    Result:=RegExReplace(Result, ",[^/]+/[^/]+/[^/]+$")
    ToolTip Trim(Result, ",")
    return
  Case "Similar1", "Similar2", "Similar3":
    i:=FindText_Capture[cmd].Value
    For k,v in ["Similar1","Similar2","Similar3"]
      (v!=cmd) && FindText_Capture[v].Value:=i
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    k:=0
    ListLines (lls:=A_ListLines)?0:0
    Loop nH
    {
      v:=""
      Loop nW
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines lls
    return
  Case "Auto":
    G_.Call("GetTxt")
    if (txt="")
    {
      FindText_Capture.Opt("+OwnDialogs")
      MsgBox Lang["s13"], "Tip", "4096 T1"
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt, "^" bg "+\n"), G_.Call("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt, "m`n)" bg "$"), G_.Call("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt, "\n\K" bg "+\n$"), G_.Call("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt, "m`n)^" bg), G_.Call("CutL")
      else Break
    }
    txt:=""
    return
  Case "OK", "SplitAdd", "AllAdd":
    _Gui:=FindText_Capture
    _Gui.Opt("+OwnDialogs")
    G_.Call("GetTxt")
    if (txt="") && (!MultiColor)
    {
      MsgBox Lang["s13"], "Tip", "4096 T1"
      return
    }
    if InStr(color,"#") && (!MultiColor)
    {
      k:=i:=j:=0
      ListLines (lls:=A_ListLines)?0:0
      Loop nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=SelPos)
        {
          j:=i
          Break
        }
      }
      ListLines lls
      if (j=0)
      {
        MsgBox Lang["s12"], "Tip", "4096 T1"
        return
      }
      color:="#" j "-" StrSplit(color "-","-")[2]
    }
    Comment:=_Gui["Comment"].Value
    if (cmd="SplitAdd") && (!MultiColor)
    {
      if InStr(color,"#")
      {
        MsgBox Lang["s14"], "Tip", "4096 T3"
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop w:=nW-CutLeft-CutRight
      {
        i++
        if (!show[k++] && A_Index<w)
          Continue
        i:=Format("{:d}",i)
        v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
        txt:=RegExReplace(txt,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}.",InStr(v,"`n")-1) . this.bit2base64(v)
          s.="`nText.=`"|<" SubStr(Comment, 1, 1) ">" color "$" v "`"`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}.",InStr(txt,"`n")-1) . this.bit2base64(txt)
    else
    {
      n:=_Gui["Similar3"].Value, n:=Round(n/100,2), color:="##" n
      , n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
      , arr:=StrSplit(Trim(StrReplace(Result,",","/"),"/"),"/"), s:="", i:=1
      Loop arr.Length//3
        x1:=arr[i++], y1:=arr[i++], c1:=arr[i++], c:="0x" c1
        , (A_Index=1 && (x:=x1, y:=y1, rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF))
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        , s.="," (x1-x) "/" (y1-y) "/" (FindShape?3*r*r+4*g*g+2*b*b<=n:c1)
      txt:=SubStr(s,2)
    }
    s:="`nText.=`"|<" Comment ">" color "$" txt "`"`n"
    if (cmd="SplitAdd" || cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    x:=nX+CutLeft+(nW-CutLeft-CutRight)//2
    y:=nY+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["s8"] "|||||||", "|")
    s:="`; #Include <FindText>`n"
    . "`nt1:=A_TickCount, Text:=X:=Y:=`"`"`n" s
    . "`nif (ok:=FindText(&X, &Y, " x "-150000, "
    . y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n{"
    . "`n  `; FindText()." . "Click(" . "X, Y, `"L`")"
    . "`n}`n"
    . "`n`; ok:=FindText(&X:=`"wait`", &Y:=3, 0,0,0,0,0,0,Text)  `; " r[7]
    . "`n`; ok:=FindText(&X:=`"wait0`", &Y:=-1, 0,0,0,0,0,0,Text)  `; " r[8]
    . "`n`nMsgBox `"" r[1] ":``t`" (IsObject(ok)?ok.Length:ok)"
    . "`n  . `"``n``n" r[2] ":``t`" (A_TickCount-t1) `" " r[3] "`""
    . "`n  . `"``n``n" r[4] ":``t`" X `", `" Y"
    . "`n  . `"``n``n" r[5] ":``t<`" (IsObject(ok)?ok[1].id:`"`") `">`", `"Tip`", 4096`n"
    . "`nTry For i,v in ok  `; ok " r[6] " ok:=FindText().ok"
    . "`n  if (i<=2)"
    . "`n    FindText().MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    _Gui.Hide()
    return
  Case "SavePic2":
    x:=nX+CutLeft, w:=nW-CutLeft-CutRight
    y:=nY+CutUp, h:=nH-CutUp-CutDown
    G_.Call("ScreenShot", x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "ShowPic":
    i:=EditGetCurrentLine(hscr)
    s:=EditGetLine(i, hscr)
    FindText_Main["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    return
  Case "KeyDown":
    Critical
    _Gui:=FindText_Main
    if (WinExist()!=_Gui.Hwnd)
      return
    Try ctrl:="", ctrl:=args[3]
    if (ctrl=hscr)
      SetTimer G_ShowPic, -150
    else if (ctrl=_Gui["ClipText"].Hwnd)
    {
      s:=_Gui["ClipText"].Value
      _Gui["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    }
    return
  Case "LButtonDown":
    Critical
    if (WinExist()!=FindText_Capture.Hwnd)
      return G_.Call("KeyDown", arg1, args*)
    CoordMode "Mouse"
    MouseGetPos &k1, &k2,, &k6, 2
    if (k6=hPic)
    {
      ListLines (lls:=A_ListLines)?0:0
      Loop
      {
        Sleep 50
        MouseGetPos &k3, &k4
        this.RangeTip(Min(k1,k3), Min(k2,k4)
        , Abs(k1-k3)+1, Abs(k2-k4)+1, (A_MSec<500 ? "Red":"Blue"))
      }
      Until !this.State("LButton")
      ListLines lls
      this.RangeTip()
      this.GetBitsFromScreen(,,,,0,&zx,&zy)
      this.ClientToScreen(&sx, &sy, 0, 0, hPic)
      sx:=Min(k1,k3)-sx+hBM_x+zx, sy:=Min(k2,k4)-sy+hBM_y+zy
      , sw:=Abs(k1-k3)+1, sh:=Abs(k2-k4)+1
      if (sw+sh)<5
        sx-=71//2, sy-=25//2, sw:=71, sh:=25
      G_.Call("CaptureUpdate")
      FindText_Capture["MyTab1"].Choose(1)
      return
    }
    if !(Cid_.Has(k6) && k5:=Cid_[k6])
      return
    if (k5=-1)
    {
      MouseMove k1+2, k2+2, 0
      MouseGetPos(,,, &k6, 2)
      MouseMove k1, k2, 0
      if !(Cid_.Has(k6) && k5:=Cid_[k6]) || (k5=-1)
        return
    }
    if (k5>71*25)
    {
      k1:=nW*nH+dx+(k5-71*25)
      this.SC(((show[k1]:=!show[k1])?0xFF0000:0xFFFFAA), k6)
      return
    }
    k3:=Mod(k5-1,71)+dx, k4:=(k5-1)//71+dy
    if (k3>=nW || k4>=nH)
      return
    k1:=k4*nW+k3+1
    if (Modify && bg!="" && show[k1])
      this.SC(((ascii[k1]:=!ascii[k1])?0:0xFFFFFF), k6)
    else
    {
      k2:=cors[k1], SelPos:=k1
      _Gui:=FindText_Capture
      _Gui["SelGray"].Value:=(((k2>>16)&0xFF)*38+((k2>>8)&0xFF)*75+(k2&0xFF)*15)>>7
      _Gui["SelColor"].Value:=Format("0x{:06X}",k2&0xFFFFFF)
      _Gui["SelR"].Value:=(k2>>16)&0xFF
      _Gui["SelG"].Value:=(k2>>8)&0xFF
      _Gui["SelB"].Value:=k2&0xFF
    }
    if (MultiColor && show[k1])
    {
      (FindShape && Result="") && G_.Call("ColorPos2Two")
      k2:=Format(",{:d}/{:d}/{:06X}", nX+k3, nY+k4, cors[k1]&0xFFFFFF)
      , Result.=InStr(Result,k2) ? "":k2
      ToolTip Trim(Result, ",")
    }
    return
  Case "RButtonDown":
    Critical
    MouseGetPos(,,, &k2, 2)
    if (k2!=hPic)
      return
    CoordMode "Mouse"
    MouseGetPos &k1, &k2
    k5:=hBM_x, k6:=hBM_y
    ListLines (lls:=A_ListLines)?0:0
    Loop
    {
      Sleep 10
      MouseGetPos &k3, &k4
      hBM_x:=k5+k1-k3, hBM_y:=k6+k2-k4
      G_.Call("PicShow")
    }
    Until !this.State("RButton")
    ListLines lls
    return
  Case "MouseMove":
    Try ctrl_name:="", ctrl_name:=GuiCtrlFromHwnd(args[3]).Name
    if (PrevControl != ctrl_name)
    {
      ToolTip
      PrevControl:=ctrl_name
      Try SetTimer G_ToolTip, (PrevControl ? -500:0)
      Try SetTimer G_ToolTipOff, (PrevControl ? -5500:0)
    }
    return
  Case "ToolTip":
    MouseGetPos(,, &_TT)
    if WinExist("ahk_id " _TT " ahk_class AutoHotkeyGUI")
      Try ToolTip Tip_Text[PrevControl]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2", "CutR2", "CutU2", "CutD2":
    s:=FindText_Main["MyPic"].Value
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    FindText_Main["MyPic"].Value:=Trim(s,"`n")
    return
  Case "Update":
    ControlFocus hscr
    i:=EditGetCurrentLine(hscr)
    s:=EditGetLine(i, hscr)
    if !RegExMatch(s, "(<[^>\n]*>[^$\n]+\$)\d+\.[\w+/]+", &r)
      return
    v:=FindText_Main["MyPic"].Value
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s, r[0], r[1] . w "." this.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend v, hscr
    EditPaste s, hscr
    ControlSend "{Home}", hscr
    return
  }
}

Lang(text:="", getLang:=0)
{
  static Lang1:="", Lang2
  if (!Lang1)
  {
    s:="
    (
Myww       = Width = Adjust the width of the capture range
Myhh       = Height = Adjust the height of the capture range
AddFunc    = Add = Additional FindText() in Copy
NowHotkey  = Hotkey = Current screenshot hotkey
SetHotkey1 = = First sequence Screenshot hotkey
SetHotkey2 = = Second sequence Screenshot hotkey
Apply      = Apply = Apply new screenshot hotkey
CutU2      = CutU = Cut the Upper Edge of the text in the edit box below
CutL2      = CutL = Cut the Left Edge of the text in the edit box below
CutR2      = CutR = Cut the Right Edge of the text in the edit box below
CutD2      = CutD = Cut the Lower Edge of the text in the edit box below
Update     = Update = Update the text in the edit box below to the line of Code
GetRange   = GetRange = Get screen range to Clipboard and update the search range of the Code
GetOffset  = GetOffset = Get position offset relative to the Text from the Code and update FindText().Click()
GetClipOffset  = GetOffset2 = Get position offset relative to the Text from the Left Box
Capture    = Capture = Initiate Image Capture Sequence
CaptureS   = CaptureS = Restore the Saved ScreenShot by Hotkey and then start capturing
Test       = Test = Test the Text from the Code to see if it can be found on the screen
TestClip   = Test2 = Test the Text from the Left Box and copy the result to Clipboard
Paste      = Paste = Paste the Text from Clipboard to the Left Box
CopyOffset = Copy2 = Copy the Offset to Clipboard
Copy       = Copy = Copy the selected or all of the code to the clipboard
Reset      = Reset = Reset to Original Captured Image
SplitAdd   = SplitAdd = Using Markup Segmentation to Generate Text Library
AllAdd     = AllAdd = Append Another FindText Search Text into Previously Generated Code
Gray2Two      = Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
GrayDiff2Two  = GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
Color2Two     = Color2Two = Converts Image Pixels from Color List to Black or White
ColorPos2Two  = ColorPos2Two = Converts Image Pixels from Color Position to Black or White
SelGray    = Gray = Gray value of the selected color
SelColor   = Color = The selected color
SelR       = R = Red component of the selected color
SelG       = G = Green component of the selected color
SelB       = B = Blue component of the selected color
RepU       = -U = Undo Cut the Upper Edge by 1
CutU       = U = Cut the Upper Edge by 1
CutU3      = U3 = Cut the Upper Edge by 3
RepL       = -L = Undo Cut the Left Edge by 1
CutL       = L = Cut the Left Edge by 1
CutL3      = L3 = Cut the Left Edge by 3
Auto       = Auto = Automatic Cut Edge after image has been converted to black and white
RepR       = -R = Undo Cut the Right Edge by 1
CutR       = R = Cut the Right Edge by 1
CutR3      = R3 = Cut the Right Edge by 3
RepD       = -D = Undo Cut the Lower Edge by 1
CutD       = D = Cut the Lower Edge by 1
CutD3      = D3 = Cut the Lower Edge by 3
Modify     = Modify = Allows Modify the Black and White Image
MultiColor = FindMultiColor = Click multiple colors with the mouse, then Click OK button
FindShape  = FindShape = Click multiple colors, it will be binarized based on the first color
Undo       = Undo = Undo the last selected color
Undo2      = Undo = Undo the last added color in Color List
Comment    = Comment = Optional Comment used to Label Code ( Within <> )
Threshold  = Gray Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
GrayDiff   = Gray Difference = Gray Difference which Determines Black or White Pixel Conversion (0-255)
Similar1   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar2   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar3   = Similarity = Adjust color similarity as Equivalent to The Selected Color
AddColorSim  = Add = Add Color to Color List and Run Color2Two
AddColorDiff = Add = Add Color to Color List and Run Color2Two
ColorList  = = Color list for converting black and white images
DiffRGB    = R/G/B = Determine the allowed R/G/B Error (0-255) when Find MultiColor
DiffRGB2   = R/G/B = Determine the allowed R/G/B Error (0-255)
Bind0      = BindWin1 = Bind the window and Use GetDCEx() to get the image of background window
Bind1      = BindWin1+ = Bind the window Use GetDCEx() and Modify the window to support transparency
Bind2      = BindWin2 = Bind the window and Use PrintWindow() to get the image of background window
Bind3      = BindWin2+ = Bind the window Use PrintWindow() and Modify the window to support transparency
Bind4      = BindWin3 = Bind the window and Use PrintWindow(,,3) to get the image of background window
OK         = OK = Create New FindText Code for Testing
OK2        = OK = Restore this ScreenShot then Capturing
Cancel     = Cancel = Close the Window Don't Do Anything
Cancel2    = Cancel = Close the Window Don't Do Anything
ClearAll   = ClearAll = Clean up all saved ScreenShots
OpenDir    = OpenDir = Open the saved screenshots directory
SavePic    = SavePic = Select a range and save as a picture
SavePic2   = SavePic = Save the trimmed original image as a picture
LoadPic    = LoadPic = Load a picture as Capture image
ClipText   = = Displays the Text data from clipboard
Offset     = = Displays the results of GetOffset2 or GetRange
SelectBox  = = Select a screenshot to display in the upper left corner of the screen
s1  = FindText
s2  = Gray|GrayDiff|Color|ColorPos|MultiColor
s3  = Capture Image To Text
s4  = Capture Image To Text and Find Text Tool
s5  = Direction keys to fine tune\nFirst click RButton(or Ctrl)\nMove the mouse away\nSecond click RButton(or Ctrl)
s6  = Unbind Window using
s7  = Drag a range with LButton(or Ctrl)\nCoordinates are copied to clipboard
s8  = Found|Time|ms|Pos|Result|value can be get from|Wait 3 seconds for appear|Wait indefinitely for disappear
s9  = Success
s10 = The Capture Position|Perspective binding window\nRight click to finish capture
s11 = Please Set Gray Difference First !
s12 = Please select the core color first !
s13 = Please convert the image to black or white first !
s14 = Can't be used in ColorPos mode, because it can cause position errors
s15 = Are you sure about the scope of your choice ?\n\nIf not, you can choose again
s16 = Please add colors to the color list first !
s17 = The picture you want to open was not found !
s18 = Capture|ScreenShot
s19 = Are you sure to delete all screenshots ?
    )"
    Lang1:=Map(), Lang1.Default:="", Lang2:=Map(), Lang2.Default:=""
    Loop Parse, s, "`n", "`r"
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v "==","\n","`n"), "=", "`t ")
        , Lang1[r[1]]:=r[2], Lang2[r[1]]:=r[3]
  }
  return getLang=1 ? Lang1 : getLang=2 ? Lang2 : Lang1[text]
}

Script_End() {
}

}  ;// Class End

;================= The End =================

;