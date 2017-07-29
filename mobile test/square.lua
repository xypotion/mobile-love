--wrong approach below? maybe just change behavior based on the number of current presses? 1 touch = drag when moving, 2 touches = resize/turn and NOT drag? can flip between on the fly?

--initialize and show square
function initSquare(hide)
	-- squareScale = WINDOW.w / 1000
	squareElement = 1
	
	square = {x = WINDOW.w / 6, y = WINDOW.h / 2, scale = WINDOW.w / 1000}
	
	showSquare = true
	
	presses = {}
	
	numPresses = 0 --ugh
	
	currentDistance = 1
end

function drawSquare()
	if not showSquare then return end

	love.graphics.draw(getSquareGraphic(), square.x, square.y, 0, square.scale)
end

function updateSquare(dt)
	if not showSquare then return end
	
	for k, v in pairs(presses) do
		-- print(k,v.time, v.x, v.y)
		presses[k].time = v.time + dt
	end
	
	-- --pinching; zoom
	-- if #presses == 2 then
	-- 	local midpoint = {x = 0, y = 0}
	-- 	for k,v in pairs(presses) do
	-- 		midpoint.x = midpoint.x + v.x
	-- 		midpoint.y = midpoint.y + v.y
	-- 	end
	--
	-- 	--move square
	-- 	something
	-- end
	
	infoMessage = 
		"showSquare = "..tostring(showSquare).."\n"..
		"numPresses = "..numPresses.."\n"..
		"square scale = "..square.scale.."\n"..
		"currentDistance = "..currentDistance.."\n"
end

function pressSquare(id, x, y)
	if not showSquare then return end
		
	presses["touch"..id] = {time = 0, x = x, y = y, insideSquare = pointInsideSquare(x, y)} -- tracking insideSquare from beginning is necessary
	numPresses = numPresses + 1
	
	--set currentDistance, for pinch zoom/move calculation
	--if moveSquare is called first, scale might go nuts...
	if numPresses == 2 then
		local op = getOtherPress(id)
		currentDistance = euDistance(x, y, op.x, op.y)
	end 
end

function moveSquare(id, x, y, dx, dy)
	if not showSquare then return end
	
	if numPresses == 2 then
		--get other press
		local op = getOtherPress(id) -- this is so stupid, i swear :[
		
		if presses["touch"..id].insideSquare and presses["touch"..op.id].insideSquare then
			-- get new distance
			local newDistance = euDistance(x, y, op.x, op.y)
		
			-- get scale between current and new distance
			local scale = newDistance / currentDistance
		
			-- get midpoint
			local midpoint = {x = (x + op.x) / 2, y = (y + op.y) / 2}
		
			-- set scale and x/y based on midpoint
			square.scale = square.scale * scale
			square.x = midpoint.x - square.scale * 250 / 2
			square.y = midpoint.y - square.scale * 256 / 2
		
			-- get current distance for next time
			currentDistance = newDistance
		end
	else
		
	-- pinching; zoom
	-- if #presses == 2 then
	-- 	local midpoint = {x = 0, y = 0}
	-- 	for k,v in pairs(presses) do
	-- 		midpoint.x = midpoint.x + v.x
	-- 		midpoint.y = midpoint.y + v.y
	-- 	end
	--
	-- 	--move square
	-- 	something
	-- end
	
	-- --update individual press
	-- local p = presses["touch"..id]
	-- presses["touch"..id] = {x = p.x + dx, y = p.y + dy, time = p.time}
	--
	-- local midpoint = {x=0, y=0, elements=0}
	-- for k, v in pairs(presses) do
	-- 	-- presses[k].x = x
	-- 	-- presses[k].y = y
	--
	-- 	--for finding the midpoint
	-- 	midpoint.x = midpoint.x + x
	-- 	midpoint.y = midpoint.y + y
	-- 	midpoint.elements = midpoint.elements + 1
	-- end
	--
	-- --midpoint calculation (i guess)
	-- midpoint.x, midpoint.y = midpoint.x / midpoint.elements, midpoint.y / midpoint.elements

	-- actually move square
		if presses["touch"..id] and presses["touch"..id].insideSquare then -- pre-set press.insideSquare is better than checking x and y now for a couple reasons
			square.x = square.x + dx
			square.y = square.y + dy
		-- 	square.x = midpoint.x
		-- 	square.y = midpoint.y
		end
	end
end

function releaseSquare(id, x, y)
	if not showSquare then return end
	if not presses["touch"..id] then return end --hack!! 
	
	local press = presses["touch"..id]

	print(id, press.time, press.x, press.y)

	if press.time < 0.25 then
		tapSquare(id, x, y)
	end

	--remove that press ~
	presses["touch"..id] = nil
	numPresses = numPresses - 1
end

function tapSquare(id, x, y)
	if not showSquare then return end
	
	if pointInsideSquare(x, y) then
		changeSquareElement()
	end
end

function changeSquareElement()
	squareElement = squareElement % 3 + 1
end

function getSquareGraphic()
	if squareElement == 1 then return FIRE end
	if squareElement == 2 then return ICE end
	if squareElement == 3 then return THUNDER end
	--inefficient, i know. whatever.
end

function pointInsideSquare(x, y)
	return x >= square.x and x <= square.x + 250 * square.scale and y >= square.y and y <= square.y + 256 * square.scale
end

function getOtherPress(id)
	local twoPresses = love.touch.getTouches()
	
	if twoPresses[1].id == id then
		return twoPresses[2]
	else
		return twoPresses[1]
	end
end

function euDistance(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end