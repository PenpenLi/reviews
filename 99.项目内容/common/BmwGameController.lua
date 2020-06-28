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
----------------------------------------------------------------------------------------------------------
-- 项目：红黑大战
-- 时间: 2018-01-11
----------------------------------------------------------------------------------------------------------
local Scheduler        = require("framework.scheduler")
local BmwSearchPath = "src/app/game/bmw"
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")

local BMWData = require("app.game.bmw.src.BMWData")

local BmwGameController = class("BmwGameController", function()
    return BaseGameController.new()
end)

BmwGameController.instance = nil

-- 获取房间控制器实例
function BmwGameController:getInstance()
    if BmwGameController.instance == nil then
        BmwGameController.instance = BmwGameController.new()
    end
    return BmwGameController.instance
end

function BmwGameController:releaseInstance()
    if BmwGameController.instance then
        BmwGameController.instance:onDestory()
        BmwGameController.instance = nil
        g_GameController = nil
    end
end

function BmwGameController:ctor()
    print("BmwGameController:ctor()")
    self:myInit()
end

-- 初始化
function BmwGameController:myInit()
    self.m_history = {}
    self.m_pGameState = {
        m_nState = 0,
    }
    self.m_pAreaTotalBet = { 0, 0, 0, 0, 0, 0, 0, 0 };
    self.m_pMyAreaBet = { 0, 0, 0, 0, 0, 0, 0, 0 };
    print("BmwGameController:myInit()")
    -- 添加搜索路径
    ToolKit:addSearchPath(BmwSearchPath);
    ToolKit:addSearchPath(BmwSearchPath .. "/res")
    -- 加载场景协议以及游戏相关协议
    Protocol.loadProtocolTemp("app.game.bmw.protoReg")

    self:initNetMsgHandlerSwitchData()
    --注册游戏协议
    --  self:initNetMsgHandlerSwitchData()
    --  addMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK, handler(self, self.Handle_EnterSceneAck))
    self:setGamePingTime(5, 2147483647)--心跳包
end

function BmwGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_Init_Nty"]                        =                handler(self, self.gameInitNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_GameReady_Nty"]            =                handler(self, self.gameFreeNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_OpenAward_Nty"]            =                handler(self, self.gameOpenCardNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_Bet_Ack"]                =                handler(self, self.gameBetAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_Bet_Nty"]                =                handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_OnlinePlayerList_Ack"]                =                handler(self, self.gamePlayerOnlineListNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_Background_Ack"]                =                handler(self, self.gameBackgroundAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_Exit_Ack"]                        =                handler(self, self.userLeftAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_TopPlayerList_Nty"]                        =                handler(self, self.gamePlayerShowAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Bmw_ContinueBet_Ack"] = handler(self, self.gameContinueBetAck)

    self.m_protocolList = {}
    for k, v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList + 1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
    self.m_callBackFuncList = {}
    self.m_callBackFuncList["CS_M2C_Bmw_Exit_Nty"]                =                handler(self, self.gameExit)
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 销毁龙虎斗游戏管理器
function BmwGameController:onDestory()
    print("----------BmwGameController:onDestory begin--------------")

    self.m_netMsgHandlerSwitch = {}
    self.m_callBackFuncList = {}


    if self.gameScene then
        UIAdapter:popScene()
        self.gameScene = nil
    end

    BMWData.releaseInstance();
    TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")

    self:onBaseDestory()

    print("----------BmwGameController:onDestory end--------------")

end

function BmwGameController:netMsgHandler1(__idStr, __info)
    if self.m_callBackFuncList[__idStr] then
        (self.m_callBackFuncList[__idStr])(__info)
    else
        print("没有处理消息", __idStr)
    end
end

function BmwGameController:sceneNetMsgHandler(__idStr, __info)
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

function BmwGameController:gameExit(info)
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

function BmwGameController:netMsgHandler(__idStr, __info)
    print("__idStr = ", __idStr)
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])(__info)
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function BmwGameController:ackSceneMessage(__info)
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

function BmwGameController:ackEnterGame(__info)
    print("BmwGameController:ackEnterGame")
    --ToolKit:removeLoadingDialog()
    if tolua.isnull(self.gameScene) and __info.m_ret == 0 then
        local scenePath = "src.app.game.bmw.BmwScene"
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL)
    end
end

function BmwGameController:gameInitNty(__info)
    -- self.m_pGameInitData = __info
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = __info.m_state
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    -- for index = 1, #__info.m_areaTotalBet do
    --     local item = __info.m_areaTotalBet[index];
    --     self.m_pAreaTotalBet[item.m_betAreaId] = item.m_totalBet;
    -- end
    -- for index = 1, #__info.m_myAreaBet do
    --     local item = __info.m_myAreaBet[index];
    --     self.m_pMyAreaBet[item.m_betAreaId] = item.m_myBet;
    -- end
    -- sendMsg(BMWEvent.MSG_BMW_GAME_INIT)
    -- --if(self.gameScene ~= nil) then 
    -- --    self.gameScene:getMainLayer():render_game_start_scene(__info)
    -- --end
    if self.gameScene then
        self.gameScene:ON_Bmw_Init_Nty(__info);
    end

end


function BmwGameController:gameFreeNty(__info)
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = 1
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    -- sendMsg(BMWEvent.MSG_BMW_GAME_GAME_STATE)
    -- --if(self.gameScene ~= nil) then
    -- --    -- self.gameScene:getMainLayer():setGameState(GS_WAIT_NEXT, __info.m_leftTime,true);
    -- --    self.gameScene:getMainLayer():clear_scene()
    -- --    self.gameScene:getMainLayer():update_state_text( 1 )
    -- --    self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    -- --end
    if self.gameScene then
        self.gameScene:ON_Bmw_GameReady_Nty(__info);
    end

end


function BmwGameController:gameOpenCardNty(__info)
    --     self.m_pGameState = {}
    --     self.m_pGameState.m_nState = 3
    --     self.m_pGameState.m_nLeftTime = __info.m_leftTime
    --     self.m_openAward = __info
    --     sendMsg(BMWEvent.MSG_BMW_GAME_GAME_STATE)
    --    --[[ if(self.gameScene ~= nil) then 
    --          self.gameScene:getMainLayer():update_state_text( 3 )
    --         self.gameScene:getMainLayer():openAward(__info); 
    --         self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    --         self.m_openAward = __info
    --     end
    --     ]]
    self.m_openAward = __info;
    if self.gameScene then
        self.gameScene:ON_Bmw_OpenAward_Nty(__info);
    end

end
function BmwGameController:getOpenAward()
    return self.m_openAward
end

function BmwGameController:gameBetReq(id, value)
    print("位置    " .. id)
    print("  金额  " .. value)
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Bmw_Bet_Req", { id, value })
    end
end
function BmwGameController:exitReq()
    ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Bmw_Exit_Req", {})
end

function BmwGameController:gameBetNty(__info)
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = 2
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    -- sendMsg(BMWEvent.MSG_BMW_GAME_GAME_STATE)
    -- --self.gameScene:getMainLayer():update_state_text( 2 )
    -- --self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    -- --self.gameScene:getMainLayer():play_state_animation( "game_star" , nil )
    if self.gameScene then
        self.gameScene:ON_Bmw_Bet_Nty(__info);
    end

end

function BmwGameController:gameBetAck(__info)
    -- if (self.gameScene ~= nil) then
    --     local str = ""
    --     if __info.m_result == 0 then
    --         if self.gameScene:getMainLayer() ~= nil then
    --             self.gameScene:getMainLayer():game_user_add_bet(__info)
    --         end
    --         if __info.m_betAccountId == Player:getAccountID() then
    --             self.m_pMyAreaBet[__info.m_betAreaId] = __info.m_betValue + self.m_pMyAreaBet[__info.m_betAreaId];
    --         else
    --             self.m_pAreaTotalBet[__info.m_betAreaId] = __info.m_betValue + self.m_pAreaTotalBet[__info.m_betAreaId];
    --         end
    --         return
    --     elseif __info.m_result == -204201    then
    --         str = "非下注阶段，不能下注！"
    --     elseif __info.m_result == -204202    then
    --         str = "下注区域无效！"
    --     elseif __info.m_result == -204203    then
    --         str = "金币不足，下注失败！"
    --     elseif __info.m_result == -204204    then
    --         str = "您下注超过个人上限！"
    --     elseif __info.m_result == -204205    then
    --         str = "已达下注总上限！"
    --     elseif __info.m_result == -204206    then
    --         str = "下注失败, 携带金币低于30金币！"
    --     elseif __info.m_result == -204207    then
    --         str = "下注筹码非法"
    --     elseif __info.m_result == -204208 then
    --         str = "开奖出错,请联系客服"
    --     elseif __info.m_result == -204209 then
    --         str = "配置出错"
    --     elseif __info.m_result == -204210 then
    --         str = "玩家不存在"
    --     end

    --     TOAST(str)
    -- end

    if self.gameScene then
        self.gameScene:ON_Bmw_Bet_Ack(__info);
    end

end

function BmwGameController:gameHistoryNty(__info)
    if (self.gameScene ~= nil) then
        self.m_history = __info.m_history
        self.m_dyzlu = __info.m_bigEyeRoad
        self.m_xlu = __info.m_smallRoad
        self.m_xqlu = __info.m_bugRoad
        self.gameScene:getMainLayer():setGameCount(__info.m_history)
        self.gameScene:getMainLayer():showLeftRecorf(__info.m_history)
        self.gameScene:getMainLayer():dealYuceReslut(self.m_dyzlu, self.m_xlu, self.m_xqlu)
    elseif (self.m_roomLayer ~= nil) then
        dump(__info, "gameHistoryNty")
    end
end

function BmwGameController:gamePlayerOnlineListNty(__info)
    -- self.m_pPlayerOnlineList = __info
    -- sendMsg(BMWEvent.MSG_BMW_PLAYR_ONLINE_LIST)
    -- --if(self.gameScene ~= nil and self.gameScene:getMainLayer() ~= nil) then
    -- --  --  sendMsg(MSG_BJL_RANK_ASK,__info) 
    -- --    self.gameScene:getMainLayer():updateOnlineUserList(__info)
    -- --
    -- --end

    if self.gameScene then
        self.gameScene:ON_Bmw_OnlinePlayerList_Ack(__info);
    end
end

function BmwGameController:gameRewardListReq()
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_RedRewardPoolHistory_Req", {})
    end
end

function BmwGameController:gameRewardList(__info)
    self.m_rewardList = __info.m_historyList
    self.gameScene:getMainLayer():showRewardInfo(__info)
end

function BmwGameController:userLeftAck(__info)
    print("BmwGameController:userLeftAck")
    self:releaseInstance()
    UIAdapter:popScene()
end

function BmwGameController:gamePlayerOnlineListReq()
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Bmw_OnlinePlayerList_Req", {})
    end
end

function BmwGameController:gamePlayerShowAck(__info)
    -- self.m_pTopPlayerList = __info
    -- sendMsg(BMWEvent.MSG_BMW_GAME_TOP_PLAYER_LIST)

    -- --if(self.gameScene ~= nil) then
    -- --    self.gameScene:getMainLayer():update_users_info(__info) 
    -- --end
    if self.gameScene then
        self.gameScene:ON_Bmw_TopPlayerList_Nty(__info);
    end
end

function BmwGameController:gameBackgroundAck(__info)

end

function BmwGameController:gameBackgroundReq(nType)
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Bmw_Background_Req", { nType })
    end
end

function BmwGameController:handleError(__info)
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


--[[function BmwGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function BmwGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]
function BmwGameController:gameContinueBetAck(__info)
    -- self.gameScene:getMainLayer():onContinueBetAck(__info)

    if self.gameScene then
        self.gameScene:ON_Bmw_ContinueBet_Ack(__info);
    end
end

return BmwGameController