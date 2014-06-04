--[[ API:
Useful Stuff:
for n in pairs(list) do Logger.Debug("%s: %s\n",n,list[n]) end -- lists all members and their values the list
for n in pairs(list) do print(n,": ", list[n]) end
--]]


local Level = { GUI = 5, RUI = 5, HUD = 5 }

function Check(...) -- throw inside the code to stop it and check variables
    write(Utils.myformat(...))
    while true do
		event, param1 = os.pullEvent()
		if event == "key" then
			break
		end
	end
end

function Debug(...)
	if Level.GUI >= 4 then write(Utils.myformat(...)) end
end

function Info(...)
	if Level.GUI >= 3 then write(Utils.myformat(...)) end
end

function Warning(...)
	if Level.GUI >= 2 then write(Utils.myformat(...)) end
end

function Error(...)
	if Level.GUI >= 1 then write(Utils.myformat(...)) end
end

function Fatal(...)
	if Level.GUI >= 0 then write(Utils.myformat(...)) end
end