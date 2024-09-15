local Particles = Object.extend(Object)

-- available particle systems
function Particles:new(type)
    self.boubles = nil
    self.dust = nil
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

function  Particles:addDustParticle()
    local dustImg = love.graphics.newImage("assets/particles/dust.png")
    local dustParticles = love.graphics.newParticleSystem(dustImg, 32)
    dustParticles:setParticleLifetime(5,15)
    dustParticles:setLinearAcceleration(-1,-3,1,5)
    dustParticles:setRotation(0,100)
    dustParticles:setEmissionRate(10000000)
    dustParticles:setSizes(1, 1.2, 0.2)
    self.dust = dustParticles
end

function Particles:getKeys()
    return { "boubles", "dust" }
end

return Particles