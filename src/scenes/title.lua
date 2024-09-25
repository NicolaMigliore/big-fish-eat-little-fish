local Title = Object.extend(Object)

local titleImage

-- ui elements
function Title:load()
    titleImage = love.graphics.newImage("assets/title.png")
    SFX.levelMusic:play()
end

function Title:update(dt)
end

function Title:draw()
    love.graphics.setColor(1,1,1)
    local imgScale = 4
    local windowCenter = { x = BASE_WIDTH/2, y = BASE_HEIGHT/2 }
    local yOffset = math.min(titleImage:getHeight() * 4, 300)
    love.graphics.draw(
        titleImage,
        windowCenter.x,
        yOffset,
        0,
        imgScale,
        imgScale,
        titleImage:getWidth() / 2,
        titleImage:getHeight() / 2
    )

    yOffset = yOffset + titleImage:getHeight() / 1.5
    UI.yOffset = yOffset + titleImage:getHeight() / 5
end

function LOAD_SCENE_TITLE()
    SCENE = "title"
    RESET_CAMERA()
    SET_SCALE(1)
    love.graphics.setBackgroundColor(love.math.colorFromBytes(44, 232, 245))
    
    UI:clearUI()

    local r, g, b = love.math.colorFromBytes(24,20,37)
    -- button
    local button = {
        x = nil,
        y = nil,
        width = 350,
        height = 50,
        color = { r, g, b },
        text = "START GAME",
        onClick = function() LOAD_SCENE_LEVEL(2) end
    }
    -- table.insert(buttons, button)
    UI:addButton(button)
end

return Title
