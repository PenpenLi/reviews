local GameWikiDetailLayer =
    class(
    "GameWikiDetailLayer",
    function()
        return display.newLayer(cc.c4b(0, 0, 0, 125))
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
function GameWikiDetailLayer:ctor(parentNode, scene, fishType, fishIndex)
    self.parentNode = parentNode
    self.scene = scene
    self.fishIndex = fishIndex
    self.fishType = fishType
    self.fishMax = self.scene.configMgr:getWikiDataCountByType(fishType)
    self.effecTable = {}
    self:enableNodeEvents()
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(
        function(event, x, y)
            if event == "ended" then
                self:onClose()
            end
            return true
        end
    )
    self:initUI()
    self:loadFish()
    self:registerEvent()
    self._currentRotation = 0
end
function GameWikiDetailLayer:registerEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.detailBg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.detailBg)
end
function GameWikiDetailLayer:onTouchBegan(touch, event)
    self._lastTouchPos = self.detailBg:convertToNodeSpace(touch:getLocation())
    return self._lastTouchPos.x > 21 and self._lastTouchPos.x < 928 and self._lastTouchPos.y > 36 and
        self._lastTouchPos.y < 554
end
function GameWikiDetailLayer:getQuatByRotation(rotation)
    local axis = cc.vec3(0, 1, 0)
    local angle = rotation * 0.0174532923716197
    local sinHalfAngle = math.sin(angle * 0.5)
    local qx = axis.x * sinHalfAngle
    local qy = axis.y * sinHalfAngle
    local qz = axis.z * sinHalfAngle
    local qw = math.cos(angle * 0.5)
    local quat = {x = qx, y = qy, z = qz, w = qw}
    return quat
end
function GameWikiDetailLayer:onTouchMoved(touch, event)
    if self.fish then
        self._currentTouchPos = self.detailBg:convertToNodeSpace(touch:getLocation())
        local angleOffset = (self._currentTouchPos.x - self._lastTouchPos.x) / 600 * 360
        self._currentRotation = self._currentRotation + angleOffset
        local quat = self:getQuatByRotation(self._currentRotation)
        if not tolua.isnull(self.fish.model) then
            self.fish.model:setRotationQuat(quat)
        elseif self.fish.visuals then
            for i = 1, #self.fish.visuals do
                if not tolua.isnull(self.fish.visuals[i]) then
                    self.fish.visuals[i].model:setRotationQuat(quat)
                end
            end
        end
        self._lastTouchPos = self._currentTouchPos
    end
end
function GameWikiDetailLayer:onTouchEnded(touch, event)
end
function GameWikiDetailLayer:onEnter()
    self:showLayer()
end
function GameWikiDetailLayer:initUI()
    self.detailBg =
        display.newSprite("ui/wiki/tujian_yulan_bg.png"):setPosition(display.cx, display.cy):setAnchorPoint(0.5, 0.5):setCascadeOpacityEnabled(
        true
    ):addTo(self)
    self.detailBgSize = self.detailBg:getContentSize()
    local btnClose =
        ccui.Button:create("ui/wiki/tujian_yulan_colse.png"):setPosition(
        self.detailBgSize.width / 2 + 406,
        self.detailBgSize.height / 2 + 223
    ):addTo(self.detailBg)
    btnClose:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:onClose()
            end
        end
    )
    local btnRight =
        ccui.Button:create("ui/wiki/tujian_yulan_Btn_right_B.png"):setPosition(
        self.detailBgSize.width / 2 + 342,
        self.detailBgSize.height / 2 + 35
    ):addTo(self.detailBg)
    btnRight:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self.fishIndex = self.fishIndex + 1
                if self.fishIndex > self.fishMax then
                    self.fishIndex = 1
                end
                self:loadFish()
            end
        end
    )
    local btnLeft =
        ccui.Button:create("ui/wiki/tujian_yulan_Btn_left_B.png"):setPosition(
        self.detailBgSize.width / 2 - 347,
        self.detailBgSize.height / 2 + 35
    ):addTo(self.detailBg)
    btnLeft:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self.fishIndex = self.fishIndex - 1
                if self.fishIndex < 1 then
                    self.fishIndex = self.fishMax
                end
                self:loadFish()
            end
        end
    )
end
function GameWikiDetailLayer:loadFish()
    self.fishData = self.scene.configMgr:getFishWikiData(self.fishType, self.fishIndex)
    local showScale = self.fishData.Model.Scale or 1.0
    local scoreStr = string.format("x%sb", self.fishData.wikiScore)
    if not tolua.isnull(self.betText) then
        self.betText:removeFromParent()
    end
    self.betText =
        self:getRichText(scoreStr):setPosition(
        self.detailBgSize.width / 2 - 421,
        self.detailBgSize.height / 2 - 162 - 20
    ):addTo(self.detailBg)
    local desStr = string.format("描述：%s", self.fishData.wikiIntroduction)
    if not tolua.isnull(self.textDes) then
        self.textDes:removeFromParent()
    end
    self.textDes =
        ccui.Text:create():setFontSize(22):setFontName("fonts/round_body.ttf"):setTextColor(cc.c3b(255, 255, 255)):setPosition(
        self.detailBgSize.width / 2 - 421,
        self.detailBgSize.height / 2 - 162 - 20 - 22 - 5
    ):setAnchorPoint(0, 0.5):addTo(self.detailBg):setString(desStr)
    local fileName = string.format("model/%s/%s.c3b", self.fishData.Model.resName, self.fishData.Model.resName)
    if not tolua.isnull(self.fish) then
        self.fish:stopAllActions()
        self.fish:removeFromParent()
    end
    for i = 1, #self.effecTable do
        if not tolua.isnull(self.effecTable[i]) then
            self.effecTable[i]:removeFromParent()
        end
    end
    if self.fishData.VisualID == "803" then
        self:loadTrippleFish()
    elseif self.fishData.VisualID == "703" then
        self:loadDoubleFish()
    else
        local offsetX = self.fishData.wikiOffsetX or 0
        local posX = self.detailBgSize.width / 2 + offsetX
        local offsetY = self.fishData.wikiOffsetY or 0
        local posY = self.detailBgSize.height / 2 + offsetY
        self.fish =
            cc.Node:create():setCascadeOpacityEnabled(true):setPosition3D(cc.vec3(posX, posY, 0)):addTo(self.detailBg)
        local model =
            cc.Sprite3D:create(fileName):setScale(self.fishData.wikiScale * showScale):setForce2DQueue(true):setPosition3D(
            cc.vec3(0, 0, 0)
        ):setRotation3D(cc.vec3(0, 0, 0)):addTo(self.fish):setGlobalZOrder(0)
        model:setCascadeOpacityEnabled(true)
        self.fish.model = model
        if self.fishData.Effect then
            for i = 1, #self.fishData.Effect do
                local effectInfo = self.fishData.Effect[i]
                local effecNode = self:addEffectById(effectInfo, self.fish.model)
                effecNode:setCameraMask(cc.CameraFlag.USER1)
                table.insert(self.effecTable, effecNode)
            end
        end
        if self.fishData.BindModel then
            local parentNode = self.fish.model:getAttachNode(self.fishData.BindModel.bindingPoint)
            parentNode:setCascadeOpacityEnabled(true)
            if not tolua.isnull(parentNode) then
                local offsetX = self.fishData.BindModel.offsetX or 0
                local posX = offsetX
                local offsetY = self.fishData.BindModel.OffsetY or 0
                local posY = offsetY
                local offsetZ = self.fishData.BindModel.OffsetZ or 0
                local posZ = offsetZ
                local pos3D = cc.vec3(posX, posY, posZ)
                local bindName =
                    string.format("model/%s/%s.c3b", self.fishData.BindModel.resName, self.fishData.BindModel.resName)
                local modelBind =
                    cc.Sprite3D:create(bindName):setScale(self.fishData.BindModel.Scale):setForce2DQueue(true):setPosition3D(
                    pos3D
                ):setRotation3D(cc.vec3(0, 0, 0)):addTo(parentNode)
            end
        end
        self.fish.visualId = self.fishData.VisualID
        self.fish.info = self.fishData
        self:playNormalAction(self.fish)
        self:playEffectAni(self.fish)
        self.fish:setCameraMask(cc.CameraFlag.USER1)
    end
    self:setCameraMask(cc.CameraFlag.USER1)
end
function GameWikiDetailLayer:addEffectById(effectInfo, modelNode)
    local offsetX = effectInfo.offsetX or 0
    local posX = offsetX
    local offsetY = effectInfo.OffsetY or 0
    local posY = offsetY
    local offsetZ = effectInfo.OffsetZ or 0
    local posZ = offsetZ
    local pos3D = cc.vec3(posX, posY, posZ)
    local effectNode = nil
    local parentNode = nil
    if not effectInfo.bindingPoint then
        parentNode = modelNode:getParent()
        pos3D = modelNode:getPosition3D()
    else
        parentNode = modelNode:getAttachNode(effectInfo.bindingPoint)
        if not parentNode then
            parentNode = modelNode:getParent()
            pos3D = modelNode:getPosition3D()
        else
            parentNode:setCascadeOpacityEnabled(true)
        end
    end
    if effectInfo.type == "particle" then
        local effPath = string.format("particle/%s.plist", effectInfo.resName)
        effectNode = cc.ParticleSystemQuad:create(effPath):setPosition3D(pos3D):setScale(effectInfo.Scale)
        if effectInfo.positionType == "2" then
            effectNode:setRotation3D(cc.vec3(-90, 0, 0))
        else
            effectNode:setRotation3D(cc.vec3(0, 0, 0))
        end
    else
        local jsonName = string.format("fish_effect/%s.json", effectInfo.resName)
        local atlasName = string.format("fish_effect/%s.atlas", effectInfo.resName)
        effectNode =
            sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition3D(pos3D):setAnimation(
            0,
            effectInfo.live,
            true
        ):setScale(effectInfo.Scale)
        if effectInfo.useRotation == "false" then
            effectNode:setRotation3D(cc.vec3(-90, 0, 0))
        elseif effectInfo.useRotation == "true" then
            effectNode:setRotation3D(cc.vec3(0, 0, 0))
        end
    end
    if effectInfo.depthLevel == "front" then
        effectNode:addTo(parentNode, 3)
    elseif effectInfo.depthLevel == "back" then
        effectNode:addTo(parentNode, 1)
    else
        effectNode:addTo(parentNode, 1)
    end
    effectNode.resName = effectInfo.resName
    return effectNode
end
function GameWikiDetailLayer:getEffecByResName(resName)
    for i = 1, #self.effecTable do
        if not tolua.isnull(self.effecTable[i]) and self.effecTable[i].resName == resName then
            return self.effecTable[i]
        end
    end
    return nil
end
function GameWikiDetailLayer:playNormalAction(fishNode)
    local fishName = fishNode.info.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    fishNode.model:setColor(cc.c3b(255, 255, 255))
    local fform = tonumber(fishNode.info.Model.Live[1].ffrom)
    local ffto = tonumber(fishNode.info.Model.Live[1].fto)
    local from = fform / 30
    local to = ffto / 30
    local liveAction = cc.Animation3D:create(fileName)
    local live = cc.RepeatForever:create(cc.Animate3D:create(liveAction, from, to - from))
    live:setTag(999)
    fishNode.model:runAction(live)
end
function GameWikiDetailLayer:playDeadAction(fishNode)
    local fishName = fishNode.info.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    fishNode.model:stopAllActions()
    fishNode.model:setColor(cc.c3b(255, 255, 255))
    if fishNode.info.Model.Die then
        local fform = tonumber(fishNode.info.Model.Die[1].ffrom)
        local ffto = tonumber(fishNode.info.Model.Die[1].fto)
        local from = fform / 30
        local to = ffto / 30
        local deadAnimation = cc.Animation3D:create(fileName)
        local dead = cc.Animate3D:create(deadAnimation, from, to - from)
        local fishDead =
            cc.CallFunc:create(
            function()
                fishNode.model:runAction(dead)
            end
        )
        local fade = cc.FadeTo:create(to - from, 0)
        local disappear = cc.Spawn:create(fishDead, fade)
        local finish =
            cc.CallFunc:create(
            function()
            end
        )
        fishNode:runAction(cc.Sequence:create(disappear, finish))
    else
        local fade = cc.FadeTo:create(0.3, 0)
        local finish =
            cc.CallFunc:create(
            function()
            end
        )
        fishNode:runAction(cc.Sequence:create(fade, finish))
    end
end
function GameWikiDetailLayer:playBlackholeDeadAction(fishNode)
    local fishName = fishNode.info.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    fishNode.model:stopAllActions()
    fishNode.model:setColor(cc.c3b(255, 255, 255))
    if fishNode.info.Model.Die then
        local fform = tonumber(fishNode.info.Model.Die[1].ffrom)
        local ffto = tonumber(fishNode.info.Model.Die[1].fto)
        local from = fform / 30
        local to = ffto / 30
        local deadAnimation = cc.Animation3D:create(fileName)
        local dead = cc.Animate3D:create(deadAnimation, from, to - from)
        local fishDead =
            cc.CallFunc:create(
            function()
                fishNode.model:runAction(dead)
            end
        )
        local fade = cc.FadeTo:create(to - from, 0)
        local disappear = cc.Spawn:create(fishDead, fade)
        local finish =
            cc.CallFunc:create(
            function()
                fishNode.model:removeFromParent()
                for i = 1, #self.effecTable do
                    if not tolua.isnull(self.effecTable[i]) then
                        self.effecTable[i]:removeFromParent()
                    end
                end
            end
        )
        fishNode.model:runAction(cc.Sequence:create(disappear, finish))
    else
        local fade = cc.FadeTo:create(0.3, 0)
        local finish =
            cc.CallFunc:create(
            function()
            end
        )
        fishNode:runAction(cc.Sequence:create(fade, finish))
    end
end
function GameWikiDetailLayer:playEffectAni(fishNode)
    if fishNode.visualId == "910" then
        self:loadFrozenFish(fishNode)
    elseif fishNode.visualId == "920" then
        self:loadDynamiteFish(fishNode)
    elseif fishNode.visualId == "930" then
        self:loadBlackholeFish(fishNode)
    elseif fishNode.visualId == "940" then
        self:loadLightningFish(fishNode)
    elseif fishNode.visualId == "616" then
        self:loadKingFish(fishNode)
    elseif fishNode.visualId == "606" then
        self:loadKingFish(fishNode)
    elseif fishNode.visualId == "803" then
    elseif fishNode.visualId == "703" then
    end
end
function GameWikiDetailLayer:loadFrozenFish(fishNode)
    fishNode:setOpacity(0)
    fishNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 150, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(150, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            local frozenParticle =
                sp.SkeletonAnimation:create(
                "fish_effect/bingdongyueffect.json",
                "fish_effect/bingdongyueffect.atlas",
                1.0
            ):setAnimation(0, "start", false):addAnimation(0, "end", false):setScale(0.5):addTo(fishNode):setCameraMask(
                cc.CameraFlag.USER1
            )
        end
    )
    local showEffectDelay = cc.DelayTime:create(3.3)
    local killCall =
        cc.CallFunc:create(
        function()
            self:playDeadAction(fishNode)
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    fishNode:runAction(presentSequence)
    fishNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadDynamiteFish(fishNode)
    fishNode:setOpacity(0)
    fishNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 150, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(150, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
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
            fishNode:runAction(
                cc.Sequence:create(
                    cc.Sequence:create(shakeStart),
                    cc.Repeat:create(cc.Sequence:create(shakeIdle), 6),
                    cc.Sequence:create(shakeEnd)
                )
            )
            local effec = self:getEffecByResName("zhadanyueffect")
            if not tolua.isnull(effec) then
                effec:clearTracks()
                effec:setAnimation(1, "end", false)
            end
        end
    )
    local showEffectDelay = cc.DelayTime:create(36 * 0.033)
    local killCall =
        cc.CallFunc:create(
        function()
            self:playDeadAction(fishNode)
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    fishNode:runAction(presentSequence)
    fishNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadBlackholeFish(fishNode)
    fishNode:setOpacity(0)
    fishNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 150, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(150, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            self:playBlackholeDeadAction(fishNode)
            local frozenParticle =
                sp.SkeletonAnimation:create("fish_effect/heidongyu.json", "fish_effect/heidongyu.atlas", 1.0):setAnimation(
                0,
                "start",
                false
            ):setAnimation(0, "idle2", false):addAnimation(0, "end", false):setScale(0.5):addTo(fishNode):setCameraMask(
                cc.CameraFlag.USER1
            )
        end
    )
    local showEffectDelay = cc.DelayTime:create(3.3)
    local killCall =
        cc.CallFunc:create(
        function()
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    fishNode:runAction(presentSequence)
    fishNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadLightningFish(fishNode)
    local showPosition = {[1] = cc.p(150, 100), [2] = cc.p(-200, 50), [3] = cc.p(-50, -100)}
    fishNode:setOpacity(0)
    fishNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 150, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(150, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            self:playDeadAction(fishNode)
            local showIndex = 1
            local effectTrigger =
                cc.CallFunc:create(
                function()
                    local centerPosition = cc.p(0, 0)
                    local fishPosition = showPosition[showIndex]
                    local distanceToCenter = cc.pGetDistance(fishPosition, centerPosition) + 30
                    local rotation = math.atan2(fishPosition.x, fishPosition.y)
                    local lineAnimation =
                        sp.SkeletonAnimation:create(
                        "fish_effect/shandianyushandian.json",
                        "fish_effect/shandianyushandian.atlas",
                        1.0
                    ):setPosition(fishPosition.x / 2, fishPosition.y / 2):setAnimation(0, "start", false):addAnimation(
                        0,
                        "idle",
                        false
                    ):addAnimation(0, "end", false):setScaleX(distanceToCenter / 720):setRotation(
                        rotation * 180 / math.pi - 90
                    ):addTo(fishNode):setCameraMask(cc.CameraFlag.USER1)
                    local targetAnimation =
                        sp.SkeletonAnimation:create(
                        "fish_effect/shandianyudianqiu.json",
                        "fish_effect/shandianyudianqiu.atlas",
                        1.0
                    ):setPosition(fishPosition):setAnimation(0, "start", false):addAnimation(0, "idle", false):addAnimation(
                        0,
                        "end",
                        false
                    ):setAnchorPoint(0.0, 0.0):setScale(0.8):addTo(fishNode):setCameraMask(cc.CameraFlag.USER1)
                    showIndex = showIndex + 1
                end
            )
            fishNode:runAction(cc.Repeat:create(cc.Sequence:create(effectTrigger, cc.DelayTime:create(0.066)), 3))
        end
    )
    local showEffectDelay = cc.DelayTime:create(1.6)
    local killCall =
        cc.CallFunc:create(
        function()
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    fishNode:runAction(presentSequence)
    fishNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadKingFish(fishNode)
    local showPosition = {[1] = cc.p(150, 100), [2] = cc.p(-200, 50), [3] = cc.p(-50, -100)}
    fishNode:setOpacity(0)
    fishNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 150, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(150, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            self:playDeadAction(fishNode)
            local frozenParticle =
                sp.SkeletonAnimation:create("fish_effect/yuwangtyeffect.json", "fish_effect/yuwangtyeffect.atlas", 1.0):setAnimation(
                0,
                "end",
                false
            ):setScale(0.6):addTo(fishNode)
            local showIndex = 1
            local effectTrigger =
                cc.CallFunc:create(
                function()
                    local centerPosition = cc.p(0, 0)
                    local fishPosition = showPosition[showIndex]
                    local distanceToCenter = cc.pGetDistance(fishPosition, centerPosition) + 30
                    local rotation = math.atan2(fishPosition.x, fishPosition.y)
                    fishNode:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.2),
                            cc.CallFunc:create(
                                function()
                                    local lineAnimation =
                                        sp.SkeletonAnimation:create(
                                        "fish_effect/yuwangshandian.json",
                                        "fish_effect/yuwangshandian.atlas",
                                        1.0
                                    ):setPosition(fishPosition.x / 2, fishPosition.y / 2):setAnimation(
                                        0,
                                        "animation",
                                        false
                                    ):setScaleX(distanceToCenter / 720):setRotation(rotation * 180 / math.pi - 90):addTo(
                                        fishNode
                                    ):setCameraMask(cc.CameraFlag.USER1)
                                end
                            )
                        )
                    )
                    fishNode:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.266),
                            cc.CallFunc:create(
                                function()
                                    local targetAnimation =
                                        sp.SkeletonAnimation:create(
                                        "fish_effect/yuwangtyeffect.json",
                                        "fish_effect/yuwangtyeffect.atlas",
                                        1.0
                                    ):setPosition(fishPosition):setAnimation(0, "end", false):setAnchorPoint(0.0, 0.0):setScale(
                                        0.5
                                    ):addTo(fishNode):setCameraMask(cc.CameraFlag.USER1)
                                end
                            )
                        )
                    )
                    showIndex = showIndex + 1
                end
            )
            fishNode:runAction(cc.Repeat:create(cc.Sequence:create(effectTrigger, cc.DelayTime:create(0.066)), 3))
        end
    )
    local showEffectDelay = cc.DelayTime:create(0.4)
    local killCall =
        cc.CallFunc:create(
        function()
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    fishNode:runAction(presentSequence)
    fishNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadFishWithConfig(visualId, parentNode)
    self.fishData = self.scene.configMgr:getFishDataByVisualId(visualId)
    local wikiInfo = self.scene.configMgr:getFishWikiInfo(self.fishType, self.fishIndex)
    self.fishData.wikiName = wikiInfo.name
    self.fishData.wikiScore = wikiInfo.score
    self.fishData.wikiIntroduction = wikiInfo.introduction
    self.fishData.wikiScale = wikiInfo.modelScale or 1.0
    self.fishData.wikiOffsetX = wikiInfo.offsetX
    self.fishData.wikiOffsetY = wikiInfo.offsetY
    local showScale = self.fishData.Model.Scale or 1.0
    local fileName = string.format("model/%s/%s.c3b", self.fishData.Model.resName, self.fishData.Model.resName)
    local fish = cc.Node:create():setCascadeOpacityEnabled(true):addTo(parentNode)
    local model =
        cc.Sprite3D:create(fileName):setScale(self.fishData.wikiScale * showScale):setForce2DQueue(true):setPosition3D(
        cc.vec3(0, 0, 0)
    ):setRotation3D(cc.vec3(0, 0, 0)):addTo(fish)
    fish.model = model
    if self.fishData.Effect then
        for i = 1, #self.fishData.Effect do
            local effectInfo = self.fishData.Effect[i]
            local effecNode = self:addEffectById(effectInfo, fish.model)
            effecNode:setCameraMask(cc.CameraFlag.USER1)
            table.insert(self.effecTable, effecNode)
        end
    end
    fish.visualId = self.fishData.VisualID
    fish.info = self.fishData
    self:playNormalAction(fish)
    fish:setCameraMask(cc.CameraFlag.USER1)
    return fish
end
function GameWikiDetailLayer:loadTrippleFish()
    if not tolua.isnull(self.fish) then
        self.fish:stopAllActions()
        self.fish:removeFromParent()
    end
    for i = 1, #self.effecTable do
        if not tolua.isnull(self.effecTable[i]) then
            self.effecTable[i]:removeFromParent()
        end
    end
    local contaierNode = cc.Node:create():addTo(self.detailBg)
    contaierNode:setCascadeOpacityEnabled(true)
    self.fish = contaierNode
    local showPosition = {
        [1] = cc.p(120, 70, 0),
        [2] = cc.p(-150, 40, 0),
        [3] = cc.p(30, -70, 0),
        [4] = cc.p(120, 70, 0)
    }
    local visuals = {
        [1] = self:loadFishWithConfig("803", contaierNode),
        [2] = self:loadFishWithConfig("808", contaierNode),
        [3] = self:loadFishWithConfig("806", contaierNode)
    }
    self.fish.visuals = visuals
    for i = 1, 3 do
        visuals[i]:setPosition3D(cc.vec3(showPosition[i].x, showPosition[i].y, 0))
    end
    contaierNode:setOpacity(0)
    contaierNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 100, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(100, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            for i = 1, 3 do
                local centerPosition = showPosition[i]
                local fishPosition = showPosition[i + 1]
                contaierNode:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(0.1),
                        cc.CallFunc:create(
                            function()
                                self:playDeadAction(visuals[i])
                            end
                        )
                    )
                )
                local distanceToCenter = cc.pGetDistance(fishPosition, centerPosition) + 60
                local rotation = math.atan2(fishPosition.x - centerPosition.x, fishPosition.y - centerPosition.y)
                local lineAnimation =
                    sp.SkeletonAnimation:create(
                    "fish_effect/yishisanniaoshandian.json",
                    "fish_effect/yishisanniaoshandian.atlas",
                    1.0
                ):setPosition((fishPosition.x + centerPosition.x) / 2, (fishPosition.y + centerPosition.y) / 2):setAnimation(
                    0,
                    "animation",
                    false
                ):setScaleX(distanceToCenter / 720):setRotation(rotation * 180 / math.pi - 90):addTo(contaierNode):setCameraMask(
                    cc.CameraFlag.USER1
                )
                local frozenParticle =
                    sp.SkeletonAnimation:create(
                    "fish_effect/yishisanniaob.json",
                    "fish_effect/yishisanniaob.atlas",
                    1.0
                ):setAnimation(0, "animation", false):setScale(0.8):setPosition(centerPosition):addTo(contaierNode):setCameraMask(
                    cc.CameraFlag.USER1
                )
            end
        end
    )
    local showEffectDelay = cc.DelayTime:create(0.4)
    local killCall =
        cc.CallFunc:create(
        function()
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadTrippleFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    contaierNode:runAction(presentSequence)
    contaierNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:loadDoubleFish()
    if not tolua.isnull(self.fish) then
        self.fish:stopAllActions()
        self.fish:removeFromParent()
    end
    for i = 1, #self.effecTable do
        if not tolua.isnull(self.effecTable[i]) then
            self.effecTable[i]:removeFromParent()
        end
    end
    local contaierNode = cc.Node:create():addTo(self.detailBg)
    contaierNode:setCascadeOpacityEnabled(true)
    self.fish = contaierNode
    local showPosition = {[1] = cc.p(100, 70), [2] = cc.p(-120, -40)}
    local visuals = {
        [1] = self:loadFishWithConfig("703", contaierNode),
        [2] = self:loadFishWithConfig("709", contaierNode)
    }
    for i = 1, 2 do
        visuals[i]:setPosition3D(cc.vec3(showPosition[i].x, showPosition[i].y, 0))
    end
    self.fish.visuals = visuals
    contaierNode:setOpacity(0)
    contaierNode:setPosition3D(cc.vec3(self.detailBgSize.width / 2 - 100, self.detailBgSize.height / 2, 0))
    local moveIn = cc.EaseSineOut:create(cc.MoveBy:create(2.0, cc.vec3(100, 0, 0)))
    local liveDelay = cc.DelayTime:create(1.0)
    local showEffectCall =
        cc.CallFunc:create(
        function()
            for i = 1, 2 do
                contaierNode:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(0.1),
                        cc.CallFunc:create(
                            function()
                                self:playDeadAction(visuals[i])
                            end
                        )
                    )
                )
            end
            local centerPosition = showPosition[1]
            local fishPosition = showPosition[2]
            local distanceToCenter = cc.pGetDistance(fishPosition, centerPosition) + 60
            local rotation = math.atan2(fishPosition.x - centerPosition.x, fishPosition.y - centerPosition.y)
            local lineAnimation =
                sp.SkeletonAnimation:create(
                "fish_effect/yijianshuangdiaoshandian.json",
                "fish_effect/yijianshuangdiaoshandian.atlas",
                1.0
            ):setPosition((fishPosition.x + centerPosition.x) / 2, (fishPosition.y + centerPosition.y) / 2):setAnimation(
                0,
                "animation",
                false
            ):setScaleX(distanceToCenter / 720):setRotation(rotation * 180 / math.pi - 90):addTo(contaierNode):setCameraMask(
                cc.CameraFlag.USER1
            )
            local frozenParticle =
                sp.SkeletonAnimation:create(
                "fish_effect/yijianshuangdiaob.json",
                "fish_effect/yijianshuangdiaob.atlas",
                1.0
            ):setAnimation(0, "animation", false):setScale(0.8):setPosition(centerPosition):addTo(contaierNode):setCameraMask(
                cc.CameraFlag.USER1
            )
            local frozenParticle =
                sp.SkeletonAnimation:create(
                "fish_effect/yijianshuangdiaob.json",
                "fish_effect/yijianshuangdiaob.atlas",
                1.0
            ):setAnimation(0, "animation", false):setScale(0.8):setPosition(fishPosition):addTo(contaierNode):setCameraMask(
                cc.CameraFlag.USER1
            )
        end
    )
    local showEffectDelay = cc.DelayTime:create(0.4)
    local killCall =
        cc.CallFunc:create(
        function()
        end
    )
    local killDelay = cc.DelayTime:create(1.3)
    local resetCall =
        cc.CallFunc:create(
        function()
            self:loadDoubleFish()
        end
    )
    local presentSequence =
        cc.Sequence:create(moveIn, liveDelay, showEffectCall, showEffectDelay, killCall, killDelay, resetCall)
    contaierNode:runAction(presentSequence)
    contaierNode:runAction(cc.FadeTo:create(0.2, 255))
end
function GameWikiDetailLayer:getRichText(textStr)
    local richTxt = ccui.RichText:create()
    local anPoint = cc.p(0, 0.5)
    richTxt:setAnchorPoint(anPoint)
    local elemText = ccui.RichElementText:create(-1, cc.c3b(255, 255, 255), 255, "倍数： ", "fonts/round_body.ttf", 22)
    richTxt:pushBackElement(elemText)
    local len = #textStr
    for i = 1, len do
        local contentStr = string.sub(textStr, i, i) or "0"
        if contentStr == "-" then
            contentStr = "zhi"
        elseif contentStr == "b" then
            contentStr = "bei"
        end
        local filePath = string.format("ui/wiki/number/beishu_%s.png", contentStr)
        local elem = ccui.RichElementImage:create(-1, cc.c3b(255, 255, 255), 255, filePath)
        richTxt:pushBackElement(elem)
    end
    richTxt:formatText()
    return richTxt
end
function GameWikiDetailLayer:showLayer()
    self.detailBg:setScale(0.8)
    self.detailBg:setOpacity(255 * 0)
    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.02)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local seq = cc.Sequence:create(spawn, reNormal)
    self.detailBg:runAction(seq)
end
function GameWikiDetailLayer:hideBg(callBack)
    self.detailBg:stopAllActions()
    self.detailBg:setScale(1.0)
    self.detailBg:setOpacity(255 * 1.0)
    local spawnTime = 0.1
    local moveUp = cc.MoveBy:create(spawnTime, cc.p(0, 20))
    local fadeOut = cc.FadeOut:create(spawnTime)
    local smaller = cc.ScaleTo:create(spawnTime, 0.8)
    local spawn = cc.Spawn:create(moveUp, fadeOut, smaller)
    local callFun =
        cc.CallFunc:create(
        function()
            if callBack then
                callBack()
            end
        end
    )
    local seq = cc.Sequence:create(spawn, callFun)
    self.detailBg:runAction(seq)
end
function GameWikiDetailLayer:onClose()
    local function callBack()
        self:stopAllActions()
        self:removeFromParent()
    end
    self:hideBg(callBack)
end
return GameWikiDetailLayer
