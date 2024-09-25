local LevelEnd = Object.extend(Object)

function LevelEnd:load()

end

function LevelEnd:update(dt)
end

function LevelEnd:draw()
    local panelW = 450
    local panelH = 480
    local panelX = love.graphics:getWidth() / 2 - panelW / 2

    love.graphics.setColor(love.math.colorFromBytes(90, 105, 136))
    love.graphics.rectangle("fill", panelX - 5, 95, panelW + 10, panelH + 10)

    love.graphics.setColor(love.math.colorFromBytes(139, 155, 180))
    love.graphics.rectangle("fill", panelX, 100, panelW, panelH)

    -- labels
    -- love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setColor(love.math.colorFromBytes(254,174,52))
    local text1 = "LEVEL COMPLETE"
    local textW = UI.fonts.labelFont:getWidth(text1)
    local textH = UI.fonts.labelFont:getHeight(text1)
    local labelX = (love.graphics:getWidth() / 2) - textW / 2
    local yOffset = 100
    love.graphics.print(text1, labelX, yOffset)

    local text2 = "Score:" .. SCORE
    yOffset = yOffset + textH
    textW = UI.fonts.labelFont:getWidth(text2)
    labelX = (love.graphics:getWidth() / 2) - textW / 2
    love.graphics.print(text2, labelX, yOffset)
end

function LOAD_SCENE_LEVEL_END()
    SCENE = "level_end"
    SET_SCALE(1)
    RESET_CAMERA()
    love.graphics.setBackgroundColor(love.math.colorFromBytes(44, 232, 245))

    UI:clearUI()

    local r, g, b = love.math.colorFromBytes(24,20,37)

    UI:addButton({
        x = nil,
        y = 375,
        width = 350,
        height = 50,
        color = { r, g, b },
        text = "RESTART",
        onClick = function() LOAD_SCENE_LEVEL() end
    })
    UI:addButton({
        x = nil,
        y = 450,
        width = 350,
        height = 50,
        color = { r, g, b },
        text = "TITLE SCREEN",
        onClick = function() LOAD_SCENE_TITLE() end
    })
end

return LevelEnd
