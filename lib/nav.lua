local robot = require("robot")
local computer = require("computer")
local component = require("component") -- TODO remove
local clsNav = {}
clsNav.title = "Navigation Library"
clsNav.shortTitle = "nav"
clsNav.version = 0.9000
function clsNav:new(oldObject)
  local object
  if oldObject
    and type(oldObject.title) == "string"
    and oldObject.title == self.title
    and type(oldObject.title) == "number"
    and oldObject.version <= self.version
  then
    object = oldObject
  else
    object = {}
  end
  setmetatable(object, self)
  self.__index = self
  return object
end

---------------- Dependencies -------------------------------------------------
local logger = logger or {}
if not logger.fatal then 
  logger.fatal = function (...) io.write(string.format(...)) end
end
if not logger.warning then 
    logger.warning = function (...) io.write(string.format(...)) end
end
if not logger.info then 
    logger.info = function (...) io.write(string.format(...)) end
end
if not logger.spam then 
    --local fs = require("filesystem")
    --fs.makeDirectory("logs")
    logger.spam = function (...)
    --  local file = fs.open("logs/test.log","a")
    --  file:write(string.format(...))
    --  file:close()
      io.write(string.format(...)) 
    end
end
local utils = utils or {}
if not utils.deepCopy then 
  function utils.deepCopy(t)
    -- Credits to MihailJP @ https://gist.github.com/MihailJP/3931841
    if type(t) ~= "table" then return t end
    --local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
      if type(v) == "table" then
        target[k] = utils.deepCopy(v)
      else
        target[k] = v
      end
    end
    --setmetatable(target, meta)
    return target
  end
end
if not utils.deepMerge then 
  function utils.deepMerge(t1, t2) -- merges t1 over t2
    if type(t1) ~= "table" then return t1 end
    --local meta1 = getmetatable(t1)
    local target = utils.deepCopy(t2)
    for k, v in pairs(t1) do
        if (type(v) == "table") and (type(target[k] or false) == "table") then
            utils.deepMerge(target[k], t1[k])
        else
            target[k] = v
        end
    end
    --setmetatable(target, meta1)
    return target
  end
end
if not utils.freeMemory then 
  function utils.freeMemory()
    local result = 0
    for i = 1, 10 do
      result = math.max(result, computer.freeMemory())
      os.sleep(0)
    end
    return result
  end
end
local thread = thread or {}
if not thread.yield then thread.yield = function() os.sleep() end end

---------------- Local variables ----------------------------------------------
local mapGrid = {
  {"A","B","C","D","E",},
  {"F","G","H","I","J",},
  {"K","L","M","N","O",},
  {"P","Q","R","S","T",},
  {"U","V","W","X","Y",},
}
local mapMaxDepth = 1

---------------- Local functions ----------------------------------------------
local function checkOptions(unknowns, ...)
	local wishlist = {...}
	if type(unknowns) ~= "table" then unknowns = {unknowns} end 
  for _,wish in pairs(wishlist) do 
    if type(wish) == "string" then 
      for _,unknown in pairs(unknowns) do
        if type(unknown) == "string" and wish == unknown then return unknown end
      end
    end
  end
  return false
end
local function checkPos(unknown)
  if type(unknown) ~= "table" then return false end
  if
    type(unknown.x) == "number"
    and type(unknown.y) == "number"
    and type(unknown.z) == "number"
  then
    return {
      x = unknown.x,
      y = unknown.y,
      z = unknown.z,
      f = (type(unknown.f) == "number" and unknown.f) or nil,
      weight = (type(unknown.weight) == "number" and unknown.f) or nil,
    }
  elseif 
    type(unknown[1]) == "number"
    and type(unknown[2]) == "number"
    and type(unknown[3]) == "number"
  then
    return {
      x = unknown[1],
      y = unknown[2],
      z = unknown[3],
      f = (type(unknown[4]) == "number" and unknown[4]) or nil,
      weight = (type(unknown[5]) == "number" and unknown[5]) or nil,
    }
  end
  return false
end
local function checkPositions(unknown)
  if type(unknown) ~= "table" then return false end
  local positions = {}
	if checkPos(unknown) then positions[#positions+1] = checkPos(unknown) end
  for k,v in pairs(unknown) do
    local pos = checkPos(v)
    if pos then
      positions[#positions+1] = pos
    end
  end
  if #positions > 0 then
    return positions
  else
    return false
  end
end

---------------- Object variables ---------------------------------------------
clsNav.pos = {
	x = 0, -- North
	z = 0, -- East
	y = 0, -- Height
	f = 0, -- Facing direction, modulus of 4 // 0,1,2,3 = North, East, South, West
}
clsNav.map = {
  _initialized = os.time(),
	_updated = os.time(),
  _maxDepth = 1,
}

---------------- Methods ------------------------------------------------------
function clsNav:getVersion()
	return self.version
	end
function clsNav:getMapFromPos(pos)
  pos = checkPos(pos)
  if not pos then return false end
  local chunkName = ""
  local chunkX = (pos.x-pos.x%16)/16
  local chunkY = -(pos.y-pos.y%16)/16 -- invert so that (-1,-1) is at bottom left, NOT up left
  local power = 1
  while chunkX > 0 or chunkY > 0 or self.map._maxDepth > #chunkName do
    local gridX = (chunkX+2)%5-2
    local gridY = (chunkY+2)%5-2
    chunkX = (chunkX+2 - (chunkX+2)%5)/5
    chunkY = (chunkY+2 - (chunkY+2)%5)/5
    chunkName = mapGrid[gridY+3][gridX+3]..chunkName
  end
  self.map._maxDepth = math.max(self.map._maxDepth, #chunkName)
  local posNo = 10000*pos.z + 100*pos.x + pos.y
  return chunkName, posNo
end
function clsNav:putMap(pos, value)
  if type(value) ~= "table" then return false end -- to delete do putMap(pos,{})
  local chunkName, posNo = self:getMapFromPos(pos)
  if (not chunkName) or (not posNo) then return false end
  
  if not self.map[chunkName] then
    -- check for filesystem files, otherwise...    
    self.map[chunkName] = {}
  end
    
  if not self.map[chunkName][posNo] then self.map[chunkName][posNo] = {} end
  
  self.map._updated = os.time()
  self.map[chunkName]._accessed = os.time()
  self.map[chunkName]._updated = os.time()
  value._updated = os.time()
  self.map[chunkName][posNo] = utils.deepMerge(value, self.map[chunkName][posNo])
  return true
end
function clsNav:setPos(pos_or_face)
  --logger.spam("Nav:setPos(%s)\n",pos_or_face)
  pos = checkPos(pos_or_face) 
  if pos then
    self.pos = pos
  else
    self.pos = self:getPos(pos_or_face)
  end
end
function clsNav:comparePos(poslist1,poslist2,isFaced) -- input either pos or tables of pos
  poslist1 = checkPositions(poslist1)
  if type(poslist1) ~= "table" then return false, 123, "comparePos: No legal pos in argument #1" end
  poslist2 = checkPositions(poslist2)
  if type(poslist2) ~= "table" then return false, 123, "comparePos: No legal pos in argument #2" end
  
	for i,pos1 in pairs(poslist1) do
		--logger.spam("Pos1(%s): %s,%s,%s,%s\n", i, Pos1.x, Pos1.z, Pos1.y, Pos1.f)
    for j,pos2 in pairs(poslist2) do
      --logger.spam("  Pos2(%s): %s,%s,%s,%s\n", j, Pos2.x, Pos2.z, Pos2.y, Pos2.f)
      if 
        pos1.x == pos2.x
        and pos1.y == pos2.y
        and pos1.z == pos2.z
      then 
        if
          (isFaced
          and pos1.f
          and pos2.f
          and pos1.f == pos2.f)
          or 
          (not isFaced)
        then
          return pos1, pos2
        end
      end
		end
  end
  
	return false
end
function clsNav:getPos(pos, dir) -- Input Position (table), FacingDirection (num) in any order
  if type(dir) == "nil" and type(pos) == "number" then
    dir = pos%6
    pos = nil
	elseif type(dir) == "number" then
    dir = dir%6
  else 
    dir = nil 
  end
  pos = checkPos(pos or self.pos) 
  if not pos then return false, "Failed to lookup pos" end
  	
	if dir == nil then return pos
	elseif dir == 0 then return {["x"] = pos.x+1, ["y"] = pos.y, ["z"] = pos.z, ["f"] = dir}
	elseif dir == 1 then return {["x"] = pos.x, ["y"] = pos.y+1, ["z"] = pos.z, ["f"] = dir}
	elseif dir == 2 then return {["x"] = pos.x-1, ["y"] = pos.y, ["z"] = pos.z, ["f"] = dir}
	elseif dir == 3 then return {["x"] = pos.x, ["y"] = pos.y-1, ["z"] = pos.z, ["f"] = dir}
	elseif dir == 4 then return {["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z+1, ["f"] = pos.f}
	elseif dir == 5 then return {["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z-1, ["f"] = pos.f}
	end
	
	return false
end
function clsNav:getMap(pos)
  local chunkName, posNo = self:getMapFromPos(pos)
  if (not chunkName) or (not posNo) then return false, "Bad arguments" end
  
  if not self.map[chunkName] then
    -- check for filesystem files, otherwise...    
    return {}
  end
  
  if not self.map[chunkName][posNo] then return {} end
  
  self.map[chunkName]._accessed = os.time()
  return utils.deepCopy(self.map[chunkName][posNo])
end
function clsNav:detectAround() -- TODO: add other detections, repair tagging
	--logger.Check("detectAround:%s,%s",location,value)
  local _,substance = robot.detect()
  self:putMap(self:getPos(self:getPos().f),{["substance"]=substance})
  _,substance = robot.detectUp()
  self:putMap(self:getPos(4),{["substance"]=substance})
  _,substance = robot.detectDown()
  self:putMap(self:getPos(5),{["substance"]=substance})
end
function clsNav:getPath(targets, options)
	--This code (Aug, 2014) is written by Akuukis 
	--	who based on code (Sep 21, 2006) by Altair
	--		who ported and upgraded code of LMelior
  
  local options = options or {}
  local upvalues = {} -- upvalue, anti-crashing mechanism
  local pathtries = 3
  local function serializePos(pos)
    return string.format("%05s",pos.x)..string.format("%05s",pos.y)..string.format("%03s",pos.z)
  end
  local function getHeuristic(startPos, targetPoslist, flag)
    local minCost = math.huge
    for _,targetPos in pairs(targetPoslist) do
      if flag == "manhattan" then
        minCost = math.min(minCost, 1 * (
          (targetPos.pathWeight or 0) +
          math.abs(startPos.x-targetPos.x) + 
          math.abs(startPos.y-targetPos.y) + 
          math.abs(startPos.z-targetPos.z) )
        )
      elseif flag == "euclidean" then
        minCost = math.min(minCost, (targetPos.pathWeight or 0) + math.abs((
          math.abs(startPos.x-targetPos.x) + 
          math.abs(startPos.y-targetPos.y) + 
          math.abs(startPos.z-targetPos.z) ) ^ (1/3) )
        )
      else -- manhattan
        minCost = math.min(minCost, 1 * (
          (targetPos.pathWeight or 0) +
          math.abs(startPos.x-targetPos.x) + 
          math.abs(startPos.y-targetPos.y) + 
          math.abs(startPos.z-targetPos.z) )
        )
      end
    end
    if minCost ~= math.huge then return minCost else error(debug.traceback()) end
  end
  local function getCostBlocks(nextBase, flag)
    local defaultMoveCost = 1 -- cost in time to move 1 square, no diagonal movement.
    local defaultWanderCost = 1 -- average cost to move in unexplored block
    local defaultDestroyCost = 3 -- average cost in time to move 1 square with solid block inside
    if nextBase.substance == "air" then
      if flag == "careful" then
        return defaultMoveCost
      elseif flag == "normal" then 
        return defaultMoveCost
      elseif flag == "simple" then
        return defaultMoveCost
      elseif flag == "brutal" then
        return defaultMoveCost
      end
    elseif nextBase.substance == "replaceable" then
      if flag == "careful" then
        return defaultMoveCost
      elseif flag == "normal" then 
        return defaultMoveCost
      elseif flag == "simple" then
        return defaultMoveCost
      elseif flag == "brutal" then
        return defaultMoveCost
      end
    elseif nextBase.substance == "solid" then
      if flag == "careful" then
        return false
      elseif flag == "normal" then 
        return defaultDestroyCost
      elseif flag == "simple" then
        return defaultMoveCost
      elseif flag == "brutal" then
        return defaultMoveCost
      end
    elseif nextBase.substance == "liquid" then
      if flag == "careful" then
        return false
      elseif flag == "normal" then 
        return defaultDestroyCost
      elseif flag == "simple" then
        return defaultMoveCost
      elseif flag == "brutal" then
        return defaultDestroyCost
      end
    elseif nextBase.substance == "entity" then
      if flag == "careful" then
        return defaultMoveCost
      elseif flag == "normal" then 
        return defaultMoveCost
      elseif flag == "simple" then
        return defaultMoveCost
      elseif flag == "brutal" then
        return defaultMoveCost
      end
    else
      return defaultWanderCost
    end
  end
  local function getCostTurn(curBase, dir, flag)
    if flag == "simple" then return 0 end
    local defaultTurnCost = 0.9 -- cost in time to turn 90 degrees
    local turnCost = 0
    if (not curBase.f) or curBase.f == dir or dir == 4 or dir == 5 then 
      return 0
    elseif (dir-curBase.f)%4 == 2 then 
      return 2 * defaultTurnCost
    else 
      return 1 * defaultTurnCost 
    end
  end
  local function getModTags(nextBase, flag)
    local defaultRoadMod = 0.1 -- cost modifier for moving along roads
    if nextBase.tag then
      if flag == "careful" or flag == "normal" then
        if nextBase.tag.evade then
          return false
        elseif nextBase.tag.road then
          return defaultRoadMod
        end
      elseif flag == "simple" then
        if nextBase.tag.evade then
          return false
        end
      elseif flag == "brutal" then
        -- ignore tags
      end
    end
    return 1
  end
  local function tryPath(starts, targets, options)
  
    starts = checkPositions(starts)
    if (not starts) or (not next(starts)) then return false, "No legal start provided" end
    --for k,v in pairs(starts) do 
    --  logger.spam("tryPath: Start %s/%s (%2s,%2s,%2s,%2s,%2s)\n", k,#starts,v.x,v.y,v.z,v.f,v.weight)
    --end
    targets = checkPositions(targets)
    if (not targets) or (not next(targets)) then return false, "No legal target provided" end
    --for k,v in pairs(targets) do 
    --  logger.spam("tryPath: Target %s/%s (%2s,%2s,%2s,%2s,%2s)\n", k,#targets,v.x,v.y,v.z,v.f,v.weight)
    --end
    
    local defaultHeurMod = 1 -- cost modifier for heuristics. Keep it big enough!
    local flag = checkOptions(options, "careful", "normal", "simple", "brutal") or "careful"
    local flag2 = checkOptions(options, "manhattan", "euclidean") or "manhattan"
    local flag3 = checkOptions(options, "forwards", "backwards", "bidirectional") or "bidirectional"
    --for k,v in pairs(options) do 
    --  logger.spam("tryPath: Option %s/%s %s\n", k,#options,v)
    --end
    
    logger.info("Pathfinding: %s starts, %s targets, %s options.\n",#starts,#targets,#options + ((options._path and 1) or 0))
    
    options = nil
    local SCL, SNL, SOL, TCL, TNL, TOL = {}, {}, {min={weight=math.huge}}, {}, {}, {min={weight=math.huge}}
    for i=1,#starts do
      local key = serializePos(starts[i])
      if not SNL[key] then 
        local nextBase = self:getMap(starts[i])
        local costBlocks = getCostBlocks(nextBase, flag)
        local modTag = getModTags(nextBase, flag)
        if costBlocks and modTag then
          SNL[key] = starts[i] -- x,y,z,f
          SNL[key].pathWeight = (SNL[key].weight or 0) + costBlocks * modTag
          SNL[key].heurWeight = getHeuristic(starts[i], targets, flag2) * defaultHeurMod
          SNL[key].weight = SNL[key].pathWeight + SNL[key].heurWeight
          SNL[key].parent = false
          SNL.min = SNL.min or {}
          SNL.min.weight = math.min(SNL.min.weight or math.huge, SNL[key].weight)
        end
      end
    end
    for i=1,#targets do
      local key = serializePos(targets[i])
      if not TNL[key] then 
        local nextBase = self:getMap(targets[i])
        local costBlocks = getCostBlocks(nextBase, flag)
        local modTag = getModTags(nextBase, flag)
        if costBlocks and modTag then
          TNL[key] = targets[i] -- x,y,z,f
          TNL[key].pathWeight = (TNL[key].weight or 0) + costBlocks * modTag
          TNL[key].heurWeight = getHeuristic(targets[i], starts, flag2) * defaultHeurMod
          TNL[key].weight = TNL[key].pathWeight + TNL[key].heurWeight
          TNL[key].parent = false
          TNL.min = TNL.min or {}
          TNL.min.weight = math.min(TNL.min.weight or math.huge, TNL[key].weight)
        end
      end
    end
    
    if (not starts) or (not next(starts)) then return false, "No legal start left, all filtered" end
    if (not targets) or (not next(targets)) then return false, "No legal target left, all filtered" end
    logger.info("Searching.")
    
    local side = false
    local closedk = 0
    local timer = os.time()
    while true do
      
      if flag3 == "forwards" then
        side = true
      elseif flag3 == "backwards" then
        side = false
      elseif flag3 == "bidirectional" then
        side = not side -- switch sides
      end
      
      local openlist = (side and SOL) or TOL
      local openlistNew = (side and SNL) or TNL
      local closedlist = (side and SCL) or TCL
      local targetlist = (side and {TCL.last, table.unpack(targets)}) or {SCL.last, table.unpack(starts)}
      
      local temp1, temp2 = openlist.min, openlistNew.min
      openlist.min, openlistNew.min = nil, nil
      if (not next(openlist)) and (not next(openlistNew)) then return false, "trapped in box or illegal targets" end -- trapped in box, cannot find path
      openlist.min, openlistNew.min = temp1, temp2
      
      do  -- Find next node with the lowest weight (Prefer newer nodes)
        local searchlist = (openlist.min.weight < openlistNew.min.weight and openlist) or openlistNew
        local lowestDS = math.huge
        searchlist.min.weight = math.huge
        local basis = nil
        for k,node in pairs(searchlist) do
          if (node.weight or math.huge) < searchlist.min.weight then
            if node.weight < lowestDS then
              searchlist.min.weight = lowestDS
              lowestDS = node.weight
              basis = k
            else
              searchlist.min.weight = node.weight 
            end
          end
        end
        closedlist[basis] = searchlist[basis]
        closedlist[basis].key = basis
        closedlist.last = closedlist[basis]
        closedk = closedk + 1
        searchlist[basis] = nil
        for k,node in pairs(openlistNew) do 
          if k ~= "min" then 
            openlist[k] = node
            openlistNew[k] = nil
          else 
            openlist.min.weight = math.min(node.weight,openlist.min.weight)
            openlistNew.min.weight = math.huge
          end
        end
      end
      local curBase = closedlist.last

      if closedk%25==0 then logger.info(".") end
        -- logger.spam("%s %0s: %4s,%2s,%2s %3s+%4s=%4s ",
          -- (side and "=>") or "<=",
          -- closedk,
          -- curBase.x,
          -- curBase.y,
          -- curBase.z,
          -- math.floor(curBase.pathWeight*10)/10,
          -- math.floor(curBase.heurWeight*10)/10,
          -- math.floor((curBase.weight)*10)/10
          -- --self:getMap(self:getPos(curBase)).substance
          -- --utils.freeMemory() --GC!
        -- )
      
      if self:comparePos(curBase,targetlist,false) then -- check if we have reached one of targetlist..
        SOL, TOL, SNL, TNL, openlist, openlistNew, targetlist = nil, nil, nil, nil, nil, nil, nil -- free some RAM
        
        local startlist, endlist = SCL, TCL
        local startBase, endBase = nil, nil
        for k,target in pairs(startlist) do 
          if self:comparePos(curBase,target,false) then startBase = target end
        end
        for k,target in pairs(endlist) do 
          if self:comparePos(curBase,target,false) then endBase = target end
        end
        
        if 
          ((not startBase) or startBase.parent == false)
          and ((not endBase) or endBase.parent == false) 
        then return {}, {}, 0 end -- if we started at target
        
        local function extractPath(list,base)
          if not base then return {} end
          local path = {[1] = base} 
          --logger.spam("(%s,%s,%s|%s)",base.x,base.y,base.z,base.parent)
          while path[#path].parent do
            path[#path+1] = list[path[#path].parent]
            list[path[#path-1].parent] = nil
            --logger.spam("(%s,%s,%s|%s)",path[#path].x,path[#path].y,path[#path].z,path[#path].parent)
            if #path%100==0 then thread.yield() end
          end
          --logger.spam("\n")
          return path
        end
        
        local startPath = extractPath(startlist, startBase) -- backwards
        local endPath = extractPath(endlist, endBase) -- backwards
        
        local path = {}
        for i=1,#startPath do path[#path+1] = startPath[#startPath-i+1] end
        path[#path]=nil
        for i=1,#endPath do path[#path+1] = endPath[i] end
        
        -- Change list of XZ coordinates into a list of directions 
        --logger.spam("dirPath. ")
        thread.yield()
        local dirPath = {}
        for i=1,#path-1 do
          if path[i+1].x > path[i].x then dirPath[i]=0 -- North
          elseif path[i+1].y > path[i].y then dirPath[i]=1 -- East
          elseif path[i+1].x < path[i].x then dirPath[i]=2 -- South
          elseif path[i+1].y < path[i].y then dirPath[i]=3 -- West
          elseif path[i+1].z > path[i].z then dirPath[i]=4 -- Up
          elseif path[i+1].z < path[i].z then dirPath[i]=5 -- Down
          end
          --logger.spam("%s,", dirPath[i])
        end
        --logger.spam("\n")
        return dirPath, path
      end  
      
      for dir=0,5 do
        local nextPos = self:getPos(curBase,dir)
        local nextKey = serializePos(nextPos)
        if not closedlist[nextKey] then 
          local nextBase = self:getMap(nextPos)
          local costBlocks = getCostBlocks(nextBase, flag)
          local costTurn = getCostTurn(curBase, dir, flag)
          local modTag = getModTags(nextBase, flag)
          if costBlocks and costTurn and modTag then
            openlistNew[nextKey] = nextPos -- x,y,z,f
            openlistNew[nextKey].pathWeight = curBase.pathWeight + (costBlocks + costTurn) * modTag
            openlistNew[nextKey].heurWeight = getHeuristic(nextPos, targetlist, flag2) * defaultHeurMod
            openlistNew[nextKey].weight = openlistNew[nextKey].pathWeight + openlistNew[nextKey].heurWeight
            if openlist[nextKey] and openlist[nextKey].weight < openlistNew[nextKey].weight then
              openlistNew[nextKey] = nil
            else
              openlist[nextKey] = nil
              openlistNew[nextKey].parent = curBase.key
              openlistNew.min.weight = math.min(openlistNew.min.weight or math.huge, openlistNew[nextKey].weight)
            end
          end
        end
      end

      do  -- find lowest weight for closedlist to add as lastTarget
        local lowestDS = curBase.weight or math.huge
        local lowestHeurWeight = curBase.heurWeight or math.huge
        local basis = "last"
        for k,node in pairs(closedlist) do
          if (node.weight or math.huge) < lowestDS then
            lowestDS = node.weight
            basis = k
          end
          if (node.heurWeight or math.huge) < lowestHeurWeight then
            lowestHeurWeight = node.heurWeight
          end
        end
        if side then
          upvalues.starts = {closedlist[basis], curBase}
        else
          upvalues.targets = {closedlist[basis], curBase}
        end
        upvalues.minHeurWeight = math.min(upvalues.minHeurWeight or math.huge, lowestHeurWeight)
        upvalues.cycles = (upvalues.cycles or 0) + 1
      end
      
      thread.yield()
    end
    return false
  end
  local oldUpvalues = {starts={},targets={},minHeurWeight=math.huge}
  
  repeat
        
    local ok, dirPath, path = pcall(
      tryPath,
      utils.deepCopy(upvalues.starts or {self:getPos()}),
      utils.deepCopy(upvalues.targets or targets),
      options
    )
    logger.info("\n")
    
    if ok then
      if not dirPath then
        return false, path -- error
      elseif self:comparePos(path[1],self:getPos(),false) then
        if self:comparePos(path[#path],targets,false) then
          return dirPath, path, true, upvalues.cycles -- full path
        else
          return dirPath, path, false, upvalues.cycles -- partial path
        end
      else
        logger.spam("Found another start: %s,%s,%s,%s\n",path[1].x,path[1].y,path[1].z,path[1].f)
        targets = path[1] -- search to new target that leads to real target
        upvalues.starts = nil
        pathtries = 3
        options._path = nil
      end
    else
      logger.spam("Searching failed: %s\n",dirPath)
    end
    
    if pathtries == 3 then
      logger.spam("Retry with 'backwards'\n")
      pathtries = pathtries - 1
      options._path = "backwards"
    elseif pathtries == 2 then
      if upvalues.minHeurWeight < oldUpvalues.minHeurWeight then
        logger.spam("Continue with 'backwards' %s/%s\n",upvalues.minHeurWeight,oldUpvalues.minHeurWeight)
        oldUpvalues.minHeurWeight = upvalues.minHeurWeight
      else
        logger.spam("Retry with 'forwards'\n")
        pathtries = pathtries - 1
        options._path = "forwards"
      end
    elseif pathtries == 1 then
      if upvalues.minHeurWeight < oldUpvalues.minHeurWeight then
        logger.spam("Continue with 'forwards' %s/%s\n",upvalues.minHeurWeight,oldUpvalues.minHeurWeight)
        oldUpvalues.minHeurWeight = upvalues.minHeurWeight
      else
        logger.spam("Retry with 'bidirectional'\n")
        pathtries = pathtries - 1
        options._path = "bidirectional"
      end
    elseif pathtries == 0 then
      if upvalues.minHeurWeight < oldUpvalues.minHeurWeight then
        logger.spam("Continue with 'bidirectional' %s/%s\n",upvalues.minHeurWeight,oldUpvalues.minHeurWeight)
        oldUpvalues.minHeurWeight = upvalues.minHeurWeight
      else
        logger.spam("lastTargets %s at (%s,%s,%s)\n",lastTargets, lastTargets and lastTargets.x, lastTargets and lastTargets.y, lastTargets and lastTargets.z)
        return false
      end
    end
    
    thread.yield()
  until pathtries < 0
  
  
end
function clsNav:move(dir, options) -- dir={0=North|1=East|2=South|3=West|4=up|5=down}, returns true if succeeded

  local flag = checkOptions(options, "careful", "normal", "simple", "brutal") or "careful"
  local flag2 = checkOptions(options, "fast", "explore", "patrol") or "explore"
  
	if not self:turnTo(dir) then return false, "no dir provided" end
  for dir=0,3 do -- look around
    if
      (flag2 == "patrol") or
      (flag2 == "explore" and not self:getMap(self:getPos(dir))._updated)
    then
      self:turnTo(dir)
    end
  end
	if dir ~= self:getPos().f then self:turnTo(dir) end
  
	if flag == "careful" or flag == "normal" or flag == "simple" then
    local pos = self:getMap(self:getPos(dir))
    if pos and pos.tag then
      return false, "Tagged as "..pos.tag
    end
  end
    
	if flag == "careful" then
    local substance
    if dir == 4 then _, substance = robot.detectUp()
    elseif dir == 5 then _, substance = robot.detectDown()
    else _, substance = robot.detect()
    end
    if substance ~= "air" and substance ~= "replaceable" then return false, substance end
  end
  
  local ok, reason
  if dir == 4 then 
    while flag ~= "careful" and robot.detectUp() do robot.swingUp() end
    ok, reason = robot.up()
  elseif dir == 5 then
    while flag ~= "careful" and robot.detectDown() do robot.swingDown() end
      ok, reason = robot.down()
  else 
    while flag ~= "careful" and robot.detect() do robot.swing() end
    ok, reason = robot.forward()
  end
  if ok then
    self:setPos(dir)
    self:detectAround()
    --logger.spam("Nav.Move() Return true\n")
    return true
	else
    return false, reason
	end
	return false, "Unexpected error"
end

-- Core methods
function clsNav:turnRight()
	robot.turnRight()
	--logger.spam("Nav.turnRight() Nav.Pos.f. %s => ",self:getPos().f)
	self.pos.f = (self:getPos().f+1)%4
	--logger.spam("%s\n",self:getPos().f)
	self:detectAround()
	return true
end
function clsNav:turnLeft()
	robot.turnLeft()
	--logger.spam("Nav:turnLeft() Nav.Pos.f. %s => ",self:getPos().f)
	self.pos.f = (self:getPos().f+3)%4
	--logger.spam("%s\n",self:getPos().f)
	self:detectAround()
	return true
end
function clsNav:turnAround()
	if 1==math.floor(math.random(0,1)+0.5) then
		self:turnRight()
		self:turnRight()
	else
		self:turnLeft()
		self:turnLeft()
	end
	return true
end
function clsNav:go(targets, options) -- table target1 [, table target2 ...] text option1 [, text option2 ...]
	
  local timer = os.time()
  targets = checkPositions(targets) -- Filters legal targets
  if (not targets) or (not next(targets)) then targets = {checkPos({0,0,0,0})} end
  
	local flag = checkOptions(options, "absolute", "relative", "relFace") or "absolute"
	if flag == "relative" then
		for j in ipairs(targets) do
			targets[j].x = targets[j].x + self:getPos().x
			targets[j].y = targets[j].y + self:getPos().y
			targets[j].z = targets[j].z + self:getPos().z
		end
	end
	if flag == "relFace" then
		for j in ipairs(targets) do
			targets[j].x = targets[j].x + self:getPos().x
			targets[j].y = targets[j].y + self:getPos().y
			targets[j].z = targets[j].z + self:getPos().z
			if self:getPos().f == 0 then targets[j].x = self:getPos().x + targets[j].x; targets[j].y = self:getPos().y + targets[j].y end
			if self:getPos().f == 1 then targets[j].x = self:getPos().x - targets[j].y; targets[j].y = self:getPos().y + targets[j].x end
			if self:getPos().f == 2 then targets[j].x = self:getPos().x - targets[j].x; targets[j].y = self:getPos().y - targets[j].y end
			if self:getPos().f == 3 then targets[j].x = self:getPos().x + targets[j].y; targets[j].y = self:getPos().y - targets[j].x end
		end
	end
	
	local tries = 2 -- TODO
  local count = 0
	--if #targets > 0 then logger.spam("Nav.Go(x%s)(%s,%s,%s)\n", #targets, targets[1].x, targets[1].z, targets[1].y) end
	while tries <= 2 do
    count = count + 1
    logger.info("Go: Try No.%s, (%2s,%2s,%2s,%2s) -> ...\n", 
      count,self:getPos().x,self:getPos().y,self:getPos().z,self:getPos().f)
    for k,v in pairs(targets) do 
      logger.info("  %s: (%2s,%2s,%2s,%2s)\n", k,v.x,v.y,v.z,v.f)
    end
    
		local destination = self:comparePos(targets, self:getPos())
		if destination then
			self:turnTo(destination.f)
      logger.info("Go: Arrived with %s try in %s seconds!\n",count,(os.time()-timer)/100)
			return true 
		end
    
    local dirPath,err,ok,cycles = self:getPath(targets,options)
		if not dirPath then -- TODO: Cannot find path!
      logger.info("Go: Failed to find path after %s tries in %s seconds because %s\n",count,(os.time()-timer)/100,err)
      if tries == 1 then 
        logger.info("Go: Retry in 10 seconds...\n")
        os.sleep(10)
        self:detectAround()
        self:turnAround()
        self:turnAround()
      end
      tries = tries + 1
		else
      tries = 1
      if ok then
        logger.info("Go: Found %s step full path (of %s nodes)\n",#dirPath,cycles)
      else
        logger.info("Go: Found %s step partial path (of %s nodes)\n",#dirPath,cycles)
      end
      local i = 1
      local ok, err = true, ""
      while i <= #dirPath and (ok or err == "no dir provided") do 
        thread.yield()
        ok, err = self:move(dirPath[i], options)
        if ok then 
          logger.info("Go: Step %s/%s done (%2s,%2s,%2s,%2s)\n",i,#dirPath,
            self:getPos().x,self:getPos().y,self:getPos().z,self:getPos().f)
        else
          logger.info("Go: Step failed because %s\n",err)
        end
        i = i + 1
      end
    end
	end
	return false, "Go: Aborting, exceeded retries"
end

-- Shortcut methods
function clsNav:turnTo(dir)
	if type(dir) ~= "number" then return false end 
  if type(dir) == "nil" or dir >= 4 then return true end
	if dir==self:getPos().f or dir==self:getPos().f+4 then return true
	elseif dir==self:getPos().f-1 or dir==self:getPos().f+3 then return self:turnLeft()
	elseif dir==self:getPos().f-2 or dir==self:getPos().f+2 then return self:turnAround()
	elseif dir==self:getPos().f-3 or dir==self:getPos().f+1 then return self:turnRight()
	end
end
function clsNav:step(options)
	return self:move(self:getPos().f,options)
end
function clsNav:stepUp(options)
	return self:move(4,options)
end
function clsNav:stepDown(options)
	return self:move(5,options)
end
function clsNav:goNextTo(center, options)
	local SixTargets = {}
	--logger.spam("Center: ")
	--for i,v in pairs(center) do logger.spam("'%s'=%s, ",i,v) end
	--logger.spam("SixTargets: %s\n",SixTargets)
	for i=0,5 do
		SixTargets[i+1] = self:getPos(center,i)
		--logger.spam("SixTargets: %s\n",SixTargets)
		--for j,v in pairs(self:getPos(center,i)) do logger.spam("'%s'=%s, ",j,v) end
		--for j,v in pairs(SixTargets[1]) do logger.spam("'%s'=%s, ",j,v) end
		--logger.spam("%s: %s,%s,%s,%s\n",SixTargets[i+1], SixTargets[i+1].x,SixTargets[i+1].z,SixTargets[i+1].y,SixTargets[i+1].f)
	end
	--logger.Check("")
	SixTargets[1].f = 2
	SixTargets[2].f = 3
	SixTargets[3].f = 0
	SixTargets[4].f = 1
	SixTargets[5].f = nil
	SixTargets[6].f = nil
	self:go( SixTargets[1], SixTargets[2], SixTargets[3], SixTargets[4], SixTargets[5], SixTargets[6], options )
end
function clsNav:drawMap(offset)
  offset = checkPos(offset)
  local resX, resY = component.gpu.getResolution()
  
  local lowLeft = self:getPos()
  lowLeft.x = lowLeft.x - (resY+resY%2)/2
  lowLeft.y = lowLeft.y - (resX+resX%2)/2
  if offset then
    lowLeft.x = lowLeft.x + offset.x
    lowLeft.y = lowLeft.y + offset.y
    lowLeft.z = lowLeft.z + offset.z
  end
  
  for yScreen=1,resY do
    local output = ""
    for xScreen=1,resX do
      local subst = self:getMap({lowLeft.x+yScreen,lowLeft.y+xScreen,lowLeft.z}).substance
      if subst == nil then output = output.." "
      elseif subst == "air" then output = output.."."
      elseif subst == "solid" then output = output.."#"
      elseif subst == "entity" then output = output.."e"
      elseif subst == "liquid" then output = output.."~"
      elseif subst == "replaceable" then output = output..","
      else error(debug.traceback())
      end
    end
    component.gpu.set(1,resY+1-yScreen,output)
  end
  return true
end

return clsNav

---------------- Details & Notes ----------------------------------------------

--[[ Tutorials
General: http://www.lua.org/pil/contents.html
Varargs: http://lua-users.org/wiki/VarargTheSecondClassCitizen
Intro to A* - http://www.raywenderlich.com/4946/introduction-to-a-pathfinding
Try it out! - http://zerowidth.com/2013/05/05/jump-point-search-explained.html
Better version to try out! - https://qiao.github.io/PathFinding.js/visual/
Useful - http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
--]]
--[[ Coord system
# MC logic
Coords... North: z--, East: x++, South: z++, West: x--, Up: y++, Down: y--
Coords... X points East, Z points South, Y points Up
Facing... 0: South, 1: West, 2: North, 3: East
Facing... Starts at South, goes clockwise
# Nav logic
Coords... North: x++, East: y++, South: x--, West: y--, Up: z++, Down: z--
Coords... X points North, Y points East, Z points Up
Facing... 0: North, 1: East, 2: South, 4: West
Facing... Starts at North, goes clockwise

use getNavFromMC() or getMCfromNav() to switch if needed, returns table
--]]
--[=[ Map structure
self.map[chunkID][SerializedCoord] = nil --[[unknown--]] or childID --[[if lended--]] or {
  substance = "air" or "solid" or "entity" or "replaceable" or "liquid"
  content = nil --[[unknown--]] or {--[[anything useful--]]}
  updated = 0 -- time in seconds from Colony start
  tag = {[string][,...]} -- RoCoWa related only, like "road", "evade", etc.
--]=]
