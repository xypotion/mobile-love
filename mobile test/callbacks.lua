function love.visible(visible)
	writeToSaveFile("VISIBLE = "..tostring(visible).." at "..os.time())
end

function love.focus(focus)
	writeToSaveFile("FOCUS = "..tostring(focus).." at "..os.time())
	
	if not focus then
		writeAutosave()
	end
end

function love.resize(w, h)
	writeToSaveFile("RESIZE to "..w..", "..h.." at "..os.time())
end

function love.quit()
	writeToSaveFile("QUIT at "..os.time())
	
	if not focus then
		writeAutosave()
	end
end

function love.lowmemory()
	writeToSaveFile("LOW MEMORY at "..os.time())
	writeToSaveFile("current usage = "..collectgarbage("count").." KB")

	writeToSaveFile("collecting garbage")
	collectgarbage()
	
	writeToSaveFile("current usage = "..collectgarbage("count").." KB")
end

--callback test cases (case --> behavior; [multiple, simultaneous, events]):
	--tap icon, recents, other app, recents, game 																--> load, focus f, focus t
	--tap icon, recents, game 																										--> load, focus f, focus t
	--tap icon, recents, back button 																							--> load, focus f, focus t
	--tap icon, recents, close game with x, other app, home button, tap icon 			--> load, focus f, load
	--tap icon, recents, close game with swipe, other app, home button, tap icon 	--> load, focus f, load
	--tap icon, home button, tap icon 																						--> load, focus f, [quit, load]. weird
	--tap icon, home button, recents, game 																				--> load, focus f, focus t
	--tap icon, back button, tap icon 																						--> load, quit, load
	--tap icon, screen off, wait 10s, screen on 																	--> load, [focus f, focus t]. actually not simultaneous, but <1s apart
	--tap icon, screen off, wait a few minutes, screen on 												--> load, focus f, focus t about 18s later (not the time the screen was turned back on). weeird :[
	--tap icon, wait for screen off, wait 10s, screen on 													--> ... screen doesn't turn off -_-
	--tap icon, home button, stop process in dev settings, recents, game					--> load, focus f, load
	--tap icon, recents, other app, memory hogging (other apps), tap icon 				--> load, focus f, load
	--tap icon, recents, other app, memory hogging (other apps), recents, game 		--> load, focus f, load. no call to quit() or lowmemory(), the process just dies...
	--tap icon, memory hogging (game; load a bunch of images?)										--> 
	--tap icon, recents, chrome, download & install new version, open							--> 
	--tap icon, recents, chrome, download & install new version, recents, game		--> 
	--tap icon, crash, home button, tap icon																			--> crash *popup* appears, but neither 'OK' nor 'Cancel' triggers a callback. just load()s on resume
	
--conclusions/thoughts:
	--tapping app icon from the home screen always calls load(), so you need to save & load game's state a lot :/
	--love.focus(false) seems to be the most common thing that's triggered by these cases. probably the most important place to implement auto-save/suspend
	--love.quit is rare but sometimes called without love.focus(false), so it also needs to call auto-save
	--...except, infuriatingly, there are cases that don't call either quit OR focus(false), so you should just auto-save every 60s or so. you were maybe gonna do that anyway, but... ugh.
	--basically some of these behaviors don't make sense, but you can probably work around them. :I
	--also it's hard to get memory-hogging to happen. i have yet to see love.lowmemory called... maybe it's about memory hogging IN the game, not in other apps?
	
	
	

--stores various state variables in "autosave.txt", to be called in the next load()
function writeAutosave()
	local data = tostring(showSquare)
	data = data..","..math.floor(square.x)
	data = data..","..math.floor(square.y)
	
	print(autosave:open("w"))
	print(autosave:write(data))
	print(autosave:close())
end

function autosaveExists()
	return love.filesystem.exists("autosave.txt")
end

--reads "autosave.txt" and sets the relevant variables. there might be a better way to do this, but... meh?
function readAutosave()
	print(autosave:open("r"))
	
	--there's no split(), gods help us
	for line in autosave:lines() do
		print(line)
		local bits = {}
		for bit in string.gmatch(line, "[-%a%d]+") do
			print("BIT: "..bit)
			table.insert(bits, bit)
		end
		
		showSquare = toboolean(bits[1])
		square.x = tonumber(bits[2])
		square.y = tonumber(bits[3])
		print(toboolean(bits[1]), tonumber(bits[2]), tonumber(bits[3]))
	end
	
	print(autosave:close())
end


--duh
function toboolean(str)
	return str == "true"
end

--after implementing above:
	--(on laptop, no autosave file) run from terminal, close													--> square does not appear, autosave created
	--(on laptop, no autosave file) run from terminal, close, repeat									--> square does not appear either time, autosave created
	--('') run from terminal, show square, close, rerun																--> square loaded correctly
	--('') run, show square, hide square, close, rerun																--> square (correctly) does not appear
	--('') run, do stuff, change focus and close game (cmd+c) 												--> correct behavior
	--on phone...																													--> success! state saved when returning to app from home screen or recents :)