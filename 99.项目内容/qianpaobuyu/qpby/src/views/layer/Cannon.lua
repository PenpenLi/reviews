local Cannon = class("Cannon", cc.Node)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function Cannon:ctor(chairId)
    self:enableNodeEvents()
    self.chairId = chairId
    self.isSelf = false
    self.isFire = false
    self.isAutoFire = false
    self.delayTime = 0
    self.waitTime = 0.3
    self.isWait = false
    self.score = 0
    self.userId = 0
    self.nickName = ""
    self.multiple = 1
    self.minScore = 0
    self.bulletScore = 0
    self.fireSpeed = 1
    self.lockingTarget = 0xFFFFFFFF
    self.cannonWorldPos = cc.p(0, 0)
    self:initUI()
end
function Cannon:getWorldPos()
    return self.cannonWorldPos
end
function Cannon:setWorldPos(pos)
    local pos = self:convertToWorldSpace(pos)
    self.cannonWorldPos = pos
end
function Cannon:onEnter()
end
function Cannon:refresh()
    self:refreshScore()
    self:updateBulletScore()
end
function Cannon:setFireSpeed(speed)
    self.fireSpeed = speed
    self.waitTime = self:getFrequency()
end
function Cannon:setLockingTarget(lockingTarget)
    self.lockingTarget = lockingTarget
end
function Cannon:getFrequency()
    if self.fireSpeed == 1 then
        return 0.3
    elseif self.fireSpeed == 2 then
        return 0.2
    else
        return 0.1
    end
    return 0.3
end
function Cannon:initUI()
    local rotate = 0
    local cannonPos = cc.p(0, 29)
    local infoPos = cc.p(-265 + 40, 45)
    local textPos = cc.p(0, 116)
    local minusPos = cc.p(-95, 45.5)
    local plusPos = cc.p(95, 45.5)
    if self.chairId > 1 then
        rotate = 180
        textPos.y = -textPos.y
    end
    self.bg =
        display.newSprite("ui/cannon/paotaidi.png"):setAnchorPoint(0.5, 0):setPosition(0, 0):addTo(self):setScale(0.85):setRotation(
        rotate
    )
    self.textWaiting =
        ccui.Text:create():setString("等待玩家进入"):setFontSize(23):setTextColor(cc.c3b(154, 206, 225)):setPosition(textPos):addTo(
        self
    ):enableShadow(cc.c3b(0, 0, 0), cc.size(2, -2))
    self.cannonPosition = cc.Node:create():setPosition(cannonPos):addTo(self):setScale(0.85):setRotation(rotate)
    self:setWorldPos(cannonPos)
    local jsonName = string.format("fish_effect/3dby_paotai%s.json", 1)
    local atlasName = string.format("fish_effect/3dby_paotai%s.atlas", 1)
    self.barrelAction =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(0, 35):addTo(self.cannonPosition):setAnimation(
        0,
        "animation",
        false
    ):setTimeScale(100.0)
    self.minusBtn = ccui.Button:create("ui/cannon/jianhao.png"):setPosition(minusPos):addTo(self):setScale(0.85)
    self.minusBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:minusMultiple()
            end
        end
    )
    self.plusBtn = ccui.Button:create("ui/cannon/jiahao.png"):setPosition(plusPos):addTo(self):setScale(0.85)
    self.plusBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:plusMultiple()
            end
        end
    )
    self.personalInfo =
        ccui.Layout:create():setContentSize(250, 80):setPosition(infoPos):setAnchorPoint(0.5, 0.5):addTo(self):setScale(
        0.85
    )
    local imgBackground =
        ccui.ImageView:create("ui/cannon/Gold_bg.png"):ignoreContentAdaptWithSize(false):setScale9Enabled(true):setCapInsets(
        cc.rect(25, 0, 133 - 50, 46)
    ):setContentSize(230, 55):setPosition(121, 12):addTo(self.personalInfo)
    self.imgCoin = display.newSprite("ui/cannon/ico_Gold.png"):setPosition(35, 22):addTo(self.personalInfo)
    self.textPlayerName =
        ccui.Text:create():setFontSize(27):setTextColor(cc.c3b(154, 206, 225)):setAnchorPoint(0, 0.5):setPosition(
        17.5,
        65
    ):addTo(self.personalInfo):enableShadow(cc.c3b(0, 0, 0), cc.size(2, -2))
    self.textScore =
        ccui.TextAtlas:create("0", "ui/cannon/gold_number_collect.png", 16, 28, "0"):setAnchorPoint(0.0, 0.5):setPosition(
        58,
        20
    ):addTo(self.personalInfo)
    self.scoreBg =
        display.newSprite("ui/cannon/cannon_txt_panel.png"):setPosition(0, 16):addTo(self):setScaleY(1.15):setScaleX(
        0.9
    )
    local score = self.bulletScore
    if score >= 10000 then
        score = math.ceil(score / 10000)
        score = string.format("%s:", score)
    end
    self.userScore =
        ccui.TextAtlas:create(score, "ui/cannon/qpbynumber.png", 26, 46, "0"):setPosition(0, 18):addTo(self):setScale(
        0.8
    )
    self.cannonPosition:hide()
    self.personalInfo:hide()
    self.scoreBg:hide()
    self.userScore:hide()
    self.minusBtn:hide()
    self.plusBtn:hide()
end
function Cannon:resetCannon()
    self.chairId = -1
    self.isSelf = false
    self.score = 0
    self.userId = 0
    self.nickName = ""
    self.cannonPosition:hide()
    self.personalInfo:hide()
    self.scoreBg:hide()
    self.userScore:hide()
    self.minusBtn:hide()
    self.plusBtn:hide()
    self.textWaiting:show()
end
function Cannon:setBulletScore(score)
    self.bulletScore = score
    if score >= 10000 then
        score = math.ceil(score / 10000)
        score = string.format("%s:", score)
    end
    self.userScore:setString(score)
end
function Cannon:plusMultiple()
    self.minScore = self:getParent().minScore
    self.multiple = self.multiple + 1
    if self.multiple > 10 then
        self.multiple = 1
    end
    local score = self.multiple * self.minScore
    self:updateBulletScore(score)
end
function Cannon:minusMultiple()
    self.minScore = self:getParent().minScore
    self.multiple = self.multiple - 1
    if self.multiple < 1 then
        self.multiple = 10
    end
    local score = self.multiple * self.minScore
    self:updateBulletScore(score)
end
function Cannon:updateBulletScore()
    self.minScore = self:getParent().minScore
    self.bulletScore = self.minScore * self.multiple
    local score = self.bulletScore
    if score >= 10000 then
        score = math.ceil(score / 10000)
        score = string.format("%s:", score)
    end
    self.userScore:setString(score)
end
function Cannon:updateScore(score)
    self.score = score
    self:refreshScore()
end
function Cannon:addScore(score)
    self.score = self.score + score
    self:refreshScore()
end
function Cannon:setFire(isFire)
    self.isFire = isFire
end
function Cannon:setWaitting(isWait)
    self.isWait = isWait
end
function Cannon:onFire()
    if self.delayTime > 0 and self.delayTime < self.waitTime then
        return false
    end
    self.barrelAction:setAnimation(0, "animation", false)
    self.barrelAction:setTimeScale(1.0)
    return true
end
function Cannon:refreshScore()
    local str = string.formatNumberThousands(self.score, true, ":")
    self.textScore:setString(str)
end
function Cannon:refreshNickname()
    self.textPlayerName:setString(self.nickName)
end
function Cannon:getCoinPosToWord()
    local imgPosX, imgPosY = self.imgCoin:getPosition()
    local imgPos = self.imgCoin:getParent():convertToWorldSpace(cc.p(imgPosX, imgPosY))
    return imgPos
end
function Cannon:showCannon(userItem, isSelf)
    self.chairId = userItem.wChairID
    self.isSelf = isSelf
    self.score = userItem.lScore
    self.userId = userItem.dwUserID
    self.nickName = userItem.szNickName
    local rotate = 0
    local cannonPos = cc.p(0, 29)
    local infoPos = cc.p(-265 + 40, 45)
    local textPos = cc.p(0, 116)
    local minusPos = cc.p(-95, 45.5)
    local plusPos = cc.p(95, 45.5)
    if self.chairId == 0 then
        rotate = 0
        infoPos = cc.p(-265 + 40, 45)
        if not self.isSelf then
            infoPos = cc.p(-200 + 20, 45)
        end
    elseif self.chairId == 1 then
        rotate = 0
        infoPos = cc.p(265 - 40, 45)
        if not self.isSelf then
            infoPos = cc.p(200 - 20, 45)
        end
    elseif self.chairId == 2 then
        rotate = 180
        infoPos = cc.p(265 - 40, -45)
        if not self.isSelf then
            infoPos = cc.p(200 - 20, -45)
        end
        cannonPos.y = -cannonPos.y
        textPos.y = -textPos.y
        minusPos.y = -minusPos.y
        plusPos.y = -plusPos.y
    elseif self.chairId == 3 then
        rotate = 180
        infoPos = cc.p(-260 + 40, -45)
        if not self.isSelf then
            infoPos = cc.p(-206 + 20, -45)
        end
        cannonPos.y = -cannonPos.y
        textPos.y = -textPos.y
        minusPos.y = -minusPos.y
        plusPos.y = -plusPos.y
    end
    self.bg:setRotation(rotate)
    self.cannonPosition:setPosition(cannonPos)
    self.cannonPosition:setRotation(rotate)
    self.personalInfo:setPosition(infoPos)
    self.textWaiting:setPosition(textPos)
    self.minusBtn:setPosition(minusPos)
    self.plusBtn:setPosition(plusPos)
    self:setWorldPos(cannonPos)
    self.cannonPosition:show()
    self.personalInfo:show()
    self.scoreBg:show()
    self.userScore:show()
    self.minusBtn:setVisible(self.isSelf)
    self.plusBtn:setVisible(self.isSelf)
    self.textWaiting:hide()
    self:refreshScore()
    self:refreshNickname()
    self:updateBulletScore()
end
return Cannon
