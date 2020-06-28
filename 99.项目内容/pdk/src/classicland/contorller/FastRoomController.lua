-- FastRoomController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛场景管理器
local scheduler             = require("framework.scheduler")
local GamePlayerInfo        = require("src.app.game.common.data.GamePlayerInfo")
local FastRoomController    = class("FastRoomController")
FastRoomController.instance = FastRoomController.instance or nil

function FastRoomController:getInstance()
	if FastRoomController.instance == nil then
		FastRoomController.instance = FastRoomController.new()
	end
    return FastRoomController.instance
end

function FastRoomController:ctor()
    self.MatchBeforeGameInfo = 
    {
       isShowMatchBegin  = 0 , -- 是否显示【比赛开始】,0:不显示，1:显示'}
       roundIndex = 0        , -- 第N轮
       upgradeType = 0       , -- 晋级类型：0:一局定胜，本桌第1名晋级,1:前N名晋级
       upgradeCnt = 0        , -- 前N名晋级
       curRoundtimes = 0     , -- 该轮共计N局
       isShowRoundUpgrade = 0, -- 是否显示【第N轮、晋级类型、前N名晋级、该轮共计N局】,0:不显示，1:显示'
       lastUpgradeCnt = 0    , -- 上一轮前N名晋级
       lastRank = 0          , -- 上一轮结束排名名次
       totalRoundCnt = 0     , -- 整场比赛总共多少轮
       contidion = 0         , -- 报名选项
    }
end

function FastRoomController:notifyMatchShowSignUpOrExitMatchPage( __info )
	LogINFO("超快赛进入场景成功,第一条消息")
    self.__gameAtomTypeId = __info.m_gameAtomTypeId

	local cfgTbl = __info.m_personCntPerRound
    table.insert(cfgTbl,1)
	self.fast_game_round_config      = cfgTbl

    if __info.m_type == 0 then
    	if self.autoSignUp then
    		local MatchSignUpController = require("src.app.game.pdk.src.classicland.contorller.MatchSignUpController")
    		MatchSignUpController:getInstance():reqSignUp( __info.m_gameAtomTypeId , self.sign_up_condition or 0 , 0 , true )
    		self.autoSignUp = false
    	else
    		DOHALL_CENTER("showSignUpGameDialog",__info.m_gameAtomTypeId)
    	end
    elseif __info.m_type == 1 or __info.m_type == 3 then
        DOHALL_CENTER("showSignUpGameDialog",__info.m_gameAtomTypeId)
    elseif __info.m_type == 2 then
    	self:setSignUpStatus( __info.m_gameAtomTypeId , 1 )
    	DOHALL_CENTER("showSignUpGameDialog",__info.m_gameAtomTypeId,self:getSignUpStatus( __info.m_gameAtomTypeId ))
    elseif __info.m_type == 5 then
    	self:setSignUpStatus( __info.m_gameAtomTypeId , 2 )
    end
end

-- 响应关闭比赛报名页
function FastRoomController:ackMatchCloseSignupPage( __info )
	if __info.m_result == 0 or __info.m_result == 1 or __info.m_result == 2 then
	   DOHALL("removeDialog")
    else
        LAND_SHOW_ERROR_TIP(__info.m_result)
    end
end

-- 请求关闭比赛报名页
function FastRoomController:reqMatchCloseSignupPage()
	if self.__gameAtomTypeId then
		ConnectManager:send2SceneServer( self.__gameAtomTypeId,"CS_C2M_MatchCloseSignupPage_Req", { self.__gameAtomTypeId })
	end
end

-- 比赛退出游戏客户端，点游戏客户端X 、游戏中退出按钮
function FastRoomController:reqMatchExitGame()
	if self.__gameAtomTypeId then
		ConnectManager:send2SceneServer( self.__gameAtomTypeId,"CS_C2M_Run_Match_Exit_Game_Req", { self.__gameAtomTypeId })
	end
end
-- 响应比赛退出游戏客户端，点游戏客户端X 、游戏中退出按钮
function FastRoomController:ackMatchExitGame( __info )
	if __info.m_result == 0 then
       LogINFO("超快赛退出场景成功")
	else
       LAND_SHOW_ERROR_TIP(__info.m_result)
	end
end

function FastRoomController:showXianWanZhe( new_atom , content )
	local dlg = RequireEX("app.game.pdk.src.landcommon.view.LandDiaLog").new()
	local function f()
		local MatchSignUpController = require("src.app.game.pdk.src.classicland.contorller.MatchSignUpController")
        MatchSignUpController:getInstance():reqSignUp( new_atom , self.sign_up_condition or 0, 1 , true )
        dlg:closeDialog()
    end
    dlg:setContent( content , 26 )
    dlg:showSingleBtn("继续报名",f)

    local function onClose()
    	FastRoomController:getInstance():reqMatchCloseSignupPage()
    	dlg:closeDialog()
    end
    dlg:setCloseBtnFun( onClose )
end

function FastRoomController:notifyMatchBeforeGameTable( __info )
	LogINFO("超快赛玩家信息过来了")

	dump(__info, "超快赛玩家信息：", 10)

    self.__gameAtomTypeId = __info.m_gameAtomTypeId
    self:setSignUpStatus( __info.m_gameAtomTypeId , 2 )
	self.minScore = __info.m_minScore
 
	LOAD_GAMEMSG_CALLBACK()
	
	if GET_GAME_SCENE() then
		POP_GAME_SCENE()
		SHOW_GAME_ROOM_BG( __info.m_gameAtomTypeId )
	end

	self.MatchBeforeGameInfo = {}
	self.MatchBeforeGameInfo.isShowMatchBegin  = __info.m_isShowMatchBegin
	self.MatchBeforeGameInfo.roundIndex = __info.m_roundIndex
	self.MatchBeforeGameInfo.upgradeType = __info.m_upgradeType
	self.MatchBeforeGameInfo.upgradeCnt = __info.m_upgradeCnt
	self.MatchBeforeGameInfo.curRoundtimes = __info.m_curRoundtimes
	self.MatchBeforeGameInfo.isShowRoundUpgrade = __info.m_isShowRoundUpgrade
	self.MatchBeforeGameInfo.lastUpgradeCnt = __info.m_lastUpgradeCnt
    self.MatchBeforeGameInfo.lastRank = __info.m_lastRank
	self.MatchBeforeGameInfo.totalRoundCnt = __info.m_totalRoundCnt
	self.MatchBeforeGameInfo.curStage = __info.m_curStage
	self.MatchBeforeGameInfo.isFirstTime = __info.m_isFirstTime											
	
    self:setCurJU( __info.m_curTimesIndex  )
    self:setTotalJU( __info.m_curRoundtimes )
    self.__players = {}
	self.__players , self.meChair = self:initTablePlayerInfo( __info )

	local function f()
		DOHALL("removeDialog")
		local scene = PUSH_GAME_SCENE( __info.m_gameAtomTypeId )
		scene:reciveRoomMsg( __info.m_gameAtomTypeId )
		scene:reciveChairTable( self.__players , self.meChair , self.minScore )
	end
	DO_ON_FRAME( CAL_PUSH_SCENE_FRAME() , f )

	local function f()
		local scene = GET_GAME_SCENE()
		LogINFO("FastRoomController 开始执行下帧函数 GAME_SCENE ", scene )
		 
		GAME_SCENE_DO( "updateRankLabel" )
		GAME_SCENE_DO( "updateFastMatchInfo" )
		GAME_SCENE_DO( "showFastFirstRound")
	end
	DO_ON_FRAME( GET_CUR_FRAME()+3 , f )
end

-- 游戏结束，比赛结算结果 （ 一轮的结束 ）
function FastRoomController:notifyMatchGameResult( __info  )
	LogINFO("接收到 超快赛 一轮 结束 消息")
	if __info.m_type == 0 or __info.m_type == 2 then -- 淘汰或者 结束
		self:setSignUpStatus( __info.m_gameAtomTypeId , 0 )
	end

	self.MatchGameResultInfo = {}
	self.MatchGameResultInfo.mathtype = __info.m_type
	self.MatchGameResultInfo.upgradeCnt = __info.m_upgradeCnt
	self.MatchGameResultInfo.curRank = __info.m_curRank
	self.MatchGameResultInfo.upgradeNextRound = __info.m_upgradeNextRound
	self.MatchGameResultInfo.goldCoin = __info.m_goldCoin
    self.MatchGameResultInfo.diamond = __info.m_diamond
    self.MatchGameResultInfo.itemArr = __info.m_itemArr
    self.MatchGameResultInfo.contidion = __info.m_contidion
    GAME_SCENE_DO( "clearUI" , __info )
	GAME_SCENE_DO("showMatchGameResultInfo")
	
end

function FastRoomController:notifyFastMatchStatus( __info )
	LogINFO("接收到超快赛比赛结果消息", __info.m_gameAtomTypeId)
	if __info.m_status == 2 then
		self:setSignUpStatus( __info.m_gameAtomTypeId , 0 )
	end
end

function FastRoomController:setSignUpStatus( atomID , num )
	if not self.fast_sign_up_status then self.fast_sign_up_status = {} end
	self.fast_sign_up_status[ atomID ] = num
	DOHALL_CENTER("updateRoomSignUpFlag",atomID)
end
-- 0未报名 1已报名 2已开赛
function FastRoomController:getSignUpStatus( atomID )
    if not self.fast_sign_up_status or not self.fast_sign_up_status[ atomID ] then return 0 end
    return self.fast_sign_up_status[ atomID ]
end

function FastRoomController:setFastGameCnt( atomID ,  _num )
	if not self.fast_game_cnt then self.fast_game_cnt = {} end
	self.fast_game_cnt[ atomID ] = _num
end

-- 超快赛轮次配表信息
function FastRoomController:getFastGameRoundConfig()
	return self.fast_game_round_config
end

function FastRoomController:getFastGameCnt( atomID )
	if not self.fast_game_cnt or not self.fast_game_cnt[ atomID ] then return 0 end
	return self.fast_game_cnt[ atomID ]
end

function FastRoomController:getMatchBeforeGameInfo()
	return self.MatchBeforeGameInfo
end

function FastRoomController:getMatchGameResultInfo()
	return  self.MatchGameResultInfo
end

function FastRoomController:setAutoSignUp( tag )
    self.autoSignUp = tag
end

function FastRoomController:setCurJU( _num )
    self.__curJU = _num
end

function FastRoomController:playerNumGoNext()
    return self.MatchBeforeGameInfo.curStage == 3  and 1 or self.MatchBeforeGameInfo.upgradeCnt
end

function FastRoomController:getCurJU()
    local ret = self.__curJU or 0
    self.__curJU = math.max(0,ret)
    return self.__curJU
end

function FastRoomController:setTotalJU( num )
	self.total_ju = num
end

function FastRoomController:getTotalJU()
	return self.total_ju
end

function FastRoomController:onClickAgainGame( atomID , contidion )
	LogINFO("超快赛再来一局",atomID,contidion)
	self.sign_up_condition = contidion
	self:setAutoSignUp(true)
	REQ_ENTER_SCENE( atomID )
end

function FastRoomController:initTablePlayerInfo( __info )
	LogINFO("初始化系统下发的三个玩家的信息(进入游戏时)")
	local meChair = nil
	local myAcc   = Player:getAccountID()
	local players = {} 
	
	for k, v in pairs( __info.m_beforeGameChair ) do
		if v.m_accountId ~= 0 then
			if v.m_accountId == myAcc then meChair = v.m_chairId end
			local info = GamePlayerInfo.new()
			players[v.m_chairId] = info
			info:setChairId(v.m_chairId)
			info:setAccountId(v.m_accountId)  

			for i = 1, #__info.m_beforeGameUser do
				local user = __info.m_beforeGameUser[i] 
				if user.m_accountId == v.m_accountId then
					info:setFaceId(user.m_faceId)
					info:setNickname(user.m_nickname)
					if user.m_goldCoin then
					   info:setGoldCoin(user.m_goldCoin)
					end
					info:setLevel(user.m_level)
					if user.m_gameScore then
					    info:setGameScore( user.m_gameScore )
					end
					break
				end
			end
		end
	end
	return players,meChair
end

return FastRoomController