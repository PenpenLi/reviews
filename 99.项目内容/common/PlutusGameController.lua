local DlgAlert                     = require("app.hall.base.ui.MessageBox")

local BaseGameController = import(".BaseGameController")

local PlutusGameController = class("PlutusGameController",function()
    return BaseGameController.new()
end)

function PlutusGameController:ctor()
    self._score = 0
    self._freeTimes = 0
    self._m_betScore = 0
	ToolKit:addSearchPath("src/app/game/plutus") 
    ToolKit:addSearchPath("src/app/game/plutus/res")
    -- 加载财神到协议
  	Protocol.loadProtocolTemp("app.game.plutus.protoReg")
	-- 初始化财神到数据
	self:initPlutusData()
	-- 注册协议
	self:initCallBackFuncList()
    self:registNetMassege()
end

--  初始化推饼数据
function PlutusGameController:initPlutusData()
    self.m_gameAtomTypeId = 181001
end 

PlutusGameController.instance = nil

-- 获取推饼游戏控制器实例
function PlutusGameController:getInstance()
	if PlutusGameController.instance == nil then
		PlutusGameController.instance = PlutusGameController.new()
	end
    return PlutusGameController.instance
end

-- 注册网络消息
function PlutusGameController:registNetMassege()
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 生成消息和对应处理函数的映射关系
function PlutusGameController:initCallBackFuncList()
	self.m_callBackFuncList = {}
    self.m_callBackFuncList["CS_M2C_Plutus_Start_Nty"]          = handler(self, self.gameStartNty )
    self.m_callBackFuncList["CS_M2C_Plutus_ScrollResult_Ack"]   = handler(self, self.gameScrollResultAck)
    self.m_callBackFuncList["CS_M2C_Plutus_SmallGameOp_Ack"]    = handler(self, self.gameSmallGameOpAck)
    self.m_callBackFuncList["CS_M2C_Plutus_Pond_Nty"]           = handler(self, self.gamePondNty)
    self.m_callBackFuncList["CS_M2C_Plutus_Exit_Ack"]           = handler(self, self.gameExitAck)
    self.m_callBackFuncList["CS_M2C_Plutus_Kick_Nty"]           = handler(self, self.gameKickNty)
    self.m_protocolList = {}
    for k,v in pairs(self.m_callBackFuncList) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
end

-- 销毁财神到游戏管理器
function PlutusGameController:onDestory()
	print("----------PlutusGameController:onDestory begin--------------")

	self.m_callBackFuncList = {}
	
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
   TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
   
   self:onBaseDestory()
   
   print("----------PlutusGameController:onDestory end--------------")
end

function PlutusGameController:releaseInstance()
    if PlutusGameController.instance then
		PlutusGameController.instance:onDestory()
        PlutusGameController.instance = nil
		g_GameController = nil
    end
end

function PlutusGameController:gameStartNty(__info)
    dump(__info, "gameStartNty")
    self._score = __info.m_score
    self._freeTimes = __info.m_freeTimes
    self._m_betScore = __info.m_betScore
    self.m_sRecordId = __info.m_recordId or ""
    self.gameScene:getMainLayer():setRecordId(self.m_sRecordId)
    self.gameScene:getMainLayer():setGoldCoin(self._score)
    self.gameScene:getMainLayer():setFreeTimes(self._freeTimes)
    self.gameScene:getMainLayer():setBetScore(self._m_betScore)
    self.gameScene:getMainLayer():updateGameMessage(true)
    --self.gameScene:getMainLayer():gameReset(0.0)
end

function PlutusGameController:gameScrollResultAck(__info)
    dump(__info, "gameScrollResultAck")
    self._freeTimes = __info.m_freeTimes
    self._startSmallGame = __info.m_startSmallGame
    self._calcFreeWinCoin = __info.m_calcFreeWinCoin
    self._curCoin = __info.m_curCoin
    self._winCoin = __info.m_winCoin
    self._score = self._score + self._winCoin
    self._icons = __info.m_icons
    self.m_sRecordId = __info.m_recordId or ""
    self.gameScene:getMainLayer():setRecordId(self.m_sRecordId)
    if __info.m_ret==-700001 then
        TOAST("非下注状态不能下注")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700002 then
        TOAST("不是有效下注区域")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700003 then
        TOAST("游戏最低金币限制找不到")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700004 then
        TOAST("玩家金币小于最低游戏金币限制")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700005 then
        TOAST("玩家金币不足")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700006 then
        TOAST("最大下注限制配置找不到")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700007 then
        TOAST("最大下注限制")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700008 then
        TOAST("操作过于频繁")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700009 then
        TOAST("下注筹码大于0")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif __info.m_ret==-700010 then
        TOAST("下注失败, 携带金币低于30金币")
        self.gameScene:getMainLayer():resetStartMenuStatu(false,true)
    elseif self._freeTimes > 0 then
        self.gameScene:getMainLayer():updateGameMessage(true)
        self.gameScene:getMainLayer():upDataMenuEnabled(true)
        self.gameScene:getMainLayer():setWinGoldCoin(self._calcFreeWinCoin)
        self.gameScene:getMainLayer():setGoldCoin(self._curCoin)
        self.gameScene:getMainLayer():setRollImage(self._icons,self._freeTimes)
    else
        self.gameScene:getMainLayer():updateGameMessage(true)
        self.gameScene:getMainLayer():upDataMenuEnabled(true)
        self.gameScene:getMainLayer():setWinGoldCoin(self._winCoin)
        self.gameScene:getMainLayer():setGoldCoin(self._curCoin)
        self.gameScene:getMainLayer():setRollImage(self._icons,self._freeTimes)
    end
end

function PlutusGameController:gameSmallGameOpAck(__info)
end

function PlutusGameController:gamePondNty(__info)
end

-- 向游戏服发消息
-- @params      __cmdId( number )    消息命令
-- @params     __dataTable( table )  消息结构体 
function  PlutusGameController:send2GameServer4Plutus( __cmdId, __dataTable)
     ConnectManager:send2SceneServer( self.m_gameAtomTypeId , __cmdId , __dataTable )
end

function PlutusGameController:handleError(  __info )
  print("PlutusGameController:onEnterScene1111111111111111111")
	if self:isPlutusGameModule( __info.m_gameAtomTypeId ) then   
        --ToolKit:removeLoadingDialog()
		print("请求进入场景失败!",__info.m_result)
        if __info.m_result > DragonVsTigerGlobal.DragonVsTigerErroCodeBegin then
            if __info.m_result == -722 then   --未找到该游戏对应服务
                local scene = display.getRunningScene()
                if scene and (scene.__cname == "PlutusScene" or scene.__cname == "DragonVsTigerEntranceScene" )then
                    local __params = { title = "提示" , msg = "游戏服正在维护中,请稍后重试!" ,surefunction = function ()
                        self:releaseInstance()
                    end}
                    self:showConfirmTips( __params )
                    --self:reconnectGameServerEnd()
                    --self:loadingDialogEnd()
                    --ToolKit:removeLoadingDialog()
                end
            elseif __info.m_result == -750 then  -- 进入中，请稍后
                local scene = display.getRunningScene()
                if scene and scene.__cname == "DragonVsTigerScene"  then
                         
                else
                    ToolKit:showErrorTip( __info.m_result )
                end
            else
            local data = getErrorTipById( __info.m_result )
            local __params = { title = "提示" , msg = data.tip  ,surefunction = function () 
				self:releaseInstance() 
			end }
            self:showConfirmTips( __params )
            end
        else   
            DragonVsTigerUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
        end
	end 
end
 --处理成功登录游戏服
-- @params __info( table ) 登录游戏服成功消息数据
function PlutusGameController:ackEnterGame( __info )
	print("PlutusGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
    else
--        self.gameScene:clearView() 
--        self:notifyViewDataAlready()
    end 
end
 

-- 消息总入口函数
-- @params __idStr( string )   消息命令
-- @params __info( table )     消息内容
function PlutusGameController:netMsgHandler(__idStr, __info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(__info)
  else
      print("没有处理消息",__idStr)
  end
end

-- 是否是财神到模块消息
function PlutusGameController:isPlutusGameModule( gameAtomTypeId )
  local data = RoomData:getPortalDataByAtomId( gameAtomTypeId )
  local isPlutusModule = false
  if data then
    if data.id == RoomData.PLUTUS then
      isPlutusModule = true
    end
  end
  return isPlutusModule
end


function PlutusGameController:sceneNetMsgHandler( __idStr, __info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if __info.m_result == 0 then
            local gameAtomTypeId = __info.m_gameAtomTypeId
            if gameAtomTypeId == 181001 then
                if type( __info.m_message ) == "table" then
                   if next( __info.m_message )  then
                      local cmdId = __info.m_message[1].id
                      local info = __info.m_message[1].msgs
                        self:netMsgHandler(cmdId, info)
                   end
                end
            end
      else
          print("__info.m_result", __info.m_result )
      end
    end
end

-- 通知服务器初始化视图资源成功
function PlutusGameController:notifyViewDataAlready()
   print("通知服务器初始化视图资源成功")

end

--玩家下注
function PlutusGameController:gameBet(deposit, lines)
    self._lines = lines
    self._deposit = deposit
    self._score = self._score - deposit * lines
    if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_Plutus_StartRoll_Req", { deposit,lines })
    end
end

function PlutusGameController:forceExit()
    if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_Plutus_Exit_Req", {})
    end
end

function PlutusGameController:gameExitAck(__info)
    self:releaseInstance()
end

function PlutusGameController:gameKickNty(__info)
    if self.gameScene then
        --self.gameScene:addDialog(__info.m_type)
        TOAST("您已被踢出房间!")
    else
        self:releaseInstance()
    end
end
	--玩家小游戏选择结果
function PlutusGameController:smallgameResult(result)

end

	--/*-----------------------------------------------------------------------------------------------*/
	--查询排列规则是否显示中奖线条
function PlutusGameController:ChecKLine(imageValue, lines, deposit)
	self._lines = lines
	self._deposit = deposit
    self._checkline = {}
    self._checkWin = {}
    local index = 1
	
	local win = false

	for k = 1,3 do
		for l = 1,3 do
			for m = 1,3 do
				for n = 1,3 do
					for j = 1,3 do
                        local num1 = (k-1)*5+1
                        local num2 = (l-1)*5+2
                        local num3 = (m-1)*5+3
                        local num4 = (n-1)*5+4
                        local num5 = (j-1)*5+5
						win = self:isWin(imageValue[num1], imageValue[num2], imageValue[num3], imageValue[num4], imageValue[num5])
						if (win > 0) then
							if (self._img_count == 5) then
                                local temp1 = 1
                                for i=1,index-1 do
                                    if self:isTableSame1(self._checkline[i], {k,l,m,n,j}) == 0 then
                                        self._checkline[i] = {k,l,m,n,j}
                                        self._checkWin[i] = win
                                        temp1 = 0 
                                    end
                                end
                                if temp1==1 then
                                    self._checkline[index] = {k,l,m,n,j}
                                    self._checkWin[index] = win
                                    index = index + 1
                                end
							elseif (self._img_count == 4) then
                                local temp1 = 1
                                local temp2 = 1
                                for i=1,index-1 do
                                    if #self._checkline[i]<=4 then
                                        if self:isTableSame1(self._checkline[i], {k,l,m,n}) == 0 then
                                            self._checkline[i] = {k,l,m,n}
                                            self._checkWin[i] = win
                                            temp1 = 0
                                        end
                                    else
                                        if self:isTableSame2(self._checkline[i], {k,l,m,n}) == 2 then
                                            temp2 = 0
                                        end
                                    end
                                end
                                if temp1==1 and temp2==1 then
                                    self._checkline[index] = {k,l,m,n}
                                    self._checkWin[index] = win
                                    index = index + 1
                                end
							elseif (self._img_count == 3) then
                                local temp2 = 1
                                for i=1,index-1 do
                                    if self:isTableSame2(self._checkline[i], {k,l,m}) == 2 then
                                        temp2 = 0
                                    end
                                end
                                if temp2==1 then
                                    self._checkline[index] = {k,l,m}
                                    self._checkWin[index] = win
                                    index = index + 1
                                end
							end
						end
					end
				end
			end
		end
	end
    if #self._checkline > 0 then
        self.gameScene:getMainLayer():setShowResult(self._checkline, self._checkWin)
    end
end

function PlutusGameController:isWin(a, b, c, d, e)
	local reward = 0
	local smallGames = false
	local freeGames = false
	reward = self:getLineWin(a, b, c, d, e)
	smallGames = self:getBonusValue(a, b, c, d, e)
	freeGames = self:getScatterValue(a, b, c, d, e)
	return reward
end

	--获取草人个数
function PlutusGameController:getBonusValue(a, b, c, d, e)
	local num = 0
	if (a == 10) then
        num = num + 1
    end
	if (b == 10) then
        num = num + 1
    end
	if (c == 10) then
        num = num + 1
    end
	if (d == 10) then
        num = num + 1
    end
	if (e == 10) then
        num = num + 1
    end

	if (num >= 3) then
        return true
    else
		return false
    end
end

	--获取播种机个数
function PlutusGameController:getScatterValue(a, b, c, d, e)
	local num = 0
	if (a == 11) and (b == 11) and (c == 11) and (d == 11) and (e == 11) then 
		num = 10
	elseif (a == 11) and (b == 11) and (c == 11) and (d == 11) then
		num =  5
	elseif (a == 11) and (b == 11) and (c == 11) then
		num = 3
	end

	if (num >= 3) then
		return true
	else
		return false
	end
end

--获取单线奖励
function PlutusGameController:getLineWin(a, b, c, d, e)
	local win = 12
	local k = {a,b,c,d,e}

	if (k[1]<10) and (k[1]==k[2]) and (k[3]==12) then
		win = k[1]
	elseif (k[1] < 10) and (k[1] == k[2]) and (k[2] == k[3]) and (k[4] == 12) then
		win = k[1]
	elseif (k[1] < 10) and (k[1] == k[2]) and (k[2] == k[3]) and (k[3] == k[4]) and (k[5] == 12) then
		win = k[1]
	elseif (k[1] < 10) and (k[2] == 12) and (k[1] == k[3]) then
		win = k[1]
	elseif (k[1] < 10) and (k[2] == 12) and (k[3] == 12) then
		win = k[1]
	elseif (k[1] == 12) then
		if (k[2] < 10) and (k[3] == 12) then
			win = k[2]
		elseif (k[2] == 12) and (k[3] < 10) then
			win = k[3]
		elseif (k[2] == 12) and (k[3] == 12) and (k[4] < 10) then
			win = k[4]
		elseif (k[2] == 12) and (k[3] == 12) and (k[4] == 12) and (k[5] < 10) then
			win = k[5]
		elseif (k[2] < 10) and (k[2] == k[3]) then
			win = k[2]
		end
    elseif (k[1] < 10 ) and (k[1] == k[2]) and (k[1] == k[3]) then
        win = k[1]
    end
    for i = 1,5 do
		if (k[i] == 12) then
			k[i] = win
		end
	end
	return self:calLineWin(k)
end
	--获取单线奖励
function PlutusGameController:calLineWin(k)
	local win1 = {12, 10, 10, 8, 4, 4, 4, 3, 3, 0, 0, 20 }--连5
	local win2 = {6, 4, 4, 2, 1.2, 1.2, 0.8, 0.6, 0.6, 0, 0, 10 }--连4
	local win3 = {1, 0.6, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 0, 0, 2 }--连3
		--INT win4[13] = {0, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 10}

	if (k[1] == k[2]) and (k[2] == k[3]) and (k[3] == k[4]) and (k[4] == k[5]) then
		self._img_count = 5
		return self._deposit * win1[k[1]]
	elseif (k[1] == k[2]) and (k[2] == k[3]) and (k[3] == k[4]) then
		self._img_count = 4
		return self._deposit * win2[k[1]]
	elseif (k[1] == k[2]) and (k[2] == k[3]) then
		self._img_count = 3
		return self._deposit * win3[k[1]]
	else 
        return 0
    end
end

--判断结果队列中是否有已存在的结果
--0:替换 1:加在后面 2:不处理
function PlutusGameController:isTableSame1(t1,t2)
    local temp = 0
    if #t2 >= #t1 then
        for i,child1 in pairs(t1) do
            if child1==t2[i] then
                
            else
                temp = 1
                return temp
            end
        end
        return temp
    end
end

function PlutusGameController:isTableSame2(t1,t2)
    local temp = 0
    if #t2 <= #t1 then
        temp = 2
        for i,child1 in pairs(t2) do
            if child1==t1[i] then
                
            else
                temp = 1
                return temp
            end
        end
        return temp
    end
end

return PlutusGameController