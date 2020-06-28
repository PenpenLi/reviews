local BackgroundLayer =
    class(
    "BackgroundLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function BackgroundLayer:ctor(parentNode)
    self.parentNode = parentNode
    self:enableNodeEvents()
    self.bubbleParticleList = {}
    self.senceIdx = 1
end
function BackgroundLayer:onEnter()
    self:changeScene(self.senceIdx)
end
function BackgroundLayer:switchScene()
    self.senceIdx = self.senceIdx + 1
    if self.senceIdx > 6 then
        self.senceIdx = 1
    end
    local waveContainer = cc.Node:create()
    waveContainer:setPosition(display.width + 200, display.height / 2)
    self:addChild(waveContainer, 2)
    for i = 0, 8 do
        local wave =
            sp.SkeletonAnimation:create(
            "animationex/effect_transition_water/transition_water.json",
            "animationex/effect_transition_water/transition_water.atlas",
            1
        )
        wave:setAnimation(0, "animation", true)
        wave:setPosition(50 + math.random() * 15, 375 - 90 * i)
        wave:setScale(0.6 + math.random() * 0.1)
        waveContainer:addChild(wave, 2)
    end
    local move = cc.MoveBy:create(5, cc.p(-display.width - 600, 0))
    local sequence = cc.Sequence:create(move, cc.RemoveSelf:create())
    waveContainer:runAction(sequence)
    local sceneInfo = self.sceneTable[self.senceIdx]
    local folderName = sceneInfo[1][1]
    local bgFile = sceneInfo[1][2]
    local bgBackFile = sceneInfo[1][3]
    local sprite = cc.Node:create()
    if nil ~= bgBackFile then
        bgBackFile = string.format("scene/%s/%s", folderName, bgBackFile)
        local bgBack = display.newSprite(bgBackFile):addTo(sprite, 0)
    end
    bgFile = string.format("scene/%s/%s", folderName, bgFile)
    local bg = display.newSprite(bgFile):addTo(sprite, 1)
    sprite:setName("last_image")
    sprite:setPosition(display.width / 2 * 3 + 200, display.height / 2)
    sprite:addTo(self)
    local move = cc.MoveBy:create(5 * (display.width + 200) / (display.width + 600), cc.p(-display.width - 200, 0))
    local sequence =
        cc.Sequence:create(
        move,
        cc.CallFunc:create(
            function()
                self:removeChildByName("last_image")
                self:changeScene(self.senceIdx)
            end
        )
    )
    sprite:runAction(sequence)
end
function BackgroundLayer:changeScene(sceneIdx)
    self.sceneTable = {
        {{"01_gu_dai_chen_chuan", "layer_2.jpg"}},
        {{"02_hai_di_dong_xue", "layer_2.png", "layer_4.jpg"}, {"02_hai_di_dong_xue"}},
        {{"03_hai_di_yi_ji", "layer_2.jpg"}},
        {{"04_hai_zao_cong_lin", "layer_2.png", "layer_4.jpg"}, {"04_hai_zao_cong_lin_layer_3"}},
        {{"05_pu_tong_shen_hai", "layer_2.jpg"}},
        {{"06_shan_hu_qian_hai", "layer_2.jpg"}}
    }
    local sceneInfo = self.sceneTable[sceneIdx]
    local folderName = sceneInfo[1][1]
    local bgFile = sceneInfo[1][2]
    local bgBackFile = sceneInfo[1][3]
    if nil ~= bgBackFile then
        bgBackFile = string.format("scene/%s/%s", folderName, bgBackFile)
        if tolua.isnull(self.bgBack) then
            self.bgBack = display.newSprite(bgBackFile):setPosition(display.cx, display.cy):addTo(self, 0)
        else
            self.bgBack:setTexture(bgBackFile)
        end
        self.bgBack:setGlobalZOrder(-1000)
    else
        if not tolua.isnull(self.bgBack) then
            self.bgBack:removeFromParent()
        end
    end
    bgFile = string.format("scene/%s/%s", folderName, bgFile)
    if tolua.isnull(self.bgBack) then
        self.bg = display.newSprite(bgFile):setPosition(display.cx, display.cy):addTo(self, 1)
    else
        self.bg:setTexture(bgFile)
    end
    self.bg:setGlobalZOrder(-1000)
    local jsonName = string.format("scene/%s/%s_layer_1.json", folderName, folderName)
    local atlasName = string.format("scene/%s/%s_layer_1.atlas", folderName, folderName)
    if not tolua.isnull(self.bgEffectNode) then
        self.bgEffectNode:removeFromParent()
    end
    self.bgEffectNode =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(display.cx, display.cy):addTo(self, 2):setAnimation(
        0,
        "animation",
        true
    )
    self.bgEffectNode:setGlobalZOrder(-1000)
    if not tolua.isnull(self.bgEffectNodeEx) then
        self.bgEffectNodeEx:removeFromParent()
    end
    if nil ~= sceneInfo[2] then
        local spineEx = sceneInfo[2][1]
        local jsonName = string.format("scene/%s/%s.json", folderName, spineEx)
        local atlasName = string.format("scene/%s/%s.atlas", folderName, spineEx)
        self.bgEffectNodeEx =
            sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(display.cx, display.cy):addTo(self, 2):setAnimation(
            0,
            "animation",
            true
        )
        self.bgEffectNodeEx:setGlobalZOrder(-1000)
    end
    local bubbleTable = {
        {{198, 75, -120, 0}, {1166, 161, -140, 1.5}, {1254, 433, -100, 2.5}},
        {{586, 34, -100, 0}, {1159, 86, -100, 2}},
        {{206, 51, -100, 1.5}, {634, 234, -100, 0}, {1059, 39, -100, 1.5}},
        {{248, 93, -100, 1}, {1098, 36, -100, 1}},
        {{159, 51, -100, 2}, {761, 94, -100, 1}, {1195, 212, -100, 2}},
        {{115, 293, -100, 2}, {684, 115, -100, 1}, {1231, 269, -200, 2}}
    }
    for i = 1, #self.bubbleParticleList do
        local bubble = self.bubbleParticleList[i]
        if not tolua.isnull(bubble) then
            bubble:removeFromParent()
        end
    end
    local bubbleSceneInfo = bubbleTable[sceneIdx]
    for i = 1, #bubbleSceneInfo do
        local bubbleInfo = bubbleSceneInfo[i]
        local bubblePos = cc.vec3(bubbleInfo[1], bubbleInfo[2], bubbleInfo[3])
        local delay = bubbleInfo[4]
        local function onParticleCreate()
            local particle =
                cc.ParticleSystemQuad:create("particle/3dby_hdqipao.plist"):setPosition3D(bubblePos):addTo(self, 2)
            table.insert(self.bubbleParticleList, particle)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(onParticleCreate)))
    end
end
function BackgroundLayer:onExit()
end
function BackgroundLayer:onCleanup()
end
return BackgroundLayer
