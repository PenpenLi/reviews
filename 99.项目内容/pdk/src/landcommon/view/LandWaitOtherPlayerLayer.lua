-- LandWaitOtherPlayerLayer
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 等待其他玩家界面
local scheduler                = require("framework.scheduler")
local JumpLabel                = require("src.app.game.pdk.src.landcommon.view.JumpLabel")
local LandAnimationManager     = require("src.app.game.pdk.src.landcommon.animation.LandAnimationManager")
local LandArmatureResource     = require("src.app.game.pdk.src.landcommon.animation.LandArmatureResource") 

local LandWaitOtherPlayerLayer = class("LandWaitOtherPlayerLayer", function ()
	return display.newLayer()
end )

function LandWaitOtherPlayerLayer:ctor()
	self:addArmature()
	self.armature_tbl = {}
	self:addWaitingOtherPlayerLabel()
	self:addChuSaiTips()
end

function LandWaitOtherPlayerLayer:initBg(game_atom)
	local path = "src/app/game/pdk/res/csb/classic_land_cs/game_land_bg.csb"
	if IS_HAPPY_LAND(game_atom) then
		path = "src/app/game/pdk/res/csb/classic_land_cs/game_happyland_bg.csb"
	end
	local node = UIAdapter:createNode( path )
	self:addChild( node , -1 )
	UIAdapter:adapter( node )
	self.exitBtn = node:getChildByName("exit_btn")
	
	if IS_FREE_ROOM( game_atom ) then
		local function reqExit( sender , eventType )
			if eventType ~= ccui.TouchEventType.ended then return end
			g_GameController:reqSysExitGame()
		end
		if self.exitBtn then
			self.exitBtn:addTouchEventListener( reqExit )
		end
		
	end
end

function LandWaitOtherPlayerLayer:showQiaoLuoDaGu()
	self:hideEveryThing()
	self:playAnimation()
	self:showJumpLabel()
end

function LandWaitOtherPlayerLayer:startFreeRoomCountDown()
	local function f()
		if self and self.exitBtn then
			self.exitBtn:setVisible(true)
		end
	end
	scheduler.performWithDelayGlobal(f, 10)
end

function LandWaitOtherPlayerLayer:showBiSaiKaiShi()
	LogINFO("播放比赛开始四个字动画")
	self:hideEveryThing()
	local function onComplete()
		self:showChuSaiTips(1)
	end
	local animation = LandAnimationManager:getInstance():getAnimation(LandArmatureResource.ANI_MATCH, self, cc.p(display.cx, display.cy))
	animation:setMovementEventCallFunc(onComplete)
	animation:playAnimationByName("lord_match_ani_start")
end

----------功能设置面板----------
function LandWaitOtherPlayerLayer:addSystemSetLayer( atom )
	if not IS_FREE_ROOM( atom ) then return end
	if self.m_landSystemSet then return end
	self.m_landSystemSet = LandSystemSet.new( self , atom )
	self:addChild(self.m_landSystemSet,4)
	self.m_landSystemSet:setVisible(false)
end

function LandWaitOtherPlayerLayer:showSystemSetLayer()
	if self.m_landSystemSet then
		self.m_landSystemSet:setVisible(true)
	end
end

function LandWaitOtherPlayerLayer:addChuSaiTips()
	local path = "src.app.game.pdk.src.landcommon.view.match.LandMatchTipsNewLayer"
	self.tipsLayer = RequireEX( path ).new()
	self:addChild( self.tipsLayer )
	self.tipsLayer:setVisible(false)
end

function LandWaitOtherPlayerLayer:showChuSaiTips( stage )
	LogINFO("播放定点赛初赛复赛提示")
	self:hideEveryThing()
	self.tipsLayer:setVisible(true)
	self.tipsLayer:showDDSChuSaiTips( stage )
end

function LandWaitOtherPlayerLayer:showJueSaiTips()
	LogINFO("播放定点赛决赛提示")
	self:hideEveryThing()
	self.tipsLayer:setVisible(true)
	self.tipsLayer:showDDSJueSaiTips()
end

function LandWaitOtherPlayerLayer:addArmature()
	local winSize = cc.Director:getInstance():getWinSize()
	self.tbl = {
				{"ddz_dz_win", winSize.width/2,  winSize.height/2 + 40},
				 {"ddz_gu", winSize.width/2, winSize.height/2 - 200},
				 {"ddz_nm_win",winSize.width/2 + 220,  winSize.height/2 - 40},
				 {"ddz_nm_idle",winSize.width/2 - 220,  winSize.height/2 - 40}
				}

	self.armature_tbl = {}
	for k,v in ipairs( self.tbl ) do
		self.armature_tbl[k] = self:createArmature()
		self.armature_tbl[k]:setPosition(v[2] , v[3] )
		self.armature_tbl[k]:setVisible(true)
		self:addChild( self.armature_tbl[k])
		self.armature_tbl[k]:getAnimation():play(v[1], -1, 1)
	end
end

function LandWaitOtherPlayerLayer:hideArmature()
	for k,v in pairs( self.armature_tbl ) do
		v:setVisible(false)
	end
end

function LandWaitOtherPlayerLayer:playAnimation()
	for k,v in pairs( self.armature_tbl ) do
		v:setVisible(true)
		v:getAnimation():play(self.tbl[k][1],-1,1)
	end
end

function LandWaitOtherPlayerLayer:createArmature()
	local pathDir = "src/app/game/pdk/res/animation/ddz_gcdh/"
	local arm = ToolKit:createArmatureAnimation( pathDir, "ddz_gcdh")
	return arm
end

function LandWaitOtherPlayerLayer:addWaitingOtherPlayerLabel()
	self.jumpLabel = JumpLabel.new("正在匹配桌子,请稍候。。。", 40, cc.c3b(247, 238, 214))
	self.jumpLabel:setPositionWithMidAnchor( cc.p(display.cx, display.cy-300) )
	self:addChild( self.jumpLabel )
	self.jumpLabel:setVisible(false)
end

function LandWaitOtherPlayerLayer:showJumpLabel()
	self.jumpLabel:setVisible(true)
end

function LandWaitOtherPlayerLayer:hideEveryThing()
	self:hideArmature()
	self.tipsLayer:setVisible(false)
	self.jumpLabel:setVisible(false)
	if self.exitBtn then
		self.exitBtn:setVisible(false)
	end
end

return LandWaitOtherPlayerLayer