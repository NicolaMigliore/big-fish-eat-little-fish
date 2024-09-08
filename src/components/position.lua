local Position = Object:extend()

--- New position component
--- @param x number position X
--- @param y number position Y
--- @param dx number horizontal direction possible values: 1,-1
--- @param dy number vertical direction possible values: 1,-1
function Position:new(x, y, dx, dy)
    dx = dx or 1
    dy = dy or 1
    
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
end

return Position
