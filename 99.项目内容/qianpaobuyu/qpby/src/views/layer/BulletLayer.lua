local BulletLayer =
    class(
    "BulletLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local Bullet = appdf.req(module_pre .. ".views.layer.Bullet")
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
function BulletLayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self.m_pUserItem = self.scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem.wTableID
    self.m_nChairID = self.m_pUserItem.wChairID
    self.m_dwUserID = self.m_pUserItem.dwUserID
    self.bulletList = {}
    self.isDead = false
    self.m_index = 0
end
function BulletLayer:getFishByFishId(fishId)
    local fish = self.scene.fishLayer:getFishByFishId(fishId)
    return fish
end
function BulletLayer:onEnter()
end
function BulletLayer:onCleanup()
end
function BulletLayer:createBullet(angle, cannonPos, chairId, bulletScore, bulletLockTarget)
    local pos = cc.vec3(cannonPos.x, cannonPos.y, 0)
    local bulletSpeed = 1200.0
    local radius = 40
    if self.m_nChairID == chairId then
        self.m_index = self.m_index + 1
        local bulletIndex = self.m_index
        local cannonType = 1
        local isSelf = 1
        local fishIndex = tonumber(bulletLockTarget) or Game_CMD.INT_MAX
        local cmddata = CCmd_Data:create(29)
        cmddata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_FIRE)
        cmddata:pushint(bulletIndex)
        cmddata:pushint(cannonType)
        cmddata:pushbyte(isSelf)
        cmddata:pushfloat(angle)
        cmddata:pushint(bulletScore)
        cmddata:pushint(fishIndex)
        cmddata:pushdword(currentTime())
        cmddata:pushfloat(bulletSpeed)
        if not self.scene._gameFrame or not self.scene._gameFrame:sendSocketData(cmddata) then
            self.m_index = self.m_index - 1
            self.scene._gameFrame._callBack(-1, "发送开火息失败")
            return false
        else
            self:bulletShoot(bulletIndex, chairId, pos, angle, bulletSpeed, radius, bulletScore, bulletLockTarget)
            return true
        end
    else
        self:bulletShoot(bulletIndex, chairId, pos, angle, bulletSpeed, radius, bulletScore, bulletLockTarget)
        return true
    end
end
function BulletLayer:bulletShoot(bulletIndex, chairId, pos, angle, speed, radius, score, bulletLockTarget)
    local index = 0
    local bulletFile = string.format("animationex/bullet%s/bullet%s_other.png", index, index)
    local bullet = Bullet:create(bulletFile):setPosition3D(pos):addTo(self)
    bullet:setChairId(chairId)
    bullet:setAngle(90 - angle)
    bullet:setSpeed(speed)
    bullet:setRadius(radius)
    bullet:setIndex(bulletIndex)
    bullet:setBulletScore(score)
    bullet:setLockingTarget(bulletLockTarget or 0xFFFFFFFF)
    table.insert(self.bulletList, bullet)
    ExternalFun.playSoundEffectCommon("sound/effect/Fire.mp3")
end
function BulletLayer:getBulletList()
    return self.bulletList
end
return BulletLayer
