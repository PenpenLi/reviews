--单局结算ui

local MatchResultOneLayer = class("MatchResultOneLayer", function()
    return display.newLayer();
end);

function MatchResultOneLayer:ctor()
    self:initCSB();
end

function MatchResultOneLayer:initCSB()
    self:setName("MatchResultOneLayer");
    local layer = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_match_cs/land_match_result.csb");
    -- local layer = cc.CSLoader:createNode("classic_land_cs/jiesuan.csb")
    self.root = layer:getChildByName("root");
    self:addChild(layer);

    self.root:setPosition(display.size.width/2, display.size.height/2);
    self.root:setAnchorPoint(cc.p(0.5, 0.5));

    self.root:getChildByName("time_text"):setVisible(false);
    self.m_panel = self.root:getChildByName("Node_4");
    
end

function MatchResultOneLayer:showView(delay, time)
    self:setVisible(false);
    -- self:runAction(
    --     cc.Sequence:create(cc.DelayTime:create(time), cc.RemoveSelf:create(), nil)
    -- );

    self.root:setVisible(true);
    self.root:setOpacity(0);
    self.root:setScale(0.1);
    self.root:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.CallFunc:create(function()
                self:setVisible(true);
            end),
            cc.Spawn:create(
                cc.ScaleTo:create(0.1, 1.05),
                cc.FadeIn:create(0.1)
            ),
            cc.ScaleTo:create(0.05, 1),
            cc.DelayTime:create(time), 
            cc.Hide:create(),
            cc.CallFunc:create(function()
                self:setVisible(false);
                g_GameController.gameScene:showMatchWaitView();
            end),
        nil)
    );

end

function MatchResultOneLayer:hideView()
    self.root:stopAllActions();
    self:setVisible(false);
end


function MatchResultOneLayer:setResult(info, game_chair_tbl)
--     CS_G2C_LandLord_Result_Nty		=
-- {
-- 	{ 1		, 1		, 'm_bSpring'			,		'UBYTE'		, 1		, '[0]否[1]是'},
-- 	{ 2		, 1		, 'm_nTotalMultiple'	,		'UINT'		, 1		, '总倍数'},
-- 	{ 3		, 1		, 'm_nTotalBombs'		,		'UINT'		, 1		, '炸弹个数'},
-- 	{ 4		, 1		, 'm_vecScore'			,		'INT'		, 3		, '记分(单位:金币)'},
-- 	{ 5		, 1		, 'm_vec1ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 6		, 1		, 'm_vec2ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},
-- 	{ 7		, 1		, 'm_vec3ChairCards'	, 		'UINT'		, 20	, '剩余手牌[0-53]黑红花片(3-KA2)小王大王'},
	
-- 	{ 8		, 1		, 'm_nCurRound'			,		'UINT'		, 1		, '当前轮数'},
-- 	{ 9		, 1		, 'm_nTotalRound'		,		'UINT'		, 1		, '总轮数'},
-- 	{ 10	, 1		, 'm_nLandPos'			,		'UINT'		, 1		, '地主位置 1 2 3'},
-- 	{ 11	, 1		, 'm_nLandCent'			,		'UINT'		, 1		, '地主叫分'},
-- 	{ 12	, 1		, 'm_nEndPos'			,		'UINT'		, 1		, '最后一手出牌的位置 1 2 3'},
	
-- }

    for index = 1, 3 do
        local chair_tbl = game_chair_tbl[index];

        local n = 1;
        local csbName = chair_tbl:getCSBName();
        if "left" == csbName then
            n = 2;
        elseif "right" == csbName then
            n = 3;
        end


        local card_num = #(info[string.format( "m_vec%dChairCards", index ) ]);
        local score = info.m_vecScore[index];
        local bomb = info.m_nTotalBombs[index];

        self:setOneData(n, {score = score, bom_num = bomb, card_num = card_num}, chair_tbl);
    end
end

function MatchResultOneLayer:setOneData(index, data, chair_tbl)
    local node = self.m_panel:getChildByName(string.format( "ImageView_%d", index ));
    local crown_coin = node:getChildByName("crown_icon");
    local lose_score_text = node:getChildByName("lose_score_text");
    local win_score_text = node:getChildByName("win_score_text");

    local card_num_text = node:getChildByName("Text_100");
    local bom_text = node:getChildByName("Text_101");
    
    card_num_text:setString( string.format( "剩牌：%d", data.card_num ));
    bom_text:setString(string.format( "炸弹：%d", data.bom_num ));

    lose_score_text:setString(string.format("/%d", math.abs( data.score ) ));
    win_score_text:setString(string.format("/%d", math.abs( data.score ) ));


    if data.score <= 0 then
        crown_coin:setVisible(false);
        win_score_text:setVisible(false);
        lose_score_text:setVisible(true);
        --node:loadTexture("game/lord/gui/result/FJGameResult015.png");
    else
        crown_coin:setVisible(true);
        win_score_text:setVisible(true);
        lose_score_text:setVisible(false);
        --node:loadTexture("game/lord/gui/result/FJGameResult029.png");
    end

    if data.card_num <= 0 then
        crown_coin:setVisible(true);
        -- card_num_text:setVisible(false);
        -- bom_text:setVisible(false);
        -- node:getChildByName("Text_100"):setVisible(false);
        -- node:getChildByName("Text_101"):setVisible(false);
    else
        crown_coin:setVisible(false);
        -- card_num_text:setVisible(true);
        -- bom_text:setVisible(true);
        -- node:getChildByName("Text_100"):setVisible(true);
        -- node:getChildByName("Text_101"):setVisible(true);
    end

    local head_node = node:getChildByName("head");
    local head_icon = head_node:getChildByName("icon");
    local head_name = head_node:getChildByName("name_text");
    local faceId = g_GameController.__players[chair_tbl.chair].m_faceId;
    local head = ToolKit:getHead( faceId );
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(head);
    head_icon:setSpriteFrame(frame);
    head_name:setString(chair_tbl.nick_name);

    head_icon:setScale( (head_node:getContentSize().width - 15) / head_icon:getContentSize().width );

end






return MatchResultOneLayer;


