--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
WiP
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
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

-- DEBUG only. Sets access to all functions.
setmetatable(Lib, { __index = _G } )

-- no more external access after this point.
setfenv(1, Lib)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------

local clsObject = { -- WiP!!!
	UniqId = "", -- UniqId of this object inside parent.
	Type = "", -- TheWorld | Base | Farm | Turtle | Inventory | Bag | Container | Resource
	
	Id = "",
	Meta = "",
	Extra = {}, -- Military or Research for TheWorld, Upgrades for Bases and Farms, Hierarchy for Turtles, Item|Fluid|Energy for Containers and Resources.
	Position = {} or 0, -- X,Z,Y,F for the back buttom left corner relative to its parent or SlotId.
	Size = {} or 0, -- X,Z,Y size in blocks or amount in stack if inside.
	TimeofBirth = 0,-- mostly used for registering future objects.
	
	Parent = "", -- TheWorld object is the only one that has Parent = nil
	Children = {}, -- Table of children clsObject objects, things within this object. For Inventory|Bag|Container index = SlotId.
	
	Value = 0, -- For Inventory|Bags|Containers|Resources its the supply value, for TheWorld|Base|Farm|Turtle its cached sum of PartList supply value

	TimeUpdated = 0, -- Time of last change
	
	new = function (self)
		local o
		setmetatable(o, self)
		self.__index = self
		return o
    end,
	}
	
--local clsTheWorld = clsObject:new()
--clsTheWorld.Profile = {} -- set of randomized defaults.

local clsBase = {
	Profile = {}, -- set of randomized defaults.
	PartList = {}, -- For Bases & Farms & Turles its the resources collected if destroyed including those inside Containers for Flows.
	Flows = {	-- For objects that generate something on their own (like defense systems)
		InputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			}, 
		OutputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			},
		Cycle = 0, -- Lenght of one cycle to transform InputList into OutputList in ticks. 1sec = 20 tics.
		FlagRun = true, -- True: flows until input is valid. False: flows until Inventory is full. Nil: flows only if output inventory is empty
		FlagInput = true, -- True: Input is taken at start. False: Input is taken at the end. Nil: Input is taken somewhere in middle.
		FlagOutput = true,	-- True: Output is made at start. False: Output is made at the end. Nil: Output is made somewhere in middle.
		Type = 0, -- Different types of flows can run in parralel, but only one flow per each type. 
		Priority = 0, -- 1 is higher priority over 2, and only 0 will stop any non-0 priority flow.
		},
	}
local clsFarm = {
	Profile = {}, -- set of randomized defaults.
	PartList = {}, -- For Bases & Farms & Turles its the resources collected if destroyed including those inside Containers for Flows.
	Flows = {	-- For objects that generate something on their own (like automated tree farms)
		InputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			}, 
		OutputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			},
		Cycle = 0, -- Lenght of one cycle to transform InputList into OutputList in ticks. 1sec = 20 tics.
		FlagRun = true, -- True: flows until input is valid. False: flows until Inventory is full. Nil: flows only if output inventory is empty
		FlagInput = true, -- True: Input is taken at start. False: Input is taken at the end. Nil: Input is taken somewhere in middle.
		FlagOutput = true,	-- True: Output is made at start. False: Output is made at the end. Nil: Output is made somewhere in middle.
		Type = 0, -- Different types of flows can run in parralel, but only one flow per each type. 
		Priority = 0, -- 1 is higher priority over 2, and only 0 will stop any non-0 priority flow.
		},
	}
local clsTurtle = {
	Profile = {}, -- set of randomized defaults.
	PartList = {}, -- For Bases & Farms & Turles its the resources collected if destroyed including those inside Containers for Flows.
	Flows = {	-- For objects that generate something on their own (like Turtle generates WorkSeconds)
		InputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			}, 
		OutputList = {
			ResourceId = 0, -- May be also a Container with a specific content or a virtual Point
			AvgAmount = 0,
			StDev = 0,
			Position = "", -- UniqId from PartList pointing to a valid Inventory | Bag | Container
			},
		Cycle = 0, -- Lenght of one cycle to transform InputList into OutputList in ticks. 1sec = 20 tics.
		FlagRun = true, -- True: flows until input is valid. False: flows until Inventory is full. Nil: flows only if output inventory is empty
		FlagInput = true, -- True: Input is taken at start. False: Input is taken at the end. Nil: Input is taken somewhere in middle.
		FlagOutput = true,	-- True: Output is made at start. False: Output is made at the end. Nil: Output is made somewhere in middle.
		Type = 0, -- Different types of flows can run in parralel, but only one flow per each type. 
		Priority = 0, -- 1 is higher priority over 2, and only 0 will stop any non-0 priority flow.
		},
	}
local clsInventory = {}
local clsBag = {}
local clsContainer = {}
local clsResource = {}



--------------------------------------------------------------------------------------------------------------------------------
---------------- Public functions ----------------------------------------------------------------------------------------------

function Start ()
	Nav.UpdateMap({0,0,0},false)
	coroutine.yield("_Call",Logger.Info,{"In"})
	coroutine.yield("_Call",PlayerRun)
	write("itialized!\n")
end

function PlayerRun()
	--Utils.Refuel()
	Logger.Info("@ ")
	str = read()
	ch = loadstring(str)
	if ch and str ~="" then 
		--print(pcall(ch))
		coroutine.yield("_Call",pcall,{ch})
		
		pos = Nav.GetPos()
		Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos().x,Nav.GetPos().z,Nav.GetPos().y,Nav.GetPos().f)
	end
	coroutine.yield("_Call",PlayerRun)
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------

-- none
