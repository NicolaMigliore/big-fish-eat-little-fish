local Fish = require "src.entities.fish"
local Player = Fish:extend()

function Player:new(x, y)
    Player.super.new(self, x,y,"assets/sprites/fish_01.png")

    self.type = "player"
    
    -- configure control
    self.control  = Control(
        {
            left = { "left", "a" },
            right = { "right", "d" },
            up = { "up", "w" },
            down = { "down", "s" }
        })

    -- define states
    self.state = self:createState()
end

function Player:update(dt)
    Player.super.update(self, dt)

    self:fishControl()

    self.position.x = self.collider:getX()
    self.position.y = self.collider:getY()
end

function Player:draw()
    Player.super.draw(self)

    love.graphics.print(self.position.dx, 10, 10)
    love.graphics.print(self.position.dy, 10, 20)
    love.graphics.print(self.type, 10, 30)
end

function Player:fishControl()
    local vx, vy = self.collider:getLinearVelocity()
    local direction = { x = 0, y = 0 }

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
    self.collider:applyForce(self.strength * direction.x, self.strength * direction.y)

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
end

function Player:createState()
    local states = {
        idle = function()
            if self.intention.right then return "swim_right" end
            if self.intention.left then return "swim_left" end

            return "idle"
        end,
        swim_right = function()
            if not self.intention.right then
                return "idle"
            end

            return "swim_right"
        end,
        swim_left = function()
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
