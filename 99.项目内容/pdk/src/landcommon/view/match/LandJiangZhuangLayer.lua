--------------------------------------------------------
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛中的奖状界面
--------------------------------------------------------
local FastRoomController =  require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local GlobalItemInfoMgr = GlobalItemInfoMgr or require("app.hall.bag.model.GoodsData").new()
local LandGlobalDefine = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

local LandJiangZhuangLayer = class("LandJiangZhuangLayer", function()
    return display.newLayer()
end)

function LandJiangZhuangLayer:ctor( landMainScene , gameAtomID )
    self.m_landMainScene = landMainScene
    self.gameAtomID = gameAtomID
    self:initUI()
end 

function LandJiangZhuangLayer:initUI()
    self.node = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_diploma.csb")
    UIAdapter:adapter( self.node , handler(self, self.onTouchCallback) )
    self:addChild( self.node )

    self.price_bg = self.node:getChildByName("prize")
    self.time_label = self.price_bg:getChildByName("time")
    self.time_label:setString( os.date("%Y-%m-%d %H:%M", os.time() ) )
    self.playerName = self.price_bg:getChildByName("name")
    self.match_name_label = self.price_bg:getChildByName("match_name")
    self.congraduation = self.price_bg:getChildByName("congraduation")
    self.congraduation_tail = self.price_bg:getChildByName("congraduation_tail")
    self.di = self.price_bg:getChildByName("di")
    self.ming = self.price_bg:getChildByName("ming")

    self.Sprite_76 = self.node:getChildByName("Sprite_76")
    self.Sprite_76:setSpriteFrame(display.newSpriteFrame("ddz_hg_yinzhang.png"))

    local rank_label = self.price_bg:getChildByName("num")
    self.rank_label_pos = cc.p(rank_label:getPosition())
    rank_label:setVisible(false)
    
    self:initRewardItem()
    self:initButton()
end

function LandJiangZhuangLayer:initRewardItem( ... )
    self.reward_item_bg = {}
    local tbl = {"","_0","_1"}
    for k,v in ipairs( tbl ) do
        self.reward_item_bg[k] = self.price_bg:getChildByName("lord_jz_bg_product"..v)
    end
end

function LandJiangZhuangLayer:getRewardItemTbl( info )
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

function LandJiangZhuangLayer:updateRewardItem( mResult )
    local itemArr  = self:getRewardItemTbl( mResult )

    self.itemArrCount = 0
    if itemArr and #itemArr > 0 then
        self.itemArrCount = #itemArr
    end

    if itemArr and #itemArr ==0 then
        -- 没有道具
        for i,v in ipairs( self.reward_item_bg ) do
            v:setVisible(false)
        end
    end

    for i, v in ipairs(self.reward_item_bg) do
        v:setVisible(false)
        if itemArr and itemArr[i] and itemArr[i].m_itemId then
            local item = GlobalItemInfoMgr:getItemInfoByID(itemArr[i].m_itemId)
            if item then
                v:setVisible(true)
                local text_product = v:getChildByName("text_product")
                text_product:setString(itemArr[i].m_num ..   item.BaseInfo.Name)
            end
        end
    end
end

function LandJiangZhuangLayer:initButton( ... )
    self.close_btn = self.node:getChildByName("btn_back")
    self.close_btn:addTouchEventListener(handler(self,self.OnClickCloseBtn))

    self.share_btn = self.node:getChildByName("Button_1_0")
    self.share_btn:addTouchEventListener(handler(self,self.OnClickShareBtn))
    self.share_btn:enableOutline({r = 19, g = 88, b = 84, a = 255}, 3)

    self.again_game_btn = self.node:getChildByName("Button_1")
    self.again_game_btn:addTouchEventListener(handler(self,self.OnClickAgainGameBtn))
    self.again_game_btn:enableOutline({r = 45, g = 54, b = 53, a = 255}, 3)


    self:resetButton()
end

function LandJiangZhuangLayer:resetButton( ... )
    if IS_DING_DIAN_SAI( self.gameAtomID ) then
        self.again_game_btn:setVisible(false)
        self.share_btn:setPositionX(475)
    else
        self.again_game_btn:setVisible(true)
        self.share_btn:setVisible(true)
    end
end

function LandJiangZhuangLayer:updateUI( mResult )
    self.sign_up_condition = mResult.contidion 
    self:updateRewardItem( mResult )
    self:updateRankLabel( mResult )
    if self.itemArrCount ~= 0  then
        --self:updateLabelPos()
    end
end

function LandJiangZhuangLayer:updateLabelPos()
    -- 如果有道具 位置不动 没道具  修改位置 
    if self.itemArrCount == 0 then
        self.playerName:setPositionY(443.48)
        self.match_name_label:setPositionY(362.91)
        self.congraduation:setPositionY(362.91)
        self.congraduation_tail:setPositionY(362.91)
        self.di:setPositionY(266.53)
        self.ming:setPositionY(266.53) 
        self.rankNumAtlas:setPositionY(266.53) 
    else
        self.playerName:setPositionY(474.70)
        self.match_name_label:setPositionY(423.13)
        self.congraduation:setPositionY(423.13)
        self.congraduation_tail:setPositionY(423.13)
        self.di:setPositionY(351.75)
        self.ming:setPositionY(351.75)
        self.rankNumAtlas:setPositionY(351.75)  
    end
end


function LandJiangZhuangLayer:updateRankLabel( mResult )
    self.rank = mResult.curRank or 0
    if self.rankNumAtlas then
        self.price_bg:removeChild( self.rankNumAtlas )
        self.rankNumAtlas = nil
    end

    local rank_label = self.price_bg:getChildByName("num")
    local di = self.price_bg:getChildByName("di")
    local ming = self.price_bg:getChildByName("ming")

    if self.itemArrCount == 0 then
        local lord_match_txt_diploma = self.node:getChildByName("lord_match_txt_diploma")
        if lord_match_txt_diploma then
            lord_match_txt_diploma:setSpriteFrame(display.newSpriteFrame("ddz_jz_title2.png"))
        end
        di:setVisible(false)
        ming:setVisible(false)
        return
    end

    di:setVisible(true)
    ming:setVisible(true)

    self.rankNumAtlas = cc.LabelAtlas:_create( tostring( self.rank ) ,  "number/ddz_jz_meishuzi.png",48,70,48)
    self.rankNumAtlas:setAnchorPoint(cc.p(0.5,0.5))

    self.price_bg:addChild( self.rankNumAtlas )
    self.rankNumAtlas:setPosition( self.rank_label_pos )

    local conSize = self.rankNumAtlas:getContentSize()
    self.di:setPositionX(self.rank_label_pos.x - conSize.width/2-30)
    self.ming:setPositionX(self.rank_label_pos.x + conSize.width/2+30)

end

function LandJiangZhuangLayer:updateMatchNameLabel( _str )

    self.playerName:setString(Player:getParam("NickName")..":")

    if self.itemArrCount == 0 then
        local strTbl = string.split(_str, "（")
        local y = 385

        self.congraduation:setAnchorPoint(cc.p(0, 0.5))
        self.congraduation:setString("您在")


        self.match_name_label:setString( strTbl[1])
        self.match_name_label:setAnchorPoint(cc.p(0, 0.5))


        self.congraduation_tail_1 = self.congraduation_tail:clone()
        self.congraduation_tail_1:setString("中,获得第")
        self.price_bg:addChild(self.congraduation_tail_1)

        self.match_name_label_1 = self.match_name_label:clone()
        self.match_name_label_1:setString(self.rank)
        self.price_bg:addChild(self.match_name_label_1)     
        
        self.congraduation_tail:setString("名。")
        local wid5 = self.match_name_label_1:getContentSize().width

        local wid1 = self.congraduation:getContentSize().width  -- 你在
        local wid2 = self.match_name_label:getContentSize().width -- 比赛名字
        local wid3 = self.congraduation_tail_1:getContentSize().width --中,获得第
        local wid4 = self.match_name_label_1:getContentSize().width  -- 名次
        local wid5 = self.congraduation_tail:getContentSize().width -- --名

        local x = (self.price_bg:getContentSize().width - (wid1+wid2+wid3+wid4+wid5))/2
        self.congraduation:setPosition(cc.p(x,y))
        self.match_name_label:setPosition( cc.p(x+wid1, y))
        self.congraduation_tail_1:setPosition(cc.p( x+wid1+wid2, y))
        self.match_name_label_1:setPosition(cc.p( x+wid1+wid2+wid3 , y))
        self.congraduation_tail:setPosition(cc.p( x+wid1+wid2+wid3+wid4, y))
    else
        local strTbl = string.split(_str, "（")
        self.match_name_label:setString( strTbl[1])
        local x,y = self.match_name_label:getPosition()
        local headX = x - self.match_name_label:getContentSize().width/2
        local tailX = x + self.match_name_label:getContentSize().width/2
        self.congraduation:setAnchorPoint(cc.p(1, 0.5))
        self.congraduation:setPositionX( headX )
        self.congraduation_tail:setAnchorPoint(cc.p(0, 0.5))
        self.congraduation_tail:setPositionX( tailX )

    end
end

function LandJiangZhuangLayer:setGameAtom( id )
	self.gameAtomID = id
end

function LandJiangZhuangLayer:OnClickCloseBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        print("LandJiangZhuangLayer:OnClickCloseBtn",self.m_landMainScene)
        self:closeGameEndLayer()
    end
end

function LandJiangZhuangLayer:OnClickShareBtn( sender, eventType )
    if eventType ~= ccui.TouchEventType.ended then return end
    QKA_SHARE( self.gameAtomID )
end

function LandJiangZhuangLayer:onShareResultCallback( result )
    
    
end

function LandJiangZhuangLayer:closeGameEndLayer( ... )
    if self.m_landMainScene then
		g_GameController:releaseInstance()
        --self.m_landMainScene:onExitGame()
    else
        print("ERROR self.m_landMainScene",self.m_landMainScene)
    end
    --self:removeFromParent()
end

function LandJiangZhuangLayer:OnClickAgainGameBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
         if IS_DING_DIAN_SAI( self.gameAtomID ) then
            print("OnClickAgainGameBtn 定点赛")
            self:closeGameEndLayer()
        elseif IS_FAST_GAME( self.gameAtomID ) then
            FastRoomController:getInstance():onClickAgainGame( self.gameAtomID , self.sign_up_condition )
        end
    end
end

function LandJiangZhuangLayer:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
    print("LandJiangZhuangLayer name: ", name)
    if name == "btn_back" then
        --self:removeFromParent()
    end

end

return LandJiangZhuangLayer


