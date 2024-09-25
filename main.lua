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
sti = require "libs.sti"
gradient = require "libs.gradient"

-- load components
Position = require "src.components.position"
Sprite = require "src.components.sprite"
local controlComponents = require("src.components.control")
Control, Intention = controlComponents[1], controlComponents[2]
local animComponents = require("src.components.animation")
Animation, AnimationController = animComponents[1], animComponents[2]
Particles = require "src.components.particles"
State = require "src.components.state"

-- load scenes
Level = require "src.scenes.level"
Title = require "src.scenes.title"
LevelEnd = require "src.scenes.levelEnd"
Death = require "src.scenes.death"


-- load entities
Trigger = require "src.entities.trigger"

-- Define global objects
WORLD_WIDTH, WORLD_HEIGHT = 2048, 8000
WINDOW_WIDTH, WINDOW_HEIGHT = 1200,900
BASE_WIDTH, BASE_HEIGHT = 1200,900
SCALE = 1
OFFSET_X, OFFSET_Y = 0,0
WORLD = nil
ENTITIES = {}
CAMERA = nil
PLAYER = nil
SCENE = "title"
SCORE = 0
UI = ui()
SFX = {}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- load sounds
    SFX.buttonSound = love.audio.newSource("assets/audio/sounds/button.mp3", "static")
    SFX.bashSound = love.audio.newSource("assets/audio/sounds/bash.mp3", "static")
    SFX.waterSound = love.audio.newSource("assets/audio/sounds/water.mp3", "static")
    SFX.waterSound:setPitch(0.5)
    SFX.waterSound:setVolume(0.5)
    SFX.biteSound = love.audio.newSource("assets/audio/sounds/bite.mp3", "static")
    SFX.playerBiteSound = SFX.biteSound:clone()
    SFX.playerHitSound = SFX.biteSound:clone()
    SFX.playerHitSound:setPitch(0.5)
    SFX.biteSound:setPitch(2)
    -- load music
    SFX.levelMusic = love.audio.newSource("assets/audio/music/level_music.mp3", "stream")
    -- setup camera
    CAMERA = Camera(BASE_WIDTH/2, BASE_HEIGHT/2, SCALE)
    
    -- load scenes
    Title:load()
    Level:load()
    LevelEnd:load()
    -- set initial scene
    LOAD_SCENE_TITLE()
end

function love.update(dt)
    if SCENE == "title" then
        Title:update(dt)
    elseif SCENE == "level" then
        Level:update(dt)
    elseif SCENE == "level_end" then
        LevelEnd:update(dt)
    elseif SCENE == "death" then
        Death:update(dt)
    end
    UI:update(dt)
end

function love.draw()
    CAMERA:attach()
    if SCENE == "title" then
        Title:draw()
    elseif SCENE == "level" then
        Level:draw()
    elseif SCENE == "level_end" then
        LevelEnd:draw()
    elseif SCENE == "death" then
        Death:draw()
    end
    
    -- -- draw original bounds
    -- love.graphics.setColor(1, .3, .3)
    -- love.graphics.rectangle("line", 10, 10, BASE_WIDTH - 20, BASE_HEIGHT - 20)
    -- love.graphics.setColor(1,1,1)
    -- love.graphics.print(SCALE, CAMERA:worldCoords(400, 10))

    CAMERA:detach()
    UI:draw()

    -- Set black bars (letterbox/pillarbox)
    love.graphics.setColor(0, 0, 0) -- Black color for bars
    love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, OFFSET_Y) -- Top bar
    love.graphics.rectangle("fill", 0, WINDOW_HEIGHT - OFFSET_Y, WINDOW_WIDTH, OFFSET_Y) -- Bottom bar
    love.graphics.rectangle("fill", 0, 0, OFFSET_X, WINDOW_HEIGHT) -- Left bar
    love.graphics.rectangle("fill", WINDOW_WIDTH - OFFSET_X, 0, OFFSET_X, WINDOW_HEIGHT) -- Right bar
end

-- input management
function love.mousereleased(x, y, button)
    if button == 1 then
        x,y = CAMERA:worldCoords(x,y)
        for _, btn in ipairs(UI.buttons) do
            if x >= btn.x and x <= btn.x + btn.width
                and y >= btn.y and y <= btn.y + btn.height then
                btn:onClick()
                SFX.buttonSound:play()
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

-- function love.resize(w, h)
--     WINDOW_WIDTH, WINDOW_HEIGHT = w, h

--     -- Calculate aspect ratios
--     local aspectBase = BASE_WIDTH / BASE_HEIGHT
--     local aspectWindow = w / h

--     -- Calculate scale and offsets
--     if aspectWindow > aspectBase then
--         -- Window is wider than the base aspect, scale based on height
--         SET_SCALE(h / BASE_HEIGHT)
--         OFFSET_X = (w - BASE_WIDTH * SCALE) / 2
--         OFFSET_Y = 0
--     else
--         -- Window is taller than the base aspect, scale based on width
--         SET_SCALE(w / BASE_WIDTH)
--         OFFSET_X = 0
--         OFFSET_Y = (h - BASE_HEIGHT * SCALE) / 2
--     end
-- end

function RESET_CAMERA()
    CAMERA.x = BASE_WIDTH/2
    CAMERA.y = BASE_HEIGHT/2
    print(CAMERA.y)
end
function SET_SCALE(newScale)
    newScale = math.min(math.max(1, newScale), 3)
    SCALE = newScale
    -- zoom camera
    CAMERA:zoomTo(SCALE)
end