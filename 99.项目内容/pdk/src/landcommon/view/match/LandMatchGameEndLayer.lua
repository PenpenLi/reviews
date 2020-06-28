--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛定点赛结束冠军亚军
--------------------------------------------------------
local FastRoomController   = require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local DDSRoomController    = require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local LandGlobalDefine     = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local LandMatchGameEndLayer = class("LandMatchGameEndLayer", function()
    return display.newLayer()
end)

local RANK_IMAGE = {
    [1] = {"ddz_tubiao_yumao.png","ddz_tubiao_jinbei.png", "ddz_zi_guanjun.png"},
    [2] = {"ddz_tubiao_hyumao.png", "ddz_tubiao_yinbei.png", "ddz_zi_yajun.png"}
}


local itemPosConfig = {
    [1] ={x= 634, y=295},
    [2] = {{x = 552, y = 295}, {x = 716, y = 295}},
    [3] = { {x = 468, y = 295}, {x = 646, y = 295}, {x = 830, y = 295} },
}

local itemNamePosConfig ={
    [1] ={x= 634, y=218},
    [2] = { {x = 552, y = 218},  {x = 716, y = 218}},
    [3] = { {x = 468, y = 218}, {x = 646, y = 218}, {x = 830, y = 218} }, 
}


function LandMatchGameEndLayer:ctor( landMainSence , param )
    
    self.m_landMainScene   = param.landMainSence 
    self.game_atom         = param.gameId
    self.sign_up_condition = param.condition

 	self:initUI()

    local strTbl = string.split(param.matchName, "（")
    self.game_name_label:setString( param.roomName..strTbl[1] )

    if param.gameRank == 1 or param.gameRank == 2 then
        self:showGuanYaJun(param.gameRank)
    else
        self:showOtherRank( param.gameRank )
    end

    self:updateRewardItem(param.reward)

end 

function LandMatchGameEndLayer:initUI()
	self.node = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_accounts.csb")
    UIAdapter:adapter(self.node, handler(self, self.onTouchCallback) )
    self:addChild( self.node )

    self.game_name_label = self.node:getChildByName("match_name")

    self:initRewardItem()
    self:initButton()

end

function LandMatchGameEndLayer:initRewardItem()
    self.reward_item_bg = {}
    for i=1,3 do
        self.reward_item_bg[i] = {}
        self.reward_item_bg[i].image_item_bg = self.node:getChildByName("Image_item_bg_"..i)
        self.reward_item_bg[i].item_name_bg =  self.node:getChildByName("item_name_bg_"..i)
    end
end

function LandMatchGameEndLayer:initButton()
    self.close_btn = self:getChildByName("back_btn")
    self.close_btn:addTouchEventListener(handler(self,self.OnClickCloseBtn))

    self.share_btn = self:getChildByName("share_btn")
    self.share_btn:addTouchEventListener(handler(self,self.OnClickShareBtn))

    self.again_game_btn = self:getChildByName("once_btn")
    self.again_game_btn:addTouchEventListener(handler(self,self.OnClickAgainGameBtn))

    if IS_DING_DIAN_SAI( self.game_atom ) then
        self.again_game_btn:setVisible(false)
        self.share_btn:setPositionX(self.share_btn:getPositionX() + 184)
    end
end

function LandMatchGameEndLayer:getRewardItemTbl( info )
	local itemArr = {}
	if info.diamond > 0 then 
		local tbl = {
			["m_itemId"] = GlobalDefine.ITEM_ID.Diamond,
			["m_num"]    = info.diamond
		}
		table.insert( itemArr , tbl )
	end
	if info.goldCoin > 0 then 
		local tbl = {
			["m_itemId"] = GlobalDefine.ITEM_ID.GoldCoin,
			["m_num"]    = info.goldCoin
		}
		table.insert( itemArr , tbl )
	end
	for k,v in pairs( info.itemArr ) do
		table.insert( itemArr , v )
	end
	return itemArr
end

function LandMatchGameEndLayer:updateRewardItem( info )
	local itemArr = self:getRewardItemTbl( info )
    local itemArrCount = 3
    if itemArr then
        itemArrCount = #itemArr
    end

    if itemArr and #itemArr ==0 then
        LogINFO(" 没有道具")
        self.node:getChildByName("item_node"):setVisible(false)
        self.node:getChildByName("award_spr"):setVisible(false)
        return
    end

    self.node:getChildByName("award_spr"):setVisible(true)
    self.node:getChildByName("item_node"):setVisible(true)

    dump(itemArr, "物品列表:::", 10)

    for i,v in ipairs( self.reward_item_bg ) do
        v.image_item_bg:setVisible(false)
        v.item_name_bg:setVisible(false)
        if itemArr and itemArr[i] and itemArr[i].m_itemId then
            local item = GlobalItemInfoMgr:getItemInfoByID( itemArr[i].m_itemId )
            if item then

                v.image_item_bg:setVisible(true)
                v.item_name_bg:setVisible(true)

                local icon =  item:getItemIconSprite()

                local item_img = v.image_item_bg:getChildByName("item_img")
                item_img:setVisible(false)

                local item_name = v.item_name_bg:getChildByName("item_name")
                item_name:setString(itemArr[i].m_num .. "X" .. item.BaseInfo.Name)

                icon:addTo(v.image_item_bg)
                icon:setScale(0.7)
                icon:setPosition(cc.p(item_img:getPositionX(), item_img:getPositionY()))

                if itemArrCount == 1 then
                    v.image_item_bg:setPosition(cc.p(itemPosConfig[1].x, itemPosConfig[1].y))
                    v.item_name_bg:setPosition(cc.p(itemNamePosConfig[1].x, itemNamePosConfig[1].y))

                elseif itemArrCount == 2 then

                    v.image_item_bg:setPosition(cc.p(itemPosConfig[2][i].x, itemPosConfig[2][i].y))
                    v.item_name_bg:setPosition(cc.p(itemNamePosConfig[2][i].x, itemNamePosConfig[2][i].y))

                else
                    v.image_item_bg:setPosition(cc.p(itemPosConfig[3][i].x, itemPosConfig[3][i].y))
                    v.item_name_bg:setPosition(cc.p(itemNamePosConfig[3][i].x, itemNamePosConfig[3][i].y))

                end
            end
        end
    end
end

function LandMatchGameEndLayer:OnClickCloseBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        LogINFO("LandMatchGameEndLayer:OnClickCloseBtn")
        self:closeGameEndLayer()
    end
end

function LandMatchGameEndLayer:closeGameEndLayer()
    if self.m_landMainScene then
		g_GameController:releaseInstance()
        --self.m_landMainScene:onExitGame()
    else
        LogINFO("ERROR self.m_landMainScene",self.m_landMainScene)
    end
    self:removeFromParent()
end

function LandMatchGameEndLayer:OnClickShareBtn( sender, eventType )
    if eventType ~= ccui.TouchEventType.ended then return end
    QKA_SHARE( self.game_atom )
end

function LandMatchGameEndLayer:OnClickAgainGameBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        if IS_DING_DIAN_SAI( self.game_atom ) then
            LogINFO("OnClickAgainGameBtn 定点赛")
            DDSRoomController:getInstance():onClickAgainGame( self.game_atom )
        elseif IS_FAST_GAME( self.game_atom ) then
            LogINFO("OnClickAgainGameBtn 超快赛")
            self.again_game_btn:setTouchEnabled(false)
            FastRoomController:getInstance():onClickAgainGame( self.game_atom , self.sign_up_condition )
        end
    end
end

function LandMatchGameEndLayer:showGuanYaJun(rank)
    LogINFO("LandMatchGameEndLayer:showGuanJun")
    self.node:getChildByName("changeNode"):setVisible(true)
    self.node:getChildByName("otherNode"):setVisible(false)
    self.node:getChildByName("rank_left_spr"):setSpriteFrame(display.newSpriteFrame(RANK_IMAGE[rank][1]))
    self.node:getChildByName("rank_right_spr"):setSpriteFrame(display.newSpriteFrame(RANK_IMAGE[rank][1]))
    self.node:getChildByName("rank_spr_bg"):setSpriteFrame(display.newSpriteFrame(RANK_IMAGE[rank][2]))
    self.node:getChildByName("rank_spr"):setSpriteFrame(display.newSpriteFrame(RANK_IMAGE[rank][3]))
end

function LandMatchGameEndLayer:showOtherRank( _rank )  
    self.node:getChildByName("changeNode"):setVisible(false)
    self.node:getChildByName("otherNode"):setVisible(true)
    self.node:getChildByName("rank"):setString(string.format("第%d名", _rank))
end

function LandMatchGameEndLayer:onTouchCallback( sender )
end

return LandMatchGameEndLayer


