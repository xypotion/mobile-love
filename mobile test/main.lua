--ideas...
	--√ sound
	--√ vibration!
	--√ load an image
	--√ change screen color
	--√ mousereleased vs touchreleased
			--touches' coordinates are floats...? probably stick with clicks
	--√ 16x9 grid of squares in background
	--√ change screen orientation?
	--√ love.graphics.getSystemLimits
	--√ love.graphics.getCanvasFormats
	--√ love.graphics.getSupported
	--√ love.graphics.getCompressedImageFormats
	--  animate something (how smooth is it?)
	--  frame rate
	--  canvas test
	--  love.focus callback. write to a file when triggered
	--  love.visible ''
	--  love.resize? ''
	--  love.quit? ''
	--  love.lowmemory? ''
	--  love.load, even ''
	--  love.window.setDisplaySleepEnabled?
	--x love.setTitle?
	--  love.window.toPixels? fromPixels? maybe good for interaction
	--  file i/o... https://love2d.org/wiki/love.filesystem lots of gets
		--  love.filesystem.getIdentity / love.filesystem.setIdentity
		--  love.filesystem.getAppdataDirectory
		--  love.filesystem.isFused
		--  actually try saving and loading files
	--  accelerometer = joystick! this is on by default. try it out :O
		--  Joystick:getAxisCount might be a good place to start.
		--  turn screen grey; each axis motion controls a color channel?
	--  text input
	--  AndroidManifest.xml stuff...
			--x change launchmode to prevent re-load() problem?
			--x android:allowTaskReparenting (under application, not activity): prevent re-load() problem?
			--  what's up with configChanges? can ignore?
			--  custom <application android:theme...>?
			--  android:windowSoftInputMode eventually if you need a keyboard
	--  long presses!
			--  maybe read https://love2d.org/forums/viewtopic.php?f=4&t=82426&p=199721&hilit=android+home+screen&sid=cec62dbae336decfbb0344482388caee#p199721
	--√ config file stuff https://love2d.org/wiki/Config_Files ...actually not a ton that applies to android gamedev, but revisit later for module-disabling in real projects!

--12 buttons...
	--flags
	--system limits
	--supported
	--canvas formats
	--compressed image formats
	--sound + vibrate
	--text input (pop up keyboard). echo it and write to the file
	--canvas test of some kind
	--  interaction test: long press (-> change graphic), drag test, pinch test (on some object), joystick test. the button also resets object's state
	--read file
	--delete file
	--write to (append OR create) file
	
require "square"
require "callbacks"

function love.load()
-- 	startFresh()
-- end
--
-- function startFresh()
	--setup for desktop..
	love.window.setMode(360, 640)
	
	-- get window dimensions
	WINDOW = {}
	WINDOW.w, WINDOW.h, WINDOW.flags = love.window.getMode()
	vSpace = WINDOW.h / 48
	hSpace = WINDOW.w / 36
	
	--add misc stuff to flags list
	WINDOW.flags.pixelScale = love.window.getPixelScale()
	WINDOW.flags.getIdentity = love.filesystem.getIdentity()
	WINDOW.flags.dir = love.filesystem.getAppdataDirectory()
	WINDOW.flags.isFused = love.filesystem.isFused()
	
	--canvas setup
	mainCanvas = love.graphics.newCanvas(WINDOW.w, WINDOW.h)
	
	-- get pixel scale
	-- PIXELSCALE = love.window.getPixelScale()
	
	-- load images
	ICE = love.graphics.newImage("DQ3_Spell_Kacrackle.png")
	FIRE = love.graphics.newImage("DQ3_Spell_Kafrizzle.png")
	THUNDER = love.graphics.newImage("DQ3_Spell_Kazap.png")
	
	--load sounds
	THUNDER_SFX = love.audio.newSource("345920__dragisharambo21__thunder.mp3", "static")	--from https://freesound.org/people/DragishaRambo21/sounds/345920/, license = noncommercial
	
	--set font and line width
	love.graphics.setNewFont(14 * WINDOW.flags.pixelScale)
	love.graphics.setLineWidth(2 * WINDOW.flags.pixelScale)
	
	-- get whether screen is touchscreen
	-- IS_TOUCHSCREEN = love.window.isTouchScreen(1) --lol, where did this come from? https://bitbucket.org/MartinFelis/love-android-sdl2/wiki/love.window.isTouchScreen
	
	--init test vars
	TOUCHES = 0
	TEXT = "Looks like you're using "..love.system.getOS()..". Touch to interact!"
	LAST_TOUCHRELEASED = {}
	LAST_MOUSERELEASED = {}
	-- IMAGE_HOT = true
	-- THUNDER_SCALE = 1
	love.graphics.setColor(255, 255, 255)
	
	infoMessage = "Tap a button for info -->"
	infoList = nil
	
	canvasTimer = -1
	inputText = {}
	
	-- love.filesystem.setIdentity("mobile_test_1")
	save = love.filesystem.newFile("save.txt")
	textInputBuffer = ""

	initSquare()
	showSquare = false --hackkk
	autosave = love.filesystem.newFile("autosave.txt")
	if autosaveExists() then readAutosave() end
	
	writeToSaveFile("LOAD at "..os.time())
	
	--fake touch stuff for testing
	-- fakeTouch = {x = WINDOW.w / 2, y = WINDOW.h / 2}
	-- showFakeTouch = false
end

function love.draw()
	--canvas stuff
	love.graphics.setCanvas(mainCanvas)
	love.graphics.clear()
	
	--doubled-up grid of squares; sub-grid first
	if (TOUCHES == 0) then
		love.graphics.setColor(31, 31, 31)
		for y = WINDOW.h / 32, WINDOW.h - 1, WINDOW.h / 16 do
			love.graphics.line(0, y, WINDOW.w, y)
		end
	
		for x = WINDOW.w / 18, WINDOW.w - 1, WINDOW.w / 9 do
			love.graphics.line(x, 0, x, WINDOW.h)
		end
	
		love.graphics.setColor(63, 63, 63)
		for y = WINDOW.h / 16, WINDOW.h - 1, WINDOW.h / 16 do
			love.graphics.line(0, y, WINDOW.w, y)
		end
	
		for x = WINDOW.w / 9, WINDOW.w - 1, WINDOW.w / 9 do
			love.graphics.line(x, 0, x, WINDOW.h)
		end
	end
	
	--color reset for text
	love.graphics.setColor(255, 255, 255)
	
	--basic text
	love.graphics.print(TEXT, hSpace * 1, vSpace * 1)
	love.graphics.print("width: "..WINDOW.w.." height: "..WINDOW.h, hSpace, vSpace * 2)

	--click & touch info
	if LAST_MOUSERELEASED then
		love.graphics.print("CLICK: ", hSpace * 1, vSpace * 3)
		local space = 1
		for k,v in pairs(LAST_MOUSERELEASED) do
 			love.graphics.print(k..": "..tostring(v), hSpace * 1, (3 + space) * vSpace)
			space = space + 1
		end
	end
	
	if LAST_TOUCHRELEASED then
		love.graphics.print("TOUCH: ", hSpace * 7, vSpace * 3)
		local space = 1
		for k,v in pairs(LAST_TOUCHRELEASED) do
 			love.graphics.print(k..": "..tostring(v), hSpace * 7, (3 + space) * vSpace)
			space = space + 1
		end
	end
	
	--window pixel scale
	-- love.graphics.print("Pixel Scale: "..PIXELSCALE, hSpace * 1, vSpace * 9)

	--infoList...
	if infoList then
		local space = 1
		for k,v in pairs(infoList) do
			if tostring(v) then
				if v == true then love.graphics.setColor(0, 255, 0)
				elseif v == false then love.graphics.setColor(255, 0, 0)
				else love.graphics.setColor(255, 255, 255)
				end
					
	 			love.graphics.print(k..": "..tostring(v), hSpace, (8 + space) * vSpace)
				space = space + 1
			end
		end
		
		love.graphics.setColor(255, 255, 255)
	else
		--(or infoMessage)
		love.graphics.print(infoMessage, hSpace, vSpace * 9)
	end
	
	
	--...and "buttons" to control it. #inefficient #whatever
	love.graphics.print("flags/misc", WINDOW.w * 2 / 3, WINDOW.h * 1 / 24)
	love.graphics.print("getSystemLimits", WINDOW.w * 2 / 3, WINDOW.h * 3 / 24)
	love.graphics.print("getCanvasFormats", WINDOW.w * 2 / 3, WINDOW.h * 5 / 24)
	love.graphics.print("getSupported", WINDOW.w * 2 / 3, WINDOW.h * 7 / 24)
	love.graphics.print("getCompressedImageFormats", WINDOW.w * 2 / 3, WINDOW.h * 9 / 24)
	love.graphics.print("thunder!", WINDOW.w * 2 / 3, WINDOW.h * 11 / 24)
	love.graphics.print("text input", WINDOW.w * 2 / 3, WINDOW.h * 13 / 24)
	love.graphics.print("canvas test", WINDOW.w * 2 / 3, WINDOW.h * 15 / 24)
	love.graphics.print("interaction test", WINDOW.w * 2 / 3, WINDOW.h * 17 / 24)
	love.graphics.print("read save file", WINDOW.w * 2 / 3, WINDOW.h * 19 / 24)
	love.graphics.print("delete save file", WINDOW.w * 2 / 3, WINDOW.h * 21 / 24)
	love.graphics.print("write to save file", WINDOW.w * 2 / 3, WINDOW.h * 23 / 24)
	
	--...plus boxes for said buttons
	for i = 0, 23, 2 do
		love.graphics.rectangle("line", WINDOW.w * 2 / 3 - hSpace, WINDOW.h * i / 24, WINDOW.w, WINDOW.h * (i + 2) / 24)
	end
	
	--square interaction test stuff
	drawSquare()
	
	--image(s)
	-- love.graphics.draw(THUNDER, WINDOW.w - 250 * THUNDER_SCALE, WINDOW.h - 256 * THUNDER_SCALE, 0, THUNDER_SCALE)
	
	--canvas stuff
	love.graphics.setCanvas()

	love.graphics.draw(mainCanvas, 0, 0)
	
	--canvasTest stuff
	if canvasTimer > 0 then
		love.graphics.setColor(255, 255, 255, 255 / canvasTimer)
		love.graphics.draw(mainCanvas, canvasTimer * hSpace * 3, canvasTimer * vSpace * 3, canvasTimer, 1 / (canvasTimer + 1))
	end
	
	--fake touch
	-- if showFakeTouch then
	-- 	love.graphics.setColor(255, 255, 255, 127)
	-- 	love.graphics.circle("fill", fakeTouch.x, fakeTouch.y, 10)
	-- end
end

function love.update(dt)
	if canvasTimer > 10 then
		canvasTimer = -1
	elseif canvasTimer >= 0 then
		--do stuff
		canvasTimer = canvasTimer + dt
	end
		
	updateSquare(dt)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	pressSquare(tostring(id), x, y)
end
function love.mousepressed(x, y, button, istouch)
	if istouch then return end
	
	pressSquare(button, x, y)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	moveSquare(tostring(id), x, y, dx, dy)
end
function love.mousemoved(x, y, dx, dy, istouch)
	if istouch then return end
	
	if love.mouse.isDown(1) then
		moveSquare(1, x, y, dx, dy)
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	LAST_TOUCHRELEASED = {x=x, y=y, dx=dx, dy=dy, pressure=pressure}--, id=id} --TODO
	
	releaseSquare(tostring(id), x, y)
end
function love.mousereleased(x, y, button, istouch)
	LAST_MOUSERELEASED = {x=x, y=y, button=button, istouch=istouch}
	
	react(x, y)
	
	if istouch then return end
	
	releaseSquare(button, x, y)
end

function love.textinput(text)
	-- table.insert(inputText, text)
	-- infoList = inputText
	
	print(text)
	textInputBuffer = textInputBuffer..text
	infoMessage = textInputBuffer
	infoList = nil
end

function love.keypressed(key, scancode, isrepeat)
	--write key AND scancode to file
	-- if save then
	-- 	if key == "return" then
	-- 		print(save:write("SAVED "..os.time()))
	-- 	end
	-- end
	
	if key == "escape" then
		love.event.quit()
	end
	
	if key == "return" then
		print("return; buffer = "..textInputBuffer)
		
		--attempt to write to file
		writeToSaveFile(textInputBuffer)

		textInputBuffer = ""
	end
	
	if key == "backspace" and string.len(textInputBuffer) > 0 then
		textInputBuffer = string.sub(textInputBuffer, 1, -2)
		infoMessage = textInputBuffer
	end	
	
	-- --fake touches for pc testing...
	-- if key == "left" or key == "right" or key == "up" or key == "down" or key == "space" then
	-- 	showFakeTouch = true
	--
	-- 	if key == "left" then
	-- 		fakeTouch.x = fakeTouch.x - 20
	-- 	end
	-- 	if key == "right" then
	-- 		fakeTouch.x = fakeTouch.x + 20
	-- 	end
	-- 	if key == "up" then
	-- 		fakeTouch.y = fakeTouch.y - 20
	-- 	end
	-- 	if key == "down" then
	-- 		fakeTouch.y = fakeTouch.y + 20
	-- 	end
	-- 	if key == "space" then
	-- 		--trigger click? what about other callbacks? this is actually kind of a dumb idea...
	-- 	end
	-- end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function react(x, y)
	local g = x / WINDOW.w * 128
	local b = y / WINDOW.h * 128
	love.graphics.setBackgroundColor(128, g, b)
	
	TOUCHES = TOUCHES + 1
	TEXT = TOUCHES.." touches"
	
	--right-hand buttons with test info
	if x > WINDOW.w * 2 / 3 then
		showSquare = false
		
		--first 5 are just debug data
		if y < WINDOW.h * 1 / 12 then
			infoList = WINDOW.flags
		elseif y < WINDOW.h * 2 / 12 then
			infoList = love.graphics.getSystemLimits()
		elseif y < WINDOW.h * 3 / 12 then
			infoList = love.graphics.getCanvasFormats()
		elseif y < WINDOW.h * 4 / 12 then
			infoList = love.graphics.getSupported()
		elseif y < WINDOW.h * 5 / 12 then
			infoList = love.graphics.getCompressedImageFormats()
		--others are specialized...
		elseif y < WINDOW.h * 6 / 12 then
			--thunder!
			love.audio.stop(THUNDER_SFX)
			love.audio.play(THUNDER_SFX)
			love.system.vibrate(THUNDER_SCALE)
		elseif y < WINDOW.h * 7 / 12 then
			--keyboard test
			love.keyboard.setTextInput(true)
		elseif y < WINDOW.h * 8 / 12 then
			--start canvas test
			canvasTimer = 0
		elseif y < WINDOW.h * 9 / 12 then
			--initialize interactive square thing
			initSquare()
		elseif y < WINDOW.h * 10 / 12 then
			--read save, output some other info
			readSaveFile()
		elseif y < WINDOW.h * 11 / 12 then
			--delete save
			deleteSaveFile()
		elseif y < WINDOW.h * 12 / 12 then
			--write to save
			writeToSaveFile()
		end
	end
end

-- function openSaveFile()
-- 	save = love.filesystem.newFile("save.txt")
--
-- 	if saveExists() then
-- 		save:open("a")
-- 		print("opened for appending")
-- 	else
-- 		save:open("w")
-- 		save:write("first line "..os.time().."\n")
-- 		print("opened for writing, wrote one line")
-- 	end
-- end

function readSaveFile()
	--DEBUG
	-- print()
	-- print(infoList.getIdentity)
	
	--actually read the file
	if saveExists() then
		-- save = love.filesystem.newFile("save.txt")
		print(save:open("r"))
		
		infoList = {}
		for line in save:lines() do
			print(line)
			table.insert(infoList, line)
		end
		
		--DEBUG?
		print(save:isEOF())
		print(save:isOpen())
		
		print(save:close())
	else
		infoMessage = "can't read, no file"
		infoList = nil
	end
end

function deleteSaveFile()
	if saveExists() then
		print()
		print(love.filesystem.remove("save.txt"))

		infoMessage = "save file deleted."
		infoList = nil
	else
		infoMessage = "can't delete, save file does not exist."
		infoList = nil
	end
	--else print to screen
end

function writeToSaveFile(text)
	-- print(text)
	if saveExists() then
		text = text or "APPEND "..os.time()

		print()
		print(save:open("a"))
		print(save:write(text.."\n"))
		print(save:close())

		infoMessage = "appended \""..text.."\""
		infoList = nil
	else
		text = text or "FIRST LINE "..os.time()
		
		infoMessage = "attempting to open and write to new file..."
		
		print()
		local success, err = save:open("w")
		infoMessage = infoMessage.."\n"..tostring(success).."\n"..tostring(err)
		
		local success, err = save:write(text.."\n")
		infoMessage = infoMessage.."\n"..tostring(success).."\n"..tostring(err)
		
		local success, err = save:close()
		infoMessage = infoMessage.."\n"..tostring(success).."\n"..tostring(err)
		
		-- infoMessage = "created new file\nwrote \""..text.."\""
		infoList = nil
	end
	

	-- 	if saveExists() then
	-- 		save:open("a")
	-- 		print("opened for appending")
	-- 	else
	-- 		save:open("w")
	-- 		save:write("first line "..os.time().."\n")
	-- 		print("opened for writing, wrote one line")
	-- 	end
end

function saveExists()
	return love.filesystem.exists("save.txt")
end


--problems...
	--opening the app from home screen (or app list) always calls load(), even if the app is already open. some attempts to address...
		--x http://stackoverflow.com/questions/7380507/how-do-i-make-a-home-screen-application-not-be-recreated-when-pressing-the-home
		--  http://stackoverflow.com/questions/151777/saving-android-activity-state
		--  http://stackoverflow.com/questions/9423640/how-do-i-prevent-my-android-app-from-resetting-every-time-my-phone-sleeps
		--x http://stackoverflow.com/questions/2059344/retaining-android-app-state-using-alwaysretaintaskstate-and-lauchmode#
		--  https://love2d.org/forums/viewtopic.php?f=4&t=82192&p=210054#p210054
				-- Yeah, I may have to rely on those things, as long as they do fire when the app is hidden (I believe you, I just need to see for myself). It'll be a pain to save and restore all the data at any possible moment in the game, but I guess it's necessary, anyway, since Android can close your game at any time to free up memory. I'm planning to have a lot of different states, like overworld exploration, shopping, battle, menus.... Guess I'll just have to simplify. :)
  --...so basically you need to save state constantly. need to, anyway, for random memory dump[l]ing
	--not all screens have the same resolution... need to stretch fully, letterbox as big as possible, or letterbox "cleanly" so pixels aren't blurred
	  --ios devices are either 3:4 (ipads) or 9:16 (or 3:5.333; iphones)
		--android... my samsung is 9:16, dustin's is 45:74 (or 3:4.933)
		--stretch: just draw canvas at screen w/h. touch input has to be scaled, too, though
		--crop (with black bars): actually not bad for a menu-based RPG... just find true resolution and make canvas as big as possible
		--alternative: always draw at max size, but have variable-size elements. probably harder but better-looking
		--good for testing here: take cmd line args for screen resolutions!
		--maybe good advice, from this silly site https://v-play.net/doc/vplay-different-screen-sizes/: 3:4.5 might be a good aspect ratio to design for. 3:4 and 9:16 are worst-casey
		--MAYBE do the thing where there are overflow visuals on the edges of the screen. seems complicated and not that good-looking, though.... letterboxing would be way easier