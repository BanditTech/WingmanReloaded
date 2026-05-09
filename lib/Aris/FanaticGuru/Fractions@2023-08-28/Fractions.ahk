;{ [Class] Fractions
; Fanatic Guru
; 2023 08 28
;
; #Requires AutoHotkey v2
;
; CLASS to work with Fractions
;------------------------------------------------
;
; Methods:
;	Lowest					Return Fraction object deduced to Lowest Terms (no approximation)
;	Lower					Return Fraction object deduced to Lower Terms (approximation if necessary)
;	Precision				Return Fraction object deduced to Terms based on a Precision (approximation if necessary)
;	Fraction				Return Fraction object
;	Arch					Return Fraction object from architectural measurement string
;	GCD						Return Greatest Common Divisor
;
; Fraction Object:
;	{Fraction}.Proper		Returns Proper Fraction String
;	{Fraction}.P			Returns Proper Fraction String
;	{Fraction}.Irregular	Returns Irregular Fraction String
;	{Fraction}.I			Returns Irregular Fraction String
;	{Fraction}.Numerator	Returns Fraction Numerator Number
;	{Fraction}.N			Returns Fraction Numerator Number
;	{Fraction}.Denominator	Returns Fraction Denominator Number
;	{Fraction}.D			Returns Fraction Denominator Number
;	{Fraction}.Whole		Returns Fraction Whole Number
;	{Fraction}.W			Returns Fraction Whole Number
;	{Fraction}.Remainder	Returns Fraction Remainder String
;	{Fraction}.R			Returns Fraction Remainder String
;	{Fraction}.RN			Returns Fraction Remainder Numerator Number
;	{Fraction}.RD			Returns Fraction Remainder Denominator Number
;	{Fraction}.Decimal		Returns Decimal to Float .15g Formatted String of Number
;	{Fraction}.Unit			Returns ' or " or null if not set String
;	{Fraction}.Arch			Returns Architectural Measurement with feet and/or inches if Unit set String (AutoCAD format)
;
;------------------------------------------------
;
; Method:
;   Lowest([Numerator, Denominator])
;
; Parameters:
;   1) [{Numerator}, 		Array with item 1 being an integer Numerator of a fraction
;   1) {Denominator}] 		Array with item 2 being an integer Denominator of a fraction
;	OR
;	1) {Fraction Object}	Fraction Object with Numerator and Denominator properties
;
; Example:
;	MsgBox Fractions.Lowest([15,81]).Proper 				; Returns 5/27
;
;------------------------------------------------
;
; Method:
;   Lower([Numerator, Denominator], Max_Denominator)
;
; Parameters:
;   1) [{Numerator}, 		Array with item 1 being an integer Numerator of a fraction
;   1) {Denominator}] 		Array with item 2 being an integer Denominator of a fraction
;	or
;	1) {Fraction Object}	Fraction Object with Numerator and Denominator
;   2) {Max_Denominator?}	(Optional) An integer Maximum Denominator of returned fraction
;							If no Max_Denominator, fraction is reduced to the best approximate fraction with a lesser denominator
;
; Comment:
; 	If fraction has no common divisor then rational approximation will be used to force a common divisor
;	using a continued fraction algorithm based on Pythons source code for fractions.limit_denominator.
;
; Example:
;	MsgBox Fractions.Lower([16,32]).Proper				; Returns 1/2
;	MsgBox Fractions.Lower([8,33]).Proper				; Returns 7/29 by approximation which is slightly closer than 1/4 or 4/17
;	MsgBox Fractions.Lower([1429, 1000], 123).Proper	; Returns 1 3/7 by aprroximation with a limit of 123 or less for denominator
;	MsgBox Fractions.Lower([1310, 1113], 99).Irregular	; Returns 113/96 by approximation with a limit of 99 (2 digits)
;
;------------------------------------------------
;
; Method:
;   Terms.Precision([Numerator, Denominator], Precision)
;
;   Parameters:
;   1) [{Numerator}, 		Array with item 1 being an integer Numerator of a fraction
;   1) {Denominator}] 		Array with item 2 being an integer Denominator of a fraction
;	or
;	1) {Fraction Object}	Fraction Object with Numerator and Denominator
;   2) {Precision?}			(Optional) An integer to force denominator to approximate to this term ie. 16 rounds fraction to 16ths
;
;	After approximation forced by Precision, fraction will be reduce to lowest terms
;
; Example:
; 	MsgBox Fractions.Precision([123,987],16).Proper 		; Returns 1/8
;
;------------------------------------------------
;
; Method:
;   Fraction([Numerator, Denominator], Unit?, Arch?)
;
; Parameters:
;   1) [{Numerator}, 		Array with item 1 being an integer Numerator of a fraction
;   1) {Denominator}] 		Array with item 2 being an integer Denominator of a fraction
;	or
;	1) {Fraction Object}	Fraction Object with Numerator and Denominator
;   2) {Unit?}	 			Measurement Unit ie. ' or " 
;   3) {Arch?}				(Optional) Architectural Measurement with feet and/or inches if Unit set (AutoCAD format)
;
; Example:
; 	MsgBox Fractions.Fraction([4,16]).Proper 				; Return 4/16
;
;------------------------------------------------
;
; Method:
;	Arch(Measurement, &Unit?)
;
;	Parameters:
;   1) {Measurement String}				; Measurement String, i.e., 4'6"
;   2) {&Unit?}							; (Optinal) ByRef Variable that will be set to unit ' or " or null
;   3) {Precision?}						; (Optional) An integer to force denominator to approximate to this term ie. 16 rounds fraction to 16ths
;
; Example:
; MsgBox Fractions.Arch("4/8").Decimal								; 0.5
; MsgBox Fractions.Arch("1 4/10").Proper							; 1 4/10
; MsgBox Fractions.Arch("-2'9`"").Decimal							; -2.75
; MsgBox Fractions.Arch("-4'- 5 3/12`"", &Unit).Decimal Unit		; -4.4375'
; MsgBox Fractions.Arch("-4.4375'", &Unit).Arch						; -4'-5 1/4"
; MsgBox Fractions.Arch("5 feet 123 / 456 inches", &Unit, 16).Arch	; 5'-0 1/4"
;
;------------------------------------------------
;
; Method:
;   GCD(A,B)
;
; Parameters:
;   1) {A} 	Integer
;   2) {B} 	Integer
;
; Example:
; 	MsgBox Fractions.GCD(9,15) 									; Returns 3
;
;------------------------------------------------
;
;}
Class Fractions
{
	Static Lowest(Frac)
	{
		(Frac is Array ? (N := Frac[1], D := Frac[2]) : (N := Frac.N, D := Frac.D))
		X := 0
		While X != 1
			X := Fractions.GCD(N, D), N := N // X, D := D // X
		Return Fractions.Fraction([N, D])
	}
	Static Lower(Frac, Max_D?)
	{
		(Frac is Array ? (N := Frac[1], D := Frac[2]) : (N := Frac.N, D := Frac.D))
		if !IsSet(Max_D)
			Max_D := D - 1
		If D = 1
			Return Fractions.Fraction([N, D])
		(N * D < 0 ? Sign := -1 : Sign := 1), N := Abs(N), Denominator := D := Abs(D)
		p0 := 0, q0 := 1, p1 := 1, q1 := 0
		Loop
		{
			Try a := N // D
			Catch
				Break
			q2 := q0 + a * q1
			If q2 > Max_D or !D
				Break
			t := p0, p0 := p1, q0 := q1, p1 := t + a * p1, q1 := q2
			t := N, N := D, D := t - a * D
		}
		k := (Max_D - q0) // q1
		If 2 * D * (q0 + k * q1) <= Denominator
			Return Fractions.Fraction([p1 * Sign, q1])
		Else
			Return Fractions.Fraction([(p0 + k * p1) * Sign, q0 + k * q1])
	}
	Static Precision(Frac, P?)
	{
		(Frac is Array ? (N := Frac[1], D := Frac[2]) : (N := Frac.N, D := Frac.D))
		If IsSet(P)
			N := Round(N / D * P), D := P
		Return Fractions.Lowest([N, D])
	}
	Static Arch(Measurement, &Unit?, Precision?)
	{
		N := N_Feet := N_Inches := 0, D := D_Feet := D_Inches := 1, Has_Neg := Has_Feet := Has_Inches := false
		If RegExMatch(Measurement, '^\s*-')
			Has_Neg := true
		If RegExMatch(Measurement, 'i)^[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*(?:feet|foot|ft|`')(?<Remaining>.*)$', &Match)
		{
			(Match.Len(1) && Num := 1), (Match.Len(2) && Num := 2), (Match.Len(3) && Num := 3)
			Switch Num
			{
				Case 1:
					N_Feet := Match[1], D_Feet := 1
				Case 2:
					N_Feet := Match[1], D_Feet := Match[2]
				Case 3:
					N_Feet := Match[1] * Match[3] + Match[2], D_Feet := Match[3]
			}
			Has_Feet := true, Measurement := Match.Remaining
		}
		If RegExMatch(Measurement, 'i)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*(?:inch|in|")[^\d\.]*$', &Match)
		{
			(Match.Len(1) && Num := 1), (Match.Len(2) && Num := 2), (Match.Len(3) && Num := 3)
			Switch Num
			{
				Case 1:
					N_Inches := Match[1], D_Inches := 1
				Case 2:
					N_Inches := Match[1], D_Inches := Match[2]
				Case 3:
					N_Inches := Match[1] * Match[3] + Match[2], D_Inches := Match[3]
			}
			Has_Inches := true
		}
		If Has_Feet
			N := (N_Feet * D_Inches * 12) + (N_Inches * D_Feet), D := (D_Feet * D_Inches * 12)
		Else If Has_Inches
			N := N_Inches, D := D_Inches
		Else
		{
			RegExMatch(Measurement, 'i)([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)', &Match)
			(Match.Len(1) && Num := 1), (Match.Len(2) && Num := 2), (Match.Len(3) && Num := 3)
			Switch Num
			{
				Case 1:
					N := Match[1], D := 1
				Case 2:
					N := Match[1], D := Match[2]
				Case 3:
					N := Match[1] * Match[3] + Match[2], D := Match[3]
			}
		}
		RegExMatch(Format('{:.15g}', N), '^\D*(\d*)\.?(\d*?)$', &Match), N := Integer(Match[1] Match[2]), D := 10 ** StrLen(Match[2]) * D
		Unit := (Has_Feet ? "'" : (Has_Inches ? '"' : '')), (Has_Neg && N := -N)
		If Unit = "'" or !Unit
		{
			F_Feet := Fractions.Fraction([N, D])
			Feet := F_Feet.Whole "'"
			If F_Feet.Remainder
			{
				If IsSet(Precision)
					F_Inches := Fractions.Precision([Abs(F_Feet.RN * 12), F_Feet.RD], Precision)
				Else
					F_Inches := Fractions.Lowest([Abs(F_Feet.RN * 12), F_Feet.RD])
				If F_Inches.RN
					Inches := '-' F_Inches.W ' ' F_Inches.RN '/' F_Inches.RD '"'
				Else If F_Inches.W
					Inches := '-' F_Inches.W '"'
			}
			Else
				Inches := '-0"'
		}
		Else
		{
			Feet := ''
			If IsSet(Precision)
				F_Inches := Fractions.Precision([N, D], Precision)
			Else
				F_Inches := Fractions.Fraction([N, D])
			If F_Inches.RN
				If F_Inches.W
					Inches := F_Inches.W ' ' F_Inches.RN '/' F_Inches.RD '"'
				Else
					Inches := F_Inches.RN '/' F_Inches.RD '"'
			Else If F_Inches.W
				Inches := F_Inches.W '"'
			Else
				Inches := '0"'
		}
		Return Fractions.Fraction([N, D], Unit, Feet Inches)
	}
	Static Fraction(Frac, Unit?, Arch?)
	{
		If Frac is Array
			N := Frac[1], D := Frac[2]
		Else If Frac is Object
			N := Frac.N, D := Frac.D
		Else If IsNumber(Frac)
		{
			RegExMatch(Format('{:.15g}', Frac), '^\D*(\d*)\.?(\d*?)$', &Match), N := Integer(Match[1] Match[2])
			(Frac < 0 && N := -N)
			D := 10 ** StrLen(Match[2])
		}
		Else If Frac is String
		{
			RegExMatch(Frac, '\s*(-?)\D*(\d*)\D*(\d*)\D*(\d*)', &Match)
			(Match[1] ? Sign := -1 : Sign := 1)
			If Match.Len[4]
				N := Match[3] + Match[2] * Match[4], D := Match[4]
			Else If Match.Len[3]
				N := Match[2], D := Match[3]
			Else
				N := Match[2], D := 1
			N *= Sign
		}
		((N < 0) = (D < 0) ? (N := Abs(N), D := Abs(D)) : (N := -Abs(N), D := Abs(D)))
		Return { N: N, D: D, Numerator: N, Denominator: D, Irregular: Irregular := N (D != 1 ? '/' D : ''), I: Irregular, Whole: Whole := N // D, W: Whole, Remainder: Remainder := (Mod(N, D) ? (RN := Mod(N, D)) '/' (RD := D) : RN := RD := ''), R: Remainder, RN: RN, RD: RD, Proper: Proper := Trim((Whole ? Whole : '') (Remainder ? ' ' (Whole < 0 ? Trim(Remainder, '-') : Remainder) : '')), P: Proper, Decimal: Format('{:.15g}', N / D), Unit: IsSet(Unit) ? Unit : '', Arch: IsSet(Arch) ? Arch : '' }
	}
	Static GCD(A, B)
	{
		While B
			B := Mod(A | 0x0, A := B)
		Return A
	}
}
