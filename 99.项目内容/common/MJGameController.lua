--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require("app.game.Sparrow.MjCommunal.src.MJGameMsg")
local MJHelper = require("app.game.Sparrow.MjCommunal.src.tool.MJHelper")
local scheduler = require("framework.scheduler")

MJDef = require("app.game.Sparrow.MjCommunal.src.MJDef")

--endregion
local BaseGameController = import(".BaseGameController")
local MJGameController =  class("MJGameController",function()
    return BaseGameController.new()
end) 

MJGameController.instance = nil

-- 获取房间控制器实例
function MJGameController:getInstance()
    if MJGameController.instance == nil then
        MJGameController.instance = MJGameController.new()
    end
    return MJGameController.instance
end
function MJGameController:releaseInstance()
    if MJGameController.instance then
        MJGameController.instance:onDestory()
        MJGameController.instance = nil
		g_GameController = nil
    end
end
function MJGameController:ctor()
    print("MJGameController:ctor()")
    self:myInit()
end 

function MJGameController:myInit()
  	ToolKit:addSearchPath("src/app/game/Sparrow/GeneralMJ/res") 
    	-- 加载网络协议
	Protocol.loadProtocolTemp("app.game.Sparrow.MjCommunal.src.mj.protoReg") 
	local ret =  Protocol.loadProtocolByFilePath("app.game.Sparrow.MjCommunal.src.mj.MjComTemp") -- 加载网络协议文件
	
	-- 网络协议列表
	local list = {}
	
	local proto_list = require("app.game.Sparrow.MjCommunal.src.mj.MjComTemp")
	for k,v in pairs(proto_list) do
		local s,e = string.find(k,"CS_%a2C_")
		if s then
			--print("this is to client",k)
			table.insert(list,k)
		end
	end
    self.pHandler = scheduler.scheduleUpdateGlobal(handler(self, self.runNetMsgQueue))
	self:setNetMsgCallbackByProtocolList(list, handler(self, self.netMsgHandler)) -- 添加网络消息回调
    -- 注册本地消息
	self:registerOptFunc()

    	print("DZMJMainScene:myInit")
	local DZMJGameManager = MJHelper:loadClass("app.game.Sparrow.GeneralMJ.src.model.DZMJGameManager")
	self.gameManager = DZMJGameManager.new() 				-- 游戏数据管理
	MJHelper:setGameManager( self.gameManager )

    local MJPlayerManager = MJHelper:loadClass("app.game.Sparrow.MjCommunal.src.MJRoom.MJPlayerManager")
	self.playerManager = MJPlayerManager.new()
	MJHelper:setPlayerManager(self.playerManager)
    self.gameManager:setPlayerManager(self.playerManager)

	local DZMJSoundManager = MJHelper:loadClass("app.game.Sparrow.GeneralMJ.src.controller.DZMJSoundManager")
	self.soundManager = DZMJSoundManager.new()
	MJHelper:setSoundManager( self.soundManager )

	self.msgQueue = {}
	
	self.reConnetTime = nil
	self.isAlive = true
	local DZMJHandLogic = MJHelper:loadClass("app.game.Sparrow.GeneralMJ.src.controller.DZMJHandLogic")
	self.handLogic = DZMJHandLogic.new()

    	-- 玩家数据管理器
	
    	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end
function MJGameController:sceneNetMsgHandler( __idStr, __info )
	if __idStr ~= "CS_H2C_HandleMsg_Ack" then return end
	 
	if __info.m_result == 0 then
		local gameAtomTypeId = __info.m_gameAtomTypeId
		local cmdId = __info.m_message[1].id
		local info = __info.m_message[1].msgs
		if MJBaseServer then
			MJBaseServer:sceneRpcCallBack(gameAtomTypeId,cmdId,info)
		end
		self:netMsgHandler1(cmdId, info)
	else
		LogINFO("找不到场景信息")
        local data = getErrorTipById(  __info.m_result)
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
function MJGameController:netMsgHandler1( __idStr, __info )
    if __idStr == "CS_M2C_EnterRoom_Nty" then
        self.playerManager:updatePlayerInfo(__info)
        self.playerManager:setRoomInitData(__info.m_initData)
        local gameManager = MJHelper:getGameManager()
	    if gameManager then
		    gameManager:initPlayerChair()
	    end
	    self.playerManager:setRoomState(__info.m_roomState)
	    if __info.m_roomState == 4 then
		    sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_REFRESH_START)
	    end
		
        sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, self.playerManager)
    end
end
-- 显示总结算
function MJGameController:onShowTotalResult()
	if self.gameScene.totalRoundEndLayer then
		self.gameScene.totalRoundEndLayer:setVisible(true)
	end
end

-- 游戏错误断线
function MJGameController:gameErrorDisconect()
	print("DZMJMainScene:gameErrorDisconect()")
	self:closeGameSvrConnect()
end

function MJGameController:registerOptFunc()
	local t = {
		{ name = "ready", func = handler(self, self.readyReq) },
		{ name = "operate", func = handler(self, self.operateReq) },
		{ name = "out_card", func = handler(self, self.outCardReq) },
		{ name = "shake", func = handler(self, self.shakeReq) },
		{ name = "run_msg_queue", func = handler(self, self.onMsgProcess) },
		{ name = "gold_continue", func = handler(self, self.goldContinue) },
		{ name = "clear_all_cardinfo", func = handler(self, self.clearAllCardInfo) }, 
		{ name = "show_total_result", func = handler(self, self.onShowTotalResult) },
		{ name = "guo_guan", func = handler(self, self.reqAutoOutCard) },
		{ name = "game_start", func = handler(self, self.gameStartReq) },
		{ name = "game_error_disconect", func = handler(self, self.gameErrorDisconect) },
	}

	self.optFunc = {}

	for k, v in pairs(t) do
		self.optFunc[v.name] = v.func
	end

    addMsgCallBack(self, PublicGameMsg.MSG_CCMJ_GAME_OPT, handler(self, self.onGameOpt))
end

function MJGameController:onGameOpt( _msgStr, _opt, _data )
	if self.optFunc[_opt] then
		self.optFunc[_opt](_data)
	else
		print("optfunc is nil : ", _opt)
	end
end
function MJGameController:netMsgHandler( __idStr, __info ,isNow) 
	if __idStr == "CS_G2C_Mj_ScenePlaying_Nty" then
		self.msgQueue = {}
	end
	
	if (__idStr == "CS_G2C_Mj_OperRst_Nty" and __info.m_stAction and __info.m_stAction.m_iAcCode == MJDef.OPER.CHU_PAI) then
		local curCardInfo = self.gameManager:getCardInfoByChairId(__info.m_nOperChair)
		if curCardInfo:getIndex() == 1 then
			self.gameManager:outCardTimeRecord(2)
		end
	end

	if __idStr == "CS_G2C_Mj_GameOver_Nty" then
		self.gameManager:outCardTimeRecordResult()
	end
	


	if __idStr == "CS_G2C_Mj_SceneInit_Nty" or 
		__idStr == "CS_G2C_Mj_VipTableInfo_Nty" or 
		__idStr == "CS_G2C_Mj_ScenePlaying_Nty" or 
		-- __idStr == "CS_G2C_Mj_OperTurnTo_Nty" or 
		(__idStr == "CS_G2C_Mj_OperRst_Nty" and __info.m_stAction and __info.m_stAction.m_iAcCode == MJDef.OPER.TUO_GUAN ) or -- 托管
		(__idStr == "CS_G2C_Mj_OperRst_Nty" and __info.m_stAction and __info.m_stAction.m_iAcCode == MJDef.OPER.DONG_HUA ) or -- 开始游戏返回
		-- (__idStr == "CS_G2C_Mj_OperRst_Nty" and __info.m_stAction and __info.m_stAction.m_iAcCode == MJDef.OPER.GAME_ERROR_ACK ) or -- 错误处理
		__idStr == "CS_G2C_Mj_SendHandCards_Nty" then
		self:onNetMsgQueue(__idStr, __info)
	else
		if __idStr == "CS_G2C_Mj_LastBalance_Nty" then
			local gameManager = MJHelper:getGameManager()
			gameManager:setIsFinalGame(true)
			sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_SINGLE_RESULT, { name = "update_btn_continue" })
		end
		local data = { __idStr = __idStr, __info = __info }
		table.insert(self.msgQueue, data)
	end

	-- 存协议数据
	if __idStr == "CS_G2C_Mj_SendHandCards_Nty" or
		__idStr == "CS_G2C_Mj_ScenePlaying_Nty" then
--		local recordManger = MJHelper:getRecordManager()
--		recordManger:startRecord()
	end

--	local recordManger = MJHelper:getRecordManager()
--	local data = { __idStr = __idStr, __info = __info }
--	recordManger:addToGameData(data)

	if __idStr == "CS_G2C_Mj_GameOver_Nty" then
--		local recordManger = MJHelper:getRecordManager()
--		recordManger:finishRecord()
	end
	
	if __idStr == "CS_G2C_UserLeft_Ack" then
		self:releaseInstance()
	end
end
function MJGameController:handleError(  __info ) 
 
    --ToolKit:removeLoadingDialog()
	print("请求进入场景失败!",__info.m_result) 
	 
end
 --处理成功登录游戏服
-- @params __info( table ) 登录游戏服成功消息数据
function MJGameController:ackEnterGame( __info )
	print("MJGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(self.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL,__info.m_gameAtomTypeId )  
    end 
end 

-- 准备请求 
function MJGameController:readyReq()

	local gameManager = MJHelper:getGameManager()	
	local playerManager = MJHelper:getPlayerManager()
	
	if not ConnectManager:isConnectGameSvr( self:getProtocolId() ) then
		if playerManager:isVipRoom() then
			gameManager:setGameState(3)
		end	
		ConnectManager:reconnect()
		return 
	end
	local gameType = playerManager:getGameAtomTypeId()
	local MJCreateRoomData = MJHelper:loadClass("app.game.Sparrow.MjCommunal.src.MJRoom.MJCreateRoomData")
	if MJCreateRoomData:IsDaibiRoomById(gameType) then
		sendMsg(PublicGameMsg.MSG_CCMJ_VIP_ROOM_OPT, "continue_db_room")
	else	
		if playerManager:isVipRoom() then
			gameManager:setGameState(3)
			sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		end
		self:send2GameServer("CS_C2G_Mj_Ready_Req", {})
	end
end

function MJGameController:getProtocolId()
    return self.m_gameAtomTypeId
end
-- 操作请求
function MJGameController:operateReq( data )
	-- 有玩家掉线不能操作
	-- local playerManager = MJHelper:getPlayerManager(true)
	-- if playerManager:isVipRoom() then
	-- 	for k, playerInfo in pairs(playerManager:getPlayerInfos()) do
	-- 		if playerInfo:isUnlinkState() then
 --        		return
	-- 		end
	-- 	end
	-- end

	if self.gameManager:isSendOptMsg() then
		return
	else
		self.gameManager:setSendOptMsg(true)
		local t = {
			{ data.m_iAcCode, 0, data.m_iAcCard }
		}
		self:send2GameServer("CS_C2G_Mj_Oper_Req", t)
		performWithDelay(self.gameScene,function ()
			self.gameManager:setSendOptMsg(false)
		end, 2)
	end
end
function MJGameController:send2GameServer( __cmdId, __dataTable)
	ConnectManager:send2GameServer(self:getProtocolId(), __cmdId, __dataTable)
end
-- 出牌请求
function MJGameController:outCardReq( cardItem )
	local card = cardItem:getCardData():getCard()
	-- print("MJGameController:outCardReq")
	-- 消息阻塞中
	local gameManager = MJHelper:getGameManager(true)
	local later = gameManager:getLaterProcessByName(MJDef.eAnimation.BEGIN_FA_PAI .. "1")
	if later and later.isLater then
		sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
		print("[MJWarnning] fa pai animation, can not out card")
		return
	end
	-- print("gameManager:getLaterProcess()", gameManager:getLaterProcess())
    -- if gameManager:getLaterProcess() then
    -- 	sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
    --     return
    -- end

	-- 当前有操作提示不能出牌
	local optTips = self.gameManager:getOperateTips()
	if #optTips > 0 then
		sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
		print("[MJWarnning] state in operate tips, can not out card")
		return
	end

	-- 不是当前玩家不能出牌
	local curOptChairId = gameManager:getCurOperator()
	local cardInfo = gameManager:getCardInfoByIndex(1)
	if cardInfo:getChairId() ~= curOptChairId then
		sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
		print("[MJWarnning] is not turner, can not out card")
        return
	end

	-- 有玩家掉线不能出牌
	-- local playerManager = MJHelper:getPlayerManager(true)
	-- if playerManager:isVipRoom() then
	-- 	for k, playerInfo in pairs(playerManager:getPlayerInfos()) do
	-- 		if playerInfo:isUnlinkState() then
	-- 			sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
 --        		return
	-- 		end
	-- 	end
	-- end

	local cardInfo, data = gameManager:getCurOutCardData()
	if cardInfo and cardInfo:getIndex() == 1 then
		sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
		print("[MJWarnning] out card done.")
 		return 		
	end
	-- print("not self.gameManager:isSendOutCardMsg()", not self.gameManager:isSendOutCardMsg())
	if self.gameManager:isSendOutCardMsg() then
		print("[MJWarnning] is sending out card msg, can not out card")
		-- sendMsg(PublicGameMsg.MSG_CCMJ_OUT_CARD_FAIL)
		return 
	else
		local card = tonumber(card)
		local data = {
			{ MJDef.OPER.CHU_PAI, 0, { card } }
		}
		-- dump(data)
		self:send2GameServer("CS_C2G_Mj_Oper_Req", data)
		-- self.gameManager:outCardTimeRecord(1)

		self.gameManager:setSendOutCardMsg(true)
		MJHelper:setOutCard(cardItem:getCardData())

		performWithDelay(self.gameScene,function ()
			local gameManager = MJHelper:getGameManager(true)
			if gameManager then
				gameManager:setSendOutCardMsg(false)
			end
		end, 2)

		sendMsg(PublicGameMsg.MSG_CCMJ_SHOW_OUT_CARD_ANI_PRE, cardItem, 1)
	end
end

-- 开始游戏请求
function MJGameController:gameStartReq(nType)
	if ConnectManager:isConnectGameSvr( self:getProtocolId() ) then
		local t = {
			{ MJDef.OPER.DONG_HUA, 0, {nType} }
		}
		self:send2GameServer("CS_C2G_Mj_Oper_Req", t)
		self.gameManager:setSendGameStartMsg(true)

		performWithDelay(self.gameScene,function ()
			if self.gameManager:isSendGameStartMsg() then
				self:gameStartReq(nType)
			end
		end, 2)
	end
end

function MJGameController:doQueue()
	-- body
	if self.isPlay then
	else
		local info = self.msg_queue[1]
		if info then
			table.remove(self.msg_queue,1)
			self.isPlay = true
			performWithDelay(self.gameScene,function ()
				-- body
				self.isPlay = false
				self:doQueue()
			end, 3)
			self:netMsgHandler(info.str,info.param,true)
		end
	end

end 

function MJGameController:onMsgProcess(data)
	self.gameManager:setLaterProcess(data)
end

function MJGameController:runNetMsgQueue(time)
	if self.gameManager and not self.gameManager:getLaterProcess(time) then
		local msg = self.msgQueue[1]
		if msg then
			table.remove(self.msgQueue, 1)
			self:onNetMsgQueue(msg.__idStr, msg.__info)
		end
	end
end

-- 网络消息
function MJGameController:onNetMsgQueue( __idStr, __info )
	-- dump(__info, __idStr, 9)
	-- 初始场景
	if __idStr == "CS_G2C_Mj_SceneInit_Nty" then
		
		local gameManager = MJHelper:getGameManager()
		gameManager:setStartGame(true)
		self:startGame1()
		local playerManager = MJHelper:getPlayerManager()
		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		--sendMsg(PublicGameMsg.MSG_CCMJ_GAME_START)
		
		
	-- 游戏中场景
	elseif __idStr == "CS_G2C_Mj_ScenePlaying_Nty" then
		local gameManager = MJHelper:getGameManager()
		if not gameManager:isStartGame() then
			gameManager:setStartGame(true)
		end
		sendMsg(PublicGameMsg.MSG_CCMJ_GAME_START)
		
		self.gameManager:updateFromServ(__info)
		self:startGame1()
		local playerManager = MJHelper:getPlayerManager()
		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		

		sendMsg(PublicGameMsg.MSG_CCMJ_GAME_OPT, "game_start", 2)
	-- 游戏线束场景
	elseif __idStr == "CS_G2C_Mj_SceneOver_Nty" then

	-- 广播准备给其他玩家
	elseif __idStr == "CS_G2C_Mj_Ready_Nty" then
		print("xxxxx ready:",__info)
		local c = __info.m_nReadChair
		local playerManager = MJHelper:getPlayerManager()
		local player = playerManager:getPlayerInfoByCid(c)
		if player then
			player:setReady(1)
			sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		end
		--self.gameManager:readyNty(__info)

	-- 发手牌
	elseif __idStr == "CS_G2C_Mj_SendHandCards_Nty" then
		sendMsg(PublicGameMsg.MSG_CCMJ_GAME_START)
		self.gameManager:clearCardInfos()
		self.gameManager:sendHandCards(__info)
		local playerManager = MJHelper:getPlayerManager()
		self.gameManager:setStartGame(true)
		self.gameManager:setGameState(1)
		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
	-- 可操作通知
	elseif __idStr == "CS_G2C_Mj_Oper_Nty" then
		self.gameManager:operateTips(__info)

	-- 有玩家可操作通知
	elseif __idStr == "CS_G2C_Mj_OtherOper_Nty" then
		self.gameManager:operateNty(__info)

	-- 操作完成通知
	elseif __idStr == "CS_G2C_Mj_OperRst_Nty" then
		self.gameManager:operateResult(__info)

	-- 玩家状态变化通知
	elseif __idStr == "CS_G2C_Mj_StateChange_Nty" then
		self.gameManager:playerStateChange(__info)
		
	-- 查听
	elseif __idStr == "CS_G2C_Mj_CheckListen_Nty" then
		self.gameManager:chaTingTips(__info)

	-- 震一下
	elseif __idStr == "CS_G2C_Mj_Shake_Nty" then
		
		local myChair = self.gameManager:IndexToChairId(1)
		if __info.m_nObjectChair==myChair then
			self:mjVibrate()
		end
		if __info.m_nOperChair == myChair then
			local playerManager = MJHelper:getPlayerManager(true)
			local playerInfo = playerManager:getPlayerInfoByCid(__info.m_nObjectChair)
			playerInfo:setShakeCD(__info.m_nCDtime)
			sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		end
		
	-- 牌局录像
	elseif __idStr == "CS_G2C_Mj_RoundRecord_Nty" then
        local playerManager = MJHelper:getPlayerManager()
		local gameManager = MJHelper:getGameManager()
		local id = __info.m_strReocrdId
        local VideoData = MJHelper:loadClass("app.game.common.record.VideoData")
        local video = VideoData:new()
        video:init("mj")
        local param = {}
        param.roomId = playerManager:getRoomId()
        param.time = os.time()
		
		param.m_gameAtomTypeId = playerManager:getGameAtomTypeId()
		local initData = playerManager:getRoomInitData() or {}
		param.maxPlayerCount = initData.m_nPlayerCount
		local myChair = self.gameManager:IndexToChairId(1)
		
		--print("m_strInfo:",__info.m_strInfo)
		--print("m_strRecord:",__info.m_strRecord)
		--print("m_strBalance:",__info.m_strBalance)
		local hf = 0
		local gf = 0
		local list = string.split(__info.m_strInfo, ";")
		for k,v in pairs(list) do
			local t_oper = tonumber("0x"..string.sub(v,1,2))
			if t_oper == MJDef.OPER.MJ_HU_FEN then
				local c = tonumber("0x"..string.sub(v,3,4))
				if c==myChair then
					hf = tonumber(string.sub(v,5,#v))
				end
			end
			
			if t_oper == MJDef.OPER.MJ_GANG_FEN then
				local c = tonumber("0x"..string.sub(v,3,4))
				if c==myChair then
					gf = tonumber(string.sub(v,5,#v))
				end
			end
			
			if t_oper == MJDef.OPER.MJ_VIP_ROUND then
				local c = tonumber("0x"..string.sub(v,7,8))
				param.curRound = c
			end
		end
		param.score = hf + gf
		local str = __info.m_strInfo..__info.m_strRecord..__info.m_strBalance
        video:writeVideo(tostring(id),param,str)
	-- 结算通知
	elseif __idStr == "CS_G2C_Mj_GameOver_Nty" then
		local gameManager = MJHelper:getGameManager()
		local playerManager = MJHelper:getPlayerManager()
		--if playerManager:isFreeRoom() then
			gameManager:setGameState(2)
		--end
  		self.gameManager:singleResultNty(__info)
		self.gameScene:createOneRoundEnd()
  		self.gameScene.oneRoundEndLayer:setVisible(true)
  		self.gameScene.oneRoundEndLayer:setData(__info.m_stBalance)
		ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
		
		
		sendMsg(PublicGameMsg.MSG_CCMJ_GAME_OVER_NTF)
  		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_OPT_CLOCK, "stop")
    	g_GameMusicUtil:stopBGMusic()
		
		local playerManager = MJHelper:getPlayerManager()
		if playerManager:isVipRoom() then
			local list = playerManager:getPlayerInfos()
			for k,v in pairs(list) do
				v:setReady(0)
			end
		end
	-- 总结算界面
	elseif __idStr == "CS_G2C_Mj_LastBalance_Nty" then
		self:createTotalRoundEnd()
		
		local gameManager = MJHelper:getGameManager(true)
		gameManager:setGameState(2)
		self.gameScene.totalRoundEndLayer:setVisible(false)
		self.gameScene.totalRoundEndLayer:setData(__info)
		
		performWithDelay(self.gameScene.totalRoundEndLayer,function()
			self.gameScene.totalRoundEndLayer:setVisible(true)
		end,2)
		sendMsg(PublicGameMsg.MSG_CCMJ_GAME_OVER_NTF)
	-- 牌友房桌子信息
	elseif __idStr == "CS_G2C_Mj_VipTableInfo_Nty" then
		-- 设置局数
		self:setRoundInfo(__info)

		-- 设置分数
		local playerManager = MJHelper:getPlayerManager()

		local myShakeCd = 0
		local myAid = Player:getAccountID()
		local myPlayerInfo = playerManager:getPlayerInfoByAid(myAid)
		if myPlayerInfo then
			local myChairId = myPlayerInfo:getChairId()
			myShakeCd = __info.m_stPlayerStatus[myChairId + 1].m_nCDtime or myShakeCd
		end

		for chairId = 0, 3 do
			local playerInfo = playerManager:getPlayerInfoByCid(chairId)
			if playerInfo then
				local v = __info.m_vstLastBalance[chairId + 1]
				if v then
					--playerInfo:setScore(v.m_nZhScore)
				end
				local v = __info.m_stPlayerStatus[chairId + 1]
				if v then
					playerInfo:setState(v.m_nStatus)
					if playerInfo:isLeaveState() then
						playerInfo:setShakeCD(myShakeCd)
					end
				end
			end
		end

        sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_PLAYERINFO, playerManager)
		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_TABLEINFO)

	-- 指示灯
	elseif __idStr == "CS_G2C_Mj_OperTurnTo_Nty" then
		local gameManager = MJHelper:getGameManager(true)
		gameManager:updateOperTurn(__info)
	end


	--校验数据
	local ip = GlobalConf.LOGIN_SERVER_IP
	local s,j  = string.find(ip,"192.168")
	if not s and device.platform ~= "windows" then return end
	self.handLogic:netMsgHandler(__idStr,__info)
end

-- 设置局数
function MJGameController:setRoundInfo( __info )
	-- dump(__info)
	local playerManager = MJHelper:getPlayerManager(true)
	local MJConf = MJHelper:getConfig()
	local roundType = playerManager:getRoundUnit()
	if roundType == 1 then
		self.gameManager:setPlayCount(__info.m_stRoundInfo.m_nCurRound)
	else
		self.gameManager:setPlayCount(__info.m_stRoundInfo.m_nPlayCount)
	end
	playerManager:setRoundNum(__info.m_stRoundInfo.m_nTolotRound)
end

function MJGameController:mjVibrate()
	local i = 0
	local function b()
			device.vibrate()
			i = i + 1
			if i<4 then
					scheduler.performWithDelayGlobal(b,1)
			end
	end
	b()
end

function MJGameController:startGame1()
	local gameManager = MJHelper:getGameManager()	
	gameManager:setGameState(1)
	-- self:reqAutoOutCard()
end

function MJGameController:reqAutoOutCard()
	local gameManager = MJHelper:getGameManager()
	local v = 0
	
	if gameManager:isAutoOutCard() then
		v=1
	end
	
	local t = {
		{ MJDef.OPER.TUO_GUAN, 0, {v} }
	}
	self:send2GameServer("CS_C2G_Mj_Oper_Req", t)
end 

-- 清楚所有数据
function MJGameController:clearAllCardInfo()
	self.gameManager:clearCardInfos()

	local playerManager = MJHelper:getPlayerManager()
	for i = 1, 4 do
		local cardInfo = self.gameManager:getCardInfoByIndex(i)
		sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_HANDCARD, cardInfo)

		if playerManager:isFreeRoom() then
			-- 清除其他玩家数据
			local chairId = cardInfo:getChairId()
			local playerInfo = playerManager:getPlayerInfoByCid(chairId)
			if playerInfo then
				local accountId = playerInfo:getAccountId()
				if accountId ~= Player:getAccountID() then
					playerManager:removePlayerInfoByAid(accountId)
				end
			end
		end
	end
	-- 隐藏查听
	sendMsg(PublicGameMsg.MSG_CCMJ_SHOW_CHATING_BTN, false)

	-- 剩余牌数
	self.gameManager:setLeftCardCount(0)
	sendMsg(PublicGameMsg.MSG_CCMJ_UPDATE_LEFT_CARD_COUNT)
end

-- 准备请求 
function MJGameController:goldContinue()
	print("goldContinue")
	local playerManager = MJHelper:getPlayerManager()
	if playerManager then
		local gameManager = MJHelper:getGameManager()
		gameManager:setStartGame(false)
		local gameAtomTypeId = playerManager:getGameAtomTypeId()
		if not gameAtomTypeId then
			return 
		end
		local param=
		{
			id = nil,
			req = "CS_C2H_EnterScene_Req",
			ack = "CS_H2C_EnterScene_Ack",
			dataTable = {gameAtomTypeId, 0, 0, 0, 0},
		}
		local function callback(param,body)
			MJHelper:getUIHelper():removeWaitLayer()
            if not param then return end
			if param and param.m_ret==0 then
				local playerManager = MJHelper:getPlayerManager()
				playerManager:setGameAtomTypeId(param.m_gameAtomTypeId)
				playerManager:setVipRoom(false)
				--sendMsg(PublicGameMsg.MSG_CCMJ_VIP_ROOM_OPT, "enter_room", 1)
				local info = 
				{
					id = param.m_gameAtomTypeId,
					req = "CS_C2M_EnterRoom_Req",
					ack = "CS_M2C_EnterRoom_Ack",
					dataTable = {1,0}
				}
				local function enter_room_callback(param,body)
					param = param or {m_ret=0}
					if param.m_ret == 0 then
						print("success enter gold room")
						local gameManager = MJHelper:getGameManager()
						if  gameManager then
							gameManager:setGameState(0)
						end
						if self.gameScene.oneRoundEndLayer then
							self.gameScene.oneRoundEndLayer:setVisible(false)
						end	
					else
						--不能进入房间，则退出场景返还金币
						local gameAtomTypeId = playerManager:getGameAtomTypeId()
						playerManager:setGameAtomTypeId(nil)
						ConnectManager:send2SceneServer(gameAtomTypeId, "CS_C2M_ExitScene_Req", {} )
					end
				end 
				MJBaseServer:sceneRpcCall(info,enter_room_callback)
			else
				if param.m_ret == -705 then
					--gold not enough
					local MJVipVideoManagerDlg =  MJHelper:loadClass("app.game.Sparrow.MjCommunal.src.MJRoom.MJGoldTipDlg")
					local Dlg = MJVipVideoManagerDlg.new()
					Dlg:showDialog()
				else	
					ToolKit:showErrorTip( param.m_ret )
				end
				
			end
		end
		MJHelper:getUIHelper():addWaitLayer(10)
		MJBaseServer:sceneRpcCall(param,callback)
	end
end


-- 准备请求 
function MJGameController:shakeReq(chairId)
	self:send2GameServer("CS_C2G_Mj_Shake_Req", {})
end

function MJGameController:onDestory()
	print("---------MJGameController:onDestory--------------")
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	
	if self.pHandler then
		scheduler.unscheduleGlobal(self.pHandler)
		self.pHandler = nil
	end

    -- 注销游戏操作消息
    removeMsgCallBack(self, PublicGameMsg.MSG_CCMJ_GAME_OPT)
end
return MJGameController