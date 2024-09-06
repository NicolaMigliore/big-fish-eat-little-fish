local Utils = Object.extend(Object)

--- calc distance between two points
---@param x1 number point 1 x coord
---@param y1 number point 1 y coord
---@param x2 number point 2 x coord
---@param y2 number point 2 y coord
---@return number
function Utils.pointDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Utils.drawDashedLine(x1, y1, x2, y2, dashLength, gapLength)
    dashLength = dashLength or 10
    gapLength = gapLength or 5
    local dx = x2 - x1
    local dy = y2 - y1
    local totalLength = math.sqrt(dx * dx + dy * dy)

    local numDashes = math.floor(totalLength / (dashLength + gapLength))

    -- Normalize direction vector
    local dirX = dx / totalLength
    local dirY = dy / totalLength

    for i = 0, numDashes do
        local startX = x1 + dirX * (i * (dashLength + gapLength))
        local startY = y1 + dirY * (i * (dashLength + gapLength))
        local endX = startX + dirX * dashLength
        local endY = startY + dirY * dashLength

        love.graphics.line(startX, startY, endX, endY)
    end
end

--- Check if a point is colliding with a box area
--- @param px number Point X coord
--- @param py number Point Y coord
--- @param bx number Box top-left corner X coord
--- @param by number Box top-left corner Y coord
--- @param bw number Box width
--- @param bh number Box height
--- @return boolean
function Utils.pointToBoxCollision(px, py, bx, by, bw, bh)
    -- check x coord
    if px >= bx and px <= bx + bw then
        -- check y coord
        if py >= by and py <= by + bh then
            return true
        end
    end
    return false
end

--- Normalize a Vector2. Usefull to calculate diagonal movement.
--- @param vx number Vector x value from 0 to 1
--- @param vy number Vector y value from 0 to 1
--- @return table
function Utils.normalizeVector2(vx, vy)
    local length = math.sqrt(vx ^ 2 + vy ^ 2)
    local normalizedX, normalizedY = 0, 0
    if length > 0 then
        normalizedX = vx / length
        normalizedY = vy / length
    end
    return { x = normalizedX, y = normalizedY }
end

return Utils
