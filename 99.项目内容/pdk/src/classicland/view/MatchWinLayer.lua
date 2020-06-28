--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local scheduler            = require("framework.scheduler")
local HNLayer = require("src.app.newHall.HNLayer")
local MatchWinLayer = class("MatchWinLayer", function()
    return HNLayer.new()
end)

function MatchWinLayer:ctor()
    self:myInit()
    self:setupView()
end
function MatchWinLayer:onTouchCallback(sender)
    local name = sender:getName()
end
function MatchWinLayer:setupView()
    local node = UIAdapter:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_win.csb")
    --  UIAdapter:praseNode(node,self) 
    self:addChild(node)
    --     self._winSize = cc.Director:getInstance():getWinSize() 
    --        if (self._winSize.width / self._winSize.height > 1.78) then
    ----            posx = (self._winSize.width*display.scaleX-self._winSize.width)/ 2
    ----            node:setPositionX(posx)
    --            node:setScaleX(display.scaleX)
    --        end
    local diffY = (display.size.height - 750) / 2
    node:setPosition(cc.p(0, diffY))
    local diffX = 145 - (1624 - display.size.width) / 2
    local pCenter = node:getChildByName("center");
    pCenter:setPositionX(diffX);

    local close_button = pCenter:getChildByName("button_close");
    --close_button:addTouchEventListener(handler(self, self.onCloseClick));
    close_button:setVisible(false);

    local pNode = pCenter:getChildByName("Node_1");
    self.m_pBg = pNode:getChildByName("rank_bg");
    self.m_pRankNumText = pNode:getChildByName("rank_num_text");
    local rank_doc_bg = pCenter:getChildByName("rank_doc_bg");
    self.m_pRankDocText = rank_doc_bg:getChildByName("rank_doc_text");
    self.m_pCoinText = rank_doc_bg:getChildByName("coin_text");
    self.m_pEffctStar = pNode:getChildByName("star");
end

function MatchWinLayer:setWinData(info)

    -- for k,v in pairs(info.m_lastRankAward) do
    --     self["name_"..v.m_rank]:setString(v.m_nickname)
    --     self["score_"..v.m_rank]:setString(v.m_score)
    --     self["award_"..v.m_rank]:setString(v.m_award*0.01)
    -- end
    if 3 < info.m_curRank then
        if self.m_pEffctStar ~= nil then
            self.m_pEffctStar:setVisible(true);
        end
        self.m_pRankNumText:setString(string.format("%d", info.m_curRank));
    else
        if self.m_pEffctStar ~= nil then
            self.m_pEffctStar:setVisible(false);
        end
        self.m_pRankNumText:setVisible(false);
        self.m_pBg:loadTexture(string.format("game/lord/gui/result/match_promotion_result_%d.png", info.m_curRank));
    end

    if info.m_goldCoin > 0 then
        self.m_pRankDocText:getParent():setVisible(true);
        self.m_pCoinText:setString(string.format("%.02f", info.m_goldCoin * 0.01));
        --self.m_pRankDocText:setString(string.format( "获得排位奖励%.02f元,请在邮件领取！", info.m_goldCoin *0.01 ));
    else
        self.m_pCoinText:getParent():setVisible(false);
    end

    local node = cc.Node:create();
    self:addChild(node);
    node:runAction(cc.Sequence:create(
        cc.DelayTime:create(5),
        cc.CallFunc:create(function()
            g_GameController:releaseInstance();
        end),
    nil));
end


-- function MatchWinLayer:onCloseClick()
--     -- UIAdapter:popScene();
--     g_GameController:reqMatchExitGame();
-- end

-- function MatchWinLayer:onJiXuClick()
--     local nGameId = g_GameController:getGameAtomTypeId();
--     UIAdapter:popScene();
--     local MatchController = require("src/app/hall/MatchGameList/control/MatchController");
--     MatchController.getInstance():openView("MatchGameListView");
--     MatchController.getInstance():startGame(nGameId);
-- end
return MatchWinLayer