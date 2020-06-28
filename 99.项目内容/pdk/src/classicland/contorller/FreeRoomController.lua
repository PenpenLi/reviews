-- FreeRoomController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 自由房场景管理器
local scheduler = require("framework.scheduler")
local GamePlayerInfo = require("src.app.game.common.data.GamePlayerInfo")

local FreeRoomController = class("FreeRoomController")
FreeRoomController.instance = FreeRoomController.instance or nil

function FreeRoomController:getInstance()
	if FreeRoomController.instance == nil then
		FreeRoomController.instance = FreeRoomController.new()
	end
    return FreeRoomController.instance
end

function FreeRoomController:ctor()
	
end

-- 通知进入系统房场景
function FreeRoomController:notifySysEnter( __info )
	self.__gameAtomTypeId = __info.m_gameAtomTypeId
	self.__players = {}
	LOAD_GAMEMSG_CALLBACK()
	POP_GAME_SCENE()
	local layer = SHOW_GAME_ROOM_BG(self.__gameAtomTypeId)
	if __info.m_type == 0 then
		if layer then
			layer:showQiaoLuoDaGu()
			layer:startFreeRoomCountDown()
		end
	end
end

function FreeRoomController:notifySysBeforeGameTable( __info )
	self.__players = {}
	self.__players , self.meChair , self.myGold = self:initTablePlayerInfo( __info )
	self.minScore = __info.m_minScore
	self.roomCost = __info.m_roomCost
	local function f()
		local scene = PUSH_GAME_SCENE( __info.m_gameAtomTypeId )
		scene:reciveRoomMsg( __info.m_gameAtomTypeId )
		scene:reciveChairTable( self.__players , self.meChair , self.minScore )
	end
	DO_ON_FRAME( CAL_PUSH_SCENE_FRAME() , f )
end

function FreeRoomController:getRoomCost()
	return self.roomCost or 0
end

function FreeRoomController:initTablePlayerInfo( __info )
	LogINFO("初始化系统下发的三个玩家的信息(进入游戏时)")
	local meChair = nil
	local myGold  = 0
	local myAcc   = Player:getAccountID()
	local players = {}

	for k,v in pairs( __info.m_beforeGameUser ) do
	 	if v.m_accountId == myAcc then 
	 		meChair = k
	 		myGold  = v.m_goldCoin
	 	end

	 	local p = GamePlayerInfo.new()
	 	p:setChairId(k)
	 	p:setAccountId(v.m_accountId)
	 	p:setFaceId(v.m_faceId)
	 	p:setNickname(v.m_nickname)
	 	p:setLevel(v.m_level)
	 	p:setGoldCoin(v.m_goldCoin)
	 	players[k] = p
	end
	
	return players,meChair,myGold
end

-- 请求退出系统房
function FreeRoomController:reqSysExitGame( _flag )
	local flag = _flag or 0
	if self.__gameAtomTypeId then
		ConnectManager:send2SceneServer( self.__gameAtomTypeId,"CS_C2M_SysExitGame_Req", { self.__gameAtomTypeId , flag })
	end
end

function FreeRoomController:notifySysExitSpecialAsk( __info )
	LogINFO("接收到服务器回应,弹窗让玩家选择是否强退")
	self.__gameAtomTypeId = __info.m_gameAtomTypeId
	local str = "强退将暂时扣除"..__info.m_leftCoin.."金币用于本局结算,结算后自动返还剩余金币,是否退出?"
	GAME_SCENE_DO("showExitGameLayer",str)
end

function FreeRoomController:reqSysExitSpecialConfirm( _flag )
	local flag = _flag or 0
	if self.__gameAtomTypeId then
		ConnectManager:send2SceneServer( self.__gameAtomTypeId,"CS_C2M_SysExitSpecialConfirm_Req", { self.__gameAtomTypeId , flag })
	end
end

function FreeRoomController:ackSysExitGame( __info )
	if __info.m_result == 0 then
		LogINFO("退出系统房成功")
		HIDE_GAME_ROOM_BG()
		GAME_SCENE_DO("onExitSysGame")
	else
		
	end
end

function FreeRoomController:ackSysExitSpecialConfirm( __info )
	if __info.m_result == 0 then
		
	else
		TOAST( __info.m_result )
	end
end

function FreeRoomController:notifySysEnd( __info )
	GAME_SCENE_DO("onSysEnd")
end

return FreeRoomController