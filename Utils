function Refuel(self)
	if turtle.getFuelLevel() < 128 then
		if turtle.refuel() then 
			Logger.Info("Refueled!")
		else 
			Logger.Info("Fuel me!")
		end
	end
	return turtle.getFuelLevel()
end

function myformat(fmt, ... )
	local buf = {}
	for i = 1, select( '#', ... ) do
		local a = select( i, ... )
		if type( a ) ~= 'string' and type( a ) ~= 'number' then
			a = tostring( a )
		end
		buf[i] = a
	end
	
	return string.format( fmt, unpack( buf ) )
end

local GlobalSteps = 0
local CountedSteps = 0

function Step(x)
	x = x or 1 -- create object if user does not provide one
	GlobalSteps = GlobalSteps + 1
	CountedSteps = CountedSteps + 1
end

function GetGlobalSteps()
	return GlobalSteps
end

function GetCountedSteps()
	return CountedSteps
end

function ResetCountedSteps()
	CountedSteps = 0
end

function GenUniqString(lenght)
	-- char(67) -- TODO need unique ... 65-90 capitals, 97-122 lowercase, 48-57 numbers (26+26+10=62)
	local Str = ""
	for i=0,lenght do
		local Char = math.random(0,61)
		if Char < 26 then Char = Char + 65
		elseif Char < 52 then Char = Char + 97 - 26
		elseif Char < 62 then Char = Char + 48 - 26 - 26
		end
		Str = Str .. string.char(Char)
	end
	return Str
end



















