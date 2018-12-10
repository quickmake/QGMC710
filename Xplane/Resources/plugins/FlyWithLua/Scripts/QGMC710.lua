require "bit"
--*****************************************************--
-- Driver for QGMC710 for Epic E1000
-- QuickMake mail:409050332@qq.com
--Build:2018-12-10

--Thanks to https://github.com/cpuwolf

-- Send 2 bytes
-- B7  B6  B5 B4   B3   B2   B1 B0        B7 B6  B5   B4   B3   B2   B1  B0
-- BL  FLC VS YD XFR_R BANK NAV HDG       X  X	 VNV  ALT  AP  XFR_L BC  APR
--BL:backlight  1 =PC control ; 0=Manual control
--When BL=1 , NEXT byte  B7 B6   is the  bright value  0-3

--**********************Copyright***********************--


----------------------  Edit the  DataRef for different Aircraft -----------------------
--EPIC E1000
if PLANE_ICAO == "EPIC" then
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
--TBM 900
elseif PLANE_ICAO == "TBM9" then
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

    --send data
    if (sendbytes[1] ~= sendbytes_old[1] or sendbytes[2] ~= sendbytes_old[2]) then
        hid_write(device, 0, sendbytes[1], sendbytes[2])
        sendbytes_old[1] = sendbytes[1]
        sendbytes_old[2] = sendbytes[2]
    end
end

do_every_frame("LED_UPD()")

