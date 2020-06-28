--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

----------------------------------------------------------------------------------------------------------
-- 项目：百家乐
-- 时间: 2018-01-11
----------------------------------------------------------------------------------------------------------
--local BaccaratDefine    = require("src.app.game.bjl.scene.BaccaratDefine")
local BaccaratEvent     = require("src.app.game.bjl.scene.BaccaratEvent")
local BaccaratDataMgr   = require("src.app.game.bjl.manager.BaccaratDataMgr")
local CBetManager = require("src.app.game.common.util.CBetManager")
  

local BetArea = 5
local ChipNum = 5

local BjlGameDesk = require("src.app.game.bjl.BjlGameDesk")
local scheduler           = require("framework.scheduler") 
local DlgAlert = require("app.hall.base.ui.MessageBox")
local BjlSearchPath = "src/app/game/bjl"
local BaseGameController = import(".BaseGameController") 
local BjlGameController =  class("BjlGameController",function()
    return BaseGameController.new()
end) 

BjlGameController.instance = nil

-- 获取房间控制器实例
function BjlGameController:getInstance()
    if BjlGameController.instance == nil then
        BjlGameController.instance = BjlGameController.new()
    end
    return BjlGameController.instance
end

function BjlGameController:releaseInstance()
    if BjlGameController.instance then 
		BjlGameController.instance:onDestory()
		BjlGameController.instance = nil

		g_GameController = nil
    end
end

function BjlGameController:ctor()
    print("BjlGameController:ctor()")
    self:myInit()
end 

-- 初始化
function BjlGameController:myInit()
	print("BjlGameController:myInit") 
	self.m_history = {}
	
    -- 添加搜索路径
    ToolKit:addSearchPath(BjlSearchPath.."/res")
    ToolKit:addSearchPath(BjlSearchPath.."/src") 
    -- 加载场景协议以及游戏相关协议
     
    Protocol.loadProtocolTemp("app.game.bjl.protoReg")
     
	self:initNetMsgHandlerSwitchData()
	
    --注册游戏协议
    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包
end
 
function BjlGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {}
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_GetRoomList_Ack"]                    =                   handler(self, self.gameGetRoomListAck)-- 请求房间列表
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_EnterRoom_Ack"]                          =                   handler(self, self.gameEnterRoomAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_StatePlay_Nty"]                      =                   handler(self, self.gameStatePlayNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_GameFree_Nty"]             	=                   handler(self, self.gameFreeNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_GameStart_Nty"]                  =                   handler(self, self.gameStartNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_GameEnd_Nty"]                 =                   handler(self, self.gameEndNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_History_Nty"]                  =                   handler(self, self.gameHistoryNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_Bet_Nty"]                   =                   handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_PlayerOnlineList_Ack"]                =                   handler(self, self.gamePlayerOnlineListNty) 
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_Background_Ack"]                   =                   handler(self, self.gameBackgroundAck) 
	self.m_netMsgHandlerSwitch["CS_G2C_UserLeft_Ack"]                   		=                   handler(self, self.userLeftAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_Baccarat_Continue_Nty"]                   		=                   handler(self, self.gameContinueBet) 
    
    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
	
	addMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT, handler(self, self.socketState))	
	addMsgCallBack(self, MSG_ENTER_FOREGROUND, handler(self, self.onEnterForeground)) -- 转前台
	addMsgCallBack(self, MSG_ENTER_BACKGROUND, handler(self, self.onEnterBackground)) -- 转后台 
	addMsgCallBack(self, POPSCENE_ACK, handler(self, self.showEndGameTip))
	addMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT, handler(self,self.onSocketEventMsgRecived))
end

function BjlGameController:onDestory()
	print("---------BjlGameController:onDestory begin-----------")
		
    self.m_netMsgHandlerSwitch = {}
    self.m_roomList = {}
    self.m_score={}
    self.m_history = {}
    self.m_dyzlu ={}
    self.m_xlu ={}
    self.m_xqlu ={}
	
	if self.m_disconnectDlg then
		self.m_disconnectDlg:closeDialog()
		self.m_disconnectDlg = nil
	end
	
	self:closeScene()
	self:closeRoomLayer()
	
	removeMsgCallBack(self, POPSCENE_ACK)
	removeMsgCallBack(self, MSG_ENTER_FOREGROUND)
	removeMsgCallBack(self, MSG_ENTER_BACKGROUND)
	removeMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT)
	removeMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT)
	
	self:onBaseDestory()
	print("---------BjlGameController:onDestory end-----------")
	
end

function BjlGameController:netMsgHandler( __idStr,info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
        (self.m_netMsgHandlerSwitch[__idStr])( info )
    else
        print("未找到百家乐游戏消息" .. (__idStr or ""))
    end
end

function BjlGameController:ackSceneMessage(info)
    if info.id == "CS_M2C_Baccarat_Exit_Nty" then
        local dlg= nil
        if info.msgs.m_type == 3 then
			dlg = DlgAlert.showTipsAlert({title = "提示", tip = "你已经被系统踢出房间，请稍后重试"})
        elseif info.msgs.m_type == 4 then
			dlg = DlgAlert.showTipsAlert({title = "提示", tip = "房间维护，请稍后再游戏"})
        end
        dlg:setSingleBtn("退出", function ()
			dlg:closeDialog()
			self:releaseInstance()
        end)
        dlg:enableTouch(false)
    end
end

function BjlGameController:gameGetRoomListAck(info)
    print("BjlGameController:gameGetRoomListAck room num:", #info.m_roomList)
    self.m_roomList = info.m_roomList
    self.m_score = info.m_score
	self.isBaijiale = true
	
	if #info.m_roomList > 0 and self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
    --显示房间列表
    if self.m_roomLayer == nil then
        self.m_roomLayer = BjlGameDesk.new(self.m_roomList,self.m_score)
        cc.Director:getInstance():getRunningScene():addChild(self.m_roomLayer, 102)
    else
        self.m_roomLayer:reloadRoomList(self.m_roomList,self.m_score)
    end
	
	--[[
    if #info.m_roomList > 0 and self.gameScene then
        local DlgAlert = require("app.hall.base.ui.MessageBox")
        local dlg = kickDialog.showTipsAlert({title = "提示", tip = "游戏已结束", tip_size = 34})
                dlg:setSingleBtn("确定", function () 
                     self.gameScene:exitGame()  
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
    end
	--]]
end

function BjlGameController:gameEnterRoomReq(roomId) 
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_EnterRoom_Req", { roomId })
	end
end

function BjlGameController:gameQuitRoomReq()    
	if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_ExitRoom_Req", {self.m_roomId })
	end
end

function BjlGameController:gameEnterRoomAck(info)  
	--ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and info.m_ret == 0 then 
        local scenePath = getGamePath(self.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
     --   self.gameScene:getMainLayer():setRoomID(info.m_roomId)
        self.m_roomId = info.m_roomId
        
    end
end 

function BjlGameController:gameStatePlayNty(info) 
    -- 数据
    local msg = {}
    msg.cbTimeLeave = info.m_leftTime
    msg.cbGameStatus = info.m_state
    msg.lAllBet = {}
    for i = 1, #info.m_totalBet do
        msg.lAllBet[i] = info.m_totalBet[i]*0.01
    end
    msg.lPlayBet = {}
    for i = 1, #info.m_myBet do
        msg.lPlayBet[i] = info.m_myBet[i]*0.01
    end 
    msg.lPlayFreeScore = info.m_score*0.01
    
   -- msg.lPlayAllScore = info.m_profit*0.01 

    --扑克信息
    msg.cbCardCount = {#info.m_xianCards,#info.m_bankerCards} 
    msg.cbTableCardArray = {}
    msg.cbTableCardArray[1] = info.m_xianCards
     msg.cbTableCardArray[2] = info.m_bankerCards

    self.m_nRecordId = info.m_recordId
    -- if self.m_nRecordId ~= "" then
    --     self.gameScene:getMainLayer().mTextRecord:setString("牌局ID:"..self.m_nRecordId)
    -- end
   
    msg.llChipsValues = {1,10,50,100,500}
--    for i = 1, 8 do
--        msg.llChipsValues[i] = info.readLongLong()
--    end

--    msg.iRevenueRatio = info.readInt() --税率

    --清理数据
    BaccaratDataMgr.getInstance():setContinueBet(info.m_canContinueBet)
    BaccaratDataMgr.getInstance():clean()
     BaccaratDataMgr.getInstance():setOtherNum(info.m_playerCount) 
    --保存
    BaccaratDataMgr:getInstance():setUserScore(msg.lPlayFreeScore)
   
    BaccaratDataMgr.getInstance():setGameState(msg.cbGameStatus) 
    if BaccaratDataMgr.eType_Bet == msg.cbGameStatus then
        BaccaratDataMgr.getInstance():setStateTime(msg.cbTimeLeave + 1) -- +1是为了衔接的更紧 
        -- 通知
        sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_STATE, "1")
    elseif BaccaratDataMgr.eType_Award == msg.cbGameStatus then
        BaccaratDataMgr.getInstance():setStateTime(msg.cbTimeLeave + 2) -- +2是为了包含空闲时间  
        
    else
        BaccaratDataMgr.getInstance():setStateTime(msg.cbTimeLeave) 
    end
  --  BaccaratDataMgr.getInstance():setGameTax(msg.iRevenueRatio)
    print("场景消息通知时间:" .. msg.cbTimeLeave)

    --设置5个筹码数据
    local chipValueList = msg.llChipsValues
    for i = 1, ChipNum do
        local bet_value = chipValueList[i] or chipValueList[#chipValueList]
        bet_value = msg.llChipsValues[i] == 0 and bet_value or msg.llChipsValues[i]
        CBetManager.getInstance():setJettonScore(i, bet_value)
        BaccaratDataMgr.getInstance():setJettonScoreByIndex(i,bet_value)
    end

    --设置押注数据
    for i = 1, #msg.lAllBet do
        BaccaratDataMgr.getInstance():setAllBetValue(i, msg.lAllBet[i], 1) 
    end
      for i = 1, #msg.lPlayBet do 
        BaccaratDataMgr.getInstance():setMyBetValue(i, msg.lPlayBet[i], 1)
    end
    --fly jetton
    for i = 1, BetArea do
        --modify
        if msg.cbGameStatus == BaccaratDataMgr.eType_Bet then
            if msg.lPlayBet[i] > 0 then
                BaccaratDataMgr.getInstance():parseJetton(BaccaratDataMgr.eType_MyInit, Player:getAccountID(), i, msg.lPlayBet[i])
            end
            if msg.lAllBet[i] > msg.lPlayBet[i] then 
                local _nChair = -1
                local _nBet = msg.lAllBet[i] - msg.lPlayBet[i]
                --ERROR
                BaccaratDataMgr.getInstance():parseJetton(BaccaratDataMgr.eType_OtherInit, _nChair, i, _nBet)
            end
        end
    end
    BaccaratDataMgr.getInstance():resetRemaingBet()
    BaccaratDataMgr.getInstance():setIsLoadGameSceneData(true)
end
 

function BjlGameController:gameFreeNty(info) 
   
    if(self.gameScene ~= nil) then
         BaccaratDataMgr.getInstance():setGameState(BaccaratDataMgr.eType_Wait)
        BaccaratDataMgr.getInstance():setStateTime(info.m_timeLeft) 
        -- 通知
        sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_STATE, "0")
    elseif(self.m_roomLayer ~= nil) then
        local rNum = table.nums(self.m_roomList)
        for i=1,rNum do
            if self.m_roomList[i].m_id==info.m_roomId then
                self.m_roomLayer:resetNoTime(i)
                self.m_roomLayer:resetFreeState(i)
                return
            end
        end
    end
end 
 
function BjlGameController:gameStartNty(info)
	if(self.gameScene ~= nil) then
     local msg = {}
    msg.cbTimeLeave = info.m_timeLeft         --剩余时间    
    self.m_nRecordId = info.m_recordId
    -- if self.m_nRecordId ~= "" then
    --     self.gameScene:getMainLayer().mTextRecord:setString("牌局ID:"..self.m_nRecordId)
    -- end
    -- 保存
     BaccaratDataMgr.getInstance():setContinueBet(info.m_canContinueBet)
    BaccaratDataMgr.getInstance():setOtherNum(info.m_playerCount) 
    BaccaratDataMgr.getInstance():setGameState(BaccaratDataMgr.eType_Bet)
    BaccaratDataMgr.getInstance():setStateTime(msg.cbTimeLeave + 1)  
    BaccaratDataMgr.getInstance():cleanAllBetValue()
    BaccaratDataMgr.getInstance():cleanUserBet()
    BaccaratDataMgr.getInstance():setIsContinued(false)
    BaccaratDataMgr.getInstance():resetRemaingBet() 
    -- 通知
    sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_STATE, "1")
	elseif(self.m_roomLayer ~= nil) then
        dump(info, "roominfo")
        local rNum = table.nums(self.m_roomList)
        for i=1,rNum do
            if self.m_roomList[i].m_id==info.m_roomId then
                self.m_roomLayer:resetTimeLeft(info.m_timeLeft,i)
                self.m_roomLayer:resetStartState(i)
                return
            end
        end
    end
end 
function BjlGameController:gameEndNty(info)
    if(self.gameScene ~= nil) then
   -- if(self.gameScene ~= nil) then
    local msg = {}
    ---- 下局信息
    msg.cbTimeLeave = info.m_timeLeft -- 剩余时间
    ---- 扑克信息 
    msg.cbCardCount = {#info.m_xianCards,#info.m_bankerCards} 
    msg.cbTableCardArray = {}
    msg.cbTableCardArray[1] = info.m_xianCards
     msg.cbTableCardArray[2] = info.m_bankerCards
     
     msg.lPlayAllScore = info.m_profit*0.01 
     ---- 全局信息 
     msg.cbRankCount = #info.m_allResult --排行数量
     
    
     
     BaccaratDataMgr.getInstance():setUserScore(info.m_score*0.01)
    -- 保存
    BaccaratDataMgr.getInstance():setGameState(BaccaratDataMgr.eType_Award)
    BaccaratDataMgr.getInstance():setStateTime(msg.cbTimeLeave + 2) -- 加上空闲时间2秒 
    BaccaratDataMgr.getInstance():cleanCard()   --牌面
    for i = 1, 2 do
        for n = 1, 3 do
            if n <= msg.cbCardCount[i] then
                local card = {}
                card.iValue = BaccaratDataMgr.getInstance():GetCardValue(msg.cbTableCardArray[i][n])
                card.iColor = BaccaratDataMgr.getInstance():GetCardColor(msg.cbTableCardArray[i][n])
                BaccaratDataMgr.getInstance():setCard(i, n, card)
            end
        end
    end
    --BaccaratDataMgr.getInstance():addGameRecordByOpen() --加入开奖记录
    BaccaratDataMgr.getInstance():cleanRank()   --结算排行版
    for i = 1, msg.cbRankCount do
        local rank = {}
        rank.name = info.m_allResult[i].m_nick
        rank.llScore = info.m_allResult[i].m_profit*0.01
        BaccaratDataMgr.getInstance():addRank(rank)
    end
  --  BaccaratDataMgr.getInstance():setContinueBet()  --设置续投
  --  BaccaratDataMgr.getInstance():setPlayScore(msg.lPlayScore)  --设置

     
    BaccaratDataMgr.getInstance():setMyResult(msg.lPlayAllScore)
  
    sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_STATE, "2")
    
    local ret = string.format("%s", "游戏结算")
    elseif (self.m_roomLayer~=nil) then
        self.m_roomLayer:resetRoomList(info)
  end
end
function BjlGameController:gameContinueBet(info)
    self:gameBetNty(info)
end
function BjlGameController:gameBetReq(id,value)
   print("位置    "..id)
   print("  金额  "..value)
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_Bet_Req", { self.m_roomId, id,value, })
	end
end
function BjlGameController:gameContinueBetReq() 
   if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_Continue_Req", { self.m_roomId})
	end
end
function BjlGameController:gameBetNty(info)
   if(self.gameScene ~= nil) then
        local str = ""
        if info.m_ret== 0 then 
            -- 数据
            local msg = {}

            msg.wChairID = info.m_bets.m_accountId
            for i=1,#info.m_bets.m_bets do
                msg.cbBetArea = info.m_bets.m_bets[i].m_betId        --筹码区域
                print("下注位置     "..msg.cbBetArea)
                msg.lBetScore = info.m_bets.m_bets[i].m_betValue*0.01    --加注数目
                 
              --  msg.cbBetArea = msg.cbBetArea + 1

                -- 保存下注筹码
                BaccaratDataMgr.getInstance():setAllBetValue(msg.cbBetArea, msg.lBetScore, 1)
                if msg.wChairID == Player:getAccountID() then
                    BaccaratDataMgr.getInstance():setMyBetValue(msg.cbBetArea, msg.lBetScore, 1)
                    if not BaccaratDataMgr.getInstance():getIsContinued() then
                        BaccaratDataMgr.getInstance():cleanContinueBet()
                        BaccaratDataMgr.getInstance():setIsContinued(true)
                    end
                    local bet = {}
                    bet.cbBetArea = msg.cbBetArea
                    bet.lBetScore = msg.lBetScore
                    BaccaratDataMgr.getInstance():addUserBet(bet) 
                    BaccaratDataMgr.getInstance():setUserScore(info.m_bets.m_coin*0.01) 
                  --  PlayerInfo.getInstance():addBetScore(msg.lBetScore)
                end

                BaccaratDataMgr.getInstance():resetRemaingBet()

                -- 通知

                if msg.wChairID == Player:getAccountID() then --自己投注直接发送
                    sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_CHIP_SUCCESS, msg)
                else
                    --1秒内随机投递事件 最后1秒直接投递
                    if BaccaratDataMgr.getInstance():getStateTime() > 1 then
                        local randomts = math.random(0,8)/10
                        scheduler.performWithDelayGlobal(function()
                            sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_CHIP_SUCCESS, msg)
                        end, randomts)
                    else
                        sendMsg(BaccaratEvent.MSG_GAME_BACCARAT_CHIP_SUCCESS, msg)
                    end
                end
            end
            return
        elseif info.m_ret== -200108 then
            str ="您的金币不足！"
        elseif info.m_ret== -200109 then
             str ="你下注超过个人上限！"
        elseif info.m_ret== -200105 then
            str ="你下注的区域无效！"
        elseif info.m_ret== -200119 then
            str ="无此筹码！"
        elseif info.m_ret== -200117 then
            str ="不在房间中！"
        elseif info.m_ret== -200105 then
            str ="下注区域无效！"
        elseif info.m_ret== -200118 then
            str ="下注失败, 携带金币低于30金币！"
        elseif info.m_ret== -200120 then
            str ="无下注局"
        elseif info.m_ret== -200121 then
         str ="单局只能续押一次！" 
        end

        TOAST(str)
   elseif(self.m_roomLayer ~= nil) then
        dump(info, "gamebetnty")
   end
end

function BjlGameController:gameHistoryNty(info)
--    if(self.gameScene ~= nil) then
--        self.m_history= info.m_history
--        self.m_dyzlu =info.m_dyzlu
--        self.m_xlu =info.m_xlu
--        self.m_xqlu =info.m_xqlu
--        self.gameScene:getMainLayer():setGameCount(info.m_history)
--        self.gameScene:getMainLayer():showLeftRecorf(info.m_history)
--        self.gameScene:getMainLayer():dealYuceReslut(self.m_dyzlu,self.m_xlu,self.m_xqlu)
--    elseif(self.m_roomLayer ~= nil) then
--        dump(info,"gameHistoryNty")
--    end
    local _SIZE_OF_A_RECORD = 5 -- size of tagServerGameRecord
    local records = {}
    for k,v in pairs(info.m_history) do
        local record = 
        { 
            bPlayerTwoPair  = v.m_xianPair ,-- 对子标识
            bBankerTwoPair  = v.m_bankerPair ,-- 对子标识
            cbPlayerCount   = v.m_xianVal   ,--闲家点数
            cbBankerCount   = v.m_bankerVal   ,--庄家点数
        }
        table.insert(records, record)
    end

    --保存
    for k, v in pairs(records) do
        if BaccaratDataMgr.eType_Bet ~= BaccaratDataMgr.getInstance():getGameState() and k == table.nums(records) then
            BaccaratDataMgr.getInstance():setCacheRecord(records[k])
        else
            BaccaratDataMgr.getInstance():addGameRecord(records[k])
        end
    end
end

function BjlGameController:gamePlayerOnlineListNty(info)
    if(self.gameScene ~= nil) then
      --  sendMsg(MSG_BJL_RANK_ASK,info)
       BaccaratDataMgr.getInstance():setOnlinePlayers(info.m_playerInfo)
        self.gameScene:getMainLayer():updateOnlineUserList()
    elseif(self.m_roomLayer ~= nil) then
        dump(info,"PlayerOnlineListNty")
    end
end

function BjlGameController:gamePlayerOnlineListReq()
	if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_PlayerOnlineList_Req", { 1,100 })
	end
end

function BjlGameController:gamePlayerShowAck(info)
    if(self.gameScene ~= nil) then
        self.gameScene:getMainLayer():updateUserList(info)
    elseif(self.m_roomLayer ~= nil) then
        dump(info, "PlayerShowAck")
    end
end

function BjlGameController:gameBackgroundAck(info)
    
end

function BjlGameController:userLeftAck(info)
	print("BjlGameController:userLeftAck")
	self:releaseInstance()
end

function BjlGameController:gameBackgroundReq(nType)
	if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_Background_Req", { nType})
	end
end 

function BjlGameController:ackRealEnterGame( info )
	 ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_EnterRoom_Req", { 111 })
end

function BjlGameController:ackEnterGame2( info )
    if self.m_gameAtomTypeId then
        ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_Baccarat_GetRoomList_Req", { 1 })
    end
end

function BjlGameController:handleError(info)
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

--[[
function BjlGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function BjlGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]

-- 从后台切换到前台
function BjlGameController:onEnterForeground()
	print("从后台切换到前台")  
	self:gameBackgroundReq(2)
end

-- 从前台切换到后台
function BjlGameController:onEnterBackground()
   print("从前台切换到后台,游戏线程挂起!")
   self:gameBackgroundReq(1)
   self.m_BackGroudFlag=true
end

--弹出场景
function BjlGameController:closeScene()
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
end

--关闭roomLayer界面, 必须调用close
function BjlGameController:closeRoomLayer()
	if self.m_roomLayer then
		self.m_roomLayer:clearData()
		self.m_roomLayer:close()
		self.m_roomLayer = nil
	end
end

function BjlGameController:showSocketDisConnetExitGameTip()
    self:closeDisconnectDilog()
    self.m_disconnectDlg = DlgAlert.showTipsAlert({title = "提示", tip = "与服务器断开,请重连", tip_size = 34})
	self.m_disconnectDlg:setSingleBtn("确定", function ()
		self:reqEnterScene()
		self.m_disconnectDlg:closeDialog()
		self.m_disconnectDlg = nil
    end)
	
    self.m_disconnectDlg:setBackBtnEnable(false)
    self.m_disconnectDlg:enableTouch(false)
end

function BjlGameController:showEndGameTip()
	print("----BjlGameController:showEndGameTip-----")
	if self.gameScene then
		return
	end
		
	self:closeDisconnectDilog()
    local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "游戏已结束", tip_size = 34})
	dlg:setSingleBtn("确定", function ()
		dlg:closeDialog()
		self:releaseInstance()
    end)
	
    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false)
end

function BjlGameController:socketState(msgName , _info )
   if  _info.connectName == cc.net.SocketTCP.EVENT_CLOSED then
		if ConnectManager:isConnectSvr(Protocol.LobbyServer) then
			if self.m_BackGroudFlag == true then
                self:showSocketDisConnetExitGameTip() 
            else
				self:reqEnterScene()
            end
		end
	elseif _info.connectName == cc.net.SocketTCP.EVENT_CONNECTED then
		self:closeDisconnectDilog()
    end
end

function BjlGameController:onSocketEventMsgRecived( __msgName, __protocol, __connectName )
	if Protocol.LobbyServer == __protocol then
		if __connectName == cc.net.SocketTCP.EVENT_CLOSED or __connectName == cc.net.SocketTCP.EVENT_CLOSE then
			self:closeDisconnectDilog()
		end
	end
end

function BjlGameController:onClickBackButton()
	if not self.gameScene and self.m_roomLayer then
		self:reqUserLeftGameServer()
		--self:releaseInstance()
	end
end

--[[
function BjlGameController:close()	
	if self.gameScene then
		self:gameQuitRoomReq()
	elseif self.m_roomLayer then
		self:reqUserLeftGameServer()
	end
	
	self:releaseInstance()
	g_GameController = nil
end
--]]

return BjlGameController