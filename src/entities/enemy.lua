local Fish = require "src.entities.fish"
local Enemy = Fish:extend()

function Enemy:new(x, y)
    Enemy.super.new(self, x, y, "assets/sprites/fish_01.png")
    self.type = "enemy"

    -- seek timer
    self.seekTimer = 10
    self.target = { x = self.position.x, y = self.position.y }
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)
    self.seekTimer = self.seekTimer - dt
end

function Enemy:draw()
    Enemy.super.draw(self)
    love.graphics.print(self.seekTimer, self.position.x - 16, self.position.y - 106)

    love.graphics.setColor(.7, .7, .2)
    love.graphics.circle("fill", self.target.x, self.target.y, 5)
    love.graphics.setColor(1, 1, 1)
end

function Enemy:fishControl()
    local vx, vy = self.collider:getLinearVelocity()
    local direction = { x = 0, y = 0 }
    local intentionU, intentionR, intentionD, intentionL = false, false, false, false

    if self.state.current == "swim" then
        intentionU = self.target.y < self.position.y
        intentionR = self.target.x > self.position.x
        intentionD = self.target.y > self.position.y
        intentionL = self.target.x < self.position.x
    end

    -- set enemy intention
    self.intention:setIntentions({
        up = intentionU,
        right = intentionR,
        down = intentionD,
        left = intentionL,
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

function Enemy:createState()
    local states = {
        idle = function()
            -- reach target
            local targetDistance = Utils.pointDistance(self.position.x, self.position.y, self.target.x, self.target.y)
            if targetDistance > 10 then
                return "swim"
            end

            -- seek for new position
            if self.seekTimer < 0 then
                local shouldSeek = math.random() > 0.3
                if shouldSeek then
                    return "seek"
                end
            end


            return "idle"
        end,
        seek = function()
            self.target = self:getNewTarget()
            return "idle"
        end,
        swim = function()
            -- stop swimming if target was reached
            local targetDistance = Utils.pointDistance(self.position.x, self.position.y, self.target.x, self.target.y)
            if targetDistance <= 10 then
                self.seekTimer = 5
                return "idle"
            end
            return "swim"
        end,
        hunt = function()

        end,
    }
    local state = State(states, "idle")
    return state
end

function Enemy:getNewTarget()
    local borderPadding = 40
    local xOffset = 0
    local yOffset = 0

    -- Ensure that fish in the edges of the screen will go toward the middle
    if self.position.x < WORLD_WIDTH / 5 then xOffset = WORLD_WIDTH / 5 end
    if self.position.x > WORLD_WIDTH / 5 * 4 then xOffset = - WORLD_WIDTH / 5 end
    if self.position.y < WORLD_HEIGHT / 50 then yOffset = WORLD_HEIGHT / 50 end
    if self.position.y > WORLD_HEIGHT / 50 * 49 then yOffset = - WORLD_HEIGHT / 5 end

    local rndX = math.random(-500, 500)
    local rndY = math.random(-20, 40)
    local tx = math.max(borderPadding, math.min(self.target.x + rndX, WORLD_WIDTH - borderPadding))
    local ty = math.max(borderPadding, math.min(self.target.y + rndY, WORLD_HEIGHT - borderPadding))

    local ret = { x = tx + xOffset, y = ty + yOffset }
    return ret
end

return Enemy
