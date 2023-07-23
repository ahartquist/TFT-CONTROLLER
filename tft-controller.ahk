#Requires AutoHotkey v2.0-beta.6

;######### UPDATED TO AHK 2.0 & XInput ###########
;
; "Joy key hotkey only works on ahk window"
; https://www.autohotkey.com/boards/viewtopic.php?f=82&p=510578

; This is a known limitation. In Windows 10 and 11 with newer Xbox controllers 
; (those released after the Xbox 360 controller) built in hotkeys like Joy1 and
; and GetKeyState reading of controller states only works when an 
; AutoHotkey window has focus. To get them working when other windows are active you have to use XInput.

;
; Custom key combos commented out and abandoned since XInput works differently. 
; Two buttons pressed at the same time sum to a different value.
; Implementation would be done differently.
;
; Helpful debugger ToolTip (~ line 404)
;
;######### UPDATED TO AHK 2.0 & XInput ###########

; Using a Joystick as a Mouse for TFT
; To use this script, http://www.autohotkey.com
; This script allows to use a gamepad as mouse and keyboard.
; It is fully configurable and can meet several requests I hope.
; Je ne sais pas si le CPU est surchargé, je n'ai pas les connaissance pour savoir cela.
; Si vous avez des suggestions n'hésiter pas à me contacter
;
; How to use :
; First you have to set the size of your screen (x and y)
; Second launch and try. If not append, try to change the number of the controller.
; Set 2 to 1 or 2 to 3... If your controller is working but your squares are not,
; Go to the edit section (~ line 94)

;State.wButtons
SQUARE_OR_X     := 16384
CROSS_OR_A      := 4096
CIRCLE_OR_B     := 8192
TRIANGLE_OR_Y   := 32768
L1_OR_LB        := 256
R1_OR_RB        := 512

;State.bLeftTrigger
L2_OR_LT        := 255

;State.bRightTrigger
R2_OR_RT        := 255

OPTIONS_OR_LIST := 16
; ---------------------------------------------------------------------------------
; Configuration
; This part you can edit.

; Resolution of your screen
; Required. This makes it possible to automatically know the place of the boxes
RESOLUTION_X := 1920    ; Default: 1920
RESOLUTION_Y := 1080    ; Default: 1080

; Shortcuts TFT
; if you use other keys in tft, edit with your shortcuts
K_BUY_XP    := "f"        ; Default: f
K_REROLL    := "d"        ; Default: d
K_SELL      := "e"        ; Default: e
 
K_NEXT_CAM  := "q"        ; Default: q
K_PREV_CAM  := "r"        ; Default: r
K_CENT_CAM  := "{Space}"  ; Default: Space
K_DEP_RET   := "w"        ; Default: w

K_ESCAPE    := "{Esc}" ; Default : Escape

; Buttons configuration
; Here you can decide which buttons does what
BUY_XP       := SQUARE_OR_X     ; Default: SQUARE_OR_X
LEFT_CLICK   := CROSS_OR_A      ; Default: CROSS_OR_A
REROLL       := CIRCLE_OR_B     ; Default: CIRCLE_OR_B
SELL         := TRIANGLE_OR_Y   ; Default: TRIANGLE_OR_Y

PREV_CAM     := L1_OR_LB        ; Default: L1_OR_LB
NEXT_CAM     := R1_OR_RB        ; Default: R1_OR_RB
DEP_RET      := L2_OR_LT        ; Default: L2_OR_LT
RIGHT_CLICK  := R2_OR_RT        ; Default: R2_OR_RT

MENU_OPTIONS := OPTIONS_OR_LIST ; Default: OPTIONS_OR_LIST

; Here, its the custom key. you have to press both;
; [touch_1, touche_2, what_you_want_to_do]
;CUS_KEY_1   := [L1_OR_LB, R1_OR_RB, K_CENT_CAM] ; Default: L1_OR_LB&R1_OR_RB     (custom)
;CUS_KEY_2   := [L2_OR_LT, R2_OR_RT, K_DEP_RET]  ; Default: L2_OR_LT&R2_OR_RT     (custom)

; Custom key Combos disabled. Refer to description at top.

; Movement speed of the mouse (in second)
SPEED := 2      ; Default: 2

; Delay to go on the game (in second)
WAIT  := 0     ; Default: 3

; Special edit
; If your squares are wrong, change the value of DEBUG to 1 and read the small explanation.
DEBUG := 0

; To make it simple it's the percentage where the square is
; You will see a small window next to your mouse.
; First, go to each box and write down all the numbers in each box that will appear.
; Second, add them to the corresponding variables. More explications in my github
AREA_BATTLEFIELD_X_1 := [29, 35, 41, 48, 53, 59, 65]
AREA_BATTLEFIELD_X_2 := [32, 38, 44, 50, 56, 63, 69]
AREA_BATTLEFIELD_Y   := [42, 48, 55, 62]

AREA_BENCH_X    := [22, 29, 34, 41, 47, 53, 59, 66, 72]
AREA_BENCH_Y    := [73]

AREA_SHOP_X     := [30, 40, 51, 61, 72]
AREA_SHOP_Y     := [92]

AREA_OBJECTS_X  := [ [18, 21], [18, 20, 23], [18, 21], [16], [18], [16] ]
AREA_OBJECTS_Y  := [ 58, 61, 63, 66, 69, 72 ]

; End of configuration. Don't change anything below
; ---------------------------------------------------------------------------------

debug_num_controller := []
Loop 16 
{
	if (GetKeyState(A_Index "JoyName"))
	{
		debug_num_controller.Push(A_Index)
	}
}
    
if(debug_num_controller.Length >= 1) 
{
	MsgBox " Success ! Controller detected."
}
else 
{
	for i in debug_num_controller 
	{
		if(i != 1)
		{
			str := str ", "
		}
		str := str debug_num_controller[i]
	}
	MsgBox " Error ! Controller not detected."
	ExitApp
}

WAIT  := WAIT  * 1000

; Movements
BTN_RIGHT := 8 
BTN_LEFT  := 4 
BTN_UP    := 1
BTN_DOWN  := 2

; Calculate auto all case
DIV_100_X := RESOLUTION_X / 100 ; Do not change this.
DIV_100_Y := RESOLUTION_Y / 100 ; Do not change this.

; Initialize some variables

x := 0
y := 0

WB := 0
LT := 0
RT := 0
LX := 0
LY := 0
RX := 0
RY := 0

BATTLEFIELD_X := 0

; Debugging
Loop {
    if(GetKeyState("Esc") || !DEBUG)
        break

    MouseGetPos x, y
    debug_x := Round(x * 100 / RESOLUTION_X)
    debug_y := Round(y * 100 / RESOLUTION_Y)
    ToolTip "debugging: press ctrl to exit`n" debug_x ", " debug_y

}

; Coordinates of squares
BATTLEFIELD_X_1 := [DIV_100_X * AREA_BATTLEFIELD_X_1[1], DIV_100_X * AREA_BATTLEFIELD_X_1[2], DIV_100_X * AREA_BATTLEFIELD_X_1[3], DIV_100_X * AREA_BATTLEFIELD_X_1[4] - 20, DIV_100_X * AREA_BATTLEFIELD_X_1[5], DIV_100_X * AREA_BATTLEFIELD_X_1[6], DIV_100_X * AREA_BATTLEFIELD_X_1[7]]
BATTLEFIELD_X_2 := [DIV_100_X * AREA_BATTLEFIELD_X_2[1], DIV_100_X * AREA_BATTLEFIELD_X_2[2], DIV_100_X * AREA_BATTLEFIELD_X_2[3], DIV_100_X * AREA_BATTLEFIELD_X_2[4] - 20, DIV_100_X * AREA_BATTLEFIELD_X_2[5], DIV_100_X * AREA_BATTLEFIELD_X_2[6] + 20, DIV_100_X * AREA_BATTLEFIELD_X_2[7] + 40]
BATTLEFIELD_Y   := [DIV_100_Y * AREA_BATTLEFIELD_Y[1], DIV_100_Y * AREA_BATTLEFIELD_Y[2], DIV_100_Y * AREA_BATTLEFIELD_Y[3], DIV_100_Y * AREA_BATTLEFIELD_Y[4]]

BENCH_X := [DIV_100_X * AREA_BENCH_X[1], DIV_100_X * AREA_BENCH_X[2], DIV_100_X * AREA_BENCH_X[3], DIV_100_X * AREA_BENCH_X[4], DIV_100_X * AREA_BENCH_X[5], DIV_100_X * AREA_BENCH_X[6], DIV_100_X * AREA_BENCH_X[7], DIV_100_X * AREA_BENCH_X[8], DIV_100_X * AREA_BENCH_X[9]]
BENCH_Y := DIV_100_Y * AREA_BENCH_Y[1]

SHOP_X := [DIV_100_X * AREA_SHOP_X[1], DIV_100_X * AREA_SHOP_X[2], DIV_100_X * AREA_SHOP_X[3], DIV_100_X * AREA_SHOP_X[4], DIV_100_X * AREA_SHOP_X[5]]
SHOP_Y := DIV_100_Y * AREA_SHOP_Y[1]

OBJECTS_X_6 := [DIV_100_X * AREA_OBJECTS_X[1][1], DIV_100_X * AREA_OBJECTS_X[1][2]]
OBJECTS_X_5 := [DIV_100_X * AREA_OBJECTS_X[2][1], DIV_100_X * AREA_OBJECTS_X[2][2], DIV_100_X * AREA_OBJECTS_X[2][3]]
OBJECTS_X_4 := [DIV_100_X * AREA_OBJECTS_X[3][1], DIV_100_X * AREA_OBJECTS_X[3][2]]
OBJECTS_X_3 := [DIV_100_X * AREA_OBJECTS_X[4][1]]
OBJECTS_X_2 := [DIV_100_X * AREA_OBJECTS_X[5][1]]
OBJECTS_X_1 := [DIV_100_X * AREA_OBJECTS_X[6][1]]
OBJECTS_Y   := [DIV_100_Y * AREA_OBJECTS_Y[6], DIV_100_Y * AREA_OBJECTS_Y[5], DIV_100_Y * AREA_OBJECTS_Y[4], DIV_100_Y * AREA_OBJECTS_Y[3], DIV_100_Y * AREA_OBJECTS_Y[2], DIV_100_Y * AREA_OBJECTS_Y[1]]


; You have N seconds to return to the game (default 3sec)
if(!DEBUG)
    Sleep WAIT

; Main program
program_launched := 1

menu_mode := 1      ; 1 = battlefield, bench, shop; 2 = objects; 3 = select_champ; 4 = select_asset

curr_len   := 7     ; default: for battlefield
curr_pos_x := 1     ; default: left
curr_pos_y := 1     ; default top

curr_x := BATTLEFIELD_X
curr_y := BATTLEFIELD_Y

left_click_down := 0

while program_launched != 0
{
    if State := XInputState(0) {
		WB := State.wButtons
		LT := State.bLeftTrigger
        RT := State.bRightTrigger
		LX := State.sThumbLX
		LY := State.sThumbLY
		RX := State.sThumbRX
		RY := State.sThumbRY		
}

    ; Simulate left click
	if(!left_click_down && (WB == LEFT_CLICK)) {
        left_click_down := 1
        Click "Down"
    }
	if(left_click_down && (WB != LEFT_CLICK)) 
	{
		left_click_down := 0
		Click "Up"
    }

	joy_x_raw := LX
	joy_y_raw := LY
	
    ; Simulate mouse movement
	;
	; GetKeyState read values 0 - 100, XInput reads values -32768 to 32767
	; I wanted to not change original scaling.
	
    joy_x := Round(((LX / 327.68 + 100) / 200) * 100, 1)
    joy_y := Round((100 - ((LY / 327.68 + 100) / 200) * 100), 1)
	
    if(!(joy_x >= 43 && joy_x <= 57) || !(joy_y >= 45 && joy_y <= 55))
        MouseMove joy_x * DIV_100_X, joy_y * DIV_100_Y
		
	; Get ALL event keys
    listener_btns_cus   := -1 ; Custom key Combos disabled. Refer to description at top.
	listener_btns_move  := listener_btns_cus != -1 ? -1 : (WB == BTN_RIGHT) ? BTN_RIGHT : (WB == BTN_LEFT) ? BTN_LEFT : (WB == BTN_UP) ? BTN_UP : (WB == BTN_DOWN) ? BTN_DOWN : -1
    listener_btns_prim  := listener_btns_cus != -1 ? -1 : (WB == BUY_XP) ? SQUARE_OR_X : (WB == REROLL) ? CIRCLE_OR_B : (WB == SELL) ? TRIANGLE_OR_Y : -1
    listener_btns_sec   := listener_btns_cus != -1 ? -1 : (WB == NEXT_CAM) ? R1_OR_RB : (WB == PREV_CAM) ? L1_OR_LB : (WB == MENU_OPTIONS) ? OPTIONS_OR_LIST : -1
    curr_btn := listener_btns_cus != -1 ? listener_btns_cus : listener_btns_move != -1 ? listener_btns_move : listener_btns_prim != -1 ? listener_btns_prim : listener_btns_sec != -1 ? listener_btns_sec : -1
	
	key := 0
	
	switch curr_btn {
        case BTN_RIGHT: curr_pos_x += 1
        case BTN_LEFT:  curr_pos_x -= 1
		case BTN_UP:    curr_pos_y -= (curr_pos_y >= 7 ? -1 : 1)
        case BTN_DOWN:  curr_pos_y += (curr_pos_y >= 7 ? -1 : 1)

        case BUY_XP: key := K_BUY_XP
        case REROLL: key := K_REROLL
        case SELL: key := K_SELL
        case PREV_CAM: key := K_PREV_CAM
        case NEXT_CAM: key := K_NEXT_CAM

        case OPTIONS_OR_LIST: key := K_ESCAPE

        ;case 20: key := CUS_KEY_1[3] ; Custom key Combos disabled. Refer to description at top.
        ;case 21: key := CUS_KEY_2[3] ; Custom key Combos disabled. Refer to description at top.
        default: key := -1
    }
    if((key != -1) && (key != 0))
	{
		Send key
        Sleep 200
    }
    if(key == 0)
	{
        Sleep 200
    }
	if (RT == RIGHT_CLICK)
	{
			Click "Down Right"
			Sleep 200
			Click "Up Right"
			Sleep 200
	}
    if (LT == DEP_RET)
	{
		Send K_DEP_RET
		Sleep 200
	}	

    ; get the coordinates
    if(curr_pos_y <= 4) {
        curr_len := 7
        curr_pos_x := (curr_pos_x == 8 && listener_btns_move == BTN_RIGHT) ? 1 : curr_pos_x > curr_len || !curr_pos_x ? curr_len : listener_btns_move == BTN_UP && curr_pos_y >= 4 ? curr_pos_x >= 2 ? curr_pos_x - 1 : curr_pos_x : curr_pos_x
		curr_pos_y := curr_pos_y <= 0 ? 4 : curr_pos_y
        coord_x := curr_pos_y == 2 || curr_pos_y == 4 ? BATTLEFIELD_X_2 : BATTLEFIELD_X_1
        coord_y := BATTLEFIELD_Y[curr_pos_y]
    }
    else if(curr_pos_y == 5) {
        if(curr_pos_x == 0 && curr_pos_y == 5 && listener_btns_move == BTN_LEFT) {
            curr_pos_x := 1
            curr_pos_y := 7
            coord_x := OBJECTS_X_1
            coord_y := OBJECTS_Y[1]
        }

        else {
            curr_len := 9
			curr_pos_x := curr_pos_x >= curr_len + 1 ? 1 : listener_btns_move == BTN_DOWN ? curr_pos_x + 1 : !curr_pos_x ? curr_len : curr_pos_x
            coord_x := BENCH_X
            coord_y := BENCH_Y
        }
    }
    else if(curr_pos_y == 6) {
        curr_len := 5
        curr_pos_x := listener_btns_move == BTN_DOWN || listener_btns_move == BTN_UP ? 3 : curr_pos_x == curr_len + 1 ? 1 : !curr_pos_x ? curr_len : curr_pos_x
        coord_x := SHOP_X
        coord_y := SHOP_Y
    }
    else if(curr_pos_y <= 12) {
        switch curr_pos_y {
            case 12:
                curr_len := 2
                coord_x := OBJECTS_X_6
            case 11:
                curr_len := 3
                coord_x := OBJECTS_X_5
            case 10:
                curr_len := 2
                coord_x := OBJECTS_X_4
            case 9:
                curr_len := 1
                coord_x := OBJECTS_X_3
            case 8:
                    curr_len := 1
                    coord_x := OBJECTS_X_2
            case 7:
                exept := 1
                if(curr_pos_x == 2 && listener_btns_move == BTN_RIGHT) {
                    curr_pos_x := 1
                    curr_pos_y := 5
                    coord_x := BENCH_X
                    coord_y := BENCH_Y
                }
                else {
                    curr_len := 1
                    curr_pos_x := curr_pos_x == curr_len + 1 ? 1 : curr_len
                    coord_x := OBJECTS_X_1
                    coord_y := OBJECTS_Y[1]
                }
            default:
        }
        if(!exept) {
            curr_pos_x := curr_pos_x == curr_len + 1 ? 1 : !curr_pos_x ? curr_len : curr_pos_x
            coord_y := OBJECTS_Y[curr_pos_y - 6]
        }
        exept := 0
    }
    else if(curr_pos_y > 12) {
		curr_pos_x := 1
		curr_pos_y := 7
		coord_x := OBJECTS_X_1
		coord_y := OBJECTS_Y[1]
    }

    ; do the movement
    if(listener_btns_move != -1) {
        MouseMove coord_x[curr_pos_x], coord_y, SPEED
    }

    ; End the program
    if(GetKeyState("Escape") && GetKeyState("Ctrl"))
        program_launched := 0
	
    Sleep 10
	
	; Useful debug ToolTips
	;ToolTip curr_btn "," WB "," LT "," RT "," LX "," LY "," RX "," RY "`n joy_x: " joy_x "`n joy_y: " joy_y
	;ToolTip "coord_x[curr_pos_x]: " coord_x[curr_pos_x] "`ncoord_y: " coord_y "`ncurr_pos_x: " curr_pos_x "`ncurr_pos_y: " curr_pos_y "`ncurr_len: " curr_len
    
}

; Functions
;
; DoublePress is only used for custom button combos
; Custom key Combos disabled. Refer to description at top.
;
;DoublePress(val1, val2, ret) {
;    res := GetKeyState(val1, "P") ? 1 : GetKeyState(val2, "P") ? 2 : -1
;    if(res != -1) {
;        Sleep 25
;        switch res {
;            case 1: key := GetKeyState(val2) ? ret : -1
;            case 2: key := GetKeyState(val1) ? ret : -1
;        }
;        return key
;    }
;    return -1
;}

#DllLoad XInput1_4.dll
XInputState(UserIndex) {
    xiState := Buffer(16)
    if err := DllCall("XInput1_4\XInputGetState", "uint", UserIndex, "ptr", xiState) {
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