--Gui
function PrintMap()
	--[[
	y = 0;
	for x = Nav.X + 3,Nav.X - 3, -1 do
		for z = Nav.Z - 19, Nav.Z + 19, 1 do
		if Nav.Map[x] == nil then
			Utils.printf(".")
		elseif Nav.Map[x][z] == nil then
			Utils.printf(".")
		else
			if (Nav.X == x and Nav.Z == z) then
				Utils.printf("#")
			else 
				if Nav.Map[x][z][y].Id == 0 then
					Utils.printf(" ")
				else
					Utils.printf("%s", Nav.Map[x][z][y].Id)
				end
			end
		end
	end
	
	Utils.printf("\n")
	end
	--]]
end

--[[ Info
Term API http://computercraft.info/wiki/Term_%28API%29
Turtle screen size (in chars) = 39 x 13
Computer screen size (in chars) = 51 x 19
--]]

function PlayerRun()
	Utils.Refuel()
	write(Utils.myformat("\n# "))
	str = io.read()
	ch = loadstring(str)
	print(pcall(ch))
	
	pos = Nav.GetPos()
	Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos("x"),Nav.GetPos("z"),Nav.GetPos("y"),Nav.GetPos("f"))
	coroutine.yield("_Call",Gui.PlayerRun)
end

function Test()
	print("Kuku!")
	return true
end