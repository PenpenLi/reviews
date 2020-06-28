--LandVoiceTalk
-- Author: 
-- Date: 2018-08-07 18:17:10
--跑得快语音表情面板
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local LandVoiceTalk = class("LandVoiceTalk",function()
	 return display.newLayer()
end)

function LandVoiceTalk:ctor( landMainScene )
	self:initUI()
end

function LandVoiceTalk:initUI()
	local path = "app.game.common.chat.ChatSystemLayer"
	package.loaded[ path ]  = nil
	local TalkVoiceLayer =  require( path )
    local params = 
    {
    	gameAtomTypeId = LandGlobalDefine.FRIEND_ROOM_GAME_ID,
    	serverReq = "CS_C2M_LVRClientChat_Req",
    	serverAck = "CS_M2C_LVRClientChat_Nty",
	}
    self.talkVoiceLayer = TalkVoiceLayer.new( params )
    self:addChild( self.talkVoiceLayer ) 
end

function LandVoiceTalk:updatePlayerIDS(  _userId , _pos , _pos2 , _isFlipX , _isFlipY )
	local params = 
	{
		userID        = _userId,       --玩家id
		messagepos    = _pos,          --播放快捷聊天位置/语音的位置
		expressionPos = _pos2,         -- 表情的位置
		isFlippedX    = _isFlipX ,     -- 播放快捷聊天背景/语音背景
		isFlippedY    = _isFlipY ,     -- 播放快捷聊天背景/语音背景
		gender        = 2              -- 性别：0.未知1.男 2.女.
	}
	self.talkVoiceLayer:setUserIDPos( params )
end

return LandVoiceTalk

