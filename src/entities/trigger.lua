local Entity = require "src.entities.entity"
local Trigger = Entity:extend()

function Trigger:new(x, y, collider, trigger_func)
    local position = Position(x, y)
    Trigger.super.new(self, nil, "trigger", {position = position, collider = collider})

    self.trigger = trigger_func
end

function Trigger:update(dt)
    local triggerSubjectClasses = {"Player"}
    for _, cl in ipairs(triggerSubjectClasses) do
        if self.collider:enter(cl) then
            local collisionData = self.collider:getEnterCollisionData(cl)
            local other = collisionData.collider:getObject()
            self.trigger(self, other)
        end
    end
end

return Trigger