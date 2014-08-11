local thread = {}
-- Magic happens here
function thread.manager( thread )

  local event = {"TuCoWa_dummy"}
  local firstThread, focus, lastThread = 1, 1, 1
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
  
  local operations = {}
  operations.TuCoWa_Cycle = function ( data )
    threads[focus].filter = data.filter
    threads[focus].Listen = true
    return nil -- Cycle to next thread
  end
  operations.TuCoWa_Spawn = function ( data )
    threads[ lastThread+1 ] = {
      ["Name"] = data.Name or "anonymous",
      ["filter"] = data.filter or nil,
      ["Pause"] = 0,
      ["Listen"] = false,
      ["tArgSets"] = { 
        [1] = data.Args or nil },
      ["Id"] = getUid("coroutine"),
      ["Function"] = data.Function,
    }
    if data.Args then threads[ lastThread+1 ].lastArgSet = 1 else threads[ lastThread+1 ].lastArgSet = 0 end
    lastThread = lastThread + 1
    return threads[ lastThread ].Id
  end
  operations.TuCoWa_Whisper = function ( data )
    for _,Thread in pairs(threads) do
      if Thread.Id == data.Id then
        Thread.lastArgSet = Thread.lastArgSet + 1 
        Thread.tArgSets[ Thread.lastArgSet ] = data.Args or nil
        return true
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_Pause = function ( data )
    for _,Thread in pairs(threads) do
      if Thread.Id == data.Id then
        Thread.Pause = math.max(0, Thread.Pause + data.Amount)
        return true
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_Ask = function ( data )
    for _,Thread in pairs(threads) do
      if Thread.Id == data.Id and Thread.Listen == true then
        return coroutine.resume( Thread.Function, "TuCoWa_Ask", table.unpack(data.Msg or {}) )
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_Kill = function ( data )
    for i=firstThread,lastThread do
      if threads[i] and threads[i].Id == data.Id then 
        graveyard[ threads[i].Id ] = { false, "Killed", threads[focus].Id, utils.getTime() }
        graveyardTime[ threads[i].Id ] = utils.getTime()
        threads[i] = nil
        return true
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_Dig = function ( data )
    if graveyard[ data.Id ] then
      local Results = graveyard[ data.Id ]
      graveyard[ data.Id ] = nil
      return true, Results
    end
    return false, "Not found in Graveyard, check Id or try again later"
  end
  operations.TuCoWa_setFilter = function ( data )
    for i=firstThread,lastThread do
      if threads[i] and threads[i].Id == data.Id then 
        threads[i].filter = data.filter
        return true
      end
    end
    return false, "No running thread found, try to dig" 
  end    
  operations.TuCoWa_getFilter = function ( data )
    for i=firstThread,lastThread do
      if threads[i] and threads[i].Id == data.Id then
        return threads[i].filter
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_setName = function ( data )
    if data == nil then 
      threads[focus] = data.Name
      return true
    end
    for i=firstThread,lastThread do
      if threads[i] and threads[i].Id == data.Id then 
        threads[i].Name = data.Name
        return true
      end
    end
    return false, "No running thread found, try to dig" 
  end    
  operations.TuCoWa_getName = function ( data )
    for i=firstThread,lastThread do
      if threads[i] and threads[i].Id == data.Id then
        return threads[i].Name
      end
    end
    return false, "No running thread found, try to dig" 
  end
  operations.TuCoWa_getThread = function ( data )
    if data.Id == nil then
      local Table = {}
      for Key,Value in pairs(threads[focus]) do
        if Key ~= "tArgSets" then Table[Key] = Value end
      end
      return Table
    else
      for _,Thread in pairs(threads) do
        if Thread.Id == data.Id then
          local Table = {}
          for Key,Value in pairs(Thread) do
            if Key ~= "tArgSets" then Table[Key] = Value end
          end
          return Table
        end
      end      
      return false, "No running thread found, try to dig" 
    end
  end
  operations.TuCoWa_getThreads = function ()
    local Table, count = {}, 0
    for _,Thread in pairs(threads) do
      count = count + 1
      Table[count] = {}
      for Key,Value in pairs(Thread) do
        if Key ~= "tArgSets" then Table[count][Key] = Value end
      end
    end
    return Table
  end
  operations.TuCoWa_UpdateLib = function ( data ) -- TODO!
    UpdateAPI(table.unpack(data or {}))
    return true
  end
  
  while lastThread > 0 do  -- Run until no threads left (won't happen normally)
    --logger.spam("\nThread %s/%s (%s,%s)", focus, lastThread ,event[1], event[2])
    
    if type(threads[focus]) == "table" then 
      --logger.spam("%s!", threads[focus].Pause)
      
      if not threads[focus].filter or threads[focus].filter == event[1] then
        threads[focus].tArgSets[ threads[focus].lastArgSet+1 ] = event
        threads[focus].lastArgSet = threads[focus].lastArgSet + 1
      end
      
      if threads[focus].Pause == 0 then
        --logger.spam("..")
        
        local i = 1
        while i <= threads[focus].lastArgSet do
          --logger.spam("i=%s..",i)
          
          local tResults = { coroutine.resume( threads[focus].Function, table.unpack( threads[focus].tArgSets[i] or {} ) ) }
          local isOk, tArgs = tResults[1], tResults[2]
          threads[focus].tArgSets[i] = nil
          threads[focus].Listen = false
          threads[focus].filter = false
          
          if not isOk then 
            logger.warning("thread failed! %s\n", tArgs )
            graveyard[ threads[focus].Id ] = tResults
            graveyardTime[ threads[focus].Id ] = utils.getTime()
            threads[focus] = nil
          elseif coroutine.status(threads[focus].Function) == "dead" then 
            graveyard[ threads[focus].Id ] = tResults
            graveyardTime[ threads[focus].Id ] = utils.getTime()
            threads[focus] = nil
          else
            if tArgs and type(tArgs) == "string" then 
              threads[focus].filter = tArgs
            elseif tArgs and type(tArgs) == "table" then
              if tArgs.Flag and operations[ tArgs.Flag ] then 
                threads[focus].tArgSets[i] = { operations[ tArgs.Flag ]( tArgs ) }
                if threads[focus].tArgSets[i][1] == nil then threads[focus].tArgSets[i] = nil end
              end
              local computer = require("computer")
              computer.pushSignal("TuCoWa_dummy")
            end
          end
          
          if not threads[focus] then break end
          if threads[focus].tArgSets[i] == nil then i = i + 1 end
        end

        if threads[focus] then threads[focus].lastArgSet = 0 end
      end
    else
      if focus == lastThread then lastThread = lastThread - 1 end
      if focus == firstThread then firstThread = math.min(firstThread + 1, lastThread) end
    end
    
    --logger.spam("\n")
    if focus < lastThread then 
      focus = focus + 1
    else
      focus = firstThread
      event = { coroutine.yield("") } -- after a cycle call pullEventRaw ( = coroutine.yield )  
    end
    
  end
  logger.info("Out-of-threads!\n")
end

-- Sanitization happens here
function thread.spawn( _Fn, ... )
  local Fn, err, tArgs
  if type(_Fn) == "function" then 
    Fn = _Fn
  elseif type(_Fn) == "string" then
    Fn, err = load(_Fn)
    if not Fn then return false, err end
  elseif false then -- TODO: Add support for file handles
  else
    return false, "Not valid function or string"
  end
  Fn = coroutine.create(Fn)
  if not Fn then return false, "Failed to create thread" end
  
  return coroutine.yield({ 
    ["Flag"] = "TuCoWa_Spawn",
    ["Function"] = Fn,
    ["Args"] = { ... },
    ["filter"] = nil,
    ["Name"] = "anonymous",
  })
end
function thread.whisper( _sId, ... )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_Whisper",
    ["Id"] = sId,
    ["Args"] = { ... },
  })  
end
function thread.pause( _sId, _Amount )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  if type(_Amount) ~= "number" then _Amount = 1 end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_Pause",
    ["Id"] = _sId,
    ["Amount"] = _Amount,
  })  
end
function thread.unpause( _sId, _Amount )
  local Amount = -(_Amount or 1)
  return thread.Pause( _sId, Amount )
end
function thread.ask( _sId, ... )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_Ask",
    ["Id"] = _sId,
    ["Msg"] = { ... },
  })  
end
function thread.kill( _sId )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_Kill",
    ["Id"] = _sId,
  })
end
function thread.dig( _sId )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_Dig",
    ["Id"] = _sId,
  })
end
function thread.cycle( filter, ... )
  local uAnswer = { ... }
  if type(filter) ~= "string" then filter = nil end
  local Data = { coroutine.yield({ ["Flag"] = "TuCoWa_Cycle", ["filter"] = filter }) }
  
  if Data[1] == "TuCoWa_Ask" then
    if type(uAnswer[1]) == "function" then coroutine.yield( uAnswer[1](Data) ) else coroutine.yield( table.unpack(uAnswer) ) end
    return thread.Cycle(uAnswer)
  else
    return table.unpack( Data )
  end
end
function thread.setFilter( _sId, filter )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  if type(filter) ~= "string" and type(filter) ~= "nil" then return false, "Not valid Filter, expected string or nil" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_setFilter",
    ["Id"] = _sId,
    ["Filter"] = filter,
  })
end
function thread.getFilter( _sId )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_getFilter",
    ["Id"] = _sId,
  })
end
function thread.setName( _sId, _sName )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  if type(_sName) ~= "string" then return false, "Not valid Name, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_setName",
    ["Id"] = _sId,
    ["Name"] = _sName,
  })
end
function thread.getName( _sId )
  if type(_sId) ~= "string" then return false, "Not valid Id, expected string" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_getName",
    ["Id"] = _sId,
  })
end
function thread.getThreads()
  return coroutine.yield({
    ["Flag"] = "TuCoWa_getThreads"
  })
end
function thread.getThread( _sId )
  if type(_sId) ~= "string" and type(_sId) ~= "nil" then return false, "Not valid Id, expected string or nil" end
  return coroutine.yield({
    ["Flag"] = "TuCoWa_getThread",
    ["Id"] = _sId,
  })
end
--[[function tucowa.UpdateLib( ... )
  return coroutine.yield({
    ["Flag"] = "TuCoWa_updateLib",
    ["List"] = { ... },
  })
end
--]]
return thread