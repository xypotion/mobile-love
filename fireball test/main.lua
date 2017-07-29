local ONE_THIRD = 1/3
local TWO_THIRDS = ONE_THIRD * 2

function love.touchreleased(id, x, y, dx, dy, pressure)
	love.keypressed('f')
	LAST_TOUCH = {x, y, dx, dy, pressure}
end

function love.load()
	LAST_TOUCH = {"hello", "world"}
	math.randomseed(os.time())
	-- math.randomseed(205) --good stuff on T
	-- math.randomseed(986) --dustin's choice
	
	--basics
	screenWidth = 320
	screenHeight = 480
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	love.graphics.setNewFont(20)
	
	paused = false
	
	--some object properties
	hoverHeight = 20
	
	wizardSize = 20
	wizardSpeed = 200
	
	enemySize = 10
		
	--actual objects
	wizard = {x=screenWidth/2, y = screenHeight - wizardSize * 2}
	
	makeEnemy()
	
	fireball = nil -- soon.
	
	emitters = {}
	
	particles = {}
end

function love.update(dt)
	if paused then return end

	--moving the wizard?
	if love.keyboard.isDown("left", "right", "up", "down") then
		moveWizard(dt)
	end
	
	--update fireball if there is one
	if fireball then
		moveFireball(dt)
		
		--maybe add a particle
		if math.random() < fireball.particleRate then
			addParticle(fireball.x, fireball.y, fireball.metaParticle)
		end
		
		--remove fireball if it hit the enemy
		if math.abs(fireball.distanceTraveled) >= math.abs(fireball.xDist) then
			explode(fireball)
			
			fireball = nil
			
			makeEnemy()
		end
	end
	
	--emitters: emit
	updateEmitters(dt)
	
	--update & remove dead particles
	updateParticles(dt)
end

function love.draw()
	--draw emitter shadows & emitters/puffers
	for i,e in pairs(emitters) do
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", e.x, e.y + hoverHeight, e.size * TWO_THIRDS, e.size * ONE_THIRD)
	
		love.graphics.setColor(e.color.r, e.color.g, e.color.b, e.color.a)
		love.graphics.circle("line", e.x, e.y, e.size, e.segments)
		if e.interval then 
			love.graphics.circle("line", e.x, e.y, e.size * 0.5, e.segments) 
		end
	end
	
	--draw wizard shadow & wizard
	love.graphics.setColor(31, 31, 31, 127)
	love.graphics.ellipse("fill", wizard.x, wizard.y + hoverHeight, wizardSize * TWO_THIRDS, wizardSize * ONE_THIRD)
		
	love.graphics.setColor(127, 127, 255)
	love.graphics.circle("fill", wizard.x, wizard.y, wizardSize)
	
	--draw enemy shadow & enemy
	if enemy then
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", enemy.x, enemy.y + hoverHeight, enemySize * TWO_THIRDS, enemySize * ONE_THIRD)

		love.graphics.setColor(127, 255, 127)
		love.graphics.circle("fill", enemy.x, enemy.y, enemySize)
	end
	
	--draw fireball shadow and fireball
	if fireball then
		if fireball.shadow then
			love.graphics.setColor(31, 31, 31, 127)
			love.graphics.ellipse("fill", fireball.sx, fireball.sy + hoverHeight, fireball.size * TWO_THIRDS, fireball.size * ONE_THIRD)
		end
	
		love.graphics.setColor(fireball.color.r, fireball.color.g, fireball.color.b, fireball.color.a)
		love.graphics.circle("fill", fireball.x, fireball.y, fireball.size, fireball.segments)
	end
	
	--draw particles
	for i = 1, #particles do
		local p = particles[i]
		love.graphics.setColor(p.r, p.g, p.b, p.a)
		love.graphics.circle("fill", p.x, p.y, p.size, p.segments)
	end
	
	--draw pause overlay
	if paused then
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf("Particles: "..#particles, 0, screenHeight * ONE_THIRD, screenWidth, "center")
		love.graphics.printf("Press keyboard keys for different effects!", 0, screenHeight * TWO_THIRDS, screenWidth, "center")
	end
	
	--TOUCH DEBUG
	if LAST_TOUCH then
		for k,v in pairs(LAST_TOUCH) do
 		 love.graphics.print(v, 0, k * 20)
		end
	end
end

--unused letters: yadjm
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	elseif key == "backspace" then
		table.remove(emitters)
	else
		print()
		if key == "f" then
			print("arcing fireball")
			startFireball("fire")
		elseif key == "i" then
			print("arcing ice ball")
			startFireball("ice")
		elseif key == "g" then
			print("go go go")
			startFireball("go")
		elseif key == "x" then
			print("x-beam")
			startFireball("x-beam")
		elseif key == "e" then
			print("summon constant emitter")
			makeEmitter("random tame", 1)
		elseif key == "k" then
			print("summon confetti emitter")
			makeEmitter("random wild", 1)
		elseif key == "p" then
			print("summon puffer")
			makeEmitter("random tame", 1, {interval = 1, burstSize = 20})
		elseif key == "b" then
			print("summon beamer")
			makeEmitter("x-beam spark", 1, {interval = 0.5, burstSize = 10})
		else
			--experimental stuff. should use named projectiles like above
			if key == "n" then
				print("linear fireball, no shadow")
				startFireball({speed=1, arc=0, shadow=false})
			elseif key == "l" then
				print("linear fireball")
				startFireball({speed=1, arc=0,})
			elseif key == "h" then
				print("high-arcing fireball")
				startFireball({speed=1, arc=20,})
			elseif key == "s" then
				print("shallow-arcing fireball")
				startFireball({speed=1, arc=3,})
			elseif key == "z" then
				print("arcing fireball, no shadow")
				startFireball({speed=1, arc=10, shadow=false})
			elseif key == "q" then
				print("quick linear fireball")
				startFireball({speed=2, arc=0,})
			elseif key == "w" then
				print("slow linear fireball")
				startFireball({speed=.5, arc=0,})
			elseif key == "u" then
				print("quick arcing fireball")
				startFireball({speed=2, arc=10,})
			elseif key == "o" then
				print("slow arcing fireball")
				startFireball({speed=0.5, arc=10,})
			elseif key == "v" then
				print("very hot arcing fireball")
				startFireball({speed=1, arc=5, particleRate=0.9, color = {r = 255, g = 255, b = 255, a = 255}})
			elseif key == "c" then
				print("very cold arcing fireball")
				startFireball({speed=1, arc=5, particleRate=0.1, color = {r = 15, g = 15, b = 15, a = 255}})
			elseif key == "t" then
				print("random-element ball")
			
				local params = {
					speed = math.random() + 0.5, 
					arc = math.sqrt(math.random(100)), 
					shadow = true,
					particleRate = math.random(), 
					metaParticle = "random tame"
				}
			
				startFireball(params)

				for k,v in pairs(fireball.metaParticle.variable) do
					print(v.min, v.var, k)
				end
			elseif key == "r" then	
				print("random confetti ball!!")
			
				local params = {
					speed = math.random() + 0.5, 
					arc = math.sqrt(math.random(100)), 
					shadow = true,
					particleRate = math.random(),
					metaParticle = "random wild"
				}
			
				startFireball(params)
			else
				print("\n'"..key.."' key not recognized...")
				love.keypressed("r")
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function moveWizard(dt)
	if love.keyboard.isDown("left") then
		wizard.x = wizard.x - dt * wizardSpeed
	end
	
	if love.keyboard.isDown("right") then
		wizard.x = wizard.x + dt * wizardSpeed
	end
	
	if love.keyboard.isDown("up") then
		wizard.y = wizard.y - dt * wizardSpeed
	end
	
	if love.keyboard.isDown("down") then
		wizard.y = wizard.y + dt * wizardSpeed
	end
end

--update particles (their ages, colors, locations, sizes, velocities, and acceleration), then kill if they're too old
function updateParticles(dt)
	for k,p in pairs(particles) do
		p.age = p.age + dt
		
		--move particle
		p.x = p.x + p.xVelocity * dt
		p.y = p.y + p.yVelocity * dt

		--change color (linear)
		p.r = p.r + p.deltaR * dt
		p.g = p.g + p.deltaG * dt
		p.b = p.b + p.deltaB * dt
		p.a = p.a + p.deltaA * dt
		
		--change size
		p.size = p.size + p.deltaSize * dt
		if p.size < 0 then 
			p.size = 0
		end
		
		--change velocities
		p.xVelocity = p.xVelocity + p.xAcceleration * dt
		p.yVelocity = p.yVelocity + p.yAcceleration * dt
		
		--change acceleration
		p.xAcceleration = p.xAcceleration + p.xJerk * dt
		p.yAcceleration = p.yAcceleration + p.yJerk * dt
		
		--release
		if p.age > p.maxAge then
			table.remove(particles, k)
		end
	end
end

function updateEmitters(dt)
	for i,e in pairs(emitters) do		
		if e.interval and e.interval > 0 then
			--it's a puffer. increment counter; burst and reset if interval surpassed
			e.counter = e.counter + dt
			
			if e.counter >= e.interval then
				for i = 1, e.burstSize do
					addParticle(e.x, e.y, e.metaParticle)
				end
				
				e.counter = e.counter % e.interval
			end
		else
			--it's a regular, constant emitter
			if math.random() < e.frequency then
				addParticle(e.x, e.y, e.metaParticle)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function makeEnemy()
	enemy = {
		x = math.random(screenWidth), 
		y = math.random(screenHeight)
	}
end

function makeEmitter(mpType, freq, other)
	local e = {
		x = math.random(screenWidth), 
		y = math.random(screenHeight),
		frequency = freq,
		metaParticle = makeMetaParticle(mpType),
		color = {
			r = 127 + math.random(128),
			g = 127 + math.random(128),
			b = 127 + math.random(128),
			a = 255
		},
		segments = 2 + math.random(3) * 2,
		size = 15,
		
		counter = 0,
		-- interval = 0,
		-- burstSize = 1
	}
	
	--add in special stuff. should just be for puffers (for now)
	if other then
		for k,v in pairs(other) do
			e[k] = v
		end
	end
	
	-- print(e.metaParticle)
	
	table.insert(emitters, e)
end

function startFireball(params)
	--i realize how gross this is to have near-duplicate functions, but it's transitional! startFireball() was experimental, but prefabProjectile() was the goal. TODO: consolidate
	if type(params) == "string" then
		fireball = prefabProjectile(params)
		return
	end
	
	--default fireball stuff
	fireball = {
		start = wizard, dest = enemy, 
		x = wizard.x, y = wizard.y,
		sx = wizard.x, sy = wizard.y,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		particleRate = 0.5,
		segments = 4,
		color = {r = 255, g = 255, b = 255, a = 255},
		arc = 10,
		speed = 1,
		particleRate = 0.5,
		shadow = true,
		size = 8,
	}
	
	--replace attributes as necessary
	for k,v in pairs(params) do
		fireball[k] = v
	end
	
	--make metaparticle
	fireball.metaParticle = makeMetaParticle(fireball.metaParticle)
	
	--should be simplified alongside the "elevation" refactor
	fireball.vector = {x = fireball.xDist, y = fireball.yDist}
	fireball.ascentSpeed = fireball.arc
	fireball.descentSpeed = fireball.ascentSpeed * 2
end

--i know this looks goofy as hell, but it's actually one of the main goals of this project: named spell animations! bear with me
function prefabProjectile(type)
	--default stuff
	proj = {
		start = wizard, 
		dest = enemy, 
		x = wizard.x, 
		y = wizard.y,
		sx = wizard.x, 
		sy = wizard.y,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		arc = 10,
		speed = 1,
		particleRate = 0.5,
		shadow = true,
		segments = 4,
		color = {r = 255, g = 255, b = 255, a = 255},
		size = 8,
	}
	
	--specifications
	if type == "fire" then
		proj.arc = 10
		proj.speed = 1
		
		proj.segments = 4
		proj.color = {r = 255, g = 127, b = 127, a = 255}

		proj.particleRate = 0.6
		proj.metaParticle = makeMetaParticle("fire trail")
	elseif type == "ice" then
		proj.arc = 7.5
		proj.speed = 1.25
		
		proj.segments = 12
		proj.color = {r = 247, g = 247, b = 255, a = 255}

		proj.particleRate = 0.8
		proj.metaParticle = makeMetaParticle("ice ball")
		
		proj.size = 10
	elseif type == "go" then
		proj.arc = 0
		proj.speed = 10
		
		proj.segments = 3
		proj.color = {r = 31, g = 247, b = 31, a = 255}

		proj.particleRate = 1
		proj.metaParticle = makeMetaParticle("go arrow")
		-- proj.explosionMetaParticle = makeMetaParticle("x-beam spark")
	elseif type == "x-beam" then
		proj.arc = 0
		proj.speed = 1
		
		proj.segments = 0
		proj.color = {r = 255, g = 255, b = 31, a = 255}

		proj.particleRate = 2
		proj.metaParticle = makeMetaParticle("x-beam spark")
		proj.explosionMetaParticle = makeMetaParticle("fire trail")
		
		proj.shadow = false
	end
	--TODO need failsafe here if type not found
	
	--should be simplified alongside the "elevation" refactor
	proj.vector = {x = proj.xDist, y = proj.yDist}
	proj.ascentSpeed = proj.arc
	proj.descentSpeed = proj.ascentSpeed * 2
	
	return proj
end

function moveFireball(dt)
	--move fireball closer to enemy, arcing
	fireball.x = fireball.x + fireball.vector.x * fireball.speed * dt
	fireball.y = fireball.y + (fireball.vector.y) * fireball.speed * dt - fireball.ascentSpeed 
	
	--move shadow closer to enemy, not arcing
	fireball.sx = fireball.sx + fireball.vector.x * fireball.speed * dt
	fireball.sy = fireball.sy + fireball.vector.y * fireball.speed * dt	
	
	--adjust arc
	fireball.ascentSpeed = fireball.ascentSpeed - fireball.descentSpeed * dt * fireball.speed
	
	--count down distance
	fireball.distanceTraveled = fireball.distanceTraveled + fireball.speed * fireball.vector.x * dt
end

function addParticle(x, y, meta, extraParams)
	--location + default particle init (just age = 0 for now)
	local p = {
		x = x,
		y = y,
		age = 0
	}
	
	--adopt all of metaparticle's static attributes
	for attribute, value in pairs(meta.static) do --what if this is nil? (it crashes! failsafe needed around line 362, but also TODO be safer with .static and .variable)
		p[attribute] = value
	end

	--adopt all of metaparticle's variable attributes with variance applied
	for attribute, range in pairs(meta.variable) do
		p[attribute] = vary(range)
	end
	
	--replace anything specified
	if extraParams then 
		for k,v in pairs(extraParams) do
			p[k] = v
		end
	end
	
	table.insert(particles, p)
end

--TODO change into, or merge with, emit(). explode() is just not a function you find in grown-ups' game code. u_u
function explode(fb)
	local mp = fb.explosionMetaParticle or fb.metaParticle or makeMetaParticle("fire trail")
	
	for i = 1, 10 + fb.particleRate * 10 do
		addParticle(fb.x, fb.y, mp)
	end
end

--metaparticles are used as a prototype for a given emitter's particles. see addParticle() and comment on vary() for a little more info on this.
function makeMetaParticle(type)
	attributes = {}
	
	--all "deltas" are applied per second, i.e. how much is a given attribute allowed to change after 1s?
	if type == "fire trail" then
		attributes = {
			static = {
				segments = 4,
			},
			variable = {
				maxAge = {min = 1, var = 1},
			
				r = {min = 247, var = 8},
				g = {min = 191, var = 64},
				b = {min = 127, var = 32},
				a = {min = 191, var = 0},
			
				deltaR = {min = -0, var = 0},
				deltaG = {min = -191, var = 100},
				deltaB = {min = -191, var = 25},
				deltaA = {min = -191, var = 25},
			
				size = {min = 6, var = 1},
				deltaSize = {min = -4, var = 2},
			
				xVelocity = {min = -100, var = 200},
				yVelocity = {min = -100, var = 200},
				xAcceleration = {min = -150, var = 300},
				yAcceleration = {min = 50, var = 100},
				xJerk = {min = -100, var = 200},
				yJerk = {min = -100, var = 200},
			}
		}
	-- elseif type == "fire explosion" then
		--...
	elseif type == "ice ball" then
		attributes = {
			static = {
				maxAge = 3,

				r = 191,
				g = 223,
				b = 255,
				a = 223,
				
				segments = 6,
			},
			variable = {
				deltaR = {min = -191, var = 50},
				deltaG = {min = -191, var = 50},
				deltaB = {min = -127, var = 50},
				deltaA = {min = -255, var = 0},
			
				size = {min = 5, var = 2},
				deltaSize = {min = -2, var = 2},
			
				xVelocity = {min = -50, var = 100},
				yVelocity = {min = -20, var = 60},
				xAcceleration = {min = -50, var = 100},
				yAcceleration = {min = 200, var = 0},
				xJerk = {min = -200, var = 400},
				yJerk = {min = -350, var = 0},
			}
		}	
	elseif type == "go arrow" then
		attributes = {
			static = {
				maxAge = 8,

				r = 31,
				g = 255,
				b = 31,
				a = 255,
				
				segments = 3,
			},
			variable = {
				deltaR = {min = 63, var = 50},
				deltaG = {min = 0, var = 0},
				deltaB = {min = 63, var = 50},
				deltaA = {min = 0, var = 0},
			
				size = {min = 5, var = 10},
				deltaSize = {min = 0, var = 0},
			
				xVelocity = {min = -250, var = 100},
				yVelocity = {min = -50, var = 100},
				xAcceleration = {min = 0, var = 100},
				yAcceleration = {min = 0, var = 0},
				xJerk = {min = 500, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}	
	elseif type == "x-beam spark" then
		attributes = {
			static = {
				maxAge = 0.5,

				r = 255,
				g = 255,
				b = 255,
				a = 255,
				
				segments = 8,
			},
			variable = {
				deltaR = {min = -640, var = 256},
				deltaG = {min = -640, var = 0},
				deltaB = {min = -1024, var = 0},
				-- deltaR = {min = -1024, var = 512, mode = "extreme"},
				-- deltaG = {min = -1024, var = 512, mode = "extreme"},
				-- deltaB = {min = -1024, var = 512, mode = "extreme"},
				deltaA = {min = 0, var = 0},
			
				size = {min = 6, var = 0},
				deltaSize = {min = -8, var = 1},
			
				xVelocity = {min = -256, var = 512, mode = "extreme"},
				yVelocity = {min = -256, var = 512, mode = "extreme"},
				xAcceleration = {min = 0, var = 0},
				yAcceleration = {min = 0, var = 0},
				xJerk = {min = 0, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}	
	elseif type == "random wild" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = 1, var = 10},
				
				segments = {min = 3, var = 5, mode = "integer"},
			
				r = {min = 0, var = 256},
				g = {min = 0, var = 256},
				b = {min = 0, var = 256},
				a = {min = 0, var = 256},
			
				deltaR = {min = -256, var = 512},
				deltaG = {min = -256, var = 512},
				deltaB = {min = -256, var = 512},
				deltaA = {min = -256, var = 512},
			
				size = {min = 1, var = 10},
				deltaSize = {min = -10, var = 20},
			
				xVelocity = {min = -500, var = 1000},
				yVelocity = {min = -500, var = 1000},
				xAcceleration = {min = -500, var = 1000},
				yAcceleration = {min = -500, var = 1000},
				xJerk = {min = -500, var = 1000},
				yJerk = {min = -500, var = 1000},
			}
		}
	elseif type == "random tame" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = math.random(5), var = math.random(5)},

				segments = {min = math.random(3) + 2, var = math.random(3), mode = "integer"},
			
				r = {min = math.random(256), var = math.random(256)},
				g = {min = math.random(256), var = math.random(256)},
				b = {min = math.random(256), var = math.random(256)},
				a = {min = math.random(256), var = math.random(256)},
			
				deltaR = {min = 0 - math.random(256), var = math.random(512)},
				deltaG = {min = 0 - math.random(256), var = math.random(512)},
				deltaB = {min = 0 - math.random(256), var = math.random(512)},
				deltaA = {min = 0 - math.random(256), var = math.random(512)},
			
				size = {min = math.random(10), var = math.random(10)},
				deltaSize = {min = 0 - math.random(10), var = math.random(10)},
			
				xVelocity = {min = 0 - math.random(256), var = math.random(512)},
				yVelocity = {min = 0 - math.random(256), var = math.random(512)},
				xAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				yAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				xJerk = {min = 0 - math.random(256), var = math.random(512)},
				yJerk = {min = 0 - math.random(256), var = math.random(512)},
			}
		}
		
		for k,v in pairs(attributes.variable) do
			print(v.min, v.var, k)
		end
	else
		print("metaparticle type not found")
		attributes = makeMetaParticle("fire trail")
	end
	
	return attributes
end

--range must be a table containing two numbers, "min" and "var", and optionally "mode"
--if range also contains the "mode" attribute, complex functions of variance may be used, like "extreme" or "integer"
--if range does not contain "mode", the default variance algorithm, "linear", is used. this will generate a rational number between [range.min] and [range.min + range.var]
function vary(range)
	local value = 0
	local mode = range.mode or "linear" 
	
	if mode == "linear" then
		--a rational number between [range.min] and [range.min + range.var]
		value = math.random() * range.var + range.min
	elseif mode == "integer" then
		--a whole number between [range.min] and [range.min + range.var]. rounds to nearest
		value = math.random() * range.var + range.min
		if value - 0.5 < math.floor(value) then
			value = math.floor(value)
		else
			value = math.ceil(value)
		end
	elseif mode == "extreme" then
		--50/50 chance: either [range.min] or [range.min + range.var]
		if math.random() > 0.5 then
			value = range.min
		else
			value = range.min + range.var
		end
	-- elseif mode == "absolute value" then --TODO
	-- elseif mode == "bell curve" then --TODO
	-- elseif mode == "inverse bell curve" then --TODO
	end
	
	return value
end

--indent = priority
--TODO this file is getting bloated! :) make a new project and separate the behavior code, projectile code, and particle code into different files. this is what you want, anyway ~
--TODO z-ordering? draw non-particle entities in correct y-order? shadows always on the bottom, also
--TODO images for particles (D for dandelion?)
--TODO ...aaand animated particles.
--TODO for projectile & shadow locations, probably use x/y/elevation instead of x/y/sx/sy. less processor-intensive. see draw() and moveFireball(), line ~374 (also the MP makers)
--TODO array of projectiles so you can have many at once on screen. come on.
--TODO stationary emitters. E not taken yet :) use "line" polygons!
--TODO better "no effect" cases, both failsafes and when you simply don't want a projectile, particle stream, and/or particle explosion
--TODO variation on particles' origin points. deltaX and deltaY? is that confusing? haha
--TODO emission (except from puffers) is currently timer-free. should definitely change to emit on a set interval, not just "some % chance of emitting every update() cycle"
--TODO   pixel-lock particle locations. kinda anal to insist on this, but it'll make small, image-based particles look way better. anti-aliasing = bad for pixel aesthetic
--TODO   destroy particles when they're off screen, alpha <= 0, or size <= 0 (in or near updateParticles(), maybe separate to new func)
--TODO   confetti gun that only has an explosion, no trail
--TODO   other particle attribute ideas... blink (kinda easy), oscillation (hard), image?, accel/jerk for color/size changes?, rotation?, orbit around origin point?, 
--       minima/maxima for colors and other attributes?
--       - picture the x-beam with a twirl effect! O_O ...but would need variable (via vary()? or something else?) angle-calculators built into the metaparticle
--TODO   MAYBE unite metaparticle attributes again instead of separating into "static" and "variable". instead, assume: if type(attribute) == table, then vary(), else foo = attribute
--       - advantage to above: would be much easier to make slight variations on prefab mParticles. could just pass the swap-out params to makeMeta()
--       - could also list static attributes in another table? some static attributes might BE tables & shouldn't vary()
--TODO   oscillation/blinking as an option for any attribute? making xOscillation, yOscillation, rOscillation, etc., plus timers and stuff for all those sounds awful
--       - probably calculating sines and stuff ahead of time (even storing in global arrays that oscillators walk) will be necessary. then different animation modes :/
--       - option to accelerate/jerk multiplicitavely? decay to 0? :/ difficult to do nicely, wait until needed. this could be another animation mode, like oscillation
--TODO     multiple metaparticles on a given projectile/emitter. could also just throw two fireballs :P
--TODO     nesting/grouping of attributes in library, or maybe attribute abstraction/generalization. like makeBall() instead of size=..., color=..., segments=..., just to save space
--TODO     random polygons instead of segmented circles? unfortunately love.graphics.polygon() doesn't take mode/x/y/shape, it just takes mode/shape, making this a bit harder

--things love.ParticleSystem can't do:
	--customizable animation speed (interval depends solely on how many quads you set)
	--pixel-locked motion
	--precise customization of particle attributes, especially velocity/accel/jerk
	--basic geometry for particles! must use images
	--oscillation
	--variable methods of vary()ing when emitting particles

--things love.ParticleSystem CAN do that i don't know how to do yet:
	--particle rotation (esp for segmented circles), particle orbit