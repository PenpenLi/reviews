local MatchWaitLayer = class("MatchWaitLayer", function()
    return display.newLayer();
end);


function MatchWaitLayer:ctor()
    self.m_nTimeIndex = 1;
    self:initCSB();
end

function MatchWaitLayer:initCSB()
    local layer = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_wait_view.csb");
    self:addChild(layer);
    self.m_pRoot = layer:getChildByName("root");
    self.m_pRoot:setPosition(display.size.width / 2, display.size.height / 2);
    self.m_pRoot:setAnchorPoint(cc.p(0.5, 0.5));
    self.m_pTimeText = self.m_pRoot:getChildByName("time_text");
    self.m_pRankText = self.m_pRoot:getChildByName("text_rank");
    self:setVisible(false);
end

function MatchWaitLayer:setData(__info)
    local info = {
        m_curRank = g_GameController.m_curRank or 0,
        m_roundIndex = g_GameController.m_roundIndex or 0,
        m_roundNum = g_GameController.m_roundNum or 0,
        m_roundPlayerNum = g_GameController.m_roundPlayerNum or 0,
        m_upgradeCnt = g_GameController.m_upgradeCnt or 0
    };
    -- self.m_roundIndex = info.m_roundIndex;      -- 第N轮
    -- self.m_roundNum = info.m_roundNum;          -- 总N轮
    local promotion_node = self.m_pRoot:getChildByName("promotion_node");
    local bar_node = self.m_pRoot:getChildByName("bar_node");
    -- local text_rank = self.m_pRoot:getChildByName("text_rank");
    -- local time_text = self.m_pRoot:getChildByName("time_text");

    self.m_upgradeCnt = info.m_upgradeCnt;
    -- self.m_nLeftTime = 10;
    -- self.m_nTimeIndex = 1;

    -- self.m_pRankText:setString("" .. info.m_curRank);
    -- self.m_pTimeText:setString(string.format("等待其他桌结束，确认前%d晋级名单，预计还有%d秒。", self.m_upgradeCnt, self.m_nLeftTime));
    
    -- self:stopAllActions();
    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(handler(self, self.updateTime)), nil));


    local progress_bar = bar_node:getChildByName("progress_bar");
    local bar_1 = bar_node:getChildByName("bar_1");
    local bar_2 = bar_node:getChildByName("bar_2");
    local bar_icon_1 = bar_node:getChildByName("icon_1");
    local bar_icon_2 = bar_node:getChildByName("icon_2");
    local bar_icon_3 = bar_node:getChildByName("icon_3");

    if 2 == info.m_roundIndex then
        bar_1:setVisible(true);
        bar_2:setVisible(false);
        bar_icon_1:setVisible(true);
        bar_icon_2:setVisible(true);
        bar_icon_3:setVisible(false);
    elseif 3 == info.m_roundIndex then
        bar_1:setVisible(true);
        bar_2:setVisible(true);
        bar_icon_1:setVisible(true);
        bar_icon_2:setVisible(true);
        bar_icon_3:setVisible(true);
    else
        bar_1:setVisible(false);
        bar_2:setVisible(false);
        bar_icon_1:setVisible(true);
        bar_icon_2:setVisible(false);
        bar_icon_3:setVisible(false);
    end

    local promotion_1 = promotion_node:getChildByName("promotion_1");
    local promotion_2 = promotion_node:getChildByName("promotion_2");
    local promotion_3 = promotion_node:getChildByName("promotion_3");

    for index = 1, 3 do
        local promotion = promotion_node:getChildByName(string.format("promotion_%d", index));
        local image_1 = promotion:getChildByName("image_1");
        local image_2 = promotion:getChildByName("image_2");
        local image_3 = promotion:getChildByName("image_3");

        local text_lun = promotion_node:getChildByName(string.format("text_lun_%d", index));
        if index < info.m_roundIndex then
            image_1:setVisible(false);
            image_2:setVisible(true);
            image_3:setVisible(false);
            text_lun:setColor(cc.c3b(255, 255, 255));
        elseif index == info.m_roundIndex then
            image_1:setVisible(true);
            image_2:setVisible(false);
            image_3:setVisible(false);
            text_lun:setColor(cc.c3b(255, 255, 255));
        else
            image_1:setVisible(false);
            image_2:setVisible(false);
            image_3:setVisible(true);
            text_lun:setColor(cc.c3b(89, 83, 93));
        end

        if index == 1 then
            image_1:getChildByName("text_rank"):setString("9")
            image_2:getChildByName("text_rank"):setString("9")
            image_3:getChildByName("text_rank"):setString("9")
        end
    end

end

function MatchWaitLayer:showView()
    if not self:isVisible() then
        self:setVisible(true);
        self.m_nLeftTime = 31;
        self.m_nTimeIndex = 1;
        self:updateTime();
    end
end

function MatchWaitLayer:hideView()
    self:stopAllActions();
    self:setVisible(false);
end

function MatchWaitLayer:updateTime()
    self.m_nLeftTime = self.m_nLeftTime - 1;
    if self.m_nLeftTime < 0 then
        self.m_nTimeIndex = self.m_nTimeIndex + 1;
        if 2 == self.m_nTimeIndex then
            self.m_nLeftTime = 15;
        else
            self.m_nLeftTime = 10;
            self.m_nTimeIndex = 3;
        end
    end

    self.m_pRankText:setString("" .. g_GameController.m_curRank);
    self.m_pTimeText:setString(string.format("等待其他桌结束，确认前%d晋级名单，预计还有%d秒。", self.m_upgradeCnt, self.m_nLeftTime));
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(handler(self, self.updateTime)), nil));
end


return MatchWaitLayer;