-- Author: 
-- Date: 2018-08-07 18:17:10
-- 定点赛场景管理器
local scheduler            = require("framework.scheduler")
local GamePlayerInfo       = require("src.app.game.common.data.GamePlayerInfo")
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

local DingDianSaiRoomController    = class("DingDianSaiRoomController")
DingDianSaiRoomController.instance = DingDianSaiRoomController.instance or nil

function DingDianSaiRoomController:getInstance()
	if DingDianSaiRoomController.instance == nil then
		DingDianSaiRoomController.instance = DingDianSaiRoomController.new()
	end
	return DingDianSaiRoomController.instance
end

function DingDianSaiRoomController:ctor()
	
end

function DingDianSaiRoomController:onClickDDS( atomID )
	self:queryDDS( atomID , 1 )
end

function DingDianSaiRoomController:queryDDS( atomID , _reqType )
	local reqType = _reqType or 0
	ConnectManager:send2SceneServer( atomID  , "CS_C2M_AppointmentMatch_Init_Req", {reqType} )
end

function DingDianSaiRoomController:notifyAppointmentMatchInit( __info )
	self:onReciveServerTime( __info.m_nSvrTime )
	self.__gameAtomTypeId = __info.m_gameAtomTypeId
	self:setDDSOpenTime( __info.m_gameAtomTypeId , __info.m_nStartTime )
	self:setSignUpStatus( __info.m_gameAtomTypeId , __info.m_nSignState )
	self.dds_candidates     = __info.m_nNumCandidates
	
	if self:serverTellMeOpenBaoMingYe( __info ) then
		self:showApointSignUpDialog( __info.m_gameAtomTypeId )
	elseif self:serverTellMeEnterScene( __info ) then
		self:reqEnterDDS( __info.m_gameAtomTypeId )
	end
end

function DingDianSaiRoomController:serverTellMeOpenBaoMingYe( __info )
	if __info.m_reqType ~= 1 then return false end
	if __info.m_nSignState == 0 or __info.m_nSignState == 4 then return true end
	if __info.m_nSignState == 1 and __info.m_nGroupState == 0 then return true end
end

function DingDianSaiRoomController:serverTellMeEnterScene( __info )
	if __info.m_reqType ~= 1 then return false end
	if __info.m_nSignState == 2 then return true end
	if __info.m_nSignState == 1 and __info.m_nGroupState > 0 then return true end
end

function DingDianSaiRoomController:notifyAppointmentMatchBegin( __info )
	LogINFO("跑得快定点赛成功进入场景,第一条消息")
	self.__gameAtomTypeId = __info.m_gameAtomTypeId
	self.dds_left_player_num = __info.m_nNumCandidates
	
	PRELOAD_GAME_SCENE( __info.m_gameAtomTypeId )
	self:setSignUpStatus( __info.m_gameAtomTypeId , 2 )
	local function f()
		local scene = PUSH_GAME_SCENE( __info.m_gameAtomTypeId  )
		scene:reciveRoomMsg( __info.m_gameAtomTypeId  )
		scene.gameRoomBgLayer.lord_bg_head:setVisible(false)
	end
	DO_ON_FRAME( GET_CUR_FRAME()+2, f )
end

function DingDianSaiRoomController:notifyAppointmentMatchRoundBegin( __info )
	LogINFO("定点赛第",__info.m_nStage,"轮开始了")
	self.DDSRoundBeginInfo         = __info
	self.dds_left_player_num       = __info.m_nGroupPlayerNum
	self.dds_promotion_player_num  = __info.m_nPromotionPlayerNum
	self:setCurStage( __info.m_nStage )
	self:setStopLimit( __info.m_nStopLimit )
	local function f()
		local scene = GET_GAME_SCENE()
		LogINFO("notifyAppointmentMatchRoundBegin 开始执行下帧函数 GAME_SCENE ", scene )
		GAME_SCENE_DO("updateDDSRankLabel")
		GAME_SCENE_DO("showDDSMatchInfo",__info.m_nStage)
		if __info.m_nUpdateOnce == 0 then
			if __info.m_nStage == 1 or __info.m_nStage == 2 then
				GAME_SCENE_DO("showDingDianSaiBeginUI",__info.m_nStage)
			elseif  __info.m_nStage == 3 then
				GAME_SCENE_DO("showDingDianSaiJueSaiUI")
			end
		end
	end
	DO_ON_FRAME( GET_CUR_FRAME()+3 , f )
end

function DingDianSaiRoomController:notifyAppointmentMatchBeforePlay( __info )
	LogINFO("定点赛 开赛前 玩家信息 服务器 推送过来了")
	self.__gameAtomTypeId = __info.m_gameAtomTypeId
	self.roomData = RoomData:getRoomDataById( __info.m_gameAtomTypeId  )
	self.roomType = self.roomData.roomType         -- 房间类型
	self.minScore = __info.m_iBaseScore
	
	self.__players = {}
	self.__players , self.meChair = self:initDingDianSaiPlayer( __info )

	local function f()
		local scene = GET_GAME_SCENE()
		LogINFO("DingDianSaiRoomController 开始执行下帧函数 GAME_SCENE ", scene )
		GAME_SCENE_DO( "reciveChairTable" , self.__players , self.meChair , self.minScore )
	end
	DO_ON_FRAME( GET_CUR_FRAME()+3 , f )
end

--初始化桌子玩家信息(定点赛)
function DingDianSaiRoomController:initDingDianSaiPlayer( __info )
	LogINFO("初始化桌子玩家信息(定点赛)(进入游戏时)")
	local meChair = nil
	local myAcc   = Player:getAccountID()
	local players = {} 
	for k,v in pairs( __info.m_cUsers ) do
		if v.m_nAccount == myAcc then meChair = v.m_nPosId end
		local info = GamePlayerInfo.new()
		players[v.m_nPosId] = info
		info:setChairId(v.m_nPosId)
		info:setAccountId(v.m_nAccount)
		info:setFaceId(v.m_nFaceId)
		info:setNickname(v.m_strNickName)
		info:setGameScore(v.m_nCent)
		info:setLevel(v.m_nLevel)
	end
	return players,meChair
end

function DingDianSaiRoomController:notifyAppointmentMatchRoundEndUpdate( __info )
	LogINFO("收到了定点赛某一轮结束消息")
	dump(__info)
	if __info.m_nResult == 0 or __info.m_nResult == 4 then
		self:setMyRank( __info.m_nRank )
		GAME_SCENE_DO("showDDSRoundEndLayer","wait", __info.m_nRunningTables)
		GAME_SCENE_DO("updateDDSRankLabel")
	end

	if __info.m_nResult == 1 then
		--晋级了同时会收到轮开始赛制提示
	end
	
	if __info.m_nOpResult == 2 then
		GAME_SCENE_DO("showTaoTai", __info)
	end
	
	if __info.m_nResult == 3 then
		GAME_SCENE_DO("ddsToastRet")
	end
end

function DingDianSaiRoomController:notifyAppointmentMatchRankUpdate( __info )
	LogINFO("收到了 定点赛 排名更新 消息")
	self:setMyRank( __info.m_nRank )
	self.dds_left_player_num = __info.m_nLastMember
	if self:getCurStage()  == 1 then
		local stopLimit = self:getStopLimitNum( self:getCurStage() )
		self.dds_left_player_num = math.max( self.dds_left_player_num , stopLimit )
	end
	
	GAME_SCENE_DO("updateDDSRankLabel")
end

function DingDianSaiRoomController:notifyAppointmentMatchResult( __info )
	LogINFO("收到了 定点赛 整场比赛结束 消息")
	dump(__info)
	self:reqExitDDS( __info.m_gameAtomTypeId )
	self.MatchGameResultInfo = {}
	self.MatchGameResultInfo.curRank = __info.m_nRank
	self.MatchGameResultInfo.goldCoin = __info.m_nCoin
	self.MatchGameResultInfo.diamond = __info.m_nDiamond
	self.MatchGameResultInfo.itemArr = __info.m_arrItems
	
	if self.MatchGameResultInfo.curRank == 1 or self.MatchGameResultInfo.curRank == 2 then
		GAME_SCENE_DO("showDiplomaLayer")
	else
		GAME_SCENE_DO("showDDSMatchGameResult")
	end
	self:queryDDS( __info.m_gameAtomTypeId )
end

function DingDianSaiRoomController:setCurStage( num )
	self.dds_cur_stage = num
end

function DingDianSaiRoomController:getCurStage()
	return self.dds_cur_stage
end

function DingDianSaiRoomController:getMatchGameResultInfo()
	return self.MatchGameResultInfo
end

function DingDianSaiRoomController:setStopLimit( num )
	self.dds_stop_limit = num
end

function DingDianSaiRoomController:getStopLimitNum( stage )
	return self.dds_stop_limit or 0
end


function DingDianSaiRoomController:playerNumGoNext()
	return self.dds_promotion_player_num or 0
end

function DingDianSaiRoomController:setMyRank( num )
	self.dds_my_rank = num
end

function DingDianSaiRoomController:getDDSMyRank()
	return self.dds_my_rank or 1
end

function DingDianSaiRoomController:getLeftPlayerNum()
	return self.dds_left_player_num or 0
end

function DingDianSaiRoomController:getLeftTableNum()
	return self.dds_left_table_num or 0
end

function DingDianSaiRoomController:getRoundBeginInfo()
	return self.DDSRoundBeginInfo
end

function DingDianSaiRoomController:setDDSPeopleCnt( atomID , cnt )
	if not self.ddsPeopleCnt then self.ddsPeopleCnt = {} end
	self.ddsPeopleCnt[ atomID ] = cnt
end

function DingDianSaiRoomController:getDDSPeopleCnt( atomID )
	if not self.ddsPeopleCnt or not self.ddsPeopleCnt[ atomID ] then return 1 end
	return self.ddsPeopleCnt[ atomID ]
end

function DingDianSaiRoomController:getSignUpCandidates( atomID )
	return self.dds_candidates or 0
end

function DingDianSaiRoomController:showApointSignUpDialog( atomID )
	DOHALL_CENTER("showSignUpGameDialog",atomID,self:getSignUpStatus( atomID ))
end

function DingDianSaiRoomController:setSignUpStatus( atomID , num )
	if not self.dds_sign_up_status then self.dds_sign_up_status = {} end
	self.dds_sign_up_status[atomID] = num
	DOHALL_CENTER("updateRoomSignUpFlag",atomID)
end
-- 0未报名 1已报名 2已开赛
function DingDianSaiRoomController:getSignUpStatus( atomID )
	if not self.dds_sign_up_status or not self.dds_sign_up_status[ atomID ] then return 0 end
	return self.dds_sign_up_status[ atomID ]
end

function DingDianSaiRoomController:reqExitDDS( atom )
	LogINFO("请求退出定点赛",atom)
	ConnectManager:send2SceneServer( atom ,"CS_C2M_AppointmentMatch_Out_Nty", {} )
end

function DingDianSaiRoomController:reqEnterDDS( atom )
	REQ_ENTER_SCENE( atom )
end


function DingDianSaiRoomController:onClickAgainGame( atomID )
	LogINFO("定点赛返回界面",atomID)
	GAME_SCENE_DO("exit")
end

function DingDianSaiRoomController:onReciveServerTime( serverTime )
	self.client_server_timegap = serverTime - os.time()
end

function DingDianSaiRoomController:getDDSOpenTimeStr( atomID )
	local str = self:timeToStr( self:getDDSOpenTime(atomID) )
	return str
end

function DingDianSaiRoomController:timeToStr( openTime )
	local ret = os.date("%H:%M",openTime)
	local curTime = self:getServerTime()
	local curTbl  = os.date( "*t",curTime )
	local openTbl = os.date("*t",openTime)
	if openTbl.yday - curTbl.yday == 1 then
		ret = "明天 "..ret
	elseif openTbl.yday - curTbl.yday > 1 then
		ret = "周"..openTbl.wday..ret
	end
	return ret
end

function DingDianSaiRoomController:getDDSOpenTime( atomID )
	if not self.dds_start_time or not self.dds_start_time[ atomID ] then
		return self:getOpenTimeFromCsv( atomID )
	end
	return self.dds_start_time[ atomID ]
end

function DingDianSaiRoomController:setDDSOpenTime( atomID , num )
	if not self.dds_start_time then self.dds_start_time = {} end
	self.dds_start_time[ atomID ] = num
end

function DingDianSaiRoomController:getServerTime()
	local gap = self.client_server_timegap or 0
	local ret = os.time() + gap
	return ret
end

function DingDianSaiRoomController:getCountDown( atomID )
	local ret = self:getDDSOpenTime( atomID ) - self:getServerTime()
	return ret
end

function DingDianSaiRoomController:getOpenTimeFromCsv( atomID )
	local curTime = tonumber( os.date("%H%M",self:getServerTime()) )
	local info = RoomData:getRoomDataById( atomID )
	if type( info ) ~= "table" then return self:getServerTime() end
	local tbl  = fromJson( info.roomOpenTime )
	if type( tbl ) ~= "table" then return self:getServerTime() end
	for k,v in pairs( tbl ) do
		if v.begin > curTime then
			local ret = self:getServerTime() + (v.begin - curTime)*60
			return ret
		end
	end
end

return DingDianSaiRoomController