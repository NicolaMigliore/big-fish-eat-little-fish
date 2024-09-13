local UI = Object.extend(Object)

local buttonFont = love.graphics.newFont(25)

function UI:new()
    self.buttons = {}
    self.labels = {}
    self.yOffset = 0
end

function UI:update(dt)
    local windowCenter = { x = love.graphics:getWidth() / 2, y = love.graphics:getHeight() / 2 }
    -- update layout
    for _, btn in pairs(self.buttons) do
        btn.x = windowCenter.x - btn.width / 2
    end

    -- check button interaction
end

function UI:draw()
    -- draw buttons
    love.graphics.setFont(buttonFont)
    for i, btn in pairs(self.buttons) do
        btn.y = self.yOffset + i * (btn.height + 10)
        love.graphics.setColor(unpack(btn.color))
        love.graphics.rectangle(
            "fill",
            btn.x,
            btn.y,
            btn.width,
            btn.height
        )
        love.graphics.setColor(1, 1, 1, 1)
        local textW, textH = buttonFont:getWidth(btn.text), buttonFont:getHeight()
        local textX = btn.x + (btn.width / 2) - (textW / 2)
        local textY = btn.y + (btn.height / 2) - (textH / 2)
        love.graphics.print(btn.text, textX, textY)
    end
end

function UI:clearUI()
    self.buttons = {}
    self.labels = {}
end
function UI:addButton(newButton)
    table.insert(self.buttons, newButton)
end

function UI:addLabel(key, text, x, y)
    self.labels[key] = {x = x, y = y, text = text}
end


return UI
