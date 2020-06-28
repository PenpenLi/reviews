--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 游戏场景基类

local GameMusicUtil = require("app.hall.base.voice.MusicUtil")
local SceneBase = require("app.hall.base.ui.SceneBase")
local scheduler = require("framework.scheduler")

local CCGameSceneBase = class("CCGameSceneBase", function()
    return SceneBase.new()
end)

PLAYER_BEHAVIOR = 
{
	ENTER = 0, -- 玩家进入房间
	EXIT = 1, -- 玩家离开房间
	RECONNECTION = 2, -- 断线重连
	KICKED = 3, -- 玩家被踢出房间
}

CCGameSceneBase.gameServerPingCD = 30

function CCGameSceneBase:ctor()
    g_AudioPlayer:stopMusic() 
    if cc.UserDefault:getInstance():getIntegerForKey("sound") == 0 then
        g_AudioPlayer:stopAllSounds()
    end
	self:myInit()
end

----------------------------------------------------------------------外部接口--------------------------------------------------------------------------
--[[
加载网络协议文件
@param __filePath(string) 所在路径(以"/"结尾)
@return (bool) 加载成功与否
]]
function CCGameSceneBase:loadProtorolFile( __filePath )
	return Protocol.loadProtocolByFilePath( __filePath )	
end

--[[
发送协议
@param __cmdId(string) 协议ID字符串
@param __dataTable(table) 数据table
@return (bool) 加载成功与否
]]
function CCGameSceneBase:send2GameServer( __cmdId, __dataTable)
	ConnectManager:send2GameServer(self:getProtocolId(), __cmdId, __dataTable)
end
 
 function CCGameSceneBase:getProtocolId()
    return g_GameController.m_gameAtomTypeId
 end

function CCGameSceneBase:registerNetMsgCallbackByProtocolList( __protocolList, __msgHandler )
	g_GameController:setNetMsgCallbackByProtocolList(__protocolList, __msgHandler,true)
end

function CCGameSceneBase:setTipsFilePath( __filePath )
	
end

--[[
注册玩家状态处理回调
@param __handler(handler) 处理回调的函数, 包含两个参数: 玩家ID, 玩家行为 PLAYER_BEHAVIOR
@return (nil)
]]
function CCGameSceneBase:registPlayerBehaviorHandler( __handler )
	self.basePlayerBehaviorHandler = __handler
end

--[[
注册游戏析构函数
@param __handler(handler) 参数: nil
@return (nil)
]]
function CCGameSceneBase:registDistructorHandler( __handler )
	self.baseDistructorHandler = __handler
end

--[[
注册玩家信息变化回调
@param __handler(handler) 处理回调的函数, 包含两个参数: 玩家ID, 玩家行为 PLAYER_BEHAVIOR
@return (nil)
]]
function CCGameSceneBase:registPlayerInfoChanged( __handler )
	self.basePlayerInfoChangeHandler = __handler
end

--[[
获取音效管理实例
@param (nil)
@return GameMusicUtil (音效管理实例)
]]
function CCGameSceneBase:getMusicUtil()
	return self.baseGameMusicUtil
end

----------------------------------------------------------------------内部接口--------------------------------------------------------------------------

function CCGameSceneBase:myInit()

	self.basePlayerBehaviorHandler = nil -- 玩家状态处理回调

	self.basePlayerInfoChangeHandler = nil -- 玩家数据变化回调

	self.baseDistructorHandler = nil -- 析构回调

	self.super = self -- 游戏场景的基类

	self:setIsGameScene(true) -- 指定为游戏场景

	ToolKit:registDistructor(self, handler(self, self.onBaseDestory))

	self.baseGameMusicUtil = GameMusicUtil.new() -- 音效管理

	self:setSceneDirection(DIRECTION.HORIZONTAL) -- 游戏场景默认横屏
	self.roomData = nil              			--房间数据
	addMsgCallBack(self, MSG_PLAYER_UPDATE_SUCCESS, handler(self, self.onPlayerInfoChanged))
end

function CCGameSceneBase:onBaseDestory()  
	if self.baseDistructorHandler then
		self.baseDistructorHandler()
		self.baseDistructorHandler = nil
	end
	
	self.basePlayerBehaviorHandler = nil -- 玩家状态处理回调
	self.basePlayerInfoChangeHandler = nil -- 玩家数据变化回调

    g_AudioPlayer:stopMusic()  
    g_AudioPlayer:playMusic('hall/sound/audio-hall.mp3', true)

	removeMsgCallBack(self, MSG_PLAYER_UPDATE_SUCCESS)
end

-- 设置基础数据
function CCGameSceneBase:setBaseData( __data )
	self:setRoomData(__data.roomData)
end

-- 设置房间数据信息
function CCGameSceneBase:setRoomData( __roomData )
	self.roomData = __roomData
end

function CCGameSceneBase:onPlayerBehavior( __chairId, __behavior )
	if self.basePlayerBehaviorHandler then
		self.basePlayerBehaviorHandler(__chairId, __behavior)
	end
end

-- player date changed
function CCGameSceneBase:onPlayerInfoChanged()
	if self.basePlayerInfoChangeHandler then
		self.basePlayerInfoChangeHandler()
	end
end

--继续游戏，主动关闭当前游戏服网络连接，并注销协议
--[[
function CCGameSceneBase:onContinueGame()
	g_GameController:onContinueGame()
end
--]]

-- 断开和游戏服务的网络连接
function CCGameSceneBase:closeGameSvrConnect() 
	ConnectManager:closeGameConnect(g_GameController.m_gameAtomTypeId)
end

--[[
function CCGameSceneBase:onExitGame()
	-- if self.baseDistructorHandler then
	-- 	self.baseDistructorHandler()
	-- end
	-- self.basePlayerBehaviorHandler = nil -- 玩家状态处理回调
	-- self.basePlayerInfoChangeHandler = nil -- 玩家数据变化回调
	-- self.baseDistructorHandler = nil
	-- RoomTotalController:getInstance():atuoClearGameNetData()
	-- removeMsgCallBack(self, MSG_PLAYER_UPDATE_SUCCESS)
	-- self:onBaseDestory()

	if g_GameController then
	    g_GameController:atuoClearGameNetData()
        g_GameController:onDestory()
        g_GameController:releaseInstance() 
        g_GameController = nil 
    end
	UIAdapter:popScene()
end
--]]

-- 进入其他游戏(在游戏过程中切换游戏)
-- params __gameid(number)  游戏最小类型ID
--[[
function CCGameSceneBase:gotoOtherGame( __gameId )
    print("CCGameSceneBase:gotoOtherGame( __gameId )",__gameId)
	local data = RoomData:getRoomDataById(__gameId)
    if data then
        print("CCGameSceneBase:gotoOtherGame( __gameId )",self.roomData.gameKindType," | ",data.gameKindType," | ", self.roomData.gameAtomTypeId)
        if data.gameKindType == self.roomData.gameKindType then--进自己游戏
            if __gameId ~= self.roomData.gameAtomTypeId then
            	-- if self.baseDistructorHandler then
		           --  self.baseDistructorHandler()
	            -- end
	            -- self.basePlayerBehaviorHandler = nil -- 玩家状态处理回调
	            -- self.basePlayerInfoChangeHandler = nil -- 玩家数据变化回调
	            -- self.baseDistructorHandler = nil
	            -- RoomTotalController:getInstance():atuoClearGameNetData()
	            self:onBaseDestory()
	            -- removeMsgCallBack(self, MSG_PLAYER_UPDATE_SUCCESS)

                g_GameController:reqEnterScene( __gameId )
            end
        else
            self:onExitGame()
            g_GameController:reqEnterScene( __gameId )
        end
    end
end
--]]

return CCGameSceneBase