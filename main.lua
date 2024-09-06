io.stdout:setvbuf("no")
-- debugger setup
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- load libraries
wf = require 'libs.windfield'

function love.load()
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 0)
end

function love.update(dt)
    world:update(dt)
end
