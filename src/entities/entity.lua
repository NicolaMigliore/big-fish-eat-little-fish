local Entity = Object.extend(Object)

--- New Entity Constructor
---@diagnostic disable-next-line: undefined-doc-name
---@param options table table of components to add to the entity
function Entity:new(id, type, options)
    self.id = id or Utils:uuid()
    self.type = type
    self.scale = options.scale or 1
    self.sprite = options.sprite
    self.position = options.position
    self.collider = options.collider
    self.control = options.control
    self.intention = options.intention
    self.animationController = options.animationController
    self.state = options.state
    self.particles = options.particles
end

function Entity:update(dt)
    -- update animation
    if self.animationController then
        local activeAnim = self.animationController.activeAnimation
        self.animationController.currentFrame = self.animationController.currentFrame + dt * self.animationController.activeAnimation.speed
        if self.animationController.currentFrame > #activeAnim.frames then
            if activeAnim.loop then
                self.animationController.currentFrame = 1 
            else
                self.animationController.currentFrame = #activeAnim.frames - 1
            end    
        end
    end

    -- update state
    if self.state then
        self.state:update(self)
    end
end

function Entity:draw()
    -- render animation
    if self.animationController and self.animationController.activeAnimation and self.position then 
        local activeAnim = self.animationController.activeAnimation
        local frameToDraw = activeAnim.frames[math.floor(self.animationController.currentFrame)]
        local scaleX = (activeAnim.flipX or self.position.dx < 0) and -self.scale or self.scale
        local scaleY = activeAnim.flipY and -self.scale or self.scale
        love.graphics.draw(
            self.sprite.image,
            frameToDraw,
            self.position.x,
            self.position.y,
            nil,
            scaleX,
            scaleY,
            activeAnim.width / 2,
            activeAnim.height / 2
        )
    -- render single sprite
    elseif self.sprite and self.position then
        love.graphics.draw(
            self.sprite.image,
            self.position.x - self.sprite.width / 2,
            self.position.y - self.sprite.height / 2
        )
    end
end

function Entity:kill()
    self.collider:destroy()
    ENTITIES[self.id] = nil
end

return Entity
