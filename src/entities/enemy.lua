local Fish = require "src.entities.fish"
local Enemy = Fish:extend()

local scanTime = 3
local memoryTime = 1

function Enemy:new(x, y, size)
    Enemy.super.new(self, x, y, size, "assets/sprites/fish_01.png")
    self.type = "enemy"

    -- seek timer
    self.scanTimer = math.random(0.3)
    self.memoryTimer = 0
    self.target = { x = self.position.x, y = self.position.y }
    self.predator = nil
    self.prey = nil
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)
    local scanDistance = 100 + 5 * self.size

    -- cleare predator
    if self.predator ~= nil and Utils.pointDistance(self.position.x, self.position.y, self.predator.position.x, self.predator.position.y) > scanDistance then
        if self.memoryTimer > 0 then
            self.memoryTimer = self.memoryTimer - dt
        else
            self.predator = nil
        end
    end
    -- clear prey
    if self.prey ~= nil and Utils.pointDistance(self.position.x, self.position.y, self.prey.position.x, self.prey.position.y) > scanDistance then
        if self.memoryTimer > 0 then
            self.memoryTimer = self.memoryTimer - dt
        else
            self.prey = nil
        end
    end

    -- spot predator and prey
    if self.predator == nil or self.prey == nil then
        local colliders = world:queryCircleArea(self.position.x, self.position.y, scanDistance)
        for _, collider in ipairs(colliders) do
            local isFish = collider.collision_class == "Fish" --or collider.collision_class == "Player"
            if isFish then
                local entity = collider:getObject()
                local isOther = entity ~= self
                local sizeDelta = self.size - entity.size
                -- spot predator
                if self.predator == nil and isOther and sizeDelta < 5 then
                    self.predator = entity
                    self.memoryTimer = memoryTime
                end
                -- spot prey
                if self.prey == nil and isOther and sizeDelta >= 5 then
                    self.prey = entity
                    self.memoryTimer = memoryTime
                end
            end
        end
    end

    if Utils.tableContains({ "idle", "wander"}, self.state.current) and math.random() >.7 then
        self.scanTimer = self.scanTimer - dt
        if self.scanTimer < 0 then
            self.scanTimer = scanTime
        end
    end
end

function Enemy:draw()
    Enemy.super.draw(self)
    -- love.graphics.print(self.scanTimer, self.position.x - 16, self.position.y - 106)

    -- draw target line
    love.graphics.line(self.position.x, self.position.y, self.target.x, self.target.y)

    -- draw predator line
    if self.predator ~= nil then
        love.graphics.setColor(0.7, 0.2, 0.2)
        love.graphics.line(self.position.x, self.position.y, self.predator.position.x, self.predator.position.y)
        love.graphics.setColor(1, 1, 1)
    end

    -- draw prey line
    if self.prey ~= nil then
        love.graphics.setColor(0.2, 0.7, 0.2)
        love.graphics.line(self.position.x, self.position.y, self.prey.position.x, self.prey.position.y)
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print(tostring(self.state.current)..math.floor(self.memoryTimer), self.position.x - 16, self.position.y - 26)
end

function Enemy:fishControl()
    local intentionU, intentionR, intentionD, intentionL = false, false, false, false

    if Utils.tableContains({ "swim", "flee", "hunt", "wander" }, self.state.current) then
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
    local vx, vy = self.collider:getLinearVelocity()
    local direction = { x = 0, y = 0 }
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
            if self.predator ~= nil then
                return "flee"
            end
            if self.prey ~= nil then
                return "hunt"
            end

            if self.scanTimer < 1 then
                return "wander"
            end

            return "idle"
        end,
        flee = function()
            self.target = self:getNewTarget()
            if self.predator == nil then
                return "idle"
            end
            return "flee"
        end,
        hunt = function()
            self.target = self:getNewTarget()

            if self.prey == nil then
                return "idle"
            end
            return "hunt"
        end,
        wander = function()
            if self.state.previous == "idle" then
                self.target = self:getNewTarget()
            end

            -- check for predators and preys
            if self.predator ~= nil then
                return "flee"
            end
            if self.prey ~= nil then
                return "hunt"
            end
            if Utils.pointDistance(self.position.x, self.position.y, self.target.x, self.target.y) < 10 then
                return "idle"
            end

            return "wander"
        end,
        attack = function()

        end,
    }
    local state = State(states, "idle")
    return state
end

-- #region player control
function Enemy:getNewTarget()
    local borderPadding = 40
    local xOffset = 0
    local yOffset = 0
    local tx, ty = self.position.x, self.position.y

    if self.state.current == "flee" and self.predator ~= nil then
        local dx = self.position.x - self.predator.position.x
        local dy = self.position.y - self.predator.position.y
        local direction = Utils.normalizeVector2(dx, dy)

        tx = self.position.x + direction.x * 200
        ty = self.position.y + direction.y * 200

        -- invert direction if reaching world edges
        if tx > WORLD_WIDTH - borderPadding or tx < borderPadding then
            tx = self.position.x + direction.x * 200 * -1
        end
        if ty > WORLD_HEIGHT - borderPadding or ty < borderPadding then
            ty = self.position.y + direction.y * 200 * -1
        end
        return { x = tx + xOffset, y = ty + yOffset }
    end

    if self.state.current == "hunt" and self.prey ~= nil then
        tx = self.prey.position.x
        ty = self.prey.position.y
        return { x = tx + xOffset, y = ty + yOffset }
    end

    if self.state.current == "wander" then
        -- Ensure that fish in the edges of the screen will go toward the middle
        if self.position.x < WORLD_WIDTH / 5 then xOffset = WORLD_WIDTH / 5 end
        if self.position.x > WORLD_WIDTH / 5 * 4 then xOffset = -WORLD_WIDTH / 5 end
        if self.position.y < WORLD_HEIGHT / 50 then yOffset = WORLD_HEIGHT / 50 end
        if self.position.y > WORLD_HEIGHT / 50 * 49 then yOffset = -WORLD_HEIGHT / 5 end

        local rndX = math.random(-500, 500)
        local rndY = math.random(-50, 140)
        tx = math.max(borderPadding, math.min(self.target.x + rndX, WORLD_WIDTH - borderPadding))
        ty = math.max(borderPadding, math.min(self.target.y + rndY, WORLD_HEIGHT - borderPadding))
        return { x = tx + xOffset, y = ty + yOffset }
    end
    return { x = tx, y = ty }
end

return Enemy
