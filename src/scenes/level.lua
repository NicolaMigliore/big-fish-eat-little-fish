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
    -- configure particles
    self.particles = Particles()
    self.particles:addDustParticle()
    self.dustParticleTimer = 0
end

function Level:update(dt)
    WORLD:update(dt)
    -- update entities
    for _, entity in pairs(ENTITIES) do
        local playerDistance = Utils.pointDistance(
            PLAYER.position.x,
            PLAYER.position.y,
            entity.position.x,
            entity.position.y
        )
        if entity.type == "enemy" and playerDistance > 1000 then
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
    UI:updateLabel("depth", "DEPTH:" .. math.floor(PLAYER.position.y / 80))
    UI:updateLabel("score", "SCORE:" .. math.floor(SCORE))
    UI:updateLabel("life", "LIVES:" .. PLAYER.life)

    -- move camera
    local viewportW, viewportH = love.graphics.getWidth() / SCALE, love.graphics.getHeight() / SCALE
    local camX, camY = PLAYER.position.x, PLAYER.position.y
    camX = math.max(camX, viewportW / 2)                -- restrict left
    camX = math.min(camX, WORLD_WIDTH - viewportW / 2)  -- restrict right
    camY = math.max(camY, 0 + viewportH / 2)            -- restrict top
    camY = math.min(camY, WORLD_HEIGHT - viewportH / 2) -- restrict bottom
    CAMERA:lockPosition(camX, camY)

    -- end level
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
    safeArea.x, safeArea.y = PLAYER.position.x - safeArea.w / 2, PLAYER.position.y + 50 - safeArea.h / 2
    spawnArea.x, spawnArea.y = PLAYER.position.x - spawnArea.w / 2, PLAYER.position.y + 100 - spawnArea.h / 2
    local overlapLeft = worldPadding - spawnArea.x
    local overlapRight = (spawnArea.x + spawnArea.w) - (WORLD_WIDTH - worldPadding)
    local overlapTop = worldPadding - spawnArea.y
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
        self.particles.dust:setEmissionArea("uniform", 800, 700)
        self.dustParticleTimer = 2
    end

    -- restart music
    if not SFX.levelMusic:isPlaying() then
        love.audio.play(SFX.levelMusic)
    end
end

function Level:draw()
    -- draw background
    self:drawGradient()
    love.graphics.setColor(1, 1, 1, 1)

    if gameMap.layers["background_1"] then
        gameMap:drawLayer(gameMap.layers["background_1"])
    end
    if gameMap.layers["background_2"] then
        gameMap:drawLayer(gameMap.layers["background_2"])
    end
    if gameMap.layers["obstacles"] then
        gameMap:drawLayer(gameMap.layers["obstacles"])
    end

    WORLD:draw()

    -- draw entities
    for _, entity in pairs(ENTITIES) do
        entity:draw()
    end

    -- -- draw spawn area
    -- love.graphics.setColor(1,0.4,.6)
    -- love.graphics.rectangle("line", spawnArea.x, spawnArea.y,spawnArea.w,spawnArea.h)
    -- love.graphics.setColor(0.4,1,.6)
    -- love.graphics.rectangle("line", safeArea.x, safeArea.y,safeArea.w,safeArea.h)
    -- love.graphics.setColor(1,1,1)

    -- draw particles
    love.graphics.draw(self.particles.dust)
    -- draw label panel
    self:drawCountersPanel()
end

function Level:loadLevel(depth)
    ENTITIES = {}
end

function Level:spawnSchool()
    -- distribute spawn points
    local spanwNumber = 10
    for i = 1, spanwNumber do
        local spawnX = math.random(spawnArea.x, spawnArea.x + spawnArea.w)
        local spawnY = math.random(spawnArea.y, spawnArea.y + spawnArea.h)
        -- shift out of safe area
        local isInSafeArea = Utils.pointToBoxCollision(spawnX, spawnY, safeArea.x, safeArea.y, safeArea.w, safeArea.h)
        if isInSafeArea and spawnX < PLAYER.position.x then
            spawnX = spawnX - math.random(safeArea.w / 2, spawnArea.w / 2)
        end
        if isInSafeArea and spawnX > PLAYER.position.x then
            spawnX = spawnX + math.random(safeArea.w / 2, spawnArea.w / 2)
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

function LOAD_SCENE_LEVEL(lvl)
    lvl = lvl or 1
    SCENE = "level"
    SET_SCALE(4)
    UI:clearUI()
    UI:addLabel("depth", "DEPTH: 0", 10, -15)
    UI:addLabel("score", "SCORE: 0", 10, 15)
    UI:addLabel("life", "LIVES: 3", 10, 45)

    levelEndTime = nil
    deathTime = nil

    Level:loadLevel(lvl)
    local mapNames = {"map_1.lua", "map_2.lua"}
    local mapFileName = "map_3.lua"
    -- if lvl > 1 then mapFileName = mapNames[math.random(1,#mapNames)] end
    Level:loadWorld(mapFileName)
    CAMERA.smoother = CAMERA.smooth.damped(10)
end

function Level:loadWorld(mapName)
    WORLD = wf.newWorld(0, 0, true)
    WORLD:addCollisionClass('Fish')
    WORLD:addCollisionClass('Obstacle')
    WORLD:addCollisionClass('Spawn')
    WORLD:addCollisionClass('Trigger')
    WORLD:addCollisionClass('Player', { ignores = { 'Trigger', 'Spawn' } })

    -- configure map
    gameMap = sti("src/maps/"..mapName)
    WORLD_WIDTH, WORLD_HEIGHT = gameMap.width * gameMap.tilewidth, gameMap.height * gameMap.tileheight
    -- local worldBounds = {
    --     top = WORLD:newRectangleCollider(0, -10, WORLD_WIDTH, 10),
    --     right = WORLD:newRectangleCollider(WORLD_WIDTH -16, 0, 16, WORLD_HEIGHT),
    --     bottom = WORLD:newRectangleCollider(0, WORLD_HEIGHT - 16, WORLD_WIDTH, 16),
    --     left = WORLD:newRectangleCollider(0, 0, 16, WORLD_HEIGHT),
    -- }
    local worldColliders = gameMap.objects
    for i, obj in pairs(worldColliders) do
        if obj ~= nil then
            local collider = WORLD:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            collider:setType("static")
            if obj.type == "obstacle" or obj.type == "world_border" then
                collider:setCollisionClass("Obstacle")
            elseif obj.type == "trigger" and obj.name == "level_exit" then
                collider:setCollisionClass("Trigger")

                local endTrigger = Trigger(collider:getX(), collider:getY(), collider,
                    function(trigger, other)
                        -- LOAD_SCENE_LEVEL_END()
                        levelEndTime = love.timer.getTime()
                    end)
                ENTITIES[endTrigger.id] = endTrigger
            elseif obj.type == "spawn" and obj.name == "player_spawn" then
                collider:setCollisionClass("Spawn")
                PLAYER = Player(nil, collider:getX(), collider:getY())
                ENTITIES[PLAYER.id] = PLAYER
            end
        end
    end
    SCORE = 0
end

function Level:drawGradient()
    -- Rectangle with linear gradient
    local color1 = { 44 / 255, 232 / 255, 245 / 255, 1 }
    local color2 = { 18 / 255, 78 / 255, 137 / 255, 1 }

    local x, y = 0, 0
    local width, height = WORLD_HEIGHT, WORLD_WIDTH

    love.gradient.draw(
        function()
            love.graphics.rectangle("fill", x, y, width, height)
        end, "linear",
        x + height / 2, y + width / 2, width / 2, height / 2, color1, color2, math.pi / 2)
end

function Level:drawCountersPanel()
    local panelW = 100
    local panelH = 50
    local panelX, panelY = CAMERA:worldCoords(5, 5)

    love.graphics.setColor(love.math.colorFromBytes(90, 105, 136))
    love.graphics.rectangle("fill", panelX - 3, panelY - 3, panelW + 6, panelH + 6)

    love.graphics.setColor(love.math.colorFromBytes(139, 155, 180))
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)
end

return Level