-- region LordRuleLayer.lua
-- Date 2017.11.15
-- Auther JackXu.
-- Desc 游戏规则弹框 Layer.
local HNLayer = require("app.newHall.HNLayer")
local LordRuleLayer = class("PDKRuleLayer", function()
    return HNLayer.new()
end)

function LordRuleLayer:ctor() 
    self:init()
end

function LordRuleLayer:init()
    self:initCSB()
end
 
  

function LordRuleLayer:initCSB()

    --root
    self.m_rootUI = display.newNode()
    self.m_rootUI:addTo(self)

    --csb
    self.m_pUiLayer = cc.CSLoader:createNode("src/app/game/pdk/res/game/lord/gui-lord-ruleLayer.csb")
    self.m_pUiLayer:addTo(self.m_rootUI, Z_ORDER_TOP)
    self.m_pLayerBase = self.m_pUiLayer:getChildByName("Layer_base") 
     local diffY = (display.size.height - 750) / 2
    self.m_pUiLayer:setPosition(cc.p(0,diffY))
     
    local diffX = 145-(1624-display.size.width)/2 
     self.m_pLayerBase:setPositionX(diffX)
    self.m_pScrollView = self.m_pLayerBase:getChildByName("ScrollView")
    self.m_pBtnClose = self.m_pLayerBase:getChildByName("Button_close")
    self.m_pLayerTouch = self.m_pLayerBase:getChildByName("Panel_touch")

    local Image_rule = self.m_pScrollView:getChildByName("Image_rule")
    Image_rule:ignoreContentAdaptWithSize(true)
    Image_rule:setAnchorPoint(cc.p(0, 1))
    Image_rule:setPositionY(1903)
    -- Image_rule:setContentSize(cc.size(880, 1903))
    self.m_pScrollView:setInnerContainerSize(cc.size(880, 1903))

    --滚动条
  --  self.m_pScrollView:setScrollBarEnabled(false)

    -- 关闭按纽
    self.m_pBtnClose:addTouchEventListener(function()
        g_AudioPlayer:playEffect("public/sound/sound-close.mp3")
        self:close()
    end)
    self.m_pLayerTouch:addTouchEventListener(function()
        g_AudioPlayer:playEffect("public/sound/sound-close.mp3")
        self:close()
    end)
end

return LordRuleLayer
