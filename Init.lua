local init = {}

-------------------------------------------------------------------------------

function init.bootstrap ()	-- TODO: not working
	Nav.UpdateMap({0,0,0},false)
	write("In")
	coroutine.Spawn( Logger.Info, "itialized!\n\n" )
	coroutine.Cycle()
	-- first turtle will look for signs with instructions (if another turtle made it)
	--write("No signs found.\n")
	write("Human, choose fate of the turtle:\n")
	write("1. Player assistant\n")
	write("2. Independent colony (WiP!)\n")
	write("3. Independent colony (debug, WiP!)\n")
	while true do
		local event, param1 = os.pullEvent("char")
		if event == "char" and param1 == "1" then InitPlayerAssistant(); break end
		if event == "char" and param1 == "2" then InitColonyMember(); break end
		if event == "char" and param1 == "3" then InitColonyMemberDebug(); break end
	end
end

function init.console()
	--Utils.Refuel()
	logger.info("@ ")
	str = io.read()
	local ch = load(str)
	if ch and str ~="" then 
		--print(pcall(ch))
		LastSpawn = thread.spawn(ch)
		thread.cycle()
		logger.info("\n")
		--Logger.Info(" Coords: (%s,%s,%s), F:%s\n",Nav.GetPos().x,Nav.GetPos().z,Nav.GetPos().y,Nav.GetPos().f)
	end
	local replicate = thread.spawn(init.console)
	thread.setName(replicate, "console")
	return true
end

return init