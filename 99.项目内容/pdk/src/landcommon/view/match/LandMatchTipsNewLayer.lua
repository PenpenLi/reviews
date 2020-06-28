--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛和定点赛中的提示
--------------------------------------------------------
local FastRoomController =  require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local DingDianSaiRoomController =  require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local StringConfig = require("app.game.pdk.src.landcommon.data.StringConfig")

local LandMatchTipsNewLayer = class("LandMatchTipsNewLayer", function()
    return display.newLayer()
end)

function LandMatchTipsNewLayer:ctor( landMainScene )
    self.m_landMainScene = landMainScene
    self:initDingDianSaiNode()
end 

-- 定点赛 赛制提示
function LandMatchTipsNewLayer:initDingDianSaiNode()
    self.dds_node = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_tip_ding.csb")
    UIAdapter:adapter(self.dds_node, handler(self, self.onTouchCallback))
    self:addChild( self.dds_node )

    self.dds_chusai_node    = self.dds_node:getChildByName("layout_chu_tip")
    self.dds_jusai_node     = self.dds_node:getChildByName("layout_jue_tip")
    self.dds_wait_node      = self.dds_node:getChildByName("layout_wait")
    self.text_oclock_number = self.dds_wait_node:getChildByName("text_oclock_number")
    self.dds_node:setVisible(false)
end

function LandMatchTipsNewLayer:showDDSNode()
	self:setVisible(true)
    self.dds_node:setVisible(true)
    self.dds_chusai_node:setVisible(false)
    self.dds_jusai_node:setVisible(false)
    self.dds_wait_node:setVisible(false)
end

function LandMatchTipsNewLayer:showDDSChuSaiTips( stage )
    self:showDDSNode()
    self.dds_chusai_node:setVisible( true )
    
    local match_type_label = self.dds_chusai_node:getChildByName("match_mode")
    if stage == 2 then
        local fu_sha = StringConfig.getValueByKey("fu_sha")
    	match_type_label:setString(fu_sha)--"复赛")
    end

    local jiezhi_num_label = self.dds_chusai_node:getChildByName("group_num")
    local jiezhi_num = DingDianSaiRoomController:getInstance():getStopLimitNum( stage or 1 )
    jiezhi_num_label:setString( jiezhi_num )
    local strSize = jiezhi_num_label:getContentSize()
    local match_info1 = self.dds_chusai_node:getChildByName("match_info1")
    match_info1:setPositionX(jiezhi_num_label:getPositionX() - strSize.width - 10)

    local jinji_num_label = self.dds_chusai_node:getChildByName("next_num")
    local jinji_num = DingDianSaiRoomController:getInstance():playerNumGoNext()
    jinji_num_label:setString( jinji_num )
    strSize = jinji_num_label:getContentSize()
    local match_info2 = self.dds_chusai_node:getChildByName("match_info2")
    match_info2:setPositionX(jinji_num_label:getPositionX() + strSize.width + 10)
    
    local function onEnd()
        self:setVisible(false)
    end
    self.dds_chusai_node:runAction(cc.Sequence:create(D(6), cc.CallFunc:create(onEnd)))
end

function LandMatchTipsNewLayer:showDDSJueSaiTips()
    local info = DingDianSaiRoomController:getInstance():getRoundBeginInfo()
    self:showDDSNode()
    self.dds_jusai_node:setVisible( true )

    local mode_name_label  = self.dds_jusai_node:getChildByName("mode_name")
    local match_type_label = self.dds_jusai_node:getChildByName("match_mode")
    local round_label      = self.dds_jusai_node:getChildByName("round_num")

    local next_info_label  = self.dds_jusai_node:getChildByName("next_info")
    local jinji_num_label  = self.dds_jusai_node:getChildByName("next_num")
    local next_info_0_label  = self.dds_jusai_node:getChildByName("next_info_0")

    local jinji_num = DingDianSaiRoomController:getInstance():playerNumGoNext()
    if jinji_num == 1 then
    	next_info_label:setVisible(false)
    	next_info_0_label:setVisible(false)
        local strTitle = StringConfig.getValueByKey("finaly_win")
    	jinji_num_label:setString(strTitle)--"争夺最后冠军")
    else
    	next_info_label:setVisible(true)
    	next_info_0_label:setVisible(true)
    	jinji_num_label:setString( jinji_num )
    end
    local strSize = jinji_num_label:getContentSize()
    local next_info_0 = self.dds_jusai_node:getChildByName("next_info_0")
    next_info_0:setPositionX(jinji_num_label:getPositionX() + strSize.width + 8)

    
    if info.m_nStage == 2 then
        local fu_sha = StringConfig.getValueByKey("fu_sha")
        match_type_label:setString(fu_sha)--"复赛")
        local li_chu_ju = StringConfig.getValueByKey("li_chu_ju")
        mode_name_label:setString(li_chu_ju)--"打立出局制")
    elseif info.m_nStage == 3 then
        local jue_sha = StringConfig.getValueByKey("jue_sha")
        match_type_label:setString(jue_sha)--"决赛")
        local mou_wei = StringConfig.getValueByKey("mou_wei")
        mode_name_label:setString(mou_wei)--"末位淘汰制")
    end

    round_label:setString( info.m_nRound )
    strSize = round_label:getContentSize()
    local round_info = self.dds_jusai_node:getChildByName("round_info")
    round_info:setPositionX(round_label:getPositionX() - strSize.width - 10)

    local function onEnd()
        self:setVisible(false)
    end
    self.dds_jusai_node:runAction(cc.Sequence:create(D(3), cc.CallFunc:create(onEnd)))
end

function LandMatchTipsNewLayer:showBeginMatchNode(stage )
    if not self or not self.showDDSChuSaiTips then return end
    self:showDDSChuSaiTips( stage )
end
function LandMatchTipsNewLayer:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
end

return LandMatchTipsNewLayer


