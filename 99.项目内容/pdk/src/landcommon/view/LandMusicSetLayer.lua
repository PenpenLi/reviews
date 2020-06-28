-- LandMusicSetLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 设置弹框

local LandSoundManager = require("src.app.game.pdk.src.landcommon.data.LandSoundManager")

local LandMusicSetLayer = class("LandMusicSetLayer", function()
    return display.newLayer()
end)

LandMusicSetLayer.ClOSE_PANEL_TAG   = 10001    --关闭
LandMusicSetLayer.MUSIC_PANEL_TAG   = 10002    --音乐
LandMusicSetLayer.SOUND_PANEL_TAG   = 10003    --音效
LandMusicSetLayer.BACK_PANEL_TAG    = 10004    --返回
LandMusicSetLayer.TIP_PANEL_TAG     = 10005    --返回

function LandMusicSetLayer:ctor( landMainScene )
    self.m_pSettingNode = nil
    self.m_LandMainScene = landMainScene
    self:init()
    LAND_LOAD_OPEN_EFFECT(self.landSystemSetPanel)
end

function LandMusicSetLayer:init()

    self.m_pSettingNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_common_cs/land_set_music.csb")
    UIAdapter:adapter(self.m_pSettingNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_pSettingNode)

    self.landSystemSetPanel = self.m_pSettingNode:getChildByName("set_panel")   

    --关闭按钮
    self.closeButton = self.landSystemSetPanel:getChildByName("btn_close")
    tolua.cast( self.closeButton,"ccui.Button")
    self.closeButton:setTag( LandMusicSetLayer.ClOSE_PANEL_TAG )
    self.closeButton:addTouchEventListener(handler(self,self.onTouchButtonCallBack))
    
    --游戏音效
    self.musicPanel = self.landSystemSetPanel:getChildByName("btn_music")
    self.musicPanel:setTag(LandMusicSetLayer.MUSIC_PANEL_TAG)
    self.musicPanel:addTouchEventListener(handler(self,self.onTouchButtonCallBack))
	self.musicOnSpr =  self.musicPanel:getChildByName("dt_set_bg_swith_on")
    self.musicOffSpr =  self.musicPanel:getChildByName("dt_set_bg_swith_off")
	
    --游戏音乐
    self.soundPanel = self.landSystemSetPanel:getChildByName("btn_effect")
    self.soundPanel:setTag( LandMusicSetLayer.SOUND_PANEL_TAG )
    self.soundPanel:addTouchEventListener(handler(self,self.onTouchButtonCallBack))
    self.soundOnSpr =  self.soundPanel:getChildByName("dt_set_bg_swith_on")
    self.soundOffSpr = self.soundPanel:getChildByName("dt_set_bg_swith_off")

    --自动提示
    self.tipPanel = self.landSystemSetPanel:getChildByName("btn_tip")
    self.tipPanel:setTag( LandMusicSetLayer.TIP_PANEL_TAG )
    self.tipPanel:addTouchEventListener(handler(self,self.onTouchButtonCallBack))
    self.tipOnSpr =  self.tipPanel:getChildByName("dt_set_bg_swith_on")
    self.tipOffSpr = self.tipPanel:getChildByName("dt_set_bg_swith_off")
    
    self:CheckSoundStatus()
end

function LandMusicSetLayer:onTouchButtonCallBack(sender,eventType)
    if sender and sender:getTag() then
        local tag = sender:getTag()
        if eventType == ccui.TouchEventType.ended then
            if tag == LandMusicSetLayer.ClOSE_PANEL_TAG then     --关闭
                self:removeFromParent()
            elseif tag == LandMusicSetLayer.MUSIC_PANEL_TAG then --游戏音效
                self:ReverseMusic()
            elseif tag == LandMusicSetLayer.SOUND_PANEL_TAG  then--游戏音乐
                self:ReverseSound()
            elseif tag == LandMusicSetLayer.TIP_PANEL_TAG  then--游戏音乐
                self:ReverseTip()
           end
        end
    end
end  

function LandMusicSetLayer:ShowMusic(isOn)
    self.musicOnSpr:setVisible(isOn) 
    self.musicOffSpr:setVisible(not isOn)
end

function LandMusicSetLayer:ShowSound(isOn)
    self.soundOnSpr:setVisible(isOn) 
    self.soundOffSpr:setVisible(not isOn)
end

function LandMusicSetLayer:ShowTip(isOn)
    self.tipOnSpr:setVisible(isOn) 
    self.tipOffSpr:setVisible(not isOn)
end


function LandMusicSetLayer:OpenMusic(bOpen)
    if not bOpen then
        self:ShowMusic(false)
        audio.stopMusic()
        LandSoundManager:getInstance():setLandGameBgMusicStatus( ccui.CheckBoxEventType.unselected )
    else
        self:ShowMusic(true)
        LandSoundManager:getInstance():setLandGameBgMusicStatus( ccui.CheckBoxEventType.selected )
        --local bgMusic = LandSoundManager.LandGameBGMusic[ self.m_LandMainScene:getLandGameType()]
        --LandSoundManager:getInstance():playBgMusic( bgMusic )
    end
end

function LandMusicSetLayer:OpenSound(bOpen)
    if not bOpen then
        self:ShowSound(false)
        --audio.stopAllSounds()
        LandSoundManager:getInstance():setLandGameEffectSoundStatus( ccui.CheckBoxEventType.unselected )
    else
        self:ShowSound(true)
        --audio.resumeAllSounds()
        LandSoundManager:getInstance():setLandGameEffectSoundStatus( ccui.CheckBoxEventType.selected )
    end
end

function LandMusicSetLayer:OpenTip(bOpen)
    if not bOpen then
        self:ShowTip(false)
    else
        self:ShowTip(true)
    end
    cc.UserDefault:getInstance():setBoolForKey("AutoTip", bOpen)
end

function LandMusicSetLayer:CheckSoundStatus()
    self:OpenMusic(LandSoundManager:getInstance():getLandGameBgMusicStatus())
    self:OpenSound(LandSoundManager:getInstance():getLandGameEffectSoundStatus())
    self:OpenTip(cc.UserDefault:getInstance():getBoolForKey("AutoTip", false))
end

function LandMusicSetLayer:ReverseMusic()
    if LandSoundManager:getInstance():getLandGameBgMusicStatus() then
        self:OpenMusic(false)
    else
        self:OpenMusic(true)
    end
end

function LandMusicSetLayer:ReverseSound()
    if LandSoundManager:getInstance():getLandGameEffectSoundStatus() then
        self:OpenSound(false)
    else
        self:OpenSound(true)
    end
end

function LandMusicSetLayer:ReverseTip()
    self.mAutoTip = cc.UserDefault:getInstance():getBoolForKey("AutoTip", false)
    if self.mAutoTip then
        self:OpenTip(false)
    else
        self:OpenTip(true)
    end
end
-- 点击事件回调
function LandMusicSetLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
    if name == "btn_close" then
        self:setVisible(false)
    elseif name == "Panel_shadow" then
        self:removeFromParent()
    end
end

return LandMusicSetLayer
