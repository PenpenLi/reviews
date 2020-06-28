-- FriendReplayController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 牌友房回放管理器
local LandGlobalDefine      = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendReplayController = class("FriendReplayController")
FriendReplayController.instance = FriendReplayController.instance or nil

function FriendReplayController:getInstance()
	if FriendReplayController.instance == nil then
		FriendReplayController.instance = FriendReplayController.new()
	end
    return FriendReplayController.instance
end

function FriendReplayController:ctor()
	self.paiju_tbl = {}             -- 牌局列表
	addMsgCallBack(self, MSG_SOCKET_CONNECTION_EVENT, handler(self, self.onSocketEventMsgRecived))
    --注册牌局列表消息
    Protocol.GameHistory = "GAME_HISTORY"
    TotalController:registerNetMsgCallback(self, Protocol.GameHistory, "CS_R2C_RoundListAck", handler(self, self.onRoundListAck))
end

function FriendReplayController:onSocketEventMsgRecived( __msgName, __protocol, __connectName )
    if __protocol == Protocol.GameHistory then
        if __connectName == cc.net.SocketTCP.EVENT_CONNECTED then
            LogINFO("牌局列表 服务器 链接 成功")
            self:reqGameList()
        end
    end
end

function FriendReplayController:getDataFromRoundServer()

    print("Protocol.GameHistory:::::::", Protocol.GameHistory)

    if ConnectManager:isConnectGameSvr( Protocol.GameHistory ) then 
        self:reqGameList()
    else 
        ConnectManager:send2SceneServer(LandGlobalDefine.FRIEND_ROOM_GAME_ID, "CS_C2M_LandVipRoomInfo_Req", { LandGlobalDefine.FRIEND_ROOM_GAME_ID } )
    end
end

function FriendReplayController:reqGameList()
    local acc = Player:getAccountID()
    LogINFO("FriendReplayController reqGameList acc,",acc)
    ConnectManager:send2GameServer(Protocol.GameHistory, "CS_C2R_Enter_Req", {acc,LandGlobalDefine.FRIEND_ROOM_GAME_ID})
    ConnectManager:send2GameServer(Protocol.GameHistory, "CS_C2R_RoundListReq", {acc})
end


function FriendReplayController:reciveVipRoomIpPort( __info )
    LogINFO("牌友房 牌局列表 IP 端口 消息")
    dump(__info, "__info:", 10)
    self:setGameListIpPort( __info.m_roundSvrIP , __info.m_roundSvrPort )
    self:connectToRoundServer()
end

function FriendReplayController:setGameListIpPort( _ip , _port )
    self.__gameListIP = _ip
    self.__gameListPort = _port
end
function FriendReplayController:getGameListIpPort()
    return self.__gameListIP,self.__gameListPort
end
function FriendReplayController:connectToRoundServer()
    local tcpID = Protocol.GameHistory
    if ConnectManager:isConnectGameSvr( tcpID ) then return end
    local ip,port  = FriendReplayController:getInstance():getGameListIpPort()
    if ip and port then
        ConnectManager:connect2GameServer(tcpID, ip, port)
    end
end

function FriendReplayController:decodeJson( jsonSTR )
    local tbl = require("cjson").decode( jsonSTR )
    return tbl
end

function FriendReplayController:insertPaiJu( gameID , json )
    local tbl = self:decodeJson( json )
    if type(tbl) ~= "table" then return end
    self.paiju_tbl[gameID] = tbl
    return true
end

function FriendReplayController:getPaiJuByGameID( gameID )
    if self.paiju_tbl[gameID] then
        return self.paiju_tbl[gameID]
    end
end

function FriendReplayController:getRoundListData()
    return self.round_list_data
end

function FriendReplayController:onRoundListAck( __idStr, data )
    LogINFO("FriendReplayController:onRoundListAck 接受到牌局列表消息",__idStr)
    self.round_list_data = data
    DOHALL("updateGameListLayer")
end

function FriendReplayController:showReplayScene( gameID )
	local scene = self:pushGameScene()
	scene:addReplayBtnLayer( gameID )
end


function FriendReplayController:pushGameScene()
	POP_GAME_SCENE()
	local path = "src.app.game.pdk.src.classicland.scene.LandGameMainScene"
	RequireEX( path )
	local scene = UIAdapter:pushScene( path , DIRECTION.HORIZONTAL )
	return scene
end

return FriendReplayController