local CannonLayer =
    class(
    "CannonLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local Cannon = appdf.req(module_pre .. ".views.layer.Cannon")
function CannonLayer:ctor(scene)
    self.scene = scene
    self._gameFrame = self.scene._gameFrame
    self:enableNodeEvents()
    self:setTouchEnabled(true)
    self.maxPlayer = self.scene.maxPlayer
    self.cannonList = {}
    self.myCannon = nil
    self.isCanTouch = true
    self:registerTouch()
    self.m_pUserItem = self.scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem.wTableID
    self.m_nChairID = self.m_pUserItem.wChairID
    self.m_dwUserID = self.m_pUserItem.dwUserID
    self.minScore = 0
    self:initCannon()
end
function CannonLayer:setCanTouch(canTouch)
    self.isCanTouch = canTouch
end
function CannonLayer:setMinScore(score)
    self.minScore = score
    self:refreshCannon()
end
function CannonLayer:registerTouch()
    self:registerScriptTouchHandler(
        function(event, x, y)
            if not self.isCanTouch then
                return true
            end
            if event == "ended" then
                if not self.myCannon.isAutoFire then
                    self.myCannon:setFire(false)
                end
            elseif event == "moved" then
                if self.myCannon.lockingTarget == 0xFFFFFFFF then
                    self:changeFirePos(x, y)
                end
            elseif event == "began" then
                if self.myCannon.lockingTarget == 0xFFFFFFFF then
                    self:changeFirePos(x, y)
                end
                self.myCannon:setFire(true)
            end
            return true
        end,
        false,
        2
    )
end
function CannonLayer:setAutoFire(isAuto)
    if not tolua.isnull(self.myCannon) then
        self.myCannon.isAutoFire = isAuto
        self.myCannon:setFire(isAuto)
    end
end
function CannonLayer:onEnter()
    self._gameFrame:QueryUserInfo(self.m_nTableID, yl.INVALID_CHAIR)
end
function CannonLayer:changeFirePos(x, y)
    local cannonPos = self.myCannon:getWorldPos()
    local angle = self:clampAngle(math.atan2(y - cannonPos.y, x - cannonPos.x), self.m_nChairID)
    self.myCannon.cannonPosition:setRotation(90 - angle * 57.29578)
end
function CannonLayer:setAngle(chairId, angle)
    local cannon = self:getCannonByChairId(chairId)
    if not tolua.isnull(cannon) then
        cannon:setRotation(angle)
    end
end
function CannonLayer:othershoot(fire)
    local chairId = fire.chair_id
    local cannon = self:getCannonByChairId(chairId)
    if not tolua.isnull(cannon) then
        if fire.lock_fishid ~= 0 then
            cannon.lockingTarget = fire.lock_fishid
        else
            cannon.lockingTarget = 0xFFFFFFFF
            cannon.cannonPosition:setRotation(fire.angle)
            cannon.cannonPosition:setRotation(fire.angle)
        end
        cannon:setBulletScore(fire.bullet_mulriple)
        cannon:onFire()
        self:sendOnFire(cannon)
        cannon:addScore(fire.fish_score)
    end
end
function CannonLayer:clampAngle(angle, chairId)
    if chairId < 2 then
        if angle < 0 and angle < -math.pi / 2 then
            angle = math.pi
            return angle, true
        elseif angle < 0 and angle >= -math.pi / 2 then
            angle = 0
            return angle, true
        end
        return angle, false
    else
        if angle > 0 and angle > math.pi / 2 then
            angle = math.pi
            return angle, true
        elseif angle > 0 and angle <= math.pi / 2 then
            angle = math.pi * 2
            return angle, true
        end
        return angle, false
    end
end
function CannonLayer:setCannonWaittingByChairId(chairId, isWait)
    local cannon = self:getCannonByChairId(chairId)
    if not tolua.isnull(cannon) then
        cannon:setWaitting(isWait)
    end
end
function CannonLayer:getCannonByChairId(chairId)
    for i = 1, #self.cannonList do
        local cannon = self.cannonList[i]
        local cannonChairId = cannon:getTag() - 1000
        if not tolua.isnull(cannon) then
            if chairId == cannonChairId then
                return cannon
            end
        end
    end
    return nil
end
function CannonLayer:getCannonByUserID(userID)
    for i = 1, #self.cannonList do
        local cannon = self.cannonList[i]
        local cannonChairId = cannon:getTag() - 1000
        if not tolua.isnull(cannon) then
            if userID == cannon.userId then
                return cannon
            end
        end
    end
    return nil
end
function CannonLayer:refreshCannon(chairId)
    local refreshChairId = chairId or -1
    for i = 1, #self.cannonList do
        local cannon = self.cannonList[i]
        if not tolua.isnull(cannon) then
            local cannonChairId = cannon:getTag() - 1000
            if refreshChairId == -1 then
                cannon:refresh()
            else
                if refreshChairId == cannonChairId then
                    cannon:refresh()
                    break
                end
            end
        end
    end
end
function CannonLayer:initCannon()
    local posTable = {
        cc.p(display.width * 0.3, 0),
        cc.p(display.width * 0.7, 0),
        cc.p(display.width * 0.7, display.height),
        cc.p(display.width * 0.3, display.height)
    }
    for i = 1, self.maxPlayer do
        local pos = posTable[i]
        local chariId = i - 1
        local cannon = Cannon:create(chariId):setPosition(pos):addTo(self):setTag(1000 + chariId)
        if chariId == self.m_nChairID then
            self.myCannon = cannon
        end
        table.insert(self.cannonList, cannon)
    end
    self.myCannon:showCannon(self.m_pUserItem, true)
end
function CannonLayer:onEventUserEnter(wTableID, wChairID, useritem)
    local cannon = self:getCannonByChairId(wChairID)
    cannon:showCannon(useritem, false)
end
function CannonLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    if oldstatus.cbUserStatus == yl.US_FREE then
        if newstatus.wTableID ~= self.m_nTableID then
            return
        end
    end
    if newstatus.cbUserStatus == yl.US_FREE or newstatus.cbUserStatus == yl.US_NULL then
        local cannon = self:getCannonByUserID(useritem.dwUserID)
        if not tolua.isnull(cannon) then
            cannon:resetCannon()
        end
    else
        self._gameFrame:QueryUserInfo(self.m_nTableID, useritem.wChairID)
    end
end
function CannonLayer:sendOnFire(cannon)
    local angle = cannon.cannonPosition:getRotation()
    local cannonPos = cannon:getWorldPos()
    local chairId = cannon.chairId
    local bulletScore = cannon.bulletScore
    local bulletLockTarget = cannon.lockingTarget
    self.scene.gameController:createBullet(angle, cannonPos, chairId, bulletScore, bulletLockTarget)
end
function CannonLayer:setFireSpeed(speed)
    if not tolua.isnull(self.myCannon) then
        self.myCannon:setFireSpeed(speed)
    end
end
function CannonLayer:update(dt)
    for i = 1, #self.cannonList do
        local cannon = self.cannonList[i]
        if not tolua.isnull(cannon) and cannon.lockingTarget ~= 0xFFFFFFFF then
            local fishLock = self.scene.fishLayer:getFishByFishId(cannon.lockingTarget)
            local setAngle = 0
            if not tolua.isnull(fishLock) then
                local pos3D = fishLock:getPosition3D()
                local lockPos = self.scene._camera:projectGL(pos3D)
                local cannonPosX, cannonPosY = cannon.cannonPosition:getPosition()
                local oldPos = cannon.cannonPosition:getParent():convertToWorldSpace(cc.p(cannonPosX, cannonPosY))
                setAngle = self:clampAngle(math.atan2(lockPos.y - oldPos.y, lockPos.x - oldPos.x), cannon.chairId)
                setAngle = 90 - setAngle * 57.29578
                cannon.cannonPosition:setRotation(setAngle)
            else
                cannon.lockingTarget = 0xFFFFFFFF
            end
        end
    end
    local cannon = self.myCannon
    if not cannon.isFire then
        cannon.delayTime = 0
        return
    end
    if cannon.delayTime == 0 then
        cannon:onFire()
        self:sendOnFire(cannon)
    end
    cannon.delayTime = cannon.delayTime + dt
    if cannon.delayTime > cannon.waitTime then
        cannon.delayTime = 0
    end
end
function CannonLayer:setMyCannonLockFish(lockingTarget)
    self.myCannon:setLockingTarget(lockingTarget)
end
function CannonLayer:setCannonLockByChairId(chairId, lockingTarget)
    for i = 1, #self.cannonList do
        local cannon = self.cannonList[i]
        local cannonChairId = cannon:getTag() - 1000
        if not tolua.isnull(cannon) then
            if chairId == cannonChairId then
                cannon:setLockingTarget(lockingTarget)
                break
            end
        end
    end
end
return CannonLayer
