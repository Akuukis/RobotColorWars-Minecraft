local gui = {}
-------------------------------------------------------------------------------

function gui.printMap()
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

function gui.test()
	print("Kuku!")
	return true
end

return gui