local Animation = Object.extend(Object)
local AnimationController = Object.extend(Object)

function Animation:new(imagePath, frames, width, height, speed, flipX, flipY)
    self.imagePath = imagePath
    self.frames = frames
    self.width = width or 32
    self.height = height or 32
    self.speed = speed or 1
    self.flipX = flipX or false
    self.flipY = flipY or false
end

function Animation.GetFrames(image, frameCount, frameW, frameH, offsetX, offsetY)
    local frames = {}
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    for i = 0, frameCount do
        -- 1 + i * (frameW + 2) ->
        -- skip 1 extruded pixel on the left
        -- move each quand considering the 2 extruded pixels on each side of each frame
        local quadX = 1 + i * (frameW + 2) + offsetX
        local quadY = 1 + offsetY
        local frame = love.graphics.newQuad(quadX, quadY, frameW, frameH, image:getWidth(), image:getHeight())
        table.insert(frames, frame)
    end

    return frames
end

function AnimationController:new(animations, activeAnimation)
    local activeAnimationName = activeAnimation or "idle"
    self.animations = animations
    self.activeAnimation = animations[activeAnimationName]
    self.currentFrame = 1
end

function AnimationController:setAnimation(newAnimationName)
    self.activeAnimation = self.animations[newAnimationName]
end

return { Animation, AnimationController }
