local Level = Object.extend(Object)

-- load entities
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"

local gameMap
local worldPadding = 40
local spawnTimer = 0
local levelEndTime = nil
local deathTime = nil
local spawnArea = { x = 0, y = 0, w = 800, h = 500 }
local safeArea = { x = 0, y = 0, w = 600, h = 400 }

function Level:load()

    -- configure map
    gameMap = sti("src/maps/map.lua")
    
    -- configure particles
    self.particles = Particles()
    self.particles:addDustParticle()
    self.dustParticleTimer = 0
end

function Level:update(dt)
    WORLD:update(dt)
    -- update entities
    for _, entity in pairs(ENTITIES) do
        local playerDistance = Utils.pointDistance(PLAYER.position.x, PLAYER.position.y, entity.position.x, entity.position.y)
        if playerDistance > 1000 then
            entity:kill()
        else
            entity:update(dt)
        end
    end

    -- spawn fish
    if Utils.tabelCount(ENTITIES) <= 20 and math.random() > .3 then
        spawnTimer = spawnTimer - dt
        if spawnTimer < 0 then
            self:spawnSchool()
        end
    end

    -- update depth label
    UI.labels.depth.text = "DEPTH:"..math.floor(PLAYER.position.y / 80)

    -- move camera
    local camScale = 1/CAMERA.scale
    local viewportW, viewportH = love.graphics.getWidth() * camScale, love.graphics.getHeight() * camScale
    local camX, camY = PLAYER.position.x, PLAYER.position.y
    camX = math.max(camX, 0 + viewportW / 2) -- restrict left
    camX = math.min(camX, WORLD_WIDTH - viewportW / 2) -- restrict right
    camY = math.max(camY, 0 + viewportH / 2) -- restrict top
    camY = math.min(camY, WORLD_HEIGHT - viewportH / 2) -- restrict bottom
    CAMERA:lockPosition(camX, camY)

    -- end level
    if levelEndTime == nil and PLAYER.position.y > WORLD_HEIGHT - 40 then
        levelEndTime = love.timer.getTime()
    end
    if levelEndTime ~= nil and love.timer.getTime() - levelEndTime > 1.5 then
        SCORE = SCORE + math.floor(PLAYER.position.y / 80)
        LOAD_SCENE_LEVEL_END()
    end

    -- player death
    if deathTime == nil and PLAYER.state.current == "death" then
        deathTime = love.timer.getTime()
    end
    if deathTime ~= nil and love.timer.getTime() - deathTime > 2.5 then
        SCORE = SCORE + math.floor(PLAYER.position.y / 80)
        LOAD_SCENE_DEATH()
    end

    -- update spawn area
    safeArea.x, safeArea.y = PLAYER.position.x - safeArea.w/2, PLAYER.position.y + 50 - safeArea.h/2
    spawnArea.x, spawnArea.y = PLAYER.position.x - spawnArea.w/2, PLAYER.position.y + 100 - spawnArea.h/2
    local overlapLeft =  worldPadding - spawnArea.x
    local overlapRight = (spawnArea.x + spawnArea.w) - (WORLD_WIDTH - worldPadding)
    local overlapTop =  worldPadding - spawnArea.y
    local overlapBottom = (spawnArea.y + spawnArea.h) - (WORLD_HEIGHT - worldPadding)
    if overlapRight > 0 then spawnArea.x = spawnArea.x - overlapRight end
    if overlapLeft > 0 then spawnArea.x = spawnArea.x + overlapLeft end
    if overlapTop > 0 then spawnArea.y = spawnArea.y + overlapTop end
    if overlapBottom > 0 then spawnArea.y = spawnArea.y - overlapBottom end

    -- update particles
    self.particles.dust:update(dt)
    self.dustParticleTimer = self.dustParticleTimer - dt
    if self.dustParticleTimer <= 0 then
        -- self.boubleLocation = { x = self.position.x, y = self.position.y }
        --self.particles.dust:emit(50)
        self.particles.dust:setPosition(PLAYER.position.x, PLAYER.position.y)
        self.particles.dust:setEmissionArea("uniform",800, 700)
        self.dustParticleTimer = 2
    end
end

function Level:draw()
    CAMERA:attach()
    -- draw background
    self:drawGradient()
    love.graphics.setColor(1,1,1,1)

    -- draw map
    gameMap:drawLayer(gameMap.layers["borders"])

    -- WORLD:draw()

    -- draw entities
    for _, entity in pairs(ENTITIES) do
        entity:draw()
    end

    -- draw spawn area
    love.graphics.setColor(1,0.4,.6)
    love.graphics.rectangle("line", spawnArea.x, spawnArea.y,spawnArea.w,spawnArea.h)
    love.graphics.setColor(0.4,1,.6)
    love.graphics.rectangle("line", safeArea.x, safeArea.y,safeArea.w,safeArea.h)
    love.graphics.setColor(1,1,1)

    -- draw particles
    -- love.graphics.draw(self.particles.dust, PLAYER.position.x + 20, PLAYER.position.y)
    love.graphics.draw(self.particles.dust)

    CAMERA:detach()
end

function Level:loadLevel(depth)
    ENTITIES = {}
end

function Level:spawnSchool()
    -- distribute spawn points
    local spanwNumber = 10
    for i=1, spanwNumber do
        local spawnX = math.random(spawnArea.x, spawnArea.x + spawnArea.w)
        local spawnY = math.random(spawnArea.y, spawnArea.y + spawnArea.h)
        -- shift out of safe area
        local isInSafeArea = Utils.pointToBoxCollision(spawnX, spawnY, safeArea.x, safeArea.y, safeArea.w, safeArea.h)
        if isInSafeArea and spawnX < PLAYER.position.x then
            spawnX = spawnX - math.random(safeArea.w/2, spawnArea.w/2)
        end
        if isInSafeArea and spawnX > PLAYER.position.x then
            spawnX = spawnX + math.random(safeArea.w/2, spawnArea.w/2)
        end

        if i > spanwNumber * .3 then
            -- spawn smaller
            local smallFish = Enemy(nil, spawnX, spawnY, PLAYER.size - 5, "assets/sprites/fish_01.png")
            ENTITIES[smallFish.id] = smallFish
        else
            -- spawn larger
            local smallFish = Enemy(nil, spawnX, spawnY, PLAYER.size + 5, "assets/sprites/fish_01_big.png")
            ENTITIES[smallFish.id] = smallFish
        end
    end
    spawnTimer = 1
end

function LOAD_SCENE_LEVEL()
    SCENE = "level"
    UI:clearUI()
    UI:addLabel("depth", "DEPTH: 0", 10, 0)

    levelEndTime = nil
    deathTime = nil
    
    Level:loadLevel(1)
    Level:loadWorld()
    CAMERA = Camera(PLAYER.position.x, PLAYER.position.y, 2)
    CAMERA.smoother = CAMERA.smooth.damped(10)
end

function Level:loadWorld()
    WORLD = wf.newWorld(0, 0, true)
    WORLD:addCollisionClass('Player')
    WORLD:addCollisionClass('Fish')

    local worldBounds = {
        top = WORLD:newRectangleCollider(0, -10, WORLD_WIDTH, 10),
        right = WORLD:newRectangleCollider(WORLD_WIDTH -16, 0, 16, WORLD_HEIGHT),
        bottom = WORLD:newRectangleCollider(0, WORLD_HEIGHT - 16, WORLD_WIDTH, 16),
        left = WORLD:newRectangleCollider(0, 0, 16, WORLD_HEIGHT),
    }

    for key, collider in pairs(worldBounds) do
        collider:setType("static")
    end

    PLAYER = Player(nil, WORLD_WIDTH/2, 200)
    ENTITIES[PLAYER.id] = PLAYER
    SCORE = 0
end

function Level:drawGradient()
    -- Rectangle with linear gradient
    local color1 = {44/255, 232/255, 245/255, 1}
    local color2 = {18/255, 78/255, 137/255, 1}

    local x, y = 0, 0
    local width, height = WORLD_HEIGHT, WORLD_WIDTH

	love.gradient.draw(
		function()
			love.graphics.rectangle("fill", x, y, width, height)
		end, "linear",
		x + height/2, y + width/2, width/2, height/2, color1, color2, math.pi/2)
end

return Level