function love.load()
	math.randomseed(os.time())
	
	--canvas setup? nope, start simple
	
	--scaling & window math
	love.window.setMode(384, 736)
	
	c1 = {r = math.random(256), g = math.random(256), b = math.random(256)}
	c2 = {r = math.random(256), g = math.random(256), b = math.random(256)}
	
	s1 = {x = 96, y = 96}
	s1r = {x = 384, y = 96}
	
	squidth = 192
	currentS1 = 1
	
	slideCountdown = 0
end

function love.update(dt)
	if not clickedInSquare1 then
		
		-- --slide to center
		-- if slideCountdown > 0 and s1.x ~= 96 then
		-- 	s1.x = (s1.x - 96) * 0.8 + 96
		-- 	-- print(s1.x)
		-- 	slideCountdown = slideCountdown - dt
		-- else
		-- 	s1.x = 96
		-- end
		
		--slide to center
		if slideCountdown > 0 then 
		-- for --not yet. table the squares, though
			s1.x = (s1.x - 96) * 0.8 + 96
			s1r.x = (s1r.x - 384) * 0.8 + 384
			
			slideCountdown = slideCountdown - dt
		
		else
			s1.x = 96
		end
	end
end

function love.draw()
	love.graphics.rectangle("line", 32, 32, 320, 320)
	love.graphics.rectangle("line", 32, 384, 320, 320)
	
	--square 1
	love.graphics.setColor(c1.r, c1.g, c1.b)
	love.graphics.rectangle("fill", s1.x, s1.y, squidth, squidth)
	
	--square 1r
	love.graphics.rectangle("fill", s1r.x, s1r.y, squidth, squidth)
	
	--square 2
	love.graphics.setColor(c2.r, c2.g, c2.b)
	love.graphics.rectangle("fill", 96, 448, squidth, squidth)
	
	love.graphics.setColor(255, 255, 255)
end

function love.mousepressed(x, y, button, istouch)
	if x > 96 and x < 96 + squidth and y > 96 and y < 96 + squidth then
		clickedInSquare1 = true
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if clickedInSquare1 then
		-- print(x, y, dx, dy, istouch)
		s1.x = s1.x + dx
		s1r.x = s1r.x + dx
		
	end
end

function love.mousereleased(x, y, button, istouch)
	
	if math.abs(384/2 - (s1.x + squidth)) > math.abs(384/2 - s1r.x) then
		--s1r
		currentS1 = 2
		clickedInSquare1 = false
		slideCountdown = 1
	else
		--s1
		currentS1 = 1
		clickedInSquare1 = false
		slideCountdown = 1
	end
	print(currentS1)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end