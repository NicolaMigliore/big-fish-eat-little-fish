io.stdout:setvbuf("no")
-- debugger setup
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- load libraries
Object = require "libs.classic"
Utils = require "src.utils"
local ui = require "src.ui"
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
Level = require "src.scenes.level"
Title = require "src.scenes.title"

-- load entities


-- Define global objects
WORLD_WIDTH, WORLD_HEIGHT = 2020, 8000
WORLD = nil
ENTITIES = {}
CAMERA = nil
PLAYER = nil
SCENE = "title"
UI = ui()

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(.5, .7, 1)

    Title:load()
    Level:load()

    -- set initial scene
    LOAD_SCENE_TITLE()
end

function love.update(dt)
    if SCENE == "title" then
        Title:update(dt)
    elseif SCENE == "level" then
        Level:update(dt)
    end
    UI:update(dt)
end

function love.draw()
    if SCENE == "title" then
        Title:draw()
    elseif SCENE == "level" then
        Level:draw()
    end
    UI:draw()
end

-- input management
function love.mousereleased(x, y, button)
    if button == 1 then
        for _, btn in ipairs(UI.buttons) do
            if x >= btn.x and x <= btn.x + btn.width
                and y >= btn.y and y <= btn.y + btn.height then
                btn:onClick()
                break
            end
        end
    end
end
function love.keyreleased(key)
    if SCENE == "title" then
        if key == "space" then
            LOAD_SCENE_LEVEL()
        end
    end
end
