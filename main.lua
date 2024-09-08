io.stdout:setvbuf("no")
-- debugger setup
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- load libraries
Object = require "libs.classic"
Utils = require "src.utils"
wf = require "libs.windfield"
Camera = require "libs.hump.camera"

-- load components
Position = require "src.components.position"
Sprite = require "src.components.sprite"
local controlComponents = require("src.components.control")
Control, Intention = controlComponents[1], controlComponents[2]
local animComponents = require("src.components.animation")
Animation, AnimationController = animComponents[1], animComponents[2]
State = require "src.components.state"

-- load entities
local Fish = require "src.entities.fish"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"

-- Define global settings
WORLD_WIDTH, WORLD_HEIGHT = 1020, 2000

local bgImage
local player
local currentFrame = 1

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(.5, .7, 1)

    loadWorld()

    -- world:setGravity(0, 10)
    camera = Camera(0, 0, 2)

    -- configure background
    bgImage = love.graphics.newImage("assets/background.png")
    bgImage:setWrap("repeat","clamp")

    player = Player(200, 200)
    f1 = Enemy(300,300,"assets/sprites/fish_01.png")
end

function love.update(dt)
    world:update(dt)

    -- update entities
    player:update(dt)
    f1:update(dt)

    currentFrame = currentFrame + dt

    -- move camera
    camera:lookAt(math.floor(player.position.x), math.floor(player.position.y))
end

function love.keyreleased(key)
end

function love.draw()

    camera:attach()
    -- draw background
    love.graphics.draw(bgImage,love.graphics.newQuad(-1, 0, 204, 204, 32, 128), -10, -10, 0, 5, 10)
    world:draw()

    -- draw entities
    player:draw()
    f1:draw()
    camera:detach()
end

function loadWorld()
    world = wf.newWorld(0, 0, true)
    local worldBounds = {
        top = world:newRectangleCollider(-10, -10, WORLD_WIDTH, 10),
        right = world:newRectangleCollider(WORLD_WIDTH - 10, 0, 10, WORLD_HEIGHT),
        bottom = world:newRectangleCollider(-10, WORLD_HEIGHT, WORLD_WIDTH, 10),
        left = world:newRectangleCollider(-10, 0, 10, WORLD_HEIGHT),
    }

    for key, collider in pairs(worldBounds) do
        collider:setType("static")
    end
end
-- 1020