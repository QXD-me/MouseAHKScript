﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; TODO - function for off

CoordMode, Mouse, Screen


#maxThreadsPerHotkey, 2
setKeyDelay, 50, 50
SetMouseDelay, 2
SetDefaultMouseSpeed, 0
isEnabled:=0

scrollAmount:= 100
currentOffset:=0

Suspend, on


UMS:
    If isEnabled {

        SystemCursor("Off")
        
        
        MouseGetPos, xpos, ypos
        
        yOffset:=ypos - yposlast
        xOffset:=xpos - xposlast
        isNegative:=yOffset < 0
        magnitude:= Sqrt(yOffset * yOffset + xOffset * xOffset)
        
        if (isNegative) {
            magnitude:= magnitude * -1
        }
        
        currentOffset:= currentOffset + magnitude

        MouseMove, xposlast, yposlast, 0
        
        ; Should I disable mouse movement somehow from here until after the scroll?

        if (currentOffset < -scrollAmount) {
            Click, WheelUp
            currentOffset:= currentOffset + scrollAmount
        } else if (currentOffset > scrollAmount) {
            Click, WheelDown
            currentOffset:= currentOffset - scrollAmount
        }
        
        if (currentOffset < -scrollAmount or currentOffset > scrollAmount) {
            currentOffset:= currentOffset * 0.95
        }
    }
    return


*+<^>!Home::
        Suspend,Off
    If (isEnabled == 1) {
        SetTimer, UMS, off
        SystemCursor("On")
        isEnabled:=0
        Suspend,On
    }
    Else {
        MouseGetPos, xposinit, yposinit
        xposlast := xposinit
        yposlast := yposinit
        SetTimer, UMS, 3
        isEnabled:=1
    }
    return
    
LButton::
        SetTimer, UMS, off
        SystemCursor("On")
        isEnabled:=0
        Suspend,On
    return

SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
    {
        $ = h                                          ; active default cursors
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
            b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
                , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; use blank cursors
    else
        $ = h  ; use the saved cursors

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
        DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
    }
}