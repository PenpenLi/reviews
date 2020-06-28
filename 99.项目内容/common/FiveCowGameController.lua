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
local FiveCowSearchPath = "src/app/game/fivecow"
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")
 
local FiveCowGameController =  class("FiveCowGameController",function()
    return BaseGameController.new()
end) 

FiveCowGameController.instance = nil

-- 获取房间控制器实例
function FiveCowGameController:getInstance()
    if FiveCowGameController.instance == nil then
        FiveCowGameController.instance = FiveCowGameController.new()
    end
    return FiveCowGameController.instance
end

function FiveCowGameController:releaseInstance()
    if FiveCowGameController.instance then
		FiveCowGameController.instance:onDestory()
        FiveCowGameController.instance = nil
		g_GameController = nil
    end
end

function FiveCowGameController:ctor()
    print("FiveCowGameController:ctor()")
    self:myInit()
end

-- 初始化
function FiveCowGameController:myInit()
    self.m_history = {}
    self.m_allPlayers = {}
    self.m_EndFlag = false
    self.m_matchFlag = false
    self.jetton_node = {} 		--model居然存了界面的节点,重连需要手动清除
    print("FiveCowGameController:myInit()") 
    -- 添加搜索路径
    ToolKit:addSearchPath(FiveCowSearchPath.."/res") 
    -- 加载场景协议以及游戏相关协议
     
    Protocol.loadProtocolTemp("app.game.fivecow.protoReg")
     
      self:initNetMsgHandlerSwitchData() 
    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包
end

function FiveCowGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}  
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Init_Nty"]                          =                   handler(self, self.gameInitNty)  
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_GameReady_Nty"]             =                   handler(self, self.gameReadyNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_DispatchCard_Nty"]                  =                   handler(self, self.gameStartNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_RobBanker_Nty"]            =                   handler(self, self.gameRobBankerNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_ShowBanker_Nty"]                 =                   handler(self, self.gameShowBankerNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Bet_Nty"]                   =                   handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Assemble_Nty"]                   =                   handler(self, self.gameAssembleNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_OpenCard_Nty"]                =                   handler(self, self.gameOpenCardNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Balance_Nty"]                  =                   handler(self, self.gameBalanceNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Banker_Ack"]                   =                   handler(self, self.gameRobBankerAck)  
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Assemble_Ack"]                   =                   handler(self, self.gameAssembleAck)  
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_Bet_Ack"]                   		=                   handler(self, self.gameBetAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_Rob_AssembleFinish_Nty"]                   		=                   handler(self, self.AssembleFinishNty) 
     self.m_netMsgHandlerSwitch["CS_G2C_RobCheckExit_Ack"]                   		=                   handler(self, self.ExitAck)  
      self.m_netMsgHandlerSwitch["CS_G2C_Rob_Exit_Ack"]                   		=                   handler(self, self.Exit)  
     
 
    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler)) 

    
    self.m_callBackFuncList = {}
     
	self.m_callBackFuncList["CS_M2C_Rob_EnterScene_Nty"]                     = handler(self,self.ackEenterScene)
	self.m_callBackFuncList["CS_M2C_Rob_Exit_Nty"]                        = handler(self,self.ackExitScene)  
   	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end
function FiveCowGameController:Exit(info)
    if info.m_result == 0 then
        UIAdapter:popScene()
        self:releaseInstance()
    end
end
function FiveCowGameController:ackExitScene(info)
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
function FiveCowGameController:onDestory()
	print("----------FiveCowGameController:onDestory begin--------------")
    TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	self.m_netMsgHandlerSwitch = {}
	self.m_callBackFuncList = {} 
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
	 
	
	self:onBaseDestory()
	
	print("----------FiveCowGameController:onDestory end--------------")

end
function FiveCowGameController:ackEenterScene(__info)
    print("ackEenterScene    "..__info.m_type)
    self.m_matchFlag = true
    self.m_EndFlag = false
    if __info.m_type == 0 then
        self.gameScene:getMainLayer():showTips("正在匹配中，请稍候....",false)
    end
end
function FiveCowGameController:netMsgHandler1(__idStr, __info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(__info)
  else
      print("没有处理消息",__idStr)
  end
end
 
function FiveCowGameController:sceneNetMsgHandler( __idStr, __info )
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
function FiveCowGameController:ExitAck( __info)
    if __info.m_keepCoin ~= 0 and __info.m_result == 0 then
        local message = "强退将暂时扣除" .. __info.m_keepCoin*0.01 .."金币，用于本局结算，结算后自动返还剩余金币，是否退出？"
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
function FiveCowGameController:gameExit(info)
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
 
function FiveCowGameController:netMsgHandler( __idStr,__info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])( __info )
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function FiveCowGameController:ackSceneMessage(__info)
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
 
function FiveCowGameController:ackEnterGame(__info)
	print("FiveCowGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(self.m_gameAtomTypeId) 
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL )  
    end
end 
function FiveCowGameController:logicToViewSeatNo(lSeatNO)
    return (lSeatNO - self._mySeatNo + 5+2) % 5+1;
end
function FiveCowGameController:addJetton(jetton)
	table.insert(self.jetton_node, jetton)
end
function FiveCowGameController:getAllJetton(  )
	print("获取所有筹码=",#self.jetton_node)
	return self.jetton_node
end
function FiveCowGameController:GetNextDeskStation()
   return (self._mySeatNo + (5 - 1)) % 5;
end
function FiveCowGameController:getAllPlayers()
    return self.m_allPlayers
end
function FiveCowGameController:getLeftTime()
    return self.m_leftTime
end
function FiveCowGameController:getMyCard()
--    local tab = {}
--    for k,v in pairs(self.m_myCardArr) do
--        if v.m_card~=0 then
--            local t = {}
--            t.size =v.m_point
--            t.color= v.m_color/16+1
--            table.insert(tab,t)
--        end
--    end
    return self.m_myCardArr
end

function FiveCowGameController:getBankerScore()
    return self.m_bankerScoreOp
end
function FiveCowGameController:getbetMultiple()
    return self.m_betMultipleOp
end
function FiveCowGameController:getCardResult()
    return self.m_openCardResult
end
function FiveCowGameController:getCardSequence()
    return self.m_openCardSequence
end
function FiveCowGameController:getPlayerPosByID(pid)
    for k,v in pairs(self.m_allPlayers) do
        if v.m_accountId == pid then
            return v.seatNo
        end
    end
end

function FiveCowGameController:getBankerId()
    return self.m_bankerId
end
function FiveCowGameController:getRandPlayer()
    return self.m_randPlayerArr
end 
function FiveCowGameController:getOpenCardResultById(pid)
    for k,v in pairs(self.m_openCardResult) do 
        if v.m_accountId == pid then
            return v
        end
    end
    return nil
end 
function FiveCowGameController:getOpenCardResult() 
    return self.m_openCardResult
end 
function FiveCowGameController:gameInitNty(__info)
   print("状态：   "..__info.m_state)
   self.m_matchFlag = false
  if(self.gameScene ~= nil) then
        --显示玩家信息
         for k,v in pairs(__info.m_initPlayer) do 
            if v.m_accountId == Player:getAccountID() then 
                self._mySeatNo =v.m_chairId 
                self._seatOffset = -self._mySeatNo
            end 
        end
         for k,v in pairs(__info.m_initPlayer) do  
            local seatNo = self:logicToViewSeatNo(v.m_chairId);
            v.seatNo = seatNo
            table.insert(self.m_allPlayers,v)
            
            self.gameScene:getMainLayer():setPlayerInfo(seatNo,v); 
        end  
        self.m_bankerId = __info.m_bankerId
        self.m_EndFlag = false
        self.m_myCardArr =__info.m_myCardArr
        self.m_leftTime = __info.m_leftTime
        self.m_bankerScoreOp  = __info.m_bankerScoreOp
        self.m_betMultipleOp= __info.m_betMultipleOp
        self.m_openCardResult= __info.m_openCardResult
        self.m_openCardSequence= __info.m_openCardSequence
        self.m_robAnte =  __info.m_robAnte
        self.m_roomName = __info.m_roomName 
        self.m_recordId = __info.m_recordId
        self.gameScene:getMainLayer().label_need_min_coin:setString("底注：" .. self.m_robAnte*0.01) 
        self.gameScene:getMainLayer().mTextRecord:setString("牌局ID:"..self.m_recordId)
        if __info.m_state == 1 then --播放开始动画
           self.gameScene:getMainLayer():playStartEffect()
        elseif __info.m_state == 2 then --发牌动画
           self.gameScene:getMainLayer():updateSendCard(199)
        elseif __info.m_state == 3 then --抢庄阶段
              self.gameScene:getMainLayer():doClockAnimation(self.m_leftTime)
         --    self.gameScene:getMainLayer():sendCard() 
             self.gameScene:getMainLayer():updateSendCard(199)
               if #__info.m_robProcess == 0 then
                     self.gameScene:getMainLayer():setGrabVisible(true) 
                     self.gameScene:getMainLayer():showTips("请抢庄",false)
                end
             for k,v in pairs(__info.m_robProcess) do 
                for m,n in pairs(self.m_allPlayers) do
                    if v.m_accountId == n.m_accountId then
                        if v.m_robScore ~= 100 then
                            self.gameScene:getMainLayer():setGrabCount(v.m_accountId,v.m_robScore) 
                            self.gameScene:getMainLayer():setGrabVisible(false)
                            self.gameScene:getMainLayer():hideTips()
                        else
                            if v.m_accountId == Player:getAccountID() then
                                self.gameScene:getMainLayer():setGrabVisible(true) 
                                self.gameScene:getMainLayer():showTips("请抢庄",false)
                            end
                        end
                    end
                end
            end
         elseif __info.m_state == 4 then --确认庄家
            self.gameScene:getMainLayer():updateSendCard(199)
                self.gameScene:getMainLayer():closeClock()
            self.gameScene:getMainLayer():doClockAnimation(__info.m_leftTime)
           
            for m,n in pairs(self.gameScene:getMainLayer().all_player_panel) do
                if __info.m_bankerId == n.pid then 
                    self.m_bankerId=__info.m_bankerId
                    self.gameScene:getMainLayer():doZjAction(n) 
                end
            end
       
      
            self.gameScene:getMainLayer():setGrabCount(__info.m_bankerId,__info.m_bankerRobScore) 
          elseif __info.m_state == 5 then --赔率选择
                self.gameScene:getMainLayer():updateSendCard(199)
                if #__info.m_betProcess == 0 then
                     if Player:getAccountID() ~= self:getBankerId() then    
                        self.gameScene:getMainLayer():stateTimes()
                        self.gameScene:getMainLayer():setTimesVisible(true)
                    else
                         self.gameScene:getMainLayer():setTimesVisible(false)
                    end
                end
               for k,v in pairs(__info.m_betProcess) do 
                    for m,n in pairs(self.m_allPlayers) do
                        if v.m_accountId == n.m_accountId then
                            if v.m_betMultiple ~= 100 then
                                v.m_betAccountId = n.m_accountId
                                self.gameScene:getMainLayer():eventRoomBet(v) 
                            else
                                if v.m_accountId == Player:getAccountID() then  
                                     self.gameScene:getMainLayer():stateTimes()
                                else
                                     self.gameScene:getMainLayer():setTimesVisible(false)
                                end
                            end
                        end
                    end
                end
               self.gameScene:getMainLayer():doClockAnimation(self.m_leftTime) 
         elseif __info.m_state == 6 then --拼牛阶段
            self.gameScene:getMainLayer():updateSendCard(199)
           self.gameScene:getMainLayer():doClockAnimation(self.m_leftTime)   
            for k , p in pairs(self.gameScene:getMainLayer().img_nn_tips_bg.img_bflabel_bg) do
                p:setVisible(false)
            end
            if #__info.m_assembleProcess == 0 then
                self.gameScene:getMainLayer():showFiveCard()
                self.gameScene:getMainLayer().img_nn_tips_bg:setVisible(true)
                self.gameScene:getMainLayer():setTimesVisible(false) 
                self.gameScene:getMainLayer():setHaveNiuVisible()
                self.gameScene:getMainLayer():hideTips()
            end
            for k,v in pairs(__info.m_assembleProcess) do
                 for m,n in pairs(self.gameScene:getMainLayer().all_player_panel) do
                    if n.pid == v.m_accountId then
                        if v.m_assembleResult == 1 then
                            self.gameScene:getMainLayer():updateRoomShowCard(v.m_accountId)
                        else
                            self.gameScene:getMainLayer():showFiveCard()
                            self.gameScene:getMainLayer().img_nn_tips_bg:setVisible(true)
                            self.gameScene:getMainLayer():setTimesVisible(false) 
                            self.gameScene:getMainLayer():setHaveNiuVisible()
                            self.gameScene:getMainLayer():hideTips()
                        end
                    end
                end
            end 
         elseif __info.m_state == 7 then --开牌阶段
            self.gameScene:getMainLayer():updateSendCard(199)
            self.gameScene:getMainLayer():showFiveCard()
            self.gameScene:getMainLayer():stateResult() 
         elseif __info.m_state == 8 then --结算阶段
             self.gameScene:getMainLayer():setReadyVisible(true)
             self.m_EndFlag = true
        end 
    end
end 
   
function FiveCowGameController:gameReadyNty(__info) 
    if(self.gameScene ~= nil) then 
          --播放开始动画 
          self.gameScene:getMainLayer():hideTips()
           self.gameScene:getMainLayer():playStartEffect()
    end
end

function FiveCowGameController:reqQuitGame()
    if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Rob_Exit_Req", {})
	end
end

function FiveCowGameController:reqCheckQuitGame()
    if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_RobCheckExit_Req", {})
	end
end
function FiveCowGameController:gameStartNty(__info)
    if(self.gameScene ~= nil) then
        --发牌动画
         self.m_myCardArr =__info.m_myCardArr
         self.gameScene:getMainLayer():updateSendCard(0)
        
    end
end

function FiveCowGameController:gameRobBankerNty(__info)
    if(self.gameScene ~= nil) then 
       --抢庄过程
        self.m_leftTime = __info.m_leftTime
        self.m_bankerScoreOp  = __info.m_bankerScoreOp
         self.gameScene:getMainLayer():doClockAnimation(__info.m_leftTime)
         --    self.gameScene:getMainLayer():sendCard() 
         self.gameScene:getMainLayer():setGrabVisible(true)     
          self.gameScene:getMainLayer():showTips("请抢庄",false)
--        for k,v in pairs(__info.m_bankerScoreOp) do 
--            for m,n in pairs(self.m_allPlayers) do
--                if v.m_accountId == n.m_accountId then
----                    if v.m_robScore ~= 100 then
----                        self.gameScene:getMainLayer():setGrabCount(v.m_accountId,v.m_robScore) 
----                        self.gameScene:getMainLayer():setGrabVisible(false)
----                    else
--                        if v.m_accountId == Player:getAccountID() then
--                            self.gameScene:getMainLayer():setGrabVisible(true) 
--                        end
--                   -- end
--                end
--            end
--        end
    end
end

function FiveCowGameController:gameShowBankerNty(__info)
 if(self.gameScene ~= nil) then 
  --显示庄家
     self.m_leftTime = __info.m_leftTime
     self.m_bankerId= __info.m_bankerId
     if __info.m_isRand==0 then
        self.gameScene:getMainLayer():closeClock()
        self.gameScene:getMainLayer():doClockAnimation(__info.m_leftTime)
        
        for m,n in pairs(self.gameScene:getMainLayer().all_player_panel) do
            if __info.m_bankerId == n.pid then 
                
                self.gameScene:getMainLayer():doZjAction(n) 
            end
        end
        self.gameScene:getMainLayer():setGrabCount(__info.m_bankerId,__info.m_bankerRobScore) 
    else
         self.m_randPlayerArr = __info.m_randPlayerArr
         self.gameScene:getMainLayer():stateRandomGrab()
    end
  end
end  
function FiveCowGameController:gameBetReq(betMultiple) 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Rob_Bet_Req", {betMultiple })
	end
end

function FiveCowGameController:gameAssembleNty(__info)
 --拼牛阶段
   self.gameScene:getMainLayer():closeClock()
        self.m_leftTime = __info.m_leftTime
        self.gameScene:getMainLayer():doClockAnimation(__info.m_leftTime)
    self.m_myCardArr =__info.m_myCardArr
    self.gameScene:getMainLayer():showFiveCard()
    self.gameScene:getMainLayer().img_nn_tips_bg:setVisible(true)
    self.gameScene:getMainLayer():setTimesVisible(false) 
    self.gameScene:getMainLayer():setHaveNiuVisible()
    self.gameScene:getMainLayer():hideTips()
    for k , p in pairs(self.gameScene:getMainLayer().img_nn_tips_bg.img_bflabel_bg) do
        p:setVisible(false)
    end 
end

function FiveCowGameController:gameBetAck(__info)
   if(self.gameScene ~= nil) then
       --自己倍率选择
        if __info.m_result ==0 then
            self.gameScene:getMainLayer():eventRoomBet(__info)
        else
            self:showTips(__info.m_result)
        end
    end
end 
function FiveCowGameController:gameBetNty(__info)
   if(self.gameScene ~= nil) then
       --倍率选择
        self.gameScene:getMainLayer():closeClock()
        self.m_leftTime = __info.m_leftTime
        self.gameScene:getMainLayer():doClockAnimation(__info.m_leftTime)
        self.m_betMultipleOp= __info.m_betMultipleOp
       if Player:getAccountID() ~= self:getBankerId() then    
            self.gameScene:getMainLayer():stateTimes()
            self.gameScene:getMainLayer():setTimesVisible(true)
        else
             self.gameScene:getMainLayer():setTimesVisible(false)
        end
   end
end
function FiveCowGameController:gameOpenCardNty(__info)
    if(self.gameScene ~= nil) then
       --开牌阶段
       self.m_openCardResult = __info.m_openCardResult
       self.gameScene:getMainLayer():stateResult()
    end
end

function FiveCowGameController:gameBalanceNty(__info)
    if(self.gameScene ~= nil) then
     --结算阶段
        self.m_EndFlag = true
         self.gameScene:getMainLayer():updateRoomResult(__info.m_balanceArr)
       --  self.gameScene:getMainLayer():setReadyVisible(true)
    end
end
--拼牛请求
function FiveCowGameController:gameAssembleReq(opType)
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Rob_Assemble_Req", {opType})
	end
end
 

function FiveCowGameController:userLeftAck(__info)
	print("FiveCowGameController:userLeftAck")
	self:releaseInstance()
end

function FiveCowGameController:gameRobBankerReq(robScore)
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Rob_Banker_Req", {robScore})
	end
end

function FiveCowGameController:gameRobBankerAck(__info)
    if(self.gameScene ~= nil) then
        --自己抢庄结果
        if __info.m_result== 0 then
            if __info.m_robAccountId ==Player:getAccountID() then
                self.gameScene:getMainLayer():setGrabVisible(false)
                self.gameScene:getMainLayer():hideTips()
            end
            self.gameScene:getMainLayer():setGrabCount(__info.m_robAccountId,__info.m_robScore) 
        else
            self:showTips(__info.m_result)
        end
    end
end 
function FiveCowGameController:AssembleFinishNty(__info)
    if(self.gameScene ~= nil) then
        --拼牛完成的玩家ID
        self.gameScene:getMainLayer():updateRoomShowCard(__info.m_accountId)
    end
end

function FiveCowGameController:gameBackgroundAck(__info)
    
end

function FiveCowGameController:gameBackgroundReq(nType)
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Rob_Background_Req", { nType})
	end
end
function FiveCowGameController:showTips(ret)
	if ret == -200201 then--桌子不存在
        TOAST("桌子不存在")
    elseif ret ==-200202 then	--抢庄分数非法
        TOAST("抢庄分数非法")
     elseif ret ==-200203 then	--抢庄分数不可用
        TOAST("抢庄分数不可用")
     elseif ret ==-200204 then --重复抢分
        TOAST("重复抢分")
     elseif ret ==-200205 then --当前状态不能抢庄
        TOAST("当前状态不能抢庄")
     elseif ret ==-200206 then --当前状态不能下注倍数
        TOAST("当前状态不能下注倍数")
     elseif ret ==-200207 then	--下注倍数非法
        TOAST("下注倍数非法")
     elseif ret ==-200208 then	--下注倍数不可用
        TOAST("下注倍数不可用")
     elseif ret ==-200209 then --重复下注倍数
        TOAST("重复下注倍数")
     elseif ret ==-200210 then --当前状态不能拼牛
        TOAST("当前状态不能拼牛")
     elseif ret ==-200211 then --拼牛操作参数非法
        TOAST("拼牛操作参数非法")
     elseif ret ==-200212 then --您有牛哦,请再耐心找找~
        TOAST("您有牛哦,请再耐心找找~")
     elseif ret ==-200213 then --您当前无牛哦,请再仔细看看~
        TOAST("您当前无牛哦,请再仔细看看")
     elseif ret ==-200214 then --重复拼牛
        TOAST("重复拼牛")
	 elseif ret ==-200215 then --庄家不能操作下注倍数
        TOAST("庄家不能操作下注倍数")
     elseif ret ==-200299 then --未知错误
        TOAST("未知错误")
     elseif ret ==-200216  then --玩家不存在
        TOAST("玩家不存在")
     elseif ret ==-200217  then --配置出错
        TOAST("配置出错") 
     end    
end    
function FiveCowGameController:handleError(__info)
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

function FiveCowGameController:gameAssembleAck(__info)
	if self.gameScene then 
		--自己拼牛按钮响应
	end
end
 

return FiveCowGameController