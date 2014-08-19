--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
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
				"DigCareful": like "Dig" but returns if there is a turtle in 2sq in front.
				"Explore": move carefully AND check sides if they are unexplored. Good for mapping, but slow.
				"SurfaceExplore": like "Exlore" but ignores Y coordinate and moves on surface, ignoring openings 3+sq deep and 1-2sq wide.
				else use Default
		OUTPUT: 
			Returns true if succeeded, false if not.
	Nav.TurnRight()
		INPUT: nothing
		OUTPUT: nothing
	Nav.TurnLeft()
		INPUT: nothing
		OUTPUT: nothing
	Nav.TurnAround()
		INPUT: nothing
		OUTPUT: nothing
	Nav.GetPos([string switchXZYF])
		INPUT: 
			string switchXZYF: any of the following values "x", "X", "z", "Z", "y", "Y", "f", "F"
		OUTPUT: 
			Default: table {x, z, y, f}, where XZY is absolute coordinates and f is facing direction (0 to 3)
			if switchXZYF: num returnXZYF, a numeric value depending on input string
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
if type(Nav) == "table" then Lib = Nav end
Nav = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
local error, pairs, select, unpack = error, pairs, select, unpack
local os, table, math = os, table, math 

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): getfenv, getmetatable, loadfile, dofile, print, type, string.sub, string.find, write
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
local ipairs, sleep, type = ipairs, sleep, type
-- local
local turtle = turtle

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui, Hud, Logger, Stats, Comm, Utils = Gui, Rui, Hud, Logger, Stats, Comm, Utils 

-- no more external access after this point
setfenv(1, Lib)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

local OldPos = Pos
local Pos = OldPos or {}
if not OldPos then 
	Pos.x = 0 -- North
	Pos.z = 0 -- East
	Pos.y = 0 -- Height
	Pos.f = 0 -- Facing direction, modulus of 4 // 0,1,2,3 = North, East, South, West
end
local OldMap = Map
local Map = OldMap or {}
if not OldMap then
	local Map = {} -- Id={nil=unexplored,false=air,0=RandomBlock,####=Block}, Updated=server's time, Tag={nil,true if tagged by special events}, Owner="".
	Map.InitTime = os.time()
	Map.UpdatedTime = os.time()
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Functions ----------------------------------------------------------------------------------------------

-- Technical and independent functions
local PutMap = function(pos,name,value)
	-- local shout = os.difftime(os.time() - Map.UpdatedTime)
	Map.UpdatedTime = os.time()
	
	if Map[GetPos(pos).x] == nil then Map[GetPos(pos).x]={} end
	if Map[GetPos(pos).x][GetPos(pos).z] == nil then Map[GetPos(pos).x][GetPos(pos).z]={} end
	if Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y] == nil then Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y]={} end

	Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y]["Updated"] = Map.UpdatedTime
	Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y][name] = value
	return shout
end
local function UpdatePos (face)
--Logger.Debug("Nav.UpdateCoord(%s)\n",face)
	Pos.x = GetPos(face).x
	Pos.z = GetPos(face).z
	Pos.y = GetPos(face).y
end
local function Test ()
	return 1
	end
local function ComparePos (_tPos1,_tPos2,isFaced) -- input either pos or tables of pos
	if type(_tPos1) ~= "table" then error("expected TABLE") end
	if type(_tPos2) ~= "table" then error("expected TABLE") end
	local tPos1, tPos2 = {}, {}
	tPos1.Abc, tPos2.Abc = {}, {}
	for i,v in pairs(_tPos1) do 
		if type(v) == "table" then tPos1[i] = v end
		if type(v) == "number" then tPos1.Abc[i] = v end
	end
	for i,v in pairs(_tPos2) do 
		if type(v) == "table" then tPos2[i] = v end
		if type(v) == "number" then tPos2.Abc[i] = v end 
	end
	
	for i,Pos1 in pairs(tPos1) do
		--Logger.Debug("Pos1(%s): %s,%s,%s,%s\n", i, Pos1.x, Pos1.z, Pos1.y, Pos1.f)
		if type(Pos1) == "table" then
			for j,Pos2 in pairs(tPos2) do
				--Logger.Debug("  Pos2(%s): %s,%s,%s,%s\n", j, Pos2.x, Pos2.z, Pos2.y, Pos2.f)
				if type(Pos2) == "table" then
					local Identical = true
					Pos1.x = Pos1.x or Pos1[1] or nil
					Pos1.z = Pos1.z or Pos1[2] or nil
					Pos1.y = Pos1.y or Pos1[3] or nil
					Pos1.f = Pos1.f or Pos1[4] or nil
					Pos2.x = Pos2.x or Pos2[1] or nil
					Pos2.z = Pos2.z or Pos2[2] or nil
					Pos2.y = Pos2.y or Pos2[3] or nil
					Pos2.f = Pos2.f or Pos2[4] or nil
					if not (Pos1.x and Pos1.z and Pos1.y and Pos2.x and Pos2.z and Pos2.y) then Identical = false end 
					if Pos1.x ~= Pos2.x or Pos1.z ~= Pos2.z or Pos1.y ~= Pos2.y then Identical = false end
					if isFaced and Pos1.f and Pos2.f and Pos1.f ~= Pos2.f then Identical = false end
					if Identical == true then return Pos1, Pos2 end
				end
			end
		end
	end
	return false
end
function GetPos ( ... ) -- Input Position (table), FacingDirection (num) in any order
	local Face = nil
	local P = {}
	local Arg = {}
	P.x = Pos.x
	P.z = Pos.z
	P.y = Pos.y
	P.f = Pos.f
	
	for i=1,select('#',...) do
		Arg[i] = select(i,...)
	end
	
	for i=1,3,1 do
		if type(Arg[i]) == "number" then Face = Arg[i]
		elseif type(Arg[i]) == "table" then 
			P.x = Arg[i].x or Arg[i][1] or Pos.x or 0
			P.z = Arg[i].z or Arg[i][2] or Pos.z or 0
			P.y = Arg[i].y or Arg[i][3] or Pos.y or 0
			P.f = Arg[i].f or Arg[i][4] or Pos.f or 0
		end
	end
	
	if Face == nil then return {["x"] = P.x, ["z"] = P.z,["y"] = P.y, ["f"] = P.f} 
	elseif Face == 0 then return {["x"] = P.x+1, ["z"] = P.z,["y"] = P.y, ["f"] = Face}
	elseif Face == 1 then return {["x"] = P.x, ["z"] = P.z+1,["y"] = P.y, ["f"] = Face}
	elseif Face == 2 then return {["x"] = P.x-1, ["z"] = P.z,["y"] = P.y, ["f"] = Face}
	elseif Face == 3 then return {["x"] = P.x, ["z"] = P.z-1,["y"] = P.y, ["f"] = Face}
	elseif Face == 4 then return {["x"] = P.x, ["z"] = P.z,["y"] = P.y+1, ["f"] = P.f}
	elseif Face == 5 then return {["x"] = P.x, ["z"] = P.z,["y"] = P.y-1, ["f"] = P.f}
	else error()
	end
	
	return nil
end

-- Technical and dependent functions, 1st level
function GetMap (pos, name)
	--Logger.Debug("GetMap(%s,%s,%s)\n", x,z,y)
	if Map[GetPos(pos).x] == nil then Map[GetPos(pos).x]={} end
	if Map[GetPos(pos).x][GetPos(pos).z] == nil then Map[GetPos(pos).x][GetPos(pos).z]={} end
	if Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y] == nil then Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y]={} end
	
	if name == nil then 
		return Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y] 
	else 
		return Map[GetPos(pos).x][GetPos(pos).z][GetPos(pos).y][name] 
	end
end
function UpdateMap (location, value) -- location{nil|dir|XZY), value{false=air,0=unknown block,1+=known block}
	--Logger.Check("UpdateMap:%s,%s",location,value)
	if type(location) == "nil" or type(location) == "number" then
		if turtle.detect() then PutMap(GetPos(GetPos().f),"Id",0) else PutMap(GetPos(GetPos().f),"Id",false) end
		if turtle.detectUp() then PutMap(GetPos(4),"Id",0) else PutMap(GetPos(4),"Id",false) end
		if turtle.detectDown() then PutMap(GetPos(5),"Id",0) else PutMap(GetPos(5),"Id",false) end
	elseif type(location)=="table" then
		location.x = location.x or location[1]
		location.z = location.z or location[2]
		location.y = location.y or location[3]
		location.f = location.f or location[4]		
		PutMap({location.x, location.x, location.y},"Id",value)
	end
end
local function GetPath (_tTargets, _tOptions)
	--[[ DISCLAIMER.
	This code (May 04, 2014) is written by Akuukis 
		who based on code (Sep 21, 2006) by Altair
			who ported and upgraded code of LMelior
	--]]
	--[[ PRE.
	Map[][][] is a 3d infinite array (.Id, .Updated, .Evade)
	Pos.x is the player's current x or North
	Z is the player's current z or East
	Pos.y is the player's current y or Height (not yet implemented)
	target.x is the target x
	target.z is the target z
	target.y is the target y (not yet implemented)
	options is the preference (not yet implemented)

	Note. all the x and z are the x and z to be used in the table.
	By this I mean, if the table is 3 by 2, the x can be 1,2,3 and the z can be 1 or 2.
	--]]
	--[[ POST.
	path is a list with all the x and y coords of the nodes of the path to the target.
	OR nil if closedlist==nil
	-- Intro to A* - http://www.raywenderlich.com/4946/introduction-to-a-pathfinding
	-- Try it out! - http://zerowidth.com/2013/05/05/jump-point-search-explained.html
	--]]
	
	-- Filters legal options
	local tOptions = {}
	if type(_tOptions) == "table" then tOptions = _tOptions else tOptions = {} end
	_tOptions = nil
	
	-- Filters legal targets
	local tTargets = {}
	tTargets.Main = {}
	for n in pairs(_tTargets) do 
		if type(_tTargets[n]) == "table" then
			tTargets[n] = {}
			tTargets[n].x = _tTargets[n].x or _tTargets[n][1] or nil
			tTargets[n].z = _tTargets[n].z or _tTargets[n][2] or nil
			tTargets[n].y = _tTargets[n].y or _tTargets[n][3] or nil
			tTargets[n].f = _tTargets[n].f or _tTargets[n][4] or nil
			if not (tTargets[n].x and tTargets[n].z and tTargets[n].y) then tTargets[n] = nil end
			for m in pairs(tOptions) do
				if tOptions[m] == "Careful" and GetMap(tTargets[n],"Id") and GetMap(tTargets[n],"Id") >= 0 then tTargets[n] = nil end
			end
		elseif type(_tTargets[n]) == "number" then
			if n == "x" or n == "1" or n == 1 then tTargets.Main.x = _tTargets[n] end
			if n == "z" or n == "2" or n == 2 then tTargets.Main.z = _tTargets[n] end
			if n == "y" or n == "3" or n == 3 then tTargets.Main.y = _tTargets[n] end
			if n == "f" or n == "4" or n == 4 then tTargets.Main.f = _tTargets[n] end
		end
	end
	if tTargets.Main.x and tTargets.Main.z and tTargets.Main.y then local x = 1 else tTargets.Main = nil end
	
	local Count = 0
	for n in pairs(tTargets) do Count = Count + 1 end
	Logger.Info("Got %s/%s valid targets!\n", Count, table.maxn(_tTargets) )
	if Count == 0 then return nil end -- no valid targets
	_tTargets = nil
	
	function CalcHeuristic (Pos, _tTargets, _tOptions)
		-- Useful - http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
		AverageCost = 1
		DefaultOption1 = "ManhattanTieBreaker"
		for n in pairs(_tOptions) do
			if _tOptions[n] == "Manhattan" or _tOptions[n] == "ManhattanTieBreaker" then DefaultOption1 = _tOptions[n] end
		end
		local MinCost = 999999
		for n in pairs(_tTargets) do
			local Cost = 0
			if DefaultOption1 == "Manhattan" then
				dx = math.abs(GetPos(Pos).x-GetPos(_tTargets[n]).x)
				dz = math.abs(GetPos(Pos).z-GetPos(_tTargets[n]).z)
				dy = math.abs(GetPos(Pos).y-GetPos(_tTargets[n]).y)
				Cost = AverageCost * (dx + dz + dy)
			elseif DefaultOption1 == "ManhattanTieBreaker" then
				dx = math.abs(GetPos(Pos).x-GetPos(_tTargets[n]).x)
				dz = math.abs(GetPos(Pos).z-GetPos(_tTargets[n]).z)
				dy = math.abs(GetPos(Pos).y-GetPos(_tTargets[n]).y)
				Cost = AverageCost * (dx + dz + dy) * (1 + 1/1000)
			else return false -- error
			end
			--Logger.Check("%s: %s,%s,%s,%s -> %s,%s,%s,%s = %s\n", n, Pos.x, Pos.z, Pos.y, Pos.f, _tTargets[n].x, _tTargets[n].z, _tTargets[n].y, _tTargets[n].f, Cost, MinCost) 
			if Cost < MinCost then MinCost = Cost end
		end
		return MinCost
	end
		
	-- Logger.Debug("Nav.GetPath(%s,%s,%s)\n",target.x,target.z,target.y)

	local closedlist = {}		-- Initialize table to store checked gridsquares
	local openlist = {}			-- Initialize table to store possible moves
	openlist[1] = {}					-- Make starting point in list
	openlist[1].x = GetPos().x
	openlist[1].z = GetPos().z
	openlist[1].y = GetPos().y
	openlist[1].DistExactStart = 0
	openlist[1].DistHeuristicTarget = CalcHeuristic(GetPos(), tTargets, tOptions)
	openlist[1].DistSum = openlist[1].DistExactStart + openlist[1].DistHeuristicTarget
	openlist[1].parent = 1
	local openk = 1					-- Openlist counter
	local closedk = 0				-- Closedlist counter
	local DefaultWeight = 3 -- TODO!
	-- Logger.Check("Openlist.x|y|z=%s,%s,%s\n",openlist[1].x,openlist[1].z,openlist[1].y)
	local OptionMoveStyle = "Normal"
	for n,v in pairs(tOptions) do
		if v == "Normal" or v == "Careful" then OptionMoveStyle = v end
		-- ... other options
	end

	while openk > 0 and table.maxn(closedlist) < 128 do   -- Growing loop
		-- Find next node with the lowest DistSum
		local lowestDS = openlist[openk].DistSum		-- Take DistSum of last node as etalon
		local basis = openk	-- Take last node as etalon
		for i = openk,1,-1 do -- Search backwards (Prefer newer nodes)
			if openlist[i].DistSum < lowestDS then
				lowestDS = openlist[i].DistSum
				basis = i
			end
		end
		closedk = closedk + 1
		closedlist[closedk] = openlist[basis]
		local curbase = closedlist[closedk]				 -- define current base from which to grow list
		--Logger.Debug("%s/%s:(%s,%s,%s)(%s,%s,%s|%s)\n", closedk, openk, curbase.x, curbase.z, curbase.y, math.floor(curbase.DistExactStart), math.floor(curbase.DistHeuristicTarget), math.floor(curbase.DistSum), curbase.parent)
		--for i,v in pairs(closedlist) do 
		--	Logger.Debug("%s:x=%s,y=%s,z=%s,p=%s,DE=%s,DH=%s,DS=%s\n", i, v.x, v.y, v.z, v.parent, v.DistExactStart, math.floor(v.DistHeuristicTarget), math.floor(v.DistSum))
		--end
		--Logger.Check("")
		table.remove(openlist,basis) -- This function deletes an element of a numerical table and moves up the remaining indices if necessary.
		openk = openk - 1
		
		local OK = {}
		for face=0,5 do OK[face] = 1 end  

		if OptionMoveStyle == "Normal" then		-- If it IS on the map, check map for obstacles
			for face=0,5 do if GetMap(GetPos(curbase,face),"Id") then OK[face] = DefaultWeight end end
		elseif OptionMoveStyle == "Careful" then
			for face=0,5 do if GetMap(GetPos(curbase,face),"Id") then OK[face] = false end end
		end
		
		for face=0,5 do if GetMap(GetPos(curbase,face),"Tag") == true then OK[face] = false end end	-- Look through Tagged
		
		--Logger.Debug("Closedlist:\n")
		if closedk>0 then		-- Look through closedlist
			for i=1,closedk do
				for face=0,5 do 
					--Logger.Debug("%s,%s,%s,%s =? %s,%s,%s,%s",GetPos(closedlist[i]).x,GetPos(closedlist[i]).z,GetPos(closedlist[i]).y,GetPos(closedlist[i]).f,GetPos(curbase,face).x,GetPos(curbase,face).y,GetPos(curbase,face).z,GetPos(curbase,face).f)
					if ComparePos(GetPos(closedlist[i]),GetPos(curbase,face),false) then OK[face] = false; --[[Logger.Debug("CL! ")--]] end 
					--Logger.Debug("\n")
				end
				--Logger.Check("")
			end
		end

		--Logger.Debug("Openlist:\n")
		for i=1,openk do		-- Look through openlist, check if the move from the current base is shorter than from the former parent
			--Logger.Debug("Openlist(%s/%s): %s,%s,%s,%s\n", i, openk, openlist[i].x, openlist[i].z, openlist[i].y, openlist[i].f)
			for face=0,5 do
				--Logger.Debug("%s/5: %s,%s,%s,%s. %s -> ",face,GetPos(curbase,face).x,GetPos(curbase,face).z,GetPos(curbase,face).y,GetPos(curbase,face).f,OK[face])
				if OK[face] and ComparePos(openlist[i],GetPos(curbase,face),false) then
					if openlist[i].DistExactStart < curbase.DistExactStart + OK[face] then
						openlist[i].DistExactStart = curbase.DistExactStart + OK[face]
						openlist[i].DistSum = openlist[i].DistHeuristicTarget + openlist[i].DistExactStart
						openlist[i].parent = closedk
					end
					OK[face] = false
				end
				--Logger.Debug("%s\n",OK[face])
			end
			--Logger.Check("")
		end

		--Logger.Debug("OK[face]: ")
		--for face=0,5 do Logger.Debug("%s",OK[face]) end
		--Logger.Debug("\n")

		for face=0,5 do		-- Add points to openlist
			if OK[face] then
				openk = openk + 1
				openlist[openk] = {}
				openlist[openk].x = GetPos(curbase,face).x
				openlist[openk].z = GetPos(curbase,face).z
				openlist[openk].y = GetPos(curbase,face).y
				openlist[openk].f = GetPos(curbase,face).f
				openlist[openk].DistExactStart = curbase.DistExactStart + OK[face]
				openlist[openk].DistHeuristicTarget = CalcHeuristic(GetPos(curbase,face), tTargets, tOptions)
				openlist[openk].DistSum = openlist[openk].DistExactStart + openlist[openk].DistHeuristicTarget
				openlist[openk].parent = closedk
				--Logger.Debug("F:%s:",face)
				--for n in pairs(openlist[openk]) do Logger.Debug("%s:%s,",n,openlist[openk][n]) end
				--Logger.Check("\n")
			end
		end
		
		--Logger.Check("Check finish!\n")
		if ComparePos(curbase,tTargets,false) then
			Logger.Debug("Found the path at %sth (of %s) try!\n", closedk, openk)
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
			Logger.Debug("Steps(x%s): ", i)
			for i=1,table.maxn(pathIndex),1 do
				path[i] = {}
				path[i].x = closedlist[pathIndex[table.maxn(pathIndex)+1-i]].x
				path[i].z = closedlist[pathIndex[table.maxn(pathIndex)+1-i]].z
				path[i].y = closedlist[pathIndex[table.maxn(pathIndex)+1-i]].y 
				Logger.Debug("%s|%s|%s, ", path[i].x,path[i].z,path[i].y)
			end
			--Logger.Debug("\n")     

			--for i=1,table.maxn(pathIndex) do
			--	Logger.Debug("%s(%s,%s,%s)", i, path[i].x, path[i].z, path[i].y)
			--end
			
			closedlist=nil
			
			-- Change list of XZ coordinates into a list of directions 
			Logger.Debug("FacePath. ")
			local fpath = {}
			for i=1,table.maxn(path)-1,1 do
				if path[i+1].x > path[i].x then fpath[i]=0 end -- North
				if path[i+1].z > path[i].z then fpath[i]=1 end -- East
				if path[i+1].x < path[i].x then fpath[i]=2 end -- South
				if path[i+1].z < path[i].z then fpath[i]=3 end -- West
				if path[i+1].y > path[i].y then fpath[i]=4 end -- Up
				if path[i+1].y < path[i].y then fpath[i]=5 end -- Down
				Logger.Debug("%s, ", fpath[i])
			end
			Logger.Debug("\n")
			Logger.Debug("%s\n",fpath)
			return fpath
		end
	end
	return nil
end

-- Technical and dependent functions, sub-Core level
local function Move (_Face, _tOptions) -- _Face={0=North|1=East|2=South|3=West|4=up|5=down}, returns true if succeeded

	Logger.Debug("0..")
	local OptionMoveStyle = "Normal" -- or "Careful" or "Blind" (Don't use Blind!)
	tOptions = _tOptions or {}
	for n,v in pairs(tOptions) do
		if v == "Careful" or v == "Normal" or v == "Blind" then OptionMoveStyle = v end
		-- ... other options
	end
	
	--Logger.Debug("Nav.Move(%s,%s,%s)\n", _Face.f, _Face.id, options)
	Utils.Refuel()
	local Id = GetMap(GetPos(_Face)).Id -- before updates
	TurnTo(_Face)
	UpdateMap()
	
	if OptionMoveStyle == "Blind" or not GetMap(GetPos(_Face)).Tag then
		if OptionMoveStyle == "Blind" or OptionMoveStyle == "Normal" or not GetMap(GetPos(_Face)).Id then
			local success = false
			if _Face == 4 then 
				while turtle.detectUp() do turtle.digUp(); sleep(0.5) end
				success = turtle.up()
			elseif _Face == 5 then
				while turtle.detectDown() do turtle.digDown(); sleep(0.5) end
			    success = turtle.down()
			else 
				while turtle.detect() do turtle.dig(); sleep(0.5) end
				success = turtle.forward()
			end
			if success then
				UpdatePos(_Face)
				UpdateMap()
				--Logger.Debug("Nav.Move() Return true\n")
				return true
			end
		end
	end
	return false
end

-- Core functions

function TurnRight ()
	turtle.turnRight()
	--Logger.Debug("Nav.TurnRight() Nav.Pos.f. %s => ",GetPos().f)
	Pos.f = (GetPos().f+1)%4
	--Logger.Debug("%s\n",GetPos().f)
	UpdateMap()
	return true
end
function TurnLeft ()
	turtle.turnLeft()
	--Logger.Debug("Nav.TurnLeft() Nav.Pos.f. %s => ",GetPos().f)
	Pos.f = (GetPos().f+3)%4
	--Logger.Debug("%s\n",GetPos().f)
	UpdateMap()
	return true
end
function TurnAround ()
	if 1==math.random(0,1) then
		TurnRight()
		TurnRight()
	else
		TurnLeft()
		TurnLeft()
	end
	return true
end
function TurnTo (Dir)
	if type(Dir) ~= "number" or Dir >= 4 then return true end
	if Dir==GetPos().f or Dir==GetPos().f+4 then return true
	elseif Dir==GetPos().f-1 or Dir==GetPos().f+3 then return TurnLeft()
	elseif Dir==GetPos().f-2 or Dir==GetPos().f+2 then return TurnAround()
	elseif Dir==GetPos().f-3 or Dir==GetPos().f+1 then return TurnRight()
	end
end
function Go ( ... ) -- table target1 [, table target2 ...] text option1 [, text option2 ...]
	
	local tTargets = {}
	local tOptions = {}
	
	for i=1,select('#',...) do
		local temp = select(i,...)
		if type(temp) == "table" then tTargets[table.maxn(tTargets)+1] = temp end
		if type(temp) == "string" then tOptions[table.maxn(tOptions)+1] = temp end
	end
	
	for i,target in ipairs(tTargets) do
		target.x = target.x or target[1] or 0
		target.z = target.z or target[2] or 0
		target.y = target.y or target[3] or 0
		target.f = target.f or target[4] or nil
	end
	
	for i,option in ipairs(tOptions) do
		if option == "Absolute" or option == "absolute" then option = "Absolute"
		elseif option == "RelCoords" or option == "relcoords" then option = "RelCoords"
		elseif option == "RelPos" or option == "relpos" then option = "RelPos"
		elseif option == "Normal" or option == "normal" then option = "Normal" 
		elseif option == "Careful" or option == "careful" then option = "Careful" 
		else option = nil
		end
	end
	
	local OptionRefStyle = "Absolute"
	for i,options in ipairs(tOptions) do if option == "RelCoords" or option == "RelPos" then OptionRefStyle = option end end
	if OptionRefStyle == "RelCoords" then
		for j in ipairs(tTargets) do
			tTargets[j].x = tTargets[j].x + GetPos().x
			tTargets[j].z = tTargets[j].z + GetPos().z
			tTargets[j].y = tTargets[j].y + GetPos().y
		end
	end
	if OptionRefStyle == "RelPos" then
		for j in ipairs(tTargets) do
			tTargets[j].x = tTargets[j].x + GetPos().x
			tTargets[j].z = tTargets[j].z + GetPos().z
			tTargets[j].y = tTargets[j].y + GetPos().y
			if GetPos().f == 0 then tTargets[j].x = GetPos().x + tTargets[j].x; tTargets[j].z = GetPos().z + tTargets[j].z end
			if GetPos().f == 1 then tTargets[j].x = GetPos().x - tTargets[j].z; tTargets[j].z = GetPos().z + tTargets[j].x end
			if GetPos().f == 2 then tTargets[j].x = GetPos().x - tTargets[j].x; tTargets[j].z = GetPos().z - tTargets[j].z end
			if GetPos().f == 3 then tTargets[j].x = GetPos().x + tTargets[j].z; tTargets[j].z = GetPos().z - tTargets[j].x end
		end
	end
	
	local tries=32 -- TODO
	--if table.maxn(tTargets) > 0 then Logger.Debug("Nav.Go(x%s)(%s,%s,%s)\n", table.maxn(tTargets), tTargets[1].x, tTargets[1].z, tTargets[1].y) end
	repeat
		local _, Destination = ComparePos(GetPos(),tTargets)
		if Destination then
			TurnTo( Destination.f )
			return true 
		else 
			tries = tries - 1
		end
		-- Logger.Debug("Nav.Go() @ (%s,%s,%s,F%s)/%s\n",GetPos().x,GetPos().z,GetPos().y,GetPos().f,tries)
		local fpath = GetPath(tTargets,tOptions)
		if fpath == nil then -- TODO: Cannot find path!
			-- Logger.Debug("Nav.Go() FPath=nil!")
			UpdateMap()
			TurnRight()
		else
			Logger.Debug("Start moving!")
			i = 1
			success = true
			while i <= table.maxn(fpath) and success do 
				-- Logger.Debug("%s",i)
				-- Logger.Debug("@(%s,%s,%s),(%s,%s) Moving %s/%s ...\n", GetPos().x,GetPos().z,GetPos().y,not fpath[i],not GetMap(GetPos(fpath[i]),"Id"),i,table.maxn(fpath))
				success = Move(fpath[i], tOptions)
				i = i + 1
			end
		end
	until tries < 0
	-- Logger.Debug("Nav.Go() Out-of-UNTIL! /%s",tries)
	return false
end

-- Shortcut functions

function Step(...)
	return Move(GetPos().f,{...})
end
function StepUp(...)
	return Move(4,{...})
end
function StepDown(...)
	return Move(5,{...})
end
function GetDistance (target, ...) -- Gets distance between your position and a target with given options
	local options = {}
	for i=1,select('#',...) do
		local temp = select(i,...)
		if type(temp) == "text" then options[table.maxn(options)+1] = temp end
	end
	return table.maxn( GetPath(target,options) )
end
function GoNextTo ( center, ... )
	local SixTargets = {}
	--Logger.Debug("Center: ")
	--for i,v in pairs(center) do Logger.Debug("'%s'=%s, ",i,v) end
	--Logger.Debug("SixTargets: %s\n",SixTargets)
	for i=0,5 do
		SixTargets[i+1] = GetPos(center,i)
		--Logger.Debug("SixTargets: %s\n",SixTargets)
		--for j,v in pairs(GetPos(center,i)) do Logger.Debug("'%s'=%s, ",j,v) end
		--for j,v in pairs(SixTargets[1]) do Logger.Debug("'%s'=%s, ",j,v) end
		--Logger.Debug("%s: %s,%s,%s,%s\n",SixTargets[i+1], SixTargets[i+1].x,SixTargets[i+1].z,SixTargets[i+1].y,SixTargets[i+1].f)
	end
	--Logger.Check("")
	SixTargets[1].f = 2
	SixTargets[2].f = 3
	SixTargets[3].f = 0
	SixTargets[4].f = 1
	SixTargets[5].f = nil
	SixTargets[6].f = nil
	Go( SixTargets[1], SixTargets[2], SixTargets[3], SixTargets[4], SixTargets[5], SixTargets[6], ... )
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------

--[[ Tutorials
General: http://www.lua.org/pil/contents.html
Varargs: http://lua-users.org/wiki/VarargTheSecondClassCitizen
Nav.ComparePos({1,2,3},{1,2,3})
--]]
	