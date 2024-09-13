local Particles = Object.extend(Object)

-- available particle systems
function Particles:new(type)
    self.boubles = nil
end

function Particles:addBoubleParticle()
    local boubleImg = love.graphics.newImage("assets/particles/bouble.png")
    local boubleParticles = love.graphics.newParticleSystem(boubleImg, 32)
    boubleParticles:setParticleLifetime(1,5)
    boubleParticles:setLinearAcceleration(-5,-25,5,0)
    -- boubleParticles:setSpeed(0,20)
    boubleParticles:setRotation(0,100)
     self.boubles = boubleParticles
end

function Particles:getKeys()
    return { "boubles" }
end

return Particles