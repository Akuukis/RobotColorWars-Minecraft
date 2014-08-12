local thread = {}
-- Magic happens here
function thread.manager( thread )

  local event = {"RoCoWa_dummy"}
  local focus, lastThread = 1, 1
  local threads = { [1] = thread } -- TODO: Sanitize
  local graveyard = {}
  local graveyardTime = {}
  
  -- You should provide better versions of these functions.
  local getUid = getUid or function () return tostring(math.random(10000000,99999999)) end
  local utils = utils or false
  if not utils then
    utils = {
      getTime = function () return os.time() end,
    }
  end
  local logger = logger or false
  if not logger then 
    logger = {
      fatal = function (...) io.write(string.format(...)) end,
      warning = function (...) io.write(string.format(...)) end,
      info = function (...) io.write(string.format(...)) end,
      spam = function (...) io.write(string.format(...)) end,
    }
  end
  
  -- Core
  local operations = {
    RoCoWa_cycle = function (data)
      threads[focus].filter = data.filter
      threads[focus].listen = true
      return nil -- Cycle to next thread
    end,
    RoCoWa_spawn = function (data)
      lastThread = lastThread + 1
      threads[ lastThread ] = {
        ["name"] = data.name or "anonymous",
        ["filter"] = data.filter or nil,
        ["pause"] = 0,
        ["listen"] = false,
        ["argSets"] = { 
          [1] = data.args or nil },
        ["uid"] = getUid("coroutine"),
        ["co"] = data.co,
      }
      if data.args then threads[ lastThread ].lastArgSet = 1 else threads[ lastThread ].lastArgSet = 0 end
      return threads[ lastThread ].uid
    end,
    RoCoWa_whisper = function (data)
      for _,thread in pairs(threads) do
        if thread.uid == data.uid then
          thread.lastArgSet = thread.lastArgSet + 1 
          thread.argSets[ thread.lastArgSet ] = data.args or nil
          return true
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_pause = function (data)
      for _,thread in pairs(threads) do
        if thread.uid == data.uid then
          thread.pause = math.max(0, thread.pause + data.amount)
          return true
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_ask = function (data)
      for _,thread in pairs(threads) do
        if thread.uid == data.uid and thread.listen == true then
          return coroutine.resume( thread.co, "RoCoWa_ask", table.unpack(data.msg or {}) )
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_kill = function (data)
      for i=1,lastThread do
        if threads[i] and threads[i].uid == data.uid then 
          graveyard[ threads[i].uid ] = { false, "killed", threads[focus].uid, utils.getTime() }
          graveyardTime[ threads[i].uid ] = utils.getTime()
          threads[i] = nil
          return true
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_dig = function (data)
      if graveyard[ data.uid ] then
        local results = graveyard[ data.uid ]
        graveyard[ data.uid ] = nil
        return true, results
      end
      return false, "Not found in Graveyard, check uid or try again later"
    end,
    RoCoWa_setFilter = function (data)
      for i=1,lastThread do
        if threads[i] and threads[i].uid == data.uid then 
          threads[i].filter = data.filter
          return true
        end
      end
      return false, "No running thread found, try to dig" 
    end, 
    RoCoWa_getFilter = function (data)
      for i=1,lastThread do
        if threads[i] and threads[i].uid == data.uid then
          return threads[i].filter
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_setName = function (data)
      if data == nil then 
        threads[focus] = data.name
        return true
      end
      for i=1,lastThread do
        if threads[i] and threads[i].uid == data.uid then 
          threads[i].name = data.name
          return true
        end
      end
      return false, "No running thread found, try to dig" 
    end,  
    RoCoWa_getName = function (data)
      for i=1,lastThread do
        if threads[i] and threads[i].uid == data.uid then
          return threads[i].name
        end
      end
      return false, "No running thread found, try to dig" 
    end,
    RoCoWa_getThread = function (data)
      if data.uid == nil then
        local result = {}
        for key,value in pairs(threads[focus]) do
          if key ~= "argSets" then result[key] = value end
        end
        return result
      else
        for _,thread in pairs(threads) do
          if thread.uid == data.uid then
            local result = {}
            for key,value in pairs(thread) do
              if key ~= "argSets" then result[key] = value end
            end
            return result
          end
        end      
        return false, "No running thread found, try to dig" 
      end
    end,
    RoCoWa_getThreads = function ()
      local result, count = {}, 0
      for _,thread in pairs(threads) do
        count = count + 1
        result[count] = {}
        for key,value in pairs(thread) do
          if key ~= "argSets" then result[count][key] = value end
        end
      end
      return result
    end,
    RoCoWa_updateLib = function (data) -- TODO!
      updateAPI(table.unpack(data or {}))
      return true
    end,
  }
  while lastThread > 0 do  -- Run until no threads left (won't happen normally)
    --logger.spam("\nThread %s/%s (%s,%s,%s)", focus, lastThread ,event[1], event[3], event[4])
    
    if type(threads[focus]) == "table" then 
      --logger.spam("%s,%s!", threads[focus].pause, threads[focus].lastArgSet)
      
      local i = 1
      while threads[focus] and threads[focus].pause == 0 and i <= threads[focus].lastArgSet do
        --logger.spam("\n  i=%s..",i)
        
        local result = table.pack( coroutine.resume( threads[focus].co, table.unpack( threads[focus].argSets[i] or {} ) ) )
        --for k,v in pairs(result) do logger.spam("\n    [%s]: %s",k,v) end
        local ok, args = result[1], result[2]
        threads[focus].argSets[i] = nil
        threads[focus].listen = false
        threads[focus].filter = false
        
        if not ok then 
          logger.warning("thread failed! %s\n", args )
          graveyard[ threads[focus].uid ] = result
          graveyardTime[ threads[focus].uid ] = utils.getTime()
          threads[focus] = nil
        elseif coroutine.status(threads[focus].co) == "dead" then 
          graveyard[ threads[focus].uid ] = result
          graveyardTime[ threads[focus].uid ] = utils.getTime()
          threads[focus] = nil
        else
          if args and type(args) == "string" and args ~= "" then 
            threads[focus].filter = args
          elseif args and type(args) == "table" then
            if args.flag and operations[ args.flag ] then 
              threads[focus].argSets[i] = { operations[ args.flag ]( args ) }
              if threads[focus].argSets[i][1] == nil then threads[focus].argSets[i] = nil end
            end
            local computer = require("computer")
            computer.pushSignal("RoCoWa_dummy")
          end
        end
        
        if threads[focus] and threads[focus].argSets[i] == nil then i = i + 1 end
      end
      if threads[focus] then threads[focus].lastArgSet = 0 -- drops all arguments before pausing, if it does
      --[[  local count = 0
        for j=i,threads[focus].lastArgSet do
          count = count + 1
          threads[focus].argSets[count] = threads[focus].argSets[j]
        end
        threads[focus].lastArgSet = count
      --]]end
    else
      if focus == lastThread then lastThread = lastThread - 1 end
    end
    
    if type(threads[focus+1]) ~= "table" then 
      threads[focus+1] = threads[focus+2] 
      threads[focus+2] = nil
      end
    
    --logger.spam("\n")
    if focus < lastThread then 
      focus = focus + 1
    else
      focus = 1
      event = { coroutine.yield("") }
      for i=1,lastThread do
        if threads[i] and ((not threads[i].filter) or (threads[i].filter == event[1])) then
          threads[i].argSets[ threads[i].lastArgSet+1 ] = event
          threads[i].lastArgSet = threads[i].lastArgSet + 1
        end
      end
    end
    
  end
  logger.info("Out-of-threads!\n")
end

-- Sanitization happens here
function thread.spawn( fn, ... )
  local err
  if type(fn) == "function" then 
    fn = fn
  elseif type(fn) == "string" then
    fn, err = load(fn)
    if not fn then return false, err end
  elseif false then -- TODO: Add support for file handles
  else
    return false, "Not valid function or string"
  end
  local co = coroutine.create(fn)
  if not co then return false, "Failed to create thread" end
  return coroutine.yield({ 
    ["flag"] = "RoCoWa_spawn",
    ["co"] = co,
    ["args"] = { ... },
    ["filter"] = nil,
    ["name"] = "anonymous",
  })
end
function thread.whisper( uid, ... )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_whisper",
    ["uid"] = uid,
    ["args"] = { ... },
  })  
end
function thread.pause( uid, amount )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  if type(amount) ~= "number" then amount = 1 end
  return coroutine.yield({
    ["flag"] = "RoCoWa_pause",
    ["uid"] = uid,
    ["amount"] = amount,
  })  
end
function thread.unpause( uid, amount )
  local amount = -(amount or 1)
  return thread.Pause( uid, amount )
end
function thread.ask( uid, ... )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_ask",
    ["uid"] = uid,
    ["msg"] = { ... },
  })  
end
function thread.kill(uid)
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_kill",
    ["uid"] = uid,
  })
end
function thread.dig(uid)
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_dig",
    ["uid"] = uid,
  })
end
function thread.cycle( filter, ... )
  local answer = { ... }
  if type(filter) ~= "string" then filter = nil end
  local data = { coroutine.yield({ ["flag"] = "RoCoWa_cycle", ["filter"] = filter }) }
  
  if data[1] == "RoCoWa_ask" then
    if type(answer[1]) == "function" then coroutine.yield( answer[1](data) ) else coroutine.yield( table.unpack(answer) ) end
    return thread.cycle(answer)
  else
    return table.unpack( data )
  end
end
function thread.setFilter( uid, filter )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  local ok, err = pcall(checkArg, 1, filter, "string", "nil"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_setFilter",
    ["uid"] = uid,
    ["filter"] = filter,
  })
end
function thread.getFilter( uid )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_getFilter",
    ["uid"] = uid,
  })
end
function thread.setName( uid, name )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  local ok, err = pcall(checkArg, 1, name, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_setName",
    ["uid"] = uid,
    ["name"] = name,
  })
end
function thread.getName( uid )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_getName",
    ["uid"] = uid,
  })
end
function thread.getThreads()
  return coroutine.yield({
    ["flag"] = "RoCoWa_getThreads"
  })
end
function thread.getThread( uid )
  local ok, err = pcall(checkArg, 1, uid, "string"); if not ok then return ok, err end
  return coroutine.yield({
    ["flag"] = "RoCoWa_getThread",
    ["uid"] = uid,
  })
end
--[[function tucowa.UpdateLib( ... )
  return coroutine.yield({
    ["flag"] = "RoCoWa_updateLib",
    ["List"] = { ... },
  })
end
--]]
return thread