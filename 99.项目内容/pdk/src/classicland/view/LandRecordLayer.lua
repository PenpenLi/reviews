local LandRecordLayer = class("LandRecordLayer", function()
    return display.newLayer()
end);

local CardConfig = require("landcommon/data/CardConfig");

function LandRecordLayer:ctor()
    self:initAttr();
    self:initCSB();
    ToolKit:registDistructor(self, handler(self, self.onDestory));
end

function LandRecordLayer:onDestory()

end

function LandRecordLayer:initAttr()
    self.m_pCardItems = {};
    self.m_pCardCounts = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1 };
end

function LandRecordLayer:initCSB()
    
    local pLayer = UIAdapter:createNode("src/app/game/pdk/res/csb/csb/classic_land_cs/land_record.csb");
    self:addChild(pLayer);
    pLayer:setPosition(display.width / 2, display.height/2);
    pLayer:setAnchorPoint(0.5,0.5);

    self.m_pRoot = pLayer:getChildByName("root");
    -- self.m_pRoot:retain();
    -- self.m_pRoot:removeFromParent();
    -- self:addChild(self.m_pRoot);
    -- self.m_pRoot:setPosition(0, 0);
    self.m_pBack = self.m_pRoot:getChildByName("back");
    self.m_pTips = self.m_pBack:getChildByName("tips");
    self.m_pCardList = self.m_pBack:getChildByName("card_list");
    self.m_pRecordButton = self.m_pRoot:getChildByName("record_button");
    UIAdapter:registClickCallBack(self.m_pRecordButton, handler(self, self._OnShowCardList), true);

    -- local tmp_item = self.m_pRoot:getChildByName("tmp_item");
    local card_types = {
        { 14, "小王" },
        { 15, "大王" },
        { 2, "2" },
        { 1, "A" },
        { 13, "K" },
        { 12, "Q" },
        { 11, "J" },
        { 10, "10" },
        { 9, "9" },
        { 8, "8" },
        { 7, "7" },
        { 6, "6" },
        { 5, "5" },
        { 4, "4" },
        { 3, "3" },
    };

    for index = 1, 15 do
        local card_type = card_types[index];
        local text_number = self.m_pCardList:getChildByName("number_"..index);
        self.m_pCardItems[card_type[1]] = text_number;

        text_number.m_nCount = self.m_pCardCounts[card_type[1]];
        text_number:setString(text_number.m_nCount);
        text_number:setColor(cc.c3b(0xf5, 0x8d, 0x12));
    end
    self:hideView();
end

function LandRecordLayer:setOutCard(cards)
    self:addCard(cards);
end

function LandRecordLayer:addCard(cards)
    for k, cardId in ipairs(cards) do
        local info = CardConfig:getCardInfoByid(cardId);
        local key = info.Value; --string.format( "card_%d", info.Value )
        local item = self.m_pCardItems[key];
        
        local count = item.m_nCount - 1;
        if count < 0 then
            print("[ERROR] function LandRecordLayer:addCard CardType:(%d) count == %d\n", key, count);
            count = 0;
        end
        item.m_nCount =  count;
        item:setString(count);
        item:setColor(cc.c3b(0xdd,0xd5,0xca));
    end
end

function LandRecordLayer:clearCard()
    for k, item in pairs(self.m_pCardItems) do
        item.m_nCount = self.m_pCardCounts[k];
        item:setString(item.m_nCount);
        item:setColor(cc.c3b(0xf5, 0x8d, 0x12));
    end
end

function LandRecordLayer:showView()
    if self.m_pBack:isVisible() then
        return;
    end
    --local size = self.m_pCardList:getContentSize();
    --self.m_pCardList:setPosition(display.size.width/2, display.size.height + size.height);
    --self.m_pCardList:runAction(cc.MoveTo:create(0.1, cc.p(display.size.width/2, display.size.height - 20)));
    self.m_pBack:setVisible(true);
    self.m_pTips:setVisible(false);
    self.m_pCardList:setVisible(false);
    if (Player:getVipMoney() >= 30) then
        self.m_pCardList:setVisible(true);
        self.m_pCardList:setScale(0, 1);
        self.m_pCardList:runAction(cc.ScaleTo:create(0.1, 1));
        self.m_pCardList:setVisible(true);
    else
        self.m_pTips:stopAllActions();
        self.m_pTips:setVisible(true);
        self.m_pTips:setScale(0, 1);
        self.m_pTips:setOpacity(255);
        self.m_pTips:runAction( cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1),
            cc.DelayTime:create(5.0),
            cc.FadeIn:create(0.2),
            cc.CallFunc:create(function()
                self:hideView();
            end),
        nil));
        --self.m_pTips:setVisible(true);
    end
    sendMsg("MSG_Game_LandRecordLayer.State", true);
end

function LandRecordLayer:hideView()
    self.m_pBack:setVisible(false);
    self.m_pTips:stopAllActions();
    sendMsg("MSG_Game_LandRecordLayer.State", false);
end

function LandRecordLayer:_OnShowCardList(taget)
    if self.m_pBack:isVisible() then
        self:hideView();
    else
        self:showView();
    end
end

return LandRecordLayer;