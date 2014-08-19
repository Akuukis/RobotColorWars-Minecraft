--[[------------ Descriptions of function calls -------------------------------
	Go( [ { x, z, y [,f] } ], [isRelative], [,style]).
		EXAMPLE: Lets say we are at coordinates X=2, Z=-3, Y=4 and if we want to go to X=0,Z=0,Y=0 then all the following will do.
			Nav.Go()
			Nav.Go({0,0,0})
			Nav.Go({0,0,0,1})
			Nav.Go({0,0,0},false,"Normal")
			Nav.Go({-2,3,-4},true,"Normal")
			pos = {x=0, z=0, y=0}; Nav.Go(pos)
		INPUT:
			table { num x, num z, num y [,num f]} : target position and face. If table is nil then default is current position and undefined face. Returns nil if X or Z or Y is nil. F are:
				0: North/X+
				1: East/Z+
				2: South/X-
				3: West/Z-
				else Undefined
			num isRelative : defines if coords are given in absolute or relative. 
				Nil|false|0: Absolute
				true|1: Relative
				2+: Relative to facing direction
			string style : defines different styles how to move around, mostly pathfinding function.
				Default: use "Normal"
				"Normal": combination of "Careful" and "DigCareful" - prefers not to dig but digs if very needed. Recommended for most purposes.
				"Careful": move carefully (recalculate path if block is in a way, doesn't destroy blocks), good for moving inside a base, but inefficient.
				"Dig": move and destroy blocks if one is in a way except if tagged "Use with caution, may destroy other turtles! Use "DigCareful"
				"DigCareful": like "Dig" but returns if there is a robot in 2sq in front.
				"Explore": move carefully AND check sides if they are unexplored. Good for mapping, but slow.
				"SurfaceExplore": like "Exlore" but ignores Y coordinate and moves on surface, ignoring openings 3+sq deep and 1-2sq wide.
				else use Default
		OUTPUT: 
			Returns true if succeeded, false if not.
	Nav.turnRight()
		INPUT: nothing
		OUTPUT: nothing
	Nav.turnLeft()
		INPUT: nothing
		OUTPUT: nothing
	Nav.TurnAround()
		INPUT: nothing
		OUTPUT: nothing
	Nav:getPos([string switchXZYF])
		INPUT: 
			string switchXZYF: any of the following values "x", "X", "z", "Z", "y", "Y", "f", "F"
		OUTPUT: 
			Default: table {x, z, y, f}, where XZY is absolute coordinates and f is facing direction (0 to 3)
			if switchXZYF: num returnXZYF, a numeric value depending on input string
--]]

local robot = require("robot")
local clsNav = {}
clsNav.title = "Navigation Library"
clsNav.shortTitle = "nav"
clsNav.version = 0.9000
function clsNav:new(oldObject)
  local object
  if oldObject
    and type(oldObject.title) == "string"
    and oldObject.title == self.title
    and type(oldObject.title) == "number"
    and oldObject.version <= self.version
  then
    object = oldObject
  else
    object = {}
  end
  setmetatable(object, self)
  self.__index = self
  return object
end

local logger = logger or false
if not logger then 
  logger = {
    fatal = function (...) io.write(string.format(...)) end,
    warning = function (...) io.write(string.format(...)) end,
    info = function (...) io.write(string.format(...)) end,
    spam = function (...) io.write(string.format(...)) end,
  }
end

---------------- Library wide variables ---------------------------------------

--[[ 
# MC logic
Coords... North: z--, East: x++, South: z++, West: x--, Up: y++, Down: y--
Coords... X points East, Z points South, Y points Up
Facing... 0: South, 1: West, 2: North, 3: East
Facing... Starts at South, goes clockwise
# Nav logic
Coords... North: x++, East: y++, South: x--, West: y--, Up: z++, Down: z--
Coords... X points North, Y points East, Z points Up
Facing... 0: North, 1: East, 2: South, 4: West
Facing... Starts at North, goes clockwise

use getNavFromMC() or getMCfromNav() to switch if needed, returns table
--]]

clsNav.pos = {
	x = 0, -- North
	z = 0, -- East
	y = 0, -- Height
	f = 0, -- Facing direction, modulus of 4 // 0,1,2,3 = North, East, South, West
}
clsNav.map = { -- id={nil=unexplored,false=air,0=RandomBlock,####=Block}, updated=server's time, tag={nil,true if tagged by special events}, Owner="".
  initialized = os.time(),
	updated = os.time(),
}

---------------- Methods ------------------------------------------------------

function clsNav:checkPos(unknown)
  if type(unknown) ~= "table" then return false end
  if
    type(unknown.x) == "number"
    and type(unknown.y) == "number"
    and type(unknown.z) == "number"
  then
    return {x = unknown.x, y = unknown.y, z = unknown.z, f = unknown.f or unknown[4] or nil}
  elseif 
    type(unknown[1]) == "number"
    and type(unknown[2]) == "number"
    and type(unknown[3]) == "number"
  then
    return {x = unknown[1], y = unknown[2], z = unknown[3], f = unknown[4] or unknown.f or nil}
  end
  return false
end
function clsNav:checkPositions(unknown)
  if type(unknown) ~= "table" then return false end
	if self:checkPos(unknown) then unknown[#unknown+1] = self:checkPos(unknown) end
  local index = 1
  local positions = {}
  for k,v in pairs(unknown) do
    local pos = self:checkPos(v)
    if pos then
      positions[index] = pos
      index = index + 1
    end
  end
  if index > 1 then
    return positions
  else
    return false
  end
end
function clsNav:getVersion()
	return self.version
	end

-- Technical and independent functions
function clsNav:putMap(pos, name, value) -- TODO: restructure to chunk tables
  pos = self:getPos(pos)
  if not pos then return false end
  
	self.map.updated = os.time()
	if self.map[pos.x] == nil then 
    self.map[pos.x] = {}
  end
	if self.map[pos.x][pos.y] == nil then
    self.map[pos.x][pos.y] = {}
  end
	if self.map[pos.x][pos.y][pos.z] == nil then
    self.map[pos.x][pos.y][pos.z] = {}
  end
	self.map[pos.x][pos.y][pos.z].updated = self.map.updated
	self.map[pos.x][pos.y][pos.z][name] = value
	return true
end
function clsNav:updatePos(pos_or_face)
  logger.spam("Nav.UpdateCoord(%s)\n",pos_or_face)
  pos = self:checkPos(pos_or_face) 
  if pos then
    self.pos = pos
  else
    self.pos = self:getPos(pos_or_face)
  end
end
function clsNav:comparePos(poslist1,poslist2,isFaced) -- input either pos or tables of pos
  poslist1 = self:checkPositions(poslist1)
  if not next(poslist1) then return false, 123, "comparePos: No legal pos in argument #1" end
  poslist2 = self:checkPositions(poslist2)
  if not next(poslist2) then return false, 123, "comparePos: No legal pos in argument #2" end
  
	for i,pos1 in pairs(poslist1) do
		--logger.spam("Pos1(%s): %s,%s,%s,%s\n", i, Pos1.x, Pos1.z, Pos1.y, Pos1.f)
    for j,pos2 in pairs(poslist2) do
      --logger.spam("  Pos2(%s): %s,%s,%s,%s\n", j, Pos2.x, Pos2.z, Pos2.y, Pos2.f)
      if 
        pos1.x == pos2.x
        and pos1.z == pos2.z
        and pos1.y == pos2.y
      then 
        if
          (isFaced
          and pos1.f
          and pos2.f
          and pos1.f == pos2.f)
          or 
          (not isFaced)
        then
          return pos1, pos2
        end
      end
		end
  end
  
	return false
end
function clsNav:getPos(pos, face) -- Input Position (table), FacingDirection (num) in any order
  if type(face) == "nil" and type(pos) == "number" then
    face = pos%6
    pos = nil
	elseif type(face) == "number" then
    face = face%6
  else 
    face = nil 
  end
  pos = self:checkPos(pos or self.pos) 
  if not pos then return false, "Failed to lookup pos" end
  	
	if face == nil then return {["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z, ["f"] = pos.f} 
	elseif face == 0 then return {["x"] = pos.x+1, ["y"] = pos.y, ["z"] = pos.z, ["f"] = face}
	elseif face == 1 then return {["x"] = pos.x, ["y"] = pos.y+1, ["z"] = pos.z, ["f"] = face}
	elseif face == 2 then return {["x"] = pos.x-1, ["y"] = pos.y, ["z"] = pos.z, ["f"] = face}
	elseif face == 3 then return {["x"] = pos.x, ["y"] = pos.y-1, ["z"] = pos.z, ["f"] = face}
	elseif face == 4 then return {["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z+1, ["f"] = pos.f}
	elseif face == 5 then return {["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z-1, ["f"] = pos.f}
	end
	
	return false
end

-- Technical and dependent functions, 1st level
function clsNav:getMap(pos, field)
	--logger.spam("getMap(%s,%s,%s)\n", x,z,y)
  pos = self:getPos(pos)
  if not pos then return false end
  
	if self.map[pos.x] == nil then 
    self.map[pos.x]={} 
  end
	if self.map[pos.x][pos.z] == nil then 
    self.map[pos.x][pos.z]={}
  end
	if self.map[pos.x][pos.z][pos.y] == nil then
    self.map[pos.x][pos.z][pos.y]={}
  end
	
	if field == nil then 
		return self.map[pos.x][pos.z][pos.y] 
	else 
		return self.map[pos.x][pos.z][pos.y][field] 
	end
end
function clsNav:detectAround() -- TODO: add other detections, repair tagging
	--logger.Check("detectAround:%s,%s",location,value)
  if robot.detect() then
    self:putMap(self:getPos(self:getPos().f),"id",0)
  else 
    self:putMap(self:getPos(self:getPos().f),"id",false)
  end
  if robot.detectUp() then self:putMap(self:getPos(4),"id",0) else self:putMap(self:getPos(4),"id",false) end
  if robot.detectDown() then self:putMap(self:getPos(5),"id",0) else self:putMap(self:getPos(5),"id",false) end
end
function clsNav:getPath(targets, options)
	--[[
	This code (Aug, 2014) is written by Akuukis 
		who based on code (Sep 21, 2006) by Altair
			who ported and upgraded code of LMelior
	
	Map[][][] is a 3d infinite array (.id, .updated, .Evade)
	Pos.x is the player's current x or North
	Z is the player's current z or East
	Pos.y is the player's current y or Height (not yet implemented)
	target.x is the target x
	target.z is the target z
	target.y is the target y (not yet implemented)
	options is the preference (not yet implemented)

	Note. all the x and z are the x and z to be used in the table.
	By this I mean, if the table is 3 by 2, the x can be 1,2,3 and the z can be 1 or 2.
  
	path is a list with all the x and y coords of the nodes of the path to the target.
	OR nil if closedlist==nil
	-- Intro to A* - http://www.raywenderlich.com/4946/introduction-to-a-pathfinding
	-- Try it out! - http://zerowidth.com/2013/05/05/jump-point-search-explained.html
	--]]
	
	if type(options) ~= "table" then options = {options} end -- Filters legal options
  for k,v in pairs(options) do if type(v) ~= "string" then options[k] = nil end end
  targets = self:checkPositions(targets) -- Filters legal targets
  if (not targets) or (not next(targets)) then return false end
	logger.info("Got %s valid targets!\n", #targets)
	
	function calcHeuristic(pos, targets, options)
		-- Useful - http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
		averageCost = 1
    dx, dy, dz = 0, 0, 0
		option = "ManhattanTieBreaker"
		for n in pairs(options) do
			if options[n] == "Manhattan" or options[n] == "ManhattanTieBreaker" then option = options[n] end
		end
		local minCost = math.huge
		for n in pairs(targets) do
			local cost = 0
			if option == "Manhattan" then
				dx = math.abs(self:getPos(pos).x-self:getPos(targets[n]).x)
				dy = math.abs(self:getPos(pos).y-self:getPos(targets[n]).y)
				dz = math.abs(self:getPos(pos).z-self:getPos(targets[n]).z)
				cost = averageCost * (dx + dz + dy)
			elseif option == "ManhattanTieBreaker" then
				dx = math.abs(self:getPos(pos).x-self:getPos(targets[n]).x)
				dy = math.abs(self:getPos(pos).y-self:getPos(targets[n]).y)
				dz = math.abs(self:getPos(pos).z-self:getPos(targets[n]).z)
				cost = averageCost * (dx + dz + dy) * (1 + 1/1000)
			else return false -- error
			end
			--logger.Check("%s: %s,%s,%s,%s -> %s,%s,%s,%s = %s\n", n, pos.x, pos.z, pos.y, pos.f, targets[n].x, targets[n].z, targets[n].y, targets[n].f, cost, minCost) 
			if cost < minCost then minCost = cost end
		end
		return minCost
	end
		
	-- logger.spam("Nav.GetPath(%s,%s,%s)\n",target.x,target.z,target.y)

	local closedlist = {}		-- Initialize table to store checked gridsquares
	local openlist = {}			-- Initialize table to store possible moves
	openlist[1] = {}					-- Make starting point in list
	openlist[1].x = self:getPos().x
	openlist[1].y = self:getPos().y
	openlist[1].z = self:getPos().z
	openlist[1].distExactStart = 0
	openlist[1].distHeuristicTarget = calcHeuristic(self:getPos(), targets, options)
	openlist[1].distSum = openlist[1].distExactStart + openlist[1].distHeuristicTarget
	openlist[1].parent = 1
	local openk = 1					-- Openlist counter
	local closedk = 0				-- Closedlist counter
	local defaultWeight = 3 -- TODO!
	-- logger.Check("Openlist.x|y|z=%s,%s,%s\n",openlist[1].x,openlist[1].z,openlist[1].y)
  
	local option_moveStyle = "Normal"
	for n,v in pairs(options) do
		if v == "Normal" or v == "Careful" then option_moveStyle = v end
		-- ... other options
	end

	while openk > 0 and #closedlist < 128 do   -- Growing loop
		-- Find next node with the lowest distSum
		local lowestDS = openlist[openk].distSum		-- Take distSum of last node as etalon
		local basis = openk	-- Take last node as etalon
		for i = openk,1,-1 do -- Search backwards (Prefer newer nodes)
			if openlist[i].distSum < lowestDS then
				lowestDS = openlist[i].distSum
				basis = i
			end
		end
		closedk = closedk + 1
		closedlist[closedk] = openlist[basis]
		local curbase = closedlist[closedk]				 -- define current base from which to grow list
		--logger.spam("%s/%s:(%s,%s,%s)(%s,%s,%s|%s)\n", closedk, openk, curbase.x, curbase.z, curbase.y, math.floor(curbase.distExactStart), math.floor(curbase.distHeuristicTarget), math.floor(curbase.distSum), curbase.parent)
		--for i,v in pairs(closedlist) do 
		--	logger.spam("%s:x=%s,y=%s,z=%s,p=%s,DE=%s,DH=%s,DS=%s\n", i, v.x, v.y, v.z, v.parent, v.distExactStart, math.floor(v.distHeuristicTarget), math.floor(v.distSum))
		--end
		--logger.Check("")
		table.remove(openlist,basis) -- This function deletes an element of a numerical table and moves up the remaining indices if necessary.
		openk = openk - 1
		
		local ok = {}
		for face=0,5 do ok[face] = 1 end  

		if option_moveStyle == "Normal" then		-- If it IS on the map, check map for obstacles
			for face=0,5 do if self:getMap(self:getPos(curbase,face),"id") then ok[face] = defaultWeight end end
		elseif option_moveStyle == "Careful" then
			for face=0,5 do if self:getMap(self:getPos(curbase,face),"id") then ok[face] = false end end
		end
		
		for face=0,5 do if self:getMap(self:getPos(curbase,face),"tag") == true then ok[face] = false end end	-- Look through Tagged
		
		--logger.spam("Closedlist:\n")
		if closedk>0 then		-- Look through closedlist
			for i=1,closedk do
				for face=0,5 do 
					--logger.spam("%s,%s,%s,%s =? %s,%s,%s,%s",self:getPos(closedlist[i]).x,self:getPos(closedlist[i]).z,self:getPos(closedlist[i]).y,self:getPos(closedlist[i]).f,self:getPos(curbase,face).x,self:getPos(curbase,face).y,self:getPos(curbase,face).z,self:getPos(curbase,face).f)
					if self:comparePos(self:getPos(closedlist[i]),self:getPos(curbase,face),false) then ok[face] = false; --[[logger.spam("CL! ")--]] end 
					--logger.spam("\n")
				end
				--logger.Check("")
			end
		end

		--logger.spam("Openlist:\n")
		for i=1,openk do		-- Look through openlist, check if the move from the current base is shorter than from the former parent
			--logger.spam("Openlist(%s/%s): %s,%s,%s,%s\n", i, openk, openlist[i].x, openlist[i].z, openlist[i].y, openlist[i].f)
			for face=0,5 do
				--logger.spam("%s/5: %s,%s,%s,%s. %s -> ",face,self:getPos(curbase,face).x,self:getPos(curbase,face).z,self:getPos(curbase,face).y,self:getPos(curbase,face).f,ok[face])
				if ok[face] and self:comparePos(openlist[i],self:getPos(curbase,face),false) then
					if openlist[i].distExactStart < curbase.distExactStart + ok[face] then
						openlist[i].distExactStart = curbase.distExactStart + ok[face]
						openlist[i].distSum = openlist[i].distHeuristicTarget + openlist[i].distExactStart
						openlist[i].parent = closedk
					end
					ok[face] = false
				end
				--logger.spam("%s\n",ok[face])
			end
			--logger.Check("")
		end

		--logger.spam("ok[face]: ")
		--for face=0,5 do logger.spam("%s",ok[face]) end
		--logger.spam("\n")

		for face=0,5 do		-- Add points to openlist
			if ok[face] then
				openk = openk + 1
				openlist[openk] = {}
				openlist[openk].x = self:getPos(curbase,face).x
				openlist[openk].y = self:getPos(curbase,face).y
				openlist[openk].z = self:getPos(curbase,face).z
				openlist[openk].f = self:getPos(curbase,face).f
				openlist[openk].distExactStart = curbase.distExactStart + ok[face]
				openlist[openk].distHeuristicTarget = calcHeuristic(self:getPos(curbase,face), targets, options)
				openlist[openk].distSum = openlist[openk].distExactStart + openlist[openk].distHeuristicTarget
				openlist[openk].parent = closedk
				--logger.spam("F:%s:",face)
				--for n in pairs(openlist[openk]) do logger.spam("%s:%s,",n,openlist[openk][n]) end
				--logger.Check("\n")
			end
		end
		
		--logger.Check("Check finish!\n")
		if self:comparePos(curbase,targets,false) then
			logger.spam("Found the path at %sth (of %s) try!\n", closedk, openk)
			-- Change Closed list into a list of XZ coordinates starting with player
			local path = {} 
			local last = closedk
			local pathIndex = {}
			pathIndex[1] = closedk
			local i = 1 -- we will include starting position into a table, otherwise 1
			while pathIndex[i] > 1 do 
				i = i + 1
				pathIndex[i] = closedlist[pathIndex[i-1]].parent
			end
			logger.spam("Steps(x%s): ", i)
			for i=1,#pathIndex,1 do
				path[i] = {}
				path[i].x = closedlist[pathIndex[#pathIndex+1-i]].x
				path[i].y = closedlist[pathIndex[#pathIndex+1-i]].y 
				path[i].z = closedlist[pathIndex[#pathIndex+1-i]].z
				logger.spam("%s|%s|%s, ", path[i].x,path[i].y,path[i].z)
			end
			--logger.spam("\n")     

			--for i=1,#pathIndex do
			--	logger.spam("%s(%s,%s,%s)", i, path[i].x, path[i].z, path[i].y)
			--end
			
			closedlist=nil
			
			-- Change list of XZ coordinates into a list of directions 
			logger.spam("FacePath. ")
			local fpath = {}
			for i=1,#path-1,1 do
				if path[i+1].x > path[i].x then fpath[i]=0 end -- North
				if path[i+1].z > path[i].z then fpath[i]=1 end -- East
				if path[i+1].x < path[i].x then fpath[i]=2 end -- South
				if path[i+1].z < path[i].z then fpath[i]=3 end -- West
				if path[i+1].y > path[i].y then fpath[i]=4 end -- Up
				if path[i+1].y < path[i].y then fpath[i]=5 end -- Down
				logger.spam("%s, ", fpath[i])
			end
			logger.spam("\n")
			logger.spam("%s\n",fpath)
			return fpath, path, #path
		end
	end
	return false
end

-- Technical and dependent functions, sub-Core level
function clsNav:move(face, options) -- face={0=North|1=East|2=South|3=West|4=up|5=down}, returns true if succeeded

	logger.spam("0..")
	local option_moveStyle = "Normal" -- or "Careful" or "Blind" (Don't use Blind!)
	
	if type(options) ~= "table" then options = {options} end -- Filters legal options
  for k,v in pairs(options) do if type(v) ~= "string" then options[k] = nil end end
  
	for n,v in pairs(options) do
		if v == "Careful" or v == "Normal" or v == "Blind" then option_moveStyle = v end
		-- ... other options
	end
	
	--logger.spam("Nav.Move(%s,%s,%s)\n", face.f, face.id, options)
	--utils.refuel()
	self:turnTo(face)
	self:detectAround()
	
	if 
    option_moveStyle == "Blind" 
    or not (self:getMap(self:getPos(face)) and self:getMap(self:getPos(face)).tag)
  then
		if option_moveStyle == "Blind"
      or option_moveStyle == "Normal"
      or not self:getMap(self:getPos(face)).id
    then
			local success = false
			if face == 4 then 
				while robot.detectUp() do robot.swingUp(); sleep(0.5) end
				success = robot.up()
			elseif face == 5 then
				while robot.detectDown() do robot.swingDown(); sleep(0.5) end
			    success = robot.down()
			else 
				while robot.detect() do robot.swing(); sleep(0.5) end
				success = robot.forward()
			end
			if success then
				self:updatePos(face)
				self:detectAround()
				--logger.spam("Nav.Move() Return true\n")
				return true
			end
		end
	end
	return false
end

-- Core functions
function clsNav:turnRight()
	robot.turnRight()
	--logger.spam("Nav.turnRight() Nav.Pos.f. %s => ",self:getPos().f)
	self.pos.f = (self:getPos().f+1)%4
	--logger.spam("%s\n",self:getPos().f)
	self:detectAround()
	return true
end
function clsNav:turnLeft()
	robot.turnLeft()
	--logger.spam("Nav:turnLeft() Nav.Pos.f. %s => ",self:getPos().f)
	self.pos.f = (self:getPos().f+3)%4
	--logger.spam("%s\n",self:getPos().f)
	self:detectAround()
	return true
end
function clsNav:turnAround()
	if 1==math.floor(math.random(0,1)+0.5) then
		self:turnRight()
		self:turnRight()
	else
		self:turnLeft()
		self:turnLeft()
	end
	return true
end
function clsNav:go(targets, options) -- table target1 [, table target2 ...] text option1 [, text option2 ...]
	
	if type(options) ~= "table" then options = {options} end -- Filters legal options
  for k,v in pairs(options) do if type(v) ~= "string" then options[k] = nil end end
  targets = self:checkPositions(targets) -- Filters legal targets
  if (not targets) or (not next(targets)) then return false end
	logger.info("Got %s valid targets!\n", #targets)
	
	local OptionRefStyle = "Absolute"
	for i,option in ipairs(options) do if option == "RelCoords" or option == "RelPos" then OptionRefStyle = option end end
	if OptionRefStyle == "RelCoords" then
		for j in ipairs(targets) do
			targets[j].x = targets[j].x + self:getPos().x
			targets[j].y = targets[j].y + self:getPos().y
			targets[j].z = targets[j].z + self:getPos().z
		end
	end
	if OptionRefStyle == "RelPos" then
		for j in ipairs(targets) do
			targets[j].x = targets[j].x + self:getPos().x
			targets[j].y = targets[j].y + self:getPos().y
			targets[j].z = targets[j].z + self:getPos().z
			if self:getPos().f == 0 then targets[j].x = self:getPos().x + targets[j].x; targets[j].y = self:getPos().y + targets[j].y end
			if self:getPos().f == 1 then targets[j].x = self:getPos().x - targets[j].y; targets[j].y = self:getPos().y + targets[j].x end
			if self:getPos().f == 2 then targets[j].x = self:getPos().x - targets[j].x; targets[j].y = self:getPos().y - targets[j].y end
			if self:getPos().f == 3 then targets[j].x = self:getPos().x + targets[j].y; targets[j].y = self:getPos().y - targets[j].x end
		end
	end
	
	local tries=32 -- TODO
	--if #targets > 0 then logger.spam("Nav.Go(x%s)(%s,%s,%s)\n", #targets, targets[1].x, targets[1].z, targets[1].y) end
	repeat
		local _, destination = self:comparePos(self:getPos(),targets)
		if destination then
			self:turnTo( destination.f )
			return true 
		else 
			tries = tries - 1
		end
		-- logger.spam("Nav.Go() @ (%s,%s,%s,F%s)/%s\n",self:getPos().x,self:getPos().z,self:getPos().y,self:getPos().f,tries)
		local fpath = self:getPath(targets,options)
		if not fpath then -- TODO: Cannot find path!
			-- logger.spam("Nav.Go() FPath=nil!")
			self:detectAround()
			self:turnRight()
		else
			logger.spam("Start moving!")
			i = 1
			success = true
			while i <= #fpath and success do 
				-- logger.spam("%s",i)
				-- logger.spam("@(%s,%s,%s),(%s,%s) Moving %s/%s ...\n", self:getPos().x,self:getPos().z,self:getPos().y,not fpath[i],not self:getMap(self:getPos(fpath[i]),"id"),i,#fpath)
				success = self:move(fpath[i], options)
				i = i + 1
			end
		end
	until tries > 0
	-- logger.spam("Nav.Go() Out-of-UNTIL! /%s",tries)
	return false
end

-- Shortcut functions
function clsNav:turnTo (dir)
	if type(dir) ~= "number" then return false end 
  if type(dir) == "nil" or dir >= 4 then return true end
	if dir==self:getPos().f or dir==self:getPos().f+4 then return true
	elseif dir==self:getPos().f-1 or dir==self:getPos().f+3 then return self:turnLeft()
	elseif dir==self:getPos().f-2 or dir==self:getPos().f+2 then return self:turnAround()
	elseif dir==self:getPos().f-3 or dir==self:getPos().f+1 then return self:turnRight()
	end
end
function clsNav:step(options)
	return self:move(self:getPos().f,options)
end
function clsNav:stepUp(options)
	return self:move(4,options)
end
function clsNav:stepDown(options)
	return self:move(5,options)
end

function clsNav:goNextTo (center, options)
	local SixTargets = {}
	--logger.spam("Center: ")
	--for i,v in pairs(center) do logger.spam("'%s'=%s, ",i,v) end
	--logger.spam("SixTargets: %s\n",SixTargets)
	for i=0,5 do
		SixTargets[i+1] = self:getPos(center,i)
		--logger.spam("SixTargets: %s\n",SixTargets)
		--for j,v in pairs(self:getPos(center,i)) do logger.spam("'%s'=%s, ",j,v) end
		--for j,v in pairs(SixTargets[1]) do logger.spam("'%s'=%s, ",j,v) end
		--logger.spam("%s: %s,%s,%s,%s\n",SixTargets[i+1], SixTargets[i+1].x,SixTargets[i+1].z,SixTargets[i+1].y,SixTargets[i+1].f)
	end
	--logger.Check("")
	SixTargets[1].f = 2
	SixTargets[2].f = 3
	SixTargets[3].f = 0
	SixTargets[4].f = 1
	SixTargets[5].f = nil
	SixTargets[6].f = nil
	self:go( SixTargets[1], SixTargets[2], SixTargets[3], SixTargets[4], SixTargets[5], SixTargets[6], options )
end

---------------- Details & Notes ----------------------------------------------

--[[ Tutorials
General: http://www.lua.org/pil/contents.html
Varargs: http://lua-users.org/wiki/VarargTheSecondClassCitizen
Nav.comparePos({1,2,3},{1,2,3})
--]]
	
return clsNav