--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--
-- Author: chenzhanming
-- Date: 2018-10-24 10:57:38
-- 龙虎斗游戏控制器
local LhdzDataMgr = require("src.app.game.DragonVsTiger.src.manager.LhdzDataMgr") 
local Lhdz_Events = require("src.app.game.DragonVsTiger.src.manager.Lhdz_Events")
local Lhdz_Const = require("src.app.game.DragonVsTiger.src.scene.Lhdz_Const")
local CBetManager = require("src.app.game.common.util.CBetManager")
local  scheduler              =  require("framework.scheduler")  
local DlgAlert = require("src.app.hall.base.ui.MessageBox")

local BaseGameController = import(".BaseGameController")

local DVTGameController = class("DVTGameController",function()
    return BaseGameController.new()
end)

DVTGameController.instance = nil

-- 获取推饼游戏控制器实例
function DVTGameController:getInstance()
	if DVTGameController.instance == nil then
		DVTGameController.instance = DVTGameController.new()
	end
    return DVTGameController.instance
end

function DVTGameController:releaseInstance()
    if DVTGameController.instance then
		DVTGameController.instance:onDestory()
        DVTGameController.instance = nil
		g_GameController = nil
    end
end

function DVTGameController:ctor()
    self.m_dSchedulers = {}
	 ToolKit:addSearchPath("src/app/game/DragonVsTiger/src") 
    ToolKit:addSearchPath("src/app/game/DragonVsTiger/src/protocol")
    ToolKit:addSearchPath("src/app/game/DragonVsTiger/res")
    -- 加载龙虎斗协议
  	Protocol.loadProtocolTemp("dragonVsTiger.protoReg")
	-- 初始化龙虎斗数据
	--self:initDragonVsTigerData()
	-- 注册协议
	self:initCallBackFuncList()
	self:registNetMassege()	
end

--  初始化推饼数据
function DVTGameController:initDragonVsTigerData()
	print("DVTGameController:initDragonVsTigerData()")
              --场景节点 
end

-- 注册网络消息
function DVTGameController:registNetMassege()
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 生成消息和对应处理函数的映射关系
function DVTGameController:initCallBackFuncList()
	self.m_callBackFuncList = {}
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_PlayerShow_Nty"]           = handler(self, self.ackDVSTPlayerShow )         -- 分布在两侧的， 每局结束时如果有变化刷新一遍 
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_GameState_Nty"]            = handler(self, self.notifyDVSTGameState)        -- 游戏信息初始化
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_Bet_Ack"]                  = handler(self, self.ackDVSTBet)                 -- 下注结果，自己下注各区域加减走这个协议
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_EachUserBet_Nty"]          = handler(self, self.notifyDVSTEachUserBet)      -- 下注飞筹码效果, 各区域加金币走这个协议  
    
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_PlayerOnlineList_Ack"]     = handler(self, self.ackDVSTPlayerOnlineList)    -- 在线玩家列表
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_Background_Ack"]           = handler(self, self.ackDragonVsTigerBackground) -- 切换后台
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_ForceExit_Ack"]            = handler(self, self.ackDragonVsTigerForceExit ) -- 玩家退出
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_Exit_Nty"]                 = handler(self, self.ackSceneMessage )   -- 玩家异常退出
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_WaitNext_Nty"]                 = handler(self, self.gameWait )   -- 等待状态
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_StartBet_Nty"]                 = handler(self, self.gameStart )   -- 开始状态
    self.m_callBackFuncList["CS_M2C_DragonVsTiger_GameBalance_Nty"]          = handler(self, self.gameResult)      -- 结算状态
     self.m_callBackFuncList["CS_M2C_DragonVsTiger_Continue_Ack"]          = handler(self, self.ackDVSTBet)      -- 续压
      self.m_callBackFuncList["CS_M2C_DragonVsTiger_UpdatePlayerNum_Nty"]          = handler(self, self.gameOnlineNum)      -- 结算状态
    
    
end

-- 清理所有游戏数据
function DVTGameController:clearAllData()
    self.myServerChipinCoin = {}     --我的下注(服务端的值)
    self.myClientChipinCoin = {}     --我的下注(客户端的值)
    self.totalServerChipinCoin = {}  --总下注(服务端的值)
    self.totalCentChipinCoin = {}    --总下注(客户端的值)
    self.m_myChipInNumList = {}      --我的下注列表
    for i=1,3 do
    	self.myServerChipinCoin[i] = 0
    	self.myClientChipinCoin[i] = 0
    	self.totalServerChipinCoin[i] = 0
    	self.totalCentChipinCoin[i] = 0
    end
    for i=1,3 do
		self.m_myChipInNumList[i] = {}
    end
    self.m_peopleCnt = 0             -- 房间人数
    self.areaBets = {}       
    for i=1,3 do
		self.areaBets[i] = {}
    end 
    self.m_vecBallHistory = {}
end

-- 销毁龙虎斗游戏管理器
function DVTGameController:onDestory()
	print("----------DVTGameController:onDestory begin--------------")
	
	self:clearAllData()
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
   
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
 
	m_callBackFuncList = {}
	--self:destroyCountDownShedule()
	self:onBaseDestory()
	print("----------DVTGameController:onDestory end--------------")
end

-- 向游戏服发消息
-- @params      __cmdId( number )    消息命令
-- @params     __dataTable( table )  消息结构体 
function  DVTGameController:send2GameServer4DragonVsTiger( __cmdId, __dataTable)
     ConnectManager:send2SceneServer( self.m_gameAtomTypeId , __cmdId , __dataTable )
end

function DVTGameController:handleError(  __info )
  print("DragonVsTigerRoomController:onEnterScene1111111111111111111")
	if self:isDVSTGameModule( __info.m_gameAtomTypeId ) then   
        --ToolKit:removeLoadingDialog()
		print("请求进入场景失败!",__info.m_result)
        if __info.m_result > DragonVsTigerGlobal.DragonVsTigerErroCodeBegin then
            if __info.m_result == -722 then   --未找到该游戏对应服务
                local scene = display.getRunningScene()
                if scene and (scene.__cname == "DragonVsTigerScene" or scene.__cname == "DragonVsTigerEntranceScene" )then
                    local __params = { title = "提示" , msg = "游戏服正在维护中,请稍后重试!" ,surefunction = function ()
                        self:releaseInstance()
                    end}
                    self:showConfirmTips( __params )
                    --self:reconnectGameServerEnd()
                    --self:loadingDialogEnd()
                    --ToolKit:removeLoadingDialog()
                end
            elseif __info.m_result == -750 then  -- 进入中，请稍后
                local scene = display.getRunningScene()
                if scene and scene.__cname == "DragonVsTigerScene"  then
                         
                else
                    ToolKit:showErrorTip( __info.m_result )
                end
            else
            local data = getErrorTipById( __info.m_result )
            local __params = { title = "提示" , msg = data.tip  ,surefunction = function () 
				self:releaseInstance()
			end }
            self:showConfirmTips( __params )
            end
        else   
            DragonVsTigerUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
        end
	end 
end
 --处理成功登录游戏服
-- @params __info( table ) 登录游戏服成功消息数据
function DVTGameController:ackEnterGame( __info )
	print("DVTGameController:ackEnterGame")
	ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
    else
        self.gameScene:clearView()
        self:clearAllData()
        --self:notifyViewDataAlready()
    end 
end
 

-- 消息总入口函数
-- @params __idStr( string )   消息命令
-- @params __info( table )     消息内容
function DVTGameController:netMsgHandler(__idStr, __info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(__info)
  else
      print("没有处理消息",__idStr)
  end
end

-- 是否是龙虎斗模块消息
function DVTGameController:isDVSTGameModule( gameAtomTypeId )
  local data = RoomData:getPortalDataByAtomId( gameAtomTypeId )
  local isDVSTModule = false
  if data then
    if data.id == RoomData.DVST then
      isDVSTModule = true
    end
  end
  return isDVSTModule
end


function DVTGameController:sceneNetMsgHandler( __idStr, __info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if __info.m_result == 0 then
            local gameAtomTypeId = __info.m_gameAtomTypeId 
            if type( __info.m_message ) == "table" then
                if next( __info.m_message )  then
                    local cmdId = __info.m_message[1].id
                    local info = __info.m_message[1].msgs
                    self:netMsgHandler(cmdId, info)
                end
            end 
      else
          print("__info.m_result", __info.m_result )
      end
    end
end

-- 通知服务器初始化视图资源成功
function DVTGameController:notifyViewDataAlready()
   print("通知服务器初始化视图资源成功")
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_Get_Req",{})
end
 
-- 响应关闭连接
function DVTGameController:onCloseConnet()
  if not tolua.isnull( self.gameScene ) then
      if not tolua.isnull( self.gameScene.m_dragonVsTigerMainLayer ) then
         self.gameScene.m_dragonVsTigerMainLayer:stopAllTimer()
      end
  end
end
  
 
function DVTGameController:startCountDownShedule(countDown)
    self:destroyCountDownShedule()
    self.m_countTime = -1
    CBetManager.getInstance():setTimeCount(countDown)
    sendMsg(Lhdz_Events.MSG_LHDZ_GAME_COUNT_TIME)   
    self.m_pHandlerId = scheduler.scheduleGlobal(function(dt)
        local timeCount = CBetManager.getInstance():getTimeCount() - 1
        CBetManager.getInstance():setTimeCount(timeCount)
        timeCount = math.floor(timeCount)
        if self.m_countTime ~= timeCount then
            self.m_countTime = timeCount
            sendMsg(Lhdz_Events.MSG_LHDZ_GAME_COUNT_TIME)   
        end
    end,1)
end

function DVTGameController:destroyCountDownShedule( )
    if self.m_pHandlerId then
        scheduler.unscheduleGlobal(self.m_pHandlerId)
        self.m_pHandlerId = nil
    end
end
function DVTGameController:ackDVSTPlayerShow(info)
     LhdzDataMgr.getInstance():clearAllUserChip()
    LhdzDataMgr.getInstance():clearMyUserChip()
    LhdzDataMgr.getInstance():clearTableBetValues()
    LhdzDataMgr.getInstance():clearNo1Bet()
    msg={}
    msg.cbUserShowsCount = 1+#info.m_mostCoinplayerList
    msg.stUserShow = {}
    msg.stUserShow[1] = {}
    msg.stUserShow[1].dwUserID   = info.m_mostWinRatePlayer.m_accountId          --//UserID号
    msg.stUserShow[1].szNickName = info.m_mostWinRatePlayer.m_nickname   --//昵称
    msg.stUserShow[1].llUserScore= info.m_mostWinRatePlayer.m_score*0.01  --//分数
    msg.stUserShow[1].wFaceID    = info.m_mostWinRatePlayer.m_faceId        --//头像 
    msg.stUserShow[1].cbWinCount = info.m_rate                                       --//上桌玩家
    for i=2, #info.m_mostCoinplayerList+1 do
        msg.stUserShow[i] = {}
        msg.stUserShow[i].dwUserID   = info.m_mostCoinplayerList[i-1].m_accountId          --//UserID号
        msg.stUserShow[i].szNickName = info.m_mostCoinplayerList[i-1].m_nickname   --//昵称
        msg.stUserShow[i].llUserScore= info.m_mostCoinplayerList[i-1].m_score*0.01  --//分数
        msg.stUserShow[i].wFaceID    = info.m_mostCoinplayerList[i-1].m_faceId        --//头像 
    end
     LhdzDataMgr.getInstance():clearTableUserInfo()
    LhdzDataMgr.getInstance():clearTableUserIdLast()
    for i =1, msg.cbUserShowsCount do
        if msg.stUserShow[i].dwUserID > 0 then
            --非空闲状态，则缓存累计下注金额 
             msg.stUserShow[i].totalbet = 0
            LhdzDataMgr.getInstance():addTableUserInfo(msg.stUserShow[i])
            LhdzDataMgr.getInstance():addTableUserIdLast(msg.stUserShow[i].dwUserID)
        end
    end
end

function DVTGameController:gameOnlineNum(info)
     LhdzDataMgr.getInstance():setUserCountAtBegin(info.m_playNum)
     sendMsg(Lhdz_Events.MSG_LHDZ_GAME_TABLE_USER)
     
end
-- 通知游戏状态信息
function DVTGameController:notifyDVSTGameState( info )
   print("DVTGameController:notifyDVSTGameState")
   --dump( __info )
    LhdzDataMgr.getInstance():setGameStatus(info.m_state)
   local msg = {} 
    msg.cbCurGameStatus = info.m_state                   --//当前游戏状态
	msg.nTimeLeftSeconds = info.m_leftTime				    --//当前游戏状态剩余秒数
    msg.cbCards = {info.m_dragonCard,info.m_tigerCard}                                            --//龙牌和虎牌,结算时才有值
    				
    
	msg.cbHistoryCount = #info.m_vecBallHistory			        --//历史开奖数
    msg.cbHistorys = {}                                         --//历史开奖记录
    for i=1, #info.m_vecBallHistory do
        msg.cbHistorys[i] = {}
        msg.cbHistorys[i].cbAreaType = info.m_vecBallHistory[i].m_luckyArea    --//中奖区域类型 
        msg.cbHistorys[i].cbCardData = {}
        msg.cbHistorys[i].cbCardData[1] = info.m_vecBallHistory[i].m_cards[1]
        msg.cbHistorys[i].cbCardData[2] = info.m_vecBallHistory[i].m_cards[2]
    end
    msg.cbNo1DownArea =info.m_mostWinBetArea                    --//神算子下注区
    msg.llMyDownValues = {}                                     --//当前自己押注情况
    for i=1, Lhdz_Const.GAME_DOWN_COUNT do
        msg.llMyDownValues[i] = info.m_vecBetList[i].m_betValue*0.01
    end
    msg.llDownAreaValues= {}                                    --//下注区押注情况
    for i=1, Lhdz_Const.GAME_DOWN_COUNT do
        msg.llDownAreaValues[i] = info.m_vecBetSumList[i].m_betValue*0.01
    end
    msg.llDownAreaPool = {}                                     --//下注区玩家下注分布
     msg.llDownAreaPool[1] = {}
      msg.llDownAreaPool[2] = {} 
    msg.llDownAreaPool[3] = {} 
     for k,v in pairs(info.m_mostWinRatePlayer.m_areaBet) do
        msg.llDownAreaPool[k][1] = v*0.01
    end
    for  k,v in pairs(info.m_mostCoinplayerList) do
        for m,n in pairs(v.m_areaBet) do
           msg.llDownAreaPool[m][k+1] = n*0.01
        end
    end

    --当前局上桌玩家从游戏开始为固定排名
    --[[
        上桌玩家在用户本地通过chairid可能是查询不到的或不准确的
        原因是上桌玩家在投注阶段离开游戏，此时另一个玩家加入游戏，会获取不到当前局离开的上桌玩家的信息
        需要服务器在场景消息中固定发送当前局的上桌玩家信息
    ]]--
    msg.cbUserShowsCount = 1+#info.m_mostCoinplayerList           --//上桌玩家数（新加） 
    msg.stUserShow = {}
       msg.stUserShow[1] = {}
    msg.stUserShow[1].dwUserID   = info.m_mostWinRatePlayer.m_accountId          --//UserID号
    msg.stUserShow[1].szNickName = info.m_mostWinRatePlayer.m_nickname   --//昵称
    msg.stUserShow[1].llUserScore= info.m_mostWinRatePlayer.m_score*0.01  --//分数
    msg.stUserShow[1].wFaceID    = info.m_mostWinRatePlayer.m_faceId        --//头像 
    msg.stUserShow[1].cbWinCount = info.m_rate                                       --//上桌玩家
    for i=2, #info.m_mostCoinplayerList+1 do
        msg.stUserShow[i] = {}
        msg.stUserShow[i].dwUserID   = info.m_mostCoinplayerList[i-1].m_accountId          --//UserID号
        msg.stUserShow[i].szNickName = info.m_mostCoinplayerList[i-1].m_nickname   --//昵称
        msg.stUserShow[i].llUserScore= info.m_mostCoinplayerList[i-1].m_score*0.01  --//分数
        msg.stUserShow[i].wFaceID    = info.m_mostCoinplayerList[i-1].m_faceId        --//头像 
    end
   
   
   
   
    msg.llChipsValues = {1,10,50,100,500}                                      --//筹码数值
    
    
    msg.iUserCounts = 	info.m_playerCount				    --//当前游戏玩家人数
    msg.m_sRecordId = info.m_recordId
    LhdzDataMgr.getInstance():setRecordId(info.m_recordId)

    --保存进入游戏时当前房间玩家人数
    LhdzDataMgr.getInstance():setUserCountAtBegin(msg.iUserCounts)

    --保存临时分数信息
    LhdzDataMgr.getInstance():setTempSelfScore(info.m_self.m_score*0.01)

    --保存上桌玩家信息
    LhdzDataMgr.getInstance():clearTableUserInfo()
    LhdzDataMgr.getInstance():clearTableUserIdLast()
    local selfUserId = info.m_self.m_accountId
    for i =1, msg.cbUserShowsCount do
        if msg.stUserShow[i].dwUserID > 0 then
            --非空闲状态，则缓存累计下注金额
            local totalbet = 0
            if Lhdz_Const.STATUS.GAME_SCENE_FREE ~= msg.cbCurGameStatus then
                for m=1, Lhdz_Const.GAME_DOWN_COUNT do
                    totalbet = totalbet + msg.llDownAreaPool[m][i]
                end
            end
            msg.stUserShow[i].totalbet = totalbet
            LhdzDataMgr.getInstance():addTableUserInfo(msg.stUserShow[i])
            LhdzDataMgr.getInstance():addTableUserIdLast(msg.stUserShow[i].dwUserID)
        end
    end
     
    
    if msg.cbCurGameStatus == Lhdz_Const.STATUS.GAME_SCENE_RESULT then
        self:startCountDownShedule(msg.nTimeLeftSeconds + 1)
    else
        self:startCountDownShedule(msg.nTimeLeftSeconds)
    end

    --进入场景后 更新一下续投的金额
    LhdzDataMgr.getInstance():updateContinueInfo()

    --设置筹码值
    local chipValueList = {1,10,50,100,500}
    for i=1,5,1 do
        local bet_value = chipValueList[i] or chipValueList[#chipValueList]
        bet_value = msg.llChipsValues[i] == 0 and bet_value or msg.llChipsValues[i]
        CBetManager.getInstance():setJettonScore(i, bet_value)
    end
    --设置牌值
    LhdzDataMgr.getInstance():setCards(msg.cbCards)

    --历史记录
    --开奖阶段进入游戏，不立刻显示当前局结果，缓存起来
    --服务器回发的历史记录时间顺序为正序
    --本地历史记录时间顺序为倒序
    LhdzDataMgr.getInstance():clearHistory()
    LhdzDataMgr.getInstance():clearTrendList()
    if msg.cbCurGameStatus == Lhdz_Const.STATUS.GAME_SCENE_RESULT then
        if msg.cbHistoryCount > 0 then
            LhdzDataMgr.getInstance():addTempHistory(msg.cbHistorys[msg.cbHistoryCount])
            msg.cbHistoryCount = msg.cbHistoryCount - 1
        end
    end
    for i = 1, msg.cbHistoryCount do
        LhdzDataMgr.getInstance():addHistoryToList(msg.cbHistorys[i])
    end

    --先清空投注数据
    LhdzDataMgr.getInstance():clearAllUserChip()
    LhdzDataMgr.getInstance():clearMyUserChip()
    LhdzDataMgr.getInstance():clearTableBetValues()
    LhdzDataMgr.getInstance():clearNo1Bet()

    --当前局已下注金币
    for i = 1, Lhdz_Const.GAME_DOWN_COUNT do
        local totalJetton = msg.llDownAreaValues[i]
        local selfJetton = msg.llMyDownValues[i]
        LhdzDataMgr.getInstance():setMyBetValue(i, selfJetton)
        LhdzDataMgr.getInstance():setOtherBetValue(i, totalJetton - selfJetton)

        local tableJetton = {}
        local tableTotalJetton = 0
        for k=1, Lhdz_Const.TABEL_USER_COUNT do
            tableJetton[k] = msg.llDownAreaPool[i][k]
            if tableJetton[k] then
                tableTotalJetton = tableTotalJetton + tableJetton[k]
            end
        end 
         local otherJetton = ((totalJetton - selfJetton - tableTotalJetton) > 0) and (totalJetton - selfJetton - tableTotalJetton) or 0
        ----new
        if selfJetton > 0 then
            local selfTable = CBetManager.getInstance():getSplitGoldNew(selfJetton)
            for k,v in pairs(selfTable) do
                local selfChip = {}
                selfChip.wChairID = 0
                selfChip.dwUserID =Player:getAccountID()
                selfChip.wChipIndex = i
                selfChip.wJettonIndex = LhdzDataMgr.getInstance():GetJettonMaxIndexByValue(v)
                LhdzDataMgr.getInstance():addMyUserChip(selfChip)
                LhdzDataMgr.getInstance():addAllUserChip(selfChip)
            end
        end

        for k=1, Lhdz_Const.TABEL_USER_COUNT do
            local tableUser = LhdzDataMgr.getInstance():getTableUserInfo(k)
            if tableUser then
                LhdzDataMgr.getInstance():addTableBetValueByUserId(tableUser.dwUserID, i, msg.llDownAreaPool[i][k])
                if tableJetton[k] > 0 then
                    if 1 == k then
                        LhdzDataMgr.getInstance():setIsNo1BetByIndex(i, tableUser.dwUserID)
                    end
                end
                 

                ----new
                if tableJetton[k] > 0 then
                    local tempTable = CBetManager.getInstance():getSplitGoldNew(tableJetton[k])
                    for m,v in pairs(tempTable) do
                        local tableChip = {}
                        tableChip.wChairID = -1
                        tableChip.dwUserID = tableUser.dwUserID
                        tableChip.wChipIndex = i
                        tableChip.wJettonIndex = LhdzDataMgr.getInstance():GetJettonMaxIndexByValue(v)
                        if Player:getAccountID() ~= tableChip.dwUserID then
                            LhdzDataMgr.getInstance():addAllUserChip(tableChip)
                        end
                    end

                end

            end
        end
         

        ----new 
        if otherJetton > 0 then
            local otherTable = CBetManager.getInstance():getSplitGoldNew(otherJetton)
            for k,v in pairs(otherTable) do
                local otherChip = {}
                otherChip.wChairID = -1
                otherChip.dwUserID = -1
                otherChip.wChipIndex = i
                otherChip.wJettonIndex = LhdzDataMgr.getInstance():GetJettonMaxIndexByValue(v)
                LhdzDataMgr.getInstance():addAllUserChip(otherChip)
            end
        end
    end
    
    self:gameState(info,msg.cbCurGameStatus)
end
function DVTGameController:gameContinueBet(data)
    local ret = data.m_ret
end
function DVTGameController:gameWait(data)
    
    self:gameState(data,1)
    if self.gameScene.m_dragonVsTigerMainLayer then
        self.gameScene.m_dragonVsTigerMainLayer:showGameVSAnim()
    end
end
function DVTGameController:gameStart(data)
    LhdzDataMgr.getInstance():setRecordId(data.m_recordId)
    self:gameState(data,2)
    if self.gameScene.m_dragonVsTigerMainLayer then
        self.gameScene.m_dragonVsTigerMainLayer:showGameStatusAnim()
    end
end
function DVTGameController:gameResult(data)
    self:gameState(data,3)
     local msg = {} 
	msg.cbAreaType = data.m_lastWin.m_luckyArea                         --//中奖区域类型 

    msg.cbCards = data.m_lastWin.m_cards                                            --//龙牌和虎牌
    msg.llPlayerResult=0
     for k,v in pairs(data.m_vecBalance) do 
        if v.m_accountId == Player:getAccountID() then
	        msg.llPlayerResult = v.m_netProfit*0.01					--//玩家成绩
        end
    end
    
    LhdzDataMgr.getInstance():setAreaType(msg.cbAreaType) 
    LhdzDataMgr.getInstance():setMyResult(msg.llPlayerResult)
    LhdzDataMgr.getInstance():setTableResult(msg.cbAreaType )
    LhdzDataMgr.getInstance():setCards(msg.cbCards)
     LhdzDataMgr.getInstance():setResult(data.m_vecBalance )
    --添加历史记录
    msg.cbHistorys = {}
    msg.cbHistorys.cbAreaType = msg.cbAreaType
    msg.cbHistorys.cbCardValue = msg.cbCardValue
    msg.cbHistorys.cbCardData = msg.cbCards
    LhdzDataMgr.getInstance():addTempHistory(msg.cbHistorys)

    sendMsg(Lhdz_Events.MSG_LHDZ_GAME_RESULT)
    if self.gameScene.m_dragonVsTigerMainLayer then
        self.gameScene.m_dragonVsTigerMainLayer:showGameStatusAnim()
    end
end
--游戏信息
function DVTGameController:gameState(data,state)
    local msg = {} 
    msg.cbCurGameStatus = state                  --//当前游戏状态
    msg.wTimerValue = data.m_leftTime                        --//当前状态剩余时间
    LhdzDataMgr.getInstance():setGameStatus(msg.cbCurGameStatus);
     LhdzDataMgr.getInstance():setContinueBet(data.m_canContinueBet)
    if msg.cbCurGameStatus == Lhdz_Const.STATUS.GAME_SCENE_FREE then
        self:removeschedulers() 
        for i=1, Lhdz_Const.GAME_DOWN_COUNT do
            LhdzDataMgr.getInstance():setMyBetValue(i, 0)
            LhdzDataMgr.getInstance():setOtherBetValue(i, 0)
        end
    elseif msg.cbCurGameStatus == Lhdz_Const.STATUS.GAME_SCENE_BET then 
        self:startCountDownShedule(msg.wTimerValue)
        LhdzDataMgr.getInstance():updateContinueInfo();
        LhdzDataMgr.getInstance():setIsContinued(false);
    elseif msg.cbCurGameStatus == Lhdz_Const.STATUS.GAME_SCENE_RESULT then
        self:startCountDownShedule(msg.wTimerValue)
    end

    sendMsg(Lhdz_Events.MSG_LHDZ_GAME_STATUS)
end

function DVTGameController:removeschedulers()
    for k,v in pairs(self.m_dSchedulers) do
        if v then
            scheduler.unscheduleGlobal(v)
        end
    end
    self.m_dSchedulers = {}
end

function DVTGameController:reqDragonVsTigerBet( __info )
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_Bet_Req", __info )
end
function DVTGameController:reqDragonVsTigerContinueBet()
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_Continue_Req" )
end
-- --下注结果，自己下注各区域加减走这个协议
-- CS_M2C_DragonVsTiger_Bet_Ack = 
-- {
--   { 1,  1, 'm_betId'       , 'UBYTE'            , 1   , '下注区域ID'},
--   { 2,  1, 'm_betValue'      , 'UINT'           , 1   , '下注额'},
--   --{ 3,  1, 'm_curBetValue'     , 'UINT'           , 1   , '当前区域已经下注总额'},
--   --{ 4,  1, 'm_score'       , 'UINT'           , 1   , '玩家总金币'},
--   { 3,  1, 'm_result'         , 'INT'            , 1   , '下注结果(0：成功 -1:系统错误;-2:游戏不能下注;-3:金币不足;-4:新手时总投注额不能超过限制;-5:单区域投注总额不能超过限制;)'},
-- }

-- 和 1, 龙 2, 虎 3
-- 下注结果，自己下注各区域加减走这个协议
function DVTGameController:ackDVSTBet( __info )
   -- print("DVTGameController:ackDVSTBet")
    dump( __info )
    if __info.m_ret == 0 then 
        return 
    end
    if __info.m_ret== -700002 then
        str ="不是有效押注区域！"
    elseif __info.m_ret== -700001 then
            str ="该状态不能押注！"
    elseif __info.m_ret== -700003 then
        str ="游戏最低金币找不到！"
    elseif __info.m_ret== -700004 then
        str ="下注失败, 携带金币低于30金币！"
    elseif __info.m_ret== -700005 then
        str ="您的金币不足！"
    elseif __info.m_ret== -700007 then
        str ="您的押注超过最大值！"
    elseif __info.m_ret== -700008 then
        str ="无此筹码！"  
    elseif __info.m_ret== -700009 then
         str ="无下注局！" 
     elseif __info.m_ret== -700010 then
         str ="单局只能续押一次！" 
    end
    TOAST(str)
end

function DVTGameController:ackSceneMessage(__info) 
    local dlg= nil
    if __info.m_type == 2 then
            dlg = DlgAlert.showTipsAlert({title = "提示", tip = "你已经被系统踢出房间，请稍后重试"})
    elseif __info.m_type == 1 then
            dlg = DlgAlert.showTipsAlert({title = "提示", tip = "房间维护，请稍后再游戏"})
    end
	if dlg then
		dlg:setSingleBtn("退出", function ()
			dlg:closeDialog() 
            self:destroyCountDownShedule() 
			self:releaseInstance()
		end)
		dlg:enableTouch(false)
	end 
end
-- 下注飞筹码效果, 各区域加金币走这个协议
function DVTGameController:notifyDVSTEachUserBet( info )
    local msg = {}
    msg.wChairID = info.m_playerBets[1].m_accountId
    for i=1,#info.m_playerBets[1].m_bets do
                            --//座位号
    
	    msg.wChipIndex = info.m_playerBets[1].m_bets[i].m_betId						--//下注索引
        for k,v in pairs(Lhdz_Const.JETTONVALUELIST) do 
            if v == info.m_playerBets[1].m_bets[i].m_betValue*0.01 then
	            msg.wJettonIndex = k				--//筹码索引
            end
        end  
    
        --记录下注金额
        local idx = LhdzDataMgr.getInstance():getUserByUserId(msg.wChairID)
        if 0 == idx then
            idx = LhdzDataMgr.getInstance():checkUserIsOnTable()
        end

        local llValue = info.m_playerBets[1].m_bets[i].m_betValue*0.01

        if idx > 0 then
            local tableuser = LhdzDataMgr.getInstance():getTableUserInfo(idx)
            if tableuser then
                tableuser.totalbet = tableuser.totalbet + llValue
            end
        end

        if(msg.wChairID == Player:getAccountID())then
            local userChip = {}
            userChip.wChairID = msg.wChairID;
            userChip.wChipIndex = msg.wChipIndex ;
            userChip.wJettonIndex = msg.wJettonIndex;
            LhdzDataMgr.getInstance():addAllUserChip(userChip);

            LhdzDataMgr.getInstance():setIsNo1BetByIndexAndChairId(msg.wChipIndex, msg.wChairID)
            LhdzDataMgr.getInstance():addTableBetValue(msg.wChairID, msg.wChipIndex, llValue)

            LhdzDataMgr.getInstance():addMyUserChip(userChip);
            LhdzDataMgr.getInstance():addMyBetValue(msg.wChipIndex, llValue);
    --        PlayerInfo.getInstance():addBetScore(llValue)
            --在缓存玩家分数中扣除下注金额
            LhdzDataMgr.getInstance():setTempSelfScore(LhdzDataMgr.getInstance():getTempSelfScore() - llValue)
            sendMsg(Lhdz_Events.MSG_LHDZ_GAME_CHIP, "myBetSuccess")
        else
            local randomts = math.random(0,8)/10
            local localscheduler =  scheduler.performWithDelayGlobal(function()
                local userChip = {}
                userChip.wChairID = msg.wChairID;
                userChip.wChipIndex = msg.wChipIndex;
                userChip.wJettonIndex = msg.wJettonIndex;
                LhdzDataMgr.getInstance():addAllUserChip(userChip);

                LhdzDataMgr.getInstance():setIsNo1BetByIndexAndChairId(msg.wChipIndex, msg.wChairID)
                LhdzDataMgr.getInstance():addTableBetValue(msg.wChairID, msg.wChipIndex, llValue)

                LhdzDataMgr.getInstance():addOtherBetValue(msg.wChipIndex, llValue);
                sendMsg(Lhdz_Events.MSG_LHDZ_GAME_CHIP)
            end, randomts)
            table.insert(self.m_dSchedulers,localscheduler)
        end
    end
end





-- 请求在线玩信息列表
function DVTGameController:reqDragonVsTigerPlayerOnlineList()
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_PlayerOnlineList_Req", {1,100} )
end

-- 在线玩家
function DVTGameController:ackDVSTPlayerOnlineList( info )
    local msg = {}

    msg.cbCount = #info.m_playerInfo
    msg.stUserShowEx = {}                                       --//
    LhdzDataMgr.getInstance():clearRankUser()
    for i=1, msg.cbCount do
        msg.stUserShowEx[i] = {}
        msg.stUserShowEx[i].dwUserID =info.m_playerInfo[i].m_accountId          --//UserID号
        msg.stUserShowEx[i].szNickName = info.m_playerInfo[i].m_nickname   --//昵称
        msg.stUserShowEx[i].llUserScore = info.m_playerInfo[i].m_score*0.01  --//分数
        msg.stUserShowEx[i].wFaceID = info.m_playerInfo[i].m_faceId        --//头像
        msg.stUserShowEx[i].cbWinCount = info.m_playerInfo[i].m_recentWin      --//最近20局获胜局数
	    msg.stUserShowEx[i].wWinCount = info.m_playerInfo[i].m_recentBet*0.01
        msg.stUserShowEx[i].cbCount = info.m_playerInfo[i].m_recentPlay
	    --msg.stUserShowEx[i].llDownTotal = info.m_playerInfo[i]:readLongLong();
      --  msg.stUserShowEx[i].nVipLev = info.m_playerInfo[i]:readUInt()
       -- msg.stUserShowEx[i].byFaceCircleID = info.m_playerInfo[i]:readUChar()
        LhdzDataMgr.getInstance():addRankUserToList(msg.stUserShowEx[i])
    end
--    LhdzDataMgr.getInstance():sortRankUserList()
    sendMsg(Lhdz_Events.MSG_LHDZ_GAME_RANK)
end

-- '1-切到后台 2-切回游戏'},
function DVTGameController:reqDragonVsTigerBackground( __info)
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_Background_Req", __info )
end

function DVTGameController:ackDragonVsTigerBackground( __info  )
   print("DVTGameController:ackDragonVsTigerBackground")
   --dump( __info )
	if __info.m_ret ~= 0 then
		--[[
		local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "与服务器断开", tip_size = 34})
		dlg:setSingleBtn("确定", function ()
			dlg:closeDialog()
            self.releaseInstance()
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
		--]]
    end
end


function DVTGameController:rewDragonVsTigerForceExit()
   self:send2GameServer4DragonVsTiger("CS_C2M_DragonVsTiger_ForceExit_Req", {} )
end

function DVTGameController:ackDragonVsTigerForceExit( __info )
    print("DVTGameController:ackDragonVsTigerForceExit")
    --dump( __info )
	if __info.m_ret == 0 then
		--self:releaseInstance()
	end
end

function DVTGameController:notifyDragonVsTigerExit( __info )
    --print("DVTGameController:notifyDragonVsTigerExit")
    --dump( __info  )
      print("游戏未开始，超时强制解散")
    if not tolua.isnull( self.gameScene ) then
       self.gameScene.m_dragonVsTigerMainLayer:showDissolveDlg( __info.m_type )
    end
end



-- 设置切换到后台状态
-- @params isEnter( boolean ) 状态值
function DVTGameController:setEnterForeground( isEnter )
    self.m_enterForeground = isEnter
end

-- 获取切换到后台状态值
-- @return self.m_enterForeground( boolean ) 状态值
function DVTGameController:getEnterForeground()
    return  self.m_enterForeground
end


return DVTGameController