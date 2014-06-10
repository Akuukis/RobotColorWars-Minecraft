--------------------------------------------------------------------------------------------------------------------------------
--[[------------ Descriptions of function calls --------------------------------------------------------------------------------
Useful Stuff:
for n in pairs(list) do Logger.Debug("%s: %s\n",n,list[n]) end -- lists all members and their values the list
for n in pairs(list) do print(n,": ", list[n]) end
--]]
--------------------------------------------------------------------------------------------------------------------------------
---------------- Dependencies --------------------------------------------------------------------------------------------------
-- Name Section: 
-- Declare the name library will use. Leave it alone and
local Lib = {}
Logger = Lib

-- Import Section:
-- declare everything this library needs from outside
-- FYI You can change or shorten names if you wish so.

---- Luaj unmodified libraries. Import only needed sub-functions.
-- Full list (functions): assert, collectgarbage, error, _G, ipairs, load, loadstring, next, pcall, rawequal, rawget, rawset, select, setfenv, setmetatable, tonumber, tostring, unpack, _VERSION, xpcall, require, module
-- Full list (tables): coroutine, package, table, math
local select, unpack = select, unpack
local string, coroutine = string, coroutine

---- CC libraries. Import only needed sub-functions.
-- Full list (modified Luaj functions): getfenv, getmetatable, loadfile, dofile, print, type, string.sub, string.find, write
-- Full list (modified Luaj tables): string, os, io
-- Full list (new tables): os, colors, disk, gps, help, keys, paintutils, parallel, peripheral, rednet, term, textutils, turtle, vector, window
local type, write = type, write

---- TuCoWa libraries. Import only needed sub-functions.
-- Full list: Gui, Rui, Hud, Logger, Stats, Comm, Utils, Nav, Jobs, Resm, Logic, Init
local Gui, Rui, Hud = Gui, Rui, Hud

-- no more external access after this point
setfenv(1, Lib)

--------------------------------------------------------------------------------------------------------------------------------
---------------- Library wide variables ----------------------------------------------------------------------------------------

Level = { GUI = 5, RUI = 5, HUD = 5 }

--------------------------------------------------------------------------------------------------------------------------------
---------------- Classes -------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
---------------- Public functions ----------------------------------------------------------------------------------------------

function Check(...) -- throw inside the code to stop it and check variables
    write(Format(...))
    while true do
		event, param1 = coroutine.yield("key")
		if event == "key" then
			break
		end
	end
end

function Debug(...)
	if Level.GUI >= 4 then write(Format(...)) end
end

function Info(...)
	if Level.GUI >= 3 then write(Format(...)) end
end

function Warning(...)
	if Level.GUI >= 2 then write(Format(...)) end
end

function Error(...)
	if Level.GUI >= 1 then write(Format(...)) end
end

function Fatal(...)
	if Level.GUI >= 0 then write(Format(...)) end
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Private functions ---------------------------------------------------------------------------------------------

function Format(fmt, ... )
	local buf = {}
	for i = 1, select( '#', ... ) do
		local a = select( i, ... )
		if type( a ) ~= 'string' and type( a ) ~= 'number' then
			a = tostring( a )
		end
		buf[i] = a
	end
	if fmt == nil then fmt = "" end
	return string.format( fmt, unpack( buf ) )
end

--------------------------------------------------------------------------------------------------------------------------------
---------------- Details & Notes -----------------------------------------------------------------------------------------------


