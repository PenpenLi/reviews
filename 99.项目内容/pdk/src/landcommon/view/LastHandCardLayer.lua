-- LastHandCardLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 上手牌功能
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LastHandCardLayer = class("LastHandCardLayer", function()
    return display.newLayer()
end)

function LastHandCardLayer:ctor( landMainScene )
    self:init()
    self:setTouchEnabled(false)
    self:setTouchSwallowEnabled(true)
    self.landMainScene = landMainScene
    LAND_LOAD_OPEN_EFFECT(self.last_poker_panel)
end

function LastHandCardLayer:init()
    local size = cc.Director:getInstance():getWinSize()

	local node = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_common_cs/land_set_lasthand.csb")
    UIAdapter:adapter(node, handler(self, self.onTouchCallback))
    self:addChild(node)


    self.last_poker_panel = node:getChildByName("last_hand_cards_panel")
    self.poker_l =  self.last_poker_panel:getChildByName("left_land_poker")
    self.poker_l:setVisible(false)
    self.poker_l_pos = cc.p(self.poker_l:getPositionX(),self.poker_l:getPositionY())
    self.pass_img_l = self.last_poker_panel:getChildByName("left_pass_image")
    self.pass_img_l:setVisible(false)

    self.poker_r =  self.last_poker_panel:getChildByName("right_land_poker")
    self.poker_r:setVisible(false)
    self.poker_r_pos = cc.p(self.poker_r:getPositionX(),self.poker_r:getPositionY())
    self.pass_img_r = self.last_poker_panel:getChildByName("right_pass_image")
    self.pass_img_r:setVisible(false)

    self.poker_b =  self.last_poker_panel:getChildByName("self_land_poker")
    self.poker_b:setVisible(false)
    self.poker_b_pos = cc.p(self.poker_b:getPositionX(),self.poker_b:getPositionY())
    self.pass_img_b = self.last_poker_panel:getChildByName("self_pass_image")
    self.pass_img_b:setVisible(false)

    --二人跑得快对家上手牌的位置
    self.poker_r_tp = self.last_poker_panel:getChildByName("tp_right_land_poker")
    self.poker_r_tp:setVisible(false)
    self.poker_r_pos_tp = cc.p(self.poker_r_tp:getPositionX(),self.poker_r_tp:getPositionY())
    self.pass_img_r_tp = self.last_poker_panel:getChildByName("tp_right_pass_image")
    self.pass_img_r_tp:setVisible(false)
end

function LastHandCardLayer:OnLastHandCallBack(sender, eventType)
    if sender then
        if eventType == ccui.TouchEventType.ended then
            self.landMainScene.m_lastHandCardLayer = nil
            self:removeFromParent()
        end
    end
end

function LastHandCardLayer:clearCard()
	for i=0x01,0x4F do
        local cardspritr = self.last_poker_panel:getChildByTag(i)
        if  cardspritr then
            self.last_poker_panel:removeChild(cardspritr, true)
        end
    end
end

function LastHandCardLayer:createShanShou( cardDataTable,uesrID ,isOutCard )
   print("----LastHandCardLayer:createShanShou")
   local size =  cc.Director:getInstance():getWinSize()
    --设置牌的初始位置
    local ptCardStart = cc.p(0,0)
    if 2 == uesrID then                --左边玩家
       self.pass_img_l:setVisible(false)
       ptCardStart = cc.p(self.poker_l:getPositionX(),self.poker_l:getPositionY())
       ptCardStart.x = ptCardStart.x-30
    elseif 0 == uesrID then           --右边玩家
       self.pass_img_r:setVisible(false)
       ptCardStart = cc.p(self.poker_r:getPositionX(),self.poker_r:getPositionY())
       if  table.nums(cardDataTable)>=9 then
          ptCardStart.x = ptCardStart.x - 9*30 + 60
       else 
          ptCardStart.x = ptCardStart.x - table.nums(cardDataTable)*30+60
       end
    elseif 1 == uesrID then              --中间玩家
        self.pass_img_b:setVisible(false)
        ptCardStart = cc.p(self.poker_b:getPositionX(),self.poker_b:getPositionY())
        ptCardStart.x = ptCardStart.x - (table.nums(cardDataTable)-1)/2*30
    end    

    if isOutCard == 1 then
        if table.nums(cardDataTable) >0 then
            for i=1,table.nums(cardDataTable) do
                local cardSprite = self.landMainScene.m_landMainLayer.m_cardSprite:createSmallCard(cardDataTable[i],false)
                cardSprite:setScale(0.3)
                self.last_poker_panel:addChild(cardSprite,2,cardDataTable[i])
                cardSprite:setPosition( self:getCardXY( i , ptCardStart , uesrID ) )
            end  
        else
           if 2 == uesrID then
              self.pass_img_l:setVisible(true)
           elseif 0 ==  uesrID then
              self.pass_img_r:setVisible(true)
           elseif 1 == uesrID then
              self.pass_img_b:setVisible(true)
           end
        end
    end
end

function LastHandCardLayer:getCardXY( k , start , uesrID )
    local oneLineCardNum = 9
    if uesrID == 1 then oneLineCardNum = 20 end
    local n = k
    if k > oneLineCardNum then n = k-oneLineCardNum end
    local x = start.x + (n-1)*30
    local y = -48*math.floor(k/(oneLineCardNum+1)) + start.y
    return x,y
end

function LastHandCardLayer:createShanShouTP( cardDataTable,uesrID,isOutCard )
   print("----LastHandCardLayer:createShanShou")
   local size =  cc.Director:getInstance():getWinSize()
    --设置牌的初始位置
    local ptCardStart = cc.p(0,0)
    if 0 == uesrID then           --右边玩家
        ptCardStart = cc.p(self.poker_r_tp:getPositionX(),self.poker_r_tp:getPositionY())
        ptCardStart.x = ptCardStart.x - (table.nums(cardDataTable)-1)/2*26    
    elseif 1 == uesrID then       --中间玩家
        ptCardStart = cc.p(self.poker_b:getPositionX(),self.poker_b:getPositionY())
        ptCardStart.x = ptCardStart.x - (table.nums(cardDataTable)-1)/2*26
    end        

    if table.nums(cardDataTable) >0 then
        for i=1,table.nums(cardDataTable) do
            local cardSprite = self.landMainScene.m_landMainLayer.m_cardSprite:createSmallCard(cardDataTable[i],false)
            cardSprite:setScale(0.3)
            self.last_poker_panel:addChild(cardSprite,2,cardDataTable[i])
            cardSprite:setPosition(ptCardStart)
            ptCardStart.x = ptCardStart.x + 26
        end  
    end
end

-- 点击事件回调
function LastHandCardLayer:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)
    if name == "close_button" then
        self.landMainScene.m_lastHandCardLayer = nil
        self:removeFromParent()
    elseif name == "Panel_shadow" then
        self.landMainScene.m_lastHandCardLayer = nil
        self:removeFromParent()
    end
end

return LastHandCardLayer