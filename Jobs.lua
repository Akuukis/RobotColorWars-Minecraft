--[[ Concepts
TODO:""
--]]

--[[ JobList.Id =
function Execute
table Capital = [id = [avg, stdev], id = [avg, stdev], ....]
table Input = [id = [avg, stdev], id = [avg, stdev], ....]
table Output = [id = [avg, stdev], id = [avg, stdev], ....]
table WorkTime = [avg, stdev]
table IdleTime = [avg, stdev]
table Location = [x, z, y, f]
--]]

--[[ BaseList.Id =
table BuildJob = JobList
table DestroyJob = JobList
table Capital = [id = [avg, stdev], id = [avg, stdev], ....]
table Size = [x, z, y, f] -- f(back) is the open side
table NewFarms = table Farms
table Upgrades = table
--]]

--[[ FarmList.Id =
table BuildJob = JobList
table DestroyJob = JobList
table Capital = [id = [avg, stdev], id = [avg, stdev], ....]
table Size = [x, z, y, f] -- f(back) is the open side
table NewJobs = table Jobs -- upgrading part can be included in maintain Job or made separately
table Upgrades = table
--]]

--[[ Upgrades[x][y] =
x is independent lists of Upgrades (may be requirements on other list levels)
y is sequence of Jobs (levels of upgrade)
--]]

local JobList = {} -- Action that takes time to exchange one bunch of resources into another bunch of resources
local FarmList = {} -- Capital (like rentable resources) that is placed and has a location. May be virtual (like digging fields)



local function GetCapital( Name )
end
local function GetPrepare( Name )
end
local function GetInput( Name ) -- per worktime in min
end
local function GetOutput( Name ) -- per worktime in min
end
local function GetCollect( Name )
end
local function GetWorkTime( Name )
end
local function GetFreeTime( Name )
end
local function GetLocation( Name )
end

function MineH( Length, Width, isBaseLevel ) -- starts at first left buttom block

	if Length == "Help" or Length == "help" or Length == "Info" or Length == "info" then
		Logger.Info("Jobs.MineH(Length, Width, isBaseLevel)\n")
		Logger.Info("Slot[1] must have a chest\n")
		Logger.Info("If isBaseLevel is true then\n")
		Logger.Info("* Turtle will place floor\n")
		Logger.Info("* Slot[15] must have resource\n")
		Logger.Info("* Slot[16] must have torches\n")
		Logger.Check()
		return 1
	end

	if Length == 0 or Length == nil then Length = 48 end
	if Width == 0 or Width == nil then Width = 6 end
	if type(isBaseLevel) ~= "boolean" then isBaseLevel = false end
	Offset = 0 -- if Offset == 0 or Offset == nil then Offset = 0 end 
	
	-- Torches are placed every 12 blocks like in diognal grid, on lines 6 & 12
	-- TODO Make an Offset based on Base Coords
	-- TODO Check for torches
	

	local StartPos = Nav.GetPos()
	local RelPos = {}
	
	if isBaseLevel then
		local f = Nav.GetPos("f")
		if f = 0 then RelPos.x = +StartPos.x; RelPos.z = +StartPos.z end -- North
		if f = 1 then RelPos.x = -StartPos.z; RelPos.z = -StartPos.x end -- East
		if f = 2 then RelPos.x = -StartPos.x; RelPos.z = -StartPos.z end -- South
		if f = 3 then RelPos.x = +StartPos.z; RelPos.z = +StartPos.x end -- West
	else
		RelPos = nil
	end
	
	local function DigStep()
		while turtle.detect() do turtle.dig() end
		Nav.Step()
		while turtle.detectUp() do turtle.digUp() end
		while turtle.detectDown() do turtle.digDown() end
		while turtle.detectUp() do turtle.digUp(); os.sleep(1) end
		if isBaseLevel then 
			local TorchLine = 0
			if (Nav.GetPos("z") - RelPos) % 12 < 6 then TorchLine = 5 else TorchLine = 11 end
			if (Nav.GetPos("x") - RelPos) % 12 == TorchLine then
				--put torch
				--if (Nav.GetPos("z") - RelPos) % 6 < 5 then	end
			end
		end
	end
	
	local function UnloadToChest() end
	
	local TempPos = {}
	local isLeaveTorch
	for i=1,Width do
	
		if i = 1 then	-- Init
			while turtle.detectUp() do turtle.digUp() end
			while turtle.detectDown() do turtle.digDown() end
			while turtle.detectUp() do turtle.digUp(); os.sleep(1) end
			DigStep()
			Nav.TurnAround()
			turtle.select(1)
			turtle.place()
			-- TODO ChestMagic
		else -- Regular
			if TempPos then Nav.Go(TempPos) end
			Nav.TurnLeft()
			DigStep()
			Nav.TurnLeft()
			DigStep()
		end
		
		for j=1,Length-1 do	DigStep()	end
		
		Nav.TurnRight()
		DigStep()		
		Nav.TurnRight()
		DigStep()	
		
		for j=1,Length-1 do	DigStep()	end
		
		if true then -- TODO: Check if needed to go to chest
			TempPos = Nav.GetPos()
			TempPos.f = Nav.GetPos("f")
			UnloadToChest() -- TODO
		else
			TempPos = nil
		end
		
		
	end
	
end

