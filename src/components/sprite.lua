local Sprite = Object.extend(Object)

function Sprite:new(sprite, width, height)
    local img = love.graphics.newImage(sprite)
    self.image = img or love.graphics.newImage("assets/sprites/missing.png")
    self.width = width or 32
    self.height = height or 32
end

return Sprite