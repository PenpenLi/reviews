--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


 

 local  Scheduler              =  require("framework.scheduler") 
local BaseGameController = import(".BaseGameController")

local HbjlGameController = class("HbjlGameController",function()
    return BaseGameController.new()
end)

function HbjlGameController:ctor() 
    ToolKit:addSearchPath("src/app/game/hbjl/res") 
    -- 加载龙虎斗协议
  	Protocol.loadProtocolTemp("app.game.hbjl.protoReg")
	-- 初始化龙虎斗数据
	self:inithbjlData()
	-- 注册协议
	self:initCallBackFuncList()
  self:registNetMassege()
	
end

--  初始化推饼数据
function HbjlGameController:inithbjlData()
	print("HbjlGameController:inithbjlData()")
  self.m_canOut= true
 	self.m_gameSceneIndex = 1        --场景索引
              --场景节点
  self.myServerChipinCoin = {}     --我的下注(服务端的值)
  self.myClientChipinCoin = {}     --我的下注(客户端的值)
  self.totalServerChipinCoin = {}  --总下注(服务端的值)
  self.totalCentChipinCoin = {}    --总下注(客户端的值)
  for i=1,3 do
  	self.myServerChipinCoin[i] = 0
  	self.myClientChipinCoin[i] = 0
  	self.totalServerChipinCoin[i] = 0
  	self.totalCentChipinCoin[i] = 0
  end
  self.chipInTime   = 30 
  self.m_waitLotteryTime = 10     
  self.m_gameStage  =  0         -- 游戏状态
  self.m_gameStageTime = 0       -- 该游戏状态的时间
  self.m_myChipInNumList = {}    -- 我的下注列表
  for i=1,3 do
  	self.m_myChipInNumList[i] = {}
  end
 
  self.m_peopleCnt = 0             -- 房间人数
  self.m_time      = 0             -- 服务端时间
  self.m_roundId    = 0            -- 轮次
  self.m_confTime = 0              -- 本阶段预留时间置
  self.m_leftTime = 0              -- 本阶段剩余时间
  self.m_dragonCard = 0            -- 龙牌面值
  self.m_tigerCard  = 0            -- 虎牌面值
  self.m_goldRankPlayers = {}      -- 金币最多玩家
  self.m_rateOfWinningPlayer = {}  -- 胜率最多玩家
  self.m_myHbjlPlayer = nil        -- 主玩家信息
  self.areaBets = {}       
  for i=1,3 do
     self.areaBets[i] = {}
  end       
  self.m_vecBallHistory = {}
  self.chipNumTable = {} 
  self.comparisonCardResult = 0
  self.m_vecBalance = {}
  self.m_enterForeground = false
   self._areaTotalValue={0,0,0}
    self._myareaTotalValue={0,0,0}
end 

HbjlGameController.instance = nil

-- 获取推饼游戏控制器实例
function HbjlGameController:getInstance()
	if HbjlGameController.instance == nil then
		HbjlGameController.instance = HbjlGameController.new()
	end
    return HbjlGameController.instance
end
function HbjlGameController:releaseInstance()
    if HbjlGameController.instance then
        HbjlGameController.instance:onDestory()
        HbjlGameController.instance = nil
		g_GameController = nil
    end
end
-- 注册网络消息
function HbjlGameController:registNetMassege()
    TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end

-- 生成消息和对应处理函数的映射关系
function HbjlGameController:initCallBackFuncList()
	self.m_callBackFuncList = {} 
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_PlayerIn_Nty"]           = handler(self, self.ackHbjlPlayerIn )         -- 新玩家进入
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_PlayerOut_Nty"]           = handler(self, self.ackHbjlPlayerOut )         -- 新玩家退出
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_GameState_Nty"]            = handler(self, self.HbjlGameState)        -- 游戏信息初始化
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_Give_Nty"]                  = handler(self, self.ackHbjlGive)                 -- 下注结果，自己下注各区域加减走这个协议
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_Grab_Nty"]          = handler(self, self.ackHbjlGrab)      -- 下注飞筹码效果, 各区域加金币走这个协议 
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_GameBalance_Nty"]          = handler(self, self.HbjlGameBalance)      -- 下注结算
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_Exit_Nty"]     = handler(self, self.ackHbjlExit)    -- 在线玩家列表
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_Background_Ack"]           = handler(self, self.ackhbjlBackground) -- 切换后台
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_ForceExit_Ack"]            = handler(self, self.ackhbjlForceExit ) -- 玩家退出  
    self.m_callBackFuncList["CS_M2C_RedEnvelopes_Start_Nty"]            = handler(self, self.gameStart ) -- 玩家退出  
end

-- 销毁龙虎斗游戏管理器
function HbjlGameController:onDestory()
	print("----------HbjlGameController:onDestory begin--------------")

	self.m_callBackFuncList = {}
	
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")
	
	if self.showBalanceTimer then
		scheduler.unscheduleGlobal(self.showBalanceTimer)
		self.showBalanceTimer = nil
	end
   
	if self.gameScene then
		UIAdapter:popScene()
		self.gameScene = nil
	end
	
	self:onBaseDestory()
	print("----------HbjlGameController:onDestory end--------------")

end

function HbjlGameController:ackHbjlExit(info)
 --   '1-房间维护结算退出 2-你已经被系统踢出房间,请稍后重试 3-超过限定局数未操作'
    local str = ""
     if info.m_type ==1 then
        str = "房间维护，请退出"
    elseif info.m_type ==2 then
         str = "你已经被系统踢出房间,请稍后重试"
      elseif info.m_type ==3 then
         str = "你长时间未参与游戏，稍后来战吧！"
    end
    local DlgAlert = require("app.hall.base.ui.MessageBox")
    local dlg = DlgAlert.showTipsAlert({title = "提示", tip = str, tip_size = 34})
    dlg:setSingleBtn("确定", function ()
		dlg:closeDialog()
        self:releaseInstance()
    end)
    dlg:setBackBtnEnable(false)
    dlg:enableTouch(false)
   
end
-- 向游戏服发消息
-- @params      __cmdId( number )    消息命令
-- @params     __dataTable( table )  消息结构体 
function  HbjlGameController:send2GameServer4hbjl( __cmdId, __dataTable)
     ConnectManager:send2SceneServer( self.m_gameAtomTypeId , __cmdId , __dataTable )
end
function HbjlGameController:gameStart(__info)
    self.m_sRecordId = __info.m_recordId or ""
    self.gameScene:getMainLayer():closeBanlance()
    self.gameScene:getMainLayer():clearData() 
 --   self.gameScene:getMainLayer():setHongbaoVisible(false)
    self.name = __info.m_playerInfo.m_nickname
    self.curPlayerInfo = __info.m_playerInfo
	self.gameScene:getMainLayer():setInfo(self.curPlayerInfo)
    if __info.m_playerInfo.m_chairId ==self.m_selfChairID then
        self.gameScene:getMainLayer():setGiveBtn(true)
        self.gameScene:getMainLayer():setGrabBtn(false)

        self.m_canOut = false
        self.gameScene:getMainLayer():showRunTime(__info.m_countDownTime)
        print("自己发红包 ")
    else
        print("等待发红包 ")  
        self.gameScene:getMainLayer():setWaitName( self.name) 
--         self.gameScene:getMainLayer():setGiveBtn(false)
--        self.gameScene:getMainLayer():setGrabBtn(true)
--        self.gameScene:getMainLayer():setHongbaoVisible(true) 
    end
   
    self.gameScene:getMainLayer():setJieLongPlayer(__info.m_playerInfo.m_chairId)
    self.gameScene:getMainLayer():setRecordId(self.m_sRecordId)
    
end
function HbjlGameController:ackHbjlPlayerIn(__info)
    if __info.m_playerInfo.m_chairId == 8 then
        __info.m_playerInfo.m_chairId = self.m_selfChairID
    end
    self.gameScene:getMainLayer():addUser(__info)
end

function HbjlGameController:ackHbjlPlayerOut(__info)
     if __info.m_chairId == 8 then
        __info.m_chairId = self.m_selfChairID
    end
    self.gameScene:getMainLayer():removeUser(__info)
end

function HbjlGameController:HbjlGameState(__info)
    --状态 1-发红包阶段 2-抢红包阶段 3-结算阶段
    self.m_sRecordId = __info.m_recordId or ""
    self.gameScene:getMainLayer():setRecordId(self.m_sRecordId)
	self.gameScene:getMainLayer():closeBanlance()
    self.gameScene:getMainLayer():clearData()
	if __info.m_hasGrabEnv ==1 then
        self.m_canOut = false
    end
	
	if self.showBalanceTimer then
		scheduler.unscheduleGlobal(self.showBalanceTimer)
		self.showBalanceTimer = nil
	end
	
    local flag = false
    self.name = ""
    if __info.m_curGiverId == __info.m_selfChairID then
        flag = true
    else
        for k,v in pairs(__info.m_playerInfo) do 
           if  __info.m_curGiverId == v.m_chairId then
                self.name =v.m_nickname
                self.curPlayerInfo = v
            end
        end
    end
    self.m_selfChairID  = __info.m_selfChairID
--   if __info.m_curGiverId == 8 then
--        __info.m_curGiverId =self.m_selfChairID
--    end
    if __info.m_curGiverId ~=0 then
        self.gameScene:getMainLayer():setJieLongPlayer(__info.m_curGiverId)
    end
   self.gameScene:getMainLayer():showMyInfo(__info.m_curCoin)
   self.gameScene:getMainLayer():showDifen(__info.m_baseScore*0.01) 
   if __info.m_selfChairID ~= 8 then 
        for k,v in pairs(__info.m_playerInfo) do 
            if v.m_chairId == 8 then
                __info.m_playerInfo[k].m_chairId = __info.m_selfChairID
            end
        end
        
    end
    if #__info.m_playerInfo ~=0 then
        self.gameScene:getMainLayer():updateUserList(__info.m_playerInfo)
    end
	
	if self.curPlayerInfo then
		self.gameScene:getMainLayer():setInfo(self.curPlayerInfo)
    end

	if __info.m_state == 1 then
        --self.gameScene:getMainLayer():closeBanlance()
     
        self.gameScene:getMainLayer():setGiveBtn(flag) 
        if not flag then 
            self.gameScene:getMainLayer():setWaitName(self.name)
        else
             self.gameScene:getMainLayer():showRunTime(__info.m_countDownTime)
        end
        self.gameScene:getMainLayer():setGrabBtn(false) 
 --       self.gameScene:getMainLayer():setHongbaoVisible(false)
	elseif __info.m_state == 2 then
        self.gameScene:getMainLayer():showRunTime(__info.m_countDownTime)
     --   self.gameScene:getMainLayer():showJielongName(self.name)
        --self.gameScene:getMainLayer():closeBanlance()
		self.gameScene:getMainLayer():setGiveBtn(false) 
        if __info.m_hasGrabEnv ==1 then
             self.gameScene:getMainLayer():setGrabBtn(false) 
        else
            self.gameScene:getMainLayer():setGrabBtn(true) 
        end
      --  self.gameScene:getMainLayer():setHongbaoVisible(true)
        self.gameScene:getMainLayer():setHongBaoNum(__info.m_leftNum)
    else
  --       self.gameScene:getMainLayer():setHongbaoVisible(false)
        self.gameScene:getMainLayer():setGiveBtn(false) 
        self.gameScene:getMainLayer():setGrabBtn(false) 
    end

    print("当前状态   "..__info.m_state)
end

function HbjlGameController:ackHbjlGive(__info)
    if __info.m_ret == 0 then
        if __info.m_chairId == self.m_selfChairID then
            self.gameScene:getMainLayer():showMyInfo(__info.m_curCoin)
        else
            if __info.m_chairId == 8 then
                __info.m_chairId =self.m_selfChairID 

            end
             self.gameScene:getMainLayer()._otherInfo[__info.m_chairId]:setUserMoney(__info.m_curCoin*0.01)
        end
   --      self.gameScene:getMainLayer():showJielongName(self.name)
        self.gameScene:getMainLayer():showRunTime(__info.m_countDownTime)
        self.gameScene:getMainLayer().wait_name:setVisible(false)
        if self.gameScene:getMainLayer()._Scheduler2 then
            Scheduler.unscheduleGlobal(self.gameScene:getMainLayer()._Scheduler2)	
            self.gameScene:getMainLayer()._Scheduler2 = nil 
        end
		self.gameScene:getMainLayer():closeBanlance()
        self.gameScene:getMainLayer().m_HbjlSendLayer:setVisible(false)
        self.gameScene:getMainLayer():setGiveBtn(false)  
        self.gameScene:getMainLayer():setGrabBtn(true) 
        --self.gameScene:getMainLayer():setInfo(self.curPlayerInfo)
     --   self.gameScene:getMainLayer():setHongbaoVisible(true)
      elseif __info.m_ret == -710001 then
        TOAST("您的金币不足，请充值！")
    elseif __info.m_ret == -710002 then
        TOAST("手快有, 手慢无, 红包已经被抢光!")
    elseif __info.m_ret == -710003 then
        TOAST("金币不足, 不能发红包")
    elseif __info.m_ret == -710004 then
        TOAST("查无此人")
    elseif __info.m_ret == -710005 then
        TOAST("无效配置")
    elseif __info.m_ret == -710006 then
        TOAST("一局只能抢一次红包")
    elseif __info.m_ret == -710007 then
        TOAST("不是发红包者")
    elseif __info.m_ret == -710008 then
        TOAST("手快有, 手慢无, 红包已经被抢光!")
    end
end

function HbjlGameController:getPlayerByChairId(chairId)
end

function HbjlGameController:ackHbjlGrab(__info)
    if self.gameScene == nil then
        return
    end
    if __info.m_ret == 0 then
       
        if self.m_selfChairID == __info.m_chairId then
           -- self.gameScene:getMainLayer():setGrabBtn(false)
            self.m_canOut =false 
        end
      
        self.gameScene:getMainLayer():flyHongBao(__info)
    elseif __info.m_ret == -710001 then
        TOAST("您的金币不足，请充值！")
    elseif __info.m_ret == -710002 then
        TOAST("手快有, 手慢无, 红包已经被抢光!")
    elseif __info.m_ret == -710003 then
        TOAST("金币不足, 不能发红包")
    elseif __info.m_ret == -710004 then
        TOAST("查无此人")
    elseif __info.m_ret == -710005 then
        TOAST("无效配置")
    elseif __info.m_ret == -710006 then
        TOAST("一局只能抢一次红包")
    elseif __info.m_ret == -710007 then
        TOAST("不是发红包者")
    elseif __info.m_ret == -710008 then
        TOAST("手快有, 手慢无, 红包已经被抢光!")
    end
end

function HbjlGameController:HbjlGameBalance(__info) 
    function delay ()
        if  self.gameScene then
            self.gameScene:getMainLayer():showBanlance(__info)
            self.gameScene:getMainLayer():setGrabBtn(false)   
        end
    end
	
	self.gameScene:getMainLayer():closeBanlance()        
	if self.showBalanceTimer then
		scheduler.unscheduleGlobal(self.showBalanceTimer)
		self.showBalanceTimer = nil
	end
	
    self.showBalanceTimer = ToolKit:delayDoSomething(delay,1)
    self.gameScene:getMainLayer():stopRunTime()
end

function HbjlGameController:handleError(  __info ) 
        --ToolKit:removeLoadingDialog()
		print("请求进入场景失败!",__info.m_result)
        if __info.m_result > hbjlGlobal.hbjlErroCodeBegin then
            if __info.m_result == -722 then   --未找到该游戏对应服务
                local scene = display.getRunningScene()
                if scene and (scene.__cname == "hbjlScene" )then
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
                if scene and scene.__cname == "hbjlScene"  then
                         
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
            hbjlUtil:getInstance():showErroCodeTipsByErrorCode( __info.m_result )
        end 
end
 --处理成功登录游戏服
-- @params __info( table ) 登录游戏服成功消息数据
function HbjlGameController:ackEnterGame( __info )
	print("HbjlGameController:ackEnterGame")
	--ToolKit:removeLoadingDialog()  
    if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
        local scenePath = getGamePath(__info.m_gameAtomTypeId)
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL )  
    end 
end
 

-- 消息总入口函数
-- @params __idStr( string )   消息命令
-- @params __info( table )     消息内容
function HbjlGameController:netMsgHandler(__idStr, __info )
  if  self.m_callBackFuncList[__idStr]  then
      (self.m_callBackFuncList[__idStr])(__info)
  else
      print("没有处理消息",__idStr)
  end
end
 
function HbjlGameController:sceneNetMsgHandler( __idStr, __info )
  if __idStr == "CS_H2C_HandleMsg_Ack" then
      if __info.m_result == 0 then
            local gameAtomTypeId = __info.m_gameAtomTypeId 
            if type( __info.m_message ) == "table" then
                if next( __info.m_message )  then
                    local cmdId = __info.m_message[1].id
                    local info = __info.m_message[1].msgs
                    self:netMsgHandler(cmdId, info)
                end
            end 
      else
          print("__info.m_result", __info.m_result )
      end
    end
end
  
function HbjlGameController:ackSceneMessage(__info)
    if __info.id == "CS_M2C_Baccarat_Exit_Nty" then
        local DlgAlert = require("app.hall.base.ui.MessageBox") 
        local dlg= nil
        if __info.msgs.m_type == 3 then
             dlg = DlgAlert.showTipsAlert({title = "提示", tip = "你已经被系统踢出房间，请稍后重试"})
        elseif __info.msgs.m_type == 4 then
             dlg = DlgAlert.showTipsAlert({title = "提示", tip = "房间维护，请稍后再游戏"})
        end
        dlg:setSingleBtn("退出", function ()
			dlg:closeDialog()
            self:releaseInstance()  
        end)
        dlg:enableTouch(false)
    end
end 
-- '1-切到后台 2-切回游戏'},
function HbjlGameController:gameBackgroundReq( __info)
   self:send2GameServer4hbjl("CS_C2M_RedEnvelopes_Background_Req", {__info} )
end

function HbjlGameController:ackhbjlBackground( __info  )
   print("HbjlGameController:ackhbjlBackground")
   --dump( __info )
--   if __info.m_ret~= 0 then
--     local DlgAlert = require("app.hall.base.ui.MessageBox")
--        local kickDialog = DlgAlert.new()
--        local dlg = kickDialog.showTipsAlert({title = "提示", tip = "与服务器断开", tip_size = 34})
--                dlg:setSingleBtn("确定", function () 
--                     self.gameScene:onBackButtonClicked()
--        end)
--        dlg:setBackBtnEnable(false)
--        dlg:enableTouch(false)
--    end
end


function HbjlGameController:rewhbjlForceExit()
   self:send2GameServer4hbjl("CS_C2M_RedEnvelopes_ForceExit_Req", {} )
end

function HbjlGameController:GiveReq()
   self:send2GameServer4hbjl("CS_C2M_RedEnvelopes_Give_Req", {} )
end

function HbjlGameController:GrabReq()
   self:send2GameServer4hbjl("CS_C2M_RedEnvelopes_Grab_Req", {} )
end

function HbjlGameController:ackhbjlForceExit( __info )
    print("HbjlGameController:ackhbjlForceExit")
  --  self.gameScene:exitGame()
    --dump( __info )
	self:releaseInstance()
end

function HbjlGameController:notifyhbjlExit( __info )
    --print("HbjlGameController:notifyhbjlExit")
    --dump( __info  )
      print("游戏未开始，超时强制解散")
    if not tolua.isnull( self.gameScene ) then
       self.gameScene.m_hbjlMainLayer:showDissolveDlg( __info.m_type )
    end
end

return HbjlGameController