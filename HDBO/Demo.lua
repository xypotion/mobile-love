function updateDemo(dt)
	debugNum = debugNum + dt
end

function drawDemo()
	love.graphics.setColor(255, 255, 127)
	love.graphics.rectangle("fill", 100, 100, 200, 200)
	
	love.graphics.print(debugNum, 100, 400)
end

function autosaveDataForDemo()
end

function createDemoFromAutosaveData(data)
end