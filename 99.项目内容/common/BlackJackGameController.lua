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
local blackjack_util = require("app.game.blackjack.blackjack_util")
local BlackJackSearchPath = "src/app/game/blackjack"
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")
 
local BlackJackGameController =  class("BlackJackGameController",function()
    return BaseGameController.new()
end) 

BlackJackGameController.instance = nil

-- 获取房间控制器实例
function BlackJackGameController:getInstance()
    if BlackJackGameController.instance == nil then
        BlackJackGameController.instance = BlackJackGameController.new()
    end
    return BlackJackGameController.instance
end

function BlackJackGameController:releaseInstance()
    if BlackJackGameController.instance then
		BlackJackGameController.instance:onDestory()
        BlackJackGameController.instance = nil
		g_GameController = nil
    end
end

function BlackJackGameController:ctor()
    print("BlackJackGameController:ctor()")
    self:myInit()
end

-- 初始化
function BlackJackGameController:myInit()
  	self.bet_order = 100
	self.room_type = nil
	self.room_state = nil
	self.result_data = nil
	self.jetton_node = {} 		--model居然存了界面的节点,重连需要手动清除
	self.player_data = {}
	self.look_card = {}
	self.bet_list = {}
	self.player_fold = {}
	self.player_cards = {}
	self.safe_list = {}
    self.m_bgFlag = false
    print("BlackJackGameController:myInit()") 
    -- 添加搜索路径
    ToolKit:addSearchPath(BlackJackSearchPath.."/res") 
    -- 加载场景协议以及游戏相关协议
     
    Protocol.loadProtocolTemp("app.game.blackjack.protoReg")
     
      self:initNetMsgHandlerSwitchData() 
    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包
end

function BlackJackGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}  
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_GameState_Nty"]                          =                   handler(self, self.gameInitNty)  
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Begin_Nty"]             =                   handler(self, self.gameBeginNty)
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_SendCard_Nty"]                  =                   handler(self, self.gameSendCardNty)
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Action_Nty"]            =                   handler(self, self.gameActionNty)
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_GameEnd_Nty"]                 =                   handler(self, self.gameEndNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Bet_Nty"]                   =                   handler(self, self.gameBetNty) 
     self.m_netMsgHandlerSwitch["CS_G2C_21Dot_FinishBet_Nty"]                   =           handler(self, self.gameFinishBetNty)
     self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Cut2Two_Nty"]                         =           handler(self, self.gameFenPaiNty)
      self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Insure_Nty"]                         =           handler(self, self.gameInsureNty)
      self.m_netMsgHandlerSwitch["CS_G2C_21Dot_StopSendCard_Nty"]                         =           handler(self, self.gameStopSendCardNty)
      self.m_netMsgHandlerSwitch["CS_G2C_21Dot_DoubleBet_Nty"]                         =           handler(self, self.gameDoubleBetNty)
      self.m_netMsgHandlerSwitch["CS_G2C_21Dot_MoreCard_Nty"]                         =           handler(self, self.gameMoreCardNty) 
     self.m_netMsgHandlerSwitch["CS_G2C_21Dot_BankOp_Nty"]                         =           handler(self, self.gameBankOpNty) 
     self.m_netMsgHandlerSwitch["CS_G2C_21Dot_BuyInsure_Nty"]                         =           handler(self, self.gameBuyInsureNty)  
     self.m_netMsgHandlerSwitch["CS_G2C_21Dot_Background_Ack"]                         =           handler(self, self.gameBackgroundAck)  
      
     
    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler)) 

    
    self.m_callBackFuncList = {}
     
	self.m_callBackFuncList["CS_M2C_21Dot_StartMate_Nty"]                     = handler(self,self.ackEenterScene)
    self.m_callBackFuncList["CS_M2C_21Dot_StartMate_Ack"]                     = handler(self,self.ackEenterScene1)
	self.m_callBackFuncList["CS_M2C_21Dot_Exit_Nty"]                        = handler(self,self.ackExitScene)  
    self.m_callBackFuncList["CS_M2C_21Dot_Exit_Ack"]                        = handler(self,self.Exit)  
    
   	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end 
 
function BlackJackGameController:gameReadyReq()
    ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_21Dot_StartMate_Req", {})
end
function BlackJackGameController:gameBankOpNty(info)
    self.gameScene:getMainLayer():SendZJCard(info)
end
function BlackJackGameController:gameEndNty(info)
   -- self:setResultData(info)
   self.room_state.game_step = 6
    self.gameScene:getMainLayer():eventRoomState()
    self.gameScene:getMainLayer():eventRoomResult(info)
end

function BlackJackGameController:gameBuyInsureNty(info)
    self.room_state.m_leftTime = info.m_opTime
     self.room_state.game_step = 4
     self.gameScene:getMainLayer():eventRoomState()
end
function BlackJackGameController:gameActionNty(info)
     self.room_state.loop_pos = info.m_chairId
     self.room_state.m_leftTime = info.m_opTime
     self.room_state.game_step = 5
     self.room_state.m_canCut2two =info.m_canCut2two
    self.gameScene:getMainLayer():eventRoomState()
end
function BlackJackGameController:gameBeginNty(info)
    local room_state = self:getRoomState()
    room_state.m_leftTime = info.m_opTime
    self.m_nRecord = info.m_recordId
    self.gameScene:getMainLayer().mTextRecord:setString("牌局ID:"..info.m_recordId)
    self.gameScene:getMainLayer():hideTips()
    self.gameScene:getMainLayer():stateBet() 
end
function BlackJackGameController:gameSendCardNty(info) 
dump(info)
    self.gameScene:getMainLayer():allSendCard(info) 
end

function BlackJackGameController:Exit(info)
    if info.m_result == 0 then
        UIAdapter:popScene()
        self:releaseInstance()
    else
        self:HandleError(info.m_result)
    end
end
function BlackJackGameController:ackExitScene(info)
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
-- 销毁龙虎斗游戏管理器
function BlackJackGameController:onDestory()
	print("----------BlackJackGameController:onDestory begin--------------")
    TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	self.m_netMsgHandlerSwitch = {}
	self.m_callBackFuncList = {} 
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
	 
	
	self:onBaseDestory()
	
	print("----------BlackJackGameController:onDestory end--------------")

end
function BlackJackGameController:ackEenterScene(info) 
    if info.m_type ==0 then
        if self.gameScene:getMainLayer().btn_ready:isVisible() then
            self.gameScene:getMainLayer().btn_ready:setVisible(false)
        end
        self.gameScene:getMainLayer():showTips("正在匹配中，请稍候....",false)
    end
end
function BlackJackGameController:ackEenterScene1(info) 
     if info.m_result == 0 then
        self.gameScene:getMainLayer():showTips("正在匹配中，请稍候....",false)
        self.bet_order = 100
	    self.room_type = nil
	    self.room_state = nil
	    self.result_data = nil
	    self.jetton_node = {} 		--model居然存了界面的节点,重连需要手动清除
	    self.player_data = {}
	    self.look_card = {}
	    self.bet_list = {}
	    self.player_fold = {}
	    self.player_cards = {}
	    self.safe_list = {}
    else
        self:reqQuitGame()
        self:HandleError(info.m_result)
    end
 
end
function BlackJackGameController:netMsgHandler1(__idStr, info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(info)
  else
      print("没有处理消息",__idStr)
  end
end
 
function BlackJackGameController:sceneNetMsgHandler( __idStr, info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if info.m_result == 0 then
            local gameAtomTypeId = info.m_gameAtomTypeId 
            if type( info.m_message ) == "table" then
                if next( info.m_message )  then
                    local cmdId = info.m_message[1].id
                    local info = info.m_message[1].msgs
                    self:netMsgHandler1(cmdId, info)
                end
            end 
      else
          print("info.m_result", info.m_result )
      end
    end
end
function BlackJackGameController:HandleError(ret) 
    if ret == -80100 then
        TOAST("当前不可下注")
    elseif ret == -80101 then
        TOAST("玩家数据异常")
    elseif ret == -80102 then
        TOAST("参数异常")
    elseif ret == -80103 then
        TOAST("此位置不可下注")
    elseif ret == -80104 then
        TOAST("已经下注")
    elseif ret == -80105 then
        TOAST("金币不足")
    elseif ret == -80106 then
        TOAST("您的位置未下注")
    elseif ret == -80107 then
        TOAST("当前不可购买保险")
    elseif ret == -80108 then
        TOAST("他人位置不可操作")
    elseif ret == -80109 then
        TOAST("庄家牌无效")
    elseif ret == -80110 then
        TOAST("下注未结束")
    elseif ret == -80111 then
        TOAST("此区域不可操作")
    elseif ret == -80112 then
        TOAST("不能分牌")
    elseif ret == -80113 then
        TOAST("已经购买了保险")
    elseif ret == -80114 then
        TOAST("您已操作完")
    elseif ret == -80115 then
        TOAST("非要牌状态")
    elseif ret == -80121 then
        TOAST("游戏未结束")
    elseif ret == -80120 then
        TOAST("玩家不存在")
    elseif ret == -747 then
        TOAST("游戏维护中")
    elseif ret == -705 then
        TOAST("金币不足")
     elseif ret == -80116 then  
        TOAST("黑杰克不能购买保险")
    end

end
function BlackJackGameController:gameFinishBetNty(info)
     --Dispatcher:dispatchEvent({ name = GameEvent.BLACKJACK_PLAYER_LOOP, data = info }) 
     info.loop_step = 5
     if info.m_ret ==0 then
        self.gameScene:getMainLayer():eventPlayerLoop(info)
    else
        self:HandleError(info.m_ret)
    end
end

function BlackJackGameController:gameFenPaiNty(info)
     info.loop_step = 3
     if info.m_ret ==0 then
        self.gameScene:getMainLayer():setALLbtnEnable(false)
        self.gameScene:getMainLayer():eventPlayerLoop(info) 
    else
        self:HandleError(info.m_ret)
    end
end

function BlackJackGameController:gameInsureNty(info)
    self:setSafeData(info)
    dump(info)
    if info.m_ret ==0 then
        self.gameScene:getMainLayer():eventSafeResult(info)
    else
        self:HandleError(info.m_ret)
          info.pos = info.m_chairId
            info.pid = info.m_accountId
          if info.m_accountId ==Player:getAccountID() then
                self.gameScene:getMainLayer():checkBuySafe(info)
            end
    end
end

function BlackJackGameController:gameDoubleBetNty(info) 
    info.loop_step = 2
    if info.m_ret ==0 then
        self.gameScene:getMainLayer():setALLbtnEnable(false)
        self.gameScene:getMainLayer():eventPlayerLoop(info)
    else
        self:HandleError(info.m_ret)
    end
end

function BlackJackGameController:gameStopSendCardNty(info) 
    info.loop_step = 4
    if info.m_ret ==0 then
        self.gameScene:getMainLayer():eventPlayerLoop(info)
    else
        self:HandleError(info.m_ret)
    end
end

function BlackJackGameController:gameMoreCardNty(info) 
     if info.m_ret ==0 then
        self.gameScene:getMainLayer():oneSendCard(info)
    else
        self:HandleError(info.m_ret)
    end
end
function BlackJackGameController:ExitAck( info)
    if info.m_keepCoin ~= 0 and info.m_result == 0 then
        local message = "强退将暂时扣除" .. info.m_keepCoin*0.01 .."金币，用于本局结算，结算后自动返还剩余金币，是否退出？"
        local params = { 
        message = message -- todo: 换行 
        }
        local dlg = require("app.hall.base.ui.MessageBox").new()
        local _leftCallback = function ()       
            
             self:reqQuitGame()
        end

        local _rightcallback = function () 
                                  
        end
     
        dlg:TowSubmitAlert(params, _leftCallback, _rightcallback)
        dlg:showDialog()
        return
    end
      UIAdapter:popScene()
end
function BlackJackGameController:gameExit(info)
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
 
function BlackJackGameController:netMsgHandler( __idStr,info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])( info )
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function BlackJackGameController:ackSceneMessage(info)
    if info.id == "CS_M2C_Red_Exit_Nty" then
        local dlg= nil
        if info.msgs.m_type == 3 then
             dlg = DlgAlert.showTipsAlert({title = "提示", tip = "你已经被系统踢出房间，请稍后重试"})
        elseif info.msgs.m_type == 4 then
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
 
function BlackJackGameController:ackEnterGame(info)
	print("BlackJackGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()
    if tolua.isnull( self.gameScene ) and info.m_ret == 0 then 
        local scenePath = getGamePath(self.m_gameAtomTypeId) 
        self.gameScene = UIAdapter:pushScene("src.app.game.blackjack.BlackJackScene", DIRECTION.HORIZONTAL )  
    end
end 

function BlackJackGameController:getOpenCardResult() 
    return self.m_openCardResult
end 
function BlackJackGameController:gameInitNty(info)
    
    if self.m_bgFlag == true then
         if info.m_state == 2 then
             
            self.m_bgFlag =false
            return
        end
    end
   self.gameScene:getMainLayer():cleanAll()
    self.gameScene:getMainLayer():stopAllSch()
    self.bet_order = 100
	self.room_type = nil
	self.room_state = nil
	self.result_data = nil
	self.jetton_node = {} 		--model居然存了界面的节点,重连需要手动清除
	self.player_data = {}
	self.look_card = {}
	self.bet_list = {}
	self.player_fold = {}
	self.player_cards = {}
	self.safe_list = {}
    self:setPlayerEnterData(info)
    self:setRoomState(info)
   if info.m_state>1 then
        self.is_recover = true
    else
        self.is_recover = false
    end   
    self.m_nRecord = info.m_recordId
    if self.m_nRecord ~= "" then
        self.gameScene:getMainLayer().mTextRecord:setString("牌局ID:"..info.m_recordId)
    end
   self.gameScene:getMainLayer():recoverGame()
    self.gameScene:getMainLayer():eventRoomState()
end 
    

function BlackJackGameController:reqQuitGame()
    if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_21Dot_Exit_Req", {})
	end
end

function BlackJackGameController:reqCheckQuitGame()
    if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_RobCheckExit_Req", {})
	end
end 
  
function BlackJackGameController:gameBetReq(chairId,betMultiple) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_Bet_Req", {chairId,betMultiple *100})
	end
end
function BlackJackGameController:gameContinueBetReq(chairId) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_ContinueLastBet_Req", {chairId })
	end
end
function BlackJackGameController:FinishBetReq() 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_FinishBet_Req", { })
	end
end
function BlackJackGameController:FenPaiReq(chairId) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_Cut2Two_Req", {chairId })
	end
end
function BlackJackGameController:InsureReq(chairId,nType) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_Insure_Req", {chairId ,nType})
	end
end
function BlackJackGameController:StopSendCardReq(chairId)
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_StopSendCard_Req", {chairId })
 
end
function BlackJackGameController:DoubleBetReq(chairId) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_DoubleBet_Req", {chairId })
	end
end
function BlackJackGameController:MoreCardReq(chairId) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_MoreCard_Req", {chairId })
	end
end

 
function BlackJackGameController:gameBetNty(info)
   if(self.gameScene ~= nil) then
        if info.m_ret == 0 then 
            
            self.gameScene:getMainLayer():eventRoomBet(info)
            if info.m_isFinish ==1 and info.m_accountId == Player:getAccountID() then
                info.loop_step = 5
                self.gameScene:getMainLayer():eventPlayerLoop(info) 
            end
        else
            self:HandleError(info.m_ret)
        end
   end
end 

function BlackJackGameController:userLeftAck(info)
	print("BlackJackGameController:userLeftAck")
	self:releaseInstance()
end
 
  

function BlackJackGameController:gameBackgroundAck(info)
    self.m_bgFlag = true
   
end

function BlackJackGameController:gameBackgroundReq(nType)
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_21Dot_Background_Req", { nType})
	end
end
function BlackJackGameController:handleError(info)
    if info.m_ret~=0 then 
         local data = getErrorTipById(info.m_ret)
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
 
 function BlackJackGameController:clearJetton()
	print("清除筹码")
	self.jetton_node = {}
end

--玩家进入房间数据
function BlackJackGameController:setPlayerEnterData(data)
	for _ , player in pairs(data.m_allPlayers) do
		self:setPlayerData(player.m_accountId, player)
        player.yazhu = player.m_bets
         for k , v in pairs(player.yazhu) do
            v.pid = player.m_accountId
			v.pos = v.m_chairId                        
			v.times = v.m_betValue*0.01                      
			v.safe = v.m_hasBuyInsure         
			v.cards = v.m_cards
			local info = {
				cards = {
					{	pid = player.m_accountId,
					    pos = v.m_chairId,                        
					    times = v.m_betValue*0.01,                      
					    safe = v.m_hasBuyInsure,         
					    cards = v.m_cards   
					}             
				}
			}
			if v.safe == true then
				self:setSafeData({pos=v.pos,pid=v.pid})
			end
			self:setCardData(info)
		end
        
		--sendMsg(  BLACKJACK_ADD_PLAYER, {pid = player.m_accountId}) 	--新加入的玩家
	end   
	local info = {
		cards = {
			{	
				pos = data.m_bankerInfo.m_chairId ,                  
				cards = data.m_bankerInfo.m_cards
			}             
		}
	} 
	self:setCardData(info)
    for _ , player in pairs(data.m_allPlayers) do
        self.gameScene:getMainLayer():eventAddPlayer(player.m_accountId)
    end
	self.data = data 
end

function BlackJackGameController:getData()
	return self.data
end

--获取自己的位置
function BlackJackGameController:getMyPos()
	local player_data = self:getMyData()
	return player_data.m_chairId
end

--获取自己的pid
function BlackJackGameController:getMyPid()
	return Player:getAccountID()
end

--获取自己的数据
function BlackJackGameController:getMyData()
    local pid = Player:getAccountID()
	return self.player_data[pid]
end


--获取玩家的数据
function BlackJackGameController:getPlayerData(pid)
	return self.player_data[pid]
end

--保存玩家的数据
function BlackJackGameController:setPlayerData(pid,data)
	self.player_data[pid] = data
	if data ~= nil then
		--self.player_data[pid].cards = blackjack_util.getAllCardColor(data.cards)
	end
end

--保存牌的数据
function BlackJackGameController:setCardData(info)
	for k , v in pairs(info.cards) do
		self.player_cards[v.pos] = v.cards 
		v.cards = blackjack_util.getAllCardColor(v.cards) 
	end
     
end

function BlackJackGameController:setSafeData(info)
	self.safe_list[info.m_chairId] = info.m_accountId
end

function BlackJackGameController:getSafeData(pos)
	return self.safe_list[pos]
end

function BlackJackGameController:getCardData(pos)
	return self.player_cards[pos]
end

--获取所有玩家数据
function BlackJackGameController:getAllPlayerData()
	return self.player_data
end


--玩家数据变更,主要是更改金币
function BlackJackGameController:changePlayerInfo(data)
	for k , player in pairs(data.lists) do
		self:setPlayerData(player.pid, player) 
		sendMsg(  BLACKJACK_ADD_PLAYER, {pid = player.pid}) 	--新加入的玩家
	end
end
--玩家离开房间
function BlackJackGameController:setPlayerLeave(info)
	sendMsg(  BLACKJACK_PLAYER_LEAVE, {pid = info.pid , code = info.code})
	self:setPlayerData(info.pid,nil)
end

--[[准备
function BlackJackGameController:setPlayerState(info)
	local player = self:getPlayerData(info.pid)
	if player and info.code == 0 then
		player.state = 1
		sendMsg( { BLACKJACK_ROOM_READY, pid = info.pid})
	else
		sendMsg( { BLACKJACK_ERROR, data = info } )
	end
end
--]]

function BlackJackGameController:cleanPlayerState()
	for k , player in pairs(self.player_data) do
		if player.state ~= 1 then
			player.state = 0
		end
	end
end

function BlackJackGameController:changePlayerCoin(info)
	local player = self:getPlayerData(info.pid)
	if player then
		-- player.coin = player.coin - info.yazhu
	end
end

--设置玩家的下注情况
function BlackJackGameController:setMyBetInfo(info)
	if info.code == 0 then
		self:changePlayerCoin(info)
		self.bet_list[info.pid] = info.yazhu
		sendMsg(  BLACKJACK_ROOM_BET, {data = info})
	else
		sendMsg(  BLACKJACK_ERROR, {data = info})
	end
end

function BlackJackGameController:getBetList()
	return self.bet_list
end

function BlackJackGameController:isBet()
	return self.bet_list[self:getMyPid()] ~= nil
end

--获取正在玩的玩家数量
function BlackJackGameController:getPlayPlayerCount()
	local count = 0
	for _ , player in pairs(self.player_data) do
		if player.state >= 2 then
			count = count + 1
		end
	end
	return count
end

--结算
function BlackJackGameController:setResultData(info)
	print("-----------结算------------")
	local tmp = {}
	self.result_data = info
	for i , v in pairs(info.m_allResult) do
		v.cards = blackjack_util.getAllCardColor(v.cards)
	end
	print("结算协议")
	dump(self.result_data) 
end

--获取结算数据
function BlackJackGameController:getResultData()
	return self.result_data
end

--获取玩家金币数量
function BlackJackGameController:getPlayerCoin(pid)
	local player = self:getPlayerData(pid)
	if player then
		return player.coin
	end
	return 0
end

--设置房间类型
function BlackJackGameController:setRoomType(room_type)
	self.room_type = room_type
	app:enterScene("subgame.point21.blackjackScene")
end

-- --房间状态数据
function BlackJackGameController:setRoomState( info )
	self.room_state = info
    self.room_state.game_step = info.m_state 
    self.room_state.loop_pos  = info.m_opIdx or 30
    self.room_state.loop_start = info.m_opIdx 
	print("发生房间状态事件1111111111")
end

function BlackJackGameController:getPlayerShowPos(pid)
	local player = self:getPlayerData(pid)
	if player == nil then
	else
		return self:getShowPos(player.m_chairId)
	end
end

function BlackJackGameController:getPlayerFold(pid)
	return self.player_fold[pid]
end

--获取显示的座位号
--自己永远都是在第三位
function BlackJackGameController:getShowPos(pos)
	if pos == 0 then
		return 0
	end
	pos = math.floor(pos/10)
	local realy_pos = pos
	local my_pos = self:getMyPos()
	my_pos = math.floor(my_pos/10)
	local max_pos = 5
	local _mypos = 3

	local dis_pos
	if my_pos > _mypos then
		dis_pos = my_pos - _mypos
	
		pos = pos - dis_pos
		if pos <= 0 then
			pos = pos + max_pos
		end
	elseif my_pos < _mypos then
		dis_pos = _mypos - my_pos
		pos = pos + dis_pos
		if pos > max_pos then
			pos = pos - max_pos
		end
	end
	local list = {5,4,3,2,1}
	return list[pos]
end

--获取房间状态数据
function BlackJackGameController:getRoomState(  )
	return self.room_state
end

---房间玩家下注筹码
function BlackJackGameController:addJetton(jetton)
	table.insert(self.jetton_node, jetton)
end

--获取所有筹码
function BlackJackGameController:getAllJetton(  )
	print("获取所有筹码=",#self.jetton_node)
	return self.jetton_node
end

function BlackJackGameController:getBetOrder(  )
	self.bet_order = self.bet_order + 1
	return self.bet_order
end

function BlackJackGameController:errorTips(info)
	sendMsg(  BLACKJACK_ERROR, {data = info})
end

function BlackJackGameController:getPlayerSex(uid)
	if self.player_data[uid] then
		return self.player_data[uid].sex
	else
		return 1
	end
end

return BlackJackGameController
