local jobs = {}

-------------------------------------------------------------------------------

jobs.jobs = {} -- Action that takes time to exchange one bunch of resources into another bunch of resources
jobs.farms = {} -- Capital (like rentable resources) that is placed and has a location. May be virtual (like digging fields)

-------------------------------------------------------------------------------

function jobs.getCapital( Name )
end
function jobs.getPrepare( Name )
end
function jobs.getInput( Name ) -- per worktime in min
end
function jobs.getOutput( Name ) -- per worktime in min
end
function jobs.getCollect( Name )
end
function jobs.getWorkTime( Name )
end
function jobs.getFreeTime( Name )
end
function jobs.getLocation( Name )
end

function jobs.mineH( Length, Width, isBaseLevel ) -- starts at first left buttom block

	if Length == "Help" or Length == "help" or Length == "Info" or Length == "info" then
		Logger.Info("Jobs.MineH(Length, Width, isBaseLevel)\n")
		Logger.Info("Slot[14] must have a chest\n")
		Logger.Info("If isBaseLevel is true then\n")
		Logger.Info("* Turtle will place floor\n")
		Logger.Info("* Slot[15] must have resource\n")
		Logger.Info("* Slot[16] must have torches\n")
		--Logger.Check("")
		return true
	end

	if Length == 0 or Length == nil then Length = 48 end
	if Width == 0 or Width == nil then Width = 6 end
	if type(isBaseLevel) ~= "boolean" then isBaseLevel = false end
	Offset = 0 -- if Offset == 0 or Offset == nil then Offset = 0 end 
	
	-- Torches are placed every 12 blocks like in diognal grid, on lines 6 & 12
	-- TODO Make an Offset based on Base Coords
	-- TODO Check for torches
	
	local StartPos = Nav.GetPos() -- TODO Repair
	-- local StartPos = Nav.GetPos()
	local RelPos = {}
	Logger.Info("StartPos: %s, %s, %s",StartPos.x,StartPos.z,StartPos.y)
	
	if isBaseLevel then
		local f = Nav.GetPos().f
		if f == 0 then RelPos.x =  Nav.GetPos().x; RelPos.z =  Nav.GetPos().z end -- North
		if f == 1 then RelPos.x = -Nav.GetPos().z; RelPos.z = -Nav.GetPos().x end -- East
		if f == 2 then RelPos.x = -Nav.GetPos().x; RelPos.z = -Nav.GetPos().z end -- South
		if f == 3 then RelPos.x =  Nav.GetPos().z; RelPos.z =  Nav.GetPos().x end -- West
		Logger.Info("%s, %s, %s\n",RelPos.x,RelPos.z,RelPos.y,f)
	else
		RelPos = nil
	end
	
	local function DigStep(Position,i)
		
		if isBaseLevel then 
			local TorchLine = 0
			local TempPos = {}
			local f = Nav.GetPos().f
			if f == 0 then TempPos.x =  Nav.GetPos().x; TempPos.z =  Nav.GetPos().z end -- North
			if f == 1 then TempPos.x = -Nav.GetPos().z; TempPos.z = -Nav.GetPos().x end -- East
			if f == 2 then TempPos.x = -Nav.GetPos().x; TempPos.z = -Nav.GetPos().z end -- South
			if f == 3 then TempPos.x =  Nav.GetPos().z; TempPos.z =  Nav.GetPos().x end -- West
			Logger.Info("%s, %s, %s\n",RelPos.x,RelPos.z,f)
			Logger.Info("%s, %s, %s\n",TempPos.x,TempPos.z,f)
			if (RelPos.z - TempPos.z) % 12 >= 6 then TorchLine = 0 else TorchLine = 6 end
			if (RelPos.x - TempPos.x) % 12 == TorchLine then -- we are on torch line
				-- TODO: i is out of range ...
				if i%2 == 0 then Nav.TurnRight() else Nav.TurnLeft() end 
				Nav.StepDown()
				while turtle.detect() do turtle.dig() end
				turtle.select(15)
				turtle.place()
				Nav.StepUp()
				while turtle.detect() do turtle.dig() end
				turtle.select(16)
				turtle.place()
				turtle.select(1)
				if i%2 == 0 then Nav.TurnLeft() else Nav.TurnRight() end 
				
				if (RelPos.z - TempPos.z) % 6 == 0 then -- we should leave a torch in our place
					Nav.StepDown()
					while turtle.detectDown() do turtle.digDown() end
					turtle.select(15)
					turtle.placeDown()
					Nav.StepUp()
					turtle.select(16)
					turtle.placeDown()
					turtle.select(1)
				end
			end
		end
		
		--while turtle.detect() do turtle.dig() end
		Nav.Go(Position)
		while turtle.detectUp() do turtle.digUp() end
		while turtle.detectDown() do turtle.digDown() end
		while turtle.detectUp() do turtle.digUp(); os.sleep(0.5) end
		return true
		
	end	
	local function UnloadToChest( _Limit )
		local Limit = _Limit or {}
		local constDirNames = {"north","east","south","west","up","down"}
		local constDirNamesReverse = {"south","west","north","east","down","up"}
		local Chest = peripheral.wrap("top") -- TODO: check if not valid inventory
		if type(Chest) ~= "table" then return false end -- not a chest
		local Side = nil
		local Slot = 1
		if Slot == 17 then return 0 end -- No items to move
		Logger.Info("Found Items at slot: %s\n", Slot)
		local ChestSlot = nil
		if type(Chest) ~= "table" then return Logger.Check("Nav Chest inside FOR!! :(\n") end -- not a chest
		os.sleep(0.1)
		local ChestInvSize = Chest.getInventorySize() 
		local j = 1
		Logger.Info("InvSize: %s\n", ChestInvSize)
		while turtle.getItemCount(Slot) == 0 or Slot == 17 do Slot = Slot + 1 end
		while j < ChestInvSize and not ChestSlot do
			Logger.Info("j: %s, ", j)
			Logger.Info("Stacks: %s\n", Chest.getStackInSlot(j))
			if not Chest.getStackInSlot(j) then ChestSlot = j end 
			j = j + 1
		end
		ChestSlot = ChestSlot or ChestInvSize
		Logger.Info("Chest has a free slot at No. %s\n", ChestSlot)
		for i = 1,6 do 		
			Logger.Info("Trying %s... ", constDirNames[i])
			if Chest.pullItem(constDirNames[i],Slot,1,ChestSlot) > 0 then Side = i; Logger.Info("Successful Pull!\n") else Logger.Info("Failed\n") end
			os.sleep(0.1)
			Chest.pushItem(constDirNames[i],ChestSlot,1,Slot)
			os.sleep(1)
			Logger.Info(" Side=%s\n", Side)
			if type(Side) == "number" then break end
		end	
		
		Logger.Info("Side outside: %s\n",Side)
		if Side == nil then return false end -- No valid side found, should never execute
		local Count = 0
		for i = 1,16 do
			Logger.Info("Pulling Item No.%s ... ", i)
			if Limit[i] == nil then Limit[i] = 0 end
			local Amount = turtle.getItemCount(i) - Limit[i]
			if Amount > 0 then
				os.sleep(0.1)
				local temp = Chest.pullItem(constDirNames[Side],i,Amount) 
				if temp == Amount then Count = Count + Amount; Logger.Info("moved %s, sum %s",Amount, Count) end
			end
			Logger.Info("\n")
		end
		return Count
	end
	
	local TempPos = {}
	for i=0,Width-1 do
		if type(TempPos) == "table" then Nav.Go(TempPos,"Normal") end
		local Start, Finish, Step
		if i%2 == 0 then Start = 0; Finish = Length-1; Step = 1 else Start = Length-1; Finish = 0; Step = -1 end
		Logger.Debug("i=%s, Remainder=%s, Start=%s, Finish=%s, Step=%s\n",i,i%2,Start,Finish,Step)
		--Logger.Check("")
		for j=Start,Finish,Step do			
			term.clear()
			term.setCursorPos(1,1)
			Logger.Info("Width = %s/%s, Length = %s/%s\n",i+1,Width,j+1,Length)
			Logger.Debug("Remainder of i/2 = %s\n",i%2)
			DigStep({j,i,0},i)
			if i == 0 and j == 0 then	-- Init
				turtle.select(14)
				turtle.placeUp()
				--sleep(0.5)
				local Limit = {}
				if isBaseLevel then	Limit[15] = 16; Limit[16] = 64 end
				Logger.Debug("kuku!")
				if not UnloadToChest(Limit) then Logger.Error("Not a chest!!!"); error() end -- TODO: Automatic problem solving
			end
		end
		
		if i%2 == 1 then -- TODO: Check if needed to go to chest
			Logger.Info("Need to unload...\n")
			TempPos = Nav.GetPos()
			TempPos.f = Nav.GetPos("f")
			Logger.Info("StartPos: %s, %s, %s",StartPos.x,StartPos.z,StartPos.y)
			Nav.Go(StartPos,"Careful") -- will fail last step cos cannot enter chest square. TODO improve
			local Limit = {}
			if isBaseLevel then Limit[15] = 16; Limit[16] = 64 end
			if not UnloadToChest(Limit) then Logger.Error("Not a chest!"); error() end -- TODO: Automatic problem solving
		else
			TempPos = nil
		end
		
	end
	
	--Nav.Go(StartPos,"Careful")
	Logger.Info("Finished!")
	
end

-------------------------------------------------------------------------------
---------------- Details & Notes ----------------------------------------------

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





