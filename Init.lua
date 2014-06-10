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

-- none

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
	Logger.Info("\n# ")
	str = read()
	ch = loadstring(str)
	print(pcall(ch))
	
	pos = Nav.GetPos()
	Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos("x"),Nav.GetPos("z"),Nav.GetPos("y"),Nav.GetPos("f"))
	coroutine.yield("_Call",PlayerRun)
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------

-- none
