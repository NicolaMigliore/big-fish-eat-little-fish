local UI = Object.extend(Object)

local buttonFont = love.graphics.newFont("assets/mago2.ttf",60)
local labelFont = love.graphics.newFont("assets/mago2.ttf",75)

function UI:new()
    self.buttons = {}
    self.labels = {}
    self.yOffset = 0
    self.fonts = {
        buttonFont = buttonFont,
        labelFont = labelFont
    }
end

function UI:update(dt)
    local windowCenter = { x = BASE_WIDTH/2, y = BASE_HEIGHT/2 }
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
        btn.y = btn.y or (self.yOffset + i * (btn.height + 10))
        love.graphics.setColor(unpack(btn.color))
        love.graphics.rectangle(
            "fill",
            btn.x,
            btn.y,
            btn.width,
            btn.height
        )
        love.graphics.setColor(love.math.colorFromBytes(254,174,52))
        local textW, textH = buttonFont:getWidth(btn.text), buttonFont:getHeight()
        local textX = btn.x + (btn.width / 2) - (textW / 2)
        local textY = btn.y + (btn.height / 2) - (textH / 2) - 3
        love.graphics.print(btn.text, textX, textY)
    end
    -- draw labels
    love.graphics.setFont(labelFont)
    love.graphics.setColor(love.math.colorFromBytes(254,174,52))
    for key,label in pairs(self.labels) do
        love.graphics.print(label.text, label.x, label.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
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
function UI:updateLabel(key, newLabel)
    if self.labels[key] ~= nil then
        self.labels[key].text = newLabel
    end
end


return UI
