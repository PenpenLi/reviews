local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local PopupLayer = class("PopupLayer", cc.Layer)
function PopupLayer:ctor()
    ExternalFun.registerTouchEvent(self, true)
    self.darkBg = display.newLayer(cc.c4b(0, 0, 0, 125))
    self:addChild(self.darkBg)
end
function PopupLayer:onExit()
    self.darkBg:removeFromParent()
end
function PopupLayer:onTouchBegan(touch, event)
    return true
end
return PopupLayer
