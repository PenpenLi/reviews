--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--
-- Author: chenzhanming
-- Date: 2017-04-10 09:57:38
-- 捕鱼游戏控制器
--

local FishGlobal              = require("src.app.game.Fishing.src.FishGlobal")
local FishingPlayer           = require("src.app.game.Fishing.src.FishingGame.model.FishingPlayer")
local FishSkillManager        = require("src.app.game.Fishing.src.FishingGame.controller.FishSkillManager")
local FishGameDataController  = require("src.app.game.Fishing.src.FishingCommon.controller.FishGameDataController")
local FishModel               = require("src.app.game.Fishing.src.FishingGame.model.FishModel")
local DlgAlert                = require("app.hall.base.ui.MessageBox")
local FishingUtil             = require("src.app.game.Fishing.src.FishingCommon.utils.FishingUtil")
local FishSoundManager        =  require("src.app.game.Fishing.src.FishingCommon.controller.FishSoundManager")

local BaseGameController = import(".BaseGameController")

local FishGameController = class("FishGameController",function()
     return BaseGameController.new()
end)

FishGameController.instance = nil

-- 获取捕鱼游戏控制器实例
function FishGameController:getInstance()
	if FishGameController.instance == nil then
		FishGameController.instance = FishGameController.new()
	end
    return FishGameController.instance
end

function FishGameController:releaseInstance()
    if FishGameController.instance then
		FishGameController.instance:onDestory()
        FishGameController.instance = nil
		g_GameController = nil
    end
end

function FishGameController:ctor()
	-- 技能管理器实例化
    self:myInit()
	FishSkillManager:getInstance()
	-- 初始化捕鱼数据
	self:initFishData() 
	--注册协议
	self:initCallBackFuncList()
	 
   -- self:initPowerList()
end

function FishGameController:myInit()
  	-- 添加搜索路径
  	ToolKit:addSearchPath("src/app/game/Fishing/src") 
	ToolKit:addSearchPath("src/app/game/Fishing/src/FishingCommon/protocol")
	ToolKit:addSearchPath("src/app/game/Fishing/res")
    -- 加载捕鱼协议
  	Protocol.loadProtocolTemp("buyu.protoReg")
    self.__roomId   = 0 			                   -- 房间编号(自由房填服务器生成的编号，其他填0)
    self.roomType         = 0           		-- 房间类型
    self.roomData         = nil
    self.m_playerSceneCoin  = 0                  -- 玩家场景金币
    self.toadFishTableInfoList = {}              -- 经典房房间列表
    self.gameKindType = 0                        -- 游戏类型
    self.onlinePersonNum = 0                     -- 房间在线人数   
    self.netMsgHandlerSwitch = {} 

	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

function FishGameController:initFishData()
	print("FishGameController:initFishData()")
	self.itemType = {
	                   POER_TYPE       = 1,  -- 炮
	                   CURRENCY_TYPE   = 2,  -- 货币
	                   SKILL_ITEM_TYPE = 3,  -- 技能道具  
                    }
                     
 	self.m_gameSceneIndex = 1       --场景索引
	self.m_fishPlayerList = {}      --捕鱼游戏中玩家列表
	self.m_accountIDChairMap ={}    --账号与椅子号对应关系
	self.m_nNativeChairCoinMap = {} --客户端本地各个玩家金币
	for i = 1 , FishGlobal.PlayerCount do 
		self.m_nNativeChairCoinMap[i] = 0
	end
	self.gameScene = nil            --场景节点
	self.myChair = 0                --我的椅子号
	self.myViewChair = 0            --我的视图id
	self.m_keepCannons  = {}        --可用炮表	
	self.minRoomOpenLevel = 1       --最小等级
	self.maxRoomOPenLvel = 3000     --最大等级
	self.taskId = 1                 --任务id
	self.isTaskInited = false       --任务是否已经初始化
	self.m_openLevels = {}          --炮可以使用的等级列表
	self.m_currentLevelIndex = 1    --当前等级的索引
	self.m_nTaskProcess = 0         --任务进度
	self.m_skillItems = {}          --技能道具 
	self.m_skillItemCounts = {}     --技能道具对应的数量
	self.m_isNeedWave = false       --是否需要播放波浪
	self.m_powerInfoList = {}       --可以使用的炮的信息:等级，分数，炮的id
	self.m_taskAwardState = {}      --活动任务奖励状态
	self.m_emojiFreeTimes = 0       --免费次数
	self.m_emojiCoin  = 0           --表情金币消耗 
	self.m_nativeChairGoldMap = {}  --客户端本地各个玩家本局掉落的元宝数量
	for i = 1 , FishGlobal.PlayerCount do 
		self.m_nativeChairGoldMap[i] = 0
	end
	self.m_aiDriveAccountID = 0     --ai驱动端 初级版本只用于检测子弹与鱼碰撞，buff伤害
end

function FishGameController:setEnterGameAck() 
    self:registNetMassege()
	self:setEnterGameAckHandler(handler(self,self.ackRealEnterGame))
end

 -- 注册网络消息 
function FishGameController:registNetMassege()
  local protocolList = { 
                          "CS_G2C_BuYu_Playerdata_Nty"           ,  
                          "CS_G2C_BuYu_Fishdata_Nty"             , 
                          "CS_G2C_BuYu_SkillInfo_Nty"            ,
                          "CS_G2C_BuYu_Update_Bag_Nty"           ,
                          "CS_G2C_BuYu_PowerScore_Nty"           ,
                          "CS_G2C_BuYu_TaskID_Nty"               ,
                          "CS_G2C_BuYu_Broadcast_Nty"            ,
                          "CS_G2C_BuYu_Expel_Nty"                ,
                          "CS_G2C_BuYu_Scene_Info_Nty"           ,
                          "CS_G2C_BuYu_Buff_List_Nty"            ,
                          "CS_G2C_BuYu_Make_Nty"                 ,
                          "CS_G2C_BuYu_Army_Over_Nty"            ,
                          "CS_G2C_BuYu_Change_Level_Nty"         ,
                          "CS_G2C_BuYu_Fire_Nty"                 ,
                          "CS_G2C_BuYu_Get_Nty"                  ,
                          "CS_G2C_BuYu_Ask_Nty"               	 , 
                          "CS_G2C_BuYu_Skill_Ack"            	 ,
                          "CS_G2C_BuYu_Buff_Get_Ack"         	 ,
                          "CS_G2C_BuYu_Chat_Nty"             	 ,
                          "CS_G2C_BuYu_BuyItem_Ack"           	 ,
                          "CS_G2C_BuYu_Notice_Msg_Nty"        	 ,
                          "CS_G2C_BuYu_Kick_GameOut_Nty"         ,
                          "CS_G2C_BuYu_Gm_Nty"                   ,
                          "CS_G2C_BuYu_GameMaintenance_Nty"	     ,
                          "CS_G2C_BuYu_Active_Task_Award_Ack"    ,
                          "CS_G2C_BuYu_Get_Active_Task_Award_Ack",
                          "CS_G2C_BuYu_Tunpao_Returnback_Nty"    ,
                          "CS_G2C_BuYu_Emoji_Count_Nty"          ,
                          "CS_G2C_BuYu_Exchange_Info_Ack"        ,
                          "CS_G2C_BuYu_Exchange_Ack"             ,
                          "CS_G2C_BuYu_ClubInit_Nty"             ,
                          "CS_G2C_BuYu_LockFishOper_Ack"         ,
                          "CS_G2C_BuYu_PlayerLockFishOper_Nty"   ,
                          "CS_G2C_BuYu_ChangeSpeed4Cannon_Ack"   ,
                          "CS_G2C_BuYu_PlayerChangeSpeed_Nty"    ,
                          "CS_G2C_BuYu_WhoDoRobotCheck_Nty"      ,
                          "CS_M2C_BuYu_KickClient_Nty",
                       }

   
  self:setNetMsgCallbackByProtocolList(protocolList, handler(self, self.netMsgHandler)) -- 注册网络处理函数 
end

function FishGameController:sceneNetMsgHandler( __idStr, __info )
    print("FishGameController:sceneNetMsgHandler            ",__info.m_message)
	if __idStr == "CS_H2C_HandleMsg_Ack" then        
		if __info.m_result == 0 then
      	    local gameAtomTypeId = __info.m_gameAtomTypeId
         --   if self:isFishGameModule( gameAtomTypeId ) then
                if type( __info.m_message ) == "table" then
                   if next( __info.m_message )  then
      		            local cmdId = __info.m_message[1].id
      		            local info = __info.m_message[1].msgs 
						self:netMsgHandler1(cmdId, info)
                   end
                end
          --  end
		end
	end
end

function FishGameController:netMsgHandler1( __idStr, __info )
	print(string.format("FishGameController:netMsgHandle",__idStr))
	if self.netMsgHandlerSwitch[__idStr] then
		__info.m_nClockTime = os.clock();
		if self.gameScene.m_bIsInit then
		   (self.netMsgHandlerSwitch[__idStr])( __info )
		else
			self.m_pSceneNetMsgData = self.m_pSceneNetMsgData or {}
			table.insert(self.m_pSceneNetMsgData, {__idStr, __info})
		end
    else
       print("未注册消息:",__idStr)
    end
end

function FishGameController:onSceneInitMsgCall()
	if self.m_pSceneNetMsgData ~= nil then
		for __, infoData in pairs(self.m_pSceneNetMsgData) do
			local idStr = infoData[1]
			local info = infoData[2]
			if self.netMsgHandlerSwitch[idStr] then
				(self.netMsgHandlerSwitch[idStr])( info )
			end	
		end
	end
	self.m_pSceneNetMsgData = nil
	if self.m_pNetMsgData ~= nil then
		for __, infoData in pairs(self.m_pNetMsgData) do
			local idStr = infoData[1]
			local info = infoData[2]
			if  self.m_callBackFuncList[idStr]  then
				(self.m_callBackFuncList[idStr])(info)
			end
		end
	end
	self.m_pNetMsgData = nil
end

function FishGameController:getTime(clockTime, nTime)
	if nTime == nil then
		return 0;
	end
	return nTime;
	-- if clockTime == nil then
		
	-- end
	-- local t = os.clock() - clockTime;
	-- if nTime == nil then
	-- 	return t;
	-- end
	-- local retT = nTime - t;
	-- if retT < 0 then
	-- 	return 0;
	-- end
	-- return retT;
end

function FishGameController:getFishLastTime(clockTime, nLastTime)
	local t = math.floor(os.clock() - clockTime + 0.5);
	return nLastTime + t;
end


function FishGameController:initCallBackFuncList()
	self.m_callBackFuncList = {}
	self.m_callBackFuncList["CS_G2C_BuYu_Playerdata_Nty"]            = handler(self, self.notifyPlayerdatas)           -- 更新玩家数据
	self.m_callBackFuncList["CS_G2C_BuYu_Fishdata_Nty"]              = handler(self, self.notifyFishDatas)             -- 刚进入游戏，初始化所有鱼的信息
	self.m_callBackFuncList["CS_G2C_BuYu_Update_Bag_Nty"]            = handler(self, self.notifyUpdateBag)             -- 更新背包
	self.m_callBackFuncList["CS_G2C_BuYu_SkillInfo_Nty"]             = handler(self, self.notifySkillInfo)             -- 通知技能信息
	self.m_callBackFuncList["CS_G2C_BuYu_PowerScore_Nty"]            = handler(self, self.notifyPowerLevelList)        -- 通知开放等级列表
	self.m_callBackFuncList["CS_G2C_BuYu_TaskID_Nty"]                = handler(self, self.notifyTaskId)                -- 通知最高完成任务Id
	self.m_callBackFuncList["CS_G2C_BuYu_Broadcast_Nty"]             = handler(self, self.notifyBroadcast)             -- 捕鱼消息广播
	self.m_callBackFuncList["CS_G2C_BuYu_Expel_Nty"]                 = handler(self, self.notifyExpel)                 -- 驱赶鱼，准备出鱼阵
	self.m_callBackFuncList["CS_G2C_BuYu_Scene_Info_Nty"]            = handler(self, self.notifyFishery)               -- 更新渔场
	self.m_callBackFuncList["CS_G2C_BuYu_Buff_List_Nty"]             = handler(self, self.notifyBuffList)              -- 刷新鱼的buff
	self.m_callBackFuncList["CS_G2C_BuYu_Make_Nty"]                  = handler(self, self.notifyOutFish)               -- 出鱼
	self.m_callBackFuncList["CS_G2C_BuYu_Army_Over_Nty"]             = handler(self, self.notifyArmyOver)              -- 鱼阵结束
	self.m_callBackFuncList["CS_G2C_BuYu_Change_Level_Nty"]          = handler(self, self.notifyChangePower)           -- 换炮的等级
	self.m_callBackFuncList["CS_G2C_BuYu_Fire_Nty"]                  = handler(self, self.notifyFire)                  -- 发炮
	self.m_callBackFuncList["CS_G2C_BuYu_Get_Nty"]                   = handler(self, self.notifyKillFish)              -- 请求捕鱼
	self.m_callBackFuncList["CS_G2C_BuYu_Ask_Nty"]                   = handler(self, self.notifyAskForFishCount)       -- 询问客户端当前鱼池数量
	self.m_callBackFuncList["CS_G2C_BuYu_Skill_Ack"]                 = handler(self, self.ackUseSkill)                 -- 响应释放技能
	self.m_callBackFuncList["CS_G2C_BuYu_Buff_Get_Ack"]              = handler(self, self.ackBuffGet)                  -- 响应功能鱼的buff
	self.m_callBackFuncList["CS_G2C_BuYu_Chat_Nty"]                  = handler(self, self.notifyChat)                  -- 聊天信息  
	self.m_callBackFuncList["CS_G2C_BuYu_Kick_GameOut_Nty"]          = handler(self, self.notifyKickGameOut)           -- 踢出房间
	self.m_callBackFuncList["CS_G2C_BuYu_Gm_Nty"]                    = handler(self, self.ackBuYuGM)                   -- 响应GM指令
	self.m_callBackFuncList["CS_G2C_BuYu_GameMaintenance_Nty"]	     = handler(self, self.notifyGameMaintenance)	     -- 维护信息
	self.m_callBackFuncList["CS_G2C_BuYu_Active_Task_Award_Ack"]     = handler(self, self.ackActiveTaskAward)	         -- 任务奖励信息
	self.m_callBackFuncList["CS_G2C_BuYu_Get_Active_Task_Award_Ack"] = handler(self, self.ackGetActiveTaskAward)	     -- 获取任务奖励
	self.m_callBackFuncList["CS_G2C_BuYu_Tunpao_Returnback_Nty"]     = handler(self, self.notifyTunpaoReturnback)	     -- 返还金币
	self.m_callBackFuncList["CS_G2C_BuYu_Emoji_Count_Nty"]           = handler(self, self.notifyEmojiFreeTimes)	       -- 魔法表情免费次数 
	self.m_callBackFuncList["CS_G2C_BuYu_LockFishOper_Ack"]          = handler(self, self.ackLockFishOper)             -- 玩家请求锁定鱼操作返回
	self.m_callBackFuncList["CS_G2C_BuYu_PlayerLockFishOper_Nty"]    = handler(self, self.notifyPlayerLockFishOper)    -- 有玩家锁定鱼操作通知
	self.m_callBackFuncList["CS_G2C_BuYu_ChangeSpeed4Cannon_Ack"]    = handler(self, self.ackChangeSpeed4Cannon )      -- 切换炮速返回
	self.m_callBackFuncList["CS_G2C_BuYu_PlayerChangeSpeed_Nty"]     = handler(self, self.notiyPlayerChangeSpeed )     -- 有玩家切换炮速
	self.m_callBackFuncList["CS_G2C_BuYu_WhoDoRobotCheck_Nty"]       = handler(self, self.notiyWhoDoRobotCheck )       -- 通知服务器指定那个玩家做AI碰撞检测
	
	self.netMsgHandlerSwitch = {}
    self.netMsgHandlerSwitch[ "CS_M2C_BuYu_EnterdomRoomPhone_Nty" ]            =   handler(self,self.notifyEnterFreedomRoomPhone)           -- 通知玩家进请求入房间
    self.netMsgHandlerSwitch[ "CS_M2C_BuYu_FastEnterTablePhone_Ack" ]          =   handler(self,self.ackFastEnterFreeTablePhone)            -- 响应快速进入房间
    self.netMsgHandlerSwitch[ "CS_M2C_BuYu_RefreshTable_Ack" ]                 =   handler(self,self.notifyToadRoomTableList) 
    self.netMsgHandlerSwitch[ "CS_M2C_BuYu_ApplyTableChair_Ack" ]              =   handler(self,self.ackApplyTableChair) 
    self.netMsgHandlerSwitch[ "CS_M2C_BuYu_ExitRoomHall_Ack" ]                 =   handler(self,self.ackExitFreeRoomHall)       			      -- 退出游戏
	self.netMsgHandlerSwitch[ "CS_M2C_BuYu_KickClient_Nty" ]                 =   handler(self,self.notifyKickGameOut)       			      -- 退出游戏
	addMsgCallBack(self, "fish_msg_MSG_GAME_INIT", handler(self, self.onSceneInitMsgCall))
end

function FishGameController:clearData()
	self.m_isNeedWave = false
    self.m_fishPlayerList = {}      --捕鱼游戏中玩家列表
	self.m_accountIDChairMap ={}    --账号与椅子号对应关系
	self.m_nNativeChairCoinMap = {} --客户端本地各个玩家金币
	for i = 1 , FishGlobal.PlayerCount do 
		self.m_nNativeChairCoinMap[i] = 0
	end
	self.m_nativeChairGoldMap = {}  --客户端本地各个玩家本局掉落的元宝数量
    for i = 1 , FishGlobal.PlayerCount do 
		self.m_nativeChairGoldMap[i] = 0
	end
end

-- 销毁捕鱼游戏管理器
function FishGameController:onDestory()
	print("----------FishGameController:onDestory begin--------------")

	removeMsgCallBack(self, "fish_msg_MSG_GAME_INIT")
	self.m_callBackFuncList = {}
	self.netMsgHandlerSwitch = {}
	
	if self.gameScene then
		self.gameScene:onExit()
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
    TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")

	self:onBaseDestory()
	
	print("----------FishGameController:onDestory end--------------")
end

function FishGameController:ackKickClient()
    self.gameScene.fishMainLayer:unscheduleUpdate()
    removeMsgCallBack(self.gameScene.fishMainLayer, MSG_FUNCSWITCH_UPDATE)
    self.gameScene.fishMainLayer:stopAllTimer() 
    self.gameScene.fishMainLayer.m_bulletManager:removeAlBulletAnimation()
    -- 移除子弹资源
    self.gameScene.fishMainLayer.m_bulletManager:removeBulletResouce()
    self.gameScene:showFishExitGameLayer()
end

function FishGameController:send2GameServer4Fish( __cmdId, __dataTable)
 --   print("send2GameServer4Fish            ",self.m_gameAtomTypeId)
     ConnectManager:send2GameServer( self.m_gameAtomTypeId , __cmdId, __dataTable)
end

--function FishGameController:setEnterGameAckHandler()
--    self:registNetMassege()
--	RoomTotalController:getInstance():setEnterGameAckHandler(handler(self,self.ackEnterGame))
--end

function FishGameController:ackEnterGame( __info )
	print("FishGameController:ackEnterGame") 
	ToolKit:removeLoadingDialog()
	-- 请求进入游戏返回 
		-- 进入游戏成功
	   --ToolKit:removeLoadingDialog()
--    self.m_gameAtomTypeId = __info.m_gameAtomTypeId
--	if tolua.isnull( self.gameScene ) then 
--	    local scenePath = getGamePath(__info.m_gameAtomTypeId)
--        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
--    else
--        self.gameScene:clearFishFishery()
--        self:clearData()
--        self:notifyViewDataAlready()
--    end
	print("fish self.gameScene", self.gameScene)
	dump(__info)
	
	if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then
	    local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
    --else
	--	self.gameScene:clearFishFishery()
    --    self:clearData()
    --    self:notifyViewDataAlready()
    end
end

function FishGameController:ackRealEnterGame( __info )
	print("FishGameController:ackRealEnterGame")
	--ToolKit:removeLoadingDialog()
	-- 请求进入游戏返回 
	-- 进入游戏成功
	-- ToolKit:removeLoadingDialog()
	--[[
	if not self.gameScene then
	    local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
    else
		self.gameScene:clearFishFishery()
        self:clearData()
        self:notifyViewDataAlready()
    end
	--]]
	
	if self.gameScene and __info.m_result == 0 then
		self.gameScene:clearFishFishery()
        self:clearData()
        self:notifyViewDataAlready()
	end
end

--通知快速加入（由EnterScene中带入标记)
function FishGameController:reqFastEnterScene( gameAtomTypeId , isFast )
    local _isFast = isFast or 0
    self:reqEnterScene()
end

-- 通知进入自由房   0:正常进入，1：断线重连 2: 通知快速加入（由EnterScene中带入标记）'},
function FishGameController:notifyEnterFreedomRoomPhone( __info )
    print("FishGameController:notifyEnterFreedomRoomPhone")
    dump( __info )
    if __info.m_result == 0 then
        self.__gameAtomTypeId = __info.m_gameAtomTypeId
        self.m_playerSceneCoin = __info.m_goldCoin
        if __info.m_type == 0 then
			--ToolKit:removeLoadingDialog()
			--sendMsg( FishGlobal.GameMsg.FISH_TOAD_ENTER_ROOM_MSG, __info  )
			sendMsg( FishGlobal.GameMsg.FISH_UPDATE_GOLD_NUM_MSG, __info.m_goldCoin )
		    elseif __info.m_type == 1 then
			if FishGlobal.isShowDesk then
              --ToolKit:removeLoadingDialog()
              --sendMsg( FishGlobal.GameMsg.FISH_TOAD_ENTER_ROOM_MSG, __info  )
              sendMsg( FishGlobal.GameMsg.FISH_UPDATE_GOLD_NUM_MSG, __info.m_goldCoin )
			end
        elseif  __info.m_type == 2 then
            self:reqFastEnterTablePhone()
        end
	else
		FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
	end
end

-- 发送快速加入请求
function FishGameController:reqFastEnterTablePhone()
	  ConnectManager:send2SceneServer( self.__gameAtomTypeId,"CS_C2M_BuYu_FastEnterTablePhone_Req", { self.__gameAtomTypeId ,0 })
end

--0:成功，-1:场景玩家信息不存在,-2:背包没有符合进该房间的炮,-3:该玩家已经在游戏中,-4:座位已经坐满
-- 响应快速加入自由房
function FishGameController:ackFastEnterFreeTablePhone( __info )
   sendMsg( MSG_FISHING_TO_LOBBY_INFO , __info )
	if __info.m_result == 0 then
	  	self.__roomId = __info.m_roomId
	else
		--self:loadingDialogEnd()
		--ToolKit:removeLoadingDialog()
		if __info.m_result == -10022 then    -- 该房间已满
			local scene = display.getRunningScene()
			if scene and scene.__cname == "FishingScene" then
				local __params = { title = "提示" , msg = "该房间人数已满" ,surefunction = function ()  
					self.scene:reqExitGame() 
				end}
				self:showConfirmTips( __params )
				--if self.reconetGameServer then
				--	self.reconetGameServer = false
				--	self:reconnectGameServerEnd()
				--end
			else
				FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
			end
		elseif __info.m_result == -10033 then --房间已销毁
			local scene = display.getRunningScene()
			if scene and scene.__cname == "FishingScene" then
				local __params = { title = "提示" , msg = "该房间已解散" ,surefunction = function ()  
					self.scene:reqExitGame() 
				end}
				self:showConfirmTips( __params )
				--if self.reconetGameServer then
				--	self.reconetGameServer = false
				--	self:reconnectGameServerEnd()
				--end
			else
				FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
			end
		elseif __info.m_result == -10006 then --炮台等级不符
			if not FishingUtil:getInstance():checkIsSelectEx( FishNormalPromptLayer.TipTypeKey.powerLvNotEnough ) then
				sendMsg( FishGlobal.GameMsg.FISH_SHOW_PROMPET_MSG, __info )
			else
				FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
			end
		else
			FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
      end
	end
end

-- 请求刷新桌子列表
function FishGameController:reqRefreshTableList()
     self.reqRefreshTable = true
     ConnectManager:send2SceneServer( self.__gameAtomTypeId ,"CS_C2M_BuYu_RefreshTable_Req", { })
end

-- 通知房间内桌子列表信息
function FishGameController:notifyToadRoomTableList( __info )
    print("FishGameController:notifyToadRoomTableList")
    dump( __info )
    --  __info.m_tableAr
    if  __info.m_nResult == 0 then
        self.onlinePersonNum =  __info.m_nCount
        sendMsg( FishGlobal.GameMsg.FISH_TOAD_UPDATE_ONLINEPERS_MSG, self.onlinePersonNum  )
        if  __info.m_nType == 1 then
            if self.reqRefreshTable then
               self.reqRefreshTable  = false
               TOAST("刷新成功!")
            end
            --ToolKit:removeLoadingDialog()
            self.toadFishTableInfoList = {}
            self.toadFishTableInfoList = __info.m_tableArr
            sendMsg( FishGlobal.GameMsg.FISH_BYDR_UPDATE_TABLE_MSG, self.toadFishTableInfoList  )
        elseif __info.m_nType == 2 then
           print("桌子发生变化")
           for k,tableInfoNew in pairs( __info.m_tableArr) do
               for j,tableInfoOld in pairs( self.toadFishTableInfoList ) do
                  if tableInfoNew.m_tableId == tableInfoOld.m_tableId then
                       self.toadFishTableInfoList[j] = tableInfoNew
                       break
                  end
               end
           end
           sendMsg( FishGlobal.GameMsg.FISH_BYDR_UPDATE_TABLE_MSG, self.toadFishTableInfoList  )
        end
    else
        self.reqRefreshTable  = false
        --ToolKit:removeLoadingDialog()
        if __info.m_nResult == -16058 then 
            local __params = { title = "提示" , msg = "您的信息已经过期,请重新进入桌界面!" ,surefunction = function ()
                               sendMsg( FishGlobal.GameMsg.FISH_EXIT_ROOM_HALL_MSG , {})
                          end}
                          self:showConfirmTips( __params )
        else
            FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_nResult )
        end
    end
end

-- 选定椅子加入桌子
function FishGameController:reqApplyTableChair( __gameAtomTypeId , __tableId , __chairId )
    ConnectManager:send2SceneServer( __gameAtomTypeId,"CS_C2M_BuYu_ApplyTableChair_Req", {  __gameAtomTypeId , 0,__tableId , __chairId ,0,0 ,""  })
end

-- 响应选定椅子加入桌子
function FishGameController:ackApplyTableChair( __info )
    if  __info.m_result == 0 then
        self.__gameAtomTypeId = __info.m_gameAtomTypeId
    else
        --ToolKit:removeLoadingDialog()
        if __info.m_result == -16058 then 
            local __params = { title = "提示" , msg = "您的信息已经过期,请重新进入桌界面!" ,surefunction = function ()
                               sendMsg( FishGlobal.GameMsg.FISH_EXIT_ROOM_HALL_MSG , {})
                          end}
                          self:showConfirmTips( __params )
        else
            FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
        end
    end
end

-- 退出游戏
function FishGameController:reqExitGame( outType )
	ConnectManager:send2SceneServer(self.__gameAtomTypeId, "CS_C2M_BuYu_ExitRoomHall_Req", { self.__gameAtomTypeId, self.__roomId, outType or 0})
end

-- 响应退出游戏
function FishGameController:ackExitFreeRoomHall( __info  )
  print("FishGameController:ackExitFreeRoomHall")
  --dump( __info )
	if __info.m_result == 0 then
      self.m_playerSceneCoin = __info.m_goldCoin
      sendMsg( FishGlobal.GameMsg.FISH_UPDATE_GOLD_NUM_MSG, __info.m_goldCoin )
	else
      FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
	end
end

function FishGameController:onConnectGameServer( msgName , __info )
    self:setEnterGameAck()
--	print("通知连接捕鱼游戏服!")
--	    -- 在连接游戏服之前,创建游戏游戏控制器实例
--    --ToolKit:removeLoadingDialog() 
--    self.roomData  = RoomData:getRoomDataById( __info.m_gameAtomTypeId )
--    local fishRoomData = FishGameDataController:getInstance():getbuyuRoomSettingItemById( __info.m_gameAtomTypeId )
--    if fishRoomData then
--        self.fishRoomType = fishRoomData.nRoomType
--    end
--    if self.roomData  then
--        self.roomType = self.roomData.roomType
--        self.gameKindType = self.roomData.gameKindType
--        if self.gameKindType == FishGlobal.ThousandsGunsKindTypeId then
--            if self.roomType == FishGlobal.RoomType.System   then  -- 千炮捕鱼
--                -- 系统房
--                FishGameController:getInstance():setEnterGameAckHandler() 
--            end

--    end 
end

function FishGameController:getMyChair()
    return self.myChair
end

function FishGameController:getMyViewChair()
	return self.myViewChair
end

function FishGameController:getPlayerInfoByChairId(__chair)
	--dump(self.m_fishPlayerList)
	if self.m_fishPlayerList[__chair ] then
		return self.m_fishPlayerList[__chair ]
	end
	return nil
end

function FishGameController:getPlayerInfoByAccountId(  accountId )
	--print("accountId=",accountId)
	--dump(self.m_fishPlayerList)
	for k,v in pairs( self.m_fishPlayerList ) do
       if v.m_nAccountId == accountId then
          return v
       end
    end
    return nil
end

function FishGameController:getChairByAccountId( accountId )
	return self.m_accountIDChairMap[ accountId ]
end

function  FishGameController:getNativeChairCoinMap()
   return self.m_nNativeChairCoinMap
end

function FishGameController:getNativeCoinByChair(  chair )
   local nativeCoin = 0
   if self.m_nNativeChairCoinMap[ chair ] then
      nativeCoin = self.m_nNativeChairCoinMap[ chair ]
   end
   return nativeCoin
end

function FishGameController:setNativeCoinByChair( chair , coin )
   self.m_nNativeChairCoinMap[ chair ] = coin
end

function FishGameController:checkNativeWithServerCoin( chair )
	local isEqual = true
	local coin = 0
	local nativeCoin = self:getNativeCoinByChair(  chair )
	local fishPalyer = self:getPlayerInfoByChairId( chair )
	if fishPalyer then
       local serverCoin  = fishPalyer:getCoin()
       if serverCoin ~= nativeCoin then
          self:setNativeCoinByChair( chair , serverCoin )
          isEqual = false
       end
       coin = serverCoin
	end
	return isEqual , coin
end

function FishGameController:getNativeGoldByChair(  chair )
	local nativeGold = 0
	if self.m_nativeChairGoldMap[ chair ] then
       nativeGold = self.m_nativeChairGoldMap[ chair ]
	end
	return nativeGold
end

function FishGameController:setNativeGoldByChair( chair , gold )
	self.m_nativeChairGoldMap[ chair ] = gold
end

function FishGameController:checkNativeWithServerGold( chair )
    local isEqual = true
	local gold = 0
	local nativeGold = self:getNativeGoldByChair(  chair )
	local fishPalyer = self:getPlayerInfoByChairId( chair )
	if fishPalyer then
       local serverGold  = fishPalyer:getGoldIngot()
       if serverGold ~= nativeGold then
          self:setNativeGoldByChair( chair , serverGold )
          isEqual = false
       end
       gold = serverGold
	end
	return isEqual , gold
end

function FishGameController:getCannonList()
   return self.m_keepCannons
end

function FishGameController:getGameSceneIndex()
	return self.m_gameSceneIndex
end

function FishGameController:isNeedWave()
	return self.m_isNeedWave
end

function FishGameController:setNeedWave( isNeed )
	self.m_isNeedWave = isNeed 
end
 
--[[
function FishGameController:getGameAtomTypeId()
	return self.m_gameAtomTypeId
end

function FishGameController:getClubId()
	return self.m_clubId
end
--]]

function FishGameController:onCloseConnet()
	if not tolua.isnull( self.gameScene ) then
       if not tolua.isnull( self.gameScene.fishMainLayer ) then
          self.gameScene.fishMainLayer:stopAllTimer()
       end
	end
end 

function FishGameController:netMsgHandler(__idStr, __info )
	print("FishGameController -------------",__idStr, "\n")
  if  self.m_callBackFuncList[__idStr]  then
	__info.m_nClockTime = os.clock();
	if self.gameScene.m_bIsInit then 
		(self.m_callBackFuncList[__idStr])(__info)
	else
		self.m_pNetMsgData = self.m_pNetMsgData or {}
		
		table.insert(self.m_pNetMsgData, {__idStr, __info})
	end
      
  else
      print("没有处理消息",__idStr)
  end
end

-- 通知服务器初始化视图资源成功
function FishGameController:notifyViewDataAlready()
   print("通知服务器初始化视图资源成功")
   self:send2GameServer4Fish("CS_C2G_BuYu_Request_Nty",{})
end
 

-- 游戏后台切换:0.从后台切换到前台,开放协议发送; 1.从前台切换到后台,关闭协议发送
function FishGameController:notifyDisableGameMsg( __type  )
	self:send2GameServer4Fish("CS_C2G_BuYu_Disable_Msg_Nty",{ __type })
end

-- 更新玩家数据
function FishGameController:notifyPlayerdatas( __info )
    -- 首先筛选出自己的椅子号
    print("FishGameController:notifyPlayerdatas")
	dump( __info )

	if __info.m_vecPlayerData then
		for k, v in pairs(__info.m_vecPlayerData) do
			if v.m_nAccountId == Player.getAccountID() then
				FishGlobal.myChair = v.m_nChair
				FishGlobal.myViewChair = FishGlobal.getViewChair(FishGlobal.myChair)
				self.m_sRecordID = v.m_recordId or ""
				self.gameScene.fishMainLayer:setRecordID(self.m_sRecordID)
				break
			end
		end
	end

    for i = 1 , FishGlobal.PlayerCount do 
	    local playerHaveInC = 0 
	    local playerHaveInS = 0
	    local fishPlayer = nil
	    local isHost = false
	    --检测玩家是否在本地客户列表中
	    if self.m_fishPlayerList[i] then
	       fishPlayer = self.m_fishPlayerList[i]
	       playerHaveInC = 1
	    end
	      --检测玩家是否在服务器消息列表中
	    for k,v in pairs(__info.m_vecPlayerData) do
	      if v.m_nChair == i then
	      	playerHaveInS = 1
	      	if not fishPlayer then
               fishPlayer = FishingPlayer.new()
               self.m_fishPlayerList[i] = fishPlayer
	      	end
	      	
	      	fishPlayer:initFishPlayer( v )
	      	local viewChair =FishGlobal.getViewChair( i )
            fishPlayer:setViewChair( viewChair )
            if v.m_nAccountId == Player.getAccountID() then
               isHost = true
			   self:calulateLevelIndexByLevel( v.m_nLevel )
            end
            fishPlayer:setHost( isHost )
	        break
	      end
	    end  
	   
	    if playerHaveInC == 0 and playerHaveInS == 1 then         --不在本地客户端列表，在服务器消息列表，则判断为进来
	       self.m_nNativeChairCoinMap[ i ] = fishPlayer:getCoin() -- 初始化本地金币
	       self.m_nativeChairGoldMap[ i ] = fishPlayer:getGoldIngot()
	       self.m_accountIDChairMap[ fishPlayer:getAccount() ] = i
           if not tolua.isnull( self.gameScene ) then
	          self.gameScene:onUserEnter(i,fishPlayer)
	       end
	    elseif playerHaveInC == 1 and playerHaveInS == 0 then    --在本地客户端列表，不在服务器消息列表，则判断为离开
           if not tolua.isnull( self.gameScene ) then
	          self.gameScene:onUserLeave(i, self.m_fishPlayerList[i] )
	       end
	       self.m_fishPlayerList[i] = nil
	       self.m_accountIDChairMap[ fishPlayer:getAccount() ] = nil 
	    elseif playerHaveInC == 1 and playerHaveInS == 1 then    -- 刷新玩家信息
            local isEqual , coin = self:checkNativeWithServerCoin( i )
            if not tolua.isnull( self.gameScene ) then 
	           self.gameScene.fishMainLayer:refreshUserView( fishPlayer )
	           if FishGameDataController:getInstance():coinEffectIsFinished( i ) then
					local isEqual , coin = self:checkNativeWithServerCoin( i )
					if coin >= 0 then
					   self.gameScene.fishMainLayer:updatePlayerGoldView( fishPlayer:getViewChair() , coin )
					end
               end
      --          if self.gameScene.m_Acer ==  FishGlobal.isDropAcer then
	     --           if FishGameDataController:getInstance():goldEffectIsFinished( i ) then
	     --                local isEqual , gold = self:checkNativeWithServerGold( i )
						-- if gold >= 0 then
						--    self.gameScene.fishMainLayer:updatePlayerYbView( fishPlayer:getViewChair() , gold )
						-- end
	            --   end
	           -- end
	        end

        elseif playerHaveInC == 0 and playerHaveInS == 0 then    
	    end
	 end
   self:initLockFishOpers()
end



-- 刚进入游戏，初始化所有鱼的信息
function FishGameController:notifyFishDatas( __info )
	--print("刚进入游戏，初始化所有鱼的信息")
   --  self.gameScene:initSceneFishMsg(__info)
	if not tolua.isnull( self.gameScene ) then
       print("刚进入游戏，初始化所有鱼的信息")
       self.gameScene:initSceneFishMsg(__info)
	end	
end

-- 刷新技能状态信息
function FishGameController:notifySkillInfo( __info )
	print("刷新技能状态信息")
	--dump( __info )
	local time =  self:getTime(__info.m_nClockTime, __info.m_nTime);
	for k,v in pairs(__info.m_vecSkillCdData) do
	    local buyuItem = FishGameDataController:getInstance():getSkillDataByIndex( v.m_nIndex )
	    local _skillData = FishSkillManager:getInstance():getSkillDataBySkillType( buyuItem.nType, FishGlobal.myViewChair )
	    dump( _skillData )
	    local leftTime = v.m_nCd - time
        local per = 0
        if leftTime <= 0 then
           per = 100
           leftTime = 0
        else
           local passTime = _skillData.m_skillCD - leftTime
           per = passTime / _skillData.m_skillCD * 100
        end
        if not tolua.isnull( self.gameScene ) then
       	  	 self.gameScene.fishMainLayer:skillProgress(buyuItem.nType, per, leftTime )
        end
	end
end

function FishGameController:notifyPowerLevelList( __info )
   print("notifyPowerLevelList")
   --dump(__info)
   self.m_powerInfoList = {}
   self.m_powerInfoList = __info.m_vecPowerInfoList
   if next( self.m_powerInfoList ) then
      table.sort( self.m_powerInfoList ,function(v1, v2) return v1.m_nPowerLevel < v2.m_nPowerLevel  end  )
   end
end


-- 通知完成的任务Id
function FishGameController:notifyTaskId( __info )
	--print("通知完成的任务Id")
	--print("FishGameController:notifyTaskId")
	--dump( __info )
	-- if self.isTaskInited then
 --       if not tolua.isnull( self.gameScene ) then
 --          if __info.m_nTaskID > self.taskId then 
 --             self.gameScene:showPowerUpLevelTips( self.taskId )
 --            -- FishGameController:getInstance():reqActiveTaskAward( {} )
	--       elseif __info.m_nTaskID == self.taskId then  
	--       	  local taskDataMax = FishGameDataController:getInstance():getTakeDataByTaskId( self.taskId  )
	--       	  if taskDataMax and taskDataMax.NextTaskID == 0 then -- 最后一个任务
 --                  if __info.m_nTaskProcess >= taskDataMax.nParam2 then
 --                     self.gameScene:showPowerUpLevelTips( self.taskId )
 --                  end
	--       	  end
	--       end	
 --       end
	-- end
 --    self.isTaskInited = true
	-- self.taskId = __info.m_nTaskID
	-- self.m_nTaskProcess = __info.m_nTaskProcess 
 --    local taskData = FishGameDataController:getInstance():getTakeDataByTaskId( self.taskId  )
 --    local _score = FishGameDataController:getInstance():getPowerScoreByLevel( taskData.nLevel )
 --    local info = {
 --                     score    = _score,
 --                     taskName = taskData.szDisc,
 --                     percen   = (self.m_nTaskProcess / taskData.nParam2) * 100,
 --                     taskPro  = self.m_nTaskProcess,
 --                     totalTask= taskData.nParam2,
 --                     taskType = taskData.nType,
 --                     fishType = taskData.nParam1,
 --                 }
 --    if not tolua.isnull( self.gameScene ) then
 --       self.gameScene.fishMainLayer:refreshTaskView( info )
	-- end	
	-- -- 判断是否已经升到最大任务
	-- if taskData.NextTaskID == 0 then
	--    if not tolua.isnull( self.gameScene ) then
	--    	   if self.m_nTaskProcess >= taskData.nParam2 then
 --              self.gameScene.fishMainLayer:setUpgradNodeVisble( false )
 --           end
	--    end	
	-- end
end

-- 通知游戏场景(渔场背景)变化
function FishGameController:notifyFishery( __info )
	print("---------------通知游戏场景(渔场背景)变化---------------")
	dump(__info)
	if self.m_gameSceneIndex ~= __info.m_nSceneIndex then
       self:setNeedWave( true )
	else
       self:setNeedWave( false )
	end
	self.m_gameSceneIndex = __info.m_nSceneIndex
	if not tolua.isnull( self.gameScene ) then
	   if not tolua.isnull( self.gameScene.m_background ) then
          self.gameScene.m_background:setBG( __info.m_nSceneIndex )
       end
    end
end

-- 刷新鱼的buff
function FishGameController:notifyBuffList( __info )
	for k,v in pairs( __info.m_vecBuffList ) do
		local glpos = cc.Director:getInstance():convertToGL( cc.p( v.m_nX * display.scaleX ,  v.m_nY * display.scaleY ) )
		local currentPos = FishGlobal.convertFishPostion( glpos )
		local buffParams = {  
	                           accountID = v.m_nAccountId,
	                           buffIndex = v.m_nEffectIndex,    
	                           buffType  = v.m_nEffectType,
	                           fishIndex = v.m_nIndex,
	                           pos       = currentPos,
	                           coin      = 0,
	                           randScore = 0,
	                           isVisible = true,
                           }
        if not tolua.isnull( self.gameScene ) then
           self.gameScene:playFishBuff( buffParams )
        end
	end
end


function FishGameController:getTaskProcess()
   return  self.m_nTaskProcess
end


function  FishGameController:addCannon(__info)
	if not __info then return end
	table.insert(self.m_keepCannons, __info)
    table.sort(self.m_keepCannons,function(v1,v2) return v1.level < v2.level end)
end


-- 切换高倍数的炮
function FishGameController:addPowerLevelIndex()
   local isCanChange = false
   if #self.m_powerInfoList == 1 then
      TOAST("当前无其它可用炮台倍数!")
      return isCanChange 
   end
   self.m_currentLevelIndex = self.m_currentLevelIndex + 1
   if self.m_currentLevelIndex > #self.m_powerInfoList then
	   self.m_currentLevelIndex = 1
   end
   isCanChange = true
   return isCanChange 
end

-- 切换底倍数的炮
function FishGameController:decPowerLevelIndex()
	local isCanChange = false
	if #self.m_powerInfoList == 1 then
      TOAST("当前无其它可用炮台倍数!")
      return isCanChange
    end
	self.m_currentLevelIndex = self.m_currentLevelIndex - 1
    if self.m_currentLevelIndex < 1 then
       self.m_currentLevelIndex = #self.m_powerInfoList
    end
    isCanChange = true
    return isCanChange
end

-- 获得开放等级
function FishGameController:getOpenLevel()
	local level = 0
	if self.m_powerInfoList[ self.m_currentLevelIndex ] then
		local powerInfo = self.m_powerInfoList[ self.m_currentLevelIndex ]
		level = powerInfo.m_nPowerLevel
	end
	return level
end

-- 根据炮的等级计算出当前等级索引值
function FishGameController:calulateLevelIndexByLevel( level )
	--print("level=",level)
	--print("calulateLevelIndexByLevel")
	--dump( self.m_powerInfoList )
    for i,v in ipairs( self.m_powerInfoList ) do
    	if v.m_nPowerLevel == level then
           self.m_currentLevelIndex = i
           break
    	end
    end
end


function FishGameController:getCannonItemByItemInBag( itemId)
	local powerItem = nil
	for k,v in pairs( self.m_keepCannons ) do
		if v.itemId  == itemId then
           powerItem = v
           break
		end
	end
	return powerItem
end

-- 通过等级来查找炮的id
function FishGameController:getPowerItemIdByLevel( __level )
	local powerItemId = 0
	for k,v in pairs( self.m_keepCannons ) do
		if v.level  == __level then
           powerItemId = v.itemId
           break
		end
	end
    return powerItemId
end


function FishGameController:initSkillItemList( vecItem )
	self.m_skillItems = {}
	for i,v in ipairs( vecItem ) do
		if FishGameDataController:getInstance():isThisItemType(v.m_nItemID,self.itemType.SKILL_ITEM_TYPE ) then
		   local itemInfo  = { itemId =v.m_nItemID, nType = self.itemType.SKILL_ITEM_TYPE , count = v.m_nCount}
		   table.insert( self.m_skillItems , itemInfo)
         end
	end
end

function FishGameController:getSkillItemCountByitemId( itemId )
	local count = 0
	for i,v in ipairs( self.m_skillItems ) do
		if v.itemId == itemId then
           count = count + v.count
		end
	end
	return count
end

-- 根据技能类型，获取该技能道具的数量
function FishGameController:getSkillItemCountByType( __type )
	local count = 0
	if self.m_skillItemCounts[ __type ] then
       count = self.m_skillItemCounts[ __type ]
	end
	return count
end

-- 更新背包
function  FishGameController:notifyUpdateBag( __info )
	for k,v in pairs(__info.m_vecItem) do
		--local info = json.decode(v.m_szExtend)
	    local powerItem = FishGameDataController:getInstance():getCannonByItemId( v.m_nItemID )
		if powerItem then--这是炮,接收完成后，初始化并通知服务器
		   self:addCannon({ index = v.m_nID, itemId = v.m_nItemID, itemType = self.itemType.POER_TYPE, level = powerItem.nLevel, name = powerItem.szName})
		end
    end
    -- 初始化技能物品数量 
    self:initSkillItemList( __info.m_vecItem )
    self:refreshSkillCountView()
    self:initLockFishOpers()
end

-- 刷新技能个数
function FishGameController:refreshSkillCountView()
	local  buyuSkill = FishGameDataController:getInstance():getBuyuSkillDataList()
	if not tolua.isnull( self.gameScene ) then
		for k,v in pairs( buyuSkill ) do
			local itemCount = self:getSkillItemCountByitemId( v.nItemId )
			self.m_skillItemCounts[ v.nType ] = itemCount
			self.gameScene.fishMainLayer:setSkilItemCountBySkillType( v.nType , itemCount )
		end
	end
end


-- 捕鱼消息广播,1 本桌 2 房间,3 全服
function FishGameController:notifyBroadcast( __info )
	--print("FishGameController:notifyBroadcast")
	--dump( __info )
    local coin = __info.m_nParam1*0.01
	if not tolua.isnull( self.gameScene ) then
	   local message = ""
	   local fishData = FishGameDataController:getInstance():getFishDataByType( __info.m_nParam2 )
	   local fishName = ""
	   if fishData then
	   	  fishName = fishData.fishCnName
	   end
       local elementAtrTable = {}
	   if __info.m_nBroadcastType == 1 then
	   	    if  fishData.nType == FishModel.FINGERLING.ITEM_FISH_TYPE then
	   	        --message = string.format("恭喜%s捕获%s!",__info.m_szName, fishName)
	   	        elementAtrTable = {  
	                                  [1] = {  color = cc.c3b(255,255,255) , fontName="Helvetica", text="恭喜" ,fontSize = 24,} ,
	                                  [2] = {  color = cc.c3b(246,255,0) ,   fontName="Helvetica", text=__info.m_szName,fontSize = 24, },
	                                  [3] = {  color = cc.c3b(255,255,255) , fontName="Helvetica",text="捕获",fontSize = 24, },
	                                  [4] = {  color = cc.c3b(246,255,0) ,   fontName="Helvetica",text= fishName,fontSize = 24,}
	   	                          }
	   	    elseif  fishData.nType == FishModel.FINGERLING.REDPACKET_FISH_TYPE then
	   	    	--新年好运滚滚来！恭喜XXXX（玩家名字）使用XXXX倍炮喜获XXX分红包
	   	    	local message_1 = string.format(",使用%d倍炮喜获",__info.m_nParam5)
	   	    	local rmb = __info.m_nParam4/100
	   	    	elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text="新年好运滚滚来！恭喜",fontSize = 24, } ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",   text=__info.m_szName,fontSize = 24, },
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= message_1 ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= rmb,fontSize = 24,},
	                                  [5] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= "元红包!",fontSize = 24,},
	   	                          }  

	   	    else
	   	       elementAtrTable = {  
	                                  [1] = {  color = cc.c3b(255,255,255) , fontName="Helvetica",text="恭喜",       fontSize = 24, } ,
	                                  [2] = {  color = cc.c3b(246,255,0) ,   fontName="Helvetica",text=__info.m_szName,fontSize = 24, },
	                                  [3] = {  color = cc.c3b(255,255,255) , fontName="Helvetica",text="捕获" ,      fontSize = 24,},
	                                  [4] = {  color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= fishName,   fontSize = 24,},
	                                  [5] = {  color = cc.c3b(255,255,255) , fontName="Helvetica",text= ",赚取了",   fontSize = 24,},
	                                  [6] = {  color = cc.c3b(246,255,0) ,   fontName="Helvetica",text= coin.."金币!",fontSize = 24,},
	   	                          }
                --message = string.format("恭喜%s捕获%s,赚取了%d金币!",__info.m_szName, fishName ,__info.m_nParam1)
	   	    end
	   elseif __info.m_nBroadcastType ==  2 then
	   	     --print("__info.m_nBroadcastType ==  2")
	   	    if  fishData.nType == FishModel.FINGERLING.ITEM_FISH_TYPE then
	   	        --message = string.format("人品爆棚！恭喜威武霸气的%s,捕获%s!",__info.m_szName, fishName)
	   	        elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica",text="人品爆棚！恭喜威武霸气的",fontSize = 24, } ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text=__info.m_szName ,fontSize = 24,},
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica",text=",捕获" ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text= fishName.."!",fontSize = 24,},
	   	                          }
            else
            	 elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text="人品爆棚！恭喜威武霸气的" ,fontSize = 24,} ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text=__info.m_szName ,fontSize = 24,},
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica",text=",捕获" ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= fishName,fontSize = 24,},
	                                  [5] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= ",赚取了",fontSize = 24,},
	                                  [6] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text= coin.."金币!",fontSize = 24,}
	   	                          }
                --message = string.format("人品爆棚！恭喜威武霸气的%s,捕获%s赚取了%s金币!",__info.m_szName, fishName ,__info.m_nParam1)
            end
            
	   elseif __info.m_nBroadcastType ==  3 then 
	   	    local goodItem =  FishGameDataController:getInstance():getItemByIndex( __info.m_nParam3 )
	   	    if goodItem then
               -- message = string.format("深海一声巨响,%s闪亮登场！恭喜%s捕获宝箱获得了%sX%s!!!",__info.m_szName,__info.m_szName, goodItem.name ,__info.m_nParam4 )
               if goodItem.nType == FishGlobal.itemType.IPHONE_TYPE then -- iphonex碎片
               	  elementAtrTable = {  
		                                  [1] = {  color = cc.c3b(255,255,255), fontName="Helvetica", text="深海一声巨响," ,fontSize = 24,} ,
		                                  [2] = {  color = cc.c3b(246,255,0)  , fontName="Helvetica",   text=__info.m_szName ,fontSize = 24,},
		                                  [3] = {  color = cc.c3b(255,255,255), fontName="Helvetica", text="闪亮登场!恭喜" ,fontSize = 24,},
		                                  [4] = {  color = cc.c3b(246,255,0)  , fontName="Helvetica",   text= __info.m_szName,fontSize = 24,},
		                                  [5] = {  color = cc.c3b(255,255,255), fontName="Helvetica", text= "捕获宝箱获得了",fontSize = 24,},
		                                  [6] = {  color = cc.c3b(246,255,0)  , fontName="Helvetica", text= goodItem.name.."x"..__info.m_nParam4.."!!!",fontSize = 24,},
		   	                          }

               elseif goodItem.nType == FishGlobal.itemType.YUNBAO_TYPE then       -- 元宝
                    local message_1 = string.format(",使用%d倍炮捕获",__info.m_nParam5)
	           	    elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text="神龟一吼,宝箱颤抖!恭喜",fontSize = 24, } ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",   text=__info.m_szName,fontSize = 24, },
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= message_1 ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= fishName,fontSize = 24,},
	                                  [5] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= ",获得",fontSize = 24,},
	                                  [6] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= __info.m_nParam4..goodItem.name.."!!!",fontSize = 24,}
	   	                          }
               elseif goodItem.nType == FishGlobal.itemType.REDPACKET_TYPE then -- 红包
               	   local message_1 = string.format(",使用%d倍炮喜获",__info.m_nParam5)
               	   local rmb = __info.m_nParam4/100
                   elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text="新年好运滚滚来！恭喜",fontSize = 24, } ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",   text=__info.m_szName,fontSize = 24, },
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= message_1 ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= rmb,fontSize = 24,},
	                                  [5] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= "元红包!",fontSize = 24,},
	   	                            }  
               elseif goodItem.nType == FishGlobal.itemType.HUIFEI_TYPE then
                    elementAtrTable = {  
	                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica",text="人品爆棚！恭喜威武霸气的",fontSize = 24, } ,
	                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text=__info.m_szName ,fontSize = 24,},
	                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica",text=",捕获" ,fontSize = 24,},
	                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",text= fishName.."!",fontSize = 24,},
	   	                          }
               end
            else   
        	   local message_1 = string.format(",使用%d倍炮捕获",__info.m_nParam5)
   	           elementAtrTable = {  
                                  [1] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text="人品爆棚！恭喜威武霸气的",fontSize = 24, } ,
                                  [2] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica",   text=__info.m_szName,fontSize = 24, },
                                  [3] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= message_1 ,fontSize = 24,},
                                  [4] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= fishName,fontSize = 24,},
                                  [5] = { color = cc.c3b(255,255,255) , fontName="Helvetica", text= ",赚取了",fontSize = 24,},
                                  [6] = { color = cc.c3b(246,255,0) ,   fontName="Helvetica", text= coin.."金币!",fontSize = 24,}
   	                          }
            end

	   end
       --self.gameScene.m_noticeLayer:playNotice( message )
       self.gameScene.m_noticeLayer:playRichNotice(  elementAtrTable )
	end
end

-- 驱赶鱼，准备出鱼阵
function  FishGameController:notifyExpel( __info )
    if not tolua.isnull( self.gameScene ) then
       self.gameScene:onDriveFish( __info )
    end
end

-- 出鱼
function  FishGameController:notifyOutFish( __info )
	--print("出鱼")
    if not tolua.isnull( self.gameScene ) then
       self.gameScene:outFishs( __info )
	  end
end

-- 鱼阵结束
function  FishGameController:notifyArmyOver( __info )
   --print("鱼阵结束")
end


-- 请求换炮使用的等级
function FishGameController:reqChangePower(  __level )
	--print("请求换炮使用的等级")
	self:send2GameServer4Fish("CS_C2G_BuYu_Change_Level_Nty",{ __level })
end

-- 换炮的等级返回
function FishGameController:notifyChangePower( __info ) 
	local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	local powerItem  =  FishGameDataController:getInstance():getCannonByItemId( __info.m_nPItemID )
	if  fishPlayer  then
	    fishPlayer:setPowerItemID( __info.m_nPItemID )
	    fishPlayer:setPowerLevel( __info.m_nLevel )
	    if __info.m_nAccountID == Player.getAccountID() then
	       self:calulateLevelIndexByLevel( __info.m_nLevel )
	    end
	end
	if not tolua.isnull( self.gameScene ) then
		if fishPlayer then
	      --  self.gameScene.fishMainLayer:changeCannon(fishPlayer:getViewChair() , __info.m_nPItemID , true )
	        local score = FishGameDataController:getInstance():getPowerScoreByLevel( __info.m_nLevel )
	        self.gameScene.fishMainLayer:showOpenLevel(fishPlayer:getViewChair() , score )
	    end
    end
end

-- 请求发炮
function FishGameController:reqFire( __info )
	--print("请求发炮") 
	self:send2GameServer4Fish("CS_C2G_BuYu_Fire_Nty", __info )
end

-- 发炮
function FishGameController:notifyFire( __info )
  if FishGlobal.NoNetTest then return end
	--print("发炮")
	--dump( __info ) 
	local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	local chair = 0
	if fishPlayer then
       fishPlayer:setnCoin( __info.m_nCoin*0.01 )
       chair = fishPlayer:getChair()
	end

	local powerScore = FishGameDataController:getInstance():getPowerScoreByLevel( __info.m_nLevel )
    local costCoin = 0
    local nativeCoin = 0
    if  powerScore then
        costCoin = powerScore * __info.m_nStep*0.01
        nativeCoin = self:getNativeCoinByChair(  chair )
        if nativeCoin then
           nativeCoin = nativeCoin - costCoin
           self:setNativeCoinByChair(chair  , nativeCoin )
        end
    end
    
    if FishGameDataController:getInstance():coinEffectIsFinished( chair ) then
        local isEqual , coin = self:checkNativeWithServerCoin( chair )
        if not isEqual then
           nativeCoin = coin
        end
    end
   
	if not tolua.isnull( self.gameScene ) then
       self.gameScene:netFireMsg( __info )
       if fishPlayer then
       	  if nativeCoin >= 0 then
             self.gameScene.fishMainLayer:updatePlayerGoldView( fishPlayer:getViewChair() ,  __info.m_nCoin*0.01 )
          end
       end
    end
end

-- 同步玩家金币
function FishGameController:synPlayersCoin()
	--print("FishGameController:synPlayersCoin")
	for k,v in pairs( self.m_fishPlayerList ) do
        if FishGameDataController:getInstance():coinEffectIsFinished( v.m_chairId ) then
        	--print("同步玩家金币")
            local isEqual , coin = self:checkNativeWithServerCoin( v.m_chairId )
            local fishPlayer = self:getPlayerInfoByAccountId( v.m_nAccountId )
	        if fishPlayer then
	       	  	if not tolua.isnull( self.gameScene ) then
	       	  	  	if  coin >= 0 then
	                   self.gameScene.fishMainLayer:updatePlayerGoldView( fishPlayer:getViewChair() , coin )
	                end
	            end
	        end
        end        
    end
end

-- 同步玩家元宝
function FishGameController:synPlayersGold()
	for k,v in pairs( self.m_fishPlayerList ) do
        if FishGameDataController:getInstance():goldEffectIsFinished( v.m_chairId ) then
        	--print("同步玩家元宝")
            local isEqual , gold = self:checkNativeWithServerGold( v.m_chairId )
       	  	if not tolua.isnull( self.gameScene ) then
       	  	  	if  gold >= 0 then
                   self.gameScene.fishMainLayer:updatePlayerYbView( v.m_viewChairId , gold )
                end
            end
        end        
    end
end

--金币返还
function FishGameController:notifyTunpaoReturnback( __info )
	--print("金币返还")
	--print("FishGameController:notifyTunpaoReturnback")
	--dump( __info )
    local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	local chair = 0
	if fishPlayer then
	    fishPlayer:setnCoin( fishPlayer:getCoin() + __info.m_nCoin*0.01 )
	    chair = fishPlayer:getChair()
	    local nativeCoin = self:getNativeCoinByChair(  chair )
		if nativeCoin then
		   nativeCoin = nativeCoin + __info.m_nCoin
		   self:setNativeCoinByChair(chair  , nativeCoin )
		end

        if FishGameDataController:getInstance():coinEffectIsFinished( chair ) then
            local isEqual , coin = self:checkNativeWithServerCoin( chair )
            if not isEqual then
               nativeCoin = coin
            end
        end

	    if not tolua.isnull( self.gameScene ) then
	       if nativeCoin >= 0 then
	          self.gameScene.fishMainLayer:updatePlayerGoldView( fishPlayer:getViewChair() ,  __info.m_nCoin*0.01 )
	       end
	    end
    end
end

-- 请求捕鱼
function FishGameController:reqGetFish( __info )
  --print("FishGameController:reqGetFish===============")
  --dump( __info )
	self:send2GameServer4Fish("CS_C2G_BuYu_Get_Nty", __info )
end

-- 广播捕到鱼消息
function FishGameController:notifyKillFish( __info )
	print( "广播捕到鱼消息" )
	--dump( __info )
  local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	if fishPlayer then
       fishPlayer:setnCoin( __info.m_nCoin*0.01 )
      -- fishPlayer:setGoldIngot( __info.m_nAcer/10 )
	end

	if not tolua.isnull( self.gameScene ) then
       self.gameScene:killFishMsg( __info )
    end
end

-- 询问客户端当前鱼池数量
function FishGameController:notifyAskForFishCount( __info ) 
    local fishCount = 0
    if not tolua.isnull( self.gameScene )then
       fishCount = self.gameScene:getFishCount()
    end
    self:reportFishNumber( fishCount )
end      

-- 汇报当前鱼的数量
function FishGameController:reportFishNumber(__fishCount )
	--print("汇报当前鱼的数量")
	self:send2GameServer4Fish("CS_C2G_BuYu_Report_Nty", { __fishCount } )
end


-- 请求使用技能
function FishGameController:reqUseSkill( __index )
	--print("请求使用技能")
    local variable = __index
	self:send2GameServer4Fish("CS_C2G_BuYu_Skill_Req", { __index } )
end

-- 响应使用技能 0为成功，-1 cd未到 -2 鱼镇即将来临 -3 未找到道具'
function FishGameController:ackUseSkill( __info )
	--print("ackUseSkill")
	--dump( __info )
    if __info.m_nResult == 0 then
       local buyuItem = FishGameDataController:getInstance():getSkillDataByIndex( __info.m_nIndex )
       if buyuItem then
       	  local skilData = {
                             m_isOpen    = true,
                             m_skillType = buyuItem.nType,
                             m_skillCD   = self:getTime(__info.m_nClockTime, __info.m_nTimeOut);
                           }
          local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
          local viewChair = 1
          if  fishPlayer then
              viewChair  = fishPlayer:getViewChair()
          end
       	  FishSkillManager:getInstance():setSkillDataBySkillType(buyuItem.nType, viewChair , skilData )
       	 
       	  if not tolua.isnull( self.gameScene ) then
       	  	 self.gameScene.fishMainLayer:skill(buyuItem.nType , viewChair  )
       	  	 if viewChair == FishGlobal.myViewChair then
       	  	    self.m_skillItemCounts[ buyuItem.nType ] = __info.m_nNum
       	  	    self.gameScene.fishMainLayer:setSkilItemCountBySkillType( buyuItem.nType , __info.m_nNum )
       	  	 end
          end
       end
    else
    	FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_nResult )
    end
end

-- 请求buff 是否对鱼造成伤害
function FishGameController:reqBuffGet( __info )
	  print("请求buff 是否对鱼造成伤害")
   -- dump( __info )
    self:send2GameServer4Fish("CS_C2G_BuYu_Buff_Get_Req", __info )
end

-- 响应buff 作用效果
function FishGameController:ackBuffGet( __info )
	print("响应buff 作用效果")
  --dump( __info )
	if __info.m_nResult == 1 then
		local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	    if fishPlayer then
           fishPlayer:setnCoin( __info.m_nCoin*0.01 )
	    end
	    if not tolua.isnull( self.gameScene ) then
          local totalCoin = 0
          local totalCount= 0
          for i,v in ipairs( __info.m_vecAddCoin ) do
          	  totalCoin = totalCoin + v
              totalCount =  totalCount + 1
          end
          __info.m_totalCoin = totalCoin 
          __info.m_tatalCount =  totalCount
          self.gameScene:showBuffTurnDisc( __info )
          for i,v in ipairs( __info.m_vecIndex ) do
              local info = { m_nIndex = v, m_nEffectIndex = __info.m_nEffectIndex, m_nCoin = __info.m_nCoin, m_nAddCoin = __info.m_vecAddCoin[i] , m_nAccountID = __info.m_nAccountID }
              self.gameScene:buffKillFishMsg( info )
          end
	    end
    elseif __info.m_nResult == 0 then
       if not tolua.isnull( self.gameScene ) then
       	  self.gameScene:stopBuffEffect( __info )
       end
    end
end

-- 发送聊天信息
function FishGameController:reqChat( __info )
	--print("发送聊天信息")
    self:send2GameServer4Fish("CS_C2G_BuYu_Chat_Nty", __info )
end

-- 聊天信息内容
function FishGameController:notifyChat( __info )
    print("聊天信息内容")
    dump( __info )
    local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
    local viewChair = 0
    local chair = 0 
    if fishPlayer then
       viewChair = fishPlayer:getViewChair()
       chair = fishPlayer:getChair()
    end

    if not tolua.isnull( self.gameScene ) then
       if __info.m_nChatType == FishGlobal.chatType.text then -- 文字
          self.gameScene.m_fishChatSystemLatyer:showMessage( viewChair, __info.m_szMsg )
       elseif __info.m_nChatType == FishGlobal.chatType.magicAni then
       	   if __info.m_nResult == 0 then
       	   	    if __info.m_nItemCoin > 0 then
		       	   	if fishPlayer then
		               fishPlayer:setnCoin( __info.m_nCoin *0.01)
		       	    end
		       	    local  nativeCoin = self:getNativeCoinByChair(  chair )
				    if nativeCoin then
				       nativeCoin = nativeCoin - __info.m_nItemCoin
				       self:setNativeCoinByChair( chair  , nativeCoin )
				    end
			    
				    if FishGameDataController:getInstance():coinEffectIsFinished( chair ) then
				        local isEqual , coin = self:checkNativeWithServerCoin( chair )
				        if not isEqual then
				           nativeCoin = coin
				        end
				    end
				    if fishPlayer then
			       	   if nativeCoin >= 0 then
			              self.gameScene.fishMainLayer:updatePlayerGoldView( fishPlayer:getViewChair() , nativeCoin )
			           end
	                end
				end
	            self.gameScene.m_fishChatSystemLatyer:onHandleAmusingByServer(  __info.m_szMsg )
           elseif __info.m_nResult == -10013 then
              --TOAST("您的金币不足,无法使用魔法表情,请前往商城充值!")
              self.gameScene.fishMainLayer:showBuyGoldTips()
           end
       end
    end
end

function FishGameController:notifyEmojiFreeTimes( __info )
	print("FishGameController:notifyEmojiFreeTimes")
	dump( __info )
    self.m_emojiFreeTimes = __info.m_nCount
    self.m_emojiCoin = __info.m_nItemCoin
    if not tolua.isnull( self.gameScene ) then
    	if not tolua.isnull( self.gameScene.m_fishPlayerInfoLayer  ) then
           self.gameScene.m_fishPlayerInfoLayer:updateEnjoyAinView( self.m_emojiFreeTimes )
        end
    end
end

-- 商品购买
function FishGameController:reqBuyGoods( __info )
	--print("商品购买")
	self:send2GameServer4Fish("CS_C2G_BuYu_BuyItem_Req", __info )
end
 
-- 退出游戏的通知,1 炮倍数不足最低倍数 2 维护踢人 3.子弹发射频率异常踢人
function FishGameController:notifyKickGameOut(  __info )
	local tips = ""
	if __info.m_nOutType == 1 then
		tips = "炮倍数不足房间最低倍数,请退出游戏!"
		if  not tolua.isnull( self.gameScene ) then
		    local fishPlayer = self:getPlayerInfoByChairId( FishGlobal.myChair )
			local goodItem =  FishGameDataController:getInstance():getGoodsItemDataByItemId( fishPlayer:getPowerItemID() )
			if goodItem then
               self.gameScene:showShopBuyConfirmLayer( FishGlobal.BUYTYPE.expire , goodItem.nIndex )
            end
		end
    else 
        if __info.m_nOutType == 2  then
           tips = "游戏进入维护状态,请退出游戏!"
        elseif __info.m_nOutType == 3 then
           tips = "炮弹发射频率异常,请退出游戏!"
        elseif __info.m_nOutType == 4 then
           tips = "由于您长时间无发炮，自动退出房间!"
        elseif __info.m_nOutType == 5 then
           tips = "您的金币低于入场限制，请充值后再进入"
        end
        local dlg = DlgAlert.showTipsAlert({title = "提示", tip = tips })
		dlg:setSingleBtn("确定", function ()
		    dlg:closeDialog()
			self.gameScene:showFishExitGameLayer()
		end)
		dlg:enableTouch(false)
		dlg:setBackBtnEnable(false)
    end
end

function FishGameController:reqActiveTaskAward( __info )
	self:send2GameServer4Fish("CS_C2G_BuYu_Active_Task_Award_Req", __info )
end

-- 任务奖励列表
function FishGameController:ackActiveTaskAward( __info )
	 --print("任务奖励列表")
	 --dump( __info )
	 self.m_taskAwardState = {}
	 local taskActiveDatas =  FishGameDataController:getInstance():getTaskActiveDatas()
	 local isHaves = false
	 for i,taskActiveItemData in ipairs( taskActiveDatas ) do
	 	 local isHave = false
	 	 for k,v in pairs( __info.m_vecAwardList ) do
	 	     if taskActiveItemData.nId == v.m_nAwardID then
	 	     	isHave = true
	 	     	if v.m_nState == FishGlobal.TaskAwardType.canGet then
	 	     		isHaves = true 
	 	     	end
                local info = { taskId = taskActiveItemData.nId , state = v.m_nState }
                table.insert(self.m_taskAwardState, info )
                break
	 	     end
	     end
	     if not isHave then
            local info = { taskId = taskActiveItemData.nId , state = FishGlobal.TaskAwardType.noGet }
            table.insert(self.m_taskAwardState, info )
	     end
	 end
	 table.sort(self.m_taskAwardState, function ( v1 ,v2 ) return v1.taskId < v2.taskId  end )
	 -- if not tolua.isnull( self.gameScene ) then
	 -- 	 if not tolua.isnull( self.gameScene.m_fishTaskActivityLayer ) then
  --           self.gameScene.m_fishTaskActivityLayer:refreshTaskActiveView( self.m_taskAwardState )
  --        end
  --        -- 有奖励，显示红点
  --        if isHaves then
  --        	 self.gameScene.fishMainLayer:setRedSpriteVisble( true )
  --        else
  --            self.gameScene.fishMainLayer:setRedSpriteVisble( false )
  --        end
	 -- end
end

function FishGameController:getTaskAwardState()
     return self.m_taskAwardState
end

-- 领取奖励
function FishGameController:reqGetActiveTaskAward(__info )
	self:send2GameServer4Fish("CS_C2G_BuYu_Get_Active_Task_Award_Req", __info )
end

-- 领取奖励
function FishGameController:ackGetActiveTaskAward( __info )
	if __info.m_nRet == 0 then
	   TOAST("领取奖励成功!")
	   -- 播放获取金币声音
     FishSoundManager:getInstance():playEffect( FishSoundManager.ItemDrop  )
	   FishGameController:getInstance():reqActiveTaskAward( {} )
	else
       TOAST("领取奖励失败!")
	end
end

-- 发送捕鱼指令
function FishGameController:reqBuYuGM( __info )
	print("发送捕鱼指令")
end

-- 捕鱼指令返回
function FishGameController:ackBuYuGM( __info )
	print("捕鱼指令返回")
end

function FishGameController:notifyGameMaintenance( __info)
	-- body
end
 
-- 玩家请求锁定操作鱼
function FishGameController:reqLockFishOper( __info )
   print("玩家请求锁定操作鱼")
   dump( __info )
   self:send2GameServer4Fish("CS_C2G_BuYu_LockFishOper_Req", __info )
end

-- 玩家请求锁定鱼操作返回
function FishGameController:ackLockFishOper( __info )
	print("玩家请求锁定鱼操作返回")
	dump( __info )
	if __info.m_nResult == 0 then
	--    self.gameScene:setLockFireFish(__info.m_nIndex)
	else
       FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_nResult )
	end
end

-- 有玩家锁定鱼操作通知
function FishGameController:notifyPlayerLockFishOper( __info )
	print("有玩家锁定鱼操作通知")
	dump( __info )
	local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
	local chair = 0
	if fishPlayer then
	   chair = fishPlayer:getChair()
	end
    if not tolua.isnull( self.gameScene ) then
       if __info.m_nIndex == 0 then
          self.gameScene:setLockTargetByChair( chair , nil )
          fishPlayer:setLockFishId( 0 )
          self.gameScene:setLockLineAndAimVisibleByChair( chair , false )
       else
          local lockTarget = self.gameScene:getFishByFishIndex( __info.m_nIndex )
          if fishPlayer then
             fishPlayer:setLockFishId( __info.m_nIndex )
          end
       	  if not tolua.isnull( lockTarget ) then
             self.gameScene:setLockTargetByChair( chair , lockTarget )
             self.gameScene:setLockLineAndAimVisibleByChair( chair , true )
          end
       end
    end
end

-- 初始化锁定目标
function FishGameController:initLockFishOpers()
	if not tolua.isnull( self.gameScene ) then
	    for k,v in pairs( self.m_fishPlayerList ) do
	        if  v.m_nLockFishId ~= 0 then
	            local lockTarget = self.gameScene:getFishByFishIndex( v.m_nLockFishId )
	            if not tolua.isnull( lockTarget ) then
                   self.gameScene:setLockTargetByChair( v.m_chairId , lockTarget )
                   self.gameScene:setLockLineAndAimVisibleByChair( v.m_chairId , true )
                end 
	        end
	    end
	end
end

-- 请求切换炮速
function FishGameController:reqChangeSpeed4Cannon( __info )
    self:send2GameServer4Fish("CS_C2G_BuYu_ChangeSpeed4Cannon_Req", __info )
end

-- 切换炮速返回
function FishGameController:ackChangeSpeed4Cannon( __info )
	print("切换炮速返回")
	dump( __info )
    if __info.m_nRet == 0 then
    	local fishPlayer = self:getPlayerInfoByChairId( FishGlobal.myChair )
       if fishPlayer then
          fishPlayer:setSeepType( __info.m_nSeepType )
       end
       if not tolua.isnull( self.gameScene ) then
          self.gameScene.fishMainLayer:setFirePowerFrequency( __info.m_nSeepType )
       end
    else
       FishingUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_nRet )
    end
end

-- 有玩家切换炮速
function FishGameController:notiyPlayerChangeSpeed( __info )
    print("有玩家切换炮速")
    --dump( __info )
    local fishPlayer = self:getPlayerInfoByAccountId( __info.m_nAccountID )
    if fishPlayer then
       fishPlayer:setSeepType( __info.m_nSeepType )
    end
end

--通知指定那个玩家做AI碰撞检测
function FishGameController:notiyWhoDoRobotCheck( __info )
    print("FishGameController:notiyWhoDoRobotCheck")
    dump( __info )
    self.m_aiDriveAccountID = __info.m_accountID
    --print("self.m_aiDriveAccountID=",self.m_aiDriveAccountID)
end

function FishGameController:getAiDriveAccountID()
    return self.m_aiDriveAccountID
end

--[[
function FishGameController:exitGameScene( outType )
    if not tolua.isnull( self.gameScene ) then
        if outType and outType == 2 then
            if FishGlobal.isShowDesk then
               self.gameScene:exitGameHall( outType )
               self.gameScene= nil
            else
               self.gameScene:exitGame( outType )
               self.gameScene= nil
            end
        else
           self.gameScene:exitGame( outType )
           self.gameScene= nil
        end
    end
end
--]]

function FishGameController:popNetMsg()
	if self.gameScene.m_bIsInit then 
		local maxNetCount = 2
		if self.m_pSceneNetMsgData ~= nil then
			local maxCount = #self.m_pSceneNetMsgData;
			
			if #self.m_pSceneNetMsgData > maxNetCount then 
				maxCount = maxNetCount
			end
			if maxCount > 0 then
				for n = 1, maxCount do 
					if #self.m_pSceneNetMsgData > 0 then
						for key, infoData in pairs(self.m_pSceneNetMsgData) do
							local idStr = infoData[1]
							local info = infoData[2]
							if self.netMsgHandlerSwitch[idStr] then
								(self.netMsgHandlerSwitch[idStr])( info )
							end	
							table.remove(self.m_pSceneNetMsgData, k)
							break
						end
					end
				end
			end
		end

		if self.m_pNetMsgData ~= nil then
			local maxCount = #self.m_pNetMsgData
			if maxCount > maxNetCount then
				maxCount = maxNetCount
			end
			if maxCount > 0 then
				for n = 1, maxCount do
					if #self.m_pNetMsgData > 0 then
						for key, infoData in pairs(self.m_pNetMsgData) do
							local idStr = infoData[1]
							local info = infoData[2]
							if  self.m_callBackFuncList[idStr]  then
								(self.m_callBackFuncList[idStr])(info)
							end
							table.remove(self.m_pNetMsgData, key)
						end
					end
				end	
			end
		end

	end
end


return FishGameController