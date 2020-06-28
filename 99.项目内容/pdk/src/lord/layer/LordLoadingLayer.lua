--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LordSceneRes = require("game.lord.scene.LordSceneRes")

local PATH_CSB = "game/lord/csb/gui-lord-loadLayer.csb"

local CommonLoading = require("common.layer.CommonLoading")
local LordLoadingLayer = class("LordLoadingLayer", CommonLoading)

function LordLoadingLayer.loading()
    return LordLoadingLayer.new(true)
end

function LordLoadingLayer.reload()
    return LordLoadingLayer.new(false)
end

function LordLoadingLayer:ctor(bBool)
    self:enableNodeEvents()
    self.bLoad = bBool
    self:init()
end

function LordLoadingLayer:init()
    self.super:init(self)
    self:initCSB()
    self:initCommonLoad()
end

function LordLoadingLayer:onEnter()
    self.super:onEnter()
end

function LordLoadingLayer:onExit()
    self.super:onExit()
end

function LordLoadingLayer:initCSB()

    --root
    self.m_rootUI = display.newNode()
    self.m_rootUI:addTo(self)

    --ccb
    self.m_pathUI = cc.CSLoader:createNode(PATH_CSB)
    self.m_pathUI:setPositionX((display.width - 1624) / 2)
    self.m_pathUI:addTo(self.m_rootUI)

    --node
    self.m_pNodeBase = self.m_pathUI:getChildByName("Layer_base")
    self.m_pNodeBg   = self.m_pNodeBase:getChildByName("Node_bg")
    self.m_pNodeLoad = self.m_pNodeBase:getChildByName("Node_load")
    self.m_pNodeText = self.m_pNodeBase:getChildByName("Node_text")

    --bar
    self.m_pLoadingBar = self.m_pNodeLoad:getChildByName("LoadingBar")

    --text
    self.m_pLabelPercent = self.m_pNodeText:getChildByName("Text_percent")
    self.m_pLabelWord    = self.m_pNodeText:getChildByName("Text_word")
end

function LordLoadingLayer:initCommonLoad()

    -------------------------------------------------------
    --设置界面ui
    self:setLabelPercent(self.m_pLabelPercent) --百分比文字
    self:setLabelWord(self.m_pLabelWord)       --提示文字
    self:setBarPercent(self.m_pLoadingBar)     --进度条
    -------------------------------------------------------
    --音效/音乐/骨骼/动画/动画/碎图/大图/其他
    self:addLoadingList(LordSceneRes.vecLoadingSound, self.TYPE_SOUND)
    self:addLoadingList(LordSceneRes.vecLoadingMusic, self.TYPE_MUSIC)
    self:addLoadingList(LordSceneRes.vecLoadingAnim,  self.TYPE_EFFECT)
    self:addLoadingList(LordSceneRes.vecRLoadingPlist, self.TYPE_PLIST)
    self:addLoadingList(LordSceneRes.vecRLoadingImg,   self.TYPE_PNG)
    -------------------------------------------------------
end

return LordLoadingLayer
--endregion
