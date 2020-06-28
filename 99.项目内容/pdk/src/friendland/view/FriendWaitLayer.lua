local scheduler = require("framework.scheduler")
local FriendRoomController  = require("src.app.game.pdk.src.classicland.contorller.FriendRoomController")
local StackLayer = require("app.hall.base.ui.StackLayer")
local FriendJieSanLayer = require("src.app.game.pdk.src.friendland.view.FriendJieSanLayer")
local EventManager = require("app.game.pdk.src.common.EventManager")
local LandAnimationManager = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource")
local FriendKickLayer = require("src.app.game.pdk.src.friendland.view.FriendKickLayer")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendWaitLayer = class("FriendWaitLayer", function()
	return StackLayer.new()
end)

function FriendWaitLayer:ctor( landMainScene , roomID )
	self.mLandMainScene = landMainScene
	self.roomID         = roomID
	self:myInit()
end

function FriendWaitLayer:myInit()
	self:initUI()
	self:initKickOutLayer()
	self:updateLayoutTip()
	ToolKit:registDistructor( self, handler(self, self.onDestory) )
end

function FriendWaitLayer:onDestory()
	LogINFO("牌友房等人界面被摧毁")
end

function FriendWaitLayer:initUI()
	self.m_pMainNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_main_wait.csb")
	self:addChild(self.m_pMainNode)
	UIAdapter:adapter(self.m_pMainNode, handler(self, self.onTouchCallback))
	self.layout_bg = self.m_pMainNode:getChildByName("layout_bg")
	self.layout_bg:setContentSize(display.width, display.height)
	self:initButton()
end

function FriendWaitLayer:initKickOutLayer()
	if self.m_landKickOutLayer then
		self:removeChild(self.m_landKickOutLayer, true)
		self.m_landKickOutLayer = nil
	end
	self.m_landKickOutLayer = FriendKickLayer.new(self)
	self:addChild(self.m_landKickOutLayer,6)
	self:setKickOutLayer( 3 )
end

function FriendWaitLayer:setKickOutLayer( tag , acc , player_name)
	if self.m_landKickOutLayer then
		self.m_landKickOutLayer:setVisible( true )
		if tag == 3 then
			self.m_landKickOutLayer:setVisible( false )
		elseif tag == 2 then
			self.m_landKickOutLayer:showKickOutDialog( acc ,player_name)
		elseif tag == 1 then
			self.m_landKickOutLayer:showKickOutInform()
		end
	end
end

function FriendWaitLayer:initButton()
	self.start_game_btn = self.layout_bg:getChildByName("btn_star_game")
	self.start_game_btn:addTouchEventListener(handler(self,self.OnClickStartGameBtn))

	self.invite_btn = self.layout_bg:getChildByName("btn_yaoqing")
	self.invite_btn:addTouchEventListener(handler(self,self.OnClickInviteBtn))

	self.layout_tip = self.layout_bg:getChildByName("layout_tip")
	LandAnimationManager:getInstance():PlayAnimation(LandArmatureResource.ANI_WAITTEXT, self.layout_tip)


	local isFangZhu = FriendRoomController:getInstance():checkMyselfIsFangzhu()
	local isCiFangZhu = FriendRoomController:getInstance():checkMyselfIsCiFangzhu()
	if isFangZhu or isCiFangZhu then -- 他就是房主
		--print("我是房主或者 次房主")
		self.invite_btn:setVisible(true)
		self.start_game_btn:setVisible(false)
	else
		--print("我不是房主")
		self.invite_btn:setVisible(true)
		self.start_game_btn:setVisible(false)
	end
	--self:checkIOS()
end

function FriendWaitLayer:updateLayoutTip()
	self.layout_tip:setVisible(false)
	--local myCreateRoomID , roomInfo = FriendRoomController:getInstance():getRoomInfo()
	local players = FriendRoomController:getInstance():getPlayers()
	local isFangZhu = FriendRoomController:getInstance():checkMyselfIsFangzhu()
	local isCiFangZhu = FriendRoomController:getInstance():checkMyselfIsCiFangzhu()
	if isFangZhu or isCiFangZhu then
		if table.nums(players) >= 3 then
			self.start_game_btn:setVisible(true)
		else
			self.invite_btn:setVisible(true)
			self.start_game_btn:setVisible(false)  
		end       
	else
		if table.nums(players) >= 3 then
			self.layout_tip:setVisible( true )
			self.start_game_btn:setVisible(false)
		end
	end
	--self:checkIOS()
end

--[[
function FriendWaitLayer:checkIOS()
	if GlobalConf.IS_IOS_TS == true then
		self.invite_btn:setVisible(false)
	end
end
--]]

function FriendWaitLayer:OnClickStartGameBtn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		print("点击开始游戏按钮")
		ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomStart_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID } )
	end
end


--点击了微信分享按钮
function FriendWaitLayer:OnClickInviteBtn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
		print("点击了微信按钮")
		
		if device.platform == "windows" then
			FriendRoomController:getInstance():sendAddRobot()
		end

		local double     = FriendRoomController:getInstance():getIsDouble()
		local limitBoom  = FriendRoomController:getInstance():getLimitOfBoom()
		local totalRound = FriendRoomController:getInstance():getTotalRound()
		FriendRoomController:getInstance():weiXinInvite( self.roomID , double , limitBoom , totalRound )
	end
end

-- 点击事件回调
function FriendWaitLayer:onTouchCallback( sender )
	local name = sender:getName()
	print("name: FriendWaitLayer", name)
end

function FriendWaitLayer:createFriendJieSanLayer(type)
	if self.mFriendJieSanLayer then
		self.mFriendJieSanLayer = nil
	end
	self.mFriendJieSanLayer = FriendJieSanLayer.new(type)
	self:addChild(self.mFriendJieSanLayer)
end

function FriendWaitLayer:removeFriendJieSanLayer()
	if self.mFriendJieSanLayer then
		self.mFriendJieSanLayer:removeFromParent()
		self.mFriendJieSanLayer = nil
	end
end

return FriendWaitLayer