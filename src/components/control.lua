local Control = Object.extend(Object)
local Intention = Object.extend(Object)

function Control:new(keys)
    self.keys = keys
end

function Intention:new()
    self.left = false
    self.right = false
    self.up = false
    self.down = false
end

function Intention:setIntentions(newIntentions)
    for intention, value in pairs(newIntentions) do
        self[intention] = value
    end
end

function Intention:__tostring()
    local str = ""
    for key, value in pairs(self) do
        str = str.."\n"..key..": "..tostring(value)
    end
    return str
end

return { Control, Intention }
