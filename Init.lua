local term = require("term")
term.clear()

print("Setup:")
print("Enter the distance to chunk border")
local start = {x=0, z=0}
io.write("from the left(0-15): 0\n")
--start.x = tonumber(term.read())
io.write("from the back(0-15): 0\n")
--start.z = tonumber(term.read())

print("Initializing basic functions...")
local function getUid(group) -- Accept "string" for group, check database for uniq
	-- char(67) -- TODO need weak tables for uniqueness ... 65-90 capitals, 97-122 lowercase, 48-57 numbers (26+26+10=62)
	local uid = ""
	for i=0,16 do
		local ch = math.random(0,61)
		if ch < 26 then ch = ch + 65
		elseif ch < 52 then ch = ch + 97 - 26
		elseif ch < 62 then ch = ch + 48 - 26 - 26
		end
		uid = uid .. string.char(ch)
	end
	return uid
end

local MRC = {}
local oUids = {}
print("Initializing classes...")
local cls = {}
function cls.initiate(self, obj, ...)
  local obj = obj or {}
  local o = {}
  o.uid = getUid("object") -- UniqId of this object.
  o.birth = obj.birth or os.time()
  o.updated = os.time()
  o.group = nil
  o.substance = obj.substance or nil
  o.pos = obj.pos or nil
  o.parent = obj.parent or nil
  o.value = obj.value or nil
  
  o.profile = obj.profile or nil
  o.parts = obj.parts or nil
	o.size = obj.size or nil
	o.children = obj.children or nil
  o.flows = obj.flows or nil
  o.id = obj.id or nil
  o.meta = obj.meta or nil
	o.extra = obj.extra or nil
  o.capacity = obj.capacity or nil
  o.amount = obj.amount or nil
  o.slotId = obj.slotId or nil
  local checks = {...}
  for _,value in pairs(checks) do
    if type(value) ~= "table" then return pcall(checkArg, 2, type(value), "table") end
    local ok, err = pcall(checkArg, 1, obj[value[1]], table.unpack(value or {}, 2))
    if not ok then return false, err end 
  end
  setmetatable(o, self)
  self.__index = self
  oUids[o.uid] = o
  o.parent = o.parent
  if o.parent then -- exception for colony
    o.parent.children = o.parent.children or {}
    o.parent.children[o.uid] = o
  end
  return o
end
cls.prototype = { -- WiP!!!
	uid = nil,
	birth = nil,
	updated = nil,
	group = nil,
  substance = "unknown", -- "space" | "block" | "entity" | "item" | "fluid" | "xpjuice" | "energy"
	pos = nil,
	parent = MRC,
	value = 0,
  
  -- optional
  profile = false,
  parts = false,
	size = false,
	children = {},
  flows = false,
  id = false,
  meta = false,
	extra = false,
  capacity = false,
  amount = false,
  slotId = false,
  
  inherit = function(self, obj)
    local o = obj
    setmetatable(o, self)
    self.__index = self
    --if obj then for k,v in pairs(obj) do o[k]=v end end
    return o
  end
}
cls.colony = cls.prototype:inherit({
	group = "colony",
  substance = "space",
	parent = false, -- Colony object is the only one that has Parent = false
	extra = {
    ["player"] = {
      ["nick"] = "",
      ["pasteId"] = "",
    },
    ["research"] = {},
    ["espionage"] = {},
    ["military"] = {},
  },

  new = function(self, obj)
    return cls.initiate(self, obj
    )
  end,
})
cls.base = cls.prototype:inherit({
	group = "base",
  substance = "space",
  size = {9*16,9*16,255}, -- default to 9 chunks x 16 blocks (144x144), from bottom to sky
	extra = {
			["hasBrains"] = false,
      ["Upgrades"] = {},
			["isConnectedNorth"] = false,
			["isConnectedEast"] = false,
			["isConnectedSouth"] = false,
			["isConnectedWest"] = false,
	},
  
  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})
cls.farm = cls.prototype:inherit({ -- WiP!!!
	group = "farm",
  substance = "space",
	extra = {
    ["upgrades"] = {},
  },

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"},
      {"size", "table"}
    )
  end,
})
cls.robot = cls.prototype:inherit({ -- WiP!!!
	group = "robot",
	extra = {
  },

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})
cls.inventory = cls.prototype:inherit({ -- WiP!!!
	group = "inventory",

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})
cls.bag = cls.prototype:inherit({ -- WiP!!!
	group = "bag",

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})
cls.container = cls.prototype:inherit({ -- WiP!!!
	group = "container",

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})
cls.resource = cls.prototype:inherit({ -- WiP!!!
	group = "resource",

  new = function(self, obj)
    return cls.initiate(self, obj,
      {"pos", "table"}
    )
  end,
})

print("Initializing objects...")
MRC = cls.colony:new()
if MRC then print("  Colony initialized!") else print("  Colony failed!") end
local temp = cls.base:new({pos={-(4*16+start.x), -(4*16+start.z), 0}})
if temp then print("  Base initialized!") else print("  Base failed!") end 
if cls.robot:new({pos={start.x, start.z, 0, 0}, parent=temp}) then print("  Robot initialized!") else print("  Robot failed!") end

local function StartDownloaderGitHub()
  local term = require("term")
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
    for i = 2, x, 1 do term.write("-") end
    term.setCursorPos((x-title:len())/2,line+1)
    print(title)
    for i = 2, x, 1 do term.write("-") end
  end
  local function writeCenter( str )
    term.clear()
    printTitle()
    term.setCursorPos((x-str:len())/2-1,y/2-1)
    for i = -1, str:len(), 1 do term.write("-") end
    term.setCursorPos((x-str:len())/2-1,y/2)
    print("|"..str.."|")
    term.setCursorPos((x-str:len())/2-1,y/2+1)
    for i = -1, str:len(), 1 do term.write("-") end
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
        os.sleep(0)
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
    local content = internet.get(url)
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
      os.sleep(2)
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
    os.sleep(2,5)
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
    os.sleep(3)
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
  local term = require("term")
  local component = require("component")
  local fs = require("filesystem")
  local internet = require("internet")
  local shell = require("shell")
  local libNames = {
  "gui","rui","hud","logger","stats",
  "comm","utils","nav","jobs","resm",
  "logic","init","thread"
  }
  local pastebinIds = {
  --[[["Nam"] = {
  "Gui.....","Rui.....","Hud.....","Logger..","Stats...",
  "Comm....","Utils...","Nav.....","Jobs....","Resm....",
  "Logic...","Init....","thread.."},
  --]]
    ["Aku"] = {
  "EiNQu1tr","Vf4iEtwA","y9b6Vm0P","Yxhz7Gju","VeVb4816",
  "5kqCkMdY","VtBzt7BU","3AKpWFvr","AigXBa8F","TsMtkpDU",
  "FMsxxBSe","YqXAK4gf","dS1NHyRt"},
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
  local nick = MRC.extra.player.nick

  for i=1,select('#',...) do
    local tmp = select(i,...)
    if tmp == "start" then shell.execute("del dlc/pb/" .. nick) end
    for j=1,#libNames do
      if tmp == "start" or tmp == "all" or tmp == libNames[j] then
        term.write(libNames[j] .. ":") -- 39-8, 31-9, 22-8, 14-9, 5
        
        local cpx,cpy = term.getCursor()
        term.setCursor(8,cpy)
        fs.makeDirectory("dlc")
        fs.makeDirectory("dlc/pb") 
        fs.makeDirectory("dlc/pb/" .. nick)   
        local path = "dlc/pb/" .. nick .. "/"

        term.write("opening...")  
        cpx,cpy = term.getCursor()
        term.setCursor(cpx-string.len("opening..."), cpy)
        local f, reason = io.open(path .. libNames[j], "w")
        if f then
          term.write("open, ")  
          term.write("fetching...")
          cpx,cpy = term.getCursor()
          term.setCursor(cpx-string.len("fetching..."), cpy)
          local url = "http://pastebin.com/raw.php?i=" .. pastebinIds[nick][j]
          local result, response = pcall(internet.request, url)
          if result then
            term.write("fetched, ")
            term.write("writing...")
            cpx,cpy = term.getCursor()
            term.setCursor(cpx-string.len("writing..."), cpy)
            for chunk in response do f:write(chunk) end
            f:close()
            term.write("wrote, ")
            term.write("loading...")
            cpx,cpy = term.getCursor()
            term.setCursor(cpx-string.len("loading..."), cpy)
            local func, err = loadfile(path .. libNames[j] )
            if func then
              term.write("loaded, ")  
              term.write("executing...")
              --print(cpx,cpy)
              cpx,cpy = term.getCursor()
              term.setCursor(cpx-string.len("executing..."), cpy)
              local ok, result = pcall(func)
              if ok then 
                _ENV[libNames[j]] = result
                term.write("executed!   \n")
              else
                term.write("error at executing:\n" .. result .. "\n")
                --os.sleep(1)
              end
            else
              term.write("error at loading:\n" .. err .. "\n")
              --os.sleep(1)
            end          
          else
            f:close()
            fs.remove(path .. libNames[j])
            term.write("HTTP request failed:\n" .. response .. "\n")
            --os.sleep(1)
          end
        else
          term.write("\nFailed opening file for writing: " .. reason)
          --os.sleep(1)
        end
        
      end
    end
  end
end
local function start(source)
  local term = require("term")
  --local event = require("event")
  local computer = require("computer")
  --term.clear()
  print()
  print("Turtle Color Wars Downloader v1.0")
  print("Choose the source (press the key):")
  print()
  print("1 - GitHub")
  print("2 - Pastebin of Akuukis")
  print("3 - Pastebin of Alkerss")
  print("4 - Pastebin of moxxcrue")
  print("5 - Pastebin of Hekaya")
  print("6 - Pastebin of marchrime")
  if source then
    computer.pushSignal("key_down",nil,48+source,nil)
  end
  _,_,ascii,_ = coroutine.yield("key_down")
  if ascii == 48 + 1 then MRC.extra.player.nick = "Git"; StartDownloaderGitHub("start") 
  elseif ascii == 48 + 2 then MRC.extra.player.nick = "Aku"; StartDownloaderPastebin("start") 
  elseif ascii == 48 + 3 then MRC.extra.player.nick = "Alk"; StartDownloaderPastebin("start") 
  elseif ascii == 48 + 4 then MRC.extra.player.nick = "Mox"; StartDownloaderPastebin("start") 
  elseif ascii == 48 + 5 then MRC.extra.player.nick = "Hek"; StartDownloaderPastebin("start") 
  elseif ascii == 48 + 6 then MRC.extra.player.nick = "Mar"; StartDownloaderPastebin("start") 
  else start()
  end
end

--[[
local function updateLib(MRC.extra.player.nick, ... )
  if MRC.extra.player.nick == "Git" then StartDownloaderGitHub( ... )
  else StartDownloaderPastebin( MRC.extra.player.nick, ... )
  end
end
--]]
-------------------------------------------------------------------------------------------------------------------------------

print("Initialized Main!")
start(...)
--

thread.manager()


