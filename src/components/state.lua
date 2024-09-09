local State = Object.extend(Object)

function State:new(states, current)
    self.states = states
    self.previous = nil
    self.current = current or"idle"
end

function State:update(entity)
    -- run the current state function
    local stateFunction = self.states[self.current]
    if stateFunction then
        local newState = stateFunction(self)
            self:setState(newState, entity)
    end
end

function State:setState(newState, entity)
    self.previous = self.current
    self.current = newState

    -- set new animation
    if entity.animationController then
        entity.animationController:setAnimation(newState)
    end
end

return State