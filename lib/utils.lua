local utils = {}

-------------------------------------------------------------------------------

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
	return os.time()
end

---------------- Details & Notes ----------------------------------------------

return utils