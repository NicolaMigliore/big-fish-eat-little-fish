
io.stdout:setvbuf("no")
-- debugger setup
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- load libraries
Object = require "libs.classic"
Utils = require "src.utils"
wf = require "libs.windfield"

-- load components
Sprite = require "src.components.sprite"
Control = require "src.components.control"
local animComponents = require("src.components.animation")
Animation, AnimationController = animComponents[1], animComponents[2]

-- load entities
local Entity = require "src.entities.entity"
local Player = require "src.entities.player"

-- Define global settings
WATER_FRICTION = 10000

local player
local currentFrame = 1

function love.load()
    world = wf.newWorld(0, 0, true)
    -- world:setGravity(0, 10)

    player = Player(200,200)
end

function love.update(dt)
    world:update(dt)

    -- update entities
    player:update(dt)

    currentFrame = currentFrame + dt
end

function love.keyreleased(key)
end

function love.draw()
    world:draw()

    -- draw entities
    player:draw()

end
