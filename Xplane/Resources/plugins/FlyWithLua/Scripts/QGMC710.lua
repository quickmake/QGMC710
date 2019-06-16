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

-------  Common Dataref -------------------------------
DataRef("cockpit_led", "sim/cockpit/electrical/cockpit_lights")

if PLANE_ICAO == "TBM9" then
	
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
elseif PLANE_ICAO == "C172" then

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
    dataref("HDG", "sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "writable")
    dataref("CRS1", "sim/cockpit/radios/nav1_obs_degm", "writable")
    dataref("CRS2", "sim/cockpit/radios/nav2_obs_degm", "writable")
    dataref("ALT", "sim/cockpit2/autopilot/altitude_dial_ft", "writable")
else
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
end

--How many spins per second  is considered FAST?
local FastTurnsPerSecond = 5

------------------------ End Edit-----------------------------------------------
--You shouldnt need to change anything below-----------------------------------

local device_gmc710 = hid_open(0x0483, 0x5650)
if device_gmc710 == nil then
	-- print("Oh, no,you not have a QGMC710 hardware!")
	XPLMSpeakString("Oh, no! You not have a QGMC!")
    return
else
	--XPLMSpeakString("QGMC710")
	hid_set_nonblocking(device_gmc710, 1)
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

    sendbytes[3] = led_br
    --switch back to manual control by default
    if (sendbytes[3] ~= sendbytes_old[3]) then
        sendbytes[1] = sendbytes[1] + 0x80
    end

	--send data
	if (sendbytes[1] ~= sendbytes_old[1] or sendbytes[2] ~= sendbytes_old[2] or sendbytes[3] ~= sendbytes_old[3]) then
		hid_write(device_gmc710, 0, sendbytes[1], sendbytes[2], sendbytes[3])
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
    HDG = HDG % 360
end

function HDG_Decrement()
	HDG, HDG_NumberDownTurns, HDG_NumberUpTurns = Rotary_Decrement(HDG, HDG_NumberDownTurns, HDG_NumberUpTurns, 10, 1)
    HDG = HDG % 360
end

function CRS1_Increment()
	CRS1, CRS1_NumberUpTurns, CRS1_NumberDownTurns = Rotary_Increment(CRS1, CRS1_NumberUpTurns, CRS1_NumberDownTurns, 10, 1)
    CRS1 = CRS1 % 360
end

function CRS1_Decrement()
	CRS1, CRS1_NumberDownTurns, CRS1_NumberUpTurns = Rotary_Decrement(CRS1, CRS1_NumberDownTurns, CRS1_NumberUpTurns, 10, 1)
    CRS1 = CRS1 % 360
end

function CRS2_Increment()
    CRS2, CRS2_NumberUpTurns, CRS2_NumberDownTurns = Rotary_Increment(CRS2, CRS2_NumberUpTurns, CRS2_NumberDownTurns, 10, 1)
    CRS2 = CRS2 % 360
end

function CRS2_Decrement()
    CRS2, CRS2_NumberDownTurns, CRS2_NumberUpTurns = Rotary_Decrement(CRS2, CRS2_NumberDownTurns, CRS2_NumberUpTurns, 10, 1)
    CRS2 = CRS2 % 360
end

function ALT_Increment()
	ALT, ALT_NumberUpTurns, ALT_NumberDownTurns = Rotary_Increment(ALT, ALT_NumberUpTurns, ALT_NumberDownTurns, 500, 100)
end

function ALT_Decrement()
	ALT, ALT_NumberDownTurns, ALT_NumberUpTurns = Rotary_Decrement(ALT, ALT_NumberDownTurns, ALT_NumberUpTurns, 500, 100)
end

create_command("FlyWithLua/QGMC710/HDG_INC", "HDG INC speed up.", "HDG_Increment()", "", "")
create_command("FlyWithLua/QGMC710/HDG_DEC", "HDG DEC speed up.", "HDG_Decrement()", "", "")
create_command("FlyWithLua/QGMC710/CRS1_INC", "CRS1 INC speed up.", "CRS1_Increment()", "", "")
create_command("FlyWithLua/QGMC710/CRS1_DEC", "CRS1 DEC speed up.", "CRS1_Decrement()", "", "")
create_command("FlyWithLua/QGMC710/CRS2_INC", "CRS2 INC speed up.", "CRS2_Increment()", "", "")
create_command("FlyWithLua/QGMC710/CRS2_DEC", "CRS2 DEC speed up.", "CRS2_Decrement()", "", "")
create_command("FlyWithLua/QGMC710/ALT_INC", "ALT INC speed up.", "ALT_Increment()", "", "")
create_command("FlyWithLua/QGMC710/ALT_DEC", "ALT DEC speed up.", "ALT_Decrement()", "", "")


do_every_frame("LED_UPD()")


if PLANE_ICAO == "TBM9" then
        --#####################################################################
    local QMCP_ADDR = 1280 -- Address of QMCP737C key
    -- read/write func
    function save_qgmc710()
        local f = io.open(SCRIPT_DIRECTORY .. 'QGMC710_TBM9.txt', 'w')
        f:write(QMCP_ADDR, '\n')
        f:close()
    end
    function default_qgmc710()
        QMCP_ADDR = 1280
        save_qgmc710()
    end
    function read_qgmc710()
        local f = io.open(SCRIPT_DIRECTORY .. 'QGMC710_TBM9.txt', 'r')
        if f then
            QMCP_ADDR = f:read('*n')
            f:close()
            if QMCP_ADDR == nil then
                default_qgmc710()
            else
                if type(QMCP_ADDR) ~= 'number' then
                    default_qgmc710()
                end
            end
        else
            default_qgmc710()
        end
    end
    -- read/write func
    
    --KeyResetTool GUI INIT
    if not SUPPORTS_FLOATING_WINDOWS then
        -- to make sure the script doesn't stop old FlyWithLua versions
        logMsg('imgui not supported by your FlyWithLua version')
        return
    end
    local button_sniffer_active = false
    local btn_num = 0
    local btn_message = 'Deactive'
    local keys_set_ok = flase
    local setkey = false
    
    -- readconfig
    read_qgmc710()
    
    function ibd_on_build(ibd_wnd, x, y)
        imgui.SetCursorPosX(80)
        imgui.TextUnformatted('Warning: This will overwrite your current keys Assignments,-')
        imgui.SetCursorPosX(80)
        imgui.TextUnformatted("you'd better create a new profile")
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(180)
        imgui.TextUnformatted('Step 1: Click button starting find key')
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(200)
        if imgui.Button('Starting Find Key', 150, 40) then
            button_sniffer_active = true
            btn_message = "Waiting 'AP' Key Press "
            --turn on  the AP button Indicator light
            hid_write(device_gmc710, 0, 0x80, 0x08, 0x01)
        end
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(180)
        imgui.TextUnformatted("Step 2:Press the 'AP' key on QGMC710. ")
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(180)
        imgui.TextUnformatted(btn_message)
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(80)
        imgui.TextUnformatted('Step 3:Starting Reset Keys (Current keys assigmengs will be overwrite.)')
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(200)

        if imgui.Button('Reset QGMC710 Keys', 150, 40) then
            if QMCP_ADDR ~= nil and QMCP_ADDR ~= 0 then --not a key base address do nothing
                ------- save config file ------
                save_qgmc710()
                -----------------------------------  Set Keys  ---------------------------------------------------------
                -- Button assignment for hotstart TBM-900
                -- Start from 0 , need add 1 for the QGMC710 keys document.
                --******************************MCP Buttons*********************************
                set_button_assignment(QMCP_ADDR + 0, "tbm900/actuators/ap/hdg")
                set_button_assignment(QMCP_ADDR + 1, "tbm900/actuators/ap/apr")
                set_button_assignment(QMCP_ADDR + 2, "tbm900/actuators/ap/nav")
                set_button_assignment(QMCP_ADDR + 3, "tbm900/actuators/ap/fd")
                set_button_assignment(QMCP_ADDR + 4, "tbm900/actuators/ap/xfr")
                set_button_assignment(QMCP_ADDR + 5, "tbm900/actuators/ap/alt")
                set_button_assignment(QMCP_ADDR + 6, "tbm900/actuators/ap/vs")
                set_button_assignment(QMCP_ADDR + 7, "tbm900/actuators/ap/flc")
                set_button_assignment(QMCP_ADDR + 8, "tbm900/actuators/ap/bc")
                set_button_assignment(QMCP_ADDR + 9, "tbm900/actuators/ap/bank")
                set_button_assignment(QMCP_ADDR + 10, "tbm900/actuators/ap/ap")
                set_button_assignment(QMCP_ADDR + 11, "tbm900/actuators/ap/yd")
                set_button_assignment(QMCP_ADDR + 12, "tbm900/actuators/ap/vnv")
                set_button_assignment(QMCP_ADDR + 13, "tbm900/actuators/ap/spd")
                set_button_assignment(QMCP_ADDR + 14, "tbm900/actuators/ap/hdg_sync")
                set_button_assignment(QMCP_ADDR + 15, "tbm900/actuators/ap/crs1_dr")
                set_button_assignment(QMCP_ADDR + 16, "sim/GPS/g1000n3_hdg_sync")
                set_button_assignment(QMCP_ADDR + 17, "tbm900/actuators/ap/crs2_dr")
                set_button_assignment(QMCP_ADDR + 18, "FlyWithLua/QGMC710/HDG_DEC")
                set_button_assignment(QMCP_ADDR + 19, "FlyWithLua/QGMC710/HDG_INC")
                set_button_assignment(QMCP_ADDR + 20, "FlyWithLua/QGMC710/CRS1_DEC")
                set_button_assignment(QMCP_ADDR + 21, "FlyWithLua/QGMC710/CRS1_INC")
                set_button_assignment(QMCP_ADDR + 22, "FlyWithLua/QGMC710/ALT_DEC")
                set_button_assignment(QMCP_ADDR + 23, "FlyWithLua/QGMC710/ALT_INC")
                set_button_assignment(QMCP_ADDR + 24, "tbm900/actuators/ap/nose_down")
                set_button_assignment(QMCP_ADDR + 25, "tbm900/actuators/ap/nose_up")
                set_button_assignment(QMCP_ADDR + 26, "FlyWithLua/QGMC710/CRS2_DEC")
                set_button_assignment(QMCP_ADDR + 27, "FlyWithLua/QGMC710/CRS2_INC")
                ---------------------------------------------- Set Keys End -----------------------------------
                keys_set_ok = true
            end
        end
        imgui.TextUnformatted('')
        imgui.SetCursorPosX(80)
        if keys_set_ok then
            imgui.TextUnformatted('Reset OK ,Reload FlywithLUA')
        end
    end

    local ibd_wnd = nil
    function ibd_show_wnd()
        ibd_wnd = float_wnd_create(640, 480, 1, true)
        float_wnd_set_title(ibd_wnd, 'QGMC710 Keys Reset Tool v1.0')
        float_wnd_set_imgui_builder(ibd_wnd, 'ibd_on_build')
        float_wnd_set_onclose(ibd_wnd, 'ibd_hide_wnd')
    end

    function ibd_hide_wnd()
        if ibd_wnd then
            float_wnd_destroy(ibd_wnd)
        end
    end

    local ibd_show_only_once = 0
    local ibd_hide_only_once = 0

    function toggle_imgui_button_demo()
        ibd_show_window = not ibd_show_window
        if ibd_show_window then
            if ibd_show_only_once == 0 then
                ibd_show_wnd()
                ibd_show_only_once = 1
                ibd_hide_only_once = 0
            end
        else
            if ibd_hide_only_once == 0 then
                ibd_hide_wnd()
                ibd_hide_only_once = 1
                ibd_show_only_once = 0
            end
        end
    end
    --------------------------------    Update eyery frame   -------------------------------
    function win_frame_upd()
        --Reset button function
        if button_sniffer_active then
            for i = 0, 3199, 1 do
                if not last_button(i) and button(i) then
                    btn_num = i
                    if (btn_num - 10) % 160 == 0 then
                        btn_message = 'Address is ' .. btn_num - 10 .. '  Pressed. OK Next Step'
                        QMCP_ADDR = btn_num - 10
                        button_sniffer_active = false
                        -- turn off AP button Indicator light
                        hid_write(device_gmc710, 0, 0x80, 0x00, 0x00)
                        break
                    end
                end
            end
        end
    end
    --------------------------------------   Switch Set  --------------------------------
    add_macro('QGMC710 Keys Reset Tool', 'ibd_show_wnd()')
    do_every_frame('win_frame_upd()')
end