local tArgs, gUser, gRepo, gPath, gBranch = {...}, nil, nil, "", "master"

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
function printTitle()
	local line = 2
	term.setCursorPos(1,line)
	for i = 2, x, 1 do write("-") end
	term.setCursorPos((x-title:len())/2,line+1)
	print(title)
	for i = 2, x, 1 do write("-") end
end

function writeCenter( str )
	term.clear()
	printTitle()
	term.setCursorPos((x-str:len())/2-1,y/2-1)
	for i = -1, str:len(), 1 do write("-") end
	term.setCursorPos((x-str:len())/2-1,y/2)
	print("|"..str.."|")
	term.setCursorPos((x-str:len())/2-1,y/2+1)
	for i = -1, str:len(), 1 do write("-") end
end
 
function printUsage()
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
function downloadFile( path, url, name )
	writeCenter("Downloading File: "..name)
	dirPath = path:gmatch('([%w%_%.% %-%+%,%;%:%*%#%=%/]+)/'..name..'$')()
	if dirPath ~= nil and not fs.isDir(dirPath) then fs.makeDir(dirPath) end
	local content = http.get(url)
	local file = fs.open(path,"w")
	file.write(content.readAll())
	file.close()
end

-- Get Directory Contents
function getGithubContents( path )
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
function isBlackListed( path )
	if blackList:gmatch("@"..path)() ~= nil then
		return true
	end
end

-- Download Manager
function downloadManager( path )
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
function main( path )
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
function parseInput( user, repo , dldir, path, branch )
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

function StartDownloaderGitHub()
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

-------------------------------------------------------------------------------------------------------------------------------
 
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

-------------------------------------------------------------------------------------------------------------------------------

function StartDownloaderPastebin( ... )
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
PastebinList = {}
ApiList = {
"Gui","Rui","Hud","Logger","Stats",
"Comm","Utils","Nav","Jobs","Resm",
"Logic","Init"
}
--[[ebinList["Nam"] = {
"Gui.....","Rui.....","Hud.....","Logger..","Stats...",
"Comm....","Utils...","Nav.....","Jobs....","Resm....",
"Logic...","Init....",}
--]]
PastebinList["Aku"] = {
"EiNQu1tr","Vf4iEtwA","y9b6Vm0P","Yxhz7Gju","VeVb4816",
"5kqCkMdY","VtBzt7BU","3AKpWFvr","AigXBa8F","TsMtkpDU",
"FMsxxBSe","YqXAK4gf",}
PastebinList["Alk"] = {
"4j3xkFqi","Nhde3VzW","zeJ6qg7L","yJ2TDrAC","W2x8HN2Z",
"de84SYF8","cf9SZvTb","HNAWHYUC","g75ryBk7","QpNgZqDk",
"URjcXVqp","Z2wLpHNw",}
PastebinList["Mox"] = {
"LCzvnrgm","yaz8QfNQ","EaH1rTcN","0jqNejLc","brF1SQX7",
"bpyKQrn4","Y9RjARM5","TbXnTHVs","sKRJw3YD","--------",
"jQizTuJd","--------",}
PastebinList["Hek"] = {
"sCCxs23y","cRPh5hK5","4B9wHmfB","eXUFfw98","buAi08ga",
"CaGGcpS3","0NP4EJcZ","Lvwz0A3b","mFFxtZUs","UmtZSab5",
"eru9yvdg","BNVW9D5u",}
PastebinList["Mar"] = {
"YwEvnNuv","VqYY94pE","a2pZzJhK","AyQ4RJRy","hTbMg1BG",
"VymxZieZ","gdL40bFx","0rFQyhKi","rz2BBebP","0xMDUvL0",
"3KZ9UcCK","D7mpfTqH",}


function Start()
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

function UpdateAPI( nick, ... )
	if nick == "Git" then StartDownloaderGitHub( ... )
	else StartDownloaderPastebin( nick, ... )
	end
end

-------------------------------------------------------------------------------------------------------------------------------

--[[ coroutine.resume Returns:
	1. boolean Ok: true if its ok, false if coroutine error()
	2. string Filter/ErrorMsg/: if Ok=true Filter is event name (may be nil=no filter), if Ok=false then ErrorMsg is error message.
	[3. function Call: if coroutine wants to start another coroutine it will return _Call
	 4. boolean noYield: true if coroutine wants to continue without waiting to other coroutines
	 [5. table Args: Args to be passed to Call ] ]
--]]

-- Warning: functions like: read(), sleep() etc. empty the event stack and you will not be able to pull the event after that


print("Initialized Main!")
TheColony = { "Emptyness" }
Start()
--



function CycleCoroutine( _Thread )

end

local tThreads = {}
local EventData = {"TuCoWa_dummy"}

-- The First coroutine
local lastThread = 1
local firstThread = 1
tThreads[lastThread] = {
	["Name"] = "InitStart",
	["Id"] = Utils.GenUniqString(16),
	["Function"] = coroutine.create(InitStart),
	["Filter"] = nil,
	["tArgSets"] = {},
	["lastArgSet"] = 0,
}

local Focus = firstThread
while lastThread > 0 do  -- Run until no coroutines left (won't happen normally)
	
	--Logger.Debug("Thread %s/%s (%s,%s)", Focus, lastThread ,EventData[1], EventData[2])
	if type(tThreads[Focus]) == "table" then
		--Logger.Debug("..")
		tThreads[Focus].tArgSets[ tThreads[Focus].lastArgSet+1 ] = EventData
		tThreads[Focus].lastArgSet = tThreads[Focus].lastArgSet + 1
		
		local i = 1
		while i <= tThreads[Focus].lastArgSet do
		
			--Logger.Debug("i=%s..",i)
			local isOk, tArgs = coroutine.resume( tThreads[Focus].Function, unpack(tThreads[Focus].tArgSets[i] or {}) )
			
			tThreads[Focus].tArgSets[i] = nil
			if coroutine.status(tThreads[Focus].Function) == "dead" then tThreads[Focus] = nil end
			
			if not isOk then 
				Logger.Error("Coroutine failed! %s\n", tArgs )
			else
				if tArgs and type(tArgs) == "string" then 
					tThreads[Focus].Filter = tArgs
				elseif tArgs and type(tArgs) == "table" then
					if tArgs.Flag and tArgs.Flag == "TuCoWa_Call" then
						local Target
						if type(tArgs.Function) == "function" then Target = tArgs.Function else Target = loadstring(tArgs.Function) end
						--Logger.Debug("%s..", Target)
						if not Target then Logger.Error("Failed to loadstring! %s",tArgs.Function)
						else
							--Logger.Debug("4..")
							Target = coroutine.create(Target)
							if type(Target) ~= "thread" then 
								Logger.Error("Failed to create coroutine! %s",tArgs.Function)
							else
								--Logger.Debug("5..")
								tThreads[ lastThread+1 ] = {}
								tThreads[ lastThread+1 ].Name = tArgs.Name or "Anonymous"
								tThreads[ lastThread+1 ].Filter = tArgs.Filter or nil
								tThreads[ lastThread+1 ].tArgSets = {}
								tThreads[ lastThread+1 ].tArgSets[1] = tArgs.Args or nil
								if tArgs.Args then tThreads[ lastThread+1 ].lastArgSet = 1 else tThreads[ lastThread+1 ].lastArgSet = 0 end
								tThreads[ lastThread+1 ].Id = Utils.GenUniqString(16)
								tThreads[ lastThread+1 ].Function = Target
								tThreads[Focus].tArgSets[i] = { tThreads[ lastThread+1 ].Id }
								lastThread = lastThread + 1
							end
						end
						os.queueEvent("TuCoWa_dummy")
					elseif tArgs.Flag and tArgs.Flag == "TuCoWa_Send" then 
						-- TODO
					elseif tArgs.Flag and tArgs.Flag == "TuCoWa_Stop" or tArgs.Flag == "TuCoWa_Kill" then
						-- TODO
					elseif tArgs.Flag and tArgs.Flag == "TuCoWa_UpdateLib" then
						UpdateAPI(unpack(tArgs or {}))
						os.queueEvent("TuCoWa_dummy")
					else	
						--os.queueEvent("dummy", unpack(tArgs or {}))
					end
				end
			end
			
			if not tThreads[Focus] then break end
			if tThreads[Focus].tArgSets[i] == nil then i = i + 1 end
		end

		if tThreads[Focus] then tThreads[Focus].lastArgSet = 0 end
		
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
Logger.Check("Out-of-coroutines!\n")
