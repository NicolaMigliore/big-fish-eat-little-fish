local Entity = require "src.entities.entity"
local Player = Entity:extend()

local maxSpeed = 500
local strength = 20000

function Player:new(x, y)
    local spr = Sprite("assets/sprites/fish_01.png")

    -- configure collider
    local collider = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    collider:setFixedRotation(true)
    collider:setMass(100)

    -- configure control
    local control = Control(
        {
            left = { "left", "a" },
            right = { "right", "d" },
            up = { "up", "w" },
            down = { "down", "s" }
        })
    local intention = Intention()

    -- define animations
    local animationController = self:createAnimationController()

    -- define states
    local state = self:createState()

    local position = Position(x, y)
    local entityOptions = {
        position = position,
        collider = collider,
        control = control,
        intention = intention,
        animationController = animationController,
        state = state
    }
    Player.super.new(self, maxSpeed, spr, entityOptions)

    self.size = 10
end

function Player:update(dt)
    self.super.update(self, dt)

    self:playerControl()

    self.position.x = self.collider:getX() + self.animationController.activeAnimation.width / 2
    self.position.y = self.collider:getY() + self.animationController.activeAnimation.height / 2
end

function Player:draw()
    self.super.draw(self)

    love.graphics.print(self.position.dx, 10, 10)
    love.graphics.print(self.position.dy, 10, 20)
end

function Player:playerControl()
    local vx, vy = self.collider:getLinearVelocity()
    local direction = { x = 0, y = 0 }
    local friction = { x = 0, y = 0 }

    -- set player intentions
    self.intention:setIntentions({
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
        up = love.keyboard.isDown("up"),
        down = love.keyboard.isDown("down")
    })

    -- accellerate
    if self.intention.left and vx > -self.maxSpeed then direction.x = direction.x - 1 end
    if self.intention.right and vx < self.maxSpeed then direction.x = direction.x + 1 end
    if self.intention.up and vy > -self.maxSpeed then direction.y = direction.y - 1 end
    if self.intention.down and vy < self.maxSpeed then direction.y = direction.y + 1 end

    direction = Utils.normalizeVector2(direction.x, direction.y)
    self.collider:applyForce(strength * direction.x, strength * direction.y)

    -- set player direction
    if direction.x > 0 then
        self.position.dx = 1
    elseif direction.x < 0 then
        self.position.dx = -1
    end
    if direction.y > 0 then
        self.position.dy = 1
    elseif direction.y < 0 then
        self.position.dy = -1
    end

    -- decellerate
    if not self.intention.left and vx < 0 then friction.x = friction.x + 1 end
    if not self.intention.right and vx > 0 then friction.x = friction.x - 1 end
    if not self.intention.up and vy < 0 then friction.y = friction.y + 1 end
    if not self.intention.down and vy > 0 then friction.y = friction.y - 1 end

    friction = Utils.normalizeVector2(friction.x, friction.y)
    self.collider:applyForce(friction.x * WATER_FRICTION, friction.y * WATER_FRICTION)
end

function Player:createAnimationController()
    local spritesFileName = "assets/sprites/fish_01.png"
    --idle
    local idleFrames = Animation.GetFrames(spritesFileName, 4, 32, 32, 0, 0)
    local idleAnimation = Animation(spritesFileName, idleFrames, 32, 32, 1)
    -- swim_right
    local swim_rightFrames = Animation.GetFrames(spritesFileName, 4, 32, 32, 0, 68)
    local swim_rightAnimation = Animation(spritesFileName, swim_rightFrames, 32, 32, 1, false, false)
    -- swim_left
    local swim_leftFrames = Animation.GetFrames(spritesFileName, 4, 32, 32, 0, 68)
    local swim_leftAnimation = Animation(spritesFileName, swim_leftFrames, 32, 32, 1, true, false)

    local animationController = AnimationController(
    { idle = idleAnimation, swim_right = swim_rightAnimation, swim_left = swim_leftAnimation }, "idle")
    return animationController
end

function Player:createState()
    local states = {
        idle = function()
            -- set animation
            if self.state.current ~= self.state.previous then self.animationController:setAnimation("idle") end
            if self.intention.right then return "swim_right" end
            if self.intention.left then return "swim_left" end

            return "idle"
        end,
        swim_right = function()
            -- set animation
            if self.state.current ~= self.state.previous then self.animationController:setAnimation("swim_right") end

            if not self.intention.right then
                return "idle"
            end

            return "swim_right"
        end,
        swim_left = function()
            -- set animation
            if self.state.current ~= self.state.previous then self.animationController:setAnimation("swim_left") end

            if not self.intention.left then
                return "idle"
            end

            return "swim_left"
        end,
    }
    local state = State(states, "idle")
    return state
end

return Player
