-- LandAccounts
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快游戏结算界面
local CardConfig = require("app.game.pdk.src.landcommon.data.CardConfig")
local GameLogic = require("app.game.pdk.src.landcommon.logic.GameLogic")
local scheduler = require("framework.scheduler")
local LandGlobalDefine = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local HNLayer = require("src.app.newHall.HNLayer")
local LandAccounts = class("LandAccounts", function()
    return HNLayer.new()
end)


--节点坐标位置
local Node_Pos = {
    [1] = {{x = 542, y = 23}},
    [2] = {{x = 424, y = 23}, {x = 660, y = 23}},
    [3] = {{x = 306, y = 23}, {x = 542, y = 23}, {x = 798, y = 23}}
}

LandAccounts.ACCOUNTS_EXIT_BTN =      20001      --退出
LandAccounts.ACCOUNTS_SHARE_BTN =     20002      --分享
LandAccounts.ACCOUNTS_CONTINUE_BTN =  20003      --继续

function LandAccounts:ctor( landMainScene , winOrLose , roomType, gameEndPram)
    self.m_layerNode = nil
    self.last_click_again_game = 0
    self.m_roomType = roomType
    self.m_winOrLose = winOrLose
    self.m_LandMainScene = landMainScene
    self.gameEndPram = gameEndPram
    self:init()
    --self:checkIOS()
    self:setContinueButtonEnable(false)

    -- 倒计时退出
    self._schedulerEnd  = scheduler.performWithDelayGlobal(function ( ... )
        if g_GameController then 
            g_GameController:releaseInstance()
        end
    end, 15)
end

function LandAccounts:init()
    self.m_scale = 1.5
    -- if self.m_winOrLose == "win" then
        self.m_layerNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_common_cs/land_account_win.csb")
        self.winPancel = self.m_layerNode:getChildByName("win_panel@5")
        self.winPancel:setPositionX(display.cx)
        self.lord_img_win_guang = self.m_layerNode:getChildByName("lord_img_win_guang")
        local t_childrenname = 
        {
            "lord_bg_win", "lord_bg_win_Copy", "lord_txt_win", "bottom_bg", "top_bg",
            "bg_bg", "lord_bg_1", "lord_bg_2", "lord_bg_3", "Panel_1", "Panel_2",
            "gold_node", "text_tips", 
            -- "btns_panel", 
        }
        for k,v in pairs(t_childrenname) do
            self.winPancel:getChildByName(v):setOpacity(0)
        end
    -- else
    --     self.m_layerNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/land_common_cs/land_account_lose.csb")
    --     self.lost_panel = self.m_layerNode:getChildByName("lost_panel@5")
    --     self.lost_panel:setPositionX(display.cx)
    -- end
    UIAdapter:adapter(self.m_layerNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_layerNode,5)

    -- 按钮处理
    self.btns_panel = self.m_layerNode:getChildByName("btns_panel")
    self.back_pancel = self.m_layerNode:getChildByName("back_pancel")
    self.exit_btn = self.back_pancel:getChildByName("exit_btn")
    self.exit_btn:setTag(LandAccounts.ACCOUNTS_EXIT_BTN)
    self.continue_button = self.btns_panel:getChildByName("continue_button")
    self.continue_button:setTag(LandAccounts.ACCOUNTS_CONTINUE_BTN)
    self.share_button = self.btns_panel:getChildByName("share_button")
    self.share_button:setTag(LandAccounts.ACCOUNTS_SHARE_BTN)
	self.continue_button_label = self.btns_panel:getChildByName("continue_label")
	self.share_button_label = self.btns_panel:getChildByName("share_label")
	self.share_button_label:setString("离开游戏")
    self.exit_btn:addTouchEventListener(handler(self ,self.onTouchAccountButton))
    self.continue_button:addTouchEventListener(handler(self ,self.onTouchAccountButton))
    self.share_button:addTouchEventListener(handler(self ,self.onTouchAccountButton))
    self.back_pancel:setVisible(false)
    self.exit_btn:setPositionY(self.exit_btn:getPositionY() - 50)
    self.continue_button:setPositionY(self.continue_button:getPositionY() - 50)
    self.share_button:setPositionY(self.share_button:getPositionY() - 50)

    -- 先隐藏
    for i=1,2 do
        self["Panel_"..i] = self.m_layerNode:getChildByName("Panel_"..i)
    end
    for j=1,6 do
        self["node_" .. j] = self.m_layerNode:getChildByName("node_" .. j)
        self["node_" .. j]:setVisible(false)
    end
    self.m_Tips = self.m_layerNode:getChildByName("text_tips")
    self.m_Tips:setVisible(false)
    self.gold_node = self.m_layerNode:getChildByName("gold_node")
    self.gold_node:setVisible(false)
    self.m_text_gold_count = self.gold_node:getChildByName("text_gold_count")
    self.m_text_gold_count:setVisible(false)
    self.lord_icon_gold = self.gold_node:getChildByName("lord_icon_gold")
    self.lord_icon_gold:setVisible(false)

    -- 玩家信息
    dump(self.gameEndPram, "self.gameEndPram")
    local gameEndPram = self.gameEndPram
    local n_mechair = gameEndPram.meChair
    local t_gamescore = gameEndPram.lGameScore
    local t_remaincount = gameEndPram.nRemainCount
    local t_bombscore = gameEndPram.lBombScore
    local t_info = {
        { anchor = cc.p(0.5, 1), pos = cc.p(display.cx, display.cy - 40), },
        { anchor = cc.p(0, 0), pos = cc.p(display.cx + 40, display.cy), },
        { anchor = cc.p(1, 0), pos = cc.p(display.cx - 40, display.cy), },
    }
    local t_chair = {
        {1,2,3},
        {2,3,1},
        {3,1,2}
    }
    -- 最大分
    local n_maxvalue = -math.huge
    local t_maxvalue = {}
    for i=1,table.maxn(t_info) do
        if n_maxvalue < t_gamescore[i] then 
            n_maxvalue = t_gamescore[i]
        end
    end
    -- 玩家显示
    local m_node_players = cc.Node:create()
    self.m_layerNode:addChild(m_node_players)
    self.m_node_players = m_node_players
    for index=1,table.maxn(t_info) do
        local i = t_chair[n_mechair][index]
        local v = t_info[index]
        local n_remaincount = t_remaincount[i]
        local n_sumscore = t_gamescore[i]
        local b_indemnityChairId = gameEndPram.m_indemnityChairId == i 
        local s_textatlas = "alter/fj_result_one_winner_s_num.png"
        if n_sumscore < 0 then 
            s_textatlas = "alter/fj_result_one_loser_s_num.png"
        end
        if n_sumscore == 0 and n_remaincount > 0 then 
            s_textatlas = "alter/fj_result_one_loser_s_num.png"
        end
        local s_sumscore = "/" .. math.abs(n_sumscore)/100
        local n_bombscore = t_bombscore[i]/100
        -- 
        local item_bg = ccui.ImageView:create("fj_result_item_bg_01.png", 1);
        item_bg:setAnchorPoint(v.anchor)
        item_bg:setPosition(v.pos)
        item_bg:setScale(0.8)
        m_node_players:addChild(item_bg)
        local item_size = item_bg:getContentSize()
        -- 最大分图
        if n_sumscore == n_maxvalue and n_sumscore > 0 then
            item_bg:loadTexture("fj_result_item_bg_02.png", 1)
            local img_result = ccui.ImageView:create("fj_result_crown.png", 1)
            img_result:setPosition(cc.p(item_size.width, item_size.height))
            item_bg:addChild(img_result)
        end
        -- 赢家 输家 分开处理
        if n_remaincount == 0 then 
            -- 赢家
        else
            -- 输家 剩牌
            local img_remain = ccui.ImageView:create("fj_result_txt_remain.png", 1)
            img_remain:setAnchorPoint(cc.p(1, 1))
            img_remain:setPosition(cc.p(item_size.width*0.3, item_size.height*0.92))
            item_bg:addChild(img_remain)
            local txt_remain = ccui.Text:create()
            txt_remain:setFontSize(30)
            txt_remain:setAnchorPoint(cc.p(0, 1))
            if device.platform == "android" then
                txt_remain:setPosition(cc.p(item_size.width*0.3, item_size.height*0.950))
            else
                txt_remain:setPosition(cc.p(item_size.width*0.3, item_size.height*0.928))
            end
            item_bg:addChild(txt_remain)
            txt_remain:setString(n_remaincount)
        end
        -- 炸弹
        do
            local img_remain = ccui.ImageView:create("fj_result_txt_bomb.png", 1)
            img_remain:setAnchorPoint(cc.p(1, 1))
            img_remain:setPosition(cc.p(item_size.width*0.7, item_size.height*0.945))
            item_bg:addChild(img_remain)
            local txt_remain = ccui.Text:create()
            txt_remain:setFontSize(30)
            txt_remain:setAnchorPoint(cc.p(0, 1))
            if device.platform == "android" then
                txt_remain:setPosition(cc.p(item_size.width*0.7, item_size.height*0.950))
            else
                txt_remain:setPosition(cc.p(item_size.width*0.7, item_size.height*0.923))
            end
            item_bg:addChild(txt_remain)
            txt_remain:setString(n_bombscore)
        end
        -- 包赔
        if b_indemnityChairId then
            local txt_remain = ccui.Text:create()
            txt_remain:setFontSize(30)
            txt_remain:setColor(cc.c3b(0xff, 0xff, 0xff))
            txt_remain:setAnchorPoint(cc.p(0, 1))
            txt_remain:setPosition(cc.p(item_size.width*0, item_size.height*1))
            item_bg:addChild(txt_remain)
            txt_remain:setString("包赔")
        end
        -- 总分
        local txt_sumscore = ccui.Text:create()
        txt_sumscore:setPosition(cc.p(item_size.width*0.15, item_size.height*0.35))
        txt_sumscore:setString("总分:")
        txt_sumscore:setFontSize(30)
        item_bg:addChild(txt_sumscore)
        local txt_atlas = ccui.TextAtlas:create( "",  s_textatlas, 64, 83, ".")
        txt_atlas:setPosition(cc.p(item_size.width*0.60, item_size.height*0.35))
        txt_atlas:setScale(0.5)
        item_bg:addChild(txt_atlas)
        txt_atlas:setString(s_sumscore)
    end
    -- 隐藏界面按钮
    local btn_hide = self.continue_button:clone()
    self.continue_button:getParent():addChild(btn_hide)
    btn_hide:removeAllChildren()
    btn_hide:setScale(1.0)
    btn_hide:setPositionX(btn_hide:getPositionX() + 250)
    btn_hide:loadTextures("fj_result_total_txt_sp.png", "", "", 1)
    btn_hide:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.began then
           self:setOpacity(0)
           self.m_layerNode:setOpacity(0)
           self.btns_panel:setVisible(false)
           self.back_pancel:setVisible(false)
           self.m_node_players:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
           self:setOpacity(255)
           self.m_layerNode:setOpacity(255)
           self.btns_panel:setVisible(true)
           -- self.back_pancel:setVisible(true)
           self.m_node_players:setVisible(true)
        end
    end)
end

--[[
function LandAccounts:checkIOS()
    if GlobalConf.IS_IOS_TS == true then
        self.btns_panel:setVisible(false)
    end
end
--]]

function LandAccounts:check( pGameEnd)
    self.strText = {}

    local i = 1
    if pGameEnd.mingNum and pGameEnd.mingNum ~= 0 then
        self.strText[i] = {str= "明牌:", str1 = (pGameEnd.mingNum.."倍")}
        i = i + 1
    end
    if pGameEnd.bomCount and pGameEnd.bomCount ~= 0 then
        self.strText[i] = {str= "炸弹:", str1 = (pGameEnd.bomCount.."个")}
        i = i + 1
    end
    if pGameEnd.bChuntian and pGameEnd.bChuntian ~= 0 then
        self.strText[i] = {str= "春天:", str1 = "有"}
        i = i + 1
    end
    if pGameEnd.baseNum and pGameEnd.baseNum ~= 0 then
        self.strText[i] = {str= "叫分:",str1 = (pGameEnd.baseNum.."分")}
        i = i + 1
    end
    if pGameEnd.jiaNum and pGameEnd.jiaNum >1 then
        self.strText[i] = {str= "加倍:",str1 = (pGameEnd.jiaNum.."倍")}
        i = i + 1
    end
    if pGameEnd.qiangNum and pGameEnd.qiangNum >1 then
        self.strText[i] = {str= "抢地主:", str1 = (pGameEnd.qiangNum.."倍")}
        i = i + 1
    end 
    if pGameEnd.teNum and pGameEnd.teNum ~= 0  then
        self.strText[i] = {str= "底牌倍数:", str1 = (pGameEnd.teNum.."倍")}
        i = i + 1
    end 
end

function LandAccounts:show()
    local pos1 =  178 
    for k,v in ipairs(self.strText) do
        self["node_" .. k] :setVisible(true) 
        self["node_" .. k]:getChildByName("text_" .. k):setString(v.str)
        self["node_" .. k]:getChildByName("context_" .. k):setString(v.str1)
    end

    if #self.strText == 0 then
        self.gold_node:setPositionY(140)
        return
    elseif #self.strText == 1 then
        self["node_1"]:setPosition(cc.p(Node_Pos[1][1].x, Node_Pos[1][1].y))
        self.Panel_1:setPositionY(pos1)
    elseif #self.strText == 2 then
        for i=1, 2 do
            self["node_".. i]:setPosition(cc.p(Node_Pos[2][i].x, Node_Pos[2][i].y))
        end
        self.Panel_1:setPositionY(pos1)
    elseif #self.strText == 3 then
        for i=1, 3 do
            self["node_".. i]:setPosition(cc.p(Node_Pos[3][i].x, Node_Pos[3][i].y))
        end
        self.Panel_1:setPositionY(pos1)
    elseif #self.strText > 3 then
        -------------------------------------
    end
end

function LandAccounts:updateGameResult( pGameEnd,retFlag)
    dump(pGameEnd,"LandAccounts:updateGameResult( pGameEnd)")
    self:check(pGameEnd)
    self:show()

    local lord_icon_gold = self.gold_node:getChildByName("lord_icon_gold")    
    if retFlag == "win" then

        local str = tostring(pGameEnd.lGameScore[pGameEnd.meChair]*0.01)
        local my_rank_label1 =ccui.TextAtlas:create( str,  "number/lord_num_win.png",30,40,".")
        my_rank_label1:setAnchorPoint(cc.p(0,0.5))
        my_rank_label1:setPosition(cc.p(lord_icon_gold:getContentSize().width+20,lord_icon_gold:getContentSize().height/2))
        lord_icon_gold:addChild(my_rank_label1)

        local wid = lord_icon_gold:getContentSize().width + my_rank_label1:getContentSize().width
        lord_icon_gold:setPositionX(-wid*self.m_scale/2)

        if pGameEnd.lGameScore[pGameEnd.meChair] == 0 then --正常
            self.m_Tips:setVisible(true)
        else
            self.m_Tips:setVisible(false)
        end
    else
        local score  = math.abs(pGameEnd.lGameScore[pGameEnd.meChair])*0.01
        local str =tostring(score)
        local my_rank_label1 = ccui.TextAtlas:create( str,  "number/lord_num_lost.png",30,40,".")
        my_rank_label1:setAnchorPoint(cc.p(0,0.5))
        my_rank_label1:setPosition(cc.p(lord_icon_gold:getContentSize().width+20,lord_icon_gold:getContentSize().height/2))
        lord_icon_gold:addChild(my_rank_label1)
        lord_icon_gold:setTexture("ddz_anniu_lusejianhao.png")
        local wid = lord_icon_gold:getContentSize().width + my_rank_label1:getContentSize().width
        lord_icon_gold:setPositionX(-wid*self.m_scale/2)

--        if pGameEnd.lGameScore[pGameEnd.meChair] < 0 and pGameEnd.meChair ~= pGameEnd.lordChair and pGameEnd.isChen == true then --我的分小于0,不是地主,三个人中有0分 说明我是拖管的
--            self.m_Tips:setVisible(true)
--        else
--            self.m_Tips:setVisible(false)
--        end
    end

end

function LandAccounts:updateHappyLandGameResult( pGameEnd)
    dump( pGameEnd,"LandAccounts:updateHappyLandGameResult( pGameEnd)")
    self:check(pGameEnd)
    self:show()

    local lord_icon_gold = self.gold_node:getChildByName("lord_icon_gold")
    if self.m_winOrLose == "win" then
        local str = tostring(pGameEnd.lGameScore[pGameEnd.meChair])*0.01
        local my_rank_label1 = ccui.TextAtlas:create( str,  "number/lord_num_win.png",30,40,".")
        my_rank_label1:setAnchorPoint(cc.p(0,0.5))
        my_rank_label1:setPosition(cc.p(lord_icon_gold:getContentSize().width,lord_icon_gold:getContentSize().height/2))
        lord_icon_gold:addChild(my_rank_label1)

        local wid = lord_icon_gold:getContentSize().width + my_rank_label1:getContentSize().width
        lord_icon_gold:setPositionX(-wid*self.m_scale/2)

        if pGameEnd.lGameScore[pGameEnd.meChair] == 0 then --正常
            self.m_Tips:setVisible(true)
        else
            self.m_Tips:setVisible(false)
        end
    else
        local score  = math.abs(pGameEnd.lGameScore[pGameEnd.meChair])*0.01
        local str =  tostring(score)
        local my_rank_label1 = cc.LabelAtlas:_create( str,  "number/lord_num_lost.png",30,40,".")
        my_rank_label1:setAnchorPoint(cc.p(0,0.5))
        my_rank_label1:setPosition(cc.p(lord_icon_gold:getContentSize().width,lord_icon_gold:getContentSize().height/2))
        lord_icon_gold:addChild(my_rank_label1)

        local wid = lord_icon_gold:getContentSize().width + my_rank_label1:getContentSize().width
        lord_icon_gold:setPositionX(-wid*self.m_scale/2)

        if pGameEnd.isChen == true then
            self.m_Tips:setVisible(true)
        else
            self.m_Tips:setVisible(false)
        end
    end
end

function LandAccounts:setContinueButtonEnable(isEnable)
    if self.continue_button then
        self.continue_button:setEnabled(isEnable)
    end
end

function LandAccounts:onTouchAccountButton(sender,eventType)
    if sender and sender:getTag() then
        local tag = sender:getTag()
        print("tag is"..tag)
        if eventType == ccui.TouchEventType.ended then
           if tag == LandAccounts.ACCOUNTS_EXIT_BTN  then        --退出
			   print("LandAccounts:onTouchAccountButton onClickTuiChu")
               self:onClickTuiChu()
           elseif tag == LandAccounts.ACCOUNTS_SHARE_BTN then    --分享
               self:onClickTuiChu()
           elseif tag == LandAccounts.ACCOUNTS_CONTINUE_BTN then --继续
                self:keepGoingGame()
           end
        end
    end
end

function LandAccounts:onClickTuiChu( ... ) 
    if self._schedulerEnd then
        scheduler.unscheduleGlobal(self._schedulerEnd)
        self._schedulerEnd = nil
    end
	self:close()
	self.m_LandMainScene:exit()
end

--继续事件的处理
function LandAccounts:keepGoingGame()   
    if self._schedulerEnd then
        scheduler.unscheduleGlobal(self._schedulerEnd)
        self._schedulerEnd = nil
    end
    self:close()
    self.m_LandMainScene:onAgainGame()
end

--分享事件的处理
function  LandAccounts:shareButtonCallBack()
    QKA_SHARE( self.m_LandMainScene:getGameAtom() )
end

-- 点击事件回调
function LandAccounts:onTouchCallback( sender )
    local name = sender:getName()
    print("LandAccounts:onTouchCallback",name)
end

function LandAccounts:LandMusicSetLayer( sender )
    local name = sender:getName()
    print("name: ", name)
    if name == "btn_close" then
        self:setVisible(false)
    end
end

return LandAccounts
