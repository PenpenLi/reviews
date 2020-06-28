-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快网络断线弹窗
local LandNetWorkLayer = class("LandNetWorkLayer", function ()
	return display.newLayer()
end )

function LandNetWorkLayer:ctor()
	self.reconnectGameServer_count = 0
	--addMsgCallBack(self, MSG_RECONNECT_LOBBY_SERVER, handler(self, self.onLobbyReconnect))
	--addMsgCallBack(self, PublicGameMsg.MSG_PUBLIC_PING_TIME_OUT, handler(self, self.onPingGameServerTimeOut))
	--addMsgCallBack(self, MSG_GAME_SHUT_DOWN, handler(self, self.onGameShutDown))
	--addMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT, handler(self, self.onGameServerSocketEvent))

	ToolKit:registDistructor( self, handler(self, self.onDestory) )
end

function LandNetWorkLayer:onDestory()
	LogINFO("跑得快网络监控界面被摧毁")
	--removeMsgCallBack(self, MSG_RECONNECT_LOBBY_SERVER)
	--removeMsgCallBack(self, PublicGameMsg.MSG_PUBLIC_PING_TIME_OUT)
	--removeMsgCallBack(self, MSG_GAME_SHUT_DOWN)
	--removeMsgCallBack(self, PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT)
end

--[[
function LandNetWorkLayer:onGameServerSocketEvent( msgName,msgObj )
	local atom  = msgObj.protocol
	local event = msgObj.connectName
	LogINFO("跑得快接收到游戏服网络变化通知",atom,event)
	if not IS_LAND_LORD( atom ) then return end
	if event == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
		self:onGameServerConnectFail( atom )
	elseif event == cc.net.SocketTCP.EVENT_CONNECTED then
		ToolKit:removeLoadingDialog()
	elseif event == cc.net.SocketTCP.EVENT_CLOSED then
		LogINFO("服务器主动断开游戏服链接")
		--self:onGameServerOffLine()
	end
end
--]]

--[[
function LandNetWorkLayer:onGameServerConnectFail( atom )
	ToolKit:removeLoadingDialog()
	if self.reconnectGameServer_count >= 3 then
		self:onLobbyServerOffLine()
		self.reconnectGameServer_count = 0
		return
	end
	ToolKit:addLoadingDialog(20, "进入房间失败,正在自动尝试重连")
	g_GameController:reconnectGameServer( atom )
	self.reconnectGameServer_count = self.reconnectGameServer_count + 1
end


function LandNetWorkLayer:onLobbyReconnect( msgName, msgObj )
	LogINFO("跑得快接收到大厅网络变化通知",msgName,msgObj,TotalController.hallOfflineCount)
	if msgObj == "start" then
		if TotalController.hallOfflineCount < 3 then
			ToolKit:removeLoadingDialog()
			ToolKit:addLoadingDialog(20, "正在尝试重连......")
		end
	end

	if msgObj == "fail" and TotalController.hallOfflineCount >= 3 then
		self:onLobbyServerOffLine()
	end

	if msgObj == "success" then
		self:onSuccess()
	end
end

function LandNetWorkLayer:onGameShutDown( _id , __msgs )
	if not IS_LAND_LORD( __msgs.m_gameId ) or IN_LORD_SCENE() then return end
	ToolKit:removeLoadingDialog()
	if self.dialog then return end
	local str = "此房间正在维护中,请稍后再试"
	self.dialog = RequireEX("app.game.pdk.src.landcommon.view.LandDiaLog").new()
	self.dialog:setContent( str , 26 )
	self.dialog:hideCloseBtn()
	local function f()
		self:clearDialog()
		GAME_SCENE_DO("exit")
	end
	self.dialog:showSingleBtn("确定",f)
end

function LandNetWorkLayer:onPingGameServerTimeOut( msgName , atom , failCount )
	LogINFO("跑得快接收到游戏服超时异常通知",atom,failCount)
	if not IS_LAND_LORD( atom ) or IN_LORD_SCENE() then return end
	self:onGameServerOffLine()
end

function LandNetWorkLayer:onGameServerOffLine()
	self:onLobbyServerOffLine()
end

function LandNetWorkLayer:onLobbyServerOffLine( _str , _btnStr )
	LogINFO("心跳包失败3次判定大厅服已经断开,弹窗提示",self.dialog)
	ToolKit:removeLoadingDialog()
	if self.dialog then return end
	local str = _str or "与服务器断开，请检查网络后进行重连"
	self.dialog = RequireEX("app.game.pdk.src.landcommon.view.LandDiaLog").new()
	self.dialog:setContent( str , 26 )
	
    local function onClose()
    	local scene = GET_GAME_SCENE()
    	if scene then
    		LogINFO("点击关闭按钮的时候在游戏界面中")
    		self:clearDialog()
    		GAME_SCENE_DO("exit")
    	elseif IN_LORD_SCENE() then
    		LogINFO("点击关闭按钮的时候在跑得快大厅中")
    		self:exitApp()
    	end
    end
    self.dialog:setCloseBtnFun( onClose )
    self.dialog:forbidClickBG()

    local function onYes()
    	self:clearDialog()
    	self:tryConnectToLobby()
    end
    local btnStr = _btnStr or "重连"
    self.dialog:showSingleBtn(btnStr,onYes)
end

function LandNetWorkLayer:onSuccess()
	LogINFO("链接到大厅服成功")
	self:clearDialog()
	ToolKit:removeLoadingDialog()
end

function LandNetWorkLayer:tryConnectToLobby()
	ToolKit:addLoadingDialog(20, "正在尝试重连......")
    ConnectManager:reconnect()
end

function LandNetWorkLayer:exitApp()
    TotalController:onExitApp()
end

function LandNetWorkLayer:clearDialog()
	if self.dialog and self.dialog.closeDialog then
		self.dialog:closeDialog()
		self.dialog = nil
	end
end

--]]

return LandNetWorkLayer