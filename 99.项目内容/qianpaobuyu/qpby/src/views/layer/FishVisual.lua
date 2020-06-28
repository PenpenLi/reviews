local FishVisual =
    class(
    "FishVisual",
    function()
        local visualNode = cc.Node:create()
        return visualNode
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function FishVisual:ctor(fishData)
    self:setCascadeOpacityEnabled(true)
    self:enableNodeEvents()
    self.fishData = fishData
    self.model = nil
    self.bindModel = nil
    self.isPlayHurt = false
    self.isDead = false
    self.effecTable = {}
    self.path = {}
    self.delayT = 0.0
    self.pointIdx = 3
    self.hp = 100
    self.isTroop = false
    self.troopId = 0
    self.isPoint = false
    self.isRemove = false
    self.isStop = false
    self._updateDelta = 0
    self:loadModelsAsync()
end
function FishVisual:setPath(pathTable)
    self.pointIdx = 3
    self.path = pathTable
end
function FishVisual:loadModels()
    local showScale = self.fishData.Model.Scale or 1.0
    local fileName = string.format("model/%s/%s.c3b", self.fishData.Model.resName, self.fishData.Model.resName)
    local model =
        cc.Sprite3D:create(fileName):setScale(showScale):setPosition3D(cc.vec3(0, 0, 0)):setRotation3D(cc.vec3(0, 0, 0)):addTo(
        self,
        2
    ):setGlobalZOrder(0):setCascadeOpacityEnabled(true)
    self.model = model
    if self.fishData.BindModel then
        local parentNode = self.model:getAttachNode(self.fishData.BindModel.bindingPoint)
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
            local bindModel =
                cc.Sprite3D:create(bindName):setScale(self.fishData.BindModel.Scale):setPosition3D(pos3D):setRotation3D(
                cc.vec3(0, 0, 0)
            ):addTo(parentNode, 2)
            self.bindModel = bindModel
        end
    end
    self.VisualID = self.fishData.VisualID
    self:loadEffects()
    self:changeNormalAction()
end
function FishVisual:loadModelsAsync()
    local showScale = self.fishData.Model.Scale or 1.0
    local fileName = string.format("model/%s/%s.c3b", self.fishData.Model.resName, self.fishData.Model.resName)
    self:hide()
    cc.Sprite3D:createAsync(
        fileName,
        function(model)
            model:setScale(showScale):setPosition3D(cc.vec3(0, 0, 0)):setRotation3D(cc.vec3(0, 0, 0)):addTo(self, 2):setGlobalZOrder(
                0
            ):setCascadeOpacityEnabled(true)
            self.model = model
            if self.fishData.BindModel then
                local parentNode = self.model:getAttachNode(self.fishData.BindModel.bindingPoint)
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
                        string.format(
                        "model/%s/%s.c3b",
                        self.fishData.BindModel.resName,
                        self.fishData.BindModel.resName
                    )
                    local bindModel =
                        cc.Sprite3D:create(bindName):setScale(self.fishData.BindModel.Scale):setPosition3D(pos3D):setRotation3D(
                        cc.vec3(0, 0, 0)
                    ):addTo(parentNode, 2)
                    self.bindModel = bindModel
                end
            end
            self.VisualID = self.fishData.VisualID
            self:loadEffects()
            self:changeNormalAction()
        end
    )
end
function FishVisual:loadEffects()
    if self.fishData.Effect then
        for i = 1, #self.fishData.Effect do
            local effectInfo = self.fishData.Effect[i]
            local effecNode = self:addEffectById(effectInfo, self.model)
            table.insert(self.effecTable, effecNode)
        end
    end
end
function FishVisual:addEffectById(effectInfo, modelNode)
    if effectInfo.Id == "3" then
        return
    end
    local offsetX = effectInfo.offsetX or 0
    local posX = offsetX
    local offsetY = effectInfo.OffsetY or 0
    local posY = offsetY
    local offsetZ = effectInfo.OffsetZ or 0
    local posZ = offsetZ
    local pos3D = cc.vec3(posX, posY, posZ)
    local effectNode = nil
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
    local parentNode = nil
    if not effectInfo.bindingPoint then
        parentNode = self
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
function FishVisual:changeNormalAction()
    local fishName = self.fishData.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    self.model:stopActionByTag(999)
    self.model:setColor(cc.c3b(255, 255, 255))
    local fform = tonumber(self.fishData.Model.Live[1].ffrom)
    local ffto = tonumber(self.fishData.Model.Live[1].fto)
    local from = fform / 30
    local to = ffto / 30
    local liveAction = cc.Animation3D:create(fileName)
    local live = cc.RepeatForever:create(cc.Animate3D:create(liveAction, from, to - from))
    live:setTag(999)
    self.model:runAction(live)
end
function FishVisual:changeHurtAction()
    local fishName = self.fishData.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    if not self.fishData.Model.Hurt then
        self.model:runAction(
            cc.Sequence:create(
                cc.TintTo:create(0.0, cc.c3b(255, 130, 130)),
                cc.TintTo:create(0.8, cc.c3b(255, 255, 255))
            )
        )
        return
    end
    if self.isPlayHurt then
        return
    end
    if tolua.isnull(self.model) then
        return
    end
    self.model:stopActionByTag(999)
    self.model:setColor(cc.c3b(255, 255, 255))
    self.isPlayHurt = true
    local fform = tonumber(self.fishData.Model.Hurt[1].ffrom)
    local ffto = tonumber(self.fishData.Model.Hurt[1].fto)
    local from = fform / 30
    local to = ffto / 30
    local hurtAction = cc.Animation3D:create(fileName)
    local hurt =
        cc.Sequence:create(
        cc.Animate3D:create(hurtAction, from, to - from),
        cc.CallFunc:create(
            function()
                self.isPlayHurt = false
                self:changeNormalAction()
            end
        )
    )
    hurt:setTag(999)
    self.model:runAction(hurt)
    self.model:runAction(
        cc.Sequence:create(cc.TintTo:create(0.0, cc.c3b(255, 130, 130)), cc.TintTo:create(0.8, cc.c3b(255, 255, 255)))
    )
end
function FishVisual:changeDeadAction()
    local fishName = self.fishData.Model.resName
    local fileName = string.format("model/%s/%s.c3b", fishName, fishName)
    if nil == fishName or "" == fishName then
        return
    end
    self.model:stopActionByTag(999)
    self.model:setColor(cc.c3b(255, 255, 255))
    self.isDead = true
    if self.fishData.Model.Die then
        local fform = tonumber(self.fishData.Model.Die[1].ffrom)
        local ffto = tonumber(self.fishData.Model.Die[1].fto)
        local from = fform / 30
        local to = ffto / 30
        local deadAnimation = cc.Animation3D:create(fileName)
        local dead = cc.Animate3D:create(deadAnimation, from, to - from)
        local fade = cc.FadeTo:create(to - from, 0)
        local disappear = cc.Spawn:create(dead, fade)
        local finish =
            cc.CallFunc:create(
            function()
                self.isRemove = true
            end
        )
        self.model:runAction(cc.Sequence:create(disappear, finish))
    else
        local fade = cc.FadeTo:create(0.3, 0)
        local finish =
            cc.CallFunc:create(
            function()
                self.isRemove = true
            end
        )
        self.model:runAction(cc.Sequence:create(fade, finish))
    end
end
function FishVisual:onEnter()
end
function FishVisual:update(dt)
    if tolua.isnull(self.model) then
        return
    end
    if self.isDead then
        return
    end
    if self.hp <= 0 then
        self.isDead = true
        self:changeDeadAction()
        return
    end
    if self:getParent().scene.bFishStop then
        return
    end
    if self.isStop then
        return
    end
    if #self.path < 1 then
        return
    end
    local startPos = self:getPosition3D()
    local endPos = cc.vec3(0, 0, 0)
    local newQuat = cc.quaternion(0, 0, 0, 1)
    local goLineTime = 12
    if self.isTroop then
        local scatterSpeed = 15
        local interval = 20
        endPos = pathMathCircleMovePos(goLineTime, dt, scatterSpeed, 20, self.troopId, startPos)
        if startPos.x > display.width + 350 or startPos.y > display.height + 100 then
            self.isDead = true
            self.isRemove = true
            return
        end
    elseif self.isPoint then
        endPos = pathMathLineMovePos(goLineTime, dt, startPos)
        if startPos.x > display.width + 350 or startPos.y > display.height + 100 then
            self.isDead = true
            self.isRemove = true
            return
        end
    else
        self.delayT = self.delayT + self._updateDelta * dt
        if self.delayT > 1.0 then
            self.pointIdx = self.pointIdx + 1
            if self.pointIdx > #self.path then
                self.isDead = true
                self.isRemove = true
                return
            end
            self.delayT = self.delayT - 1.0
        end
        local p0 = self.path[self.pointIdx - 2]
        local p1 = self.path[self.pointIdx - 1]
        local p2 = self.path[self.pointIdx]
        local length = pathMathGetLength(p0, p1, p2, 5)
        self._updateDelta = self.fishData.Speed / length
        endPos = pathMathGetInterpolatedPt(p0, p1, p2, self.delayT)
        newQuat = pathMathGetDirection(startPos, endPos)
    end
    self.model:setRotationQuat(newQuat)
    self:setPosition3D(endPos)
    if not self:isVisible() then
        if startPos.x == 0 and startPos.y == 0 and startPos.z == 0 and endPos.x ~= 0 and endPos.y ~= 0 and endPos.z ~= 0 then
            self:show()
        end
    end
end
return FishVisual
