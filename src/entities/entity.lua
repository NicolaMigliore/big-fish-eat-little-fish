local Entity = Object.extend(Object)

--- New Entity Constructor
--- @param x number position X
--- @param y number position Y
---@param maxSpeed number entity max speed
---@diagnostic disable-next-line: undefined-doc-name
---@param sprite Sprite entity sprite data
function Entity:new(x, y, maxSpeed, sprite, options)
    self.x = x
    self.y = y
    self.maxSpeed = maxSpeed
    self.sprite = sprite
    self.collider = options.collider
    self.control = options.control
end

function Entity:update(dt)
end

function Entity:draw()
    if self.sprite then
        love.graphics.draw(
            self.sprite.sprite,
            self.x - self.sprite.width / 2,
            self.y - self.sprite.height / 2
        )
    end
end

-- set current entity sprite
function Entity:setSprite()

end

return Entity
