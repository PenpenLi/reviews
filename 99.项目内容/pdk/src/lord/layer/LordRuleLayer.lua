-- region LordRuleLayer.lua
-- Date 2017.11.15
-- Auther JackXu.
-- Desc 游戏规则弹框 Layer.

local LordRuleLayer = class("LordRuleLayer", cc.exports.FixLayer)

function LordRuleLayer:ctor()
    self.super:ctor(self)
    self:enableNodeEvents()
    self:init()
end

function LordRuleLayer:init()
    self:initCSB()
end

function LordRuleLayer:onEnter()
    self.super:onEnter()

    self:setTargetShowHideStyle(self, self.SHOW_DLG_BIG, self.HIDE_DLG_BIG)
    self:showWithStyle()
end

function LordRuleLayer:onExit()
    self.super:onExit()
end

function LordRuleLayer:initCSB()

    --root
    self.m_rootUI = display.newNode()
    self.m_rootUI:addTo(self)

    --csb
    self.m_pUiLayer = cc.CSLoader:createNode("game/lord/csb/gui-lord-ruleLayer.csb")
    self.m_pUiLayer:addTo(self.m_rootUI, Z_ORDER_TOP)
    self.m_pLayerBase = self.m_pUiLayer:getChildByName("Layer_base")
    self.m_pScrollView = self.m_pLayerBase:getChildByName("ScrollView")
    self.m_pBtnClose = self.m_pLayerBase:getChildByName("Button_close")
    self.m_pLayerTouch = self.m_pLayerBase:getChildByName("Panel_touch")

    --滚动条
    self.m_pScrollView:setScrollBarEnabled(false)

    -- 关闭按纽
    self.m_pBtnClose:addClickEventListener(function()
        AudioManager.getInstance():playSound("public/sound/sound-close.mp3")
        self:onMoveExitView()
    end)
    self.m_pLayerTouch:addClickEventListener(function()
        AudioManager.getInstance():playSound("public/sound/sound-close.mp3")
        self:onMoveExitView()
    end)
end

return LordRuleLayer
