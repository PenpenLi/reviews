--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local LandlordGameSearchPath = "src/app/game/landlords"
require("app.game.landlords.src.common.LandInit")
local DlgAlert = require("app.hall.base.ui.MessageBox")
local GamePlayerInfo = require("src.app.game.common.data.GamePlayerInfo")
local MatchEvent = require("src.app.hall.MatchGameList.control.MatchEvent")
local MatchController = require("src.app.hall.MatchGameList.control.MatchController")

local sLocalScenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene"

local BaseGameController = import(".BaseGameController")
local LandlordGameController =  class("LandlordGameController",function()
    return BaseGameController.new()
end) 

LandlordGameController.instance = nil

-- 获取房间控制器实例
function LandlordGameController:getInstance()
    if LandlordGameController.instance == nil then
        LandlordGameController.instance = LandlordGameController.new()
    end
    return LandlordGameController.instance
end

function LandlordGameController:releaseInstance()
    if LandlordGameController.instance then
        LandlordGameController.instance:onDestory()
        LandlordGameController.instance = nil
		g_GameController = nil
    end
end

function LandlordGameController:ctor()
    print("LandlordGameController:ctor()")
    self.m_roundIndex = 0;      -- 第N轮
    self.m_roundNum = 0;        -- 总N轮
    self.m_inning = 0;          -- 当前第几局
    self.m_totalInning = 0;     -- 总局数
    self.m_totalPlayerNum = 0; 
    self.m_curRank = 0; 
    self.m_roundPlayerNum = 0;
    self.m_m_upgradeCnt = 0;

    self.m_pNetMsgData = {};

    self:myInit()
end 

function LandlordGameController:myInit()
    -- 添加搜索路径
    local t_extrasearchpath = {
        LandlordGameSearchPath.."/res",
        LandlordGameSearchPath.."/src",
        LandlordGameSearchPath.."/res/csb",
        LandlordGameSearchPath.."/src/landcommon",
        LandlordGameSearchPath .. "/res/animation",
        LandlordGameSearchPath .. "/res/csb/resouces",
    }
    local t_searchpath = cc.FileUtils:getInstance():getSearchPaths()
    for k,v in pairs(t_extrasearchpath) do
        table.insert(t_searchpath, cc.FileUtils:getInstance():getWritablePath() .. UpdateConfig.updateDirName..v)
        table.insert(t_searchpath, v)
    end
    cc.FileUtils:getInstance():setSearchPaths(t_searchpath)

    local msg_tbl = 
    {
    "CS_G2C_LandLord_LoginData_Nty"    ,
    "CS_G2C_LandLord_AutoControl_Nty"  ,
    "CS_G2C_LandLord_Ready_Nty"        ,
    "CS_G2C_LandLord_Begin_Nty"        ,
    "CS_G2C_LandLord_BeLord_Nty"       ,
    "CS_G2C_LandLord_BeLordResult_Nty" ,
    "CS_G2C_LandLord_DoubleOpt_Nty"    ,
    "CS_G2C_LandLord_Double_Nty"       ,
    "CS_G2C_LandLord_Out_Nty"          ,
    "CS_G2C_LandLord_Result_Nty"       ,
    "CS_G2C_LandLord_CarryOn_Nty"      ,
    "CS_G2C_HLLand_LoginData_Nty"      ,
    "CS_G2C_HLLand_Begin_Nty"          ,
    "CS_G2C_HLLand_OpenPoker_Nty"      ,
    "CS_G2C_HLLand_Result_Nty"         ,
    "CS_G2C_HLLand_LandOpenPoker_Nty"  ,
	"CS_G2C_UserLeft_Ack"  			   ,
    }

    local function GameMsgHandler( _idStr, _info )
        _info.m_nClockTime = os.clock();
        if self.gameScene ~= nil and self.m_bIsInitlLayer then
            GAME_SCENE_DO( "reciveGameServerMsg" , _idStr , _info )
        else
            table.insert(self.m_pNetMsgData, {m_nType = 2, m_sMsgId = _idStr, m_pCmd = _info});
        end
    end

    self:setNetMsgCallbackByProtocolList( msg_tbl , GameMsgHandler )
    self.m_callBackFuncList = {}
     
	self.m_callBackFuncList["CS_M2C_SysExitGame_Ack"]                     = handler(self,self.ackSysExitGame)
	self.m_callBackFuncList["CS_M2C_SysEnter_Nty"]                        = handler(self,self.notifySysEnter)
	self.m_callBackFuncList["CS_M2C_SysBeforeGameTable_Nty"]              = handler(self,self.notifySysBeforeGameTable)
	self.m_callBackFuncList["CS_M2C_SysEnd_Nty"]                          = handler(self,self.notifySysEnd)
	self.m_callBackFuncList["CS_M2C_SysExitSpecialAskPlayer_Nty"]         = handler(self,self.notifySysExitSpecialAsk)
	self.m_callBackFuncList["CS_M2C_SysExitSpecialConfirm_Ack"]           = handler(self,self.ackSysExitSpecialConfirm)
	self.m_callBackFuncList["CS_M2C_SysContinueGame_Ack"]           	  = handler(self,self.ackContinueGame)
    self.m_callBackFuncList["CS_M2C_MatchEnter_Nty"]           	  = handler(self,self.ackMatchEnterGame)
    -- self.m_callBackFuncList["CS_M2C_SignUp_Ack"]           	  = handler(self,self.ackSignUpGame)
    -- self.m_callBackFuncList["CS_M2C_SignInfo_Nty"]           	  = handler(self,self.ackSignInfoGame)
    self.m_callBackFuncList["CS_M2C_MatchBeforeGameTable_Nty"]           	  = handler(self,self.ackMatchBeforeGameTableGame)
    self.m_callBackFuncList["CS_M2C_MatchGameResult_Nty"]           	  = handler(self,self.ackMatchGameResultGame) 
    -- self.m_callBackFuncList["CS_M2C_CancelSignUp_Ack"]           	  = handler(self,self.ackCancelSignUp) 
    --  self.m_callBackFuncList["CS_M2C_MatchSignTimeOut_Nty"]           	  = handler(self,self.ackMatchSignTimeOut) 
    self.m_callBackFuncList["CS_M2C_MatchExitGame_Ack"]           	  = handler(self,self.ackMatchExit) 
    --self.m_callBackFuncList["CS_M2C_Enter_Ack"]                         = handler(self, self.notifySysEnter);
    self.m_callBackFuncList["CS_M2C_RefreshMatchRank_Nty"]             = handler(self, self.onRefreshMatchRank_Nty);
    
    LogINFO("斗地主 LandHallMsgController 初始化")
	-- Protocol.loadProtocolTemp("Peasants_vs_Landlord.protoReg") -- load 协议模板
    Protocol.loadProtocolTemp("app.game.landlords.src.landcommon.Peasants_vs_Landlord.protoReg") 
   	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
end
function LandlordGameController:ackMatchExit(info)
    if info.m_result ==0 then
        if self.gameScene ~= nil then
            UIAdapter:popScene()
        end
        self.gameScene = nil
    end
end

function LandlordGameController:createMatchScene()
    if self.gameScene or tolua.isnull(self.gameScene)  then
        local scenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene";
        MatchController.getInstance():closeView("MatchSignView");
        self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL, self.m_gameAtomTypeId );
    end
end

function LandlordGameController:sendHandlerData()
    for index = 1, #self.m_pNetMsgData do
        local item = self.m_pNetMsgData[index];
        if item.m_nType == 1 then
            if self.m_callBackFuncList[item.m_sMsgId] then
                (self.m_callBackFuncList[item.m_sMsgId])( item.m_pCmd );
            end
        else
            GAME_SCENE_DO( "reciveGameServerMsg" , item.m_sMsgId , item.m_pCmd );    
        end
    end
    self.m_pNetMsgData = {};
end


function LandlordGameController:netMsgHandler( __idStr, __info )
    if "CS_M2C_CancelSignUp_Ack" == __idStr then
        print("取消比赛----\n")
        self:ackCancelSignUp(__info);
    elseif "CS_M2C_MatchSignTimeOut_Nty" == __idStr then
        print("报名超时----\n")
        TOAST("报名超时未开始, 已取消该场比赛")
        sendMsg(MatchEvent.MSG_SIGNUP_TIME_OUT)
        -- self:ackMatchSignTimeOut(__info);
    elseif "CS_M2C_SignUp_Ack" == __idStr then
        print("收到报名消息----\n")
        self:ackSignUpGame(__info);
    elseif "CS_M2C_SignInfo_Nty" == __idStr then
        print("收到参赛人员数据----\n")
        self:ackSignInfoGame(__info);
    else
        if self.m_callBackFuncList[__idStr] then
            __info.m_nClockTime = os.clock();
            if self.gameScene ~= nil and self.m_bIsInitlLayer then
                self.m_callBackFuncList[__idStr]( __info )
            else
                if "CS_M2C_MatchEnter_Nty" == __idStr then
                    if __info.m_state > 3 then
                        self:createMatchScene();
                        table.insert(self.m_pNetMsgData, {m_nType = 1, m_sMsgId = __idStr, m_pCmd = __info});
                    else
                        if __info.m_state == 0 then
                            self:reqJoinMatch();
                        end
                        sendMsg(MatchEvent.MSG_SIGN_STATE, {
                            m_gameId = self.m_gameAtomTypeId,
                            m_state = __info.m_state,
                            m_enrollNum = __info.m_roundPlayerNum
                        })
                    end
                elseif "CS_M2C_MatchBeforeGameTable_Nty" == __idStr or "CS_M2C_MatchGameResult_Nty" == __idStr then
                    self:createMatchScene();
                    table.insert(self.m_pNetMsgData, {m_nType = 1, m_sMsgId = __idStr, m_pCmd = __info});
                else
                    table.insert(self.m_pNetMsgData, {m_nType = 1, m_sMsgId = __idStr, m_pCmd = __info});
                end
            end
        -- elseif "CS_M2C_GameStart_Nty" == __idStr then
        --     --self:notifyEnterGame(__info)
        else
           LogINFO("未注册消息:",__idStr)
        end
    end
end

function LandlordGameController:ackCancelSignUp(__info)
    --   self:releaseInstance()
       if __info.m_ret == 0 then
           --self.gameScene.m_MatchJoinLayer:SignCancel()
        elseif __info.m_ret == -10 then
           TOAST("玩家不存在")
       elseif __info.m_ret == -25008  then
           TOAST("比赛已经开始, 无法取消")
       end
   
       sendMsg(MatchEvent.MSG_CANCEL_SIGNUP, {m_gameId = self.m_gameAtomTypeId, m_code = __info.m_ret, m_info = __info})
   end



-- function LandlordGameController:ackMatchSignTimeOut()
--     TOAST("报名超时未开始, 已取消该场比赛")
--     --self.gameScene.m_MatchJoinLayer:SignCancel()
--     sendMsg(MatchEvent.MSG_SIGNUP_TIME_OUT)
-- end

function LandlordGameController:ackSignUpGame(__info)
    if __info.m_ret == 0 then
        --self.gameScene.m_MatchJoinLayer:SignUp()
    elseif __info.m_ret == -10 then
        TOAST("玩家不存在")
    elseif __info.m_ret == -25005 then
        TOAST("玩家已报名")
    elseif __info.m_ret == -25006 then
        TOAST("报名中, 请稍后")
    elseif __info.m_ret == -25007 then
        TOAST("金币不足, 无法报名")
    elseif __info.m_ret == -25008 then
        TOAST("人数已满, 报名下一场比赛")
    end
    sendMsg(MatchEvent.MSG_SIGNUP, {m_gameId = self.m_gameAtomTypeId, m_code = __info.m_ret, m_info = __info});
end
function LandlordGameController:ackSignInfoGame(info)
    --self.gameScene.m_MatchJoinLayer:refreshMatchData(info)
    sendMsg(MatchEvent.MSG_SIGN_INFO, {m_gameId = self.m_gameAtomTypeId, m_info = info });
end

--进入比赛房场景
function LandlordGameController:ackMatchEnterGame(info)
    --0：未报名(按钮状态：未报名)
    --1: 报名扣费中(显示为报名, 暂时不可点击),
    --2：已报名(报名成功，按钮显示为退赛) 
    --3: 报名人员已满, 分配房间中(不可退赛) 
    --4: 已开赛, 正在游戏中(不显示报名页面) 
    --5: 当前轮比赛结束, 显示等待中 
    --6: 晋级界面,显示名次'
    self.m_bIsEnter = true
    self.m_roundIndex = info.m_roundIndex;      -- 第N轮
    self.m_roundNum = info.m_roundNum;          -- 总N轮
    self.m_inning = info.m_inning;              -- 当前第几局
    self.m_totalInning = info.m_totalInning;    -- 总局数
    self.m_curRank = info.m_showRank;
    self.m_roundPlayerNum = info.m_roundPlayerNum;
    self.m_upgradeCnt = info.m_upgradeCnt;

    if 0 == info.m_state then
        --ConnectManager:send2SceneServer(self.m_gameAtomTypeId, "CS_C2M_Enter_Req", {self.m_gameAtomTypeId, "" });
        self:reqJoinMatch()
    elseif 1 == info.m_state then
        --sendMsg(MatchEvent.MSG_SIGN_STATE, {m_gameId = self.m_gameAtomTypeId, m_state = info.m_state, m_enrollNum = info.m_roundPlayerNum})
    elseif 2 == info.m_state then
        --sendMsg(MatchEvent.MSG_SIGN_STATE, {m_gameId = self.m_gameAtomTypeId, m_state = info.m_state, m_enrollNum = info.m_roundPlayerNum})
    elseif 3 == info.m_state then
        --sendMsg(MatchEvent.MSG_SIGN_STATE, {m_gameId = self.m_gameAtomTypeId, m_state = info.m_state, m_enrollNum = info.m_roundPlayerNum})
    else
        -- if tolua.isnull(self.gameScene)  then
        --     local scenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene";
        --     MatchController.getInstance():closeView("MatchSignView");
        --     self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL, self.m_gameAtomTypeId );
        -- end

        if info.m_state==5 then
            self.gameScene:showMatchWaitView();
            self.gameScene:hideMatchResultView();
        elseif info.m_state==4 then
            self.gameScene:closeMatchJoinLayer()
            self.gameScene:closeMatchJinjiLayer()
            self.gameScene.gameRoomBgLayer:removeMatchWaitAni();
            self.__players = {}
            self.__players , self.meChair , self.myGold = self:initTablePlayerInfo( info )
            self.minScore = info.m_minScore
            self.gameScene:reciveRoomMsg( self.m_gameAtomTypeId )
            self.gameScene:reciveChairTable( self.__players , self.meChair , self.minScore )
            self.gameScene:hideMatchResultView();
            self.gameScene:hideMatchWaitView();
            self.gameScene.m_landMainLayer:refreshView();
        elseif info.m_state == 6 then
            self.gameScene:showMatchWaitView();
        end
    end
    sendMsg(MatchEvent.MSG_SIGN_STATE, {m_gameId = self.m_gameAtomTypeId, m_state = info.m_state, m_enrollNum = info.m_roundPlayerNum})

end

function LandlordGameController:ackMatchBeforeGameTableGame(info)
    -- if tolua.isnull(self.gameScene)  then
    --     local scenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene";
    --     MatchController.getInstance():closeView("MatchSignView");
    --     self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL, self.m_gameAtomTypeId );
        
    -- end

    -- { 1		, 1		, 'm_tableId'				, 'UINT'								, 1     , '桌子编号'},
	-- { 2		, 1		, 'm_minScore'				, 'UINT'								, 1     , '底分'},	
	-- { 3		, 1		, 'm_roundIndex'			, 'UBYTE'								, 1     , '第N轮'},
	-- { 4		, 1		, 'm_roundNum'				, 'UBYTE'								, 1     , '总N轮'},
	-- { 5		, 1		, 'm_upgradeCnt'			, 'UINT'								, 1     , '该轮前N名晋级'},
	-- { 6		, 1		, 'm_roundPlayerNum'		, 'UINT'								, 1     , '当前轮总人数'},
	-- { 7		, 1		, 'm_curStage'				, 'UBYTE'								, 1     , '当前阶段，1:晋级赛，2:半决赛，3:决赛，其他值为数值错误'},
	-- { 8		, 1		, 'm_beforeGameUser'		, 'PstMatchBeforeGameUser'				, 3  	, '玩家数组'},
	-- { 9		, 1		, 'm_showRank'				, 'UINT'								, 1  	, '中间晋级界面, 该状态持续10s, 才开始下一轮, 只针对状态6可用, 决赛或者淘汰不会下发'},
	-- { 10	, 1		, 'm_inning'				, 'UINT'								, 1     , '当前第几局'},
	-- { 11	, 1		, 'm_totalInning'			, 'UINT'								, 1     , '总局数'},

    self.m_roundIndex = info.m_roundIndex;      -- 第N轮
    self.m_roundNum = info.m_roundNum;          -- 总N轮
    self.m_inning = info.m_inning;              -- 当前第几局
    self.m_totalInning = info.m_totalInning;    -- 总局数
    self.m_curRank = info.m_showRank;
    self.m_roundPlayerNum = info.m_roundPlayerNum;
    self.m_upgradeCnt = info.m_upgradeCnt;

    self.gameScene:closeMatchJoinLayer()
    self.gameScene:closeMatchJinjiLayer()
    self.gameScene.gameRoomBgLayer:removeMatchWaitAni()
    
    self.__players = {}
	self.__players , self.meChair , self.myGold = self:initTablePlayerInfo( info )
    self.minScore = info.m_minScore
    self.gameScene:reciveRoomMsg( self.m_gameAtomTypeId )
    self.gameScene:reciveChairTable( self.__players , self.meChair , self.minScore )
    self.gameScene:hideMatchResultView();
    self.gameScene:hideMatchWaitView();
    self.gameScene.m_landMainLayer:refreshView();
    --MatchController.releseInstance()
end
function LandlordGameController:ackMatchGameResultGame(info)

--   CS_M2C_MatchGameResult_Nty =
-- {
-- 	--{ 1		, 1		, 'm_gameAtomTypeId'			, 'UINT'					 , 1		, '游戏最小配置类型ID'},
-- 	{ 1		, 1		, 'm_type'						, 'UBYTE'					 , 1		, '类型，0:淘汰,1:晋级,2:整场比赛结束'},
-- 	--{ 2		, 1		, 'm_contidion'					, 'UBYTE'					 , 1	    , '比赛报名条件，0：免费报名，1：开赛选项1,2：开赛选项2，3：开赛选项3'},
-- 	--{ 4		, 1		, 'm_upgradeNextRound'			, 'UBYTE'					 , 1		, '晋级到下一轮的轮次(只针对m_type=1的情况)'},
-- 	{ 2		, 1		, 'm_upgradeCnt'				, 'UINT'					 , 1		, '前N名晋级, 非决赛使用'},
-- 	{ 3		, 1		, 'm_curRank'					, 'UINT'					 , 1		, '玩家当前排名, 非决赛使用'},
-- 	{ 4		, 1		, 'm_goldCoin'					, 'UINT'					 , 1		, '玩家奖励金币数量, 非决赛使用'},
-- 	--{ 5		, 1		, 'm_lastRankAward'				, 'PstMatchRankReward'		 , 3		, '最终决赛比赛奖励'},
-- 	--{ 8		, 1		, 'm_diamond'					, 'UINT'					 , 1		, '奖励钻石数量'},
-- 	--{ 9		, 1		, 'm_itemArr'					, 'PstMatchRewardItem'		 , 1024		, '奖励道具数组'},
-- }
    self.m_curRank = info.m_curRank;
    
    -- if tolua.isnull(self.gameScene)  then
    --     local scenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene";
    --     MatchController.getInstance():closeView("MatchSignView");
    --     self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL, self.m_gameAtomTypeId );
    -- end

    if info.m_type == 2 then
        self.gameScene:createMatchWinLayer(info);
        self.gameScene:hideMatchWaitView();
    elseif  info.m_type == 1 then 
        --self.gameScene:createMatchJinjiLayer(info)
        self.gameScene:showMatchWaitView();
    else
        self.gameScene:createMatchTaotaiLayer(info);
        -- self.gameScene:showMatchWaitView();
        self.gameScene:hideMatchWaitView();
    end
    self.gameScene:hideMatchResultView();
    
    self.gameScene.gameRoomBgLayer:removeMatchWaitAni()
    --self.m_bIsEnter = false
end

function LandlordGameController:onRefreshMatchRank_Nty(__info)
    -- { 1		, 1		, 'm_rank'					, 'UINT'								, 1     , '玩家当前名次'},
    -- { 2		, 1		, 'm_totalPlayerNum'		, 'UINT'								, 1     , '当前轮次比赛总人数'},
    self.m_curRank = __info.m_rank;
    self.m_totalPlayerNum = __info.m_totalPlayerNum;
    if self.gameScene and self.gameScene.m_landMainLayer then 
        self.gameScene.m_landMainLayer:refreshView();
    end
end

function LandlordGameController:isMatchGame()
    if self.m_gameAtomTypeId<=101204 and self.m_gameAtomTypeId>=101201 then
        return true
    end
    return false
end



function LandlordGameController:onDestory()
	print("----------LandlordGameController:onDestory begin--------------")
	self.m_bIsEnter = false
	self.m_callBackFuncList = {}
	
	TotalController:removeNetMsgCallback(self,Protocol.SceneServer, "CS_H2C_HandleMsg_Ack")

    -- 添加搜索路径
    ToolKit:removeSearchPath(LandlordGameSearchPath)

    if self.gameScene then
        self.gameScene:onExit();
		UIAdapter:popScene()
		self.gameScene = nil
	end
    
    self:onBaseDestory()
	print("----------LandlordGameController:onDestory end--------------")
	
end

function LandlordGameController:handleError(  __info )
	print("LandlordGameController:onEnterScene1111111111111111111")
 
	--ToolKit:removeLoadingDialog()
	print("请求进入场景失败!",__info.m_result)
--    if __info.m_message[i].msgs.m_ret == -705 then
--        TOAST("") 
end

 --处理成功登录游戏服
-- @params __info( table ) 登录游戏服成功消息数据
function LandlordGameController:ackEnterGame( __info )
	print("LandlordGameController:ackEnterGame")
    --ToolKit:removeLoadingDialog()  
    self.m_bIsEnter = true
    if self:isMatchGame() ~= true then
        if tolua.isnull( self.gameScene ) and __info.m_ret == 0 then 
            local scenePath = "src.app.game.landlords.src.classicland.scene.LandGameMainScene"
            self.gameScene = UIAdapter:pushScene(scenePath, DIRECTION.HORIZONTAL,__info.m_gameAtomTypeId )  
        end
    end
end
 
function LandlordGameController:sceneNetMsgHandler( __idStr, __info )
	if __idStr ~= "CS_H2C_HandleMsg_Ack" then return end
	 
	if __info.m_result == 0 then
		dump( __info )
		if __info.m_message and __info.m_message[1] and __info.m_message[1].id then
			local cmdId = __info.m_message[1].id
			local info = __info.m_message[1].msgs
			self:netMsgHandler(cmdId, info)
		end
	else
		LogINFO("找不到场景信息")
        local data = getErrorTipById(  __info.m_result)
        local box_title = "提示"
        local box_content = data.tip or ""
        local cb1 = function() end
        local params = {
			title = box_title,
			message = box_content,
			leftStr = btnText1,
			rightStr = btnText2,
			tip = box_content,
        }
        DlgAlert.showRightAlert(params,cb1) 
	end
end

function LandlordGameController:reqSysExitGame( _flag )
	local flag = _flag or 0
	if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_SysExitGame_Req", { self.m_gameAtomTypeId , flag })
	end
end
function LandlordGameController:reqJoinMatch( )
	 
	if self.m_gameAtomTypeId then 
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_SignUp_Req", { self.m_gameAtomTypeId , 0,"0" })
	end
end
function LandlordGameController:reqSignCancel( )
	 
	if self.m_gameAtomTypeId then 
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_CancelSignUp_Req", { self.m_gameAtomTypeId  ,"0" })
	end
end

function LandlordGameController:reqMatchExitGame()
    -- if self.m_gameAtomTypeId then
    --     ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_MatchExitGame_Req", { });
    -- end
    if self.gameScene ~= nil then
        UIAdapter:popScene();
    end
    self.gameScene = nil
end



function LandlordGameController:reqSysExitSpecialConfirm( _flag )
	local flag = _flag or 0
	if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_SysExitSpecialConfirm_Req", { self.m_gameAtomTypeId , flag })
	end
end

function LandlordGameController:reqContinueGame()  
	if self.m_gameAtomTypeId then
		ConnectManager:send2SceneServer( self.m_gameAtomTypeId,"CS_C2M_SysContinueGame_Req",  {self.m_gameAtomTypeId} )
	end
end

function LandlordGameController:ackContinueGame(__info)
    if __info.m_result == 0 then 
        print("ackContinueGame111111111111111111")
     --   self.gameScene.m_landAccountLayer:setVisible(false)
        if self.gameScene then
			self.gameScene.m_landAccountLayer = nil
            self.gameScene.gameRoomBgLayer:playWaitAni()
        end
   elseif __info.m_result == -1 then
		local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "游戏已结束", tip_size = 34})
		dlg:setSingleBtn("确定", function ()
			dlg:closeDialog()
			self:releaseInstance()
        end)
    elseif __info.m_result == -2 then
		self.gameScene:exit()
        --self:releaseInstance()
    elseif __info.m_result == -705 then  
        local DlgAlert = require("app.hall.base.ui.MessageBox")
        local dlg = DlgAlert.showTipsAlert({title = "提示", tip = "金币不足！请退出", tip_size = 34})
		dlg:setSingleBtn("确定", function ()
			self.gameScene:exit()
			dlg:closeDialog()
			--self:releaseInstance()
        end)
        dlg:setBackBtnEnable(false)
        dlg:enableTouch(false)
    elseif __info.m_result == -747 then 
        local data = getErrorTipById( __info.m_result)
        local box_title = "提示"
        local box_content = data.tip or ""
        local cb1 = function() 
			self.gameScene:exit() 
		end
        local params = {
            title = box_title,
            message = box_content,
            leftStr = btnText1,
            rightStr = btnText2,
            tip = box_content,
        }
        DlgAlert.showRightAlert(params,cb1)   
    end
end

-- 通知进入系统房场景
function LandlordGameController:notifySysEnter( __info )
	self.m_gameAtomTypeId = __info.m_gameAtomTypeId
	self.__players = {}
    if __info.m_type == 0 then
	    self.gameScene.gameRoomBgLayer:playWaitAni()
    end
end

function LandlordGameController:notifySysBeforeGameTable( __info )
	self.__players = {}
	self.__players , self.meChair , self.myGold = self:initTablePlayerInfo( __info )
	self.minScore = __info.m_minScore
	self.roomCost = __info.m_roomCost
--	local function f()   
--		self.gameScene:reciveRoomMsg( __info.m_gameAtomTypeId )
--		self.gameScene:reciveChairTable( self.__players , self.meChair , self.minScore )
--	end
--	DO_ON_FRAME( CAL_PUSH_SCENE_FRAME() , f )
	self.gameScene:reciveRoomMsg( __info.m_gameAtomTypeId )
	self.gameScene:reciveChairTable( self.__players , self.meChair , self.minScore )
end

function LandlordGameController:getRoomCost()
	return self.roomCost or 0
end

function LandlordGameController:initTablePlayerInfo( __info )
	LogINFO("初始化系统下发的三个玩家的信息(进入游戏时)")
	local meChair = nil
	local myGold  = 0
	local myAcc   = Player:getAccountID()
	local players = {}

	for k,v in pairs( __info.m_beforeGameUser or __info.m_players ) do
	 	if v.m_accountId == myAcc then 
	 		meChair = k
	 		myGold  = v.m_goldCoin or v.m_gameScore
	 	end

	 	local p = GamePlayerInfo.new()
	 	p:setChairId(k)
	 	p:setAccountId(v.m_accountId)
	 	p:setFaceId(v.m_faceId)
	 	p:setNickname(v.m_nickname)
	 	p:setLevel(v.m_level)
	 	p:setGoldCoin(v.m_goldCoin )
        p:setGameScore(v.m_gameScore )
	 	players[k] = p
	end
	
	return players,meChair,myGold
end

function LandlordGameController:ackSysExitGame( __info )
	if __info.m_result == 0 then
		LogINFO("退出系统房成功") 
		self:releaseInstance()
	else
		
	end
end

function LandlordGameController:notifySysExitSpecialAsk( __info )
	LogINFO("接收到服务器回应,弹窗让玩家选择是否强退")
	self.m_gameAtomTypeId = __info.m_gameAtomTypeId
	local str = "强退将暂时扣除"..__info.m_leftCoin.."金币用于本局结算,结算后自动返还剩余金币,是否退出?"
	GAME_SCENE_DO("showExitGameLayer",str)
end

function LandlordGameController:ackSysExitSpecialConfirm( __info )
	if __info.m_result == 0 then 
	else
		TOAST( __info.m_result )
	end
end

function LandlordGameController:notifySysEnd( __info )
	GAME_SCENE_DO("onSysEnd")
end



return LandlordGameController