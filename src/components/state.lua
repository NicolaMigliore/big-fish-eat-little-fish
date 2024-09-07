local State = Object.extend(Object)

function State:new(states, current)
    self.states = states
    self.previous = nil
    self.current = current or"idle"
end

function State:update()
    -- run the current state function
    local stateFunction = self.states[self.current]
    if stateFunction then
        local newState = stateFunction(self)
        if newState ~= self.current then
            self:setState(newState)
        end
    end
end

function State:setState(newState)
    self.previous = self.current
    self.current = newState
end

return State