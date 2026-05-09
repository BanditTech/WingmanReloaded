; Source: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=106254
; Author: lexikos

/*  XInput by Lexikos
 */

#Requires AutoHotkey v2.0-beta.6

/*
    Function: XInput_Init
    
    Initializes XInput.ahk with the given XInput DLL.
    
    Parameters:
        dll     -   The path or name of the XInput DLL to load.
*/
XInput_Init(dll:="")
{
    global
    if _XInput_hm ?? 0
        return
    
    ;======== CONSTANTS DEFINED IN XINPUT.H ========
    
    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD          := 0x01

    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD       := 0x01

    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED     := 0x0004

    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP          := 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
    XINPUT_GAMEPAD_START            := 0x0010
    XINPUT_GAMEPAD_BACK             := 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
    XINPUT_GAMEPAD_GUIDE            := 0x0400
    XINPUT_GAMEPAD_A                := 0x1000
    XINPUT_GAMEPAD_B                := 0x2000
    XINPUT_GAMEPAD_X                := 0x4000
    XINPUT_GAMEPAD_Y                := 0x8000

    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  := 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE := 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD    := 30

    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD             := 0x00000001
    
    ;=============== END CONSTANTS =================
    
    if (dll = "")
        Loop Files A_WinDir "\System32\XInput1_*.dll"
            dll := A_LoopFileName
    if (dll = "")
        dll := "XInput1_3.dll"
    
    _XInput_hm := DllCall("LoadLibrary" ,"str",dll ,"ptr")
    
    if !_XInput_hm
        throw Error("Failed to initialize XInput: " dll " not found.")
    
   (_XInput_GetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"ptr",100 ,"ptr"))
|| (_XInput_GetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetState" ,"ptr"))
    _XInput_SetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputSetState" ,"ptr")
    _XInput_GetCapabilities := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetCapabilities" ,"ptr")
    
    if !(_XInput_GetState && _XInput_SetState && _XInput_GetCapabilities) {
        XInput_Term()
        throw Error("Failed to initialize XInput: function not found.")
    }
}

/*
    Function: XInput_GetState
    
    Retrieves the current state of the specified controller.

    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value from 0 to 3.
    
    Returns:
        An object with with properties equivalent to merging XINPUT_STATE and XINPUT_GAMEPAD.
        https://docs.microsoft.com/en-us/windows/win32/api/xinput/ns-xinput-xinput_state
    
    Error handling:
        Returns false if the controller is disconnected.
        Throws an OSError for other errors.
*/
XInput_GetState(UserIndex)
{
    global _XInput_GetState
    
    xiState := Buffer(16)

    if err := DllCall(_XInput_GetState ,"uint",UserIndex ,"ptr",xiState) {
        if err = 1167 ; ERROR_DEVICE_NOT_CONNECTED
            return 0
        throw OSError(err, -1)
    }
    
    return {
        dwPacketNumber: NumGet(xiState,  0, "UInt"),
        wButtons:       NumGet(xiState,  4, "UShort"),
        bLeftTrigger:   NumGet(xiState,  6, "UChar"),
        bRightTrigger:  NumGet(xiState,  7, "UChar"),
        sThumbLX:       NumGet(xiState,  8, "Short"),
        sThumbLY:       NumGet(xiState, 10, "Short"),
        sThumbRX:       NumGet(xiState, 12, "Short"),
        sThumbRY:       NumGet(xiState, 14, "Short"),
    }
}

/*
    Function: XInput_SetState
    
    Sends data to a connected controller. This function is used to activate the vibration
    function of a controller.
    
    Parameters:
        UserIndex       -   [in] Index of the user's controller. Can be a value from 0 to 3.
        LeftMotorSpeed  -   [in] Speed of the left motor, between 0 and 65535.
        RightMotorSpeed -   [in] Speed of the right motor, between 0 and 65535.
    
    Error handling:
        Throws an OSError on failure, such as if the controller is not connected.
    
    Remarks:
        The left motor is the low-frequency rumble motor. The right motor is the
        high-frequency rumble motor. The two motors are not the same, and they create
        different vibration effects.
*/
XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
{
    global _XInput_SetState
    if err := DllCall(_XInput_SetState ,"uint",UserIndex ,"uint*",LeftMotorSpeed|RightMotorSpeed<<16)
        throw OSError(err, -1)
}

/*
    Function: XInput_GetCapabilities
    
    Retrieves the capabilities and features of a connected controller.
    
    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value in the range 03.
        Flags       -   [in] Input flags that identify the controller type.
                                0   - All controllers.
                                1   - XINPUT_FLAG_GAMEPAD: Xbox 360 Controllers only.
    
    Returns:
        An object with properties equivalent to XINPUT_CAPABILITIES.
        https://docs.microsoft.com/en-au/windows/win32/api/xinput/ns-xinput-xinput_capabilities
    
    Error handling:
        Returns false if the controller is disconnected.
        Throws an OSError for other errors.
*/
XInput_GetCapabilities(UserIndex, Flags)
{
    global _XInput_GetCapabilities
    
    xiCaps := Buffer(20)
    
    if err := DllCall(_XInput_GetCapabilities ,"uint",UserIndex ,"uint",Flags ,"ptr",xiCaps) {
        if err = 1167 ; ERROR_DEVICE_NOT_CONNECTED
            return 0
        throw OSError(err, -1)
    }
    
    return {
        Type:                   NumGet(xiCaps,  0, "UChar"),
        SubType:                NumGet(xiCaps,  1, "UChar"),
        Flags:                  NumGet(xiCaps,  2, "UShort"),
        Gamepad: {
            wButtons:           NumGet(xiCaps,  4, "UShort"),
            bLeftTrigger:       NumGet(xiCaps,  6, "UChar"),
            bRightTrigger:      NumGet(xiCaps,  7, "UChar"),
            sThumbLX:           NumGet(xiCaps,  8, "Short"),
            sThumbLY:           NumGet(xiCaps, 10, "Short"),
            sThumbRX:           NumGet(xiCaps, 12, "Short"),
            sThumbRY:           NumGet(xiCaps, 14, "Short")
        },
        Vibration: {
            wLeftMotorSpeed:    NumGet(xiCaps, 16, "UShort"),
            wRightMotorSpeed:   NumGet(xiCaps, 18, "UShort")
        }
    }
}

/*
    Function: XInput_Term
    Unloads the previously loaded XInput DLL.
*/
XInput_Term() {
    global
    if _XInput_hm
        DllCall("FreeLibrary","uint",_XInput_hm), _XInput_hm :=_XInput_GetState :=_XInput_SetState :=_XInput_GetCapabilities :=0
}

; TODO: XInputEnable, 'GetBatteryInformation and 'GetKeystroke.