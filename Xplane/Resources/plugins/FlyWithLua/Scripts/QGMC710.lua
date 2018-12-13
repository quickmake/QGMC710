--require "bit"
--**********************************************************************************************************--
-- PC Driver for QGMC710
-- Author: QuickMake 
-- Email:  409050332@qq.com
-- Website: https://space.bilibili.com/323386663/
-- Build:  2018-12-6

-- Send 3 Bytes:
-- 1st Byte
---- B7  B6  B5 B4   B3   B2  B1  B0           
---- BL  FLC VS YD XFR_R BANK NAV HDG              
-- 2nd Byte
---- B7 B6  B5   B4   B3   B2  B1  B0
---- X  X  VNV  ALT  AP  XFR_L BC  APR
-- 3rd Byte
---- B7 B6 B5 B4 B3 B2 B1 B0
----  Brightness
--
-- Notes:
-- BL:backlight  1=PC control ; 0=Manual control
---- When BL=1 , 3rd byte is the brightness value  0-255

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
	dataref("CRS1", "tbm900/knobs/ap/crs1", "writable")
    dataref("CRS2", "tbm900/knobs/ap/crs2", "writable")
	dataref("ALT", "tbm900/knobs/ap/alt", "writable")
	------------------------------------------------
elseif PLANE_ICAO == "EPIC" then
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
    dataref("CRS2", "sim/cockpit/radios/nav2_obs_degm", "writable")
	dataref("ALT", "sim/cockpit2/autopilot/altitude_dial_ft", "writable")
	------------------------------------------------
else
    return
end

--How many spins per second  is considered FAST?
local FastTurnsPerSecond = 5

------------------------ End Edit-----------------------------------------------
--You shouldnt need to change anything below-----------------------------------

local device = hid_open(0x0483, 0x5650)
if device == nil then
	-- print("Oh, no,you not have a QGMC710 hardware!")
	XPLMSpeakString("Oh, no! You not have a hardware!")
    return
else
	--XPLMSpeakString("QGMC710")
	hid_set_nonblocking(device, 1)
end


local sendbytes_old = {0x00, 0x04, 0x00} --bytes last send


function LED_UPD()
    local sendbytes = {0x00, 0x00, 0x00} --bytes will send

	if flc_led > 0 then sendbytes[1] = sendbytes[1] + 0x40  end
	if vs_led > 0 then sendbytes[1] = sendbytes[1] + 0x20 end
	if yd_led > 0 then sendbytes[1] = sendbytes[1] + 0x10 end
	if xfr_r_led > 0 then sendbytes[1] = sendbytes[1] + 0x08 end
	if bank_led > 0 then sendbytes[1] = sendbytes[1] + 0x04 end
	if nav_led > 0 then sendbytes[1] = sendbytes[1] + 0x02 end
	if hdg_led > 0 then sendbytes[1] = sendbytes[1] + 0x01 end

	if vnv_led > 0 then sendbytes[2] = sendbytes[2] + 0x20 end 
	if alt_led > 0 then sendbytes[2] = sendbytes[2] + 0x10 end
	if ap_led > 0 then sendbytes[2] = sendbytes[2] + 0x08 end
	if xfr_l_led > 0 then sendbytes[2] = sendbytes[2] + 0x04 end
	if bc_led > 0 then sendbytes[2] = sendbytes[2] + 0x02 end
	if apr_led > 0 then sendbytes[2] = sendbytes[2] + 0x01 end

	local led_br = math.floor(cockpit_led *255.0)

    sendbytes[1] = sendbytes[1] + 0x80
    sendbytes[3] = led_br

	--send data
	if (sendbytes[1] ~= sendbytes_old[1] or sendbytes[2] ~= sendbytes_old[2] or sendbytes[3] ~= sendbytes_old[3]) then
		hid_write(device, 0, sendbytes[1], sendbytes[2], sendbytes[3])
		sendbytes_old[1] = sendbytes[1]
		sendbytes_old[2] = sendbytes[2]
        sendbytes_old[3] = sendbytes[3]
	end
end





--OBS1TurnTimes is used for both OBS1 and OBS2 to store times since each turn
local TurnTimes = {}
local HDG_NumberUpTurns = 1
local HDG_NumberDownTurns = 1
local CRS1_NumberUpTurns = 1
local CRS1_NumberDownTurns = 1
local CRS2_NumberUpTurns = 1
local CRS2_NumberDownTurns = 1
local ALT_NumberUpTurns = 1
local ALT_NumberDownTurns = 1

local i = 1

for i = 1, FastTurnsPerSecond do
	TurnTimes[i] = 1
end


function Rotary_Is_Fast(NumberUpTurns)
    local TimeNow = os.clock()
    TurnTimes[NumberUpTurns] = TimeNow

    local i = 1
    local ItsFast = 1

    for i = 1, FastTurnsPerSecond do
        if (TurnTimes[i] + 1 >= TimeNow) and (ItsFast == 1) then
            ItsFast = 1
        else
            ItsFast = 0
        end
    end

    NumberUpTurns = NumberUpTurns + 1
    if NumberUpTurns > FastTurnsPerSecond then
        NumberUpTurns = 1
    end
    return ItsFast, NumberUpTurns
end

function Rotary_Increment(coredata, NumberUpTurns, NumberDownTurns, FastStep, SlowStep)
    NumberDownTurns = 1
    local ItsFast = 1

    ItsFast, NumberUpTurns = Rotary_Is_Fast(NumberUpTurns)

    if ItsFast == 1 then
        coredata = coredata + FastStep
    else
        coredata = coredata + SlowStep
    end
    return coredata, NumberUpTurns, NumberDownTurns
end

function Rotary_Decrement(coredata, NumberDownTurns, NumberUpTurns, FastStep, SlowStep)
    HDG_NumberUpTurns = 1
    local ItsFast = 1
    
    ItsFast, NumberDownTurns = Rotary_Is_Fast(NumberDownTurns)

    if ItsFast == 1 then
        coredata = coredata - FastStep
    else
        coredata = coredata - SlowStep
    end
    return coredata, NumberDownTurns, NumberUpTurns
end

function HDG_Increment()
    HDG, HDG_NumberUpTurns, HDG_NumberDownTurns = Rotary_Increment(HDG, HDG_NumberUpTurns, HDG_NumberDownTurns, 10, 1)
end

function HDG_Decrement()
	HDG, HDG_NumberDownTurns, HDG_NumberUpTurns = Rotary_Decrement(HDG, HDG_NumberDownTurns, HDG_NumberUpTurns, 10, 1)
end

function CRS1_Increment()
	CRS1, CRS1_NumberUpTurns, CRS1_NumberDownTurns = Rotary_Increment(CRS1, CRS1_NumberUpTurns, CRS1_NumberDownTurns, 10, 1)
end

function CRS1_Decrement()
	CRS1, CRS1_NumberDownTurns, CRS1_NumberUpTurns = Rotary_Decrement(CRS1, CRS1_NumberDownTurns, CRS1_NumberUpTurns, 10, 1)
end

function CRS2_Increment()
    CRS2, CRS2_NumberUpTurns, CRS2_NumberDownTurns = Rotary_Increment(CRS2, CRS2_NumberUpTurns, CRS2_NumberDownTurns, 10, 1)
end

function CRS2_Decrement()
    CRS2, CRS2_NumberDownTurns, CRS2_NumberUpTurns = Rotary_Decrement(CRS2, CRS2_NumberDownTurns, CRS2_NumberUpTurns, 10, 1)
end

function ALT_Increment()
	ALT, ALT_NumberUpTurns, ALT_NumberDownTurns = Rotary_Increment(ALT, ALT_NumberUpTurns, ALT_NumberDownTurns, 500, 100)
end

function ALT_Decrement()
	ALT, ALT_NumberDownTurns, ALT_NumberUpTurns = Rotary_Decrement(ALT, ALT_NumberDownTurns, ALT_NumberUpTurns, 500, 100)
end

create_command("FlyWithLua/QGMC710/HDG_INC", "HDG INC speed up.", "HDG_Increment()", "", "HDG = HDG % 360 ")
create_command("FlyWithLua/QGMC710/HDG_DEC", "HDG DEC speed up.", "HDG_Decrement()", "", "HDG = HDG % 360 ")
create_command("FlyWithLua/QGMC710/CRS1_INC", "CRS1 INC speed up.", "CRS1_Increment()", "", "CRS1 = CRS1 % 360 ")
create_command("FlyWithLua/QGMC710/CRS1_DEC", "CRS1 DEC speed up.", "CRS1_Decrement()", "", "CRS1 = CRS1 % 360 ")
create_command("FlyWithLua/QGMC710/CRS2_INC", "CRS2 INC speed up.", "CRS2_Increment()", "", "CRS2 = CRS2 % 360 ")
create_command("FlyWithLua/QGMC710/CRS2_DEC", "CRS2 DEC speed up.", "CRS2_Decrement()", "", "CRS2 = CRS2 % 360 ")
create_command("FlyWithLua/QGMC710/ALT_INC", "ALT INC speed up.", "ALT_Increment()", "", "")
create_command("FlyWithLua/QGMC710/ALT_DEC", "ALT DEC speed up.", "ALT_Decrement()", "", "")


do_every_frame("LED_UPD()")

