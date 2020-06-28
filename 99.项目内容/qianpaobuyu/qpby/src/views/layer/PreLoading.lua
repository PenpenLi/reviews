local PreLoading =
    class(
    "PreLoading",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
function PreLoading:ctor()
    self:setCascadeOpacityEnabled(true)
    self:enableNodeEvents()
    self:createSpineLogo()
    self:initUI()
    self:initListener()
end
function PreLoading:createSpineLogo()
    local jsonName = "animationex/spine/by_loading/by_loading.json"
    local atlasName = "animationex/spine/by_loading/by_loading.atlas"
    self.effectNode =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(display.cx, display.cy):addTo(self):setAnimation(
        0,
        "idle",
        true
    )
end
function PreLoading:initUI()
    self.txtLoad =
        ccui.Text:create("0%", "", 27):setAnchorPoint(cc.p(0.5, 0.5)):setPosition(display.cx + 217, 186):setTextColor(
        cc.c4b(255, 255, 255, 255)
    ):addTo(self)
    local bgLoading =
        display.newSprite("ui/common/kongyuan.png"):setPosition(display.cx, 150):addTo(self):setBlendFunc(
        cc.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
    )
    self.loadingBar =
        ccui.Layout:create():setAnchorPoint(cc.p(0, 0)):setContentSize(0, 70):setPosition(display.cx - 690 * 0.5, 136):addTo(
        self
    )
    self.loadingBar:setClippingEnabled(true)
    self.loadingBar:setCascadeOpacityEnabled(true)
    self.loadingBarPosX = self.loadingBar:getPositionX()
    local spProgress =
        display.newSprite("ui/common/shixinyuan.png"):setPosition(345, 17):addTo(self.loadingBar):setBlendFunc(
        cc.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
    )
    local Image_LoadingText = display.newSprite("ui/txt/jiazaiyouxi.png"):setPosition(display.cx, 62):addTo(self)
end
function PreLoading:initListener()
    local eventListeners = {}
    eventListeners["qpbyResMgr_percent"] = handler(self, self.updatePercent)
    eventListeners["qpbyResMgr_updateEnd"] = handler(self, self.startRemoveAni)
    -- self.qpbyResMgrEventHandles = EventMgr:getInstance():addEventListenerByTable(eventListeners)
    self.qpbyResMgrEventHandles = nil
   local listener1 = cc.EventListenerCustom:create("qpbyResMgr_percent", function(args) self:updatePercent(args._usedata) end)
   local listener2 = cc.EventListenerCustom:create("qpbyResMgr_updateEnd", function(args) self:startRemoveAni(args._usedata) end)
   local dispacther=cc.Director:getInstance():getEventDispatcher()
   dispacther:addEventListenerWithFixedPriority(listener1, 1)
   dispacther:addEventListenerWithFixedPriority(listener2, 1)
end
function PreLoading:removeListener()
    -- EventMgr:getInstance():removeListenerByTable(self.qpbyResMgrEventHandles)
    self.qpbyResMgrEventHandles = nil
    local dispacther=cc.Director:getInstance():getEventDispatcher()
    dispacther:removeCustomEventListeners("qpbyResMgr_percent")
    dispacther:removeCustomEventListeners("qpbyResMgr_updateEnd")
end
function PreLoading:onCleanup()
    self:removeListener()
end
function PreLoading:onEnter()
end
function PreLoading:startRemoveAni(args)
    if not tolua.isnull(self.effectNode) then
        local fadeOut = cc.FadeOut:create(0.1)
        local callfunc =
            cc.CallFunc:create(
            function()
                self.effectNode:removeFromParent()
            end
        )
        local seq = cc.Sequence:create(fadeOut, callfunc)
        self.effectNode:runAction(seq)
    end
    local fadeOut = cc.FadeOut:create(0.5)
    local callfunc =
        cc.CallFunc:create(
        function()
            self:stopAllActions()
            self:removeFromParent()
        end
    )
    local seq = cc.Sequence:create(fadeOut, callfunc)
    self:stopAllActions()
    self:runAction(seq)
end
function PreLoading:updatePercent(args)
    local param = args.para
    local percent = param.percent
    self.txtLoad:setString(perStr)
    self.loadingBar:setContentSize(cc.size(math.ceil(690 * percent), 136))
    local barWidth = 690 * percent
    local perStr = tostring(math.ceil(percent * 100) .. "%")
    self.txtLoad:setPositionX(self.loadingBarPosX + barWidth)
    self.txtLoad:setString(perStr)
end
return PreLoading
