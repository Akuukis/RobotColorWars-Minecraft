--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
WiP
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
Gui = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, getfenv, getmetatable, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
-- local 
local os = os

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): loadfile, dofile, print, type, string.sub, string.find
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
-- local 
-- local
-- local

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui = Gui, Rui

-- no more external access after this point
setfenv(1, Lib)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Public functions ----------------------------------------------------------------------------------------------

function PrintMap()
	--[[
	y = 0;
	for x = Nav.X + 3,Nav.X - 3, -1 do
		for z = Nav.Z - 19, Nav.Z + 19, 1 do
		if Nav.Map[x] == nil then
			Utils.printf(".")
		elseif Nav.Map[x][z] == nil then
			Utils.printf(".")
		else
			if (Nav.X == x and Nav.Z == z) then
				Utils.printf("#")
			else 
				if Nav.Map[x][z][y].Id == 0 then
					Utils.printf(" ")
				else
					Utils.printf("%s", Nav.Map[x][z][y].Id)
				end
			end
		end
	end
	
	Utils.printf("\n")
	end
	--]]
end

function PlayerRun()
	Utils.Refuel()
	write(Utils.myformat("\n# "))
	str = io.read()
	ch = loadstring(str)
	print(pcall(ch))
	
	pos = Nav.GetPos()
	Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos("x"),Nav.GetPos("z"),Nav.GetPos("y"),Nav.GetPos("f"))
	coroutine.yield("_Call",Gui.PlayerRun)
end

function Test()
	print("Kuku!")
	return true
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------
--[[ Info
Term API http://computercraft.info/wiki/Term_%28API%29
Turtle screen size (in chars) = 39 x 13
Computer screen size (in chars) = 51 x 19
--]]