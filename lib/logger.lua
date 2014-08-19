local logger = {}
-------------------------------------------------------------------------------

logger.level = { gui = 3, rui = 3, hud = 3 }


-------------------------------------------------------------------------------

function logger.check(...) -- throw inside the code to stop it and check variables
  -- needs rework
  return false
end

function logger.spam(...)
  local format = string.format
  if utils then sf = utils.format or sf end
	if logger.level.gui >= 3 then io.write(format(...)) end
end

function logger.info(...)
  local format = string.format
  if utils then sf = utils.format or sf end
	if logger.level.gui >= 2 then io.write(format(...)) end
end

function logger.warning(...)
  local format = string.format
  if utils then sf = utils.format or sf end
	if logger.level.gui >= 1 then io.write(format(...)) end
end

function logger.fatal(...)
  local format = string.format
  if utils then sf = utils.format or sf end
	if logger.level.gui >= 0 then io.write(format(...)) end
end

return logger
