-- function love.load()
-- 	-- loadGraphics()
--
-- 	-- loadSound()
--
-- 	if autosaveExists() then
-- 		readAutosave()
-- 	else
-- 		-- loadTitleScreen() ?
-- 	end
--
-- 	setGameState("Demo")
--
-- 	print("demo load")
-- end

function love.update(dt)
	_G["update"..getGameState()](dt)
end

function love.draw()
	_G["draw"..getGameState()]()
end

------------------------------------------------------------------------------------------------------------------------

--TODO make state a stack, not a single variable

function setGameState(s)
	state = s
end

function getGameState()
	return state
end

------------------------------------------------------------------------------------------------------------------------

--since love.load() can come unexpectedly, these callbacks trigger autosaves

function love.focus(focus)
	if not focus then
		writeAutosave()
	end
end

function love.quit()
	writeAutosave()
end