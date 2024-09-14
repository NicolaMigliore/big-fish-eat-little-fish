local Fish = require "src.entities.fish"
local Player = Fish:extend()

function Player:new(id, x, y)
    Player.super.new(self,id, x, y, 10, "assets/sprites/fish_01.png")

    self.type = "player"
    self.collider:setCollisionClass("Player")

    -- configure control
    self.control = Control(
        {
            left = { "left", "a" },
            right = { "right", "d" },
            up = { "up", "w" },
            down = { "down", "s" }
        })
end

function Player:update(dt)
    Player.super.update(self, dt)

    self:fishControl()

    self.position.x = self.collider:getX()
    self.position.y = self.collider:getY()
end

function Player:draw()
    Player.super.draw(self)
end

function Player:fishControl()
    if self.state.current == "death" then
        return
    end
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
            if self.intention.right or self.intention.left then return "swim" end

            return "idle"
        end,
        swim = function()
            if not self.intention.right and not self.intention.left then
                return "idle"
            end
            return "swim"
        end,
        death = function()
            self.control = nil
            return "death"
        end
    }
    local state = State(states, "idle")
    return state
end

function Player:eat()
    if self.size <= 30 then
        self.size = self.size + 2
        local newZoom = 2 - (self.size - 10) * (2 - 0.7) / (30 - 10)
        CAMERA:zoomTo(newZoom)
    end
    SCORE = SCORE + math.floor(self.size / 10)
end

function Player:kill()
    self.state:setState("death", self)
end

return Player
