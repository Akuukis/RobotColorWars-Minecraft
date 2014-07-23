--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
WiP
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
if type(Utils) == "table" then Lib = Utils end
Utils = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
local os, string, math = os, string, math

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): getfenv, getmetatable, loadfile, dofile, print, type, string.sub, string.find, write
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
local turtle = turtle

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui, Hud, Logger, Stats, Comm = Gui, Rui, Hud, Logger, Stats, Comm

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

function Refuel(self)
	if turtle.getFuelLevel() < 128 then
		if turtle.refuel() then 
			Logger.Info("Refueled!")
		else 
			Logger.Info("Fuel me!")
		end
	end
	return turtle.getFuelLevel()
end

function GenUniqString( _Name ) -- Accept "string" for names, check database for uniq
	-- char(67) -- TODO need unique ... 65-90 capitals, 97-122 lowercase, 48-57 numbers (26+26+10=62)
	local Str = ""
	for i=0,16 do
		local Char = math.random(0,61)
		if Char < 26 then Char = Char + 65
		elseif Char < 52 then Char = Char + 97 - 26
		elseif Char < 62 then Char = Char + 48 - 26 - 26
		end
		Str = Str .. string.char(Char)
	end
	return Str
end

function GetTime()
	return os.time()
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

-- none

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------
