-- FriendRoomController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 牌友房场景管理器
local scheduler = require("framework.scheduler")
local GamePlayerInfo = require("src.app.game.common.data.GamePlayerInfo")
local FriendRoomController = class("FriendRoomController")
local EventManager = require("app.game.pdk.src.common.EventManager")
local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

FriendRoomController.instance = FriendRoomController.instance or nil

function FriendRoomController:getInstance()
	if FriendRoomController.instance == nil then
		FriendRoomController.instance = FriendRoomController.new()
	end
	return FriendRoomController.instance
end

function FriendRoomController:ctor()
	
end

function FriendRoomController:LandVipRoomEnter( info )
	LogINFO("收到跑得快牌友房发来进入场景结果")
	ToolKit:removeLoadingDialog()
end

function FriendRoomController:onClickTiRen( chairID )
	LogINFO("牌友房点击踢人按钮,目标椅子ID",chairID)
	local p = self:getPlayerInfoByChairId( chairID )
	FRIEND_ROOM_SCENE_DO("showKickDialog",p:getAccountId(),p:getNickname())
end

function FriendRoomController:onClickGoBack( roomID )
	local myCreateRoomID = self:getRoomInfo()
	LogINFO("点击了返回大厅按钮,房间号",roomID,myCreateRoomID)
	if roomID == myCreateRoomID then
		self:onFangZhuGoBack()
	end
end

function FriendRoomController:reqEnterVipScene()
	ToolKit:addLoadingDialog(3, "正在进入")
	REQ_ENTER_SCENE( LandGlobalDefine.FRIEND_ROOM_GAME_ID )
end

function FriendRoomController:clearEnterSceneReason()
	self.enter_reason = false
end

function FriendRoomController:getEnterSceneReason()
	return self.enter_reason
end

function FriendRoomController:sendCreateRoom( info )
	LogINFO("发送创建房间协议")
	dump( info )
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_CreateLandVipRoom_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID, info.mJu, info.mJia, info.mZaDan, info.isCreateForOther } )
end

function FriendRoomController:notifyClearRoom()
	LogINFO("接收到服务器发来清空自己的牌友房房间通知")
	self:clearRoomInfo()
end

function FriendRoomController:clearRoomInfo()
	self.roomInfo = nil
end

function FriendRoomController:setRoomInfo( __info )
	self.roomInfo = __info
end

function FriendRoomController:setVipRoomPlayers( roomId , players )
	if not self.vip_rooms then self.vip_rooms = {} end
	self.vip_rooms[ roomId ] = players
end

function FriendRoomController:getVipRoomPlayers( roomId )
	if not self.vip_rooms then return end
	return self.vip_rooms[ roomId ]
end

function FriendRoomController:getRoomInfo()
	if self.roomInfo then
		return self.roomInfo.m_roomId , self.roomInfo
	end
	return 0
end

function FriendRoomController:checkMyselfIsFangzhu()
	--dump(self.roomInfo, "self.roomInfo 1")
	if self.roomInfo then
		if self.roomInfo.m_isReplace == 0 then --不是为别人创建
			local myAcc = Player:getAccountID()
			-- 创建者是我  而且 房间不是为别人创建的
			print(">>>>>>>", self.roomInfo.m_createAccountId, myAcc)
			if self.roomInfo.m_createAccountId == myAcc  then
				return true
			end
		end
	end
end

function FriendRoomController:checkMyselfIsCiFangzhu()
	--dump(self.roomInfo, "self.roomInfo 2")
	if self.roomInfo then
		if self.roomInfo.m_isReplace == 1 then --是为别人创建
			local myAcc = Player:getAccountID()
			-- 第一个加入的人是我
			if self.roomInfo.m_secondAccountId == myAcc  then
				return true
			end
		end
	end
end

function FriendRoomController:checkMyselfIsFangKe()
	if not self:checkMyselfIsFangzhu() and not self:checkMyselfIsCiFangzhu() then
		return true
	end
end

function FriendRoomController:showFriendMainScene( info )
	PRELOAD_GAME_SCENE( LandGlobalDefine.FRIEND_ROOM_GAME_ID )
	local function f()
		local scene = PUSH_GAME_SCENE( LandGlobalDefine.FRIEND_ROOM_GAME_ID )
		scene:reciveRoomMsg( LandGlobalDefine.FRIEND_ROOM_GAME_ID , info.m_roomId )
		scene:updateMiddleUI()
		if info.m_isReEnter and info.m_isReEnter == 2 then

		else
			scene:addFriendWaitLayer( info.m_roomId )
			scene:setSelfChatUIPos()
		end

		if #self.__players > 1 then
			scene:reciveChairTable( self.__players , self.meChair , 0 )
			scene:updateFriendWaitLayer()
			if self:checkMyselfIsFangzhu() or self:checkMyselfIsCiFangzhu() then
				scene:showTiRen()
			end

		end
	end
	DO_ON_FRAME( GET_CUR_FRAME()+1 , f )
end

-- 房主返回后 再次加入
function FriendRoomController:backJionin()
	local myCreateRoomID , roomInfo = self:getRoomInfo()
	LogINFO("房主返回给自己创建的房间",myCreateRoomID)
	if roomInfo then
		self.__players = self:getVipRoomPlayers( roomInfo.m_roomId )
		self:showFriendMainScene( roomInfo )
	end
end

function FriendRoomController:t_ackCreateLandVipRoom()--CS_M2C_CreateLandVipRoom_Ack
	print("创建成功后,回调到这里, 主动发起进入房间请求 回调到t_ackEnterLandVipRoom")
	DOHALL("showDefaultView")
	self:reqEnterVipScene()
end
--CS_M2C_EnterLandipRoomResult_Ack
function FriendRoomController:ackEnterSuccess()--CS_M2C_EnterLandVipRoomResult_Ack
	print("加入别人的房间 成功 后回调到这里,再发起进入房间请求 回调到t_ackEnterLandVipRoom")
	DOHALL("showDefaultView")
	self:reqEnterVipScene()
end

function FriendRoomController:ackCreateaForOther(__info)
	DOHALL( "createUICreateSsful" , __info )
end

function FriendRoomController:t_ackEnterLandVipRoom(__info)
	LogINFO("FriendRoomController:t_ackEnterLandVipRoom 进入房间")
	if __info.m_isReEnter >= 1 then
		LogINFO("牌友房 1:断线(或强退)重连")
	end
	
	self.__roomId = __info.m_roomId 					-- 房间ID
	self.__minScore = __info.m_minScore					-- 最小分
	self:setCurRound( __info.m_curRound )
	self:setTotalRound( __info.m_innings )
	self:setLimitOfBoom( __info.m_limitOfBomb )
	self:setIsDouble( __info.m_isDouble )
	self.__players = {}
	self.__gameAtomTypeId = __info.m_gameAtomTypeId		-- LandGlobalDefine.FRIEND_ROOM_GAME_ID

	-- 这时只下发了一个椅子ID 其它消息都没有自己构造一个
	local info = GamePlayerInfo.new()
	self.__players[__info.m_chairId] = info
	info:setChairId(__info.m_chairId)
	info:setAccountId(Player:getAccountID())  
	info:setFaceId(Player:getParam("FaceID"))
	info:setNickname(Player:getParam("NickName"))
	-- 这两项不知道要不要
	info:setGoldCoin(Player:getParam("GoldCoin"))
	info:setGameScore(0)

	__info.__players = self.__players

	self:setRoomInfo( __info )
	self:showFriendMainScene( __info )
end

function FriendRoomController:t_ackDismissLandVipRoom(__info)
	LogINFO("解散房间结果 ")
	if __info.m_result ==0 then
		local myCreateRoomID = self:getRoomInfo()
		if __info.m_roomId == myCreateRoomID then
			self:clearRoomInfo()
		end
		if __info.m_accountId == Player:getAccountID() then
			if __info.m_isInRoom == 1 then -- 房主也在房间
				POP_GAME_SCENE()
				LogINFO("解散房间成功!,房主在房间")
				local function f()
					DOHALL_CENTER("updateJoinBtn")
				end
				DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
				--DO_ON_FRAME()
			else
				self:disMissRoom( __info.m_roomId )
			end
		else
			FRIEND_ROOM_SCENE_DO("showJieShanNotifyDialog")
		end
	end
end

function FriendRoomController:t_ackLandVipRoomBeforeGameTable( _info )
	local acc = _info.m_takeAccountId
	LogINFO("牌友房接到服务器广播玩家进出信息,帐号:",acc)
	self:initPaiYouFangPlayer( _info )
end

function FriendRoomController:initPaiYouFangPlayer( __info )
	-- 房间玩家信息解析
	self.meChair   = nil
	local myAcc    = Player:getAccountID()
	self.__players = {}

	for k,v in pairs( __info.m_memberList ) do
		if v.m_accountId ~= 0 then
			if v.m_accountId == myAcc then self.meChair = v.m_chairId end
			local info = GamePlayerInfo.new()
			self.__players[v.m_chairId] = info
			info:setChairId(v.m_chairId)
			info:setAccountId(v.m_accountId)  
			info:setFaceId(v.m_faceId)
			info:setNickname(v.m_nickname)
			-- 这两项不知道要不要
			info:setGoldCoin(0)
			info:setGameScore( v.m_score )
			info.m_offine = v.m_offine
		end
	end

	self:setVipRoomPlayers( __info.m_roomId , self.__players )
	
	local function f()
		FRIEND_ROOM_SCENE_DO("setPlayerTBL",self.__players)
		FRIEND_ROOM_SCENE_DO("updateOffLineFlag")
	end
	DO_ON_FRAME( GET_CUR_FRAME()+2 , f )

	if __info.m_isGame == 0 then
		self:onPlayerChange()
	end
end

function FriendRoomController:onPlayerChange()

	local function f()
		FRIEND_ROOM_SCENE_DO( "reciveChairTable" , self.__players , self.meChair , 0 )
		FRIEND_ROOM_SCENE_DO("updateFriendWaitLayer")

		if self:checkMyselfIsFangzhu() or self:checkMyselfIsCiFangzhu()  then
			FRIEND_ROOM_SCENE_DO("showTiRen")
		end
	end

	DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
end

function FriendRoomController:paiYouFangPlayerLiXian( __info )
	for k,v in pairs( __info.m_memberList ) do
		if v.m_offine == 1 then
			if self.gameScene then
				self.gameScene:onPlayerLiXian( v.m_chairId )
			end
		end
	end
end

function FriendRoomController:paiYouFangPlayerReconnect( __info )
	if self.gameScene then
		local chairId = self:getChairId( __info.m_takeAccountId )
		self.gameScene:onPlayerBehavior( chairId , PLAYER_BEHAVIOR.RECONNECTION )
	end
end

function FriendRoomController:t_ackLandVipRoomKick(__info)
	local player_been_kick = __info.m_accountId
	local tick_m_chairId = nil

	local myAcc = Player:getAccountID()
	for k,v in pairs( self.__players ) do
	   local acc = v:getAccountId()
	   if acc == player_been_kick then
			tick_m_chairId = v.m_chairId
			self.__players[k] = nil
			break
		end
	end

	LogINFO("踢出成员 : " ,player_been_kick ,myAcc, tick_m_chairId)
	if player_been_kick == myAcc then
		LogINFO("我被踢出去了") -- 清理房间信息 
		self:clearRoomInfo()
		FRIEND_ROOM_SCENE_DO("showMeBeenKickOut")
	else
		-- 踢出去一个人,看下我是不是房主了
		FRIEND_ROOM_SCENE_DO("onKickOutOtherSuccess")
		self:onPlayerChange()
	end
end

function FriendRoomController:sendReqJieShanGameing()
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_DismissLVRGame_Req",{LandGlobalDefine.FRIEND_ROOM_GAME_ID})
end

function FriendRoomController:reciveJieShanTongZhi(__info)
	if __info.m_accountId == Player:getAccountID() then
		FRIEND_ROOM_SCENE_DO("showJieShanGameLayer",__info.m_accountId)
	else
		FRIEND_ROOM_SCENE_DO("showJieShanGameLayerKe",__info.m_accountId)
	end
end

function FriendRoomController:sendReqAgreeJieShanGameing(type)
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_IsAgreeLVRGame_Req",{LandGlobalDefine.FRIEND_ROOM_GAME_ID, type})
end

function FriendRoomController:t_ackIsAgreeLVRGame(__info)
	if __info.m_disType == 1 then
		LogINFO("这是强制解散")
		self:clearRoomInfo()
		
		local function f()
			DOHALL_CENTER("updateJoinBtn")
		end
		DO_ON_FRAME( GET_CUR_FRAME()+2 , f )

		FRIEND_ROOM_SCENE_DO("showForceJieShanDialog")
		return
	end
	if __info.m_isReEnter == 0 then  --正常进来
		local function f()
			FRIEND_ROOM_SCENE_DO("updateJieShanGameLayer",__info)
			if __info.m_result == 0 then
				LogINFO("解散成功")
				dump(__info)
				self:clearRoomInfo()
				
				FRIEND_ROOM_SCENE_DO("removeJieShanGameLayer")
				FRIEND_ROOM_SCENE_DO("OnJieShanGameEnd",__info)
				
			else
				local idList = {}
				local isAgree  = {}
				local id = 0
				for i=1,#__info.m_lvrDisData do
					idList[i] = __info.m_lvrDisData[i].m_accountId
					isAgree[i] = __info.m_lvrDisData[i].m_isResult
					if __info.m_lvrDisData[i].m_isResult == 2 then
						id = id + 1
					end
				end
				if id == 2 then
					FRIEND_ROOM_SCENE_DO("setJieShanGameLayerVisible",false)
					TOAST("解散游戏失败!")
				end
			end
		end
		DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
	elseif __info.m_isReEnter == 1 then --重连
		LogINFO("重连进来,解散游戏投票")
		local id = 0
		for i=1,#__info.m_lvrDisData do
			if __info.m_lvrDisData[i].m_isResult == 0 then
				id = __info.m_lvrDisData[i].m_accountId
			end
		end
		

		local function f()
			if id == Player:getAccountID() then
				FRIEND_ROOM_SCENE_DO("showJieShanGameLayer",id)
			else
				FRIEND_ROOM_SCENE_DO("showJieShanGameLayerKe",id)
			end
			FRIEND_ROOM_SCENE_DO("updateJieShanGameLayer",__info)
		end
		DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
	end
end

function FriendRoomController:reciveAllJieShuan(__info)
	LogINFO("游戏总结算")
	self:clearRoomInfo()
	FRIEND_ROOM_SCENE_DO("OnAllGameEnd",__info)
end

function FriendRoomController:reciveFangKeExitRoom(__info)
	LogINFO("退出房间")
	dump(__info)
	if __info.m_pos == self:getChairId(Player:getAccountID()) then
		LogINFO("自己退出")
		self:clearRoomInfo()
		local function f()
			DOHALL_CENTER("updateJoinBtn")
		end
		DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
		POP_GAME_SCENE()
	else
		LogINFO("有人退出")
		self.__players[ __info.m_pos ] = nil
		self.roomInfo.m_secondAccountId =  __info.m_secondAccountId
		self:onPlayerChange()
	end

end

-- 获取椅子id
function FriendRoomController:getChairId( __accountId )
	for k, v in pairs(self.__players) do
		if v:getAccountId() == __accountId then
			return v:getChairId()
		end
	end
	return nil
end

function FriendRoomController:disMissRoom( id )
	--DOHALL("disMissFriendRoom" , id )
	local scene = GET_LORD_SCENE()
	if scene then
		local FriendRoomListLayer = scene:getChildByName("FriendRoomListLayer")
		if FriendRoomListLayer then
			FriendRoomListLayer:removeRoom( id )
		end
	end
end

function FriendRoomController:sendReqMyRoomList()
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomList_Req", {LandGlobalDefine.FRIEND_ROOM_GAME_ID})
end

function FriendRoomController:reciveMyRoomlist(__info)
	local scene = GET_LORD_SCENE()
	if scene then
		local FriendRoomListLayer = scene:getChildByName("FriendRoomListLayer")
		if FriendRoomListLayer then
			FriendRoomListLayer:updateRoomList( __info.m_listData )
		end
	end

end


--请求
function FriendRoomController:sendAddRobot()
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomTest_Req", {1,0,0,0})
end

function FriendRoomController:onFangZhuGoBack()
	FRIEND_ROOM_SCENE_DO("exit")
	local function f()
		TOAST("返回大厅房间仍然保留噢!可以通过返回房间按钮返回房间")
		DOHALL_CENTER("updateJoinBtn")
	end
	DO_ON_FRAME( GET_CUR_FRAME()+2 , f )
end

function FriendRoomController:getPlayerInfoByChairId( __chairId )
	return self.__players[__chairId]
end

function FriendRoomController:getPlayers()
	return self.__players
end

function FriendRoomController:setCurRound( _num )
	self.__curRound = _num
end
function FriendRoomController:getCurRound()
	return self.__curRound or 0
end
function FriendRoomController:setTotalRound( _num )
	self.__totalRound = _num
end
function FriendRoomController:getTotalRound()
	return self.__totalRound or 0
end

function FriendRoomController:getIsDouble()
	return self.__isDouble
end

function FriendRoomController:setIsDouble( _num )
	self.__isDouble = _num
end

function FriendRoomController:setLimitOfBoom( _num )
	self.__limitOfBoom = _num
end
function FriendRoomController:getLimitOfBoom()
	return self.__limitOfBoom or 0
end

function FriendRoomController:getRoomInfoStr( _curRound )
	local curRound   = _curRound or FriendRoomController:getInstance():getCurRound()
	local totalRound = FriendRoomController:getInstance():getTotalRound()
	local limitBoom  = FriendRoomController:getInstance():getLimitOfBoom()
	local double     = FriendRoomController:getInstance():getIsDouble()

	local str = self:formatRoomInfo( curRound , totalRound , limitBoom , double )
	return str
end

function FriendRoomController:formatRoomInfo( curRound , totalRound , limitBoom , double )
	local doubleStr  = "不加倍"
	local boomStr    = limitBoom.."炸"
	if limitBoom == 0 then
		boomStr = "不封顶"
	end
	if double == 1 then
		doubleStr = "加倍"
	end
	local str = "局数: "..curRound.."/"..totalRound.."     上限:"..boomStr .."     "..doubleStr
	return str
end

function FriendRoomController:formatRoomWeiXinStr( double , limitBoom , totalRound )
	local boomStr    = limitBoom.."炸封顶"
	if limitBoom == 0 then
		boomStr = "不封顶"
	end
	
	local doubleStr  = "不可加倍"
	if double == 1 then
		doubleStr = "可加倍"
	end
	local str = boomStr..","..doubleStr..","..totalRound.."局"
	return str
end

function FriendRoomController:weiXinInvite( roomNumber , double , limitBoom , totalRound )
	local str = self:formatRoomWeiXinStr( double , limitBoom , totalRound )
	LogINFO("分享到微信",roomNumber,str)
	XbShareUtil:wxInvite(27, roomNumber, str)
	ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomInvite_Req", {roomNumber} )
end

-- 错误提示总回调
function FriendRoomController:t_ackLandVipRoomError(__info)
	local tipTb = { 
		"0:正常  ",                              
		"1:开始游戏 人数不足",
		"2:游戏初始化错误 ",
		"3:未知错误 ",
		"4:重连-房间解散了(参数是房间id) ",
		"5:重连-游戏结束了(参数是房间id) ",
		"房卡不足,请先购买!",--"6:创建房间 房卡不足 参数为详细错误",
		"最多帮别人创建50个房间",--"7:创建房间 帮别人创建达到上限 ",
		"8:创建房间 创建中(扣费会有一个过程)",
		"9:创建房间 您没有登陆场景 ",
		"10:创建房间 您已经在房间 ",
		"%s房间不存在",--"11:加入房间 没有这个房间 ",
		"12:加入房间 被踢cd时间内，不能加入 ",
		"此房间人数已满,请换个房间吧!",--"13:加入房间 他人创建的房间已满 ",
		"此房间人数已满,请换个房间吧!",--"14:加入房间 已满未开局",
		"此房间人数已满,请换个房间吧!",--"15:加入房间 已满已开局",
		"16:加入房间 您已经在房间",
		"房间不存在 ",--"17:解散房间 没有这个房间",
		"18:解散房间 您不是房主 ",
		"房间已开局",--"19:解散房间 游戏中不能解散房间 ",
		"20:解散房间 别人创建的不能解散",
		"21:踢人 您不是房主",
		"22:踢人 游戏中不能踢人",
		"23:退出 游戏开始了不能退",
		"24:退出 房主不能退出",
		"25:测试 返回",
		"26:踢人 不能踢出自己",
		"房间有人啦!",--"27:解散 他人创建房间，有人不能解散",
		"房卡不足100张",-- 28:创建房间 他人创建房间，房卡不足
		"解散发起过于频繁，请稍后再试",-- 29:解散发起过于频繁，请稍后再试
	}

	local tips = tipTb[__info.m_error + 1] or "no tips"

	if __info.m_error == 9 then
		LogINFO( "创建房间 您已经在房间" )
		self:reqEnterVipScene()
	elseif __info.m_error == 10 then
		--LogINFO( "创建房间 您已经在房间" )
		self:reqEnterVipScene()
	elseif  __info.m_error == 11 then 
		local roomId = GET_LORD_HALL().dialogLayer.tempInPutVal
		EventManager:getInstance():raiseEvent("UILandJoin.clear")
		TOAST(string.format(tips,roomId))--__info.m_roomId))
	elseif  __info.m_error == 12 then 
		TOAST("您刚被请离房间，请1分钟后再试")
		EventManager:getInstance():raiseEvent("UILandJoin.clear")
	elseif  __info.m_error == 14 then 
		if GET_LORD_HALL() and GET_LORD_HALL().dialogLayer
		and GET_LORD_HALL().dialogLayer.tempInPutVal then
			local roomId = GET_LORD_HALL().dialogLayer.tempInPutVal
			TOAST(roomId .."房主正忙,请稍后再试!")
		else
			TOAST("房主正忙,请稍后再试!")
		end
		EventManager:getInstance():raiseEvent("UILandJoin.clear")
	elseif __info.m_error == 15 then
		if GET_LORD_HALL() and GET_LORD_HALL().dialogLayer
		and GET_LORD_HALL().dialogLayer.tempInPutVal then
			local roomId = GET_LORD_HALL().dialogLayer.tempInPutVal
			TOAST(roomId .."房间已开局")
		else
			TOAST("此房间已开局,请换个房间吧!")
		end
		EventManager:getInstance():raiseEvent("UILandJoin.clear")
	elseif __info.m_error == 6 then
		TOAST("房卡不足,请先购买!")
		DOHALL("onButtonCallback",7)
	elseif __info.m_error == 27 then
		TOAST("房间有人啦!")
		self:sendReqMyRoomList()
	else
		TOAST(tips .. __info.m_param)
	end
end

return FriendRoomController