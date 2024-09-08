local Entity = require "src.entities.entity"
local Fish = Entity:extend()

function Fish:new(x, y, spriteFileName)
    self.maxSpeed = 500
    self.strength = 20000
    self.size = 10
    local spr = Sprite(spriteFileName)

    -- configure collider
    local collider = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    collider:setFixedRotation(true)
    collider:setMass(100)
    collider:setLinearDamping(1)

    -- configure control
    -- local control = Control()
    local intention = Intention()

    -- define animations
    local animationController = self:createAnimationController(spr)

    -- define states
    local state = self:createState()

    local position = Position(x, y)
    local entityOptions = {
        position = position,
        collider = collider,
        -- control = control,
        intention = intention,
        animationController = animationController,
        state = state,
    }
    Fish.super.new(self, "fish", spr, entityOptions)
end

function Fish:update(dt)
    Fish.super.update(self, dt)

    self:fishControl()

    self.position.x = self.collider:getX()
    self.position.y = self.collider:getY()
end

function Fish:draw()
    Fish.super.draw(self)
    love.graphics.print(self.state.current, self.position.x - 16, self.position.y - 36)
end

function Fish:createAnimationController(spr)
    --idle
    local idleFrames = Animation.GetFrames(spr.image, 4, 32, 32, 0, 0)
    local idleAnimation = Animation(spr.image, idleFrames, 32, 32, 1)
    --seek
    local seekAnimation = Animation(spr.image, idleFrames, 32, 32, 1)
    -- swim_right
    local swimFrames = Animation.GetFrames(spr.image, 4, 32, 32, 0, 68)
    local swimAnimation = Animation(spr.image, swimFrames, 32, 32, 1, false, false)
    -- swim_right
    local swim_rightFrames = Animation.GetFrames(spr.image, 4, 32, 32, 0, 68)
    local swim_rightAnimation = Animation(spr.image, swim_rightFrames, 32, 32, 1, false, false)
    -- swim_left
    local swim_leftFrames = Animation.GetFrames(spr.image, 4, 32, 32, 0, 68)
    local swim_leftAnimation = Animation(spr.image, swim_leftFrames, 32, 32, 1, true, false)

    local animationController = AnimationController({
        idle = idleAnimation,
        swim = swimAnimation,
        swim_right = swim_rightAnimation,
        swim_left = swim_leftAnimation,
        seek = seekAnimation,
    }, "idle")
    return animationController
end

function Fish:createState()
    return State({}, "idle")
end

return Fish
