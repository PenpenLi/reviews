local Bullet =
    class(
    "Bullet",
    function(file)
        local sprite = display.newSprite(file)
        return sprite
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function Bullet:ctor()
    self:enableNodeEvents()
    self.isRemove = false
    self.isDead = false
    self.speed = 0
    self.radius = 0
    self.angle = 0
    self.chairId = -1
    self.bulletIndex = 0
    self.bulletScore = 0
    self.isRebound = true
    self.lockingTarget = 0xFFFFFFFF
end
function Bullet:onEnter()
end
function Bullet:setBulletScore(bulletScore)
    self.bulletScore = bulletScore
end
function Bullet:setIndex(bulletIndex)
    self.bulletIndex = bulletIndex
end
function Bullet:setChairId(chairId)
    self.chairId = chairId
end
function Bullet:setSpeed(speed)
    self.speed = speed
end
function Bullet:setRadius(radius)
    self.radius = radius
end
function Bullet:setAngle(angle)
    self.angle = angle
end
function Bullet:setLockingTarget(lockingTarget)
    self.lockingTarget = lockingTarget
end
function Bullet:clampAngle(angle, chairId)
    if chairId < 2 then
        if angle < 0 and angle < -math.pi * 0.5 then
            angle = math.pi
            return angle, true
        elseif angle < 0 and angle >= -math.pi * 0.5 then
            angle = 0
            return angle, true
        end
        return angle, false
    else
        if angle > 0 and angle > math.pi * 0.5 then
            angle = math.pi
            return angle, true
        elseif angle > 0 and angle <= math.pi * 0.5 then
            angle = math.pi * 2
            return angle, true
        end
        return angle, false
    end
end
function Bullet:update(dt)
    local oldPos = self:getPosition3D()
    if
        oldPos.y < -self.radius or oldPos.y > display.height + self.radius or oldPos.x < -self.radius or
            oldPos.x > display.width + self.radius
     then
        self.isRemove = true
    end
    if self.isRemove then
        return
    end
    local scale = 1.0
    local setAngle = 0
    local speedDt = self.speed * dt * scale
    if self.lockingTarget ~= 0xFFFFFFFF then
        local fishLock = self:getParent():getFishByFishId(self.lockingTarget)
        if not tolua.isnull(fishLock) and not fishLock.isDead and fishLock.hp > 0 then
            local pos3D = fishLock:getPosition3D()
            local lockPos = self:getParent().scene._camera:projectGL(pos3D)
            local getAngle, isOut =
                self:clampAngle(math.atan2(lockPos.y - oldPos.y, lockPos.x - oldPos.x), self.chairId)
            if isOut then
                self.isRemove = true
                return
            end
            setAngle = 90 - getAngle * 57.29578
            self:setRotation(setAngle)
            local angleRota = (90 - setAngle) * 0.01745
            local posX = oldPos.x + speedDt * math.cos(angleRota)
            local posY = oldPos.y + speedDt * math.sin(angleRota)
            local newPos = cc.vec3(posX, posY, 0)
            self:setPosition3D(newPos)
        else
            self.lockingTarget = 0xFFFFFFFF
        end
        return
    end
    local angleRota = self.angle * 0.01745
    local posX = oldPos.x + speedDt * math.cos(angleRota)
    local posY = oldPos.y + speedDt * math.sin(angleRota)
    if self.isRebound then
        if posY <= 0 or posY >= display.height then
            self.angle = -self.angle
            angleRota = self.angle * 0.01745
            posX = oldPos.x + speedDt * math.cos(angleRota)
            posY = oldPos.y + speedDt * math.sin(angleRota)
        elseif posX <= 0 or posX >= display.width then
            self.angle = 180 - self.angle
            angleRota = self.angle * 0.01745
            posX = oldPos.x + speedDt * math.cos(angleRota)
            posY = oldPos.y + speedDt * math.sin(angleRota)
        end
    end
    local newPos = cc.vec3(posX, posY, 0)
    self:setPosition3D(newPos)
    self:setRotation(90 - self.angle)
end
return Bullet
