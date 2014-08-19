
local function StartDownloaderGitHub()

	local tArgs, gUser, gRepo, gPath, gBranch = nil, nil, nil, "", "master"
	local usage = [[
	 github [path] [remote path] [branch]
	 user is hardcoded to "Akuukis"
	 repo is hardcoded to "TurtleColorWars"
	 Remote path defaults to the root of the repo.
	 Path defaults to the download folder.
	 Branch defaults to master.
	 If you want to leave an option empty use a dot.
	 Example: github johnsmith hello-world . foo
	 Everything inside the directory foo will be 
	 downloaded to downloads/hello-world/.
	  ]]
	local blackList = [[
	@blacklistedfile
	]]

	local title = "Github Repo Downloader"
	local fileList = {dirs={},files={}}
	local x , y = term.getSize()

	-- GUI
	local function printTitle()
		local line = 2
		term.setCursorPos(1,line)
		for i = 2, x, 1 do write("-") end
		term.setCursorPos((x-title:len())/2,line+1)
		print(title)
		for i = 2, x, 1 do write("-") end
	end
	local function writeCenter( str )
		term.clear()
		printTitle()
		term.setCursorPos((x-str:len())/2-1,y/2-1)
		for i = -1, str:len(), 1 do write("-") end
		term.setCursorPos((x-str:len())/2-1,y/2)
		print("|"..str.."|")
		term.setCursorPos((x-str:len())/2-1,y/2+1)
		for i = -1, str:len(), 1 do write("-") end
	end 
	local function printUsage()
		local str = "Press space key to continue"
		term.clear()
		printTitle()
		term.setCursorPos(1,y/2-4)
		print(usage)
		term.setCursorPos((x-str:len())/2,y/2+7)
		print(str)
		while true do
			local event, param1 = os.pullEvent("key")
			if param1 == 57 then
				sleep(0)
				break
			end
		end
		term.clear()
		term.setCursorPos(1,1)
	end
	-- Download File
	local function downloadFile( path, url, name )
		writeCenter("Downloading File: "..name)
		dirPath = path:gmatch('([%w%_%.% %-%+%,%;%:%*%#%=%/]+)/'..name..'$')()
		if dirPath ~= nil and not fs.isDir(dirPath) then fs.makeDir(dirPath) end
		local content = http.get(url)
		local file = fs.open(path,"w")
		file.write(content.readAll())
		file.close()
	end
	-- Get Directory Contents
	local function getGithubContents( path )
		local pType, pPath, pName, checkPath = {}, {}, {}, {}
		local response = http.get("https://api.github.com/repos/"..gUser.."/"..gRepo.."/contents/"..path.."/?ref="..gBranch)
		if response then
			response = response.readAll()
			if response ~= nil then
				for str in response:gmatch('"type":"(%w+)"') do table.insert(pType, str) end
				for str in response:gmatch('"path":"([^\"]+)"') do table.insert(pPath, str) end
				for str in response:gmatch('"name":"([^\"]+)"') do table.insert(pName, str) end
			end
		else
			writeCenter( "Error: Can't resolve URL" )
			sleep(2)
			term.clear()
			term.setCursorPos(1,1)
			error()
		end
		return pType, pPath, pName
	end
	-- Blacklist Function
	local function isBlackListed( path )
		if blackList:gmatch("@"..path)() ~= nil then
			return true
		end
	end
	-- Download Managercd Start
	local function downloadManager( path )
		local fType, fPath, fName = getGithubContents( path )
		for i,data in pairs(fType) do
			if data == "file" then
				checkPath = http.get("https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i])
				if checkPath == nil then

					fPath[i] = fPath[i].."/"..fName[i]
				end
				local path = "Downloads/GitHub/"..gRepo.."/"..fPath[i]
				if gPath ~= "" then path = gPath.."/"..gRepo.."/"..fPath[i] end
				if not fileList.files[path] and not isBlackListed(fPath[i]) then
					fileList.files[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
				end
			end
		end
		for i, data in pairs(fType) do
			if data == "dir" then
				local path = "Downloads/GitHub/"..gRepo.."/"..fPath[i]
				if gPath ~= "" then path = gPath.."/"..gRepo.."/"..fPath[i] end
				if not fileList.dirs[path] then 
					writeCenter("Listing directory: "..fName[i])
					fileList.dirs[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
					downloadManager( fPath[i] )
				end
			end
		end
	end
	-- Main Function
	local function main( path )
		writeCenter("Connecting to Github")
		downloadManager(path)
		for i, data in pairs(fileList.files) do
			downloadFile( i, data[1], data[2] )
		end
		writeCenter("Download completed")
		sleep(2,5)
		term.clear()
		term.setCursorPos(1,1)
	end
	-- Parse User Input
	local function parseInput( user, repo , dldir, path, branch )
		if path == nil then path = "" end
		if branch ~= nil then gBranch = branch end
		if repo == nil then printUsage()
		else
			gUser = user
			gRepo = repo
			if dldir ~= nil then gPath = dldir end
			main( path ) 
		end
	end

	if not http then
		writeCenter("You need to enable the HTTP API!")
		sleep(3)
		term.clear()
		term.setCursorPos(1,1)
	else
		for i=1, 5, 1 do
			if tArgs[i] == "." then tArgs[i] = nil end
		end	
		parseInput( "Akuukis", "TurtleColorWars", tArgs[1], tArgs[2], tArgs[3])
	 shell.run("Downloads/GitHub/TurtleColorWars/Main", "Downloads/GitHub/TurtleColorWars/")
	end
end

local function StartDownloaderPastebin( ... )

	local ApiList = {
	"Gui","Rui","Hud","Logger","Stats",
	"Comm","Utils","Nav","Jobs","Resm",
	"Logic","Init"
	}
	local PastebinList = {
	--[[["Nam"] = {
	"Gui.....","Rui.....","Hud.....","Logger..","Stats...",
	"Comm....","Utils...","Nav.....","Jobs....","Resm....",
	"Logic...","Init....",},
	--]]
		["Aku"] = {
	"EiNQu1tr","Vf4iEtwA","y9b6Vm0P","Yxhz7Gju","VeVb4816",
	"5kqCkMdY","VtBzt7BU","3AKpWFvr","AigXBa8F","TsMtkpDU",
	"FMsxxBSe","YqXAK4gf",},
		["Alk"] = {
	"4j3xkFqi","Nhde3VzW","zeJ6qg7L","yJ2TDrAC","W2x8HN2Z",
	"de84SYF8","cf9SZvTb","HNAWHYUC","g75ryBk7","QpNgZqDk",
	"URjcXVqp","Z2wLpHNw",},
		["Mox"] = {
	"LCzvnrgm","yaz8QfNQ","EaH1rTcN","0jqNejLc","brF1SQX7",
	"bpyKQrn4","Y9RjARM5","TbXnTHVs","sKRJw3YD","--------",
	"jQizTuJd","--------",},
		["Hek"] = {
	"sCCxs23y","cRPh5hK5","4B9wHmfB","eXUFfw98","buAi08ga",
	"CaGGcpS3","0NP4EJcZ","Lvwz0A3b","mFFxtZUs","UmtZSab5",
	"eru9yvdg","BNVW9D5u",},
		["Mar"] = {
	"YwEvnNuv","VqYY94pE","a2pZzJhK","AyQ4RJRy","hTbMg1BG",
	"VymxZieZ","gdL40bFx","0rFQyhKi","rz2BBebP","0xMDUvL0",
	"3KZ9UcCK","D7mpfTqH",},
	}
	
	local function get(paste)
		--write( "Connecting to pastebin.com... " )
		write("connecting...")
		local cpx,cpy = term.getCursorPos()
		term.setCursorPos(cpx-string.len("Connecting..."), cpy)
		local response = http.get(
			"http://pastebin.com/raw.php?i="..textutils.urlEncode( paste )
		)
				
		if response then
			write( "connected, " )
			local cpx,cpy = term.getCursorPos()
			term.setCursorPos(cpx-string.len("connected, "), cpy)
			local sResponse = response.readAll()
			response.close()
			return sResponse
		else
			write( "Failed connection." )
			sleep(2)
		end
	end
	local function PastebinGet( ... )
		local tArgs = { ... }
		if #tArgs < 2 then return	end
		if not http then
			print( "Pastebin requires http API" )
			print( "Set enableAPI_http to true in ComputerCraft.cfg" )
			return
		end
		-- Download a file from pastebin.com
		-- Determine file to download
		local sCode = tArgs[1]
		local sFile = tArgs[2]
		local sPath = shell.resolve( sFile )
		if fs.exists( sPath ) then
				--write( "File already exists" )
				--return
		end
		-- GET the contents from pastebin
		local res = get(sCode)
		if res then        
				local file = fs.open( sPath, "w" )
				file.write( res )
				file.close()
				--print( "Downloaded as "..sFile )
				write("fetched, ")
		end 
		return
	end

	for i=1,select('#',...) do
		local tmp = select(i,...)
		if tmp == "start" then shell.run("delete Downloads/Pastebin" .. nick) end
		for j=1,12 do
			if tmp == "start" or tmp == "all" or tmp == ApiList[j] then
				write(ApiList[j] .. ": ") -- 39-8, 31-9, 22-8, 14-9, 5
				PastebinGet( PastebinList[nick][j], "Downloads/Pastebin/" .. nick .. "/" .. ApiList[j] )
				local Function, Error = loadfile("Downloads/Pastebin/" .. nick .. "/" .. ApiList[j] )
				if Function == nil then 
					write("error at loading: \n" .. Error .. "\n")
					sleep(5)
				else
					write("loaded, ")
					local Ok, Error = pcall(Function)
					if Ok == false then 
						write("Error at executing: \n" .. Error .. "\n")
						sleep(5)
					else
						write("executed!\n")
					end
				end
			end
		end
	end
end

nick = ""

local function Start()
	term.clear()
	print("Turtle Color Wars Downloader v1.0")
	print("Choose the source (press the key):")
	print()
	print("1 - GitHub")
	print("2 - Pastebin of Akuukis")
	print("3 - Pastebin of Alkerss")
	print("4 - Pastebin of moxxcrue")
	print("5 - Pastebin of Hekaya")
	print("6 - Pastebin of marchrime")
	event, param1 = os.pullEvent("char")
	if event == "char" and param1 == "1" then nick = "Git"; StartDownloaderGitHub("start") end
	if event == "char" and param1 == "2" then nick = "Aku"; StartDownloaderPastebin("start") end
	if event == "char" and param1 == "3" then nick = "Alk"; StartDownloaderPastebin("start") end 
	if event == "char" and param1 == "4" then nick = "Mox"; StartDownloaderPastebin("start") end 
	if event == "char" and param1 == "5" then nick = "Hek"; StartDownloaderPastebin("start") end
	if event == "char" and param1 == "6" then nick = "Mar"; StartDownloaderPastebin("start") end
end

local function UpdateAPI( nick, ... )
	if nick == "Git" then StartDownloaderGitHub( ... )
	else StartDownloaderPastebin( nick, ... )
	end
end

-------------------------------------------------------------------------------------------------------------------------------

print("Initialized Main!")
TheColony = { "Emptyness" }
Start()
--

-- Magic happens here
function coroutine.Manager( _FirstThread )

	local EventData = {"TuCoWa_dummy"}
	local firstThread, Focus, lastThread = 1, 1, 1
	local tThreads = { [1] = _FirstThread } -- TODO: Sanitize
	local tGraveyard = {}
	local tGraveyardTime = {}

	local Operations = {}
	Operations.TuCoWa_Cycle = function ( _tArgs )
		tThreads[Focus].Filter = _tArgs.Filter
		tThreads[Focus].Listen = true
		return nil -- Cycle to next coroutine
	end
	Operations.TuCoWa_Spawn = function ( _tArgs )
		tThreads[ lastThread+1 ] = {
			["Name"] = _tArgs.Name or "Anonymous",
			["Filter"] = _tArgs.Filter or nil,
			["Pause"] = 0,
			["Listen"] = false,
			["tArgSets"] = { 
				[1] = _tArgs.Args or nil },
			["Id"] = Utils.GenUniqString(16),
			["Function"] = _tArgs.Function,
		}
		if _tArgs.Args then tThreads[ lastThread+1 ].lastArgSet = 1 else tThreads[ lastThread+1 ].lastArgSet = 0 end
		lastThread = lastThread + 1
		return tThreads[ lastThread ].Id
	end
	Operations.TuCoWa_Whisper = function ( _tArgs )
		for _,Thread in pairs(tThreads) do
			if Thread.Id == _tArgs.Id then
				Thread.lastArgSet = Thread.lastArgSet + 1 
				Thread.tArgSets[ Thread.lastArgSet ] = _tArgs.Args or nil
				return true
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_Pause = function ( _tArgs )
		for _,Thread in pairs(tThreads) do
			if Thread.Id == _tArgs.Id then
				Thread.Pause = math.max(0, Thread.Pause + _tArgs.Amount)
				return true
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_Ask = function ( _tArgs )
		for _,Thread in pairs(tThreads) do
			if Thread.Id == _tArgs.Id and Thread.Listen == true then
				return coroutine.resume( Thread.Function, "TuCoWa_Ask", unpack(_tArgs.Msg or {}) )
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_Kill = function ( _tArgs )
		for i=firstThread,lastThread do
			if tThreads[i] and tThreads[i].Id == _tArgs.Id then 
				tGraveyard[ tThreads[i].Id ] = { false, "Killed", tThreads[Focus].Id, Utils.GetTime() }
				tGraveyardTime[ tThreads[i].Id ] = Utils.GetTime()
				tThreads[i] = nil
				return true
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_Dig = function ( _tArgs )
		if tGraveyard[ _tArgs.Id ] then
			local Results = tGraveyard[ _tArgs.Id ]
			tGraveyard[ _tArgs.Id ] = nil
			return true, Results
		end
		return false, "Not found in Graveyard, check Id or try again later"
	end
	Operations.TuCoWa_setFilter = function ( _tArgs )
		for i=firstThread,lastThread do
			if tThreads[i] and tThreads[i].Id == _tArgs.Id then 
				tThreads[i].Filter = _tArgs.Filter
				return true
			end
		end
		return false, "No running coroutine found, try to dig" 
	end		
	Operations.TuCoWa_getFilter = function ( _tArgs )
		for i=firstThread,lastThread do
			if tThreads[i] and tThreads[i].Id == _tArgs.Id then
				return tThreads[i].Filter
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_setName = function ( _tArgs )
		if _tArgs == nil then 
			tThreads[Focus] = _tArgs.Name
			return true
		end
		for i=firstThread,lastThread do
			if tThreads[i] and tThreads[i].Id == _tArgs.Id then 
				tThreads[i].Name = _tArgs.Name
				return true
			end
		end
		return false, "No running coroutine found, try to dig" 
	end		
	Operations.TuCoWa_getName = function ( _tArgs )
		for i=firstThread,lastThread do
			if tThreads[i] and tThreads[i].Id == _tArgs.Id then
				return tThreads[i].Name
			end
		end
		return false, "No running coroutine found, try to dig" 
	end
	Operations.TuCoWa_getThread = function ( _tArgs )
		if _tArgs.Id == nil then
			local Table = {}
			for Key,Value in pairs(tThreads[Focus]) do
				if Key ~= "tArgSets" then Table[Key] = Value end
			end
			return Table
		else
			for _,Thread in pairs(tThreads) do
				if Thread.Id == _tArgs.Id then
					local Table = {}
					for Key,Value in pairs(Thread) do
						if Key ~= "tArgSets" then Table[Key] = Value end
					end
					return Table
				end
			end			
			return false, "No running coroutine found, try to dig" 
		end
	end
	Operations.TuCoWa_getThreads = function ()
		local Table, count = {}, 0
		for _,Thread in pairs(tThreads) do
			count = count + 1
			Table[count] = {}
			for Key,Value in pairs(Thread) do
				if Key ~= "tArgSets" then Table[count][Key] = Value end
			end
		end
		return Table
	end
	Operations.TuCoWa_UpdateLib = function ( _tArgs ) -- TODO!
		UpdateAPI(unpack(_tArgs or {}))
		return true
	end
	
	while lastThread > 0 do  -- Run until no coroutines left (won't happen normally)
		--Logger.Debug("\nThread %s/%s (%s,%s)", Focus, lastThread ,EventData[1], EventData[2])
		
		if type(tThreads[Focus]) == "table" then 
			--Logger.Debug("%s!", tThreads[Focus].Pause)
			
			if not tThreads[Focus].Filter or tThreads[Focus].Filter == EventData[1] then
				tThreads[Focus].tArgSets[ tThreads[Focus].lastArgSet+1 ] = EventData
				tThreads[Focus].lastArgSet = tThreads[Focus].lastArgSet + 1
			end
			
			if tThreads[Focus].Pause == 0 then
				--Logger.Debug("..")
				
				local i = 1
				while i <= tThreads[Focus].lastArgSet do
					--Logger.Debug("i=%s..",i)
					
					local tResults = { coroutine.resume( tThreads[Focus].Function, unpack( tThreads[Focus].tArgSets[i] or {} ) ) }
					local isOk, tArgs = tResults[1], tResults[2]
					tThreads[Focus].tArgSets[i] = nil
					tThreads[Focus].Listen = false
					tThreads[Focus].Filter = false
					
					if not isOk then 
						Logger.Error("Coroutine failed! %s\n", tArgs )
						tGraveyard[ tThreads[Focus].Id ] = tResults
						tGraveyardTime[ tThreads[Focus].Id ] = Utils.GetTime()
						tThreads[Focus] = nil
					elseif coroutine.status(tThreads[Focus].Function) == "dead" then 
						tGraveyard[ tThreads[Focus].Id ] = tResults
						tGraveyardTime[ tThreads[Focus].Id ] = Utils.GetTime()
						tThreads[Focus] = nil
					else
						if tArgs and type(tArgs) == "string" then 
							tThreads[Focus].Filter = tArgs
						elseif tArgs and type(tArgs) == "table" then
							if tArgs.Flag and Operations[ tArgs.Flag ] then 
								tThreads[Focus].tArgSets[i] = { Operations[ tArgs.Flag ]( tArgs ) }
								if tThreads[Focus].tArgSets[i][1] == nil then tThreads[Focus].tArgSets[i] = nil end
							end
							os.queueEvent("TuCoWa_dummy")
						end
					end
					
					if not tThreads[Focus] then break end
					if tThreads[Focus].tArgSets[i] == nil then i = i + 1 end
				end

				if tThreads[Focus] then tThreads[Focus].lastArgSet = 0 end
			end
		else
			if Focus == lastThread then lastThread = lastThread - 1 end
			if Focus == firstThread then firstThread = math.min(firstThread + 1, lastThread) end
		end
		
		--Logger.Debug("\n")
		if Focus < lastThread then 
			Focus = Focus + 1
		else
			Focus = firstThread
			EventData = { os.pullEventRaw() } -- after a cycle call pullEventRaw ( = coroutine.yield )	
		end
		
	end
Logger.Debug("Out-of-coroutines!\n")
end

-- Sanitization happens here
function coroutine.Spawn( _Fn, ... )
	local Fn, err, tArgs
	if type(_Fn) == "function" then 
		Fn = _Fn
	elseif type(_Fn) == "string" then
		Fn, err = loadstring(_Fn)
		if not Fn then return false, err end
	elseif false then -- TODO: Add support for file handles
	else
		return false, "Not valid function or string"
	end
	Fn = coroutine.create(Fn)
	if not Fn then return false, "Failed to create coroutine" end
	
	return coroutine.yield({ 
		["Flag"] = "TuCoWa_Spawn",
		["Function"] = Fn,
		["Args"] = { ... },
		["Filter"] = nil,
		["Name"] = "Anonymous",
	})
end
function coroutine.Whisper( _sId, ... )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_Whisper",
		["Id"] = sId,
		["Args"] = { ... },
	})	
end
function coroutine.Pause( _sId, _Amount )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	if type(_Amount) ~= "number" then _Amount = 1 end
	return coroutine.yield({
		["Flag"] = "TuCoWa_Pause",
		["Id"] = _sId,
		["Amount"] = _Amount,
	})	
end
function coroutine.Unpause( _sId, _Amount )
	local Amount = -(_Amount or 1)
	return coroutine.Pause( _sId, Amount )
end
function coroutine.Ask( _sId, ... )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_Ask",
		["Id"] = _sId,
		["Msg"] = { ... },
	})	
end
function coroutine.Kill( _sId )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_Kill",
		["Id"] = _sId,
	})
end
function coroutine.Dig( _sId )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_Dig",
		["Id"] = _sId,
	})
end
function coroutine.Cycle( _sFilter, ... )
	local uAnswer = { ... }
	if type(_sFilter) ~= "string" then _sFilter = nil end
	local Data = { coroutine.yield({ ["Flag"] = "TuCoWa_Cycle", ["Filter"] = _sFilter }) }
	
	if Data[1] == "TuCoWa_Ask" then
		if type(uAnswer[1]) == "function" then coroutine.yield( uAnswer[1](Data) ) else coroutine.yield( unpack(uAnswer) ) end
		return coroutine.Cycle(uAnswer)
	else
		return unpack( Data )
	end
end
function coroutine.setFilter( _sId, _sFilter )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	if type(_sFilter) ~= "string" and type(_sFilter) ~= "nil" then return false, "Not valid Filter, expected string or nil" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_setFilter",
		["Id"] = _sId,
		["Filter"] = _sFilter,
	})
end
function coroutine.getFilter( _sId )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_getFilter",
		["Id"] = _sId,
	})
end
function coroutine.setName( _sId, _sName )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	if type(_sName) ~= "string" then return false, "Not valid Name, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_setName",
		["Id"] = _sId,
		["Name"] = _sName,
	})
end
function coroutine.getName( _sId )
	if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_getName",
		["Id"] = _sId,
	})
end
function coroutine.getThreads()
	return coroutine.yield({
		["Flag"] = "TuCoWa_getThreads"
	})
end
function coroutine.getThread( _sId )
	if type(_sId) ~= "string" and type(_sId) ~= "nil" then return false, "Not valid Id, expected string or nil" end
	return coroutine.yield({
		["Flag"] = "TuCoWa_getThread",
		["Id"] = _sId,
	})
end
function tucowa.UpdateLib( ... )
	return coroutine.yield({
		["Flag"] = "TuCoWa_updateLib",
		["List"] = { ... },
	})
end

coroutine.Manager( {
	["Name"] = "InitStart",
	["Id"] = Utils.GenUniqString(16),
	["Function"] = coroutine.create(InitStart),
	["Filter"] = nil,
	["Pause"] = 0,
	["Listen"] = false,
	["tArgSets"] = {},
	["lastArgSet"] = 0,
} )