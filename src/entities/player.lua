local Entity = require "src.entities.entity"
local Player = Entity:extend()

local maxSpeed = 100
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

    Player.super.new(self, x, y, maxSpeed, spr, { collider = collider, control = control })
    self.sprite = spr
    self.size = 10
end

function Player:update(dt)
    self.super.update(self, dt)

    self:playerControl()

    self.x = self.collider:getX()
    self.y = self.collider:getY()
end

function Player:draw()
    self.super.draw(self)
end

function Player:playerControl()
    local vx, vy = self.collider:getLinearVelocity()
    local direction = { x = 0, y = 0 }
    local friction = { x = 0, y = 0 }

    local intention = {
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
        up = love.keyboard.isDown("up"),
        down = love.keyboard.isDown("down")
    }

    -- accellerate
    if intention.left and vx > -self.maxSpeed then
        direction.x = direction.x - 1
    end
    if intention.right and vx < self.maxSpeed then
        direction.x = direction.x + 1
    end
    if intention.up and vy > -self.maxSpeed then
        direction.y = direction.y - 1
    end
    if intention.down and vy < self.maxSpeed then
        direction.y = direction.y + 1
    end

    direction = Utils.normalizeVector2(direction.x, direction.y)
    self.collider:applyForce(strength * direction.x, strength * direction.y)

    -- decellerate
    if not intention.left and vx < 0 then
        -- self.collider:applyForce(WATER_FRICTION, 0)
        friction.x = friction.x + 1
    end
    if not intention.right and vx > 0 then
        -- self.collider:applyForce(-WATER_FRICTION, 0)
        friction.x = friction.x - 1
    end
    if not intention.up and vy < 0 then
        -- self.collider:applyForce(0, WATER_FRICTION)
        friction.y = friction.y + 1
    end
    if not intention.down and vy > 0 then
        -- self.collider:applyForce(0, -WATER_FRICTION)
        friction.y = friction.y - 1
    end

    friction = Utils.normalizeVector2(friction.x, friction.y)
    self.collider:applyForce(friction.x * WATER_FRICTION, friction.y * WATER_FRICTION)
end

return Player
