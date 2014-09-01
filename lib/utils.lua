local utils = {}

-------------------------------------------------------------------------------

function utils.console(env)
  if type(env) == "table" then
    local upenv = _ENV
    local setmetatable = setmetatable
    setmetatable(env, {__index = upenv})
    _ENV = env
    print("Local environment set!")
  end
  
  local function read(history)
    local component = require("component")
    local prefix = "P# "
    local history = history
    if type(history) ~= "table" then history = {} end
    history[#history] = ""
    local command = ""
    local historyCursor = #history
    local cursorX, cursorY = 1,1
    while true do
      local newline = false
      local resX, resY = component.gpu.getResolution()
      for i=1,#prefix do
        if string.sub(prefix,i,i) ~= component.gpu.get(i,resY) then newline = true end
      end
      if newline then
        component.gpu.copy(1,1,resX,resY,0,-1)
        component.gpu.fill(1,resY,resX,1," ")
      end
      local output = prefix..string.sub(command or "",-(resX-3))
      for i=1,resX-#output do output = output.." " end
      component.gpu.set(1,resY,output)
      
      local name, address, charOrValue, code, player = coroutine.yield("[kc][el][yi][_p][db][oo][wa][nr]d?")
      if name == "clipboard" then player = code; code = nil end
      
      if name == "key_down" then
        if code == 28 then -- enter
          component.gpu.fill(1,resY,resX,1," ")
          return command
        elseif code == 14 then -- backspace
          command = string.sub(history[historyCursor],1,#history[historyCursor]-1)
          history[#history] = command
          historyCursor = #history                  
        elseif code == 211 then -- del
          command = ""
          history[#history] = command
          historyCursor = #history    
        elseif code == 200 then -- arrow up
          historyCursor = math.max(1, historyCursor-1)
          command = history[historyCursor]
        elseif code == 208 then -- arrow down
          historyCursor = math.min(#history, historyCursor+1)
          command = history[historyCursor]
          historyCursor = #history
        elseif not(type(charOrValue) == "number" and (charOrValue < 0x20 or (charOrValue >= 0x7F and charOrValue <= 0x9F))) then -- is normal char
          command = history[historyCursor]..string.char(charOrValue) -- TODO: crashed once with "value out of range", unicode problems?
          history[#history] = command
          historyCursor = #history
        end
      elseif name == "clipboard" then
        command = history[historyCursor]..charOrValue
        history[#history] = command
        historyCursor = #history
        if string.find(command,"\n",-1, true) then 
          component.gpu.fill(1,resY,resX,1," ")
          return command 
        end
      end
    end
  end
  local history = {}
  while true do
    local str = read(history) -- yields here!
    history[#history+1] = str
    if str == "quit" then
      print("Quit!")
      return history
    end
    --local formattedTime = ""
    --if os.clock()*60 >= 60 * 60 then formattedTime = formattedTime .. string.format("%dh",os.clock/60) end
    --if os.clock()*60 >= 60 then formattedTime = formattedTime .. string.format("%dm",os.clock()-math.floor(os.clock()/60)) end
    --formattedTime = formattedTime .. string.format("%is",os.clock()*60-math.floor(os.clock())*60)            
    local fn, err = load(str) -- ,"console@"..formattedTime
    if fn and str ~="" and str ~="\n" then 
      print("executed:",pcall(fn))
    else
      if err then print("load error:", err) end
    end
  end
end


function utils.format(fmt, ... )
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

function utils.freeMemory()
    local result = 0
    for i = 1, 10 do
      result = math.max(result, computer.freeMemory())
      os.sleep(0)
    end
    return result
  end

function utils.monitorFuel(self, error_limit, critical_limit)
  local logger = logger
  local robot = require("robot")
	if turtle.getFuelLevel() < 128 then
		if turtle.refuel() then 
			logger.Info("Refueled!")
		else 
			logger.Info("Fuel me!")
		end
	end
	return turtle.getFuelLevel()
end

function utils.getTime()
	return os.clock()*60
end

---------------- Details & Notes ----------------------------------------------

return utils