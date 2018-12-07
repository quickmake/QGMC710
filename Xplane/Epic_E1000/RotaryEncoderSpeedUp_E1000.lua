--*****************************************************--
-- Driver for QGMC710 for Epic E1000
--RotaryEncoder Speed Up Script
-- QuickMake mail:409050332@qq.com
--Build:2018-12-7

--******************************************************--

-------  Dataref -------------------------------
dataref("HDG", "sim/cockpit/autopilot/heading", "writable")
dataref("CRS1", "sim/cockpit/radios/nav1_obs_degm", "writable")
dataref("ALT", "sim/cockpit2/autopilot/altitude_dial_ft", "writable")

------------------------------------------------

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
create_command("FlyWithLua/QGMC710/ALT_INC", "ALT INC speed up.", "ALT_Increment()", "", "")
create_command("FlyWithLua/QGMC710/ALT_DEC", "ALT DEC speed up.", "ALT_Decrement()", "", "")
