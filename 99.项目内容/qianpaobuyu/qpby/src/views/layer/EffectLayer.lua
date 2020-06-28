local EffectLayer =
    class(
    "EffectLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local FishVisual = appdf.req(module_pre .. ".views.layer.FishVisual")
local TexturedNumber = appdf.req(module_pre .. ".models.TexturedNumber")
function EffectLayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self._shakeScreen = nil
    self.SpeedScale = {[0] = 0.35, [1] = 0.65, [2] = 0.75, [3] = 0.9, [4] = 1.1, [5] = 1.2, [6] = 1.4}
    if device.platform ~= "android" then
        self.CoinNumber = {[0] = 4, [1] = 6, [2] = 12, [3] = 25, [4] = 45, [5] = 85, [6] = 100}
    else
        self.CoinNumber = {[0] = 3, [1] = 3, [2] = 6, [3] = 12, [4] = 24, [5] = 32, [6] = 50}
    end
    self.positionZero = {x = 0, y = 0}
    self.freeAnimationNodes = {
        [0] = {number = 0, maxNumber = 50},
        [1] = {number = 0, maxNumber = 5},
        [2] = {number = 0, maxNumber = 5},
        [3] = {number = 0, maxNumber = 5},
        [4] = {number = 0, maxNumber = 3},
        [5] = {number = 0, maxNumber = 1},
        [6] = {number = 0, maxNumber = 1}
    }
    self.usedAnimationNodes = {}
    self.coinPos = {
        [0] = cc.p(display.cx, display.cy),
        [1] = cc.p(display.cx, display.cy),
        [2] = cc.p(display.cx, display.cy),
        [3] = cc.p(display.cx, display.cy)
    }
    self.coinEffect = {}
    for i = 0, 3 do
        local spine = self:getSpineByName("jinbishounaeffect")
        spine:setPosition(self.coinPos[i])
        spine:setAnimation(0, "animation", false)
        spine:hide()
        spine:setScale(0.9)
        spine:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(
                    function()
                        spine:show()
                    end
                )
            )
        )
        self:addChild(spine, 3)
        self.coinEffect[i] = spine
    end
    self.coinParticle = {}
    for i = 0, 3 do
        local particle = cc.ParticleSystemQuad:create("particle/paotaijinbilizi.plist")
        particle:setPosition(self.coinPos[i])
        particle:resetSystem()
        particle:setScale(0.1)
        particle:setVisible(false)
        particle:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(
                    function()
                        particle:setVisible(true)
                    end
                )
            )
        )
        self:addChild(particle, 4)
        self.coinParticle[i] = particle
    end
    self.m_pUserItem = self.scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem.wTableID
    self.m_nChairID = self.m_pUserItem.wChairID
    self.m_dwUserID = self.m_pUserItem.dwUserID
    self._lockFishChain = {}
end
function EffectLayer:onEnter()
end
function EffectLayer:blackholeFishEffect(catchFish, deadFishIdList, deadFishCount, chairID, totalScore)
    local fishCmd = {fish_kind = 1 - 1, cmd_version = 0, fish_id = 12232133}
    local fish = self.scene.fishLayer:createTestFish(fishCmd)
    fish:setPosition3D(cc.vec3(display.cx, display.cy, -500))
    fish:show()
    local circle = CirCleBy:create(5, cc.p(display.cx, display.cy), 100)
    local autoMoveBy = MoveBy:create(5, cc.p(display.cx + 500, display.cy))
    if true then
        return
    end
    local catchFishPos3D = catchFish:getPosition3D()
    local centerPosition = self.scene._camera:projectGL(catchFishPos3D)
    local index = 1
    local maxDistance = -9999999
    while index <= #deadFishIdList and deadFishIdList[index] > 0 do
        local fish = self._world:retrieveEntity("fish", message.fishes[index])
        if fish then
            local fishPosition = fish:getValue("position")
            fishPosition = gameConfig:mirrorPosition(fishPosition, fish._mirrorPosition)
            local distance = Tools:distance3D(fishPosition, gravityCenter)
            fish.distanceToGravityCenter = distance > 200 and distance or 200
            fish.startPosition = fishPosition
            if distance > maxDistance then
                maxDistance = distance
            end
        end
        index = index + 1
    end
    for index = 1, 100 do
        if message.fishes[index] > 0 then
            local fish = self._world:retrieveEntity("fish", message.fishes[index])
            if fish then
                local visualNode = fish:getComponentByName("visual")._visualNode
                local function delayCall(node)
                    fish:setValue("deadCause", "EFFECT_KILL_FINISH")
                    fish:trigger("isDead", true)
                end
                local duration = (3.5 - math.random() * 1) * fish.distanceToGravityCenter / maxDistance
                local w = (math.pi - math.random() * 2.5) * 0.7
                local startDelay = 1.0 * math.random() + 0.2
                local deadTrigger =
                    cc.CallFunc:create(
                    function()
                        fish:setValue("deadCause", "EFFECT_HOLD")
                        fish:trigger("isDead", true)
                        local fishPosition = fish:getValue("position")
                        fishPosition = gameConfig:mirrorPosition(fishPosition, fish._mirrorPosition)
                        local action =
                            custom.ActionVortex:create(
                            duration,
                            w,
                            -1,
                            fishPosition,
                            gravityCenter,
                            200 * math.random()
                        )
                        visualNode:runAction(cc.EaseSineIn:create(action))
                    end
                )
                visualNode:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(startDelay),
                        deadTrigger,
                        cc.Sequence:create(
                            cc.DelayTime:create(duration * 0.2),
                            cc.EaseExponentialIn:create(cc.FadeTo:create(duration * 0.8, 10))
                        ),
                        cc.CallFunc:create(delayCall)
                    )
                )
            end
        else
            break
        end
    end
    casterFish:setValue("deadCause", "EFFECT_KILL_FINISH")
    casterFish:trigger("isDead", true)
    local skeleton = sp.SkeletonAnimation:create("fish_effect/heidongyu.json", "fish_effect/heidongyu.atlas", 0.7)
    skeleton:setPosition(centerPosition.x, centerPosition.y)
    skeleton:setAnimation(0, "start", false)
    skeleton:addAnimation(0, "idle2", false)
    skeleton:addAnimation(0, "idle2", false)
    skeleton:addAnimation(0, "end", false)
    skeleton:setScale(1.15)
    skeleton:setGlobalZOrder(-50)
    self:addChild(skeleton, 101)
    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(4),
            cc.CallFunc:create(
                function()
                    ExternalFun.playSoundEffectCommon("sound/effect/Bigfireworks.mp3")
                end
            )
        )
    )
    skeleton:runAction(cc.Sequence:create(cc.DelayTime:create(8), cc.RemoveSelf:create()))
    local function killFishGold()
        local effectLevel = gameConfig.FishVisuals[casterFish:getValue("visualId")].effectLevel
        self:ShowFishGoldEx(centerPosition, message.wChairID, totalScore, message.nBScoe, 6)
    end
    effectLayer:runAction(cc.Sequence:create(cc.DelayTime:create(5.0), cc.CallFunc:create(killFishGold)))
    local shakeStart = {
        cc.MoveBy:create(0.066, cc.p(-0.5, 0.5)),
        cc.MoveBy:create(0.066, cc.p(0, -1)),
        cc.MoveBy:create(0.066, cc.p(1.5, 1)),
        cc.MoveBy:create(0.066, cc.p(-3, -2.5)),
        cc.MoveBy:create(0.066, cc.p(2, 2))
    }
    local shakeIdle = {
        cc.MoveBy:create(0.066, cc.p(-2, 2)),
        cc.MoveBy:create(0.066, cc.p(0, -4)),
        cc.MoveBy:create(0.066, cc.p(4, 2)),
        cc.MoveBy:create(0.066, cc.p(-2, -2)),
        cc.MoveBy:create(0.066, cc.p(0, 2))
    }
    local shakeEnd = {
        cc.MoveBy:create(0.066, cc.p(-2, 2)),
        cc.MoveBy:create(0.066, cc.p(0, -4)),
        cc.MoveBy:create(0.066, cc.p(5, 5)),
        cc.MoveBy:create(0.066, cc.p(-8, -6)),
        cc.MoveBy:create(0.066, cc.p(10, 5)),
        cc.MoveBy:create(0.066, cc.p(-9, -7)),
        cc.MoveBy:create(0.066, cc.p(10, 11)),
        cc.MoveBy:create(0.066, cc.p(-16, 5)),
        cc.MoveBy:create(0.066, cc.p(2, -11)),
        cc.MoveBy:create(0.066, cc.p(8, 0))
    }
    cc.Director:getInstance():getRunningScene():runAction(
        cc.Sequence:create(
            cc.Sequence:create(shakeStart),
            cc.Repeat:create(cc.Sequence:create(shakeIdle), 13),
            cc.Sequence:create(shakeEnd)
        )
    )
    ExternalFun.playSoundEffectCommon("sound/effect/sfx_blackhole.mp3")
end
function EffectLayer:lightningFishEffect(catchFish, deadFishIdList, deadFishCount, chairID, score)
    local catchFishPos3D = catchFish:getPosition3D()
    local centerPosition = self.scene._camera:projectGL(catchFishPos3D)
    local index = 1
    local action = 0
    if not tolua.isnull(catchFish) then
        catchFish.isStop = true
        local fishCount = deadFishCount
        if catchFish.killAction then
            self:stopAction(catchFish.killAction)
        end
        catchFish.killAction =
            cc.Sequence:create(
            cc.DelayTime:create((40 + fishCount) * 0.033),
            cc.CallFunc:create(
                function()
                    local cannon = self.scene.cannonLayer:getCannonByChairId(chairID)
                    if not tolua.isnull(cannon) then
                        local coinPos = cannon:getCoinPosToWord()
                        self:ShowFishGoldEx(centerPosition, coinPos, chairID, score, 1)
                    end
                    catchFish.killAction = nil
                    catchFish.hp = 0
                end
            )
        )
        self:runAction(catchFish.killAction)
        ExternalFun.playSoundEffectCommon("sound/effect/sfx_thunder_fever.mp3")
    end
    action =
        cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(
                function()
                    local currentIndex = index
                    if deadFishIdList[currentIndex] > 0 then
                        local deadFish = self.scene.fishLayer:getFishByFishId(deadFishIdList[currentIndex])
                        if not tolua.isnull(deadFish) and deadFish.fishId ~= catchFish.fishId then
                            local fishPos3D = deadFish:getPosition3D()
                            fishPosition = self.scene._camera:projectGL(fishPos3D)
                            deadFish.isStop = true
                            local distanceToCenter = cc.pGetDistance(fishPosition, centerPosition) + 30
                            local rotation =
                                math.atan2(fishPosition.x - centerPosition.x, fishPosition.y - centerPosition.y)
                            local lineAnimation =
                                sp.SkeletonAnimation:create(
                                "fish_effect/shandianyushandian.json",
                                "fish_effect/shandianyushandian.atlas"
                            )
                            lineAnimation:setPosition(
                                (fishPosition.x + centerPosition.x) / 2,
                                (fishPosition.y + centerPosition.y) / 2
                            )
                            lineAnimation:setAnimation(0, "start", false)
                            lineAnimation:addAnimation(0, "idle", false)
                            lineAnimation:addAnimation(0, "end", false)
                            lineAnimation:setScaleX(distanceToCenter / 720)
                            lineAnimation:setRotation(rotation * 180 / math.pi - 90)
                            self:addChild(lineAnimation, 103)
                            lineAnimation:runAction(
                                cc.Sequence:create(cc.DelayTime:create(45 * 0.033), cc.RemoveSelf:create())
                            )
                            local targetAnimation =
                                sp.SkeletonAnimation:create(
                                "fish_effect/shandianyudianqiu.json",
                                "fish_effect/shandianyudianqiu.atlas"
                            )
                            targetAnimation:setPosition(fishPosition)
                            targetAnimation:setAnimation(0, "start", false)
                            targetAnimation:addAnimation(0, "idle", false)
                            targetAnimation:addAnimation(0, "end", false)
                            targetAnimation:setAnchorPoint(0.0, 0.0)
                            targetAnimation:setScale(0.5)
                            self:addChild(targetAnimation, 104)
                            targetAnimation:runAction(
                                cc.Sequence:create(cc.DelayTime:create(45 * 0.033), cc.RemoveSelf:create())
                            )
                            local function killFishGold()
                                deadFish.hp = 0
                            end
                            self:runAction(
                                cc.Sequence:create(cc.DelayTime:create(40 * 0.033), cc.CallFunc:create(killFishGold))
                            )
                            ExternalFun.playSoundEffectCommon("sound/effect/electric.mp3")
                        end
                        index = index + 1
                    else
                        self:stopAction(action)
                    end
                end
            ),
            cc.DelayTime:create(0.033)
        )
    )
    self:runAction(action)
end
function EffectLayer:displayFrozenEffect(catchFish)
    local parentNode = self
    local delayTime = 15
    local catchFishPos3D = catchFish:getPosition3D()
    local casterPosition = self.scene._camera:projectGL(catchFishPos3D)
    local startDuration = 46 * 0.033
    local idleDuration = 72 * 0.033
    local endDuration = 73 * 0.033
    local idlePlayTimes = (delayTime - startDuration - endDuration) / idleDuration + 1
    local recycleDelay = startDuration + idleDuration * idlePlayTimes + endDuration
    local frozenFullScreen =
        sp.SkeletonAnimation:create("fish_effect/bingdongyupmeffect.json", "fish_effect/bingdongyupmeffect.atlas")
    frozenFullScreen:setAnimation(0, "start", false)
    frozenFullScreen:setScale(display.width / 1336)
    for i = 1, idlePlayTimes do
        frozenFullScreen:addAnimation(0, "idle", false)
    end
    frozenFullScreen:addAnimation(0, "end", false)
    frozenFullScreen:setMix("idle", "end", 0.8)
    frozenFullScreen:setPosition(display.cx, display.cy)
    frozenFullScreen:runAction(cc.Sequence:create(cc.DelayTime:create(recycleDelay), cc.RemoveSelf:create()))
    parentNode:addChild(frozenFullScreen, 101)
    local frozenParticle =
        sp.SkeletonAnimation:create("fish_effect/bingdongyueffect.json", "fish_effect/bingdongyueffect.atlas")
    frozenParticle:setAnimation(0, "start", false)
    for i = 1, idlePlayTimes do
        frozenParticle:addAnimation(0, "idle", false)
    end
    frozenParticle:addAnimation(0, "end", false)
    frozenParticle:setMix("idle", "end", 0.8)
    frozenParticle:setPosition(display.cx, display.cy)
    frozenParticle:runAction(cc.Sequence:create(cc.DelayTime:create(recycleDelay), cc.RemoveSelf:create()))
    if casterPosition then
        parentNode:addChild(frozenParticle, 101)
        frozenParticle:setPosition(casterPosition)
    end
    local timerSkeleton =
        sp.SkeletonAnimation:create("fish_effect/bingdongyujiesuan.json", "fish_effect/bingdongyujiesuan.atlas")
    timerSkeleton:setPosition(display.cx, 120)
    timerSkeleton:setVisible(false)
    timerSkeleton:setScale(0.9)
    timerSkeleton:setOpacity(255)
    local function timerSkeletonAppear()
        timerSkeleton:show()
        timerSkeleton:setAnimation(0, "start", false)
        timerSkeleton:addAnimation(0, "idle", true)
    end
    local actionAppearDelay = cc.DelayTime:create(0.2)
    local actionBeginCall = cc.CallFunc:create(timerSkeletonAppear)
    local actionIdleDelay = cc.DelayTime:create(delayTime - 0.5)
    local actionRemove = cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.FadeOut:create(0.3))
    local actionSequence = cc.Sequence:create(actionAppearDelay, actionBeginCall, actionIdleDelay, actionRemove)
    timerSkeleton:runAction(actionSequence)
    parentNode:addChild(timerSkeleton, 102)
    local duration = 3 * 0.033
    local texInfo = {
        textureType = 2,
        jsonFileName = "fish_effect/3dby_baofen.json",
        atlasFileName = "fish_effect/3dby_baofen.atlas",
        textureWidth = "66",
        textureHeight = "84",
        [0] = {texture = "0", sizeFix = {-15, 0}},
        [1] = {texture = "1", sizeFix = {-20, 0}},
        [2] = {texture = "2", sizeFix = {-15, 0}},
        [3] = {texture = "3", sizeFix = {-15, 0}},
        [4] = {texture = "4", sizeFix = {-15, 0}},
        [5] = {texture = "5", sizeFix = {-15, 0}},
        [6] = {texture = "6", sizeFix = {-15, 0}},
        [7] = {texture = "7", sizeFix = {-15, 0}},
        [8] = {texture = "8", sizeFix = {-15, 0}},
        [9] = {texture = "9", sizeFix = {-15, 0}},
        [","] = {texture = "10", sizeFix = {-50, 0}, positionFix = {-3, -10}},
        ["w"] = {texture = "11", sizeFix = {-10, 0}, positionFix = {0, -5}},
        ["y"] = {texture = "12", sizeFix = {-10, 0}, positionFix = {0, -5}}
    }
    local timerLabelLight = TexturedNumber.new()
    timerLabelLight:setTextureSet(texInfo)
    timerLabelLight:setAnchorPoint(0.5, 0.5)
    timerLabelLight:disableSeperator()
    timerLabelLight:enableUnit()
    timerLabelLight:setNumber(delayTime)
    timerLabelLight:setPosition(5, -27)
    timerLabelLight:setScale(0.5 * 0.65)
    timerLabelLight:setOpacity(0)
    local appearAction =
        cc.Sequence:create(
        cc.DelayTime:create(0.2 + 6 * 0.033),
        cc.Spawn:create(cc.ScaleTo:create(duration, 1.0 * 0.65), cc.FadeTo:create(duration, 255))
    )
    local delayAction = cc.DelayTime:create(delayTime - 0.5 - 9 * 0.033)
    local disappearCall =
        cc.CallFunc:create(
        function()
            parentNode:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(
                        function()
                            catchFish.hp = 0
                        end
                    )
                )
            )
        end
    )
    local disappearAction =
        cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.FadeOut:create(0.3)))
    local actionSequence =
        cc.Sequence:create(
        appearAction,
        delayAction,
        disappearCall,
        disappearAction,
        cc.CallFunc:create(
            function()
                self.scene.bFishStop = false
                timerLabelLight:removeFromParent()
                timerSkeleton:removeFromParent()
            end
        )
    )
    timerLabelLight:runAction(actionSequence)
    timerSkeleton:addChild(timerLabelLight, 104)
    local countDown = math.floor(delayTime - 1)
    local countDownCall = function()
        countDown = countDown - 1
        timerLabelLight:setNumber(countDown)
        local scaleAction = cc.Sequence:create(cc.ScaleTo:create(0.2, 0.65 * 1.1), cc.ScaleTo:create(0.2, 0.65 * 1.0))
        timerLabelLight:runAction(scaleAction)
        local durationFadeIn = 10 * 0.033
        local durationFadeOut = 25 * 0.033
        local durationTotal = durationFadeIn + durationFadeOut
        local timerInfo = {
            textureType = 2,
            jsonFileName = "fish_effect/3dby_baofen.json",
            atlasFileName = "fish_effect/3dby_baofen.atlas",
            textureWidth = "66",
            textureHeight = "84",
            [0] = {texture = "0_s", sizeFix = {-15, 0}},
            [1] = {texture = "1_s", sizeFix = {-20, 0}},
            [2] = {texture = "2_s", sizeFix = {-15, 0}},
            [3] = {texture = "3_s", sizeFix = {-15, 0}},
            [4] = {texture = "4_s", sizeFix = {-15, 0}},
            [5] = {texture = "5_s", sizeFix = {-15, 0}},
            [6] = {texture = "6_s", sizeFix = {-15, 0}},
            [7] = {texture = "7_s", sizeFix = {-15, 0}},
            [8] = {texture = "8_s", sizeFix = {-15, 0}},
            [9] = {texture = "9_s", sizeFix = {-15, 0}},
            [","] = {texture = "10_s", sizeFix = {-15, 0}},
            ["w"] = {texture = "11_s", sizeFix = {-10, 0}, positionFix = {0, -5}},
            ["y"] = {texture = "12_s", sizeFix = {-10, 0}, positionFix = {0, -5}}
        }
        local timerLabelEffect = TexturedNumber.new()
        timerLabelEffect:setTextureSet(timerInfo)
        timerLabelEffect:setAnchorPoint(0.5, 0.5)
        timerLabelEffect:disableSeperator()
        timerLabelEffect:disableUnit()
        timerLabelEffect:setNumber(countDown)
        timerLabelEffect:setPosition(display.cx + 7, 93)
        timerLabelEffect:setScale(1.0 * 0.65)
        timerLabelEffect:setOpacity(0)
        local scaleEase = cc.EaseExponentialOut:create(cc.ScaleTo:create(durationTotal, 1.6 * 0.65))
        local effectAction =
            cc.Sequence:create(
            cc.Spawn:create(
                scaleEase,
                cc.Sequence:create(cc.FadeTo:create(durationFadeIn, 145), cc.FadeTo:create(durationFadeOut, 0))
            ),
            cc.CallFunc:create(
                function()
                    timerLabelEffect:removeFromParent()
                end
            )
        )
        timerLabelEffect:runAction(effectAction)
        parentNode:addChild(timerLabelEffect, 105)
    end
    local countDownAction =
        cc.Sequence:create(
        cc.DelayTime:create(0.2 + 6 * 0.033),
        cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(countDownCall), cc.DelayTime:create(1.0)), countDown)
    )
    timerSkeleton:runAction(countDownAction)
end
function EffectLayer:dynamiteFishBoom(catchFish, deadFishIdList, chairID, score)
    catchFish.isStop = true
    local catchFishPos3D = catchFish:getPosition3D()
    local runScene = cc.Director:getInstance():getRunningScene()
    local index = 1
    local delayTime = 36 * 0.033
    while index <= 300 and #deadFishIdList > 0 do
        local deadFish = self.scene.fishLayer:getFishByFishId(deadFishIdList[index])
        local currentIndex = index
        if not tolua.isnull(deadFish) and deadFish.fishId ~= catchFish.fishId then
            local function killFishGold()
                deadFish.hp = 0
            end
            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(delayTime + 0.5 * math.random()),
                    cc.CallFunc:create(killFishGold)
                )
            )
        end
        index = index + 1
    end
    local shakeStart = {
        cc.MoveBy:create(0.033, cc.p(-1, 1)),
        cc.MoveBy:create(0.033, cc.p(-3, 2)),
        cc.MoveBy:create(0.033, cc.p(4, -4)),
        cc.MoveBy:create(0.033, cc.p(7, -7)),
        cc.MoveBy:create(0.033, cc.p(-7, 8))
    }
    local shakeIdle = {
        cc.MoveBy:create(0.033, cc.p(7, 6)),
        cc.MoveBy:create(0.033, cc.p(-6, 0)),
        cc.MoveBy:create(0.033, cc.p(6, -7)),
        cc.MoveBy:create(0.033, cc.p(0, 6)),
        cc.MoveBy:create(0.033, cc.p(-7, -5))
    }
    local shakeEnd = {
        cc.MoveBy:create(0.033, cc.p(-7, 8)),
        cc.MoveBy:create(0.033, cc.p(7, -7)),
        cc.MoveBy:create(0.033, cc.p(4, -4)),
        cc.MoveBy:create(0.033, cc.p(-3, 2)),
        cc.MoveBy:create(0.033, cc.p(-1, 1))
    }
    catchFish:runAction(
        cc.Sequence:create(
            cc.Sequence:create(shakeStart),
            cc.Repeat:create(cc.Sequence:create(shakeIdle), 6),
            cc.Sequence:create(shakeEnd)
        )
    )
    local shakeStart = {
        cc.MoveBy:create(0.033, cc.p(-0.5, 0.5)),
        cc.MoveBy:create(0.033, cc.p(-1.5, 1)),
        cc.MoveBy:create(0.033, cc.p(2, -2)),
        cc.MoveBy:create(0.033, cc.p(2.5, -2.5)),
        cc.MoveBy:create(0.033, cc.p(-2.5, 3))
    }
    local shakeIdle = {
        cc.MoveBy:create(0.033, cc.p(2.5, 2)),
        cc.MoveBy:create(0.033, cc.p(-2, 0)),
        cc.MoveBy:create(0.033, cc.p(2, -2.5)),
        cc.MoveBy:create(0.033, cc.p(0, 2)),
        cc.MoveBy:create(0.033, cc.p(-2.5, -1.5))
    }
    runScene:runAction(
        cc.Sequence:create(cc.Sequence:create(shakeStart), cc.Repeat:create(cc.Sequence:create(shakeIdle), 6))
    )
    local position3D = catchFish:getPosition3D()
    local castEffect =
        sp.SkeletonAnimation:create("fish_effect/zhadanyueffect.json", "fish_effect/zhadanyueffect.atlas")
    castEffect:setPosition3D(position3D)
    castEffect:setAnimation(0, "end", false)
    castEffect:setScale(1.2)
    self:addChild(castEffect, 1000)
    castEffect:runAction(cc.Sequence:create(cc.DelayTime:create(60 * 0.033), cc.RemoveSelf:create()))
    local fullScreenEffect =
        sp.SkeletonAnimation:create("fish_effect/zhadanyupmeffect.json", "fish_effect/zhadanyupmeffect.atlas")
    fullScreenEffect:setPosition(display.cx, display.cy)
    fullScreenEffect:setAnimation(0, "animation", false)
    fullScreenEffect:setScale(display.width / 1336)
    self:addChild(fullScreenEffect, 10001)
    fullScreenEffect:runAction(cc.Sequence:create(cc.DelayTime:create(60 * 0.033), cc.RemoveSelf:create()))
    local runParticleAction =
        cc.CallFunc:create(
        function()
            if tolua.isnull(catchFish) then
                return
            end
            local particle = cc.ParticleSystemQuad:create("fish_effect/zhadanyulizinew.plist")
            particle:setPosition3D(position3D)
            particle:resetSystem()
            particle:setScale(1.2)
            self:addChild(particle, 102)
            particle:runAction(cc.Sequence:create(cc.DelayTime:create(60 * 0.033), cc.RemoveSelf:create()))
            catchFish.hp = 0
            ExternalFun.playSoundEffectCommon("sound/effect/Bigfireworks.mp3")
            local cannon = self.scene.cannonLayer:getCannonByChairId(chairID)
            if not tolua.isnull(cannon) then
                local coinPos = cannon:getCoinPosToWord()
                local catchFishPos = self.scene._camera:projectGL(catchFishPos3D)
                self:ShowFishGoldEx(catchFishPos, coinPos, chairID, score, 1)
            end
        end
    )
    self:runAction(cc.Sequence:create(cc.DelayTime:create(36 * 0.033), runParticleAction))
    local shakeStart = {
        cc.MoveBy:create(0.033, cc.p(-1, 1)),
        cc.MoveBy:create(0.033, cc.p(-3, 2)),
        cc.MoveBy:create(0.033, cc.p(5, -5)),
        cc.MoveBy:create(0.033, cc.p(8, -8)),
        cc.MoveBy:create(0.033, cc.p(-9, 10))
    }
    local shakeIdle = {
        cc.MoveBy:create(0.033, cc.p(10, 9)),
        cc.MoveBy:create(0.033, cc.p(-9, 0)),
        cc.MoveBy:create(0.033, cc.p(9, -10)),
        cc.MoveBy:create(0.033, cc.p(0, 9)),
        cc.MoveBy:create(0.033, cc.p(-10, -8))
    }
    local shakeEnd = {
        cc.MoveBy:create(0.033, cc.p(-9, 10)),
        cc.MoveBy:create(0.033, cc.p(8, -8)),
        cc.MoveBy:create(0.033, cc.p(5, -5)),
        cc.MoveBy:create(0.033, cc.p(-3, 2)),
        cc.MoveBy:create(0.033, cc.p(-1, 1))
    }
    runScene:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(36 * 0.033),
            cc.Sequence:create(shakeStart),
            cc.Repeat:create(cc.Sequence:create(shakeIdle), 2),
            cc.Sequence:create(shakeEnd)
        )
    )
end
function EffectLayer:generateParticleNode(scale, offsetX)
    local containerNode = cc.Node:create()
    local particleNode = cc.Node:create()
    particleNode.particles = {}
    containerNode:addChild(particleNode)
    for i = 0, 3 do
        local node = cc.Node:create()
        local particle = cc.ParticleSystemQuad:create("particle/particle_fire.plist")
        particle:setTotalParticles(350)
        particle:setEmissionRate(20)
        particle:setPosition(cc.p(offsetX, 0))
        particle:setPositionType(0)
        node:addChild(particle)
        node:setRotation(90 * i)
        particleNode.particles[i] = particle
        particleNode:setScale(scale)
        particleNode:addChild(node)
        particleNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -360)))
    end
    containerNode.stop = function()
        for i = 0, 3 do
            particleNode.particles[i]:stopSystem()
        end
    end
    return containerNode
end
function EffectLayer:generateCircleNodeOutside(targetMultiply, scoreBase)
    local radius = 159
    local angleInterval = 36 * math.pi / 180
    local circleNode = cc.Node:create()
    local resultIndex = math.random(0, 9)
    local targetAngle = 0
    circleNode:setCascadeOpacityEnabled(true)
    for i = 0, 9 do
        local currentAngle = angleInterval * i + math.pi / 2
        local score = scoreBase
        if i == resultIndex then
            score = score * targetMultiply
            targetAngle = currentAngle * 180 / math.pi - 90
        else
            score = score * math.floor(math.random(80, 150) / math.random(1, 10))
        end
        local itemNode = self:generateOutsideItem(radius, currentAngle, score)
        circleNode:addChild(itemNode, 2)
    end
    return circleNode, targetAngle
end
function EffectLayer:generateCircleNodeInside(targetMultiply)
    local radius = 85
    local angleInterval = 36 * math.pi / 180
    local circleNode = cc.Node:create()
    local targetAngle = 0
    circleNode:setCascadeOpacityEnabled(true)
    for i = 0, 9 do
        local currentAngle = angleInterval * i + math.pi / 2
        local itemNode = self:generateInsideItem(radius, currentAngle, i + 1)
        circleNode:addChild(itemNode, 2)
        if targetMultiply == i + 1 then
            targetAngle = currentAngle * 180 / math.pi - 90
        end
    end
    return circleNode, targetAngle
end
function EffectLayer:generateOutsideItem(radius, angle, score)
    local node = cc.Node:create()
    node:setPosition(cc.p(radius * math.cos(angle), radius * math.sin(angle)))
    node:setRotation(90 - angle * 180 / math.pi)
    node:setCascadeOpacityEnabled(true)
    local sprite = cc.Sprite:create("ui/ingame/changgui_jinbi.png")
    node:addChild(sprite, 1)
    local txt =
        ccui.TextAtlas:create(score, "ui/ingame/roulette_score.png", 16, 20, "0"):setAnchorPoint(0.5, 0.5):setPosition(
        cc.p(0, 0)
    )
    node:addChild(txt, 2)
    return node
end
function EffectLayer:generateInsideItem(radius, angle, multiply)
    local node = cc.Node:create()
    node:setPosition(cc.p(radius * math.cos(angle), radius * math.sin(angle)))
    node:setRotation(90 - angle * 180 / math.pi)
    node:setCascadeOpacityEnabled(true)
    local txt =
        ccui.TextAtlas:create(":" .. multiply, "ui/ingame/roulette_multiply.png", 18, 21, "0"):setAnchorPoint(0.5, 0.5):setPosition(
        cc.p(0, 0)
    )
    node:addChild(txt)
    return node
end
function EffectLayer:showSpecialCashInAnimation(score, chairID, txtOffset)
    local offsetY = 150
    local txtOffset = txtOffset or 0
    if chairID == 2 or chairID == 3 then
        offsetY = -150
    end
    local cannon = self.scene.cannonLayer:getCannonByChairId(chairID)
    local cannonPosition = cannon:getWorldPos()
    local coinPosition = cannon:getCoinPosToWord()
    local spine = sp.SkeletonAnimation:create("fish_effect/3dby_xybxjs.json", "fish_effect/3dby_xybxjs.atlas")
    spine:setOpacity(255)
    spine:setScale(0.9)
    spine:setAnimation(0, "start", false)
    spine:addAnimation(0, "idle", true)
    spine:setCascadeOpacityEnabled(true)
    spine:setPosition(cannonPosition.x, cannonPosition.y + offsetY)
    self:addChild(spine, 101)
    local duration = 3 * 0.033
    local texInfo = {
        textureType = 2,
        jsonFileName = "fish_effect/3dby_baofen.json",
        atlasFileName = "fish_effect/3dby_baofen.atlas",
        textureWidth = "66",
        textureHeight = "84",
        [0] = {texture = "0", sizeFix = {-15, 0}},
        [1] = {texture = "1", sizeFix = {-20, 0}},
        [2] = {texture = "2", sizeFix = {-15, 0}},
        [3] = {texture = "3", sizeFix = {-15, 0}},
        [4] = {texture = "4", sizeFix = {-15, 0}},
        [5] = {texture = "5", sizeFix = {-15, 0}},
        [6] = {texture = "6", sizeFix = {-15, 0}},
        [7] = {texture = "7", sizeFix = {-15, 0}},
        [8] = {texture = "8", sizeFix = {-15, 0}},
        [9] = {texture = "9", sizeFix = {-15, 0}},
        [","] = {texture = "10", sizeFix = {-50, 0}, positionFix = {-3, -10}},
        ["w"] = {texture = "11", sizeFix = {-10, 0}, positionFix = {0, -5}},
        ["y"] = {texture = "12", sizeFix = {-10, 0}, positionFix = {0, -5}}
    }
    local timerLabelLight = TexturedNumber.new()
    timerLabelLight:setTextureSet(texInfo)
    timerLabelLight:setAnchorPoint(0.5, 0.5)
    timerLabelLight:setLimitTrigger(0)
    timerLabelLight:disableSeperator()
    timerLabelLight:enableUnit()
    timerLabelLight:setNumber(score)
    timerLabelLight:setPosition(5, -27 + txtOffset)
    timerLabelLight:setScale(0.5 * 0.65)
    timerLabelLight:setOpacity(0)
    local appearAction =
        cc.Sequence:create(
        cc.DelayTime:create(6 * 0.033),
        cc.Spawn:create(cc.ScaleTo:create(duration, 1.0 * 0.65), cc.FadeTo:create(duration, 255))
    )
    local actionSequence = cc.Sequence:create(appearAction)
    timerLabelLight:runAction(actionSequence)
    spine:addChild(timerLabelLight, 104)
    local durationFadeIn = 10 * 0.033
    local durationFadeOut = 25 * 0.033
    local durationTotal = durationFadeIn + durationFadeOut
    local timerInfo = {
        textureType = 2,
        jsonFileName = "fish_effect/3dby_baofen.json",
        atlasFileName = "fish_effect/3dby_baofen.atlas",
        textureWidth = "66",
        textureHeight = "84",
        [0] = {texture = "0_s", sizeFix = {-15, 0}},
        [1] = {texture = "1_s", sizeFix = {-20, 0}},
        [2] = {texture = "2_s", sizeFix = {-15, 0}},
        [3] = {texture = "3_s", sizeFix = {-15, 0}},
        [4] = {texture = "4_s", sizeFix = {-15, 0}},
        [5] = {texture = "5_s", sizeFix = {-15, 0}},
        [6] = {texture = "6_s", sizeFix = {-15, 0}},
        [7] = {texture = "7_s", sizeFix = {-15, 0}},
        [8] = {texture = "8_s", sizeFix = {-15, 0}},
        [9] = {texture = "9_s", sizeFix = {-15, 0}},
        [","] = {texture = "10_s", sizeFix = {-15, 0}},
        ["w"] = {texture = "11_s", sizeFix = {-10, 0}, positionFix = {0, -5}},
        ["y"] = {texture = "12_s", sizeFix = {-10, 0}, positionFix = {0, -5}}
    }
    local timerLabelEffect = TexturedNumber.new()
    timerLabelEffect:setTextureSet(timerInfo)
    timerLabelEffect:setAnchorPoint(0.5, 0.5)
    timerLabelEffect:setLimitTrigger(0)
    timerLabelEffect:disableSeperator()
    timerLabelEffect:enableUnit()
    timerLabelEffect:setNumber(score)
    timerLabelEffect:setPosition(5, -27 + txtOffset)
    timerLabelEffect:setScale(0.7 * 0.65)
    timerLabelEffect:setOpacity(0)
    local scaleEase = cc.EaseExponentialOut:create(cc.ScaleTo:create(durationTotal, 1.35 * 0.65))
    local effectAction =
        cc.Sequence:create(
        cc.Spawn:create(
            scaleEase,
            cc.Sequence:create(cc.FadeTo:create(durationFadeIn, 145), cc.FadeTo:create(durationFadeOut, 0))
        )
    )
    timerLabelEffect:runAction(effectAction)
    spine:addChild(timerLabelEffect, 105)
    local disappearAction =
        cc.Sequence:create(
        cc.EaseSineOut:create(cc.ScaleTo:create(5 * 0.033, 0.85)),
        cc.EaseSineOut:create(cc.ScaleTo:create(5 * 0.033, 1.08)),
        cc.EaseSineOut:create(cc.ScaleTo:create(5 * 0.033, 1.01)),
        cc.EaseSineOut:create(cc.ScaleTo:create(5 * 0.033, 1.07)),
        cc.EaseSineInOut:create(
            cc.Spawn:create(
                cc.MoveTo:create(15 * 0.033, coinPosition),
                cc.ScaleTo:create(15 * 0.033, 0.3),
                cc.FadeTo:create(15 * 0.033, 0)
            )
        ),
        cc.CallFunc:create(
            function()
            end
        )
    )
    local recycleAction =
        cc.CallFunc:create(
        function()
            timerLabelLight:onDestroy()
            timerLabelEffect:onDestroy()
            spine:removeFromParent()
        end
    )
    spine:runAction(cc.Sequence:create(cc.DelayTime:create(3), disappearAction, recycleAction))
    ExternalFun.playSoundEffectCommon("sound/effect/sfx_levelup.mp3")
end
function EffectLayer:crabBoom(score, chairID, multiple, fishPos)
    local score = score
    local chairID = chairID
    local cannon = self.scene.cannonLayer:getCannonByChairId(chairID)
    local cannonPos = cannon:getWorldPos()
    local cannonPosition = cc.p(cannonPos.x, cannonPos.y)
    local nBScoe = 1000
    local nBMultiple = 1
    local nBaseScore = math.floor(score / (nBScoe * nBMultiple))
    local nBaseMultiple = multiple or 1
    local fishPos = fishPos
    local wheelRotation = 0
    local targetY = 0
    local matchNum = math.floor((nBaseScore / nBaseMultiple) * 10) / 10
    if chairID < 2 then
        cannonPosition.y = cannonPosition.y - 20
        targetY = -100
    else
        cannonPosition.y = cannonPosition.y + 20
        wheelRotation = 180
        targetY = 750 + 100
    end
    local effect = self.coinEffect[chairID]
    local particle = self.coinParticle[chairID]
    local animationNode = cc.Node:create()
    animationNode:setPosition(fishPos)
    animationNode:setScale(0.85)
    animationNode:setCascadeOpacityEnabled(true)
    animationNode:setRotation(wheelRotation)
    self:addChild(animationNode)
    local bg = cc.Sprite:create("ui/ingame/3dby_xybxzpdb.png")
    bg:setScale(4)
    animationNode:addChild(bg, 0)
    local spine = sp.SkeletonAnimation:create("fish_effect/3dby_xybxzp.json", "fish_effect/3dby_xybxzp.atlas")
    spine:setAnimation(0, "start", false)
    animationNode:addChild(spine, 2)
    local boom_1 = cc.ParticleSystemQuad:create("particle/3dby_xybxzpguangci.plist")
    boom_1:setPosition(cc.p(-5, -5))
    boom_1:resetSystem()
    boom_1:setScale(1.5)
    animationNode:addChild(boom_1, 102)
    local boom_2 = cc.ParticleSystemQuad:create("particle/3dby_xybxzpstarboom.plist")
    boom_2:setPosition(cc.p(-5, -5))
    boom_2:resetSystem()
    boom_2:setScale(1.5)
    animationNode:addChild(boom_2, 103)
    local particleNode_1 = self:generateParticleNode(1.0 * 1.05, -195)
    animationNode:addChild(particleNode_1, 3)
    local particleNode_2 = self:generateParticleNode(0.6 * 1.05, -200)
    animationNode:addChild(particleNode_2, 3)
    local contentOutside, angleOutside = self:generateCircleNodeOutside(matchNum, nBScoe * nBMultiple)
    animationNode:addChild(contentOutside, 1)
    local contentInside, angleInside = self:generateCircleNodeInside(nBaseMultiple)
    animationNode:addChild(contentInside, 1)
    local resultScore = self:generateOutsideItem(0, 0, nBScoe * nBMultiple * matchNum)
    animationNode:addChild(resultScore, 4)
    resultScore:setRotation(0)
    resultScore:setPosition(0, 159)
    resultScore:hide()
    local resultMultiply = self:generateInsideItem(0, 0, nBaseMultiple)
    animationNode:addChild(resultMultiply, 4)
    resultMultiply:setRotation(0)
    resultMultiply:setPosition(0, 85)
    resultMultiply:hide()
    animationNode:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(3 * 0.033),
            cc.CallFunc:create(
                function()
                    animationNode:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0 * 0.033),
                            cc.EaseBackIn:create(cc.MoveTo:create(0.55, cannonPosition)),
                            cc.CallFunc:create(
                                function()
                                    spine:setAnimation(0, "p2", false)
                                    animationNode:runAction(
                                        cc.Sequence:create(
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(
                                                function()
                                                    spine:setAnimation(1, "idle", false)
                                                    contentInside:runAction(
                                                        cc.EaseSineInOut:create(
                                                            cc.RotateBy:create(68 * 0.033, 360 * 2 + angleInside)
                                                        )
                                                    )
                                                    contentOutside:runAction(
                                                        cc.EaseSineInOut:create(
                                                            cc.RotateBy:create(68 * 0.033, -360 * 3 + angleOutside)
                                                        )
                                                    )
                                                    animationNode:runAction(
                                                        cc.Sequence:create(
                                                            cc.DelayTime:create(4.5),
                                                            cc.CallFunc:create(
                                                                function()
                                                                    spine:setAnimation(0, "end", false)
                                                                    particleNode_1.stop()
                                                                    particleNode_2.stop()
                                                                    animationNode:runAction(
                                                                        cc.Sequence:create(
                                                                            cc.DelayTime:create(12 * 0.033),
                                                                            cc.CallFunc:create(
                                                                                function()
                                                                                    self:showSpecialCashInAnimation(
                                                                                        score,
                                                                                        chairID,
                                                                                        -15
                                                                                    )
                                                                                end
                                                                            )
                                                                        )
                                                                    )
                                                                    animationNode:runAction(
                                                                        cc.Sequence:create(
                                                                            cc.DelayTime:create(12 * 0.033),
                                                                            cc.FadeTo:create(0.15, 0)
                                                                        )
                                                                    )
                                                                    animationNode:runAction(
                                                                        cc.Sequence:create(
                                                                            cc.DelayTime:create(6 * 0.033),
                                                                            cc.EaseSineIn:create(
                                                                                cc.MoveTo:create(
                                                                                    9 * 0.033,
                                                                                    cc.p(cannonPosition.x, targetY)
                                                                                )
                                                                            ),
                                                                            cc.CallFunc:create(
                                                                                function()
                                                                                end
                                                                            ),
                                                                            cc.RemoveSelf:create()
                                                                        )
                                                                    )
                                                                end
                                                            )
                                                        )
                                                    )
                                                    animationNode:runAction(
                                                        cc.Sequence:create(
                                                            cc.DelayTime:create(69 * 0.033),
                                                            cc.CallFunc:create(
                                                                function()
                                                                    resultScore:show()
                                                                    resultMultiply:show()
                                                                    resultScore:runAction(
                                                                        cc.Sequence:create(
                                                                            cc.ScaleTo:create(6 * 0.033, 1.4),
                                                                            cc.ScaleTo:create(6 * 0.033, 1.0),
                                                                            cc.ScaleTo:create(3 * 0.033, 1.2),
                                                                            cc.ScaleTo:create(3 * 0.033, 1.0)
                                                                        )
                                                                    )
                                                                    resultMultiply:runAction(
                                                                        cc.Sequence:create(
                                                                            cc.ScaleTo:create(6 * 0.033, 1.4),
                                                                            cc.ScaleTo:create(6 * 0.033, 1.0),
                                                                            cc.ScaleTo:create(3 * 0.033, 1.2),
                                                                            cc.ScaleTo:create(3 * 0.033, 1.0)
                                                                        )
                                                                    )
                                                                    boom_1:resetSystem()
                                                                    boom_2:resetSystem()
                                                                end
                                                            )
                                                        )
                                                    )
                                                end
                                            )
                                        )
                                    )
                                end
                            )
                        )
                    )
                end
            )
        )
    )
end
function EffectLayer:showBingoAnimationEx(score, chairId)
    local node = cc.Node:create()
    local bottomPanel = sp.SkeletonAnimation:create("fish_effect/3dby_xybxzp.json", "fish_effect/3dby_xybxzp.atlas")
    bottomPanel:setAnimation(0, "start", false)
    bottomPanel:addAnimation(0, "p1", false)
    bottomPanel:addAnimation(0, "p2", false)
    bottomPanel:addAnimation(0, "end", false)
    self:addChild(bottomPanel, 10000)
    bottomPanel:setPosition(display.cx, display.cy)
    local effectNode =
        cc.ParticleSystemQuad:create("particle/3dby_xybxzpguangci.plist"):setPosition(display.cx, display.cy)
    self:addChild(effectNode, 10000)
    local effectNode1 =
        cc.ParticleSystemQuad:create("particle/3dby_xybxzpstarboom.plist"):setPosition(display.cx, display.cy)
    self:addChild(effectNode1, 10000)
end
function EffectLayer:showBingoAnimation(score, chairId)
    local node = cc.Node:create()
    local bottomPanel =
        sp.SkeletonAnimation:create("animationex/score/gaofenzhuanpan.json", "animationex/score/gaofenzhuanpan.atlas")
    bottomPanel:setAnimation(0, "animation", true)
    bottomPanel:setOpacity(0)
    node:addChild(bottomPanel)
    local panelSize = bottomPanel:getContentSize()
    local scoreNode = generateNumberLabel(score, chairId)
    scoreNode:setAnchorPoint(0.5, 0.5)
    node:setScale(1.1)
    node:addChild(scoreNode, 2)
    scoreNode:setPosition(-5, 15)
    scoreNode:setSkewY(10)
    scoreNode:setRotation(3)
    local raction = cc.RotateBy:create(4.0, 360)
    bottomPanel:runAction(cc.RepeatForever:create(raction))
    local cannons = self._world:retrieveEntity("cannon")
    local selfCannon = cannons[chairId]
    local gameConfig = self.GameConfig
    local cannonPosition = selfCannon:getValue("position")
    local offsetY = 200
    if gameConfig.MirrorFlag then
        if chairId == 0 or chairId == 1 then
            offsetY = -200
        end
    else
        if chairId == 2 or chairId == 3 then
            offsetY = -200
        end
    end
    local x = cannonPosition.x
    local y = cannonPosition.y + offsetY
    node:setPosition(x, y)
    local effectLayer = self.effectLayer
    effectLayer:addChild(node, 101)
    node:setScale(0.3)
    node:setOpacity(0)
    node:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.ScaleTo:create(0.2, 1.2)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.25, 0.98)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.15, 1.05)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.15, 1.0))
                )
            ),
            cc.DelayTime:create(1.6),
            cc.Spawn:create(cc.ScaleTo:create(0.3, 1.15), cc.Sequence:create(cc.DelayTime:create(1.6))),
            cc.RemoveSelf:create()
        )
    )
    scoreNode:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.Spawn:create(
                cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.ScaleTo:create(0.2, 1.2)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.25, 0.98)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.15, 1.05)),
                    cc.EaseSineInOut:create(cc.ScaleTo:create(0.15, 1.0))
                )
            ),
            cc.DelayTime:create(1.4),
            cc.ScaleTo:create(0.1, 0.95),
            cc.Spawn:create(cc.ScaleTo:create(0.3, 1.15), cc.Sequence:create(cc.DelayTime:create(0.1)))
        )
    )
    scoreNode:runAction(
        cc.Sequence:create(
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 12)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -12))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 9)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -9))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 13)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -13))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 12)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -12))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 12)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -12))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 9)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -9))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 13)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -13))
            ),
            cc.Sequence:create(
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, 12)),
                cc.EaseSineInOut:create(cc.RotateBy:create(0.2, -12))
            )
        )
    )
    scoreNode:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.FadeTo:create(0.3, 255),
            cc.DelayTime:create(2.05),
            cc.FadeTo:create(0.1, 0)
        )
    )
    bottomPanel:runAction(
        cc.Sequence:create(
            cc.FadeTo:create(0.1, 255),
            cc.DelayTime:create(2.35),
            cc.FadeTo:create(0.15, 0),
            cc.CallFunc:create(
                function()
                end
            )
        )
    )
end
function EffectLayer:loadLockedFish(fishId)
    if not self._lockUIContainer then
        self._lockUIContainer = display.newNode():setPosition(display.width - 73, 200):addTo(self.scene.uiLayer, 1)
        local spineAnimation =
            sp.SkeletonAnimation:create(
            "animationex/lock/3dby_game_lock.json",
            "animationex/lock/3dby_game_lock.atlas",
            1
        ):setAnimation(0, "start", false):addAnimation(0, "idle", true):addTo(self._lockUIContainer)
        local lockButton =
            ccui.Button:create("ui/btn/3dby_game_lockmenu.png", "ui/btn/3dby_game_lockmenu.png"):addTo(
            self._lockUIContainer
        )
        local buttonSize = lockButton:getContentSize()
        lockButton:setPosition(0, 50 - buttonSize.height / 2)
        lockButton:addTouchEventListener(handler(self, self.switchLockTarget))
        self._lockUIContainer.spine = spineAnimation
        self._lockUIContainer.modelContainer = display.newNode()
        self._lockUIContainer:addChild(self._lockUIContainer.modelContainer)
    end
    local fish = self.scene.fishLayer:getFishByFishId(fishId)
    if fish then
        if self._lockUIContainer._visual then
            self._lockUIContainer._visual:removeFromParent()
            self._lockUIContainer._visual = nil
        end
        if fish.fishData then
            self._lockUIContainer:setVisible(true)
            self._lockUIContainer.spine:setAnimation(0, "start", false)
            self._lockUIContainer.spine:addAnimation(0, "idle", true)
            self._lockUIContainer.modelContainer:removeAllChildren()
            local fishView =
                FishVisual:create(fish.fishData):addTo(self._lockUIContainer.modelContainer):setScale(
                fish.fishData.presentationScale
            ):show()
            fishView.model:setRotation3D(cc.vec3(0, -180, 0))
            self._lockUIContainer._visual = fishVisual
        end
    else
        self._lockUIContainer:hide()
    end
end
function EffectLayer:switchLockTarget(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        ExternalFun.playCommonButtonClickEffect()
        -- EventMgr:getInstance():dispatchEvent({name = "qpby_changeLockTarget", para = {}})
        local event = cc.EventCustom:new("qpby_changeLockTarget")
        event._usedata = {name = "qpby_changeLockTarget", para = {}}
        local dispacther=cc.Director:getInstance():getEventDispatcher()
        dispacther:dispatchEvent(event)
    end
end
function EffectLayer:updateLockChain(dt)
    for i = 1, #self.scene.cannonLayer.cannonList do
        local curCannon = self.scene.cannonLayer.cannonList[i]
        if not tolua.isnull(curCannon) then
            local cannonChairId = curCannon:getTag() - 1000
            local lockFishId = curCannon.lockingTarget
            local cannonPosX, cannonPosY = curCannon.cannonPosition:getPosition()
            local cannonPos = curCannon.cannonPosition:getParent():convertToWorldSpace(cc.p(cannonPosX, cannonPosY))
            if not self._lockFishChain[cannonChairId] then
                self._lockFishChain[cannonChairId] = self:createLockChain(cannonPos)
            end
            local chain = self._lockFishChain[cannonChairId]
            local fish = self.scene.fishLayer:getFishByFishId(lockFishId)
            if not tolua.isnull(fish) and not fish.isDead then
                local fishPos = fish:getPosition3D()
                fishPos = self.scene._camera:projectGL(fishPos)
                local direction = cc.p(fishPos.x - chain.posX, fishPos.y - chain.posY)
                local distance = math.sqrt(direction.x * direction.x + direction.y * direction.y) - 60
                local angle = (math.pi / 2 - math.atan2(direction.y, direction.x)) * 57.29578
                chain:setVisible(true)
                chain:setRotation(angle)
                chain.mask:setScaleY((1221 - distance) / 10)
                chain.target:setVisible(true)
                chain.target:setPosition(fishPos)
            else
                chain:hide()
                chain.target:hide()
            end
        end
    end
end
function EffectLayer:createLockChain(startPosition)
    local target = cc.Sprite:create("animationex/lock/suoding_quan.png")
    self:addChild(target, 1)
    local clippingMask = cc.Sprite:create("ui/mask.png"):setAnchorPoint(0.5, 1.0):setScaleX(5):setPosition(0, 1221)
    local clippingNode =
        cc.ClippingNode:create():setStencil(clippingMask):setAlphaThreshold(0.8):setPosition(
        startPosition.x,
        startPosition.y
    ):setInverted(true):addTo(self)
    clippingNode.mask = clippingMask
    clippingNode.posX = startPosition.x
    clippingNode.posY = startPosition.y
    clippingNode.target = target
    local spines = {}
    for i = 1, 5 do
        local spine =
            sp.SkeletonAnimation:create("fish_effect/3dby_lockjiantou.json", "fish_effect/3dby_lockjiantou.atlas")
        spine:setTimeScale(2)
        spine:setOpacity(255)
        spine:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(0.033 * 29 * i),
                cc.CallFunc:create(
                    function()
                        spine:setAnimation(0, "animation", true)
                    end
                )
            )
        )
        spines[i + 1] = spine
        clippingNode:addChild(spines[i + 1], i)
    end
    return clippingNode
end
function EffectLayer:playFishGold(eventMsg)
    self:setShakeScreen()
end
function EffectLayer:playBossTip()
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 1))
    mask:setTouchEnabled(false)
    mask:runAction(
        cc.Sequence:create(
            cc.FadeTo:create(0.1, 70),
            cc.DelayTime:create(1.1),
            cc.FadeTo:create(0.1, 0),
            cc.RemoveSelf:create()
        )
    )
    self:addChild(mask, 1)
    local animation = sp.SkeletonAnimation:create("fish_effect/2dboostips.json", "fish_effect/2dboostips.atlas", 1)
    animation:setPosition(667, 375)
    animation:setAnimation(0, "animation", false)
    animation:setSkin("haidaochuan")
    self:addChild(animation, 1)
    animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.RemoveSelf:create()))
end
function EffectLayer:playTroopTip()
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 1))
    mask:setTouchEnabled(false)
    mask:runAction(
        cc.Sequence:create(
            cc.FadeTo:create(0.1, 70),
            cc.DelayTime:create(1.1),
            cc.FadeTo:create(0.1, 0),
            cc.RemoveSelf:create()
        )
    )
    self:addChild(mask, 1)
    local animation =
        sp.SkeletonAnimation:create(
        "animationex/troop_tips/flshboomtips.json",
        "animationex/troop_tips/flshboomtips.atlas",
        1
    )
    animation:setPosition(667, 375)
    animation:setAnimation(0, "animation", false)
    self:addChild(animation, 1)
    animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.RemoveSelf:create()))
end
function EffectLayer:onCleanup()
end
function EffectLayer:update(dt)
    self:updateLockChain(dt)
    if self._shakeScreen then
        self:updateShakeScreen(dt)
    end
end
function EffectLayer:setShakeScreen()
    self._shakeScreen = {time = math.max(0.5, math.min(60 / 60, 1.5)), range = math.min(150 / 50, 2)}
end
function EffectLayer:updateShakeScreen(dt)
    local base = math.max(1, 12 * self._shakeScreen.range * self._shakeScreen.time)
    local base_2 = base / 2
    local rootLayer = cc.Director:getInstance():getRunningScene()
    self._shakeScreen.time = self._shakeScreen.time - dt
    if self._shakeScreen.time <= 0 then
        rootLayer:setPosition(0, 0)
        self._shakeScreen = nil
    else
        rootLayer:setPosition(math.random() * base - base_2, math.random() * base - base_2)
    end
end
function EffectLayer:bulletEffect(pos)
    local folderName = "yuwangeffect"
    local jsonName = string.format("animationex/%s/%s.json", folderName, folderName)
    local atlasName = string.format("animationex/%s/%s.atlas", folderName, folderName)
    local bulletEffect =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition3D(pos):setAnimation(0, "animation", false):setTimeScale(
        2
    ):addTo(self)
    bulletEffect:setSkin(1)
    bulletEffect:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.RemoveSelf:create()))
end
function EffectLayer:getSpineByName(spineName)
    local info = {
        ["yuboomceffect"] = {
            JSON_PATH = "animationex/armature/yuboomceffect/yuboomceffect.json",
            ATLAS_PATH = "animationex/armature/yuboomceffect/yuboomceffect.atlas"
        },
        ["yuboombeffect"] = {
            JSON_PATH = "animationex/armature/yuboombeffect/yuboombeffect.json",
            ATLAS_PATH = "animationex/armature/yuboombeffect/yuboombeffect.atlas"
        },
        ["yuboomdeffect"] = {
            JSON_PATH = "animationex/armature/yuboomdeffect/yuboomdeffect.json",
            ATLAS_PATH = "animationex/armature/yuboomdeffect/yuboomdeffect.atlas"
        },
        ["yuboomeffect"] = {
            JSON_PATH = "animationex/armature/yuboomeffect/yuboomeffect.json",
            ATLAS_PATH = "animationex/armature/yuboomeffect/yuboomeffect.atlas"
        },
        ["jinbishounaeffect"] = {
            JSON_PATH = "animationex/armature/jinbishounaeffect.json",
            ATLAS_PATH = "animationex/armature/jinbishounaeffect.atlas"
        }
    }
    local spineInfo = info[spineName]
    return self:getSpineAnimation(spineInfo)
end
function EffectLayer:getSpineAnimation(info)
    local object = sp.SkeletonAnimation:create(info.JSON_PATH, info.ATLAS_PATH, info.Scale or 1)
    return object
end
function EffectLayer:getFrameAnimationByName(aniName)
    local info = {
        ["fish_jinbi_gold"] = {
            PLIST_PATH = string.format("%sfish_jinbi_1/fish_jinbi_10.plist", "animationex/"),
            FRAME_NAME = "fish_jinbi4",
            FRAME_NUMBER = 6
        },
        ["fish_jinbi_silver"] = {
            PLIST_PATH = string.format("%sfish_jinbi_1/fish_jinbi_yinse0.plist", "animationex/"),
            FRAME_NAME = "fish_yinse_jinbi4",
            FRAME_NUMBER = 6,
            maxCacheNumber = 0
        }
    }
    local aniInfo = info[aniName]
    return self:getFrameAnimation(aniInfo, aniName)
end
function EffectLayer:getFrameAnimation(info, key)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(info.PLIST_PATH)
    local animation = cc.AnimationCache:getInstance():getAnimation(key)
    if not animation then
        local frames = {}
        for i = 1, info.FRAME_NUMBER do
            frames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("%s_%d.png", info.FRAME_NAME, i))
        end
        animation = cc.Animation:createWithSpriteFrames(frames, 0.040)
        animation:setLoops(100)
        cc.AnimationCache:getInstance():addAnimation(animation, key)
    end
    local object = cc.Animate:create(animation)
    if object then
        object:retain()
    end
    return object
end
function EffectLayer:getkillSpine(effectLevel)
    local EffectLevel = {
        EffectLevel_Primary = 1,
        EffectLevel_Middle = 2,
        EffectLevel_Senior = 3,
        EffectLevel_Explode = 4
    }
    if effectLevel > 4 then
        effectLevel = 4
    end
    if effectLevel == EffectLevel.EffectLevel_Primary then
        local boomEffect = self:getSpineByName("yuboomdeffect")
        boomEffect:setTimeScale(1)
        boomEffect:setScale(1.1)
        return boomEffect
    elseif effectLevel == EffectLevel.EffectLevel_Middle then
        local boomEffect = self:getSpineByName("yuboomceffect")
        boomEffect:setScale(1.0)
        return boomEffect
    elseif effectLevel == EffectLevel.EffectLevel_Senior then
        local boomEffect = self:getSpineByName("yuboombeffect")
        boomEffect:setScale(1.2)
        return boomEffect
    elseif effectLevel == EffectLevel.EffectLevel_Explode then
        local boomEffect = self:getSpineByName("yuboomeffect")
        boomEffect:setScale(1.5)
        return boomEffect
    else
        local boomEffect = self:getSpineByName("yuboomceffect")
        boomEffect:setScale(1.0)
        return boomEffect
    end
end
function EffectLayer:getSpriteByName(spriteName)
    local info = {
        ["coinImage"] = {TEXTURE_PATH = "ui/common/ico_Gold.png"},
        ["plusImage"] = {TEXTURE_PATH = "ui/common/jiafen.png"}
    }
    local spriteInfo = info[spriteName]
    local object = cc.Sprite:create(spriteInfo.TEXTURE_PATH)
    return object
end
function EffectLayer:createCoinNumber()
    local containerNode = cc.Node:create()
    containerNode:setOpacity(255)
    containerNode:setCascadeOpacityEnabled(true)
    local coinSprite = self:getSpriteByName("coinImage")
    coinSprite:setPosition(0, 0)
    coinSprite:setScale(0.9)
    coinSprite:setCascadeOpacityEnabled(true)
    coinSprite:setOpacity(255)
    containerNode:addChild(coinSprite, 2)
    containerNode.coinSprite = coinSprite
    local plusSprite = self:getSpriteByName("plusImage")
    plusSprite:setPosition(28, 0)
    plusSprite:setScale(1.0)
    plusSprite:setScale(0.6)
    plusSprite:setCascadeOpacityEnabled(true)
    plusSprite:setOpacity(255)
    containerNode:addChild(plusSprite, 2)
    containerNode.plusSprite = plusSprite
    local labelScore = ccui.TextAtlas:create("100000", "ui/ingame/scoreNumber/collect.png", 33, 49, "0")
    labelScore:setScale(0.55)
    labelScore:setAnchorPoint(0.0, 0.5)
    labelScore:setPosition(38, 0)
    labelScore:setOpacity(255)
    containerNode.labelScore = labelScore
    containerNode:addChild(labelScore, 2)
    containerNode.label = labelScore
    containerNode:setVisible(false)
    return containerNode
end
function EffectLayer:ShowFishGoldEx(fishPosition, coinPos, chairId, score, effectLevel)
    if score <= 0 then
        return
    end
    local animationNode = nil
    local freeNodes = self.freeAnimationNodes[effectLevel]
    local freeNumber = freeNodes.number
    if freeNumber > 0 then
        animationNode = freeNodes[freeNumber]
        freeNumber = freeNumber - 1
        freeNodes.number = freeNumber
    else
        animationNode = self:createFishGoldAnimation(effectLevel)
    end
    self:addChild(animationNode)
    if chairId == self.m_nChairID then
        animationNode.gold = true
    else
        animationNode.gold = false
    end
    animationNode:setPosition(fishPosition)
    animationNode.endPos = animationNode:convertToNodeSpace(coinPos)
    animationNode.effect = self.coinEffect[chairId]
    animationNode.effect:setPosition(coinPos)
    animationNode.particle = self.coinParticle[chairId]
    animationNode.particle:setPosition(coinPos)
    animationNode.label:setPosition(self.positionZero)
    if chairId == self.m_nChairID then
        animationNode.label:setBMFontFilePath("ui/gaofenText.fnt")
    else
        animationNode.label:setBMFontFilePath("ui/gaofenText2.fnt")
    end
    animationNode.label:setString(tostring(score))
    animationNode.coinNumber.label:setString(tostring(score))
    animationNode.coinNumber:setPosition(animationNode.endPos)
    local distance =
        math.sqrt(animationNode.endPos.x * animationNode.endPos.x + animationNode.endPos.y * animationNode.endPos.y)
    animationNode.speedScale = 600 / distance
    animationNode:runAction(animationNode.startAction)
    self.usedAnimationNodes[animationNode] = true
    ExternalFun.playSoundEffectCommon("sound/effect/sfx_coin.mp3")
end
function EffectLayer:createFishGoldAnimation(effectLevel)
    local goldNumber = self.CoinNumber[effectLevel]
    local animationNode = cc.Node:create()
    animationNode:retain()
    animationNode.goldNumber = goldNumber
    animationNode.coins = {}
    animationNode.counter = 0
    animationNode.gold = true
    local maxDuration = 0
    for i = 1, goldNumber do
        local dcc = 550
        local speed = 0
        local jumpScale = 0
        if effectLevel == 0 then
            speed = 30 + 350 * math.random() * 0.22
            jumpScale = 0.8 - 0.4 * math.random()
        elseif effectLevel > 0 then
            speed = 150 + 350 * math.random() * self.SpeedScale[effectLevel]
            jumpScale = 1.0 - 0.5 * math.random()
        end
        local duration = speed / dcc
        local distance = speed * duration - 0.5 * dcc * duration * duration
        local angle = math.pi * 2 * math.random()
        local animateGold = self:getFrameAnimationByName("fish_jinbi_gold")
        local animateSilver = self:getFrameAnimationByName("fish_jinbi_silver")
        local coin = cc.Sprite:createWithSpriteFrameName("fish_jinbi4_1.png")
        coin:setScale(0.2)
        coin:setOpacity(0)
        coin.animateGold = animateGold
        coin.animateSilver = animateSilver
        animationNode:addChild(coin, 2)
        coin.collectMove = cc.MoveTo:create(0.3, self.positionZero)
        coin.collectAction =
            cc.Speed:create(
            cc.Sequence:create(
                cc.EaseSineIn:create(
                    cc.Spawn:create(
                        coin.collectMove,
                        cc.Sequence:create(cc.DelayTime:create(0.15), cc.ScaleTo:create(0.15, 0.4))
                    )
                ),
                cc.CallFunc:create(
                    function()
                        coin:setVisible(false)
                        animationNode.effect:setAnimation(0, "animation", false)
                        animationNode.particle:resetSystem()
                        animationNode.counter = animationNode.counter + 1
                        if animationNode.counter == animationNode.goldNumber then
                            animationNode.coinNumber:setVisible(true)
                            animationNode.coinNumber:runAction(animationNode.coinNumberAction)
                        end
                    end
                )
            ),
            1.0
        )
        coin.collectAction:retain()
        coin.spreadAction =
            cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeTo:create(duration / 9, 255),
                cc.ScaleTo:create(duration / 4, 0.75),
                cc.EaseExponentialOut:create(
                    cc.MoveBy:create(duration, cc.p(distance * math.cos(angle), distance * math.sin(angle)))
                ),
                cc.Sequence:create(
                    cc.EaseSineOut:create(cc.MoveBy:create(0.2 * jumpScale, cc.p(0, 180 * jumpScale))),
                    cc.EaseSineIn:create(cc.MoveBy:create(0.2 * jumpScale, cc.p(0, -180 * jumpScale))),
                    cc.EaseSineOut:create(cc.MoveBy:create(0.15 * jumpScale, cc.p(0, 60 * jumpScale))),
                    cc.EaseSineIn:create(cc.MoveBy:create(0.15 * jumpScale, cc.p(0, -60 * jumpScale))),
                    cc.EaseSineOut:create(cc.MoveBy:create(0.1 * jumpScale, cc.p(0, 10 * jumpScale))),
                    cc.EaseSineIn:create(cc.MoveBy:create(0.1 * jumpScale, cc.p(0, -10 * jumpScale))),
                    cc.EaseSineOut:create(cc.MoveBy:create(0.066 * jumpScale, cc.p(0, 5 * jumpScale))),
                    cc.EaseSineIn:create(cc.MoveBy:create(0.066 * jumpScale, cc.p(0, -5 * jumpScale))),
                    cc.EaseSineOut:create(cc.MoveBy:create(0.066 * jumpScale, cc.p(0, 5 * jumpScale))),
                    cc.EaseSineIn:create(cc.MoveBy:create(0.066 * jumpScale, cc.p(0, -5 * jumpScale))),
                    cc.CallFunc:create(
                        function()
                            coin:runAction(coin.collectAction)
                        end
                    )
                )
            )
        )
        coin.spreadAction:retain()
        animationNode.coins[i] = coin
        if duration > maxDuration then
            maxDuration = duration
        end
    end
    local spine = self:getkillSpine(effectLevel)
    animationNode:addChild(spine, 1)
    animationNode.spine = spine
    local labelScore = cc.Label:createWithBMFont("ui/gaofenText.fnt", "")
    labelScore:setScale(0.7)
    labelScore:setAnchorPoint(0.5, 0.5)
    labelScore:setString(tonumber(999999))
    labelScore:setOpacity(0)
    animationNode:addChild(labelScore, 2)
    animationNode.label = labelScore
    animationNode.coinNumber = self:createCoinNumber()
    animationNode:addChild(animationNode.coinNumber)
    animationNode.labelAction =
        cc.Sequence:create(
        cc.Spawn:create(cc.EaseSineOut:create(cc.MoveBy:create(0.25, cc.p(0, 35))), cc.FadeTo:create(0.1, 255)),
        cc.DelayTime:create(0.6),
        cc.Spawn:create(cc.FadeTo:create(0.3, 0), cc.EaseSineIn:create(cc.MoveBy:create(0.3, cc.p(0, 15)))),
        cc.MoveBy:create(0.016, cc.p(0, -30)),
        cc.CallFunc:create(
            function()
                animationNode.label:setVisible(false)
            end
        )
    )
    animationNode.labelAction:retain()
    animationNode.coinNumberAction =
        cc.Sequence:create(
        cc.Spawn:create(cc.EaseSineOut:create(cc.MoveBy:create(0.25, cc.p(0, 30))), cc.FadeTo:create(0.1, 255)),
        cc.DelayTime:create(0.3),
        cc.Spawn:create(cc.FadeTo:create(0.3, 0), cc.EaseSineIn:create(cc.MoveBy:create(0.3, cc.p(0, 15)))),
        cc.CallFunc:create(
            function()
                animationNode.coinNumber:setVisible(false)
            end
        )
    )
    animationNode.coinNumberAction:retain()
    animationNode.startAction =
        cc.Sequence:create(
        cc.CallFunc:create(
            function()
                for i = 1, goldNumber do
                    local coin = animationNode.coins[i]
                    coin:setPosition(self.positionZero)
                    coin:setScale(0.2)
                    coin:setOpacity(0)
                    coin:setVisible(true)
                    coin.collectMove:initWithDuration(0.3, animationNode.endPos)
                    coin.collectAction:setSpeed(animationNode.speedScale)
                    coin:runAction(coin.spreadAction)
                    if animationNode.gold then
                        coin:runAction(coin.animateGold)
                    else
                        coin:runAction(coin.animateSilver)
                    end
                end
                animationNode.spine:setVisible(true)
                animationNode.spine:setAnimation(0, "animation", false)
                animationNode.label:setVisible(true)
                animationNode.label:setOpacity(255)
                animationNode.label:runAction(animationNode.labelAction)
                animationNode.coinNumber:setVisible(true)
                animationNode.coinNumber:setOpacity(0)
                animationNode.counter = 0
            end
        ),
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(
            function()
                animationNode.spine:setVisible(false)
            end
        ),
        cc.DelayTime:create(maxDuration + 1.5 - 0.4 + 0.5),
        cc.CallFunc:create(
            function()
                animationNode:removeFromParent()
                local freeNodes = self.freeAnimationNodes[effectLevel]
                local freeNumber = freeNodes.number
                if freeNumber >= freeNodes.maxNumber then
                    self:recycleFishCoinNode(animationNode)
                else
                    freeNumber = freeNumber + 1
                    freeNodes[freeNumber] = animationNode
                    freeNodes.number = freeNumber
                end
                self.usedAnimationNodes[animationNode] = nil
            end
        )
    )
    animationNode.startAction:retain()
    return animationNode
end
function EffectLayer:recycleFishCoinNode(animationNode)
    if animationNode.labelAction then
        animationNode.labelAction:release()
    end
    if animationNode.coinNumberAction then
        animationNode.startAction:release()
    end
    if animationNode.coinNumberAction then
        animationNode.coinNumberAction:release()
    end
    for i = 1, animationNode.goldNumber do
        local coin = animationNode.coins[i]
        coin.collectAction:release()
        coin.spreadAction:release()
        coin:removeFromParent()
    end
    animationNode:release()
end
return EffectLayer
