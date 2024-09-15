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


-- Define global objects
WORLD_WIDTH, WORLD_HEIGHT = 2048, 8000
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
    SFX.biteSound = love.audio.newSource("assets/audio/sounds/bite.mp3", "static")
    SFX.playerBiteSound = SFX.biteSound:clone()
    SFX.playerHitSound = SFX.biteSound:clone()
    SFX.playerHitSound:setPitch(0.5)
    SFX.biteSound:setVolume(0.5)
    SFX.biteSound:setPitch(2)
    -- load music
    SFX.levelMusic = love.audio.newSource("assets/audio/music/level_music.mp3", "stream")
    
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
    if SCENE == "title" then
        Title:draw()
    elseif SCENE == "level" then
        Level:draw()
    elseif SCENE == "level_end" then
        LevelEnd:draw()
    elseif SCENE == "death" then
        Death:draw()
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
