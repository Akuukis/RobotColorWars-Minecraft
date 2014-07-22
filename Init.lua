--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
WiP
--]]

--[[ let's drop Environment thingy
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
if type(Init) == "table" then Lib = Init end
Init = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
-- local 
local coroutine = coroutine
local read = io.read

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): getfenv, getmetatable, loadfile, dofile, print, type, string.sub, string.find, write
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
-- local 
-- local
local write = write

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic = Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic
local TheColony = TheColony
-- DEBUG only. Sets access to all functions.
setmetatable(Lib, { __index = _G } )

-- no more external access after this point.
setfenv(1, Lib)
--]]


--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------

clsObject = { -- WiP!!!
	UniqId = "", -- UniqId of this object inside parent.
	Type = "", -- Colony | Base | Farm | Turtle | Inventory | Bag | Container | Resource

	Extra = {}, -- Military or Research for Colony, Upgrades for Bases and Farms, Hierarchy for Turtles, Item|Fluid|Energy for Containers and Resources.
	Pos = {} or 0, -- X,Z,Y,F for the back buttom left corner relative to its parent or SlotId.
	Size = {} or 0, -- # of chunkloaders placed for Colony, X,Z,Y size in blocks or amount in stack if inside.
	TimeofBirth = 0,-- mostly used for registering future objects.
	
	Parent = "", -- Colony object is the only one that has Parent = false
	Children = {}, -- Table of children clsObject objects, things within this object. For Inventory|Bag|Container index = SlotId.
	
	Value = 0, -- For Inventory|Bags|Containers|Resources its the supply value, for Colony|Base|Farm|Turtle its cached sum of PartList supply value

	TimeUpdated = 0, -- Time of last change
	}
--clsObject.__index = clsObject

function clsObject:Inherit()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end	
function clsObject:New ( _Obj )
	local o = {}
	o.UniqId = Utils.GenUniqString("Object") -- UniqId of this object.
	o.TimeUpdated = Utils.GetTime()

	local tTypes = { "Colony", "Base", "Farm", "Turtle", "Inventory", "Bag", "Container", "Resource" }
	for i=1,table.maxn(tTypes) do
		if _Obj.Type == tTypes[i] then o.Type = tTypes[i] end
	end
	if not o.Type then return "No valid Type provided" end
	
	o.Id = _Obj.Id or nil
	o.Meta = _Obj.Meta or nil
	o.Extra = _Obj.Extra;	if not o.Extra then return "No Extra provided" end 
	o.Pos = _Obj.Pos;	if not o.Pos then return "No Position(Pos) provided" end
	o.Size = _Obj.Size;	if not o.Size then return "No Size provided" end
	o.TimeofBirth = _Obj.TimeofBirth or Utils.GetTime()
	
	o.Parent = _Obj.Parent;	if type(o.Parent) == "nil" then return "No Parent provided" end
	o.Children = _Obj.Children or {}
	
	o.Value = _Obj.Value;	if not o.Value then return "No Value provided" end

	return o		
end

clsColony = clsObject:Inherit()
clsBase = clsObject:Inherit()
clsFarm = clsObject:Inherit()
clsTurtle = clsObject:Inherit()
clsInventory = clsObject:Inherit()
clsBag = clsObject:Inherit()
clsContainer = clsObject:Inherit()
clsResource = clsObject:Inherit()

clsColony.Profile = {}
clsColony.Partlist = {}
clsColony.Flows = {}
function clsColony:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Colony",
		["Extra"] = {
			["Research"] = {},
			["Espionage"] = {},
			["Military"] = {},
			},
		["Pos"] = Nav.GetPos(),
		["Size"] = 1, -- At the start there's always only 1 chunkloader
		--TimeofBirth
		["Parent"] = false,
		--Children
		["Value"] = 0,
		} )
	
	if type(o) == "string" then return o end -- return error if any
		
	o.Profile = {} -- TODO
	
	setmetatable(o, self)
	self.__index = self
	return o		
end

clsBase.Profile = {}
clsBase.Partlist = {}
clsBase.Flows = {}
function clsBase:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Base",
		["Extra"] = {
			["hasBrains"] = false,
			["isConnectedNorth"] = false,
			["isConnectedEast"] = false,
			["isConnectedSouth"] = false,
			["isConnectedWest"] = false,
			},
		["Pos"] = _Obj.Pos,
		["Size"] = {144,144,255}, -- 9 chunks x 16 blocks, from bottom to sky
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Profile = {} --TODO
	o.PartList = {} -- TODO
	o.Flows = {} -- TODO
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsFarm.Profile = {}
clsFarm.Partlist = {}
clsFarm.Flows = {}
function clsFarm:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Farm",
		["Extra"] = {
			["hasBrains"] = false,
			["isConnectedNorth"] = false,
			["isConnectedEast"] = false,
			["isConnectedSouth"] = false,
			["isConnectedWest"] = false,
			},
		["Pos"] = _Obj.Pos,
		["Size"] = _Obj.Size,
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Profile = {} --TODO
	o.PartList = {} -- TODO
	o.Flows = {} -- TODO
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsTurtle.Profile = {}
clsTurtle.Partlist = {}
clsTurtle.Flows = {}
function clsTurtle:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Turtle",
		["Extra"] = {
			["hasBrains"] = false,
			["isConnectedNorth"] = false,
			["isConnectedEast"] = false,
			["isConnectedSouth"] = false,
			["isConnectedWest"] = false,
			},
		["Pos"] = _Obj.Pos,
		["Size"] = _Obj.Size,
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Profile = {} --TODO
	o.PartList = {} -- TODO
	o.Flows = {} -- TODO
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsInventory.Id = -1 -- Unknown
clsInventory.Meta = -1 -- Unknown
function clsInventory:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Inventory",
		["Extra"] = _Obj.Extra,
		["Pos"] = _Obj.Pos,
		["Size"] = 1, -- All inventories are of size 1
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Id = _Obj.Id or nil
	o.Meta = _Obj.Meta or nil
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsBag.Id = -1 -- Unknown
clsBag.Meta = -1 -- Unknown
function clsBag:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Bag",
		["Extra"] = _Obj.Extra,
		["Pos"] = _Obj.Pos,
		["Size"] = _Obj.Size or 1,
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Id = _Obj.Id or nil
	o.Meta = _Obj.Meta or nil
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsContainer.Id = -1 -- Unknown
clsContainer.Meta = -1 -- Unknown
function clsContainer:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Container",
		["Extra"] = _Obj.Extra,
		["Pos"] = _Obj.Pos,
		["Size"] = _Obj.Size or 1,
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Id = _Obj.Id or nil
	o.Meta = _Obj.Meta or nil
	
	setmetatable(o, self)
	self.__index = self
	return o
end	

clsResource.Id = -1 -- Unknown
clsResource.Meta = -1 -- Unknown
function clsResource:New( _Obj )
	local o
	o = clsObject:New( {
		--UniqId
		--TimeUpdated
		["Type"] = "Resource",
		["Extra"] = _Obj.Extra,
		["Pos"] = _Obj.Pos,
		["Size"] = _Obj.Size or 1,
		--TimeofBirth
		["Parent"] = _Obj.Parent,
		--Children
		["Value"] = 0,
		} )
	if type(o) == "string" then return o end -- return error if any
	
	o.Id = _Obj.Id or nil
	o.Meta = _Obj.Meta or nil
	
	setmetatable(o, self)
	self.__index = self
	return o
end	


--------------------------------------------------------------------------------------------------------------------------------
---------------- Public functions ----------------------------------------------------------------------------------------------

function InitStart ()
	TheColony = clsColony:New()
	assert(TheColony.Type=="Colony","TheColony table failed!")
	
	Nav.UpdateMap({0,0,0},false)
	write("In")
	coroutine.yield({ ["Flag"] = "TuCoWa_Call", ["Function"] = Logger.Info, ["Args"] = {"itialized!\n\n"} })
	coroutine.yield()
	--coroutine.yield("_Call",PlayerRun)
	-- first turtle will look for signs with instructions (if another turtle made it)
	--write("No signs found.\n")
	write("Human, choose fate of the turtle:\n")
	write("1. Player assistant\n")
	write("2. Independent colony (WiP!)\n")
	write("3. Independent colony (debug, WiP!)\n")
	while true do
		local event, param1 = os.pullEvent("char")
		if event == "char" and param1 == "1" then InitPlayerAssistant(); break end
		if event == "char" and param1 == "2" then InitColonyMember(); break end
		if event == "char" and param1 == "3" then InitColonyMemberDebug(); break end
	end
end

function InitPlayerAssistant()
	--Utils.Refuel()
	Logger.Info("@ ")
	str = read()
	local ch = loadstring(str)
	if ch and str ~="" then 
		--print(pcall(ch))
		coroutine.yield({ ["Flag"] = "TuCoWa_Call", ["Function"] = pcall, ["Args"] = {ch} })
		coroutine.yield("dummy")
		Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos().x,Nav.GetPos().z,Nav.GetPos().y,Nav.GetPos().f)
	end
	InitPlayerAssistant()
	--coroutine.yield("_Call",PlayerRun)
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------

-- none
