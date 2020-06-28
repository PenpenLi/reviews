--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
----------------------------------------------------------------------------------------------------------
-- 项目：红黑大战
-- 时间: 2018-01-11
----------------------------------------------------------------------------------------------------------
local Scheduler        = require("framework.scheduler")
local RBWarSearchPath = "src/app/game/BRHH"
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")

import("..BRHH.RBWarGlobal")
local RBWarGameController = class("RBWarGameController", function()
    return BaseGameController.new()
end)

RBWarGameController.instance = nil

-- 获取房间控制器实例
function RBWarGameController:getInstance()
    if RBWarGameController.instance == nil then
        RBWarGameController.instance = RBWarGameController.new()
    end
    return RBWarGameController.instance
end

function RBWarGameController:releaseInstance()
    if RBWarGameController.instance then
        RBWarGameController.instance:onDestory()
        RBWarGameController.instance = nil
        g_GameController = nil
    end
end

function RBWarGameController:ctor()
    print("RBWarGameController:ctor()")
    self:myInit()
end

-- 初始化
function RBWarGameController:myInit()
    self.m_history = {}
    print("RBWarGameController:myInit()")
    -- 添加搜索路径
    ToolKit:addSearchPath(RBWarSearchPath .. "/res")
    -- 加载场景协议以及游戏相关协议
    Protocol.loadProtocolTemp("app.game.BRHH.protoReg")

    self:initNetMsgHandlerSwitchData()
    --注册游戏协议
    --  self:initNetMsgHandlerSwitchData()
    --  addMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK, handler(self, self.Handle_EnterSceneAck))
    self:setGamePingTime(5, 2147483647)--心跳包
end

function RBWarGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}
    self.m_netMsgHandlerSwitch["CS_G2C_Red_Init_Nty"]                        =                handler(self, self.gameInitNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_GameFree_Nty"]            =                handler(self, self.gameFreeNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_GameStart_Nty"]                =                handler(self, self.gameStartNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_GameOpenCard_Nty"]            =                handler(self, self.gameOpenCardNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_GameEnd_Nty"]                =                handler(self, self.gameEndNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_History_Nty"]                =                handler(self, self.gameHistoryNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_Bet_Ack"]                =                handler(self, self.gameBetAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_Bet_Nty"]                =                handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_PlayerOnlineList_Ack"]                =                handler(self, self.gamePlayerOnlineListNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_TopPlayerList_Nty"]                =                handler(self, self.gamePlayerShowAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_Background_Ack"]                =                handler(self, self.gameBackgroundAck)
    self.m_netMsgHandlerSwitch["CS_G2C_RedRewardPoolHistory_Ack"]                =                handler(self, self.gameRewardList)
    self.m_netMsgHandlerSwitch["CS_G2C_UserLeft_Ack"]                        =                handler(self, self.userLeftAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_PlayerCnt_Nty"]                        =                handler(self, self.PlayerCntNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Red_ContinueBet_Ack"] = handler(self, self.gameContinueBetAck);

    self.m_protocolList = {}
    for k, v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList + 1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
    self.m_callBackFuncList = {}
    self.m_callBackFuncList["CS_M2C_Red_Exit_Nty"]                =                handler(self, self.gameExit)
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 销毁龙虎斗游戏管理器
function RBWarGameController:onDestory()
    print("----------RBWarGameController:onDestory begin--------------")

    self.m_netMsgHandlerSwitch = {}
    self.m_callBackFuncList = {}
    self.m_history = {}
    self.m_dyzlu = {}
    self.m_xlu = {}
    self.m_xqlu = {}

    if self.gameScene then
        -- if self.gameScene:getMainLayer() then
        --     self.gameScene:getMainLayer():onExit();
        -- end
        self.gameScene:onExit();
        UIAdapter:popScene()
        self.gameScene = nil
    end

    TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")

    self:onBaseDestory()

    print("----------RBWarGameController:onDestory end--------------")

end

function RBWarGameController:netMsgHandler1(__idStr, __info)
    if self.m_callBackFuncList[__idStr] then
        (self.m_callBackFuncList[__idStr])(__info)
    else
        print("没有处理消息", __idStr)
    end
end

function RBWarGameController:sceneNetMsgHandler(__idStr, __info)
    if __idStr == "CS_H2C_HandleMsg_Ack" then
        if __info.m_result == 0 then
            local gameAtomTypeId = __info.m_gameAtomTypeId
            if type(__info.m_message) == "table" then
                if next(__info.m_message) then
                    local cmdId = __info.m_message[1].id
                    local info = __info.m_message[1].msgs
                    self:netMsgHandler1(cmdId, info)
                end
            end
        else
            print("__info.m_result", __info.m_result)
        end
    end
end

function RBWarGameController:gameExit(info)
    --   '1-房间维护结算退出 2-你已经被系统踢出房间,请稍后重试 3-超过限定局数未操作'
    if info.m_type == 0 then
        self:releaseInstance()
        return
    end

    local str = ""
    if info.m_type == 1 then
        str = "分配游戏服失败"
    elseif info.m_type == 2 then
        str = "同步游戏服失败"
    elseif info.m_type == 3 then
        str = "你已经被系统踢出房间,请稍后重试"
    end
    local dlg = DlgAlert.showTipsAlert({ title = "提示", tip = str, tip_size = 34 })
    dlg:setSingleBtn("确定", function()
        dlg:closeDialog()
        self:releaseInstance()
    end)

    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false)
end

function RBWarGameController:netMsgHandler(__idStr, __info)
    print("__idStr = ", __idStr)
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])(__info)
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function RBWarGameController:ackSceneMessage(__info)
    if __info.id == "CS_M2C_Red_Exit_Nty" then
        local dlg = nil
        if __info.msgs.m_type == 3 then
            dlg = DlgAlert.showTipsAlert({ title = "提示", tip = "你已经被系统踢出房间，请稍后重试" })
        elseif __info.msgs.m_type == 4 then
            dlg = DlgAlert.showTipsAlert({ title = "提示", tip = "房间维护，请稍后再游戏" })
        end
        if dlg then
            dlg:setSingleBtn("退出", function()
                dlg:closeDialog()
                self:releaseInstance()
            end)
            dlg:enableTouch(false)
        end
    end
end

function RBWarGameController:ackEnterGame(__info)
    print("RBWarGameController:ackEnterGame")
    --ToolKit:removeLoadingDialog()
    if tolua.isnull(self.gameScene) and __info.m_ret == 0 then
        local scenePath = getGamePath(self.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL)
    end
end

function RBWarGameController:gameInitNty(__info)

    if (self.gameScene ~= nil) then
        self.gameScene:ON_INIT_NTY(__info);
        -- self.gameScene:getMainLayer():setXiaZhuBtnTxt(RB_ChipValue)
        -- self.gameScene:getMainLayer():setXianhongMoney(__info.m_totalBetLimit, __info.m_playerBetLimit)

        -- self.gameScene:getMainLayer():showMyInfo(__info.m_curCoin);
        -- self.gameScene:getMainLayer():setPlayerCount(__info.m_playerCnt);
        -- self.gameScene:getMainLayer():setCaiciNum(__info.m_rewardPool * 0.01)
        -- self.m_rewardPool = __info.m_rewardPool * 0.01
        -- self.gameScene:getMainLayer():showMyBetTxt(__info.m_myAreaBetArr)
        -- self.gameScene:getMainLayer():showAreaBetTxt(__info.m_allAreaBetArr)
        -- print("游戏状态")
        -- if __info.m_state == 2 then --下注阶段
        --     print("下注阶段")
        --     self.gameScene:getMainLayer():setGameState(GS_BET)
        --     dump(__info.m_myBet)
        --     --self.gameScene:getMainLayer():showMyBetTxt(__info.m_myAreaBetArr) 
        --     print("剩余下注时间    " .. __info.m_leftTime)
        --     self.gameScene:getMainLayer():isXiazhu(RB_ChipValue)
        --     --self.gameScene:getMainLayer():showAreaBetTxt(__info.m_allAreaBetArr) 
        --     self.gameScene:getMainLayer():setStageVisible(true)
        --     self.gameScene:getMainLayer():showRunTime(__info.m_leftTime);
        --     self.gameScene:getMainLayer():showGameStageView(1);
        --     self.gameScene:getMainLayer():initDeskChip(__info.m_myAreaBetArr, __info.m_allAreaBetArr);
        -- elseif __info.m_state == 3 then --开牌阶段
        --     print("开牌阶段")
        --     dump(__info.m_myBet)
        --     --self.gameScene:getMainLayer():showMyBetTxt(__info.m_myAreaBetArr) 
        --     print("剩余下注时间    " .. __info.m_leftTime)
        --     self.gameScene:getMainLayer():openCard(__info);
        --     self.gameScene:getMainLayer():setWinOrLoseArea(__info.m_winType, __info.m_luckyStrike)
        --     --self.gameScene:getMainLayer():showAreaBetTxt(__info.m_allAreaBetArr) 
        --     self.gameScene:getMainLayer():setStageVisible(false)
        --     self.gameScene:getMainLayer():setGameState(GS_SEND_CARD)
        --     self.gameScene:getMainLayer():initDeskChip(__info.m_myAreaBetArr, __info.m_allAreaBetArr);
        -- elseif __info.m_state == 4 then --结算阶段
        --     print("结算阶段")
        --     self.gameScene:getMainLayer():setGameState(GS_PLAY_GAME)
        -- else
        --     self.gameScene:getMainLayer():setXiaZhuBtnTxt(RB_ChipValue)
        --     self.gameScene:getMainLayer():setXianhongMoney(__info.m_totalBetLimit, __info.m_playerBetLimit)
        --     local tab = { 0, 0, 0 }
        --     --     self.gameScene:getMainLayer():showAreaBetTxt(tab)    
        --     --self.gameScene:getMainLayer():setPlayerCount(__info.m_playerCnt);
        --     self.gameScene:getMainLayer():setGameState(GS_FREE)
        --     self.gameScene:getMainLayer():showRunTime(__info.m_leftTime);
        --     self.gameScene:getMainLayer():showGameStageView(3);
        -- end
    elseif self.m_roomLayer ~= nil then
        dump(__info, "gamestateplay")
    end
end

function RBWarGameController:getOneCardNum(card, biNiu)
    local byValue = bit.band(card, 15);
    if (byValue >= 10 and biNiu) then
        byValue = 0;
    end
    return byValue;
end

function RBWarGameController:gameFreeNty(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_GAMEFREE_NTY(__info);
        -- self.gameScene:getMainLayer():setGameState(GS_WAIT_NEXT, __info.m_leftTime,true);
        -- self.gameScene:getMainLayer():resetPokers()
        -- self.gameScene:getMainLayer():clearDesk()
        -- self.gameScene:getMainLayer():showRunTime(__info.m_timeLeft);
        -- self.gameScene:getMainLayer():setGameState(GS_FREE)
        -- self.gameScene:getMainLayer():showGameStageView(3);

    end
end

--续压
function RBWarGameController:gameStartNty(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_GAMESTART_NTY(__info);
        -- self.gameScene:getMainLayer():showRunTime(__info.m_timeLeft);
        -- self.gameScene:getMainLayer():startGame()
        -- self.gameScene:getMainLayer():setGameState(GS_BET)
        -- self.gameScene:getMainLayer():showGameStageView(1);
    end
end

function RBWarGameController:gameOpenCardNty(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_GAMEOPENCARD_NTY(__info);
        -- self.gameScene:getMainLayer():openCard(__info);
        -- self.gameScene:getMainLayer():setWinOrLoseArea(__info.m_winType, __info.m_luckyStrike)
        -- self.gameScene:getMainLayer():setGameState(GS_SEND_CARD)
        -- self.gameScene:getMainLayer():stopChipInAni()
    end
end

function RBWarGameController:gameEndNty(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_GAMEEND_NTY(__info);
        -- self.gameScene:getMainLayer():dealGameResult(__info)
        -- self.gameScene:getMainLayer():setGameState(GS_PLAY_GAME)
        -- self.gameScene:getMainLayer():setCaiciNum(__info.m_beforeReward * 0.01)
        -- self.m_rewardPool = __info.m_beforeReward * 0.01
        -- if __info.m_isOpenReward == 1 then
        --     self.gameScene:getMainLayer():gameReward(__info)
        -- end
    end
end

function RBWarGameController:gameBetReq(id, value)
    print("位置    " .. id)
    print("  金额  " .. value)
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Red_Bet_Req", { id, value })
    end
end

function RBWarGameController:gameBetNty(__info)
    self.gameScene:ON_BET_NTY(__info);
    -- self.gameScene:getMainLayer():dealXiaZhu(__info)
    -- self.gameScene:getMainLayer():showAreaBetTxt(__info.m_allAreaBetArr)
end

function RBWarGameController:gameBetAck(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_BET_ACK(__info);
        -- local str = ""
        -- if __info.m_result == 0 then
        --     __info.m_accountId = Player:getAccountID()
            
        --     -- self.gameScene:getMainLayer():dealXiaZhu(__info)
        --     -- self.gameScene:getMainLayer():showAreaBetTxt(__info.m_allAreaBetArr)
        --     -- self.gameScene:getMainLayer():showMyBetTxt(__info.m_myAreaBetArr)
        --     -- self.gameScene:getMainLayer():showMyInfo(__info.m_curCoin);
        --     return
        -- elseif __info.m_result == -200101 then
        --     str = "非下注阶段，不能下注！"
        -- elseif __info.m_result == -200102 then
        --     str = "下注区域无效！"
        -- elseif __info.m_result == -200103 then
        --     str = "金币不足，下注失败！"
        -- elseif __info.m_result == -200104 then
        --     str = "您下注超过个人上限！"
        -- elseif __info.m_result == -200105 then
        --     str = "已达下注总上限！"
        -- elseif __info.m_result == -200106    then
        --     str = "下注失败, 携带金币低于30金币！"
        -- elseif __info.m_result == -200107    then
        --     str = "下注筹码非法"
        -- elseif __info.m_result == -200199 then
        --     str = "未知错误"
        -- end

        -- TOAST(str)
    end
end

function RBWarGameController:gameHistoryNty(__info)
    if (self.gameScene ~= nil) then
        self.m_history = __info.m_history
        self.m_dyzlu = __info.m_bigEyeRoad
        self.m_xlu = __info.m_smallRoad
        self.m_xqlu = __info.m_bugRoad
        -- self.gameScene:getMainLayer():setGameCount(__info.m_history)
        -- self.gameScene:getMainLayer():showLeftRecorf(__info.m_history)
        -- self.gameScene:getMainLayer():dealYuceReslut(self.m_dyzlu, self.m_xlu, self.m_xqlu)
        self.gameScene:ON_HISTORY_NTY(__info);
    elseif (self.m_roomLayer ~= nil) then
        dump(__info, "gameHistoryNty")
    end
end

function RBWarGameController:gamePlayerOnlineListNty(__info)
    if (self.gameScene ~= nil) then
        --  sendMsg(MSG_BJL_RANK_ASK,__info)
        self.gameScene:ON_PLAYERONLINELIST_ACK(__info);
        -- self.gameScene:getMainLayer():setPlayerCount(#__info.m_playerList)
        -- self.gameScene:getMainLayer():updateOnlineUserList(__info)

    end
end

function RBWarGameController:gameRewardListReq()
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_RedRewardPoolHistory_Req", {})
    end
end

function RBWarGameController:gameRewardList(__info)
    self.m_rewardList = __info.m_historyList;
    self.gameScene:ON_REWARDPOOLHISTORY_ACK(__info);
    -- self.gameScene:getMainLayer():showRewardInfo(__info)
end

function RBWarGameController:userLeftAck(__info)
    print("RBWarGameController:userLeftAck")
    self:releaseInstance()
end

function RBWarGameController:gamePlayerOnlineListReq()
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Red_PlayerOnlineList_Req", {})
    end
end

function RBWarGameController:gamePlayerShowAck(__info)
    if (self.gameScene ~= nil) then
        self.gameScene:ON_TOPPLAYERLIST_NTY(__info);
        -- self.gameScene:getMainLayer():updateUserList(__info)
    end
end

function RBWarGameController:gameBackgroundAck(__info)

end

function RBWarGameController:gameBackgroundReq(nType)
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Red_Background_Req", { nType })
    end
end

function RBWarGameController:handleError(__info)
    if __info.m_ret ~= 0 then
        local data = getErrorTipById(__info.m_ret)
        local box_title = "提示"
        local box_content = data.tip or ""
        local cb1 = function() end
        local params = {
            title = box_title,
            message = box_content,
            leftStr = btnText1,
            rightStr = btnText2,
            tip = box_content,
        }
        local dlg = require("app.hall.base.ui.MessageBox").new()
        dlg.showRightAlert(params, cb1)
    end
end

function RBWarGameController:PlayerCntNty(__info)
    if self.gameScene then
        self.gameScene:ON_PLAYERCNT_NTY(__info);
        -- self.gameScene:getMainLayer():setPlayerCount(__info.m_playerCount)
    end
end

--[[function RBWarGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function RBWarGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]

function RBWarGameController:continueReq(sender)
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Red_ContinueBet_Req", {sender});
    end
end

function RBWarGameController:gameContinueBetAck(__info)
    if not tolua.isnull(self.gameScene) then
        self.gameScene:ON_CONTINUE_BET_ACK(__info);
    end
end

return RBWarGameController