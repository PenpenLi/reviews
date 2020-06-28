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
 
local Scheduler           = require("framework.scheduler") 
local BirdSearchPath = "src/app/game/bird"
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")

local BirdEvent = require("app.game.bird.src.BirdEvent")
local BirdData = require("src.app.game.bird.src.BirdData");
 
local BirdGameController =  class("BirdGameController",function()
    return BaseGameController.new()
end) 

BirdGameController.instance = nil

-- 获取房间控制器实例
function BirdGameController:getInstance()
    if BirdGameController.instance == nil then
        BirdGameController.instance = BirdGameController.new()
    end
    return BirdGameController.instance
end

function BirdGameController:releaseInstance()
    if BirdGameController.instance then
		BirdGameController.instance:onDestory()
        BirdGameController.instance = nil
		g_GameController = nil
    end
end

function BirdGameController:ctor()
    print("BirdGameController:ctor()")
    self:myInit()
end

-- 初始化
function BirdGameController:myInit()
    self.m_history = {}
    self.m_pGameState = {}
    self.m_pGameState.m_nState = 0

    self.m_pOtenrBetCoin = {};
    self.m_pMyBetCoin = {};

    print("BirdGameController:myInit()") 
    -- 添加搜索路径
    ToolKit:addSearchPath(BirdSearchPath.."/res") 
    -- 加载场景协议以及游戏相关协议
     
    Protocol.loadProtocolTemp("app.game.bird.protoReg")
     
      self:initNetMsgHandlerSwitchData()
    --注册游戏协议
  --  self:initNetMsgHandlerSwitchData()

  --  addMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK, handler(self, self.Handle_EnterSceneAck))

    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包
end

function BirdGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}  
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_Init_Nty"]                          =                   handler(self, self.gameInitNty)  
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_GameReady_Nty"]             =                   handler(self, self.gameFreeNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_OpenAward_Nty"]            =                   handler(self, self.gameOpenCardNty)  
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_Bet_Ack"]                   =                   handler(self, self.gameBetAck)
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_Bet_Nty"]                   =                   handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_OnlinePlayerList_Ack"]                =                   handler(self, self.gamePlayerOnlineListNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_Background_Ack"]                   =                   handler(self, self.gameBackgroundAck)   
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_Exit_Ack"]                   		=                   handler(self, self.userLeftAck)  
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_TopPlayerList_Nty"]                   		=                   handler(self, self.gamePlayerShowAck)  
    self.m_netMsgHandlerSwitch["CS_G2C_Bird_ContinueBet_Ack"] = handler(self, self.gameContinueBetAck)

    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
    self.m_callBackFuncList = {} 
    self.m_callBackFuncList["CS_M2C_Bird_Exit_Nty"]                   =                   handler(self, self.gameExit)  
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 销毁龙虎斗游戏管理器
function BirdGameController:onDestory()
	print("----------BirdGameController:onDestory begin--------------")

	self.m_netMsgHandlerSwitch = {}
	self.m_callBackFuncList = {}
	 
	BirdData.releaseInstance();
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	
	self:onBaseDestory()
	
	print("----------BirdGameController:onDestory end--------------")

end

function BirdGameController:netMsgHandler1(__idStr, __info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(__info)
  else
      print("没有处理消息",__idStr)
  end
end
 
function BirdGameController:sceneNetMsgHandler( __idStr, __info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if __info.m_result == 0 then
            local gameAtomTypeId = __info.m_gameAtomTypeId 
            if type( __info.m_message ) == "table" then
                if next( __info.m_message )  then
                    local cmdId = __info.m_message[1].id
                    local info = __info.m_message[1].msgs
                    self:netMsgHandler1(cmdId, info)
                end
            end 
      else
          print("__info.m_result", __info.m_result )
      end
    end
end

function BirdGameController:gameExit(info)
 --   '1-房间维护结算退出 2-你已经被系统踢出房间,请稍后重试 3-超过限定局数未操作'
    if info.m_type == 0 then
        self:releaseInstance()
        return
    end
	
    local str = ""
     if info.m_type ==1 then
        str = "分配游戏服失败"
    elseif info.m_type ==2 then
         str = "同步游戏服失败"
    elseif info.m_type ==3 then
         str = "你已经被系统踢出房间,请稍后重试"
    end
    local dlg = DlgAlert.showTipsAlert({title = "提示", tip = str, tip_size = 34})
    dlg:setSingleBtn("确定", function ()
		dlg:closeDialog()
		self:releaseInstance()
    end)
	
    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false) 
end
 
function BirdGameController:netMsgHandler( __idStr,__info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])( __info )
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function BirdGameController:ackSceneMessage(__info)
    if __info.id == "CS_M2C_Red_Exit_Nty" then
        local dlg= nil
        if __info.msgs.m_type == 3 then
             dlg = DlgAlert.showTipsAlert({title = "提示", tip = "你已经被系统踢出房间，请稍后重试"})
        elseif __info.msgs.m_type == 4 then
             dlg = DlgAlert.showTipsAlert({title = "提示", tip = "房间维护，请稍后再游戏"})
        end
        if dlg then
            dlg:setSingleBtn("退出", function ()
			    dlg:closeDialog()
                self:releaseInstance()
            end)
            dlg:enableTouch(false)
        end
    end
end
 
function BirdGameController:ackEnterGame(__info)
	print("BirdGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = "src.app.game.bird.BirdScene"
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL )  
    end
end 

function BirdGameController:gameInitNty(__info)
    self.gameScene:ON_INIT_NTY(__info);
    -- self.m_pGameInitData = __info
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = __info.m_state
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime

    -- -- 'm_areaTotalBet'	'm_betAreaId' 'm_totalBet'	
    -- -- 'm_myAreaBet'	'm_betAreaId' 'm_myBet'	
    -- self.m_pOtenrBetCoin = {};
    -- self.m_pMyBetCoin = {};

    -- for index = 1, #__info.m_areaTotalBet do
    --     local item = __info.m_areaTotalBet[index];
    --     self.m_pOtenrBetCoin[item.m_betAreaId] = item.m_totalBet;
    -- end

    -- for index = 1, #__info.m_myAreaBet do
    --     local item = __info.m_areaTotalBet[index];
    --     self.m_pMyBetCoin[item.m_betAreaId] = item.m_myBet;
    -- end

    -- sendMsg(BirdEvent.MSG_BIRD_GAME_INIT)
    --if(self.gameScene ~= nil) then 
    --    self.gameScene:getMainLayer():render_game_start_scene(__info)
    --end
end 
   

function BirdGameController:gameFreeNty(__info) 
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = 1
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    -- sendMsg(BirdEvent.MSG_BIRD_GAME_GAME_STATE)
    self.gameScene:ON_GAME_READY_NTY(__info);

    --if(self.gameScene ~= nil) then
    --    -- self.gameScene:getMainLayer():setGameState(GS_WAIT_NEXT, __info.m_leftTime,true);
    --    self.gameScene:getMainLayer():clear_scene()
    --    self.gameScene:getMainLayer():update_state_text( 1 )
    --    self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    --end
end
 

function BirdGameController:gameOpenCardNty(__info)
    self.m_openAward = __info;
    self.gameScene:ON_OPEN_AWARD_NTY(__info);
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = 3
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    
    -- self.m_pOtenrBetCoin = {};
    -- self.m_pMyBetCoin = {};
    -- sendMsg(BirdEvent.MSG_BIRD_GAME_GAME_STATE)
    --if(self.gameScene ~= nil) then 
    --     self.gameScene:getMainLayer():update_state_text( 3 )
    --     
    --    self.gameScene:getMainLayer():openAward(__info); 
    --    self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    --    
    --end
end
 function BirdGameController:getOpenAward()
    return  self.m_openAward
 end

function BirdGameController:gameBetReq(id,value)
   print("位置    "..id)
   print("  金额  "..value)
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Bird_Bet_Req", { id,value })
	end
end
function BirdGameController:exitReq()
    ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Bird_Exit_Req", { })
end

function BirdGameController:gameBetNty(__info)
    -- self.m_pGameState = {}
    -- self.m_pGameState.m_nState = 2
    -- self.m_pGameState.m_nLeftTime = __info.m_leftTime
    -- sendMsg(BirdEvent.MSG_BIRD_GAME_GAME_STATE)
    self.gameScene:ON_BET_NTY(__info);

    --self.gameScene:getMainLayer():update_state_text( 2 )
    --self.gameScene:getMainLayer():showLeftTime(__info.m_leftTime)
    --self.gameScene:getMainLayer():play_state_animation( "game_star" , nil )
   
end

function BirdGameController:gameBetAck(__info)
    if(self.gameScene ~= nil) then
        self.gameScene:ON_BET_ACK(__info);
        -- local str = ""
        -- if __info.m_result== 0 then
        --     if __info.m_betAccountId == Player:getAccountID() then
        --         local coin = self.m_pMyBetCoin[__info.m_betAreaId] or 0;
        --         self.m_pMyBetCoin[__info.m_betAreaId] = coin + __info.m_betValue;
        --     else
        --         local coin = self.m_pOtenrBetCoin[__info.m_betAreaId] or 0; 
        --         self.m_pOtenrBetCoin[__info.m_betAreaId] = coin + __info.m_betValue;
        --     end
            
        --     if self.gameScene:getMainLayer() ~= nil then
        --         self.gameScene:getMainLayer():game_user_add_bet(__info); 
        --     end

        --     return
        -- elseif __info.m_result== -201201 then
        --     str ="非下注阶段，不能下注！"
        -- elseif __info.m_result== -201202	 then
        --      str ="下注区域无效！"
        -- elseif __info.m_result== -201203	 then
        --     str ="金币不足，下注失败！"
        -- elseif __info.m_result== -201204	 then
        --     str ="您下注超过个人上限！"
        --  elseif __info.m_result== -201205	 then
        --     str ="已达下注总上限！"
        --  elseif __info.m_result== -201206		 then
        --     str ="下注失败, 携带金币低于30金币！"
        --   elseif __info.m_result== -201207			 then
        --     str ="下注筹码非法"
        --  elseif __info.m_result== -201208 then
        --     str ="开奖出错,请联系客服"
        -- elseif __info.m_result== -201209	 then
        --     str ="配置出错"
        -- elseif __info.m_result== -201210	 then
        --     str ="玩家不存在"
        -- elseif __info.m_result== -201299	then
        --     str ="未知错误"
        -- end

        -- TOAST(str) 
    end
end

function BirdGameController:gameHistoryNty(__info)
    if(self.gameScene ~= nil) then
        self.m_history= __info.m_history
        self.m_dyzlu =__info.m_bigEyeRoad
        self.m_xlu =__info.m_smallRoad
        self.m_xqlu =__info.m_bugRoad
        self.gameScene:getMainLayer():setGameCount(__info.m_history)
        self.gameScene:getMainLayer():showLeftRecorf(__info.m_history)
        self.gameScene:getMainLayer():dealYuceReslut(self.m_dyzlu,self.m_xlu,self.m_xqlu)
    elseif(self.m_roomLayer ~= nil) then
        dump(__info,"gameHistoryNty")
    end
end

function BirdGameController:gamePlayerOnlineListNty(__info)
    if(self.gameScene ~= nil) then 
        self.gameScene:ON_ONLINE_PLAYER_LIST_ACK(__info);
        -- self.gameScene:getMainLayer():updateOnlineUserList(__info)
    
    end
end

function BirdGameController:gameRewardListReq()
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_RedRewardPoolHistory_Req", {})
	end
end

function BirdGameController:gameRewardList(__info)
   self.m_rewardList = __info.m_historyList
   self.gameScene:getMainLayer():showRewardInfo(__info)
end

function BirdGameController:userLeftAck(__info)
	print("BirdGameController:userLeftAck")
	self:releaseInstance()
    UIAdapter:popScene()
end

function BirdGameController:gamePlayerOnlineListReq()
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Bird_OnlinePlayerList_Req", {})
	end
end

function BirdGameController:gamePlayerShowAck(__info)
    self.m_pTopPlayerList = __info
    self.gameScene:ON_TOP_PLAYER_LIST_NTY(__info);
    -- sendMsg(BirdEvent.MSG_BIRD_GAME_TOP_PLAYER_LIST)
    --if(self.gameScene ~= nil) then
    --    self.gameScene:getMainLayer():update_users_info(__info) 
    --end
end

function BirdGameController:gameBackgroundAck(__info)
    
end

function BirdGameController:gameBackgroundReq(nType)
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Bird_Background_Req", { nType})
	end
end
    
function BirdGameController:handleError(__info)
    if __info.m_ret~=0 then 
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
        dlg.showRightAlert(params,cb1) 
    end     
end 
--[[
function BirdGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function BirdGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]
function BirdGameController:gameContinueBetAck(__info)
    self.gameScene:ON_CONTINUE_BET_ACK(__info);
    -- if self.gameScene ~= nil and self.gameScene:getMainLayer() ~= nil then
    --     self.gameScene:getMainLayer():onContinueBetAck(__info)
    -- end
end
return BirdGameController