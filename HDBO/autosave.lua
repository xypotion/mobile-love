function autosaveExists()
	return false --DEBUG
end

--read data and load
function readAutosave()
	--read file
	local data = nil
	
	--pass data to state-specific function
	_G["create"..getGameState().."FromAutosaveData"](data)
end

--save game's state; called from love.quit() and love.focus(false) callbacks
function writeAutosave()
	local data = _G["autosaveDataFor"..getGameState()]()
	
	--and write to file
end