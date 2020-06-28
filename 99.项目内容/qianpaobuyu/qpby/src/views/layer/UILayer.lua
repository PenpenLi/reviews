local UILayer =
    class(
    "UILayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local GameMenuLayer = appdf.req(module_pre .. ".views.layer.GameMenuLayer")
local NODEZORDER = {UI = 1, POP = 2}
function UILayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self:initUI()
end
function UILayer:onEnter()
end
function UILayer:initUI()
    self.menuBtn = ccui.Button:create("ui/an_menu_Open.png"):setPosition(65, display.height - 55):addTo(self)
    self.menuBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                GameMenuLayer.new(self.scene):setPosition(0, 0):addTo(self, NODEZORDER.POP)
            end
        end
    )
    self.autoBtn =
        ccui.Button:create("ui/zidong_anniu.png"):setPosition(display.width - 65, display.height - 180):addTo(
        self,
        NODEZORDER.UI
    )
    self.autoBtn.highlight =
        display.newSprite("ui/suoding-guangxiao.png"):setPosition(57, 57):addTo(self.autoBtn):hide()
    self.autoBtn.text = display.newSprite("ui/zidongzhong.png"):setPosition(57, 10):addTo(self.autoBtn):hide()
    self.autoBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:changeAuto()
            end
        end
    )
    self.lockBtn =
        ccui.Button:create("ui/suoding_anniu.png"):setPosition(display.width - 65, display.height - 300):addTo(
        self,
        NODEZORDER.UI
    )
    self.lockBtn.highlight =
        display.newSprite("ui/suoding-guangxiao.png"):setPosition(57, 57):addTo(self.lockBtn):hide()
    self.lockBtn.text = display.newSprite("ui/suodingzhong.png"):setPosition(57, 10):addTo(self.lockBtn):hide()
    self.lockBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:changeLock()
            end
        end
    )
    self.speedBtn =
        ccui.Button:create("ui/jiasu_anniu.png"):setPosition(display.width - 65, display.height - 420):addTo(
        self,
        NODEZORDER.UI
    )
    self.speedBtn.highlight =
        display.newSprite("ui/suoding-guangxiao.png"):setPosition(57, 57):addTo(self.speedBtn):hide()
    self.speedBtn.text = display.newSprite("ui/suodingzhong.png"):setPosition(57, 10):addTo(self.speedBtn):hide()
    self.speedBtn.speed = 1
    self.speedBtn:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:changeSpeed()
            end
        end
    )
end
function UILayer:changeAuto()
    if self.autoBtn.highlight:isVisible() then
        self.autoBtn.highlight:stopAllActions()
        self.autoBtn.highlight:hide()
        self.autoBtn.text:hide()
        self.scene.gameController:setAuto(false)
    else
        self.autoBtn.highlight:show()
        self.autoBtn.highlight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
        self.autoBtn.text:show()
        self.scene.gameController:setAuto(true)
    end
end
function UILayer:changeLock()
    local isAutoLock = false
    if self.lockBtn.highlight:isVisible() then
        self.lockBtn.highlight:stopAllActions()
        self.lockBtn.highlight:hide()
        self.lockBtn.text:hide()
    else
        self.lockBtn.highlight:show()
        self.lockBtn.highlight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
        self.lockBtn.text:show()
        isAutoLock = true
    end
    -- EventMgr:getInstance():dispatchEvent({name = "qpby_changeAutoLock", para = {isLock = isAutoLock}})
    local event = cc.EventCustom:new("qpby_changeAutoLock")
    event._usedata = {name = "qpby_changeAutoLock", para = {isLock = isAutoLock}}
    local dispacther=cc.Director:getInstance():getEventDispatcher()
    dispacther:dispatchEvent(event)
end
function UILayer:changeSpeed()
    if self.speedBtn.speed == 1 or self.speedBtn.speed == 2 then
        self.speedBtn.highlight:show()
        self.speedBtn.highlight:stopAllActions()
        self.speedBtn.highlight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
        if self.speedBtn.speed == 1 then
            self.speedBtn.speed = 2
        elseif self.speedBtn.speed == 2 then
            self.speedBtn.speed = 4
        end
        local filePath = string.format("ui/jiasu-%s.png", self.speedBtn.speed)
        self.speedBtn.text:show()
        self.speedBtn.text:setTexture(filePath)
    elseif self.speedBtn.speed == 4 then
        self.speedBtn.highlight:stopAllActions()
        self.speedBtn.highlight:hide()
        self.speedBtn.text:hide()
        self.speedBtn.speed = 1
    end
    self.scene.gameController:setFireSpeed(self.speedBtn.speed)
end
return UILayer
