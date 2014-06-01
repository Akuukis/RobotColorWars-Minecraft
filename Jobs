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

function MineH( lenght )

	for i=1,lenght do
		while turtle.detect() do turtle.dig() end
		Nav.Step()
		while turtle.detectUp() do turtle.digUp() end
		while turtle.detectDown() do turtle.digDown() end
	end
	Nav.TurnRight()
	while turtle.detect() do turtle.dig() end
	Nav.Step()
	while turtle.detectUp() do turtle.digUp() end
	while turtle.detectDown() do turtle.digDown() end
	Nav.TurnRight()
	while turtle.detect() do turtle.dig() end
	for i=1,lenght-1 do
		while turtle.detect() do turtle.dig() end
		Nav.Step()
		while turtle.detectUp() do turtle.digUp() end
		while turtle.detectDown() do turtle.digDown() end
	end
	Nav.Step()	
end
