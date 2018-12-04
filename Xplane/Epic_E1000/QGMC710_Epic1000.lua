require "bit"
--*****************************************************--
-- Driver for QGMC710 for Epic E1000
-- QuickMaker mail:409050332@qq.com
--Build:2018-12-4

-- Send 2 bytes
-- B7  B6  B5 B4  B3	B2	B1  B0         B7 B6  B5  B4   B3   B2   B1  B0
-- BL  FLC VS YD XFR_R BANK NAV HDG        X  X	 VNV  ALT  AP  XFR_L BC  APR
--BL:backlight  1 =PC control ; 0=Manual control
--When BL=1 , NEXT byte  B7 B6   is the  bright value  0-3

--**********************Copyright***********************--




----------------------  Edit the  DataRef for different Aircraft -----------------------

DataRef("flc_led", "sim/cockpit2/autopilot/speed_status")
DataRef("vs_led", "sim/cockpit2/autopilot/vvi_status")
DataRef("yd_led", "sim/cockpit/switches/yaw_damper_on")
--DataRef("xfr_r_led", "sim/cockpit2/autopilot/nav_status")
DataRef("bank_led", "sim/cockpit2/autopilot/heading_status")
DataRef("nav_led", "sim/cockpit2/autopilot/nav_status")
DataRef("hdg_led", "sim/cockpit2/autopilot/heading_status")

DataRef("vnv_led", "sim/cockpit2/autopilot/vnav_status")
DataRef("alt_led", "sim/cockpit2/autopilot/altitude_hold_status")
DataRef("ap_led", "sim/cockpit2/autopilot/servos_on")
--DataRef("xfr_l_led", "sim/cockpit2/autopilot/nav_status")
DataRef("bc_led", "sim/cockpit2/autopilot/backcourse_status")
DataRef("apr_led", "sim/cockpit2/autopilot/approach_status")

------------------------ End Edit-----------------------------------------------


device = hid_open(0x0483, 0x5650)
if device == nil then
    -- print("Oh, no,you not have a hardware!")
    XPLMSpeakString("Oh, no! You not have a hardware!")
else
    hid_set_nonblocking(device, 1)
    --XPLMSpeakString("QGMC710")
end


sendbytes = {0x00, 0x04}		--bytes will send
sendbytes_old = {0x00, 0x04} 	--bytes last send

function LED_UPD()
    if flc_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x40)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xBF)
    end
    if vs_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x20)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xDF)
    end
    if yd_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x10)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xEF)
    end
	if xfr_r_led_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x08)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xF7)
    end
	if bank_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x04)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xFB)
    end
    if nav_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x02)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xFD)
    end
	if hdg_led > 0 then
        sendbytes[1] = bit.bor(sendbytes[1], 0x01)
    else
        sendbytes[1] = bit.band(sendbytes[1], 0xFE)
    end



    if vnv_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x20)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xDF)
    end
    if alt_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x10)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xEF)
    end
    if ap_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x08)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xF7)
    end
	if xfr_l_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x04)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xFB)
    end
    if bc_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x02)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xFD)
    end
	if apr_led > 0 then
        sendbytes[2] = bit.bor(sendbytes[2], 0x01)
    else
        sendbytes[2] = bit.band(sendbytes[2], 0xFE)
    end

	--send data
    if (sendbytes[1] ~= sendbytes_old[1] or sendbytes[2] ~= sendbytes_old[2]) then
        hid_write(device, 0, sendbytes[1], sendbytes[2])
        sendbytes_old[1] = sendbytes[1]
        sendbytes_old[2] = sendbytes[2]
    end
end

do_every_frame("LED_UPD()")

