-- LandGameMainScene
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 打牌主场景
local DlgAlert              = require("app.hall.base.ui.MessageBox")
local scheduler             = require("framework.scheduler") 
local FastRoomController    = require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local DDSRoomController     = require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local CCGameSceneBase       = require("src.app.game.common.main.CCGameSceneBase")
local LandAccounts          = require("src.app.game.pdk.src.landcommon.view.LandAccounts")
local LandMusicSetLayer     = require("src.app.newHall.childLayer.SetLayer")
local LandGameRuleInfo      = require("src.app.game.pdk.src.landcommon.view.LandGameRuleInfo")   
local ExitGameLayer         = require("src.app.game.pdk.src.landcommon.view.ExitGameLayer")       
local LastHandCardLayer     = require("src.app.game.pdk.src.landcommon.view.LastHandCardLayer")

local LandGlobalDefine      = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local FriendJieSaningLayer  = require("src.app.game.pdk.src.friendland.view.FriendJieSaningLayer")  
local FriendAccountLayer    = require("src.app.game.pdk.src.friendland.view.FriendAccountLayer")
local LandSystemSet         = RequireEX("src.app.game.pdk.src.landcommon.view.LandSystemSet")
local LandSoundManager      = require("src.app.game.pdk.src.landcommon.data.LandSoundManager")
local MatchSignUpController = require("src.app.game.pdk.src.classicland.contorller.MatchSignUpController")
local FriendJieSanLayer     = require("src.app.game.pdk.src.friendland.view.FriendJieSanLayer")
local MatchJoinLayer     = require("src.app.game.pdk.src.classicland.view.MatchJoinLayer")
local MatchWinLayer     = require("src.app.game.pdk.src.classicland.view.MatchWinLayer")
local MatchJinjiLayer     = require("src.app.game.pdk.src.classicland.view.MatchJinjiLayer")
local MatchTaotaiLayer     = require("src.app.game.pdk.src.classicland.view.MatchTaotaiLayer")

local LandLoadingLayer  = require("src.app.game.pdk.src.classicland.view.LandLoadingLayer")
local LandRes = require("src.app.game.pdk.src.classicland.scene.LandRes")
local landArmatureResource = require ("app.game.pdk.src.landcommon.animation.LandArmatureResource")
local CardKit = require("src.app.game.pdk.src.common.CardKit")

local scheduler = require("framework.scheduler")

local LandGameBGMusic = 
{
	[LandGlobalDefine.CLASSIC_LAND_TYPE] = "sounds/bg.mp3",
	[LandGlobalDefine.HAPPLY_LAND_TYPE] = "sounds/bg_happy.mp3",
	[LandGlobalDefine.LAIZI_LAND_TYPE] = "sounds/bg_laizi.mp3",
}


local LandGameMainScene = class("LandGameMainScene", function ()
	return CCGameSceneBase.new()
end)

function LandGameMainScene:ctor( atomID )
	self.game_atom = atomID
	self.sceneCtorFrame = GET_CUR_FRAME()
	 local flag = cc.UserDefault:getInstance():getStringForKey("First_Hall")   
    if  flag == "" then 
          cc.UserDefault:getInstance():setStringForKey("First_Hall",1)
          cc.UserDefault:getInstance():flush()  
    end 
	LogINFO("主场景开始创建,游戏类型," , self.game_atom , "创建帧," , self.sceneCtorFrame)
	
	-- local  musicPath = LandGameBGMusic[GET_GAME_GLOAL_TYPE(self.game_atom)]
	local  musicPath = LandGameBGMusic[LandGlobalDefine.CLASSIC_LAND_TYPE]
	self:setMusicPath(musicPath) 
	LandRes.Audio.BACK_MUSIC = musicPath;
	g_AudioPlayer:playMusic(musicPath, true)
    
    addMsgCallBack(self, MSG_ENTER_BACKGROUND, handler(self, self.onEnterBackGround))
    addMsgCallBack(self, MSG_ENTER_FOREGROUND, handler(self, self.onEnterForeground))
    --addMsgCallBack(self, MSG_KICK_NOTIVICE, handler(self, self.onMsgKickNotice))
    --addMsgCallBack(self, MSG_GAME_SHOW_MESSAGE, handler(self, self.onStartGame))
    --addMsgCallBack(self, MSG_PUSH_GAME_RECONNECT, handler(self, self.onGameReconnectResult))
	self:registBackClickHandler(handler(self, self.onBackButtonClicked)) -- Android & Windows注册返回按钮
	--addMsgCallBack(self, POPSCENE_ACK,handler(self,self.showEndGameTip))
    --addMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT, handler(self, self.socketState))
	--addMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT, handler(self,self.onSocketEventMsgRecived))
	--g_GameController:setGamePingTime( 5 , g_GameController.gameServerOfflineMaxCount )

	local LandResourcesKit = require("src.app.game.pdk.src.common.LandResourcesKit")
	LandResourcesKit:LOAD_GAME_RESOURCES()
 	self:onLoadingCall()

	-- addMsgCallBack(self, UPDATE_GAME_RESOURCE, handler(self, self.onLoadingCall))
	-- self.m_pLoadingLayer = LandLoadingLayer.new();
	-- self:addChild(self.m_pLoadingLayer, 1000);

	-- self:showMatchWaitView()
end

function LandGameMainScene:onLoadingCall()
	self:addBGLayer();
	if self.m_pLoadingLayer then self.m_pLoadingLayer:closeView(); end
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function()
			g_GameController.m_bIsInitlLayer = true;
			g_GameController:sendHandlerData();
		end),
	nil))
end

function LandGameMainScene:onBackButtonClicked()
	--[[
	if self.m_landAccountLayer or self:getGameState() < 1 then
		print("LandGameMainScene:onBackButtonClicked reqSysExitGame")
		g_GameController:reqSysExitGame(0)
		g_GameController:releaseInstance()
    else
		print("LandGameMainScene:onBackButtonClicked reqUserLeftGameServer")
		g_GameController:reqUserLeftGameServer()
		g_GameController:releaseInstance()
    end
	--]]
	if self.m_landMainLayer then 
		self.m_landMainLayer:onReturnClicked(nil, ccui.TouchEventType.ended)
		return
	end
	self:exit()
end

function LandGameMainScene:onEnter()
    print("----------------LandGameMainScene:onEnter begin----------------")
	print("----------------LandGameMainScene:onEnter end----------------")
end

function LandGameMainScene:onExit()
    LogINFO("主场景被摧毁 此场景创建于第 ", self.sceneCtorFrame ,"帧" , "游戏类型,",self.game_atom )
	print("----------------LandGameMainScene:onExit begin----------------")
	
	if self.m_landMainLayer then
		self.m_landMainLayer:clearData()
		self.m_landMainLayer = nil
	end
	
	if self._schedulerEnd then
		scheduler.unscheduleGlobal(self._schedulerEnd)
		self._schedulerEnd = nil
	end
	
    --removeMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT)
	removeMsgCallBack(self, MSG_ENTER_BACKGROUND)
	removeMsgCallBack(self, MSG_ENTER_FOREGROUND)
	--removeMsgCallBack(self, MSG_KICK_NOTIVICE)
	--removeMsgCallBack(self, MSG_GAME_SHOW_MESSAGE)
	--removeMsgCallBack(self, MSG_PUSH_GAME_RECONNECT)
    --removeMsgCallBack(self, POPSCENE_ACK)
	--removeMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT)
	--g_GameController:setGamePingTime( g_GameController.gameServerPingCD, g_GameController.gameServerOfflineMaxCount )
	removeMsgCallBack(self, UPDATE_GAME_RESOURCE)


	AudioManager:getInstance():stopAllSounds()
    AudioManager:getInstance():stopMusic()
    -- cc.AnimationCache:destroyInstance();
    -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames();
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures();
    CacheManager:removeAllExamples();

	-- 释放动画
	-- local ani_list = {};
    for key, value in pairs(landArmatureResource.armatureResourceInfo) do
		-- table.insert(ani_list, value.configFilePath);
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(value.configFilePath)
    end

    for _, strPathName in pairs(LandRes.vecReleaseAnim) do
        --local strJsonName = string.format("%s%s/%s.ExportJson", Lhdz_Res.strAnimPath, strPathName, strPathName)
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(strPathName)
    end
    -- 释放整图
    for _, strPathName in pairs(LandRes.vecReleasePlist) do
        display.removeSpriteFrames(strPathName[1], strPathName[2])
    end
    -- 释放背景图
    for _, strFileName in pairs(LandRes.vecReleaseImg) do
        display.removeImage(strFileName)
    end
    -- 释放音频
    for _, strFileName in pairs(LandRes.vecReleaseSound) do
        AudioManager.getInstance():unloadEffect(strFileName)
    end

	print("----------------LandGameMainScene:onExit end----------------")
end

function LandGameMainScene:addGameLayer()
	self.m_landMainLayer = self:addLayer( "GameLayer" , "src.app.game.pdk.src.classicland.view.GameMainLayer" , 0 , self:getGameAtom() )
end

function LandGameMainScene:showMatchResultView(delayTime, resultInfo, gameChairTbl)
	if g_GameController:isMatchGame() then
		if self.m_pMatchResultView == nil then
			self.m_pMatchResultView = require("src.app.game.pdk.src.classicland.view.MatchResultOneLayer").new();
			self:addChild(self.m_pMatchResultView, 10);
		end
		self.m_pMatchResultView:setResult(resultInfo, gameChairTbl);
		self.m_pMatchResultView:showView(delayTime, 5);
	end
end

function LandGameMainScene:hideMatchResultView()
	if self.m_pMatchResultView ~= nil then
		self.m_pMatchResultView:hideView();
	end
end

function LandGameMainScene:showMatchWaitView(info)
	if self.m_pMatchWaitView == nil then
		self.m_pMatchWaitView = require("src.app.game.pdk.src.classicland.view.MatchWaitLayer").new();
		self:addChild(self.m_pMatchWaitView, 11);
	end
	self.m_pMatchWaitView:setData(info);
	self.m_pMatchWaitView:showView();
end

function LandGameMainScene:hideMatchWaitView()
	if self.m_pMatchWaitView ~= nil then
		self.m_pMatchWaitView:hideView();
	end
end

function LandGameMainScene:createMatchJoinLayer(info)
	self.m_MatchJoinLayer = MatchJoinLayer.new()
    self:addChild(self.m_MatchJoinLayer) 
    self.m_MatchJoinLayer:setLocalZOrder(100)
    self.m_MatchJoinLayer:setMatchData(info)
end

function LandGameMainScene:closeMatchJoinLayer()
	if self.m_MatchJoinLayer then
        self.m_MatchJoinLayer:close()
        self.m_MatchJoinLayer = nil
    end
end
function LandGameMainScene:createMatchWinLayer(info)
	self.m_MatchWinLayer = MatchWinLayer.new()
    self:addChild(self.m_MatchWinLayer, 12) 
    self.m_MatchWinLayer:setWinData(info)
end

function LandGameMainScene:createMatchJinjiLayer(info)
	self.m_MatchJinjiLayer = MatchJinjiLayer.new()
    self:addChild(self.m_MatchJinjiLayer) 
    self.m_MatchJinjiLayer:setData(info)
end
function LandGameMainScene:closeMatchJinjiLayer()
	if self.m_MatchJinjiLayer then
        self.m_MatchJinjiLayer:close()
        self.m_MatchJinjiLayer = nil
    end
end
function LandGameMainScene:createMatchTaotaiLayer(info)
	self.m_MatchTaotaiLayer = MatchTaotaiLayer.new()
    self:addChild(self.m_MatchTaotaiLayer, 12) 
    self.m_MatchTaotaiLayer:setData(info)
end
function LandGameMainScene:addLandDDSMatchLayer()
	local name = "DDSMatchTipsLayer"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandMatchTipsNewLayer" , 5 )
end

function LandGameMainScene:addLandMatchTipsGameBegin()
	local name = "MatchTipsLayerGameBegin"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandMatchTipsGameBegin" , 5 )
end

function LandGameMainScene:addLandMatchTipsGameLun()
	local name = "MatchTipsLayerGameLun"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandMatchTipsLun" , 5 )
end

function LandGameMainScene:addLandMatchTipsWinLose()
	local name = "MatchTipsLayerWinLose"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandMatchTipsWinLose" , 5 )
end

function LandGameMainScene:addWaitingOtherPlayerLayer()
	local name = "WaitOtherPlayerLayer"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.LandWaitOtherPlayerLayer" , 1 )
end

function LandGameMainScene:removeWaitingOtherPlayerLayer()
	local name = "WaitOtherPlayerLayer"
	self:removeLayer( name )
end

function LandGameMainScene:removeLandMatchTipsWinLose()
	local name = "MatchTipsLayerWinLose"
	self:removeLayer( name )
end

function LandGameMainScene:addJiangZhuangLayer()
	local name = "JiangZhuangLayer"
	self:removeLayer( name )
	self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandJiangZhuangLayer" , 99999 , self:getGameAtom() )
end

function LandGameMainScene:removeLayer( name )
	if not self.layer_tbl or not self.layer_tbl[name] then return end
	self:removeChild( self.layer_tbl[name] )
	self.layer_tbl[name] = nil
end

function LandGameMainScene:addLayer( name , path , order , ... )
	if not self.layer_tbl then self.layer_tbl = {} end
	if self.layer_tbl[name] then return end
	self.layer_tbl[name] = RequireEX( path ).new( self , ... )
	self:addChild( self.layer_tbl[name] , order )
	return self.layer_tbl[name]
end

function LandGameMainScene:removeAllLayer( _stayTBL )
	if not self.layer_tbl then return end
	local stayTBL = _stayTBL or {}
	for k,v in pairs( self.layer_tbl ) do
		if not stayTBL[k] then
			self:removeChild( v )
			self.layer_tbl[k] = nil
		end
	end
end

function LandGameMainScene:getJiangZhuangLayer()
	if not self.layer_tbl then return end
	return self.layer_tbl["JiangZhuangLayer"]
end

function LandGameMainScene:getDDSMatchTipsLayer()
	if not self.layer_tbl then return end
	return self.layer_tbl["DDSMatchTipsLayer"]
end

function LandGameMainScene:getMatchTipsGameBegin()
	if not self.layer_tbl then return end
	return self.layer_tbl["MatchTipsLayerGameBegin"]
end

function LandGameMainScene:getMatchTipsLun()
	if not self.layer_tbl then return end
	return self.layer_tbl["MatchTipsLayerGameLun"]
end

function LandGameMainScene:getMatchTipsWinLose()
	if not self.layer_tbl then return end
	return self.layer_tbl["MatchTipsLayerWinLose"]
end

function LandGameMainScene:getGameLayer()
	if not self.layer_tbl then return end
	return self.layer_tbl["GameLayer"]
end

function LandGameMainScene:addBGLayer()
	self.gameRoomBgLayer = RequireEX( "src.app.game.pdk.src.classicland.view.GameLandBGLayer" ).new(self:getGameAtom())
	self:addChild( self.gameRoomBgLayer , -1 )
end

----------功能设置面板----------
function LandGameMainScene:addSystemSetLayer()
	self.m_landSystemSet = LandSystemSet.new( self , self:getGameAtom())
	self:addChild(self.m_landSystemSet,4)
	self.m_landSystemSet:setVisible(true)
end

function LandGameMainScene:setSelfChatUIPos()
	print("表情位置--------------->>")
	if not self.m_landSystemSet then return end
	local myAcc = Player:getAccountID()
	local expressionPos1 = cc.p(195,230)
	local expressionPos  = cc.p(215,280)
	self.m_landSystemSet:updatePlayerIDS( myAcc , expressionPos1 , expressionPos )
end

-------------对外接口开始------------
function LandGameMainScene:getGameAtom()
	return self.game_atom
end

function LandGameMainScene:setGameState( num )
	self.game_state = num
end

function LandGameMainScene:getGameState()
	return self.game_state or 0
end

-------------牌局回放专用代码开始-----------
function LandGameMainScene:getReplayBtnLayer()
	if not self.layer_tbl then return end
	return self.layer_tbl["FriendReplayBtnLayer"]
end

function LandGameMainScene:addReplayBtnLayer( gameID )
    local name = "FriendReplayBtnLayer"
	self:removeLayer( name )
	return self:addLayer( name , "src.app.game.pdk.src.friendland.view.FriendReplayBtnLayer" , 2 , gameID )
end
-------------牌局回放专用代码结束-----------
-------------牌友房专用代码开始-----------
function LandGameMainScene:clearGameUI()
	local stayTBL = 
	{
		["GameLayer"] = 1,
	}
    self:removeAllLayer( stayTBL )
	local layer = self:getGameLayer()
	if not layer then return end
	layer:clearAllPokerOut()
end

function LandGameMainScene:clearUIForGoon()
	local layer = self:getGameLayer()
	if not layer then return end
	layer:clearUIForGoon()

	self.gameRoomBgLayer:resetTopPanel()
	self.gameRoomBgLayer:showMyHead()
end

-- 游戏总结束
function LandGameMainScene:OnAllGameEnd(_info)
    self:clearGameUI()
    self:createAllGameEndLayer(_info.m_lvrGameOverData,2)
end

function LandGameMainScene:updateOffLineFlag()
	local layer = self:getGameLayer()
	print("updateOffLineFlag",layer)
	if not layer then return end
	layer:updateOffLine( self.player_tbl )
end

function LandGameMainScene:setJieShanGameLayerVisible(isVisible)
    LogINFO("function LandGameMainScene:removeJieShanGameLayerKe()")
    
    if self.m_FriendJieSaningLayer then
        self.m_FriendJieSaningLayer:statusTimerEnd()
        self.m_FriendJieSaningLayer:setVisible(isVisible)  
    end
end

function LandGameMainScene:updateJieShanGameLayer(__info)
    LogINFO("LandGameMainScene:updateJieShanGameLayer")
    local idList = {}
    local isAgree  = {}
    local id = 0
    for i=1,#__info.m_lvrDisData do
        idList[i] = __info.m_lvrDisData[i].m_accountId
        isAgree[i] = __info.m_lvrDisData[i].m_isResult
        if __info.m_lvrDisData[i].m_isResult == 0 then
            id = __info.m_lvrDisData[i].m_accountId
        end

    end
    self.m_FriendJieSaningLayer:setVisible(true)
    self.m_FriendJieSaningLayer:updateShow(idList, isAgree, id, __info.m_remainTime)
end

function LandGameMainScene:showJieShanGameLayerKe(m_accountId)
    LogINFO("LandGameMainScene:showJieShanGameLayerKe",m_accountId)
    if self.m_FriendJieSaningLayer then self.m_FriendJieSaningLayer:removeFromParent()  end
    self.m_FriendJieSaningLayer = nil
    self.m_FriendJieSaningLayer = FriendJieSaningLayer.new( self )
    self.m_FriendJieSaningLayer:updateShowKe(m_accountId)
    self.m_FriendJieSaningLayer:setVisible(true) 
    self:addChild(self.m_FriendJieSaningLayer,100)
end

-- 创建游戏结算界面.包括正常结算以及解散游戏结算
function LandGameMainScene:createAllGameEndLayer(m_lvrGameOverData, Gametype)
	--self:removeAllLayer()
    self.mFriendAccountLayer = FriendAccountLayer.new( self )
    self:addChild(self.mFriendAccountLayer, 999)
    self.mFriendAccountLayer:setVisible(true)
    self.mFriendAccountLayer:updateGameResult(m_lvrGameOverData, Gametype)
end

-- 解散游戏总结束
function LandGameMainScene:OnJieShanGameEnd(_info)
    --清掉出的牌
    local stayTBL = 
	{
		["GameLayer"] = 1,
	}

    self:removeAllLayer( stayTBL )

    self:createAllGameEndLayer(_info.m_lvrDisData,1)-- 炸弹数.底分 结算数据
    local layer = self:getGameLayer()
    layer:clearAllPokerOut()
    
    --清掉要不起
    layer:hideTuoGuanPanel()
    layer:setOutCardButtonsVisible(false)
end

function LandGameMainScene:removeJieShanGameLayer()
    LogINFO("LandGameMainScene:removeJieShanGameLayer")
    
    if self.m_FriendJieSaningLayer then
        self.m_FriendJieSaningLayer:statusTimerEnd()
        self.m_FriendJieSaningLayer:removeFromParent()  
    end
    self.m_FriendJieSaningLayer = nil
end

function LandGameMainScene:showJieShanGameLayer(m_accountId)
    LogINFO("LandGameMainScene:showJieShanGameLayer",m_accountId)
    if self.m_FriendJieSaningLayer then self.m_FriendJieSaningLayer:removeFromParent()  end
    self.m_FriendJieSaningLayer = nil
    self.m_FriendJieSaningLayer = FriendJieSaningLayer.new( self )
    self.m_FriendJieSaningLayer:updateShowZhu(m_accountId)
    self.m_FriendJieSaningLayer:setVisible(true) 
    self:addChild(self.m_FriendJieSaningLayer,100)
end

function LandGameMainScene:addCarryOnLayer()
	local name = "FriendCarryOnLayer"
	self:removeLayer( name )
	return self:addLayer( name , "src.app.game.pdk.src.friendland.view.FriendCarryOnLayer" , 2 )
end

function LandGameMainScene:addHappyOpenPokerLayer()
	local name = "HappyOpenPokerLayer"
	self:removeLayer( name )
	return self:addLayer( name , "src.app.game.pdk.src.classicland.view.HappyOpenPokerLayer" , 2 , self.game_atom )
end

function LandGameMainScene:removeHappyOpenPokerLayer()
	local name = "HappyOpenPokerLayer"
	self:removeLayer( name )
end

function LandGameMainScene:getFriendWaitLayer()
	if not self.layer_tbl then return end
	return self.layer_tbl["FriendWaitLayer"]
end

function LandGameMainScene:addFriendWaitLayer( roomID )
	local name = "FriendWaitLayer"
	self:removeLayer( name )
	return self:addLayer( name , "src.app.game.pdk.src.friendland.view.FriendWaitLayer" , 2 , roomID )
end

function LandGameMainScene:updateFriendWaitLayer()
	local layer = self:getFriendWaitLayer()
	if not layer then return end
	layer:updateLayoutTip()
end

function LandGameMainScene:showJieShanNotifyDialog()
	local layer = self:getFriendWaitLayer()
	if not layer then return end
	layer:createFriendJieSanLayer(2)
end

function LandGameMainScene:showForceJieShanDialog()
	local layer = FriendJieSanLayer.new(2)
	self:addChild( layer , 9 )
end

function LandGameMainScene:hideTiRen()
	local layer = self:getGameLayer()
	if not layer then return end
	layer:setTiRen( false )
end

function LandGameMainScene:showTiRen()
	local layer = self:getGameLayer()
	if not layer then return end
	layer:setTiRen( true )
end

function LandGameMainScene:showKickDialog( acc , name )
	local layer = self:getFriendWaitLayer()
	if not layer then return end
	layer:setKickOutLayer( 2 , acc , name )
end

function LandGameMainScene:showMeBeenKickOut()
	local layer = self:getFriendWaitLayer()
	if not layer then return end
	layer:setKickOutLayer(1)
end

function LandGameMainScene:onKickOutOtherSuccess()
	local layer = self:getFriendWaitLayer()
	if not layer then return end
	layer:setKickOutLayer(3)
end

function LandGameMainScene:restoreGameCarryOn( _info )
	local curRound = FriendRoomController:getInstance():getCurRound()
	local ret = math.max(1,curRound-1)
	self:updateMiddleUI( ret ) 
	local myStatus = _info.m_vecValue[self.meChair]
	if myStatus == 0 then
		self:showCarryOnLayer()
	end
end

function LandGameMainScene:updateMiddleUI( _curRound )
    local str = FriendRoomController:getInstance():getRoomInfoStr( _curRound )
    self.gameRoomBgLayer:setFriendRoomLabel( str )
end

function LandGameMainScene:setMiddleUI( curRound , totalRound , limitBoom , double )
	local str = FriendRoomController:getInstance():formatRoomInfo( curRound , totalRound , limitBoom , double )
    self.gameRoomBgLayer:setFriendRoomLabel( str )
end
-------------牌友房专用代码结束-----------

-------------定点赛专用代码开始-----------
-- 是否正在展示赛制提示
function LandGameMainScene:isShowINGTips()
	local layer = self:getDDSMatchTipsLayer()
	if not layer then return end
	return true
end

function LandGameMainScene:ddsToastRet()
	--TOAST("本阶段淘汰人数已满，本局结束后进行积分排名")

	local str = "本阶段淘汰人数已满，本局结束后进行积分排名"
	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new(str, 1, 5)
    ToolKit:addBeginGameNotice(notice, 5)
end

function LandGameMainScene:updateDDSRankLabel()
    local rank    = DDSRoomController:getInstance():getDDSMyRank()
    local curLeft = DDSRoomController:getInstance():getLeftPlayerNum()
    local str = "排名:  "..rank.."/"..PEPLE_COUNT_FORMAT(curLeft)
    self.gameRoomBgLayer:setRankLabel( str )
end

function LandGameMainScene:showDingDianSaiBeginUI( stage )
	self:addLandDDSMatchLayer()
	self:addLandMatchTipsGameBegin()

    local layer = self:getDDSMatchTipsLayer()
	local layerGameBegin = self:getMatchTipsGameBegin()

    LogINFO("LandGameMainScene showDingDianSaiBeginUI 定点赛 打立出局赛制提示")
	layerGameBegin:showGameBeginAnimation(handler(layer, layer.showBeginMatchNode), stage)

end

function LandGameMainScene:showDDSMatchInfo( stage )
    self:updateDDSMatchInfo( DDSRoomController:getInstance():getStopLimitNum() )
end

function LandGameMainScene:updateDDSMatchInfo( _jiezhi )
	local jieZhiNum  = _jiezhi
    local goNext     = DDSRoomController:getInstance():playerNumGoNext()
	local str = "前"..goNext .."名晋级"
	if goNext == 1 then
		str = "冠军争夺战"
	end
	--　不用显示多少人截止,只用显示多少人晋级就好
	if jieZhiNum and jieZhiNum > 0 then
		str = jieZhiNum.."人截止  "..str
	end

	self.gameRoomBgLayer:setMatchInfoLabel( str )
end

function LandGameMainScene:updateFastMatchInfo()
    local goNext     = FastRoomController:getInstance():playerNumGoNext()
	local str = "前"..goNext .."名晋级"
	if goNext == 1 then
		str = "冠军争夺战"
	end

	self.gameRoomBgLayer:setMatchInfoLabel( str )
end

-- 定点赛 显示 赛制提示
function LandGameMainScene:showDingDianSaiJueSaiUI()
	self:addLandDDSMatchLayer()
    local layer = self:getDDSMatchTipsLayer()
    LogINFO("LandGameMainScene showDingDianSaiJueSaiUI 定点赛 末位淘汰赛制提示")
    self:updateDDSMatchInfo()
    layer:showDDSJueSaiTips()
end

function LandGameMainScene:showDDSRoundEndLayer( tag , leftTable )
	local rank    = DDSRoomController:getInstance():getDDSMyRank()
	local gameLayer = self:getGameLayer()
	if gameLayer then
		gameLayer:clearAllPokerOut()
	end
    local layer = self:getRoundEndLayer()
    if not layer then
    	layer = self:addRoundEndLayer()
    end
    layer:updateLeftTableUI( leftTable , rank )
    if tag == "wait" then
        layer:showWaitRankAnimation()
    elseif tag == "jinji" then
        layer:showJinJiAnimation()
    end
end

function LandGameMainScene:getRoundEndLayer( ... )
	if not self.layer_tbl then return end
	return self.layer_tbl["DDSRoundEndLayer"]
end

function LandGameMainScene:addRoundEndLayer()
	local name = "DDSRoundEndLayer"
	self:removeLayer( name )
	return self:addLayer( name , "src.app.game.pdk.src.landcommon.view.match.LandDDSRoundEndLayer" , 5 )
end


-------------定点赛专用代码结束-----------

-------------超快赛专用代码开始-----------
function LandGameMainScene:setDelayForNextRound( num )
	self.delay_for_next_round = math.max( self.delay_for_next_round or 0 , num )
end

function LandGameMainScene:getDelayForNextRound()
	return self.delay_for_next_round
end

function LandGameMainScene:isFastShowINGTips()
	local layer = self:getMatchTipsLun()
	local layerGameBegin = self:getMatchTipsGameBegin()
	if (not layer) or (not layerGameBegin) then return end
	return true

end

function LandGameMainScene:showFastFirstRound()
	self:removeWaitingOtherPlayerLayer()

	-- 经典快速赛 
	local time  = 2  -- 赛制横幅 显示时间
	local time1 = 0  -- 延迟向服务发送准备时间

	if FastRoomController:getInstance():getMatchBeforeGameInfo() and FastRoomController:getInstance():getMatchBeforeGameInfo().isFirstTime == 0 then
		print("应该是重连了 不用播放动画了")
		return 
	end

	self:addLandMatchTipsGameLun()
    local layer = self:getMatchTipsLun()

	if FastRoomController:getInstance():getMatchBeforeGameInfo() and FastRoomController:getInstance():getMatchBeforeGameInfo().isShowMatchBegin == 1 then
		self:addLandMatchTipsGameBegin()
		local layerGameBegin = self:getMatchTipsGameBegin()
		layerGameBegin:showGameBeginAnimation(handler(layer, layer.showFirstNode), time)

		-- 经典快速赛 
		time1 = 2 -- 第一轮的 延迟发送确认时间
		if IS_HAPPY_LAND( self:getGameAtom() ) then
		-- 欢乐快速赛
			time1 = 4  -- 第一轮的 延迟发送确认时间
		end

		local layer = self:getGameLayer()
		layer:delaySendReady(time1)
	else
		layer:showFirstNode(time)
		-- 经典快速赛
		time1 = 1.7 --非第一轮的 延迟发送确认时间
		if IS_HAPPY_LAND( self:getGameAtom() ) then
		-- 欢乐快速赛
			time1 = 3  --非第一轮的 延迟发送确认时间
		end

		local layer = self:getGameLayer()
		layer:delaySendReady(time1)
	end


end

function LandGameMainScene:showMatchGameResultInfo()
    LogINFO("超快赛一轮的结算")
    
    self.matchGameResultInfo = FastRoomController:getInstance():getMatchGameResultInfo()
    self:updateRankLabel( self.matchGameResultInfo.curRank )

    if self.matchGameResultInfo.mathtype == 2 then  -- 整场比赛结束
    	if self.matchGameResultInfo.curRank == 1 or self.matchGameResultInfo.curRank == 2 then
            self:showDiplomaLayer()
        else
            self:showJiangZhuang()
        end
    else
    	self:addLandMatchTipsWinLose()

    	local layer = self:getMatchTipsWinLose()
    	if self.matchGameResultInfo.mathtype == 0 then
    		layer:showRoundLose()
    		local  function f()
    			if self and self.showJiangZhuang then
    				self:showJiangZhuang()
    			end
    		end
    		scheduler.performWithDelayGlobal(f, 4)
    	elseif self.matchGameResultInfo.mathtype == 1 then
    		layer:showRoundWin()
    		self:setDelayForNextRound(2)
    	end
    end
end

function LandGameMainScene:showTaoTai()
    LogINFO("定点赛淘汰后")
    
    self:addLandMatchTipsWinLose()

    local layer = self:getMatchTipsWinLose()
    layer:showRoundLose()
end

function LandGameMainScene:clearUI()
    self.gameRoomBgLayer:setTopPanelVisible(false)
    self.m_landMainLayer:clearMyCardUI()
    self.m_landMainLayer:clearAllPokerOut()
end

function LandGameMainScene:showDDSMatchGameResult()
	self.matchGameResultInfo = DDSRoomController:getInstance():getMatchGameResultInfo()
	self:showJiangZhuang()
end

function LandGameMainScene:showJiangZhuang()
    self:addJiangZhuangLayer()
    local layer = self:getJiangZhuangLayer()
    layer:setGameAtom( self:getGameAtom() )
    layer:updateUI( self.matchGameResultInfo )
    layer:updateMatchNameLabel( self.roomData.gameKindName..self.roomData.phoneGameName)
end

function LandGameMainScene:showDiplomaLayer()
	local matchGameResultInfo = nil
	if IS_FAST_GAME( self:getGameAtom() ) then
		matchGameResultInfo = FastRoomController:getInstance():getMatchGameResultInfo()
	elseif IS_DING_DIAN_SAI( self:getGameAtom() ) then
		matchGameResultInfo = DDSRoomController:getInstance():getMatchGameResultInfo()
	end
    local _reward = {
           goldCoin = matchGameResultInfo.goldCoin,
           diamond = matchGameResultInfo.diamond,
           itemArr = matchGameResultInfo.itemArr,
    }
	local param = {
		roomName  = self.roomData.gameKindName,
		matchName = self.roomData.phoneGameName, 
		gameRank = matchGameResultInfo.curRank,
		reward = _reward,
		shareZorder = 100,
		gameId = self:getGameAtom(),
        landMainSence = self,
        condition = matchGameResultInfo.contidion
	}

	self:addLayer("GameEndLayer","src.app.game.pdk.src.landcommon.view.match.LandMatchGameEndLayer",5,param)
    
end

function LandGameMainScene:updateRankLabel( _score )
	local matchBeforeGameInfo = FastRoomController:getInstance():getMatchBeforeGameInfo()
	local curRound = matchBeforeGameInfo.roundIndex
	local myScroe = _score
	local AllPeople = matchBeforeGameInfo.lastUpgradeCnt
	if not myScroe then
        if curRound == 1 then
            math.randomseed(os.time())
            myScroe = math.random(1,AllPeople)
        else
            myScroe = matchBeforeGameInfo.lastRank
        end
    end

    local str = "排名 "..myScroe.."/"..PEPLE_COUNT_FORMAT(AllPeople)
    self.gameRoomBgLayer:setRankLabel( str )
end

-------------超快赛专用代码结束-----------
function LandGameMainScene:onGameBeginUI()
	self:removeWaitingOtherPlayerLayer()
	local stayTBL = 
	{
		["FriendWaitLayer"] = 1,
		["FriendReplayBtnLayer"] = 1,
	}
	--if IS_DING_DIAN_SAI( self:getGameAtom() ) then
		stayTBL["DDSMatchTipsLayer"] = 1
		stayTBL["MatchTipsLayerGameLun"] = 1
		stayTBL["MatchTipsLayerGameBegin"] = 1
		stayTBL["MatchTipsLayerWinLose"] = 1
	--end
	self:removeAllLayer( stayTBL )
	self:addGameLayer()
	local layer = self:getGameLayer()
	layer:setGameAtom( self:getGameAtom() )
	self.gameRoomBgLayer:resetTopPanel()
	self.gameRoomBgLayer:setTopTypePanelVisible(false)
	self.gameRoomBgLayer:updateStartCentUI( self.minScore )
	layer:setMeChairID( self.meChair )
	layer:initChairTable( self.player_tbl )
	self.gameRoomBgLayer:removeWaitAni()
	
	self.m_landMainLayer:refreshView();
end

function LandGameMainScene:reciveRoomMsg( atomID  , roomID )
	self.roomData = RoomData:getRoomDataById( atomID )
	self.gameRoomBgLayer:setRoomInfo( atomID , roomID )
--	self:addSystemSetLayer()
end

function LandGameMainScene:hideLabelCentLabelDouble()
	self.gameRoomBgLayer:hideStartCent()
	self.gameRoomBgLayer:hideDoubleLabel()
end

function LandGameMainScene:reciveChairTable( players , meChair , cent )
	LogINFO("主场景接收到玩家列表")
	self:setPlayerTBL( players )
	self.meChair = meChair
    if g_GameController:isMatchGame() then
        self.minScore = cent
    else
	    self.minScore = cent*0.01
    end
	self:onGameBeginUI()
end

function LandGameMainScene:setPlayerTBL( tbl )
	self.player_tbl = tbl
end

function LandGameMainScene:updatePlayerTbl( vec )
	if not self.player_tbl then return end
	for k,v in pairs( self.player_tbl ) do
		local score = v:getGameScore()
		if score then
			local ret =  score + vec[k]
			v:setGameScore( ret )
		else
			score = v:getGoldCoin()
			local ret =  score + vec[k]*0.01
			v:setGoldCoin( ret )
		end
	end
end

function LandGameMainScene:updateJueSaiRank()
	if not IS_FAST_GAME( self.game_atom ) then return end
	local goNext = FastRoomController:getInstance():playerNumGoNext()
	if goNext == 1 then
		local rank = self:calMyFakeRank()
		self:updateRankLabel( rank )
	end
end

function LandGameMainScene:calMyFakeRank()
	LogINFO("超快赛最后一轮客户端根据分数实时计算排名")
	local rank = 1
	local myScore = self.player_tbl[self.meChair]:getGameScore()
	for k,v in pairs( self.player_tbl ) do
		local num = v:getGameScore()
		if num > myScore then
			rank = rank + 1
		end
	end
	return rank
end

function LandGameMainScene:reciveGameServerOldMsg( _idStr, _info  )
	-- body
	if _idStr == "CS_G2C_LandLord_Result_Nty" or _idStr == "CS_G2C_HLLand_Result_Nty" then
        if g_GameController:isMatchGame() then
			--self.gameRoomBgLayer:playMatchWaitAni()
			--m_vecScore
			--self:showMatchWaitView()
			for k, v in pairs(self.player_tbl) do
				local score = _info.m_vecScore[v:getChairId()];
				v:setGameScore(v:getGameScore() + score);
			end

			self:clearUI()
			if _info.m_nCurRound == _info.m_nTotalRound then
				self:closeGameSvrConnect()
			end
        else
		    self:reciveGameResult( _info )
        end
	elseif _idStr == "CS_G2C_LandLord_CarryOn_Nty" then
		self:reciveGameCarryOn( _info )
	elseif _idStr == "CS_G2C_LandLord_LoginData_Nty" then
		self.m_eRoundState = _info.m_eRoundState
		if IS_FREE_ROOM(self:getGameAtom()) and _info.m_eRoundState == 4 then --游戏已经结束的状态,直接强框,不展示别的消息
            self:showGameMainTainDialog({message="本局游戏已结束,请退出"})
        else  	
			self:removeLayer("FriendWaitLayer")
			self:hideTiRen()
		end
	elseif _idStr == "CS_G2C_LandLord_ReconnectData_Nty" then
		-- 断线重连
	elseif _idStr == "CS_G2C_LandLord_Begin_Nty" then
		g_GameController.m_inning = _info.m_nCurRound;
		self:hideMatchResultView();
		self:hideMatchWaitView();
		self:reciveGameBegin( _info )
		self:updateJueSaiRank()
		self.m_landMainLayer:refreshView();
	elseif _idStr == "CS_G2C_HLLand_Begin_Nty" then
		
		self:removeWaitingOtherPlayerLayer()
		self:removeAllLayer( {["MatchTipsLayerGameLun"] = 1,} )
		self:addGameLayer()
		local layer = self:getGameLayer()
		layer:setGameAtom( self:getGameAtom() )
		self.gameRoomBgLayer:resetTopPanel()
		self.gameRoomBgLayer:updateStartCentUI( self.minScore )
		layer:setMeChairID( self.meChair )
		layer:initChairTable( self.player_tbl )
		self:updateJueSaiRank()
		
	elseif _idStr == "CS_G2C_UserLeft_Ack" then
		g_GameController:releaseInstance()
		return
	end
	return _idStr, _info
end

function LandGameMainScene:reciveGameBegin( _info )
	self:removeLayer("DDSMatchTipsLayer")
	--display:getRunningScene():removeChildByName("MatchResultOneLayer");
	self:onGameBeginUI()
	if IS_FAST_GAME( self:getGameAtom() ) then
		FastRoomController:getInstance():setCurJU( _info.m_nCurRound )
		FastRoomController:getInstance():setTotalJU( _info.m_nTotalRound )
	end

	if IS_PAI_YOU_FANG( self:getGameAtom() ) then
		FriendRoomController:getInstance():setTotalRound( _info.m_nTotalRound )
		FriendRoomController:getInstance():setCurRound( _info.m_nCurRound )
		self:updateMiddleUI()
	end
end

function LandGameMainScene:reciveGameResult( _info )
	self.m_isSpring      = _info.m_bSpring
	self.m_totalMultiple = _info.m_nTotalMultiple
	self.m_bombsNumber   = _info.m_nTotalBombs
	self.userGameScores  = _info.m_vecScore
	self.lordLandCent    = _info.m_nLandCent

	self.userGameScores = {}
	for k,v in pairs(_info.m_allResult) do
		self.userGameScores[k] = v.m_calScore
		if v.m_cardCount == 0 then
			self.m_nEndPos       = k
		end
	end
	self:updatePlayerTbl( _info.m_vecScore)

	if IS_PAI_YOU_FANG( self:getGameAtom() ) then
		if _info.m_nCurRound < _info.m_nTotalRound then
			self:showCarryOnLayer(5)
		end
	end
	
	if IS_FREE_ROOM( self:getGameAtom() ) and IS_CLASSIC_LAND(self:getGameAtom())then
		self:showFenXiang()	
	end
end

function LandGameMainScene:reciveGameCarryOn( _info )
	if _info.m_nPosition == self.meChair then
		self:removeLayer("FriendCarryOnLayer")
	end
end

function LandGameMainScene:showCarryOnLayer( _delay )
	local delay = _delay or 0
	local function f()
		-- local layer  = self:getGameLayer()
		-- if layer then
		-- 	layer:clearAllPokerOut()
		-- end
		self:addCarryOnLayer()
	end
	scheduler.performWithDelayGlobal(f,delay)
end

function LandGameMainScene:onSysEnd()
	-- if not self.m_eRoundState then
	-- 	return
	-- end
	-- if self.m_eRoundState == LandGlobalDefine.GAME_END then
	-- 	return
	-- end
	if self.m_landAccountLayer then
		print("function LandGameMainScene:onSysEnd()")
		self.m_landAccountLayer:setContinueButtonEnable(true)
	end
end

function LandGameMainScene:showFenXiang()
	local layer = self:getGameLayer()
	local retFlag = layer:winOrLose( self.m_nEndPos )
	LogINFO("显示经典跑得快分享界面,输赢结果",retFlag,self.m_nEndPos)

	local gameEndPram = {}
    -- gameEndPram.Wbeishu    = self.m_totalMultiple
    -- gameEndPram.bChuntian  = self.m_isSpring
    gameEndPram.lGameScore = self.userGameScores
    gameEndPram.bCardData  = {}
    gameEndPram.lBombScore = self.userBombScores
    gameEndPram.m_indemnityChairId = self.m_indemnityChairId
    gameEndPram.nRemainCount = self.userRemainCount
    -- gameEndPram.bomCount   = self.m_bombsNumber

    -- gameEndPram.baseNum   = self.lordLandCent
    -- gameEndPram.minScore = self.minScore

	local layer    = self:getGameLayer()
    gameEndPram.meChair   = layer:getMeChairID()
    -- gameEndPram.lordChair = layer:getLordChair()

    -- -- 在输的情况下, 我托管,我的队友肯定是0,地主肯定是
    -- local isChen = false
    -- for i=1,#gameEndPram.lGameScore do
    --     if gameEndPram.lGameScore[i] == 0 then
    --         isChen = true
    --     end
    -- end
    -- gameEndPram.isChen = isChen

    layer:clearAllPokerOut() 
    self:removeChildByTag(1000)
	self.m_landAccountLayer = LandAccounts.new( self , retFlag, self.game_atom, gameEndPram)
    self:addChild(self.m_landAccountLayer,  12,1000) 
    -- self.m_landAccountLayer:updateGameResult(gameEndPram,retFlag)
    self.m_landAccountLayer:setContinueButtonEnable(true)
--    self:closeGameSvrConnect()
    self.m_landAccountLayer:setVisible(false)
    local func = function()
         self.m_landAccountLayer:setVisible(true)
    end
	
	if self._schedulerEnd then
		scheduler.unscheduleGlobal(self._schedulerEnd)
		self._schedulerEnd = nil
	end
	
	if not self._schedulerEnd then
		self._schedulerEnd = scheduler.performWithDelayGlobal(func, 2)
	end
end

function LandGameMainScene:showWinLose()
	LogINFO("播放胜利失败动画")
	self.m_landMainLayer:playWinLoseAnimation()
end

function LandGameMainScene:sendToLayer( funName , _info )
	local layer = self:getGameLayer()
	if layer and type( layer[ funName ] ) == "function" then
		layer[ funName ]( layer , _info )
	end
end

function LandGameMainScene:getLandGameType()
	local ret = LandGlobalDefine.CLASSIC_LAND_TYPE
	if IS_HAPPY_LAND( self:getGameAtom() ) then ret = LandGlobalDefine.HAPPLY_LAND_TYPE end
    return ret
end

function LandGameMainScene:showCardByPer( per )
	local layer = self:getGameLayer()
	layer:showSomeOfMyCard( per )
end

function LandGameMainScene:EnterLandScore()
    print("----------------绘牌完毕了--------------")
    local layer = self:getGameLayer()
    layer:onDrawCardDone()

    local replayLayer = self:getReplayBtnLayer()
    if replayLayer then
    	replayLayer:onDrawCardDone()
    end
end

function LandGameMainScene:OnPassCard()
	local layer = self:getGameLayer()
	layer:onPassCard()
end

function LandGameMainScene:onClockRunToZero()
	local layer = self:getGameLayer()
	layer:setOutCardButtonsVisible(false)
	if self:getGameState() == LandGlobalDefine.GAME_OUTCARD then
		layer:reqStartTuoGuan()
	end
end

function LandGameMainScene:huDongBiaoQing( biaoQingType , targetChair )
	local tag = biaoQingType
	local send_userId = self.player_tbl[self.meChair].m_accountId
	local recive_userId = self.player_tbl[targetChair].m_accountId
	local str_data = tag .. "," .. tostring(send_userId) .. "," .. tostring(recive_userId)
	local str_len = string.len(str_data)
	ConnectManager:send2SceneServer( self.game_atom, "CS_C2M_LVRClientChat_Req", { 5,4,send_userId,str_len,str_data,self.game_atom } )
end

function LandGameMainScene:onAllCardDown()
	self:hideAllInfoPanel()
	local layer = self:getGameLayer()
	if not layer then return end
	layer:updateOutCardBtn()
end

function LandGameMainScene:hideAllInfoPanel()
	local layer = self:getGameLayer()
	if not layer then return end
	layer:hideInfoPanel()
end

function LandGameMainScene:HideRuleLayer()
    if self.m_landGameRuleInfo then
        self.m_landGameRuleInfo:removeFromParent()
        self.m_landGameRuleInfo = nil
    end
end

function LandGameMainScene:showRuleLayer()
	--self:HideRuleLayer()
    self.m_landGameRuleInfo = LandGameRuleInfo.new(self.game_atom)
    self:addChild(self.m_landGameRuleInfo,100)
end

--显示上手牌
function LandGameMainScene:ShowShangShouPai()
    self:HideShangShouPai()

    self.m_lastHandCardLayer = LastHandCardLayer.new( self )
    self:addChild(self.m_lastHandCardLayer,100)
    
    local layer = self:getGameLayer()
    if not layer then return end

	for i=0,2 do
		local isOutCard = 0
		local sCard = layer:getShangShouPai( i )
		if sCard then isOutCard = 1 end
		local card = CardKit:S2C_CONVERT( sCard or {} )
		self.m_lastHandCardLayer:createShanShou(card,i,isOutCard)
	end
end

--隐藏上手牌
function LandGameMainScene:HideShangShouPai()
    if self.m_lastHandCardLayer then
        self.m_lastHandCardLayer:removeFromParent()
        self.m_lastHandCardLayer = nil
    end
end

function LandGameMainScene:showSettingLayer()
    self.m_landMusicSetLayer = LandMusicSetLayer.new( self )
    self:addChild(self.m_landMusicSetLayer,100)
   -- self.m_landMusicSetLayer:CheckSoundStatus()
end

function LandGameMainScene:showExitGameLayer( str )
    if self.m_ExitGameLayer then 
       self.m_ExitGameLayer:setVisible(true) 
    else
       self.m_ExitGameLayer = ExitGameLayer.new( self , self:getGameAtom() )
       self.m_ExitGameLayer:setVisible(true) 
       self:addChild(self.m_ExitGameLayer,100)
    end
    LAND_LOAD_OPEN_EFFECT(self.m_ExitGameLayer.exitgameDialogpanel)
    self.m_ExitGameLayer:setRoomName(self:getRoomType())
    self.m_ExitGameLayer:setCenterText(str)
end

function LandGameMainScene:hideExitGameLayer()
	if not self.m_ExitGameLayer then return end 
	self.m_ExitGameLayer:setVisible(false)
end

--房间类型（自由房、比赛房）
function LandGameMainScene:getRoomType()
    local roomType = 0
    if self.roomData then
       roomType = self.roomData.roomType
    end
    return roomType
end

function LandGameMainScene:onClickEmptySpace()
	local layer = self:getGameLayer()
	layer:onClickEmptySpace()
end


function LandGameMainScene:OnLeftHitCard(__curentValaue)
	local layer = self:getGameLayer()
	layer:onLeftHitCard( __curentValaue )
end

--划牌回调
function LandGameMainScene:OnMoveSelectCard( __selectCards )
    LogINFO("划牌回调")
    local layer = self:getGameLayer()
    layer:onMoveSelectCard( __selectCards )
end

function LandGameMainScene:OnSendCardFinish()
	
end

function LandGameMainScene:OnTuoGuan( bFlag )
	local layer = self:getGameLayer()
    layer:reqCancelTuoGuan()
end

--[[
function LandGameMainScene:closeGameSocket()
	LogINFO("离开跑得快打牌界面,主动关闭游戏服链接")
	self:closeGameSvrConnect()
	g_GameController:clearGameNetData()
    g_GameController:releaseInstance()
end

function LandGameMainScene:onExitSysGame()
	self:closeGameSocket()
	POP_GAME_SCENE()
end
--]]

function LandGameMainScene:hideTimeLabel()
	if self.gameRoomBgLayer then
		self.gameRoomBgLayer:hideTimeLabel()
	end
end

--退出之后发一个场景退出 则不会再收到场景发来消息
--[[
function LandGameMainScene:reqExitGameScene()
	self:closeGameSocket() 
end
--]]

function LandGameMainScene:exit()
	--[[
    if IS_FREE_ROOM(self:getGameAtom()) then
        LogINFO("金币房退出直接向服务器发送第一次请求")
        print("GameState", self:getGameState())
        if self.m_landAccountLayer or self:getGameState() < 1 then
            g_GameController:reqSysExitGame(0)
        else
            g_GameController:reqUserLeftGameServer()
        end
    else
        print("a")
        if self:getGameState() < 1 then -- 未开局
            g_GameController:reqSysExitGame(0)
        else
            self:showExitGameLayer()
        end
    end
	--]]
	print("GameState", self:getGameState())
	if self.m_landAccountLayer or self:getGameState() < 1 then
		g_GameController:reqSysExitGame(0)
	else
		g_GameController:reqUserLeftGameServer()
	end
    if self.m_landSystemSet then
        self.m_landSystemSet:hideFuctionButtons()
    end
end

--[[
function LandGameMainScene:exitGame() 
	UIAdapter:popScene() 
end
--]]

function LandGameMainScene:onAgainGame()
	LogINFO("结算界面点击再来一局按钮")
--	local atom = self:getGameAtom()
--	if IS_FREE_ROOM( atom ) then
--		POP_GAME_SCENE()
--		local layer = SHOW_GAME_ROOM_BG( atom )
--		if layer then
--			layer:showQiaoLuoDaGu()
--		end
--	end
--	REQ_ENTER_SCENE( atom )
    self:clearUI()
--    if self.m_landAccountLayer then
--        self.m_landAccountLayer:setVisible(false) 
--    end
    local layer = self:getGameLayer()
    layer.mTextRecord:setString("")
    for k,v in pairs( layer.game_chair_tbl ) do
        v:removeFromParent()
        v = nil
    end
    layer.game_chair_tbl= {}
--    if layer.m_landAccountLayer then
--         layer.m_landAccountLayer:setVisible(false) 
--    end

	if g_GameController:gameKickOutDefault() then return end

    g_GameController:reqContinueGame()
end

function LandGameMainScene:createAction(node, callback1, callback2, time)

    local callback  = function ()
    	if callback1 then
    		callback1()
    	end
    end
    local callbackend = function () 
    	if callback2 then
    		callback2()
    	end
    end

    local delay = cc.DelayTime:create(1)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local repea = cc.Repeat:create(sequence, time)
    local sequ = cc.Sequence:create(repea, cc.CallFunc:create(callbackend))
    node:runAction(sequ)
end

function LandGameMainScene:onEnterBackGround()
	self.enter_background_time = os.time()
    g_GameController.m_BackGroudFlag=true
	LogINFO("跑得快打牌界面挂起到后台",self.enter_background_time)
end

function LandGameMainScene:onEnterForeground() 
--	if timeGap < 15 then
--		local layer = self:getGameLayer()
--		if layer then
--			layer:comeBackCallScore( timeGap )
--		end
--	end
end

--走重连流程
--[[
function LandGameMainScene:reconnect()
     if self.reconnectLandLordDlg and self.reconnectLandLordDlg.closeDialog then
        self.reconnectLandLordDlg:closeDialog()
        self.reconnectLandLordDlg = nil
    end
    ConnectManager:reconnect()
end
--]]

--- 大厅踢下线处理
--- 包括顶号以及其他踢人情况。
--[[
function LandGameMainScene:onMsgKickNotice( __msg , __info )
	LogINFO("收到被踢被顶号通知")

	local frozenReason = -305 --platformErrCode -305是账号冻结
    local number = getPublicInfor("phonenub")
    local str = ""
    if __info.m_nOtherTerminalType == 1 or __info.m_nOtherTerminalType == 2 then
      local str_dv = STR(55,5)
        if __info.m_nOtherTerminalType == 2 then
            str_dv = STR(56,5)
        end
        str = STR(53,5)..str_dv..STR(54,5)

	elseif __info.m_nReason == frozenReason then -- new 永久冻结
		--str = STR(86,4) .. number
		str = STR(86,4)
    else
		local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "您已被踢出游戏", tip_size = 34})
        dlg:setSingleBtn("确定", function () 
			self:onBackButtonClicked()
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
        return
    end

    local kickDialog = DlgAlert.new()
    local data = {tip = str, tip_size = 28, areaSize = cc.size(540, 250)}
    local dlg = kickDialog.customTipsAlert(data)
    dlg:enableTouch(nil)
    -- dlg:setBtnAndCallBack( STR(76, 1), STR(87, 4), 
    --function ()
    --    TotalController:onExitApp()
    --end, 
    --function ()
    --    ToolKit:showPhoneCall()
    --end )

    dlg:setSingleBtn(STR(5, 4), function()
        TotalController:onExitApp()
    end)
    
	-- dlg:setTitle(STR(88, 4))
    -- local btn = ToolKit:getLabelBtn({str = number}, ToolKit.showPhoneCall)
    -- btn:setPosition(cc.p(-15, -10))
    -- dlg:setContent(btn)

    self:setBackEventFlag(false)
    --被顶号后关闭断线检测
    ConnectionUtil:setCallback(function ( network_state )
        
    end)
    TotalController:stopToSendHallPing()
    
end
--]]

--[[
function LandGameMainScene:onGameReconnectResult( msgName, msgObj )
	LogINFO("跑得快打牌界面接收到大厅重连成功之后发来游戏服状态,",msgObj.m_gameAtomTypeId)
	if msgObj.m_gameAtomTypeId == 0 then
		self:showGameMainTainDialog({message="本局游戏已结束,请退出"})
	end
end

function LandGameMainScene:onStartGame( msgName, protalId, ret )

    if self ~= ToolKit:getCurrentScene() then return end
    if ret.type == 1 and not ret.cancelSignUpId then
    	LogINFO("第一次开赛提醒")
    	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new(ret.message, 1, 10)
        ToolKit:addBeginGameNotice(notice, 10)
        return 
    end
    -- 牌友房时弹房间维护就不走最下边了所以把这个条件分别加在下边的几个分支上
    -- if IS_PAI_YOU_FANG( self.game_atom ) then
    -- 	return 
    -- end
    if not IS_PAI_YOU_FANG( self.game_atom ) and ret.type == 1 and ret.cancelSignUpId then
    	LogINFO("第二次开赛提醒")
    	self:showSecondGameStartTip( ret )
    	return
    end

   	if not IS_PAI_YOU_FANG( self.game_atom ) and ret.enterGameId then
		self:showLastGameStartTip( ret )   		
        return
   	end

   	local old_atom = ret.cancelSignUpId
   	local new_atom = ret.signUpId

   	if not IS_PAI_YOU_FANG( self.game_atom ) and IS_DING_DIAN_SAI( old_atom ) and IS_FAST_GAME( new_atom ) then
        LogINFO("报名满人赛时候,服务器提示和定点赛冲突")
        self:exit()
        local function f()
        	 FastRoomController:getInstance():showXianWanZhe( new_atom , ret.message )
        end
        DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
        return
    end
    if ret.m_msgTipId >=12 and ret.m_msgTipId <= 15 then --tipID在这个范围的为维护提醒 
		self:showGameMainTainDialog( ret )
    end

end
--]]

function LandGameMainScene:showGameMainTainDialog( ret )
	LogINFO("LandGameMainScene 房间维护弹窗")
	local dlg = RequireEX("app.game.pdk.src.landcommon.view.LandDiaLog").new()
	dlg:setContent( ret.message , 26 )
	dlg:hideCloseBtn()
	local function f()
		dlg:closeDialog()
		self:exit()
	end
	dlg:showSingleBtn("确定",f)
end

--[[
function LandGameMainScene:showSecondGameStartTip( ret )
	LogINFO("LandGameMainScene 显示第二次开赛提醒")
	local function callYes()
		LogINFO("开赛就去 暂时没有操作 实际上应该是移除提示条")
	end
	local function callNo()
		MatchSignUpController:getInstance():reqCancelSignUp(  ret.cancelSignUpId )
	end
	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new(ret.message, 2, 10)
	notice:setCallBackNo(callNo)
	notice:setCallBackYes(callYes)
	ToolKit:addBeginGameNotice(notice, 10)  
end

function LandGameMainScene:showLastGameStartTip( ret )
	local function callYes()
		LogINFO("转入到游戏,",ret.enterGameId)
		self:reqExitGameScene()
		if IS_FREE_ROOM( self:getGameAtom() ) then
			g_GameController:reqSysExitGame(1)
		end
		if IS_LAND_LORD( ret.enterGameId ) then
			LogINFO("目标游戏是跑得快自己的游戏,不需要退出到一部大厅")
			REQ_ENTER_SCENE( ret.enterGameId )
		else
			LogINFO("目标游戏是其他产品的游戏,强行退出到一部大厅")
		--	g_GameController:forceEnterGame( RoomData.LANDLORD , ret.enterGameId )
		end
	end

	local function callNo()
		MatchSignUpController:getInstance():reqCancelSignUp( ret.enterGameId )
	end


	LogINFO("LandGameMainScene 显示最后一次开赛弹窗")
	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new(ret.message, 3, 10)
    notice:setCallBackNo(callNo)
    notice:setCallBackYes(callYes)
    notice:setPosition(cc.p(display.cx, display.cy))
    notice:setLocalZOrder(999999)
    self:addChild(notice)

    self:setDelayForNextRound(4)
end

function LandGameMainScene:onCancelBaoMingSuccess()
	local notice =  require("src.app.game.pdk.src.landcommon.view.LandRollNotice").new("退赛成功", 1, 3)
    ToolKit:addBeginGameNotice(notice, 3) 
end
--]]
-------------对外接口结束------------
------------------------------------------------------------------------------------------------------------------
---[[
--服务器消息回调
function LandGameMainScene:reciveGameServerMsg( _idStr, _info  )
	print( _idStr )
	dump( _info )
	_idStr, _info = self:reciveGameServerOldMsg(_idStr, _info)
	if not _idStr then return end

	-- 新消息
	if _idStr == "CS_G2C_Run_In_Wait_Nty" then
        self:receiveSceneMsg(_info)
	elseif _idStr == "CS_G2C_Run_In_PlayGame_Nty" then
        self:receiveSceneMsg(_info)
	elseif _idStr == "CS_G2C_Run_Begin_Nty" then
		self:reciveGameBeginNty( _info )
	elseif _idStr == "CS_G2C_Run_GameEnd_Nty" then
		if g_GameController:isMatchGame() then
			--self.gameRoomBgLayer:playMatchWaitAni()
			--m_vecScore
			--self:showMatchWaitView()
			for k, v in pairs(self.player_tbl) do
				local score = _info.m_allResult[v:getChairId()].m_netProfit
				v:setGameScore(v:getGameScore() + score);
			end
			self:clearUI()
			if _info.m_nCurRound == _info.m_nTotalRound then
				self:closeGameSvrConnect()
			end
        else
		    self:reciveGameResultNty( _info )
        end
	elseif _idStr == "CS_G2C_UserLeft_Ack" then
		g_GameController:releaseInstance()
		return
	end
	
	local funName = string.sub( _idStr , 8 , -1 )
	print("funName:::", funName)
	self:sendToLayer( funName , _info )
end
function LandGameMainScene:reciveGameBeginNty( _info )
	g_GameController.m_inning = _info.m_nCurRound;
	scheduler.performWithDelayGlobal( function ( ... )
		self:hideMatchResultView();
		self:hideMatchWaitView();
	end , 1)
	self:removeLayer("DDSMatchTipsLayer")
	self:removeWaitingOtherPlayerLayer()
	local stayTBL = 
	{
		["FriendWaitLayer"] = 1,
		["FriendReplayBtnLayer"] = 1,
	}
	--if IS_DING_DIAN_SAI( self:getGameAtom() ) then
		stayTBL["DDSMatchTipsLayer"] = 1
		stayTBL["MatchTipsLayerGameLun"] = 1
		stayTBL["MatchTipsLayerGameBegin"] = 1
		stayTBL["MatchTipsLayerWinLose"] = 1
	--end
	self:removeAllLayer( stayTBL )
	self:addGameLayer()
	local layer = self:getGameLayer()
	layer:setGameAtom( self:getGameAtom() )
	self.gameRoomBgLayer:resetTopPanel()
	self.gameRoomBgLayer:setTopTypePanelVisible(false)
	self.gameRoomBgLayer:updateStartCentUI( self.minScore )
	layer:setMeChairID( self.meChair )
	layer:initChairTable( self.player_tbl )
	self.gameRoomBgLayer:removeWaitAni()
	
	self.m_landMainLayer:refreshView();
	-- if IS_FAST_GAME( self:getGameAtom() ) then
	-- 	FastRoomController:getInstance():setCurJU( _info.m_nCurRound )
	-- 	FastRoomController:getInstance():setTotalJU( _info.m_nTotalRound )
	-- end
end
function LandGameMainScene:reciveGameResultNty( _info )
	self.m_indemnityChairId = _info.m_indemnityChairId
	self.userGameScores = {}
	self.userBombScores = {}
	self.userRemainCount = {}
	for k,v in pairs(_info.m_allResult) do
		local chairKey = v.m_chairId
		self.userGameScores[chairKey] = v.m_netProfit
		self.userBombScores[chairKey] = v.m_bombScore
		self.userRemainCount[chairKey] = v.m_cardCount
		if v.m_cardCount == 0 then
			self.m_nEndPos       = chairKey
		end
	end
	self:updatePlayerTbl(self.userGameScores)
	if not g_GameController:isMatchGame() then
		self:showFenXiang()	
	end
end
function LandGameMainScene:receiveSceneMsg(__info) 
	if __info.m_cell then self.minScore = __info.m_cell * 0.01 end
	self.gameRoomBgLayer:removeWaitAni()
	self:removeWaitingOtherPlayerLayer()
	self:removeAllLayer( {["MatchTipsLayerGameLun"] = 1,} )
	self:addGameLayer()
	local layer = self:getGameLayer()
	layer:setGameAtom( self:getGameAtom() )
	self.gameRoomBgLayer:resetTopPanel()
	self.gameRoomBgLayer:updateStartCentUI( self.minScore )
	self:updateJueSaiRank()
end
function LandGameMainScene:onRefreshPlayerInfo(__info)
	if __info.m_cell then self.minScore = __info.m_cell * 0.01 end
	local tPlayers, meChairID = g_GameController:onInitTablePlayerInfo(__info)

	-- dump(__info, "onRefreshPlayxxxxxerInfxxo")
	dump(tPlayers, "onRefreshPlayxxxxxerInfo")
	self.meChair = meChairID
	self:setPlayerTBL( tPlayers )
	if self:getGameLayer() then
		self:getGameLayer():setMeChairID( meChairID )
		self:getGameLayer():Run_onShowChairTable( tPlayers, meChairID )
	end
end
--]]

return LandGameMainScene