require "bit"
--*****************************************************--
-- Driver for QGMC710 for Epic E1000
-- QuickMake mail:409050332@qq.com
--Build:2018-12-6

-- Send 2 bytes
-- B7  B6  B5 B4   B3   B2   B1 B0        B7 B6  B5   B4   B3   B2   B1  B0
-- BL  FLC VS YD XFR_R BANK NAV HDG       X  X	 VNV  ALT  AP  XFR_L BC  APR
--BL:backlight  1 =PC control ; 0=Manual control
--When BL=1 , NEXT byte  B7 B6   is the  bright value  0-3

--**********************Copyright***********************--

-- modified by Wei Shuai <cpuwolf@gmail.com>

----------------------  Edit the  DataRef for different Aircraft -----------------------

if PLANE_ICAO == "TBM9" then
    DataRef("cockpit_led", "sim/cockpit/electrical/cockpit_lights")
    DataRef("flc_led", "tbm900/lights/ap/flc")
    DataRef("vs_led", "tbm900/lights/ap/vs")
    DataRef("yd_led", "tbm900/lights/ap/yd")
    DataRef("xfr_r_led", "tbm900/lights/ap/comp_right")
    DataRef("bank_led", "tbm900/lights/ap/bank")
    DataRef("nav_led", "tbm900/lights/ap/nav")
    DataRef("hdg_led", "tbm900/lights/ap/hdg")

    DataRef("vnv_led", "tbm900/lights/ap/vnv")
    DataRef("alt_led", "tbm900/lights/ap/alt")
    DataRef("ap_led", "tbm900/lights/ap/ap")
    DataRef("xfr_l_led", "tbm900/lights/ap/comp_left")
    DataRef("bc_led", "tbm900/lights/ap/bc")
    DataRef("apr_led", "tbm900/lights/ap/apr")

    -------  Dataref for rotary switches -----------
    dataref("HDG", "tbm900/knobs/ap/hdg", "writable")
    dataref("CRS1", "sim/cockpit/radios/nav1_obs_degm", "writable")
    dataref("ALT", "tbm900/knobs/ap/alt", "writable")
    ------------------------------------------------
else
    DataRef("cockpit_led", "sim/cockpit/electrical/cockpit_lights")
    DataRef("flc_led", "sim/cockpit2/autopilot/speed_status")
    DataRef("vs_led", "sim/cockpit2/autopilot/vvi_status")
    DataRef("yd_led", "sim/cockpit/switches/yaw_damper_on")
    DataRef("xfr_r_led", "sim/cockpit2/autopilot/nav_status")
    DataRef("bank_led", "sim/cockpit2/autopilot/heading_status")
    DataRef("nav_led", "sim/cockpit2/autopilot/nav_status")
    DataRef("hdg_led", "sim/cockpit2/autopilot/heading_status")

    DataRef("vnv_led", "sim/cockpit2/autopilot/vnav_status")
    DataRef("alt_led", "sim/cockpit2/autopilot/altitude_hold_status")
    DataRef("ap_led", "sim/cockpit2/autopilot/servos_on")
    DataRef("xfr_l_led", "sim/cockpit2/autopilot/nav_status")
    DataRef("bc_led", "sim/cockpit2/autopilot/backcourse_status")
    DataRef("apr_led", "sim/cockpit2/autopilot/approach_status")

    -------  Dataref -------------------------------
    dataref("HDG", "sim/cockpit/autopilot/heading", "writable")
    dataref("CRS1", "sim/cockpit/radios/nav1_obs_degm", "writable")
    dataref("ALT", "sim/cockpit2/autopilot/altitude_dial_ft", "writable")
    ------------------------------------------------
end
------------------------ End Edit-----------------------------------------------

device = hid_open(0x0483, 0x5650)
if device == nil then
    -- print("Oh, no,you not have a QGMC710 hardware!")
    XPLMSpeakString("Oh, no! You not have a hardware!")
else
    --XPLMSpeakString("QGMC710")
    hid_set_nonblocking(device, 1)
end

sendbytes = {0x00, 0x04} --bytes will send
sendbytes_old = {0x00, 0x04} --bytes last send


function LED_brightness()
    local led_br = math.floor(cockpit_led *3.0)

    sendbytes[1] = bit.bor(sendbytes[1], 0x80)
    local led_br_bits = bit.band(bit.lshift(led_br, 6), 0xC0)
    sendbytes[2] = bit.band(sendbytes[2], 0x3F)
    sendbytes[2] = bit.bor(sendbytes[2], led_br_bits)

end

function LED_UPD()
    sendbytes[1] = flc_led > 0 and bit.bor(sendbytes[1], 0x40) or bit.band(sendbytes[1], 0xBF)
    sendbytes[1] = vs_led > 0 and bit.bor(sendbytes[1], 0x20) or bit.band(sendbytes[1], 0xDF)
    sendbytes[1] = yd_led > 0 and bit.bor(sendbytes[1], 0x10) or bit.band(sendbytes[1], 0xEF)
    sendbytes[1] = xfr_r_led > 0 and bit.bor(sendbytes[1], 0x08) or bit.band(sendbytes[1], 0xF7)
    sendbytes[1] = bank_led > 0 and bit.bor(sendbytes[1], 0x04) or bit.band(sendbytes[1], 0xFB)
    sendbytes[1] = nav_led > 0 and bit.bor(sendbytes[1], 0x02) or bit.band(sendbytes[1], 0xFD)
    sendbytes[1] = hdg_led > 0 and bit.bor(sendbytes[1], 0x01) or bit.band(sendbytes[1], 0xFE)

    sendbytes[2] = vnv_led > 0 and bit.bor(sendbytes[2], 0x20) or bit.band(sendbytes[2], 0xDF)
    sendbytes[2] = alt_led > 0 and bit.bor(sendbytes[2], 0x10) or bit.band(sendbytes[2], 0xEF)
    sendbytes[2] = ap_led > 0 and bit.bor(sendbytes[2], 0x08) or bit.band(sendbytes[2], 0xF7)
    sendbytes[2] = xfr_l_led > 0 and bit.bor(sendbytes[2], 0x04) or bit.band(sendbytes[2], 0xFB)
    sendbytes[2] = bc_led > 0 and bit.bor(sendbytes[2], 0x02) or bit.band(sendbytes[2], 0xFD)
    sendbytes[2] = apr_led > 0 and bit.bor(sendbytes[2], 0x01) or bit.band(sendbytes[2], 0xFE)

    LED_brightness()

    --send data
    if (sendbytes[1] ~= sendbytes_old[1] or sendbytes[2] ~= sendbytes_old[2]) then
        hid_write(device, 0, sendbytes[1], sendbytes[2])
        sendbytes_old[1] = sendbytes[1]
        sendbytes_old[2] = sendbytes[2]
    end
end



--How many degrees should the value jump each time if your spinning fast?
FastDegrees = 8

--How many spins per second  is considered FAST?
FastTurnsPerSecond = 12

--How many setp per ALT is considered fast?
ALT_Fast_Step = 100

--You shouldnt need to change anything below-----------------------------------

--OBS1TurnTimes is used for both OBS1 and OBS2 to store times since each turn
TurnTimes = {}
HDG_NumberUpTurns = 1
HDG_NumberDownTurns = 1
CRS1_NumberUpTurns = 1
CRS1_NumberDownTurns = 1
ALT_NumberUpTurns = 1
ALT_NumberDownTurns = 1

local i = 1

for i = 1, FastTurnsPerSecond do
    TurnTimes[i] = 1
end

function HDG_Increment()
    HDG_NumberDownTurns = 1
    local TimeNow = os.clock()
    TurnTimes[HDG_NumberUpTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    HDG_NumberUpTurns = HDG_NumberUpTurns + 1
    if HDG_NumberUpTurns > FastTurnsPerSecond then
        HDG_NumberUpTurns = 1
    end

    if ItsFast == 1 then
        HDG = HDG + FastDegrees
    else
        HDG = HDG + 1
    end
end

function HDG_Decrement()
    HDG_NumberUpTurns = 1
    local TimeNow = os.clock()
    TurnTimes[HDG_NumberDownTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    HDG_NumberDownTurns = HDG_NumberDownTurns + 1
    if HDG_NumberDownTurns > FastTurnsPerSecond then
        HDG_NumberDownTurns = 1
    end

    if ItsFast == 1 then
        HDG = HDG - FastDegrees
    else
        HDG = HDG - 1
    end
end

function CRS1_Increment()
    CRS1_NumberDownTurns = 1
    local TimeNow = os.clock()
    TurnTimes[CRS1_NumberUpTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    CRS1_NumberUpTurns = CRS1_NumberUpTurns + 1
    if CRS1_NumberUpTurns > FastTurnsPerSecond then
        CRS1_NumberUpTurns = 1
    end

    if ItsFast == 1 then
        CRS1 = CRS1 + FastDegrees
    else
        CRS1 = CRS1 + 1
    end
end

function CRS1_Decrement()
    CRS1_NumberUpTurns = 1
    local TimeNow = os.clock()
    TurnTimes[CRS1_NumberDownTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    CRS1_NumberDownTurns = CRS1_NumberDownTurns + 1
    if CRS1_NumberDownTurns > FastTurnsPerSecond then
        CRS1_NumberDownTurns = 1
    end

    if ItsFast == 1 then
        CRS1 = CRS1 - FastDegrees
    else
        CRS1 = CRS1 - 1
    end
end

function ALT_Increment()
    ALT_NumberDownTurns = 1
    local TimeNow = os.clock()
    TurnTimes[ALT_NumberUpTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    ALT_NumberUpTurns = ALT_NumberUpTurns + 1
    if ALT_NumberUpTurns > FastTurnsPerSecond then
        ALT_NumberUpTurns = 1
    end

    if ItsFast == 1 then
        ALT = ALT + ALT_Fast_Step
    else
        ALT = ALT + 10
    end
end

function ALT_Decrement()
    ALT_NumberUpTurns = 1
    local TimeNow = os.clock()
    TurnTimes[ALT_NumberDownTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    ALT_NumberDownTurns = ALT_NumberDownTurns + 1
    if ALT_NumberDownTurns > FastTurnsPerSecond then
        ALT_NumberDownTurns = 1
    end

    if ItsFast == 1 then
        ALT = ALT - ALT_Fast_Step
    else
        ALT = ALT - 10
    end
end

create_command("FlyWithLua/QGMC710/HDG_INC", "HDG INC speed up.", "HDG_Increment()", "", "HDG = HDG % 360 ")
create_command("FlyWithLua/QGMC710/HDG_DEC", "HDG DEC speed up.", "HDG_Decrement()", "", "HDG = HDG % 360 ")
create_command("FlyWithLua/QGMC710/CRS1_INC", "CRS1 INC speed up.", "CRS1_Increment()", "", "CRS1 = CRS1 % 360 ")
create_command("FlyWithLua/QGMC710/CRS1_DEC", "CRS1 DEC speed up.", "CRS1_Decrement()", "", "CRS1 = CRS1 % 360 ")
create_command("FlyWithLua/QGMC710/ALT_INC", "ALT INC speed up.", "ALT_Increment()", "", "ALT = ALT % 360")
create_command("FlyWithLua/QGMC710/ALT_DEC", "ALT DEC speed up.", "ALT_Decrement()", "", "ALT = ALT % 360")


do_every_frame("LED_UPD()")

