--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
require( "app.newHall.data.GameSwitchData")
local scheduler = require("framework.scheduler")
local DlgAlert = require("app.hall.base.ui.MessageBox")
BaseGameController = class("BaseGameController")
BaseGameController.gameServerPingCD          = 20  -- 发送心跳包的CD
BaseGameController.gameServerOfflineMaxCount = 3   -- 离线心跳包次数

--BaseGameController.instance = nil

-- 获取房间控制器实例
--function BaseGameController:getInstance()
--	if BaseGameController.instance == nil then
--		BaseGameController.instance = BaseGameController.new()
--	end
--    return BaseGameController.instance
--end

function BaseGameController:ctor()
	print("BaseGameController:ctor()")
	self:myInit() 
	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.netBaseMsgHandler))
     
	self.gameProtocolList = {}
	self.gameNetMsgHandler = nil
	self.enterGameAckHandler = nil
	
	-- 游戏通知
	addMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT, handler(self, self.onSocketEventMsgRecived))
    --addMsgCallBack(self, MSG_RECONNECT_LOBBY_SERVER, handler(self, self.onLobbyReconnect)) 
    --addMsgCallBack(self, MSG_KICK_NOTIVICE, handler(self, self.kickMsgCallback))  --顶号
	--addMsgCallBack(self, MSG_SHOW_ERROR_TIPS, handler(self,self.onReceiveErrorTips))  -- 错误飘字 
    addMsgCallBack(self, MSG_KICKPLAY_MAINTANENCE, handler(self, self.onKickNotice)) -- 维护
	addMsgCallBack(self, POPSCENE_ACK,handler(self,self.showEndGameTip))
end

function BaseGameController:onBaseDestory()
	print("BaseGameController:onBaseDestory")
	
	self:closeDisconnectDilog()

	if self.reconnectDlg then
		self.reconnectDlg:closeDialog()
        self.reconnectDlg = nil
    end
	
	if not tolua.isnull(self.m_DlgAlertDlg) then
		self.m_DlgAlertDlg:closeDialog()
		self.m_DlgAlertDlg = nil
    end
	
	self:loadingDialogEnd()
	self:reconnectGameServerEnd()
	self:endSendGameServerPing()
    
	removeMsgCallBack(self, POPSCENE_ACK)
	--removeMsgCallBack(self, MSG_KICK_NOTIVICE) 
    removeMsgCallBack(self, MSG_KICKPLAY_MAINTANENCE) 
    --removeMsgCallBack(self, MSG_GAME_SHOW_MESSAGE)
    --removeMsgCallBack(self, MSG_RECONNECT_LOBBY_SERVER)
    removeMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT)
	
	self:removeNetMsgCallback() 
    self.gameProtocolList = {}
    self.gameNetMsgHandler = nil
    self.enterGameAckHandler = nil
    self.userLeftGameAckHandler = nil
	
	--关闭网络
	self:clearGameNetData()
end

-- 初始化
function BaseGameController:myInit()
	print("BaseGameController:myInit")
	self.connectInfo = 
	{
		m_key = nil,				-- 密钥
       	m_domainName = nil,			-- GameServer域名
       	m_port = nil,				-- GameServer端口
       	m_serviceId = nil,			-- GameServer服务ID
       	m_gameProtocolId = nil
	}
	
    self.m_reconetGameServer          = false                  -- 是否正在连接游戏服
    self.gameScene = nil
	self.m_gameAtomTypeId = 0
	self.roomControllers = {} 
    self.gameServer_ping_schedule = nil
	self.gameServerOfflineCount = 0 -- 离线心跳包次数\
    self.reconetGameServerTimes = 0
	self.customPingCD = BaseGameController.gameServerPingCD -- 发送心跳包的CD
	self.customPingMaxCount = BaseGameController.gameServerOfflineMaxCount -- 离线心跳包次数
end

function BaseGameController:setNetMsgCallbackByProtocolList( __protocolList, __msgHandler)
	if not __protocolList or #__protocolList == 0 then
		print("[ERROR]: get nil when regist game protocol by list, the game protocol id is: ",self.gameProtocolId)
		return
	end
	self.gameProtocolList = {}
	self.gameProtocolList = __protocolList
    table.insert(self.gameProtocolList,"CS_G2C_PingAck")
    table.insert(self.gameProtocolList,"CS_G2C_EnterGame_Ack")
    --table.insert(self.gameProtocolList,"CS_G2C_UserLeft_Ack" ) 
    self.gameNetMsgHandler = __msgHandler 
end

function BaseGameController:reqEnterScene()
    return ConnectManager:send2SceneServer(self.m_gameAtomTypeId, "CS_C2M_Enter_Req", { self.m_gameAtomTypeId, "" } )
end

function BaseGameController:setGamePingTime( __cd, __maxOffLineCount )
	self.customPingCD = __cd 
	self.customPingMaxCount = __maxOffLineCount
end

-- 设置响应进入游戏服后的handler
function BaseGameController:setEnterGameAckHandler( __enterGameAckHandler )
     self.enterGameAckHandler = __enterGameAckHandler
end

-- 网络消息
function BaseGameController:netBaseMsgHandler( __idStr, __info ) 
    print("BaseGameController:netBaseMsgHandler ")
	if __idStr == "CS_H2C_HandleMsg_Ack" then
		for i = 1, #__info.m_message do 
			dump(__info) 
            if __info.m_message[i].id == "CS_M2C_Enter_Ack" then
				ToolKit:removeLoadingDialog()
                if __info.m_result == 0 then
                    --self.m_gameAtomTypeId = __info.m_gameAtomTypeId
                    if self.m_reconetGameServer then
                          self:loadingDialogEnd()
                          print("重连游戏服成功")
                          TOAST("重连游戏服成功!")
                          if not tolua.isnull( self.reconnectDlg )  then
                             self.reconnectDlg:closeDialog()
                             self.reconnectDlg = nil
                          end
                          self.m_reconetGameServer = false
                          self:reconnectGameServerEnd()
                    end
					
                    if __info.m_message[i].msgs.m_ret == 0 then 
                        self:ackEnterGame(__info.m_message[i].msgs)
                    else
                        if __info.m_message[i].msgs.m_ret == -705 then 
                            local params = { 
                                message = "金币不足！请充值" -- todo: 换行 
                            }
                            if self.m_DlgAlertDlg == nil then     
                                self.m_DlgAlertDlg = require("app.hall.base.ui.MessageBox").new()
                                local _leftCallback = function ()   
                                    if self.gameScene~=nil then
                                        UIAdapter:popScene()
                                    else
                                        sendMsg(MSG_OPENSHOP) 
                                     end   
                                    
                                    self.m_DlgAlertDlg = nil
                                end

                                local _rightcallback = function () 
                                    if self.gameScene~=nil then
                                        UIAdapter:popScene()
                                    end
                                    self.m_DlgAlertDlg = nil
                                end

                                self.m_DlgAlertDlg:TowSubmitAlert(params, _leftCallback, _rightcallback)
                                self.m_DlgAlertDlg:showDialog()
                            end
                            return
                        elseif __info.m_message[i].msgs.m_ret == -747 then 
                            local data = getErrorTipById( __info.m_message[i].msgs.m_ret)
                            local box_title = "提示"
                            local box_content = data.tip or ""
                            local cb1 = function()
								self.m_DlgAlertDlg = nil 
							end
                            local params = {
                                title = box_title,
                                message = box_content,
                                leftStr = btnText1,
                                rightStr = btnText2,
                                tip = box_content,
                            }
                            if self.m_DlgAlertDlg == nil then
                                self.m_DlgAlertDlg = require("app.hall.base.ui.MessageBox").new()
                                self.m_DlgAlertDlg.showRightAlert(params,cb1) 
                            end
                            return
                        elseif __info.m_message[i].msgs.m_ret == -752 then 
                            TOAST("游戏暂未开放")
                        end
                        self:handleError(__info)
                    end
                else
                    print("请求进入场景失败!")
		            print("[ERROR]: Enter scene error, the error code is: ", __info.m_ret)
		            if __info.m_ret == -747 then
			            return -- 系统维护, 避免重复提示, 这里直接返回
		            end
                    self:handleError(__info)
                end
            elseif __info.m_message[i].id == "CS_M2C_GameStart_Nty" then 
				self:notifyEnterGame(__info.m_message[i].msgs)
            else
                self:ackSceneMessage(__info.m_message[i])
			end
		end
	end
end

function BaseGameController:ackSceneMessage(info)
end

function BaseGameController:ackEnterGame(info)
end

function BaseGameController:ackEnterGame2(info)
end

function BaseGameController:handleError(info)
end

function BaseGameController:showConfirmTips(params)
    self:showErrorDialogBeginEnd()
    if not tolua.isnull( self.m_reconnectDlg   )  then
        self.m_reconnectDlg:closeDialog()
        self.m_reconnectDlg   = nil
    end

    if not tolua.isnull( self.m_DlgAlertDlg  ) then
       self.m_DlgAlertDlg:closeDialog()
       self.m_DlgAlertDlg = nil
    end
	
    self.m_DlgAlertDlg = DlgAlert.showTipsAlert({title=params.title,tip =params.msg , tip_size = params.size })
    self.m_DlgAlertDlg:setSingleBtn("确定",function()
        if params.surefunction then
			params.surefunction()
        end
		self.m_DlgAlertDlg:closeDialog()
        self.m_DlgAlertDlg = nil
        end)
    self.m_DlgAlertDlg:enableTouch(false)
    self.m_DlgAlertDlg:setBackBtnEnable(false)
end

-- 通知玩家进入游戏
function BaseGameController:notifyEnterGame( __info  )
	dump(__info, "BaseGameController:notifyEnterGame")
    --连接游戏服前确保关掉当前socekt 连接
    if self.connectInfo.m_gameProtocolId then -- todo
	   print(" self.connectInfo.m_gameProtocolId =", self.connectInfo.m_gameProtocolId)
	   ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
	  -- self:removeNetMsgCallback()
	end 
	self.connectInfo.m_key        = __info.m_key	            -- 密钥
	self.connectInfo.m_domainName = __info.m_domainName	        -- GameServer域名
	self.connectInfo.m_port       = __info.m_port	            -- GameServer端口
	--self.connectInfo.m_serviceId  = __info.m_serviceId	        -- GameServer服务ID
	--self.m_gameAtomTypeId         = __info.m_gameAtomTypeId     
    self:onConnectGameServer(__info)
	self:startGame() 
end

function BaseGameController:onConnectGameServer(__info)
end

-- 游戏开始
function BaseGameController:startGame()
	self.connectInfo.m_gameProtocolId = self.m_gameAtomTypeId   --  gameID => protocolid
	ConnectManager:connect2GameServer(self.connectInfo.m_gameProtocolId, self.connectInfo.m_domainName, self.connectInfo.m_port)
end

-- 开启提示框定时器
-- @params tips( string ) 提示内容
function BaseGameController:loadingDialogBegin( tips )
    if self.loadingDialogTimer then
       scheduler.unscheduleGlobal( self.loadingDialogTimer )
       self.loadingDialogTimer = nil
    end
	
    local function showTips()
        ToolKit:removeLoadingDialog()
        if tolua.isnull( self.m_reconnectDlg   ) then
           ToolKit:addLoadingDialog(10, tips)
        end
    end
    self.loadingDialogTimer = scheduler.performWithDelayGlobal(showTips, 0.05)
end

function BaseGameController:loadingDialogEnd()
    if self.loadingDialogTimer then
       scheduler.unscheduleGlobal( self.loadingDialogTimer )
       self.loadingDialogTimer = nil
    end
end

-- 获取游戏最小配置id
-- @return self.m_gameAtomTypeId( number ) 最小配置id
function BaseGameController:getGameAtomTypeId()
   return  self.m_gameAtomTypeId
end

function BaseGameController:bindGameTypeId( __gameId )
	if self.m_gameAtomTypeId == 0 and __gameId ~= 0 then
		self.m_gameAtomTypeId = __gameId
	end
end

function BaseGameController:reconnectGameServerBegin()
    print("BaseGameController:reconnectGameServerBegin")
    if self.reconnectGameServerTimer then
        scheduler.unscheduleGlobal( self.reconnectGameServerTimer )
        self.reconnectGameServerTimer = nil 
    end
	
    self.m_reconetGameServer= true
    self.m_reconetGameServerTimes = 0
    self.reconnectGameServerTimer = scheduler.scheduleGlobal(handler(self,self.reconnectGameServer), 10)
    self:reconnectGameServer()
end

function BaseGameController:reconnectGameServer()
    self.reconetGameServerTimes = self.reconetGameServerTimes + 1
    self:loadingDialogBegin( "正在尝试重连游戏服..." )
    if self.reconetGameServerTimes <= 3  then 
        self:reqEnterScene()
    else
        self:reconnectGameServerEnd()
        self:showGameServerConnectDialog()
    end
end

-- 停止连接游戏服定时器
function BaseGameController:reconnectGameServerEnd()
    if not self.reconnectGameServerTimer then
        return
    end
    self.m_reconetGameServer= false

    ToolKit:removeLoadingDialog()
    scheduler.unscheduleGlobal(self.reconnectGameServerTimer)
    self.reconnectGameServerTimer = nil
end

function BaseGameController:showGameServerConnectDialog() 
    if not tolua.isnull( self.m_reconnectDlg   )  then
       self.m_reconnectDlg:closeDialog()
       self.m_reconnectDlg = nil
    end
    if not tolua.isnull( self.m_DlgAlertDlg ) then
       self.m_DlgAlertDlg:closeDialog()
       self.m_DlgAlertDlg = nil
    end
    self.m_reconnectDlg = DlgAlert.new()
    self.m_reconnectDlg:TowSubmitAlert({title = "提示",message = "游戏服连接失败, 请退出重连!"})
    self.m_reconnectDlg:setSingleBtn("确定", function ()
		self.m_reconnectDlg:closeDialog()
		self.m_reconnectDlg = nil
        g_GameController:releaseInstance()
    end)
    self.m_reconnectDlg:showDialog()
    self.m_reconnectDlg:enableTouch(false)
    self.m_reconnectDlg:setBackBtnEnable(false)
end

-- 注册游戏消息回调
function BaseGameController:registerNetMsgCallback() 
    dump("BaseGameController:registerNetMsgCallback", self.gameProtocolList)
    if self.connectInfo.m_gameProtocolId then
    	if #self.gameProtocolList > 0 then       
		   for i = 1, #self.gameProtocolList do
			   TotalController:registerNetMsgCallback(self, self.connectInfo.m_gameProtocolId, self.gameProtocolList[i], handler(self, self.totalGameNetMsgHandler))
		   end
		else
            print("[ERROR]:没有设置游戏相关协议！")
		end
	end
end
 
function BaseGameController:removeNetMsgCallback()  
	print("BaseGameController:removeNetMsgCallback")
    if self.connectInfo.m_gameProtocolId then
	   for i = 1, #self.gameProtocolList do
		   TotalController:removeNetMsgCallback(self, self.connectInfo.m_gameProtocolId, self.gameProtocolList[i])
	   end
	end
     TotalController:removeNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
end

-- 游戏消息的回调函数
function  BaseGameController:totalGameNetMsgHandler( __idStr, __info )	
    if __idStr == "CS_G2C_PingAck" then
       self:onReceiveGameServerPing()
    elseif __idStr == "CS_G2C_EnterGame_Ack" then  --收到entergame_ack时如果是百家乐则发送请求房间列表 
        print ("CS_G2C_EnterGame_Ack  m_result "..__info.m_result)
        if __info.m_result == -735 then
            self:reqEnterScene()
            return
        end
		self:ackEnterGame2(__info)
		if self.enterGameAckHandler then 
			self.enterGameAckHandler( __info )
        end
    --elseif __idStr == "CS_G2C_UserLeft_Ack" then 
    --    if self.userLeftGameAckHandler then
    --       self.userLeftGameAckHandler( __info )
    --    end
    else
        if self.gameNetMsgHandler then
	        self.gameNetMsgHandler(__idStr, __info)
	    else
         	print("[ERROR]: Get msg handler error, the game protocol id is: ", self.connectInfo.m_gameProtocolId)
        end
    end
end

--[[
function BaseGameController:onLobbyReconnect( msgName, msgObj )
    if self.lobbyReconnectStatue == msgObj then
        return
    end

    local scene = display.getRunningScene()
    if tolua.isnull( scene ) then
       return
    end

    self.lobbyReconnectStatue = msgObj
    print("TotalScene:onLobbyReconnect111111111: ", msgObj)
    if msgObj == "start" then -- 开始重连
        local function de()
            ToolKit:removeLoadingDialog()
            ToolKit:addLoadingDialog(10, "正在连接服务器, 请稍后")
        end
      --  scene:performWithDelay(de, 0.1)
    elseif msgObj == "success" then --重连成功 
        --g_LoginController.isReconnect = false
        ToolKit:removeLoadingDialog()
        if self.reconnectDlg and self.reconnectDlg.closeDialog then
            self.reconnectDlg:closeDialog()
            self.reconnectDlg = nil
        end
        if self.gameScene  then
            if self.gameScene.m_BackGroudFlag== true then
                self.gameScene.m_BackGroudFlag = false
            end
        end
     --   self:reqEnterScene()
       -- self:reconnectGameServerBegin()
    elseif msgObj == "fail" then -- 重连失败 
        if self.connectInfo.m_gameProtocolId then
	       for i = 1, #self.gameProtocolList do
		       TotalController:removeNetMsgCallback(self, self.connectInfo.m_gameProtocolId, self.gameProtocolList[i])
	       end
	    end
        --g_LoginController.isReconnect = false 
		--ConnectManager:reconnect() 
		--ToolKit:addLoadingDialog(30, "正在连接服务器, 请稍后")
    end
end

--走重连流程
function BaseGameController:reconnect()
    if self.reconnectDlg then
        self.reconnectDlg:closeDialog()
        self.reconnectDlg = nil
    end
    ConnectManager:reconnect()
end
--]]

--走退出的流程
function BaseGameController:exit()
    TotalController:onExitApp()
end

-- socket连接状态改变
function BaseGameController:onSocketEventMsgRecived( __msgName, __protocol, __connectName ) 
	if self.connectInfo.m_gameProtocolId == __protocol then
		if __connectName == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
			print("连接游戏服失败")
			--self:endSendGameServerPing()
		elseif __connectName == cc.net.SocketTCP.EVENT_CLOSED then
			print("游戏服连接断开")
			self:endSendGameServerPing()
            if self.connectInfo.m_gameProtocolId then
	            for i = 1, #self.gameProtocolList do
		           TotalController:removeNetMsgCallback(self, self.connectInfo.m_gameProtocolId, self.gameProtocolList[i])
	           end
	        end
			
			--如果是从后台切回来
			if ConnectManager:isConnectSvr(Protocol.LobbyServer)  then
				if self.m_BackGroudFlag == true then
					self:showSocketDisConnetExitGameTip()
				else
					self:reqEnterScene()
				end
			end
		elseif __connectName == cc.net.SocketTCP.EVENT_CLOSE then
			print("游戏服连接断开")
			self:endSendGameServerPing()
            if self.connectInfo.m_gameProtocolId then
	            for i = 1, #self.gameProtocolList do
		           TotalController:removeNetMsgCallback(self, self.connectInfo.m_gameProtocolId, self.gameProtocolList[i])
	           end
	        end
		elseif __connectName == cc.net.SocketTCP.EVENT_CONNECTED then
			print("连接游戏服成功")  
	        self:registerNetMsgCallback()
	        self:beginSendGameServerPing()
	        self:reqEnterGameServer()
			self:closeDisconnectDilog()
            if self.m_BackGroudFlag == true then
               self.m_BackGroudFlag = false
            end
		end
		sendMsg( PublicGameMsg.MS_PUBLIC_GAME_SERVER_SOCKET_CONNECT, { protocol = self.connectInfo.m_gameProtocolId ,  connectName = __connectName, passiveness = ConnectManager:getGameClosePassiveness(self.connectInfo.m_gameProtocolId) } )
	elseif Protocol.LobbyServer == __protocol then
		if __connectName == cc.net.SocketTCP.EVENT_CLOSED or __connectName == cc.net.SocketTCP.EVENT_CLOSE then
			if self.connectInfo.m_gameProtocolId then
				ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
			end
			self:closeDisconnectDilog()
		end
	end 
end

--[[
function BaseGameController:kickMsgCallback(__msg, __info)      
    if __info.m_nReason == -320 then
        ConnectManager:reconnect()
    else  
        ToolKit:returnToLoginScene()
    end
end
--]]

function BaseGameController:send2GameServer( __cmdId, __dataTable)
	ConnectManager:send2GameServer(self.connectInfo.m_gameProtocolId, __cmdId, __dataTable)
end

-- 请求登录游戏服
function BaseGameController:reqEnterGameServer()
	self:send2GameServer( "CS_C2G_EnterGame_Req", {self.m_gameAtomTypeId,Player:getAccountID(),self.connectInfo.m_key })
end

-- 玩家退出游戏服
function BaseGameController:reqUserLeftGameServer()
	print("BaseGameController:reqUserLeftGameServer")
    self:send2GameServer( "CS_C2G_UserLeft_Req", { self.m_gameAtomTypeId })
end

 --游戏服心跳包
function BaseGameController:beginSendGameServerPing()
	--每过30秒发一次心跳包
        print("beginSendGameServerPing")
	if self.gameServer_ping_schedule then
        print("beginSendGameServerPing stop")
		scheduler.unscheduleGlobal(self.gameServer_ping_schedule)
		self.gameServer_ping_schedule = nil
	end
	self.gameServerOfflineCount = 0
	self.gameServer_ping_schedule = scheduler.scheduleGlobal(handler(self, self.sendGameServerPing), self.customPingCD)
end

function BaseGameController:sendGameServerPing()
    if self.gameServerOfflineCount > 0 then
       print("发送离线游戏服心跳包")
    end
    self.gameServerOfflineCount = self.gameServerOfflineCount + 1
    print("------ping 游戏服----------")
	self:send2GameServer("CS_C2G_PingReq",{})
	if self.gameServerOfflineCount > self.customPingMaxCount  then --离线心跳包次数
		print("超时关闭游戏服scoket连接: ", self.gameServerOfflineCount, self.customPingMaxCount)
		ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
		--self:endSendGameServerPing()
		--sendMsg(PublicGameMsg.MSG_PUBLIC_PING_TIME_OUT, self.connectInfo.m_gameProtocolId, self.gameServerOfflineCount)
	end
end

function BaseGameController:onReceiveGameServerPing()
	print("-----游戏服心跳包返回-----")
    self.gameServerOfflineCount = 0
end

function BaseGameController:endSendGameServerPing()
	if self.gameServer_ping_schedule then
		scheduler.unscheduleGlobal(self.gameServer_ping_schedule)
		self.gameServer_ping_schedule = nil
		self.gameServerOfflineCount = 0
	end
end

--[[
--继续游戏，主动关闭当前游戏服网络连接，并注销协议
function BaseGameController:onContinueGame()
	self:endSendGameServerPing()
	self:removeNetMsgCallback()
    ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
end

function BaseGameController:atuoClearGameNetData()
	self:endSendGameServerPing()
	ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
end
--]]

-- 被踢出房间
function BaseGameController:onKickNotice(msgName,__info )    
    if __info.m_type  == 1 then
        --全平台维护
        local dlg = DlgAlert.showTipsAlert({title = "维护通知", tip = "系统即将维护，请关闭游戏！", tip_size = 34})
        dlg:setSingleBtn(STR(37, 5), function ()
            TotalController:onExitApp()
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
		g_isAllowReconnect = false		--不允许重连
        --被顶号后关闭断线检测
        ConnectionUtil:setCallback(function ( network_state )
            end)
        TotalController:stopToSendHallPing()
    elseif __info.m_type == 2 then  -- 游戏维护
        if __info.m_gameId == self.m_gameAtomTypeId then -- 
            local runningScene = cc.Director:getInstance():getRunningScene()
            local name = runningScene:getSceneName()
          
            --全平台维护
            local dlg = DlgAlert.showTipsAlert({title = "维护通知", tip = "系统即将维护，请退出游戏！", tip_size = 34})
            dlg:setSingleBtn(STR(37, 5), function ()
                --runningScene:StrongbackGame()  -- 强退
				dlg:closeDialog()
				self:releaseInstance()
            end)
            dlg:setBackBtnEnable(false)
            dlg:enableTouch(false)
            --被顶号后关闭断线检测
            ConnectionUtil:setCallback(function ( network_state )
            end)
        end
    end
end

function BaseGameController:clearGameNetData()
    --self:endSendGameServerPing()
	if self.connectInfo.m_gameProtocolId then
		ConnectManager:closeGameConnect( self.connectInfo.m_gameProtocolId )
	end
end

function BaseGameController:showEndGameTip()
	print("----BaseGameController:showEndGameTip-----")
	if not self.gameScene then 
		return 
	end
	
	--如果已经弹出断开连接对话框, 将其关掉
	self:closeDisconnectDilog()
	
    local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "游戏已结束", tip_size = 34})
	dlg:setSingleBtn("确定", function ()
		dlg:closeDialog()
		g_GameController:releaseInstance()
    end)
    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false)
end

function BaseGameController:closeDisconnectDilog()
	if self.m_disconnectDlg then
		self.m_disconnectDlg:closeDialog()
		self.m_disconnectDlg = nil
	end
end

function BaseGameController:showSocketDisConnetExitGameTip()
	print("-------BaseGameController:showSocketDisConnetExitGameTip---------")
    self:closeDisconnectDilog()
	self.m_disconnectDlg = DlgAlert.showTipsAlert({title = "提示", tip = "与服务器断开,请重连", tip_size = 34})
	self.m_disconnectDlg:setSingleBtn("确定", function ()
		self:reqEnterScene()
		self.m_disconnectDlg:closeDialog()
		self.m_disconnectDlg = nil
    end)
    self.m_disconnectDlg:setBackBtnEnable(false)
    self.m_disconnectDlg:enableTouch(false)
end

return BaseGameController