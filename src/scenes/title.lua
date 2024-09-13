local Title = Object.extend(Object)

local titleImage

-- ui elements
local buttons = {}
function Title:load()
    titleImage = love.graphics.newImage("assets/title.png")
end

function Title:update(dt)
end

function Title:draw()
    local imgScale = 4
    local windowCenter = { x = love.graphics:getWidth() / 2, y = love.graphics:getHeight() / 2 }
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
    -- -- draw buttons
    -- love.graphics.setFont(buttonFont)
    -- for i, btn in pairs(buttons) do
    --     btn.y = yOffset + i * (btn.height + 10)
    --     love.graphics.setColor(unpack(btn.color))
    --     love.graphics.rectangle(
    --         "fill",
    --         btn.x,
    --         btn.y,
    --         btn.width,
    --         btn.height
    --     )
    --     love.graphics.setColor(1, 1, 1, 1)
    --     local textW, textH = buttonFont:getWidth(btn.text), buttonFont:getHeight()
    --     local textX = btn.x + (btn.width / 2) - (textW / 2)
    --     local textY = btn.y + (btn.height / 2) - (textH / 2)
    --     love.graphics.print(btn.text, textX, textY)
    -- end
    -- love.graphics.setFont()              -- reset font
    love.graphics.setColor(1, 1, 1, 1)
end

function LOAD_SCENE_TITLE()
    SCENE = "title"
    UI:clearUI()
    love.graphics.setBackgroundColor(love.math.colorFromBytes(44, 232, 245))

    -- button
    local button = {
        x = 100,
        y = 100,
        width = 350,
        height = 50,
        color = { .6, .7, .9, 1 },
        text = "START GAME",
        onClick = function() LOAD_SCENE_LEVEL() end
    }
    -- table.insert(buttons, button)
    UI:addButton(button)
end

return Title
