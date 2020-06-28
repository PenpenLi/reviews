 
local scheduler              =  require("framework.scheduler") 
local HNLayer= require("src.app.newHall.HNLayer") 
local MatchTaotaiLayer = class("MatchTaotaiLayer",function ()
     return HNLayer.new()
end)

function MatchTaotaiLayer:ctor()
    self:myInit()
    self:setupView()
end
function MatchTaotaiLayer:onTouchCallback(sender)
    local name = sender:getName() 
end
function MatchTaotaiLayer:setupView() 
    local node = UIAdapter:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_lose.csb")  
    -- UIAdapter:praseNode(node,self) 
    self:addChild(node)
    local diffY = (display.size.height - 750) / 2
    node:setPosition(cc.p(0,diffY)) 
    local diffX = 145-(1624-display.size.width)/2 
    local pCenter = node:getChildByName("center");
    pCenter:setPositionX(diffX);

    local bg = pCenter:getChildByName("bg2");
    self.m_pRankNumText = bg:getChildByName("rank_num_text");
    
    local close_button = pCenter:getChildByName("button_close");
    --close_button:addTouchEventListener(handler(self, self.onCloseClick));

    close_button:setVisible(false);

    local jixu_button = pCenter:getChildByName("Button_1");
    jixu_button:addTouchEventListener(handler(self, self.onJiXuClick));
    -- jixu_button:setVisible(false);


end 
function MatchTaotaiLayer:setData(info) 
    -- self["rank"]:setString(info.m_curRank or info.m_showRank)
    -- local function callback()
    --    UIAdapter:popScene()
    -- end

    self.m_pRankNumText:setString(string.format( "%d",info.m_curRank ));

    local node = cc.Node:create();
    self:addChild(node);
    node:runAction(cc.Sequence:create(
        cc.DelayTime:create(5),
        cc.CallFunc:create(function()
            self:onCloseClick();
        end),
    nil));
end  

function MatchTaotaiLayer:onCloseClick()
    -- UIAdapter:popScene();
    --g_GameController:reqMatchExitGame();
    g_GameController:releaseInstance();
end

function MatchTaotaiLayer:onJiXuClick()
    local nGameId = g_GameController:getGameAtomTypeId();
    -- UIAdapter:popScene();
    self:onCloseClick();
    local MatchController = require("src/app/hall/MatchGameList/control/MatchController");
    -- --MatchController.getInstance():openView("MatchGameListView", nil, 0.2);
    MatchController.getInstance():startGame(nGameId, 0.3);
    
end

return MatchTaotaiLayer