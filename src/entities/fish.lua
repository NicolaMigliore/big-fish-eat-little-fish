local Entity = require "src.entities.entity"
local Fish = Entity:extend()

--- Fish constructor
--- @param x number Position x coordinate
--- @param y number Position y coordinate
--- @param size number initial size
--- @param spriteFileName string file name fo rthe spritesheet
function Fish:new(id, x, y, size, spriteFileName)
    self.size = size or 5
    -- self.strength = 500 + 100 / self.size
    self.strength = 400 + 200 / self.size
    self.maxSpeed = 450 + 250 / self.size 
    local spr = Sprite(spriteFileName)

    -- configure collider
    local collider = world:newRectangleCollider(x - 16, y - 8, 32 * self.size / 10, 16 * self.size / 10)
    collider:setFixedRotation(true)
    collider:setMass(1)
    collider:setLinearDamping(1)
    collider:setCollisionClass("Fish")
    collider:setObject(self)

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
    Fish.super.new(self, id, "fish", spr, entityOptions)
end

function Fish:update(dt)
    Fish.super.update(self, dt)

    self:fishControl()

    self.position.x = self.collider:getX()
    self.position.y = self.collider:getY()

    -- check collisions
    local fishClasses = {"Fish", "Player"}
    for _, cl in ipairs(fishClasses) do
        if self.collider:enter(cl) then
            local collisionData = self.collider:getEnterCollisionData(cl)
            local other = collisionData.collider:getObject()
            if other then
                local sizeDelta = self.size - other.size
                if sizeDelta >= 5 then
                -- if fish is larger than other
                self:eat()
                other:kill()
                elseif sizeDelta < 5 then 
                    other:eat()
                    self:kill()
                else
                    print("same size")
                end
            end
        end
    end
end

function Fish:draw()
    -- Fish.super.draw(self)
    local activeAnim = self.animationController.activeAnimation
    local frameToDraw = activeAnim.frames[math.floor(self.animationController.currentFrame)]
    local dx = (activeAnim.flipX or self.position.dx < 0) and -1 or 1
    local dy = activeAnim.flipY and -1 or 1
    local scaleX = dx * self.size / 10
    local scaleY = dy * self.size / 10
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

function Fish:eat()
    self.size = self.size + 2
end

function Fish:createState()
    return State({}, "idle")
end

return Fish
