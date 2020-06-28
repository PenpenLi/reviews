--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

----------------------------------------------------------------------------------------------------------
-- 项目：百家乐
-- 时间: 2018-01-11
----------------------------------------------------------------------------------------------------------
local GoldenFlowerSearchPath = "src/app/game/GoldenFlower"
local Scheduler = require("framework.scheduler") 
local DlgAlert = require("app.hall.base.ui.MessageBox")
local BaseGameController = import(".BaseGameController") 
local Global = import("..GoldenFlower.GoldenFlowerGlobal") 
local GoldenFlowerGameController =  class("GoldenFlowerGameController",function()
    return BaseGameController.new()
end) 

GoldenFlowerGameController.instance = nil

-- 获取房间控制器实例
function GoldenFlowerGameController:getInstance()
    if GoldenFlowerGameController.instance == nil then
        GoldenFlowerGameController.instance = GoldenFlowerGameController.new()
    end
    return GoldenFlowerGameController.instance
end

function GoldenFlowerGameController:releaseInstance()
    if GoldenFlowerGameController.instance then
        GoldenFlowerGameController.instance:onDestory()
        GoldenFlowerGameController.instance = nil
		g_GameController = nil
    end
end
function GoldenFlowerGameController:ctor()
    print("GoldenFlowerGameController:ctor()")
    self:myInit()
end 

-- 初始化
function GoldenFlowerGameController:myInit()
    self._m_bMeLook = false
    self._m_bCanOut = false
    self._UserState = {}
    self._gameStation = 0
    self._thinkTime = 0
    self._beginTime = 0 
    self._mySeatNo = 0
    self._seatOffset = 0 
    self._maxPlayers = Global.PLAY_COUNT
    self.m_allPlayers = {}
     self.m_isSeeFlag = {}
    for k=0,10 do
        self.m_isSeeFlag[k] = false
    end
    print("GoldenFlowerGameController:myInit()") 
    -- 添加搜索路径
    ToolKit:addSearchPath(GoldenFlowerSearchPath.."/res")
    ToolKit:addSearchPath(GoldenFlowerSearchPath.."/src") 
    -- 加载场景协议以及游戏相关协议
     
    Protocol.loadProtocolTemp("app.game.GoldenFlower.protoReg")
     
      self:initNetMsgHandlerSwitchData()
    --注册游戏协议
  --  self:initNetMsgHandlerSwitchData()

  --  addMsgCallBack(self, PublicGameMsg.MSG_C2H_ENTER_SCENE_ACK, handler(self, self.Handle_EnterSceneAck))

    self:setGamePingTime( 5, 0x7FFFFFFF )--心跳包

end
 

function GoldenFlowerGameController:initNetMsgHandlerSwitchData()
    self.m_netMsgHandlerSwitch = {} 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_In_Wait_Nty"]                          =                   handler(self, self.gameStateFreeNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_In_PlayGame_Nty"]                      =                   handler(self, self.gameStatePlayNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Begin_Nty"]             =                   handler(self, self.gameBeginNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_PlayStart_Nty"]                  =                   handler(self, self.gameStartNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_SendCard_Nty"]            =                   handler(self, self.gameSendCardNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_GameEnd_Nty"]                 =                   handler(self, self.gameEndNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Raise_Nty"]                  =                   handler(self, self.gameRasieNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Action_Nty"]                   =                   handler(self, self.gameBetNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Fellow_Nty"]                =                   handler(self, self.gameFellowNty)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_See_Nty"]                  =                   handler(self, self.gameSeeAck)
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_GiveUp_Nty"]                   =                   handler(self, self.gameGiveUpAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Compare_Nty"]                   =                   handler(self, self.gameCompareAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_CombatGains_Nty"]                   =                   handler(self, self.gameCombatGainsAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Enter_Nty"]                   =                   handler(self, self.gameSitDown) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Leave_Nty"]                   =                   handler(self, self.gameStandUp) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Kick_Nty"]                   =                   handler(self, self.gameExit) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_Ready_Nty"]                   =                   handler(self, self.gameReadyAck) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_CompareTargetCard_Nty"]                   =                   handler(self, self.gameCompareCards) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_BetAll_Nty"]                   =                   handler(self, self.gameAllIn) 
    self.m_netMsgHandlerSwitch["CS_G2C_GlodenFlower_PublicCard_Nty"]                   =                   handler(self, self.gameLiangPai) 
    self.m_netMsgHandlerSwitch["CS_G2C_UserLeft_Ack"]                   		=                   handler(self, self.userLeftAck) 
   
    
    self.m_protocolList = {}
    for k,v in pairs(self.m_netMsgHandlerSwitch) do
        self.m_protocolList[#self.m_protocolList+1] = k
    end

    self:setNetMsgCallbackByProtocolList(self.m_protocolList, handler(self, self.netMsgHandler))
	
	self.m_callBackFuncList = {} 
    self.m_callBackFuncList["CS_M2C_GlodenFlower_Exit_Nty"]                   =                   handler(self, self.exitScene)  
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
    addMsgCallBack(self, "MSG_GAME_INIT", handler(self, self.onSceneInitMsgCall))
end
function GoldenFlowerGameController:onSceneInitMsgCall()
	 if self.m_pSceneNetMsgData ~= nil then
		for __, infoData in pairs(self.m_pSceneNetMsgData) do
			local idStr = infoData[1]
			local info = infoData[2]
			if self.m_callBackFuncList[idStr] then
				(self.m_callBackFuncList[idStr])( info )
			end	
		end
	end
	if self.m_pNetMsgData ~= nil then
		for __, infoData in pairs(self.m_pNetMsgData) do
			local idStr = infoData[1]
			local info = infoData[2]
			if  self.m_netMsgHandlerSwitch[idStr]  then
				(self.m_netMsgHandlerSwitch[idStr])(info)
			end
		end
	end
	self.m_pNetMsgData = nil
end
function GoldenFlowerGameController:onDestory()
    print("----------GoldenFlowerGameController:onDestory begin--------------")
     removeMsgCallBack(self, "MSG_GAME_INIT")
	self.m_netMsgHandlerSwitch = {}
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	
	if  self.m_lastTimer then
		Scheduler.unscheduleGlobal( self.m_lastTimer);
		self.m_lastTimer = nil
	end
	
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
	self:onBaseDestory()
	print("----------GoldenFlowerGameController:onDestory end--------------")

end

function GoldenFlowerGameController:userLeftAck(__info)
	print("BjlGameController:userLeftAck")
	self:releaseInstance()
end

function GoldenFlowerGameController:netMsgHandler( __idStr,__info )
    print("__idStr = ",__idStr) 
    if self.m_netMsgHandlerSwitch[__idStr] then
         if self.gameScene and self.gameScene.m_bIsInit then 
            (self.m_netMsgHandlerSwitch[__idStr])( __info )
        else
            self.m_pNetMsgData = self.m_pNetMsgData or {}
		    table.insert(self.m_pNetMsgData, {__idStr, __info})
        end
    else
        print("未找到炸金花游戏消息" .. (__idStr or ""))
    end
end

function GoldenFlowerGameController:sceneNetMsgHandler( __idStr, __info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if __info.m_result == 0 then
            if type( __info.m_message ) == "table" then
                if next( __info.m_message )  then
                    local cmdId = __info.m_message[1].id
                    local info = __info.m_message[1].msgs
                    if self.gameScene and self.gameScene.m_bIsInit then
                        if  self.m_callBackFuncList[cmdId]  then
						    (self.m_callBackFuncList[cmdId])(info)
					    else
						    print("没有处理消息",cmdId)
					    end
                    else
                        self.m_pSceneNetMsgData = self.m_pSceneNetMsgData or {}
			            table.insert(self.m_pSceneNetMsgData, {__idStr, __info})
                    end
                end
            end
      else
          print("__info.m_result", __info.m_result )
      end
    end
end

function GoldenFlowerGameController:exitScene(info)
 --   '1-房间维护结算退出 2-你已经被系统踢出房间,请稍后重试 3-超过限定局数未操作'
    if info.m_type == 0 then
        --self:releaseInstance()
        return
    end
	
    local str = ""
     if info.m_type ==1 then
        str = "分配游戏服失败"
    elseif info.m_type ==2 then
         str = "同步游戏服失败"
    elseif info.m_type ==3 then
         str = "你已经被系统踢出房间,请稍后重试"
    end
    local dlg = DlgAlert.showTipsAlert({title = "提示", tip = str, tip_size = 34})
    dlg:setSingleBtn("确定", function ()
		dlg:closeDialog()
		self:releaseInstance()
    end)
	
    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false) 
end

function GoldenFlowerGameController:gameCompareCards(__info)  
    for k,v in pairs(__info.m_cards) do
    --     if self.gameScene:getMainLayer():isShowCard(self:logicToViewSeatNo(v.m_opIdx)) then
            self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(v.m_opIdx), v.m_cards); 
--        else
--             self.gameScene:getMainLayer():showUserFlipCard(self:logicToViewSeatNo(v.m_opIdx), v.m_cards); 
--        end
--        self.gameScene:getMainLayer():showWatchCard(self:logicToViewSeatNo(v.m_opIdx), false); 
    end
end

function GoldenFlowerGameController:gameLiangPai(__info)  
  --   if self.gameScene:getMainLayer():isShowCard(self:logicToViewSeatNo(__info.m_opIdx)) then
         self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(__info.m_opIdx), __info.m_cards); 
--     else
--        self.gameScene:getMainLayer():showUserFlipCard(self:logicToViewSeatNo(__info.m_opIdx), __info.m_cards); 
--    end
--      self.gameScene:getMainLayer():showWatchCard(self:logicToViewSeatNo(__info.m_opIdx), false); 
end

function GoldenFlowerGameController:gameAllIn(__info)
    if __info.m_ret ~=0 then
        return
    end
	self._UserState[__info.m_opIdx]  = __info.m_state;

	--for i = 0, Global.PLAY_COUNT-1 do
		
	--	if (i == __info.m_opIdx) then 
			--self.gameScene:getMainLayer():setAfterBetMoney(self:logicToViewSeatNo(i), __info.m_allChip); 
	self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_curCoin);
	--	end
	--end
     --self.gameScene:getMainLayer():updateUserMoney(id, v.m_curCoin);
    -- 显示个人总下注
    self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(__info.m_opIdx), __info.m_userTotalBetValue);
	-- 显示加住
	self.gameScene:getMainLayer():showUserNote(self:logicToViewSeatNo(__info.m_opIdx));
	-- 显示总下注
	self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
    --显示桌面筹码
    self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_allChip);
end
function GoldenFlowerGameController:gameReadyAck(__info)
    if __info.m_ret ==0 then
        local seatNo = self:logicToViewSeatNo(__info.m_chairId);
        self.gameScene:getMainLayer():showReadySign(seatNo,true)
    end
end
function GoldenFlowerGameController:gameExit(__info)
    if __info.m_type == 1  then
        local dlg = DlgAlert.showTipsAlert({title="提示",tip="开局金币不足", tip_size = 34})
        dlg:setSingleBtn("确定", function ()
            dlg:closeDialog()
            self:releaseInstance()
        end)
        dlg:enableTouch(false)
        dlg:setBackBtnEnable(false)
	elseif __info.m_type == 2  then
        local dlg = DlgAlert.showTipsAlert({title="提示",tip="超时未准备", tip_size = 34})
        dlg:setSingleBtn("确定", function ()
			dlg:closeDialog()
            self:releaseInstance()
        end)
        dlg:enableTouch(false)
        dlg:setBackBtnEnable(false)
    else
        self:releaseInstance() 
    end
end
function GoldenFlowerGameController:gameSitDown(__info)  
    local seatNo = self:logicToViewSeatNo(__info.m_playerInfo.m_chairId);
    table.insert(self.m_allPlayers,__info.m_playerInfo)
    self.gameScene:getMainLayer():addUser(seatNo,__info.m_playerInfo); 
end
function GoldenFlowerGameController:gameStandUp(__info)  
     local seatNo = self:logicToViewSeatNo(__info.m_chairId);
     for k,v in pairs(self.m_allPlayers) do
        if v.m_chairId == __info.m_chairId then
            table.remove(self.m_allPlayers,k)
        end
    end
     self.gameScene:getMainLayer():removeUser(seatNo);
end
function GoldenFlowerGameController:gameFellowNty(__info)  
    if __info.m_ret ~=0 then
        return
    end
	self._UserState[__info.m_opIdx]  = __info.m_state;		
	-- 显示个人总下注
    self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(__info.m_opIdx), __info.m_userTotalBetValue);
    --显示桌面筹码 
    self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_followValue);
	-- 显示跟住

	self.gameScene:getMainLayer():showUserFollow(self:logicToViewSeatNo(__info.m_opIdx));

	--for  i = 0, Global.PLAY_COUNT-1 do 
	--	if (i == __info .m_opIdx) then  
		--	self.gameScene:getMainLayer():setAfterBetMoney(self:logicToViewSeatNo(i), __info.m_followValue); 
	self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_curCoin);
	--	end 
	--end
		
		
	-- 显示总下注
    self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
end
function GoldenFlowerGameController:gameGiveUpAck(__info) 
		-- 备份数据
    if __info.m_ret ~=0 then
        return
    end
	self._UserState[__info.m_opIdx] = __info.m_state; 
	-- 玩家弃牌
    local isMe = (__info.m_opIdx == self._mySeatNo);
	self.gameScene:getMainLayer():showUserGiveUp(self:logicToViewSeatNo(__info.m_opIdx),isMe); 
    
    if isMe then
        self._m_bCanOut = false;
    end
end
function GoldenFlowerGameController:gameCompareAck(__info) 
     if __info.m_ret ~=0 then
        print(__info.m_ret)
        return
    end
    print ("比牌玩家位置    "..__info.m_opIdx)
    print ("被比牌玩家位置    "..__info.m_beOpIdx)
	self._UserState[__info.m_opIdx] = __info.m_state; 
    self._UserState[__info.m_beOpIdx] = __info.m_beState; 

    -- 显示个人总下注
    self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(__info.m_opIdx), __info.m_userTotalBetValue);
	-- 显示总下注
    self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
	-- 显示比牌结果
    local lostdesk =0 
    if __info.m_winOpId == __info.m_opIdx then
        lostdesk = __info.m_beOpIdx
    elseif __info.m_winOpId == __info.m_beOpIdx then
        lostdesk = __info.m_opIdx
    end
	self.gameScene:getMainLayer():showCompareResult(self:logicToViewSeatNo(__info.m_winOpId), self:logicToViewSeatNo(lostdesk));

    --显示桌面筹码
    self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_openValue);
	self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(lostdesk), true);
    if self.gameScene:getMainLayer():getbtnCanelVisible() then
        self.gameScene:getMainLayer():showCanelFollow(false)
	end 
     self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_curCoin);
	--self.gameScene:getMainLayer():setAfterBetMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_openValue); 
    local isMe = (lostdesk == self._mySeatNo);
    if isMe then
        self._m_bCanOut = false;
    end
end
function GoldenFlowerGameController:gameCombatGainsAck(__info)
    	--self.gameScene:getMainLayer():showAllCalculateBoard(__info);
end
function GoldenFlowerGameController:gameRasieNty(__info) 
     if __info.m_ret ~=0 then
        return
    end
	self._UserState[__info.m_opIdx]  = __info.m_state;

	--for i = 0, Global.PLAY_COUNT-1 do
		
	--	if (i == __info.m_opIdx) then 
			--self.gameScene:getMainLayer():setAfterBetMoney(self:logicToViewSeatNo(i), __info.m_raiseValue); 
            self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_curCoin);
	--	end
	--end

    -- 显示个人总下注
    self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(__info.m_opIdx), __info.m_userTotalBetValue);
	-- 显示加住
	self.gameScene:getMainLayer():showUserNote(self:logicToViewSeatNo(__info.m_opIdx));
	-- 显示总下注
	self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
    --显示桌面筹码
    self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(__info.m_opIdx), __info.m_raiseValue);
end
function GoldenFlowerGameController:gameSeeAck(__info)  
    if __info.m_ret ~=0 then
        return
    end
	self._UserState[__info.m_opIdx] = __info.m_state;
	if self.m_isSeeFlag[__info.m_opIdx] == nil or self.m_isSeeFlag[__info.m_opIdx] == false then
        self.m_isSeeFlag[__info.m_opIdx] = true
    end
	local isMe = (__info.m_opIdx == self._mySeatNo);
	if(isMe) then 
--		self.gameScene:getMainLayer():showUserFlipCard(self:logicToViewSeatNo(self._mySeatNo), __info.m_cards); 
       --  self.gameScene:getMainLayer():doubleBetNum(true);
       self.gameScene:getMainLayer():SetCardData(__info.m_cards,3,self:logicToViewSeatNo(self._mySeatNo))
	end

	self._m_bMeLook = isMe;
	-- 提示看牌		
	self.gameScene:getMainLayer():showUserLookCard(self:logicToViewSeatNo(__info.m_opIdx), isMe);	

end
function GoldenFlowerGameController:gameSendCardNty(__info)  
		self.gameScene:getMainLayer():showReadySign(Global.INVALID_SEAT_NO, false); 
        self._gameStation = Global.GS_SEND_CARD;
--		-- 显示手牌
--		std::vector<THandCard> cards;
--		for  i = 0, Global.PLAY_COUNT-1 do 

--            --发牌玩家的位置索引
--            BYTE sendCardIndex = __info.bySendCardTurn[i];			
--            if (__info.byCardCount[sendCardIndex]>0)

--                THandCard card;
--                card.bySeatNo = self:logicToViewSeatNo(sendCardIndex);
--                memcpy(card.byCards, __info.byCard[sendCardIndex], sizeof(BYTE)*__info.byCardCount[sendCardIndex]);
--				cards.push_back(card);
--			end
--		end

end
function GoldenFlowerGameController:gameBeginNty(__info)    
		self.gameScene:getMainLayer():showTobeBegin(false);
        self.gameScene:getMainLayer():RefreshCards()
         self.gameScene:getMainLayer():removeAllTag()
		-- 游戏数据重置
		self:refreshParams();
        self:clearDesk(); 
        self.m_sRecordId = __info.m_recordId or ""
        self.gameScene:getMainLayer():setRecordId(__info.m_recordId)
	--	memcpy(self._UserState, __info.m_state, sizeof(self._UserState));

		--隐藏准备标志
		self.gameScene:getMainLayer():showReadySign(Global.INVALID_SEAT_NO, false);
		self.gameScene:getMainLayer():showGiveUpCard(Global.INVALID_SEAT_NO, false);
		
		
		self.gameScene:getMainLayer():showHandCardBroken(Global.INVALID_SEAT_NO, false);
		

        self.gameScene:getMainLayer():showWaitTime(self:logicToViewSeatNo(self._mySeatNo), true);

		
-- 		for  i = 0, Global.PLAY_COUNT-1 do 

-- 			self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(i), false);
-- 		end
		self.guodi = __info.m_guodi
		-- 锅底信息
        self.gameScene:getMainLayer():showBaseNote(__info.m_guodi);
        self.gameScene:getMainLayer():showLimitPerNote(__info.m_topLimit);
        self.gameScene:getMainLayer():showGuoDi(__info.m_guodi);
        self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
        -- 显示庄家
    --    self.gameScene:getMainLayer():showDealer(self:logicToViewSeatNo(__info.byNtStation));

	--	self.gameScene:getMainLayer():setBtnEnable(true);
		self._m_bCanOut = true;
		
--		for  i = 0, Global.PLAY_COUNT-1 do 
--			self._allUserMoney[i+1] =self._allUserMoney[i+1]- __info.m_guodi;
--			self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(i), __info.m_guodi, self._allUserMoney[i+1]);

--            self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(i), 0);
--            --显示桌面筹码
--            self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(i), __info.m_guodi);  
--		end
--        for  i = 0, Global.PLAY_COUNT-1 do  
--			self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(i), false);
--		end
      --  self.m_allPlayers = __info.m_playerBetInfo
        local cards = {}
        for k,v in pairs(__info.m_playerBetInfo) do
            local tab = {}
            local id = self:logicToViewSeatNo(v.m_chairId)
            tab.bySeatNo =id
            tab.byCards = {0,0,0}
            table.insert(cards,tab) 
        --    self.gameScene:getMainLayer():updateUserMoney(id, __info.m_guodi, self._allUserMoney[id+1]);
            self.guodi = __info.m_guodi
            self.gameScene:getMainLayer():showMyTotalNote(id, __info.m_guodi);
             self.gameScene:getMainLayer():showUserNoteMoney(id, __info.m_guodi);  
             self.gameScene:getMainLayer():showHandCardBroken(id, false);
              self.gameScene:getMainLayer():updateUserMoney(id, v.m_userCurCoin);
        end
		self.gameScene:getMainLayer():showHandCard(cards);
end
function GoldenFlowerGameController:isGameing()
    return self._m_bCanOut
end
function GoldenFlowerGameController:setGameInfo(__info)
    self:clearDesk();	
    self:refreshParams(); 
    for k,v in pairs(__info.m_allPlayers) do 
        if v.m_accountId == Player:getAccountID() then 
            self._mySeatNo =v.m_chairId 
            self._seatOffset = -self._mySeatNo
        end 
    end
     for k,v in pairs(__info.m_allPlayers) do  
        local seatNo = self:logicToViewSeatNo(v.m_chairId);
        table.insert(self.m_allPlayers,v)
        self.gameScene:getMainLayer():addUser(seatNo,v); 
    end    
    self.guodi = __info.m_guodi
    self.gameScene:getMainLayer():setBetNum(__info.m_betInfo); 
    self.gameScene:getMainLayer():showAllNoteOnTable(__info.m_betInfo);
end
function GoldenFlowerGameController:getPlayer(seat)
     for k,v in pairs(self.m_allPlayers) do  
        local id = self:logicToViewSeatNo(v.m_chairId)
        if id ==seat then
            return v 
        end
    end  
    return nil
end

function GoldenFlowerGameController:gameStateFreeNty(__info) 
   
   self:setGameInfo(__info)
    self._beginTime  =__info.m_beginTime; 
    self.m_sRecordId = __info.m_recordId or ""
    if 1 ~= __info.m_state then
        self.gameScene:getMainLayer():setRecordId(self.m_sRecordId)
    end
    
    if __info.m_state == 1 then
		self._thinkTime = __info.m_thinkTime; 
       self.guodi = __info.m_guodi
		-- 界面显示	
        self.gameScene:getMainLayer():showBaseNote(__info.m_guodi);
        self.gameScene:getMainLayer():showGuoDi(__info.m_guodi);
        self.gameScene:getMainLayer():showLimitPerNote(__info.m_topLimit);
		self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
		self.gameScene:getMainLayer():showWatchCard(Global.INVALID_SEAT_NO, false);
		self.gameScene:getMainLayer():showGiveUpCard(Global.INVALID_SEAT_NO, false);
--		self.gameScene:getMainLayer():showHandCardBroken(Global.INVALID_SEAT_NO, false);
       
		--显示准备标志 
		for k,v in pairs(__info.m_allPlayers) do
             if (v.m_ready==1) then 
				self.gameScene:getMainLayer():showReadySign(self:logicToViewSeatNo(v.m_chairId), true); 
			else 
				self.gameScene:getMainLayer():showReadySign(self:logicToViewSeatNo(v.m_chairId), false);
			end
            -- 显示自己总下注
            self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(v.m_chairId), 0); 
		--	self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(v.m_chairId), false);
		end
        for k,v in pairs(__info.m_allPlayers) do
            if (v.m_chairId == self._mySeatNo and v.m_ready == 0) then

			    self.gameScene:getMainLayer():showWaitTime(self:logicToViewSeatNo(self._mySeatNo), false);
			    --当前玩家是自己才显示时钟
                self.gameScene:getMainLayer():IStartTimer(__info.m_leftTime);
                self.gameScene:getMainLayer():showReady(true);
		        self.gameScene:getMainLayer():showNextGame(false);
		    end
		end		
        self._m_bCanOut = false
    elseif  __info.m_state == 2 then
    -- 数据缓存 
      self.gameScene:getMainLayer():RefreshCards()
        local cards = {}
        for k,v in pairs(__info.m_allPlayers) do
            local tab = {}
            local id = self:logicToViewSeatNo(v.m_chairId)
            tab.bySeatNo =id
            tab.byCards = {0,0,0}
            table.insert(cards,tab)  
        end
		self.gameScene:getMainLayer():sendCardToPlayerTable(false,cards);
		self._thinkTime  = __info.m_thinkTime; 
		self._m_bCanOut = true;
		-- 界面显示
        self.gameScene:getMainLayer():showBaseNote(__info.m_guodi);
        self.gameScene:getMainLayer():showGuoDi(__info.m_guodi);
        self.gameScene:getMainLayer():showLimitPerNote(__info.m_topLimit);
        self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
		self.gameScene:getMainLayer():showReady(false); 
        for k,v in pairs(__info.m_allPlayers) do 
            if v.m_accountId == __info.m_banker then 
                self.gameScene:getMainLayer():showDealer(self:logicToViewSeatNo(v.m_chairId));
            end
        end
		--隐藏准备标志
		self.gameScene:getMainLayer():showReadySign(Global.INVALID_SEAT_NO, false);
		self.gameScene:getMainLayer():showWatchCard(Global.INVALID_SEAT_NO, false);
		self.gameScene:getMainLayer():showGiveUpCard(Global.INVALID_SEAT_NO, false);
		self.gameScene:getMainLayer():showHandCardBroken(Global.INVALID_SEAT_NO, false);
		-- 显示玩家手上的牌 
--		-- 显示玩家下注的钱
	--	for  i = 0, Global.PLAY_COUNT-1 do 
        self.m_allPlayers = __info.m_allPlayers
        for k,v in pairs(__info.m_allPlayers) do
			if (Global.STATE_ERR ~= v.m_state) then 
                -- 显示玩家总下注
                self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(v.m_chairId), v.m_totalBet);
				self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(v.m_chairId), __info.m_guodi); 
                if Global.STATE_LOOK == v.m_state then
                    if self.m_isSeeFlag[v.m_chairId] == nil or self.m_isSeeFlag[v.m_chairId] ==false then
                        self.m_isSeeFlag[v.m_chairId] = true
                    end
                end
                if (v.m_chairId == self._mySeatNo and (Global.STATE_LOOK == v.m_state)) then 
                   
				    self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(v.m_chairId), __info.m_myCards); 
			    else
				    local cards = {0,0,0}
				    self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(v.m_chairId), cards);
			    end
			elseif (v.m_chairId == self._mySeatNo and (Global.STATE_ERR ==v.m_state)) then 
				self.gameScene:getMainLayer():showNextGame(true);
				--self.gameScene:getMainLayer():setBtnEnable(true);
				self._m_bCanOut = false;
			end			
            self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(v.m_chairId), false);
		end
       
    end
end

function GoldenFlowerGameController:gameStatePlayNty(__info) 
  	-- 数据备份
     self.m_bAll = __info.m_bAll
    self._m_bCanOut = true;
    self:setGameInfo(__info)
   --  self._UserState = {0,0,0,0,0}
	self._thinkTime        = __info.m_thinkTime; 
     self._beginTime  =__info.m_beginTime; 
     self.m_sRecordId = __info.m_recordId or ""
--	self.gameScene:getMainLayer():setTimeBgRota(self:logicToViewSeatNo(__info.m_curOpIdx));
	-- 界面显示
    self.gameScene:getMainLayer():showBaseNote(__info.m_guodi);
    self.gameScene:getMainLayer():showGuoDi(__info.m_guodi);
    self.gameScene:getMainLayer():showLimitPerNote(__info.m_topLimit);
    self.gameScene:getMainLayer():showTotalNote(__info.m_allTotalBetValue);
	self.gameScene:getMainLayer():showReady(false);
     self.gameScene:getMainLayer():showRound(__info);
     self.gameScene:getMainLayer():setRecordId(__info.m_recordId)
    -- 显示庄家
    self.m_allPlayers = __info.m_allPlayers
         self.gameScene:getMainLayer():RefreshCards()
    local cards = {}
    for k,v in pairs(__info.m_allPlayers) do
        local tab = {}
        local id = self:logicToViewSeatNo(v.m_chairId)
        tab.bySeatNo =id
        tab.byCards = {0,0,0}
        table.insert(cards,tab)  
    end
	self.gameScene:getMainLayer():sendCardToPlayerTable(false,cards);
--    for k,v in pairs(self.m_allPlayers) do 
--        if v.m_accountId == __info.m_banker then 
--            self.gameScene:getMainLayer():showDealer(self:logicToViewSeatNo(v.m_chairId));
--        end
--    end 
	-- 显示倒计时
	--self:stopAllWait();
  --  self.gameScene:getMainLayer():showWaitTime(self:logicToViewSeatNo(__info.m_curOpIdx), false);

	-- 显示玩家手上的牌
	 for k,v in pairs(self.m_allPlayers) do  
		self._UserState[v.m_chairId] = v.m_state
        if (v.m_state ~=Global.STATE_ERR) then
			
			if (v.m_chairId == self._mySeatNo and (Global.STATE_LOOK == v.m_state)) then 
                self._m_bMeLook = true;
				self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(v.m_chairId), __info.m_myCards); 
			else
				local cards = {0,0,0}
				self.gameScene:getMainLayer():showUserHandCard(self:logicToViewSeatNo(v.m_chairId), cards);
			end

		end

		if (Global.STATE_ERR ~= v.m_state) then
			
                self.gameScene:getMainLayer():showMyTotalNote(self:logicToViewSeatNo(v.m_chairId),v.m_totalBet);
            self.gameScene:getMainLayer():showUserNoteMoney(self:logicToViewSeatNo(v.m_chairId), __info.m_guodi);
		--	self.gameScene:getMainLayer():setBtnEnable(true);
			--self._m_bCanOut = true; 
		elseif (v.m_chairId == self._mySeatNo and (Global.STATE_ERR == v.m_state)) then
			
			self.gameScene:getMainLayer():showNextGame(true);
			--self.gameScene:getMainLayer():setBtnEnable(true);
            self._gameStation = GS_WAIT_NEXT;
			self._m_bCanOut = false;
		end
			

		if (Global.STATE_GIVE_UP == v.m_state) then
			
			self.gameScene:getMainLayer():showGiveUpCard(self:logicToViewSeatNo(v.m_chairId), v.m_chairId == self._mySeatNo);
			if (v.m_chairId == self._mySeatNo) then
				
		--		self.gameScene:getMainLayer():setBtnEnable(true);
				self._m_bCanOut = false;
			end 
        elseif (Global.STATE_COMPARE_LOSE == v.m_state) then
            
         --   self.gameScene:getMainLayer():showHandCardBroken(self:logicToViewSeatNo(v.m_chairId),true);
			if (v.m_chairId == self._mySeatNo) then
				
			--	self.gameScene:getMainLayer():setBtnEnable(true);
				self._m_bCanOut = false;
			end 
		elseif (Global.STATE_LOOK ==v.m_state) then
			
            if (v.m_chairId ~= self._mySeatNo) then
                
                self.gameScene:getMainLayer():showWatchCard(self:logicToViewSeatNo(v.m_chairId), true); 
            else 
                --加倍显示四个下注筹码
                self.gameScene:getMainLayer():doubleBetNum(true);
            end	
            if self.m_isSeeFlag[v.m_chairId] == nil or self.m_isSeeFlag[v.m_chairId] ==false then
                self.m_isSeeFlag[v.m_chairId] = true
            end			
		end 
	end
		
    local isMe = (__info.m_curOpIdx == self._mySeatNo);
    --显示时钟
 --   self.gameScene:getMainLayer():IStartTimer(__info.m_leftTime);
	
	self.gameScene:getMainLayer():showDashboard(isMe);
    if isMe then	 
         self.gameScene:getMainLayer():setLookVisible(__info.m_bLook);
        self.gameScene:getMainLayer():setFollowVisible(__info.m_bFollow);
        self.gameScene:getMainLayer():setAddVisible(isMe, __info.m_bAdd);
        self.gameScene:getMainLayer():setOpenVisible(__info.m_bOpen);
        self.gameScene:getMainLayer():setGiveUpVisible( __info.m_bGiveUp);
         self.gameScene:getMainLayer():setAllInVisible(__info.m_bAll);
    end
    self.gameScene:getMainLayer():SetGameClock(self:logicToViewSeatNo(__info.m_curOpIdx), 201, self._thinkTime)

end  
--续压
function GoldenFlowerGameController:gameStartNty(__info) 
    self._gameStation = GS_PLAY_GAME;
     self.gameScene:getMainLayer():showRound(__info);
	-- 操作提示
     self.m_bAll = __info.m_bAll
	self:stopAllWait();
    self.gameScene:getMainLayer():showWaitTime(self:logicToViewSeatNo(__info.m_opIdx), false);

	-- 显示操作按钮
    local isMe = (__info.m_opIdx == self._mySeatNo);
--	if (isMe) then

--		self.gameScene:getMainLayer():setTimeBgRota(0); 
--	else 
--		self.gameScene:getMainLayer():setTimeBgRota1(self:logicToViewSeatNo(__info.m_opIdx));
--	end
		
	self.gameScene:getMainLayer():showDashboard(isMe);
    self.gameScene:getMainLayer():showAlwaysFollow(not isMe);
    if (isMe) then
        self.gameScene:getMainLayer():setLookVisible(__info.m_bLook);
        self.gameScene:getMainLayer():setFollowVisible(__info.m_bFollow);
        self.gameScene:getMainLayer():setAddVisible(isMe, __info.m_bAdd);
        self.gameScene:getMainLayer():setOpenVisible(__info.m_bOpen);
        self.gameScene:getMainLayer():setGiveUpVisible( __info.m_bGiveUp);
         self.gameScene:getMainLayer():setAllInVisible(__info.m_bAll);
   
    end
    self.gameScene:getMainLayer():SetGameClock(self:logicToViewSeatNo(__info.m_opIdx), 201, self._thinkTime)
	--显示时钟
	--self.gameScene:getMainLayer():IStartTimer(self._thinkTime);
end
 
 function GoldenFlowerGameController:getMySeat()
    return self._mySeatNo
 end
function GoldenFlowerGameController:gameEndNty(__info) 
    self._gameStation = GS_WAIT_NEXT;
	--self.gameScene:getMainLayer():setTimeBgRota(0);
    -- sendUserReady();
    -- 游戏数据重置
 --   self:refreshParams();
   -- self:clearDesk()
	-- 显示赢牌玩家
--	self.gameScene:getMainLayer():showWin(self:logicToViewSeatNo(__info.m_winner));
	self.gameScene:getMainLayer():showCanelFollow(false);
--	self.gameScene:getMainLayer():setTimerVisible(true);
	self.gameScene:getMainLayer():showDashboard(true);
    self.gameScene:getMainLayer():showAlwaysFollow(false);
--	self.gameScene:getMainLayer():IStartTimer(5);
 --   self.gameScene:getMainLayer():showReady(true);
     
    --if self:isGameing() or self._UserState[self._mySeatNo]==Global.ACTION_GIVEUP or self._UserState[self._mySeatNo]==Global.ACTION_OPEN then
    
   self.m_winner=    self:logicToViewSeatNo(__info.m_winner)
   -- end
   self.m_lWinScore={}
    for k,v in pairs(__info.m_allResult) do
     --   self.gameScene:getMainLayer():setAfterBetMoney(self:logicToViewSeatNo(v.m_chairId),- v.m_netProfit); 
        self.gameScene:getMainLayer():updateUserMoney(self:logicToViewSeatNo(v.m_chairId), v.m_curScore);
        table.insert(self.m_lWinScore,v.m_netProfit)
     --    self.gameScene:getMainLayer():playHeadMoney(self:logicToViewSeatNo(v.m_chairId), v.m_netProfit); 
        
         if v.m_chairId == self._mySeatNo then
          --  if self.gameScene:getMainLayer():getHandCardVisible(self:logicToViewSeatNo(v.m_chairId)) then
            if v.m_netProfit~=0 then
                 self.gameScene:getMainLayer():showLiangPai(true);
           end
        end
    end
    self.gameScene:getMainLayer():onMsgGameEnd(__info.m_allResult)
    if  self.m_lastTimer then
		Scheduler.unscheduleGlobal( self.m_lastTimer);
		self.m_lastTimer = nil
	end
    self.m_lastTimer = Scheduler.performWithDelayGlobal(function()
        self.gameScene:getMainLayer():showReady(true);
        self.gameScene:getMainLayer():IStartTimer(self._beginTime);
        self.gameScene:getMainLayer():showLiangPai(false);
        self.gameScene:getMainLayer():showDashboard(false);
        self.gameScene:getMainLayer():showAlwaysFollow(false);
    end, 5)
--        if v.m_accountId == Player:getAccountID() then
--	        if (v.m_profit~=0) then

--		        if (v.m_profit>0) then

--			        self.gameScene:getMainLayer():playWinAnimation(); 
--		        elseif (v.m_profit<0) then

--			        self.gameScene:getMainLayer():playLoseAnimation();
--		        end
--		        self.gameScene:getMainLayer():showEndBox(__info); 
--	        elseif (v.m_profit == 0) then

--		        self.gameScene:getMainLayer():showReady(true);
--	        end
--		end
--    end
--	if (self:logicToViewSeatNo(__info.m_winner) == 0) then

--		self.gameScene:getMainLayer():showAni();
--	end

--	for  k,v in pairs(__info.m_allResult) do
--		if (v.m_chairId == self._mySeatNo and (GS_PLAY_GAME ==v.m_state)) then 
--			local mycards; 
--			if (not self._m_bMeLook ) then

--				self.gameScene:getMainLayer():showUserFlipCard(self:logicToViewSeatNo(v.m_chairId),v.m_cards);
--			end

--			for  j = 0, Global.PLAY_COUNT-1 do 
--				if (v.m_bCompare[j+1]) then

--					self.gameScene:getMainLayer():showUserFlipCard(self:logicToViewSeatNo(j), v.m_cards);
--				end
--			end
--		end 
--	end
	--self.gameScene:getMainLayer():setBtnEnable(true);
	self._m_bCanOut = false;
  
end 

function GoldenFlowerGameController:gameBetNty(__info) 
	-- 显示倒计时 
     self.m_bAll = __info.m_bAll
	self:stopAllWait();
  --  self.gameScene:getMainLayer():showWaitTime(self:logicToViewSeatNo(__info.m_opIdx), false);
  self.gameScene:getMainLayer():SetGameClock(self:logicToViewSeatNo(__info.m_opIdx), 201, self._thinkTime)
     self.gameScene:getMainLayer():showRound(__info);
    -- 显示操作按钮
    local isMe = (__info.m_opIdx == self._mySeatNo);
    self.gameScene:getMainLayer():showDashboard(isMe);
    self.gameScene:getMainLayer():showAlwaysFollow(not isMe);
    if __info.m_bAll ==1 then
        self.gameScene:getMainLayer():showAlwaysFollow(false);
    end
    if isMe then
        self.gameScene:getMainLayer():setLookVisible( __info.m_bLook);
        self.gameScene:getMainLayer():setFollowVisible(__info.m_bFollow);
        self.gameScene:getMainLayer():setAddVisible(isMe, __info.m_bAdd);
        self.gameScene:getMainLayer():setOpenVisible(__info.m_bOpen);
        self.gameScene:getMainLayer():setGiveUpVisible(__info.m_bGiveUp);
	    self.gameScene:getMainLayer():setAlwaysFollowVisble(false);
        self.gameScene:getMainLayer():setAllInVisible(__info.m_bAll);
    end
    --显示时钟
  --  self.gameScene:getMainLayer():IStartTimer(self._thinkTime);
	if (isMe) then
		
	--	self.gameScene:getMainLayer():setTimeBgRota(0); 
        
	    if 	(__info.m_isEverAll == 1 or __info.m_bAll==1) and self.gameScene:getMainLayer():getbtnCanelVisible() then
            self.gameScene:getMainLayer():showCanelFollow(false)
            self.gameScene:getMainLayer():showDashboard(true);
            self.gameScene:getMainLayer():showAlwaysFollow(false);
           
        end
         if __info.m_isEverAll==1 then
            self.gameScene:getMainLayer():setFollowMoney(__info.m_followCoin*0.01)
            
        else
            self.gameScene:getMainLayer():setFollowMoney(0)
        end
        if (self.gameScene:getMainLayer():getbtnCanelVisible() and __info.m_bFollow  ) then
		     self.gameScene:getMainLayer():showAlwaysFollow(false);
		    self.gameScene:getMainLayer():showDashboard(false);
		    self:sendFollow();
	    end
	else
		if __info.m_isEverAll==1 or self.gameScene:getMainLayer():getbtnCanelVisible() or not self:isGameing() then 
             self.gameScene:getMainLayer():showAlwaysFollow(false);
        end
	--	self.gameScene:getMainLayer():setTimeBgRota(self:logicToViewSeatNo(__info.m_opIdx));
	end
   
	
end  
function GoldenFlowerGameController:sendAgreeGame()
      if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_Ready_Req", { })
	end
end

function GoldenFlowerGameController:sendAllIn()
      if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_BetAll_Req", { })
	end
end
function GoldenFlowerGameController:sendLiangPai()
      if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_PublicCard_Req", { })
	end
end
function GoldenFlowerGameController:sendAddBet(raiseType)
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_Raise_Req", { raiseType})
	end
end 
function GoldenFlowerGameController:sendGiveUp()
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_GiveUp_Req", { })
	end
end
function GoldenFlowerGameController:sendLook()
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_See_Req", { })
	end
end
function GoldenFlowerGameController:compareCardReq()
 
	local seats ={};
    local remainPlayer = 0;
    local logicSeat = INVALID_DESKSTATION;

	for k,v in pairs(self._UserState) do
		     
        if (v ~= Global.STATE_GIVE_UP) and (v ~= Global.STATE_COMPARE_LOSE) and (v ~= Global.STATE_ERR) and  (k ~= self._mySeatNo) then
			
			seats[self:logicToViewSeatNo(k)] = true;
            logicSeat = k;
            remainPlayer = remainPlayer+1;
			
		else 
			seats[self:logicToViewSeatNo(k)] = false;
		end
			
	end
    --如果只剩下一个人比牌的时候就不用选择了
    if (1 == remainPlayer) then 
        self:sendCompare(logicSeat); 
    else 
        self.gameScene:getMainLayer():SetCompareCardLabel(true,seats);
    end		
end
function GoldenFlowerGameController:sendCompare(beComOpIdx)
     if self.m_gameAtomTypeId then
        print("我的位置             "..self._mySeatNo)
        print("被比牌玩家位置             "..beComOpIdx)

		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_Compare_Req", {beComOpIdx })
	end
end 
function GoldenFlowerGameController:sendFollow()
     if self.m_gameAtomTypeId then
		ConnectManager:send2GameServer( self.m_gameAtomTypeId,"CS_C2G_GlodenFlower_Fellow_Req", { })
	end
end
function GoldenFlowerGameController:viewToLogicSeatNo( vSeatNO) 
    local seat = (vSeatNO - self._seatOffset + self._maxPlayers) % self._maxPlayers
    if seat == 0 then
        seat =5
    end
	return seat
end

function GoldenFlowerGameController:logicToViewSeatNo( lSeatNO)
	
	return (lSeatNO + self._seatOffset + self._maxPlayers) % self._maxPlayers;
end
--function GoldenFlowerGameController:onConnectGameServer( __info )
--   self:setEnterGameAck()
--end
-- function GoldenFlowerGameController:setEnterGameAck() 

--	self:setEnterGameAckHandler(handler(self,self.ackRealEnterGame))
--end 
function GoldenFlowerGameController:ackEnterGame( __info )
    print("GoldenFlowerGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL )  
    end
end
function GoldenFlowerGameController:EnterGame( gameId )
    print("GoldenFlowerGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()  
   -- if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(gameId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL ) 
       -- self.gameScene:getMainLayer()= self.gameScene:getMainLayer()
 --   end
end
function GoldenFlowerGameController:handleError(__info)
    if __info.m_ret~=0 then 
     
        local box_title = "提示"
        local box_content = "进入《炸金花》失败"
        local cb1 = function() end
        local params = {
            title = box_title,
            message = box_content,
            leftStr = btnText1,
            rightStr = btnText2,
            tip = box_content,
        }
        local dlg = require("app.hall.base.ui.MessageBox").new()
        dlg.showRightAlert(params,cb1) 
    end     
end

--[[
function GoldenFlowerGameController:setGameAtomTypeId( _gameAtomTypeId )
    self.m_gameAtomTypeId = _gameAtomTypeId
end 

function GoldenFlowerGameController:getGameAtomTypeId()
    return self.m_gameAtomTypeId 
end
--]]

function GoldenFlowerGameController:clearDesk()
   --  self:stopAllWait();
     local m_bAdd = {}
	self.gameScene:getMainLayer():showDashboard(false);
     self.gameScene:getMainLayer():showAlwaysFollow(false);
	self.gameScene:getMainLayer():setLookVisible(false);
	self.gameScene:getMainLayer():setFollowVisible(false);
	--self.gameScene:getMainLayer():setAlwaysFollowVisble(false);
    self.gameScene:getMainLayer():setAddVisible(false, m_bAdd);
	self.gameScene:getMainLayer():setOpenVisible(false);
	self.gameScene:getMainLayer():setGiveUpVisible(false);
	self.gameScene:getMainLayer():setFollowVisible(false);
    self.gameScene:getMainLayer():showWatchCard(Global.INVALID_SEAT_NO, false);
    self.gameScene:getMainLayer():showGiveUpCard(Global.INVALID_SEAT_NO, false);
	 self.gameScene:getMainLayer():resetHandCardGray()
--	self.gameScene:getMainLayer():showHandCardBroken(Global.INVALID_SEAT_NO, false);
    self.gameScene:getMainLayer():showTotalNote(0);
    for  i = 0, Global.PLAY_COUNT-1 do 
    
        self.gameScene:getMainLayer():showMyTotalNote(i, 0);
    end
    self.gameScene:getMainLayer():clearDesk();
end
function GoldenFlowerGameController:stopAllWait()
   for  i = 0, Global.PLAY_COUNT-1 do 
		
		local vSeatNo = self:logicToViewSeatNo(i);
        self.gameScene:getMainLayer():showWaitTime(vSeatNo,true);
--		self.gameScene:getMainLayer():IStartTimer(0);
	end
end
function GoldenFlowerGameController:logicToViewSeatNo(lSeatNO)
    return (lSeatNO - self._mySeatNo + Global.PLAY_COUNT) % Global.PLAY_COUNT;
end
function GoldenFlowerGameController:GetNextDeskStation()
   return (self._mySeatNo + (Global.PLAY_COUNT - 1)) % Global.PLAY_COUNT;
end
function GoldenFlowerGameController:initParams()
    self._thinkTime = 15; 
    self._m_bMeLook = false;
    self._UserState={} 
     for k=0,10 do
        self.m_isSeeFlag[k] = false
    end
end
function GoldenFlowerGameController:refreshParams()
    self._UserState={}
    self._m_bMeLook = false;
     for k=0,10 do
        self.m_isSeeFlag[k] = false
    end
   -- self._mySeatNo = 0
    
end

return GoldenFlowerGameController