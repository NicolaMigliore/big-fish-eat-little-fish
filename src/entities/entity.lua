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
    self.intention = options.intention
    self.animationController = options.animationController
    self.state = options.state
end

function Entity:update(dt)
    -- update animation
    if self.animationController then
        local activeAnim = self.animationController.activeAnimation
        self.animationController.currentFrame = self.animationController.currentFrame + dt * self.animationController.activeAnimation.speed
        if self.animationController.currentFrame > #activeAnim.frames then self.animationController.currentFrame = 1 end
    end

    -- update state
    if self.state then
        self.state:update()
    end
end

function Entity:draw()
    -- render animation
    if self.animationController then 
        local activeAnim = self.animationController.activeAnimation
        local frameToDraw = activeAnim.frames[math.floor(self.animationController.currentFrame)]
        local scaleX = activeAnim.flipX and -1 or 1
        local scaleY = activeAnim.flipY and -1 or 1
        love.graphics.draw(
            self.sprite.sprite,
            frameToDraw,
            self.x - activeAnim.width / 2,
            self.y - activeAnim.height / 2,
            nil,
            scaleX,
            scaleY,
            activeAnim.width / 2,
            activeAnim.height / 2
        )
    -- render single sprite
    elseif self.sprite then
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
