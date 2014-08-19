local init = {}

-------------------------------------------------------------------------------


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
  local term = require("term")
	logger.info("@ ")
	str = term.read()
	local ch = load(str)
	if ch and str ~="" and str ~="\n" then thread.spawn(ch) end
  print("executed...")
  local uid = thread.spawn(init.console)
	thread.setName(uid, "console")
	return true
end

return init