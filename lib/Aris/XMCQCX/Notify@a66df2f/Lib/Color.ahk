#Requires AutoHotKey v2.0

/**
 *  Color.ahk
 *
 *  @version 1.0
 *  @author Komrad Toast (komrad.toast@hotmail.com)
 *  @see https://www.autohotkey.com/boards/viewtopic.php?f=83&t=132433
 *  @license
 *  Copyright (c) 2024 Tyler J. Colby (Komrad Toast)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 *  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 *  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 *  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

/**
 * Color class. Stores a decimal RGB color representation. 
 * 
 * Has methods to convert to / from other formats (Hex, HSL, HWB, CMYK, NCol).
 * ```ahk2
 * Color("#27D")           ; #RGB
 * Color("#27DF")          ; #RGBA
 * Color("#2277DD")        ; #RRGGBB
 * Color("#2277DDFF")      ; #RRGGBBAA
 * Color(22, 77, 221)      ; RGB
 * Color(22, 77, 221, 255) ; RGBA
 * ```
 */
class Color
{
    /** @property {String} HexFormat The hexadecimal color code format for `Color.ToHex().Full` (e.g. `#{R}{G}{B}{A}`). */
    HexFormat
    {
        get
        {
            hex := this._hexFormat
            hex := RegExReplace(hex, "{4:02X}", "{A}")
            hex := RegExReplace(hex, "{1:02X}", "{R}")
            hex := RegExReplace(hex, "{2:02X}", "{G}")
            hex := RegExReplace(hex, "{3:02X}", "{B}")
            return hex
        }

        set
        {
            value := RegExReplace(value, "{A}", "{4:02X}")
            value := RegExReplace(value, "{R}", "{1:02X}")
            value := RegExReplace(value, "{G}", "{2:02X}")
            value := RegExReplace(value, "{B}", "{3:02X}")
            this._hexFormat := value
        }
    }

    /** @property {String} RGBFormat The RGB color code format for `Color.ToRGB().Full` (e.g. `RGBA({R},{G},{B},{A})`). */
    RGBFormat
    {
        get
        {
            rgb := this._rgbFormat
            rgb := RegExReplace(rgb, "{1:d}", "{R}")
            rgb := RegExReplace(rgb, "{2:d}", "{G}")
            rgb := RegExReplace(rgb, "{3:d}", "{B}")
            rgb := RegExReplace(rgb, "{4:d}", "{A}")
            return rgb
        }
        set
        {
            value := RegExReplace(value, "{R}", "{1:d}")
            value := RegExReplace(value, "{G}", "{2:d}")
            value := RegExReplace(value, "{B}", "{3:d}")
            value := RegExReplace(value, "{A}", "{4:d}")
            this._rgbFormat := value
            this.Full := Format(this._rgbFormat, this.R, this.G, this.B, this.A)
        }
    }

    /** @property {String} HSLFormat The HSL color code format for `Color.ToHSL().Full` (e.g. `hsl({H},{S}%,{L}%)`). */
    HSLFormat
    {
        get
        {
            hsl := this._hslFormat
            hsl := RegExReplace(hsl, "{1:d}", "{H}")
            hsl := RegExReplace(hsl, "{2:d}", "{S}")
            hsl := RegExReplace(hsl, "{3:d}", "{L}")
            hsl := RegExReplace(hsl, "{4:d}", "{A}")
            return hsl
        }

        set
        {
            value := RegExReplace(value, "{H}", "{1:d}")
            value := RegExReplace(value, "{S}", "{2:d}")
            value := RegExReplace(value, "{L}", "{3:d}")
            value := RegExReplace(value, "{A}", "{4:d}")
            this._hslFormat := value
        }
    }

    /** @property {String} HWBFormat The HWB color code format for `Color.ToHWB().Full` (e.g. `hwb({H},{W}%,{B}%)`). */
    HWBFormat
    {
        get
        {
            hwb := this._hwbFormat
            hwb := RegExReplace(hwb, "{1:d}", "{H}")
            hwb := RegExReplace(hwb, "{2:d}", "{W}")
            hwb := RegExReplace(hwb, "{3:d}", "{B}")
            return hwb
        }
        
        set
        {
            value := RegExReplace(value, "{H}", "{1:d}")
            value := RegExReplace(value, "{W}", "{2:d}")
            value := RegExReplace(value, "{B}", "{3:d}")
            this._hwbFormat := value
        }
    }

    /** @property {String} CMYKFormat The CMYK color code format for `Color.ToCMYK().Full` (e.g. `cmyk({C}%,{M}%,{Y}%,{K}%)`). */
    CMYKFormat
    {
        get
        {
            cmyk := this._cmykFormat
            cmyk := RegExReplace(cmyk, "{1:d}", "{C}")
            cmyk := RegExReplace(cmyk, "{2:d}", "{M}")
            cmyk := RegExReplace(cmyk, "{3:d}", "{Y}")
            cmyk := RegExReplace(cmyk, "{4:d}", "{K}")
            return cmyk
        }
        
        set
        {
            value := RegExReplace(value, "{C}", "{1:d}")
            value := RegExReplace(value, "{M}", "{2:d}")
            value := RegExReplace(value, "{Y}", "{3:d}")
            value := RegExReplace(value, "{K}", "{4:d}")
            this._cmykFormat := value
        }
    }

    /** @property {String} NColFormat The NCol color code format for `Color.ToNCol().Full` (e.g. `ncol({H},{W}%,{B}%)`). */
    NColFormat
    {
        get
        {
            ncol := this._nColFormat
            ncol := RegExReplace(ncol, "{1:d}", "{H}")
            ncol := RegExReplace(ncol, "{2:d}", "{W}")
            ncol := RegExReplace(ncol, "{3:d}", "{B}")
            return ncol
        }

        set
        {
            value := RegExReplace(value, "{H}", "{1:s}")
            value := RegExReplace(value, "{W}", "{2:d}")
            value := RegExReplace(value, "{B}", "{3:d}")
            this._nColFormat := value
        }
    }

    ; Default Format Strings
    _hexFormat  := "0x{1:02X}{2:02X}{3:02X}"
    _rgbFormat  := "rgba({1:d}, {2:d}, {3:d}, {4:d})"
    _hslFormat  := "hsl({1:d}, {2:d}%, {3:d}%)"
    _hwbFormat  := "hwb({1:d} {2:d}% {3:d}%)"
    _cmykFormat := "cmyk({1:d}%, {2:d}%, {3:d}%, {4:d}%)"
    _nColFormat := "ncol({1:s}, {2:d}%, {3:d}%)"

    static Black   => Color("Black")
    static Silver  => Color("Silver")
    static Gray    => Color("Gray")
    static White   => Color("White")
    static Maroon  => Color("Maroon")
    static Red     => Color("Red")
    static Purple  => Color("Purple")
    static Fuchsia => Color("Fuchsia")
    static Green   => Color("Green")
    static Lime    => Color("Lime")
    static Olive   => Color("Olive")
    static Yellow  => Color("Yellow")
    static Navy    => Color("Navy")
    static Blue    => Color("Blue")
    static Teal    => Color("Teal")
    static Aqua    => Color("Aqua")

    /**
     * Color constructor
     * @param colorArgs - Color arguments to initialize the color from. Can be RGB, RGBA, Hex (3, 4, 6, or 8 character), or Name.
     */
    __New(colorArgs*)
    {
        this.A := 255

        colorNames := Map(
            "Black" , "000000", "Silver", "C0C0C0", "Gray"  , "808080", "White"  , "FFFFFF",
            "Maroon", "800000", "Red"   , "FF0000", "Purple", "800080", "Fuchsia", "FF00FF",
            "Green" , "008000", "Lime"  , "00FF00", "Olive" , "808000", "Yellow" , "FFFF00",
            "Navy"  , "000080", "Blue"  , "0000FF", "Teal"  , "008080", "Aqua"   , "00FFFF"
        )


        if (colorArgs.Length == 0)
        {
            this.R := 0
            this.G := 0
            this.B := 0
        }
        else if (colorArgs.Length == 1)
        {
            if (colorNames.Has(colorArgs[1]))
                hex := colorNames[colorArgs[1]]
            else if (StrLen(colorArgs[1]) >= 3)
                hex := RegExReplace(colorArgs[1], "^#|^0x", "")
            else
                throw Error("Invalid Hex Color argument")

            if StrLen(hex) == 3
            {
                this.R := Integer("0x" . SubStr(hex, 1, 1))
                this.G := Integer("0x" . SubStr(hex, 2, 1))
                this.B := Integer("0x" . SubStr(hex, 3, 1))
            }
            else if StrLen(hex) == 4
            {
                this.R := Integer("0x" . SubStr(hex, 2, 1))
                this.G := Integer("0x" . SubStr(hex, 3, 1))
                this.B := Integer("0x" . SubStr(hex, 4, 1))
                this.A := Integer("0x" . SubStr(hex, 1, 1))
            }
            else if StrLen(hex) == 6
            {
                this.R := Integer("0x" . SubStr(hex, 1, 2))
                this.G := Integer("0x" . SubStr(hex, 3, 2))
                this.B := Integer("0x" . SubStr(hex, 5, 2))
            }
            else if StrLen(hex) == 8
            {
                this.R := Integer("0x" . SubStr(hex, 3, 2))
                this.G := Integer("0x" . SubStr(hex, 5, 2))
                this.B := Integer("0x" . SubStr(hex, 7, 2))
                this.A := Integer("0x" . SubStr(hex, 1, 2))
            }
        }
        else if (colorArgs.Length == 3)
        {
            this.R := Clamp(colorArgs[1], 0, 255)
            this.G := Clamp(colorArgs[2], 0, 255)
            this.B := Clamp(colorArgs[3], 0, 255)
        }
        else if (colorArgs.Length == 4)
        {
            this.R := Clamp(colorArgs[1], 0, 255)
            this.G := Clamp(colorArgs[2], 0, 255)
            this.B := Clamp(colorArgs[3], 0, 255)
            this.A := Clamp(colorArgs[4], 0, 255)
        }
        else
        {
            throw Error("Invalid color arguments")
        }

        this.Full := Format(this._rgbFormat, this.R, this.G, this.B, this.A)

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Converts the stored color to Hexadecimal representation.
     * @param {String} formatString The string used to format the output.
     * @returns {Object} `{R:(00-FF), G:(00-FF), B:(00-FF), A:(00-FF), Full:string}`
     */
    ToHex(formatString := "")
    {
        if formatString
        {
            oldFormat := this.HexFormat
            this.HexFormat := formatString
        }

        full := Format(this._hexFormat, this.R, this.G, this.B, this.A)

        if formatString
            this.HexFormat := oldFormat

        return {
            R: Format("{:02X}", this.R),
            G: Format("{:02X}", this.G),
            B: Format("{:02X}", this.B),
            A: Format("{:02X}", this.A),
            Full: full
        }
    }

    /**
     * Converts the stored color to HSLA representation.
     * @param {String} formatString The string used to format the output.
     * @returns {Object} `{H:(0-360), S:(0-100), L:(0-100), A:(0-1), Full:string}`
     */
    ToHSL(formatString := "")
    {
        if formatString
        {
                oldFormat := this.HSLFormat
                this.HSLFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
        a := this.A / 255

        cmax := Max(r, g, b)
        cmin := Min(r, g, b)
        delta := cmax - cmin

        l := (cmax + cmin) / 2

        if (delta == 0)
        {
            h := 0
            s := 0
        }
        else
        {
            s := delta / (1 - Abs(2 * l - 1))

            if (cmax == r)
                h := 60 * Mod((g - b) / delta, 6)
            else if (cmax == g)
                h := 60 * ((b - r) / delta + 2)
            else
                h := 60 * ((r - g) / delta + 4)

            if (h < 0)
                h += 360
        }

        full := Format(this._hslFormat, Round(h), Round(s * 100), Round(l * 100))

        if formatString
            this.HSLFormat := oldFormat

        return {
            H: Round(h),
            S: Round(s * 100),
            L: Round(l * 100),
            A: Round(a, 1),
            Full: full
        }
    }

    /**
     * Converts the stored color to HWB representation.
     * ```ahk2
     * color.ToHWB("HWB: {H}, {W}%, {B}%")
     * ```
     * @param {String} formatString The string used to format the `Full` output.
     * @returns {Object} `{H:(0-360), W:(0-100), B:(0-100), Full:string}`
     */
    ToHWB(formatString := "")
    {
        if formatString
        {
            oldFormat := this.HWBFormat
            this.HWBFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
    
        cmax := Max(r, g, b)
        cmin := Min(r, g, b)
        delta := cmax - cmin
    
        if (delta == 0)
            h := 0
        else if (cmax == r)
            h := 60 * Mod((g - b) / delta, 6)
        else if (cmax == g)
            h := 60 * ((b - r) / delta + 2)
        else
            h := 60 * ((r - g) / delta + 4)
    
        if (h < 0)
            h += 360
    
        w := cmin
        bl := 1 - cmax

        full := Format(this._hwbFormat, Round(h), Round(w * 100), Round(bl * 100))

        if formatString
            this.HWBFormat := oldFormat
    
        return {
            H: Round(h),
            W: Round(w * 100),
            B: Round(bl * 100),
            Full: full
        }
    }

    /**
     * Converts the stored color to CMYK representation.
     * @param {String} formatString The string used to format the output.
     * @returns {Object} `{C:(0-100), M:(0-100), Y:(0-100), K:(0-100), Full:string}`
     */
    ToCMYK(formatString := "")
    {
        if formatString
        {
            oldFormat := this.CMYKFormat
            this.CMYKFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
    
        k := 1 - Max(r, g, b)
        
        if (k == 1)
        {
            c := 0
            m := 0
            y := 0
        }
        else
        {
            c := (1 - r - k) / (1 - k)
            m := (1 - g - k) / (1 - k)
            y := (1 - b - k) / (1 - k)
        }

        full := Format(this._cmykFormat, Round(c * 100), Round(m * 100), Round(y * 100), Round(k * 100))

        if formatString
            this.CMYKFormat := oldFormat
    
        return {
            C: Round(c * 100),
            M: Round(m * 100),
            Y: Round(y * 100),
            K: Round(k * 100),
            Full: full
        }
    }

    /**
     * Converts the stored color to NCol representation.
     * @param {String} formatString The string used to format the output.
     * @returns {Object} `{"H":string, "W":(0-100), "B":(0-100), "Full":string}`
     */
    ToNCol(formatString := "")
    {
        if formatString
        {
            oldFormat := this.NColFormat
            this.NColFormat := formatString
        }

        hwb := this.ToHWB()
        h := hwb.H
        w := hwb.W
        b := hwb.B
    
        hueNames := ["R", "Y", "G", "C", "B", "M"]
        hueIndex := Floor(h / 60)
        huePercent := Round(Mod(h, 60) / 60 * 100)
    
        ncolHue := hueNames[Mod(hueIndex, 6) + 1] . huePercent

        full := Format(this._nColFormat, ncolHue, w, b)

        if formatString
            this.NColFormat := oldFormat
    
        return {
            H: ncolHue,
            W: w,
            B: b,
            Full: full
        }
    }

    /**
     * Generates a random color.
     * @returns {Color} A new, random color
     */
    static Random() => Color(Random(255), Random(255), Random(255))

    /**
     * Syntactic Sugar for the Color Constructor. Makes a new color using RGB or RGBA representation.
     * @returns {Color}
     */
    static FromRGB(colorArgs*) ; Syntactic Sugar
    {
        if (colorArgs.Length == 3)
            return Color(colorArgs[1], colorArgs[2], colorArgs[3])
        else if (colorArgs.Length == 4)
            return Color(colorArgs[1], colorArgs[2], colorArgs[3], colorArgs[4])
        else
            throw Error("Invalid number of arguments passed to Color.FromRGB")
    }

    /**
     * Syntactic Sugar for the Color Constructor. Makes a new color using Hex RGB or RGBA representation.
     * @returns {Color}
     */
    static FromHex(hex) ; Syntactic Sugar
    {
        if (StrLen(hex) >= 3)
            hex := RegExReplace(hex, "^#|^0x", "")
        else
            throw Error("Invalid Hex Color argument")

        if StrLen(hex) == 3
        {
            R := Integer("0x" . SubStr(hex, 1, 1))
            G := Integer("0x" . SubStr(hex, 2, 1))
            B := Integer("0x" . SubStr(hex, 3, 1))
            A := 255
        }
        else if StrLen(hex) == 4
        {
            R := Integer("0x" . SubStr(hex, 1, 1))
            G := Integer("0x" . SubStr(hex, 2, 1))
            B := Integer("0x" . SubStr(hex, 3, 1))
            A := Integer("0x" . SubStr(hex, 4, 1))
        }
        else if StrLen(hex) == 6
        {
            R := Integer("0x" . SubStr(hex, 1, 2))
            G := Integer("0x" . SubStr(hex, 3, 2))
            B := Integer("0x" . SubStr(hex, 5, 2))
            A := 255
        }
        else if StrLen(hex) == 8
        {
            R := Integer("0x" . SubStr(hex, 1, 2))
            G := Integer("0x" . SubStr(hex, 3, 2))
            B := Integer("0x" . SubStr(hex, 5, 2))
            A := Integer("0x" . SubStr(hex, 7, 2))
        }

        return Color(R, G, B, A)
    }

    /**
     * Creates a `Color` instance from HSL format.
     * @param {Integer} h Hue        - `0-360`
     * @param {Integer} s Saturation - `0-100`
     * @param {Integer} l Lightness  - `0-100`
     * @returns {Color}
     */
    static FromHSL(h, s, l)
    {
        h := Mod(h, 360) / 360
        s := Clamp(s, 0, 100) / 100
        l := Clamp(l, 0, 100) / 100

        if (s == 0)
        {
            r := g := b := l
        }
        else
        {
            q := l < 0.5 ? l * (1 + s) : l + s - l * s
            p := 2 * l - q
            r := HueToRGB(p, q, h + 1/3)
            g := HueToRGB(p, q, h)
            b := HueToRGB(p, q, h - 1/3)
        }

        return Color(Round(r * 255), Round(g * 255), Round(b * 255))

        Clamp(val, low, high) => Min(Max(val, low), high)

        HueToRGB(p, q, t)
        {
            if (t < 0) 
                t += 1
            if (t > 1) 
                t -= 1
            if (t < 1/6) 
                return p + (q - p) * 6 * t
            if (t < 1/2) 
                return q
            if (t < 2/3) 
                return p + (q - p) * (2/3 - t) * 6
            return p
        }
    }

    /**
     * Creates a `Color` instance from HWB format.
     * @param {Integer} h Hue       - `0-360`
     * @param {Integer} w Whiteness - `0-100`
     * @param {Integer} b Blackness - `0-100`
     * @returns {Color}
     */
    static FromHWB(h, w, b)
    {
        h := Mod(h, 360) / 360
        w := Clamp(w, 0, 100) / 100
        b := Clamp(b, 0, 100) / 100
    
        if (w + b >= 1)
        {
            g := w / (w + b)
            return Color(Round(g * 255), Round(g * 255), Round(g * 255))
        }
    
        f := 1 - w - b
        rgb := HueToRGB(h)
    
        r := Round((rgb.R * f + w) * 255)
        g := Round((rgb.G * f + w) * 255)
        b := Round((rgb.B * f + w) * 255)
    
        return Color(r, g, b)

        Clamp(val, low, high) => Min(Max(val, low), high)

        HueToRGB(h)
        {
            h *= 6
            x := 1 - Abs(Mod(h, 2) - 1)
            switch Floor(h)
            {
                case 0: return {R: 1, G: x, B: 0}
                case 1: return {R: x, G: 1, B: 0}
                case 2: return {R: 0, G: 1, B: x}
                case 3: return {R: 0, G: x, B: 1}
                case 4: return {R: x, G: 0, B: 1}
                case 5: return {R: 1, G: 0, B: x}
            }
        }
    }

    /**
     * Creates a `Color` instance from CMYK format.
     * @param {Integer} c Cyan        - `0-100`
     * @param {Integer} m Magenta     - `0-100`
     * @param {Integer} y Yellow      - `0-100`
     * @param {Integer} k Key (Black) - `0-100`
     * @returns {Color}
     */
    static FromCMYK(c, m, y, k)
    {
        c := Clamp(c, 0, 100) / 100
        m := Clamp(m, 0, 100) / 100
        y := Clamp(y, 0, 100) / 100
        k := Clamp(k, 0, 100) / 100
    
        r := Round((1 - c) * (1 - k) * 255)
        g := Round((1 - m) * (1 - k) * 255)
        b := Round((1 - y) * (1 - k) * 255)
    
        return Color(r, g, b)

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Creates a `Color` instance from NCol format.
     * @param {Integer} h Hue       - `(R|Y|G|C|B|M)0-100`
     * @param {Integer} w Whiteness - `0-100`
     * @param {Integer} b Blackness - `0-100`
     * @returns {Color}
     */
    static FromNCol(h, w, b)
    {
        hueNames := "RYGCBM"
        hueIndex := InStr(hueNames, SubStr(h, 1, 1)) - 1
        huePercent := Integer(SubStr(h, 2))
        
        h := Mod(hueIndex * 60 + huePercent * 0.6, 360)
        w := Clamp(w, 0, 100)
        b := Clamp(b, 0, 100)
    
        return Color.FromHWB(h, w, b)

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Creates a new `Color` by calculating the average of two or more colors.
     * @param {Color[]} colors The colors to calculate the average of.
     * @returns {Color}
     */
    static Average(colors*)
    {
        r := 0
        g := 0
        b := 0

        for _color in colors
        {
            r += _color.R
            g += _color.G
            b += _color.B
        }

        count := colors.Length
        return Color(Round(r / count), Round(g / count), Round(b / count))
    }

    /**
     * Creates a new `Color` by multiplying two or more colors.
     * @param colors The colors to multiply.
     * @returns {Color}
     */
    static Multiply(colors*)
    {
        r := 1
        g := 1
        b := 1

        for _color in colors
        {
            r *= _color.R / 255
            g *= _color.G / 255
            b *= _color.B / 255
        }

        return Color(Round(r * 255), Round(g * 255), Round(b * 255))
    }

    /**
     * Inverts the current color and returns it as a new `Color` instance.
     * @returns {Color}
     */
    Invert() => Color(255 - this.R, 255 - this.G, 255 - this.B, this.A)

    /**
     * Returns the grayscale representation of the current color.
     * @returns {Color}
     */
    Grayscale()
    {
        luminance := 0.299 * this.R + 0.587 * this.G + 0.114 * this.B
        grayValue := Round(luminance)
        return Color(grayValue, grayValue, grayValue)
    }

    /**
     * Shifts the current color's hue by the specified amount of degrees.
     * @param {Integer} degrees The amount to shift the hue by - `0-360`.
     * @returns {Color}
     */
    ShiftHue(degrees)
    {
        hsl := this.ToHSL()
        newHue := Mod(hsl.H + degrees, 360)
        return Color.FromHSL(newHue, hsl.S, hsl.L)
    }

    /**
     * Shifts the current color's saturation by the specified amount.
     * @param {Integer} degrees The amount to shift the saturation by - `0-100`.
     * @returns {Color}
     */
    ShiftSaturation(amount)
    {
        hsl := this.ToHSL()
        newSaturation := Max(0, Min(100, hsl.S + amount))
        return Color.FromHSL(hsl.H, newSaturation, hsl.L)
    }

    /**
     * Increases the current color's saturation by the specified amount. Negative values are made positive.
     * @param {Integer} percentage The amount to increase the saturation by - `0-100`.
     * @returns {Color}
     */
    Saturate(percentage)   => this.ShiftSaturation( Abs(percentage))

    /**
     * Decreases the current color's saturation by the specified amount. Positive values are made negative.
     * @param {Integer} percentage The amount to decrease the saturation by - `0-100`.
     * @returns {Color}
     */
    Desaturate(percentage) => this.ShiftSaturation(-Abs(percentage))

    /**
     * Shifts the current color's lightness by the specified amount.
     * @param {Integer} degrees The amount to shift the lightness by - `0-100`.
     * @returns {Color}
     */
    ShiftLightness(amount)
    {
        hsl := this.ToHSL()
        newLightness := Max(0, Min(100, hsl.L + amount))
        return Color.FromHSL(hsl.H, hsl.S, newLightness)
    }

    /**
     * Increases the current color's lightness by the specified amount. Negative values are made positive.
     * @param {Integer} percentage The amount to increase the lightness by - `0-100`.
     * @returns {Color}
     */
    Lighten(percentage) => this.ShiftLightness( Abs(percentage))

    /**
     * Decreases the current color's lightness by the specified amount. Positive values are made negative.
     * @param {Integer} percentage The amount to decrease the lightness by - `0-100`.
     * @returns {Color}
     */
    Darken(percentage)  => this.ShiftLightness(-Abs(percentage))

    /**
     * Shifts the current color's whiteness by the specified amount.
     * @param {Integer} degrees The amount to shift the whiteness by - `0-100`.
     * @returns {Color}
     */
    ShiftWhiteness(amount)
    {
        hwb := this.ToHWB()
        newWhiteness := Max(0, Min(100, hwb.W + amount))
        return Color.FromHWB(hwb.H, newWhiteness, hwb.B)
    }

    /**
     * Shifts the current color's blackness by the specified amount.
     * @param {Integer} degrees The amount to shift the blackness by - `0-100`.
     * @returns {Color}
     */
    ShiftBlackness(amount)
    {
        hwb := this.ToHWB()
        newBlackness := Max(0, Min(100, hwb.B + amount))
        return Color.FromHWB(hwb.H, hwb.W, newBlackness)
    }

    /**
     * Returns the complementary color to the current `Color` instance.
     * @returns {Color}
     */
    Complement() => this.ShiftHue(180)

    /**
     * Returns the luminance (`0-1`) of the current `Color` instance.
     * @returns {Float}
     */
    GetLuminance()
    {
        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /**
     * Returns `True` if the current `Color` instance's Luminance is above `0.5`.
     * @returns {Boolean}
     */
    IsLight() => this.GetLuminance() > 0.5

    /**
     * Returns `True` the current `Color` instance's Luminance is equal to or below `0.5`.
     * @returns {Boolean}
     */
    IsDark() => this.GetLuminance() <= 0.5

    /**
     * Gets the contrast ratio between the current `Color` instance and another.
     * @param {Color} _color The `Color` instance to compare to.
     * @returns {Float}
     */
    GetContrast(_color)
    {
        l1 := this.GetLuminance()
        l2 := _color.GetLuminance()
        
        if (l1 > l2)
            return (l1 + 0.05) / (l2 + 0.05)
        else
            return (l2 + 0.05) / (l1 + 0.05)
    }

    /**
     * Mixes the current `Color` instance with another and returns a new `Color`.
     * @param {Color} _color The color to mix with.
     * @param {Integer} weight The weight used to mix the two colors.
     * @returns {Color}
     */
    Mix(_color, weight := 50)
    {
        w := weight / 100
        r := Round(this.R * (1 - w) + _color.R * w)
        g := Round(this.G * (1 - w) + _color.G * w)
        b := Round(this.B * (1 - w) + _color.B * w)

        return Color.FromRGB(r, g, b)
    }

    /**
     * Generates `count` colors that are analogous with (next to) the current color by `angle` degrees.
     * @param {Integer} angle The angle between the analogous colors.
     * @param {Integer} count Total colors to return (includes original).
     * @returns {Color[]}
     */
    Analogous(angle := 30, count := 3)
    {
        hsl := this.ToHSL()
        colors := []
        colors.Push(this)
    
        Loop count - 1
        {
            newH := Mod(hsl.H + angle * A_Index, 360)
            colors.Push(Color.FromHSL(newH, hsl.S, hsl.L))
        }

        return colors
    }

    /**
     * Generates a Triadic color scheme from the current color. Traidic colors are offset from the current by `120°` and `240°`.
     * @returns {Color[3]}
     */
    Triadic()
    {
        hsl := this.ToHSL()
        color2 := Color.FromHSL(Mod(hsl.H + 120, 360), hsl.S, hsl.L)
        color3 := Color.FromHSL(Mod(hsl.H + 240, 360), hsl.S, hsl.L)

        return [this, color2, color3]
    }

    /**
     * Produces a gradient from the current `Color` instance to another `Color` instance.
     * @param endColor The other color in the gradient.
     * @param {Integer} steps How many colors in-between should be made?
     * @returns {Color[]}
     */
    Gradient(endColor, steps := 10)
    {
        gradient := []
        gradient.Push(this)
        
        Loop steps - 1
        {
            weight := A_Index / steps
            gradient.Push(this.Mix(endColor, weight * 100))
        }
        
        gradient.Push(endColor)
        
        return gradient
    }
}

/**
#Requires AutoHotKey v2.0
#Include ColorPicker.ahk
#Include Color.ahk

TestGui := Gui()
TestGui.Title := "Color Class Test"
TestGui.Opt("+Resize")

startColor := Color.Random()
endColor   := Color.Random()

CreateControls()
UpdateControls()
TestGui.Show()

MsgBox("
    (
        This demonstration shows some of the Capabilities of the Color class.
        Every individual box is displaying an instance of the Color class.

        There are 149 boxes in total:
        Single color operations, 70 boxes arranged in a grid (5x14).
        There are also 20 boxes for Analogous colors
        15 Boxes for Triadic colors
        And 54 boxes for the gradient.
    )")

LaunchStartColorPicker(*)
{
    picker := ColorPicker(False,, UpdateStartColor)
    picker.DefaultCaptureSize := 5
    picker.DefaultZoomFactor := 12
    picker.ViewMode := "crosshair"
    picker.OnExit := ExitStartColor
    picker.Start()
}

LaunchEndColorPicker(*)
{
    picker := ColorPicker(False,, UpdateEndColor)
    picker.DefaultCaptureSize := 5
    picker.DefaultZoomFactor := 12
    picker.ViewMode := "crosshair"
    picker.OnExit := ExitEndColor
    picker.Start()
}

RandomizeColors(*)
{
        global startColor := Color.Random()
        global endColor   := Color.Random()
        UpdateControls()
}

UpdateStartColor(_color)
{
    global startColor := _color
    UpdateTopRow()
}

UpdateEndColor(_color)
{
    global endColor := _color
    UpdateTopRow()
}

ExitStartColor(_color)
{
    global startColor := _color
    UpdateControls()
}

ExitEndColor(_color)
{
    global endColor := _color
    UpdateControls()
}

CreateControls()
{
    global controls := Map()
    
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]
    columnX := [120, 240, 360, 480, 600]

    TestGui.Add("Button", "x" columnX[1] " y10 w100", "Pick Start Color").OnEvent("Click", LaunchStartColorPicker)
    TestGui.Add("Button", "x" columnX[2] " y10 w100", "Pick End Color").OnEvent("Click", LaunchEndColorPicker)
    TestGui.Add("Button", "x" columnX[3] " y10 w100", "Randomize").OnEvent("Click", RandomizeColors)
    
    for i, label in columnLabels
    {
        TestGui.Add("Text", "x" columnX[i] " y50 w100 Center", label)
        controls[label] := TestGui.Add("Progress", "x" columnX[i]+10 " y70 w20 h20")
        controls[label "Text"] := TestGui.Add("Text", "x" columnX[i]+35 " y70 w80 h20 Left", "")
    }
    
    colorProperties := ["Hex → RGB", "RGB → RGB", "HSL → RGB", "HWB → RGB", "CMYK → RGB", "NCol → RGB", "Invert", "Lighten", "Darken", "Saturate", "Desaturate", "Grayscale", "Complement"]
    
    for i, prop in colorProperties
    {
        y := 100 + (i - 1) * 30
        TestGui.Add("Text", "x10 y" y " w100 Right", prop)

        for j, label in columnLabels
        {
            controls[label prop] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y-2 " w20 h20")
            controls[label prop "Text"] := TestGui.Add("Text", "x" columnX[j]+35 " y" y " w80 h20 Left", "")
        }
    }

    ; Add Analogous and Triadic displays
    y := 495
    TestGui.Add("Text", "x10 y" y " w100 Right", "Analogous")
    for j, label in columnLabels
    {
        controls[label "Analogous1"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y-5 " w20 h20")
        controls[label "Analogous2"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y-5 " w20 h20")
        controls[label "Analogous3"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y+15 " w20 h20")
        controls[label "Analogous4"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y+15 " w20 h20")
        controls[label "AnalogousText"] := TestGui.Add("Text" , "x" columnX[j]+5  " y" y+40 " w80 h20 Center")
    }

    y += 50
    TestGui.Add("Text", "x10 y" y " w100 Right", "Triadic")
    for j, label in columnLabels
    {
        controls[label "Triadic1"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y-5 " w20 h20")
        controls[label "Triadic2"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y-5 " w20 h20")
        controls[label "Triadic3"] := TestGui.Add("Progress", "x" columnX[j]+20 " y" y+15 " w20 h20")
        controls[label "TriadicText"] := TestGui.Add("Text" , "x" columnX[j]+5  " y" y+40 " w80 h20 Center")
    }

    ; Gradient display
    y += 50
    TestGui.Add("Text", "x10 y" y " w100 Right", "Gradient")
    Loop 54
    {
        controls["Gradient" A_Index] := TestGui.Add("Progress", "x" 120+(A_Index-1)*10 " y" y-5 " w10 h20")
    }
}

UpdateTopRow()
{
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]
    colorColumns := [startColor, endColor, startColor.Mix(endColor), Color.Average(startColor, endColor), Color.Multiply(startColor, endColor)]
    
    for i, _color in colorColumns
    {
        UpdateColorDisplay(columnLabels[i], _color)
    }
}

UpdateControls()
{
    mixedColor := startColor.Mix(endColor)
    averageColor := Color.Average(startColor, endColor)
    multipliedColor := Color.Multiply(startColor, endColor)

    colorColumns := [startColor, endColor, mixedColor, averageColor, multipliedColor]
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]

    for i, _color in colorColumns
    {
        UpdateColorDisplay(columnLabels[i], _color)
        UpdateColorDisplay(columnLabels[i] "Hex → RGB", _color)
        UpdateColorDisplay(columnLabels[i] "RGB → RGB", Color.FromRGB(_color.R, _color.G, _color.B))

        hsl := _color.ToHSL()
        UpdateColorDisplay(columnLabels[i] "HSL → RGB", Color.FromHSL(hsl.H, hsl.S, hsl.L))

        hwb := _color.ToHWB()
        UpdateColorDisplay(columnLabels[i] "HWB → RGB", Color.FromHWB(hwb.H, hwb.W, hwb.B))

        cmyk := _color.ToCMYK()
        UpdateColorDisplay(columnLabels[i] "CMYK → RGB", Color.FromCMYK(cmyk.C, cmyk.M, cmyk.Y, cmyk.K))

        ncol := _color.ToNCol()
        UpdateColorDisplay(columnLabels[i] "NCol → RGB", Color.FromNCol(ncol.H, ncol.W, ncol.B))
        UpdateColorDisplay(columnLabels[i] "Invert", _color.Invert())
        UpdateColorDisplay(columnLabels[i] "Lighten", _color.Lighten(20))
        UpdateColorDisplay(columnLabels[i] "Darken", _color.Darken(20))
        UpdateColorDisplay(columnLabels[i] "Saturate", _color.Saturate(20))
        UpdateColorDisplay(columnLabels[i] "Desaturate", _color.Desaturate(20))
        UpdateColorDisplay(columnLabels[i] "Grayscale", _color.Grayscale())
        UpdateColorDisplay(columnLabels[i] "Complement", _color.Complement())
    }

    ; Update Analogous and Triadic displays
    for i, _color in colorColumns
    {
        analogous := _color.Analogous(30, 4)
        triadic := _color.Triadic()

        UpdateColorDisplay(columnLabels[i] "Analogous1", analogous[1])
        UpdateColorDisplay(columnLabels[i] "Analogous2", analogous[2])
        UpdateColorDisplay(columnLabels[i] "Analogous3", analogous[3])
        UpdateColorDisplay(columnLabels[i] "Analogous4", analogous[4])

        UpdateColorDisplay(columnLabels[i] "Triadic1", triadic[1])
        UpdateColorDisplay(columnLabels[i] "Triadic2", triadic[2])
        UpdateColorDisplay(columnLabels[i] "Triadic3", triadic[3])
    }

    gradient := startColor.Gradient(endColor, 54)
    Loop 54
    {
        hex := gradient[A_Index].ToHex("{R}{G}{B}").Full
        controls["Gradient" A_Index].Opt("c" hex " Background" hex)
    }
}

UpdateColorDisplay(label, _color)
{
    hex := _color.ToHex("{R}{G}{B}").Full
    controls[label].Opt("c" hex " Background" hex)

    if (controls.Has(label "Text"))
    {
        controls[label "Text"].Value := _color.ToHex("0x{R}{G}{B}").Full
    }
}

TestGui.OnEvent("Close", (*) => ExitApp())