--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 游戏控制类 
local scheduler = require("framework.scheduler")
local BaseGameController = import(".BaseGameController")
local DlgAlert = require("app.hall.base.ui.MessageBox")
local HoxDataMgr                    = require("src.app.game.cattle.src.manager.HoxDataMgr")
local CBetManager                   = require("src.app.game.common.util.CBetManager")  
local NiuNiuCBetManager              = require("src.app.game.cattle.src.manager.NiuNiuCBetManager")
local Handredcattle_Events          =require("src.app.game.cattle.src.scene.HandredcattleEvent")
local DOWN_COUNT_HOX = 4
local PLAYERS_COUNT_HOX = 5
local HAND_COUNT = 5
local CattleGameController =  class("CattleGameController",function()
    return BaseGameController.new()
end) 
CattleGameController.instance = nil

function CattleGameController:ctor()
    ToolKit:addSearchPath("src/app/game/cattle/res")
     ToolKit:addSearchPath("src/app/game/cattle/src") 
    ToolKit:addSearchPath("src/app/game/cattle/src/common/cattleprotocol") 
    Protocol.loadProtocolTemp("niuniu.protoReg")
	self:myInit()
   -- ToolKit:gGameFPS(1/60.0)
end

function CattleGameController:getInstance() 
	if  CattleGameController.instance == nil then 
		CattleGameController.instance = CattleGameController.new()
	end
	return CattleGameController.instance
end

function CattleGameController:releaseInstance()
    if CattleGameController.instance then
		CattleGameController.instance:onDestory()
        CattleGameController.instance = nil
		g_GameController = nil
    end
end

function CattleGameController:myInit() 
	self.gameScene = nil  --游戏场景
	self.m_netMsgHandlerSwitch = {} -- 消息集合

	self.m_roomData =  nil -- 获取房间数据
	self.m_arrUserData = {} -- 桌子玩家信息
	self.m_selfChairId = nil -- 自己的椅子号
	self.m_cellScore = {} -- 默认选择倍率筹码列表
	self.m_bankerArray = {} 
	self.m_applyArray = {}  
	self.m_arrAddScore = {}
	self.m_recordArray = {}
	self.m_allGameScore = {}
	self.m_selfGameScore = {}
	self.m_gameTimes = {}
	self.m_jokerCardData = {} -- 扑克变牌
	self.m_cardArray = {}  -- 扑克牌
	self.m_bankerRandCard = {}
	self.m_userwinlosttimes = {}
	self.m_maxAddScore = 0 -- 最大下注
	self.m_applyScore = 0 -- 申请庄家
	self.m_timeRemaining = 0 -- 剩余时间
	self.m_addAllScore = 0 -- 一局下的筹码总数
	self.m_selfAddScore = 0
    self.m_exitGame = false --游戏退出
    self.m_sendChangTable = false -- 发送换桌消息
	self.m_reEnter = 0 -- 重连标志 0:非重连 1:重连
	self.m_exit_req_time = 0
	self.m_exitNtyReceive = false
    self.m_exit_req = nil
    self.m_lastAddTimes = 0
    self.m_sendAddScore = 0 -- 玩家下注发送的筹码数量
    self.m_sceneInit = 0
    self.m_playerMaxGameScore = 0

    self.m_userBetInfo = {} --用户筹码信息

  --  self:setEnterGameAckHandler( handler(self, self.askGameDataInitInfo)  )
    self:initNetMsgHandlerSwitchData()
    -- 游戏状态 
 	self:initHandredcattle_Events()
end

function CattleGameController:initHandredcattle_Events()
	-- 注册接受转义消息
    addMsgCallBack(self, Handredcattle_Events.MSG_COW_BET_XIAZHU, handler(self, self.addScoreReq)) -- 下注
	addMsgCallBack(self, Handredcattle_Events.MSG_COW_OPENCARD_OVER, handler(self, self.openPokerOver)) -- 闲家一家开牌完成
	addMsgCallBack(self, Handredcattle_Events.MSG_COW_SHANGZHUANG_REQ, handler(self, self.applyBankeraReq)) -- 请求上庄
	addMsgCallBack(self, Handredcattle_Events.MSG_COW_XIAZHUANG_REQ, handler(self, self.cancelBankerReq) )-- 请求下庄
    addMsgCallBack(self, Handredcattle_Events.MSG_COW_CONTINUE_XIAZHU, handler(self, self.continueBetReq)) -- 续压
    addMsgCallBack(self, Handredcattle_Events.MSG_COW_ONLINE_REQ, handler(self, self.onlineListReq)) -- 续压
end

function CattleGameController:initNetMsgHandlerSwitchData()

	----------------------------------------- 4个场景游戏状态 --------------------------------------
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_GameState_Nty" ]     =  handler(self,self.gameGameStateNty)   -- 游戏空闲状态 
------------------9个客户端-游戏服(逻辑)----------------- 
    self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_GameFree_Nty"]               =  handler(self,self.gameEndFree)--游戏结束，空闲状态
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_StartAddScore_Nty" ]     =  handler(self,self.startAddScoreNty) --开始下注
    self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_GameEnd_Nty" ]           =  handler(self,self.gameEndNty) --游戏结束
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_AddScore_Ack" ]          =  handler(self,self.addScoreAck) --玩家下注响应(失败时才返回)
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_AddScore_Nty" ]          =  handler(self,self.addScoreNty) --玩家下注广播(成功时广播)

	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_Apply_Banker_Ack" ]      =  handler(self,self.applyBankerAck) --申请庄家响应
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_Cancel_Banker_Ack" ]     =  handler(self,self.cancelBankerAck) --取消上庄响应
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_UpdateBankerArray_Nty" ] =  handler(self,self.updateBankerArrayNty) --刷新庄家通知
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_UpdateApplyArray_Nty" ]  =  handler(self,self.updateApplyArrayNty) --刷新申请庄家队列通知
    self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_UpdatePlayerNum_Nty" ]  =  handler(self,self.updateOtherNum) --刷新玩家人数
     
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_UpdateScore_Nty" ]       =  handler(self,self.updateScoreNty) --游戏刷新积分(服务端刷新积分)  
    self.m_netMsgHandlerSwitch[ "CS_G2C_OX_ContinueBet_Ack" ]       =  handler(self,self.continueBetAck) --续压
	
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_ServiceError_Nty"]           =  handler(self,self.ServiceErrorNty)--游戏服异常  
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_GameEnd_ExitBanker_Nty"]   =  handler(self,self.exitBankerNty)--退庄家队列消息
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_GameEnd_ExitApply_Nty"]   =  handler(self,self.exitApplyNty)--退申请庄家队列消息
    self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_Exit_Nty"]               =  handler(self,self.exitNty)--退出游戏
    self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_PlayerOnlineList_Ack"]   =  handler(self,self.onlineListAck)--玩家列表
    
	self.m_netMsgHandlerSwitch[ "CS_G2C_Ox_Remain_BankerTimes_Ack"]   =  handler(self,self.bankerTimesAck)--庄家剩余上庄次数   
    self.m_netMsgHandlerSwitch["CS_G2C_UserLeft_Ack"]                   		=                   handler(self, self.userLeftAck) 
 

	self.m_protocolList = {}
	for k,v in pairs(self.m_netMsgHandlerSwitch) do
		self.m_protocolList[#self.m_protocolList+1] = k
	end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
end

function CattleGameController:removeHandredcattle_EventsCallBack()
	removeMsgCallBack(self, Handredcattle_Events.MSG_COW_BET_XIAZHU)
	removeMsgCallBack(self, Handredcattle_Events.MSG_COW_OPENCARD_OVER)
	removeMsgCallBack(self, Handredcattle_Events.MSG_COW_SHANGZHUANG_REQ)
	removeMsgCallBack(self, Handredcattle_Events.MSG_COW_XIAZHUANG_REQ)
    removeMsgCallBack(self, Handredcattle_Events.MSG_COW_CONTINUE_XIAZHU) 
    removeMsgCallBack(self, Handredcattle_Events.MSG_COW_ONLINE_REQ) 
end

--弹出场景
function CattleGameController:closeScene()
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
end

function CattleGameController:onDestory()
	print("---------CattleGameController:onDestory begin-----------")
	
	if self.m_exit_req then
        scheduler.unscheduleGlobal(self.m_exit_req)
        self.m_exit_req = nil
    end
	
	self:removeHandredcattle_EventsCallBack()
	self:closeScene() 
	self.m_netMsgHandlerSwitch = {}
	
	self:onBaseDestory()
	print("---------CattleGameController:onDestory end-----------")
	
end

function CattleGameController:netMsgHandler( __idStr,__info )
	--print("__idStr11111111 = ",__idStr)
	--[[
	if self.gameScene and self.gameScene:getSocketState() == false then -- 已断开，不处理了
		if __idStr == "CS_G2C_Ox_Exit_Nty" then

		else
			return
		end
	end
	if self.gameScene  and self.gameScene:getOnEnterForeground() == false then -- 转后台
		if __idStr == "CS_G2C_Ox_Exit_Nty" then
			
		else
			return
		end
	end
	--]]
	if self.m_netMsgHandlerSwitch[__idStr] then
		(self.m_netMsgHandlerSwitch[__idStr])( __info )
	else
		print("未找到牛牛游戏消息" .. (__idStr or ""))
	end
end

function CattleGameController:ackEnterGame(__info)
	print("CattleGameController:ackEnterGame")
	dump(__info)
	g_cowLastEnterRoomID = __info.m_gameAtomTypeId
	ToolKit:removeLoadingDialog()
	if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then  
        local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL,{["ctl"] = g_GameController,["roomData"] = self:getRoomData()} )  
    end
end

function CattleGameController:handleError( __info )
    print("CowRoomController onEnterScene 进入场景")
    if __info.m_ret ~= 0 then
	  --  ToolKit:removeLoadingDialog()
	end
	local data = RoomData:getPortalDataByAtomId(__info.m_gameAtomTypeId)
	if data.id ~= RoomData.CRAZYOX then -- 只有牛牛才判断
		return
	end
    if __info.m_ret == CowRoomDef.SceneErrorId.GLOD_NOT_ENOUGH then
    	-- TOAST("最小金币数量限制，不能进入游戏")
		local room = RoomData:getRoomDataById(__info.m_gameAtomTypeId)
		if room  then
			local josn = json.decode(room.roomMinScore)
	        for k,v in pairs(josn) do
	        	if v.min > Player:getGoldCoin() then 
				    GlodDialog.new(v.min,getFuncOpenStatus(CowRoomDef.Fun.GOUMAI_GLOD ) ~= 1):showDialog()
				------------------------------------------------------------------------------------------
				    break
				end
			end
	    end
	elseif __info.m_ret == CowRoomDef.SceneErrorId.GLOD_EXCEED_MAX then 
		local dlg = DlgAlert.showTipsAlert({tip =  "您的金币超出了该房间" .. v.max .."限制", tip_size = 34})
        dlg:setSingleBtn(STR(37, 5), function ()
            dlg:closeDialog()
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
	elseif __info.m_ret ==  CowRoomDef.SceneErrorId.ROOM_Maintain then -- 房间维护
		print("房间维护")
	elseif __info.m_ret ~= 0 then
		ToolKit:showErrorTip(__info.m_ret)
	
	end
	if __info.m_ret ~= 0 then
		self:releaseInstance()
	end
end
 
-- 游戏消息逻辑处理
---------------------------------------------------------------------------------------------------------------------
-- 请求游戏初始化信息
function CattleGameController:askGameDataInitInfo( __info )

	print("请求游戏初始化信息-------------------")

    if __info.m_result == 0 then
   	-- 进入游戏成功
   		self.m_roomData =  RoomData:getRoomDataById( self:getGameAtomTypeId() ) -- 获取房间数据
	   	-- dump(self.m_roomData)
		self:gameInitReq()
   	elseif __info.m_result == -1 then
       -- 密钥不对
        CowToolKit:showErrorTip( "密钥不对" )
    end
    if self.gameScene then
		self.gameScene:gameInitReq()
	end
end 

function CattleGameController:getLastAddTimes()
	return self.m_lastAddTimes
end 
 

--用户筹码信息
function CattleGameController:getUserBetInfo()
	return self.m_userBetInfo
end

function CattleGameController:setUserBetInfo(_info)

	--dump(_info, "用户筹码信息_info::::::::::::", 10)
    for k,v in pairs(_info.m_vctBetInfo) do
        table.insert(self.m_userBetInfo,v*0.01)
    end
	--self.m_userBetInfo = _info.m_vctBetInfo
	if self.gameScene then
		self.gameScene:userBetInfo(_info)
	end
end

-- 场景消息
function CattleGameController:gameFreeSceneNty( _info )
	-- 刷新游戏界面
	self:creatGameSceneInfo(_info,HoxDataMgr.m_gameState.FREE)
end

function CattleGameController:gameStartSceneNty( _info )
	-- 刷新游戏界面
	self:creatGameSceneInfo(_info,HoxDataMgr.m_gameState.START)
end

function CattleGameController:gameAddSceneNty( _info )
	-- 刷新游戏界面
	-- dump(_info.m_selfAddScore,"m_selfAddScore")
	-- if _info.m_selfAddScore == nil then
	-- 	print("m_selfAddScore nil ")
	-- end

	self:creatGameSceneInfo(_info,HoxDataMgr.m_gameState.ADD)
end

function CattleGameController:gameEndSceneNty( _info )
	-- 刷新游戏界面
	self:creatGameSceneInfo(_info,HoxDataMgr.m_gameState.END)
end
------------------------------- 创建界面信息 --------------------------
function CattleGameController:gameGameStateNty( _buffer )
   
    local msg = {}   
    msg.llBankerScore = _buffer.m_totalBankerCoin*0.01         --如果是系统坐庄，这是系统的分数
    msg.llMinBankerScore = _buffer.m_applyScore*0.01       --上庄限制 
    msg.llMaxBankerScore= _buffer.m_maxApplyScore*0.01
    msg.cbGameStatue = _buffer.m_status+1  --游戏状态

    msg.llMyDownJetton = {}
    msg.llTotalJetton = {} 
    for i = 1,4 do
        if _buffer.m_arrAddScore[i] then
            msg.llTotalJetton[i] = _buffer.m_arrAddScore[i]*0.01   --当前所有人押注情况
        else
            msg.llTotalJetton[i] =0
        end
    end
    for i = 1,4 do
        if _buffer.m_selfAddScore[i] then
            msg.llMyDownJetton[i] = _buffer.m_selfAddScore[i]*0.01   --当前我押注情况
        else
            msg.llMyDownJetton[i] =0
        end
    end
    
    msg.cbHisCount = #_buffer.m_winHistoryArr --历史记录数
    msg.pHistory = {}
    for i = 1, #_buffer.m_winHistoryArr do
        msg.pHistory[i] = {}
        msg.pHistory[i].bWin = {} --历史记录
        for j = 1,4 do
            msg.pHistory[i].bWin[j] = _buffer.m_winHistoryArr[i].m_record[j]>0
        end
    end

    msg.iTiemrIndex = _buffer.m_timeRemaining   
    msg.iTotalBoard = _buffer.m_totalRound --今日总局数
    msg.iBoardCount = _buffer.m_winRoundArr       
    
 --   msg.cbTableUserCount = _buffer:readUChar()  --上桌玩家数
    
    msg.llChipsValues = {1,10,50,100,500}
    
--    msg.cbRoonModel = _buffer:readUChar()
    HoxDataMgr.getInstance():setModeType(10)
--    msg.dwRevenueRatio = _buffer:readUInt()
    CBetManager.getInstance():setGameTax(0)
	HoxDataMgr.getInstance():setRecordId(_buffer.m_recordId)
    --设置筹码值
    local chipValueList = BR_BASE_CHIP_LIST
    for i = 1, 5 do
        local bet_value = chipValueList[i] or chipValueList[#chipValueList]
        bet_value = msg.llChipsValues[i] == 0 and bet_value or msg.llChipsValues[i]
        CBetManager.getInstance():setJettonScore(i, bet_value)
        NiuNiuCBetManager.getInstance():setJettonScore(i, bet_value)
    end
    local pGameScene = msg 
     HoxDataMgr.getInstance():setOtherNum(_buffer.m_playerNum)
     HoxDataMgr.getInstance():getOtherNum()
     HoxDataMgr.getInstance():setGameSelfScore(_buffer.m_self.m_score*0.01)
    HoxDataMgr.getInstance():setBankerGold(pGameScene.llBankerScore) 
    HoxDataMgr.getInstance():setBankerArray(_buffer.m_bankerArray)
     HoxDataMgr.getInstance():setApplyArray(_buffer.m_applyArray)
        HoxDataMgr.getInstance():setApplyNum(#_buffer.m_applyArray)
    HoxDataMgr.getInstance():setMinBankerScore(pGameScene.llMinBankerScore) 
    HoxDataMgr.getInstance():setMaxBankerScore(pGameScene.llMaxBankerScore) 
    HoxDataMgr.getInstance():setGameStatus(pGameScene.cbGameStatue )
    local time = pGameScene.cbGameStatue == 3 and msg.iTiemrIndex + 1 or msg.iTiemrIndex
    NiuNiuCBetManager.getInstance():setTimeCount(time)
      
    --历史记录
    HoxDataMgr.getInstance():clearHistory()
    local min = math.min(pGameScene.cbHisCount,10)
    if pGameScene.cbHisCount < 3 then
        print("通知到的历史消息数量：" .. pGameScene.cbHisCount)
    end
    for i = 1, min do
        HoxDataMgr.getInstance():addHistoryToList(pGameScene.pHistory[i])
    end
    HoxDataMgr.getInstance():setTotalBoard(pGameScene.iTotalBoard)
    for i = 1, DOWN_COUNT_HOX do
        HoxDataMgr.getInstance():setWinBoardCount(i,pGameScene.iBoardCount[i])
    end
     
    --当前局已下注金币
    HoxDataMgr.getInstance():clearUsrChip()
    HoxDataMgr.getInstance():clearOtherChip()
    for i = 1, DOWN_COUNT_HOX do
        local totalJetton = pGameScene.llTotalJetton[i]
        local selfJetton = pGameScene.llMyDownJetton[i]
        local otherJetton = ((totalJetton - selfJetton) > 0) and (totalJetton - selfJetton) or 0
         
        if selfJetton > 0 then
             local selfTable = CBetManager.getInstance():getSplitGoldNew(selfJetton)
             for k,v in pairs(selfTable) do
                local selfChip = {}
                selfChip.wChipIndex = i
                selfChip.wJettonIndex = HoxDataMgr.getInstance():GetJettonMaxIdx(v)
                HoxDataMgr.getInstance():addUsrChip(selfChip)
             end
        end
        
        --other
        while otherJetton > 0 do              
            local index = HoxDataMgr.getInstance():GetJettonMaxIdx(otherJetton)
            if index >= 1 then
                local jettonVal = NiuNiuCBetManager.getInstance():getJettonScore(index)
                otherJetton = otherJetton - jettonVal
                HoxDataMgr.getInstance():addOtherChip(i,jettonVal)
            end
        end
    end
     if _buffer.m_canContinueBet ==1 then
        NiuNiuCBetManager.getInstance():setContinue(true)
    else
        NiuNiuCBetManager.getInstance():setContinue(true)
    end
    self:gameState(msg.iTiemrIndex,msg.cbGameStatue) 
end
function CattleGameController:gameState(time,state) 
    local t = HoxDataMgr.instance
    HoxDataMgr.getInstance():setGameStatus(state); 
    if state == 2 then -- 1秒
     --   HoxDataMgr.getInstance():setGameStatus(HoxDataMgr.eGAME_STATUS_IDLE)
    elseif state == 3 then -- 21秒
        HoxDataMgr.getInstance():setCurBankerTimes(HoxDataMgr.getInstance():getCurBankerTimes() + 1)
     --   HoxDataMgr.getInstance():setGameStatus(HoxDataMgr.eGAME_STATUS_CHIP) 
        NiuNiuCBetManager.getInstance():setTimeCount(time)
       
        --HoxDataMgr.getInstance():updateBetContinueRec()
    elseif state == 4 then -- 21秒
     --   HoxDataMgr.getInstance():setGameStatus(HoxDataMgr.eGAME_STATUS_END)
        NiuNiuCBetManager.getInstance():setTimeCount(time + 1) -- 包含空闲的一秒
    end

    --通知
    local _event = {
        name = Handredcattle_Events.MSG_HOX_UDT_GAME_STATUE, 
    }
    sendMsg(Handredcattle_Events.MSG_HOX_UDT_GAME_STATUE, _event)
     
end

function CattleGameController:onlineListAck(info)
    HoxDataMgr.getInstance():setOnlinePlayers(info.m_playerInfo)
     sendMsg(Handredcattle_Events.ONLINE_LIST)
end

function  CattleGameController:getMyBankerCoin()
   for k,v in pairs(self.m_bankerArray) do
        local bankinfo = self:getGamePlayerInfo( v.m_chairId )
        if bankinfo.m_userId == Player:getAccountID()  then
            return v.m_bankerCoin
        end
    end
    return 0
end

function CattleGameController:getAllBet()
    return self.m_totalBet or 0
end

function CattleGameController:updateScene()
	if self._info then
		self.gameScene:updateScene( {m_info = self._info} )
		self._info = nil
	end
end

--------------------------------- 游戏逻辑 ------------------------------
--播放开始下注动画
function CattleGameController:gameStartAnimNty()
	self:setGameState( HoxDataMgr.m_gameState.START )
	self:setAddAllScore(0)
	self:setSelfAddScore(0)
	self:setReEnter(false)
	if self.gameScene then
		self.gameScene:gameStartAnimNty()
	end
end

--开始下注倒计时
function CattleGameController:startAddScoreNty(_info)
 if _info.m_canContinueBet ==1 then
        NiuNiuCBetManager.getInstance():setContinue(true)
    else
        NiuNiuCBetManager.getInstance():setContinue(false)
	end
	HoxDataMgr.getInstance():setRecordId(_info.m_recordId)
    self:gameState(_info.m_timeCountDown,3) 
end

--玩家下注请求
function CattleGameController:addScoreReq(masname,_data)  
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_AddScore_Req", {_data.m_addArea,_data.m_addScore*100})
end
function CattleGameController:continueBetReq()  
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_OX_ContinueBet_Req", {})
end
function CattleGameController:onlineListReq()  
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_PlayerOnlineList_Req", {1,100})
end

-- 玩家失败返回
function CattleGameController:addScoreAck(_info)
--	if self.gameScene and self.m_sceneInit then
--		self.gameScene:showCowGameTipsNode( _info.m_result )
--	end
    local str = ""
    if _info.m_result == -120001 then
        str ="庄家不可下注"
    elseif _info.m_result == -120003 then
        str = "下注已达庄家上限"
      elseif _info.m_result == -120004 then
        str = "个人下注已达上限"
      elseif _info.m_result == -121144 then
        str = "金币不足，无法下注"
      elseif _info.m_result == -120000 then
        str = "下注区域错误"
     elseif _info.m_result == -121145 then
        str = "金币不足当前筹码10倍，无法下注"
     elseif _info.m_result == -120021	 then
        str = "上庄金币不足"
     elseif _info.m_result == -120046 then
        str = "上庄金币不合法"
     elseif _info.m_result == -120047 then
        str = "上庄金币达到系统上限，无法上庄"
     elseif _info.m_result == -120048 then
        str = "上庄金币将要达到系统上限，请选择较低金币上庄"
      elseif _info.m_result == -200118 then
        str = " 金币低于30，不能下注"
     elseif _info.m_result == -120050 then
        str = " 一局只能续押一次"
    end
    TOAST(str)
end
function  CattleGameController:continueBetAck( _buffer ) 
    if _buffer.m_result == 0 then
        if _buffer.m_betAccountId == Player:getAccountID() then
            HoxDataMgr.getInstance():setGameSelfScore(_buffer.m_curCoin*0.01)
        end
        for k,v in pairs(_buffer.m_continueBetArr) do
            local msg = {} 
            msg.wChairID = _buffer.m_betAccountId
            msg.wChipIndex = v.m_pos   --下注索引  
            local tab = {1,10,50,100,500}
            for m,n in pairs(tab) do
                if n ==v.m_betValue*0.01 then
                     msg.wJettonIndex = m --筹码索引
                end
            end 
            --保存
             local chip = msg.wChipIndex+1
             local score = NiuNiuCBetManager.getInstance():getJettonScore(msg.wJettonIndex)
            if msg.wChairID == Player:getAccountID() then --自己投注   
                local selfChip = {}
                selfChip.wChipIndex = chip
                selfChip.wJettonIndex = msg.wJettonIndex
                HoxDataMgr.getInstance():addUsrChip(selfChip)
            else 
                HoxDataMgr.getInstance():addOtherChip(chip, score)
            end
            local userDownChip = {}
            userDownChip.wChairID = msg.wChairID
            userDownChip.wChipIndex = msg.wChipIndex+1
            userDownChip.wJettonIndex = msg.wJettonIndex 
            userDownChip.bIsSelf = (msg.wChairID == Player:getAccountID()) 
           -- HoxDataMgr.getInstance():pushOtherUserChip(userDownChip)

            --通知 
    
            sendMsg(Handredcattle_Events.MSG_GAME_SHIP,userDownChip)
        end

    end
end
function  CattleGameController:addScoreNty( _buffer ) 
--	self.m_addAllScore = self.m_addAllScore + _info.m_addScore*0.01
--	if _info.m_chairId == self:getSelfChairId() then
--		self.m_selfAddScore = self.m_selfAddScore + _info.m_addScore*0.01
--	end 
--	if self.gameScene and self.m_sceneInit then  
--		self.gameScene:addScoreNty(_info)
--	end
--     local _buffer = __data:readData(__data:getReadableSize())

    --数据
    local msg = {}
    msg.wChairID = _buffer.m_userId     --椅子ID
    msg.wChipIndex = _buffer.m_addArea   --下注索引
    print("_buffer.m_addScore"  .._buffer.m_addScore)
    local tab = {1,10,50,100,500}
    for k,v in pairs(tab) do
        if v ==_buffer.m_addScore*0.01 then
             msg.wJettonIndex = k --筹码索引
        end
    end 
    --保存
     local chip = msg.wChipIndex+1
     local score = NiuNiuCBetManager.getInstance():getJettonScore(msg.wJettonIndex)
    if msg.wChairID == Player:getAccountID() then --自己投注  
--        local curGold = PlayerInfo.getInstance():getUserScore()
--        local subGold = NiuNiuCBetManager.getInstance():getJettonScore(msg.wJettonIndex)
--         HoxDataMgr.getInstance():setGameSelfScore(curGold - subGold)
        local selfChip = {}
        selfChip.wChipIndex = chip
        selfChip.wJettonIndex = msg.wJettonIndex
        HoxDataMgr.getInstance():addUsrChip(selfChip)
    else 
        HoxDataMgr.getInstance():addOtherChip(chip, score)
    end
    local userDownChip = {}
    userDownChip.wChairID = msg.wChairID
    userDownChip.wChipIndex = msg.wChipIndex+1
    userDownChip.wJettonIndex = msg.wJettonIndex 
    userDownChip.bIsSelf = (msg.wChairID == Player:getAccountID()) 
   -- HoxDataMgr.getInstance():pushOtherUserChip(userDownChip)

    --通知 
    if _buffer.m_userId == Player:getAccountID() then
        HoxDataMgr.getInstance():setGameSelfScore(_buffer.m_score*0.01)
    end
    sendMsg(Handredcattle_Events.MSG_GAME_SHIP,userDownChip)
end
 
function CattleGameController:gameEndNty( _buffer )

--	self:setGameState( HoxDataMgr.m_gameState.END )
--	self:setJokerCardData(_info.m_jokerCardData)
--	self:setCardArray(_info.m_cardArray )
--	self:setBankerRandCard(_info.m_bankerRandCard)
--	self:setGameTimes(_info.m_gameTimes)
--	self:setSelfGameScore(_info.m_selfGameScore)

--	--dump(_info.m_allGameScore, "_info.m_allGameScore:::::::", 10)

--	self:setAllGameScore(_info.m_allGameScore)
--	if self.gameScene and self.m_sceneInit then
--		self.gameScene:gameEndNty(_info)
--	end
--        local _buffer = __data:readData(__data:getReadableSize())

    --数据
   --  NiuNiuCBetManager.getInstance():setTimeCount(_buffer.m_timeCountDown)
    
    local msg = {}
    msg.llBankerResult = _buffer.m_allBankerWinScore*0.01
    msg.llBankerScore = _buffer.m_allBankerWinScore*0.01
    msg.llAreaTotalResult = {}
--    for i = 1,DOWN_COUNT_HOX do
--        msg.llAreaTotalResult[i] = _buffer:readLongLong()
--    end
--    msg.llAreaMyResult = {}
--    for i = 1,DOWN_COUNT_HOX do
--        msg.llAreaMyResult[i] = _buffer:readLongLong()
--    end
    msg.llFinaResult = _buffer.m_selfGameScore*0.01
 --   msg.iBankerTimes = _buffer:readInt() 
    msg.cbSendCardData={}
    for i = 1,PLAYERS_COUNT_HOX do
        msg.cbSendCardData[i] = {} 
        for j = 1, HAND_COUNT do
            local card = _buffer.m_cardArray[i].m_card[j] 
            msg.cbSendCardData[i][j] = card
        end
    end
    msg.bPlayerWin = {}
    for i = 1, DOWN_COUNT_HOX do
        msg.bPlayerWin[i] = _buffer.m_gameTimes[i]
    end
    msg.cbRankList = _buffer.m_allGameScore
--    msg.wRankChairID = {}
--    for i = 1, 10 do
--        msg.wRankChairID[i] = _buffer:readUShort()
--    end
--    msg.llRankResult = {}
--    for i = 1, 10 do
--        msg.llRankResult[i] = _buffer:readLongLong()
--    end 
    --保存/更新庄家分数
    HoxDataMgr.getInstance():setBankerCurrResult(msg.llBankerResult)
    local data = msg
    HoxDataMgr.getInstance():addOpenData(data)
  --  HoxDataMgr.getInstance():ComparePlayerCard()
    
    HoxDataMgr.getInstance():setCardType(_buffer.m_cardType)
    HoxDataMgr.getInstance():sortShowCard()
    HoxDataMgr.getInstance():setGameStatus(HoxDataMgr.eGAME_STATUS_END)
    --通知
    local _event = {
        name = Handredcattle_Events.MSG_HOX_GAME_END,
        packet = msg,
    }
    HoxDataMgr.getInstance():setGameSelfScore(_buffer.m_score*0.01)
    sendMsg(Handredcattle_Events.MSG_HOX_GAME_END, _event)
    self:gameState(_buffer.m_timeCountDown,4) 
end


--申请庄家请求
function CattleGameController:applyBankeraReq(msg,info)
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_Apply_Banker_Req", info)
end

-- 请求剩余上庄次数
function CattleGameController:applyBankerTimesReq()
	ConnectManager:send2GameServer(self.m_gameAtomTypeId,"CS_C2G_Ox_Remain_BankerTimes_Req", {})
end

-- 记录最后一次使用的筹码
function CattleGameController:recordUseJetton_Req()
	local pos = 1
	if self.gameScene then
		pos = self.gameScene:getSelOldBet()
		if self.m_addTimes then
			local tiems = self.m_addTimes[pos]
			if tiems then
				ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_RecordUseJetton_Req", {tiems})
			end
		end
	end 
end

function CattleGameController:bankerTimesAck( _info )
	if self.gameScene then
		self.gameScene:bankerTimesAck( _info )
	end
end

function CattleGameController:applyBankerAck ( _info )
	 if _info.m_result == 0 then  -- 成功
    elseif  _info.m_result == HoxDataMgr.ErrorID.Success_ApplyBanker_By_Update_Apply then -- 申请成功，刷新排队列表
        
        TOAST("等本局结束后上庄")
         sendMsg(Handredcattle_Events.MSG_CLOSE)
    elseif _info.m_result == HoxDataMgr.ErrorID.Success_ApplyBanker_By_Update_Banker then -- 申请成功，刷新庄家列表
        TOAST("上庄成功")
        sendMsg(Handredcattle_Events.MSG_CLOSE)
    elseif _info.m_result == HoxDataMgr.ErrorID.Err_ApplyBanker_By_Lack_Score then -- 申请失败，金币不足 
        TOAST("申请失败，金币不足 ")
    else 
    end
end

--取消上庄请求
function CattleGameController:cancelBankerReq ()
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_Cancel_Banker_Req", {})
end

function CattleGameController:exitBankerNty(_info)--退庄家队列消息
	if HoxDataMgr.ErrorID.tips[_info.m_result] then
		if self.gameScene and self.m_sceneInit then
			local str = HoxDataMgr.ErrorID.tips[_info.m_result]
			if _info.m_result == HoxDataMgr.ErrorID.Rst_GameEnd_ExitBanker_Over_Times then
				-- local lianzhuangShu = _info.m_data
				-- str = "连庄已达" .. lianzhuangShu .. "局数上限，系统自动换庄"
				self.gameScene:lianXuShangZhuang()
			else
				self.gameScene:setAlwaysApply( false )
			end
			self.gameScene:showCowGameTipsNode( str )
		end
	end
end

function CattleGameController:exitApplyNty( _info )--退申请庄家队列消息
	if HoxDataMgr.ErrorID.tips[_info.m_result] then
		if self.gameScene and self.m_sceneInit then
			self.gameScene:showCowGameTipsNode( HoxDataMgr.ErrorID.tips[_info.m_result] )
				self.gameScene:setAlwaysApply( false )
		end
	end
end

function CattleGameController:cancelBankerAck ( _info)
	    if _info.m_result == 0 then
        
    elseif _info.m_result == HoxDataMgr.ErrorID.Success_CancelBanker_By_Cur_Game then --成功退庄(还在游戏中) 
       TOAST("等本局结束后下庄") 
      
    elseif _info.m_result == HoxDataMgr.ErrorID.Success_CancelBanker_By_Exit_Apply then -- 成功退庄(退出申请队列) 
       TOAST("等本局结束后下庄") 
    elseif _info.m_result == HoxDataMgr.ErrorID.Success_CancelBanker_By_Exit_Banker then -- 成功退庄(退出庄家队列)
       TOAST("退庄成功") 
    else 
    end
end

function CattleGameController:updateBankerArrayNty(_info)
	HoxDataMgr.getInstance():setBankerGold(_info.m_totalBankerCoin*0.01) 
    HoxDataMgr.getInstance():setBankerArray(_info.m_bankerArray)
    sendMsg(Handredcattle_Events.MSG_UPDATE_APPLYARRAY_NTY)
end

function CattleGameController:getBankerCount()
    return self.bankerCount or 0
end

function CattleGameController:getTotalBank()
    return self.m_totalBankerCoin or 0
end

function CattleGameController:updateApplyArrayNty(_info) 

     HoxDataMgr.getInstance():setApplyNum(#_info.m_applyArray) 
     HoxDataMgr.getInstance():setApplyArray(_info.m_applyArray) 
     sendMsg(Handredcattle_Events.MSG_UPDATE_APPLYARRAY_NTY)
end

function  CattleGameController:supplyAck( _info )
	if _info.m_result == 0 then -- 补充结果
		TOAST(STR(6, 1))
	elseif _info.m_result == HoxDataMgr.ErrorID.Err_G2C_SUPPLY then
		TOAST(HoxDataMgr.ErrorID.Err_G2C_SUPPLY) 
	end
end

function CattleGameController:userLeftAck(__info)
	print("CattleGameController:userLeftAck")
	self:releaseInstance()
end  

function CattleGameController:gameInitNty(_info)
	dump(_info, "初始化信息:", 10)

	self:setSelfChairId(_info.m_selfChairId)
	self:setSelfUserId(_info.m_selfUserId)
	self:setArrUserData(_info.m_arrUserData)
	self:setReEnter( _info.m_reEnter )
	self:setApplyScore( _info.m_applyScore )
--	self:setCellScore( _info.m_cellScore )
	self:setAddTimes( _info.m_addTimes)
	self:setPlayerMaxGameScore( _info.m_playerMaxGameScore or 100000)
    self.m_maxApplyScore =_info.m_maxApplyScore
end

function CattleGameController:getMaxApplyScore()
    return self.m_maxApplyScore or 0
end

function CattleGameController:userEnterGameNty(_info)
	self:updateArrUserData( _info.m_userData,true )
end

function CattleGameController:userExitGameNty(_info)
	--dump(_info,"userExitGameNty")
	local userInfo = self:getGamePlayerInfo(_info.m_chairId)
	if userInfo then
		-- self:updateArrUserData( userInfo,false )
		-- self:delUserWinLostTimesInfo(userInfo.m_userId)
	end
end

function CattleGameController:updateScoreNty(_info)
	for i=1,#_info.m_arrUserData do
		self:updateArrUserDataScore( _info.m_arrUserData[i].m_chairId,_info.m_arrUserData[i].m_score)
	end
	if self.gameScene and self.m_sceneInit then
		self.gameScene:updateScoreNty(  _info  ) 
	end
end
function CattleGameController:updateOtherNum(_info)
    HoxDataMgr.getInstance():setOtherNum(_info.m_playNum)
end
function CattleGameController:ServiceErrorNty( _info )
	if self.gameScene then
		self.gameScene:showServiceErrorNtyTip()
	end
end

function CattleGameController:gameEndFree()  
     HoxDataMgr.getInstance():setGameStatus(2)
      HoxDataMgr.getInstance():clearUsrChip()
    HoxDataMgr.getInstance():clearOtherChip()
      sendMsg(Handredcattle_Events.MSG_HOX_UDT_GAME_STATUE)
end

function CattleGameController:userExitGameReq()
	ToolKit:addLoadingDialog(10, "正在退出房间...")
--	self:recordUseJetton_Req()
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_Exit_Req", {}) 
	self:releaseInstance()
end

function CattleGameController:sendExitGameReq()
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_Exit_Req", {})
end

-- 3秒没回包，直接强退
function CattleGameController:updateExitReq()
	if self.m_exit_req then
        scheduler.unscheduleGlobal(self.m_exit_req)
        self.m_exit_req = nil
    end
    if self.m_exit_req_time and (os.time() - self.m_exit_req_time >= HoxDataMgr.exitGameTime) then
    	if self.m_exitNtyReceive == false then
			
    	end
    end
end

function CattleGameController:exitNty(_info)
	-- dump(_info)
	print("CattleGameController:exitNty")
--	ToolKit:removeLoadingDialog()
	self.m_exitNtyReceive = true
	-- print("_info.m_result = ",_info.m_result)
	if HoxDataMgr.ErrorID.tips[_info.m_result] then
		local scene = UIAdapter.sceneStack[#UIAdapter.sceneStack]
	    if  scene.class.__cname == "CowGameScene" then -- CrazyCowEntrance 
            local dlg = DlgAlert.showTipsAlert({tip = HoxDataMgr.ErrorID.tips[_info.m_result], tip_size = 34})
            dlg:setSingleBtn(STR(37, 5), function ()
				dlg:closeDialog()
                self:releaseInstance()
            end)
            dlg:setBackBtnEnable(false)
            dlg:enableTouch(false)
	    else
			local dlg = DlgAlert.showTipsAlert({tip = HoxDataMgr.ErrorID.tips[_info.m_result], tip_size = 34})
            dlg:setSingleBtn(STR(37, 5), function ()
				dlg:closeDialog()
                self:releaseInstance()
            end)
            dlg:setBackBtnEnable(false)
            dlg:enableTouch(false)
	    end
	else
		if self.gameScene then
			self:releaseInstance()
		end
	end
end

function CattleGameController:changeTableAck( _info )
--	ToolKit:removeLoadingDialog()
	if self.gameScene then
		self.gameScene:updateHuanzhuoState( _info )
	end
end

--[[
function CattleGameController:StrongbackGame()
	if self.gameScene then
		self.gameScene:StrongbackGame()
	end
end
--]]

function CattleGameController:sendCS_C2G_Ox_ChangeTable_Req()
	ToolKit:addLoadingDialog(10, "正在换桌，请等待...")
	self.m_sendChangTable = true
	ConnectManager:send2GameServer(self.m_gameAtomTypeId, "CS_C2G_Ox_ChangeTable_Req", {})
	-- 断开 

end
------------------------------------- get/set ---------------------------------

function CattleGameController:setPlayerMaxGameScore( _playerMaxGameScore )
	print("玩家最大下注分數:",  _playerMaxGameScore)
	self.m_playerMaxGameScore = _playerMaxGameScore
end

function CattleGameController:getPlayerMaxGameScore()
	--[[return self.m_playerMaxGameScore / HoxDataMgr.m_MaxXiaZhuRate--]]
	return self.m_playerMaxGameScore
end

function CattleGameController:setAddTimes( _addTimes)
	self.m_addTimes = _addTimes
end

function CattleGameController:getAddTimes()
	return self.m_addTimes
end

function CattleGameController:setReEnter( _reEnter )
	self.m_reEnter = _reEnter
end

function CattleGameController:getReEnter()
	return self.m_reEnter
end

function CattleGameController:setSelfUserId(_selfUserId )
	self.m_selfUserId = _selfUserId
end

function CattleGameController:getSelfUserId()
	return self.m_selfUserId
end

function CattleGameController:getCellScore()
	return self.m_cellScore
end

function CattleGameController:setCellScore( _cellScore )
	self.m_cellScore = _cellScore
	self:setTotalScoreType()
end

function CattleGameController:setTotalScoreType()
	self.m_totalScore = {} 
	for i=1, #self.m_userBetInfo do
		for j=1, #HoxDataMgr.m_betRate do

			if #self.m_totalScore == 0 then
				self.m_totalScore[#self.m_totalScore + 1] = self.m_cellScore[i] * HoxDataMgr.m_betRate[j]*0.01
			else

				local isAdd = true

				for n=1, #self.m_totalScore do
					if self.m_cellScore[i] * HoxDataMgr.m_betRate[j] == self.m_totalScore[n] then
						isAdd = false
						break
					end
				end

				if isAdd then
					self.m_totalScore[#self.m_totalScore + 1] = self.m_cellScore[i] * HoxDataMgr.m_betRate[j]*0.01
				end
			end
			
		end
	end

	table.sort(self.m_totalScore, function(a, b)
		return a < b
	end)

end

function CattleGameController:getTotalScoreType()
	return self.m_totalScore
end

function CattleGameController:getChoumaImgNameIndex(_score)
   local imgName = "ps_cm_1.png"
   local totalScore = {1,5,10,50,100,500} 
   	for i=1, #totalScore do
	   	if totalScore[i] == _score then
	   		imgName = HoxDataMgr.BetChoumaImg[i]
	   		break
	   	end
   	end 
   return imgName
end

function CattleGameController:getFlyChoumaImgNameIndex(_score)
   local imgName = "ps_cm_yuan1.png"
   local totalScore = self:getTotalScoreType()

   local totalScore = {1,5,10,50,100,500} 
   	for i=1, #totalScore do
	   	if totalScore[i] == _score then
	   		imgName = HoxDataMgr.FlyChoumaImg[i]
	   		break
	   	end
   	end 
   return imgName
end

--[[
function CattleGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function CattleGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]

function CattleGameController:getGameState()
	return self.m_gameState
end

function CattleGameController:setGameState( _gameState )
	self.m_gameState = _gameState
end

function CattleGameController:setCowRoomController( _roomController )
	self.m_roomController = _roomController
end

function CattleGameController:getCowRoomController()
	return self.m_roomController 
end

function CattleGameController:getRoomData()
	return self.m_roomData
end

function CattleGameController:setRoomData( _roomData )
	self.m_roomData = _roomData
end

function CattleGameController:addUserWinLostTimesData( _data )
	local notContain = {}
	local contian = false
	for i=1,#_data.m_timesData do
		contian = false
		for k=1,#self.m_userwinlosttimes do
			if self.m_userwinlosttimes[k].m_userId == _data.m_timesData[i].m_userId then
				contian = true
				self.m_userwinlosttimes[k].m_winTimes = _data.m_timesData[i].m_winTimes
				self.m_userwinlosttimes[k].m_lostTimes = _data.m_timesData[i].m_lostTimes
			end
		end 
		if not contian then
			notContain[#notContain+1] = _data.m_timesData[i]
		end
	end
	for i=1,#notContain do
		self.m_userwinlosttimes[#self.m_userwinlosttimes+1] = notContain[i]
	end
end
function CattleGameController:getUserWinLostTimesInfo( _userid )
	--dump(self.m_userwinlosttimes,"self.m_userwinlosttimes")
	for i=1,#self.m_userwinlosttimes do
		print("self.m_userwinlosttimes[i].m_userId= ",self.m_userwinlosttimes[i].m_userId)
		if tonumber(self.m_userwinlosttimes[i].m_userId) == _userid then
			return self.m_userwinlosttimes[i]
		end
	end
end

function CattleGameController:delUserWinLostTimesInfo( _userid )
	for i=1,#self.m_userwinlosttimes do
		if self.m_userwinlosttimes[i].m_userId == _userid then
			table.remove(self.m_userwinlosttimes,i)
			return
		end
	end
end

function CattleGameController:getArrUserData()
	return self.m_arrUserData
end

function CattleGameController:setArrUserData( _arrUserData )
	self.m_arrUserData = _arrUserData
		-- 找到非庄家
	local nozhuang = {}
	for i=1,#_arrUserData do
		if self:isInBankerArray( _arrUserData[i].m_chairId ) == false then
			nozhuang[#nozhuang+1] = _arrUserData[i]
		end
	end
	-- 排序
	table.sort( nozhuang , function ( a,b )
		return a.m_chairId < b.m_chairId
	end )
	local _userData = {}
	-- 判断是否有在self.m_bankerArray 和nozhuang 都存在的玩家
	for i=1,#self.m_bankerArray do
		for k=1,#nozhuang do
			if self.m_bankerArray[i].m_chairId == nozhuang[k].m_chairId then
				table.remove(nozhuang,k)
				break
			end
		end
	end

	for i=1,#self.m_bankerArray do
		_userData[#_userData+1] = self:getGamePlayerInfo( self.m_bankerArray[i].m_chairId )-- self.m_bankerArray[i]
	end
	for i=1,#nozhuang do
		_userData[#_userData+1] = nozhuang[i]
	end

	self.m_arrUserData = _userData
	if self.gameScene ~= nil then
		self.gameScene:updateUserDataNty( self.m_arrUserData,#nozhuang )
	end
end

function CattleGameController:updateArrUserData( _arrUserData,_isadd )
	local contain = false
	for i=1,#self.m_arrUserData do
		if self.m_arrUserData[i].m_chairId == _arrUserData.m_chairId then
			contain = true
			if _isadd then -- 不用加
				
			else -- 移除
				table.remove(self.m_arrUserData,i)
				break
			end
		end
	end
	if contain == false and _isadd then
		self.m_arrUserData[#self.m_arrUserData + 1] = _arrUserData
	end
	self:setArrUserData( self.m_arrUserData )
end

function CattleGameController:updateArrUserDataScore( _charid,score )
	for i=1,#self.m_arrUserData do
		if self.m_arrUserData[i].m_chairId == _charid then
			self.m_arrUserData[i].m_score = score
			break
		end
	end
end

function CattleGameController:getSelfChairId()
	return self.m_selfChairId
end

function CattleGameController:setSelfChairId( _selfChairId )
	self.m_selfChairId = _selfChairId
end

function CattleGameController:getBankerArray()
	return self.m_bankerArray
end

function CattleGameController:setBankerArray( _bankerArray )
	local oldresult =  self:isInBankerArray()
	self.m_bankerArray = _bankerArray
	self:setArrUserData(self:getArrUserData())
	local nowresult = self:isInBankerArray()
	if nowresult then
		if self.gameScene and self.m_sceneInit then
			self:applyBankerTimesReq()
		end
	end
	if self.gameScene and self.m_sceneInit then
		if oldresult then
			if not nowresult then -- 下庄成功
				self.gameScene:showCowGameTipsNode("您已经下庄")
				self.gameScene:updateBankInfoListState()
			end
		else
			if nowresult then -- 上庄成功
				self.gameScene:showCowGameTipsNode("上庄成功")
			end
		end
	end
end

function CattleGameController:getApplyArray()
	return self.m_applyArray
end

function CattleGameController:setApplyArray( _applyArray )
	self.m_applyArray = _applyArray
end

function CattleGameController:getArrAddScore()
	return self.m_arrAddScore 
end

function CattleGameController:setArrAddScore( _arrAddScore )
	self.m_arrAddScore = _arrAddScore
end

function CattleGameController:setRecordArray ( _recordArray )
	self.m_recordArray = _recordArray
end

function CattleGameController:getRecordArray()
	return self.m_recordArray
end

function CattleGameController:getAllGameScore()
	return self.m_allGameScore
end

function CattleGameController:getUserGameResult(_charid)
	for i=1, #self.m_allGameScore do
		if _charid == self.m_allGameScore[i].m_chairId then
			return self.m_allGameScore[i].m_score
		end
	end

	return nil
end

function CattleGameController:getSelfJieSuanGameScore()
	for i=1,#self.m_allGameScore do
		if self.m_allGameScore[i].m_chairId == self:getSelfChairId() then
			return self.m_allGameScore[i].m_score
		end
	end
	return nil
end

function CattleGameController:setAllGameScore( _allGameScore )
	if _allGameScore == nil then self.m_allGameScore = {}  return end
	self.m_allGameScore = _allGameScore
end

function CattleGameController:setSelfGameScore( _selfGameScore )
	self.m_selfGameScore = _selfGameScore
end

function CattleGameController:getSelfGameScore()
	return self.m_selfGameScore
end

function CattleGameController:getGameTimes()
	return self.m_gameTimes
end

function CattleGameController:setGameTimes( _gameTimes )
	self.m_gameTimes = _gameTimes
end

function CattleGameController:getJokerCardData()
	return self.m_jokerCardData
end

function CattleGameController:setJokerCardData( _jokerCardData )
	self.m_jokerCardData = _jokerCardData
end

function CattleGameController:getCardArray()
	return self.m_cardArray
end

function CattleGameController:setCardArray( _cardArray )
	self.m_cardArray = _cardArray
end

function CattleGameController:getBankerRandCard()
	return self.m_bankerRandCard
end

function CattleGameController:setBankerRandCard( _bankerRandCard )
	self.m_bankerRandCard = _bankerRandCard
end

function CattleGameController:getApplyScore()
	return self.m_applyScore
end
-- 总金额
function CattleGameController:getAllBankAllScore()
	-- 获取每个庄家的金币
	local allbanker = self:getBankerArray()
	local allScore = 0
	for i=1,#allbanker do
		local bankerInfo = self:getGamePlayerInfo(allbanker[i].m_chairId)
		if bankerInfo then
			allScore = allScore + bankerInfo.m_score
		end     
	end
	return allScore --self.m_applyScore * table.nums(self:getBankerArray())
end

function CattleGameController:getAllBankScore()
	return self.m_applyScore * table.nums(self:getBankerArray())
end
function CattleGameController:setAddAllScore( _addScore )
	self.m_addAllScore = _addScore
end

function CattleGameController:getAddAllScore()
	return self.m_addAllScore
end

function CattleGameController:samllChipScore()
	return HoxDataMgr.m_betRate[1] * self:getCellScore()
end
function CattleGameController:setApplyScore( _applyScore )
	self.m_applyScore = _applyScore
end

function CattleGameController:getMaxAddScore()
	return self.m_maxAddScore
end

function CattleGameController:setMaxAddScore( _maxAddScore )
	self.m_maxAddScore = _maxAddScore
end

function CattleGameController:getTimeRemaining()
	return  self.m_timeRemaining
end

function CattleGameController:setTimeRemaining( _timeRemaining )
	self.m_timeRemaining = _timeRemaining
end

function CattleGameController:setCurCancelBanker(_curCancelBanker)
	self.m_curCancelBanker = _curCancelBanker
end

function CattleGameController:getCurCancelBanker()
	return self.m_curCancelBanker
end


function CattleGameController:isInBankerArray( _charid )
	local charid = _charid or self:getSelfChairId()
	for i=1,#self.m_bankerArray do
		if charid == self.m_bankerArray[i].m_chairId then
			return true
		end
	end
	return false
end

function CattleGameController:isInApplyArray( _charid )
	local charid = _charid or self:getSelfChairId()
	for i=1,#self.m_applyArray do
		if charid == self.m_applyArray[i] then
			return true
		end
	end
	return false
end

function CattleGameController:setExitGame( _exitGame )
	self.m_exitGame = _exitGame
end


function CattleGameController:setSelfAddScore( _selfAddScore )
	self.m_selfAddScore = _selfAddScore
end

function CattleGameController:getSelfAddScore()
	return self.m_selfAddScore
end
-- 返回游戏类型
function CattleGameController:getRoomType()
	local id = self.m_gameAtomTypeId
	local data = RoomData:getRoomDataById( id )
	if not data or not data.gameKindType then return CowRoomDef.CRAZYGameKindID end
	return data.gameKindType
end

-- 刚进场景是用到，后面用服务器数据刷新
function CattleGameController:getRoomCellScore()
	local cellScore = {}
	local roomdata = RoomData:getRoomDataById( self:getGameAtomTypeId())
	if roomdata then
		local josn = json.decode(roomdata.roomMinScore)
		-- dump(josn)
        for k,v in pairs(josn) do
            cellScore[#cellScore + 1] = k
        end
	end
	return cellScore
end

--获取是否要显示胜负结算结果，（自己庄家：有人下注就显示，自己闲家：下注就显示）
function CattleGameController:getHaveShowShengFuResult()
	if self:isInBankerArray() then -- 自己是庄家
		if self:getAddAllScore() > 0 then -- 所有玩家下注
			return true
		end
	else --自己是闲家
		if self:getSelfAddScore() >0 then
			return true
		end
	end
	return false
end

function CattleGameController:canApplyBank()
	local selfinfo = self:getGameSelfInfo()
	if selfinfo and self.m_applyScore > selfinfo.m_score then
		return false
	end
	return true
end

function CattleGameController:isBankEmpty()
	return  ( table.nums(self.m_applyArray) ==  0 and table.nums(self.m_bankerArray) == 0 ) -- and true or false
end

--------------------------- 查找玩家信息 -------------------------------------
function CattleGameController:getGamePlayerInfo( _charid )
	for i=1,#self.m_arrUserData do
		if self.m_arrUserData[i].m_chairId == _charid then
			return self.m_arrUserData[i]
		end
	end
	return nil
end

function CattleGameController:getGameSelfInfo()
	for i=1,#self.m_arrUserData do
		if self.m_arrUserData[i].m_chairId == self:getSelfChairId() then
			return self.m_arrUserData[i]
		end
	end
	return nil
end

function CattleGameController:getBankPlayerInfo( _charid )
	for i=1,#self.m_bankerArray do
		if _charid == self.m_bankerArray[i].m_chairId then
			return self.m_bankerArray[i]
		end
	end
	return nil
end

function CattleGameController:getGamePlayerInfoWithUserID( _userid )
	for i=1,#self.m_arrUserData do
		if self.m_arrUserData[i].m_userId == _userid then
			return self.m_arrUserData[i]
		end
	end
	return nil
end

function CattleGameController:getAllXianJiaInfo()
	local xianjia = {}
	for i=1,#self.m_arrUserData do
		if not self:isInBankerArray(self.m_arrUserData[i].m_chairId) then
			xianjia[#xianjia+1] = self.m_arrUserData[i]
		end
	end
	return xianjia
end

function CattleGameController:isSelfChair( _charid )
	return self:getSelfChairId() == _charid
end

function CattleGameController:isNewPlayerRoom() -- 判断是欢乐，疯狂 牛牛新手房

	if HoxDataMgr.FUNID.HAPPY_NEWROOM == self:getGameAtomTypeId() or HoxDataMgr.FUNID.CRAZY_NEWROOM == self:getGameAtomTypeId() then
		return true
	end
	
	return false
end
----------------------------------------------------------------------
function CattleGameController:openPokerOver( msgName,_info )
	if _info.m_area == HoxDataMgr.m_BetEraeCount - 1 then -- 最后一家(0-3)开完了
		if self.gameScene then
			self.gameScene:bankfanPai()
		end
	else --下一家
		if self.gameScene then
			self.gameScene:showXianJiaPai1()
		end
	end
end

return CattleGameController


