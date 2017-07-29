require "game"
require "autosave"

require "Demo"

function love.load()
	if loaded then return end
	
	gameThread = love.thread.newThread("game.lua") -- was there a point to this? TODO

	-- print(gameThread:isRunning())
	-- loadGraphics()
	
	-- loadSound()
	
	if autosaveExists() then
		readAutosave()
	else
		-- loadTitleScreen() ?
	end
	
	setGameState("Demo")
	
	-- print("main")
	
	debugNum = 0
	
	loaded = true
end

--"loaded" variable didn't work. not only is love.load() called when the icon is tapped on the home screen, but the existing activity is dumped

--also you overwrote mobile test somehow? what did you miss in the manifest? :/
--...oh. idiot. you changed data in the wrong file :I try again