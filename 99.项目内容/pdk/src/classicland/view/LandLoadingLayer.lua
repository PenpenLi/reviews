local CommonLoading = require("src.app.newHall.layer.CommonLoading")

local LandLoadingLayer = class("LandLoadingLayer", function()
    return CommonLoading.new()
end)

local LandRes = require("src.app.game.pdk.src.classicland.scene.LandRes")
local landArmatureResource = require ("app.game.pdk.src.landcommon.animation.LandArmatureResource")

local PATH_CSB = "hall/csb/CommonLoading.csb"
local PATH_BG = "src/app/game/pdk/res/csb/resouces/big_pic/lord_loading_bg.jpg"
local PATH_LOGO1 = "src/app/game/pdk/res/csb/resouces/big_pic/lord_loading_bg.jpg"
local PATH_LOGO2 = "80000044/game_room/logo-2.png"

function LandLoadingLayer.loading()
    return LandLoadingLayer.new(true)
end

function LandLoadingLayer.reload()
    return LandLoadingLayer.new(false)
end

function LandLoadingLayer:ctor(bBool)
    self:setNodeEventEnabled(true)
    self.bLoad = bBool
    self:init()
end

function LandLoadingLayer:init()
    --self.super:init(self)
    self:initCSB()
    self:initCommonLoad()
    if cc.exports.g_SchulerOfLoading then
        scheduler.unscheduleGlobal(cc.exports.g_SchulerOfLoading)
        cc.exports.g_SchulerOfLoading = nil
    end

    self:startLoading()
end

function LandLoadingLayer:closeView()
    self.m_pathUI:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.Spawn:create( cc.FadeOut:create(0.3), cc.ScaleTo:create(0.3, 1.2)),
        cc.CallFunc:create(function()
            self:getParent():removeChild(self);
        end),
    nil))
    -- self:getParent():removeChild(self);
end


function LandLoadingLayer:initCSB()

    --root
    self.m_rootUI = display.newNode()
    self.m_rootUI:addTo(self)

    --ccb
    self.m_pathUI = cc.CSLoader:createNode(PATH_CSB)
    -- self.m_pathUI:setPositionX((display.width - 1624) / 2)
    self.m_pathUI:addTo(self.m_rootUI)
    self.m_pathUI:setPosition(display.width / 2, display.height / 2);
    self.m_pathUI:setAnchorPoint(cc.p(0.5, 0.5));

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

    --image
    self.m_pImageLogo = self.m_pNodeBg:getChildByName("Image_logo")
    self.m_pImageBg   = self.m_pNodeBg:getChildByName("Image_bg")
    self.m_pImageBg:loadTexture(PATH_BG, ccui.TextureResType.localType)
    local bg_size = self.m_pImageBg:getContentSize();
    if bg_size.width < display.width then
        self.m_pImageBg:setScale(display.width / bg_size.width);
        self.m_pImageBg:setPosition((1334 - display.width) / 2, display.height);
        self.m_pImageBg:setAnchorPoint(cc.p( 0 , 1));
    end

    -- self.m_pImageLogo:loadTexture(PATH_LOGO1, ccui.TextureResType.localType)
    -- self.m_pImageLogo:setContentSize(cc.size(551, 328))
end

function LandLoadingLayer:initCommonLoad()
    
    -------------------------------------------------------
    --设置界面ui
    self:setLabelPercent(self.m_pLabelPercent) --百分比文字
    --self:setLabelWord(self.m_pLabelWord)       --提示文字
    self:setBarPercent(self.m_pLoadingBar)     --进度条
    -------------------------------------------------------

    local other_list = {}
    table.insert(other_list, handler(self, self._CreateCsbNode));
    -- table.insert(other_list, handler(self, self._CreateAniNode));
    table.insert(other_list, handler(self, self._CreateDragonBones));
    table.insert(other_list, handler(self, self._LoadAudio));

    local ani_list = {};
    for key, value in pairs(landArmatureResource.armatureResourceInfo) do
        table.insert(ani_list, value.configFilePath);
    end
    table.insert(ani_list, "src/app/game/pdk/res/animation/lord_eff_head/lord_eff_head.ExportJson");


    --音效/音乐/骨骼/动画/动画/碎图/大图/其他
    self:addLoadingList(LandRes.vecLoadingPlist,  self.TYPE_PLIST)
    self:addLoadingList(LandRes.vecLoadingImage,  self.TYPE_PNG)
    -- self:addLoadingList(LandRes.vecLoadingAnim,   self.TYPE_EFFECT)
    self:addLoadingList(ani_list,   self.TYPE_EFFECT)
    -- self:addLoadingList(LandRes.vecLoadingMusic,  self.TYPE_MUSIC)
    -- self:addLoadingList(LandRes.vecLoadingSound,  self.TYPE_SOUND)
    self:addLoadingList(other_list,  self.TYPE_OTHER)
    -------------------------------------------------------
end

function LandLoadingLayer:_CreateCsbNode()
    CacheManager:putCSB("src/app/game/pdk/res/csb/classic_land_cs/free_land_main.csb");
    CacheManager:putCSB("src/app/game/pdk/res/csb/classic_land_cs/game_land_bg.csb")
	CacheManager:putCSB("src/app/game/pdk/res/csb/classic_land_cs/game_happyland_bg.csb")
    -- CacheManager:putCSB(LandRes.CSB.BG);
    CacheManager:putCSB(LandRes.CSB.PLAYER_LEFT);
    CacheManager:putCSB(LandRes.CSB.PLAYER_RIGHT);
    CacheManager:putCSB(LandRes.CSB.PLAYER_SELF);
    CacheManager:putCSB(LandRes.CSB.OVER_TOP_INFO);
    CacheManager:putCSB(LandRes.CSB.JIA_BEI);
end

function LandLoadingLayer:_CreateAniNode()

end

function LandLoadingLayer:_CreateDragonBones()
    CacheManager:putDragonBones(landArmatureResource.armatureResourceInfo[landArmatureResource.ANI_DIZHU].armatureName);
    CacheManager:putDragonBones(landArmatureResource.armatureResourceInfo[landArmatureResource.ANI_NONG_MING].armatureName);
    CacheManager:putDragonBones(landArmatureResource.armatureResourceInfo[landArmatureResource.ANI_NONG_MING].armatureName);
    CacheManager:putDragonBones("lord_eff_head");
end

function LandLoadingLayer:_LoadAudio()
    g_AudioPlayer:playMusic(LandRes.Audio.BACK_MUSIC, true)



end

return LandLoadingLayer