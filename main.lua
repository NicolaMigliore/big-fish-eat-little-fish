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
local Player = require "src.entities.player"

-- Define global settings
WATER_FRICTION = 10000

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
end

function love.update(dt)
    world:update(dt)

    -- update entities
    player:update(dt)

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
    camera:detach()
end

function loadWorld()
    world = wf.newWorld(0, 0, true)
    local worldBounds = {
        top = world:newRectangleCollider(-10, -10, 1020, 10),
        right = world:newRectangleCollider(1000, 0, 10, 2000),
        bottom = world:newRectangleCollider(-10, 2000, 1020, 10),
        left = world:newRectangleCollider(-10, 0, 10, 2000),
    }

    for key, collider in pairs(worldBounds) do
        collider:setType("static")
    end
end
-- 1020