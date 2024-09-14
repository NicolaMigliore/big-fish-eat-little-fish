local Level = Object.extend(Object)

-- load entities
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"

local bgImage
local spawnTimer = 0

function Level:load()

    self:loadWorld()
    self:loadLevel(1)

    CAMERA = Camera(PLAYER.position.x, PLAYER.position.y, 2)
    CAMERA.smoother = CAMERA.smooth.damped(10)

    -- configure background
    bgImage = love.graphics.newImage("assets/background.png")
    bgImage:setWrap("repeat", "clamp")
end

function Level:update(dt)
    WORLD:update(dt)
    -- update entities
    for _, entity in pairs(ENTITIES) do
        entity:update(dt)
    end

    -- spawn fish
    if Utils.tabelCount(ENTITIES) <= 10 and math.random() > .5 then
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
end

function Level:draw()
    CAMERA:attach()
    -- draw background
    love.graphics.draw(bgImage, love.graphics.newQuad(-1, 0, 204, 204, 32, 128), -10, -10, 0, 5, 10)
    WORLD:draw()

    -- draw entities
    for _, entity in pairs(ENTITIES) do
        entity:draw()
    end

    CAMERA:detach()
end

function Level:loadLevel(depth)
    -- for i = 1, 5, 1 do
    --     -- local tmpEnemy = Enemy(math.random(40, WORLD_WIDTH - 40), 100 + i * math.random(50), "assets/sprites/fish_01.png")
    --     local tmpEnemy = Enemy(nil, 250, 250 + i * math.random(50), math.floor(math.random(30)), "assets/sprites/fish_01.png")
    --     ENTITIES[tmpEnemy.id] = tmpEnemy
    -- end
end

function Level:spawnSchool()
    local worldPadding = 40
    local x,y = PLAYER.position.x, PLAYER.position.y
    local xOffset, yOffset = 0, 0

    for i=1, math.random(4,9) do
        xOffset = 100 + math.random(200,450)
        yOffset = 100 + math.random(100,350)

        if x + xOffset > WORLD_WIDTH + worldPadding then xOffset = -xOffset end
        if y + yOffset > WORLD_HEIGHT + worldPadding then yOffset = -yOffset end
        
        local smallFish = Enemy(nil, x + xOffset, y + yOffset, PLAYER.size - 5, "assets/sprites/fish_01.png")
        ENTITIES[smallFish.id] = smallFish
    end
    for i=1, math.random(1,2) do
        local largeFish = Enemy(nil, x + xOffset, y + yOffset + 300, PLAYER.size + 5, "assets/sprites/fish_01.png")
        ENTITIES[largeFish.id] = largeFish
    end
    -- local spawnCounter = math.floor(math.random(5))
    spawnTimer = 10
end

function LOAD_SCENE_LEVEL()
    SCENE = "level"
    UI:clearUI()
    UI:addLabel("depth", "DEPTH: 0", 10, 0)

    Level:loadLevel(1)
end

function Level:loadWorld()
    WORLD = wf.newWorld(0, 0, true)
    WORLD:addCollisionClass('Player')
    WORLD:addCollisionClass('Fish')

    local worldBounds = {
        top = WORLD:newRectangleCollider(-10, -10, WORLD_WIDTH, 10),
        right = WORLD:newRectangleCollider(WORLD_WIDTH - 10, 0, 10, WORLD_HEIGHT),
        bottom = WORLD:newRectangleCollider(-10, WORLD_HEIGHT, WORLD_WIDTH, 10),
        left = WORLD:newRectangleCollider(-10, 0, 10, WORLD_HEIGHT),
    }

    for key, collider in pairs(worldBounds) do
        collider:setType("static")
    end

    PLAYER = Player(nil, WORLD_WIDTH/2, 200)
    ENTITIES[PLAYER.id] = PLAYER
end
return Level