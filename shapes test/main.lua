--"why is this in workspace/mobile love?" answer: because these shapes are supposed to be used as enemy types in your ocean-themed BE prototype game.

function love.load()
	--precalculate sines
	-- sines = {}
	-- for i = 1, 25 do
	-- 	sines[i] = math.sin(i / 2 / math.pi)
	-- 	print(sines[i])
	-- end
	-- ...ugh, not important right now
	
	timer = 0
	
	pi = math.pi
	qpi = math.pi / 4
	
	love.graphics.setLineWidth(2)
end

function love.update(dt)
	timer = timer + dt * 2
	sin1 = math.sin(timer)
	cos1 = math.cos(timer)
	tan1 = math.tan(timer)
	sin2 = math.sin(timer * 2)
	cos2 = math.cos(timer * 2)
	
	--differently-phased sine timers for the beam ball
	sinP2 = math.sin(timer + qpi)
	sinP3 = math.sin(timer + qpi * 2)
	sinP4 = math.sin(timer + qpi * 3)
	cosP2 = math.cos(timer + qpi)
	cosP3 = math.cos(timer + qpi * 2)
	cosP4 = math.cos(timer + qpi * 3)
end

function love.draw()
	--flipping rectangles
	love.graphics.rectangle("fill", 100, 100, cos1 * 25, sin1 * -25)
	love.graphics.rectangle("fill", 100, 100, cos1 * -25, sin1 * 25)
	
	--flailing rectangles
	love.graphics.rectangle("fill", 100, 200, cos1 * 25, sin1 * -25)
	love.graphics.rectangle("fill", 100, 200, cos2 * 25, sin2 * 25)
	
	--gyrator 1
	-- yellow()
	love.graphics.polygon("fill", 75, 275, sin1 * 10 + 100, cos1 * 10 + 290, sin1 * 10 + 90, cos1 * 10 + 300)
	love.graphics.polygon("fill", 125, 275, sin1 * 10 + 100, cos1 * 10 + 290, sin1 * 10 + 110, cos1 * 10 + 300)
	love.graphics.polygon("fill", 125, 325, sin1 * 10 + 100, cos1 * 10 + 310, sin1 * 10 + 110, cos1 * 10 + 300)
	love.graphics.polygon("fill", 75, 325, sin1 * 10 + 100, cos1 * 10 + 310, sin1 * 10 + 90, cos1 * 10 + 300)
	love.graphics.circle("fill", 100 + sin1 * 10, 300 + cos1 * 10, 5)
	
	--gyrator 2
	yellow()
	love.graphics.polygon("fill", 75, 375, sin1 * 10 + 100, cos1 * 10 + 375, sin1 * 10 + 75, cos1 * 10 + 400)
	love.graphics.polygon("fill", 125, 375, sin1 * 10 + 100, cos1 * 10 + 375, sin1 * 10 + 125, cos1 * 10 + 400)
	love.graphics.polygon("fill", 125, 425, sin1 * 10 + 100, cos1 * 10 + 425, sin1 * 10 + 125, cos1 * 10 + 400)
	love.graphics.polygon("fill", 75, 425, sin1 * 10 + 100, cos1 * 10 + 425, sin1 * 10 + 75, cos1 * 10 + 400)
	-- white()
	love.graphics.circle("fill", 100 + sin1 * 5, 400 + cos1 * 5, 15)
	-- love.graphics.circle("fill", 100 + sin1 * 10, 400 + cos1 * 10, 15)
	-- love.graphics.circle("fill", 100, 400, 15)
	
	white()
	
	--spinner
	-- love.graphics.polygon("fill", sin1 * 20 + 100, cos1 * 20 + 400,  cos1 * 10 + 100, sin1 * -10 + 400,  sin1 * -10 + 100, cos1 * -10 + 400)
	
	--circles 1
	love.graphics.circle("fill", 100 + cos1 * 20, 500 + sin1 * 10, 20)
	love.graphics.circle("fill", 100 + sin1 * 20, 500 + cos1 * -10, 20)
	love.graphics.circle("fill", 100 + cos1 * -20, 500 + sin1 * -10, 20)
	love.graphics.circle("fill", 100 + sin1 * -20, 500 + cos1 * 10, 20)
	
	--circles 2
	love.graphics.circle("fill", 200 + cos1 * 20, 500 + sin1 * 20, 20)
	love.graphics.circle("fill", 200 + sin1 * 20, 500 + cos1 * -20, 20)
	love.graphics.circle("fill", 200 + cos1 * -20, 500 + sin1 * -20, 20)
	love.graphics.circle("fill", 200 + sin1 * -20, 500 + cos1 * 20, 20)
	
	--diamonds 1
	love.graphics.circle("fill", 300 + cos1 * 15, 500 + sin1 * 10, 20, 4)
	love.graphics.circle("fill", 300 + sin1 * 15, 500 + cos1 * -10, 20, 4)
	love.graphics.circle("fill", 300 + cos1 * -15, 500 + sin1 * -10, 20, 4)
	love.graphics.circle("fill", 300 + sin1 * -15, 500 + cos1 * 10, 20, 4)
	
	--ellipses 1
	love.graphics.ellipse("fill", 200 + cos1 * 20, 400 + sin1 * 20, 25, 15)
	love.graphics.ellipse("fill", 200 + sin1 * 20, 400 + cos1 * -20, 15, 25)
	love.graphics.ellipse("fill", 200 + cos1 * -20, 400 + sin1 * -20, 25, 15)
	love.graphics.ellipse("fill", 200 + sin1 * -20, 400 + cos1 * 20, 15, 25)
	love.graphics.circle("fill", 200, 400, 10)
	black()
	love.graphics.circle("fill", 200, 400, 7)
	white()
	
	--diamonds 2
	love.graphics.ellipse("fill", 200 + cos1 * 20, 300 + sin1 * 20, 25, 20, 4)
	love.graphics.ellipse("fill", 200 + sin1 * 20, 300 + cos1 * -20, 20, 25, 4)
	love.graphics.ellipse("fill", 200 + cos1 * -20, 300 + sin1 * -20, 25, 20, 4)
	love.graphics.ellipse("fill", 200 + sin1 * -20, 300 + cos1 * 20, 20, 25, 4)
	black()
	love.graphics.circle("fill", 200, 300, 7, 4)
	white()
	-- love.graphics.circle("fill", 200, 300, 10)
	
	--oscillating moire
	
	--pokey star
	-- love.graphics.polygon("line", 260, 150, 300, 50, 340, 150, 250, 80, 350, 80)
	--well, shit. that doesn't work.
	
	--gooey?
	love.graphics.ellipse("fill", 200, 100, 25 + sin2 * 5, 15 + cos2 * 5)
	
	--?
	-- love.graphics.ellipse("fill", 300, 100, 40, 30, 5, 10, 10)
	
	--cone beam
	love.graphics.ellipse("line", 300, 150 + ((timer/2 + 0.0) % 1.6) * 40, ((timer/2 + 0.0) % 1.6) * 25 + 5, ((timer/2 + 0.0) % 1.6) * 5 + 2)
	love.graphics.ellipse("line", 300, 150 + ((timer/2 + 0.4) % 1.6) * 40, ((timer/2 + 0.4) % 1.6) * 25 + 5, ((timer/2 + 0.4) % 1.6) * 5 + 2)
	love.graphics.ellipse("line", 300, 150 + ((timer/2 + 0.8) % 1.6) * 40, ((timer/2 + 0.8) % 1.6) * 25 + 5, ((timer/2 + 0.8) % 1.6) * 5 + 2)
	love.graphics.ellipse("line", 300, 150 + ((timer/2 + 1.2) % 1.6) * 40, ((timer/2 + 1.2) % 1.6) * 25 + 5, ((timer/2 + 1.2) % 1.6) * 5 + 2)
	love.graphics.circle("fill", 300, 190, 15)
	
	--inverse cone beam
	love.graphics.ellipse("line", 300, 250 + ((timer + 0.0) % 1.6) * 40, 40 - ((timer + 0.0) % 1.6) * 25, 8 - ((timer + 0.0) % 1.6) * 5)
	love.graphics.ellipse("line", 300, 250 + ((timer + 0.4) % 1.6) * 40, 40 - ((timer + 0.4) % 1.6) * 25, 8 - ((timer + 0.4) % 1.6) * 5)
	love.graphics.ellipse("line", 300, 250 + ((timer + 0.8) % 1.6) * 40, 40 - ((timer + 0.8) % 1.6) * 25, 8 - ((timer + 0.8) % 1.6) * 5)
	love.graphics.ellipse("line", 300, 250 + ((timer + 1.2) % 1.6) * 40, 40 - ((timer + 1.2) % 1.6) * 25, 8 - ((timer + 1.2) % 1.6) * 5)
	
	--beam diamond (combination of cone beams, filled, kind of)
	yellow()
	love.graphics.ellipse("fill", 400, 150 + ((timer + qpi * 0) % pi) * 25, sin1 * 50, sin1 * 5)
	love.graphics.ellipse("fill", 400, 150 + ((timer + qpi * 1) % pi) * 25, sinP2 * 50, sinP2 * 5)
	love.graphics.ellipse("fill", 400, 150 + ((timer + qpi * 2) % pi) * 25, sinP3 * 50, sinP3 * 5)
	love.graphics.ellipse("fill", 400, 150 + ((timer + qpi * 3) % pi) * 25, sinP4 * 50, sinP4 * 5)
	white()
	
	--beam ball... but i don't like it as much!
	-- love.graphics.ellipse("fill", 400, 200 + cos1 * 50, sin1 * 50, sin1 * 5)
	-- love.graphics.ellipse("fill", 400, 200 + cosP2 * 50, sinP2 * 50, sinP2 * 5)
	-- love.graphics.ellipse("fill", 400, 200 + cosP3 * 50, sinP3 * 50, sinP3 * 5)
	-- love.graphics.ellipse("fill", 400, 200 + cosP4 * 50, sinP4 * 50, sinP4 * 5)
	
	--pulser 1
	love.graphics.circle("fill", 300, 400, 20 + sin1 * 20)
	love.graphics.circle("fill", 300, 400, 20 + cos1 * 20)
	love.graphics.circle("fill", 300, 400, 20 + sin1 * -20)
	love.graphics.circle("fill", 300, 400, 20 + cos1 * -20)
	
	--many-shape 1
	love.graphics.circle("fill", 400, 400, 20 + sin1 * 20, 4)
	love.graphics.circle("fill", 400, 400, 20 + cos1 * 20, 8)
	love.graphics.circle("fill", 400, 400, 20 + sin1 * -20, 4)
	love.graphics.circle("fill", 400, 400, 20 + cos1 * -20, 6)
	
	--many-shape 2
	love.graphics.circle("fill", 500, 400, 20 + sin1 * 20, 4)
	love.graphics.circle("fill", 500, 400, 20 + cos1 * 20, 8)
	love.graphics.circle("fill", 500, 400, 20 + sin2 * -20, 4)
	love.graphics.circle("fill", 500, 400, 20 + cos1 * -20, 6)
	
	--pulser 2
	love.graphics.circle("fill", 400, 500, 20 + sin1 * 20)
	love.graphics.circle("fill", 400, 500, 20 + cos1 * 20, 4)
	love.graphics.circle("fill", 400, 500, 20 + sin1 * -20)
	love.graphics.circle("fill", 400, 500, 20 + cos1 * -20, 4)
	
	--pulser 3, slimer
	yellow()
	love.graphics.circle("fill", 495, 505, 20 + sin2 * 15)
	love.graphics.circle("fill", 495, 495, 20 + cos2 * 15)
	love.graphics.circle("fill", 505, 495, 20 + sin2 * -15)
	love.graphics.circle("fill", 505, 505, 20 + cos2 * -15)
	white()
	
	--slimer 2
	love.graphics.ellipse("fill", 595, 505, 20 + sin2 * 15, 15 + sin2 * 15)
	love.graphics.ellipse("fill", 595, 495, 20 + cos2 * 15, 15 + cos2 * 15)
	love.graphics.ellipse("fill", 605, 495, 20 + sin2 * -15, 15 + sin2 * -15)
	love.graphics.ellipse("fill", 605, 505, 20 + cos2 * -15, 15 + cos2 * -15)
	
	--fuzz grid
	-- for i = 1, 10 do
	-- 	for j = 1, 10 do
	-- 		if timer % (0.95 + 1/j + 1/i) > 1 then
	for i = -4, 3 do
		for j = -4, 3 do
			if (i * i + j * j * cos2) % 70 < 20 then
				white()
			else
				black()
			end
			love.graphics.rectangle("fill", 600 + i * 10, 100 + j * 10, 20, 20)
		end
	end
	white()
	
	--flasher
	-- love.graphics.arc("line", "closed", 400, 300, 25, 0, timer % pi) --ha, arc type not supported in 10.0 :P
	love.graphics.arc("fill", 400, 300, 45, 0, sinP3)
	love.graphics.arc("fill", 400, 300, 45, qpi * 2, qpi * 2 + sinP2)
	love.graphics.arc("fill", 400, 300, 45, qpi * 4, qpi * 4 + sinP3)
	love.graphics.arc("fill", 400, 300, 45, qpi * 6, qpi * 6 + sinP2)
	
	--flasher 2
	yellow()
	love.graphics.arc("fill", 500, 300, 45, (qpi * 1 + timer) % (pi * 2), (qpi * 1+ timer) % (pi * 2) + sin1 * sin1)
	love.graphics.arc("fill", 500, 300, 45, (qpi * 3 + timer) % (pi * 2), (qpi * 3 + timer) % (pi * 2) + cos1 * cos1)
	love.graphics.arc("fill", 500, 300, 45, (qpi * 5 + timer) % (pi * 2), (qpi * 5 + timer) % (pi * 2) + sin1 * sin1)
	love.graphics.arc("fill", 500, 300, 45, (qpi * 7 + timer) % (pi * 2), (qpi * 7 + timer) % (pi * 2) + cos1 * cos1)
	black()
	love.graphics.circle("fill", 500, 300, 20)
	white()

end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function white()
	love.graphics.setColor(255,255,255)
end

function black()
	love.graphics.setColor(0,0,0)
end

function yellow()
	love.graphics.setColor(255, 255, 0)
end